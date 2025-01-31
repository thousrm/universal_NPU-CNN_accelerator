`timescale 1ns/10ps

module tb_mac_pre_processing_unit
import mac_pkg::*;
import tx_pkg::*;
();

  // Parameters
  parameter CLK_PERIOD = 10;
  parameter NUM_RANDOM_TESTS = 1;

  // Signals
  logic                        i_clk                       ;
  logic                        i_reset                     ;
  logic                        mac_pre_o_instruction_ready ;
  logic                        mac_pre_i_instruction_valid ;
  tx_mac_instruction_port      mac_pre_i_instruction       ;
  logic                        mac_pre_i_done_ready        ;
  logic                        mac_pre_o_done              ;
  logic                        mac_pre_o_ifm_ready         ;
  logic                        mac_pre_i_ifm_valid         ;
  tx_mac_ifm_port              mac_pre_i_ifm               ;
  logic                        mac_pre_o_wfm_ready         ;
  logic                        mac_pre_i_wfm_valid         ;
  tx_mac_wfm_port              mac_pre_i_wfm               ;
  logic                        mac_pre_to_lane_i_ifm_ready ;
  logic                        mac_pre_to_lane_o_ifm_valid ;
  mac_pre_ifm_port             mac_pre_to_lane_o_ifm       ;
  logic [64-1:0]               mac_pre_to_lane_o_wfm_valid ;
  mac_pre_wfm_port             mac_pre_to_lane_o_wfm       ;

  mac_pre_processing_unit dut (.*);

  function automatic logic [31:0] float_to_fp32(real f);
    union {
      real f;
      logic [31:0] i;
    } conv;
    conv.f = f;
    return conv.i;
  endfunction

  // Utility function to convert FP32 bit representation to float
  function automatic real fp32_to_float(logic [31:0] i);
    union {
      real f;
      logic [31:0] i;
    } conv;
    conv.i = i;
    return conv.f;
  endfunction

  function automatic real logic_to_real(input logic [31:0] bits);
    real sign, exponent, fraction, result;
    logic [22:0] mantissa;
    logic [7:0] exp;
    
    sign = bits[31] ? -1.0 : 1.0;
    exp = bits[30:23];
    mantissa = bits[22:0];
    
    if (exp == 0) begin
        // Denormalized number
        if (mantissa != 0) begin
            exponent = -126.0;
            fraction = mantissa / (2.0 ** 23);
        end else begin
            // Zero
            return sign * 0.0;
        end
    end else if (exp == 8'hFF) begin
        // Infinity or NaN
        if (mantissa == 0)
            return sign * 1.0 / 0.0; // Infinity
        else
            return 0.0 / 0.0; // NaN
    end else begin
        // Normalized number
        exponent = exp - 127.0;
        fraction = 1.0 + (mantissa / (2.0 ** 23));
    end
    
    result = sign * fraction * (2.0 ** exponent);
    return result;
  endfunction

  function automatic int count_leading_zeros(logic [33:0] value);
    int count = 0;
    for (int i = 33; i >= 0; i--) begin
      if (value[i] == 1'b0)
        count++;
      else
        break;
    end
    return count;
  endfunction

  function automatic logic [31:0] int34_to_float32_ref(logic [33:0] int34);
  logic sign;
  logic [7:0] exponent;
  logic [22:0] mantissa;
  logic [33:0] abs_value;
  int leading_zeros, shift_amount;

  sign = int34[33];
  abs_value = sign ? (~int34 + 1'b1) : int34;

  if (abs_value == 0) begin
    return 32'h0;
  end

  leading_zeros = count_leading_zeros(abs_value);
  shift_amount = 33 - leading_zeros;
  exponent = 8'd160 - leading_zeros;

  if (shift_amount <= 23) begin
    mantissa = abs_value << (23 - shift_amount);
  end else begin
    logic [33:0] rounded_value;
    rounded_value = abs_value + (1 << (shift_amount - 24));
    mantissa = rounded_value >> (shift_amount - 23);
  end

  return {sign, exponent, mantissa[22:0]};
endfunction
  

  // Clock generation
  always #(CLK_PERIOD/2) i_clk = ~i_clk;

  logic signed [9-1:0] input_set [3][64][64];
  logic signed [9-1:0] weight_set[3][64];
  logic [11-1:0] ref_out_input_set [3][64][64];
  logic [11-1:0] ref_out_weight_set[3][64][64];

  logic signed [34-1:0] pre_int_ref_value[3][64],  int_ref_value[64];
  shortreal bias, ref_value[64], temp_psum;

  assign mac_pre_i_instruction.ifm_datatype = MAC_DATATYPE_I9;
  assign mac_pre_i_instruction.wfm_datatype = MAC_DATATYPE_I9;
  assign mac_pre_i_instruction.bias_enable  = 1;
  assign mac_pre_i_instruction.bias_mode    = 0;

  // Test procedure
  initial begin
    // Initialize signals
    i_clk = 1;
    i_reset = 0;
    
    #(CLK_PERIOD*2+1);

    i_reset = 1;

    #(CLK_PERIOD*2+1);


    
    for (int i = 0; i < NUM_RANDOM_TESTS; i++) begin
      // generate test vector
      bias = $random() * 1000.0 / 32'h7FFFFFFF; // gen bias
      //bias = 0;

      for (int j=0; j<3; j++) begin // gen input vector
        for (int k=0; k<64; k++) begin 
          for (int l=0; l<64; l++) begin 
            input_set[j][k][l] = $signed($urandom_range(255 - (-256)) -256);
            //input_set[j][k][l] = 1;
          end
        end
      end

      for (int j=0; j<3; j++) begin // gen weight vector
        for (int k=0; k<64; k++) begin 
          weight_set[j][k] = $signed($urandom_range(255 - (-256)) -256);
          //weight_set[j][k] = 1;
        end
      end

      
      for (int j=0; j<3; j++) begin // gen ref value
        for (int k=0; k<64; k++) begin 
          for (int l=0; l<64; l++) begin 
            ref_out_input_set[j][k][l] = {input_set[j][k][l]==0, input_set[j][k][l][8], input_set[j][k][l]};
            ref_out_weight_set[j][k][l] = {weight_set[j][l]==0, weight_set[j][l][8], weight_set[j][l]};
          end
        end
      end

      #(CLK_PERIOD);

      for (int l=0; l<3; l++) begin // input & weight set
        for (int j=0; j<64; j++) begin
          for (int k=0; k<64; k++) begin
            mac_pre_i_wfm.data[k*9+:9]  = weight_set[l][k];
          end
          if (j==63) mac_pre_i_wfm.is_last = 1;
          else       mac_pre_i_wfm.is_last = 0;
          mac_pre_i_wfm_valid = 1;
          while ( !(mac_pre_o_wfm_ready == 1 && mac_pre_i_wfm_valid == 1) ) begin
            #(CLK_PERIOD);
          end
          #(CLK_PERIOD);
          mac_pre_i_wfm_valid = 0;
        end
        for (int j=0; j<64; j++) begin
          for (int k=0; k<64; k++) begin
            mac_pre_i_ifm.data[k*9+:9] = input_set[l][j][k];
            mac_pre_i_ifm.data_element_valid[k] = 1;
          end
          if (j==63) begin  mac_pre_i_ifm.inter_end = 1; end
          else       begin  mac_pre_i_ifm.inter_end = 0; end
          if (l==2 ) begin  mac_pre_i_ifm.accum_end = 1; end
          else       begin  mac_pre_i_ifm.accum_end = 0; end
          mac_pre_i_ifm_valid = 1;
          while ( !(mac_pre_o_ifm_ready == 1 && mac_pre_i_ifm_valid == 1) ) begin
            #(CLK_PERIOD);
          end
          #(CLK_PERIOD);
          mac_pre_i_ifm_valid = 0;
        end
      end
      mac_pre_i_ifm_valid = 0;
    end


    // End simulation
    #(CLK_PERIOD*10);
    $display("Simulation completed");
  end

  int err_i, err_w;
  logic [64-1:0] err_id_i, err_id_w;
  logic [6-1:0] id_0, id_1, id_2;
  //shortreal real_output, real_output_set[64];
  logic [11-1:0] out_input_set [3][64][64];
  logic [11-1:0] out_weight_set[3][64][64];

  always_comb begin
    for (int i=0; i<64; i++) begin
      err_id_i[i] = ref_out_input_set[id_1][id_0][i] == mac_pre_to_lane_o_ifm.data[11*i+:11];
      err_id_w[i] = ref_out_weight_set[id_1][id_0][i] == mac_pre_to_lane_o_wfm.data[11*i+:11];
    end
  end


  always_ff @(posedge i_clk) begin
    mac_pre_to_lane_i_ifm_ready <= $urandom_range(0,2);
  end
  //assign mac_pre_i_ofm_ready = 1;

  always_ff @(posedge i_clk or negedge i_reset) begin // check output
    if (!i_reset) begin
      err_i <= 0;
      err_w <= 0;
      id_0 <= 0;
      id_1 <= 0;
    end
    else if (mac_pre_to_lane_i_ifm_ready & mac_pre_to_lane_o_ifm_valid & mac_pre_to_lane_o_wfm_valid[0]) begin
      for (int i=0; i<64; i++) begin
        if (mac_pre_to_lane_o_ifm.data_element_valid[i]) begin
          out_input_set[id_1][id_0][i] <= mac_pre_to_lane_o_ifm.data[11*i+:11];
        end
        out_weight_set[id_1][id_0][i] <= mac_pre_to_lane_o_wfm.data[11*i+:11];
      end
      if ((|err_id_i)!=0) begin
        err_i <= err_i+1;
      end
      if ((|err_id_w)!=0) begin
        err_w <= err_w+1;
      end
      
      id_0 <= id_0 +1;
      if (mac_pre_to_lane_o_ifm.inter_end) begin
        id_1 <= id_1 +1;
      end
    end
  end


endmodule
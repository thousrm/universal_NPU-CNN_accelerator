`timescale 1ns/10ps

module tb_mac_lane
import mac_pkg::*;
();

  // Parameters
  parameter CLK_PERIOD = 10;
  parameter NUM_RANDOM_TESTS = 1;

  // Signals
    logic                i_clk                   ;
    logic                i_reset                 ;
    mac_instruction_port mac_lane_config         ;
    logic                mac_lane_o_ifm_ready    ;
    logic                mac_lane_i_ifm_valid    ;
    mac_lane_ifm_port    mac_lane_i_ifm          ;
    logic                mac_lane_i_wfm_valid    ;
    mac_lane_wfm_port    mac_lane_i_wfm          ;
    logic                mac_lane_o_bias_ready   ;
    logic                mac_lane_i_bias_valid   ;
    logic [32-1:0]       mac_lane_i_bias         ;
    logic                mac_lane_i_ofm_ready    ;
    logic                mac_lane_o_ofm_valid    ;
    mac_lane_ofm_port    mac_lane_o_ofm          ;
    mac_lane_monitor     mac_lane_o_monitor      ;

  mac_lane dut (.*);

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

  logic signed [34-1:0] pre_int_ref_value[3][64],  int_ref_value[64];
  shortreal bias, ref_value[64];

  assign mac_lane_config.bias_enable = 1;
  assign mac_lane_config.bias_mode = 0;

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

      for (int j=0; j<3; j++) begin // gen input vector
        for (int k=0; k<64; k++) begin 
          for (int l=0; l<64; l++) begin 
            input_set[j][k][l] = $signed($urandom_range(255 - (-256)) -256);
          end
        end
      end

      for (int j=0; j<3; j++) begin // gen weight vector
        for (int k=0; k<64; k++) begin 
          weight_set[j][k] = $signed($urandom_range(255 - (-256)) -256);
        end
      end

      for (int j=0; j<3; j++) begin // gen ref value
        for (int k=0; k<64; k++) begin 
          pre_int_ref_value[j][k] = 0;
          for (int l=0; l<64; l++) begin 
            pre_int_ref_value[j][k] = pre_int_ref_value[j][k] + input_set[j][k][l] * weight_set[j][l];
          end
        end
      end
      for (int j=0; j<64; j++) begin
        int_ref_value[j] = pre_int_ref_value[0][j] + pre_int_ref_value[1][j] + pre_int_ref_value[2][j];
        ref_value[j] = int34_to_float32_ref(int_ref_value[j]);
        ref_value[j] = ref_value[j] + bias;
      end

      mac_lane_i_bias = $shortrealtobits(bias);
      mac_lane_i_bias_valid = 1;
      while ( !(mac_lane_o_bias_ready == 1 && mac_lane_i_bias_valid == 1) ) begin // bias
        #(CLK_PERIOD);
      end
      #(CLK_PERIOD);
      mac_lane_i_bias_valid = 0;
      mac_lane_i_bias = 0;

      #(CLK_PERIOD);

      for (int l=0; l<3; l++) begin // input & weight set
        mac_lane_i_wfm_valid = 1;
        for (int k=0; k<64; k++) begin
          mac_lane_i_wfm.data[k*10+:10]  = {weight_set[l][k]==0, weight_set[l][k]};
        end
        for (int j=0; j<64; j++) begin
          for (int k=0; k<64; k++) begin
            mac_lane_i_ifm.data[k*10+:10] = {input_set[l][j][k]==0, input_set[l][j][k]};
            mac_lane_i_ifm.data_element_valid[k] = 1;
          end
          if (j==63) begin  mac_lane_i_ifm.inter_end = 1; end
          else       begin  mac_lane_i_ifm.inter_end = 0; end
          if (l==2 ) begin  mac_lane_i_ifm.accum_end = 1; end
          else       begin  mac_lane_i_ifm.accum_end = 0; end
          mac_lane_i_ifm_valid = 1;
          while ( !(mac_lane_o_ifm_ready == 1 && mac_lane_i_ifm_valid == 1) ) begin
            #(CLK_PERIOD);
          end
          #(CLK_PERIOD);
        end
      end
    end


    // End simulation
    #(CLK_PERIOD*10);
    $display("Simulation completed");
  end

  int err;
  logic [6-1:0] chk_id;
  shortreal real_output;

  always #(CLK_PERIOD/2) mac_lane_i_ofm_ready = $urandom_range(0,2);


  always_ff @(posedge i_clk or negedge i_reset) begin // check output
    if (!i_reset) begin
      err <= 0;
      chk_id <= 0;
    end
    else if (mac_lane_i_ofm_ready & mac_lane_o_ofm_valid) begin
      if ( !(mac_lane_o_ofm.data - ref_value[chk_id] < 0.001 && ref_value[chk_id] - mac_lane_o_ofm.data < 0.001) ) begin
        err <= err+1;
      end
      chk_id <= chk_id +1;
    end
  end


endmodule
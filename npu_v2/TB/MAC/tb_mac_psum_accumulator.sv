`timescale 1ns/10ps

module tb_mac_psum_accumulator
import mac_pkg::*;
();

  // Parameters
  parameter CLK_PERIOD = 10;
  parameter NUM_RANDOM_TESTS = 100;

  // Signals

  // Instantiate the DUT (Design Under Test)

  logic                i_clk                               ;
  logic                i_reset                             ;
  logic                i_bias_enable                       ;
  logic                i_bias_mode                         ; // 0: normal (same bias in ~64 cycles), 1: change bias in every cycl
  logic                mac_psum_accumulator_o_psum_ready   ;
  logic                mac_psum_accumulator_i_psum_valid   ;
  logic [32    -1:0]   mac_psum_accumulator_i_psum_data    ;
  logic                mac_psum_accumulator_i_inter_end    ;
  logic                mac_psum_accumulator_i_accum_end    ;
  logic                mac_psum_accumulator_o_bias_ready   ;
  logic                mac_psum_accumulator_i_bias_valid   ;
  logic [32    -1:0]   mac_psum_accumulator_i_bias_data    ;
  logic                mac_psum_accumulator_i_output_ready ;
  logic                mac_psum_accumulator_o_output_valid ;
  logic [32    -1:0]   mac_psum_accumulator_o_output_data  ;

  mac_psum_accumulator dut (.*);

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

  // Clock generation
  always #(CLK_PERIOD/2) i_clk = ~i_clk;

  shortreal bias, data_in_0[64], data_in_1[64], expected_out[64];

  assign i_bias_enable = 1;
  assign i_bias_mode = 0;

  // Test procedure
  initial begin
    // Initialize signals
    i_clk = 1;
    i_reset = 0;
    mac_psum_accumulator_i_bias_valid = 0;
    mac_psum_accumulator_i_psum_valid = 0;
    mac_psum_accumulator_i_inter_end = 0;
    mac_psum_accumulator_i_accum_end = 0;
    
    #(CLK_PERIOD*2+1);

    i_reset = 1;

    #(CLK_PERIOD*2+1);


    // Run random tests
    for (int i = 0; i < NUM_RANDOM_TESTS; i++) begin
      bias = $random() * 1000.0 / 32'h7FFFFFFF; // gen bias
      for (int j=0; j<64; j++) begin // gen psum
        data_in_0[j] = $random() * 1000.0 / 32'h7FFFFFFF;
        data_in_1[j] = $random() * 1000.0 / 32'h7FFFFFFF;
        expected_out[j] = data_in_0[j] + data_in_1[j] + bias;
      end

      mac_psum_accumulator_i_bias_data = $shortrealtobits(bias);
      mac_psum_accumulator_i_bias_valid = 1;
      while ( !(mac_psum_accumulator_o_bias_ready == 1 && mac_psum_accumulator_i_bias_valid == 1) ) begin // bias
        #(CLK_PERIOD);
      end
      #(CLK_PERIOD);
      mac_psum_accumulator_i_bias_valid = 0;
      mac_psum_accumulator_i_bias_data = 0;

      #(CLK_PERIOD);

      for (int j=0; j<64; j++) begin // input set 0
        mac_psum_accumulator_i_psum_data = $shortrealtobits(data_in_0[j]);
        if (j==63) begin  mac_psum_accumulator_i_inter_end = 1; end
        else       begin  mac_psum_accumulator_i_inter_end = 0; end
        mac_psum_accumulator_i_psum_valid = 1;
        while ( !(mac_psum_accumulator_o_psum_ready == 1 && mac_psum_accumulator_i_psum_valid == 1) ) begin
          #(CLK_PERIOD);
        end
        #(CLK_PERIOD);
      end

      mac_psum_accumulator_i_accum_end = 1;
      for (int j=0; j<64; j++) begin // input set 1
        mac_psum_accumulator_i_psum_data = $shortrealtobits(data_in_1[j]);
        if (j==63) begin  mac_psum_accumulator_i_inter_end = 1; end
        else       begin  mac_psum_accumulator_i_inter_end = 0; end
        mac_psum_accumulator_i_psum_valid = 1;
        while ( !(mac_psum_accumulator_o_psum_ready == 1 && mac_psum_accumulator_i_psum_valid == 1) ) begin
          #(CLK_PERIOD);
        end
        #(CLK_PERIOD);
      end
    end

    // End simulation
    #(CLK_PERIOD*10);
    $display("Simulation completed");
  end

  int err;
  logic [6-1:0] chk_id;
  shortreal real_output;

  assign real_output = logic_to_real(mac_psum_accumulator_o_output_data);
  assign mac_psum_accumulator_i_output_ready = 1;

  always_ff @(posedge i_clk or negedge i_reset) begin // check output
    if (!i_reset) begin
      err <= 0;
      chk_id <= 0;
    end
    else if (mac_psum_accumulator_i_output_ready & mac_psum_accumulator_o_output_valid) begin
      if ( !(real_output - expected_out[chk_id] < 0.001 && expected_out[chk_id] - real_output < 0.001) ) begin
        err <= err+1;
      end
      chk_id <= chk_id +1;
    end
  end


endmodule
`timescale 1ns/10ps

module tb_mac_fp32_converter
import mac_pkg::*;
();

  // Parameters
  parameter CLK_PERIOD = 10;
  parameter NUM_RANDOM_TESTS = 1000;

  // Signals
  logic clk;
  logic [33:0] int34_in;
  logic [31:0] float32_out;
  logic valid_in;
  logic valid_in_d;

  // Instantiate the DUT (Design Under Test)

  mac_datatype i_ifm_datatype;
  mac_datatype i_wfm_datatype;

  assign i_ifm_datatype = MAC_DATATYPE_I9;
  assign i_wfm_datatype = MAC_DATATYPE_I9;

  mac_fp32_converter dut (
    .i_clk         (clk   ),
    .i_ifm_datatype(i_ifm_datatype ),
    .i_wfm_datatype(i_wfm_datatype ),
    .i_exp    (6'd0       ),
    .i_intdata(int34_in   ),
    .i_pipe_en({valid_in_d, valid_in}   ),
    .o_data   (float32_out)
  );

  // Clock generation
  always #(CLK_PERIOD/2) clk = ~clk;

  // Test vector
  typedef struct {
    logic [33:0] int34;
    logic [31:0] expected_float32;
  } test_vector_t;

  test_vector_t test_vectors[4] = {
    '{34'h000000000, 32'h00000000}, // 0
    '{34'h000000001, 32'h3F800000}, // 1
    '{34'h000000002, 32'h40000000}, // 2
    '{34'h3FFFFFFFF, 32'hBF800000}  // -1
  };

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

  logic [31:0] expected_float32;
  logic [ 7:0] ref_exp, exp;
  logic [22:0] ref_mant, mant;

  int err;

  // Test procedure
  initial begin
    // Initialize signals
    clk = 0;
    int34_in = '0;
    valid_in = 0;
    err = 0;

    #(CLK_PERIOD*2+1);

    // Run test vectors
    for (int i = 0; i < $size(test_vectors); i++) begin
      int34_in = test_vectors[i].int34;
      valid_in = 1;
      
      #(CLK_PERIOD);
      valid_in = 0;
      #(CLK_PERIOD);
      
      if (float32_out === test_vectors[i].expected_float32) begin
        $display("Test %0d Passed: Input = %h, Output = %h, Expected = %h", 
                 i, int34_in, float32_out, test_vectors[i].expected_float32);
      end else begin
        $display("Test %0d Failed: Input = %h, Output = %h, Expected = %h", 
                 i, int34_in, float32_out, test_vectors[i].expected_float32);
      end
    end

    // Run random tests
    for (int i = 0; i < NUM_RANDOM_TESTS; i++) begin
      int34_in = $random();
      valid_in = 1;
      
      #(CLK_PERIOD);
      valid_in = 0;
      #(CLK_PERIOD);
      
      expected_float32 = int34_to_float32_ref(int34_in);
      ref_exp  = expected_float32[30:23];
      ref_mant = expected_float32[22:0];
      exp  = float32_out[30:23];
      mant = float32_out[22:0];

      if (float32_out === expected_float32) begin
        $display("Random Test %0d Passed: Input = %h, Output = %h, Expected = %h", 
                 i, int34_in, float32_out, expected_float32);
      end else begin
        $display("Random Test %0d Failed: Input = %h, Output = %h, Expected = %h", 
                 i, int34_in, float32_out, expected_float32);
                err = err+1;
      end
      #(CLK_PERIOD);
      
    end

    // End simulation
    #(CLK_PERIOD*10);
    $display("Simulation completed");
  end

  always_ff @(posedge clk) begin
    valid_in_d <= valid_in;
  end


endmodule
`timescale 1ns / 1ps

module tb_fp32_adder;

  logic        clk;
  logic        rst_n;
  logic [31:0] a, b;
  logic        valid_in;
  logic [31:0] result;
  logic        valid_out;

  // Instantiate the Unit Under Test (UUT)
  fp32_adder uut (
    .clk(clk),
    .rst_n(rst_n),
    .a(a),
    .b(b),
    .valid_in(valid_in),
    .result(result),
    .valid_out(valid_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test case structure
  typedef struct {
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] expected;
    string       description;
  } test_case_t;

  // Test cases
  test_case_t test_cases[] = '{
    '{32'h3F800000, 32'h3F800000, 32'h40000000, "1.0 + 1.0 = 2.0"},
    '{32'h00000000, 32'h3F800000, 32'h3F800000, "0.0 + 1.0 = 1.0"},
    '{32'h80000000, 32'h3F800000, 32'h3F800000, "-0.0 + 1.0 = 1.0"},
    '{32'h3F800000, 32'hBF800000, 32'h00000000, "1.0 + (-1.0) = 0.0"},
    '{32'h7F800000, 32'h3F800000, 32'h7F800000, "Inf + 1.0 = Inf"},
    '{32'h7FC00000, 32'h3F800000, 32'h7FC00000, "NaN + 1.0 = NaN"},
    '{32'h00800000, 32'h00400000, 32'h00C00000, "Subnormal + Subnormal"}
  };

  // Utility function to convert float to FP32 bit representation
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

  shortreal float_a, float_b, expected_result, real_result;
  int error;

  // Test process
  initial begin
    // Initialize signals
    clk = 0;
    rst_n = 0;
    a = 0;
    b = 0;
    valid_in = 0;
    error = 0;

    // Reset
    #10 rst_n = 1;
    #1;

    // Run predefined test cases
    foreach (test_cases[i]) begin
      a = test_cases[i].a;
      b = test_cases[i].b;
      valid_in = 1;
      
      // Wait for 2 clock cycles (2-stage pipeline)
      #10;
      valid_in = 0;
      #10;

      
      if (result === test_cases[i].expected)
        $display("Test Case %0d PASSED: %s", i, test_cases[i].description);
      else
        $display("Test Case %0d FAILED: %s, Expected %h, Got %h", i, test_cases[i].description, test_cases[i].expected, result);
    end

    // Random value tests
    for (int i = 0; i < 1000; i++) begin
      
      // Generate random float values
      float_a = $random() * 1000.0 / 32'h7FFFFFFF;
      float_b = $random() * 1000.0 / 32'h7FFFFFFF;
      valid_in = 1;
      
      a = $shortrealtobits(float_a);
      b = $shortrealtobits(float_b);
      expected_result = float_a + float_b;
      //expected_result = $shortrealtobits(pre_expected_result);
      
      // Wait for 2 clock cycles (2-stage pipeline)
      #10;
      valid_in = 0;
      #10;
      real_result = logic_to_real(result);
      
      if (expected_result - real_result < 0.001 && real_result - expected_result < 0.001)
        $display("Random Test %0d PASSED: %f + %f = %f", i, float_a, float_b, real_result);
      else begin
        error = error+1;
        $display("Random Test %0d FAILED: %f + %f, Expected %f, Got %f", i, float_a, float_b, expected_result, 
                                                                                    real_result);
      end
    end

    // Finish simulation
    $display("error : %d", error);
    #100 $finish;
  end

endmodule
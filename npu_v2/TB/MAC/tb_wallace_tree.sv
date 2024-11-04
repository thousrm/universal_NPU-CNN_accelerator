`timescale 1ns/10ps

module tb_wallace_tree;

  localparam NUM_INPUTS = 16;
  localparam INPUT_WIDTH = 28;
  localparam OUTPUT_WIDTH = 32; 

  logic [27:0] inputs [16];
  logic [31:0] sum;

 logic [28*16-1:0] i_data_array;

  wallace_tree dut (
    .i_data_array(i_data_array),
    .o_data(sum)
  );

  generate
    for (genvar i=0; i<16; i++) begin : input_parsing
      assign i_data_array[i*28+:28] = inputs[i];
    end
endgenerate

  // Test variables
  int test_count, err;
  logic [OUTPUT_WIDTH-1:0] expected_sum;

  // Initialize
  initial begin
    test_count = 0;
    err = 0;
    
    // Run tests
    repeat(1000) begin  // Run 1000 tests
      test_count++;
      
      // Generate input values
      for (int i = 0; i < NUM_INPUTS; i++) begin
        inputs[i] = $urandom & ((1 << INPUT_WIDTH) - 1);  // Generate random 28-bit value
      end
      
      // Calculate expected sum
      expected_sum = '0;
      for (int i = 0; i < NUM_INPUTS; i++) begin
        expected_sum += inputs[i];
      end
      
      // Wait for combinational logic to settle
      #1;
      
      // Check result
      if (sum !== expected_sum) begin
        err = err+1;
        $display("Test %0d failed!", test_count);
        $display("Inputs:");
        for (int i = 0; i < NUM_INPUTS; i++) begin
          $display("  input[%0d] = %0h", i, inputs[i]);
        end
        $display("Expected sum: %0h", expected_sum);
        $display("Actual sum:   %0h", sum);
        $display("");
      end else begin
        $display("Test %0d passed.", test_count);
      end
      
      // Add some delay between tests
      #10;
    end
    
    // End simulation
    $display("Simulation completed. %0d tests run.", test_count);
    //$finish;
  end

endmodule
`timescale 1ns/10ps

module tb_adder_tree;

  localparam NUM_INPUTS = 64;
  localparam INPUT_WIDTH = 32;
  localparam OUTPUT_WIDTH = INPUT_WIDTH+6; 

  logic signed [INPUT_WIDTH-1:0] inputs [NUM_INPUTS];
  logic [OUTPUT_WIDTH-1:0] sum;

  logic [16*28-1:0] big_wallace_tree_input_0, big_wallace_tree_input_1;
  logic [16*28-1:0] mid_wallace_tree_input_0, mid_wallace_tree_input_1;
  logic [32   -1:0] big_wallace_tree_output_0, big_wallace_tree_output_1, mid_wallace_tree_output_0, mid_wallace_tree_output_1;


generate
    for (genvar i=0; i<16; i++) begin : parsing_wallace_tree_input
        assign big_wallace_tree_input_0[i*28+:28] = inputs[i   ][27:0];
        assign big_wallace_tree_input_1[i*28+:28] = inputs[i+16][27:0];
        assign mid_wallace_tree_input_0[i*28+:28] = inputs[i+32][27:0];
        assign mid_wallace_tree_input_1[i*28+:28] = inputs[i+48][27:0];
    end
endgenerate

wallace_tree u_wallace_tree_big_0
    (
        .i_data_array   (big_wallace_tree_input_0   ),
        .o_data         (big_wallace_tree_output_0  )
    );
wallace_tree u_wallace_tree_big_1
    (
        .i_data_array   (big_wallace_tree_input_1   ),
        .o_data         (big_wallace_tree_output_1  )
    );
wallace_tree u_wallace_tree_mid_0
    (
        .i_data_array   (mid_wallace_tree_input_0   ),
        .o_data         (mid_wallace_tree_output_0  )
    );
wallace_tree u_wallace_tree_mid_1
    (
        .i_data_array   (mid_wallace_tree_input_1   ),
        .o_data         (mid_wallace_tree_output_1  )
    );


logic [5 :0] big_sum_sign;
logic [5 :0] mid_sum_sign;
logic [5 :0] big_final_sum_sign;
logic [5 :0] mid_final_sum_sign;

always_comb begin
    big_sum_sign = 0;
    mid_sum_sign = 0;
    for (int i=0; i<32; i++) begin
        big_sum_sign += inputs[i   ][INPUT_WIDTH-1];
        mid_sum_sign += inputs[i+32][INPUT_WIDTH-1];
    end
end

assign big_final_sum_sign = big_sum_sign + (big_sum_sign << 1) + (big_sum_sign << 2) + (big_sum_sign << 3) + (big_sum_sign << 4) +
                            (big_sum_sign << 5);
assign mid_final_sum_sign = mid_sum_sign + (mid_sum_sign << 1) + (mid_sum_sign << 2) + (mid_sum_sign << 3) + (mid_sum_sign << 4) +
                            (mid_sum_sign << 5);

/////////
/// adder tree final output
/////////
logic [33-1:0] big_adder_tree_output;
logic [33-1:0] mid_adder_tree_output;

assign big_adder_tree_output = {1'b0, big_wallace_tree_output_0} + {1'b0, big_wallace_tree_output_1} + {big_final_sum_sign[4:0], 28'd0};
assign mid_adder_tree_output = {1'b0, mid_wallace_tree_output_0} + {1'b0, mid_wallace_tree_output_1} + {mid_final_sum_sign[4:0], 28'd0};

logic [34-1:0] adder_tree_final_output;
assign adder_tree_final_output = {big_adder_tree_output[32], big_adder_tree_output} + {mid_adder_tree_output[32], mid_adder_tree_output};

assign sum = {{(OUTPUT_WIDTH-34){adder_tree_final_output[33]}}, adder_tree_final_output};


  // Test variables
  int test_count, err;
  logic signed [OUTPUT_WIDTH-1:0] expected_sum, debug;
  logic [28-1:0] temp;

  // Initialize
  initial begin
    test_count = 0;
    err = 0;
    
    // Run tests
    repeat(1000) begin  // Run 1000 tests
      test_count++;
      
      // Generate input values
      for (int i = 0; i < NUM_INPUTS; i++) begin
        temp = $urandom & ((1 << 28) - 1);
        inputs[i] = {{(4){temp[27]}}, temp};
      end
      
      // Calculate expected sum
      expected_sum = '0;
      for (int i = 0; i < NUM_INPUTS; i++) begin
        expected_sum += inputs[i];
      end

      // Calculate expected sum
      debug = '0;
      for (int i = 0; i < 32; i++) begin
        debug += inputs[i];
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
`timescale 1ns/10ps

module tb_mac
import mac_pkg::*;
import tx_pkg::*;
();

  // Parameters
  parameter CLK_PERIOD = 10;
  parameter NUM_RANDOM_TESTS = 1;

  // Signals
  logic                        i_clk                   ;
  logic                        i_reset                 ;
  logic                        mac_i_start             ;
  logic                        mac_o_instruction_ready ;
  logic                        mac_i_instruction_valid ;
  tx_mac_instruction_port      mac_i_instruction       ;
  logic                        mac_i_feeder_done       ;
  logic                        mac_i_drainer_done      ;
  logic                        mac_i_tx_done           ;
  logic                        mac_o_ifm_ready         ;
  logic                        mac_i_ifm_valid         ;
  tx_mac_ifm_port              mac_i_ifm               ;
  logic                        mac_o_wfm_ready         ;
  logic                        mac_i_wfm_valid         ;
  tx_mac_wfm_port              mac_i_wfm               ;
  logic                        mac_o_bias_ready        ;
  logic [64-1:0]               mac_i_bias_valid        ;
  tx_mac_bias_port             mac_i_bias              ;
  logic                        mac_i_ofm_ready         ;
  logic                        mac_o_ofm_valid         ;
  tx_mac_ofm_port              mac_o_ofm               ;
  tx_mac_exception_port        mac_o_exceptions        ;

  mac dut (.*);
  
  // Parameters
  localparam INT9_WIDTH = 9;
  localparam SET_SIZE = 64;
  localparam MAX_WEIGHT_SETS = 64;
  localparam FP32_WIDTH = 32;

  // Clock and reset
  logic clk;
  logic rst_n;

  // Inputs
  logic [SET_SIZE-1:0][INT9_WIDTH-1:0] input_data;
  logic input_valid;
  logic input_ready;
  logic [SET_SIZE-1:0][INT9_WIDTH-1:0] weight_data;
  logic weight_valid;
  logic weight_ready;
  logic weight_end;

  // Outputs
  logic [MAX_WEIGHT_SETS-1:0][FP32_WIDTH-1:0] output_data;
  logic output_valid;
  logic output_ready;

  // DUT instantiation
  matrix_multiply dut (
    .clk(clk),
    .rst_n(rst_n),
    .input_data(input_data),
    .input_valid(input_valid),
    .input_ready(input_ready),
    .weight_data(weight_data),
    .weight_valid(weight_valid),
    .weight_ready(weight_ready),
    .weight_end(weight_end),
    .output_data(output_data),
    .output_valid(output_valid),
    .output_ready(output_ready)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test variables
  int num_weight_sets;
  int9 weight_array[MAX_WEIGHT_SETS][SET_SIZE];
  int9 input_set[SET_SIZE];
  int input_count;
  int weight_count;
  int output_count;

  // Initialize test
  initial begin
    clk = 0;
    rst_n = 0;
    input_valid = 0;
    weight_valid = 0;
    weight_end = 0;
    output_ready = 1;

    // Reset
    #20 rst_n = 1;

    // Test case 1: 32 weight sets
    num_weight_sets = 32;
    fork
      load_weights(num_weight_sets);
      send_inputs(100);  // Send 100 input sets
      collect_outputs(100 * num_weight_sets);
    join

    // Test case 2: 64 weight sets (maximum)
    num_weight_sets = 64;
    fork
      load_weights(num_weight_sets);
      send_inputs(50);  // Send 50 input sets
      collect_outputs(50 * num_weight_sets);
    join

    // Wait for all processes to finish
    wait fork;

    $finish;
  end

  // Task to load weight sets
  task automatic load_weights(int num_sets);
    for (int i = 0; i < num_sets; i++) begin
      for (int j = 0; j < SET_SIZE; j++) begin
        weight_array[i][j] = $random;  // Generate random int9 weights
      end
      weight_data = weight_array[i];
      weight_valid = 1;
      weight_end = (i == num_sets - 1);
      @(posedge clk);
      while (!weight_ready) @(posedge clk);
      weight_count++;
    end
    weight_valid = 0;
    weight_end = 0;
  endtask

  // Task to send input sets
  task automatic send_inputs(int num_inputs);
    for (int k = 0; k < num_inputs; k++) begin
      for (int i = 0; i < SET_SIZE; i++) begin
        input_set[i] = $random;  // Generate random int9 inputs
      end
      input_data = input_set;
      input_valid = 1;
      @(posedge clk);
      while (!input_ready) @(posedge clk);
      input_count++;
    end
    input_valid = 0;
  endtask

  // Task to collect and check outputs
  task automatic collect_outputs(int num_outputs);
    for (int i = 0; i < num_outputs; i++) begin
      @(posedge clk);
      while (!output_valid) @(posedge clk);
      // Here you would typically check the output_data against expected results
      // For simplicity, we're just counting the outputs
      output_count++;
      @(posedge clk);
    end
  endtask

  // Monitor process
  initial begin
    forever begin
      @(posedge clk);
      if (input_valid && input_ready)
        $display("Time %0t: Input set received", $time);
      if (weight_valid && weight_ready)
        $display("Time %0t: Weight set received, end = %0d", $time, weight_end);
      if (output_valid && output_ready)
        $display("Time %0t: Output produced", $time);
    end
  end

  // Final check
  final begin
    $display("Test completed:");
    $display("  Inputs processed: %0d", input_count);
    $display("  Weight sets loaded: %0d", weight_count);
    $display("  Outputs produced: %0d", output_count);
    if (input_count * weight_count != output_count)
      $error("Mismatch in input/weight/output counts");
    else
      $display("Counts match as expected");
  end

endmodule

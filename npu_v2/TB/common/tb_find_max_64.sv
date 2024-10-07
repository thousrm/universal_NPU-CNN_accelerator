`timescale 1ns/10ps

module tb_find_max_64;

  parameter DATA_WIDTH = 6;
  parameter NUM_INPUTS = 64;
  
  logic clk;
  logic rst_n;
  logic [DATA_WIDTH-1:0] data_in [NUM_INPUTS];
  logic [DATA_WIDTH-1:0] max_out;
  logic valid_out;

  assign valid_out = 1;

  logic [DATA_WIDTH*NUM_INPUTS-1:0] i_data;

  generate
    for (genvar i=0; i<NUM_INPUTS; i++) begin : packing
        assign i_data[i*DATA_WIDTH+:DATA_WIDTH] = data_in[i];
    end
endgenerate

  find_max_64 #(
    .WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .i_data(i_data),
    .pipe_en(1'b1),
    .result(max_out)
  );
  always #5 clk = ~clk;


  logic [DATA_WIDTH-1:0] bound, expected_max;
  integer err;

  initial begin
    err = 0;
    clk = 0;
    rst_n = 0;
    foreach (data_in[i]) data_in[i] = 0;

    #10 rst_n = 1;

    #1;

    repeat(100) begin
      bound = $urandom_range(0, 2**DATA_WIDTH - 1);
      foreach (data_in[i]) data_in[i] = $urandom_range(0, bound);

      expected_max = data_in[0];
      foreach (data_in[i]) begin
        if (data_in[i] > expected_max) expected_max = data_in[i];
      end

      #10;
      if (valid_out) begin
        if (max_out == expected_max) begin
          $display("Test Passed: Input max = %d, Output = %d", expected_max, max_out);
        end else begin
          $error("Test Failed: Expected %d, Got %d", expected_max, max_out);
          err = err + 1;
        end
      end
    end

  end

  initial begin
    $monitor("Time = %0t: max_out = %d, valid_out = %b", $time, max_out, valid_out);
  end

endmodule
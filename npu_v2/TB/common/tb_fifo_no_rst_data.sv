`timescale 1ns/10ps

module tb_fifo_no_rst_data;

logic i_clk                  ;
logic i_reset                ;

localparam CLK_PERIOD = 10;
localparam STAGE      = 4;
initial begin
    i_clk <= 1;
    i_reset <= 0;

    #(CLK_PERIOD);
    i_reset <= 1;
end
always #(CLK_PERIOD/2) i_clk <= ~i_clk;

localparam WIDTH = 32;
localparam DEPTH = 32;

logic o_input_ready          ;
logic i_input_valid          ;
logic i_output_ready         ;
logic o_output_valid         ;
logic [WIDTH-1:0]    i_input_data    ;
logic [WIDTH-1:0]    o_output_data   ;

fifo_no_rst_data # (.WIDTH(WIDTH), .DEPTH(DEPTH)) u_fifo_no_rst_data (.*);

initial begin
    i_input_valid   = 0;
    i_output_ready  = 0;

    #(CLK_PERIOD*2+1);

    i_input_valid   = 1;
    for (int i=0; i<128; i++) begin
        i_input_data = i;
        #(CLK_PERIOD);
    end

    i_input_valid   = 1;
    i_output_ready  = 1;
    for (int i=0; i<128; i++) begin
        i_input_data = i;
        #(CLK_PERIOD);
    end

    i_input_valid   = 0;
    i_output_ready  = 1;
    for (int i=0; i<128; i++) begin
        i_input_data = i;
        #(CLK_PERIOD);
    end
end

endmodule
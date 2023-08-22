
module tb_ap();

parameter cell_bit = 8;
parameter N_cell = 9;
parameter biasport = 16;
parameter N_core = 8;
parameter outport = 8;

reg [cell_bit*N_cell-1:0] in;
reg [cell_bit*N_cell*N_core-1:0] weight;
reg [biasport*N_core-1:0] bias;
reg [2:0] bound_level;
reg [2:0] step;
reg en, en_relu, en_mp;
reg clk, reset;

wire [outport*N_core-1:0] out;
wire [N_core-1:0] out_en;

always #5 clk <= ~clk;


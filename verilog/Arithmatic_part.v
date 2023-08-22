
module AP(in, weight, bias, bound_level, step, en, en_relu, en_mp, out, out_en, clk, reset);

parameter cell_bit = 8;
parameter N_cell = 9;
parameter biasport = 16;
parameter N_core = 8;
parameter outport = 8;

input [cell_bit*N_cell-1:0] in;
input [cell_bit*N_cell*N_core-1:0] weight;
input [biasport*N_core-1:0] bias;
input [2:0] bound_level;
input [2:0] step;
input en, en_relu, en_mp;
input clk, reset;

output [outport*N_core-1:0] out;
output [N_core-1:0] out_en;

genvar i;
generate
for(i=0; i<N_core; i=i+1) begin : generate_ac
    arithmetic_core ac (in, weight[cell_bit*N_cell*N_core-i*cell_bit*N_cell-1-:cell_bit*N_cell], bias[biasport*N_core-i*biasport-1-:biasport],
                                bound_level, step, en, en_relu, en_mp,
                            out[outport*N_core-i*outport-1-:outport], out_en[N_core-i-1], clk, reset);
end
endgenerate

endmodule

module npu_simple (write_w, write_h, data_in, en_in, readi_w, readi_h, en_read, en_bias, step, en_pe, bound_level, step_p,
                        en_relu, en_mp, 
                        out, out_en, clk, reset);

parameter width = 80;
parameter height = 8;

parameter width_b = 7;
parameter height_b = 3;

input [width_b-1:0]  write_w;
input [height_b-1:0]  write_h;
input [width_b*9-1:0] readi_w;
input [height_b*9-1:0]  readi_h;
input [8*9-1:0] data_in;
input [8:0] en_in, en_read;
input en_bias;
input [2:0] step;
input en_pe;
input [2:0] step_p, bound_level;
input en_relu, en_mp;
input clk, reset;

output [8*8-1:0] out;
output [7:0] out_en;

wire [8*9-1:0] fmaps, fmap;
wire [8*9*8-1:0] weight;
wire [16*8-1:0] biases, biasp;
reg [2:0] step_d, bound_level_d;
reg en_pe_d;



always @(posedge clk) begin
       en_pe_d <= en_pe;
       step_d <= step_p;
       bound_level_d <= bound_level;
end



control_part_simple #(width, height, width_b, height_b) control (en_read, en_bias, fmaps, biases, fmap, biasp, clk);

memory_part #(width, height, width_b, height_b) memory (write_w, write_h, data_in, readi_w, readi_h, step, en_in, fmaps, biases, weight, clk);

AP arithmetic (fmap, weight, biasp, bound_level_d, step_d, en_pe_d, en_relu, en_mp, out, out_en, clk, reset);


//////////////// for debugging
wire [7:0] data_in_each [0:8];

wire [7:0] data_mc [0:8];

wire [7:0] data_cp [0:8];
wire [7:0] weight_group_cp [0:8][0:7];
wire [15:0] bias_cp [0:7];

assign {data_in_each[0], data_in_each[1], data_in_each[2], data_in_each[3], data_in_each[4], data_in_each[5], data_in_each[6], data_in_each[7], data_in_each[8]} = data_in;

assign {data_mc[0], data_mc[1], data_mc[2], data_mc[3], data_mc[4], data_mc[5], data_mc[6], data_mc[7], data_mc[8]} = fmaps;

assign {data_cp[0], data_cp[1], data_cp[2], data_cp[3], data_cp[4], data_cp[5], data_cp[6], data_cp[7], data_cp[8]} = fmap;
assign {weight_group_cp[0][0], weight_group_cp[1][0], weight_group_cp[2][0], weight_group_cp[3][0], weight_group_cp[4][0], weight_group_cp[5][0], 
        weight_group_cp[6][0], weight_group_cp[7][0], weight_group_cp[8][0],
        
        weight_group_cp[0][1], weight_group_cp[1][1], weight_group_cp[2][1], weight_group_cp[3][1], weight_group_cp[4][1], weight_group_cp[5][1], 
        weight_group_cp[6][1], weight_group_cp[7][1], weight_group_cp[8][1],
        
        weight_group_cp[0][2], weight_group_cp[1][2], weight_group_cp[2][2], weight_group_cp[3][2], weight_group_cp[4][2], weight_group_cp[5][2], 
        weight_group_cp[6][2], weight_group_cp[7][2], weight_group_cp[8][2],
        
        weight_group_cp[0][3], weight_group_cp[1][3], weight_group_cp[2][3], weight_group_cp[3][3], weight_group_cp[4][3], weight_group_cp[5][3], 
        weight_group_cp[6][3], weight_group_cp[7][3], weight_group_cp[8][3],
        
        weight_group_cp[0][4], weight_group_cp[1][4], weight_group_cp[2][4], weight_group_cp[3][4], weight_group_cp[4][4], weight_group_cp[5][4], 
        weight_group_cp[6][4], weight_group_cp[7][4], weight_group_cp[8][4],
        
        weight_group_cp[0][5], weight_group_cp[1][5], weight_group_cp[2][5], weight_group_cp[3][5], weight_group_cp[4][5], weight_group_cp[5][5], 
        weight_group_cp[6][5], weight_group_cp[7][5], weight_group_cp[8][5],
        
        weight_group_cp[0][6], weight_group_cp[1][6], weight_group_cp[2][6], weight_group_cp[3][6], weight_group_cp[4][6], weight_group_cp[5][6], 
        weight_group_cp[6][6], weight_group_cp[7][6], weight_group_cp[8][6],
        
        weight_group_cp[0][7], weight_group_cp[1][7], weight_group_cp[2][7], weight_group_cp[3][7], weight_group_cp[4][7], weight_group_cp[5][7], 
        weight_group_cp[6][7], weight_group_cp[7][7], weight_group_cp[8][7]} = weight;

assign {bias_cp[0], bias_cp[1], bias_cp[2], bias_cp[3], bias_cp[4], bias_cp[5], bias_cp[6], bias_cp[7]} = biasp;
///////////////////////////

endmodule
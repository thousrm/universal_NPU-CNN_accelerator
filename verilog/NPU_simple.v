
module npu_simple (write_wr, write_hr, data_in, en_in, readi_wr, readi_hr, en_read, en_bias, stepr, en_pe, bound_levelr, step_pr, out, out_en, clk, reset);

parameter width = 80;
parameter height = 8;

parameter width_b = 7;
parameter height_b = 3;

input [8*9-1:0] data_in;
input [8:0] en_in, en_read;
input en_bias;
input [2:0] stepr;
input en_pe;
input [2:0] step_pr, bound_levelr;
input clk, reset;
input [width_b-1:0]  write_wr;
input [height_b-1:0]  write_hr;
input [width_b*9-1:0] readi_wr;
input [height_b*9-1:0]  readi_hr;

output [7:0] out;
output out_en;


wire [width_b-1:0]  write_w;
wire [height_b-1:0]  write_h;
wire [8*9-1:0] write;

wire [width_b*9-1:0] readi_w;
wire [height_b*9-1:0]  readi_h;
wire [2:0] step;
wire [8:0] en_out;



wire [8*9-1:0] fmaps, fmap;
wire [8*9*8-1:0] weights, weight;
wire [16*8-1:0] biases, biasp;
reg [2:0] step_p, bound_levelp;
reg en_pe_out;



always @(posedge clk) begin
       en_pe_out <= en_pe;
       step_p <= step_pr;
       bound_levelp <= bound_levelr;
end



control_part_simple #(width, height, width_b, height_b) control 
(write_wr, write_hr, data_in, en_in, readi_wr, readi_hr, en_read, en_bias, stepr, en_pe, bound_levelr, step_pr, write_w, write_h, write,
readi_w, readi_h, step, en_out, fmaps, weights, biases, fmap, weight, biasp, en_pe_out, bound_levelp, step_p, clk);

memory_part #(width, height, width_b, height_b) memory
(write_w, write_h, write, readi_w, readi_h, step, en_out, biases, fmaps, weights, clk);

AP arithmetic (fmap, weight, biasp, bound_levelp, step_p, en_pe_out, en_relu, en_mp, out, out_en, clk, reset);


//////////////// for debugging
wire [7:0] data_cm [0:8];
wire [7:0] data_mc [0:8];

wire [7:0] data_cp [0:8];
wire [7:0] weight_group_cp [0:8][0:7];
wire [15:0] bias_cp [0:7];

assign {data_cm[0], data_cm[1], data_cm[2], data_cm[3], data_cm[4], data_cm[5], data_cm[6], data_cm[7], data_cm[8]} = write;
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


module control_part_simple

#(

parameter width = 80,
parameter height = 8,

parameter width_b = 7,
parameter height_b = 3

)

(write_wr, write_hr, data_in, en_in, // from ram
readi_wr, readi_hr, en_read, en_bias, stepr,


write_w, write_h, write, // to mem
readi_w, readi_h,
step, en_out,

fmaps, weights, biases, // from mem

fmap, weight, biasp, // to pe

clk
);

parameter step0 = width - 9;
parameter step1 = width - 18;
parameter step2 = width - 27;
parameter step3 = width - 36;
parameter step4 = width - 45;
parameter step5 = width - 54;

parameter bias = 2;

input [8*9-1:0] data_in;
input [8:0] en_in, en_read;
input en_bias;
input clk;

output [width_b-1:0]  write_wr;
output [height_b-1:0]  write_hr;
output [width_b-1:0]  write_w;
output [height_b-1:0]  write_h;
output [8*9-1:0] write;

output [width_b*9-1:0] readi_wr;
output [height_b*9-1:0]  readi_hr;
output [width_b*9-1:0] readi_w;
output [height_b*9-1:0]  readi_h;

input [2:0] stepr;
output [2:0] step;
output [8:0] en_out;

input [8*9-1:0] fmaps;
output [8*9-1:0] fmap;
input [8*9*8-1:0] weights;
output [8*9*8-1:0] weight;
input [16*8-1:0] biases;
output [16*8-1:0] biasp;


assign write_w = write_wr;
assign write_h = write_hr;
assign readi_w = readi_wr;
assign readi_h = readi_hr;
assign write = data_in;
assign step = stepr;
assign en_out = en_in;

reg [8:0] en_read_d;
reg en_bias_d;

always @(posedge clk) begin
       en_read_d <= en_read;
       en_bias_d <= en_bias;
end


//for zero padding and else
assign fmap[8*9-1-8*0-:8] = en_read_d[8] ? fmaps[8*9-1-8*0-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*1-:8] = en_read_d[7] ? fmaps[8*9-1-8*1-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*2-:8] = en_read_d[6] ? fmaps[8*9-1-8*2-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*3-:8] = en_read_d[5] ? fmaps[8*9-1-8*3-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*4-:8] = en_read_d[4] ? fmaps[8*9-1-8*4-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*5-:8] = en_read_d[3] ? fmaps[8*9-1-8*5-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*6-:8] = en_read_d[2] ? fmaps[8*9-1-8*6-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*7-:8] = en_read_d[1] ? fmaps[8*9-1-8*7-:8] : 8'b0000_0000;
assign fmap[8*9-1-8*8-:8] = en_read_d[0] ? fmaps[8*9-1-8*8-:8] : 8'b0000_0000;

assign weight = weights;

assign biasp = en_bias_d ? biases : 0;



   

endmodule
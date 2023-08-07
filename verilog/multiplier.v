
module multiplier(multiplicand, multiplier,
                        O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0);

input [8*9-1:0] multiplicand, multiplier;
wire signed [8-1:0] md[0:8], mr[0:8];

wire [10:0] pp0[0:8];
wire [8:0] pp1[0:8], pp2[0:8], pp3[0:8];
wire neg0[0:8], neg1[0:8], neg2[0:8], neg3[0:8];

genvar i;
generate
for(i=0; i<9; i=i+1) begin : app
    assign md[i] = multiplicand[8*9-1 - 8*i -: 8];
    assign mr[i] = multiplier[8*9-1 - 8*i -: 8];
    PPG P0(md[i], mr[i], pp0[i],  pp1[i],  pp2[i],  pp3[i], neg0[i], neg1[i], neg2[i], neg3[i]);
end
endgenerate



wire [8:0] pp0_trans[0:11];
wire [8:0] pp1_trans[0:9], pp2_trans[0:9], pp3_trans[0:9];

genvar j;
generate
for(j=0; j<11; j=j+1) begin : transpose_pp0
    assign pp0_trans[j] = {pp0[0][j], pp0[1][j], pp0[2][j], pp0[3][j], pp0[4][j], pp0[5][j], pp0[6][j], pp0[7][j], 
                pp0[8][j]};
end

for(j=0; j<9; j=j+1) begin : transpose_pp123
    assign pp1_trans[j] = {pp1[0][j], pp1[1][j], pp1[2][j], pp1[3][j], pp1[4][j], pp1[5][j], pp1[6][j], pp1[7][j], 
                pp1[8][j]};
    assign pp2_trans[j] = {pp2[0][j], pp2[1][j], pp2[2][j], pp2[3][j], pp2[4][j], pp2[5][j], pp2[6][j], pp2[7][j], 
                pp2[8][j]};
    assign pp3_trans[j] = {pp3[0][j], pp3[1][j], pp3[2][j], pp3[3][j], pp3[4][j], pp3[5][j], pp3[6][j], pp3[7][j], 
                pp3[8][j]};
end

endgenerate

output [8:0] O14, O13;
output [17:0] O12, O11;
output [35:0] O10, O9, O8, O7;
output [44:0] O6;
output [26:0] O5;
output [35:0] O4;
output [17:0] O3;
output [26:0] O2;
output [8:0] O1;
output [17:0] O0;

assign O14 = pp3_trans[8];
assign O13 = pp3_trans[7];
assign O12 = {pp3_trans[6], pp2_trans[8]};
assign O11 = {pp3_trans[5], pp2_trans[7]};
assign O10 = {pp3_trans[4], pp2_trans[6], pp1_trans[8], pp0_trans[10]};
assign O9 = {pp3_trans[3], pp2_trans[5], pp1_trans[7], pp0_trans[9]};
assign O8 = {pp3_trans[2], pp2_trans[4], pp1_trans[6], pp0_trans[8]};
assign O7 = {pp3_trans[1], pp2_trans[3], pp1_trans[5], pp0_trans[7]};
assign O6 = {pp3_trans[0], pp2_trans[2], pp1_trans[4], pp0_trans[6], 
                neg3[0], neg3[1], neg3[2], neg3[3], neg3[4], neg3[5], neg3[6], neg3[7], neg3[8]};
assign O5 = {               pp2_trans[1], pp1_trans[3], pp0_trans[5]};
assign O4 = {               pp2_trans[0], pp1_trans[2], pp0_trans[4],
                neg2[0], neg2[1], neg2[2], neg2[3], neg2[4], neg2[5], neg2[6], neg2[7], neg2[8]};
assign O3 = {                             pp1_trans[1], pp0_trans[3]};
assign O2 = {                             pp1_trans[0], pp0_trans[2],
                neg1[0], neg1[1], neg1[2], neg1[3], neg1[4], neg1[5], neg1[6], neg1[7], neg1[8]};
assign O1 = pp0_trans[1];
assign O0 = {pp0_trans[0], 
                         neg0[0], neg0[1], neg0[2], neg0[3], neg0[4], neg0[5], neg0[6], neg0[7], neg0[8]};


endmodule
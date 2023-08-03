
module multiplier(multiplicand, multiplier,
                        O15, O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0);

input [8*9-1:0] multiplicand, multiplier;
wire signed [8-1:0] md[0:8], mr[0:8];

wire [11:0] pp0[0:8];
wire [9:0] pp1[0:8], pp2[0:8], pp3[0:8];
wire neg0[0:8], neg1[0:8], neg2[0:8], neg3[0:8];

genvar i;
generate
for(i=0; i<9; i=i+1) begin : app
    assign md[i] = multiplicand[8*9-1 - 8*i -: 8];
    assign mr[i] = multiplier[8*9-1 - 8*i -: 8];
    PPG P0(md[i], mr[i], pp0[i],  pp1[i],  pp2[i],  pp3[i], neg0[i], neg1[i], neg2[i], neg3[i]);
end
endgenerate

output [8:0] O15, O14;
output [17:0] O13, O12;
output [35:0] O11, O10, O9, O8, O7;
output [44:0] O6;
output [26:0] O5;
output [35:0] O4;
output [17:0] O3;
output [26:0] O2;
output [8:0] O1;
output [17:0] O0;

assign O15 = {pp3[0][9], pp3[1][9], pp3[2][9], pp3[3][9], pp3[4][9], pp3[5][9], pp3[6][9], pp3[7][9], 
                pp3[8][9]};

assign O14 = {pp3[0][8], pp3[1][8], pp3[2][8], pp3[3][8], pp3[4][8], pp3[5][8], pp3[6][8], pp3[7][8], 
                pp3[8][8]};

assign O13 = {pp3[0][7], pp3[1][7], pp3[2][7], pp3[3][7], pp3[4][7], pp3[5][7], pp3[6][7], pp3[7][7], 
                pp3[8][7],

                pp2[0][9], pp2[1][9], pp2[2][9], pp2[3][9], pp2[4][9], pp2[5][9], pp2[6][9], pp2[7][9], 
                pp2[8][9]};

assign O12 = {pp3[0][6], pp3[1][6], pp3[2][6], pp3[3][6], pp3[4][6], pp3[5][6], pp3[6][6], pp3[7][6], 
                pp3[8][6],
                
                pp2[0][9], pp2[1][9], pp2[2][9], pp2[3][9], pp2[4][9], pp2[5][9], pp2[6][9], pp2[7][9], 
                pp2[8][9]};

endmodule
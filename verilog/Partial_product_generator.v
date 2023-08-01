
module PPG(multiplicand, multiplier, pp0,  pp1,  pp2,  pp3, neg0, neg1, neg2, neg3);

input signed [7:0] multiplicand, multiplier;
wire [2:0] S[0:3];

/// line 0
wire [2:0] S0;
MBE_enc Me0(multiplier[1], multiplier[0], 1'b0, S[0]);
MBE_enc Me1(multiplier[3], multiplier[2], multiplier[1], S[1]);
MBE_enc Me2(multiplier[5], multiplier[4], multiplier[3], S[2]);
MBE_enc Me3(multiplier[7], multiplier[6], multiplier[5], S[3]);

wire [7:0] sign[0:3];

genvar i;
generate
for(i=0; i<4; i=i+1) begin : signa
    assign sign[i] = multiplicand ^ {S[i][2], S[i][2], S[i][2], S[i][2], S[i][2], S[i][2], S[i][2], S[i][2]};
end
endgenerate

wire [8:0] m[0:3];

genvar j;
generate
for(j=0; j<4; j=j+1) begin : multia
    assign m[j] = S[j][0] ? 9'b0_0000_0000 :
                            S[j][1] ? {sign[j][7],sign[j]} : {sign[j], S[j][2]};

end
endgenerate

output [11:0] pp0;
output [9:0] pp1, pp2, pp3;

assign pp0 = {~m[0][8], m[0][8], m[0][8], m[0]};
assign pp1 = {~m[1][8], m[1]};
assign pp2 = {~m[2][8], m[2]};
assign pp3 = {~m[3][8], m[3]};


output neg0, neg1, neg2, neg3;

assign neg0 = (S[0][2]) & (~S[0][0]);
assign neg1 = (S[1][2]) & (~S[1][0]);
assign neg2 = (S[2][2]) & (~S[2][0]);
assign neg3 = (S[3][2]) & (~S[3][0]);

endmodule


module PPG(multiplicand, multiplier, out);

input signed [7:0] multiplicand, multiplier;
input [2:0] S;
output [8:0] out;

/// line 0
wire [2:0] S0;
MBE_enc Me0(multiplier[1], multiplier[0], 1'b0, S0);
MBE_dec Md0(pos, neg, S0, out);


endmodule

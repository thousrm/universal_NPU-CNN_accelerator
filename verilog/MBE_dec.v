

module MBE_dec(pos, neg, S, out);

input [7:0] pos, neg;
input [2:0] S;
output [8:0] out;

wire [8:0] temp0, temp1, temp2;

assign temp0 = S[2] ? {neg, 1'b0} : {pos, 1'b0}; // 2
assign temp1 = S[2] ? {neg[7], neg} : {pos[7], pos}; // 1

assign temp2 = S[1] ? temp1 : temp0;

assign out = S[0] ? 9'b0_0000_0000 : temp2;

/*
assign out[8] = S[0] & temp2[8];
assign out[7] = S[0] & temp2[7];
assign out[6] = S[0] & temp2[6];
assign out[5] = S[0] & temp2[5];
assign out[4] = S[0] & temp2[4];

assign out[3] = S[0] & temp2[3];
assign out[2] = S[0] & temp2[2];
assign out[1] = S[0] & temp2[1];
assign out[0] = S[0] & temp2[0];

*/

endmodule


module MBE_enc(A, B, C, S);

input A, B, C;
output [2:0] S; 
//S[2] = sign, 0 = +, 1 = -
//S[1] = mult, 0 = 2 or 0, 1 = 1
//S[0] = zero, 0 = not 0, 1 = 0

assign S[2] = A;

assign S[1] = B ^ C;

assign S[0] = (A & B & C) | ((~A) & (~B) & (~C));

endmodule
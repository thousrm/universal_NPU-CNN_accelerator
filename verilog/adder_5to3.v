
module adder5_3(x0, x1, x2, x3, x4, cout, carry, sum);

input x0, x1, x2, x3, x4;
output cout, carry, sum;

wire y0, y1, y2, y3;

assign y0 = x4 | x3;
assign y1 = x4 & x3;
assign y2 = x2 | x1;
assign y3 = x2 & x1;

wire sand0, sand1, sxor0;

assign sand0 = y2 & (~y3);
assign sand1 = y0 & (~y1);
assign sxor0 = sand0 ^ sand1;
assign sum = sxor0 ^ x0;

wire mux0;

assign mux0 = sxor0 ? x0 : y3;

wire cor0, cand0;

assign cor0 = y1 | y2;
assign cand0 = y0 & cor0;

assign carry = mux0 ^ cand0;
assign cout = mux0 & cand0;


endmodule

module adder5_3_mod(x0, x1, x2, x3, x4, cout, carry, sum);

input x0, x1, x2, x3, x4;
output cout, carry, sum;

wire y0, y1, y2, y3;

assign y0 = x4 | x3;
assign y1 = x4 & x3;
assign y2 = x2 | x1;
assign y3 = x2 & x1;

wire sxor0, sxor1, sxor2;

assign sxor1 = y2 ^ y3;
assign sxor2 = y0 ^ y1;

assign sxor0 = sxor1 ^ sxor2;
assign sum = sxor0 ^ x0;

wire mux0;

assign mux0 = sxor0 ? x0 : y3;

wire cor0, cand0;

assign cor0 = y1 | y2;
assign cand0 = y0 & cor0;

assign carry = mux0 ^ cand0;
assign cout = mux0 & cand0;


endmodule

module adder5_3_mod2(x1, x2, x3, x4, x5, cout, carry, sum);

input x1, x2, x3, x4, x5;
output cout, carry, sum;

wire and12, xor12, and34, xor34;

assign and12 = x1 & x2;
assign xor12 = x1 ^ x2;
assign and34 = x3 & x4;
assign xor34 = x3 ^ x4;

wire  and3, xor3, and4, xor4;

assign and3 = and12 & and34;
assign xor3 = and12 ^ and34;
assign and4 = xor12 & xor34;
assign xor4 = xor12 ^ xor34;

wire xor5, and6, xor6;

assign xor5 = xor3 ^ and4;
assign and6 = x5 & xor4;
assign xor6 = x5 ^ xor4;

wire and7, xor7, xor8;

assign and7 = xor5 & and6;
assign xor7 = xor5 ^ and6;
assign xor8 = and7 ^ and3;

assign sum = xor6;
assign carry = xor7;
assign cout = xor8;

endmodule
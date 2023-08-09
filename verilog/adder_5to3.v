
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
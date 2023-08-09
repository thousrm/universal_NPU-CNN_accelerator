

module adder6_3(x0, x1, x2, x3, x4, x5, cout, carry, sum);

input x0, x1, x2, x3, x4, x5;
output cout, carry, sum;

wire y0, y1, y2, y3, y4;

assign y0 = x5 | x4;
assign y1 = x5 & x4;
assign y2 = x3 | x2;
assign y3 = x3 & x2;
assign y4 = x1 | x0;
assign y5 = x1 & x0;


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
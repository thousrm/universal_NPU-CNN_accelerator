
module adder_4to3(in, cout, carry, sum);

input [3:0] in;
wire x0, x1, x2, x3;
output cout, carry, sum;

assign {x0, x1, x2, x3} = in;

wire s0, c0, c1;

FA FA0(x0, x1, x2, s0, c0);
HA HA0(x3, s0, sum, c1);
HA HA1(c0, c1, carry, cout);

endmodule



module adder_4to3_mod(in, cout, carry, sum);

input [3:0] in;
wire x0, x1, x2, x3;
output cout, carry, sum;

assign {x0, x1, x2, x3} = in;

wire and12, xor12, and34, xor34;

assign and12 = x0 & x1;
assign xor12 = x0 ^ x1;
assign and34 = x2 & x3;
assign xor34 = x2 ^ x3;

wire  and3, xor3, and4, xor4;

assign and3 = and12 & and34;
assign xor3 = and12 ^ and34;
assign and4 = xor12 & xor34;
assign xor4 = xor12 ^ xor34;

wire xor5;

assign xor5 = xor3 ^ and4;

assign sum = xor4;
assign carry = xor5;
assign cout = and3;

endmodule
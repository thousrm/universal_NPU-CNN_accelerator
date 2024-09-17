

module adder_6to3(in, cout, carry, sum);

input [5:0] in;
wire x1, x2, x3, x4, x5, x6;
output cout, carry, sum;

assign {x1, x2, x3, x4, x5, x6} = in;

wire and12, xor12, and34, xor34, and56, xor56;

assign and12 = x1 & x2;
assign xor12 = x1 ^ x2;
assign and34 = x3 & x4;
assign xor34 = x3 ^ x4;
assign and56 = x5 & x6;
assign xor56 = x5 ^ x6;

wire  and4, xor4, and5, xor5, xor6;

assign and4 = and12 & and34;
assign xor4 = and12 ^ and34;
assign and5 = xor12 & xor34;
assign xor5 = xor12 ^ xor34;
assign xor6 = xor56;

wire xor10, xor7;

assign xor10 = xor4 ^ and5;
assign xor7 = and56;

wire and8, xor8, and9, xor9;

assign and8 = xor5 & xor6;
assign xor8 = xor5 ^ xor6;
assign and9 = xor10 & xor7;
assign xor9 = xor10 ^ xor7;


wire xor12_, and11, xor11, xor13;

assign xor12_ = and9 ^ and11;
assign and11 = xor9 & and8;
assign xor11 = xor9 ^ and8;
assign xor13 = xor12_ ^ and4;

assign sum = xor8;
assign carry = xor11;
assign cout = xor13;

endmodule
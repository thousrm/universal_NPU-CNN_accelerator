


module adder_10to4(in, O3, O2, O1, O0);

input [9:0] in;
wire x0, x1, x2, x3, x4, x5, x6, x7, x8, x9;
output O3, O2, O1, O0;

assign {x0, x1, x2, x3, x4, x5, x6, x7, x8, x9} = in;

wire A[2:0], B[2:0];

adder_5to3 A530({x0, x1, x2, x3, x4}, B[2], B[1], B[0]);
adder_5to3 A531({x5, x6, x7, x8, x9}, A[2], A[1], A[0]);

wire C1, C2;

HA HA0(A[0], B[0], O0, C1);
FA FA0(A[1], B[1], C1, O1, C2);
FA FA1(A[2], B[2], C2, O2, O3);

endmodule
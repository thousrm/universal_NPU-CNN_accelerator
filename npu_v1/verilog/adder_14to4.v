

module adder_14to4(in, O3, O2, O1, O0);

input [13:0] in;
wire x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13;
output O3, O2, O1, O0;

assign {x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13} = in;

wire A[2:0], B[2:0];

adder_7to3 A730({x0, x1, x2, x3, x4, x5, x6}, B[2], B[1], B[0]);
adder_7to3 A731({x7, x8, x9, x10, x11, x12, x13}, A[2], A[1], A[0]);

wire C1, C2;

HA HA0(A[0], B[0], O0, C1);
FA FA0(A[1], B[1], C1, O1, C2);
FA FA1(A[2], B[2], C2, O2, O3);

endmodule

module adder_14to4_mod(in, O3, O2, O1, O0);

input [13:0] in;
wire x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13;
output O3, O2, O1, O0;

assign {x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13} = in;

wire cout[0:6], sum[0:6];

HA H0(x0, x1, sum[0], cout[0]);
HA H1(x2, x3, sum[1], cout[1]);
HA H2(x4, x5, sum[2], cout[2]);
HA H3(x6, x7, sum[3], cout[3]);
HA H4(x8, x9, sum[4], cout[4]);
HA H5(x10, x11, sum[5], cout[5]);
HA H6(x12, x13, sum[6], cout[6]);

wire A[3:1], B[2:0];

//choose from original, mod and mod2
adder_7to3 A730({sum[0], sum[1], sum[2], sum[3], sum[4], sum[5], sum[6]}, B[2], B[1], B[0]);
adder_7to3 A731({cout[0], cout[1], cout[2], cout[3], cout[4], cout[5], cout[6]}, A[3], A[2], A[1]);


assign O0 = B[0];

wire C1, C2;
HA HA0(A[1], B[1], O1, C1);
FA FA5(A[2], B[2], C1, O2, C2);

assign O3 = A[3] ^ C2;

endmodule
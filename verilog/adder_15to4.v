
module adder15_4(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, O3, O2, O1, O0);

input x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14;
output O3, O2, O1, O0;

wire cout[0:4], sum[0:4];

FA F0(x0, x1, x2, sum[0], cout[0]);
FA F1(x3, x4, x5, sum[1], cout[1]);
FA F2(x6, x7, x8, sum[2], cout[2]);
FA F3(x9, x10, x11, sum[3], cout[3]);
FA F4(x12, x13, x14, sum[4], cout[4]);

wire A[3:1], B[2:0];

//choose from original, mod and mod2
adder5_3 A530(sum[0], sum[1], sum[2], sum[3], sum[4], B[2], B[1], B[0]);
adder5_3 A531(cout[0], cout[1], cout[2], cout[3], cout[4], A[3], A[2], A[1]);


assign O0 = B[0];

wire C1, C2;
HA HA0(A[1], B[1], O1, C1);
FA FA5(A[2], B[2], C1, O2, C2);

assign O3 = A[3] ^ C2;

endmodule


module adder15_4_mod(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, O3, O2, O1, O0);

input x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14;
output O3, O2, O1, O0;

wire cout[0:4], sum[0:4];

wire A[2:0], B[2:0];

adder7_3 A730(x0, x1, x2, x3, x4, x5, x6, B[2], B[1], B[0]);
adder7_3 A731(x7, x8, x9, x10, x11, x12, x13, A[2], A[1], A[0]);

wire C1, C2;
FA FA0(A[0], B[0], x14, O0, C1);
FA FA5(A[1], B[1], C1, O1, C2);
FA FA6(A[2], B[2], C2, O2, O3);

endmodule

module adder15_4_mod2(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, O3, O2, O1, O0);

input x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14;
output O3, O2, O1, O0;

wire cout[0:4], sum[0:4];

wire A[2:0], B[2:0], C[2:0];

//choose from original, mod and mod2
adder5_3 A530(x0, x1, x2, x3, x4, A[2], A[1], A[0]);
adder5_3 A531(x5, x6, x7, x8, x9, B[2], B[1], B[0]);
adder5_3 A532(x10, x11, x12, x13, x14, C[2], C[1], C[0]);

wire C1, C2, C2_0, C2_1, O1_0, O1_1, O2_0, O2_1, O3_0, O3_1;
FA FA0(A[0], B[0], C[0],  O0, C1);


/*
FA FA10(A[1], B[1], C[] O1_0, C2_0);
FA FA11(A[1], B[1], O1_1, C2_1);

assign C2 = C1 ? C2_1 : C2_0;
assign O1 = C1 ? O1_1 : O1_0;

FA FA20(1'b0, A[2], B[2], O2_0, O3_0);
FA FA21(1'b1, A[2], B[2], O2_1, O3_1);

assign O2 = C2 ? O2_1 : O2_0;
assign O3 = C2 ? O3_1 : O3_0;
*/
endmodule

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

adder5_3 A530(sum[0], sum[1], sum[2], sum[3], sum[4], B[2], B[1], B[0]);
adder5_3 A531(cout[0], cout[1], cout[2], cout[3], cout[4], A[3], A[2], A[1]);


assign O0 = B[0];

wire C1, C2;
HA HA0(A[1], B[1], O1, C1);
FA FA5(A[2], B[2], C1, O2, C2);

assign O3 = A[3] ^ C2;

endmodule
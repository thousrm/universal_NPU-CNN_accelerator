
module addertree_stage3(x19, x18, x17, x16, x15, x14, x13, x12, x11, x10, x9, x8, x7, x6, x5, x4, x3,
                        o19, o18, o17, o16, o15, o14, o13, o12, o11, o10, o9, o8, o7, o6, o5
                        );


input x19;
input [2:0] x18, x17;
input [3:0] x16, x15, x14, x13, x12, x11, x10, x9, x8, x7;
input [2:0] x6, x5;
input [1:0] x4;
input x3;

wire [1:0] a19, a18, a17;
wire [2:0] a16, a15, a14, a13, a12, a11, a10, a9, a8, a7;
wire [1:0] a6, a5;
wire a4;

// x19
assign a19[0] = x19;

// x18 3
FA A180(x18[0], x18[1], x18[2], a18[0], a19[1]);

// x17 3
FA A170(x17[0], x17[1], x17[2], a17[0], a18[1]);

// x16 3
FA A160(x16[0], x16[1], x16[2], a16[0], a17[1]);

// x15 3
FA A150(x15[0], x15[1], x15[2], a15[0], a16[1]);

// x14 3
FA A140(x14[0], x14[1], x14[2], a14[0], a15[1]);

// x13 3
FA A130(x13[0], x13[1], x13[2], a13[0], a14[1]);

// x12 3
FA A120(x12[0], x12[1], x12[2], a12[0], a13[1]);

// x11 3
FA A110(x11[0], x11[1], x11[2], a11[0], a12[1]);

// x10 3
FA A100(x10[0], x10[1], x10[2], a10[0], a11[1]);

// x9 3
FA A90(x9[0], x9[1], x9[2], a9[0], a10[1]);

// x8 3
FA A80(x8[0], x8[1], x8[2], a8[0], a9[1]);

// x7 3
FA A70(x7[0], x7[1], x7[2], a7[0], a8[1]);

// x6 3
FA A60(x6[0], x6[1], x6[2], a6[0], a7[1]);

// x5 3
FA A50(x5[0], x5[1], x5[2], a5[0], a6[1]);

// x4 2
HA A40(x4[0], x4[1], a4, a5[1]);

assign a16[2] = x16[3];
assign a15[2] = x15[3];
assign a14[2] = x14[3];
assign a13[2] = x13[3];
assign a12[2] = x12[3];
assign a11[2] = x11[3];
assign a10[2] = x10[3];
assign a9[2] = x9[3];
assign a8[2] = x8[3];
assign a7[2] = x7[3];



//stage4

output [1:0] o19, o18, o17, o16, o15, o14, o13, o12, o11, o10, o9, o8, o7, o6;
output o5; 

// a19 2
assign o19[0] = a19[0] ^ a19[1];

// a18 2
HA A181(a18[0], a18[1], o18[0], o19[1]);

// a17 2
HA A171(a17[0], a17[1], o17[0], o18[1]);

// a16 3
FA A161(a16[0], a16[1], a16[2], o16[0], o17[1]);

// a15 3
FA A151(a15[0], a15[1], a15[2], o15[0], o16[1]);

// a14 3
FA A141(a14[0], a14[1], a14[2], o14[0], o15[1]);

// a13 3
FA A131(a13[0], a13[1], a13[2], o13[0], o14[1]);

// a12 3
FA A121(a12[0], a12[1], a12[2], o12[0], o13[1]);

// a11 3
FA A111(a11[0], a11[1], a11[2], o11[0], o12[1]);

// a10 3
FA A101(a10[0], a10[1], a10[2], o10[0], o11[1]);

// a9 3
FA A91(a9[0], a9[1], a9[2], o9[0], o10[1]);

// a8 3
FA A81(a8[0], a8[1], a8[2], o8[0], o9[1]);

// a7 3
FA A71(a7[0], a7[1], a7[2], o7[0], o8[1]);

// a6 2
HA A61(a6[0], a6[1], o6[0], o7[1]);

// a5 2
HA A51(a5[0], a5[1], o5, o6[1]);



endmodule


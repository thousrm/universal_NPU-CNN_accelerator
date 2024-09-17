

module addertree_stage2_mod2(x18, x17, x16, x15, x14, x13, x12, x11, x10, x9, x8, x7, x6, x5, x4, x3,
                        pre_output,
                        o19, o18, o17, o16, o15, o14, o13, o12, o11, o10, o9, o8, o7, o6, o5, o4, o3
                        );

input x18;
input x17;
input [1:0] x16;
input [3:0] x15, x14;
input [6:0] x13;
input [8:0] x12;
input [9:0] x11;
input [10:0] x10;
input [11:0] x9;
input [10:0] x8;
input [9:0] x7;
input [8:0] x6;
input [7:0] x5;
input [7:0] x4;
input [5:0] x3;

input [13:1] pre_output;

wire p19;
output o19;
output [1:0] o18;
output [2:0] o17;
output [3:0] o16, o15, o14, o13, o12, o11, o10, o9, o8, o7;
output [2:0] o6, o5;
output [1:0] o4;
output o3;

// x19
assign o19 = ~(p19 ^ pre_output[13]);

// x18 2 - 2
HA A180(x18,           pre_output[13],             o18[0], p19);

// x17 2 - 2
HA A170(x17,           pre_output[12],                  o17[0], o18[1]);

// x16 3 - 3
FA A160(x16[0], x16[1],  pre_output[11],                o16[0], o17[1]);

// x15 5 - 5
adder_5to3 A150({x15,  pre_output[10]},                         o17[2], o16[1], o15[0]);

// x14 5 - 5
adder_5to3 A140({x14,  pre_output[9]},                                  o16[2], o15[1], o14[0]);

// x13 8 - 8
adder_8to4 A130({x13,  pre_output[8]},                                  o16[3], o15[2], o14[1], o13[0]);

// x12 10 - 10
adder_10to4 A120({x12, pre_output[7]},                                          o15[3], o14[2], o13[1], o12[0]);

// x11 11 - 11
adder_11to4 A110({x11, pre_output[6]},                                                  o14[3], o13[2], o12[1], o11[0]);

// x10 12 - 12
adder_12to4 A100({x10, pre_output[5]},                                                          o13[3], o12[2], o11[1], o10[0]);

// x9 13 - 13
adder_13to4 A90({x9,   pre_output[4]},                                                                  o12[3], o11[2], o10[1], o9[0]);

// x8 12 - 12
adder_12to4 A80({x8,   pre_output[3]},                                                                          o11[3], o10[2], o9[1], o8[0]);

// x7 11 -11
adder_11to4 A70({x7,   pre_output[2]},                                                                                  o10[3], o9[2], o8[1], o7[0]);

// x6 10 - 0
adder_10to4 A60({x6,   pre_output[1]},                                                                                          o9[3], o8[2], o7[1], o6[0]);

// x5 8 - 8
adder_8to4 A50(x5,                                                                                                                     o8[3], o7[2], o6[1], o5[0]);

// x4 8 - 8
adder_8to4 A40(x4,                                                                                                                            o7[3], o6[2], o5[1], o4[0]);

// x3 6 - 6
adder_6to3 A30(x3,                                                                                                                                          o5[2], o4[1], o3);





endmodule


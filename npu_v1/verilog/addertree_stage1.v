
module addertree_stage1(x14, x13, x12, x11, x10, x9, x8, x7, x6, x5, x4, x3, x2, x1, x0, 
                         bias,
                         o18, o17, o16, o15, o14, o13, o12, o11, o10, o9, o8, o7, o6, o5, o4, o3);

input[8:0] x14, x13;
input[17:0] x12, x11;
input[35:0] x10, x9, x8, x7;
input[44:0] x6;
input[26:0] x5;
input[35:0] x4;
input[17:0] x3;
input[26:0] x2;
input[8:0] x1;
input[17:0] x0;
input[15:0] bias;

output o18;
output [1:0] o17;
output [2:0] o16;
output [4:0] o15, o14;
output [6:0] o13;
output [8:0] o12;
output [9:0] o11;
output [10:0] o10;
output [11:0] o9;
output [10:0] o8;
output [9:0] o7;
output [9:0] o6;
output [8:0] o5;
output [7:0] o4;
output [5:0] o3;

wire [3:0] o2;
wire [1:0] o1;
wire o0;


//o18
assign o18 = ~bias[15];

//o17
assign o17[1] = bias[15];

//o16
assign o16[2] = bias[15];

// x14 11 - 11
adder_11to4 A140({x14, bias[14], 1'b1},     o17[0], o16[0], o15[0], o14[0]);

// x13 11 - 11
adder_11to4 A130({x13, bias[13], 1'b1},             o16[1], o15[1], o14[1], o13[0]);

// x12 19 - 15 4
adder_15to4 A120({x12[17:4], bias[12]},                     o15[2], o14[2], o13[1], o12[0]);
adder_4to3 A121(x12[3:0],                                           o14[3], o13[2], o12[1]);

// o15
assign                                                      o15[3] = bias[15];
assign                                                      o15[4] = 1'b1;

// x11 20 - 15 5
adder_15to4 A110({x11[17:5], bias[11], 1'b1},                       o14[4], o13[3], o12[2], o11[0]);
adder_5to3 A111(x11[4:0],                                                   o13[4], o12[3], o11[1]);

// x10 37 - 15 15 7
adder_15to4 A100({x10[35:22], bias[10]},                                    o13[5], o12[4], o11[2], o10[0]);
adder_15to4 A101(x10[21:7],                                                 o13[6], o12[5], o11[3], o10[1]);
adder_7to3 A102(x10[6:0],                                                           o12[6], o11[4], o10[2]);

// x9 37 - 15 15 7
adder_15to4 A90({x9[35:22], bias[9]},                                               o12[7], o11[5], o10[3], o9[0]);
adder_15to4 A91(x9[21:7],                                                           o12[8], o11[6], o10[4], o9[1]);
adder_7to3 A92(x9[6:0],                                                                     o11[7], o10[5], o9[2]);

// x8 37 - 15 15 7
adder_15to4 A80({x8[35:22], bias[8]},                                                       o11[8], o10[6], o9[3], o8[0]);
adder_15to4 A81(x8[21:7],                                                                   o11[9], o10[7], o9[4], o8[1]);
adder_7to3 A82(x8[6:0],                                                                             o10[8], o9[5], o8[2]);

// x7 37 - 15 15 7
adder_15to4 A70({x7[35:22], bias[7]},                                                               o10[9], o9[6], o8[3], o7[0]);
adder_15to4 A71(x7[21:7],                                                                           o10[10],o9[7], o8[4], o7[1]);
adder_7to3 A72(x7[6:0],                                                                                     o9[8], o8[5], o7[2]);

// x6 46 - 15 15 15
adder_15to4 A60(x6[44:30],                                                                                  o9[9], o8[6], o7[3], o6[0]);
adder_15to4 A61(x6[29:15],                                                                                  o9[10],o8[7], o7[4], o6[1]);
adder_15to4 A62(x6[14:0],                                                                                   o9[11],o8[8], o7[5], o6[2]);

// x5 28 - 14 14 or 15 13
adder_14to4 A50({x5[26:14], bias[5]},                                                                              o8[9], o7[6], o6[3], o5[0]);
adder_14to4 A51(x5[13:0],                                                                                          o8[10],o7[7], o6[4], o5[1]);

// x4 37 - 15 15 7
adder_15to4 A40({x4[35:22], bias[4]},                                                                                     o7[8], o6[5], o5[2], o4[0]);
adder_15to4 A41(x4[21:7],                                                                                                 o7[9], o6[6], o5[3], o4[1]);
adder_7to3 A42(x4[6:0],                                                                                                          o6[7], o5[4], o4[2]);

// x3 19 - 15 4
adder_15to4 A30({x3[17:4], bias[3]},                                                                                             o6[8], o5[5], o4[3], o3[0]);
adder_4to3 A31(x3[3:0],                                                                                                                 o5[6], o4[4], o3[1]);

assign                                                                                                                           o6[9] = bias[6];

// x2 28 - 14 14 or 15 13
adder_14to4 A20({x2[26:14], bias[2]},                                                                                                   o5[7], o4[5], o3[2], o2[0]);
adder_14to4 A21(x2[13:0],                                                                                                               o5[8], o4[6], o3[3], o2[1]);

// x1 10 - 10
adder_10to4 A10({x1[8:0], bias[1]},                                                                                                            o4[7], o3[4], o2[2], o1[0]);

// x0 19 - 15
adder_15to4 A00({x0[17:4], bias[0]},                                                                                                                  o3[5], o2[3], o1[1], o0);



endmodule

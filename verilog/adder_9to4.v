
module adder_9to4(in, O3, O2, O1, O0);

input [8:0] in;
wire x0, x1, x2, x3, x4, x5, x6, x7, x8;
output O3, O2, O1, O0;

assign {x0, x1, x2, x3, x4, x5, x6, x7, x8} = in;

wire s00, s01, s10, s11, s2, c0, c1; 

HA HA0(x7, x8, s00, s10);
adder_7to3 A730( {x0, x1, x2, x3, x4, x5, x6}, s2, s11, s01);

HA HA1(s00, s01, O0, c0);
FA FA0(s10, s11, c0, O1, c1);
HA HA2(s2, c1, O2, O3);



endmodule

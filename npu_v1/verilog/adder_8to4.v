
module adder_8to4(in, O3, O2, O1, O0);

input [7:0] in;
wire x0, x1, x2, x3, x4, x5, x6, x7;
output O3, O2, O1, O0;

assign {x0, x1, x2, x3, x4, x5, x6, x7} = in;

wire s00, s01, s10, s11, s2, c0, c1; 

FA FA0(x5, x6, x7, s00, s10);
adder_5to3 A530( {x0, x1, x2, x3, x4}, s2, s11, s01);

HA HA0(s00, s01, O0, c0);
FA FA1(s10, s11, c0, O1, c1);
HA HA1(s2, c1, O2, O3);

endmodule


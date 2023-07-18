
module A_16 (A, B, out);

parameter inport = 16;
parameter outport = 17;

input signed [inport-1:0] A, B;
output signed [outport-1:0] out;
wire signed [inport:0] C;

assign  C = A+B;

assign out = C;
//assign out = C[inport-:2]=='b01 ? 'b0111_1111_1111_1111 : C[inport-:2]=='b10 ? 'b1000_0000_0000_0000 :C[inport-1:0];

endmodule

module A_17 (A, B, out);

parameter inport = 17;
parameter outport = 18;

input signed [inport-1:0] A, B;
output signed [outport-1:0] out;
wire signed [inport:0] C;

assign  C = A+B;

assign out = C;
//assign out = C[inport-:2]=='b01 ? 'b0111_1111_1111_1111 : C[inport-:2]=='b10 ? 'b1000_0000_0000_0000 :C[inport-1:0];

endmodule

module A_18_f (A, B, out);

parameter inport = 18;
parameter outport = 18;

input signed [inport-1:0] A, B;
output signed [outport-1:0] out;
wire signed [inport:0] C;

assign C = A+B;

//assign out = C;
assign  out = C[inport-:2]=='b01 ? 'b01_1111_1111_1111_1111 : C[inport-:2]=='b10 ? 'b10_0000_0000_0000_0000 :C[inport-1:0];

endmodule

module A_8_f (A, B, out);

parameter inport = 8;
parameter outport = 8;

input signed [inport-1:0] A, B;
output signed [outport-1:0] out;
wire signed [inport:0] C;

assign C = A+B;

//assign out = C;
assign  out = C[inport-:2]=='b01 ? 'b01_1111_1111_1111_1111 : C[inport-:2]=='b10 ? 'b10_0000_0000_0000_0000 :C[inport-1:0];

endmodule



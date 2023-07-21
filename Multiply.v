

module M_8 (in, weight, out);

parameter inport = 8;
parameter weiport = 8;
parameter outport = 16;

input signed [inport-1:0] in;
input signed [weiport-1:0] weight;
output signed [outport-1:0] out;

assign  out = in * weight;

endmodule

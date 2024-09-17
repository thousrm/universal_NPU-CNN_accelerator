module relu(in, en_relu, out);

input [7:0] in;
input en_relu;
output [7:0] out;

wire sel;

assign sel = ~(en_relu & in[7]);

assign out[7] = in[7] & sel;
assign out[6] = in[6] & sel;
assign out[5] = in[5] & sel;
assign out[4] = in[4] & sel;
assign out[3] = in[3] & sel;
assign out[2] = in[2] & sel;
assign out[1] = in[1] & sel;
assign out[0] = in[0] & sel;

/* using mux
assign out[7] = sel ? in[7] : 1'b0;
assign out[6] = sel ? in[7] : 1'b0;
assign out[5] = sel ? in[7] : 1'b0;
assign out[4] = sel ? in[7] : 1'b0;
assign out[3] = sel ? in[7] : 1'b0;
assign out[2] = sel ? in[7] : 1'b0;
assign out[1] = sel ? in[7] : 1'b0;
assign out[0] = sel ? in[7] : 1'b0;
*/

endmodule

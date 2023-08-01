
module C53(A, B, C, D, E, O0, O1, O2);

input A, B, C, D, E;
output O0, O1, O2;

wire xor1, xor2, xor3, mux1, mux2;

assign xor1 = A ^ B;
assign xor2 = C ^ D;

assign mux1 = xor1 ? C : A;
assign xor3 = xor1 ^ xor2;

assign mux2 = xor3 ? E : D;
assign O0 = xor3 ^ E;
assign O1 = mux1 ^ mux2;
assign O2 = mux1 & mux2;

endmodule

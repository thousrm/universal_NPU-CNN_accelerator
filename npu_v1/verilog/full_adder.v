
module FA(A, B, Cin, S, Cout);

input A, B, Cin;
output S, Cout;

wire w1, w2, w3;

assign w1 = A ^ B;
assign w2 = w1 & Cin;
assign w3 = A & B;

assign S = w1 ^ Cin;
assign Cout = w2 | w3;

endmodule
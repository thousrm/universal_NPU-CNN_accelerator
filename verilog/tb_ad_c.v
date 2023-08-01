

`timescale 1ns/10ps
module tb_ad_c;

	reg clk, reset;
    reg [4:0] in;
    wire [1:0] FO, FOm;
    wire [2:0] O, Om;

    FA FA0(in[2], in[1], in[0], FO[0], FO[1]);
    C53 C530(in[4], in[3], in[2], in[1], in[0], O[0], O[1], O[2]);
	
    assign FOm = in[2] + in[1] + in[0];
    assign Om = in[4] + in[3] + in[2] + in[1] + in[0];

	initial
	begin
		clk = 1;
        in = 5'b00000;
	end
	
	always #5 clk = ~clk;
    always #10 in = in + 1'b1;






endmodule



`timescale 1ns/10ps
module tb_adder;

	reg clk, reset;

    wire x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14;
    wire O3, O2, O1, O0;
	
	
    adder15_4 A0(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, O3, O2, O1, O0);

    wire OO2, OO1, OO0, OOO2, OOO1, OOO0;
    adder5_3 A1(x10, x11, x12, x13, x14, OO2, OO1, OO0);
    adder5_3_mod A2(x10, x11, x12, x13, x14, OOO2, OOO1, OOO0);

    reg [14:0] in;
    wire [3:0] out, p_out;

    assign {x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14} = in;
    assign out = {O3, O2, O1, O0};
    assign p_out = x0+x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14;

	initial
	begin
    in = 15'b000_0000_0000_0000;		
	end

    integer err = 0, err1 = 0;

    always #10 in = in + 1;
    always begin #9; if (out != p_out) err = err + 1; #1; end
    always begin #9; if ({OO2, OO1, OO0} != {OOO2, OOO1, OOO0}) err1 = err1 + 1; #1; end
	




endmodule

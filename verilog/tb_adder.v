

`timescale 1ns/10ps
module tb_adder;

	reg clk, reset;

    wire x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14;
    wire O3, O2, O1, O0, O3m, O2m, O1m, O0m;
	
	
    adder15_4 A0(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, O3, O2, O1, O0);
    adder15_4_mod A15(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, O3m, O2m, O1m, O0m);

    wire OO2, OO1, OO0, OOO2, OOO1, OOO0, OOOO2, OOOO1, OOOO0, O2_, O1_, O0_, O26, O16, O06;
    adder5_3 A1(x10, x11, x12, x13, x14, OO2, OO1, OO0);
    adder5_3_mod A2(x10, x11, x12, x13, x14, OOO2, OOO1, OOO0);
    adder5_3_mod2 A3(x10, x11, x12, x13, x14, OOOO2, OOOO1, OOOO0);

    adder7_3 A4(x8, x9, x10, x11, x12, x13, x14, O2_, O1_, O0_);

    adder6_3 A5(x9, x10, x11, x12, x13, x14, O26, O16, O06);

    reg [14:0] in;
    wire [3:0] out, outm, p_out;
    wire [2:0] p_out_7, p_out_6;

    assign {x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14} = in;
    assign out = {O3, O2, O1, O0};
    assign outm = {O3m, O2m, O1m, O0m};
    assign p_out = x0+x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14;
    assign p_out_7 = x8+x9+x10+x11+x12+x13+x14;
    assign p_out_6 = x9+x10+x11+x12+x13+x14;

	initial
	begin
    in = 15'b000_0000_0000_0000;		
	end

    integer err = 0, err1 = 0, err7 = 0, err6 = 0;

    always #10 in = in + 1;
    always begin #9; if (out != p_out | outm != p_out) err = err + 1; #1; end
    always begin #9; if ({OO2, OO1, OO0} != {OOO2, OOO1, OOO0} | {OO2, OO1, OO0} != {OOOO2, OOOO1, OOOO0}) err1 = err1 + 1; #1; end
    always begin #9; if ({O2_, O1_, O0_} != p_out_7) err7 = err7 + 1; #1; end
    always begin #9; if ({O26, O16, O06} != p_out_6) err6 = err6 + 1; #1; end
	




endmodule

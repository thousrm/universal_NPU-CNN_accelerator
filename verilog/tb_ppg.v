
`timescale 1ns/10ps
module tb_ppg;

	reg clk, reset;
    reg signed [7:0] multiplicand, multiplier;
    reg [15:0] mat_in[0:127];
    wire [11:0] pp0;
    wire [9:0] pp1, pp2, pp3;
    wire neg0, neg1, neg2, neg3;

    PPG P0(multiplicand, multiplier, pp0,  pp1,  pp2,  pp3, neg0, neg1, neg2, neg3);

	initial
	begin
		clk = 1;
        multiplier = 8'b0000_0000;
        multiplicand = 8'b0000_0000;
	end
	
	always #5 clk = ~clk;

    wire [16:0] O, Om;

    assign Om = multiplier * multiplicand;
    assign O = pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                    17'b1_0101_0000_0000_0000;


    integer err = 0, i = 0;
    initial
	begin		
		$readmemh("input_ppg.txt", mat_in);
        #10
		begin
			for (i=0; i<128; i=i+1)
			begin
				{multiplier, multiplicand} = mat_in[i];
                #(1);
                if (O != Om) err = err + 1;
				#(9);
			end
		end
	end





endmodule


`timescale 1ns/10ps
module tb_ppg;

	reg clk, reset;
    reg signed [7:0] multiplicand, multiplier;
    reg [15:0] mat_in[0:140];
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

    wire [18:0] Ob;
    wire [16:0] O, Om;
    wire [18:0] O10;
    wire signed [18:0] O10m;

    assign Om = multiplier * multiplicand;
    assign Ob = pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                    19'b111_0101_0000_0000_0000;
    assign O = Ob[16:0];
    assign O10 = pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 

                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                pp0 + (pp1<<2) + (pp2<<4) + (pp3<<6) + (neg0) + (neg1<<2) + (neg2<<4) + (neg3<<6) + 
                19'b001_1101_0000_0000_0000;
    assign O10m = multiplier * multiplicand * 9;


    integer err = 0, i = 0, j = 0, err10 = 0;
    initial
	begin		
		$readmemh("input_ppg.txt", mat_in);
        #10
		begin
			for (i=0; i<20; i=i+1)
			begin
				{multiplier, multiplicand} = mat_in[i];
                #(1);
                if (O != Om) err = err + 1;
				#(9);
			end
		end
        i = 0;
        multiplicand = 8'b1111_1111;
        multiplier = 8'b1111_1111;

        begin
			for (i=0; i<256; i=i+1)
			begin
                multiplier = multiplier + 1;
                for (j=0; j<256; j=j+1)
                begin
                    multiplicand = multiplicand + 1;
                    #(1);
                    if (O != Om) err = err + 1;
                    if (O10 != O10m) err10 = err10 + 1;
                    #(9);
                end
			end
		end

	end





endmodule

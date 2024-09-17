


`timescale 1ns/10ps
module tb_relu;

	reg clk, reset;

    reg [8-1:0] mat_in [0:59];
    reg [8-1:0] mat_out [0:63];

    reg [8-1:0] p_out;
	

	reg [8-1:0] in;
	wire [8-1:0] out;
	reg en, en_mp;
	wire out_en;

	relu r0(in, en, out);

	
	initial
	begin
		clk = 1;
		reset = 0;
		en = 0;
		#12
		reset = 1;
		#8
		en = 1;

		#100
		en = 0;

		#100
		en = 1;

		#100
		en = 0;

	end
	
	always #5 clk = ~clk;
	
    integer i=0, j=0;

	initial
	begin		
		$readmemh("input_mp.txt", mat_in);
		begin
			#(20);
			for (i=0; i<60; i=i+1)
			begin
				in = mat_in[i];

				#(10);
			end
		end
	end

	/*
	integer err = 0;
	initial
	begin		
		$readmemh("output_pe.txt", mat_out);
		begin
			#(40); //change if needed
			for (j=0; j<64; j=j+1)
			begin
                p_out = mat_out[j];
                #(9);
				if (out != p_out) err = err + 1;
				#(1);
			end
		end
	end

*/



endmodule

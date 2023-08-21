
`timescale 1ns/10ps
module tb_ad_mul;

	reg clk, reset;

    reg [8*9-1:0] mat_in [0:63];
	reg [8-1:0] ina[0:8];
	reg [8-1:0] weight[0:8];
    reg [8-1:0] mat_out [0:63];
	//reg [32-1:0] mata_in [0:27];
	//reg [16-1:0] mata_out [0:27];
	//reg [8-1:0] A, B;
	//reg [16-1:0] Aa, Ab;

    //wire [17-1:0] outa;
	//wire [16-1:0] out;
    reg [8-1:0] p_out;
	
	
	//M_8 M0 (A, B, out);
	//A_16 A0 (Aa, Ab, outa);
	reg [8*9-1:0] in;
	wire [8*9-1:0] weightin;
	reg [16-1:0] bias;
	wire [8-1:0] out;
	reg en;
	wire out_en;
	
	assign {ina[0], ina[1], ina[2], ina[3], ina[4], ina[5], ina[6], ina[7], ina[8]} = in;

	assign weightin = {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], weight[8]}; 

	//module PE(in, weight, bias, bound_level, step, en, out, out_en, clk, reset);
	PE P0(in, weightin, 16'b0000_0000_0000_0000, 2'b0, 3'b000, en, out, out_en, clk, reset);
	
	initial
	begin
		clk = 1;
		reset = 0;
		en = 0;
		#12
		reset = 1;
	end
	
	always #5 clk = ~clk;
	
    integer i=0, j=0;

	initial
	begin		
		$readmemh("input_pe.txt", mat_in);
		$readmemh("input_pe_wi.txt", weight);
		begin
			#(20);
			for (i=0; i<64; i=i+1)
			begin
				in = mat_in[i];
				en = 1;
				#(10);
			end
		end
	end

	
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





endmodule

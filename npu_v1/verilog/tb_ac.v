

`timescale 1ns/10ps
module tb_ac;

	reg clk, reset;

    reg [8*9-1:0] mat_in [0:63];
	reg signed [8-1:0] ina[0:8];
	reg signed [8-1:0] weight[0:8];
    reg signed [8-1:0] mat_out [0:63];
	//reg [32-1:0] mata_in [0:27];
	//reg [16-1:0] mata_out [0:27];
	//reg [8-1:0] A, B;
	//reg [16-1:0] Aa, Ab;

    //wire [17-1:0] outa;
	//wire [16-1:0] out;
	reg signed [8-1:0] p_out;
    //wire signed [8-1:0] p_out_2b;
	//reg signed [8-1:0] p_out, p_out_b;
	wire signed [8-1:0] out;
	
	
	//M_8 M0 (A, B, out);
	//A_16 A0 (Aa, Ab, outa);
	reg [8*9-1:0] in;
	wire [8*9-1:0] weightin;
	
	wire out_en;

    reg signed [16-1:0] bias;
    reg [2:0] bound_level;
    reg [2:0] step;
    reg en, en_relu, en_mp;

	assign {ina[0], ina[1], ina[2], ina[3], ina[4], ina[5], ina[6], ina[7], ina[8]} = in;

	
	assign weightin = {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], weight[8]}; 

	/*
	assign p_out_t = (ina[0] * weight[0] + ina[1] * weight[1] + ina[2] * weight[2] + ina[3] * weight[3] + 
				ina[4] * weight[4] + ina[5] * weight[5] + ina[6] * weight[6] + ina[7] * weight[7] + ina[8] * weight[8] + bias);
	assign p_out_2b = p_out_t >> (11-bound_level);*/

	//module PE(in, weight, bias, bound_level, step, en, out, out_en, clk, reset);
	//PE P0(in, weightin, 16'b0000_0000_0000_0000, 2'b0, 3'b000, en, out, out_en, clk, reset);

    arithmetic_core A0 (in, weightin, bias, bound_level, step, en,
                            en_relu, en_mp, 
                            out, out_en,
                            clk, reset);

	/*arithmetic_core_mod A0 (in, weightin, bias, bound_level, step, en,
                            en_relu, en_mp, 
                            out, out_en,
                            clk, reset);*/

	/*
	always @(posedge clk) begin
		p_out_b <= p_out_2b;
		p_out <= p_out_b;
	end
	*/
	
	initial
	begin
		clk <= 1;
		reset <= 0;
        en_relu <= 0;
        en_mp <= 0;
		en <= 0;
		#12
		reset <= 1;
        #8
        #10
		#1
        bias <= 16'b0000_0000_0000_0000;
        en_relu <= 1;
        en_mp <= 1;
        bound_level <= 3'b000;
        step <= 3'b000;

		#670

		reset <= 0;
		en_mp <= 0;
		#12
		reset <= 1;
		#8

		#670

		reset <= 0;
		step <= 3'b001;
		en_mp <= 1;
		#12
		reset <= 1;
		#8

		#670

		reset <= 0;
		step <= 3'b000;
		en_mp <= 1;
		en_relu <= 0;
		#12
		reset <= 1;
		#8

		#670

		reset <= 0;
		step <= 3'b011;
		en_mp <= 0;
		en_relu <= 0;
		#12
		reset <= 1;
		#8

		#670

		reset <= 0;
		step <= 3'b000;
		en_mp <= 0;
		en_relu <= 0;
		bound_level <= 3'b010;
		#12
		reset <= 1;

		#8

		#670

		reset <= 0;
		step <= 3'b011;
		en_mp <= 0;
		en_relu <= 0;
		bound_level <= 3'b000;
		#12
		reset <= 1;
		
		



	end
	
	always #5 clk <= ~clk;

	
    integer i=0, j=0;

	initial
	begin		
		$readmemh("input_pe.txt", mat_in);
		$readmemh("input_pe_wi.txt", weight);
		begin
			
			#(31);
			for (i=0; i<64; i=i+1)
			begin
				in <= mat_in[i];
				en <= 1;
				#(10);
			end
			en <= 0;

			#30
			#20
			for (i=0; i<64; i=i+1)
			begin
				in <= mat_in[i];
				en <= 1;
				#(10);
			end
			en <= 0;

			#30
			#20
			for (i=0; i<64; i=i+1)
			begin
				in <= mat_in[i];
				en <= 1;
				#(10);
			end
			en <= 0;

			#30
			#20
			for (i=0; i<64; i=i+1)
			begin
				in <= mat_in[i];
				en <= 1;
				#(10);
			end
			en <= 0;

			#30
			#20
			for (i=0; i<64; i=i+1)
			begin
				in <= mat_in[i];
				en <= 1;
				#(10);
			end
			en <= 0;

			#30
			#20
			for (i=0; i<64; i=i+1)
			begin
				in <= mat_in[i];
				en <= 1;
				#(10);
			end
			en <= 0;

			#30
			#20
			for (i=0; i<64; i=i+1)
			begin
				in <= mat_in[i];
				en <= 1;
				#(10);
				en <= 0;
				#(20);
			end
			en <= 0;
		end
	end

	
	integer err = 0, err1 = 0;
	initial
	begin		
		$readmemh("output_ac.txt", mat_out);
		begin
			#(60); //change if needed
			for (j=0; j<16; j=j+1)
			begin
                p_out = mat_out[j]>>>1;
                #(39);
				if (out_en != 1) err = err + 1;
				if (out != p_out) err = err + 1;
				if (out - p_out > 'sd1 | out - p_out < -'sd1) err1 = err1 + 1;
				#(1);
			end
		end

		$readmemh("output_ac1.txt", mat_out);
		begin
			#(50); //change if needed
			for (j=0; j<64; j=j+1)
			begin
                p_out = mat_out[j]>>>1;
                #(9);
				if (out_en != 1) err = err + 1;
				if (out != p_out) err = err + 1;
				if (out - p_out > 'sd1 | out - p_out < -'sd1) err1 = err1 + 1;
				#(1);
			end
		end

		$readmemh("output_ac2.txt", mat_out);
		begin
			#(50); //change if needed
			for (j=0; j<8; j=j+1)
			begin
                p_out = mat_out[j]>>>1;
                #(79);
				if (out_en != 1) err = err + 1;
				if (out != p_out) err = err + 1;
				if (out - p_out > 'sd1 | out - p_out < -'sd1) err1 = err1 + 1;
				#(1);
			end
		end

		$readmemh("output_ac3.txt", mat_out);
		begin
			#(50); //change if needed
			for (j=0; j<16; j=j+1)
			begin
                p_out = mat_out[j]>>>1;
                #(39);
				if (out_en != 1) err = err + 1;
				if (out != p_out) err = err + 1;
				if (out - p_out > 'sd1 | out - p_out < -'sd1) err1 = err1 + 1;
				#(1);
			end
		end

		$readmemh("output_ac4.txt", mat_out);
		begin
			#(50); //change if needed
			for (j=0; j<16; j=j+1)
			begin
                p_out = mat_out[j]>>>1;
                #(39);
				if (out_en != 1) err = err + 1;
				if (out != p_out) err = err + 1;
				if (out - p_out > 'sd1 | out - p_out < -'sd1) err1 = err1 + 1;
				#(1);
			end
		end

		$readmemh("output_ac5.txt", mat_out);
		begin
			#(50); //change if needed
			for (j=0; j<64; j=j+1)
			begin
                p_out = mat_out[j]>>>1;
                #(9);
				if (out_en != 1) err = err + 1;
				if (out != p_out) err = err + 1;
				if (out - p_out > 'sd1 | out - p_out < -'sd1) err1 = err1 + 1;
				#(1);
			end
		end

		$readmemh("output_ac4.txt", mat_out);
		begin
			#(30); //change if needed
			for (j=0; j<16; j=j+1)
			begin
                p_out = mat_out[j]>>>1;
                #(119);
				if (out_en != 1) err = err + 1;
				if (out != p_out) err = err + 1;
				if (out - p_out > 'sd1 | out - p_out < -'sd1) err1 = err1 + 1;
				#(1);
			end
		end
	end





endmodule

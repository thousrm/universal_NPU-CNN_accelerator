
`timescale 1ns/10ps
module tb_npu_simple;

parameter width = 80;
parameter height = 8;

parameter width_b = 7;
parameter height_b = 3;

parameter input_width = 128;
parameter input_height = 128;

parameter step0 = width - 9;
parameter step1 = width - 18;
parameter step2 = width - 27;
parameter step3 = width - 36;
parameter step4 = width - 45;
parameter step5 = width - 54;


reg [8-1:0] mat_in [0:128*128-1];
reg signed [8-1:0] weight [0:8];
reg signed [16-1:0] bias [0:8];
reg [8-1:0] mat_out [0:128*128-1];

reg [width_b-1:0]  write_w;
reg [height_b-1:0]  write_h;
reg [width_b*9-1:0] readi_w;
reg [height_b*9-1:0]  readi_h;
reg [8*9-1:0] data_in;
reg [8:0] en_in, en_read;
reg en_bias;
reg [2:0] step;
reg en_pe;
reg [2:0] step_p, bound_level;
reg en_relu, en_mp;
reg clk, reset;

wire [8*8-1:0] out;
wire [7:0] out_en;

reg [width_b-1:0] readi_w_each[0:8];
reg [height_b-1:0] readi_h_each;

npu_simple npu (write_w, write_h, data_in, en_in, readi_w, readi_h, en_read, en_bias, step, en_pe, bound_level, step_p,
					en_relu, en_mp, 
					out, out_en, clk, reset);

initial
begin
	clk <= 1;
	reset <= 0;
	en_relu <= 0;
	en_mp <= 0;
	en_in <= 9'b0_0000_0000;
	#12
	reset <= 1;

end

always #5 clk <= ~clk;


integer i=0, j=0, k=0, l=0;

//write
initial begin		
	$readmemh("input_npu.txt", mat_in);
	$readmemh("input_npu_wi.txt", weight);
	$readmemh("input_npu_bi.txt", bias);
	
	#(31);

	// write bias
	for (i=0; i<8; i=i+1) begin
		write_w <= width;
		write_h <= i;
		data_in <= {bias[i], {7{8'b0000_0000}}};
		en_in <= 9'b1_1000_0000;
		#(10);
	end

	//write weight
	for (i=0; i<8; i=i+1) begin
		write_w <= step0;
		write_h <= i;
		data_in <= {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], weight[8]};
		en_in <= 9'b1_1111_1111;
		#(10);
	end

	//write input
	for (j=0; j<8; j=j+1) begin
		for (i=0; i<7; i=i+1) begin
			write_w <= i*9;
			write_h <= j;
			data_in <= {mat_in[j+128*9*i], mat_in[j+128*9*i+128*1], mat_in[j+128*9*i+128*2], mat_in[j+128*9*i+128*3], mat_in[j+128*9*i+128*4],
						mat_in[j+128*9*i+128*5], mat_in[j+128*9*i+128*6], mat_in[j+128*9*i+128*7], mat_in[j+128*9*i+128*8]};
			en_in <= 9'b1_1111_1111;
			#(10);
		end
		write_w <= 9*7;
		write_h <= j;
		data_in <= {mat_in[j+128*9*7], mat_in[j+128*9*7+128*1], mat_in[j+128*9*7+128*2], mat_in[j+128*9*7+128*3], mat_in[j+128*9*7+128*4],
					mat_in[j+128*9*7+128*5], mat_in[j+128*9*7+128*6], mat_in[j+128*9*7+128*7], mat_in[j+128*9*7+128*8]};
		en_in <= 9'b1_1111_1110;
		#(10);
	end
	en_in <= 9'b0_0000_0000;
	#(10);

	//check. read memory
	/*
	en_read <= 9'b1_1111_1111;
	en_bias <= 1;
	for (j=0; j<8; j=j+1)
	begin
		for (i=0; i<10; i=i+1)
		begin
			readi_w_each[0] <= i*9;
			readi_w_each[1] <= i*9+1;
			readi_w_each[2] <= i*9+2;
			readi_w_each[3] <= i*9+3;
			readi_w_each[4] <= i*9+4;
			readi_w_each[5] <= i*9+5;
			readi_w_each[6] <= i*9+6;
			readi_w_each[7] <= i*9+7;
			readi_w_each[8] <= i*9+8;

			readi_w <= {readi_w_each[0], readi_w_each[1], readi_w_each[2], readi_w_each[3], readi_w_each[4], 
						readi_w_each[5], readi_w_each[6], readi_w_each[7], readi_w_each[8]};
			readi_h_each <= j;
			readi_h <= {9{readi_h_each}};
			#(10);
		end
	end
	*/


end

// read
initial begin
	#(831);
	#(10);
end





/*
integer err = 0, err1 = 0;
initial
begin		
	$readmemh("output_npu.txt", mat_out);
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
end
*/





endmodule

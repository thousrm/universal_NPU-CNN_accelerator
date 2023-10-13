

`timescale 1ns/10ps

module run_33 #(
parameter write_delay = 31,
parameter read_delay = 881,
parameter input_file = "input.txt",
parameter weight_file = "weight.txt",
parameter bias_file = "bias.txt",
parameter output_file = "output.txt",
parameter input_width = 128,
parameter input_height = 238,
parameter memory_width = 80,
parameter memory_height = 8,
parameter width_b = 7,
parameter height_b = 3,
parameter filter_width = 3,
parameter filter_height = 3,
parameter zero_padding = 1)

(write_w, write_h, data_in, en_in, readwg, readhg, en_read, en_bias, en_pe);

output reg [width_b-1:0]  write_w;
output reg [height_b-1:0]  write_h;
output reg [8*9-1:0] data_in;
output reg [8:0] en_in;

output reg [width_b*9-1:0] readwg;
output reg [height_b*9-1:0] readhg;
output reg [8:0] en_read;
output reg en_bias, en_pe;

parameter step0 = memory_width - 9;
parameter step1 = memory_width - 18;
parameter step2 = memory_width - 27;
parameter step3 = memory_width - 36;
parameter step4 = memory_width - 45;
parameter step5 = memory_width - 54;

integer i=0, j=0, k=0, l=0, w=0, h=0;

reg [8-1:0] mat_in [0:input_width*input_height-1];
reg signed [8-1:0] weight [0:8];
reg signed [16-1:0] bias [0:8];

/*
task writing_33(
output [width_b-1:0]  write_w,
output [height_b-1:0]  write_h,
output reg [8*9-1:0] data_in,
output reg [8:0] en_in);
reg [8-1:0] mat_in [0:input_width*input_height-1];
reg signed [8-1:0] weight [0:8];
reg signed [16-1:0] bias [0:8];
begin
	#(write_delay);
	$readmemh(input_file, mat_in);
	$readmemh(weight_file, weight);
	$readmemh(bias_file, bias);

	// write bias
	for (i=0; i<8; i=i+1)
	begin
		write_w <= memory_width;
		write_h <= i;
		data_in <= {bias[i], {7{8'b0000_0000}}};
		en_in <= 9'b1_1000_0000;
		#(10);
	end

	//write weight
	for (i=0; i<8; i=i+1)
	begin
		write_w <= step0;
		write_h <= i;
		data_in <= {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], weight[8]};
		en_in <= 9'b1_1111_1111;
		#(10);
	end

	//write input
	for (j=0; j<8; j=j+1)
	begin
		for (i=0; i<7; i=i+1)
		begin
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


end
endtask
*/

wire [width_b-1:0] readw [0:8];
wire [height_b-1:0] readh [0:8];

assign readw[0] = en_read[8] ? k + w -1 : 0;
assign readh[0] = en_read[8] ? j + h -1 : 0;
assign readw[1] = en_read[7] ? k + w -0 : 0;
assign readh[1] = en_read[7] ? j + h -1 : 0;
assign readw[2] = en_read[6] ? k + w +1 : 0;
assign readh[2] = en_read[6] ? j + h -1 : 0;
assign readw[3] = en_read[5] ? k + w -1 : 0;
assign readh[3] = en_read[5] ? j + h -0 : 0;
assign readw[4] = en_read[4] ? k + w -0 : 0;
assign readh[4] = en_read[4] ? j + h -0 : 0;
assign readw[5] = en_read[3] ? k + w +1 : 0;
assign readh[5] = en_read[3] ? j + h -0 : 0;
assign readw[6] = en_read[2] ? k + w -1 : 0;
assign readh[6] = en_read[2] ? j + h +1 : 0;
assign readw[7] = en_read[1] ? k + w -0 : 0;
assign readh[7] = en_read[1] ? j + h +1 : 0;
assign readw[8] = en_read[0] ? k + w +1 : 0;
assign readh[8] = en_read[0] ? j + h +1 : 0;

assign readwg = {readw[0], readw[1], readw[2], readw[3], readw[4], readw[5], readw[6], readw[7], readw[8]};
assign readhg = {readh[0], readh[1], readh[2], readh[3], readh[4], readh[5], readh[6], readh[7], readh[8]};


/*
task reading_33(
output reg [width_b*9-1:0] readwg,
output reg [height_b*9-1:0] readhg,
output reg [8:0] en_in,
output reg en_bias
);

reg [width_b-1:0] readw [0:8];
reg [height_b-1:0] readh [0:8];

begin
	#(read_delay);
	if (input_width > memory_width-9) begin
		for ( i=0; i < (input_width/(memory_width-filter_width-filter_width*filter_height+1))-1; i=i+1 ) begin // fmap > right
			for ( j=0; j < input_height; j=j+2 ) begin // mem > under
				for ( k=0; k < memory_width-filter_width-filter_width*filter_height+1; k=k+2 ) begin // mem > right
					for( l=0; l < 4; l=l+1 ) begin // for maxpooling
						if (zero_padding == 1) begin
							if (i==0 && k==0 && j==0 && l==0) begin // top-left
								en_in <= 9'b000011011;
							end
							else if (i==0 && (j==input_height-1 || j==input_height-2) && k==0 && l==1) begin // bottom-left
								en_in <= 9'b011011000;
							end
							else if (j==0 && (l==0 || l==3)) begin // top
								en_in <= 9'b000111111;
							end
							else if (i==0 && k==0 && (l==0 || l==1)) begin // left
								en_in <= 9'b011011011;
							end
							else if ((j==input_height-1 || j==input_height-2) && (l==1 || l==2)) begin // bottom
								en_in <= 9'b011011000;
							end
							else en_in <= 9'b111111111;
						end
						else en_in <= 9'b111111111; // incompleted yet

						if (l==0 || l==1) w <= 0;
						else w <= 1;
						if (l==0 || l==2) h <= 0;
						else h <= 1; 

						readw[0] = en_in[8] ? k + w -1 : 0;
						readh[0] = en_in[8] ? j + h -1 : 0;
						readw[1] = en_in[7] ? k + w -0 : 0;
						readh[1] = en_in[7] ? j + h -1 : 0;
						readw[2] = en_in[6] ? k + w +1 : 0;
						readh[2] = en_in[6] ? j + h -1 : 0;
						readw[3] = en_in[5] ? k + w -1 : 0;
						readh[3] = en_in[5] ? j + h -0 : 0;
						readw[4] = en_in[4] ? k + w -0 : 0;
						readh[4] = en_in[4] ? j + h -0 : 0;
						readw[5] = en_in[3] ? k + w +1 : 0;
						readh[5] = en_in[3] ? j + h -0 : 0;
						readw[6] = en_in[2] ? k + w -1 : 0;
						readh[6] = en_in[2] ? j + h +1 : 0;
						readw[7] = en_in[1] ? k + w -0 : 0;
						readh[7] = en_in[1] ? j + h +1 : 0;
						readw[8] = en_in[0] ? k + w +1 : 0;
						readh[8] = en_in[0] ? j + h +1 : 0;

						readwg = {readw[0], readw[1], readw[2], readw[3], readw[4], readw[5], readw[6], readw[7], readw[8], readw[9]};
						readhg = {readh[0], readh[1], readh[2], readh[3], readh[4], readh[5], readh[6], readh[7], readh[8], readh[9]};
						en_bias <= 1;

						#10;
					end
				end
			end
		end
	end

	// rightest fmap
	for ( j=0; j < input_height; j=j+2 ) begin // mem > under
		for ( k=0; k < input_width - i * (memory_width-filter_width-filter_width*filter_height+1); k=k+2 ) begin // mem > right
			for( l=0; l < 4; l=l+1 ) begin // for maxpooling
				if (zero_padding == 1) begin
					if (k==0 && j==0 && l==0) begin // top-left
						en_in <= 9'b000011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && k==0 && l==1) begin // bottom-left
								en_in <= 9'b011011000;
					end
					if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && j==0 && l==3) begin // top-right
						en_in <= 9'b000011011;
					end
					if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && (j==input_height-1 || j==input_height-2) && l==2) begin // bottom-right
						en_in <= 9'b000011011;
					end
					else if (j==0 && (l==0 || l==3)) begin // top
						en_in <= 9'b000111111;
					end
					else if (k==0 && (l==0 || l==1)) begin // left
						en_in <= 9'b011011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && (l==1 || l==2)) begin // bottom
						en_in <= 9'b011011000;
					end
					else if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && (l==2 || l==3)) begin // right
						en_in <= 9'b011011000;
					end
					else en_in <= 9'b111111111;
				end
				else en_in <= 9'b111111111; // incompleted yet

				if (l==0 || l==1) w <= 0;
				else w <= 1;
				if (l==0 || l==2) h <= 0;
				else h <= 1; 

				readw[0] = en_in[8] ? k + w -1 : 0;
				readh[0] = en_in[8] ? j + h -1 : 0;
				readw[1] = en_in[7] ? k + w -0 : 0;
				readh[1] = en_in[7] ? j + h -1 : 0;
				readw[2] = en_in[6] ? k + w +1 : 0;
				readh[2] = en_in[6] ? j + h -1 : 0;
				readw[3] = en_in[5] ? k + w -1 : 0;
				readh[3] = en_in[5] ? j + h -0 : 0;
				readw[4] = en_in[4] ? k + w -0 : 0;
				readh[4] = en_in[4] ? j + h -0 : 0;
				readw[5] = en_in[3] ? k + w +1 : 0;
				readh[5] = en_in[3] ? j + h -0 : 0;
				readw[6] = en_in[2] ? k + w -1 : 0;
				readh[6] = en_in[2] ? j + h +1 : 0;
				readw[7] = en_in[1] ? k + w -0 : 0;
				readh[7] = en_in[1] ? j + h +1 : 0;
				readw[8] = en_in[0] ? k + w +1 : 0;
				readh[8] = en_in[0] ? j + h +1 : 0;

				readwg = {readw[0], readw[1], readw[2], readw[3], readw[4], readw[5], readw[6], readw[7], readw[8], readw[9]};
				readhg = {readh[0], readh[1], readh[2], readh[3], readh[4], readh[5], readh[6], readh[7], readh[8], readh[9]};
				en_bias <= 1;

				#10;
			end
		end
	end
end
endtask
*/

//write
initial begin
	#(write_delay);
	$readmemh(input_file, mat_in);
	$readmemh(weight_file, weight);
	$readmemh(bias_file, bias);

	// write bias
	for (i=0; i<8; i=i+1)
	begin
		write_w <= memory_width;
		write_h <= i;
		data_in <= {bias[i], {7{8'b0000_0000}}};
		en_in <= 9'b1_1000_0000;
		#(10);
	end

	//write weight
	for (i=0; i<8; i=i+1)
	begin
		write_w <= step0;
		write_h <= i;
		data_in <= {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], weight[8]};
		en_in <= 9'b1_1111_1111;
		#(10);
	end

	//write input
	for (j=0; j<8; j=j+1)
	begin
		for (i=0; i<7; i=i+1)
		begin
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
end


//read
initial begin
	#(read_delay);
	if (input_width > memory_width-9) begin
		for ( i=0; i < (input_width/(memory_width-filter_width-filter_width*filter_height+1)); i=i+1 ) begin // fmap > right
			for ( j=0; j < input_height; j=j+2 ) begin // mem > under
				for ( k=0; k < memory_width-filter_width-filter_width*filter_height+1; k=k+2 ) begin // mem > right
					for( l=0; l < 4; l=l+1 ) begin // for maxpooling
						if (zero_padding == 1) begin
							if (i==0 && k==0 && j==0 && l==0) begin // top-left
								en_read <= 9'b000011011;
							end
							else if (i==0 && (j==input_height-1 || j==input_height-2) && k==0 && l==1) begin // bottom-left
								en_read <= 9'b011011000;
							end
							else if (j==0 && (l==0 || l==3)) begin // top
								en_read <= 9'b000111111;
							end
							else if (i==0 && k==0 && (l==0 || l==1)) begin // left
								en_read <= 9'b011011011;
							end
							else if ((j==input_height-1 || j==input_height-2) && (l==1 || l==2)) begin // bottom
								en_read <= 9'b011011000;
							end
							else en_read <= 9'b111111111;
						end
						else en_read <= 9'b111111111; // incompleted yet

						if (l==0 || l==1) w <= 0;
						else w <= 1;
						if (l==0 || l==3) h <= 0;
						else h <= 1; 

						

						en_bias <= 1;
						en_pe <= 1;

						#10;
					end
				end
			end
		end
	end

	// rightest fmap
	for ( j=0; j < input_height; j=j+2 ) begin // mem > under
		for ( k=0; k < input_width - i * (memory_width-filter_width-filter_width*filter_height+1); k=k+2 ) begin // mem > right
			for( l=0; l < 4; l=l+1 ) begin // for maxpooling
				if (zero_padding == 1) begin
					if (k==0 && j==0 && l==0) begin // top-left
						en_read <= 9'b000011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && k==0 && l==1) begin // bottom-left
								en_read <= 9'b011011000;
					end
					else if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && j==0 && l==3) begin // top-right
						en_read <= 9'b000011011;
					end
					else if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && (j==input_height-1 || j==input_height-2) && l==2) begin // bottom-right
						en_read <= 9'b000011011;
					end
					else if (j==0 && (l==0 || l==3)) begin // top
						en_read <= 9'b000111111;
					end
					else if (k==0 && (l==0 || l==1)) begin // left
						en_read <= 9'b011011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && (l==1 || l==2)) begin // bottom
						en_read <= 9'b011011000;
					end
					else if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && (l==2 || l==3)) begin // right
						en_read <= 9'b011011000;
					end
					else en_read <= 9'b111111111;
				end
				else en_read <= 9'b111111111; // incompleted yet

				if (l==0 || l==1) w <= 0;
				else w <= 1;
				if (l==0 || l==3) h <= 0;
				else h <= 1; 

				en_bias <= 1;
				en_pe <= 1;

				#10;
			end
		end
	end

	en_pe <= 0;

end

endmodule


module run_npu_simple;

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

wire [width_b-1:0]  write_w;
wire [height_b-1:0]  write_h;
wire [width_b*9-1:0] readi_w;
wire [height_b*9-1:0]  readi_h;
wire [8*9-1:0] data_in;
wire [8:0] en_in, en_read;
wire en_bias;
reg [2:0] step;
wire en_pe;
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

always #5 clk <= ~clk;

integer i=0, j=0, k=0;

// for debugging
wire [7:0] out_1;
assign out_1 = out[8*8-1-:8];

initial
begin
	clk <= 1;
	reset <= 0;
	en_relu <= 0;
	en_mp <= 0;
	bound_level <= 3'b011;
	step <= 3'b000;
	step_p <= 3'b000;
	#12
	reset <= 1;

end

run_33 #( .input_file("input_npu.txt"), .weight_file("input_npu_wi.txt"), .bias_file ("input_npu_bi.txt"), .output_file ("output_npu.txt"))
		layer0 (write_w, write_h, data_in, en_in, readi_w, readi_h, en_read, en_bias, en_pe);




/*
//write
initial
begin		
	$readmemh("input_npu.txt", mat_in);
	$readmemh("input_npu_wi.txt", weight);
	$readmemh("input_npu_bi.txt", bias);
	
	#(31);

	// write bias
	for (i=0; i<8; i=i+1)
	begin
		write_w <= width;
		write_h <= i;
		data_in <= {bias[i], {7{8'b0000_0000}}};
		en_in <= 9'b1_1000_0000;
		#(10);
	end

	//write weight
	for (i=0; i<8; i=i+1)
	begin
		write_w <= step0;
		write_h <= i;
		data_in <= {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], weight[8]};
		en_in <= 9'b1_1111_1111;
		#(10);
	end

	//write input
	for (j=0; j<8; j=j+1)
	begin
		for (i=0; i<7; i=i+1)
		begin
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

	//check. read memory
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


end
*/








endmodule

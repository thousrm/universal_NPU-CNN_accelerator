

`timescale 1ns/10ps

module run_33 #(
parameter write_delay = 31,
parameter read_delay = 881,
parameter save_delay = 941, // read_delay + 60
parameter input_file = "input.txt",
parameter weight_file = "weight.txt",
parameter bias_file = "bias.txt",
parameter output_file0 = "output0.txt",
parameter output_file1 = "output1.txt",
parameter output_file2 = "output2.txt",
parameter output_file3 = "output3.txt",
parameter output_file4 = "output4.txt",
parameter output_file5 = "output5.txt",
parameter output_file6 = "output6.txt",
parameter output_file7 = "output7.txt",
parameter input_width = 128,
parameter input_height = 128,
parameter memory_width = 80,
parameter memory_height = 8,
parameter width_b = 7,
parameter height_b = 3,
parameter filter_width = 3,
parameter filter_height = 3,
parameter zero_padding = 1)

(write_w, write_h, data_in, en_in, readwg, readhg, en_read, step, en_bias, en_pe, out, out_en, clk);

output reg [width_b-1:0]  write_w;
output reg [height_b-1:0]  write_h;
output reg [8*9-1:0] data_in;
output reg [8:0] en_in;

output reg [width_b*9-1:0] readwg;
output reg [height_b*9-1:0] readhg;
output reg [8:0] en_read;
output reg en_bias, en_pe;
output reg [2:0] step;

input [8*8-1:0] out;
input [7:0] out_en;
input clk;

parameter step0 = memory_width - 9;
parameter step1 = memory_width - 18;
parameter step2 = memory_width - 27;
parameter step3 = memory_width - 36;
parameter step4 = memory_width - 45;
parameter step5 = memory_width - 54;

integer i=0, j=0, k=0, l=0, w=0, h=0, s=0, i_d, i_2d, i_3d, i_4d, i_5d, i_6d, i_7d, j_d, j_2d, j_3d, j_4d, j_5d, j_6d, j_7d, k_d, k_2d, k_3d, k_4d, k_5d, k_6d, k_7d,
			f0, f1, f2, f3, f4, f5, f6, f7, fw=0, fh=0;

reg [8-1:0] mat_in [0:input_width*input_height-1];
reg signed [8-1:0] weight [0:8];
reg signed [16-1:0] bias [0:8];

wire [width_b-1:0] readw [0:8];
wire [height_b-1:0] readh [0:8];

assign readw[0] = en_read[8] ? k + w -1 : 0;
assign readh[0] = en_read[8] ? (j % input_height) + h -1 : 0;
assign readw[1] = en_read[7] ? k + w -0 : 0;
assign readh[1] = en_read[7] ? (j % input_height) + h -1 : 0;
assign readw[2] = en_read[6] ? k + w +1 : 0;
assign readh[2] = en_read[6] ? (j % input_height) + h -1 : 0;
assign readw[3] = en_read[5] ? k + w -1 : 0;
assign readh[3] = en_read[5] ? (j % input_height) + h -0 : 0;
assign readw[4] = en_read[4] ? k + w -0 : 0;
assign readh[4] = en_read[4] ? (j % input_height) + h -0 : 0;
assign readw[5] = en_read[3] ? k + w +1 : 0;
assign readh[5] = en_read[3] ? (j % input_height) + h -0 : 0;
assign readw[6] = en_read[2] ? k + w -1 : 0;
assign readh[6] = en_read[2] ? (j % input_height) + h +1 : 0;
assign readw[7] = en_read[1] ? k + w -0 : 0;
assign readh[7] = en_read[1] ? (j % input_height) + h +1 : 0;
assign readw[8] = en_read[0] ? k + w +1 : 0;
assign readh[8] = en_read[0] ? (j % input_height) + h +1 : 0;

assign readwg = {readw[0], readw[1], readw[2], readw[3], readw[4], readw[5], readw[6], readw[7], readw[8]};
assign readhg = {readh[0], readh[1], readh[2], readh[3], readh[4], readh[5], readh[6], readh[7], readh[8]};

// for debugging
integer data_in_ck, data_in_w, data_in_h, ck_last_k0;
reg [7:0] data_in_first;
always @(*) begin
	data_in_ck = k? j-2+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+(k_4d+w)*input_height +memory_height
				:	j-4+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)
					+(memory_width-filter_width-filter_width*filter_height+w)*input_height +memory_height;
	data_in_w = data_in_ck/128;
	data_in_h = data_in_ck - 128*data_in_w;
	ck_last_k0 = j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(memory_width-filter_width-filter_width*filter_height+w)*input_height;
	data_in_first = data_in[8*9-1-:8];
end


//write

// first write
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
			data_in <= {mat_in[j+input_height*9*i], mat_in[j+input_height*9*i+input_height*1], mat_in[j+input_height*9*i+input_height*2], mat_in[j+input_height*9*i+input_height*3], mat_in[j+input_height*9*i+input_height*4],
						mat_in[j+input_height*9*i+input_height*5], mat_in[j+input_height*9*i+input_height*6], mat_in[j+input_height*9*i+input_height*7], mat_in[j+input_height*9*i+input_height*8]};
			en_in <= 9'b1_1111_1111;
			#(10);
		end
		write_w <= 9*7;
		write_h <= j;
		data_in <= {mat_in[j+input_height*9*7], mat_in[j+input_height*9*7+input_height*1], mat_in[j+input_height*9*7+input_height*2], mat_in[j+input_height*9*7+input_height*3], mat_in[j+input_height*9*7+input_height*4],
					mat_in[j+input_height*9*7+input_height*5], mat_in[j+input_height*9*7+input_height*6], mat_in[j+input_height*9*7+input_height*7], mat_in[j+input_height*9*7+input_height*8]};
		en_in <= 9'b1_1111_1110;
		#(10);
	end
	en_in <= 9'b0_0000_0000;
end

reg enable_write_reading, rightest, pre_rightest;
//write during reading
always @(*) begin
	if (i == (input_width/(memory_width-filter_width-filter_width*filter_height+1)) -1) pre_rightest =1;
	else pre_rightest =0;
	if (i == (input_width/(memory_width-filter_width-filter_width*filter_height+1))) rightest =1;
	else rightest =0;


	if (enable_write_reading==1) begin
		if ((j==0 || (j==2 && k==1)) && i!=0) begin 
			if (k==1) begin
				write_w = rightest ? input_width - i * (memory_width-filter_width-filter_width*filter_height+1) +w -2 : k_4d + w; 
				write_h = (j % input_height)+4+h; // +4 is correct
				if (l==2 || l==3) begin
					data_in = rightest ?
					{mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(input_width - i * (memory_width-filter_width-filter_width*filter_height+1) -2+w)*input_height], {8{8'b0000_0000}}}
					
					: {mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(k_4d+w)*input_height],
					mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(k_4d+w+1)*input_height], {7{8'b0000_0000}}};
					en_in = rightest ? 9'b1_0000_0000 : 9'b1_1000_0000;
				end
				else begin
					data_in = rightest ?
					{mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(input_width - i * (memory_width-filter_width-filter_width*filter_height+1) -2+w)*input_height], {8{8'b0000_0000}}}
					
					:{mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(k_4d+w)*input_height], {8{8'b0000_0000}}};
					en_in = 9'b1_0000_0000;
				end
			end
			else if (k==3) begin
				write_w = 0 + w; 
				write_h = (j % input_height)+6+h; // +6 is correct
				if (l==0 || l==1) begin
					data_in = {mat_in[j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(0+w)*input_height],
					mat_in[j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(0+w+1)*input_height], {7{8'b0000_0000}}};
					en_in = 9'b1_1000_0000;
				end
				else begin
					data_in = {8'b0000_0000, mat_in[j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(0+w+1)*input_height], {7{8'b0000_0000}}};
					en_in = 9'b0_1000_0000;
				end
			end
			else begin
				write_w = k_4d+w;
				write_h = (j % input_height)+6+h; // +6 is correct
				data_in = {mat_in[j-2+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}}; 	
				en_in = 9'b1_0000_0000;
			end
		end
		else if (j>0) begin
			if (j==2 && (k!=0 || k!=1)) begin
				write_w = k==3 ? k_4d+w-1 : k_4d+w; 
				write_h = (j % input_height)-2+h;
				data_in = k==3 ?
				  {mat_in[j-2+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+(k_4d+w-1)*input_height +memory_height],
				  mat_in[j-2+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+(k_4d+w)*input_height +memory_height], {7{8'b0000_0000}}}
				: {mat_in[j-2+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}};
				en_in = k==3 ? 9'b1_1000_0000 : 9'b1_0000_0000;
			end
			else if (j==2 && k==0) begin
				data_in = {9{8'b0000_0000}};
				en_in = 9'b0_0000_0000;
			end
			else if (j>2) begin
				if (j>input_height-(memory_height-1) && !(j==input_height-(memory_height-2) && (k==0 || k==1))) begin
					if (pre_rightest==1) begin
						if (k==0 || k==1) begin 
							write_w =  input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1)-2 + w; 
							write_h = (j % input_height)-4+h;
							if (l==2 || l==3) begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1)-2+w)*input_height], {8{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1)-2+w)*input_height], {8{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
							end
						end
						else if (k==2 || k==3) begin 
							write_w = 0+w*2; 
							write_h = (j % input_height)-2+h;
							if (l==0 || l==1) begin
								data_in = {mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w)*input_height], mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w+1)*input_height], {7{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1) ?
								  9'b1_1000_0000
								: 9'b0_0000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w+1)*input_height], {8{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
							end
						end
						else begin
							write_w = k_4d+w;
							write_h = (j % input_height)-2+h;
							data_in = k < input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1) ?
							{mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
							+(k_4d+w)*input_height], {8{8'b0000_0000}}}
							:{9{8'b0000_0000}};
							en_in = k < input_width - (i+1) * (memory_width-filter_width-filter_width*filter_height+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
						end
					end									
					else begin
						if (k==0 || k==1) begin
							write_w = k_4d + w; 
							write_h = (j % input_height)-4+h;
							if (l==2 || l==3) begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(k_4d+w)*input_height],
								mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(k_4d+w+1)*input_height], {7{8'b0000_0000}}};
								en_in = 9'b1_1000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(k_4d+w)*input_height], {8{8'b0000_0000}}};
								en_in = 9'b1_0000_0000;
							end
						end
						else if (k==2 || k==3) begin
							write_w = 0+w*2; 
							write_h = (j % input_height)-2+h;
							if (l==0 || l==1) begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w)*input_height],
								mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w+1)*input_height], {7{8'b0000_0000}}};
								en_in = 9'b1_1000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w+1)*input_height], {8{8'b0000_0000}}};
								en_in = 9'b1_0000_0000;
							end
						end
						else begin
							write_w = k_4d+w;
							write_h = (j % input_height)-2+h;
							data_in = {mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-filter_width*filter_height+1)
							+(k_4d+w)*input_height], {8{8'b0000_0000}}};
							en_in = 9'b1_0000_0000;
						end
					end
				end
				else if (k==0 || k==1) begin
						write_w = k_4d + w;
						write_h = (j % input_height)-4+h;
						if (l==2 || l==3) begin
							data_in = {mat_in[j-4+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)
							+(k_4d+w)*input_height +memory_height],
							mat_in[j-4+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)
							+(k_4d+w+1)*input_height +memory_height], {7{8'b0000_0000}}};
							en_in = 9'b1_1000_0000;
						end
						else begin
							data_in = {mat_in[j-4+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)
							+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}};
							en_in = 9'b1_0000_0000;
					end 	
				end
				else if (k==3) begin
							write_w = 0+w*2; 
							write_h = (j % input_height)-2+h;
							if (l==0 || l==1) begin
								data_in = {mat_in[j-2+h+input_height*(i)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w)*input_height +memory_height],
								mat_in[j-2+h+input_height*(i)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w+1)*input_height +memory_height], {7{8'b0000_0000}}};
								en_in = 9'b1_1000_0000;
							end
							else begin
								data_in = {mat_in[j-2+h+input_height*(i)*(memory_width-filter_width-filter_width*filter_height+1)
								+(w+1)*input_height +memory_height], {8{8'b0000_0000}}};
								en_in = 9'b1_0000_0000;
							end
						end
				else begin
					write_w = k_4d+w;
					write_h = (j % input_height)-2+h;
					data_in = {mat_in[j-2+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}}; 		
					en_in = 9'b1_0000_0000;		
				end
				
			end
		end
	end
	else begin
		write_w = 0;
		write_h = 0;
		data_in = {9{8'b0000_0000}};
		en_in = 9'b0_0000_0000;
	end
end



//read
initial begin
	enable_write_reading <= 0;
	#(read_delay);
	if (input_width > memory_width-9) begin
		for ( i=0; i < (input_width/(memory_width-filter_width-filter_width*filter_height+1)); i=i+1 ) begin // fmap > right  
			for ( j=0; j < input_height; j=j+2 ) begin // mem > under
				for ( k= i==0 ? 0 : 1; k < memory_width-filter_width-filter_width*filter_height+1; k=k+2 ) begin // mem > right
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
								en_read <= 9'b111111000;
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
						step <= 3'b000;

						// write_reading start
						enable_write_reading <= 1;
						

						#10;
					end
				end
			end
		end
	end

	// rightest fmap
	for ( j=0; j < input_height; j=j+2 ) begin // mem > under
		for ( k= i==0 ? 0 : 1; k < input_width - i * (memory_width-filter_width-filter_width*filter_height+1); k=k+2 ) begin // mem > right		k=1 is correct
			for( l=0; l < 4; l=l+1 ) begin // for maxpooling
				if (zero_padding == 1) begin
					if (k==0 && j==0 && l==0) begin // top-left
						en_read <= 9'b000011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && k==0 && l==1) begin // bottom-left
								en_read <= 9'b011011000;
					end
					else if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && j==0 && l==3) begin // top-right
						en_read <= 9'b000110110;
					end
					else if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && (j==input_height-1 || j==input_height-2) && l==2) begin // bottom-right
						en_read <= 9'b110110000;
					end
					else if (j==0 && (l==0 || l==3)) begin // top
						en_read <= 9'b000111111;
					end
					else if (k==0 && (l==0 || l==1)) begin // left
						en_read <= 9'b011011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && (l==1 || l==2)) begin // bottom
						en_read <= 9'b111111000;
					end
					else if (k > input_width - i * (memory_width-filter_width-filter_width*filter_height+1)-3 && (l==2 || l==3)) begin // right
						en_read <= 9'b110110110;
					end
					else en_read <= 9'b111111111;
				end
				else en_read <= 9'b111111111; // incompleted yet

				if (l==0 || l==1) w <= 0;
				else w <= 1;
				if (l==0 || l==3) h <= 0;
				else h <= 1; 

				step <= 3'b000;
				en_bias <= 1;
				en_pe <= 1;

				// write_reading start
				enable_write_reading <= 1;

				#10;
			end
		end
	end

	en_pe <= 0;

end


// save output

reg start_save;
reg [7:0] out_save[0:7][0:(input_width/2)-1][0:(input_height/2)-1];

initial begin
	#(save_delay);
	start_save <= 1;
end

always @(posedge clk) begin
	i_d <= i;
	i_2d <= i_d;
	i_3d <= i_2d;
	i_4d <= i_3d;
	i_5d <= i_4d;
	i_6d <= i_5d;
	i_7d <= i_6d;

	j_d <= j;
	j_2d <= j_d;
	j_3d <= j_2d;
	j_4d <= j_3d;
	j_5d <= j_4d;
	j_6d <= j_5d;
	j_7d <= j_6d;

	k_d <= k;
	k_2d <= k_d;
	k_3d <= k_2d;
	k_4d <= k_3d;
	k_5d <= k_4d;
	k_6d <= k_5d;
	k_7d <= k_6d;

end

always @(posedge clk) begin
	if (out_en[7]==1 && start_save ==1 && s < (input_width/2) * (input_height/2)) begin
		out_save[0][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+(k_7d/2) + (k_7d % 2)][j_7d/2] <= out[8*8-1-8*0-:8];
		out_save[1][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+k_7d/2][j_7d/2] <= out[8*8-1-8*1-:8];
		out_save[2][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+k_7d/2][j_7d/2] <= out[8*8-1-8*2-:8];
		out_save[3][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+k_7d/2][j_7d/2] <= out[8*8-1-8*3-:8];
		out_save[4][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+k_7d/2][j_7d/2] <= out[8*8-1-8*4-:8];
		out_save[5][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+k_7d/2][j_7d/2] <= out[8*8-1-8*5-:8];
		out_save[6][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+k_7d/2][j_7d/2] <= out[8*8-1-8*6-:8];
		out_save[7][i_7d*(memory_width-filter_width-filter_width*filter_height)/2+k_7d/2][j_7d/2] <= out[8*8-1-8*7-:8];
		s <= s+1;
	end
	else if (s == (input_width/2) * (input_height/2)) begin
        //write
        f0 = $fopen(output_file0, "w");
		f1 = $fopen(output_file1, "w");
		f2 = $fopen(output_file2, "w");
		f3 = $fopen(output_file3, "w");
		f4 = $fopen(output_file4, "w");
		f5 = $fopen(output_file5, "w");
		f6 = $fopen(output_file6, "w");
		f7 = $fopen(output_file7, "w");

        for (fw=0; fw < (input_width/2); fw = fw + 1) begin
			for (fh=0; fh < (input_height/2); fh = fh + 1)
            $fdisplay(f0, "%d", out_save[0][fw][fh]);
			$fdisplay(f1, "%d", out_save[1][fw][fh]);
			$fdisplay(f2, "%d", out_save[2][fw][fh]);
			$fdisplay(f3, "%d", out_save[3][fw][fh]);
			$fdisplay(f4, "%d", out_save[4][fw][fh]);
			$fdisplay(f5, "%d", out_save[5][fw][fh]);
			$fdisplay(f6, "%d", out_save[6][fw][fh]);
			$fdisplay(f7, "%d", out_save[7][fw][fh]);

        end
        $fclose(f0);
        $fclose(f1);
        $fclose(f2);
        $fclose(f3);
        $fclose(f4);
        $fclose(f5);
        $fclose(f6);
        $fclose(f7);

		s <= s+1;
    end
end

endmodule









module run_44 #(
parameter write_delay = 31,
parameter read_delay = 881,
parameter save_delay = 941, // read_delay + 60
parameter input_file = "input.txt",
parameter weight_file = "weight.txt",
parameter bias_file = "bias.txt",
parameter output_file0 = "output0.txt",
parameter output_file1 = "output1.txt",
parameter output_file2 = "output2.txt",
parameter output_file3 = "output3.txt",
parameter output_file4 = "output4.txt",
parameter output_file5 = "output5.txt",
parameter output_file6 = "output6.txt",
parameter output_file7 = "output7.txt",
parameter input_width = 128,
parameter input_height = 128,
parameter memory_width = 80,
parameter memory_height = 8,
parameter width_b = 7,
parameter height_b = 3,
parameter filter_width = 4,
parameter filter_height = 4,
parameter zero_padding = 1)

(write_w, write_h, data_in, en_in, readwg, readhg, en_read, step, en_bias, en_pe, out, out_en, clk);

output reg [width_b-1:0]  write_w;
output reg [height_b-1:0]  write_h;
output reg [8*9-1:0] data_in;
output reg [8:0] en_in;

output reg [width_b*9-1:0] readwg;
output reg [height_b*9-1:0] readhg;
output reg [8:0] en_read;
output reg en_bias, en_pe;
output reg [2:0] step;

input [8*8-1:0] out;
input [7:0] out_en;
input clk;

parameter step0 = memory_width - 9;
parameter step1 = memory_width - 18;
parameter step2 = memory_width - 27;
parameter step3 = memory_width - 36;
parameter step4 = memory_width - 45;
parameter step5 = memory_width - 54;

integer i=0, j=0, k=0, l=0, w=0, h=0, s=0, i_d, i_2d, i_3d, i_4d, i_5d, i_6d, i_7d, j_d, j_2d, j_3d, j_4d, j_5d, j_6d, j_7d, k_d, k_2d, k_3d, k_4d, k_5d, k_6d, k_7d,
			f0, f1, f2, f3, f4, f5, f6, f7, fw=0, fh=0;

reg [8-1:0] mat_in [0:input_width*input_height-1];
reg signed [16-1:0] weight [0:8];
reg signed [16-1:0] bias [0:8];

wire [width_b-1:0] readw [0:8];
wire [height_b-1:0] readh [0:8];

assign readw[0] = en_read[8] ? k + w -2 : 0;
assign readh[0] = en_read[8] ? (j % input_height) + h -2 : 0;
assign readw[1] = en_read[7] ? k + w -1 : 0;
assign readh[1] = en_read[7] ? (j % input_height) + h -2 : 0;
assign readw[2] = en_read[6] ? k + w +0 : 0;
assign readh[2] = en_read[6] ? (j % input_height) + h -2 : 0;
assign readw[3] = en_read[5] ? k + w +1 : 0;
assign readh[3] = en_read[5] ? (j % input_height) + h -2 : 0;
assign readw[4] = en_read[4] ? k + w -2 : 0;
assign readh[4] = en_read[4] ? (j % input_height) + h -1 : 0;
assign readw[5] = en_read[3] ? k + w -1 : 0;
assign readh[5] = en_read[3] ? (j % input_height) + h -1 : 0;
assign readw[6] = en_read[2] ? k + w -0 : 0;
assign readh[6] = en_read[2] ? (j % input_height) + h -1 : 0;
assign readw[7] = en_read[1] ? k + w +1 : 0;
assign readh[7] = en_read[1] ? (j % input_height) + h -1 : 0;
assign readw[8] = 0;
assign readh[8] = 0;

assign readwg = {readw[0], readw[1], readw[2], readw[3], readw[4], readw[5], readw[6], readw[7], readw[8]};
assign readhg = {readh[0], readh[1], readh[2], readh[3], readh[4], readh[5], readh[6], readh[7], readh[8]};

// for debugging
integer data_in_ck, data_in_w, data_in_h, ck_last_k0;
reg [7:0] data_in_first;
always @(*) begin
	data_in_ck = k? j-2+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+(k_4d+w)*input_height +memory_height
				:	j-4+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)
					+(memory_width-filter_width-filter_width*filter_height+w)*input_height +memory_height;
	data_in_w = data_in_ck/128;
	data_in_h = data_in_ck - 128*data_in_w;
	ck_last_k0 = j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-filter_width*filter_height+1)+
					(memory_width-filter_width-filter_width*filter_height+w)*input_height;
	data_in_first = data_in[8*9-1-:8];
end


//write

// first write
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
		data_in <= {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], 8'b0000_0000};
		en_in <= 9'b1_1111_1111;
		#(10);
		write_w <= step1;
		write_h <= i;
		data_in <= {weight[8], weight[9], weight[10], weight[11], weight[12], weight[13], weight[14], weight[15], 8'b0000_0000};
		en_in <= 9'b1_1111_1111;
		#(10);
	end

	//write input
	for (j=0; j<8; j=j+1)
	begin
		for (i=0; i<6; i=i+1)
		begin
			write_w <= i*9;
			write_h <= j;
			data_in <= {mat_in[j+input_height*9*i], mat_in[j+input_height*9*i+input_height*1], mat_in[j+input_height*9*i+input_height*2], mat_in[j+input_height*9*i+input_height*3], mat_in[j+input_height*9*i+input_height*4],
						mat_in[j+input_height*9*i+input_height*5], mat_in[j+input_height*9*i+input_height*6], mat_in[j+input_height*9*i+input_height*7], mat_in[j+input_height*9*i+input_height*8]};
			en_in <= 9'b1_1111_1111;
			#(10);
		end
		write_w <= 9*6;
		write_h <= j;
		data_in <= {mat_in[j+input_height*9*6], mat_in[j+input_height*9*6+input_height*1], mat_in[j+input_height*9*6+input_height*2], mat_in[j+input_height*9*6+input_height*3], mat_in[j+input_height*9*6+input_height*4],
					mat_in[j+input_height*9*6+input_height*5], mat_in[j+input_height*9*6+input_height*6], mat_in[j+input_height*9*6+input_height*7], mat_in[j+input_height*9*6+input_height*8]};
		en_in <= 9'b1_1111_1110;
		#(10);
	end
	en_in <= 9'b0_0000_0000;
end

reg enable_write_reading, rightest, pre_rightest;
//write during reading
always @(*) begin
	if (i == (input_width/(memory_width-filter_width-(filter_width*filter_height+2))) -1) pre_rightest =1;
	else pre_rightest =0;
	if (i == (input_width/(memory_width-filter_width-(filter_width*filter_height+2)))) rightest =1;
	else rightest =0;


	if (enable_write_reading==1) begin
		if ((j==0 || (j==2 && k==1)) && i!=0) begin 
			if (k==1) begin
				write_w = rightest ? input_width - i * (memory_width-filter_width-(filter_width*filter_height+2)+1) +w -2 : k_4d + w; 
				write_h = (j % input_height)+4+h; // +4 is correct
				if (l==2 || l==3) begin
					data_in = rightest ?
					{mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(input_width - i * (memory_width-filter_width-(filter_width*filter_height+2)+1) -2+w)*input_height], {8{8'b0000_0000}}}
					
					: {mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(k_4d+w)*input_height],
					mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(k_4d+w+1)*input_height], {7{8'b0000_0000}}};
					en_in = rightest ? 9'b1_0000_0000 : 9'b1_1000_0000;
				end
				else begin
					data_in = rightest ?
					{mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(input_width - i * (memory_width-filter_width-(filter_width*filter_height+2)+1) -2+w)*input_height], {8{8'b0000_0000}}}
					
					:{mat_in[j+(memory_height-4)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(k_4d+w)*input_height], {8{8'b0000_0000}}};
					en_in = 9'b1_0000_0000;
				end
			end
			else if (k==3) begin
				write_w = 0 + w; 
				write_h = (j % input_height)+6+h; // +6 is correct
				if (l==0 || l==1) begin
					data_in = {mat_in[j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(0+w)*input_height],
					mat_in[j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(0+w+1)*input_height], {7{8'b0000_0000}}};
					en_in = 9'b1_1000_0000;
				end
				else begin
					data_in = {8'b0000_0000, mat_in[j+(memory_height-2)+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+
					(0+w+1)*input_height], {7{8'b0000_0000}}};
					en_in = 9'b0_1000_0000;
				end
			end
			else begin
				write_w = k_4d+w;
				write_h = (j % input_height)+6+h; // +6 is correct
				data_in = {mat_in[j-2+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}}; 	
				en_in = 9'b1_0000_0000;
			end
		end
		else if (j>0) begin
			if (j==2 && (k!=0 || k!=1)) begin
				write_w = k==3 ? k_4d+w-1 : k_4d+w; 
				write_h = (j % input_height)-2+h;
				data_in = k==3 ?
				  {mat_in[j-2+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+(k_4d+w-1)*input_height +memory_height],
				  mat_in[j-2+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+(k_4d+w)*input_height +memory_height], {7{8'b0000_0000}}}
				: {mat_in[j-2+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}};
				en_in = k==3 ? 9'b1_1000_0000 : 9'b1_0000_0000;
			end
			else if (j==2 && k==0) begin
				data_in = {9{8'b0000_0000}};
				en_in = 9'b0_0000_0000;
			end
			else if (j>2) begin
				if (j>input_height-(memory_height-1) && !(j==input_height-(memory_height-2) && (k==0 || k==1))) begin
					if (pre_rightest==1) begin
						if (k==0 || k==1) begin 
							write_w =  input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1)-2 + w; 
							write_h = (j % input_height)-4+h;
							if (l==2 || l==3) begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1)-2+w)*input_height], {8{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1)-2+w)*input_height], {8{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
							end
						end
						else if (k==2 || k==3) begin 
							write_w = 0+w*2; 
							write_h = (j % input_height)-2+h;
							if (l==0 || l==1) begin
								data_in = {mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w)*input_height], mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w+1)*input_height], {7{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1) ?
								  9'b1_1000_0000
								: 9'b0_0000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w+1)*input_height], {8{8'b0000_0000}}};
								en_in = k < input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
							end
						end
						else begin
							write_w = k_4d+w;
							write_h = (j % input_height)-2+h;
							data_in = k < input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1) ?
							{mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
							+(k_4d+w)*input_height], {8{8'b0000_0000}}}
							:{9{8'b0000_0000}};
							en_in = k < input_width - (i+1) * (memory_width-filter_width-(filter_width*filter_height+2)+1) ?
								  9'b1_0000_0000
								: 9'b0_0000_0000;
						end
					end									
					else begin
						if (k==0 || k==1) begin
							write_w = k_4d + w; 
							write_h = (j % input_height)-4+h;
							if (l==2 || l==3) begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(k_4d+w)*input_height],
								mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(k_4d+w+1)*input_height], {7{8'b0000_0000}}};
								en_in = 9'b1_1000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(k_4d+w)*input_height], {8{8'b0000_0000}}};
								en_in = 9'b1_0000_0000;
							end
						end
						else if (k==2 || k==3) begin
							write_w = 0+w*2; 
							write_h = (j % input_height)-2+h;
							if (l==0 || l==1) begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w)*input_height],
								mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w+1)*input_height], {7{8'b0000_0000}}};
								en_in = 9'b1_1000_0000;
							end
							else begin
								data_in = {mat_in[j-(input_height-(memory_height-4))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w+1)*input_height], {8{8'b0000_0000}}};
								en_in = 9'b1_0000_0000;
							end
						end
						else begin
							write_w = k_4d+w;
							write_h = (j % input_height)-2+h;
							data_in = {mat_in[j-(input_height-(memory_height-2))+h+input_height*(i+1)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
							+(k_4d+w)*input_height], {8{8'b0000_0000}}};
							en_in = 9'b1_0000_0000;
						end
					end
				end
				else if (k==0 || k==1) begin
						write_w = k_4d + w;
						write_h = (j % input_height)-4+h;
						if (l==2 || l==3) begin
							data_in = {mat_in[j-4+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)
							+(k_4d+w)*input_height +memory_height],
							mat_in[j-4+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)
							+(k_4d+w+1)*input_height +memory_height], {7{8'b0000_0000}}};
							en_in = 9'b1_1000_0000;
						end
						else begin
							data_in = {mat_in[j-4+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)
							+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}};
							en_in = 9'b1_0000_0000;
					end 	
				end
				else if (k==3) begin
							write_w = 0+w*2; 
							write_h = (j % input_height)-2+h;
							if (l==0 || l==1) begin
								data_in = {mat_in[j-2+h+input_height*(i)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w)*input_height +memory_height],
								mat_in[j-2+h+input_height*(i)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w+1)*input_height +memory_height], {7{8'b0000_0000}}};
								en_in = 9'b1_1000_0000;
							end
							else begin
								data_in = {mat_in[j-2+h+input_height*(i)*(memory_width-filter_width-(filter_width*filter_height+2)+1)
								+(w+1)*input_height +memory_height], {8{8'b0000_0000}}};
								en_in = 9'b1_0000_0000;
							end
						end
				else begin
					write_w = k_4d+w;
					write_h = (j % input_height)-2+h;
					data_in = {mat_in[j-2+h+input_height*i*(memory_width-filter_width-(filter_width*filter_height+2)+1)+(k_4d+w)*input_height +memory_height], {8{8'b0000_0000}}}; 		
					en_in = 9'b1_0000_0000;		
				end
				
			end
		end
	end
	else begin
		write_w = 0;
		write_h = 0;
		data_in = {9{8'b0000_0000}};
		en_in = 9'b0_0000_0000;
	end
end



//read
initial begin
	enable_write_reading <= 0;
	#(read_delay);
	if (input_width > memory_width-18) begin
		for ( i=0; i < (input_width/(memory_width-filter_width-(filter_width*filter_height+2))); i=i+1 ) begin // fmap > right  
			for ( j=0; j < input_height; j=j+2 ) begin // mem > under
				for ( k= i==0 ? 0 : 2; k < memory_width-filter_width-(filter_width*filter_height+2)+1; k=k+2 ) begin // mem > right
					for( l=0; l < 8; l=l+1 ) begin // for maxpooling & step
						if (zero_padding == 1) begin
							if (i==0 && k==0 && j==0 && l==0) begin // top-left 0
								en_read <= 9'b000000000;
							end
							else if (i==0 && k==0 && j==0 && l==1) begin // top-left 1
								en_read <= 9'b001100110;
							end
							else if (i==0 && k==0 && j==0 && l==2) begin // top-left 2
								en_read <= 9'b000000110;
							end
							else if (i==0 && k==0 && j==0 && l==3) begin // top-left 3
								en_read <= 9'b001100110;
							end
							else if (i==0 && k==0 && j==0 && l==4) begin // top-left 4
								en_read <= 9'b000000000;
							end
							else if (i==0 && k==0 && j==0 && l==5) begin // top-left 5
								en_read <= 9'b011101110;
							end
							else if (i==0 && k==0 && j==0 && l==6) begin // top-left 6
								en_read <= 9'b000001110;
							end
							else if (i==0 && k==0 && j==0 && l==7) begin // top-left 7
								en_read <= 9'b011101110;
							end
							else if (i==0 && (j==input_height-1 || j==input_height-2) && k==0 && (l==0 || l==1 || l==2)) begin // bottom-left 0 1 2
								en_read <= 9'b001100110;
							end
							else if (i==0 && (j==input_height-1 || j==input_height-2) && k==0 && l==1) begin // bottom-left 3
								en_read <= 9'b001100000;
							end
							else if (i==0 && (j==input_height-1 || j==input_height-2) && k==0 && (l==4 || l==5 || l==6)) begin // bottom-left 4 5 6
								en_read <= 9'b011101110;
							end
							else if (i==0 && (j==input_height-1 || j==input_height-2) && k==0 && l==7) begin // bottom-left 7
								en_read <= 9'b011100000;
							end
							else if (j==0 && (l==0 || l==6)) begin // top 0 6
								en_read <= 9'b000000000;
							end
							else if (j==0 && (l==2 || l==4)) begin // top 2 4
								en_read <= 9'b000011110;
							end
							else if (i==0 && k==0 && (l==0 || l==1 || l==2 || l==3)) begin // left 0 1 2 3
								en_read <= 9'b001100110;
							end
							else if (i==0 && k==0 && (l==4 || l==5 || l==6 || l==7)) begin // left 4 5 6 7
								en_read <= 9'b011101110;
							end
							else if ((j==input_height-1 || j==input_height-2) && (l==3 || l==5)) begin // bottom 3 5
								en_read <= 9'b111100000;
							end
							else en_read <= 9'b111111111;
						end
						else en_read <= 9'b111111111; // incompleted yet

						if (l==0 || l==1 || l==2 || l==3) w <= 0;
						else w <= 1;
						
						if (l==1 || l==7) h <= 2;
						else if (l==2 || l==4) h <= 1;
						else if (l==3 || l==5) h <= 3;
						else h <= 0; 

						if (l==0 || l==2 || l==4 || l==6) step <= 3'b000;
						else step <= 3'b001;

						en_bias <= 1;
						en_pe <= 1;

						// write_reading start
						enable_write_reading <= 1;
						

						#10;
					end
				end
			end
		end
	end

	// rightest fmap
	for ( j=0; j < input_height; j=j+2 ) begin // mem > under
		for ( k= i==0 ? 0 : 1; k < input_width - i * (memory_width-filter_width-(filter_width*filter_height+2)+1); k=k+2 ) begin // mem > right		k=1 is correct
			for( l=0; l < 4; l=l+1 ) begin // for maxpooling
				if (zero_padding == 1) begin
					if (k==0 && j==0 && l==0) begin // top-left
						en_read <= 9'b000011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && k==0 && l==1) begin // bottom-left
								en_read <= 9'b011011000;
					end
					else if (k > input_width - i * (memory_width-filter_width-(filter_width*filter_height+2)+1)-3 && j==0 && l==3) begin // top-right
						en_read <= 9'b000110110;
					end
					else if (k > input_width - i * (memory_width-filter_width-(filter_width*filter_height+2)+1)-3 && (j==input_height-1 || j==input_height-2) && l==2) begin // bottom-right
						en_read <= 9'b110110000;
					end
					else if (j==0 && (l==0 || l==3)) begin // top
						en_read <= 9'b000111111;
					end
					else if (k==0 && (l==0 || l==1)) begin // left
						en_read <= 9'b011011011;
					end
					else if ((j==input_height-1 || j==input_height-2) && (l==1 || l==2)) begin // bottom
						en_read <= 9'b111111000;
					end
					else if (k > input_width - i * (memory_width-filter_width-(filter_width*filter_height+2)+1)-3 && (l==2 || l==3)) begin // right
						en_read <= 9'b110110110;
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

				// write_reading start
				enable_write_reading <= 1;

				#10;
			end
		end
	end

	en_pe <= 0;

end


// save output

reg start_save;
reg [7:0] out_save[0:7][0:(input_width/2)-1][0:(input_height/2)-1];

initial begin
	#(save_delay);
	start_save <= 1;
end

always @(posedge clk) begin
	i_d <= i;
	i_2d <= i_d;
	i_3d <= i_2d;
	i_4d <= i_3d;
	i_5d <= i_4d;
	i_6d <= i_5d;
	i_7d <= i_6d;

	j_d <= j;
	j_2d <= j_d;
	j_3d <= j_2d;
	j_4d <= j_3d;
	j_5d <= j_4d;
	j_6d <= j_5d;
	j_7d <= j_6d;

	k_d <= k;
	k_2d <= k_d;
	k_3d <= k_2d;
	k_4d <= k_3d;
	k_5d <= k_4d;
	k_6d <= k_5d;
	k_7d <= k_6d;

end

always @(posedge clk) begin
	if (out_en[7]==1 && start_save ==1 && s < (input_width/2) * (input_height/2)) begin
		out_save[0][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+(k_7d/2) + (k_7d % 2)][j_7d/2] <= out[8*8-1-8*0-:8];
		out_save[1][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+k_7d/2][j_7d/2] <= out[8*8-1-8*1-:8];
		out_save[2][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+k_7d/2][j_7d/2] <= out[8*8-1-8*2-:8];
		out_save[3][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+k_7d/2][j_7d/2] <= out[8*8-1-8*3-:8];
		out_save[4][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+k_7d/2][j_7d/2] <= out[8*8-1-8*4-:8];
		out_save[5][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+k_7d/2][j_7d/2] <= out[8*8-1-8*5-:8];
		out_save[6][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+k_7d/2][j_7d/2] <= out[8*8-1-8*6-:8];
		out_save[7][i_7d*(memory_width-filter_width-(filter_width*filter_height+2))/2+k_7d/2][j_7d/2] <= out[8*8-1-8*7-:8];
		s <= s+1;
	end
	else if (s == (input_width/2) * (input_height/2)) begin
        //write
        f0 = $fopen(output_file0, "w");
		f1 = $fopen(output_file1, "w");
		f2 = $fopen(output_file2, "w");
		f3 = $fopen(output_file3, "w");
		f4 = $fopen(output_file4, "w");
		f5 = $fopen(output_file5, "w");
		f6 = $fopen(output_file6, "w");
		f7 = $fopen(output_file7, "w");

        for (fw=0; fw < (input_width/2); fw = fw + 1) begin
			for (fh=0; fh < (input_height/2); fh = fh + 1)
            $fdisplay(f0, "%d", out_save[0][fw][fh]);
			$fdisplay(f1, "%d", out_save[1][fw][fh]);
			$fdisplay(f2, "%d", out_save[2][fw][fh]);
			$fdisplay(f3, "%d", out_save[3][fw][fh]);
			$fdisplay(f4, "%d", out_save[4][fw][fh]);
			$fdisplay(f5, "%d", out_save[5][fw][fh]);
			$fdisplay(f6, "%d", out_save[6][fw][fh]);
			$fdisplay(f7, "%d", out_save[7][fw][fh]);

        end
        $fclose(f0);
        $fclose(f1);
        $fclose(f2);
        $fclose(f3);
        $fclose(f4);
        $fclose(f5);
        $fclose(f6);
        $fclose(f7);

		s <= s+1;
    end
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
wire [2:0] step;
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
	en_relu <= 1;
	en_mp <= 1;
	bound_level <= 3'b011;
	step_p <= 3'b000;
	#12
	reset <= 1;

end

run_33 #( .input_file("input_npu.txt"), .weight_file("input_npu_wi.txt"), .bias_file ("input_npu_bi.txt"), .output_file0 ("output_npu.txt"))
		layer0 (write_w, write_h, data_in, en_in, readi_w, readi_h, en_read, step, en_bias, en_pe, out, out_en, clk);









endmodule

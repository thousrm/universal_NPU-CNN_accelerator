
`timescale 1ns/10ps
module tb_npu_simple;

parameter width = 80;
parameter height = 8;

parameter width_b = 7;
parameter height_b = 3;

	reg clk, reset;

    reg [8-1:0] mat_in [0:63][0:63];
	reg signed [8-1:0] weight [0:8];
    reg signed [8-1:0] mat_out [0:63];
    reg signed [16-1:0] bias [0:8];

	reg signed [8-1:0] p_out;

	wire signed [8-1:0] out;

	reg [8*9-1:0] in;
	wire [8*9-1:0] weightin;
	
	wire out_en;

    reg signed [16-1:0] bias;
    reg [2:0] bound_level;
    reg [2:0] step;
    reg en, en_relu, en_mp;

    reg [8*9-1:0] data_in;
    reg [8:0] en_in, en_read;
    reg en_bias;
    reg [2:0] stepr;
    reg en_pe;
    reg [2:0] step_pr, bound_levelr;
    reg clk, reset;
    reg [width_b-1:0]  write_wr;
    reg [height_b-1:0]  write_hr;
    reg [width_b*9-1:0] readi_wr;
    reg [height_b*9-1:0]  readi_hr;

	assign {ina[0], ina[1], ina[2], ina[3], ina[4], ina[5], ina[6], ina[7], ina[8]} = in;

	
	assign weightin = {weight[0], weight[1], weight[2], weight[3], weight[4], weight[5], weight[6], weight[7], weight[8]}; 


	npu_simple npu (write_wr, write_hr, data_in, en_in, 
                    readi_wr, readi_hr, en_read, en_bias, stepr, en_pe, bound_levelr, step_pr, 
                    out, out_en, clk, reset);

	
	initial
	begin
		clk <= 1;
		reset <= 0;
        en_relu <= 0;
        en_mp <= 0;
		en <= 0;
		#12
		reset <= 1;

	end
	
	always #5 clk <= ~clk;

	
    integer i=0, j=0;

//write
	initial
	begin		
		$readmemh("input_pe.txt", mat_in);
		$readmemh("input_pe_wi.txt", weight);
		
        #(31);
        for (i=0; i<64; i=i+1)
        begin
            in <= mat_in[i];
            en <= 1;
            #(10);
        end
        en <= 0;

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
	end





endmodule

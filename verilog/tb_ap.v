
`timescale 1ns/10ps
module tb_ap();

parameter cell_bit = 8;
parameter N_cell = 9;
parameter biasport = 16;
parameter N_core = 8;
parameter outport = 8;

reg [cell_bit*N_cell-1:0] in;
reg [cell_bit*N_cell*N_core-1:0] weight;
reg [biasport*N_core-1:0] bias;
reg [2:0] bound_level;
reg [2:0] step;
reg en, en_relu, en_mp;
reg clk, reset;

wire [outport*N_core-1:0] out;
wire [N_core-1:0] out_en;

always #5 clk <= ~clk;

reg [223:0] mat_in[0:27];
reg [7:0] inp[0:27][0:27];

reg [7:0] weight0[0:15];
reg [15:0] bias0[0:1];
reg [7:0] out0[0:143];

wire[7:0] out0a;

assign out0a = out[outport*N_core-1-:8];


AP AP0(in, weight, bias, bound_level, step, en, en_relu, en_mp, out, out_en, clk, reset);

//{weight0[0], weight0[1], weight0[2], weight0[3], weight0[4], weight0[5], weight0[6], weight0[7], weight0[8]}

integer i=0, j=0, layer0 = 0, f, k;

initial //input
	begin
		clk = 1;
        reset = 0;
        en_relu = 0;
        en_mp = 0;
		en = 0;
        #12
        reset = 1;

        #9
        $readmemh("input_map_hex.txt", mat_in);
        $readmemb("wei0_bin.txt", weight0);
        $readmemb("bias0_bin.txt", bias0);

        en_relu = 1;
        en_mp = 1;
        en = 1;
        bound_level = 3'b011;
        step = 3'b001;


        for (i=0; i<28; i=i+1)
			begin
                for (j=0; j<28; j=j+1)
                begin
                    inp[i][j] = mat_in[i][223-8*j-:8];
                    inp[i][j] = inp[i][j] >> 1;
                end
                
			end

        
        for (i=0; i<24; i=i+2)
            begin
                for (j=0; j<24; j=j+2)
                    begin
                        in = {inp[i][j], inp[i][j+1], inp[i][j+2], inp[i][j+3], 
                                inp[i+1][j], inp[i+1][j+1], inp[i+1][j+2], inp[i+1][j+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[0], weight0[1], weight0[2], weight0[3], weight0[4], weight0[5], weight0[6], weight0[7], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell :0] = 0;
                        bias[biasport*N_core-1-:biasport] = bias0[0];
                        bias[biasport*N_core-1-biasport:0] = 0;

                        #10
                        in = {inp[i+2][j], inp[i+2][j+1], inp[i+2][j+2], inp[i+2][j+3], 
                                inp[i+3][j], inp[i+3][j+3], inp[i+3][j+2], inp[i+3][j+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[8], weight0[9], weight0[10], weight0[11], weight0[12], weight0[13], weight0[14], weight0[15], 8'b0000_0000};
                        bias[biasport*N_core-1-:biasport] = 0;
                        #10;

                        in = {inp[i][j+1], inp[i][j+1+1], inp[i][j+1+2], inp[i][j+1+3], 
                                inp[i+1][j+1], inp[i+1][j+1+1], inp[i+1][j+1+2], inp[i+1][j+1+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[0], weight0[1], weight0[2], weight0[3], weight0[4], weight0[5], weight0[6], weight0[7], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell :0] = 0;
                        bias[biasport*N_core-1-:biasport] = bias0[0];
                        bias[biasport*N_core-1-biasport:0] = 0;

                        #10
                        in = {inp[i+2][j+1], inp[i+2][j+1+1], inp[i+2][j+1+2], inp[i+2][j+1+3], 
                                inp[i+3][j+1], inp[i+3][j+1+3], inp[i+3][j+1+2], inp[i+3][j+1+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[8], weight0[9], weight0[10], weight0[11], weight0[12], weight0[13], weight0[14], weight0[15], 8'b0000_0000};
                        bias[biasport*N_core-1-:biasport] = 0;
                        #10;




                        in = {inp[i+1][j], inp[i+1][j+1], inp[i+1][j+2], inp[i+1][j+3], 
                                inp[i+1+1][j], inp[i+1+1][j+1], inp[i+1+1][j+2], inp[i+1+1][j+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[0], weight0[1], weight0[2], weight0[3], weight0[4], weight0[5], weight0[6], weight0[7], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell :0] = 0;
                        bias[biasport*N_core-1-:biasport] = bias0[0];
                        bias[biasport*N_core-1-biasport:0] = 0;

                        #10
                        in = {inp[i+1+2][j], inp[i+1+2][j+1], inp[i+1+2][j+2], inp[i+1+2][j+3], 
                                inp[i+1+3][j], inp[i+1+3][j+3], inp[i+1+3][j+2], inp[i+1+3][j+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[8], weight0[9], weight0[10], weight0[11], weight0[12], weight0[13], weight0[14], weight0[15], 8'b0000_0000};
                        bias[biasport*N_core-1-:biasport] = 0;
                        #10;

                        in = {inp[i+1][j+1], inp[i+1][j+1+1], inp[i+1][j+1+2], inp[i+1][j+1+3], 
                                inp[i+1+1][j+1], inp[i+1+1][j+1+1], inp[i+1+1][j+1+2], inp[i+1+1][j+1+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[0], weight0[1], weight0[2], weight0[3], weight0[4], weight0[5], weight0[6], weight0[7], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell :0] = 0;
                        bias[biasport*N_core-1-:biasport] = bias0[0];
                        bias[biasport*N_core-1-biasport:0] = 0;

                        #10
                        in = {inp[i+1+2][j+1], inp[i+1+2][j+1+1], inp[i+1+2][j+1+2], inp[i+1+2][j+1+3], 
                                inp[i+1+3][j+1], inp[i+1+3][j+1+3], inp[i+1+3][j+1+2], inp[i+1+3][j+1+3], 8'b0000_0000};
                        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight0[8], weight0[9], weight0[10], weight0[11], weight0[12], weight0[13], weight0[14], weight0[15], 8'b0000_0000};
                        bias[biasport*N_core-1-:biasport] = 0;
                        #10;
                    end
            end


    end

always @(posedge clk) begin
    if (layer0 < 144 & out_en[7] == 1) begin
        out0[layer0] <= out[outport*N_core-1-:8];
        layer0 <= layer0 + 1;
    end
    else if (layer0 == 144) begin
        //write
        f = $fopen("output_layer01.txt", "w");
        for (k = 0; k < 144; k = k + 1) begin
            $fdisplay(f, "%b", out0[k]);
        end
        $fclose(f);
    end
end


endmodule




`timescale 1ns/10ps
module tb_ap();

parameter cell_bit = 8;
parameter N_cell = 9;
parameter biasport = 16;
parameter N_core = 8;
parameter outport = 8;

reg [cell_bit*N_cell-1:0] in;
wire signed [cell_bit-1:0] inv[0:8];
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
reg [7:0] in2[0:143];

reg [7:0] weight0[0:15];
reg [15:0] bias0[0:1];
reg [7:0] out0[0:143];
reg signed [7:0] out20[0:24], out21[0:24], out22[0:24], out23[0:24], out24[0:24], out25[0:24], out26[0:24], out27[0:24];

reg [7:0] weight20[0:8], weight21[0:8], weight22[0:8], weight23[0:8], weight24[0:8], weight25[0:8], weight26[0:8], weight27[0:8];
reg [15:0] bias2[0:7];

wire[7:0] out0a, out1a, out2a, out3a, out4a, out5a, out6a, out7a;

assign out0a = out[outport*N_core-1-:8];
assign out1a = out[outport*N_core-1-outport*1-:8];
assign out2a = out[outport*N_core-1-outport*2-:8];
assign out3a = out[outport*N_core-1-outport*3-:8];
assign out4a = out[outport*N_core-1-outport*4-:8];
assign out5a = out[outport*N_core-1-outport*5-:8];
assign out6a = out[outport*N_core-1-outport*6-:8];
assign out7a = out[outport*N_core-1-outport*7-:8];

assign inv[0] = in[cell_bit*N_cell-1-:8];
assign inv[1] = in[cell_bit*N_cell-1-1*8-:8];
assign inv[2] = in[cell_bit*N_cell-1-2*8-:8];
assign inv[3] = in[cell_bit*N_cell-1-3*8-:8];
assign inv[4] = in[cell_bit*N_cell-1-4*8-:8];
assign inv[5] = in[cell_bit*N_cell-1-5*8-:8];
assign inv[6] = in[cell_bit*N_cell-1-6*8-:8];
assign inv[7] = in[cell_bit*N_cell-1-7*8-:8];
assign inv[8] = in[cell_bit*N_cell-1-8*8-:8];



AP AP0(in, weight, bias, bound_level, step, en, en_relu, en_mp, out, out_en, clk, reset);

//{weight0[0], weight0[1], weight0[2], weight0[3], weight0[4], weight0[5], weight0[6], weight0[7], weight0[8]}

integer i=0, j=0, layer0 = 0, layer2 = 0, f, f0, f1, f2, f3, f4, f5, f6, f7, k;

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
        $readmemb("l0c0 weight.txt", weight0);
        $readmemb("l0 bias.txt", bias0);

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
        en = 0;
        #100

        $readmemb("output layer01.txt", in2);
        for (i = 0; i < 12; i = i+1)
            begin
                for (j = 0; j < 12; j = j+1)
                    begin
                        inp[i][j] = in2[i*12+j];
                    end
            end
        $readmemb("l2c0 weight.txt", weight20);
        $readmemb("l2c1 weight.txt", weight21);
        $readmemb("l2c2 weight.txt", weight22);
        $readmemb("l2c3 weight.txt", weight23);
        $readmemb("l2c4 weight.txt", weight24);
        $readmemb("l2c5 weight.txt", weight25);
        $readmemb("l2c6 weight.txt", weight26);
        $readmemb("l2c7 weight.txt", weight27);
        $readmemb("l2 bias.txt", bias2);
        

        reset = 0;
        #10
        reset = 1;
        en = 1;
        bound_level = 3'b101;
        step = 3'b000;

        weight[cell_bit*N_cell*N_core-1 -:cell_bit*N_cell] = {weight20[0], weight20[1], weight20[2], weight20[3], weight20[4], weight20[5], weight20[6], weight20[7], weight20[8]};
        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell*1 -:cell_bit*N_cell] = {weight21[0], weight21[1], weight21[2], weight21[3], weight21[4], weight21[5], weight21[6], weight21[7], weight21[8]};
        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell*2 -:cell_bit*N_cell] = {weight22[0], weight22[1], weight22[2], weight22[3], weight22[4], weight22[5], weight22[6], weight22[7], weight22[8]};
        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell*3 -:cell_bit*N_cell] = {weight23[0], weight23[1], weight23[2], weight23[3], weight23[4], weight23[5], weight23[6], weight23[7], weight23[8]};
        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell*4 -:cell_bit*N_cell] = {weight24[0], weight24[1], weight24[2], weight24[3], weight24[4], weight24[5], weight24[6], weight24[7], weight24[8]};
        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell*5 -:cell_bit*N_cell] = {weight25[0], weight25[1], weight25[2], weight25[3], weight25[4], weight25[5], weight25[6], weight25[7], weight25[8]};
        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell*6 -:cell_bit*N_cell] = {weight26[0], weight26[1], weight26[2], weight26[3], weight26[4], weight26[5], weight26[6], weight26[7], weight26[8]};
        weight[cell_bit*N_cell*N_core-1-cell_bit*N_cell*7 -:cell_bit*N_cell] = {weight27[0], weight27[1], weight27[2], weight27[3], weight27[4], weight27[5], weight27[6], weight27[7], weight27[8]};
        bias = {bias2[0], bias2[1], bias2[2], bias2[3], bias2[4], bias2[5], bias2[6], bias2[7]};

        for (i=0; i<10; i=i+2)
            begin
                for (j=0; j<10; j=j+2)
                    begin
                        in = {inp[i][j], inp[i][j+1], inp[i][j+2], 
                              inp[i+1][j], inp[i+1][j+1], inp[i+1][j+2],
                              inp[i+2][j], inp[i+2][j+1], inp[i+2][j+2]};
                        #10
                        in = {inp[i][j+1], inp[i][j+1+1], inp[i][j+1+2], 
                              inp[i+1][j+1], inp[i+1][j+1+1], inp[i+1][j+1+2],
                              inp[i+2][j+1], inp[i+2][j+1+1], inp[i+2][j+1+2]};
                        #10
                        in = {inp[i+1][j], inp[i+1][j+1], inp[i+1][j+2], 
                              inp[i+1+1][j], inp[i+1+1][j+1], inp[i+1+1][j+2],
                              inp[i+1+2][j], inp[i+1+2][j+1], inp[i+1+2][j+2]};
                        #10
                        in = {inp[i+1][j+1], inp[i+1][j+1+1], inp[i+1][j+1+2], 
                              inp[i+1+1][j+1], inp[i+1+1][j+1+1], inp[i+1+1][j+1+2],
                              inp[i+1+2][j+1], inp[i+1+2][j+1+1], inp[i+1+2][j+1+2]};
                        #10;
                    end
            end

        en = 0;



    end

always @(posedge clk) begin
    if (layer0 < 144 & out_en[7] == 1) begin
        out0[layer0] <= out[outport*N_core-1-:8];
        layer0 <= layer0 + 1;
    end
    else if (layer0 == 144) begin
        //write
        f = $fopen("output layer01.txt", "w");
        for (k = 0; k < 144; k = k + 1) begin
            $fdisplay(f, "%b", out0[k]);
        end
        $fclose(f);
    end

    if (layer0 == 144 & out_en == 8'b1111_1111 & layer2 < 25) begin
        out20[layer2] <= out[outport*N_core-1-:8];
        out21[layer2] <= out[outport*N_core-1-8*1-:8];
        out22[layer2] <= out[outport*N_core-1-8*2-:8];
        out23[layer2] <= out[outport*N_core-1-8*3-:8];
        out24[layer2] <= out[outport*N_core-1-8*4-:8];
        out25[layer2] <= out[outport*N_core-1-8*5-:8];
        out26[layer2] <= out[outport*N_core-1-8*6-:8];
        out27[layer2] <= out[outport*N_core-1-8*7-:8];

        layer2 <= layer2 + 1;
    end
    else if (layer2 == 25) begin
        //write
        f0 = $fopen("output layer20.txt", "w");
        f1 = $fopen("output layer21.txt", "w");
        f2 = $fopen("output layer22.txt", "w");
        f3 = $fopen("output layer23.txt", "w");
        f4 = $fopen("output layer24.txt", "w");
        f5 = $fopen("output layer25.txt", "w");
        f6 = $fopen("output layer26.txt", "w");
        f7 = $fopen("output layer27.txt", "w");
        for (k = 0; k < 25; k = k + 1) begin
            $fdisplay(f0, "%d", out20[k]);
            $fdisplay(f1, "%d", out21[k]);
            $fdisplay(f2, "%d", out22[k]);
            $fdisplay(f3, "%d", out23[k]);
            $fdisplay(f4, "%d", out24[k]);
            $fdisplay(f5, "%d", out25[k]);
            $fdisplay(f6, "%d", out26[k]);
            $fdisplay(f7, "%d", out27[k]);
        end
        $fclose(f0);
        $fclose(f1);
        $fclose(f2);
        $fclose(f3);
        $fclose(f4);
        $fclose(f5);
        $fclose(f6);
        $fclose(f7);
    end
end


endmodule





`timescale 1ns/10ps
module tb_addertree2;

	reg clk, reset;
    wire [8*9-1:0] multiplicand9, multiplier9;
    reg signed [7:0] multiplicand, multiplier;
    reg [15:0] mat_in[0:140];
    reg signed [15:0] bias;


    wire [8:0] O14, O13;
    wire [17:0] O12, O11;
    wire [35:0] O10, O9, O8, O7;
    wire [44:0] O6;
    wire [26:0] O5;
    wire [35:0] O4;
    wire [17:0] O3;
    wire [26:0] O2;
    wire [8:0] O1;
    wire [17:0] O0;

    wire ao18;
    wire [1:0] ao17;
    wire [2:0] ao16;
    wire [4:0] ao15, ao14;
    wire [6:0] ao13;
    wire [8:0] ao12;
    wire [9:0] ao11;
    wire [10:0] ao10;
    wire [11:0] ao9;
    wire [10:0] ao8;
    wire [9:0] ao7;
    wire [9:0] ao6;
    wire [8:0] ao5;
    wire [7:0] ao4;
    wire [5:0] ao3;

    wire o19;
    wire [2:0] o18, o17;
    wire [3:0] o16, o15, o14, o13, o12, o11, o10, o9, o8, o7;
    wire [2:0] o6, o5;
    wire [1:0] o4;
    wire o3;

    reg signed [13:1] pre_output, pre_outputm;

    assign multiplier9 = {9{multiplier}};
    assign multiplicand9 = {9{multiplicand}};

    multiplier M0(multiplicand9, multiplier9,
                        O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0);

    addertree_stage1 AT10(O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0, 
                         bias,
                         ao18, ao17, ao16, ao15, ao14, ao13, ao12, ao11, ao10, ao9, ao8, ao7, ao6, ao5, ao4, ao3);

    addertree_stage2 AT20(ao18, ao17, ao16, ao15, ao14, ao13, ao12, ao11, ao10, ao9, ao8, ao7, ao6, ao5, ao4, ao3,
                        pre_output,
                        o19, o18, o17, o16, o15, o14, o13, o12, o11, o10, o9, o8, o7, o6, o5, o4, o3
                        );

    wire [5:0] aao[19:3];

    assign aao[19] = addall(o19);
    assign aao[18] = addall(o18);
    assign aao[17] = addall(o17);
    assign aao[16] = addall(o16);
    assign aao[15] = addall(o15);
    assign aao[14] = addall(o14);
    assign aao[13] = addall(o13);
    assign aao[12] = addall(o12);
    assign aao[11] = addall(o11);
    assign aao[10] = addall(o10);
    assign aao[9] = addall(o9);
    assign aao[8] = addall(o8);
    assign aao[7] = addall(o7);
    assign aao[6] = addall(o6);
    assign aao[5] = addall(o5);
    assign aao[4] = addall(o4);
    assign aao[3] = addall(o3);

	initial
	begin
		clk = 1;
        multiplier = 8'b0000_0000;
        multiplicand = 8'b0000_0000;
        pre_output = 0;
        pre_outputm = 0;
	end
	
	always #5 clk = ~clk;

    function [5:0] addall;
    input [11:0] in;
    begin
        addall = in[0] + in[1] + in[2] + 
              in[3] + in[4] + in[5] + 
              in[6] + in[7] + in[8] +
              in[9] + in[10] + in[11] ;
    end
    endfunction

    wire signed [19:0] O9m, Oao;
    assign O9m = multiplier * multiplicand * 9 + bias + (pre_outputm<<6);
    assign Oao = (aao[19]<<19) + (aao[18]<<18) +(aao[17]<<17) +(aao[16]<<16) +(aao[15]<<15) +
                    (aao[14]<<14) +(aao[13]<<13) +(aao[12]<<12) +(aao[11]<<11) +
                    (aao[10]<<10) +(aao[9]<<9) +(aao[8]<<8) +(aao[7]<<7) +
                    (aao[6]<<6) +(aao[5]<<5) +(aao[4]<<4) +(aao[3]<<3);

    wire signed [13:1] outm, outa;

    assign outm = O9m[19-:2] == 2'b01 ? 'b0_1111_1111_1111 : O9m[19-:2] == 2'b10 ? 'b1_0000_0000_0000 : O9m[18-:13];
    assign outa = Oao[19-:2] == 2'b01 ? 'b0_1111_1111_1111 : Oao[19-:2] == 2'b10 ? 'b1_0000_0000_0000 : Oao[18-:13];

    always begin #10 pre_output = outa; #10 pre_output = outa; #10 pre_output = outa; #10 pre_output = 0; end
    always begin #10 pre_outputm = outm; #10 pre_outputm = outm; #10 pre_outputm = outm; #10 pre_outputm = 0; end


    integer err = 0, i = 0, j = 0, err2 = 0;
    initial
	begin
        bias = 16'b0000_0000_0000_0000;		
		$readmemh("input_ppg.txt", mat_in);
        #20
		begin
			for (i=0; i<30; i=i+1)
			begin
				{multiplier, multiplicand} = mat_in[i];
                #(1);
                if (outa - outm > 'sd16 | outa - outm > 'sd16) err2 = err2 + 1;
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
                    bias = bias + 5;
                    #(1);
                    if (outa - outm > 'sd16 | outa - outm > 'sd16) err2 = err2 + 1;
                    #(9);
                end
			end
		end

	end





endmodule

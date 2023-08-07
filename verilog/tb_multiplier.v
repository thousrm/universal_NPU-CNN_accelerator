

`timescale 1ns/10ps
module tb_multiplier;

	reg clk, reset;
    wire [8*9-1:0] multiplicand9, multiplier9;
    reg signed [7:0] multiplicand, multiplier;
    reg [15:0] mat_in[0:140];


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

    multiplier M0(multiplicand9, multiplier9,
                        O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0);

    assign multiplier9 = {9{multiplier}};
    assign multiplicand9 = {9{multiplicand}};

	initial
	begin
		clk = 1;
        multiplier = 8'b0000_0000;
        multiplicand = 8'b0000_0000;
	end
	
	always #5 clk = ~clk;

    wire [5:0] Oa[14:0];

    function [5:0] addport1;
    input [8:0] in;
    begin
        addport1 = in[0] + in[1] + in[2] + 
              in[3] + in[4] + in[5] + 
              in[6] + in[7] + in[8] ;
    end
    endfunction

    function [5:0] addport2;
    input [9-1:0] in1, in2;
    begin
        addport2 = addport1(in1) + addport1(in2);
    end
    endfunction

    function [5:0] addport3;
    input [9-1:0] in1, in2, in3;
    begin
        addport3 = addport1(in1) + addport1(in2) + addport1(in3);
    end
    endfunction

    function [5:0] addport4;
    input [9-1:0] in1, in2, in3, in4;
    begin
        addport4 = addport1(in1) + addport1(in2) + addport1(in3) + addport1(in4);
    end
    endfunction

    function [5:0] addport5;
    input [9-1:0] in1, in2, in3, in4, in5;
    begin
        addport5 = addport1(in1) + addport1(in2) + addport1(in3) + addport1(in4) + addport1(in5);
    end
    endfunction

    
    //14, 13, 1 - 1
    assign Oa[14] = addport1(O14);
    assign Oa[13] = addport1(O13);
    assign Oa[1] = addport1(O1);

    //12, 11, 3, 0 - 2
    assign Oa[11] = addport2(O11[17:9], O11[8:0]);
    assign Oa[12] = addport2(O12[17:9], O12[8:0]);
    assign Oa[3] = addport2(O3[17:9], O3[8:0]);
    assign Oa[0] = addport2(O0[17:9], O0[8:0]);


    // 10, 9, 8, 7, 4 - 4
    assign Oa[10] = addport4(O10[35:27], O10[26:18], O10[17:9], O10[8:0]);
    assign Oa[9] = addport4(O9[35:27], O9[26:18], O9[17:9], O9[8:0]);
    assign Oa[8] = addport4(O8[35:27], O8[26:18], O8[17:9], O8[8:0]);
    assign Oa[7] = addport4(O7[35:27], O7[26:18], O7[17:9], O7[8:0]);
    assign Oa[4] = addport4(O4[35:27], O4[26:18], O4[17:9], O4[8:0]);

    //6 - 5
    assign Oa[6] = addport5(O6[44:36], O6[35:27], O6[26:18], O6[17:9], O6[8:0]);

    //5, 2 - 3
    assign Oa[5] = addport3(O5[26:18], O5[17:9], O5[8:0]);
    assign Oa[2] = addport3(O2[26:18], O2[17:9], O2[8:0]);








    wire signed [18:0] O9o, O9m;

    assign O9o = (Oa[14]<<14) + (Oa[13]<<13) + (Oa[12]<<12) + (Oa[11]<<11) + 
                (Oa[10]<<10) + (Oa[9]<<9) + (Oa[8]<<8) + (Oa[7]<<7) + (Oa[6]<<6) + 
                (Oa[5]<<5) + (Oa[4]<<4) + (Oa[3]<<3) + (Oa[2]<<2) + (Oa[1]<<1) + Oa[0] +
                19'b100_1110_1000_0000_0000;
    assign O9m = multiplier * multiplicand * 9;


    integer err = 0, i = 0, j = 0, err2 = 0;
    initial
	begin		
		$readmemh("input_ppg.txt", mat_in);
        #10
		begin
			for (i=0; i<20; i=i+1)
			begin
				{multiplier, multiplicand} = mat_in[i];
                #(1);
                if (O9o != O9m) err = err + 1;
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
                    #(1);
                    if (O9o != O9m) err = err + 1;
                    #(9);
                end
			end
		end

	end





endmodule




`timescale 1ns/10ps
module FF_test;

	reg clk, reset;

    reg [8-1:0] A1;
    wire [8-1:0] A2, A3, A4, A5, A6;
    reg [8-1:0] B2, B3, B4, B5, B6;
    reg [8-1:0] C2, C3, C4, C5, C6;

    D_FF8 FF0 (A1, A2, clk, reset);
    D_FF8 FF1 (A2, A3, clk, reset);
    D_FF8 FF2 (A3, A4, clk, reset);
    D_FF8 FF3 (A4, A5, clk, reset);
    D_FF8 FF4 (A5, A6, clk, reset);

	
	initial
	begin
		clk = 1;
		reset = 0;
		
		#12
		reset = 1;
        #8
        A1 = 8'd4;

	end
	
	always #5 clk = ~clk;

    always @ (posedge clk) begin
        B2 <= A1;
        B3 <= B2;
        B4 <= B3;
        B5 <= B4;
        B6 <= B5;
    end

    always @ (posedge clk) begin
        C2 <= A1;
    end

    always @ (posedge clk) begin
        C3 <= C2;
    end

    always @ (posedge clk) begin
        C4 <= C3;
    end

    always @ (posedge clk) begin
        C5 <= C4;
    end

    always @ (posedge clk) begin
        C6 <= C5;
    end


endmodule

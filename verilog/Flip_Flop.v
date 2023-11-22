module D_FF144 # (parameter port = 144) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF114 # (parameter port = 114) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF8 # (parameter port = 8) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF1 # (parameter port = 1) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF3 # (parameter port = 3) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF2 # (parameter port = 2) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF16 # (parameter port = 16) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF119 # (parameter port = 119) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF10 # (parameter port = 10) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule

module D_FF13 # (parameter port = 13) (d, q, clk, reset);


input [port-1:0] d;
input clk, reset;
output reg [port-1:0] q;


always @ (posedge clk)

begin

if(!reset)
	q <= 'd0;
else
	q <= d;

end

endmodule
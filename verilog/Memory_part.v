
module memory_part(write_w, write_h, write,
                    read_w0, read_w1, read_w2, read_w3, read_w4, read_w5, read_w6, read_w7, read_w8,
                    read_h0, read_h1, read_h2, read_h3, read_h4, read_h5, read_h6, read_h7, read_h8,
                    clk,
                    read0, read1, read2, read3, read4, read5, read6, read7, read8
                    );

parameter width = 16;
parameter height = 16;
parameter width_b = 4;
parameter height_b = 4;

input clk;

input [width_b-1:0]  write_w;
input [height_b-1:0]  write_h;
input [7:0] write;

input [width_b-1:0]  read_w0, read_w1, read_w2, read_w3, read_w4, read_w5, read_w6, read_w7, read_w8;
input [height_b-1:0]  read_h0, read_h1, read_h2, read_h3, read_h4, read_h5, read_h6, read_h7, read_h8;
output reg [7:0] read0, read1, read2, read3, read4, read5, read6, read7, read8;


reg [7:0] mem[0:width][0:height];

always @(posedge clk) begin

    mem[write_w][write_h] <= write;
    read0 <= mem[read_w0][read_h0];
    read1 <= mem[read_w1][read_h1];
    read2 <= mem[read_w2][read_h2];
    read3 <= mem[read_w3][read_h3];
    read4 <= mem[read_w4][read_h4];
    read5 <= mem[read_w5][read_h5];
    read6 <= mem[read_w6][read_h6];
    read7 <= mem[read_w7][read_h7];
    read8 <= mem[read_w8][read_h8];

end

endmodule

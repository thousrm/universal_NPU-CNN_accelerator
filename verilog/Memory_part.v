
module memory_part
#(

parameter width = 57,
parameter height = 8

parameter width_b = 6,
parameter height_b = 3

)

(
write_w, write_h, write,

readi_w, readi_h, readi,

readw_w, readw,

fmap, weight

en, set, clk
);

parameter step0 = width - 9;
parameter step1 = width - 18;
parameter step2 = width - 27;
parameter step3 = width - 36;
parameter step4 = width - 45;
parameter step5 = width - 49;


input [width_b-1:0]  write_w;
input [height_b-1:0]  write_h;
input [8*9-1:0] write;

input [2:0] readi_w;
input [height_b*9-1:0]  readi_h;

input [width_b-1:0] count;

input en, clk;

output[8*9-1:0] fmap;
output[8*9*8-1:0] weight;



wire [width_b-1:0]  readi_w0, readi_w1, readi_w2, readi_w3, readi_w4, readi_w5, readi_w6, readi_w7, readi_w8;
wire [height_b-1:0]  readi_h0, readi_h1, readi_h2, readi_h3, readi_h4, readi_h5, readi_h6, readi_h7, readi_h8;
reg [7:0] readi0, readi1, readi2, readi3, readi4, readi5, readi6, readi7, readi8;

reg [8*9-1:0] readw0, readw1, readw2, readw3, readw4, readw5, readw6, readw7, readw8;

reg [2:0] count_p;

assign {readi_w0, readi_w1, readi_w2, readi_w3, readi_w4, readi_w5, readi_w6, readi_w7, readi_w8} = readi_w;
assign {readi_h0, readi_h1, readi_h2, readi_h3, readi_h4, readi_h5, readi_h6, readi_h7, readi_h8} = readi_h;


assign fmap = {readi0, readi1, readi2, readi3, readi4, readi5, readi6, readi7, readi8};
assign weight = {readw0, readw1, readw2, readw3, readw4, readw5, readw6, readw7, readw8};




reg [7:0] mem[0:width-1][0:height-1];

always @(posedge clk) begin

    readi0 <= mem[readi_w0][readi_h0];
    readi1 <= mem[readi_w1][readi_h1];
    readi2 <= mem[readi_w2][readi_h2];
    readi3 <= mem[readi_w3][readi_h3];
    readi4 <= mem[readi_w4][readi_h4];
    readi5 <= mem[readi_w5][readi_h5];
    readi6 <= mem[readi_w6][readi_h6];
    readi7 <= mem[readi_w7][readi_h7];
    readi8 <= mem[readi_w8][readi_h8];

    if (en == 1) begin
        if (set == 1) begin
            case(count)




            endcase
        end
    end

end

endmodule

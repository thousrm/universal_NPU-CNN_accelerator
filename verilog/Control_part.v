
module control_part(data_in, en_in, set, type, // from ram

                    write_w, write_h, write, // to mem
                    readi_w, readi_h,
                    step, en_out

                    biases, // from mem

                    bias, // to pe

                    clk, reset
                    );

parameter width = 63;
parameter height = 8;

parameter width_b = 6;
parameter height_b = 3;

parameter step0 = width - 9;
parameter step1 = width - 18;
parameter step2 = width - 27;
parameter step3 = width - 36;
parameter step4 = width - 45;
parameter step5 = width - 54;

parameter bias = 2;

input [8*9-1:0] data_in;
input en_in, set;
input [2:0] type;
input clk;

output [width_b-1:0]  write_w;
output [height_b-1:0]  write_h;
output [8*9-1:0] write;

output [width_b*9-1:0] readi_w;
output [height_b*9-1:0]  readi_h;

output [2:0] step;
output [8:0] en_out;

input [16*8-1:0] biases;
output [16*8-1:0] bias;



reg [width_b-1:0]  readi_w0, readi_w1, readi_w2, readi_w3, readi_w4, readi_w5, readi_w6, readi_w7, readi_w8;
reg [height_b-1:0]  readi_h0, readi_h1, readi_h2, readi_h3, readi_h4, readi_h5, readi_h6, readi_h7, readi_h8;

assign readi_w = {readi_w0, readi_w1, readi_w2, readi_w3, readi_w4, readi_w5, readi_w6, readi_w7, readi_w8};
assign readi_h = {readi_h0, readi_h1, readi_h2, readi_h3, readi_h4, readi_h5, readi_h6, readi_h7, readi_h8};

reg [2:0] type_c;
reg [2:0] count;

//write
always @(posedge clk) begin
    if (reset == 0) begin
        type_c <= 0;
        count <= 0;
    end
    else begin
        if (en == 1) begin
            if (set == 1) begin
                type_c <= type;
                count <= count + 1;
                if ()

        end
    end
end

always @(*) begin
    if ()


assign write = data_in;


        



end

endmodule

module memory_part
#(

parameter width = 80,
parameter height = 8,

parameter width_b = 7,
parameter height_b = 3

)

(
    write_w, write_h, write, // from mem
    readi_w, readi_h,
    step, en,

    fmap, biases,  // to control

    weight, // to ar

    clk

);

parameter step0 = width - 9;
parameter step1 = width - 18;
parameter step2 = width - 27;
parameter step3 = width - 36;
parameter step4 = width - 45;
parameter step5 = width - 54;

parameter bias = 2;


input [width_b-1:0]  write_w;
input [height_b-1:0]  write_h;
input [8*9-1:0] write;

input [width_b*9-1:0] readi_w;
input [height_b*9-1:0]  readi_h;

input [2:0] step;
input [8:0] en;
input clk;

output [8*9-1:0] fmap;
output [8*9*8-1:0] weight;
output [16*8-1:0] biases;



wire [width_b-1:0]  readi_w0, readi_w1, readi_w2, readi_w3, readi_w4, readi_w5, readi_w6, readi_w7, readi_w8;
wire [height_b-1:0]  readi_h0, readi_h1, readi_h2, readi_h3, readi_h4, readi_h5, readi_h6, readi_h7, readi_h8;
reg [7:0] readi0, readi1, readi2, readi3, readi4, readi5, readi6, readi7, readi8;

reg [8*9-1:0] readw0, readw1, readw2, readw3, readw4, readw5, readw6, readw7;

assign {readi_w0, readi_w1, readi_w2, readi_w3, readi_w4, readi_w5, readi_w6, readi_w7, readi_w8} = readi_w;
assign {readi_h0, readi_h1, readi_h2, readi_h3, readi_h4, readi_h5, readi_h6, readi_h7, readi_h8} = readi_h;


assign fmap = {readi0, readi1, readi2, readi3, readi4, readi5, readi6, readi7, readi8};
assign weight = {readw0, readw1, readw2, readw3, readw4, readw5, readw6, readw7};


reg [7:0] mem[0:width-1+bias][0:height-1];

    // read bias
assign biases = {mem[width-1+bias-1][0], mem[width-1+bias][0], 
             mem[width-1+bias-1][1], mem[width-1+bias][1], 
             mem[width-1+bias-1][2], mem[width-1+bias][2], 
             mem[width-1+bias-1][3], mem[width-1+bias][3], 
             mem[width-1+bias-1][4], mem[width-1+bias][4], 
             mem[width-1+bias-1][5], mem[width-1+bias][5], 
             mem[width-1+bias-1][6], mem[width-1+bias][6], 
             mem[width-1+bias-1][7], mem[width-1+bias][7]};






always @(posedge clk) begin
    // read feature map
    readi0 <= mem[readi_w0][readi_h0];
    readi1 <= mem[readi_w1][readi_h1];
    readi2 <= mem[readi_w2][readi_h2];
    readi3 <= mem[readi_w3][readi_h3];
    readi4 <= mem[readi_w4][readi_h4];
    readi5 <= mem[readi_w5][readi_h5];
    readi6 <= mem[readi_w6][readi_h6];
    readi7 <= mem[readi_w7][readi_h7];
    readi8 <= mem[readi_w8][readi_h8];

    // read weights
    case(step)
        3'b001 : begin
            readw0 <= {mem[step1][0], mem[step1+1][0], mem[step1+2][0], mem[step1+3][0], mem[step1+4][0], mem[step1+5][0], mem[step1+6][0], mem[step1+7][0], mem[step1+8][0]};
            readw1 <= {mem[step1][1], mem[step1+1][1], mem[step1+2][1], mem[step1+3][1], mem[step1+4][1], mem[step1+5][1], mem[step1+6][1], mem[step1+7][1], mem[step1+8][1]};
            readw2 <= {mem[step1][2], mem[step1+1][2], mem[step1+2][2], mem[step1+3][2], mem[step1+4][2], mem[step1+5][2], mem[step1+6][2], mem[step1+7][2], mem[step1+8][2]};
            readw3 <= {mem[step1][3], mem[step1+1][3], mem[step1+2][3], mem[step1+3][3], mem[step1+4][3], mem[step1+5][3], mem[step1+6][3], mem[step1+7][3], mem[step1+8][3]};
            readw4 <= {mem[step1][4], mem[step1+1][4], mem[step1+2][4], mem[step1+3][4], mem[step1+4][4], mem[step1+5][4], mem[step1+6][4], mem[step1+7][4], mem[step1+8][4]};
            readw5 <= {mem[step1][5], mem[step1+1][5], mem[step1+2][5], mem[step1+3][5], mem[step1+4][5], mem[step1+5][5], mem[step1+6][5], mem[step1+7][5], mem[step1+8][5]};
            readw6 <= {mem[step1][6], mem[step1+1][6], mem[step1+2][6], mem[step1+3][6], mem[step1+4][6], mem[step1+5][6], mem[step1+6][6], mem[step1+7][6], mem[step1+8][6]};
            readw7 <= {mem[step1][7], mem[step1+1][7], mem[step1+2][7], mem[step1+3][7], mem[step1+4][7], mem[step1+5][7], mem[step1+6][7], mem[step1+7][7], mem[step1+8][7]};
        end
        3'b010 : begin
            readw0 <= {mem[step2][0], mem[step2+1][0], mem[step2+2][0], mem[step2+3][0], mem[step2+4][0], mem[step2+5][0], mem[step2+6][0], mem[step2+7][0], mem[step2+8][0]};
            readw1 <= {mem[step2][1], mem[step2+1][1], mem[step2+2][1], mem[step2+3][1], mem[step2+4][1], mem[step2+5][1], mem[step2+6][1], mem[step2+7][1], mem[step2+8][1]};
            readw2 <= {mem[step2][2], mem[step2+1][2], mem[step2+2][2], mem[step2+3][2], mem[step2+4][2], mem[step2+5][2], mem[step2+6][2], mem[step2+7][2], mem[step2+8][2]};
            readw3 <= {mem[step2][3], mem[step2+1][3], mem[step2+2][3], mem[step2+3][3], mem[step2+4][3], mem[step2+5][3], mem[step2+6][3], mem[step2+7][3], mem[step2+8][3]};
            readw4 <= {mem[step2][4], mem[step2+1][4], mem[step2+2][4], mem[step2+3][4], mem[step2+4][4], mem[step2+5][4], mem[step2+6][4], mem[step2+7][4], mem[step2+8][4]};
            readw5 <= {mem[step2][5], mem[step2+1][5], mem[step2+2][5], mem[step2+3][5], mem[step2+4][5], mem[step2+5][5], mem[step2+6][5], mem[step2+7][5], mem[step2+8][5]};
            readw6 <= {mem[step2][6], mem[step2+1][6], mem[step2+2][6], mem[step2+3][6], mem[step2+4][6], mem[step2+5][6], mem[step2+6][6], mem[step2+7][6], mem[step2+8][6]};
            readw7 <= {mem[step2][7], mem[step2+1][7], mem[step2+2][7], mem[step2+3][7], mem[step2+4][7], mem[step2+5][7], mem[step2+6][7], mem[step2+7][7], mem[step2+8][7]};
        end
        3'b011 : begin
            readw0 <= {mem[step3][0], mem[step3+1][0], mem[step3+2][0], mem[step3+3][0], mem[step3+4][0], mem[step3+5][0], mem[step3+6][0], mem[step3+7][0], mem[step3+8][0]};
            readw1 <= {mem[step3][1], mem[step3+1][1], mem[step3+2][1], mem[step3+3][1], mem[step3+4][1], mem[step3+5][1], mem[step3+6][1], mem[step3+7][1], mem[step3+8][1]};
            readw2 <= {mem[step3][2], mem[step3+1][2], mem[step3+2][2], mem[step3+3][2], mem[step3+4][2], mem[step3+5][2], mem[step3+6][2], mem[step3+7][2], mem[step3+8][2]};
            readw3 <= {mem[step3][3], mem[step3+1][3], mem[step3+2][3], mem[step3+3][3], mem[step3+4][3], mem[step3+5][3], mem[step3+6][3], mem[step3+7][3], mem[step3+8][3]};
            readw4 <= {mem[step3][4], mem[step3+1][4], mem[step3+2][4], mem[step3+3][4], mem[step3+4][4], mem[step3+5][4], mem[step3+6][4], mem[step3+7][4], mem[step3+8][4]};
            readw5 <= {mem[step3][5], mem[step3+1][5], mem[step3+2][5], mem[step3+3][5], mem[step3+4][5], mem[step3+5][5], mem[step3+6][5], mem[step3+7][5], mem[step3+8][5]};
            readw6 <= {mem[step3][6], mem[step3+1][6], mem[step3+2][6], mem[step3+3][6], mem[step3+4][6], mem[step3+5][6], mem[step3+6][6], mem[step3+7][6], mem[step3+8][6]};
            readw7 <= {mem[step3][7], mem[step3+1][7], mem[step3+2][7], mem[step3+3][7], mem[step3+4][7], mem[step3+5][7], mem[step3+6][7], mem[step3+7][7], mem[step3+8][7]};
        end
        3'b100 : begin
            readw0 <= {mem[step4][0], mem[step4+1][0], mem[step4+2][0], mem[step4+3][0], mem[step4+4][0], mem[step4+5][0], mem[step4+6][0], mem[step4+7][0], mem[step4+8][0]};
            readw1 <= {mem[step4][1], mem[step4+1][1], mem[step4+2][1], mem[step4+3][1], mem[step4+4][1], mem[step4+5][1], mem[step4+6][1], mem[step4+7][1], mem[step4+8][1]};
            readw2 <= {mem[step4][2], mem[step4+1][2], mem[step4+2][2], mem[step4+3][2], mem[step4+4][2], mem[step4+5][2], mem[step4+6][2], mem[step4+7][2], mem[step4+8][2]};
            readw3 <= {mem[step4][3], mem[step4+1][3], mem[step4+2][3], mem[step4+3][3], mem[step4+4][3], mem[step4+5][3], mem[step4+6][3], mem[step4+7][3], mem[step4+8][3]};
            readw4 <= {mem[step4][4], mem[step4+1][4], mem[step4+2][4], mem[step4+3][4], mem[step4+4][4], mem[step4+5][4], mem[step4+6][4], mem[step4+7][4], mem[step4+8][4]};
            readw5 <= {mem[step4][5], mem[step4+1][5], mem[step4+2][5], mem[step4+3][5], mem[step4+4][5], mem[step4+5][5], mem[step4+6][5], mem[step4+7][5], mem[step4+8][5]};
            readw6 <= {mem[step4][6], mem[step4+1][6], mem[step4+2][6], mem[step4+3][6], mem[step4+4][6], mem[step4+5][6], mem[step4+6][6], mem[step4+7][6], mem[step4+8][6]};
            readw7 <= {mem[step4][7], mem[step4+1][7], mem[step4+2][7], mem[step4+3][7], mem[step4+4][7], mem[step4+5][7], mem[step4+6][7], mem[step4+7][7], mem[step4+8][7]};
        end
        3'b101 : begin
            readw0 <= {mem[step5][0], mem[step5+1][0], mem[step5+2][0], mem[step5+3][0], mem[step5+4][0], mem[step5+5][0], mem[step5+6][0], mem[step5+7][0], mem[step5+8][0]};
            readw1 <= {mem[step5][1], mem[step5+1][1], mem[step5+2][1], mem[step5+3][1], mem[step5+4][1], mem[step5+5][1], mem[step5+6][1], mem[step5+7][1], mem[step5+8][1]};
            readw2 <= {mem[step5][2], mem[step5+1][2], mem[step5+2][2], mem[step5+3][2], mem[step5+4][2], mem[step5+5][2], mem[step5+6][2], mem[step5+7][2], mem[step5+8][2]};
            readw3 <= {mem[step5][3], mem[step5+1][3], mem[step5+2][3], mem[step5+3][3], mem[step5+4][3], mem[step5+5][3], mem[step5+6][3], mem[step5+7][3], mem[step5+8][3]};
            readw4 <= {mem[step5][4], mem[step5+1][4], mem[step5+2][4], mem[step5+3][4], mem[step5+4][4], mem[step5+5][4], mem[step5+6][4], mem[step5+7][4], mem[step5+8][4]};
            readw5 <= {mem[step5][5], mem[step5+1][5], mem[step5+2][5], mem[step5+3][5], mem[step5+4][5], mem[step5+5][5], mem[step5+6][5], mem[step5+7][5], mem[step5+8][5]};
            readw6 <= {mem[step5][6], mem[step5+1][6], mem[step5+2][6], mem[step5+3][6], mem[step5+4][6], mem[step5+5][6], mem[step5+6][6], mem[step5+7][6], mem[step5+8][6]};
            readw7 <= {mem[step5][7], mem[step5+1][7], mem[step5+2][7], mem[step5+3][7], mem[step5+4][7], mem[step5+5][7], mem[step5+6][7], mem[step5+7][7], mem[step5+8][7]};
        end
        default : begin
            readw0 <= {mem[step0][0], mem[step0+1][0], mem[step0+2][0], mem[step0+3][0], mem[step0+4][0], mem[step0+5][0], mem[step0+6][0], mem[step0+7][0], mem[step0+8][0]};
            readw1 <= {mem[step0][1], mem[step0+1][1], mem[step0+2][1], mem[step0+3][1], mem[step0+4][1], mem[step0+5][1], mem[step0+6][1], mem[step0+7][1], mem[step0+8][1]};
            readw2 <= {mem[step0][2], mem[step0+1][2], mem[step0+2][2], mem[step0+3][2], mem[step0+4][2], mem[step0+5][2], mem[step0+6][2], mem[step0+7][2], mem[step0+8][2]};
            readw3 <= {mem[step0][3], mem[step0+1][3], mem[step0+2][3], mem[step0+3][3], mem[step0+4][3], mem[step0+5][3], mem[step0+6][3], mem[step0+7][3], mem[step0+8][3]};
            readw4 <= {mem[step0][4], mem[step0+1][4], mem[step0+2][4], mem[step0+3][4], mem[step0+4][4], mem[step0+5][4], mem[step0+6][4], mem[step0+7][4], mem[step0+8][4]};
            readw5 <= {mem[step0][5], mem[step0+1][5], mem[step0+2][5], mem[step0+3][5], mem[step0+4][5], mem[step0+5][5], mem[step0+6][5], mem[step0+7][5], mem[step0+8][5]};
            readw6 <= {mem[step0][6], mem[step0+1][6], mem[step0+2][6], mem[step0+3][6], mem[step0+4][6], mem[step0+5][6], mem[step0+6][6], mem[step0+7][6], mem[step0+8][6]};
            readw7 <= {mem[step0][7], mem[step0+1][7], mem[step0+2][7], mem[step0+3][7], mem[step0+4][7], mem[step0+5][7], mem[step0+6][7], mem[step0+7][7], mem[step0+8][7]};
        end
    endcase


    //write
    if (en[8] == 1) begin
        mem[write_w][write_h] <= write[8*9-1-:8];
    end

    if (en[7] == 1) begin
        mem[write_w+1][write_h] <= write[8*9-1-1*8-:8];
    end

    if (en[6] == 1) begin
        mem[write_w+2][write_h] <= write[8*9-1-2*8-:8];
    end

    if (en[5] == 1) begin
        mem[write_w+3][write_h] <= write[8*9-1-3*8-:8];
    end

    if (en[4] == 1) begin
        mem[write_w+4][write_h] <= write[8*9-1-4*8-:8];
    end

    if (en[3] == 1) begin
        mem[write_w+5][write_h] <= write[8*9-1-5*8-:8];
    end

    if (en[2] == 1) begin
        mem[write_w+6][write_h] <= write[8*9-1-6*8-:8];
    end

    if (en[1] == 1) begin
        mem[write_w+7][write_h] <= write[8*9-1-7*8-:8];
    end

    if (en[0] == 1) begin
        mem[write_w+8][write_h] <= write[8*9-1-8*8-:8]; 
    end    
            


end

endmodule

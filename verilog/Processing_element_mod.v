
module PE_m(in, weight, bias, bound_level, step, en, out, out_en, clk, reset);

parameter cell_bit = 8;
parameter N_cell = 9;
parameter biasport = 16;
parameter outport = 8;

parameter outport_mul = 16;
parameter outport_add = 17;

input [cell_bit*N_cell-1:0] in;
input [cell_bit*N_cell-1:0] weight;
input signed [biasport-1:0] bias;
output signed [outport-1:0] out;

input clk, reset;

wire signed [cell_bit-1:0] inp[0:N_cell-1];
wire signed [cell_bit-1:0] wei[0:N_cell-1];

wire signed [outport_mul-1:0] mulout[0:N_cell-1];
wire signed [outport_mul-1:0] d_mulout[0:N_cell-1];
wire signed [outport_add-1:0] addout[0:4];
wire signed [outport_add:0] addout_1[0:3];

genvar i;
generate
for(i=0; i<N_cell; i=i+1) begin : app
    assign inp[i] = in[cell_bit*N_cell-1 - cell_bit*i -: cell_bit];
    assign wei[i] = weight[cell_bit*N_cell-1 - cell_bit*i -: cell_bit];
    M_8 M8(inp[i], wei[i], mulout[i]);
end
endgenerate


input en;
wire en_d;
input [1:0] bound_level;
wire [1:0] bound_level_d;
input [2:0] step;
wire [2:0] step_d;
wire signed [biasport-1:0] bias_d;

D_FF144 FF0 ({mulout[0], mulout[1], mulout[2], mulout[3], mulout[4], mulout[5], mulout[6], mulout[7], mulout[8]},           
                {d_mulout[0], d_mulout[1], d_mulout[2], d_mulout[3], d_mulout[4], d_mulout[5], d_mulout[6], d_mulout[7], d_mulout[8]},
                 clk, reset);

D_FF1 F3 (en, en_d, clk, reset);
D_FF3 F9 (step, step_d, clk, reset);
D_FF2 F8 (bound_level, bound_level_d, clk, reset);
D_FF16 F_bias(bias, bias_d, clk, reset);


/////////////////////////////////////////////
//clk+1
/////////////////////////////////////////////



A_16 A0 (bias, d_mulout[0], addout[0]);
A_16 A1 (d_mulout[1], d_mulout[2], addout[1]);
A_16 A2 (d_mulout[3], d_mulout[4], addout[2]);
A_16 A3 (d_mulout[5], d_mulout[6], addout[3]);
A_16 A4 (d_mulout[7], d_mulout[8], addout[4]);

A_17 A5 (addout[0], addout[1], addout_1[0]);
A_17 A6 (addout[2], addout[3], addout_1[1]);

A_18_f A7 (addout_1[0], addout_1[1], addout_1[2]);

A_18_f A8 ({addout[4][outport_add-1], addout[4]}, addout_1[2], addout_1[3]);


//assign out = addout_1[3][outport_add-:outport];


////////////////
//adder tree end, output = addout_1[3]
////////////////


////////////////
//set bound
////////////////

wire signed [outport-1:0] b_out;
wire uxnor[1:3], uand[1:2]; 
assign b_out[7] = addout_1[3][outport_add]; //MSB

assign uxnor[1] = addout_1[3][outport_add] ~^ addout_1[3][outport_add-1];
assign uxnor[2] = addout_1[3][outport_add-1] ~^ addout_1[3][outport_add-2];
assign uxnor[3] = addout_1[3][outport_add-2] ~^ addout_1[3][outport_add-3];

assign uand[1] = uxnor[1] & uxnor[2];
assign uand[2] = uand[1] & uxnor[3];

assign b_out[6:0] = bound_level_d == 2'b01 ?
                    uxnor[1] == 1'b0 ? {~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add],
                                ~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add]}
                                : addout_1[3][outport_add-2-:7]
                : bound_level_d == 2'b10 ?
                    uand[1] == 1'b0 ? {~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add],
                                ~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add]}
                                : addout_1[3][outport_add-3-:7]
                : bound_level_d == 2'b11 ?
                    uand[2] == 1'b0 ? {~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add],
                                ~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add], ~addout_1[3][outport_add]}
                                : addout_1[3][outport_add-4-:7]
                : addout_1[3][outport_add-1-:7];



////////////////
//set bound end, output = b_out
////////////////

////////////////
//multiple clk adder start
////////////////


reg [2:0] p_step;
reg mux_f_s;
//reg out_en_b;
output reg out_en;

/// counter
always @(posedge clk) begin
    if(reset == 0) begin
        p_step <= 3'b000;
        mux_f_s <= 1'b0;
        out_en <= 1'b0;
    end
    else if (en_d == 1) begin
        if (p_step == step_d) begin
            p_step <= 3'b000;
            out_en <= 1'b1;
            mux_f_s <= 1'b0;
        end
        else begin
            p_step <= p_step +1;
            out_en <= 1'b0;
            mux_f_s <= 1'b1;
        end
    end
    else  begin
        mux_f_s <= mux_f_s;
        out_en <= 1'b0;
    end
end

//adder

wire signed [outport-1:0] adder_final_B, adder_final_out;

assign adder_final_B = mux_f_s ? out : 8'b0000_0000;

A_8_f A_final(b_out, adder_final_B, adder_final_out);


wire signed [outport-1:0] out_ck_en;
assign out_ck_en = en_d ? adder_final_out : out;

///clk+2
D_FF8 F1 (out_ck_en, out, clk, reset);

//D_FF1 F2 (out_en_b, out_en, clk, reset);





endmodule
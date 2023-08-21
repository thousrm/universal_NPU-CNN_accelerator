module PE(in, weight, bias, bound_level, step, en, out, out_en, clk, reset);

parameter cell_bit = 8;
parameter N_cell = 9;
parameter biasport = 16;
parameter outport = 8;

parameter outport_add = 14;

input [cell_bit*N_cell-1:0] in;
input [cell_bit*N_cell-1:0] weight;
input signed [biasport-1:0] bias;
output signed [outport-1:0] out;

input clk, reset;


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


multiplier M0(in, weight,
                        O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0);

addertree_stage1 AT10(O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0, 
                        bias,
                        ao18, ao17, ao16, ao15, ao14, ao13, ao12, ao11, ao10, ao9, ao8, ao7, ao6, ao5, ao4, ao3);

/////////////////////////////////////////////
//clk+1
/////////////////////////////////////////////

wire ao18_d;
wire [1:0] ao17_d;
wire [2:0] ao16_d;
wire [4:0] ao15_d, ao14_d;
wire [6:0] ao13_d;
wire [8:0] ao12_d;
wire [9:0] ao11_d;
wire [10:0] ao10_d;
wire [11:0] ao9_d;
wire [10:0] ao8_d;
wire [9:0] ao7_d;
wire [9:0] ao6_d;
wire [8:0] ao5_d;
wire [7:0] ao4_d;
wire [5:0] ao3_d;


input en;
wire en_d;
input [2:0] bound_level;
wire [2:0] bound_level_d;
input [2:0] step;
wire [2:0] step_d;
wire signed [biasport-1:0] bias_d;
wire [outport_add-2:0] pre_output;

D_FF119 FF0 ({ao18, ao17, ao16, ao15, ao14, ao13, ao12, ao11, ao10, ao9, ao8, ao7, ao6, ao5, ao4, ao3},           
                {ao18_d, ao17_d, ao16_d, ao15_d, ao14_d, ao13_d, ao12_d, ao11_d, ao10_d, ao9_d, ao8_d, ao7_d, ao6_d, ao5_d, ao4_d, ao3_d},
                 clk, reset);
D_FF1 F3 (en, en_d, clk, reset);
D_FF3 F9 (step, step_d, clk, reset);
D_FF3 F8 (bound_level, bound_level_d, clk, reset);


wire o19;
wire [2:0] o18, o17;
wire [3:0] o16, o15, o14, o13, o12, o11, o10, o9, o8, o7;
wire [2:0] o6, o5;
wire [1:0] o4;
wire o3;

wire [1:0] a19, a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, a7, a6;
wire a5; 

wire [outport_add-1:0] addout;

addertree_stage2 AT20(ao18_d, ao17_d, ao16_d, ao15_d, ao14_d, ao13_d, ao12_d, ao11_d, ao10_d, ao9_d, ao8_d, ao7_d, ao6_d, ao5_d, ao4_d, ao3_d,
                    pre_output,
                    o19, o18, o17, o16, o15, o14, o13, o12, o11, o10, o9, o8, o7, o6, o5, o4, o3
                    );

addertree_stage3 AT30(o19, o18, o17, o16, o15, o14, o13, o12, o11, o10, o9, o8, o7, o6, o5, o4, o3,
                    a19, a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5
                    );

adder_final AF0(a19, a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, a7, a6,
                    addout);



////////////////
//adder tree end, output = addout
////////////////


////////////////
//set bound
////////////////

wire signed [outport-1:0] b_out;
wire oxor[0:5], chk_over[0:5]; 
assign b_out[7] = addout[outport_add-1]; //MSB

assign oxor[0] = addout[outport_add-1] ~^ addout[outport_add-2];
assign oxor[1] = addout[outport_add-2] ~^ addout[outport_add-3];
assign oxor[2] = addout[outport_add-3] ~^ addout[outport_add-4];
assign oxor[3] = addout[outport_add-4] ~^ addout[outport_add-5];
assign oxor[4] = addout[outport_add-5] ~^ addout[outport_add-6];
assign oxor[5] = addout[outport_add-6] ~^ addout[outport_add-7];

assign chk_over[0] = oxor[0];
assign chk_over[1] = oxor[0] & oxor[1];
assign chk_over[2] = oxor[0] & oxor[1] & oxor[2];
assign chk_over[3] = oxor[0] & oxor[1] & oxor[2] & oxor[3];
assign chk_over[4] = oxor[0] & oxor[1] & oxor[2] & oxor[3] & oxor[4];
assign chk_over[5] = oxor[0] & oxor[1] & oxor[2] & oxor[3] & oxor[4] & oxor[5];

assign b_out[6:0] =   bound_level_d == 3'b001 ?
                            chk_over[1] == 1'b0 ? {7{~addout[outport_add]}}
                                : addout[outport_add-4-:7]

                    : bound_level_d == 3'b010 ?
                            chk_over[2] == 1'b0 ? {7{~addout[outport_add]}}
                                : addout[outport_add-5-:7]
                    
                    : bound_level_d == 3'b011 ?
                            chk_over[3] == 1'b0 ? {7{~addout[outport_add]}}
                                : addout[outport_add-6-:7]
                    : bound_level_d == 3'b100 ?
                            chk_over[4] == 1'b0 ? {7{~addout[outport_add]}}
                                : addout[outport_add-7-:7]
                    : bound_level_d == 3'b101 ?
                            chk_over[5] == 1'b0 ? {7{~addout[outport_add]}}
                                : addout[outport_add-8-:7]
                    
                    : chk_over[0] == 1'b0 ? {7{~addout[outport_add]}}
                                : addout[outport_add-3-:7];

wire signed [outport-1:0] pre_output_b;

assign pre_output[outport_add-2] = pre_output_b[7];
assign pre_output[outport_add-3:0] =   bound_level_d == 3'b001 ? {pre_output_b[7], pre_output_b[6:0], 4'b0000}
                                    :  bound_level_d == 3'b010 ? {pre_output_b[7], pre_output_b[7], pre_output_b[6:0], 3'b000}
                                    :  bound_level_d == 3'b010 ? {pre_output_b[7], pre_output_b[7], pre_output_b[7], pre_output_b[6:0], 2'b00}
                                    :  bound_level_d == 3'b010 ? {pre_output_b[7], pre_output_b[7], pre_output_b[7], pre_output_b[7], pre_output_b[6:0], 1'b0}
                                    :  bound_level_d == 3'b010 ? {pre_output_b[7], pre_output_b[7], pre_output_b[7], pre_output_b[7], pre_output_b[7], pre_output_b[6:0]}
                                    :  {pre_output_b[6:0], 5'b00000};




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
        mux_f_s <= 0;
        out_en <= 1'b0;
    end
end

//adder



assign pre_output_b = mux_f_s ? out : 8'b0000_0000;


///clk+2
D_FF8 F1 (b_out, out, clk, reset);

//D_FF1 F2 (out_en_b, out_en, clk, reset);





endmodule
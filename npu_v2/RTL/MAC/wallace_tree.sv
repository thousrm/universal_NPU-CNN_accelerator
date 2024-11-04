module wallace_tree
# (
    parameter W = 28,
    parameter N = 16
)
(
    input  logic [N*W-1:0] i_data_array,
    output logic [32 -1:0] o_data
);

function automatic [2:0] add_7;
    input [6:0] in;
    
    logic x1, x2, x3, x4, x5, x6, x7;
    logic and12, xor12, and34, xor34, and56, xor56;
    logic and4, xor4, and5, xor5, and6, xor6;
    logic xor10, xor7;
    logic and8, xor8, and9, xor9;
    logic xor12_, and11, xor11, xor13;
    logic cout, carry, sum;

    {x1, x2, x3, x4, x5, x6, x7} = in;

    and12 = x1 & x2;
    xor12 = x1 ^ x2;
    and34 = x3 & x4;
    xor34 = x3 ^ x4;
    and56 = x5 & x6;
    xor56 = x5 ^ x6;

    and4 = and12 & and34;
    xor4 = and12 ^ and34;
    and5 = xor12 & xor34;
    xor5 = xor12 ^ xor34;
    and6 = x7 & xor56;
    xor6 = x7 ^ xor56;

    xor10 = xor4 ^ and5;
    xor7 = and56 ^ and6;

    and8 = xor5 & xor6;
    xor8 = xor5 ^ xor6;
    and9 = xor10 & xor7;
    xor9 = xor10 ^ xor7;

    and11 = xor9 & and8;
    xor12_ = and9 ^ and11;
    xor11 = xor9 ^ and8;
    xor13 = xor12_ ^ and4;

    sum = xor8;
    carry = xor11;
    cout = xor13;

    add_7 = {cout, carry, sum};
endfunction

function automatic [2:0] add_6;
    input [5:0] in;
    
    logic x1, x2, x3, x4, x5, x6;
    logic and12, xor12, and34, xor34, and56, xor56;
    logic and4, xor4, and5, xor5, xor6;
    logic xor10, xor7;
    logic and8, xor8, and9, xor9;
    logic xor12_, and11, xor11, xor13;
    logic cout, carry, sum;

    {x1, x2, x3, x4, x5, x6} = in;

    and12 = x1 & x2;
    xor12 = x1 ^ x2;
    and34 = x3 & x4;
    xor34 = x3 ^ x4;
    and56 = x5 & x6;
    xor56 = x5 ^ x6;

    and4 = and12 & and34;
    xor4 = and12 ^ and34;
    and5 = xor12 & xor34;
    xor5 = xor12 ^ xor34;
    xor6 = xor56;

    xor10 = xor4 ^ and5;
    xor7 = and56;

    and8 = xor5 & xor6;
    xor8 = xor5 ^ xor6;
    and9 = xor10 & xor7;
    xor9 = xor10 ^ xor7;

    and11 = xor9 & and8;
    xor12_ = and9 ^ and11;
    xor11 = xor9 ^ and8;
    xor13 = xor12_ ^ and4;

    sum = xor8;
    carry = xor11;
    cout = xor13;

    add_6 = {cout, carry, sum};
endfunction

function automatic [2:0] add_5;
    input [4:0] in;
    
    logic x0, x1, x2, x3, x4;
    logic y0, y1, y2, y3;
    logic sand0, sand1, sxor0;
    logic mux0, cor0, cand0;
    logic cout, carry, sum;

    {x0, x1, x2, x3, x4} = in;

    y0 = x4 | x3;
    y1 = x4 & x3;
    y2 = x2 | x1;
    y3 = x2 & x1;

    sand0 = y2 & (~y3);
    sand1 = y0 & (~y1);
    sxor0 = sand0 ^ sand1;
    sum = sxor0 ^ x0;

    mux0 = sxor0 ? x0 : y3;

    cor0 = y1 | y2;
    cand0 = y0 & cor0;

    carry = mux0 ^ cand0;
    cout = mux0 & cand0;

    add_5 = {cout, carry, sum};
endfunction

function automatic [2:0] add_4;
    input [3:0] in;
    
    logic x0, x1, x2, x3;
    logic s0, c0, c1;
    logic cout, carry, sum;
    logic [1:0] fa_result, ha_result1, ha_result2;

    {x0, x1, x2, x3} = in;

    fa_result = x0 + x1 + x2;
    s0 = fa_result[0];
    c0 = fa_result[1];

    ha_result1 = x3 + s0;
    sum = ha_result1[0];
    c1 = ha_result1[1];

    ha_result2 = c0 + c1;
    carry = ha_result2[0];
    cout = ha_result2[1];

    add_4 = {cout, carry, sum};
endfunction

function automatic [1:0] add_3;
    input [2:0] in;

    add_3 = in[0] + in[1] + in[2];
endfunction

function automatic [1:0] add_2;
    input [1:0] in;

    add_2 = in[0] + in[1];
endfunction

logic [N-1:0] bit_data [0:W-1];

generate
    for (genvar i=0; i<W; i++) begin : decoding_input_W
        for (genvar j=0; j<N; j++) begin : decoding_input_N
            assign bit_data[i][j] = i_data_array[i+j*W];
        end
    end
endgenerate

/////////////
/// stage1
/////////////
logic [7:0] stage1 [0:29];
logic [7:0] stage1_aligned [0:29];

generate
    for (genvar i=0; i<28; i++) begin : stage_1_0
        assign    {stage1[i+2][2], stage1[i+1][1], stage1[i][0]} = add_7(bit_data[i][ 6:0]);
        assign    {stage1[i+2][5], stage1[i+1][4], stage1[i][3]} = add_7(bit_data[i][13:7]);
        assign    stage1[i][7:6] = bit_data[i][N-1:N-2];
    end
endgenerate

generate
    for (genvar i=2; i<28; i++) begin : stage_1_align
        assign stage1_aligned[i] = stage1[i];
    end
endgenerate

assign stage1_aligned[0 ][3:0] = {stage1[ 0][7:6], stage1[ 0][3],   stage1[ 0][0]  };
assign stage1_aligned[1 ][5:0] = {stage1[ 1][7:6], stage1[ 1][4:3], stage1[ 1][1:0]};
assign stage1_aligned[28][3:0] = {stage1[28][5:4], stage1[28][2:1]};
assign stage1_aligned[29][1:0] = {stage1[29][  5], stage1[29][  2]};

/////////////
/// stage2
/////////////
logic [3:0] stage2 [0:30];
logic [3:0] stage2_aligned [0:30];

assign {stage2[0+2][2], stage2[0+1][1], stage2[0][0]} = add_4(stage1_aligned[0][ 3:0]);
assign {stage2[1+2][2], stage2[1+1][1], stage2[1][0]} = add_6(stage1_aligned[1][ 5:0]);
generate
    for (genvar i=2; i<28; i++) begin : stage_2_0
        assign    {stage2[i+2][2], stage2[i+1][1], stage2[i][0]} = add_7(stage1_aligned[i][ 6:0]);
        assign    stage2[i][3] = stage1_aligned[i][7];
    end
endgenerate
assign {stage2[28+2][2], stage2[28+1][1], stage2[28][0]} = add_4(stage1_aligned[28][ 3:0]);
assign {stage2[29][0], stage2[29][3]} = stage1_aligned[29][1:0];

generate
    for (genvar i=0; i<30; i++) begin : stage_2_align
        assign stage2_aligned[i] = stage2[i];
    end
endgenerate
assign stage2_aligned[30][0] = stage2[30][2];

/////////////
/// stage3
/////////////
logic [2:0] stage3 [0:31];
logic [2:0] stage3_aligned [0:31];

assign stage3[0][0] = stage2_aligned[0][0];
assign {stage3[1+1][1], stage3[1+0][0]} = add_2(stage2_aligned[1][ 1:0]);
generate
    for (genvar i=2; i<28; i++) begin : stage_3_0
        assign    {stage3[i+2][2], stage3[i+1][1], stage3[i][0]} = add_4(stage2_aligned[i][ 3:0]);
    end
endgenerate
assign {                 stage3[28+1][1], stage3[28][0]} = add_3(stage2_aligned[28][ 2:0]);
assign {stage3[29+2][2], stage3[29+1][1], stage3[29][0]} = add_4(stage2_aligned[29][ 3:0]);
assign stage3[30][0] = stage2_aligned[30];

generate
    for (genvar i=0; i<31; i++) begin : stage_3_align
        assign stage3_aligned[i] = stage3[i];
    end
endgenerate
//assign stage3_aligned[30][0] = stage3[30][0];
assign stage3_aligned[31][0] = stage3[31][2];

/////////////
/// stage3
/////////////
logic [1:0] stage4 [0:31];

assign stage4[0][0] = stage3_aligned[0][0];
assign stage4[1][0] = stage3_aligned[1][0];
assign {stage4[2+1][1], stage4[2+0][0]} = add_2(stage3_aligned[2][ 1:0]);
assign {stage4[3+1][1], stage4[3+0][0]} = add_2(stage3_aligned[3][ 1:0]);
generate
    for (genvar i=4; i<30; i++) begin : stage_4_0
        assign    {stage4[i+1][1], stage4[i][0]} = add_3(stage3_aligned[i][ 2:0]);
    end
endgenerate
assign {stage4[30+1][1], stage4[30+0][0]} = add_2(stage3_aligned[30][ 1:0]);
assign stage4[31][0] = stage3_aligned[31][0];


////////////////////////////
/// final adder 29bit adder
////////////////////////////

// TODO fake version for now

logic [28:0] data_a, data_b;
logic [29:0] pre_out;

generate
    for (genvar i=0; i<29; i++) begin : pre_out_parsing
        assign data_a[i] = stage4[i+3][0];
        assign data_b[i] = stage4[i+3][1];
    end
endgenerate

assign pre_out = data_a + data_b;
assign o_data = {pre_out[28:0], stage4[2][0], stage4[1][0], stage4[0][0]};

endmodule
///////
//// - tx_top
//// - mac_lane
module mac_lane 
import mac_pkg::*;
(
    input  logic                i_clk                   ,
    input  logic                i_reset                 ,
    input  mac_instruction_port mac_lane_config         ,
    output logic                mac_lane_o_ifm_ready    ,
    input  logic                mac_lane_i_ifm_valid    ,
    input  mac_lane_ifm_port    mac_lane_i_ifm          ,
    output logic                mac_lane_o_wfm_ready    ,
    input  logic                mac_lane_i_wfm_valid    ,
    input  mac_lane_wfm_port    mac_lane_wfm            ,
    output logic                mac_lane_o_bias_ready   ,
    input  logic                mac_lane_i_bias_valid   ,
    input  [32      -1:0]       mac_lane_i_bias         ,
    input  logic                mac_lane_i_ofm_ready    ,
    output logic                mac_lane_o_ofm_valid    ,
    input  mac_lane_ofm_port    mac_lane_o_ofm          ,
    output mac_lane_monitor     mac_lane_o_monitor
);

// pipe ctrl for input -> psum accum
localparam STAGE = 7;

logic               pipe_o_input_ready  ;
logic               pipe_i_input_valid  ;
logic               pipe_i_output_ready ;
logic               pipe_o_output_valid ;
logic [STAGE-1:0]   pipe_o_pipe_ctrl    ;

assign pipe_i_input_valid = mac_lane_i_ifm_valid & mac_lane_i_wfm_valid;
assign mac_lane_o_ifm_ready = pipe_o_input_ready;


pipe_ctrl # ( .STAGE (STAGE) ) u_pipe_ctrl_mac_lane
    (
        .i_clk                  (i_clk                  ),
        .i_reset                (i_reset                ),
        .o_input_ready          (pipe_o_input_ready     ),
        .i_input_valid          (pipe_i_input_valid     ),
        .i_output_ready         (pipe_i_output_ready    ),
        .o_output_valid         (pipe_o_output_valid    ),
        .o_pipe_ctrl            (pipe_o_pipe_ctrl       )
    )


/// control signal pipeline
logic [STAGE-1 :0] inter_end;
logic [STAGE-1 :0] accum_end;
logic [31:0]  big_data_element_valid;
logic [31:0]  mid_data_element_valid;
logic [31:0]  pipe_big_data_element_valid[STAGE-1 :0];
logic [31:0]  pipe_mid_data_element_valid[STAGE-1 :0];
logic [31:0]  big_is_zero_or        ;
logic [31:0]  mid_is_zero_or        ;
logic [31:0]  pipe_big_is_zero_or   ;
logic [31:0]  pipe_mid_is_zero_or   ;

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        inter_end[0]                    <= 0;
        accum_end[0]                    <= 0;
        pipe_big_data_element_valid[0]  <= 0;
        pipe_mid_data_element_valid[0]  <= 0;
        pipe_big_is_zero_or[0]          <= 0;
        pipe_mid_is_zero_or[0]          <= 0;
    end
    else if (pipe_o_pipe_ctrl[0]) begin
        inter_end[0]                    <= mac_lane_i_ifm.inter_end;
        accum_end[0]                    <= mac_lane_i_ifm.accum_end;
        pipe_big_data_element_valid[0]  <= big_data_element_valid;
        pipe_mid_data_element_valid[0]  <= mid_data_element_valid;
        pipe_big_is_zero_or[0]          <= big_is_zero_or;
        pipe_mid_is_zero_or[0]          <= mid_is_zero_or;
    end
end

generate
    for (genvar i=1; i<STAGE; i++) begin
        always_ff @ (posedge i_clk or negedge i_reset) begin
            if (!i_reset) begin
                inter_end[i] <= 0;
                accum_end[i] <= 0;
                pipe_big_data_element_valid[i]  <= 0;
                pipe_mid_data_element_valid[i]  <= 0;
                pipe_big_is_zero_or[i]          <= 0;
                pipe_mid_is_zero_or[i]          <= 0;
            end
            else if (pipe_o_pipe_ctrl[i]) begin
                inter_end[i] <= inter_end[i-1];
                accum_end[i] <= accum_end[i-1];
                pipe_big_data_element_valid[i]  <= pipe_big_data_element_valid[i-1];
                pipe_mid_data_element_valid[i]  <= pipe_mid_data_element_valid[i-1];
                pipe_big_is_zero_or[i]          <= pipe_big_is_zero_or[i-1];
                pipe_mid_is_zero_or[i]          <= pipe_mid_is_zero_or[i-1];
            end
        end
    end
endgenerate


///////////////////
/// decode data
///////////////////

logic [31:0]  big_a_is_zero     ;
logic [31:0]  big_a_sign        ;
logic [4 :0]  big_a_exp [0:31]  ;
logic [10:0]  big_a_mant[0:31]  ;
logic [31:0]  big_b_is_zero     ;
logic [31:0]  big_b_sign        ;
logic [4 :0]  big_b_exp [0:31]  ;
logic [10:0]  big_b_mant[0:31]  ;
logic [31:0]  big_o_sign        ;
logic [5 :0]  big_o_exp [0:31]  ;
logic [21:0]  big_o_mant[0:31]  ;

logic [31:0]  mid_a_is_zero     ;
logic [31:0]  mid_a_sign        ;
logic [3 :0]  mid_a_exp [0:31]  ;
logic [7 :0]  mid_a_mant[0:31]  ;
logic [31:0]  mid_b_is_zero     ;
logic [31:0]  mid_b_sign        ;
logic [3 :0]  mid_b_exp [0:31]  ;
logic [7 :0]  mid_b_mant[0:31]  ;
logic [31:0]  mid_o_sign        ;
logic [4 :0]  mid_o_exp [0:31]  ;
logic [17:0]  mid_o_mant[0:31]  ;

generate
    for (genvar i=0; i<32; i++) begin : decoding_ifm_wfm
        assign big_a_is_zero[i] =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_ifm.data[17+i*MAC_W_ELEMENT*2+:1]
                                    :   mac_lane_i_ifm.data[9 +i*MAC_W_ELEMENT*1+:1];
        assign big_a_sign[i]    =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_ifm.data[16+i*MAC_W_ELEMENT*2+:1]
                                    :   mac_lane_i_ifm.data[8 +i*MAC_W_ELEMENT*1+:1];
        assign big_a_exp [i]    =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_ifm.data[11+i*MAC_W_ELEMENT*2+:5]
                                    : mac_lane_config.ifm_datatype == MAC_DATATYPE_FP8  ?
                                        {1'b0, mac_lane_i_ifm.data[4 +i*MAC_W_ELEMENT*1+:4]}
                                    :   0;
        assign big_a_mant[i]    =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_ifm.data[0+i*MAC_W_ELEMENT*2+:11]
                                    : mac_lane_config.ifm_datatype == MAC_DATATYPE_FP8  ?
                                        {5'b0, mac_lane_i_ifm.data[0+i*MAC_W_ELEMENT*1+:4], 2'b0}
                                    :   {3'b0, mac_lane_i_ifm.data[0+i*MAC_W_ELEMENT*1+:8]};

        assign big_b_is_zero[i] =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_wfm.data[17+i*MAC_W_ELEMENT*2+:1]
                                    :   mac_lane_i_wfm.data[9 +i*MAC_W_ELEMENT*1+:1];
        assign big_b_sign[i]    =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_wfm.data[16+i*MAC_W_ELEMENT*2+:1]
                                    :   mac_lane_i_wfm.data[8 +i*MAC_W_ELEMENT*1+:1];
        assign big_b_exp [i]    =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_wfm.data[11+i*MAC_W_ELEMENT*2+:5]
                                    : mac_lane_config.wfm_datatype == MAC_DATATYPE_FP8  ?
                                        {1'b0, mac_lane_i_wfm.data[4 +i*MAC_W_ELEMENT*1+:4]}
                                    :   0;
        assign big_b_mant[i]    =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        mac_lane_i_wfm.data[0+i*MAC_W_ELEMENT*2+:11]
                                    : mac_lane_config.wfm_datatype == MAC_DATATYPE_FP8  ?
                                        {5'b0, mac_lane_i_wfm.data[0+i*MAC_W_ELEMENT*1+:4], 2'b0}
                                    :   {3'b0, mac_lane_i_wfm.data[0+i*MAC_W_ELEMENT*1+:8]};

        assign mid_a_is_zero[i] =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    :   mac_lane_i_ifm.data[9 +i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:1];
        assign mid_a_sign[i]    =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    :   mac_lane_i_ifm.data[8 +i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:1];
        assign mid_a_exp [i]    =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    : mac_lane_config.ifm_datatype == MAC_DATATYPE_FP8  ?
                                        {1'b0, mac_lane_i_ifm.data[4 +i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:4]}
                                    :   0;
        assign mid_a_mant[i]    =     mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    : mac_lane_config.ifm_datatype == MAC_DATATYPE_FP8  ?
                                        {5'b0, mac_lane_i_ifm.data[0+i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:4], 2'b0}
                                    :   {3'b0, mac_lane_i_ifm.data[0+i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:8]};

        assign mid_b_is_zero[i] =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    :   mac_lane_i_wfm.data[9 +i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:1];
        assign mid_b_sign[i]    =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    :   mac_lane_i_wfm.data[8 +i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:1];
        assign mid_b_exp [i]    =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    : mac_lane_config.wfm_datatype == MAC_DATATYPE_FP8  ?
                                        {1'b0, mac_lane_i_wfm.data[4 +i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:4]}
                                    :   0;
        assign mid_b_mant[i]    =     mac_lane_config.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        0
                                    : mac_lane_config.wfm_datatype == MAC_DATATYPE_FP8  ?
                                        {5'b0, mac_lane_i_wfm.data[0+i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:4], 2'b0}
                                    :   {3'b0, mac_lane_i_wfm.data[0+i*MAC_W_ELEMENT*1 + 32*MAC_W_ELEMENT +:8]};
    end
endgenerate


////////////////
//// multiplier
////////////////

logic [31:0]  big_o_sign        ;
logic [5 :0]  big_o_exp [0:31]  ;
logic [21:0]  big_o_mant[0:31]  ;
logic [31:0]  mid_o_sign        ;
logic [4 :0]  mid_o_exp [0:31]  ;
logic [17:0]  mid_o_mant[0:31]  ;


generate
    for (genvar i=0; i<32; i++) begin : multiplier
        mac_multiplier_big u_mac_multiplier_big
            (
                .a_sign     (big_a_sign[i]),
                .a_exp      (big_a_exp [i]),
                .a_mant     (big_a_mant[i]),
                .b_sign     (big_b_sign[i]),
                .b_exp      (big_b_exp [i]),
                .b_mant     (big_b_mant[i]),
                .o_sign     (big_o_sign[i]),
                .o_exp      (big_o_exp [i]),
                .o_mant     (big_o_mant[i]) 
            );

        mac_multiplier_mid u_mac_multiplier_mid
            (
                .a_sign     (mid_a_sign[i]),
                .a_exp      (mid_a_exp [i]),
                .a_mant     (mid_a_mant[i]),
                .b_sign     (mid_b_sign[i]),
                .b_exp      (mid_b_exp [i]),
                .b_mant     (mid_b_mant[i]),
                .o_sign     (mid_o_sign[i]),
                .o_exp      (mid_o_exp [i]),
                .o_mant     (mid_o_mant[i]) 
            );

            assign big_is_zero_or[i] = big_a_is_zero[i] | big_b_is_zero[i];
            assign mid_is_zero_or[i] = mid_a_is_zero[i] | mid_b_is_zero[i];
            assign big_data_element_valid[i] = mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                                mac_lane_i_ifm.data_element_valid[i*2 ]
                                            :   mac_lane_i_ifm.data_element_valid[i   ];
            assign mid_data_element_valid[i] = mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                                0
                                            :   mac_lane_i_ifm.data_element_valid[i+32];
    end
endgenerate



///////////////////
/// find max exp
///////////////////
logic [6*64 -1:0] exp_array;
logic [6    -1:0] c;
logic             pipe_en_find_max;
logic [6    -1:0] max_exp;

generate
    for (genvar i=0; i<32; i++) begin : concat_exp
        assign exp_array[6*i        +:6] = mac_lane_i_ifm_valid & big_data_element_valid[i] ? big_o_exp[i] : 0;
        assign exp_array[6*i+6*32   +:6] = mac_lane_i_ifm_valid & mid_data_element_valid[i] ? {1'b0, mid_o_exp[i]} : 0;
    end
endgenerate

find_max_64 u_find_max_64
(   
    .clk            (i_clk              ),
    .i_data         (exp_array          ),
    .pipe_en        (pipe_en_find_max   ),
    .result         (max_exp            ) 
);

assign pipe_en_find_max = pipe_o_pipe_ctrl[0];

///////////////////
//// pipeline 0
///////////////////

logic [31:0]  r_big_o_sign              ;
logic [5 :0]  r_big_o_exp [0:31]        ;
logic [21:0]  r_big_o_mant[0:31]        ;
logic [31:0]  r_mid_o_sign              ;
logic [4 :0]  r_mid_o_exp [0:31]        ;
logic [17:0]  r_mid_o_mant[0:31]        ;

generate
    for (genvar i=0; i<32; i++) begin : pipeline_0
        always_ff @ (posedge i_clk) begin // big
            if (pipe_o_pipe_ctrl[0] & (~big_is_zero_or[i]) & big_data_element_valid[i]) begin
                r_big_o_sign[i] <= big_o_sign[i];
                r_big_o_mant[i] <= big_o_mant[i];
            end
        end
        always_ff @ (posedge i_clk) begin // big exp
            if (pipe_o_pipe_ctrl[0] & (~big_is_zero_or[i]) & big_data_element_valid[i] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
                r_big_o_exp[i] <= big_o_exp[i];
            end
        end
        always_ff @ (posedge i_clk) begin // mid
            if (pipe_o_pipe_ctrl[0] & (~mid_is_zero_or[i]) & mid_data_element_valid[i]) begin
                r_mid_o_sign[i] <= mid_o_sign[i];
                r_mid_o_mant[i] <= mid_o_mant[i];
            end
        end
        always_ff @ (posedge i_clk) begin // mid exp
            if (pipe_o_pipe_ctrl[0] & (~mid_is_zero_or[i]) & mid_data_element_valid[i] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
                r_mid_o_exp[i] <= mid_o_exp[i];
            end
        end
    end
endgenerate


///////////////////
///// 2s complement
///////////////////

logic [31:0]  comple_big_o_sign              ;
logic [21:0]  comple_big_o_mant[0:31]        ;
logic [31:0]  comple_mid_o_sign              ;
logic [17:0]  comple_mid_o_mant[0:31]        ;


generate
    for (genvar i=0; i<32; i++) begin : 2s_complement
        mac_2s_complement  # (.WIDTH (22)) u_mac_2s_complement_big
            (
                .i_sign ( r_big_o_sign[i]       ),
                .i_mant ( r_big_o_mant[i]       ),
                .o_sign ( comple_big_o_sign[i]  ),
                .o_mant ( comple_big_o_mant[i]  )
            );

        mac_2s_complement  # (.WIDTH (18)) u_mac_2s_complement_mid
            (
                .i_sign ( r_mid_o_sign[i]       ),
                .i_mant ( r_mid_o_mant[i]       ),
                .o_sign ( comple_mid_o_sign[i]  ),
                .o_mant ( comple_mid_o_mant[i]  )
            );
    end
endgenerate

///////////////////
//// pipeline 1
///////////////////

logic [31:0]  r_comple_big_o_sign              ;
logic [5 :0]  after_findmax_big_exp[0:31]      ;
logic [21:0]  r_comple_big_o_mant[0:31]        ;
logic [31:0]  r_comple_mid_o_sign              ;
logic [5 :0]  after_findmax_mid_exp[0:31]      ;
logic [17:0]  r_comple_mid_o_mant[0:31]        ;


generate
    for (genvar i=0; i<32; i++) begin : pipeline_1
        always_ff @ (posedge i_clk) begin // big
            if (pipe_o_pipe_ctrl[1] & (~pipe_big_is_zero_or[0][i]) & pipe_big_data_element_valid[0][i]) begin
                r_comple_big_o_sign[i] <= comple_big_o_sign[i];
                r_comple_big_o_mant[i] <= comple_big_o_mant[i];
            end
        end
        always_ff @ (posedge i_clk) begin // big exp
            if (pipe_o_pipe_ctrl[1] & (~pipe_big_is_zero_or[0][i]) & pipe_big_data_element_valid[0][i] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
                after_findmax_big_exp[i] <= max_exp - r_big_o_exp[i];
            end
        end
        always_ff @ (posedge i_clk) begin // mid
            if (pipe_o_pipe_ctrl[1] & (~pipe_mid_is_zero_or[0][i]) & pipe_mid_data_element_valid[0][i]) begin
                r_comple_mid_o_sign[i] <= comple_mid_o_sign[i];
                r_comple_mid_o_mant[i] <= comple_mid_o_mant[i];
            end
        end
        always_ff @ (posedge i_clk) begin // mid exp
            if (pipe_o_pipe_ctrl[1] & (~pipe_mid_is_zero_or[0][i]) & pipe_mid_data_element_valid[0][i] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
                after_findmax_mid_exp[i] <= max_exp - r_mid_o_exp[i];
            end
        end
    end
endgenerate

logic [6-1:0] r_max_exp;
always_ff @ (posedge i_clk) begin
    if (pipe_o_pipe_ctrl[1] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
        r_max_exp <= max_exp;
    end
end


///////////////////
//// right shifter
///////////////////
localparam W_O_SHIFTER = 32- $clogs(16);

logic [5-1:0] big_shift_value    [0:31];
logic [W_O_SHIFTER -1:0] big_output_shifter [0:31];
logic [5-1:0] mid_shift_value    [0:31];
logic [W_O_SHIFTER -1:0] mid_output_shifter [0:31];

generate
    for (genvar i=0; i<32; i++) begin : 2s_complement

        assign big_shift_value[i] = mac_lane_config.ifm_datatype == MAC_DATATYPE_I9 ? 5
                                :   after_findmax_big_exp[i][5] ? 31- $clogs(16) : after_findmax_big_exp[i][4:0];
        
        right_shifter  # (.IN_WIDTH (23), .IN_S_WIDTH (6-1), .OUT_WIDTH (W_O_SHIFTER), .TAIL_BIT(5)) u_mac_right_shifter_big
            (
                .i_data         ( { r_comple_big_o_sign[i], r_comple_big_o_mant[i] } ),
                .i_shift_value  ( big_shift_value[i]    ),
                .o_data         ( big_output_shifter[i] )
            );

        assign mid_shift_value[i] = mac_lane_config.ifm_datatype == MAC_DATATYPE_I9 ? 9
                                :   after_findmax_mid_exp[i][4:0];
        
        right_shifter  # (.IN_WIDTH (19), .IN_S_WIDTH (6-1), .OUT_WIDTH (W_O_SHIFTER), .TAIL_BIT(9)) u_mac_right_shifter_mid
            (
                .i_data         ( { r_comple_mid_o_sign[i], r_comple_mid_o_mant[i] } ),
                .i_shift_value  ( mid_shift_value[i]    ),
                .o_data         ( mid_output_shifter[i] )
            );
    end
endgenerate

///////////////////
/// pipeline 2
///////////////////

logic [W_O_SHIFTER -1:0] r_big_output_shifter [0:31];
logic [W_O_SHIFTER -1:0] r_mid_output_shifter [0:31];

generate
    for (genvar i=0; i<32; i++) begin : pipeline_2
        always_ff @ (posedge i_clk) begin // big
            if (pipe_o_pipe_ctrl[2] & (~pipe_big_is_zero_or[1][i]) & pipe_big_data_element_valid[1][i]) begin
                r_big_output_shifter[i] <= big_output_shifter[i];
            end
        end
        always_ff @ (posedge i_clk) begin // mid
            if (pipe_o_pipe_ctrl[2] & (~pipe_mid_is_zero_or[1][i]) & pipe_mid_data_element_valid[1][i]) begin
                r_mid_output_shifter[i] <= mid_output_shifter[i];
            end
        end
    end
endgenerate

logic [6-1:0] r2_max_exp;
always_ff @ (posedge i_clk) begin
    if (pipe_o_pipe_ctrl[2] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
        r2_max_exp <= r_max_exp;
    end
end

///////////////////
///// masking 0
///////////////////

logic [W_O_SHIFTER -1:0] masked_big_output_shifter [0:31];
logic [W_O_SHIFTER -1:0] masked_mid_output_shifter [0:31];

generate
    for (genvar i=0; i<32; i++) begin : mask_0
        assign masked_big_output_shifter[i] = pipe_big_is_zero_or[2][i] | (~pipe_big_data_element_valid[2][i]) ? 0 : r_big_output_shifter[i];
        assign masked_mid_output_shifter[i] = pipe_mid_is_zero_or[2][i] | (~pipe_mid_data_element_valid[2][i]) ? 0 : r_mid_output_shifter[i];
    end
endgenerate

///////////////////
////// sign bit for clog2(16) bit
///////////////////

logic [5 :0] big_sum_sign;
logic [5 :0] mid_sum_sign;
logic [5 :0] big_final_sum_sign;
logic [5 :0] mid_final_sum_sign;

always_comb begin
    big_sum_sign = 0;
    mid_sum_sign = 0;
    for (int i=0; i<32; i++) begin
        big_sum_sign += masked_big_output_shifter[i][W_O_SHIFTER-1];
        mid_sum_sign += masked_mid_output_shifter[i][W_O_SHIFTER-1];
    end
end

assign big_final_sum_sign = big_sum_sign + (big_sum_sign << 1) + (big_sum_sign << 2) + (big_sum_sign << 3) + (big_sum_sign << 4) +
                            (big_sum_sign << 5);
assign mid_final_sum_sign = mid_sum_sign + (mid_sum_sign << 1) + (mid_sum_sign << 2) + (mid_sum_sign << 3) + (mid_sum_sign << 4) +
                            (mid_sum_sign << 5);


////////////////////////
///// wallace tree
////////////////////////
logic [16*28-1:0] big_wallace_tree_input_0, big_wallace_tree_input_1;
logic [16*28-1:0] mid_wallace_tree_input_0, mid_wallace_tree_input_1;
logic [32   -1:0] big_wallace_tree_output_0, big_wallace_tree_output_1, mid_wallace_tree_output_0, mid_wallace_tree_output_1;


generate
    for (genvar i=0; i<16; i++) begin : parsing_wallace_tree_input
        assign big_wallace_tree_input_0[i*28+:28] = masked_big_output_shifter[i];
        assign big_wallace_tree_input_1[i*28+:28] = masked_big_output_shifter[i+16];
        assign mid_wallace_tree_input_0[i*28+:28] = masked_mid_output_shifter[i];
        assign mid_wallace_tree_input_1[i*28+:28] = masked_mid_output_shifter[i+16];
    end
endgenerate

wallace_tree u_wallace_tree_big_0
    (
        .i_data_array   (big_wallace_tree_input_0   ),
        .o_data         (big_wallace_tree_output_0  )
    );
wallace_tree u_wallace_tree_big_1
    (
        .i_data_array   (big_wallace_tree_input_1   ),
        .o_data         (big_wallace_tree_output_1  )
    );
wallace_tree u_wallace_tree_mid_0
    (
        .i_data_array   (mid_wallace_tree_input_0   ),
        .o_data         (mid_wallace_tree_output_0  )
    );
wallace_tree u_wallace_tree_mid_1
    (
        .i_data_array   (mid_wallace_tree_input_1   ),
        .o_data         (mid_wallace_tree_output_1  )
    );

///////////////////
/// pipeline 3
///////////////////

logic [32-1:0] r_wallace_tree_output [0:3];
logic [6 -1:0] r_big_final_sum_sign;
logic [6 -1:0] r_mid_final_sum_sign;

always_ff @ (posedge i_clk) begin
    if (pipe_o_pipe_ctrl[3]) begin
        r_wallace_tree_output[0] <= big_wallace_tree_output_0;
        r_wallace_tree_output[1] <= big_wallace_tree_output_1;
        r_wallace_tree_output[2] <= mid_wallace_tree_output_0;
        r_wallace_tree_output[3] <= mid_wallace_tree_output_1;
        r_big_final_sum_sign     <= big_final_sum_sign;
        r_mid_final_sum_sign     <= mid_final_sum_sign;
    end
end

logic [6-1:0] r3_max_exp;
always_ff @ (posedge i_clk) begin
    if (pipe_o_pipe_ctrl[3] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
        r3_max_exp <= r2_max_exp;
    end
end

/////////
/// adder tree final output
/////////
logic [33-1:0] big_adder_tree_output;
logic [33-1:0] mid_adder_tree_output;

assign big_adder_tree_output = {1'b0, r_wallace_tree_output[0]} + {1'b0, r_wallace_tree_output[1]} + {r_big_final_sum_sign[4:0], 28'd0};
assign mid_adder_tree_output = {1'b0, r_wallace_tree_output[2]} + {1'b0, r_wallace_tree_output[3]} + {r_mid_final_sum_sign[4:0], 28'd0};

logic [34-1:0] adder_tree_final_output;
assign adder_tree_final_output = {big_adder_tree_output[32], big_adder_tree_output} + {mid_adder_tree_output[32], mid_adder_tree_output};

///////////////////
/// pipeline 4
///////////////////

logic [34-1:0] r_adder_tree_final_output;

always_ff @ (posedge i_clk) begin
    if (pipe_o_pipe_ctrl[4]) begin
        r_adder_tree_final_output <= adder_tree_final_output;
    end
end

logic [6-1:0] r4_max_exp;
always_ff @ (posedge i_clk) begin
    if (pipe_o_pipe_ctrl[4] & (mac_lane_config.ifm_datatype != MAC_DATATYPE_I9)) begin
        r4_max_exp <= r3_max_exp;
    end
end

//////
// fp32 converter
/////

logic mac_fp32_converter_o_data;

mac_fp32_converter u_mac_fp32_converter
    (
        .i_clk              ( i_clk                     ),
        .i_ifm_datatype     ( mac_lane_config.ifm_datatype),
        .i_wfm_datatype     ( mac_lane_config.wfm_datatype),
        .i_exp              ( r4_max_exp                ),
        .i_intdata          ( r_adder_tree_final_output ),
        .i_pipe_en          ( pipe_o_pipe_ctrl[6:5]     ),
        .o_data             ( mac_fp32_converter_o_data )
    );


///////
/// fifo for cutting ready signal
///////

logic fifo_mac_fp32_converter_o_input_ready;
logic fifo_mac_fp32_converter_i_input_valid;
logic fifo_mac_fp32_converter_i_output_ready;
logic fifo_mac_fp32_converter_o_output_valid;
logic [32-1:0] fifo_mac_fp32_converter_o_output_data;

assign fifo_mac_fp32_converter_i_input_valid = pipe_o_output_valid;
assign pipe_i_output_ready = fifo_mac_fp32_converter_o_input_ready;

fifo_no_rst_data #( .WIDTH(32) ) u_fifo_mac_fp32_converter
    (
        .i_clk              ( i_clk     ),
        .i_reset            ( i_reset   ),
        .o_input_ready      ( fifo_mac_fp32_converter_o_input_ready     ),
        .i_input_valid      ( fifo_mac_fp32_converter_i_input_valid     ),
        .i_input_data       ( mac_fp32_converter_o_data                 ),
        .i_output_ready     ( fifo_mac_fp32_converter_i_output_ready    ),
        .o_output_valid     ( fifo_mac_fp32_converter_o_output_valid    ),
        .o_output_data      ( fifo_mac_fp32_converter_o_output_data     )
    );
    







endmodule
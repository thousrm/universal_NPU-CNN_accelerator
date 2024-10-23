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
localparam STAGE = 5;

logic               pipe_o_input_ready  ;
logic               pipe_i_input_valid  ;
logic               pipe_i_output_ready ;
logic               pipe_o_output_valid ;
logic [STAGE-1:0]   pipe_o_pipe_ctrl    ;


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
    else begin
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
            else begin
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


//// multiplier

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
            assign big_data_element_valid = mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                                mac_lane_i_ifm.data_element_valid[i*2 ]
                                            :   mac_lane_i_ifm.data_element_valid[i   ];
            assign mid_data_element_valid = mac_lane_config.ifm_datatype == MAC_DATATYPE_FP16 ?
                                                0
                                            :   mac_lane_i_ifm.data_element_valid[i+32];
    end
endgenerate




/// find max exp

logic [6*64 -1:0] exp_array;
logic [6    -1:0] c;
logic             pipe_en_find_max;

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

//// pipeline 0
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



///// 2s complement
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

//// pipeline 1
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







endmodule
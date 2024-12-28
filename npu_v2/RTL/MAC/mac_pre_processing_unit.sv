///////
//// - tx_top
//// - mac_lane
module mac_pre_processing_unit
import tx_pkg::*;
import mac_pkg::*;
(
    output logic                        mac_pre_o_instruction_ready ,
    input  logic                        mac_pre_i_instruction_valid ,
    input  tx_mac_instruction_port      mac_pre_i_instruction       ,
    input  logic                        mac_pre_i_done_ready        ,
    output logic                        mac_pre_o_done              ,
    output logic                        mac_pre_o_ifm_ready         ,
    input  logic                        mac_pre_i_ifm_valid         ,
    input  tx_mac_ifm_port              mac_pre_i_ifm               ,
    output logic                        mac_pre_o_wfm_ready         ,
    input  logic                        mac_pre_i_wfm_valid         ,
    input  tx_mac_wfm_port              mac_pre_i_wfm               ,
    input  logic                        mac_pre_to_lane_i_ifm_ready ,
    output logic                        mac_pre_to_lane_o_ifm_valid ,
    output mac_pre_ifm_port             mac_pre_to_lane_o_ifm       ,
    output logic [64-1:0]               mac_pre_to_lane_o_wfm_valid ,
    output mac_pre_wfm_port             mac_pre_to_lane_o_wfm       
);





/////////////
/// IFM fifo
/////////////

logic ifm_fifo_o_input_ready;
logic ifm_fifo_i_input_valid;
logic ifm_fifo_i_output_ready;
logic ifm_fifo_o_output_valid;
logic tx_mac_ifm_port  ifm_fifo_i_output_data;
logic tx_mac_ifm_port  ifm_fifo_o_output_data;

assign mac_o_ifm_ready = ifm_fifo_o_input_ready;
assign ifm_fifo_i_input_valid = mac_i_ifm_valid;
assign ifm_fifo_i_output_data = mac_i_ifm      ;


fifo_no_rst_data_type #( .DATA_TYPE(tx_mac_ifm_port) ) u_fifo_mac_ifm_fifo
    (
        .i_clk              ( i_clk                     ),
        .i_reset            ( i_reset                   ),
        .o_input_ready      ( ifm_fifo_o_input_ready    ),
        .i_input_valid      ( ifm_fifo_i_input_valid    ),
        .i_input_data       ( ifm_fifo_i_output_data    ),
        .i_output_ready     ( ifm_fifo_i_output_ready   ),
        .o_output_valid     ( ifm_fifo_o_output_valid   ),
        .o_output_data      ( ifm_fifo_o_output_data    )
    );


/////////////
/// WFM fifo
/////////////

logic wfm_fifo_o_input_ready;
logic wfm_fifo_i_input_valid;
logic wfm_fifo_i_output_ready;
logic wfm_fifo_o_output_valid;
logic tx_mac_wfm_port  wfm_fifo_i_output_data;
logic tx_mac_wfm_port  wfm_fifo_o_output_data;

assign mac_o_wfm_ready = wfm_fifo_o_input_ready;
assign wfm_fifo_i_input_valid = mac_i_wfm_valid;
assign wfm_fifo_i_output_data = mac_i_wfm      ;


fifo_no_rst_data_type #( .DATA_TYPE(tx_mac_wfm_port) ) u_fifo_mac_wfm_fifo
    (
        .i_clk              ( i_clk                     ),
        .i_reset            ( i_reset                   ),
        .o_input_ready      ( wfm_fifo_o_input_ready    ),
        .i_input_valid      ( wfm_fifo_i_input_valid    ),
        .i_input_data       ( wfm_fifo_i_output_data    ),
        .i_output_ready     ( wfm_fifo_i_output_ready   ),
        .o_output_valid     ( wfm_fifo_o_output_valid   ),
        .o_output_data      ( wfm_fifo_o_output_data    )
    );

/////////////
//// decoder
/////////////

logic [TX_MAC_W_ELEMENT*2-2-1:0] decoder_big_ifm_i_data[32];
logic [32-1:0] decoder_big_ifm_o_iszero  ;
logic [32-1:0] decoder_big_ifm_o_sign    ;
logic [5 -1:0] decoder_big_ifm_o_exp [32];
logic [11-1:0] decoder_big_ifm_o_mant[32];
logic [TX_MAC_W_ELEMENT  -1:0] decoder_mid_ifm_i_data[32];
logic [32-1:0] decoder_mid_ifm_o_iszero  ;
logic [32-1:0] decoder_mid_ifm_o_sign    ;
logic [4 -1:0] decoder_mid_ifm_o_exp [32];
logic [9 -1:0] decoder_mid_ifm_o_mant[32];

logic [TX_MAC_W_ELEMENT*2-2-1:0] decoder_big_wfm_i_data[32];
logic [32-1:0] decoder_big_wfm_o_iszero  ;
logic [32-1:0] decoder_big_wfm_o_sign    ;
logic [5 -1:0] decoder_big_wfm_o_exp [32];
logic [11-1:0] decoder_big_wfm_o_mant[32];
logic [TX_MAC_W_ELEMENT  -1:0] decoder_mid_wfm_i_data[32];
logic [32-1:0] decoder_mid_wfm_o_iszero  ;
logic [32-1:0] decoder_mid_wfm_o_sign    ;
logic [4 -1:0] decoder_mid_wfm_o_exp [32];
logic [9 -1:0] decoder_mid_wfm_o_mant[32];

logic [MAC_W_ELEMENT*2-1:0] decoder_ifm_array[32];
logic [MAC_W_ELEMENT*2-1:0] decoder_wfm_array[32];

generate
    for (genvar i=0; i<32; i++) begin : decoder

        assign decoder_big_ifm_i_data[i] = ifm_fifo_o_output_data.data[i*TX_MAC_W_ELEMENT*2+:TX_MAC_W_ELEMENT*2-2];
        assign decoder_mid_ifm_i_data[i] = ifm_fifo_o_output_data.data[i*TX_MAC_W_ELEMENT*2 +TX_MAC_W_ELEMENT +:TX_MAC_W_ELEMENT];

        mac_decoder_big u_mac_decoder_big_ifm
            (
                .i_datatype (mac_pre_i_instruction.ifm_datatype ),
                .i_data     (decoder_big_ifm_i_data[i]          ),
                .o_iszero   (decoder_big_ifm_o_iszero[i]        ),
                .o_sign     (decoder_big_ifm_o_sign[i]          ),
                .o_exp      (decoder_big_ifm_o_exp [i]          ),
                .o_mant     (decoder_big_ifm_o_mant[i]          )
            );

        mac_decoder_mid u_mac_decoder_mid_ifm
            (
                .i_datatype (mac_pre_i_instruction.ifm_datatype ),
                .i_data     (decoder_mid_ifm_i_data[i]          ),
                .o_iszero   (decoder_mid_ifm_o_iszero[i]        ),
                .o_sign     (decoder_mid_ifm_o_sign[i]          ),
                .o_exp      (decoder_mid_ifm_o_exp [i]          ),
                .o_mant     (decoder_mid_ifm_o_mant[i]          )
            );

        assign decoder_ifm_array[i] = mac_pre_i_instruction.ifm_datatype == MAC_DATATYPE_FP16 ?
                                        {4'b0,  decoder_big_ifm_o_iszero[i]   ,  decoder_big_ifm_o_sign[i], 
                                                decoder_big_ifm_o_exp[i]      ,  decoder_big_ifm_o_mant[i]}
                                    : mac_pre_i_instruction.ifm_datatype == MAC_DATATYPE_FP8  ?
                                        {1'b0,  decoder_big_ifm_o_iszero[i]   ,  decoder_big_ifm_o_sign[i], 
                                                decoder_big_ifm_o_exp[i][3:0] ,  decoder_big_ifm_o_mant[i][3:0],
                                         1'b0,  decoder_mid_ifm_o_iszero[i]   ,  decoder_mid_ifm_o_sign[i], 
                                                decoder_mid_ifm_o_exp[i]      ,  decoder_mid_ifm_o_mant[i][3:0]}
                                    : //int9
                                        {       decoder_big_ifm_o_iszero[i]   ,  decoder_big_ifm_o_sign[i], 
                                                decoder_big_ifm_o_mant[i][8:0],
                                                decoder_mid_ifm_o_iszero[i]   ,  decoder_mid_ifm_o_sign[i], 
                                                decoder_mid_ifm_o_mant[i][8:0]};

        assign decoder_big_wfm_i_data[i] = wfm_fifo_o_output_data.data[i*TX_MAC_W_ELEMENT*2+:TX_MAC_W_ELEMENT*2-2];
        assign decoder_mid_wfm_i_data[i] = wfm_fifo_o_output_data.data[i*TX_MAC_W_ELEMENT*2 +TX_MAC_W_ELEMENT +:TX_MAC_W_ELEMENT];

        mac_decoder_big u_mac_decoder_big_wfm
            (
                .i_datatype (mac_pre_i_instruction.wfm_datatype ),
                .i_data     (decoder_big_wfm_i_data[i]          ),
                .o_iszero   (decoder_big_wfm_o_iszero[i]        ),
                .o_sign     (decoder_big_wfm_o_sign[i]          ),
                .o_exp      (decoder_big_wfm_o_exp [i]          ),
                .o_mant     (decoder_big_wfm_o_mant[i]          )
            );

        mac_decoder_mid u_mac_decoder_mid_wfm
            (
                .i_datatype (mac_pre_i_instruction.wfm_datatype ),
                .i_data     (decoder_mid_wfm_i_data[i]          ),
                .o_iszero   (decoder_mid_wfm_o_iszero[i]        ),
                .o_sign     (decoder_mid_wfm_o_sign[i]          ),
                .o_exp      (decoder_mid_wfm_o_exp [i]          ),
                .o_mant     (decoder_mid_wfm_o_mant[i]          )
            );

        assign decoder_wfm_array[i] = mac_pre_i_instruction.wfm_datatype == MAC_DATATYPE_FP16 ?
                                        {4'b0,  decoder_big_wfm_o_iszero[i]   ,  decoder_big_wfm_o_sign[i], 
                                                decoder_big_wfm_o_exp[i]      ,  decoder_big_wfm_o_mant[i]}
                                    : mac_pre_i_instruction.wfm_datatype == MAC_DATATYPE_FP8  ?
                                        {1'b0,  decoder_big_wfm_o_iszero[i]   ,  decoder_big_wfm_o_sign[i], 
                                                decoder_big_wfm_o_exp[i][3:0] ,  decoder_big_wfm_o_mant[i][3:0],
                                         1'b0,  decoder_mid_wfm_o_iszero[i]   ,  decoder_mid_wfm_o_sign[i], 
                                                decoder_mid_wfm_o_exp[i]      ,  decoder_mid_wfm_o_mant[i][3:0]}
                                    : //int9
                                        {       decoder_big_wfm_o_iszero[i]   ,  decoder_big_wfm_o_sign[i], 
                                                decoder_big_wfm_o_mant[i][8:0],
                                                decoder_mid_wfm_o_iszero[i]   ,  decoder_mid_wfm_o_sign[i], 
                                                decoder_mid_wfm_o_mant[i][8:0]};
    end
endgenerate

////////////
/// pipeline ifm
////////////

localparam STAGE_IFM = 2;

logic [MAC_W_ELEMENT*2-1:0] r_decoder_ifm_array[32];
logic [MAC_W_ELEMENT*2-1:0] r_g_decoder_ifm_array[1:STAGE_IFM][MAC_LANE_GROUP][32];

logic   [64-1:0] r_data_element_valid;
logic            r_inter_end;
logic            r_accum_end;
logic   [64 -1:0]                   r_g_data_element_valid[1:STAGE_IFM][MAC_LANE_GROUP];
logic   [MAC_LANE_GROUP     -1:0]   r_g_inter_end[1:STAGE_IFM];
logic   [MAC_LANE_GROUP     -1:0]   r_g_accum_end[1:STAGE_IFM];



logic                   pipe_ifm_o_input_ready  ;
logic                   pipe_ifm_i_input_valid  ;
logic                   pipe_ifm_i_output_ready ;
logic                   pipe_ifm_o_output_valid ;
logic [STAGE_IFM-1:0]   pipe_ifm_o_pipe_ctrl    ;

assign mac_pre_o_ifm_ready         = pipe_ifm_o_input_ready;
assign pipe_ifm_i_input_valid      = mac_pre_i_ifm_valid;
assign pipe_ifm_i_output_ready     = mac_pre_to_lane_i_ifm_ready;
assign mac_pre_to_lane_o_ifm_valid = pipe_ifm_o_output_valid;

pipe_ctrl # ( .STAGE (STAGE_IFM) ) u_pipe_ctrl_ifm
    (
        .i_clk                  (i_clk                   ),
        .i_reset                (i_reset                 ),
        .o_input_ready          (pipe_ifm_o_input_ready  ),
        .i_input_valid          (pipe_ifm_i_input_valid  ),
        .i_output_ready         (pipe_ifm_i_output_ready ),
        .o_output_valid         (pipe_ifm_o_output_valid ),
        .o_pipe_ctrl            (pipe_ifm_o_pipe_ctrl    )
    );

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        r_data_element_valid    <= 0;
        r_inter_end             <= 0;
        r_accum_end             <= 0;
    end
    else if (pipe_ifm_o_pipe_ctrl[0]) begin
        r_data_element_valid    <= mac_pre_i_ifm.data_element_valid;
        r_inter_end             <= mac_pre_i_ifm.inter_end         ;
        r_accum_end             <= mac_pre_i_ifm.accum_end         ;
    end
end

generate
    for (genvar i=0; i<MAC_LANE_GROUP; i++) begin : pipeline_ifm_ctrl_1
        always_ff @ (posedge i_clk or negedge i_reset) begin
            if (!i_reset) begin
                r_g_inter_end[1][i]           <= 0;
                r_g_accum_end[1][i]           <= 0;
                r_g_data_element_valid[1][i]  <= 0;
            end
            else if (pipe_ifm_o_pipe_ctrl[1]) begin
                r_g_inter_end[1][i]           <= r_data_element_valid;
                r_g_accum_end[1][i]           <= r_inter_end         ;
                r_g_data_element_valid[1][i]  <= r_accum_end         ;
            end
        end
    end
endgenerate

generate
    for (genvar j=2; j<MAC_LANE_GROUP; j++) begin : pipeline_ifm_ctrl_2
        for (genvar i=0; i<MAC_LANE_GROUP; i++) begin
            always_ff @ (posedge i_clk or negedge i_reset) begin
                if (!i_reset) begin
                    r_g_inter_end[j][i]           <= 0;
                    r_g_accum_end[j][i]           <= 0;
                    r_g_data_element_valid[j][i]  <= 0;
                end
                else if (pipe_ifm_o_pipe_ctrl[j]) begin
                    r_g_inter_end[j][i]           <= r_g_inter_end[j-1][i]         ;
                    r_g_accum_end[j][i]           <= r_g_accum_end[j-1][i]         ;
                    r_g_data_element_valid[j][i]  <= r_g_data_element_valid[j-1][i];
                end
            end
        end
    end
endgenerate

generate
    for (genvar i=0; i<32; i++) begin : pipeline_ifm_0
        always_ff @ (posedge i_clk) begin
            if (pipe_ifm_o_pipe_ctrl[0] & mac_pre_i_ifm.data_element_valid[i]) begin
                r_decoder_ifm_array[i] <= decoder_ifm_array[i];
            end
        end
    end
endgenerate

generate
    for (genvar j=0; j<MAC_LANE_GROUP; j++) begin : pipeline_ifm_1
        for (genvar i=0; i<32; i++) begin : pipeline_ifm_e
            always_ff @ (posedge i_clk) begin
                if (pipe_ifm_o_pipe_ctrl[1] & r_data_element_valid[i]) begin
                    r_g_decoder_ifm_array[1][j][i] <= r_decoder_ifm_array[i];
                end
            end
        end
    end
endgenerate

generate
    for (genvar k=2; k<STAGE_IFM; k++) begin : pipeline_ifm_2
        for (genvar j=0; j<MAC_LANE_GROUP; j++) begin : pipeline_ifm_g
            for (genvar i=0; i<32; i++) begin : pipeline_ifm_e
                always_ff @ (posedge i_clk) begin
                    if (pipe_ifm_o_pipe_ctrl[k] & r_g_data_element_valid[i]) begin
                        r_g_decoder_ifm_array[k][j][i] <= r_g_decoder_ifm_array[k-1][j][i];
                    end
                end
            end
        end
    end
endgenerate

generate
    for (genvar i=0; i<MAC_LANE_GROUP; i++) begin : incoding_mac_pre_o_ifm
        for (genvar j=0; j<32; j++) begin : incoding_mac_pre_o_ifm_element
            assign mac_pre_to_lane_o_ifm.data[MAC_W_ELEMENT*64*i+MAC_W_ELEMENT*2*j+:MAC_W_ELEMENT*2] 
                            = r_g_decoder_ifm_array[STAGE_IFM-1][i][j];
        end
        assign mac_pre_to_lane_o_ifm.data_element_valid[64*i+:64] = r_g_data_element_valid[STAGE_IFM-1][i];
        assign mac_pre_to_lane_o_ifm.inter_end[i]                 = r_g_inter_end[STAGE_IFM-1][i];
        assign mac_pre_to_lane_o_ifm.accum_end[i]                 = r_g_accum_end[STAGE_IFM-1][i];
    end
endgenerate



////////////
/// pipeline wfm
////////////

localparam STAGE_WFM_DEC = 1;

logic [MAC_W_ELEMENT*2-1:0] r_decoder_wfm_array[32];
logic                       r_is_last;

logic                     pipe_wfm_o_input_ready  ;
logic                     pipe_wfm_i_input_valid  ;
logic                     pipe_wfm_i_output_ready ;
logic                     pipe_wfm_o_output_valid ;
logic [STAGE_WFM_DEC-1:0] pipe_wfm_dec_o_pipe_ctrl;

assign mac_pre_o_wfm_ready    = pipe_wfm_o_input_ready;
assign pipe_wfm_i_input_valid = mac_pre_i_wfm_valid;

pipe_ctrl # ( .STAGE (STAGE_WFM_DEC) ) u_pipe_ctrl_wfm
    (
        .i_clk                  (i_clk                   ),
        .i_reset                (i_reset                 ),
        .o_input_ready          (pipe_wfm_o_input_ready  ),
        .i_input_valid          (pipe_wfm_i_input_valid  ),
        .i_output_ready         (pipe_wfm_i_output_ready ),
        .o_output_valid         (pipe_wfm_o_output_valid ),
        .o_pipe_ctrl            (pipe_wfm_dec_o_pipe_ctrl)
    );

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        r_is_last <= 0;
    end
    else if (pipe_wfm_dec_o_pipe_ctrl[0]) begin
        r_is_last <= mac_pre_i_wfm.is_last;
    end
end

generate
    for (genvar i=0; i<32; i++) begin : pipeline_wfm_dec
        always_ff @ (posedge i_clk) begin
            if (pipe_wfm_dec_o_pipe_ctrl[0]) begin
                r_decoder_wfm_array[i] <= decoder_wfm_array[i];
            end
        end
    end
endgenerate

/// weight buffer

localparam STAGE_WFM_BUF = 2;

logic [MAC_W_ELEMENT*2-1:0] wfm_buffer[STAGE_WFM_BUF][64][32];
logic [6-1:0]               ptr_buffer;
logic [64-1:0]              lane_valid[STAGE_WFM_BUF];

logic                     pipe_wfm_buf_o_input_ready  ;
logic                     pipe_wfm_buf_i_input_valid  ;
logic                     pipe_wfm_buf_i_output_ready ;
logic                     pipe_wfm_buf_o_output_valid ;
logic [STAGE_WFM_BUF-1:0] pipe_wfm_buf_o_pipe_ctrl    ;

assign pipe_wfm_i_output_ready    = pipe_wfm_buf_o_input_ready;
assign pipe_wfm_buf_i_input_valid = pipe_wfm_o_output_valid & r_is_last;


pipe_ctrl # ( .STAGE (STAGE_WFM_BUF) ) u_pipe_ctrl_wfm_buf
    (
        .i_clk                  (i_clk                       ),
        .i_reset                (i_reset                     ),
        .o_input_ready          (pipe_wfm_buf_o_input_ready  ),
        .i_input_valid          (pipe_wfm_buf_i_input_valid  ),
        .i_output_ready         (pipe_wfm_buf_i_output_ready ),
        .o_output_valid         (pipe_wfm_buf_o_output_valid ),
        .o_pipe_ctrl            (pipe_wfm_buf_o_pipe_ctrl    )
    );

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        ptr_buffer <= 0;
    end
    else if (pipe_wfm_buf_o_input_ready & pipe_wfm_o_output_valid & r_is_last) begin
        ptr_buffer <= 0;
    end
    else if (pipe_wfm_buf_o_input_ready & pipe_wfm_o_output_valid) begin
        ptr_buffer <= ptr_buffer+1;
    end
end

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        lane_valid[0][i] <= 0;
    end
    else if (pipe_wfm_buf_o_input_ready & pipe_wfm_o_output_valid) begin
        lane_valid[0][ptr_buffer] = 1'b1;
    end
end

generate
    for (genvar i=0; i<32; i++) begin : wfm_buffer_element
        always_ff @ (posedge i_clk) begin
            if (pipe_wfm_buf_o_input_ready & pipe_wfm_o_output_valid) begin
                wfm_buffer[0][ptr_buffer][i] <= decoder_wfm_array[i];
            end
        end
    end
endgenerate

generate
    for (genvar k=1; k<STAGE_WFM_BUF; k++) begin : pipeline_wfm_buffer
        always_ff @ (posedge i_clk) begin
            if (pipe_wfm_buf_o_input_ready & pipe_wfm_o_output_valid) begin
                lane_valid[k] <= lane_valid[k-1];
            end
        end
        for (genvar j=0; j<64; j++) begin : pipeline_wfm_buffer_line
            always_ff @ (posedge i_clk) begin
                if (pipe_wfm_buf_o_pipe_ctrl[k]) begin
                    wfm_buffer[k][j][i] <= wfm_buffer[k-1][j][i];
                end
            end
            for (genvar i=0; i<32; i++) begin : pipe_line_wfm_buffer_element
                always_ff @ (posedge i_clk) begin
                    if (pipe_wfm_buf_o_pipe_ctrl[k]) begin
                        wfm_buffer[k][j][i] <= wfm_buffer[k-1][j][i];
                    end
                end
            end
        end
    end
endgenerate

/// TODO it needs to check 
logic pop_wfm_buffer, r_pop_wfm_buffer;
assign pop_wfm_buffer = mac_pre_to_lane_i_ifm_ready & mac_pre_to_lane_o_ifm_valid & mac_pre_to_lane_o_ifm.inter_end[0];

assign pipe_wfm_buf_i_output_ready = pop_wfm_buffer;
assign mac_pre_to_lane_o_wfm_valid = pipe_wfm_buf_o_output_valid;


endmodule
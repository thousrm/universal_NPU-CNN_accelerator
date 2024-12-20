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



endmodule
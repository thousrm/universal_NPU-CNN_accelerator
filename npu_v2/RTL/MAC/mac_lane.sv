///////
//// - tx_top
//// - mac_lane
module mac_lane 
import mac_pkg::*;
(
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
logic [2 :0]  mid_a_exp [0:31]  ;
logic [7 :0]  mid_a_mant[0:31]  ;
logic [31:0]  mid_b_is_zero     ;
logic [31:0]  mid_b_sign        ;
logic [2 :0]  mid_b_exp [0:31]  ;
logic [7 :0]  mid_b_mant[0:31]  ;
logic [31:0]  mid_o_sign        ;
logic [3 :0]  mid_o_exp [0:31]  ;
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
    end
endgenerate

logic [31:0]  big_o_sign        ;
logic [5 :0]  big_o_exp [0:31]  ;
logic [21:0]  big_o_mant[0:31]  ;
logic [31:0]  mid_o_sign        ;
logic [3 :0]  mid_o_exp [0:31]  ;
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
    end
endgenerate




endmodule
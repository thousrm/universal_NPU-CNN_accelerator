///////
//// - tx_top
//// - mac_lane
module mac_lane 
import mac_pkg::*;
(
    output logic             mac_lane_o_ifm_ready   ,
    input  logic             mac_lane_i_ifm_valid   ,
    input  mac_lane_ifm_port mac_lane_i_ifm         ,
    output logic             mac_lane_o_wfm_ready   ,
    input  logic             mac_lane_i_wfm_valid   ,
    input  mac_lane_wfm_port mac_lane_wfm           ,
    output logic             mac_lane_o_bias_ready  ,
    input  logic             mac_lane_i_bias_valid  ,
    input  [32      -1:0]    mac_lane_i_bias        ,
    input  logic             mac_lane_i_ofm_ready   ,
    output logic             mac_lane_o_ofm_valid   ,
    input  mac_lane_ofm_port mac_lane_o_ofm         ,
    output mac_lane_monitor  mac_lane_o_monitor

);



endmodule
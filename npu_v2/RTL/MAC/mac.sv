///////
//// - tx_top
//// - mac_lane
module mac 
import tx_pkg::*;
import mac_pkg::*;
(
    output logic                        mac_o_instruction_ready ,
    input  logic                        mac_i_instruction_valid ,
    input  tx_mac_instruction_port      mac_i_instruction       ,
    input  logic                        mac_i_done_ready        ,
    output logic                        mac_o_done              ,
    output logic                        mac_o_ifm_ready         ,
    input  logic                        mac_i_ifm_valid         ,
    input  tx_mac_ifm_port              mac_i_ifm               ,
    output logic                        mac_o_wfm_ready         ,
    input  logic                        mac_i_wfm_valid         ,
    input  tx_mac_wfm_port              mac_i_wfm               ,
    output logic                        mac_o_bias_ready        ,
    input  logic                        mac_i_bias_valid        ,
    input  tx_mac_bias_port             mac_i_bias              ,
    input  logic                        mac_i_ofm_ready         ,
    output logic                        mac_o_ofm_valid         ,
    output tx_mac_ofm_port              mac_o_ofm                
);





endmodule
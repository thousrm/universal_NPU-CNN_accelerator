
module mac 
import tx_pkg::*;
import mac_pkg::*;
(
    input  logic                        i_clk                   ,
    input  logic                        i_reset                 ,
    input  logic                        mac_i_start             ,
    output logic                        mac_o_instruction_ready ,
    input  logic                        mac_i_instruction_valid ,
    input  tx_mac_instruction_port      mac_i_instruction       ,
    input  logic                        mac_i_feeder_done       ,
    input  logic                        mac_i_drainer_done      ,
    input  logic                        mac_i_tx_done           ,
    output logic                        mac_o_ifm_ready         ,
    input  logic                        mac_i_ifm_valid         ,
    input  tx_mac_ifm_port              mac_i_ifm               ,
    output logic                        mac_o_wfm_ready         ,
    input  logic                        mac_i_wfm_valid         ,
    input  tx_mac_wfm_port              mac_i_wfm               ,
    output logic                        mac_o_bias_ready        ,
    input  logic [64-1:0]               mac_i_bias_valid        ,
    input  tx_mac_bias_port             mac_i_bias              ,
    input  logic                        mac_i_ofm_ready         ,
    output logic                        mac_o_ofm_valid         ,
    output tx_mac_ofm_port              mac_o_ofm               ,
    output tx_mac_exception_port        mac_o_exceptions
);

typedef enum { IDLE, RUN, F_DONE, DONE } mac_state;
mac_state c_state, n_state;

always_ff @(posedge i_clk, negedge i_reset) begin
    if (!i_reset) n_state <= IDLE;
    else          n_state <= c_state;
end

always_comb begin
    c_state = n_state;
    case (n_state)
        IDLE    : begin
            if (mac_i_start)        c_state = RUN;
        end
        RUN     : begin
            if (mac_i_feeder_done & mac_i_drainer_done)  c_state = IDLE;
            else if (mac_i_feeder_done)                  c_state = F_DONE;
        end
        F_DONE     : begin
            if (mac_i_drainer_done)                 c_state = IDLE;
        end
    endcase
end



///// mac_pre_processsing_unit
logic                        mac_pre_o_instruction_ready ;
logic                        mac_pre_i_instruction_valid ;
tx_mac_instruction_port      mac_pre_i_instruction       ;
logic                        mac_pre_i_done_ready        ;
logic                        mac_pre_o_done              ;
logic                        mac_pre_o_ifm_ready         ;
logic                        mac_pre_i_ifm_valid         ;
tx_mac_ifm_port              mac_pre_i_ifm               ;
logic                        mac_pre_o_wfm_ready         ;
logic                        mac_pre_i_wfm_valid         ;
tx_mac_wfm_port              mac_pre_i_wfm               ;
logic                        mac_pre_to_lane_i_ifm_ready ;
logic                        mac_pre_to_lane_o_ifm_valid ;
mac_pre_ifm_port             mac_pre_to_lane_o_ifm       ;
logic [64-1:0]               mac_pre_to_lane_o_wfm_valid ;
mac_pre_wfm_port             mac_pre_to_lane_o_wfm       ;

mac_pre_processing_unit u_mac_pre_processing_unit (.*);


////// mac_lane

mac_instruction_port mac_lane_config         ;
logic [64-1:0]       mac_lane_o_ifm_ready    ;
logic                mac_lane_i_ifm_valid    ;
mac_lane_ifm_port    mac_lane_i_ifm      [64];
logic                mac_lane_i_wfm_valid[64];
mac_lane_wfm_port    mac_lane_i_wfm      [64];
logic [64-1:0]       mac_lane_o_bias_ready   ;
logic [64-1:0]       mac_lane_i_bias_valid   ;
logic [32-1:0]       mac_lane_i_bias     [64];
logic                mac_lane_i_ofm_ready    ;
logic [64-1:0]       mac_lane_o_ofm_valid    ;
mac_lane_ofm_port    mac_lane_o_ofm      [64];
mac_lane_monitor     mac_lane_o_monitor  [64];

generate
    for (genvar i=0; i<64; i++) begin

        assign mac_lane_i_ifm[i].data = mac_pre_to_lane_o_ifm.data[MAC_W_ELEMENT*64*(i/MAC_LANE_GROUP)+:MAC_W_ELEMENT*64];
        assign mac_lane_i_ifm[i].data_element_valid = mac_pre_to_lane_o_ifm.data_element_valid[64*(i/MAC_LANE_GROUP)+:64];
        assign mac_lane_i_ifm[i].inter_end = mac_pre_to_lane_o_ifm.inter_end[i/MAC_LANE_GROUP];
        assign mac_lane_i_ifm[i].accum_end = mac_pre_to_lane_o_ifm.accum_end[i/MAC_LANE_GROUP];
        assign mac_lane_i_wfm_valid  [i] = mac_pre_to_lane_o_wfm_valid[i];
        assign mac_lane_i_wfm        [i] = mac_pre_to_lane_o_wfm.data[MAC_W_ELEMENT*64*i+:MAC_W_ELEMENT*64];
        assign mac_lane_i_bias_valid [i] = mac_i_bias_valid[i];
        assign mac_lane_i_bias       [i] = mac_i_bias.data [32*i+:32];

        mac_lane u_mac_lane (
            .i_clk                   (i_clk                         ),
            .i_reset                 (i_reset                       ),
            .mac_lane_config         (mac_lane_config               ),
            .mac_lane_o_ifm_ready    (mac_lane_o_ifm_ready  [i]     ),
            .mac_lane_i_ifm_valid    (mac_lane_i_ifm_valid          ),
            .mac_lane_i_ifm          (mac_lane_i_ifm        [i]     ),
            .mac_lane_i_wfm_valid    (mac_lane_i_wfm_valid  [i]     ),
            .mac_lane_i_wfm          (mac_lane_i_wfm        [i]     ),
            .mac_lane_o_bias_ready   (mac_lane_o_bias_ready [i]     ),
            .mac_lane_i_bias_valid   (mac_lane_i_bias_valid [i]     ),
            .mac_lane_i_bias         (mac_lane_i_bias       [i]     ),
            .mac_lane_i_ofm_ready    (mac_lane_i_ofm_ready          ),
            .mac_lane_o_ofm_valid    (mac_lane_o_ofm_valid  [i]     ),
            .mac_lane_o_ofm          (mac_lane_o_ofm        [i]     ),
            .mac_lane_o_monitor      (mac_lane_o_monitor    [i]     )
        );
    end
endgenerate

generate
    for (genvar i=0; i<64; i++) begin
        assign mac_o_ofm.data[i*64 +: 64] = mac_lane_o_ofm[i].data;
    end
endgenerate
assign mac_o_ofm.is_last = mac_lane_o_ofm[0].output_end;


endmodule
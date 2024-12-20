
package tx_pkg;

import mac_pkg::*;

parameter TX_MAC_W_ELEMENT = 9;

typedef struct packed {
    mac_datatype    ifm_datatype;
    mac_datatype    wfm_datatype;
    logic           bias_enable ; 
    logic           bias_mode   ;
} tx_mac_instruction_port;

typedef struct packed {
    logic   [TX_MAC_W_ELEMENT*64-1:0]  data;
    logic   [64  -1:0]              data_element_valid;
    logic                           inter_end;
    logic                           accum_end;
} tx_mac_ifm_port;

typedef struct packed {
    logic   [TX_MAC_W_ELEMENT*64-1:0]  data;
    //logic   [64  -1:0]  lane_enable;
    logic                           is_last;
} tx_mac_wfm_port;

typedef struct packed {
    logic   [32*64-1:0] data;
} tx_mac_bias_port;

typedef struct packed {
    logic   [32*64-1:0] data;
    logic               is_last;
} tx_mac_ofm_port;

endpackage


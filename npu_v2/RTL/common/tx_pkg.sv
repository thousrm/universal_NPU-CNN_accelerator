
package tx_pkg;

import mac_pkg::*;

parameter W_DATATYPE = 3;

typedef struct packed {
    logic   [W_DATATYPE   -1:0]     ifm_datatype;
    logic   [W_DATATYPE   -1:0]     wfm_datatype;
    logic                           bias_enable ; 
    logic                           bias_mode   ; 
    
} mac_instruction_port;

typedef struct packed {
    logic   [MAC_W_ELEMENT*64-1:0]  data;
    logic   [64  -1:0]              data_element_valid;
    logic                           inter_end;
    logic                           accum_end;
} mac_ifm_port;

typedef struct packed {
    logic   [MAC_W_ELEMENT*64-1:0]  data;
    //logic   [64  -1:0]  lane_enable;
    logic                           is_last_line;
} mac_wfm_port;

endpackage


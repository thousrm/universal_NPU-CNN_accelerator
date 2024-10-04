
package tx_pkg;

import mac_pkg::*;



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


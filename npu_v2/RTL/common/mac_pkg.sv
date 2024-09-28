
package mac_pkg;

parameter MAC_W_ELEMENT = 9;

typedef struct packed {
    logic   [MAC_W_ELEMENT*64-1:0]  data;
    logic   [64  -1:0]  data_element_valid;
    logic               inter_end;
    logic               accum_end;
} mac_lane_ifm_port;

typedef struct packed {
    logic   [MAC_W_ELEMENT*64-1:0]  data;
} mac_lane_wfm_port;

typedef struct packed {
    logic   [32-1:0]    data;
} mac_lane_ofm_port;

typedef struct packed {
    logic   [32-1:0]    data;
} mac_lane_monitor;

endpackage


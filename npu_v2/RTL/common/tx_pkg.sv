
package tx_pkg;

typedef struct packed {
    logic               ready;
    logic               valid;
    logic   [9*64-1:0]  data;
    logic   [64  -1:0]  data_element_valid;
    logic               inter_end;
    logic               accum_end;
} ifm_port;

typedef struct packed {
    logic               ready;
    logic               valid;
    logic   [9*64-1:0]  data;
    logic   [64  -1:0]  lane_enable;
    logic               is_last_line;
} wfm_port;

endpackage


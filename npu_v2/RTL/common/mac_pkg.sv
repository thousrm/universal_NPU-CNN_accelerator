
package mac_pkg;

parameter MAC_W_ELEMENT = 10;
parameter MAC_W_DATATYPE = 3;

typedef enum { 
    MAC_DATATYPE_I9     ,
    MAC_DATATYPE_FP8    ,
    MAC_DATATYPE_FP16   ,
    MAC_DATATYPE_FP32
} mac_datatype;

typedef struct packed {
    logic   [MAC_W_DATATYPE-1:0]    ifm_datatype;
    logic   [MAC_W_DATATYPE-1:0]    wfm_datatype;
    logic                           bias_enable ; 
    logic                           bias_mode   ;
} mac_instruction_port;

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
    logic               is_nan;
    logic               is_inf;
} mac_lane_monitor;

endpackage


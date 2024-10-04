///////////
// In  draft version, there are only simple modules for multiplication.
// But, in alpha version, there will be modules for MBE multipliation.
///////////

module mac_multiplier_mid (
    input  logic         a_sign     ,
    input  logic [2 :0]  a_exp      ,
    input  logic [7 :0]  a_mant     ,
    input  logic         b_sign     ,
    input  logic [2 :0]  b_exp      ,
    input  logic [7 :0]  b_mant     ,
    output logic         o_sign     ,
    output logic [3 :0]  o_exp      ,
    output logic [17:0]  o_mant     
);

assign o_sign = a_sign  ^   b_sign  ;
assign o_exp  = a_exp   +   b_exp   ;
assign o_mant = a_mant  *   b_mant  ;

endmodule
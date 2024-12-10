///////////
// In  draft version, there are only simple modules for multiplication.
// But, in alpha version, there will be modules for MBE multipliation.
///////////

module mac_2s_complement #
(
    parameter WIDTH = 10
)
(
    input  logic                i_sign     ,
    input  logic [WIDTH-1:0]    i_mant     ,
    output logic                o_sign     ,
    output logic [WIDTH-1:0]    o_mant     
);

assign o_sign = i_sign;
assign o_mant = i_sign ? ~i_mant +1 : i_mant;

endmodule
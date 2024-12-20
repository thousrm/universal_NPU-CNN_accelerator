
module mac_decoder_mid
import tx_pkg::*;
(
    input  mac_datatype     i_datatype  ,
    input  logic [9-1:0]    i_data      ,
    output logic            o_iszero    ,
    output logic            o_sign      ,
    output logic [4  -1:0]  o_exp       ,
    output logic [9  -1:0]  o_mant
);

logic            pre_sign       ;
logic [4  -1:0]  pre_exp        ;
logic [10 -1:0]  pre_mant       ;
logic            is_subnormal   ;

assign pre_sign = i_datatype == MAC_DATATYPE_FP8 ? i_data[8]     : i_data[7];
assign pre_exp  = i_data[6:3];
assign pre_mant = i_datatype == MAC_DATATYPE_FP8 ? i_data[2:0]   : i_data[8:0];
assign is_subnormal = pre_exp == 0 && pre_mant != 0;

always_comb begin
    o_iszero = i_data == 0;
    o_sign   = pre_sign   ;
    o_exp    = pre_exp    ;
    if (i_datatype == MAC_DATATYPE_FP8) begin
        o_mant = {5'b0, is_subnormal, pre_mant[2:0]};
    end
    else begin
        o_mant = pre_mant;
    end
end


endmodule
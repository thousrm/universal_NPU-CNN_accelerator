
module mac_decoder_big 
import tx_pkg::*;
import mac_pkg::*;
(
    input  mac_datatype     i_datatype  ,
    input  logic [9*2-2-1:0]  i_data      ,
    output logic            o_iszero    ,
    output logic            o_sign      ,
    output logic [5  -1:0]  o_exp       ,
    output logic [11 -1:0]  o_mant
);

logic            pre_sign       ;
logic [5  -1:0]  pre_exp        ;
logic [10 -1:0]  pre_mant       ;
logic            is_subnormal   ;

assign pre_sign = i_datatype == MAC_DATATYPE_FP16 ? i_data[15]      
                : i_datatype == MAC_DATATYPE_FP8  ? i_data[ 7]      : i_data[8]     ;
assign pre_exp  = i_datatype == MAC_DATATYPE_FP16 ? i_data[14:10]   : i_data[6:3]   ;
assign pre_mant = i_datatype == MAC_DATATYPE_FP16 ? i_data[ 9: 0]   
                : i_datatype == MAC_DATATYPE_FP8  ? i_data[ 2: 0]   : i_data[8:0]   ;
assign is_subnormal = pre_exp == 0 && pre_mant != 0;

always_comb begin
    o_iszero = i_datatype == MAC_DATATYPE_FP16 ? i_data == 0      
             : i_datatype == MAC_DATATYPE_FP8  ? i_data[7:0] == 0   : i_data[8:0] == 0 ;
    o_sign   = pre_sign   ;
    o_exp    = pre_exp    ;
    if (i_datatype == MAC_DATATYPE_FP16) begin
        o_mant = {is_subnormal, pre_mant};
    end
    else if (i_datatype == MAC_DATATYPE_FP8) begin
        o_mant = {7'b0, is_subnormal, pre_mant[2:0]};
    end
    else begin
        o_mant = pre_mant;
    end
end


endmodule
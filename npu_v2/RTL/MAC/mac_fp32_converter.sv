module mac_fp32_converter
import mac_pkg::*;
# (
    parameter W_I_EXP = 6,
    parameter W_I_INT = 34,
    parameter STAGE = 2
)
(
    input  logic                i_clk           ,
    input  logic [MAC_W_DATATYPE -1:0] i_ifm_datatype  ,
    input  logic [MAC_W_DATATYPE -1:0] i_wfm_datatype  ,
    input  logic [W_I_EXP -1:0] i_exp           ,
    input  logic [W_I_INT -1:0] i_intdata       ,
    input  logic [STAGE   -1:0] i_pipe_en       ,
    output logic [32      -1:0] o_data
);

    localparam EXP = 8;
    localparam BIAS_FP32   = 127;
    localparam BIAS_FP16   =  15;
    localparam BIAS_FP8    =   7;
    localparam BIAS_ADD_FP =   8;

/// caculate bias of exp
logic [EXP  -1:0] bias_i, bias_w, bias_add, bias_total;
logic [EXP  -1:0] exp_biased, exp_is_int;

assign bias_i = i_ifm_datatype == MAC_DATATYPE_FP16 ? BIAS_FP16
            :   i_ifm_datatype == MAC_DATATYPE_FP8  ? BIAS_FP8 : 0;
assign bias_w = i_wfm_datatype == MAC_DATATYPE_FP16 ? BIAS_FP16
            :   i_wfm_datatype == MAC_DATATYPE_FP8  ? BIAS_FP8 : 0;
assign bias_add = i_ifm_datatype == MAC_DATATYPE_I9 ? W_I_INT-1 : BIAS_ADD_FP;
assign bias_total = BIAS_FP32 - bias_i - bias_w + BIAS_ADD_FP;

assign exp_is_int = i_ifm_datatype == MAC_DATATYPE_I9 ? 0 : i_exp;
assign exp_biased = exp_is_int + bias_total;


/// calculate abs
logic [W_I_INT-1 -1:0] pre_abs;
logic [W_I_INT   -1:0] abs;
logic is_zero;

assign pre_abs = i_intdata[W_I_INT-1] ? (~i_intdata[W_I_INT-2:0]) +1 : i_intdata[W_I_INT-2:0];
assign abs = {i_intdata[W_I_INT-1], pre_abs};
assign is_zero = i_intdata == 0;

/// find leading one 0
logic [5-1:0] pre_leading_one;
find_leading_one u_find_leading_one (.i_data(abs[W_I_INT-3:0]), .result(pre_leading_one));

/// pipeline 0
logic r_sign;
logic [EXP    -1:0] r_exp_biased;
logic [W_I_INT-1:0] r_abs;
logic r_is_zero;
logic [5-1:0] r_pre_leading_one;

always_ff @(posedge i_clk) begin
    if (i_pipe_en[0]) begin
        r_sign              <= i_intdata[W_I_INT-1];
        r_exp_biased        <= exp_biased       ;
        r_abs               <= abs              ;
        r_is_zero           <= is_zero          ;
        r_pre_leading_one   <= pre_leading_one  ;
    end
end

/// find leading one 1
logic [6-1:0] leading_one;

always_comb begin
    case (r_abs[W_I_INT-1:W_I_INT-2])
        2'b00   : begin leading_one = r_pre_leading_one +3; end
        2'b01   : begin leading_one = 2; end
        default : begin leading_one = 1; end
    endcase
end

/// shift & rounding
logic [W_I_INT -1:0] shifted_mant;
logic [W_I_INT -1:0] pre_mant;

assign shifted_mant = r_abs << leading_one  ;

// pipeline 1
logic r2_sign;
logic [EXP    -1:0] r2_exp_biased;
logic r2_is_zero;
logic [W_I_INT -1:0] r_shifted_mant;

always_ff @(posedge i_clk) begin
    if (i_pipe_en[1]) begin
        r2_sign         <= r_sign               ;
        r_exp_biased    <= exp_biased           ;
        r2_is_zero      <= r_is_zero            ;
        r_shifted_mant  <= shifted_mant         ;
    end
end

logic [23      -1:0] mant;
logic guard, round, sticky, lsb;

assign mant   = r_shifted_mant[W_I_INT-1 -:23];
assign lsb    = r_shifted_mant[W_I_INT-23];
assign guard  = r_shifted_mant[W_I_INT-24];
assign round  = r_shifted_mant[W_I_INT-25];
assign sticky = |r_shifted_mant[W_I_INT-26:0];

logic [EXP-1:0] fp32_exp;
logic [23 -1:0] fp32_mant;
logic is_overflow;

always_comb begin // there is no need for overflow, underflow, subnormal. because it is impossible to generate them from calculation
    is_overflow = 0;
    fp32_exp    = 0;
    fp32_mant   = 0;

    if (r2_is_zero) begin
        fp32_exp = BIAS_FP32;
        fp32_mant = 0;
    end
    else begin
        if ( guard & (lsb | guard | round | sticky)) begin
            {is_overflow, fp32_mant} = mant+1 ;
        end
        else begin
            fp32_mant = mant;
        end
        fp32_exp = r_exp_biased + is_overflow;
    end
end


assign o_data = {r2_sign, fp32_exp, fp32_mant};

endmodule
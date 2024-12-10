
module right_shifter 
#(
    parameter IN_WIDTH  = 10  ,
    parameter IN_S_WIDTH= 3   ,
    parameter OUT_WIDTH = 15  ,
    parameter TAIL_BIT  = 5   
)
(
    input  logic signed [IN_WIDTH   -1:0] i_data          ,
    input  logic        [IN_S_WIDTH -1:0] i_shift_value   ,
    output logic signed [OUT_WIDTH  -1:0] o_data
);

logic signed [OUT_WIDTH-1:0] pre_out;

assign pre_out = { i_data, {(TAIL_BIT){1'b0}} };

assign o_data = pre_out >>> i_shift_value;


endmodule
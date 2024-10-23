
module right_shifter 
#(
    parameter IN_WIDTH  = 10  ,
    parameter IN_S_WIDTH= 3   ,
    parameter OUT_WIDTH = 15  ,
    parameter IN_M_OUT  = OUT_WIDTH - IN_WIDTH
)
(
    input  logic signed [IN_WIDTH   -1:0] i_data          ,
    input  logic        [IN_S_WIDTH -1:0] i_shift_value   ,
    output logic signed [OUT_WIDTH  -1:0] o_data
);

assign o_data = { (IN_M_OUT){i_data[IN_WIDTH-1]} , i_data >>> i_shift_value };


endmodule
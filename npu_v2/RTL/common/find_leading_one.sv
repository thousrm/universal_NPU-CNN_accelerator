
module find_leading_one 
#(
    parameter WIDTH     = 6,
    parameter NUMBER    = 32
)
(
    input  logic [WIDTH*NUMBER  -1:0]     i_data_array  ,
    output logic [WIDTH         -1:0]     result
);

logic [WIDTH/2  -1:0] level0;
logic [WIDTH/4  -1:0] level1;
logic [WIDTH/8  -1:0] level2;
logic [WIDTH/16 -1:0] level3;

assign result = ~pre_result;

endmodule
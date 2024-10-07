
module find_leading_one 
#(
    parameter WIDTH     = 32,
    parameter BIT_WIDTH = 5
)
(
    input  logic [WIDTH    -1:0]     i_data          ,
    output logic [BIT_WIDTH-1:0]     result  
);

logic [WIDTH/2  -1:0] level0;
logic [WIDTH/4  -1:0] level1;
logic [WIDTH/8  -1:0] level2;
logic [WIDTH/16 -1:0] level3;

generate
    for (genvar i=0; i<WIDTH/2; i++) begin
        assign level0[i] = i_data[i*2] | i_data[i*2+1];
    end
    for (genvar i=0; i<WIDTH/4; i++) begin
        assign level1[i] = level0[i*2] | level0[i*2+1];
    end
    for (genvar i=0; i<WIDTH/8; i++) begin
        assign level2[i] = level1[i*2] | level1[i*2+1];
    end
    for (genvar i=0; i<WIDTH/16; i++) begin
        assign level3[i] = level2[i*2] | level2[i*2+1];
    end
endgenerate

logic [BIT_WIDTH-1:0] pre_result;

assign pre_result[4] = level3[1];
assign pre_result[3] = level2[ {pre_result[4], 1'b1}];
assign pre_result[2] = level1[ {pre_result[4], pre_result[3], 1'b1}];
assign pre_result[1] = level0[ {pre_result[4], pre_result[3], pre_result[2], 1'b1}];
assign pre_result[0] = i_data[ {pre_result[4], pre_result[3], pre_result[2], pre_result[1], 1'b1}];

assign result = ~pre_result;

endmodule

module find_max_4 
#(
    parameter WIDTH     = 6
)
(
    input  logic [WIDTH*4   -1:0]     i_data_array  ,
    output logic [WIDTH     -1:0]     result
);

logic [WIDTH-1:0]   data[0:3];

generate
    for (genvar i=0; i<4; i++) begin : decoding
        assign data[i] = i_data_array[i*WIDTH+:WIDTH];
    end
endgenerate

logic [5:0] compare;

assign compare[0] = data[0] > data[1];
assign compare[1] = data[0] > data[2];
assign compare[2] = data[0] > data[3];
assign compare[3] = data[1] > data[2];
assign compare[4] = data[1] > data[3];
assign compare[5] = data[2] > data[3];

logic [3:0] is_greatest;

assign is_greatest[0] =   compare[0]  &   compare[1]  &   compare[2];
assign is_greatest[1] = (~compare[0]) &   compare[3]  &   compare[4];
assign is_greatest[2] = (~compare[1]) & (~compare[3]) &   compare[5];
assign is_greatest[3] = (~compare[2]) & (~compare[4]) & (~compare[5]);

assign result = {data[0] & {(WIDTH){is_greatest[0]}}} |
                {data[1] & {(WIDTH){is_greatest[1]}}} |
                {data[2] & {(WIDTH){is_greatest[2]}}} |
                {data[3] & {(WIDTH){is_greatest[3]}}} ;

endmodule
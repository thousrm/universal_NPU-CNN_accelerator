
module find_max_64
#(
    parameter WIDTH     = 6
)
(   input  logic                     clk             ,
    input  logic [WIDTH*64 -1:0]     i_data          ,
    input  logic                     pipe_en         ,
    output logic [WIDTH    -1:0]     result  
);

logic [WIDTH    -1:0] level0  [0:15];
logic [WIDTH    -1:0] r_level0[0:15];
logic [WIDTH    -1:0] level1  [0: 3];

generate
    for (genvar i=0; i<16; i++) begin : findmax64to16
        find_max_4 #( .WIDTH (WIDTH) ) u_find_max_4_0 ( .i_data_array (i_data[i*WIDTH*4+:WIDTH*4]), .result (level0[i]) );
        always_ff @( posedge clk ) begin
            if (pipe_en) begin
                r_level0[i] <= level0[i];
            end
        end
    end

    for (genvar i=0; i<4; i++) begin : findmax16to1
        find_max_4 #( .WIDTH (WIDTH) ) u_find_max_4_1 ( .i_data_array ({r_level0[i*4+0], r_level0[i*4+1], 
                                                                        r_level0[i*4+2], r_level0[i*4+3] }), .result (level1[i]) );
    end

    find_max_4 #( .WIDTH (WIDTH) ) u_find_max_4_2 ( .i_data_array (    {level1[0], level1[1], 
                                                                        level1[2], level1[3] }), .result (result) );
endgenerate

endmodule
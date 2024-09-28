
module mac_psum_accumulator (
    output logic                mac_psum_accumulator_o_psum_ready   ,
    input  logic                mac_psum_accumulator_i_psum_valid   ,
    input  logic [32    -1:0]   mac_psum_accumulator_i_psum_data    ,
    input  logic                mac_psum_accumulator_i_inter_end    ,
    input  logic                mac_psum_accumulator_i_accum_end    ,
    output logic                mac_psum_accumulator_o_bias_ready   ,
    input  logic                mac_psum_accumulator_i_bias_valid   ,
    input  logic [32    -1:0]   mac_psum_accumulator_i_bias_data    ,
    output logic                mac_psum_accumulator_o_output_ready ,
    input  logic                mac_psum_accumulator_i_output_valid ,
    output logic [32    -1:0]   mac_psum_accumulator_o_output_data  
);







endmodule
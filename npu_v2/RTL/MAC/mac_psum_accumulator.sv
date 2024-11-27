
module mac_psum_accumulator 
#(
    
)
(
    input  logic                i_clk                               ,
    input  logic                i_reset                             ,
    input  logic                i_bias_enable                       ,
    input  logic                i_bias_mode                         , // 0: normal (same bias in ~64 cycles), 1: change bias in every cycle
    output logic                mac_psum_accumulator_o_psum_ready   ,
    input  logic                mac_psum_accumulator_i_psum_valid   ,
    input  logic [32    -1:0]   mac_psum_accumulator_i_psum_data    ,
    input  logic                mac_psum_accumulator_i_inter_end    ,
    input  logic                mac_psum_accumulator_i_accum_end    ,
    output logic                mac_psum_accumulator_o_bias_ready   ,
    input  logic                mac_psum_accumulator_i_bias_valid   ,
    input  logic [32    -1:0]   mac_psum_accumulator_i_bias_data    ,
    input  logic                mac_psum_accumulator_i_output_ready ,
    output logic                mac_psum_accumulator_o_output_valid ,
    output logic [32    -1:0]   mac_psum_accumulator_o_output_data  
);

//////////////
/// pipe
//////////////

localparam STAGE = 1;
localparam STAGE_ADD = 2;

logic               pipe_o_input_ready  ;
logic               pipe_i_input_valid  ;
logic               pipe_i_output_ready ;
logic               pipe_o_output_valid ;
logic [STAGE+STAGE_ADD-1:0]   pipe_o_pipe_ctrl    ;

pipe_ctrl # ( .STAGE (STAGE) ) u_pipe_ctrl_mac_psum_acc
    (
        .i_clk                  (i_clk                  ),
        .i_reset                (i_reset                ),
        .o_input_ready          (pipe_o_input_ready     ),
        .i_input_valid          (pipe_i_input_valid     ),
        .i_output_ready         (pipe_i_output_ready    ),
        .o_output_valid         (pipe_o_output_valid    ),
        .o_pipe_ctrl            (pipe_o_pipe_ctrl[STAGE-1:0] )
    );

logic [STAGE+STAGE_ADD-1 :0] inter_end;
logic [STAGE+STAGE_ADD-1 :0] accum_end;

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        inter_end[0]                    <= 0;
        accum_end[0]                    <= 0;
    end
    else begin
        inter_end[0]                    <= mac_psum_accumulator_i_inter_end;
        accum_end[0]                    <= mac_psum_accumulator_i_accum_end;
    end
end

generate
    for (genvar i=1; i<STAGE+STAGE_ADD; i++) begin
        always_ff @ (posedge i_clk or negedge i_reset) begin
            if (!i_reset) begin
                inter_end[i] <= 0;
                accum_end[i] <= 0;
            end
            else begin
                inter_end[i] <= inter_end[i-1];
                accum_end[i] <= accum_end[i-1];
            end
        end
    end
endgenerate



/////////////
/// bias fifo
/////////////

logic bias_o_input_ready;
logic bias_i_input_valid;
logic bias_i_output_ready;
logic bias_o_output_valid;
logic [32-1:0]  bias_o_output_data;

assign bias_i_input_valid = mac_psum_accumulator_i_bias_valid;
assign mac_psum_accumulator_o_bias_ready = bias_o_input_ready;

fifo_no_rst_data #( .WIDTH(32) ) u_fifo_mac_bias
    (
        .i_clk              ( i_clk                 ),
        .i_reset            ( i_reset               ),
        .o_input_ready      ( bias_o_input_ready    ),
        .i_input_valid      ( bias_i_input_valid    ),
        .i_input_data       ( mac_psum_accumulator_i_bias_data),
        .i_output_ready     ( bias_i_output_ready   ),
        .o_output_valid     ( bias_o_output_valid   ),
        .o_output_data      ( bias_o_output_data    )
    );


//////////////
//// fp32 adder
//////////////

logic [32-1:0] fp32_adder_input_a;
logic [32-1:0] fp32_adder_input_b;
logic [32-1:0] fp32_adder_output ;
logic fp32_adder_o_input_ready;
logic fp32_adder_i_input_valid;
logic fp32_adder_i_output_ready;
logic fp32_adder_o_output_valid;

fp32_adder u_fp32_adder (
  .clk      ( i_clk                     ),
  .rst_n    ( i_reset                   ),
  .a        ( fp32_adder_input_a        ),
  .b        ( fp32_adder_input_b        ),
  .in_ready ( fp32_adder_o_input_ready  ),
  .in_valid ( fp32_adder_i_input_valid  ),
  .result   ( fp32_adder_output         ),
  .out_ready( fp32_adder_i_output_ready ),
  .out_valid( fp32_adder_o_output_valid ),
  .out_pipe ( pipe_o_pipe_ctrl[STAGE+STAGE_ADD-1:STAGE])
);



///////////////
/// psum fifo
///////////////

logic psum_o_input_ready;
logic psum_i_input_valid;
logic psum_i_output_ready;
logic psum_o_output_valid;
logic [32-1:0]  psum_o_output_data;

fifo_no_rst_data #( .WIDTH(32), .DEPTH(64) ) u_fifo_mac_psum
    (
        .i_clk              ( i_clk                 ),
        .i_reset            ( i_reset               ),
        .o_input_ready      ( psum_o_input_ready    ),
        .i_input_valid      ( psum_i_input_valid    ),
        .i_input_data       ( fp32_adder_output     ),
        .i_output_ready     ( psum_i_output_ready   ),
        .o_output_valid     ( psum_o_output_valid   ),
        .o_output_data      ( psum_o_output_data    )
    );

/////////////
/// output fifo
/////////////

logic output_o_input_ready;
logic output_i_input_valid;
logic output_i_output_ready;
logic output_o_output_valid;
logic [32-1:0]  output_o_output_data;

fifo_no_rst_data #( .WIDTH(32) ) u_fifo_mac_output
    (
        .i_clk              ( i_clk                 ),
        .i_reset            ( i_reset               ),
        .o_input_ready      ( output_o_input_ready  ),
        .i_input_valid      ( output_i_input_valid  ),
        .i_input_data       ( fp32_adder_output     ),
        .i_output_ready     ( output_i_output_ready ),
        .o_output_valid     ( output_o_output_valid ),
        .o_output_data      ( output_o_output_data  )
    );



//////////////
//// control
//////////////

logic sel_bias_psum; // 0 : bias, 1: psum
logic pipe_i_input_a_valid;
logic pipe_i_input_b_valid;

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        sel_bias_psum   <=  0;
    end
    else if (mac_psum_accumulator_i_inter_end & mac_psum_accumulator_i_accum_end) begin
        sel_bias_psum   <=  0;
    end
    else if (mac_psum_accumulator_i_inter_end) begin
        sel_bias_psum   <=  1;
    end
end

assign pipe_i_input_a_valid = mac_psum_accumulator_i_psum_valid;
assign pipe_i_input_b_valid = sel_bias_psum ? psum_o_output_valid : (bias_o_output_valid | (~i_bias_enable));
assign pipe_i_input_valid = pipe_i_input_a_valid & pipe_i_input_b_valid;

assign bias_i_output_ready = sel_bias_psum ? 0 
                           : i_bias_mode   ? pipe_o_input_ready & pipe_i_input_a_valid
                           :                 pipe_o_input_ready & pipe_i_input_a_valid & mac_psum_accumulator_i_inter_end ;
assign psum_i_output_ready = sel_bias_psum ? pipe_o_input_ready & pipe_i_input_a_valid : 0;
assign mac_psum_accumulator_o_psum_ready = pipe_i_input_b_valid & pipe_o_input_ready;

///////
// pipeline 0
///////
logic [32-1:0] r_input_a, r_input_bias, r_input_psum;
logic r_sel_bias_psum;

always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        r_sel_bias_psum   <=  0;
    end
    else if (pipe_o_pipe_ctrl[0]) begin
        r_sel_bias_psum   <=  sel_bias_psum;
    end
end

always_ff @ (posedge i_clk) begin
    if (pipe_o_pipe_ctrl[0]) begin
        r_input_a       <= mac_psum_accumulator_i_psum_data         ;
        r_input_bias    <= i_bias_enable ? bias_o_output_data : 0   ;
        r_input_psum    <= psum_o_output_data                       ;
    end
end

assign pipe_i_output_ready = fp32_adder_o_input_ready;
assign fp32_adder_i_input_valid = pipe_o_output_valid;
assign fp32_adder_input_a = r_input_a;
assign fp32_adder_input_b = r_sel_bias_psum ? r_input_psum : r_input_bias;

assign fp32_adder_i_output_ready = accum_end[STAGE+STAGE_ADD-1] ? output_o_input_ready : psum_o_input_ready;
assign psum_i_input_valid   = accum_end[STAGE+STAGE_ADD-1] ? 0 : fp32_adder_o_output_valid;
assign output_i_input_valid = accum_end[STAGE+STAGE_ADD-1] ? fp32_adder_o_output_valid : 0;

assign output_i_output_ready = mac_psum_accumulator_i_output_ready;
assign mac_psum_accumulator_o_output_valid = output_o_output_valid;
assign mac_psum_accumulator_o_output_data = output_o_output_data;

endmodule
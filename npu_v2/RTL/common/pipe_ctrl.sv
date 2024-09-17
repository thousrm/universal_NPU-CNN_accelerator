
module pipe_ctrl 
#(
    parameter STAGE = 1
)
(
    input  logic i_clk                  ,
    input  logic i_reset                ,
    output logic o_input_ready          ,
    input  logic i_input_valid          ,
    input  logic i_output_ready         ,
    output logic o_output_valid         ,
    output logic [STAGE-1:0] o_pipe_ctrl
);

logic [STAGE  :0]   ready;
logic [STAGE  :0]   valid;
logic [STAGE  :0]   ready_valid;
logic [STAGE-1:0]   enable;

assign o_input_ready    = ready[0];
assign ready[STAGE]     = i_output_ready;
assign o_output_valid   = valid[STAGE];
assign o_pipe_ctrl      = ready_valid;

////// ready, valid assign
generate
    for (genvar i=0; i<STAGE; i++) begin
        assign ready[i] = (~enable[i]) | ready[i+1];
    end
endgenerate
assign valid = {enable, i_input_valid};
///////

generate
    for (genvar i=0; i<STAGE+1; i++) begin
        assign ready_valid[i] = ready[i] & valid[i];
    end
endgenerate

generate
    for (genvar i=0; i<STAGE; i++) begin
        always_ff @ (posedge i_clk or negedge i_reset) begin
            if (!i_reset) begin
                enable[i] <= 0;
            end
            else begin
                case ({ready_valid[i], ready_valid[i+1]})
                    2'b10 : begin enable[i] <= 1; end //push
                    2'b01 : begin enable[i] <= 0; end //pop
                endcase
            end
        end
    end
endgenerate

endmodule
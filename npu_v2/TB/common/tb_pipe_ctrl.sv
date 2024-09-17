`timescale 1ns/10ps

module tb_pipe_ctrl;

logic i_clk                  ;
logic i_reset                ;

localparam CLK_PERIOD = 10;
localparam STAGE      = 4;
initial begin
    i_clk <= 1;
    i_reset <= 0;

    #(CLK_PERIOD);
    i_reset <= 1;
end
always #(CLK_PERIOD/2) i_clk <= ~i_clk;


logic o_input_ready          ;
logic i_input_valid          ;
logic i_output_ready         ;
logic o_output_valid         ;
logic [STAGE-1:0] o_pipe_ctrl;

pipe_ctrl # (.STAGE(STAGE)) u_pipe_ctrl (.*);

initial begin
    i_input_valid   = 0;
    i_output_ready  = 0;

    #(CLK_PERIOD*1 +1);
    i_input_valid   = 1;
    i_output_ready  = 0;

    #(CLK_PERIOD*STAGE);
    i_input_valid   = 1;
    i_output_ready  = 0;

    #(CLK_PERIOD*STAGE);
    i_input_valid   = 1;
    i_output_ready  = 0;

    #(CLK_PERIOD*STAGE);
    i_input_valid   = 1;
    i_output_ready  = 1;

    #(CLK_PERIOD*STAGE);
    i_input_valid   = 0;
    i_output_ready  = 1;

    #(CLK_PERIOD*STAGE);
    i_input_valid   = 0;
    i_output_ready  = 1;

end



endmodule
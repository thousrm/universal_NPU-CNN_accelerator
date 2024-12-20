
module fifo_no_rst_data_type
#(
    parameter WIDTH = 8,
    parameter DEPTH = 2,
    parameter DEPTH_BIT = $clog2(DEPTH),
    parameter DEPTH_OCP_BIT = $clog2(DEPTH+1),
    parameter type DATA_TYPE = logic[WIDTH-1:0]
)
(
    input  logic                i_clk                  ,
    input  logic                i_reset                ,
    output logic                o_input_ready          ,
    input  logic                i_input_valid          ,
    input  DATA_TYPE            i_input_data           ,
    input  logic                i_output_ready         ,
    output logic                o_output_valid         ,
    output DATA_TYPE            o_output_data           
);

logic DATA_TYPE             mem [0:DEPTH-1];
logic [DEPTH_BIT-1:0]       wr_ptr, rd_ptr;
logic [DEPTH_OCP_BIT-1:0]   occupy;

assign o_input_ready  = occupy != DEPTH;
assign o_output_valid = occupy != 0;

logic wr_en, rd_en;
assign wr_en = o_input_ready  & i_input_valid ;
assign rd_en = i_output_ready & o_output_valid;

// wr_ptr control
always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        wr_ptr <= 0;
    end
    else if (wr_en) begin
        if (wr_ptr == DEPTH-1) begin
            wr_ptr <= 0;
        end
        else begin
            wr_ptr <= wr_ptr+1;
        end
    end
end

// rd_ptr control
always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        rd_ptr <= 0;
    end
    else if (rd_en) begin
        if (rd_ptr == DEPTH-1) begin
            rd_ptr <= 0;
        end
        else begin
            rd_ptr <= rd_ptr+1;
        end
    end
end

// occupy control
always_ff @ (posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        occupy <= 0;
    end
    else begin
        case ({wr_en, rd_en})
            2'b10 : begin occupy <= occupy+1; end // push
            2'b01 : begin occupy <= occupy-1; end // pop
        endcase
    end
end

// data control
always_ff @ (posedge i_clk) begin
    if (wr_en) begin
        mem[wr_ptr] <= i_input_data;
    end
end
assign o_output_data = mem[rd_ptr];


endmodule
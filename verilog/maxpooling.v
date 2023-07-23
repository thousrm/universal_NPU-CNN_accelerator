module maxpooling(in, en, en_mp, out, out_en, clk, reset);

input signed [7:0] in;
input en, en_mp, clk, reset;
output signed [7:0] out;
output out_en;

wire en_count, en2;
assign en_count = en & en_mp;
assign en2 = en & (~en_mp);

//comparator
reg comparator_out;
wire signed [7:0] mux_out;
always @(*) begin
    if (mux_out > in) comparator_out = 1'b0;
    else comparator_out = 1'b1;
end

reg [1:0] count;
reg count_out;
// counter
always @(posedge clk) begin
    if (!reset) begin
        count <= 0;
        count_out <= 0;
    end
    else if (en_count == 1) begin
        if (count == 2'b11) begin
            count <= count + 1'b1;
            count_out <= 1;
        end
        else begin
            count <= count + 1'b1;
            count_out <= 0;
        end
    end
    else count_out <= 0;
end


//out_en
wire en2_d;
D_FF1 D_en2(en2, en2_d, clk, reset);
assign out_en = count_out | en2_d;


//mux_in
wire com_en_and;
assign com_en_and = comparator_out & en;

wire mux_in_s;
assign mux_in_s = com_en_and | en2;

wire signed [7:0] mux_in;
assign mux_in = mux_in_s ? in : mux_out;

D_FF8 D_in(mux_in, out, clk, reset);

/*wire en_mp_d_i;
D_FF1 D_en_mp(~(en_mp), en_mp_d_i, clk, reset);*/

//mux_out
assign mux_out = (out_en) ? 8'b1000_0000 : out;



endmodule
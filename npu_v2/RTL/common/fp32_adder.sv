// ai chatbot perplexity is very good

module fp32_adder (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] a,
  input  logic [31:0] b,
  output logic        in_ready,
  input  logic        in_valid,
  output logic [31:0] result,
  input  logic        out_ready,
  output logic        out_valid
);

  // IEEE 754 FP32 format
  typedef struct packed {
    logic        sign;
    logic [7:0]  exponent;
    logic [22:0] fraction;
  } fp32_t;

  fp32_t a_fp, b_fp, result_fp;

  // Pipeline registers
  fp32_t a_fp_r, b_fp_r;
  logic  valid_r;

  // Intermediate signals
  logic [24:0] aligned_a, aligned_b;
  logic [7:0]  exp_diff;
  logic        a_larger;
  logic [24:0] sum;
  logic [7:0]  larger_exp;
  logic [4:0]  pre_leading_zeros, leading_zeros;
  logic        is_zero, is_inf, is_nan;
  logic        a_subnormal, b_subnormal;


  // pipe control
  logic [2-1:0]   pipe_en;
  pipe_ctrl #(.STAGE(2)) u_pipe_control 
(
    .i_clk                  (clk        ),
    .i_reset                (rst_n      ),
    .o_input_ready          (in_ready   ),
    .i_input_valid          (in_valid   ),
    .i_output_ready         (out_ready  ),
    .o_output_valid         (out_valid  ),
    .o_pipe_ctrl            (pipe_en    )
);



  ///////////////

  // Unpack inputs
  assign a_fp = a;
  assign b_fp = b;

  // Stage 1: Alignment and Addition

    // Check for subnormal inputs
    assign a_subnormal = (a_fp.exponent == 0) && (a_fp.fraction != 0);
    assign b_subnormal = (b_fp.exponent == 0) && (b_fp.fraction != 0);
    // Exponent difference and alignment
    assign exp_diff = (a_fp.exponent > b_fp.exponent) ? (a_fp.exponent - b_fp.exponent) : (b_fp.exponent - a_fp.exponent);
    assign a_larger = (a_fp.exponent > b_fp.exponent) || (a_fp.exponent == b_fp.exponent && a_fp.fraction >= b_fp.fraction);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      a_fp_r <= '0;
      b_fp_r <= '0;
      valid_r <= 1'b0;
      aligned_a <= '0;
      aligned_b <= '0;
      larger_exp <= '0;
      //is_zero <= 1'b0;
      is_inf <= 1'b0;
      is_nan <= 1'b0;
    end else if (pipe_en[0]) begin
      a_fp_r <= a_fp;
      b_fp_r <= b_fp;
      valid_r <= in_valid;
      
      if (a_larger) begin
        aligned_a <= a_subnormal ? {1'b0, a_fp.fraction, 1'b0} : {2'b01, a_fp.fraction};
        aligned_b <= b_subnormal ? ({1'b0, b_fp.fraction, 1'b0} >> exp_diff) : ({2'b01, b_fp.fraction} >> exp_diff);
        larger_exp <= a_subnormal ? 8'd1 : a_fp.exponent;
      end else begin
        aligned_a <= b_subnormal ? {1'b0, b_fp.fraction, 1'b0} : {2'b01, b_fp.fraction};
        aligned_b <= a_subnormal ? ({1'b0, a_fp.fraction, 1'b0} >> exp_diff) : ({2'b01, a_fp.fraction} >> exp_diff);
        larger_exp <= b_subnormal ? 8'd1 : b_fp.exponent;
      end

      // Special cases
      //is_zero <= (a_fp.exponent == 0 && a_fp.fraction == 0) && (b_fp.exponent == 0 && b_fp.fraction == 0);
      is_inf <= (a_fp.exponent == 8'hFF && a_fp.fraction == 0) || (b_fp.exponent == 8'hFF && b_fp.fraction == 0);
      is_nan <= (a_fp.exponent == 8'hFF && a_fp.fraction != 0) || (b_fp.exponent == 8'hFF && b_fp.fraction != 0);
    end
  end

  // Stage 2: Normalization and Rounding
  find_leading_one u_find_leading_one (.i_data({7'd0, sum[24:0]}), .result(pre_leading_zeros));

  always_comb begin
    leading_zeros = pre_leading_zeros - 8;
    sum = (a_fp_r.sign == b_fp_r.sign) ? (aligned_a + aligned_b) : (aligned_a - aligned_b);

    if (/*is_zero ||*/ sum == 0) begin
    result_fp = '0;
    end else if (is_inf) begin
    result_fp.sign = a_fp_r.sign;
    result_fp.exponent = 8'hFF;
    result_fp.fraction = '0;
    end else if (is_nan) begin
    result_fp.sign = 1'b0;
    result_fp.exponent = 8'hFF;
    result_fp.fraction = 23'h400000; // Quiet NaN
    end else begin
    

    // Normalization
    //$display("start normalization");

    if (sum[24]) begin
        //$display("sum[24]==1");
        result_fp.fraction = sum[23:1];
        result_fp.exponent = larger_exp + 1;
    end else begin
        result_fp.fraction = sum[22:0] << leading_zeros;
        result_fp.exponent = larger_exp - leading_zeros;
    end

    // Handle subnormal results
    if (result_fp.exponent <= leading_zeros) begin
        //$display("result_fp.exponent = leading_zeros");
        result_fp.fraction = sum[22:0] >> (leading_zeros - result_fp.exponent + 1);
        result_fp.exponent = 8'h00;
    end

    result_fp.sign = a_larger ? a_fp_r.sign : b_fp_r.sign;
    end
  end


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result      <= 0;
            //out_valid   <= 0;
        end
        else if (pipe_en[1])begin
            result      <= result_fp;
            //out_valid   <= valid_r;
        end
    end

endmodule
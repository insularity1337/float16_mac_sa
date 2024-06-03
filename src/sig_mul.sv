module sig_mul #(parameter bit EN_OUT_FF = 1'b0) (
  input                     CLK ,
  input                     RSTn,
  input        [ 1:0][10:0] F   ,
  output logic [21:0]       P
);

  logic [21:0] prod;

  always_comb
    prod = F[0] * F[1];

  generate
    if (EN_OUT_FF)
      always_ff @(/*negedge RSTn,*/ posedge CLK)
        /*if (!RSTn)
          P <= 'b0;
        else*/
          P <= prod;
    else
      always_comb
        P = prod;
  endgenerate

endmodule
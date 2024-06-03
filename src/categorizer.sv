module categorizer #(parameter bit EN_OUT_FF = 1'b0) (
  input                      CLK        ,
  input                      RSTn       ,
  input               [15:0] F          ,
  output logic        [ 5:0] TYPE       , // 5 - normal, 4 - subnormal, 3 - zero, 2 - infinity, 1 - quiet Nan, 0 - signalling NaN
  output logic signed [ 6:0] EXPONENT   ,
  output logic        [10:0] SIGNIFICAND
);

  logic               NaNs       ;
  logic               NaNq       ;
  logic               Inf        ;
  logic               zero       ;
  logic               normal     ;
  logic               subnormal  ;
  logic signed [ 6:0] exponent   ;
  logic        [10:0] significand;

  logic exp_ones, exp_zeroes, sig_zeroes;

  // always_comb begin
  //   exp_ones   =  &F[14:10];
  //   exp_zeroes = ~|F[14:10];
  //   sig_zeroes = ~|F[ 9: 0];

  //   NaNs = exp_ones & ~sig_zeroes & ~F[9];
  //   NaNq = exp_ones & F[9];

  //   Inf = exp_ones & sig_zeroes;
  //   zero = exp_zeroes & sig_zeroes;

  //   normal = ~exp_ones & ~exp_zeroes;
  //   subnormal = exp_zeroes & ~sig_zeroes;
  // end

  assign exp_ones   =  &F[14:10];
  assign exp_zeroes = ~|F[14:10];
  assign sig_zeroes = ~|F[ 9: 0];

  assign NaNs = exp_ones & ~sig_zeroes & ~F[9];
  assign NaNq = exp_ones & F[9];

  assign Inf = exp_ones & sig_zeroes;
  assign zero = exp_zeroes & sig_zeroes;

  assign normal = ~exp_ones & ~exp_zeroes;
  assign subnormal = exp_zeroes & ~sig_zeroes;

  always_comb
    casez ({normal, F[9:0]})
      11'b1_??????????: begin
        significand = {1'b1, F[9:0]};
        exponent = F[14:10] - 15;
      end

      11'b0_1?????????: begin
        significand = F[9:0] << 1;
        exponent = -14 - 1;
      end

      11'b0_01????????: begin
        significand = F[9:0] << 2;
        exponent = -14 - 2;
      end

      11'b0_001???????: begin
        significand = F[9:0] << 3;
        exponent = -14 - 3;
      end

      11'b0_0001??????: begin
        significand = F[9:0] << 4;
        exponent = -14 - 4;
      end

      11'b0_00001?????: begin
        significand = F[9:0] << 5;
        exponent = -14 - 5;
      end

      11'b0_000001????: begin
        significand = F[9:0] << 6;
        exponent = -14 - 6;
      end

      11'b0_0000001???: begin
        significand = F[9:0] << 7;
        exponent = -14 - 7;
      end

      11'b0_00000001??: begin
        significand = F[9:0] << 8;
        exponent = -14 - 8;
      end

      11'b0_000000001?: begin
        significand = F[9:0] << 9;
        exponent = -14 - 9;
      end

      default: begin
        significand = F[9:0] << 10;
        exponent = -14 - 10;
      end
    endcase

  generate
    if (EN_OUT_FF)
      always_ff @(/*negedge RSTn, */posedge CLK)
        /*if (!RSTn) begin
          TYPE <= 'b0;
          EXPONENT <= 'b0;
          SIGNIFICAND <= 'b0;
        end else*/ begin
          TYPE[0] <= NaNs;
          TYPE[1] <= NaNq;
          TYPE[2] <= Inf;
          TYPE[3] <= zero;
          TYPE[4] <= subnormal;
          TYPE[5] <= normal;

          EXPONENT    <= exponent;
          SIGNIFICAND <= significand;
        end
    else
      always_comb begin
        TYPE[0] = NaNs;
        TYPE[1] = NaNq;
        TYPE[2] = Inf;
        TYPE[3] = zero;
        TYPE[4] = subnormal;
        TYPE[5] = normal;

        EXPONENT    = exponent;
        SIGNIFICAND = significand;
      end
  endgenerate

endmodule
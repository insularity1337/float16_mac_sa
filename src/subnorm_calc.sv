module subnorm_calc #(parameter bit EN_OUT_FF = 1'b0) (
  input                      CLK                ,
  input                      RSTn               ,
  input               [ 5:0] EXTR_TYPE          ,
  input               [15:0] EXTR_DATA          ,
  input                      SUB_V              ,
  input                      SIGN               ,
  input        signed [ 6:0] EXPONENT_PRODUCT   ,
  input               [10:0] SIGNIFICAND_PRODUCT,
  output logic        [ 5:0] P_TYPE             ,
  output logic        [15:0] P
);

  logic [ 5:0] p_type;
  logic [15:0] p     ;

  always_comb begin
    if (|EXTR_TYPE[3:0]) begin
        p_type = EXTR_TYPE;
        p = EXTR_DATA;
    end else if (SUB_V) begin
        p_type = 6'b010000;

        p[15   ] = SIGN;
        p[14:10] = 'b0;

        case (-24 - EXPONENT_PRODUCT)
          7'd10  : p[9:0] = SIGNIFICAND_PRODUCT >> 10;
          7'd9   : p[9:0] = SIGNIFICAND_PRODUCT >>  9;
          7'd8   : p[9:0] = SIGNIFICAND_PRODUCT >>  8;
          7'd7   : p[9:0] = SIGNIFICAND_PRODUCT >>  7;
          7'd6   : p[9:0] = SIGNIFICAND_PRODUCT >>  6;
          7'd5   : p[9:0] = SIGNIFICAND_PRODUCT >>  5;
          7'd4   : p[9:0] = SIGNIFICAND_PRODUCT >>  4;
          7'd3   : p[9:0] = SIGNIFICAND_PRODUCT >>  3;
          7'd2   : p[9:0] = SIGNIFICAND_PRODUCT >>  2;
          7'd1   : p[9:0] = SIGNIFICAND_PRODUCT >>  1;
          default: p[9:0] = SIGNIFICAND_PRODUCT;
        endcase
    end else begin
      p_type = 6'b100000;
        p[15   ] = SIGN;
        p[14:10] = EXPONENT_PRODUCT;
        p[ 9: 0] = SIGNIFICAND_PRODUCT;
    end

    // case ({|EXTR_TYPE[3:0], SUB_V})
    //   2'b10: begin
    //     p_type = EXTR_TYPE;
    //     p = EXTR_DATA;
    //   end

    //   2'b01: begin
    //     p_type = 6'b010000;

    //     p[15   ] = SIGN;
    //     p[14:10] = 'b0;

    //     case (-24 - EXPONENT_PRODUCT)
    //       7'd10  : p[9:0] = SIGNIFICAND_PRODUCT >> 10;
    //       7'd9   : p[9:0] = SIGNIFICAND_PRODUCT >>  9;
    //       7'd8   : p[9:0] = SIGNIFICAND_PRODUCT >>  8;
    //       7'd7   : p[9:0] = SIGNIFICAND_PRODUCT >>  7;
    //       7'd6   : p[9:0] = SIGNIFICAND_PRODUCT >>  6;
    //       7'd5   : p[9:0] = SIGNIFICAND_PRODUCT >>  5;
    //       7'd4   : p[9:0] = SIGNIFICAND_PRODUCT >>  4;
    //       7'd3   : p[9:0] = SIGNIFICAND_PRODUCT >>  3;
    //       7'd2   : p[9:0] = SIGNIFICAND_PRODUCT >>  2;
    //       7'd1   : p[9:0] = SIGNIFICAND_PRODUCT >>  1;
    //       default: p[9:0] = SIGNIFICAND_PRODUCT;
    //     endcase
    //   end

    //   default: begin
    //     p_type = 6'b100000;
    //     p[15   ] = SIGN;
    //     p[14:10] = EXPONENT_PRODUCT + 15;
    //     p[ 9: 0] = SIGNIFICAND_PRODUCT;
    //   end
    // endcase
  end

  generate
    if (EN_OUT_FF)
      always_ff @(/*negedge RSTn,*/ posedge CLK)
        /*if (!RSTn) begin
          P_TYPE <= 'b0;
          P <= 'b0;
        end else*/ begin
          P_TYPE <= p_type;
          P <= p;
        end
    else
      always_comb begin
        P_TYPE = p_type;
        P = p;
      end
  endgenerate

endmodule
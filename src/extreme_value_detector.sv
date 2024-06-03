module extreme_value_detector #(parameter bit EN_OUT_FF = 1'b0) (
  input                     CLK   ,
  input                     RSTn  ,
  input        [ 1:0][ 5:0] TYPES , // 5 - normal, 4 - subnormal, 3 - zero, 2 - infinity, 1 - quiet Nan, 0 - signalling NaN
  input        [ 1:0][15:0] F     ,
  output logic [ 5:0]       P_TYPE,
  output logic [15:0]       P
);

  logic sign;

  logic [15:0] nans        ;
  logic [15:0] nanq        ;
  logic [15:0] inf         ;
  logic [15:0] zero_or_subs;

  logic        p_nans;
  logic        p_nanq;
  logic        p_inf ;
  logic        p_zero;
  logic [15:0] p     ;

  always_comb begin
    sign = F[0][15] ^ F[1][15];

    if (|{TYPES[1][0], TYPES[0][0]}) begin
      if (TYPES[0][0])
        nans = F[0];
      else
        nans = F[1];

      p_nans = 1'b1;
    end else begin
      nans = 'b0;
      p_nans = 1'b0;
    end

    if ((|{TYPES[1][1], TYPES[0][1]}) || (|{TYPES[1][2], TYPES[0][2]} && |{TYPES[1][3], TYPES[0][3]}))
      p_nanq = 1'b1;
    else
      p_nanq = 1'b0;

    if ((|{TYPES[1][2], TYPES[0][2]}) && (|{TYPES[1][3], TYPES[0][3]}))
      nanq = {sign, {5{1'b1}}, 1'b1, {9{1'b0}}};
    else if (|{TYPES[1][1], TYPES[0][1]}) begin
      if (TYPES[0][1])
        nanq = F[0];
      else
        nanq = F[1];
    end else
      nanq = 'b0;

    // if (|{TYPES[1][1], TYPES[0][1]}) begin
    //   if (TYPES[0][1])
    //     nanq = F[0];
    //   else
    //     nanq = F[1];

    //   p_nanq = 1'b1;
    // end else begin
    //   nanq = 'b0;
    //   p_nanq = 1'b0;
    // end

    if ((|{TYPES[1][2], TYPES[0][2]}) && !(|{TYPES[1][3], TYPES[0][3]})) begin
      inf = {sign, {5{1'b1}}, {10{1'b0}}};
      p_inf = 1'b1;
    end else begin
      inf = 'b0;
      p_inf = 1'b0;
    end

    // if (|{TYPES[1][2], TYPES[0][2]}) begin
    //   inf = {sign, {5{1'b1}}, |{TYPES[1][3], TYPES[0][3]}, 9'h000};
    //   p_inf = 1'b1;
    // end else begin
    //   inf = 'b0;
    //   p_inf = 1'b0;
    // end

    if (|{TYPES[1][3], TYPES[0][3]} || &{TYPES[1][4], TYPES[0][4]}) begin
      zero_or_subs = {sign, {15{1'b0}}};
      p_zero = 1'b1;
    end else begin
      zero_or_subs = 'b0;
      p_zero = 1'b0;
    end
  end

  logic [5:0] p_type;

  always_comb begin
    if (p_nans)
      p_type = 6'b000001;
    else if (p_nanq)
      p_type = 6'b000010;
    else if (p_inf)
      p_type = 6'b000100;
    else if (p_zero)
      p_type = 6'b001000;
    else
      p_type = 'b0;

    case (p_type)
      6'b000001: p = nans;
      6'b000010: p = nanq;
      6'b000100: p = inf;
      default  : p = zero_or_subs;
    endcase
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
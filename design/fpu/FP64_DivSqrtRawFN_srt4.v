module FP64_SrtTable(
  input  [2:0] io_d,
  input  [7:0] io_y,
  output [2:0] io_q
);
  wire  _T_1 = $signed(io_y) >= 8'sh18; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_3 = $signed(io_y) >= 8'sh8; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_5 = $signed(io_y) >= -8'sh8; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_7 = $signed(io_y) >= -8'sh1a; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_9 = $signed(io_y) >= 8'sh1c; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_11 = $signed(io_y) >= -8'sha; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_13 = $signed(io_y) >= -8'sh1c; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_15 = $signed(io_y) >= 8'sh20; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_17 = $signed(io_y) >= -8'shc; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_19 = $signed(io_y) >= -8'sh20; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_21 = $signed(io_y) >= -8'sh22; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_23 = $signed(io_y) >= 8'sh24; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_25 = $signed(io_y) >= 8'shc; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_27 = $signed(io_y) >= -8'sh24; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_29 = $signed(io_y) >= 8'sh28; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_31 = $signed(io_y) >= -8'sh10; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_33 = $signed(io_y) >= -8'sh28; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_35 = $signed(io_y) >= 8'sh10; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_37 = $signed(io_y) >= -8'sh2c; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_39 = $signed(io_y) >= 8'sh30; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire  _T_41 = $signed(io_y) >= -8'sh2e; // @[DivSqrtRecFN_srt4.scala 29:58]
  wire [2:0] _T_42 = _T_7 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_43 = _T_5 ? $signed(3'sh0) : $signed(_T_42); // @[Mux.scala 98:16]
  wire [2:0] _T_44 = _T_3 ? $signed(3'sh1) : $signed(_T_43); // @[Mux.scala 98:16]
  wire [2:0] _T_45 = _T_1 ? $signed(3'sh2) : $signed(_T_44); // @[Mux.scala 98:16]
  wire [2:0] _T_46 = _T_13 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_47 = _T_11 ? $signed(3'sh0) : $signed(_T_46); // @[Mux.scala 98:16]
  wire [2:0] _T_48 = _T_3 ? $signed(3'sh1) : $signed(_T_47); // @[Mux.scala 98:16]
  wire [2:0] _T_49 = _T_9 ? $signed(3'sh2) : $signed(_T_48); // @[Mux.scala 98:16]
  wire [2:0] _T_50 = _T_19 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_51 = _T_17 ? $signed(3'sh0) : $signed(_T_50); // @[Mux.scala 98:16]
  wire [2:0] _T_52 = _T_3 ? $signed(3'sh1) : $signed(_T_51); // @[Mux.scala 98:16]
  wire [2:0] _T_53 = _T_15 ? $signed(3'sh2) : $signed(_T_52); // @[Mux.scala 98:16]
  wire [2:0] _T_54 = _T_21 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_55 = _T_17 ? $signed(3'sh0) : $signed(_T_54); // @[Mux.scala 98:16]
  wire [2:0] _T_56 = _T_3 ? $signed(3'sh1) : $signed(_T_55); // @[Mux.scala 98:16]
  wire [2:0] _T_57 = _T_15 ? $signed(3'sh2) : $signed(_T_56); // @[Mux.scala 98:16]
  wire [2:0] _T_58 = _T_27 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_59 = _T_17 ? $signed(3'sh0) : $signed(_T_58); // @[Mux.scala 98:16]
  wire [2:0] _T_60 = _T_25 ? $signed(3'sh1) : $signed(_T_59); // @[Mux.scala 98:16]
  wire [2:0] _T_61 = _T_23 ? $signed(3'sh2) : $signed(_T_60); // @[Mux.scala 98:16]
  wire [2:0] _T_62 = _T_33 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_63 = _T_31 ? $signed(3'sh0) : $signed(_T_62); // @[Mux.scala 98:16]
  wire [2:0] _T_64 = _T_25 ? $signed(3'sh1) : $signed(_T_63); // @[Mux.scala 98:16]
  wire [2:0] _T_65 = _T_29 ? $signed(3'sh2) : $signed(_T_64); // @[Mux.scala 98:16]
  wire [2:0] _T_66 = _T_37 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_67 = _T_31 ? $signed(3'sh0) : $signed(_T_66); // @[Mux.scala 98:16]
  wire [2:0] _T_68 = _T_35 ? $signed(3'sh1) : $signed(_T_67); // @[Mux.scala 98:16]
  wire [2:0] _T_69 = _T_29 ? $signed(3'sh2) : $signed(_T_68); // @[Mux.scala 98:16]
  wire [2:0] _T_70 = _T_41 ? $signed(-3'sh1) : $signed(-3'sh2); // @[Mux.scala 98:16]
  wire [2:0] _T_71 = _T_31 ? $signed(3'sh0) : $signed(_T_70); // @[Mux.scala 98:16]
  wire [2:0] _T_72 = _T_35 ? $signed(3'sh1) : $signed(_T_71); // @[Mux.scala 98:16]
  wire [2:0] _T_73 = _T_39 ? $signed(3'sh2) : $signed(_T_72); // @[Mux.scala 98:16]
  wire  _T_74 = 3'h1 == io_d; // @[Mux.scala 80:60]
  wire [2:0] _T_75 = _T_74 ? $signed(_T_49) : $signed(_T_45); // @[Mux.scala 80:57]
  wire  _T_76 = 3'h2 == io_d; // @[Mux.scala 80:60]
  wire [2:0] _T_77 = _T_76 ? $signed(_T_53) : $signed(_T_75); // @[Mux.scala 80:57]
  wire  _T_78 = 3'h3 == io_d; // @[Mux.scala 80:60]
  wire [2:0] _T_79 = _T_78 ? $signed(_T_57) : $signed(_T_77); // @[Mux.scala 80:57]
  wire  _T_80 = 3'h4 == io_d; // @[Mux.scala 80:60]
  wire [2:0] _T_81 = _T_80 ? $signed(_T_61) : $signed(_T_79); // @[Mux.scala 80:57]
  wire  _T_82 = 3'h5 == io_d; // @[Mux.scala 80:60]
  wire [2:0] _T_83 = _T_82 ? $signed(_T_65) : $signed(_T_81); // @[Mux.scala 80:57]
  wire  _T_84 = 3'h6 == io_d; // @[Mux.scala 80:60]
  wire [2:0] _T_85 = _T_84 ? $signed(_T_69) : $signed(_T_83); // @[Mux.scala 80:57]
  wire  _T_86 = 3'h7 == io_d; // @[Mux.scala 80:60]
  assign io_q = _T_86 ? $signed(_T_73) : $signed(_T_85); // @[DivSqrtRecFN_srt4.scala 35:8]
endmodule
module FP64_OnTheFlyConv(
  input         clock,
  input         io_resetSqrt,
  input         io_resetDiv,
  input         io_enable,
  input  [2:0]  io_qi,
  output [59:0] io_QM,
  output [59:0] io_Q,
  output [59:0] io_F
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
`endif // RANDOMIZE_REG_INIT
  reg [59:0] Q; // @[DivSqrtRecFN_srt4.scala 57:18]
  reg [59:0] QM; // @[DivSqrtRecFN_srt4.scala 57:18]
  reg [59:0] mask; // @[DivSqrtRecFN_srt4.scala 63:17]
  reg [59:0] b_111; // @[DivSqrtRecFN_srt4.scala 64:26]
  reg [59:0] b_1100; // @[DivSqrtRecFN_srt4.scala 64:26]
  wire [57:0] _T_4 = mask[59:2]; // @[DivSqrtRecFN_srt4.scala 70:18]
  reg [56:0] b_01; // @[DivSqrtRecFN_srt4.scala 74:35]
  reg [56:0] b_10; // @[DivSqrtRecFN_srt4.scala 74:35]
  reg [56:0] b_11; // @[DivSqrtRecFN_srt4.scala 74:35]
  wire  _T_7 = io_resetDiv | io_resetSqrt; // @[DivSqrtRecFN_srt4.scala 76:20]
  wire [59:0] negQ = ~Q; // @[DivSqrtRecFN_srt4.scala 86:14]
  wire [1:0] _T_16 = io_qi[0] ? 2'h1 : 2'h2; // @[DivSqrtRecFN_srt4.scala 94:25]
  wire [62:0] _GEN_18 = {{3'd0}, negQ}; // @[DivSqrtRecFN_srt4.scala 94:19]
  wire [62:0] _T_17 = _GEN_18 << _T_16; // @[DivSqrtRecFN_srt4.scala 94:19]
  wire [59:0] _T_20 = $signed(mask) >>> io_qi[0]; // @[DivSqrtRecFN_srt4.scala 94:83]
  wire [62:0] _GEN_19 = {{3'd0}, _T_20}; // @[DivSqrtRecFN_srt4.scala 94:56]
  wire [62:0] _T_21 = _T_17 & _GEN_19; // @[DivSqrtRecFN_srt4.scala 94:56]
  wire [62:0] _GEN_20 = {{3'd0}, b_111}; // @[DivSqrtRecFN_srt4.scala 94:87]
  wire [62:0] _T_22 = _T_21 | _GEN_20; // @[DivSqrtRecFN_srt4.scala 94:87]
  wire [62:0] _GEN_23 = {{3'd0}, b_1100}; // @[DivSqrtRecFN_srt4.scala 94:87]
  wire [62:0] _T_31 = _T_21 | _GEN_23; // @[DivSqrtRecFN_srt4.scala 94:87]
  wire [62:0] _GEN_24 = {{3'd0}, QM}; // @[DivSqrtRecFN_srt4.scala 94:19]
  wire [62:0] _T_35 = _GEN_24 << _T_16; // @[DivSqrtRecFN_srt4.scala 94:19]
  wire [62:0] _T_39 = _T_35 & _GEN_19; // @[DivSqrtRecFN_srt4.scala 94:56]
  wire [62:0] _T_40 = _T_39 | _GEN_20; // @[DivSqrtRecFN_srt4.scala 94:87]
  wire [62:0] _T_49 = _T_39 | _GEN_23; // @[DivSqrtRecFN_srt4.scala 94:87]
  wire  _T_51 = 3'h1 == io_qi; // @[Mux.scala 80:60]
  wire [62:0] _T_52 = _T_51 ? _T_22 : 63'h0; // @[Mux.scala 80:57]
  wire  _T_53 = 3'h2 == io_qi; // @[Mux.scala 80:60]
  wire [62:0] _T_54 = _T_53 ? _T_31 : _T_52; // @[Mux.scala 80:57]
  wire  _T_55 = 3'h7 == io_qi; // @[Mux.scala 80:60]
  wire [62:0] _T_56 = _T_55 ? _T_40 : _T_54; // @[Mux.scala 80:57]
  wire  _T_57 = 3'h6 == io_qi; // @[Mux.scala 80:60]
  wire [62:0] sqrtToCsa = _T_57 ? _T_49 : _T_56; // @[Mux.scala 80:57]
  wire [59:0] _GEN_30 = {{3'd0}, b_01}; // @[DivSqrtRecFN_srt4.scala 99:21]
  wire [59:0] Q_load_01 = Q | _GEN_30; // @[DivSqrtRecFN_srt4.scala 99:21]
  wire [59:0] _GEN_31 = {{3'd0}, b_10}; // @[DivSqrtRecFN_srt4.scala 100:21]
  wire [59:0] Q_load_10 = Q | _GEN_31; // @[DivSqrtRecFN_srt4.scala 100:21]
  wire [59:0] QM_load_01 = QM | _GEN_30; // @[DivSqrtRecFN_srt4.scala 101:23]
  wire [59:0] QM_load_10 = QM | _GEN_31; // @[DivSqrtRecFN_srt4.scala 102:23]
  wire [59:0] _GEN_34 = {{3'd0}, b_11}; // @[DivSqrtRecFN_srt4.scala 103:23]
  wire [59:0] QM_load_11 = QM | _GEN_34; // @[DivSqrtRecFN_srt4.scala 103:23]
  wire  _T_70 = 3'h0 == io_qi; // @[Mux.scala 80:60]
  assign io_QM = QM; // @[DivSqrtRecFN_srt4.scala 131:9]
  assign io_Q = Q; // @[DivSqrtRecFN_srt4.scala 132:8]
  assign io_F = sqrtToCsa[59:0]; // @[DivSqrtRecFN_srt4.scala 130:8]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  Q = _RAND_0[59:0];
  _RAND_1 = {2{`RANDOM}};
  QM = _RAND_1[59:0];
  _RAND_2 = {2{`RANDOM}};
  mask = _RAND_2[59:0];
  _RAND_3 = {2{`RANDOM}};
  b_111 = _RAND_3[59:0];
  _RAND_4 = {2{`RANDOM}};
  b_1100 = _RAND_4[59:0];
  _RAND_5 = {2{`RANDOM}};
  b_01 = _RAND_5[56:0];
  _RAND_6 = {2{`RANDOM}};
  b_10 = _RAND_6[56:0];
  _RAND_7 = {2{`RANDOM}};
  b_11 = _RAND_7[56:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (io_resetSqrt) begin
      Q <= 60'h200000000000000;
    end else if (io_resetDiv) begin
      Q <= 60'h0;
    end else if (io_enable) begin
      if (_T_57) begin
        Q <= QM_load_10;
      end else if (_T_55) begin
        Q <= QM_load_11;
      end else if (_T_53) begin
        Q <= Q_load_10;
      end else if (_T_51) begin
        Q <= Q_load_01;
      end else if (!(_T_70)) begin
        Q <= 60'h0;
      end
    end
    if (io_resetSqrt) begin
      QM <= 60'h0;
    end else if (io_resetDiv) begin
      QM <= 60'h0;
    end else if (io_enable) begin
      if (_T_57) begin
        QM <= QM_load_01;
      end else if (_T_55) begin
        QM <= QM_load_10;
      end else if (_T_53) begin
        QM <= Q_load_01;
      end else if (_T_51) begin
        QM <= Q;
      end else if (_T_70) begin
        QM <= QM_load_11;
      end else begin
        QM <= 60'h0;
      end
    end
    if (io_resetSqrt) begin
      mask <= -60'sh800000000000000;
    end else if (io_enable) begin
      mask <= {{2{_T_4[57]}},_T_4};
    end
    if (io_resetSqrt) begin
      b_111 <= 60'h380000000000000;
    end else if (io_enable) begin
      b_111 <= {{2'd0}, b_111[59:2]};
    end
    if (io_resetSqrt) begin
      b_1100 <= 60'h600000000000000;
    end else if (io_enable) begin
      b_1100 <= {{2'd0}, b_1100[59:2]};
    end
    if (_T_7) begin
      b_01 <= 57'h80000000000000;
    end else if (io_enable) begin
      b_01 <= {{2'd0}, b_01[56:2]};
    end
    if (_T_7) begin
      b_10 <= 57'h100000000000000;
    end else if (io_enable) begin
      b_10 <= {{2'd0}, b_10[56:2]};
    end
    if (_T_7) begin
      b_11 <= 57'h180000000000000;
    end else if (io_enable) begin
      b_11 <= {{2'd0}, b_11[56:2]};
    end
  end
endmodule
module FP64_CSA3_2(
  input  [60:0] io_in_0,
  input  [60:0] io_in_1,
  input  [60:0] io_in_2,
  output [60:0] io_out_0,
  output [60:0] io_out_1
);
  wire  _T_3 = io_in_0[0] ^ io_in_1[0]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_4 = io_in_0[0] & io_in_1[0]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_5 = _T_3 ^ io_in_2[0]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_6 = _T_3 & io_in_2[0]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_7 = _T_4 | _T_6; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_0 = {_T_7,_T_5}; // @[Cat.scala 30:58]
  wire  _T_12 = io_in_0[1] ^ io_in_1[1]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_13 = io_in_0[1] & io_in_1[1]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_14 = _T_12 ^ io_in_2[1]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_15 = _T_12 & io_in_2[1]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_16 = _T_13 | _T_15; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_1 = {_T_16,_T_14}; // @[Cat.scala 30:58]
  wire  _T_21 = io_in_0[2] ^ io_in_1[2]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_22 = io_in_0[2] & io_in_1[2]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_23 = _T_21 ^ io_in_2[2]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_24 = _T_21 & io_in_2[2]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_25 = _T_22 | _T_24; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_2 = {_T_25,_T_23}; // @[Cat.scala 30:58]
  wire  _T_30 = io_in_0[3] ^ io_in_1[3]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_31 = io_in_0[3] & io_in_1[3]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_32 = _T_30 ^ io_in_2[3]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_33 = _T_30 & io_in_2[3]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_34 = _T_31 | _T_33; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_3 = {_T_34,_T_32}; // @[Cat.scala 30:58]
  wire  _T_39 = io_in_0[4] ^ io_in_1[4]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_40 = io_in_0[4] & io_in_1[4]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_41 = _T_39 ^ io_in_2[4]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_42 = _T_39 & io_in_2[4]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_43 = _T_40 | _T_42; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_4 = {_T_43,_T_41}; // @[Cat.scala 30:58]
  wire  _T_48 = io_in_0[5] ^ io_in_1[5]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_49 = io_in_0[5] & io_in_1[5]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_50 = _T_48 ^ io_in_2[5]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_51 = _T_48 & io_in_2[5]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_52 = _T_49 | _T_51; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_5 = {_T_52,_T_50}; // @[Cat.scala 30:58]
  wire  _T_57 = io_in_0[6] ^ io_in_1[6]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_58 = io_in_0[6] & io_in_1[6]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_59 = _T_57 ^ io_in_2[6]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_60 = _T_57 & io_in_2[6]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_61 = _T_58 | _T_60; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_6 = {_T_61,_T_59}; // @[Cat.scala 30:58]
  wire  _T_66 = io_in_0[7] ^ io_in_1[7]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_67 = io_in_0[7] & io_in_1[7]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_68 = _T_66 ^ io_in_2[7]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_69 = _T_66 & io_in_2[7]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_70 = _T_67 | _T_69; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_7 = {_T_70,_T_68}; // @[Cat.scala 30:58]
  wire  _T_75 = io_in_0[8] ^ io_in_1[8]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_76 = io_in_0[8] & io_in_1[8]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_77 = _T_75 ^ io_in_2[8]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_78 = _T_75 & io_in_2[8]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_79 = _T_76 | _T_78; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_8 = {_T_79,_T_77}; // @[Cat.scala 30:58]
  wire  _T_84 = io_in_0[9] ^ io_in_1[9]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_85 = io_in_0[9] & io_in_1[9]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_86 = _T_84 ^ io_in_2[9]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_87 = _T_84 & io_in_2[9]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_88 = _T_85 | _T_87; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_9 = {_T_88,_T_86}; // @[Cat.scala 30:58]
  wire  _T_93 = io_in_0[10] ^ io_in_1[10]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_94 = io_in_0[10] & io_in_1[10]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_95 = _T_93 ^ io_in_2[10]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_96 = _T_93 & io_in_2[10]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_97 = _T_94 | _T_96; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_10 = {_T_97,_T_95}; // @[Cat.scala 30:58]
  wire  _T_102 = io_in_0[11] ^ io_in_1[11]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_103 = io_in_0[11] & io_in_1[11]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_104 = _T_102 ^ io_in_2[11]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_105 = _T_102 & io_in_2[11]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_106 = _T_103 | _T_105; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_11 = {_T_106,_T_104}; // @[Cat.scala 30:58]
  wire  _T_111 = io_in_0[12] ^ io_in_1[12]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_112 = io_in_0[12] & io_in_1[12]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_113 = _T_111 ^ io_in_2[12]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_114 = _T_111 & io_in_2[12]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_115 = _T_112 | _T_114; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_12 = {_T_115,_T_113}; // @[Cat.scala 30:58]
  wire  _T_120 = io_in_0[13] ^ io_in_1[13]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_121 = io_in_0[13] & io_in_1[13]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_122 = _T_120 ^ io_in_2[13]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_123 = _T_120 & io_in_2[13]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_124 = _T_121 | _T_123; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_13 = {_T_124,_T_122}; // @[Cat.scala 30:58]
  wire  _T_129 = io_in_0[14] ^ io_in_1[14]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_130 = io_in_0[14] & io_in_1[14]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_131 = _T_129 ^ io_in_2[14]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_132 = _T_129 & io_in_2[14]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_133 = _T_130 | _T_132; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_14 = {_T_133,_T_131}; // @[Cat.scala 30:58]
  wire  _T_138 = io_in_0[15] ^ io_in_1[15]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_139 = io_in_0[15] & io_in_1[15]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_140 = _T_138 ^ io_in_2[15]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_141 = _T_138 & io_in_2[15]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_142 = _T_139 | _T_141; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_15 = {_T_142,_T_140}; // @[Cat.scala 30:58]
  wire  _T_147 = io_in_0[16] ^ io_in_1[16]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_148 = io_in_0[16] & io_in_1[16]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_149 = _T_147 ^ io_in_2[16]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_150 = _T_147 & io_in_2[16]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_151 = _T_148 | _T_150; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_16 = {_T_151,_T_149}; // @[Cat.scala 30:58]
  wire  _T_156 = io_in_0[17] ^ io_in_1[17]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_157 = io_in_0[17] & io_in_1[17]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_158 = _T_156 ^ io_in_2[17]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_159 = _T_156 & io_in_2[17]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_160 = _T_157 | _T_159; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_17 = {_T_160,_T_158}; // @[Cat.scala 30:58]
  wire  _T_165 = io_in_0[18] ^ io_in_1[18]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_166 = io_in_0[18] & io_in_1[18]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_167 = _T_165 ^ io_in_2[18]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_168 = _T_165 & io_in_2[18]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_169 = _T_166 | _T_168; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_18 = {_T_169,_T_167}; // @[Cat.scala 30:58]
  wire  _T_174 = io_in_0[19] ^ io_in_1[19]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_175 = io_in_0[19] & io_in_1[19]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_176 = _T_174 ^ io_in_2[19]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_177 = _T_174 & io_in_2[19]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_178 = _T_175 | _T_177; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_19 = {_T_178,_T_176}; // @[Cat.scala 30:58]
  wire  _T_183 = io_in_0[20] ^ io_in_1[20]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_184 = io_in_0[20] & io_in_1[20]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_185 = _T_183 ^ io_in_2[20]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_186 = _T_183 & io_in_2[20]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_187 = _T_184 | _T_186; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_20 = {_T_187,_T_185}; // @[Cat.scala 30:58]
  wire  _T_192 = io_in_0[21] ^ io_in_1[21]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_193 = io_in_0[21] & io_in_1[21]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_194 = _T_192 ^ io_in_2[21]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_195 = _T_192 & io_in_2[21]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_196 = _T_193 | _T_195; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_21 = {_T_196,_T_194}; // @[Cat.scala 30:58]
  wire  _T_201 = io_in_0[22] ^ io_in_1[22]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_202 = io_in_0[22] & io_in_1[22]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_203 = _T_201 ^ io_in_2[22]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_204 = _T_201 & io_in_2[22]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_205 = _T_202 | _T_204; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_22 = {_T_205,_T_203}; // @[Cat.scala 30:58]
  wire  _T_210 = io_in_0[23] ^ io_in_1[23]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_211 = io_in_0[23] & io_in_1[23]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_212 = _T_210 ^ io_in_2[23]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_213 = _T_210 & io_in_2[23]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_214 = _T_211 | _T_213; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_23 = {_T_214,_T_212}; // @[Cat.scala 30:58]
  wire  _T_219 = io_in_0[24] ^ io_in_1[24]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_220 = io_in_0[24] & io_in_1[24]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_221 = _T_219 ^ io_in_2[24]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_222 = _T_219 & io_in_2[24]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_223 = _T_220 | _T_222; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_24 = {_T_223,_T_221}; // @[Cat.scala 30:58]
  wire  _T_228 = io_in_0[25] ^ io_in_1[25]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_229 = io_in_0[25] & io_in_1[25]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_230 = _T_228 ^ io_in_2[25]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_231 = _T_228 & io_in_2[25]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_232 = _T_229 | _T_231; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_25 = {_T_232,_T_230}; // @[Cat.scala 30:58]
  wire  _T_237 = io_in_0[26] ^ io_in_1[26]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_238 = io_in_0[26] & io_in_1[26]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_239 = _T_237 ^ io_in_2[26]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_240 = _T_237 & io_in_2[26]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_241 = _T_238 | _T_240; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_26 = {_T_241,_T_239}; // @[Cat.scala 30:58]
  wire  _T_246 = io_in_0[27] ^ io_in_1[27]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_247 = io_in_0[27] & io_in_1[27]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_248 = _T_246 ^ io_in_2[27]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_249 = _T_246 & io_in_2[27]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_250 = _T_247 | _T_249; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_27 = {_T_250,_T_248}; // @[Cat.scala 30:58]
  wire  _T_255 = io_in_0[28] ^ io_in_1[28]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_256 = io_in_0[28] & io_in_1[28]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_257 = _T_255 ^ io_in_2[28]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_258 = _T_255 & io_in_2[28]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_259 = _T_256 | _T_258; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_28 = {_T_259,_T_257}; // @[Cat.scala 30:58]
  wire  _T_264 = io_in_0[29] ^ io_in_1[29]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_265 = io_in_0[29] & io_in_1[29]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_266 = _T_264 ^ io_in_2[29]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_267 = _T_264 & io_in_2[29]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_268 = _T_265 | _T_267; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_29 = {_T_268,_T_266}; // @[Cat.scala 30:58]
  wire  _T_273 = io_in_0[30] ^ io_in_1[30]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_274 = io_in_0[30] & io_in_1[30]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_275 = _T_273 ^ io_in_2[30]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_276 = _T_273 & io_in_2[30]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_277 = _T_274 | _T_276; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_30 = {_T_277,_T_275}; // @[Cat.scala 30:58]
  wire  _T_282 = io_in_0[31] ^ io_in_1[31]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_283 = io_in_0[31] & io_in_1[31]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_284 = _T_282 ^ io_in_2[31]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_285 = _T_282 & io_in_2[31]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_286 = _T_283 | _T_285; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_31 = {_T_286,_T_284}; // @[Cat.scala 30:58]
  wire  _T_291 = io_in_0[32] ^ io_in_1[32]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_292 = io_in_0[32] & io_in_1[32]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_293 = _T_291 ^ io_in_2[32]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_294 = _T_291 & io_in_2[32]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_295 = _T_292 | _T_294; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_32 = {_T_295,_T_293}; // @[Cat.scala 30:58]
  wire  _T_300 = io_in_0[33] ^ io_in_1[33]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_301 = io_in_0[33] & io_in_1[33]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_302 = _T_300 ^ io_in_2[33]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_303 = _T_300 & io_in_2[33]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_304 = _T_301 | _T_303; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_33 = {_T_304,_T_302}; // @[Cat.scala 30:58]
  wire  _T_309 = io_in_0[34] ^ io_in_1[34]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_310 = io_in_0[34] & io_in_1[34]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_311 = _T_309 ^ io_in_2[34]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_312 = _T_309 & io_in_2[34]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_313 = _T_310 | _T_312; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_34 = {_T_313,_T_311}; // @[Cat.scala 30:58]
  wire  _T_318 = io_in_0[35] ^ io_in_1[35]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_319 = io_in_0[35] & io_in_1[35]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_320 = _T_318 ^ io_in_2[35]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_321 = _T_318 & io_in_2[35]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_322 = _T_319 | _T_321; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_35 = {_T_322,_T_320}; // @[Cat.scala 30:58]
  wire  _T_327 = io_in_0[36] ^ io_in_1[36]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_328 = io_in_0[36] & io_in_1[36]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_329 = _T_327 ^ io_in_2[36]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_330 = _T_327 & io_in_2[36]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_331 = _T_328 | _T_330; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_36 = {_T_331,_T_329}; // @[Cat.scala 30:58]
  wire  _T_336 = io_in_0[37] ^ io_in_1[37]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_337 = io_in_0[37] & io_in_1[37]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_338 = _T_336 ^ io_in_2[37]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_339 = _T_336 & io_in_2[37]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_340 = _T_337 | _T_339; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_37 = {_T_340,_T_338}; // @[Cat.scala 30:58]
  wire  _T_345 = io_in_0[38] ^ io_in_1[38]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_346 = io_in_0[38] & io_in_1[38]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_347 = _T_345 ^ io_in_2[38]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_348 = _T_345 & io_in_2[38]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_349 = _T_346 | _T_348; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_38 = {_T_349,_T_347}; // @[Cat.scala 30:58]
  wire  _T_354 = io_in_0[39] ^ io_in_1[39]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_355 = io_in_0[39] & io_in_1[39]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_356 = _T_354 ^ io_in_2[39]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_357 = _T_354 & io_in_2[39]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_358 = _T_355 | _T_357; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_39 = {_T_358,_T_356}; // @[Cat.scala 30:58]
  wire  _T_363 = io_in_0[40] ^ io_in_1[40]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_364 = io_in_0[40] & io_in_1[40]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_365 = _T_363 ^ io_in_2[40]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_366 = _T_363 & io_in_2[40]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_367 = _T_364 | _T_366; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_40 = {_T_367,_T_365}; // @[Cat.scala 30:58]
  wire  _T_372 = io_in_0[41] ^ io_in_1[41]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_373 = io_in_0[41] & io_in_1[41]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_374 = _T_372 ^ io_in_2[41]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_375 = _T_372 & io_in_2[41]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_376 = _T_373 | _T_375; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_41 = {_T_376,_T_374}; // @[Cat.scala 30:58]
  wire  _T_381 = io_in_0[42] ^ io_in_1[42]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_382 = io_in_0[42] & io_in_1[42]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_383 = _T_381 ^ io_in_2[42]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_384 = _T_381 & io_in_2[42]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_385 = _T_382 | _T_384; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_42 = {_T_385,_T_383}; // @[Cat.scala 30:58]
  wire  _T_390 = io_in_0[43] ^ io_in_1[43]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_391 = io_in_0[43] & io_in_1[43]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_392 = _T_390 ^ io_in_2[43]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_393 = _T_390 & io_in_2[43]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_394 = _T_391 | _T_393; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_43 = {_T_394,_T_392}; // @[Cat.scala 30:58]
  wire  _T_399 = io_in_0[44] ^ io_in_1[44]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_400 = io_in_0[44] & io_in_1[44]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_401 = _T_399 ^ io_in_2[44]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_402 = _T_399 & io_in_2[44]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_403 = _T_400 | _T_402; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_44 = {_T_403,_T_401}; // @[Cat.scala 30:58]
  wire  _T_408 = io_in_0[45] ^ io_in_1[45]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_409 = io_in_0[45] & io_in_1[45]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_410 = _T_408 ^ io_in_2[45]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_411 = _T_408 & io_in_2[45]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_412 = _T_409 | _T_411; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_45 = {_T_412,_T_410}; // @[Cat.scala 30:58]
  wire  _T_417 = io_in_0[46] ^ io_in_1[46]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_418 = io_in_0[46] & io_in_1[46]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_419 = _T_417 ^ io_in_2[46]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_420 = _T_417 & io_in_2[46]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_421 = _T_418 | _T_420; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_46 = {_T_421,_T_419}; // @[Cat.scala 30:58]
  wire  _T_426 = io_in_0[47] ^ io_in_1[47]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_427 = io_in_0[47] & io_in_1[47]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_428 = _T_426 ^ io_in_2[47]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_429 = _T_426 & io_in_2[47]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_430 = _T_427 | _T_429; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_47 = {_T_430,_T_428}; // @[Cat.scala 30:58]
  wire  _T_435 = io_in_0[48] ^ io_in_1[48]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_436 = io_in_0[48] & io_in_1[48]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_437 = _T_435 ^ io_in_2[48]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_438 = _T_435 & io_in_2[48]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_439 = _T_436 | _T_438; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_48 = {_T_439,_T_437}; // @[Cat.scala 30:58]
  wire  _T_444 = io_in_0[49] ^ io_in_1[49]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_445 = io_in_0[49] & io_in_1[49]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_446 = _T_444 ^ io_in_2[49]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_447 = _T_444 & io_in_2[49]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_448 = _T_445 | _T_447; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_49 = {_T_448,_T_446}; // @[Cat.scala 30:58]
  wire  _T_453 = io_in_0[50] ^ io_in_1[50]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_454 = io_in_0[50] & io_in_1[50]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_455 = _T_453 ^ io_in_2[50]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_456 = _T_453 & io_in_2[50]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_457 = _T_454 | _T_456; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_50 = {_T_457,_T_455}; // @[Cat.scala 30:58]
  wire  _T_462 = io_in_0[51] ^ io_in_1[51]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_463 = io_in_0[51] & io_in_1[51]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_464 = _T_462 ^ io_in_2[51]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_465 = _T_462 & io_in_2[51]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_466 = _T_463 | _T_465; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_51 = {_T_466,_T_464}; // @[Cat.scala 30:58]
  wire  _T_471 = io_in_0[52] ^ io_in_1[52]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_472 = io_in_0[52] & io_in_1[52]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_473 = _T_471 ^ io_in_2[52]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_474 = _T_471 & io_in_2[52]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_475 = _T_472 | _T_474; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_52 = {_T_475,_T_473}; // @[Cat.scala 30:58]
  wire  _T_480 = io_in_0[53] ^ io_in_1[53]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_481 = io_in_0[53] & io_in_1[53]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_482 = _T_480 ^ io_in_2[53]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_483 = _T_480 & io_in_2[53]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_484 = _T_481 | _T_483; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_53 = {_T_484,_T_482}; // @[Cat.scala 30:58]
  wire  _T_489 = io_in_0[54] ^ io_in_1[54]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_490 = io_in_0[54] & io_in_1[54]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_491 = _T_489 ^ io_in_2[54]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_492 = _T_489 & io_in_2[54]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_493 = _T_490 | _T_492; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_54 = {_T_493,_T_491}; // @[Cat.scala 30:58]
  wire  _T_498 = io_in_0[55] ^ io_in_1[55]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_499 = io_in_0[55] & io_in_1[55]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_500 = _T_498 ^ io_in_2[55]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_501 = _T_498 & io_in_2[55]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_502 = _T_499 | _T_501; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_55 = {_T_502,_T_500}; // @[Cat.scala 30:58]
  wire  _T_507 = io_in_0[56] ^ io_in_1[56]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_508 = io_in_0[56] & io_in_1[56]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_509 = _T_507 ^ io_in_2[56]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_510 = _T_507 & io_in_2[56]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_511 = _T_508 | _T_510; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_56 = {_T_511,_T_509}; // @[Cat.scala 30:58]
  wire  _T_516 = io_in_0[57] ^ io_in_1[57]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_517 = io_in_0[57] & io_in_1[57]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_518 = _T_516 ^ io_in_2[57]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_519 = _T_516 & io_in_2[57]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_520 = _T_517 | _T_519; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_57 = {_T_520,_T_518}; // @[Cat.scala 30:58]
  wire  _T_525 = io_in_0[58] ^ io_in_1[58]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_526 = io_in_0[58] & io_in_1[58]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_527 = _T_525 ^ io_in_2[58]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_528 = _T_525 & io_in_2[58]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_529 = _T_526 | _T_528; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_58 = {_T_529,_T_527}; // @[Cat.scala 30:58]
  wire  _T_534 = io_in_0[59] ^ io_in_1[59]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_535 = io_in_0[59] & io_in_1[59]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_536 = _T_534 ^ io_in_2[59]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_537 = _T_534 & io_in_2[59]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_538 = _T_535 | _T_537; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_59 = {_T_538,_T_536}; // @[Cat.scala 30:58]
  wire  _T_543 = io_in_0[60] ^ io_in_1[60]; // @[ArrayMultiplier.scala 28:21]
  wire  _T_544 = io_in_0[60] & io_in_1[60]; // @[ArrayMultiplier.scala 29:21]
  wire  _T_545 = _T_543 ^ io_in_2[60]; // @[ArrayMultiplier.scala 30:23]
  wire  _T_546 = _T_543 & io_in_2[60]; // @[ArrayMultiplier.scala 31:35]
  wire  _T_547 = _T_544 | _T_546; // @[ArrayMultiplier.scala 31:24]
  wire [1:0] temp_60 = {_T_547,_T_545}; // @[Cat.scala 30:58]
  wire [6:0] _T_615 = {temp_6[0],temp_5[0],temp_4[0],temp_3[0],temp_2[0],temp_1[0],temp_0[0]}; // @[Cat.scala 30:58]
  wire [14:0] _T_623 = {temp_14[0],temp_13[0],temp_12[0],temp_11[0],temp_10[0],temp_9[0],temp_8[0],temp_7[0],_T_615}; // @[Cat.scala 30:58]
  wire [6:0] _T_629 = {temp_21[0],temp_20[0],temp_19[0],temp_18[0],temp_17[0],temp_16[0],temp_15[0]}; // @[Cat.scala 30:58]
  wire [29:0] _T_638 = {temp_29[0],temp_28[0],temp_27[0],temp_26[0],temp_25[0],temp_24[0],temp_23[0],temp_22[0],_T_629,_T_623}; // @[Cat.scala 30:58]
  wire [6:0] _T_644 = {temp_36[0],temp_35[0],temp_34[0],temp_33[0],temp_32[0],temp_31[0],temp_30[0]}; // @[Cat.scala 30:58]
  wire [14:0] _T_652 = {temp_44[0],temp_43[0],temp_42[0],temp_41[0],temp_40[0],temp_39[0],temp_38[0],temp_37[0],_T_644}; // @[Cat.scala 30:58]
  wire [7:0] _T_659 = {temp_52[0],temp_51[0],temp_50[0],temp_49[0],temp_48[0],temp_47[0],temp_46[0],temp_45[0]}; // @[Cat.scala 30:58]
  wire [30:0] _T_668 = {temp_60[0],temp_59[0],temp_58[0],temp_57[0],temp_56[0],temp_55[0],temp_54[0],temp_53[0],_T_659,_T_652}; // @[Cat.scala 30:58]
  wire [6:0] _T_736 = {temp_6[1],temp_5[1],temp_4[1],temp_3[1],temp_2[1],temp_1[1],temp_0[1]}; // @[Cat.scala 30:58]
  wire [14:0] _T_744 = {temp_14[1],temp_13[1],temp_12[1],temp_11[1],temp_10[1],temp_9[1],temp_8[1],temp_7[1],_T_736}; // @[Cat.scala 30:58]
  wire [6:0] _T_750 = {temp_21[1],temp_20[1],temp_19[1],temp_18[1],temp_17[1],temp_16[1],temp_15[1]}; // @[Cat.scala 30:58]
  wire [29:0] _T_759 = {temp_29[1],temp_28[1],temp_27[1],temp_26[1],temp_25[1],temp_24[1],temp_23[1],temp_22[1],_T_750,_T_744}; // @[Cat.scala 30:58]
  wire [6:0] _T_765 = {temp_36[1],temp_35[1],temp_34[1],temp_33[1],temp_32[1],temp_31[1],temp_30[1]}; // @[Cat.scala 30:58]
  wire [14:0] _T_773 = {temp_44[1],temp_43[1],temp_42[1],temp_41[1],temp_40[1],temp_39[1],temp_38[1],temp_37[1],_T_765}; // @[Cat.scala 30:58]
  wire [7:0] _T_780 = {temp_52[1],temp_51[1],temp_50[1],temp_49[1],temp_48[1],temp_47[1],temp_46[1],temp_45[1]}; // @[Cat.scala 30:58]
  wire [30:0] _T_789 = {temp_60[1],temp_59[1],temp_58[1],temp_57[1],temp_56[1],temp_55[1],temp_54[1],temp_53[1],_T_780,_T_773}; // @[Cat.scala 30:58]
  assign io_out_0 = {_T_668,_T_638}; // @[ArrayMultiplier.scala 34:48]
  assign io_out_1 = {_T_789,_T_759}; // @[ArrayMultiplier.scala 34:48]
endmodule
module FP64_SigDivSqrt_srt4(
  input         clock,
  input         reset,
  input         io_kill,
  output        io_in_ready,
  input         io_in_valid,
  input  [56:0] io_in_bits_sigA,
  input  [56:0] io_in_bits_sigB,
  input         io_in_bits_isDiv,
  input  [5:0]  io_in_bits_dsCycles,
  input         io_out_ready,
  output        io_out_valid,
  output [56:0] io_out_bits_quotient,
  output        io_out_bits_isZeroRem
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
`endif // RANDOMIZE_REG_INIT
  wire [2:0] table__io_d; // @[DivSqrtRecFN_srt4.scala 189:21]
  wire [7:0] table__io_y; // @[DivSqrtRecFN_srt4.scala 189:21]
  wire [2:0] table__io_q; // @[DivSqrtRecFN_srt4.scala 189:21]
  wire  conv_clock; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire  conv_io_resetSqrt; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire  conv_io_resetDiv; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire  conv_io_enable; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire [2:0] conv_io_qi; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire [59:0] conv_io_QM; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire [59:0] conv_io_Q; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire [59:0] conv_io_F; // @[DivSqrtRecFN_srt4.scala 190:20]
  wire [60:0] csa_io_in_0; // @[DivSqrtRecFN_srt4.scala 191:19]
  wire [60:0] csa_io_in_1; // @[DivSqrtRecFN_srt4.scala 191:19]
  wire [60:0] csa_io_in_2; // @[DivSqrtRecFN_srt4.scala 191:19]
  wire [60:0] csa_io_out_0; // @[DivSqrtRecFN_srt4.scala 191:19]
  wire [60:0] csa_io_out_1; // @[DivSqrtRecFN_srt4.scala 191:19]
  wire  _T = io_in_ready & io_in_valid; // @[Decoupled.scala 40:37]
  reg  isDivReg; // @[Reg.scala 15:16]
  reg [56:0] divisor; // @[Reg.scala 15:16]
  reg [1:0] state; // @[DivSqrtRecFN_srt4.scala 161:22]
  wire  _T_2 = state == 2'h0; // @[DivSqrtRecFN_srt4.scala 165:38]
  wire  _T_3 = state == 2'h1; // @[DivSqrtRecFN_srt4.scala 165:56]
  wire  _T_4 = _T_2 | _T_3; // @[DivSqrtRecFN_srt4.scala 165:48]
  reg [4:0] cnt; // @[Reg.scala 15:16]
  wire [4:0] _T_7 = cnt - 5'h1; // @[DivSqrtRecFN_srt4.scala 166:62]
  wire [5:0] _T_8 = _T_2 ? io_in_bits_dsCycles : {{1'd0}, _T_7}; // @[DivSqrtRecFN_srt4.scala 166:18]
  wire [4:0] cnt_next = _T_8[4:0]; // @[DivSqrtRecFN_srt4.scala 164:22 DivSqrtRecFN_srt4.scala 166:12]
  reg  firstCycle; // @[DivSqrtRecFN_srt4.scala 169:27]
  wire  _T_10 = 2'h0 == state; // @[Conditional.scala 37:30]
  wire  _T_12 = 2'h1 == state; // @[Conditional.scala 37:30]
  wire  _T_13 = cnt_next == 5'h0; // @[DivSqrtRecFN_srt4.scala 176:21]
  wire  _T_14 = 2'h2 == state; // @[Conditional.scala 37:30]
  wire  _T_15 = 2'h3 == state; // @[Conditional.scala 37:30]
  reg [60:0] ws; // @[DivSqrtRecFN_srt4.scala 187:19]
  reg [60:0] wc; // @[DivSqrtRecFN_srt4.scala 187:19]
  wire [57:0] S = conv_io_Q[59:2]; // @[DivSqrtRecFN_srt4.scala 194:21]
  wire  s4 = S[51]; // @[DivSqrtRecFN_srt4.scala 195:67]
  wire  s3 = S[52]; // @[DivSqrtRecFN_srt4.scala 195:67]
  wire  s2 = S[53]; // @[DivSqrtRecFN_srt4.scala 195:67]
  wire  s0 = S[55]; // @[DivSqrtRecFN_srt4.scala 195:67]
  wire [2:0] _T_19 = {s2,s3,s4}; // @[Cat.scala 30:58]
  wire [2:0] _T_20 = s0 ? 3'h7 : _T_19; // @[DivSqrtRecFN_srt4.scala 196:50]
  wire [2:0] sqrt_d = firstCycle ? 3'h5 : _T_20; // @[DivSqrtRecFN_srt4.scala 196:19]
  wire [2:0] div_d = divisor[55:53]; // @[DivSqrtRecFN_srt4.scala 197:22]
  wire [7:0] sqrt_y = ws[60:53] + wc[60:53]; // @[DivSqrtRecFN_srt4.scala 198:33]
  wire [7:0] div_y = ws[59:52] + wc[59:52]; // @[DivSqrtRecFN_srt4.scala 199:32]
  wire  _T_30 = ~io_in_bits_isDiv; // @[DivSqrtRecFN_srt4.scala 204:40]
  wire [57:0] _T_35 = {divisor, 1'h0}; // @[DivSqrtRecFN_srt4.scala 211:18]
  wire [60:0] dx1 = {{4'd0}, divisor}; // @[DivSqrtRecFN_srt4.scala 209:40 DivSqrtRecFN_srt4.scala 210:7]
  wire [60:0] neg_dx1 = ~dx1; // @[DivSqrtRecFN_srt4.scala 212:14]
  wire [61:0] _T_37 = {neg_dx1, 1'h0}; // @[DivSqrtRecFN_srt4.scala 213:22]
  wire  _T_43 = 3'h7 == table__io_q; // @[Mux.scala 80:60]
  wire [60:0] _T_44 = _T_43 ? dx1 : 61'h0; // @[Mux.scala 80:57]
  wire  _T_45 = 3'h6 == table__io_q; // @[Mux.scala 80:60]
  wire [60:0] dx2 = {{3'd0}, _T_35}; // @[DivSqrtRecFN_srt4.scala 209:40 DivSqrtRecFN_srt4.scala 211:7]
  wire [60:0] _T_46 = _T_45 ? dx2 : _T_44; // @[Mux.scala 80:57]
  wire  _T_47 = 3'h1 == table__io_q; // @[Mux.scala 80:60]
  wire [60:0] _T_48 = _T_47 ? neg_dx1 : _T_46; // @[Mux.scala 80:57]
  wire  _T_49 = 3'h2 == table__io_q; // @[Mux.scala 80:60]
  wire [60:0] neg_dx2 = _T_37[60:0]; // @[DivSqrtRecFN_srt4.scala 209:40 DivSqrtRecFN_srt4.scala 213:11]
  wire [60:0] divCsaIn = _T_49 ? neg_dx2 : _T_48; // @[Mux.scala 80:57]
  wire  _T_51 = ~table__io_q[2]; // @[DivSqrtRecFN_srt4.scala 223:34]
  wire  _T_52 = isDivReg & _T_51; // @[DivSqrtRecFN_srt4.scala 223:32]
  wire [60:0] _GEN_17 = {{59'd0}, table__io_q[1:0]}; // @[DivSqrtRecFN_srt4.scala 223:54]
  wire [60:0] _T_54 = wc | _GEN_17; // @[DivSqrtRecFN_srt4.scala 223:54]
  wire [58:0] _T_57 = {2'h0,io_in_bits_sigA}; // @[Cat.scala 30:58]
  wire [58:0] _T_60 = _T_57 - 59'h200000000000000; // @[DivSqrtRecFN_srt4.scala 227:42]
  wire [60:0] sqrtWsInit = {_T_60,2'h0}; // @[Cat.scala 30:58]
  wire [60:0] _T_62 = io_in_bits_isDiv ? {{4'd0}, io_in_bits_sigA} : sqrtWsInit; // @[DivSqrtRecFN_srt4.scala 230:14]
  wire [62:0] _T_65 = {csa_io_out_0, 2'h0}; // @[DivSqrtRecFN_srt4.scala 233:62]
  wire [62:0] _T_66 = _T_13 ? {{2'd0}, csa_io_out_0} : _T_65; // @[DivSqrtRecFN_srt4.scala 233:14]
  wire [61:0] _T_68 = {csa_io_out_1, 1'h0}; // @[DivSqrtRecFN_srt4.scala 234:47]
  wire [63:0] _T_69 = {csa_io_out_1, 3'h0}; // @[DivSqrtRecFN_srt4.scala 234:67]
  wire [63:0] _T_70 = _T_13 ? {{2'd0}, _T_68} : _T_69; // @[DivSqrtRecFN_srt4.scala 234:14]
  wire [62:0] _GEN_11 = _T_3 ? _T_66 : {{2'd0}, ws}; // @[DivSqrtRecFN_srt4.scala 232:37]
  wire [63:0] _GEN_12 = _T_3 ? _T_70 : {{3'd0}, wc}; // @[DivSqrtRecFN_srt4.scala 232:37]
  wire [62:0] _GEN_13 = _T ? {{2'd0}, _T_62} : _GEN_11; // @[DivSqrtRecFN_srt4.scala 229:21]
  wire [63:0] _GEN_14 = _T ? 64'h0 : _GEN_12; // @[DivSqrtRecFN_srt4.scala 229:21]
  wire [60:0] rem = ws + wc; // @[DivSqrtRecFN_srt4.scala 237:16]
  wire  _T_74 = state == 2'h2; // @[DivSqrtRecFN_srt4.scala 245:57]
  reg  remSignReg; // @[Reg.scala 15:16]
  wire  _T_75 = rem == 61'h0; // @[DivSqrtRecFN_srt4.scala 246:35]
  reg  isZeroRemReg; // @[Reg.scala 15:16]
  wire [59:0] _T_79 = remSignReg ? conv_io_QM : conv_io_Q; // @[DivSqrtRecFN_srt4.scala 250:30]
  wire  _T_80 = ~isDivReg; // @[DivSqrtRecFN_srt4.scala 250:73]
  wire [1:0] _T_81 = {_T_80,1'h0}; // @[Cat.scala 30:58]
  wire [59:0] _T_82 = _T_79 >> _T_81; // @[DivSqrtRecFN_srt4.scala 250:66]
  FP64_SrtTable FP64_table_ ( // @[DivSqrtRecFN_srt4.scala 189:21]
    .io_d(table__io_d),
    .io_y(table__io_y),
    .io_q(table__io_q)
  );
  FP64_OnTheFlyConv FP64_conv ( // @[DivSqrtRecFN_srt4.scala 190:20]
    .clock(conv_clock),
    .io_resetSqrt(conv_io_resetSqrt),
    .io_resetDiv(conv_io_resetDiv),
    .io_enable(conv_io_enable),
    .io_qi(conv_io_qi),
    .io_QM(conv_io_QM),
    .io_Q(conv_io_Q),
    .io_F(conv_io_F)
  );
  FP64_CSA3_2 FP64_csa ( // @[DivSqrtRecFN_srt4.scala 191:19]
    .io_in_0(csa_io_in_0),
    .io_in_1(csa_io_in_1),
    .io_in_2(csa_io_in_2),
    .io_out_0(csa_io_out_0),
    .io_out_1(csa_io_out_1)
  );
  assign io_in_ready = state == 2'h0; // @[DivSqrtRecFN_srt4.scala 248:15]
  assign io_out_valid = state == 2'h3; // @[DivSqrtRecFN_srt4.scala 249:16]
  assign io_out_bits_quotient = _T_82[56:0]; // @[DivSqrtRecFN_srt4.scala 250:24]
  assign io_out_bits_isZeroRem = isZeroRemReg; // @[DivSqrtRecFN_srt4.scala 251:25]
  assign table__io_d = isDivReg ? div_d : sqrt_d; // @[DivSqrtRecFN_srt4.scala 201:14]
  assign table__io_y = isDivReg ? div_y : sqrt_y; // @[DivSqrtRecFN_srt4.scala 202:14]
  assign conv_clock = clock;
  assign conv_io_resetSqrt = _T & _T_30; // @[DivSqrtRecFN_srt4.scala 204:21]
  assign conv_io_resetDiv = _T & io_in_bits_isDiv; // @[DivSqrtRecFN_srt4.scala 205:20]
  assign conv_io_enable = state == 2'h1; // @[DivSqrtRecFN_srt4.scala 206:18]
  assign conv_io_qi = table__io_q; // @[DivSqrtRecFN_srt4.scala 207:14]
  assign csa_io_in_0 = ws; // @[DivSqrtRecFN_srt4.scala 222:16]
  assign csa_io_in_1 = _T_52 ? _T_54 : wc; // @[DivSqrtRecFN_srt4.scala 223:16]
  assign csa_io_in_2 = isDivReg ? divCsaIn : {{1'd0}, conv_io_F}; // @[DivSqrtRecFN_srt4.scala 224:16]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  isDivReg = _RAND_0[0:0];
  _RAND_1 = {2{`RANDOM}};
  divisor = _RAND_1[56:0];
  _RAND_2 = {1{`RANDOM}};
  state = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  cnt = _RAND_3[4:0];
  _RAND_4 = {1{`RANDOM}};
  firstCycle = _RAND_4[0:0];
  _RAND_5 = {2{`RANDOM}};
  ws = _RAND_5[60:0];
  _RAND_6 = {2{`RANDOM}};
  wc = _RAND_6[60:0];
  _RAND_7 = {1{`RANDOM}};
  remSignReg = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  isZeroRemReg = _RAND_8[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (_T) begin
      isDivReg <= io_in_bits_isDiv;
    end
    if (_T) begin
      divisor <= io_in_bits_sigB;
    end
    if (reset) begin
      state <= 2'h0;
    end else if (io_kill) begin
      state <= 2'h0;
    end else if (_T_10) begin
      if (_T) begin
        state <= 2'h1;
      end
    end else if (_T_12) begin
      if (_T_13) begin
        state <= 2'h2;
      end
    end else if (_T_14) begin
      state <= 2'h3;
    end else if (_T_15) begin
      if (io_out_valid) begin
        state <= 2'h0;
      end
    end
    if (_T_4) begin
      cnt <= cnt_next;
    end
    firstCycle <= io_in_ready & io_in_valid;
    ws <= _GEN_13[60:0];
    wc <= _GEN_14[60:0];
    if (_T_74) begin
      remSignReg <= rem[60];
    end
    if (_T_74) begin
      isZeroRemReg <= _T_75;
    end
  end
endmodule
module FP64_DivSqrtRawFN_srt4(
  input         clock,
  input         reset,
  output        io_inReady,
  input         io_inValid,
  input         io_sqrtOp,
  input         io_a_isNaN,
  input         io_a_isInf,
  input         io_a_isZero,
  input         io_a_sign,
  input  [12:0] io_a_sExp,
  input  [53:0] io_a_sig,
  input         io_b_isNaN,
  input         io_b_isInf,
  input         io_b_isZero,
  input         io_b_sign,
  input  [12:0] io_b_sExp,
  input  [53:0] io_b_sig,
  input  [2:0]  io_roundingMode,
  input  [5:0]  io_sigBits,
  input         io_kill,
  output        io_rawOutValid_div,
  output        io_rawOutValid_sqrt,
  output [2:0]  io_roundingModeOut,
  output        io_invalidExc,
  output        io_infiniteExc,
  output        io_rawOut_isNaN,
  output        io_rawOut_isInf,
  output        io_rawOut_isZero,
  output        io_rawOut_sign,
  output [12:0] io_rawOut_sExp,
  output [55:0] io_rawOut_sig
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
`endif // RANDOMIZE_REG_INIT
  wire  sigDs_clock; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_reset; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_io_kill; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_io_in_ready; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_io_in_valid; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire [56:0] sigDs_io_in_bits_sigA; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire [56:0] sigDs_io_in_bits_sigB; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_io_in_bits_isDiv; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire [5:0] sigDs_io_in_bits_dsCycles; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_io_out_ready; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_io_out_valid; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire [56:0] sigDs_io_out_bits_quotient; // @[DivSqrtRecFN_srt4.scala 383:21]
  wire  sigDs_io_out_bits_isZeroRem; // @[DivSqrtRecFN_srt4.scala 383:21]
  reg  sqrtOp_Z; // @[DivSqrtRecFN_srt4.scala 277:27]
  reg  majorExc_Z; // @[DivSqrtRecFN_srt4.scala 278:27]
  reg  isNaN_Z; // @[DivSqrtRecFN_srt4.scala 280:27]
  reg  isInf_Z; // @[DivSqrtRecFN_srt4.scala 281:27]
  reg  isZero_Z; // @[DivSqrtRecFN_srt4.scala 282:27]
  reg  sign_Z; // @[DivSqrtRecFN_srt4.scala 283:27]
  reg [12:0] sExp_Z; // @[DivSqrtRecFN_srt4.scala 284:27]
  reg [2:0] roundingMode_Z; // @[DivSqrtRecFN_srt4.scala 286:27]
  wire  _T = io_a_isZero & io_b_isZero; // @[DivSqrtRecFN_srt4.scala 296:20]
  wire  _T_1 = io_a_isInf & io_b_isInf; // @[DivSqrtRecFN_srt4.scala 296:55]
  wire  notSigNaNIn_invalidExc_S_div = _T | _T_1; // @[DivSqrtRecFN_srt4.scala 296:38]
  wire  _T_2 = ~io_a_isNaN; // @[DivSqrtRecFN_srt4.scala 300:5]
  wire  _T_3 = ~io_a_isZero; // @[DivSqrtRecFN_srt4.scala 300:23]
  wire  _T_4 = _T_2 & _T_3; // @[DivSqrtRecFN_srt4.scala 300:20]
  wire  notSigNaNIn_invalidExc_S_sqrt = _T_4 & io_a_sign; // @[DivSqrtRecFN_srt4.scala 300:39]
  wire  _T_6 = ~io_a_sig[51]; // @[common.scala 84:49]
  wire  _T_7 = io_a_isNaN & _T_6; // @[common.scala 84:46]
  wire  _T_8 = _T_7 | notSigNaNIn_invalidExc_S_sqrt; // @[DivSqrtRecFN_srt4.scala 309:32]
  wire  _T_13 = ~io_b_sig[51]; // @[common.scala 84:49]
  wire  _T_14 = io_b_isNaN & _T_13; // @[common.scala 84:46]
  wire  _T_15 = _T_7 | _T_14; // @[DivSqrtRecFN_srt4.scala 310:32]
  wire  _T_16 = _T_15 | notSigNaNIn_invalidExc_S_div; // @[DivSqrtRecFN_srt4.scala 310:60]
  wire  _T_18 = ~io_a_isInf; // @[DivSqrtRecFN_srt4.scala 312:28]
  wire  _T_19 = _T_2 & _T_18; // @[DivSqrtRecFN_srt4.scala 312:25]
  wire  _T_20 = _T_19 & io_b_isZero; // @[DivSqrtRecFN_srt4.scala 312:43]
  wire  _T_21 = _T_16 | _T_20; // @[DivSqrtRecFN_srt4.scala 311:38]
  wire  _T_22 = io_a_isNaN | notSigNaNIn_invalidExc_S_sqrt; // @[DivSqrtRecFN_srt4.scala 323:20]
  wire  _T_23 = io_a_isNaN | io_b_isNaN; // @[DivSqrtRecFN_srt4.scala 324:20]
  wire  _T_24 = _T_23 | notSigNaNIn_invalidExc_S_div; // @[DivSqrtRecFN_srt4.scala 324:36]
  wire  _T_25 = io_a_isInf | io_b_isZero; // @[DivSqrtRecFN_srt4.scala 330:61]
  wire  _T_26 = io_a_isZero | io_b_isInf; // @[DivSqrtRecFN_srt4.scala 335:62]
  wire  _T_27 = ~io_sqrtOp; // @[DivSqrtRecFN_srt4.scala 339:31]
  wire  _T_28 = _T_27 & io_b_sign; // @[DivSqrtRecFN_srt4.scala 339:43]
  wire  sign_S = io_a_sign ^ _T_28; // @[DivSqrtRecFN_srt4.scala 339:28]
  wire  _T_29 = io_a_isNaN | io_a_isInf; // @[DivSqrtRecFN_srt4.scala 342:37]
  wire  specialCaseA_S = _T_29 | io_a_isZero; // @[DivSqrtRecFN_srt4.scala 342:53]
  wire  _T_30 = io_b_isNaN | io_b_isInf; // @[DivSqrtRecFN_srt4.scala 343:37]
  wire  specialCaseB_S = _T_30 | io_b_isZero; // @[DivSqrtRecFN_srt4.scala 343:53]
  wire  _T_31 = ~specialCaseA_S; // @[DivSqrtRecFN_srt4.scala 346:26]
  wire  _T_32 = ~specialCaseB_S; // @[DivSqrtRecFN_srt4.scala 346:46]
  wire  normalCase_S_div = _T_31 & _T_32; // @[DivSqrtRecFN_srt4.scala 346:43]
  wire  _T_34 = ~io_a_sign; // @[DivSqrtRecFN_srt4.scala 349:47]
  wire  normalCase_S_sqrt = _T_31 & _T_34; // @[DivSqrtRecFN_srt4.scala 349:44]
  wire  normalCase_S = io_sqrtOp ? normalCase_S_sqrt : normalCase_S_div; // @[DivSqrtRecFN_srt4.scala 351:25]
  wire [10:0] _T_37 = ~io_b_sExp[10:0]; // @[DivSqrtRecFN_srt4.scala 355:34]
  wire [11:0] _T_39 = {io_b_sExp[11],_T_37}; // @[DivSqrtRecFN_srt4.scala 355:65]
  wire [12:0] _GEN_15 = {{1{_T_39[11]}},_T_39}; // @[DivSqrtRecFN_srt4.scala 354:17]
  wire [13:0] sExpQuot_S_div = $signed(io_a_sExp) + $signed(_GEN_15); // @[DivSqrtRecFN_srt4.scala 354:17]
  wire  _T_40 = 14'she00 <= $signed(sExpQuot_S_div); // @[DivSqrtRecFN_srt4.scala 359:44]
  wire [3:0] _T_42 = _T_40 ? 4'h6 : sExpQuot_S_div[12:9]; // @[DivSqrtRecFN_srt4.scala 359:12]
  wire [12:0] sSatExpQuot_S_div = {_T_42,sExpQuot_S_div[8:0]}; // @[DivSqrtRecFN_srt4.scala 364:7]
  wire  oddSqrt_S = io_sqrtOp & io_a_sExp[0]; // @[DivSqrtRecFN_srt4.scala 368:30]
  wire  entering = io_inReady & io_inValid; // @[DivSqrtRecFN_srt4.scala 373:29]
  wire  entering_normalCase = entering & normalCase_S; // @[DivSqrtRecFN_srt4.scala 375:38]
  wire [56:0] sigA_ext = {io_a_sig[52:0],4'h0}; // @[Cat.scala 30:58]
  wire [5:0] _T_50 = io_sigBits + 6'h4; // @[DivSqrtRecFN_srt4.scala 388:44]
  wire  _T_53 = oddSqrt_S | _T_27; // @[DivSqrtRecFN_srt4.scala 393:42]
  reg [1:0] state; // @[DivSqrtRecFN_srt4.scala 404:22]
  wire  _T_59 = sigDs_io_out_ready & sigDs_io_out_valid; // @[Decoupled.scala 40:37]
  wire  _T_60 = state == 2'h2; // @[DivSqrtRecFN_srt4.scala 406:50]
  wire  rawOutValid = _T_59 | _T_60; // @[DivSqrtRecFN_srt4.scala 406:41]
  wire  _T_61 = 2'h0 == state; // @[Conditional.scala 37:30]
  wire  _T_62 = 2'h1 == state; // @[Conditional.scala 37:30]
  wire  _T_64 = 2'h2 == state; // @[Conditional.scala 37:30]
  wire [11:0] _T_65 = io_a_sExp[12:1]; // @[DivSqrtRecFN_srt4.scala 443:21]
  wire [12:0] _T_66 = $signed(_T_65) + 12'sh400; // @[DivSqrtRecFN_srt4.scala 443:26]
  wire  _T_68 = state == 2'h0; // @[DivSqrtRecFN_srt4.scala 449:24]
  wire  _T_70 = ~sqrtOp_Z; // @[DivSqrtRecFN_srt4.scala 453:41]
  wire  _T_74 = ~isNaN_Z; // @[DivSqrtRecFN_srt4.scala 457:37]
  wire  _T_76 = ~sigDs_io_out_bits_isZeroRem; // @[DivSqrtRecFN_srt4.scala 465:49]
  wire [56:0] _GEN_16 = {{56'd0}, _T_76}; // @[DivSqrtRecFN_srt4.scala 465:47]
  wire [56:0] _T_77 = sigDs_io_out_bits_quotient | _GEN_16; // @[DivSqrtRecFN_srt4.scala 465:47]
  FP64_SigDivSqrt_srt4 FP64_sigDs ( // @[DivSqrtRecFN_srt4.scala 383:21]
    .clock(sigDs_clock),
    .reset(sigDs_reset),
    .io_kill(sigDs_io_kill),
    .io_in_ready(sigDs_io_in_ready),
    .io_in_valid(sigDs_io_in_valid),
    .io_in_bits_sigA(sigDs_io_in_bits_sigA),
    .io_in_bits_sigB(sigDs_io_in_bits_sigB),
    .io_in_bits_isDiv(sigDs_io_in_bits_isDiv),
    .io_in_bits_dsCycles(sigDs_io_in_bits_dsCycles),
    .io_out_ready(sigDs_io_out_ready),
    .io_out_valid(sigDs_io_out_valid),
    .io_out_bits_quotient(sigDs_io_out_bits_quotient),
    .io_out_bits_isZeroRem(sigDs_io_out_bits_isZeroRem)
  );
  assign io_inReady = _T_68 & sigDs_io_in_ready; // @[DivSqrtRecFN_srt4.scala 449:14]
  assign io_rawOutValid_div = rawOutValid & _T_70; // @[DivSqrtRecFN_srt4.scala 453:23]
  assign io_rawOutValid_sqrt = rawOutValid & sqrtOp_Z; // @[DivSqrtRecFN_srt4.scala 454:23]
  assign io_roundingModeOut = roundingMode_Z; // @[DivSqrtRecFN_srt4.scala 455:23]
  assign io_invalidExc = majorExc_Z & isNaN_Z; // @[DivSqrtRecFN_srt4.scala 456:20]
  assign io_infiniteExc = majorExc_Z & _T_74; // @[DivSqrtRecFN_srt4.scala 457:20]
  assign io_rawOut_isNaN = isNaN_Z; // @[DivSqrtRecFN_srt4.scala 458:20]
  assign io_rawOut_isInf = isInf_Z; // @[DivSqrtRecFN_srt4.scala 459:20]
  assign io_rawOut_isZero = isZero_Z; // @[DivSqrtRecFN_srt4.scala 460:20]
  assign io_rawOut_sign = sign_Z; // @[DivSqrtRecFN_srt4.scala 461:20]
  assign io_rawOut_sExp = sExp_Z; // @[DivSqrtRecFN_srt4.scala 462:20]
  assign io_rawOut_sig = _T_77[55:0]; // @[DivSqrtRecFN_srt4.scala 465:17]
  assign sigDs_clock = clock;
  assign sigDs_reset = reset;
  assign sigDs_io_kill = io_kill; // @[DivSqrtRecFN_srt4.scala 390:17]
  assign sigDs_io_in_valid = entering & normalCase_S; // @[DivSqrtRecFN_srt4.scala 385:21]
  assign sigDs_io_in_bits_sigA = _T_53 ? sigA_ext : {{1'd0}, sigA_ext[56:1]}; // @[DivSqrtRecFN_srt4.scala 393:25]
  assign sigDs_io_in_bits_sigB = {io_b_sig[52:0],4'h0}; // @[DivSqrtRecFN_srt4.scala 396:25]
  assign sigDs_io_in_bits_isDiv = ~io_sqrtOp; // @[DivSqrtRecFN_srt4.scala 398:26]
  assign sigDs_io_in_bits_dsCycles = {{1'd0}, _T_50[5:1]}; // @[DivSqrtRecFN_srt4.scala 388:29]
  assign sigDs_io_out_ready = 1'h1; // @[DivSqrtRecFN_srt4.scala 400:22]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  sqrtOp_Z = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  majorExc_Z = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  isNaN_Z = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  isInf_Z = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  isZero_Z = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  sign_Z = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  sExp_Z = _RAND_6[12:0];
  _RAND_7 = {1{`RANDOM}};
  roundingMode_Z = _RAND_7[2:0];
  _RAND_8 = {1{`RANDOM}};
  state = _RAND_8[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (entering) begin
      sqrtOp_Z <= io_sqrtOp;
    end
    if (entering) begin
      if (io_sqrtOp) begin
        majorExc_Z <= _T_8;
      end else begin
        majorExc_Z <= _T_21;
      end
    end
    if (entering) begin
      if (io_sqrtOp) begin
        isNaN_Z <= _T_22;
      end else begin
        isNaN_Z <= _T_24;
      end
    end
    if (entering) begin
      if (io_sqrtOp) begin
        isInf_Z <= io_a_isInf;
      end else begin
        isInf_Z <= _T_25;
      end
    end
    if (entering) begin
      if (io_sqrtOp) begin
        isZero_Z <= io_a_isZero;
      end else begin
        isZero_Z <= _T_26;
      end
    end
    if (entering) begin
      sign_Z <= sign_S;
    end
    if (entering) begin
      if (io_sqrtOp) begin
        sExp_Z <= _T_66;
      end else begin
        sExp_Z <= sSatExpQuot_S_div;
      end
    end
    if (entering) begin
      roundingMode_Z <= io_roundingMode;
    end
    if (reset) begin
      state <= 2'h0;
    end else if (io_kill) begin
      state <= 2'h0;
    end else if (_T_61) begin
      if (entering) begin
        if (entering_normalCase) begin
          state <= 2'h1;
        end else begin
          state <= 2'h2;
        end
      end
    end else if (_T_62) begin
      if (_T_59) begin
        state <= 2'h0;
      end
    end else if (_T_64) begin
      state <= 2'h0;
    end
  end
endmodule

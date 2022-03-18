module DivSqrtRawFN_srt4(
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        input nReset,
        input clock,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        input [(`floatControlWidth - 1):0] control,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output inReady,
        input inValid,
        input sqrtOp,
        input [64:0] a,
        input [64:0] b,
        input fp64,
        input [2:0] roundingMode,
        // flush control
        input flush_lower, 
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output outValid,
        output [64:0] out_data,
        output [4:0] exceptionFlags
    );

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire isNaNA_S_fp32, isInfA_S_fp32, isZeroA_S_fp32, signA_S_fp32;
    wire signed [9:0] sExpA_S_fp32;
    wire [24:0] sigA_S_fp32;
    wire isNaNA_S_fp64, isInfA_S_fp64, isZeroA_S_fp64, signA_S_fp64;
    wire signed [12:0] sExpA_S_fp64;
    wire [53:0] sigA_S_fp64;

    // fp32
    recFNToRawFN #(.expWidth(8), .sigWidth(24)) recFNToRawFN_a_fp32
    (
        .in(a[32:0]), 
        .isNaN(isNaNA_S_fp32), 
        .isInf(isInfA_S_fp32), 
        .isZero(isZeroA_S_fp32), 
        .sign(signA_S_fp32), 
        .sExp(sExpA_S_fp32), 
        .sig(sigA_S_fp32)
    );
    wire isSigNaNA_S_fp32;
    isSigNaNRecFN #(.expWidth(8), .sigWidth(24)) isSigNaN_a_fp32
    (
        .in(a[32:0]), 
        .isSigNaN(isSigNaNA_S_fp32)
    );

    // fp64
    recFNToRawFN #(.expWidth(11), .sigWidth(53)) recFNToRawFN_a_fp64
    (
        .in(a[64:0]), 
        .isNaN(isNaNA_S_fp64), 
        .isInf(isInfA_S_fp64), 
        .isZero(isZeroA_S_fp64), 
        .sign(signA_S_fp64), 
        .sExp(sExpA_S_fp64), 
        .sig(sigA_S_fp64)
    );
    wire isSigNaNA_S_fp64;
    isSigNaNRecFN #(.expWidth(11), .sigWidth(53)) isSigNaN_a_fp64
    (
        .in(a[64:0]), 
        .isSigNaN(isSigNaNA_S_fp64)
    );

    wire isNaNB_S_fp32, isInfB_S_fp32, isZeroB_S_fp32, signB_S_fp32;
    wire signed [9:0] sExpB_S_fp32;
    wire [24:0] sigB_S_fp32;
    wire isNaNB_S_fp64, isInfB_S_fp64, isZeroB_S_fp64, signB_S_fp64;
    wire signed [12:0] sExpB_S_fp64;
    wire [53:0] sigB_S_fp64;
    
    // fp32
    recFNToRawFN #(.expWidth(8), .sigWidth(24)) recFNToRawFN_b_fp32
    (
        .in(b[32:0]), 
        .isNaN(isNaNB_S_fp32), 
        .isInf(isInfB_S_fp32), 
        .isZero(isZeroB_S_fp32), 
        .sign(signB_S_fp32), 
        .sExp(sExpB_S_fp32), 
        .sig(sigB_S_fp32)
    );
    wire isSigNaNB_S_fp32;
    isSigNaNRecFN #(.expWidth(8), .sigWidth(24)) isSigNaN_b_fp32
    (
        .in(b[32:0]), 
        .isSigNaN(isSigNaNB_S_fp32)
    );

    // fp64
    recFNToRawFN #(.expWidth(11), .sigWidth(53)) recFNToRawFN_b_fp64
    (
        .in(b[64:0]), 
        .isNaN(isNaNB_S_fp64), 
        .isInf(isInfB_S_fp64), 
        .isZero(isZeroB_S_fp64), 
        .sign(signB_S_fp64), 
        .sExp(sExpB_S_fp64), 
        .sig(sigB_S_fp64)
    );
    wire isSigNaNB_S_fp64;
    isSigNaNRecFN #(.expWidth(11), .sigWidth(53)) isSigNaN_b_fp64
    (
        .in(b[64:0]), 
        .isSigNaN(isSigNaNB_S_fp64)
    );

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire OutValid_div_fp32, OutValid_sqrt_fp32;
    wire OutValid_div_fp64, OutValid_sqrt_fp64;
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire [2:0] roundingModeOut_fp32, roundingModeOut_fp64;
    wire invalidExc_fp32, infiniteExc_fp32, out_isNaN_fp32, out_isInf_fp32, out_isZero_fp32, out_sign_fp32;
    wire invalidExc_fp64, infiniteExc_fp64, out_isNaN_fp64, out_isInf_fp64, out_isZero_fp64, out_sign_fp64;
    wire signed [9:0] out_sExp_fp32;
    wire [26:0] out_sig_fp32;
    wire signed [12:0] out_sExp_fp64;
    wire [55:0] out_sig_fp64;
    wire inReady_fp32, inReady_fp64;
    wire [32:0] out_data_fp32;
    wire [64:0] out_data_fp64;
    wire [4:0] exceptionFlags_fp32, exceptionFlags_fp64;
    

    // fp32
    FP32_DivSqrtRawFN_srt4 divSqrtRecFNToRaw_fp32
    (
        .clock(clock),
        .reset(~nReset),   // set 1 reset
        .io_inReady(inReady_fp32),
        .io_inValid(inValid & ~fp64),
        .io_sqrtOp(sqrtOp),
        .io_a_isNaN(isNaNA_S_fp32),
        .io_a_isInf(isInfA_S_fp32),
        .io_a_isZero(isZeroA_S_fp32),
        .io_a_sign(signA_S_fp32),
        .io_a_sExp(sExpA_S_fp32),
        .io_a_sig(sigA_S_fp32),
        .io_b_isNaN(isNaNB_S_fp32),
        .io_b_isInf(isInfB_S_fp32),
        .io_b_isZero(isZeroB_S_fp32),
        .io_b_sign(signB_S_fp32),
        .io_b_sExp(sExpB_S_fp32),
        .io_b_sig(sigB_S_fp32),
        .io_roundingMode(roundingMode),
        .io_sigBits(5'd24),
        .io_kill(flush_lower),
        .io_rawOutValid_div(OutValid_div_fp32),
        .io_rawOutValid_sqrt(OutValid_sqrt_fp32),
        .io_roundingModeOut(roundingModeOut_fp32),
        .io_invalidExc(invalidExc_fp32),
        .io_infiniteExc(infiniteExc_fp32),
        .io_rawOut_isNaN(out_isNaN_fp32),
        .io_rawOut_isInf(out_isInf_fp32),
        .io_rawOut_isZero(out_isZero_fp32),
        .io_rawOut_sign(out_sign_fp32),
        .io_rawOut_sExp(out_sExp_fp32),
        .io_rawOut_sig(out_sig_fp32)
    );
    // fp64
    FP64_DivSqrtRawFN_srt4 divSqrtRecFNToRaw_fp64
    (
        .clock(clock),
        .reset(~nReset),   // set 1 reset
        .io_inReady(inReady_fp64),
        .io_inValid(inValid & fp64),
        .io_sqrtOp(sqrtOp),
        .io_a_isNaN(isNaNA_S_fp64),
        .io_a_isInf(isInfA_S_fp64),
        .io_a_isZero(isZeroA_S_fp64),
        .io_a_sign(signA_S_fp64),
        .io_a_sExp(sExpA_S_fp64),
        .io_a_sig(sigA_S_fp64),
        .io_b_isNaN(isNaNB_S_fp64),
        .io_b_isInf(isInfB_S_fp64),
        .io_b_isZero(isZeroB_S_fp64),
        .io_b_sign(signB_S_fp64),
        .io_b_sExp(sExpB_S_fp64),
        .io_b_sig(sigB_S_fp64),
        .io_roundingMode(roundingMode),
        .io_sigBits(6'd53),
        .io_kill(flush_lower),
        .io_rawOutValid_div(OutValid_div_fp64),
        .io_rawOutValid_sqrt(OutValid_sqrt_fp64),
        .io_roundingModeOut(roundingModeOut_fp64),
        .io_invalidExc(invalidExc_fp64),
        .io_infiniteExc(infiniteExc_fp64),
        .io_rawOut_isNaN(out_isNaN_fp64),
        .io_rawOut_isInf(out_isInf_fp64),
        .io_rawOut_isZero(out_isZero_fp64),
        .io_rawOut_sign(out_sign_fp64),
        .io_rawOut_sExp(out_sExp_fp64),
        .io_rawOut_sig(out_sig_fp64)
    );
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    // fp32
    roundRawFNToRecFN #(.expWidth(8), .sigWidth(24), .options(0)) roundRawOut_fp32
    (
        .control(control),
        .invalidExc(invalidExc_fp32),
        .infiniteExc(infiniteExc_fp32),
        .in_isNaN(out_isNaN_fp32),
        .in_isInf(out_isInf_fp32),
        .in_isZero(out_isZero_fp32),
        .in_sign(out_sign_fp32),
        .in_sExp(out_sExp_fp32),
        .in_sig(out_sig_fp32),
        .roundingMode(roundingModeOut_fp32),
        .out(out_data_fp32),
        .exceptionFlags(exceptionFlags_fp32)
    );
    // fp64
    roundRawFNToRecFN #(.expWidth(11), .sigWidth(53), .options(0)) roundRawOut_fp64
    (
        .control(control),
        .invalidExc(invalidExc_fp64),
        .infiniteExc(infiniteExc_fp64),
        .in_isNaN(out_isNaN_fp64),
        .in_isInf(out_isInf_fp64),
        .in_isZero(out_isZero_fp64),
        .in_sign(out_sign_fp64),
        .in_sExp(out_sExp_fp64),
        .in_sig(out_sig_fp64),
        .roundingMode(roundingModeOut_fp64),
        .out(out_data_fp64),
        .exceptionFlags(exceptionFlags_fp64)
    );

    assign inReady = inReady_fp32 & inReady_fp64;
    assign outValid = OutValid_div_fp32 | OutValid_sqrt_fp32 | OutValid_div_fp64 | OutValid_sqrt_fp64;
    assign out_data = ({65{(OutValid_div_fp32 | OutValid_sqrt_fp32)}} & {32'b0, out_data_fp32}) | 
                      ({65{(OutValid_div_fp64 | OutValid_sqrt_fp64)}} & out_data_fp64);
    assign exceptionFlags = ({5{OutValid_div_fp32 | OutValid_sqrt_fp32}} & exceptionFlags_fp32) | 
                            ({5{OutValid_div_fp64 | OutValid_sqrt_fp64}} & exceptionFlags_fp64);

endmodule
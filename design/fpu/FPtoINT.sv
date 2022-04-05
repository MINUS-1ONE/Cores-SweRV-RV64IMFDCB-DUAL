module FPtoINT (
    input logic [64:0] in_frs1_rec_fn,  // rec format rs1 input
    input logic [64:0] in_frs2_rec_fn,  // rec format rs2 input

    input logic [2:0] in_rm,    // rounding mode

    input logic fp64,
    // {fs, fclass, feq, flt, fle, fmv, fcvt, sign, islong}
    input logic [8:0] ctrl_code,

	output logic lt,               // less than signal to FPtoFP
	
    output logic [63:0] out_int_data,  // integer output data
	output logic [4:0]  out_exc    // exception flags
);
	
    logic fs;
    logic fclass;
    logic feq;
    logic flt;
    logic fle;
    logic fmv;
    logic fcvt;
    logic sign;
    logic islong;

    logic frs1_sign;

    logic [31:0] fsw_data;
    logic [63:0] fsd_data;
    logic [63:0] fs_data;
    
    logic [63:0] fmv_data;

    logic [9:0] fclass_data;

    logic feq_s_res, feq_d_res, feq_res;
    logic flt_s_res, flt_d_res, flt_res;
    logic fle_s_res, fle_d_res, fle_res;

    logic fcmp_res;
    logic [63:0] fcmp_data;
    logic [4:0] fcmp_s_exc, fcmp_d_exc, fcmp_exc;

    logic [31:0] fcvt_w_s_data;
    logic [2:0]  fcvt_w_s_exc;
    logic [31:0] fcvt_w_d_data;
    logic [2:0]  fcvt_w_d_exc;
    logic [63:0] fcvt_l_s_data;
    logic [2:0]  fcvt_l_s_exc;
    logic [63:0] fcvt_l_d_data;
    logic [2:0]  fcvt_l_d_exc;
    logic [63:0] fcvt_data;
    logic [2:0]  fcvt_exc;


    logic nzero_lt_pzero;
    
    assign {fs, fclass, feq, flt, fle, fmv, fcvt, sign, islong} = ctrl_code;

    assign frs1_sign = fp64 ? in_frs1_rec_fn[64] : in_frs1_rec_fn[32];

    // FSW / FSD
    recFNToFN #(.expWidth(8), .sigWidth(24)) RecToFn_FSW(
        .in(in_frs1_rec_fn[32:0]),
        .out(fsw_data)
    );

    recFNToFN #(.expWidth(11), .sigWidth(53)) RecToFn_FSD(
        .in(in_frs1_rec_fn[64:0]),
        .out(fsd_data)
    );

    // For FSW / FSD, just use the lower n-bit from FGPRs.
    assign fs_data = fp64 ? fsd_data : {32'b0, fsw_data};

    // According to spec:
    // FMV.X.W moves the single-precision value in floating-point register rs1 represented in 
    // IEEE 754-2008 encoding to the lower 32 bits of integer register rd. 
    // The bits are not modified in the transfer, and in particular, 
    // the payloads of non-canonical NaNs are preserved. 
    // For RV64, the higher 32 bits of the destination register are filled with copies of the floating-point number’s sign bit.
    // ---------------------------------
    // For FMV.X.W / FMV.X.D, just use the lower n-bit from FGPRs.
    // Need sign-extension for fmv.x.w
    assign fmv_data = fp64 ? fsd_data : {{32{frs1_sign}}, fsw_data};

    // FCLASS.S / FCLASS.D
    f_class f_class  (
        .rec_fn(in_frs1_rec_fn),
        .fp64(fp64),
        .class_out(fclass_data)
    );
    
    // FEQ.S / FLT.S / FLE.S
    compareRecFN #(.expWidth(8), .sigWidth(24)) cmp_fp32
    (
	 	.a(in_frs1_rec_fn[32:0]),
	 	.b(in_frs2_rec_fn[32:0]),
	 	.signaling(flt | fle),
	 	.lt(flt_s_res),
	 	.eq(feq_s_res), 
	 	.gt(), 
	 	.unordered(),    // either input is NaN 
	 	.exceptionFlags(fcmp_s_exc)
	);

    // FEQ.D / FLT.D / FLE.D
    compareRecFN #(.expWidth(11), .sigWidth(53)) cmp_fp64
    (
	 	.a(in_frs1_rec_fn[64:0]),
	 	.b(in_frs2_rec_fn[64:0]),
	 	.signaling(flt | fle),
	 	.lt(flt_d_res),
	 	.eq(feq_d_res), 
	 	.gt(), 
	 	.unordered(),    // either input is NaN 
	 	.exceptionFlags(fcmp_d_exc)
	);

    assign feq_res = fp64 ? feq_d_res : feq_s_res;
    assign flt_res = fp64 ? flt_d_res : flt_s_res;
    assign fle_res = fp64 ? |{flt_d_res, feq_d_res} : |{flt_s_res, feq_s_res};
    assign fcmp_res = (feq & feq_res) | (flt & flt_res) | (fle & fle_res);
    assign fcmp_data = {63'b0, fcmp_res};
    assign fcmp_exc = fp64 ? fcmp_d_exc : fcmp_s_exc;

    // FCVT.W.S / FCVT.WU.S
    recFNToIN #(.expWidth(8), .sigWidth(24), .intWidth(32)) fcvt_w_s
    (
    	.control(1'b0),   // no use
    	.in(in_frs1_rec_fn[32:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_w_s_data),
    	.intExceptionFlags(fcvt_w_s_exc)
    );

    // FCVT.W.D / FCVT.WU.D
    recFNToIN #(.expWidth(11), .sigWidth(53), .intWidth(32)) fcvt_w_d
    (
    	.control(1'b0),   // no use
    	.in(in_frs1_rec_fn[64:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_w_d_data),
    	.intExceptionFlags(fcvt_w_d_exc)
    );

    // FCVT.L.S / FCVT.LU.S
    recFNToIN #(.expWidth(8), .sigWidth(24), .intWidth(64)) fcvt_l_s
    (
    	.control(1'b0),   // no use
    	.in(in_frs1_rec_fn[32:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_l_s_data),
    	.intExceptionFlags(fcvt_l_s_exc)
    );

    // FCVT.L.D / FCVT.LU.D
    recFNToIN #(.expWidth(11), .sigWidth(53), .intWidth(64)) fcvt_l_d
    (
    	.control(1'b0),   // no use
    	.in(in_frs1_rec_fn[64:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_l_d_data),
    	.intExceptionFlags(fcvt_l_d_exc)
    );

    // For XLEN> 32, FCVT.W[U].S sign-extends the 32-bit result to the destination register width.
    assign fcvt_data = fp64 ? (islong ? fcvt_l_d_data : {{32{fcvt_w_d_data[31]}}, fcvt_w_d_data}) :
                              (islong ? fcvt_l_s_data : {{32{fcvt_w_s_data[31]}}, fcvt_w_s_data});
    assign fcvt_exc  = fp64 ? (islong ? fcvt_l_d_exc : fcvt_w_d_exc) :
                              (islong ? fcvt_l_s_exc : fcvt_w_s_exc);
    
    
    assign out_int_data = ({64{fs}} & fs_data)                   |
                          ({64{fclass}} & {54'b0, fclass_data})  |
                          ({64{(feq | flt | fle)}} & fcmp_data)  |
                          ({64{fcvt}} & fcvt_data)               |
                          ({64{fmv}} & fmv_data);
    assign out_exc  = ({5{fs}} & 5'b0) |
                      ({5{fclass}} & 5'b0) |
                      ({5{(feq | flt | fle)}} & fcmp_exc) |
                      // According to the module "recFNToIN":
                      // Although intExceptionFlags distinguishes integer overflow separately from invalid exceptions, 
                      // the IEEE Standard does not permit conversions to integer to raise a floating-point overflow exception. 
                      // Instead, if a system has no other way to indicate that a conversion to integer overflowed, 
                      // the standard requires that the floating-point invalid exception be raised, not floating-point overflow. 
                      // Hence, the invalid and overflow bits from intExceptionFlags will typically be ORed together to contribute to the usual floating-point invalid exception.
                      // --------------------------
                      // So we just raise Invalid Operation when it's invalid or overflow exception, and ignore Overflow.
                      ({5{fcvt}} & {(fcvt_exc[2] | fcvt_exc[1]), 3'b0, fcvt_exc[0]}) |
                      ({5{fmv}} & 5'b0);
    
    // to FPtoFP
    // −0.0 is considered to be less than the value +0.0
    assign nzero_lt_pzero = fp64 ? (in_frs1_rec_fn[64] & ~in_frs2_rec_fn[64] & ~|in_frs1_rec_fn[63:61] & ~|in_frs2_rec_fn[63:61]) : 
                                   (in_frs1_rec_fn[32] & ~in_frs2_rec_fn[32] & ~|in_frs1_rec_fn[31:29] & ~|in_frs2_rec_fn[31:29]);
    assign lt = flt_res | nzero_lt_pzero;

endmodule

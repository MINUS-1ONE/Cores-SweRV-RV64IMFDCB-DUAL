module FPtoINT (
    input logic [64:0] in_in1,  // rec format rs1 input
    input logic [64:0] in_in2,  // rec format rs2 input

    input logic [2:0] in_rm,    // rounding mode

    input logic fp64,
    // {fclass, feq, flt, fle, fmv, fcvt, sign, long}
    input logic [7:0] ctrl_code,

	output logic lt,               // less than signal to FPtoFP
	
    output logic [63:0] out_data,  // integer output data
	output logic [4:0]  out_exc    // exception flags
);
	
    logic fclass;
    logic feq;
    logic flt;
    logic fle;
    logic fmv;
    logic fcvt;
    logic sign;
    logic long;

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
    logic [4:0]  fcvt_exc;

    logic [63:0] fmv_data;

    logic nzero_lt_pzero;
    
    assign {fclass, feq, flt, fle, fmv, fcvt, sign, long} = ctrl_code;

    // FCLASS.S / FCLASS.D
    f_class f_class  (
        .rec_fn(in_in1),
        .fp64(fp64),
        .class_out(fclass_data)
    );
    
    // FEQ.S / FLT.S / FLE.S
    compareRecFN #(.expWidth(8), .sigWidth(24)) cmp_fp32
    (
	 	.a(in_in1[32:0]),
	 	.b(in_in2[32:0]),
	 	.signaling(flt | fle),
	 	.lt(flt_s_res),
	 	.eq(feq_s_res), 
	 	.gt(fle_s_res), 
	 	.unordered(),    // either input is NaN 
	 	.exceptionFlags(fcmp_s_exc)
	);

    // FEQ.D / FLT.D / FLE.D
    compareRecFN #(.expWidth(11), .sigWidth(53)) cmp_fp64
    (
	 	.a(in_in1[64:0]),
	 	.b(in_in2[64:0]),
	 	.signaling(flt | fle),
	 	.lt(flt_d_res),
	 	.eq(feq_d_res), 
	 	.gt(fle_d_res), 
	 	.unordered(),    // either input is NaN 
	 	.exceptionFlags(fcmp_d_exc)
	);

    assign feq_res = fp64 ? feq_d_res : feq_s_res;
    assign flt_res = fp64 ? flt_d_res : flt_s_res;
    assign fle_res = fp64 ? fle_d_res : fle_s_res;
    assign fcmp_res = (feq & feq_res) | (flt & flt_res) | (fle & fle_res);
    assign fcmp_data = {63'b0, fcmp_res};
    assign fcmp_exc = fp64 ? fcmp_d_exc : fcmp_s_exc;

    // FCVT.W.S / FCVT.WU.S
    recFNToIN #(.expWidth(8), .sigWidth(24), .intWidth(32)) fcvt_w_s
    (
    	.control(1'b0),   // no use
    	.in(in_in1[32:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_w_s_data),
    	.intExceptionFlags(fcvt_w_s_exc)
    );

    // FCVT.W.D / FCVT.WU.D
    recFNToIN #(.expWidth(11), .sigWidth(53), .intWidth(32)) fcvt_w_d
    (
    	.control(1'b0),   // no use
    	.in(in_in1[64:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_w_d_data),
    	.intExceptionFlags(fcvt_w_d_exc)
    );

    // FCVT.L.S / FCVT.LU.S
    recFNToIN #(.expWidth(8), .sigWidth(24), .intWidth(64)) fcvt_l_s
    (
    	.control(1'b0),   // no use
    	.in(in_in1[32:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_l_s_data),
    	.intExceptionFlags(fcvt_l_s_exc)
    );

    // FCVT.L.D / FCVT.LU.D
    recFNToIN #(.expWidth(11), .sigWidth(53), .intWidth(64)) fcvt_l_d
    (
    	.control(1'b0),   // no use
    	.in(in_in1[64:0]),
    	.roundingMode(in_rm), 
    	.signedOut(sign),
    	.out(fcvt_l_d_data),
    	.intExceptionFlags(fcvt_l_d_exc)
    );

    // For XLEN> 32, FCVT.W[U].S sign-extends the 32-bit result to the destination register width.
    assign fcvt_data = fp64 ? (long ? fcvt_l_d_data : {{32{sign}}, fcvt_w_d_data}) :
                              (long ? fcvt_l_s_data : {{32{sign}}, fcvt_w_s_data});
    assign fcvt_exc  = fp64 ? (long ? fcvt_l_d_exc : fcvt_w_d_exc) :
                              (long ? fcvt_l_s_exc : fcvt_w_s_exc);
    
    // FMV.X.W / FMV.X.D
    // Any operation that writes a narrower result to an f register must write all 1s to the uppermost FLEN−n bits to yield a legal NaN-boxed value.
    assign fmv_data = fp64 ? in_in1[63:0] : {32'b1, in_in1[31:0]};
    
    assign out_data = ({64{fclass}} & {54'b0, fclass_data}) |
                      ({64{(feq | flt | fle)}} & fcmp_data) |
                      ({64{fcvt}} & fcvt_data) |
                      ({64{fmv}} & fmv_data);
    assign out_exc  = ({5{fclass}} & 5'b0) |
                      ({5{(feq | flt | fle)}} & fcmp_exc) |
                      ({5{fcvt}} & {(fcvt_exc[2] | fcvt_exc[1]), 3'b0, fcvt_exc[0]}) |
                      ({5{fmv}} & 5'b0);
    
    // to FPtoFP
    // −0.0 is considered to be less than the value +0.0
    assign nzero_lt_pzero = fp64 ? (in_in1[64] & ~in_in2[64] & ~|in_in1[63:61] & ~|in_in2[63:61]) : 
                                   (in_in1[32] & ~in_in2[32] & ~|in_in1[31:29] & ~|in_in2[31:29]);
    assign lt = flt_res | nzero_lt_pzero;

endmodule

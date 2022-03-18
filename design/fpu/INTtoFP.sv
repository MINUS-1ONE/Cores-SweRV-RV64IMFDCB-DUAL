`include "HardFloat_consts.vi"

module INTtoFP (
	input logic [63:0] in_rs1,  // integer rs1 input

	input logic [2:0] in_rm,    // rounding mode
	
	input logic fp64,
    // {fcvt, fmv, sign, long}
	input logic [3:0] ctrl_code,

    output logic [64:0] out_rec_fn_data,  // rec format output data
	output logic [4:0]  out_exc    // exception flags	
);
	logic fcvt;
	logic fmv;
	logic sign;
	logic long;

	logic [32:0] fmv_w_x_data;
	logic [64:0] fmv_d_x_data;
	logic [64:0] fmv_data;

	logic [32:0] fcvt_s_w_data;
	logic [4:0]  fcvt_s_w_exc;
	logic [32:0] fcvt_s_l_data;
	logic [4:0]  fcvt_s_l_exc;
	logic [64:0] fcvt_d_w_data;
	logic [4:0]  fcvt_d_w_exc;
	logic [64:0] fcvt_d_l_data;
	logic [4:0]  fcvt_d_l_exc;
	logic [64:0] fcvt_data;
	logic [4:0]  fcvt_exc;

	assign {fcvt, fmv, sign, long} = ctrl_code;

	// FMV.W.X
	fNToRecFN#(.expWidth(8), .sigWidth(24)) fmv_w_x
	(
		.in(in_rs1[31:0]),
		.out(fmv_w_x_data)
	);

	// FMV.D.X
	fNToRecFN#(.expWidth(11), .sigWidth(53)) fmv_d_x
	(
		.in(in_rs1[63:0]),
		.out(fmv_d_x_data)
	);

	assign fmv_data = fp64 ? fmv_d_x_data : {32'b0, fmv_w_x_data};

	// FCVT.S.W / FCVT.S.WU
	iNToRecFN #(.intWidth(32), .expWidth(8), .sigWidth(24)) fcvt_s_w
	(
		.control(`flControl_tininessAfterRounding), 
		.signedIn(sign), 
		.in(in_rs1[31:0]), 
		.roundingMode(in_rm), 
		.out(fcvt_s_w_data), 
		.exceptionFlags(fcvt_s_w_exc)
	);

	// FCVT.S.L / FCVT.S.LU
	iNToRecFN #(.intWidth(64), .expWidth(8), .sigWidth(24)) fcvt_s_l
	(
		.control(`flControl_tininessAfterRounding), 
		.signedIn(sign), 
		.in(in_rs1[63:0]), 
		.roundingMode(in_rm), 
		.out(fcvt_s_l_data), 
		.exceptionFlags(fcvt_s_l_exc)
	);

	// FCVT.D.W / FCVT.D.WU
	iNToRecFN #(.intWidth(32), .expWidth(11), .sigWidth(53)) fcvt_d_w
	(
		.control(`flControl_tininessAfterRounding), 
		.signedIn(sign), 
		.in(in_rs1[31:0]), 
		.roundingMode(in_rm), 
		.out(fcvt_d_w_data), 
		.exceptionFlags(fcvt_d_w_exc)
	);

	// FCVT.D.L / FCVT.D.LU
	iNToRecFN #(.intWidth(64), .expWidth(11), .sigWidth(53)) fcvt_d_l
	(
		.control(`flControl_tininessAfterRounding), 
		.signedIn(sign), 
		.in(in_rs1[63:0]), 
		.roundingMode(in_rm), 
		.out(fcvt_d_l_data), 
		.exceptionFlags(fcvt_d_l_exc)
	);

	assign fcvt_data = fp64 ? (long ? fcvt_d_l_data : fcvt_d_w_data) : 
							  (long ? {32'b0, fcvt_s_l_data} : {32'b0, fcvt_s_w_data});
	assign fcvt_exc  = fp64 ? (long ? fcvt_d_l_exc : fcvt_d_w_exc) : 
							  (long ? fcvt_s_l_exc : fcvt_s_w_exc);

	assign out_rec_fn_data = ({65{fcvt}} & fcvt_data) | ({65{fmv}} & fmv_data);
	assign out_exc         = ({5{fcvt}} & fcvt_exc) | ({5{fmv}} & 5'b0);

endmodule

module f_div_sqrt (
    input  logic clk,            // Clock
    input  logic rst_n,          // Asynchronous reset active low
    input  logic valid,          // operation valid at e1 stage
    input  logic [64:0] in_frs1_rec_fn,  // rec format rs1 input at e1 stage
    input  logic [64:0] in_frs2_rec_fn,  // rec format rs2 input at e1 stage
    input  logic fp64,
    input  logic [2:0] in_rm,    // rounding mode at e1 stage
    input  logic fdiv,           // div ctrl signal at e1 stage
    input  logic fsqrt,          // sqrt ctrl signal at e1 stage
    input  logic flush_lower,    // flush control
    output logic fdiv_fsqrt_stall,       // float div sqrt long stall 
    output logic fdiv_fsqrt_finish,      // float div sqrt finish signal
    output logic [64:0] fdiv_fsqrt_data, 
    output logic [4:0] fdiv_fsqrt_exc
);
    logic inReady;
    logic inValid;
    logic outValid;
    logic sqrtOp;
    
    assign inValid = (fsqrt || fdiv) && valid;

    assign sqrtOp = fsqrt;

    assign fdiv_fsqrt_finish = outValid;

    assign fdiv_fsqrt_stall = !inReady;

    DivSqrtRawFN_srt4 float_div_sqrt(
            .nReset(rst_n),
            .clock(clk),
            .control(`flControl_tininessAfterRounding),
            .inReady(inReady),
            .inValid(inValid),
            .sqrtOp(sqrtOp),
            .a(in_frs1_rec_fn),
            .b(in_frs2_rec_fn),
            .fp64(fp64),
            .roundingMode(in_rm),
            //***** FPU related port*****
            .flush_lower(flush_lower), 
            //***** FPU related port*****
            .outValid(outValid),
            .out_data(fdiv_fsqrt_data),
            .exceptionFlags(fdiv_fsqrt_exc)
    );

endmodule
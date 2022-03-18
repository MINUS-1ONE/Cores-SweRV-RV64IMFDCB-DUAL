/*
Float instructions' coverage
----------------------------------------------------------------------------------------------------------
Extension                                          Instruction         FU              Read XGPRs         Write XGPRs      Read FGPRs       Write FGPRs       Read FCSRs      Write FGPRs
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
RV32F Standard Extension                           FLW                 LSU
                                                   FSW                 LSU/FPtoINT
                                                   FMADD.S             FMA
                                                   FMSUB.S             FMA
                                                   FNMSUB.S            FMA
                                                   FNMADD.S            FMA
                                                   FADD.S              FMA
                                                   FSUB.S              FMA
                                                   FMUL.S              FMA
                                                   FDIV.S              f_div_sqrt
                                                   FSQRT.S             f_div_sqrt
                                                   FSGNJ.S             FPtoFP
                                                   FSGNJN.S            FPtoFP
                                                   FSGNJX.S            FPtoFP
                                                   FMIN.S              FPtoFP
                                                   FMAX.S              FPtoFP
                                                   FCVT.W.S            FPtoINT
                                                   FCVT.WU.S           FPtoINT
                                                   FMV.X.W             FPtoINT
                                                   FEQ.S               FPtoINT
                                                   FLT.S               FPtoINT
                                                   FLE.S               FPtoINT
                                                   FCLASS.S            FPtoINT
                                                   FCVT.S.W            INTtoFP
                                                   FCVT.S.WU           INTtoFP
                                                   FMV.W.X             INTtoFP
----------------------------------------------------------------------------------------------------------
RV64F Standard Extension (in addition to RV32F)    FCVT.L.S            FPtoINT
                                                   FCVT.LU.S           FPtoINT
                                                   FCVT.S.L            INTtoFP
                                                   FCVT.S.LU           INTtoFP
----------------------------------------------------------------------------------------------------------
RV32D Standard Extension                           FLD                 LSU
                                                   FSD                 LSU/FPtoINT
                                                   FMADD.D             FMA
                                                   FMSUB.D             FMA
                                                   FNMSUB.D            FMA
                                                   FNMADD.D            FMA
                                                   FADD.D              FMA
                                                   FSUB.D              FMA
                                                   FMUL.D              FMA
                                                   FDIV.D              f_div_sqrt
                                                   FSQRT.D             f_div_sqrt
                                                   FSGNJ.D             FPtoFP
                                                   FSGNJN.D            FPtoFP
                                                   FSGNJX.D            FPtoFP
                                                   FMIN.D              FPtoFP
                                                   FMAX.D              FPtoFP
                                                   FCVT.S.D            FPtoFP
                                                   FCVT.D.S            FPtoFP
                                                   FEQ.D               FPtoINT
                                                   FLT.D               FPtoINT
                                                   FLE.D               FPtoINT
                                                   FCLASS.D            FPtoINT
                                                   FCVT.W.D            FPtoINT
                                                   FCVT.WU.D           FPtoINT
                                                   FCVT.D.W            INTtoFP
                                                   FCVT.D.WU           INTtoFP
----------------------------------------------------------------------------------------------------------
RV64D Standard Extension (in addition to RV32D)    FCVT.L.D            FPtoINT
                                                   FCVT.LU.D           FPtoINT
                                                   FMV.X.D             FPtoINT
                                                   FCVT.D.L            INTtoFP
                                                   FCVT.D.LU           INTtoFP
                                                   FMV.D.X             INTtoFP
----------------------------------------------------------------------------------------------------------

FPtoINT: return integer or combination of bits result
    float compare: return 0 or 1
        FEQ.S/FEQ.D
        FLT.S/FLT.D
        FLE.S/FLE.D
    convert float to integer: return integer
        FCVT.W.S/FCVT.W.D
        FCVT.WU.S/FCVT.WU.D
        FCVT.L.S/FCVT.L.D
        FCVT.LU.S/FCVT.LU.D
    move from fgpr to xgpr: return combination of bits
        FMV.X.W/FMV.X.D
    fclass: return combination of bits
        FCLASS.S/FCLASS.D

INTtoFP: return float result or combination of bits result
    convert integer to float: return float
        FCVT.S.W/FCVT.D.W
        FCVT.S.WU/FCVT.D.WU
        FCVT.S.L/FCVT.D.L
        FCVT.S.LU/FCVT.D.LU
    move from xgpr to fgpr: return combination of bits
        FMV.W.X/FMV.D.X
    a exception:
        FSW/FSD, convert it from recoded format to standard format

FPtoFP: return float result
    fmin/fmax: return float result
        FMIN.S/FMIN.D ( reuse the compare result in FPtoINT!!! )
        FMAX.S/FMAX.D ( reuse the compare result in FPtoINT!!! )
    sign injection: return float result
        FSGNJ.S/FSGNJ.D
        FSGNJN.S/FSGNJN.D
        FSGNJX.S/FSGNJX.D
    convert between fp32 and fp 64: return float
        FCVT.S.D
        FCVT.D.S

FMA: return float result
    add/sub: return float result
        FADD.S/FADD.D
        FSUB.S/FSUB.D
    mul: return float result
        FMUL.S/FMUL.D
    mul_add/mul_sub: return float result
        FMADD.S/FMADD.D
        FMSUB.S/FMSUB.D
        FNMSUB.S/FNMSUB.D
        FNMADD.S/FNMADD.D

f_div_sqrt: return float result
    div: return float result
        FDIV.S/FDIV.D
    sqrt: return float result
        FSQRT.S/FSQRT.D

LSU: 
    load:
        FLW/FLD
    store:
        FSW/FSD

1. Data read from GPRs is in standard format, and transfered into recoded format in DECODE stage.
   So if it's a FSW or FSD instruction, we must convert the data from recoded format to standard format in FPtoINT before write back to memory.
2. All intermediate data is in recoded format, and transfered into standard format when write back to GPRs.

*/

module fpu
   import swerv_types::*;
 (
    input logic clk,    // Clock
    input logic rst_l,  // reset
    
    input logic lsu_freeze_dc3,   

    input logic dec_tlu_flush_lower_wb,  
    
    // input 32/64 bits ieee format oprand
    input logic [63:0] dec_frs1_d, 
    input logic [63:0] dec_frs2_d, 
    input logic [63:0] dec_frs3_d, 
    
    // input 64 bits integer 
    input logic [63:0] gpr_i0_rs1_d, 
    input logic [63:0] gpr_i1_rs1_d, 
    
    input fpu_pkt_t fpu_d,

    input logic fpu_decode_i0_d,
    input logic fpu_decode_i1_d, 

    input logic dec_i0_frs1_bypass_en_d,
    input logic dec_i0_frs2_bypass_en_d,
    input logic dec_i0_frs3_bypass_en_d,
    input logic dec_i0_frs1_bypass_fp64_d,
    input logic dec_i0_frs2_bypass_fp64_d,
    input logic dec_i0_frs3_bypass_fp64_d,
    input logic [64:0] dec_i0_frs1_bypass_rec_fn_data_d,
    input logic [64:0] dec_i0_frs2_bypass_rec_fn_data_d,
    input logic [64:0] dec_i0_frs3_bypass_rec_fn_data_d, 

    input logic dec_i1_frs1_bypass_en_d,
    input logic dec_i1_frs2_bypass_en_d,
    input logic dec_i1_frs3_bypass_en_d,
    input logic dec_i1_frs1_bypass_fp64_d,
    input logic dec_i1_frs2_bypass_fp64_d,
    input logic dec_i1_frs3_bypass_fp64_d,
    input logic [64:0] dec_i1_frs1_bypass_rec_fn_data_d,
    input logic [64:0] dec_i1_frs2_bypass_rec_fn_data_d,
    input logic [64:0] dec_i1_frs3_bypass_rec_fn_data_d,

    input logic dec_i0_rs1_bypass_en_d,
    input logic [63:0] i0_rs1_bypass_data_d, 

    input logic dec_i1_rs1_bypass_en_d, 
    input logic [63:0] i1_rs1_bypass_data_d,

    // fdiv_sqrt port
    output logic fpu_fdiv_fsqrt_stall, 
    output logic fpu_fdiv_fsqrt_finish,  // include flush control
    output logic [64:0] fpu_fdiv_fsqrt_rec_fn_data,  
    output logic [4:0] fpu_fdiv_fsqrt_exc, 
    output logic fpu_fdiv_fsqrt_valid_e1,  // -> EXU record fdiv_sqrt_npc

    // e1 stage fmisc output
    output logic [64:0] fpu_fmisc_rec_fn_result_e1,  // output 31 bits ieee format result
    output logic [63:0] fpu_int_result_e1, // output 31 bits to int data
    output logic [4:0] fpu_fmisc_exc_e1,         // output 5 bits exc flags at e1 stage
  
    // e3 stage fma output
    output logic [64:0] fpu_fma_rec_fn_result_e3, 
    output logic [4:0] fpu_fma_exc_e3, 

    // format change ports
    input logic [63:0] lsu_result_dc3, 
    input logic lsu_fp64_e3,
    output logic [64:0] lsu_rec_fn_result_dc3, 

    input logic dec_frd_fp64_wb,
    input logic [64:0] dec_frd_rec_fn_wdata_wb,
    output logic [63:0] dec_frd_wdata_wb, 

    output logic [63:0] dec_i0_frs2_bypass_data_d,
    output logic [63:0] dec_i1_frs2_bypass_data_d

    
);
    // 在bypass过来时应该同时传一个fp64信号，告诉FPUbypass的数据是fp64还是fp32。
    // 同时，指令本身也有一个fp64信号，表示当前质量操作的数据类型是fp64还是fp32。
    // 那么在传到每个FU的时候，就有4中情况：
    // 1. bypass is fp64, inst is fp64
    //    这是直接使用bypass的数据进行计算即可。
    // 2. bypass is fp32, inst is fp32
    //    这是直接使用bypass的数据进行计算即可。
    // 3. bypass is fp64, inst is fp32
    //    这时，计算按fp64进行，同时结果也按fp64传递。
    // 4. bypass is fp32, inst is fp64
    //    这时，计算按fp32进行，同时结果也按fp32传递。
    // 为了保证数据在流水线中传递时数据格式能被正确识别，bypass时传递的fp64信号应该是实际用于计算的fp64信号，而不是指令实际的fp64信号。
    // 同时，为了在写回阶段能够正确的转换到指令指定的数据格式，需要写回阶段提供两个fp64信号。
    // 一个指示写回时的数据格式，一个指示当前数据的格式。
    // 因此，这里可能还需要做fp64和fp32之间的转换，完了还要做NaN-boxing。

    // pipeline control
    logic fpu_e1_ctl_en;
    logic [5:0] fpu_pipe_en;
    logic fpu_e1_data_en, fpu_e2_data_en, fpu_e3_data_en;

    fpu_pkt_t fpu_e1;

    logic fpu_i0_frs1_bypass_en_d, fpu_i0_frs2_bypass_en_d, fpu_i0_frs3_bypass_en_d;
    logic fpu_i1_frs1_bypass_en_d, fpu_i1_frs2_bypass_en_d, fpu_i1_frs3_bypass_en_d;

    logic need_nb_check;
    logic [32:0] dec_frs1_rec_fp32_d, dec_frs2_rec_fp32_d, dec_frs3_rec_fp32_d;
    logic [32:0] dec_frs1_rec_fp32_nb_d, dec_frs2_rec_fp32_nb_d, dec_frs3_rec_fp32_nb_d;
    logic [64:0] dec_frs1_rec_fp64_d, dec_frs2_rec_fp64_d, dec_frs3_rec_fp64_d;
    logic [64:0] dec_frs1_rec_fn_d, dec_frs2_rec_fn_d, dec_frs3_rec_fn_d;
    
    logic [63:0] frs1_mux_d;
    logic [63:0] frs2_mux_d;
    logic [63:0] frs3_mux_d;

    logic [64:0] frs1_rec_fn_d;
    logic [64:0] frs2_rec_fn_d;
    logic [64:0] frs3_rec_fn_d;

    logic [64:0] frs1_rec_fn_mux; 
    logic [64:0] frs2_rec_fn_mux;
    logic [64:0] frs3_rec_fn_mux;

    logic [64:0] frs1_rec_fn_e1;
    logic [64:0] frs2_rec_fn_e1;
    logic [64:0] frs3_rec_fn_e1;

    logic [63:0] int_rs1_d;
    logic [63:0] int_rs1_e1;

    logic lt;
    logic [8:0] fp_to_int_ctrl_code;
    logic [3:0] int_to_fp_ctrl_code;
    logic [5:0] fp_to_fp_ctrl_code;
    logic [6:0] fma_ctrl_code;

    logic [63:0] fp_to_int_data;
    logic [64:0] int_to_fp_rec_fn_data;
    logic [64:0] fp_to_fp_rec_fn_data;
    logic [64:0] fma_rec_fn_data_e3;

    logic [4:0] fp_to_int_exc_flags;
    logic [4:0] int_to_fp_exc_flags;
    logic [4:0] fp_to_fp_exc_flags;
    logic [4:0] fma_exc_flags_e3;

    logic [32:0] lsu_rec_fn_result_fp32_dc3;
    logic [64:0] lsu_rec_fn_result_fp64_dc3;

    logic [64:0] tofp_rec_fn_data;

    logic sel_fp_to_fp_e1, sel_int_to_fp_e1, sel_fp_to_int_e1;

    logic fdiv_fsqrt_i0_valid_e1;
    logic [64:0] fdiv_fsqrt_rec_fn_data;

    logic [31:0] dec_i0_frs1_bypass_fp32_data_d;
    logic [63:0] dec_i0_frs1_bypass_fp64_data_d;
    logic [31:0] dec_i1_frs1_bypass_fp32_data_d;
    logic [63:0] dec_i1_frs1_bypass_fp64_data_d;
    
    logic [31:0] dec_i0_frs2_bypass_fp32_data_d;
    logic [63:0] dec_i0_frs2_bypass_fp64_data_d;
    logic [31:0] dec_i1_frs2_bypass_fp32_data_d;
    logic [63:0] dec_i1_frs2_bypass_fp64_data_d;

    logic [31:0] dec_i0_frs3_bypass_fp32_data_d;
    logic [63:0] dec_i0_frs3_bypass_fp64_data_d;
    logic [31:0] dec_i1_frs3_bypass_fp32_data_d;
    logic [63:0] dec_i1_frs3_bypass_fp64_data_d;
    
    logic [63:0] dec_i0_frs1_bypass_data_d, dec_i1_frs1_bypass_data_d;
    logic [63:0] dec_i0_frs3_bypass_data_d, dec_i1_frs3_bypass_data_d;
    
    logic [32:0] lsu_rec_fnresult_fp32_dc3;
    logic [64:0] lsu_rec_fnresult_fp64_dc3;
    logic [31:0] dec_frd_fp32_wdata_wb;
    logic [63:0] dec_frd_fp64_wdata_wb;

    //****************clock gating***********************************************

    assign fpu_pipe_en[5] = fpu_d.valid;

    rvdffs #(3) fpucg0ff (.*, .clk(clk), .en(~lsu_freeze_dc3), .din(fpu_pipe_en[5:3]), .dout(fpu_pipe_en[4:2]));

    assign fpu_e1_ctl_en = (|fpu_pipe_en[5:4]) & ~lsu_freeze_dc3;

    assign fpu_e1_data_en = (fpu_pipe_en[5]) & ~lsu_freeze_dc3;
    assign fpu_e2_data_en = (fpu_pipe_en[4]) & ~lsu_freeze_dc3;
    assign fpu_e3_data_en = (fpu_pipe_en[3]) & ~lsu_freeze_dc3;
    //***************************************************************************

    //**********************************************
    //*************decode stage start***************
    //**********************************************
    
    // Transfer bypass recoded formats to standard formats.
    // -----------------------------------
    // For frs1
    // fp32
    recFNToFN #(.expWidth(8), .sigWidth(24)) i0_recFnToFN_frs1_byps1_fp32
    (
        .in(dec_i0_frs1_bypass_rec_fn_data_d[32:0]),
        .out(dec_i0_frs1_bypass_fp32_data_d)
    );
    // fp64
    recFNToFN #(.expWidth(11), .sigWidth(53)) i0_recFnToFN_frs1_byps1_fp64
    (
        .in(dec_i0_frs1_bypass_rec_fn_data_d[64:0]),
        .out(dec_i0_frs1_bypass_fp64_data_d)
    );
    // Need create a valid NaN-boxing value???
    assign dec_i0_frs1_bypass_data_d = dec_i0_frs1_bypass_fp64_d ? 
                                       dec_i0_frs1_bypass_fp64_data_d :
                                       {{32{1'b1}}, dec_i0_frs1_bypass_fp32_data_d};
    
    // fp32
    recFNToFN #(.expWidth(8), .sigWidth(24)) i1_recFnToFN_frs1_byps1_fp32
    (
        .in(dec_i1_frs1_bypass_rec_fn_data_d[32:0]),
        .out(dec_i1_frs1_bypass_fp32_data_d)
    );
    // fp64
    recFNToFN #(.expWidth(11), .sigWidth(53)) i1_recFnToFN_frs1_byps1_fp64
    (
        .in(dec_i1_frs1_bypass_rec_fn_data_d[64:0]),
        .out(dec_i1_frs1_bypass_fp64_data_d)
    );
    assign dec_i1_frs1_bypass_data_d = dec_i1_frs1_bypass_fp64_d ? 
                                       dec_i1_frs1_bypass_fp64_data_d :
                                       {{32{1'b1}}, dec_i1_frs1_bypass_fp32_data_d};
    
    // -----------------------------------
    // For frs2
    // fp32
    recFNToFN #(.expWidth(8), .sigWidth(24)) i0_recFnToFN_frs2_byps1_fp32
    (
        .in(dec_i0_frs2_bypass_rec_fn_data_d[32:0]),
        .out(dec_i0_frs2_bypass_fp32_data_d)
    );
    // fp64
    recFNToFN #(.expWidth(11), .sigWidth(53)) i0_recFnToFN_frs2_byps1_fp64
    (
        .in(dec_i0_frs2_bypass_rec_fn_data_d[64:0]),
        .out(dec_i0_frs2_bypass_fp64_data_d)
    );
    // Need create a valid NaN-boxing value???
    assign dec_i0_frs2_bypass_data_d = dec_i0_frs2_bypass_fp64_d ? 
                                       dec_i0_frs2_bypass_fp64_data_d :
                                       {{32{1'b1}}, dec_i0_frs2_bypass_fp32_data_d};
    
    // fp32
    recFNToFN #(.expWidth(8), .sigWidth(24)) i1_recFnToFN_frs2_byps1_fp32
    (
        .in(dec_i1_frs2_bypass_rec_fn_data_d[32:0]),
        .out(dec_i1_frs2_bypass_fp32_data_d)
    );
    // fp64
    recFNToFN #(.expWidth(11), .sigWidth(53)) i1_recFnToFN_frs2_byps1_fp64
    (
        .in(dec_i1_frs2_bypass_rec_fn_data_d[64:0]),
        .out(dec_i1_frs2_bypass_fp64_data_d)
    );
    assign dec_i1_frs2_bypass_data_d = dec_i1_frs2_bypass_fp64_d ? 
                                       dec_i1_frs2_bypass_fp64_data_d :
                                       {{32{1'b1}}, dec_i1_frs2_bypass_fp32_data_d};
    
    // -----------------------------------
    // For frs3
    // I0
    // fp32
    recFNToFN #(.expWidth(8), .sigWidth(24)) i0_recFnToFN_frs3_byps1_fp32
    (
        .in(dec_i0_frs3_bypass_rec_fn_data_d[32:0]),
        .out(dec_i0_frs3_bypass_fp32_data_d)
    );
    // fp64
    recFNToFN #(.expWidth(11), .sigWidth(53)) i0_recFnToFN_frs3_byps1_fp64
    (
        .in(dec_i0_frs3_bypass_rec_fn_data_d[64:0]),
        .out(dec_i0_frs3_bypass_fp64_data_d)
    );
    // Need create a valid NaN-boxing value???
    assign dec_i0_frs3_bypass_data_d = dec_i0_frs3_bypass_fp64_d ? 
                                       dec_i0_frs3_bypass_fp64_data_d :
                                       {{32{1'b1}}, dec_i0_frs3_bypass_fp32_data_d};
    
    // I1
    // fp32
    recFNToFN #(.expWidth(8), .sigWidth(24)) i1_recFnToFN_frs3_byps1_fp32
    (
        .in(dec_i1_frs3_bypass_rec_fn_data_d[32:0]),
        .out(dec_i1_frs3_bypass_fp32_data_d)
    );
    // fp64
    recFNToFN #(.expWidth(11), .sigWidth(53)) i1_recFnToFN_frs3_byps1_fp64
    (
        .in(dec_i1_frs3_bypass_rec_fn_data_d[64:0]),
        .out(dec_i1_frs3_bypass_fp64_data_d)
    );
    assign dec_i1_frs3_bypass_data_d = dec_i1_frs3_bypass_fp64_d ? 
                                       dec_i1_frs3_bypass_fp64_data_d :
                                       {{32{1'b1}}, dec_i1_frs3_bypass_fp32_data_d};
    
    // --------------------------


    // frs mux for bypass
    assign fpu_i0_frs1_bypass_en_d = dec_i0_frs1_bypass_en_d & fpu_decode_i0_d;
    assign fpu_i0_frs2_bypass_en_d = dec_i0_frs2_bypass_en_d & fpu_decode_i0_d;
    assign fpu_i0_frs3_bypass_en_d = dec_i0_frs3_bypass_en_d & fpu_decode_i0_d;

    assign fpu_i1_frs1_bypass_en_d = dec_i1_frs1_bypass_en_d & fpu_decode_i1_d;
    assign fpu_i1_frs2_bypass_en_d = dec_i1_frs2_bypass_en_d & fpu_decode_i1_d;
    assign fpu_i1_frs3_bypass_en_d = dec_i1_frs3_bypass_en_d & fpu_decode_i1_d;

    assign frs1_mux_d[63:0] = ({64{fpu_i0_frs1_bypass_en_d}}                               & dec_i0_frs1_bypass_data_d[63:0]) |
                              ({64{fpu_i1_frs1_bypass_en_d}}                               & dec_i1_frs1_bypass_data_d[63:0]) |
                              ({64{(~fpu_i0_frs1_bypass_en_d & ~fpu_i1_frs1_bypass_en_d)}} & dec_frs1_d[63:0]);

    assign frs2_mux_d[63:0] = ({64{fpu_i0_frs2_bypass_en_d}}                               & dec_i0_frs2_bypass_data_d[63:0]) |
                              ({64{fpu_i1_frs2_bypass_en_d}}                               & dec_i1_frs2_bypass_data_d[63:0]) |
                              ({64{(~fpu_i0_frs2_bypass_en_d & ~fpu_i1_frs2_bypass_en_d)}} & dec_frs2_d[63:0]);

    assign frs3_mux_d[63:0] = ({64{fpu_i0_frs3_bypass_en_d}}                               & dec_i0_frs3_bypass_data_d[63:0]) |
                              ({64{fpu_i1_frs3_bypass_en_d}}                               & dec_i1_frs3_bypass_data_d[63:0]) |
                              ({64{(~fpu_i0_frs3_bypass_en_d & ~fpu_i1_frs3_bypass_en_d)}} & dec_frs3_d[63:0]);

    // ieee format -> rec format
    // NaN-boxing
    // From the spec, we can known: 
    // 1. For FSW / FSD / FMV.X.W / FMV.X.D, just use lower n-bit and ignore upper FLEN-n bits.
    // 2. For FLW / FLD / FMV.W.X / FMV.D.X, use NaN-boxing to create a valid NaN-boxed value and write it to FGPRs.
    // 3. For any other operations, 
    //        (1) if you read narrower n-bit from FGPRs (n < FLEN), you nust check if the input operands are correctly NaN-boxed, 
    //            i.e., all upper FLEN−n bits are 1. If so, the n least-significant bits of the input are used as the input value, 
    //            otherwise the input value is treated as an n-bit canonical NaN.
    //        (2) if you write narrower n-bit to FGPRs (n < FLEN), you must write all 1s to the upper FLEN-n bits.
    // Here, we only consider transferring single float to other type.
    // Transferring other type to single is handled when write back to FGPRs.
    assign need_nb_check = (~fpu_d.fp64 & ((fpu_d.fp_to_int & (fpu_d.fclass | fpu_d.feq | fpu_d.flt | fpu_d.fle | fpu_d.fcvt)) | 
                                         fpu_d.fp_to_fp |
                                         fpu_d.fma |
                                         fpu_d.fdiv |
                                         fpu_d.fsqrt)) |
                           (fpu_d.fp64 & fpu_d.fp_to_fp & fpu_d.fcvt); // fcvt.d.s
    // fp32
    fNToRecFN #(.expWidth(8), .sigWidth(24)) fNToRecFN_frs1_fp32
    (
        .in(frs1_mux_d[31:0]), 
        .out(dec_frs1_rec_fp32_d)
    );
    fNToRecFN #(.expWidth(8), .sigWidth(24)) fNToRecFN_frs2_fp32
    (
        .in(frs2_mux_d[31:0]), 
        .out(dec_frs2_rec_fp32_d)
    );
    fNToRecFN #(.expWidth(8), .sigWidth(24)) fNToRecFN_frs3_fp32
    (
        .in(frs3_mux_d[31:0]), 
        .out(dec_frs3_rec_fp32_d)
    );

    // consider NaN-boxing
    assign dec_frs1_rec_fp32_nb_d = &frs1_mux_d[63:32] ? dec_frs1_rec_fp32_d : 33'h0_e040_0000;
    assign dec_frs2_rec_fp32_nb_d = &frs2_mux_d[63:32] ? dec_frs2_rec_fp32_d : 33'h0_e040_0000;
    assign dec_frs3_rec_fp32_nb_d = &frs3_mux_d[63:32] ? dec_frs3_rec_fp32_d : 33'h0_e040_0000;
    
    // fp64
    fNToRecFN #(.expWidth(11), .sigWidth(53)) fNToRecFN_frs1_fp64
    (
        .in(frs1_mux_d), 
        .out(dec_frs1_rec_fp64_d)
    );
    fNToRecFN #(.expWidth(11), .sigWidth(53)) fNToRecFN_frs2_fp64
    (
        .in(frs2_mux_d), 
        .out(dec_frs2_rec_fp64_d)
    );
    fNToRecFN #(.expWidth(11), .sigWidth(53)) fNToRecFN_frs3_fp64
    (
        .in(frs3_mux_d), 
        .out(dec_frs3_rec_fp64_d)
    );

    // For FCVT.D.S / FCVT.S.D, fp64 indicates whether the destination operand is FP64.
    // So for the source operand mux, we should use ~fp64 to indicate whether it is FP64.
    assign dec_frs1_rec_fn_d = ((fpu_d.fp64 & ~(fpu_d.fp_to_fp & fpu_d.fcvt)) | (~fpu_d.fp64 & (fpu_d.fp_to_fp & fpu_d.fcvt))) ? dec_frs1_rec_fp64_d : 
                                 need_nb_check ? {32'b0, dec_frs1_rec_fp32_nb_d} :
                                 {32'b0, dec_frs1_rec_fp32_d};
    assign dec_frs2_rec_fn_d = fpu_d.fp64 ? dec_frs2_rec_fp64_d : 
                                 need_nb_check ? {32'b0, dec_frs2_rec_fp32_nb_d} :
                                 {32'b0, dec_frs2_rec_fp32_d};
    assign dec_frs3_rec_fn_d = fpu_d.fp64 ? dec_frs3_rec_fp64_d : 
                                 need_nb_check ? {32'b0, dec_frs3_rec_fp32_nb_d} :
                                 {32'b0, dec_frs3_rec_fp32_d};
    // NaN-boxing给使用recoded formats进行bypass带来了困难
    // 如果前一条指令使用double，后一条指令使用float，
    // 后一条指令如果要做NaN-boxing检查，这是bypass会出现格式不匹配的问题
    // 可能需要用standard formats格式进行bypass！！！

    assign frs1_rec_fn_d = dec_frs1_rec_fn_d;
    
    assign frs2_rec_fn_d = dec_frs2_rec_fn_d;

    assign frs3_rec_fn_d = dec_frs3_rec_fn_d;

    // rs1 mux for bypass
    assign int_rs1_d = ({64{~dec_i1_rs1_bypass_en_d & fpu_decode_i1_d}} & (gpr_i1_rs1_d)) |
                       ({64{~dec_i0_rs1_bypass_en_d & fpu_decode_i0_d}} & (gpr_i0_rs1_d)) |                         
                       ({64{ dec_i1_rs1_bypass_en_d & fpu_decode_i1_d}} & i1_rs1_bypass_data_d) |
                       ({64{ dec_i0_rs1_bypass_en_d & fpu_decode_i0_d}} & i0_rs1_bypass_data_d);

    // operand exchange
    // For FSW/FSD, we use frs1 as input to FPtoINT, but the data is in frs2.
    // So we should change frs1 with frs2.
    assign frs1_rec_fn_mux = fpu_d.fs ? frs2_rec_fn_d : frs1_rec_fn_d;

    assign frs2_rec_fn_mux = frs2_rec_fn_d;

    // For FADD / FSUB, we do frs1*1 ± frs2 instead in FMA.
    // So we should change frs3 with frs2.
    assign frs3_rec_fn_mux = (fpu_d.fadd | fpu_d.fsub) ? frs2_rec_fn_d : frs3_rec_fn_d;

    // flip-flop dec stage signal to e1 stage
    // ctl_en & data_en include freeze ctrl
    rvdffe #($bits(fpu_pkt_t)) fpu_pkt_e1_ff
    (
        .*,
        .scan_mode(1'b0),
        .en(fpu_e1_ctl_en),
        .din(fpu_d),
        .dout(fpu_e1)
    );
    
    rvdffe #(65) rec_rs1_e1_ff
    (
        .*,
        .scan_mode(1'b0),
        .en(fpu_e1_data_en),
        .din(frs1_rec_fn_mux),
        .dout(frs1_rec_fn_e1)
    );

    rvdffe #(65) rec_rs2_e1_ff
    (
        .*,
        .scan_mode(1'b0),
        .en(fpu_e1_data_en),
        .din(frs2_rec_fn_mux),
        .dout(frs2_rec_fn_e1)
    );

    rvdffe #(65) rec_rs3_e1_ff
    (
        .*,
        .scan_mode(1'b0),
        .en(fpu_e1_data_en),
        .din(frs3_rec_fn_mux),
        .dout(frs3_rec_fn_e1)
    );

    rvdffe #(64) int_rs1_e1_ff
    (
        .*,
        .scan_mode(1'b0),
        .en(fpu_e1_data_en),
        .din(int_rs1_d),
        .dout(int_rs1_e1)
    );

    //**********************************************
    //*************e1 stage start*******************
    //**********************************************

    assign fp_to_int_ctrl_code = {fpu_e1.fs,
                                  fpu_e1.fclass,
                                  fpu_e1.feq,
                                  fpu_e1.flt,
                                  fpu_e1.fle,
                                  fpu_e1.fmv & fpu_e1.fp_to_int,
                                  fpu_e1.fcvt & fpu_e1.fp_to_int,
                                  fpu_e1.sign,
                                  fpu_e1.long};
    assign int_to_fp_ctrl_code = {fpu_e1.fcvt & fpu_e1.int_to_fp,
                                  fpu_e1.fmv & fpu_e1.int_to_fp,
                                  fpu_e1.sign,
                                  fpu_e1.long};
    assign fp_to_fp_ctrl_code = {fpu_e1.fmin,
                                 fpu_e1.fmax,
                                 fpu_e1.fsgnj,
                                 fpu_e1.fsgnjn,
                                 fpu_e1.fsgnjx,
                                 fpu_e1.fcvt & fpu_e1.fp_to_fp};
    assign fma_ctrl_code = {fpu_e1.fadd,
                            fpu_e1.fsub,
                            fpu_e1.fmul,
                            fpu_e1.fmadd,
                            fpu_e1.fmsub,
                            fpu_e1.fnmsub,
                            fpu_e1.fnmadd};
    
    FPtoINT fptoint_unit
    (
        .in_frs1_rec_fn(frs1_rec_fn_e1), 
        .in_frs2_rec_fn(frs2_rec_fn_e1), 
        .in_rm(fpu_e1.rm),
        .fp64(fpu_e1.fp64), 
        .ctrl_code(fp_to_int_ctrl_code),
        .lt(lt), 
        .out_int_data(fp_to_int_data), 
        .out_exc(fp_to_int_exc_flags)
    );

    INTtoFP inttofp_unit
    (
        .in_rs1(int_rs1_e1), 
        .in_rm(fpu_e1.rm),
        .fp64(fpu_e1.fp64), 
        .ctrl_code(int_to_fp_ctrl_code), 
        .out_rec_fn_data(int_to_fp_rec_fn_data), 
        .out_exc(int_to_fp_exc_flags)
    );

    FPtoFP fptofp_unit
    (
        .in_frs1_rec_fn(frs1_rec_fn_e1), 
        .in_frs2_rec_fn(frs2_rec_fn_e1), 
        .in_rm(fpu_e1.rm),
        .fp64(fpu_e1.fp64),
        .ctrl_code(fp_to_fp_ctrl_code),
        .lt(lt), 
        .out_rec_fn_data(fp_to_fp_rec_fn_data), 
        .out_exc(fp_to_fp_exc_flags)
    );

    // 3 stage FMA unit
    FMA fma_unit
    (
        .clk(clk), 
        .rst_l(rst_l), 
        .e2_data_en(fpu_e2_data_en),
        .e3_data_en(fpu_e3_data_en),
        .in_frs1_rec_fn(frs1_rec_fn_e1), 
        .in_frs2_rec_fn(frs2_rec_fn_e1), 
        .in_frs3_rec_fn(frs3_rec_fn_e1), 
        .fp64(fpu_e1.fp64),
        .ctrl_code(fma_ctrl_code), 
        .in_rm(fpu_e1.rm), 
        .out_rec_fn_data(fma_rec_fn_data_e3), 
        .out_exc(fma_exc_flags_e3) 
    );

    assign sel_fp_to_fp_e1 = fpu_e1.fp_to_fp & fpu_e1.valid;
    assign sel_int_to_fp_e1 = fpu_e1.int_to_fp & fpu_e1.valid;
    assign sel_fp_to_int_e1 = fpu_e1.fp_to_int & fpu_e1.valid;

    assign fpu_int_result_e1 = fp_to_int_data;

    // fptoint, inttofp, fptofp have wflags signal to control the exc data flow
    assign fpu_fmisc_exc_e1 = ({5{sel_fp_to_int_e1}} & fp_to_int_exc_flags[4:0]) | 
                              ({5{sel_int_to_fp_e1}} & int_to_fp_exc_flags[4:0]) | 
                              ({5{sel_fp_to_fp_e1}} & fp_to_fp_exc_flags[4:0]) ;

    assign tofp_rec_fn_data = ({65{sel_int_to_fp_e1}} & int_to_fp_rec_fn_data) | 
                              ({65{sel_fp_to_fp_e1}} & fp_to_fp_rec_fn_data) ;

    assign fpu_fmisc_rec_fn_result_e1 = tofp_rec_fn_data;

    // out of pipeline float div & sqrt unit

    assign fdiv_fsqrt_i0_valid_e1 = fpu_e1.valid & (fpu_e1.fdiv | fpu_e1.fsqrt);

    f_div_sqrt fdiv_sqrt_unit
    (
        .clk(clk),          
        .rst_n(rst_l),          
        .valid(fdiv_fsqrt_i0_valid_e1),          
        .in_frs1_rec_fn(frs1_rec_fn_e1),  
        .in_frs2_rec_fn(frs2_rec_fn_e1), 
        .fp64(fpu_e1.fp64),
        .in_rm(fpu_e1.rm),    
        .fdiv(fpu_e1.fdiv),       
        .fsqrt(fpu_e1.fsqrt),      
        .flush_lower(dec_tlu_flush_lower_wb),    
        .fdiv_fsqrt_stall(fpu_fdiv_fsqrt_stall),       
        .fdiv_fsqrt_finish(fpu_fdiv_fsqrt_finish),      
        .fdiv_fsqrt_data(fpu_fdiv_fsqrt_rec_fn_data), 
        .fdiv_fsqrt_exc(fpu_fdiv_fsqrt_exc)
    );

    assign fpu_fdiv_fsqrt_valid_e1 = fdiv_fsqrt_i0_valid_e1 & ~dec_tlu_flush_lower_wb;

    //**********************************************
    //*************e2 stage start*******************
    //**********************************************
    // Empty now!!!


    //**********************************************
    //*************e3 stage start*******************
    //**********************************************

    assign fpu_fma_rec_fn_result_e3 = fma_rec_fn_data_e3; 

    assign fpu_fma_exc_e3 = fma_exc_flags_e3; 


    // flw dc3 result ieee -> rec
    // fp32
    fNToRecFN #(.expWidth(8), .sigWidth(24)) fNToRecFN_lsu_res_fp32
    (
        .in(lsu_result_dc3[31:0]), 
        .out(lsu_rec_fn_result_fp32_dc3)
    );
    // fp64
    fNToRecFN #(.expWidth(11), .sigWidth(53)) fNToRecFN_lsu_res_fp64
    (
        .in(lsu_result_dc3[63:0]), 
        .out(lsu_rec_fn_result_fp64_dc3)
    );

    // Don't need to check NaN-boxing for FLW/FLD.
    assign lsu_rec_fn_result_dc3 = lsu_fp64_e3 ? lsu_rec_fn_result_fp64_dc3 : {32'b0, lsu_rec_fn_result_fp32_dc3};
    
    //**********************************************
    //*************wb stage start*******************
    //**********************************************
    recFNToFN #(.expWidth(8), .sigWidth(24)) RecToFn_WB_FP32
    (
        .in(dec_frd_rec_fn_wdata_wb[32:0]),
        .out(dec_frd_fp32_wdata_wb)
    );
    recFNToFN #(.expWidth(11), .sigWidth(53)) RecToFn_WB_FP64
    (
        .in(dec_frd_rec_fn_wdata_wb[64:0]),
        .out(dec_frd_fp64_wdata_wb)
    );
    // Do NaN-boxing when write back to FGPRs
    assign dec_frd_wdata_wb = dec_frd_fp64_wb ? dec_frd_fp64_wdata_wb :
                                    {{32{1'b1}}, dec_frd_fp32_wdata_wb};


endmodule

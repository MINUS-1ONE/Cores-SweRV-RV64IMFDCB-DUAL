/*
Float instructions' coverage
----------------------------------------------------------------------------------------------------------
Extension                                          Instruction         FU              Read XGPRs         Write XGPRs      Read FGPRs       Write FGPRs       Read FCSRs      Write FGPRs
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
RV32F Standard Extension                           FLW                 LSU
                                                   FSW                 LSU
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
                                                   FSD                 LSU
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

Data read from GPRs is in standard format. All intermediate data is in recoded format, and transfered into standard format when write back to GPRs.

*/
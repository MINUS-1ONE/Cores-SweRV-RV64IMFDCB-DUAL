// NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
// This is an automatically generated file by chisel on Wed Feb 23 22:07:35 CST 2022
//
// cmd:    swerv -target=high_perf -set iccm_enable 
//
#ifndef RV_NMI_VEC
#define RV_NMI_VEC 0x1111111100000000
#endif
#define RV_ICCM_DATA_CELL ram_16384x39
#define RV_ICCM_BANK_BITS 3
#define RV_ICCM_SIZE 512
#define RV_ICCM_BITS 19
#define RV_ICCM_SIZE_512 
#define RV_ICCM_EADR 0x6e07ffff
#define RV_ICCM_OFFSET 0x6e000000
#define RV_ICCM_NUM_BANKS 8
#define RV_ICCM_INDEX_BITS 14
#define RV_ICCM_RESERVED 0x1000
#define RV_ICCM_ENABLE 1
#define RV_ICCM_REGION 0x0
#define RV_ICCM_NUM_BANKS_8 
#define RV_ICCM_ROWS 16384
#define RV_ICCM_SADR 0x6e000000
#define RV_DCCM_SADR 0x70040000
#define RV_DCCM_INDEX_BITS 10
#define RV_DCCM_RESERVED 0x1000
#define RV_DCCM_EADR 0x7004ffff
#define RV_DCCM_ENABLE 1
#define RV_DCCM_DATA_CELL ram_1024x72
#define RV_DCCM_SIZE_64 
#define RV_DCCM_ROWS 1024
#define RV_DCCM_DATA_WIDTH 64
#define RV_DCCM_BANK_BITS 3
#define RV_DCCM_ECC_WIDTH 8
#define RV_LSU_SB_BITS 16
#define RV_DCCM_FDATA_WIDTH 72
#define RV_DCCM_SIZE 64
#define RV_DCCM_REGION 0x0
#define RV_DCCM_NUM_BANKS_8 
#define RV_DCCM_OFFSET 0x70040000
#define RV_DCCM_WIDTH_BITS 3
#define RV_DCCM_BITS 16
#define RV_DCCM_NUM_BANKS 8
#define RV_DCCM_BYTE_WIDTH 8
#define RV_EXTERNAL_DATA 0xe000000000580000
#define RV_UNUSED_REGION9 0x9000000000000000
#define RV_DEBUG_SB_MEM 0xd000000000580000
#define RV_EXTERNAL_PROG 0xd000000000000000
#define RV_UNUSED_REGION8 0x8000000000000000
#define RV_UNUSED_REGION3 0x3000000000000000
#define RV_UNUSED_REGION6 0x6000000000000000
#define RV_UNUSED_REGION7 0x7000000000000000
#define RV_SERIALIO 0xf000000000580000
#define RV_UNUSED_REGION1 0x1000000000000000
#define RV_UNUSED_REGION11 0xb000000000000000
#define RV_UNUSED_REGION4 0x4000000000000000
#define RV_UNUSED_REGION2 0x2000000000000000
#define RV_UNUSED_REGION5 0x5000000000000000
#define RV_UNUSED_REGION10 0xa000000000000000
#define RV_EXTERNAL_DATA_1 0xc000000000000000
#define RV_TARGET high_perf
#define RV_XLEN 64
#define RV_LDERR_ROLLBACK 1
#define TOP tb_top
#define RV_EXT_ADDRWIDTH 64
#define ASSERT_ON 
#define RV_EXT_DATAWIDTH 64
#define SDVT_AHB 1
#define RV_BUILD_AXI4 1
#define RV_STERR_ROLLBACK 0
#define CLOCK_PERIOD 100
#define DATAWIDTH 64
#define CPU_TOP `RV_TOP.swerv
#define RV_TOP `TOP.rvtop
#ifndef RV_RESET_VEC
#define RV_RESET_VEC 0x0000000000000000
#endif
#define RV_INST_ACCESS_ENABLE7 0x1
#define RV_INST_ACCESS_ADDR1 0x2000000000000000
#define RV_INST_ACCESS_ADDR3 0x6000000000000000
#define RV_INST_ACCESS_ADDR5 0xa000000000000000
#define RV_DATA_ACCESS_MASK3 0x2fffffffffffffff
#define RV_DATA_ACCESS_ADDR7 0xe000000000000000
#define RV_INST_ACCESS_ADDR4 0x8000000000000000
#define RV_DATA_ACCESS_MASK7 0x1fffffffffffffff
#define RV_INST_ACCESS_ADDR7 0xe000000000000000
#define RV_DATA_ACCESS_ADDR0 0x0000000000000000
#define RV_DATA_ACCESS_ENABLE3 0x1
#define RV_INST_ACCESS_ENABLE4 0x0
#define RV_INST_ACCESS_MASK6 0x1fffffffffffffff
#define RV_DATA_ACCESS_ADDR1 0x2000000000000000
#define RV_INST_ACCESS_ADDR0 0x0000000000000000
#define RV_INST_ACCESS_ADDR6 0xc000000000000000
#define RV_DATA_ACCESS_ENABLE0 0x1
#define RV_INST_ACCESS_MASK7 0x1fffffffffffffff
#define RV_INST_ACCESS_ADDR2 0x4000000000000000
#define RV_DATA_ACCESS_MASK4 0x1fffffffffffffff
#define RV_DATA_ACCESS_MASK6 0x1fffffffffffffff
#define RV_DATA_ACCESS_MASK1 0x1fffffffffffffff
#define RV_DATA_ACCESS_ENABLE2 0x1
#define RV_DATA_ACCESS_MASK2 0x1fffffffffffffff
#define RV_INST_ACCESS_ENABLE1 0x1
#define RV_INST_ACCESS_ENABLE6 0x1
#define RV_DATA_ACCESS_ENABLE6 0x1
#define RV_DATA_ACCESS_ENABLE1 0x1
#define RV_DATA_ACCESS_ADDR2 0x4000000000000000
#define RV_INST_ACCESS_MASK0 0x1fffffffffffffff
#define RV_DATA_ACCESS_ADDR6 0xc000000000000000
#define RV_DATA_ACCESS_ENABLE7 0x1
#define RV_DATA_ACCESS_ADDR5 0xa000000000000000
#define RV_DATA_ACCESS_ADDR4 0x8000000000000000
#define RV_DATA_ACCESS_ENABLE4 0x0
#define RV_DATA_ACCESS_MASK5 0x1fffffffffffffff
#define RV_INST_ACCESS_MASK2 0x1fffffffffffffff
#define RV_INST_ACCESS_ENABLE2 0x1
#define RV_INST_ACCESS_ENABLE3 0x1
#define RV_INST_ACCESS_MASK5 0x1fffffffffffffff
#define RV_INST_ACCESS_MASK4 0x1fffffffffffffff
#define RV_INST_ACCESS_ENABLE0 0x1
#define RV_INST_ACCESS_ENABLE5 0x1
#define RV_INST_ACCESS_MASK1 0x1fffffffffffffff
#define RV_DATA_ACCESS_MASK0 0x1fffffffffffffff
#define RV_DATA_ACCESS_ADDR3 0x6000000000000000
#define RV_INST_ACCESS_MASK3 0x1fffffffffffffff
#define RV_DATA_ACCESS_ENABLE5 0x1
#define RV_PIC_MEIPL_COUNT 8
#define RV_PIC_MEIPL_MASK 0xf
#define RV_PIC_MEIP_OFFSET 0x1000
#define RV_PIC_MEIGWCTRL_COUNT 8
#define RV_PIC_MEIGWCLR_COUNT 8
#define RV_PIC_BASE_ADDR 0x700c0000
#define RV_PIC_MPICCFG_MASK 0x1
#define RV_PIC_MEIE_MASK 0x1
#define RV_PIC_MEIE_COUNT 8
#define RV_PIC_MEIGWCTRL_OFFSET 0x4000
#define RV_PIC_MEIE_OFFSET 0x2000
#define RV_PIC_TOTAL_INT 8
#define RV_PIC_MEIP_COUNT 4
#define RV_PIC_MEIPL_OFFSET 0x0000
#define RV_PIC_MEIPT_OFFSET 0x3004
#define RV_PIC_INT_WORDS 1
#define RV_PIC_MEIGWCTRL_MASK 0x3
#define RV_PIC_REGION 0x0
#define RV_PIC_MEIP_MASK 0x0
#define RV_PIC_OFFSET 0x700c0000
#define RV_PIC_BITS 15
#define RV_PIC_MEIGWCLR_MASK 0x0
#define RV_PIC_TOTAL_INT_PLUS1 9
#define RV_PIC_MEIPT_MASK 0x0
#define RV_PIC_MEIGWCLR_OFFSET 0x5000
#define RV_PIC_MPICCFG_OFFSET 0x3000
#define RV_PIC_SIZE 32
#define RV_PIC_MEIPT_COUNT 8
#define RV_PIC_MPICCFG_COUNT 1
#define RV_DMA_BUS_TAG 1
#define RV_SB_BUS_TAG 1
#define RV_LSU_BUS_TAG 4
#define RV_IFU_BUS_TAG 3

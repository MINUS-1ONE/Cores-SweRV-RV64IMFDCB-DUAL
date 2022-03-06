// NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
// This is an automatically generated file by chisel on Wed Feb 23 22:06:40 CST 2022
//
// cmd:    swerv -target=default_pd -set iccm_enable 
//
`define RV_DMA_BUS_TAG 1
`define RV_IFU_BUS_TAG 3
`define RV_LSU_BUS_TAG 4
`define RV_SB_BUS_TAG 1
`define RV_XLEN 64
`define RV_UNUSED_REGION11 64'hb000000000000000
`define RV_UNUSED_REGION7 64'h7000000000000000
`define RV_UNUSED_REGION5 64'h5000000000000000
`define RV_DEBUG_SB_MEM 64'hd000000000580000
`define RV_UNUSED_REGION3 64'h3000000000000000
`define RV_EXTERNAL_DATA_1 64'hc000000000000000
`define RV_EXTERNAL_PROG 64'hd000000000000000
`define RV_SERIALIO 64'hf000000000580000
`define RV_UNUSED_REGION8 64'h8000000000000000
`define RV_UNUSED_REGION2 64'h2000000000000000
`define RV_UNUSED_REGION6 64'h6000000000000000
`define RV_UNUSED_REGION10 64'ha000000000000000
`define RV_UNUSED_REGION9 64'h9000000000000000
`define RV_UNUSED_REGION1 64'h1000000000000000
`define RV_UNUSED_REGION4 64'h4000000000000000
`define RV_EXTERNAL_DATA 64'he000000000580000
`define RV_RET_STACK_SIZE 4
`define RV_RESET_VEC 64'h0000000000000000
`define RV_INST_ACCESS_MASK1 64'h1fffffffffffffff
`define RV_INST_ACCESS_ADDR5 64'ha000000000000000
`define RV_INST_ACCESS_ADDR0 64'h0000000000000000
`define RV_INST_ACCESS_ADDR3 64'h6000000000000000
`define RV_INST_ACCESS_ENABLE2 1'h1
`define RV_DATA_ACCESS_ENABLE5 1'h1
`define RV_INST_ACCESS_MASK4 64'h1fffffffffffffff
`define RV_DATA_ACCESS_ADDR7 64'he000000000000000
`define RV_DATA_ACCESS_MASK6 64'h1fffffffffffffff
`define RV_DATA_ACCESS_ENABLE3 1'h1
`define RV_INST_ACCESS_ENABLE3 1'h1
`define RV_INST_ACCESS_ENABLE6 1'h1
`define RV_INST_ACCESS_MASK6 64'h1fffffffffffffff
`define RV_DATA_ACCESS_ADDR0 64'h0000000000000000
`define RV_DATA_ACCESS_ENABLE7 1'h1
`define RV_INST_ACCESS_ENABLE1 1'h1
`define RV_DATA_ACCESS_MASK4 64'h1fffffffffffffff
`define RV_INST_ACCESS_MASK2 64'h1fffffffffffffff
`define RV_INST_ACCESS_MASK3 64'h1fffffffffffffff
`define RV_DATA_ACCESS_ADDR1 64'h2000000000000000
`define RV_INST_ACCESS_ADDR1 64'h2000000000000000
`define RV_INST_ACCESS_MASK5 64'h1fffffffffffffff
`define RV_DATA_ACCESS_ADDR6 64'hc000000000000000
`define RV_DATA_ACCESS_MASK7 64'h1fffffffffffffff
`define RV_DATA_ACCESS_ADDR5 64'ha000000000000000
`define RV_DATA_ACCESS_ENABLE1 1'h1
`define RV_INST_ACCESS_ENABLE4 1'h0
`define RV_DATA_ACCESS_ADDR4 64'h8000000000000000
`define RV_DATA_ACCESS_ADDR3 64'h6000000000000000
`define RV_INST_ACCESS_ADDR7 64'he000000000000000
`define RV_DATA_ACCESS_MASK0 64'h1fffffffffffffff
`define RV_DATA_ACCESS_ENABLE2 1'h1
`define RV_DATA_ACCESS_MASK3 64'h2fffffffffffffff
`define RV_DATA_ACCESS_ENABLE0 1'h1
`define RV_INST_ACCESS_ENABLE0 1'h1
`define RV_DATA_ACCESS_MASK1 64'h1fffffffffffffff
`define RV_INST_ACCESS_ADDR2 64'h4000000000000000
`define RV_DATA_ACCESS_MASK5 64'h1fffffffffffffff
`define RV_INST_ACCESS_ENABLE7 1'h1
`define RV_INST_ACCESS_ADDR4 64'h8000000000000000
`define RV_INST_ACCESS_MASK0 64'h1fffffffffffffff
`define RV_INST_ACCESS_MASK7 64'h1fffffffffffffff
`define RV_INST_ACCESS_ENABLE5 1'h1
`define RV_DATA_ACCESS_ADDR2 64'h4000000000000000
`define RV_DATA_ACCESS_ENABLE6 1'h1
`define RV_INST_ACCESS_ADDR6 64'hc000000000000000
`define RV_DATA_ACCESS_ENABLE4 1'h0
`define RV_DATA_ACCESS_MASK2 64'h1fffffffffffffff
`define CLOCK_PERIOD 100
`define RV_TOP `TOP.rvtop
`define CPU_TOP `RV_TOP.swerv
`define DATAWIDTH 64
`define RV_STERR_ROLLBACK 0
`define RV_EXT_ADDRWIDTH 64
`define ASSERT_ON 
`define SDVT_AHB 1
`define TOP tb_top
`define RV_BUILD_AXI4 1
`define RV_LDERR_ROLLBACK 1
`define RV_EXT_DATAWIDTH 64
`define RV_ICACHE_TADDR_HIGH 5
`define RV_ICACHE_TAG_HIGH 12
`define RV_ICACHE_TAG_LOW 6
`define RV_ICACHE_IC_ROWS 256
`define RV_ICACHE_TAG_DEPTH 64
`define RV_ICACHE_SIZE 16
`define RV_ICACHE_DATA_CELL ram_256x34
`define RV_ICACHE_TAG_CELL ram_64x53
`define RV_ICACHE_IC_INDEX 8
`define RV_ICACHE_ENABLE 1
`define RV_ICACHE_IC_DEPTH 8
`define RV_BTB_ADDR_LO 4
`define RV_BTB_INDEX1_LO 4
`define RV_BTB_SIZE 32
`define RV_BTB_BTAG_FOLD 1
`define RV_BTB_INDEX3_LO 8
`define RV_BTB_INDEX2_HI 7
`define RV_BTB_INDEX2_LO 6
`define RV_BTB_INDEX1_HI 5
`define RV_BTB_ARRAY_DEPTH 4
`define RV_BTB_INDEX3_HI 9
`define RV_BTB_BTAG_SIZE 9
`define RV_BTB_ADDR_HI 5
`define RV_DCCM_NUM_BANKS_8 
`define RV_DCCM_SIZE 32
`define RV_DCCM_ROWS 512
`define RV_DCCM_WIDTH_BITS 3
`define RV_DCCM_ECC_WIDTH 8
`define RV_DCCM_OFFSET 32'h70040000
`define RV_DCCM_EADR 64'h70047fff
`define RV_LSU_SB_BITS 15
`define RV_DCCM_DATA_WIDTH 64
`define RV_DCCM_SIZE_32 
`define RV_DCCM_SADR 64'h70040000
`define RV_DCCM_DATA_CELL ram_512x72
`define RV_DCCM_NUM_BANKS 8
`define RV_DCCM_INDEX_BITS 9
`define RV_DCCM_FDATA_WIDTH 72
`define RV_DCCM_BITS 15
`define RV_DCCM_RESERVED 'h1000
`define RV_DCCM_REGION 4'h0
`define RV_DCCM_ENABLE 1
`define RV_DCCM_BYTE_WIDTH 8
`define RV_DCCM_BANK_BITS 3
`define RV_ICCM_NUM_BANKS_8 
`define RV_ICCM_BITS 19
`define RV_ICCM_ROWS 16384
`define RV_ICCM_SADR 64'h6e000000
`define RV_ICCM_BANK_BITS 3
`define RV_ICCM_INDEX_BITS 14
`define RV_ICCM_SIZE_512 
`define RV_ICCM_NUM_BANKS 8
`define RV_ICCM_SIZE 512
`define RV_ICCM_DATA_CELL ram_16384x39
`define RV_ICCM_OFFSET 32'h6e000000
`define RV_ICCM_RESERVED 'h1000
`define RV_ICCM_EADR 64'h6e07ffff
`define RV_ICCM_REGION 4'h0
`define RV_ICCM_ENABLE 1
`define RV_NUMIREGS 32
`define RV_BHT_GHR_SIZE 5
`define RV_BHT_ADDR_LO 4
`define RV_BHT_ADDR_HI 7
`define RV_BHT_GHR_RANGE 4:0
`define RV_BHT_HASH_STRING {ghr[3:2] ^ {ghr[3+1], {4-1-2{1'b0} } },hashin[5:4]^ghr[2-1:0]}
`define RV_BHT_SIZE 128
`define RV_BHT_GHR_PAD2 fghr[4:3],2'b0
`define RV_BHT_ARRAY_DEPTH 16
`define RV_BHT_GHR_PAD fghr[4],3'b0
`define RV_TARGET default_pd
`define TEC_RV_ICG clockhdr
`define RV_DEC_INSTBUF_DEPTH 4
`define RV_LSU_NUM_NBLOAD_WIDTH 3
`define RV_LSU_STBUF_DEPTH 8
`define RV_DMA_BUF_DEPTH 4
`define RV_LSU_NUM_NBLOAD 8
`define REGWIDTH 64
`define RV_PIC_MEIP_COUNT 4
`define RV_PIC_MEIPL_MASK 'hf
`define RV_PIC_MEIPT_OFFSET 'h3004
`define RV_PIC_REGION 4'h0
`define RV_PIC_MEIGWCLR_COUNT 8
`define RV_PIC_MPICCFG_MASK 'h1
`define RV_PIC_MEIP_OFFSET 'h1000
`define RV_PIC_OFFSET 32'h700c0000
`define RV_PIC_MEIPT_COUNT 8
`define RV_PIC_BASE_ADDR 64'h700c0000
`define RV_PIC_MEIGWCTRL_COUNT 8
`define RV_PIC_MEIE_OFFSET 'h2000
`define RV_PIC_MEIGWCTRL_MASK 'h3
`define RV_PIC_SIZE 32
`define RV_PIC_TOTAL_INT 8
`define RV_PIC_MEIE_MASK 'h1
`define RV_PIC_MEIPL_COUNT 8
`define RV_PIC_MEIGWCLR_OFFSET 'h5000
`define RV_PIC_MEIPT_MASK 'h0
`define RV_PIC_MEIP_MASK 'h0
`define RV_PIC_MEIGWCLR_MASK 'h0
`define RV_PIC_MEIPL_OFFSET 'h0000
`define RV_PIC_MEIE_COUNT 8
`define RV_PIC_MPICCFG_OFFSET 'h3000
`define RV_PIC_INT_WORDS 1
`define RV_PIC_TOTAL_INT_PLUS1 9
`define RV_PIC_MPICCFG_COUNT 1
`define RV_PIC_BITS 15
`define RV_PIC_MEIGWCTRL_OFFSET 'h4000
`define RV_NMI_VEC 64'h1111111100000000

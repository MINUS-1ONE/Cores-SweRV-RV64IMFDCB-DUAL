#  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#  This is an automatically generated file by chisel on Wed Feb 23 22:07:24 CST 2022
# 
#  cmd:    swerv -target=default -set iccm_enable 
# 
# To use this in a perf script, use 'require $RV64_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'triggers' => [
                            {
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            },
                            {
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'poke_mask' => [
                                               '0x081810c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            },
                            {
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ]
                            },
                            {
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'poke_mask' => [
                                               '0x081810c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ]
                            }
                          ],
            'iccm' => {
                        'iccm_region' => '0x0',
                        'iccm_size_512' => '',
                        'iccm_enable' => 1,
                        'iccm_bank_bits' => 3,
                        'iccm_reserved' => '0x1000',
                        'iccm_sadr' => '0x6e000000',
                        'iccm_offset' => '0x6e000000',
                        'iccm_rows' => '16384',
                        'iccm_num_banks_8' => '',
                        'iccm_bits' => 19,
                        'iccm_eadr' => '0x6e07ffff',
                        'iccm_data_cell' => 'ram_16384x39',
                        'iccm_index_bits' => 14,
                        'iccm_size' => 512,
                        'iccm_num_banks' => '8'
                      },
            'bht' => {
                       'bht_addr_hi' => 7,
                       'bht_size' => 128,
                       'bht_array_depth' => 16,
                       'bht_addr_lo' => '4',
                       'bht_ghr_pad' => 'fghr[4],3\'b0',
                       'bht_ghr_size' => 5,
                       'bht_hash_string' => '{ghr[3:2] ^ {ghr[3+1], {4-1-2{1\'b0} } },hashin[5:4]^ghr[2-1:0]}',
                       'bht_ghr_range' => '4:0',
                       'bht_ghr_pad2' => 'fghr[4:3],2\'b0'
                     },
            'csr' => {
                       'pmpaddr10' => {
                                        'exists' => 'false'
                                      },
                       'micect' => {
                                     'mask' => '0xffffffff',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'number' => '0x7f0'
                                   },
                       'dmst' => {
                                   'mask' => '0x0',
                                   'exists' => 'true',
                                   'debug' => 'true',
                                   'number' => '0x7c4',
                                   'reset' => '0x0',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.'
                                 },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mhpmcounter3h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'mhpmcounter3' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'mitbnd1' => {
                                      'mask' => '0xffffffff',
                                      'exists' => 'true',
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d6'
                                    },
                       'pmpcfg2' => {
                                      'exists' => 'false'
                                    },
                       'mvendorid' => {
                                        'mask' => '0x0',
                                        'exists' => 'true',
                                        'reset' => '0x45'
                                      },
                       'mip' => {
                                  'reset' => '0x0',
                                  'poke_mask' => '0x70000888',
                                  'exists' => 'true',
                                  'mask' => '0x0'
                                },
                       'meicurpl' => {
                                       'exists' => 'true',
                                       'mask' => '0xf',
                                       'number' => '0xbcc',
                                       'reset' => '0x0',
                                       'comment' => 'External interrupt current priority level.'
                                     },
                       'mie' => {
                                  'reset' => '0x0',
                                  'exists' => 'true',
                                  'mask' => '0x70000888'
                                },
                       'dicawics' => {
                                       'debug' => 'true',
                                       'mask' => '0x0130fffc',
                                       'exists' => 'true',
                                       'comment' => 'Cache diagnostics.',
                                       'reset' => '0x0',
                                       'number' => '0x7c8'
                                     },
                       'mhpmcounter5' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'mhpmcounter5h' => {
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0xffffffff'
                                          },
                       'mhpmcounter4' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         },
                       'meicidpl' => {
                                       'comment' => 'External interrupt claim id priority level.',
                                       'reset' => '0x0',
                                       'number' => '0xbcb',
                                       'exists' => 'true',
                                       'mask' => '0xf'
                                     },
                       'pmpcfg3' => {
                                      'exists' => 'false'
                                    },
                       'mitcnt1' => {
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d5',
                                      'reset' => '0x0'
                                    },
                       'pmpcfg1' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr1' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent3' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'pmpaddr9' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent5' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'pmpaddr7' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent6' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'mitbnd0' => {
                                      'number' => '0x7d3',
                                      'reset' => '0xffffffff',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff'
                                    },
                       'mpmc' => {
                                   'mask' => '0x2',
                                   'exists' => 'true',
                                   'poke_mask' => '0x2',
                                   'comment' => 'FWHALT',
                                   'reset' => '0x2',
                                   'number' => '0x7c6'
                                 },
                       'dicad1' => {
                                     'mask' => '0x3',
                                     'exists' => 'true',
                                     'debug' => 'true',
                                     'number' => '0x7ca',
                                     'reset' => '0x0',
                                     'comment' => 'Cache diagnostics.'
                                   },
                       'misa' => {
                                   'mask' => '0x0',
                                   'exists' => 'true',
                                   'reset' => '0x40001104'
                                 },
                       'pmpaddr11' => {
                                        'exists' => 'false'
                                      },
                       'mfdc' => {
                                   'number' => '0x7f9',
                                   'reset' => '0x00070040',
                                   'exists' => 'true',
                                   'mask' => '0x000727ff'
                                 },
                       'pmpaddr8' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr5' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr3' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr12' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter6h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'pmpaddr2' => {
                                       'exists' => 'false'
                                     },
                       'dicad0' => {
                                     'debug' => 'true',
                                     'exists' => 'true',
                                     'mask' => '0xffffffff',
                                     'comment' => 'Cache diagnostics.',
                                     'reset' => '0x0',
                                     'number' => '0x7c9'
                                   },
                       'mcpc' => {
                                   'mask' => '0x0',
                                   'exists' => 'true',
                                   'reset' => '0x0',
                                   'number' => '0x7c2'
                                 },
                       'pmpcfg0' => {
                                      'exists' => 'false'
                                    },
                       'mstatus' => {
                                      'reset' => '0x1800',
                                      'mask' => '0x88',
                                      'exists' => 'true'
                                    },
                       'tselect' => {
                                      'reset' => '0x0',
                                      'mask' => '0x3',
                                      'exists' => 'true'
                                    },
                       'mitctl1' => {
                                      'mask' => '0x00000007',
                                      'exists' => 'true',
                                      'reset' => '0x1',
                                      'number' => '0x7d7'
                                    },
                       'mhpmevent4' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'mitctl0' => {
                                      'number' => '0x7d4',
                                      'reset' => '0x1',
                                      'exists' => 'true',
                                      'mask' => '0x00000007'
                                    },
                       'meipt' => {
                                    'mask' => '0xf',
                                    'exists' => 'true',
                                    'number' => '0xbc9',
                                    'reset' => '0x0',
                                    'comment' => 'External interrupt priority threshold.'
                                  },
                       'mitcnt0' => {
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d2',
                                      'reset' => '0x0'
                                    },
                       'pmpaddr14' => {
                                        'exists' => 'false'
                                      },
                       'mimpid' => {
                                     'reset' => '0x6',
                                     'exists' => 'true',
                                     'mask' => '0x0'
                                   },
                       'meicpct' => {
                                      'comment' => 'External claim id/priority capture.',
                                      'reset' => '0x0',
                                      'number' => '0xbca',
                                      'mask' => '0x0',
                                      'exists' => 'true'
                                    },
                       'pmpaddr0' => {
                                       'exists' => 'false'
                                     },
                       'marchid' => {
                                      'reset' => '0x0000000b',
                                      'mask' => '0x0',
                                      'exists' => 'true'
                                    },
                       'mhpmcounter6' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'miccmect' => {
                                       'exists' => 'true',
                                       'mask' => '0xffffffff',
                                       'reset' => '0x0',
                                       'number' => '0x7f1'
                                     },
                       'mhpmcounter4h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'dcsr' => {
                                   'reset' => '0x40000003',
                                   'mask' => '0x00008c04',
                                   'exists' => 'true',
                                   'poke_mask' => '0x00008dcc'
                                 },
                       'mgpmc' => {
                                    'number' => '0x7d0',
                                    'reset' => '0x1',
                                    'mask' => '0x1',
                                    'exists' => 'true'
                                  },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'mcountinhibit' => {
                                            'exists' => 'false'
                                          },
                       'pmpaddr6' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr15' => {
                                        'exists' => 'false'
                                      },
                       'mcgc' => {
                                   'number' => '0x7f8',
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'poke_mask' => '0x000001ff',
                                   'mask' => '0x000001ff'
                                 },
                       'pmpaddr4' => {
                                       'exists' => 'false'
                                     },
                       'dicago' => {
                                     'number' => '0x7cb',
                                     'reset' => '0x0',
                                     'comment' => 'Cache diagnostics.',
                                     'mask' => '0x0',
                                     'exists' => 'true',
                                     'debug' => 'true'
                                   },
                       'pmpaddr13' => {
                                        'exists' => 'false'
                                      },
                       'mdccmect' => {
                                       'reset' => '0x0',
                                       'number' => '0x7f2',
                                       'exists' => 'true',
                                       'mask' => '0xffffffff'
                                     },
                       'time' => {
                                   'exists' => 'false'
                                 }
                     },
            'reset_vec' => '0x0000000000000000',
            'target' => 'default',
            'testbench' => {
                             'clock_period' => '100',
                             'SDVT_AHB' => '1',
                             'RV_TOP' => '`TOP.rvtop',
                             'ext_addrwidth' => '64',
                             'datawidth' => '64',
                             'assert_on' => '',
                             'sterr_rollback' => '0',
                             'TOP' => 'tb_top',
                             'build_axi4' => '1',
                             'lderr_rollback' => '1',
                             'CPU_TOP' => '`RV_TOP.swerv',
                             'ext_datawidth' => '64'
                           },
            'protection' => {
                              'inst_access_enable7' => '0x1',
                              'data_access_mask5' => '0x1fffffffffffffff',
                              'inst_access_enable1' => '0x1',
                              'data_access_mask4' => '0x1fffffffffffffff',
                              'inst_access_enable2' => '0x1',
                              'data_access_mask2' => '0x1fffffffffffffff',
                              'data_access_mask0' => '0x1fffffffffffffff',
                              'inst_access_addr4' => '0x8000000000000000',
                              'data_access_addr5' => '0xa000000000000000',
                              'inst_access_mask4' => '0x1fffffffffffffff',
                              'data_access_enable0' => '0x1',
                              'inst_access_mask2' => '0x1fffffffffffffff',
                              'inst_access_mask6' => '0x1fffffffffffffff',
                              'data_access_mask1' => '0x1fffffffffffffff',
                              'inst_access_enable4' => '0x0',
                              'inst_access_addr2' => '0x4000000000000000',
                              'inst_access_addr1' => '0x2000000000000000',
                              'inst_access_addr7' => '0xe000000000000000',
                              'inst_access_mask1' => '0x1fffffffffffffff',
                              'inst_access_mask7' => '0x1fffffffffffffff',
                              'inst_access_addr5' => '0xa000000000000000',
                              'data_access_enable5' => '0x1',
                              'data_access_mask3' => '0x2fffffffffffffff',
                              'inst_access_addr6' => '0xc000000000000000',
                              'data_access_addr7' => '0xe000000000000000',
                              'inst_access_addr0' => '0x0000000000000000',
                              'inst_access_mask3' => '0x1fffffffffffffff',
                              'data_access_enable2' => '0x1',
                              'data_access_mask7' => '0x1fffffffffffffff',
                              'data_access_enable3' => '0x1',
                              'inst_access_enable3' => '0x1',
                              'inst_access_enable0' => '0x1',
                              'data_access_addr4' => '0x8000000000000000',
                              'inst_access_enable6' => '0x1',
                              'data_access_addr1' => '0x2000000000000000',
                              'data_access_mask6' => '0x1fffffffffffffff',
                              'data_access_enable4' => '0x0',
                              'data_access_addr6' => '0xc000000000000000',
                              'inst_access_mask5' => '0x1fffffffffffffff',
                              'inst_access_mask0' => '0x1fffffffffffffff',
                              'data_access_enable7' => '0x1',
                              'inst_access_enable5' => '0x1',
                              'data_access_addr0' => '0x0000000000000000',
                              'data_access_enable6' => '0x1',
                              'data_access_enable1' => '0x1',
                              'data_access_addr2' => '0x4000000000000000',
                              'data_access_addr3' => '0x6000000000000000',
                              'inst_access_addr3' => '0x6000000000000000'
                            },
            'retstack' => {
                            'ret_stack_size' => '4'
                          },
            'icache' => {
                          'icache_enable' => '1',
                          'icache_ic_rows' => '256',
                          'icache_tag_cell' => 'ram_64x53',
                          'icache_ic_index' => 8,
                          'icache_tag_low' => '6',
                          'icache_tag_high' => 12,
                          'icache_taddr_high' => 5,
                          'icache_data_cell' => 'ram_256x34',
                          'icache_size' => 16,
                          'icache_ic_depth' => 8,
                          'icache_tag_depth' => 64
                        },
            'nmi_vec' => '0x1111111100000000',
            'core' => {
                        'dma_buf_depth' => '4',
                        'dec_instbuf_depth' => '4',
                        'fpga_optimize' => 1,
                        'lsu_num_nbload_width' => '3',
                        'lsu_stbuf_depth' => '8',
                        'lsu_num_nbload' => '8'
                      },
            'xlen' => 64,
            'tec_rv_icg' => 'clockhdr',
            'regwidth' => '64',
            'numiregs' => '32',
            'even_odd_trigger_chains' => 'true',
            'btb' => {
                       'btb_index3_hi' => 9,
                       'btb_addr_lo' => '4',
                       'btb_index1_hi' => 5,
                       'btb_array_depth' => 4,
                       'btb_index2_hi' => 7,
                       'btb_index2_lo' => 6,
                       'btb_btag_fold' => 1,
                       'btb_size' => 32,
                       'btb_btag_size' => 9,
                       'btb_index3_lo' => 8,
                       'btb_addr_hi' => 5,
                       'btb_index1_lo' => '4'
                     },
            'physical' => '1',
            'pic' => {
                       'pic_meigwclr_mask' => '0x0',
                       'pic_meip_count' => 4,
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_mpiccfg_count' => 1,
                       'pic_meie_mask' => '0x1',
                       'pic_meip_mask' => '0x0',
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meipl_mask' => '0xf',
                       'pic_int_words' => 1,
                       'pic_size' => 32,
                       'pic_offset' => '0x700c0000',
                       'pic_meipt_offset' => '0x3004',
                       'pic_meip_offset' => '0x1000',
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_region' => '0x0',
                       'pic_total_int_plus1' => 9,
                       'pic_meie_offset' => '0x2000',
                       'pic_base_addr' => '0x700c0000',
                       'pic_meigwctrl_count' => 8,
                       'pic_meipl_offset' => '0x0000',
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_meipt_count' => 8,
                       'pic_meipt_mask' => '0x0',
                       'pic_total_int' => 8,
                       'pic_meigwclr_count' => 8,
                       'pic_meipl_count' => 8,
                       'pic_meie_count' => 8,
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_bits' => 15
                     },
            'memmap' => {
                          'external_prog' => '0xd000000000000000',
                          'unused_region9' => '0x9000000000000000',
                          'external_data_1' => '0xc000000000000000',
                          'external_data' => '0xe000000000580000',
                          'unused_region7' => '0x7000000000000000',
                          'unused_region3' => '0x3000000000000000',
                          'unused_region10' => '0xa000000000000000',
                          'unused_region8' => '0x8000000000000000',
                          'unused_region6' => '0x6000000000000000',
                          'unused_region11' => '0xb000000000000000',
                          'unused_region4' => '0x4000000000000000',
                          'unused_region1' => '0x1000000000000000',
                          'serialio' => '0xf000000000580000',
                          'unused_region5' => '0x5000000000000000',
                          'consoleio' => '0xf000000000580000',
                          'unused_region2' => '0x2000000000000000',
                          'debug_sb_mem' => '0xd000000000580000'
                        },
            'dccm' => {
                        'dccm_sadr' => '0x70040000',
                        'dccm_rows' => '1024',
                        'dccm_num_banks_8' => '',
                        'dccm_eadr' => '0x7004ffff',
                        'dccm_size_64' => '',
                        'dccm_byte_width' => '8',
                        'dccm_region' => '0x0',
                        'dccm_data_cell' => 'ram_1024x72',
                        'dccm_size' => 64,
                        'dccm_index_bits' => 10,
                        'dccm_bits' => 16,
                        'lsu_sb_bits' => 16,
                        'dccm_fdata_width' => 72,
                        'dccm_data_width' => 64,
                        'dccm_reserved' => '0x1000',
                        'dccm_offset' => '0x70040000',
                        'dccm_enable' => '1',
                        'dccm_num_banks' => '8',
                        'dccm_ecc_width' => 8,
                        'dccm_width_bits' => 3,
                        'dccm_bank_bits' => 3
                      },
            'verilator' => '',
            'harts' => 1,
            'max_mmode_perf_event' => '50',
            'bus' => {
                       'sb_bus_tag' => '1',
                       'lsu_bus_tag' => 4,
                       'dma_bus_tag' => '1',
                       'ifu_bus_tag' => '3'
                     },
            'num_mmode_perf_regs' => '4'
          );
1;

#  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#  This is an automatically generated file by riscv on Fri 18 Mar 2022 02:29:32 AM PDT
# 
#  cmd:    swerv -target=default -set iccm_enable 
# 
# To use this in a perf script, use 'require $RV64_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'memmap' => {
                          'serialio' => '0xf000000000580000',
                          'consoleio' => '0xf000000000580000',
                          'external_prog' => '0xd000000000000000',
                          'external_data_1' => '0xc000000000000000',
                          'unused_region10' => '0xa000000000000000',
                          'unused_region9' => '0x9000000000000000',
                          'unused_region4' => '0x4000000000000000',
                          'unused_region3' => '0x3000000000000000',
                          'external_data' => '0xe000000000580000',
                          'unused_region8' => '0x8000000000000000',
                          'unused_region7' => '0x7000000000000000',
                          'unused_region1' => '0x1000000000000000',
                          'unused_region5' => '0x5000000000000000',
                          'debug_sb_mem' => '0xd000000000580000',
                          'unused_region2' => '0x2000000000000000',
                          'unused_region6' => '0x6000000000000000',
                          'unused_region11' => '0xb000000000000000'
                        },
            'bus' => {
                       'ifu_bus_tag' => '3',
                       'lsu_bus_tag' => 4,
                       'sb_bus_tag' => '1',
                       'dma_bus_tag' => '1'
                     },
            'even_odd_trigger_chains' => 'true',
            'max_mmode_perf_event' => '50',
            'icache' => {
                          'icache_tag_high' => 12,
                          'icache_enable' => '1',
                          'icache_tag_low' => '6',
                          'icache_tag_cell' => 'ram_64x53',
                          'icache_ic_index' => 8,
                          'icache_taddr_high' => 5,
                          'icache_data_cell' => 'ram_256x34',
                          'icache_ic_depth' => 8,
                          'icache_tag_depth' => 64,
                          'icache_size' => 16,
                          'icache_ic_rows' => '256'
                        },
            'tec_rv_icg' => 'clockhdr',
            'protection' => {
                              'inst_access_enable2' => '0x1',
                              'inst_access_addr2' => '0x4000000000000000',
                              'inst_access_enable1' => '0x1',
                              'inst_access_enable4' => '0x0',
                              'data_access_addr4' => '0x8000000000000000',
                              'inst_access_addr5' => '0xa000000000000000',
                              'data_access_addr7' => '0xe000000000000000',
                              'data_access_mask1' => '0x1fffffffffffffff',
                              'data_access_mask3' => '0x2fffffffffffffff',
                              'inst_access_addr6' => '0xc000000000000000',
                              'data_access_addr0' => '0x0000000000000000',
                              'inst_access_addr1' => '0x2000000000000000',
                              'inst_access_addr3' => '0x6000000000000000',
                              'inst_access_enable6' => '0x1',
                              'data_access_enable3' => '0x1',
                              'data_access_mask6' => '0x1fffffffffffffff',
                              'data_access_enable0' => '0x1',
                              'inst_access_mask0' => '0x1fffffffffffffff',
                              'data_access_enable5' => '0x1',
                              'data_access_mask2' => '0x1fffffffffffffff',
                              'inst_access_mask4' => '0x1fffffffffffffff',
                              'data_access_enable7' => '0x1',
                              'data_access_mask5' => '0x1fffffffffffffff',
                              'inst_access_mask7' => '0x1fffffffffffffff',
                              'inst_access_mask3' => '0x1fffffffffffffff',
                              'inst_access_mask1' => '0x1fffffffffffffff',
                              'inst_access_addr0' => '0x0000000000000000',
                              'data_access_addr6' => '0xc000000000000000',
                              'data_access_enable2' => '0x1',
                              'data_access_enable1' => '0x1',
                              'data_access_enable4' => '0x0',
                              'data_access_addr2' => '0x4000000000000000',
                              'inst_access_addr7' => '0xe000000000000000',
                              'data_access_addr5' => '0xa000000000000000',
                              'inst_access_addr4' => '0x8000000000000000',
                              'inst_access_mask2' => '0x1fffffffffffffff',
                              'inst_access_mask5' => '0x1fffffffffffffff',
                              'data_access_mask7' => '0x1fffffffffffffff',
                              'inst_access_enable7' => '0x1',
                              'data_access_mask4' => '0x1fffffffffffffff',
                              'data_access_addr3' => '0x6000000000000000',
                              'data_access_addr1' => '0x2000000000000000',
                              'inst_access_enable3' => '0x1',
                              'data_access_enable6' => '0x1',
                              'data_access_mask0' => '0x1fffffffffffffff',
                              'inst_access_mask6' => '0x1fffffffffffffff',
                              'inst_access_enable0' => '0x1',
                              'inst_access_enable5' => '0x1'
                            },
            'regwidth' => '64',
            'numiregs' => '32',
            'csr' => {
                       'mitbnd0' => {
                                      'exists' => 'true',
                                      'reset' => '0xffffffff',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d3'
                                    },
                       'dicad1' => {
                                     'mask' => '0x3',
                                     'number' => '0x7ca',
                                     'comment' => 'Cache diagnostics.',
                                     'debug' => 'true',
                                     'exists' => 'true',
                                     'reset' => '0x0'
                                   },
                       'mgpmc' => {
                                    'reset' => '0x1',
                                    'exists' => 'true',
                                    'number' => '0x7d0',
                                    'mask' => '0x1'
                                  },
                       'dcsr' => {
                                   'poke_mask' => '0x00008dcc',
                                   'mask' => '0x00008c04',
                                   'reset' => '0x40000003',
                                   'exists' => 'true'
                                 },
                       'meipt' => {
                                    'reset' => '0x0',
                                    'exists' => 'true',
                                    'comment' => 'External interrupt priority threshold.',
                                    'number' => '0xbc9',
                                    'mask' => '0xf'
                                  },
                       'pmpaddr3' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent3' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'mip' => {
                                  'reset' => '0x0',
                                  'exists' => 'true',
                                  'poke_mask' => '0x70000888',
                                  'mask' => '0x0'
                                },
                       'mhpmcounter5h' => {
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0xffffffff'
                                          },
                       'micect' => {
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'mask' => '0xffffffff',
                                     'number' => '0x7f0'
                                   },
                       'mimpid' => {
                                     'exists' => 'true',
                                     'reset' => '0x6',
                                     'mask' => '0x0'
                                   },
                       'mhpmcounter3' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'pmpcfg1' => {
                                      'exists' => 'false'
                                    },
                       'mhpmevent4' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'mie' => {
                                  'exists' => 'true',
                                  'reset' => '0x0',
                                  'mask' => '0x70000888'
                                },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'pmpaddr15' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter6h' => {
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0',
                                            'exists' => 'true'
                                          },
                       'dicad0' => {
                                     'exists' => 'true',
                                     'debug' => 'true',
                                     'reset' => '0x0',
                                     'mask' => '0xffffffff',
                                     'comment' => 'Cache diagnostics.',
                                     'number' => '0x7c9'
                                   },
                       'pmpaddr9' => {
                                       'exists' => 'false'
                                     },
                       'miccmect' => {
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'mask' => '0xffffffff',
                                       'number' => '0x7f1'
                                     },
                       'pmpcfg0' => {
                                      'exists' => 'false'
                                    },
                       'dicawics' => {
                                       'reset' => '0x0',
                                       'debug' => 'true',
                                       'exists' => 'true',
                                       'number' => '0x7c8',
                                       'comment' => 'Cache diagnostics.',
                                       'mask' => '0x0130fffc'
                                     },
                       'pmpaddr14' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter5' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         },
                       'mvendorid' => {
                                        'mask' => '0x0',
                                        'reset' => '0x45',
                                        'exists' => 'true'
                                      },
                       'mpmc' => {
                                   'reset' => '0x2',
                                   'exists' => 'true',
                                   'poke_mask' => '0x2',
                                   'comment' => 'FWHALT',
                                   'number' => '0x7c6',
                                   'mask' => '0x2'
                                 },
                       'mitbnd1' => {
                                      'reset' => '0xffffffff',
                                      'exists' => 'true',
                                      'number' => '0x7d6',
                                      'mask' => '0xffffffff'
                                    },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'mhpmcounter6' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'pmpaddr7' => {
                                       'exists' => 'false'
                                     },
                       'marchid' => {
                                      'exists' => 'true',
                                      'reset' => '0x0000000b',
                                      'mask' => '0x0'
                                    },
                       'mstatus' => {
                                      'exists' => 'true',
                                      'reset' => '0x1800',
                                      'mask' => '0x88'
                                    },
                       'pmpaddr11' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter3h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'meicidpl' => {
                                       'comment' => 'External interrupt claim id priority level.',
                                       'number' => '0xbcb',
                                       'mask' => '0xf',
                                       'reset' => '0x0',
                                       'exists' => 'true'
                                     },
                       'dmst' => {
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'debug' => 'true',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'number' => '0x7c4',
                                   'mask' => '0x0'
                                 },
                       'misa' => {
                                   'reset' => '0x40001104',
                                   'exists' => 'true',
                                   'mask' => '0x0'
                                 },
                       'pmpaddr1' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr0' => {
                                       'exists' => 'false'
                                     },
                       'pmpcfg3' => {
                                      'exists' => 'false'
                                    },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'pmpcfg2' => {
                                      'exists' => 'false'
                                    },
                       'mhpmevent5' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'mitctl0' => {
                                      'exists' => 'true',
                                      'reset' => '0x1',
                                      'mask' => '0x00000007',
                                      'number' => '0x7d4'
                                    },
                       'pmpaddr5' => {
                                       'exists' => 'false'
                                     },
                       'mhpmcounter4h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'mitcnt0' => {
                                      'number' => '0x7d2',
                                      'mask' => '0xffffffff',
                                      'reset' => '0x0',
                                      'exists' => 'true'
                                    },
                       'mhpmevent6' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'pmpaddr10' => {
                                        'exists' => 'false'
                                      },
                       'dicago' => {
                                     'debug' => 'true',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'mask' => '0x0',
                                     'number' => '0x7cb',
                                     'comment' => 'Cache diagnostics.'
                                   },
                       'pmpaddr8' => {
                                       'exists' => 'false'
                                     },
                       'mcountinhibit' => {
                                            'exists' => 'false'
                                          },
                       'mitcnt1' => {
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'number' => '0x7d5',
                                      'mask' => '0xffffffff'
                                    },
                       'pmpaddr13' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter4' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'meicurpl' => {
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt current priority level.',
                                       'number' => '0xbcc'
                                     },
                       'pmpaddr12' => {
                                        'exists' => 'false'
                                      },
                       'mfdc' => {
                                   'number' => '0x7f9',
                                   'mask' => '0x000727ff',
                                   'reset' => '0x00070040',
                                   'exists' => 'true'
                                 },
                       'meicpct' => {
                                      'mask' => '0x0',
                                      'number' => '0xbca',
                                      'comment' => 'External claim id/priority capture.',
                                      'exists' => 'true',
                                      'reset' => '0x0'
                                    },
                       'tselect' => {
                                      'exists' => 'true',
                                      'reset' => '0x0',
                                      'mask' => '0x3'
                                    },
                       'pmpaddr6' => {
                                       'exists' => 'false'
                                     },
                       'mitctl1' => {
                                      'mask' => '0x00000007',
                                      'number' => '0x7d7',
                                      'exists' => 'true',
                                      'reset' => '0x1'
                                    },
                       'mcpc' => {
                                   'mask' => '0x0',
                                   'number' => '0x7c2',
                                   'exists' => 'true',
                                   'reset' => '0x0'
                                 },
                       'mcgc' => {
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'number' => '0x7f8',
                                   'poke_mask' => '0x000001ff',
                                   'mask' => '0x000001ff'
                                 },
                       'mdccmect' => {
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'mask' => '0xffffffff',
                                       'number' => '0x7f2'
                                     },
                       'pmpaddr2' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr4' => {
                                       'exists' => 'false'
                                     }
                     },
            'target' => 'default',
            'nmi_vec' => '0x1111111100000000',
            'core' => {
                        'fpga_optimize' => 1,
                        'lsu_num_nbload_width' => '3',
                        'lsu_stbuf_depth' => '8',
                        'lsu_num_nbload' => '8',
                        'dec_instbuf_depth' => '4',
                        'dma_buf_depth' => '4'
                      },
            'pic' => {
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_meie_mask' => '0x1',
                       'pic_meipt_offset' => '0x3004',
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_mpiccfg_count' => 1,
                       'pic_total_int' => 8,
                       'pic_meipt_count' => 8,
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_region' => '0x0',
                       'pic_meipt_mask' => '0x0',
                       'pic_total_int_plus1' => 9,
                       'pic_bits' => 15,
                       'pic_meip_count' => 4,
                       'pic_meie_offset' => '0x2000',
                       'pic_meie_count' => 8,
                       'pic_int_words' => 1,
                       'pic_meip_offset' => '0x1000',
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_offset' => '0x700c0000',
                       'pic_meigwctrl_count' => 8,
                       'pic_meipl_mask' => '0xf',
                       'pic_size' => 32,
                       'pic_base_addr' => '0x700c0000',
                       'pic_meipl_offset' => '0x0000',
                       'pic_meigwclr_count' => 8,
                       'pic_meipl_count' => 8,
                       'pic_meigwclr_mask' => '0x0',
                       'pic_meip_mask' => '0x0'
                     },
            'harts' => 1,
            'bht' => {
                       'bht_array_depth' => 16,
                       'bht_addr_hi' => 7,
                       'bht_hash_string' => '{ghr[3:2] ^ {ghr[3+1], {4-1-2{1\'b0} } },hashin[5:4]^ghr[2-1:0]}',
                       'bht_ghr_pad' => 'fghr[4],3\'b0',
                       'bht_ghr_size' => 5,
                       'bht_ghr_pad2' => 'fghr[4:3],2\'b0',
                       'bht_size' => 128,
                       'bht_addr_lo' => '4',
                       'bht_ghr_range' => '4:0'
                     },
            'xlen' => 64,
            'testbench' => {
                             'build_axi4' => '1',
                             'ext_datawidth' => '64',
                             'TOP' => 'tb_top',
                             'lderr_rollback' => '1',
                             'assert_on' => '',
                             'sterr_rollback' => '0',
                             'datawidth' => '64',
                             'CPU_TOP' => '`RV_TOP.swerv',
                             'ext_addrwidth' => '64',
                             'clock_period' => '100',
                             'RV_TOP' => '`TOP.rvtop',
                             'SDVT_AHB' => '1'
                           },
            'triggers' => [
                            {
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ]
                            },
                            {
                              'poke_mask' => [
                                               '0x081810c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081810c7',
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
                              'poke_mask' => [
                                               '0x081810c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ]
                            }
                          ],
            'num_mmode_perf_regs' => '4',
            'btb' => {
                       'btb_index2_lo' => 6,
                       'btb_addr_lo' => '4',
                       'btb_index1_lo' => '4',
                       'btb_size' => 32,
                       'btb_index3_lo' => 8,
                       'btb_addr_hi' => 5,
                       'btb_array_depth' => 4,
                       'btb_index1_hi' => 5,
                       'btb_index2_hi' => 7,
                       'btb_btag_size' => 9,
                       'btb_btag_fold' => 1,
                       'btb_index3_hi' => 9
                     },
            'iccm' => {
                        'iccm_enable' => 1,
                        'iccm_size' => 512,
                        'iccm_reserved' => '0x1000',
                        'iccm_data_cell' => 'ram_16384x39',
                        'iccm_rows' => '16384',
                        'iccm_bank_bits' => 3,
                        'iccm_size_512' => '',
                        'iccm_sadr' => '0x6e000000',
                        'iccm_region' => '0x0',
                        'iccm_index_bits' => 14,
                        'iccm_eadr' => '0x6e07ffff',
                        'iccm_bits' => 19,
                        'iccm_num_banks_8' => '',
                        'iccm_num_banks' => '8',
                        'iccm_offset' => '0x6e000000'
                      },
            'verilator' => '',
            'reset_vec' => '0x0000000000000000',
            'retstack' => {
                            'ret_stack_size' => '4'
                          },
            'dccm' => {
                        'dccm_size' => 64,
                        'dccm_enable' => '1',
                        'dccm_bank_bits' => 3,
                        'dccm_rows' => '1024',
                        'dccm_data_cell' => 'ram_1024x72',
                        'dccm_reserved' => '0x1000',
                        'lsu_sb_bits' => 16,
                        'dccm_size_64' => '',
                        'dccm_num_banks_8' => '',
                        'dccm_data_width' => 64,
                        'dccm_bits' => 16,
                        'dccm_offset' => '0x70040000',
                        'dccm_fdata_width' => 72,
                        'dccm_num_banks' => '8',
                        'dccm_width_bits' => 3,
                        'dccm_index_bits' => 10,
                        'dccm_region' => '0x0',
                        'dccm_byte_width' => '8',
                        'dccm_sadr' => '0x70040000',
                        'dccm_eadr' => '0x7004ffff',
                        'dccm_ecc_width' => 8
                      },
            'physical' => '1'
          );
1;

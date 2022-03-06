#  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#  This is an automatically generated file by chisel on Wed Feb 23 22:07:35 CST 2022
# 
#  cmd:    swerv -target=high_perf -set iccm_enable 
# 
# To use this in a perf script, use 'require $RV64_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'nmi_vec' => '0x1111111100000000',
            'iccm' => {
                        'iccm_data_cell' => 'ram_16384x39',
                        'iccm_bank_bits' => 3,
                        'iccm_size' => 512,
                        'iccm_bits' => 19,
                        'iccm_size_512' => '',
                        'iccm_eadr' => '0x6e07ffff',
                        'iccm_offset' => '0x6e000000',
                        'iccm_num_banks' => '8',
                        'iccm_index_bits' => 14,
                        'iccm_reserved' => '0x1000',
                        'iccm_enable' => 1,
                        'iccm_region' => '0x0',
                        'iccm_num_banks_8' => '',
                        'iccm_rows' => '16384',
                        'iccm_sadr' => '0x6e000000'
                      },
            'dccm' => {
                        'dccm_sadr' => '0x70040000',
                        'dccm_index_bits' => 10,
                        'dccm_reserved' => '0x1000',
                        'dccm_eadr' => '0x7004ffff',
                        'dccm_enable' => '1',
                        'dccm_data_cell' => 'ram_1024x72',
                        'dccm_size_64' => '',
                        'dccm_rows' => '1024',
                        'dccm_data_width' => 64,
                        'dccm_bank_bits' => 3,
                        'dccm_ecc_width' => 8,
                        'lsu_sb_bits' => 16,
                        'dccm_fdata_width' => 72,
                        'dccm_size' => 64,
                        'dccm_region' => '0x0',
                        'dccm_num_banks_8' => '',
                        'dccm_offset' => '0x70040000',
                        'dccm_width_bits' => 3,
                        'dccm_bits' => 16,
                        'dccm_num_banks' => '8',
                        'dccm_byte_width' => '8'
                      },
            'physical' => '1',
            'memmap' => {
                          'external_data_1' => '0xc000000000000000',
                          'unused_region10' => '0xa000000000000000',
                          'unused_region11' => '0xb000000000000000',
                          'unused_region4' => '0x4000000000000000',
                          'serialio' => '0xf000000000580000',
                          'unused_region1' => '0x1000000000000000',
                          'unused_region5' => '0x5000000000000000',
                          'unused_region2' => '0x2000000000000000',
                          'unused_region6' => '0x6000000000000000',
                          'unused_region8' => '0x8000000000000000',
                          'consoleio' => '0xf000000000580000',
                          'unused_region3' => '0x3000000000000000',
                          'unused_region7' => '0x7000000000000000',
                          'external_data' => '0xe000000000580000',
                          'unused_region9' => '0x9000000000000000',
                          'external_prog' => '0xd000000000000000',
                          'debug_sb_mem' => '0xd000000000580000'
                        },
            'target' => 'high_perf',
            'xlen' => 64,
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
                            }
                          ],
            'testbench' => {
                             'lderr_rollback' => '1',
                             'TOP' => 'tb_top',
                             'ext_addrwidth' => '64',
                             'assert_on' => '',
                             'ext_datawidth' => '64',
                             'SDVT_AHB' => '1',
                             'build_axi4' => '1',
                             'sterr_rollback' => '0',
                             'clock_period' => '100',
                             'datawidth' => '64',
                             'CPU_TOP' => '`RV_TOP.swerv',
                             'RV_TOP' => '`TOP.rvtop'
                           },
            'retstack' => {
                            'ret_stack_size' => '4'
                          },
            'max_mmode_perf_event' => '50',
            'reset_vec' => '0x0000000000000000',
            'protection' => {
                              'inst_access_enable7' => '0x1',
                              'inst_access_addr1' => '0x2000000000000000',
                              'inst_access_addr3' => '0x6000000000000000',
                              'inst_access_addr5' => '0xa000000000000000',
                              'data_access_mask3' => '0x2fffffffffffffff',
                              'data_access_addr7' => '0xe000000000000000',
                              'inst_access_addr4' => '0x8000000000000000',
                              'data_access_mask7' => '0x1fffffffffffffff',
                              'inst_access_addr7' => '0xe000000000000000',
                              'data_access_addr0' => '0x0000000000000000',
                              'data_access_enable3' => '0x1',
                              'inst_access_enable4' => '0x0',
                              'inst_access_mask6' => '0x1fffffffffffffff',
                              'data_access_addr1' => '0x2000000000000000',
                              'inst_access_addr0' => '0x0000000000000000',
                              'inst_access_addr6' => '0xc000000000000000',
                              'data_access_enable0' => '0x1',
                              'inst_access_mask7' => '0x1fffffffffffffff',
                              'inst_access_addr2' => '0x4000000000000000',
                              'data_access_mask4' => '0x1fffffffffffffff',
                              'data_access_mask6' => '0x1fffffffffffffff',
                              'data_access_mask1' => '0x1fffffffffffffff',
                              'data_access_enable2' => '0x1',
                              'data_access_mask2' => '0x1fffffffffffffff',
                              'inst_access_enable1' => '0x1',
                              'inst_access_enable6' => '0x1',
                              'data_access_enable6' => '0x1',
                              'data_access_enable1' => '0x1',
                              'data_access_addr2' => '0x4000000000000000',
                              'inst_access_mask0' => '0x1fffffffffffffff',
                              'data_access_addr6' => '0xc000000000000000',
                              'data_access_enable7' => '0x1',
                              'data_access_addr5' => '0xa000000000000000',
                              'data_access_addr4' => '0x8000000000000000',
                              'data_access_enable4' => '0x0',
                              'data_access_mask5' => '0x1fffffffffffffff',
                              'inst_access_mask2' => '0x1fffffffffffffff',
                              'inst_access_enable2' => '0x1',
                              'inst_access_enable3' => '0x1',
                              'inst_access_mask5' => '0x1fffffffffffffff',
                              'inst_access_mask4' => '0x1fffffffffffffff',
                              'inst_access_enable0' => '0x1',
                              'inst_access_enable5' => '0x1',
                              'inst_access_mask1' => '0x1fffffffffffffff',
                              'data_access_mask0' => '0x1fffffffffffffff',
                              'data_access_addr3' => '0x6000000000000000',
                              'inst_access_mask3' => '0x1fffffffffffffff',
                              'data_access_enable5' => '0x1'
                            },
            'bht' => {
                       'bht_hash_string' => '{ghr[7:6] ^ {ghr[7+1], {8-1-6{1\'b0} } },hashin[9:4]^ghr[6-1:0]}',
                       'bht_size' => 2048,
                       'bht_ghr_pad2' => 'fghr[8:3],2\'b0',
                       'bht_array_depth' => 256,
                       'bht_ghr_pad' => 'fghr[8:4],3\'b0',
                       'bht_addr_hi' => 11,
                       'bht_ghr_range' => '8:0',
                       'bht_addr_lo' => '4',
                       'bht_ghr_size' => 9
                     },
            'harts' => 1,
            'icache' => {
                          'icache_taddr_high' => 6,
                          'icache_tag_high' => 13,
                          'icache_tag_depth' => 128,
                          'icache_enable' => '1',
                          'icache_ic_index' => 9,
                          'icache_tag_low' => '6',
                          'icache_data_cell' => 'ram_512x34',
                          'icache_tag_cell' => 'ram_128x53',
                          'icache_size' => 32,
                          'icache_ic_depth' => 9,
                          'icache_ic_rows' => '512'
                        },
            'csr' => {
                       'pmpaddr12' => {
                                        'exists' => 'false'
                                      },
                       'pmpaddr6' => {
                                       'exists' => 'false'
                                     },
                       'mcountinhibit' => {
                                            'exists' => 'false'
                                          },
                       'mstatus' => {
                                      'mask' => '0x88',
                                      'reset' => '0x1800',
                                      'exists' => 'true'
                                    },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'meicidpl' => {
                                       'number' => '0xbcb',
                                       'exists' => 'true',
                                       'comment' => 'External interrupt claim id priority level.',
                                       'mask' => '0xf',
                                       'reset' => '0x0'
                                     },
                       'mip' => {
                                  'poke_mask' => '0x70000888',
                                  'mask' => '0x0',
                                  'reset' => '0x0',
                                  'exists' => 'true'
                                },
                       'mhpmcounter5' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'pmpcfg3' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr11' => {
                                        'exists' => 'false'
                                      },
                       'meicurpl' => {
                                       'mask' => '0xf',
                                       'reset' => '0x0',
                                       'number' => '0xbcc',
                                       'comment' => 'External interrupt current priority level.',
                                       'exists' => 'true'
                                     },
                       'mhpmevent4' => {
                                         'exists' => 'true',
                                         'mask' => '0xffffffff',
                                         'reset' => '0x0'
                                       },
                       'mitcnt1' => {
                                      'number' => '0x7d5',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'reset' => '0x0'
                                    },
                       'meicpct' => {
                                      'reset' => '0x0',
                                      'mask' => '0x0',
                                      'comment' => 'External claim id/priority capture.',
                                      'exists' => 'true',
                                      'number' => '0xbca'
                                    },
                       'dicago' => {
                                     'mask' => '0x0',
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'number' => '0x7cb',
                                     'comment' => 'Cache diagnostics.',
                                     'exists' => 'true'
                                   },
                       'dicad0' => {
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'mask' => '0xffffffff',
                                     'comment' => 'Cache diagnostics.',
                                     'exists' => 'true',
                                     'number' => '0x7c9'
                                   },
                       'mhpmcounter6h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'mitctl0' => {
                                      'reset' => '0x1',
                                      'mask' => '0x00000007',
                                      'exists' => 'true',
                                      'number' => '0x7d4'
                                    },
                       'miccmect' => {
                                       'mask' => '0xffffffff',
                                       'reset' => '0x0',
                                       'number' => '0x7f1',
                                       'exists' => 'true'
                                     },
                       'mimpid' => {
                                     'exists' => 'true',
                                     'reset' => '0x6',
                                     'mask' => '0x0'
                                   },
                       'mitctl1' => {
                                      'mask' => '0x00000007',
                                      'reset' => '0x1',
                                      'number' => '0x7d7',
                                      'exists' => 'true'
                                    },
                       'mvendorid' => {
                                        'exists' => 'true',
                                        'mask' => '0x0',
                                        'reset' => '0x45'
                                      },
                       'marchid' => {
                                      'exists' => 'true',
                                      'mask' => '0x0',
                                      'reset' => '0x0000000b'
                                    },
                       'pmpaddr2' => {
                                       'exists' => 'false'
                                     },
                       'tselect' => {
                                      'reset' => '0x0',
                                      'mask' => '0x3',
                                      'exists' => 'true'
                                    },
                       'pmpaddr3' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr10' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter3h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'pmpaddr4' => {
                                       'exists' => 'false'
                                     },
                       'mhpmcounter4' => {
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0',
                                           'exists' => 'true'
                                         },
                       'dicad1' => {
                                     'number' => '0x7ca',
                                     'exists' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'mask' => '0x3',
                                     'debug' => 'true',
                                     'reset' => '0x0'
                                   },
                       'pmpaddr14' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter6' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'mcgc' => {
                                   'exists' => 'true',
                                   'number' => '0x7f8',
                                   'reset' => '0x0',
                                   'mask' => '0x000001ff',
                                   'poke_mask' => '0x000001ff'
                                 },
                       'mdccmect' => {
                                       'reset' => '0x0',
                                       'mask' => '0xffffffff',
                                       'exists' => 'true',
                                       'number' => '0x7f2'
                                     },
                       'mitbnd1' => {
                                      'reset' => '0xffffffff',
                                      'mask' => '0xffffffff',
                                      'exists' => 'true',
                                      'number' => '0x7d6'
                                    },
                       'pmpaddr15' => {
                                        'exists' => 'false'
                                      },
                       'micect' => {
                                     'mask' => '0xffffffff',
                                     'reset' => '0x0',
                                     'number' => '0x7f0',
                                     'exists' => 'true'
                                   },
                       'mitbnd0' => {
                                      'number' => '0x7d3',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'reset' => '0xffffffff'
                                    },
                       'mfdc' => {
                                   'number' => '0x7f9',
                                   'exists' => 'true',
                                   'mask' => '0x000727ff',
                                   'reset' => '0x00070040'
                                 },
                       'dcsr' => {
                                   'exists' => 'true',
                                   'poke_mask' => '0x00008dcc',
                                   'mask' => '0x00008c04',
                                   'reset' => '0x40000003'
                                 },
                       'dmst' => {
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'exists' => 'true',
                                   'number' => '0x7c4',
                                   'debug' => 'true',
                                   'reset' => '0x0',
                                   'mask' => '0x0'
                                 },
                       'mhpmevent6' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'meipt' => {
                                    'reset' => '0x0',
                                    'mask' => '0xf',
                                    'exists' => 'true',
                                    'comment' => 'External interrupt priority threshold.',
                                    'number' => '0xbc9'
                                  },
                       'pmpaddr0' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr8' => {
                                       'exists' => 'false'
                                     },
                       'pmpcfg1' => {
                                      'exists' => 'false'
                                    },
                       'mpmc' => {
                                   'poke_mask' => '0x2',
                                   'mask' => '0x2',
                                   'reset' => '0x2',
                                   'number' => '0x7c6',
                                   'exists' => 'true',
                                   'comment' => 'FWHALT'
                                 },
                       'pmpaddr5' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent5' => {
                                         'exists' => 'true',
                                         'mask' => '0xffffffff',
                                         'reset' => '0x0'
                                       },
                       'mitcnt0' => {
                                      'exists' => 'true',
                                      'number' => '0x7d2',
                                      'reset' => '0x0',
                                      'mask' => '0xffffffff'
                                    },
                       'mhpmevent3' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'dicawics' => {
                                       'debug' => 'true',
                                       'reset' => '0x0',
                                       'mask' => '0x0130fffc',
                                       'exists' => 'true',
                                       'comment' => 'Cache diagnostics.',
                                       'number' => '0x7c8'
                                     },
                       'mhpmcounter4h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'pmpcfg2' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr13' => {
                                        'exists' => 'false'
                                      },
                       'mie' => {
                                  'exists' => 'true',
                                  'reset' => '0x0',
                                  'mask' => '0x70000888'
                                },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr9' => {
                                       'exists' => 'false'
                                     },
                       'mhpmcounter3' => {
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0',
                                           'exists' => 'true'
                                         },
                       'misa' => {
                                   'mask' => '0x0',
                                   'reset' => '0x40001104',
                                   'exists' => 'true'
                                 },
                       'mcpc' => {
                                   'mask' => '0x0',
                                   'reset' => '0x0',
                                   'number' => '0x7c2',
                                   'exists' => 'true'
                                 },
                       'pmpcfg0' => {
                                      'exists' => 'false'
                                    },
                       'mgpmc' => {
                                    'reset' => '0x1',
                                    'mask' => '0x1',
                                    'exists' => 'true',
                                    'number' => '0x7d0'
                                  },
                       'pmpaddr1' => {
                                       'exists' => 'false'
                                     },
                       'mhpmcounter5h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'pmpaddr7' => {
                                       'exists' => 'false'
                                     },
                       'time' => {
                                   'exists' => 'false'
                                 }
                     },
            'verilator' => '',
            'btb' => {
                       'btb_addr_lo' => '4',
                       'btb_index2_lo' => 10,
                       'btb_size' => 512,
                       'btb_index2_hi' => 15,
                       'btb_index1_hi' => 9,
                       'btb_index3_lo' => 16,
                       'btb_index1_lo' => '4',
                       'btb_array_depth' => 64,
                       'btb_addr_hi' => 9,
                       'btb_index3_hi' => 21,
                       'btb_btag_size' => 5
                     },
            'core' => {
                        'dma_buf_depth' => '4',
                        'dec_instbuf_depth' => '4',
                        'fpga_optimize' => 1,
                        'lsu_num_nbload_width' => '3',
                        'lsu_num_nbload' => '8',
                        'lsu_stbuf_depth' => '8'
                      },
            'even_odd_trigger_chains' => 'true',
            'num_mmode_perf_regs' => '4',
            'pic' => {
                       'pic_meipl_count' => 8,
                       'pic_meipl_mask' => '0xf',
                       'pic_meip_offset' => '0x1000',
                       'pic_meigwctrl_count' => 8,
                       'pic_meigwclr_count' => 8,
                       'pic_base_addr' => '0x700c0000',
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meie_mask' => '0x1',
                       'pic_meie_count' => 8,
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meie_offset' => '0x2000',
                       'pic_total_int' => 8,
                       'pic_meip_count' => 4,
                       'pic_meipl_offset' => '0x0000',
                       'pic_meipt_offset' => '0x3004',
                       'pic_int_words' => 1,
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_region' => '0x0',
                       'pic_meip_mask' => '0x0',
                       'pic_offset' => '0x700c0000',
                       'pic_bits' => 15,
                       'pic_meigwclr_mask' => '0x0',
                       'pic_total_int_plus1' => 9,
                       'pic_meipt_mask' => '0x0',
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_size' => 32,
                       'pic_meipt_count' => 8,
                       'pic_mpiccfg_count' => 1
                     },
            'bus' => {
                       'dma_bus_tag' => '1',
                       'sb_bus_tag' => '1',
                       'lsu_bus_tag' => 4,
                       'ifu_bus_tag' => '3'
                     },
            'numiregs' => '32',
            'regwidth' => '64',
            'tec_rv_icg' => 'clockhdr'
          );
1;

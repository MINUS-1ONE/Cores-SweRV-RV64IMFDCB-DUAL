#  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#  This is an automatically generated file by riscv on Fri 01 Apr 2022 11:01:24 PM PDT
# 
#  cmd:    swerv -target=default -set iccm_enable 
# 
# To use this in a perf script, use 'require $RV64_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'iccm' => {
                        'iccm_eadr' => '0x6e07ffff',
                        'iccm_size' => 512,
                        'iccm_size_512' => '',
                        'iccm_offset' => '0x6e000000',
                        'iccm_region' => '0x0',
                        'iccm_bits' => 19,
                        'iccm_num_banks_8' => '',
                        'iccm_data_cell' => 'ram_16384x39',
                        'iccm_rows' => '16384',
                        'iccm_index_bits' => 14,
                        'iccm_bank_bits' => 3,
                        'iccm_num_banks' => '8',
                        'iccm_enable' => 1,
                        'iccm_sadr' => '0x6e000000',
                        'iccm_reserved' => '0x1000'
                      },
            'retstack' => {
                            'ret_stack_size' => '4'
                          },
            'max_mmode_perf_event' => '50',
            'bht' => {
                       'bht_addr_lo' => '4',
                       'bht_array_depth' => 16,
                       'bht_ghr_pad' => 'fghr[4],3\'b0',
                       'bht_ghr_pad2' => 'fghr[4:3],2\'b0',
                       'bht_ghr_range' => '4:0',
                       'bht_hash_string' => '{ghr[3:2] ^ {ghr[3+1], {4-1-2{1\'b0} } },hashin[5:4]^ghr[2-1:0]}',
                       'bht_ghr_size' => 5,
                       'bht_size' => 128,
                       'bht_addr_hi' => 7
                     },
            'pic' => {
                       'pic_region' => '0x0',
                       'pic_meigwclr_mask' => '0x0',
                       'pic_size' => 32,
                       'pic_offset' => '0x700c0000',
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meipl_offset' => '0x0000',
                       'pic_total_int' => 8,
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_meipt_count' => 8,
                       'pic_meip_offset' => '0x1000',
                       'pic_bits' => 15,
                       'pic_meipl_mask' => '0xf',
                       'pic_meie_mask' => '0x1',
                       'pic_int_words' => 1,
                       'pic_total_int_plus1' => 9,
                       'pic_meigwctrl_count' => 8,
                       'pic_meigwclr_count' => 8,
                       'pic_meie_count' => 8,
                       'pic_mpiccfg_count' => 1,
                       'pic_meipl_count' => 8,
                       'pic_meipt_offset' => '0x3004',
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_meip_count' => 4,
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meie_offset' => '0x2000',
                       'pic_base_addr' => '0x700c0000',
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_meipt_mask' => '0x0',
                       'pic_meip_mask' => '0x0'
                     },
            'numiregs' => '32',
            'core' => {
                        'fpga_optimize' => 1,
                        'lsu_num_nbload_width' => '3',
                        'lsu_num_nbload' => '8',
                        'dma_buf_depth' => '4',
                        'dec_instbuf_depth' => '4',
                        'lsu_stbuf_depth' => '8'
                      },
            'nmi_vec' => '0x1111111100000000',
            'protection' => {
                              'inst_access_enable4' => '0x0',
                              'inst_access_enable3' => '0x1',
                              'inst_access_enable7' => '0x1',
                              'inst_access_addr1' => '0x2000000000000000',
                              'data_access_mask3' => '0x2fffffffffffffff',
                              'inst_access_enable5' => '0x1',
                              'inst_access_enable0' => '0x1',
                              'data_access_addr3' => '0x6000000000000000',
                              'inst_access_mask1' => '0x1fffffffffffffff',
                              'data_access_addr2' => '0x4000000000000000',
                              'inst_access_mask0' => '0x1fffffffffffffff',
                              'inst_access_addr7' => '0xe000000000000000',
                              'data_access_mask6' => '0x1fffffffffffffff',
                              'inst_access_mask4' => '0x1fffffffffffffff',
                              'data_access_enable1' => '0x1',
                              'inst_access_addr5' => '0xa000000000000000',
                              'inst_access_addr0' => '0x0000000000000000',
                              'data_access_mask2' => '0x1fffffffffffffff',
                              'data_access_enable2' => '0x1',
                              'data_access_enable6' => '0x1',
                              'inst_access_mask7' => '0x1fffffffffffffff',
                              'data_access_addr6' => '0xc000000000000000',
                              'inst_access_addr4' => '0x8000000000000000',
                              'inst_access_mask5' => '0x1fffffffffffffff',
                              'data_access_addr7' => '0xe000000000000000',
                              'data_access_mask0' => '0x1fffffffffffffff',
                              'inst_access_addr2' => '0x4000000000000000',
                              'data_access_addr5' => '0xa000000000000000',
                              'data_access_mask4' => '0x1fffffffffffffff',
                              'inst_access_enable1' => '0x1',
                              'inst_access_mask6' => '0x1fffffffffffffff',
                              'data_access_mask7' => '0x1fffffffffffffff',
                              'inst_access_enable6' => '0x1',
                              'inst_access_mask2' => '0x1fffffffffffffff',
                              'data_access_addr0' => '0x0000000000000000',
                              'inst_access_enable2' => '0x1',
                              'data_access_mask5' => '0x1fffffffffffffff',
                              'data_access_addr4' => '0x8000000000000000',
                              'inst_access_addr6' => '0xc000000000000000',
                              'data_access_enable4' => '0x0',
                              'data_access_enable3' => '0x1',
                              'data_access_enable7' => '0x1',
                              'data_access_addr1' => '0x2000000000000000',
                              'inst_access_mask3' => '0x1fffffffffffffff',
                              'data_access_enable0' => '0x1',
                              'data_access_enable5' => '0x1',
                              'inst_access_addr3' => '0x6000000000000000',
                              'data_access_mask1' => '0x1fffffffffffffff'
                            },
            'dccm' => {
                        'dccm_num_banks_8' => '',
                        'dccm_bits' => 16,
                        'dccm_byte_width' => '8',
                        'dccm_data_width' => 64,
                        'dccm_data_cell' => 'ram_1024x72',
                        'dccm_rows' => '1024',
                        'dccm_ecc_width' => 8,
                        'dccm_eadr' => '0x7004ffff',
                        'dccm_size' => 64,
                        'dccm_offset' => '0x70040000',
                        'dccm_fdata_width' => 72,
                        'dccm_region' => '0x0',
                        'dccm_enable' => '1',
                        'lsu_sb_bits' => 16,
                        'dccm_reserved' => '0x1000',
                        'dccm_sadr' => '0x70040000',
                        'dccm_width_bits' => 3,
                        'dccm_bank_bits' => 3,
                        'dccm_index_bits' => 10,
                        'dccm_num_banks' => '8',
                        'dccm_size_64' => ''
                      },
            'testbench' => {
                             'lderr_rollback' => '1',
                             'assert_on' => '',
                             'ext_addrwidth' => '64',
                             'clock_period' => '100',
                             'TOP' => 'tb_top',
                             'CPU_TOP' => '`RV_TOP.swerv',
                             'RV_TOP' => '`TOP.rvtop',
                             'datawidth' => '64',
                             'build_axi4' => '1',
                             'sterr_rollback' => '0',
                             'SDVT_AHB' => '1',
                             'ext_datawidth' => '64'
                           },
            'regwidth' => '64',
            'btb' => {
                       'btb_index2_lo' => 6,
                       'btb_addr_lo' => '4',
                       'btb_btag_fold' => 1,
                       'btb_array_depth' => 4,
                       'btb_addr_hi' => 5,
                       'btb_index1_hi' => 5,
                       'btb_size' => 32,
                       'btb_index3_lo' => 8,
                       'btb_index2_hi' => 7,
                       'btb_index1_lo' => '4',
                       'btb_index3_hi' => 9,
                       'btb_btag_size' => 9
                     },
            'even_odd_trigger_chains' => 'true',
            'physical' => '1',
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
            'verilator' => '',
            'csr' => {
                       'mhpmevent3' => {
                                         'exists' => 'true',
                                         'mask' => '0xffffffff',
                                         'reset' => '0x0'
                                       },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'pmpaddr15' => {
                                        'exists' => 'false'
                                      },
                       'mcpc' => {
                                   'exists' => 'true',
                                   'mask' => '0x0',
                                   'reset' => '0x0',
                                   'number' => '0x7c2'
                                 },
                       'micect' => {
                                     'reset' => '0x0',
                                     'number' => '0x7f0',
                                     'exists' => 'true',
                                     'mask' => '0xffffffff'
                                   },
                       'mhpmcounter4' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'pmpaddr0' => {
                                       'exists' => 'false'
                                     },
                       'dicago' => {
                                     'mask' => '0x0',
                                     'comment' => 'Cache diagnostics.',
                                     'number' => '0x7cb',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'debug' => 'true'
                                   },
                       'mhpmcounter3h' => {
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0xffffffff'
                                          },
                       'mhpmcounter5' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'meicurpl' => {
                                       'mask' => '0xf',
                                       'exists' => 'true',
                                       'number' => '0xbcc',
                                       'comment' => 'External interrupt current priority level.',
                                       'reset' => '0x0'
                                     },
                       'pmpaddr4' => {
                                       'exists' => 'false'
                                     },
                       'pmpcfg0' => {
                                      'exists' => 'false'
                                    },
                       'dicawics' => {
                                       'comment' => 'Cache diagnostics.',
                                       'number' => '0x7c8',
                                       'mask' => '0x0130fffc',
                                       'reset' => '0x0',
                                       'debug' => 'true',
                                       'exists' => 'true'
                                     },
                       'mcgc' => {
                                   'exists' => 'true',
                                   'poke_mask' => '0x000001ff',
                                   'mask' => '0x000001ff',
                                   'reset' => '0x0',
                                   'number' => '0x7f8'
                                 },
                       'pmpaddr3' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr2' => {
                                       'exists' => 'false'
                                     },
                       'marchid' => {
                                      'exists' => 'true',
                                      'mask' => '0x0',
                                      'reset' => '0x0000000b'
                                    },
                       'pmpcfg1' => {
                                      'exists' => 'false'
                                    },
                       'meicpct' => {
                                      'exists' => 'true',
                                      'mask' => '0x0',
                                      'comment' => 'External claim id/priority capture.',
                                      'reset' => '0x0',
                                      'number' => '0xbca'
                                    },
                       'pmpaddr5' => {
                                       'exists' => 'false'
                                     },
                       'misa' => {
                                   'reset' => '0x40001104',
                                   'mask' => '0x0',
                                   'exists' => 'true'
                                 },
                       'mhpmcounter5h' => {
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0xffffffff'
                                          },
                       'mhpmcounter3' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'pmpaddr7' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent6' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'pmpaddr13' => {
                                        'exists' => 'false'
                                      },
                       'mgpmc' => {
                                    'reset' => '0x1',
                                    'number' => '0x7d0',
                                    'exists' => 'true',
                                    'mask' => '0x1'
                                  },
                       'mhpmcounter4h' => {
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff',
                                            'exists' => 'true'
                                          },
                       'pmpaddr1' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr12' => {
                                        'exists' => 'false'
                                      },
                       'mhpmevent4' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'mstatus' => {
                                      'mask' => '0x88',
                                      'exists' => 'true',
                                      'reset' => '0x1800'
                                    },
                       'mpmc' => {
                                   'exists' => 'true',
                                   'poke_mask' => '0x2',
                                   'reset' => '0x2',
                                   'mask' => '0x2',
                                   'comment' => 'FWHALT',
                                   'number' => '0x7c6'
                                 },
                       'pmpaddr10' => {
                                        'exists' => 'false'
                                      },
                       'mcountinhibit' => {
                                            'exists' => 'false'
                                          },
                       'meipt' => {
                                    'number' => '0xbc9',
                                    'reset' => '0x0',
                                    'comment' => 'External interrupt priority threshold.',
                                    'mask' => '0xf',
                                    'exists' => 'true'
                                  },
                       'mdccmect' => {
                                       'mask' => '0xffffffff',
                                       'exists' => 'true',
                                       'number' => '0x7f2',
                                       'reset' => '0x0'
                                     },
                       'dcsr' => {
                                   'reset' => '0x40000003',
                                   'poke_mask' => '0x00008dcc',
                                   'exists' => 'true',
                                   'mask' => '0x00008c04'
                                 },
                       'dicad0' => {
                                     'mask' => '0xffffffff',
                                     'comment' => 'Cache diagnostics.',
                                     'number' => '0x7c9',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'debug' => 'true'
                                   },
                       'mitbnd1' => {
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d6',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff'
                                    },
                       'pmpaddr6' => {
                                       'exists' => 'false'
                                     },
                       'mitbnd0' => {
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d3',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff'
                                    },
                       'miccmect' => {
                                       'reset' => '0x0',
                                       'number' => '0x7f1',
                                       'exists' => 'true',
                                       'mask' => '0xffffffff'
                                     },
                       'mitctl1' => {
                                      'exists' => 'true',
                                      'mask' => '0x00000007',
                                      'reset' => '0x1',
                                      'number' => '0x7d7'
                                    },
                       'pmpaddr8' => {
                                       'exists' => 'false'
                                     },
                       'dicad1' => {
                                     'debug' => 'true',
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'number' => '0x7ca',
                                     'comment' => 'Cache diagnostics.',
                                     'mask' => '0x3'
                                   },
                       'meicidpl' => {
                                       'exists' => 'true',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt claim id priority level.',
                                       'reset' => '0x0',
                                       'number' => '0xbcb'
                                     },
                       'mie' => {
                                  'mask' => '0x70000888',
                                  'exists' => 'true',
                                  'reset' => '0x0'
                                },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'pmpaddr9' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr11' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter6h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'mitctl0' => {
                                      'exists' => 'true',
                                      'mask' => '0x00000007',
                                      'reset' => '0x1',
                                      'number' => '0x7d4'
                                    },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr14' => {
                                        'exists' => 'false'
                                      },
                       'mitcnt1' => {
                                      'number' => '0x7d5',
                                      'reset' => '0x0',
                                      'mask' => '0xffffffff',
                                      'exists' => 'true'
                                    },
                       'mfdc' => {
                                   'exists' => 'true',
                                   'mask' => '0x000727ff',
                                   'reset' => '0x00070040',
                                   'number' => '0x7f9'
                                 },
                       'pmpcfg2' => {
                                      'exists' => 'false'
                                    },
                       'mhpmevent5' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'tselect' => {
                                      'exists' => 'true',
                                      'mask' => '0x3',
                                      'reset' => '0x0'
                                    },
                       'mvendorid' => {
                                        'mask' => '0x0',
                                        'exists' => 'true',
                                        'reset' => '0x45'
                                      },
                       'pmpcfg3' => {
                                      'exists' => 'false'
                                    },
                       'mitcnt0' => {
                                      'mask' => '0xffffffff',
                                      'exists' => 'true',
                                      'number' => '0x7d2',
                                      'reset' => '0x0'
                                    },
                       'mhpmcounter6' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'dmst' => {
                                   'number' => '0x7c4',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'mask' => '0x0',
                                   'debug' => 'true',
                                   'reset' => '0x0',
                                   'exists' => 'true'
                                 },
                       'mip' => {
                                  'exists' => 'true',
                                  'poke_mask' => '0x70000888',
                                  'mask' => '0x0',
                                  'reset' => '0x0'
                                },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'mimpid' => {
                                     'mask' => '0x0',
                                     'exists' => 'true',
                                     'reset' => '0x6'
                                   }
                     },
            'icache' => {
                          'icache_tag_high' => 12,
                          'icache_tag_cell' => 'ram_64x53',
                          'icache_size' => 16,
                          'icache_ic_depth' => 8,
                          'icache_ic_index' => 8,
                          'icache_tag_low' => '6',
                          'icache_data_cell' => 'ram_256x34',
                          'icache_taddr_high' => 5,
                          'icache_ic_rows' => '256',
                          'icache_tag_depth' => 64,
                          'icache_enable' => '1'
                        },
            'tec_rv_icg' => 'clockhdr',
            'num_mmode_perf_regs' => '4',
            'bus' => {
                       'ifu_bus_tag' => '3',
                       'lsu_bus_tag' => 4,
                       'dma_bus_tag' => '1',
                       'sb_bus_tag' => '1'
                     },
            'xlen' => 64,
            'memmap' => {
                          'consoleio' => '0xf000000000580000',
                          'unused_region7' => '0x7000000000000000',
                          'unused_region6' => '0x6000000000000000',
                          'serialio' => '0xf000000000580000',
                          'unused_region3' => '0x3000000000000000',
                          'unused_region2' => '0x2000000000000000',
                          'unused_region9' => '0x9000000000000000',
                          'debug_sb_mem' => '0xd000000000580000',
                          'external_data_1' => '0xc000000000000000',
                          'unused_region11' => '0xb000000000000000',
                          'external_prog' => '0xd000000000000000',
                          'unused_region10' => '0xa000000000000000',
                          'unused_region1' => '0x1000000000000000',
                          'unused_region8' => '0x8000000000000000',
                          'external_data' => '0xe000000000580000',
                          'unused_region5' => '0x5000000000000000',
                          'unused_region4' => '0x4000000000000000'
                        },
            'reset_vec' => '0x0000000000000000',
            'target' => 'default',
            'harts' => 1
          );
1;

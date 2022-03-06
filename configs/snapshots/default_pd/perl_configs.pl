#  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#  This is an automatically generated file by chisel on Wed Feb 23 22:06:41 CST 2022
# 
#  cmd:    swerv -target=default_pd -set iccm_enable 
# 
# To use this in a perf script, use 'require $RV64_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'harts' => 1,
            'bus' => {
                       'dma_bus_tag' => '1',
                       'ifu_bus_tag' => '3',
                       'lsu_bus_tag' => 4,
                       'sb_bus_tag' => '1'
                     },
            'xlen' => 64,
            'memmap' => {
                          'unused_region10' => '0xa000000000000000',
                          'unused_region1' => '0x1000000000000000',
                          'unused_region9' => '0x9000000000000000',
                          'unused_region4' => '0x4000000000000000',
                          'external_data' => '0xe000000000580000',
                          'unused_region11' => '0xb000000000000000',
                          'unused_region7' => '0x7000000000000000',
                          'consoleio' => '0xf000000000580000',
                          'unused_region5' => '0x5000000000000000',
                          'debug_sb_mem' => '0xd000000000580000',
                          'unused_region3' => '0x3000000000000000',
                          'external_data_1' => '0xc000000000000000',
                          'unused_region8' => '0x8000000000000000',
                          'unused_region2' => '0x2000000000000000',
                          'unused_region6' => '0x6000000000000000',
                          'external_prog' => '0xd000000000000000',
                          'serialio' => '0xf000000000580000'
                        },
            'retstack' => {
                            'ret_stack_size' => '4'
                          },
            'reset_vec' => '0x0000000000000000',
            'even_odd_trigger_chains' => 'true',
            'protection' => {
                              'inst_access_mask1' => '0x1fffffffffffffff',
                              'inst_access_addr5' => '0xa000000000000000',
                              'inst_access_addr0' => '0x0000000000000000',
                              'inst_access_addr3' => '0x6000000000000000',
                              'inst_access_enable2' => '0x1',
                              'data_access_enable5' => '0x1',
                              'inst_access_mask4' => '0x1fffffffffffffff',
                              'data_access_addr7' => '0xe000000000000000',
                              'data_access_mask6' => '0x1fffffffffffffff',
                              'data_access_enable3' => '0x1',
                              'inst_access_enable3' => '0x1',
                              'inst_access_enable6' => '0x1',
                              'inst_access_mask6' => '0x1fffffffffffffff',
                              'data_access_addr0' => '0x0000000000000000',
                              'data_access_enable7' => '0x1',
                              'inst_access_enable1' => '0x1',
                              'data_access_mask4' => '0x1fffffffffffffff',
                              'inst_access_mask2' => '0x1fffffffffffffff',
                              'inst_access_mask3' => '0x1fffffffffffffff',
                              'data_access_addr1' => '0x2000000000000000',
                              'inst_access_addr1' => '0x2000000000000000',
                              'inst_access_mask5' => '0x1fffffffffffffff',
                              'data_access_addr6' => '0xc000000000000000',
                              'data_access_mask7' => '0x1fffffffffffffff',
                              'data_access_addr5' => '0xa000000000000000',
                              'data_access_enable1' => '0x1',
                              'inst_access_enable4' => '0x0',
                              'data_access_addr4' => '0x8000000000000000',
                              'data_access_addr3' => '0x6000000000000000',
                              'inst_access_addr7' => '0xe000000000000000',
                              'data_access_mask0' => '0x1fffffffffffffff',
                              'data_access_enable2' => '0x1',
                              'data_access_mask3' => '0x2fffffffffffffff',
                              'data_access_enable0' => '0x1',
                              'inst_access_enable0' => '0x1',
                              'data_access_mask1' => '0x1fffffffffffffff',
                              'inst_access_addr2' => '0x4000000000000000',
                              'data_access_mask5' => '0x1fffffffffffffff',
                              'inst_access_enable7' => '0x1',
                              'inst_access_addr4' => '0x8000000000000000',
                              'inst_access_mask0' => '0x1fffffffffffffff',
                              'inst_access_mask7' => '0x1fffffffffffffff',
                              'inst_access_enable5' => '0x1',
                              'data_access_addr2' => '0x4000000000000000',
                              'data_access_enable6' => '0x1',
                              'inst_access_addr6' => '0xc000000000000000',
                              'data_access_enable4' => '0x0',
                              'data_access_mask2' => '0x1fffffffffffffff'
                            },
            'max_mmode_perf_event' => '50',
            'triggers' => [
                            {
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'poke_mask' => [
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
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
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
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            },
                            {
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'poke_mask' => [
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
                             'clock_period' => '100',
                             'RV_TOP' => '`TOP.rvtop',
                             'CPU_TOP' => '`RV_TOP.swerv',
                             'datawidth' => '64',
                             'sterr_rollback' => '0',
                             'ext_addrwidth' => '64',
                             'assert_on' => '',
                             'SDVT_AHB' => '1',
                             'TOP' => 'tb_top',
                             'build_axi4' => '1',
                             'lderr_rollback' => '1',
                             'ext_datawidth' => '64'
                           },
            'icache' => {
                          'icache_taddr_high' => 5,
                          'icache_tag_high' => 12,
                          'icache_tag_low' => '6',
                          'icache_ic_rows' => '256',
                          'icache_tag_depth' => 64,
                          'icache_size' => 16,
                          'icache_data_cell' => 'ram_256x34',
                          'icache_tag_cell' => 'ram_64x53',
                          'icache_ic_index' => 8,
                          'icache_enable' => '1',
                          'icache_ic_depth' => 8
                        },
            'physical' => '1',
            'btb' => {
                       'btb_addr_lo' => '4',
                       'btb_index1_lo' => '4',
                       'btb_size' => 32,
                       'btb_btag_fold' => 1,
                       'btb_index3_lo' => 8,
                       'btb_index2_hi' => 7,
                       'btb_index2_lo' => 6,
                       'btb_index1_hi' => 5,
                       'btb_array_depth' => 4,
                       'btb_index3_hi' => 9,
                       'btb_btag_size' => 9,
                       'btb_addr_hi' => 5
                     },
            'csr' => {
                       'mhpmcounter5' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'mstatus' => {
                                      'exists' => 'true',
                                      'reset' => '0x1800',
                                      'mask' => '0x88'
                                    },
                       'pmpaddr4' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr6' => {
                                       'exists' => 'false'
                                     },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'dicad1' => {
                                     'comment' => 'Cache diagnostics.',
                                     'debug' => 'true',
                                     'number' => '0x7ca',
                                     'mask' => '0x3',
                                     'exists' => 'true',
                                     'reset' => '0x0'
                                   },
                       'meicpct' => {
                                      'comment' => 'External claim id/priority capture.',
                                      'number' => '0xbca',
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'mask' => '0x0'
                                    },
                       'pmpaddr11' => {
                                        'exists' => 'false'
                                      },
                       'dicad0' => {
                                     'number' => '0x7c9',
                                     'comment' => 'Cache diagnostics.',
                                     'debug' => 'true',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'mask' => '0xffffffff'
                                   },
                       'pmpaddr3' => {
                                       'exists' => 'false'
                                     },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'mitcnt0' => {
                                      'mask' => '0xffffffff',
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'number' => '0x7d2'
                                    },
                       'pmpaddr8' => {
                                       'exists' => 'false'
                                     },
                       'mie' => {
                                  'mask' => '0x70000888',
                                  'reset' => '0x0',
                                  'exists' => 'true'
                                },
                       'mgpmc' => {
                                    'exists' => 'true',
                                    'reset' => '0x1',
                                    'mask' => '0x1',
                                    'number' => '0x7d0'
                                  },
                       'mcountinhibit' => {
                                            'exists' => 'false'
                                          },
                       'mitctl0' => {
                                      'number' => '0x7d4',
                                      'mask' => '0x00000007',
                                      'reset' => '0x1',
                                      'exists' => 'true'
                                    },
                       'mcpc' => {
                                   'number' => '0x7c2',
                                   'mask' => '0x0',
                                   'reset' => '0x0',
                                   'exists' => 'true'
                                 },
                       'mhpmcounter6h' => {
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0xffffffff'
                                          },
                       'mhpmevent4' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'mhpmcounter4h' => {
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0',
                                            'exists' => 'true'
                                          },
                       'meicurpl' => {
                                       'reset' => '0x0',
                                       'exists' => 'true',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt current priority level.',
                                       'number' => '0xbcc'
                                     },
                       'mhpmcounter3h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'mhpmcounter3' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'dicawics' => {
                                       'number' => '0x7c8',
                                       'debug' => 'true',
                                       'comment' => 'Cache diagnostics.',
                                       'mask' => '0x0130fffc',
                                       'exists' => 'true',
                                       'reset' => '0x0'
                                     },
                       'marchid' => {
                                      'reset' => '0x0000000b',
                                      'exists' => 'true',
                                      'mask' => '0x0'
                                    },
                       'mimpid' => {
                                     'mask' => '0x0',
                                     'exists' => 'true',
                                     'reset' => '0x6'
                                   },
                       'mfdc' => {
                                   'reset' => '0x00070040',
                                   'exists' => 'true',
                                   'mask' => '0x000727ff',
                                   'number' => '0x7f9'
                                 },
                       'pmpaddr13' => {
                                        'exists' => 'false'
                                      },
                       'pmpcfg0' => {
                                      'exists' => 'false'
                                    },
                       'mitbnd1' => {
                                      'reset' => '0xffffffff',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d6'
                                    },
                       'pmpaddr14' => {
                                        'exists' => 'false'
                                      },
                       'meicidpl' => {
                                       'reset' => '0x0',
                                       'exists' => 'true',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt claim id priority level.',
                                       'number' => '0xbcb'
                                     },
                       'mitctl1' => {
                                      'mask' => '0x00000007',
                                      'reset' => '0x1',
                                      'exists' => 'true',
                                      'number' => '0x7d7'
                                    },
                       'mpmc' => {
                                   'number' => '0x7c6',
                                   'comment' => 'FWHALT',
                                   'poke_mask' => '0x2',
                                   'exists' => 'true',
                                   'reset' => '0x2',
                                   'mask' => '0x2'
                                 },
                       'pmpaddr5' => {
                                       'exists' => 'false'
                                     },
                       'miccmect' => {
                                       'number' => '0x7f1',
                                       'mask' => '0xffffffff',
                                       'reset' => '0x0',
                                       'exists' => 'true'
                                     },
                       'mdccmect' => {
                                       'number' => '0x7f2',
                                       'reset' => '0x0',
                                       'exists' => 'true',
                                       'mask' => '0xffffffff'
                                     },
                       'micect' => {
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'mask' => '0xffffffff',
                                     'number' => '0x7f0'
                                   },
                       'pmpaddr10' => {
                                        'exists' => 'false'
                                      },
                       'mhpmevent3' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'mhpmcounter5h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'dmst' => {
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'debug' => 'true',
                                   'number' => '0x7c4',
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'mask' => '0x0'
                                 },
                       'dcsr' => {
                                   'exists' => 'true',
                                   'reset' => '0x40000003',
                                   'poke_mask' => '0x00008dcc',
                                   'mask' => '0x00008c04'
                                 },
                       'pmpaddr0' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr1' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent6' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'pmpaddr7' => {
                                       'exists' => 'false'
                                     },
                       'mip' => {
                                  'exists' => 'true',
                                  'reset' => '0x0',
                                  'poke_mask' => '0x70000888',
                                  'mask' => '0x0'
                                },
                       'mhpmcounter6' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'meipt' => {
                                    'mask' => '0xf',
                                    'reset' => '0x0',
                                    'exists' => 'true',
                                    'number' => '0xbc9',
                                    'comment' => 'External interrupt priority threshold.'
                                  },
                       'pmpcfg1' => {
                                      'exists' => 'false'
                                    },
                       'mhpmevent5' => {
                                         'exists' => 'true',
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff'
                                       },
                       'pmpcfg2' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr12' => {
                                        'exists' => 'false'
                                      },
                       'pmpaddr2' => {
                                       'exists' => 'false'
                                     },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'dicago' => {
                                     'number' => '0x7cb',
                                     'debug' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'mask' => '0x0'
                                   },
                       'pmpaddr9' => {
                                       'exists' => 'false'
                                     },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'pmpcfg3' => {
                                      'exists' => 'false'
                                    },
                       'mitcnt1' => {
                                      'number' => '0x7d5',
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff'
                                    },
                       'mvendorid' => {
                                        'reset' => '0x45',
                                        'exists' => 'true',
                                        'mask' => '0x0'
                                      },
                       'pmpaddr15' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter4' => {
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0',
                                           'exists' => 'true'
                                         },
                       'mcgc' => {
                                   'poke_mask' => '0x000001ff',
                                   'exists' => 'true',
                                   'reset' => '0x0',
                                   'mask' => '0x000001ff',
                                   'number' => '0x7f8'
                                 },
                       'tselect' => {
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'mask' => '0x3'
                                    },
                       'misa' => {
                                   'mask' => '0x0',
                                   'exists' => 'true',
                                   'reset' => '0x40001104'
                                 },
                       'mitbnd0' => {
                                      'mask' => '0xffffffff',
                                      'exists' => 'true',
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d3'
                                    }
                     },
            'dccm' => {
                        'dccm_num_banks_8' => '',
                        'dccm_size' => 32,
                        'dccm_rows' => '512',
                        'dccm_width_bits' => 3,
                        'dccm_ecc_width' => 8,
                        'dccm_offset' => '0x70040000',
                        'dccm_eadr' => '0x70047fff',
                        'lsu_sb_bits' => 15,
                        'dccm_data_width' => 64,
                        'dccm_size_32' => '',
                        'dccm_sadr' => '0x70040000',
                        'dccm_data_cell' => 'ram_512x72',
                        'dccm_num_banks' => '8',
                        'dccm_index_bits' => 9,
                        'dccm_fdata_width' => 72,
                        'dccm_bits' => 15,
                        'dccm_reserved' => '0x1000',
                        'dccm_region' => '0x0',
                        'dccm_enable' => '1',
                        'dccm_byte_width' => '8',
                        'dccm_bank_bits' => 3
                      },
            'iccm' => {
                        'iccm_num_banks_8' => '',
                        'iccm_bits' => 19,
                        'iccm_rows' => '16384',
                        'iccm_sadr' => '0x6e000000',
                        'iccm_bank_bits' => 3,
                        'iccm_index_bits' => 14,
                        'iccm_size_512' => '',
                        'iccm_num_banks' => '8',
                        'iccm_size' => 512,
                        'iccm_data_cell' => 'ram_16384x39',
                        'iccm_offset' => '0x6e000000',
                        'iccm_reserved' => '0x1000',
                        'iccm_eadr' => '0x6e07ffff',
                        'iccm_region' => '0x0',
                        'iccm_enable' => 1
                      },
            'numiregs' => '32',
            'bht' => {
                       'bht_ghr_size' => 5,
                       'bht_addr_lo' => '4',
                       'bht_addr_hi' => 7,
                       'bht_ghr_range' => '4:0',
                       'bht_hash_string' => '{ghr[3:2] ^ {ghr[3+1], {4-1-2{1\'b0} } },hashin[5:4]^ghr[2-1:0]}',
                       'bht_size' => 128,
                       'bht_ghr_pad2' => 'fghr[4:3],2\'b0',
                       'bht_array_depth' => 16,
                       'bht_ghr_pad' => 'fghr[4],3\'b0'
                     },
            'target' => 'default_pd',
            'tec_rv_icg' => 'clockhdr',
            'verilator' => '',
            'num_mmode_perf_regs' => '4',
            'core' => {
                        'dec_instbuf_depth' => '4',
                        'lsu_num_nbload_width' => '3',
                        'lsu_stbuf_depth' => '8',
                        'dma_buf_depth' => '4',
                        'lsu_num_nbload' => '8'
                      },
            'regwidth' => '64',
            'pic' => {
                       'pic_meip_count' => 4,
                       'pic_meipl_mask' => '0xf',
                       'pic_meipt_offset' => '0x3004',
                       'pic_region' => '0x0',
                       'pic_meigwclr_count' => 8,
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meip_offset' => '0x1000',
                       'pic_offset' => '0x700c0000',
                       'pic_meipt_count' => 8,
                       'pic_base_addr' => '0x700c0000',
                       'pic_meigwctrl_count' => 8,
                       'pic_meie_offset' => '0x2000',
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_size' => 32,
                       'pic_total_int' => 8,
                       'pic_meie_mask' => '0x1',
                       'pic_meipl_count' => 8,
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_meipt_mask' => '0x0',
                       'pic_meip_mask' => '0x0',
                       'pic_meigwclr_mask' => '0x0',
                       'pic_meipl_offset' => '0x0000',
                       'pic_meie_count' => 8,
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_int_words' => 1,
                       'pic_total_int_plus1' => 9,
                       'pic_mpiccfg_count' => 1,
                       'pic_bits' => 15,
                       'pic_meigwctrl_offset' => '0x4000'
                     },
            'nmi_vec' => '0x1111111100000000'
          );
1;

# See LICENSE for license details.

#*****************************************************************************
# sh3add.S
#-----------------------------------------------------------------------------
#
# Test sh3add instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN

    TEST_RR_OP(2, sh3add, 0x676927b1816e58cb, 0x10fd3dedadea5195, 0xdf7f3844121bcc23);
    TEST_RR_OP(3, sh3add, 0xdef89b313c7b0663, 0xbd295ce2d2ffbec1, 0xf5adb41aa47d105b);
    TEST_RR_OP(4, sh3add, 0xce1b6cacb7883898, 0xc9649f05a8e1a8bb, 0x82f6747f707af2c0);
    TEST_RR_OP(5, sh3add, 0x1db2789727e8fa1b, 0x3541291848c99fcb, 0x73a92fd4e19bfbc3);
    TEST_RR_OP(6, sh3add, 0xd97d48568374a327, 0x10a24740461d524f, 0x546b0e54528a10af);
    TEST_RR_OP(7, sh3add, 0xb3fab9e2da6dd7c7, 0x546b0e54528a10af, 0x10a24740461d524f);
    TEST_RR_OP(8, sh3add, 0xd28aa7bf55a97de3, 0x73a92fd4e19bfbc3, 0x3541291848c99fcb);
    TEST_RR_OP(9, sh3add, 0xe11843012cb93ebb, 0x82f6747f707af2c0, 0xc9649f05a8e1a8bb);
    TEST_RR_OP(10, sh3add, 0x6a96fdb7f6e84199, 0xf5adb41aa47d105b, 0xbd295ce2d2ffbec1);
    TEST_RR_OP(11, sh3add, 0x0cf7000e3ec8b2ad, 0xdf7f3844121bcc23, 0x10fd3dedadea5195);
    TEST_RR_OP(12, sh3add, 0x0000000000000007, 0x1, 0xffffffffffffffff);
    TEST_RR_OP(13, sh3add, 0x800000000000000f, 0x2, 0x7fffffffffffffff);
    TEST_RR_OP(14, sh3add, 0xc00000000000001f, 0x4, 0xbfffffffffffffff);
    TEST_RR_OP(15, sh3add, 0xe00000000000003f, 0x8, 0xdfffffffffffffff);
    TEST_RR_OP(16, sh3add, 0xf00000000000007f, 0x10, 0xefffffffffffffff);
    TEST_RR_OP(17, sh3add, 0xf8000000000000ff, 0x20, 0xf7ffffffffffffff);
    TEST_RR_OP(18, sh3add, 0xfc000000000001ff, 0x40, 0xfbffffffffffffff);
    TEST_RR_OP(19, sh3add, 0xfe000000000003ff, 0x80, 0xfdffffffffffffff);
    TEST_RR_OP(20, sh3add, 0xff000000000007ff, 0x100, 0xfeffffffffffffff);
    TEST_RR_OP(21, sh3add, 0xff80000000000fff, 0x200, 0xff7fffffffffffff);
    TEST_RR_OP(22, sh3add, 0xffc0000000001fff, 0x400, 0xffbfffffffffffff);
    TEST_RR_OP(23, sh3add, 0xffe0000000003fff, 0x800, 0xffdfffffffffffff);
    TEST_RR_OP(24, sh3add, 0xfff0000000007fff, 0x1000, 0xffefffffffffffff);
    TEST_RR_OP(25, sh3add, 0xfff800000000ffff, 0x2000, 0xfff7ffffffffffff);
    TEST_RR_OP(26, sh3add, 0xfffc00000001ffff, 0x4000, 0xfffbffffffffffff);
    TEST_RR_OP(27, sh3add, 0xfffe00000003ffff, 0x8000, 0xfffdffffffffffff);
    TEST_RR_OP(28, sh3add, 0xffff00000007ffff, 0x10000, 0xfffeffffffffffff);
    TEST_RR_OP(29, sh3add, 0xffff8000000fffff, 0x20000, 0xffff7fffffffffff);
    TEST_RR_OP(30, sh3add, 0xffffc000001fffff, 0x40000, 0xffffbfffffffffff);
    TEST_RR_OP(31, sh3add, 0xffffe000003fffff, 0x80000, 0xffffdfffffffffff);
    TEST_RR_OP(32, sh3add, 0xfffff000007fffff, 0x100000, 0xffffefffffffffff);
    TEST_RR_OP(33, sh3add, 0xfffff80000ffffff, 0x200000, 0xfffff7ffffffffff);
    TEST_RR_OP(34, sh3add, 0xfffffc0001ffffff, 0x400000, 0xfffffbffffffffff);
    TEST_RR_OP(35, sh3add, 0xfffffe0003ffffff, 0x800000, 0xfffffdffffffffff);
    TEST_RR_OP(36, sh3add, 0xffffff0007ffffff, 0x1000000, 0xfffffeffffffffff);
    TEST_RR_OP(37, sh3add, 0xffffff800fffffff, 0x2000000, 0xffffff7fffffffff);
    TEST_RR_OP(38, sh3add, 0xffffffc01fffffff, 0x4000000, 0xffffffbfffffffff);
    TEST_RR_OP(39, sh3add, 0xffffffe03fffffff, 0x8000000, 0xffffffdfffffffff);
    TEST_RR_OP(40, sh3add, 0xfffffff07fffffff, 0x10000000, 0xffffffefffffffff);
    TEST_RR_OP(41, sh3add, 0xfffffff8ffffffff, 0x20000000, 0xfffffff7ffffffff);
    TEST_RR_OP(42, sh3add, 0xfffffffdffffffff, 0x40000000, 0xfffffffbffffffff);
    TEST_RR_OP(43, sh3add, 0x00000001ffffffff, 0x80000000, 0xfffffffdffffffff);
    TEST_RR_OP(44, sh3add, 0x00000006ffffffff, 0x100000000, 0xfffffffeffffffff);
    TEST_RR_OP(45, sh3add, 0x0000000f7fffffff, 0x200000000, 0xffffffff7fffffff);
    TEST_RR_OP(46, sh3add, 0x0000001fbfffffff, 0x400000000, 0xffffffffbfffffff);
    TEST_RR_OP(47, sh3add, 0x0000003fdfffffff, 0x800000000, 0xffffffffdfffffff);
    TEST_RR_OP(48, sh3add, 0x0000007fefffffff, 0x1000000000, 0xffffffffefffffff);
    TEST_RR_OP(49, sh3add, 0x000000fff7ffffff, 0x2000000000, 0xfffffffff7ffffff);
    TEST_RR_OP(50, sh3add, 0x000001fffbffffff, 0x4000000000, 0xfffffffffbffffff);
    TEST_RR_OP(51, sh3add, 0x000003fffdffffff, 0x8000000000, 0xfffffffffdffffff);
    TEST_RR_OP(52, sh3add, 0x000007fffeffffff, 0x10000000000, 0xfffffffffeffffff);
    TEST_RR_OP(53, sh3add, 0x00000fffff7fffff, 0x20000000000, 0xffffffffff7fffff);
    TEST_RR_OP(54, sh3add, 0x00001fffffbfffff, 0x40000000000, 0xffffffffffbfffff);
    TEST_RR_OP(55, sh3add, 0x00003fffffdfffff, 0x80000000000, 0xffffffffffdfffff);
    TEST_RR_OP(56, sh3add, 0x00007fffffefffff, 0x100000000000, 0xffffffffffefffff);
    TEST_RR_OP(57, sh3add, 0x0000fffffff7ffff, 0x200000000000, 0xfffffffffff7ffff);
    TEST_RR_OP(58, sh3add, 0x0001fffffffbffff, 0x400000000000, 0xfffffffffffbffff);
    TEST_RR_OP(59, sh3add, 0x0003fffffffdffff, 0x800000000000, 0xfffffffffffdffff);
    TEST_RR_OP(60, sh3add, 0x0007fffffffeffff, 0x1000000000000, 0xfffffffffffeffff);
    TEST_RR_OP(61, sh3add, 0x000fffffffff7fff, 0x2000000000000, 0xffffffffffff7fff);
    TEST_RR_OP(62, sh3add, 0x001fffffffffbfff, 0x4000000000000, 0xffffffffffffbfff);
    TEST_RR_OP(63, sh3add, 0x003fffffffffdfff, 0x8000000000000, 0xffffffffffffdfff);
    TEST_RR_OP(64, sh3add, 0x007fffffffffefff, 0x10000000000000, 0xffffffffffffefff);
    TEST_RR_OP(65, sh3add, 0x00fffffffffff7ff, 0x20000000000000, 0xfffffffffffff7ff);
    TEST_RR_OP(66, sh3add, 0x01fffffffffffbff, 0x40000000000000, 0xfffffffffffffbff);
    TEST_RR_OP(67, sh3add, 0x03fffffffffffdff, 0x80000000000000, 0xfffffffffffffdff);
    TEST_RR_OP(68, sh3add, 0x07fffffffffffeff, 0x100000000000000, 0xfffffffffffffeff);
    TEST_RR_OP(69, sh3add, 0x0fffffffffffff7f, 0x200000000000000, 0xffffffffffffff7f);
    TEST_RR_OP(70, sh3add, 0x1fffffffffffffbf, 0x400000000000000, 0xffffffffffffffbf);
    TEST_RR_OP(71, sh3add, 0x3fffffffffffffdf, 0x800000000000000, 0xffffffffffffffdf);
    TEST_RR_OP(72, sh3add, 0x7fffffffffffffef, 0x1000000000000000, 0xffffffffffffffef);
    TEST_RR_OP(73, sh3add, 0xfffffffffffffff7, 0x2000000000000000, 0xfffffffffffffff7);
    TEST_RR_OP(74, sh3add, 0xfffffffffffffffb, 0x4000000000000000, 0xfffffffffffffffb);
    TEST_RR_OP(75, sh3add, 0xfffffffffffffffd, 0x8000000000000000, 0xfffffffffffffffd);
    TEST_RR_OP(76, sh3add, 0xfffffffffffffffe, 0x0, 0xfffffffffffffffe);
    TEST_RR_OP(77, sh3add, 0xfffffffffffffff0, 0xfffffffffffffffe, 0x0);
    TEST_RR_OP(78, sh3add, 0x7fffffffffffffe8, 0xfffffffffffffffd, 0x8000000000000000);
    TEST_RR_OP(79, sh3add, 0x3fffffffffffffd8, 0xfffffffffffffffb, 0x4000000000000000);
    TEST_RR_OP(80, sh3add, 0x1fffffffffffffb8, 0xfffffffffffffff7, 0x2000000000000000);
    TEST_RR_OP(81, sh3add, 0x0fffffffffffff78, 0xffffffffffffffef, 0x1000000000000000);
    TEST_RR_OP(82, sh3add, 0x07fffffffffffef8, 0xffffffffffffffdf, 0x800000000000000);
    TEST_RR_OP(83, sh3add, 0x03fffffffffffdf8, 0xffffffffffffffbf, 0x400000000000000);
    TEST_RR_OP(84, sh3add, 0x01fffffffffffbf8, 0xffffffffffffff7f, 0x200000000000000);
    TEST_RR_OP(85, sh3add, 0x00fffffffffff7f8, 0xfffffffffffffeff, 0x100000000000000);
    TEST_RR_OP(86, sh3add, 0x007fffffffffeff8, 0xfffffffffffffdff, 0x80000000000000);
    TEST_RR_OP(87, sh3add, 0x003fffffffffdff8, 0xfffffffffffffbff, 0x40000000000000);
    TEST_RR_OP(88, sh3add, 0x001fffffffffbff8, 0xfffffffffffff7ff, 0x20000000000000);
    TEST_RR_OP(89, sh3add, 0x000fffffffff7ff8, 0xffffffffffffefff, 0x10000000000000);
    TEST_RR_OP(90, sh3add, 0x0007fffffffefff8, 0xffffffffffffdfff, 0x8000000000000);
    TEST_RR_OP(91, sh3add, 0x0003fffffffdfff8, 0xffffffffffffbfff, 0x4000000000000);
    TEST_RR_OP(92, sh3add, 0x0001fffffffbfff8, 0xffffffffffff7fff, 0x2000000000000);
    TEST_RR_OP(93, sh3add, 0x0000fffffff7fff8, 0xfffffffffffeffff, 0x1000000000000);
    TEST_RR_OP(94, sh3add, 0x00007fffffeffff8, 0xfffffffffffdffff, 0x800000000000);
    TEST_RR_OP(95, sh3add, 0x00003fffffdffff8, 0xfffffffffffbffff, 0x400000000000);
    TEST_RR_OP(96, sh3add, 0x00001fffffbffff8, 0xfffffffffff7ffff, 0x200000000000);
    TEST_RR_OP(97, sh3add, 0x00000fffff7ffff8, 0xffffffffffefffff, 0x100000000000);
    TEST_RR_OP(98, sh3add, 0x000007fffefffff8, 0xffffffffffdfffff, 0x80000000000);
    TEST_RR_OP(99, sh3add, 0x000003fffdfffff8, 0xffffffffffbfffff, 0x40000000000);
    TEST_RR_OP(100, sh3add, 0x000001fffbfffff8, 0xffffffffff7fffff, 0x20000000000);
    TEST_RR_OP(101, sh3add, 0x000000fff7fffff8, 0xfffffffffeffffff, 0x10000000000);
    TEST_RR_OP(102, sh3add, 0x0000007feffffff8, 0xfffffffffdffffff, 0x8000000000);
    TEST_RR_OP(103, sh3add, 0x0000003fdffffff8, 0xfffffffffbffffff, 0x4000000000);
    TEST_RR_OP(104, sh3add, 0x0000001fbffffff8, 0xfffffffff7ffffff, 0x2000000000);
    TEST_RR_OP(105, sh3add, 0x0000000f7ffffff8, 0xffffffffefffffff, 0x1000000000);
    TEST_RR_OP(106, sh3add, 0x00000006fffffff8, 0xffffffffdfffffff, 0x800000000);
    TEST_RR_OP(107, sh3add, 0x00000001fffffff8, 0xffffffffbfffffff, 0x400000000);
    TEST_RR_OP(108, sh3add, 0xfffffffdfffffff8, 0xffffffff7fffffff, 0x200000000);
    TEST_RR_OP(109, sh3add, 0xfffffff8fffffff8, 0xfffffffeffffffff, 0x100000000);
    TEST_RR_OP(110, sh3add, 0xfffffff07ffffff8, 0xfffffffdffffffff, 0x80000000);
    TEST_RR_OP(111, sh3add, 0xffffffe03ffffff8, 0xfffffffbffffffff, 0x40000000);
    TEST_RR_OP(112, sh3add, 0xffffffc01ffffff8, 0xfffffff7ffffffff, 0x20000000);
    TEST_RR_OP(113, sh3add, 0xffffff800ffffff8, 0xffffffefffffffff, 0x10000000);
    TEST_RR_OP(114, sh3add, 0xffffff0007fffff8, 0xffffffdfffffffff, 0x8000000);
    TEST_RR_OP(115, sh3add, 0xfffffe0003fffff8, 0xffffffbfffffffff, 0x4000000);
    TEST_RR_OP(116, sh3add, 0xfffffc0001fffff8, 0xffffff7fffffffff, 0x2000000);
    TEST_RR_OP(117, sh3add, 0xfffff80000fffff8, 0xfffffeffffffffff, 0x1000000);
    TEST_RR_OP(118, sh3add, 0xfffff000007ffff8, 0xfffffdffffffffff, 0x800000);
    TEST_RR_OP(119, sh3add, 0xffffe000003ffff8, 0xfffffbffffffffff, 0x400000);
    TEST_RR_OP(120, sh3add, 0xffffc000001ffff8, 0xfffff7ffffffffff, 0x200000);
    TEST_RR_OP(121, sh3add, 0xffff8000000ffff8, 0xffffefffffffffff, 0x100000);
    TEST_RR_OP(122, sh3add, 0xffff00000007fff8, 0xffffdfffffffffff, 0x80000);
    TEST_RR_OP(123, sh3add, 0xfffe00000003fff8, 0xffffbfffffffffff, 0x40000);
    TEST_RR_OP(124, sh3add, 0xfffc00000001fff8, 0xffff7fffffffffff, 0x20000);
    TEST_RR_OP(125, sh3add, 0xfff800000000fff8, 0xfffeffffffffffff, 0x10000);
    TEST_RR_OP(126, sh3add, 0xfff0000000007ff8, 0xfffdffffffffffff, 0x8000);
    TEST_RR_OP(127, sh3add, 0xffe0000000003ff8, 0xfffbffffffffffff, 0x4000);
    TEST_RR_OP(128, sh3add, 0xffc0000000001ff8, 0xfff7ffffffffffff, 0x2000);
    TEST_RR_OP(129, sh3add, 0xff80000000000ff8, 0xffefffffffffffff, 0x1000);
    TEST_RR_OP(130, sh3add, 0xff000000000007f8, 0xffdfffffffffffff, 0x800);
    TEST_RR_OP(131, sh3add, 0xfe000000000003f8, 0xffbfffffffffffff, 0x400);
    TEST_RR_OP(132, sh3add, 0xfc000000000001f8, 0xff7fffffffffffff, 0x200);
    TEST_RR_OP(133, sh3add, 0xf8000000000000f8, 0xfeffffffffffffff, 0x100);
    TEST_RR_OP(134, sh3add, 0xf000000000000078, 0xfdffffffffffffff, 0x80);
    TEST_RR_OP(135, sh3add, 0xe000000000000038, 0xfbffffffffffffff, 0x40);
    TEST_RR_OP(136, sh3add, 0xc000000000000018, 0xf7ffffffffffffff, 0x20);
    TEST_RR_OP(137, sh3add, 0x8000000000000008, 0xefffffffffffffff, 0x10);
    TEST_RR_OP(138, sh3add, 0x0000000000000000, 0xdfffffffffffffff, 0x8);
    TEST_RR_OP(139, sh3add, 0xfffffffffffffffc, 0xbfffffffffffffff, 0x4);
    TEST_RR_OP(140, sh3add, 0xfffffffffffffffa, 0x7fffffffffffffff, 0x2);
    TEST_RR_OP(141, sh3add, 0xfffffffffffffff9, 0xffffffffffffffff, 0x1);
    TEST_RR_OP(142, sh3add, 0x0000000000000008, 0x1, 0x0);
    TEST_RR_OP(143, sh3add, 0x0000000000000010, 0x2, 0x0);
    TEST_RR_OP(144, sh3add, 0x0000000000000020, 0x4, 0x0);
    TEST_RR_OP(145, sh3add, 0x0000000000000040, 0x8, 0x0);
    TEST_RR_OP(146, sh3add, 0x0000000000000080, 0x10, 0x0);
    TEST_RR_OP(147, sh3add, 0x0000000000000100, 0x20, 0x0);
    TEST_RR_OP(148, sh3add, 0x0000000000000200, 0x40, 0x0);
    TEST_RR_OP(149, sh3add, 0x0000000000000400, 0x80, 0x0);
    TEST_RR_OP(150, sh3add, 0x0000000000000800, 0x100, 0x0);
    TEST_RR_OP(151, sh3add, 0x0000000000001000, 0x200, 0x0);
    TEST_RR_OP(152, sh3add, 0x0000000000002000, 0x400, 0x0);
    TEST_RR_OP(153, sh3add, 0x0000000000004000, 0x800, 0x0);
    TEST_RR_OP(154, sh3add, 0x0000000000008000, 0x1000, 0x0);
    TEST_RR_OP(155, sh3add, 0x0000000000010000, 0x2000, 0x0);
    TEST_RR_OP(156, sh3add, 0x0000000000020000, 0x4000, 0x0);
    TEST_RR_OP(157, sh3add, 0x0000000000040000, 0x8000, 0x0);
    TEST_RR_OP(158, sh3add, 0x0000000000080000, 0x10000, 0x0);
    TEST_RR_OP(159, sh3add, 0x0000000000100000, 0x20000, 0x0);
    TEST_RR_OP(160, sh3add, 0x0000000000200000, 0x40000, 0x0);
    TEST_RR_OP(161, sh3add, 0x0000000000400000, 0x80000, 0x0);
    TEST_RR_OP(162, sh3add, 0x0000000000800000, 0x100000, 0x0);
    TEST_RR_OP(163, sh3add, 0x0000000001000000, 0x200000, 0x0);
    TEST_RR_OP(164, sh3add, 0x0000000002000000, 0x400000, 0x0);
    TEST_RR_OP(165, sh3add, 0x0000000004000000, 0x800000, 0x0);
    TEST_RR_OP(166, sh3add, 0x0000000008000000, 0x1000000, 0x0);
    TEST_RR_OP(167, sh3add, 0x0000000010000000, 0x2000000, 0x0);
    TEST_RR_OP(168, sh3add, 0x0000000020000000, 0x4000000, 0x0);
    TEST_RR_OP(169, sh3add, 0x0000000040000000, 0x8000000, 0x0);
    TEST_RR_OP(170, sh3add, 0x0000000080000000, 0x10000000, 0x0);
    TEST_RR_OP(171, sh3add, 0x0000000100000000, 0x20000000, 0x0);
    TEST_RR_OP(172, sh3add, 0x0000000200000000, 0x40000000, 0x0);
    TEST_RR_OP(173, sh3add, 0x0000000400000000, 0x80000000, 0x0);
    TEST_RR_OP(174, sh3add, 0x0000000800000000, 0x100000000, 0x0);
    TEST_RR_OP(175, sh3add, 0x0000001000000000, 0x200000000, 0x0);
    TEST_RR_OP(176, sh3add, 0x0000002000000000, 0x400000000, 0x0);
    TEST_RR_OP(177, sh3add, 0x0000004000000000, 0x800000000, 0x0);
    TEST_RR_OP(178, sh3add, 0x0000008000000000, 0x1000000000, 0x0);
    TEST_RR_OP(179, sh3add, 0x0000010000000000, 0x2000000000, 0x0);
    TEST_RR_OP(180, sh3add, 0x0000020000000000, 0x4000000000, 0x0);
    TEST_RR_OP(181, sh3add, 0x0000040000000000, 0x8000000000, 0x0);
    TEST_RR_OP(182, sh3add, 0x0000080000000000, 0x10000000000, 0x0);
    TEST_RR_OP(183, sh3add, 0x0000100000000000, 0x20000000000, 0x0);
    TEST_RR_OP(184, sh3add, 0x0000200000000000, 0x40000000000, 0x0);
    TEST_RR_OP(185, sh3add, 0x0000400000000000, 0x80000000000, 0x0);
    TEST_RR_OP(186, sh3add, 0x0000800000000000, 0x100000000000, 0x0);
    TEST_RR_OP(187, sh3add, 0x0001000000000000, 0x200000000000, 0x0);
    TEST_RR_OP(188, sh3add, 0x0002000000000000, 0x400000000000, 0x0);
    TEST_RR_OP(189, sh3add, 0x0004000000000000, 0x800000000000, 0x0);
    TEST_RR_OP(190, sh3add, 0x0008000000000000, 0x1000000000000, 0x0);
    TEST_RR_OP(191, sh3add, 0x0010000000000000, 0x2000000000000, 0x0);
    TEST_RR_OP(192, sh3add, 0x0020000000000000, 0x4000000000000, 0x0);
    TEST_RR_OP(193, sh3add, 0x0040000000000000, 0x8000000000000, 0x0);
    TEST_RR_OP(194, sh3add, 0x0080000000000000, 0x10000000000000, 0x0);
    TEST_RR_OP(195, sh3add, 0x0100000000000000, 0x20000000000000, 0x0);
    TEST_RR_OP(196, sh3add, 0x0200000000000000, 0x40000000000000, 0x0);
    TEST_RR_OP(197, sh3add, 0x0400000000000000, 0x80000000000000, 0x0);
    TEST_RR_OP(198, sh3add, 0x0800000000000000, 0x100000000000000, 0x0);
    TEST_RR_OP(199, sh3add, 0x1000000000000000, 0x200000000000000, 0x0);
    TEST_RR_OP(200, sh3add, 0x2000000000000000, 0x400000000000000, 0x0);
    TEST_RR_OP(201, sh3add, 0x4000000000000000, 0x800000000000000, 0x0);
    TEST_RR_OP(202, sh3add, 0x8000000000000000, 0x1000000000000000, 0x0);
    TEST_RR_OP(203, sh3add, 0x0000000000000000, 0x2000000000000000, 0x0);
    TEST_RR_OP(204, sh3add, 0x0000000000000000, 0x4000000000000000, 0x0);
    TEST_RR_OP(205, sh3add, 0x0000000000000000, 0x8000000000000000, 0x0);
    TEST_RR_OP(206, sh3add, 0x0000000000000000, 0x0, 0x0);
    TEST_RR_OP(207, sh3add, 0xfffffffffffffff0, 0xfffffffffffffffe, 0x0);
    TEST_RR_OP(208, sh3add, 0xffffffffffffffe8, 0xfffffffffffffffd, 0x0);
    TEST_RR_OP(209, sh3add, 0xffffffffffffffd8, 0xfffffffffffffffb, 0x0);
    TEST_RR_OP(210, sh3add, 0xffffffffffffffb8, 0xfffffffffffffff7, 0x0);
    TEST_RR_OP(211, sh3add, 0xffffffffffffff78, 0xffffffffffffffef, 0x0);
    TEST_RR_OP(212, sh3add, 0xfffffffffffffef8, 0xffffffffffffffdf, 0x0);
    TEST_RR_OP(213, sh3add, 0xfffffffffffffdf8, 0xffffffffffffffbf, 0x0);
    TEST_RR_OP(214, sh3add, 0xfffffffffffffbf8, 0xffffffffffffff7f, 0x0);
    TEST_RR_OP(215, sh3add, 0xfffffffffffff7f8, 0xfffffffffffffeff, 0x0);
    TEST_RR_OP(216, sh3add, 0xffffffffffffeff8, 0xfffffffffffffdff, 0x0);
    TEST_RR_OP(217, sh3add, 0xffffffffffffdff8, 0xfffffffffffffbff, 0x0);
    TEST_RR_OP(218, sh3add, 0xffffffffffffbff8, 0xfffffffffffff7ff, 0x0);
    TEST_RR_OP(219, sh3add, 0xffffffffffff7ff8, 0xffffffffffffefff, 0x0);
    TEST_RR_OP(220, sh3add, 0xfffffffffffefff8, 0xffffffffffffdfff, 0x0);
    TEST_RR_OP(221, sh3add, 0xfffffffffffdfff8, 0xffffffffffffbfff, 0x0);
    TEST_RR_OP(222, sh3add, 0xfffffffffffbfff8, 0xffffffffffff7fff, 0x0);
    TEST_RR_OP(223, sh3add, 0xfffffffffff7fff8, 0xfffffffffffeffff, 0x0);
    TEST_RR_OP(224, sh3add, 0xffffffffffeffff8, 0xfffffffffffdffff, 0x0);
    TEST_RR_OP(225, sh3add, 0xffffffffffdffff8, 0xfffffffffffbffff, 0x0);
    TEST_RR_OP(226, sh3add, 0xffffffffffbffff8, 0xfffffffffff7ffff, 0x0);
    TEST_RR_OP(227, sh3add, 0xffffffffff7ffff8, 0xffffffffffefffff, 0x0);
    TEST_RR_OP(228, sh3add, 0xfffffffffefffff8, 0xffffffffffdfffff, 0x0);
    TEST_RR_OP(229, sh3add, 0xfffffffffdfffff8, 0xffffffffffbfffff, 0x0);
    TEST_RR_OP(230, sh3add, 0xfffffffffbfffff8, 0xffffffffff7fffff, 0x0);
    TEST_RR_OP(231, sh3add, 0xfffffffff7fffff8, 0xfffffffffeffffff, 0x0);
    TEST_RR_OP(232, sh3add, 0xffffffffeffffff8, 0xfffffffffdffffff, 0x0);
    TEST_RR_OP(233, sh3add, 0xffffffffdffffff8, 0xfffffffffbffffff, 0x0);
    TEST_RR_OP(234, sh3add, 0xffffffffbffffff8, 0xfffffffff7ffffff, 0x0);
    TEST_RR_OP(235, sh3add, 0xffffffff7ffffff8, 0xffffffffefffffff, 0x0);
    TEST_RR_OP(236, sh3add, 0xfffffffefffffff8, 0xffffffffdfffffff, 0x0);
    TEST_RR_OP(237, sh3add, 0xfffffffdfffffff8, 0xffffffffbfffffff, 0x0);
    TEST_RR_OP(238, sh3add, 0xfffffffbfffffff8, 0xffffffff7fffffff, 0x0);
    TEST_RR_OP(239, sh3add, 0xfffffff7fffffff8, 0xfffffffeffffffff, 0x0);
    TEST_RR_OP(240, sh3add, 0xffffffeffffffff8, 0xfffffffdffffffff, 0x0);
    TEST_RR_OP(241, sh3add, 0xffffffdffffffff8, 0xfffffffbffffffff, 0x0);
    TEST_RR_OP(242, sh3add, 0xffffffbffffffff8, 0xfffffff7ffffffff, 0x0);
    TEST_RR_OP(243, sh3add, 0xffffff7ffffffff8, 0xffffffefffffffff, 0x0);
    TEST_RR_OP(244, sh3add, 0xfffffefffffffff8, 0xffffffdfffffffff, 0x0);
    TEST_RR_OP(245, sh3add, 0xfffffdfffffffff8, 0xffffffbfffffffff, 0x0);
    TEST_RR_OP(246, sh3add, 0xfffffbfffffffff8, 0xffffff7fffffffff, 0x0);
    TEST_RR_OP(247, sh3add, 0xfffff7fffffffff8, 0xfffffeffffffffff, 0x0);
    TEST_RR_OP(248, sh3add, 0xffffeffffffffff8, 0xfffffdffffffffff, 0x0);
    TEST_RR_OP(249, sh3add, 0xffffdffffffffff8, 0xfffffbffffffffff, 0x0);
    TEST_RR_OP(250, sh3add, 0xffffbffffffffff8, 0xfffff7ffffffffff, 0x0);
    TEST_RR_OP(251, sh3add, 0xffff7ffffffffff8, 0xffffefffffffffff, 0x0);
    TEST_RR_OP(252, sh3add, 0xfffefffffffffff8, 0xffffdfffffffffff, 0x0);
    TEST_RR_OP(253, sh3add, 0xfffdfffffffffff8, 0xffffbfffffffffff, 0x0);
    TEST_RR_OP(254, sh3add, 0xfffbfffffffffff8, 0xffff7fffffffffff, 0x0);
    TEST_RR_OP(255, sh3add, 0xfff7fffffffffff8, 0xfffeffffffffffff, 0x0);
    TEST_RR_OP(256, sh3add, 0xffeffffffffffff8, 0xfffdffffffffffff, 0x0);
    TEST_RR_OP(257, sh3add, 0xffdffffffffffff8, 0xfffbffffffffffff, 0x0);
    TEST_RR_OP(258, sh3add, 0xffbffffffffffff8, 0xfff7ffffffffffff, 0x0);
    TEST_RR_OP(259, sh3add, 0xff7ffffffffffff8, 0xffefffffffffffff, 0x0);
    TEST_RR_OP(260, sh3add, 0xfefffffffffffff8, 0xffdfffffffffffff, 0x0);
    TEST_RR_OP(261, sh3add, 0xfdfffffffffffff8, 0xffbfffffffffffff, 0x0);
    TEST_RR_OP(262, sh3add, 0xfbfffffffffffff8, 0xff7fffffffffffff, 0x0);
    TEST_RR_OP(263, sh3add, 0xf7fffffffffffff8, 0xfeffffffffffffff, 0x0);
    TEST_RR_OP(264, sh3add, 0xeffffffffffffff8, 0xfdffffffffffffff, 0x0);
    TEST_RR_OP(265, sh3add, 0xdffffffffffffff8, 0xfbffffffffffffff, 0x0);
    TEST_RR_OP(266, sh3add, 0xbffffffffffffff8, 0xf7ffffffffffffff, 0x0);
    TEST_RR_OP(267, sh3add, 0x7ffffffffffffff8, 0xefffffffffffffff, 0x0);
    TEST_RR_OP(268, sh3add, 0xfffffffffffffff8, 0xdfffffffffffffff, 0x0);
    TEST_RR_OP(269, sh3add, 0xfffffffffffffff8, 0xbfffffffffffffff, 0x0);
    TEST_RR_OP(270, sh3add, 0xfffffffffffffff8, 0x7fffffffffffffff, 0x0);
    TEST_RR_OP(271, sh3add, 0xfffffffffffffff8, 0xffffffffffffffff, 0x0);

TEST_PASSFAIL
RVTEST_CODE_END
  .data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END


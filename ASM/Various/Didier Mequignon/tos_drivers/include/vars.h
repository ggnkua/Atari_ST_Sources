/* TOS 4.04 Xbios vars for the CT60 board
*  Didier Mequignon 2002-2010, e-mail: aniplay@wanadoo.fr
*
*  This library is free software; you can redistribute it and/or
*  modify it under the terms of the GNU Lesser General Public
*  License as published by the Free Software Foundation; either
*  version 2.1 of the License, or (at your option) any later version.
*
*  This library is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*  Lesser General Public License for more details.
*
*  You should have received a copy of the GNU Lesser General Public
*  License along with this library; if not, write to the Free Software
*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef	_VARS_H
#define	_VARS_H

#define RESERVED_VEC    0x5C
#define XBIOS_VEC       0xB8
#define VBL_VEC         0x70
/* MFP vectors */
#define PSEUDO_DMA_VEC 0x13C // 15
#define TIMER_A_VEC    0x134 // 13
#define RX_FULL_VEC    0x130 // 12
#define RX_ERROR_VEC   0x12C // 11
#define TX_EMPTY_VEC   0x128 // 10
#define TX_ERROR_VEC   0x124 // 9
#define TIMER_B_VEC    0x120 // 8
#define FLOPPY_DMA_VEC 0x11C // 7
#define IKBD_VEC       0x118 // 6
#define TIMER_C_VEC    0x114 // 5
#define TIMER_D_VEC    0x110 // 4
#define CTS_VEC        0x104 // 2

#define etv_timer   0x400
#define etv_critic  0x404
#define memvalid    0x420
#define memctrl     0x424
#define resvalid    0x426
#define resvector   0x42A
#define phystop     0x42E
#define _membot     0x432
#define _memtop     0x436
#define memval2     0x43A
#define flock       0x43E
#define _timer_ms   0x442
#define _bootdev    0x446
#define sshiftmd    0x44C
#define _v_bas_ad   0x44E
#define vblsem      0x452
#define nvbls       0x454
#define _vblqueue   0x456
#define colorptr    0x45A
#define _vbclock    0x462
#define _frclock    0x466
#define hdv_init    0x46A
#define hdv_bpb     0x472	
#define hdv_rw      0x476
#define hdv_boot    0x47A
#define hdv_mediach 0x47E
#define _cmdload    0x482
#define conterm     0x484
#define trp14ret    0x486
#define __md        0x49E
#define savptr      0x4A2
#define _nflops     0x4A6
#define con_state   0x4A8
#define save_row    0x4AC
#define _hz_200     0x4BA
#define _drvbits    0x4C2
#define _dskbufp    0x4C6
#define _dumpflg    0x4EE
#define _sysbase    0x4F2
#define exec_os     0x4FE
#define dump_vec    0x502
#define ptr_stat    0x506
#define ptr_vec     0x50A
#define aux_sta     0x50E
#define aux_vec     0x512
#define pun_ptr     0x516
#define memval3     0x51A
#define proc_type   0x59E
#define cookie      0x5A0
#define ramtop      0x5A4
#define ramvalid    0x5A8
#define _bell_hook  0x5AC
#define _kcl_hook   0x5B0

/* AHDI */

#define PUN_DEV           0x1F /* device number of HD */
#define PUN_UNIT          0x07 /* Unit number */
#define PUN_SCSI          0x08 /* 1=SCSI 0=ACSI */
#define PUN_IDE           0x10 /* Falcon IDE */
#define PUN_REMOVABLE     0x40 /* Removable media */
#define PUN_VALID         0x80 /* zero if valid */

#define pinfo_puns     0  // 2 bytes
#define pinfo_pun      2  // 16 bytes
#define pinfo_pstart  18  // 16 x 4 bytes
#define pinfo_cookie  82  // 4 bytes
#define pinfo_cookptr 86  // 4 bytes
#define pinfo_vernum  90  // 2 bytes
#define pinfo_maxsiz  92  // 2 bytes
#define pinfo_ptype   94  // 16 x 4 bytes
#define pinfo_psize  158  // 16 x 4 bytes
#define pinfo_flags  222  // 16 x 2 bytes, internal use: B15:swap, B7:change, B0:bootable
#define pinfo_bpb    256  // 16 x 18 bytes
#define pinfo_size   544
                  
/* line A offset vars */

#define dev_tab -692
#define v_cel_ht -46
#define v_cel_mx -44
#define v_cel_my -42
#define v_cel_wr -40
#define v_rez_hz -12
#define v_cel_vt -4
#define bytes_ln -2
#define v_lin_wr  2

/* variables and fonts copy added above phystop */

#define RESERVE_MEM_FONTS   0x8000

#define CTPCI_1ABCD         0x00000001
#define ABE_SDR_7           0x00010000
#define ETHERNAT            0x80000000
#define SUPERVIDEL          0x40000000

#define measure_clock       (RESERVE_MEM_FONTS-92)
#define hardware_type       (RESERVE_MEM_FONTS-88)
#define pci_io_size         (RESERVE_MEM_FONTS-84)
#define pci_io_offset       (RESERVE_MEM_FONTS-80)
#define pci_memory_size     (RESERVE_MEM_FONTS-76)
#define pci_memory_offset   (RESERVE_MEM_FONTS-72)
#define power_flag          (RESERVE_MEM_FONTS-68)
#define flag_statvec        (RESERVE_MEM_FONTS-64)
#define pbuf_statvec        (RESERVE_MEM_FONTS-60)
#define count_io3_mfp       (RESERVE_MEM_FONTS-54)
#define start_hz_200        (RESERVE_MEM_FONTS-52)
#define flag_cache          (RESERVE_MEM_FONTS-48)
#define save_hz_200         (RESERVE_MEM_FONTS-44)
#define save_source         (RESERVE_MEM_FONTS-40)
#define save_target         (RESERVE_MEM_FONTS-36)
#define save_contrl         (RESERVE_MEM_FONTS-32)
#define adr_source          (RESERVE_MEM_FONTS-28)
#define adr_target          (RESERVE_MEM_FONTS-24)
#define adr_fonts           (RESERVE_MEM_FONTS-20)   /* 5 longs */

#endif

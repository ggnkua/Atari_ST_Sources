/* TOS 4.04 Xbios dispatcher for the CT60/CTPCI and Coldfire boards
 * and USB-disk / SD-card / Ram-Disk utility
 * Didier Mequignon 2005-2011, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"
#include "../include/vars.h"
#ifdef COLDFIRE
#include "../include/fire.h"
#else
#undef pun_ptr
#define pun_ptr pun_ptr_usb
#endif

#undef DEBUG
#undef DEBUG_XHDI

// #define RAM_DISK_FAT12
#define RAM_DISK_SEC_FAT    64
#define RAM_DISK_SIZE_KB    8192

#define SD_CARD_VERIFY
#define SD_CARD_REPLACE_FLOPPY
#define RAM_DISK_REPLACE_B

#define MAX_LOGICAL_DRIVE 16

#define Modecode    0x184C

	.global _det_xbios,_old_vector_xbios
	.global _physbase,_logbase,_getrez,_vsetscreen,_wait_vbl,_vsetmode,_montype,_vgetsize,_vsetrgb,_vgetrgb
	.global _cursconf,_info_fvdi,_ltoa
#ifdef COLDFIRE
	.global _acp_new_hardware
#ifndef MCF5445X
#ifndef MCF547X
#ifdef NETWORK
#ifdef LWIP
	.global _settime,_gettime
#endif
#endif
#endif
#endif
#endif /* COLDFIRE */
#ifdef SOUND_AC97
#ifdef COLDFIRE
#ifdef NETWORK
#ifndef MCF5445X
	.global _locksnd,_unlocksnd,_soundcmd,_setbuffer,_setmode,_settracks,_setmontracks
	.global _setinterrupt,_buffoper,_gpio,_devconnect,_sndstatus,_buffptr
	.global _flag_snd_init,_count_timer_a,_preload_timer_a,_timer_a_enabled,_io7_enabled;
	.global _mcf548x_ac97_playback_resample,_mcf548x_ac97_record_resample
#endif
#endif
#endif
#endif /* SOUND_AC97 */
	.global _validmode,_vmalloc
	.global _vixGetVersion,_vixProbe,_vixInit,_vixDestroy,_vixGetCapability
	.global _vixQueryFourcc,_vixConfigPlayback,_vixPlaybackOn,_vixPlaybackOff
	.global _vixPlaybackFrameSelect,_vixGetGrKeys,_vixSetGrKeys
	.global _vixPlaybackGetEq,_vixPlaybackSetEq,_vixPlaybackGetDeint,_vixPlaybackSetDeint
	.global _InitVideo
	.global _asm_set_ipl
#ifdef MCF547X
	.global _check_sd_card,_install_sd_card
#endif
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	.global _install_usb_stor,_uninstall_usb_stor,_usb_stor_read,_usb_stor_write,_usb_malloc,_usb_1st_disk_drive
#endif
#ifdef NETWORK
#ifdef COLDFIRE
#ifdef LWIP
	.global _disable_caches,_enable_caches,_flush_caches,_flush_dc,_flush_ic
#if !defined(MCF547X) && !defined(MCF5445X)
	.global _set_intfrcl,_clr_intfrcl
#endif
#endif /* LWIP */
#endif /* COLDFIRE */
	.global _install_ram_disk,_address_ram_disk,_size_ram_disk,_change_ram_disk,_ext_write_protect_ram_disk,_ram_disk_drive
	.global _alert_tos
#endif /* NETWORK */
	.global _call_enumfunc,_call_ikbdvec,_call_mousevec,_direct_conout
	.global _critical_error,_get_sr
#if defined(DEBUG) || defined(DEBUG_XHDI)
	.global display_string,hex_long,hex_word,hex_byte,display_char,wait_key,_video_found
#endif

	.data

/* XHDI */

#define XH_DL_SECSIZ 0 // maximal sector size (BIOS level)
#define XH_DL_MINFAT 1 // minimal number of FATs
#define XH_DL_MAXFAT 2 // maximal number of FATs
#define XH_DL_MINSPC 3 // sectors per cluster minimal
#define XH_DL_MAXSPC 4 // sectors per cluster maximal
#define XH_DL_CLUSTS 5 // maximal number of clusters of a 16 bit FAT
#define XH_DL_MAXSEC 6 // maximal number of sectors
#define XH_DL_DRIVES 7 // maximal number of BIOS drives supported by the DOS
	
/* AHDI */

#define PUN_DEV           0x1F /* device number of HD */
#define PUN_UNIT          0x07 /* Unit number */
#define PUN_SCSI          0x08 /* 1=SCSI 0=ACSI */
#define PUN_IDE           0x10 /* Falcon IDE */
#define PUN_USB           0x20 /* USB */
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

#ifdef DEBUG
debug1:	.asciz "XBIOS #0x"
debug2:	.asciz "Setscreen 0x"
debug3:	.asciz "hdv_rw 0x"
debug4:	.ascii "hdv_bpb"
	.byte 13,10,0
debug5:	.ascii "hdv_mediach"
	.byte 13,10,0
debug6:	.asciz "Vsetmode 0x"
debug7:	.asciz "ValidMode 0x"
debug8:	.asciz "Gettime 0x"
#endif
#ifdef DEBUG_XHDI
debug130:	.asciz "XHDI return 0x"
debug131:	.asciz "XHDI XHDrvMap 0x"
debug132:	.asciz "XHDI XHReadWrite major 0x"
debug133:	.asciz "XHDI XHInqTarget major 0x"
debug133a:	.asciz "XHDI XHInqTarget2 major 0x"
debug134:	.asciz "XHDI XHInqDev device 0x"
debug135:	.asciz "XHDI XHInqDriver device 0x"
debug136:	.asciz "XHDI XHInqDev2 device 0x"
debug137:	.asciz "XHDI XHDOSLimits which 0x"
debug138:	.ascii "XHDI XHGetVersion"
	.byte 13,10,0
debug139:	.asciz ", minor 0x"
debug140:	.asciz ", rwflag 0x"
debug141:	.asciz ", sector 0x"
debug142:	.asciz ", count 0x"
debug143:	.asciz ", buffer 0x"
#endif

	.align 2

_det_xbios:

#if defined(COLDFIRE) && (__GNUC__ <= 3)
	.chip 68060
	move.l USP,A0            // V4
	.chip 5200
#else
	move.l USP,A0
#endif
	btst #5,(SP)             // call in supervisor state
	beq.s .x2
	lea 6(SP),A0
	tst.w proc_type
	beq.s .x2
	tst.w (A0)+              // if > 68000
.x2:
#ifdef DEBUG
	move.l A0,-(SP)
	moveq #0,D0
	move.w (A0),D0           // function
	cmp.l #2,D0              // Physbase
	beq.s .x0
	cmp.l #3,D0              // Logbase
	beq.s .x0
	cmp.l #4,D0              // Getrez
	beq.s .x0
	cmp.l #5,D0              // Setscreen
	beq.s .x0
	cmp.l #22,D0             // Gettime
	beq.s .x0
	cmp.l #23,D0             // Settime
	beq.s .x0
	cmp.l #64,D0             // Blitmode
	beq.s .x0
	cmp.l #88,D0             // Vsetmode
	beq.s .x0
	cmp.l #89,D0             // Mon_type
	beq.s .x0
	cmp.l #91,D0             // Vgetsize
	beq.s .x0
	cmp.l #93,D0             // Vsetrgb
	beq.s .x0
	cmp.l #94,D0             // Vgetrgb
	beq.s .x0
	cmp.l #95,D0             // ValidMode (undocumented)
	beq.s .x0
	cmp.l #141,D0            // Buffptr
	bhi.s .x0b
	cmp.l #128,D0            // Locksnd
	bcs.s .x0b	
.x0:
	lea debug1(PC),A0
	jsr display_string
	move.l (SP),A0
	move.w (A0),D0           // opcode function
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
.x0b:
	move.l (SP)+,A0
#endif
#ifdef PATCH_NVDI
	move.l A2,-(SP)
	move.l 0xB8,A1           // TRAP #14
	move.l A1,A2
	moveq #0,D1
.loop_xbra:
#ifdef COLDFIRE
		move.l -12(A1),D0
		cmp.l #0x58425241,D0     // XBRA
		bne.s .no_xbra
		move.l -8(A1),D0
		cmp.l #0x4E564449,D0     // NVDI
		bne.s .not_nvdi
		move.l A1,D1
		bra.s .next_xbra
.not_nvdi:
		move.l -8(A1),D0
		cmp.l #0x5F504349,D0     // _PCI
#else /* !COLDFIRE */
		cmp.l #0x58425241,-12(A1) // XBRA
		bne.s .no_xbra
		cmp.l #0x4E564449,-8(A1)  // NVDI
		bne.s .not_nvdi
		move.l A1,D1
		bra.s .next_xbra
.not_nvdi:
		cmp.l #0x5F504349,-8(A1) // _PCI
#endif /* COLDFIRE */
		bne.s .next_xbra
		tst.l D1
		beq.s .no_xbra           // NVDI not found before _PCI
		move.l -4(A1),-4(A2)     // remove _PCI XBRA
		move.l 0xB8,-4(A1)       // install _PCI XBRA at the top
		move.l A1,0xB8           // TRAP #14
		bra.s .no_xbra
.next_xbra:
		move.l -4(A1),D0         // next
		beq.s .no_xbra           // no vector
		move.l A1,A2             // previous
		move.l D0,A1
	bra.s .loop_xbra
.no_xbra:
	move.l (SP)+,A2
#endif /* PATCH_NVDI */
#ifdef COLDFIRE
	moveq #0,D0
#endif
	move.w (A0),D0           // function
	tst.l _info_fvdi
	beq .x11
#ifdef COLDFIRE
	cmp.l #2,D0              // Physbase
#else
	cmp.w #2,D0              // Physbase
#endif
	bne.s .x9
	jsr _physbase
	rte	
.x9:
#ifdef COLDFIRE
	cmp.l #3,D0              // Logbase
#else
	cmp.w #3,D0              // Logbase
#endif
	bne.s .x31
	jsr _logbase
	rte	
.x31:
#ifdef COLDFIRE
	cmp.l #4,D0              // Getrez
#else
	cmp.w #4,D0              // Getrez
#endif
	bne.s .x26
	jsr _getrez
	rte
.x26:
#ifdef COLDFIRE
	cmp.l #5,D0              // Setscreen
#else
	cmp.w #5,D0              // Setscreen
#endif
	bne .x3
#ifdef DEBUG
	move.l A0,-(SP)
	lea debug2(PC),A0
	jsr display_string
	move.l (SP)+,A0
	move.l 2(A0),D0
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.l 6(A0),D0
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 10(A0),D0
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 12(A0),D0
	jsr hex_word	
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	moveq #1,D0
	move.l D0,-(SP)          // init var VDI
	move.w 12(A0),D0         // modecode
	ext.l D0
	move.l D0,-(SP)
	move.w 10(A0),D0         // rez
	ext.l D0
	move.l D0,-(SP)
	move.l 6(A0),-(SP)       // logical address
	move.l 2(A0),-(SP)       // physical address
	jsr _vsetscreen
	lea 20(SP),SP
	rte
.x3:
	cmp.l #21,D0             // Cursconf
	bne.s .x25
	move.w 4(A0),-(SP)       // operand
	move.w 2(A0),-(SP)       // function
	jsr _cursconf            // VDI ESC VT52
	addq.l #4,SP
	rte
.x25:
#ifdef COLDFIRE
#ifdef USE_RTC
#ifndef MCF5445X
#ifndef MCF547X
#ifdef NETWORK
#ifdef LWIP
	move.l MCF_SIU_JTAGID,D1 // check the processor
	and.l #MCF_SIU_JTAGID_PROCESSOR,D1
	cmp.l #MCF_SIU_JTAGID_MCF5485,D1
             bne.s .x24               // <> M5485EVB
	cmp.l #22,D0             // Settime
	bne.s .x23
	move.l 2(A0),-(SP)
	jsr _settime
	addq.l #4,SP
	bra .x1                  // TOS routine
.x23:
	cmp.l #23,D0             // Gettime
	bne.s .x24
	jsr _gettime
#ifdef DEBUG
	move.l D0,-(SP)
	move.l A0,-(SP)
	lea debug8(PC),A0
	jsr display_string
	move.l (SP)+,A0
	move.w 2(A0),D0
	jsr hex_long
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
	move.l (SP)+,D0
#endif
	tst.l D0
	beq .x1                  // TOS routine
	rte
.x24:
#endif /* LWIP */
#endif /* NETWORK */
#endif /* MCF547X */
#endif /* MCF5445X */
#endif /* RTC */
#endif /* COLDFIRE */
#ifdef COLDFIRE
	cmp.l #37,D0             // Vsync
#else
	cmp.w #37,D0             // Vsync
#endif
	bne.s .x28
	jsr _wait_vbl
	beq.s .x29               // TOS routine
	rte
.x29:
#ifdef COLDFIRE
	move.w SR,D0
	move.w D0,-(SP)
	and.l #0xF8FF,D0         // enable VBL interrupt
	move D0,SR
#else
	move.w SR,-(SP)
	and.w #0xF8FF,SR
#endif
	move.l _frclock,D0
.x30:
	cmp.l _frclock,D0        // enable VBL interrupt
	beq.s .x30
#ifdef COLDFIRE
	move.w (SP)+,D0
	move D0,SR
#else
	move.w (SP)+,SR
#endif
	rte
.x28:
#ifdef COLDFIRE
	cmp.l #64,D0             // Blitmode
#else
	cmp.w #64,D0             // Blitmode
#endif
	bne.s .x4
	moveq #0,D0              // no blitter  
	rte
.x4:
#ifdef COLDFIRE
	cmp.l #88,D0             // Vsetmode
#else
	cmp.w #88,D0             // Vsetmode
#endif
	bne.s .x5
#ifdef DEBUG
	move.l A0,-(SP)
	lea debug6(PC),A0
	jsr display_string
	move.l (SP)+,A0
	move.w 2(A0),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	move.w 2(A0),D0          // modecode
	ext.l D0
	move.l D0,-(SP)
	jsr _vsetmode
	and.l #0xFFFF,D0
	addq.l #4,SP
	rte
.x5:
#ifdef COLDFIRE
	cmp.l #89,D0             // Mon_type
#else
	cmp.w #89,D0             // Mon_type
#endif
	bne.s .x6
	jsr _montype
	rte
.x6:
#ifdef COLDFIRE
	cmp.l #91,D0             // Vgetsize
#else
	cmp.w #91,D0             // Vgetsize
#endif
	bne.s .x7
	move.w 2(A0),D0          // modecode
	ext.l D0
	move.l D0,-(SP)
	jsr _vgetsize
	addq.l #4,SP
	rte
.x7:
#ifdef COLDFIRE
	cmp.l #93,D0             // Vsetrgb
#else
	cmp.w #93,D0             // Vsetrgb
#endif
	bne.s .x8
	move.l 6(A0),-(SP)       // array	
	moveq #0,D0
	move.w 4(A0),D0          // count		
	move.l D0,-(SP)
	move.w 2(A0),D0          // index
	move.l D0,-(SP)
	jsr _vsetrgb
	lea 12(SP),SP
	rte
.x8:
#ifdef COLDFIRE
	cmp.l #94,D0             // Vgetrgb
#else
	cmp.w #94,D0             // Vgetrgb
#endif
	bne.s .x10
	move.l 6(A0),-(SP)       // array
	moveq #0,D0
	move.w 4(A0),D0          // count		
	move.l D0,-(SP)
	move.w 2(A0),D0          // index
	move.l D0,-(SP)
	jsr _vgetrgb
	lea 12(SP),SP
	rte
.x10:
#ifdef COLDFIRE
	cmp.l #95,D0             // ValidMode (undocumented, used by AES before v_opnwk or set_video dialog box)
#else
	cmp.w #95,D0             // ValidMode (undocumented, used by AES before v_opnwk or set_video dialog box)
#endif
	bne.s .x11
#ifdef DEBUG
	move.l A0,-(SP)
	lea debug7(PC),A0
	jsr display_string
	move.l (SP)+,A0
	move.w 2(A0),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	move.w 2(A0),D0          // modecode
	ext.l D0
	move.l D0,-(SP)
	jsr _validmode
	addq.l #4,SP
	rte
.x11:		
#ifdef COLDFIRE
#ifdef NETWORK
#ifndef MCF5445X
#ifdef SOUND_AC97
	tst.l _flag_snd_init
	beq .x15
	move.w SR,D1
	and.l #0x700,D1
	cmp.l #0x700,D1
	beq .x15                 // called under interrupts ???
	cmp.l #26,D0             // Jdisint
	bne.s .x20
	move.w 2(A0),D0          // num
	bsr jdisint
             bne .x15
             rte
.x20:
	cmp.l #27,D0             // Jenabint
	bne.s .x21
	move.w 2(A0),D0          // num
	bsr jenabint
             bne .x15
             rte
.x21:
	cmp.l #31,D0             // Xbtimer
	bne.s .x22
	move.l D2,-(SP)
	move.w 2(A0),D0          // timer
	move.w 4(A0),D1          // control
	move.w 6(A0),D2          // data
	move.l 8(A0),A0          // vector
	bsr xbtimer
	move.l (SP)+,D2
	tst.l D0
	bne .x15
	rte	
.x22:	
	cmp.l #141,D0
	bhi .x15
	cmp.l #128,D0
	bcs .x15
	sub.l #128,D0
	move.w tab_snd_bios(PC,D0.l*2),D0
	bmi .x15                // original TOS XBIOS
	jsr tab_snd_bios(PC,D0.l)
	rte
tab_snd_bios:
	dc.w locksnd-tab_snd_bios // 128
	dc.w unlocksnd-tab_snd_bios // 129
	dc.w soundcmd-tab_snd_bios // 130
	dc.w setbuffer-tab_snd_bios // 131
	dc.w setmode-tab_snd_bios // 132
	dc.w settracks-tab_snd_bios // 133
	dc.w setmontracks-tab_snd_bios // 134
	dc.w setinterrupt-tab_snd_bios // 135
	dc.w buffoper-tab_snd_bios // 136
	dc.w -1 // 137
	dc.w gpio-tab_snd_bios // 138
	dc.w devconnect-tab_snd_bios // 139
	dc.w sndstatus-tab_snd_bios // 140
	dc.w buffptr-tab_snd_bios // 141

jdisint:

	ext.l D0
	cmp.l #13,D0 // timer A
	bne.s .x16
	clr.l _timer_a_enabled
	moveq #0,D0
	rts
.x16:
	cmp.l #15,D0 // IO7
	bne.s .x17
	clr.l _io7_enabled
	moveq #0,D0
	rts
.x17:
	moveq #1,D0
	rts

jenabint:

	ext.l D0
	cmp.l #13,D0 // timer A
	bne.s .x18
	moveq #1,D0
	move.l D0,_timer_a_enabled
	moveq #0,D0
	rts
.x18:
	cmp.l #15,D0 // IO7
	bne.s .x17
	moveq #1,D0
	move.l D0,_io7_enabled
	moveq #0,D0
	rts
 
xbtimer:

	ext.l D0
	bne.s .x17 // <> timer A
	ext.l D1
	bne.s .x19 // <> stop
	clr.l _count_timer_a
	clr.l _preload_timer_a
	clr.l 0x134
	moveq #0,D0
	rts
.x19:
	cmp.l #8,D1
	bne.s .x17 // <> event count mode
	and.l #0xFF,D2
	move.l D2,_count_timer_a
	move.l D2,_preload_timer_a
	move.l A0,0x134 // vector
	moveq #0,D0
	rts

locksnd:

	jmp _locksnd

unlocksnd:

	jmp _unlocksnd

soundcmd:

	moveq #0,D0
	move.w 4(A0),D0
	move.l D0,-(SP) // data
	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // mode
	jsr _soundcmd
	addq.l #8,SP
	rts

setbuffer:

	move.l 8(A0),-(SP) // endaddr
	move.l 4(A0),-(SP) // begaddr
	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // reg
	jsr _setbuffer
	lea 12(SP),SP
	rts

setmode:

	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // mode
	jsr _setmode
	addq.l #4,SP
	rts

settracks:

	move.w 4(A0),D0
	ext.l D0
	move.l D0,-(SP) // rectracks
	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // playtracks
	jsr _settracks
	addq.l #8,SP
	rts

setmontracks:

	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // track
	jsr _setmontracks
	addq.l #4,SP
	rts

setinterrupt:

	move.l 6(A0),D0
	move.l D0,-(SP) // callback
	move.w 4(A0),D0
	ext.l D0
	move.l D0,-(SP) // cause
	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // src
	jsr _setinterrupt
	lea 12(SP),SP
	rts

buffoper:

	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // mode
	jsr _buffoper
	addq.l #4,SP
	rts

gpio:

	move.w 4(A0),D0
	ext.l D0
	move.l D0,-(SP) // data
	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // mode
	jsr _gpio
	addq.l #8,SP
	rts

devconnect:

	move.w 10(A0),D0
	ext.l D0
	move.l D0,-(SP) // protocol
	move.w 8(A0),D0
	ext.l D0
	move.l D0,-(SP) // prescale
	move.w 6(A0),D0
	ext.l D0
	move.l D0,-(SP) // srcclk
	move.w 4(A0),D0
	ext.l D0
	move.l D0,-(SP) // dest
	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // src
	jsr _devconnect
	lea 20(SP),SP
	rts

sndstatus:

	move.w 2(A0),D0
	ext.l D0
	move.l D0,-(SP) // mode
	jsr _sndstatus
	addq.l #4,SP
	rts

buffptr:
	move.l 2(A0),-(SP) // pointer
	jsr _buffptr
	addq.l #4,SP
	rts
 
.x15:
#endif /* SOUND_AC97 */
#endif /* MCF5445X */
#endif /* NETWORK */
	tst.l _info_fvdi
	beq.s .x1
	cmp.l #0xc60e,D0         // ct60_vmalloc
	beq.s .x12
	cmp.l #0xc6e,D0          // bis
#else /* !COLDFIRE */
	tst.l _info_fvdi
	beq.s .x1
	cmp.w #0xc60e,D0         // ct60_vmalloc
	beq.s .x12
	cmp.w #0xc6e,D0          // bis
#endif /* COLDFIRE */
	bne.s .x14
.x12:
	move.l 4(A0),-(SP)
	move.w 2(A0),D0          // value
	ext.l D0
	move.l D0,-(SP)          // mode
	jsr _vmalloc
	addq.l #8,SP
	rte
.x14:
#ifdef COLDFIRE
#ifdef MCF5445X
#undef VIDIX /* because MCF5445X has no FPU */
#else /* MCF548X has FPU */
#define VIDIX
	cmp.l #420,D0
	bhi .x1
	cmp.l #400,D0            // VIDIX
	bcs .x1
	sub.l #400,D0
	move.w tab_vidix_bios(PC,D0.l*2),D0
	bmi .x1                // original TOS XBIOS
	jsr tab_vidix_bios(PC,D0.l)
	rte
#endif /* MCF5445X */
#else /* ATARI */
#define VIDIX
	cmp.w #420,D0
	bhi .x1
	cmp.w #400,D0            // VIDIX
	bcs .x1
	sub.w #400,D0
	move.w tab_vidix_bios(PC,D0.w*2),D0
	bmi .x1                // original TOS XBIOS
	jsr tab_vidix_bios(PC,D0.w)
	rte
#endif /* COLDFIRE */
#ifdef VIDIX
tab_vidix_bios:
	dc.w vixGetVersion-tab_vidix_bios // 400
	dc.w vixProbe-tab_vidix_bios // 401
	dc.w vixInit-tab_vidix_bios // 402
	dc.w vixDestroy-tab_vidix_bios // 403
	dc.w vixGetCapability-tab_vidix_bios // 404
	dc.w vixQueryFourcc-tab_vidix_bios // 405
	dc.w vixConfigPlayback-tab_vidix_bios // 406
	dc.w vixPlaybackOn-tab_vidix_bios // 407
	dc.w vixPlaybackOff-tab_vidix_bios // 408
	dc.w vixPlaybackFrameSelect-tab_vidix_bios // 409
	dc.w vixGetGrKeys-tab_vidix_bios // 410
	dc.w vixSetGrKeys-tab_vidix_bios // 411
	dc.w vixPlaybackGetEq-tab_vidix_bios // 412
	dc.w vixPlaybackSetEq-tab_vidix_bios // 413
	dc.w vixPlaybackGetDeint-tab_vidix_bios // 414
	dc.w vixPlaybackSetDeint-tab_vidix_bios // 415
	dc.w vixPlaybackCopyFrame-tab_vidix_bios // 416
	dc.w vixQueryDMAStatus-tab_vidix_bios // 417
	dc.w -1 // 418
	dc.w -1 // 419
	dc.w InitVideo-tab_vidix_bios // 420
#endif /* VIDIX */
.x1:
#ifdef PATCH_NVDI
#ifndef COLDFIRE
	/* if XBRA moved can't use  _old_vector_xbios */
	cmp.l #0x58425241,-12(A1) // XBRA
	bne.s .x27
	cmp.l #0x5F504349,-8(A1)  // _PCI
	bne.s .x27
	move.l -4(A1),D0          // next
	beq.s .x27
	move.l D0,-(SP)
	rts	
.x27:
#endif /* COLDIRE */
#endif /* PATCH_NVDI */
	move.l _old_vector_xbios,-(SP)
	rts

#ifdef VIDIX	
vixGetVersion:
	
	jmp _vixGetVersion
	
vixProbe:

	move.l 6(A0),-(SP) // force
	move.l 2(A0),-(SP) // verbose
	jsr _vixProbe
	addq.l #8,SP
	rts
	
vixInit:

	jmp _vixInit
	
vixDestroy:

	jmp _vixDestroy

vixGetCapability:

	move.l 2(A0),-(SP) // to
	jsr _vixGetCapability
	addq.l #4,SP
	rts
	
vixQueryFourcc:

	move.l 2(A0),-(SP) // to
	jsr _vixQueryFourcc
	addq.l #4,SP
	rts

vixConfigPlayback:

	move.l 2(A0),-(SP) // info
	jsr _vixConfigPlayback
	addq.l #4,SP
	rts
	
vixPlaybackOn:

	jmp _vixPlaybackOn
	
vixPlaybackOff:

	jmp _vixPlaybackOff

vixPlaybackFrameSelect:

	move.l 2(A0),-(SP) // frame
	jsr _vixPlaybackFrameSelect
	addq.l #4,SP
	rts
	
vixGetGrKeys:

	move.l 2(A0),-(SP) // grkey
	jsr _vixGetGrKeys
	addq.l #4,SP
	rts
	
vixSetGrKeys:
	
	move.l 2(A0),-(SP) // grkey
	jsr _vixSetGrKeys
	addq.l #4,SP
	rts
	
vixPlaybackGetEq:

	move.l 2(A0),-(SP) // eq
	jsr _vixPlaybackGetEq
	addq.l #4,SP
	rts
	
vixPlaybackSetEq:

	move.l 2(A0),-(SP) // eq
	jsr _vixPlaybackSetEq
	addq.l #4,SP
	rts
	
vixPlaybackGetDeint:

	move.l 2(A0),-(SP) // info
	jsr _vixPlaybackGetDeint
	addq.l #4,SP
	rts
	
vixPlaybackSetDeint:

	move.l 2(A0),-(SP) // info
	jsr _vixPlaybackSetDeint
	addq.l #4,SP
	rts
	
vixPlaybackCopyFrame:

	move.l 2(A0),-(SP) // dmai
	jsr _vixPlaybackCopyFrame
	addq.l #4,SP
	rts

vixQueryDMAStatus:

	jmp _vixQueryDMAStatus
	
InitVideo:
	jmp _InitVideo
#endif /* VIDIX */

#ifdef DEBUG
dump:
	lea -20(SP),SP
	movem.l D0-D2/A0-A1,(SP)
	moveq #31,D1
.loop_dump1:
		moveq #15,D2
.loop_dump2:
			move.b (A1)+,D0
			jsr hex_byte
			moveq #0x20,D0
			jsr display_char
		subq.l #1,D2
		bpl.s .loop_dump2
		lea -16(A1),A1
		moveq #15,D2
.loop_dump3:
			moveq #0,D0
			move.b (A1)+,D0
			cmp.l #0x20,D0
			bcs.s .dump_bad_char
			cmp.l #0x7F,D0
			bcs.s .dump_ok
.dump_bad_char:
			moveq #0x2E,D0
.dump_ok:
			jsr display_char
		subq.l #1,D2
		bpl.s .loop_dump3
		moveq #13,D0
		jsr display_char
		moveq #10,D0
		jsr display_char
	subq.l #1,D1
	bpl.s .loop_dump1
	movem.l (SP),D0-D2/A0-A1
	lea 20(SP),SP
	rts
#endif /* DEBUG */

install_xbra:	// A0: handler, D0: vector, D1: ID 

	lea -28(SP),SP
	movem.l D1-D3/A0-A3,(SP)
	moveq #0,D3
	move.w D0,D3             // vector
	move.l A0,A3             // handler
	move.l D1,-(SP)
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) && defined(CONFIG_USB_MEM_NO_CACHE)
	move.l _pxCurrentTCB,D1
	cmp.l _tid_TOS,D1
	beq.s .use_tos_mxalloc
	move.l #18,-(SP)         // size
	jsr _usb_malloc
	addq.l #4,SP
	move.l (SP)+,D1
	tst.l D0
	beq.s .error_xbra
	move.l D0,A0
	move.l #0x58425241,(A0)+ // XBRA
	move.l D1,(A0)+
	clr.l (A0)+	
	move.w #0x4EF9,(A0)+     // JMP
	move.l A3,(A0)+          // handler
	lea -10(A0),A0
	bsr _flush_dc
	bsr _flush_ic
	bra.s .end_install_xbra
.use_tos_mxalloc:
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) && defined(CONFIG_USB_MEM_NO_CACHE) */
#endif /* defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) */
	move.w #3,-(SP)          // TT ram if possible
	move.l #18,-(SP)         // size
	move.w #0x44,-(SP)       // Mxalloc
	trap #1 
	addq.l #8,SP
	move.l (SP)+,D1
	tst.l D0
	beq.s .error_xbra
	move.l D0,A0
	move.l #0x58425241,(A0)+ // XBRA
	move.l D1,(A0)+
	clr.l (A0)+	
	move.w #0x4EF9,(A0)+     // JMP
	move.l A3,(A0)+          // handler
	lea -10(A0),A0
#ifdef COLDFIRE
	.chip 68060
	cpusha BC
	.chip 5200
#else
	cpusha BC
#endif
.end_install_xbra:
	move.l D3,A1
	move.l (A1),D0
	move.l D0,(A0)+          // old vector
	move.l A0,(A1)           // JMP, new vector
.error_xbra:
	tst.l D0
	movem.l (SP),D1-D3/A0-A3
	lea 28(SP),SP
	rts

#ifdef MCF547X /* FIREBEE */

_check_sd_card:

#ifdef SD_CARD_REPLACE_FLOPPY
	moveq #-1,D0
	move.l D0,_sd_disk_drive
	bsr sd_card_init
	bmi.s .error_found_sd_card
	// Floppy BIOS routines removed
	lea error_loadable(PC),A0
	move.l A0,hdv_boot
	lea error_ok(PC),A0
	move.l A0,hdv_bpb
	lea error_unknow_device(PC),A0
	move.l A0,hdv_rw
	move.l A0,hdv_mediach
	move.l A0,hdv_init
	moveq #1,D0
	rts
.error_found_sd_card:
#endif
	moveq #0,D0              // nothing
	rts

error_loadable:

	moveq #1,D0              // not loadable
	rts

error_unknow_device:

	moveq #-15,D0
	rts

error_ok:

	moveq #0,D0
	rts

_install_sd_card:

	lea -32(SP),SP
	movem.l D1-D4/A0-A3,(SP)
#ifdef SD_CARD_REPLACE_FLOPPY
	moveq #-1,D0
	move.l D0,_sd_disk_drive
#endif
	bsr sd_card_init
	bmi .error_install_sd_card
	moveq #0,D0              // root sector / MBR
	move.l _dskbufp,A0
	bsr sd_card_sector_read
	bmi .error_install_sd_card
	moveq #0,D2
	move.l #256,D1
.loop_sum_root_sd_card:
		moveq #0,D0
		move.w (A0)+,D0
		add.l D0,D2
	subq.l #1,D1
	bgt.s .loop_sum_root_sd_card
	move.l _dskbufp,A0
	and.l #0xFFFF,D2
	cmp.l #0x1234,D2         // checksum
	bne.s .check_partition_dos_sd_card
	lea 0x1C6(A0),A0         // partition table
	moveq #4,D4
.loop_partitions_tos_sd_card:
		move.l (A0),D1
		and.l #0xFFFFFF,D1 // part_type
		beq.s .next_partition_tos_sd_card
		cmp.l #0x58474D,D1 // XGM
		beq.s .next_partition_tos_sd_card
		move.l 4(A0),D2  // part_offset
		move.l 8(A0),D3  // part_size
		bra.s .install_partition_sd_card
.next_partition_tos_sd_card:
		lea 12(A0),A0
	subq.l #1,D4
	bgt.s .loop_partitions_tos_sd_card
	bra.s .error_install_sd_card
.check_partition_dos_sd_card:
	moveq #0,D0
	move.w 510(A0),D0
	cmp.l #0x55AA,D0         // DOS magic
	bne.s .error_install_sd_card
	lea 0x1BE(A0),A0         // partition table
	moveq #4,D4
.loop_partitions_dos_sd_card:
		moveq #0,D1
		move.b 4(A0),D1  // part_type
		beq.s .next_partition_dos_sd_card
		move.l 8(A0),D2  // part_offset
		swap D2
		move.l D2,D0
		asl.l #8,D0
		lsr.l #8,D2
		and.l #0xFF00FF00,D0
		and.l #0x00FF00FF,D2
		or.l D0,D2
		move.l 12(A0),D3 // part_size
		swap D3
		move.l D3,D0
		asl.l #8,D0
		lsr.l #8,D3
		and.l #0xFF00FF00,D0
		and.l #0x00FF00FF,D3
		or.l D0,D3
		bra.s .install_partition_sd_card
.next_partition_dos_sd_card:
		lea 16(A0),A0
	subq.l #1,D4
	bgt.s .loop_partitions_dos_sd_card
.error_install_sd_card:
	moveq #0,D0              // nothing installed
	bra.s .end_install_sd_card
.install_partition_sd_card:
	pea name_sd_card         // product
	pea 0                    // revision      
	pea 0                    // vendor  
	move.l D3,-(SP)          // part_size
	move.l D2,-(SP)          // part_offset
	move.l D1,-(SP)          // part_type	
	clr.l -(SP)              // dev_num
	bsr install_pun_drive
	lea 28(SP),SP
.end_install_sd_card:
	movem.l (SP),D1-D4/A0-A3
	lea 32(SP),SP
	rts

sd_card_init:

	lea -20(SP),SP
	movem.l D1-D3/A0-A1,(SP)
	move.l #MCF_DSPI_DMCR_MSTR+MCF_DSPI_DMCR_CSIS5+MCF_DSPI_DMCR_CSIS3+MCF_DSPI_DMCR_CSIS2+MCF_DSPI_DMCR_CSIS0+MCF_DSPI_DMCR_DTXF+MCF_DSPI_DMCR_DRXF+MCF_DSPI_DMCR_CTXF+MCF_DSPI_DMCR_CRXF,D0
	move.l D0,MCF_DSPI_DMCR   // 8 bit cs off clear fifo
	move.l #MCF_DSPI_DCTARn_TRSZ(7)+MCF_DSPI_DCTARn_PCSSCK_3CLK+MCF_DSPI_DCTARn_PASC_3CLK+MCF_DSPI_DCTARn_PDT_3CLK+MCF_DSPI_DCTARn_PBR_3CLK+MCF_DSPI_DCTARn_CSSCK(8)+MCF_DSPI_DCTARn_ASC(8)+MCF_DSPI_DCTARn_DT(9)+MCF_DSPI_DCTARn_BR(7),D0
	move.l D0,MCF_DSPI_DCTAR0 // 400kHz 
	move.l #MCF_DSPI_DTFR_EOQ+MCF_DSPI_DTFR_CS5+MCF_DSPI_DTFR_TXDATA(0xFF),D0
	move.l D0,MCF_DSPI_DTFR
	moveq #-1,D0
	move.l D0,MCF_DSPI_DSR
	move.l #MCF_DSPI_DMCR_MSTR+MCF_DSPI_DMCR_CSCK+MCF_DSPI_DMCR_CSIS3+MCF_DSPI_DMCR_CSIS2+MCF_DSPI_DMCR_CSIS0+MCF_DSPI_DMCR_DTXF+MCF_DSPI_DMCR_DRXF+MCF_DSPI_DMCR_CTXF+MCF_DSPI_DMCR_CRXF,D0
	move.l D0,MCF_DSPI_DMCR   // clock on cs on
	bsr wait_10ms
	move.l #MCF_DSPI_DMCR_MSTR+MCF_DSPI_DMCR_CSIS5+MCF_DSPI_DMCR_CSIS3+MCF_DSPI_DMCR_CSIS2+MCF_DSPI_DMCR_CSIS0+MCF_DSPI_DMCR_DTXF+MCF_DSPI_DMCR_DRXF+MCF_DSPI_DMCR_CTXF+MCF_DSPI_DMCR_CRXF,D0
	move.l D0,MCF_DSPI_DMCR   // clock off cs off
	moveq #10,D1
.loop_sd_com:
		move.b #0xFF,D0
		bsr sd_com
	subq.l #1,D1
	bgt.s .loop_sd_com
	move.l #MCF_DSPI_DMCR_MSTR+MCF_DSPI_DMCR_CSIS3+MCF_DSPI_DMCR_CSIS2+MCF_DSPI_DMCR_CSIS0+MCF_DSPI_DMCR_DTXF+MCF_DSPI_DMCR_DRXF+MCF_DSPI_DMCR_CTXF+MCF_DSPI_DMCR_CRXF,D0
	move.l D0,MCF_DSPI_DMCR   // cs on
	move.b #0xFF,D0
	bsr sd_com					
	move.b #0xFF,D0
	bsr sd_com
	move.l #MCF_DSPI_DMCR_MSTR+MCF_DSPI_DMCR_CSIS5+MCF_DSPI_DMCR_CSIS3+MCF_DSPI_DMCR_CSIS2+MCF_DSPI_DMCR_CSIS0+MCF_DSPI_DMCR_DTXF+MCF_DSPI_DMCR_DRXF+MCF_DSPI_DMCR_CTXF+MCF_DSPI_DMCR_CRXF,D0
	move.l D0,MCF_DSPI_DMCR   // cs off
	move.b #0xFF,D0
	bsr sd_com
	move.b #0xFF,D0
	bsr sd_com
	bsr wait_10ms
// sd idle
	moveq #10,D3              // retry counter
	moveq #100,D1
.sd_idle:
			bsr sd_card_idle
			moveq #10,D2
.sd_idle2:
				move.b #0xFF,D0
				bsr sd_com
				cmp.l #0x01,D0
				beq.s .idle_end
			subq.l #1,D2
			bgt.s .sd_idle2
		subq.l #1,D1
		bgt.s .sd_idle
		bra .sd_not
.idle_end:
.read_ic:
			move.b #0xFF,D0 // clocks
			bsr sd_com
			moveq #0x48,D0  // cmd 8, SEND_IF_COND
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x01,D0
			bsr sd_com
			move.b #0xAA,D0
			bsr sd_com
			move.b #0x87,D0
			bsr sd_com
			bsr sd_get_status
			cmp.l #5,D0
			beq.s .sd_v1
		cmp.l #1,D0
		bne.s .read_ic
		move.b #0xFF,D0
		bsr sd_com                // 4 bytes
		move.b #0xFF,D0
		bsr sd_com
		move.b #0xFF,D0
		bsr sd_com
		move.b #0xFF,D0
		bsr sd_com
		cmp.l #0xAA,D0            // pattern ?
		bne .sd_testd3
.sd_v1:		// SDHC
.read_ocr:
			move.b #0xFF,D0 // clocks
			bsr sd_com
			moveq #0x7A,D0  // cmd 58, READ_OCR
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x01,D0
			bsr sd_com
			bsr sd_get_status
			// Ver1
		cmp.l #5,D0
		beq.s .read_ocr
		cmp.l #1,D0
		bne.s .read_ocr
		move.b #0xFF,D0
		bsr sd_com                // 4 bytes
		move.b #0xFF,D0
		bsr sd_com
		move.b #0xFF,D0
		bsr sd_com
		move.b #0xFF,D0
		bsr sd_com
		move.l #20000,D1          // timeout
.wait_activity:
			move.b #0xFF,D0 // clocks
			bsr sd_com
			moveq #0x77,D0  // cmd 55, APP_CMD
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			moveq #0x00,D0
			bsr sd_com
			move.b #0x95,D0
			bsr sd_com
			bsr sd_get_status
		cmp.l #0x05,D0
		beq.s .wait_activity
.wait_activity2:
				move.b #0xFF,D0 // clocks
				bsr sd_com
				moveq #0x69,D0  // app cmd 41
				bsr sd_com
				moveq #0x40,D0
				bsr sd_com
				moveq #0x00,D0
				bsr sd_com
				moveq #0x00,D0
				bsr sd_com
				moveq #0x00,D0
				bsr sd_com
				move.b #0x95,D0
				bsr sd_com
				bsr sd_get_status
				tst.l D0
				beq.s .sd_init_ok
			cmp.l #0x05,D0
			beq.s .wait_activity2	
		subq.l #1,D1
		bgt .wait_activity
.sd_testd3:
	subq.l #1,D3 // retry counter
	bgt .sd_idle
	bra .sd_error
.sd_init_ok:
// fullspeed 
	move.l #MCF_DSPI_DCTARn_TRSZ(7)+MCF_DSPI_DCTARn_PCSSCK_3CLK+MCF_DSPI_DCTARn_PASC_3CLK+MCF_DSPI_DCTARn_PDT_3CLK+MCF_DSPI_DCTARn_PBR_3CLK+MCF_DSPI_DCTARn_CSSCK(1)+MCF_DSPI_DCTARn_ASC(1)+MCF_DSPI_DCTARn_DT(2)+MCF_DSPI_DCTARn_BR(0),D0
	move.l D0,MCF_DSPI_DCTAR0 // 22Mbit/sec
read_cid:
	move.b #0xFF,D0           // clocks
	bsr sd_com
	moveq #0x4A,D0            // cmd 10, SEND_CID
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	move.b #0x95,D0
	bsr sd_com
	move.l _dskbufp,A0
	bsr sd_rcv_info
	addq.l #1,A0 // name
	moveq #7,D0
	lea name_sd_card,A1
.sd_name_loop:
		move.b (A0)+,(A1)+
	subq.l #1,D0
	bgt.s .sd_name_loop
	clr.b (A1)
.read_csd:
	move.b #0xFF,D0           // clocks
	bsr sd_com
	move.b #0x49,D0           // cmd 9, SEND_CSD
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x01,D0
	bsr sd_com
	move.l _dskbufp,A0
	bsr sd_rcv_info
	moveq #0,D0
	move.b (A0),D0
	lsr.l #6,D0
	bne.s .sd_csd2            // format v2
	move.l 6(A0),D1
	moveq #14,D0	             // bit 73..62 c_size
	lsr.l D0,D1
	and.l #0xFFF,D1           // 12 bits
	addq.l #1,D1
	move.b 9(A0),D0
	lsr.l #7,D0               // bits 49..47
	and.l #7,D0               // 3 bits
	moveq.l #8,D2             // x256 (dif v1 v2)
	sub.l D0,D2		
	lsr.l D2,D1
	bra.s .sd_return_size
.sd_not:
	moveq #-2,D0
	bra.s .sd_init_end
.sd_error:
	moveq #-1,D0
	bra.s .sd_init_end
.sd_csd2:
	moveq #0,D1
	move.w 8(A0),D1
	addq.l #1,D1
.sd_return_size:
	swap D1
	move.l D1,D0
	lsr.l #6,D0               // x 65636 / 64 -> total sectors
.sd_init_end:
	movem.l (SP),D1-D3/A0-A1
	lea 20(SP),SP
	rts

sd_card_sector_read: // D0.L:sec_nr, A0:buf_addr

	lea -12(SP),SP
	movem.l D1-D2/A0,(SP)
	asl.l #8,D0
	add.l D0,D0               // x 512 !
	move.l D0,D1	             // bytes
	move.l D0,D2
	swap D1
	move.b #0xFF,D0           // clocks
	bsr sd_com	
	moveq #0x51,D0            // cmd 17, READ_SINGLE_BLOCK
	bsr sd_com	
	move.l D1,D0
	lsr.l #8,D0
	bsr sd_com	
	move.b D1,D0
	bsr sd_com
	move.l D2,D0              // bytes
	lsr.l #8,D0
	bsr sd_com	
	move.b D2,D0
	bsr sd_com	
	moveq #0x01,D0
	bsr sd_com
	moveq #0,D1               // status, no error
	bsr sd_get_status
	tst.l D0
	bne.s .sd_csr_end
	bsr sd_rcv_sector         // sector read
.sd_csr_end:
	tst.l D0
	beq.s .sd_csr_ok
	neg.l D1
	move.l D0,D1
.sd_csr_ok:
	move.l D1,D0
	movem.l (SP),D1-D2/A0
	lea 12(SP),SP
	rts

sd_card_sector_write: // D0.L:sec_nr, A0:buf_addr

	lea -12(SP),SP
	movem.l D1-D2/A0,(SP)
	asl.l #8,D0
	add.l D0,D0               // x 512 !
	move.l D0,D1	             // bytes
	move.l D0,D2
	swap D1
	move.b #0xFF,D0           // clocks
	bsr sd_com	
	moveq #0x58,D0            // cmd 24, WRITE_SINGLE_BLOCK
	bsr sd_com	
	move.l D1,D0
	lsr.l #8,D0
	bsr sd_com	
	move.b D1,D0
	bsr sd_com
	move.l D2,D0              // bytes
	lsr.l #8,D0
	bsr sd_com	
	move.b D2,D0
	bsr sd_com	
	moveq #0x01,D0
	bsr sd_com
	moveq #0,D1               // status, no error
	bsr sd_get_status
	tst.l D0
	bne.s .sd_csw_end
	bsr sd_send_sector        // sector write
.sd_csw_end:
	tst.l D0
	beq.s .sd_csw_ok
	neg.l D1
	move.l D0,D1
.sd_csw_ok:
	move.l D1,D0
	movem.l (SP),D1-D2/A0
	lea 12(SP),SP
	rts

sd_card_idle:

	move.l #MCF_DSPI_DCTARn_TRSZ(8-1)+MCF_DSPI_DCTARn_PCSSCK_3CLK+MCF_DSPI_DCTARn_PASC_3CLK+MCF_DSPI_DCTARn_PDT_3CLK+MCF_DSPI_DCTARn_PBR_3CLK+MCF_DSPI_DCTARn_CSSCK(8)+MCF_DSPI_DCTARn_ASC(8)+MCF_DSPI_DCTARn_DT(9)+MCF_DSPI_DCTARn_BR(7),D0
	move.l D0,MCF_DSPI_DCTAR0	// 400kHz 
	move.b #0xFF,D0
	bsr sd_com                // clocks 
	moveq #0x40,D0            // cmd 0, GO_IDLE_STATE
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	moveq #0x00,D0
	bsr sd_com
	move.b #0x95,D0
	bsr sd_com
	rts

sd_rcv_sector: // 1 sector data to A0 pointer

	move.l A0,-(SP)
	move.l D1,-(SP)
	bsr sd_get_status 
	cmp.l #0xFE,D0
	bne .sd_rs_end // error
	move.l #512,D1
.sd_rs_loop:
		move.b #0xFF,D0
		bsr sd_com
		move.b D0,(A0)+
	subq.l #1,D1
	bgt.s .sd_rs_loop
	// crc
	move.b #0xFF,D0
	bsr sd_com
	move.b #0xFF,D0
	bsr sd_com
	moveq #0,D0 // all ok
.sd_rs_end:
	move.l (SP)+,D1
	move.l (SP)+,A0
	tst.l D0
	rts

sd_send_sector: // 1 sector data to A0 pointer

	move.l A0,-(SP)
	move.l D1,-(SP)
	move.l #512,D1		
	move.b #0xFE,D0 // start token
	bsr sd_com // send
.sd_send_wr_wb:
		move.b (A0)+,D0 // data
		bsr sd_com   // send
	subq.l #1,D1
	bgt.s .sd_send_wr_wb	
// send crc
	moveq #0x01,D0			
	bsr sd_com                // crc 1st byte
	moveq #0x01,D0			
	bsr sd_com                // crc 2nd byte
	bsr sd_get_status
	and.l #0x1F,D0
	moveq #0,D1               // status, no error
	cmp.l #5,D0               // data accepted ?
	beq.s .sd_send_end        // OK
	move.l D0,D1              // status
.sd_send_end:
		move.b #0xFF,D0
		bsr sd_com
	tst.l D0
	beq.s .sd_send_end
	move.l D1,D0 // status
	move.l (SP)+,D1
	move.l (SP)+,A0
	rts

sd_rcv_info: // A0: data

	lea -12(SP),SP
	movem.l D0-D1/A0,(SP)
	moveq #18,D1             // 16 bytes + 2 bytes crc
.sd_rcv_rb_w:		
			move.b #0xFF,D0
			bsr sd_get_status 
		cmp.l #0xFE,D0
		bne.s .sd_rcv_rb_w
.sd_rcv_rd_rb:
		move.b #0xFF,D0
		bsr sd_com
		move.b D0,(A0)+
	subq.l #1,D1
	bgt.s .sd_rcv_rd_rb
	movem.l (SP),D0-D1/A0
	lea 12(SP),SP
	rts

sd_get_status:

		move.b #0xFF,D0
		bsr sd_com
	cmp.l #0xFF,D0
	beq.s sd_get_status
	rts

sd_com:

	and.l #MCF_DSPI_DTFR_TXDATA(0xFF),D0 // 8 bits data
	or.l #MCF_DSPI_DTFR_EOQ+MCF_DSPI_DTFR_CS5,D0
	move.l D0,MCF_DSPI_DTFR  // TX fifo
.wait_complete:
		move.l MCF_DSPI_DSR,D0
#if 1
	bpl.s .wait_complete
#else
	and.l #MCF_DSPI_DSR_TCF,D0
	beq.s .wait_complete
#endif
	move.l MCF_DSPI_DRFR,-(SP) // RX fifo
	moveq #-1,D0
	move.l D0,MCF_DSPI_DSR   // clear status register
	move.l (SP)+,D0
	and.l #MCF_DSPI_DRFR_RXDATA(0xFF),D0 // 8 bits data
	rts

wait_10ms:

 	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l MCF_SLT_SCNT1,D1
.wait_10ms_loop:
		move.l D1,D0
		sub.l MCF_SLT_SCNT1,D0
	cmp.l #10000*SYSTEM_CLOCK,D0
	bcs.s .wait_10ms_loop
	move.l (SP)+,D0
	move.l (SP)+,D1
	rts

#endif /* MCF547X */

#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)

_install_usb_stor:

	lea -32(SP),SP
	movem.l D1-D4/A0-A3,(SP)
	move.l 36(SP),D0         // dev_num
	cmp.l #PUN_DEV,D0
	bhi .error_usb_install   // error
	or.l #PUN_USB,D0
	movem.l 40(SP),D1-D3     // part_type, part_offset, part_size
	movem.l 52(SP),A1/A2/A3  // vendor / revision / product
	move.l A3,-(SP)          // product
	move.l A2,-(SP)          // revision      
	move.l A1,-(SP)          // vendor  
	move.l D3,-(SP)          // part_size
	move.l D2,-(SP)          // part_offset
	move.l D1,-(SP)          // part_type	
	move.l D0,-(SP)          // dev_num
	bsr install_pun_drive
	lea 28(SP),SP
	bra.s .end_usb_install
.error_usb_install:
	moveq #0,D0              // not installed
.end_usb_install:
	movem.l (SP),D1-D4/A0-A3
	lea 32(SP),SP
	rts

_uninstall_usb_stor:

	lea -24(SP),SP
	movem.l D0-D3/A0-A1,(SP)
	move.l 28(SP),D0         // dev_num
	cmp.l #PUN_DEV,D0
	bhi.s .error_usb_uninstall   // error
	move.l _usb_1st_disk_drive,D2
	beq.s .error_usb_uninstall
	or.l #PUN_USB,D0
	move.l pun_ptr,A1
.loop_uninstall_usb_part:
		moveq #0,D1
		move.b pinfo_pun(A1,D2.l),D1
		cmp.l D1,D0
		bne.s .not_this_usb_devnum
		move.w pinfo_puns(A1),D1
		subq.l #1,D1
		move.w D1,pinfo_puns(A1)
		moveq #-1,D1
		move.b D1,pinfo_pun(A1,D2.l)
		clr.l pinfo_pstart(A1,D2.l*4)
		lea pinfo_psize(A1),A0
		clr.l (A0,D2.l*4) 
		move.l _drvbits,D1
		bclr D2,D1
		move.l D1,_drvbits
.not_this_usb_devnum:
		addq.l #1,D2
	cmp.l #MAX_LOGICAL_DRIVE,D2
	bcs.s .loop_uninstall_usb_part
.error_usb_uninstall:
	movem.l (SP),D0-D3/A0-A1
	lea 24(SP),SP
	rts

#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */

#if ((defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)) || defined(MCF547X)

install_pun_drive:

	lea -32(SP),SP
	movem.l D1-D4/A0-A3,(SP)
	move.l pun_ptr,D0
	bne.s .pinfo_ok
	move.w #3,-(SP)          // TT ram if possible
	move.l #pinfo_size,-(SP)
	move.w #0x44,-(SP)       // Mxalloc
	trap #1 
	addq.l #8,SP
	move.l D0,pun_ptr
	beq.s .no_pinfo
	move.l D0,A3
	clr.w pinfo_puns(A3)
	lea pinfo_pun(A3),A0
	moveq #-1,D0
	move.w D0,(A0)+          // drives A/B
	move.l D0,(A0)+
	move.l D0,(A0)+
	move.l D0,(A0)+
	move.w D0,(A0)
	lea pinfo_pstart(A3),A0
	lea pinfo_size(A3),A1
.clrpun:
		clr.w -(A1)
	cmp.l A0,A1
	bgt.s .clrpun
	lea pinfo_cookie(A3),A0
	move.l #0x41484449,(A0)  // AHDI
	move.l A0,4(A0)
	move.w #0x0300,D0
	move.w D0,pinfo_vernum(A3)
	move.w #0x4000,D0
	move.w D0,pinfo_maxsiz(A3)
	move.l A3,D0             // pun_ptr
.pinfo_ok:
	move.l D0,A3             // pun_ptr
#if defined(MCF547X) && defined(SD_CARD_REPLACE_FLOPPY)
	move.l 36(SP),D2         // dev_num
	moveq #PUN_USB,D0
	and.l D2,D0
	bne.s .usb_pun
	moveq #0,D4              // drive A
	bra.s .drive_not_exist_usb
.usb_pun:	
#endif /* defined(MCF547X) && defined(SD_CARD_REPLACE_FLOPPY) */
	move.l _drvbits,D0
	moveq #2,D4              // drive C
.search_empty_drive_usb:
		btst D4,D0
		beq.s .drive_not_exist_usb
		addq.l #1,D4
	cmp.l #MAX_LOGICAL_DRIVE,D4
	bcs.s .search_empty_drive_usb
	bra .drive_full_usb      // all drives already used
.no_pinfo:
	moveq #0,D0              // not installed
	bra .end_usb_disk
.drive_not_exist_usb:
	move.w pinfo_puns(A3),D0
	addq.l #1,D0
	move.w D0,pinfo_puns(A3)
	moveq #0,D0
	bset #7,D0               // changed
	lea pinfo_flags(A3),A0
	move.l D0,(A0,D4.l*4)    // B15:swap, B7:change, B0:bootable
	lea pinfo_psize(A3),A0
	move.l 48(SP),D3         // part_size
	move.l 44(SP),D1         // part_offset
	move.l 40(SP),D2         // part_type
	move.l 36(SP),D0         // dev_num
	move.l D2,pinfo_ptype(A3,D4.l*4)
	and.l #0xFFFFFF,D2       // ID
	// GEMDOS
	cmp.l #0x47454D,D2       // GEM up to 16M
	beq.s .check_size
	cmp.l #0x42474D,D2       // BGM over 16M
	beq.s .check_size
	// DOS 1:FAT12, 0xB/0xC:FAT32
	cmp.l #0x4,D2            // FAT16 up to 32M
	beq.s .check_size
	cmp.l #0x6,D2            // FAT16 over 32M
	beq.s .check_size
	cmp.l #0xE,D2            // WIN95 FAT16
	bne.s .no_limit_size
.check_size:
	cmp.l #0x400000,D3
	bcs.s .no_limit_size
	move.l #0x400000,D3      // 2GB limit
.no_limit_size:
	move.l D0,D2
	move.b D2,pinfo_pun(A3,D4.l)
	move.l D3,(A0,D4.l*4)    // size
	move.l D1,pinfo_pstart(A3,D4.l*4)
	move.l _dskbufp,A0 
#ifdef MCF547X
	moveq #PUN_USB,D0
	and.l D2,D0
	beq.s .not_usb_pun
#endif
	move.l A0,-(SP)          // buffer
	move.l #1,-(SP)          // blkcnt	
	move.l D1,-(SP)          // blknr
	moveq #PUN_DEV,D0
	and.l D2,D0
	move.l D0,-(SP)          // devnum
	jsr _usb_stor_read
	lea 16(SP),SP
	tst.l D0
	ble .end_usb_disk        // read error
#ifdef MCF547X
	move.l _sd_disk_drive,D0
#ifdef SD_CARD_REPLACE_FLOPPY
	addq.l #1,D0
#endif
	or.l _usb_1st_disk_drive,D0
#else /* !MCF547X */
	tst.l _usb_1st_disk_drive
#endif /* MCF547X */
	bne .usb_1st_drive_ok    // hdv vectors installed
#ifdef MCF547X
	bra.s .install_hdv_xbra
.not_usb_pun:                                        
	move.l D1,D0             // sector number
	move.l _dskbufp,A0
	bsr sd_card_sector_read  // read boot sector
	bmi .end_usb_disk        // read error
	move.l _sd_disk_drive,D0
#ifdef SD_CARD_REPLACE_FLOPPY
	addq.l #1,D0
#endif
	move.l D4,_sd_disk_drive
	or.l _usb_1st_disk_drive,D0
	bne .sd_1st_drive_ok    // hdv vectors installed
.install_hdv_xbra:
#endif /* MCF547X */
	move.w SR,D0
	move.w D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	move.l #0x5F555342,D1    // _USB
	lea det_hdv_bpb_usb(PC),A0
	move.w #hdv_bpb,D0
	bsr install_xbra
	move.l D0,old_hdv_bpb_usb
	lea det_hdv_rw_usb(PC),A0
	move.w #hdv_rw,D0
	bsr install_xbra
	move.l D0,old_hdv_rw_usb
	lea det_hdv_mediach_usb(PC),A0
	move.w #hdv_mediach,D0
	bsr install_xbra
	move.l D0,old_hdv_mediach_usb
	move.l cookie,D0
	beq.s .no_cookie_jar
	move.l D0,A0
	move.l #0x58484449,D1    // XHDI
.find_cookie_jar:
		tst.l (A0)
		beq.s .cookie_slot_free
		cmp.l (A0),D1
		beq.s .cookie_found
		addq.l #8,A0
	bra.s .find_cookie_jar
.cookie_found:
	move.l A0,-(SP)
	move.l 4(A0),D0
	move.l D0,old_xhdi
	clr.l -(SP)              // XHGetVersion
	move.l D0,A0
	jsr (A0)
	addq.l #4,SP
	move.l D0,old_xhdi_version
	lea xhdi(PC),A1
	move.l A1,-(SP)			
	move.w #9,-(SP)          // XHNewCookie
	move.l old_xhdi,A0
	jsr (A0)
	add.l #2,SP
	move.l (SP)+,A1
	move.l (SP)+,A0
	tst.l D0
	beq.s .no_cookie_jar
	move.l A1,4(A0)          // replace cookie			
	bra.s .no_cookie_jar
.cookie_slot_free:
	move.l 4(A0),12(A0)      // copy size
	move.l #0x58484449,(A0)+ // XHDI new cookie name
	lea xhdi(PC),A1
	move.l A1,(A0)+          // cookie data
	clr.l (A0)               // end (size is already copied after)
	clr.l old_xhdi
	clr.l old_xhdi_version   //  protocol version
.no_cookie_jar:
	move.w (SP)+,D0
	move.w D0,SR
.usb_1st_drive_ok:
	tst.l _usb_1st_disk_drive
	bne.s .sd_1st_drive_ok
	move.l D4,_usb_1st_disk_drive
.sd_1st_drive_ok:
	move.l _dskbufp,A0       // boot sector
	lea pinfo_bpb(A3),A1
	move.l D4,D2             // logical drive
	mulu #18,D2              // * 18
	add.l D2,A1
	move.l pinfo_ptype(A3,D4.l*4),D2 // part_type
	move.l D2,D1
	and.l #0xFFFFFF,D1       // ID
	// GEMDOS
	cmp.l #0x47454D,D1       // GEM up to 16M
	beq.s .partition_ok
	cmp.l #0x42474D,D1       // BGM over 16M
	beq.s .partition_ok
	// DOS 1:FAT12, 0xB/0xC:FAT32
	cmp.l #0x4,D2            // FAT16 up to 32M
	beq.s .partition_ok
	cmp.l #0x6,D2            // FAT16 over 32M
	beq.s .partition_ok
	cmp.l #0xE,D2            // WIN95 FAT16
	bne .no_bpb
.partition_ok:
	moveq #0,D2
	move.b 0xC(A0),D2
	asl.l #8,D2
	move.b 0xB(A0),D2        // BPS
	move.w D2,(A1)           // sector size in bytes
	beq .no_bpb
	moveq #0,D1
	move.b 0xD(A0),D1        // SPC
	move.w D1,2(A1)          // cluster size in sectors
	move.w D1,D0
	mulu D2,D0
	move.w D0,4(A1)          // cluster size in bytes
	moveq #0,D0
	move.b 0x12(A0),D0
	asl.l #8,D0
	move.b 0x11(A0),D0       // NDIRS
	asl.l #5,D0              // * 32
	tst.l D2
	beq.s .no_dirs
#ifdef COLDFIRE
	.chip 68060
#endif
	divu D2,D0               // / sector size
#ifdef COLDFIRE
	.chip 5200
#endif
.no_dirs:
	move.w D0,6(A1)          // size directory in sectors
	moveq #0,D2
	move.b 0x17(A0),D2
	asl.l #8,D2
	move.b 0x16(A0),D2       // SPF
	move.w D2,8(A1)          // FAT size
	moveq #0,D0
	move.b 0xF(A0),D0
	asl.l #8,D0
	move.b 0xE(A0),D0        // RES
	move.l D0,D3
	add.l D2,D3              // + FAT size
	move.w D3,10(A1)         // 1st sector of FAT2 
	moveq #0,D3
	move.b 0x10(A0),D3       // NFATS
	mulu D2,D3               // * FAT size
	add.l D0,D3              // + RES
	moveq #0,D0
	move.w 6(A1),D0          // size directory in sectors
	add.l D3,D0
	move.w D0,12(A1)         // 1st data sector
	moveq #0,D2
	move.b 0x14(A0),D2
	asl.l #8,D2
	move.b 0x13(A0),D2       // NSECTS
	bne.s .nsects_ok_usb
	lea pinfo_psize(A3),A2
	move.l (A2,D4.l*4),D2    // partition size in sectors
	sub.l D0,D2              // - 1st data sector
.nsects_ok_usb:
	tst.l D1
	beq.s .no_cluster_size
#ifdef COLDFIRE
	.chip 68060
#endif
	divu D1,D2
#ifdef COLDFIRE
	.chip 5200
#endif
.no_cluster_size:
	move.w D2,14(A1)         // total clusters
	moveq #1,D0
	move.w D0,16(A1)         // FAT 16
	bra.s .end_bpb
.no_bpb:
	clr.w (A1)
	clr.l 2(A1)
	clr.l 6(A1)
	clr.l 10(A1)
	clr.l 14(A1)
.end_bpb:
	move.l _drvbits,D0
	bset D4,D0
	move.l D0,_drvbits
	moveq #2,D0              // drive C
	cmp.l D4,D0
	bne.s .no_set_drive_usb
	move.w D0,_bootdev
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
	move.l _pxCurrentTCB,D1
	cmp.l _tid_TOS,D1
	bne.s .no_set_drive_usb
#endif
	move.w D0,-(SP)
	move.w #0xE,-(SP)        // Dsetdrv
	trap #1
	addq.l #4,SP
.no_set_drive_usb:
	move.l D4,D1             // logical drive
	move.l pinfo_ptype(A3,D4.l*4),D2 // part_type
	lea pinfo_psize(A3),A0
	move.l (A0,D4.l*4),D3    // partition size in sectors
	moveq #PUN_USB+PUN_DEV,D0
	and.l 36(SP),D0          // devnum
	movem.l 52(SP),A1/A2/A3  // vendor / revision / product
	lea product_name,A0      // save product name pointer for XHDI
	move.l A3,(A0,D0.l*4)
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
	move.l _pxCurrentTCB,D0
	cmp.l _tid_TOS,D0
	bne.s .no_display_drive_usb
#endif
	move.l 36(SP),D0         // devnum
	bsr display_drive_usb
.no_display_drive_usb:
	move.l D4,D0             // OK
	bra.s .end_usb_disk
.invalid_partition_type:
	pea error4(PC)
	bra.s .display_error_usb
.drive_full_usb:
	pea error2(PC)
.display_error_usb:
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
	move.l _pxCurrentTCB,D0
	cmp.l _tid_TOS,D0
	bne.s .no_display_error_usb
#endif
	move.l 36+4(SP),D0       // devnum 
	movem.l 52+4(SP),A1/A2/A3// vendor / revision / product
	bsr display_drive_usb
	move.w #0x2C,-(SP)
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	move.w #0x20,-(SP)
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #2,SP
.no_display_error_usb:	
	addq.l #4,SP
	moveq #0,D0              // not installed
.end_usb_disk:
	movem.l (SP),D1-D4/A0-A3
	lea 32(SP),SP
.return:
	rts

display_drive_usb:

	link A6,#-16
	add.l #0x41,D1
	move.w D1,-(SP)          // logical drive
	move.l A1,-(SP)          // vendor
	moveq #0x30,D1
	or.l D0,D1	            // device number
	move.w D1,-(SP)         
	lea blue(PC),A0
	moveq #PUN_USB,D1
	and.l D0,D1
	bne.s .display_usb
	pea message3(PC)         // SD-disk installed
	bra.s .display_color
.display_usb:
	pea message2(PC)         // USB-disk installed
.display_color:
	bsr text_color
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	move.w #0x2E,-(SP)       // .
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	move.w #0x30,-(SP)       // 0
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	lea black(PC),A0
	bsr text_color
	tst.l (SP)               // vendor
	beq.s .no_vendor
	move.w #0x20,-(SP)
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #2,SP
.no_vendor:
	addq.l #4,SP
	move.l A2,D0
	beq.s .no_revision
	move.w #0x20,-(SP)
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	move.l A2,-(SP)          // revision
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
.no_revision:
	move.w #0x20,-(SP)
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	move.l A3,-(SP)          // product
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	pea message4(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	pea message5(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	cmp.l #0xFF,D2           // part_type
	bhi.s .gem_part
	move.l #16,-(SP)
	move.l D2,-(SP)
	pea -16(A6)
	jsr _ltoa
	lea 12(SP),SP
	bra.s .size_part
.gem_part:
	move.l D2,D0
	asl.l #8,D0
	move.l D0,-16(A6)
.size_part:
	pea -16(A6)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP	
	pea message6(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	add.l #1024,D3	
	moveq #11,D0
	lsr.l D0,D3              // sector size / 1024*2 => MB
	move.l #10,-(SP)
	move.l D3,-(SP)
	pea -16(A6)
	jsr _ltoa
	lea 12(SP),SP
	pea -16(A6)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP	
	pea message7(PC)         // MB
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP	
	unlk A6
	rts

det_hdv_bpb_usb:

	move.l A0,-(SP)
	move.l pun_ptr,A0
 	moveq #0,D0
	move.w 4+4(SP),D0        // drive
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .dhbu5
#else
	beq.s .dhbu5
#endif
	cmp.l _sd_disk_drive,D0
	beq.s .dhbu4
.dhbu5:
#endif
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .dhbu2             // error
	cmp.l _usb_1st_disk_drive,D0
	bcs.s .dhbu2
	cmp.l #MAX_LOGICAL_DRIVE,D0
	bcs.s .dhbu4
#endif
	bra.s .dhbu2             // error
.dhbu4:
	tst.b pinfo_pun(A0,D0.l)
	bpl.s .dhbu1
.dhbu2:
	move.l (SP)+,A0
	moveq #0,D0
	move.l old_hdv_bpb_usb,-(SP)
	rts
.dhbu1:
	move.l D1,-(SP)
	move.l pinfo_ptype(A0,D0.l*4),D1
	// from ROOT sector
	cmp.l #0x47454D,D1       // GEM
	beq.s .dhbu3
	cmp.l #0x42474D,D1       // BGM
	beq.s .dhbu3
	// from MBR
	cmp.l #0x4,D1            // FAT16 up to 32M
	beq.s .dhbu3
	cmp.l #0x6,D1            // FAT16 over 32M
	beq.s .dhbu3
	cmp.l #0xE,D1            // WIN95 FAT16
	beq.s .dhbu3
.dhbu6:
	move.l (SP)+,D1
	move.l (SP)+,A0
	moveq #0,D0              // not for TOS
	rts
.dhbu3:
	lea pinfo_bpb(A0),A0
	mulu #18,D0              // * 18
	add.l A0,D0
	move.l D0,A0
	tst.w (A0)               // sector size
	beq.s .dhbu6
#ifdef DEBUG
	move.l D0,-(SP)
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.l (SP),D0
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	lea debug4(PC),A0
	jsr display_string
	move.l (SP)+,D0
#endif
	move.l (SP)+,D1
	move.l (SP)+,A0
	rts

det_hdv_rw_usb:

	lea -28(SP),SP
	movem.l D1-D4/A0-A2,(SP)
	btst #3,5+28(SP)         // rwflag
	bne.s .dhru8             // physical
	move.l pun_ptr,A0
 	moveq #0,D0
	move.w 14+28(SP),D0      // drive
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .dhru17
#else
	beq.s .dhru17
#endif
	cmp.l _sd_disk_drive,D0
	beq.s .dhru9
.dhru17:
#endif
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .dhru8             // error
	cmp.l _usb_1st_disk_drive,D0
	bcs.s .dhru8
	cmp.l #MAX_LOGICAL_DRIVE,D0
	bcs.s .dhru9
#endif
	bra.s .dhru8             // error
.dhru9:
	moveq #0,D4
	move.b pinfo_pun(A0,D0.l),D4
	bpl.s .dhru1             // valid
.dhru8:
	movem.l (SP),D1-D4/A0-A2
	lea 28(SP),SP
	moveq #0,D0
	move.l old_hdv_rw_usb,-(SP)
	rts
.dhru1:
#ifdef DEBUG
	move.l D0,-(SP)
	move.l A0,-(SP)
	lea debug3(PC),A0
	jsr display_string	
	move.w 4+28+8(SP),D0     // rwflag
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.l 6+28+8(SP),D0     // buffer
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 10+28+8(SP),D0    // num sectors
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 12+28+8(SP),D0    // logical sector
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 14+28+8(SP),D0    // drive
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
	move.l (SP)+,A0
	move.l (SP)+,D0
#endif
#ifdef MCF547X
	move.l D4,D2
	beq.s .dhru10
#endif	
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l D4,D2
	and.l #PUN_USB,D2
	bne.s .dhru10
#endif
	bra .dhru8               // error
.dhru10:
	moveq #0,D2
	move.w 12+28(SP),D2      // logical sector
	bpl.s .dhru6
	move.l 16+28(SP),D2      // logical sector	
.dhru6:
	tst.l D2
	bmi .dhru2               // negative logical sector
	move.l 6+28(SP),D1       // buffer
	beq .dhru4               // no buffer
	move.l pinfo_pstart(A0,D0.l*4),D3
	lea pinfo_bpb(A0),A0
	mulu #18,D0              // * 18
	add.l D0,A0
	move.w 14(A0),D0         // total clusters
	mulu.w 2(A0),D0          // cluster size in sectors
	cmp.l D0,D2              // logical sector to hight
	bcc .dhru2
	moveq #0,D0
	move.w (A0),D0           // sector size
	lsr.l #8,D0
	lsr.l #1,D0              // / 512
	move.l D1,A0             // buffer
	move.w 10+28(SP),D1      // num sectors
	beq .dhru4               // no sectors
	mulu D0,D1
	mulu.l D0,D2
	add.l D3,D2              // start sector
	move.l D1,D3             // count
	btst #0,5+28(SP)         // rwflag
	beq.s .dhru7             // read
	// write
	tst.l D2                 // logical sector
	beq.s .dhru2             // root sector
#ifdef MCF547X
	moveq #PUN_USB,D0
	and.l D4,D0
	bne.s .dhru14            // USB
	move.l A0,A2
.dhru11:
		move.l D2,D0  // sector number
		move.l A2,A0
		bsr sd_card_sector_write
		bmi.s .dhru2  // error
#if 0 // #ifdef DEBUG
		move.l A2,A1
		bsr dump
#endif
#ifdef SD_CARD_VERIFY
		move.l D2,D0  // sector number
		lea sd_buffer_verify,A0
		bsr sd_card_sector_read
		bmi.s .dhru2  // error
		move.l A2,A0
		lea sd_buffer_verify,A1
		move.l #512/4,D1
.dhru15:
			move.l (A0)+,D0
			cmp.l (A1)+,D0
			bne.s .dhru16 // error
		subq.l #1,D1
		bgt.s .dhru15
#endif /* SD_CARD_VERIFY */
		addq.l #1,D2  // sector number
		add.l #512,A2 // buffer
	subq.l #1,D3             // blkcnt
	bgt.s .dhru11
	bra.s .dhru4             // OK
#ifdef SD_CARD_VERIFY
.dhru16:
	moveq #-4,D0             // CRC error
	bra.s .dhru3
#endif
.dhru14:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l A0,-(SP)          // buffer
	move.l D3,-(SP)          // blkcnt	
	move.l D2,-(SP)          // blknr
	moveq #PUN_DEV,D0
	and.l D4,D0
	move.l D0,-(SP)          // devnum
	jsr _usb_stor_write
	bra.s .dhru5
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
.dhru2:
	moveq #-1,D0             // error
	bra.s .dhru3
.dhru4:
	moveq #0,D0              // OK
	bra.s .dhru3
.dhru7:
#ifdef MCF547X
	moveq #PUN_USB,D0
	and.l D4,D0
	bne.s .dhru12            // USB
.dhru13:
		move.l D2,D0  // sector number
		bsr sd_card_sector_read
		bmi.s .dhru2  // error
#if 0 // #ifdef DEBUG
		move.l A0,A1
		bsr dump
#endif
		addq.l #1,D2  // sector number
		add.l #512,A0 // buffer
	subq.l #1,D3             // blkcnt
	bgt.s .dhru13
	bra.s .dhru4             // OK
.dhru12:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l A0,-(SP)          // buffer
	move.l D3,-(SP)          // blkcnt	
	move.l D2,-(SP)          // blknr
	moveq #PUN_DEV,D0
	and.l D4,D0
	move.l D0,-(SP)          // devnum
	jsr _usb_stor_read
.dhru5:
	lea 16(SP),SP
 	tst.l D0
	bmi.s .dhru3             // error
	moveq #0,D0
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
.dhru3:
	movem.l (SP),D1-D4/A0-A2
	lea 28(SP),SP
 	rts

det_hdv_mediach_usb:

	move.l A0,-(SP)
	move.l pun_ptr,A0
 	moveq #0,D0
	move.w 4+4(SP),D0        // drive
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .dhmu4
#else
	beq.s .dhmu4
#endif
	cmp.l _sd_disk_drive,D0
	beq.s .dhmu3
.dhmu4:
#endif
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .dhmu2             // error
	cmp.l _usb_1st_disk_drive,D0
	bcs.s .dhmu2
	cmp.l #MAX_LOGICAL_DRIVE,D0
	bcs.s .dhmu3
#endif
	bra.s .dhmu2             // error
.dhmu3:
	tst.b pinfo_pun(A0,D0.l)
	bpl.s .dhmu1
.dhmu2:
	move.l (SP)+,A0
	moveq #0,D0
	move.l old_hdv_mediach_usb,-(SP)
	rts
.dhmu1:
#if 0 // #ifdef DEBUG
	move.l A0,-(SP)
	lea debug5(PC),A0
	jsr display_string
	move.l (SP)+,A0
#endif
	lea pinfo_flags(A0),A0
	add.l D0,A0
	add.l D0,A0
	bclr #7,1(A0)
	sne.b D0
	and.l #2,D0
	move.l (SP)+,A0
	rts

	// XHDI
	
	dc.l 0x27011992
	
xhdi:

	link A6,#0
#ifdef COLDFIRE
	lea -52(SP),SP
	movem.l D1-A5,(SP)
#else
	movem.l D1-A5,-(SP)
#endif
	moveq #0,D1
	move.w 8(A6),D1
	moveq #-32,D0            // invalid function
	cmp.l #18,D1
	bcc.s .default_xhdi
	move.w SR,D0             // supervisor only
	moveq #-1,D0             // error
	move.w tab_xhdi(PC,D1.l*2),D1
	bmi.s .default_xhdi
	jsr tab_xhdi(PC,D1.l)
#ifdef DEBUG_XHDI
	move.l D0,-(SP)
	lea debug130(PC),A0
	jsr display_string
	move.l (SP),D0
	jsr hex_long
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
	move.l (SP)+,D0
#endif
	cmp.l #0xBAD0CA11,D0     // key word BAD CALL =>  call old_xhdi handler
	beq.s .default_xhdi
#ifdef COLDFIRE
	movem.l (SP),D1-A5
	lea 52(SP),SP
#else
	movem.l (SP)+,D1-A5
#endif
	unlk A6
	rts
.default_xhdi:
#ifdef COLDFIRE
	movem.l (SP),D1-A5
	lea 52(SP),SP
#else
	movem.l (SP)+,D1-A5
#endif
	unlk A6
	tst.l old_xhdi
	beq.s .no_old_xhdi
	move.l old_xhdi,-(SP)    // parameters are on the stack
.no_old_xhdi:
	rts 

tab_xhdi:
	dc.w XHGetVersion-tab_xhdi    // 0
	dc.w XHInqTarget-tab_xhdi     // 1
	dc.w XHReserve-tab_xhdi       // 2
	dc.w XHLock-tab_xhdi          // 3
	dc.w XHStop-tab_xhdi          // 4
	dc.w XHEject-tab_xhdi         // 5
	dc.w XHDrvMap-tab_xhdi        // 6
	dc.w XHInqDev-tab_xhdi        // 7
	dc.w XHInqDriver-tab_xhdi     // 8
	dc.w XHNewCookie-tab_xhdi     // 9
	dc.w XHReadWrite-tab_xhdi     // 10
	dc.w XHInqTarget2-tab_xhdi    // 11
	dc.w XHInqDev2-tab_xhdi       // 12
	dc.w XHDriverSpecial-tab_xhdi // 13
	dc.w XHGetCapacity-tab_xhdi   // 14
	dc.w XHMediumChanged-tab_xhdi // 15
	dc.w XHMiNTInfo-tab_xhdi      // 16
	dc.w XHDOSLimits-tab_xhdi     // 17
	
XHGetVersion:

#ifdef DEBUG_XHDI
	move.l A0,-(SP)
	lea debug138(PC),A0
	jsr display_string
	move.l (SP)+,A0
#endif
	move.l #0x120,D0         //  protocol version
	move.l old_xhdi_version,D1
	beq.s .xv1
	cmp.l D1,D0
	bcs.s .xv1
	move.l D1,D0             // minimum version
.xv1:	
	rts
	
XHInqTarget:

#ifdef DEBUG_XHDI
	lea debug133(PC),A0
	jsr display_string
#endif
	moveq #32,D2             // stringlen
	bra.s .xi1
	
XHInqTarget2:

#ifdef DEBUG_XHDI
	lea debug133a(PC),A0
	jsr display_string
#endif
	move.l 26(A6),D2         // stringlen
.xi1:
#ifdef DEBUG_XHDI
	move.w 10(A6),D0         // major
	jsr hex_word
	lea debug139(PC),A0
	jsr display_string	
	move.w 12(A6),D0         // minor
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	tst.w 12(A6)             // minor
	bne.s .xi2
	moveq #0,D0
	move.w 10(A6),D0         // major
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .xi10
#else
	beq.s .xi10
#endif
	tst.l D0
	beq.s .xi3               // OK
.xi10:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .xi2               // error
	cmp.l #PUN_USB,D0
	bcs.s .xi2
	cmp.l #PUN_USB+PUN_DEV,D0
	bls.s .xi3               // OK
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
.xi2:
	tst.l old_xhdi
	bne.s .xi7
	moveq #-15,D0            // unknown device
	rts
.xi7:
	move.l #0xBAD0CA11,D0
	rts
.xi3:
	move.l 14(A6),D1
	beq.s .xi8
	move.l D1,A0             // blocksize
	move.l #512,(A0)
.xi8:
	move.l 18(A6),D1
	beq.s .xi9
	move.l D1,A0             // device_flags
//	move.l #2,(A0)           // removable
	clr.l (A0)
.xi9:
	move.l 22(A6),D1         // product_name
	beq.s .xi6
	move.l D1,A0
	clr.b (A0)
	and.l #PUN_USB+PUN_DEV,D0
	lea product_name,A1
	move.l (A1,D0.l*4),D0
	beq.s .xi6               // no pointer
	move.l D0,A1
.xi5:
		move.b (A1)+,(A0)+
		beq.s .xi4
	subq.l #1,D2
	bgt.s .xi5
.xi4:
	clr.b -1(A0)
.xi6:
	moveq #0,D0
	rts

XHReserve:
XHLock:
XHStop:
XHEject:

	tst.l old_xhdi
	bne.s .xnu1
	moveq #0,D0
	rts
.xnu1:
	move.l #0xBAD0CA11,D0
	rts
	
XHDrvMap:

	move.l _drvbits,D0
	moveq #0,D1
	moveq #0,D2
	move.l pun_ptr,A0
.xdm1:
		move.b pinfo_pun(A0,D1.L),D2
		bmi.s .xdm4 // nothing
#ifdef MCF547X
		tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
		bmi.s .xdm5
#else
		beq.s .xdm5
#endif
		tst.l D2
		beq.s .xdm2 // OK
.xdm5:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
		tst.l _usb_1st_disk_drive
		beq.s .xdm4 // error
		cmp.l #PUN_USB,D2
		bcs.s .xdm4
		cmp.l #PUN_USB+PUN_DEV,D2
		bls.s .xdm2 // OK
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
.xdm4:
		bclr D1,D0  // remove drive not in pun table
.xdm2:
		addq.l #1,D1
	cmp.l #MAX_LOGICAL_DRIVE,D1
	bcs.s .xdm1
	tst.l old_xhdi
	beq.s .xdm3
	move.l D0,-(SP)	
	move.w 8(A6),-(SP)
	move.l old_xhdi,A0
	jsr (A0)
	addq.l #2,SP
	or.l (SP)+,D0
.xdm3:	
#ifdef DEBUG_XHDI
	move.l D0,-(SP)
	lea debug131(PC),A0
	jsr display_string
	move.l (SP),D0
	jsr hex_long
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
	move.l (SP)+,D0
#endif
	rts

XHInqDev:

#ifdef DEBUG_XHDI
	lea debug134(PC),A0
	jsr display_string
	move.w 10(A6),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	move.l pun_ptr,A0
 	moveq #0,D0
	move.w 10(A6),D0         // bios_device
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .xd10
#else
	beq.s .xd10
#endif
	cmp.l _sd_disk_drive,D0
	beq.s .xd8
.xd10:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .xd2               // error
	cmp.l _usb_1st_disk_drive,D0
	bcs.s .xd2
	cmp.l #MAX_LOGICAL_DRIVE,D0
	bcs.s .xd8
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
	bra.s .xd2               // error
.xd8:
	moveq #0,D1
	move.b pinfo_pun(A0,D0.l),D1
	bpl.s .xd1
.xd2:	
	tst.l old_xhdi
	bne.s .xd3
	moveq #-46,D0            // invalid drive number
	rts
.xd3:
	move.l #0xBAD0CA11,D0
	rts
.xd1:	
#ifdef MCF547X
	move.l D1,D2
	beq.s .xd9
#endif	
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l D1,D2
	and.l #PUN_USB,D2
	bne.s .xd9
#endif
	bra.s .xd2               // error
.xd9:
	tst.l 12(A6)
	beq.s .xd4
	move.l 12(A6),A1         // major
	move.w D1,(A1)
.xd4:
	tst.l 16(A6)
	beq.s .xd5
	move.l 16(A6),A1         // minor
	clr.w (A1)
.xd5:
	tst.l 20(A6)
	beq.s .xd6
	move.l pinfo_pstart(A0,D0.l*4),D1
	move.l 20(A6),A1         // start_sector
	move.l D1,(A1)
.xd6:
	lea pinfo_bpb(A0),A0
	mulu #18,D0              // * 18
	add.l D0,A0
	tst.l 24(A6)
	beq.s .xd7
	move.l 24(A6),A1         // bpb
	move.l (A0)+,(A1)+
	move.l (A0)+,(A1)+
	move.l (A0)+,(A1)+
	move.l (A0)+,(A1)+
	move.w (A0)+,(A1)+
.xd7:
	moveq #0,D0
	rts

XHInqDriver:

#ifdef DEBUG_XHDI
	lea debug135(PC),A0
	jsr display_string
	move.w 10(A6),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	move.l pun_ptr,A0
 	moveq #0,D0
	move.w 10(A6),D0         // bios_device
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .xdr11
#else
	beq.s .xdr11
#endif
	cmp.l _sd_disk_drive,D0
	beq.s .xdr9
.xdr11:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .xdr2              // error
	cmp.l _usb_1st_disk_drive,D0
	bcs.s .xdr2
	cmp.l #MAX_LOGICAL_DRIVE,D0
	bcs.s .xdr9
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
	bra.s .xdr2              // error
.xdr9:
	moveq #0,D1
	move.b pinfo_pun(A0,D0.l),D1
	bpl.s .xdr1
.xdr2:	
	tst.l old_xhdi
	bne.s .xdr8
	moveq #-46,D0            // invalid drive number
	rts
.xdr8:
	move.l #0xBAD0CA11,D0
	rts
.xdr1:
#ifdef MCF547X
	move.l D1,D0
	beq.s .xdr10
#endif	
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l D1,D0
	and.l #PUN_USB,D0
	bne.s .xdr10
#endif
	bra.s .xdr2              // error
.xdr10:
	move.l 12(A6),D0         // name, 17 characters
	beq.s .xdr3
	move.l D0,A1
	lea message1(PC),A0
	moveq #17,D1
.xdr6:
		move.b (A0)+,D0
		beq.s .xdr7
		move.b D0,(A1)+
	subq.l #1,D1
	bpl.s .xdr6
.xdr7:
	clr.b (A1)
.xdr3:
	move.l 16(A6),D0         // version, 7 characters
	beq.s .xdr4
	move.l D0,A1
	move.b #0x34,(A1)+       // ??? TOS 4.04
	move.b #0x2E,(A1)+
	move.b #0x30,(A1)+
	move.b #0x34,(A1)+
	clr.b (A1)
.xdr4:
	move.l 20(A6),D0         // company, 17 characters
	beq.s .xdr5
	move.l D0,A1
	clr.b (A1)
.xdr5:
	move.l 24(A6),A1         // ahdi_version
	move.l pun_ptr,A0
	move.w pinfo_vernum(A0),(A1)
	move.l 28(A6),A1         // maxIPL
	moveq #5,D0
	move.w D0,(A1)	
	moveq #0,D0
	rts

XHReadWrite:                          // read / write physical sectors

#ifdef DEBUG_XHDI
	lea debug132(PC),A0
	jsr display_string
	move.w 10(A6),D0         // major
	jsr hex_word
	lea debug139(PC),A0
	jsr display_string	
	move.w 12(A6),D0         // minor
	jsr hex_word
	lea debug140(PC),A0
	jsr display_string
	move.w 14(A6),D0         // rwflag
	jsr hex_word
	lea debug141(PC),A0
	jsr display_string
	move.l 16(A6),D0         // recno
	jsr hex_long
	lea debug142(PC),A0
	jsr display_string
	move.w 20(A6),D0         // count
	jsr hex_word
	lea debug143(PC),A0
	jsr display_string
	move.l 22(A6),D0         // buffer
	jsr hex_long
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char	
#endif
	tst.w 12(A6)             // minor
	bne.s .xr4
	moveq #0,D4
	move.w 10(A6),D4         // major
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .xr12
#else
	beq.s .xr12
#endif
	tst.l D4
	beq.s .xr1               // SD-card
.xr12:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .xr4               // error
	cmp.l #PUN_USB,D4
	bcs.s .xr4
	cmp.l #PUN_USB+PUN_DEV,D4
	bls.s .xr1               // OK
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
.xr4:
	tst.l old_xhdi
	bne.s .xr6
	moveq #-15,D0            // unknown device
	rts
.xr6:
	move.l #0xBAD0CA11,D0
	rts
.xr1:
	move.l 22(A6),A0         // buffer
	moveq #0,D3
	move.w 20(A6),D3         // count
	beq .xr2                 // no sectors
             move.l 16(A6),D2         // recno
	btst #0,15(A6)           // rwflag
	beq.s .xr7               // read
	// write
#ifdef MCF547X
	moveq #PUN_USB,D0
	and.l D4,D0
	bne.s .xr10              // USB
.xr11:
		move.l D2,D0
		bsr sd_card_sector_write
		bmi.s .xr2    // error
		addq.l #1,D2  // blknr
		add.l #512,A0 // buffer
	subq.l #1,D3             // blkcnt
	bgt.s .xr11
	bra.s .xr3
.xr10:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l A0,-(SP)          // buffer
	move.l D3,-(SP)          // blkcnt	
	move.l D2,-(SP)          // blknr
	moveq #PUN_DEV,D0
	and.l D4,D0              // major
	move.l D0,-(SP)          // devnum
	jsr _usb_stor_write
	bra.s .xr5
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
.xr2:
	moveq #-1,D0             // error
	bra.s .xr3
.xr7:
#ifdef MCF547X
	moveq #PUN_USB,D0
	and.l D4,D0
	bne.s .xr8               // USB
.xr9:
		move.l D2,D0
		bsr sd_card_sector_read
		bmi.s .xr2    // error
		addq.l #1,D2  // blknr
		add.l #512,A0 // buffer
	subq.l #1,D3             // blkcnt
	bgt.s .xr9
	bra.s .xr3
.xr8:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l A0,-(SP)          // buffer
	move.l D3,-(SP)          // blkcnt	
	move.l D2,-(SP)          // blknr
	moveq #PUN_DEV,D0
	and.l D4,D0              // major
	move.l D0,-(SP)          // devnum
	jsr _usb_stor_read
.xr5:
	lea 16(SP),SP
	tst.l D0
	bmi.s .xr3               // error
	moveq #0,D0
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
.xr3:
 	rts

XHInqDev2:

#ifdef DEBUG_XHDI
	lea debug136(PC),A0
	bsr display_string
	move.w 10(A6),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char	
#endif
	move.l pun_ptr,A0
 	moveq #0,D0
	move.w 10(A6),D0         // bios_device
#ifdef MCF547X
	tst.l _sd_disk_drive
#ifdef SD_CARD_REPLACE_FLOPPY
	bmi.s .xdd13
#else
	beq.s .xdd13
#endif
	cmp.l _sd_disk_drive,D0
	beq.s .xdd12
.xdd13:
#endif /* MCF547X */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	tst.l _usb_1st_disk_drive
	beq.s .xdd2              // error
	cmp.l _usb_1st_disk_drive,D0
	bcs.s .xdd2
	cmp.l #MAX_LOGICAL_DRIVE,D0
	bcs.s .xdd12
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE) */
	bra.s .xdd2              // error
.xdd12:
	moveq #0,D1
	move.b pinfo_pun(A0,D0.l),D1
	bpl.s .xdd1
.xdd2:	
	tst.l old_xhdi
	bne.s .xdd4
	moveq #-46,D0            // invalid drive number
	rts
.xdd4:
	move.l #0xBAD0CA11,D0
	rts
.xdd1:
#ifdef MCF547X
	move.l D1,D2
	beq.s .xdd11
#endif	
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)
	move.l D1,D2
	and.l #PUN_USB,D2
	bne.s .xdd11
#endif
	bra.s .xdd2              // error
.xdd11:
	tst.l 12(A6)
	beq.s .xdd5
	move.l 12(A6),A1         // major
	move.w D1,(A1)
.xdd5:
	tst.l 16(A6)
	beq.s .xdd6
	move.l 16(A6),A1         // minor
	clr.w (A1)
.xdd6:
	tst.l 20(A6)
	beq.s .xdd7
	move.l pinfo_pstart(A0,D0.l*4),D1
	move.l 20(A6),A1         // start_sector
	move.l D1,(A1)
.xdd7:
	tst.l 24(A6)
	beq.s .xdd8
	lea pinfo_bpb(A0),A2
	move.l D0,D1
	mulu #18,D1              // * 18
	add.l D1,A2
	move.l 24(A6),A1         // bpb
	move.l (A2)+,(A1)+
	move.l (A2)+,(A1)+
	move.l (A2)+,(A1)+
	move.l (A2)+,(A1)+
	move.w (A2)+,(A1)+
.xdd8:
	tst.l 28(A6)
	beq.s .xdd9
	move.l 28(A6),A1         // blocks
	lea pinfo_psize(A0),A2
	move.l (A2,D0.l*4),(A1)
.xdd9:
	tst.l 32(A6)
	beq.s .xdd10
	move.l 32(A6),A1         // partid
	move.b pinfo_ptype+1(A0,D0.l*4),(A1)+
	move.b pinfo_ptype+2(A0,D0.l*4),D1
	bne.s .xdd3              // Atari partition
	moveq #0x44,D1           // D for MSDOS
.xdd3:
	move.b D1,(A1)+
	move.b pinfo_ptype+3(A0,D0.l*4),(A1)
.xdd10:
	moveq #0,D0
	rts
 
XHDriverSpecial:
XHGetCapacity:
XHMediumChanged:
XHMiNTInfo:
XHNewCookie:

	tst.l old_xhdi
	bne.s .xn1
	moveq #-32,D0            //  invalid function number 
	rts
.xn1:
	move.l #0xBAD0CA11,D0
	rts

XHDOSLimits:

#ifdef DEBUG_XHDI
	lea debug137(PC),A0
	jsr display_string
	move.w 10(A6),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char	
#endif
	tst.l old_xhdi
	bne.s .xn1
	moveq #0,D0
	move.w 10(A6),D0         // which
	cmp.l #XH_DL_SECSIZ,D0   // maximal sector size (BIOS level)
	bne.s .xl1
	move.l #0x4000,D0
	rts	
.xl1:
	cmp.l #XH_DL_MINFAT,D0   // minimal number of FATs
	bne.s .xl2
	moveq #1,D0
	rts
.xl2:
	cmp.l #XH_DL_MAXFAT,D0   // maximal number of FATs
	bne.s .xl3
	moveq #2,D0
	rts
.xl3:
	cmp.l #XH_DL_MINSPC,D0   // sectors per cluster minimal
	bne.s .xl4
	moveq #2,D0
	rts
.xl4:
	cmp.l #XH_DL_MAXSPC,D0   // sectors per cluster maximal
	bne.s .xl5
#ifdef COLDFIRE
	moveq #64,D0             // for this Coldfire version of BDOS, else 2
#else
	moveq #2,D0
#endif
	rts
.xl5:
	cmp.l #XH_DL_CLUSTS,D0   // maximal number of clusters of a 16 bit FAT
	bne.s .xl6
	move.l #0x8000,D0
	rts	
.xl6:
	cmp.l #XH_DL_MAXSEC,D0   // maximal number of sectors
	bne.S .xl7
#ifdef COLDFIRE
	move.l #0x200000,D0      // for this Coldfire version of BDOS, else 0x10000
#else
	move.l #0x10000,D0
#endif
	rts
.xl7:
	cmp.l #XH_DL_DRIVES,D0   // maximal number of BIOS drives supported by the DOS
	bne.s .xl8
	moveq #MAX_LOGICAL_DRIVE,D0
	rts
.xl8:
	moveq #-32,D0            // invalid function number 
	rts

#endif /* ((defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)) || defined(MCF547X) */


#ifdef NETWORK

_install_ram_disk:

	lea -20(SP),SP
	movem.l D1-D2/A0-A2,(SP)
	link A6,#-16
#ifdef RAM_DISK_REPLACE_B
	moveq #1,D1              // drive B
#else
	moveq #2,D1              // drive C
	move.l _drvbits,D0
.search_empty_drive:
		btst D1,D0
		beq.s .drive_not_exist
		addq.l #1,D1
	cmp.l #MAX_LOGICAL_DRIVE,D1
	bcs.s .search_empty_drive
	bra .drive_full          // all drives already used
.drive_not_exist:
#endif /* RAM_DISK_REPLACE_B */
	move.l D1,_ram_disk_drive
	moveq #2,D0
	move.l D0,_change_ram_disk
	clr.l _ext_write_protect_ram_disk
	moveq #0,D0
	move.w tab_bpb+12(PC),D0 // sectors offset
	addq.l #1,D0
	lsr.l #1,D0
	add.l #RAM_DISK_SIZE_KB,D0
	asl.l #8,D0              // * 1024
	asl.l #2,D0
	move.l D0,_size_ram_disk
	addq.l #4,D0
	move.w #3,-(SP)          // TT ram if possible
	move.l D0,-(SP)
	move.w #0x44,-(SP)       // Mxalloc
	trap #1 
	addq.l #8,SP
.test_malloc_ok:
	tst.l D0
	beq .no_ram_disk
	addq.l #3,D0
	and.l #0xFFFFFFFC,D0     // 4 bytes alignment
	move.l D0,_address_ram_disk
	move.w SR,D0
	move.w D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	move.l #0x5F43465F,D1    // _CF_
	lea det_hdv_bpb(PC),A0
	move.w #hdv_bpb,D0
	bsr install_xbra
	move.l D0,old_hdv_bpb
	lea det_hdv_rw(PC),A0
	move.w #hdv_rw,D0
	bsr install_xbra
	move.l D0,old_hdv_rw
	lea det_hdv_mediach(PC),A0
	move.w #hdv_mediach,D0
	bsr install_xbra
	move.l D0,old_hdv_mediach
	move.w (SP)+,D0
	move.w D0,SR
#ifdef RAM_DISK_FAT12
	moveq #0,D0
	move.w tab_bpb+12(PC),D0 // sectors offset
	asl.l #6,D0              // * 512 / 8
	subq.l #1,D0
#else
	move.l #((512*((RAM_DISK_SEC_FAT*2)+1+7))/8)-1,D0
#endif
	move.l _address_ram_disk,A0
.raz_fat:
		clr.l (A0)+
		clr.l (A0)+
	subq.l #1,D0
	bpl.s .raz_fat
	move.l _address_ram_disk,A0
	lea 8(A0),A0
	lea tab_boot(PC),A1
	moveq #5,D0
.init_boot_sector:
		move.l (A1)+,(A0)+
	subq.l #1,D0
	bpl.s .init_boot_sector
	moveq #0,D0
	move.w tab_bpb+12(PC),D0 // sectors offset
	add.l #RAM_DISK_SIZE_KB*2,D0 // number of sectors
	move.l _address_ram_disk,A0 // boot sector bytes 19-20
	moveq #0,D2
	move.b D0,D2
	move.l 16(A0),D1
	and.l #0xFFFFFF00,D1
	or.l D2,D1
	move.l D1,16(A0)
	move.w D0,D2
	swap D2
	and.l #0xFF000000,D2
	move.l 20(A0),D1
	and.l #0x00FFFFFF,D1
	or.l D2,D1
	move.l D1,20(A0)
	move.l _drvbits,D0
	move.l _ram_disk_drive,D1
	bset D1,D0
	move.l D0,_drvbits
	lea -16(A6),A0           // name
	add.l #0x41,D1
	move.b D1,(A0)+
	move.b #0x3A,(A0)+       // :
	move.l #0x5C52414D,(A0)+ // \RAM
	move.l #0x2D444953,(A0)+ // -DIS
	move.w #0x4B00,(A0)      // K
	move.w #8,-(SP)
	pea -16(A6)              // name
	move.w #0x3C,-(SP)       // Fcreate
	trap #1
	addq.l #8,SP
	tst.w D0
	bmi .error_fcreate
	move.w D0,-(SP)	
	move.w #0x3E,-(SP)       // Fclose
	trap #1
	addq.l #4,SP	
	moveq #2,D0              // drive C
	cmp.l _ram_disk_drive,D0
	bne.s .no_set_drive
	move.w D0,_bootdev
	move.w D0,-(SP)
	move.w #0xE,-(SP)        // Dsetdrv
	trap #1
	addq.l #4,SP
.no_set_drive:
	lea blue(PC),A0
	bsr text_color
	pea message(PC)          // Ram-disk installed
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	moveq #0x41,D0           // A
	add.l _ram_disk_drive,D0
	move.w D0,-(SP)
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	pea crlf(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	lea black(PC),A0
	bsr text_color
	move.l _ram_disk_drive,D0 // OK
	bra.s .end_ram_disk
.error_fcreate:
	pea error3(PC)
	bra.s .display_error
.drive_full:
	pea error2(PC)
	bra.s .display_error
.no_ram_disk:
	pea error1(PC)
.display_error:
	pea error(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	moveq #0,D0              // not installed
.end_ram_disk:
	unlk A6
	movem.l (SP),D1-D2/A0-A2
	lea 20(SP),SP
	rts

det_hdv_bpb:

 	moveq #0,D0
	move.w 4(SP),D0          // drive
	cmp.l _ram_disk_drive,D0
	beq.s .dhb1
	move.l old_hdv_bpb,-(SP)
	rts
.dhb1:
	move.l A0,-(SP)
#ifdef DEBUG
	lea debug4(PC),A0
	jsr display_string	
#endif
	lea tab_bpb(PC),A0
	move.l A0,D0
	move.l (SP)+,A0
	rts
	
#ifdef RAM_DISK_FAT12

tab_bpb:
	dc.w 0x200               // sector size
	dc.w 2                   // cluster size in sectors
	dc.w 0x400               // cluster size in bytes
	dc.w 7                   // size directory in sectors
	dc.w RAM_DISK_SEC_FAT    // FAT size
	dc.w RAM_DISK_SEC_FAT+1  // 1st sector of FAT2
	dc.w (RAM_DISK_SEC_FAT*2)+7+1 // 1st data sector
	dc.w RAM_DISK_SIZE_KB    // total clusters
	dc.w 0                   // FAT 12
	dc.w 0
	dc.l 0,0,0
	
tab_boot:
	dc.b 0x16,0x10,0x64      // serial number
	dc.b 0,2                 // bytes/sector
	dc.b 2                   // sectors/cluster
	dc.b 1,0                 // reserved sectors
	dc.b 2                   // number of FATs
	dc.b 112,0               // number of directory entry
	dc.b 0,0                 // number of sectors
	dc.b 0
	dc.b RAM_DISK_SEC_FAT,0  // number of sectors/FAT
	dc.b 9,0                 // number of sectors/track
	dc.b 1,0                 // number of sides
	dc.b 0,0                 // number of hidden sectors
	dc.b 0,0                 // exec flag

#else

tab_bpb:
	dc.w 0x200               // sector size
	dc.w 2                   // cluster size in sectors
	dc.w 0x400               // cluster size in bytes
	dc.w 7                   // size directory in sectors
	dc.w RAM_DISK_SEC_FAT    // FAT size
	dc.w RAM_DISK_SEC_FAT+1  // 1st sector of FAT2
	dc.w (RAM_DISK_SEC_FAT*2)+7+1 // 1st data sector
	dc.w RAM_DISK_SIZE_KB    // total clusters
	dc.w 1                   // FAT 16
	dc.w 0
	dc.l 0,0,0
	
tab_boot:
	dc.b 0x16,0x10,0x64      // serial number
	dc.b 0,2                 // bytes/sector
	dc.b 2                   // sectors/cluster
	dc.b 1,0                 // reserved sectors
	dc.b 2                   // number of FATs
	dc.b 112,0               // number of directory entry
	dc.b 0,0                 // number of sectors
	dc.b 0
	dc.b RAM_DISK_SEC_FAT,0  // number of sectors/FAT
	dc.b 9,0                 // number of sectors/track
	dc.b 1,0                 // number of sides
	dc.b 0,0                 // number of hidden sectors
	dc.b 0,0                 // exec flag

#endif
	.align 2

det_hdv_rw:

 	moveq #0,D0
	move.w 14(SP),D0         // drive
	cmp.l _ram_disk_drive,D0
	beq.s .dhr1
	move.l old_hdv_rw,-(SP)
	rts
.dhr1:
	lea -16(SP),SP
	movem.l D1-D2/A0-A1,(SP)
#ifdef DEBUG
	lea debug3(PC),A0
	jsr display_string	
	move.w 4+16(SP),D0       // rwflag
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.l 6+16(SP),D0       // buffer
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 10+16(SP),D0      // num sectors
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 12+16(SP),D0      // logical sector
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 14+16(SP),D0      // drive
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	moveq #0,D0
	move.w 12+16(SP),D0      // logical sector
	bpl.s .dhr5
	move.l 16+16(SP),D0      // logical sector	
.dhr5:
	asl.l #8,D0
	add.l D0,D0              // * 512
	move.l 6+16(SP),D1       // buffer
	beq.s .dhr4
	move.l D1,A0
	moveq #0,D1
	move.w 10+16(SP),D1      // num sectors
	subq.l #1,D1
	bmi.s .dhr4
	move.l _address_ram_disk,A1
	add.l D0,A1
	btst #0,5+16(SP)         // rwflag
	beq.s .dhr2              // read
	move.l A0,D0
	move.l A1,A0
	move.l D0,A1
	tst.l _ext_write_protect_ram_disk
	beq.s .dhr2
	moveq #-13,D0            // write protect
	bra.s .dhr6
.dhr2:
#ifdef DEBUG
//		bsr dump
//		jsr wait_key
#endif
		moveq #15,D0 // 512 bytes transfer
.dhr3:
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+  
		subq.l #1,D0
		bpl.s .dhr3
	subq.l #1,D1
	bpl.s .dhr2
.dhr4:
	moveq #0,D0
.dhr6:
	movem.l (SP),D1-D2/A0-A1
	lea 16(SP),SP
 	rts

det_hdv_mediach:

 	moveq #0,D0
	move.w 4(SP),D0          // drive
	cmp.l _ram_disk_drive,D0
	beq.s .dhm1
	move.l old_hdv_mediach,-(SP)
	rts
.dhm1:
#if 0 // #ifdef DEBUG
	move.l A0,-(SP)
	lea debug5(PC),A0
	jsr display_string
	move.l (SP)+,A0
#endif
	move.l _change_ram_disk,D0
	clr.l _change_ram_disk
	rts
	
_alert_tos:
	
	lea -52(SP),SP
	movem.l D1-A5,(SP)
	move.l 56(SP),A0         // string
	pea.l (A0)
	move.w #1,-(SP)
	jsr 0xE22A68             // form_alert
	addq.l #6,SP
	movem.l (SP),D1-A5
	lea 52(SP),SP
	ext.l D0
	rts
	
#ifdef SOUND_AC97
#ifdef COLDFIRE
#ifndef MCF5445X

#define STEREO8  0 // 8 bits stereo
#define STEREO16 1 // 16 bits stereo
#define MONO8    2 // 8 bits mono
#define MONO16   3 // 16 bits mono   

_mcf548x_ac97_playback_resample:	

	lea -32(SP),SP
	movem.l D2-D7/A2-A3,(SP)
	move.l 32+4(SP),D1       // source frequency
	move.l 32+8(SP),D0       // mode
	move.l 32+12(SP),D4      // target number of samples
	move.l 32+16(SP),A0      // source
	move.l 32+20(SP),A2      // target AC97 slots
	swap D1                  // source frequency * 65536
	.chip 68060
	divu #48000,D1           // / target frequency
	.chip 5200
	swap D1                  // * 65536 => step
	clr.w D1
	moveq #0,D2
	moveq #0,D3
	cmp.l #MONO16,D0
	beq.s .pr9
	cmp.l #MONO8,D0
	beq.s .pr7
	move.l D4,A3
	cmp.l #STEREO16,D0
	beq .pr5
	cmp.l #STEREO8,D0
	beq .pr3
	move.l A0,A1
	bra .pr1
.pr9:
		move.l A0,A1 // source
		add.l D3,A1
		add.l D3,A1
		move.w (A1)+,D6 // 16 bits mono sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .pr8
		move.w (A1),D7 // 16 bits mono sample x(n+1)
		muls D0,D7
		neg.l D0
		bclr #15,D0 // 1-32767
		muls D0,D6
		add.l D7,D6
		add.l D6,D6
		swap D6
.pr8:
	  	moveq #16,D0
		asl.l D0,D6
		move.l D6,(A2)
		move.l D6,4(A2)
		moveq #0,D0
		add.l D1,D2 // step
		addx.l D0,D3
		lea 52(A2),A2
	subq.l #1,D4
	bgt.s .pr9
	bra .pr1
.pr7:
		move.l A0,A1 // source
		add.l D3,A1
		move.b (A1)+,D6 // 8 bits mono sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .pr6
		move.b (A1),D7 // 8 its mono sample x(n+1)
		ext.w D7
		muls D0,D7
		neg.l D0
		bclr #15,D0 // 1-32767
		ext.w D6
		muls D0,D6
		add.l D7,D6
		add.l D6,D6
		swap D6
.pr6:
		moveq #24,D0
		asl.l D0,D6
		move.l D6,(A2)
		move.l D6,4(A2)
		moveq #0,D0
		add.l D1,D2 // step
		addx.l D0,D3
		lea 52(A2),A2
	subq.l #1,D4
	bgt.s .pr7
	bra .pr1
.pr5:
		move.l A0,A1 // source
		add.l D3,A1
		add.l D3,A1
		add.l D3,A1
		add.l D3,A1
		move.w (A1)+,D4 // 16 bits left sample x(n)
		move.w (A1)+,D6 // 16 bits right sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .pr4
		move.w (A1),D5 // 16 bits left sample x(n+1)
		move.w 2(A1),D7 // 16 bits right sample x(n+1)
		muls D0,D5
		muls D0,D7
		neg.l D0
 		bclr #15,D0 // 1-32767
		muls D0,D4
		muls D0,D6
		add.l D5,D4
		add.l D7,D6
		add.l D4,D4
		add.l D6,D6
		swap D4
		swap D6
.pr4:
	  	moveq #16,D0
		asl.l D0,D4
		asl.l D0,D6
		move.l D4,(A2)
		move.l D6,4(A2)
		moveq #0,D0
		add.l D1,D2 // step
		addx.l D0,D3
		lea 52(A2),A2
	subq.l #1,A3
	move.l A3,D0
	bgt.s .pr5
	bra.s .pr1
.pr3:
		move.l A0,A1 // source
		add.l D3,A1
		add.l D3,A1
		move.b (A1)+,D4 // 8 bits left sample x(n)
		move.b (A1)+,D6 // 8 bits right sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .pr2
		move.b (A1),D5 // 8 bits left sample x(n+1)
		move.b 1(A1),D7 // 8 bits right sample x(n+1)
		ext.w D5
		ext.w D7
		muls D0,D5
		muls D0,D7
		neg.l D0
 		bclr #15,D0 // 1-32767
 		ext.w D4
 		ext.w D6
		muls D0,D4
		muls D0,D6
		add.l D5,D4
		add.l D7,D6
		add.l D4,D4
		add.l D6,D6
		swap D4
		swap D6
.pr2:
	  	moveq #24,D0
		asl.l D0,D4
		asl.l D0,D6
		move.l D4,(A2)
		move.l D6,4(A2)
		moveq #0,D0
		add.l D1,D2 // step
		addx.l D0,D3
		lea 52(A2),A2
	subq.l #1,A3
	move.l A3,D0
	bgt.s .pr3
.pr1:
	move.l A1,D0
	movem.l (SP),D2-D7/A2-A3
	lea 32(SP),SP
	rts

#define RECORD_STEREO16 0x0000 // 16-bit stereo capture
#define RECORD_STEREO8  0x0100 // 8-bit stereo capture
#define RECORD_MONO8    0x0200 // 8-bit mono capture
#define RECORD_MONO16   0x0300 // 16-bit mono capture

_mcf548x_ac97_record_resample:	

	lea -40(SP),SP
	movem.l D2-D7/A2-A5,(SP)
	move.l 40+4(SP),D2       // target frequency
	move.l 40+8(SP),D0       // mode
	move.l 40+12(SP),D4      // source number of samples
	move.l 40+16(SP),A2      // target
	move.l 40+20(SP),A0      // source AC97 slots
	move.l #48000*65536,D1   // source frequency * 65536
	.chip 68060
	divu.l D2,D1             // / target frequency
	.chip 5200
	move.l D1,D2
	swap D2
	clr.w D2                 // * 65536
	move.l D2,A5             // step.low
	clr.w D1
	swap D1                  // step.high
	moveq #0,D2
	moveq #0,D3
	move.l D4,A4
	move.l D4,A3
	subq.l #1,A3             // source number of samples - 1
	cmp.l #RECORD_MONO16,D0
	beq.s .rr9
	cmp.l #RECORD_MONO8,D0
	beq.s .rr7
	cmp.l #RECORD_STEREO16,D0
	beq .rr5
	cmp.l #RECORD_STEREO8,D0
	beq .rr3
	bra .rr1
.rr9:
		moveq #52,D0
		.chip 68060
		mulu.l D3,D0
		.chip 5200
		lea (A0,D0.l),A1
		move.w (A1),D6 // 16 bits mono sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .rr8
		cmp.l A3,D3
		bcc .rr1
		move.w 52(A1),D7 // 16 bits mono sample x(n+1)
		muls D0,D7
		neg.l D0
		bclr #15,D0 // 1-32767
		muls D0,D6
		add.l D7,D6
		add.l D6,D6
		swap D6
.rr8:
		move.w D6,(A2)+
		add.l A5,D2
		addx.l D1,D3 // step
	cmp.l D4,D3
	bcs.s .rr9
	bra .rr1
.rr7:
		moveq #52,D0
		.chip 68060
		mulu.l D3,D0
		.chip 5200
		lea (A0,D0.l),A1
		move.b (A1),D6 // 8 bits mono sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .rr6
		cmp.l A3,D3
		bcc .rr1
		move.b 52(A1),D7 // 8 bits mono sample x(n+1)
		ext.w D7
		muls D0,D7
		neg.l D0
		bclr #15,D0 // 1-32767
		ext.w D6
		muls D0,D6
		add.l D7,D6
		add.l D6,D6
		swap D6
.rr6:
		move.b D6,(A2)+
		add.l A5,D2
		addx.l D1,D3 // step
	cmp.l D4,D3
	bcs.s .rr7
	bra .rr1
.rr5:
		moveq #52,D0
		.chip 68060
		mulu.l D3,D0
		.chip 5200
		lea (A0,D0.l),A1
		move.w (A1),D6 // 16 bits left sample x(n)
		move.w 4(A1),D4 // 16 bits right sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .rr4
		cmp.l A3,D3
		bcc .rr1
		move.w 52(A1),D7 // 16 bits left sample x(n+1)
		move.w 56(A1),D5 // 16 bits right sample x(n+1)
		muls D0,D7
		muls D0,D5
		neg.l D0
		bclr #15,D0 // 1-32767
		muls D0,D6
		muls D0,D4
		add.l D7,D6
		add.l D5,D4
		add.l D6,D6
		add.l D4,D4
		swap D6
		swap D4
.rr4:
		move.w D6,(A2)+
		move.w D4,(A2)+
		add.l A5,D2
		addx.l D1,D3 // step
	cmp.l A4,D3
	bcs.s .rr5
	bra.s .rr1
.rr3:
		moveq #52,D0
		.chip 68060
		mulu.l D3,D0
		.chip 5200
		lea (A0,D0.l),A1
		move.b (A1),D6 // 8 bits left sample x(n)
		move.b 4(A1),D4 // 8 bits right sample x(n)
		move.l D2,D0
		clr.w D0
		swap D0
		lsr.l #1,D0 // 1-32767
		beq.s .rr2
		cmp.l A3,D3
		bcc.s .rr1
		move.b 52(A1),D7 // 8 bits left sample x(n+1)
		move.b 56(A1),D5 // 8 bits right sample x(n+1)
		ext.w D7
		ext.w D5
		muls D0,D7
		muls D0,D5
		neg.l D0
		bclr #15,D0 // 1-32767
		ext.w D6
		ext.w D4
		muls D0,D6
		muls D0,D4
		add.l D7,D6
		add.l D5,D4
		add.l D6,D6
		add.l D4,D4
		swap D6
		swap D4
.rr2:
		move.b D6,(A2)+
		move.b D4,(A2)+
		add.l A5,D2
		addx.l D1,D3 // step
	cmp.l A4,D3
	bcs.s .rr3
.rr1:
	move.l A2,D0
	movem.l (SP),D2-D7/A2-A5
	lea 40(SP),SP
	rts
	
#endif/* MCF5445X */	
#endif /* COLDFIRE */
#endif /* SOUND_AC97 */
	
#endif /* NETWORK */
	
_asm_set_ipl:

	link A6,#-8
	movem.l D6-D7,(SP)
	move.w SR,D7             // current SR
	move.l D7,D0             // prepare return value
	and.l #0x0700,D0         // mask out IPL
	lsr.l #8,D0              // IPL
	move.l 8(A6),D6          // get argument
	and.l #7,D6              // least significant three bits
	lsl.l #8,D6              // move over to make mask
	and.l #0x0000F8FF,D7     // zero out current IPL
	or.l D6,D7               // place new IPL in SR
	move.w D7,SR
	movem.l (SP),D6-D7
	lea 8(SP),SP
	unlk A6
	rts

#ifdef COLDFIRE
#ifdef NETWORK
#ifdef LWIP

#include "../include/fire.h"

	.chip 68060
	
_flush_dc:

 	move.w SR,D0
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	lea 0,A1                 // cpushl pointer
.fdc1:
		cpushl DC,(A1)
		addq.l #1,A1
		cpushl DC,(A1)
		addq.l #1,A1
		cpushl DC,(A1)
		addq.l #1,A1
		cpushl DC,(A1)
		add.l #0x10-3,A1
	cmp.l #LAST_DCACHE_ADDR,A1
	bls.s .fdc1
	move.w D0,SR
	rts

_flush_caches:

	bsr _flush_dc

_flush_ic:

 	move.w SR,D0
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	lea 0,A1                 // cpushl pointer
.fic1:
		cpushl IC,(A1)
		addq.l #1,A1
		cpushl IC,(A1)
		addq.l #1,A1
		cpushl IC,(A1)
		addq.l #1,A1
		cpushl IC,(A1)
		add.l #0x10-3,A1
	cmp.l #LAST_ICACHE_ADDR,A1
	bls.s .fic1
	move.w D0,SR
	rts

_disable_caches:

	move.l D0,-(SP)
	move.w SR,D0
	move.l D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	bsr _flush_caches
	nop
	move.l #0x01000120,D0    // Invalidate and disable cache
	movec D0,CACR
	move.l (SP)+,D0
	move.w D0,SR
	move.l (SP)+,D0
	rts

_enable_caches:

	move.w SR,D0
	move.l D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	bsr _flush_caches
	nop
	move.l #0x01040120,D0    // invalidate whole cache
	movec D0,CACR
	nop
	move.l #0xA2088020,D0    // enable caches
	movec D0,CACR
	move.l (SP)+,D0
	move.w D0,SR
	rts

#if !defined(MCF547X) && !defined(MCF5445X)

_set_intfrcl:                         // force interrupt

	move.l 4(SP),D0
	or.l D0,MCF_INTC_INTFRCL
	rts

_clr_intfrcl:                         // unforce interrupt

	move.l 4(SP),D0
	and.l D0,MCF_INTC_INTFRCL
	rts

#endif /* !defined(MCF547X) && !defined(MCF5445X) */
#endif /* LWIP */
#endif /* NETWORK */

#ifdef MCF547X

_acp_new_hardware:                    // need asm timming

	moveq #0,D1
	moveq.l #0x55,D0
	move.w D0,ACP_VIDEO_PLL_CLK
	move.w ACP_VIDEO_PLL_CLK,D1 // 1st read not works
	move.w ACP_VIDEO_PLL_CLK,D1 // 2nd access works
	cmp.l D0,D1
	seq.b D0
	and.l #1,D0
	rts

#endif /* MCF547X */

#endif /* COLDFIRE */

text_color:

	moveq #0,D0
	move.w 0x3E86,D0         // number of planes
	cmp.l #2,D0
	bls.s .black_and_white
	pea (A0)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
.black_and_white:
	rts
	
_call_enumfunc:

	lea -20(SP),SP
	movem.l D1-D2/A0-A2,(SP)
	move.l 24(SP),A2         // enumfunc
	move.l 28(SP),A0         // si
	move.l 32(SP),D0         // flags
	move.l D0,-(SP)
	move.l A0,-(SP)
	jsr (A2)
	addq.l #8,SP
	movem.l (SP),D1-D2/A0-A2
	lea 20(SP),SP
	rts

_call_ikbdvec:

	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
	move.l 28(SP),D0         // ikbd code
	and.l #0xFF,D0
	move.l 32(SP),A0         // iorec
	move.l 36(SP),A2         // &kbdvecs[-1]
	move.l (A2),A2           // ikbdvec
	jsr (A2)
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
	rts

_call_mousevec:

	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
	move.l 28(SP),A0         // data
	move.l 32(SP),A2
	move.l (A2),A2           // mousevec
	jsr (A2)
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
	rts
	
_direct_conout:

	lea -60(SP),SP
	movem.l D0-A6,(SP)
	move.l 64(SP),D1
	and.l #0xff,D1
#if defined(DEBUG) && !defined(COLDFIRE)
	tst.w _video_found
	beq.s .normal_conout 
	move.l D1,D0
	bsr display_char
	movem.l (SP),D0-A6
	lea 60(SP),SP
	rts
.normal_conout:		
#endif
	move.l con_state,A0
	jsr (A0)	
	movem.l (SP),D0-A6
	lea 60(SP),SP
	rts

_critical_error:

	move.l (SP),D0
	move.l etv_critic,-(SP)
	rts

_get_sr:
	moveq #0,D0
	move SR,D0
	rts
	
message:	.asciz "Ram-disk installed in "
#if ((defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)) || defined(MCF547X)
message1:	.ascii "TOS4.04 "
message2:	.asciz "USB  "
message3:	.asciz "SD   "
message4:	.asciz ", partition installed in "
message5:	.asciz ", type "
message6:	.asciz ", "
message7:	.ascii " MB"
#endif /* ((defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)) || defined(MCF547X) */
crlf:	.byte 13,10,0
error:	.asciz "No ram-disk installed, "
error1:	.ascii "no enough memory"
	.byte 13,10,0
error2:	.ascii "all drives already used"
	.byte 13,10,0
error3:	.ascii "error disk name"
	.byte 13,10,0
error4:	.ascii "partition type not supported"
	.byte 13,10,0
blue:	.byte 0x1B,0x62,0x34,0
black:	.byte 0x1B,0x62,0x3F,0

	.align 2

	.lcomm _address_ram_disk,4
	.lcomm _size_ram_disk,4
	.lcomm _change_ram_disk,4
	.lcomm _ext_write_protect_ram_disk,4
	.lcomm _ram_disk_drive,4
	.lcomm old_hdv_bpb,4
	.lcomm old_hdv_rw,4
	.lcomm old_hdv_mediach,4
#ifdef MCF547X
	.lcomm name_sd_card,8
#endif
#if ((defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)) || defined(MCF547X)
#ifndef COLDFIRE
	.lcomm pun_ptr_usb,4
#endif
#ifdef MCF547X
#ifdef SD_CARD_VERIFY
	.lcomm sd_buffer_verify,512
#endif
	.lcomm _sd_disk_drive,4
#endif
	.lcomm _usb_1st_disk_drive,4
	.lcomm old_hdv_bpb_usb,4
	.lcomm old_hdv_rw_usb,4
	.lcomm old_hdv_mediach_usb,4
	.lcomm old_xhdi,4
	.lcomm old_xhdi_version,4
	.lcomm product_name,4*(PUN_USB+PUN_DEV+1)
#endif /* ((defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_STORAGE)) || defined(MCF547X) */

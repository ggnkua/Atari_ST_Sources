/* TOS 4.04 VDI for the CT60/CTPCI and Coldfire boards
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
 * along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"
#include "types.inc" /* fVDI structures */
#ifdef COLDFIRE
#ifdef DEBUG
#include "../../include/fire.h"
#endif
#endif /* COLDFIRE */

#undef XAAES_SEMAPHORE

#ifdef TOS_TABLES
#define tab_index_col_pal 0xE4D5D0 // index VDI color => index palette
#define tab_index_col_vdi 0xE4D7D0 // color index palette => index VDI
#endif

#define _timr_ms   0x442
#define _v_bas_ad  0x44E
#define _vblqueue  0x456
#define conterm    0x484
#define con_state  0x4A8
#define _hz_200    0x4BA
#define _dumpflg   0x4EE
#define _sysbase   0x4F2
#define dump_vec   0x502
#define bconstat_2 0x526
#define bconin_2   0x546
#define bconout_2  0x586
#define bconout_5  0x592
#define proc_type  0x59E

#define F_CFLASH   0 // cursor flash enable
#define F_CSTATE   1 // cursor flash state on
#define F_CVIS     2 // cursor visibility (semaphore)
#define F_CEOL     3 // cursor end of line handling
#define F_REVID    4 // reverse video       
#define F_SVPOS    5 // position saved

/* var VDI */
#define CUR_FONT -906
#define M_POS_HX -856
#define M_POS_HY -854
#define M_PLANES -852
#define M_CDB_BG -850
#define M_CDB_FG -848
#define MASKFORM -846
#define INQ_TAB -782
#define DEV_TAB -692
#define G_CURX -602
#define G_CURY -600
#define M_HID_CT -598
#define MOUSE_BT -596
#define REQ_COL48 -594 // 16 colors RVB
#define SIZ_TAB15 -498
#define TERM_CH -468
#define CHC_MODE -466
#define CUR_WORK -464
#define DEF_FONT -460
#define FONT_RING -456 // 4 pointers to sysfonts, last null
#define FONT_COUNT -440
#define LINE_CW -438
#define LOC_MODE -436
#define STR_MODE -352
#define VAL_MODE -350
#define CUR_MS_STAT -348
#define V_HID_CNT -346
#define CUR_X -344
#define CUR_Y -342
#define CUR_FLAG -340
#define MOUSE_FLAG -339
#define V_SAV_X -334
#define V_SAV_Y -332
#define SAVE_LEN -330
#define SAVE_ADR -328
#define SAVE_STAT -324
#define SAVE_AREA -322
#define USER_TIM -66
#define NEXT_TIM -62
#define USER_BUT -58
#define USER_CUR -54
#define USER_MOT -50
#define V_CEL_HT -46
#define V_CEL_MX -44
#define V_CEL_MY -42
#define V_CEL_WR -40
#define V_COL_BG -38
#define V_COL_FG -36
#define V_CUR_AD -34
#define V_CUR_OFF -30
#define V_CUR_X -28
#define V_CUR_Y -26
#define V_PERIOD -24
#define V_CUR_CT -23
#define V_FNT_AD -22
#define V_FNT_ND -18
#define V_FNT_ST -16
#define V_FNT_WD -14
#define V_REZ_HZ -12
#define V_OFF_AD -10
#define V_STAT_0 -6
#define V_DELAY -5
#define V_REZ_VT -4
#define BYTES_LN -2
#define V_PLANES 0
#define V_LIN_WR 2
#define _WRT_MODE 36
#define _X1 38
#define _Y1 40
#define _X2 42
#define _Y2 44
#define _PATPTR 46
#define _PATMSK 50
#define _MULTIFILL 52
#define _CLIP 54
#define _XMN_CLIP 56
#define _YMN_CLIP 58
#define _XMX_CLIP 60
#define _YMX_CLIP 62
#define _DDA_INC 66
#define _T_SCLSTS 68
#define _MONO_STATUS 70
#define _SOURCE_X 72
#define _SOURCE_Y 74
#define _DESTX 76
#define _DESTY 78
#define _DELX 80
#define _DELY 82
#define _FBASE 84
#define _FWIDTH 88
#define _STYLE 90
#define _SCALE 102
#define _CHUP 104
#define REQ_COL48E 174 // 240 colors RVB TOS 4.XX FALCON
#define BYT_PER_PIX 2822
#define FORM_ID 2824   // scrn form 2 ST, 1 stndrd, 3 pix
#define VL_COL_BG 2826
#define VL_COL_FG 2830
#define PAL_MAP 2834

#define STANDARD    1 // flag for standard format
#define INTERLEAVED 2 // flag for interlieved planes
#define PIXPACKED   3 // flag for pixel packed

/* workstation */
#define CHUP 0
#define CLIP 2
#define ADR_FONT 4
#define MULTIFILL 10
#define PATMSK 12
#define PATPTR 14
#define SCRTCHP 20
#define SCRPT2 24
#define STYLE 26
#define FILL_COLOR_INDEX 30
#define FILL_STYLE_INDEX 32
#define FILL_PER_VISIB 34
#define FILL_INT_STYLE 36
#define HORIZONTAL_ALIGN 38
#define HANDLE 40
#define BEGIN_STYLE 42
#define LINE_COLOR_INDEX 44
#define END_STYLE 46
#define LINE_TYPE 48
#define LINE_WIDTH 50
#define LOADED_FONTS 52
#define MARK_COLOR_INDEX 56
#define MARK_HEIGHT 58
#define MARK_TYPE 60
#define MARK_SCALE 62
#define NEXT_WORK 64
#define NUM_FONTS 68
#define TEXT_COLOR_INDEX 162
#define USER_DEF_LINE_STYLE_PAT 164
#define USER_DEF_FILL_PAT 166
#define VERTICAL_ALIGN 1190 // special TOS 4.XX FALCON
#define WRT_MODE 1192
#define XMN_CLIP 1196
#define XMX_CLIP 1198
#define YMN_CLIP 1200
#define YMX_CLIP 1202
#define FVDI_WORK 1204

/* font */
#define FACE_ID 0
#define FONT_SIZE 2
#define FONT_NAME 4
#define FIRST_ADE 36
#define LAST_ADE 38
#define TOP_LINE 40
#define ASCENT_LINE 42
#define HALF_LINE 44
#define DESCENT_LINE 46
#define BOTTOM_LINE 48
#define CHARACTER_WIDTH 50
#define CELL_WIDTH 52
#define LEFT_OFFSET 54
#define RIGTH_OFFSET 56
#define THICKENING 58
#define FONTFLAGS 66
#define HOR_OFF_TABLE 68
#define CHAR_OFF_TABLE 72
#define FONTDAT 76
#define FORMWIDTH 80
#define FORMHEIGHT 82
#define NEXT_FONT 84

	.global _init_det_vdi,_end_vdi,_copy_det_vdi,_det_vdi,_old_vector_vdi
	.global _opnwk,_clswk,_resolution,_colours
	.global _wide_line,_allocate_block,_free_block,_copy_line
	.global _fill_poly,_filled_poly,_fill_spans,_solid,_pattern_ptrs
	.global _ellipsearc,_c_pline,_rounded_box,_contourfill,_get_color,_pixelread,_end_pts
	.global _vq_chcells,_v_exit_cur,_v_enter_cur,_v_curup
	.global _v_curdown,_v_curright,_v_curleft,_v_curhome
	.global _v_eeos,_v_eeol,_vs_curaddress,_v_curtext
	.global _v_rvon,_v_rvoff,_vq_curaddress,_vq_tabstatus
	.global _fill_area,_get_extent,_draw_text,_lib_vr_trnfm,lib_vrt_cpyfm
	.global _init_var_linea,_linea_fonts,_flip_words,_flip_longs
	.global _c_get_videoramaddress,_c_get_width_virtual,_c_get_height_virtual,_c_get_bpp_virtual
	.global _eddi_cookie,_oldmouse,show_c,hide_c
	.global _init_screen,_clear_screen,_move_screen,_print_screen,_memmove
#ifdef COLDFIRE
	.global _dma_transfer
#endif
	.global _c_blit_area,_c_line_draw,_default_line,_c_fill_area,_default_fill
	.global _c_expand_area,_c_fill_polygon
#ifdef DEBUG
	.global display_string,hex_long,hex_word,hex_byte,display_char,wait_key,_debug
	.global _display_string,_display_char,_hex_byte,_hex_word,_hex_long,vdu
#endif
	.global _flag_mouse,_os_magic
	.global adr_var_vdi,adr_linea_fonts,adr_linea_atab // for det_linea / MagiC
	.global _virt_work,_V_OPNWK,_V_CLSWK,_V_OPNVWK,_V_CLSVWK,_LINE_STYLE,_init_choice_fill,_tick_int
	.global _cursconf,_update_mono,_mousexy
		
	.data

_init_det_vdi:

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
#else
	movem.l D0-D2/A0-A2,-(SP)
#endif
	move.l 28(SP),D0
	move.l D0,fvdi_virtual_default
	move.l D0,fvdi_virtual
	clr.l ok_statvec
#ifdef XAAES_SEMAPHORE
	clr.b semaphore
#endif
#ifdef COLDFIRE
	jsr 0xE09512             // TOS404
#else
	dc.w 0xA000
#endif
	move.l A0,adr_var_vdi
	move.l A1,adr_linea_fonts
	move.l A2,adr_linea_atab
#if 0
	tst.w _os_magic
	beq.s .not_os_magic
	move.l _sysbase,A1
	move.l 0x18(A1),D0       // date
	swap D0
	cmp.l #0x20010000,D0     // MagiC 6.20
	bcs.s .not_os_magic
	lea var_vdi,A1
	move.l a1,adr_var_vdi
	lea CUR_FONT(A0),A0
	lea CUR_FONT(A1),A1
	move.l #(-(CUR_FONT)+PAL_MAP+(256*4))/2,D0
.copy_var_vdi:
		move.w (A0)+,(A1)+
	subq.l #1,D0
	bgt.s .copy_var_vdi
.not_os_magic:
#endif
#ifdef COLDFIRE
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else
	movem.l (SP)+,D0-D2/A0-A2
#endif
	rts

_end_vdi:
	clr.l adr_var_vdi
	rts
	
init_type_video:

	moveq #1,D1
	move.b D1,direct_call    // faster
	clr.b use_videl
	tst.l D0
	bne.s .itv1              // PCI driver
	clr.b direct_call
	move.b D1,use_videl
.itv1:
	rts
	
#ifdef DEBUG

_hex_long:

	move.l 4(SP),D0
	bra hex_long

_hex_word:

	move.l 4(SP),D0
	bra hex_word

_hex_byte:

	move.l 4(SP),D0
	bra hex_byte

_display_char:
	move.l 4(SP),D0
	bra display_char

_display_string:

	move.l 4(SP),A0

#ifdef COLDFIRE // for interrupts

display_string:

	move.l D0,-(SP)
	move.l A0,-(SP)
.dds2:
		move.b (A0)+,D0
		beq.s .dds1
		bsr display_char
	bra.s .dds2
.dds1:
	move.l (SP)+,A0
	move.l (SP)+,D0
	rts

hex_long:
	move.l D0,-(SP)
	swap D0
	bsr.s hex_word
	move.l (SP)+,D0
hex_word:
	move.w D0,-(SP)
	lsr.l #8,D0          
	bsr.s hex_byte     
	move.w (SP)+,D0
hex_byte:
	move.w D0,-(SP)
	lsr.l #4,D0        
	bsr.s hex_char      
	move.w (SP)+,D0      
hex_char:
	and.l #0xF,D0      
	or.l #0x30,D0      
	cmp.l #0x3A,D0     
	bcs.s display_char  
	addq.l #7,D0   

display_char:

	move.l D1,-(SP)
.wait_uart:
	move.b MCF_UART_USR0,D1
	and.l  #MCF_UART_USR_TXRDY,D1
	beq.s .wait_uart
	move.b D0,MCF_UART_UTB0 // send the character
	move.l (SP)+,D1
	rts

#else

display_string:

#ifdef COLDFIRE
	move.l D0,-(SP)
	move.l A0,-(SP)
#else
	movem.l D0/A0,-(SP)

#endif
.os2:
		move.b (A0)+,D0
		beq.s .os1
		bsr display_char
	bra.s .os2
.os1:
#ifdef COLDFIRE
	move.l (SP)+,A0
	move.l (SP)+,D0
#else
	movem.l (SP)+,D0/A0
#endif
	rts

hex_long:
	move.l D0,-(SP)
	swap D0
	bsr.s hex_word
	move.l (SP)+,D0
hex_word:
	move.w D0,-(SP)
	lsr.l #8,D0          
	bsr.s hex_byte     
	move.w (SP)+,D0
hex_byte:
	move.w D0,-(SP)
	lsr.l #4,D0
	bsr.s hex_char      
	move.w (SP)+,D0      
hex_char:
	and.l #0xF,D0      
	or.l #0x30,D0      
	cmp.l #0x3A,D0     
	bcs.s display_char  
	addq.l #7,D0   

display_char:

#ifndef COLDFIRE
	jmp vdu
#else
#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
#else
	movem.l D0-D2/A0-A2,-(SP)
#endif
	move.w D0,-(SP)
	move.w #2,-(SP)
	move.w #3,-(SP)          // Bconout
	trap #13
	addq.l #6,SP
#ifdef COLDFIRE
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else
	movem.l (SP)+,D0-D2/A0-A2
#endif
	rts
#endif
	
#endif // COLDFIRE

display_tab:

#ifdef COLDFIRE
	move.l D1,-(SP)
#endif
	move.w D0,-(SP)
	moveq #0,D0
.dt1:
#ifdef COLDFIRE
		move.b (A0),D1
		extb.l D1
		cmp.l #-1,D1
		beq.s .dt3
		moveq #0,D1
		move.w (SP),D1
		cmp.l D1,D0
#else
		cmp.b #-1,(A0)
		beq.s .dt3
		cmp.w (SP),D0
#endif
		beq.s .dt4
.dt2:
		tst.b (A0)+
		bne.s .dt2
#ifdef COLDFIRE
		addq.l #1,D0
#else
		addq.w #1,D0
#endif
	bra.s .dt1
.dt4:
	bsr display_string
.dt3:
	addq.l #2,SP
#ifdef COLDFIRE
	move.l (SP)+,D1
#endif
	rts

wait_key:

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
#if 0 // #ifdef DEBUG
	move.w #1,-(SP)          // AUX
#else
	move.w #2,-(SP)          // CON
#endif
	move.w #2,-(SP)          // Bconin
	trap #13
	addq.l #4,SP
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else
	movem.l D0-D2/A0-A2,-(SP)
	move.w #7,-(SP)          // Crawcin
	trap #1
	addq.l #2,SP
	movem.l (SP)+,D0-D2/A0-A2
#endif
	rts
	
debug1:	.asciz "v_opnwk 0x"
debug2:	.ascii "no handle or invalid function"
	.byte 13,10,0
debug3:	.asciz "normal_ascii 0x"
debug4:	.asciz "esc_ch1 0x"
debug5:	.asciz "init_var_linea 0x"
debug6:	.ascii "init_var_vdi"
	.byte 13,10,0
debug7:	.ascii "init_var_fvdi"
	.byte 13,10,0

tab_debug_f:
	.byte 0
	.asciz "v_opnwk"            // 1
	.asciz "v_clswk"            // 2
	.asciz "v_clrwk"            // 3
	.asciz "v_updwk"            // 4
	.asciz "escapes"            // 5 ESCAPES
	.asciz "v_pline"            // 6 
	.asciz "v_pmarker"          // 7
	.asciz "v_gtext"            // 8
	.asciz "v_fillarea"         // 9
	.asciz "v_cellarray"        // 10
	.asciz "gdps"               // 11
	.asciz "vst_height"         // 12
	.asciz "vst_rotation"       // 13
	.asciz "vs_color"           // 14
	.asciz "vsl_type"           // 15
	.asciz "vsl_width"          // 16
	.asciz "vsl_color"          // 17
	.asciz "vsm_type"           // 18
	.asciz "vsm_height"         // 19
	.asciz "vsm_color"          // 20
	.asciz "vst_font"           // 21
	.asciz "vst_color"          // 22
	.asciz "vsf_interior"       // 23
	.asciz "vsf_style"          // 24
	.asciz "vsf_color"          // 25
	.asciz "vq_color"           // 26
	.asciz "vq_cellarray"       // 27
	.asciz "v_locator"          // 28 vrq_locator/vsm_locator
	.asciz "v_valuator"         // 29 vrq_valuator/vrm_valuator
	.asciz "v_choice"           // 30 vrq_choice/vrm_choice
	.asciz "v_string"           // 31 vrq_string/vrm_string
	.asciz "vswr_mode"          // 32
	.asciz "vsin_mode"          // 33
	.byte 0                     // 34
	.asciz "vql_attributes"     // 35
	.asciz "vqm_attributes"     // 36
	.asciz "vqf_attributes"     // 37
	.asciz "vqt_attributes"     // 38
	.asciz "vst_alignment"      // 39
	.rep 60
	.byte 0                     // opcodes 40-99
	.endr
	.asciz "v_opnvwk"           // 100
	.asciz "v_clsvwk"           // 101
	.asciz "vq_extend"          // 102
	.asciz "v_contourfill"      // 103
	.asciz "vsf_perimeter"      // 104
	.asciz "v_get_pixel"        // 105
	.asciz "vst_effects"        // 106
	.asciz "vst_point"          // 107
	.asciz "vsl_ends"           // 108
	.asciz "vro_cpyfm"          // 109
	.asciz "vr_trnfm"           // 110
	.asciz "vsc_form"           // 111
	.asciz "vsf_updat"          // 112
	.asciz "vsl_udsty"          // 113
	.asciz "vr_recfl"           // 114
	.asciz "vqin_mode"          // 115
	.asciz "vqt_extent"         // 116
	.asciz "vqt_width"          // 117
	.asciz "vex_time"           // 118
	.asciz "vst_load_fonts"     // 119
	.asciz "vst_unload_fonts"   // 120
	.asciz "vrt_cpyfm"          // 121
	.asciz "v_show_c"           // 122
	.asciz "v_hide_c"           // 123
	.asciz "vq_mouse"           // 124
	.asciz "vex_butv"           // 125
	.asciz "vex_motv"           // 126
	.asciz "vex_curv"           // 127
	.asciz "vq_key_s"           // 128
	.asciz "vs_clip"            // 129
	.asciz "vqt_name"           // 130
	.asciz "vqt_fontinfo"       // 131
	.byte 0                     // 132
	.byte 0                     // 133
	.asciz "vex_wheelv"         // 134 since Milan TOS 4.08

tab_debug_gdps_f:
	.asciz " v_bar"             // 1
	.asciz " v_arc"             // 2
	.asciz " v_pie"             // 3
	.asciz " v_circle"          // 4
	.asciz " v_ellipse"         // 5
	.asciz " v_ellarc"          // 6
	.asciz " v_ellpie"          // 7
	.asciz " v_rbox"            // 8
	.asciz " v_rfbox"           // 9
	.asciz " v_justified"       // 10
	
	.align 2

#endif	// DEBUG

#undef DEBUG

_GSX_ENTRY: /* for GDOS/Speedo/NVDI  */

#ifdef XAAES_SEMAPHORE
	moveq #0,D0
#ifdef COLDFIRE
	.chip 68060
#endif
	tas.b semaphore
#ifdef COLDFIRE
	.chip 5200
#endif
	bne.s .ge7               // another thread, hope that stack size is enough
#endif /* XAAES_SEMAPHORE */
	move.l SP,save_stack
	lea vdi_stack,SP
#ifdef XAAES_SEMAPHORE
	moveq #-1,D0
.ge7:
	move.w D0,-(SP)          // flag for restore stack
#endif /* XAAES_SEMAPHORE */
#ifdef COLDFIRE
	lea -20(SP),SP
	movem.l A0-A4,(SP)
#else
	movem.l A0-A4,-(SP)
#endif /* COLDFIRE */
	move.l D1,A1
	move.l (A1),A3           // CONTRL
	lea tab_vdi(PC),A4
#ifdef DEBUG
	moveq #0x2D,D0
	bsr display_char
	moveq #0,D0
	move.w (A3),D0           // opcode function
	lea tab_debug_f,A0
	bsr display_tab
	moveq #0x20,D0
	bsr display_char
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
#endif
#ifdef COLDFIRE
	moveq #0,D0
	move.w (A3),D0           // opcode function
	cmp.l #134,D0            // vex_wheelv
	bhi.s .ge3               // end
	move.w (A4,D0.l*2),D0
	bmi.s .ge3               // TOS function
	bclr #0,D0
	bne.s .ge2               // v_opnwk or v_opnvwk
	move.l D0,-(SP)
	move.l D1,-(SP)
	lea _virt_work,A2        // work_ptr
	move.w 12(A3),D0         // VDI handle	
.ge4:
		moveq #0,D1
		move.w HANDLE(A2),D1
		cmp.l D1,D0
		beq.s .ge5  // found handle
		move.l NEXT_WORK(A2),A2
	move.l A2,D1
	bne.s .ge4
	move.l (SP)+,D1
	bra.s .ge1                // no workstation	
.ge5:
	move.l (SP)+,D1
	move.l adr_var_vdi,A0
	move.l A2,CUR_WORK(A0)
	move.l FVDI_WORK(A2),D0
	move.l D0,fvdi_virtual
#else
	move.w (A3),D0           // opcode function
	cmp.w #134,D0            // vex_wheelv
	bhi.s .ge3               // end
	move.w (A4,D0.w*2),D0
	bmi.s .ge3               // TOS function
	bclr #0,D0
	bne.s .ge2               // v_opnwk or v_opnvwk
	move.l D0,-(SP)
	lea _virt_work,A2        // work_ptr
	move.w 12(A3),D0         // VDI handle	
.ge4:
		cmp.w HANDLE(A2),D0
		beq.s .ge5  // found handle
		move.l NEXT_WORK(A2),A2
	tst.l A2
	bne.s .ge4
	bra.s .ge1                // no workstation	
.ge5:
	move.l adr_var_vdi,A0
	move.l A2,CUR_WORK(A0)
	move.l FVDI_WORK(A2),fvdi_virtual
#endif
	move.l (SP)+,D0
.ge2:
#ifdef COLDFIRE
	jsr (A4,D0.l)
#else /* !COLDFIRE */
	jsr (A4,D0.w)
#endif /* COLDFIRE */
	bra.s .ge3
.ge1:
	addq.l #4,SP
.ge3:
#ifdef COLDFIRE
	movem.l (SP),A0-A4
	lea 20(SP),SP
#else /* !COLDFIRE */
	movem.l (SP)+,A0-A4
#endif /* COLDFIRE */
#ifdef XAAES_SEMAPHORE
	move.w (SP)+,D0
	beq.s .ge6
#endif
	move.l save_stack,SP
#ifdef XAAES_SEMAPHORE
.ge6:
	clr.b semaphore
#endif
	moveq #0,D0
	rts

.v1:
#ifdef COLDFIRE
	cmp.l #-1,D0
#else /* !COLDFIRE */
	cmp.w #-1,D0
#endif /* COLDFIRE */
	bne .v6
	move.l #_GSX_ENTRY,D0 /* for GDOS/NVDI */
	rte
.v11:
#ifdef COLDFIRE
	movem.l (SP),A0-A3
	lea 16(SP),SP
#else /* !COLDFIRE */
	movem.l (SP)+,A0-A3
#endif /* COLDFIRE */
	moveq #0x73,D0
#ifdef XAAES_SEMAPHORE
	clr.b semaphore
	tst.w (SP)+
	beq.s .v6
#endif
	move.l save_stack,SP
.v6:
	move.l _old_vector_vdi,-(SP)
	rts

_det_vdi:

#ifdef COLDFIRE
	ext.l D0
	cmp.l #0x73,D0           // VDI
	bne.s .v1
#ifdef XAAES_SEMAPHORE
	moveq #0,D0
	.chip 68060
	tas.b semaphore
	.chip 5200
	bne.s .v10               // another thread, hope that stack size is enough
#endif
	move.l SP,save_stack
	lea vdi_stack,SP
#ifdef XAAES_SEMAPHORE
	moveq #-1,D0
.v10:
	move.w D0,-(SP)          // flag for restore stack
#endif
	lea -16(SP),SP
	movem.l A0-A3,(SP)
#else /* !COLDFIRE */
	cmp.w #0x73,D0           // VDI
	bne.s .v1
#ifdef XAAES_SEMAPHORE
	moveq #0,D0
	tas.b semaphore
	bne.s .v10               // can't save stack
#endif
	move.l SP,save_stack
	lea vdi_stack,SP
#ifdef XAAES_SEMAPHORE
	moveq #-1,D0
.v10:
	move.w D0,-(SP)          // flag for restore stack
#endif /* XAAES_SEMAPHORE */
	movem.l A0-A3,-(SP)
#endif /* COLDFIRE */
	move.l D1,A1
	move.l (A1),A3           // CONTRL
#ifdef DEBUG
	moveq #0,D0
	move.w (A3),D0           // opcode function
	cmp.l #0x1F,D0
	beq.s .vx
	cmp.l #0x21,D0
	beq.s .vx
	cmp.l #0x7C,D0
	beq.s .vx
	cmp.l #0x80,D0
	beq.s .vx
	lea tab_debug_f,A0
	bsr display_tab
	moveq #0x20,D0
	bsr display_char
#if 0
	moveq #0x30,D0
	bsr display_char
	moveq #0x78,D0
	bsr display_char
	move.w 12(A3),D0         // VDI handle
	bsr hex_word
#endif
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
.vx:
#endif
#ifdef COLDFIRE
	moveq #0,D0
	move.w (A3),D0           // opcode function
	cmp.l #134,D0            // vex_wheelv
	bhi.s .v5                // end
	move.w tab_vdi(PC,D0.l*2),D0
	bmi.s .v3                // TOS function
	bclr #0,D0
	bne.s .v2                // v_opnwk or v_opnvwk
	move.l D0,-(SP)
	move.l D1,-(SP)
	lea _virt_work,A2        // work_ptr
	move.w 12(A3),D0         // VDI handle	
.v8:
		moveq #0,D1
		move.w HANDLE(A2),D1
		cmp.l D1,D0
		beq.s .v9  // found handle
		move.l NEXT_WORK(A2),A2
	move.l A2,D1
	bne.s .v8
	move.l (SP)+,D1
	bra .v4                 // no workstation	
.v9:
	move.l (SP)+,D1
	move.l adr_var_vdi,A0
	move.l A2,CUR_WORK(A0)
	move.l FVDI_WORK(A2),D0
	move.l D0,fvdi_virtual
#else
	move.w (A3),D0           // opcode function
	cmp.w #134,D0            // vex_wheelv
	bhi.s .v5                // end
	move.w tab_vdi(PC,D0.w*2),D0
	bmi.s .v3                // TOS function
	bclr #0,D0
	bne.s .v2                // v_opnwk or v_opnvwk
	move.l D0,-(SP)
	lea _virt_work,A2        // work_ptr
	move.w 12(A3),D0         // VDI handle	
.v8:
		cmp.w HANDLE(A2),D0
		beq.s .v9  // found handle
		move.l NEXT_WORK(A2),A2
	tst.l A2
	bne.s .v8
	bra .v4                 // no workstation	
.v9:
	move.l adr_var_vdi,A0
	move.l A2,CUR_WORK(A0)
	move.l FVDI_WORK(A2),fvdi_virtual
#endif
	move.l (SP)+,D0
.v2:
#ifdef COLDFIRE
	jsr tab_vdi(PC,D0.l)
.v7:
	movem.l (SP),A0-A3
	lea 16(SP),SP
#else /* !COLDFIRE */
	jsr tab_vdi(PC,D0.w)
.v7:
	movem.l (SP)+,A0-A3
#endif /* COLDFIRE */
#ifdef XAAES_SEMAPHORE
	move.w (SP)+,D0
	beq.s .v12
#endif
	move.l save_stack,SP
#ifdef XAAES_SEMAPHORE
.v12:
	clr.b semaphore
#endif
	moveq #0,D0
	rte
.v4:
	addq.l #4,SP
.v5:
#ifdef DEBUG
//	lea debug2,A0
//	bsr display_string
#endif
	bra.s .v7
.v3:
	jmp .v11

tab_vdi:                              // functions 1 to 131                 
	dc.w -1                       
	dc.w det_v_opnwk-tab_vdi+1          // 1
	dc.w det_v_clswk-tab_vdi            // 2
	dc.w det_v_clrwk-tab_vdi            // 3
	dc.w -1                             // 4 v_updwk
	dc.w det_escapes-tab_vdi            // 5 ESCAPES
	dc.w det_v_pline-tab_vdi            // 6 
	dc.w det_v_pmarker-tab_vdi          // 7
	dc.w det_v_gtext-tab_vdi            // 8
	dc.w det_v_fillarea-tab_vdi         // 9
	dc.w det_v_cellarray-tab_vdi        // 10
	dc.w det_gdps-tab_vdi               // 11
	dc.w det_vst_height-tab_vdi         // 12
	dc.w det_vst_rotation-tab_vdi       // 13
	dc.w det_vs_color-tab_vdi           // 14
	dc.w det_vsl_type-tab_vdi           // 15
	dc.w det_vsl_width-tab_vdi          // 16
	dc.w det_vsl_color-tab_vdi          // 17
	dc.w det_vsm_type-tab_vdi           // 18
	dc.w det_vsm_height-tab_vdi         // 19
	dc.w det_vsm_color-tab_vdi          // 20
	dc.w det_vst_font-tab_vdi           // 21
	dc.w det_vst_color-tab_vdi          // 22
	dc.w det_vsf_interior-tab_vdi       // 23
	dc.w det_vsf_style-tab_vdi          // 24
	dc.w det_vsf_color-tab_vdi          // 25
	dc.w det_vq_color-tab_vdi           // 26
	dc.w det_vq_cellarray-tab_vdi       // 27
	dc.w det_v_locator-tab_vdi          // 28 vrq_locator/vsm_locator
	dc.w det_v_valuator-tab_vdi         // 29 vrq_valuator/vrm_locator
	dc.w det_v_choice-tab_vdi           // 30 vrq_choice/vrm_choice
	dc.w det_v_string-tab_vdi           // 31 vrq_string/vrm_string
	dc.w det_vswr_mode-tab_vdi          // 32
	dc.w det_vsin_mode-tab_vdi          // 33
	dc.w -1                             // 34
	dc.w det_vql_attributes-tab_vdi     // 35
	dc.w det_vqm_attributes-tab_vdi     // 36
	dc.w det_vqf_attributes-tab_vdi     // 37
	dc.w det_vqt_attributes-tab_vdi     // 38
	dc.w det_vst_alignment-tab_vdi      // 39
	.rep 60
	dc.w -1                             // opcodes 40-99
	.endr
	dc.w det_v_opnvwk-tab_vdi+1         // 100
	dc.w det_v_clsvwk-tab_vdi           // 101
	dc.w det_vq_extend-tab_vdi          // 102
	dc.w det_v_contourfill-tab_vdi      // 103
	dc.w det_vsf_perimeter-tab_vdi      // 104
	dc.w det_v_get_pixel-tab_vdi        // 105
	dc.w det_vst_effects-tab_vdi        // 106
	dc.w det_vst_point-tab_vdi          // 107
	dc.w det_vsl_ends-tab_vdi           // 108
	dc.w det_vro_cpyfm-tab_vdi          // 109
	dc.w det_vr_trnfm-tab_vdi           // 110
	dc.w det_vsc_form-tab_vdi           // 111
	dc.w det_vsf_updat-tab_vdi          // 112
	dc.w det_vsl_udsty-tab_vdi          // 113
	dc.w det_vr_recfl-tab_vdi           // 114
	dc.w det_vqin_mode-tab_vdi          // 115
	dc.w det_vqt_extent-tab_vdi         // 116
	dc.w det_vqt_width-tab_vdi          // 117
	dc.w det_vex_time-tab_vdi           // 118
	dc.w det_vst_load_fonts-tab_vdi     // 119
	dc.w det_vst_unload_fonts-tab_vdi   // 120
	dc.w det_vrt_cpyfm-tab_vdi          // 121
	dc.w det_v_show_c-tab_vdi           // 122
	dc.w det_v_hide_c-tab_vdi           // 123
	dc.w det_vq_mouse-tab_vdi           // 124
	dc.w det_vex_butv-tab_vdi           // 125
	dc.w det_vex_motv-tab_vdi           // 126
	dc.w det_vex_curv-tab_vdi           // 127
	dc.w det_vq_key_s-tab_vdi           // 128
	dc.w det_vs_clip-tab_vdi            // 129
	dc.w det_vqt_name-tab_vdi           // 130
	dc.w det_vqt_fontinfo-tab_vdi       // 131
	dc.w -1                             // 132
	dc.w -1                             // 133
	dc.w det_vex_wheelv-tab_vdi         // 134 since Milan TOS 4.08

det_v_opnwk:

	move.l D1,-(SP)
	move.l D2,-(SP)
#ifdef COLDFIRE
	moveq #6,D0
	move.w D0,4(A3)          // nb points PTSOUT
	moveq #45,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #6,4(A3)          // nb points PTSOUT
	move.w #45,8(A3)         // length tab INTOUT
#endif
#ifdef DEBUG
	lea debug1,A0
	bsr display_string
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	moveq #0x30,D0
	bsr display_char
	moveq #0x78,D0
	bsr display_char
	move.l 16(A1),A0         // PTSOUT
	move.w (A0),D0
	bsr hex_word
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
#endif
	move.l A1,-(SP)
	move.l 16(A1),-(SP)      // PTSOUT
	move.l 12(A1),D0         // INTOUT
	move.l D0,save_intout    // for init_var_vdi
	move.l D0,-(SP)          // INTOUT
	move.l 4(A1),-(SP)       // INTIN
	move.l adr_var_vdi,-(SP)
	jsr _V_OPNWK
	lea 16(SP),SP
	move.l (SP)+,A1
	move.w D0,12(A3)         // CONTRL[6]
	beq .owk3                // error (not INTIN[0] for screen)
	move.l adr_var_vdi,A0
	move.l CUR_WORK(A0),A0
	move.l FVDI_WORK(A0),A0  // Mxalloc for buffer inside V_OPNWK
	move.l A0,fvdi_virtual
	clr.w _resolution        // resolution.used
	move.l fvdi_virtual,-(SP)
	jsr _opnwk
	move.l #-1,(SP)          // video_found => no change
	bsr _init_var_linea      // if res has no change
	addq.l #4,SP
	jsr _init_screen         // ESC E, ...
	bsr init_var_vdi
	bsr init_var_fvdi
	bsr find_default_font
	move.l fvdi_virtual,A1
	clr.l vwk_palette(A1)
	move.l A1,-(SP)
	move.w #3,-(SP)          // TT ram if possible
	move.l #256*colour_struct_size,-(SP)    // size
	move.w #0x44,-(SP)       // Mxalloc
	trap #1 
	addq.l #8,SP
	move.l (SP)+,A1
	move.l vwk_real_address(A1),A0
	move.l adr_var_vdi,A2
	move.l wk_driver(A0),A1
	move.l driver_device(A1),A1
	move.w dev_format(A1),D2
	ext.l D2
	moveq #INTERLEAVED,D1
	cmp.l #2,D2              // packed pixels
	bne.s .owk2
	moveq #PIXPACKED,D1
.owk2:
	move.w D1,FORM_ID(A2)
	move.w DEV_TAB+26(A2),wk_screen_palette_size(A0) // nb colors
	move.l D0,wk_screen_palette_colours(A0) // malloc buffer global
	beq.s .owk1
	move.l D0,A2
	move.l A3,-(SP)
	move.l #0x1000000,D0
	lea _colours,A1          // default colors fVDI
/*--------
* Set palette colours
* c_set_colours(Virtual *vwk, long start, long entries, short requested[3][], Colour palette[])
* In:	a0	VDI struct
*	d0	number of entries (H), start entry (L)
*	a1	requested colour values (3 word/entry)
*	a2	colour palette
*-------*/
	move.l fvdi_virtual,A0
	move.l A2,vwk_palette(A0)
	move.l vwk_real_address(A0),A3
	move.l wk_r_set_palette(A3),A3
	jsr (A3)
	move.l (SP)+,A3
.owk1:
	bsr mouse_init           // init the mouse
	move.l adr_var_vdi,A0    // destroyed before
	bsr escf	            // disable text cursor
.owk3:
	move.l (SP)+,D2
	move.l (SP)+,D1
	rts

det_v_clswk:

	move.l D1,-(SP)
	bsr dinit_mouse
	bsr esce                 // enable text cursor
	move.l fvdi_virtual,-(SP)
	jsr _clswk
	addq.l #4,SP
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A0
	move.l wk_screen_palette_colours(A0),D0 // global
	ble.s .cwk1
	clr.l wk_screen_palette_colours(A0) 
	move.l D0,-(SP)
	move.w #0x49,-(SP)       // Mfree
	trap #1 
	addq.l #6,SP	
.cwk1:
	move.l adr_var_vdi,-(sp)
	jsr _V_CLSWK
	addq.l #4,SP
	move.l (SP)+,D1
	rts
	
det_v_clrwk:

#ifdef COLDFIRE
	lea -32(SP),SP
	movem.l D1-D7/A4,(SP)
#else
	movem.l D1-D7/A4,-(SP)
#endif
	tst.b use_videl
	bne.s .clrw6            // Videl driver
	moveq #-1,D0
	move.l D0,-(SP)
	jsr _clear_screen
	addq.l #4,SP
	bra .clrw2
.clrw6:
	moveq #0,D0              // color index
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A3
	move.l wk_r_get_colour(A3),A3 // index to real colour
	jsr (A3)
	move.l D0,D2
	move.l adr_var_vdi,A0
#ifdef COLDFIRE
	moveq #0,D0
	move.w V_PLANES(A0),D0   // nb planes
	cmp.l #16,D0
#else
	move.w V_PLANES(A0),D0   // nb planes
	cmp.w #16,D0
#endif
	bhi.s .clrw1
	bcs.s .clrw5
	swap D2
	move.w D0,D2
	bra.s .clrw1
.clrw5:
	asl.l #8,D2
	move.b D0,D2
	asl.l #8,D2
	move.b D0,D2	
	asl.l #8,D2
	move.b D0,D2
.clrw1:
#ifdef COLDFIRE
	moveq #0,D0
	move.w V_PLANES(A0),D0   // nb planes
	lsr.l #3,D0              // / 8
#else
	move.w V_PLANES(A0),D0   // nb planes
	lsr.w #3,D0              // / 8
#endif
	move.w V_REZ_HZ(A0),D1   // width screen
	mulu D1,D0               // bytes / line
	move.w V_REZ_VT(A0),D1   // height screen
	mulu D1,D0               // total bytes
	move.l _v_bas_ad,A4
	add.l D0,A4              // end screen
	lsr.l #7,D0
	move.l D2,D1
	move.l D2,D3
	move.l D2,D3
	move.l D2,D4
	move.l D2,D5
	move.l D2,D6
	move.l D2,D7
	move.l D2,A0
	bra.s .clrw4
.clrw3:
#ifdef COLDFIRE
		lea -32(SP),SP
		movem.l D1-A0,(A4)
		lea -32(SP),SP
		movem.l D1-A0,(A4)
		lea -32(SP),SP
		movem.l D1-A0,(A4)
		lea -32(SP),SP
		movem.l D1-A0,(A4)
.clrw4:
	subq.l #1,D0
	bpl.s .clrw3
#else
		movem.l D1-A0,-(A4)
		movem.l D1-A0,-(A4)
		movem.l D1-A0,-(A4)
		movem.l D1-A0,-(A4)
.clrw4:
	dbf D0,.clrw3
#endif
.clrw2:
#ifdef COLDFIRE
	movem.l (SP),D1-D7/A4
	lea 32(SP),SP
#else
	movem.l (SP)+,D1-D7/A4
#endif
	rts

det_escapes:

#ifdef COLDFIRE
	moveq #0,D0
	move.w 10(A3),D0         // sub-function
	subq.l #1,D0
	bmi.s .de1
	cmp.l #23,D0
	bcc.s .de1
	add.l D0,D0
	move.w tab_escapes(PC,D0.l),D0
	bmi.s .de2               // TOS function
	jmp tab_escapes(PC,D0.l)
#else /* !COLDFIRE */
	move.w 10(A3),D0         // sub-function
	subq.w #1,D0
	bmi.s .de1
	cmp.w #23,D0
	bcc.s .de1
	add.w D0,D0
	move.w tab_escapes(PC,D0.w),D0
	bmi.s .de2               // TOS function
	jmp tab_escapes(PC,D0.w)
#endif /* COLDFIRE */
.de1:
	rts
.de2:
	lea tab_vdi(PC),A0
	cmp.l A4,A0
	beq.s .de1               // call from _GSX_ENTRY
	addq.l #4,SP             // pop return address
#ifdef COLDFIRE
	movem.l (SP),A0-A3
	lea 16(SP),SP
#else
	movem.l (SP)+,A0-A3
#endif
#ifdef XAAES_SEMAPHORE
	move.w (SP)+,D0
	beq.s .de3
#endif
	move.l save_stack,SP
#ifdef XAAES_SEMAPHORE
.de3:
	clr.b semaphore
#endif
	moveq #0x73,D0
	move.l _old_vector_vdi,-(SP)
	rts

tab_escapes:
	dc.w det_vq_chcells-tab_escapes    // ESC 1
	dc.w det_v_exit_cur-tab_escapes    // ESC 2
	dc.w det_v_enter_cur-tab_escapes   // ESC 3
	dc.w det_v_curup-tab_escapes       // ESC 4
	dc.w det_v_curdown-tab_escapes     // ESC 5
	dc.w det_v_curright-tab_escapes    // ESC 6
	dc.w det_v_curleft-tab_escapes     // ESC 7
	dc.w det_v_curhome-tab_escapes     // ESC 8
	dc.w det_v_eeos-tab_escapes        // ESC 9
	dc.w det_v_eeol-tab_escapes        // ESC 10
	dc.w det_vs_curaddress-tab_escapes // ESC 11
	dc.w det_v_curtext-tab_escapes     // ESC 12
	dc.w det_v_rvon-tab_escapes        // ESC 13
	dc.w det_v_rvoff-tab_escapes       // ESC 14
	dc.w det_vq_curaddress-tab_escapes // ESC 15
	dc.w -1 // vq_tabstatus            // ESC 16
	dc.w det_v_hardcopy-tab_escapes    // ESC 17
	dc.w det_v_dspcur-tab_escapes      // ESC 18
	dc.w det_v_rmcur-tab_escapes       // ESC 19
	dc.w -1 // v_form_adv              // ESC 20
	dc.w -1 // v_output_window         // ESC 21
	dc.w -1 // v_clear_disp_list       // ESC 22
	dc.w -1 // v_bit_image             // ESC 23

det_vq_chcells:

#ifdef COLDFIRE
	moveq #2,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #2,8(A3)          // length tab INTOUT
#endif
	move.l 12(A1),A3         // INTOUT
	move.w V_CEL_MY(A0),D0
	addq.l #1,D0
	move.w D0,(A3)+
	move.w V_CEL_MX(A0),D0
	addq.l #1,D0
	move.w D0,(A3)
	rts

det_v_exit_cur:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escf                 // hide cursor
	bsr escE                 // clear screen and home cursor	
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_enter_cur:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	tst.b use_videl
	bne.s .vec1              // Videl driver
	move.l A0,-(SP)
	moveq #-1,D0
	move.l D0,-(SP)          // init
	jsr _print_screen
	addq.l #4,SP
	move.l (SP)+,A0
.vec1:
	bsr escE                 // clear screen and home cursor	
	bsr esce                 // enable cursor
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_v_curup:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn4               // alpha cursor up 
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_curdown:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn5               // alpha cursor down
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_v_curright:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn6               // alpha cursor right 
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_curleft:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn7               // alpha cursor left
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_curhome:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn8               // home cursor	
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_eeos:
	
#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn9               // erase to end of screen
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_v_eeol:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn10              // erase to end of line
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_vs_curaddress:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	move.l 4(A1),A3          // INTIN
	move.w (A3)+,D1
	subq.l #1,D1             // y
	move.w (A3),D0
	subq.l #1,D0             // x
	bsr move_cursor
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_curtext:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	moveq #0,D0
	move.w 6(A3),D0          // length tab INTIN
	move.l 4(A1),A0          // INTIN -> character array.
	bra.s ef12_lend
ef12_loop:
		move.w (A0)+,D1
		move.l D0,-(SP)
		move.l A0,-(SP)
		and.l #0xff,D1
		move.l con_state,A0
		jsr (A0)
		move.l (SP)+,A0
		move.l (SP)+,D0
ef12_lend:
	subq.l #1,D0
	bpl.s ef12_loop
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_rvon:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn13              // reverse video on
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_v_rvoff:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	bsr escfn14              // reverse video off
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_vq_curaddress:

#ifdef COLDFIRE
	moveq #2,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #2,8(A3)          // length tab INTOUT
#endif
	move.l 12(A1),A3         // INTOUT
	move.w V_CUR_Y(A0),D0
	addq.l #1,D0
	move.w D0,(A3)+
	move.w V_CUR_X(A0),D0
	addq.l #1,D0
	move.w D0,(A3)
	rts
	
det_v_hardcopy:

	bsr escfn17              // hardcopy
	rts
	
det_v_dspcur:

	moveq #1,D0              // no reset
	bsr show_c
	rts
	
det_v_rmcur:

	bsr hide_c
	rts

/*
 * escape E -  Clear Screen and Home Cursor	
 */
escE:

	bsr escfn8               // home cursor
	bra escfn9               // erase to end of screen
	
/*
 * escfn4 - Alpha Cursor Up 
 */
escA:
escfn4:

	move.w V_CUR_Y(A0),D1    // current cursor y
	beq esc_end
up_cursor:
	subq.l #1,D1             // move the cursor up
	move.w V_CUR_X(A0),D0
	bra.s move_cursor        // update cursor position and globals.

/*
 * escfn5 - Alpha Cursor Down
 */
escB:
escfn5:

	move.w V_CUR_Y(A0),D1    // current cursor y
	ext.l D1
	move.w V_CEL_MY(A0),D0
	ext.l D0
	cmp.l D0,D1
	beq esc_end
down_cursor:
	addq.l #1,D1             // move the cursor down
	move.w V_CUR_X(A0),D0
	bra.s move_cursor        // update cursor position and globals

/*
 * escfn6 - Alpha Cursor Right 
 */
escC:
escfn6:

	move.w V_CUR_X(A0),D0    // current cursor x
	ext.l D0
	move.w V_CEL_MX(A0),D1
	ext.l D1
	cmp.l D1,D0
	beq esc_end
	addq.l #1,D0             // move the cursor right
	move.w V_CUR_Y(A0),D1
	bra.s move_cursor        // update cursor position and globals

/*
 * escfn7 - Alpha Cursor Left
 */
escD:
escfn7:

	move.w V_CUR_X(A0),D0    // current cursor x
	beq esc_end
	subq.l #1,D0             // move the cursor left
	move.w V_CUR_Y(A0),D1
	bra.s move_cursor        // update cursor position and globals.

/*
 * escfn8 - Home Alpha Cursor
 */
escH:
escfn8:

	moveq #0,D0              // x coord (fixed)
	moveq #0,D1              // y coord

move_cursor:                          // update cell position

	move.w V_HID_CNT(A0),D2
	addq.l #1,D2
	move.w D2,V_HID_CNT(A0)  // begin critical section
	bclr #F_CSTATE,V_STAT_0(A0) // is curs currently displayed ?
	beq.s invisible          // if it isn't, don't invert it.
	bsr neg_cell             // erase it now
invisible:
	bsr cell_addr
	bra show_alpha           // end critical section

/*
 * escfn9 - Erase to End of Screen
 */
escJ:
escfn9:

	bsr escfn10              // erase to end of line
	moveq #0,D0
	moveq #0,D1
	move.w V_CUR_Y(A0),D1
	move.w V_CEL_MY(A0),D0   // last line?
	cmp.l D0,D1
	beq esc_end              // yes, done
	addq.l #1,D1             // no, drop down a line
	swap D1
	clr.w D1                 // upper left corner
	move.w V_CEL_MY(A0),D2
	swap D2
	move.w V_CEL_MX(A0),D2   // lower right corner
	bra blnk_blt             // erase rest of screen

/*
 * escfn10 - Erase to End of Line.
 */
escK:
escfn10:

	move.w V_CUR_Y(A0),D1
	move.w D1,D2
	swap D1
	move.w V_CUR_X(A0),D1    // upper left coords
	swap D2
	move.w V_CEL_MX(A0),D2   // lower right coords
	bra blnk_blt

/*
 * escfn13 - Reverse Video On
 */
escp:
escfn13:

	bset #F_REVID,V_STAT_0(A0) // set the reverse bit
esc_end:
	rts

/*
 * escfn14 - Reverse Video Off
 */
escq:
escfn14:

	bclr #F_REVID,V_STAT_0(A0) // clear the reverse bit
	rts
	
/*
 * escfn17 - Hardcopy
 */
escfn17:

#ifdef COLDFIRE
	lea -52(SP),SP
	movem.l D1-D7/A1-A6,(SP)
#else
	movem.l D1-D7/A1-A6,-(SP)
#endif
#if 1

	move.l dump_vec,A0
	jsr (A0)
	moveq #-1,D0
	move.w D0,_dumpflg
#else
	move.w #0x14,-(SP)       // Scrdmp
	trap #14                 // XBIOS
	addq.l #2,SP
#endif
#ifdef COLDFIRE
	movem.l D1-D7/A1-A6,(SP)
	lea 52(SP),SP
#else
	movem.l (SP)+,D1-D7/A1-A6
#endif
	rts
	
/*
 * escape I - Reverse Index
 */
escI:

	move.w V_CUR_Y(A0),D1    // current cursor Y
	bne up_cursor            // if not at top, move cursor up 1 line
	bsr hide_cursor
	bsr p_sc_dwn             // scroll screen down 1 line and
	bra show_cursor          // blank the top line

/*
 * escape L - Insert Line
 */
escL:

	bsr hide_cursor
	move.w V_CUR_Y(A0),D1    // Ymin of scroll region
	bsr p_sc_dwn	            // scroll down 1 line. insert blank line
start_o_line:
	moveq #0,D0              // X of beginning of line
	move.w V_CUR_Y(A0),D1    // current Y
	bsr move_cursor
	bra show_cursor

/*
 * escape M - Delete Line
 */
escM:

	bsr hide_cursor          // hide cursor
	move.w V_CUR_Y(A0),D1    // line to begin scrolling up
	bsr p_sc_up              // scroll up 1 line & blank bottom line.
	bra start_o_line

/*
 * escape d - Erase from Beginning of Page
 */
escd:

	bsr esco                 // erase from beginning of line
	move.w V_CUR_Y(A0),D2    // first line?
	beq esc_end              // yes, done
             subq.l #1,D2             // no, move up a line
	swap D2
	move.w V_CEL_MX(A0),D2   // lower right coord
	moveq #0,D1              // upper left coord
	bra blnk_blt             // erase rest of screen
	
/*
 * escape e - Enable Cursor (always)
 */
esce:

	tst.w V_HID_CNT(A0)
	beq esc_end
enable_it:
	moveq #1,D0
	move.w D0,V_HID_CNT(A0)  // set up for cursor redisplay
	bra show_alpha	

show_cursor:

	moveq #0,D0
	move.w V_HID_CNT(A0),D0  // old count=0  =>  cursor is visible
	beq esc_end
	subq.l #1,D0             // new count=0  =>  redisplay cursor
	beq enable_it
	move.w D0,V_HID_CNT(A0)  // otherwise, record current count
	rts

/*
 * escape f - Disable Cursor (counted depth)
 */
escf:
hide_cursor:

	move.w V_HID_CNT(A0),D0
	addq.l #1,D0
	move.w D0,V_HID_CNT(A0)  // increment the disable counter
	bclr #F_CSTATE,V_STAT_0(A0)
	beq esc_end              // exit if cursor is currently invisible
	bra neg_cell             // turn cursor off

/*
 * escape j - Save Cursor Position
 */
escj:
	bset #F_SVPOS,V_STAT_0(A0) // set "pos saved" status bit
	move.l V_CUR_X(A0),CUR_X(A0)
	rts

/*
 * escape k - Restore Cursor Position
 */
esck:

	bclr #F_SVPOS,V_STAT_0(A0) // clear "position saved" status bit
	beq escH                 // if (X,Y) was not saved, home cursor
	move.w V_SAV_X(A0),D0    // saved X
	move.w V_SAV_Y(A0),D1    // saved Y
	bra move_cursor          // move cursor to saved position.

/*
 * escape l - Erase Entire Line
 */
escl:

	move.w V_CUR_Y(A0),D1
	move.w D1,D2
	swap D1
	clr.w D1                 // upper left coords. (0,y)
	swap D2
	move.w V_CEL_MX(A0),D2   // lower right coords. (max,y)
	bsr blnk_blt             // blank whole line
	bra move_cursor          // (d0,d1) is X,Y of beginning of line

/*
 * escape o - Erase from Beginning of Line.			     **
 */
esco:

	move.w V_CUR_Y(A0),D2
	move.w D2,D1
	swap D2
             move.w V_CUR_X(A0),D2    // lower right coords (x,y)
	swap D1
	clr.w D1                 // upper left coords. (0,y)
	bsr blnk_blt             // blank from beginning of line

/*
 * escape v - Wrap at End of Line
 */
escv:

	bset #F_CEOL,V_STAT_0(A0) // set the eol handling bit in v_stat_0
	rts

/*
 * escape w - Overwrite at End of Line
 */
escw:

	bclr #F_CEOL,V_STAT_0(A0) // clear the eol bit in v_stat_0
	rts

ascii_cr:

	moveq #0,D0              // X of beginning of line
	move.w V_CUR_Y(A0),D1    // current Y
	bra move_cursor

ascii_lf:

	moveq #0,D0
	moveq #0,D1
	move.w V_CUR_Y(A0),D1    // current cursor y
	move.w V_CEL_MY(A0),D0
	cmp.l D0,D1              // at bottom of screen?
	bne down_cursor          // no, move cursor down one line
	bsr hide_cursor
	moveq #0,D1              // scroll region starts at top of screen
	bsr p_sc_up              // scroll up 1 line & blank current line
	bra show_cursor

/*
 * p_sc_dwn - Scroll (partitially) downwards
 */
p_sc_dwn:

#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D0-D3/A0-A2,(SP)
#else
	movem.l D0-D3/A0-A2,-(SP)
#endif
	move.w V_LIN_WR(A0),D0   // line wrap
	mulu V_CEL_HT(A0),D0     // * cell height => v_cel_wr
	moveq #0,D3
	move.w V_CEL_MY(A0),D3   // max cell y # in d3
	mulu.l D0,D3             // form offset for bottom of second to last cell row
	tst.b use_videl
	bne.s videl_p_sc_dwn     // Videl driver	
	move.w D1,D0             // Y
	ext.l D0
	neg.l D0                 // do tricky subtract
	moveq #0,D2
	move.w V_CEL_MY(A0),D2
	add.l D2,D0              // to form # of cell rows to move
	mulu D0,D3               // form # of bytes to move in d3	
	mulu V_CEL_HT(A0),D0
        	move.l A0,-(SP)
	move.l D0,-(SP)          // h
	moveq #0,D0
	move.w V_REZ_HZ(A0),D0
	move.l D0,-(SP)          // w
	move.w D1,D0
	addq.l #1,D0
	move.l D0,-(SP)          // dst_y
	mulu V_CEL_HT(A0),D0        
	clr.l -(SP)              // dst_x
	move.w D1,D0
	mulu V_CEL_HT(A0),D0
	move.l D0,-(SP)          // src_y      
	clr.l -(SP)              // src_x
	jsr _move_screen
	lea 24(SP),SP
	bra.s end_p_sc_dwn
videl_p_sc_dwn:	
	move.l _v_bas_ad,A1      // screen base addr to source        
	lea (A1,D3.l),A1         // form source address
	lea (A1,D0.l),A2         // form destination from source + cell wrap
	move.w D1,D0             // y
	ext.l D0
	neg.l D0                 // do tricky subtract
	moveq #0,D2
	move.w V_CEL_MY(A0),D2
	add.l D2,D0              // to form # of cell rows to move
	mulu.l D0,D3             // form # of bytes to move in d3
	move.l D3,-(SP)          // move memory
	move.l A1,-(SP)          // source
	move.l A2,-(SP)          // dest
	jsr _memmove
	lea 12(SP),SP
end_p_sc_dwn:
#ifdef COLDFIRE
	movem.l (SP),D0-D3/A0-A2
	lea 28(SP),SP
#else
	movem.l (SP)+,D0-D3/A0-A2
#endif
	bra scr_out

/*
 * p_sc_up - Scroll upwards
 *
 * Scroll copies a source region as wide as the screen to an overlapping
 * destination region on a one cell-height offset basis.  Two entry points
 * are provided:  Partial-lower scroll-up, partial-lower scroll-down.
 * Partial-lower screen operations require the cell y # indicating the 
 * top line where scrolling will take place.
 *
 * After the copy is performed, any non-overlapping area of the previous
 * source region is "erased" by calling blnk_blt which fills the area
 * with the background color.
 *
 *     D1.W            cell y of cell line to be used as top line in scroll
 */
p_sc_up:

#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D0-D3/A0-A2,(SP)
#else
	movem.l D0-D3/A0-A2,-(SP)
#endif
	move.w V_LIN_WR(A0),D0   // line wrap
	mulu V_CEL_HT(A0),D0     // * cell height => v_cel_wr cell wrap to temp
	move.l D0,D3             // cell wrap to temp d3
	tst.b use_videl
	bne.s videl_p_sc_up
	move.w D1,D0
	ext.l D0
	neg.l D0
	moveq #0,D2
	move.w V_CEL_MY(A0),D2
	add.l D2,D0              // form (max-1) - top row # for total rows to move
	mulu D0,D3               // form # of bytes to move in d3
	mulu V_CEL_HT(A0),D0
	move.l D0,-(SP)          // h
	moveq #0,D0
	move.w V_REZ_HZ(A0),D0
	move.l D0,-(SP)          // w
	move.w D1,D0
	move.l D0,-(SP)          // dst_y
	mulu V_CEL_HT(A0),D0      
	clr.l -(SP)              // dst_x
	move.w D1,D0
	addq.l #1,D0
	mulu V_CEL_HT(A0),D0
	move.l D0,-(SP)          // src_y      
	clr.l -(SP)              // src_x
	jsr _move_screen
	lea 24(SP),SP
	bra.s end_p_sc_up
videl_p_sc_up:
	and.l #0xffff,D1
	mulu.l D1,D0             // cell y nbr //  cell wrap is destination offset
	move.l _v_bas_ad,A1      // get base addr to destination
	lea.l (A1,D0.l),A1       // form destination addr
	move.l D1,D0
	neg.l D0
	moveq #0,D2
	move.w V_CEL_MY(A0),D2
	add.l D2,D0              // form (max-1) - top row # for total rows to move
	lea.l (A1,D3.l),A2       // form source address from cell wrap + base address
	mulu.l D0,D3             // form # of bytes to move in d3
#ifdef COLDFIRE
	moveq #0,D0
	move.w V_PLANES(A0),D0
	lsr.l #3,D0              // / 8
	beq.s videl_p_sc_up2     // use memmove if < 256 colors
	moveq #4,D0
	move.l D0,-(SP)          // step
	clr.l -(SP)              // dest_incr
	clr.l -(SP)              // src_incr
	clr.l -(SP)              // width
	move.l D3,-(SP)          // size
	move.l A1,-(SP)          // dest
	move.l A2,-(SP)          // source
	jsr _dma_transfer
	move.l (SP)+,A2
	move.l (SP)+,A1
	lea 20(SP),SP
	tst.l D0
	beq.s end_p_sc_up        // OK
videl_p_sc_up2:
#endif     
	move.l D3,-(SP)          // move memory
	move.l A2,-(SP)          // source
	move.l A1,-(SP)          // dest
	jsr _memmove
	lea 12(SP),SP
end_p_sc_up:
#ifdef COLDFIRE
	movem.l (SP),D0-D3/A0-A2
	lea 28(SP),SP
#else
	movem.l (SP)+,D0-D3/A0-A2
#endif
	move.w V_CEL_MY(A0),D1   // bottom line cell address y to top/left cell

scr_out:
	move.w D1,D2             // for bottom/left cell too
	swap D1
	swap D2
	clr.w D1                 // top/left starts at left edge
	move.w V_CEL_MX(A0),D2   // maximum x for right edge on bottom/right
	bra blnk_blt             // blank whole line
	
cell_addr:
                                      // update cell position (A1) from X (D0.W), Y (D1.W)
	move.l D2,-(SP)
	move.l A2,-(SP)
	ext.l D0                 // X
	ext.l D1                 // Y
	moveq #0,D2
	move.w V_CEL_MX(A0),D2
	tst.w D0                 // test for negative x
	bge.s clip_x
	moveq #0,D0
	bra.s x_clipped
clip_x:
	cmp.l D0,D2
	bpl.s x_clipped
	move.l D2,D0             // clipped x
x_clipped:
	moveq #0,D2
	move.w V_CEL_MY(A0),D2
	tst.l D1                 // test for negative y
	bge.s clip_y
	moveq #0,D1
	bra.s y_clipped
clip_y:
	cmp.l D1,D2
	bpl.s y_clipped
	move.l D2,D1	            // clipped Y
y_clipped:
	move.l _v_bas_ad,A1
	move.w D1,D2             // clipped Y
	mulu V_CEL_HT(A0),D2
	mulu V_LIN_WR(A0),D2     // offset to row Y	
	add.l D2,A1
	move.w D0,D2             // clipped X
	cmp.l #0x01000000,A1
	bcc.s graphic_card_x_offset
	tst.b use_videl
	bne.s videl_x_offset     // Videl driver
graphic_card_x_offset:
	move.l V_OFF_AD(A0),A2   // offset table
	mulu 2(A2),D2            // # of pixels into line
	mulu BYT_PER_PIX(A0),D2  // # of bytes into line
	bra.s end_cell_addr	
videl_x_offset:
	bclr #0,D2               // even(X)
	mulu V_PLANES(A0),D2     // planes * even(X)
	btst #0,D0               // calculate Xmod2
	beq.s end_cell_addr      // Xmod2 = 0 ?
	addq.l #1,D2             // Xmod2 = 1
end_cell_addr:
	add.l D2,A1
	moveq #0,D2
	move.w V_CUR_OFF(A0),D2  // another silly offset
	add.l D2,A1              // cell (X,Y)
	move.w D0,V_CUR_X(A0)    // save new cursor X
	move.w D1,V_CUR_Y(A0)    // save new cursor Y
	move.l A1,V_CUR_AD(A0)   // save new cursor address
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
/*
 * ascii_out
 *	this routine interfaces with the BIOS.	                     
 *		it prints an ascii character on the screen as if
 *		there was a dumb terminal in here
 *
 * 	D1.L	ascii code for character
 */
ascii_out:	

	move.l D1,A2             // save character
	move.l adr_var_vdi,A0
	moveq #0,D0
	move.w V_FNT_ND(A0),D0
	cmp.l D0,D1              // test against maximum
	bhi esc_end
	move.w V_FNT_ST(A0),D0
	cmp.l D0,D1              // test against minimum
	bcs esc_end
	sub.l D0,D1              // relative character value
	move.l V_OFF_AD(A0),A1   // offset table
	add.l D1,D1              // word offset into table
	move.w (A1,D1.l),D1      // pixel offset into font data
	lsr.l #3,D1              // byte offset into font data
	move.l V_FNT_AD(A0),A1
	add.l D1,A1              // alpha source
	move.l VL_COL_FG(A0),D1  // foreground color
	move.l VL_COL_BG(A0),D2  // background color
	btst #F_REVID,V_STAT_0(A0) // test reverse video flag in v_stat_0
	beq.s put_char
	move.l D1,D0
	move.l D2,D1
	move.l D0,D2             // reverse fore and background colours     
put_char:
	move.w V_HID_CNT(A0),D0
	addq.l #1,D0
	move.w D0,V_HID_CNT(A0)  // begin critical section
 	bclr #F_CSTATE,V_STAT_0(A0) // mark cursor invisible in v_stat_0
	tst.b use_videl
	bne.s videl_char         // Videl driver
	move.l A2,-(SP)          // character
	move.l A0,-(SP)
	move.l D2,-(SP)          // bg
	move.l D1,-(SP)          // fg
	moveq #0,D0
	move.w V_FNT_WD(A0),D0   // font cell wrap
	move.l D0,-(SP)
	move.w V_CEL_HT(A0),D0
	move.l D0,-(SP)          // h
	move.l V_OFF_AD(A0),A2   // offset table
	move.w 2(A2),D0
	move.l D0,-(SP)          // w
	move.w V_CUR_Y(A0),D0    
	move.l D0,-(SP)          // y
	move.w V_CUR_X(A0),D0
	move.l D0,-(SP)          // x  
	move.l A1,-(SP)          // character source
	jsr _print_screen
	lea 32(SP),SP
	move.l (SP)+,A0
	move.l (SP)+,D1          // saved character
	tst.b flush_bconout      // from bconin2
	bne.s flush_line
	cmp.l #0x20,D1           // space
	bhi.s update_cursor
flush_line:
	move.l A0,-(SP)
	clr.l -(SP)              // => flush
	jsr _print_screen
	addq.l #4,SP
	move.l (SP)+,A0
	clr.b flush_bconout
	bra.s update_cursor
videl_char:                           // alpha source (A1)
	move.l V_CUR_AD(A0),A2   // destination
	bsr cell_xfer

update_cursor:
//  update cursor position to next cell position
//  perform carriage return and line feed if necessary
	moveq #0,D0
	moveq #0,D1
	moveq #0,D2
	move.l V_CUR_AD(A0),A1   // current cursor position
	move.w V_CUR_X(A0),D0
	move.w V_CUR_Y(A0),D1
	move.w V_CEL_MX(A0),D2
	cmp.l D2,D0              // are we at right edge ?
	blt.s next_cell          // no => increment cell ptr
	btst.b #F_CEOL,V_STAT_0(A0) // wrap or overwrite ?
	beq.s flush_alpha        // overwrite: stay put
	moveq #0,D0              // X of first cell in line
	move.l _v_bas_ad,A1      // base of screen
	move.w V_CEL_MY(A0),D2 
	cmp.l D2,D1              // is it time to scroll ? 
	blt.s no_scroll
	move.w D1,V_CUR_Y(A0)    // save the cursor Y coordinate
	mulu V_CEL_HT(A0),D1     // (cell height) * (cursor Y pos)
	mulu V_LIN_WR(A0),D1     // offset to start of last line
	add.l D1,A1              // beginning of last line
	moveq #0,D1              // scroll from top of screen.
	move.l A1,-(SP)
	bsr p_sc_up
	move.l (SP)+,A1
	bra.s save_it
flush_alpha:
	tst.b use_videl
	bne.s show_alpha         // Videl driver
	move.l A0,-(SP)
	move.l A1,-(SP)
	move.l D0,-(SP)
	move.l D1,-(SP)
	clr.l -(SP)              // no character source => flush
	jsr _print_screen
	addq.l #4,SP
	move.l (SP)+,D1
	move.l (SP)+,D0
	move.l (SP)+,A1
	move.l (SP)+,A0
	bra.s show_alpha
no_scroll:
	addq.l #1,D1             // Y of next line
	move.w D1,D2
	mulu V_CEL_HT(A0),D2     // (cell height) * (cursor Y pos)
	mulu V_LIN_WR(A0),D2     // offset to start of last line
	add.l D2,A1              // next line
	bra.s disp_cur
next_cell:                            // increment cell ptr
	addq.l #1,D0             // X cell of next cell to right
	cmp.l #0x01000000,A1
	bcc.s graphic_card_next_cell
	tst.b use_videl
	bne.s videl_next_cell    // Videl driver
graphic_card_next_cell:
	move.l V_OFF_AD(A0),A2   // offset table
	move.w BYT_PER_PIX(A0),D2	// # of bytes per pix
	mulu 2(A2),D2            // offset to next cell
	add.l D2,A1              // first cell of next word
	bra.s disp_cur
videl_next_cell:
	btst #0,D0               // if X is even, move to next
	beq.s next_word          // word in the plane
	addq.l #1,A1             // new cell
	bra.s disp_cur
next_word:
	moveq #0,D2
	move.w V_PLANES(A0),D2
	asl.l #1,D2
	subq.l #1,D2             // offset to next word in plane
	add.l D2,A1              // new cell (1st plane)

disp_cur:	// display cursor

	move.w D1,V_CUR_Y(A0)    // update the cursor Y coordinate
save_it:
	move.w D0,V_CUR_X(A0)    // update the cursor X coordinate
	move.l A1,V_CUR_AD(A0)   // update cursor address

show_alpha:

	move.b V_DELAY(A0),D2    // if v_delay=0 and v_hid_ct=1
	bne set_delay            // redisplay cursor right now!
	moveq #0,D2
	move.w V_HID_CNT(A0),D2  // old hide count
	subq.l #1,D2             // new hide count
	bne set_hide             // quit if cursor remains invisible
	bsr neg_cell             // immediately redisplay cursor
	bset.b #F_CSTATE,V_STAT_0(A0) // indicate cursor is now visible
	move.b V_PERIOD(A0),D2   // new flash cycle
set_delay:
	move.b D2,V_CUR_CT(A0)   // toggle after a period of mourning
set_hide:
	move.w V_HID_CNT(A0),D0
	subq.l #1,D0
	move.w D0,V_HID_CNT(A0)  // end critical section
	move.l A0,-(SP)
	jsr _update_mono
	move.l (SP)+,A0
	rts
/*
 * cell_xfer - Performs a byte aligned block transfer for the Videl.
 *
 * This routine performs a byte aligned block transfer for the purpose of
 * manipulating monospaced byte-wide text. the routine maps an single
 * plane arbitrarilly long byte-wide image to a multi-plane bit map.
 * all transfers are byte aligned.
 *
 * in:   D1.L    foreground color
 *       D2.L    background color
 *       A0      points to VDI variables
 *       A1      points to contiguous source block (1 byte wide)
 *       A2      points to destination (1st plane, top of block)
 */
cell_xfer:

#ifdef COLDFIRE
	lea -52(SP),SP
	movem.l D0-D6/A0-A5,(SP)
#else
	movem.l D0-D6/A0-A5,-(SP)
#endif
	moveq #0,D0
	moveq #0,D4
	moveq #0,D6
	move.w V_FNT_WD(A0),D0   // font cell wrap
	move.w V_CEL_HT(A0),D4   // cell height
	move.w V_PLANES(A0),D6
	move.w V_LIN_WR(A0),A3   // number of bytes/video line
	move.l _v_bas_ad,D5
	cmp.l #0x01000000,D5
	bcc cell_xfer_no_planes
	cmp.l #8,D6              // # of planes  
	bhi p_lp0_ntc            // 65K colors
p_lp0:
		move.l D4,D5    // reset block length counter
		move.l A1,A4    // top of source block
		move.l A2,A5    // top of current dest plane
		lsr.l #1,D2     // current background color bit
		bcc.s back_0
		lsr.l #1,D1     // current foreground color bit
		bcc.s blk_invrt // back:1  fore:0  =>  invert block
		moveq.l #-1,D3  // all ones.
		bra.s blk_reg   // back:1  fore:1  =>  all ones
back_0:
		lsr.l #1,D1     // current foreground color bit
		bcs.s blk_xfer  // back:0  fore:1  =>  direct substitution
		moveq #0,D3     // all zeroes.
                          // back:0  fore:0  =>  all zeros
blk_reg:
			move.b  D3,(A5)
			add.l A3,A5
		subq.l #1,D5
		bgt.s blk_reg
		addq.l #2,A2    // top of block in next plane
	subq.l #1,D6
	bgt.s p_lp0
	bra end_xfer
blk_xfer:                                 // inject the source block
			move.b (A4),(A5)
			add.l A3,A5
			add.l D0,A4
		subq.l #1,D5
		bgt.s blk_xfer
		addq.l #2,A2    // top of block in next plane
 	subq.l #1,D6
	bgt.s p_lp0
	bra end_xfer
blk_invrt:                                // inject the inverted source block
			move.b (A4),D3
			not.l D3
			move.b D3,(A5)
			add.l A3,A5
			add.l D0,A4
		subq.l #1,D5
		bgt.s blk_invrt
		addq.l #2,A2    // top of block in next plane
	subq.l #1,D6
	bgt.s p_lp0
	bra end_xfer
cell_xfer_no_planes:                      // no planes
	cmp.l #8,D6                  // 256 colors
	bne.s p_lp0_ntc
blk_xfer_256:                             // inject the source block
		move.b (A1),D6
		swap D6
		asl.l #8,D6
		move.l A2,A5
		moveq #7,D5
blk_xfer_byte_256:
			add.l D6,D6
			bcc.s blk_xfer_bgc_256
			move.b D1,(A5)+ // fg color
		subq.l #1,D5
		bpl.s blk_xfer_byte_256
		add.l A3,A2
		add.l D0,A1
	subq.l #1,D4
	bgt.s blk_xfer_256
	bra end_xfer
blk_xfer_bgc_256:
			move.b D2,(A5)+ // bg color
		subq.l #1,D5
		bpl.s blk_xfer_byte_256
		add.l A3,A2
		add.l D0,A1
	subq.l #1,D4
	bgt.s blk_xfer_256
	bra end_xfer
p_lp0_ntc:
	cmp.l #16,D6                 // 65K colors
	bne.s blk_xfer_tc
blk_xfer_ntc:                             // inject the source block
		move.b (A1),D6
		swap D6
		asl.l #8,D6
		move.l A2,A5
		moveq #7,D5
blk_xfer_byte_ntc:
			add.l D6,D6
			bcc.s blk_xfer_bgc_ntc
			move.w D1,(A5)+ // fg color
		subq.l #1,D5
		bpl.s blk_xfer_byte_ntc
		add.l A3,A2
		add.l D0,A1
	subq.l #1,D4
	bgt.s blk_xfer_ntc
	bra.s end_xfer
blk_xfer_bgc_ntc:
			move.w D2,(A5)+ // bg color
		subq.l #1,D5
		bpl.s blk_xfer_byte_ntc
		add.l A3,A2
		add.l D0,A1
	subq.l #1,D4
	bgt.s blk_xfer_ntc
	bra.s end_xfer
blk_xfer_tc:                            // inject the source block
		move.b (A1),D6
		swap D6
		asl.l #8,D6
		move.l A2,A5
		moveq #7,D5
blk_xfer_byte_tc:
			add.l D6,D6
			bcc.s blk_xfer_bgc_tc
			move.l D1,(A5)+ // fg color
		subq.l #1,D5
		bpl.s blk_xfer_byte_tc
		add.l A3,A2
		add.l D0,A1  
	subq.l #1,D4
	bgt.s blk_xfer_tc
	bra.s end_xfer
blk_xfer_bgc_tc:
			move.l D2,(A5)+ // bg color
		subq.l  #1,D5
		bpl.s blk_xfer_byte_tc
		add.l A3,A2
		add.l D0,A1
	subq.l #1,D4
	bgt.s blk_xfer_tc
end_xfer:
#ifdef COLDFIRE
	movem.l (SP),D0-D6/A0-A5
	lea 52(SP),SP
#else
	movem.l (SP)+,D0-D6/A0-A5
#endif
	rts

/*
 * blnk_blt - Fills region with the background color.
 *
 * This routine fills a cell-word aligned region with the background
 * color.  The rectangular region is specified by a top/left cell x,y
 * and a bottom/right cell x,y, inclusive.  Routine assumes top/left x is even
 * and bottom/right x is odd for cell-word alignment.
 *
 *       D1(31:16)       top/left cell y position
 *       D1(15:00)       top/left cell x position
 *       D2(31:16)       bottom/right cell y position
 *       D2(15:00)       bottom/right cell x position 
 */
blnk_blt:

#ifdef COLDFIRE
	lea -36(SP),SP
	movem.l D0-D5/A0-A2,(SP)
#else
	movem.l D0-D5/A0-A2,-(SP)
#endif	
	bsr hide_cursor
	sub.l D1,D2              // form cell delta x, delta y in d2
	move.w D1,D0             // cell x 
	swap D1                  // cell y
	tst.b use_videl
	bne.s videl_blnk_blt     // Videl driver
	move.l A0,-(SP)
	ext.l D0
	move.l D0,-(SP)          // cell x
	move.l D2,D0
	swap D0                  // delta y
	addq.l #1,D0
	mulu V_CEL_HT(A0),D0
	move.l D0,-(SP)          // h
	moveq #0,D0
	move.w D2,D0             // delta x
	addq.l #1,D0
	asl.l #3,D0              // * 8
	move.l D0,-(SP)          // w
	move.w D1,D0             // cell y
	mulu V_CEL_HT(A0),D0
	move.l D0,-(SP)          // y
	move.l 12(SP),D0         // cell x
	asl.l #3,D0              // * 8
	move.l D0,-(SP)          // x
        	move.l VL_COL_BG(A0),-(SP) // bg
	jsr _clear_screen
	lea 24(SP),SP
	move.l (SP)+,A0
	bra end_blnk_blt
videl_blnk_blt:
	move.l _v_bas_ad,A1
	move.w D1,D3             // cell y
	mulu V_CEL_HT(A0),D3
	mulu V_LIN_WR(A0),D3     // offset to row Y	
	add.l D3,A1
	moveq #0,D3
	move.w V_PLANES(A0),D3   // # of planes
	cmp.l #0x01000000,A1
	bcc blnk_blt_no_planes
	cmp.l #8,D3              // # of planes  
	bhi blnk_blt_no_planes   // 65K colors
	move.w D0,D3             // cell x
	bclr #0,D3               // even(X)
	mulu V_PLANES(A0),D3     // planes * even(X)
	btst #0,D0               // calculate Xmod2
	beq.s blnk_blt_cell_addr // Xmod2 = 0 ?
	addq.l #1,D3             // Xmod2 = 1
blnk_blt_cell_addr:
	add.l D3,A1
	moveq #0,D3
	move.w V_CUR_OFF(A0),D3  // another silly offset
	add.l D3,A1              // cell (X,Y) address
	moveq #0,D0
	move.w D2,D0             // delta x
	lsr.l #1,D0              // # of cell-pairs per row in region -1
	move.l D0,D1
	addq.l #1,D1             // # of cell-pairs per row in region
	moveq #0,D3
	move.w V_PLANES(A0),D3   // # of planes
	cmp.l #4,D3              // form 1,2, or 3
	bne.s not_4_planes
	subq.l #1,D3             // 4 planes -> 3 shifts
not_4_planes:
	asl.l D3,D1              // total bytes per row in region
	move.w V_LIN_WR(A0),A2   // line wrap
	sub.l D1,A2              // line stride to a2
	move.l D0,D1             // # of cell pairs per row in region -1
	clr.w D2
	swap D2                  // cell delta y in low word
	addq.l #1,D2             // # of vertical cells in region
	mulu V_CEL_HT(A0),D2     // # of lines in region
      	moveq #0,D0              // assume 0 background color
	move.l VL_COL_BG(A0),D5  // background color
	moveq #0,D3
	move.w V_PLANES(A0),D3   // # of planes
	cmp.l #1,D3              // # of planes
	beq.s mono_blnk_blt
	cmp.l #2,D3              // # of planes
	beq.s plane2_blnk_blt
	cmp.l #4,D3              // # of planes
	bne end_blnk_blt         // not supported
plane4_blnk_blt:
	lsr.l #1,D5              // shift background color plane 0
	scs.b D0
	ext.w D0
	swap D0                  // put 1st bit in high word
	lsr.l #1,D5              // shift plane 1
	scs.b D0
	ext.w D0
	moveq #0,D3              // assume all 0's for planes 2 & 3
	lsr.l #1,D5
	scs.b D3
	ext.w D3
	swap D3
	asr.l #1,D5
	scs.b D3
	ext.w D3
plane4y:
		move.l D1,D5 // reset cell -1 count
plane4x:
			move.l D0,(A1)+ // fill background to planes 0 & 1
			move.l D3,(A1)+ // fill background to planes 2 & 3
		subq.l #1,D5
		bpl.s plane4x // go for rest of row
		add.l A2,A1 // skip non-region area with stride advance
	subq.l #1,D2
	bgt.s plane4y     
	bra end_blnk_blt
plane2_blnk_blt:
	lsr.l #1,D5              // shift background color plane 0
	scs.b D0
	ext.w D0
	swap D0                  // put 1st bit in high word
	lsr.l #1,D5              // shift plane 1
	scs.b D0
	ext.w D0
plane2y:
	move.l D1,D5             // reset cell-pair -1 count
plane2x:
			move.l D0,(A1)+ // fill background to planes 0 & 1
		subq.l #1,D5
		bpl.s plane2x // go for rest of row
		add.l A2,A1 // skip non-region area with stride advance
	subq.l #1,D2
	bgt.s plane2y            // do all rows in region
	bra end_blnk_blt
mono_blnk_blt:
        	lsr.l #1,D5
	negx.l D0
plane1y:
		move.l D1,D5 // reset cell-pair -1 count
plane1x:
			move.w D0,(A1)+ // fill background to plane
		subq.l #1,D5
		bpl.s plane1x // go for rest of row
		add.l A2,A1 // skip non-region area with stride advance
	subq.l #1,D2
	bgt.s plane1y            // do all rows in region
	bra end_blnk_blt
blnk_blt_no_planes:
             move.w D0,D1             // cell x
	move.l V_OFF_AD(A0),A2   // offset table
	mulu 2(A2),D1            // # of pixels into line
	mulu BYT_PER_PIX(A0),D1  // # of bytes into line
	add.l D1,A1
	moveq #0,D1
	move.w V_CUR_OFF(A0),D1  // another silly offset
	add.l D1,A1              // cell (X,Y) address
	moveq #0,D1
	move.w V_LIN_WR(A0),A2   // line wrap
	move.l VL_COL_BG(A0),D5  // background color
	cmp.l #8,D3              // # of planes  
	bne.s blnk_blt_ntc       // 65K colors
	moveq #0,D1
	move.w D2,D1             // # of cell per row in region -1
	swap D2                  // cell delta y in lo word
	addq.l #1,D2             // # of vertical cells in region     
	mulu V_CEL_HT(A0),D2     // # of lines in region
	asl.l #8,D5
	move.b VL_COL_BG+3(A0),D5  // background color
	move.w D5,D0
	swap D0
	move.w D5,D0
no_planesy_256:
		move.l D1,D5 // reset cell -1 count
		move.l A1,D4
no_planesx_256:
			move.l D0,(A1)+ // fill background
			move.l D0,(A1)+ 
		subq.l #1,D5
		bpl.s no_planesx_256 // go for rest of row
		move.l D4,A1
		add.l A2,A1 // skip non-region area with stride advance
	subq.l #1,D2
	bgt.s no_planesy_256     // do all rows in region        
	bra end_blnk_blt
blnk_blt_ntc:                         // 65K colors
	cmp.l #16,d3             // 16 planes
	bne blnk_blt_tc          // 16M colors
	moveq #0,D1
	move.w D2,D1             // # of cell per row in region -1
	swap D2                  // cell delta y in lo word
	addq.l #1,D2             // # of vertical cells in region
	mulu V_CEL_HT(A0),D2     // # of lines in region
	move.w D5,D0
	swap D0
	move.l D5,D0
no_planesy_ntc:
		move.l D1,D5 // reset cell -1 count
		move.l A1,D4
no_planesx_ntc:
			move.l D0,(A1)+ // fill background
			move.l D0,(A1)+ 
			move.l D0,(A1)+
			move.l D0,(A1)+ 
		subq.l #1,D5
		bpl.s no_planesx_ntc // go for rest of row
		move.l D4,A1
		add.l A2,A1 // skip non-region area with stride advance
	subq.l #1,D2
	bgt.s no_planesy_ntc     // do all rows in region        
	bra.s end_blnk_blt
blnk_blt_tc:                          // 16M colors
	moveq #0,D1
	move.w D2,D1             // # of cell per row in region -1
	swap D2                  // cell delta y in lo word
	addq.l #1,D2             // # of vertical cells in region
	mulu V_CEL_HT(A0),D2     // # of lines in region
	move.l D5,D0
no_planesy_tc:
		move.l D1,D5 // reset cell -1 count
		move.l A1,D4
no_planesx_tc:
			move.l D0,(A1)+ // fill background
			move.l D0,(A1)+ 
			move.l D0,(A1)+
			move.l D0,(A1)+ 
			move.l D0,(A1)+
			move.l D0,(A1)+
			move.l D0,(A1)+
			move.l D0,(A1)+  
		subq.l #1,D5
		bpl.s no_planesx_tc // go for rest of row
		move.l D4,A1
		add.l A2,A1 // skip non-region area with stride advance
	subq.l #1,D2
	bgt.s no_planesy_tc      // do all rows in region    
end_blnk_blt:
	bsr show_cursor

#ifdef COLDFIRE
	movem.l (SP),D0-D5/A0-A2
	lea 36(SP),SP
#else
	movem.l (SP)+,D0-D5/A0-A2
#endif
	rts

neg_cell:

	tst.b use_videl
	bne.s int_neg_cell       // Videl driver
#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
#else
	movem.l D0-D2/A0-A2,-(SP)
#endif
	moveq #0,D0
	move.w V_CEL_HT(A0),D0
	move.l D0,-(SP)          // h
	moveq #8,D0
	move.l D0,-(SP)          // w
	move.w V_CUR_Y(A0),D0    // cell y
	mulu V_CEL_HT(A0),D0
	move.l D0,-(SP)          // y
	moveq #0,D0
	move.w V_CUR_X(A0),D0    // cell x	
	move.l V_OFF_AD(A0),A1   // offset table
	mulu 2(A1),D0
	move.l D0,-(SP)          // x
        	moveq #-2,D0
        	move.l D0,-(SP)          // xor
	jsr _clear_screen
	lea 20(SP),SP
#ifdef COLDFIRE
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else
	movem.l (SP)+,D0-D2/A0-A2
#endif
	rts

int_neg_cell:
	// accelerated routine not used for interrupts => no semaphores
#ifdef COLDFIRE
	lea -32(SP),SP
	movem.l D0-D4/A0-A2,(SP)
#else
	movem.l D0-D3/A0-A2,-(SP)
#endif
	move.l V_CUR_AD(A0),A2   // cursor address
	moveq #0,D0
	moveq #0,D1
	moveq #0,D2
	moveq #-1,D3
	move.l V_OFF_AD(A0),A1   // offset table
	move.w 2(A1),D2
	lsr.l #3,D2
	move.w V_CEL_HT(A0),D1
	move.w V_PLANES(A0),D0
	cmp.l #16,D0
	bhi.s loop_line_32
	beq.s loop_line_16
	cmp.l #0x01000000,A2
	bcs.s videl_neg_cell     // planes	
	cmp.l #8,D0
	beq.s loop_line_8
videl_neg_cell:
	moveq #0,D2
	move.w V_LIN_WR(A0),D2
plane_loop:
	        move.l A2,A1
	        move.l D1,D3
neg_loop:
#ifdef COLDFIRE
			move.b (A1),D4
			not.l D4
			move.b D4,(A1)
#else
			not.b (A1)
#endif
			add.l D2,A1
	        subq.l #1,D3
	        bgt.s neg_loop
	        addq.l #2,A2
	subq.l #1,D0
	bgt.s plane_loop
	bra.s end_neg_cell
loop_line_8:
		move.l A2,A1
		move.l D2,D0
loop_pixel_8:
			eor.l D3,(A1)+	
			eor.l D3,(A1)+
		subq.l #1,D0			
		bgt.s loop_pixel_8
		move.w V_LIN_WR(A0),D0
		add.l D0,A2
	subq.l #1,D1
	bgt.s loop_line_8
	bra.s end_neg_cell
loop_line_16:
		move.l A2,A1
		move.l D2,D0
loop_pixel_16:
			eor.l D3,(A1)+
			eor.l D3,(A1)+
			eor.l D3,(A1)+	
			eor.l D3,(A1)+
		subq.l #1,D0			
		bgt.s loop_pixel_16
		move.w V_LIN_WR(A0),D0
		add.l D0,A2
	subq.l #1,D1
	bgt.s loop_line_16
	bra.s end_neg_cell
loop_line_32:
		move.l A2,A1
		move.l D2,D0
loop_pixel_32:
			eor.l D3,(A1)+
			eor.l D3,(A1)+
			eor.l D3,(A1)+	
			eor.l D3,(A1)+	
			eor.l D3,(A1)+
			eor.l D3,(A1)+
			eor.l D3,(A1)+	
			eor.l D3,(A1)+
		subq.l #1,D0			
		bgt.s loop_pixel_32
		move.w V_LIN_WR(A0),D0
		add.l D0,A2
	subq.l #1,D1
	bgt.s loop_line_32
end_neg_cell:
#ifdef COLDFIRE
	movem.l (SP),D0-D4/A0-A2
	lea 32(SP),SP
#else
	movem.l (SP)+,D0-D3/A0-A2
#endif
	rts
	
/*
 * cursor blink interrupt routine
 */
blink:

	move.l adr_var_vdi,A0
	tst.w V_HID_CNT(A0)
	bne.s bl_exit            // if cursor is hidden, exit
	moveq #0,D0
	move.b V_CUR_CT(A0),D0
	subq.l #1,D0
	move.b D0,V_CUR_CT(A0)   // decrement cursor activity timer
	bne.s bl_exit            // if <> 0, do not process
	move.b V_PERIOD(A0),V_CUR_CT(A0) // reset timer with flash count
	btst #F_CFLASH,V_STAT_0(A0) // test flash bit in v_stat_0
	beq.s bl_static          // route to static or flashing cases
	bchg #F_CSTATE,V_STAT_0(A0) // toggle cursor state in v_stat_0
bl_neg:
	bsr int_neg_cell         // XOR cursor
	bra.s bl_exit
bl_static:
	bset #F_CSTATE,V_STAT_0(A0)
	bne.s bl_exit
	bsr int_neg_cell         // if cursor was off, turn it on
bl_exit:
	rts
	
_bconout5:

	moveq #0,D1
	move.b 7(SP),D1
	move.l SP,save_stack4
	lea conout_stack,SP
#ifdef COLDFIRE
	lea -44(SP),SP
	movem.l D2-D7/A2-A6,(SP)
#else
	movem.l D2-D7/A2-A6,-(SP)
#endif
	bsr ascii_out
#ifdef COLDFIRE
	movem.l (SP),D2-D7/A2-A6
	lea 44(SP),SP
#else
	movem.l (SP)+,D2-D7/A2-A6
#endif
	move.l save_stack4,SP
	rts

_cursconf:                            // from XBIOS handler

	move.l adr_var_vdi,D0
	beq.s bl_exit
	move.l D0,A0
	moveq #0,D0
	move.w 4(SP),D0          // fetch function number
	cmp.l #7,D0
	bhi.s bl_exit
	add.l D0,D0
	move.w conf_tbl(PC,D0.l),D0
	jmp conf_tbl(PC,D0.l)

conf_tbl:
	dc.w escf-conf_tbl       // hide
	dc.w esce-conf_tbl       // forced show
	dc.w onblink-conf_tbl    // turn on blinking
	dc.w offblink-conf_tbl   // turn off blinking
	dc.w setrate-conf_tbl    // set blink rate
	dc.w getrate-conf_tbl    // get blink rate
	dc.w setdelay-conf_tbl   // set delay value
	dc.w getdelay-conf_tbl   // get delay value

onblink:

	bset #F_CFLASH,V_STAT_0(A0) // enable blinking
	rts

offblink:

	bclr #F_CFLASH,V_STAT_0(A0) // disable blinking
	rts

setrate:

	move.b 7(SP),V_PERIOD(A0) // set the blink rate.
	rts

getrate:

	moveq #0,D0
	move.b V_PERIOD(A0),D0   // get the blink rate.
	rts

setdelay:

	move.b 7(SP),D0
	move.b D0,V_DELAY(A0)    // set the delay period
	rts

getdelay:

	moveq #0,D0
	move.b V_DELAY(A0),D0    // get the delay period
	rts

_bconout2:

	move.w 6(SP),D1
	move.l SP,save_stack4
	lea conout_stack,SP
	move.w D1,-(SP)
	bsr _cputc
	addq.l #2,SP
	jsr _update_mono
	move.l save_stack4,SP
	rts

_bconstat2:

	tst.b use_videl
	bne.s .old_bconstat2     // Videl driver
	move.l SP,save_stack4
	lea conout_stack,SP
	clr.l -(SP)              // flush characters
	jsr _print_screen
	addq.l #4,SP
	move.l save_stack4,SP
#ifdef COLDFIRE
	moveq #-1,D0
	move.b D0,flush_bconout
#else
	st.b flush_bconout       // flush again after next character
#endif
.old_bconstat2:
	move.l save_bconstat2,-(SP)
	rts

_bconin2:

	tst.b use_videl
	bne.s .old_bconin2       // Videl driver
	move.l SP,save_stack4
	lea conout_stack,SP
	clr.l -(SP)              // flush characters
	jsr _print_screen
	addq.l #4,SP
	move.l save_stack4,SP
#ifdef COLDFIRE
	moveq #-1,D0
	move.b D0,flush_bconout
#else
	st.b flush_bconout       // flush again output after next character
#endif
.old_bconin2:
	move.l save_bconin2,-(SP)
	rts
        
_cputc:          

	moveq #0,D1
	move.b 5(SP),D1
	move.l con_state,A0
	jmp (A0)

normal_ascii:

#if 0 // #ifdef DEBUG
	move.l D0,-(SP)
	lea debug3(PC),A0
	bsr display_string
	move.w D1,D0
	bsr hex_byte
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	move.l (SP)+,D0
#endif
	and.l #0xff,D1
	cmp.l #0x20,D1           // If the character is printable ascii
	bge ascii_out            // go print it
	move.l adr_var_vdi,A0
	move.w V_HID_CNT(A0),D0
	addq.l #1,D0
	move.w D0,V_HID_CNT(A0)  // begin critical section
	tst.b use_videl
	bne.s no_flush_videl     // Videl driver
	move.l A0,-(SP)
	move.l D1,-(SP)
	clr.l -(SP)              // no character source => flush
	jsr _print_screen
	addq.l #4,SP
	move.l (SP)+,D1
	move.l (SP)+,A0
no_flush_videl:
	move.w V_HID_CNT(A0),D0
	subq.l #1,D0
	move.w D0,V_HID_CNT(A0)  // end critical section
/*  We handle the following control characters as special
*   All others are thrown away.
*	 7 = bell
*	 8 = backspace
*	 9 = Horizontal tab
*	10 = Line feed
*	11 = Vertical tab        (Treated as line feed)
*	12 = Form Feed           (Treated as line feed)
*	13 = Carriage Return
*	27 = Escape              (Begin command sequence)
*/
	cmp.l #27,D1	            // control characters are handled
	bne.s handle_control     // immediately
	lea esc_ch1(PC),A1       // wait for the next character
	bra load_state           // in the escape sequence.
handle_control:
	subq.l #7,D1             // Range check the character against
	bmi.s exit_conout        // the ones we handle, and exit if out
	cmp.l #6,D1              // of range.
	bgt.s exit_conout
	add.l D1,D1
	move.w ctrl_tbl(PC,D1.l),D1 // offset to the control routine
	ext.l D1
	jmp ctrl_tbl(PC,D1.l)

ctrl_tbl:
	dc.w do_bell-ctrl_tbl    // ^G  Bell
	dc.w escD-ctrl_tbl       // ^H  Backspace
	dc.w do_tab-ctrl_tbl     // ^I  Horizontal Tab
	dc.w ascii_lf-ctrl_tbl   // ^J  Line Feed
	dc.w ascii_lf-ctrl_tbl   // ^K  Vertical Tab
	dc.w ascii_lf-ctrl_tbl   // ^L  Form Feed
	dc.w ascii_cr-ctrl_tbl   // ^M  Carriage Return

do_bell:

	lea conterm,A0
	btst #2,(A0)             // see if bell is disabled
	beq.s exit_conout
	pea bellsnd(PC)
#if 1
	jsr 0xE03C00             // Dosound
	addq.l #4,SP
#else
	move.w #0x20,-(sp)       // Dosound
	trap #14                 // XBIOS
	addq.l #6,SP
#endif
exit_conout:
	rts

do_tab:
	move.w V_CUR_X(A0),D0    // cursor cell X
	and.l #0xFFF8,D0         // previous 8 cell boundry
	addq.l #8,D0             // next 8 cell boundry
	move.w V_CUR_Y(A0),D1    // cursor cell Y
	bra move_cursor

esc_ch1:	// Handle the first character of an escape sequence

#if 0 // #ifdef DEBUG
	move.l D0,-(SP)
	lea debug4(PC),A0
	bsr display_string
	move.w D1,D0
	bsr hex_byte
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	move.l (SP)+,D0
#endif
	move.l adr_var_vdi,A0
	lea normal_ascii(PC),A1  // Most functions only use 1 additional
	bsr load_state           // character so default to normal ascii
	and.l #0xff,D1
	sub.l #0x41,D1           // state.  Bias by lowest character
	bmi exit_conout          // value. Exit if invalid.
	cmp.l #12,D1             // if in the range A-M go handle
	ble range_A2M
	cmp.l #24,D1             // <esc> Y is direct cursor addressing
	bne check_low_case       // and takes 2 additional characters
	lea get_row(PC),A1       // 1st, fetch the cell Y
load_state:
	move.l A1,con_state
	rts
get_row:
	move.l adr_var_vdi,A0
	and.l #0xff,D1
	sub.l #0x20,D1
	moveq #0,D0
	move.w V_CEL_MY(A0),D0   // remove space bias
	cmp.l D0,D1              // maximum row number
	bls.s row_ok
	move.w V_CEL_MY(A0),D1   // clamp it to the maximum
row_ok:
	move.w D1,save_row       // and save until command complete
	lea get_column(PC),A1    // now, fetch the cell X
	bra load_state
get_column:
	move.l adr_var_vdi,A0
	and.l #0xff,D1
	sub.l #0x20,D1           // remove space bias
	moveq #0,D0
	move.w V_CEL_MX(A0),D0
	cmp.l D0,D1              // maximum column number
	bls.s col_ok           
	move.w V_CEL_MX(A0),D1   // clamp to maximum column
col_ok:
	move.w D1,D0             // cell X
	move.w save_row,D1       // cell Y
	bsr move_cursor          // move cursor
	lea normal_ascii(PC),A1  // we have what we need
	bra load_state           // return to normal ascii

/*
 * escape b - Set Foreground Color
 */
get_fg_col:

	lea set_fg_col(PC),A1
	bra load_state           // Next char is the FG color
set_fg_col:
	move.l adr_var_vdi,A0
	lea PAL_MAP(A0),A1       // virtual palette
	tst.w _os_magic
	beq.s set_fg_col_tos
	move.l A1,-(SP)
	move.l _sysbase,A1
	move.l 0x18(A1),D0       // date
	move.l (SP)+,A1
	swap D0
	cmp.l #0x20010000,D0     // MagiC 6.20
	bcs.s set_fg_col_tos
	lea var_vdi,A1
	lea PAL_MAP(A1),A1       // virtual palette
set_fg_col_tos:	
	and.l #0xff,D1
	sub.l #0x30,D1           // mask out unneeded bits
	asl.l #2,D1
	move.l (A1,D1.l),D1
	moveq #0,D0
	move.w V_PLANES(A0),D0
	cmp.l #16,D0
	bhi.s set_fg_col_tc
	move.w D1,V_COL_FG(A0)
set_fg_col_tc:
	move.l D1,VL_COL_FG(A0)  // set the foreground color
	lea normal_ascii(PC),A1
	bra load_state

/*
 * escape c - Set Background Color
 */
get_bg_col:

	lea set_bg_col(PC),A1    // Next char is the BG color
	bra load_state
set_bg_col:
	move.l adr_var_vdi,A0
	lea PAL_MAP(A0),A1       // virtual palette
	tst.w _os_magic
	beq.s set_bg_col_tos
	move.l A1,-(SP)
	move.l _sysbase,A1
	move.l 0x18(A1),D0       // date
	move.l (SP)+,A1
	swap D0
	cmp.l #0x20010000,D0     // MagiC 6.20
	bcs.s set_bg_col_tos
	lea var_vdi,A1
	lea PAL_MAP(A1),A1       // virtual palette
set_bg_col_tos:
	and.l #0xff,D1
	sub.l #0x30,D1           // mask out unneeded bits
	asl.l #2,D1
	move.l (A1,D1.l),D1
	moveq #0,D0
	move.w V_PLANES(A0),D0
	cmp.l #16,D0
	bhi.s set_bg_col_tc
	move.w D1,V_COL_BG(A0)
set_bg_col_tc:
	move.l D1,VL_COL_BG(A0)  // set the background color
	lea normal_ascii(PC),A1
	bra load_state
check_low_case:
	sub.l #0x21,D1           // see if b to w range
	bmi load_state
	cmp.l #21,D1
	ble.s range_b2w
	rts
range_A2M:
	add.l D1,D1
	move.w A2M_tbl(PC,D1.l),D1
	ext.l D1
	jmp A2M_tbl(PC,D1.l)
range_b2w:
	add.l D1,D1
	move.w b2w_tbl(PC,D1.l),D1
	ext.l D1
	jmp b2w_tbl(PC,D1.l)

A2M_tbl:
	dc.w escA-A2M_tbl        // <Esc> A  Cursor Up
	dc.w escB-A2M_tbl        // <Esc> B  Cursor Down
	dc.w escC-A2M_tbl        // <Esc> C  Cursor Right
	dc.w escD-A2M_tbl        // <Esc> D  Cursor Left
	dc.w escE-A2M_tbl        // <Esc> E  Clear and Home
	dc.w exit_conout-A2M_tbl // <Esc> F  *** not supported
	dc.w exit_conout-A2M_tbl // <Esc> G  *** not supported
	dc.w escH-A2M_tbl        // <Esc> H  Home
	dc.w escI-A2M_tbl        // <Esc> I  Reverse Line Feed
	dc.w escJ-A2M_tbl        // <Esc> J  Erase to End of Screen
	dc.w escK-A2M_tbl        // <Esc> K  Erase to End of Line
	dc.w escL-A2M_tbl        // <Esc> L  Insert Line
	dc.w escM-A2M_tbl        // <Esc> M  Delete Line

b2w_tbl:
	dc.w get_fg_col-b2w_tbl  // <Esc> b  Set fore color (1 more char)
	dc.w get_bg_col-b2w_tbl  // <Esc> c  Set back color (1 more char)
	dc.w escd-b2w_tbl        // <Esc> d  Erase from beginning of page
	dc.w esce-b2w_tbl        // <Esc> e  Cursor On
	dc.w escf-b2w_tbl        // <Esc> f  Cursor Off
	dc.w exit_conout-b2w_tbl // <Esc> g  *** not supported
	dc.w exit_conout-b2w_tbl // <Esc> h  *** not supported
	dc.w exit_conout-b2w_tbl // <Esc> i  *** not supported
	dc.w escj-b2w_tbl        // <Esc> j  Save Cursor Position
	dc.w esck-b2w_tbl        // <Esc> h  Restore Cursor position
	dc.w escl-b2w_tbl        // <Esc> i  Erase line
	dc.w exit_conout-b2w_tbl // <Esc> m  *** not supported
	dc.w exit_conout-b2w_tbl // <Esc> n  *** not supported
	dc.w esco-b2w_tbl        // <Esc> o  Erase from Beginning of Line
	dc.w escp-b2w_tbl        // <Esc> p  Reverse Video On
	dc.w escq-b2w_tbl        // <Esc> q  Reverse Video Off
	dc.w exit_conout-b2w_tbl // <Esc> r  *** not supported
	dc.w exit_conout-b2w_tbl // <Esc> s  *** not supported
	dc.w exit_conout-b2w_tbl // <Esc> t  *** not supported
	dc.w exit_conout-b2w_tbl // <Esc> u  *** not supported
	dc.w escv-b2w_tbl        // <Esc> v  Wrap at End of Line
	dc.w escw-b2w_tbl        // <Esc> w  Overwrite at End of Line

bellsnd:
	.dc.b 0,0x34
	.dc.b 1,0
	.dc.b 2,0
	.dc.b 3,0
	.dc.b 4,0
	.dc.b 5,0
	.dc.b 6,0
	.dc.b 7,0xFE
	.dc.b 8,0x10             // enable envelope, ch a
	.dc.b 9,0
	.dc.b 10,0
	.dc.b 11,0
	.dc.b 12,0x10
	.dc.b 13,9               // envelope single attack
	.dc.b 255,0              // need local variable in ctrl_tbl

det_v_pline:

#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D1-D7,(SP)
#else	
	movem.l D1-D7,-(SP)
#endif
	move.l 8(A1),A0          // PTSIN
	moveq #0,D6
	move.w 2(A3),D6          // nb points PTSIN
	tst.w BEGIN_STYLE(A2)
	bne .pl3                 // wide line
	tst.w END_STYLE(A2)
	bne .pl3                 // wide line
#ifdef COLDFIRE
	moveq #0,D0
	move.w LINE_WIDTH(A2),D0
	cmp.l #1,D0
	bhi .pl3                 // wide line
.pl4:
	cmp.l #2,D6              // nb points PTSIN
#else
	cmp.w #1,LINE_WIDTH(A2)
	bhi .pl3                 // wide line
.pl4:
	cmp.w #2,D6              // nb points PTSIN
#endif
	blt .pl1
	moveq #0,D5
	move.w USER_DEF_LINE_STYLE_PAT(A2),D5
#ifdef COLDFIRE
	moveq #0,D0
	move.w LINE_TYPE(A2),D0
	cmp.l #6,D0
	bcc.s .pl2
	lea tab_line_type,A3
	add.l D0,D0
	move.w (A3,D0.l),D5      // pattern
#else
	move.w LINE_TYPE(A2),D0
	cmp.w #6,D0
	bcc.s .pl2
	lea tab_line_type,A3
	add.w D0,D0
	move.w (A3,D0.w),D5      // pattern
#endif
.pl2:
	move.l A0,D1             // table address
	move.w D6,D2             // table length
	swap D2
	clr.w D2                 // type - coordinate pairs
	moveq #0,D3
	moveq #0,D4
	move.l fvdi_virtual,A0
	move.l vwk_line_colour(A0),D0
	moveq #0,D6
	move.w vwk_mode(A0),D6
	tst.b direct_call
	beq.s .pl5               // slower
	addq.l #1,A0             // table operation
	move.l D1,-(SP)
	move.l A0,-(SP)
	move.l D6,-(SP)          // mode
	move.l D0,-(SP)          // colour
	move.l D5,-(SP)          // pattern 
	move.l D4,-(SP)          // y2 => 0 (moves)
	move.l D3,-(SP)          // x2 => 0 (index)
	move.l D2,-(SP)          // y1 => (table length << 16) + 0 (type)
	move.l D1,-(SP)          // x1 => table
	move.l A0,-(SP)          // vwk | 1 => table operation
	jsr _c_line_draw
	lea 32(SP),SP
	move.l (SP)+,A0
	move.l (SP)+,D1
	tst.l D0
	bne .pl1
	move.l fvdi_virtual,A1
	move.l vwk_line_colour(A1),D0
	jsr _default_line
	bra .pl1
.pl5:
/*--------
* Draw a colored line between 2 points
* c_draw_line(Virtual *vwk, long x1, long y1, long x2, long y2, long pattern, long colour, long mode)
* In:	a0	VDI struct (odd address marks table operation)
*	d0	line colour
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	mode
*--------*/
	move.l vwk_real_address(A0),A3
	addq.l #1,A0             // table operation
	move.l wk_r_line(A3),A3
	jsr (A3)                 // if no accel call default_line
	bra .pl1
.pl3:
#ifdef COLDFIRE
	lea -12(SP),SP
	movem.l A0-A2,(SP)
#else
	movem.l A0-A2,-(SP)
#endif
	clr.l -(SP)              // get a memory block of any size (hopefully large)
	jsr _allocate_block
	addq.l #4,SP
#ifdef COLDFIRE
	movem.l (SP),A0-A2
	lea 12(SP),SP
#else
	movem.l (SP)+,A0-A2
#endif
	tst.l D0
	beq .pl4                 // error
	move.l D0,-(SP)          // save for later
	move.l fvdi_virtual,A1
	moveq #0,D2
	move.w vwk_mode(A1),D2
	move.l D2,-(SP)          // mode
	move.l D0,-(SP)          // points
	move.l vwk_line_colour(A1),D0
	move.l D0,-(SP)          // color
	moveq #0,D0
	move.w D6,D0             // nb points PTSIN
	move.l D0,-(SP)          // numpts
	move.l A0,-(SP)          // pts
	move.l A1,-(SP)          // vwk
// wide_line(Virtual *vwk, short *pts, long numpts, long colour, short *points, long mode)
	jsr _wide_line
	lea 24(SP),SP
	jsr _free_block
	addq.l #4,SP
.pl1:
#ifdef COLDFIRE
	movem.l (SP),D1-D7
	lea 28(SP),SP
#else
	movem.l (SP)+,D1-D7
#endif
	rts

det_v_pmarker:

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D1-D6,(SP)	
#else
	movem.l D1-D6,-(SP)
#endif
	move.l 8(A1),A0          // PTSIN
	tst.w 2(A3)              // nb points PTSIN
	beq .pm1
#ifdef COLDFIRE
	move.w (A0),D1
	ext.l D1
	move.w 2(A0),D2          // only a single dot for now
	ext.l D2
#else
	movem.w (A0),D1-D2       // only a single dot for now
#endif
	move.l D1,D3
	move.l D2,D4
	move.l #0xffff,D5
	move.l fvdi_virtual,A0
	move.l vwk_marker_colour(A0),D0
	moveq #0,D6
	move.w vwk_mode(A0),D6
	tst.b direct_call
	beq.s .pm2               // slower
	move.l D1,-(SP)
	move.l A0,-(SP)
	move.l D6,-(SP)
	move.l D0,-(SP)
	move.l D5,-(SP)
	move.l D4,-(SP)
	move.l D3,-(SP)
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l A0,-(SP)
	jsr _c_line_draw
	lea 32(SP),SP
	move.l (SP)+,A0
	move.l (SP)+,D1
	tst.l D0
	bne.s .pm1
	move.l vwk_marker_colour(A0),D0
	jsr _default_line
	bra.s .pm1
.pm2:
/*--------
* Draw a colored line between 2 points
* c_draw_line(Virtual *vwk, long x1, long y1, long x2, long y2, long pattern, long colour, long mode)
* In:	a0	VDI struct (odd address marks table operation)
*	d0	line colour
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	mode
*--------*/
	move.l vwk_real_address(A0),A3
	move.l wk_r_line(A3),A3
	jsr (A3)
.pm1:
#ifdef COLDFIRE
	movem.l (SP),D1-D6
	lea 24(SP),SP
#else
	movem.l (SP)+,D1-D6
#endif
	rts

det_v_gtext:

	moveq #0,D0
	move.w 6(A3),D0          // length tab INTIN
	beq .vg1
	move.l 4(A1),A0          // INTIN
	
gtext:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	move.l A0,A3             // INTIN
	move.l 8(A1),A0          // PTSIN
	move.l (A0),D1           // X1,Y1 destination
	tst.w HORIZONTAL_ALIGN(A2)
	beq.s .vg2               // left justified
	move.l D1,-(SP)
	link A6,#-16
#ifdef COLDFIRE
	lea -12(SP),SP
	movem.l D0/A0-A1,(SP)
#else
	movem.l D0/A0-A1,-(SP)
#endif
	move.l A3,A0             // INTIN
	lea -16(A6),A1           // PTSOUT		
	bsr vqt_extent
	move.w -8(A6),D1         // X3
#ifdef COLDFIRE
	movem.l (SP),D0/A0-A1
	lea 12(SP),SP
	unlk A6
	ext.l D1
	moveq #0,D2
	move.w HORIZONTAL_ALIGN(A2),D2
	cmp.l #2,D2
	beq.s .vg3               // right justified
	asr.l #1,D1 
.vg3:
	neg.l D1
#else
	movem.l (SP)+,D0/A0-A1
	unlk A6
	cmp.w #2,HORIZONTAL_ALIGN(A2)
	beq.s .vg3               // right justified
	lsr.w #1,D1 
.vg3:
	neg.w D1
#endif
	swap D1
	clr.w D1
	add.l (SP)+,D1           // X1,Y1 destination
.vg2:
	move.l fvdi_virtual,A0
	move.l A3,A1             // INTIN => string
	sub.l A2,A2              // no special offset table
	tst.b direct_call
	beq.s .vg5               // slower
	move.l D1,-(SP)
	move.w D1,D2
	swap D1
	ext.l D1
	ext.l D2
	move.l A0,-(SP)
	move.l A1,-(SP)
	move.l A2,-(SP)          // offsets
	move.l D2,-(SP)          // y
	move.l D1,-(SP)          // x
	move.l D0,-(SP)          // length
	move.l D0,D2
	move.l A1,-(SP)          // text
	move.l A0,-(SP)
	jsr _c_text_area
	lea 24(SP),SP
	move.l (SP)+,A1
	move.l (SP)+,A0
             move.l (SP)+,D1
	tst.l D0
	bne.s .vg4
             move.l D2,D0
	sub.l A2,A2              // no special offset table
	jsr _default_text
	bra.s .vg4
.vg5:
/*--------
* Draw some text
* c_text_area(Virtual *vwk, short *text, long length, long dst_x, long dst_y, short *offsets)
* In:	a0	VDI struct
*	a1	string address
*	a2	offset table
*	d0	string length
*	d1	x1,y1 destination
*-------*/
	move.l vwk_real_address(A0),A3
	move.l wk_r_text(A3),A3
	jsr (A3)
.vg4:
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
.vg1:
	rts

det_v_fillarea:

	tst.w 2(A3)              // nb points PTSIN
	beq .vfa1             
#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D1-D7,(SP)
#else
	movem.l D1-D7,-(SP)
#endif
	move.l A1,-(SP)
	move.l A2,-(SP)
	move.l 8(A1),D1          // PTSIN
	moveq #0,D2
	move.w 2(A3),D2          // nb points PTSIN
	moveq #0,D3              // no index address
	moveq #0,D4              // no indices
	bsr get_pattern
	move.l A0,D5             // pattern
	moveq #0,D6
	move.w WRT_MODE(A2),D6
	addq.l #1,D6             // mode
	move.l D0,D7             // interior/style
	clr.w D0
	swap D0
	cmp.l #4,D0              // user pattern
	bne.s .vfa7
	tst.w MULTIFILL(A2)
	bne.s .vfa2              // no accel poly
.vfa7:
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A3
	move.l wk_r_fillpoly(A3),D0
	beq.s .vfa2              // no accel poly
	tst.b direct_call
	beq.s .vfa8              // slower
	move.l vwk_fill_colour(A0),D0
	tst.w vwk_fill_interior(A0)
	bne.s .vfa5
	swap D0
.vfa5:
	move.l D7,-(SP)          // interior/style
	move.l D6,-(SP)          // mode
	move.l D0,-(SP)          // colours
	move.l D5,-(SP)          // pattern address
	move.l D4,-(SP)
	move.l D3,-(SP)
	move.l D2,-(SP)          // number of points
	move.l D1,-(SP)          // points address
	move.l A0,-(SP)
	jsr _c_fill_polygon
	lea 36(SP),SP
	bra .vfa3
.vfa8:
/*--------
* Fill a multiple bitplane polygon using a monochrome pattern
* c_fill_polygon(Virtual *vwk, short points[], long n, short index[], long moves, short *pattern, long colour, long mode, long interior_style)
* In:	a0	VDI struct
*	d0	colours
*	d1	points address
*	d2	number of points
*	d3	index address
*	d4	number of indices
*	d5	pattern address
*	d6	mode
*	d7	interior/style
*-------*/
	move.l D0,A3
	move.l vwk_fill_colour(A0),D0
	tst.w vwk_fill_interior(A0)
	bne.s .vfa9
	swap D0
.vfa9:
	jsr (A3)
	bra .vfa3
.vfa2:
#ifdef COLDFIRE
	lea -20(SP),SP
	movem.l D1-D2/A0-A2,(SP)
#else
	movem.l D1-D2/A0-A2,-(SP)
#endif
	clr.l -(SP)              // get a memory block of any size (hopefully large)
	jsr _allocate_block
	addq.l #4,SP
#ifdef COLDFIRE
	movem.l (SP),D1-D2/A0-A2
	lea 20(SP),SP
#else
	movem.l (SP)+,D1-D2/A0-A2
#endif
	tst.l D0
	beq.s .vfa3              // error
	move.l D0,-(SP)          // save for later
	move.l D7,-(SP)          // interior/style
	move.l D6,-(SP)          // mode
	move.l D0,-(SP)          // points
	move.l D5,-(SP)          // pattern
	move.l vwk_fill_colour(A0),D0
	tst.w vwk_fill_interior(A0)
	bne.s .vfa4
	swap D0
.vfa4:
	move.l D0,-(SP)          // color
	move.l D2,-(SP)          // nb points PTSIN
	move.l D1,-(SP)          // pts
	move.l A0,-(SP)          // vwk
// filled_poly(Virtual *vwk, short *pts, long n, long colour, short *pattern, short *points, long mode, long interior_style)
	jsr _filled_poly
	lea 32(SP),SP
	jsr _free_block
	addq.l #4,SP
.vfa3:
	move.l (SP)+,A2
	move.l (SP)+,A1
	tst.w FILL_PER_VISIB(A2)
	beq .vfa6
#ifdef COLDFIRE
	moveq #0,D0
	move.w FILL_INT_STYLE(A2),D0
	cmp.l #1,D0              // color fill
#else
	cmp.w #1,FILL_INT_STYLE(A2)
#endif
	beq .vfa6                // nothing to do
	move.l (A1),A3           // CONTRL
	move.l 8(A1),D1          // PTSIN
	move.w 2(A3),D2          // nb points PTSIN
	swap D2
	clr.w D2                 // type - coordinate pairs
	moveq #0,D3
	moveq #0,D4
	move.l #0xffff,D5        // full pattern
	move.l fvdi_virtual,A0 
	move.l vwk_fill_colour(A0),D0
	moveq #0,D6
	move.w vwk_mode(A0),D6
	tst.b direct_call
	beq.s .vfa10             // slower
	addq.l #1,A0             // table operation
	move.l D1,-(SP)
	move.l A0,-(SP)
	move.l D6,-(SP)
	move.l D0,-(SP)
	move.l D5,-(SP)
	move.l D4,-(SP)
	move.l D3,-(SP)
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l A0,-(SP)
	jsr _c_line_draw
	lea 32(SP),SP
	move.l (SP)+,A0
	move.l (SP)+,D1
	tst.l D0
	bne.s .vfa6
	move.l fvdi_virtual,A1 
	move.l vwk_fill_colour(A1),D0
	jsr _default_line
	bra.s .vfa6
.vfa10:
/*--------
* Draw a colored line between 2 points
* c_draw_line(Virtual *vwk, long x1, long y1, long x2, long y2, long pattern, long colour, long mode)
* In:	a0	VDI struct (odd address marks table operation)
*	d0	line colour
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	mode
*--------*/
	move.l vwk_real_address(A0),A3
	addq.l #1,A0             // table operation
	move.l wk_r_line(A3),A3
	jsr (A3)
.vfa6:
#ifdef COLDFIRE
	movem.l (SP),D1-D7
	lea 28(SP),SP
#else
	movem.l (SP)+,D1-D7
#endif
.vfa1:
	rts
	
det_gdps:

#ifdef COLDFIRE
	moveq #0,D0
	move.w 10(A3),D0         // sub-function
	subq.l #1,D0
	bmi.s .gd1
	cmp.l #10,D0
	bcc.s .gd1
#ifdef DEBUG
	move.l D0,-(SP)
	move.l A0,-(SP)
	lea tab_debug_gdps_f,A0
	bsr display_tab
	moveq #0x20,D0
	bsr display_char
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	move.l (SP)+,A0
	move.l (SP)+,D0
#endif
	add.l D0,D0
	move.w tab_sub_vdi(PC,D0.l),D0
	bmi.s .gd1
	jmp tab_sub_vdi(PC,D0.l)
#else
	move.w 10(A3),D0         // sub-function
	subq.w #1,D0
	bmi.s .gd1
	cmp.w #10,D0
	bcc.s .gd1
#ifdef DEBUG
	move.l D0,-(SP)
	move.l A0,-(SP)
	lea tab_debug_gdps_f,A0
	bsr display_tab
	moveq #0x20,D0
	bsr display_char
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	move.l (SP)+,A0
	move.l (SP)+,D0
#endif
	add.w D0,D0
	move.w tab_sub_vdi(PC,D0.w),D0
	bmi.s .gd1
	jmp tab_sub_vdi(PC,D0.w)
#endif
.gd1:
	rts

tab_sub_vdi:

	dc.w det_v_bar-tab_sub_vdi       // 1
	dc.w det_v_arc-tab_sub_vdi       // 2
	dc.w det_v_pie-tab_sub_vdi       // 3
	dc.w det_v_circle-tab_sub_vdi    // 4
	dc.w det_v_ellipse-tab_sub_vdi   // 5
	dc.w det_v_ellarc-tab_sub_vdi    // 6
	dc.w det_v_ellpie-tab_sub_vdi    // 7
	dc.w det_v_rbox-tab_sub_vdi      // 8
	dc.w det_v_rfbox-tab_sub_vdi     // 9
	dc.w det_v_justified-tab_sub_vdi // 10

det_v_bar:

	move.l 8(A1),A0          // PTSIN
	tst.w FILL_INT_STYLE(A2)
	bne.s .vbar3
	tst.w FILL_PER_VISIB(A2)
	bne.s .vbar2
.vbar3:
	bsr rectangle
	tst.w FILL_PER_VISIB(A2)
	beq .vbar1
.vbar2:
#ifdef COLDFIRE
	moveq #0,D0
	move.w FILL_INT_STYLE(A2),D0
	cmp.l #1,D0              // color fill
	beq .vbar1               // nothing to do
	lea -28(SP),SP
	movem.l D1-D7,(SP)
#else
	cmp.w #1,FILL_INT_STYLE(A2)
	beq .vbar1               // nothing to do
	movem.l D1-D7,-(SP)
#endif
	link A6,#-20
	lea -20(A6),A0
	move.l 8(A1),A1          // PTSIN
	move.w (A1),D0           // X1
	move.w D0,(A0)
	move.w D0,12(A0)
	move.w D0,16(A0)
	move.w 2(A1),D0          // Y1
	move.w D0,2(A0)
	move.w D0,6(A0)
	move.w D0,18(A0)
	move.w 4(A1),D0          // X2
	move.w D0,4(A0)
	move.w D0,8(A0)
	move.w 6(A1),D0          // Y2          
	move.w D0,10(A0)
	move.w D0,14(A0)
	move.l A0,D1             // table address
	moveq #5,D2              // table length
	swap D2
	clr.w D2                 // type - coordinate pairs
	moveq #0,D3
	moveq #0,D4
	move.l #0xffff,D5        // full pattern 
	move.l fvdi_virtual,A0
	move.l vwk_fill_colour(A0),D0
	moveq #0,D6
	move.w vwk_mode(A0),D6
	tst.b direct_call
	beq.s .vbar5             // slower
	move.l vwk_real_address(A0),A3
	addq.l #1,A0             // table operation
	move.l D1,-(SP)
	move.l A0,-(SP)
	move.l D6,-(SP)
	move.l D0,-(SP)
	move.l D5,-(SP)
	move.l D4,-(SP)
	move.l D3,-(SP)
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l A0,-(SP)
	jsr _c_line_draw
	lea 32(SP),SP
	move.l (SP)+,A0
	move.l (SP)+,D1
	tst.l D0
	bne.s .vbar4
	move.l fvdi_virtual,A1 
	move.l vwk_fill_colour(A1),D0
	jsr _default_line
	bra.s .vbar4
.vbar5:
/*--------
* Draw a colored line between 2 points
* c_draw_line(Virtual *vwk, long x1, long y1, long x2, long y2, long pattern, long colour, long mode)
* In:	a0	VDI struct (odd address marks table operation)
*	d0	line colour
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	mode
*--------*/
	move.l vwk_real_address(A0),A3
	addq.l #1,A0             // table operation
	move.l wk_r_line(A3),A3
	jsr (A3)
.vbar4:
	unlk A6
#ifdef COLDFIRE
	movem.l (SP),D1-D7
	lea 28(SP),SP
#else
	movem.l (SP)+,D1-D7
#endif
.vbar1:
	rts
	
rectangle:
#ifdef COLDFIRE
	lea -48(SP),SP
	movem.l D0-D7/A0-A3,(SP)
	move.w (A0),D1           // X1
	move.w 2(A0),D2          // Y1
	move.w 4(A0),D3          // X2
	move.w 6(A0),D4          // Y2
	ext.l D1
	ext.l D2
	ext.l D3
	ext.l D4
	cmp.l D2,D4
	bge.s .rec3
	move.l D2,D0
	move.l D4,D2
	move.l D0,D4
.rec3:
	cmp.l D1,D3
	bge.s .rec2
	move.l D1,D0
	move.l D3,D1
	move.l D0,D3
#else
	movem.l D0-D7/A0-A3,-(SP)
	movem.w (A0),D1-D4       // X1, Y1, X2, Y2
	cmp.w D2,D4
	bge.s .rec3
	exg D2,D4
.rec3:
	cmp.w D1,D3
	bge.s .rec2
	exg D1,D3
#endif
.rec2:
	bsr clip_rect
	beq .rec1
	bsr get_pattern
	move.l A0,D5             // pattern
	move.l D0,D7             // interior/style
	move.l fvdi_virtual,A0
	move.l vwk_fill_colour(A0),D0
	moveq #0,D6
	move.w vwk_mode(A0),D6
	tst.w vwk_fill_interior(A0)
	bne.s .rec4
	swap D0
.rec4:
	tst.b direct_call
	beq.s .rec5              // slower
	move.l D1,-(SP)
	move.l A0,-(SP)
	move.l D7,-(SP)          // interior/style
	move.l D6,-(SP)          // mode
	move.l D0,-(SP)          // colors
	move.l D5,-(SP)          // pattern
	move.l D4,D0
	sub.l D2,D0
	addq.l #1,D0
	move.l D0,-(SP)          // H
	move.l D3,D0
	sub.l D1,D0
	addq.l #1,D0
	move.l D0,-(SP)          // W
	move.l D2,-(SP)          // Y
	move.l D1,-(SP)          // X
	move.l A0,-(SP)
	jsr _c_fill_area 
	lea 36(SP),SP
	move.l (SP)+,A0
	move.l (SP)+,D1
	tst.l D0
	bne.s .rec1
	move.l vwk_fill_colour(A0),D0
	jsr _default_fill
	bra.s .rec1
.rec5:
/*--------
* Fill a multiple bitplane area using a monochrome pattern
* c_fill_area(Virtual *vwk, long x, long y, long w, long h, short *pattern, long colour, long mode, long interior_style)
* In:	a0	VDI struct (odd address marks table operation)
*	d0	colours
*	d1	x1 destination or table address
*	d2	y1    - " -    or table length (high) and type (0 - y/x1/x2 spans)
*	d3-d4	x2,y2 destination
*	d5	pattern address
*	d6	mode
*	d7	interior/style
*-------*/
	move.l vwk_real_address(A0),A3
	move.l wk_r_fill(A3),A3
	jsr (A3)
.rec1:
#ifdef COLDFIRE
	movem.l (SP),D0-D7/A0-A3
	lea 48(SP),SP
#else
	movem.l (SP)+,D0-D7/A0-A3
#endif
	rts
	
det_v_arc:

	move.l 8(A1),A0          // PTSIN
	move.w 12(A0),4(A0)      // radius
	move.w 12(A0),6(A0)      // radius

det_v_ellarc:
       
#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0           // angles: begang
	move.w 2(A0),D1          //         endang
	ext.l D0
	ext.l D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l 8(A1),A0          // PTSIN
	move.w 4(A0),D0          // radius: x
	move.w 6(A0),D1          //         y
	ext.l D0
	ext.l D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.w (A0),D0            // center: x
	move.w 2(A0),D1           //         y
	ext.l D0
	ext.l D1
#else
	movem.l D1-D2,-(SP)
	move.l 4(A1),A0          // INTIN
	movem.w (A0),D0-D1       // angles: begang, endang
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l 8(A1),A0          // PTSIN
	movem.w 4(A0),D0-D1      // radius: x, y
	move.l D1,-(SP)
	move.l D0,-(SP)
	movem.w (A0),D0-D1       // center: x, y
#endif
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l #6,-(SP)          // ellarc
	move.l fvdi_virtual,-(SP)
	jsr _ellipsearc          // vwk, gdp, xc, yc, xrad, yrad, b_ang, e_ang
	lea 32(SP),SP
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_pie:

	move.l 8(A1),A0          // PTSIN
	move.w 12(A0),4(A0)      // radius
	move.w 12(A0),6(A0)      // radius

det_v_ellpie:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0           // angles: begang
	move.w 2(A0),D1          //         endang
	ext.l D0
	ext.l D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l 8(A1),A0          // PTSIN	
	move.w 4(A0),D0          // radius: x
	move.w 6(A0),D1          //         y
	ext.l D0
	ext.l D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.w (A0),D0           // center: x
	move.w 2(A0),D1          //         y
	ext.l D0
	ext.l D1
#else
	movem.l D1-D2,-(SP)
	move.l 4(A1),A0          // INTIN
	movem.w (A0),D0-D1       // angles: begang, endang
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l 8(A1),A0          // PTSIN	
	movem.w 4(A0),D0-D1      // radius: x, y
	move.l D1,-(SP)
	move.l D0,-(SP)
	movem.w (A0),D0-D1       // center: x, y
#endif
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l #7,-(SP)          // ellpie
	move.l fvdi_virtual,-(SP)
	jsr _ellipsearc          // vwk, gdp, xc, yc, xrad, yrad, b_ang, e_ang
	lea 32(SP),SP
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_v_circle:

	move.l 8(A1),A0          // PTSIN
	move.w 8(A0),4(A0)       // radius
	move.w 8(A0),6(A0)       // radius
	
det_v_ellipse:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
	clr.l -(SP)              // dummy angles
	clr.l -(SP)
	move.l 8(A1),A0          // PTSIN	
	move.w 4(A0),D0          // radius: x
	move.w 6(A0),D1          //         y
	ext.l D0
	ext.l D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.w (A0),D0           // center: x
	move.w 2(A0),D1          //         y
	ext.l D0
	ext.l D1
#else
	movem.l D1-D2,-(SP)
	clr.l -(SP)              // dummy angles
	clr.l -(SP)
	move.l 8(A1),A0          // PTSIN	
	movem.w 4(A0),D0-D1      // radius: x, y
	move.l D1,-(SP)
	move.l D0,-(SP)
	movem.w (A0),D0-D1       // center: x, y
#endif
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l #5,-(SP)          // ellipse
	move.l fvdi_virtual,-(SP)
	jsr _ellipsearc          // vwk, gdp, xc, yc, xrad, yrad, b_ang, e_ang
	lea 32(SP),SP
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_v_rbox:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	move.l 8(A1),-(SP)       // PTSIN, edges
	move.l #8,-(SP)          // rbox
	move.l fvdi_virtual,-(SP)
	jsr _rounded_box         // vwk, gdb_code, points
	lea 12(SP),SP
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts
	
det_v_rfbox:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	move.l 8(A1),-(SP)       // PTSIN, edges
	move.l #9,-(SP)          // rfbox
	move.l fvdi_virtual,-(SP)
	jsr _rounded_box         // vwk, gdb_code, points
	lea 12(SP),SP
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_v_justified:

	moveq #0,D0
	move.w 6(A3),D0          // length tab INTIN
	subq.l #2,D0
	ble .vj1
	move.l 4(A1),A0          // INTIN
	tst.l (A0)               // word_space, char_space
	bne.s .vj2	
	addq.l #4,A0             // => string
	bra gtext
.vj2:
#ifdef COLDFIRE
	lea -12(SP),SP
	movem.l A0-A2,(SP)
#else
	movem.l A0-A2,-(SP)
#endif
	move.l #4*1024,-(SP)
	jsr _allocate_block
	addq.l #4,SP
#ifdef COLDFIRE
	movem.l (SP),A0-A2
	lea 12(SP),SP
#else
	movem.l (SP)+,A0-A2
#endif
	tst.l D0
	beq .vj1
#ifdef COLDFIRE
	lea -36(SP),SP
	movem.l D1-D7/A4-A5,(SP)
#else
	movem.l D1-D7/A4-A5,-(SP)
#endif
	move.l D0,A5
	move.l A5,-(SP)
	moveq #0,D0
	move.w 6(A3),D0          // length tab INTIN
	subq.l #2,D0             // number of characters
	move.l D0,D7
	move.l 4(A1),A0          // INTIN
	lea 4(A0),A4             // string
	move.l ADR_FONT(A2),A3
#ifdef COLDFIRE
	moveq #0,D3
	moveq #0,D4
	move.l D7,-(SP)
	moveq #0,D6
	moveq #0,D7
#endif
	move.w FIRST_ADE(A3),D3
	move.w LAST_ADE(A3),D4
	move.l CHAR_OFF_TABLE(A3),A3
	clr.l (A5)+              // first character at 0,0
	moveq #0,D2              // width total
	moveq #0,D5              // spaces
	bra.s .vj5
.vj4:
#ifdef COLDFIRE
		moveq #0,D1
		move.w (A4)+,D1
		sub.l D3,D1 // negative numbers are higher
		cmp.l D4,D1 // than code_high
		bhi.s .vj5
		cmp.l #0x20,D1 // space
		bne.s .vj3
		addq.l #1,D5
.vj3:
		move.w 2(A3,D1.l*2),D6
		move.w (A3,D1.l*2),D7
		sub.l D7,D6
		add.l D6,D2
#else
		move.w (A4)+,D1
		sub.w D3,D1 // negative numbers are higher
		cmp.w D4,D1 // than code_high
		bhi.s .vj5
		cmp.b #0x20,D1 // space
		bne.s .vj3
		addq.w #1,D5
.vj3:
		move.w 2(A3,D1.w*2),D6
		sub.w (A3,D1.w*2),D6
		add.w D6,D2
#endif
		move.w D6,(A5)+
		clr.w (A5)+
.vj5:
#ifdef COLDFIRE
	subq.l #1,D0
	bpl.s .vj4
	move.l (SP)+,D7
	move.l 8(A1),A3          // PTSIN
	moveq #0,D6
	move.w 4(A3),D6          // x size
	sub.l D2,D6
	beq .vj6
	ext.l D6                 // amount to widen by (could be negative)
	move.l D7,D4             // number of characters
	sub.l D5,D4
	tst.w (A0)               // any word spacing?
	beq.s .vj9
	move.l D5,D4
	tst.w 2(A0)              // any character spacing?
	beq .vj9
	move.l D7,D4             // number of characters
.vj9:
	subq.l #1,D4             // number of positions to vary spacing at
	beq .vj6
	.chip 68000
	divs D4,D6
	.chip 5200
	move.l D6,D2
	swap D2
	ext.l D2
	bpl.s .vj10
	move.l D2,D0
	neg.l D0
	move.w D0,D2
.vj10:
	moveq #0,D3
	move.l (SP),A5
	clr.l (A5)+              // first character at 0,0
	move.l D7,D0             // number of characters
	subq.l #1,D0             // skip first character
	move.l D7,-(SP)
	move.w D2,D7
	ext.l D7
#else
	dbf D0,.vj4
	move.l 8(A1),A3          // PTSIN
	move.w 4(A3),D6          // x size
	sub.w D2,D6
	beq .vj6
	ext.l D6                 // amount to widen by (could be negative)
	move.w D7,D4             // number of characters
	sub.w D5,D4
	tst.w (A0)               // any word spacing?
	beq.s .vj9
	move.w D5,D4
	tst.w 2(A0)              // any character spacing?
	beq .vj9
	move.w D7,D4             // number of characters
.vj9:
	subq.w #1,D4             // number of positions to vary spacing at
	beq .vj6
	divs D4,D6
	move.l D6,D2
	swap D2
	ext.l D2
	bpl.s .vj10
	neg.w D2
.vj10:
	moveq #0,D3
	move.l (SP),A5
	clr.l (A5)+              // first character at 0,0
	move.w D7,D0             // number of characters
	subq.w #1,D0             // skip first character
#endif
	lea 4(A0),A4             // string
	addq.l #2,A4             // skip first character
	bra.s .vj12
.vj11:
		move.w (A5),D5
#ifdef COLDFIRE
		ext.l D5
		moveq #0,D1
		move.w (A4)+,D1
		cmp.l #0x20,D1 // space
		bne.s .vj13
		tst.w 2(A0)    // character spacing
		bra.s .vj14
.vj13:
		tst.w (A0)     // word spacing
.vj14:
		beq.s .vj15
		add.l D6,D5
.vj15:
		add.l D7,D3
		cmp.l D4,D3
		bcs.s .vj16
		sub.l D4,D3
		addq.l #1,D5
		tst.l D2
		bpl.s .vj16
		subq.l #2,D5
#else
		move.w (A4)+,D1
		cmp.b #0x20,D1 // space
		bne.s .vj13
		tst.w 2(A0)    // character spacing
		bra.s .vj14
.vj13:
		tst.w (A0)     // word spacing
.vj14:
		beq.s .vj15
		add.w D6,D5
.vj15:
		add.w D2,D3
		cmp.w D4,D3
		bcs.s .vj16
		sub.w D4,D3
		addq.w #1,D5
		tst.l D2
		bpl.s .vj16
		subq.w #2,D5
#endif
.vj16:
		move.w D5,(A5)
		addq.l #4,A5
.vj12:
#ifdef COLDFIRE
	subq.l #1,D0
	bpl.s .vj11
	move.l (SP)+,D7
#else
	dbf D0,.vj11
#endif
.vj6:
	moveq #0,D1
	tst.w HORIZONTAL_ALIGN(A2)
	beq.s .vj7               // left justified
	move.w 4(A3),D1          // x size
#ifdef COLDFIRE
	moveq #0,D0
	move.w HORIZONTAL_ALIGN(A2),D0
	cmp.l #2,D0
	beq.s .vj8
	lsr.l #1,D1 
.vj8:
	neg.l D1
#else
	cmp.w #2,HORIZONTAL_ALIGN(A2)
	beq.s .vj8
	lsr.w #1,D1 
.vj8:
	neg.w D1
#endif
	swap D1
	clr.w D1
.vj7:
	add.l (A3),D1            // x, y	
	move.l D7,D0             // string length
	lea 4(A0),A1             // string
	move.l fvdi_virtual,A0
	move.l (SP),A2           // the character offset table
	tst.b direct_call
	beq.s .vj18              // slower
	move.l D1,-(SP)
	move.w D1,D2
	swap D1
	ext.l D1
	ext.l D2
	move.l A0,-(SP)
	move.l A1,-(SP)
	move.l A2,-(SP)          // offsets
	move.l D2,-(SP)          // y
	move.l D1,-(SP)          // x
	move.l D0,-(SP)          // length
	move.l D0,D2
	move.l A1,-(SP)          // text
	move.l A0,-(SP)
	jsr _c_text_area
	lea 24(SP),SP
	move.l (SP)+,A1
	move.l (SP)+,A0
             move.l (SP)+,D1
	tst.l D0
	bne.s .vj17
             move.l D2,D0
	move.l (SP),A2           // the character offset table
	jsr _default_text
	bra.s .vj17
.vj18:
/*--------
* Draw some text
* c_text_area(Virtual *vwk, short *text, long length, long dst_x, long dst_y, short *offsets)
* In:	a0	VDI struct
*	a1	string address
*	a2	offset table
*	d0	string length
*	d1	x1,y1 destination
*-------*/
	move.l vwk_real_address(A0),A3
	move.l wk_r_text(A3),A3
	jsr (A3)
.vj17:
	jsr _free_block          // address still on stack
	addq.l #4,SP
#ifdef COLDFIRE
	movem.l (SP),D1-D7/A4-A5
	lea 36(SP),SP
#else
	movem.l (SP)+,D1-D7/A4-A5
#endif
.vj1:
	rts
	
det_vs_color:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
	move.l 4(A1),A1          // INTIN
	move.w (A1)+,D1          // color index
	blt .vco1
	ext.l D1
	moveq #0,D2
	move.w DEV_TAB+26(A0),D2
	cmp.l D2,D1              // nb colors
#else
	movem.l D1-D2,-(SP)
	move.l 4(A1),A1          // INTIN
	move.w (A1)+,D1          // color index
	blt .vco1
	cmp.w DEV_TAB+26(A0),D1  // nb colors
#endif
	bge .vco1
	moveq #1,D0              // number of entries
	swap D0
	move.w D1,D0             // index
	lea REQ_COL48(A0),A2
#ifdef COLDFIRE
	cmp.l #16,D2 // nb colors
	ble.s .vco2
	cmp.l #16,D1
	blt.s .vco2
	sub.l #16,D1
#else
	cmp.w #16,DEV_TAB+26(A0) // nb colors
	ble.s .vco2
	cmp.w #16,D1
	blt.s .vco2
	sub.w #16,D1
#endif
	lea REQ_COL48E(A0),A2
.vco2:
	mulu #6,D1
	add.l D1,A2
	move.l (A1),(A2)+        // red & green level 0-1000
	move.w 4(A1),(A2)+       // blue level 0-1000
	move.l fvdi_virtual,A0
	move.l vwk_palette(A0),A2
	move.l A2,D1
	bgt.s .vco3              // local palette
	move.l vwk_real_address(A0),A0
	move.l wk_screen_palette_colours(A0),A2 // global
.vco3:
/*--------
* Set palette colours
* c_set_colours(Virtual *vwk, long start, long entries, short requested[3][], Colour palette[])
* In:	a0	VDI struct
*	d0	number of entries (H), start entry (L)
*	a1	requested colour values (3 word/entry)
*	a2	colour palette
*-------*/
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A3
	move.l wk_r_set_palette(A3),A3
	jsr (A3)
.vco1:
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_vst_height:

	move.l D1,-(SP)
#ifdef COLDFIRE
	moveq #4,D0
	move.w D0,4(A3)          // length tab PTSOUT
#else
	move.w #4,4(A3)          // length tab PTSOUT
#endif
	move.l 8(A1),A3          // PTSIN
	move.w 2(A3),D0          // nb points PTSIN
	move.l ADR_FONT(A2),A3
	move.l font_extra_first_size(A3),A3
	move.l A3,ADR_FONT(A2)
.vsh1:
#ifdef COLDFIRE
		move.w TOP_LINE(A3),D1
		ext.l D1
		cmp.l D1,D0
#else
		cmp.w TOP_LINE(A3),D0
#endif
		bcs.s .vsh2
		move.l A3,ADR_FONT(A2)
		move.l font_extra_next_size(A3),A3
	move.l A3,D1
	bne.s .vsh1
.vsh2:
	move.l ADR_FONT(A2),A3
	move.l A3,CUR_FONT(A0)   // address current font
	move.l 16(A1),A1         // PTSOUT
	move.w CHARACTER_WIDTH(A3),(A1)+
	move.w TOP_LINE(A3),D0
	move.w D0,(A1)+          // height in pixels
	move.w CELL_WIDTH(A3),(A1)+
#ifdef COLDFIRE
	addq.l #1,D0
	move.w BOTTOM_LINE(A3),D1
	add.l D1,D0
#else
	addq.w #1,D0
	add.w BOTTOM_LINE(A3),D0
#endif
	move.w D0,(A1)           // height in pixels
	bsr update_fvdi_fontinfo
	move.l (SP)+,D1
	rts

det_vst_rotation:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #1,8(A3)          // length tab INTOUT
#endif
	move.l ADR_FONT(A2),CUR_FONT(A0)
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // rotation 1/10 degree
#ifdef COLDFIRE
	ext.l D0
	add.l #450,D0
	.chip 68000
	divs #900,D0
	.chip 5200
#else
	add.w #450,D0
	ext.l D0
	divs #900,D0
#endif
	muls #900,D0
	move.l 12(A1),A3         // INTOUT
	move.w D0,(A3)           // rotation selectedÇ
	move.w D0,CHUP(A2)
	move.w D0,_CHUP(A0)
	move.l fvdi_virtual,A0
	move.w D0,vwk_text_rotation(A0)
	rts

det_vsl_type:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0           // line type
	subq.l #1,D0
	blt.s .vt1
	cmp.l #6,D0
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0           // line type
	subq.w #1,D0
	blt.s .vt1
	cmp.w #6,D0
#endif /* COLDFIRE */
	ble.s .vt2
.vt1:
	moveq #0,D0
.vt2:
	move.w D0,LINE_TYPE(A2)
	addq.l #1,D0
	move.l fvdi_virtual,A0
	move.w D0,vwk_line_type(A0)
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)           // line type selected
	rts

det_vsl_width:

#ifdef COLDFIRE
	move.l D1,-(SP)
	moveq #1,D0
	move.w D0,4(A3)          // nb points PTSOUT
	move.l 8(A1),A3          // PTSIN
	move.w (A3),D0           // line width
	ble.s .vlw1
	moveq #0,D1
	move.w SIZ_TAB15+12(A0),D1
	cmp.l D1,D0              // max width
	blt.s .vlw3
	move.l D1,D0             // max width
.vlw3:
	btst #0,D0
	bne.s .vlw2              // odd
	subq.l #1,D0
#else /* !COLDFIRE */
	move.w #1,4(A3)          // nb points PTSOUT
	move.l 8(A1),A3          // PTSIN
	move.w (A3),D0           // line width
	ble.s .vlw1
	cmp.w SIZ_TAB15+12(A0),D0  // max width
	blt.s .vlw3
	move.w SIZ_TAB15+12(A0),D0 // max width
.vlw3:
	btst #0,D0
	bne.s .vlw2              // odd
	subq.w #1,D0
#endif /* COLDFIRE */
	bra.s .vlw2
.vlw1:
	moveq #1,D0              // min width
.vlw2:
	move.l 16(A1),A0         // PTSOUT
	move.w D0,(A0)           // line width selected
	move.w D0,LINE_WIDTH(A2)
	move.l fvdi_virtual,A0
	move.w D0,vwk_line_width(A0)
#ifdef COLDFIRE
	move.l (SP)+,D1
#endif
	rts

det_vsl_color:

	move.w D1,-(SP)
#ifdef COLDFIRE
	moveq #1,D1
	move.w D1,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w DEV_TAB+26(A0),D1 // nb colors
	moveq #0,D0
	move.w (A3),D0           // color index
	blt.s .vlc1
	cmp.l D1,D0
#else
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w DEV_TAB+26(A0),D1 // nb colors
	move.w (A3),D0           // color index
	blt.s .vlc1
	cmp.w D1,D0
#endif
	blt.s .vlc2
.vlc1:
	moveq #1,D0              // default color index
.vlc2:
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)           // color index selected
	move.l fvdi_virtual,A0
	ext.l D0
	move.l D0,vwk_line_colour(A0)
	lea tab_index_col_pal,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0
#else
	move.b (A0,D0.l),D0
#endif
	subq.l #1,D1
	and.l D1,D0
	move.w D0,LINE_COLOR_INDEX(A2)
	move.w  (SP)+,D1
	rts

det_vsm_type:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0           // mark type
	subq.l #1,D0
	blt.s .vmt1
	cmp.l #5,D0
#else
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0           // mark type
	subq.w #1,D0
	blt.s .vmt1
	cmp.w #5,D0
#endif
	ble.s .vmt2
.vmt1:
	moveq #2,D0
.vmt2:
	move.w D0,MARK_TYPE(A2)
	addq.l #1,D0
	move.l fvdi_virtual,A0
	move.w D0,vwk_marker_type(A0)
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)           // mark type selected
	rts

det_vsm_height:

	move.l D1,-(SP)
#ifdef COLDFIRE
	moveq #2,D0
	move.w D0,4(A3)          // length tab PTSOUT
	moveq #0,D1
#else
	move.w #2,4(A3)          // length tab PTSOUT
#endif
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // mark height
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A3
	move.w wk_drawing_marker_size_height_min(A3),D1
#ifdef COLDFIRE
	lsr.l #1,D1
	add.l D1,D0              // half the minimum height
	.chip 68000
	divu wk_drawing_marker_size_height_min(A3),D0 // w = 15n, h = 11n
	.chip 5200
	bne.s .dvh1
	moveq #1,D0
.dvh1:
	move.w wk_drawing_marker_size_possibilities(A3),D1
	ext.l D0
	cmp.l D1,D0
#else
	lsr.w #1,D1
	add.w D1,D0              // half the minimum height
	divu wk_drawing_marker_size_height_min(A3),D0 // w = 15n, h = 11n
	bne.s .dvh1
	moveq #1,D0
.dvh1:
	cmp.w wk_drawing_marker_size_possibilities(A3),D0
#endif
	bls.s .dvh2
	moveq #1,D0
.dvh2:
	move.w D0,D1
	mulu wk_drawing_marker_size_width_min(A3),D0
	swap D0
	mulu wk_drawing_marker_size_height_min(A3),D1
	move.w D1,D0
//	move.l D0,vwk_marker_size(A0)
	move.w D0,MARK_HEIGHT(A2)
	move.l 16(A1),A0         // PTSOUT
	move.l D0,(A0)           // mark height selected
	move.l (SP)+,D1
	moveq #0,D0
	rts

det_vsm_color:

	move.w D1,-(SP)
#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	moveq #0,D1
	move.w DEV_TAB+26(A0),D1 // nb colors
	move.w (A3),D0           // color index
	blt.s .dvmc1
	cmp.l D1,D0
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w DEV_TAB+26(A0),D1 // nb colors
	move.w (A3),D0           // color index
	blt.s .dvmc1
	cmp.w D1,D0
#endif /* COLDFIRE */
	blt.s .dvmc2
.dvmc1:
	moveq #1,D0              // default color index
.dvmc2:
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)           // color index selected
	move.l fvdi_virtual,A0
	ext.l D0
	move.l D0,vwk_marker_colour(A0)
	lea tab_index_col_pal,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0
#else
	move.b (A0,D0.l),D0
#endif
	subq.l #1,D1
	and.l D1,D0
	move.w D0,MARK_COLOR_INDEX(A2)
	move.w (SP)+,D1
	rts

det_vst_font:

	move.l D1,-(SP)
	move.l 4(A1),A3          // INTIN
#ifdef COLDFIRE
	moveq #0,D0
#endif
	move.w (A3),D0           // font
	bne.s .dvf1
	moveq #1,D0
.dvf1:
	move.l fvdi_virtual,A0	
	move.l vwk_real_address(A0),A3
	move.l wk_writing_first_font(A3),A3
.dvf3:       // search
#ifdef COLDFIRE
		moveq #0,D1
		move.w FACE_ID(A3),D1
		cmp.l D1,D0
#else
		cmp.w FACE_ID(A3),D0
#endif
		beq.s .dvf2
		move.l NEXT_FONT(A3),A3
	move.l A3,D1
	bne.s .dvf3
	moveq #1,D0              // default
	move.l vwk_real_address(A0),A3
	move.l wk_writing_first_font(A3),A3
.dvf2:
	move.l A3,ADR_FONT(A2)
	move.l adr_var_vdi,A0
	move.l A3,CUR_FONT(A0)   // address current font
	move.l 12(A1),A3         // INTOUT
	move.w D0,(A3)           // font selected
	bsr update_fvdi_fontinfo
	move.l (SP)+,D1
	rts
	
det_vst_color:

	move.w D1,-(SP)
#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l ADR_FONT(A2),CUR_FONT(A0)
	move.l 4(A1),A3          // INTIN
	moveq #0,D1
	move.w DEV_TAB+26(A0),D1 // nb colors
	move.w (A3),D0           // color index
	blt.s .vtc1
	cmp.l D1,D0
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l ADR_FONT(A2),CUR_FONT(A0)
	move.l 4(A1),A3          // INTIN
	move.w DEV_TAB+26(A0),D1 // nb colors
	move.w (A3),D0           // color index
	blt.s .vtc1
	cmp.w D1,D0
#endif /* COLDFIRE */
	blt.s .vtc2
.vtc1:
	moveq #1,D0              // default color index
.vtc2:
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)           // color index selected
	move.l fvdi_virtual,A0
	ext.l D0
	move.l D0,vwk_text_colour(A0)	
	lea tab_index_col_pal,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0
#else
	move.b (A0,D0.l),D0
#endif
	subq.l #1,D1
	and.l D1,D0
	move.w D0,TEXT_COLOR_INDEX(A2)
	move.w (SP)+,D1
	rts

det_vsf_interior:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // fill type
	blt.s .vfi2
	cmp.l #4,D0              // user pattern
#else
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // fill type
	blt.s .vfi2
	cmp.w #4,D0              // user pattern
#endif
	ble.s .vfi1
.vfi2:
	moveq #0,D0
.vfi1:
	move.w D0,FILL_INT_STYLE(A2)
	move.l 12(A1),A3         // INTOUT
	move.w D0,(A3)           // fill type selected
	move.l fvdi_virtual,A3
	move.w D0,vwk_fill_interior(A3)
	bra choice_fill
	
det_vsf_style:

#ifdef COLDFIRE
	move.l D1,-(SP)
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // fill pattern
	move.l 12(A1),A3         // INTOUT
	cmp.l #1,D0
	blt.s .vsf2
	moveq #0,D1
	move.w FILL_INT_STYLE(A2),D1
	cmp.l #2,D1              // fill type: frames
	bne.s .vsf1
	cmp.l #24,D0
	ble.s .vsf3
	bra.s .vsf2
.vsf1:
	cmp.l #12,D0
	ble.s .vsf3
.vsf2:
	moveq #1,D0
.vsf3:
	move.w D0,(A3)           // fill pattern selected
	move.l fvdi_virtual,A3
	move.w D0,vwk_fill_style(A3)
	subq.l #1,D0
	move.l (SP)+,D1
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // fill pattern
	move.l 12(A1),A3         // INTOUT
	cmp.w #1,D0
	blt.s .vsf2
	cmp.w #2,FILL_INT_STYLE(A2) // fill type: frames
	bne.s .vsf1
	cmp.w #24,D0
	ble.s .vsf3
	bra.s .vsf2
.vsf1:
	cmp.w #12,D0
	ble.s .vsf3
.vsf2:
	moveq #1,D0
.vsf3:
	move.w D0,(A3)           // fill pattern selected
	move.l fvdi_virtual,A3
	move.w D0,vwk_fill_style(A3)
	subq.w #1,D0
#endif /* COLDFIRE */
	move.w D0,FILL_STYLE_INDEX(A2) // index fill pattern

choice_fill:

	move.w FILL_INT_STYLE(A2),D0 // pattern type
#ifdef COLDFIRE
	cmp.l #4,D0              // user pattern
	bne.s .vsf8
	lea USER_DEF_FILL_PAT(A2),A1
	bra.s .vsf9
.vsf8:
	cmp.l #3,D0              // pattern
	bne.s .vsf4
	lea tab_pattern,A1
	bra.s .vsf7
.vsf4:
	cmp.l #2,D0              // frames
	bne.s .vsf5
	lea tab_frames,A1
.vsf7:
	move.w FILL_STYLE_INDEX(A2),D0 // index fill pattern
	asl.l #5,D0              // *32
	add.l D0,A1
	bra.s .vsf9
.vsf5:
	lea tab_full_pattern,A1
	cmp.l #1,D0              // color
#else /* !COLDFIRE */
	cmp.w #4,D0              // user pattern
	bne.s .vsf8
	lea USER_DEF_FILL_PAT(A2),A1
	bra.s .vsf9
.vsf8:
	cmp.w #3,D0              // pattern
	bne.s .vsf4
	lea tab_pattern,A1
	bra.s .vsf7
.vsf4:
	cmp.w #2,D0              // frames
	bne.s .vsf5
	lea tab_frames,A1
.vsf7:
	move.w FILL_STYLE_INDEX(A2),D0 // index fill pattern
	asl.w #5,D0              // *32
	add.w D0,A1
	bra.s .vsf9
.vsf5:
	lea tab_full_pattern,A1
	cmp.w #1,D0              // color
#endif /* COLDFIRE */
	beq.s .vsf9
	lea tab_empty_pattern,A1 // no fill
.vsf9:
	move.l A1,PATPTR(A2)
	move.l A1,_PATPTR(A0)
	moveq #15,D0
	move.w D0,PATMSK(A2)     // mask
	move.w D0,_PATMSK(A0)
	rts
	
_init_choice_fill:

	move.l A2,-(SP)
	move.l 8(SP),A0          // adr_var_vdi
	move.l 12(SP),A2         // work
	bsr choice_fill
	move.l (SP)+,A2
	rts

det_vsf_color:

	move.l D1,-(SP)
#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	moveq #0,D1
	move.w DEV_TAB+26(A0),D1 // nb colors
	move.w (A3),D0           // color index
	blt.s .vfc1
	cmp.l D1,D0
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w DEV_TAB+26(A0),D1 // nb colors
	move.w (A3),D0           // color index
	blt.s .vfc1
	cmp.w D1,D0
#endif /* COLDFIRE */
	blt.s .vfc2
.vfc1:
	moveq #1,D0              // default color index
.vfc2:
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)           // color index selected
	move.l fvdi_virtual,A0
	ext.l D0
	move.l D0,vwk_fill_colour(A0)
	lea tab_index_col_pal,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0
#else
	move.b (A0,D0.l),D0
#endif
	subq.l #1,D1
	and.l D1,D0
	move.w D0,FILL_COLOR_INDEX(A2)
	move.l (SP)+,D1
	rts

det_vq_color:

#ifdef COLDFIRE
	move.l D1,-(SP)
	moveq #4,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w (A3)+,D0          // color index
	blt.s .vqc1
	moveq #0,D1
	move.w DEV_TAB+26(A0),D1
	cmp.l D1,D0              // nb colors
#else /* !COLDFIRE */
	move.w #4,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w (A3)+,D0          // color index
	blt.s .vqc1
	cmp.w DEV_TAB+26(A0),D0  // nb colors
#endif /* COLDFIRE */
	bge.s .vqc1
	move.l 12(A1),A2         // INTOUT
	move.w D0,(A2)+
	move.l fvdi_virtual,A0
	move.l vwk_palette(A0),A1
	move.l A1,D1
	bgt.s .vqc5              // local palette
	move.l vwk_real_address(A0),A0
	move.l wk_screen_palette_colours(A0),A1 // global
.vqc5:
	mulu #colour_struct_size,D0
	tst.w (A3)               // flag index color used
	bne.s .vqc3              // current index (real colors)
	add.l #colour_vdi,A1
	bra.s .vqc4
.vqc3:
	add.l #colour_hw,A1
.vqc4:
	add.l D0,A1
	move.l (A1)+,(A2)+        // red & green level
	move.w (A1)+,(A2)+        // blue level
.vqc1:
#ifdef COLDFIRE
	move.l (SP)+,D1
#endif
	rts
	
gchc_key:	// 0: nothing happened, 1: choice value, 2: button pressed

	moveq #1,D0
	move.w D0,TERM_CH(A0)
	rts

gchr_key:

#ifdef COLDFIRE
	lea -20(SP),SP
	movem.l D1-D2/A0-A2,(SP)
#else
	movem.l D1-D2/A0-A2,-(SP)
#endif
	move.w #2,-(SP)          // CON
	move.w #1,-(SP)          // Bconstat
	trap #13
	addq.l #4,SP
#ifdef COLDFIRE
	ext.l D0
#else
	tst.w D0                 // D0=0 => no character
#endif
	beq .no_char
	move.w #2,-(SP)          // CON
	move.w #2,-(SP)          // Bconin
	trap #13
	addq.l #4,SP
	move.l D0,D1
	swap D1
#ifdef COLDFIRE
	asl.l #8,D1              // D0 <07:00> <- ascii code
	and.l #0xff00,D1
	or.l D1,D0               // D0 <15:08> <- scan code
#else
	asl.w #8,D1              // D0 <07:00> <- ascii code
	or.w D1,D0               // D0 <15:08> <- scan code
#endif
	move.l adr_var_vdi,A0
	move.w D0,TERM_CH(A0)    // store character
	moveq #1,D0              // indicate character present
.no_char:
#ifdef COLDFIRE
	movem.l (SP),D1-D2/A0-A2
	lea 20(SP),SP
#else
	movem.l (SP)+,D1-D2/A0-A2
#endif
	rts
	
gloc_key:	// get locator key

	move.l D2,-(SP)
#ifdef COLDFIRE
	move.w SR,D2
	move.w D2,-(SP)
	or.l #0x700,D2           // mask interrupts
	move.w D2,SR
#else
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
#endif
	move.b CUR_MS_STAT(A0),D0 
	bclr #5,CUR_MS_STAT(A0)  // clearing state change flags indicates
	bclr #6,CUR_MS_STAT(A0)  // that this data has been processed
	bclr #7,CUR_MS_STAT(A0)
	move.l G_CURX(A0),_X1(A0) // lastest X,Y
#ifdef COLDFIRE
	move.w (SP)+,D2
	move.w D2,SR
#else
	move.w (SP)+,SR
#endif
	moveq #0,D2              // initial status: no change
	btst #5,D2               // mouse move flag
	beq.s .glk4
	moveq #2,D2              // status: coordinate information valid
.glk4:
	btst #7,D0               // left mouse button status flag
	beq.s .glk2
	moveq #0x20,D0           // send terminator code for right key
	bra.s .glk5
.glk2:
	btst #6,D0               // right mouse button status flag
	beq.s .glk3     
	moveq #0x21,D0           // send terminator code for left key
.glk5:
	move.w D0,TERM_CH(A0)
	bset #0,D2               // button pressed
	bra.s .glk1
.glk3:	
	bsr gchr_key             // key pressed
	or.l D0,D2               // final locator status
.glk1:
	move.l D2,D0
	move.l (SP)+,D2
	tst.l D0                 // final locator status
	rts

det_v_locator:

	move.l 4(A1),A3          // INTIN
	moveq #1,D0
	move.w D0,(A3)
	move.l fvdi_virtual,A2
	move.l vwk_real_address(A2),A2
	move.l 8(A1),A3          // PTSIN
	move.l (A3),D0           // X,Y
	move.l D0,G_CURX(A0)     // set the initial locator position
	move.l D0,wk_mouse_position(A2)
	tst.w LOC_MODE(A0)
	bne.s .vlo2              // sample mode
	moveq #1,D0              // request mode
	move.w D0,4(A3)          // nb points PTSOUT
	move.w D0,8(A3)          // length tab INTOUT
	moveq #0,D0
	bsr show_c
.vlo3:
		bsr gloc_key
	btst #0,D0               // _X1 and _Y1 get updated
	beq.s .vlo3
	move.l 12(A1),A2         // INTOUT
	move.w TERM_CH(A0),D0
	and.l #0xff,D0
	move.w D0,(A2)           // terminating character
	move.l 16(A1),A2         // PTSOUT
	move.l _X1(A0),(A2)      // final cursor position
	bsr hide_c
	bra .vlo1
.vlo2:	// sample mode
	clr.w 4(A3)              // nb points PTSOUT
	clr.w 8(A3)              // length tab INTOUT
	bsr gloc_key 
	beq.s .vlo1              // nothing
	cmp.l #1,D0              // button or key pressed
	bne.s .vlo5
	clr.w 4(A3)              // nb points PTSOUT
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 12(A1),A2         // INTOUT
	move.w TERM_CH(A0),D0
	and.l #0xff,D0
	move.w D0,(A2)           // terminating character
	bra.s .vlo1
.vlo5:
	cmp.l #2,D0              // new coordinates
	bne.s .vlo4
	moveq #1,D0
	move.w D0,4(A3)          // nb points PTSOUT
	clr.w 8(A3)              // length tab INTOUT
	move.l 16(A1),A2         // PTSOUT
	move.l _X1(A0),(A2)
	bra.s .vlo1
.vlo4:
	cmp.l #3,D0              // button or key pressed and new coordinates
	bne.s .vlo1
	moveq #1,D0
	move.w D0,4(A3)          // nb points PTSOUT
	move.w D0,8(A3)          // length tab INTOUT
	move.l 12(A1),A2         // INTOUT
	move.w TERM_CH(A0),D0
	and.l #0xff,D0
	move.w D0,(A2)           // terminating character
	move.l 16(A1),A2         // PTSOUT
	move.l _X1(A0),(A2)
.vlo1:
	rts

det_v_cellarray:
det_vq_cellarray:
det_v_valuator:

	rts

det_v_choice:

	tst.w CHC_MODE(A0)
	bne.s .vch2
	moveq #1,D0
	move.w D0,8(A3)          // length
.vch1:
	bsr gchr_key
	beq.s .vch1
	bra.s .vch4
.vch2:
	bsr gchr_key
	move.w D0,8(A3)          // length
	beq.s .vch3
#ifdef COLDFIRE
	cmp.l #2,D0
#else
	cmp.w #2,D0
#endif
	bhi.s .vch3
	beq.s .vch4
	move.l 12(A1),A3         // INTOUT
	move.w TERM_CH(A0),D0
#ifdef COLDFIRE
	and.l #0xff,D0
#else
	and.w #0xff,D0
#endif
	move.w D0,(A3)           // tf_out
	bra.s .vch3
.vch4:
	move.l 12(A1),A3         // INTOUT
	move.w TERM_CH(A0),D0
#ifdef COLDFIRE
	and.l #0xff,D0
#else
	and.w #0xff,D0
#endif
	move.w D0,2(A3)          // tf_out
.vch3:
	rts

det_v_string:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
	move.l D3,-(SP)
	move.l #0xff,D1          // mask
	move.l 4(A1),A2          // INTIN
	move.w (A2),D3           // max length
	ext.l D3
	bpl.s .vrs1
	neg.l D3
	move.l #0xffff,D1        // mask
.vrs1:
	moveq #0,D2
	move.l 12(A1),A2         // INTOUT
	tst.w STR_MODE(A0)
	bne.s .vrs2
	clr.w TERM_CH(A0)
.vrs6:
		cmp.l D3,D2
		bcc.s .vrs4     // max length
		move.w TERM_CH(A0),D0
		and.l #0xff,D0
		cmp.l #13,D0
		beq.s .vrs4
.vrs5:
		bsr gchr_key
		beq.s .vrs5     // nothing  
		move.w TERM_CH(A0),D0
		and.l D1,D0
		move.w D0,TERM_CH(A0)
		move.w D0,(A2)+ // INTOUT
		addq.l #1,D2
	bra.s .vrs6
.vrs4:
	move.w TERM_CH(A0),D0
	and.l #0xff,D0
	cmp.l #13,D0
	bne.s .vrs3
	subq.l #1,D2
	bra.s .vrs3
.vrs2:	// sample mode
		cmp.l D3,D2
		bcc.s .vrs3     // max length
		bsr gchr_key
		beq.s .vrs3     // nothing
		moveq #0,D0
		move.w TERM_CH(A0),D0
		and.l D1,D0
		move.w D0,(A2)+ // INTOUT
		addq.l #1,D2
	bra.s .vrs2	    
.vrs3:	
	move.w D2,8(A3)          // length
	move.l (SP)+,D3
	move.l (SP)+,D2
	move.l (SP)+,D1
#else /* !COLDFIRE */
	movem.l D1-D3,-(SP)
	move.w #0xff,D1          // mask
	move.l 4(A1),A2          // INTIN
	move.w (A2),D3           // max length
	bpl.s .vrs1
	neg.w D3
	move.w #0xffff,D1        // mask 
.vrs1:
	moveq #0,D2
	move.l 12(A1),A2         // INTOUT
	tst.w STR_MODE(A0)
	bne.s .vrs2
	clr.w TERM_CH(A0)
.vrs6:
		cmp.w D3,D2
		bcc.s .vrs4     // max length
		move.w TERM_CH(A0),D0
		and.w #0xff,D0
		cmp.w #13,D0
		beq.s .vrs4
.vrs5:
		bsr gchr_key
		beq.s .vrs5     // nothing  
		and.w D1,TERM_CH(A0)
		move.w TERM_CH(A0),D0
		move.w D0,(A2)+ // INTOUT
		addq.l #1,D2
	bra.s .vrs6
.vrs4:
	move.w TERM_CH(A0),D0
	and.w #0xff,D0
	cmp.w #13,D0
	bne.s .vrs3
	subq.l #1,D2
	bra.s .vrs3
.vrs2:	// sample mode
		cmp.w D3,D2
		bcc.s .vrs3     // max length
		bsr gchr_key
		beq.s .vrs3     // nothing
		move.w TERM_CH(A0),D0
		and.w D1,D0
		move.w D0,(A2)+ // INTOUT
		addq.l #1,D2
	bra.s .vrs2	    
.vrs3:	
	move.w D2,8(A3)          // length
	movem.l (SP)+,D1-D3
#endif /* COLDFIRE */
	rts

det_vswr_mode:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)           // length tab INTOUT
	move.l 4(A1),A3           // INTIN
	move.w (A3),D0            // graphic mode
	subq.l #1,D0
	blt.s .vrm1
	cmp.l #3,D0
#else
	move.w #1,8(A3)           // length tab INTOUT
	move.l 4(A1),A3           // INTIN
	move.w (A3),D0            // graphic mode
	subq.w #1,D0
	blt.s .vrm1
	cmp.w #3,D0
#endif
	ble.s .vrm2
.vrm1:
	moveq #0,D0
.vrm2:
	move.w D0,WRT_MODE(A2)
	move.w D0,_WRT_MODE(A0)
	addq.l #1,D0
	move.l fvdi_virtual,A0
	move.w D0,vwk_mode(A0)
	move.l 12(A1),A0          // INTOUT
	move.w D0,(A0)            // graphic mode selected
	rts

det_vsin_mode:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A2          // INTIN
	move.w (A2)+,D0
	beq.s .vnm1
	cmp.l #4,D0
	bhi.s .vnm1
	move.w (A2)+,D1
	move.l 12(A1),A2         // INTOUT
	move.w D1,(A2)
	subq.l #1,D1
	add.l D0,D0
	lea tab_vin,A1
	move.w (A1,D0.l),D0
	ext.l D0
	move.w D1,(A0,D0.l)
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A2          // INTIN
	move.w (A2)+,D0
	beq.s .vnm1
	cmp.w #4,D0
	bhi.s .vnm1
	move.w (A2)+,D1
	move.l 12(A1),A2         // INTOUT
	move.w D1,(A2)
	subq.w #1,D1
	add.w D0,D0
	lea tab_vin,A1
	move.w (A1,D0.w),D0
	move.w D1,(A0,D0.w)
#endif /* COLDFIRE */
.vnm1:
	rts

det_vql_attributes:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,4(A3)          // nb points PTSOUT
	moveq #5,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 16(A1),A3         // PTSOUT
	move.w LINE_WIDTH(A2),(A3)+ // width line
	clr.w (A3)
	move.l 12(A1),A1         // INTOUT
	move.w LINE_TYPE(A2),D0
	addq.l #1,D0
	move.w D0,(A1)+          // type line
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.l #1,D0
	and.l #255,D0
	move.l D0,A0
	move.w LINE_COLOR_INDEX(A2),D0
	cmp.l A0,D0
	bne.s .vla1
	move.w #255,D0
.vla1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0    // => VDI color index
#else
	move.b (A0,D0.l),D0      // => VDI color index
#endif
#else /* !COLDFIRE */
	move.w #1,4(A3)          // nb points PTSOUT
	move.w #5,8(A3)          // length tab INTOUT
	move.l 16(A1),A3         // PTSOUT
	move.w LINE_WIDTH(A2),(A3)+ // width line
	clr.w (A3)
	move.l 12(A1),A1         // INTOUT
	move.w LINE_TYPE(A2),D0
	addq.w #1,D0
	move.w D0,(A1)+          // type line
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.w #1,D0
	and.w #255,D0
	move.w D0,A0
	move.w LINE_COLOR_INDEX(A2),D0
	cmp.w A0,D0
	bne.s .vla1
	move.w #255,D0
.vla1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.w*2),D0    // => VDI color index
#else
	move.b (A0,D0.w),D0      // => VDI color index
#endif
#endif /* COLDFIRE */
	move.w D0,(A1)+          // color line
	move.w WRT_MODE(A2),D0
	addq.l #1,D0
	move.w D0,(A1)+          // graphic mode
	move.w BEGIN_STYLE(A2),(A1)+ // begin line style
	move.w END_STYLE(A2),(A1) // end line style
	rts

det_vqm_attributes:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,4(A3)          // nb points PTSOUT
	moveq #3,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 16(A1),A3         // PTSOUT
	clr.w (A3)+              // width marker
	move.w MARK_HEIGHT(A2),(A3) // height marker
	move.l 12(A1),A1         // INTOUT
	move.w MARK_TYPE(A2),(A1)+ // type marker
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.l #1,D0
	and.l #255,D0
	move.l D0,A0
	move.w MARK_COLOR_INDEX(A2),D0
	cmp.l A0,D0
	bne.s .vma1
	move.w #255,D0
.vma1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0    // => VDI color index
#else
	move.b (A0,D0.l),D0      // => VDI color index
#endif
	move.w D0,(A1)+          // color marker
	move.w WRT_MODE(A2),D0
	addq.l #1,D0
	move.w D0,(A1)           // graphic mode
#else /* !COLDFIRE */
	move.w #1,4(A3)          // nb points PTSOUT
	move.w #3,8(A3)          // length tab INTOUT
	move.l 16(A1),A3         // PTSOUT
	clr.w (A3)+              // width marker
	move.w MARK_HEIGHT(A2),(A3) // height marker
	move.l 12(A1),A1         // INTOUT
	move.w MARK_TYPE(A2),(A1)+ // type marker
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.w #1,D0
	and.w #255,D0
	move.w D0,A0
	move.w MARK_COLOR_INDEX(A2),D0
	cmp.w A0,D0
	bne.s .vma1
	move.w #255,D0
.vma1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.w*2),D0    // => VDI color index
#else
	move.b (A0,D0.w),D0      // => VDI color index
#endif
	move.w D0,(A1)+          // color marker
	move.w WRT_MODE(A2),D0
	addq.l #1,D0
	move.w D0,(A1)           // graphic mode
#endif /* COLDFIRE */
	rts

det_vqf_attributes:

#ifdef COLDFIRE
	moveq #5,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 12(A1),A1         // INTOUT
	move.w FILL_INT_STYLE(A2),(A1)+ // fill type
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.l #1,D0
	and.l #255,D0
	move.l D0,A0
	move.w FILL_COLOR_INDEX(A2),D0
	cmp.l A0,D0
	bne.s .vqfa1
	move.w #255,D0
.vqfa1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0     // => VDI color index
#else
	move.b (A0,D0.l),D0      // => VDI color index
#endif
#else /* !COLDFIRE */
	move.w #5,8(A3)          // length tab INTOUT
	move.l 12(A1),A1         // INTOUT
	move.w FILL_INT_STYLE(A2),(A1)+ // fill type
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.w #1,D0
	and.w #255,D0
	move.w D0,A0
	move.w FILL_COLOR_INDEX(A2),D0
	cmp.w A0,D0
	bne.s .vqfa1
	move.w #255,D0
.vqfa1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.w*2),D0     // => VDI color index
#else
	move.b (A0,D0.w),D0      // => VDI color index
#endif
#endif /* COLDFIRE */
	move.w D0,(A1)+          // fill color
	move.w FILL_STYLE_INDEX(A2),D0
	addq.l #1,D0
	move.w D0,(A1)+          // fill pattern
	move.w WRT_MODE(A2),D0
	addq.l #1,D0
	move.w D0,(A1)+          // graphic mode
	move.w FILL_PER_VISIB(A2),(A1) // state border
	rts

det_vqt_attributes:

#ifdef COLDFIRE
	move.l D1,-(SP)
	moveq #2,D0
	move.w D0,4(A3)          // nb points PTSOUT
	moveq #6,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l ADR_FONT(A2),A0
	move.l 16(A1),A3         // PTSOUT
	move.w CHARACTER_WIDTH(A0),(A3)+ // character width, greatest char
	move.w TOP_LINE(A0),D0   // top line distance
	move.w D0,(A3)+          // height char
	move.w CELL_WIDTH(A0),(A3)+ // cell width
	move.w BOTTOM_LINE(A0),D1
	ext.l D1
	add.l D1,D0 // bottom line distance
	addq.l #1,D0
	move.w D0,(A3)           // cell height
	move.l 12(A1),A3         // INTOUT
	move.w FACE_ID(A0),(A3)+ // font identifier
	move.l adr_var_vdi,A0
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.l #1,D0
	and.l #255,D0
	move.l D0,A0
	move.w TEXT_COLOR_INDEX(A2),D0
	cmp.l A0,D0
	bne.s .dvqta1
	move.w #255,D0
.dvqta1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0    // => VDI color index
#else
	move.b (A0,D0.l),D0      // => VDI color index
#endif
#else /* !COLDFIRE */
	move.w #2,4(A3)          // nb points PTSOUT
	move.w #6,8(A3)          // length tab INTOUT
	move.l ADR_FONT(A2),A0
	move.l 16(A1),A3         // PTSOUT
	move.w CHARACTER_WIDTH(A0),(A3)+ // character width, greatest char
	move.w TOP_LINE(A0),D0   // top line distance
	move.w D0,(A3)+          // height char
	move.w CELL_WIDTH(A0),(A3)+ // cell width
	add.w BOTTOM_LINE(A0),D0 // bottom line distance
	addq.w #1,D0
	move.w D0,(A3)           // cell height
	move.l 12(A1),A3         // INTOUT
	move.w FACE_ID(A0),(A3)+ // font identifier
	move.l adr_var_vdi,A0
	move.w DEV_TAB+26(A0),D0 // nb colors
	subq.w #1,D0
	and.w #255,D0
	move.w D0,A0
	move.w TEXT_COLOR_INDEX(A2),D0
	cmp.w A0,D0
	bne.s .dvqta1
	move.w #255,D0
.dvqta1:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.w*2),D0    // => VDI color index
#else
	move.b (A0,D0.w),D0      // => VDI color index
#endif
#endif /* COLDFIRE */
	move.w D0,(A3)+          // text color
	move.w CHUP(A2),(A3)+    // rotation
	move.w HORIZONTAL_ALIGN(A2),(A3)+ // horizontal center
	move.w VERTICAL_ALIGN(A2),(A3)+   // vertical center
	move.w WRT_MODE(A2),D0
	addq.l #1,D0
	move.w D0,(A3)           // graphic mode
#ifdef COLDFIRE
	move.l (SP)+,D1
#endif
	rts

det_vst_alignment:

#ifdef COLDFIRE
	moveq #2,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l ADR_FONT(A2),CUR_FONT(A0) // address current font
	move.l 4(A1),A0          // INTIN
	move.l 12(A1),A1         // INTOUT
	move.w (A0)+,D0          // horizontal text alignment
	blt.s .vsta1
	cmp.l #2,D0              // right
#else
	move.w #2,8(A3)          // length tab INTOUT
	move.l ADR_FONT(A2),CUR_FONT(A0) // address current font
	move.l 4(A1),A0          // INTIN
	move.l 12(A1),A1         // INTOUT
	move.w (A0)+,D0          // horizontal text alignment
	blt.s .vsta1
	cmp.w #2,D0              // right
#endif
	ble.s .vsta2
.vsta1:
	moveq #0,D0              // left
.vsta2:
	move.w D0,(A1)+          // horizontal alignment selected
	move.w D0,HORIZONTAL_ALIGN(A2)
	move.l fvdi_virtual,A3
	move.w D0,vwk_text_alignment_horizontal(A3)
	move.w (A0)+,D0          // vertical text alignment
	blt.s .vsta3
#ifdef COLDFIRE
	cmp.l #5,D0              // top line
#else
	cmp.w #5,D0              // top line
#endif
	ble.s .vsta4
.vsta3:
	moveq #0,D0              // middle inf
.vsta4:
	move.w D0,(A1)           // vertical alignment selected
	move.w D0,VERTICAL_ALIGN(A2)
	move.w D0,vwk_text_alignment_vertical(A3)
	rts

det_v_opnvwk:

	move.l D1,-(SP)
	move.l D2,-(SP)
#ifdef COLDFIRE
	moveq #6,D0
	move.w D0,4(A3)          // nb points PTSOUT
	moveq #45,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #6,4(A3)          // nb points PTSOUT
	move.w #45,8(A3)         // length tab INTOUT
#endif
	move.l 16(A1),-(SP)      // PTSOUT
	move.l 12(A1),-(SP)      // INTOUT
	move.l 4(A1),-(SP)       // INTIN
	move.l adr_var_vdi,-(SP)
	jsr _V_OPNVWK
	lea 16(SP),SP
	move.w D0,12(A3)         // CONTRL[6]
	beq .vo1                 // error
	move.l adr_var_vdi,A0
	move.l CUR_WORK(A0),A0
	move.l FVDI_WORK(A0),A0
	move.l A0,fvdi_virtual
	bsr init_var_fvdi
	move.l fvdi_virtual,A0
	clr.l vwk_palette(A0)
	bsr find_default_font
	move.l adr_var_vdi,A0
	moveq #0,D0
	move.w V_PLANES(A0),D0   // nb planes
	cmp.l #8,D0
	bls.s .vo1               // global palette
	move.w #3,-(SP)          // TT ram if possible
	move.l #256*colour_struct_size,-(SP)    // size
	move.w #0x44,-(SP)       // Mxalloc
	trap #1 
	addq.l #8,SP
	tst.l D0                 // local palette
	beq.s .vo1
	move.l D0,A2
	move.l #0x1000000,D0
	lea _colours,A1          // default colors fVDI
/*--------
* Set palette colours
* c_set_colours(Virtual *vwk, long start, long entries, short requested[3][], Colour palette[])
* In:	a0	VDI struct
*	d0	number of entries (H), start entry (L)
*	a1	requested colour values (3 word/entry)
*	a2	colour palette
*-------*/
	move.l fvdi_virtual,A0
	move.l A2,vwk_palette(A0)
	move.l vwk_real_address(A0),A3
	move.l wk_r_set_palette(A3),A3
	jsr (A3)
.vo1:
	move.l (SP)+,D2
	move.l (SP)+,D1
	rts

det_v_clsvwk:

	move.l D1,-(SP)
	move.l fvdi_virtual,A0
	move.l vwk_palette(A0),D0
	ble.s .cvwk1             // no local palette
	clr.l vwk_palette(A0)
	move.l D0,-(SP)
	move.w #0x49,-(SP)       // Mfree
	trap #1 
	addq.l #6,SP
.cvwk1:
	move.l adr_var_vdi,-(sp)
             jsr _V_CLSVWK
             addq.l #4,SP
	move.l (SP)+,D1
	rts

det_vq_extend:

#ifdef COLDFIRE
	moveq #6,D0
	move.w D0,4(A3)          // nb points PTSOUT
	moveq #45,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #6,4(A3)          // nb points PTSOUT
	move.w #45,8(A3)         // length tab INTOUT
#endif
	move.l 4(A1),A2          // INTIN
	moveq #0,D0
	move.w (A2),D0
	bne.s .ve1
	move.l 16(A1),A2         // PTSOUT
	lea SIZ_TAB15(A0),A3     // datas for texts, lines, & markers outputs
	move.l (A3)+,(A2)+       // 2*6 parameters of PTSOUT
	move.l (A3)+,(A2)+
	move.l (A3)+,(A2)+
	move.l (A3)+,(A2)+
	move.l (A3)+,(A2)+
	move.l (A3),(A2)
	lea DEV_TAB(A0),A0       // 45 parameters of v_opnwk
	move.l 12(A1),A2         // INTOUT
	moveq #21,D0             // 45 parameters in INTOUT
.ve4:
		move.l (A0)+,(A2)+
#ifdef COLDFIRE
	subq.l #1,D0
	bpl.s .ve4
#else
	dbf D0,.ve4
#endif
	move.w (A0)+,(A2)+
	bra .ve2
.ve1:
#ifdef COLDFIRE
	cmp.l #2,D0              // vq_scrninfo ?
	bne.s .ve5
	move.w 10(A3),D0
	cmp.l #1,D0              // sub-function
#else
	cmp.w #2,D0              // vq_scrninfo ?
	bne.s .ve5
	cmp.w #1,10(A3)          // sub-function
#endif
	bne.s .ve5
	move.l 12(A1),A2         // INTOUT
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A0
	move.l wk_driver(A0),A3
	move.l driver_device(A3),A3
	move.l wk_screen_mfdb_address(A0),dev_address(A3)
	move.w wk_screen_wrap(A0),dev_byte_width(A3)
	move.l #(dev_struct_size/2)-1,D0
.ve6:
		move.w (A3)+,(A2)+
#ifdef COLDFIRE
	subq.l #1,D0
	bpl.s .ve6
#else
	dbf D0,.ve6
#endif
	bra.s .ve2
.ve5:
	move.l 16(A1),A2         // PTSOUT
	lea _XMN_CLIP(A0),A3
	move.l (A3)+,(A2)+       // clipping coords in 2*6 parameters of PTSOUT
	move.l (A3),(A2)+
	clr.l (A2)+
	clr.l (A2)+
	clr.l (A2)+
	clr.l (A2)
	lea INQ_TAB(A0),A0       // 45 paramätres de VQ_EXTEND
	move.l 12(A1),A2         // INTOUT
	moveq #21,D0             // 45 parameters in INTOUT
.ve3:
		move.l (A0)+,(A2)+
#ifdef COLDFIRE
	subq.l #1,D0
	bpl.s .ve3
#else
	dbf D0,.ve3
#endif
	move.w (A0)+,(A2)+
	lea 863(A0),A0           // offset var VDI +171
	lea -78(A2),A2           // INTOUT[6] nb op/S for resolution 16 * 16
	move.w #1000,(A2)
	btst #0,(A0)
	beq.s .ve2
	move.w #5000,(A2)
.ve2:
	moveq #0,D0
	rts

det_v_contourfill:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // color index (-1 for pixelread)
	ext.l D0
	move.l 8(A1),-(SP)       // PTSIN, coords x, y
	move.l D0,-(SP)          // color index
	move.l fvdi_virtual,-(SP)
	jsr _contourfill         // vwk, search_color, points
	lea 12(SP),SP
#ifdef COLDFIRE
	move.l (SP)+,D2
	move.l (SP)+,D1
#else
	movem.l (SP)+,D1-D2
#endif
	rts

det_vsf_perimeter:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #1,8(A3)          // length tab INTOUT
#endif
	move.l 4(A1),A0          // INTIN
	move.w (A0),D0           // border
	beq.s .vp1
	moveq #1,D0              // drawing
.vp1:
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)
	move.w D0,FILL_PER_VISIB(A2)
	move.l fvdi_virtual,A0
	move.w D0,vwk_fill_perimeter(A0)
	rts
	
det_v_get_pixel:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
	moveq #2,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 8(A1),A3          // PTSIN
	move.w (A3),D1           // X
	move.w 2(A3),D2          // Y
	move.l A0,-(SP)
	move.l A1,-(SP)
#else /* !COLDFIRE */
	movem.l D1-D2,-(SP)
	move.w #2,8(A3)          // length tab INTOUT
	move.l 8(A1),A3          // PTSIN
	movem.w (A3),D1-D2       // X, Y
	movem.l A0-A1,-(SP) 
#endif /* COLDFIRE */
	ext.l D1
	ext.l D2
	move.l D2,-(SP)          // Y
	move.l D1,-(SP)          // X
	bsr _pixelread
	addq.l #8,SP
#ifdef COLDFIRE
	move.l (SP)+,A1
	move.l (SP)+,A0
	move.l 12(A1),A3         // INTOUT
	moveq #0,D1
	move.w V_PLANES(A0),D1	
	cmp.l #16,D1
	bhi.s .vgp2
	beq.s .vgp3
	move.w D0,(A3)           // pixel color
	move.w DEV_TAB+26(A0),D1 // nb colors
	subq.l #1,D1
	and.l #255,D1
	ext.l D0
	cmp.l D1,D0
	bne.s .vgp4
	move.w #255,D0
.vgp4:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.l*2),D0
#else
	move.b (A0,D0.l),D0
#endif
	move.w D0,2(A3)          // index
	bra.s .vgp1	
.vgp3:
	move.w D0,(A3)           // 16 bits color
	moveq #-1,D0
	move.w D0,2(A3)          // index not used
	bra.s .vgp1
.vgp2:
	swap D0
	move.l D0,(A3)           // 32 bits color
.vgp1:
	move.l (SP)+,D2
	move.l (SP)+,D1
#else /* !COLDFIRE */
	movem.l (SP)+,A0-A1
	move.l 12(A1),A3         // INTOUT
	cmp.w #16,V_PLANES(A0)
	bhi.s .vgp2
	beq.s .vgp3
	move.w D0,(A3)           // pixel color
	move.w DEV_TAB+26(A0),D1 // nb colors
	subq.w #1,D1
	and.w #255,D1
	cmp.w D1,D0
	bne.s .vgp4
	move.w #255,D0
.vgp4:
	lea tab_index_col_vdi,A0
#ifdef TOS_TABLES
	move.w (A0,D0.w*2),D0
#else
	move.b (A0,D0.w),D0
#endif
	move.w D0,2(A3)          // index	
	bra.s .vgp1
.vgp3:
	move.w D0,(A3)           // 16 bits color
	move.w #-1,2(A3)         // index not used
	bra.s .vgp1
.vgp2:
	swap D0
	move.l D0,(A3)           // 32 bits color
.vgp1:
	movem.l (SP)+,D1-D2
#endif /* COLDFIRE */
	rts

det_vst_effects:

#ifdef COLDFIRE
	move.l D1,-(SP)
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // effect
	move.l ADR_FONT(A2),CUR_FONT(A0)
	moveq #0,D1
	move.w INQ_TAB+4(A0),D1
	and.l D1,D0              // text effects
#else /* !COLDFIRE */
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // effect
	move.l ADR_FONT(A2),CUR_FONT(A0)
	and.w INQ_TAB+4(A0),D0   // text effects
#endif /* COLDFIRE */
	move.l 12(A1),A3         // INTOUT
	move.w D0,(A3)           // effect selected
	move.w D0,STYLE(A2)
	move.w D0,_STYLE(A0)
	move.l fvdi_virtual,A0
	move.w D0,vwk_text_effects(A0)
#ifdef COLDFIRE
	move.l (SP)+,D1
#endif
	rts

det_vst_point:

	move.l D1,-(SP)
#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	moveq #4,D0
	move.w D0,4(A3)          // length tab PTSOUT
#else
	move.w #1,8(A3)          // length tab INTOUT
	move.w #4,4(A3)          // length tab PTSOUT
#endif
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // point
	move.l ADR_FONT(A2),A3
	move.l font_extra_first_size(A3),A3
	move.l A3,ADR_FONT(A2)
.vsp1:
#ifdef COLDFIRE
		moveq #0,D1
		move.w FONT_SIZE(A3),D1
		cmp.l D1,D0
#else
		cmp.w FONT_SIZE(A3),D0
#endif
		bcs.s .vsp2
		move.l A3,ADR_FONT(A2)
		move.l font_extra_next_size(A3),A3
	move.l A3,D1
	bne.s .vsp1
.vsp2:
	move.l ADR_FONT(A2),A3
	move.l A3,CUR_FONT(A0)
	move.l 12(A1),A0         // INTOUT
	move.w FONT_SIZE(A3),(A0) // point
	move.l 16(A1),A1         // PTSOUT
	move.w CHARACTER_WIDTH(A3),(A1)+
	move.w TOP_LINE(A3),(A1)+ // height in pixels
	move.w CELL_WIDTH(A3),(A1)+
	move.w FORMHEIGHT(A3),(A1) //  height in pixels
	bsr update_fvdi_fontinfo
	move.l (SP)+,D1
	rts	

det_vsl_ends:

#ifdef COLDFIRE
	moveq #2,D0
	move.w D0,8(A3)          // length tab INTOUT
	movem.l 4(A1),A0         // INTIN
	move.l 12(A1),A1         // INTOUT
	move.w (A0)+,D0          // begin line
	blt.s .vse1
	cmp.l #2,D0
#else
	move.w #2,8(A3)          // length tab INTOUT
	movem.l 4(A1),A0         // INTIN
	move.l 12(A1),A1         // INTOUT
	move.w (A0)+,D0          // begin line
	blt.s .vse1
	cmp.w #2,D0
#endif
	ble.s .vse2
.vse1:
	moveq #0,D0
.vse2:
	move.w D0,BEGIN_STYLE(A2)
	move.w D0,(A1)+          // begin line selected
	move.l fvdi_virtual,A3
	move.w D0,vwk_line_ends_beginning(A3)
	move.w (A0),D0           // end line
	blt.s .vse3
#ifdef COLDFIRE
	cmp.l #2,D0
#else
	cmp.w #2,D0
#endif
	ble.s .vse4
.vse3:
	moveq #0,D0
.vse4:
	move.w D0,END_STYLE(A2)
	move.w D0,vwk_line_ends_end(A3)
	move.w D0,(A1)           // end line selected
	rts

#if 0
aff_x:

	move.l D0,-(SP)
	move.w (A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	move.w 2(A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	move.w 4(A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	move.w 6(A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	move.w 8(A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	move.w 10(A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	move.w 12(A0),D0
	bsr hex_word
	moveq #0x20,D0
	bsr display_char
	move.w 14(A0),D0
	bsr hex_word	
	moveq #0x20,D0
	bsr display_char
	move.l D5,D0
	bsr hex_long
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	move.l (SP)+,D0
	rts
#endif

det_vro_cpyfm:

#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D1-D7,(SP)
#else
	movem.l D1-D7,-(SP)
#endif
	moveq #0,D5              // not screen
#if 1
	move.l 14(A3),D0         // source MFDB
	beq.s .vrc11             // source = screen
	move.l D0,A0
	move.l (A0),D0           // source address
	beq.s .vrc11             // source = screen
	cmp.l _v_bas_ad,D0
	bne.s .vrc12             // source <> screen
.vrc11:
	move.w #-1,D5            // source is screen
.vrc12:
#endif
	move.l 18(A3),D0         // target MFDB
	beq.s .vrc2              // target = screen
	move.l D0,A0
	move.l (A0),D0           // target address
	beq.s .vrc2              // target = screen
	cmp.l _v_bas_ad,D0
	bne.s .vrc3              // target <> screen
.vrc2:
	swap D5
	move.w #-1,D5            // target is screen
	swap D5
.vrc3:
	move.l 8(A1),A0          // PTSIN
	move.w 4(A0),D6          // X2 source
	ext.l D6
	move.w 6(A0),D7          // Y2 source
	ext.l D7
#if 1
	tst.w D5
	bpl.s .vrc14             // source isn't screen
	move.l A0,D0
	move.l adr_var_vdi,A0
	move.w DEV_TAB(A0),D1    // width and height screen -1
	move.w DEV_TAB+2(A0),D2
	move.l D0,A0
	ext.l D1
	ext.l D2
	cmp.l D1,D6
	ble.s .vrc13
	move.l D1,D6             // fix X2 source if screen
//	bsr aff_x
.vrc13:
	cmp.l D2,D7
	ble.s .vrc14
	move.l D2,D7             // fix Y2 source if screen
.vrc14:
#endif
	move.w 8(A0),D1          // X1 target
	move.w 10(A0),D2         // Y1 target
	ext.l D1
	ext.l D2
	move.l D1,D3             // calcul X2,Y2 target from source
	move.l D2,D4
	move.w (A0),D0           // X1 source
	ext.l D0
	sub.l D0,D3
	add.l D6,D3              // + X2 source fixed
	move.w 2(A0),D0          // Y1 source
	ext.l D0
	sub.l D0,D4
	add.l D7,D4              // + Y2 source fixed
             tst.l D5
	bpl.s .vrc4              // target isn't screen => no clipping
	tst.w CLIP(A2)           // clipping
	beq.s .vrc5              // clipping off
	move.w XMN_CLIP(A2),D0   // coords X1,X2,Y1,Y2 clipping
	move.w XMN_CLIP+2(A2),D5
	move.w XMN_CLIP+4(A2),D6
	move.w XMN_CLIP+6(A2),D7
	ext.l D0                 // X1 clipping
	ext.l D6                 // Y1 clipping
	bra.s .vrc6
.vrc5:
	move.l A0,D0
	move.l adr_var_vdi,A0
	move.w DEV_TAB(A0),D5    // width and height screen -1
	move.w DEV_TAB+2(A0),D7
	move.l D0,A0
	moveq #0,D0
	moveq #0,D6	
.vrc6:
	ext.l D5                 // X2 clipping
	ext.l D7                 // Y2 clipping
	cmp.l D0,D1              // check X1 target
	bge.s .vrc7              // X1 inside clipping
	cmp.l D0,D3
	blt .vrc1                // X2 out of clipping
	move.l D0,D1             // X1
.vrc7:
	cmp.l D6,D2              // check Y1 target
	bge.s .vrc8              // Y1 inside clipping
	cmp.l D6,D4
	blt .vrc1                // Y2 out of clipping
	move.l D6,D2             // Y1
.vrc8:
	cmp.l D5,D3              // check X2 target
	ble.s .vrc9              // X2 inside clipping
	cmp.l D5,D1
	bgt .vrc1                // X1 out of clipping
	move.l D5,D3             // X2
.vrc9:
	cmp.l D7,D4              // check Y2 target
	ble.s .vrc4              // Y2 inside clipping
	cmp.l D7,D2
	bgt .vrc1                // Y1 out of clipping
	move.l D7,D4             // Y2
.vrc4:
	move.l D4,D6             // Y2 target
	move.l D3,D5             // X2 target
	move.l D2,D4             // Y1 target
	move.l D1,D3             // X1 target
	move.w 8(A0),A2          // X1 target
	sub.l A2,D1
	move.w (A0),A2           // X1 source
	add.l A2,D1              // X1 source fixed
	move.w 10(A0),A2         // Y1 target
	sub.l A2,D2
	move.w 2(A0),A2          // Y1 source
	add.l A2,D2              // Y1 source fixed
	move.l 4(A1),A0          // INTIN
	moveq #0,D0
	move.w (A0),D0           // logic operation
	tst.b direct_call
	beq.s .vrc10             // slower
	sub.l D4,D6
	addq.l #1,D6
	ble.s .vrc1
	sub.l D3,D5
	addq.l #1,D5
	ble.s .vrc1
 	move.l D0,-(SP)          // operation
	move.l D6,-(SP)          // H
	move.l D5,-(SP)          // W
	move.l D4,-(SP)          // Y target
	move.l D3,-(SP)          // X target
	move.l 18(A3),-(SP)      // target MFDB
	move.l D2,-(SP)          // Y source
	move.l D1,-(SP)          // X source
	move.l 14(A3),-(SP)      // source MFDB
	move.l fvdi_virtual,-(SP)
	jsr _c_blit_area
	lea 40(SP),SP
	bra.s .vrc1
.vrc10:
/*--------
* Blit an area
* c_blit_area(Virtual *vwk, MFDB *src, long src_x, long src_y, MFDB *dst, long dst_x, long dst_y, long w, long h, long operation)
* In:	a0	VDI struct, destination MFDB, VDI struct, source MFDB
*	d0	logic operation
*	d1-d2	x1,y1 source
*	d3-d6	x1,y1 x2,y2 destination
*-------*/
	move.l fvdi_virtual,A0
	lea -16(SP),SP
	move.l A0,(SP)
	move.l 18(A3),4(SP)      // target MFDB
	move.l A0,8(SP)
 	move.l 14(A3),12(SP)     // source MFDB
	move.l vwk_real_address(A0),A3
	move.l wk_r_blit(A3),A3
 	move.l SP,A0
	jsr (A3)
	lea 16(SP),SP
.vrc1:
#ifdef COLDFIRE
	movem.l (SP),D1-D7
	lea 28(SP),SP
#else
	movem.l (SP)+,D1-D7
#endif
	rts

det_vr_trnfm:

	move.l D1,-(SP)
	lea 14(A3),A1            // ptr source/target MFDB
#if 0 // fVDI not need this test
	move.l (A1),A0           // MFDB source
	move.l (A0),D0           // src address
	move.l 4(A1),A2          // MFDB target
	cmp.l (A2),D0            // dst address
	bne .vtr2                // <> addresses
 	moveq #0,D1
 	move.w 4(A0),D1          // width
 	add.l #15,D1
 	lsr.l #4,D1              // /16
	mulu 12(A0),D1           // number of planes
	mulu 6(A0),D1            // height
	add.l D1,D1              // size in bytes
	move.l A1,-(SP)
	move.l D1,-(SP)
	jsr _allocate_block
	move.l (SP)+,D1
	move.l (SP)+,A1
	tst.l D0                 // src buffer
	beq .vtr2
	move.l D0,-(SP)          // save buffer address
	lsr.l #1,D1
	move.l D1,-(SP)          // words/line
	move.l A0,-(SP)          // src
	move.l D0,-(SP)          // dst
	jsr _copy_line
	lea 12(SP),SP
	move.l (SP),D0           // src buffer
	lea 14(A3),A1            // ptr source/target MFDB
	move.l (A1),A2           // MFDB source
	link A6,#-28
	lea -20(A6),A0
	move.l A0,-28(A6)        // new MFDB source
	move.l 4(A1),-24(A6)     // MFDB target
	move.l D0,(A0)+          
	addq.l #4,A2             // copy MFDB source
	move.l (A2)+,(A0)+
	move.l (A2)+,(A0)+
	move.l (A2)+,(A0)+
	move.l (A2),(A0)
	lea -28(A6),A1           // new ptr source/target MFDB
	move.l fvdi_virtual,A0
	jsr _lib_vr_trn_fm       // fVDI function
	unlk A6
	jsr _free_block
	addq.l #4,SP
	bra.s .vtr1
.vtr2:
#endif
	move.l fvdi_virtual,A0
	jsr _lib_vr_trn_fm       // fVDI function
.vtr1:
	move.l (SP)+,D1
	rts

det_vsc_form:

	tst.w _oldmouse
	bne .vf6
#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
#else
	movem.l D1-D2,-(SP)
#endif
//	bsr hide_c
	move.l 4(A1),A2          // INTIN
#ifdef COLDFIRE
	move.b MOUSE_FLAG(A0),D0
	addq.l #1,D0             // mask mouse interrupt routine
	move.b D0,MOUSE_FLAG(A0)
#else
	addq.b #1,MOUSE_FLAG(A0) // mask mouse interrupt routine
#endif
	moveq #0xF,D0
	move.w (A2)+,D1          // X action point
	and.l D0,D1
	move.w D1,M_POS_HX(A0)
	move.w (A2)+,D1          // Y action point
	and.l D0,D1
	move.w D1,M_POS_HY(A0)
	move.w (A2)+,D1
	move.w D1,M_PLANES(A0)
	move.w DEV_TAB+26(A0),D0 // nb colors
	move.w (A2)+,D1          // index VDI color, mask
	cmp.l D0,D1
	blt.s .vf1
	moveq #1,D1
.vf1:
	lea tab_index_col_pal,A3
#ifdef TOS_TABLES
	move.w (A3,D1.l*2),D1
#else
	move.b (A3,D1.l),D1
#endif
	move.w D1,M_CDB_BG(A0)
	move.w (A2)+,D1          // index VDI color, form
	cmp.l D0,D1
	blt.s .vf2
	moveq #1,D1
.vf2:
#ifdef TOS_TABLES
	move.w (A3,D1.l*2),D1
#else
	move.b (A3,D1.l),D1
#endif
#ifdef COLDFIRE
	subq.l #1,D0             // nb colors -1
	and.l D0,D1
	move.w D1,M_CDB_FG(A0)
	moveq #0,D1
	move.w M_CDB_BG(A0),D1
	and.l D0,D1
	move.w D1,M_CDB_BG(A0)
#else
	subq.w #1,D0             // nb colors -1
	and.w D0,M_CDB_BG(A0)
	and.w D0,D1
	move.w D1,M_CDB_FG(A0)
#endif
	lea MASKFORM(A0),A1	
	lea 32(A2),A3            // 16 words form
	moveq #15,D0
.vf3:
		move.w (A2)+,(A1)+ // word mask
		move.w (A3)+,(A1)+ // word form
#ifdef COLDFIRE
	subq.l #1,D0
	bpl.s .vf3
#else
	dbf D0,.vf3
#endif
/*--------
* Draw the mouse
* c_mouse_draw(Workstation *wk, long x, long y, Mouse *mouse)
* In:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move), 1 (hide), 2 (show), Mouse* (change)
* Call:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move shown), 1 (move hidden), 2 (hide), 3 (show), Mouse* (change)
* Out:	d0	mouse op to try again (low), pointer delay (high)
*-------*/
	move.l fvdi_virtual,A1
	move.l vwk_real_address(A1),A1
	move.w M_HID_CT(A0),wk_mouse_hide(A1)
	move.l G_CURX(A0),wk_mouse_position(A1)
	move.l M_POS_HX(A0),wk_mouse_hotspot(A1)
	lea tab_index_col_vdi,A2
#ifdef COLDFIRE
	moveq #0,D1
	move.w DEV_TAB+26(A0),D1 // nb colors
	subq.l #1,D1
	and.l #255,D1
	moveq #0,D0
	move.w M_CDB_BG(A0),D0
	cmp.l D1,D0
	bne.s .vf7
	move.w #255,D0
.vf7:
#ifdef TOS_TABLES
	move.w (A2,D0.l*2),D0
#else
	move.b (A2,D0.l),D0
#endif
	swap D0	
	moveq #0,D2
	move.w M_CDB_FG(A0),D2
	cmp.l D1,D2
	bne.s .vf8
	move.w #255,D2
.vf8:
#ifdef TOS_TABLES
	move.w (A2,D2.l*2),D0
#else
	move.b (A2,D2.l),D0	
#endif
#else /* !COLDFIRE */
	move.w DEV_TAB+26(A0),D1 // nb colors
	subq.w #1,D1
	and.w #255,D1
	move.w M_CDB_BG(A0),D0
	cmp.w D1,D0
	bne.s .vf7
	move.w #255,D0
.vf7:
#ifdef TOS_TABLES
	move.w (A2,D0.w*2),D0
#else
	move.b (A2,D0.w),D0
#endif
	swap D0	
	move.w M_CDB_FG(A0),D0
	cmp.w D1,D0
	bne.s .vf8
	move.w #255,D0
.vf8:
#ifdef TOS_TABLES
	move.w (A2,D0.w*2),D0
#else
	move.b (A2,D0.w),D0	
#endif
#endif /* COLDFIRE */
	move.l D0,wk_mouse_colour(A1)
	move.l A0,-(SP)
	lea MASKFORM(A0),A0
	moveq #15,D2
#ifdef COLDFIRE
	lea wk_mouse_mask(A1),A2
	lea wk_mouse_data(A1),A3
.vf4:
		move.w (A0)+,(A2)+
		move.w (A0)+,(A3)+
	subq.l #1,D2
	bpl.s .vf4
#else
	moveq #0,D1
.vf4:
		move.w (A0)+,wk_mouse_mask(A1,D1.w)
		move.w (A0)+,wk_mouse_data(A1,D1.w)
		addq.w #2,D1
	dbf D2,.vf4
#endif
	move.l (SP)+,A0
	tst.l wk_r_mouse(A1)
	beq.s .vf5               // no accel
	lea wk_mouse(A1),A2
	move.l wk_r_mouse(A1),A3
	move.l A2,D2             // change shape (pointer to mouse struct)
#ifdef COLDFIRE
	move.w G_CURX(A0),D0
	move.w G_CURY(A0),D1
#else
	movem.w G_CURX(A0),D0-D1
#endif
	swap D0
	move.w mouse_op,D0
	swap D0
	jsr (A3)
	move.w D0,mouse_op       // what to try again
.vf5:
	move.l adr_var_vdi,A0
#ifdef COLDFIRE
	move.w SR,D0
	move.w D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	move.l G_CURX(A0),CUR_X(A0) // actual position for the next drawing
	bset #0,CUR_FLAG(A0)     // VBL redraw actived
	move.w (SP)+,D0
	move.w D0,SR
	move.b MOUSE_FLAG(A0),D0
	subq.l #1,D0             // remove mask mouse interrupt routine
	move.b D0,MOUSE_FLAG(A0)
//	moveq #1,D0              // no reset
//	bsr show_c
	move.l (SP)+,D2
	move.l (SP)+,D1
#else /* !COLDFIRE */
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
	move.l G_CURX(A0),CUR_X(A0) // actual position for the next drawing
	bset #0,CUR_FLAG(A0)     // VBL redraw actived
	move.w (SP)+,SR
	subq.b #1,MOUSE_FLAG(A0) // remove mask mouse interrupt routine
//	moveq #1,D0              // no reset
//	bsr show_c
	movem.l (SP)+,D1-D2
#endif /* COLDFIRE */
.vf9:
	rts
.vf6:
	lea tab_vdi(PC),A0
	cmp.l A4,A0
	beq.s .vf9               // call from _GSX_ENTRY => impossible to use old mouse
	addq.l #4,SP             // pop return address
#ifdef COLDFIRE
	movem.l (SP),A0-A3
	lea 16(SP),SP
#else
	movem.l (SP)+,A0-A3
#endif
#ifdef XAAES_SEMAPHORE
	move.w (SP)+,D0
	beq.s .vf10
#endif
	move.l save_stack,SP
#ifdef XAAES_SEMAPHORE
.vf10:
	clr.b semaphore
#endif
	moveq #0x73,D0
	move.l _old_vector_vdi,-(SP)
	rts

det_vsf_updat:

	move.l D1,-(SP)
	move.l D2,-(SP)
#ifdef COLDFIRE
	moveq #0,D0
	move.w 6(A3),D0          // length tab INTIN
	lsr.l #1,D0
#else
	move.w 6(A3),D0          // length tab INTIN
	lsr.w #1,D0
#endif
	move.l 4(A1),A3          // INTIN
	lea USER_DEF_FILL_PAT(A2),A1
	move.l A0,-(SP)
	move.l fvdi_virtual,A0
	move.l A1,vwk_fill_user_pattern_in_use(A0)
	move.l (SP)+,A0
#ifdef COLDFIRE
	cmp.l #8,D0
#else
	cmp.w #8,D0
#endif
	bne.s .vfu3
	move.l (A3)+,(A1)+       // fill pattern 16 * 16 for 1 plane => monochrome
	move.l (A3)+,(A1)+
	move.l (A3)+,(A1)+
	move.l (A3)+,(A1)+
	move.l (A3)+,(A1)+
	move.l (A3)+,(A1)+
	move.l (A3)+,(A1)+
	move.l (A3)+,(A1)+
	moveq #0,D0              // pattern fo 1 plane
	bra.s .vfu1
.vfu3:
#ifdef COLDFIRE
	cmp.l #256,D0
	bhi.s .vfu6
	subq.l #1,D0
	bmi.s .vfu6
	moveq #0,D1
	move.w V_PLANES(A0),D1   // nb planes
	cmp.l #16,D1
	bne.s .vfu2              // <> 65K colors
.vfu5:	
		move.b 1(A3),D2 // red
		asl.l #8,D2
		and.l #0xF800,D2
		move.b 2(A3),D1 // green
		asl.l #3,D1
		and.l #0x07E0,D1
		or.l D1,D2
		move.b 3(A3),D1 // blue
		and.l #0x001F,D1
		or.l D1,D2
		move.w D2,(A1)+ // 65K colors
		addq.l #4,A3
	subq.l #1,D0
	bpl.s .vfu5
	bra.s .vfu4
.vfu2:
		move.l (A3)+,(A1)+
	subq.l #1,D0
	bpl.s .vfu2
.vfu4:
	moveq #1,D0
.vfu1:
	move.w D0,MULTIFILL(A2)
	move.w D0,_MULTIFILL(A0) // pattern for X planes
	move.l fvdi_virtual,A0
	move.w D0,vwk_fill_user_multiplane(A0)
.vfu6:
	move.l (SP)+,D2
	move.l (SP)+,D1
#else /* !COLDFIRE */
	cmp.w #256,D0
	bhi.s .vfu6
	subq.w #1,D0
	bmi.s .vfu6
	cmp.w #16,V_PLANES(A0)   // nb planes
	bne.s .vfu2              // <> 65K colors
.vfu5:	
		move.b 1(A3),D2 // red
		asl.w #8,D2
		and.w #0xF800,D2
		move.b 2(A3),D1 // green
		asl.w #3,D1
		and.w #0x07E0,D1
		or.w D1,D2
		move.b 3(A3),D1 // blue
		and.w #0x001F,D1
		or.w D1,D2
		move.w D2,(A1)+ // 65K colors
		addq.l #4,A3
	dbf D0,.vfu5
	bra.s .vfu4
.vfu2:
		move.l (A3)+,(A1)+
	dbf D0,.vfu2
.vfu4:
	moveq #1,D0
.vfu1:
	move.w D0,MULTIFILL(A2)
	move.w D0,_MULTIFILL(A0) // pattern for X planes
	move.l fvdi_virtual,A0
	move.w D0,vwk_fill_user_multiplane(A0)
.vfu6:
	move.l (SP)+,D2
	move.l (SP)+,D1
#endif /* COLDFIRE */
	rts
	
det_vsl_udsty:

	move.l 4(A1),A0          // INTIN
	move.w (A0),USER_DEF_LINE_STYLE_PAT(A2) // user line type
	rts

det_vr_recfl:

	move.l 8(A1),A0          // PTSIN
	bsr rectangle
	rts

det_vqin_mode:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 4(A1),A2          // INTIN
	move.w (A2),D0
	beq.s .vqm1
	cmp.l #4,D0
	bhi.s .vqm1
	move.l 12(A1),A2         // INTOUT
	add.l D0,D0
	move.w tab_vin(PC,D0.l),D0
	ext.l D0
	move.w (A0,D0.l),(A2)
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l 4(A1),A2          // INTIN
	move.w (A2),D0
	beq.s .vqm1
	cmp.w #4,D0
	bhi.s .vqm1
	move.l 12(A1),A2         // INTOUT
	add.l D0,D0
	move.w tab_vin(PC,D0.w),D0
	move.w (A0,D0.w),(A2)
#endif /* COLDFIRE */
.vqm1:
	rts

tab_vin:
	dc.w 0                   // offset var VDI
	dc.w LOC_MODE
	dc.w VAL_MODE
	dc.w CHC_MODE
	dc.w STR_MODE
 
det_vqt_extent:

#ifdef COLDFIRE
	moveq #4,D0
	move.w D0,4(A3)          // length tab PTSOUT
#else
	move.w #4,4(A3)          // length tab PTSOUT
#endif
	move.w 6(A3),D0          // length tab INTIN
	move.l 4(A1),A0          // INTIN	
	move.l 16(A1),A1         // PTSOUT
	bsr vqt_extent
	rts

vqt_extent:

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D1-D4/A2-A3,(SP)
	moveq #0,D1
	moveq #0,D4
#else
	movem.l D1-D3/A2-A3,-(SP)
#endif
	move.w D0,D3             // length tab INTIN
	swap D3
	move.w D0,D3             // length tab INTIN
	move.l adr_var_vdi,A3
	move.l CUR_WORK(A3),A3
	move.l ADR_FONT(A3),A3
	move.l A2,-(SP)
	move.l CHAR_OFF_TABLE(A3),A2  // offset table of characters
	moveq #0,D2              // border text
	move.w FIRST_ADE(A3),D1  // lower ASCII code
	bra.s .vte1
.vte2:
#ifdef COLDFIRE
		moveq #0,D0
		move.w (A0)+,D0 // char
		sub.l D1,D0     // - ASCII base code
		add.l D0,D0
		move.w 2(A2,D0.l),D4
		add.l D4,D2
		move.w (A2,D0.l),D4
		sub.l D4,D2
.vte1:
	move.w D3,D0
	ext.l D0
	subq.l #1,D0
	move.w D0,D3
	bpl.s .vte2
#else /* !COLDFIRE */
		move.w (A0)+,D0 // char
		sub.w D1,D0     // - ASCII base code
		add.w D0,D0
		add.w 2(A2,D0.w),D2
		sub.w (A2,D0.w),D2
.vte1:
	dbf D3,.vte2             // next char
#endif
	move.l (SP)+,A2
	swap D3                  // length tab INTIN
	move.w STYLE(A2),D0      // style
	btst #0,D0               // bold char
	beq.s .vte3
	btst #3,FONTFLAGS+1(A3)
	bne.s .vte3              // no proportionnal font (characters with same width)
	move.w THICKENING(A3),D1
	mulu D3,D1               // * size tab INTIN = nb characters
	add.l D1,D2
.vte3:
	btst #2,D0               // italic
	beq.s .vte4
#ifdef COLDFIRE
	move.w LEFT_OFFSET(A3),D4  // + left offset
	ext.l D4
	add.l D4,D2
	move.w RIGTH_OFFSET(A3),D4 // + right offset
	ext.l D4
	add.l D4,D2
.vte4:
	move.w TOP_LINE(A3),D1   // top line distance
	ext.l D1
	move.w BOTTOM_LINE(A3),D4 // bottom line distance
	ext.l D4
 	add.l D4,D1 
	addq.l #1,D1             // height border text
#if 0 // fVDI outlined width/height <=> normal
	btst #4,D0               // outlined
	beq.s .vte6
	ext.l D3
	add.l D3,D3              // size tab INTIN = nb characters
	add.l D3,D2
	addq.l #2,D1
#endif
#else /* !COLDFIRE */
	add.w LEFT_OFFSET(A3),D2 // + left offset
	add.w RIGTH_OFFSET(A3),D2 // + right offset
.vte4:
	move.w TOP_LINE(A3),D1   // top line distance
 	add.w BOTTOM_LINE(A3),D1 // bottom line distance
	addq.w #1,D1             // height border text
#if 0 // fVDI outlined width/height <=> normal
	btst #4,D0               // outlined
	beq.s .vte6
	add.w D3,D3              // size tab INTIN = nb characters
	add.w D3,D2
	addq.w #2,D1
#endif
#endif /* COLDFIRE */
.vte6:
	move.w CHUP(A2),D0       // rotation
	bne.s .vte7
	clr.l (A1)+
	move.w D2,(A1)+
	clr.w (A1)+
	move.w D2,(A1)+
	move.w D1,(A1)+
	clr.w (A1)+
	move.w D1,(A1)
	bra.s .vte5
.vte7:
#ifdef COLDFIRE
	ext.l D0
	cmp.l #900,D0
#else
	cmp.w #900,D0
#endif
	bne.s .vte8
	move.w D1,(A1)+
	clr.w (A1)+
	move.w D1,(A1)+
	move.w D2,(A1)+
	clr.w (A1)+
	move.w D2,(A1)+
	clr.l (A1)
	bra.s .vte5
.vte8:
#ifdef COLDFIRE
	cmp.l #1800,D0
#else
	cmp.w #1800,D0
#endif
	bne.s .vte9
	move.w D2,(A1)+
	move.w D1,(A1)+
	clr.w (A1)+
	move.w D1,(A1)+
	clr.l (A1)+
	move.w D2,(A1)+
	clr.w (A1)
	bra.s .vte5
.vte9:
#ifdef COLDFIRE
	cmp.l #2700,D0
#else
	cmp.w #2700,D0
#endif
	bne.s .vte5
	clr.w (A1)+
	move.w D2,(A1)+
	clr.l (A1)+
	move.w D1,(A1)+
	clr.w (A1)+
	move.w D1,(A1)+
	move.w D2,(A1)
.vte5:
#ifdef COLDFIRE
	movem.l (SP),D1-D4/A2-A3
	lea 24(SP),SP
#else
	movem.l (SP)+,D1-D3/A2-A3
#endif
	rts

det_vqt_width:

	move.l D1,-(SP)
#ifdef COLDFIRE
	move.l D2,-(SP)
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	moveq #6,D0
	move.w D0,4(A3)          // length tab PTSOUT
#else
	move.w #1,8(A3)          // length tab INTOUT
	move.w #6,4(A3)          // length tab PTSOUT
#endif
	move.l 4(A1),A3          // INTIN
	move.l 12(A1),A2         // INTOUT
	move.l 16(A1),A1         // PTSOUT
	move.w (A3),D0           // character
	move.l adr_var_vdi,A3
	move.l CUR_WORK(A3),A3
	move.l ADR_FONT(A3),A3
	move.w FIRST_ADE(A3),D1
#ifdef COLDFIRE
	ext.l D1
	neg.l D1
	add.l D0,D1
	move.w LAST_ADE(A3),D2
	ext.l D2
	cmp.l D2,D1
	bhi.s .vqw2
	move.w D0,(A2)           // character
	add.l D1,D1
	move.l CHAR_OFF_TABLE(A3),A0 // offset table of characters
	move.w 2(A0,D1.l),D0
	ext.l D0
	move.w (A0,D1.l),D2
	ext.l D2
	sub.l D2,D0
#else
	neg.w D1
	add.w D0,D1
	cmp.w LAST_ADE(A3),D1
	bhi.s .vqw2
	move.w D0,(A2)           // character
	add.w D1,D1
	move.l CHAR_OFF_TABLE(A3),A0 // offset table of characters
	move.w 2(A0,D1.w),D0
	sub.w (A0,D1.w),D0
#endif
	move.w D0,(A1)+          // cell width
	clr.l (A1)+              // left delta
	btst #1,FONTFLAGS+1(A3)
	beq.s .vqw1
	move.l HOR_OFF_TABLE(A3),A0 // horizontal offset table
#ifdef COLDFIRE
	move.w 2(A0,D1.l),D0
	ext.l D0
	move.w (A0,D1.l),D2
	ext.l D2
	sub.l D2,D0
#else
	move.w 2(A0,D1.w),D0
	sub.w (A0,D1.w),D0
#endif
	move.w D0,-2(A1)         // left delta
.vqw1:
	clr.w (A1)+
	clr.l (A1)               // right delta
	bra.s .vqw3
.vqw2:
	move.w #-1,(A2)          // invalid character
.vqw3:
#ifdef COLDFIRE
	move.l (SP)+,D2
#endif
	move.l (SP)+,D1
	rts

det_vex_time:

	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l 12(A1),A1         // INTOUT
	move.w _timr_ms,(A1)
	lea USER_TIM(A0),A0
	bra change_vex

det_vst_load_fonts:

	move.l D1,-(SP)
#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #1,8(A3)          // length tab INTOUT
#endif
	move.l 12(A1),A0         // INTOUT
	clr. (A0)
	move.l (SP)+,D1
	rts

det_vst_unload_fonts:

	rts

det_vrt_cpyfm:

#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D1-D7,(SP)
#else
	movem.l D1-D7,-(SP)
#endif
	moveq #0,D5              // not screen
	move.l 18(A3),D0         // target MFDB
	beq.s .vrtc2             // target = screen
	move.l D0,A0	
	move.l (A0),D0           // target address
	beq.s .vrtc2             // target = screen
	cmp.l _v_bas_ad,D0
	bne.s .vrtc3             // target <> screen
.vrtc2:
	moveq #-1,D5             // screen
.vrtc3:
	move.l 8(A1),A0          // PTSIN
	move.w 8(A0),D1          // X1 target
	move.w 10(A0),D2         // Y1 target
	ext.l D1
	ext.l D2
	move.l D1,D3             // calcul X2,Y2 target from source
	move.l D2,D4
	move.w (A0),D7           // X1 source
	ext.l D7
	sub.l D7,D3
	move.w 4(A0),D0          // X2 source
	ext.l D0
	add.l D0,D3
	move.w 2(A0),D0          // Y1 source
	ext.l D0
	sub.l D0,D4
	move.w 6(A0),D0          // Y2 source
	ext.l D0
	add.l D0,D4
             tst.l D5
	beq.s .vrtc4             // no clipping
	bsr clip_rect
	beq .vrtc1               // nothing to do
.vrtc4:
	move.l D4,D6             // Y2 target
	move.l D3,D5             // X2 target
	move.l D2,D4             // Y1 target
	move.l D1,D3             // X1 target
	move.w 8(A0),A2          // X1 target
	sub.l A2,D1
	add.l D7,D1              // X1 source fixed
	move.w 10(A0),A2         // Y1 target
	sub.l A2,D2
	move.w 2(A0),A2          // Y1 source
	add.l A2,D2              // Y1 source fixed
	move.l 4(A1),A0          // INTIN
	moveq #0,D7
	move.w (A0)+,D7          // logic operation
	move.l (A0),D0
	swap D0                  // colors
	tst.b direct_call
	beq.s .vrtc5             // slower
	move.l D0,-(SP)          // colors
	move.l D7,-(SP)          // operation
	sub.l D4,D6
	addq.l #1,D6
	move.l D6,-(SP)          // H
	sub.l D3,D5
	addq.l #1,D5
	move.l D5,-(SP)          // W
	move.l D4,-(SP)          // Y target
	move.l D3,-(SP)          // X target
	move.l 18(A3),-(SP)      // target MFDB
	move.l D2,-(SP)          // Y source
	move.l D1,-(SP)          // X source
	move.l 14(A3),-(SP)      // source MFDB
	move.l fvdi_virtual,-(SP)
	jsr _c_expand_area
	lea 44(SP),SP
	bra.s .vrtc1
.vrtc5:
/*--------
* Expand a monochrome area to multiple bitplanes
* c_expand_area(Virtual *vwk, MFDB *src, long src_x, long src_y, MFDB *dst, long dst_x, long dst_y, long w, long h, long operation, long colour)
* In:	a0	VDI struct, destination MFDB, VDI struct, source MFDB
*	d0	colours
*	d1-d2	x1,y1 source
*	d3-d6	x1,y1 x2,y2 destination
*	d7	logic operation
*-------*/
	move.l fvdi_virtual,A0
	lea -16(SP),SP
	move.l A0,(SP)
	move.l 18(A3),4(SP)      // target MFDB
	move.l A0,8(SP)
 	move.l 14(A3),12(SP)     // source MFDB
	move.l vwk_real_address(A0),A3
	move.l wk_r_expand(A3),A3
 	move.l SP,A0
	jsr (A3)
	lea 16(SP),SP
.vrtc1:
#ifdef COLDFIRE
	movem.l (SP),D1-D7
	lea 28(SP),SP
#else
	movem.l (SP)+,D1-D7
#endif
	moveq #0,D0
	rts

det_v_show_c:

	tst.w _oldmouse
	bne.s .vsc
	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // reset
	bsr show_c
.end_vsc:
	rts
.vsc:
	lea tab_vdi(PC),A0
	cmp.l A4,A0
	beq.s .end_vsc           // call from _GSX_ENTRY => impossible to use old mouse
	addq.l #4,SP             // pop return address
#ifdef COLDFIRE
	movem.l (SP),A0-A3
	lea 16(SP),SP
#else
	movem.l (SP)+,A0-A3
#endif
#ifdef XAAES_SEMAPHORE
	move.w (SP)+,D0
	beq.s .vscx
#endif
	move.l save_stack,SP
#ifdef XAAES_SEMAPHORE
.vscx:
	clr.b semaphore
#endif
	moveq #0x73,D0
	move.l _old_vector_vdi,-(SP)
	rts

show_c:

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D1-D2/A0-A3,(SP)
	move.l adr_var_vdi,A0
	move.w D0,-(SP)
	move.b MOUSE_FLAG(A0),D0
	addq.l #1,D0             // mask mouse interrupt routine
	move.b D0,MOUSE_FLAG(A0)
	move.w (SP)+,D0          // reset
	beq.s .shc1              // reset cursor to on
	move.w M_HID_CT(A0),D0
	beq.s .shc3
	subq.l #1,D0
#else
	movem.l D1-D2/A0-A3,-(SP)
	move.l adr_var_vdi,A0
	addq.b #1,MOUSE_FLAG(A0) // mask mouse interrupt routine
	tst.w D0                 // reset
	beq.s .shc1              // reset cursor to on
	move.w M_HID_CT(A0),D0
	beq.s .shc3
	subq.w #1,D0
#endif
	move.w D0,M_HID_CT(A0)
	bgt.s .shc2
	bra.s .shc4
.shc1:
	tst.w M_HID_CT(A0)
	beq.s .shc3              // already in show state, do no draw the mouse a 2nd time without restore screen
.shc4:
	clr.w M_HID_CT(A0)
	move.l G_CURX(A0),CUR_X(A0) // actual position for the next drawing
	// display the cursor
/*--------
* Draw the mouse
* c_mouse_draw(Workstation *wk, long x, long y, Mouse *mouse)
* In:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move), 1 (hide), 2 (show), Mouse* (change)
* Call:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move shown), 1 (move hidden), 2 (hide), 3 (show), Mouse* (change)
* Out:	d0	mouse op to try again (low), pointer delay (high)
*-------*/
	move.l fvdi_virtual,A1
	move.l vwk_real_address(A1),A1
	move.l G_CURX(A0),wk_mouse_position(A1)
	clr.w wk_mouse_hide(A1)
	move.l wk_r_mouse(A1),D2
	beq.s .shc3              // no accel
	move.l D2,A3
	moveq #3,D2              // show
#ifdef COLDFIRE
	move.w G_CURX(A0),D0
	move.w G_CURY(A0),D1
#else
	movem.w G_CURX(A0),D0-D1
#endif
	swap D0
	move.w mouse_op,D0
	swap D0
	jsr (A3)
	move.w D0,mouse_op       // what to try again
.shc3:
	move.l adr_var_vdi,A0	
	bclr #0,CUR_FLAG(A0)     // VBL redraw disabled
.shc2:	
#ifdef COLDFIRE
	move.b MOUSE_FLAG(A0),D0
	subq.l #1,D0             // remove mask mouse interrupt routine
	move.b D0,MOUSE_FLAG(A0)
	movem.l (SP),D1-D2/A0-A3
	lea 24(SP),SP
#else
	subq.b #1,MOUSE_FLAG(A0) // remove mask mouse interrupt routine
	movem.l (SP)+,D1-D2/A0-A3
#endif
	rts

det_v_hide_c:

	tst.w _oldmouse
	bne.s .vhc
	bsr hide_c
.end_vhc:
	rts
.vhc:
	lea tab_vdi(PC),A0
	cmp.l A4,A0
	beq.s .end_vhc           // call from _GSX_ENTRY => impossible to use old mouse
	addq.l #4,SP             // pop return address
#ifdef COLDFIRE
	movem.l (SP),A0-A3
	lea 16(SP),SP
#else
	movem.l (SP)+,A0-A3
#endif
#ifdef XAAES_SEMAPHORE
	move.w (SP)+,D0
	beq.s .vhcx
#endif
	move.l save_stack,SP
#ifdef XAAES_SEMAPHORE
.vhcx:
	clr.b semaphore
#endif
	moveq #0x73,D0
	move.l _old_vector_vdi,-(SP)
	rts
	
hide_c:
	
#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D1-D2/A0-A3,(SP)
	move.l adr_var_vdi,A0
	moveq #0,D0
	move.b MOUSE_FLAG(A0),D0
	addq.l #1,D0             // mask mouse interrupt routine
	move.b D0,MOUSE_FLAG(A0)
	move.w M_HID_CT(A0),D0
	addq.l #1,D0
	move.w D0,M_HID_CT(A0)
             cmp.l #1,D0
#else
	movem.l D1-D2/A0-A3,-(SP)
	move.l adr_var_vdi,A0
	addq.b #1,MOUSE_FLAG(A0) // mask mouse interrupt routine
	addq.w #1,M_HID_CT(A0)
	cmp.w #1,M_HID_CT(A0)
#endif
	bhi.s .hic1              // cursor was hidden
	// remove the cursor from screen
/*--------
* Draw the mouse
* c_mouse_draw(Workstation *wk, long x, long y, Mouse *mouse)
* In:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move), 1 (hide), 2 (show), Mouse* (change)
* Call:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move shown), 1 (move hidden), 2 (hide), 3 (show), Mouse* (change)
* Out:	d0	mouse op to try again (low), pointer delay (high)
*-------*/
	move.l fvdi_virtual,A1
	move.l vwk_real_address(A1),A1
	move.l G_CURX(A0),wk_mouse_position(A1)
#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,wk_mouse_hide(A1)
#else
	move.w #1,wk_mouse_hide(A1)
#endif
	move.l wk_r_mouse(A1),D2
	beq.s .hic2              // no accel	
	move.l D2,A3
	moveq #2,D2              // hide
#ifdef COLDFIRE
	move.w G_CURX(A0),D0
	move.w G_CURY(A0),D1
#else
	movem.w G_CURX(A0),D0-D1
#endif
	swap D0
	move.w mouse_op,D0
	swap D0
	jsr (A3)
	move.w D0,mouse_op       // what to try again
.hic2:
	move.l adr_var_vdi,A0
	bclr #0,CUR_FLAG(A0)     // VBL redraw disabled
.hic1:
#ifdef COLDFIRE
	move.b MOUSE_FLAG(A0),D0
	subq.l #1,D0             // remove mask mouse interrupt routine
	move.b D0,MOUSE_FLAG(A0)
	movem.l (SP),D1-D2/A0-A3
	lea 24(SP),SP
#else
	subq.b #1,MOUSE_FLAG(A0) // remove mask mouse interrupt routine
	movem.l (SP)+,D1-D2/A0-A3
#endif
	rts

det_vq_mouse:

	moveq #1,D0
	move.w D0,4(A3)          // nb points PTSOUT
	move.w D0,8(A3)          // length tab INTOUT
	move.l 12(A1),A2         // INTOUT
#ifdef COLDFIRE
	move.w SR,D0
	move.w D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	move.w MOUSE_BT(A0),(A2)
	move.l 16(A1),A2         // PTSOUT
	move.l G_CURX(A0),(A2)
	move.w (SP)+,D0
	move.w D0,SR
#else /* !COLDFIRE */
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
	move.w MOUSE_BT(A0),(A2)
	move.l 16(A1),A2         // PTSOUT
	move.l G_CURX(A0),(A2)
	move.w (SP)+,SR
#endif /* COLDFIRE */
	rts

_mousexy:

	move.l adr_var_vdi,D0
	beq.s .mxy1
	move.l D0,A0
	move.l G_CURX(A0),D0
	rts
.mxy1:
	move.l fvdi_virtual,D0
	beq.s .mxy2
#ifdef COLDFIRE
	lea -16(SP),SP
	movem.l D1-D2/A1-A2,(SP)
	dc.w 0xA920              // 0xA000 used on Coldfire for MAC instruction
	movem.l (SP),D1-D2/A1-A2
	lea 16(SP),SP
#else
	movem.l D1-D2/A1-A2,-(SP)
	dc.w 0xA000
	movem.l (SP)+,D1-D2/A1-A2
#endif
	move.l G_CURX(A0),D0
.mxy2:
	rts

det_vex_butv:

	lea USER_BUT(A0),A0
	bra.s change_vex
 
det_vex_motv:

	lea USER_MOT(A0),A0
	bra.s change_vex

det_vex_curv:

	lea USER_CUR(A0),A0
	bra.s change_vex
	
det_vex_wheelv:

	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A0
	lea wk_vector_wheel(A0),A0
	
change_vex:

#ifdef COLDFIRE
	move.w SR,D0
	move.w D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	move.l (A0),18(A3)
	move.l 14(A3),(A0)
	move.w (SP)+,D0
	move.w D0,SR
#else /* !COLDFIRE */
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
	move.l (A0),18(A3)
	move.l 14(A3),(A0)
	move.w (SP)+,SR
#endif /* COLDFIRE */
	rts
 
det_vq_key_s:

#ifdef COLDFIRE
	moveq #1,D0
	move.w D0,8(A3)          // length tab INTOUT
	move.l _sysbase,A0       // header ROM
	move.l 0x24(A0),A0       // kbshift
	move.b (A0),D0
	and.l #0xF,D0
#else /* !COLDFIRE */
	move.w #1,8(A3)          // length tab INTOUT
	move.l _sysbase,A0       // header ROM
	move.l 0x24(A0),A0       // kbshift
	move.b (A0),D0
	and.w #0xF,D0
#endif /* COLDFIRE */
	move.l 12(A1),A0         // INTOUT
	move.w D0,(A0)
	rts
 
det_vs_clip:

	move.l 4(A1),A3          // INTIN
	move.w (A3),D0           // flag clip
	move.l fvdi_virtual,A3
	move.w D0,_CLIP(A0)
	move.w D0,CLIP(A2)       // clipping
	move.w D0,vwk_clip_on(A3)
#ifdef COLDFIRE
	beq .vsc3                // not actived
	lea -16(SP),SP
	movem.l D1-D4,(SP)
	move.l 8(A1),A1          // PTSIN
	move.w (A1),D0
	move.w 2(A1),D1
	move.w 4(A1),D2
	move.w 6(A1),D3
	ext.l D0
	ext.l D1
	ext.l D2
	ext.l D3
	cmp.l D0,D2
	bge.s .vsc1              // X2 >= X1
	move.l D0,D4
	move.l D2,D0
	move.l D4,D2
.vsc1:
	cmp.l D1,D3
	bge.s .vsc2              // Y2 >= Y1
	move.l D1,D4
	move.l D3,D1
	move.l D4,D3
#else
	beq.s .vsc3              // not actived
	movem.l D1-D3,-(SP)
	move.l 8(A1),A1          // PTSIN
	movem.w (A1),D0-D3
	cmp.w D0,D2
	bge.s .vsc1              // X2 >= X1
	exg D0,D2
.vsc1:
	cmp.w D1,D3
	bge.s .vsc2              // Y2 >= Y1
	exg D1,D3
#endif
.vsc2:
	tst.w D0                 // X1
	bpl.s .vsc5
	moveq #0,D0
.vsc5:
	tst.w D1                 // Y1
	bpl.s .vsc6
	moveq #0,D1
.vsc6:
	tst.w D2                 // X2
	bpl.s .vsc9
	moveq #0,D2
.vsc9:
	tst.w D3                 // Y2
	bpl.s .vsc10
	moveq #0,D3
.vsc10:
#ifdef COLDFIRE
	move.w DEV_TAB(A0),D4
	ext.l D4 
	cmp.l D4,D2              // width screen -1
	ble.s .vsc7              // X2 < width screen
	move.l D4,D2             // width screen -1
.vsc7:
	move.w DEV_TAB+2(A0),D4
	ext.l D4
	cmp.l D4,D3              // height screen -1
	ble.s .vsc8              // Y2 < height screen
	move.l D4,D3             // height screen -1
.vsc8:
	move.w D0,_XMN_CLIP(A0)
	move.w D1,_XMN_CLIP+2(A0)
	move.w D2,_XMN_CLIP+4(A0)
	move.w D3,_XMN_CLIP+6(A0)
#else
	cmp.w DEV_TAB(A0),D2     // width screen -1
	ble.s .vsc7              // X2 < width screen
	move.w DEV_TAB(A0),D2    // width screen -1
.vsc7:
	cmp.w DEV_TAB+2(A0),D3   // height screen -1
	ble.s .vsc8              // Y2 < height screen
	move.w DEV_TAB+2(A0),D3  // height screen -1
.vsc8:
	movem.w D0-D3,_XMN_CLIP(A0)
#endif /* COLDFIRE */
	move.w D0,XMN_CLIP(A2)   // clipping X1,X2,Y1,Y2
	move.w D2,XMN_CLIP+2(A2) 
	move.w D1,XMN_CLIP+4(A2)
	move.w D3,XMN_CLIP+6(A2)
	move.w D0,vwk_clip_rectangle_x1(A3)
	move.w D2,vwk_clip_rectangle_x2(A3)	
	move.w D1,vwk_clip_rectangle_y1(A3)
	move.w D3,vwk_clip_rectangle_y2(A3)	
#ifdef COLDFIRE
	movem.l (SP),D1-D4
	lea 16(SP),SP
#else
	movem.l (SP)+,D1-D3
#endif
	bra.s .vsc4
.vsc3:                                // clipping not actived
	lea _XMN_CLIP(A0),A1
	clr.l (A1)+
	move.l DEV_TAB(A0),(A1)  // width and height screen -1
	lea XMN_CLIP(A2),A1      // clipping coords X1,X2,Y1,Y2
	moveq #0,D0              // = screen coords
	move.w D0,vwk_clip_rectangle_y1(A3)
	move.w D0,vwk_clip_rectangle_x1(A3)
	move.w DEV_TAB(A0),D0    // width screen -1
	move.l D0,(A1)+
	move.w D0,vwk_clip_rectangle_x2(A3)	
	move.w DEV_TAB+2(A0),D0  // height screen -1
	move.l D0,(A1)
	move.w D0,vwk_clip_rectangle_y2(A3)	
.vsc4:
	rts

det_vqt_name:

#ifdef COLDFIRE
	move.l D1,-(SP)
	move.l D2,-(SP)
	move.l D3,-(SP)
	moveq #33,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	movem.l D1-D3,-(SP)
	move.w #33,8(A3)         // length tab INTOUT
#endif
	move.l 4(A1),A3          // INTIN
	moveq #0,D3
	move.w (A3),D3           // element
  	lea FONT_RING(A0),A2     // chain ptr
	moveq #-1,D1             // font_id
	moveq #0,D2              // count
.vqn4:
		move.l (A2)+,A3 // tmp font
		tst.l A3
		beq.s .vqn6
.vqn2:
#ifdef COLDFIRE
			move.w FACE_ID(A3),D0
			ext.l D0
			cmp.l D0,D1  // font_id
			beq.s .vqn3
			move.l D0,D1
			addq.l #1,D2 // count
			cmp.l D3,D2  // element
#else
			cmp.w FACE_ID(A3),D1  // font_id
			beq.s .vqn3
			move.l FACE_ID(A3),D1
			addq.w #1,D2 // count
			cmp.w D3,D2  // element
#endif
			beq.s .vqn5  // found element
.vqn3:
			move.l NEXT_FONT(A3),A3
		tst.l A3
		bne.s .vqn2
	bra.s .vqn4
.vqn6:
	// The element is out of bounds use the system font
	move.l sysfonts,A3
	move.l (A3),A3           // temp font = fon6x6
.vqn5:
	move.l 12(A1),A0         // INTOUT
	move.w FACE_ID(A3),(A0)+
	lea FONT_NAME(A3),A1
	moveq #0,D0
	moveq #31,D1             // copy name
.vqn7:
		move.b (A1)+,D0
		move.w D0,(A0)+
#ifdef COLDFIRE
		beq.s .vqn8
	subq.l #1,D1
	bpl.s .vqn7
	bra.s .vqn1
.vqn8:
		clr.w (A0)+
	subq.l #1,D1
	bpl.s .vqn8
.vqn1:
	move.l (SP)+,D3
	move.l (SP)+,D2
	move.l (SP)+,D1
#else /* !COLDFIRE */
	dbeq d1,.vqn7
	bne.s .vqn1
.vqn8:
		clr.w (A0)+
	dbf d1,.vqn8
.vqn1:
	movem.l (SP)+,D1-D3
#endif /* COLDFIRE */
	rts

det_vqt_fontinfo:

#ifdef COLDFIRE
	moveq #5,D0
	move.w D0,4(A3)          // nb points PTSOUT
	moveq #2,D0
	move.w D0,8(A3)          // length tab INTOUT
#else
	move.w #5,4(A3)          // nb points PTSOUT
	move.w #2,8(A3)          // length tab INTOUT
#endif
	move.l ADR_FONT(A2),A3
	move.w _STYLE(A0),D0
	move.l 12(A1),A0         // INTOUT
	move.l FIRST_ADE(A3),(A0) // ASCII code mini and maxi
	move.l 16(A1),A0         // PTSOUT
	move.w CELL_WIDTH(A3),(A0)+  // cell width
	move.w BOTTOM_LINE(A3),(A0)+ // bottom line distance
	clr.w (A0)+
	btst #0,D0               // bold char
	beq.s .vtf2
	move.w THICKENING(A3),-2(A0)
.vtf2:
	move.w TOP_LINE(A3),(A0)+ // descent line distance
	btst #8,D0               // italic char
	beq.s .vtf3
	move.w LEFT_OFFSET(A3),(A0)+ // left offset
	move.w HALF_LINE(A3),(A0)+   // half line distance
	move.w RIGTH_OFFSET(A3),(A0)+ // right offset
	bra.s .vtf1
.vtf3:
	clr.w (A0)+              // left offset
	move.w HALF_LINE(A3),(A0)+ // half line distance
	clr.w (A0)+              // right offset
.vtf1:
	move.w ASCENT_LINE(A3),(A0)+ // ascent line distance
	clr.w (A0)+
	move.w TOP_LINE(A3),(A0)+    // top line distance
	rts
	
find_default_font:

#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D0-D2/A0-A3,(SP)
	moveq #0,D2
#else
	movem.l D0-D1/A0-A3,-(SP)
#endif
	move.l adr_var_vdi,A0
	move.l CUR_WORK(A0),A2
	move.l ADR_FONT(A2),A3
	move.l FACE_ID(A3),D0    // font ID & size
	move.w #10,D0
#ifdef COLDFIRE
	moveq #0,D1
	move.w DEV_TAB+2(A0),D1
	cmp.l #350,D1            // height workstation info
	bhi.s .fdf5
	move.w #9,D0
#else
	cmp.w #350,DEV_TAB+2(A0) // height workstation info
	bhi.s .fdf5
	subq.w #1,D0
#endif
.fdf5:
	swap D0
	move.l fvdi_virtual,A0	
	move.l vwk_real_address(A0),A3
	move.l wk_writing_first_font(A3),A3
.fdf1:       // search ID
#ifdef COLDFIRE
		moveq #0,D1
		move.w FACE_ID(A3),D1
		move.w D0,D2
		cmp.l D1,D2
#else
		cmp.w FACE_ID(A3),D0
#endif
		beq.s .fdf2
		move.l NEXT_FONT(A3),A3
	move.l A3,D1
	bne.s .fdf1
	moveq #1,D0              // default
	move.l vwk_real_address(A0),A3
	move.l wk_writing_first_font(A3),A3
.fdf2:
	swap D0
	move.l font_extra_first_size(A3),A3
	move.l A3,ADR_FONT(A2)
.fdf3: // search size
#ifdef COLDFIRE
		moveq #0,D1
		move.w FONT_SIZE(A3),D1
		move.w D0,D2
		cmp.l D1,D2
#else
		cmp.w FONT_SIZE(A3),D0
#endif
		bcs.s .fdf4
		move.l A3,ADR_FONT(A2)
		move.l font_extra_next_size(A3),A3
	move.l A3,D1
	bne.s .fdf3
.fdf4:
	move.l ADR_FONT(A2),A3
	move.l adr_var_vdi,A0
	move.l A3,CUR_FONT(A0)
	bsr update_fvdi_fontinfo
#ifdef COLDFIRE
	movem.l (SP),D0-D2/A0-A3
	lea 28(SP),SP
#else
	movem.l (SP)+,D0-D1/A0-A3
#endif
	rts
	
clip_rect:  // D1:X1, D2:Y1, D3:X2, D4:Y2, return flag drawing if <> 0
            // and update D1-D4 for clipping

#ifdef COLDFIRE
	lea -12(SP),SP
	movem.l D5-D7,(SP)
	ext.l D1
	ext.l D2
	ext.l D3
	ext.l D4
	tst.w CLIP(A2)           // clipping
	beq.s .clr2              // clipping off
	move.w XMN_CLIP(A2),D0   // coords X1,X2,Y1,Y2 clipping
	move.w XMN_CLIP+2(A2),D5
	move.w XMN_CLIP+4(A2),D6
	move.w XMN_CLIP+6(A2),D7
	ext.l D0
	ext.l D6
	bra.s .clr4
.clr2:
	move.l A0,D0
	move.l adr_var_vdi,A0
	move.w DEV_TAB(A0),D5    // width and height screen -1
	move.w DEV_TAB+2(A0),D7
	move.l D0,A0
	moveq #0,D0
	moveq #0,D6	
.clr4:
	ext.l D5
	ext.l D7
	cmp.l D0,D1
	bge.s .clr3              // X1 inside clipping
	cmp.l D0,D3
	blt.s .clr5              // X2 out of clipping
	move.l D0,D1             // X1
.clr3:
	cmp.l D6,D2
	bge.s .clr6              // Y1 inside clipping
	cmp.l D6,D4
	blt.s .clr5              // Y2 out of clipping
	move.l D6,D2             // Y1
.clr6:
	cmp.l D5,D3
	ble.s .clr7              // X2 inside clipping
	cmp.l D5,D1
	bgt.s .clr5              // X1 out of clipping
	move.l D5,D3             // X2
.clr7:
	cmp.l D7,D4
	ble.s .clr8              // Y2 inside clipping
	cmp.l D7,D2
	bgt.s .clr5              // Y1 out of clipping
	move.l D7,D4             // Y2
.clr8:
	moveq #1,D0              // drawing with new coords
	bra.s .clr1
.clr5:
	moveq #0,D0
.clr1:
	movem.l (SP),D5-D7
	lea 12(SP),SP
#else
	movem.l D5-D7,-(SP)
	tst.w CLIP(A2)           // clipping
	beq.s .clr2              // clipping off
	movem.w XMN_CLIP(A2),D0/D5-D7 // coords X1,X2,Y1,Y2 clipping
	bra.s .clr4
.clr2:
	move.l A0,D0
	move.l adr_var_vdi,A0
	movem.w DEV_TAB(A0),D5/D7 // width and height screen -1
	move.l D0,A0
	moveq #0,D0
	moveq #0,D6	
.clr4:
	cmp.w D0,D1
	bge.s .clr3              // X1 inside clipping
	cmp.w D0,D3
	blt.s .clr5              // X2 out of clipping
	move.w D0,D1             // X1
.clr3:
	cmp.w D6,D2
	bge.s .clr6              // Y1 inside clipping
	cmp.w D6,D4
	blt.s .clr5              // Y2 out of clipping
	move.w D6,D2             // Y1
.clr6:
	cmp.w D5,D3
	ble.s .clr7              // X2 inside clipping
	cmp.w D5,D1
	bgt.s .clr5              // X1 out of clipping
	move.w D5,D3             // X2
.clr7:
	cmp.w D7,D4
	ble.s .clr8              // Y2 inside clipping
	cmp.w D7,D2
	bgt.s .clr5              // Y1 out of clipping
	move.w D7,D4             // Y2
.clr8:
	cmp.l D1,D3
	blt.s .clr5
	cmp.l D2,D4
	blt.s .clr5
	moveq #1,D0              // drawing with new coords
	bra.s .clr1
.clr5:
	moveq #0,D0
.clr1:
	ext.l D1
	ext.l D2
	ext.l D3
	ext.l D4
	tst.l D0
	movem.l (SP)+,D5-D7
#endif
	rts
	
#if 0 // old code
coords_raster:
// input: A1: PB VDI, A2: CUR_WORK, A3: CONTRL
// return source coords inside D0-D3 & target inside D4-D7
// if D0.L < 0 => nothing to do
// if 2 rasters are differents, source is used

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l A0-A5,(SP)
	clr.l -(SP)
	moveq #0,D5              // flag clipping
	move.l 18(A3),A0         // target MFDB
	move.l (A0),D0           // target address
	move.l 8(A1),A0          // PTSIN
	beq.s .cr15              // target = screen
	cmp.l _v_bas_ad,D0
	bne.s .cr17              // target <> screen
.cr15:
	moveq #-1,D5
	move.w CLIP(A2),2(SP)    // clipping
.cr17:
	move.l D5,A5
	move.w 8(A0),D4          // target coords
	move.w 10(A0),D5
	move.w 12(A0),D6
	move.w 14(A0),D7
	ext.l D4
	ext.l D5
	ext.l D6
	ext.l D7
	cmp.l D4,D6
	bge.s .cr14              // X2 target >= X1 target
	move.l D4,D0
	move.l D6,D4
	move.l D0,D6             // X1,X2 target
.cr14:
	cmp.l D5,D7
	bge.s .cr9               // Y2 target >= Y1 target
	move.l D5,D0
	move.l D7,D5
	move.l D0,D7             // Y1,Y2 target
.cr9:
	move.w 4(A0),D0          // X2 source (fix target coords if error)
	move.w (A0),D1           // X1 source
	ext.l D0
	ext.l D1
	sub.l D1,D0
	bge.s .cr21
	neg.l D0
.cr21:
	move.l D4,D6             // X1 target
	add.l D0,D6              // X2 target = width source + X1 target
	move.w 6(A0),D0          // Y2 source
	move.w 2(A0),D1          // Y1 source
	ext.l D0
	ext.l D1
	sub.l D1,D0
	bge.s .cr18
	neg.l D0
.cr18:
	move.l D5,D7             // Y1 target
	add.l D0,D7              // Y2 target = heigth source + Y1 target
	tst.l (SP)
	beq.s .cr5               // no clipping
	move.w XMN_CLIP(A2),D0   // X1,X2,Y1,Y2 clipping coords
	move.w XMN_CLIP+2(A2),D1
	move.w XMN_CLIP+4(A2),D2
	move.w XMN_CLIP+6(A2),D3	
	ext.l D0
	ext.l D1
	ext.l D2
	ext.l D3
	move.l D4,A1             // save X1 target
	move.l D5,A2             // save Y1 target
	move.l D6,A3             // save X2 target
	move.l D7,A4             // save Y2 target
	cmp.l D0,D4
	bge.s .cr8               // X1 inside clipping
	cmp.l D0,D6
	blt .cr4                 // X2 outside clipping
	move.l D0,D4             // X1 target
.cr8:
	cmp.l D2,D5
	bge.s .cr7               // Y1 inside clipping
	cmp.l D2,D7
	blt .cr4                 // Y2 outside clipping
	move.l D2,D5             // Y1 target
.cr7:
	cmp.l D1,D6
	ble.s .cr6               // X2 inside clipping
	cmp.l D1,D4
	bgt .cr4                 // X1 outside clipping
	move.l D1,D6             // Y1 cible
.cr6:
	cmp.l D3,D7
	ble.s .cr5               // Y2 inside clipping
	cmp.l D3,D5
	bgt .cr4                 // Y1 outside clipping
	move.l D3,D7             // Y2 target
.cr5:
	move.w (A0),D0           // source coords
	move.w 2(A0),D1
	move.w 4(A0),D2
	move.w 6(A0),D3
	ext.l D0
	ext.l D1
	ext.l D2
	ext.l D3
	cmp.l D0,D2
	bge.s .cr2               // X2 source >= X1 source
	move.l D0,-(SP)
	move.l D2,D0
	move.l (SP)+,D2          // X1,X2 source
.cr2:
	cmp.l D1,D3
	bge.s .cr3               // Y2 source >= Y1 source
	move.l D1,-(SP)
	move.l D3,D1
	move.l (SP)+,D3          // Y1,Y2 source
.cr3:
	tst.l (SP)
	beq.s .cr19              // no clipping
	sub.l D4,A1
	sub.l A1,D0              // X1 source fixed after target clipping
	sub.l D5,A2
	sub.l A2,D1              // Y1 source
	sub.l D6,A3
	sub.l A3,D2              // X2 source
	sub.l D7,A4
	sub.l A4,D3              // Y2 source
.cr19:
	move.l D2,-(SP)
	cmp.l #0,A5
	bpl.s .cr16              // target <> screen
	move.l adr_var_vdi,A0
	moveq #0,D2
	move.w DEV_TAB(A0),D2
	cmp.l D2,D6              // width screen
	bcs.s .cr20
	move.l D2,D6             // X2 target
.cr20:
	move.w DEV_TAB+2(A0),D2
	cmp.l D2,D7              // height screen
	bcs.s .cr16
	move.l D2,D7             // Y2 target
.cr16:
	move.l (SP)+,D2
	tst.l D0                 // X1 source
	bpl.s .cr12
	clr.l D0                 // X1 source
.cr12:
	tst.l D1                 // Y1 source
	bpl.s .cr13
	clr.l D1                 // Y1 source
.cr13:
	tst.l D4                 // X1 target
	bpl.s .cr10
	clr.l D4                 // X1 target
.cr10:
	tst.l D5                 // Y1 source
	bpl.s .cr11
	clr.l D5                 // Y1 target
.cr11:
	and.l #0xffff,D0
	bra.s .cr1
.cr4:
	moveq #-1,D0             // nothing to do
.cr1:
	addq.l #4,SP
	movem.l (SP),A0-A5
	lea 24(SP),SP
#else
	movem.l A0-A5,-(SP)
	moveq #0,D5              // flag clipping
	move.l 18(A3),A0         // target MFDB
	move.l (A0),D0           // target address
	move.l 8(A1),A0          // PTSIN
	beq.s .cr15              // target = screen
	cmp.l _v_bas_ad,D0
	bne.s .cr17              // target <> screen
.cr15:
	moveq #-1,D5
	move.w CLIP(A2),D5       // clipping
.cr17:
	move.l D5,A5
	movem.w 8(A0),D4-D7      // target coords
	cmp.w D4,D6
	bge.s .cr14              // X2 target >= X1 target
	exg D4,D6                // X1,X2 target
.cr14:
	cmp.w D5,D7
	bge.s .cr9               // Y2 target >= Y1 target
	exg D5,D7                // Y1,Y2 target
.cr9:
	move.w 4(A0),D0          // X2 source (fix target coords if error)
	sub.w (A0),D0            // X1 source
	bge.s .cr21
	neg D0
.cr21:
	move.w D4,D6             // X1 target
	add.w D0,D6              // X2 target = width source + X1 target
	move.w 6(A0),D0          // Y2 source
	sub.w 2(A0),D0           // Y1 source
	bge.s .cr18
	neg.w D0
.cr18:
	move.w D5,D7             // Y1 target
	add.w D0,D7              // Y2 target = heigth source + Y1 target
	cmp.w #0,A5
	beq.s .cr5               // no clipping
	movem.w XMN_CLIP(A2),D0-D3 // X1,X2,Y1,Y2 clipping coords
	move.w D4,A1             // save X1 target
	move.w D5,A2             // save Y1 target
	move.w D6,A3             // save X2 target
	move.w D7,A4             // save Y2 target
	cmp.w D0,D4
	bge.s .cr8               // X1 inside clipping
	cmp.w D0,D6
	blt .cr4                 // X2 outside clipping
	move.w D0,D4             // X1 target
.cr8:
	cmp.w D2,D5
	bge.s .cr7               // Y1 inside clipping
	cmp.w D2,D7
	blt .cr4                 // Y2 outside clipping
	move.w D2,D5             // Y1 target
.cr7:
	cmp.w D1,D6
	ble.s .cr6               // X2 inside clipping
	cmp.w D1,D4
	bgt .cr4                 // X1 outside clipping
	move.w D1,D6             // Y1 cible
.cr6:
	cmp.w D3,D7
	ble.s .cr5               // Y2 inside clipping
	cmp.w D3,D5
	bgt.s .cr4               // Y1 outside clipping
	move.w D3,D7             // Y2 target
.cr5:
	movem.w (A0),D0-D3       // source coords
	cmp.w D0,D2
	bge.s .cr2               // X2 source >= X1 source
	exg D0,D2                // X1,X2 source
.cr2:
	cmp.w D1,D3
	bge.s .cr3               // Y2 source >= Y1 source
	exg D1,D3                // Y1,Y2 source
.cr3:
	cmp.w #0,A5
	beq.s .cr19              // no clipping
	sub.w D4,A1
	sub.w A1,D0              // X1 source fixed after target clipping
	sub.w D5,A2
	sub.w A2,D1              // Y1 source
	sub.w D6,A3
	sub.w A3,D2              // X2 source
	sub.w D7,A4
	sub.w A4,D3              // Y2 source
.cr19:
	cmp.l #0,A5
	bpl.s .cr16              // target <> screen
	move.l adr_var_vdi,A0
	cmp.w DEV_TAB(A0),D6     // width screen
	bcs.s .cr20
	move.w DEV_TAB(A0),D6    // X2 target
.cr20:
	cmp.w DEV_TAB+2(A0),D7   // height screen
	bcs.s .cr16
	move.w DEV_TAB+2(A0),D7  // Y2 target
.cr16:
	tst.w D0                 // X1 source
	bpl.s .cr12
	clr.w D0                 // X1 source
.cr12:
	tst.w D1                 // Y1 source
	bpl.s .cr13
	clr.w D1                 // Y1 source
.cr13:
	tst.w D4                 // X1 target
	bpl.s .cr10
	clr.w D4                 // X1 target
.cr10:
	tst.w D5                 // Y1 source
	bpl.s .cr11
	clr.w D5                 // Y1 target
.cr11:
	and.l #0xffff,D0
	bra.s .cr1
.cr4:
	moveq #-1,D0             // nothing to do
.cr1:
	movem.l (SP)+,A0-A5
#endif
	rts
	
coords_raster_vrt:
// input: A1: PB VDI, A2: CUR_WORK, A3: CONTRL
// return source coords inside D0-D3 & target inside D4-D7
// if D0.L < 0 => nothing to do
// if 2 rasters are differents, use adjusted target

#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l A0-A5,(SP)
	clr.l -(SP)
	moveq #0,D5              // flag clipping
	move.l 18(A3),A0         // target MFDB
	move.l (A0),D0           // target address
	move.l 8(A1),A0          // PTSIN
	beq.s .tcr15             // target = screen
	cmp.l _v_bas_ad,D0
	bne.s .tcr17             // target <> screen
.tcr15:
	moveq #-1,D5
	move.w CLIP(A2),2(SP)    // clipping
.tcr17:
	move.l D5,A5
	move.w 8(A0),D4          // target coords
	move.w 10(A0),D5
	move.w 12(A0),D6
	move.w 14(A0),D7
	ext.l D4
	ext.l D5
	ext.l D6
	ext.l D7
	cmp.l D4,D6
	bge.s .tcr14             // X2 target >= X1 target
	move.l D4,D0
	move.l D6,D4
	move.l D0,D6             // X1,X2 target
.tcr14:
	cmp.l D5,D7
	bge.s .tcr9              // Y2 target >= Y1 target
	move.l D5,D0
	move.l D7,D5
	move.l D0,D7             // Y1,Y2 target
.tcr9:
	tst.l (SP)
	beq.s .tcr5              // no clipping
	move.w XMN_CLIP(A2),D0   // X1,X2,Y1,Y2 clipping coords
	move.w XMN_CLIP+2(A2),D1
	move.w XMN_CLIP+4(A2),D2
	move.w XMN_CLIP+6(A2),D3
	ext.l D0
	ext.l D1
	ext.l D2
	ext.l D3
	move.l D4,A1             // save X1 target
	move.l D5,A2             // save Y1 target
	move.l D6,A3             // save X2 target
	move.l D7,A4             // save Y2 target
	cmp.l D0,D4
	bge.s .tcr8              // X1 inside clipping
	cmp.l D0,D6
	blt .tcr4                // X2 outside clipping
	move.l D0,D4             // X1 target
.tcr8:
	cmp.l D2,D5
	bge.s .tcr7              // Y1 inside clipping
	cmp.l D2,D7
	blt .tcr4                // Y2 outside clipping
	move.l D2,D5             // Y1 target
.tcr7:
	cmp.l D1,D6
	ble.s .tcr6              // X2 inside clipping
	cmp.l D1,D4
	bgt .tcr4                // X1 outside clipping
	move.l D1,D6             // Y1 cible
.tcr6:
	cmp.l D3,D7
	ble.s .tcr5              // Y2 inside clipping
	cmp.l D3,D5
	bgt .tcr4                // Y1 outside clipping
	move.l D3,D7             // Y2 target
.tcr5:
	move.w (A0),D0           // source coords
	move.w 2(A0),D1
	move.w 4(A0),D2
	move.w 6(A0),D3
	ext.l D0
	ext.l D1
	ext.l D2
	ext.l D3
	cmp.l D0,D2
	bge.s .tcr2              // X2 source >= X1 source
	move.l D0,-(SP)
	move.l D2,D0
	move.l (SP)+,D2          // X1,X2 source
.tcr2:
	cmp.l D1,D3
	bge.s .tcr3              // Y2 source >= Y1 source
	move.l D1,-(SP)
	move.l D3,D1
	move.l (SP)+,D3          // Y1,Y2 source
.tcr3:
	move.l D4,-(SP)
	move.w 12(A0),D4         // X2 target (fix source coords if error)
	move.w 8(A0),D3
	ext.l D4
	ext.l D3
	sub.l D3,D4              // X1 target with target coors without clipping
	bge .tcr21
	neg.l D4
.tcr21:
	move.l D0,D2             // X1 source
	add.l D4,D2              // X2 source
	move.w 14(A0),D4         // Y2 cible
	move.w 10(A0),D3
	ext.l D4
	ext.l D3
	sub.l D3,D4              // Y1 cible
	bge.s .tcr19
	neg.l D4
.tcr19:
	move.l D1,D3             // Y1 source
	add.l D4,D3              // Y2 source
	move.l (SP)+,D4
	tst.l (SP)
	beq.s .tcr18             // no clipping
	sub.l D4,A1
	sub.l A1,D0              // X1 source fixed after target clipping
	sub.l D5,A2
	sub.l A2,D1              // Y1 source
	sub.l D6,A3
	sub.l A3,D2              // X2 source
	sub.l D7,A4
	sub.l A4,D3              // Y2 source
.tcr18:
	move.l D2,-(SP)
	cmp.l #0,A5
	bpl .tcr16               // target <> screen
	move.l adr_var_vdi,A0
	moveq #0,D2
	move.w DEV_TAB(A0),D2
	cmp.l D2,D6              // width screen
	bcs.s .tcr20
	move.l D2,D6             // X2 target
.tcr20:
	move.w DEV_TAB+2(A0),D2
	cmp.l D2,D7              // height screen
	bcs.s .tcr16
	move.l D2,D7             // Y2 target
.tcr16:
	move.l (SP)+,D2
	tst.l D0                 // X1 source
	bpl.s .tcr12
	clr.l D0                 // X1 source
.tcr12:
	tst.l D1                 // Y1 source
	bpl.s .tcr13
	clr.l D1                 // Y1 source
.tcr13:
	tst.l D4                 // X1 target
	bpl.s .tcr10
	clr.l D4                 // X1 target
.tcr10:
	tst.l D5                 // Y1 source
	bpl.s .tcr11
	clr.l D5                 // Y1 target
.tcr11:
	and.l #0xffff,D0
	bra.s .tcr1
.tcr4:
	moveq #-1,D0             // nothing to do
.tcr1:
	addq.l #4,SP
	movem.l (SP),A0-A5
	lea 24(SP),SP
#else
	movem.l A0-A5,-(SP)
	moveq #0,D5              // flag clipping
	move.l 18(A3),A0         // target MFDB
	move.l (A0),D0           // target address
	move.l 8(A1),A0          // PTSIN
	beq.s .tcr15             // target = screen
	cmp.l _v_bas_ad,D0
	bne.s .tcr17             // target <> screen
.tcr15:
	moveq #-1,D5
	move.w CLIP(A2),D5       // clipping
.tcr17:
	move.l D5,A5
	movem.w 8(A0),D4-D7      // target coords
	cmp.w D4,D6
	bge.s .tcr14             // X2 target >= X1 target
	exg D4,D6                // X1,X2 target
.tcr14:
	cmp.w D5,D7
	bge.s .tcr9              // Y2 target >= Y1 target
	exg D5,D7                // Y1,Y2 target
.tcr9:
	cmp.w #0,A5
	beq.s .tcr5              // no clipping
	movem.w XMN_CLIP(A2),D0-D3 // X1,X2,Y1,Y2 clipping coords
	move.w D4,A1             // save X1 target
	move.w D5,A2             // save Y1 target
	move.w D6,A3             // save X2 target
	move.w D7,A4             // save Y2 target
	cmp.w D0,D4
	bge.s .tcr8              // X1 inside clipping
	cmp.w D0,D6
	blt .tcr4                // X2 outside clipping
	move.w D0,D4             // X1 target
.tcr8:
	cmp.w D2,D5
	bge.s .tcr7              // Y1 inside clipping
	cmp.w D2,D7
	blt .tcr4                // Y2 outside clipping
	move.w D2,D5             // Y1 target
.tcr7:
	cmp.w D1,D6
	ble.s .tcr6              // X2 inside clipping
	cmp.w D1,D4
	bgt .tcr4                // X1 outside clipping
	move.w D1,D6             // Y1 cible
.tcr6:
	cmp.w D3,D7
	ble.s .tcr5              // Y2 inside clipping
	cmp.w D3,D5
	bgt .tcr4                // Y1 outside clipping
	move.w D3,D7             // Y2 target
.tcr5:
	movem.w (A0),D0-D3       // source coords
	cmp.w D0,D2
	bge.s .tcr2              // X2 source >= X1 source
	exg D0,D2                // X1,X2 source
.tcr2:
	cmp.w D1,D3
	bge.s .tcr3              // Y2 source >= Y1 source
	exg D1,D3                // Y1,Y2 source
.tcr3:
	move.w D4,-(SP)
	move.w 12(A0),D4         // X2 target (fix source coords if error)
	sub.w 8(A0),D4           // X1 target with target coors without clipping
	bge .tcr21
	neg.w D4
.tcr21:
	move.w D0,D2             // X1 source
	add.w D4,D2              // X2 source
	move.w 14(A0),D4         // Y2 cible
	sub.w 10(A0),D4          // Y1 cible
	bge.s .tcr19
	neg.w D4
.tcr19:
	move.w D1,D3             // Y1 source
	add.w D4,D3              // Y2 source
	move.w (SP)+,D4
	cmp.w #0,A5
	beq.s .tcr18             // no clipping
	sub.w D4,A1
	sub.w A1,D0              // X1 source fixed after target clipping
	sub.w D5,A2
	sub.w A2,D1              // Y1 source
	sub.w D6,A3
	sub.w A3,D2              // X2 source
	sub.w D7,A4
	sub.w A4,D3              // Y2 source
.tcr18:
	cmp.l #0,A5
	bpl.s .tcr16             // target <> screen
	move.l adr_var_vdi,A0
	cmp.w DEV_TAB(A0),D6     // width screen
	bcs.s .tcr20
	move.w DEV_TAB(A0),D6    // X2 target
.tcr20:
	cmp.w DEV_TAB+2(A0),D7   // height screen
	bcs.s .tcr16
	move.w DEV_TAB+2(A0),D7  // Y2 target
.tcr16:
	tst.w D0                 // X1 source
	bpl.s .tcr12
	clr.w D0                 // X1 source
.tcr12:
	tst.w D1                 // Y1 source
	bpl.s .tcr13
	clr.w D1                 // Y1 source
.tcr13:
	tst.w D4                 // X1 target
	bpl.s .tcr10
	clr.w D4                 // X1 target
.tcr10:
	tst.w D5                 // Y1 source
	bpl.s .tcr11
	clr.w D5                 // Y1 target
.tcr11:
	and.l #0xffff,D0
	bra.s .tcr1
.tcr4:
	moveq #-1,D0             // nothing to do
.tcr1:
	movem.l (SP)+,A0-A5
#endif
	rts
#endif
	
get_pattern:

	move.l D1,-(SP)
	moveq #0,D0
	move.w FILL_INT_STYLE(A2),D0
	move.w D0,D1
	swap D0
#ifdef COLDFIRE
	ext.l D1
	cmp.l #4,D1              // user pattern
#else
	cmp.w #4,D1              // user pattern
#endif
	bne.s .gp1
	lea USER_DEF_FILL_PAT(A2),A0
	bra.s .gp5
.gp1:
#ifdef COLDFIRE
	cmp.l #3,D1              // pattern
#else
	cmp.w #3,D1              // pattern
#endif
	bne.s .gp2
	lea tab_pattern,A0
	bra.s .gp3
.gp2:
#ifdef COLDFIRE
	cmp.l #2,D1              // frames
#else
	cmp.w #2,D1              // frames
#endif
	bne.s .gp4
	lea tab_frames,A0
.gp3:
#ifdef COLDFIRE
	moveq #0,D0
	move.w FILL_STYLE_INDEX(A2),D0 // index fill pattern
	asl.l #5,D0              // *32
	add.l D0,A0
	moveq #0,D0
	move.w FILL_STYLE_INDEX(A2),D0
	addq.l #1,D0
	swap D0
	move.w FILL_INT_STYLE(A2),D0
	swap D0
#else
	move.w FILL_STYLE_INDEX(A2),D0 // index fill pattern
	asl.w #5,D0              // *32
	add.w D0,A0
	move.w FILL_STYLE_INDEX(A2),D0
	addq.w #1,D0
#endif
	bra.s .gp5
.gp4:
	lea tab_full_pattern,A0
.gp5:
	move.l (SP)+,D1
	rts

mov_cur:

	move.l A0,-(SP)
	move.l adr_var_vdi,A0
	tst.w M_HID_CT(A0)
	bne.s .mc1
	swap D0
	move.w D1,D0
#ifdef COLDFIRE
	move.w SR,D1
	move.w D1,-(SP)
	or.l #0x700,D1           // mask interrupts
	move.w D1,SR
	move.l D0,mouse_first
	bset #0,CUR_FLAG(A0)     // VBL redraw actived
	move.w (SP)+,D1
	move.w D1,SR
#else
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
	move.l D0,mouse_first
	bset #0,CUR_FLAG(A0)     // VBL redraw actived
	move.w (SP)+,SR
#endif
.mc1:
	move.l (SP)+,A0
	rts
	
vb_draw:	                         // VBL routine

#ifdef COLDFIRE
	move.l SP,save_stack2
	lea vbl_stack,SP
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
	move.w SR,D2
	move.w D2,-(SP)
	or.l #0x700,D2           // mask interrupts
	move.w D2,SR
#else
	move.l SP,save_stack2
	lea vbl_stack,SP
	movem.l D0-D2/A0-A2,-(SP)
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
#endif
	move.l adr_var_vdi,A0	
	bclr #0,CUR_FLAG(A0)     // VBL redraw actived
	beq .vd1
	move.l mouse_first,D0
	move.w D0,D1
	move.w mouse_op,D0
	swap D0
	move.l fvdi_virtual,A1
	move.l vwk_real_address(A1),A1
	move.l A1,D2
	beq .vd1                 // TO FIX else crach during change rez with mouse move 
	move.w D0,G_CURX(A0)
	move.w D1,G_CURY(A0)
	move.l G_CURX(A0),wk_mouse_position(A1)
#if 0
#ifdef COLDFIRE
	move.w (SP),D2
	move.w D2,SR
#else
	move.w (SP),SR
#endif
#endif
	tst.b MOUSE_FLAG(A0)
	bne.s .vd1               // mouse interrupt disabled
/*--------
* Draw the mouse
* c_mouse_draw(Workstation *wk, long x, long y, Mouse *mouse)
* In:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move), 1 (hide), 2 (show), Mouse* (change)
* Call:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move shown), 1 (move hidden), 2 (hide), 3 (show), Mouse* (change)
* Out:	d0	mouse op to try again (low), pointer delay (high)
*-------*/
	move.l wk_r_mouse(A1),D2
	beq.s .vd3               // no accel
	move.l D2,A2
	moveq #1,D2              // move hidden
	move.w M_HID_CT(A0),wk_mouse_hide(A1)
	bne.s .vd2               // don't display cursor form yet
	moveq #0,D2              // move showm
.vd2:
	jsr (A2)
.vd3:
	move.w D0,mouse_op
.vd1:
#ifdef COLDFIRE
	move.w (SP)+,D2
	move.w D2,SR
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
	move.l save_stack2,SP
#else
	move.w (SP)+,SR
	movem.l (SP)+,D0-D2/A0-A2
	move.l save_stack2,SP
#endif
	rts

_tick_int:

	subq.l  #4,SP            // leave some room on the stack
#ifdef COLDFIRE
	lea -60(SP),SP
	movem.l D0-A6,(SP)
#else
	movem.l D0-A6,-(SP)
#endif
	move.l adr_var_vdi,A1
	move.l USER_TIM(A1),A0   // Invoke user routine
	move.l NEXT_TIM(A1),A1
	move.l A1,60(SP)         // store chained routine
	jsr (A0)
#ifdef COLDFIRE
	movem.l (SP),D0-A6
	lea 60(SP),SP
#else
	movem.l (SP)+,D0-A6
#endif
	rts                      // jump to next routine in chain

init_var_vdi:

#ifdef COLDFIRE
	lea -44(SP),SP
	movem.l D0-A2,(SP)
#else
	movem.l D0-A2,-(SP)
#endif
#ifdef DEBUG
	lea debug6(PC),A0
	bsr display_string
#endif
	jsr _c_get_width_virtual
	move.l save_intout,A1
	move.w D0,(A1)           // width in pixels
#ifdef COLDFIRE
	lsr.l #1,D0
#else
	lsr.w #1,D0
#endif
	move.w D0,mouse_first
	jsr _c_get_height_virtual
	move.l save_intout,A1
	move.w D0,2(A1)          // height in pixels
#ifdef COLDFIRE
	lsr.l #1,D0
#else
	lsr.w #1,D0
#endif
	move.w D0,mouse_first+2
	jsr _c_get_bpp_virtual
	move.l adr_var_vdi,A0
	move.w D0,INQ_TAB+8(A0)  // planes
	move.l save_intout,A1
	moveq #0,D1
	bset D0,D1               // nb colors
	cmp.l #1,D1
	bls.s .ivv6              // 16M colors
	cmp.l #256,D1
	bcs.s .ivv5
.ivv6:
	move.w #256,D1
.ivv5:
	move.w D1,26(A1)         // nb colors
	move.w D1,DEV_TAB+26(A0)
	clr.w 78(A1)
	clr.w DEV_TAB+78(A0)
#ifdef PATCH_NVDI /* for font size ??? */
	move.w #265,D0
	move.w D0,DEV_TAB+6(A0)  // width point in mm/1000
	move.w D0,DEV_TAB+8(A0)  // heigth point in mm/1000
#else
	/* TODO ... the best is to get monitor specs */
#ifdef COLDFIRE
	move.l #744,D0
	moveq #0,D1
	move.w (A1),D1
	cmp.l #400,D1            // width in pixels
	bcs.s .ivv4
	lsr.l #1,D0
.ivv4:
	move.w D0,DEV_TAB+6(A0)  // width point in mm/1000
	move.l #744,D0
	move.w 2(A1),D1
	cmp.l #350,D1            // height in pixels
	bcs.s .ivv3
	lsr.l #1,D0
#else /* !COLDFIRE */
	move.w #744,D0
	cmp.w #400,(A1)          // width in pixels
	bcs.s .ivv4
	lsr.w #1,D0
.ivv4:
	move.w D0,DEV_TAB+6(A0)  // width point in mm/1000
	move.w #744,D0
	cmp.w #350,2(A1)         // height in pixels
	bcs.s .ivv3
	lsr.w #1,D0
#endif /* COLDFIRE */
.ivv3:
	move.w D0,DEV_TAB+8(A0)  // heigth point in mm/1000
#endif /* PATCH_NVDI */ 
	lea _colours,A1          // default colors fVDI
	lea REQ_COL48(A0),A2
	moveq #15,D0
.ivv2:
		move.l (A1)+,(A2)+ // red, green
		move.w (A1)+,(A2)+
#ifdef COLDFIRE
	subq.l #1,D0
	bpl.s .ivv2
	lea REQ_COL48E(A0),A2
	move.l #239,D0
.ivv1:
		move.l (A1)+,(A2)+ // red, green
		move.w (A1)+,(A2)+
	subq.l #1,D0
	bpl.s .ivv1	
	movem.l (SP),D0-A2
	lea 44(SP),SP
#else
	dbf D0,.ivv2
	lea REQ_COL48E(A0),A2
	move.w #239,D0
.ivv1:
		move.l (A1)+,(A2)+ // red, green
		move.w (A1)+,(A2)+
	dbf D0,.ivv1	
	movem.l (SP)+,D0-A2
#endif
	rts

mouse_init:

	tst.w _oldmouse
	bne user_init
#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
	move.l adr_var_vdi,A0	
	move.w SR,D2
	move.w D2,-(SP)
	or.l #0x700,D2           // mask interrupts
	move.w D2,SR
#else
	movem.l D0-D2/A0-A2,-(SP)
	move.l adr_var_vdi,A0	
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
#endif
	lea user_init(PC),A1
	move.l A1,USER_BUT(A0)   // button vector, default to no action (rts)
	move.l A1,USER_MOT(A0)   // motion vector, default to no action (rts)
	move.l fvdi_virtual,A2
	move.l vwk_real_address(A2),A2
	move.l A1,wk_vector_wheel(A2) // wheel vector, default to no action (rts)
	lea mov_cur(PC),A1       // mouse
	move.l A1,USER_CUR(A0)
	// initialize mouse/draw status and semaphores
	clr.w MOUSE_BT(A0)       // clear mouse button state
	clr.b CUR_MS_STAT(A0)    // clear current mouse status
	clr.b MOUSE_FLAG(A0)     // enable mouse interrupt routine
	moveq #1,D0
	move.w D0,M_HID_CT(A0)   // don't display cursor form yet
	// Initialize communication packet between mouse interrupt service routine
	// and vblank cursor display routine. Insert vblank draw routine into front
	// of vblank queue.
	moveq #0,D0
	move.w V_REZ_HZ(A0),D0   // horizontal rez
	lsr.l #1,D0              // x rez / 2
	move.w D0,G_CURX(A0)     // init mouse X position
	move.w D0,CUR_X(A0)      // initial position
	move.w V_REZ_VT(A0),D0   // vertical rez
	lsr.l #1,D0              // y rez / 2
	move.w D0,G_CURY(A0)     // init mouse Y position
	move.w D0,CUR_Y(A0)      // initial position
	moveq #1,D0
	move.b D0,CUR_FLAG(A0)   // mark data valid for update
	move.l _vblqueue,A0      // insert the display routine
	lea vb_draw(PC),A1
	move.l A1,(A0)           // at the head of the queue
#ifdef COLDFIRE
	move.w (SP)+,D2
	move.w D2,SR
#else
	move.w (SP)+,SR
#endif
	move.w #0x22,-(SP)       // Kdbvbase
	trap #14                 // XBIOS
	addq.l #2,SP
	move.l D0,A0
	lea 12(A0),A0
	lea det_statvec(PC),A1
	move.l (A0),old_statvec
	move.l A1,(A0)
	pea mouse_rel(PC)        // mouse packet interrupt handler
	pea rel_pblock(PC)       // mouse configuration parameter block
	move.w #1,-(SP)          // enable mouse, in relative mode
	clr.w -(SP)              // Initmous
	trap #14                 // XBIOS
	lea 12(SP),SP
#ifdef COLDFIRE
	move.l #0xCAFEFADE,D0
	move.l D0,ok_statvec
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else         
	move.l #0xCAFEFADE,ok_statvec
	movem.l (SP)+,D0-D2/A0-A2
#endif
user_init:
	rts
	
rel_pblock:
	dc.b 0                   // Y=0 at the top of the screen
	dc.b 0                   // Generate interrupts on make and break
	dc.b 1                   // Mouse X threshold
	dc.b 1                   // Mouse Y threshold

det_statvec:

	move.l D0,-(SP)
	move.l A0,-(SP)
	moveq #0,D0
	move.b (A0),D0
	cmp.l #5,D0              // Eiffel keys status frame
	bne.s .ds1
	move.l D1,-(SP)
	move.b 6(A0),D0          // scan-code
	cmp.l #0x59,D0           // UP
	bne.s .ds2
	moveq #1,D0              // wheel_number
	moveq #1,D1              // wheel_amount
	bra.s .ds5
.ds2:
	cmp.l #0x5A,D0           // DOWN
	bne.s .ds3
	moveq #1,D0              // wheel_number
	moveq #-1,D1             // wheel_amount
	bra.s .ds5
.ds3:
	cmp.l #0x5C,D0           // LEFT
	bne.s .ds4
	moveq #2,D0              // wheel_number
	moveq #1,D1              // wheel_amount
	bra.s .ds5
.ds4:
	cmp.l #0x5D,D0           // RIGHT
	bne.s .ds6
	moveq #2,D0              // wheel_number
	moveq #-1,D1             // wheel_amount
.ds5:
	move.l #0xCAFEFADE,A0
	cmp.l ok_statvec,A0
	bne.s .ds6
	move.l A1,-(SP)
	move.l fvdi_virtual,A1
	move.l vwk_real_address(A1),A1
	move.l wk_vector_wheel(A1),A1
	jsr (A1)
	move.l (SP)+,A1
.ds6:
	move.l (SP)+,D1
.ds1:
	move.l (SP)+,A0
	move.l (SP)+,D0
	move.l old_statvec,-(SP)
	rts

mouse_rel:

	move.l SP,save_stack3
	lea mouse_stack,SP
#ifdef COLDFIRE
	lea -60(SP),SP
	movem.l D0-A6,(SP)
#else
	movem.l D0-A6,-(SP)
#endif
	move.l adr_var_vdi,A2
	moveq #0,D0
	move.b (A0),D0           // get header from mouse buffer
	move.b D0,D1
	and.l #0xf8,D1           // mask out button bits
	cmp.l #0xf8,D1           // is header relative positioning
	bne ms_done              // no check just return
	and.l #3,D0              // IKBD <00>:rt btn  <01>:lf btn
	lsr.l #1,D0              // VDI <00>:lf btn <01>:rt btn
	bcc.s right_up
	bset #1,D0
right_up:
	move.b CUR_MS_STAT(A2),D1 // previous mouse state
	and.l #3,D1
	cmp.l D1,D0
	beq.s xy_update          // hasn't changed since last IRQ
	move.l A0,-(SP)
	move.l D1,-(SP)          // preserve previous mouse state
	move.l USER_BUT(A2),A1   // get user routine address
	jsr (A1)                 // call user
	move.l (SP)+,D1          // retrieve back previous state
	move.l (SP)+,A0
	move.l adr_var_vdi,A2
	move.w D0,MOUSE_BT(A2)   // save cur mouse button state
	ext.l D0
	eor.l D0,D1              // compute which buttons changed
	asl.l #6,D1              // d1<07:06> <-last ms btn state
	or.l D1,D0               // d0<07:06> <-delta btn state
	move.b D0,CUR_MS_STAT(A2) // store new button status byte
xy_update:
	moveq #0,D0
	moveq #0,D1
	move.b 1(A0),D0          // has mouse position changed ?
	move.b 2(A0),D1
	or.l D1,D0
	bne.s new_coord
	bclr #5,CUR_MS_STAT(A2)  // no motion: clear motion
	bra.s ms_done            // status flag and exit
new_coord:
	bset #5,CUR_MS_STAT(A2)  // motion:set motion status flag
	move.l G_CURX(A2),D0
	move.l D0,D1             // old mouse cursor Y
	swap D0
	move.b 1(A0),D3          // delta X from IKBD
	ext.w D3                 // sign extend delta X to word
	ext.l D3
	add.l D3,D0              // new mouse cursor X
	move.b 2(A0),D3          // delta Y from IKBD
	ext.w D3
	ext.l D3                 // sign extend delta Y to word
	add.l D3,D1              // new mouse cursor Y
	bsr scrn_clip            // clip X and Y to screen
	move.l USER_MOT(A2),A1
             jsr (A1)                 // call user motion routine
	move.l adr_var_vdi,A2
	bsr scrn_clip
	move.w D0,G_CURX(A2)     // save new X cursor position
	move.w D1,G_CURY(A2)     // save new Y cursor position
	move.l USER_CUR(A2),A1
	jsr (A1)                 // call user cur display routine
ms_done:
#ifdef COLDFIRE
	movem.l (SP),D0-A6
	lea 60(SP),SP
#else
	movem.l (SP)+,D0-A6
#endif
	move.l save_stack3,SP
	rts

scrn_clip:

	ext.l D0                 // is new_x < 0
	bge.s cl_xmax
	clr.l D0
	bra.s cl_y
cl_xmax:
	moveq #0,D2
	move.w V_REZ_HZ(A2),D2
	cmp.l D2,D0              // is new_x < max resolution
	blt.s cl_y
	move.l D2,D0             // clip to max x resolution
	subq.l #1,D0             // adjust for zero based
cl_y:
	ext.l D1                 // is new_y < 0
	bge.s cl_ymax
	clr.l D1
	rts
cl_ymax:
	move.w V_REZ_VT(A2),D2
	cmp.l D2,D1              // is new_y < max resolution
	blt.s cl_done
	move.l D2,D1             // clip to max y resolution
	subq.l #1,D1	            // adjust for zero based
cl_done:
	rts
	
dinit_mouse:

	tst.w _oldmouse
	bne user_init
#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
	move.l adr_var_vdi,A0	
	move.w SR,D2
	move.w D2,-(SP)
	or.l #0x700,D2           // mask interrupts
	move.w D2,SR
	lea user_init(PC),A1
	move.l A1,USER_BUT(A0)   // button vector
	move.l A1,USER_MOT(A0)   // motion vector
	move.l A1,USER_CUR(A0)   // cursor vector
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A0
	move.l A1,wk_vector_wheel(A0) // wheel vector
	move.l _vblqueue,A0      // remove the display routine
	clr.l (A0)	
	move.w (SP)+,D2
	move.w D2,SR
#else
	movem.l D0-D2/A0-A2,-(SP)
	move.l adr_var_vdi,A0	
	move.w SR,-(SP)
	or.w #0x700,SR           // mask interrupts
	lea user_init(PC),A1
	move.l A1,USER_BUT(A0)   // button vector
	move.l A1,USER_MOT(A0)   // motion vector
	move.l A1,USER_CUR(A0)   // cursor vector
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A0
	move.l A1,wk_vector_wheel(A0) // wheel vector
	move.l _vblqueue,A0      // remove the display routine
	clr.l (A0)	
	move.w (SP)+,SR
#endif
	moveq #-1,D0
	move.l D0,-(SP)          // discontinue mouse processing
	move.l D0,-(SP)
	clr.w -(SP)              // disable mouse
	clr.w -(SP)              // Initmouse
	trap #14                 // XBIOS
	lea 12(SP),SP
	move.w #0x22,-(SP)       // Kdbvbase
	trap #14                 // XBIOS
	addq.l #2,SP
	move.l D0,A0
	lea 12(A0),A0
	lea det_statvec(PC),A1
	cmp.l (A0),A1
	bne.s .dm1
	move.l old_statvec,(A0)
.dm1:
	clr.l ok_statvec
#ifdef COLDFIRE
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
#else
	movem.l (SP)+,D0-D2/A0-A2
#endif
	rts
	
_init_var_linea:

#ifdef COLDFIRE
	lea -48(SP),SP
	movem.l D0-A3,(SP)
	jsr 0xE09512             // TOS404
#else
	movem.l D0-A3,-(SP)
	dc.w 0xA000
#endif
	tst.w _os_magic
	beq.s .not_os_magic_linea
	tst.l adr_var_vdi
	bne.s .os_magic_linea
.not_os_magic_linea:
	move.l A0,adr_var_vdi
	move.l A1,adr_linea_fonts
	move.l A2,adr_linea_atab
.os_magic_linea:
	move.l A1,-(SP)
	move.l 56(SP),D0         // video_found
	bmi.s .from_vopnwk       // no change
	bsr init_type_video      // from Vsetscreen
	tst.b use_videl
	bgt.s .from_vopnwk       // Videl driver (old VDI ESC)
	jsr _c_get_videoramaddress
	cmp.l #0x01000000,D0
	bcc.s .from_vopnwk
	clr.b direct_call
	moveq #-1,D0
	move.b D0,use_videl      // not really videl but emulation
.from_vopnwk:
	jsr _c_get_width_virtual
	move.l D0,D6
	jsr _c_get_height_virtual
	move.l D0,D7
	jsr _c_get_bpp_virtual
#ifdef DEBUG
	move.l D0,-(SP)
	lea debug5(PC),A0
	bsr display_string
	move.l D6,D0
	bsr hex_long
	moveq #0x20,D0
	bsr display_char
	moveq #0x30,D0
	bsr display_char
	moveq #0x78,D0
	bsr display_char
	move.l D7,D0
	bsr hex_long
	moveq #0x20,D0
	bsr display_char
	moveq #0x30,D0
	bsr display_char
	moveq #0x78,D0
	bsr display_char
	move.l (SP),D0
	bsr hex_long
	moveq #0x20,D0
	bsr display_char
	moveq #0x30,D0
	bsr display_char
	moveq #0x78,D0
	bsr display_char
	move.l _v_bas_ad,D0
	bsr hex_long		
	moveq #0x20,D0
	bsr display_char
	moveq #0x30,D0
	bsr display_char
	moveq #0x78,D0
	bsr display_char
	move.b direct_call,D0
	bsr hex_byte	
	move.b use_videl,D0
	bsr hex_byte	
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	move.l (SP)+,D0
#endif
	move.l adr_var_vdi,A0
	move.l (SP)+,A1
	move.w D0,V_PLANES(A0)   // nb planes
	move.w D0,INQ_TAB+8(A0)  // planes
#ifdef COLDFIRE
	lsr.l #3,D0
#else
	lsr.w #3,D0
#endif
	move.w D0,BYT_PER_PIX(A0)
#ifdef PATCH_NVDI /* for font size ??? */
	move.l 4(A1),A2          // 8 * 8 font characters
#ifdef COLDFIRE
	cmp.l #350,D7            // height in pixels
#else
	cmp.w #350,D7            // height in pixels
#endif /* COLDFIRE */
	bcs.s .ivl2
	move.l 8(A1),A2          // 16 * 8 font characters
.ivl2:
	move.l A1,sysfonts
	move.w #265,D0
	move.w D0,DEV_TAB+6(A0)  // width point in mm/1000
	move.w D0,DEV_TAB+8(A0)  // heigth point in mm/1000
#else /* !PATCH_NVDI */
	/* TODO ... the best is to get monitor specs */
#ifdef COLDFIRE
	move.l #744,D0
	cmp.l #400,D6            // width in pixels
	bcs.s .ivl1
	lsr.l #1,D0
.ivl1:
	move.w D0,DEV_TAB+6(A0)  // width point in mm/1000
	move.l 4(A1),A2          // 8 * 8 font characters
	move.l #744,D0
	cmp.l #350,D7            // height in pixels
	bcs.s .ivl2
	lsr.l #1,D0
#else /* !COLDFIRE */ 
	move.w #744,D0
	cmp.w #400,D6
	bcs.s .ivl1
	lsr.w #1,D0
.ivl1:
	move.w D0,DEV_TAB+6(A0)  // width point in mm/1000
	move.l 4(A1),A2          // 8 * 8 font characters
	move.w #744,D0
	cmp.w #350,D7            // height in pixels
	bcs.s .ivl2
	lsr.w #1,D0
#endif /* COLDFIRE */
	move.l 8(A1),A2          // 16 * 8 font characters
.ivl2:
	move.l A1,sysfonts
	move.w D0,DEV_TAB+8(A0)  // heigth point in mm/1000
#endif /* PATCH_NVDI */
	move.l A2,CUR_FONT(A0)   // current font
	move.l A2,DEF_FONT(A0)   // default font
	move.w FORMHEIGHT(A2),V_CEL_HT(A0) // cell height
	move.w FORMWIDTH(A2),V_FNT_WD(A0)  // cell width
	move.w FIRST_ADE(A2),V_FNT_ST(A0)  // font start ADE
	move.w LAST_ADE(A2),V_FNT_ND(A0)   // font end ADE
	move.l FONTDAT(A2),V_FNT_AD(A0)    // character definitions
	move.l CHAR_OFF_TABLE(A2),V_OFF_AD(A0) // character offsets
	clr.w MOUSE_BT(A0)       // clear mouse button state
	clr.b CUR_MS_STAT(A0)    // clear current mouse status
	clr.b MOUSE_FLAG(A0)     // enable mouse interrupt routine
	moveq #1,D0
	move.w D0,M_HID_CT(A0)
	move.b D0,V_STAT_0(A0)   // flash, nowrap, normal video
	move.w D0,V_HID_CNT(A0)
	clr.b V_DELAY(A0)        // cursor redisplay interval (immediate)
	clr.w V_CUR_X(A0)        // cursor to column 0
	clr.w V_CUR_Y(A0)        // cursor to line 0
	clr.w V_CUR_OFF(A0)      // line offset is 0
	moveq #30,D0
	move.b D0,V_CUR_CT(A0)
	move.b D0,V_PERIOD(A0)   // cursor blink rate
#ifdef COLDFIRE
	move.l _v_bas_ad,D2
	move.l D2,V_CUR_AD(A0)   // set cursor to begin of the screen
	moveq #0,D2
	move.w D6,D2
	subq.l #1,D2
	move.w D2,DEV_TAB(A0)    // width workstation info
	move.w D7,D2
	subq.l #1,D2
	move.w D2,DEV_TAB+2(A0)  // height workstation info
	move.w D7,V_REZ_VT(A0)   // height screen VDI ESC
	move.l D7,D1
	.chip 68000
	divu V_CEL_HT(A0),D1     // height character VDI ESC
	.chip 5200
	ext.l D1
	subq.l #1,D1
	move.w D1,V_CEL_MY(A0)   // max line cursor VDI ESC
	move.w D6,V_REZ_HZ(A0)   // width VDI ESC
	move.l D6,D0
	lsr.l #3,D0
	move.l D0,D2
	subq.l #1,D2
	move.w D2,V_CEL_MX(A0)   // max column cursor VDI ESC
#else
	move.l _v_bas_ad,V_CUR_AD(A0) // set cursor to begin of the screen
	move.w D6,DEV_TAB(A0)
	subq.w #1,DEV_TAB(A0)    // width workstation info
	move.w D7,DEV_TAB+2(A0)
	subq.w #1,DEV_TAB+2(A0)  // height workstation info
	move.w D7,V_REZ_VT(A0)   // height screen VDI ESC
	move.l D7,D1
	divu V_CEL_HT(A0),D1     // height character VDI ESC
	subq.w #1,D1
	move.w D1,V_CEL_MY(A0)   // max line cursor VDI ESC
	move.w D6,V_REZ_HZ(A0)   // width VDI ESC
	move.w D6,D0
	lsr.w #3,D0              // / 8
	move.w D0,V_CEL_MX(A0)
	subq.w #1,V_CEL_MX(A0)   // max column cursor VDI ESC
#endif
	mulu V_PLANES(A0),D0     // planes line A
	move.w D0,V_LIN_WR(A0)   // bytes/line line A
	move.w D0,BYTES_LN(A0)   // bytes/line VDI ESC
	mulu V_CEL_HT(A0),D0     // height character VDI ESC
	move.w D0,V_CEL_WR(A0)   // bytes/line characters VDI ESC	
	moveq #0,D0
	move.w V_REZ_HZ(A0),D0   // horizontal rez
	lsr.l #1,D0              // x rez / 2
	move.w D0,G_CURX(A0)     // init mouse X position
	move.w V_REZ_VT(A0),D0   // vertical rez
	lsr.l #1,D0              // y rez / 2
	move.w D0,G_CURY(A0)     // init mouse Y position
	move.l _v_bas_ad,D0
	cmp.l #0x01000000,D0
	bcc.s .ivl13             // not Videl
	tst.b use_videl
	bgt .ivl9                // Videl driver (old VDI ESC)
.ivl13:
	moveq #-1,D0
	move.l D0,-(SP)          // init
	jsr _print_screen
	addq.l #4,SP
	lea normal_ascii(PC),A1
	move.l A1,con_state      // VDI escapes
	lea _bconout2(PC),A1
	move.l A1,bconout_2
	lea _bconout5(PC),A1
	move.l A1,bconout_5
	lea _bconstat2(PC),A1
	tst.l save_bconstat2
	bne.s .ivl11             // restart
	move.l bconstat_2,D0
	move.l D0,save_bconstat2
.ivl11:
	move.l A1,bconstat_2
	lea _bconin2(PC),A1
	tst.l save_bconin2
	bne.s .ivl10             // restart
	move.l bconin_2,D0
	move.l D0,save_bconin2
.ivl10:
	move.l A1,bconin_2
	clr.b flush_bconout
	move.l _vblqueue,A1      // insert the blink routine
	lea blink(PC),A2
	move.l A2,4(A1)          // as second entry in the queue
.ivl9:
	move.l adr_var_vdi,A0
	move.l A0,A3
	tst.w _os_magic
	beq.s .ivl12
	move.l _sysbase,A1
	move.l 0x18(A1),D0       // date
	swap D0
	cmp.l #0x20010000,D0     // MagiC 6.20
	bcs.s .ivl12
	lea var_vdi,A3
.ivl12:
	lea PAL_MAP(A3),A1       // Bconout colors
	moveq #0,D0
	moveq #15,D1
#ifdef COLDFIRE
	moveq #0,D2
	move.w V_PLANES(A0),D2   // nb planes
	cmp.l #16,D2
#else
	cmp.w #16,V_PLANES(A0)   // nb planes
#endif
	beq.s .ivl6              // 65K colors
	bhi.s .ivl4              // 16M colors
	moveq #0,D0              // 256 colors
	move.w D0,V_COL_BG(A0)   // background color
	move.l D0,VL_COL_BG(A0)
.ivl8:
		move.l D0,(A1)+
		addq.l #1,D0
#ifdef COLDFIRE
	subq.l #1,D1
	bpl.s .ivl8
#else
	dbf D1,.ivl8
#endif
	subq.l #1,D0
	move.w D0,V_COL_FG(A0)   // foreground color
	move.l D0,VL_COL_FG(A0)
	bra.s .ivl5

.ivl6:	// 65K colors
	lea tab_16_col_ntc,A2
	move.w (A2),D0
	move.w D0,V_COL_BG(A0)   // background color
	move.l D0,VL_COL_BG(A0)
.ivl3:
		move.w (A2)+,D0
		move.w D0,(A1)+
		move.w D0,(A1)+
#ifdef COLDFIRE
	subq.l #1,D1
	bpl.s .ivl3
#else
	dbf D1,.ivl3
#endif
	move.w -2(A2),D0
	move.w D0,V_COL_FG(A0)   // foreground color
	move.l D0,VL_COL_FG(A0)
	bra.s .ivl5
.ivl4:
	lea tab_16_col_tc,A2
	move.l (A2),VL_COL_BG(A0) // background color
.ivl7:
		move.l (A2)+,(A1)+
#ifdef COLDFIRE
	subq.l #1,D1
	bpl.s .ivl7
#else
	dbf D1,.ivl7
#endif
	move.l -4(A2),VL_COL_FG(A0) // foreground color
.ivl5:
#ifdef COLDFIRE
	movem.l (SP),D0-A3
	lea 48(SP),SP
#else
	movem.l (SP)+,D0-A3
#endif
	rts

_linea_fonts:

#ifdef COLDFIRE
	move.l D2,-(SP)
	move.l A2,-(SP)
	jsr 0xE09512             // TOS404
#else
	movem.l D2/A2,-(SP)
	dc.w 0xA000
#endif
	move.l A1,D0
#ifdef COLDFIRE
	move.l (SP)+,A2
	move.l (SP)+,D2
#else
	movem.l (SP)+,D2/A2
#endif
	rts
	
_flip_words: // used inside fvdi/font.c

	move.l 4(SP),A0
	move.l 8(SP),D0
	bra .loopend
.loop:
#ifdef COLDFIRE
		moveq #0,D0
		move.w (A0),D1
		move.l D1,D2
		lsr.l #8,D1
		lsl.l #8,D2
		or.l D2,D1
		move.w D1,(a0)+
.loopend:
	subq.l #1,D0
	bpl.s .loop
#else
		move.w (A0),D1
		rol.w #8,D1
		move.w D1,(a0)+
.loopend:
	dbf D0,.loop
#endif
	rts

_flip_longs: // used inside fvdi/font.c

	move.l 4(SP),A0
	move.l 8(SP),D0
	bra .loopend_l
.loop_l:
#ifdef COLDFIRE
		move.l (A0),D1
		move.l D1,D2
		lsr.l #8,D1
		and.l #0x00ff00ff,D1
		lsl.l #8,D2
		and.l #0xff00ff00,D2
		or.l D2,D1
		swap D1
		move.l D1,(A0)+
.loopend_l:
	subq.l #1,D0
	bpl.s .loop_l
#else
		move.l (A0),D1
		rol.w #8,D1
		swap D1
		rol.w #8,D1
		move.l D1,(A0)+
.loopend_l:
	dbf D0,.loop_l
#endif
	rts

_eddi_cookie:

	tst.w D0
	bne.s .ec1
	move.w #0x110,D0         // version 1.10
	rts
.ec1:
	moveq #-1,D0
	rts

init_var_fvdi:

#ifdef COLDFIRE
	lea -44(SP),SP
	movem.l D0-A2,(SP)
#else
	movem.l D0-A2,-(SP)
#endif
#ifdef DEBUG
	lea debug7(PC),A0
	bsr display_string
#endif
	move.l fvdi_virtual_default,A1
	move.l fvdi_virtual,A0
	moveq #(vwk_struct_size/2)-1,D0
.ivf1:
		move.w (A1)+,(A0)+
	subq.l #1,D0
	bpl.s .ivf1
	move.l adr_var_vdi,A0
	move.l CUR_WORK(A0),A2
	move.l fvdi_virtual,A0
	lea tab_index_col_vdi,A1
	moveq #0,D0
	move.w LINE_COLOR_INDEX(A2),D0
#ifdef TOS_TABLES
	move.w (A1,D0.l*2),D0
	move.l D0,vwk_line_colour(A0)
	move.w FILL_COLOR_INDEX(A2),D0
	move.w (A1,D0.l*2),D0
	move.l D0,vwk_fill_colour(A0)
	move.w MARK_COLOR_INDEX(A2),D0
	move.w (A1,D0.l*2),D0
	move.l D0,vwk_marker_colour(A0)
	move.w TEXT_COLOR_INDEX(A2),D0
	move.w (A1,D0.l*2),D0
#else
	move.b (A1,D0.l),D0
	move.l D0,vwk_line_colour(A0)
	move.w FILL_COLOR_INDEX(A2),D0
	move.b (A1,D0.l),D0
	move.l D0,vwk_fill_colour(A0)
	move.w MARK_COLOR_INDEX(A2),D0
	move.b (A1,D0.l),D0
	move.l D0,vwk_marker_colour(A0)
	move.w TEXT_COLOR_INDEX(A2),D0
	move.b (A1,D0.l),D0
#endif
	move.l D0,vwk_text_colour(A0)
	move.w LINE_TYPE(A2),D0
	addq.l #1,D0
	move.w D0,vwk_line_type(A0)
	move.w LINE_WIDTH(A2),vwk_line_width(A0)
	move.w BEGIN_STYLE(A2),vwk_line_ends_beginning(A0)
	move.w END_STYLE(A2),vwk_line_ends_end(A0)
	move.w FILL_STYLE_INDEX(A2),D0
	addq.l #1,D0
	move.w D0,vwk_fill_style(A0)	
	move.w FILL_INT_STYLE(A2),vwk_fill_interior(A0)
	move.w FILL_PER_VISIB(A2),vwk_fill_perimeter(A0)
	move.w MULTIFILL(A2),vwk_fill_user_multiplane(A0)
	move.w MARK_TYPE(A2),D0
	addq.l #1,D0
	move.w D0,vwk_marker_type(A0)
//	move.w MARK_HEIGHT(A2),D0
//	move.l D0,vwk_marker_size(A0)
	move.w CHUP(A2),vwk_text_rotation(A0)
	move.w HORIZONTAL_ALIGN(A2),vwk_text_alignment_horizontal(A0)
	move.w VERTICAL_ALIGN(A2),vwk_text_alignment_vertical(A0)
	move.w STYLE(A2),vwk_text_effects(A0)
	move.w WRT_MODE(A2),D0
	addq.l #1,D0
	move.w D0,vwk_mode(A0)
	move.w CLIP(A2),vwk_clip_on(A0)
	move.w XMN_CLIP(A2),vwk_clip_rectangle_x1(A0)
	move.w XMN_CLIP+2(A2),vwk_clip_rectangle_x2(A0)	
	move.w XMN_CLIP+4(A2),vwk_clip_rectangle_y1(A0)
	move.w XMN_CLIP+6(A2),vwk_clip_rectangle_y2(A0)
#ifdef COLDFIRE
	movem.l (SP),D0-A2
	lea 44(SP),SP
#else
	movem.l (SP)+,D0-A2
#endif
	rts
	
update_fvdi_fontinfo:

	move.l D2,-(SP)
	move.l fvdi_virtual,A0
	move.l ADR_FONT(A2),A3
	move.l A3,vwk_text_current_font(A0)
#ifdef COLDFIRE
	move.w CHARACTER_WIDTH(A3),vwk_text_character(A0) // character w/h in vwk
	move.w CELL_WIDTH(A3),vwk_text_cell(A0) // cell w/h in vwk
	move.w TOP_LINE(A3),D2
	move.w D2,vwk_text_character+2(A0) // character w/h in vwk
	ext.l D2
	addq.l #1,D2
	move.l D0,-(SP)
	move.w BOTTOM_LINE(A3),D0
	ext.l D0
	add.l D0,D2
	move.l (SP)+,D0
	move.w D2,vwk_text_cell+2(A0) // cell w/h in vwk
#else
	move.w CHARACTER_WIDTH(A3),D2
	swap D2
	move.w TOP_LINE(A3),D2
	move.l D2,vwk_text_character(A0) // character w/h in vwk
	swap D2
	move.w CELL_WIDTH(A3),D2
	swap D2
	addq.w #1,D2
	add.w BOTTOM_LINE(A3),D2
	move.l D2,vwk_text_cell(A0) // cell w/h in vwk
#endif
	move.l (SP)+,D2
	rts
	
/*--------	
* This routine finds the endpoints of a horizontaly contiguous
* section of solid color (used by the contourfill C routine)
* input:
*        4(SP) = fVDI struct
*        8(SP) = X start
*        12(SP) = Y start
*        16(SP) = ptr to endXleft
*        20(SP) = ptr to endXright
*        24(SP) = seed type
*        28(SP) = search color
* output:
*        endXleft = X of left endpoint of solid color
*        endXright = X of right endpoint of solid color
*        D0 = 0 => no endpoints or X start on edge
*             1 => endpoints found
*-------*/
_end_pts:

#ifdef COLDFIRE
	lea -44(SP),SP
	movem.l D2-D7/A2-A6,(SP)
#else
	movem.l D2-D7/A2-A6,-(SP)
#endif
	move.l adr_var_vdi,A6
	moveq #0,D0              // return value
	moveq #0,D1
	move.w V_PLANES(A6),D1
	cmp.l #8,D1
	blt .epp_ret0            // not implemented (TO FIX for monochrome emulation)
	move.w FORM_ID(A6),D1
	cmp.l #PIXPACKED,D1  
	bne .epp_ret0            // pixel packed only (TO FIX for monochrome emulation)
	move.l 52(SP),D4         // X coordinate start
	move.l 56(SP),D1         // Y coordinate start
	move.l 60(SP),A0         // ptr to endXleft
	move.l 64(SP),A1         // ptr to endXright
	move.w _YMN_CLIP(A6),D3  // y minimum position
	ext.l D3
	cmp.l D3,D1              // return if above viewport Ymin
	bmi .epp_ret0
	move.w _YMX_CLIP(A6),D2  // y maximum position
	ext.l D2
	cmp.l D2,D1
	bgt .epp_ret0            // return if below viewport Ymax
	move.w _XMN_CLIP(A6),D3  // x minimum position
	ext.l D3
	cmp.l D3,D4              // ret if left of viewport Xmin
	bmi .epp_ret0
	move.w _XMX_CLIP(A6),D2  // x maximum position
	ext.l D2
	cmp.l D2,D4
	bgt .epp_ret0            // ret if right of viewport Xmax
             move.w D3,(A0)           // init end X left
	move.w D2,(A1)           // init end X right
	mulu V_LIN_WR(A6),D1     // y portion of offset
	move.w D4,D2             // X coordinate
	mulu BYT_PER_PIX(A6),D2  // x portion of offset
	add.l D2,D1              // byte offs into mem frm
	move.l _v_bas_ad,A2      // base of screen
	add.l D1,A2              // (x,y) pixel in question
	moveq #0,D1
	move.w V_PLANES(A6),D1
	// TO FIX => must use pixelread
	cmp.l #16,D1             // see how many bits per pixel
	beq .check16Left         // do 16 bits per pixel case
	blt .check8Left          // do 8 bits per pixel case
	// 32 bit case
	move.l (A2),D1           // value of current pix
	move.l D4,D2	            // x position
	lea 4(A2),A3             // current X position adjusted for predecrement
.left32Loop:
		cmp.l -(A3),D1           // see if color matches
		beq.s .l32lSkip          // if so then skip
		addq.l #1,D2             // end X left
		move.w D2,(A0)           // store end Xleft
		bra.s .check32Right      // go right no
.l32lSkip:
		subq.l #1,D2             // move one pixel left
	cmp.l D2,D3              // see if we reached endpoint
	ble.s .left32Loop        // if not the loop back
.check32Right:
	move.l D4,D2             // x position
	move.w _XMX_CLIP(A6),D3  // maximum position
	ext.l D3
	move.l A2,A3             // current X position
.right32Loop:
		cmp.l (A3)+,D1           // see if color matches
		beq.s .r32lSkip          // if so then skip
		subq.l #1,D2             // end X right
		move.w D2,(A1)           // store end Xright
		bra .epp_ret1            // found end point and skip
.r32lSkip:
		addq.l #1,D2             // advance x position
	cmp.l D2,D3              // see if we reached end point
	bge.s .right32Loop       // if so then leave
	bra .epp_ret1            // done with search now leave
	// 16 bit case
.check16Left:
	moveq #0,D1
	move.w (A2),D1           // value of current pix
	move.l D4,D2             // x position
	lea 2(A2),A3             // current X position adjusted for predecrement
	moveq #0,D0
.left16Loop:
		move.w -(A3),D0
		cmp.l D0,D1              // see if color matches
		beq.s .l16lSkip          // if so then skip
		addq.l #1,D2             // end X left
		move.w D2,(A0)           // store end Xleft
		bra.s .check16Right      // go right no
.l16lSkip:
		subq.l #1,D2             // move one pixel left
	cmp.l D2,D3              // see if we reached endpoint
	ble.s .left16Loop        // if not the loop back
.check16Right:
	move.l D4,D2             // x position
	move.w _XMX_CLIP(A6),D3  // x maximum position
	ext.l D3
	move.l A2,A3             // current X position
.right16Loop:
		move.w (A3)+,D0
		cmp.l D0,D1              // see if color matches
		beq.s .r16lSkip          // if so then skip
		subq.l #1,D2	            // end X right
		move.w D2,(A1)           // store end Xright
		bra .epp_ret1            // found end point and skip
.r16lSkip:
		addq.l #1,D2	            // advance x position
	cmp.l D2,D3              // see if we reached end point
	bge.s .right16Loop       // if so then leave
	bra .epp_ret1            // done with search now leave
	// 8 bit case
.check8Left:
	moveq #0,D1              // clear upper bits of long var
	move.b (A2),D1           // value of current pix
	move.l D4,D2             // x position
	lea 1(A2),A3             // current X position adjusted for predecrement
	moveq #0,D0
.left8Loop:
		move.b -(A3),D0
		cmp.l D0,D1              // see if color matches
		beq.s .l8lSkip           // if so then skip
		addq.l #1,D2             // end X left
		move.w D2,(A0)           // store end Xleft
		bra.s .check8Right       // go right no
.l8lSkip:
		subq.l #1,D2             // move one pixel left
	cmp.l D2,D3              // see if we reached endpoint
	ble.s .left8Loop         // if not the loop back
.check8Right:
	move.l D4,D2             // x position
	move.w _XMX_CLIP(A6),D3  // x maximum position
	ext.l D3
	move.l A2,A3             // current X position
.right8Loop:
		move.b (A3)+,D0
		cmp.l D0,D1              // see if color matches
		beq.s .r8lSkip           // if so then skip
		subq.l #1,D2             // end X right
		move.w D2,(A1)           // store end Xright
		bra.s .epp_ret1          // found end point and skip
.r8lSkip:
		addq.l #1,D2             // advance x position
	cmp.l D2,D3              // see if we reached end point
	bge.s .right8Loop        // if so then leave
.epp_ret1:
	move.l 68(SP),D0         // seed type
	cmp.l 72(SP),D1          // search color
	beq.s .epp_ret0          // ret seg is of search color
	bchg #0,D0               // ret seg not of search color
.epp_ret0:
#ifdef COLDFIRE
	movem.l (SP),D2-D7/A2-A6
	lea 44(SP),SP
#else
	movem.l (SP)+,D2-D7/A2-A6
#endif
	rts

_get_color:

	move.l 4(SP),D0           // index
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A1
	move.l wk_r_get_colour(A1),A1 // index to real colour
	jsr (A1)
	rts
	
_pixelread:
	
#ifdef COLDFIRE
	move.l D2,-(SP)
	move.l A3,-(SP)
#else
	movem.l D2/A3,-(SP) 
#endif
	move.l 12(SP),D1         // X
	move.l 16(SP),D2         // Y
/*--------
* Get a coloured pixel
* c_read_pixel(Virtual *vwk, MFDB *mfdb, long x, long y)
* In:	a0	VDI struct, source MFDB
*	d1	x
*	d2	y
* Out:	d0	pixel colour
*-------*/
	move.l fvdi_virtual,A0
	move.l vwk_real_address(A0),A3
	move.l wk_r_get_pixel(A3),A3
	clr.l -(SP)
	pea (A0)
	move.l SP,A0
	jsr (A3)
	addq.l #8,SP
#ifdef COLDFIRE
	move.l (SP)+,A3
	move.l (SP)+,D2
#else
	movem.l (SP)+,D2/A3
#endif
	rts
	
/* fVDI subroutines calls, from Johan Klockars */

// fill_area(Virtual *vwk, long x1, long y1, long x2, long y2, long colour)
_fill_area:

#ifdef COLDFIRE
	lea -28(SP),SP
	movem.l D2-D7/A2,(SP)
#else
	movem.l D2-D7/A2,-(SP)
#endif
	move.l 32(SP),A0         // vwk
	movem.l 36(SP),D1-D4     // x1, y1, x2, y2
	bsr clip_rect
	blt.s .end_fill_area     // Empty rectangle?
	move.l vwk_real_address(A0),A2
	move.l wk_r_fill(A2),A1
	move.l 52(SP),D0         // colour
	move.l _pattern_ptrs,D5
	moveq #1,D6              // Replace mode
	move.l #0x00010000,D7    // Solid
	jsr (A1)
.end_fill_area:
#ifdef COLDFIRE
	movem.l (SP),D2-D7/A2
	lea 28(SP),SP
#else
	movem.l (SP)+,D2-D7/A2
#endif
	rts

// fill_poly(Virtual *vwk, short *pts, int n, int colour, short *pattern, short *points, long mode, long interior_style);
_fill_poly:

	move.l 12(SP),D1         // number of points
	ble .end_fill_poly
	move.l 4(SP),A0          // vwk
	moveq #0,D0
	move.w 32(SP),D0         // interior
	cmp.l #4,D0              // user pattern
	bne.s .not_user_pattern
	tst.w vwk_fill_user_multiplane(A0)
	bne.s .do_c_poly
.not_user_pattern:
	move.l vwk_real_address(A0),A1
	move.l wk_r_fillpoly(A1),D0
	beq.s .do_c_poly
#ifdef COLDFIRE
	lea -24(SP),SP
	movem.l D2-D7,(SP)
#else
	movem.l D2-D7,-(SP)
#endif
	tst.b direct_call
	beq.s .slower_fill_poly  // slower
	move.l D1,D2             // number of points
	move.l 6*4+8(SP),D1      // points address
	move.l D0,A1
	moveq #0,D3              // no index address
	moveq #0,D4              // no indices
	move.l 6*4+16(SP),D0     // colours
	move.l 6*4+20(SP),D5     // pattern address
	move.l 6*4+28(SP),D6     // mode
	move.l 6*4+32(SP),D7     // interior/style
	move.l D7,-(SP)
	move.l D6,-(SP)
	move.l D0,-(SP)
	move.l D5,-(SP)
	move.l D4,-(SP)
	move.l D3,-(SP)
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l A0,-(SP)
	jsr _c_fill_polygon
	lea 36(SP),SP
	bra.s .end_fill_poly2
.slower_fill_poly:
/*--------
* Fill a multiple bitplane polygon using a monochrome pattern
* c_fill_polygon(Virtual *vwk, short points[], long n, short index[], long moves, short *pattern, long colour, long mode, long interior_style)
* In:	a0	VDI struct
*	d0	colours
*	d1	points address
*	d2	number of points
*	d3	index address
*	d4	number of indices
*	d5	pattern address
*	d6	mode
*	d7	interior/style
*-------*/
	move.l D1,D2             // number of points
	move.l 6*4+8(SP),D1      // points address
	move.l D0,A1
	moveq #0,D3              // no index address
	moveq #0,D4              // no indices
	move.l 6*4+16(SP),D0     // colours
	move.l 6*4+20(SP),D5     // pattern address
	move.l 6*4+28(SP),D6     // mode
	move.l 6*4+32(SP),D7     // interior/style
	jsr (A1)
.end_fill_poly2:
#ifdef COLDFIRE
	movem.l (SP),D2-D7
	lea 24(SP),SP
#else
	movem.l (SP)+,D2-D7
#endif
.end_fill_poly:
	rts
.do_c_poly:
	jmp _filled_poly

// fill_spans(Virtual *vwk, short *spans, long n, long colour, short *pattern, long mode, long interior_style)
_fill_spans:

#ifdef COLDFIRE
	lea -44(SP),SP
	movem.l D2-D7/A2-A6,(SP)
#else
	movem.l D2-D7/A2-A6,-(SP)
#endif
	move.l 44+4+0(SP),A0     // vwk
	move.l 44+4+4(SP),D1     // spans
	move.l 44+4+8(SP),D2     // n
	move.l 44+4+12(SP),D0    // colour
	swap D2
	clr.w D2
	moveq #0,D3
	moveq #0,D4
	move.l 44+4+16(SP),D5    // pattern
	move.l 44+4+20(SP),D6    // mode
	move.l 44+4+24(SP),D7    // interior/style
/*--------
* Fill a multiple bitplane area using a monochrome pattern
* c_fill_area(Virtual *vwk, long x, long y, long w, long h, short *pattern, long colour, long mode, long interior_style)
* In:	a0	VDI struct (odd address marks table operation)
*	d0	colours
*	d1	x1 destination or table address
*	d2	y1    - " -    or table length (high) and type (0 - y/x1/x2 spans)
*	d3-d4	x2,y2 destination
*	d5	pattern address
*	d6	mode
*	d7	interior/style
*-------*/
	move.l vwk_real_address(A0),A2
	addq.l #1,A0             // table operation
	move.l wk_r_fill(A2),A2
	jsr (A2)
#ifdef COLDFIRE
	movem.l (SP),D2-D7/A2-A6
	lea 44(SP),SP
#else
	movem.l (SP)+,D2-D7/A2-A6
#endif
	rts

// c_pline(Virtual *vwk, long numpts, long colour, short *pts)
_c_pline:

#ifdef COLDFIRE
	lea -12(SP),SP
	movem.l D2-D3/A2,(SP)
	move.l 12+4(SP),A0       // vwk
	moveq #0,D0
	move.w vwk_line_width(A0),D0
	cmp.l #1,D0
#else
	movem.l D2-D3/A2,-(SP)
	move.l 12+4(SP),A0       // vwk
	cmp.w #1,vwk_line_width(A0)
#endif
	bhi .cpl2
	tst.w vwk_line_ends_beginning(A0)
	bne .cpl2
	tst.w vwk_line_ends_end(A0)
	bne .cpl2
	move.l 12+12(SP),D0      // colour	
	move.l 12+16(SP),D1      // pts
	move.l 12+8(SP),D2       // numpts	
	swap D2
	clr.w D2                 // type - coordinate pairs
	moveq #0,D3
#ifdef COLDFIRE
	lea -12(SP),SP
	movem.l D4-D6,(SP)
#else
	movem.l D4-D6,-(SP)
#endif
	moveq #0,D4
	move.l #0xffff,D5
	moveq #0,D6
	move.w vwk_mode(A0),D6
	tst.b direct_call
	beq.s .cpl4              // slower
	addq.l #1,A0             // table operation
	move.l D1,-(SP)
	move.l A0,-(SP)
	move.l D6,-(SP)
	move.l D0,-(SP)
	move.l D5,-(SP)
	move.l D4,-(SP)
	move.l D3,-(SP)
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l A0,-(SP)
	jsr _c_line_draw
	lea 32(SP),SP
	move.l (SP)+,A0
	move.l (SP)+,D1
	tst.l D0
	bne.s .cpl3
	move.l 12+12+12(SP),D0      // colour
	jsr _default_line
	bra.s .cpl3
.cpl4:
/*--------
* Draw a colored line between 2 points
* c_draw_line(Virtual *vwk, long x1, long y1, long x2, long y2, long pattern, long colour, long mode)
* In:	a0	VDI struct (odd address marks table operation)
*	d0	line colour
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	mode
*--------*/
	move.l vwk_real_address(A0),A2
	addq.l #1,A0             // table operation
	move.l wk_r_line(A2),A2
	jsr (A2)
.cpl3:
#ifdef COLDFIRE
	movem.l (SP),D4-D6
	lea 12(SP),SP
#else
	movem.l (SP)+,D4-D6
#endif
	bra .cpl1
.cpl2:
	clr.l -(SP)              // get a memory block of any size (hopefully large)
	jsr _allocate_block
	addq.l #4,SP
	tst.l D0
	beq.s .cpl1              // error
	move.l D0,-(SP)          // save for later
	move.l 12+4+4(SP),A0     // vwk
	move.l 12+4+8(SP),D1     // numpts	
	move.l 12+4+12(SP),D2    // colour	
	move.l 12+4+16(SP),A1    // pts
	moveq #0,D3
	move.w vwk_mode(A0),D3
	move.l D3,-(SP)          // mode
	move.l D0,-(SP)          // points
	move.l D2,-(SP)          // color
	move.l D1,-(SP)          // numpts
	move.l A1,-(SP)          // pts
	move.l A0,-(SP)          // vwk
// wide_line(Virtual *vwk, short *pts, long numpts, long colour, short *points, long mode)
	jsr _wide_line
	lea 24(SP),SP
	jsr _free_block
	addq.l #4,SP
.cpl1:
#ifdef COLDFIRE
	movem.l (SP),D2-D3/A2
	lea 12(SP),SP
#else
	movem.l (SP)+,D2-D3/A2
#endif
	rts
	
// void get_patternextent(Virtual *vwk, long length, short *text, short points[]);
_get_extent:

 	move.w 8(SP),D0          // length tab INTIN			; Number of characters
	move.l 10(SP),A0         // text INTIN
	move.l 14(SP),A1         // points PTSOUT	
	bsr vqt_extent
	rts
	
// void draw_text(Virtual *vwk, long x, long y, short *text, long length, long colour);
_draw_text:
#ifdef COLDFIRE
	move.l A2,-(SP)
	move.l A3,-(SP)
#else
	movem.l A2-A3,-(A7)
#endif
	lea 4+2*4(SP),A1
	move.l (A1),A0
	move.w 2+4(A1),D1
	swap D1
	move.w 2+8(A1),D1
	move.l 16(A1),D0
	move.l 12(A1),A1
	sub.l A2,A2              // no special offset table
/*--------
* Draw some text
* c_text_area(Virtual *vwk, short *text, long length, long dst_x, long dst_y, short *offsets)
* In:	a0	VDI struct
*	a1	string address
*	a2	offset table
*	d0	string length
*	d1	x1,y1 destination
*-------*/
	move.l vwk_real_address(A0),A3
	move.l wk_r_text(A3),A3
	jsr (A3)
#ifdef COLDFIRE
	move.l (SP)+,A3
	move.l (SP)+,A2
#else
	movem.l (SP)+,A2-A3
#endif
	rts

/* lib_vrt_cpyfm 
* In:   a1      Parameters (mode, points, source, destination, pens)
*       a0      VDI struct
*/	
lib_vrt_cpyfm:

#ifdef COLDFIRE
	lea -36(SP),SP
	movem.l D1-D7/A2-A3,(SP)
#else
	movem.l D1-D7/A2-A3,-(SP)
#endif
	moveq #0,D5              // not screen
	move.l 10(A1),D0         // target MFDB
	beq.s .lvrtc2            // target = screen
	move.l D0,A3
	move.l (A3),D0           // target address
	beq.s .lvrtc2            // target = screen
	cmp.l _v_bas_ad,D0
	bne.s .lvrtc3            // target <> screen
.lvrtc2:
	moveq #-1,D5             // screen
.lvrtc3:
	move.l 2(A1),A3          // coords
	move.w 8(A3),D1          // X1 target
	move.w 10(A3),D2         // Y1 target
	ext.l D1
	ext.l D2
	move.l D1,D3             // calcul X2,Y2 target from source
	move.l D2,D4
	move.w (A3),D7           // X1 source
	ext.l D7
	sub.l D7,D3
	move.w 4(A3),D0          // X2 source
	ext.l D0
	add.l D0,D3
	move.w 2(A3),D0          // Y1 source
	ext.l D0
	sub.l D0,D4
	move.w 6(A3),D0          // Y2 source
	ext.l D0
	add.l D0,D4
             tst.l D5
	beq.s .lvrtc4            // no clipping
	move.l adr_var_vdi,A2
	move.l CUR_WORK(A2),A2
	bsr clip_rect
	beq .lvrtc1              // nothing to do
.lvrtc4:
	move.l D4,D6             // Y2 target
	move.l D3,D5             // X2 target
	move.l D2,D4             // Y1 target
	move.l D1,D3             // X1 target
	move.w 8(A3),D0          // X1 target
	ext.l D0
	sub.l D0,D1
	add.l D7,D1              // X1 source fixed
	move.w 10(A3),D0         // Y1 target
	ext.l D0
	sub.l D0,D2
	move.w 2(A3),D0          // Y1 source
	ext.l D0
	add.l D0,D2              // Y1 source fixed
	moveq #0,D7
	move.w (A1),D7           // logic operation
	move.l 14(A1),A2
	move.l (A2),D0
	swap D0                  // colors
	tst.b direct_call
	beq.s .lvrtc5            // slower
	move.l D0,-(SP)          // colors
	move.l D7,-(SP)          // operation
	sub.l D4,D6
	addq.l #1,D6
	move.l D6,-(SP)          // H
	sub.l D3,D5
	addq.l #1,D5
	move.l D5,-(SP)          // W
	move.l D4,-(SP)          // Y target
	move.l D3,-(SP)          // X target
	move.l 10(A1),-(SP)      // target MFDB
	move.l D2,-(SP)          // Y source
	move.l D1,-(SP)          // X source
	move.l 6(A1),-(SP)       // source MFDB
	move.l fvdi_virtual,-(SP)
	jsr _c_expand_area
	lea 44(SP),SP
	bra.s .lvrtc1
.lvrtc5:
/*--------
* Expand a monochrome area to multiple bitplanes
* c_expand_area(Virtual *vwk, MFDB *src, long src_x, long src_y, MFDB *dst, long dst_x, long dst_y, long w, long h, long operation, long colour)
* In:	a0	VDI struct, destination MFDB, VDI struct, source MFDB
*	d0	colours
*	d1-d2	x1,y1 source
*	d3-d6	x1,y1 x2,y2 destination
*	d7	logic operation
*-------*/
	lea -16(SP),SP
	move.l A0,(SP)
	move.l 10(A1),4(SP)      // target MFDB
	move.l A0,8(SP)
 	move.l 6(A1),12(SP)      // source MFDB
	move.l vwk_real_address(A0),A2
	move.l wk_r_expand(A2),A2
 	move.l SP,A0
	jsr (A2)
	lea 16(SP),SP
.lvrtc1:
#ifdef COLDFIRE
	movem.l (SP),D1-D7/A2-A3
	lea 36(SP),SP
#else
	movem.l (SP)+,D1-D7/A2-A3
#endif
	moveq #1,D0
	rts
	
	.data

tab_16_col_ntc:
	dc.w 0xFFDF,0xF800,0x07C0,0xFFC0,0x001F,0xF81F,0x07DF,0xB596
	dc.w 0x8410,0xA000,0x0500,0xA500,0x0014,0xA014,0x0514,0x0000
tab_16_col_tc:
	dc.l 0xFFFFFF,0xFF0000,0x00FF00,0xFFFF00,0x0000FF,0xFF00FF,0x00FFFF,0xB0B0B0
	dc.l 0x808080,0x8F0000,0x008F00,0x8F8F00,0x00008F,0x8F008F,0x008F8F,0x000000

#ifndef TOS_TABLES
	
tab_index_col_pal: // index VDI color => index palette
	dc.b   0,255,  1,  2,  4,  6,  3,  5,  7,  8,  9, 10, 12, 14, 11, 13
	dc.b  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
	dc.b  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
	dc.b  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
	dc.b  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
	dc.b  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
	dc.b  96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111
	dc.b 112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
	dc.b 128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
	dc.b 144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
	dc.b 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
	dc.b 176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
	dc.b 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
	dc.b 208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
	dc.b 224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
	dc.b 240,241,242,243,244,245,246,247,248,249,250,251,252,253,254, 15

tab_index_col_vdi: // color index palette => index VDI
	dc.b   0,  2,  3,  6,  4,  7,  5,  8,  9, 10, 11, 14, 12, 15, 13,255
	dc.b  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
	dc.b  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
	dc.b  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
	dc.b  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
	dc.b  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
	dc.b  96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111
	dc.b 112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
	dc.b 128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
	dc.b 144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
	dc.b 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
	dc.b 176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
	dc.b 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
	dc.b 208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
	dc.b 224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
	dc.b 240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,  1

#endif

tab_empty_pattern:
	.rep 16
	dc.w 0
	.endr

tab_full_pattern:
_solid:
	.rep 16
	dc.w 0xFFFF
	.endr

tab_frames:
	dc.w 0x0000,0x4444,0x0000,0x1111,0x0000,0x4444,0x0000,0x1111
	dc.w 0x0000,0x4444,0x0000,0x1111,0x0000,0x4444,0x0000,0x1111
	dc.w 0x0000,0x5555,0x0000,0x5555,0x0000,0x5555,0x0000,0x5555
	dc.w 0x0000,0x5555,0x0000,0x5555,0x0000,0x5555,0x0000,0x5555
	dc.w 0x8888,0x5555,0x2222,0x5555,0x8888,0x5555,0x2222,0x5555
	dc.w 0x8888,0x5555,0x2222,0x5555,0x8888,0x5555,0x2222,0x5555
	dc.w 0xAAAA,0x5555,0xAAAA,0x5555,0xAAAA,0x5555,0xAAAA,0x5555
	dc.w 0xAAAA,0x5555,0xAAAA,0x5555,0xAAAA,0x5555,0xAAAA,0x5555
	dc.w 0xAAAA,0xDDDD,0xAAAA,0x7777,0xAAAA,0xDDDD,0xAAAA,0x7777
	dc.w 0xAAAA,0xDDDD,0xAAAA,0x7777,0xAAAA,0xDDDD,0xAAAA,0x7777
	dc.w 0xAAAA,0xFFFF,0xAAAA,0xFFFF,0xAAAA,0xFFFF,0xAAAA,0xFFFF
	dc.w 0xAAAA,0xFFFF,0xAAAA,0xFFFF,0xAAAA,0xFFFF,0xAAAA,0xFFFF
	dc.w 0xEEEE,0xFFFF,0xBBBB,0xFFFF,0xEEEE,0xFFFF,0xBBBB,0xFFFF
	dc.w 0xEEEE,0xFFFF,0xBBBB,0xFFFF,0xEEEE,0xFFFF,0xBBBB,0xFFFF
	dc.w 0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF
	dc.w 0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF
	dc.w 0xFFFF,0x8080,0x8080,0x8080,0xFFFF,0x0808,0x0808,0x0808
	dc.w 0xFFFF,0x8080,0x8080,0x8080,0xFFFF,0x0808,0x0808,0x0808
	dc.w 0x2020,0x4040,0x8080,0x4141,0x2222,0x1414,0x0808,0x1010
	dc.w 0x2020,0x4040,0x8080,0x4141,0x2222,0x1414,0x0808,0x1010
	dc.w 0x0000,0x0000,0x1010,0x2828,0x0000,0x0000,0x0101,0x8282
	dc.w 0x0000,0x0000,0x1010,0x2828,0x0000,0x0000,0x0101,0x8282
	dc.w 0x0202,0x0202,0xAAAA,0x5050,0x2020,0x2020,0xAAAA,0x0505
	dc.w 0x0202,0x0202,0xAAAA,0x5050,0x2020,0x2020,0xAAAA,0x0505
	dc.w 0x4040,0x8080,0x0000,0x0808,0x0404,0x0202,0x0000,0x2020
	dc.w 0x4040,0x8080,0x0000,0x0808,0x0404,0x0202,0x0000,0x2020
	dc.w 0x6606,0xC6C6,0xD8D8,0x1818,0x8181,0x8DB1,0x0C33,0x6000
	dc.w 0x6606,0xC6C6,0xD8D8,0x1818,0x8181,0x8DB1,0x0C33,0x6000
	dc.w 0x0000,0x0000,0x0400,0x0000,0x0010,0x0000,0x8000,0x0000
	dc.w 0x0000,0x0000,0x0400,0x0000,0x0010,0x0000,0x8000,0x0000
	dc.w 0xF8F8,0x6C6C,0xC6C6,0x8F8F,0x1F1F,0x3636,0x6363,0xF1F1
	dc.w 0xF8F8,0x6C6C,0xC6C6,0x8F8F,0x1F1F,0x3636,0x6363,0xF1F1
	dc.w 0xAAAA,0x0000,0x8888,0x1414,0x2222,0x4141,0x8888,0x0000
	dc.w 0xAAAA,0x0000,0x8888,0x1414,0x2222,0x4141,0x8888,0x0000
	dc.w 0x0808,0x0000,0xAAAA,0x0000,0x0808,0x0000,0x8888,0x0000
	dc.w 0x0808,0x0000,0xAAAA,0x0000,0x0808,0x0000,0x8888,0x0000
	dc.w 0x7777,0x9898,0xF8F8,0xF8F8,0x7777,0x8989,0x8F8F,0x8F8F
	dc.w 0x7777,0x9898,0xF8F8,0xF8F8,0x7777,0x8989,0x8F8F,0x8F8F
	dc.w 0x8080,0x8080,0x4141,0x3E3E,0x0808,0x0808,0x1414,0xE3E3
	dc.w 0x8080,0x8080,0x4141,0x3E3E,0x0808,0x0808,0x1414,0xE3E3
	dc.w 0x8181,0x4242,0x2424,0x1818,0x0606,0x0101,0x8080,0x8080
	dc.w 0x8181,0x4242,0x2424,0x1818,0x0606,0x0101,0x8080,0x8080
	dc.w 0xF0F0,0xF0F0,0xF0F0,0xF0F0,0x0F0F,0x0F0F,0x0F0F,0x0F0F
	dc.w 0xF0F0,0xF0F0,0xF0F0,0xF0F0,0x0F0F,0x0F0F,0x0F0F,0x0F0F
	dc.w 0x0808,0x1C1C,0x3E3E,0x7F7F,0xFFFF,0x7F7F,0x3E3E,0x1C1C
	dc.w 0x0808,0x1C1C,0x3E3E,0x7F7F,0xFFFF,0x7F7F,0x3E3E,0x1C1C
	dc.w 0x1111,0x2222,0x4444,0xFFFF,0x8888,0x4444,0x2222,0xFFFF
	dc.w 0x1111,0x2222,0x4444,0xFFFF,0x8888,0x4444,0x2222,0xFFFF

tab_pattern:
	dc.w 0x0101,0x0202,0x0404,0x0808,0x1010,0x2020,0x4040,0x8080
	dc.w 0x0101,0x0202,0x0404,0x0808,0x1010,0x2020,0x4040,0x8080
	dc.w 0x6060,0xC0C0,0x8181,0x0303,0x0606,0x0C0C,0x1818,0x3030
	dc.w 0x6060,0xC0C0,0x8181,0x0303,0x0606,0x0C0C,0x1818,0x3030
	dc.w 0x4242,0x8181,0x8181,0x4242,0x2424,0x1818,0x1818,0x2424
	dc.w 0x4242,0x8181,0x8181,0x4242,0x2424,0x1818,0x1818,0x2424
	dc.w 0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080
	dc.w 0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080
	dc.w 0xFFFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	dc.w 0xFFFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	dc.w 0xFFFF,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080
	dc.w 0xFFFF,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080
	dc.w 0x0001,0x0002,0x0004,0x0008,0x0010,0x0020,0x0040,0x0080
	dc.w 0x0100,0x0200,0x0400,0x0800,0x1000,0x2000,0x4000,0x8000
	dc.w 0x8003,0x0007,0x000E,0x001C,0x0038,0x0070,0x00E0,0x01C0
	dc.w 0x0380,0x0700,0x0E00,0x1C00,0x3800,0x7000,0xE000,0xC001
	dc.w 0x8001,0x4002,0x2004,0x1008,0x0810,0x0420,0x0240,0x0180
	dc.w 0x0180,0x0240,0x0420,0x0810,0x1008,0x2004,0x4002,0x8001
	dc.w 0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000
	dc.w 0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000,0x8000
	dc.w 0xFFFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	dc.w 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	dc.w 0xFFFF,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080
	dc.w 0xFFFF,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080,0x8080
	
_LINE_STYLE:
tab_line_type:
	dc.w 0xFFFF,0xFFF0,0xE0E0,0xFE38,0xFF00,0xF198

_pattern_ptrs:
	dc.l tab_full_pattern, tab_full_pattern, tab_frames, tab_pattern

	.bss

	ds.l 2048
vdi_stack:	ds.l 1
	ds.l 1024
vbl_stack:	ds.l 1
	ds.l 1024
mouse_stack:	ds.l 1
	ds.l 1024
conout_stack:	ds.l 1
	ds.b -(CUR_FONT)
var_vdi:     // for MagiC
	ds.b PAL_MAP+(256*4)
fvdi_virtual_default:	ds.l 1
fvdi_virtual:	ds.l 1
adr_var_vdi:	ds.l 1
adr_linea_fonts: ds.l 1
adr_linea_atab: ds.l 1
sysfonts:	ds.l 1
save_intout:	ds.l 1
old_statvec:	ds.l 1
ok_statvec:	ds.l 1
mouse_op:	ds.w 1
mouse_first:	ds.l 1
save_stack:	ds.l 1
save_stack2:	ds.l 1
save_stack3:	ds.l 1
save_stack4:	ds.l 1
save_bconstat2:	ds.l 1
save_bconin2:	ds.l 1
save_row:	ds.l 1
direct_call:	ds.b 1
use_videl:	ds.b 1
flush_bconout:	ds.b 1
#ifdef XAAES_SEMAPHORE
semaphore:	ds.b 1
#endif


;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

;  #[ Alt E:[Alt_E]

 IFNE in_line_asm

eskb		equ	0
tdata		equ	0
tnb		equ	10
tlspec		equ	11
tlength		equ	12
pcounter	equ	14
ptrop		equ	18
pendop		equ	22
ptrbufe		equ	26
asm_link	equ	30
eske		equ	34

 ENDC	; de in_line_asm

alt_e_get_curwind:
	movem.l	d2,-(sp)
	bsr	get_curwind
	movem.l	(sp)+,d2
	rts

redraw_register_windows:
 lea w1_db(a6),a0
 moveq #4,d0
.redraw_windows:
 move.w d0,d7
 lsl.w #4,d7
 tst.w $e(a0,d7.w)
 bne.s .dont_redraw
 movem.l d0/d7/a0,-(sp)
 bsr redraw_inside_window
 movem.l (sp)+,d0/d7/a0
.dont_redraw:
 dbf d0,.redraw_windows
 rts

alt_e:
 clr.w alt_e_tab_value(a6)
 bsr alt_e_get_curwind
 tst.w d1
 beq.s .reg
 cmp.w #HEXWIND_TYPE,d1
 beq.s .dump
 IFNE in_line_asm
 cmp.w #DISWIND_TYPE,d1
 beq disassembly_alt_e
 ENDC
 cmp.w #ASCWIND_TYPE,d1
 beq ascii_alt_e
.noalte:
 rts
.reg:
 cmp.w #9,w1_db+_GENWIND_H(a6)
 ble.s .noalte
.dump:
 not.b alt_e_flag(a6)
 beq .end_alt_e
 lea alt_e_berror(pc),a1
 move.l a1,d0
 _JSR set_berr
 move.l d0,save_alt_e_berror(a6)
 sf tab_cursor(a6)
 move.w window_selected(a6),window_redrawed(a6)
 subq.w #1,window_redrawed(a6)
 bsr alt_e_get_curwind
 bmi .register_window
 move.w 4(a0,d0.w),d4
 sub.w 0(a0,d0.w),d4
 cmp.w #26,d4
 bne.s .1
 lea alt_e_table1,a4
 moveq #4,d3
.1:
 cmp.w #50,d4
 bne.s .2
 lea alt_e_table3,a4
 moveq #$a,d3
.2:
 cmp.w #78,d4
 bne.s .3
 lea alt_e_table5,a4
 moveq #$10,d3
.3:
 cmp.w #38,d4
 bne.s .4
 lea alt_e_table7,a4
 moveq #8,d3
.4:
 cmp.w #158,d4
 bne.s .not_meta1
 lea alt_e_table9,a4
 moveq #$20,d3
.not_meta1:
 cmp.w #106,d4
 bne.s .not_meta2
 lea alt_e_table11,a4
 moveq #$10,d3
.not_meta2:
 move.w d4,d5
 btst #0,$d(a0,d0.w)
 beq.s .6
 add.w d5,a4
.6:
 move.w 2(a0,d0.w),d6
 move.w 6(a0,d0.w),d7
 move.w 0(a0,d0.w),minimum_ex_cursor(a6)
 add.w d6,d7
 subq.w #2,d7
 clr.w d5
 move.l 0(a0,d0.w),ex_cursor(a6)
 move.w #-1,old_ey_cursor(a6)
 bsr cursor_right
.0:
 _JSR print_window_cursor
.big_loop:
 bsr alt_e_get_char
 swap d0
 cmp.w #$0812,d0
 beq alt_e
 cmp.w #$0001,d0
 beq alt_e
 lea arrows_table(pc),a1
.little_loop:
 move.w (a1)+,d1
 beq.s .other_key_pressed
 addq.w #4,a1
 cmp.w d0,d1
 bne.s .little_loop
 swap d0
 clr.w d0
 bsr alte_record_key
 move.l -4(a1),a1
 jsr (a1)
 bra.s .0
.end_alt_e:
 move.w #-1,old_ey_cursor(a6)
 st alt_e_flag(a6)
 _JSR print_window_cursor
 bsr alte_record_esc
 sf alt_e_flag(a6)
 move.l save_alt_e_berror(a6),d0
 _JSR set_berr
 bra redraw_all_windows

.other_key_pressed:
 movem.l d1-d7/a0-a5,-(sp)
 swap d0
 tst.b tab_cursor(a6)
 bne.s .ascii
.hexa:
 sub.w #"0",d0
 bmi.s .flash
 cmp.w #9,d0
 ble.s .put_hexa_character
 bclr #5,d0
 subq.w #7,d0
 bmi.s .flash
 cmp.w #$f,d0
 bgt.s .flash
.put_hexa_character:
 exg d0,d7
 moveq #1,d0
 bsr.s .internal_other_key
 moveq #$f0,d3
 lsl.w #4,d7
 lsr.w #1,d4
 bcs.s .5
 lsr.w #4,d7
 moveq #$f,d3
 subq.w #1,d4
.5:
 add.w d4,d2
 bsr alt_e_get_curwind
 add.w d0,a0
 and.b d3,d7
 not.b d3
 and.b d3,0(a1,d2.w)
 or.b d7,0(a1,d2.w)
 bsr alt_e_scroll_up_down
.end_key:
 movem.l (sp)+,d1-d7/a0-a5
 bsr alte_record_key
 bsr cursor_right
 bra .0
.flash:
 _JSR flash
 movem.l (sp)+,d1-d7/a0-a5
 bra .0
.ascii:
 exg d0,d7
 moveq #-1,d0
 bsr.s .internal_other_key
 add.w d4,d2
 subq.w #1,d2
 bsr alt_e_get_curwind
 add.w d0,a0
 move.b d7,0(a1,d2.w)
 bsr alt_e_scroll_up_down
 bra.s .end_key

.internal_other_key:
 bsr get_occurence
 move.w ey_cursor(a6),d2
 sub.w d6,d2
 exg.l d4,d1
 bsr get_m_l_v
 addq.w #1,d6
 add.w d6,d6
 mulu d6,d2
 rts

.register_window:
 tst.l reg_wind_buf(a6)
 bne.s .force
 cmp.w #1,window_selected(a6)
 beq.s .no_switch
.force:
 tst.b window_magnified(a6)
 beq.s .no_magnify
 bsr alt_e_get_curwind
 lea reg_wind_buf(a6),a0
 lsr.w #2,d0
 move.l 0(a0,d0.w),-(sp)
 clr.l 0(a0,d0.w)
 sf alt_e_flag(a6)
 bsr redraw_all_windows
 st alt_e_flag(a6)
 move.w #1,-(sp)
 bra.s .after_switch
.no_magnify:
 lea w1_db(a6),a0
 move.b 8(a0),d7 
 move.w window_selected(a6),-(sp)
 move.w d7,-(sp)
 bsr alt_1
 move.w (sp)+,d7
 lea reg_wind_buf(a6),a0
 move.l (a0),-(sp)
 clr.l (a0)
 lea w1_db(a6),a0
 move.w $e(a0),-(sp)
 clr.w $e(a0)
 sf alt_e_flag(a6)
 ext.w d7
 move.w d7,-(sp)
 bsr redraw_all_windows
 st alt_e_flag(a6)
 move.w #-1,-(sp)
 bra.s .after_switch
.no_switch:
 clr.w -(sp)
.after_switch:
 bsr .invert_choice
.reg_big_loop:
 bsr alt_e_get_char
 swap d0
 cmp.w #$0812,d0	;alt_e
 beq.s .finish
 cmp.w #$0001,d0	;esc
 beq.s .finish
 cmp.w #$000f,d0	;tab
 beq .tab
.no_sr:
 lea reg_keys_table(pc),a0
 moveq #6,d1
 and.w #$ff,d0
._21:
 cmp.w (a0)+,d0
 bne.s ._20
 swap d0
 bsr alte_record_key
;
 move.w (a0),d0
 move.w sr_buf(a6),d1
 bchg d0,d1
 move.w d1,sr_buf(a6)
;
 sf alt_e_flag(a6)
 move.w window_selected(a6),d0
 subq.w #1,d0
 bsr redraw_inside_window
 st alt_e_flag(a6)
 bsr .invert_choice
 bra.s .reg_big_loop
._20:
 addq.w #2,a0
 dbf d1,._21
 movem.l d0-d2/a0-a2,-(sp)
 _JSR flash
 movem.l (sp)+,d0-d2/a0-a2
 bra.s .reg_big_loop
.finish:
 bsr alte_record_esc
 sf alt_e_flag(a6)
 move.l save_alt_e_berror(a6),d0
 _JSR set_berr
 move.w (sp)+,d0
 beq redraw_register_windows
 bpl.s .it_was_magnified
 tst.w (sp)+
 bne.s .keep_w1
 bsr alt_s
.keep_w1:
 lea w1_db(a6),a0
 move.w (sp)+,$e(a0)
 bsr redraw_curwind
 lea reg_wind_buf(a6),a0
 move.l (sp)+,(a0)
 move.w (sp)+,d0
 lsl.w #3,d0
 jmp .window_to_switch-8(pc,d0.w)
.window_to_switch:
 bsr alt_1
 bra redraw_register_windows
 bsr alt_2
 bra redraw_register_windows
 bsr alt_3
 bra redraw_register_windows
 bsr alt_4
 bra redraw_register_windows
 bsr alt_5
 bra redraw_register_windows
.it_was_magnified:
 bsr alt_e_get_curwind
 lsr.w #2,d0
 lea reg_wind_buf(a6),a0
 move.l (sp)+,0(a0,d0.w)
 bra redraw_curwind

.tab:
 swap d0
 bsr alte_record_key
 tst.b low_rez(a6)
 bne .reg_big_loop
 move.w alt_e_tab_value(a6),d0
 addq.w #1,d0
 IFNE ATARITT
 cmp.w #9,d0
 ELSEIF
 cmp.w #5,d0
 ENDC
 bne.s .tab1
 clr.w d0
.tab1:
 move.w d0,alt_e_tab_value(a6)
 lsl.w #3,d0
 move.w d0,-(sp)
 tst.w d0
 bne.s .tab2
 IFNE ATARITT
 moveq #72,d0
 ELSEIF
 moveq #40,d0
 ENDC
.tab2:
 move.w #-1,old_ey_cursor(a6)
 lea alt_e_tab_table(pc),a1
 move.l -8(a1,d0.w),ex_cursor(a6)
 _JSR print_window_cursor
 move.w #-1,old_ey_cursor(a6)
 move.l -4(a1,d0.w),ex_cursor(a6)
 _JSR print_window_cursor
 move.w (sp)+,d0
 move.w #-1,old_ey_cursor(a6)
 move.l 0(a1,d0.w),ex_cursor(a6)
 _JSR print_window_cursor
 move.w #-1,old_ey_cursor(a6)
 move.l 4(a1,d0.w),ex_cursor(a6)
 _JSR print_window_cursor
 tst.w alt_e_tab_value(a6)
 beq .reg_big_loop
.alt_e_waiting:
 bsr alt_e_get_char
 swap d0
 cmp.w #$0001,d0
 beq .finish
 cmp.w #$0812,d0
 beq .finish
 cmp.w #$000f,d0
 beq .tab
 cmp.w #$0015,d0
 beq.s .alt_e_yes
 cmp.w #$0031,d0
 beq.s .alt_e_no
 movem.l d0-d2/a0-a2,-(sp)
 _JSR flash
 movem.l (sp)+,d0-d2/a0-a2
 bra.s .alt_e_waiting
.alt_e_no:
 move.w alt_e_tab_value(a6),d1
 lea external_mfp_ctl_struct(a6),a0
 sf -1(a0,d1.w)
 bra.s .alt_e_yes_no
.alt_e_yes:
 move.w alt_e_tab_value(a6),d1
 lea external_mfp_ctl_struct(a6),a0
 st -1(a0,d1.w)
.alt_e_yes_no:
 swap d0
 bsr.s alte_record_key
 sf alt_e_flag(a6)
 move.w window_selected(a6),d0
 subq.w #1,d0
 bsr redraw_inside_window
 st alt_e_flag(a6)
 bsr.s .invert_choice
 bra.s .alt_e_waiting

.invert_choice:
 move.w d0,-(sp)
 move.w alt_e_tab_value(a6),d0
 lsl.w #3,d0
 move.w #-1,old_ey_cursor(a6)
 move.l alt_e_tab_table(pc,d0.w),ex_cursor(a6)
 _JSR print_window_cursor
 move.w #-1,old_ey_cursor(a6)
 move.l alt_e_tab_table+4(pc,d0.w),ex_cursor(a6)
 _JSR print_window_cursor
 move.w (sp)+,d0
 rts

alte_record_esc:
 move.l #$0001001b,d0
alte_record_key:
 tst.b rec_mac_flag(a6)
 beq.s .no_recording
 movem.l d0-d2/a0-a1,-(sp)
 move.b alt_e_flag(a6),-(sp)
 sf alt_e_flag(a6)
 _JSR recording_mac
 move.b (sp)+,alt_e_flag(a6)
 movem.l (sp)+,d0-d2/a0-a1
.no_recording:
 rts

 IFNE	ATARIST
 IFNE _68020!_68030
alt_e_tab_table:
 dc.l $00010009
 dc.l $00020009
 dc.l $004b0002
 dc.l $004c0002
 dc.l $004b0003
 dc.l $004c0003
 dc.l $004b0004
 dc.l $004c0004
 dc.l $004b0005
 dc.l $004c0005
 dc.l $004b0006
 dc.l $004c0006
 dc.l $004b0007
 dc.l $004c0007
 dc.l $004b0008
 dc.l $004c0008
 dc.l $004b0009
 dc.l $004c0009
 ELSEIF
alt_e_tab_table:
 dc.l $00010009
 dc.l $00020009
 dc.l $004b0003
 dc.l $004c0003
 dc.l $004b0004
 dc.l $004c0004
 dc.l $004b0005
 dc.l $004c0005
 dc.l $004b0006
 dc.l $004c0006
 ENDC
 ENDC ; d'ATARIST
 IFNE	AMIGA
alt_e_tab_table:
 dc.l $0001000a
 dc.l $0002000a
 dc.l $004b0006
 dc.l $004c0006
 dc.l $004b0007
 dc.l $004c0007
 dc.l $004b0008
 dc.l $004c0008
 dc.l $004b0009
 dc.l $004c0009
 ENDC ; d'AMIGA

reg_keys_table:
 dc.w $002d
 dc.w 4
 dc.w $0031
 dc.w 3
 dc.w $002f
 dc.w 1
 dc.w $0011
 dc.w 2
 dc.w $002e
 dc.w 0
 dc.w $0014
 dc.w $f
 dc.w $001f
 dc.w $d

alt_e_berror:
 IFNE _68030
 tst.b chip_type(a6)
 beq.s .68000
 bclr #0,$a(sp)
 rte
.68000:
 ENDC ;de 68030
 addq.w #8,sp
 rte

arrows_table:
 dc.w $0048
 dc.l cursor_up
 dc.w $0050
 dc.l cursor_down
 dc.w $0148
 dc.l cursor_shift_up
 dc.w $0150
 dc.l cursor_shift_down
 dc.w $004b
 dc.l cursor_left
 dc.w $004d
 dc.l cursor_right
 dc.w $000f
 dc.l alt_e_tab
 dc.w 0

 even

cursor_right:
 addq.w #1,ex_cursor(a6)
 addq.w #1,d5
 cmp.w d5,d4
 bne.s .1
 sub.w d4,ex_cursor(a6)
 clr.w d5
 bsr.s cursor_right
 bra.s cursor_down
.1:
 tst.b 0(a4,d5.w)
 beq.s cursor_right
 bmi.s .2
 tst.b tab_cursor(a6)
 bne.s cursor_right
 rts
.2:
 tst.b tab_cursor(a6)
 beq.s cursor_right
 rts

cursor_left:
 subq.w #1,ex_cursor(a6)
 subq.w #1,d5
 bpl.s .1
 add.w d4,ex_cursor(a6)
 move.w d4,d5
 subq.w #1,d5
 bsr.s cursor_left
 bra.s cursor_up
.1:
 tst.b 0(a4,d5.w)
 beq.s cursor_left
 bmi.s .2
 tst.b tab_cursor(a6)
 bne.s cursor_left
 rts
.2:
 tst.b tab_cursor(a6)
 beq.s cursor_left
 rts

cursor_up:
 cmp.w ey_cursor(a6),d6
 bne.s .1
 bsr alt_e_get_curwind
 add.w d0,a0
 sub.l d3,$a(a0)
 bra.s alt_e_scroll_up_down
.1:
 subq.w #1,ey_cursor(a6)
 rts

cursor_down:
 cmp.w ey_cursor(a6),d7
 bne.s .1
 bsr alt_e_get_curwind
 add.w d0,a0
 add.l d3,$a(a0)
 bra.s alt_e_scroll_up_down
.1:
 addq.w #1,ey_cursor(a6)
 rts

cursor_shift_up:
 move.l d7,-(sp)
 bsr alt_e_get_curwind
 add.w d0,a0
 sub.w 2(a0),d7
.1:
 sub.l d3,$a(a0)
 dbf d7,.1
 move.l (sp)+,d7
 bra.s alt_e_scroll_up_down

cursor_shift_down:
 move.l d7,-(sp)
 bsr alt_e_get_curwind
 add.w d0,a0
 sub.w 2(a0),d7
.1:
 add.l d3,$a(a0)
 dbf d7,.1
 move.l (sp)+,d7

alt_e_scroll_up_down:
 move.w #-1,old_ey_cursor(a6)
 _JSR print_window_cursor
 movem.l d0-d7/a0-a5,-(sp)
 sf alt_e_flag(a6)
 bsr redraw_inside_window2
 st alt_e_flag(a6)
 movem.l (sp)+,d0-d7/a0-a5
 move.w #-1,old_ey_cursor(a6)
 jmp print_window_cursor

alt_e_tab:
 not.b tab_cursor(a6)
 beq.s .1
 moveq #1,d0
 bsr.s get_occurence
 lsr.w #1,d1
 bcc.s .2
 addq.w #1,d1
.2:
 bra.s replace_cursor
.1:
 moveq #-1,d0
 bsr.s get_occurence
 add.w d1,d1
 subq.w #1,d1
 bra.s replace_cursor

get_occurence:
 movem.l d2-d4/a0-a2,-(sp)
 moveq #0,d1
 moveq #0,d2
.2:
 cmp.b 0(a4,d2.w),d0
 bne.s .1
 addq.w #1,d1
.1:
 addq.w #1,d2
 cmp.w d2,d5
 bge.s .2
 movem.l (sp)+,d2-d4/a0-a2
 rts

replace_cursor:
 neg.b d0
 subq.w #1,d1
 bpl.s .2
 clr.w d1
.2:
 moveq #-1,d5
.1:
 addq.w #1,d5
 cmp.b 0(a4,d5.w),d0
 bne.s .1
 dbf d1,.1
 move.w d5,ex_cursor(a6)
 move.w minimum_ex_cursor(a6),d0
 add.w d0,ex_cursor(a6)
 rts

alt_e_get_char:
 tst.b play_mac_flag(a6)
 beq.s .no_playing
 movem.l d1-a5,-(sp)
 move.l cur_play_mac_addr(a6),a0
 _JSR pskip
 cmp.b #'`',(a0)+
; bne.s .syntax_error
 move.l a0,cur_play_mac_addr(a6)
 _JSR text_to_scan
 exg.l d0,d7
 move.l cur_play_mac_addr(a6),a0
 _JSR pflush
 move.l a0,cur_play_mac_addr(a6)
 exg.l d0,d7
 movem.l (sp)+,d1-a5
 bra.s .after_playing
.no_playing:
 _JSR get_char
.after_playing:
 tst.l d0
 bne.s .good_key
 _JSR flash
 bra.s alt_e_get_char
.good_key:
 rts

 IFNE in_line_asm

disassembly_alt_e:
 not.b alt_e_flag(a6)
 beq .end_alt_e
 bsr get_vbr
 move.l 8(a0),save_alt_e_berror(a6)
.loop:
 bsr alt_e_get_curwind
 move.w 2(a0,d0.w),y_pos(a6)
 move.l a1,d0
 bclr #0,d0
 move.l d0,test_instruction(a6)
.little_loop:
 bsr alt_e_get_curwind
 move.w 0(a0,d0.w),d1
 add.w #10,d1
 move.w d1,x_pos(a6)
 bsr .internal_disassemble_line
 bra.s .51
.50:
 move.w #"**",(a0)+
.51:
 clr.b (a0)
.after_cursor:
 bsr alt_e_get_curwind
 lea 0(a0,d0.w),a1
 move.w (a1)+,d2
 lea window_tab_table(a6),a0
 lsr #3,d0
 add 0(a0,d0),d2
 addq.w #2,a1
 move.w (a1)+,d1
 subq.w #2,d1
 lea print_presskey_buffer(a6),a0
 _JSR strlen
 move.l a0,a1
 move.l a0,a2
 add.w d0,a0
 move.w d2,d0
 st m_line(a6)
 sf alt_e_flag(a6)
 _JSR edit_ascii_line
 sf m_line(a6)
 st alt_e_flag(a6)
 tst.w d0
 bmi disassembly_alt_e
 sf alt_e_flag(a6)
 cmp.w #2,d0
 beq .up
 cmp.w #3,d0
 beq .down
 cmp.w #4,d0
 beq .sft_up
 cmp.w #5,d0
 beq .sft_down 
 clr.b (a2)
 move.l a1,a0
 _JSR recmacline
 move.l a1,a0
 lea line_buffer(a6),a1
 move.l test_instruction(a6),d0
 bsr asm_one_line
 tst.w d0
 bpl.s .assembling_done
.assembling_error:
 _JSR flash
 sf alt_e_flag(a6)
 bra .after_cursor
.assembling_done:
 ext.l d4
 bclr #0,d4
 move.w d4,instruction_size(a6)
 bra .down

.end_alt_e:
 bsr alte_record_esc
 move.l save_alt_e_berror(a6),d0
 _JSR set_berr
 bra redraw_all_windows

.internal_disassemble_line:
 movem.l d0-d7/a1-a5,-(sp)
 move.l test_instruction(a6),a1
 lea print_presskey_buffer(a6),a0
 st optimise_address(a6)
 _JSR disassemble_line
 movem.l (sp)+,d0-d7/a1-a5
 rts

.up:
 bsr alt_e_get_curwind
 move.w y_pos(a6),d1
 cmp.w 2(a0,d0.w),d1
 bne.s .only_up
 bsr up
 bsr alt_e_get_curwind
 move.l a1,test_instruction(a6)
 move.l 0(a0,d0.w),x_pos(a6)
 bra .little_loop
.only_up:
 move.l a1,test_instruction(a6)
 move.l test_instruction(a6),d7
 move.l device_number(a6),-(sp)
 clr.l device_number(a6)
 move.w y_pos(a6),d6
 sub.w 2(a0,d0.w),d6
 subq.w #1,d6
 moveq #0,d0
.going_up:
 ext.l d0
 add.l d0,test_instruction(a6)
 add.l d0,d7
 bsr .internal_disassemble_line
 move.w instruction_size(a6),d0
 dbf d6,.going_up
 move.l (sp)+,device_number(a6)
 subq.w #1,y_pos(a6)
 move.l x_pos(a6),-(sp)
 bsr redraw_curwind
 move.l (sp)+,x_pos(a6)
 move.l d7,test_instruction(a6)
 bra .little_loop
.sft_up:
 bsr shift_up
 bra .loop

.down:
 bsr alt_e_get_curwind
 move.w 2(a0,d0.w),d1
 add.w 6(a0,d0.w),d1
 subq.w #2,d1
 cmp.w y_pos(a6),d1
 bgt.s .only_down
 move.w instruction_size(a6),-(sp)
 move.l test_instruction(a6),-(sp)
 bsr down
 move.l (sp)+,test_instruction(a6)
 move.w (sp)+,instruction_size(a6)
 subq.w #2,y_pos(a6)
.only_down:
 addq.w #1,y_pos(a6)
 move.w instruction_size(a6),d7
 ext.l d7
 add.l test_instruction(a6),d7
 move.l x_pos(a6),-(sp)
 bsr redraw_curwind
 move.l (sp)+,x_pos(a6)
 move.l d7,test_instruction(a6)
 bra .little_loop
.sft_down:
 bsr shift_down
 bra .loop

ev:
 movem.l d1-a4/a6,-(sp)
 GETA6
 move.l a5,a0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
.another_char:
 move.b (a5)+,d0
 beq.s .end_reached
 cmp.b #'(',d0
 bne.s .not_open_par
 addq.w #1,d1
.not_open_par:
 cmp.b #')',d0
 bne.s .not_close_par
 subq.w #1,d1
.not_close_par:
 cmp.b #'{',d0
 bne.s .not_open_acc
 addq.w #1,d2
.not_open_acc:
 cmp.b #'}',d0
 bne.s .not_close_acc
 subq.w #1,d2
.not_close_acc:
 cmp.b #'[',d0
 bne.s .not_open_bracket
 addq.w #1,d3
.not_open_bracket:
 cmp.b #']',d0
 bne.s .not_close_bracket
 subq.w #1,d3
.not_close_bracket:
 tst.b d0
 beq.s .end_reached
 cmp.b #',',d0
 beq.s .test_if_end_reached
 cmp.b #' ',d0
 beq.s .test_if_end_reached
 bra.s .another_char
.test_if_end_reached:
 tst.w d1
 bne.s .another_char
 tst.w d2
 bne.s .another_char
 tst.w d3
 bne.s .another_char
.end_reached:
 moveq #0,d0
 move.b -2(a5),d0
 cmp.b #')',d0
 beq .ev_get_start
 cmp.w #'a',d0
 blt.s .not_upper
 cmp.w #'z',d0
 bgt.s .not_upper
.upper:
 and.w #$df,d0
.not_upper:
 cmp.b #'B',d0
 beq.s .test_dot
 cmp.b #'W',d0
 beq.s .test_dot
 cmp.b #'L',d0
 bne.s .cut
.test_dot:
 cmp.b #'.',-3(a5)
 bne.s .cut
 subq.w #2,a5
.cut:
 move.b -(a5),-(sp)
 move.l a5,-(sp)
 clr.b (a5)
 st evaluate_decimal_flag(a6)
 st evaluate_one_string_flag(a6)
 bsr evaluate
 sf evaluate_decimal_flag(a6)
 sf evaluate_one_string_flag(a6)
 move.l (sp)+,a5
 move.b (sp)+,(a5)
 move.b (a5),d2
 lsl.w #8,d2
 move.b 1(a5),d2
 and.b #$df,d2
 cmp.w #'.W',d2
 beq.s .abs_short_long
 cmp.w #'.L',d2
 beq.s .abs_short_long
.not_abs_short_long:
 tst.w d1
 movem.l (sp)+,d1-a4/a6
 bmi er
 rts
.abs_short_long:
 addq.w #2,a5
 bra.s .not_abs_short_long
.ev_get_start:
 subq.w #1,a5
 bsr.s .test_if_d16_an
 beq.s .end_get_start
 bsr.s .test_if_d8_an_xn
.end_get_start:
 addq.w #1,a5
 bra.s .cut

.test_if_d16_an:
 move.l d1,-(sp)
 moveq #0,d0
 move.b -3(a5),d0
 bsr .to_upper
 move.b d0,d1
 move.b -2(a5),d0
 bsr .to_upper
 lsl.w #8,d1
 or.w d1,d0
 cmp.l #'SP',d0
 beq.s .d16_end
 cmp.l #'PC',d0
 beq.s .d16_end
 cmp.l #'A0',d0
 bcs.s .d16_error
 cmp.l #'A7',d0
 bhi.s .d16_error
.d16_end:
 cmp.b #'(',-4(a5)
 bne.s .d16_error
 subq.w #4,a5
 move.l (sp)+,d1
 moveq #0,d0
 rts
.d16_error:
 move.l (sp)+,d1
 moveq #-1,d0
 rts

.test_if_d8_an_xn:
 movem.l d1-d2,-(sp)
 moveq #0,d0
 moveq #0,d2
 move.b -3(a5),d0
 bsr .to_upper
 move.b d0,d1
 move.b -2(a5),d0
 bsr .to_upper
 lsl.w #8,d1
 or.w d1,d0
 cmp.l #'.W',d0
 beq.s .size
 cmp.l #'.L',d0
 bne.s .after_size
.size:
 moveq #-2,d2
 moveq #0,d0
 move.b -5(a5),d0
 bsr .to_upper
 move.b d0,d1
 move.b -4(a5),d0
 bsr .to_upper
 lsl.w #8,d1
 or.w d1,d0
.after_size:
 cmp.l #'SP',d0
 beq.s .d8_1
 cmp.l #'A0',d0
 blt.s .d8_error
 cmp.l #'D7',d0
 bgt.s .d8_error
 cmp.l #'A7',d0
 ble.s .d8_1
 cmp.l #'D0',d0
 blt.s .d8_error
.d8_1:
 cmp.b #',',-4(a5,d2.w)
 bne.s .d8_error
 moveq #0,d0
 move.b -6(a5,d2.w),d0
 bsr.s .to_upper
 move.b d0,d1
 move.b -5(a5,d2.w),d0
 bsr.s .to_upper
 lsl.w #8,d1
 or.w d1,d0
 cmp.l #'SP',d0
 beq.s .d8_end
 cmp.l #'PC',d0
 beq.s .d8_end
 cmp.l #'A0',d0
 blt.s .d8_error
 cmp.l #'A7',d0
 bgt.s .d8_error
.d8_end:
 cmp.b #'(',-7(a5,d2.w)
 bne.s .d8_error
 subq.w #7,a5
 add.w d2,a5
 movem.l (sp)+,d1-d2
 moveq #0,d0
 rts
.d8_error:
 movem.l (sp)+,d1-d2
 moveq #-1,d0
 rts

.to_upper:
 cmp.b #'a',d0
 blt.s .not_lower
 cmp.b #'z',d0
 bgt.s .not_lower
.lower:
 and.w #$df,d0
.not_lower:
 rts

xbase:
; find and set size
; bit 5432109876543210
;     ........00......  = byte
;     ........01......  = word
;     ........10......  = long
;
fsize:
 or.w tlength(a1),d2	; set size bits
 rts

;  d0 = value 0 - 7
;  d1 = 0 if d@ = 1 if a@
getregd:
 moveq #0,d1

 cmp.b #'D',(a5)+
 beq.s .1
 cmp.b #'d',-1(a5)
 bne.s er1
.1:

get41:
 moveq #0,d0
 move.b (a5)+,d0
 sub.b #'0',d0
 bmi.s er1
 cmp.b #7,d0
 bgt.s er1
 rts

getrega:
 moveq #8,d1

 cmp.b #'A',(a5)+
 beq.s .1
 cmp.b #'a',-1(a5)
 beq.s .1
.test_sp:
 cmp.b #'S',-1(a5)
 beq.s _get_sp
 cmp.b #'s',-1(a5)
 beq.s _get_sp
 bra er1
.1:
 bra.s get41

getregad:
 clr d1
 move.b (a5)+,d0

 cmp.b #'D',d0
 beq.s get41
 cmp.b #'d',d0
 beq.s get41

 move.b #8,d1

 cmp.b #'A',d0
 beq.s get41
 cmp.b #'a',d0
 beq.s get41

 cmp.b #'S',d0
 beq.s _get_sp
 cmp.b #'s',d0
 bne.s er1

_get_sp:
 cmp.b #'P',(a5)
 beq.s _put_sp
 cmp.b #'p',(a5)
 bne.s er1
_put_sp:
 moveq #8,d1
 moveq #7,d0
 addq.w #1,a5
 rts

 
er1:
 bra er

eada:
 move.w #$1fd,d7	; data alterable only
 bra.s ea
eac:
 move.w #$7e4,d7	; control only
 bra.s ea
eam:
 move.w #$1fc,d7	; memory alterable only
 bra.s ea
eaz:
 move.w #$800,d7	; immediate only
 bra.s ea

eadaddr:
 move.w #$ffd,d7	; data addressing
 bra.s ea

eaa:
 move.w #$1ff,d7	; alterable addressing
 bra.s ea

eaall:
 move.w #$fff,d7	; all modes
;  ...............1  d@  data register
;  ..............1.  a@
;  .............1..  (a@)
;  ............1...  -(a@)
;  ...........1....  (a@)+
;  ..........1.....  data(a@)
;  .........1......  data(a@,r@)
;  ........1.......  data (short)
;  .......1........  data (long)
;  ......1.........  data(pc)
;  .....1..........  data(pc,r@)
;  ....1...........  #data
;  1...............  special case jmp.l

; d0 = value calculated
; d2 = mask word (1st word of instruction)
; d3 = offset for data store (tdata+..)
; d4 = extension word
; d5 = <data>
; d6 = mode as built.........xxxxxx
; d7 = modes allowed
;
; a4 = base address for data store (tdata+..){a4,d3}
ea: 
 moveq #0,d5		; zero value
 moveq #0,d6		; mode = 000000
 move.b (a5),d0
 cmp.b #'#',d0
 bne.s ea10

; immediate mode
 btst #11,d7
 beq.s er1

 move.b #$3c,d6		; d6 = mode  111100
 addq.w #1,a5

 bsr ev			;evaluate expression
 move.l d0,d5		; d5 = value

 tst.b tlspec(a1)
 beq.s ea0633		; size not specified (.w assumed)

 move.w tlength(a1),d0
 beq.s ea0635		; byte

 tst.b d0
 bmi.s ea0637		; long

ea0633:
 bsr ea16bit		; word -32k to +64k
ea0634:
 move.w d5,(a4,d3)
 addq.b #2,tnb(a1)	; byte count
 addq.l #2,d3		; offset
 rts

ea0635:
 bsr ea8bit		; -127 to +255
 bne.s er1
 bra.s ea0634

ea0637:
 move.l d5,(a4,d3)
 addq.b #4,tnb(a1)
 addq.l #4,d3
 rts

ea10:
 cmp.b #'-',(a5)
 bne.s ea11

 cmp.b #'(',1(a5)
 bne ea41		; may be -<data>

 addq.w #2,a5
 move.w #$0020,d6	; mode = -(a@) 100aaa

 btst #4,d7
 beq er1		; this mode not allowed

 bsr getrega
 or.w d0,d6

 cmp.b #')',(a5)+
 bne asm_err_mode	; no closing parin
 rts

ea11:
 cmp.b #'A',d0
 beq.s .1
 cmp.b #'a',d0
 beq.s .1
 cmp.b #'S',d0
 beq.s .1
 cmp.b #'s',d0
 bne.s ea21
.1:

 move.b #$08,d6		; mode = 001...
 btst #1,d7
 beq.s asm_err_mode	; mode not allowed

 bsr getrega
 or.w d0,d6
 rts

ea21:
 cmp.b #'D',d0
 beq.s .1
 cmp.b #'d',d0
 bne.s ea31
.1:

 btst #0,d7
 beq.s asm_err_mode	; mode not allowed

 bsr getregd		; mode = d@000aaa
 or.w d0,d6
 rts

ea31:
 cmp.b #'(',d0
 bne.s ea41

; possible
;  (a@)
;  (a@)+
;  (a@,r@)  implied zero displacement
;
 addq.w #1,a5
 bsr getrega
 or.w d0,d6

 move.b (a5)+,d0
 cmp.b #',',d0
 beq ea5116		; mode = (a@,r@)  ;implied d5 = 0 data

 cmp.b #')',d0		; look for closing )
 bne.s asm_err_mode

 cmp.b #' ',(a5)	; look for blank
 beq.s ea35		; mode = (a@)

 cmp.b #'+',(a5)
 bne.s ea35
 addq.w #1,a5

 or.w #$18,d6		; mode = 011... (a@)+

 btst #3,d7
 beq.s asm_err_mode	; mode not allowed

ea34:
 rts

ea35:
 or.w #$10,d6		; mode = 010... (a@)

 btst #2,d7
 bne.s ea34		; mode allowed
asm_err_mode:
 bra er			; mode not allowed or parenthesis not matched

; possible
;<data>short
;<data>long
;<data>(a@)
;<data>(a@,r@)
;<data>(a@,r@.w)
;<data>(a@,r@.l)
;<data>(pc)
;<data>(pc,r@)
;<data>(pc,r@.w)
;<data>(pc,r@.l)
;
ea41:
 bsr ev			; evaluate expression
 move.l d0,d5		; d5 = <data>
 cmp.b #'.',-2(a5)				; ***
 bne.s .not_word				; ***
 cmp.b #'w',-1(a5)
 beq.s .it_was_word
 cmp.b #'W',-1(a5)
 bne.s .not_word
.it_was_word:
 move.b (a5),d0					; ***
 cmp.b #',',d0					; ***
 beq.s its_short				; ***
 cmp.b #' ',d0					; ***
 bne.s ea4120					; ***
 bra its_short					; ***

.not_word:					; ***
 move.b (a5),d0
 cmp.b #',',d0
; beq.s ea4102
 beq ea4135					; ***
 cmp.b #' ',d0
 bne.s ea4120
 bra ea4135					; ***

;  <data> only
; check if negative number
;ea4102:
; move.l d5,d0
; bpl.s ea4105		; positive number
; not.l d0
;ea4105:
; and.w #$8000,d0
; tst.l d0
; bne.s ea4135		; long

;  <data>.w
its_short:
 btst #7,d7
 bne.s ea4127		; short allowed
 btst #15,d7
 beq.s asm_err_mode	; mode not allowed
 bra.s ea4135		; special case (jmp.l)

ea4127:
 or.w #$38,d6		; ea = absolute short
 move.w d5,(a4,d3)	; d5 = data
 addq.b #2,tnb(a1)	; byte count
 addq.l #2,d3
 rts

;ea4134 cmp.b #'L',d0
; bne asm_err_mode

;  <data>.l
ea4135:
 or.w #$39,d6		; ea = absolute long
 move.l d5,(a4,d3)
 addq.b #4,tnb(a1)	; byte count
 addq.l #4,d3
 btst #8,d7
 beq.s asm_err_mode	; mode not allowed
 rts

ea4120:
 addq.w #1,a5
 cmp.b #'(',d0
 bne asm_err_mode

 cmp.b #'P',(a5)
 beq ea61
 cmp.b #'p',(a5)
 beq ea61

; <data>(a@.......
 bsr ea16bits		; -32k to +32k

 bsr getrega
 or.w d0,d6

 move.b (a5),d0
 cmp.b #')',d0
 bne.s ea5115

; <data>(a@)
 addq.w #1,a5

 btst #5,d7
 beq er4		; mode not allowed

 or.w #$0028,d6		; mode = 101aaa

 cmp.l #$10000,d5
 bpl er4

 move.w d5,(a4,d3)
 addq.b #2,tnb(a1)
 addq.l #2,d3
 rts

ea5115:
 bsr comma

;<data>(a@,----- address register with index
ea5116:
 ext.l d5
 bsr ea8bits		; -128 to +127
 bne  er4
 and.w #$00ff,d5
 or.w #$0030,d6	; mode 110---

 btst #6,d7
 beq  er4		; mode not allowed

 bsr getregad
 or.w d1,d0
 ror.w #4,d0
 or.w d0,d5		; extension word

; bit 11 extension word
;0 = sign extended, low order integer in index register
;1 = long value in index register  (default)
;
 move.b (a5)+,d0
 cmp.b #')',d0
 beq.s ea5119		; default.w

 cmp.b #'.',d0
 bne.s er4

 move.b (a5)+,d0
 cmp.b #'W',d0
 beq.s ea5118
 cmp.b #'w',d0
 beq.s ea5118

 cmp.b #'L',d0
 beq.s .1		; neither .w nor .l
 cmp.b #'l',d0
 bne.s er4		; neither .w nor .l
.1:

 or.w #$0800,d5		; extension word, w/l bit = .l

ea5118:
 cmp.b #')',(a5)+
 bne.s er4		; no closing ")"

ea5119:
 move.w d5,(a4,d3)
 addq.b #2,tnb(a1)
 addq.l #2,d3
ea5119e:
 rts

;<data>(p-----
ea61:
 addq.w #1,a5

 cmp.b #'C',(a5)+
 beq.s .1
 cmp.b #'c',-1(a5)
 bne er
.1:

 sub.l pcounter(a1),d5	; d5 = d5 - pc
 subq.l #2,d5		; d5 = d5 - (pc + 2)

 move.b (a5)+,d0
 cmp.b #')',d0
 bne.s ea71

;  <data>(pc)
 or.w #$3a,d6		; mode = 111010

 bsr.s ea16bits	; -32k to +32k
 move.w d5,(a4,d3)
 addq.b #2,tnb(a1)
 addq.l #2,d3

 btst #9,d7
 bne.s ea5119e
er4:
 bra er

;<data>(pc---- program counter with index
ea71:
 move.w #$003b,d6	; mode = 111011

 cmp.b #',',d0
 bne.s er4

 btst #10,d7
 beq.s er4		; mode not allowed

 bsr.s ea8bits		; -128 to +127
 bne.s er4

 and.w #$00ff,d5	; d5 = value
 bsr getregad
 or.w d1,d0


 ror.w #4,d0
 or.w d0,d5		; d5 = extension word

 move.b (a5)+,d0
 cmp.b #')',d0
 beq.s ea7115		; default  .w

 cmp.b #'.',d0
 bne.s er4

 move.b (a5)+,d0
 cmp.b #'W',d0
 beq.s ea7113
 cmp.b #'w',d0
 beq.s ea7113

 cmp.b #'L',d0
 bne.s er4
 cmp.b #'l',d0
 bne.s er4

 or.w #$0800,d5		; extension word w/l = .l

ea7113:
 cmp.b #')',(a5)+
 bne.s er4		; no closing ")"

ea7115:
 move.w d5,(a4,d3)
 addq.b #2,tnb(a1)
 addq.l #2,d3
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; routines to test for valid effective addresses
;
; ea16bit tests that -32768 <= d5 <= 65535. (signed or unsigned)
; ea16bits  tests that -32768 <= d5 <= 32767. (signed only)
; ea8bit tests that-128 <= d5 <=255. (signed or unsigned)
; ea8bits tests that-128 <= d5 <=127. (signed only)
;
; the 16-bit tests branch to er if invalid, else return.
; the  8-bit tests return condition codes <eq> if valid, else <ne>.
; d5 is preserved unless a branch to er results.
; d1 is destroyed.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ea16bit:
 bsr.s ea16bitc		; check range -32768 to 32767.  if
 move.l d5,d1		; invalid, check whether the high 16
 swap d1		; bits are 0 (which implies that
 tst.w d1		; d5 <= 65535). if not, fall thru to
 beq.s easex		; the 16-bit signed test--we will
			; fail and go to er.

ea16bits:
 pea er(pc)		; set up to return to er if invalid.
ea16bitc:
 move.l #$7fff,d1	; d1  <--  2^16-1.
 bra.s eas		; go to the common test routine.
ea8bit:
 bsr.s ea8bitc		; check range -128 to 127.  if invalid,
 move.l d5,d1		; check whether the high 24 bits are
 lsr.l #8,d1		; 0 (which implies that d5 <= 255).
 rts

ea8bits:
 bsr.s ea8bitc		; just check for -127 <= d5 <= 128.
 rts			; (bsr puts needed address on stack!)

ea8bitc:
 moveq #$7f,d1	; d1  <--  2/8 - 1.

;  *** note: this routine plays with the stack ***
eas:
 cmp.l d1,d5  		; if d5 > 2^n-1, return with <ne> (inval).
 bgt.s easex
 not.l d1		; if d5 < -2^n, return with <ne> (inval).
 cmp.l d1,d5
 blt.s easex
 addq.w #4,a7		; pop the return address off the stack,
 moveq #0,d1		; set <eq> (valid), and return.
easex:
 rts

adr	MACRO
 dc.w m\1-xbase
	ENDM

tblkeys:	; INDEX
 adr	abcd	0	abcd	sbcd
 adr	add	1	add	sub
 adr	adda	2	adda	cmpa	suba
 adr	addi	3	addi	cmpi	subi
 adr	addq	4	addq	subq
 adr	addx	5	addx	subx
 adr	and	6	and	eor	or
 adr	asl	7	asl	lsl	rol	roxl
 adr	dbcc	8	dbcc
 adr	bchg	9	bchg
 adr	bra	10	bra	bsr	bcc
 adr	bset	11	bset
 adr	chk	12	chk	divs	divu	mils	mulu
 adr	clr	13	clr	neg	negx	not	tst
 adr	cmpm	14	cmpm
 adr	moveq	15	moveq
 adr	exg	16	exg
 adr	ext	17	ext
 adr	jmp	18	jmp	jsr
 adr	lea	19	lea
 adr	link	20	link
 adr	move	21	move
 adr	cmmd2	22	illegal	nop	reset	rte	rtr	rts	trapv
 adr	stop	23	stop
 adr	swap	24	swap
 adr	trap	25	trap
 adr	unlk	26	unlk
 adr	movem	27	movem
 adr	andi	28	andi	eori	ori
 adr	scc	29	nbcd	scc	tas
 adr	bclr	30	bclr
 adr	btst	31	btst
 adr	movea	32	movea
 adr	movep	33	movep
 adr	cmp	34	cmp
 adr	eor	35	eor
 adr	pea	36	pea
 adr	dc	37	dc.w

; \1,\2;\3 = mneumonic (\2 sign bit set as last character)
; \4 = index to tablkeys
; \5,\6 = first word mask
; \7 = no operand allowed if sign set
; \8 = .s allowed (.w not allowed)

OPC	MACRO
 dc.b '\1','\2','\3'+128
 dc.b \4+\7+\8,$\5,$\6
	ENDM

NOC	equ	128	; (bit 7 set) no operand
NW	equ	$40	; (bit 6 set) .w not allowed

tblopc:
 OPC 0,ABC,D,0,C1,0,0,0			;ABCD
 OPC 0,ADD,A,2,D0,C0,0,0		;ADDA
 OPC 0,ADD,I,3,06,0,0,0			;ADDI
 OPC 0,ADD,Q,4,50,0,0,0			;ADDQ
 OPC 0,ADD,X,5,D1,0,0,0			;ADDX
 OPC 0,AD,D,1,D0,00,0,0			;ADD
 OPC 0,AND,I,28,2,0,0,0			;ANDI
 OPC 0,AN,D,6,C0,0,0,0			;AND
 OPC 0,AS,L,7,E1,0,0,0			;ASL
 OPC 0,AS,R,07,E0,0,0,0			;ASR
 OPC 0,BR,A,10,60,0,0,0		;BRA
 OPC 0,BH,I,10,62,0,0,0		;BHI
 OPC 0,BL,S,10,63,0,0,0		;BLS
 OPC 0,BC,C,10,64,0,0,0		;BCC
 OPC 0,BC,S,10,65,0,0,0		;BCS
 OPC 0,BN,E,10,66,0,0,0		;BNE
 OPC 0,BE,Q,10,67,0,0,0		;BEQ
 OPC 0,BV,C,10,68,0,0,0		;BVC
 OPC 0,BV,S,10,69,0,0,0		;BVS
 OPC 0,BP,L,10,6A,0,0,0		;BPL
 OPC 0,BM,I,10,6B,0,0,0		;BMI
 OPC 0,BG,E,10,6C,0,0,0		;BGE
 OPC 0,BL,T,10,6D,0,0,0		;BLT
 OPC 0,BG,T,10,6E,0,0,0		;BGT
 OPC 0,BL,E,10,6F,0,0,0		;BLE
 OPC 0,BCH,G,9,1,40,0,0			;BCHG
 OPC 0,BCL,R,30,1,80,0,0		;BCLR
 OPC 0,BSE,T,11,1,C0,0,0		;BSET
 OPC 0,BS,R,10,61,0,0,0		;BSR
 OPC 0,BTS,T,31,01,0,0,0		;BTST
 OPC 0,B,T,10,60,0,0,0			;BT
 OPC 0,CH,K,12,41,80,0,0		;CHK
 OPC 0,CL,R,13,42,00,0,0		;CLR
 OPC 0,CMP,A,2,B0,C0,0,0		;CMPA
 OPC 0,CMP,I,3,0C,0,0,0			;CMPI
 OPC 0,CMP,M,14,B1,08,0,0		;CMPM
 OPC 0,CM,P,34,B0,0,0,0			;CMP
 OPC 0,DB,T,8,50,C8,0,NW		;DBT
 OPC 0,DB,F,8,51,C8,0,NW		;DBF
 OPC 0,DBR,A,8,51,C8,0,NW		;DBRA
 OPC 0,DBH,I,8,52,C8,0,NW		;DBHI
 OPC 0,DBL,S,8,53,C8,0,NW		;DBLS
 OPC 0,DBC,C,8,54,C8,0,NW		;DBCC
 OPC 0,DBC,S,8,55,C8,0,NW		;DBCS
 OPC 0,DBN,E,8,56,C8,0,NW		;DBNE
 OPC 0,DBE,Q,8,57,C8,0,NW		;DBEQ
 OPC 0,DBV,C,8,58,C8,0,NW		;DBVC
 OPC 0,DBV,S,8,59,C8,0,NW		;DBVS
 OPC 0,DBP,L,8,5A,C8,0,NW		;DBPL
 OPC 0,DBM,I,8,5B,C8,0,NW		;DBMI
 OPC 0,DBG,E,8,5C,C8,0,NW		;DBGE
 OPC 0,DBL,T,8,5D,C8,0,NW		;DBLT
 OPC 0,DBG,T,8,5E,C8,0,NW		;DBGT
 OPC 0,DBL,E,8,5F,C8,0,NW		;DBLE
 OPC 0,D,C,37,0,0,0,0			;DC.W (WORD ONLY)
 OPC 0,DIV,S,12,81,C0,0,0		;DIVS
 OPC 0,DIV,U,12,80,C0,0,0		;DIVU
 OPC 0,EOR,I,28,A,0,0,0			;EORI
 OPC 0,EO,R,35,B1,0,0,0			;EOR
 OPC 0,EX,G,16,C1,0,0,0			;EXG
 OPC 0,EX,T,17,48,0,0,0			;EXT
 OPC ILLE,GA,L,22,4A,FC,NOC,0		;ILLEGAL
 OPC 0,JM,P,18,4E,C0,0,NW		;JMP
 OPC 0,JS,R,18,4E,80,0,NW		;JSR
 OPC 0,LE,A,19,41,C0,0,0		;LEA
 OPC 0,LIN,K,20,4E,50,0,0		;LINK
 OPC 0,LS,L,07,E3,8,0,0			;LSL
 OPC 0,LS,R,07,E2,8,0,0			;LSR
 OPC 0,MOVE,A,32,0,04,0,0		;MOVEA
 OPC 0,MOVE,M,27,48,80,0,0		;MOVEM
 OPC 0,MOVE,P,33,1,08,0,0		;MOVEP
 OPC 0,MOVE,Q,15,70,00,0,0		;MOVEQ
 OPC 0,MOV,E,21,0,0,0,0			;MOVE
 OPC 0,MUL,S,12,C1,C0,0,0		;MULS
 OPC 0,MUL,U,12,C0,C0,0,0		;MULU
 OPC 0,NBC,D,29,48,0,0,0		;NBCD
 OPC 0,NEG,X,13,40,0,0,0		;NEGX
 OPC 0,NE,G,13,44,0,0,0			;NEG
 OPC 0,NO,P,22,4E,71,NOC,0		;NOP
 OPC 0,NO,T,13,46,0,0,0			;NOT
 OPC 0,OR,I,28,00,0,0,0			;ORI
 OPC 0,O,R,6,80,0,0,0			;OR
 OPC 0,PE,A,36,48,40,0,0		;PEA
 OPC 0,RESE,T,22,4E,70,NOC,0		;RESET
 OPC 0,RO,L,7,E7,18,0,0			;ROL
 OPC 0,RO,R,7,E6,18,0,0			;ROR
 OPC 0,ROX,L,7,E5,10,0,0		;ROXL
 OPC 0,ROX,R,7,E4,10,0,0		;ROXR
 OPC 0,RT,E,22,4E,73,NOC,0		;RTE
 OPC 0,RT,R,22,4E,77,NOC,0		;RTR
 OPC 0,RT,S,22,4E,75,NOC,0		;RTS
 OPC 0,SBC,D,0,81,0,0,0			;SBCD
 OPC 0,S,F,29,51,C0,0,0			;SF
 OPC 0,SH,I,29,52,C0,0,0		;SHI
 OPC 0,SL,S,29,53,C0,0,0		;SLS
 OPC 0,SC,C,29,54,C0,0,0		;SCC
 OPC 0,SC,S,29,55,C0,0,0		;SCS
 OPC 0,SN,E,29,56,C0,0,0		;SNE
 OPC 0,SE,Q,29,57,C0,0,0		;SEQ
 OPC 0,SV,C,29,58,C0,0,0		;SVC
 OPC 0,SV,S,29,59,C0,0,0		;SVS
 OPC 0,SP,L,29,5A,C0,0,0		;SPL
 OPC 0,SM,I,29,5B,C0,0,0		;SMI
 OPC 0,SG,E,29,5C,C0,0,0		;SGE
 OPC 0,SL,T,29,5D,C0,0,0		;SLT
 OPC 0,SG,T,29,5E,C0,0,0		;SGT
 OPC 0,SL,E,29,5F,C0,0,0		;SLE
 OPC 0,STO,P,23,4E,72,0,0		;STOP
 OPC 0,S,T,29,50,C0,0,0			;ST
 OPC 0,SUB,A,2,90,C0,0,0		;SUBA
 OPC 0,SUB,I,3,04,0,0,0			;SUBI
 OPC 0,SUB,Q,4,51,0,0,0			;SUBQ
 OPC 0,SUB,X,5,91,0,0,0			;SUBX
 OPC 0,SU,B,1,90,0,0,0			;SUB
 OPC 0,SWA,P,24,48,40,0,0		;SWAP
 OPC 0,TA,S,29,4A,C0,0,0		;TAS
 OPC 0,TRAP,V,22,4E,76,NOC,0		;TRAPV
 OPC 0,TRA,P,25,4E,40,0,0		;TRAP
 OPC 0,TS,T,13,4A,0,0,0			;TST
 OPC 0,UNL,K,26,4E,58,0,0		;UNLK
tblopce:
 
; without label field
; 012345678901234567890123456789012345678901234567890
; aaaaaa dddddddddddddddddddd opcode  operand
; fdata  foc fop

; 012345678901234567890123456789012345678901234567890
; aaaaaa dddddddddddddddddddd llllllll opcode  operand
; fdata  fol foc fop

; a3 = store pointer
; a4 = program counter
; a5 = source ptr beginning
; a6 = source ptr end+1

outbsize	equ	50
fop	equ	10

 dc.w 0

asm_one_line:
;
; a0 = string address
; a1 = temporary buffer address
;
 movem.l d6-d7/a2-a6,-(sp)
 move.l a0,a5
.tab_loop:
 move.b (a0)+,d4
 beq.s .end_replace
 cmp.b #9,d4
 bne.s .tab_loop
 move.b #' ',-1(a0)
 bra.s .tab_loop
.end_replace:
 move.l a5,a0
 move.l a0,a6
 move.l a1,a3
 move.l d0,d4
 link a1,#0-(eske-eskb)
 move.l a1,asm_link(a7)	; save linkage
 move.l a7,a1		; a1 = base register to data
 _JSR strlen
 addq.w #1,d0
 add.w d0,a6
 move.b #' ',(a6)	; insure last char is space
 move.l a3,a0
 moveq #outbsize-1,d0
.l1:
 move.b #' ',(a0)+	; space fill buffer
 dbf d0,.l1
 subq.w #2,a0
 move.l a0,ptrbufe(a1)	; ptr to end of buffer
 move.l d4,pcounter(a1)	; format pc
 moveq #1,d7		; possible error code
 move.l d4,d0
 ror.l #1,d0
 bmi erdone		; pc odd address
 moveq #0,d7		; possible error code
 move.b #2,tnb(a1)		; inz # of bytes = word (def)
 move.w #$40,tlength(a1)	; size = .w (default)
 clr.b tlspec(a1)		; default (size not specified)
 move.l a3,a0		; a0 = store address
.skip_space:
 bsr getcharf		; get past spaces
 cmp.b #' ',d0
 beq.s .skip_space
 subq.w #1,a5		; format op-code
.get_instr:
 bsr getcharf
 move.b d0,(a0)+
 beq.s match_opcodes
 cmp.b #'.',d0
 bne.s .not_period
 move.b (a5),tlspec(a1)	; not default

 cmp.b #'W',(a5)
 beq.s .not_period
 cmp.b #'w',(a5)
 beq.s .not_period

 clr.w tlength(a1)		;size=byte

 cmp.b #'S',(a5)
 beq.s .not_period
 cmp.b #'s',(a5)
 beq.s .not_period

 cmp.b #'B',(a5)
 beq.s .not_period
 cmp.b #'b',(a5)
 beq.s .not_period

 move.w #$80,tlength(a1)	;size=long

 cmp.b #'L',(a5)
 beq.s .not_period
 cmp.b #'l',(a5)
 bne erf

.not_period:
 cmp.b #' ',d0
 bne.s .get_instr	; not space continue
			; search op-code table
match_opcodes:
 lea tblopc(pc),a0	; a0 = ptr to table of codes
match_next_opcode:
 move.l a3,a2		; a3 = start of store buffer
.search_beginning:
 cmp.b #'0',(a0)
 bne.s .next_char
 addq.w #1,a0
.next_char:
 move.b (a0)+,d0	; xxxxxxdd
 ext.w d0		; xxxxssdd  sign extended
 and.b #$7f,d0
 cmp.b (a2)+,d0
 bne.s .no_match	; non-match
 tst.w d0
 bpl.s .next_char	; sign reset. continue
 bra.s match_complete	; match complete
.no_match:
 tst.w d0		; sequence to next code
 bmi.s .next_code
.flush:
 move.b (a0)+,d0
 bpl.s .flush		; finish this op-code
.next_code:
 addq.w #3,a0		; adjust ptr to table
 lea tblopce(pc),a2
 cmp.l a0,a2
 bne.s match_next_opcode

asm_error:
 moveq #-1,d7		; error code
 bra erdone

; get goto index
; get first word mask
match_complete:
 move.b (a2),d0		; must terminate op-code
 beq.s .good_separator
 cmp.b #' ',d0		; with space or period
 beq.s .good_separator
 cmp.b #'.',d0
 bne.s asm_error	;error
.good_separator:
 moveq #0,d0
 move.b (a0)+,d0	; d0 = keys  index
 move.b d0,d1		; d1 = keys (index)
 and.b #$3f,d0		; d0 = index
 add.w d0,d0		; index * two
 move.b (a0)+,d2
 lsl.w #8,d2
 move.b (a0)+,d2	; d2 = first word mask
 move.w d2,tdata(a1)
			; insure .s .w match op-code
 move.b tlspec(a1),d3	; d3 = .n specified
 beq.s .good_size	; not specified
 btst #6,d1
 beq.s .check_s		; w allowed (.s not allowed)
 cmp.b #'W',d3
 beq.s asm_error	; w not allowed
 cmp.b #'w',d3
 beq.s asm_error	; w not allowed
 cmp.b #'B',d3
 beq.s asm_error	; b not allowed
 cmp.b #'b',d3
 beq.s asm_error	; b not allowed
 bra.s .good_size

.check_s:
 cmp.b #'S',d3
 beq.s asm_error	; s not allowed
 cmp.b #'s',d3
 beq.s asm_error	; s not allowed
.good_size:
			; calculate goto address
 lea tblkeys(pc),a0	; a0 = ptr to keys
 move.w 0(a0,d0),d0	; d0 = 16 bit offset
 lea xbase(pc),a2	; a2 = base address
 add d0,a2		; a2 = computed go to address
			; format operand if reguired
 tst.b d1		; look at key
 bmi.s .no_operand	; operand not required
 move.l a3,a0
 add.w #fop,a0		; store pointer
 move.l a0,ptrop(a1)	; pointer to operand (formated)
.skip_space:
; bsr.s getcharf	; d0 = char
 bsr.s getchar
 cmp.b #' ',d0
 beq.s .skip_space	; skip spaces
.backup_rest:
 move.b d0,(a0)+	; move rest of source line
; bsr.s getcharf	; d0 = char
 bsr.s getchar
 cmp.l a5,a6
 bpl.s .backup_rest
 move.l a0,ptrbufe(a1)	; pointer to end formated source
 move.l a0,a6		; a6 = pointer to end of source
.no_operand:		; plantos
 move.l ptrop(a1),a5	; a5 = ptr to operand
; lea tdata+2(a1),a4	; a4 = base addr for data store
; moveq #0,d3		; d3 = offset for data store
 lea tdata(a1),a4	; a4 = base addr for data store
 moveq #2,d3		; d3 = offset for data store
 jmp (a2)		; goto routine
			; d2 = mask
			; d4 = p-counter

comma:
 cmp.b #',',(a5)+
 bne.s er		; not comma
 rts

getchar:
 cmp.l a5,a6
 bmi.s er
 move.b (a5)+,d0
 bne.s .no_zero
 move.b #' ',d0
.no_zero:
 rts

getcharf:
 cmp.l a5,a6
 bmi.s erf
 move.b (a5)+,d0
 cmp.b #'a',d0		; *
 blt.s .end		; *
 cmp.b #'z',d0		; *
 bgt.s .end		; *
 bclr #5,d0		; *
.end:			; *
 tst.b d0
 bne.s .no_zero
 move.b #' ',d0
.no_zero:
 rts

erf:
 move.l a0,a5
er:
 move.l a5,d7		; d7 = error flag
 sub.l a3,d7		; & position of error
erdone:
 moveq #0,d3		; d3 = (zero) byte count
 bra.s asm_end

cmmd2:
mcmmd2:			; no operand sequence
 move.w d2,tdata(a1)
 move.b tnb(a1),d3	; format data
 moveq #0,d7		; reset error flag
asm_end:
 move.l a3,a0		; a0 = ptr to beginning of buffer
 move.l a5,a2		; a1 = ptr to error in buffer
 movem.l tdata(a1),d0-d2	; d0-d2 = data
		; d3 = nb of bytes assembled
 move.l pcounter(a1),d4	; d4 = original pc
 move.w d7,d5		; d5 = position of error
 move.l asm_link(a1),a1
 unlk a1
 move.l a2,a1
;
;		d0 = datas assembles
;		d1 = datas assembles
;		d2 = datas assembles
;		d3 = nombre d'octets (0 si erreur)
;		a0 = pointeur sur l'instruction analysee
;		a1 = pointeur sur l'erreur dans le buffer
;		a4 = pointeur sur les donnees inserees
;
 movem.l (sp)+,d6-d7/a2-a6
 move.l test_instruction(a6),a0
 swap d0
 swap d1
 swap d2
 tst.w d3
 beq .error
 move.w d3,d4
 move.w d3,d5
 move.w d3,d6
 sub.w #10,d6
 lsl.w #3,d6
 neg.w d6
 move.l a0,a1
 clr.l readable_buffer(a6)
 clr.l readable_buffer+4(a6)
 clr.w readable_buffer+8(a6)
 jmp .read_test(pc,d6.w)
 _NOOPTI
.read_test:
 bsr test_if_readable2
 add.w #2,a1
 tst.w readable_buffer(a6)
 bmi .error
 bsr test_if_readable2
 add.w #2,a1
 tst.w readable_buffer(a6)
 bmi .error
 bsr test_if_readable2
 add.w #2,a1
 tst.w readable_buffer(a6)
 bmi .error
 bsr test_if_readable2
 add.w #2,a1
 tst.w readable_buffer(a6)
 bmi .error
 bsr test_if_readable2
 tst.w readable_buffer(a6)
 bmi .error
 move.l a0,a1
 sub.w #10,d5
 lsl.w #2,d5
 neg.w d5
 jmp .write_test(pc,d5.w)
.write_test:
 bsr test_if_writable2
 bmi.s .error 
 addq.w #2,a0 
;
 bsr test_if_writable2
 bmi.s .error
 addq.w #2,a0 
;
 bsr test_if_writable2
 bmi.s .error
 addq.w #2,a0 
;
 bsr test_if_writable2
 bmi.s .error
 addq.w #2,a0 
;
 bsr test_if_writable2
 bmi.s .error
 _OPTI
 move.w d0,(a1)+
 subq.w #2,d3
 beq.s .end
 swap d0
 move.w d0,(a1)+
 subq.w #2,d3
 beq.s .end
 move.w d1,(a1)+
 subq.w #2,d3
 beq.s .end
 swap d1
 move.w d1,(a1)+
 subq.w #2,d3
 beq.s .end
 move.w d2,(a1)+
.end:
 moveq #0,d0
 rts			; return to requestor
.error:
 moveq #-1,d0
 rts			; return to requestor

;    a3 = pointer to start of buffer
;    d6 = number of bytes assembled
;    d7 = error flag (position)

;  size = byte
; dy,dx
; -(ay),-(ax)
; ....rx@.ss...ry@
mabcd:    		; (index 0) abcd sbcd
 tst.b tlspec(a1)
 beq.s mabcd9		; default sixe = byte
; cmp.w #0,tlength(a1)
 tst.w tlength(a1)
 bne er			; not .b
mabcd9:
 move.w #$11,d7
 bsr ea
 bsr comma
 move.l d6,d0
 and.w #7,d0
 or.w d0,d2
 btst #5,d6
 beq.s mabcd55		; d@,d@ mode
 or.w #$0008,d2		; -(a@),-(a@) mode
 move.w #$10,d7
 bsr ea
 and.w #7,d6
 ror.w #7,d6
 or.w d6,d2
 bra cmmd2

mabcd55:
 bsr getregd		; d@,d@
 ror.w #7,d0
 or.w d0,d2
cmmd2s10:
 bra cmmd2


mcmp:			; (index 34)
 bsr eaall
 move.l d6,d4		; d4 = source mode
 bsr.s commas20

 cmp.b #'A',(a5)
 beq madda21		; destination = a@
 cmp.b #'a',(a5)
 beq madda21		; destination = a@

; cmp.b #$3c,d4						; *
; beq.s mcmp56		; source  ....i #<data>,...	; *
 bsr fsize
 move.w #$009,d7
 bsr ea			; d@ + (a@)+
 move.l d6,d0		; mmmrrr
 and.w #$38,d0		; mmm...
 beq.s mcmp39		; destination  d@
 cmp.b #$18,d0
 bne er
 and.w #$f,d6		; (ay)+,(ax)+
 ror.w #7,d6
 or.w d6,d2		; ...ax@.........
 or.w #$0100,d2		; ..1ax@.........
 move.l d4,d0
 and.w #$38,d0
 cmp.w #$18,d0
 bne er			; not (a@)+
 and.w #$f,d4		; ...........1ay@
 or.w d4,d2
 bra cmmd2

;  <ea>,d@
mcmp39:
 ror.w #7,d6
 or.w d6,d2
 or.w d4,d2
 bra.s cmmd2s11

mcmp56:
 move.w #$0c00,d2	; #<data>,<ea> mask = cmpi
 bsr fsize
 bsr eada
 or.w d6,d2
cmmd2s11:
 bra.s cmmd2s10

commas20:
 bra comma

madd:			; (index 1)
 bsr eaall
 move.l d6,d4		; d4 = source mode
 bsr.s commas20

 cmp.b #'A',(a5)
 beq madda21		; destination = a@
 cmp.b #'a',(a5)
 beq madda21		; destination = a@

; cmp.b #$3c,d4
; beq.s madd56		; source  ....i #<data>,...
 bsr fsize
 move.w #$1ff,d7
 bsr ea			; alterable + d@
 move.l d6,d0		; mmmrrr
 and.w #$38,d0		; mmm...
 bne.s madd46		; destination not  d@
			; <ea>,d@
 ror.w #7,d6
 or.w d6,d2
 or.w d4,d2
 bra.s cmmd2s11

madd46:			; d@,<ea>
 or.w #$100,d2 	
 ror.w #7,d4
 or.w d4,d2		; <ea> as destination
 or.w d6,d2		; d@  as source
 bra.s cmmd2s11

madd56:
 move.l d2,d0		; #<data>,<ea>
 move.w #$0600,d2	; mask = addi
 cmp.w #$d000,d0
 beq.s madd58
 move.w #$400,d2	; mask = subi
madd58:
 bsr fsize
 bsr eada		; data alterable only
 or.w d6,d2
 bra.s cmmd2s11

maddi:
 move.l ptrop(a1),a5	; (index 3) cmpi
 bsr fsize
 bsr eaz
 bsr.s commas20
 bsr eada		; data alterable only
 or.w d6,d2
 bra.s cmmd2s11

;  size =  byte, word, long
;  #<data>,sr
;  #<data>,<ea> data alterable only
mandi:			; (index 28) andi eori ori
 bsr fsize
 bsr eaz
 bsr commas20

 cmp.b #'S',(a5)
 beq.s mandi23
 cmp.b #'s',(a5)
 beq.s mandi23

 cmp.b #'C',(a5)
 beq.s .andi_to_c
 cmp.b #'c',(a5)
 beq.s .andi_to_c

.normal_andi:
 bsr eada
 or.w d6,d2
 bra cmmd2s11

.andi_to_c:
 cmp.b #'C',1(a5)
 beq.s .andi_to_cc
 cmp.b #'C',1(a5)
 bne.s .normal_andi
.andi_to_cc:
 cmp.b #'R',2(a5)
 beq.s .andi_to_ccr
 cmp.b #'r',2(a5)
 bne er
.andi_to_ccr:
 and.w #$ffbf,d2
 bra.s andi_ccr_sr

mandi23:
 cmp.b #'R',1(a5)	; #<data>,sr
 beq.s .1
 cmp.b #'r',1(a5)	; #<data>,sr
 bne er
.1:

andi_ccr_sr:
 cmp.w #$0080,tlength(a1)
 beq er			; l not allowed with sr
 or.w #$003c,d2
 addq.w #2,a5		; pointer to end of operand
 bra cmmd2

madda:			; (index 2)
 bsr eaall
 or.w d6,d2
 bsr comma

madda21:
 or.w d6,d2
 move.w tlength(a1),d0
 beq er			; byte not allowed
 lsl.w #1,d0		; w = 011......
 or.w #$00c0,d0		; l = 111......
 or.w d0,d2
 bsr getrega
 ror.w #7,d0
 or.w d0,d2
 bra cmmd2

maddq:			; (index 4)
 bsr fsize
 bsr getimm
 tst.l d0
 beq er			; data = zero
 cmp.b #9,d0
 bpl er			; value too big
 and.w #$7,d0		; make 8 = 0
 ror.w #7,d0		; shift data to bits 9-11
 or.w d0,d2
 bsr comma
 bsr eaa		; alterable addressing
 or.w d6,d2
 move.l d2,d0
 and.w #$c0,d0
 bne.s maddq25
; byte size; address register direct not allowed
 move.l d2,d0
 and.w #$38,d0
 cmp.b #$08,d0
 beq er
maddq25:
 bra cmmd2

; size = byte, word, long
; dy,dx
; -(ay),-(ax)
; ....rx@.ss...ry@
maddx:			; (index 5)
 bsr fsize
 move.w #$11,d7
 bsr ea
 bsr comma
 move.l d6,d0
 and.w #7,d0
 or.w d0,d2
 btst #5,d6
 beq.s maddx5		; d@,d@ mode
 or.w #$0008,d2		; -(a@),-(a@) mode
 move.w #$10,d7
 bsr ea
 and.w #7,d6
 ror.w #7,d6
 or.w d6,d2
 bra cmmd2

maddx5:
 bsr getregd 		; d@,d@
 ror.w #7,d0
 or.w d0,d2
 bra cmmd2

;  size = byte, word, long
; <ea>,d@
; d@,<ea>
mand:
 bsr fsize		; (index 6)
; cmp.b #'#',(a5)
; beq.s mand90
 bsr a5todest		; move a5 to destination
 move.b (a5),d0		; d0 = 1st char of destination
 move.l ptrop(a1),a5	; a5 = pointer to operand

 cmp.b #'D',d0
 beq.s mand77
 cmp.b #'d',d0
 beq.s mand77

 or.w #$0100,d2	; d@,<ea>
 bsr getregd
 ror.w #7,d0
 or.w d0,d2
 bsr comma
 bsr eam		; alterable memory
 or.w d6,d2
 bra cmmd2

mand77:
 bsr eadaddr		; <ea>,d@
 or.w d6,d2
 bsr comma
 bsr getregd
 ror.w #7,d0
 or.w d0,d2
 bra cmmd2

;mand90:
; and.w #$f000,d2
; cmp.w #$c000,d2
; beq.s mand97		; and
; move.w #$0000,d2	; change to "ori"
;mand91:
; bra mandi
;mand97:
; move.w #$0200,d2	; change to "addi"
; bra.s mand91

meor:
 bsr fsize		; (index 35)
 cmp.b #'#',(a5)
 beq.s meor90
 bsr getregd
 ror.w #7,d0
 or.w d0,d2
 bsr comma
 bsr eada		; data alterable addressing
 or.w d6,d2
 bra cmmd2

meor90:
 move.l ptrop(a1),a5	; a5 = pointer to operand
 move.w #$0a00,d2	; change to "eori"
 bra mandi
a5todest:
.again:
 moveq #0,d1		; move a5 to destination
.next_char:
 bsr getchar
 cmp.b #'(',d0
 bne.s .not_parenthesis
 move.l d0,d1
.not_parenthesis:
 cmp.b #')',d0
 beq.s .again
 cmp.b #',',d0
 bne.s .next_char
 tst d1
 bne.s .next_char
 rts

masl:	; (index 7)
; asl lsl  rol  roxl
; masks  e000 e008 e018 e010
; e0c0 e2c0 e6c0 e4c0shift memory

 bsr fsize
 move.b (a5)+,d0
 cmp.b #'#',d0
 bne.s msl200
			;  #<count>,d@
 bsr ev
 cmp.l #8,d0
 bgt er			; greater than 8
 and.b #$7,d0		; make 8 into 0
msl150:
 ror.w #7,d0
 and.w #$f1ff,d2
 or.w d0,d2		; count/reg
 bsr comma
 bsr getregd
 or.w d0,d2
 bra cmmd2

msl200:			; d@,d@

 cmp.b #'D',d0
 beq.s .1		; d@,d@
 cmp.b #'d',d0
 bne.s msl300		; d@,d@
.1:

 or.w #$20,d2
 subq.w #1,a5
 bsr getregd
 bra.s msl150

msl300:			; <ea> shift memory
 subq.w #1,a5
 or.w #$00c0,d2		; size = memory
 and.w #$ffc0,d2	; remove "shift memory" bits
 cmp.w #$0040,tlength(a1)
 bne.s er2		; not .word
 bsr eam
 or.w d6,d2
 bra cmmd2

mscc:
 bsr sizebyte		; (index 29) nbcd scc tas
 bsr eada		; data alterable only
 or.w d6,d2
 bra cmmd2

mbchg:			; (9)
 cmp.b #'#',(a5)
 bne.s mb200
 move.w #$0840,d2	; new op-code mask

mb100:
 addq.w #1,a5
 bsr ev			; evaluate expression
 cmp.l #$ff,d0
 bhi.s er2		; ---> (modulo 32) <--- NO!!!
 move.w d0,tdata+2(a1)
 addq.l #2,d3		; store pointer
 addq.b #2,tnb(a1)

mb105:
 bsr comma
 bsr eada		; destination
 or.w d6,d2
 tst.b tlspec(a1)
 beq.s mb185		; default
 and.w #$0038,d6
 bne.s mb145		; destination <ea> was not d@ 
 cmp.w #$80,tlength(a1)	; destination <ea> was d@
 beq.s mb185		; length is .l
er2:
 bra er

mb145:
 tst.w tlength(a1)
 bne.s er2		; not byte length
mb185:
 bra cmmd2

mb200:
 bsr getregd		; dynamic
 ror.w #7,d0
 or.w d0,d2
 bra.s mb105

mbset:
 cmp.b #'#',(a5)	; (index 11) bclr bset
 bne.s mb200
 move.w #$08c0,d2
 bra.s mb100

mbclr:
 cmp.b #'#',(a5)	; (index 30)
 bne.s mb200
 move.w #$0880,d2
 bra.s mb100

mbtst:
 cmp.b #'#',(a5)	; (index 31)
 bne.s mb200
 move.w #$0800,d2
 bra.s mb100

mdbcc:			; (index 8)
 bsr getregd
 or.w d0,d2
 bsr comma
 bsr.s evsr
 bra.s mbra23
			; size .s  =  .w(default)
			; .l  =  .l
mbra:			; (index 10)
 bsr.s evsr					; ***
 tst.b tlspec(a1)				; ***
 beq.s mbra23					; ***
 cmp.b #'S',tlspec(a1)				; ***
 beq.s .short					; ***
 cmp.b #'s',tlspec(a1)				; ***
 beq.s .short					; ***
 cmp.b #'B',tlspec(a1)				; ***
 beq.s .short					; ***
 cmp.b #'b',tlspec(a1)				; ***
 bne ever						; ***
.short: 
; bsr.s evsr
 cmp.w #$0080,tlength(a1)
 beq.s mbra23		; forced long
 bsr ea8bits		; -128 to +127
; bne.s mbra23		; not 8 bit value
; or.b d5,d2
 bne ever					; ***
 or.b d5,d2					; ***
 bra cmmd2		; short

ever:
 bra er			; error handler

mbra23:
 tst.b tlspec(a1)
 beq.s mbra27
 cmp.w #$0040,tlength(a1)
 beq.s ever		; s specified
mbra27:

 move.l d4,d5		; restore d5
 bsr ea16bits		; -32k to +32k
 move.w d5,tdata+2(a1)
 addq.b #2,tnb(a1)
 bra cmmd2

evsr:
 bsr ev
 cmp.b #' ',(a5)
 bne.s ever		; did not terminate with space  1,1
 move.l d0,d5
 asr.l #1,d0
 bcs.s ever		; odd value
 move.l pcounter(a1),d4
 addq.l #2,d4		; d4 = pc + 2
 sub.l d4,d5
 beq.s ever		; zero; special case error
 move.l d5,d4
 rts

mchk:			; (index 12) chk div mul
 bsr sizeword
 bsr eadaddr		; data addressing only
 or.w d6,d2
 bsr comma
 bsr getregd
 ror.w #7,d0
 or.w d0,d2
 bra cmmd2

mclr:			; (index 13)
 bsr fsize
 bsr eada		; data alterable only
 or.w d6,d2
 bra cmmd2
			; size = byte, word, long
mcmpm:			; (index 14)
 bsr fsize
 move.w #$0008,d7
 bsr ea			; -(a@) only
 and.w #7,d6
 or.w d6,d2
 bsr comma
 move.w #$0008,d7
 bsr ea
 and.w #7,d6
 ror.w #7,d6
 or.w d6,d2
 bra cmmd2

mexg:			; (index 16)
 bsr sizelong
 bsr getregad
 move.l d0,d4		; d4 = reg number
 move.l d1,d5		; d5 = reg type
 bsr comma		; test for comma
 bsr getregad
 cmp.l d1,d5
 beq.s mexg35		; both regs the same
			;  dx,ay  or  ay,dx
 or.w #$88,d2		; mode
 tst.b d1
 bne.s mexg25
 exg.l d0,d4		; swap source & destination
mexg25:
 or.w d0,d2		; ......mmmmmyyy
 ror.w #7,d4
 or.w d4,d2		; ...xxxmmmmmyyy
 bra cmmd2

mexg35:
 or.w #$0040,d2		; op-mode
 tst.b d1
 beq.s mexg25		; dx,dy
 or.w #$0048,d2		; ax,ay
 bra.s mexg25

mext:			; (index 17)
 tst.w tlength(a1)
 beq er			; byte size not allowed
 bsr fsize		; w = ........10......
 add.w #$0040,d2	; l = ........11......
 bsr getregd
 or.w d0,d2
 bra cmmd2

mmovem:			; (index 27)
 move.w tlength(a1),d0	; size bits  76 to 6
 beq er			; byte 00 error
 lsr.w #1,d0		; word 01 0
 and.w #$0040,d0	; long 10 1
 or.w d0,d2
 addq.b #2,tnb(a1)	; number of bytes
 addq.l #2,d3		; force store ptr past mask

 cmp.b #'A',(a5)
 beq.s mmm44
 cmp.b #'a',(a5)
 beq.s mmm44

 cmp.b #'D',(a5)
 beq.s mmm44
 cmp.b #'d',(a5)
 beq.s mmm44

 cmp.b #$B2,(a5)				; ***
 beq.s mmm44					; ***
 cmp.b #',',(a5)				; ***
 beq.s mmm44					; ***
			; <ea>,<register list>  memory to register
 or.w #$0400,d2		; direction bit
 move.w #$7ec,d7	; modes allowed
 bsr ea
 or.w d6,d2
 bsr comma
 bsr.s mmm48
 bra cmmd2
			; <register list>,<ea>  register to memory
mmm44:
			; evaluate destination first
mmm46:
 bsr getchar
 cmp.b #',',d0		; find comma
 bne.s mmm46
 move.w #$1f4,d7	; modes allowed
 bsr ea
 or.w d6,d2
 move.l a5,pendop(a1)	; end of operand
 move.l ptrop(a1),a5
 bsr.s mmm48		; evaluate registers
 move.l pendop(a1),a5	; pointer to end of operand
 bra cmmd2

; d6 = correspondence mask
; d4 = control  $ff '-' '/'
mmm48:
 moveq #0,d6		; mask
 cmp.b #$B2,(a5)				; ***
 beq.s no_movem_reg				; ***
 cmp.b #',',(a5)				; ***
 beq.s no_movem_reg				; ***
 moveq #-1,d4		; control = $ff
rl111:
 bsr getchar
 cmp.b #',',d0
 beq.s rl114		; done. found comma
 cmp.b #' ',d0
 bne.s rl115		; not space
rl114:
 rts			; done

no_movem_reg:					; ***
 bsr getchar					; ***
 cmp.b #',',d0					; ***
 beq.s .end					; ***
 cmp.b #' ',d0					; ***
 bne.s no_movem_reg				; ***
.end:						; ***
 clr.w 2(a1)					; ***
 rts						; ***

rl115:
 cmp.b #'/',d0
 bne.s rl444
 tst.b d4		; control
 bmi er
 move.l d0,d4		; control = '/'
rl333:
 bsr getregad
 or.b d0,d1		; d1 = bit position
 move.b d1,d5		; d5 = last register entered
 bsr.s setbit
 bra.s rl111

rl444:
 cmp.b #'-',d0
 bne.s rl666
 cmp.b #'/',d4		; control
 bne er
 move.l d0,d4		; control = '-'
 bsr getregad
 or.b d0,d1
 move.l d1,d7		; d7 = now register
 move.b d5,d0		; d5 = last reg
 eor.b d1,d0
 and.b #$38,d0
 bne er			; not matched set
 cmp.b d1,d5
 bpl er
rl555:
 addq.l #1,d5
 move.l d5,d1
 bsr.s setbit
 cmp.b d7,d5
 bmi.s rl555
 bra.s rl111

rl666:
 tst.b d4
 bpl er
 move.b #'/',d4		; control = '/'
 subq.w #1,a5
 bra.s rl333

setbit:
 lea mtbl(pc),a0	; set bit in correspondence mask
 move.l d2,d0
 and.w #$38,d0
 cmp.w #$20,d0
 bne.s rl30		; not predecrement
 move.b (a0,d1),d1	; d1 = bit  (for sure)
rl30:
 bset d1,d6
 move.w d6,tdata+2(a1)	; save correspondence mask
 rts

mtbl:
 dc.b 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

; d@,<data>(a@)
; <data>(a@),d@
; (a@),d@ forced to 0(a@),d0
; d@,(a@) forced to d0,0(a@)
;
;  size = word, long

mmovep:			; (index 33)
 move.w tlength(a1),d0
 beq er			; byte not allowed
 lsr.w #1,d0
 and.w #$0040,d0
 or.w d0,d2		; size
 move.w #$25,d7
 bsr ea			; d6 = mode
 bsr comma
 move.l d6,d0
 and.w #$38,d0
 cmp.b #$0,d0
 beq.s mmp344		; d@,<data>(a@)
			; <data>(a@),d@
 bsr getregd
 ror.w #7,d0
 or.w d0,d2		; d@
 bra.s mmp348

mmp344:
 or.w #$0080,d2		; register to memory
 ror.w #7,d6
 or.w d6,d2		; d@
 move.w #$24,d7
 bsr ea
mmp348:
 move.l d6,d0
 and.w #7,d6
 or.w d6,d2		; a@
 and.w #$38,d0
 cmp.b #$10,d0
 bne.s mmp368		; <data>(a@)
 clr.w tdata+2(a1)	; <data> forced to zero "(a@)"
 addq.b #2,tnb(a1)	; number of bytes
 addq.l #2,d3		; store pointer
mmp368:
 bra cmmd2

mmoveq:			; (index 34)
 bsr getimm
 move.l d0,d5
 bsr ea8bits		; -128 to +127
 bne er
 or.b d5,d2		; d5 = value
 bsr comma
 bsr getregd		; d@
 ror.w #7,d0
mmq20:
 or.w d0,d2
 bsr.s sizelong
 bra cmmd2

sizelong:
 tst.b tlspec(a1)	; must be .long
 beq.s si201		; default size ok
 cmp.w #$0080,tlength(a1)
 bne.s er10		; not .long
si201:
 rts

sizeword:
 cmp.w #$0040,tlength(a1)		; must be .word
 beq.s si201		; rts
er10:
 bra er

sizebyte:
 tst.b tlspec(a1)
 beq.s si222		; default size ok
 tst.w tlength(a1)
 bne.s er10
si222:
 rts

mmove:			; (index 21)

 cmp.b #'S',(a5)
 beq.s .1
 cmp.b #'s',(a5)
 bne.s mm40
.1:

 move.w #$40c0,d2	; sr,<ea>
 addq.w #1,a5

 cmp.b #'R',(a5)+
 beq.s .2
 cmp.b #'r',-1(a5)
 bne.s er10
.2:

 bsr comma
 bsr eada		; data alterable only (destination)
mm315:
 or.w d6,d2
 bsr.s sizeword
 bra cmmd2

mm40:

 cmp.b #'U',(a5)
 beq.s .1
 cmp.b #'u',(a5)
 bne.s mm50
.1:

 addq.w #1,a5

 cmp.b #'S',(a5)+
 beq.s .2
 cmp.b #'s',-1(a5)
 bne.s er10
.2:

 cmp.b #'P',(a5)+
 beq.s .3
 cmp.b #'p',-1(a5)
 bne.s er10
.3:

 bsr comma
 move.w #$4e68,d2	; usp,a@
 bsr getrega
 bra mmq20

; get exceptions from destination
mm50:
 bsr a5todest		; move a5 to destination
 move.b (a5)+,d0

 cmp.b #'C',d0
 beq.s .1
 cmp.b #'c',d0
 bne.s mm60
.1:

 cmp.b #'C',(a5)+
 beq.s .2
 cmp.b #'c',-1(a5)
 bne er10
.2:

 cmp.b #'R',(a5)+
 beq.s .3
 cmp.b #'r',-1(a5)
 bne er10
.3:

 move.w #$44c0,d2	; <ea>,ccr
mm508:
 move.l a5,pendop(a1)	; save pointer
 move.l ptrop(a1),a5	; a5 = pointer to operand
 bsr eadaddr		; data addressing only (source)
 move.l pendop(a1),a5
 bra mm315

mm60:

 cmp.b #'S',d0
 beq.s .1
 cmp.b #'s',d0
 bne.s mm70
.1:

 move.w #$46c0,d2	; <ea>,sr

 cmp.b #'R',(a5)+
 beq.s .2
 cmp.b #'r',-1(a5)
 bne er
.2:

 bra.s mm508

mm70:

 cmp.b #'U',d0
 beq.s .1
 cmp.b #'u',d0
 bne.s mm80
.1:

 move.w #$4e60,d2	; a@,usp

 cmp.b #'S',(a5)+
 beq.s .2
 cmp.b #'s',-1(a5)
 bne er
.2:

 cmp.b #'P',(a5)+
 beq.s .3
 cmp.b #'p',-1(a5)
 bne er
.3:

 move.l a5,pendop(a1)
 move.l ptrop(a1),a5
 bsr getrega
 move.l pendop(a1),a5	; restore a5
 bra mmq20

mm80:
 move.l ptrop(a1),a5	; a5 = pointer to source field
 bsr fsize		; get size (bits  7 - 6)
 lsl.w #6,d2		; adjust to(bits 13-12)
 btst #13,d2
 bne.s mm804		; l 10 to 10
 add.w #$1000,d2	; w 01 to 11
 or.w #$1000,d2		; b 00 to 01
mm804:
 bsr eaall		; source; all modes allowed
 or.w d6,d2
; if bite size. "address register direct" not allowed
 move.l d2,d0
 and.w #$3000,d0
 cmp.w #$1000,d0
 bne.s mm806		; not .b size
 and.b #$38,d6
 cmp.b #$08,d6
 beq er
mm806:
 bsr comma
 move.w #$1ff,d7	; data alterable + a@
 bsr ea
 move.l d6,d0		; destination
 and.w #$0038,d0
 cmp.w #$0008,d0
 beq.s mmovea1		; a@ make movea
; position register and mode of destination
mm825:
 ror.l #3,d6		; rrr............. .............mmm
 ror.w #3,d6		; mmm.............
 swap d6		; mmm............. rrr.............
 rol.w #3,d6		; .............rrr
 rol.l #1,d6		; mm.............. ............rrrm
 rol.l #8,d6		; ............... ....rrrmmm......
 or.w d6,d2
 bra cmmd2

mmovea1:
 moveq #0,d3
 move.b #2,tnb(a1)

mmovea:			; (index 32)
 move.l ptrop(a1),a5	; a5 = pointer to operand
 move.w tlength(a1),d2	; d0 = size
 beq er			; byte not allowed
 lsl.w #6,d2		; size
 btst #12,d2
 beq.s mma225		; l = ..10
 or.w #$3000,d2		; w = ..11
mma225:
 bsr eaall		; all modes allowed
 or.w d6,d2
 bsr comma
 move.w #$0002,d7	; a@ only
 bsr ea
 bra.s mm825

mjmp:			; (index 18)
 tst.b tlspec(a1)
 beq.s mjmp32		; default (allow either .s or .l) 1,1
 move.w tlength(a1),d0
 beq er			; b not allowed
 move.w #$6e4,d7	; d7 = modes allowed
 cmp.w #$40,d0
 beq.s mjmp22		; s specified (.w accepted)
 move.w #$8764,d7	; mode for .l
mjmp22:
 bsr ea
 bra.s mjmp42

mjmp32:
 bsr eac		; control addressing only
mjmp42:
 or.w d6,d2
 bra cmmd2
			; size = long
mlea:			; (index 19)
 bsr sizelong
 bsr eac		; control addressing only
 or.w d6,d2
 bsr comma
 bsr getrega
 ror.w #7,d0
 or.w d0,d2
 bra cmmd2
			; size = lg
mpea:			; (index 36)
 bsr sizelong
 bsr eac		; control addressing only
 or.w d6,d2
 bra cmmd2

mswap:			; (index 24)
			; size word
 cmp.w  #$0040,tlength(a1)
 bne er

 bsr getregd		; d@ only
 or.w d0,d2
 bra cmmd2

getimm:
 cmp.b #'#',(a5)+
 bne er
 bsr ev			; evaluate expression
 rts			; d0 = value

mlink:
 bsr getrega		; (index 20)
 or.w d0,d2
 bsr comma
 bsr.s getimm
 move.l d0,d5
 bsr ea16bits		; -32k to +32k
 move.w d0,tdata+2(a1)
 addq.b #2,tnb(a1)
 bra cmmd2

mstop:			; (index 23)* unsized
 bsr.s getimm
 move.w d0,tdata+2(a1)
 addq.b #2,tnb(a1)
 bra cmmd2

mtrap:
			; (index 25)
 bsr.s getimm
 cmp.l #16,d0
 bcc er
 or.w d0,d2
 bra cmmd2

munlk:			; (index 26)
			; nsized
 bsr getrega
 or.w d0,d2
 bra cmmd2

mdc:			; (index 37) .w only allowed
 move.b tlspec(a1),d0
 bclr #5,d0
 cmp.b #'W',d0
 bne er
 bsr ev
 tst.w d1
 bmi er
 move.l d0,d5
 move d5,d2
 bsr ea16bit		; only .w ao
 move.b #2,tnb(a1)
 bra cmmd2

 ENDC

;a3=buffer de fenetre
;a4=@ ou ecrire
;d7=no de fenetre
;d6=taille reelle de la ligne
;d5=taille max de la ligne
ascii_alt_e:
	movem.l	d5-d7/a2-a4,-(sp)
	bsr	alt_e_get_curwind
	lea	0(a0,d0.w),a3		;descr
	move.l	a1,a4			;@
	move.w	2(a3),y_pos(a6)		;premiere ligne
.loop:	tst.b	play_mac_flag(a6)
	beq.s	.noplay1
	move.l	cur_play_mac_addr(a6),a0
	move.b	(a0)+,d0
	beq	.playend
	cmp.b	#'`',d0
	beq.s	.playkey
.noplay1:	lea	line_buffer(a6),a2
	move.l	a2,a0
	move.l	a4,a1
	moveq	#0,d6
	move.w	line_buffer_size(a6),d5
.l1:	bsr	test_if_readable5
	tst.b	readable_buffer(a6)
	bne	.no
	move.b	(a1),d0
	beq.s	.eol
	cmp.b	#13,d0
	beq.s	.eol
	cmp.b	#10,d0
	beq.s	.eol
	move.b	d0,(a0)+
	addq.w	#1,a1
	addq.w	#1,d6
	dbf	d5,.l1
.eol:	clr.b	(a0)
	tst.b	play_mac_flag(a6)
	beq.s	.noplay2
	_JSR	copy_next_mac_eval		;a2=buffer @
	bmi	.no		;syntax error in macro
	bgt.s	.noplay2		;?
	move.l	a2,a1
	bra	.playcr		;ok
.playkey:	_JSR	text_to_scan
	addq.l	#1,d1
	add.l	d1,cur_play_mac_addr(a6)
	swap	d0
	cmp.w	#$0001,d0		;esc
	beq	.edit_end
	cmp.w	#$0812,d0		;alt_e
	beq	.edit_end
	cmp.w	#$0050,d0		;down
	beq	.down
	cmp.w	#$0048,d0		;up
	beq	.up
	cmp.w	#$0150,d0		;pgdn
	beq	.sft_down
	cmp.w	#$0148,d0		;pgup
	beq	.sft_up
	sub.l	d1,cur_play_mac_addr(a6)
	_JSR	flash
	bra	.playend
.noplay2:	move.l	a2,a1
	move.w	(a3),d0
	addq.w	#1,d0
	move.w	4(a3),d1
	subq.w	#2,d1
	st	m_line(a6)
	_JSR	edit_ascii_line
	sf	m_line(a6)
	bmi	.edit_end
	subq.w	#2,d0
	beq	.up
	subq.w	#1,d0
	beq	.down
	subq.w	#1,d0
	beq	.sft_up
	subq.w	#1,d0
	beq	.sft_down 
;.cr:
	clr.b	(a0)		;recopier la ligne a l'@
	move.l	a1,a0
	_JSR	recmacline
.playcr:	move.l	a1,a0
        	move.l	a4,a1
.l2:	move.b	(a0)+,d0
	beq.s	.redraw
	move.b	d0,(a1)+
	subq.w	#1,d6
	bra.s	.l2
.redraw:	subq.w	#1,d6		;padder avec des 0
	bmi.s	.crdown
.l3:	clr.b	(a1)+
	dbf	d6,.l3
	bra.s	.crdown
.down:	moveq	#$50,d0
	swap	d0
	bsr	alte_record_key
.crdown:	move.l	a4,a1
	moveq	#1,d0
	bsr	down_line_ascii
	addq.w	#1,y_pos(a6)
	bra.s	.all_redraw
.up:	moveq	#$48,d0
	swap	d0
	bsr	alte_record_key
	move.l	a4,a1
	bsr	up_line_ascii
	subq.w	#1,y_pos(a6)
;	bra.s	.all_redraw
.all_redraw:
	move.w	y_pos(a6),d0
	move.w	2(a3),d1
	cmp.w	d1,d0
	blt.s	.force_first_line
	add.w	6(a3),d1
	subq.w	#2,d1	
	cmp.w	d1,d0
	bgt.s	.force_last_line
	bra.s	.let_window
.force_last_line:
	move.w	2(a3),d0
	add.w	6(a3),d0
	subq.w	#2,d0
	move.w	d0,y_pos(a6)
	move.l	a1,-(sp)
	move.l	10(a3),a1
	moveq	#1,d0
	bsr	down_line_ascii
	move.l	a1,10(a3)
	move.l	(sp)+,a1
	bra.s	.let_window
.sft_up:	move.l	#$01480000,d0
	bsr	alte_record_key
	move.l	a4,a1
;	move.l	10(a3),a1
	move.w	6(a3),d0
	subq.w	#2,d0
	bsr	up_page_ascii
;	bra.s	.redraw_window
	bra.s	.force_first_line
.sft_down:
	move.l	#$01500000,d0
	bsr	alte_record_key
	move.l	a4,a1
;	move.l	10(a3),a1
	move.w	6(a3),d0
	subq.w	#2,d0
	bsr	down_page_ascii
;	bra.s	.redraw_window
;	bra.s	.force_first_line
.force_first_line:
	move.w	2(a3),y_pos(a6)
;	bra.s	.redraw_window
.redraw_window:
	move.l	a1,10(a3)
.let_window:
	move.l	a1,a4
	move.l	x_pos(a6),-(sp)
	bsr	redraw_curwind
	move.l	(sp)+,x_pos(a6)
	bra	.loop
.playend:	sf	play_mac_flag(a6)
.edit_end:
	bsr	alte_record_esc
	bsr	redraw_curwind
	bra.s	.end
.no:	_JSR	flash
.end:	movem.l	(sp)+,d5-d7/a2-a4
	rts
;  #] Alt E:

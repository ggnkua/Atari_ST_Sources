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

;  #[ Redraw switch:
redraw_inside_window:
 move.w d0,window_redrawed(a6)
 lea w1_db(a6),a0
 lsl.w #4,d0
 add.w d0,a0
redraw_inside_window2:
	tst.b	8(a0)
	beq.s	.26
	move.w	$e(a0),d1
	cmp.w	#ZOMWIND_TYPE,d1
	bgt.s	.not_implemented
	add.w	d1,d1
	move.w	.redraw_table(pc,d1.w),d1
	jmp	.redraw_table(pc,d1.w)
.redraw_table:
	dc.w	.registers-.redraw_table
	dc.w	.disassembly-.redraw_table
	dc.w	.memory_dump-.redraw_table
	dc.w	.ascii-.redraw_table
	dc.w	.not_implemented-.redraw_table
	IFNE	sourcedebug
	dc.w	.src-.redraw_table
	dc.w	.var-.redraw_table
	dc.w	.ins-.redraw_table
	ELSEIF
	dc.w	.not_implemented-.redraw_table
	dc.w	.not_implemented-.redraw_table
	dc.w	.not_implemented-.redraw_table
	ENDC	;de sourcedebug
	dc.w	.26-.redraw_table

.not_implemented:
	lea not_implemented_wtype_text,a1
	bra clear_window
.26:
	rts

;  #] Redraw switch:
;  #[ Registers:

.registers:
 movem.l d0-a6,-(sp)
 move.l a0,d4

 ;registres d0-d7
 moveq #1,d6
 lea d0_buf(a6),a1
 lea save_d0_buf(a6),a2
 lea d0_flag(a6),a3
 move.l a3,a4
 moveq #$f,d5
.29:
 sf (a3)
 cmpm.l (a1)+,(a2)+
 beq.s .25
 bgt.s .sup1
 st (a3)
 bra.s .25
.sup1:
 move.b d6,(a3)
.25:
 addq.w #1,a3
 dbf d5,.29

 ;registres ssp-pc-sr
 lea ssp_buf(a6),a1
 lea save_ssp_buf(a6),a2
 sf ssp_flag(a6)
 cmp.l (a1)+,(a2)+
 beq.s .31
 st ssp_flag(a6)
.31:
 sf sr_flag(a6)
 cmp.w (a1)+,(a2)+
 beq.s .32
 st sr_flag(a6)
.32:
 sf pc_flag(a6)
 cmp.l (a1)+,(a2)+
 beq.s .33
 st pc_flag(a6)
.33:

 ;registres 68030
 IFNE _68030
 tst.b chip_type(a6)
 beq .no_68030_stars
 moveq #2,d5
 lea isp_flag(a6),a3
.st1:
 sf (a3)
 cmp.l (a1)+,(a2)+
 beq.s .no_st1
 st (a3)
.no_st1:
 addq.w #1,a3
 dbf d5,.st1

 sf (a3)+
 cmp.w (a1)+,(a2)+
 beq.s .no_sfc
 st -1(a3)
.no_sfc:
 sf (a3)+
 cmp.w (a1)+,(a2)+
 beq.s .no_dfc
 st -1(a3)
.no_dfc:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .no_cacr
 st -1(a3)
.no_cacr:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .no_caar
 st -1(a3)
.no_caar:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .crp2
 st -1(a3)
.crp2:
 cmp.l (a1)+,(a2)+
 beq.s .crp3
 st -1(a3)
.crp3:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .srp2
 st -1(a3)
.srp2:
 cmp.l (a1)+,(a2)+
 beq.s .srp3
 st -1(a3)
.srp3:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .no_tc
 st -1(a3)
.no_tc:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .tt02
 st -1(a3)
.tt02:
; cmp.l (a1)+,(a2)+
; beq.s .tt03
; st -1(a3)
;.tt03:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .tt12
 st -1(a3)
.tt12:
; cmp.l (a1)+,(a2)+
; beq.s .tt13
; st -1(a3)
;.tt13:
 sf (a3)+
 cmp.w (a1)+,(a2)+
 beq.s .no_mmusr
 st -1(a3)
.no_mmusr:
 moveq #7,d5
.fpx_star_test:
 sf (a3)+
; cmp.l (a1)+,(a2)+
 cmp.w (a1)+,(a2)+
 beq.s .no_fp0
 st -1(a3)
.no_fp0:
 addq.w #2,a1
 addq.w #2,a2
 cmp.l (a1)+,(a2)+
 beq.s .no_fp1
 st -1(a3)
.no_fp1:
 cmp.l (a1)+,(a2)+
 beq.s .no_fp2
 st -1(a3)
.no_fp2:
 dbf d5,.fpx_star_test
 moveq #2,d5
.fpxx_star_test:
 sf (a3)+
 cmp.l (a1)+,(a2)+
 beq.s .no_fpxx
 st -1(a3)
.no_fpxx:
 dbf d5,.fpxx_star_test
.no_68030_stars:
 ENDC ; de _68030
 lea misc_dat,a3
 lea misc_dat_buffer(a6),a2
 moveq #8,d0
.80:
 move.l (a3)+,(a2)+
 dbf d0,.80
 sub.w #36,a2
 IFNE	ATARIST
 move.w sr,d0
 lsr.w	#8,d0
 and.w	#7,d0
 ENDC
 IFNE	AMIGA
 move.w	current_ipl(a6),d0
 ENDC
 add.w #"0",d0
 move.b d0,3(a2)
 IFNE ATARIST
 IFNE ATARITT
 move.b #'Y',7(a2)
 ELSEIF
 move.b #' ',7(a2)
 ENDC
 move.b #'Y',11(a2)
 move.b #'Y',15(a2)
 move.b #'Y',19(a2)
 move.b #'Y',23(a2)
 IFNE ATARITT
 move.b #'Y',27(a2)
 move.b #'Y',31(a2)
 move.b #'Y',35(a2)
 lea external_mfp_ctl_struct(a6),a3
 tst.b (a3)+
 bne.s ._30
 move.b #'N',7(a2)
._30:
 tst.b (a3)+
 bne.s ._31
 move.b #'N',11(a2)
._31:
 tst.b (a3)+
 bne.s ._32
 move.b #'N',15(a2)
._32:
 tst.b (a3)
 bne.s ._33
 move.b #'N',19(a2)
._33:
;				TT timers
 move.b #'N',23(a2)
 move.b #'N',27(a2)
 move.b #'N',31(a2)
 move.b #'N',35(a2)
 ELSEIF
 tst.b play_mac_flag(a6)
 beq.s .no_play
 move.b #'P',7(a2)
.no_play:
 tst.b rec_mac_flag(a6)
 beq.s .no_rec
 move.b #'R',7(a2)
.no_rec:
 lea external_mfp_ctl_struct(a6),a3
 tst.b (a3)+
 bne.s ._30
 move.b #'N',11(a2)
._30:
 tst.b (a3)+
 bne.s ._31
 move.b #'N',15(a2)
._31:
 tst.b (a3)+
 bne.s ._32
 move.b #'N',19(a2)
._32:
 tst.b (a3)
 bne.s ._33
 move.b #'N',23(a2)
._33:
 ENDC ;d'ATARITT
 ENDC ;d'ATARIST
 IFNE AMIGA
 move.b #' ',15(a2) ; macro
 move.b #'Y',19(a2) ; timers
 move.b #'Y',23(a2)
 move.b	#'Y',27(a2)
 move.b	#'Y',31(a2)
 tst.b play_mac_flag(a6)
 beq.s .no_play
 move.b #'P',15(a2)
.no_play:
 tst.b rec_mac_flag(a6)
 beq.s .no_rec
 move.b #'R',15(a2)
.no_rec:
 lea external_mfp_ctl_struct(a6),a3
 tst.b (a3)+
 bne.s ._32
 move.b #'N',19(a2)
._32:
 tst.b (a3)+
 bne.s ._33
 move.b #'N',23(a2)
._33:
 tst.b	(a3)+
 bne.s	._34_0
 move.b	#'N',27(a2)
._34_0:
 tst.b	(a3)
 bne.s	._35_0
 move.b	#'N',31(a2)
._35_0:
 move.w	internal_intena(a6),d0
 moveq	#3,d6
.digit:
 move.w	d0,d7
 move.w	#10,d5
 and.w	#15,d7
 cmp.w	d5,d7
 bge.s	.sup10
 add.b	#'0',d7
 move.b d7,8(a2,d6.w)
 lsr.w	#4,d0
 dbf	d6,.digit
 bra.s	.suite
.sup10:
 add.b	#'A'-10,d7
 move.b	d7,8(a2,d6.w)
 lsr.w	#4,d0
 dbf	d6,.digit
.suite:
 ENDC ;d'AMIGA
 sf optimise_address(a6)
 move.w (a0),x_pos(a6)
 move.w 2(a0),y_pos(a6)
 lea reg_wind_buf(a6),a3
 move.w window_redrawed(a6),d0
 lsl.w #2,d0
 move.l 0(a3,d0.w),current_window_reg_pos(a6)
 move.w 2(a3,d0.w),-(sp)
 lea a1_flag(a6),a3
 move.w 6(a0),d0
 add.w current_window_reg_pos+2(a6),d0
 moveq #9,d6
 cmp.w d6,d0
 bge.s ._no_reg_clip
 move.w d0,d6
._no_reg_clip:
 subq.w #2,d6
 moveq #0,d7
 lea a1_buf(a6),a4
._2:
 move.l (a2)+,-(sp)
 move.l -(a4),a5
 move.l a5,d5
 lea $10(a5),a5
 IFNE _68020!_68030
 tst.b 34(a3)
 ELSEIF
 tst.b 10(a3)
 ENDC
 beq.s ._40
 lea -$10(a5),a5
 lea tmp_buffer(a6),a0
 move.l a0,-(sp)
 moveq #38,d0
._41:
 moveq	#'*',d1
 move.l a1,-(sp)
 move.l a5,a1
 bsr test_if_readable5
 move.l (sp)+,a1
 addq.w #1,a5
 tst.b readable_buffer(a6)
 bne.s ._42
._60:
 move.b -1(a5),d1
 bne.s ._42
 moveq	#' ',d1
._42:
 move.b d1,(a0)+
 dbf d0,._41
 clr.b (a0)
 bra.s ._35
._40:
 move.w #7,d0
 btst #0,d5
 beq.s ._34
 addq.w #1,a5
._34:
 subq.w #2,a5
 move.l a5,-(sp)
 dbf d0,._34
 btst #0,d5
 beq.s ._35
 subq.w #1,a5
 move.l a5,-(sp)
._35:

 move.l (a4),-(sp)

 moveq	#' ',d1
 tst.b	-(a3)
 beq.s	._3
 bgt.s	.sup2_1
 moveq	#1,d1
 bra.s	._3
.sup2_1:
 moveq	#2,d1
._3:
 move.w	d1,-(sp)

 move.w	d7,d0
 add.w	#'0',d0
 move.w	d0,-(sp)
 move.l	-$20(a4),a5
 move.l	a5,-(sp)
 move.l	a5,-(sp)

 moveq	#' ',d1
 tst.b	-8(a3)
 beq.s	._4
 bgt.s	.sup2_2
 moveq	#1,d1
 bra.s ._4
.sup2_2:
 moveq	#2,d1
._4:
 move.w	d1,-(sp)

 move.w	d0,-(sp)
 lea	even_reg_window_format_pointer,a0
 IFNE	_68020!_68030
 tst.b	35(a3)
 ELSEIF
 tst.b	11(a3)
 ENDC
 beq.s	._5
 addq.w	#8,a0
._5:
 btst	#0,d5
 beq.s	._38
 addq.w	#4,a0
._38:
 move.l (a0),-(sp)
 subq.w #1,current_window_reg_pos+2(a6)
 bpl.s .no_print
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print:
 lea	32(sp),sp
 IFNE _68020!_68030
 tst.b	35(a3)
 ELSEIF
 tst.b	11(a3)
 ENDC
 bne.s ._37
 lea 28(sp),sp
; lea 60(sp),sp
; IFNE _68020!_68030
; tst.b 35(a3)
; ELSEIF
; tst.b 12(a3)
; ENDC
; beq.s ._47
; sub.w #$1c,sp
; bra.s ._37
;._47:
 btst #0,d5
 beq.s ._37
 addq.w #4,sp
._37:
 addq.w #8,a4
 addq.w #2,a3
 addq.w #1,d7
 dbf d6,._2
 move.l d4,a0
 move.w 6(a0),d0
 add.w (sp),d0
 cmp.w #$a,d0
 blt ._end_registers

 move.l ssp_buf(a6),a5
 add.w #$10,a5
 move.l (a2)+,-(sp)
 moveq #7,d0
._20:
 subq.l #2,a5
 move.l a5,-(sp)
 dbf d0,._20
 move.l ssp_buf(a6),-(sp)
	lea	ssp_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)

 move.w sr_buf(a6),d0
 lea tmp_buffer(a6),a0
 bsr build_ascii_sr
 pea tmp_buffer(a6)
 move.w sr_buf(a6),-(sp)
	lea	sr_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)

 pea even_sr_ssp_format
 btst #0,ssp_buf+3(a6)
 beq.s ._19
 move.l #odd_sr_ssp_format,(sp)
._19:
 subq.w #1,current_window_reg_pos+2(a6)
 bpl.s .no_print2
 lea line_buffer(a6),a0
 bsr	sprintf3
 lea line_buffer(a6),a0
 bsr .right_shift
 _JSR print_instruction
 addq.w #1,y_pos(a6)
.no_print2:
 lea 54(sp),sp
 move.l d4,a0
 move.w 6(a0),d0
 add.w (sp),d0
 cmp.w #$b,d0
 blt ._end_registers
 lea disassemble_datas(a6),a1
 move.l pc_buf(a6),a2
 move.l a2,d0
 bclr #0,d0
; move.l d0,a2
 move.l d0,a1
; move.l a2,test_instruction(a6)
 move.l a1,test_instruction(a6)
 lea tmp_buffer(a6),a0
; move.l a0,dc_w_line_buffer(a6)
; bsr test_if_readable4
; tst.l readable_buffer(a6)
; bne .50
; tst.l readable_buffer+4(a6)
; bne .50
; tst.w readable_buffer+8(a6)
; bne .50
; move.l (a2)+,(a1)
; move.l (a2)+,4(a1)
; move.w (a2)+,8(a1)
 st optimise_address(a6)
; lea instruction_size(a6),a5
; clr.w (a5)
 _JSR disassemble_line
 _JSR display_break
 tst.b analyse_s_onoff(a6)
 beq .100
 move.b #" ",(a0)+
 move.b #":",(a0)+
 sf optimise_address(a6)
 lea analyse_s_data(a6),a1
 _JSR dat_to_asc_l_3
 move.b #" ",(a0)+
 move.b #"(",(a0)+
 move.l analyse_s_data(a6),a1		; test_if_readable
 rept 3
 _JSR dat_to_asc_w_3
 addq.w #2,a1
 endr
 _JSR dat_to_asc_w_3
 sub.w #$10,a0
 move.b s_data_size(a6),d0
 ext.w d0
.101:
 tst.b (a0)+
 tst.b (a0)+
 dbf d0,.101
 move.b #")",(a0)+
 tst.b analyse_d_onoff(a6)
 beq.s .100
 move.b #3,(a0)+
 lea analyse_d_data(a6),a1
 _JSR dat_to_asc_l_3
 move.b #" ",(a0)+
 move.b #"(",(a0)+
 move.l analyse_d_data(a6),a1
 _JSR dat_to_asc_w_3
 addq.w #2,a1
 _JSR dat_to_asc_w_3
 subq.w #8,a0
 move.b d_data_size(a6),d0
 ext.w d0
.102:
 tst.b (a0)+
 tst.b (a0)+
 dbf d0,.102
 move.b #")",(a0)+
.100:
 clr.b (a0)
 bra.s .51
.50:
 move.w #"**",(a0)+
 clr.b (a0)

.51:
 pea	tmp_buffer(a6)
 move.l pc_buf(a6),-(sp)
	lea	pc_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)

 pea	pc_format
 sf	optimise_address(a6)
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print3
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print3:
 lea	14(sp),sp
						; 68030 registers
 IFNE _68030
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$c,d0
 blt	._end_registers
 move.l	cacr_buf(a6),d2
 bsr	build_ascii_cacr
 pea	tmp_buffer(a6)
 move.l	cacr_buf(a6),-(sp)
	lea	cacr_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.l	isp_buf(a6),-(sp)
	lea	isp_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 pea	isp_cacr_format
 lea	line_buffer(a6),a0
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print4
 sf	optimise_address(a6)
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print4:
 lea	20(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$d,d0
 blt	._end_registers
 move.l	caar_buf(a6),-(sp)
	lea	caar_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.l	msp_buf(a6),-(sp)
	lea	msp_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 pea	msp_caar_format
 lea	line_buffer(a6),a0				; ***
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print5
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print5:
 lea	16(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$e,d0
 blt	._end_registers
 move.w	dfc_buf(a6),-(sp)
 and.w	#7,(sp)
	lea	dfc_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	sfc_buf(a6),-(sp)
 and.w	#7,(sp)
	lea	sfc_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.l	vbr_buf(a6),-(sp)
	lea	vbr_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 pea	vbr_sfc_dfc_format
 lea	line_buffer(a6),a0				; ***
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print6
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print6:
 lea	18(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$f,d0
 blt	._end_registers
 pea	pmmu_message_text
 pea	pmmu_message_format
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print7
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print7:
 lea	8(sp),sp

 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$10,d0
 blt	._end_registers

 move.l	tc_buf(a6),d2
 bsr	build_ascii_tc
 pea	tmp_buffer(a6)
 move.l	tc_buf(a6),-(sp)
	lea	tc_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	mmusr_buf(a6),d2
 bsr	build_ascii_mmusr
 move.l	d1,-(sp)
 move.l	d0,-(sp)
 move.w	mmusr_buf(a6),-(sp)
	lea	mmusr_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 pea	mmusr_tc_format
 lea	line_buffer(a6),a0
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print8
 sf	optimise_address(a6)
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print8:
 lea	26(sp),sp
 move.l d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$11,d0
 blt	._end_registers
 lea	tmp_buffer(a6),a0
 clr.b	(a0)
 move.l	tc_buf(a6),d0
 bpl.s	.no_crp
 lea	crp_tree_address_text,a1
 exg	a0,a1
 _JSR	strcpy
 add.w	d0,a1
 move.l	crp_buf+4(a6),d0
 and.l	#$fffffff0,d0
 move.l	a1,a0
 subq.w	#1,a0
 _JSR	hex_to_asc_lu
 clr.b	(a0)
 lea	tmp_buffer(a6),a0
.no_crp:
 move.l	a0,-(sp)
 move.l	crp_buf+4(a6),-(sp)
 move.l	crp_buf(a6),-(sp)
	lea	crp_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.l	tt0_buf(a6),-(sp)
	lea	tt0_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 pea	tt0_crp_format
 lea	line_buffer(a6),a0
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print9
 sf	optimise_address(a6)
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print9:
 lea	24(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$12,d0
 blt	._end_registers
 lea	tmp_buffer(a6),a0
 clr.b	(a0)
 move.l	tc_buf(a6),d0
 bpl.s	.no_srp
 lea	srp_tree_address_text,a1
 exg	a0,a1
 _JSR	strcpy
 add.w	d0,a1
 btst	#1,tc_buf(a6)
 bne.s	.srp_allowed
.srp_not_allowed:
 move.l	crp_buf+4(a6),d0
 bra.s	.put_srp
.srp_allowed:
 move.l	srp_buf+4(a6),d0
.put_srp:
 and.l	#$fffffff0,d0
 move.l	a1,a0
 subq.w	#1,a0
 _JSR	hex_to_asc_lu
 clr.b	(a0)
 lea	tmp_buffer(a6),a0
.no_srp:
 move.l	a0,-(sp)
 move.l	srp_buf+4(a6),-(sp)
 move.l	srp_buf(a6),-(sp)
	lea	srp_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.l	tt1_buf(a6),-(sp)
	lea	tt1_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 pea	tt1_srp_format
 lea	line_buffer(a6),a0
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print10
 sf	optimise_address(a6)
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print10:
 lea	24(sp),sp

 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$13,d0
 blt	._end_registers
 pea	fpu_message_text
 pea	fpu_message_format
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print11
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print11:
 lea	8(sp),sp

 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$14,d0
 blt	._end_registers
 move.l	fp4_buf+8(a6),-(sp)
 move.l	fp4_buf+4(a6),-(sp)
 move.l	fp4_buf(a6),-(sp)
	lea	fp4_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w #'4',-(sp)
 move.l fp0_buf+8(a6),-(sp)
 move.l fp0_buf+4(a6),-(sp)
 move.l fp0_buf(a6),-(sp)
	lea	fp0_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	#'0',-(sp)
 lea	fpx_format_table,a0
 tst.b	fp0_float_flag(a6)
 beq.s	._fp0
 addq.w	#8,a0
._fp0:
 tst.b	fp4_float_flag(a6)
 beq.s	._fp4
 addq.w	#4,a0
._fp4:
 move.l	(a0),-(sp)
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print12
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print12:
 lea	36(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$15,d0
 blt	._end_registers
 move.l	fp5_buf+8(a6),-(sp)
 move.l	fp5_buf+4(a6),-(sp)
 move.l	fp5_buf(a6),-(sp)
	lea	fp5_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	#'5',-(sp)
 move.l	fp1_buf+8(a6),-(sp)
 move.l	fp1_buf+4(a6),-(sp)
 move.l	fp1_buf(a6),-(sp)
	lea	fp1_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	#'1',-(sp)
 lea	fpx_format_table,a0
 tst.b	fp1_float_flag(a6)
 beq.s	._fp1
 addq.w	#8,a0
._fp1:
 tst.b	fp5_float_flag(a6)
 beq.s ._fp5
 addq.w	#4,a0
._fp5:
 move.l (a0),-(sp)
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print13
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print13:
 lea	36(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$16,d0
 blt	._end_registers
 move.l	fp6_buf+8(a6),-(sp)
 move.l	fp6_buf+4(a6),-(sp)
 move.l	fp6_buf(a6),-(sp)
	lea	fp6_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w #'6',-(sp)
 move.l fp2_buf+8(a6),-(sp)
 move.l fp2_buf+4(a6),-(sp)
 move.l fp2_buf(a6),-(sp)
	lea	fp2_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	#'2',-(sp)
 lea	fpx_format_table,a0
 tst.b	fp2_float_flag(a6)
 beq.s	._fp2
 addq.w	#8,a0
._fp2:
 tst.b	fp6_float_flag(a6)
 beq.s	._fp6
 addq.w	#4,a0
._fp6:
 move.l	(a0),-(sp)
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print14
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print14:
 lea	36(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$17,d0
 blt	._end_registers
 move.l	fp7_buf+8(a6),-(sp)
 move.l	fp7_buf+4(a6),-(sp)
 move.l	fp7_buf(a6),-(sp)
	lea	fp7_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	#'7',-(sp)
 move.l	fp3_buf+8(a6),-(sp)
 move.l	fp3_buf+4(a6),-(sp)
 move.l	fp3_buf(a6),-(sp)
	lea	fp3_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w	#'3',-(sp)
 lea	fpx_format_table,a0
 tst.b	fp3_float_flag(a6)
 beq.s	._fp3
 addq.w	#8,a0
._fp3:
 tst.b	fp7_float_flag(a6)
 beq.s	._fp7
 addq.w	#4,a0
._fp7:
 move.l	(a0),-(sp)
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print15
 sf	optimise_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
 addq.w	#1,y_pos(a6)
.no_print15:
 lea	36(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$18,d0
 blt	._end_registers
 move.l	fpiar_buf(a6),-(sp)
	lea	fpiar_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.w fpcr_buf(a6),-(sp)
	lea	fpcr_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 move.l fpsr_buf(a6),-(sp)
	lea	fpsr_flag(a6),a0
	bsr	.set_moved_flag
	move.w	d0,-(sp)
 pea	fpsr_fpcr_fpiar_format
 subq.w	#1,current_window_reg_pos+2(a6)
 bpl.s	.no_print16
 sf	optimize_address(a6)
 lea	line_buffer(a6),a0
 bsr	sprintf3
 lea	line_buffer(a6),a0
 bsr	.right_shift
 _JSR	print_instruction
.no_print16:
 lea	20(sp),sp
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 cmp.w	#$19,d0
 blt.s	._end_registers
 sub.w	#$19,d0
 ELSEIF
 subq.w	#1,y_pos(a6)
 move.l	d4,a0
 move.w	6(a0),d0
 add.w	(sp),d0
 sub.w	#$c,d0			; $c
 bmi.s	._end_registers
 ENDC	;de _68030
.clear_bottom_of_window:
 addq.w	#1,y_pos(a6)
 lea	line_buffer(a6),a0
 clr.b	(a0)
 _JSR	print_instruction
 dbf	d0,.clear_bottom_of_window
._end_registers:
 addq.w	#2,sp
 movem.l	(sp)+,d0-a6
 rts

.right_shift:
 move.w current_window_reg_pos(a6),d0 
 beq.s .no_right_shift
._right_shift:
 move.b 0(a0,d0.w),(a0)+
 tst.b 0(a0,d0.w)
 bne.s ._right_shift
 clr.b (a0)
.no_right_shift:
 rts

.set_moved_flag:
	moveq	#' ',d0
	tst.b	(a0)
	beq.s	.end_set_moved
	bgt.s	.moved_upper
	moveq	#1,d0
	bra.s	.end_set_moved
.moved_upper:
	moveq	#2,d0
.end_set_moved:
	rts

;  #] Registers:
;  #[ Disassembly:

.disassembly:
 movem.l d6-d7/a0/a2-a5,-(sp)
; sf watch_subroutine_flag(a6)
 sf bsr_jsr_flag(a6)
 cmp.w #$10,d0
 bne .42
 tst.b relock_pc_flag(a6)
 beq.s .24
 lea lock_m2_buffer(a6),a3
 move.l pc_buf(a6),d7
.another:
 tst.l 4(a3)
 beq.s .not_found
 cmp.l (a3)+,d7
 bne.s .another
 bra.s .before_24
.not_found:
 move.l pc_buf(a6),test_instruction(a6)
 move.l pc_buf(a6),$a(a0)
.before_24:
 tst.l (a3)
 beq.s .not_found
.24:
 move.l $a(a0),test_instruction(a6)
 bclr #0,test_instruction+3(a6)
 lea lock_m2_buffer(a6),a3
 addq.w #4,a3
 lea shift_up_down_table(a6),a1
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 move.l test_instruction(a6),0(a1,d0.w)
 move.w 6(a0),d1
 subq.w #1,d1
 add.w d1,d1
 ext.l d1
 sub.l d1,0(a1,d0.w)
 lea test_instruction(a6),a1
 move.w 6(a0),d7
 subq.w #2,d7
 move.l (a0),x_pos(a6)
 move.l (a1),-4(a3)
 movem.l d7/a0/a1/a3,-(sp)
 bsr disassemble
 addq.w #1,y_pos(a6)
 lea shift_up_down_table(a6),a0
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 move.l test_instruction(a6),$c(a0,d0.w)
 movem.l (sp)+,d7/a0/a1/a3
 move.l (a1),(a3)+
 subq.w #1,d7
 bmi.s .60
.21:
 move.l (a1),-4(a3)
 movem.l d7/a0/a1/a3,-(sp)
 bsr disassemble
 movem.l (sp)+,d7/a0/a1/a3
 move.l (a1),(a3)+
 addq.w #1,y_pos(a6)
 dbf d7,.21
.60:
 clr.l -4(a3)
 lea shift_up_down_table(a6),a0
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 move.l test_instruction(a6),4(a0,d0.w)
 movem.l (sp)+,d6-d7/a0/a2-a5
 rts
.42:
 st relock_flag(a6)
 bsr _lock
 sf relock_flag(a6)
 move.l $a(a0),test_instruction(a6)
 bclr #0,test_instruction+3(a6)
 lea shift_up_down_table(a6),a1
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 move.l test_instruction(a6),0(a1,d0.w)
 move.w 6(a0),d1
 subq.w #1,d1
 add.w d1,d1
 ext.l d1
 sub.l d1,0(a1,d0.w)
 move.w 6(a0),d7
 subq.w #2,d7
 move.l (a0),x_pos(a6)
 movem.l d7/a0/a1/a3,-(sp)
 bsr disassemble
 addq.w #1,y_pos(a6)
 lea shift_up_down_table(a6),a0
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 move.l test_instruction(a6),$c(a0,d0.w)
 movem.l (sp)+,d7/a0/a1/a3
 subq.w #1,d7
 bmi.s .61
.43:
 movem.l d7/a0/a1/a3,-(sp)
 bsr disassemble
 movem.l (sp)+,d7/a0/a1/a3
 addq.w #1,y_pos(a6)
 dbf d7,.43
.61:
 lea shift_up_down_table(a6),a0
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 move.l test_instruction(a6),4(a0,d0.w)
 movem.l (sp)+,d6/d7/a0/a2-a5
 rts

;  #] Disassembly:
;  #[ Memory dump:

.memory_dump:
 movem.l d3-d7/a2-a5,-(sp)
 sf optimise_address(a6)
 sf memory_parity_flag(a6)
 st relock_flag(a6)
 bsr _lock
 sf relock_flag(a6)
 lea $a(a0),a1
 move.w memory_loop_value(a6),-(sp)
 move.w 4(a0),d1
 sub.w (a0),d1
 bsr get_m_l_v
 move.w d6,memory_loop_value(a6)
 move.l (a1),-(sp)
 btst #0,3(sp)
 beq.s .23
 st memory_parity_flag(a6)
.23:
 move.l a1,-(sp)
 move.l (a0),x_pos(a6)
 move.w 6(a0),d4
 subq.w #2,d4
.3:
 move.l a1,-(sp)
 lea line_buffer(a6),a0
 _JSR init_buffer
 move.l (a1),a4
 _JSR dat_to_asc_l_3
 st allowed_memory_flag(a6)
 move.b #" ",(a0)+
 move.l a4,-(sp)
 move.w memory_loop_value(a6),d6
.1:
 move.l a4,a1
 _JSR dat_to_asc_w_3
 tst.b readable_buffer(a6)
 beq.s .38
 move.b #"*",-4(a0)
 move.b #"*",-3(a0)
.38:
 tst.b readable_buffer+1(a6)
 beq.s .39
 move.b #"*",-2(a0)
 move.b #"*",-1(a0)
.39:
 move.b #" ",(a0)+
 tst.b memory_parity_flag(a6)
 beq.s .5
 move.b -2(a0),-1(a0)
 move.b -3(a0),-2(a0)
 move.b #" ",-3(a0)
.5:
 addq.w #2,a4
 dbf d6,.1
 move.b #" ",(a0)+
 move.l (sp)+,a4
 move.w memory_loop_value(a6),d6
 add.w d6,d6
 addq.w #1,d6
.2:
 _JSR test_if_readable3
 tst.b readable_buffer(a6)
 beq.s .37
 move.b #"*",d0
 bra.s .4
.37:
 move.b (a4),d0
 bne.s .4
 move.b #" ",d0
.4:
 move.b d0,(a0)+
 addq.w #1,a4
 dbf d6,.2
 sf allowed_memory_flag(a6)
 movem.l d0/a0-a1,-(sp)
 lea w1_db(a6),a0
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 add.w d0,a0
 clr.b (a0)+
 movem.l (sp)+,d0/a0-a1
 _JSR print_instruction
 addq.w #1,y_pos(a6)
 move.l (sp)+,a1
 move.w memory_loop_value(a6),d0
 add.w d0,d0
 addq.w #2,d0
 ext.l d0
 add.l d0,(a1)
 dbf d4,.3
 move.l (sp)+,a1
 move.l (sp)+,(a1)
 move.w (sp)+,memory_loop_value(a6)
 movem.l (sp)+,d3-d7/a2-a5
 rts

;  #] Memory dump:
;  #[ Ascii:

;a0=@ du descripteur de fenetre
.ascii:
	movem.l	a2-a3,-(sp)
	move.w	window_redrawed(a6),d0
	asl.w	#1,d0
	lea	asc_wind_buf(a6),a1
	move.w	0(a1,d0.w),d0
	move.l	$a(a0),a1
	suba.l	a2,a2
	bsr	print_ascii
	movem.l	(sp)+,a2-a3
	rts
;  #] Ascii:
	IFNE	sourcedebug
;  #[ Source:
.src:
	movem.l	a2-a4,-(sp)
	move.l	a0,a4
	tst.w	source_type(a6)
	bne.s	.good_src
.clr_src:
	move.l	a4,a0
	lea	no_src_text,a1
	bsr	clear_window
	bra.s	.src_end
.good_src:
	move.w	window_redrawed(a6),d0
	mulu.w	#_SRCWIND_SIZEOF,d0
	lea	src_wind_buf(a6),a3
	add.w	d0,a3

	tst.l	(a3)
	beq.s	.force_src_relock
	move.l	source_ptr(a6),a0
;	cmp.l	(a3),a0
;	bgt.s	.force_src_relock
	add.l	source_len(a6),a0
;	cmp.l	(a3),a0
;	blt.s	.force_src_relock
	tst.b	relock_pc_flag(a6)
	beq.s	.print_src
.force_src_relock:
	_JSR	update_source_pc_ptr
	move.l	source_pc_ptr(a6),d0
	beq.s	.clr_src
	move.l	d0,a0
	cmp.l	(a3),a0
	blt.s	.relock_src
	cmp.l	_SRCWIND_ENDPTR(a3),a0
	bge.s	.relock_src
	bra.s	.print_src
.relock_src:
	move.l	a0,(a3)
	move.l	source_ptr(a6),a1
	exg	a0,a1
	_JSR	count_source_lines
	move.l	d0,_SRCWIND_LINENB(a3)
.print_src:
	move.l	(a3),a1
	move.w	_SRCWIND_OFF(a3),d0
	move.l	a4,a0
	move.l	_SRCWIND_LINENB(a3),d1
	move.l	source_ptr(a6),a2
	add.l	source_len(a6),a2
	subq.w	#1,a2
	bsr	print_source_ascii
	move.l	a0,_SRCWIND_ENDPTR(a3)
	move.w	d0,_SRCWIND_OFFMAX(a3)
.src_end:
	movem.l	(sp)+,a2-a4
	rts
;  #] Source:
;  #[ Var:
;Input:
;a0=@ du descripteur de fenetre
;In:
;d7=nb de lignes
;d6=offset d'affichage
;d4=var len
;d3=nb de colonnes
;a5=var window struct
;a4=var struct
.var:
	movem.l	d3-d7/a2-a5,-(sp)

	tst.w	source_type(a6)
	bne.s	.good_var
	lea	no_vars_text,a1
	bsr	clear_window
	bra.s	.var_end
.good_var:
	moveq	#0,d0
	move.w	_GENWIND_W(a0),d0
	sub.w	(a0),d0
	subq.w	#2,d0
	move.l	d0,curwind_columns(a6)
	move.w	_GENWIND_H(a0),d7
	subq.w	#2,d7
	move.l	(a0),x_pos(a6)
	lea	line_buffer(a6),a3

;	tst.b	relock_pc_flag(a6)
;	beq.s	.dont_calc_vars_pc
	move.w	window_redrawed(a6),d0
	_JSR	update_wind_tcvars
;.dont_calc_vars_pc:
	lea	var_wind_buf(a6),a5
	move.w	window_redrawed(a6),d0
	mulu	#_VARWIND_SIZEOF,d0
	add.w	d0,a5
	move.l	_VARWIND_PTR(a5),a4
	move.l	a4,d0
	beq.s	.out_var
	move.l	_VARWIND_NB(a5),d4
	move.l	_VARWIND_NBMAX(a5),d5
	beq.s	.out_var
	move.w	_VARWIND_OFF(a5),d6
	clr.w	_VARWIND_OFFMAX(a5)

.next_var:
	move.l	(a4),a0
	move.l	a3,a1
	move.l	a5,a2
	move.w	d6,d0
	bsr	print_source_var
	subq.w	#1,d7
	bmi.s	.var_end
.more_var:
	addq.w	#TCVARS_SIZEOF,a4
	addq.l	#1,d4
	cmp.l	d5,d4
	blt.s	.next_var
.out_var:
	clr.b	(a3)
.clear_var:
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d7,.clear_var
.var_end:
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;  #] Var:
;  #[ Ins:
;Input:
;a0=@ du descripteur de fenetre
;In:
;d7=nb de lignes
;d6=offset d'affichage
;d4=var len
;d3=nb de colonnes
;a5=var window struct
;a4=var struct
.ins:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	a0,a2
	tst.w	source_type(a6)
	bne.s	.good_ins
.clear:
	move.l	a2,a0
	lea	no_vars_text,a1
	bsr	clear_window
	bra.s	.ins_end
.good_ins:
	moveq	#0,d0
	move.w	4(a0),d0
	sub.w	(a0),d0
	subq.w	#2,d0
	move.l	d0,curwind_columns(a6)
	move.w	6(a0),d7
	subq.w	#2,d7
	move.l	(a0),x_pos(a6)

	lea	ins_wind_buf(a6),a5
	move.w	window_redrawed(a6),d0
	mulu	#_INSWIND_SIZEOF,d0
	add.w	d0,a5
	move.l	(a5),d5
	move.l	d5,d0
	sub.l	text_buf(a6),d0
	bmi.s	.clear
	bsr	get_var_by_offset
	move.l	a0,d0
	beq.s	.clear
	clr.w	_INSWIND_OFFMAX(a5)
	lea	line_buffer(a6),a1
	move.l	a5,a2
	move.w	_INSWIND_OFF(a5),d0
	move.w	d7,d1
	move.l	d5,d2
	bsr	inspect_source_var
.ins_end:
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;  #] Ins:
	ENDC	;de sourcedebug
;a0=gen wind buf
;a1=text to print
clear_window:
	movem.l	d7/a2,-(sp)
	move.l	(a0),x_pos(a6)
	move.w	6(a0),d7
	subq.w	#2,d7
	lea	line_buffer(a6),a0
	exg	a0,a1
	_JSR	strcpy
	_JSR	print_instruction
	subq.w	#1,d7
	bmi.s	.end
	addq.w	#1,y_pos(a6)
	clr.b	line_buffer(a6)
.l1:
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d7,.l1
.end:
	movem.l	(sp)+,d7/a2
	rts

update_title:
 movem.l d3-d7/a2-a5,-(sp)
 bsr get_noaddr_wind
 add.w d0,a0
 move.w d2,d0
 move.w 0(a0),upper_x(a6)
 move.w 2(a0),upper_y(a6)
 move.w 4(a0),lower_x(a6)
 move.w 6(a0),lower_y(a6)
 lea line_buffer(a6),a0
 cmp.w #5,d0
 beq.s .no_name
 move.b d0,(a0)
 add.b #'1',(a0)+
 move.b #'/',(a0)+
.no_name:
 add.w d1,d1
 move.w .title_table(pc,d1.w),d1
 ;ds d0 le numero de fenetre
 ;ds a0 le buffer ASCII
 ;construire
 jsr .title_table(pc,d1.w)
 ;afficher
 lea line_buffer(a6),a0
 _JSR print_title
 movem.l (sp)+,d3-d7/a2-a5
 rts
.title_table:
 dc.w .title0-.title_table
 dc.w .title1-.title_table
 dc.w .title2-.title_table
 dc.w .title3-.title_table
 IFNE sourcedebug
 dc.w .title4-.title_table
 dc.w .title5-.title_table
 dc.w .title6-.title_table
 dc.w .title7-.title_table
 ELSEIF
 dc.w .title4-.title_table
 dc.w .title4-.title_table
 dc.w .title4-.title_table
 dc.w .title4-.title_table
 ENDC ;de sourcedebug
 dc.w .title8-.title_table
 
.title0:
 lea .reg_title(pc),a1
 exg a0,a1
 bra strcpy3
.reg_title:	dc.b	"REGS",0
 even
 
.title1:
 move.w d0,-(sp)
 lea .dis_title(pc),a1
 exg a0,a1
 bsr strcpy3
 move.w (sp)+,d1
 bra.s .test_lock 
.dis_title:	dc.b	"DIS",0
 even
 
.title2:
 move.w d0,-(sp)
 lea .hex_title(pc),a1
 exg a0,a1
 bsr strcpy3
 move.w (sp)+,d1
 bra.s .test_lock
.hex_title:	dc.b	"HEXA",0
 even
 
.title3:
 move.w d0,-(sp)
 lea .asc_title(pc),a1
 exg a0,a1
 bsr strcpy3
 move.w (sp)+,d1
 bra.s .test_lock
.asc_title:	dc.b	"ASC",0
 even
 
.test_lock:
 lea lock_buffer(a6),a2
 mulu #200,d1
 add.w d1,a2
 tst.b (a2)
 beq.s .end_title
 add.w d0,a1
 move.b #'/',-1(a1)
 move.l a2,a0
 bsr strcpy3
.end_title:
 rts
 
.title4:
 lea .unimp_title(pc),a1
 exg a0,a1
 bra strcpy3
.unimp_title:	dc.b	"NONE",0
 even

	IFNE	sourcedebug 
.title5:
	move.l	source_name_addr(a6),d0
	bne.s	.src_name
	lea	.none_text(pc),a1
	move.l	a1,d0
.src_name:
	move.l	d0,-(sp)
	pea	.src_title_format(pc)
	bsr	sprintf3
	addq.w	#8,sp
	rts
.src_title_format:	dc.b	"SRC:%s",0
.none_text:	dc.b	"NONE",0
	even
 
;glob,loc,stat
.title6:
	lea	var_wind_buf(a6),a1
	mulu	#_VARWIND_SIZEOF,d0
	move.w	_VARWIND_TYPE(a1,d0.w),d0
	add.w	d0,d0
	move.w	.scope_var_table(pc,d0.w),d0
	lea	.scope_var_table(pc,d0.w),a1
	exg	a0,a1
	bra	strcpy3
.scope_var_table:
	dc.w	.notype_text-.scope_var_table
	dc.w	.gtype_text-.scope_var_table
	dc.w	.stype_text-.scope_var_table
	dc.w	.ltype_text-.scope_var_table
.notype_text:	dc.b	"No variables",0
.gtype_text:	dc.b	"Globals",0
.stype_text:	dc.b	"Statics",0
.ltype_text:	dc.b	"Locals",0
	even
 
;@
.title7:
	move.w	d0,d3
	lea	.ins_text(pc),a1
	exg	a0,a1
	bsr	strcpy3
	lea	-1(a1,d0.w),a3
	lea	ins_wind_buf(a6),a2
	mulu	#_INSWIND_SIZEOF,d3
	add.w	d3,a2
	move.l	_INSWIND_PTR(a2),d3
	beq.s	.end
	move.l	d3,d0
	move.l	a3,a0
	bsr	sprint_var_name
	move.l	d3,-(sp)
	pea	.ins_format(pc)
	bsr	sprintf3
	addq.w	#8,sp
.end:
	rts
.ins_text:	dc.b	"Ins/",0
.ins_format:	dc.b	"(0x%=lx)",0
	ENDC	;de sourcedebug

.title8:
 move.l big_title_addr(a6),a1
 exg a0,a1
 bra strcpy3

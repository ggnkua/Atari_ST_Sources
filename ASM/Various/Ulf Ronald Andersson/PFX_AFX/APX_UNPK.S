;File name:	APX_UNPK.S		Revised:	1993.06.07
;Disassembler:	Ulf Ronald Andersson	Disassembled:	1992.08.24
;
;
APX_unpack:	;call with:  d0->basepage,  d1=packsize
;The basepage must have:  bp_selfbeg_p,  bp_selfend_p
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d0,a5			;a5-> basepage
	move.l	a5,a0
	lea	$100(a0),a0
	move.l	a0,bp_textbeg_p(a5)
	clr.l	bp_textlen(a5)
	move.l	a0,bp_databeg_p(a5)
	move.l	d1,bp_datalen(a5)
	addq.l	#3,d1
	and.b	#$FC,d1
	lea	(a0,d1.l),a0
	move.l	a0,bp_bss_beg_p(a5)
	clr.l	bp_bss_len(a5)
	move.l	bp_selfend_p(a5),a0
	lea	-1024(a0),a0		;a0-> end of TPA - 1024
	move.l	a0,a2			;a2-> end of TPA - 1024
	move.l	bp_bss_beg_p(a5),a1	;a1-> bss == end of data area
	move.l	bp_datalen(a5),d0	;d0 = data_size
	addq.l	#3,d0
	and.b	#$FC,d0
	move.l	a0,a4
	suba.l	d0,a4			;a4-> database = end of TPA - 1024 - datasize
	lsr.l	#4,d0			;d0 = data_size/16
.move_up_lp:					;loop start to move data up
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	subq.l	#1,d0
	bpl.s	.move_up_lp		;loop back to move data up
	movep.w	14(a4),d4
	move.b	13(a4),d4
	swap	d4
	movep.w	12(a4),d4
	move.b	11(a4),d4		;d4 = unpack counter = original filesize
	moveq	#2,d0
	add.b	(a4),d0			;d0 = size of header + 2  (for checksum size)
	adda	d0,a4			;a4 -> packed data beyond header and checksum
	move.l	bp_textbeg_p(a5),a6	;a6-> unpacked code destination base
	move	#$FEE-1,d5
	move	d5,d0
	moveq	#32,d1
.fill_space_lp:
	move.b	d1,(a6)+
	dbra	d0,.fill_space_lp	
	move.l	a6,a3			;a3-> code_base + $FEE
	moveq	#0,d7
	move.l	a6,d5
	sub.l	#$FEE-1,d5		;d5-> code_base  constant in unpack
	move	#$FFF,d3		;d3 = $FFF       constant in unpack
	dbra	d7,.unpack_lp_2
.unpack_lp_1:
	move.b	(a4)+,d6
	moveq	#7,d7
.unpack_lp_2:
	lsr.b	#1,d6
	bcc.s	.LC8
	move.b	(a4)+,(a6)+
	subq.l	#1,d4
	ble.s	APX_unpacked
	dbra	d7,.unpack_lp_2
	bra.s	.unpack_lp_1
;
.LC8:
	movep.w	1(a4),d0
	lsr.w	#4,d0
	move.b	(a4)+,d0
	move.l	a6,d1
	sub.l	d5,d1
	and	d3,d1
	sub	d1,d0
	neg	d0
	and	d3,d0
	neg	d0
	lea	-1(a6,d0.w),a0
	moveq	#15,d1
	and.b	(a4)+,d1
	addq	#2,d1
	moveq	#1,d0
	add	d1,d0
.LEC:
	move.b	(a0)+,(a6)+
	dbra	d1,.LEC
	sub.l	d0,d4
	ble.s	APX_unpacked
	dbra	d7,.unpack_lp_2
	bra.s	.unpack_lp_1
;
;
APX_unpacked:
APX_fixup:
	move.l	bp_textbeg_p(a5),d3	;d3-> unpacked code base
	movem.l	ph_textlen(a3),d4-d7
; d4 = textlen,  d5 = datalen,  d6 = bss_len,  d7 = symblen
	lea	ph_textbeg(a3),a0	;a0 = textbeg_p of program
	move.l	a0,a4			;a4 = textbeg_p of program
	tst	26(a3)		;relocation flag ???
	bne.s	.relocated
	lea	0(a0,d4.l),a1		;a1 -> data of program
	adda.l	d5,a1			;a1 -> bss of program = symbol dump
	adda.l	d7,a1			;a1 -> relocation data of program
	move.l	(a1)+,d1		;d1 = offset to first relocation
	beq.s	.relocated
	adda.l	d1,a0			;a0 -> first relocation
	moveq	#0,d1
.relocate_lp_1:
	add.l	d3,(a0)			;add textbeg_p to relocation value
.relocate_lp_2:
	move.b	(a1)+,d1		;d1 = byte offset to next relocation
	beq.s	.relocated		;byte 0 means finished
	cmp.b	#1,d1			;byte 1 means extra offset 254
	bne.s	.L13A			;else go relocate at offset
	lea	254(a0),a0		;a0 -> extra offset base
	bra.s	.relocate_lp_2
;
.L13A:
	adda	d1,a0			;a0 -> next relocation
	bra.s	.relocate_lp_1
;
.relocated:
	move.l	d4,bp_textlen(a5)
	move.l	d5,bp_datalen(a5)
	move.l	d6,bp_bss_len(a5)
	move.l	d4,d7
	add.l	d5,d7
	lsr.l	#4,d7
	addq.l	#1,d7			;d7 = (textlen + datalen) / 16 + 1
	add.l	d3,d4			;d4 -> data area of program
	move.l	d4,bp_databeg_p(a5)
	add.l	d5,d4			;d4 -> bss area of program
	move.l	d4,bp_bss_beg_p(a5)
	btst	#0,25(a3)
	sne	d1
	lea	28(a3),a1
	move.l	bp_textbeg_p(a5),a0
	sub.l	a0,d4
	lsr.l	#4,d4
.move_down_lp:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	subq.l	#1,d4
	bpl.s	.move_down_lp
	move.l	bp_bss_beg_p(a5),a0
	adda.l	bp_bss_len(a5),a0
	tst.b	d1
	bne.s	.L18E
	move.l	bp_selfend_p(a5),a0
.L18E:
	move.l	a0,d0
	sub.l	bp_bss_beg_p(a5),d0
	move.l	d0,d1
	lsr.l	#7,d0
	lsr.l	#3,d0
	beq.s	.L20E
	move.l	d1,-(sp)
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
.L1B8:				;loop to clear 1 KByte per passage
	rept	19
	movem.l	d1-d7/a1-a6,-(a0)
	endr
	movem.l	d1-d7/a1-a2,-(a0)
	subq.l	#1,d0
	bne.s	.L1B8		;loop back for each KByte to be cleared
	move.l	(sp)+,d1
.L20E:
	and	#$3FF,d1
	bra.s	.L216
;
.L214:				;loop to clear remainder < 1 KByte
	clr.b	-(a0)
.L216:
	dbra	d1,.L214	;loop back to clear < 1 KByte
	movem.l	(sp)+,d1-d7/a0-a6
APX_fixed_up:
	rts
;
;
; End of file:	APX_UNPK.S

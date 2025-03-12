;
; Sentry Packer v2.05 (& v2.02) Program Depacker
;
; a0 = source
; a1 = destination
; 

exe_depack
	clr.w	_sam
	cmp.l	#$4e714e71,106(a0)	; modules?
	beq.s	.nomod
	move.w	#1,_sam
	add.l	#34,d2			; jip
	add.l	#34,a3
.nomod	sub.l	d2,d0
	lea	(a3,d0.l),a0	; source adres
	lea	(a1,d1.l),a2
	move.l	d1,-(sp)	; depacked length
	move.l	a3,-(sp)
	move.l	a1,a3
	bsr	exec_unp
	move.l	(sp)+,a1
	subq.l	#8,a1
	tst	_sam
	beq.s	.exit
	bsr	ENDUNP		; samples
.exit	move.l	(sp)+,d0	; d0=depacked length
	rts
_sam	dc.w	0
exec_unp
	bsr	get_long
unp_loop
	bsr.s	.getbit
.cont	bcs.s   .blocks
	bsr.s	.getbit
	bcs.s	.copy_2
	move.b	-(a0),-(a2)	; 1 byte copy
	bra	l_col
.copy_2	bsr.s	.getbit
	bcs.s	.c_more
	moveq	#1,d2		; copy 2 bytes
	bra.s	.copy
.c_more	lea	copy_tab(pc),a4
.c_loop	move.l	(a4)+,d1
	bsr.s	.getbyte		; haal aantal
	subq.w	#1,d2
	bpl.s	.found
	bra.s	.c_loop
.found	swap	d1
	add.w	d1,d2

.copy	move.b	-(a0),-(a2)
	dbf	d2,.copy
	bra	l_col

.get_off
	MOVEQ	#1,D1		;OFFSET
	BSR.S	.getbyte
	move.b	(a4,d2),d1	; bits
	ADD.W	D2,D2
	ext.w	d1
	move.w	4(a4,d2),d4
	bsr.s	.getbyte
	add.w	d4,d2
	rts
.getbit	add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha
	rts
.haha	bsr.s	get_long
	addx.l	d0,d0	;ROXR.L  #1,D0
	rts
.haha1	bsr.s	get_long
	addx.l	d0,d0	;ROXR.L  #1,D0
	bra.s	.getbyt
.getbyte
	CLR.W   D2
.loop	add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha1
.getbyt	addx.L  d2,D2 
	DBF     D1,.loop
	RTS

.blocks	bsr.s	.getbit
	bcs.s	.string3
	moveq	#1,d3		; 2 bytes-string
	moveq	#8-1,d1	; small-bits-offset
	bsr.s	.getbyte
	bra.s	.s_copy
.string3
	lea	small_offset(pc),a4
	bsr.s	.getbit
	bcs.s	.string_more
	moveq	#2,d3		; 3 bytes-string
	bra.s	.do_strings
.string_more
	moveq	#1,d1		; 2 bits-commando
	bsr.s	.getbyte
	subq.w	#1,d2		; large string?
	bmi.s	.large
	moveq	#3,d3		; minimaal 4 bytes-string
	add.w	d2,d3		; meer?
	bra.s	.do_strings
.large	lea	aantal_tab(pc),a4
	bsr.s	.get_off
	move.w	d2,d3
	lea	offset_tab(pc),a4
.do_strings
	bsr.s	.get_off
.s_copy	move.b	-1(a2,d2.w),-(a2) 
	dbf	d3,.s_copy

l_col	cmpa.l	a2,a3 
	blt	unp_loop
ex_unp	RTS
get_long
	moveq	#3,d6
.get	lsl.l	#8,d0
	move.b	-(a0),d0
	dbf	d6,.get
	move.w	#$10,ccr
	rts
offset_tab
	dc.b	5-1,8-1,9-1,13-1
	dc.w	1,1+32,1+32+256,1+32+256+512
aantal_tab
	dc.b	2-1,3-1,5-1,9-1
	dc.w	6,6+4,6+4+8,6+4+8+32
small_offset
	dc.b	4-1,5-1,7-1,9-1
	dc.w	1,1+16,1+16+32,1+16+32+128
copy_tab
	dc.w	2,1
	dc.w	5,2
	dc.w	12,3
	dc.w	27,4
	even
ENDUNP
	move.l	a3,a0
	add.l	(a1)+,a0
	move.l	(a1),d0
	lea	(a0,d0.l),a2
.loop	move.b	(a0)+,d0
	sub.b	d0,(a0)
	neg.b	(a0)	
	cmp.l	a2,a0
	blt.s	.loop
	rts

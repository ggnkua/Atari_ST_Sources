	opt x+
***************************************
* Sentry Packer v2.10 Data Decruncher *
* Coded by Eagle. (29 Jun 1993)       *
* Also works with v2.01 & v2.05, but  *
* this one is faster.                 *
*                                     *
* Source a0, d0: length               *
***************************************

sentry210
;	move.l	a0,a3		; remove ';' =>a3: dest.adres!
	lea	(a0,d0.l),a0
	tst.b	-1(a0)
	bne.s	.cont1
	subq.l	#1,a0
.cont1	moveq	#8,d6
	bsr	get_long
	cmpi.l	#'2tnS',d0	; Snt2
	beq.s	.unpack
	rts
.unpack	bsr	get_long
	lea	(a3,d0.l),a2	; dest adres
	move.l	a2,a5		; save for picture depack
	bsr	get_long
	moveq	#0,d1
	bsr	.getbyte
	move.w	d2,unp_pic
	moveq	#0,d1
	bsr	.getbyte
	move.w	d2,unp_sam
	bne.s	.no_sam
	move.l	d0,-(sp)
	bsr	get_long
	move.l	d0,samoff+4
	bsr	get_long
	move.l	d0,samoff
	move.l	(sp)+,d0
.no_sam	bsr.s	.unp_loop	; unpack data
	tst	unp_pic
	bne.s	.no_pic
	bsr	unp_picture
.no_pic	tst	unp_sam
	bne.s	.no_mod
	bsr	samples
.no_mod	rts

.unp_loop
	bsr.s	.getbit
.cont	bcs.s   .blocks
	bsr.s	.getbit
	bcs.s	.copy_2
	move.b	-(a0),-(a2)	; 1 byte copy
	bra	.l_col
.copy_2	bsr.s	.getbit
	moveq	#1,d2		; copy 2 bytes
	bcc.s	.copy
.c_more	lea	copy_tab(pc),a4
.c_loop	move.l	(a4)+,d1
	bsr.s	.getbyte		; haal aantal
	subq.w	#1,d2
	bmi.s	.c_loop
.found	swap	d1
	add.w	d1,d2

.copy	move.b	-(a0),-(a2)
	dbf	d2,.copy
	bra	.l_col

.get_off
	MOVEQ	#1,D1		;OFFSET
	BSR.S	.getbyte
	move.b	(a4,d2),d1	; bits
	ADD.W	D2,D2			; remove for MC6830
	ext.w	d1
	move.w	4(a4,d2),d4		; MC68030: move.w 4(a4,d2.w*2),d4
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
	bra.s	.string_copy
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
	bra.s	.s_copy
.string_copy
	bsr.s	.getbyte
.s_copy	move.b	-1(a2,d2.w),-(a2) 
	dbf	d3,.s_copy

.l_col	cmpa.l	a2,a3 
	blt	.unp_loop
ex_unp	RTS
get_long
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	move.w	#$10,ccr
	rts
samples	lea	samoff(pc),a1
	move.l	a3,a0		; source adres
	add.l	(a1)+,a0
	move.l	(a1),d0
	lea	(a0,d0.l),a2
.loop	move.b	(a0)+,d0
	sub.b	d0,(a0)
	neg.b	(a0)
	cmp.l	a2,a0
	blt.s	.loop
	rts
unp_picture
.low	move.w	#$0f9f,d7
snt2_01	moveq	#3,d6
snt2_02	move.w	-(a5),d4
	moveq	#3,d5
snt2_03	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,snt2_03
	dbra	d6,snt2_02
	movem.w d0-d3,(a5)
	dbra	d7,snt2_01
	rts
samoff	dc.l	0,0
unp_pic	dc.w	0
unp_sam	dc.w	0
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

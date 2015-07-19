	OPT	O+
; 356 octets
;decrunch source code of ATOMIK by ALTAIR	;je tiens a preciser
;A0=packed code		;que j'ai entierement
;call it by bsr		;ecris ce compacteur
			;environnement compris.
DEC_MARGE:	equ	$10	;min=0 , max=126 (pair!)

atomik:
	cmp.l	#"ATOM",(a0)
	bne	no_crunched
	pea	(a0)
;	movem.l	d0-a6,-(a7)
	addq	#4,a0
	move.l	(a0)+,d3
	add.l	d3,(sp)
	lea	DEC_MARGE(a0,d3.l),a5

;	link	a3,#-(DEC_MARGE+10)
;	move.l	a5,a2
;	moveq	#DEC_MARGE+10-1,d0
;.save_m:
;	move.b	-(a2),-(a3)
;	dbf	d0,.save_m

	move.l	(a0)+,a6
	add.l	a0,a6
	move.b	-(a6),d7
	bra	make_jnk
decrunch:
	moveq	#6,d6
.take_length:
	add.b	d7,d7
	beq.s	.empty1
.cont_copy:
	dbcc	d6,.take_length
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.empty1:
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy

.next_cod:
	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:
	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.next_cod2:
	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:
	move	d5,D0
	bne.s	bigger
	lea	decrun_table2(pc),a4
	bsr.s	get_bit22
	cmp	#5,d5
	blt.s	contus
	lea	tablus_table(pc),a4
	subq	#6,d5
	bgt.s	.first4
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:
	moveq	#1,d6
	bsr.s	get_bit2
	move.b	(a4,d5.w),-(a5)
	bra.s	make_jnk

get_bit22:
	moveq	#2,d6
get_bit2:
	clr	d5
.get_bits:
	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont

bigger:	lea	decrun_table(pc),a4
	bsr.s	get_bit22
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:
	move.b	-(a4),-(a5)
	dbf	d0,.copy_same
make_jnk:
	moveq	#10,d5		;cleare le poids fort
	moveq	#11,d6
.take_jnk:
	add.b	d7,d7
	beq.s	.empty
.cont_jnk:
	dbcc	d6,.take_jnk
	bcs.s	.next_cod
	sub	d6,d5
	bra.s	copy_jnk2
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_jnk
.next_cod:
	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	add	#8+3-1,d5
	bra.s	copy_jnk2
.next_cod1:
	bsr.s	get_bit22
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5
	subq	#1,d5
copy_jnk2:
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:
	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:
	cmp.l	a6,a0
.decr	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decr

	lsr.l	#4,d3
	lea	-12(a6),a6
.copy_decrun:
	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d3,.copy_decrun

;	moveq	#DEC_MARGE+10-1,d0
;.restore_m:
;	move.b	(a3)+,(a2)+
;	dbf	d0,.restore_m
;	unlk	a3

;	movem.l	(a7)+,d0-a6
	move.l	(sp)+,a1		;ptr fin fichier
no_crunched:
 	rts
decrun_table:
	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2:
	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table:
	dc.b	$60,$20,$10,$8

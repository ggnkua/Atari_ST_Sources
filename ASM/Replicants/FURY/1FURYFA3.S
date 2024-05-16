	bra	nodebug
	
	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	move	#$777,$ffff8240.w
	
	pea	0
	trap	#1

screen	equ	$f8000

	opt	d+
	
	text
	
nodebug	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	clr.b	$ffff8260.w
	move.l	#screen,d0
	lea	$ffff8200.w,a0
	lsr.l	#8,d0
	movep	d0,1(a0)
		
	
	move.l	#scroll_pos,last_scro
	move.l	#scro_buf_a,scro_a
	move.l	#scro_buf_b,scro_b
	move	#1,nxt_let
	clr	nxt_pos
	clr	point_txt
			
main	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	
*	move	#3000,d0
*efe	dbra	d0,efe	
*	clr	$ffff8240.w
	
	bsr	scroll
	
	move	#$777,$ffff8240.w
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main
	
	pea	0
	trap	#1
		
scroll	move.l	scro_a,a0
	move.l	scro_b,scro_a
	move.l	a0,scro_b
	lea	(a0),a3

	subq	#1,nxt_let
	bne.s	no_let
	
	LEA	message,a1
	lea	font_adress,a2
	moveq	#0,d0
refetch	move	point_txt,d0
	move.b	(a1,d0),d0
	EXT	D0
	CMP.B	#$FF,d0	* Fin de message
	bNE.s	z_tetx
	clr	point_txt
	bra.S	refetch
z_tetx	
	add	d0,d0
	add	d0,d0
	move.l	(a2,d0),a1
	
	lea	new_bloc+2,a2
	moveq	#27,d0
new_blk	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	ADDQ	#2,A2
	lea	32(a1),a1
	dbra	d0,new_blk
	
	addq	#1,point_txt	
	move	#8,nxt_let	* 64 pixels a 16 pix/vbl		
no_let	move.l	last_scro,a1
	move.l	(a1)+,a2
	move	(a1)+,d1	* Adresse d'ecriture
		
	subq	#1,nxt_pos
	bpl.s	no_move
	
	tst	(a1)
	bpl.s	zlot
	
	lea	scroll_pos,a1
zlot	move.l	a1,LAST_scro
	
	move	#1,nxt_pos	* Nbre de frames avant le chgt-1
	
no_move	lea	screen+160*150,a1
	moveq	#27,d0	* Hauteur
	jmp	(a2)
	
scro_0	
gizi	set	0
	rept	20
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_0
	
	bra	inclu_blk
	
	rts
	
scro_1	move	(a0)+,152(a1)
gizi	set	0
	rept	19
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_1
	bra	inclu_blk
	
	rts

scr	set	2
scro_2	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
	
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	
	dbra	d0,scro_2
	bra	inclu_blk
	rts

scr	set	3
scro_3	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_3
	bra	inclu_blk
	
	rts

scr	set	4
scro_4	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_4
	bra	inclu_blk
	
	rts

scr	set	5
scro_5	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_5
	bra	inclu_blk
	
	rts
	
scr	set	6
scro_6	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_6
	bra	inclu_blk
	rts

scr	set	7
scro_7	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_7
	bra	inclu_blk
	rts

scr	set	8
scro_8	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_8
	bra	inclu_blk
	rts

scr	set	9
scro_9	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_9
	bra	inclu_blk
	rts

scr	set	10
scro_10	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_10
	bra	inclu_blk
	rts

scr	set	11
scro_11	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_11
	bra	inclu_blk
	rts

scr	set	12
scro_12	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_12
	bra	inclu_blk
	rts

scr	set	13
scro_13	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_13
	bra	inclu_blk
	rts

scr	set	14
scro_14	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_14
	bra	inclu_blk
	rts

scr	set	15
scro_15	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_15
	bra	inclu_blk
	rts
	
scr	set	16
scro_16	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_16
	bra	inclu_blk
	rts

scr	set	17
scro_17	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_17
	bra	inclu_blk
	rts

scr	set	18
scro_18	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_18
	bra	inclu_blk
	rts

scr	set	19
scro_19	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_19
*	bsr	inclu_blk
*	rts

inclu_blk	lea	new_bloc,a0
	add	d1,a3
	moveq	#27,d0
letre_in	MOVE	(a0)+,(a3)+
	ADDQ	#8,A0
	lea	46(a3),a3
	dbra	d0,letre_in
	
	LEA	NEW_BLOC+1,A0
	LEA	-1(A0),A1
	MOVEQ	#27,D0
DECAL	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	ADDQ	#1,A0
	ADDQ	#1,A1
	DBRA	D0,DECAL
	
	rts

	data
* Affichage rout
scroll_pos	dc.l	scro_0
	DC.W	0
	dc.l	scro_1
	DC.W	2
	dc.l	scro_2
	DC.W	4
	dc.l	scro_3
	DC.W	6
	dc.l	scro_4
	DC.W	8
	dc.l	scro_5
	DC.W	10
	dc.l	scro_6
	DC.W	12
	dc.l	scro_7
	DC.W	14
	dc.l	scro_8
	DC.W	16
	dc.l	scro_9
	DC.W	18
	dc.l	scro_10
	DC.W	20
	dc.l	scro_11
	DC.W	22
	dc.l	scro_12
	DC.W	24
	dc.l	scro_13
	DC.W	26
	dc.l	scro_14
	DC.W	28
	dc.l	scro_15
	DC.W	30
	dc.l	scro_16
	DC.W	32
	dc.l	scro_17
	DC.W	34
	dc.l	scro_18
	DC.W	36
	dc.l	scro_19
	DC.W	38
	dc.w	$ffff

font_adress	rept	33
	dc.l	pic_dat+40*140+8	* plein de codes!
	endr
	dc.l	pic_dat+40*140+16	* !
	rept	5
	dc.l	pic_dat+40*140+8	* plein de codes!
	endr
	
	dc.l	pic_dat+40*224+16	* '
	dc.l	pic_dat+40*224+32	* (
	dc.l	pic_dat+40*252	* )
	
	
	dc.l	pic_dat+40*140+8	* * y est pas
	dc.l	pic_dat+40*140+8	* + y est pas
	
	dc.l	pic_dat+40*224+8	* ,
	dc.l	pic_dat+40*224+24	* -
	dc.l	pic_dat+40*140+24	* .
	
	dc.l	pic_dat+40*140+8	* plein de codes!
	
	dc.l	pic_dat+40*140+32	* 0
gizi	set	0
	rept	2
	dc.l	pic_dat+40*168+gizi*40*28	* 1->5 et 6->:
	dc.l	pic_dat+40*168+gizi*40*28+8	* 1->5 et 6->:
	dc.l	pic_dat+40*168+gizi*40*28+16	* 1->5 et 6->:
	dc.l	pic_dat+40*168+gizi*40*28+24	* 1->5 et 6->:
	dc.l	pic_dat+40*168+gizi*40*28+32	* 1->5 et 6->:
gizi	set	gizi+1
	endr
	
	rept	4
	dc.l	pic_dat+40*140+8	* plein de codes!
	endr
	
	dc.l	pic_dat+40*224	* ?
	dc.l	pic_dat+40*140+8	* @ y est pas
		
gizi	set	0
	rept	5
	dc.l	pic_dat+gizi*28*40
	dc.l	pic_dat+gizi*28*40+8
	dc.l	pic_dat+gizi*28*40+16
	dc.l	pic_dat+gizi*28*40+24
	dc.l	pic_dat+gizi*28*40+32
gizi	set	gizi+1
	endr
	dc.l	pic_dat+gizi*28*40
	
	rept	163
	dc.l	pic_dat+40*140+8	* plein de codes!
	endr
	
meSSAGE	
	INCLUDE	"1TEXTSCR.S"
	DC.B	-1
	
pic_dat	incbin	"bigfonts.1pl"

	bss
last_scro	ds.l	1
nxt_pos	ds.w	1
nxt_let	ds.w	1
point_txt	ds.w	1
scro_a	ds.l	1
scro_b	ds.l	1
scro_buf_a	ds.w	24*30
scro_buf_b	ds.w	24*30
new_bloc	ds.w	5*30

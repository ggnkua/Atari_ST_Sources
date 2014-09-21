;---------------------------------------------------------------;
;	Scroller			;
;	Version TEST			;
;	- Buffer en $1000		;
;	- Tablehigh en $10000 CHANGEE (bon ordre)	;
;	- TOUT en Rept			;
;	- dat_letters CHANGES		;
;---------------------------------------------------------------;

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	table_high,a0
	lea	$10000,a1

	move.w	#32768-1,d1
conver	move.w	(a0),d2
	add.w	#$150,d2
	move.w	d2,(a0)+
	dbf	d1,conver

	lea	table_high,a1
	
	move.w	#256-1,d2
conv2	move.l	a1,a0
x	set	0
	rept	64
	move.w	x(a0),d1
	move.w	x+128(a0),x(a0)
	move.w	d1,x+128(a0)
x	set	x+2
	endr
	lea	$100(a1),a1
	dbf	d2,conv2

	lea	table_high,a0
	lea	$10000,a1

	move.w	#32768-1,d1
conver2	move.w	(a0)+,(a1)+
	dbf	d1,conver2

;---------------------------------------------------------------;

	lea	text,a0

cde	move.b	(a0)+,d0
	cmp.b	#-1,d0
	beq.s	fin_text

	cmp.b	#32,d0
	bne.s	.tst1
	move.b	#64,-1(a0)
	bra.s	cde

.tst1	cmp.b	#".",d0
	bne.s	.tst2
	move.b	#91,-1(a0)
	bra.s	cde
.tst2	cmp.b	#",",d0
	bne.s	.tst3
	move.b	#92,-1(a0)
	bra.s	cde
.tst3	cmp.b	#"!",d0
	bne.s	.tst4
	move.b	#93,-1(a0)
	bra.s	cde
.tst4	cmp.b	#"?",d0
	bne.s	cde
	move.b	#94,-1(a0)
	bra.s	cde
fin_text

;---------------------------------------------------------------;
;	Sauvegardes			;
;---------------------------------------------------------------;

	lea	save,a0
	move.l	d0,(a0)+
	move.l	$70.w,(a0)+
	move.l	$fffffa06.w,(a0)+
	move.l	$ffff8200.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

;---------------------------------------------------------------;
;	Inits			;
;---------------------------------------------------------------;

	move.l	#vbl,$70.w
	clr.l	$fffffa06.w
	stop	#$2300
	stop	#$2300
	move.b	#0,$ffff8260.w

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,work
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	clr.w	$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$777,$ffff8250.w

;---------------------------------------------------------------;
;	Inits sur les buffers, les parametres etc.	;
;---------------------------------------------------------------;

	lea	adrs320,a0

	lea	dat_letters,a1

	move.w	#20*256-1,d0	
remp	move.l	a1,(a0)+
	dbf	d0,remp

;---------------------------------------------------------------;
;	Boucle principale		;
;---------------------------------------------------------------;
	
start_vbl	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,work
	add.l	#32000,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	clr.w	flag_vbl
synchro	tst.w	flag_vbl
	beq.s	synchro

	clr.w	$ffff8240.w

	bsr	vide_buffer
	bsr	letter
	bsr	scroll
	jsr	aff

	;move.w	#$400,$ffff8240.w

	cmp.b	#$39,$fffffc02.w
	beq	fin_prg

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,d1
	add.l	#32000,d0
	move.l	d0,work
	lsr.w	#8,d1
	move.l	d1,$ffff8200.w

	clr.w	flag_vbl
synchro2	tst.w	flag_vbl
	beq.s	synchro2

	clr.w	$ffff8240.w

	bsr	vide_buffer
	bsr	letter
	bsr	scroll
	jsr	aff

	;move.w	#$400,$ffff8240.w

	cmp.b	#$39,$fffffc02.w
	bne	start_vbl

;---------------------------------------------------------------;
;	Fin programme			;
;---------------------------------------------------------------;

fin_prg	lea	save,a0
	move.l	(a0)+,-(a7)
	move.l	(a0)+,$70.w
	move.l	(a0)+,$fffffa06.w
	move.l	(a0)+,$ffff8200.w
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

;---------------------------------------------------------------;
;	Vidage buffer			;
;---------------------------------------------------------------;

vide_buffer	lea	$1000+672,a0	10240 oct
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a1		
	move.l	d0,a2		
	move.l	d0,a3		
	move.l	d0,a4		
	move.l	d0,a5		
	move.l	d0,a6		
	moveq	#9,d7

clear	rept	12
	movem.l	d0-d6/a1-a6,-(a0)   52 octets
	endr
	movem.l	d0-d6/a1-a5,-(a0)
	lea	$6a0(a0),a0
	dbf	d7,clear
	rts

;---------------------------------------------------------------;
;	Routine letter			;
;---------------------------------------------------------------;

letter:	move.w	dec,d0
	addq.w	#6,d0
	cmp.w	#256*17,d0
	blo.s	pas_max
	sub.w	#256*10,d0
pas_max	move.w	d0,dec

	lea	adrs320,a0
	move.l	a0,a3
	add.w	#256*7,d0	on ecrit 256*7 pix + loin.
	move.w	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0
	sub.w	#256*10,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a3
	
	moveq	#6,d7

same_letter	move.w	pos_letter,d1
	cmp.w	width_letter,d1
	bhi.s	new_letter

	move.l	adr_letter,(a0)+
	move.l	adr_letter,(a3)+
	addq.l	#8,adr_letter
	addq.w	#1,pos_letter

	subq.w	#1,d7
	bne.s	same_letter
	
	bra	fin_rout

new_letter	move.l	pos_scroll,a2
	moveq	#0,d0	

read_letter	move.b	(a2)+,d0
	bpl.s	no_negatif
	lea	text,a2
	move.b	(a2)+,d0
no_negatif	move.l	a2,pos_scroll
	sub.b	#64,d0

	lea	width,a1
	add.w	d0,d0
	move.w	(a1,d0.w),width_letter
	lea	dat_letters,a1
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	d0,a1
	move.l	a1,adr_letter
	clr.w	pos_letter

	bra	same_letter
	
fin_rout	rts

;---------------------------------------------------------------;
;	Routine scroll			;
;---------------------------------------------------------------;

scroll:	moveq	#0,d0
	move.w	dec,d0
	add.w	d0,d0
	add.w	d0,d0

	move.l	pos_ht,a0
	clr.w	d1

	move.b	(a0)+,d1	ZOOM
	bne.s	.ok
	lea	ht,a0
	move.b	(a0)+,d1
.ok	cmp.b	#-1,d1
	bne.s	.boum	
	not.b	ruban
	addq.l	#1,a0
	move.b	(a0)+,d1
.boum	move.b	(a0)+,d7
	move.l	a0,pos_ht

	moveq	#0,d2
	move.w	d1,d2
	lsl.w	#8,d2
	
	lea	adrs320+4*256,a0
	add.w	d0,a0	d0=0 pour l'instant

	move.l	#$10000,d3
	divu	d1,d3
	ext.l	d3

	move.l	d3,d6
	lsl.l	#8,d6
	mulu	#160,d3
	lsr.l	#8,d3
	lsl.l	#2,d3
	tst.b	d7
	bne.s	.caca
	sub.l	d3,a0	A enlever
.caca	
	lea	$10000,a4
	add.l	d2,a4
	move.l	a4,d2	Imperatif!
	lea	bidon,a6
	rept	320
	move.l	d2,(a6)+
	endr
	lea	bidon,a6

	lea	$1000.w,a5

	move.w	#$8000,d0
	moveq	#0,d4

	tst.b	ruban
	bne.s	pas_rub

	subq.l	#8,pos_prof
	move.l	pos_prof,a6
	cmp.l	#prof,a6
	bhi.s	ouioui
	lea	fin_prof,a6
ouioui	move.l	a6,pos_prof

pas_rub

a	=	$6754
b	=	$673e
c	=	$6728
d	=	$6712

x	set	$1000

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+$3fe

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

x	set	x+2

	REPT	16
	move.l	(a6)+,d2
	add.l	d6,d4
	move.l	d4,d3
	swap	d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a2
	move.b	(a2)+,d2
	DC.W	a
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	b
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	c
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	DC.W	d
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	move.b	(a2)+,d2
	move.l	d2,a4
	move.w	(a4),a5
	eor.w	d0,x(a5)
	ror.w	#1,d0
	ENDR

	rts

;---------------------------------------------------------------;
;	Routine affichage		;
;---------------------------------------------------------------;

aff	lea	$1000.w,a0
	move.l	work,a1
	lea	6(a1),a1

	move.w	#$a,a2

deb	moveq	#0,d7
x	set	0
	rept	24
	movem.l	(a0)+,d0-d6
	eor.l	d0,d7
	move.l	d7,x+0*160(a1)
	eor.l	d1,d7
	move.l	d7,x+1*160(a1)
	eor.l	d2,d7
	move.l	d7,x+2*160(a1)
	eor.l	d3,d7
	move.l	d7,x+3*160(a1)
	eor.l	d4,d7
	move.l	d7,x+4*160(a1)
	eor.l	d5,d7
	move.l	d7,x+5*160(a1)
	eor.l	d6,d7
	move.l	d7,x+6*160(a1)
x	set	x+7*160
	endr
	lea	$10(a1),a1
	lea	$160(a0),a0
	subq.w	#1,a2
	move.w	a2,d6
	bne	deb

	rts

;---------------------------------------------------------------;
;	Routines en interruption		;
;---------------------------------------------------------------;

vbl	not.w	flag_vbl
	rte

;---------------------------------------------------------------;
	DATA			;
;---------------------------------------------------------------;

table_high	incbin	tblhigh.bin

dat_letters	dcb.b	2048,0
	incbin	a.bin
	incbin	b.bin
	incbin	c.bin
	incbin	d.bin
	incbin	e.bin
	incbin	f.bin
	incbin	g.bin
	incbin	h.bin
	incbin	i.bin
	incbin	j.bin
	incbin	k.bin
	incbin	l.bin
	incbin	m.bin
	incbin	n.bin
	incbin	o.bin
	incbin	p.bin
	incbin	q.bin
	incbin	r.bin
	incbin	s.bin
	incbin	t.bin
	incbin	u.bin
	incbin	v.bin
	incbin	w.bin
	incbin	x.bin
	incbin	y.bin
	incbin	z.bin
	incbin	point.bin
	incbin	virgule.bin
	incbin	exclam.bin
	incbin	interrog.bin

dec	dc.w	256*10

;---------------------------------------------------------------;
;	Se rattachant au scrolltext		;
;---------------------------------------------------------------;

text	dc.b	'WHAT ABOUT ZOOMING, SHRINKING, WRINGING AND PLAYING IN ANYWAY WITH A SCROLLER, OR ANY OTHER SURFACE???  '
	dc.b	-1
	even

pos_scroll	dc.l	text

width	dc.w	150,117+8,155+8,131+8,157+8,136+8,136+8
	dc.w	132+8,161+8,99+8,138+8,164+8,92+8,208+8
	dc.w	166+8,147+8,153+8,147+8,153+8,147+8,122+8
	dc.w	134+8,117+8,207+8,163+8,114+8,114+8

	dc.w	100+8,100+8,100+8,100+8
	even

width_letter	dc.w	0	bidon
pos_letter	dc.w	1	bidon
adr_letter	dc.l	dat_letters	bidon

ht	dc.b	-1,0	PAS
	rept	50*5
	dc.b	$30,0
	endr
x	set	$30
	rept	$fe-$30
	dc.b	x,0
x	set	x+1
	endr

	dc.b	$fe,0

x	set	$fe
	rept	$fe-$30
	dc.b	x,0
x	set	x-1
	endr

	dc.b	$30,0

x	set	$30
	rept	($fe-$30)/2
	dc.b	x,0	j
x	set	x+2
	endr

	dc.b	$fe,0

x	set	$fe
	rept	($fe-$30)/2
	dc.b	x,0	j
x	set	x-2
	endr

	dc.b	$30,0

x	set	$30
	rept	$fe-$30
	dc.b	x,0
x	set	x+1
	endr

	dc.b	$fe,0

x	set	$fe
	rept	$fe-$30
	dc.b	x,0
x	set	x-1
	endr

	dc.b	$30,0

x	set	$30
	rept	$fe-$30
	dc.b	x,0
x	set	x+1
	endr

	dc.b	$fe,0

	dc.b	-1,0	OUI
	rept	50*5
	dc.b	$fe,0
	endr
x	set	$fe
	rept	$fe-$30
	dc.b	x,0	j
x	set	x-1
	endr

	dc.b	$30,0

x	set	$30
	rept	$fe-$30
	dc.b	x,0
x	set	x+1
	endr

	dc.b	$fe,0

x	set	$fe
	rept	$fe-$30
	dc.b	x,0
x	set	x-1
	endr

	dc.b	$30,0

	dc.b	-1,0	PAS

	dc.b	$30,0

	dc.b	0,0

pos_ht	dc.l	ht

prof	incbin	sinus.bin
fin_prof	incbin	sinus.bin

pos_prof	dc.l	fin_prof

ruban	dc.b	0
	even
;---------------------------------------------------------------;
	BSS			;
;---------------------------------------------------------------;
	even	
flag_vbl	ds.w	1
work	ds.l	1
save	ds.l	20

	even
bidon	ds.l	320

ecran0	ds.l	8000+64
	ds.l	8000

	ds.l	256*10
adrs320	ds.l	256*40	5 lettres de 256 colonnes
			;et 1 colonne = 1 long
;buffer	ds.b	10*$400

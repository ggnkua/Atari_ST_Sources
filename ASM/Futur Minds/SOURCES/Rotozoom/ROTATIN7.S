;---------------------------------------------------------------;
;	Rotating-zoomer (256x128)		;
;---------------------------------------------------------------;

machine_time	equ	0

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

;---------------------------------------------------------------;
;	Sauvegardes			;
;---------------------------------------------------------------;

	lea	save,a0
	move.l	d0,(a0)+
	move.l	$ffff8200.w,(a0)+
	move.l	$fffffa06.w,(a0)+
	move.l	$70.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

;---------------------------------------------------------------;
;	Initialisations			;
;---------------------------------------------------------------;
	
	clr.l	$fffffa06.w
	stop	#$2300
	stop	#$2300
	move.b	#1,$ffff8260.w
	stop	#$2300
	move.b	#0,$ffff8260.w

	move.l	#vbl,$70.w
	
	move.l	#ecran+256,d0
	clr.b	d0
	move.l	d0,work
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

;---------------------------------------------------------------;
;	Boucle principale		;
;---------------------------------------------------------------;

start_vbl1	clr.w	flag_vbl
.synchro	tst.w	flag_vbl
	beq.s	.synchro

	movem.l	palette1,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	work,a4
	bsr	rz

	ifne	machine_time
	not.w	$ffff8240.w
	dcb.w	120,$4e71
	not.w	$ffff8240.w
	endc

	cmp.b	#$39,$fffffc02.w
	beq	fin

start_vbl2	clr.w	flag_vbl
.synchro	tst.w	flag_vbl
	beq.s	.synchro

	movem.l	palette2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	work,a4
	addq.l	#2,a4
	bsr	rz

	ifne	machine_time
	not.w	$ffff8240.w
	dcb.w	120,$4e71
	not.w	$ffff8240.w
	endc

	cmp.b	#$39,$fffffc02.w
	beq	fin

start_vbl3	clr.w	flag_vbl
.synchro	tst.w	flag_vbl
	beq.s	.synchro

	movem.l	palette3,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	work,a4
	addq.l	#4,a4
	bsr	rz

	ifne	machine_time
	not.w	$ffff8240.w
	dcb.w	120,$4e71
	not.w	$ffff8240.w
	endc

	cmp.b	#$39,$fffffc02.w
	beq	fin

start_vbl4	clr.w	flag_vbl
.synchro	tst.w	flag_vbl
	beq.s	.synchro

	movem.l	palette4,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	work,a4
	addq.l	#6,a4
	bsr	rz

	ifne	machine_time
	not.w	$ffff8240.w
	dcb.w	120,$4e71
	not.w	$ffff8240.w
	endc

	cmp.b	#$39,$fffffc02.w
	bne	start_vbl1

;---------------------------------------------------------------;
;	Fin du programme		;
;---------------------------------------------------------------;
		
fin:	lea	save,a0
	move.l	(a0)+,-(a7)
	move.l	(a0)+,$ffff8200.w
	move.l	(a0)+,$fffffa06.w
	move.l	(a0)+,$70.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

;---------------------------------------------------------------;
;	Routine principal du Rotating-zoomer	;
;	(ecran de travail dans A4)		;
;---------------------------------------------------------------;

rz:	move.l	pos_crb,a0
	move.l	(a0)+,d0
	cmp.l	#$99999999,d0
	bne.s	.ok
	lea	crb,a0
	move.l	(a0)+,d0
.ok	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d0,polygone+6
	move.l	d1,polygone+12
	move.l	d2,polygone+18
	move.l	d3,polygone+24
	move.l	a0,pos_crb

;---------------------------------------------------------------;

	lea	picture0,a0
	lea	picture1,a1
	lea	picture2,a2
	lea	picture3,a3
	move.l	#picture0,addrs+2
	move.l	#picture1,addrs+8
	move.l	#picture2,addrs+14
	move.l	#picture3,addrs+20

	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d5

	lea	table_mul2,a5

	move.w	polygone+6,d1	x depart
	move.w	polygone+12,d5
	sub.w	d1,d5	largeur
	ext.l	d5
	muls	320(a5),d5
	AND.W	#$ff,d1	DANS LE CARRE

	move.l	#$8000,offset
	moveq	#-1,d4
	move.w	#$7fff,d0

	move.w	polygone+8,d2	y depart
	move.w	polygone+14,d3
	sub.w	d2,d3	hauteur
	bpl.s	dy_posit
	move.l	#-$8000,offset
	add.l	#$8000,addrs+2
	add.l	#$8000,addrs+8
	add.l	#$8000,addrs+14
	add.l	#$8000,addrs+20
	add.l	#$8000,a0
	add.l	#$8000,a1
	add.l	#$8000,a2
	add.l	#$8000,a3
	exg	d0,d4
dy_posit	AND.W	#$7f,d2	DANS LE CARRE
	LSL.L	#8,d2
	ext.l	d3
	muls	320(a5),d3
	ASL.L	#8,d3
	add.l	d3,d3

	add.l	d5,d5
	swap	d3	Pas d'incrementations …
	swap	d5	l'interieur de notre ligne.
	move.l	d5,a5

	moveq	#0,d6
	move.w	d2,d6
	move.b	d1,d6
	lea	(a0,d6.l),a0
	lea	(a1,d6.l),a1
	lea	(a2,d6.l),a2
	lea	(a3,d6.l),a3

	moveq	#0,d7
	lea	starting+2,a6

	movem.l	d1-d2/d4,-(a7)

	moveq	#20-1,d5	10-1
	moveq	#0,d1
	moveq	#0,d2

slope	rept	2	4
	add.l	a5,d1
	addx.w	d7,d1
	add.l	d3,d2
	addx.w	d7,d2
	move.w	d2,d6
	move.b	d1,d6
	AND.W	D0,D6
	sub.w	#$8000,d6
	AND.W	D4,D6
	move.w	d6,(a6)
	add.l	a5,d1
	addx.w	d7,d1
	add.l	d3,d2
	addx.w	d7,d2
	move.w	d2,d6
	move.b	d1,d6
	AND.W	D0,D6
	sub.w	#$8000,d6
	AND.W	D4,D6
	move.w	d6,4(a6)
	add.l	a5,d1
	addx.w	d7,d1
	add.l	d3,d2
	addx.w	d7,d2
	move.w	d2,d6
	move.b	d1,d6
	AND.W	D0,D6
	sub.w	#$8000,d6
	AND.W	D4,D6
	move.w	d6,8(a6)
	add.l	a5,d1
	addx.w	d7,d1
	add.l	d3,d2
	addx.w	d7,d2
	move.w	d2,d6
	move.b	d1,d6
	AND.W	D0,D6
	sub.w	#$8000,d6
	AND.W	D4,D6
	move.w	d6,12(a6)
	lea	18(a6),a6
	endr
	lea	4+4(a6),a6
	dbf	d5,slope

	movem.l	(a7)+,d1-d2/d4

	lea	table_mul2,a5

	moveq	#0,d0
	moveq	#0,d3
	moveq	#0,d5
	move.w	polygone+12,d0
	move.w	polygone+18,d5
	sub.w	d0,d5
	ext.l	d5
	muls	320(a5),d5
	add.l	d5,d5
	swap	d5

	move.w	polygone+14,d0
	move.w	polygone+20,d3
	sub.w	d0,d3
	ext.l	d3
	muls	320(a5),d3
	ASL.L	#8,d3
	add.l	d3,d3
	swap	d3
	
	move.l	offset(pc),d4
	add.l	d4,a0
	add.l	d4,a1
	add.l	d4,a2
	add.l	d4,a3

	moveq	#100-1,d0

starting	rept	10	nos 160 (gros) points
	move.b	0(a0),d6	=320 points a l'ecran
	or.b	0(a1),d6
	or.b	0(a2),d6
	or.b	0(a3),d6
	move.b	d6,(a4)+
	move.b	0(a0),d6
	or.b	0(a1),d6
	or.b	0(a2),d6
	or.b	0(a3),d6
	move.b	d6,(a4)+
	move.w	-(a4),160(a4)
	lea	8(a4),a4
	move.b	0(a0),d6
	or.b	0(a1),d6
	or.b	0(a2),d6
	or.b	0(a3),d6
	move.b	d6,(a4)+
	move.b	0(a0),d6
	or.b	0(a1),d6
	or.b	0(a2),d6
	or.b	0(a3),d6
	move.b	d6,(a4)+
	move.w	-(a4),160(a4)
	lea	8(a4),a4	
	endr
	lea	160(a4),a4

	add.l	d5,d1	x
	addx.w	d7,d1
	add.l	d3,d2	y
	addx.w	d7,d2

	moveq	#0,d6
	move.w	d2,d6
	move.b	d1,d6
	AND.W	#$7FFF,D6
addrs	lea	picture0,a0
	lea	picture1,a1
	lea	picture2,a2
	lea	picture3,a3
	add.l	d4,d6
	add.l	d6,a0
	add.l	d6,a1
	add.l	d6,a2
	add.l	d6,a3

	dbf	d0,starting
	rts

;---------------------------------------------------------------;
;	Routine VBL			;
;---------------------------------------------------------------;

vbl:	not.w	flag_vbl
	rte

;---------------------------------------------------------------;
	DATA			;
;---------------------------------------------------------------;
	even
offset	dc.l	0
polygone:	dc.w	0
	dc.w	4,0,$0000,$2f00,1,$0050,$0000,2,$007f,$5000,3,$002f,$7f00	;1=bidon

table_mul2	incbin	tblmul2.bin

picture0	incbin	ro128_0.bin
	incbin	ro128_0.bin
picture1	incbin	ro128_1.bin
	incbin	ro128_1.bin
picture2	incbin	ro128_2.bin
	incbin	ro128_2.bin
picture3	incbin	ro128_3.bin
	incbin	ro128_3.bin

pos_crb	dc.l	crb
crb	incbin	crb.bin
	dc.l	$99999999

chk1	equ	$222
chk2	equ	$444
chk3	equ	$777
none	equ	$000

	;	   0    1    2  1+2    4  1+4  2+4 1+2+4   8  1+8  2+8 1+2+8 4+8 1+4+8 2+4+8 1+2+4+8 
palette1	dc.w	$000,none,chk1,chk1,chk1,chk1,chk2,chk2,chk1,chk1,chk2,chk2,chk2,chk2,chk3,chk3
palette2	dc.w	$000,chk1,none,chk1,chk1,chk2,chk1,chk2,chk1,chk2,chk1,chk2,chk2,chk3,chk2,chk3
palette3	dc.w	$000,chk1,chk1,chk2,none,chk1,chk1,chk2,chk1,chk2,chk2,chk3,chk1,chk2,chk2,chk3
palette4	dc.w	$000,chk1,chk1,chk2,chk1,chk2,chk2,chk3,none,chk1,chk1,chk2,chk1,chk2,chk2,chk3

;---------------------------------------------------------------;
	BSS			;
;---------------------------------------------------------------;
	even
flag_vbl	ds.w	1
save	ds.l	30
work	ds.l	1
ecran	ds.l	8064

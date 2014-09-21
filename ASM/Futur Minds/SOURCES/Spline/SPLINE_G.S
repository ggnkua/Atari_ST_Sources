;---------------------------------------------------------------;
;	Spline			;
;---------------------------------------------------------------;

nb	equ	1300

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	save,a0
	move.l	d0,(a0)+
	move.l	$70.w,(a0)+
	move.l	$8c.w,(a0)+
	move.l	$fffffa06.w,(a0)+
	move.l	$ffff8200.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	move.l	#ecran0+256,d0
	clr.b	d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	clr.l	$ffff8240.w
	clr.w	$ffff8244.w

	clr.l	$fffffa06.w
	move.l	#none,$70.w
	stop	#$2300
	stop	#$2300
	move.b	#1,$ffff8260.w
	stop	#$2300
	move.b	#0,$ffff8260.w

	move.l	#vbl,$70.w
deb_rast:	move.w	#25-1,d0
.wait	stop	#$2300
	dbf	d0,.wait
	cmp.w	#$777,colo2
	beq.s	fin_deb
	add.w	#$111,colo2
	cmp.w	#$777,colo
	beq.s	no_1
	add.w	#$111,colo
no_1	tst.w	colo
	bmi.s	rien_1
	move.w	colo,raster1+2
rien_1	tst.w	colo2
	bmi.s	rien_2
	move.w	colo2,raster3+2
rien_2	bra.s	deb_rast	

fin_deb	stop	#$2300

;---------------------------------------------------------------;
;	Relocation des tables/bss		;
;---------------------------------------------------------------;

	lea	spltbl2,a0
	lea	buftbl+65536,a1
	lea	buftbl+65536*2,a2
	lea	buftbl+65536*3,a3
	move.w	#65536/4-1,d0
copie_tbl2	move.l	(a0)+,d1
	move.l	d1,(a1)+			
	move.l	d1,(a2)+			
	move.l	d1,(a3)+			
	dbf	d0,copie_tbl2

	lea	spltbl,a0
	lea	spltbl2,a1
	lea	buftbl,a2
	move.w	#65536/4-1,d0
copie_tbl1	move.l	(a0)+,d1
	move.l	d1,(a1)+			
	move.l	d1,(a2)+			
	dbf	d0,copie_tbl1

;---------------------------------------------------------------;
;	Construction des routines points avec param	;
;---------------------------------------------------------------;

	lea	routines,a0

	lea	params,a5 
	movem.w	(a5)+,d1-d4/a1/a2 ;a1 a2=inc d2-d5=init
	movem.w	(a5)+,a3/a4	  ;d6 d7=inc

	move.w	#nb-1,d0	

build_rout	move.w	#$3228,(a0)+	  ;move.w $1234(a0),d1
	move.w	d1,(a0)+
	move.w	#$d26d,(a0)+	  ;add.w  $1234(a5),d1
	move.w	d2,(a0)+
	move.l	#$22331000,(a0)+  ;move.l (a3,d1.w),d1
	move.w	#$3001,(a0)+	  ;move.w d1,d0
	move.w	#$d069,(a0)+	  ;add.w  $1234(a1),d0
	move.w	d3,(a0)+
	move.w	#$d06e,(a0)+	  ;add.w  $1234(a6),d0
	move.w	d4,(a0)+
	move.w	#$4841,(a0)+	  ;swap   d1
	move.l	#$83740000,(a0)+  ;or.w   d1,(a4,d0.w)
	move.w	#$2ec0,(a0)+	  ;move.l d0,(a7)+

	add.w	a1,d1
	add.w	a2,d2
	add.w	a3,d3
	add.w	a4,d4

	dbf	d0,build_rout

	move.l	#$3ebc4e75,(a0)+
	move.w	#$2e79,(a0)+
	move.l	#sauve_a7,(a0)+
	move.l	#$4e434e75,(a0)

;---------------------------------------------------------------;
;	Inits			;
;---------------------------------------------------------------;

	move.l	#trap3,$8c.w

	move.w	#$4e75,clear_rout1
	move.w	#$4e75,clear_rout2

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,work
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

;---------------------------------------------------------------;
;	Boucle principale		;
;---------------------------------------------------------------;

start_vbl	move.l	#vbl,$70.w
	clr.w	$ffff8244.w

	clr.w	flag_vbl
synchro	tst.w	flag_vbl
	beq.s	synchro

	subq.w	#1,count_vbl
	bmi	fin

	cmp.w	#50*2,count_vbl
	bhi.s	.go
	tst.w	raster1+2
	beq	fin
	move.w	count_vbl,d0
	and.w	#7,d0
	bne.s	.no_add
	sub.w	#$111,raster1+2
	sub.w	#$111,raster3+2
	tst.w	couleur
	beq.s	.no_add
	sub.w	#$111,couleur
	bra.s	.no_add
.go
	cmp.w	#$555,couleur
	beq.s	.no_add
	move.w	count_vbl,d0
	and.w	#15,d0
	bne.s	.no_add	
	add.w	#$111,couleur
.no_add
	moveq	#0,d0
	move.l	work,a0
	add.w	#154,a0
	jsr	clear_rout1
	move.l	#clear_rout1,clear
	move.w	#154,d6
	bsr	spline_rout

	cmp.b	#$39,$fffffc02.w
	beq	fin

	move.l	#vbl2,$70.w	
	clr.w	$ffff8242.w

	clr.w	flag_vbl
synchro2	tst.w	flag_vbl
	beq.s	synchro2

	subq.w	#1,count_vbl
	bmi	fin

	cmp.w	#50*2,count_vbl
	bhi.s	.go
	tst.w	raster1+2
	beq	fin
	move.w	count_vbl,d0
	and.w	#7,d0
	bne.s	.no_add
	sub.w	#$111,raster1+2
	sub.w	#$111,raster3+2
	tst.w	couleur
	beq.s	.no_add
	sub.w	#$111,couleur
	bra.s	.no_add
.go
	cmp.w	#$555,couleur
	beq.s	.no_add
	move.w	count_vbl,d0
	and.w	#15,d0
	bne.s	.no_add	
	add.w	#$111,couleur
.no_add
	moveq	#0,d0
	move.l	work,a0
	add.w	#152,a0
	jsr	clear_rout2
	move.l	#clear_rout2,clear
	move.w	#152,d6
	bsr	spline_rout

	cmp.b	#$39,$fffffc02.w
	bne	start_vbl

;---------------------------------------------------------------;
;	Fin programme			;
;---------------------------------------------------------------;

fin	lea	save,a0
	move.l	(a0)+,-(a7)
	move.l	(a0)+,$70.w
	move.l	(a0)+,$8c.w
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
;	Routine			;
;---------------------------------------------------------------;

spline_rout	lea	params,a0 
	movem.w	param2,d1-d4 
	add.w	d1,(a0)+ 
	add.w	d2,(a0)+ 
	add.w	d3,(a0)+ 
	add.w	d4,(a0)+ 

	move.l	a7,sauve_a7
	move.w	#$300,sr

	lea	spltbl+65536+$8000,a5 
	move.l	a5,a0
	lea	buftbl+131072+$8000,a6 
	move.l	a6,a1

	lea	table_x,a3
	move.l	work,a4 
	add.w	d6,a4
	move.l	clear,a7

	movem.w	params,d0-d3
	add.w	d0,a0
	add.w	d1,a5
	add.w	d2,a1
	add.w	d3,a6

	move.l	#$31400000,d0

	jmp	routines

;---------------------------------------------------------------;
;	Routine VBL			;
;---------------------------------------------------------------;

vbl:	not.w	flag_vbl
	clr.b	$fffffa1b.w
	move.l	#raster1,$120.w
	move.b	#1,$fffffa07.w
	move.b	#1,$fffffa13.w
	bclr.b	#3,$fffffa17.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	couleur(pc),$ffff8242.w
	move.w	couleur(pc),$ffff8246.w
none	rte

vbl2:	not.w	flag_vbl
	clr.b	$fffffa1b.w
	move.l	#raster1,$120.w
	move.b	#1,$fffffa07.w
	move.b	#1,$fffffa13.w
	bclr.b	#3,$fffffa17.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	couleur(pc),$ffff8244.w
	move.w	couleur(pc),$ffff8246.w
	rte

couleur	dc.w	0

raster1:	move.w	#$0,$ffff8240.w
	move.l	#raster2,$120.w
	rte
raster2:	clr.w	$ffff8240.w
	clr.b	$fffffa1b.w
	move.l	#raster3,$120.w
	move.b	#197,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

raster3:	move.w	#$0,$ffff8240.w
	clr.b	$fffffa1b.w
	move.l	#raster4,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

raster4:	clr.b	$fffffa1b.w
	clr.w	$ffff8240.w
	rte

trap3:	move.w	#$2300,(a7)
	rte

colo	dc.w	-$111*3
colo2	dc.w	-$111*10

;---------------------------------------------------------------;
	DATA			;
;---------------------------------------------------------------;
	even
	;	d2 d3 d4 d5  a1     a2     d6   d7
params	dc.w	$0,$0,$0,$0,-$1204*2,$2206*2,-$204*2,-$1206*2
param2	dc.w	$f8,$174,$ff9c,$40

mul_160
y	set	0
	rept	200
	dc.w	y
y	set	y+160
	endr


table_x
x	set	0
	rept	20
	dc.w	$1,-x
	dc.w	$2,-x
	dc.w	$4,-x
	dc.w	$8,-x
	dc.w	$10,-x
	dc.w	$20,-x
	dc.w	$40,-x
	dc.w	$80,-x
	dc.w	$100,-x
	dc.w	$200,-x
	dc.w	$400,-x
	dc.w	$800,-x
	dc.w	$1000,-x
	dc.w	$2000,-x
	dc.w	$4000,-x
	dc.w	$8000,-x
x	set	x+8
	endr

count_vbl	dc.w	50*10

spltbl	incbin	spltbl.bin	max=159 inc=1
spltbl2	incbin	spltbl2.bin  max=99*160 inc=160

;---------------------------------------------------------------;
	BSS			;
;---------------------------------------------------------------;
buftbl	ds.l	65536

sauve_a7	ds.l	1
flag_vbl	ds.w	1
work	ds.l	1
save	ds.l	50

clear	ds.l	1

clear_rout1	ds.l	nb
	ds.w	1
clear_rout2	ds.l	nb
	ds.w	1

routines	ds.w	15*nb
	ds.l	7

ecran0	ds.l	8000+64

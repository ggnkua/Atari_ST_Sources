	opt x-
hauteur	equ	95		* logo exo7
spd	equ	2		* vitesse du scrolling : 0,1,2 ou 4
**************************
* Test superviseur + set *
**************************
	move.w	sr,d0
	btst	#13,d0
	bne.s	begin
	clr.w	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
begin:
**************
* Efface BSS *
**************
	lea	dbss(pc),A0
	lea	fbss,a1
loop:	clr.b	(a0)+
	cmp.l	a1,a0
	bne.s	loop
********************
* adr initiale ecr *
********************
	move.l	$44e.w,oldecr
	move.b	$ffff8260.w,oldrez
*************************
* adr divisible par 256 *
*************************
	move.l	#ecrans,d0
	clr.b	d0
	add.l	#256,d0
	move.l	d0,log
	move.l	d0,log1
	add.l	#16*8*160,d0
	move.l	d0,log2
***************
* save colors *
***************
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol
***************
* set palette *
***************
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
**************
* set screen *
**************
	move.b	log+1(pc),$ffff8201.w
	move.b	log+2(pc),$ffff8203.w
	clr.b	$ffff8260.w
*************************
* affiche img ds buffer *
*************************
	move.l	log,a1
	bsr	recopie
	
	moveq.w	#(34+16)-1,d1
lignes:
	bsr	scroll
	
	lea	image2(pc),a0
	move.w	#8*160/4-1,d0
loop1:	move.l	(a0)+,(a1)+
	dbra	d0,loop1

	dbra	d1,lignes
*****************
* install routs *
*****************
	bsr	initmfp

	move.l	#hbl,$68.w
	move.l	#vbl,$70.w

	clr.l	d0
	bsr	player

***********
* program *
***********
main:
	addi.l	#spd*8*160,log1
	move.l	log2,a0
	cmp.l	log1,a0
	bne.s	suit1
	move.l	log,log1
suit1:
	move.b	log1+1(pc),$ffff8201.w
	move.b	log1+2(pc),$ffff8203.w
	
	bsr.s	vsync
	bsr	player+8
	
;	move.w	#$700,$ffff8240.w
	bsr	getfond
;	move.w	#$070,$ffff8240.w
	bsr	putlogo
;	move.w	#$007,$ffff8240.w
	bsr	putfond
;	move.w	#$000,$ffff8240.w

	cmpi.b	#57,$fffffc02.w
	bne.s	main

********************
* fin interruption *
********************
	bsr	finmfp
*****************
* teste clavier *
*****************
error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:
*********************
* restaure couleurs *
*********************
	movem.l	savcol(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
******************
* restaure ecran *
******************
	move.b	oldecr+1(pc),$ffff8201.w
	move.b	oldecr+2(pc),$ffff8203.w
	move.b	oldrez(pc),$ffff8260.w
*********************
* arrete la musique *
*********************
	bsr	player+4	
********
* quit *
********
	clr.w	-(sp)
	trap	#1

************
* routines *
************
vsync:	move.l	$466.w,d0
vlp:	cmp.l	$466.w,d0
	beq.s	vlp
	rts
recopie:	
	lea	image(pc),a0
	lea	image2(pc),a2

	moveq.w	#7,d1
recopligne:
	moveq.w	#19,d0
recop:	move.l	(a0),(a2)+
	move.l	4(a0),(a2)+
	dbra	d0,recop
	addq.l	#8,a0
	dbra	d1,recopligne
	rts

getfond:	
	move.l	log1,a0
	lea	(40+hauteur*160)(a0),a0
	move.l	a0,adrlogo
	
	lea	fond(pc),a1
	moveq.w	#31,d0
getloop:
	moveq.w	#9,d1
getg:	move.l	(a0)+,(a1)+
	addq.l	#4,a0
	dbra	d1,getg
	lea	80(a0),a0
	dbra	d0,getloop
	rts
putfond:
	lea	fond(pc),a0
	move.l	adrlogo(pc),a1
	moveq.l	#0,d1
	moveq.w	#31,d0
putloop:
	rept	10
	move.l	(a0)+,(a1)+
	move.l	d1,(a1)+
	endr
	lea	80(a1),a1
	dbra	d0,putloop
	rts
	
scroll:
	move.l	#image2,a0
	moveq.w	#7,d7
scrloop:

scr	set	152
	rept	20
	roxl	scr(a0)
scr	set	scr-8
	endr
	bcc.s	scr2
	addq.w	#1,152(a0)
; droite:	btst	#15,0(a0)
scr2:

scr	set	154
	rept	20
	roxl	scr(a0)
scr	set	scr-8
	endr
	bcc.s	scr3
	addq.w	#1,154(a0)
scr3:

	lea	160(a0),a0
	dbra	d7,scrloop
	rts
putlogo:
	lea	logo(pc),a0
	move.l	adrlogo(pc),a1
	moveq.w	#31,d0
logoloop:
	moveq.w	#9,d1
repeat:

	MOVE.W	(A0)+,D3	Premier plan
	MOVE.W	D3,D2		Premier plan dans masque
	SWAP	D3
	
	MOVE.W	(A0)+,D3	Deuxiäme plan
	OR.W	D3,D2		Or masque

	MOVE.W	(A0)+,D5	Troisiäme plan
	OR.W	D5,D2		Or masque
	SWAP	D5

	MOVE.W	(A0)+,D5	Quatriäme plan
	OR.W	D5,D2		Or masque

	NOT.W	D2		Not masque
	MOVE.W	D2,D6
	SWAP	D2
	MOVE.W	D6,D2		Masque pour 2 plans

	AND.L	D2,(A1)		Masque and fond
	OR.L	D3,(A1)+	Sprite or fond
	AND.L	D2,(A1)		Masque and fond
	OR.L	D5,(A1)+	Sprite or fond

	dbra	d1,repeat
	lea	80(a1),a1
	dbra	d0,logoloop
	rts


hbl:	rte

initmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp(pc),a1
	moveq.w	#16,d0
savemfp:move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7		* On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+32
	movem.l	$58.w,d0-d7		* Et 68000...
	movem.l	d0-d7,oldvec+64

	bclr	#3,$fffffa17.w
	
	clr.b	$fffffa19.w		* Arret Timer A (Reg control)
	clr.b	$fffffa1b.w		* Arret Timer B (Reg control)

	move.b	#1,$fffffa07.w		* On lance le timer B seul
	move.b	#1,$fffffa13.w		* Pareil avec le masque
	
	clr.b	$fffffa09.w		* Pas de Timer C et D
	clr.b	$fffffa15.w
	rte
	
finmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp(pc),a0
	lea	$fffffa01.w,a1
	moveq.w	#16,d0
restmfp:move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,restmfp
	
	movem.l	oldvec(pc),d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+32(pc),d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+64(pc),d0-d7
	movem.l	d0-d7,$58.w
	rte
	

VBL22:
	movem.l	d0-a6,-(sp)

	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr
	
	lea	$ffff820a.w,a0			; Frequence	

	lea	color(pc),a4
	move.l	(a4)+,$ffff8242.w
	move.w	(a4)+,$ffff8246.w
	move.l	a4,adrcolor
	
	clr.b	count
	
	dcb.w	79-17,$4e71			; !!!!
	
*~~~~~	Border haut     ~~~~~*
	move.b	#0,(a0)				; 60 Hz
	dcb.w	16,$4e71
	move.b	#2,(a0)				; 50 Hz
********
	move.l	#raster,$120.w			; Vecteur Timer B
	clr.b	$fffffa1b.w			; On stoppe le Timer B
	move.b	#8,$fffffa21.w		;
	move.b	#8,$fffffa1b.w			; Frequence de 369 Hz
	ori.b	#%000000001,$fffffa07.w
********

	
	movem.l	(sp)+,d0-a6
	rte

raster:
	move.l	adrcolor(pc),a4
	move.l	(a4)+,$ffff8242.w
	move.w	(a4)+,$ffff8246.w
	addq.l	#6,adrcolor
	
	addq.b	#1,count
	cmp.b	#28,count
	bne.s	rast2
	
	move.l	#bas,$120.w
	clr.b	$fffffa1b.w
	move.b	#4,$fffffa21.w
	move.b	#8,$fffffa1b.w
	ori.b	#1,$fffffa07.w
	bra.s	rast3
rast2:	
	move.l	#raster,$120.w
	clr.b	$fffffa1b.w
	move.b	#8,$fffffa21.w
	move.b	#8,$fffffa1b.w
	ori.b	#1,$fffffa07.w
rast3:	
	rte
	
vbl:

	move.l	#VBL22,$120.w			; Vecteur Timer B
	clr.b	$fffffa1b.w			; On stoppe le Timer B
	move.b	#98,$fffffa21.w			;
	move.b	#4,$fffffa1b.w			; Frequence de 369 Hz
	ori.b	#1,$fffffa07.w

	addq.l	#1,$466.w
	rte

bas:
	move.b	#0,$fffffa1b.w
	dcb.w	95+2+4,$4e71
	move.b	#0,$ffff820a.w
	dcb.w	14-4,$4e71
	move.b	#2,$ffff820a.w
	move.b	#0,$ffff820a.w
	dcb.w	14-4,$4e71
	move.b	#2,$ffff820a.w

	move.l	#raster,$120.w
	clr.b	$fffffa1b.w
	move.b	#3,$fffffa21.w
	move.b	#8,$fffffa1b.w
	ori.b	#1,$fffffa07.w

	rte
********************	
	section	data
********************
logo:	incbin	logo.bi2
palette:
	dc.w	$000
	dc.w	$420,$530,$640			* Petits logos
	dc.w	$133,$244,$355,$466,$577,$000
	dc.w	$301,$402,$503,$604,$705	* Grand Logo EXO7
	dc.w	$777
image:		include	ligne2.doo
player:		incbin	sb.mus
color:
	rept	3
	dc.w	$700,$600,$500
	dc.w	$730,$620,$510
	dc.w	$750,$640,$530
	dc.w	$770,$660,$550
	dc.w	$470,$360,$250
	dc.w	$070,$060,$050
	dc.w	$074,$063,$052
	dc.w	$077,$066,$055
	dc.w	$057,$046,$035
	dc.w	$027,$016,$005
	dc.w	$007,$006,$005
	dc.w	$407,$306,$205
	dc.w	$707,$606,$505
	dc.w	$704,$603,$502
	endr
*******************
	section	bss
*******************

dbss:
oldecr:	ds.l	1
oldrez:	ds.w	1

savcol:	ds.w	16
oldmfp	ds.b	24
oldvec	ds.l	24

count:	ds.w	1

log:	ds.l	1
log1:	ds.l	1
log2:	ds.l	1

adrlogo:	ds.l	1
adrcolor:	ds.l	1

image2:	ds.b	8*160
fond:	ds.l	80*32/4
ecrans:	ds.b	256
	ds.b	274*160
	ds.b	16*8*160
fbss:
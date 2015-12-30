**************
* Constantes *
**************
palraster	=	$ffff8240+2*0
attente	=	50*3
nbbarre	=	24	; 51 au max
ecart	=	3
nb_vbl	=	1
****************
* GUARDIAN !!! *
****************
*	trap	#0
	
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
	lea	dbss,a0
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
***************
* save colors *
***************
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol
**************
* set screen *
**************
	move.b	log+1(pc),$ffff8201.w
	move.b	log+2(pc),$ffff8203.w
	bsr	vsync
	clr.b	$ffff8260.w
	bsr	vsync
**********************************
* Code le texte pour l'affichage *
**********************************
	bsr	calculetexte
	bsr	calctexte
	bsr	predecalage
	bsr	terminesinus
*****************
* install routs *
*****************
	clr.l	count2
	bsr	initmfp

	move.l	#hbl,$68.w
	move.l	#vbl,$70.w

	moveq	#1,d0
	bsr	madmax
*****************
* rempli ybarre *
*****************
	lea	ybarre,a0
	move.w	#0,d0
	move.w	#nbbarre-1,d1
rempli:	move.w	d0,(a0)+
	add.w	#ecart,d0
	cmp.w	#199,d0
	bls.s	rem2
	sub.w	#200,d0
rem2:
	dbra	d1,rempli
	
***********
* program *
***********
	move.w	#10,equa1
	move.w	#10,equa2
	move.w	#10,equa3
	
	move.l	#tablehazard,numtable	* numtable pointe sur nb 0..4 
	move.l	#sinustable,pointsin	* pointsin .. table des offsets
		
	lea	texte2,a6		* A6=TEXTE2
	move.w	#nb_vbl,waitvbl
repeat:

* Adresse de la table d'apparition du texte *
	move.l	numtable,a0
	clr.w	d0
	move.b	(a0),d0
	cmpi.b	#-1,d0
	bne.s	adrtabsuit
	move.l	#tablehazard,numtable
	move.l	numtable,a0
	clr.w	d0
	move.b	(a0),d0
adrtabsuit:
	mulu	#400,d0
	addq.l	#1,numtable
	lea	table,a0
	lea	(a0,d0.l),a0
	move.l	a0,pointable
	
	move.w	#200*nb_vbl-1,d0
afftexte:
	
	bsr	vsync
;	MOVE.W	#$700,$FFFF8240.W
	bsr	affichelelogo
;	MOVE.W	#$70,$FFFF8240.W	
	bsr	volume	
	bsr	equalizer	
;	MOVE.W	#$707,$FFFF8240.W
	bsr	waitunpeu
;	MOVE.W	#$7,$FFFF8240.W
	movem.l	d0-a6,-(sp)
	bsr	madmax+8
	movem.l	(sp)+,d0-a6
;	CLR.W	$FFFF8240.W

* Si on doit attendre pour afficher la lettre *	
	subq.w	#1,waitvbl
	bne	pastexte

* Si on l'affiche *	
	move.w	#nb_vbl,waitvbl

	move.l	pointable,a5

* Calcul de la lettre a afficher *
	clr.l	d1
	clr.l	d3
	move.b	(a5),d1
	move.b	1(a5),d3
	lsl.w	#1,d1
	mulu	#40,d3
	add.l	d1,d3

* Calcul de l'adresse dans la fonte *		
	move.w	(a6,d3),d1
	tst.w	d1
	bpl.s	colsuit
	lea	texte2,a6
	clr.l	d1
	clr.l	d3
	move.b	(a6),d1
	move.b	1(a6),d3
	lsl.w	#1,d1
	mulu	#20,d3
	add.w	d1,d3	
	move.w	(a6,d3),d1
colsuit:	* Affichage *
	lea	fonte,a0			
	lea	(a0,d1.w),a0
	move.l	log,a1
	lea	160*108(a1),a1
	clr.l	d1
	move.b	(a5)+,d1
	lsl.w	#3,d1
	lea	(a1,d1.w),a1
	clr.l	d1
	move.b	(a5)+,d1
	mulu	#160*16,d1
	lea	(a1,d1.w),a1
	rept	16
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	152(a1),a1
	endr
	
	move.l	a5,pointable
pastexte:
	cmpi.b	#57,$fffffc02.w
	beq	fin
	
	dbra	d0,afftexte

* A la fin du texte : on attends un peu *	
	move.w	#attente-1,d0
wait:	bsr	vsync
	bsr	affichelelogo
	bsr	volume	
	bsr	equalizer	
	bsr	waitunpeu
	movem.l	d0-a6,-(sp)
	bsr	madmax+8
	movem.l	(sp)+,d0-a6
	cmpi.b	#57,$fffffc02.w
	beq.s	fin
	dbra	d0,wait

* On efface le texte *
	move.l	log,a0
	lea	160*108(a0),a0
	move.w	#160/2-1,d0
clrligne:
	bsr	vsync
	move.w	#40*2-1,d1
effass:	clr.l	(a0)+
	dbra	d1,effass
	movem.l	d0-d1/a0,-(sp)
	bsr	affichelelogo
	bsr	volume
	bsr	equalizer
	bsr	waitunpeu
	movem.l	d0-a6,-(sp)
	bsr	madmax+8
	movem.l	(sp)+,d0-a6
	movem.l	(sp)+,d0-d1/a0
	cmpi.b	#57,$fffffc02.w
	beq.s	fin
	dbra	d0,clrligne
	
* Et On repart ( nouveau texte a afficher => a6 ) *
	lea	20*10*2(a6),a6
	tst.w	(a6)
	bpl	repeat
	lea	texte2,a6

	bra	repeat
	
fin:	
********************
* fin interruption *
********************
	bsr	finmfp
	moveq	#0,d0
	bsr	madmax
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
	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
******************
* restaure ecran *
******************
	bsr.s	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	bsr.s	vsync
	move.b	oldrez,$ffff8260.w
********
* quit *
********
	clr.w	-(sp)
	trap	#1

************
* routines *
************
vsync:	move.l	d0,-(sp)
	move.l	$466.w,d0
vlp:	cmp.l	$466.w,d0
	beq.s	vlp
	move.l	(sp)+,d0
	rts

hbl:	rte

initmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
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
	move.b	#0,$fffffa1b.w		* Arret Timer B (Reg control)

	move.b	#1,$fffffa07.w		* On lance le timer B seul
	move.b	#1,$fffffa13.w		* Pareil avec le masque
	
	clr.b	$fffffa09.w		* Pas de Timer C et D
	clr.b	$fffffa15.w
	rte
	
finmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	moveq.w	#16,d0
restmfp:move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+32,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+64,d0-d7
	movem.l	d0-d7,$58.w
	rte
	

VBL22:
	movem.l	d0-a6,-(sp)

	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr
	
	lea	$ffff820a.w,a0

	move.b	#226,count	; 227

	dcb.w	77,$4e71			
	move.b	#0,(a0)
	dcb.w	16,$4e71
	move.b	#2,(a0)
	
	move.l	#rastertop,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	
	movem.l	(sp)+,d0-a6
	rte

rastertop:		* Jusqu'aux lettres
	move.l	a4,-(sp)
	move.l	adrbackground(pc),a4
	move.w	(a4)+,palraster.w
	addq.l	#2,adrbackground
	move.l	(sp)+,a4
	
	subq.b	#1,count
	cmpi.b	#227-32,count
	bne.s	rast2
	
	move.l	#changecolor1,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
rast2:	
	move.l	#rastertop,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
changecolor1:
	move.l	a4,-(sp)

	move.l	adrbackground(pc),a4
	move.w	(a4)+,palraster.w
	addq.l	#2,adrbackground
	
	move.l	#rastermilieu,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w

	subq.b	#1,count

;palettelogo:	dc.w	$000,$100,$211,$322,$433,$544,$655,$766
;		dc.w	$310,$420,$530,$641,$652,$763,$774,$777
	lea	$ffff8242.w,a4
	move.l	#$01000211,(a4)+
	move.l	#$03220433,(a4)+
	move.l	#$05440655,(a4)+
	move.l	#$07660310,(a4)+
	move.l	#$04200530,(a4)+
	move.l	#$06410652,(a4)+
	move.l	#$07630774,(a4)+
	move.w	#$777,(a4)+
	
	move.l	(sp)+,a4
	rte
rastermilieu:		* Jusqu'aux lettres
	move.l	a4,-(sp)
	move.l	adrbackground(pc),a4
	move.w	(a4)+,palraster.w
	addq.l	#2,adrbackground
	move.l	(sp)+,a4
	
	subq.b	#1,count
	cmpi.b	#227-92,count
	bne.s	rast3
	
	move.l	#changecolor2,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
rast3:	
	move.l	#rastermilieu,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
changecolor2:
	move.l	a4,-(sp)

	move.l	adrbackground(pc),a4
	move.w	(a4)+,palraster.w
	addq.l	#2,adrbackground
	
	move.l	#rasterbas,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w

	subq.b	#1,count

fontenum	=	1
	ifeq	fontenum-3
;sgt3:	dc.w	$000,$210,$320,$430,$540,$650,$651,$211,$221
;	dc.w	$231,$241,$252,$262,$273,$274,$777
	lea	$ffff8242.w,a4
	move.l	#$02100320,(a4)+
	move.l	#$04300540,(a4)+
	move.l	#$06500651,(a4)+
	move.l	#$02110221,(a4)+
	move.l	#$02310241,(a4)+
	move.l	#$02520262,(a4)+
	move.l	#$02730274,(a4)+
	move.w	#$777,(a4)+
	endc
	ifeq	fontenum-2
;mega2:	dc.w	0,$013,$024,$035,$046,$156,$266,$376,$477,$112
;	dc.w	$223,$334,$445,$556,$667,$766
	lea	$ffff8242.w,a4
	move.l	#$00130024,(a4)+
	move.l	#$00350046,(a4)+
	move.l	#$01560266,(a4)+
	move.l	#$03760477,(a4)+
	move.l	#$01120223,(a4)+
	move.l	#$03340445,(a4)+
	move.l	#$05560667,(a4)+
	move.w	#$766,(a4)+
	endc
	ifeq	fontenum-1
; dc.w	$0000,$0230,$0123,$0234,$0345,$0456,$0567,$0677
; dc.w	$0070,$0170,$0270,$0370,$0470,$0570,$0670,$0777
	lea	$ffff8242.w,a4
	move.l	#$0,(a4)+
	move.l	#$0,(a4)+
	move.l	#$0,(a4)+
	move.l	#$0,(a4)+
	move.l	#$0,(a4)+
	move.l	#$0,(a4)+
	move.l	#$0,(a4)+
	move.w	#$0,(a4)+
	endc

	move.l	(sp)+,a4
	rte
	
rasterbas:	* a partir des lettres
	move.l	a4,-(sp)
	move.l	adrbackground(pc),a4
	move.w	(a4)+,palraster.w
	addq.l	#2,adrbackground
	move.l	(sp)+,a4
	
	subq.b	#1,count
	cmpi.b	#227-106,count	
	bne.s	rast4
	
	move.l	#changecolor3,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
rast4:	
	move.l	#rasterbas,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
changecolor3:
	move.l	a4,-(sp)

	move.l	adrbackground(pc),a4
	move.w	(a4)+,palraster.w
	addq.l	#2,adrbackground
	
	move.l	#rasterplusbas,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w

	subq.b	#1,count

;palettefonte2:	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
;		dc.w	$777,$666,$555,$444,$333,$222,$111,$777
	lea	$ffff8242.w,a4
	move.l	#$01000200,(a4)+
	move.l	#$03000400,(a4)+
	move.l	#$05000600,(a4)+
	move.l	#$07000777,(a4)+
	move.l	#$06660555,(a4)+
	move.l	#$04440333,(a4)+
	move.l	#$02220111,(a4)+
	move.w	#$777,(a4)+
		
	move.l	(sp)+,a4
	rte
rasterplusbas:	* a partir des lettres
	move.l	a4,-(sp)
	move.l	adrbackground(pc),a4
	move.w	(a4)+,palraster.w
	addq.l	#2,adrbackground
	move.l	(sp)+,a4
	
	subq.b	#1,count
	bne.s	rast5
	
	move.l	#bas,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
rast5:	
	move.l	#rasterplusbas,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte
	
vbl:

	move.l	#VBL22,$120.w			; Vecteur Timer B
	move.b	#0,$fffffa1b.w			; On stoppe le Timer B
	move.b	#98,$fffffa21.w			;
	move.b	#4,$fffffa1b.w			; Frequence de 369 Hz
	move.b	#1,$fffffa07.w

	movem.l	d0-a6,-(sp)

	movem.l	palettefonte1,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.w	palraster.w
	lea	background(pc),a0
	addq.l	#2,count2
	add.l	count2(pc),a0

	cmpi.b	#val,count2+3
	bne.s	vblsuit
	clr.l	count2
vblsuit:
	lea	fond,a1
	move.l	a1,adrbackground
	rept	274/2
	move.l	(a0)+,(a1)+
	endr

	lea	rastercourbe(pc),a0
	lea	ybarre(pc),a1
	lea	barre(pc),a2
	lea	fond,a3

	move.w	#nbbarre-1,d1
sinus:	addq.w	#1,(a1)	
	cmpi.w	#200,(a1)
	bne.s	sinus2
	clr.w	(a1)
sinus2:
	move.w	(a1)+,d0
	lsl.w	d0
	move.w	(a0,d0.w),d0
	lsl.w	d0
	lea	(a3,d0.w),a4
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.w	(a2)+,(a4)+
	dbra	d1,sinus
;	lea	fond,a3
;	clr.l	184(a3)	
;	clr.l	188(a3)
;	clr.l	192(a3)
;	clr.l	196(a3)
	
	bsr	scroll1
	addq.l	#1,$466.w
	movem.l	(sp)+,d0-a6
	rte

bas:
	move.b	#0,$fffffa1b.w

	move.w	fond+2*226,palraster.w
	dcb.w	95+6-6,$4e71		
	
	move.b	#0,$ffff820a.w
	dcb.w	14-4,$4e71
	move.b	#2,$ffff820a.w
	move.b	#0,$ffff820a.w
	
	dcb.w	14-6-4,$4e71		
	move.w	fond+2*227,palraster.w
	
	move.b	#2,$ffff820a.w
	addq.l	#4,adrbackground

	move.l	#rasterbas,$120.w
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa07.w
	rte

volume:
	clr.l	d1
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d1
	btst	#4,d1
	beq.s	eq1
	move.b	#10,d1
eq1:	
	cmp.w	equa1,d1
	beq.s	eq2
	move.w	d1,equa1
	bra.s	eq3
eq2:
	cmpi.w	#0,equa1
	bls.s	eq3
	subq.w	#1,equa1
eq3:
	clr.l	d1
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d1
	btst	#4,d1
	beq.s	eq4
	move.b	#10,d1
eq4:	
	cmp.w	equa2,d1
	beq.s	eq5
	move.w	d1,equa2
	bra.s	eq6
eq5:
	cmpi.w	#0,equa2
	bls.s	eq6
	subq.w	#1,equa2
eq6:
	clr.l	d1
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d1
	btst	#4,d1
	beq.s	eq7
	move.b	#10,d1
eq7:	
	cmp.w	equa3,d1
	beq.s	eq8
	move.w	d1,equa3
	bra.s	eq9
eq8:
	cmpi.w	#0,equa3
	bls.s	eq9
	subq.w	#1,equa3
eq9:
	rts
equalizer:
	lea	fonte+128*05(pc),a0	*
	move.l	log(pc),a1
	lea	40+8*0(a1),a1
	move.w	equa1,d3
	bsr	affequa
	lea	fonte+128*00(pc),a0	*
	move.l	log(pc),a1
	lea	40+8(a1),a1
	move.w	equa2,d3
	bsr	affequa
	lea	fonte+128*11(pc),a0	*
	move.l	log(pc),a1
	lea	40+16(a1),a1
	move.w	equa3,d3
	bsr.s	affequa
	lea	fonte+128*02(pc),a0	*
	move.l	log(pc),a1
	lea	40+8*3(a1),a1
	move.w	equa1,d3
	bsr.s	affequa
	lea	fonte+128*14(pc),a0	*
	move.l	log(pc),a1
	lea	40+8*4(a1),a1
	move.w	equa2,d3
	bsr.s	affequa
	lea	fonte+128*13(pc),a0	*
	move.l	log(pc),a1
	lea	40+8*5(a1),a1
	move.w	equa3,d3
	bsr.s	affequa
	lea	fonte+128*26(pc),a0	*
	move.l	log(pc),a1
	lea	48+8*6(a1),a1
	move.w	equa1,d3
	bsr.s	affequa
	lea	fonte+128*29(pc),a0	*
	move.l	log(pc),a1
	lea	48+8*7(a1),a1
	move.w	equa2,d3
	bsr.s	affequa
	lea	fonte+128*26(pc),a0	*
	move.l	log(pc),a1
	lea	48+8*8(a1),a1
	move.w	equa3,d3
	bsr.s	affequa
	rts
affequa:
	move.w	d3,d4
	neg.w	d3
	add.w	#15,d3
clr1:	clr.l	(a1)+
	clr.l	(a1)+
	lea	152(a1),a1	
	dbra	d3,clr1
	rept	16
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	152(a1),a1
	endr
clr2:	clr.l	(a1)+
	clr.l	(a1)+
	lea	152(a1),a1
	dbra	d4,clr2
	rts
affichelelogo:
	movem.l	d0-d4/a0-a5,-(sp)
;	clr.l	d3
;	clr.l	d4
	move.l	pointsin(pc),a2
	lea	t2816(pc),a3
	lea	t88(pc),a4
	move.l	log(pc),a0
	lea	160*16*3(a0),a0
	moveq.w	#62,d1
afflogo:
	lea	buffer,a1
	clr.w	d2
	clr.w	d3
	move.b	(a2)+,d2
	move.b	(a2)+,d3
	tst.b	d3
	bpl.s	afflogo2
	move.l	#sinustable,pointsin
	move.l	pointsin(pc),a2
	move.b	(a2)+,d2
	move.b	(a2)+,d3
afflogo2:
	move.w	(a3,d3.w),d3
	moveq.w	#62,d4
	sub.w	d1,d4
	move.w	(a4,d4.w),d4
	add.w	d3,d4
	lea	(a1,d4.l),a1
	movea.l	a0,a5
	lea	(a5,d2.w),a5
	rept	22
	move.l	(a1)+,(a5)+
	endr
	lea	160(a0),a0
	
	subq.w	#2,d1
	bpl	afflogo
	
	addq.l	#2,pointsin
	movem.l	(sp)+,d0-d4/a0-a5
	rts
predecalage:
	lea	buffer,a6
	move.w	#15,d2
seize:
	lea	logo,a0
	move.w	#2816/4-1,d0
rec1:	move.l	(a0)+,(a6)+
	dbra	d0,rec1
	lea	logo,a0
	move.w	#31,d0
scr1:	
	moveq	#0,d1
	roxr	d1
adr	set	0
	rept	11
	roxr	adr(a0)
adr	set	adr+8
	endr
	moveq	#0,d1
	roxr	d1
adr	set	2
	rept	11
	roxr	adr(a0)
adr	set	adr+8
	endr
	moveq	#0,d1
	roxr	d1
adr	set	4
	rept	11
	roxr	adr(a0)
adr	set	adr+8
	endr
	moveq	#0,d1
	roxr	d1
adr	set	6
	rept	11
	roxr	adr(a0)
adr	set	adr+8
	endr
	lea	88(a0),a0
	dbra	d0,scr1	
	dbra	d2,seize
	rts		
terminesinus:
	lea	sinustable,a0
	lea	finsinustable,a1
	move.w	#31,d0
term:	move.w	(a0)+,(a1)+
	dbra	d0,term
	move.w	#9,d0	
term2:	move.b	#-1,(a1)+
	dbra	d0,term2
	rts
scroll1:
	movem.l	d0-a6,-(sp)
hauteur	=	94
	move.l	log,a0
	lea	hauteur*160(a0),a0
	move.w	#7,d7
loop1:	moveq	#0,d0
	roxl	d0
st	set	160-8
	rept	20
	roxl	st(a0)
st	set	st-8
	endr
	moveq	#0,d0
	roxl	d0
st	set	160-8
	rept	20
	roxl	st+2(a0)
st	set	st-8
	endr
	moveq	#0,d0
	roxl	d0
st	set	160-8
	rept	20
	roxl	st+4(a0)
st	set	st-8
	endr
	moveq	#0,d0
	roxl	d0
st	set	160-8
	rept	20
	roxl	st+6(a0)
st	set	st-8
	endr
	lea	160(a0),a0
	dbra	d7,loop1

	lea	-8*160(a0),a0
	move.w	posx1,d6
	subq.w	#1,d6
	bge.s	.ok2
	move.l	pttex1,a1
	move.w	(a1)+,d0
	cmp.l	ftexte1,a1
	blt.s	.ok1
	lea	texte1,a1
.ok1:	move.w	d0,offl1
	move.l	a1,pttex1
	moveq	#7,d6
.ok2:	move.w	d6,posx1
	move.w	offl1,d0
	lea	font1,a2
	adda.w	d0,a2
	moveq	#0,d5
	bset	d6,d5
st	set	0
	rept	8
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+2(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+4(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+6(a0)
st	set	st+160
	endr
	movem.l	(sp)+,d0-a6
	rts
waitunpeu:
	move.l	d0,-(sp)
	dcb.w	1200,$4e71
	move.l	(sp)+,d0
	rts
	include	calcule.dat
	include	calctxt.dat	
********************	
	section	data
********************
ybarre:		dcb.w	nbbarre*2,0
count:		dc.w	0
count2:		dc.l	0
log:		dc.l	0
img:		dc.l	0
adrbackground:	dc.l	0
pttex1:	dc.l	texte1
posx1:	dc.w	7
offl1:	dc.w	32*26
font1:	incbin	font2.bin
palettefonte1:	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
		dc.w	$777,$666,$555,$444,$333,$222,$111,$777
;		dc.w	$777,$600,$500,$400,$300,$200,$100,$700
palettefonte2:	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
		dc.w	$777,$666,$555,$444,$333,$222,$111,$777
palettelogo:	dc.w	$000,$100,$211,$322,$433,$544,$655,$766
		dc.w	$310,$420,$530,$641,$652,$763,$774,$777
logo:		incbin	exo7.dat
fonte:		incbin	fonte.bin
rastercourbe:	incbin	rastcur2.bin
madmax:		incbin	rip6.mus
background:
val=42*2	; 72 ou 42
	rept	5*2
	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$670,$570,$470,$370,$270,$170,$070
	dc.w	$071,$072,$073,$074,$075,$076,$077
	dc.w	$067,$057,$047,$037,$027,$017,$007
	dc.w	$107,$207,$307,$407,$507,$607,$707
	dc.w	$706,$705,$704,$703,$702,$701
	endr
barre:	
	rept	nbbarre/6
;	* 1=tricolor 2=red 3=vert 4=bleu 5=jaune 6=violet 7=bleu c. 8=gris
;	dc.w	$007,$117,$227,$337,$447,$557,$667,$777,$766,$755,$744,$733,$722,$711,$700
;	dc.w	$100,$200,$300,$400,$500,$600,$700,$711,$711,$700,$600,$500,$400,$300,$200
;	dc.w	$010,$020,$030,$040,$050,$060,$070,$171,$171,$070,$060,$050,$040,$030,$020
;	dc.w	$001,$002,$003,$004,$005,$006,$007,$117,$117,$007,$006,$005,$004,$003,$002
;	dc.w	$110,$220,$330,$440,$550,$660,$770,$771,$771,$770,$660,$550,$440,$330,$220
;	dc.w	$101,$202,$303,$404,$505,$606,$707,$717,$717,$707,$606,$505,$404,$303,$202
;	dc.w	$011,$022,$033,$044,$055,$066,$077,$177,$177,$077,$066,$055,$044,$033,$022
;	dc.w	$111,$222,$333,$444,$555,$666,$777,$777,$777,$777,$666,$555,$444,$333,$222
;	* 1=bois 2=vert pomme 3=bx 4=bleu-gris 5=vert c. 6=mauve
	dc.w	$210,$210,$321,$432,$543,$654,$765,$776,$765,$654,$543,$432,$321,$210,$210
	dc.w	$120,$120,$231,$342,$453,$564,$675,$776,$675,$564,$453,$342,$231,$120,$120
	dc.w	$201,$201,$312,$423,$534,$645,$756,$767,$756,$645,$534,$423,$312,$201,$201
	dc.w	$012,$012,$123,$234,$345,$456,$567,$677,$567,$456,$345,$234,$123,$012,$012
	dc.w	$021,$021,$132,$243,$354,$465,$576,$677,$576,$465,$354,$243,$132,$021,$021
	dc.w	$102,$102,$213,$324,$435,$546,$657,$767,$657,$546,$435,$324,$213,$102,$102
	endr
texte:	
	DC.B	"   DYNO  PRESENTS   "
	DC.B	"********************"
	DC.B	"                    "
	DC.B	" ZE COLORTALKS DEMO " 
	DC.B	"                    "
	DC.B	"********************"
	DC.B	"  CODE ...... DYNO  "
	DC.B	"GFX .. SAMOS,SERGENT"
	DC.B	"  MUSIC ... MADMAX  "
	DC.B	"********************"

	DC.B	"                    "
	DC.B	"THIS DEMO WILL BE MY"
	DC.B	"LAST DEMO FOR THE ST"
	DC.B    " BECAUSE THE FALCON "
	DC.B    "IS COMING SOON, AND "
	DC.B    "   I'LL BUY ONE !   "
	DC.B	"                    "
	DC.B	"I HOPE YOU LIKE IT !"
	DC.B	"                    "
	DC.B	"********************"

	DC.B	"  EXO7 MEMBERS ARE  "
	DC.B	"   ***************  "
	DC.B	"   * BLUE MURDER *  "
	DC.B	"   *        DYNO *  "
	DC.B	"   *       GOOFY *  "
	DC.B	"   *     LE MUGE *  "
	DC.B	"   *        RICK *  "
	DC.B	"   *     SADEMAN *  "
	DC.B	"   *   SKYWALKER *  "
	DC.B	"   ***************  "

	DC.B	"                    "
	DC.B	"                    "
	DC.B	"THE GREETINGS GO TO "
	DC.B	" THE CREWS WHO MADE "
	DC.B	"  MY FAVORITE DEMOS "
	DC.B	"ON STF , WHICH MEANS"
	DC.B	"                    "
	DC.B	"( NO SPECIAL ORDER )"
	DC.B	"                    "
	DC.B	"                    "

	DC.B	"                    "
	DC.B	" OVERLANDERS (GREAT "
	DC.B	"WORK ! EUROPEAN DEMO"
	DC.B	"PHALEON, PUNISH YOUR"
	DC.B	"MACHINE, LIGHTNING) "
	DC.B	"                    "
	DC.B	" ULM (THE DARK SIDE "
	DC.B	"   OF THE SPOON IS  "
	DC.B	"FABULOUS !!!!!!!!!!)"
	DC.B	"                    "
	
	DC.B	"     PENDRAGONS     "
	DC.B	"(LIGHTNING DEMO THE "
	DC.B	"FIRST DEMO I SAW ON "
    DC.B    "ATARI ST)           "
	DC.B	"                    "
	DC.B	"ALL THE FRENCH CREWS"
	DC.B	"WHO TAKE PART TO THE"
	DC.B	"TRANSBEAUCE II DEMO "
	DC.B	"(UNDEAD, NAOS, DNT, "
    DC.B    "...)                "
	
	DC.B	"ACF (JUST BUGGIN IS "
	DC.B	"  A COOL DEMO !!! ) "
	DC.B	"                    "
	DC.B	"DELTA FORCE (GREAT  "
	DC.B	"PUNISH YOUR MACHINE "
	DC.B	"EXCEPT SOME BUGS !!)"
	DC.B	"                    "
	DC.B	"CHAOS (PANDEMONIUM  "
	DC.B	"IS WOW ! 3D, PLASMA,"
	DC.B	"...)                "
	
	DC.B	"   HEMOROIDS (THE   "
	DC.B	" FULLPART IS GENIAL,"
	DC.B	"  DENTRO,BEACHTRO,  "
	DC.B	"EUROPEAN .. EXTRA !)"
	DC.B	"                    "
	DC.B	"ARMADA ( OVERDOSE IS"
	DC.B	"SPECIAL BUT CLEAN !)"
	DC.B	"                    "
	DC.B	"INNER CIRCLE (DECADE"
	DC.B	"  IS OLD BUT GOOD)  "
	
	DC.B	"                    "
	DC.B	" NPG (A PART OF THE "
	DC.B	"NONAME DEMO IS GOOD)"
	DC.B	"                    "
	DC.B	"FUTUR MINDS (SNORK ,"
	DC.B	"TRANS II.. COOL !!) "
	DC.B	"                    "
	DC.B	"   EQUINOX (EAT MY  "
	DC.B	"BOLLOCKS ... )      "
	DC.B	"                    "
	
	DC.B	" NEXT ( THE PHALEON "
	DC.B	" IS IMPRESSIVE !!!) "
	DC.B	"                    "
	DC.B	" PHALANX (OVERDRIVE "
	DC.B	"   IS OLD BUT SOME  "
	DC.B	"SCREENS ARE GOOD !!)"
	DC.B	"                    "
	DC.B	" I THINK THAT'S ALL "
	DC.B	"FOR THE ST CREW WHO "
	DC.B	"MAKES ME DREAM ....."
	
	DC.B	"********************"
	DC.B	"*                  *"
	DC.B	"*                  *"
	DC.B	"* I HAVE NOTHING   *"
	DC.B	"* ELSE TO SAY SO   *"
	DC.B	"* I ONLY DECLARE   *"
    DC.B    "*  THAT THIS IS    *"
	DC.B	"*                  *"
	DC.B	"*                  *"
	DC.B	"********************"

	DC.B	"********************"
	DC.B	"*                  *"
	DC.B	"*                  *"
	DC.B	"*                  *"
	DC.B	"*     THE END.     *"
	DC.B	"*                  *"
	DC.B	"*                  *"
	DC.B	"*                  *"
	DC.B	"*                  *"
	DC.B	"********************"

	REPT	10
	DC.B	"********************"
	ENDR
	
	dc.w	0	
tex_init1:
	DC.B	"WOW !!!             "
	DC.B	"EXO7 WELCOME EVERYBODY HERE !!!             "
	DC.B	"THIS IS DYNO SPEAKING.             "
	DC.B	"CREDITS GO TO              "
	DC.B	"CODE BY DYNO             "
	DC.B	"MUSIC BY MADMAX             "
	DC.B	"GFX BY SAMOS             "
	DC.B	"THIS IS THE LAST INTRO I CODE FOR THE ST BECAUSE I LL BUY A FALCON 030 SOON !             "
	DC.B	"THIS IS THE END FOR MY PART OF THIS SCROLLTEXT AND NOW IT S THE TURN OF GOOFY TO SPEAK...             "
	DC.B	"A LAST LITTLE WORDS... CODE FOR FUN, NOT FOR BEING THE BEST !!!             "
	DC.B	"                       "
	DC.B	"ET VOICI LE FAMOUS GOOFY QUI PRENDS LA RELEVE ....................             "
	DC.B	"GOOFY AU CLAVIER...... ET POUR LA DERNIERE FOIS SUR ST "
	DC.B	"EXO7 EXISTERA DESORMAIS SUR FALCON, QUELQUES GREETINGS AVANT LES "
	DC.B	"ADIEUS... WIL FROM COBRA (FIN D UN LONG CONTACT DE 3 ANS)   "
	DC.B	"ZER (ON SE RETROUVERA EN SCIENCE PO.)   JEAN LUC (NANTERRE)   "
	DC.B	"INSOMNIA (JE GARDE VOTRE ADDRESSE POUR UNE FUTURE COLLABORATION SUR "
	DC.B	"FALCON)   ET ENFIN JEDI FROM SECTOR ONE (PEUT ETRE UNE FUTURE COLLABORATION "
	DC.B	"SUR FALCON)........ VOILA C EST FINI... ADIEU MONDE CRUEL.................... "
	DC.B	"SEE YOU SOON ON FALCON..... "
	DC.B	"APRIL 1993. DYNO AND GOOFY......................             "
	DC.B	"                       "
	DC.B	-1
t2816:	dc.w	0,2816,5632,8448,11264,14080,16896,19712,22528,25344,28160
	dc.w	30976,33792,36608,39424,42240
t88:	dc.w	0,88,176,264,352,440,528,616,704,792,880,968,1056,1144,1232
	dc.w	1320,1408,1496,1584,1672,1760,1848,1936,2024,2112,2200,2288
	dc.w	2376,2464,2552,2640,2728
; 1=Standard 2=Escargot 3=Vert,GtoD 4=Impair:GtoD;Pair:DtoG 5=Hazard
table:		incbin	table.bin
pointable:	dc.l	0
tablehazard:	dc.b	0,1,2,3,4,-1
numtable:	dc.l	0
pointsin:	dc.l	0
* don't touch it !! *
sinustable:	
	rept	32*4
	dc.b	4*8,28
	endr
	incbin	sin1.bin
	incbin	sin1.bin
	incbin	sin2.bin
	incbin	sin2.bin
*******************
	section	bss
*******************
dbss:
finsinustable:	ds.w	4*32*2
equa1:		ds.w	1
equa2:		ds.w	1
equa3:		ds.w	1
oldecr:		ds.l	1
oldrez:		ds.w	1

ftexte1:	ds.l	1
texte1:		ds.b	7000

savcol:		ds.w	16
oldmfp		ds.l	6
oldvec		ds.l	24

waitvbl:	ds.w	1
fond:		ds.w	274
texte2:		ds.w	(200)*20	* 10 ecrans

buffer:		ds.l	2816*4
ecrans:		ds.l	274*40+64
fbss:
***********
	end
***********
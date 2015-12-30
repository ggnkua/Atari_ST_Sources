**********************************
*    ROUTINE OVERSCAN 460*274    *
**********************************
*        BY: DYNO OF EXO7        *
**********************************
	opt o+

super:	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

*************************
* QQUES INITIALISATIONS *
*************************	
initdemo:
	move.l	$44e.w,oldecr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcol
	move.b	$ffff8260.w,oldrez
	clr.b	$ffff8260.w
	move.l	#ecran,d0
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log			; Log=adresse nouvel ecran
	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w
**********************************
* REUNI LES 272 ROUTS EN 1 SEULE *
**********************************
	bsr	generation
	moveq	#0,d0
	bsr	musique
	bsr	musique+18
**********************************
* INSTALLE LES NOUVELLES HBL-VBL *
**********************************
	bsr	initmfp
	move.l	#hbl,$68.w
	move.l	#vbl,$70.w
*****************************
* PALETTE+AFFICHE IMAGE KID *
*****************************
	movem.l	image+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	log,a0
	lea	image+34,a1
	move.w	#204/4-1,d0		; une ligne vide
cls1:	clr.l	(a0)+
	dbra	d0,cls1
	move.w	#63020/4-1,d0
cls2:	move.l	(a1)+,(a0)+
	dbra	d0,cls2

*******************************************
* BEN CA ALORS ! ON VOIT DANS LES BORDS ! *
*******************************************
DEMONSTRATION:
	bsr	vsync

	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr	

	bsr	musique+26
	;
	; *********************************************************
	; * METTRE A CET ENDROIT LES ROUTINES A EXECUTER AVANT    *
	; * LE DEBUT DE L'OVERSCAN , CAD PENDANT LES 34 SCANLINES *
	; * PRECEDANT L'AFFICHAGE DE L'IMAGE                      *
	; *********************************************************
	;

	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
		
top:	stop	#$2100			; On attend la 34eme ligne
	tst.w	high_border
	bpl.s	top

	move.w	#$2700,sr
*************************
* OUVERTURE BORDER HAUT *
*************************
	moveq	#23,d6
wait:	dbra	d6,wait
	clr.b	$ffff820a.w
	dcb.w	16,$4e71
	move.b	#2,$ffff820a.w
	dcb.w	24,$4e71

*****************
* STABILISATION	*
*****************
	move.b	$ffff8209.w,d6
	ext.w	d6
	neg.w	d6
	lsr.w	d6,d6
	dcb.w	35,$4e71

	jsr	buffergen			* IT'S FULL !!!
	
********************************
* ESPACE=FIN SINON ON CONTINUE *
********************************
	move.w	#$2300,sr
	movem.l	(sp)+,d0-a6
	cmpi.b	#57,$fffffc02.w
	beq.s	findemo
	bra	DEMONSTRATION

**********************
* COMPTEUR DE LIGNES *
**********************	
high_border:	dc.w	0

***********************************
* RESTAURE LES ANCIENS PARAMETRES *
***********************************
findemo:
	movem.l	oldcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr.s	vsync
	move.b	oldrez,$ffff8260.w
	bsr.s	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	bsr.s	vsync
	bsr	finmfp
	moveq	#-1,d0
	bsr	musique
	bsr	musique+22
	clr.w	(sp)
	trap	#1
	
******************
* ATTENDS LA VBL *
******************
vsync:	move.l	d0,-(sp)
	move.l	v466,d0
vl:	cmp.l	v466,d0
	beq.s	vl
	move.l	(sp)+,d0
	rts
v466:	dc.l	0

**********************
* ROUTINES INTEGREES *
**********************
overgd:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89,$4e71
	rts
bas:
	move.b	d0,(a5)
	dcb.w	14,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	85,$4e71
	rts
	
************************
* ROUTINES HBLs ET VBL *
************************
hbl:	rte
tstht:	subq.w	#1,high_border
	rte
vbl:	move.w	#33,high_border
	move.l	#tstht,$68.w
	addq.l	#1,v466
	rte
	
****************************************
* GENERE LE CODE INTEGRE DE L'OVERSCAN *
****************************************
generation:
	lea	routines,a0
	lea	buffergen,a1
	move.w	#271,d0
lg:	move.l	(a0)+,a2
rep:	move.w	(a2)+,(a1)+
	cmpi.w	#$4e75,(a2)
	bne.s	rep
	dbra	d0,lg
	move.w	#$4e75,(a1)+	; RTS
	rts
	
***************************
* SAUVE LES REGISTRES MFP *
***************************
initmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	moveq.w	#16,d0
savemfp:move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+32
	movem.l	$58.w,d0-d7
	movem.l	d0-d7,oldvec+64

	bclr	#3,$fffffa17.w
	clr.b	$fffffa19.w		; Arret timer A
	move.b	#0,$fffffa1b.w		;  ...   ...  B
	move.b	#1,$fffffa07.w		; Timer B seul
	move.b	#1,$fffffa13.w		; ..
	clr.b	$fffffa09.w		; Pas de timer C-D
	clr.b	$fffffa15.w		; ..
	rte
	
******************************
* RESTAURE LES REGISTRES MFP *
******************************
finmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	moveq	#16,d0
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



	************
	SECTION DATA
	************
musique:	incbin	c:\over\*.mus
image:		incbin	c:\over\*.kid

******************************
* 272 ROUTINES DE L'OVERSCAN *
******************************
routines:
	rept	228
	dc.l	overgd
	endr
	dc.l	bas
	rept	44
	dc.l	overgd
	endr

	***********
	SECTION BSS
	***********
oldecr:	ds.l	1
oldrez:	ds.w	1
oldmfp:	ds.b	24
oldvec:	ds.l	24
oldcol:	ds.w	16

log:		ds.l	1
buffergen:	ds.b	80000
ecran:		ds.b	63020+256
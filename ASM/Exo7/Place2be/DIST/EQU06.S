HAUTEUR		=	243-12
HAUTEUR2	=	243

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
	
	move.b	#$12,$fffffc02.w
	dc.w	$a00a

*************************
* QQUES INITIALISATIONS *
*************************	
initdemo:
	move.l	$44e.w,oldecr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcol
	move.b	$ffff8260.w,oldrez
	clr.b	$ffff8260.w
	move.l	#ecran_dist,d0
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log3			; Log=adresse nouvel ecran
**********************************
* INSTALLE LES NOUVELLES HBL-VBL *
**********************************
	moveq	#0,d0
	bsr	zzz
	bsr	zzz+18
	bsr	initmfp
	move.l	#vbl,$70.w
	
	;
	; ...
	;
	bsr	predecalage_fonte_trois_plans
	bsr	generation2
	bsr	initialise_texte_et_courbe
	bsr	affiche_exo2	

	move.l	log3,a1
	add.l	#204+24,a1
	rept	16
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	lea	230-6*4(a1),a1
	endr
	rept	16
	move.l	#$0000fffe,(a1)
	move.l	#0,4(a1)
	move.l	#0,8(a1)
	move.l	#$fffe0000,12(a1)
	move.l	#0,16(a1)
	move.l	#$0000fffe,20(a1)
	lea	230(a1),a1
	endr
	
AVDEMONSTRATION3:
	* setscreen *
	move.b	log3+1,$ffff8201.w
	move.b	log3+2,$ffff8203.w
*******************************************
* BEN CA ALORS ! ON VOIT DANS LES BORDS ! *
*******************************************
DEMONSTRATION3:
	bsr	vsync

	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr	
	
	movem.l	exo2+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	;
	; ...
	;
	
;	move.w	#3000,d0
;w:	dbra	d0,w
	
	move.w	#$700,$ffff8240.w
	
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	btst	#4,d0
	beq.s	l1
	move.b	#0,d0
l1:	clr.l	d1
	move.b	d0,d1
	lsl.l	#5,d1
	lea	equalizer,a0
	lea	(a0,d1.l),a0
	move.l	log3,a1
	add.l	#204+26+230,a1
	rept	16
	move.w	(a0)+,(a1)
	lea	230(a1),a1
	endr

	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	btst	#4,d0
	beq.s	l2
	move.b	#0,d0
l2:	clr.l	d1
	move.b	d0,d1
	lsl.l	#5,d1
	lea	equalizer,a0
	lea	(a0,d1.l),a0
	move.l	log3,a1
	add.l	#204+36+230,a1
	rept	16
	move.w	(a0)+,(a1)
	lea	230(a1),a1
	endr
	
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d0
	btst	#4,d0
	beq.s	l3
	move.b	#0,d0
l3:	clr.l	d1
	move.b	d0,d1
	lsl.l	#5,d1
	lea	equalizer,a0
	lea	(a0,d1.l),a0
	move.l	log3,a1
	add.l	#204+46+230,a1
	rept	16
	move.w	(a0)+,(a1)
	lea	230(a1),a1
	endr
	
	move.w	#$070,$ffff8240.w
	bsr	calcule_adresses1
	bsr	calcule_adresses2
	move.w	#$007,$ffff8240.w
	bsr	zzz+26
	
	clr.w	$ffff8240.w
	
	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
		
;	bra	finoverscan
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

	jsr	buffergen2
	
********************************
* ESPACE=FIN SINON ON CONTINUE *
********************************
finoverscan:
	move.w	#$2300,sr
	movem.l	(sp)+,d0-a6
	cmpi.b	#57,$fffffc02.w
	beq.s	findemo
	bra	DEMONSTRATION3

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
	bsr	zzz
	bsr	zzz+22
	
	move.b	#$8,$fffffc02.w
	dc.w	$a009
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

clear1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR+8,a0
	nop
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	movem.l	zero,d3-d7/a1-a4
	movem.l	d3-d6,(a0)
	lea	4*4(a0),a0
	dcb.w	89-23-12,$4e71
	rts
clear12:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR2+8,a0
	nop
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	movem.l	zero,d3-d7/a1-a4
	movem.l	d3-d6,(a0)
	lea	4*4(a0),a0
	dcb.w	89-23-12,$4e71
	rts
clear2:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	movem.l	d3-d6,(a0)
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	movem.l	d3-d6,4*4(a0)
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	movem.l	d3-d7/a1-a4,8*4(a0)
	movem.l	d3-d7/a1-a4,17*4(a0)
	movem.l	d3-d7/a1-a4,26*4(a0)
	movem.l	d3-d7/a1-a4,35*4(a0)
	move.w	d3,44*4(a0)
	lea	44*4+2(a0),a0
;	dcb.w	3,$4e71
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
ligne1:
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
	dcb.w	89-15,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR-14,a0
	lea	position,a2
	lea	letinit,a3
	rts
ligne12:
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
	dcb.w	89-15,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR2-14,a0
	lea	position2,a2
	lea	letinit2,a3
	rts
ligne2:
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
	lea	14(a0),a0
	lea	texte2,a4
	move.w	(a2)+,d6
	ext.l	d6
	move.w	(a3)+,d7
	lea	(a4,d7.w),a4
	lea	troisplans2,a1
	add.l	(a4)+,a1
	lea	6(a1,d6.w),a1
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	subq.l	#6,a0
	lea	troisplans2,a1
	add.l	d6,a1
	move.l	a1,d4
	dcb.w	89-40,$4e71	
	rts
ligne22:
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
	lea	14(a0),a0
	lea	texte22,a4
	move.w	(a2)+,d6
	ext.l	d6
	move.w	(a3)+,d7
	lea	(a4,d7.w),a4
	lea	troisplans2,a1
	add.l	(a4)+,a1
	lea	6(a1,d6.w),a1
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	subq.l	#6,a0
	lea	troisplans2,a1
	add.l	d6,a1
	move.l	a1,d4
	dcb.w	89-40,$4e71	
	rts
ligne3:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	d4,a1
	add.l	(a4)+,a1
	move.l	(a1)+,d3
	dcb.w	2,$4e71
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	nop
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	addq.l	#2,a0
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	subq.l	#6,a0
	
	rept	2
	move.l	d4,a1
	add.l	(a4)+,a1
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	addq.l	#2,a0
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	subq.l	#6,a0
	endr
	dcb.w	2,$4e71
	rts
setcolorscroll:
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
;	dcb.w	89,$4e71
St	set	0
	rept	8
	move.l	pal_3plans+St,$ffff8240+St.w
St	set	St+4
	endr
	dcb.w	89-64,$4e71
	rts
	
	
************************
* ROUTINES HBLs ET VBL *
************************
tstht:	subq.w	#1,high_border
	rte
vbl:	move.w	#33,high_border
	move.l	#tstht,$68.w
	addq.l	#1,v466
	rte
	
****************************************
* GENERE LE CODE INTEGRE DE L'OVERSCAN *
****************************************
generation2:
	lea	routines2,a0
	lea	buffergen2,a1
	move.w	#271,d0
lg:	move.l	(a0)+,a2
rep:	move.w	(a2)+,(a1)+
	cmpi.w	#$4e75,(a2)
	bne.s	rep
	dbra	d0,lg
	move.w	#$4e75,(a1)+	; RTS
	rts

	;
	; ...
	;
	
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
***********************************
* PREDECALAGE DE LA FONTE UN PLAN *
***********************************
predecalage_fonte_trois_plans:
	lea	troisplans2,a1
	lea	troisplans,a6
	move.w	#20*3-1,d0
tsleschar:
	moveq	#15,d1
les8decal:
	* Recopie *
	move.l	a6,a0
	move.w	#10,d2
mots:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d2,mots
	* Scrolle 
	move.l	a6,a0
	move.w	#10,d2
scro:	moveq	#0,d3
	roxl	d3
	roxl	6(a0)
	roxl	(a0)
	moveq	#0,d3
	roxl	d3
	roxl	8(a0)
	roxl	2(a0)
	moveq	#0,d3
	roxl	d3
	roxl	10(a0)
	roxl	4(a0)
	lea	12(a0),a0
	dbra	d2,scro

	dbra	d1,les8decal
	lea	132(a6),a6
	dbra	d0,tsleschar
	rts
calcule_adresses1:
	move.l	pt_courbe2,a0
	lea	position,a1
	lea	letinit,a2
	moveq	#10,d1
calcing:
	move.w	(a0)+,d0
	add.w	d0,(a1)
	cmpi.w	#16*132,(a1)
	blt.s	sdf
	sub.w	#16*132,(a1)
	addq.w	#4,(a2)
	move.w	(a2),d0
	sub.w	longueur_texte2,d0
	bne.s	sdf
	move.w	#0,(a2)
sdf:
	cmpi.w	#0,(a1)
	bge.s	sdg
	add.w	#16*132,(a1)
	subq.w	#4,(a2)
	cmpi.w	#-4,(a2)
	bne.s	sdg
	move.w	longueur_texte2,(a2)
	subq.w	#4,(a2)
sdg:
	addq.l	#2,a1
	addq.l	#2,a2
	dbra	d1,calcing
	
	addq.l	#2,pt_courbe2		* 2*11
	cmpi.l	#fincourbe2,pt_courbe2
	bne.s	pfc
	move.l	#courbe2,pt_courbe2
pfc:
	rts

calcule_adresses2:
	move.l	pt_courbe22,a0
	lea	position2,a1
	lea	letinit2,a2
	moveq	#10,d1
calcing2:
	move.w	(a0)+,d0
	add.w	d0,(a1)
	cmpi.w	#16*132,(a1)
	blt.s	sdf2
	sub.w	#16*132,(a1)
	addq.w	#4,(a2)
	move.w	(a2),d0
	sub.w	longueur_texte22,d0
	bne.s	sdf2
	move.w	#0,(a2)
sdf2:
	cmpi.w	#0,(a1)
	bge.s	sdg2
	add.w	#16*132,(a1)
	subq.w	#4,(a2)
	cmpi.w	#-4,(a2)
	bne.s	sdg2
	move.w	longueur_texte22,(a2)
	subq.w	#4,(a2)
sdg2:
	addq.l	#2,a1
	addq.l	#2,a2
	dbra	d1,calcing2
	
	addq.l	#2,pt_courbe22		* 2*11
	cmpi.l	#fincourbe2,pt_courbe22
	bne.s	pfc2
	move.l	#courbe2,pt_courbe22
pfc2:
	rts

***************************************
* RECOPIE DEBUT TEXTE+COURBE A LA FIN *
***************************************
initialise_texte_et_courbe:
	move.l	#fintexte2,d0		*
	sub.l	#texte2,d0
	move.w	d0,longueur_texte2
	lea	texte2,a0		*
	lea	fintexte2,a1
	moveq	#29,d0
rec:	move.l	(a0)+,(a1)+
	dbra	d0,rec
	lea	courbe2,a0		*
	lea	fincourbe2,a1
	moveq	#10,d0
rec2:	move.w	(a0)+,(a1)+
	dbra	d0,rec2

	move.l	#fintexte22,d0		*
	sub.l	#texte22,d0
	move.w	d0,longueur_texte22
	lea	texte22,a0		*
	lea	fintexte22,a1
	moveq	#29,d0
rec3:	move.l	(a0)+,(a1)+
	dbra	d0,rec3
	
	rept	12
	bsr	calcule_adresses2
	endr
	rts

***********************
* LE VAISSEAU DE RICK *
***********************
affiche_exo2:
	move.l	log3,a0
	lea	exo2+34,a1
	move.w	#204/4-1,d0
c:	clr.l	(a0)+
	dbra	d0,c
	move.w	#229*230/4-1,d0
c2:	move.l	(a1)+,(a0)+
	dbra	d0,c2
	rts
	
	************
	SECTION DATA
	************
zzz:	incbin	c:\*.mus
zero:	dcb.l	16,0

position:	dc.w	0,144,288,432,576,720,864,1008,1152,1296,1440
letinit:	dcb.w	11,4*0
A=2
position2:	dc.w	A*132+0,A*132+144,A*132+288,A*132+432,A*132+576,A*132+720,A*132+864,A*132+1008,A*132+1152,A*132+1296,A*132+1440
letinit2:	dcb.w	11,4*0

pt_courbe2:	dc.l	avcourbe2
pt_courbe22:	dc.l	avcourbe2
avcourbe2:	dcb.w	12,132*2
courbe2:	
	incbin	c:\dist\crb4712.dat	
fincourbe2:	dcb.w	11,0

longueur_texte2:	dc.w	0
texte2:			dcb.l	30,0
			incbin	c:\dist\txtdist1.dat
fintexte2:		dcb.l	30,0
longueur_texte22:	dc.w	0
texte22:		dcb.l	31,0
			incbin	c:\dist\txtdist2.dat
fintexte22:		dcb.l	30,0

routines2:
	dc.l	clear1
	rept	14
	dc.l	clear2
	endr
	dc.l	ligne1
	rept	11
	dc.l	ligne2
	dc.l	ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3
	endr
	dc.l	clear12
	rept	14
	dc.l	clear2
	endr
	dc.l	ligne12
	rept	8
	dc.l	ligne22
	dc.l	ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3
	endr
	dc.l	ligne22
	dc.l	ligne3,ligne3,ligne3,ligne3,ligne3
	dc.l	bas,ligne3,setcolorscroll
	dc.l	ligne3,ligne3,ligne3
	rept	2
	dc.l	ligne22
	dc.l	ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3,ligne3
	endr
	rept	44-4-2*10
	dc.l	overgd
	endr
	
troisplans:	incbin	c:\dist\fontor.dat
pal_3plans:	dc.w	$000,$222,$321,$432,$543,$654,$765,$777
		dc.w	8,0
equalizer:	
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe

exo2:	incbin	c:\dist\exo2.kid

	***********
	SECTION BSS
	***********
oldecr:	ds.l	1
oldrez:	ds.w	1
oldmfp:	ds.b	24
oldvec:	ds.l	24
oldcol:	ds.w	16
log3:		ds.l	1

troisplans2:	ds.b	7920*16
buffergen2:	ds.b	80000
ecran_dist:		ds.b	63020+256
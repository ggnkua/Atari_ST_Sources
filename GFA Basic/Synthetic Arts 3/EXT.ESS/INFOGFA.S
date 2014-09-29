*-------------------------------------------------------------------------*
*									  *
* 			  -SYNTHETIC ARTS III- 				  *
*			         -1993-					  *
*									  *																					
*			         -INFO- 				  *
*			    -INLINE VERSION-		  	          *
*-------------------------------------------------------------------------*
	
	output	e:\code\synthy.art\curent\ext.ess\infogfa.bin

HAUT:	SET	570

	opt	o+,a+,p+		* CODE TRANSLATABLE

	move.l	4(sp),d6		* ADRESSE ECRAN
	move.w	8(sp),d7		*

	lea	table(pc),a6		* TABLE DE VARS
	lea 	text2(pc),a0		*
	tst.w	d7
	bne.s	oklang
	lea	text(pc),a0
oklang:	move.l	a0,18(a6)		* INIT POINTEUR TEXTE

	clr.l	-(sp)			* SUPERVISEUR
	move.w	#32,-(sp)		*
	trap	#1			*
	move.l	d0,(a6)			*
	addq.l	#6,sp			*

	move.w	#$2700,sr		* INHIBE LES INTERS
	move.b	$fffffa07.w,12(a6)	*
	move.b	$fffffa09.w,14(a6)	*	
	clr.b	$fffffa07.w		*
	clr.b	$fffffa09.w		*
	move.l	$70.w,8(a6)		*
	lea	vbl(pc),a0		*
	move.l	a0,$70.w		*
	move.w	#$2300,sr		*	
	
	lea	pal(pc),a0		*
	lea	$ffff8248.w,a1		*
	rept	6
	move.l	(a0)+,(a1)+
	endr

	add.l	#1606,d6		* D6: PHYSBASE+1606
	lea	fnt(pc),a5		* A5: ADRESSE BASE DES FONTES
	move.l	d6,a2
	 
	move.l	18(a6),a3		* INIT ECRAN
	moveq.l	#21,d0
aff:	
	rept	20			* AFFICHE LES CARACTERES SUR 
	bsr	convert			* TOUTE LA PAGE
	lea	(a5,d7.w),a1
	move.b	(a1)+,(a2)
	move.b	(a1)+,160(a2)
	move.b	(a1)+,320(a2)
	move.b	(a1)+,480(a2)
	move.b	(a1)+,640(a2)
	move.b	(a1)+,800(a2)
	move.b	(a1)+,960(a2)
	addq.l	#1,a2

	bsr	convert			* TOUTE LA PAGE
	lea	(a5,d7.w),a1
	move.b	(a1)+,(a2)
	move.b	(a1)+,160(a2)
	move.b	(a1)+,320(a2)
	move.b	(a1)+,480(a2)
	move.b	(a1)+,640(a2)
	move.b	(a1)+,800(a2)
	move.b	(a1)+,960(a2)
	addq.l	#7,a2
	endr
	lea	7*160(a2),a2
	dbra.w	d0,aff
	
loop:	
	stop	#$2300			* SYNCHRO ECRAN

	move.l	d6,a0			* SCROLLING
	move.l	d6,a1			
	move.w	#174,d0			* 176 de haut

	cmp.w	#1,4(a6)		* VERS LE HAUT si touche
	bne	a			*
	cmp.w	#HAUT,16(a6)		* si on est pas en bas du scroll	
	beq	a			*	       
	addq.w	#1,16(a6)		* on decremente le cpt
	lea	160(a0),a0		* 
copy:					*
i:	set	0			* on deplace l'image sur 1 plan 
	rept	20			*
	move.w	i(a0),i(a1)		*
i:	set	i+8			*
	endr				*
	lea	160(a0),a0		*
	lea	160(a1),a1		*
	dbra.w	d0,copy			*
					*
	move.l	18(a6),a3		*
	move.w	16(a6),d0		*
	add.w	#175,d0			*
	lsr.w	#3,d0			*
	mulu.w	#40,d0			*
	lea	(a3,d0.w),a3		*
	move.w	16(a6),d0		*
	add.w	#175,d0			*
	and.w	#7,d0			*
	lea	(a5,d0.w),a4		*
	move.l	d6,a0			* base ecran+1606
	lea	175*160(a0),a0		*
	rept	20			* affichage des 40 caracteres	
	bsr	convert			*
	move.b	(a4,d7.w),(a0)+		*
	bsr	convert			*
	move.b	(a4,d7.w),(a0)		*
	addq.l	#7,a0			*
	endr				*
a:

	cmp.w	#-1,4(a6)		* VERS LE BAS si touche
	bne	b			*
	tst.w	16(a6)			* si on est pas en haut
	ble	b			*
	subq.w	#1,16(a6)		* on decremente le cpt
	lea	175*160(a1),a1		*
	lea	174*160(a0),a0		*
copy2:					*
i:	set	0			* on deplace le bloc vers le bas
	rept	20			*
	move.w	i(a0),i(a1)		*
i:	set	i+8			*
	endr				*
	lea	-160(a0),a0		*
	lea	-160(a1),a1		*
	dbra.w	d0,copy2		*

	move.l	18(a6),a3		*
	move.w	16(a6),d0		*
	lsr.w	#3,d0			*
	mulu.w	#40,d0			*
	lea	(a3,d0.w),a3		*
 	move.w	16(a6),d0		*
	and.w	#7,d0			*
	lea	(a5,d0.w),a4		*
	move.l	d6,a0			* base ecran+1606
	rept	20			* affichage des 40 caracteres	
	bsr	convert
	move.b	(a4,d7.w),(a0)+		*
	bsr	convert			*
	move.b	(a4,d7.w),(a0)		*
	addq.l	#7,a0			*
	endr				*
b:
	move.b	$fffffc02.w,6(a6)	* ETAT REGISTRE ACIA CLAVIER
  
	cmp.b	#$48,6(a6)		* SI curseur haut on
	bne.s	offh			*
	move.w	#-1,4(a6)		*
	bra.s	onh
offh:					*
	cmp.b	#$48+128,6(a6)		* Si curseur haut off
	bne.s	onh			*
	clr.w	4(a6)			*
onh:

	cmp.b	#$50,6(a6)		* Si curseur bas on
	bne.s	offb			*
	move.w	#1,4(a6)		*
	bra.s	onb
offb:					*
	cmp.b	#$50+128,6(a6)		* Si curseur haut off
	bne.s	onb			*
	clr.w	4(a6)			*
onb:
	cmp.b	#185,6(a6)		* EXIT si 'space' 
	bne	loop			*
okette:
	move.w	#$2700,sr		* REINIT INTERS
	move.l	8(a6),$70.w		*
	move.b	12(a6),$fffffa07.w	*
	move.b	14(a6),$fffffa09.w	*
	move.w	#$2300,sr		*

	move.l	(a6),-(sp)		* UTILISATEUR 
	move.w	#32,-(sp)		*
	trap	#1			*
	addq.l	#6,sp			*

	rts				* RETURN TO GFA

vbl:	rte				* NEW VBL

convert: moveq.l #0,d7
	 move.b	(a3)+,d7
	 add.w	d7,d7
	 move.w	convertab(pc,d7.w),d7
	 rts		

convertab:	dcb.w	40,40*8		* 0 … 39
		dc.w	38*8		* 40
		dc.w	39*8		* 41
		dc.w	41*8		* 42
		dcb.w	3,32*8		* de 43 … 45
		dc.w	36*8		* 46
		dc.w	40*8		* 47
var:	set	26			* de 48 … 57
		rept	10		*
		dc.w	var*8		*
var:	set	var+1			*
		endr			*
		dc.w	37*8		* 58
		dcb.w	6,40*8		* 59 … 64
var:	set	0			* de 65 … 90
		rept	26		*
		dc.w	var*8		*
var:	set	var+1			*
		endr			*	
		
			**** TABLEs ****

table:	dc.l	0 		* 0:	oldstack
	dc.w	0		* 4:	curseur 
	dc.w	0		* 6:	touche	
	dc.l	0		* 8:	oldvbl
	dc.w	0		* 12:	oldiera
	dc.w	0		* 14:	oldierb
	dc.w	0		* 16:	cpt
	dc.l	0		* 18:	point
	dc.w	0		* 20:	plane

pal:	rept	12
	dc.w	$124
	endr

text:	
        dc.b        '****************************************'
        dc.b        '****************************************'
	dc.b        'SYNTHETIC ARTS 3.0        CYBERNETICS 93'
        dc.b        '****************************************'
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' CE LOGICIEL EST UN SHAREWARE:          '
        dc.b        '   VOUS POUVEZ OBTENIR LA DOCUMENTATION '
        dc.b        '   CONTRE LA MODIQUE SOMME DE 90 FRS EN '
        dc.b        '   ECRIVANT A:                          '
      	dc.b	    '                       JEROME HUBERT    '
        dc.b        '                       96 BD BLANQUI    '
        dc.b        '                        75013 PARIS     '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' CONCEPT ET PROGRAMMATION:              '
        dc.b        '                  J.HUBERT (METAL AGES) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' ROUTINE CHARGEMENT ET OVERSCAN:        '
        dc.b        '               C.HOUILLON (STORM LIGHT) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' ROUTINE SAUVEGARDE ET GESTION CARTE:   '
        dc.b        '                    S.BOISSON (NUCLEUS) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' DOCUMENTATION:                         '
        dc.b        '                  J.HUBERT (METAL AGES) '
        dc.b        '                        O.JACQUES (BIP) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' TRADUCTION ANGLAISE:                   '
        dc.b        '                             JOHN DURST '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' TEST:                                  '
        dc.b        '                      R.DESBERG (SINIS) '
        dc.b        '                      N.LEGER (POLARIS) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' SYNTHETIC ARTS 3 UTILISE LES CAPACITES '
        dc.b        ' DE LA CARTE DE DIGITALISATION VIDEO    '
        dc.b        ' TEMPS REEL *VIDEO CLIC*                '
        dc.b        ' VOUS POUVEZ VOUS PROCUREZ CETTE CARTE  '
        dc.b        ' AUPRES DE ...                          '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' CYBERNETICS:                           '
        dc.b        '                                        '
        dc.b        '     .BIP                               '
        dc.b        '     .KRAG                              '
        dc.b        '     .LMQD                              '
        dc.b        '     .METAL AGES                        '
        dc.b        '     .POLARIS                           '
        dc.b        '     .POSITRONIC                        '
        dc.b        '     .SINIS                             '
        dc.b        '     .STORM LIGHT                       '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' MERCI A:                               '
        dc.b        '                                        ' 
        dc.b        '  .DOMINIQUE DUPOND                     '
        dc.b	    '  .DOCNO                                '
        dc.b        '  .GANJA KID                            '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' SALUT A:                               '
        dc.b        '                                        '
        dc.b        '  .BRAIN BLASTER ET CORVUS CORAX        '
        dc.b        '  .DUNE                                 '
        dc.b        '  .FMCCNX                               '
        dc.b        '  .HEMOROIDS                            '
        dc.b        '  .MJJ PROD                             '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '




text2:	
        dc.b        '****************************************'
        dc.b        '****************************************'
	dc.b        'SYNTHETIC ARTS 3.0        CYBERNETICS 93'
        dc.b        '****************************************'
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' THIS SOFTWARE IS SHAREWARE:            '
        dc.b        '   YOU CAN OBTAIN THE DOCUMENTATION BY  '
        dc.b        '   SENDING US 90 FRS AT:                '
      	dc.b	    '                          JEROME HUBERT '
        dc.b        '                          96 BD BLANQUI '
        dc.b        '                            75013 PARIS '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' DESIGN AND PROGRAM:                    '
        dc.b        '                  J.HUBERT (METAL AGES) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' LOADING AND OVERSCAN ROUTINES:         '
        dc.b        '               C.HOUILLON (STORM LIGHT) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' SAVING AND CARD MANAGING ROUTINE:      '
        dc.b        '                    S.BOISSON (NUCLEUS) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' NOTICE:                                '
        dc.b        '                  J.HUBERT (METAL AGES) '
        dc.b        '                        O.JACQUES (BIP) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' ENGLISH TRANSLATION:                   '
        dc.b        '                             JOHN DURST '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' TEST:                                  '
        dc.b        '                      R.DESBERG (SINIS) '
        dc.b        '                      N.LEGER (POLARIS) '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' SYNTHETIC ARTS 3 IS ABBLE TO USE THE   '
        dc.b        ' REEL TIME VIDEO DIGITALIZATION CARD    '
        dc.b        ' *VIDEO CLIC*                           '
        dc.b        ' YOU CAN OBTAIN THIS CARD NEAR...       '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' CYBERNETICS:                           '
        dc.b        '                                        '
        dc.b        '     .BIP                               '
        dc.b        '     .KRAG                              '
        dc.b        '     .LMQD                              '
        dc.b        '     .METAL AGES                        '
        dc.b        '     .POLARIS                           '
        dc.b        '     .POSITRONIC                        '
        dc.b        '     .SINIS                             '
        dc.b        '     .STORM LIGHT                       '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' THANKS TO:                             '
        dc.b        '                                        ' 
        dc.b        '  .DOMINIQUE DUPOND                     '
        dc.b	    '  .DOCNO                                '
        dc.b        '  .GANJA KID                            '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '****************************************'
        dc.b        ' HELLO TO:                              '
        dc.b        '                                        '
        dc.b        '  .BRAIN BLASTER ET CORVUS CORAX        '
        dc.b        '  .DUNE                                 '
        dc.b        '  .FMCCNX                               '
        dc.b        '  .HEMOROIDS                            '
        dc.b        '  .MJJ PROD                             '
        dc.b        '****************************************'
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '                                        '
        dc.b        '                                        '

fnt:	incbin		"E:\CODE\SYNTHY.ART\CURENT\datas.old\smfnt.bin"
	dc.w		0
	dc.b		0,-1
	dcb.w		2,0
	even
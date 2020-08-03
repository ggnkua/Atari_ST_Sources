*-------------------------------------------------------------------------*
* STE PROTRACKER ROUTINES PATCHED BY METAL AGES     VBL VERSION (50 Hz)	  *
*									  *
*  -MUSIC ROUTINE OPTIMIZED VERSION I				          *
*  -AUTOMODIFIED FREQUENCY CALCULATION WITH LEVEL 2 CORRECTION TABLE	  *
*									  *
*  ALL THESE OPTIONS CAN BE TURNED ON/OFF:				  *
*									  *
*  -APPROXIMATED VOLUME CONTROL		(Hyperspeed table option)	  *
*  -VOLUME CONTROL ON/OFF						  *
*  -SP CALCULATED SAMPLES					          *
*  -DOUBLE DMA FREQUENCY USED						  *
*						- CYBERNETICS 1992 -      *
*-------------------------------------------------------------------------*

	*output	"e:\code\effects.grx\nosystem\info.inl"

cpu:		set	0	* Time cpu	

nbre_div:	set	4	* Len/nbre_div doit etre un entier
doublefreq:	set	0	* Double DMA frequency		  (0-1-2)
spcalc:		set	1	* Calcul des samples avec le sp     (0/1)
freq:		set	3	* Frequency 		        (0-1-2-3) 
mvol		equ	$80	* Main volume				
aigus:		set	6
graves:		set	8
system:		set	0
*-------------------------------------------------------------------------*
		ifeq	freq-3
doublefreq:	set	0
		endc
lfreq:		set	1
		rept	doublefreq
lfreq:		set	lfreq*2
		endr
*-------------------------------------------------------------------------*
	IFEQ FREQ
LEN	EQU 125
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
LEN	EQU 250
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
LEN	EQU 500
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
LEN	EQU 1000
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC
*-------------------------------------------------* ROUTINE DE TEST

	ifne	system
	clr.w	-(sp)
	move.l	#-1,-(sp)	
	move.l	#-1,-(sp)	
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	move.b	#2,$ffff820a.w
	endc

	bsr	initsound

	move.l	#ecran,d0
	sub.b	d0,d0
	move.l	d0,a1

	ifeq	system
	move.l	a1,a2
	move.w	#7999,d1
effbss:	clr.l	(a2)+
	dbra.w	d1,effbss
	endc 
	
	clr.b	$ffff820d.w
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

	move.w	#32000,d1
temp5: 	dbra.w	d1,temp5
		
	lea	please,a0		* Precalcule le texte
	lea	98*160+56(a1),a1
	lea	fnt,a2
	
	moveq.l	#5,d7			* 40 caractŠres par ligne
calc5: 	bsr	offcar	
	addq.w	#1,a1
	bsr	offcar
	addq.w	#7,a1
	dbra.w	d7,calc5

	lea	zero,a0
	lea	pal,a2
	moveq.l	#-1,d1
	lea	$1.w,a6
	bsr	light

	move.l	#module,data		* Module adr
	move.l	#modulend,workspc	* Workspc end adr
	bsr	incrcal

	lea	zero,a2
	lea	pal,a0
	moveq.l	#-1,d1
	lea	$1.w,a6
	bsr	light
	
	lea	text,a0			* Precalcule le texte
	lea	ecran,a1
	lea	fnt,a2
	
	move.w	#(fintext-text-1)/40,d1	* Nombre de lignes
calc2:	
	moveq.l	#19,d7			* 40 caractŠres par ligne
calc3: 	bsr	offcar	
	addq.w	#1,a1
	bsr	offcar
	addq.w	#7,a1
	dbra.w	d7,calc3
	lea	5*160(a1),a1
	dbra.w	d1,calc2
	
	bsr	muson

	lea	zero,a0
	lea	pal,a2
	moveq.l	#-1,d1
	lea	$1.w,a6
	bsr	light

*-------------------------------------------------------------------------*
main:	cmp.b	#57,tch			* Test barre espace = exit 
	bne.s	main

	lea	pal,a0
	lea	zero,a2
	moveq.l	#-1,d1
	lea	$1.w,a6
	bsr	light

	bsr	fadesound

	bsr	musoff

	ifne	system
	move.b	#0,$ffff820a.w
	clr.w	-(sp)			* Fin
	trap	#1			
	else
	illegal
	endc	

please:	dc.b	'PLEASE WAIT '
	even	

*-------------------------------------------------------------------------*
offcar:	moveq.l	#0,d0
	move.b	(a0)+,d0
	cmp.b	#32,d0			* Espace
	bne.s	oknospc
	moveq.l	#65+39,d0
oknospc:cmp.b	#58,d0			* Double point
	bne.s	nodpt
	moveq.l	#65+26+10+2,d0
nodpt:	cmp.b	#46,d0			* Point
	bne.s	nopt	
	moveq.l	#65+26+10,d0
nopt:	cmp.b	#44,d0			* Virgule
	bne.s	novir
	moveq.l	#65+26+10+1,d0
novir:	cmp.b	#57,d0			* Chiffre
	bgt.s	nonumer
	add.w	#65+26-48,d0
nonumer:sub.b	#65,d0
	mulu.w	#24,d0
	lea	(a2,d0.w),a3
var:	set	0
	rept	6
	move.b	(a3)+,var(a1)
	move.b	(a3)+,var+2(a1)
	move.b	(a3)+,var+4(a1)
	move.b	(a3)+,var+6(a1)
var:	set	var+160
	endr
	rts
*----------------------------- FADE ROUTINE ------------------------------*
*	A0 = adr palette depart						  *
* 	A2 = adr palette arrivee					  *
*	A6 = boucle de tempo						  * 
* 	D1 = masque							  *
*-------------------------------------------------------------------------*
light:	
	move.w		d1,a5			* Sauve le mot de test couleurs
	clr.w		rd4			* Compteur de boucles: nbre d'etapes
looplight:					* Boucle principale
	move.l		a0,a1			* Adresse palette
	move.l		a2,a3			* Adresse palette
	move.w		rd4(pc),d2		* Compteur boucle (‚tape fade)
	lsl.w		#4,d2			*
	lea		$ffff8240.w,a4		* Adr palette
	move.w		a5,d1
	move.w		#15,rd6
	
light_colors:
	move.w  	(a1)+,d4		* Couleur de depart
	move.w		(a3)+,d5 		* Couleur d'arrivee
	
	add.w		d1,d1			* Test si il faut modifier
	bcc.s		nocol			* ce registre de couleur
	
	moveq.l		#0,d3			* Registre pour couleur finale
	moveq.l		#0,d0			* Indice boucle: 0-4-8 (decalage composante r-v-b)

compo:	move.w		d4,d7			* Color dep
	bsr		rol4bits		*  
	move.w		d7,d6			* => valeur composante de 0 … 15
	move.w		d5,d7			* Color arr
	bsr		rol4bits		* => valeur composante de 0 … 15
	sub.w		d6,d7			* delta composante: Dc
	muls.w		d2,d7			* Dc * 256 / nb ‚tape 
	asr.w		#8,d7			* Dc / 256
	add.w		d6,d7			* Dc + color dep 
	bsr		ror4bits		* composante de 0 … 15 => ste color 
	lsl.w		d0,d7
	or.w		d7,d3			* D3 : resultat couleur

	lsr.w		#4,d4			* Decalage pour composante
	lsr.w		#4,d5
	
	addq.w		#4,d0			* Boucle composante
	cmp.w		#12,d0
	bne.s		compo
	
	move.w		d3,(a4)			* Fixe couleur
nocol:	addq.w		#2,a4
	
	subq.w		#1,rd6			* Boucle couleur
	bge.s 		light_colors

	move.w		a6,d5			* Temporisation
temp:	stop		#$2300
	dbra.w		d5,temp
	
	addq.w		#1,rd4			* Boucle etape
	cmp.w		#17,rd4
	bne		looplight
exit:	
	rts

rd4:	dc.w	0
rd6:	dc.w	0


rol4bits:
	add.w		d7,d7		* D7: couleur shift‚e (selon Composante voulue)
	btst.l		#4,d7
	beq.s		nobit1_1
	or.w		#1,d7	
nobit1_1:
	and.w		#15,d7		* D7: compsante de 0 … 15
	rts

	
ror4bits:
	ror.w		#1,d7
	bcc.s		nobit1_2
	or.w		#8,d7
nobit1_2:
	and.w		#15,d7
	rts


initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
dmwr:	cmp.w		#$7ff,$ffff8924.w
	bne.s		dmwr
	move.w		#%10011101000,d0		* Volume max
	bsr.s		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr.s		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr.s		microwrite
	rts

microwrite:
	move.w		#1000,d1
waitdma:dbra.w		d1,waitdma
	move.w		d0,$ffff8922.w
	rts

fadesound:	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#500,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2
	rts

zero:	ds.w	16
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*-------------------------------------------------------------------------*
*-------------------------------------------------------------------------*
*	REPLAY ROUT
*-------------------------------------------------------------------------*
	opt	o+
*-------------------------------------------------------------------------*
*-------------------------------------------------- INTERS ON
muson:
	bsr	vol			* approxim‚, on calcule la table

	jsr	init			* Initialise routine music
	jsr	prepare			* Prepare module (samples)

	move.w	#$2700,sr		* Inters
	move.b	$fffffa07.w,oldmfp1	*
	move.b	$fffffa09.w,oldmfp2	*
	clr.b	$fffffa07.w		*
	clr.b	$fffffa09.w		*
	move.l	$70.w,oldvbl		*
	move.l	#stereo,$70.w		*
	move.b	#FREQ+doublefreq,$FFFF8921.w	* DMA Frequency
	lea	$FFFF8907.w,a0		* Set DMA Adr
	move.l	#sample1,d0		*
	move.b	d0,(a0)			*
	lsr.w	#8,d0			*
	move.l	d0,-5(a0)		*
	move.l	#sample1+LEN*lfreq*2,d0 *
	move.b	d0,12(a0)		*
	lsr.w	#8,d0			*
	move.l	d0,7(a0)		*
	move.b	#1,$FFFF8901.w		* DMA run
	move.w	#$2300,sr		* VBL on

	rts
*----------------------------------------------------- INTERS OFF
musoff:
	move.w	#$2700,sr		* Restaure inters
	move.l	oldvbl(pc),$70.w	
	move.b	oldmfp1,$fffffa07.w
	move.b	oldmfp2,$fffffa09.w
	clr.b	$FFFF8901.w		* DMA off
	move.w	#$2300,sr	
	rts
	
oldvbl:		DC.L 0
oldmfp1:	DC.W 0
oldmfp2:	DC.W 0

*----------------------------------------------------------VOLUME TABLE
vol:	moveq.l	#64,d0			* approxim‚
	lea	vtabend,a0
.ploop:	move.w	#255,d1
.mloop:	move.w	d1,d2
	ext.w	d2
	muls.w	d0,d2
	divs.w	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra.w	d1,.mloop
	dbra.w	d0,.ploop
	rts
*-------------------------------------------------------INCREMENT TABLE
incrcal:lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2			* Frequence de ref (selon freq replay)
	lea	stab2(pc),a1		* Pointe sur la table de correction
	lea	stabvar,a3		* Pointe sur la table de correction 2
	
recalc:	swap	d2
	moveq.l	#0,d3			
	move.w	d2,d3			
	divu.w	d1,d3
	move.w	d3,d4
	move.w	d3,a2			* Coef
	swap	d4

	swap	d2
	move.w	d2,d3			* Taux d'erreur
	divu.w	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	exg.l	d3,a2
	moveq.l	#0,d6			
	moveq.l	#0,d7
	move.w	#len-1,d5		* On calcule l'offset auquel on arriverait
calc10:	add.w	a2,d6	
	addx.w	d3,d7		
	dbra.w	d5,calc10
	move.w	d7,(a1)+		* Offset auquel on parvient
	move.w	d6,(a1)+		* Taux d'erreur auquel on parvient
					* dans Stab2 (freq * 4 & .w + .w)
	moveq.l	#0,d6			
	move.l	a3,a4			* Stab var + freq *2 dans a4
	move.w	#nbre_div-2,d4
calc4:	move.w	#len/nbre_div-1,d5	* On calcule l'offset auquel on arriverait
	moveq.l	#0,d7
calc32:	add.w	a2,d6			*\
	addx.w	d3,d7			* \ Calcul de l'offset theorique
	dbra.w	d5,calc32		* /
	move.w	d7,(a4)			* On le note	
	lea	$03a0*2(a4),a4
	dbra.w	d4,calc4		* nbre_div-1 fois
	addq.w	#2,a3			* Table + 2 * freq
		
	addq.w	#1,d1
	dbra.w	d0,recalc
	
	rts

*-------------------------------------------TABLE VOLUME & INCREMENTS
itab:	ds.l $30
stab:	DS.L $03A0-$30
itab2:	ds.l $30
stab2:	DS.L $03A0-$30
vtab:	DS.B 65*256
vtabend:

*-------------------------------------------------------------------------*
fnt:		incbin		e:\code\effects.grx\infoscr\tryfnt.dat
pal:		incbin		e:\code\effects.grx\infoscr\info.pal
*-------------------------------------------------------------------------*
text:		dc.b	'RELAPSE INFOS             CYBERNETICS 92'
		dc.b	'                                        '
		dc.b	'                                        '
		dc.b	'   USE CURSOR KEYS TO SCROLL THE TEXT   '
		dc.b	'                                        '
		dc.b	'                                        '
		dc.b	'   CYBERNETICS ARE :                    '
		dc.b	'                                        '
		dc.b	'          BIP                           '
		dc.b	'          KRAG                          '
		dc.b	'          LMQD                          '
		dc.b	'          METAL AGES                    '
		dc.b	'          POLARIS                       '
		dc.b	'          POSITRONIC                    '
		dc.b	'          SINIS                         '
		dc.b	'          STORM LIGHT                   '
		dc.b	'                                        '
		dc.b	'   GUEST CODER :                        '
		dc.b	'                                        '
		dc.b	'          PIPOZOR FROM ARTIS MAGIA      '
		dc.b	'                                        '
		dc.b	'   GUEST MUSICIAN :                     '
		dc.b	'                                        '
		dc.b	'          DELOS FROM CYCLADES           '
		dc.b	'                                        '
		dc.b	'                                        '
		dc.b	'SCREENS INFORMATIONS :                  '
		dc.b	'                                        '
		dc.b	' INTRO :                                '
		dc.b	'  ONLY WORKS ON A MEGABYTE MACHINE.     '
		dc.b	'  SOUNDTRACK AT TRUE 25 KHZ.            '
		dc.b	'                                        '		
		dc.b	' THE LIQUID OSMOSIS :                   '
		dc.b	'  SOUNDTRACK AT NEAR 25 KHZ.            '
		dc.b	'  VIDEO DIGIT ARE FIRED FROM DUNE MOVIE.'		
		dc.b	'  ONLY WORKS ON A MEGABYTE MACHINE.     '		
		dc.b	'                                        '		
		dc.b	' EGYPTIA :                              '		
		dc.b	'  SOUNDTRACK AT NEAR 50 KHZ.            '		
		dc.b	'  USES A NEW FLEXISCROLL TECHNIC BY KRAG'
		dc.b	'  WITHOUT THE SOUNDTRACK, IT CAN DISPLAY'		
		dc.b	'  ABOUT 16000 POINTS IN ONE VBL.        '
		dc.b	'                                        '
		dc.b	' THE GRAFIK SOUND II :                  '
		dc.b	'  SOUNDTRACK AT NEAR 25 KHZ             '
		dc.b	'  IT CONTAINS 10 DIFFERENT EFFECTS AND  '
		dc.b	'  FEATURES NEW STE TECHNIC :            '
       		dc.b	'  THE BLITTER PLASMA                    '
		dc.b	'  THIS VERSION SHOULD WORK WITH ALL STES'
		dc.b	'  BECAUSE I,VE USED AN AUTOGENERATED    '
		dc.b	'  BLITTER TESTED PLASMA ROUTINE         '
		dc.b	'                                        '		
		dc.b	' CYBERNETICS ROULENT NAME AS PAM HOUSE :'		
		dc.b	'  THE FIRST SCREEN MADE FOR THIS DEMO,  '		
		dc.b	'  AND WITHOUT DOUBT THE SHITTIEST.      '		
		dc.b	'  SAMPLE AT 25 KHZ FIRED FROM ,DAFT, BY '		
		dc.b	'  THE ART OF NOISE.                     '		
		dc.b	'                                        '		
		dc.b	' CASCADE :                              '		
		dc.b	'  SOUNDTRACK AT NEAR 50 KHZ.            '		
		dc.b	'  THIS VERY ESTHETIC SCREEN FEATURES A  '
		dc.b	'  32 COLOURS FLIPPED PICTURE BY POLARIS.'		
		dc.b	'  SPECIAL GREETING TO THALION SOFTWARE  '		
		dc.b	'  FOR RIPPING OUR FONT AND USE IT IN    '		
		dc.b	'  LETHAL XCESS...                       '		
		dc.b	'                                        '		
		dc.b	' SPACE FILLER :                         '		
		dc.b	'  SOUNDTRACK AT NEAR 50 KHZ.            '		
		dc.b	'  VIDEO DIGITS COME FROM DIFFERENT BOOKS'		
		dc.b	'  THIS SCREEN WAS ORIGINALLY DESIGNED TO'		
		dc.b	'  BE USED AS A SPACE FILLER IN THE NEVER'		
		dc.b	'  REALISED ,DEUS EX MACHINA, ...        '		
		dc.b	'                                        '		
		dc.b	' BOBS MIGRATION OVER A ZOOM LAND :      '	
		dc.b	'  ONLY WORK ON A MEGABYTE MACHINE.      '		
		dc.b	'  SOUNDTRACK AT NEAR 25 KHZ.            '
		dc.b	'  PICTURES ARE PREZOOMED WITH AN        '
		dc.b	'  AUTOGENERATED NEAR REALTIME ZOOM ROUT.'
		dc.b	'                                        '		
		dc.b	' SHADED VISION OF ART :                 '
		dc.b	'  SOUNDTRACK AT NEAR 50 KHZ.            '
		dc.b	'  THIS SCREEN FEATURES ROTATING BLITTER '
		dc.b	'  SHADED BOBS.                          '		
		dc.b	'                                        '		
		dc.b	' LOADER :                               '		
		dc.b	'  SOUNDTRACK AT NEAR 25 KHZ.            '		
		dc.b	'  MUSIC INSPIRED FROM NIKITA SOUNDTRACK '		
		dc.b	'  BY ERIC SERRA.                        '		
		dc.b	'                                        '		
		dc.b	' INFO SCREEN :                          '		
		dc.b	'  SOUNDTRACK AT TRUE 50 KHZ ON ALL STES.'		
		dc.b	'                                        '		
		dc.b	' FAST MENU :                            '		
		dc.b	'  AUTOGENERATED BLITTER TESTED PLASMA.  '
		dc.b	'                                        '		
		dc.b	'                                        '		
		dc.b	'...BUT A SCREEN STILL MISS :            '		
		dc.b	'THE FABULOUS 16 COLOURS MULTIOBJECTS    '		
		dc.b	'LANGUAGE CONTROL 3D ROUTINE BY PIPOZOR. '		
		dc.b	'UNFORTUNATELY WE DIDN,T MANAGE TO       '		
		dc.b	'CONTACT HIM SINCE TWO MONTHS.           '
		dc.b    'WE HOPE NOTHING BAD HAPPENED TO HIM...  '		
		dc.b	'                                        '
		dc.b	'                                        '
		dc.b	'ALL GRAPHICS AND MUSICS ARE ORIGINAL... '		
		dc.b	'ALL CODE IS CYBERNETICS PRODUCT EXCEPT :'		
		dc.b	' . ICE PACKER 2.4 ROUTINE               '		
		dc.b	' . ATOMIK 3.5 PACK ROUTINE              '		
		dc.b	' . NOISE PACKER 0.3 ROUTINE             '		
		dc.b	' . ADAPTED PROTRACKER 1.2 ROUTINES      '		
		dc.b	'                                        '		
		dc.b	'                                        '
		dc.b	'GREETINGS GO TO :                       '		
		dc.b	' HMD,ESPECIALLY TO NUCLEUS.RED FOXX.    '		
		dc.b	' LEGACY,ESPECIALLY TO PIXEL KILLER.DUNE.'		
		dc.b	' MJJ PROD.JACK TBS.DARK PROCESS.MISTER  '		
		dc.b	' PINK EYE.EQUINOX.NOVALIS.THE MISFITS,  '		
		dc.b	' ESPECIALLY JOKER.IMAGINA.TSB.FANTASY.  '
		dc.b	' LA GARDE ROYALE.GANJA KID.ART OF CODE. '
		dc.b	' BINARIS.DNT CREW.JOHN DURST.MINGO.CVM. '
		dc.b	' PHABA CLUB.T V INC.SECTOR ONE.TST D0.  '		
		dc.b	'        ... IN RANDOM ORDER...          '		
		dc.b	'                                        '		
		dc.b	'                                        '		
		dc.b	'SPECIAL THANKS FROM BIP TO ASTRID FOR   '
		dc.b	'HER WEEK END SUPPORT                    '		
		dc.b	'                                        '		
		dc.b	'SPECIAL THANKS FROM SINIS TO SAD FOR ALL'		
		dc.b	'HER SUPPORT...                          '		
		dc.b	'                                        '		
		dc.b	'SPECIAL THANKS FROM METAL AGES TO HIS   '		
		dc.b	'RIGHT HAND FOR HER EVERY DAY SUPPORT    '		
		dc.b	'                                        '		
		dc.b	'                                        '		
		dc.b	'SOFTWARES USED TO REALISE THIS DEMO :   '		
		dc.b	' . SYNTHETIC ARTS 3                     '		
		dc.b	' . EXOMODULES                           '		
		dc.b	' . DEVPACK 2.23                         '		
		dc.b	' . GFA BASIC 3.5E                       '		
		dc.b	' . ICE,ATOMIK AND NOISE PACKER          '		
		dc.b	' . PROTRACKER 1.2                       '						
		dc.b	' . PROTRACKER 2.0 BY CHECKSUM           '						
		dc.b	' . AUDIO SCULPTURE                      '						
		dc.b	' . ST REPLAY                            '						
		dc.b	' . DIGITAL IMPACT                       '		
		dc.b	' . VIDI ST                              '						
		dc.b	' . REZRENDER                            '						
		dc.b	' . DELUXE PAINT 4                       '						
		dc.b	'                                        '						
fintext:		
*-------------------------------------------------------------------------*
offset:		dc.l	0
physb:		dc.l	ecran
tch:		dc.w	0
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	CALCUL SAMPLE AUTOMODIFIE					  *
*-------------------------------------------------------------------------*
stereo:	move.b	#1,$FFFF8901.w		* Relance le DMA
	move.b	$fffffc02.w,tch

	ifne	cpu			* Si time Cpu time demand‚
	move.w	#$7,$ffff8240.w		
	endc

	movem.l	d0-a6,-(sp)		* Sauve registres

	move.l	physb(pc),d0
	lea	$ffff8203.w,a0
	movep.l	d0,(a0)

	cmp.l	#((fintext-text)/40-34)*(6*160),offset
	bge.s	nolow
	cmp.b	#$50,tch		* Test fleche bas
	bne.s	nolow			*
	lea	ecran,a0		* Calcul nouvelle adresse video pour prochaine vbl
	add.l	#160,offset		* Incremente offset
	add.l	offset(pc),a0		*
	move.l	a0,physb		* dans physb pour next vbl 
	bra.s	nohight
nolow:		
	tst.l	offset
	ble.s	nohight
	cmp.b	#$48,tch		* Test fleche bas
	bne.s	nohight			*
	sub.l	#160,offset		* Incremente offset
	lea	ecran,a0		* Calcul nouvelle adresse video pour prochaine vbl
	add.l	offset(pc),a0		* 
	move.l	a0,physb		* dans physb pour next vbl 
nohight:

	move.l	samp2(pc),d0		* Flip buffer sample
	move.l	samp1(pc),samp2
	move.l	d0,samp1
	move.l	d0,d1
	moveq.l	#8,d2

	lea	$FFFF8907.w,a0		* et met l'adresse du nouveau buf
	move.b	d0,(a0)
	lsr.w	d2,d0
	move.l	d0,-5(a0)		* Adr debut
	
	add.l	#LEN*lfreq*2,d1
	move.b	d1,12(a0)
	lsr.w	d2,d1
	move.l	d1,7(a0)		* Adr fin	
	
	bsr	music			* Gestion de la partition

	lea	itab(pc),a5		* Calcul voix GAUCHE
	lea	vtab(pc),a3
	moveq.l	#0,d0
	moveq.l	#0,d4

v1:	movea.l	wiz1lc(pc),a0		******* CALCUL VOIX GAUCHE

	move.w	wiz1pos(pc),d0		* Dernier offset sur sample
	move.w	wiz1frc(pc),d1		* Dernier taux d'erreur
	
	move.w	aud1per(pc),d7		* Selon la note
	add.w	d7,d7			* on choisit
	add.w	d7,d7
	move.w	0(a5,d7.w),d2		* un coef
	movea.w	2(a5,d7.w),a4		* un taux d'erreur

	lea	itab2(pc),a6		* Table de correction: voix 2
        moveq.l	#0,d3			
	move.w	0(a6,d7.w),d3		* Correction offset
	add.l	d0,d3
	cmp.l	wiz1len(pc),d3		* Test si on depasse la longueur du sample
	blt.s	.ok2
	sub.w	wiz1rpt(pc),d3		* dans lequel cas => gestion boucle
.ok2	move.w	d3,wiz1pos		* On note l'offset atteint
	move.w	2(a6,d7.w),d3		* Correction du taux d'erreur
	add.w	d3,wiz1frc
	
	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz3lc(pc),a1
	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	moveq.l	#0,d3			* Table de correction VBL
	move.w	0(a6,d7.w),d3
	add.l	d4,d3
	cmp.l	wiz3len(pc),d3
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d3
.ok3	move.w	d3,wiz3pos
	move.w	2(a6,d7.w),d3
	add.w	d3,wiz3frc
	
	move.w	aud3vol(pc),d7		* registres correspondants
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	ifne	spcalc			* Automodification routine de
	lea	create2+2(pc),a6	* calcul buffer sample
	else
	lea	create0+2(pc),a6
	endc
	moveq.l	#10+8+2*doublefreq,d7
	bsr	automodrout

	lea	itabvar,a4		* Table de correction Dynamique
	move.w	aud1per(pc),d3		* (pour chaque division)
	add.w	d3,d3
	lea	(a4,d3.w),a5
	move.w	aud3per(pc),d3
	add.w	d3,d3
	lea	(a4,d3.w),a4
		
		
	movea.l	samp1(pc),a6
	ifne	spcalc
	addq.w	#1,a6
	endc
	bsr	calc
		 
	lea	itab(pc),a5		******* Calcul voix DROITE
	lea	vtab(pc),a3
	moveq.l	#0,d0
	moveq.l	#0,d4

v2:	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4
	
	lea	itab2(pc),a6		* Table de correction: voix 1
        moveq.l	#0,d3
	move.w	0(a6,d7.w),d3
	add.l	d0,d3
	cmp.l	wiz2len(pc),d3
	blt.s	.ok1
	sub.w	wiz2rpt(pc),d3
.ok1:	move.w	d3,wiz2pos
	move.w	2(a6,d7.w),d3
	add.w	d3,wiz2frc
	
	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2
	
	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

        moveq.l	#0,d3			* Table de correction voix 4
	move.w	0(a6,d7.w),d3
	add.l	d4,d3
	cmp.l	wiz4len(pc),d3
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d3
.ok4	move.w	d3,wiz4pos
	move.w	2(a6,d7.w),d3
	add.w	d3,wiz4frc

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	ifne	spcalc
	lea	create2+2(pc),a6
	moveq.l	#10+8+2*doublefreq,d7
	else
	lea	create1+2(pc),a6
	moveq.l	#12+8+4*doublefreq,d7
	endc
	bsr.s	automodrout
	
	lea	itabvar,a4		* Table de correction VBL
	move.w	aud2per(pc),d3
	add.w	d3,d3
	lea	(a4,d3.w),a5
	move.w	aud4per(pc),d3
	add.w	d3,d3
	lea	(a4,d3.w),a4


	movea.l	samp1(pc),a6
	ifne	spcalc
	bsr	calc
	else
	bsr	calc2
	endc

	movem.l	(sp)+,d0-a6			* Restore les registres

	ifne cpu
	move.w	#$0,$ffff8240.w
	endc

	rte

*------------------------------------- AUTOMOD & SAMPLE CALC ROUTINES 
setbyte:	macro
	move.b	2(a0),d3
	move.b	0(a2,d3.w),d7
	move.b	2(a1),d3
	add.b	0(a3,d3.w),d7
	endm

var:	set	8
automodrout:
	add.l	d0,a0
	add.l	d4,a1
	moveq.l	#0,d0
	moveq.l	#0,d4
	rept	len/nbre_div
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.w	d0,(a6)
	move.w	d4,var(a6)
	add.w	d7,a6
	endr
	rts
	
	ifne	spcalc			* Si stackpointer calcul mode on
calc:	
	moveq.l	#0,d3
	moveq.l	#nbre_div-1,d6
	exg.l	a6,sp
create2:				* Routine de calcul du sample
	REPT LEN/nbre_div
	setbyte
	move.b	d7,(sp)+
	ifle	1-doublefreq
	move.b	d7,(sp)+
	ifle 	2-doublefreq
	move.b	d7,(sp)+
	move.b	d7,(sp)+
	endc
	endc
	ENDR
	add.w	(a5),a0				* Correction dynamique des 
	lea	$3a0*2(a5),a5			* offsets sample
	add.w	(a4),a1
	lea	$3a0*2(a4),a4
	dbra.w	d6,create2
	
	exg.l	a6,sp
	rts

	else				* Si sp non utilis‚
calc:	
	moveq.l	#0,d3
	moveq.l	#nbre_div-1,d6
create0:				* Routine de calcul du sample
	REPT LEN/nbre_div
	setbyte
	move.w	d7,(a6)+
	ifle	1-doublefreq
	move.w	d7,(a6)+
	ifle 	2-doublefreq
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	endc
	endc
	ENDR
	add.w	(a5),a0				* Correction dynamique des 
	lea	$3a0*2(a5),a5			* offsets sample
	add.w	(a4),a1
	lea	$3a0*2(a4),a4
	dbra.w	d6,create0
	rts

	opt	o-
var:	set	0
calc2:	moveq.l	#0,d3
	moveq.l	#nbre_div-1,d6
create1:				* Routine de calcul du sample
	REPT LEN/nbre_div
	setbyte
	move.b	d7,var(a6)
var:	set	var+2
	ifle	1-doublefreq
	move.b	d7,var(a6)
var:	set	var+2
	ifle 	2-doublefreq
	move.b	d7,var(a6)
	move.b	d7,var+2(a6)
var:	set	var+4
	endc
	endc
	ENDR
	add.w	(a5),a0				* Correction dynamique des 
	lea	$3a0*2(a5),a5			* offsets sample
	add.w	(a4),a1
	lea	$3a0*2(a4),a4
	lea	var(a6),a6
	dbra.w	d6,create1
	opt	o+
	rts

	endc

*-------------------------------------------- HARDWARE-REGISTERS & DATA
wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dummy	DC.L 0

samp1:	DC.L sample1
samp2:	DC.L sample2

sample1:	DS.W 	LEN*lfreq
		DS.W	8	
sample2:	DS.W	LEN*lfreq
		DS.W	8	
*--------------------------------------------------- INIT MODULE
prepare:move.l	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack:move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	move.l	data(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop:	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq:	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk:
	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep

repne:	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st:	
	move.w	(a4)+,(a0)+		; Move all samples back from stack
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6

rep:	movea.l	a0,a5
	moveq	#0,d1
toosmal:movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep:
	move.w	(a3)+,(a0)+		; Move all samples back from stack
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320*5,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320*5/2-1,d2
last320:
	move.w	(a5)+,(a0)+			; Move all samples back from stack
	dbra.w	d2,last320

done:	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok:lea	$1E(a1),a1
	dbra.w	d7,roop

	cmp.l	workspc,a0
	bgt.s	.nospac

	rts

.nospac:	illegal

end_of_samples:	DC.L 0

*--------------------------------------------------- INIT SAMPLE ADR TABLE
init:	move.l	data(pc),a0
	lea	$03B8(a0),a1

	moveq.l	#$7F,d0
	moveq.l	#0,d1
loop:	move.l	d1,d2
	subq.w	#1,d0
lop2:	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra.w	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq.l	#$1E,d0
lop3:	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra.w	d0,lop3

	move.l	a2,end_of_samples	;
	rts

*-------------------------------------------------------------------------*
*	MUSIC		Optimized version 0.5				  *
*-------------------------------------------------------------------------*

	opt	a+,o+,p+

music	move.l	data(pc),a0
	lea	counter(pc),a6
	addq.w	#$01,(a6)
	move.w	(a6),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	(a6)
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	(a6),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	move.l	data(pc),a0
	lea	$43c(a0),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon-counter(a6)

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon-counter(a6)
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc-counter(a6)	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len-counter(a6)		;
	move.w	d2,wiz1rpt-counter(a6)		;
	clr.w	wiz1pos-counter(a6)			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc-counter(a6)	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len-counter(a6)		;
	move.w	d2,wiz2rpt-counter(a6)		;
	clr.w	wiz2pos-counter(a6)			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc-counter(a6)	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len-counter(a6)	;
	move.w	d2,wiz3rpt-counter(a6)	;
	clr.w	wiz3pos-counter(a6)	;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc-counter(a6)	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len-counter(a6)	;
	move.w	d2,wiz4rpt-counter(a6)	;
	clr.w	wiz4pos-counter(a6)	;-------------------

wz_nch4	addi.w	#$10,pattpos-counter(a6)
	cmpi.w	#$0400,pattpos-counter(a6)
	bne.s	endr
nex	clr.w	pattpos-counter(a6)
	clr.b	break-counter(a6)
	addq.b	#1,songpos-counter(a6)
	andi.b	#$7F,songpos-counter(a6)
	move.b	songpos(pc),d1
	move.l	data(pc),a5
	cmp.b	$03B6(a5),d1
	bne.s	endr
	move.b	$03B7(a5),songpos-counter(a6)
endr:	tst.b	break-counter(a6)
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break-counter(a6)
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos-counter(a6)
	st	break-counter(a6)
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed-counter(a6)
	clr.w	(a6)
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

data:		dc.l	0			* Adresse module
workspc:	dc.l	0			* Adresse fin workspc

module:
	ifne	system
	INCBIN d:\sndtrack\modules\tcn\info.MOD
	Section  bss
	else
	dc.l	'Here'
	Section  bss
	ds.b	86422-4
	endc

		DS.b	27000			* Workspace
modulend:	DS.W	1

itabvar:	ds.w	$30			* Table de correction
stabvar:	ds.w	(nbre_div-1)*$3a0	* dynamique

sauv:		ds.b	200			* Espace
ecran:		ds.b	(fintext-text)/40*(6*160)	
	
						

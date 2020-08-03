*-------------------------------------------------------------------------*
*			                				  *
*	THE LIQUID OSMOSIS II 			- CYBERNETICS 1992 -      *
*			  				                  *
*	CODED                        by METAL AGES 			  *
*       VIDEO DIGITS                 by BRAIN BLASTER 	 		  *
*       MUSIC                        by CPT (AMIGA)      		  *
*       MUSIC RIPPED FROM THE AMIGA  by POLARIS	         		  *	
*					                 		  *
*-------------------------------------------------------------------------*

	opt	o+
	
	output	e:\code\effects.grx\liquid\liquid.prg

aigus:	set	8
graves:	set	10
cpu:	set	0

miniec:	macro	* Affichage de 2 ecrans digits                            

	rept	70
	movem.l	(a0)+,d0-d7/a5-a6
	movem.l	d0-d7/a5-a6,(a1)
	movem.l	d0-d7/a5-a6,(a2)
	lea	40(a1),a1
	lea	40(a2),a2
	movem.l	(a0)+,d0-d7/a5-a6
	movem.l	d0-d7/a5-a6,(a1)
	movem.l	d0-d7/a5-a6,(a2)
	lea	120(a1),a1
	lea	120(a2),a2
	endr

	endm

*********************************************** ANIMATION
	
	clr.l	-(sp)			* SUPERVISEUR
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack

	move.w	#2,-(sp)		* PHYBASE
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldec

	move.l	#buffer,d0
	and.w	#$8000,d0
      	move.l	d0,ec			* ADRESSE ECRAN	

	lea	$ffff8240.w,a0		* PALETTE A ZERO
	rept	8			
	clr.l	(a0)+
	endr

	clr.w	-(sp)			* RESOLUTION
	move.l	ec,-(sp)
	move.l	ec,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.b	#2,$ffff820A.w		* SYNCHRO

	bsr	initsound
	
	lea	pres,a0			* DECOMPACTE IMAGE DE PRESENTATION
	move.l	ec(pc),a1		* A L'ECRAN
	sub.l	a2,a2
	move.w	#199,d0	
	bsr	decomp

	lea	pal1,a0			* FADE IN COLORS
	move.w	#13,d0
fade1:	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	move.w	#20000,d1
temp7:	move.l	(sp),(sp)
	dbra.w	d1,temp7
	dbra.w	d0,fade1
	
	bsr	error_clavier		* WAIT FOR SPACE
temp5:	cmp.b	#57,$fffffc02.w
	bne.s	temp5
	bsr	error_clavier
temp6:	cmp.b	#185,$fffffc02.w
	bne.s	temp6
	bsr	error_clavier

	move.w	#13,d0			* FADE OUT COLORS
fade2:	lea	$ffff8240.w,a1
	lea	-32(a0),a0
	rept	8
	move.l	(a0)+,(a1)+
	endr
	lea	-32(a0),a0
	move.w	#20000,d1
temp8:	move.l	(sp),(sp)
	dbra.w	d1,temp8
	dbra.w	d0,fade2

	move.w	#11200*3/4,d0		* EFFACE L'ECRAN
	move.l	ec(pc),a0
eff2:	clr.l	(a0)+
	dbra.w	d0,eff2

	bsr	muson			* MUSIC ON

	lea 	scrtxt,a1
	move.w	#319,d0
eff:	clr.l	(a1)+
	dbra.w	d0,eff
					**** DEBUT MAIN LOOP
					
main:	move.w	#-1,flag		* VSYNC
temp:	tst.w	flag
	bne.s	temp

	ifne	cpu
	move.w	#$700,$ffff8240.w
	endc

	lea	52+off(pc),a1		* GESTION STROBOSCOPIE
	rept	12
	move.l	-8(a1),-(a1)
	endr

	subq.l	#4,a1			* GESTION POINTEUR ANIMATION 
	add.l	#5600,(a1)
	cmp.l	#5600*45,(a1)
	bne.s	oko
	clr.l	(a1)
oko:
					* AFFICHAGE 3*2 ECRANs
	move.l	ec(pc),a1	
	lea	70*160*2(a1),a1
	move.l	a1,a2
	lea	80(a2),a2
	lea	img,a3
	move.l	a3,a0
	add.l	off+48(pc),a0 
	miniec				* AFFICHAGE 2 ECRANs DU BAS

	lea	scrtxt,a3		* AFFICHAGE TEXTE
	move.l	ec(pc),a4
	lea	32000-2560(a4),a4
	rept	320
	move.l	(a3)+,d1
	or.l	d1,(a4)+
	endr

	lea	scrtxt,a3		* GESTION SCROLLTEXT
	rept	8			* DECALAGE 1 PIXEL SUR 4 PLANS
	roxl.w	152(a3)			* 8 LIGNES
	roxl.w	144(a3)		
	roxl.w	136(a3)		
	roxl.w	128(a3)		
	roxl.w	120(a3)		
	roxl.w	112(a3)		
	roxl.w	104(a3)		
	roxl.w	96(a3)		
	roxl.w	88(a3)		
	roxl.w	80(a3)		
	roxl.w	72(a3)		
	roxl.w	64(a3)		
	roxl.w	56(a3)		
	roxl.w	48(a3)		
	roxl.w	40(a3)		
	roxl.w	32(a3)		
	roxl.w	24(a3)		
	roxl.w	16(a3)		
	roxl.w	8(a3)		
	roxl.w	(a3)+		
	roxl.w	152(a3)	
	roxl.w	144(a3)		
	roxl.w	136(a3)		
	roxl.w	128(a3)		
	roxl.w	120(a3)		
	roxl.w	112(a3)		
	roxl.w	104(a3)		
	roxl.w	96(a3)		
	roxl.w	88(a3)		
	roxl.w	80(a3)		
	roxl.w	72(a3)		
	roxl.w	64(a3)		
	roxl.w	56(a3)		
	roxl.w	48(a3)		
	roxl.w	40(a3)		
	roxl.w	32(a3)		
	roxl.w	24(a3)		
	roxl.w	16(a3)		
	roxl.w	8(a3)		
	roxl.w	(a3)+		
	roxl.w	152(a3)	
	roxl.w	144(a3)		
	roxl.w	136(a3)		
	roxl.w	128(a3)		
	roxl.w	120(a3)		
	roxl.w	112(a3)		
	roxl.w	104(a3)		
	roxl.w	96(a3)		
	roxl.w	88(a3)		
	roxl.w	80(a3)		
	roxl.w	72(a3)		
	roxl.w	64(a3)		
	roxl.w	56(a3)		
	roxl.w	48(a3)		
	roxl.w	40(a3)		
	roxl.w	32(a3)		
	roxl.w	24(a3)		
	roxl.w	16(a3)		
	roxl.w	8(a3)		
	roxl.w	(a3)+		
	roxl.w	152(a3)	
	roxl.w	144(a3)		
	roxl.w	136(a3)		
	roxl.w	128(a3)		
	roxl.w	120(a3)		
	roxl.w	112(a3)		
	roxl.w	104(a3)		
	roxl.w	96(a3)		
	roxl.w	88(a3)		
	roxl.w	80(a3)		
	roxl.w	72(a3)		
	roxl.w	64(a3)		
	roxl.w	56(a3)		
	roxl.w	48(a3)		
	roxl.w	40(a3)		
	roxl.w	32(a3)		
	roxl.w	24(a3)		
	roxl.w	16(a3)		
	roxl.w	8(a3)		
	roxl.w	(a3)+		
	lea	152(a3),a3
	endr

	move.w	cpt,d0			* Main compteur
	move.w	d0,d1			
	and.w	#7,d0			* Pixel offset sur caractere courant
	tst.w	d0			* Si = 0
	bne	okg			
	lea    	txt,a3			* On prend le nouveau caractere 
	lsr.w	#3,d1			* 1 caractere = offset par rapport
	move.b	(a3,d1.w),d1		* au fichier fnt
	ext.w	d1
	cmp.w	#32,d1			* Espace
	bne.s	nospace
	move.w	#1280+152,d1
	bra.s	movecar
nospace:cmp.w	#33,d1			* Point d'exclamation 				
	bne.s	noexcla
	move.w	#1280+144,d1
	bra.s	movecar
noexcla:cmp.w	#42,d1
	bne.s	noreset
	move.w	#1280+152,d1
	clr.w	cpt
	bra.s	movecar
noreset:cmp.w	#44,d1			* Virgule
	bne.s	novirg
	move.w	#1280+136,d1
	bra.s	movecar
novirg: cmp.w	#46,d1			* Point
	bne.s	nopoint		
	move.w	#1280+128,d1
	bra.s	movecar
nopoint:sub.w	#48,d1			
	cmp.w	#9,d1	
	bgt.s	nonummer
	lsl.w	#3,d1
	add.w	#1280+56,d1
	bra.s	movecar
nonummer:
	sub.w	#65-48,d1
	cmp.w	#20,d1
	bge.s	low
	lsl.w	#3,d1
	move.w	d1,car
	bra.s	movecar
low:	sub.w	#20,d1
	lsl.w	#3,d1
	add.w	#1280,d1
movecar:move.w	d1,car
okg:	

	lea	fnt,a3			* Adr caractere
	add.w	car,a3			
	lea	scrtxt+152,a4		* Endroit a reafficher ds buffer
	neg.w	d0			* Prepare pour decalage
	addq.w	#7,d0			
	move.l	#$FFFEFFFE,d4		* Precharge masques
	move.l	#$10001,d5
	rept	8			* 8 Lignes
	move.l	(a3)+,d2		* Charge caractere plan 1 & 2
	move.l	(a3)+,d3		* plan 3 & 4
	lsr.l	d0,d2			* Decalage plan 1 & 2
	lsr.l	d0,d3			* Decalage plan 3 & 4
	and.l	d5,d2			* Mask les bits 15->1 du caractere
	and.l	d5,d3			* Idem plan 3 & 4
	and.l	d4,(a4)			* Mask le bit 0 des plans 1 & 2 sur la fin du scroll 
	or.l	d2,(a4)+		* Affiche plan  1 & 2
	and.l	d4,(a4)			* Idem pour plan 3 & 4
	or.l	d3,(a4)+	
	lea	152(a3),a3		* Ligne suivante
	lea	152(a4),a4
	endr
	addq.w	#1,cpt			* Gestion main pointer pour le scrolltext 

	lea	img,a3
	move.l	a3,a0
	add.l	off(pc),a0
	move.l	ec(pc),a1
	lea	80(a1),a2
	miniec				* AFFICHAGE 2 ECRANs DU HAUT

	move.l	a3,a0
	add.l	off+24(pc),a0
	miniec				* AFFICHAGE 2 ECRANs DU BAS 

	cmp.l	#32,gen			* FADE IN COLORS 
	bge.s	okl
	lea	$ffff8240.w,a0
	lea	pal2,a1
	move.l	gen(pc),d0
	and.w	#%111110,d0
	lsl.w	#4,d0
	add.w	d0,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr	
okl:
	addq.l	#1,gen	

	ifne	cpu
	move.w	#$0,$ffff8240.w
	endc

	cmp.b	#57,$fffffc02.w		* TEST TOUCHE & LOOP
	bne.s	okj			* 
	move.w	#-1,flagt		* FLAG POUR FADE OUT COLORS
okj:
	tst.w	flagt			* FADE OUT COLORS
	beq	main
	subq.w	#1,ext
	lea	$ffff8240.w,a0
	lea	pal2,a1
	move.w	ext,d0
	and.w	#%1111100,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1	
	rept	8
	move.l	(a1)+,(a0)+
	endr	
	tst.w	ext			* SORTIE QUAND EXT =0
	bne	main

	lea	$ffff8240.w,a0		* PALETTE A ZERO
	rept	8			
	clr.l	(a0)+
	endr

	bsr	error_clavier		* VIDE BUFFER CLAVIER

	bsr	musoff			* MUSIC OFF

	move.w	#1,-(sp)		* RESOLUTION
	move.l	oldec,-(sp)
	move.l	oldec,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	clr.b	$ffff820A.w		* SYNCHRO

	move.w	#0,$ffff8240.w		* COLOR OK
	move.w	#$555,$ffff8246.w

	move.l	stack,-(sp)		* UTILISATEUR
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	$4C0000			* END
	trap	#1			

initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
dmwr:	cmp.w		#$7ff,$ffff8924.w
	bne.s		dmwr
	move.w		#%10011101000,d0		* Volume max
	bsr		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr		microwrite
	rts

microwrite:
	move.w		d0,$ffff8922.w
	moveq.l		#127,d0
waitdma:dbra.w		d0,waitdma
	rts


fadesound:	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#1500,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2
	rts


					******* INTERs (graphic)
	
	  				* TIMER B

hbl1:	clr.b	$FFFFFA1B.w		* Hlb1: revectorise sur Hbl2
	move.b	#2,$FFFFFA21.w		* qui s'occupera du grossissement
	move.l	#hbl2,$120.w		* vertical pendant 80 lignes en  
	move.b	#8,$FFFFFA1B.w		* agissant sur le compteur video
	and.b	#%11111110,$FFFFFA0F.w	* (40 toutes les deux lignes)
	rte	

hbl2:					* Hbl2:		
	addq.w	#1,cptbig		* Si on est a plus de 40 appels de 
	cmp.w	#40,cptbig		* hbl2, on revectorise sur 
	bne.s	okd			* overscan qui gere le no border
	move.l	d0,-(sp)		* bas
	move.w	vert2(pc),d0
	neg.w	d0
	add.w	#157,d0
	add.w	ic2(pc),d0
	clr.b	$FFFFFA1B.w
	move.b	d0,$FFFFFa21.w
	move.l	#overscan,$120.w
	move.b	#8,$FFFFFA1B.w
	move.l	(sp)+,d0
	and.b	#%11111110,$FFFFFA0F.w
	rte				* fin inter si plus de 40 appels
okd:	move.l	d0,-(sp)		* Sinon 
	move.w	vert2(pc),d0		
	sub.w	ic2(pc),d0		* on stabilise par rapport au
	addq.w	#3,d0			* compteur video car le timer B
	mulu.w	#160,d0			* n'est pas stable avec la routine
temp4:	cmp.b	$FFFF8209.w,d0		* de tracker et il faut eviter de
	bne.s	temp4			* toucher au compteur video qd il
	addq.w	#1,vert2		* affiche.
	move.l	(sp)+,d0
	sub.b	#160,$FFFF8209.w	* on soustrait 160 au compteur:
	bcc.s	okc			* grossissement vertical (X 2)
	subq.b	#1,$FFFF8207.w		*
okc:
	and.b	#%11111110,$FFFFFA0F.w	* fin d'inter
	rte


overscan:				* no border bas
	move.l	d0,-(sp)		* sauvegarde registres
	move.l	a0,-(sp)
	lea	$FFFF8209.w,a0	
temp3:	tst.b	(a0)			* synchronisation par rapport
	bne.s	temp3			* a la fin de la ligne 198
temp10_:move.b 	(a0),d0			* synchronisation par rapport
	beq.s	temp10_			* au debut de la ligne 199
	neg.w	d0			* pour faire une 'synchro lsl'
	add.w	#16,d0
	lsl.w	d0,d0			* synchro lsl
	rept	70			
	nop				* nops -> fin de la ligne 199
	endr
	clr.b	$ffff820a.w		* 60 Hz
	rept	20
	nop				* on attend un peu
	endr
	move.b	#2,$ffff820a.w		* 50 Hz
	move.l	(sp)+,a0 		* restaure registres
	move.l	(sp)+,d0 
	clr.b	$FFFFFA1B.w		* arrete le timer B
	and.b	#%11111110,$FFFFFA0F.w	* fin d'inter
	rte


vbl:					* VBL

	clr.b	$FFFFFA1B.w		* arrete le timer B
	move.l	#hbl1,$120.w		* vectorise hbl1  

	move.w	vert(pc),$FFFFFA20.w	* mvt vertical du grossissement
	move.b	#8,$FFFFFA1B.w		*
	move.w	d0,-(sp)		*	( sauvegarde registre )
	move.w	ic(pc),d0		*
	add.w	d0,vert			*
	move.w	(sp)+,d0		* 	( restaure registre )
	move.w	ic(pc),ic2		*
	move.w	vert(pc),vert2		*
	cmp.w	#100,vert		*
	bne.s	oka			*
	neg.w	ic			*
oka:	cmp.w	#3,vert			*
	bne.s	okb			*
	neg.w	ic			*
okb:	
	clr.w	flag			* flag pour la synchro 2 vbls de l'affichages des ecrans

	clr.w	cptbig			* flag a zero du nombre d'appels de hbl2 effectues 

	rte				* fin d'inter
	
					***** DECOMPACTAGE
decomp:					
	move.w	(a0)+,d4		*a0: image compactee
	lea	32(a0),a0		*a1: ecran dest
	cmp.l	#0,a2			*a2: pal 
	beq.s	endifdec2		*d0: hauteur-1
	lea	-32(a0),a0
	rept	8
	move.l	(a0)+,(a2)+
	endr
endifdec2:
	move.l	a0,a2			
	lsl.w	#2,d4			
	add.w	d4,a2	
	moveq.w	#39,d4
	moveq.w	#0,d2
	moveq.l	#0,d3
	move.l	a1,a3
dec:	move.l	a3,a1
	addq.l	#4,a3
	move.w	d0,d1			
dec2:	tst.w	d2
	bne.s	endifdec
	move.b	(a2)+,d2
	move.l	(a0)+,d3
endifdec:
	move.l	d3,(a1)
	lea	160(a1),a1
	subq.w	#1,d2
	dbra.w	d1,dec2
	dbra.w	d4,dec
	rts

error_clavier: 				
	btst	#5,$fffffc00.w		* vide le buffer clavier
	beq.s	noerror
	tst.b	$fffffc02.w
	bra.s	error_clavier
noerror:
	btst	#0,$fffffc00.w
	beq.s	vidbuff                          
	tst.b	$fffffc02.w
	bra.s	error_clavier
vidbuff:
	move.w	#0,$fffffc02.w
	rts

	************** ZONES POUR MES VARS

stack:	dc.l	0
oldec:	dc.l	0
ec:	dc.l	0
flag:	dc.w	0
ic:	dc.w	1
vert:	dc.w	5
vert2:	dc.w	5
ic2:	dc.w	1
cptbig: dc.w	0
car:	dc.w	0	
cpt:	dc.w	0
gen:	dc.l	0
ext:	dc.w	64
flagt:	dc.w	0

savtim1_1:	dc.b	0
savtim1_2:	dc.b	0
savtim2_1:	dc.b	0
	even
oldtimb:	dc.l	0
oldvbl:		dc.l	0
	
off:	dc.l	44*5600		*	<-
	dc.l	44*5600	
	dc.l	44*5600	
	dc.l	44*5600	
	dc.l	44*5600	
	dc.l	44*5600	
	dc.l	44*5600		*	<-
	dc.l	44*5600
	dc.l	44*5600	
	dc.l	44*5600	
	dc.l	44*5600
	dc.l	44*5600
	dc.l	44*5600		*	<-

pal:	dc.w	$0008,$0001,$0009,$0002,$008A,$0083,$008B,$0084
	dc.w	$001C,$0095,$0025,$003D,$00B6,$004E,$00CE,$08DF


*************************************** ROUTINES PROTRACKER ************

;-----------------------------------------------------------------------;									;
; MVOL = Main volume	  (Unnecessary to adjust. $80 default)		;
; FREQ = replay frequency (See below)					;
;-----------------------------------------------------------------------;

MVOL	EQU $80
FREQ	EQU 1				; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
PARTS	EQU 5-1				; 6.259
LEN	EQU 25
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
PARTS	EQU 5-1				; 12.517
LEN	EQU 50
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
PARTS	EQU 5-1				; 25.035
LEN	EQU 100
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
PARTS	EQU 5-1				; 50.072
LEN	EQU 200
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

;---------------------------------------------------- Interrupts on/off --
muson	bsr	vol			 ; Calculate volume tables
	bsr	incrcal			 ; Calculate tonetables

	jsr	init			 ; Initialize music
	jsr	prepare			 ; Prepare samples

	move	#$2700,sr

	move.b	$FFFFFA07.w,savtim1_1
	move.b	$FFFFFA09.w,savtim2_1
	move.b	$FFFFFA13.w,savtim1_2

	clr.b	$FFFFFA07.w
	clr.b	$FFFFFA09.w

	bset.b	#3,$fffffa17.w			; End mode

	bset.b	#0,$FFFFFA07.w			
	bset.b	#0,$FFFFFA13.w
	bset.b	#5,$FFFFFA07.w
	bset.b	#5,$FFFFFA13.w

	clr.b	$FFFFFA19.w			; Data register
	move.b	#1,$FFFFFA1F.w
	clr.b	$FFFFFA1B.w			; Data register
	move.b	#100,$FFFFFA21.w

	move.b	#8,$FFFFFA19.w			; Control register
	move.b	#8,$FFFFFA1B.w

	move.l	$134.w,oldtima			; Sauve anciens vecteurs
	move.l	$120.w,oldtimb
	move.l	$70.w,oldvbl
	
	move.l	#stereo,$0134.w			; Vecteurs
	move.l	#hbl1,$120.w
	move.l	#vbl,$70.w

	move.b	#FREQ+1,$FFFF8921.w		; Frequency

	lea	$FFFF8907.w,a0

	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	#sample1+LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	move.b	#3,$FFFF8901.w		; Start DMA

	move	#$2300,sr
	rts

musoff	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timer A	
	clr.b	$FFFFFA1B.w		; Stop timer B

	move.l	oldtima(pc),$134.w	; Restore everything
	move.l	oldtimb(pc),$120.w
	move.l	oldvbl(pc),$70.w

	move.b	savtim1_1(pc),$FFFFFA07.w
	move.b	savtim1_2(pc),$FFFFFA13.w
	move.b	savtim2_1(pc),$FFFFFA09.w

	clr.b	$FFFF8901.w			; Stop DMA

	move	#$2300,sr
	rts

oldtima	DC.L 0

;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;------------------------------------------------------ Increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
stereo:
	and.b	#%11011111,$FFFFFA0F.w
	move.w	#$2300,sr

	movem.l	d0-a6,-(sp)

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1(pc),d0
	add.l	#LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	tst.w	flagt
	beq.s	okz
	cmp.w	ext,d7
	ble.s	okz
	move.w	ext,d7
okz:
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

	move.w	aud3vol(pc),d7
	tst.w	flagt
	beq.s	oky
	cmp.w	ext,d7
	ble.s	oky
	move.w	ext,d7
oky:
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	ENDR

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	tst.w	flagt
	beq.s	okw
	cmp.w	ext,d7
	ble.s	okw
	move.w	ext,d7
okw:
	lea	0(a3,d7.w),a2

	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	tst.w	flagt
	beq.s	okx
	cmp.w	ext,d7
	ble.s	okx
	move.w	ext,d7
okx:
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

var:	set	0
	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,var(a6)
	move.b	d7,var+2(a6)
var:	set	var+4
	ENDR

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6
	rte

;-------------------------------------------- Hardware-registers & data --

count	DC.W PARTS

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

dmactrl	DC.W 0

dummy	DC.L 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1	DS.W LEN*2
sample2	DS.W LEN*2

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	data(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	data(pc),a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	data(pc),a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
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
	move.w	counter(pc),d0
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

getnew	lea	data+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

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
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data+$03B6(pc),d1
	bne.s	endr
	move.b	data+$03B7(pc),songpos
endr:	tst.b	break
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
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
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
	move.w	d0,speed
	clr.w	counter
rts2	rts

	Section	data

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

data:	INCBIN "d:\sndtrack\modules\tcn\hydro.MOD"

	DS.B	58000			; Workspace
workspc:DS.W	1

scrtxt:	ds.w	1280/2

txt:	dc.b	' OPEN YOUR KARMA TO THE POSITIVE ENERGY OF THE LIQUID '
	dc.b	'OSMOSIS. LET THE CYBERNETICS SPIRIT ENTER IN YOUR MIND.'
	dc.b	' YOU FEEL MECHANICAL. YOU ARE NOW A LIQUID BIOMECHANOID'
	dc.b	', IN COMPLETE OSMOSIS WITH WATER. D,ONT BE AFRAID, YOUR '
	dc.b	'MIND BELONGS TO LIQUID. YOU CAN NOW AFFORD THE ELEMENTS.'
	dc.b	'    CALM... WARM FEELINGS... YOU ARE SWIMMING IN THE '
	dc.b	'ELECTRONIC WATER OF THIS SCREEN.          NOW IT,S TIME TO...*'
	
	even
fnt:	incbin	"font.bin"		* FONTE 8X8 - 4 PLANS
pal1:
		dc.w	$0000,$0000,$0000,$0000,$0008,$0008,$0008,$0008
		dc.w	$0008,$0008,$0008,$0008,$0001,$0001,$0001,$0001
		dc.w	$0000,$0000,$0000,$0008,$0008,$0008,$0008,$0008
		dc.w	$0001,$0081,$0081,$0081,$0081,$0089,$0089,$0089
		dc.w	$0000,$0000,$0008,$0088,$0888,$0881,$0881,$0881
		dc.w	$0819,$0819,$0819,$0812,$0112,$0192,$019A,$019A
		dc.w	$0000,$0000,$0088,$0888,$0881,$0881,$0811,$0819
		dc.w	$0119,$0112,$0192,$0192,$019A,$099A,$0923,$0923
		dc.w	$0000,$0000,$0888,$0888,$0881,$0811,$0119,$0119
		dc.w	$0192,$0192,$099A,$092A,$0923,$0923,$02A3,$02AB
		dc.w	$0000,$0008,$0888,$0881,$0811,$0119,$0119,$0192
		dc.w	$0992,$092A,$092A,$0223,$02A3,$02AB,$0A3B,$0A34
		dc.w	$0000,$0008,$0888,$0881,$0111,$0119,$0192,$0992
		dc.w	$092A,$022A,$02A3,$02AB,$0A3B,$0A34,$0334,$03BC
		dc.w	$0000,$0088,$0888,$0811,$0119,$0199,$0992,$092A
		dc.w	$022A,$02A3,$0AAB,$0A3B,$0334,$03BC,$03BC,$0B45
		dc.w	$0000,$0888,$0888,$0111,$0119,$0992,$0922,$022A
		dc.w	$02A3,$0AAB,$0A3B,$03B4,$03BC,$0B4C,$0B45,$04CD
		dc.w	$0000,$0888,$0881,$0111,$0199,$0992,$022A,$02A3
		dc.w	$0AA3,$0A3B,$03B4,$0BBC,$0B45,$04C5,$04CD,$0C56
		dc.w	$0000,$0888,$0881,$0119,$0999,$0922,$022A,$0AA3
		dc.w	$0A3B,$03B4,$0BBC,$0B4C,$04C5,$0CCD,$0C56,$05DE
		dc.w	$0000,$0888,$0811,$0119,$0992,$022A,$02A3,$0A3B
		dc.w	$033B,$0BB4,$0B4C,$04C5,$0C5D,$0C56,$05DE,$0D67
		dc.w	$0000,$0888,$0111,$0199,$0992,$022A,$0AA3,$033B
		dc.w	$03B4,$0B4C,$04C5,$0CCD,$0556,$05DE,$0D67,$06EF
		dc.w	$0000,$0888,$0111,$0199,$0992,$022A,$0AA3,$033B
		dc.w	$03B4,$0B4C,$04C5,$0C5D,$0556,$05DE,$0D67,$06EF
pal2:
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0008,$0008,$0008,$0008,$0001,$0001,$0001,$0001
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0008,$0001,$0001,$0001,$0001,$0009,$0009,$0009
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0008,$0001,$0001,$0001,$0009,$0009,$0002,$0002
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0001,$0001,$0009,$0009,$0082,$0082,$008A,$008A
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0001,$0081,$0089,$0089,$0082,$001A,$001A,$0013
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0001,$0089,$0089,$0082,$001A,$0013,$0093,$009B
		dc.w	$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008
		dc.w	$0081,$0089,$0012,$0012,$009A,$0093,$002B,$0024
		dc.w	$0008,$0008,$0008,$0008,$0001,$0001,$0001,$0001
		dc.w	$0089,$0082,$001A,$001A,$0093,$002B,$0024,$00AC
		dc.w	$0008,$0008,$0008,$0008,$0001,$0001,$0001,$0001
		dc.w	$0089,$0082,$001A,$001A,$0093,$002B,$0024,$00AC
		dc.w	$0008,$0008,$0001,$0001,$0001,$0001,$0009,$0009
		dc.w	$0082,$001A,$0013,$0093,$002B,$00A4,$00AC,$0035
		dc.w	$0008,$0008,$0001,$0001,$0009,$0009,$0002,$0002
		dc.w	$008A,$0013,$009B,$009B,$0024,$00AC,$0035,$00BD
		dc.w	$0008,$0001,$0001,$0009,$0009,$0002,$0002,$000A
		dc.w	$0083,$001B,$0094,$0024,$00AC,$0035,$00BD,$0046
		dc.w	$0008,$0001,$0001,$0009,$0002,$000A,$000A,$0003
		dc.w	$008B,$0014,$009C,$002C,$0035,$00BD,$0046,$00CE
		dc.w	$0008,$0008,$0001,$0009,$0002,$000A,$0003,$000B
		dc.w	$0084,$001C,$009C,$00A5,$003D,$00B6,$0046,$0057
		dc.w	$0008,$0001,$0009,$0002,$008A,$0083,$008B,$0084
		dc.w	$001C,$0095,$0025,$003D,$00B6,$004E,$00CE,$08DF

	even
pres:	incbin  "pres.dat"			* IMAGE PRESENTATION
	even
img:	incbin	"water.dat"			* ANIMATION VIDI ST

	Section		bss

		ds.b	32768
buffer:		ds.b	280*160





                   



                                                                                                                                            
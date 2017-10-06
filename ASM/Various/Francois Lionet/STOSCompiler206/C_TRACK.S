*
*	EXTENSION STOS-TRACKER COMPILATEUR
*
*	Par Francois Lionet
*	STOS (c) Mandarin 1988
*
* Incluez le fichier d'EQUATES si vous avez
* la disquette du journal.
*	Include "Equates.s"
Debut:	equ	$92c
Buffer:	equ	$938
Error:	equ	$93c
SVect:	equ	$9b4
Dta:	equ	$970

******* POINTEURS SUR LES LIBRAIRIES
Debu:   dc.l Para-Debu
        dc.l Data-Debu
        dc.l Libr-Debu

******* CATALOGUE
Cata:   dc.w 	L2-L1,L3-L2
	dc.w	L4-L3,L5-L4
	dc.w	L6-L5,L7-L6
	dc.w	L8-L7,L9-L8
	dc.w	L10-L9,L11-L10
	dc.w	L12-L11,L13-L12
	dc.w	L14-L13,L15-L14
	
******* LISTE DES FONCTIONS
Para:   dc.w 	14
	dc.w	13    
        dc.w 	P2-Para,P0-Para
	dc.w	P1-Para,P1-Para
	dc.w	P1-Para,P0-Para
	dc.w	P1-Para,P0-Para
	dc.w	P1-Para,P0-Para
	dc.w	P1-Para,P0-Para
	dc.w	P0-Para

P0:	dc.b	0		* Pas de parametre
	dc.b	1,0
	even
P1:	dc.b	0		* 1 entier
	dc.b	0,1
	dc.b 	1
	even
P2:	dc.b	0		* "chaine",nombre
	dc.b	$80,",",0,1,0	
	dc.b	1
	even
	
******* ZONE DE DONNEES/INITIALISATION
DATA

* ENTREE DE LA ROUTINE INITIALISATION
Init:   
* Enlevez les etoiles pour debugger!
*	lea	SVect(a5),a2
*	move.l	(a2)+,$8
*	move.l	(a2)+,$c
*	move.l	(a2)+,$404
*	move.l	(a2)+,$10
*	move.l	(a2)+,$14
	lea 	TEnd(pc),a2
	moveq	#0,d0
	rts
* ROUTINE DE FIN
TEnd	move.w	#$2700,sr
	bsr	MusOff
	move.w	#$2300,sr
	move.w	#4000,d0
TEnd1	nop
	dbra	d0,TEnd1
	rts

* DATAS
	even
THandle	dc.w 	0
Touche	dc.w	0
TStop	dc.b	$61,0	

* ROUTINES STOS-TRACKER
	Include	"ST_STOS.S"
	even

******* QUELQUES ROUTINES DE LA LIBRAIRIE PRINCIPALE
L_Reserve	equ	219
L_Reloge	equ	220
L_Erase		equ	222
L_AdOuBank	equ	214

******* DEBUT DE LA LIBRAIRIE
Libr:

******* TRACK LOAD "nom",bank
L1:	dc.w	ki1-l1,ki2-l1
	dc.w 	L1a-L1,L1b-L1,L1c-L1,L1d-L1,L1e-L1,0
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
	move.l	(a6)+,d6
	cmp.l	#15,d6
	bhi	L1FCall
	move.l	(a6)+,a2
	move.w	(a2)+,d2
ki1	jsr	$80000000+13
ki2	jsr	$80000000+14
; Arrete la musique 
	jsr	MusOff-Data(a3)	
; Prepare le buffer disquette
	bsr	SetDta
; Efface la banque de memoire
	move.l	d6,d3
	movem.l	d0-d7/a0-a3,-(sp)
L1a	jsr	L_Erase
L1b	jsr	L_Reloge
	movem.l	(sp)+,d0-d7/a0-a3
; Copie la chaine dans le buffer, zero a la fin	
	move.l	Buffer(a5),a0
	move.l	a0,a1
	move.l	a1,d4
	subq.w	#1,d2
	bmi	L1Fcall
Stl1	move.b	(a2)+,(a1)+
	dbra	d2,Stl1
	clr.b	(a1)
; Ouvre le fichier
	moveq	#0,d0
	bsr	Open
	bmi	L1NFnd
; Charge l'entete dans le buffer, prend sa taille
	lea	128(a0),a0
	moveq	#12,d0
	bsr	Read
	cmp.l	#"AmBk",(a0)
	bne	L1FCall
	move.l	8(a0),d3
	and.l	#$FFFFFF,d3
	move.l	d3,d5
; Il faut fermer le fichier
	bsr	Close
; Va reserver la banque
	move.l	d6,d2
	move.w	#$81,d1
	movem.l	d0-d7/a0-a3,-(sp)
L1c	jsr	L_Reserve
L1d	jsr	L_Reloge
	movem.l	(sp)+,d0-d7/a0-a3
; Charge le reste de la banque
	move.l	d4,a0
	moveq	#0,d0
	bsr	Open
	bmi	L1DErr
	move.l	Buffer(a5),a0
	moveq	#12,d0	
	bsr	Read
	bne	L1DErr
	move.l	d6,-(a6)
L1e	jsr	L_AdOuBank
	move.l	d3,a0
	move.l	d5,d0
	bsr	Read
	bne	L1DErr
	bsr	Close
; Initialise la banque
	move.l	a0,a1
	jsr	BkNew-Data(a3)
	bne.s	L1DErr
; Termine
	rts
******* Routines disques
; Initialise la zone d'echange avec la disquette
setdta	movem.l	a0/d0,-(sp)
	move.l 	DTA(a5),-(sp)
	move.w 	#$1a,-(sp)
        trap 	#1
	addq.l 	#6,sp
	movem.l	(sp)+,a0/d0
	rts
; Open fichier (a0), mode d0
open	move.l	a0,-(sp)
	move.w 	d0,-(sp)
        move.l 	a0,-(sp)
        move.w 	#$3d,-(sp)
        trap 	#1
	addq.l	#8,sp
	lea	THandle-Data(a3),a0
	move.w	d0,(a0)
	move.l	(sp)+,a0
        tst.w 	d0
        rts
; Read dans A0, D0 octets
read  	movem.l	a0/d0,-(sp)
	move.l 	a0,-(sp)
       	move.l 	d0,-(sp)
        move.w	THandle-Data(a3),-(sp)
        move.w 	#$3f,-(sp)
        trap 	#1
        lea	12(sp),sp
	movem.l	(sp)+,a0/d1
	cmp.l	d0,d1
	rts
; Ferme le fichier, si ouvert
close	movem.l	a0/d0,-(sp)
	move.w	THandle-Data(a3),d0
	beq.s 	cloclo
        clr.w	THandle-Data(a3)
	move.w 	d0,-(sp)
        move.w 	#$3e,-(sp)
        trap 	#1
        addq.l 	#4,sp
cloclo	movem.l	(sp)+,a0/d0
	rts
******* Erreurs
; Illegal fonction call
L1FCall	moveq	#13,d0
	bra.s	L1Err
L1NFnd	moveq	#48,d0
	bra.s	L1Err
; Disc error
L1DErr	moveq	#52,d0
; Appel de l'erreur
L1Err	bsr	Close
	move.l	Error(a5),a0
	jmp	(a0)

******* =TRACK SCAN
L2:	dc.w	0
	move.l	Debut(a5),a0	
	move.l	0(a0,d1.w),a0
	lea	Touche-Data(a0),a0
	moveq	#0,d0
	move.b	(a0),d0
	move.l	d0,-(a6)
	clr.b	(a0)
	rts

******* TRACK BANK bank
L3:	dc.w	L3a-L3,0	
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
	lea	MB-Data(a3),a0
	clr.l	MusBank-MB(a0)
	move.l	(a6)+,d3
L3a:	jsr	L_AdOuBank
	move.l	a0,a1
	jsr	BkNew-Data(a3)
	bne.s	L3Bad
	rts
L3Bad	moveq	#13,d0
	move.l	Error(a5),a0
	jmp	(a0)

******* TRACK VU(voix)
L4:	dc.w 	0
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
	move.l	(a6)+,d0
	subq.l	#1,d0
	cmp.l	#4,d0
	bcc.s	L4FCall
	moveq	#0,d1
	lea	MB-Data(a3),a0
	move.b	0(a0,d0.w),d1
	clr.b	0(a0,d0.w)
	move.l	d1,-(a6)
	rts
L4FCall	moveq	#13,d0
	move.l	Error(a5),a0
	jmp	(a0)

******* TRACK PLAY music
L5:	dc.w	0
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
; Poke les adresses dans la routine
	lea	TtAd1+2(pc),a1
	move.l	a3,(a1)
	lea	Play-Data(a3),a0
	lea	TtAd2+2(pc),a1
	move.l	a0,(a1)
; Demarre la routine
	move.l	(a6)+,d3
	jsr	IMusic-Data(a3)
; Installe la routine de test de touche
	move.w	#$2700,sr
	lea	TTouche(pc),a0
	move.l	a0,$70.w
	move.w	#$2300,sr
	rts
; Test du processeur clavier
TTouche	movem.l	a0/d0,-(sp)
TtAd1	lea	$0,a0 
	tst.l	MuBase-Data(a0)
	beq.s	TTouX
	btst	#0,$FFFFFC00.w
	beq.s	TTouX
	move.b	$FFFFFC02.w,d0
	bmi.s	TTouX
	move.b	d0,Touche-Data(a0)
	cmp.b	TStop-Data(a0),d0
	bne.s	TTouX
; Provoque l'arret de la musique 
	move.l	MuBase-Data(a0),a0
	clr.w	VoiLong*0+VoiCpt(a0)
	clr.w	VoiLong*1+VoiCpt(a0)
	clr.w	VoiLong*2+VoiCpt(a0)
	clr.w	VoiLong*3+VoiCpt(a0)
	move.w	#101,MuCpt(a0)
TTouX	movem.l	(sp)+,a0/d0
TtAd2	jmp	TtAd2

******* Fonction 6
L6:	dc.w	0

******* TRACK KEY k
L7:	dc.w	0
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
	move.l	(a6)+,d0
	lea	TStop-Data(a3),a0
	move.b	d0,(a0)
	rts

******* Fonction 8
L8:	dc.w	0

******* TRACK VOLUME v
L9:	dc.w	0
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
	move.l	(a6)+,d0
	bmi.s	L9FCall
	jsr	MVol-Data(a3)
	rts
L9FCall	moveq	#13,d0
	move.l	Error(a5),a0	
	jmp	(a0)

******* Fonction 10
L10:	dc.w	0

******* TRACK TEMPO
L11:	dc.w	0
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
	move.l	(a6)+,d3
	jsr	STempo-Data(a3)
	rts

******* Fonction 12
L12:	dc.w	0

******* TRACK STOP
L13:	dc.w	0
	move.l	Debut(a5),a3	
	move.l	0(a3,d1.w),a3
	move.w	#$2700,sr
	jsr	MusOff-Data(a3)
	move.w	#$2300,sr
	move.w	#4000,d0
St_W	nop
	dbra	d0,St_W
	rts

******* Essai!
L14:	dc.w	0
	move.w	#$1234,d0
	rts


L15:	dc.w	0
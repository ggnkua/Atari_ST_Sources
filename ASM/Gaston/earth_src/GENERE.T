;----- Fichier : Genere.T -------------------------------------------------

	SECTION TEXT

***************************************************************************

Total		equr	d1
x		equr	d2
Largeur_Ligne	equr	d3
Y1		equr	d4
ray		equr	d5
Offset		equr	d6

buff2		equr	a0
adrgen		equr	a1
gen		equr	a2
Y2		equr	a3
buff		equr	a5

***************************************************************************

;----- GENERATION DU CODE POUR CHAQUE LARGEUR DE LIGNE --------------------

	lea	genere,gen
	lea	adrgenere,adrgen

***************************************************************************
				
;----- POUR Largeur_Ligne DE 2 A 384 PAR PAS DE 2 FAIRE: ------------------

	move.w	#2,Largeur_Ligne
For_LargLigne:


***************************************************************************

;----- INITIALISATIONS ----------------------------------------------------

	move.w	Largeur_Ligne,Ray
	lsr.w	#1,Ray
	
	move.w	#-1,Y2

***************************************************************************

;----- BUFFER => OFFSETS DES POINTS A AFFICHER ----------------------------

	lea	buffer,buff
	move.w	#1,x
for_x:
	move.w	x,d0
	move.w	Ray,d1
	bsr	COS	; D0=   Ray*Cos(x*90/hautbande)
	move.w	#160,Y1
	sub.w	d0,Y1	; Y=160-Ray*Cos(x*90/hautbande)

	cmp.w	Y1,Y2
	beq.s	noteq
	move.w	x,d0	; Si y<>Y2 : on stocke x/2 dans le
	lsr.w	#1,d0	; tableau buffer
	move.w	d0,(buff)+	
	move.w	Y1,Y2	; et on r‚affecte Y2
noteq:	
	addq.w	#1,x
	move.w	#Hautbande,d0
	lsl.w	#1,d0
	cmp.w	d0,x
	bne.s	for_x	; R‚pŠte jusqu'… ce que x=Hautbande*2

	move.w	#$FFF,(buff)+

***************************************************************************

;----- COPIE LES ECARTS ENTRE 2 PTS DANS LE BUFFER2 -----------------------

	lea	buffer,buff
	lea	buffer2,buff2
	clr.w	sbuffer2
Copie_Buffer:
	move.w	2(buff),d0
	sub.w	(buff),d0
	move.w	d0,(buff2)+	
	add.w	d0,sbuffer2
	
	addq.l	#2,buff
	cmpi.w	#$fff,2(buff)
	bne.s	Copie_Buffer
	move.w	(buffer2),d0
	
	add.w	d0,sbuffer2
	move.w	sbuffer2,d1
	btst.l	#0,d1
	beq.s	suitt
	ADDq.w	#1,d0
	ADDq.w	#1,sbuffer2
	
suitt:	move.w	#$FFF,(buff2)+

***************************************************************************

;----- G‚NŠRE LE CODE G‚N‚RANT LA G‚N‚RATION DU CODE G‚N‚R‚ ---------------

	lea	buffer2,buff
	clr.w	offset
	clr.w	reajuste
	move.l	gen,(adrgen)+
ge:	
	; LEA X(A6),A6
	move.w	#Xrsl,d0
	sub.w	Largeur_Ligne,d0
	move.w	#$4DEE,(gen)+
	move.w	d0,(gen)+
	
	; MOVE.W (A5),(A6)+
 	move.w	#$3CD5,(gen)+
OKAY:	
	cmpi.w	#1,2(buff)
	beq.s	CONSECUTIFS
	
	;--------------------------------------------------------------

	; BLOC DE POINTS NON CONSECUTIFS
NON_CONSECUTIFS:
	move.w	(buff)+,d0
	lsl.w	#1,d0
	add.w	d0,offset
	
	move.w	#$3CED,(gen)+
	move.w	offset,(gen)+
	
	cmp.w	#$fff,(buff)
	beq	Fin_Genere
	bra.s	OKAY

	;--------------------------------------------------------------
	
	; BLOC DE POINTS CONSECUTIFS : OPTIMISATION MAX
CONSECUTIFS:
	move.l	buff,buff2
	
	clr.w	total
Ripite:	move.w	(buff2)+,d0
	addq.w	#1,total		
	cmpi.w	#1,(buff2)
	beq.s	Ripite

Cas2_5:	cmpi.w	#6,total
	bhs.s	Cas6_11

	subq.w	#2,total
	lsr.w	#1,total
	bcc.s	Move_l
	move.w	(buff)+,d0
	lsl.w	#1,d0
	add.w	d0,offset
	move.w	#$3CED,(gen)+
	move.w	offset,(gen)+

Move_l:	
	move.w	(buff)+,d0
	lsl.w	#1,d0
	add.w	d0,offset
	move.w	#$2CED,(gen)+
	move.w	offset,(gen)+
	move.w	(buff)+,d0
	lsl.w	#1,d0
	add.w	d0,offset
	dbra	total,Move_l
	bra	Retour

Cas6_11:	cmpi.w	#12,total
	bhs.s	Cas12
	
	move.w	(buff)+,d0
	lsl.w	#1,d0
	add.w	d0,offset
	move.w	#$4bed,(gen)+
	move.w	offset,(gen)+

	add.w	offset,reajuste
	move.w	total,d0

	subq.w	#4,total
	lsr.w	#1,total
	bcc.s	Move_plus
	move.w	#$3cdd,(gen)+
	addq.w	#2,reajuste	
	
Move_plus:	move.w	#$2cdd,(gen)+
	addq.w	#4,reajuste
	dbra	total,Move_plus	
	move.w	#$2cd5,(gen)+

	clr.w	offset
	subq.w	#1,d0
	lsl.w	#1,d0
	lea	(buff,d0.w),buff
	bra.s	Retour
	
Cas12:	

	move.w	#%1111111111111,Y1
	move.w	#26,Ray
Les_13:
TstMovem:
	cmp.w	Ray,total
	blo.s	Ftm
	
	sub.w	Ray,total

	move.w	(buff)+,d0
	lsl.w	#1,d0
	add.w	d0,Offset

	move.w	#$4bed,(gen)+
	move.w	Ray,(gen)
	add.w	Ray,(gen)+

	move.w	#$4dee,(gen)+
	move.w	Ray,(gen)
	add.w	Ray,(gen)+

	move.w	Ray,d0
	subq.w	#2,d0
NewOff:	move.w	Y1,-(sp)
	move.w	(buff)+,Y1
	lsl.w	#1,Y1
	add.w	Y1,Offset
	move.w	(sp)+,Y1
	dbra	d0,NewOff
	
	bra.s	TstMovem
Ftm:	
	move.w	Y1,d0
	lsr.w	#1,d0
	move.w	d0,Y1
	subq.w	#2,Ray
	bne.s	Les_13

Retour:	bra	OKAY

Fin_Genere:
	; LEA Y(A5),A5
	move.w	#$4BED,(gen)+
	move.w	#LARGIMAGE*2,d0
	sub.w	reajuste,d0
	move.w	d0,(gen)+

 	; LEA X(A6),A6
	move.w	#Xrsl,d0
	sub.w	Largeur_Ligne,d0
	move.w	#$4DEE,(gen)+
	move.w	d0,(gen)+
	
	; RTS
	move.w	#$4E75,(gen)+
	
***************************************************************************

;----- LIGNE SUIVANTE -----------------------------------------------------

	addq.w	#2,Largeur_Ligne
	cmpi.w	#204,Largeur_Ligne
	bne	For_LargLigne

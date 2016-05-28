
;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* CHAINES DE CARACTERES
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

******************************************************************
*	MENAGE ALPHANUMERIQUE
Menage	movem.l d1-d7/a2-a6,-(sp)

******* Essaie de proceder à un FAST-MENAGE!
	move.l	HiChaine(a5),d7
	move.l	LoChaine(a5),d6
	move.l	d7,d0
	sub.l	d6,d0
	cmp.l	#$FFFFE,d0
	bcc	SLOW_MENAGE
	move.l	d0,d5
	Bsr	RamFast2
	tst.l	d0
	beq	SLOW_MENAGE

*********************************************************************
FAST_MENAGE
	move.l	d0,a4
	move.l	d0,a2
	clr.w	(a2)+
FfMen0  	move.l 	VarLoc(a5),a6			;Debut des variables
        moveq 	#-1,d2                    	;Maxi dans le tableau
        moveq 	#0,d4                     	;Cpt tableau---> 0
; Rempli la table intermediaire
FfMen1: move.l	a6,a3
	addq.l	#4,a6
	move.w	(a6)+,d0
	bpl.s	FfMen1a
	move.l	(a3),d0
	beq	FfMenX
	move.l	d0,a6
	bra.s	FfMen1
FfMen1a btst	#1,d0
	beq.s	FfMen1
; Variable alphanumerique
	tst.l	(a3)				* Pas initialise!
	beq.s	FfMen1
	btst 	#6,d0
	beq.s 	FfMen4
	move.l	(a3),a3
	move.w	(a3)+,d0
	subq.w 	#1,d0
	moveq 	#1,d4
FfMen2:	move.w 	(a3)+,d1			;Calcule nombre de variable
	addq.l	#2,a3
	addq.w	#1,d1
	mulu	d1,d4
	dbra 	d0,FfMen2
FfMen3:	subq.l 	#1,d4
; Recopie la chaine dans le buffer intermediaire
FfMen4	move.l	(a3),a0
	cmp.l	d6,a0			; Dans le buffer?
	bcs.s	FfMenN
	cmp.l	d7,a0
	bcc.s	FfMenN
	move.w	(a0),d0			; Chaine vide?
	beq.s	FfMenV
	move.w	d0,d1
	and.w	#$FFF0,d1
	cmp.w	#$FFF0,d1
	beq.s	FfMenD			; Deja fait
	move.l	a2,d2
	sub.l	a4,d2
	move.l	d2,(a3)			; Change le pointeur
	add.l	d6,(a3)
	move.w	d0,(a2)+
	addq.w	#1,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	lea	2(a0),a1
FfMen5	move.w	(a1)+,(a2)+
	dbra	d0,FfMen5
	or.l	#$FFF00000,d2
	move.l	d2,(a0)			; Marque la chaine...
	bra.s	FfMenN
; Chaine deja copiee
FfMenD	move.l	(a0),d0
	and.l	#$000FFFFF,d0
	add.l	d6,d0
	move.l	d0,(a3)
	bra.s	FfMenN
; Chaine vide
FfMenV	move.l	ChVide(a5),(a3)
; Prend la chaine suivante	
FfMenN	addq.l	#4,a3
	tst.l 	d4
        bne 	FfMen3
        beq 	FfMen1
; Recopie le tout dans le buffer
FfMenX	move.l	a4,a0
	move.l	d6,a1
FfMenX1	move.w	(a0)+,(a1)+
	cmp.l	a2,a0
	bcs.s	FfMenX1
	move.l	a1,HiChaine(a5)
; Libere le buffer temporaire
	move.l	a4,a1
	move.l	d5,d0
	Bsr	RamFree
	bra	FinMenS
*********************************************************************
SLOW_MENAGE
* Reserve la memoire, ou prend le BUFFER si rien du tout!!!
	move.l	#TMenage+16,d0
	bsr	RamFast2
	bne.s	L47a
	move.l	#-1,BMenage(a5)
	move.l	Buffer(a5),d5
	bra.s	L47b
L47a	move.l	d0,BMenage(a5)
	move.l	d0,d5
* Menage
L47b   	move.l 	d5,d6	
	add.l 	#TMenage,d6                  	;Fin TI
	move.l 	LoChaine(a5),d7               	;Ad mini de recopie
	move.l	HiChaine(a5),a4			;Ad maxi des chaines!
	addq.l 	#2,d7		  		;Chaine vide
	move.l 	d7,a1		  		;Si ya pas de variable!

Men0:  	move.l 	VarLoc(a5),a6			;Debut des variables
        moveq 	#-1,d2                    	;Maxi dans le tableau
        moveq 	#0,d4                     	;Cpt tableau---> 0
        move.l 	d5,d3                    	;Rien dans la TI
        move.l 	d3,a0
        move.l 	#$7fffffff,(a0)
; Rempli la table intermediaire
Men1:  	move.l	a6,a3
	addq.l	#4,a6
	move.w	(a6)+,d0
	bpl.s	Men1a
	move.l	(a3),d0
	beq	Men20
	move.l	d0,a6
	bra.s	Men1
Men1a:	btst	#1,d0
	beq.s	Men1
; Variable alphanumerique
	tst.l	(a3)				* Pas initialise!
	beq.s	Men1
	btst 	#6,d0
	beq.s 	Men4
	move.l	(a3),a3
	move.w	(a3)+,d0
	subq.w 	#1,d0
	moveq 	#1,d4
Men2:	move.w 	(a3)+,d1			;Calcule nombre de variable
	addq.l	#2,a3
	addq.w	#1,d1
	mulu	d1,d4
	dbra 	d0,Men2
Men3:	subq.l 	#1,d4
; Essai de poker dans la TI
Men4:   move.l 	(a3),d0
        cmp.l 	d7,d0                     	;< au minimum?
        bcs.s 	Men10
	cmp.l	a4,d0				;Dans le source?
	bcc.s	Men10
        cmp.l 	d2,d0                     	;>= au maximum?
        bcc.s 	Men10
        move.l 	d5,a0
Men6:   cmp.l 	(a0),d0
        lea 	8(a0),a0
        bcc.s 	Men6
        cmp.l 	d6,a0
        bne.s 	Men7
        move.l 	d0,d2                    	;C'est le dernier element!
        move.l 	d6,d3
        bra.s 	Men9
Men7:   move.l 	d3,a1                    	;Decale les adresses au dessus
        cmp.l 	d6,d3
        bcs.s 	Men7a
        lea 	-8(a1),a1
        move.l 	-8(a1),d2                	;Remonte la limite haute
        bra.s 	Men8 
Men7a:  addq.l 	#8,d3
        move.l 	#$7fffffff,8(a1)
Men8:   move.l 	-(a1),8(a1)
        move.l 	-(a1),8(a1)
        cmp.l 	a0,a1
        bcc.s 	Men8
Men9:   move.l 	a3,-(a0)                 	;Poke dans la table
        move.l 	d0,-(a0) 
Men10:  addq.l	#4,a3
	tst.l 	d4
        bne.s 	Men3
        beq 	Men1

; Recopie toutes les chaines du buffer
Men20:  move.l 	d5,a3                    	;Adresse TI
        move.l 	d7,a1                    	;Adresse de recopie
        moveq 	#0,d7
Men21:  cmp.l 	d3,a3                     	;Fini-ni?
        bcc.s 	Men26 
        move.l 	(a3),a0                  	;Adresse de la chaine
        lea 	8(a3),a3
        cmp.l 	a0,d7                    	;Chaine deja bougee?
        beq.s 	Men25
        move.l 	a0,d7
        cmp.l 	a0,a1                     	;Au meme endroit?
        bne.s 	Men22
; Les 2 chaines sont au meme endroit!
        move.l 	a1,d1
	moveq 	#0,d0
        move.w 	(a1)+,d0
	add.l 	d0,a1
        move.w 	a1,d0
        btst 	#0,d0
        beq.s 	Men21
        addq.l 	#1,a1
        bra.s 	Men21
; Recopie la chaine
Men22:  move.l 	-4(a3),a2                	;Change la variable
        move.l 	a1,(a2)
        move.l 	a1,d1
        move.w 	(a0)+,d0                 	;Recopie la chaine
        beq.s 	Men24
        move.w 	d0,(a1)+
        subq.w 	#1,d0 
        lsr.w 	#1,d0
Men23:  move.w 	(a0)+,(a1)+
        dbra 	d0,Men23
        bra.s 	Men21
; Chaine vide au milieu: pointe la vraie
Men24:  move.l 	ChVide(a5),d1
        move.l 	d1,(a2)
        bra.s 	Men21
; La variable pointait la meme chaine que la precedente
Men25:  move.l 	-4(a3),a2
        move.l 	d1,(a2)
        bra.s 	Men21
; Est-ce completement fini?
Men26:  cmp.l 	d6,d3                     	;Buffer TI rempli?
        bcs.s 	FinMen                    	;NON---> c'est fini!

;-----> Reexplore les variables a la recherche de la DERNIERE CHAINE
        move.l 	VarLoc(a5),a6             	;Table des ad strings
        moveq 	#0,d4                     	;Cpt tableau---> 0
	move.l 	d1,d2		  		;Feneant!
; Rempli la table intermediaire
Men31:  move.l	a6,a3
	addq.l	#4,a6
	move.w	(a6)+,d0
	bpl.s	Men31a
	move.l	(a3),d0
	beq	Men40
	move.l	d0,a6
	bra.s	Men31
Men31a:	btst	#1,d0
	beq.s	Men31
; Variable alphanumerique
	tst.l	(a3)
	beq.s	Men31
	btst 	#6,d0
	beq.s 	Men34
	move.l	(a3),a3
	move.w	(a3)+,d0
	subq.w 	#1,d0
	moveq 	#1,d4
Men32:	move.w 	(a3)+,d1			;Calcule nombre de variable
	addq.l	#2,a3
	addq.w	#1,d1
	mulu	d1,d4
	dbra 	d0,Men32
Men33:	subq.l 	#1,d4
; La variable pointe elle la meme chaine?
Men34:  cmp.l 	(a3)+,d7
        beq.s 	Men36
        tst.l 	d4
        bne.s 	Men33
        beq.s 	Men31
Men36:  move.l 	d2,-4(a3)
        tst.l 	d4
        bne.s 	Men33
        beq.s 	Men31

;-----> Refait un tour!
Men40:  move.l 	a1,d7    	                ;Monte la limite <
        bra 	Men0
;-----> Menage fini!
FinMen	move.l 	a1,hichaine(a5)
; Libere la mémoire
	move.l	Bmenage(a5),d0
	bmi.s	Finm1
	move.l	d0,a1
	move.l	#TMenage+16,d0
	bsr	RamFree
Finm1   clr.l	Bmenage(a5)

;-----> FIN DES DEUX MENAGES : ca marche maintenant?
FinMenS movem.l (sp)+,d1-d7/a2-a6
	move.l	HiChaine(a5),a1
	add.l	d3,a1
	addq.l	#4,a1
	cmp.l	TabBas(a5),a1
	bcc.s	FinMenE
	rts
FinMenE	move.l	a4,d0
	bgt.s	FinMenF
	move.l	MenA4(a5),a4
FinMenF	moveq	#11,d0
	bra	RunErr

*******************************************************************
* 	DEMANDE une certaine place pour le traitement des chaines
demande:move.l 	HiChaine(a5),a0 
        move.l 	a0,a1
	add.l	d3,a1
	addq.l	#4,a1
	cmp.l	TabBas(a5),a1
	bcc.s	Dem1
	move.l	a0,a1
        rts
* Va faire le menage, si revient: OK!
dem1:	bsr 	menage 
* Si A4=0, un menage vient d'etre fait!!!
	cmp.w	#1,RunAct(a5)
	beq.s	dem3
	move.l	a4,d0
	beq	FinMenE
	bmi.s	dem2
	move.l	PLoop(a5),a3
	move.l	BasSp(a5),sp
        lea	-2(a4),a6
	move.l	a4,MenA4(a5)
	sub.l	a4,a4
	move.w	(a6)+,d0
	bra	InsMen
* Rebranche!
dem2	sub.l	a4,a4
	bra.s	demande
* Si TUTOR
dem3	jmp	TtMenage

*******************************************************************
*	Demande une chaine SANS erreur...
DDemande
	move.l	a4,MenA4(a5)
	sub.l	a4,a4
	subq.l	#1,a4
	bsr	Demande
	move.l	MenA4(a5),a4
	rts

*******************************************************************
*	=FREE ---> Taille pour les chaines + variables
FnFree:	moveq	#-100,d3
	bsr	Menage
	move.l	TabBas(a5),d3
	sub.l	HiChaine(a5),d3
	moveq	#0,d2
	bra	OpeRet

*******************************************************************
*	= INKEY$
FnInky:
************************
	SyCall	Inkey
	tst.l	d1
	beq	RVide
	move.w	d1,d2
	swap	d1
	move.w	d1,SScan(a5)
	moveq	#2,d3
	bsr	Demande
	move.w	#1,(a0)+
	move.b	d2,(a0)+
	addq.l	#1,a0
	move.l	a0,HiChaine(a5)
	move.l	a1,d3
	moveq	#2,d2
	bra	OpeRet
*******************************************************************
*	=SCANCODE
FnScan:
************************
	moveq	#0,d3
	move.b	SScan+1(a5),d3
	clr.b	SScan+1(a5)
	moveq	#0,d2
	bra	OpeRet
*******************************************************************
*	=JOY(n) et assimiles
FnJoy:
************************
	bsr	FnExpE
	cmp.l	#1,d3
	bhi	FonCall
	move.l	d3,d1
	SyCall	Joy
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet
FJ:	bsr	FnExpE
	cmp.l	#1,d3
	bhi	FonCall
	move.l	d3,d1
	SyCall	Joy
	rts

******* FIRE
FFire:	bsr	FJ
	btst	#4,d1
	beq.s	JF
* Vrai!
JT:
FTrue:	moveq	#-1,d3
	moveq	#0,d2
	bra	OpeRet
* Faux!
JF:
FFalse:	moveq	#0,d3
	moveq	#0,d2
	bra	OpeRet

******* Routine
SsGtKy:	movem.l	d0-d2/a0-a2,-(sp)
	SyCall	GetFunK
	moveq	#0,d3
SGk0:	clr.b	(a2)
	move.b	(a0)+,d0
	beq.s	SGkX
	cmp.b	#13,d0			* RETURN
	beq.s	SGk2
	cmp.b	#"'",d0			* REM
	beq.s	SGk0
	cmp.b	#1,d0			* SCAN CODE
	beq.s	SGk4
	cmp.b	#32,d0
	bcc.s	SGk1
	moveq	#".",d0
SGk1:	move.b	d0,(a2)+
	addq.w	#1,d3
	bra.s	SGk0
SGk2:	move.b	#"`",d0
	cmp.b	#10,(a0)+
	beq.s	SGk1
	subq.l	#1,a1
	bra.s	SGk1
SGk4:	addq.l	#3,a1
	bra.s	SGk0
SGkX:	movem.l	(sp)+,d0-d2/a0-a2
	rts

*******************************************************************
*	WAIT KEY
WtKy:
************************
	bsr	Tests
	SyCall	Inkey
	IFEQ	Finale
	btst	#6,CIAAPRA
	bne.s	.skip
	illegal
.skip	
	ENDC
	tst.l	d1
	beq.s	WtKy
	bra	InsRet

****************************************************************************
*       FONCTION LEFT$(a$,xx)
FnLft:
***********************
	bsr FnPar2
        move.l (a3)+,d6
        move.l (a3)+,a2
        moveq #0,d2
        move.w (a2)+,d2
        moveq #0,d5
	bra L76

****************************************************************************
*       FONCTION RIGHT$(a$,yy)
FnRgt:
***********************
	bsr FnPar2
        move.l (a3)+,d5
        bmi FonCall
        move.l (a3)+,a2
        moveq #0,d2
        move.w (a2)+,d2
        move.l #$ffff,d6
        cmp.l d2,d5
        bcs L73c
        move.l d2,d5
L73c:   neg.l d5
        add.l d2,d5
        addq.l #1,d5
	bra L76

****************************************************************************
*       FONCTION MID$(a$,xx)
FnMid2:
***********************
	bsr FnPar2
        move.l (a3)+,d5
        move.l (a3)+,a2
        moveq #0,d2
        move.w (a2)+,d2
        move.l #$FFFF,d6
	bra L76

****************************************************************************
*       FONCTION MID$(a$,xx,yy)
FnMid3:
**********************
	moveq	#3,d0
	bsr FnParD0
        move.l (a3)+,d6
        move.l (a3)+,d5
        move.l (a3)+,a2
        moveq #0,d2
        move.w (a2)+,d2

****************************************************************************
*       ROUTINE COMMUNE LEFT/RIGHT/MID
L76:
***********************
        tst.l d5                        ;pointe au milieu de la chaine
        bmi FonCall
        beq.s mi2
        subq.l #1,d5
mi2:    add.l d5,a2
        cmp.l d2,d5                     ;pas pointe trop loin??
        bcc.s RVide                     ;si! chaine vide
mi3:    tst.l d6
        beq.s RVide
        bmi Foncall
mi4:    add.l d5,d6
        cmp.l d2,d6
        bls.s mi5
        move.l d2,d6
mi5:    sub.l d5,d6
mi6:    move.l d6,d3
	bsr demande
        move d6,(a0)+                   ;poke la longueur
        subq.l #1,d6
        bmi.s mi8
mi7:    move.b (a2)+,(a0)+
        dbra d6,mi7
        move a0,d0                      ;rend pair
        btst #0,d0
        beq.s mi8
        addq.l #1,a0
mi8:    move.l a0,hichaine(a5)
        move.l a1,d3
	moveq #2,d2
        bra OpeRet
RVide:  move.l ChVide(a5),d3          ;ramene la chaine vide
	moveq #2,d2
	bra OpeRet

****************************************************************************
*       ROUTINE COMMUNE LEFT/RIGHT/MID$ en INSTRUCTIONS
L77: 
***********************
	addq.w #2,a6		Saute la parenthese
	bsr FindVar
        move.l (a0),a2
        moveq #0,d2
        move.w (a2)+,d2
	beq.s L77c
        cmp.l LoChaine(a5),a2   ;La chaine est-elle une constante?
        bcs.s L77a
	cmp.l HiChaine(a5),a2
	bcs.s L77c
L77a:   move.l a0,-(sp)         ;Sauve l'adresse de la variable
	move.l d2,d3
	bsr demande             ;Recopie la chaine dans le source
        move.w d2,(a1)+         ;Longueur
	move.w d2,d0
        subq.w #1,d0
        lsr.w #2,d0
L77b:   move.l (a2)+,(a1)+
        dbra d0,L77b
        move.l a1,HiChaine(a5)
	move.l (sp)+,a1
	move.l a0,(a1)		Change la variable
	lea 2(a0),a2
L77c:   rts

****************************************************************************
*       LEFT(a$,xx) en INSTRUCTION
InLft:
********************************
	bsr L77
	movem.l a2/d2,-(sp)
	bsr FnExpE
        move.l d3,d6
        moveq #0,d5
	bra L82

****************************************************************************
*       RIGHT(a$,xx) en INSTRUCTION
InRgt:
********************************
	bsr L77
	movem.l a2/d2,-(sp)
	bsr FnExpE
	move.l d3,d6
        bmi FonCall
	move.l (sp),d2
        moveq #0,d5
        cmp.l d2,d6
        bcc L82
        move.l d2,d5
	sub.l d6,d5
        addq.l #1,d5
	bra L82

****************************************************************************
*       MID$(a$,xx) en INSTRUCTION
InMid2:
********************************
	bsr L77
	movem.l a2/d2,-(sp)
	bsr FnExpE
	move.l d3,d5
*	addq.l #1,d5
        move.l #$FFFF,d6
	bra L82

****************************************************************************
*       MID$(a$,xx,yy) en INSTRUCTION
InMid3:
********************************
	bsr L77
	movem.l a2/d2,-(sp)
	bsr FnPar2
        move.l (a3)+,d6
        move.l (a3)+,d5
*	addq.l #1,d5

****************************************************************************
*       Routine commune LEFT/RIGHT/MID en INSTRUCTION (II)
L82:
***********************
	movem.l d5/d6,-(sp)
	bsr FnExpA
	movem.l (sp)+,d5/d6
	movem.l (sp)+,a1/d1
        tst.l d5
        bmi Foncall
        beq.s mdst2
        subq.l #1,d5
mdst2:  add.l d5,a1             ;situe dans la chaine a changer
        cmp.l d1,d5
        bcc.s mdst10            ;trop loin: ne change rien
        tst.l d6
        bmi Foncall
        beq.s mdst10
        add.l d5,d6
        cmp.l d1,d6
        bls.s mdst3
        move.l d1,d6
mdst3:  sub.l d5,d6
        cmp.l d2,d6             ;limite par la taille de la chaine source
        bls.s mdst4
        move.l d2,d6
mdst4:  subq.l #1,d6            ;la chaine source est nulle!
        bmi.s mdst10
mdst5:  move.b (a2)+,(a1)+
        dbra d6,mdst5
mdst10: bra InsRet

****************************************************************************
*       INSTR(a$,b$)
Instr2:
***********************
	bsr 	FnPar2
        moveq 	#0,d2
        move.l 	(a3)+,a2
        move.w 	(a2)+,d2
        moveq 	#0,d1
        move.l 	(a3)+,a1
        move.w 	(a1)+,d1
        moveq 	#0,d4
	bsr 	InstrFind
	bra 	OpeRet

****************************************************************************
*       INSTR(a$,b$,xx)
Instr3:
***********************	
	moveq	#3,d0
	bsr 	FnParD0
        move.l 	(a3)+,d4
        bmi 	FonCall
        moveq 	#0,d2
        move.l 	(a3)+,a2
        move.w 	(a2)+,d2
        moveq 	#0,d1
        move.l 	(a3)+,a1
        move.w 	(a1)+,d1
	bsr 	InstrFind
	bra 	OpeRet

*       INSTR FIND: trouve une sous chaine dans une chaine a partir de d4
*       routine appelee par - chaine et INSTR
InstrFind:
	move.l	a3,-(sp)
        tst.l 	d2
        beq.s 	instf11
        tst.l 	d4
        beq.s 	instf1
        subq.l 	#1,d4
instf1: add.l 	d4,a1         ;situe dans la chaine
instf3: clr 	d3
instf4: move.l 	a2,a3
        addq 	#1,d4
        cmp 	d1,d4
        bhi.s 	instf11
        cmpm.b 	(a1)+,(a3)+
        bne.s 	instf4
        move.l	a1,a0
        move 	d4,d0
instf5: addq 	#1,d3
        cmp 	d2,d3
        bcc.s 	instf10
        addq 	#1,d0
        cmp 	d1,d0
        bhi.s 	instf11
        cmpm.b 	(a0)+,(a3)+
        beq.s 	instf5
        bra.s 	instf3
instf10:move.l	(sp)+,a3
	moveq	#0,d2
        move.l 	d4,d3                  ;trouve!
        rts
instf11:move.l	(sp)+,a3
	moveq	#0,d2
        moveq 	#0,d3
        rts

****************************************************************************
*       LEN(a$)
Len:
**************
	bsr 	FnExpA
        move.l 	d2,d3
	moveq 	#0,d2
        bra 	OpeRet

****************************************************************************
*       STRING$("a",xx)
String:
***********************
	bsr 	FnPar2
        move.l 	(a3)+,d3
        move.l 	(a3)+,a2
        move.w 	(a2)+,d2
        bne.s 	L88a
        moveq 	#0,d3
        bra.s 	L89
L88a:   move.b 	(a2),d1
        lsl.w 	#8,d1
        move.b 	(a2),d1

****************************************************************************
*       SUITE et FIN de SPACE$ et STRING$
L89:
***********************
        tst.l 	d3
        bmi 	FonCall
	bsr 	Demande
        move.w 	d3,(a0)+
        beq.s 	L89c
        subq.w 	#1,d3
        lsr.w 	#1,d3
L89b:   move.w 	d1,(a0)+
        dbra 	d3,L89b
L89c:   move.l 	a0,hichaine(a5)
	move.l 	a1,d3
	moveq 	#2,d2
        bra 	OpeRet

****************************************************************************
*       CHR$(xx)
Chr:
***********************
	bsr 	FnExpE
	move.l 	d3,d2
FinChr: cmp.l 	#$100,d2
        bcc 	FonCall
        moveq 	#2,d3
	bsr 	Demande
        move.w 	#1,(a0)+
        move.b 	d2,(a0)
	addq.w	#2,a0
        move.l 	a0,hichaine(a5)
	move.l 	a1,d3
	moveq 	#2,d2
        bra 	OpeRet

****************************************************************************
*	AT(X,Y)
FnAt:	
**************
	bsr	FnPar2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d1
	move.l	(a3)+,d2
	cmp.l	#EntNul,d2
	beq.s	FnAt1
	cmp.l	#255-48,d2
	bhi	FonCall
	move.w	d2,d1
	moveq	#3,d3
	bset	#1,d4
FnAt1:	moveq	#0,d0
	move.l	(a3)+,d2
	cmp.l	#EntNul,d2
	beq.s	FnAt2
	cmp.l	#255-48,d2
	bhi	FonCall
	move.w	d2,d0
	addq.l	#3,d3
	bset	#0,d4
FnAt2:	tst.w	d4
	beq	RVide
	bsr	Demande
	move.w	d3,(a0)+
	btst	#0,d4
	beq.s	FnAt3
	add.w	#"0",d0
	move.b	#27,(a0)+
	move.b	#"X",(a0)+
	move.b	d0,(a0)+
FnAt3:	btst	#1,d4
	beq.s	FnAt4
	add.w	#"0",d1
	move.b	#27,(a0)+
	move.b	#"Y",(a0)+
	move.b	d1,(a0)+
FnAt4:	bra	FinBin
****************************************************************************
*       ZONE$
FnZon:
**************
	bsr	FnPar2
	move.l	(a3)+,d3
	beq	JWFonc
	cmp.l	#255-48,d3
	bcc	JWFonc
	lea	ChZon,a0
FinRpt:	add.b	#"0",d3
	move.b	d3,6(a0)
	move.l	(a3)+,a2
	moveq	#0,d2
	move.w	(a2)+,d2
	move.l	a3,-(sp)
	move.l	a0,a3
	move.l	d2,d3
	addq.l	#6,d3
	bsr	Demande
	move.w	d3,(a0)+
FnR1:	move.b	(a3)+,(a0)+
	bne.s	FnR1
	tst.b	-(a0)
	subq.w	#1,d2
	bmi.s	FnR3
FnR2:	move.b	(a2)+,(a0)+
	dbra	d2,FnR2
FnR3:	move.b	(a3)+,(a0)+
	bne.s	FnR3
	tst.b	-(a0)
	move.l	(sp)+,a3
	bra	FinBin
JWFonc	jmp	WFoncall
ChRpt:	dc.b 	27,"R0",0,27,"R0",0
ChZon:	dc.b 	27,"Z0",0,27,"Z0",0
ChSur:	dc.b 	27,"E0",0,27,"E0",0

****************************************************************************
*     	UPPER$(a$)
FnUpp:
**************
	bsr 	FnExpA
        move.l 	d2,d3
        beq 	RVide
        bsr 	demande         ;meme taille de chaine
        move.w 	d3,(a0)+
        subq 	#1,d3
fnup1:  move.b 	(a2)+,d0
        cmp.b 	#"A",d0
        bcs.s 	fnup2
        cmp.b 	#"Z",d0
        bhi.s 	fnup2
        add.b 	#$20,d0
fnup2:  move.b 	d0,(a0)+
        dbra 	d3,fnup1
        bra 	FinBin

****************************************************************************
*     	LOWER$(a$)
FnLwr:
**************
	bsr 	FnExpA
        move.l 	d2,d3
        beq 	RVide
        bsr 	demande
        move.w 	d3,(a0)+
        subq 	#1,d3
fnlw1:  move.b 	(a2)+,d0
        cmp.b 	#"a",d0
        bcs.s 	fnlw2
        cmp.b 	#"z",d0
        bhi.s	fnlw2
        sub.b 	#$20,d0
fnlw2:  move.b 	d0,(a0)+
        dbra 	d3,fnlw1
        bra 	FinBin

****************************************************************************
*       ASC(a$)
Asc:	
**************
	bsr 	FnEval
	move.l 	d3,a2
        moveq 	#0,d3
        move.w 	(a2)+,d0
        beq.s 	L91a
        move.b 	(a2),d3
L91a:   moveq 	#0,d2
        bra 	OpeRet

****************************************************************************
*       BIN$(xx)
Bin1:	
***************************
        bsr 	FnExpE
	move.l 	d3,d1
        moveq 	#-1,d2
        moveq 	#33,d3
	bra L96

****************************************************************************
*       BIN$(xx,yy)
Bin2:
***********************
	bsr 	FnPar2    
    	move.l 	(a3)+,d2
        move.l 	(a3)+,d1
        moveq 	#33,d3
	bra 	L96

****************************************************************************
*       HEX$(xx)
Hex1:
***********************
	bsr 	FnExpE
        move.l 	d3,d1
        moveq 	#-1,d2
        moveq 	#9,d3
	bra 	L96

****************************************************************************
*       HEX$(xx,yy)
Hex2:
***********************
	bsr 	FnPar2
        move.l 	(a3)+,d2
        move.l 	(a3)+,d1
        moveq 	#9,d3

****************************************************************************
*       ROUTINE pour BIN et HEX
L96: 
***************************************
	bsr 	demande
	addq.l	#2,a0
        move.l 	d1,d0
        exg 	d2,d3
        cmp 	#9,d2
        bne.s 	hx3
	jsr 	LongAscii
        bra.s 	FinBin
hx3:    jsr 	LongBin

****************************************************************************
*       FINBIN: ROUTINE de fin de HEX/BIN/STR$
FinBin:
**************
        move.l 	a0,d0        ;rend pair
        btst 	#0,d0
        beq.s 	hx5
        addq.l 	#1,d0
hx5:    move.l 	d0,hichaine(a5)
        sub.l 	a1,a0
        subq.l 	#2,a0
        move 	a0,(a1)        ;poke la longueur
        move.l	a1,d3		;Ramene la chaine
	moveq 	#2,d2
        bra 	OpeRet

****************************************************************************
*       STR$
Str:
**************
        bsr 	FnEval
        movem.l d2-d4,-(sp)
        moveq 	#40,d3
        bsr 	demande    
	lea	2(a0),a0
        movem.l (sp)+,d2-d4
	tst.b	d2
	beq.s	Str1
        jsr 	strflasc
        bra 	FinBin
Str1:   move.l 	d3,d2
        moveq	#16,d3
        bsr 	demande
        lea 	2(a0),a0
        move.l 	d2,d0
        jsr 	longdec1        ;fait la conversion
        bra 	FinBin

****************************************************************************
*      	VAL(A$)
Val:
**************	
      	bsr 	FnExpA
	beq.s	Val11
        bsr 	chverbuf        ;recopie la chaine dans le buffer
        move.l	buffer(a5),a0
        jsr 	valprg
	bra	OpeRet
val11: 	clr.b 	d2
        moveq	#0,d3
        bra	OpeRet


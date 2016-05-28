
***********************************************************
*	EVALUATION D'EXPRESSION
***********************************************************

*******	EVALUATION
FnEval:	addq.l	#2,a6		Saute la parenthese fonction!
Evalue:	move.w	#$7FFF,d0
	bra.s	Eva1
Eva0:	move.l	d3,-(sp)
	move.w	d2,-(sp)
Eva1:	move.w	d0,-(sp)
	bsr	Operande
EvaRet:	move.w	(a6)+,d0
	cmp.w	(sp),d0
	bhi.s	Eva0
	subq.l	#2,a6
	move.w	(sp)+,d1
	bpl.s	Eva3
	move.w	(sp)+,d5
	move.l	(sp)+,d6
	lea	Tk(pc),a0
	move.w	0(a0,d1.w),d1
	jmp	0(a0,d1.w)
Eva3:	cmp.w	#TkPar2-Tk,d0
	bne.s	Eva4
	move.w	(a6)+,d0
Eva4:	rts

******* OPERANDE
Operande:
	clr.w	-(sp)
Ope0:	move.w	(a6)+,d0
	lea	Tk(pc),a0
	move.w	2(a0,d0.w),d0
	jmp	0(a0,d0.w)
* Changement de signe?
OpeRet:	tst.w	(sp)+
	bne.s	Chs0
	rts
Chs0:	tst.w	d2
	bne.s	Chs1
	neg.l	d3
	rts	
Chs1:	move.l	d3,d0
	move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	jsr	SPNeg(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#1,d2
	rts
* Signe moins devant
OpeM:	addq.w	#1,(sp)
	bra.s	Ope0
* Debut de parenthese?
OpeP:	bsr	Evalue
	bra.s	OpeRet

EvaRien:bra	EvaRet
OpeRien:bra	OpeRet	

******* VIRGULE / : / TO / THEN / ELSE ---> pas de parmetre, entier
Null:	move.l	#EntNul,d3
	clr.b	d2
	subq.l	#2,a6
	bra	OpeRet

***********************************************************
*	PREND UNE VARIABLE
***********************************************************
FnVar:	move.l	VarLoc(a5),a0
	move.w	(a6)+,d0
	bpl.s	FnV0
	move.l	VarGlo(a5),a0
	addq.w	#1,d0
	neg.w	d0
FnV0:	move.b	(a6)+,d1
	move.b	(a6)+,d2
	ext.w	d1
	add.w	d1,a6
	add.w	d0,a0
	btst	#6,d2
	beq.s	FnV1		* Tableau
	bsr	GetTablo
FnV1:	and.w	#$F,d2
	cmp.b	#2,d2
	beq.s	FnVC
* Ramene la valeur ENTIERE / FLOAT
	move.l	(a0),d3
	bra	OpeRet
* Ramene la valeur CHAINE
FnVC:	move.l	(a0),d3
	bne	OpeRet
	move.l	ChVide(a5),d3
	move.l	d3,(a0)
	bra	OpeRet

***********************************************************
*	LABEL / EGALISATION D'UNE VARIABLE
***********************************************************
InVar:	move.l	VarLoc(a5),a0
	move.w	(a6)+,d0
	bpl.s	InVal
	move.l	VarGlo(a5),a0
	addq.w	#1,d0
	neg.w	d0
InVal:	move.b	(a6)+,d1
	ext.w	d1
	moveq	#0,d2
	move.b	(a6)+,d2
	add.w	d1,a6
	add.w	d0,a0
	move.w	d2,4(a0)	* Poke le flag
	btst	#6,d2		* Si tableau, pointe l'intirieur
	beq.s	InVar0
	bsr	GetTablo
InVar0:	move.l	a0,-(sp)
	and.w	#$000F,d2
	move.w	d2,-(sp)
	addq.l	#2,a6		* Saute le EGAL
	bsr	Evalue		* Va evaluer
	cmp.w	(sp)+,d2
	beq.s	InVar2
	tst.b	d2
	bne.s	InVar1
	bsr	IntToFl
	bra.s	InVar2
InVar1:	bsr	FlToInt
InVar2:	move.l	(sp)+,a0
	move.l	d3,(a0)
* Securite MENAGE
	bra	InsRet

******* Saute un label
InLab:	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	bra	InsRet

******* Trouve l'adresse d'une variable
FindVar:addq.l	#2,a6
	move.l	VarLoc(a5),a0
	move.w	(a6)+,d0
	bpl.s	FdV2
	move.l	VarGlo(a5),a0
	addq.w	#1,d0
	neg.w	d0
FdV2:	move.b	(a6)+,d1
	ext.w	d1
	moveq	#0,d2
	move.b	(a6)+,d2
	add.w	d1,a6
	add.w	d0,a0
	move.w	d2,4(a0)
	btst	#6,d2
	beq.s	FdV0
	bsr	GetTablo
FdV0:	and.w	#$F,d2	
	cmp.b	#2,d2
	bne.s	FdV1
	tst.l	(a0)
	bne.s	FdV1
	move.l	ChVide(a5),(a0)
FdV1:	rts

******* SHARED
Shared:	jsr	RouSha
	bra	InsRet

******* DEF FN
IDFn	bsr	FindVar
	move.l	a6,(a0)
	lea	-4(a4),a6
	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	add.w	d0,a6	
	bra	ChrGet
******* =FN
FFn	bsr	FindVar
	move.l	(a0),d0
	beq	FnNDef
	move.l	d0,a2
* Egalise les params
	move.w	(a6)+,d0
	cmp.w	#TkPar1-Tk,d0
	bne.s	FFn5
FFn1	cmp.w	(a2)+,d0
	bne.s	FnIlNb
	move.l	a2,-(sp)
	bsr	Evalue
	movem.l	d2/d3/a6,-(sp)
	move.l	3*4(sp),a6
	bsr	FindVar
	move.w	d2,d1
	move.l	a6,a2
	movem.l	(sp)+,d2/d3/a6
	addq.l	#4,sp
	cmp.b	d1,d2
	beq.s	FFn3
	subq.b	#1,d1
	bmi.s	FFn2
	bne	TypeMis
	bsr	IntToFl
	bra.s	FFn3
FFn2	subq.b	#1,d2
	bhi	TypeMis
	bsr	FlToInt
FFn3	move.l	d3,(a0)
	move.w	(a6)+,d0
	cmp.w	#TkVir-Tk,d0
	beq.s	FFn1
	subq.l	#2,a6
	cmp.w	#TkPar2-Tk,(a2)+
	bne.s	FnIlNb
FFn5	cmp.w	#TkEg-Tk,(a2)+
	bne.s	FnIlNb
* Appelle la fonction
	movem.l	a3-a6,-(sp)
	move.l	a2,a6
	bsr	Evalue
	movem.l	(sp)+,a3-a6
	bra	OpeRet
FnIlNb	moveq	#16,d0
	bra	RunErr
FnNDef	moveq	#15,d0
	bra	RunErr 

***********************************************************
*	TABLEAUX DE VARIABLES
***********************************************************

******* DIM
Dim:	addq.l	#2,a6
	move.l	VarLoc(a5),a0
	move.w	(a6)+,d0
	bpl.s	Dim0
	move.w	VarGlo(a5),a0
	addq.w	#1,d0
	neg.w	d0
Dim0:	move.b	(a6)+,d1
	moveq	#0,d2
	move.b	(a6)+,d2
	ext.w	d1
	add.w	d1,a6
	add.w	d0,a0
	tst.l	(a0)		Allready dimensionned
	bne	AlrDim
	move.w	d2,4(a0)
	and.w	#$F,d2
	move.w	d2,-(sp)
	move.l	a0,-(sp)
* Recupere et compte les params
	clr.w	-(sp)
	move.w	#1,-(sp)
Dim1:	bsr	FnEval
	tst.b	d2
	beq.s	Dim2
	move.w	d0,-(sp)
	bsr	FlToInt
	move.w	(sp)+,d0
Dim2:	cmp.l	#$FFFF,d3
	bcc	FonCall
	move.w	d3,-(a3)
	addq.w	#1,d3
	addq.w	#1,2(sp)
	mulu	(sp),d3
	cmp.w	#TkPar2-Tk,d0
	beq.s	Dim3
	cmp.l	#$10000,d3
	bcc	FonCall
	move.w	d3,(sp)
	cmp.w	#TkVir-Tk,(a6)
	beq.s	Dim1
	bra	Synt
Dim3:	lsl.l	#2,d3
	move.l	TabBas(a5),a0		Descend le bas tableaux
	move.l	a0,a2
	sub.l	d3,a0
	addq.l	#2,sp
	move.w	(sp)+,d2		Nb de dimensions
	move.w	d2,d0
	lsl.w	#2,d0
	addq.l	#2,d0
	sub.w	d0,a0
	cmp.l	HiChaine(a5),a0
	bcc	DimM1
	movem.l	a0/a1/d3,-(sp)
	moveq	#0,d3
	bsr	Menage
	movem.l	(sp)+,a0/a1/d3
	cmp.l	HiChaine(a5),a0
	bcs	OOfMem
DimM1	move.l	(sp)+,a1		Stocke l'adresse du tableau
	move.l	a0,(a1)
	move.l	a0,TabBas(a5)
	move.w	d2,(a0)			Stocke le nb de dim
	lea	0(a0,d0.w),a0
	move.l	a0,a1
	moveq	#1,d1
	subq.w	#1,d2
Dim4:	move.w	d1,-(a0)		Stocke taille et multiplicateur
	move.w	(a3)+,d0
	move.w	d0,-(a0)
	addq.w	#1,d0
	mulu	d0,d1
	dbra	d2,Dim4
* Nettoie le tableau
	moveq	#0,d0
	cmp.w	#2,(sp)+
	bne.s	Dim5
	move.l	ChVide(a5),d0
Dim5:	move.l	d0,(a1)+
	cmp.l	a2,a1
	bcs.s	Dim5
* Une autre variable
	cmp.w	#TkVir-Tk,(a6)+
	beq	Dim
* Fin du dim!
	subq.l	#2,a6
	bra	InsRet
	
******* Trouve un element de tableau
GetTablo:
	movem.l	d2/d3,-(sp)
	move.l	(a0),d0
	beq	NonDim
	move.l	d0,a0
	move.w	(a0)+,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
GetT1:	bsr	FnEval
	subq.w	#1,6(sp)
	beq.s	GetT3
	tst.b	d2
	beq.s	GetT2
	bsr	IntToFL
GetT2:	move.l	2(sp),a0
	moveq	#0,d0
	move.w	(a0)+,d0
	cmp.l	d0,d3
	bhi	FonCall
	mulu	(a0)+,d3
	add.w	d3,(sp)
	move.l	a0,2(sp)
	bra.s	GetT1
GetT3:	tst.b	d2
	beq.s	GetT4
	bsr	FlToInt
GetT4:	moveq	#0,d2
	move.w	(sp)+,d2
	move.l	(sp)+,a0
	addq.l	#2,sp
	moveq	#0,d0
	move.w	(a0)+,d0
	cmp.l	d0,d3
	bhi	FonCall
	add.l	d3,d2
	lsl.l	#2,d2
	lea	2(a0,d2.l),a0
	movem.l	(sp)+,d2/d3
	rts

******* = VARPTR(a)
FnVptr:	addq.l	#2,a6
	bsr	FindVar
	addq.l	#2,a6
	cmp.b	#2,d2
	beq.s	FnVp1
	move.l	a0,d3
	moveq	#0,d2
	bra	OpeRet
FnVp1:	move.l	(a0),d3
	addq.l	#2,d3
	moveq	#0,d2
	bra	OpeRet

***********************************************************
*	Int To Float
***********************************************************
IntToFl:movem.l	a0-a6/d5-d7,-(sp)
	move.l	FloatBase(a5),a6
	move.l	d3,d0
	jsr	SPFlt(a6)
	move.l	d0,d3
	moveq	#1,d2
	movem.l	(sp)+,a0-a6/d5-d7
	rts

***********************************************************
*	Float to Int
***********************************************************
FlToInt:movem.l	a0-a6/d5-d7,-(sp)
	move.l	FloatBase(a5),a6
	move.l	d3,d0
	jsr	SPFix(a6)
	move.l	d0,d3
	moveq	#0,d2
	movem.l	(sp)+,a0-a6/d5-d7
	rts

***********************************************************
*	Recuperation de parametres dans -(a3)
***********************************************************

******* Un entier D3
FnExpE:	addq.l	#2,a6
ExpEntier:
	bsr 	Evalue
	tst.b 	d2
	bne 	FlToInt
	rts

******* Un float D3
FnFloat	addq.l	#2,a6
	bsr	Evalue
	tst.b	d2
	beq	IntToFl
	rts

******* Une chaine A2/A2
FnExpA:	addq.l 	#2,a6
ExpAlpha:
	bsr Evalue
	move.l d3,a2
	moveq #0,d2
	move.w (a2)+,d2
	rts

******* Un entier
FnEnt1:	addq.l	#2,a6
Ent1:	bsr	Evalue
	tst.b	d2
	beq.s	Ent1a
	bsr	FlToInt
Ent1a:	move.l	d3,-(a3)
	rts

******* Deux entiers
FnEnt2:	addq.l	#2,a6	
Ent2:	bsr	Evalue
	tst.b	d2
	beq.s	Ent2a
	bsr	FlToInt
Ent2a:	move.l	d3,-(a3)
	bsr	FnEval
	tst.b	d2
	beq.s	Ent2b
	bsr	FlToInt
Ent2b:	move.l	d3,-(a3)
	rts

******* Deux chaines
FnCha2:	addq.l	#2,a6
Cha2:	bsr Evalue
	move.l d3,-(a3)
	bsr FnEval
	move.l d3,-(a3)
	rts

******* Recupere les params -(a3) / ENTIERS / CHAINE$
FnGetP:	addq.l	#2,a6
GetPar:	bsr	Evalue
	subq.b	#1,d2
	bne.s	GetP1
	bsr	FlToInt
GetP1:	move.l	d3,-(a3)
	move.w	(a6)+,d0
	cmp.w	#TkVir-Tk,d0
	beq.s	GetPar
	cmp.w	#TkTo-Tk,d0
	beq.s	GetPar
	subq.l	#2,a6
	rts

******* Un param -(a3)
FnPar1:	addq.l	#2,a6
Par1:	bsr	Evalue
	subq.b	#1,d2
	bmi.s	Par11
	bne.s	Par11
	bsr	FlToInt
Par11:	move.l	d3,-(a3)
	rts

******* Deux params -(a3)
FnPar2:	addq.l	#2,a6
Par2:	bsr	Evalue
	subq.b	#1,d2
	bmi.s	Par21
	bne.s	Par21
	bsr	FlToInt
Par21:	move.l	d3,-(a3)
	bsr	FnEval
	subq.b	#1,d2
	bmi.s	Par22
	bne.s	Par22
	bsr	FlToInt
Par22:	move.l	d3,-(a3)
	rts

******* D0 params -(a3)
ParD0:	subq.l	#2,a6
FnParD0	move.w	d0,-(sp)
Pard1:	addq.l	#2,a6
	bsr	Evalue
	subq.b	#1,d2
	bmi.s	ParD2
	bne.s	ParD2
	bsr	FlToInt
Pard2:	move.l	d3,-(a3)
	subq.w	#1,(sp)
	bne.s	Pard1
	addq.l	#2,sp
	rts

***********************************************************
*	Prend des constantes
***********************************************************
******* Entieres
CstInt:	moveq	#0,d2
	move.l	(a6)+,d3
	bra	OpeRet
******* Float
CstFl:	moveq	#1,d2
	move.l	(a6)+,d3
	bra	OpeRet
******* Chaine
CstCh:	moveq	#2,d2
	move.l	a6,d3
	move.w	(a6)+,d0
	add.w	d0,a6
	btst	#0,d0
	beq.s	CstC0
	addq.l	#1,a6
CstC0:	tst.w	Direct(a5)
	beq	OpeRet
* Mode direct: recopier la chaine
CstC1:	move.l	d3,a2
	moveq	#0,d3
	move.w	(a2)+,d3
	bsr	Demande
	move.w	d3,(a0)+
	addq.w	#1,d3
	lsr.w	#1,d3
	subq.w	#1,d3
	bmi.s	CstC3
CstC2:	move.w	(a2)+,(a0)+
	dbra	d3,CstC2
CstC3:	move.l	a1,d3
	move.l	a0,HiChaine(a5)
	bra	OpeRet

***********************************************************
*	OPERATEURS
***********************************************************

* Que des floats
QueFloat: 
	tst.b 	d2
	bne.s 	Compat
	bsr 	IntToFl
* COMPATIBILITE ENTRE OPERANDES
Compat:	cmp.b	d2,d5	
	bne.s 	Cpt1
	subq.b 	#1,d5
	rts
Cpt1:	tst.b	d2
	bne.s 	Cpt2  
* Change D2/D3 en float
	bsr	IntToFl
	moveq 	#0,d5
	rts
* Change D5/D6 en float
Cpt2:   exg.l	d3,d6
	bsr	IntToFl
	exg.l	d3,d6
	moveq 	#0,d5
	rts
* Que des entiers
QuEntier: 
	tst.b 	d2
	beq.s 	Quent1
	bsr 	FlToInt
Quent1:	tst.b 	d5
	bne.s 	Cpt2
	rts

; OPERATEUR PLUS
plus:   bsr 	compat
        bmi.s 	plus1
        bne.s 	plus2
* Plus float!
	move.l	a6,-(sp)
	move.l	d3,d1
	move.l	d6,d0
	move.l	FloatBase(a5),a6
	jsr	SPAdd(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#1,d2
	bra 	EvaRet
* Addition entiere
plus1:  add.l 	d6,d3
        bvs 	overflow
        bra	EvaRet
* Addition de chaines
plus2:  move.l 	d3,a2
        move.l	d3,-(sp)
        clr.l 	d3
        move 	(a2),d3        ;taille de la deuxieme chaine
        beq.s 	plus11        ;deuxieme chaine nulle
        move.l 	d6,a2
        clr.l 	d0
        move 	(a2),d0
        beq.s 	plus10          ;premiere chaine nulle
        add.l 	d0,d3
        cmp.l 	#$fff0,d3
        bcc 	stoolong        ;string too long!
        bsr 	demande
        move 	d3,(a0)+       ;poke la taille resultante
        move 	(a2)+,d0
        beq.s 	plus4
        subq 	#1,d0
plus3:  move.b 	(a2)+,(a0)+  ;recopie de la premiere chaine
        dbra 	d0,plus3
plus4:  move.l 	(sp)+,a2
        move 	(a2)+,d0
        beq.s 	plus6
        subq 	#1,d0
plus5:  move.b 	(a2)+,(a0)+
        dbra 	d0,plus5
plus6:  move 	a0,d0          ;rend pair
        btst 	#0,d0
        beq.s 	plus7
        addq.l 	#1,a0
plus7:  move.l 	a0,hichaine(a5)
        move.l 	a1,d3
        bra 	EvaRet
plus10: move.l 	(sp)+,d3     ;premiere chaine nulle: ramene la deuxieme
        bra 	EvaRet
plus11: addq.l 	#4,sp        ;deuxieme chaine nulle: ramene la premiere
        move.l 	d6,d3
        bra	EvaRet

; OPERATEUR MOINS
moins:  bsr compat
        bmi.s ms1
        bne.s ms2
* Moins float
	move.l	a6,-(sp)
	move.l	d3,d1
	move.l	d6,d0
	move.l	FloatBase(a5),a6
	jsr	SPSub(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#1,d2
	bra 	EvaRet
* Moins entier
ms1:    sub.l 	d3,d6          ;soustraction entiere
        bvs 	overflow
        move.l 	d6,d3
        bra 	EvaRet
; Soustction de chaines EXCLUSIF!!!
ms2:    move.l	d3,d4        ;sauve pour plus tard
        move.l 	d6,a2
        clr.l 	d3
        move.w 	(a2)+,d3
        move.l 	d3,d1
        bsr 	demande         ;prend la place une fois pour toute!
        move.w 	d3,(a0)+
        beq.s 	ms4
        addq 	#1,d3
        lsr 	#1,d3
        subq 	#1,d3
ms3:    move.w 	(a2)+,(a0)+  ;recopie la chaine
        dbra 	d3,ms3
ms4:    move.l 	a0,hichaine(a5)
        addq.l 	#2,a1        ;chaine dont auquelle on soustrait en a1/d1
        move.l 	d4,a2
        clr.l 	d2
        move 	(a2)+,d2       ;chaine a soustraire en a2/d2

ms5:    clr.l 	d4
        movem.l d1-d2/a1-a3,-(sp)
        bsr 	instrfind       ;recherche la chaine! XXX
        movem.l (sp)+,d1-d2/a1-a3
        tst.l 	d3
        beq.s 	ms9
        move.l 	a1,a0
        move.l 	a1,d4        ;pour plus tard!
        subq.l 	#1,d3
        move.l 	d3,d5        ;taille du debut a garder
        add.l 	d3,a1         ;pointe ou transferer la fin
        add.l 	d2,d3
        add.l 	d3,a0         ;pointe la fin a recopier
        sub.l 	d3,d1
        add.l 	d1,d5         ;taille finale en memoire
        subq.l 	#1,d1
        bmi.s 	ms7
ms6:    move.b 	(a0)+,(a1)+
        dbra 	d1,ms6
ms7:    move 	a0,d0          ;rend pair
        btst 	#0,d0
        beq.s 	ms8
        addq.l 	#1,a0
ms8:    move.l 	a0,hichaine(a5)
        move.l 	d4,a1
        move.w 	d5,-2(a1)
        move.l 	d5,d1
        bra.s 	ms5
ms9:    moveq 	#2,d2
        move.l 	a1,d3
        subq.l 	#2,d3
        bra 	EvaRet

; OPERATEUR ETOILE
multiplie:
	bsr 	compat
        bmi.s 	milt1
* Multiplie float
	move.l	a6,-(sp)
	move.l	d3,d1
	move.l	d6,d0
	move.l	FloatBase(a5),a6
	jsr	SPMul(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#1,d2
	bra 	EvaRet
* Entier!
milt1:  clr 	d4              ;multiplication signee 32*32 bits
        tst.l 	d3            ;aabb*ccdd
        bpl.s 	mlt1
        neg.l 	d3
        not 	d4
mlt1:   tst.l 	d6            ;tests des signes
        bpl.s 	mlt2
        neg.l 	d6
        not 	d4
* Peut on faire une mult rapide?
mlt2:  	cmp.l 	#$00010000,d3
        bcc.s 	mlt0
        cmp.l 	#$00010000,d6
        bcc.s 	mlt0
        mulu 	d6,d3          ;quand on le peut: multiplication directe!
	tst.w 	d4
	beq 	EvaRet
	neg.l 	d3
	bra 	EvaRet
* Multipcation lente
mlt0:   move 	d6,d1
        mulu 	d3,d1
        bmi 	overflow
        swap 	d6
        move 	d6,d0
        mulu 	d3,d0
        swap 	d0
        bmi 	overflow
        tst 	d0
        bne 	overflow
        add.l 	d0,d1
        bvs 	overflow
        swap 	d3
        move 	d6,d0
        mulu 	d3,d0
        bne 	overflow
        swap 	d6
        move 	d6,d0
        mulu 	d3,d0
        swap 	d0
        bmi 	overflow
        tst 	d0
        bne 	overflow
        add.l 	d0,d1
        bvs 	overflow
        tst 	d4              ;signe du resultat
        beq.s 	mlt3
        neg.l 	d1
mlt3:   move.l 	d1,d3
        bra 	EvaRet

; OPERATEUR DIVISE
divise: bsr 	compat
        bmi.s 	div1
* Divise float
	move.l	a6,-(sp)
	move.l	d3,d1
	move.l	FloatBase(a5),a6
	jsr	SPTst(a6)
	beq	dbyzero
	move.l	d3,d1
	move.l	d6,d0
	jsr	SPDiv(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#1,d2
	bra 	EvaRet
div1:   tst.l 	d3
        beq 	dbyzero         ;division par zero!
        clr 	d7
        tst.l 	d6
        bpl.s 	dva
        not 	d7
        neg.l 	d6
dva:    cmp.l 	#$10000,d3    ;Division rapide ou non?
        bcc.s 	dv0
        tst.l 	d3
        bpl.s 	dvb
        not 	d7
        neg.l 	d3
dvb:    move.l 	d6,d0
        divu 	d3,d0          ;division rapide: 32/16 bits
        bvs.s 	dv0
        moveq 	#0,d3
        move	d0,d3
        bra.s 	dvc
dv0:    tst.l 	d3
        bpl.s 	dv3
        not 	d7
        neg.l 	d3
dv3:    moveq 	#31,d5         ;division lente: 32/32 bits
        moveq 	#-1,d4
        clr.l 	d1
dv2:    lsl.l 	#1,d6
        roxl.l	#1,d1
        cmp.l 	d3,d1
        bcs.s 	dv1
        sub.l 	d3,d1
        lsr 	#1,d4           ;met X a un!
dv1:    roxl.l 	#1,d0
        dbra 	d5,dv2
        move.l 	d0,d3
dvc:    tst 	d7
        beq.s 	dvd
        neg.l 	d3
dvd:    bra 	EvaRet

; OPERATEUR PUISSANCE
puissant: 
	bsr quefloat        	;que des float
	move.l	a6,-(sp)
	move.l	d3,d1
	move.l	d6,d0
	move.l	MathBase(a5),a6
	jsr	SPPow(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#1,d2
	bra 	EvaRet

; OPERATEUR MODULO
modulo: bsr 	quentier	      ;Que des entiers!
	tst.l 	d3
        bpl.s 	mdv3
        neg.l 	d3
mdv3:   moveq 	#31,d5         ;division lente: 32/32 bits
        moveq 	#-1,d4
        clr.l 	d1
mdv2:   lsl.l 	#1,d6
        roxl.l 	#1,d1
        cmp.l 	d3,d1
        bcs.s 	mdv1
        sub.l 	d3,d1
        lsr 	#1,d4           ;met X a un!
mdv1:   roxl.l 	#1,d0
        dbra 	d5,mdv2
	move.l 	d1,d3        ;prend le reste!
        bra 	EvaRet

* NOT
FNot:	bsr	Evalue
	not.l	d3
	bra	OpeRet

; COMPARAISON DE DEUX CHAINES
compch: move.l 	d6,a0
        move.l 	d3,a1
        clr.l 	d3
        clr.l 	d6
        clr.b 	d2
        move.w 	(a0)+,d0
        move.w 	(a1)+,d1
        beq.s 	cpch8
        tst 	d0
        beq.s	cpch7
cpch1:  cmpm.b 	(a0)+,(a1)+
        bne.s 	cpch6
        subq 	#1,d0
        beq.s 	cpch3
        subq	#1,d1
        bne.s 	cpch1
; on estrrive au bout d'une des chaines
cpch2:  moveq 	#1,d6         ;A$>B$
        rts
cpch3:  subq 	#1,d1          ;egalite!
        beq.s 	cpch5
cpch4:  moveq 	#1,d3         ;B$>A$
cpch5:  rts
; on estas arrive au bout des chaines
cpch6:  bcc.s 	cpch4
        bcs.s 	cpch2
; a$ estulle
cpch7:  tst 	d1
        beq.s 	cpch5           ;deux chaines nulles
        bne.s 	cpch4           ;B$>A$
; b$ estulle
cpch8:  tst 	d0
        beq.s 	cpch5           ;deux chaines nulles
        bne.s 	cpch2           ;A$>B$

* Comparaison de 2 floats
CFloat:	move.l	a6,-(sp)
	move.l	d3,d1
	move.l	d6,d0
	move.l	FloatBase(a5),a6
	jsr	SPCmp(a6)
	move.l	(sp)+,a6
	rts

; OPERATEUR EGAL
egale:  bsr 	compat
egbis:  bmi.s 	eg1             ;entree pour find
        bne.s 	eg2
	bsr	CFloat
	bne.s	Faux
	bra.s	Vrai
eg1:    cmp.l 	d3,d6
        beq.s 	vrai
faux:   moveq 	#0,d3
	moveq 	#0,d2
	bra 	EvaRet
vrai:   moveq 	#-1,d3
        moveq 	#0,d2
        bra	EvaRet
eg2:    bsr 	compch
        bra.s 	eg1
 
; OPERATEUR INFERIEUR STRICTEMENT
inf:    bsr 	compat
        bmi.s 	inf1
        bne.s 	inf2
	bsr	CFloat
	blt	Vrai
	bra	Faux
inf1:   cmp.l 	d3,d6
        blt.s 	vrai
        bra.s 	faux
inf2:   bsr 	compch
        bra.s 	inf1

; OPERATEUR INFERIEUR OU EGAL
infeg:  bsr 	compat
        bmi.s 	infeg1
        bne.s 	infeg2
	bsr	CFloat
	ble	Vrai
	bra	Faux
infeg1: cmp.l 	d3,d6
        ble 	vrai
        bra 	faux
infeg2: bsr 	compch
        bra.s 	infeg1

; OPERATEUR DIFFERENT
diff:   bsr 	compat
        bmi.s 	dif1
        bne.s 	dif2
	bsr	CFloat
	bne	Vrai
	bra	Faux
dif1:   cmp.l 	d3,d6
        bne 	vrai
        bra 	faux
dif2:   bsr 	compch
        bra.s 	dif1

; OPERATEUR SUPERIEUR STRICTEMENT
sup:    bsr 	compat
	bmi.s 	sup1
        bne.s 	sup2
	bsr	CFloat
	bgt	Vrai
	bra	Faux
sup1:   cmp.l 	d3,d6
        bgt 	vrai
        bra 	faux
sup2:   bsr 	compch
        bra.s 	sup1

; OPERATEUR SUPERIEUR OU EGAL
supeg:  bsr 	compat
        bmi.s 	supeg1
        bne.s 	supeg2
	bsr	CFloat
	bge	Vrai
	bra	Faux
supeg1: cmp.l 	d3,d6
        bge 	vrai
        bra 	faux
supeg2: bsr 	compch
        bra.s 	supeg1

; OPERATEUR AND
opand:  bsr 	quentier
        and.l 	d6,d3
        bra 	EvaRet

; OPERATEUR OR
opor:   bsr 	quentier
        or.l 	d6,d3
        bra 	EvaRet

; OPERATEUR XOR
opxor:  bsr 	quentier
        eor.l 	d6,d3
        bra 	EvaRet

***********************************************************
*	FONCTIONS MATH!

******* MAX
FMax	bsr	MinMax
	bge	FMx2
FMx1	exg.l	d3,d6
FMx2	bra	OpeRet
******* MIN
FMin	bsr	MinMax
	bge.s	FMx1
	bra.s	FMx2
******* Routine min max
MinMax	bsr	FnEval
	movem.l	d2/d3,-(sp)
	bsr	FnEval
	movem.l	(sp)+,d5/d6
	bsr	Compat
	bmi.s	MMx1
	bne.s	MMx2
	movem.l	d2/d3/d5/d6,-(sp)	* Float
	bsr	CFloat
	movem.l	(sp)+,d2/d3/d5/d6
	rts
MMx1	cmp.l	d3,d6			* Int
	rts
MMx2	movem.l	d2/d3/d5/d6,-(sp)	* Chaine
	bsr	CompCh
	move.l	d3,d0
	move.l	d6,d1
	movem.l	(sp)+,d2/d3/d5/d6
	cmp.l	d0,d1
	rts

******* ABS
FAbs:	bsr	FnEval
	tst.b	d2
	bne.s	FAbs1
* Entier
	tst.l	d3
	bpl	OpeRet
	neg.l	d3
	bra	OpeRet
* Float
FAbs1	moveq	#SPAbs,d2
FlOpe	move.l	a6,-(sp)
	move.l	d3,d0
	move.l	FloatBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d0,d3
	moveq	#1,d2
	move.l	(sp)+,a6
	bra	OpeRet
******* INT
FInt:	bsr	FnEval
	tst.b	d2
	beq	OpeRet
	moveq	#SpFloor,d2
	bra.s	Flope

******* =SGN
FSgn:	bsr	FnEval
	tst.b	d2
	bne.s	FSgn1
	tst.l	d3
	beq	OpeRet
	bpl.s	FSgn0
	moveq	#-1,d3
	bra	OpeRet
FSgn0	moveq	#1,d3
	bra	OpeRet
FSgn1	move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	move.l	d3,d1
	jsr	SPTst(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#0,d2
	bra	OpeRet

******* RADIUS
IRad:	clr.w	Angle(a5)
	bra	InsRet
******* DEGREE
IDeg:	move.w	#-1,Angle(a5)
	bra	InsRet
******* Fonction: ramene un ANGLE
FAngle:	bsr	FnFloat
	tst.w	Angle(a5)
	beq.s	FAnX
* Conversion--> radian
	move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	move.l	d3,d0
	move.l	Val180(a5),d1
	jsr	SPDiv(a6)
	move.l	ValPi(a5),d1
	jsr	SPMul(a6)
	move.l	d0,d3
	moveq	#1,d2
	move.l	(sp)+,a6
FAnX	rts
******* =PI
FPi:	move.l	ValPi(a5),d3
	moveq	#1,d2
	bra	OpeRet
******* SQR
FSqr:	bsr	FnFloat
	bsr	FlPos
	moveq	#SPSqrt,d2
FMOpe	move.l	a6,-(sp)
	move.l	d3,d0
	move.l	MathBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d0,d3
	moveq	#1,d2
	move.l	(sp)+,a6
	bra	OpeRet
* Verifie que le float est positif!
FlPos:	move.l	d3,d1
	move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	jsr	SPTst(a6)
	move.l	(sp)+,a6
	bmi	FonCall
	rts
******* SIN
FSin:	bsr	FAngle
	moveq	#SPSin,d2
	bra	Fmope
******* COS
FCos:	bsr	FAngle
	moveq	#SPCos,d2
	bra	Fmope
******* TAN
FTan:	bsr	FAngle
	move.l	d3,d0
	move.l	a6,-(sp)
	move.l	MathBase(a5),a6
	jsr	SPTan(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	moveq	#1,d2
	cmp.l	#$FFFFFF7F,d3
	bne	OpeRet
	bra	Overflow
******* FIX le nombre de decimales
IFix:   bsr 	Expentier
        tst.l 	d3
        bmi.s 	ifx2 
        clr 	ExpFlg(a5)
ifx0:   cmp.l 	#16,d3
        bcs.s 	ifx1
        move 	#-1,d3
ifx1:   move 	d3,FixFlg(a5)
       	bra	InsRet
ifx2:   neg.l 	d3
        move.w 	#1,ExpFlg(a5)
        bra.s 	ifx0

***********************************************************
*	HASARD
*******	=RND(n)
FnRnd	bsr	FnExpE
	tst.l	d3
	bne.s	Rnd1
* Ramene le dernier
	move.l	OldRnd(a5),d3
	moveq	#0,d2
	bra	OpeRet
* Calcule!
Rnd1	moveq	#0,d7
	move.l	d3,d5
	bmi.s	Rnd0
	moveq	#-1,d7
	bra.s	Rnd0a
Rnd0	neg.l	d5
Rnd0a	move.l	#$FFFFFF,d4
	moveq	#23,d0
Rnd2	lsr.l	#1,d4
	cmp.l	d5,d4
	dbcs	d0,rnd2
	roxl.l	#1,d4
Rnd4	bsr	RRnd
	move.w	$dff006,d0
	and.w	d7,d0
	add.w	d0,d1
	and.l	d4,d1
	cmp.l	d5,d1
	bhi.s	Rnd4
	move.l	d1,OldRnd(a5)
	move.l	d1,d3
	moveq	#0,d2
	bra	OpeRet

******* RANDOMIZE n
Random:	bsr	Expentier
	move.l	d3,Seed(a5)
	bra	InsRet
******* RND
RRnd:	move.l 	Seed(a5),d3
	move.l	#$bb40e62d,d6
	bsr	Mul32
	addq.l	#1,d1
	move.l	d1,Seed(a5)
	lsr.l	#8,d1
	rts
******* Multiplication 32 Bits non signee D6*D3 -> D1
Mul32:  move d6,d1
        mulu d3,d1
        swap d6
        move d6,d0
        mulu d3,d0
        swap d0
        add.l d0,d1
        swap d3
        move d6,d0
        mulu d3,d0
        swap d6
        move d6,d0
        mulu d3,d0
        swap d0
        add.l d0,d1
	rts

***********************************************************
*	DATA/READ/RESTORE
***********************************************************

******* Instruction DATA-> passe a la ligne suivante
InData: move.w	(a6),d0
	sub.w	d0,a6
	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	add.w	d0,a6
	bra	ChrGet

******* READ
InRead:
* Va chercher la variable
	bsr	FindVar
* Va chercher le data
	move.l	a0,-(sp)
	move.w	d2,-(sp)
	move.l	a6,-(sp)
	move.l	AData(a5),d0
	beq.s	NxD0
	move.l	d0,a6
	bra.s	NxD3
NxD0:	move.l	PData(a5),d0
	beq	OOfData
	move.l	d0,a6
NxD1:	tst.w	(a6)
	beq	OOfData
	lea	2(a6),a0
	move.w	(a0),d0
	cmp.w	#TkEndP-Tk,d0
	beq	OOfData
	cmp.w	#TkProc-Tk,d0
	beq.s	NxD6
	cmp.w	#TkData-Tk,d0		* DATA direct
	beq.s	NxD2
	cmp.w	#TkLab-Tk,d0		* LABEL: DATA
	bne.s	NxD5
	move.b	6(a6),d0
	ext.w	d0
	lea	8(a6,d0.w),a0
	cmp.w	#TkData-Tk,(a0)
	beq.s	NxD2
NxD5:	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	lea	0(a6,d0.w),a6
	bra.s	NxD1
NxD6:	move.l	2(a0),d0
	lea	10(a0,d0.l),a6
	bra.s	NxD1
NxD2:	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	lea	0(a6,d0.w),a6
	move.l	a6,PData(a5)
	lea	4(a0),a6
* Virgule---> SPECIAL!
NxD3:	move.w	(a6),d0
	beq.s	InRdV
	cmp.w	#TkVir-Tk,d0
	bne.s	InRd0
InRdV:	moveq	#0,d3
	moveq	#0,d2
	move.w	4(sp),d5
	subq.w	#2,d5
	bmi.s	InRd1
	move.l	ChVide(a5),d3
	moveq	#2,d2
	bra.s	InRd1
* Evaluation normale
InRd0:	bsr	Evalue
* Pointe la fin du data
InRd1:	tst.w	(a6)+
	bne.s	InRd2
	sub.l	a6,a6
InRd2:	move.l	a6,AData(a5)
* Egalise
	move.l	(sp)+,a6
	move.w	(sp)+,d5
	move.l	(sp)+,a2
	cmp.b	d2,d5
	beq.s	InRd5
	cmp.b	#2,d5
	beq	RTypeM
	cmp.b	#2,d2
	beq	RTypeM
	tst.b	d5
	beq.s	InRd4
	bsr	IntToFl
	bra.s	InRd5
InRd4:	bsr	FlToInt
InRd5:	move.l	d3,(a2)
* Encore une variable?
	cmp.w	#TkVir-Tk,(a6)+
	beq	InRead
	subq.l	#2,a6
	bra	InsRet
OOfData:clr.l	PData(a5)
	moveq	#33,d0
	bra	RunErr
RTypeM:	moveq	#34,d0
	bra	RunErr
	
******* RESTORE
InRest:	jsr	Finie
	bne.s	InRs1
* Sans label
	move.l	DProc(a5),PData(a5)
	clr.l	AData(a5)
	bra	InsRet
* Avec label
InRs1:	bsr	GetLabel
	beq	LbNDef
	move.l	d0,a0
	cmp.w	#TkData-Tk,(a0)+
	bne.s	InRs2
	move.w	(a0),d0
	sub.w	d0,a0
	move.l	a0,PData(a5)
	clr.l	AData(a5)
	bra	InsRet
InRs2	moveq	#41,d0
	bra	RunErr

***********************************************************
*	TIMER
ITimer:	bsr	FnExpE
	move.l	d3,T_VBLTimer(a5)
	bra	InsRet
FTimer:	move.l	T_VBLTimer(a5),d3
	moveq	#0,d2
	bra	OpeRet

***********************************************************
*	WAIT n
IWait	bsr	Expentier
	tst.l	d3
	bls	FonCall
* Routine avec branchements
	add.l	T_VBLCount(a5),d3
IWt1	cmp.l	T_VBLCount(a5),d3
	bls	InsRet
	move.l	d3,-(sp)
	bsr	Tests
	move.l	(sp)+,d3
	bra.s	IWt1
* Routine SANS branchement (extensions)
WaitRout:
	add.l	T_VBLCount(a5),d3
IWt2	cmp.l	T_VBLCount(a5),d3
	bls.s	IWt3
	move.l	d3,-(sp)
	bsr	Tests
	move.l	(sp)+,d3
	bra.s	IWt2
IWt3	rts
* Multiwait
IMWait:	jsr	WaitMul
	bsr	Tests
	bra	InsRet


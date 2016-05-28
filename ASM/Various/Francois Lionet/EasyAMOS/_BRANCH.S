
;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* BOUCLES / BRANCHEMENT
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

***********************************************************
*	FOR / NEXT
TForNxt:equ 	24		24 octets pour une FOR/NEXT

*******	FOR
For:	move.w	(a6)+,d0	Pousse l'adresse du NEXT
	pea	0(a6,d0.w)
	bsr	FindVar
	move.w	d2,-(sp)
	move.l	a0,-(sp)
	bsr	FnEval		Egalise la variable
	move.w	4(sp),d1
	bsr	MMType
	move.l	(sp)+,a0	
	move.l	d3,(a0)
	move.l	a0,-(a3)
	bsr	FnEval		Cherche la limite
	move.w	(sp),d1
	bsr	MMType
	move.l	d3,-(a3)
	moveq	#0,d2
	moveq	#1,d3
	cmp.w	#TkStp-Tk,(a6)
	bne.s	For3
	bsr	FnEval		Cherche la STEP
For3:	move.w	(sp)+,d1
	bsr	MMType
	move.l	d3,-(a3)
	move.w	d2,-(a3)	Poke le type
	move.l	(sp)+,a0
	moveq	#TForNxt,d0
	bra	Rpt0
	
* Egalise le type D3 au type demande (D1)
MMType:	cmp.b	d1,d2
	bne.s	MMt1
	rts
MMt1:	tst.b	d2
	beq	IntToFl
	bne	FlToInt

******* NEXT
TNext:	bsr	Tester
Next:	tst.b	T_Actualise(a5)
	bmi.s	TNext
	move.l	20(a3),a2
	move.l	12(a3),d3
	move.l	16(a3),d6
	tst.b	11(a3)
	bne.s	NextF
; TRAVAILLE SUR ENTIERS
	add.l 	d3,(a2)         ;ENTIER
        tst.l 	d3
        bpl.s 	next1
; step negative: inferieur
	cmp.l 	(a2),d6
        ble.s 	nextR
        bra.s 	nextS
; step positive: superieur
next1:  cmp.l 	(a2),d6
        blt.s 	nextS
; ON RESTE DANS LA BOUCLE!
nextR:  move.l	6(a3),a6
	bra	InsRet  
; ON SORT DE LA BOUCLE!
nextS: 	add.w	#TForNxt,a3
	move.l	a3,PLoop(a5)
	cmp.w	#TkVar-Tk,(a6)	Saute la variable
	bne	InsRet
	bsr	FindVar
	bra	InsRet
; TRAVAILLE SUR FLOAT
NextF:  move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	move.l	d3,d1
	jsr	SPTst(a6)
	move.l	d0,d5
	move.l	d3,d0
	move.l 	(a2),d1
	jsr	SPAdd(a6)
	move.l	d0,(a2)
	move.l	d6,d1
	jsr	SPCmp(a6)
	move.l	(sp)+,a6
	blt	NextF1
	tst.l	d5
	bpl.s	NextS
	bmi.s	NextR
NextF1	tst.l	d5
	bpl.s	NextR
	bmi.s	NextS

***********************************************************
*	REPEAT/UNTIL
TRptUnt:equ 	10

******* REPEAT
Repeat:	move.w	(a6)+,d0
	lea	0(a6,d0.w),a0
	moveq	#TRptUnt,d0
Rpt0:	tst.w	(a6)+
	bne.s	Rpt1
	addq.l	#2,a6
Rpt1:	move.l	a6,-(a3)
	move.l	a0,-(a3)
	move.w	d0,-(a3)
	cmp.l	MinLoop(a5),a3	
	bcs	OofStack
	move.l	a3,PLoop(a5)
	bra	InsRet

******* UNTIL
TUnt:	bsr	Tester
Until:	tst.b	T_Actualise(a5)
	bmi.s	TUnt
	bsr	Expentier
	tst.l	d3
	bne.s	Unt1
* On reste dans la boucle
	move.l	6(a3),a6
	bra	InsRet
* On sort de la boucle
Unt1:	lea	TRptUnt(a3),a3
	move.l	a3,PLoop(a5)
	bra	InsRet


***********************************************************
*	WHILE/WEND
TWhlWnd:equ 	10

******* WHILE
While:	move.w	(a6)+,d0
	move.l	a6,-(a3)
	add.w	d0,a6
	move.l	a6,-(a3)
	move.w	#TWhlWnd,-(a3)
	cmp.l	MinLoop(a5),a3	
	bcs	OofStack
	move.l	a3,PLoop(a5)
	bra.s	Wend

******* WEND
TWend:	bsr	Tester
Wend:	tst.b	T_Actualise(a5)
	bmi.s	TWend
	move.l	a6,-(sp)
	move.l	6(a3),a6
	bsr	Expentier
	tst.l	d3
	beq.s	Wnd1
* On reste dans la boucle
	addq.l	#4,sp
	bra	InsRet
* On sort de la boucle
Wnd1:	move.l	(sp)+,a6
	lea	TWhlWnd(a3),a3
	move.l	a3,PLoop(a5)
	bra	InsRet

***********************************************************
*	DO/LOOP
TDoLoop:equ 10

******* DO
Do:	bra	Repeat

******* LOOP
TLoop:	bsr	Tester
Loop:	tst.b	T_Actualise(a5)
	bmi.s	TLoop
	move.l	6(a3),a6
	bra	InsRet	

***********************************************************
*		EXIT/EXIT IF

******* Exit simple
TExit:	bsr	Tester
Exit:	tst.b	T_Actualise(a5)
	bmi.s	TExit
	move.w	(a6)+,d0
	add.w	(a6)+,a3
	move.l	a3,PLoop(a5)
	add.w	d0,a6
	bra	InsRet
*******	IF
If:	move.l	a6,-(sp)
	addq.l	#2,a6
	bsr	Expentier
	tst.l	d3
	bne.s	IfV
* Faux: va au ELSE
	move.l	(sp)+,a6
	add.w	(a6)+,a6
	bra	LGoto
IfV:	addq.l	#4,sp
	cmp.w	#TkThen-Tk,(a6)
	bne	InsRet
	addq.l	#2,a6
	bra	InsRet
******* ELSE
Else:	add.w	(a6)+,a6
	bra	LGoto
******* ENDIF---> rien du tout!

******* GOSUB
TGosub:	bsr	Tester
Gosub:	tst.b	T_Actualise(a5)
	bmi.s	TGosub
	bsr	GetLabel
	beq	LbNDef
Gos2:	move.l	BasA3(a5),-(a3)
	move.l	a6,-(a3)
	move.l	CodeGosb(pc),-(a3)
	cmp.l	MinLoop(a5),a3	
	bcs	OofStack
	move.l	a3,PLoop(a5)
	move.l	a3,BasA3(a5)
	move.l	d0,a6
	bra	InsRet
******* RETURN
TRetN:	bsr	Tester
Retn:	tst.b	T_Actualise(a5)
	bmi.s	TRetN
	move.l	BasA3(a5),a3
	move.l	CodeGosb(pc),d0
	cmp.l	(a3)+,d0
	bne	RetGsb
	move.l	(a3)+,a6
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	bra	InsRet
******* POP
TPop:	bsr	Tester
Pop:	tst.b	T_Actualise(a5)
	bmi.s	TPop
	move.l	BasA3(a5),a3		BUG si POP au milieu d'une boucle
	move.l	CodeGosb(pc),d0
	cmp.l	(a3)+,d0
	bne	PopGsb
	addq.l	#4,a3
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	bra	LGoto

******* PASSAGE SUR UNE PROCEDURE: saute le contenu!
Proc:	move.l	(a6)+,d0
	lea	4(a6,d0.l),a6
	bra	InsRet
******* INSTRUCTION PROC
InPrc:	addq.w	#2,a6
******* APPEL PROCEDURE
TInPro:	bsr	Tester
InPro:	tst.b	T_Actualise(a5)
	bmi.s	TInPro
	move.w	(a6)+,d0
	move.b	(a6),d1
	ext.w	d1
	lea	2(a6,d1.w),a6
	move.l	LabHaut(a5),a2
	move.l	0(a2,d0.w),a2
	clr.w	-(sp)
* Entree pour la routine d'erreur
InProE:	moveq	#0,d7
* Bas de la zone de variables
InPrOn	move.l	d7,-(sp)
	addq.l	#6,a2
	move.l	TabBas(a5),a0
	move.w	#$FFFF,-(a0)		Pointe le debut des variables!
	move.l	VarLoc(a5),-(a0)
	move.l	a0,a1
	sub.w	(a2)+,a0
	addq.l	#2,a2
	move.l	a0,-(sp)
* Assez de memoire?
	subq.l	#4,a0
	cmp.l	HiChaine(a5),a0
	bcc.s	InP0b
	movem.l	a1-a2/d0-d2,-(sp)
	move.l	a0,a1
	moveq	#0,d3
	bsr	Menage
	movem.l	(sp)+,a1-a2/d0-d2
* Nettoie les variables
InP0b	move.l	(sp),a0
	cmp.l	a1,a0
	bcc.s	InP1
InP0:	clr.l	(a0)+
	clr.w	(a0)+
	cmp.l	a1,a0
	bcs.s	InP0
InP1:	move.b	4(a2),d0
	ext.w	d0
	lea	6(a2,d0.w),a2
	cmp.w	#TkBra1-Tk,(a6)
	bne.s	InPx
* Recupere les variables
InPa:	addq.l	#2,a6
	pea	4(a2)
	bsr	Evalue
	move.l	(sp)+,a2
	move.l	(sp),a1
	move.w	(a2)+,d0
	bpl.s	InPa0
	move.l	VarGlo(a5),a1
	addq.w	#1,d0
	neg.w	d0
InPa0	add.w	d0,a1
	move.b	(a2)+,d1
	ext.w	d1
	move.b	(a2)+,d5
	add.w	d1,a2
	and.w	#$0F,d5
	cmp.b	d2,d5
	beq.s	InPd
	tst.b	d2
	bne.s	InPc
	bsr	IntToFl
	bra.s	InPd
InPc:	bsr	FlToInt
InPd:	move.l	d3,(a1)+
	move.w	d5,(a1)
	cmp.w	#TkVir-Tk,(a6)
	beq.s	InPa
	addq.l	#2,a6
	addq.l	#2,a2
* Descend les limites
InPx	move.l	(sp)+,a0
	lea	-8(a0),a1
	cmp.l	HiChaine(a5),a1
	bcs.s	Refaire
	move.l	(sp)+,d7
	beq.s	InPx1
	move.l	d7,a6
InPx1	move.l	BasA3(a5),-(a3)
	move.l	VarLoc(a5),-(a3)
	move.l	TabBas(a5),-(a3)
	move.l	OnErrLine(a5),-(a3)
	move.l	ErrorChr(a5),-(a3)
	move.w	ErrorOn(a5),-(a3)
	move.l	PData(a5),-(a3)
	move.l	AData(a5),-(a3)
	move.l	DProc(a5),-(a3)
	move.l	a6,-(a3)
	move.l	CodeProc(pc),-(a3)	* Code anti crash!!!
	cmp.l	MinLoop(a5),a3
	bcs	OOfStack
	move.l	a3,PLoop(a5)
	move.l	a3,BasA3(a5)
	move.l	a0,VarLoc(a5)
	move.l	a0,TabBas(a5)
	clr.l	OnErrLine(a5)
	move.l	a2,a6
	addq.l	#2,a2
	move.l	a2,DProc(a5)
	move.l	a2,PData(a5)
	clr.l	AData(a5)
* Erreurs
	move.w	(sp)+,ErrorOn(a5)
* Branche a la procedure
	bra	InsRet
* Les variables ont ete effacees par les chaines!
ReFaire	move.l	TabBas(a5),d3
	lea	-16(a0),a0
	sub.l	a0,d3
	bra	Demande

******* END PROC
TEProc:	bsr	Tester
EProc:	tst.b	T_Actualise(a5)
	bmi.s	TEProc
	cmp.w	#TkBra1-Tk,(a6)
	beq.s	FnEPRoc
EPro1:	tst.w	ErrorOn(a5)
	bne	EProErr
* Protection anti crash!!!
EPro2	move.l	(a3),d0
	addq.l	#2,a3
	cmp.l	CodeProc(pc),d0
	bne.s	EPro2
	addq.l	#2,a3
* Ok!
	move.l	(a3)+,d0
	move.l	(a3)+,DProc(a5)
	move.l	(a3)+,AData(a5)
	move.l	(a3)+,PData(a5)
	move.w	(a3)+,ErrorOn(a5)
	move.l	(a3)+,ErrorChr(a5)
	move.l	(a3)+,OnErrLine(a5)
	move.l	(a3)+,TabBas(a5)
	move.l	(a3)+,VarLoc(a5)
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	move.l	d0,a6
	bra	InsRet
******* END PROC [param]
FnEProc:addq.l	#2,a6
	bsr	Evalue
	subq.b	#1,d2
	bmi.s	FNE1
	beq.s	FnE2
	move.l	d3,ParamC(a5)
	bra.s	EPro1
FnE1:	move.l	d3,ParamE(a5)
	bra.s	EPro1
FnE2:	move.l	d3,ParamF(a5)
	bra.s	EPro1
******* POP PROC
TPopPro:bsr	Tester
PopPro:	tst.b	T_Actualise(a5)
	bmi.s	TPopPro
	tst.w	ErrorOn(a5)
	bne	EProErr
	bsr.s	PopP
	bra	InsRet
* Routine
PopP:	move.l	BasA3(a5),a3
* Protection anti crash!!!	
PopP2	move.l	(a3),d0
	addq.l	#2,a3
	cmp.l	CodeProc(pc),d0
	bne.s	PopP2
	addq.l	#2,a3
* Ok!
	move.l	(a3)+,d0
	move.l	(a3)+,DProc(a5)
	move.l	(a3)+,AData(a5)
	move.l	(a3)+,PData(a5)
	move.w	(a3)+,ErrorOn(a5)
	move.l	(a3)+,ErrorChr(a5)
	move.l	(a3)+,OnErrLine(a5)
	move.l	(a3)+,TabBas(a5)
	move.l	(a3)+,VarLoc(a5)
	tst.l	d0
	beq	FonCall
	move.l	d0,a6
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	rts
	
******* PARAM: ramene le parametre
ParEnt:	clr.w	d2
	move.l	ParamE(a5),d3
	bra	OpeRet
ParFl:	moveq	#1,d2
	move.l	ParamF(a5),d3
	bra	OpeRet
ParCh:	moveq	#2,d2
	move.l	ParamC(a5),d3
	bra	OpeRet

******* Appel direct du label!!!
Goto2:	move.w	(a6),d0
	move.l	LabHaut(a5),a0
	move.l	0(a0,d0.w),a6
	bra.s	LGoto
******* GOTO / THEN #ligne
TGoto:	bsr	Tester
Goto:	tst.b	T_Actualise(a5)
	bmi.s	TGoto
	bsr	GetLabel
	beq	LbNDef
	move.l	d0,a6

******* Routine GOTO - remonte la pile et branche a A6 -
LGoto:	move.l	BasA3(a5),d0
LGo0:	cmp.l	d0,a3
	bcc	InsRet
	cmp.l	6(a3),a6
	bcs.s	LGo1
	cmp.l	2(a3),a6
	bls	InsRet
LGo1:	add.w	(a3),a3
	bra.s	LGo0	

******* ON xx GOTO/GOSUB/PROC
TOn:	bsr	Tester
On:	tst.b	T_Actualise(a5)
	bmi.s	TOn
	move.w	(a6)+,d0
	pea	2(a6,d0.w)
	move.w	(a6)+,-(sp)
	bsr	Expentier
	moveq	#0,d2
	move.w	(sp),d2
	move.w	(a6)+,(sp)
	subq.l	#1,d3
	bmi.s	OnR
	beq.s	OnG
	cmp.l	d2,d3
	bcc.s	OnR
* Pointe le bon label et fait le saut
	move.w	d3,-(sp)
On1	bsr	GetLabel
* Pour version 2!
*	cmp.w	#TkBra1-Tk,(a6)+
*	bne.s	On1b
*On1a	cmp.w	#TkBra2-Tk,(a6)+
*	bne.s	On1a
*	cmp.w	#TkVir-Tk,(a6)
*	bne.s	On1a
	addq.l	#2,a6
On1b	subq.w	#1,(sp)
	bne.s	On1
	addq.l	#2,sp
OnG:	move.w	(sp)+,d1
	move.l	(sp)+,a0
	cmp.w	#TkGto-Tk,d1
	beq	Goto
	cmp.w	#TkPrc-Tk,d1
	beq.s	ROnP
	move.l	BasA3(a5),-(a3)
	move.l	a0,-(a3)
	move.l	CodeGosb(pc),-(a3)
	cmp.l	MinLoop(a5),a3	
	bcs	OofStack
	bsr	GetLabel
	beq	LbNDef
	move.l	d0,a6
	move.l	a3,PLoop(a5)
	move.l	a3,BasA3(a5)
	bra	InsRet
* Appel d'une procedure
ROnP	move.l	a0,d7			* Adresse de retour
	bsr	GetLabel
	move.l	d0,a2			* Adresse procedure
	clr.w	-(sp)
	bra	InPrOn
* Passe a l'instruction suivante
OnR:	addq.l	#2,sp
	move.l	(sp)+,a6
	bra	InsRet

******* TROUVE LE LABEL (A6)
GetLabel:
	move.w	(a6)+,d0
	cmp.w	#TkPro-Tk,d0
	beq.s	GLb0
	cmp.w	#TkLGo-Tk,d0
	bne.s	GLb1
* Un label NORMAL!!!
GLb0	move.w	(a6)+,d0
	move.l	LabHaut(a5),a0
	move.b	(a6),d1
	ext.w	d1
	lea	2(a6,d1.w),a6
	move.l	0(a0,d0.w),d0
	rts
* Une expression
GLb1	subq.l	#2,a6
	bsr	Evalue
	subq.b	#1,d2
	bmi.s	GLb2
	bne.s	GLb3
	bsr	FlToInt
* Ecrit le chiffre dans le buffer!
GLb2	move.l	BufLabel(a5),a1
	move.l	a1,a0
	move.l	d3,d0
	jsr	LongDec
	move.l	a0,d2
	sub.l	a1,d2
	beq.s	GLabE
	move.l	a1,d3
	bra.s	GLab
* Chaine alphanumerique
GLb3	move.l	d3,a2
	move.w	(a2)+,d2
	beq.s	GLabE
	cmp.w	#32,d2
	bcc.s	GLabE
	move.w	d2,d1
	subq.w	#1,d1
	move.l	BufLabel(a5),a0
	move.l	a0,d3
GLab0	move.b	(a2)+,d0
	cmp.b	#"A",d0
	bcs.s	GLab1
	cmp.b	#"Z",d0
	bhi.s	GLab1
	add.b	#32,d0
GLab1	move.b	d0,(a0)+
	dbra	d1,GLab0
* Rend pair
GLab	btst	#0,d2
	beq.s	GLab2
	clr.b	(a0)+
	addq.w	#1,d2
* Trouve le label
GLab2	move.l	LabBas(a5),a1
GLab3	move.l	a1,a0
	move.b	(a0),d1
	beq.s	GLabE
	ext.w	d1
	cmp.w	d2,d1
	bne.s	GLabN
	move.l	d3,a2
	addq.l	#8,a0
	move.w	d1,d0
	subq.w	#1,d0
GLab4	cmp.b	(a0)+,(a2)+
	bne.s	GLabN
	dbra	d0,GLab4
* Label trouve!
GLabT	move.l	4(a1),d0
	rts
* Label suivant
GLabN	lea	8(a1,d1.w),a1
	bra.s	GLab3
* Label pas trouve!
GLabE	moveq	#0,d0
	rts
* Erreur!
LbNDef:	moveq	#40,d0
	bra	RunErr


*************** Codes de protection anti-crash! ***********
CodeProc	dc.l "Proc"
CodeGosb	dc.l "Gosb"
***********************************************************


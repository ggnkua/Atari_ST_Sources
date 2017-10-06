

	bra Installe

*********************************************************************
*	TABLE DES SAUTS A LA TRAPPE
************************************
Jumps:	dc.l CPlus		;0
	dc.l CMoins		;1
	dc.l CMult		;2
	dc.l CDivi		;3
	dc.l CSIN			;4
	dc.l CCOS			;5
	dc.l CTAN			;6
	dc.l CEXP			;7
	dc.l CLN			;8
	dc.l CLOG			;9
	dc.l CSQR			;A
	dc.l Catof		;B
	dc.l CFtoa		;C
	dc.l CFtol		;D
	dc.l CLtof		;E
	dc.l CEq			;F
	dc.l CDif			;10
	dc.l CGt			;11
	dc.l CGe			;12
	dc.l CLt			;13
	dc.l CLe			;14
	dc.l CASIN		;15
	dc.l CACOS		;16
	dc.l CATAN		;17
	dc.l CSINH		;18
	dc.l CCOSH		;19
	dc.l CTANH		;1A
	dc.l CINT			;1B
	dc.l CPUIS		;1C
	dc.l CABS			;1D

Jump2:	dc.l 0			;0
	dc.l GetSgn		;1
	dc.l pi			;2	
	dc.l deg			;3
	dc.l rad			;4
	dc.l zerau		;5

TempBuf 	dc.l 0
TempFl 	dc.l 0
Zero:	dc.b "0.0000000",0
BadFlo:	dc.b 21," BAD FLOAT TRAP ",18,0
Buffer	ds.b 64

	even

**********************************************************************
*	INSTALLATION DE LA TRAPPE
**********************************
Installe:	pea STrap(pc)
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	lea FinPrg(pc),a0
	rts
STrap:	lea Entrap(pc),a0
	move.l a0,$98
	rts

**********************************************************************
*	ENTREE DE LA TRAPPE
****************************
Entrap:	lsl.w #2,d0
	bmi.s DirFonc
	lea Jumps(pc),a1
	move.l 0(a1,d0.w),a1
	jmp (a1)

; Fonctions SUPPLEMENTAIRES
DirFonc	tst.b d0
	beq.s Inverse
	and.w #$ff,d0
	lea Jump2(pc),a1
	move.l 0(a1,d0.w),a1
	jmp (a1)
;-----> INVERSE
Inverse	bchg #7,d3			;0 ---> INVERSE le signe
	rte
;-----> RAMENE LE SIGNE en D0
GetSgn	tst.l d3
	beq.s Gs2
	btst #7,d3			;1 ---> TROUVE le signe, en D0
	bne.s Gs1
	moveq #1,d0
	rte
GS1:	moveq #-1,d0
	rte
Gs2:	moveq #0,d0
	rte
;-----> PI
pi	move.l #$c90fd942,d3
	move.l #$12345678,d4
	rte
;-----> DEG
deg	move.l #$c90fc942,-(sp)		;/pi
	move.l d3,-(sp)
	bsr Divi
	addq.l #8,sp
	move.l d0,-(sp)
	move.l #$b4000048,-(sp)		;*180
	bsr Mult
	addq.l #8,sp
	move.l d0,d3
	move.l #$12345678,d4
	rte
;-----> RAD
rad	move.l #$b4000048,-(sp)		;/180
	move.l d3,-(sp)
	bsr Divi
	addq.l #8,sp
	move.l d0,-(sp)
	move.l #$c90fc942,-(sp)		;*PI
	bsr Mult
	addq.l #8,sp
	move.l d0,d3
	move.l #$12345678,d4
	rte
;-----> ZERO: ramene le ZERO (pour DIM)
zerau:	moveq #0,d3
	move.l #$12345678,d4
	rte



******* ADDITION FLOAT
CPlus:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Plus
	addq.l #8,sp
	move.l #$12345678,d1
	rte

******* SOUSTRACTION FLOAT
CMoins:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Moins
	addq.l #8,sp
	move.l #$12345678,d1 
	rte

******* MULTIPLICATION FLOAT
CMult:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Mult
	addq.l #8,sp
	move.l #$12345678,d1
	rte

******* DIVISION FLOAT
CDivi:	tst.l d3
	beq.s CD0
	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Divi
	addq.l #8,sp
	move.l #$12345678,d1
	rte
; Division par ZERO!
CD0:	divu #0,d1
	rte

******* ASCII to FLOAT
CAtof:	lea Buffer(pc),a1
	move.l a1,-(sp)
	moveq #18,d1
Ca1:	move.b (a0)+,d0
	beq.s Ca2
	cmp.b #32,d0
	beq.s Ca1
	move.b d0,(a1)+
	dbra d1,Ca1
Ca2:	clr.b (a1)
	clr.b 1(a1)
	bsr atof
	addq.l #4,sp
	move.l #$12345678,d1
	rte
	
******* FLOAT to ASCII
CFtoa:	cmp.l #$12345678,d2
	beq.s paplant
; Empeche le plantage lors du listing!
	move.l a0,-(sp)
	lea badflo(pc),a1
papl:	move.b (a1)+,(a0)+
	bne.s papl
	move.l a0,d0
	move.l (sp)+,a0
	sub.l a0,d0
	subq.l #1,d0
	rte
; OK, c'est le bon float!
paplant:	movem.l a2/d1-d5,-(sp)
	move.l a0,TempBuf
	move.l d1,TempFl
	tst.w d5		;D5= FIX FLAG
	bne.s PaFix
	tst.w d4
	bmi.s PaFix
; Fix precise NORMAL
	cmp.w #8,d4
	bcs.s Fx1
	moveq #7,d4
Fx1:	move.w d4,-(sp)
	move.l a0,-(sp)
	move.l d1,-(sp)
	bsr ftoa
	lea 10(sp),sp
	tst.w d4		;Si FIX=0, enleve le POINT!
	bne.s Fx2
	cmp.b #".",-1(a0)
	bne.s Fx2
	clr.b -(a0)
Fx2:	sub.l d0,a0
	exg d0,a0
	movem.l (sp)+,a2/d1-d5
	rte
; Representation proportionnelle
PaFix:	move.b d1,d0
	and.b #$7f,d0
	cmp.b #$41,d0
	bcs.s PaF1
	move.w #7,-(sp)
	bra.s PaF5
PaF1:	cmp.b #$31,d0
	bcs.s PaF2
	move.w #7+3,-(sp)
	bra.s PaF5
PaF2:	move.w #16+6,-(sp)	;Si >-1 et <1, demande 16 chiffres!
PaF5:	pea Buffer(pc)
	move.l d1,-(sp)
	bsr ftoa
	lea 10(sp),sp
	move.l d0,a1
	cmp.b #"-",(a1)
	bne.s PaFix1
	addq.l #1,a1
PaFix1:	move.l a1,a0
	cmp.b #"0",(a0)
	beq.s PaFix5
;-----> Chiffre >1
PaFix2:	move.b (a0)+,d0		;Compte AVANT la virgule
	beq.s PaFix3
	cmp.b #$2e,d0
	bne.s PaFix2
PaFix3:	sub.l a1,a0
	tst.w d5
	bne ExFix1
	moveq #7,d0
	cmp.w #8,a0		;Si >7 ---> representation E+
	bcc ExFix1
	sub.w a0,d0
	cmp.b #5,d0
	bcs Clean
	moveq #5,d0
	bra Clean
;-----> Chiffre <1
PaFix5:	addq.l #1,a0
	addq.l #1,a0
	move.l a0,a1
PaFix6:	move.b (a0)+,d0		;Compte le nombre de ZEROS
	beq.s PaFix7
	cmp.b #"0",d0
	beq.s PaFix6
PaFix7:	sub.l a1,a0
	clr.w d0
	cmp.w #16+6,a0		;Est-ce un vrai ZERO?
	bcs.s PaFix8
	move.w #6,a0
	moveq #1,d0
	bra.s PaFix9
PaFix8:	cmp.w #4,a0		;0.0001 ---> Exponantielle
	bcc ExVir1
PaFix9:	tst.w d5
	bne ExVir1	
	addq.w #6,a0
	move.w a0,d0
; Calcule BIEN, et nettoie le chiffre
Clean:	move.w d0,-(sp)
	pea Buffer(pc)
	move.l Tempfl(pc),-(sp)	
	bsr ftoa
	lea 10(sp),sp
	move.l d0,a0
	move.l TempBuf(pc),a1
Cl1:	move.b (a0)+,d0
	beq.s Cl5
	move.b d0,(a1)+
	cmp.b #".",d0
	bne.s Cl1
	lea -1(a1),a2
Cl2:	move.b (a0)+,d0
	beq.s Cl3
	move.b d0,(a1)+
	cmp.b #"0",d0
	beq.s Cl2
	move.l a1,a2		;Dernier non nul
	bra.s Cl2
Cl3:	move.l a2,a1
Cl5:	clr.b (a1)
	move.l Tempbuf(pc),a0
	sub.l a0,a1
	move.l a1,d0
	movem.l (sp)+,a2/d1-d5
	rte

;-----> Representation exponantielle >= 1
ExFix1:	move.w a0,d2
	subq.w #2,d2
	cmp.w #7,a0
	bcs.s Exf0
	move.w #7,a0
Exf0:	moveq #9,d0
	sub.w a0,d0
	move.w d0,-(sp)
	pea buffer(pc)
	move.l TempFl(pc),-(sp)
	bsr ftoa
	lea 10(sp),sp
	
	lea Buffer(pc),a0
	move.l TempBuf(pc),a1
	cmp.b #"-",(a0)
	bne.s Exf0a
	move.b (a0)+,(a1)+
Exf0a:	move.b (a0)+,(a1)+
	move.b #".",(a1)+
	lea -1(a1),a2
	move.w d4,d1
	bpl.s ExF1
	moveq #5,d1
	bra.s ExF2
Exf1:	cmp.w #5,d1
	bcs.s Exf2
	moveq #5,d1
Exf2:	move.b (a0)+,d0
	beq.s Exf2a
	cmp.b #".",d0
	beq.s Exf2
	move.b d0,(a1)+
	subq.w #1,d1
	bne.s Exf2
Exf2a:	clr.b (a1)
	tst.w d4
	bpl.s Exf5
; Enleve les zeros
	lea 1(a2),a0
Exf3:	move.b (a0)+,d0
	beq.s Exf4
	cmp.b #"0",d0
	beq.s Exf3
	move.l a0,a2		;Dernier non nul
	bra.s Exf3
Exf4:	move.l a2,a1
; Rajoute le E+00
Exf5:	move.b #"E",(a1)+
	move.b #"+",(a1)+
	move.b #"0",(a1)+
Exf6:	cmp.b #10,d2
	bcs.s Exf7
	add.b #1,-1(a1)
	sub.w #10,d2
	bra.s Exf6
Exf7:	add.b #"0",d2
	move.b d2,(a1)+
	clr.b (a1)
	move.l TempBuf(pc),a0
	sub.l a0,a1
	move.l a1,d0
	movem.l (sp)+,a2/d1-d5
	rte

;-----> Exponantielle <1
ExVir1:	tst.w d0
	beq.s Exv0
	clr.w d2
	moveq #1,d3
	lea Zero(pc),a0
	bra.s Exv0a

Exv0:	clr.w d3
	move.w a0,d2
	addq.l #6,a0
	move.w a0,-(sp)
	pea buffer(pc)
	move.l TempFl(pc),-(sp)
	bsr ftoa
	lea 10(sp),sp
	lea Buffer(pc),a0

Exv0a:	move.l TempBuf(pc),a1
	cmp.b #"-",(a0)
	bne.s Exv1
	move.b (a0)+,(a1)+
Exv1:	lea 2(a0),a2
Exv2:	move.b (a0)+,d0			;Cherche le debut du chiffre
	beq.s Exv3
	cmp.b #".",d0
	beq.s Exv2
	cmp.b #"0",d0
	beq.s Exv2
	bra.s Exv4
Exv3:	move.l a2,a0
	moveq #"0",d0		 
Exv4:	move.w d4,d1
	bpl.s Exv5
	moveq #6,d1
	bra.s Exv6
Exv5:	cmp.w #6,d1
	bcs.s Exv6
	moveq #6,d1
Exv6:	move.b d0,(a1)+
	move.b #".",(a1)+
	lea -1(a1),a2
	tst.w d1
	beq.s Exv7b
Exv7:	move.b (a0)+,d0
	beq.s Exv7a
	move.b d0,(a1)+ 
	cmp.b #"0",d0
	beq.s Exv7a
	move.l a1,a2
Exv7a	subq.w #1,d1
	bne.s Exv7
Exv7b:	tst.w d4		;Nettoie le chiffre
	bpl.s Exv8
	move.l a2,a1
Exv8:	tst.w d3
	bne Exf5
	move.b #"E",(a1)+
	move.b #"-",(a1)+
	move.b #"0",(a1)+
	bra Exf6	

******* FLOAT to LONG
CFtol:	move.l d1,-(sp)
	bsr ftol
	addq.l #4,sp
	rte

******* LONG to FLOAT
CLtof:	move.l d1,-(sp)
	bsr ltof
	addq.l #4,sp
	move.l #$12345678,d1
	rte

*******	EGAL
CEq:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Comp
	addq.l #8,sp
	beq.s Vrai
Faux:	moveq #0,d0
	rte
Vrai:	moveq #-1,d0
	rte

******* DIFFERENT
CDif:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Comp
	addq.l #8,sp
	bne.s Vrai
	bra.s Faux

******* INFERIEUR
CLt:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Comp
	addq.l #8,sp
	blt.s Vrai
	bra.s Faux

******* INFERIEUR ou EGAL
CLe:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Comp
	addq.l #8,sp
	ble.s Vrai
	bra.s Faux

******* SUPERIEUR
CGt:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Comp
	addq.l #8,sp
	bgt.s Vrai
	bra.s Faux

******* DIFFERENT
CGe:	move.l d3,-(sp)
	move.l d1,-(sp)
	bsr Comp
	addq.l #8,sp
	bge.s Vrai
	bra.s Faux

*******	TANGENTE
CTAN	MOVE.L 	D1,-(SP)
	BSR 	SIN
	MOVE.L 	D0,TEMPFL
	BSR 	COS
	MOVE.L 	D0,(SP)
	MOVE.L 	TEMPFL,-(SP)
	BSR 	DIVI
	ADDQ.L 	#8,SP
	MOVE.L 	#$12345678,D1
	RTE

******* ABS
CABS:	MOVE.L 	D1,D0
	BCLR 	#7,D0
	MOVE.L 	#$12345678,D1
	RTE

******* INT
CINT	MOVE.L	D1,-(SP)
	BSR 	INT
	ADDQ.L 	#4,SP
	MOVE.L 	#$12345678,D1
	RTE

*******	COSINUS
CCOS	MOVE.L 	D1,-(SP)
	BSR 	COS
	ADDQ.L 	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
COS	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	BSR	TB0572
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*******	PUISSANCE
CPUIS	MOVE.L	D3,-(SP)
	MOVE.L	D1,-(SP)
	BSR 	PUIS
	ADDQ.L 	#8,SP
	MOVE.L 	#$12345678,D1
	RTE
PUIS	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	BSR	TB053C
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*******	SINUS
CSIN	MOVE.L 	D1,-(SP)
	BSR 	SIN
	ADDQ.L 	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
SIN	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	BSR	TB0584
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*******	RACINE CARRE
CSQR	MOVE.L	D1,-(SP)
	BSR 	SQR
	ADDQ.L 	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
SQR	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	BSR	TB06EC
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*******	EXPONANTIELLE
CEXP	MOVE.L 	D1,-(SP)
	BSR 	EXP
	ADDQ.L 	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
EXP	LINK	A6,#-4
	MOVEM.L	D7,-(A7)
	MOVE.L	8(A6),D7
	JSR	TB093E
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D7
	UNLK	A6
	RTS

*******	LOGARYTHME NEPERIEN
CLN	MOVE.L 	D1,-(SP)
	BSR 	LN
	ADDQ.L	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
LN	LINK	A6,#-4
	MOVEM.L	D7,-(A7)
	MOVE.L	8(A6),D7
	BSR	TB0A18
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D7
	UNLK	A6
	RTS

******* LOGARITHME DECIMAL
CLOG	MOVE.L	D1,-(SP)
	BSR 	LN
	MOVE.L	#$935D8D42,(SP)
	MOVE.L 	D0,-(SP)
	BSR	DIVI
	ADDQ.L 	#8,SP
	MOVE.L	#$12345678,D1
	RTE

*******	ARCTANGENTE
CATAN	MOVE.L	D1,-(SP)
	BSR 	ATAN
	ADDQ.L 	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
ATAN	LINK	A6,#-4
	MOVE.L	D7,-(A7)
	MOVE.L	8(A6),D7
	JSR	TB03D4
	MOVE.L	D7,D0
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS

******* ARC SINUS
CASIN	BSR 	ASIN
	MOVE.L	#$12345678,D1
	RTE
ASIN	MOVE.L 	D1,D7
	MOVE.L 	D1,-(SP)
	MOVE.L 	D1,-(SP)
	BSR 	MULT
	ADDQ.L 	#8,SP
	BCHG	#7,D0
	MOVE.L	D0,-(SP)
	MOVE.L 	#$80000041,-(SP)
	BSR 	PLUS
	ADDQ.L 	#8,SP
	BTST	#7,D0
	BNE	CAS 	
	MOVE.L 	D0,-(SP)
	MOVE.L 	D7,-(SP)
	BSR 	DIVI
	ADDQ.L 	#8,SP
	MOVE.L	D0,-(SP)
	BSR	ATAN
	ADDQ.L	#4,SP
	RTS
CAS	MOVEQ	#$0,D0
	RTS

******* ARC COSINUS
CACOS	BSR 	ASIN
	MOVE.L	D0,-(SP)
	MOVE.L	#$C90FD941,-(SP)
	BSR 	MOINS
	ADDQ.L 	#8,SP
	MOVE.L 	#$12345678,D1
	RTE

*******	SINUS HYPERBOLIQUE
CSINH	MOVE.L	D1,-(SP)
	BSR 	SINH
	ADDQ.L 	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
SINH	LINK	A6,#-4
	MOVE.L	D7,-(A7)
	MOVE.L	8(A6),D7
	BSR	TB049A
	MOVE.L	D7,D0
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS

******* COSINUS HYPERBOLIQUE
CCOSH	MOVE.L 	D1,-(SP)
	BSR 	EXP
	MOVE.L 	D0,TEMPFL
	MOVE.L	(SP),D0	
	BCHG	#7,D0
	MOVE.L 	D0,(SP)
	BSR	EXP
	MOVE.L	D0,(SP)
	MOVE.L	TEMPFL,-(SP)
	BSR	PLUS
	ADDQ.L	#8,SP
	MOVE.L 	#$80000042,-(SP)
	MOVE.L	D0,-(SP)
	BSR 	DIVI
	ADDQ.L 	#8,SP
	MOVE.L 	#$12345678,D1
	RTE

*******	TANGENTE HYPERBOLIQUE
CTANH	MOVE.L 	D1,-(SP)
	BSR 	TANH
	ADDQ.L	#4,SP
	MOVE.L 	#$12345678,D1
	RTE
TANH	LINK	A6,#-4
	MOVE.L	D7,-(A7)
	MOVE.L	8(A6),D7
	BSR	TB04D4
	MOVE.L	D7,D0
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS

*****************************************************************
*	CONVERSION FLOAT ---> ASCII
************************************
ftoa	LINK	A6,#-8
	MOVEM.L	D3-d7,-(A7)
	MOVE.L	$C(A6),-4(A6)
	TST.W	$10(A6)
	BGT.S	L27CDA
	MOVEQ	#1,D0
	BRA.S	L27CEC
L27CDA	CMPI.W	#$16,$10(A6)
	BLE.S	L27CE6
	MOVEQ	#$17,D0
	BRA.S	L27CEC
L27CE6	MOVE.W	$10(A6),D0
	ADDQ.W	#1,D0
L27CEC	MOVE.W	D0,D4
	CLR.W	D7
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L27D1C
	MOVEA.L	$C(A6),A0
	MOVE.B	#$2D,(A0)
	ADDQ.L	#1,$C(A6)
	MOVE.L	8(A6),-(A7)
	JSR	L283A8
	ADDQ.L	#4,A7
	MOVE.L	D0,8(A6)
L27D1C	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLE.S	L27D5A
	BRA.S	L27D46
L27D2E	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	SUBQ.W	#1,D7
L27D46	MOVE.L	#$80000041,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLT.S	L27D2E
L27D5A	BRA.S	L27D74
L27D5C	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	ADDQ.W	#1,D7
L27D74	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L27D5C
	ADD.W	D7,D4
	MOVEQ	#1,D6
	MOVE.W	D6,D0
	EXT.L	D0
	MOVE.L	D0,-(A7)
	JSR	L28270
	ADDQ.L	#4,A7
	MOVE.L	D0,-8(A6)
	BRA.S	L27DB8
L27DA0	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,-8(A6)
	ADDQ.W	#1,D6
L27DB8	CMP.W	D4,D6
	BLT.S	L27DA0
	MOVE.L	#$80000042,-(A7)
	MOVE.L	-8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28212
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLT.S	L27DFE
	MOVE.L	#$80000041,8(A6)
	ADDQ.W	#1,D7
L27DFE	TST.W	D7
	BGE.S	L27E36
	MOVEA.L	$C(A6),A0
	MOVE.B	#$30,(A0)
	ADDQ.L	#1,$C(A6)
	MOVEA.L	$C(A6),A0
	MOVE.B	#$2E,(A0)
	ADDQ.L	#1,$C(A6)
	TST.W	D4
	BGE.S	L27E20
	SUB.W	D4,D7
L27E20	MOVEQ	#-1,D6
	BRA.S	L27E32
L27E24	MOVEA.L	$C(A6),A0
	MOVE.B	#$30,(A0)
	ADDQ.L	#1,$C(A6)
	SUBQ.W	#1,D6
L27E32	CMP.W	D7,D6
	BGT.S	L27E24
L27E36	CLR.W	D6
	BRA.S	L27EA4
L27E3A	MOVE.L	8(A6),-(A7)
	JSR	L28300
	ADDQ.L	#4,A7
	MOVE.W	D0,D5
	MOVE.W	D5,D0
	ADD.W	#$30,D0
	MOVEA.L	$C(A6),A1
	MOVE.B	D0,(A1)
	ADDQ.L	#1,$C(A6)
	CMP.W	D7,D6
	BNE.S	L27E68
	MOVEA.L	$C(A6),A0
	MOVE.B	#$2E,(A0)
	ADDQ.L	#1,$C(A6)
L27E68	MOVE.W	D5,D0
	EXT.L	D0
	MOVE.L	D0,-(A7)
	JSR	L28270
	ADDQ.L	#4,A7
	MOVE.L	D0,-8(A6)
	MOVE.L	D0,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L283C4
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	MOVE.L	#$A0000044,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	ADDQ.W	#1,D6
L27EA4	CMP.W	D4,D6
	BLT.S	L27E3A
	MOVEA.L	$C(A6),A0
	CLR.B	(A0)
	ADDQ.L	#1,$C(A6)
	MOVE.L	-4(A6),D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS

******************************************************************
*	Conversion ASCII---> FLOAT
***********************************
Atof	LINK	A6,#-$2E
	MOVEM.L	D7/A4-A5,-(A7)
	LEA	-$14(A6),A5
	LEA	-$18(A6),A4
	CLR.W	-$1E(A6)
	CLR.W	-$26(A6)
	BRA.S	L27EDE
L27EDA	ADDQ.L	#1,8(A6)
L27EDE	MOVEA.L	8(A6),A0
	CMPI.B	#$20,(A0)
	BEQ.S	L27EDA
	MOVEA.L	8(A6),A0
	CMPI.B	#9,(A0)
	BEQ.S	L27EDA
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27F00
	CLR.W	D0
	BRA.S	L27F02
L27F00	MOVEQ	#1,D0
L27F02	MOVE.W	D0,-$22(A6)
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27F1A
	MOVEA.L	8(A6),A0
	CMPI.B	#$2B,(A0)
	BNE.S	L27F1E
L27F1A	ADDQ.L	#1,8(A6)
L27F1E	BRA.S	L27F44
L27F20	MOVEA.L	8(A6),A0
	CMPI.B	#$2E,(A0)
	BNE.S	L27F30
	ADDQ.W	#1,-$1E(A6)
	BRA.S	L27F40
L27F30	MOVEA.L	8(A6),A0
	MOVE.B	(A0),(A5)+
	TST.W	-$1E(A6)
	BEQ.S	L27F40
	ADDQ.W	#1,-$26(A6)
L27F40	ADDQ.L	#1,8(A6)
L27F44	MOVEA.L	8(A6),A0
	TST.B	(A0)
	BEQ.S	L27F60
	MOVEA.L	8(A6),A0
	CMPI.B	#$65,(A0)
	BEQ.S	L27F60
	MOVEA.L	8(A6),A0
	CMPI.B	#$45,(A0)
	BNE.S	L27F20
L27F60	CLR.B	(A5)
	MOVEA.L	8(A6),A0
	CMPI.B	#$65,(A0)
	BEQ.S	L27F76
	MOVEA.L	8(A6),A0
	CMPI.B	#$45,(A0)
	BNE.S	L27FBA
L27F76	ADDQ.L	#1,8(A6)
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27F88
	CLR.W	D0
	BRA.S	L27F8A
L27F88	MOVEQ	#1,D0
L27F8A	MOVE.W	D0,-$20(A6)
	MOVEA.L	8(A6),A0
	CMPI.B	#$2D,(A0)
	BEQ.S	L27FA2
	MOVEA.L	8(A6),A0
	CMPI.B	#$2B,(A0)
	BNE.S	L27FA6
L27FA2	ADDQ.L	#1,8(A6)
L27FA6	BRA.S	L27FB2
L27FA8	MOVEA.L	8(A6),A0
	MOVE.B	(A0),(A4)+
	ADDQ.L	#1,8(A6)
L27FB2	MOVEA.L	8(A6),A0
	TST.B	(A0)
	BNE.S	L27FA8
L27FBA	CLR.B	(A4)
	MOVE.L	A6,(A7)
	ADDI.L	#$FFFFFFEC,(A7)
	BSR	L280A8
	MOVE.L	D0,-$2A(A6)
	MOVE.L	A6,(A7)
	ADDI.L	#$FFFFFFE8,(A7)
	JSR	L28654
	MOVE.W	D0,-$24(A6)
	TST.W	-$20(A6)
	BEQ.S	L27FF0
	MOVE.W	-$24(A6),D0
	NEG.W	D0
	SUB.W	-$26(A6),D0
	BRA.S	L27FF8
L27FF0	MOVE.W	-$24(A6),D0
	SUB.W	-$26(A6),D0
L27FF8	MOVE.W	D0,-$26(A6)
	MOVE.L	-$2A(A6),-(A7)
	MOVE.W	-$26(A6),-(A7)
	BSR.S	L28040
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,-$2E(A6)
	MOVE.L	-$2E(A6),(A7)
	JSR	L28116
	MOVE.L	D0,-$1C(A6)
	TST.W	-$22(A6)
	BEQ.S	L28032
	ORI.L	#$80,-$1C(A6)
L28032	MOVE.L	-$1C(A6),D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,A4-A5
	UNLK	A6
	RTS
L28040	LINK	A6,#-8
	TST.W	8(A6)
	BGE.S	L28076
	MOVE.L	#$80000041,-4(A6)
	BRA.S	L2806E
L28054	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	ADDQ.W	#1,8(A6)
L2806E	TST.W	8(A6)
	BLT.S	L28054
	BRA.S	L280A0
L28076	MOVE.L	#$80000041,-4(A6)
	BRA.S	L2809A
L28080	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	SUBQ.W	#1,8(A6)
L2809A	TST.W	8(A6)
	BGT.S	L28080
L280A0	MOVE.L	-4(A6),D0
	UNLK	A6
	RTS
L280A8	LINK	A6,#-8
	MOVE.L	#0,-4(A6)
	BRA.S	L280FA
L280B6	MOVE.L	#$A0000044,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	MOVE.L	-4(A6),-(A7)
	MOVEA.L	8(A6),A0
	MOVE.B	(A0),D0
	EXT.W	D0
	ADD.W	#$FFD0,D0
	EXT.L	D0
	MOVE.L	D0,-(A7)
	JSR	L28270
	ADDQ.L	#4,A7
	MOVE.L	D0,-(A7)
	JSR	L28212
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
	ADDQ.L	#1,8(A6)
L280FA	MOVEA.L	8(A6),A0
	CMPI.B	#$30,(A0)
	BLT.S	L2810E
	MOVEA.L	8(A6),A0
	CMPI.B	#$39,(A0)
	BLE.S	L280B6
L2810E	MOVE.L	-4(A6),D0
	UNLK	A6
	RTS
L28116	LINK	A6,#-4
	MOVEM.L	D4-D7,-(A7)
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BNE.S	L28134
	CLR.L	D0
	BRA	L28208
L28134	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L28158
	MOVE.L	8(A6),-(A7)
	JSR	L283A8
	ADDQ.L	#4,A7
	MOVE.L	D0,8(A6)
	MOVEQ	#1,D5
	BRA.S	L2815A
L28158	CLR.W	D5
L2815A	CLR.W	D7
	BRA.S	L28176
L2815E	ADDQ.W	#1,D7
	MOVE.L	#$80000042,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28250
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
L28176	MOVE.L	#$80000041,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BGE.S	L2815E
	BRA.S	L281A4
L2818C	SUBQ.W	#1,D7
	MOVE.L	#$80000042,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
L281A4	MOVE.L	#$80000040,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28232
	ADDQ.L	#8,A7
	BLT.S	L2818C
	MOVE.L	#$80000059,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	L28388
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
	MOVE.L	8(A6),-(A7)
	JSR	L28300
	ADDQ.L	#4,A7
	MOVE.L	D0,-4(A6)
	MOVE.L	-4(A6),D0
	ASL.L	#8,D0
	MOVE.L	D0,-4(A6)
	ADD.W	#$40,D7
	MOVE.W	D7,D0
	AND.W	#$7F,D0
	EXT.L	D0
	OR.L	D0,-4(A6)
	TST.W	D5
	BEQ.S	L28204
	ORI.L	#$80,-4(A6)
L28204	MOVE.L	-4(A6),D0
L28208	TST.L	(A7)+
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L28212	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L28422
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L28232	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L283E4
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L28250	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L28518
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L28270	LINK	A6,#0
	MOVEM.L	D5-D7,-(A7)
	TST.L	8(A6)
	BGE.S	L2828C
	MOVEQ	#1,D6
	MOVE.L	8(A6),D0
	NEG.L	D0
	MOVE.L	D0,8(A6)
	BRA.S	L2828E
L2828C	CLR.W	D6
L2828E	TST.L	8(A6)
	BNE.S	L28298
	CLR.L	D0
	BRA.S	L282F6
L28298	MOVEQ	#$18,D7
	BRA.S	L282A8
L2829C	MOVE.L	8(A6),D0
	ASR.L	#1,D0
	MOVE.L	D0,8(A6)
	ADDQ.L	#1,D7
L282A8	MOVE.L	8(A6),D0
	AND.L	#$7F000000,D0
	BNE.S	L2829C
	BRA.S	L282C2
L282B6	MOVE.L	8(A6),D0
	ASL.L	#1,D0
	MOVE.L	D0,8(A6)
	SUBQ.L	#1,D7
L282C2	BTST	#7,9(A6)
	BEQ.S	L282B6
	MOVE.L	8(A6),D0
	ASL.L	#8,D0
	MOVE.L	D0,8(A6)
	ADD.L	#$40,D7
	MOVE.L	D7,D0
	AND.L	#$7F,D0
	OR.L	D0,8(A6)
	TST.W	D6
	BEQ.S	L282F2
	ORI.L	#$80,8(A6)
L282F2	MOVE.L	8(A6),D0
L282F6	TST.L	(A7)+
	MOVEM.L	(A7)+,D6-D7
	UNLK	A6
	RTS
L28300	LINK	A6,#0
	MOVEM.L	D4-D7,-(A7)
	MOVE.L	8(A6),D0
	AND.L	#$7F,D0
	ADD.L	#$FFFFFFC0,D0
	MOVE.W	D0,D6
	TST.L	8(A6)
	BEQ.S	L28324
	TST.W	D6
	BGE.S	L28328
L28324	CLR.L	D0
	BRA.S	L2837E
L28328	MOVE.L	8(A6),D0
	AND.L	#$80,D0
	MOVE.W	D0,D5
	CMP.W	#$1F,D6
	BLE.S	L2834E
	TST.W	D5
	BEQ.S	L28346
	MOVE.L	#$80000000,D0
	BRA.S	L2834C
L28346	MOVE.L	#$7FFFFFFF,D0
L2834C	BRA.S	L2837E
L2834E	MOVE.L	8(A6),D7
	ASR.L	#8,D7
	AND.L	#$FFFFFF,D7
	SUB.W	#$18,D6
	BRA.S	L28364
L28360	ASR.L	#1,D7
	ADDQ.W	#1,D6
L28364	TST.W	D6
	BLT.S	L28360
	BRA.S	L2836E
L2836A	ASL.L	#1,D7
	SUBQ.W	#1,D6
L2836E	TST.W	D6
	BGT.S	L2836A
	TST.W	D5
	BEQ.S	L2837C
	MOVE.L	D7,D0
	NEG.L	D0
	MOVE.L	D0,D7
L2837C	MOVE.L	D7,D0
L2837E	TST.L	(A7)+
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L28388	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L2858A
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L283A8	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	JSR	L28406
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L283C4	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	L28410
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
L283E4	TST.B	D6
	BPL.S	L283F4
	TST.B	D7
	BPL.S	L283F4
	CMP.B	D7,D6
	BNE.S	L283FA
	CMP.L	D7,D6
	RTS
L283F4	CMP.B	D6,D7
	BNE.S	L283FA
	CMP.L	D6,D7
L283FA	RTS
	TST.B	D7
	RTS
	AND.B	#$7F,D7
	RTS
L28406	TST.B	D7
	BEQ.S	L2840E
	EORI.B	#$80,D7
L2840E	RTS
L28410	MOVE.B	D6,D4
	BEQ.S	L28466
	EORI.B	#$80,D4
	BMI.S	L28484
	MOVE.B	D7,D5
	BMI.S	L2848A
	BNE.S	L2842E
	BRA.S	L28460
L28422	MOVE.B	D6,D4
	BMI.S	L28484
	BEQ.S	L28466
	MOVE.B	D7,D5
	BMI.S	L2848A
	BEQ.S	L28460
L2842E	SUB.B	D4,D5
	BMI.S	L2846A
	MOVE.B	D7,D4
	CMP.B	#$18,D5
	BCC.S	L28466
	MOVE.L	D6,D3
	CLR.B	D3
	LSR.L	D5,D3
	MOVE.B	#$80,D7
	ADD.L	D3,D7
	BCS.S	L2844C
L28448	MOVE.B	D4,D7
	RTS
L2844C	ROXR.L	#1,D7
	ADDQ.B	#1,D4
	BVS.S	L28454
	BCC.S	L28448
L28454	MOVEQ	#-1,D7
	SUBQ.B	#1,D4
	MOVE.B	D4,D7
	ORI.B	#2,CCR
	RTS
L28460	MOVE.L	D6,D7
	MOVE.B	D4,D7
	RTS
L28466	TST.B	D7
	RTS
L2846A	CMP.B	#$E8,D5
	BLE.S	L28460
	NEG.B	D5
	MOVE.L	D6,D3
	CLR.B	D7
	LSR.L	D5,D7
	MOVE.B	#$80,D3
	ADD.L	D3,D7
	BCS.S	L2844C
	MOVE.B	D4,D7
	RTS
L28484	MOVE.B	D7,D5
	BMI.S	L2842E
	BEQ.S	L28460
L2848A	MOVEQ	#-$80,D3
	EOR.B	D3,D5
	SUB.B	D4,D5
	BEQ.S	L284E2
	BMI.S	L284D0
	CMP.B	#$18,D5
	BCC.S	L28466
	MOVE.B	D7,D4
	MOVE.B	D3,D7
	MOVE.L	D6,D3
L284A0	CLR.B	D3
	LSR.L	D5,D3
	SUB.L	D3,D7
	BMI.S	L28448
L284A8	MOVE.B	D4,D5
L284AA	CLR.B	D7
	SUBQ.B	#1,D4
	CMP.L	#$7FFF,D7
	BHI.S	L284BC
	SWAP	D7
	SUB.B	#$10,D4
L284BC	ADD.L	D7,D7
	DBMI	D4,L284BC
	EOR.B	D4,D5
	BMI.S	L284CC
	MOVE.B	D4,D7
	BEQ.S	L284CC
	RTS
L284CC	MOVEQ	#0,D7
	RTS
L284D0	CMP.B	#$E8,D5
	BLE.S	L28460
	NEG.B	D5
	MOVE.L	D7,D3
	MOVE.L	D6,D7
	MOVE.B	#$80,D7
	BRA.S	L284A0
L284E2	MOVE.B	D7,D5
	EXG	D5,D4
	MOVE.B	D6,D7
	SUB.L	D6,D7
	BEQ.S	L284CC
	BPL.S	L284A8
	NEG.L	D7
	MOVE.B	D5,D4
	BRA.S	L284AA
L284F4	DIVU	#0,D7
	TST.L	D6
	BNE.S	L28518
L284FC	OR.L	#$FFFFFF7F,D7
	TST.B	D7
	ORI.B	#2,CCR
L28508	RTS
L2850A	SWAP	D6
	SWAP	D7
L2850E	EOR.B	D6,D7
	BRA.S	L284FC
L28512	BMI.S	L2850E
L28514	MOVEQ	#0,D7
	RTS
L28518	MOVE.B	D6,D5
	BEQ.S	L284F4
	MOVE.L	D7,D4
	BEQ.S	L28508
	MOVEQ	#-$80,D3
	ADD.W	D5,D5
	ADD.W	D4,D4
	EOR.B	D3,D5
	EOR.B	D3,D4
	SUB.B	D5,D4
	BVS.S	L28512
	CLR.B	D7
	SWAP	D7
	SWAP	D6
	CMP.W	D6,D7
	BMI.S	L2853E
	ADDQ.B	#2,D4
	BVS.S	L2850A
	ROR.L	#1,D7
L2853E	SWAP	D7
	MOVE.B	D3,D5
	EOR.W	D5,D4
	LSR.W	#1,D4
	MOVE.L	D7,D3
	DIVU	D6,D3
	MOVE.W	D3,D5
	MULU	D6,D3
	SUB.L	D3,D7
	SWAP	D7
	SWAP	D6
	MOVE.W	D6,D3
	CLR.B	D3
	MULU	D5,D3
	SUB.L	D3,D7
	BCC.S	L28566
	MOVE.L	D6,D3
	CLR.B	D3
	ADD.L	D3,D7
	SUBQ.W	#1,D5
L28566	MOVE.L	D6,D3
	SWAP	D3
	CLR.W	D7
	DIVU	D3,D7
	SWAP	D5
	BMI.S	L2857A
	MOVE.W	D7,D5
	ADD.L	D5,D5
	SUBQ.B	#1,D4
	MOVE.W	D5,D7
L2857A	MOVE.W	D7,D5
	ADD.L	#$80,D5
	MOVE.L	D5,D7
	MOVE.B	D4,D7
	BEQ.S	L28514
	RTS
L2858A	MOVE.B	D7,D5
	BEQ.S	L285E0
	MOVE.B	D6,D4
	BEQ.S	L285FA
	ADD.W	D5,D5
	ADD.W	D4,D4
	MOVEQ	#-$80,D3
	EOR.B	D3,D4
	EOR.B	D3,D5
	ADD.B	D4,D5
	BVS.S	L285FE
	MOVE.B	D3,D4
	EOR.W	D4,D5
	ROR.W	#1,D5
	SWAP	D5
	MOVE.W	D6,D5
	CLR.B	D7
	CLR.B	D5
	MOVE.W	D5,D4
	MULU	D7,D4
	SWAP	D4
	MOVE.L	D7,D3
	SWAP	D3
	MULU	D5,D3
	ADD.L	D3,D4
	SWAP	D6
	MOVE.L	D6,D3
	MULU	D7,D3
	ADD.L	D3,D4
	CLR.W	D4
	ADDX.B	D4,D4
	SWAP	D4
	SWAP	D7
	MULU	D6,D7
	SWAP	D6
	SWAP	D5
	ADD.L	D4,D7
	BPL.S	L285E2
	ADD.L	#$80,D7
	MOVE.B	D5,D7
	BEQ.S	L285FA
L285E0	RTS
L285E2	SUBQ.B	#1,D5
	BVS.S	L285FA
	BCS.S	L285FA
	MOVEQ	#$40,D4
	ADD.L	D4,D7
	ADD.L	D7,D7
	BCC.S	L285F4
	ROXR.L	#1,D7
	ADDQ.B	#1,D5
L285F4	MOVE.B	D5,D7
	BEQ.S	L285FA
	RTS
L285FA	MOVEQ	#0,D7
	RTS
L285FE	BPL.S	L285FA
	EOR.B	D6,D7
	OR.L	#$FFFFFF7F,D7
	TST.B	D7
	ORI.B	#2,CCR
	RTS

L28654	LINK	A6,#0
	MOVEM.L	D5-D7/A5,-(A7)
	MOVEA.L	8(A6),A5
	CLR.W	D7
	CLR.W	D6
	BRA.S	L28668
L28666	ADDQ.L	#1,A5
L28668	MOVE.B	(A5),D0
	EXT.W	D0
	EXT.L	D0
	ADD.L	#0,D0
	MOVEA.L	D0,A0
;	BTST	#5,(A0)
;	BNE.S	L28666
	CMPI.B	#$2B,(A5)
	BNE.S	L28686
	ADDQ.L	#1,A5
	BRA.S	L28690
L28686	CMPI.B	#$2D,(A5)
	BNE.S	L28690
	ADDQ.L	#1,A5
	ADDQ.W	#1,D6
L28690	BRA.S	L286A0
L28692	MULS	#$A,D7
	MOVE.B	(A5)+,D0
	EXT.W	D0
L2869A	ADD.W	D0,D7
L2869C	ADD.W	#$FFD0,D7
L286A0	CMPI.B	#$30,(A5)
L286A4	BLT.S	L286AC
	CMPI.B	#$39,(A5)
	BLE.S	L28692
L286AC	TST.W	D6
	BEQ.S	L286B6
	MOVE.W	D7,D0
	NEG.W	D0
	MOVE.W	D0,D7
L286B6	MOVE.W	D7,D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,D6-D7/A5
	UNLK	A6
	RTS

*********************************************************
*	LONG TO FLOAT
*********************
LTOF:	LINK	A6,#0
	MOVEM.L	D5-D7,-(A7)
	TST.L	8(A6)
	BGE.S	LAFFF0
	MOVEQ	#1,D6
	MOVE.L	8(A6),D0
	NEG.L	D0
	MOVE.L	D0,8(A6)
	BRA.S	LAFFF2
LAFFF0	CLR.W	D6
LAFFF2	TST.L	8(A6)
	BNE.S	LAFFFC
	CLR.L	D0
	BRA.S	LB005A
LAFFFC	MOVEQ	#$18,D7
	BRA.S	LB000C
LB0000	MOVE.L	8(A6),D0
	ASR.L	#1,D0
	MOVE.L	D0,8(A6)
	ADDQ.L	#1,D7
LB000C	MOVE.L	8(A6),D0
	AND.L	#$7F000000,D0
	BNE.S	LB0000
	BRA.S	LB0026
LB001A	MOVE.L	8(A6),D0
	ASL.L	#1,D0
	MOVE.L	D0,8(A6)
	SUBQ.L	#1,D7
LB0026	BTST	#7,9(A6)
	BEQ.S	LB001A
	MOVE.L	8(A6),D0
	ASL.L	#8,D0
	MOVE.L	D0,8(A6)
	ADD.L	#$40,D7
	MOVE.L	D7,D0
	AND.L	#$7F,D0
	OR.L	D0,8(A6)
	TST.W	D6
	BEQ.S	LB0056
	ORI.L	#$80,8(A6)
LB0056	MOVE.L	8(A6),D0
LB005A	TST.L	(A7)+
	MOVEM.L	(A7)+,D6-D7
	UNLK	A6
	RTS

************************************************************
*	FLOAT TO LONG
************************
FTOL	LINK	A6,#0
	MOVEM.L	D4-D7,-(A7)
	MOVE.L	8(A6),D0
	AND.L	#$7F,D0
	ADD.L	#$FFFFFFC0,D0
	MOVE.W	D0,D6
	TST.L	8(A6)
	BEQ.S	LB0088
	TST.W	D6
	BGE.S	LB008C
LB0088	CLR.L	D0
	BRA.S	LB00E2
LB008C	MOVE.L	8(A6),D0
	AND.L	#$80,D0
	MOVE.W	D0,D5
	CMP.W	#$1F,D6
	BLE.S	LB00B2
	TST.W	D5
	BEQ.S	LB00AA
	MOVE.L	#$80000000,D0
	BRA.S	LB00B0
LB00AA	MOVE.L	#$7FFFFFFF,D0
LB00B0	BRA.S	LB00E2
LB00B2	MOVE.L	8(A6),D7
	ASR.L	#8,D7
	AND.L	#$FFFFFF,D7
	SUB.W	#$18,D6
	BRA.S	LB00C8
LB00C4	ASR.L	#1,D7
	ADDQ.W	#1,D6
LB00C8	TST.W	D6
	BLT.S	LB00C4
	BRA.S	LB00D2
LB00CE	ASL.L	#1,D7
	SUBQ.W	#1,D6
LB00D2	TST.W	D6
	BGT.S	LB00CE
	TST.W	D5
	BEQ.S	LB00E0
	MOVE.L	D7,D0
	NEG.L	D0
	MOVE.L	D0,D7
LB00E0	MOVE.L	D7,D0
LB00E2	TST.L	(A7)+
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS



*************************************************************
*	ADDITION FLOAT
***********************
Plus	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	CB018C
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*************************************************************
*	COMPARAISON FLOAT
**************************
Comp	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	CB015E
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*************************************************************
*	DIVISION FLOAT
***********************
Divi	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	CB0282
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*************************************************************
*	MULTIPLICATION FLOAT
*****************************
Mult	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	CB02F4
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

*************************************************************
*	SOUSTRACTION FLOAT
***************************
Moins	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	CB017A
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

CB015E	TST.B	D6
	BPL.S	CB016E
	TST.B	D7
	BPL.S	CB016E
	CMP.B	D7,D6
	BNE.S	CB0174
	CMP.L	D7,D6
	RTS
CB016E	CMP.B	D6,D7
	BNE.S	CB0174
	CMP.L	D6,D7
CB0174	RTS
	TST.B	D7
	RTS
CB017A	MOVE.B	D6,D4
	BEQ.S	CB01D0
	EORI.B	#$80,D4
	BMI.S	CB01EE
	MOVE.B	D7,D5
	BMI.S	CB01F4
	BNE.S	CB0198
	BRA.S	CB01CA
CB018C	MOVE.B	D6,D4
	BMI.S	CB01EE
	BEQ.S	CB01D0
	MOVE.B	D7,D5
	BMI.S	CB01F4
	BEQ.S	CB01CA
CB0198	SUB.B	D4,D5
	BMI.S	CB01D4
	MOVE.B	D7,D4
	CMP.B	#$18,D5
	BCC.S	CB01D0
	MOVE.L	D6,D3
	CLR.B	D3
	LSR.L	D5,D3
	MOVE.B	#$80,D7
	ADD.L	D3,D7
	BCS.S	CB01B6
CB01B2	MOVE.B	D4,D7
	RTS
CB01B6	ROXR.L	#1,D7
	ADDQ.B	#1,D4
	BVS.S	CB01BE
	BCC.S	CB01B2
CB01BE	MOVEQ	#-1,D7
	SUBQ.B	#1,D4
	MOVE.B	D4,D7
	ORI.B	#2,CCR
	RTS
CB01CA	MOVE.L	D6,D7
	MOVE.B	D4,D7
	RTS
CB01D0	TST.B	D7
	RTS
CB01D4	CMP.B	#$E8,D5
	BLE.S	CB01CA
	NEG.B	D5
	MOVE.L	D6,D3
	CLR.B	D7
	LSR.L	D5,D7
	MOVE.B	#$80,D3
	ADD.L	D3,D7
	BCS.S	CB01B6
	MOVE.B	D4,D7
	RTS
CB01EE	MOVE.B	D7,D5
	BMI.S	CB0198
	BEQ.S	CB01CA
CB01F4	MOVEQ	#-$80,D3
	EOR.B	D3,D5
	SUB.B	D4,D5
	BEQ.S	CB024C
	BMI.S	CB023A
	CMP.B	#$18,D5
	BCC.S	CB01D0
	MOVE.B	D7,D4
	MOVE.B	D3,D7
	MOVE.L	D6,D3
CB020A	CLR.B	D3
	LSR.L	D5,D3
	SUB.L	D3,D7
	BMI.S	CB01B2
CB0212	MOVE.B	D4,D5
CB0214	CLR.B	D7
	SUBQ.B	#1,D4
	CMP.L	#$7FFF,D7
	BHI.S	CB0226
	SWAP	D7
	SUB.B	#$10,D4
CB0226	ADD.L	D7,D7
	DBMI	D4,CB0226
	EOR.B	D4,D5
	BMI.S	CB0236
	MOVE.B	D4,D7
	BEQ.S	CB0236
	RTS
CB0236	MOVEQ	#0,D7
	RTS
CB023A	CMP.B	#$E8,D5
	BLE.S	CB01CA
	NEG.B	D5
	MOVE.L	D7,D3
	MOVE.L	D6,D7
	MOVE.B	#$80,D7
	BRA.S	CB020A
CB024C	MOVE.B	D7,D5
	EXG	D5,D4
	MOVE.B	D6,D7
	SUB.L	D6,D7
	BEQ.S	CB0236
	BPL.S	CB0212
	NEG.L	D7
	MOVE.B	D5,D4
	BRA.S	CB0214
CB025E	DIVU	#0,D7
	TST.L	D6
	BNE.S	CB0282
CB0266	OR.L	#$FFFFFF7F,D7
	TST.B	D7
	ORI.B	#2,CCR
CB0272	RTS
CB0274	SWAP	D6
	SWAP	D7
CB0278	EOR.B	D6,D7
	BRA.S	CB0266
CB027C	BMI.S	CB0278
CB027E	MOVEQ	#0,D7
	RTS
CB0282	MOVE.B	D6,D5
	BEQ.S	CB025E
	MOVE.L	D7,D4
	BEQ.S	CB0272
	MOVEQ	#-$80,D3
	ADD.W	D5,D5
	ADD.W	D4,D4
	EOR.B	D3,D5
	EOR.B	D3,D4
	SUB.B	D5,D4
	BVS.S	CB027C
	CLR.B	D7
	SWAP	D7
	SWAP	D6
	CMP.W	D6,D7
	BMI.S	CB02A8
	ADDQ.B	#2,D4
	BVS.S	CB0274
	ROR.L	#1,D7
CB02A8	SWAP	D7
	MOVE.B	D3,D5
	EOR.W	D5,D4
	LSR.W	#1,D4
	MOVE.L	D7,D3
	DIVU	D6,D3
	MOVE.W	D3,D5
	MULU	D6,D3
	SUB.L	D3,D7
	SWAP	D7
	SWAP	D6
	MOVE.W	D6,D3
	CLR.B	D3
	MULU	D5,D3
	SUB.L	D3,D7
	BCC.S	CB02D0
	MOVE.L	D6,D3
	CLR.B	D3
	ADD.L	D3,D7
	SUBQ.W	#1,D5
CB02D0	MOVE.L	D6,D3
	SWAP	D3
	CLR.W	D7
	DIVU	D3,D7
	SWAP	D5
	BMI.S	CB02E4
	MOVE.W	D7,D5
	ADD.L	D5,D5
	SUBQ.B	#1,D4
	MOVE.W	D5,D7
CB02E4	MOVE.W	D7,D5
	ADD.L	#$80,D5
	MOVE.L	D5,D7
	MOVE.B	D4,D7
	BEQ.S	CB027E
	RTS
CB02F4	MOVE.B	D7,D5
	BEQ.S	CB034A
	MOVE.B	D6,D4
	BEQ.S	CB0364
	ADD.W	D5,D5
	ADD.W	D4,D4
	MOVEQ	#-$80,D3
	EOR.B	D3,D4
	EOR.B	D3,D5
	ADD.B	D4,D5
	BVS.S	CB0368
	MOVE.B	D3,D4
	EOR.W	D4,D5
	ROR.W	#1,D5
	SWAP	D5
	MOVE.W	D6,D5
	CLR.B	D7
	CLR.B	D5
	MOVE.W	D5,D4
	MULU	D7,D4
	SWAP	D4
	MOVE.L	D7,D3
	SWAP	D3
	MULU	D5,D3
	ADD.L	D3,D4
	SWAP	D6
	MOVE.L	D6,D3
	MULU	D7,D3
	ADD.L	D3,D4
	CLR.W	D4
	ADDX.B	D4,D4
	SWAP	D4
	SWAP	D7
	MULU	D6,D7
	SWAP	D6
	SWAP	D5
	ADD.L	D4,D7
	BPL.S	CB034C
	ADD.L	#$80,D7
	MOVE.B	D5,D7
	BEQ.S	CB0364
CB034A	RTS
CB034C	SUBQ.B	#1,D5
	BVS.S	CB0364
	BCS.S	CB0364
	MOVEQ	#$40,D4
	ADD.L	D4,D7
	ADD.L	D7,D7
	BCC.S	CB035E
	ROXR.L	#1,D7
	ADDQ.B	#1,D5
CB035E	MOVE.B	D5,D7
	BEQ.S	CB0364
	RTS
CB0364	MOVEQ	#0,D7
	RTS
CB0368	BPL.S 	CB0364
	EOR.B	D6,D7
	OR.L	#$FFFFFF7F,D7
	TST.B 	D7
	ORI.B	#2,CCR
	RTS

	even
FinPrg:	dc.l 0



****************************************************************
*	ROUTINES TRIGONOMETRIQUES
**********************************
TB011C	MOVE.L	-$10(A6),-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	TB036C
	ADDQ.L	#8,A7
	MOVE.L	D0,-4(A6)
TB0130	CLR.L	-(A7)
	MOVE.L	-$10(A6),-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	TB036C
	ADDQ.L	#8,A7
	MOVE.L	D0,-(A7)
	JSR	TB018A
	ADDQ.L	#8,A7
	BGE.S	TB011C
	MOVE.L	-4(A6),-(A7)
	JSR	TB02E4
	ADDQ.L	#4,A7
	MOVE.L	D0,D7
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	TB018A
	ADDQ.L	#8,A7
	BGE.S	TB016E
	NEG.L	D7
TB016E	MOVE.L	D7,-(A7)
	JSR	TB0254
	ADDQ.L	#4,A7
	MOVE.L	D0,-8(A6)
	MOVE.L	-8(A6),D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,D7
	UNLK	A6
	RTS

TB018A	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	TB0520
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS


TB0254	LINK	A6,#0
	MOVEM.L	D5-D7,-(A7)
	TST.L	8(A6)
	BGE.S	TB0270
	MOVEQ	#1,D6
	MOVE.L	8(A6),D0
	NEG.L	D0
	MOVE.L	D0,8(A6)
	BRA.S	TB0272
TB0270	CLR.W	D6
TB0272	TST.L	8(A6)
	BNE.S	TB027C
	CLR.L	D0
	BRA.S	TB02DA
TB027C	MOVEQ	#$18,D7
	BRA.S	TB028C
TB0280	MOVE.L	8(A6),D0
	ASR.L	#1,D0
	MOVE.L	D0,8(A6)
	ADDQ.L	#1,D7
TB028C	MOVE.L	8(A6),D0
	AND.L	#$7F000000,D0
	BNE.S	TB0280
	BRA.S	TB02A6
TB029A	MOVE.L	8(A6),D0
	ASL.L	#1,D0
	MOVE.L	D0,8(A6)
	SUBQ.L	#1,D7
TB02A6	BTST	#7,9(A6)
	BEQ.S	TB029A
	MOVE.L	8(A6),D0
	ASL.L	#8,D0
	MOVE.L	D0,8(A6)
	ADD.L	#$40,D7
	MOVE.L	D7,D0
	AND.L	#$7F,D0
	OR.L	D0,8(A6)
	TST.W	D6
	BEQ.S	TB02D6
	ORI.L	#$80,8(A6)
TB02D6	MOVE.L	8(A6),D0
TB02DA	TST.L	(A7)+
	MOVEM.L	(A7)+,D6-D7
	UNLK	A6
	RTS
TB02E4	LINK	A6,#0
	MOVEM.L	D4-D7,-(A7)
	MOVE.L	8(A6),D0
	AND.L	#$7F,D0
	ADD.L	#$FFFFFFC0,D0
	MOVE.W	D0,D6
	TST.L	8(A6)
	BEQ.S	TB0308
	TST.W	D6
	BGE.S	TB030C
TB0308	CLR.L	D0
	BRA.S	TB0362
TB030C	MOVE.L	8(A6),D0
	AND.L	#$80,D0
	MOVE.W	D0,D5
	CMP.W	#$1F,D6
	BLE.S	TB0332
	TST.W	D5
	BEQ.S	TB032A
	MOVE.L	#$80000000,D0
	BRA.S	TB0330
TB032A	MOVE.L	#$7FFFFFFF,D0
TB0330	BRA.S	TB0362
TB0332	MOVE.L	8(A6),D7
	ASR.L	#8,D7
	AND.L	#$FFFFFF,D7
	SUB.W	#$18,D6
	BRA.S	TB0348
TB0344	ASR.L	#1,D7
	ADDQ.W	#1,D6
TB0348	TST.W	D6
	BLT.S	TB0344
	BRA.S	TB0352
TB034E	ASL.L	#1,D7
	SUBQ.W	#1,D6
TB0352	TST.W	D6
	BGT.S	TB034E
	TST.W	D5
	BEQ.S	TB0360
	MOVE.L	D7,D0
	NEG.L	D0
	MOVE.L	D0,D7
TB0360	MOVE.L	D7,D0
TB0362	TST.L	(A7)+
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS

TB036C	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	TB079E
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS


TB03D4	MOVEM.L	D1-D6/A0,-(A7)
	MOVE.B	D7,-(A7)
	AND.B	#$7F,D7
	MOVE.L	#$80000041,D6
	CLR.B	-(A7)
	CMP.B	D6,D7
	BCS.S	TB03FA
	BHI.S	TB03F0
	CMP.L	D6,D7
	BLS.S	TB03FA
TB03F0	NOT.B	(A7)
	EXG	D6,D7
	JSR	TB08A6
TB03FA	SUB.B	#$43,D7
	NEG.B	D7
	CMP.B	#$1F,D7
	BLS.S	TB040A
	MOVEQ	#0,D6
	BRA.S	TB0442
TB040A	LSR.L	D7,D7
	MOVEQ	#0,D6
	MOVE.L	#$20000000,D5
	LEA	TB0B72,A0
	MOVEQ	#$18,D1
	MOVEQ	#1,D2
	BRA.S	TB0426
TB0420	ASR.L	D2,D4
	ADD.L	D4,D5
	ADD.L	(A0),D6
TB0426	MOVE.L	D7,D4
	MOVE.L	D5,D3
	ASR.L	D2,D3
TB042C	SUB.L	D3,D7
	BPL.S	TB0420
	MOVE.L	D4,D7
	ADDQ.L	#4,A0
	ADDQ.B	#1,D2
	LSR.L	#1,D3
	DBF	D1,TB042C
	JSR	TB0BDA
TB0442	MOVE.L	D6,D7
	TST.B	(A7)+
	BEQ.S	TB0454
	MOVE.L	#$C90FDB41,D7
	JSR	TB079E
TB0454	MOVE.B	(A7)+,D6
	TST.B	D7
	BEQ.S	TB0460
	AND.B	#$80,D6
	OR.B	D6,D7
TB0460	MOVEM.L	(A7)+,D1-D6/A0
	RTS
	MOVE.L	D6,-(A7)
	AND.B	#$7F,D7
	JSR	TB093E
	BVS.S	TB0494
	MOVE.L	D7,-(A7)
	MOVE.L	D7,D6
	MOVE.L	#$80000041,D7
	JSR	TB08A6
	MOVE.L	(A7)+,D6
	JSR	TB07B0
	BEQ.S	TB0494
	SUBQ.B	#1,D7
	BVC.S	TB0494
	MOVEQ	#0,D7
TB0494	MOVEM.L	(A7)+,D6
	RTS
TB049A	MOVE.L	D6,-(A7)
	JSR	TB093E
	BVS.S	TB04CE
	MOVE.L	D7,-(A7)
	MOVE.L	D7,D6
	MOVE.L	#$80000041,D7
	JSR	TB08A6
	MOVE.L	(A7),D6
	JSR	TB07B0
	BEQ.S	TB04C4
	SUBQ.B	#1,D7
	BVC.S	TB04C4
	MOVEQ	#0,D7
TB04C4	MOVE.L	D7,D6
	MOVE.L	(A7)+,D7
	JSR	TB079E
TB04CE	MOVEM.L	(A7)+,D6
	RTS
TB04D4	MOVE.L	D6,-(A7)
	TST.B	D7
	BEQ.S	TB050A
	ADDQ.B	#1,D7
	BVS.S	TB050E
	JSR	TB093E
	BVS.S	TB0518
	MOVE.L	D7,-(A7)
	MOVE.L	#$80000041,D6
	JSR	TB07B0
	MOVE.L	D7,-(A7)
	MOVE.L	4(A7),D7
	JSR	TB079E
	MOVE.L	(A7)+,D6
	JSR	TB08A6
	ADDQ.L	#4,A7
TB050A	MOVE.L	(A7)+,D6
	RTS
TB050E	MOVE.L	#$80000082,D7
	ROXR.B	#1,D7
	BRA.S	TB050A
TB0518	MOVE.L	#$80000041,D7
	BRA.S	TB050A
TB0520	TST.B	D6
	BPL.S	TB0530
	TST.B	D7
	BPL.S	TB0530
	CMP.B	D7,D6
	BNE.S	TB0536
	CMP.L	D7,D6
	RTS
TB0530	CMP.B	D6,D7
	BNE.S	TB0536
	CMP.L	D6,D7
TB0536	RTS
	TST.B	D7
	RTS
TB053C	TST.B	D7
	BPL.S	TB054C
	AND.B	#$7F,D7
	BSR.S	TB054C
	ORI.B	#2,CCR
	RTS
TB054C	JSR	TB0A18
	MOVEM.L	D3-D5,-(A7)
	JSR	TB0AE8
	MOVEM.L	(A7)+,D3-D5
	JMP	TB093E
	MOVE.W	#$FFFE,-(A7)
	BRA.S	TB0590
	MOVE.W	#$FFFF,-(A7)
	BRA.S	TB0586
TB0572	MOVE.W	#1,-(A7)
	BRA.S	TB0590
TB0578	CMP.B	#$B8,D7
	BHI.S	TB0590
TB057E	ADDQ.L	#2,A7
	TST.B	D7
	RTS
TB0584	CLR.W	-(A7)
TB0586	TST.B	D7
	BMI.S	TB0578
	CMP.B	#$38,D7
	BLS.S	TB057E
TB0590	MOVEM.L	D1-D6/A0,-(A7)
	MOVE.L	D7,D2
	ADD.B	D7,D7
	CMP.B	#$8A,D7
	BLS.S	TB05EE
	CMP.B	#$A8,D7
	BLS.S	TB05B0
	ORI.B	#2,CCR
	MOVEM.L	(A7)+,D1-D6/A0
	ADDQ.L	#2,A7
	RTS
TB05B0	MOVE.L	#$A2F9833E,D6
	MOVE.L	D2,D7
	JSR	TB0AE8
	MOVE.B	D7,D5
	AND.B	#$7F,D5
	SUB.B	#$58,D5
	NEG.B	D5
	MOVEQ	#-1,D4
	CLR.B	D4
	LSL.L	D5,D4
	OR.B	#$FF,D4
	AND.L	D4,D7
	MOVE.L	#$C90FDB43,D6
	JSR	TB0AE8
	MOVE.L	D7,D6
	MOVE.L	D2,D7
	JSR	TB079E
	MOVE.L	D7,D2
TB05EE	MOVE.L	#$C90FDAA,D4
	MOVE.L	D2,D7
	CLR.B	D7
	TST.B	D2
	BMI.S	TB0616
	SUB.B	#$46,D2
	NEG.B	D2
	CMP.B	#$1F,D2
	BLS.S	TB060A
	MOVEQ	#0,D7
TB060A	LSR.L	D2,D7
TB060C	CMP.L	D4,D7
	BLE.S	TB0634
	SUB.L	D4,D7
	SUB.L	D4,D7
	BRA.S	TB060C
TB0616	SUB.B	#$C6,D2
	NEG.B	D2
	CMP.B	#$1F,D2
	BLS.S	TB0624
	MOVEQ	#0,D7
TB0624	LSR.L	D2,D7
	NEG.L	D7
	NEG.L	D4
TB062A	CMP.L	D4,D7
	BGE.S	TB0634
	SUB.L	D4,D7
	SUB.L	D4,D7
	BRA.S	TB062A
TB0634	MOVEQ	#0,D5
	MOVE.L	#$EC916240,D6
	MOVE.L	#$3243F6A8,D4
	ASL.L	#3,D7
	BMI.S	TB064A
	NEG.L	D6
	NEG.L	D4
TB064A	ADD.L	D4,D7
	LEA	TB0B6E,A0
	MOVEQ	#$17,D1
	MOVEQ	#-1,D2
TB0656	ADDQ.W	#1,D2
	MOVE.L	D5,D3
	MOVE.L	D6,D4
	ASR.L	D2,D3
	ASR.L	D2,D4
	TST.L	D7
	BMI.S	TB0670
	SUB.L	D4,D5
	ADD.L	D3,D6
	SUB.L	(A0)+,D7
	DBF	D1,TB0656
	BRA.S	TB067A
TB0670	ADD.L	D4,D5
	SUB.L	D3,D6
	ADD.L	(A0)+,D7
	DBF	D1,TB0656
TB067A	MOVE.W	$1C(A7),D1
	BPL.S	TB06A4
	ADDQ.B	#1,D1
	BNE.S	TB06B6
	BSR.S	TB06C2
	MOVE.L	D6,D7
	MOVE.L	D5,D6
	BSR.S	TB06C2
	BEQ.S	TB069C
	JSR	TB08A6
TB0694	MOVEM.L	(A7)+,D1-D6/A0
	ADDQ.L	#2,A7
	RTS
TB069C	DC.W 	$FFFF
TB069E	DC.W 	$FF7F
	BRA.S	TB0694
TB06A4	BEQ.S	TB06A8
	MOVE.L	D5,D6
TB06A8	BSR.S	TB06C2
	MOVE.L	D6,D7
	TST.B	D7
	MOVEM.L	(A7)+,D1-D6/A0
	ADDQ.L	#2,A7
	RTS
TB06B6	MOVE.L	D5,-(A7)
	BSR.S	TB06C2
	MOVE.L	D6,$18(A7)
	MOVE.L	(A7)+,D6
	BRA.S	TB06A8
TB06C2	MOVE.L	D6,D4
	BMI.S	TB06D2
	CMP.L	#$FF,D6
	BHI.S	TB06DA
TB06CE	MOVEQ	#0,D6
	RTS
TB06D2	ASR.L	#8,D4
	ADDQ.L	#1,D4
	BNE.S	TB06DA
	BRA.S	TB06CE
TB06DA	JMP	TB0BDA
TB06E0	AND.B	#$7F,D7
	BSR.S	TB06EC
	ORI.B	#2,CCR
	RTS
TB06EC	MOVE.B	D7,D3
	BEQ.S	TB0740
	BMI.S	TB06E0
	LSR.B	#1,D3
	BCC.S	TB06FA
	ADDQ.B	#1,D3
	LSR.L	#1,D7
TB06FA	ADD.B	#$20,D3
	SWAP	D3
	MOVE.W	#$17,D3
	LSR.L	#7,D7
	MOVE.L	D7,D4
	MOVE.L	D7,D5
	MOVE.L	A0,D6
	LEA	TB0742(PC),A0
	MOVE.L	#$800000,D7
	SUB.L	D7,D4
	SUB.L	#$1200000,D5
	BRA.S	TB072C
TB0720	BSET	D3,D7
	MOVE.L	D5,D4
TB0724	ADD.L	D4,D4
	MOVE.L	D4,D5
	SUB.L	(A0)+,D5
	SUB.L	D7,D5
TB072C	DBMI	D3,TB0720
	DBPL	D3,TB0724
	BLS.S	TB0738
	ADDQ.L	#1,D7
TB0738	LSL.L	#8,D7
	MOVEA.L	D6,A0
	SWAP	D3
	MOVE.B	D3,D7
TB0740	RTS

TB0742	DC.B	0,$10,0,0,0,8,0,0
	DC.B	0,4,0,0,0,2,0,0
	DC.B	0,1,0,0,0,0,$80,0
	DC.B	0,0,$40,0,0,0,$20,0
	DC.B	0,0,$10,0,0,0,8,0
	DC.B	0,0,4,0,0,0,2,0
	DC.B	0,0,1,0,0,0,0,$80
	DC.B	0,0,0,$40,0,0,0,$20
	DC.B	0,0,0,$10,0,0,0,8
	DC.B	0,0,0,4,0,0,0,2
	DC.B	0,0,0,1,0,0,0,0
	DC.B	0,0,0,0
	
TB079E	MOVE.B 	D6,D4
	BEQ.S 	TB07F4
	EORI.B 	#$80,D4
	BMI.S	TB0812
	MOVE.B	D7,D5
	BMI.S	TB0818
	BNE.S	TB07BC
	BRA.S	TB07EE
TB07B0	MOVE.B	D6,D4
	BMI.S	TB0812
	BEQ.S	TB07F4
	MOVE.B	D7,D5
	BMI.S	TB0818
	BEQ.S	TB07EE
TB07BC	SUB.B	D4,D5
	BMI.S	TB07F8
	MOVE.B	D7,D4
	CMP.B	#$18,D5
	BCC.S	TB07F4
	MOVE.L	D6,D3
	CLR.B	D3
	LSR.L	D5,D3
	MOVE.B	#$80,D7
	ADD.L	D3,D7
	BCS.S	TB07DA
TB07D6	MOVE.B	D4,D7
	RTS
TB07DA	ROXR.L	#1,D7
	ADDQ.B	#1,D4
	BVS.S	TB07E2
	BCC.S	TB07D6
TB07E2	MOVEQ	#-1,D7
	SUBQ.B	#1,D4
	MOVE.B	D4,D7
	ORI.B	#2,CCR
	RTS
TB07EE	MOVE.L	D6,D7
	MOVE.B	D4,D7
	RTS
TB07F4	TST.B	D7
	RTS
TB07F8	CMP.B	#$E8,D5
	BLE.S	TB07EE
	NEG.B	D5
	MOVE.L	D6,D3
	CLR.B	D7
	LSR.L	D5,D7
	MOVE.B	#$80,D3
	ADD.L	D3,D7
	BCS.S	TB07DA
	MOVE.B	D4,D7
	RTS
TB0812	MOVE.B	D7,D5
	BMI.S	TB07BC
	BEQ.S	TB07EE
TB0818	MOVEQ	#-$80,D3
	EOR.B	D3,D5
	SUB.B	D4,D5
	BEQ.S	TB0870
	BMI.S	TB085E
	CMP.B	#$18,D5
	BCC.S	TB07F4
	MOVE.B	D7,D4
	MOVE.B	D3,D7
	MOVE.L	D6,D3
TB082E	CLR.B	D3
	LSR.L	D5,D3
	SUB.L	D3,D7
	BMI.S	TB07D6
TB0836	MOVE.B	D4,D5
TB0838	CLR.B	D7
	SUBQ.B	#1,D4
	CMP.L	#$7FFF,D7
	BHI.S	TB084A
	SWAP	D7
	SUB.B	#$10,D4
TB084A	ADD.L	D7,D7
	DBMI	D4,TB084A
	EOR.B	D4,D5
	BMI.S	TB085A
	MOVE.B	D4,D7
	BEQ.S	TB085A
	RTS
TB085A	MOVEQ	#0,D7
	RTS
TB085E	CMP.B	#$E8,D5
	BLE.S	TB07EE
	NEG.B	D5
	MOVE.L	D7,D3
	MOVE.L	D6,D7
	MOVE.B	#$80,D7
	BRA.S	TB082E
TB0870	MOVE.B	D7,D5
	EXG	D5,D4
	MOVE.B	D6,D7
	SUB.L	D6,D7
	BEQ.S	TB085A
	BPL.S	TB0836
	NEG.L	D7
	MOVE.B	D5,D4
	BRA.S	TB0838
TB0882	DIVU	#0,D7
	TST.L	D6
	BNE.S	TB08A6
TB088A	OR.L	#$FFFFFF7F,D7
	TST.B	D7
	ORI.B	#2,CCR
TB0896	RTS
TB0898	SWAP	D6
	SWAP	D7
TB089C	EOR.B	D6,D7
	BRA.S	TB088A
TB08A0	BMI.S	TB089C
TB08A2	MOVEQ	#0,D7
	RTS
TB08A6	MOVE.B	D6,D5
	BEQ.S	TB0882
	MOVE.L	D7,D4
	BEQ.S	TB0896
	MOVEQ	#-$80,D3
	ADD.W	D5,D5
	ADD.W	D4,D4
	EOR.B	D3,D5
	EOR.B	D3,D4
	SUB.B	D5,D4
	BVS.S	TB08A0
	CLR.B	D7
	SWAP	D7
	SWAP	D6
	CMP.W	D6,D7
	BMI.S	TB08CC
	ADDQ.B	#2,D4
	BVS.S	TB0898
	ROR.L	#1,D7
TB08CC	SWAP	D7
	MOVE.B	D3,D5
	EOR.W	D5,D4
	LSR.W	#1,D4
	MOVE.L	D7,D3
	DIVU	D6,D3
	MOVE.W	D3,D5
	MULU	D6,D3
	SUB.L	D3,D7
	SWAP	D7
	SWAP	D6
	MOVE.W	D6,D3
	CLR.B	D3
	MULU	D5,D3
	SUB.L	D3,D7
	BCC.S	TB08F4
	MOVE.L	D6,D3
	CLR.B	D3
	ADD.L	D3,D7
	SUBQ.W	#1,D5
TB08F4	MOVE.L	D6,D3
	SWAP	D3
	CLR.W	D7
	DIVU	D3,D7
	SWAP	D5
	BMI.S	TB0908
	MOVE.W	D7,D5
	ADD.L	D5,D5
	SUBQ.B	#1,D4
	MOVE.W	D5,D7
TB0908	MOVE.W	D7,D5
	ADD.L	#$80,D5
	MOVE.L	D5,D7
	MOVE.B	D4,D7
	BEQ.S	TB08A2
	RTS
TB0918	MOVE.W	(A7)+,D6
	TST.B	D6
	BPL.S	TB0922
	MOVEQ	#0,D7
	BRA.S	TB092A
TB0922	MOVEQ	#-1,D7
	LSR.B	#1,D7
	ORI.B	#2,CCR
TB092A	MOVEM.L	(A7)+,D1-D6/A0
	RTS
TB0930	MOVE.L	#$80000041,D7
	LEA	$1E(A7),A7
	TST.B	D7
	RTS
TB093E	MOVEM.L	D1-D6/A0,-(A7)
	MOVE.W	D7,-(A7)
	BEQ.S	TB0930
	AND.B	#$7F,D7
	MOVE.L	D7,D2
	MOVE.L	#$B8AA3B41,D6
	JSR	TB0AE8
	BVS.S	TB0918
	MOVE.B	D7,D5
	MOVE.B	D7,D6
	SUB.B	#$60,D5
	NEG.B	D5
	CMP.B	#$18,D5
	BLE.S	TB0918
	CMP.B	#$20,D5
	BGE.S	TB0992
	LSR.L	D5,D7
	MOVE.B	D7,(A7)
	LSL.L	D5,D7
	MOVE.B	D6,D7
	MOVE.L	#$B1721840,D6
	JSR	TB0AE8
	MOVE.L	D7,D6
	MOVE.L	D2,D7
	JSR	TB079E
	MOVE.L	D7,D2
	BRA.S	TB0996
TB0992	CLR.B	(A7)
	MOVE.L	D2,D7
TB0996	CLR.B	D7
	SUB.B	#$43,D2
	NEG.B	D2
	CMP.B	#$1F,D2
	BLS.S	TB09A6
	MOVEQ	#0,D7
TB09A6	LSR.L	D2,D7
	MOVEQ	#0,D5
	MOVE.L	#$26A3D100,D6
	LEA	TB0C10,A0
	MOVEQ	#0,D2
	MOVEQ	#3,D1
	BSR.S	TB09F2
	SUBQ.L	#4,A0
	SUBQ.W	#1,D2
	MOVEQ	#9,D1
	BSR.S	TB09F2
	SUBQ.L	#4,A0
	SUBQ.W	#1,D2
	MOVEQ	#$A,D1
	BSR.S	TB09F2
	TST.B	1(A7)
	BPL.S	TB09D6
	NEG.L	D5
	NEG.B	(A7)
TB09D6	ADD.L	D5,D6
	JSR	TB0BDA
	MOVE.L	D6,D7
	ADD.B	(A7),D7
	BMI	TB0918
	BEQ	TB0918
	ADDQ.L	#2,A7
	MOVEM.L	(A7)+,D1-D6/A0
	RTS
TB09F2	ADDQ.W	#1,D2
	MOVE.L	D5,D3
	MOVE.L	D6,D4
	ASR.L	D2,D3
	ASR.L	D2,D4
	TST.L	D7
	BMI.S	TB0A0C
	ADD.L	D4,D5
	ADD.L	D3,D6
	SUB.L	(A0)+,D7
	DBF	D1,TB09F2
	RTS
TB0A0C	SUB.L	D4,D5
	SUB.L	D3,D6
	ADD.L	(A0)+,D7
	DBF	D1,TB09F2
	RTS
TB0A18	TST.B	D7
	BEQ.S	TB0A2A
	BPL.S	TB0A32
	AND.B	#$7F,D7
	BSR.S	TB0A32
TB0A24	ORI.B	#2,CCR
	RTS
TB0A2A	MOVEQ	#-1,D7
	JMP	TB0A24
TB0A32	MOVEM.L	D1-D6/A0,-(A7)
	MOVE.B	D7,-(A7)
	MOVE.B	#$41,D7
	MOVE.L	#$80000041,D6
	MOVE.L	D7,D2
	JSR	TB07B0
	EXG	D7,D2
	JSR	TB079E
	MOVE.L	D2,D6
	JSR	TB08A6
	BEQ.S	TB0AAA
	SUB.B	#$43,D7
	NEG.B	D7
	CMP.B	#$1F,D7
	BLS.S	TB0A6A
	MOVEQ	#0,D7
TB0A6A	LSR.L	D7,D7
	MOVEQ	#0,D6
	MOVE.L	#$20000000,D5
	LEA	TB0C10,A0
	MOVEQ	#$16,D1
	MOVEQ	#1,D2
	BRA.S	TB0A86
TB0A80	ASR.L	D2,D4
	SUB.L	D4,D5
	ADD.L	(A0),D6
TB0A86	MOVE.L	D7,D4
	MOVE.L	D5,D3
	ASR.L	D2,D3
TB0A8C	SUB.L	D3,D7
	BPL.S	TB0A80
	MOVE.L	D4,D7
	ADDQ.L	#4,A0
	ADDQ.B	#1,D2
	LSR.L	#1,D3
	DBF	D1,TB0A8C
	MOVEQ	#0,D7
	JSR	TB0BDA
	BEQ.S	TB0AAA
	ADDQ.B	#1,D6
	MOVE.L	D6,D7
TB0AAA	MOVE.L	D7,D2
	MOVEQ	#0,D6
	MOVE.B	(A7)+,D6
	SUB.B	#$41,D6
	BEQ.S	TB0AE2
	MOVE.B	D6,D1
	BPL.S	TB0ABC
	NEG.B	D6
TB0ABC	ROR.L	#8,D6
	MOVEQ	#$47,D5
TB0AC0	ADD.L	D6,D6
	DBMI	D5,TB0AC0
	MOVE.B	D5,D6
	AND.B	#$80,D1
	OR.B	D1,D6
	MOVE.L	#$B1721840,D7
	JSR	TB0AE8
	MOVE.L	D2,D6
	JSR	TB07B0
TB0AE2	MOVEM.L	(A7)+,D1-D6/A0
	RTS
TB0AE8	MOVE.B	D7,D5
	BEQ.S	TB0B3E
	MOVE.B	D6,D4
	BEQ.S	TB0B58
	ADD.W	D5,D5
	ADD.W	D4,D4
	MOVEQ	#-$80,D3
	EOR.B	D3,D4
	EOR.B	D3,D5
	ADD.B	D4,D5
	BVS.S	TB0B5C
	MOVE.B	D3,D4
	EOR.W	D4,D5
	ROR.W	#1,D5
	SWAP	D5
	MOVE.W	D6,D5
	CLR.B	D7
	CLR.B	D5
	MOVE.W	D5,D4
	MULU	D7,D4
	SWAP	D4
	MOVE.L	D7,D3
	SWAP	D3
	MULU	D5,D3
	ADD.L	D3,D4
	SWAP	D6
	MOVE.L	D6,D3
	MULU	D7,D3
	ADD.L	D3,D4
	CLR.W	D4
	ADDX.B	D4,D4
	SWAP	D4
	SWAP	D7
	MULU	D6,D7
	SWAP	D6
	SWAP	D5
	ADD.L	D4,D7
	BPL.S	TB0B40
	ADD.L	#$80,D7
	MOVE.B	D5,D7
	BEQ.S	TB0B58
TB0B3E	RTS
TB0B40	SUBQ.B	#1,D5
	BVS.S	TB0B58
	BCS.S	TB0B58
	MOVEQ	#$40,D4
	ADD.L	D4,D7
	ADD.L	D7,D7
	BCC.S	TB0B52
	ROXR.L	#1,D7
	ADDQ.B	#1,D5
TB0B52	MOVE.B	D5,D7
	BEQ.S	TB0B58
	RTS
TB0B58	MOVEQ	#0,D7
	RTS
TB0B5C	DC.B	$6A,$FA,$BD,7,$8E,$BC,$FF,$FF
	DC.B	$FF,$7F,$4A,7,0,$3C,0,2
	DC.B	$4E,$75
TB0B6E	DC.B 	$19,$21,$FB,$54
TB0B72	DC.B	$E,$D6
	DC.B	$33,$82,7,$D6,$DD,$7E,3,$FA
	DC.B	$B7,$53,1,$FF,$55,$BB,0,$FF
	DC.B	$EA,$AD,0,$7F,$FD,$55,0,$3F
	DC.B	$FF,$AA,0,$1F,$FF,$F5,0,$F
	DC.B	$FF,$FE,0,7,$FF,$FF,0,3
	DC.B	$FF,$FF,0,1,$FF,$FF,0,0
	DC.B	$FF,$FF,0,0,$7F,$FF,0,0
	DC.B	$3F,$FF,0,0,$1F,$FF,0,0
	DC.B	$F,$FF,0,0,7,$FF,0,0
	DC.B	3,$FF,0,0,1,$FF,0,0
	DC.B	0,$FF,0,0,0,$7F,0,0
	DC.B	0,$3F,0,0,0,$1F,0,0
	DC.B	0,$F,0,0,0,7
TB0BDA	MOVEQ	#$42,D4
	TST.L	D6
	BEQ.S	TB0C0E
	BPL.S	TB0BE8
	NEG.L	D6
	MOVE.B	#$C2,D4
TB0BE8	CMP.L	#$7FFF,D6
	BHI.S	TB0BF6
	SWAP	D6
	SUB.B	#$10,D4
TB0BF6	ADD.L	D6,D6
	DBMI	D4,TB0BF6
	TST.B	D6
	BPL.S	TB0C0C
	ADD.L	#$100,D6
	BCC.S	TB0C0C
	ROXR.L	#1,D6
	ADDQ.B	#1,D4
TB0C0C	MOVE.B	D4,D6
TB0C0E	RTS
TB0C10	DC.B	$11,$93,$EA,$7A,8,$2C,$57,$7D
	DC.B	4,5,$62,$47,2,0,$AB,$11
	DC.B	1,0,$15,$58,0,$80,2,$AA
	DC.B	0,$40,0,$55,0,$20,0,$A
	DC.B	0,$10,0,1,0,8,0,0
	DC.B	0,4,0,0,0,2,0,0
	DC.B	0,1,0,0,0,0,$80,0
	DC.B	0,0,$40,0,0,0,$20,0
	DC.B	0,0,$10,0,0,0,8,0
	DC.B	0,0,4,0,0,0,2,0
	DC.B	0,0,1,0,0,0,0,$80
	DC.B	0,0,0,$40,0,0,0,$20

**********************************************************************
*	PARTIE ENTIERE
************************
INT	LINK	A6,#-4
	MOVEM.L	D6-D7,-(A7)
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	IB0028
	ADDQ.L	#8,A7
	BGE.S	IAFFFE
	MOVE.L	#$FFFFFE40,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	IB015E
	ADDQ.L	#8,A7
	MOVE.L	D0,8(A6)
IAFFFE	MOVE.L	8(A6),-(A7)
	JSR	IB00D6
	ADDQ.L	#4,A7
	MOVE.L	D0,D7
	MOVE.L	D7,-(A7)
	JSR	IB0046
	ADDQ.L	#4,A7
	MOVE.L	D0,-4(A6)
	MOVE.L	-4(A6),D0
	TST.L	(A7)+
	MOVEM.L	(A7)+,D7
	UNLK	A6
	RTS
IB0028	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	IB017E
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS

IB0046	LINK	A6,#0
	MOVEM.L	D5-D7,-(A7)
	TST.L	8(A6)
	BGE.S	IB0062
	MOVEQ	#1,D6
	MOVE.L	8(A6),D0
	NEG.L	D0
	MOVE.L	D0,8(A6)
	BRA.S	IB0064
IB0062	CLR.W	D6
IB0064	TST.L	8(A6)
	BNE.S	IB006E
	CLR.L	D0
	BRA.S	IB00CC
IB006E	MOVEQ	#$18,D7
	BRA.S	IB007E
IB0072	MOVE.L	8(A6),D0
	ASR.L	#1,D0
	MOVE.L	D0,8(A6)
	ADDQ.L	#1,D7
IB007E	MOVE.L	8(A6),D0
	AND.L	#$7F000000,D0
	BNE.S	IB0072
	BRA.S	IB0098
IB008C	MOVE.L	8(A6),D0
	ASL.L	#1,D0
	MOVE.L	D0,8(A6)
	SUBQ.L	#1,D7
IB0098	BTST	#7,9(A6)
	BEQ.S	IB008C
	MOVE.L	8(A6),D0
	ASL.L	#8,D0
	MOVE.L	D0,8(A6)
	ADD.L	#$40,D7
	MOVE.L	D7,D0
	AND.L	#$7F,D0
	OR.L	D0,8(A6)
	TST.W	D6
	BEQ.S	IB00C8
	ORI.L	#$80,8(A6)
IB00C8	MOVE.L	8(A6),D0
IB00CC	TST.L	(A7)+
	MOVEM.L	(A7)+,D6-D7
	UNLK	A6
	RTS

IB00D6	LINK	A6,#0
	MOVEM.L	D4-D7,-(A7)
	MOVE.L	8(A6),D0
	AND.L	#$7F,D0
	ADD.L	#$FFFFFFC0,D0
	MOVE.W	D0,D6
	TST.L	8(A6)
	BEQ.S	IB00FA
	TST.W	D6
	BGE.S	IB00FE
IB00FA	CLR.L	D0
	BRA.S	IB0154
IB00FE	MOVE.L	8(A6),D0
	AND.L	#$80,D0
	MOVE.W	D0,D5
	CMP.W	#$1F,D6
	BLE.S	IB0124
	TST.W	D5
	BEQ.S	IB011C
	MOVE.L	#$80000000,D0
	BRA.S	IB0122
IB011C	MOVE.L	#$7FFFFFFF,D0
IB0122	BRA.S	IB0154
IB0124	MOVE.L	8(A6),D7
	ASR.L	#8,D7
	AND.L	#$FFFFFF,D7
	SUB.W	#$18,D6
	BRA.S	IB013A
IB0136	ASR.L	#1,D7
	ADDQ.W	#1,D6
IB013A	TST.W	D6
	BLT.S	IB0136
	BRA.S	IB0144
IB0140	ASL.L	#1,D7
	SUBQ.W	#1,D6
IB0144	TST.W	D6
	BGT.S	IB0140
	TST.W	D5
	BEQ.S	IB0152
	MOVE.L	D7,D0
	NEG.L	D0
	MOVE.L	D0,D7
IB0152	MOVE.L	D7,D0
IB0154	TST.L	(A7)+
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
IB015E	LINK	A6,#-4
	MOVEM.L	D3-D7,-(A7)
	MOVE.L	8(A6),D7
	MOVE.L	$C(A6),D6
	JSR	IB019A
	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D3-D7
	UNLK	A6
	RTS
IB017E	TST.B	D6
	BPL.S	IB018E
	TST.B	D7
	BPL.S	IB018E
	CMP.B	D7,D6
	BNE.S	IB0194
	CMP.L	D7,D6
	RTS
IB018E	CMP.B	D6,D7
	BNE.S	IB0194
	CMP.L	D6,D7
IB0194	RTS
	TST.B	D7
	RTS
IB019A	MOVE.B	D6,D4
	BEQ.S	IB01F0
	EORI.B	#$80,D4
	BMI.S	IB020E
	MOVE.B	D7,D5
	BMI.S	IB0214
	BNE.S	IB01B8
	BRA.S	IB01EA
	MOVE.B	D6,D4
	BMI.S	IB020E
	BEQ.S	IB01F0
	MOVE.B	D7,D5
	BMI.S	IB0214
	BEQ.S	IB01EA
IB01B8	SUB.B	D4,D5
	BMI.S	IB01F4
	MOVE.B	D7,D4
	CMP.B	#$18,D5
	BCC.S	IB01F0
	MOVE.L	D6,D3
	CLR.B	D3
	LSR.L	D5,D3
	MOVE.B	#$80,D7
	ADD.L	D3,D7
	BCS.S	IB01D6
IB01D2	MOVE.B	D4,D7
	RTS
IB01D6	ROXR.L	#1,D7
	ADDQ.B	#1,D4
	BVS.S	IB01DE
	BCC.S	IB01D2
IB01DE	MOVEQ	#-1,D7
	SUBQ.B	#1,D4
	MOVE.B	D4,D7
	ORI.B	#2,CCR
	RTS
IB01EA	MOVE.L	D6,D7
	MOVE.B	D4,D7
	RTS
IB01F0	TST.B	D7
	RTS
IB01F4	CMP.B	#$E8,D5
	BLE.S	IB01EA
	NEG.B	D5
	MOVE.L	D6,D3
	CLR.B	D7
	LSR.L	D5,D7
	MOVE.B	#$80,D3
	ADD.L	D3,D7
	BCS.S	IB01D6
	MOVE.B	D4,D7
	RTS
IB020E	MOVE.B	D7,D5
	BMI.S	IB01B8
	BEQ.S	IB01EA
IB0214	MOVEQ	#-$80,D3
	EOR.B	D3,D5
	SUB.B	D4,D5
	BEQ.S	IB026C
	BMI.S	IB025A
	CMP.B	#$18,D5
	BCC.S	IB01F0
	MOVE.B	D7,D4
	MOVE.B	D3,D7
	MOVE.L	D6,D3
IB022A	CLR.B	D3
	LSR.L	D5,D3
	SUB.L	D3,D7
	BMI.S	IB01D2
IB0232	MOVE.B	D4,D5
IB0234	CLR.B	D7
	SUBQ.B	#1,D4
	CMP.L	#$7FFF,D7
	BHI.S	IB0246
	SWAP	D7
	SUB.B	#$10,D4
IB0246	ADD.L	D7,D7
	DBMI	D4,IB0246
	EOR.B	D4,D5
	BMI.S	IB0256
	MOVE.B	D4,D7
	BEQ.S	IB0256
	RTS
IB0256	MOVEQ	#0,D7
	RTS
IB025A	CMP.B	#$E8,D5
	BLE.S	IB01EA
	NEG.B	D5
	MOVE.L	D7,D3
	MOVE.L	D6,D7
	MOVE.B	#$80,D7
	BRA.S	IB022A
IB026C	MOVE.B	D7,D5
	EXG	D5,D4
	MOVE.B	D6,D7
	SUB.L	D6,D7
	BEQ.S	IB0256
	BPL.S	IB0232
	NEG.L	D7
	MOVE.B	D5,D4
	BRA.S	IB0234

	

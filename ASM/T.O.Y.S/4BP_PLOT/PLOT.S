*************************************************************************
*						*
*		FYRBITPLANS PLOTRUTIN			*
*						*
*						*
*	AV : TAM of TOYS				*
*						*
*	D0=X,D1=Y,D2=F�RG,A0=LOGIC	X CYCLER PER PRICK	*
*	ANROPAS MED BSR/JSR		X=MASSOR		*
*						*
*	Obs! Detta �r absolut inte det snabbaste s�ttet att	*
*	s�tta ut en prick p�, men jag ville testa mitt s�s-	*
*	k�dsgenererare-program. Jag tar inget ansvar f�r om	*
*	k�den inte funkar el dyl, men om ni anv�nder den s�	*
*	n�mn inte mitt namn.				*
*						*
*************************************************************************
* TAB 12	Skriven i Devpac ST v2.25

	SECTION	TEXT

	LEA	LISTA(PC),A1	8
	ADD.W	D1,D1		4
	ADDA.W	0(A1,D1.W),A0	20
	LSL.W	#3,D0		12
	LEA	CODEA(PC),A2	8
ETT	BTST	#0,D2		16
	BEQ.S	SET_1		12/8
CLR_1	JSR	CODEA(PC,D0.W)	24
	BRA.S	TV�		12
SET_1	JSR	CODEB(PC,D0.W)	24
TV�	BTST	#1,D2		16
	BEQ.S	SET_2		12/8
CLR_2	JSR	CODEA(PC,D0.W)	24
	BRA.S	TRE		12
SET_2	JSR	CODEB(PC,D0.W)	24
TRE	BTST	#2,D2		16
	BEQ.S	SET_3		12/8
CLR_3	JSR	CODEA(PC,D0.W)	24
	BRA.S	FYRA		12
SET_3	JSR	CODEB(PC,D0.W)	24
FYRA	BTST	#3,D2		16
	BEQ.S	SET_4		12/8
CLR_4	JSR	CODEA(PC,D0.W)	24
	RTS			16
SET_4	JSR	CODEB(PC,D0.W)	24
	RTS			16

CODEB	BSET	#7,(A0)		12
	RTS			16
	NOP
	BSET	#6,(A0)
	RTS
	NOP
	BSET	#5,(A0)
	RTS
	NOP
	BSET	#4,(A0)
	RTS
	NOP
	BSET	#3,(A0)
	RTS
	NOP
	BSET	#2,(A0)
	RTS
	NOP
	BSET	#1,(A0)
	RTS
	NOP
	BSET	#0,(A0)
	RTS
	NOP
	BSET	#7,1(A0)		16
	RTS			16
	BSET	#6,1(A0)
	RTS
	BSET	#5,1(A0)
	RTS
	BSET	#4,1(A0)
	RTS
	BSET	#3,1(A0)
	RTS
	BSET	#2,1(A0)
	RTS
	BSET	#1,1(A0)
	RTS
	BSET	#0,1(A0)
	RTS
	BSET	#7,8(A0)
	RTS
	BSET	#6,8(A0)
	RTS
	BSET	#5,8(A0)
	RTS
	BSET	#4,8(A0)
	RTS
	BSET	#3,8(A0)
	RTS
	BSET	#2,8(A0)
	RTS
	BSET	#1,8(A0)
	RTS
	BSET	#0,8(A0)
	RTS
	BSET	#7,9(A0)
	RTS
	BSET	#6,9(A0)
	RTS
	BSET	#5,9(A0)
	RTS
	BSET	#4,9(A0)
	RTS
	BSET	#3,9(A0)
	RTS
	BSET	#2,9(A0)
	RTS
	BSET	#1,9(A0)
	RTS
	BSET	#0,9(A0)
	RTS
	BSET	#7,16(A0)
	RTS
	BSET	#6,16(A0)
	RTS
	BSET	#5,16(A0)
	RTS
	BSET	#4,16(A0)
	RTS
	BSET	#3,16(A0)
	RTS
	BSET	#2,16(A0)
	RTS
	BSET	#1,16(A0)
	RTS
	BSET	#0,16(A0)
	RTS
	BSET	#7,17(A0)
	RTS
	BSET	#6,17(A0)
	RTS
	BSET	#5,17(A0)
	RTS
	BSET	#4,17(A0)
	RTS
	BSET	#3,17(A0)
	RTS
	BSET	#2,17(A0)
	RTS
	BSET	#1,17(A0)
	RTS
	BSET	#0,17(A0)
	RTS
	BSET	#7,24(A0)
	RTS
	BSET	#6,24(A0)
	RTS
	BSET	#5,24(A0)
	RTS
	BSET	#4,24(A0)
	RTS
	BSET	#3,24(A0)
	RTS
	BSET	#2,24(A0)
	RTS
	BSET	#1,24(A0)
	RTS
	BSET	#0,24(A0)
	RTS
	BSET	#7,25(A0)
	RTS
	BSET	#6,25(A0)
	RTS
	BSET	#5,25(A0)
	RTS
	BSET	#4,25(A0)
	RTS
	BSET	#3,25(A0)
	RTS
	BSET	#2,25(A0)
	RTS
	BSET	#1,25(A0)
	RTS
	BSET	#0,25(A0)
	RTS
	BSET	#7,32(A0)
	RTS
	BSET	#6,32(A0)
	RTS
	BSET	#5,32(A0)
	RTS
	BSET	#4,32(A0)
	RTS
	BSET	#3,32(A0)
	RTS
	BSET	#2,32(A0)
	RTS
	BSET	#1,32(A0)
	RTS
	BSET	#0,32(A0)
	RTS
	BSET	#7,33(A0)
	RTS
	BSET	#6,33(A0)
	RTS
	BSET	#5,33(A0)
	RTS
	BSET	#4,33(A0)
	RTS
	BSET	#3,33(A0)
	RTS
	BSET	#2,33(A0)
	RTS
	BSET	#1,33(A0)
	RTS
	BSET	#0,33(A0)
	RTS
	BSET	#7,40(A0)
	RTS
	BSET	#6,40(A0)
	RTS
	BSET	#5,40(A0)
	RTS
	BSET	#4,40(A0)
	RTS
	BSET	#3,40(A0)
	RTS
	BSET	#2,40(A0)
	RTS
	BSET	#1,40(A0)
	RTS
	BSET	#0,40(A0)
	RTS
	BSET	#7,41(A0)
	RTS
	BSET	#6,41(A0)
	RTS
	BSET	#5,41(A0)
	RTS
	BSET	#4,41(A0)
	RTS
	BSET	#3,41(A0)
	RTS
	BSET	#2,41(A0)
	RTS
	BSET	#1,41(A0)
	RTS
	BSET	#0,41(A0)
	RTS
	BSET	#7,48(A0)
	RTS
	BSET	#6,48(A0)
	RTS
	BSET	#5,48(A0)
	RTS
	BSET	#4,48(A0)
	RTS
	BSET	#3,48(A0)
	RTS
	BSET	#2,48(A0)
	RTS
	BSET	#1,48(A0)
	RTS
	BSET	#0,48(A0)
	RTS
	BSET	#7,49(A0)
	RTS
	BSET	#6,49(A0)
	RTS
	BSET	#5,49(A0)
	RTS
	BSET	#4,49(A0)
	RTS
	BSET	#3,49(A0)
	RTS
	BSET	#2,49(A0)
	RTS
	BSET	#1,49(A0)
	RTS
	BSET	#0,49(A0)
	RTS
	BSET	#7,56(A0)
	RTS
	BSET	#6,56(A0)
	RTS
	BSET	#5,56(A0)
	RTS
	BSET	#4,56(A0)
	RTS
	BSET	#3,56(A0)
	RTS
	BSET	#2,56(A0)
	RTS
	BSET	#1,56(A0)
	RTS
	BSET	#0,56(A0)
	RTS
	BSET	#7,57(A0)
	RTS
	BSET	#6,57(A0)
	RTS
	BSET	#5,57(A0)
	RTS
	BSET	#4,57(A0)
	RTS
	BSET	#3,57(A0)
	RTS
	BSET	#2,57(A0)
	RTS
	BSET	#1,57(A0)
	RTS
	BSET	#0,57(A0)
	RTS
	BSET	#7,64(A0)
	RTS
	BSET	#6,64(A0)
	RTS
	BSET	#5,64(A0)
	RTS
	BSET	#4,64(A0)
	RTS
	BSET	#3,64(A0)
	RTS
	BSET	#2,64(A0)
	RTS
	BSET	#1,64(A0)
	RTS
	BSET	#0,64(A0)
	RTS
	BSET	#7,65(A0)
	RTS
	BSET	#6,65(A0)
	RTS
	BSET	#5,65(A0)
	RTS
	BSET	#4,65(A0)
	RTS
	BSET	#3,65(A0)
	RTS
	BSET	#2,65(A0)
	RTS
	BSET	#1,65(A0)
	RTS
	BSET	#0,65(A0)
	RTS
	BSET	#7,72(A0)
	RTS
	BSET	#6,72(A0)
	RTS
	BSET	#5,72(A0)
	RTS
	BSET	#4,72(A0)
	RTS
	BSET	#3,72(A0)
	RTS
	BSET	#2,72(A0)
	RTS
	BSET	#1,72(A0)
	RTS
	BSET	#0,72(A0)
	RTS
	BSET	#7,73(A0)
	RTS
	BSET	#6,73(A0)
	RTS
	BSET	#5,73(A0)
	RTS
	BSET	#4,73(A0)
	RTS
	BSET	#3,73(A0)
	RTS
	BSET	#2,73(A0)
	RTS
	BSET	#1,73(A0)
	RTS
	BSET	#0,73(A0)
	RTS
	BSET	#7,80(A0)
	RTS
	BSET	#6,80(A0)
	RTS
	BSET	#5,80(A0)
	RTS
	BSET	#4,80(A0)
	RTS
	BSET	#3,80(A0)
	RTS
	BSET	#2,80(A0)
	RTS
	BSET	#1,80(A0)
	RTS
	BSET	#0,80(A0)
	RTS
	BSET	#7,81(A0)
	RTS
	BSET	#6,81(A0)
	RTS
	BSET	#5,81(A0)
	RTS
	BSET	#4,81(A0)
	RTS
	BSET	#3,81(A0)
	RTS
	BSET	#2,81(A0)
	RTS
	BSET	#1,81(A0)
	RTS
	BSET	#0,81(A0)
	RTS
	BSET	#7,88(A0)
	RTS
	BSET	#6,88(A0)
	RTS
	BSET	#5,88(A0)
	RTS
	BSET	#4,88(A0)
	RTS
	BSET	#3,88(A0)
	RTS
	BSET	#2,88(A0)
	RTS
	BSET	#1,88(A0)
	RTS
	BSET	#0,88(A0)
	RTS
	BSET	#7,89(A0)
	RTS
	BSET	#6,89(A0)
	RTS
	BSET	#5,89(A0)
	RTS
	BSET	#4,89(A0)
	RTS
	BSET	#3,89(A0)
	RTS
	BSET	#2,89(A0)
	RTS
	BSET	#1,89(A0)
	RTS
	BSET	#0,89(A0)
	RTS
	BSET	#7,96(A0)
	RTS
	BSET	#6,96(A0)
	RTS
	BSET	#5,96(A0)
	RTS
	BSET	#4,96(A0)
	RTS
	BSET	#3,96(A0)
	RTS
	BSET	#2,96(A0)
	RTS
	BSET	#1,96(A0)
	RTS
	BSET	#0,96(A0)
	RTS
	BSET	#7,97(A0)
	RTS
	BSET	#6,97(A0)
	RTS
	BSET	#5,97(A0)
	RTS
	BSET	#4,97(A0)
	RTS
	BSET	#3,97(A0)
	RTS
	BSET	#2,97(A0)
	RTS
	BSET	#1,97(A0)
	RTS
	BSET	#0,97(A0)
	RTS
	BSET	#7,104(A0)
	RTS
	BSET	#6,104(A0)
	RTS
	BSET	#5,104(A0)
	RTS
	BSET	#4,104(A0)
	RTS
	BSET	#3,104(A0)
	RTS
	BSET	#2,104(A0)
	RTS
	BSET	#1,104(A0)
	RTS
	BSET	#0,104(A0)
	RTS
	BSET	#7,105(A0)
	RTS
	BSET	#6,105(A0)
	RTS
	BSET	#5,105(A0)
	RTS
	BSET	#4,105(A0)
	RTS
	BSET	#3,105(A0)
	RTS
	BSET	#2,105(A0)
	RTS
	BSET	#1,105(A0)
	RTS
	BSET	#0,105(A0)
	RTS
	BSET	#7,112(A0)
	RTS
	BSET	#6,112(A0)
	RTS
	BSET	#5,112(A0)
	RTS
	BSET	#4,112(A0)
	RTS
	BSET	#3,112(A0)
	RTS
	BSET	#2,112(A0)
	RTS
	BSET	#1,112(A0)
	RTS
	BSET	#0,112(A0)
	RTS
	BSET	#7,113(A0)
	RTS
	BSET	#6,113(A0)
	RTS
	BSET	#5,113(A0)
	RTS
	BSET	#4,113(A0)
	RTS
	BSET	#3,113(A0)
	RTS
	BSET	#2,113(A0)
	RTS
	BSET	#1,113(A0)
	RTS
	BSET	#0,113(A0)
	RTS
	BSET	#7,120(A0)
	RTS
	BSET	#6,120(A0)
	RTS
	BSET	#5,120(A0)
	RTS
	BSET	#4,120(A0)
	RTS
	BSET	#3,120(A0)
	RTS
	BSET	#2,120(A0)
	RTS
	BSET	#1,120(A0)
	RTS
	BSET	#0,120(A0)
	RTS
	BSET	#7,121(A0)
	RTS
	BSET	#6,121(A0)
	RTS
	BSET	#5,121(A0)
	RTS
	BSET	#4,121(A0)
	RTS
	BSET	#3,121(A0)
	RTS
	BSET	#2,121(A0)
	RTS
	BSET	#1,121(A0)
	RTS
	BSET	#0,121(A0)
	RTS
	BSET	#7,128(A0)
	RTS
	BSET	#6,128(A0)
	RTS
	BSET	#5,128(A0)
	RTS
	BSET	#4,128(A0)
	RTS
	BSET	#3,128(A0)
	RTS
	BSET	#2,128(A0)
	RTS
	BSET	#1,128(A0)
	RTS
	BSET	#0,128(A0)
	RTS
	BSET	#7,129(A0)
	RTS
	BSET	#6,129(A0)
	RTS
	BSET	#5,129(A0)
	RTS
	BSET	#4,129(A0)
	RTS
	BSET	#3,129(A0)
	RTS
	BSET	#2,129(A0)
	RTS
	BSET	#1,129(A0)
	RTS
	BSET	#0,129(A0)
	RTS
	BSET	#7,136(A0)
	RTS
	BSET	#6,136(A0)
	RTS
	BSET	#5,136(A0)
	RTS
	BSET	#4,136(A0)
	RTS
	BSET	#3,136(A0)
	RTS
	BSET	#2,136(A0)
	RTS
	BSET	#1,136(A0)
	RTS
	BSET	#0,136(A0)
	RTS
	BSET	#7,137(A0)
	RTS
	BSET	#6,137(A0)
	RTS
	BSET	#5,137(A0)
	RTS
	BSET	#4,137(A0)
	RTS
	BSET	#3,137(A0)
	RTS
	BSET	#2,137(A0)
	RTS
	BSET	#1,137(A0)
	RTS
	BSET	#0,137(A0)
	RTS
	BSET	#7,144(A0)
	RTS
	BSET	#6,144(A0)
	RTS
	BSET	#5,144(A0)
	RTS
	BSET	#4,144(A0)
	RTS
	BSET	#3,144(A0)
	RTS
	BSET	#2,144(A0)
	RTS
	BSET	#1,144(A0)
	RTS
	BSET	#0,144(A0)
	RTS
	BSET	#7,145(A0)
	RTS
	BSET	#6,145(A0)
	RTS
	BSET	#5,145(A0)
	RTS
	BSET	#4,145(A0)
	RTS
	BSET	#3,145(A0)
	RTS
	BSET	#2,145(A0)
	RTS
	BSET	#1,145(A0)
	RTS
	BSET	#0,145(A0)
	RTS
	BSET	#7,152(A0)
	RTS
	BSET	#6,152(A0)
	RTS
	BSET	#5,152(A0)
	RTS
	BSET	#4,152(A0)
	RTS
	BSET	#3,152(A0)
	RTS
	BSET	#2,152(A0)
	RTS
	BSET	#1,152(A0)
	RTS
	BSET	#0,152(A0)
	RTS
	BSET	#7,153(A0)
	RTS
	BSET	#6,153(A0)
	RTS
	BSET	#5,153(A0)
	RTS
	BSET	#4,153(A0)
	RTS
	BSET	#3,153(A0)
	RTS
	BSET	#2,153(A0)
	RTS
	BSET	#1,153(A0)
	RTS
	BSET	#0,153(A0)
	RTS

CODEA	BCLR	#7,(A0)		12
	RTS			16
	NOP
	BCLR	#6,(A0)
	RTS
	NOP
	BCLR	#5,(A0)
	RTS
	NOP
	BCLR	#4,(A0)
	RTS
	NOP
	BCLR	#3,(A0)
	RTS
	NOP
	BCLR	#2,(A0)
	RTS
	NOP
	BCLR	#1,(A0)
	RTS
	NOP
	BCLR	#0,(A0)
	RTS
	NOP
	BCLR	#7,1(A0)		16
	RTS			16
	BCLR	#6,1(A0)
	RTS
	BCLR	#5,1(A0)
	RTS
	BCLR	#4,1(A0)
	RTS
	BCLR	#3,1(A0)
	RTS
	BCLR	#2,1(A0)
	RTS
	BCLR	#1,1(A0)
	RTS
	BCLR	#0,1(A0)
	RTS
	BCLR	#7,8(A0)
	RTS
	BCLR	#6,8(A0)
	RTS
	BCLR	#5,8(A0)
	RTS
	BCLR	#4,8(A0)
	RTS
	BCLR	#3,8(A0)
	RTS
	BCLR	#2,8(A0)
	RTS
	BCLR	#1,8(A0)
	RTS
	BCLR	#0,8(A0)
	RTS
	BCLR	#7,9(A0)
	RTS
	BCLR	#6,9(A0)
	RTS
	BCLR	#5,9(A0)
	RTS
	BCLR	#4,9(A0)
	RTS
	BCLR	#3,9(A0)
	RTS
	BCLR	#2,9(A0)
	RTS
	BCLR	#1,9(A0)
	RTS
	BCLR	#0,9(A0)
	RTS
	BCLR	#7,16(A0)
	RTS
	BCLR	#6,16(A0)
	RTS
	BCLR	#5,16(A0)
	RTS
	BCLR	#4,16(A0)
	RTS
	BCLR	#3,16(A0)
	RTS
	BCLR	#2,16(A0)
	RTS
	BCLR	#1,16(A0)
	RTS
	BCLR	#0,16(A0)
	RTS
	BCLR	#7,17(A0)
	RTS
	BCLR	#6,17(A0)
	RTS
	BCLR	#5,17(A0)
	RTS
	BCLR	#4,17(A0)
	RTS
	BCLR	#3,17(A0)
	RTS
	BCLR	#2,17(A0)
	RTS
	BCLR	#1,17(A0)
	RTS
	BCLR	#0,17(A0)
	RTS
	BCLR	#7,24(A0)
	RTS
	BCLR	#6,24(A0)
	RTS
	BCLR	#5,24(A0)
	RTS
	BCLR	#4,24(A0)
	RTS
	BCLR	#3,24(A0)
	RTS
	BCLR	#2,24(A0)
	RTS
	BCLR	#1,24(A0)
	RTS
	BCLR	#0,24(A0)
	RTS
	BCLR	#7,25(A0)
	RTS
	BCLR	#6,25(A0)
	RTS
	BCLR	#5,25(A0)
	RTS
	BCLR	#4,25(A0)
	RTS
	BCLR	#3,25(A0)
	RTS
	BCLR	#2,25(A0)
	RTS
	BCLR	#1,25(A0)
	RTS
	BCLR	#0,25(A0)
	RTS
	BCLR	#7,32(A0)
	RTS
	BCLR	#6,32(A0)
	RTS
	BCLR	#5,32(A0)
	RTS
	BCLR	#4,32(A0)
	RTS
	BCLR	#3,32(A0)
	RTS
	BCLR	#2,32(A0)
	RTS
	BCLR	#1,32(A0)
	RTS
	BCLR	#0,32(A0)
	RTS
	BCLR	#7,33(A0)
	RTS
	BCLR	#6,33(A0)
	RTS
	BCLR	#5,33(A0)
	RTS
	BCLR	#4,33(A0)
	RTS
	BCLR	#3,33(A0)
	RTS
	BCLR	#2,33(A0)
	RTS
	BCLR	#1,33(A0)
	RTS
	BCLR	#0,33(A0)
	RTS
	BCLR	#7,40(A0)
	RTS
	BCLR	#6,40(A0)
	RTS
	BCLR	#5,40(A0)
	RTS
	BCLR	#4,40(A0)
	RTS
	BCLR	#3,40(A0)
	RTS
	BCLR	#2,40(A0)
	RTS
	BCLR	#1,40(A0)
	RTS
	BCLR	#0,40(A0)
	RTS
	BCLR	#7,41(A0)
	RTS
	BCLR	#6,41(A0)
	RTS
	BCLR	#5,41(A0)
	RTS
	BCLR	#4,41(A0)
	RTS
	BCLR	#3,41(A0)
	RTS
	BCLR	#2,41(A0)
	RTS
	BCLR	#1,41(A0)
	RTS
	BCLR	#0,41(A0)
	RTS
	BCLR	#7,48(A0)
	RTS
	BCLR	#6,48(A0)
	RTS
	BCLR	#5,48(A0)
	RTS
	BCLR	#4,48(A0)
	RTS
	BCLR	#3,48(A0)
	RTS
	BCLR	#2,48(A0)
	RTS
	BCLR	#1,48(A0)
	RTS
	BCLR	#0,48(A0)
	RTS
	BCLR	#7,49(A0)
	RTS
	BCLR	#6,49(A0)
	RTS
	BCLR	#5,49(A0)
	RTS
	BCLR	#4,49(A0)
	RTS
	BCLR	#3,49(A0)
	RTS
	BCLR	#2,49(A0)
	RTS
	BCLR	#1,49(A0)
	RTS
	BCLR	#0,49(A0)
	RTS
	BCLR	#7,56(A0)
	RTS
	BCLR	#6,56(A0)
	RTS
	BCLR	#5,56(A0)
	RTS
	BCLR	#4,56(A0)
	RTS
	BCLR	#3,56(A0)
	RTS
	BCLR	#2,56(A0)
	RTS
	BCLR	#1,56(A0)
	RTS
	BCLR	#0,56(A0)
	RTS
	BCLR	#7,57(A0)
	RTS
	BCLR	#6,57(A0)
	RTS
	BCLR	#5,57(A0)
	RTS
	BCLR	#4,57(A0)
	RTS
	BCLR	#3,57(A0)
	RTS
	BCLR	#2,57(A0)
	RTS
	BCLR	#1,57(A0)
	RTS
	BCLR	#0,57(A0)
	RTS
	BCLR	#7,64(A0)
	RTS
	BCLR	#6,64(A0)
	RTS
	BCLR	#5,64(A0)
	RTS
	BCLR	#4,64(A0)
	RTS
	BCLR	#3,64(A0)
	RTS
	BCLR	#2,64(A0)
	RTS
	BCLR	#1,64(A0)
	RTS
	BCLR	#0,64(A0)
	RTS
	BCLR	#7,65(A0)
	RTS
	BCLR	#6,65(A0)
	RTS
	BCLR	#5,65(A0)
	RTS
	BCLR	#4,65(A0)
	RTS
	BCLR	#3,65(A0)
	RTS
	BCLR	#2,65(A0)
	RTS
	BCLR	#1,65(A0)
	RTS
	BCLR	#0,65(A0)
	RTS
	BCLR	#7,72(A0)
	RTS
	BCLR	#6,72(A0)
	RTS
	BCLR	#5,72(A0)
	RTS
	BCLR	#4,72(A0)
	RTS
	BCLR	#3,72(A0)
	RTS
	BCLR	#2,72(A0)
	RTS
	BCLR	#1,72(A0)
	RTS
	BCLR	#0,72(A0)
	RTS
	BCLR	#7,73(A0)
	RTS
	BCLR	#6,73(A0)
	RTS
	BCLR	#5,73(A0)
	RTS
	BCLR	#4,73(A0)
	RTS
	BCLR	#3,73(A0)
	RTS
	BCLR	#2,73(A0)
	RTS
	BCLR	#1,73(A0)
	RTS
	BCLR	#0,73(A0)
	RTS
	BCLR	#7,80(A0)
	RTS
	BCLR	#6,80(A0)
	RTS
	BCLR	#5,80(A0)
	RTS
	BCLR	#4,80(A0)
	RTS
	BCLR	#3,80(A0)
	RTS
	BCLR	#2,80(A0)
	RTS
	BCLR	#1,80(A0)
	RTS
	BCLR	#0,80(A0)
	RTS
	BCLR	#7,81(A0)
	RTS
	BCLR	#6,81(A0)
	RTS
	BCLR	#5,81(A0)
	RTS
	BCLR	#4,81(A0)
	RTS
	BCLR	#3,81(A0)
	RTS
	BCLR	#2,81(A0)
	RTS
	BCLR	#1,81(A0)
	RTS
	BCLR	#0,81(A0)
	RTS
	BCLR	#7,88(A0)
	RTS
	BCLR	#6,88(A0)
	RTS
	BCLR	#5,88(A0)
	RTS
	BCLR	#4,88(A0)
	RTS
	BCLR	#3,88(A0)
	RTS
	BCLR	#2,88(A0)
	RTS
	BCLR	#1,88(A0)
	RTS
	BCLR	#0,88(A0)
	RTS
	BCLR	#7,89(A0)
	RTS
	BCLR	#6,89(A0)
	RTS
	BCLR	#5,89(A0)
	RTS
	BCLR	#4,89(A0)
	RTS
	BCLR	#3,89(A0)
	RTS
	BCLR	#2,89(A0)
	RTS
	BCLR	#1,89(A0)
	RTS
	BCLR	#0,89(A0)
	RTS
	BCLR	#7,96(A0)
	RTS
	BCLR	#6,96(A0)
	RTS
	BCLR	#5,96(A0)
	RTS
	BCLR	#4,96(A0)
	RTS
	BCLR	#3,96(A0)
	RTS
	BCLR	#2,96(A0)
	RTS
	BCLR	#1,96(A0)
	RTS
	BCLR	#0,96(A0)
	RTS
	BCLR	#7,97(A0)
	RTS
	BCLR	#6,97(A0)
	RTS
	BCLR	#5,97(A0)
	RTS
	BCLR	#4,97(A0)
	RTS
	BCLR	#3,97(A0)
	RTS
	BCLR	#2,97(A0)
	RTS
	BCLR	#1,97(A0)
	RTS
	BCLR	#0,97(A0)
	RTS
	BCLR	#7,104(A0)
	RTS
	BCLR	#6,104(A0)
	RTS
	BCLR	#5,104(A0)
	RTS
	BCLR	#4,104(A0)
	RTS
	BCLR	#3,104(A0)
	RTS
	BCLR	#2,104(A0)
	RTS
	BCLR	#1,104(A0)
	RTS
	BCLR	#0,104(A0)
	RTS
	BCLR	#7,105(A0)
	RTS
	BCLR	#6,105(A0)
	RTS
	BCLR	#5,105(A0)
	RTS
	BCLR	#4,105(A0)
	RTS
	BCLR	#3,105(A0)
	RTS
	BCLR	#2,105(A0)
	RTS
	BCLR	#1,105(A0)
	RTS
	BCLR	#0,105(A0)
	RTS
	BCLR	#7,112(A0)
	RTS
	BCLR	#6,112(A0)
	RTS
	BCLR	#5,112(A0)
	RTS
	BCLR	#4,112(A0)
	RTS
	BCLR	#3,112(A0)
	RTS
	BCLR	#2,112(A0)
	RTS
	BCLR	#1,112(A0)
	RTS
	BCLR	#0,112(A0)
	RTS
	BCLR	#7,113(A0)
	RTS
	BCLR	#6,113(A0)
	RTS
	BCLR	#5,113(A0)
	RTS
	BCLR	#4,113(A0)
	RTS
	BCLR	#3,113(A0)
	RTS
	BCLR	#2,113(A0)
	RTS
	BCLR	#1,113(A0)
	RTS
	BCLR	#0,113(A0)
	RTS
	BCLR	#7,120(A0)
	RTS
	BCLR	#6,120(A0)
	RTS
	BCLR	#5,120(A0)
	RTS
	BCLR	#4,120(A0)
	RTS
	BCLR	#3,120(A0)
	RTS
	BCLR	#2,120(A0)
	RTS
	BCLR	#1,120(A0)
	RTS
	BCLR	#0,120(A0)
	RTS
	BCLR	#7,121(A0)
	RTS
	BCLR	#6,121(A0)
	RTS
	BCLR	#5,121(A0)
	RTS
	BCLR	#4,121(A0)
	RTS
	BCLR	#3,121(A0)
	RTS
	BCLR	#2,121(A0)
	RTS
	BCLR	#1,121(A0)
	RTS
	BCLR	#0,121(A0)
	RTS
	BCLR	#7,128(A0)
	RTS
	BCLR	#6,128(A0)
	RTS
	BCLR	#5,128(A0)
	RTS
	BCLR	#4,128(A0)
	RTS
	BCLR	#3,128(A0)
	RTS
	BCLR	#2,128(A0)
	RTS
	BCLR	#1,128(A0)
	RTS
	BCLR	#0,128(A0)
	RTS
	BCLR	#7,129(A0)
	RTS
	BCLR	#6,129(A0)
	RTS
	BCLR	#5,129(A0)
	RTS
	BCLR	#4,129(A0)
	RTS
	BCLR	#3,129(A0)
	RTS
	BCLR	#2,129(A0)
	RTS
	BCLR	#1,129(A0)
	RTS
	BCLR	#0,129(A0)
	RTS
	BCLR	#7,136(A0)
	RTS
	BCLR	#6,136(A0)
	RTS
	BCLR	#5,136(A0)
	RTS
	BCLR	#4,136(A0)
	RTS
	BCLR	#3,136(A0)
	RTS
	BCLR	#2,136(A0)
	RTS
	BCLR	#1,136(A0)
	RTS
	BCLR	#0,136(A0)
	RTS
	BCLR	#7,137(A0)
	RTS
	BCLR	#6,137(A0)
	RTS
	BCLR	#5,137(A0)
	RTS
	BCLR	#4,137(A0)
	RTS
	BCLR	#3,137(A0)
	RTS
	BCLR	#2,137(A0)
	RTS
	BCLR	#1,137(A0)
	RTS
	BCLR	#0,137(A0)
	RTS
	BCLR	#7,144(A0)
	RTS
	BCLR	#6,144(A0)
	RTS
	BCLR	#5,144(A0)
	RTS
	BCLR	#4,144(A0)
	RTS
	BCLR	#3,144(A0)
	RTS
	BCLR	#2,144(A0)
	RTS
	BCLR	#1,144(A0)
	RTS
	BCLR	#0,144(A0)
	RTS
	BCLR	#7,145(A0)
	RTS
	BCLR	#6,145(A0)
	RTS
	BCLR	#5,145(A0)
	RTS
	BCLR	#4,145(A0)
	RTS
	BCLR	#3,145(A0)
	RTS
	BCLR	#2,145(A0)
	RTS
	BCLR	#1,145(A0)
	RTS
	BCLR	#0,145(A0)
	RTS
	BCLR	#7,152(A0)
	RTS
	BCLR	#6,152(A0)
	RTS
	BCLR	#5,152(A0)
	RTS
	BCLR	#4,152(A0)
	RTS
	BCLR	#3,152(A0)
	RTS
	BCLR	#2,152(A0)
	RTS
	BCLR	#1,152(A0)
	RTS
	BCLR	#0,152(A0)
	RTS
	BCLR	#7,153(A0)
	RTS
	BCLR	#6,153(A0)
	RTS
	BCLR	#5,153(A0)
	RTS
	BCLR	#4,153(A0)
	RTS
	BCLR	#3,153(A0)
	RTS
	BCLR	#2,153(A0)
	RTS
	BCLR	#1,153(A0)
	RTS
	BCLR	#0,153(A0)
	RTS

	SECTION	DATA

LISTA	dc.w	0,160,320,480,640,800,960,1120,1280,1440,1600,1760
	dc.w	1920,2080,2240,2400,2560,2720,2880,3040,3200,3360
	dc.w	3520,3680,3840,4000,4160,4320,4480,4640,4800,4960
	dc.w	5120,5280,5440,5600,5760,5920,6080,6240,6400,6560
	dc.w	6720,6880,7040,7200,7360,7520,7680,7840,8000,8160
	dc.w	8320,8480,8640,8800,8960,9120,9280,9440,9600,9760
	dc.w	9920,10080,10240,10400,10560,10720,10880,11040,11200,11360
	dc.w	11520,11680,11840,12000,12160,12320,12480,12640,12800,12960
	dc.w	13120,13280,13440,13600,13760,13920,14080,14240,14400,14560
	dc.w	14720,14880,15040,15200,15360,15520,15680,15840,16000,16160
	dc.w	16320,16480,16640,16800,16960,17120,17280,17440,17600,17760
	dc.w	17920,18080,18240,18400,18560,18720,18880,19040,19200,19360
	dc.w	19520,19680,19840,20000,20160,20320,20480,20640,20800,20960
	dc.w	21120,21280,21440,21600,21760,21920,22080,22240,22400,22560
	dc.w	22720,22880,23040,23200,23360,23520,23680,23840,24000,24160
	dc.w	24320,24480,24640,24800,24960,25120,25280,25440,25600,25760
	dc.w	25920,26080,26240,26400,26560,26720,26880,27040,27200,27360
	dc.w	27520,27680,27840,28000,28160,28320,28480,28640,28800,28960
	dc.w	29120,29280,29440,29600,29760,29920,30080,30240,30400,30560
	dc.w	30720,30880,31040,31200,31360,31520,31680,31840,32000,32160
	dc.w	32320,32480,32640,32800,32960,33120,33280,33440,33600,33760
	dc.w	33920,34080,34240,34400,34560,34720,34880,35040,35200,35360
	dc.w	35520,35680,35840,36000,36160,36320,36480,36640,36800,36960
	dc.w	37120,37280,37440,37600,37760,37920,38080,38240,38400,38560
	dc.w	38720,38880,39040,39200,39360,39520,39680,39840,40000,40160
	dc.w	40320,40480,40640,40800,40960,41120,41280,41440,41600,41760

***************************
* 			  *
* Detta program tar bort  *
* bordrarna runt sk„rmen! *
* Man f†r dessutom 270    *
* rader i grafik-minnet!  *
* Du b”r d„rf”r flytta    *
* sk„rmminnet till en     *
* annan adress. Detta     *
* m†ste inte g”ras f”r    *
* att rutinen ska funka!  *
* Tryck ESC f”r att komma *
* ut!			  *
*			  *
***************************



** Supervisor

	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

** Starta borderrutin

	jsr	Starta

** V„nta p† ESC!

loop	cmp.b	#1,$edb
	beq	slut
	jmp	loop

** Stoppa borderrutin

slut	jsr	Stoppa


** S„tt tillbaka till 50 Hz

	move.b	#2,$ff820a

** Avsluta

	move.w	#0,-(a7)
	trap	#1



***** Starta - Rutinen *****

Starta	MOVE.L	$70.W,SAVEVBI
	MOVE.L	$120.W,SAVEHBI
	MOVE.B	$FFFFFA07,Sreg1
	MOVE.B	$FFFFFA09,Sreg2
	MOVE.B	$FFFFFA0F,Sreg3
	MOVE.B	$FFFFFA11,Sreg4
	MOVE.B	$FFFFFA1B,Sreg5

	ANDI.B	#$DF,$FFFA09
	ANDI.B	#$FE,$FFFA07
	MOVE.B	#$64,$FFFA21
	MOVE.L	#HBI1,$120
	MOVE.L	#VBI,$70
	ORI.B	#1,$FFFFFA07
	ORI.B	#1,$FFFFFA13
	RTS


*** Mellan - rutin (Wait vbl)

Mellan	CMPI.W	#1,VSYNC
	BNE	Mellan
	MOVE.W	#0,VSYNC
	RTS


*** Stoppa interupt-rutin

Stoppa	MOVE.L	SAVEVBI,$70
	MOVE.L	SAVEHBI,$120
	MOVE.B	Sreg1,$FFFFFA07
	MOVE.B	Sreg2,$FFFFFA09
	MOVE.B	Sreg3,$FFFFFA0F
	MOVE.B	Sreg4,$FFFFFA11
	MOVE.B	Sreg5,$FFFFFA1B
	RTS


**** Interupt-rutiner

*** Hblank-rutin nr 1

HBI1	MOVE.B	#2,$FFFF820A.W
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.B	#0,$FFFF820A.W

	CLR.B	$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	MOVE.B	#0,$FFFFFA1B.W
	MOVE.B	#$18,$FFFFA21
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.L	#HBI2,$120
	RTE

**** Hblank-rutin nr 2

HBI2	MOVE.B	#2,$FFFF820A.W
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.B	#0,$FFFF820A.W

	CLR.B	$FFFFFA1B.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE

** VBI-rutin

VBI	MOVE.B	#2,$FFFF820A.W

	MOVE.W	#$92,D0
NOPLOOP	NOP
	NOP
	NOP
	NOP
	NOP
	DBF	D0,NOPLOOP

	MOVE.B	#0,$FFFF820A.W

	MOVE.W	#1,VSYNC
	CLR.B	$FFFFFA1B.W
	MOVE.B	#$C8,$FFFA21
	MOVE.L	#HBI1,$120
	MOVE.B	#8,$FFFA1B
	RTE


section data

VSYNC	dc.w	0

SAVEVBI	dc.l	0
SAVEHBI	dc.l	0

Sreg1	dc.b	0
Sreg2	dc.b	0
Sreg3	dc.b	0
Sreg4	dc.b	0
Sreg5	dc.b	0



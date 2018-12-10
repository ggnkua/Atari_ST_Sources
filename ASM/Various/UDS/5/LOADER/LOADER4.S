	move.w	d0,minne
	move.w	d1,meny
	move.w	d2,stste
*	JSR	SETSUPER
	JSR	SETPREDISTTEXT
	JSR	FIXCURVE
	JSR	FIXSINCURVE
LOADER:	
	JSR	BLACKOUT
	JSR	LOADMENU
	CMP.W	#6,PART
	BNE	NOFRACTAL
	JSR	PREPARE
	JSR	LOADPART2
	JMP	LOADER
NOFRACTAL:
	JSR	PREPARE
	JSR	LOADPART
	JMP	LOADER
BLACKOUT:
	MOVE.L	#$ff8240,a0
	REPT 	8
	CLR.L	(a0)+
	ENDR
	RTS
LOADMENU:
	CMP.W	#0,meny
	bne	altmeny
	JSR	PREPARE
	jsr	LOADMAINMENU
	MOVE.W	D0,PART
	RTS	
altmeny:
	jsr	LOADALTMENU
	MOVE.W	D0,PART
	RTS	
***************************************************************************	
READSECTOR:
	MOVE.W	#0,-(SP)	* ENHET
	MOVE.W	START,-(SP)	* STARTSEKTOR
	MOVE.W	ANTAL,-(SP)	* ANTAL
	MOVE.L	#$19000,-(SP)	* BUFFERT ADDRESS
	MOVE.W	#0,-(SP)	* SKRIV
	MOVE.W	#4,-(SP)
	TRAP	#13
	LEA	14(SP),SP
	RTS
***************************************************************************	
CHOOSEPART:
	MOVE.L	#SECTORS,A0
	CLR.L	D0
	MOVE.W	PART,D0
	MULS	#4,D0
	ADD.W	D0,A0
	MOVE.W	(A0)+,START
	MOVE.W	(A0)+,ANTAL
	RTS
***************************************************************************	
PREPARE:
	JSR	SETSCREEN
	JSR	CLEARSCREENS
	MOVE.L	#SLOGOCURVE,SLOGOCURVEPTR
	CLR.L	SINCURVEPTR
	CLR.L	OLDSCURVEPTR
	CLR.L	OLDSCURVEPTR2
	CLR.L	SINCURVEPTR_2
	CLR.L	OLDSCURVEPTR_2
	CLR.L	OLDSCURVEPTR2_2
	CLR.L	DISTTEXTPTR
	CLR.W	DISTTEXTPTRP
	JSR	SETVAR
	MOVE.W	#299,D6
	PRELOOP:
		JSR	INCREASESINCURVES
		JSR	CLRSINCURVE
		JSR	SHOWSINCURVE
		JSR	CLRSINCURVE_2
		JSR	SHOWSINCURVE_2
	DBRA	D6,PRELOOP	
	JSR	INIT
	RTS
***************************************************************************	
LOADPART:
	JSR	CHOOSEPART
	MOVE.W	#0,DISTTEXTPTRP
	JSR	READSECTOR
	MOVE.W	#4608,DISTTEXTPTRP
	MOVE.L	#$19000,A0
	JSR	ice_decrunch_2
	JSR	RELOCATE
	JSR	RETINIT
	JSR	$19000
	RTS
***************************************************************************	
LOADMAINMENU:
	MOVE.W	#11,PART
	JSR	CHOOSEPART
	MOVE.W	#0,DISTTEXTPTRP
	JSR	READSECTOR
	MOVE.W	#4608,DISTTEXTPTRP
	MOVE.L	#$19000,A0
	JSR	ice_decrunch_2
	JSR	RELOCATE
	JSR	RETINIT
	MOVE.W	minne,d0
	MOVE.W	stste,d1
	JSR	$19000
	RTS
***************************************************************************	
LOADALTMENU:
	CLR.W	PART
	JSR	CHOOSEPART
	MOVE.W	#0,DISTTEXTPTRP
	JSR	READSECTOR
	MOVE.W	#4608,DISTTEXTPTRP
	MOVE.L	#$19000,A0
	JSR	ice_decrunch_2
	JSR	RELOCATE
	move.w	minne,d0
	move.w	stste,d1
	JSR	$19000
	RTS
***************************************************************************	
LOADPART2:
	JSR	CHOOSEPART
	MOVE.W	#0,DISTTEXTPTRP
	JSR	READSECTOR
	JSR	RETINIT
	MOVE.L	#$19000,A0
	JSR	ice_decrunch_2
	JSR	RELOCATE
	JSR	$19000
	RTS
*******************************
*         SUB - ROUTS         *
*******************************
SETSUPER:
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,SAVESUPER
	RTS
ENDSUPER:
	MOVE.L	SAVESUPER,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	RTS
*******************************
SETVAR:
	MOVE.L	#SINCURVE,SINCURVEPTR
	MOVE.L	#SINCURVE,OLDSCURVEPTR
	MOVE.L	#SINCURVE_2,SINCURVEPTR_2
	MOVE.L	#SINCURVE_2,OLDSCURVEPTR_2
	MOVE.L	#$00000777,$FF8240
	MOVE.L	#$00060777,$FF8244
	MOVE.L	#$00060777,$FF8248
	MOVE.L	#$00070777,$FF824C
	RTS
*******************************
SETSCREEN:
	MOVE.W	#0,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.W	#$5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	RTS
*******************************
SCREENSWAP:
	MOVE.W	#-1,-(SP)
	MOVE.L	$44E,-(SP)
	MOVE.L	$44E,-(SP)
	MOVE.W	#$5,-(SP)
	TRAP	#14
	ADD.L	#12,SP

	CMP.L	#$70000,$44E
	BEQ	SCREENSWAP2
	MOVE.L	#$70000,$44E
	RTS
SCREENSWAP2:
	MOVE.L	#$78000,$44E
	RTS
*******************************
INIT:
	jsr	music
	MOVE.W	 #$2700,SR
	MOVE.L	 $70.W,OLDVBL
	MOVE.L	 $120.W,OLDHBL
	MOVE.B	 $FFFFFA07.W,OLD07	
	MOVE.B	 $FFFFFA09.W,OLD09
	MOVE.B 	 $FFFFFA13.W,OLD13
	MOVE.B	 $FFFFFA1B.W,OLD1B	
	MOVE.L	 #NEWVBL,$70.W
	MOVE.L	 #NEWHBL,$120.W
	CLR.B	 $FFFFFA07.W	
	CLR.B 	 $FFFFFA09.W
	ORI.B 	 #1,$FFFFFA07.W	
	ORI.B 	 #1,$FFFFFA13.W
	CLR.B 	 $FFFFFA1B.W	
	MOVE.W 	 #$2300,SR	
	RTS
RETINIT:
	MOVE.W	 #$2700,SR
	MOVE.L	 OLDVBL,$70.W
	MOVE.L	 OLDHBL,$120.W
	MOVE.B	 OLD07,$FFFFFA07.W
	MOVE.B	 OLD09,$FFFFFA09.W
	MOVE.B 	 OLD13,$FFFFFA13.W
	MOVE.B	 OLD1B,$FFFFFA1B.W
	MOVE.W 	 #$2300,SR	
	move.l	#$08080000,$ff8800
	move.l	#$09090000,$ff8800
	move.l	#$0a0a0000,$ff8800
	MOVE.L	#$ff8240,a0
	rept	8
	clr.l	(a0)+
	endr
	RTS
*******************************
CLEARSCREENS:
	MOVE.L	#$70000,A0
	MOVE.L	#$78000,A1
	MOVE.W	#7999,D0
CLEARSCREENSLOOP:
	CLR.L	(A0)+
	CLR.L	(A1)+
	DBF.W	D0,CLEARSCREENSLOOP
	RTS
*******************************
WAITVBL:
	CMP.W	#1,WFNC
	BNE.S	WAITVBL
	MOVE.W	#0,WFNC
	RTS
*******************************
* FIX SINUS CURVE TO SCR.FORM *
*******************************
FIXSINCURVE:
	MOVE.L	#SINCURVE,A0
	MOVE.L	#SINCURVE,A1
	MOVE.L	#NIBBLES,A2
	MOVE.L	#(1080*2*2)-1,D3
FIXSINCURVELOOP:
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1

	MULS	#160,D1
	MOVE.W	D0,D2
	AND.W	#$FFF0,D2
	ASR.W	D2
	ADD.W	D2,D1
	AND.W	#$000F,D0
	ASL.W	D0
	MOVE.W	(A2,D0.W),D0
	MOVE.W	D1,(A1)+
	MOVE.W	D0,(A1)+
	DBF.W	D3,FIXSINCURVELOOP
	RTS
*******************************
*   PUT SINUSCURVE ON SCREEN  * 
*******************************
INCREASESINCURVES:
	ADDQ.L	#4,SINCURVEPTR
	CMP.L	#SINCURVEEND,SINCURVEPTR
	BNE	NORESTORESINCURVE
	MOVE.L	#SINCURVE,SINCURVEPTR
NORESTORESINCURVE:
	ADDQ.L	#4,SINCURVEPTR_2
	CMP.L	#SINCURVEEND_2,SINCURVEPTR_2
	BNE	NORESTORESINCURVE_2
	MOVE.L	#SINCURVE_2,SINCURVEPTR_2
NORESTORESINCURVE_2:
	RTS
*******************************
SHOWSINCURVE:
	CLR.L	D1
	CLR.L	D2
	MOVE.L	SINCURVEPTR,A0
	MOVE.L	#$70000,A1
	MOVE.L	#$78000,A2
	MOVE.W	1200(A0),D1
	MOVE.W	1202(A0),D2
	MOVE.W	2(A1,D1.W),D3
	BSET	D2,D3
	MOVE.W	D3,2(A1,D1.W)
	MOVE.W	D3,2(A2,D1.W)
	RTS
*******************************
CLRSINCURVE:
	CLR.L	D1
	CLR.L	D2
	MOVE.L	SINCURVEPTR,A0
	MOVE.L	#$70000,A1
	MOVE.L	#$78000,A2
	MOVE.W	(A0),D1
	MOVE.W	2(A0),D2
	MOVE.W	2(A1,D1.W),D3
	BCLR	D2,D3
	MOVE.W	D3,2(A1,D1.W)
	MOVE.W	D3,2(A2,D1.W)
	RTS
*******************************
SHOWSINCURVE_2:
	CLR.L	D1
	CLR.L	D2
	MOVE.L	SINCURVEPTR_2,A0
	MOVE.L	#$70000,A1
	MOVE.L	#$78000,A2
	MOVE.W	1200(A0),D1
	MOVE.W	1202(A0),D2
	MOVE.W	4(A1,D1.W),D3
	BSET	D2,D3
	MOVE.W	D3,4(A1,D1.W)
	MOVE.W	D3,4(A2,D1.W)
	RTS
*******************************
CLRSINCURVE_2:
	CLR.L	D1
	CLR.L	D2
	MOVE.L	SINCURVEPTR_2,A0
	MOVE.L	#$70000,A1
	MOVE.L	#$78000,A2
	MOVE.W	(A0),D1
	MOVE.W	2(A0),D2
	MOVE.W	4(A1,D1.W),D3
	BCLR	D2,D3
	MOVE.W	D3,4(A1,D1.W)
	MOVE.W	D3,4(A2,D1.W)
	RTS
*******************************
*   1 - PIXEL DISTING LOGO    * 
*******************************
FIXCURVE:
	LEA	SLOGOCURVE,A0
	MOVE.W	#720*2-1,D0
FIXCURVELOOP:
	CLR.L	D1
	MOVE.W	(A0),D1	
	MULS	#160,D1
	MOVE.W	D1,(A0)+
	DBF.W	D0,FIXCURVELOOP
*******************************
GETNEWCURVEP:
	ADDQ.L	#2,SLOGOCURVEPTR
	CMP.L	#SLOGOCURVEEND,SLOGOCURVEPTR
	BNE	GETNEWCURVEPEND
	MOVE.L	#SLOGOCURVE,SLOGOCURVEPTR
GETNEWCURVEPEND:
	RTS
*******************************
SETPREDISTTEXT:
	MOVE.L	#DISTTEXTBUFF,A0
	MOVE.L	#DISTTEXT,DISTTEXTPTR
	MOVE.L	#1,D7
SETPREDISTTEXTLOOP:
	CLR.L	D0
	MOVE.L	DISTTEXTPTR,A1
	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BEQ	SETPREDISTWRAP
	MOVE.L	A1,DISTTEXTPTR
	SUB.W	#32,D0
	MULS.W	#16*2,D0

	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%1000000000000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0100000000000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0010000000000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0001000000000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000100000000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000010000000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000001000000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000100000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000010000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000001000000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000000100000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000000010000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000000001000,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000000000100,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000000000010,D1
	MOVE.W	D1,(A0)+
	ENDR
	MOVE.L	#FONT+34,A1
	ADD.W	D0,A1
	REPT	16
	CLR.L	D1
	MOVE.W	(A1)+,D1
	AND.W	#%0000000000000001,D1
	MOVE.W	D1,(A0)+
	ENDR
	BRA	SETPREDISTTEXTLOOP
SETPREDISTWRAP:
	MOVE.L	#DISTTEXT2,DISTTEXTPTR
	DBF.W	D7,SETPREDISTTEXTLOOP
	RTS
*******************************
SETDISTTEXT:
	MOVE.L	#DISTTEXTBUFF,A0
	ADD.W	DISTTEXTPTRP,A0
	MOVE.L	$44E,A1
	SUB.W	#160*5+120,A1
	MOVE.L	SLOGOCURVEPTR,A2
	MOVE.W	#8,D7
	CLR.L	D0
SETDISTTEXTLOOP:
	REPT	16
	MOVE.W	(A2)+,D0
	MOVE.L	A1,A3
	ADD.W	D0,A3

	MOVE.W	(A0)+,D1
	OR.W	D1,(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,2*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,3*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,4*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,5*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,6*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,7*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,8*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,9*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,10*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,11*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,12*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,13*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,14*160(A3)
	MOVE.W	(A0)+,D1
	OR.W	D1,15*160(A3)
	ENDR			
	ADDQ.W	#8,A1
	DBF.W	D7,SETDISTTEXTLOOP
	RTS	
*******************************
CLRDISTTEXT:
	MOVE.L	#DISTTEXTBUFF,A0
	ADD.W	DISTTEXTPTRP,A0
	MOVE.L	$44E,A1
	SUB.W	#160*5+120,A1
	MOVE.L	SLOGOCURVEPTR,A2
	MOVE.W	#8,D7
CLRDISTTEXTLOOP:
	MOVE.W	(A2),D0
	MOVE.W	32(A2),D1
	MOVE.L	A1,A3
	MOVE.L	A1,A4
	ADD.W	#32,A2
	ADD.W	D0,A3
	ADD.W	D1,A4
	CLR.W	-160*5(A3)
	CLR.W	-160*4(A3)
	CLR.W	-160*3(A3)
	CLR.W	-160*2(A3)
	CLR.W	-160(A3)
	CLR.W	(A3)
	CLR.W	160(A3)
	CLR.W	160*2(A3)
	CLR.W	160*3(A3)
	CLR.W	160*4(A3)
	CLR.W	160*5(A3)
	CLR.W	160*6(A3)
	CLR.W	160*7(A3)
	CLR.W	160*8(A3)
	CLR.W	160*9(A3)
	CLR.W	160*10(A3)
	CLR.W	160*11(A3)
	CLR.W	160*12(A3)
	CLR.W	160*13(A3)
	CLR.W	160*14(A3)
	CLR.W	160*15(A3)
	CLR.W	160*16(A3)
	CLR.W	160*17(A3)
	CLR.W	160*18(A3)
	CLR.W	160*19(A3)
	CLR.W	160*20(A3)
	CLR.W	-160*5(A4)
	CLR.W	-160*4(A4)
	CLR.W	-160*3(A4)
	CLR.W	-160*2(A4)
	CLR.W	-160(A4)
	CLR.W	(A4)
	CLR.W	160(A4)
	CLR.W	160*2(A4)
	CLR.W	160*3(A4)
	CLR.W	160*4(A4)
	CLR.W	160*5(A4)
	CLR.W	160*6(A4)
	CLR.W	160*7(A4)
	CLR.W	160*8(A4)
	CLR.W	160*9(A4)
	CLR.W	160*10(A4)
	CLR.W	160*11(A4)
	CLR.W	160*12(A4)
	CLR.W	160*13(A4)
	CLR.W	160*14(A4)
	CLR.W	160*15(A4)
	CLR.W	160*16(A4)
	CLR.W	160*17(A4)
	CLR.W	160*18(A4)
	CLR.W	160*19(A4)
	CLR.W	160*20(A4)
	ADDQ.W	#8,A1
	DBF.W	D7,CLRDISTTEXTLOOP
	RTS
*******************************
*            VBL              * 
*******************************
NEWVBL:
	MOVEM.L	d0-d7/a0-a6,-(sp)
	MOVE.W	#$000,$FF8240
	jsr	music+8
	MOVE.L	#NEWHBL,$120.W
	MOVE.B 	#1,$FFFFFA21.W	
	MOVE.B 	#8,$FFFFFA1B.W	

	JSR	CLRDISTTEXT
	JSR	SETDISTTEXT
	JSR	GETNEWCURVEP
	JSR	GETNEWCURVEP
	JSR	GETNEWCURVEP

	JSR	INCREASESINCURVES
	JSR	CLRSINCURVE
	JSR	SHOWSINCURVE
	JSR	CLRSINCURVE_2
	JSR	SHOWSINCURVE_2

	JSR	SCREENSWAP

	MOVE.W	#1,WFNC
	MOVEM.L	(sp)+,d0-d7/a0-a6
	RTE
*******************************
NEWHBL:
	CLR.B	$FFFFFA1B.W
	MOVE.W	#$227,$FF8240
	MOVE.L	#NEWHBL2,$120.W
	MOVE.B 	#1,$FFFFFA21.W	
	MOVE.B 	#8,$FFFFFA1B.W	
	BCLR 	#0,$FFFFFA0F.W	
	RTE			
NEWHBL2:
	MOVE.W	#$004,$FF8240
	CLR.B	$FFFFFA1B.W
	MOVE.L	#NEWHBL3,$120.W
	MOVE.B 	#197,$FFFFFA21.W	
	MOVE.B 	#8,$FFFFFA1B.W	
	BCLR 	#0,$FFFFFA0F.W	
	RTE			
NEWHBL3:
	MOVE.W	#$227,$FF8240
	CLR.B	$FFFFFA1B.W
	MOVE.L	#NEWHBL4,$120.W
	MOVE.B 	#1,$FFFFFA21.W	
	MOVE.B 	#8,$FFFFFA1B.W	
	BCLR 	#0,$FFFFFA0F.W	
	RTE			
NEWHBL4:
	MOVE.W	#$000,$FF8240
	CLR.B	$FFFFFA1B.W
	BCLR 	#0,$FFFFFA0F.W	
	RTE			
***************************************************************************	
RELOCATE:	
	MOVE.L  #$19000,A0  
	MOVE.L  2(A0),D0  
	ADD.L   6(A0),D0  
	ADD.L   14(A0),D0 

	ADD.L   #$1C,A0   
	MOVE.L  A0,A1     
	MOVE.L  A1,A2     
	MOVE.L  #$19000,d1
	ADD.W	#$1c,D1   

	ADD.L   D0,A1     
	MOVE.L  (A1)+,D0  
	ADD.L   D0,A2     
	ADD.L   D1,(A2)   
	CLR.L   D0        
RELO:	
	MOVE.B  (A1)+,D0  
	BEQ     RELEND    
	CMP.B   #1,D0     
	BEQ     RELOJUMP      
	ADD.L   D0,A2     
	ADD.L   D1,(A2)   
	BRA     RELO      
RELOJUMP:	
	ADD.L   #254,A2   
	BRA     RELO      
RELEND:
	RTS
********************************;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
	bne	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_Åber
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_2:
;************************************************** end of unpacking routine
*******************************
*          VARIABLES          *
*******************************
SAVESUPER:	DC.L	0
OLDVBL:		DC.L	0
OLDHBL:		DC.L	0
OLD07:		DC.B	0
OLD09:		DC.B	0
OLD13:		DC.B	0
OLD1B:		DC.B	0
WFNC:		DC.W	0
PART:		DC.W	0
START:		DC.W	0
ANTAL:		DC.W	0
minne:		DC.W	0
meny:		DC.W	0
stste:		DC.W	0
SINCURVEPTR:	DC.L	0
OLDSCURVEPTR:	DC.L	0
OLDSCURVEPTR2:	DC.L	0
SINCURVEPTR_2:	DC.L	0
OLDSCURVEPTR_2:	DC.L	0
OLDSCURVEPTR2_2:DC.L	0
DISTTEXTPTR:	DC.L	0
DISTTEXTPTRP:	DC.W	0
SLOGOCURVEPTR:	DC.L	SLOGOCURVE
NIBBLES:	DC.W	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
		DC.W	$8000,$4000,$2000,$1000,$800,$400,$200,$100,$80,$40,$20,$10,$8,$4,$2,$1
SECTORS:	DC.W	222,42	  * ALTERNATIVE MENU
		DC.W	265,86	  * CHROME CORNY
		DC.W	352,77	  * ALWAYS ULTRA
		DC.W	508,35	  * MAGGOT MASTER
		DC.W	508,35	  * WHY NOT
		DC.W	430,77	  * MIXTURE
		DC.W	661,130	  * BANAL FRACTAL
		DC.W	543,117	  * EXHUMAN
		DC.W	508,35	  * BOBO SCREEN 2
		DC.W	508,35	  * IQ PQ SCREEN
		DC.W	508,35	  * TOILET DEMO 2
		DC.W	1390,109  * MAIN MENU
DISTTEXT:	DC.B	' LOADING ',$FF
DISTTEXT2:	DC.B	'DEPACKING',$FF
FONT:		INCBIN	A:\LOADER\16FONT1.DAT
SLOGOCURVE:	INCLUDE	A:\LOADER\BDISTCUR.DAT
SLOGOCURVEEND:	INCLUDE	A:\LOADER\BDISTCUR.DAT
SINCURVE:	INCLUDE	A:\LOADER\BRAIN.DAT
SINCURVEEND:	INCLUDE	A:\LOADER\BRAIN.DAT
SINCURVE_2:	INCLUDE	A:\LOADER\BLOMMA.DAT
SINCURVEEND_2:	INCLUDE	A:\LOADER\BLOMMA.DAT
		EVEN
music:		incbin	a:\loader\overlord.thk
DISTTEXTBUFF:	DCB.B	5120,0
DISTTEXTBUFF2:	DCB.B	5120,0

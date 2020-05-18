;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~ Coquille en *.APP ou *.ACC pour la routine CPU_MOD.BIN ~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;-------------------------------------------------------------------------------
;Error.B = CPU_MOD( Cmd.W , 0.W , Mo_St.W , Freq.W , MOD_Ad.L , MOD_Ln.L)
;D0		    SP+4	  SP+8	    SP+10    SP+12	SP+16

;Error= 0:No error
;      -1:Error (Power OFF ? , Incorrect module ? , No module ?)

;Cmd=	 0:-
;	 1:Power OFF/ON 					[P]
;	 2:Open new module at address=MOD_Ad and length=MOD_Ln	[L]
;	 3:Pause/Play						[SP]
;	 4:Stop 						[-]
;	 5:Song position Reverse Search 			[(]
;	 6:Song position Forward Search 			[)]
;	 7:Fast Forward OFF/ON					[+]
;	 8:Repeat mode OFF/ON					[.]

;Mo_St= 0:-
;	1:Mono/Stereo						[*]

;Freq=	0:-
;	1: 6258 Hz						[3]
;	2:12517 Hz						[2]
;	3:25033 Hz						[1]
;	4:50066 Hz						[0]
;-------------------------------------------------------------------------------
;Pour le Formulaire
;	Fin							[CR]
;-------------------------------------------------------------------------------

ModuleLength=512*1024

	INCLUDE "CPU_MODA.INC"

	M_
VARS	DS.B 70000 ;pour CPU_MOD.BIN
	P_

	GEM_APP_ACC
	BRA	CPU_MOD_E

SUPER:	PROG_SUPER A3
	RTS

POWER:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#1
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

OPEN:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	MOVE.L	ModuleLn(PC),-(SP)
	MOVE.L	ModuleAd(PC),-(SP)
	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#2
	BSR	CPU_MOD
	ADDA	#16,SP
	RTS

PLAY:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#3
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

STOP:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#4
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

RS:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#5
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

FS:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#6
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

FF:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#7
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

REP:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	PW	#8
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

MO_ST:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	PW	#1
	CLR	-(SP)
	CLR	-(SP)
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

FREQ:	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	PW	ModuleFr(PC)
	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	BSR	CPU_MOD
	ADDQ	#8,SP
	RTS

MSE_ARROW: GRAF_MOUSE #0,A0
	RTS

MSE_PHAND: GRAF_MOUSE #3,A0
	RTS

MSE_BEGCTL: WIND_UPDATE #3
	RTS

MSE_ENDCTL: WIND_UPDATE #2
	RTS

CHANGE:
 ;E:D3=objc  A5=clip  D4=state
 ;E:D5=redraw A6=tree
	OBJC_CHANGE D3,A5,D4,D5,A6
	RTS

DRAW:
 ;E:D3=objc  D4=depth
 ;E:A5=clip  A6=tree
	OBJC_DRAW D3,D4,A5,A6
	RTS

CLICK:	EVNT_TIME #500
	RTS

TOS_ERR: ;E: D0=erreur
	NEG D0
	MOVE D0,D3
	FORM_ERROR D3
	RTS

NO_MEMORY: MOVEQ #-10,D0
	BSR TOS_ERR
	RTS

POWEROFF:
	LEA	ModulePower(PC),A0
	TST.B	(A0)
	BEQ.S	.f
	SF	(A0)
	BSR	POWER
	MOVEA.L ModuleAd(PC),A3
	MEMO_FREE A3
	LEA	ModuleLn(PC),A0
	CLR.L	(A0)
	MOVEQ	#FPower,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	BSR	CHANGE
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_POWEROFF_AD,(A0)
	MOVEA.L F_MODULETITLE,A0
	LEA	S_NUL(PC),A1
	MOVE.L	A1,(A0)
.f	RTS

DMAStatus: ;S:D0=Status
	LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	BTST	#0,SND_CR+1
	SNE	D0
	RTS

CExit:	MOVEQ	#FExit,D3
	MOVEQ	#1,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	BSR	CLICK
	MOVEQ	#0,D4
	BSR	CHANGE
	LEA	ModuleExit(PC),A0
	ST	(A0)
	RTS

CPower: LEA	ModulePower(PC),A3
	TST.B	(A3)
	BEQ.S	.on
.off	BSR	POWEROFF
	MOVEQ	#FPower,D3
	MOVEQ	#0,D4
	BSR	DRAW
	MOVEQ	#FMessage,D3
	BSR	DRAW
	MOVEQ	#FModuleTitle,D3
	BSR	DRAW
	BRA.S	.f

.on ;Allouer la mˆmoire
	MEMO_ALLOC #ModuleLength
	TST.L	D0
	BEQ.S	.nomem
	ST	(A3)
	LEA	ModuleAd(PC),A0
	MOVE.L	D0,(A0)
	BSR	POWER
;Penser … mettre en conformit‚ les paramˆtres internes
;avec les positions des boutons qui eux ne disjonctent PAS.
	MOVE.B	ModuleRep(PC),D0
	BEQ.S	.2
	BSR	REP
.2	MOVE.B	ModuleMoSt(PC),D0
	BEQ.S	.3
	BSR	MO_ST
.3	BSR	FREQ
	MOVEQ	#FPower,D3
	MOVEQ	#1,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	MOVEA.L F_MESSAGE,A3
	MOVE.L	S_STOP_AD,(A3)
	MOVEQ	#FMessage,D3
	MOVEQ	#0,D4
	BSR	DRAW
.f	BSR	CLICK
	RTS

.nomem	BSR	NO_MEMORY
	BRA	.f

CLoad:	MOVEQ	#FLoad,D3
	MOVEQ	#1,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	MOVE.B	ModulePower(PC),D0
	BNE.S	.tp
	BSR	CPower
.tp	MOVE.B	ModulePower(PC),D0
	BEQ	.fin

	MOVE.B	ModuleAuto(PC),D0
	BEQ.S	.fs
 ;Transf‚rer la Command Line dans PathnameFile
	MOVEA.L CL,A0
	LEA	PathnameFile,A1
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0 ;#car.
	SUBQ	#1,D0
.rpf	MOVE.B	(A0)+,(A1)+
	DBRA	D0,.rpf
	CLR.B	(A1)
	BRA	.load

.fs	LEA	LoadPathname,A3
	LEA	LoadFile,A4
	FILE_SELECT A3,A4,D3,S_LOAD_AD
 ;Redessin des autres fenˆtres
	BSR	MSE_ENDCTL
	BSR	CLICK
	BSR	MSE_BEGCTL
	CMPI #1,D3
	BNE	.fin

 ;Construire le PathnameFile
	LEA	PathnameFile,A2
	MOVEA.L A2,A0
	MOVEA.L A3,A1
.1	MOVE.B	(A1)+,(A0)+
	BNE	.1
	SUBQ	#1,A0
  ;Couper le filtre , c.a.d. apr‚s le dernier '\' (S'il existe)
	MOVEQ	#'\',D0
.3	CMPA.L	A2,A0
	BEQ.S	.2
	CMP.B	-(A0),D0
	BNE	.3
	ADDQ	#1,A0
.2	MOVEA.L A4,A1
.4	MOVE.B	(A1)+,(A0)+
	BNE	.4

 ;Attendre le redraw (mˆme si la souris est bloqu‚e)
	LEA	MsgeBuffer,A3
	EVNT_MESS A3
	BSR	REDRAW

.load	LEA	PathnameFile,A3
	FILE_OPEN A3,#0
	MOVE	D0,D6
	BMI	.err1

 ;"Loading ..."
	MOVEA.L F_MESSAGE,A0
	MOVEA.L (A0),A4 ;pour savoir si "Playing ..."
	MOVE.L	S_LOADING_AD,(A0)
	MOVEQ	#FMessage,D3
	MOVEQ	#0,D4
	BSR	DRAW

	BSR	STOP
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_STOP_AD,(A0)

	FILE_READ D6,#ModuleLength,ModuleAd(PC)
	LEA	ModuleLn(PC),A0
	MOVE.L	D0,(A0)
	BMI.S	.err2
.5	FILE_CLOSE D6
	BSR	OPEN
	TST.B	D0
	BNE.S	.inc

	MOVEA.L F_MODULETITLE,A0
	MOVE.L	ModuleAd(PC),A1
 ;Limiter … 20 car.
	CLR.B	20(A1)
	MOVE.L	A1,(A0)

 ;AUTO-PLAY ?
	MOVEA.L S_PLAYING_AD,A0
	CMPA.L	A4,A0
	BNE.S	.msg
	BSR.S	CPlay
	BRA.S	.tit

.msg	MOVEQ	#FMessage,D3
	MOVEQ	#0,D4
	BSR	DRAW
.tit	MOVEQ	#FModuleTitle,D3
	BSR	DRAW
.fin	BSR	CLICK
	MOVEQ	#FLoad,D3
	MOVEQ	#0,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	RTS

.err1	BSR	TOS_ERR
	BRA	.fin

.err2	CLR.L	(A0)
	BSR	TOS_ERR
	BRA	.5

.inc	LEA	ModuleLn(PC),A0
	CLR.L	(A0)
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_INCMOD_AD,(A0)
	MOVEA.L F_MODULETITLE,A0
	LEA	S_NUL(PC),A1
	MOVE.L	A1,(A0)
	BRA	.msg

CPlay:	BSR	PLAY
;	MOVEQ	#FPlay,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIPlay,D0
	MULU	D7,D0
	ADDQ	#1,16(A6,D0)
	ADDQ	#1,18(A6,D0)
	MOVE.B	ModulePower(PC),D0
	BEQ.S	.1
	MOVE.L	ModuleLn(PC),D0
	BEQ.S	.nomod
	BSR	DMAStatus
	MOVEA.L F_MESSAGE,A0
	TST.B	D0
	BNE.S	.play
.pause	MOVE.L	S_PAUSE_AD,(A0)
	BRA.S	.msg
.play	MOVE.L	S_PLAYING_AD,(A0)
.msg	MOVEQ	#FMessage,D3
	MOVEQ	#0,D4
	BSR	DRAW
.1	MOVEQ	#FPlay,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
;	MOVEQ	#FPlay,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIPlay,D0
	MULU	D7,D0
	SUBQ	#1,16(A6,D0)
	SUBQ	#1,18(A6,D0)
	BSR	DRAW
	RTS

.nomod	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_NOMOD_AD,(A0)
	BRA.S	.msg

CStop:	BSR	STOP
;	MOVEQ	#FStop,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIStop,D0
	MULU	D7,D0
	ADDQ	#1,16(A6,D0)
	ADDQ	#1,18(A6,D0)
	MOVE.B	ModulePower(PC),D0
	BEQ.S	.1
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_STOP_AD,(A0)
	MOVEQ	#FMessage,D3
	MOVEQ	#0,D4
	BSR	DRAW
.1	MOVEQ	#FStop,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
;	MOVEQ	#FStop,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIStop,D0
	MULU	D7,D0
	SUBQ	#1,16(A6,D0)
	SUBQ	#1,18(A6,D0)
	BSR	DRAW
	RTS

CRS:	BSR	RS
;	MOVEQ	#FRS,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIRS,D0
	MULU	D7,D0
	ADDQ	#1,16(A6,D0)
	ADDQ	#1,18(A6,D0)
	MOVEQ	#FRS,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
;	MOVEQ	#FRS,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIRS,D0
	MULU	D7,D0
	SUBQ	#1,16(A6,D0)
	SUBQ	#1,18(A6,D0)
	BSR	DRAW
	RTS

CFS:	BSR	FS
;	MOVEQ	#FFS,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIFS,D0
	MULU	D7,D0
	ADDQ	#1,16(A6,D0)
	ADDQ	#1,18(A6,D0)
	MOVEQ	#FFS,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
;	MOVEQ	#FFS,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIFS,D0
	MULU	D7,D0
	SUBQ	#1,16(A6,D0)
	SUBQ	#1,18(A6,D0)
	BSR	DRAW
	RTS

CFF:	BSR	FF
;	MOVEQ	#FFF,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIFF,D0
	MULU	D7,D0
	ADDQ	#1,16(A6,D0)
	ADDQ	#1,18(A6,D0)
	MOVEQ	#FFF,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
;	MOVEQ	#FFF,D0
;	MULU	D7,D0
;	BCHG	#0,11(A6,D0)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIFF,D0
	MULU	D7,D0
	SUBQ	#1,16(A6,D0)
	SUBQ	#1,18(A6,D0)
	BSR	DRAW
	RTS

CREP:	BSR	REP
	LEA	ModuleRep(PC),A0
	NOT.B	(A0)
	MOVEQ	#FRepeat,D3
	MOVE.B	(A0),D4
	ANDI	#1,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	BSR	CLICK
	RTS

CMO_ST: BSR	MO_ST
	LEA	ModuleMoSt(PC),A0
	NOT.B	(A0)
	MOVEQ	#FMo_St,D3
	MOVE.B	(A0),D4
	ANDI	#1,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	BSR	CLICK
	RTS

CFreq: ;E:D0=Freq (1-4)
	LEA	ModuleFr(PC),A0
	MOVE	(A0),D3
	CMP	D3,D0
	BEQ.S	.f
	MOVE	D0,(A0)
	BSR	FREQ
	LEA	FreqButt(PC),A3
	LSL	#1,D3
	MOVE	-2(A3,D3),D3
	MOVEQ	#0,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	MOVE	ModuleFr(PC),D3
	LSL	#1,D3
	MOVE	-2(A3,D3),D3
	MOVEQ	#1,D4
	BSR	CHANGE
.f	BSR	CLICK
	RTS

CPU_MOD_E: ;******************
E1 ;Charger le *.RSC
	LEA	RscName(PC),A3
	RSRC_LOAD A3
	TST	D0
	BNE.S	E2
	TST.B	APP
	BNE	FIN

X1	TST.B	APP
	BNE.S	.1

.2	EVNT_TIME #-1
	BRA	.2

.1	RSRC_FREE
	BRA	FIN

E2 ;En extraire les adresses
	MOVEQ	#0,D3 ;Tree
	MOVEQ	#F_CPU_MOD,D4 ;Pos
	RSRC_GADDR D3,D4
 ;Les registres affect‚s:
	MOVEA.L D0,A6		;Tree
	LEA	16(A6),A5	;Clip
	MOVEQ	#24,D7		;Objc length
	LEA	F_MESSAGE,A0
	MOVEQ	#FMessage,D0
	MULU	D7,D0
	MOVE.L	12(A6,D0),(A0)
	LEA	F_MODULETITLE,A0
	MOVEQ	#FModuleTitle,D0
	MULU	D7,D0
	MOVE.L	12(A6,D0),(A0)
E3	LEA	S_POWEROFF_AD,A3
	MOVEQ	#5,D3 ;FreeString
	MOVEQ	#S_POWEROFF,D4 ;Pos
.1	RSRC_GADDR D3,D4
	MOVE.L	D0,(A3)+
	ADDQ	#1,D4
	CMPI	#S_INCMOD,D4
	BLS	.1

E4 ;Initialiser les RSC
	LEA	WindCArea,A4
	FORM_CENTER A6,A4
 ;Pour la fantaisie:
  ;X=X+0.5W
  ;Y=Y+0.5H
  ;W=0
  ;H=0
	MOVE	6(A4),D0
	LSR	#1,D0
	ADD	D0,(A4)
	MOVE	8(A4),D0
	LSR	#1,D0
	ADD	D0,2(A4)
	CLR.L	4(A4)
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_POWEROFF_AD,(A0)
	MOVEA.L F_MODULETITLE,A0
	LEA	S_NUL(PC),A1
	MOVE.L	A1,(A0)
 ;Rendre le formulaire lisible en 2 ou 4 couleurs
  ;Couleur=0
	MOVE	SCR_REG,D0
	BEQ	E5
	CMPI	#16,D0
	BHS	E5
	MOVE.L	#$FFFFFFF0,D1
	AND.L	D1,12(A6)
	MOVEQ	#FExit,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FTitle,D0
	MULU	D7,D0
	MOVEA.L 12(A6,D0),A0
	AND	D1,18(A0)
	MOVEQ	#FOscilloscope,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FMessage,D0
	MULU	D7,D0
	MOVEA.L 12(A6,D0),A0
	AND	D1,18(A0)
	MOVEQ	#FModuleTitle,D0
	MULU	D7,D0
	MOVEA.L 12(A6,D0),A0
	AND	D1,18(A0)
	MOVEQ	#FPlay,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FStop,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FRS,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FFS,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FFF,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FRepeat,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#FMo_St,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#F6KHz,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#F12KHz,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#F25KHz,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)
	MOVEQ	#F50KHz,D0
	MULU	D7,D0
	AND.L	D1,12(A6,D0)

E5 ;Pour le chemin
	LEA	LoadFilter(PC),A0
	LEA	LoadPathname,A1
.1	MOVE.B	(A0)+,(A1)+
	BNE .1
	LEA	LoadFile,A0
	CLR.B	(A0)

E6	TST.B	APP
	BEQ.S	E7
 ;AUTO-LOAD ?
	MOVEA.L CL,A0
	TST.B	(A0)
	BEQ	CPU_MOD_O
	LEA	ModuleAuto(PC),A0
	ST	(A0)
	BRA	CPU_MOD_O

E7 ;Mettre une entr‚e dans le menu
	LEA	AccsString(PC),A3
	MENU_ACC A3
	LEA	AccsHandle,A0
	MOVE	D0,(A0)
	BMI	X1

 ;Attendre la s‚lection
WAITACC LEA	MsgeBuffer,A3
	EVNT_MESS A3
	MOVE	(A3),D0
	CMPI	#40,D0 ;ACCS_OPEN
	BEQ.S	.open
	CMPI	#41,D0 ;ACCS_CLOSE
	BEQ.S	.close
	BRA	WAITACC

.open	MOVE	8(A3),D0
	CMP	AccsHandle,D0
	BEQ.S	CPU_MOD_O
	BRA	WAITACC

.close	BRA	WAITACC

CPU_MOD_O:
	BSR	MSE_BEGCTL
 ;D‚clarer une fenˆtre de surface utile A5
	LEA	WindExtent,A3
	WIND_CALC #0,#0,A5,A3
	WIND_CREATE #0,A3
	MOVE	D0,WindHandle
	BMI	CPU_MOD_X
	LEA	WindCArea,A4
	FORM_DIAL #1,A4,A3
	WIND_OPEN WindHandle,A3
	BSR	MSE_PHAND
	BRA	WAITEVT

CPU_MOD_C:
	SF	(A0)
	BSR	MSE_ARROW
	WIND_CLOSE WindHandle
	LEA	WindExtent,A3
	LEA	WindCArea,A4
	FORM_DIAL #2,A4,A3
	WIND_DELETE WindHandle
	BSR	MSE_ENDCTL
CPU_MOD_X:
	TST.B	APP
	BEQ	WAITACC
	BSR	POWEROFF
	BRA	X1

WAITEVT	EVNT_MULTI #%110011,#1,#%01,#%01,#0,#PAD,#0,#PAD,#1000,#MsgeBuffer,Evnt,#MousXY,D1
	MOVE	D0,-(SP)
	MOVE	Evnt,D1
	BTST	#4,D1
	BEQ.S	.1
	BSR.S	REDRAW
.1	MOVE	Evnt,D1
	BTST	#1,D1
	BEQ.S	.2
	BSR.S	BUTTON
.2	MOVE	(SP)+,D0
	MOVE	Evnt,D1
	BTST	#0,D1
	BEQ.S	.3
	BSR	KEYBOARD
.3	MOVE	Evnt,D1
	BTST	#5,D1
	BEQ.S	.4
	BSR	AUTOSTOP
.4 ;Exit ?
	LEA	ModuleExit(PC),A0
	TST.B	(A0)
	BNE	CPU_MOD_C
	BRA	WAITEVT

REDRAW: LEA	MsgeBuffer,A0
	CMPI	#20,(A0)
	BNE.S	.f
	MOVE	6(A0),D0
	CMP	WindHandle,D0
	BNE.S	.f
	MOVEQ	#0,D3
	MOVEQ	#2,D4
	BSR	DRAW
.f ;Suivi de l'AUTO-LOAD ?
	MOVE.B	ModuleAuto(PC),D0
	BNE.S	AUTOLOAD
	RTS

AUTOLOAD:
	BSR	CPower
	BSR	CLoad
	BSR	CPlay
	LEA	ModuleAuto(PC),A0
	SF	(A0)
	RTS

BUTTON: OBJC_FIND #0,#2,#MousXY,A6
	TST	D0
	BMI	.f
	CMPI	#FExit,D0
	BEQ	CExit
	CMPI	#FPower,D0
	BEQ	CPower
	CMPI	#FLoad,D0
	BEQ	CLoad
	CMPI	#FIPlay,D0
	BEQ	CPlay
	CMPI	#FIStop,D0
	BEQ	CStop
	CMPI	#FIRS,D0
	BEQ	CRS
	CMPI	#FIFS,D0
	BEQ	CFS
	CMPI	#FIFF,D0
	BEQ	CFF
	CMPI	#FRepeat,D0
	BEQ	CREP
	CMPI	#FMo_St,D0
	BEQ	CMO_ST
	CMPI	#F6KHz,D0
	BNE.S	.1
	MOVEQ	#1,D0
	BRA	CFreq
.1	CMPI	#F12KHz,D0
	BNE.S	.2
	MOVEQ	#2,D0
	BRA	CFreq
.2	CMPI	#F25KHz,D0
	BNE.S	.3
	MOVEQ	#3,D0
	BRA	CFreq
.3	CMPI	#F50KHz,D0
	BNE.S	.f
	MOVEQ	#4,D0
	BRA	CFreq
.f	RTS

KEYBOARD:
	CMPI.B	#13,D0
	BEQ	CExit
	CMPI.B	#'P',D0
	BEQ	CPower
	CMPI.B	#'p',D0
	BEQ	CPower
	CMPI.B	#'L',D0
	BEQ	CLoad
	CMPI.B	#'l',D0
	BEQ	CLoad
	CMPI.B	#' ',D0
	BEQ	CPlay
	CMPI.B	#'-',D0
	BEQ	CStop
	CMPI.B	#'(',D0
	BEQ	CRS
	CMPI.B	#')',D0
	BEQ	CFS
	CMPI.B	#'+',D0
	BEQ	CFF
	CMPI.B	#'.',D0
	BEQ	CREP
	CMPI.B	#'*',D0
	BEQ	CMO_ST
	CMPI.B	#'0',D0
	BLO.S	.1
	CMPI.B	#'3',D0
	BHI.S	.1
	MOVE	D0,D1
	MOVEQ	#4,D0
	SUBI.B	#'0',D1
	SUB.B	D1,D0
	BRA	CFreq
.1	RTS

AUTOSTOP:
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_PLAYING_AD,D0
	CMP.L	(A0),D0
	BNE.S	.f
	BSR	DMAStatus
	TST.B	D0
	BNE.S	.f
 ;LAST CHANCE ! Mettons en pour 1 seconde
	BSR	CLICK
	BSR	CLICK
	BSR	DMAStatus
	TST.B	D0
	BNE.S	.f
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_STOP_AD,(A0)
	MOVEQ	#FMessage,D3
	MOVEQ	#0,D4
	BSR	DRAW
.f	RTS

	D_
;Variables~~~~~~~~~~~~~
ModuleAuto	DC.B 0 ;pour *.GTP
ModuleExit	DC.B 0
ModulePower	DC.B 0
ModuleRep	DC.B 0
		DC.B -1
ModuleMoSt	DC.B -1
ModuleFr	DC.W 3 ;(1-4)
ModuleAd	DC.L 0 ;pointe sur le bloc allou‚
ModuleLn	DC.L 0 ;0:pas de module
;~~~~~~~~~~~~~~~~~~~~~~

RscName 	DC.B "CPU_MODA.RSC",0
S_NUL		DC.B 0
LoadFilter	DC.B "\*.MOD",0
AccsString	DC.B "  ~~~ CPU_MOD ~~~",0
	EVEN
FreqButt:	DC.W F6KHz,F12KHz,F25KHz,F50KHz

CPU_MOD:	INCBIN "CPU_MOD.BIN"

	M_
F_MESSAGE	DS.L 1 ;Adresse … modifier
F_MODULETITLE	DS.L 1 ;Adresse … modifier
S_POWEROFF_AD	DS.L 1
S_STOP_AD	DS.L 1
S_LOAD_AD	DS.L 1
S_LOADING_AD	DS.L 1
S_PLAYING_AD	DS.L 1
S_PAUSE_AD	DS.L 1
S_NOMOD_AD	DS.L 1
S_INCMOD_AD	DS.L 1

AccsHandle	DS.W 1
WindHandle	DS.W 1
WindExtent	DS.W 4
WindCArea	DS.W 4
Evnt		DS.W 1
MsgeBuffer	DS.W 8
MousXY		DS.W 2
LoadPathname	DS.B 256
LoadFile	DS.B 12+1
	EVEN
PathnameFile	DS.B 256
FileHandle	DS.W 1
 END

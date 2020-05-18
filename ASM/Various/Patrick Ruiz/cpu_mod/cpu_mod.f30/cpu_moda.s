;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~ Coquille en *.APP ou *.ACC pour la routine CPU_MOD.BIN ~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;-------------------------------------------------------------------------------
;Error.B=CPU_MOD(Cmd.W,8_16.W,Mo_St.W,Freq.W,MOD_Ad.L,MOD_Ln.L)
;D0		 SP+4  SP+6   SP+8    SP+10  SP+12    SP+16

;Error= 0:No error
;      -1:Error (Power OFF ? , Incorrect module ? , No module ?)

;Cmd=	0:-
;	1:Power OFF/ON						[P]
;	2:Open new module at address=MOD_Ad and length=MOD_Ln	[L]
;	3:Pause/Play						[SP]
;	4:Stop							[-]
;	5:Song position Reverse Search				[(]
;	6:Song position Forward Search				[)]
;	7:Fast Forward OFF/ON					[+]
;	8:Repeat mode OFF/ON					[.]

;8_16=	0:-
;	1:8 bits/16 bits					[/]

;Mo_St= 0:-
;	1:Mono/Stereo						[*]

;Freq=	0:-
;	1: 8195 Hz						[7]
;	2: 9834 Hz						[6]
;	3:12292 Hz						[5]
;	4:16390 Hz						[4]
;	5:19668 Hz						[3]
;	6:24585 Hz						[2]
;	7:32780 Hz						[1]
;	8:49170 Hz						[0]
;-------------------------------------------------------------------------------
;Pour le Formulaire
;	Fin							[CR]
;Pour le mode Oscilloscope:
;	D‚but							[~]
;	Fin							[~][SP][ESC]
;-------------------------------------------------------------------------------

ModuleLength=800*1024

	INCLUDE "CPU_MODA.INC"

	M_
bss	DS.B 80000 ;pour CPU_MOD.BIN , BSS=bss-4 ('0000' de NON reloc.)

;RAPPEL:
;Les variables concernant l'oscilloscope sont en BSS+1000
 ;Arriv‚e asynchrone des donn‚es (0.01 sec. ... 0.02 sec. ... 0.08 sec.)
 ;		     TIMER_BEAT = 255		125	      33
 ;Gestion par paquets dans un tampon circulaire
 ;Sortie des donn‚es (0.020 sec.  ou  0.017 sec.)
 ;	       VFreq= 50	      60

PTail	=90
PNumber =26 ;au moins 10
PVTail	=22

REnable=bss-4+1000		;DS.B 1
RFull=REnable+1 		;DS.B 1
RWritePointer=RFull+1		;DS.W 1 (0 … (PNumber-1)*PTail)
RReadPointer=RWritePointer+2	;DS.W 1 (0 … (PNumber-1)*PTail)
RTimeInt=RReadPointer+2 	;DS.W 1 (si trop important alors d‚gorger)
RTimeFrc=RTimeInt+2		;DS.W 1

PACKETS=RTimeFrc+2		;DS.B PTail*PNumber
PTimeFrc=0			 ;DS.W 1

PV0=2
PVSamplePointerInt  =0		 ;DS.L 1
PVSamplePointerFrc  =4		 ;DS.W 1
PVSamplePointerEnd  =6		 ;DS.L 1 (0 ou -1:STOP)
PVSampleRepeatStart =10 	 ;DS.L 1
PVSampleRepeatEnd   =14 	 ;DS.L 1 (-1:STOP)
PVFreq		    =18 	 ;DS.W 1
PVVolume	    =20 	 ;DS.W 1

PV1=PV0+PVTail
PV2=PV1+PVTail
PV3=PV2+PVTail

XPixelNumber=344
YPixelNumber=256
V0Color=%0000011111100000 ;Vert
V1Color=%1111100000000000 ;Rouge
V2Color=%1111111111100000 ;Jaune
V3Color=%0000000000011111 ;Bleu

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

_8_16B: LEA	.sp(PC),A3
	BSR	SUPER
	RTS
.sp	CLR	-(SP)
	CLR	-(SP)
	PW	#1
	CLR	-(SP)
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

.on ;Allouer la mˆmoire pour le module et les 2 ‚crans
 ;Penser … ligner les 2 ‚crans sur un LONG WORD
	MEMO_ALLOC #(ModuleLength+2*2*XPixelNumber*YPixelNumber+4)
	TST.L	D0
	BEQ.S	.nomem
	ST	(A3)
	LEA	ModuleAd(PC),A0
	MOVE.L	D0,(A0)
	ADDI.L	#ModuleLength+4,D0
	ANDI	#%11111100,D0
	LEA	Scr1Ad,A0
	MOVE.L	D0,(A0)+
	ADDI.L	#2*XPixelNumber*YPixelNumber,D0
	MOVE.L	D0,(A0)
	BSR	POWER
;Penser … mettre en conformit‚ les paramˆtres internes
;avec les positions des boutons qui eux ne disjonctent PAS.
	MOVE.B	ModuleRep(PC),D0
	BEQ.S	.1
	BSR	REP
.1	MOVE.B	Module8_16(PC),D0
	BEQ.S	.2
	BSR	_8_16B
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
	CLR.B	(A1,20)
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
	MOVEQ	#FPlay,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIPlay,D0
	MULU	D7,D0
	ADDQ	#1,(A6,D0,16)
	ADDQ	#1,(A6,D0,18)
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
	MOVEQ	#FPlay,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIPlay,D0
	MULU	D7,D0
	SUBQ	#1,(A6,D0,16)
	SUBQ	#1,(A6,D0,18)
	BSR	DRAW
	RTS

.nomod	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_NOMOD_AD,(A0)
	BRA.S	.msg

CStop:	BSR	STOP
	MOVEQ	#FStop,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIStop,D0
	MULU	D7,D0
	ADDQ	#1,(A6,D0,16)
	ADDQ	#1,(A6,D0,18)
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
	MOVEQ	#FStop,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIStop,D0
	MULU	D7,D0
	SUBQ	#1,(A6,D0,16)
	SUBQ	#1,(A6,D0,18)
	BSR	DRAW
	RTS

CRS:	BSR	RS
	MOVEQ	#FRS,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIRS,D0
	MULU	D7,D0
	ADDQ	#1,(A6,D0,16)
	ADDQ	#1,(A6,D0,18)
	MOVEQ	#FRS,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
	MOVEQ	#FRS,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIRS,D0
	MULU	D7,D0
	SUBQ	#1,(A6,D0,16)
	SUBQ	#1,(A6,D0,18)
	BSR	DRAW
	RTS

CFS:	BSR	FS
	MOVEQ	#FFS,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIFS,D0
	MULU	D7,D0
	ADDQ	#1,(A6,D0,16)
	ADDQ	#1,(A6,D0,18)
	MOVEQ	#FFS,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
	MOVEQ	#FFS,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIFS,D0
	MULU	D7,D0
	SUBQ	#1,(A6,D0,16)
	SUBQ	#1,(A6,D0,18)
	BSR	DRAW
	RTS

CFF:	BSR	FF
	MOVEQ	#FFF,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;D‚caler le d‚calcomanie de +1 en X et Y
	MOVEQ	#FIFF,D0
	MULU	D7,D0
	ADDQ	#1,(A6,D0,16)
	ADDQ	#1,(A6,D0,18)
	MOVEQ	#FFF,D3
	MOVEQ	#1,D4
	BSR	DRAW
	BSR	CLICK
	MOVEQ	#FFF,D0
	MULU	D7,D0
	BCHG	#0,(A6,D0,11)
 ;Puis revenir au X et Y normal
	MOVEQ	#FIFF,D0
	MULU	D7,D0
	SUBQ	#1,(A6,D0,16)
	SUBQ	#1,(A6,D0,18)
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

C8_16:	BSR	_8_16B
	LEA	Module8_16(PC),A0
	NOT.B	(A0)
	MOVEQ	#F8_16bits,D3
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

CFreq: ;E:D0=Freq (1-8)
	LEA	ModuleFr(PC),A0
	MOVE	(A0),D3
	CMP	D3,D0
	BEQ.S	.f
	MOVE	D0,(A0)
	BSR	FREQ
	LEA	FreqButt(PC),A3
	MOVE	(A3,D3*2,-2),D3
	MOVEQ	#0,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	MOVE	ModuleFr(PC),D3
	MOVE	(A3,D3*2,-2),D3
	MOVEQ	#1,D4
	BSR	CHANGE
.f	BSR	CLICK
	RTS

COsc:	MOVEQ	#FOscilloscope,D3
	MOVEQ	#1,D4
	MOVEQ	#1,D5
	BSR	CHANGE
	BSR	CLICK
	MOVEM.L D3-D7/A3-A6,-(SP)
	PROG_SUPERMODE #0
	MOVE.L	D0,-(SP)

 ;Interdit si POWER OFF
	MOVE.B	ModulePower(PC),D0
	BEQ	COscfin

 ;Type d'‚cran
	MOVE.B	$FFFF8006,D7
	ROL.B	#2,D7
	ANDI	#%11,D7 ;ATARI/PRO
	BEQ	COscfin

 ;Sauver , Mode ST ?
	MOVE	#-1,-(SP)
	MOVE	#88,-(SP)
	TRAP	#14
	ADDQ	#4,SP
	BTST	#7,D0
	SNE	D0
	EXT	D0
	LEA	VRegsO,A0
	MOVE	VID_SYNC,(A0)+
	MOVE	VID_RES1,(A0)+
	MOVE	VID_RES2,(A0)+
	MOVE	D0,(A0)+
	MOVE	VID_CO,(A0)+
	MOVE	VID_MODE,(A0)+
	MOVE	VID_HHT,(A0)+
	MOVE	VID_HBB,(A0)+
	MOVE	VID_HBE,(A0)+
	MOVE	VID_HDB,(A0)+
	MOVE	VID_HDE,(A0)+
	MOVE	VID_HSS,(A0)+
	MOVE	VID_VFT,(A0)+
	MOVE	VID_VBB,(A0)+
	MOVE	VID_VBE,(A0)+
	MOVE	VID_VDB,(A0)+
	MOVE	VID_VDE,(A0)+
	MOVE	VID_VSS,(A0)+
	MOVE	VID_BH,(A0)+
	MOVE	VID_BM,(A0)+
	MOVE	VID_BL,(A0)+
	MOVE	VID_HJ,(A0)+
	MOVE	VID_VJ,(A0)+
	MOVE	VID_LW,(A0)+
	MOVE.L	VID_CR00,(A0)+

IVRegs ;Compl‚ter la structure source , VTime et VXFreq
	LEA	VRegsMon,A6
	MOVE	#65536/60,D0
	MOVE	#(XPixelNumber/2)*60,D1
	CMPI	#%10,D7
	BEQ.S	.1
	LEA	VRegsTV,A6
	MOVE	#65536/50,D0
	MOVE	#(XPixelNumber/2)*50,D1
.1	MOVE	D0,VTime
	MOVE	D1,VXFreq
	MOVE.L	Scr1Ad,D0
	MOVEQ	#0,D1
	MOVE.B	D0,D1
	MOVE	D1,(A6,36+4)
	LSR.L	#8,D0
	MOVE.B	D0,D1
	MOVE	D1,(A6,36+2)
	LSR.L	#8,D0
	MOVE.B	D0,D1
	MOVE	D1,(A6,36)

IScr ;Effacer les 2 ‚crans
	MOVEA.L Scr1Ad,A0
	MOVE.L	#XPixelNumber*YPixelNumber,D0
.1	CLR.L	(A0)+
	SUBQ.L	#1,D0
	BNE	.1

IVid	MOVE.L	$70,VBLO
	MOVE.L	A6,VStruc
	LEA	IVIDEL(PC),A0
	MOVE.L	A0,$70
.1	CMPA.L	$70,A0
	BEQ	.1

IStrobos ;D‚clarer l'‚cran 2
	PL	#XPixelNumber*2*YPixelNumber
	MOVEA.L Scr2Ad,A0
	PEA	(A0)
	PW	#-1
	BSR	STROBOS
	ADDA	#10,SP
	LEA	ScrAd(PC),A0
	MOVE.L	D0,(A0)

IYTab ;Init YTable
	LEA	YTable+(65*256*4),A0
	MOVEQ	#65-1,D0 ;65 tables
.2	MOVE	#256-1,D1 ;256 valeurs
.1	MOVE.B	D1,D2
	EXT.W	D2
	MULS	D0,D2
	ASR.L	#7,D2 ;-64 … +63
	MULS	#-XPixelNumber*2,D2 ;Moins car Y+ situ‚ en arri‚re
	MOVE.L	D2,-(A0)
	DBF	D1,.1
	DBF	D0,.2

IClearScrAd
	LEA	ClearScrAd(PC),A0
	LEA	ClearScr1V0,A1
	LEA	ClearScr2V0,A2
	MOVE.L	A2,(A0)+
	MOVE.L	A1,(A0)+

IClearScrV ;Init des structures ClearV
	LEA	ClearScr1V0,A0
	MOVE	#(XPixelNumber/2)*8-1,D0
.1	CLR.L	(A0)+
	DBRA	D0,.1

IRing ;Init tampon
	SF	RFull
	CLR	RWritePointer
	CLR	RReadPointer
	CLR.L	RTimeInt
	ST	REnable

VIBRATION:
	LEA	REnable(PC),A0
	TST.B	(A0)
	BEQ.S	.kbd ;Sera mis … 0 si STOP
	LEA	RFull(PC),A0
	TST.B	(A0)
	BEQ.S	.time
	BSR	FLUSH
	BRA.S	.wait
.time	LEA	RTimeInt(PC),A0
	CMPI.L	#65536/50,(A0) ;1/50 sec.
	BLO.S	.wait
 ;A-t-on du retard ?
	CMPI.L	#65536*2/50,(A0) ;2/50 sec.
	BLO.S	.draw
	BSR	RUN
	BRA	VIBRATION
.draw	BSR	DRAWWAVES
.wait	LEA	SND_CR+1,A0
	BTST	#0,(A0)
	BNE.S	.kbd
 ;On r‚pŠte , normal il est sourd !
	BTST	#0,(A0)
	BNE.S	.kbd
	BTST	#0,(A0)
	BNE.S	.kbd
	BTST	#0,(A0)
	BNE.S	.kbd
	BSR	DRAWNULL
	LEA	REnable(PC),A0
	SF	(A0)
.kbd ;Test clavier
	CONS_GINSTATE #2
	TST	D0
	BEQ	VIBRATION
	CONS_IN #2
	CMPI	#'~',D0
	BEQ.S	.rst
	CMPI	#' ',D0
	BEQ.S	.rst
	CMPI	#27,D0
	BEQ.S	.rst
	BRA	VIBRATION

.rst	LEA	REnable(PC),A0
	SF	(A0)
 ;Restaurer
	PW	#0
	BSR	STROBOS
	ADDQ	#2,SP
 ;Revenir au mode graphique d'origine
 ;en sachant que les modes 1 plan sont rebelles
 ;il faut passer par un ‚tat interm‚diaire qui vide le tampon
	LEA	VRegsO,A0
	MOVE.L	A0,VStruc
	CMPI	#$0400,(A0,4) ;VID_RES2
	SEQ	D0 ;1 plan ?
	BNE.S	.1
 ;Passer en 1 plan au dernier VBL seulement
	CLR	(A0,4)
 ;Pas de mode Compatible !
	CLR	(A0,6)
 ;D‚caler VID_HDB et VID_HDE
	SUBQ	#1,(A0,18)
	SUBQ	#5,(A0,20)
.1	LEA	IVIDEL(PC),A1
	MOVE.L	A1,$70
.att1	CMPA.L	$70,A1
	BEQ	.att1
 ;Une deuxiŠme fois ?
	TST.B	D0
	BEQ.S	COscfin
 ;Revenir aux VID_RES2 , VID_HDB et VID_HDE voulus
	MOVE	#$0400,(A0,4)
	ADDQ	#1,(A0,18)
	ADDQ	#5,(A0,20)
	MOVE.L	A1,$70
.att2	CMPA.L	$70,A1
	BEQ	.att2

COscfin PROG_SUPERMODE (SP)+
	MOVEM.L (SP)+,D3-D7/A3-A6
	MOVEQ	#0,D4
	BSR	CHANGE
	RTS

IVIDEL: ORI	#$700,SR
	MOVEM.L D0-D3/A0-A2,-(SP)
	MOVEA.L VStruc,A0
	MOVE	(A0)+,VID_SYNC
;TABLE pour la restitution de RES1/RES2
; RES1	RES2  Comp.  Ordre
;  =0	 =0    =0   RES1/RES2
;  =0	 =0   <>0   RES2/RES1
;  =0	<>0    =0   RES1/RES2
;  =0	<>0   <>0   RES1/RES2
; <>0	 =0    =0   RES2/RES1
; <>0	 =0   <>0   RES2/RES1
	MOVE	(A0)+,D0
	MOVE	(A0)+,D1
	MOVE	(A0)+,D2
	LEA	VID_RES1,A1
	LEA	VID_RES2,A2
	MOVE	D0,D3
	ANDI	#$0300,D3
	BNE.S	.ST
	MOVE	D1,D3
	ANDI	#$0510,D3
	BNE.S	.1
	TST	D2
	BEQ.S	.1
.ST	EXG.L	D0,D1
	EXG.L	A1,A2
.1	MOVE	D0,(A1)
	MOVE	D1,(A2)
	MOVE	(A0)+,VID_CO
	MOVE	(A0)+,VID_MODE
	MOVE	(A0)+,VID_HHT
	MOVE	(A0)+,VID_HBB
	MOVE	(A0)+,VID_HBE
	MOVE	(A0)+,VID_HDB
	MOVE	(A0)+,VID_HDE
	MOVE	(A0)+,VID_HSS
	MOVE	(A0)+,VID_VFT
	MOVE	(A0)+,VID_VBB
	MOVE	(A0)+,VID_VBE
	MOVE	(A0)+,VID_VDB
	MOVE	(A0)+,VID_VDE
	MOVE	(A0)+,VID_VSS
	MOVE	(A0)+,VID_BH
	MOVE	(A0)+,VID_BM
	MOVE	(A0)+,VID_BL
	MOVE	(A0)+,VID_HJ
	MOVE	(A0)+,VID_VJ
	MOVE	(A0)+,VID_LW
	MOVE.L	(A0)+,VID_CR00
	MOVEM.L (SP)+,D0-D3/A0-A2
	ANDI	#$FBFF,SR
	MOVE.L	VBLO,$70
	JMP	([$70])

NEWSCREEN:
	PW	#1
	BSR	STROBOS
	ADDQ	#2,SP
	LEA	ScrAd(PC),A0
	MOVE.L	D0,(A0)
	LEA	ClearScrAd(PC),A0
	MOVEM.L (A0),A1-A2
	EXG.L	A1,A2
	MOVEM.L A1-A2,(A0)
	RTS

ERASEWAVES: ;Attention la liste peut ‚tre nulle
	MOVEA.L ClearScrAd(PC),A0
	MOVE	#(XPixelNumber/2)*4-1,D0
	TST.L	(A0)
	BEQ.S	.f
.4V	MOVEA.L (A0)+,A1
	CLR	(A1) ;ou une r‚manance ?
	DBRA	D0,.4V
.f	RTS

DRAWNULL: ;Tracer les lignes neutres
	BSR	ERASEWAVES

	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber/4)-1)*(XPixelNumber*2),A6
	MOVE	#XPixelNumber/2-1,D0
	MOVE	#V0Color,D1
.V0	MOVE	D1,(A6)+
	DBRA	D0,.V0

	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber/4)-1)*(XPixelNumber*2)+XPixelNumber,A6
	MOVE	#XPixelNumber/2-1,D0
	MOVE	#V1Color,D1
.V1	MOVE	D1,(A6)+
	DBRA	D0,.V1

	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber*3/4)-1)*(XPixelNumber*2)+XPixelNumber,A6
	MOVE	#XPixelNumber/2-1,D0
	MOVE	#V2Color,D1
.V2	MOVE	D1,(A6)+
	DBRA	D0,.V2

	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber*3/4)-1)*(XPixelNumber*2),A6
	MOVE	#XPixelNumber/2-1,D0
	MOVE	#V3Color,D1
.V3	MOVE	D1,(A6)+
	DBRA	D0,.V3

	BSR	NEWSCREEN
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~
;D7=Pixel number	~
;D6=PointerInt		~
;D5=PointerFrc		~
;D4=IncrementInt	~
;D3=IncrementFrc	~
;A6=X			~
;A5=ClearV		~
;A4=PointerEnd		~
;A3=YTable		~
;A2=PV			~
;~~~~~~~~~~~~~~~~~~~~~~~~
	D_
;Variables pour le calcul des voies hors registres en DATA pour d(PC)
WFrameTime	DS.W 1 ;Dur‚e en temps de la trame (FRC)
WFramePixel	DS.W 1 ;Dur‚e en pixel de la trame
WFragTime	DS.W 1 ;Dur‚e en temps du fragment (FRC)
WFragPixel	DS.W 1 ;Dur‚e en pixel du fragment
WColor		DS.W 1 ;Couleur du pixel
WNull		DC.W 0 ;Pour les voies … 0
WSimul		DC.B 0,0 ;Pour ‚viter d'appeler DRAWSIMUL

	P_
FLUSH: ;Massacre les paquets
	LEA	RReadPointer(PC),A0
	MOVE	RWritePointer(PC),(A0)
	LEA	RTimeInt(PC),A0
	CLR.L	(A0)
	LEA	RFull(PC),A0
	SF	(A0)
	RTS

DRAWSIMUL: ;Simule un dessin d'un fragment d'une onde
	SUBQ	#1,D7
	MOVE.L	PVSamplePointerEnd(A2),D0
	BLE.S	.V0
	MOVEA.L D0,A4
	MOVE.L	PVSamplePointerInt(A2),D6
	MOVE	PVSamplePointerFrc(A2),D5
 ;Increment=PVFreq/VXFreq
	MOVEQ	#0,D0
	MOVE	PVFreq(A2),D0
	DIVU	VXFreq(PC),D0
	MOVEQ	#0,D4
	MOVE	D0,D4
	CLR	D0
	DIVU	VXFreq(PC),D0
	MOVE	D0,D3
.1	MOVEQ	#0,D0

.wave: ;Boucle principale
	ADD	D3,D5
	ADDX.L	D4,D6
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.wave

.out	MOVE.L	D6,PVSamplePointerInt(A2)
	MOVE	D5,PVSamplePointerFrc(A2)
	MOVE.L	A4,PVSamplePointerEnd(A2)
	RTS

.V0:	LEA	-1,A4
	LEA	WNull(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.out

.rep:	MOVE.L	PVSampleRepeatEnd(A2),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	PVSampleRepeatStart(A2),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	WNull(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.out

RUN: ;Ampute les paquets
	LEA	WFrameTime(PC),A0
	MOVE	VTime(PC),(A0)
	LEA	WFramePixel(PC),A0
	MOVE	#XPixelNumber/2,(A0)
.anap	;D0=FragTime
	;D1=FragPixel
	MOVEQ	#0,D0
	MOVE	WFrameTime(PC),D0
	MOVE	WFramePixel(PC),D1
	LEA	PACKETS(PC),A2
	ADDA	RReadPointer(PC),A2
	MOVE	(A2),D2
	CMP	D0,D2
	LEA	WSimul(PC),A0
	SHI	(A0)
	BHS.S	.1
	MULU	D2,D1
	 ADD.L	D0,D1
	 SUBQ.L #1,D1
	DIVU	D0,D1
	MOVE	D2,D0
	CMP	WFramePixel(PC),D1
	BLS.S	.1
	MOVE	WFramePixel(PC),D1
.1	LEA	WFragTime(PC),A0
	MOVE	D0,(A0)
	LEA	WFragPixel(PC),A0
	MOVE	D1,(A0)
	LEA	WSimul(PC),A0
	TST.B	(A0)
	BEQ.S	.dec

.V0	MOVE	D1,D7
	ADDQ	#PV0,A2
	BSR	DRAWSIMUL

.V1	MOVE	WFragPixel(PC),D7
	ADDA	#PVTail,A2
	BSR	DRAWSIMUL

.V2	MOVE	WFragPixel(PC),D7
	ADDA	#PVTail,A2
	BSR	DRAWSIMUL

.V3	MOVE	WFragPixel(PC),D7
	ADDA	#PVTail,A2
	BSR	DRAWSIMUL

.dec ;D‚cr‚menter les temps (D0)
	MOVEQ	#0,D0
	MOVE	WFragTime(PC),D0
	LEA	PACKETS(PC),A2
	ADDA	RReadPointer(PC),A2
	SUB	D0,(A2)
	BNE.S	.2

.nextp	LEA	RReadPointer(PC),A0
	MOVE	(A0),D1
	ADDI	#PTail,D1
	CMPI	#PTail*PNumber,D1
	BNE.S	.3
	MOVEQ	#0,D1
.3	MOVE	D1,(A0)
	LEA	RFull(PC),A0
	SF	(A0)

.2	LEA	RTimeInt(PC),A0
	SUB.L	D0,(A0)
	LEA	WFrameTime(PC),A0
	SUB	D0,(A0)
	LEA	WFramePixel(PC),A0
	MOVE	WFragPixel(PC),D0
	SUB	D0,(A0)
	BNE	.anap
.f	RTS

DRAWWAVE: ;Dessine un fragment d'une onde
	SUBQ	#1,D7
	MOVE.L	PVSamplePointerEnd(A2),D0
	BLE.S	.V0
	MOVEA.L D0,A4
	MOVE.L	PVSamplePointerInt(A2),D6
	MOVE	PVSamplePointerFrc(A2),D5
 ;Increment=PVFreq/VXFreq
	MOVEQ	#0,D0
	MOVE	PVFreq(A2),D0
	DIVU	VXFreq(PC),D0
	MOVEQ	#0,D4
	MOVE	D0,D4
	CLR	D0
	DIVU	VXFreq(PC),D0
	MOVE	D0,D3
.ytab	LEA	YTable,A0
	MOVEQ	#0,D0
	MOVE	PVVolume(A2),D0
	LSL	#8,D0
	LEA	(A0,D0.L*4),A3
	MOVE	WColor(PC),D2
	MOVEQ	#0,D0

.wave: ;Boucle principale
	MOVEA.L D6,A0
	MOVE.B	(A0),D0
	MOVE.L	(A3,D0*4),D1
	LEA	(A6,D1.L),A0
	ADDQ	#2,A6
	MOVE	D2,(A0)
	MOVE.L	A0,(A5)+
	ADD	D3,D5
	ADDX.L	D4,D6
.vad	CMP.L	A4,D6
	BHS.S	.rep
.svt	DBRA	D7,.wave

.out	MOVE.L	D6,PVSamplePointerInt(A2)
	MOVE	D5,PVSamplePointerFrc(A2)
	MOVE.L	A4,PVSamplePointerEnd(A2)
	RTS

.V0:	LEA	-1,A4
	LEA	WNull(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.ytab

.rep:	MOVE.L	PVSampleRepeatEnd(A2),D1
	BMI.S	.V0bis
	SUB.L	A4,D6
	ADD.L	PVSampleRepeatStart(A2),D6
	MOVEA.L D1,A4
	BRA	.vad

.V0bis: MOVEA.L D1,A4 ;=-1
	LEA	WNull(PC),A0
	MOVE.L	A0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	MOVEQ	#0,D3
	BRA	.svt

DRAWWAVES:
	BSR	ERASEWAVES
	LEA	WFrameTime(PC),A0
	MOVE	VTime(PC),(A0)
	LEA	WFramePixel(PC),A0
	MOVE	#XPixelNumber/2,(A0)
.anap	;D0=FragTime
	;D1=FragPixel
	MOVEQ	#0,D0
	MOVE	WFrameTime(PC),D0
	MOVE	WFramePixel(PC),D1
	LEA	PACKETS(PC),A2
	ADDA	RReadPointer(PC),A2
	MOVE	(A2),D2
	CMP	D0,D2
	BHS.S	.1
 ;Le paquet ne fournit pas assez (sauf si arrondi en pixel>=WFramePixel)
  ;Calcul de la dur‚e en pixel
	MULU	D2,D1
  ;... en cherchant … arrondir au nombre sup.
	 ADD.L	D0,D1
	 SUBQ.L #1,D1
	DIVU	D0,D1
	MOVE	D2,D0
  ;Sans d‚passer la limite
	CMP	WFramePixel(PC),D1
	BLS.S	.1
	MOVE	WFramePixel(PC),D1
.1	LEA	WFragTime(PC),A0
	MOVE	D0,(A0)
	LEA	WFragPixel(PC),A0
	MOVE	D1,(A0)

.V0	MOVE	D1,D7
	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber/4)-1)*(XPixelNumber*2)+XPixelNumber,A6
	MOVE	WFramePixel(PC),D0
	LSL	#1,D0
	SUBA	D0,A6
	MOVEA.L ClearScrAd(PC),A5
	ADDA	#(XPixelNumber/2)*4,A5
	MOVE	WFramePixel(PC),D0
	LSL	#2,D0
	SUBA	D0,A5
	ADDQ	#PV0,A2
	LEA	WColor(PC),A0
	MOVE	#V0Color,(A0)
	BSR	DRAWWAVE

.V1	MOVE	WFragPixel(PC),D7
	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber/4)-1)*(XPixelNumber*2)+XPixelNumber*2,A6
	MOVE	WFramePixel(PC),D0
	LSL	#1,D0
	SUBA	D0,A6
	ADDA	#(XPixelNumber/2)*4,A5
	MOVE	WFragPixel(PC),D0
	LSL	#2,D0
	SUBA	D0,A5
	ADDA	#PVTail,A2
	LEA	WColor(PC),A0
	MOVE	#V1Color,(A0)
	BSR	DRAWWAVE

.V2	MOVE	WFragPixel(PC),D7
	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber*3/4)-1)*(XPixelNumber*2)+XPixelNumber*2,A6
	MOVE	WFramePixel(PC),D0
	LSL	#1,D0
	SUBA	D0,A6
	ADDA	#(XPixelNumber/2)*4,A5
	MOVE	WFragPixel(PC),D0
	LSL	#2,D0
	SUBA	D0,A5
	ADDA	#PVTail,A2
	LEA	WColor(PC),A0
	MOVE	#V2Color,(A0)
	BSR	DRAWWAVE

.V3	MOVE	WFragPixel(PC),D7
	MOVEA.L ScrAd(PC),A6
	ADDA.L	#((YPixelNumber*3/4)-1)*(XPixelNumber*2)+XPixelNumber,A6
	MOVE	WFramePixel(PC),D0
	LSL	#1,D0
	SUBA	D0,A6
	ADDA	#(XPixelNumber/2)*4,A5
	MOVE	WFragPixel(PC),D0
	LSL	#2,D0
	SUBA	D0,A5
	ADDA	#PVTail,A2
	LEA	WColor(PC),A0
	MOVE	#V3Color,(A0)
	BSR	DRAWWAVE

 ;D‚cr‚menter les temps (D0)
	MOVEQ	#0,D0
	MOVE	WFragTime(PC),D0
	LEA	PACKETS(PC),A2
	ADDA	RReadPointer(PC),A2
	SUB	D0,(A2)
	BNE.S	.2

.nextp	LEA	RReadPointer(PC),A0
	MOVE	(A0),D1
	ADDI	#PTail,D1
	CMPI	#PTail*PNumber,D1
	BNE.S	.3
	MOVEQ	#0,D1
.3	MOVE	D1,(A0)
	LEA	RFull(PC),A0
	SF	(A0)

.2	LEA	RTimeInt(PC),A0
	SUB.L	D0,(A0)
	LEA	WFrameTime(PC),A0
	SUB	D0,(A0)
 ;... et les pixels
	LEA	WFramePixel(PC),A0
	MOVE	WFragPixel(PC),D0
	SUB	D0,(A0)
	BNE	.anap
	BSR	NEWSCREEN
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
	LEA	(A6,16),A5	;Clip
	MOVEQ	#24,D7		;Objc length
	LEA	F_MESSAGE,A0
	MOVEQ	#FMessage,D0
	MULU	D7,D0
	MOVE.L	(A6,D0,12),(A0)
	LEA	F_MODULETITLE,A0
	MOVEQ	#FModuleTitle,D0
	MULU	D7,D0
	MOVE.L	(A6,D0,12),(A0)
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
	MOVE	(A4,6),D0
	LSR	#1,D0
	ADD	D0,(A4)
	MOVE	(A4,8),D0
	LSR	#1,D0
	ADD	D0,(A4,2)
	CLR.L	(A4,4)
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
	AND.L	D1,(A6,12)
	MOVEQ	#FExit,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FTitle,D0
	MULU	D7,D0
	MOVEA.L (A6,D0,12),A0
	AND	D1,(A0,18)
	MOVEQ	#FOscilloscope,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FMessage,D0
	MULU	D7,D0
	MOVEA.L (A6,D0,12),A0
	AND	D1,(A0,18)
	MOVEQ	#FModuleTitle,D0
	MULU	D7,D0
	MOVEA.L (A6,D0,12),A0
	AND	D1,(A0,18)
	MOVEQ	#FPlay,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FStop,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FRS,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FFS,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FFF,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FRepeat,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F8_16bits,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#FMo_St,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F8KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F9KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F12KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F16KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F19KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F24KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F32KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)
	MOVEQ	#F49KHz,D0
	MULU	D7,D0
	AND.L	D1,(A6,D0,12)

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

.open	MOVE	(A3,8),D0
	CMP	AccsHandle,D0
	BEQ.S	CPU_MOD_O
	BRA	WAITACC

.close ;On doit faire POWER OFF pour un changement de r‚solution mais
 ;h‚las lors du lancement d'un *.TOS un ACC_CLOSE est aussi envoy‚.
 ;D'o—: penser … arr‚ter manuellement.
	BRA	WAITACC

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

WAITEVT EVNT_MULTI #%110011,#1,#%01,#%01,#0,#PAD,#0,#PAD,#1000,#MsgeBuffer,Evnt,#MousXY,D1
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
	MOVE	(A0,6),D0
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
	CMPI	#F8_16bits,D0
	BEQ	C8_16
	CMPI	#FMo_St,D0
	BEQ	CMO_ST
	CMPI	#F8KHz,D0
	BNE.S	.1
	MOVEQ	#1,D0
	BRA	CFreq
.1	CMPI	#F9KHz,D0
	BNE.S	.2
	MOVEQ	#2,D0
	BRA	CFreq
.2	CMPI	#F12KHz,D0
	BNE.S	.3
	MOVEQ	#3,D0
	BRA	CFreq
.3	CMPI	#F16KHz,D0
	BNE.S	.4
	MOVEQ	#4,D0
	BRA	CFreq
.4	CMPI	#F19KHz,D0
	BNE.S	.5
	MOVEQ	#5,D0
	BRA	CFreq
.5	CMPI	#F24KHz,D0
	BNE.S	.6
	MOVEQ	#6,D0
	BRA	CFreq
.6	CMPI	#F32KHz,D0
	BNE.S	.7
	MOVEQ	#7,D0
	BRA	CFreq
.7	CMPI	#F49KHz,D0
	BNE.S	.8
	MOVEQ	#8,D0
	BRA	CFreq
.8	CMPI	#FOscilloscope,D0
	BEQ	COsc
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
	CMPI.B	#'/',D0
	BEQ	C8_16
	CMPI.B	#'*',D0
	BEQ	CMO_ST
	CMPI.B	#'0',D0
	BLO.S	.1
	CMPI.B	#'7',D0
	BHI.S	.1
	MOVE	D0,D1
	MOVEQ	#8,D0
	SUBI.B	#'0',D1
	SUB.B	D1,D0
	BRA	CFreq
.1	CMPI.B	#'~',D0
	BEQ	COsc
	RTS

AUTOSTOP:
	MOVEA.L F_MESSAGE,A0
	MOVE.L	S_PLAYING_AD,D0
	CMP.L	(A0),D0
	BNE.S	.f
	BSR	DMAStatus
	TST.B	D0
	BNE.S	.f
	BSR	DMAStatus
	TST.B	D0
	BNE.S	.f
 ;LAST CHANCE
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
Module8_16	DC.B -1
ModuleMoSt	DC.B -1
ModuleFr	DC.W 8 ;(1-8)
ModuleAd	DC.L 0 ;pointe sur le bloc allou‚
ModuleLn	DC.L 0 ;0:pas de module
;~~~~~~~~~~~~~~~~~~~~~~

RscName 	DC.B "CPU_MODA.RSC",0
S_NUL		DC.B 0
LoadFilter	DC.B "\*.MOD",0
AccsString DC.B "  ~~~ CPU_MOD ~~~",0

	EVEN
FreqButt:	DC.W F8KHz,F9KHz,F12KHz,F16KHz,F19KHz,F24KHz,F32KHz,F49KHz

;~~~ VIDEL ~~~
;VID_SYNC VID_RES1 VID_RES2 STCOMP  VID_CO   VID_MODE
;VID_HHT  VID_HBB  VID_HBE  VID_HDB VID_HDE  VID_HSS
;VID_VFT  VID_VBB  VID_VBE  VID_VDB VID_VDE  VID_VSS
;VID_BH   VID_BM   VID_BL   VID_HJ  VID_VJ   VID_LW
;VID_CR00

VRegsMon:
	DC.W $0000,$0000,$0100,$0000,$0186,$0005
	DC.W $00C6,$0096,$0008,$029E,$0096,$0096
	DC.W $0419,$0415,$0017,$0017,$0415,$0415
	DC.W	 0,    0,    0,    0,	 0,$0158
	DC.L	 0

VRegsTV:
	DC.W $0000,$0000,$0100,$0000,$0183,$0000
	DC.W $00FE,$00CB,$0027,$001D,$0096,$00D8
	DC.W $0271,$0265,$002F,$0047,$0247,$026B
	DC.W	 0,    0,    0,    0,	 0,$0158
	DC.L	 0

 ;en D_ pour d(PC)
VTime		DS.W 1 ;Dur‚e du frame (FRC) en sec.
VXFreq		DS.W 1 ;(XPixelNumber/2)*60 ou (XPixelNumber/2)*50
ScrAd		DS.L 1 ;Logique
Scr1Ad		DS.L 1 ;^Sur 1er  ‚cran
Scr2Ad		DS.L 1 ;^Sur 2Šme ‚cran
ClearScrAd	DS.L 2 ;ClearScr1V0 ou ClearScr2V0

STROBOS: INCBIN "STROBOS.BIN"
	EVEN
CPU_MOD: INCBIN "CPU_MOD.BIN"
;DERNIER DATA

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
;~~~~~~~~~~~~~~~~~~~~~~
VRegsO		DS.W 26
VBLO		DS.L 1
VStruc		DS.L 1 ;pointe sur une structure video (0:Aucune)

YTable: 	DS.L 65*256 ;volume combin‚ au sample 8 bits sign‚
			    ;*poids graphique en octets

 ;pour faciliter l'effacement
ClearScr1V0:	DS.L XPixelNumber/2
ClearScr1V1:	DS.L XPixelNumber/2
ClearScr1V2:	DS.L XPixelNumber/2
ClearScr1V3:	DS.L XPixelNumber/2
ClearScr2V0:	DS.L XPixelNumber/2
ClearScr2V1:	DS.L XPixelNumber/2
ClearScr2V2:	DS.L XPixelNumber/2
ClearScr2V3:	DS.L XPixelNumber/2

 END

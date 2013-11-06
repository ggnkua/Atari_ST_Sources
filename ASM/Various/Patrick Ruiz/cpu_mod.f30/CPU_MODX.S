;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~ Shell *.TTP type for the CPU_MOD.BIN routine  ~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;CPU_MOD.BIN is relocatable , need 70000 bytes free after the code
;and you must be in Supervisor mode.

	OUTPUT CPU_MODX.TTP

;Call in C-type:
;-------------------------------------------------------------------------------
;Error.B = CPU_MOD( Cmd.W , 8_16.W , Mo_St.W , Freq.W , MOD_Ad.L , MOD_Ln.L )
;D0		    SP+4    SP+6     SP+8      SP+10	SP+12	   SP+16

;Error= 0:No error
;      -1:Error (Power OFF ? , Incorrect module ? , No module ?)

;Cmd=	 0:-
;	 1:Power OFF/ON 					[Esc]
;	 2:Open new module at address=MOD_Ad and length=MOD_Ln
;	 3:Pause/Play						[SP]
;	 4:Stop 						[-]
;	 5:Song position Reverse Search 			[(]
;	 6:Song position Forward Search 			[)]
;	 7:Fast Forward mode OFF/ON				[+]
;	 8:Repeat mode OFF/ON					[.]

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

ModuleLength=512*1024

INIT: ;Load the MODULE
	MOVEA.L 4(SP),A6
	ADDA	#128+1,A6
	;FILE_OPEN
	  CLR	  -(SP)
	  PEA	  (A6)
	  MOVE	  #61,-(SP)
	  TRAP	  #1
	  ADDQ	  #8,SP
	MOVE	D0,D7
	BMI	FIN
	LEA	MODULE,A6
	;FILE_READ
	  PEA	  (A6)
	  MOVE.L  #ModuleLength,-(SP)
	  MOVE	  D7,-(SP)
	  MOVE	  #63,-(SP)
	  TRAP	  #1
	  ADDA	  #12,SP
	MOVE.L	D0,D6
	;FILE_CLOSE
	  MOVE	  D7,-(SP)
	  MOVE	  #62,-(SP)
	  TRAP	  #1
	  ADDQ	  #4,SP
	;PROG_SUPERMODE
	  CLR.L   -(SP)
	  MOVE	  #32,-(SP)
	  TRAP	  #1
	  ADDQ	  #6,SP
	  MOVEA.L D0,A5 ;Saved
	LEA	CPU_MOD(PC),A4

	MOVE	#8,-(SP) ;49 KHz
	MOVE	#1,-(SP) ;ST
	MOVE	#1,-(SP) ;16b
	MOVE	#1,-(SP) ;Power ON
	JSR	(A4)
	ADDQ	#8,SP

	MOVE.L	D6,-(SP)
	PEA	(A6)
	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	MOVE	#2,-(SP) ;Open MOD
	JSR	(A4)
	ADDA	#16,SP

	TST.B	D0
	BNE	SORTIE
 ;Extract the name of the module
	LEA	MODULE,A0
	LEA	NomMOD+10,A1
	MOVEQ	#20-1,D0
.1	MOVE.B	(A0)+,D1
	BEQ.S	.aff
	MOVE.B	D1,(A1)+
	DBRA	D0,.1

.aff ;Print the page
	PEA	PAGE(PC)
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	BRA.S	PLAY

ATT: ;Wait
      ;A Key ?
	MOVE	#2,-(SP)
	MOVE	#1,-(SP)
	TRAP	#13
	ADDQ	#4,SP
	TST	D0
	BEQ	ATT
	MOVE	#2,-(SP)
	MOVE	#2,-(SP)
	TRAP	#13
	ADDQ	#4,SP

	CMPI.B	#27,D0 ;Esc
	BEQ	SORTIE
	CMPI.B	#' ',D0
	BEQ.S	PLAY
	CMPI.B	#'-',D0
	BEQ.S	STOP
	CMPI.B	#'(',D0
	BEQ.S	SGRS
	CMPI.B	#')',D0
	BEQ.S	SGFS
	CMPI.B	#'+',D0
	BEQ.S	FAST
	CMPI.B	#'.',D0
	BEQ.S	REPEAT
	CMPI.B	#'/',D0
	BEQ.S	M8_16
	CMPI.B	#'*',D0
	BEQ.S	MO_ST
	CMPI.B	#'0',D0
	BLO	ATT
	CMPI.B	#'7',D0
	BLS.S	FREQ
	BRA	ATT

CMD	CLR	-(SP)
	CLR	-(SP)
	CLR	-(SP)
	MOVE	D0,-(SP)
	JSR	(A4)
	ADDQ	#8,SP
	BRA	ATT

PLAY	MOVEQ	#3,D0
	BRA	CMD

STOP	MOVEQ	#4,D0
	BRA	CMD

SGRS	MOVEQ	#5,D0
	BRA	CMD

SGFS	MOVEQ	#6,D0
	BRA	CMD

FAST	MOVEQ	#7,D0
	BRA	CMD

REPEAT	MOVEQ	#8,D0
	BRA	CMD

HARD	MOVE	D2,-(SP)
	MOVE	D1,-(SP)
	MOVE	D0,-(SP)
	CLR	-(SP)
	JSR	(A4)
	ADDQ	#8,SP
	BRA	ATT

M8_16	MOVEQ	#1,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	BRA	HARD

MO_ST	MOVEQ	#0,D0
	MOVEQ	#1,D1
	MOVEQ	#0,D2
	BRA	HARD

FREQ	ANDI	#$FF,D0
	SUBI	#'0',D0
	MOVEQ	#8,D2
	SUB	D0,D2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	BRA	HARD

SORTIE	MOVE	#1,-(SP) ;Power OFF
	JSR	(A4)
	ADDQ	#2,SP

	;PROG_SUPERMODE
	  PEA	  (A5)
	  MOVE	  #32,-(SP)
	  TRAP	  #1
	  ADDQ	  #6,SP

FIN:	;PROG_END
	  CLR	-(SP)
	  TRAP	#1

 DATA
PAGE:	DC.B 27,'f',27,'w',27,'q',27,'E'
NomMOD	DC.B '<<<<<<<<< 		     >>>>>>>>>',13,10,13,10
	DC.B '	   Quit 			[Esc]',13,10
	DC.B '	   Pause/',27,'p','Play',27,'q','		    [SP]',13,10
	DC.B '	   Stop 			[-]',13,10
	DC.B '	   Song position Reverse Search [(]',13,10
	DC.B '	   Song position Forward Search [)]',13,10
	DC.B '	   Fast Forward mode ',27,'p','OFF',27,'q','/ON     [+]',13,10
	DC.B '	   Repeat mode ',27,'p','OFF',27,'q','/ON	    [.]',13,10
	DC.B '	   8 bits/',27,'p','16 bits',27,'q','		    [/]',13,10
	DC.B '	   Mono/',27,'p','Stereo',27,'q','		    [*]',13,10
	DC.B '	   ',27,'p','49170 Hz',27,'q',' 		    [0]',13,10
	DC.B '	   32780 Hz			[1]',13,10
	DC.B '	   24585 Hz			[2]',13,10
	DC.B '	   19668 Hz			[3]',13,10
	DC.B '	   16390 Hz			[4]',13,10
	DC.B '	   12292 Hz			[5]',13,10
	DC.B '	    9834 Hz			[6]',13,10
	DC.B '	    8195 Hz			[7]',13,10,13,10
	DC.B '	   ',27,'p','REVERSE VIDEO',27,'q',': BY DEFAULT',13,10
	DC.B '<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>',13,10
	DC.B '<<<      Code: Patrick RUIZ	   >>>',13,10
	DC.B '<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>',13,10,0

CPU_MOD: INCBIN "CPU_MOD.BIN"

 BSS
	DS.B 70000 ;for CPU_MOD.BIN just AFTER the code !!!

MODULE: DS.B ModuleLength
 END

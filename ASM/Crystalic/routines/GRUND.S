	JSR	SETSUPER
	JSR	SETSCREEN
	JSR	INIT
DEMOLOOP:
	JSR	WAITVBL

	JMP	DEMOLOOP
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
SETSCREEN:
	MOVE.W	#0,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.W	#$5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	RTS
*******************************
INIT:
	MOVE.L	$70,OLDVBL
	MOVE.L	#NEWVBL,$70
	RTS
RETINIT:
	MOVE.L	OLDVBL,$70
	RTS
*******************************
WAITVBL:
	CMP.W	#1,WFNC
	BNE.S	WAITVBL
	MOVE.W	#0,WFNC
	RTS
*******************************
*        MAIN - ROUTS         * 
*******************************

*******************************
*            VBL              * 
*******************************
NEWVBL:
	MOVE.W	#1,WFNC
	RTE
*******************************
*          VARIABLES          *
*******************************
SAVESUPER:	DC.L	0
OLDVBL:		DC.L	0
WFNC:		DC.W	0

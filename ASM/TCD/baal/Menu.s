	;---- BAAL TRAINER MENU BY DR.D ----;
	
	
	DC.W	$A00A		;HIDE MOUSE
	BSR	SETMED		;MEDIUM RES
	BSR	SETPAL		;WHITE ON BLACK
	BSR	DOCREDIT	;PRINT CREDITS
	BSR	DO_OPTIONS	;PRINT MENU OPTIONS
NEXT	BSR	WAITKEY		;WAIT FOR FKEY PRESSED

;--------------------------------------
	LEA	YOFF(PC),A0
	MOVE.L	#"NO  ",D0
	MOVE.L	#"YES ",D1	

F1	CMP.B	#$3B,D7
	BNE	F2
	MOVE.B	#32+10,(A0)
	LEA	LIVES(PC),A1
	BSR	GETYN
	BRA	NEXT
			
F2	CMP.B	#$3C,D7
	BNE	F3
	MOVE.B	#32+12,(A0)
	LEA	LFUEL(PC),A1
	BSR	GETYN
	BRA	NEXT
		
F3	CMP.B	#$3D,D7
	BNE	F4
	MOVE.B	#32+14,(A0)
	LEA	JFUEL(PC),A1
	BSR	GETYN
	BRA	NEXT
	
F4	CMP.B	#$3E,D7
	BNE	SPACE
	MOVE.B	#32+16,(A0)
	LEA	WEAPS(PC),A1
	BSR	GETYN
	BRA	NEXT


SPACE	CMP.B	#$39,D7
	BNE	NEXT
	
EXIT	CLR.W	D7
	BSR	SETRES
	
	CLR.W	-(A7)
	TRAP	#1

;--------------------------------------------------------
GETYN	LEA	YN(PC),A2

	TST.B	1(A1)	;IS IT 0
	BNE	STY	;IF NOT SET TO NO
	BRA	SETYES
	
STY	MOVE.B	#0,(A1)
	MOVE.L	D0,(A2)	;SET TO NO
	CLR.B	1(A1)	
	LEA	COL(PC),A0
	MOVE.B	#1,(A0)
	BRA	DO_OPTS

SETYES	MOVE.L	D1,(A2)
	MOVE.B	#1,(A1)	;SET TRAINER OPTION TO YES
	MOVE.B	#1,1(A1)
	LEA	COL(PC),A0
	MOVE.B	#2,(A0)
	
DO_OPTS	BSR	UPDATE
	RTS
	

;-----------------------------

WAITKEY	MOVE.W	#7,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	SWAP	D0
	MOVE.L	D0,D7
	RTS

;-----------------------------
PRINT	MOVE.L	A6,-(A7)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS	
;-----------------------------

DOCREDIT	LEA	CREDIT(PC),A6
	BSR	PRINT	
	RTS
;-----------------------------

DO_OPTIONS	
	LEA	OPTIONS(PC),A6
	BSR	PRINT

	LEA	YOFF(PC),A5
	LEA	YN(PC),A3
	MOVE.L	#"NO  ",(A3)
	LEA	LIVES(PC),A4
	CLR.L	(A4)
	CLR.L	4(A4)
	ADD.B	#10,(A5)
	BSR	UPDATE
	ADD.B	#2,(A5)
	BSR	UPDATE
	ADD.B	#2,(A5)
	BSR	UPDATE
	ADD.B	#2,(A5)
	BSR	UPDATE

	RTS
;-----------------------------

UPDATE	LEA	YESNO(PC),A6
	BSR	PRINT
	LEA	YN(PC),A6
	BSR	PRINT
	RTS
;-----------------------------

SETMED	MOVE.W	#1,D7
	BSR	SETRES
	RTS

SETLOW	CLR.W	D7
	BSR	SETRES
	RTS
	
SETRES	MOVE.W	D7,-(A7)
	PEA	-1
	PEA	-1
	MOVE.W	#5,-(A7)
	TRAP	#14
	ADD.L	#12,A7
	RTS
;-----------------------------

SETPAL	PEA	PAL(PC)
	MOVE.W	#6,-(A7)
	TRAP	#14
	ADD.L	#6,A7
	RTS
;-----------------------------

CREDIT	DC.B	27,"E"
	DC.B	27,"Y",32+2,32+30,"* ---    BAAL    --- *"
	
	DC.B	27,"Y",32+5,32+25,"CRACKED, TRAINED, FILED & PACKED"
	DC.B	27,"Y",32+7,32+33,"BY DR.D of T.C.D"
	
	
	DC.B	27,"Y",32+20,32+29,"SELECT TRAINER OPTIONS"
	DC.B	27,"Y",32+23,32+32,"SPACE TO CONTINUE"
	DC.B	0
	
OPTIONS	DC.B	27,"Y",32+10,32+26,"[F1]  INFINITE LIVES"
	DC.B	27,"Y",32+12,32+26,"[F2]  INFINITE LASER FUEL"
	DC.B	27,"Y",32+14,32+26,"[F3]  INFINITE JETPACK FUEL"
	DC.B	27,"Y",32+16,32+26,"[F4]  ALL WEAPONS (Keys 1-4)"
	DC.B	0

	EVEN

YESNO	DC.B	27,"Y"
YOFF	DC.B	32
	DC.B	32+26+30
	DC.B	27,"b"
COL	DC.B	1,0
YN	DC.B	"NO  "
	DC.B	0
	
	EVEN	
	

PAL	DC.W	$000,$700,$070,$777

LIVES	DS.B	2
LFUEL	DS.B	2
JFUEL	DS.B	2
WEAPS	DS.B	2



* LINKFILE CREATOR
* CODED BY PELE/LEMMINGS '93

; THIS MERGES ALL FILES FROM DIRECTORY INTO SINGLE LINKFILE
; ALL FILENAMES & LENGTHS ARE IN 'BLOCK' FILE

files	equ	10	; alter to however many files will be in the link

	CLR.W	-(A7)
	PEA	$200000
	TRAP	#1
	MOVE.L	$42E,A7

	MOVE.W	#$2F,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	MOVE.L	D0,DTA

	MOVE.L	DTA,A6
	LEA	SAVES(PC),A5

;	MOVE.W	#x-1,-(A7)	; x = DRIVE letter-65
;	MOVE.W	#$E,-(A7)		
;	TRAP	#1		;IF LOADING FROM DRIVE x
;	ADDQ.L	#4,A7
	
	PEA	PATH(PC)
	MOVE.W	#$3B,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7

	CLR.W	-(A7)
	PEA	FILE(PC)
	MOVE.W	#$4E,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	BRA.S	L1
	
FNEX	MOVE.W	#$4F,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
L1	TST	D0
	BMI	TERM

	MOVE.L	30(A6),(A5)+
	MOVE.L	34(A6),(A5)+	
	MOVE.L	38(A6),(A5)+	
	MOVE.L	26(A6),D0
	BTST	#0,D0
	BEQ.S	EVEN
	ADDQ.L	#1,D0		* IF ALL DATA MUST BE ON EVEN BOUNDARY
	ADDQ.L	#1,26(A6)
EVEN	ADD.L	D0,OFFSET
	MOVE.L	OFFSET,(A5)+
	
	LEA	30(A6),A0
	BSR	PRINT
			
	CLR.W	-(A7)
	PEA	30(A6)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	MOVE.W	D0,D7
	
	MOVE.L	BUF,-(A7)
	MOVE.L	26(A6),-(A7)
	MOVE.W	D7,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVE.L	26(a6),D0	* IF ALL DATA MUST BE ON EVEN BOUNDARY
	ADD.L	D0,BUF
	BSR	CLOSE	
	BRA	FNEX

TERM	MOVE.L	BUF,D6
	SUB.L	#LINK,D6

;	CLR.W	-(A7)
;	MOVE.W	#$E,-(A7)		
;	TRAP	#1		;IF NOW SAVING TO DRIVE A
;	ADDQ.L	#4,A7

	CLR.W	-(A7)	
	PEA	LINKNM(PC)
	MOVE.W	#$3C,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	MOVE.W	D0,D7
	PEA	LINK(PC)
	MOVE.L	D6,-(A7)
	MOVE.W	D7,-(A7)
	MOVE.W	#$40,-(A7)
	TRAP	#1
	LEA	12(A7),A7

	BSR	CLOSE

	CLR.W	-(A7)	
	PEA	BLOCK(PC)
	MOVE.W	#$3C,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	MOVE.W	D0,D7

	PEA	SAVES(PC)
	MOVE.L	#16*files,-(A7)	;NUMBER OF FILES*16
	MOVE.W	D7,-(A7)
	MOVE.W	#$40,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVE.W	D7,-(A7)
	BSR	CLOSE

;	PEA	OLD(PC)
;	MOVE.W	#$3B,-(A7)
;	TRAP	#1
;	ADDQ.L	#6,A7

QUIT	PEA	0
	TRAP	#1

CLOSE	MOVE.W	D7,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	RTS

PRINT	MOVEM.L	D0-D2/A0-A2,-(A7)
	BSR	CONWS
	LEA	RET(PC),A0
	BSR	CONWS
	MOVEM.L	(A7)+,D0-D2/A0-A2	
	rts

CONWS	PEA	(A0)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS

RET	DC.B	13,10,0
	EVEN
OFFSET	DC.L	0

;
; This is the linkfile filename
;
LINKNM	DC.B	"e:\inter+.lnk",0
	EVEN
;
; This is where the offset block file is saved too
;
BLOCK	DC.B	"inter+.blk",0
	EVEN
OLD	dc.b	"a:"
;
; This is the search criteria for the file-grab
;
FILE	DC.B	"*.*",0
	EVEN
;
; This is where the files are grabbed from
;
PATH	DC.B	"\hack_me\",0
	EVEN
DTA	DS.L	1	
BUF	DC.L	LINK

SAVES	DS.L	16*files		;NUMBER OF FILES*16
LINK	
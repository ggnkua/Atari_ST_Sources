*	Parallax scrolling demo
*	Last altered 27/10/89

	OPT T+,O+,W-		Type checking, optimising
in	EQU 0			input file handle
screen	EQU 4			screen start address
scr1	EQU 8
scr2	EQU 12
send1	EQU 16
send2	EQU 20
count1	EQU 24
count2	EQU 28
back	EQU 32			other screen
flag	EQU 36

prints	MACRO			Print a string
	PEA \1(PC)
	MOVE #9,-(A7)		c_conws
	TRAP #1
	ADDQ.L #6,A7
	ENDM

f_open	MACRO			Open a file
  	MOVE #\1,-(A7)		read/write flag
	PEA \2(PC)		filename
	MOVE #61,-(A7)		f_open
	TRAP #1
	ADDQ.L #8,A7
	ENDM			D0=handle

f_close	MACRO			Close a file
  	MOVE \1(A6),-(A7)	handle
	MOVE #62,-(A7)		f_close
	TRAP #1
	ADDQ.L #4,A7
	ENDM

f_read	MACRO			Read from file into buffer
	MOVE.L \1,-(A7)		input buffer
	MOVE.L #\2,-(A7)	bytes to read
	MOVE \3(A6),-(A7)	handle
	MOVE #63,-(A7)		f_read
	TRAP #1
	ADDA.L #12,A7
	ENDM			D0=bytes read

*********************************************************************
*	Start of program
*********************************************************************

*----->	Initialise
	MOVE #-1,-(A7)		cursor off
	MOVE #0,-(A7)
	MOVE #21,-(A7)		cursconf
	TRAP #14
	ADDQ.L #6,A7
	LEA var(PC),A6		A6 -> variables
	MOVE #2,-(A7)		_physbase...get screen address
	TRAP #14
	ADDQ.L #2,A7
	MOVE.L D0,screen(A6)	screen start address

*----->	Get buffer adress
	MOVE.L 4(A7),A0		get base page in A0
	MOVE.L $C(A0),D0	get text segment size
	ADD.L $14(A0),D0	add data segment
	ADD.L  $1C(A0),D0	add uninitialised bit
	ADD.L #$100,D0		add base page length
	ADDA.L D0,A0		A0 -> buffer
	MOVE.L A0,scr1(A6)	address of scr1
	ADDA.L #33000,A0	screen2 starts here
	MOVE.L A0,scr2(A6)	address of scr2
	ADDA.L #33000,A0	address of dual screen
	MOVE.L A0,back(A6)	store address of dual screen
	ANDI.L #$FFFFFF00,back(A6)

*----->	Load pictures
	f_open 0,pic1		load PICTURE1.PIC
	MOVE D0,in(A6)		store file handle
	f_read scr1(A6),33000,in
	f_close in
	f_open 0,pic2		load PICTURE2.PIC
	MOVE D0,in(A6)		store file handle
	f_read scr2(A6),33000,in
	f_close in

*----->	Skip Degas headers, set screen ends
	ADDI.L #34,scr1(A6)	skip header
	ADDI.L #34,scr2(A6)	skip header
	MOVE.L scr1(A6),A0
	ADDA.L #32000,A0
	MOVE.L A0,send1(A6)	end of screen1
	MOVE.L scr2(A6),A0
	ADDA.L #32000,A0
	MOVE.L A0,send2(A6)	end of screen1

*----->	Display screen
	CLR.L count1(A6)	set counter
	CLR.L count2(A6)	set counter
scroll	BSR setscr		A0=screen
	MOVEA.L scr1(A6),A1	A1=screen1
	MOVE.L count1(A6),D0	get counter
	CMPI #200,D0
	BNE s2
	CLR.L D0
	MOVE.L D0,count1(A6)	set counter
s2	MOVE.L #160,D1		one scanline
	MULU D1,D0
	ADDA.L D0,A1		new start address
	ADDQ.L #1,count1(A6)
	MOVEA.L scr2(A6),A2	A2=screen2
	MOVE.L count2(A6),D0	get counter
	BPL s1
	MOVE.L #199,D0
	MOVE.L D0,count2(A6)	set counter
s1	MULU D1,D0
	ADDA.L D0,A2		new start address
	SUBQ.L #1,count2(A6)
	BSR draw

*----->	Wait for keypress
	MOVE #11,-(A7)		c_conis...key pressed?
	TRAP #1
	ADDQ.L #2,A7
	TST D0
	BEQ scroll
	MOVE #8,-(A7)		c_necin...read keypress
	TRAP #1
	ADDQ.L #2,A7

*----->	Return to desktop
	CLR flag(A6)		restore original screen address
	BSR setscr
	MOVE #-1,-(A7)		cursor on
	MOVE #1,-(A7)
	MOVE #21,-(A7)		cursconf
	TRAP #14
	ADDQ.L #6,A7
	CLR -(A7)		p_term0...back to desktop
	TRAP #1


setscr	EORI #1,flag(A6)
	BEQ set1
	MOVE #-1,-(A7)
	MOVE.L screen(A6),-(A7)
	MOVE.L #-1,-(A7)
	MOVE #5,-(A7)
	TRAP #14
	ADDA.L #12,A7
	MOVEA.L back(A6),A0
	RTS
set1	MOVE #-1,-(A7)
	MOVE.L back(A6),-(A7)
	MOVE.L #-1,-(A7)
	MOVE #5,-(A7)
	TRAP #14
	ADDA.L #12,A7
	MOVEA.L screen(A6),A0
	RTS

*********************************************************************
*	screen = screen1+screen2
*	A0=realscreen, A1=screen1, A2=screen2
*********************************************************************
draw	MOVE #199,D7
dloop
	REPT 20
	MOVE (A1),D0		make mask from screen1
	OR 2(A1),D0		OR 4 words
	OR 4(A1),D0		OR 4 words
	OR 6(A1),D0		OR 4 words
	NOT D0
	MOVE D0,D1		store mask in D1...
	SWAP D1
	MOVE D0,D1		...in lower and upper words
	MOVE.L D1,D0		get mask
	AND.L (A2)+,D0		AND longword0 from screen2
	OR.L (A1)+,D0		OR longword0 from screen1
	MOVE.L D0,(A0)+		store longword0 in screen
	AND.L (A2)+,D1		AND longword1 from screen2
	OR.L (A1)+,D1		OR longword1 from screen1
	MOVE.L D1,(A0)+		store longword0 in screen
	ENDR
	CMP.L send2(A6),A2
	BLT d1
	SUBA.L #32000,A2
d1	CMP.L send1(A6),A1
	BLT d2
	SUBA.L #32000,A1
d2	DBRA D7,dloop

	RTS

*********************************************************************

var	DS.L 15			space for 15 variables

pic1	DC.B 'A:\AUTO\PICTURE2.PI1',0
pic2	DC.B 'A:\AUTO\PICTURE1.PI1',0

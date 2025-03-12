	SECTION	TEXT

	
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)		;supervisor mode
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,old_sp
	
	MOVE.W	#4,-(SP)		;get rez
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,old_rez
	CMPI.W	#2,D0
	BEQ	quit

	LEA	$FFFF8240.W,A0
	LEA	def_pal,A1
	LEA	32(A1),A1		;store colours
	MOVEM.L	(A0)+,D0-D7
	MOVEM.L	D0-D7,-(A1)

	CLR.W	-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP
	
********************** START OF SCROLLER CODE ************************

start	LEA	text,A0
scroll	MOVEQ.L	#0,D4
	MOVE.B	(A0),D4			;next letter
 	TST.B	(A0)+			;end of text
	BNE.S	chr_val
	BRA.S	start

chr_val	SUBI.B	#32,D4			;where's that character?
	DIVU.W	#20,D4
	MOVEQ.L	#0,D5
	MOVE.W	D4,D5
	ASL	#7,D5
	MULU.W	#10,D5
	CLR.W	D4
	SWAP	D4
	ASL	#3,D4
	LEA	font,A5
	ADD.W	D5,A5
	ADD.W	D4,A5

	MOVEQ.W	#7,D7
	LEA	stc_pad,A6		;copy letter to scratch pad
cpy_chr	MOVE.W	(A5),(A6)
	ADDQ.L	#4,A6
	LEA	160(A5),A5
	DBF	D7,cpy_chr

	MOVEQ.W	#7,D6			;pixels across
pixels	MOVE.L	$44E.W,A1		;screen address
	LEA	28800(A1),A1		;some where near the bottom!
	LEA	stc_pad,A6

	MOVEQ.W	#7,D7			;lines to ROXL
lines	MOVE.L	(A6),D0
	LSL.L	D0
	MOVE.L	D0,(A6)+

	ROXL	152(A1)			;lotsa ROXL's
	ROXL	144(A1)
	ROXL	136(A1)
	ROXL	128(A1)
	ROXL	120(A1)
	ROXL	112(A1)
	ROXL	104(A1)
	ROXL	96(A1)
	ROXL	88(A1)
	ROXL	80(A1)
	ROXL	72(A1)
	ROXL	64(A1)
	ROXL	56(A1)
	ROXL	48(A1)
	ROXL	40(A1)
	ROXL	32(A1)
	ROXL	24(A1)
	ROXL	16(A1)
	ROXL	8(A1)
	ROXL	(A1)

	LEA	160(A1),A1		;add 160 (1 line) to screen addr
	DBF	D7,lines

	MOVE.L	$462.W,D0		;vbl frame counter
vbl	CMP.L	$462.W,D0		;wait for vbl
	BEQ.S	vbl

	DBF	D6,pixels		;rest of the pixels

	MOVE.W	#$FF,-(SP)		;wait for a key press
	MOVE.W	#$06,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	TST.B	D0

	BEQ	scroll

********************** END OF SCROLLER CODE ***************************

	MOVE.W	old_rez,-(SP)		;restore rez
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP

	LEA	def_pal,A0
	LEA	$FFFF8260.W,A1		;restore colours
	MOVEM.L	(A0)+,D0-D7
	MOVEM.L	D0-D7,-(A1)

quit	MOVE.L	old_sp,-(SP)
	MOVE.W	#$20,-(SP)		;user mode
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR.W	-(SP)			;p_term
	TRAP	#1


	SECTION	DATA

text	DC.B	"THE MONSTER OF THE FCC        GREETINGS TO ALEC,"
	DC.B	" LAWZ, EDDIE             "
	DC.B	0		;terminator
	EVEN

font	INCBIN	\FONT.FNT

	SECTION	BSS


old_sp	DS.L	1
old_rez	DS.W	1
def_pal	DS.W	16
stc_pad	DS.L	8
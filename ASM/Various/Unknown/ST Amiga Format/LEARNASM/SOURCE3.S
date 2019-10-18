		OPT	D+,C+

		BSR	START
* A5 now points to the screen base.
* Your code goes here:



* Program to print 8 factorials.
		MOVEQ	#0,D6
		MOVEQ	#1,D5
main_loop	ADDQ	#1,D6		next factor
		MULU	D6,D5		running factorial
		MOVE.L	D5,D0
		BSR	number_printer	print number
		CMP	#8,D6		all done?
		BNE	main_loop	no
		BRA	done		yes
*
* In this code several instructions can be replace by more efficient ones
* but this has not been done since they have yet to be covered in the text.
*
* This code should be run from a low resolution Desktop!
*
* Routine to print an unsigned word in decimal.
* Entered with A5 pointing an even screen address at which the printing is
* to start and with D0.L containing the number to be printed.
* D0-D4/A0/A1 smashed.
number_printer	MOVEA.L	A5,A0		screen column ptr
		MOVE.L	#$70001,D3	column delta (see next month)
		MOVEQ	#0,D2		leading zero flag
* determine number of 'ten thousands':
		DIVU	#10000,D0
		BEQ.S	no_ten_thousands
		MOVEQ	#1,D2		no more leading zeros
		BSR	digit_printer
		ADDA	D3,A0		next screen column
		SWAP	D3		prepare offset for next column
		MOVE	#0,D0		prepare for divide
* determine number of 'thousands':
no_ten_thousands	SWAP	D0		look at remainder
		DIVU	#1000,D0
		BNE.S	some_thousands
		CMP	#0,D2
		BEQ.S	no_thousands
some_thousands	MOVEQ	#1,D2		no more leading zeros
		BSR	digit_printer
		ADDA	D3,A0		next screen column
		SWAP	D3		prepare offset for next column
		MOVE	#0,D0		prepare for divide
* determine number of 'hundreds':
no_thousands	SWAP	D0		look at remainder
		DIVU	#100,D0
		BNE.S	some_hundreds
		CMP	#0,D2
		BEQ.S	no_hundreds
some_hundreds	MOVEQ	#1,D2		no more leading zeros
		BSR	digit_printer
		ADDA	D3,A0		next screen column
		SWAP	D3		prepare offset for next column
		MOVE	#0,D0		prepare for divide
* determine number of 'tens':
no_hundreds	SWAP	D0		look at remainder
		DIVU	#10,D0
		BNE.S	some_tens
		CMP	#0,D2
		BEQ.S	no_tens
some_tens	BSR	digit_printer
		ADDA	D3,A0		next screen column
		SWAP	D3		prepare offset for next column
		MOVE	#0,D0		prepare for divide
* the remainder is equal to the number of 'units':
no_tens		SWAP	D0		always print units
*					(fall through to next routine)
*
* Routine to print a single digit.
* Entered with A0 pointing to screen address of top row of first character
* and with D0.W containing the digit to be printed.
* D1/D4/A1 smashed.
digit_printer	MOVE	D0,D1
		MULU	#8,D1			digit index -> offset
* Point to correct bit image data:
		LEA	digit_images(PC,D1),A1
		MOVEQ	#8-1,D4			8 rows
text_loop	MOVE.B	(A1)+,(A0)		write row of image
		LEA	160(A0),A0		next screen row
		DBRA	D4,text_loop
		LEA	-160*8(A0),A0		restore screen ptr
		RTS
* Font data:
digit_images	DC.B	$7C,$C6,$C6,$00,$C6,$C6,$7C,$00	"O"
		DC.B	$18,$18,$18,$00,$18,$18,$18,$00	"1"
		DC.B	$7C,$06,$06,$7C,$C0,$C0,$7C,$00	"2"
		DC.B	$7C,$06,$06,$7C,$06,$06,$7C,$00	"3"
		DC.B	$C6,$C6,$C6,$7C,$06,$06,$06,$00	"4"
		DC.B	$7C,$C0,$C0,$7C,$06,$06,$7C,$00	"5"
		DC.B	$7C,$C0,$C0,$7C,$C6,$C6,$7C,$00	"6"
		DC.B	$7C,$06,$06,$00,$06,$06,$06,$00	"7"
		DC.B	$7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	"8"
		DC.B	$7C,$C6,$C6,$7C,$06,$06,$7C,$00	"9"




* (End of your code.)
done
* Terminate:
		LEA	Variables(PC),A5
wait		BSR.S	Get_Key
		BEQ.S	wait		no key
		CMP.B	#13,D0		return?
		BNE.S	wait		no
* Return to Desktop:
		MOVE.L	#$4C0000,-(A7)
		TRAP	#1			ciao
*
* Remove flashing cursor:
START		MOVE	#27,-(A7)
		MOVE.L	#$30002,-(A7)
		TRAP	#13
		MOVE	#"f",4(A7)
		MOVE.L	#$30002,(A7)
		TRAP	#13
		ADDQ.L	#6,A7
*
		LEA	Variables(PC),A5
* Read current physical screen base address:
		MOVE	#2,-(A7)
		TRAP	#14
		ADDQ.L	#2,A7
		MOVE.L	D0,(A5)
		MOVEA.L	D0,A5
		RTS
*
* Routine to read a key. Returns Z set if no key else key code in D0.
Get_Key		MOVE.L	#$10002,-(A7)
		TRAP	#13
		ADDQ.L	#4,A7
		TST	D0		key available?
		BEQ.S	key_done		no
		MOVE.L	#$20002,-(A7)
		TRAP	#13
		ADDQ.L	#4,A7
		MOVEQ	#1,D1		clear Z
key_done		RTS
*
Variables	DS.L	1	ptr to physical screen			x min					 0

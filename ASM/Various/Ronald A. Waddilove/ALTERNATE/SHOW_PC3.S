**********************************************************************
* Load and display a Degas Elite compressed mono screen: PICTURE.PC3 *
* Written using Devpac 2 by R.A.Waddilove			     *
**********************************************************************

	OPT T+,O+,W-		Type checking, optimising on

in	EQU 0			input file handle
buffer	EQU 2			buffer address
palette	EQU 6			palette address

*********************************************************************
*	Macros
*********************************************************************
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
	PEA \1(A6)		input buffer
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
	TRAP #14		XBIOS
	ADDQ.L #2,A7		tidy stack
	MOVEA.L D0,A5		A5 = screen start address

*----->	Load palette
	f_open 0,pic		open file
	MOVE D0,in(A6)		store file handle
	f_read palette,34,in	read res and palette information

*----->	Decode compacted picture data
	MOVE #399,D7		400 scan lines
	MOVEA.L A5,A4		A5 = current scan line address
loop1	ADDA.L #80,A4		A4 = next scan line address
loop2	f_read buffer,1,in	read 1 byte
	MOVE.B buffer(A6),D0	D0 = byte
	CMP.B #128,D0		< 128 ?
	BPL skip1
	MOVE D0,D6		loop counter
	ANDI #$FF,D6
loop3	f_read buffer,1,in	read byte
	MOVE.B buffer(A6),(A5)+	store in screen
	DBRA D6,loop3
	BRA next
skip1	CMP.B #129,D0		> 128 ?
	BMI next
	MOVE D0,D6		loop counter
	NOT D6
	ANDI #$FF,D6
	ADDQ.L #1,D6
	f_read buffer,1,in	read byte
loop4	MOVE.B buffer(A6),(A5)+
	DBRA D6,loop4
next	MOVE.L A5,D0		done whole scan line?
	CMP.L A4,D0
	BMI loop2		back to loop2 if not done
	MOVEA.L A4,A5		next scan line address
	DBRA D7,loop1		done all scan lines?
	f_close in		close file

*----->	Return to desktop
	MOVE #8,-(A7)		c_necin...wait for a keypress
	TRAP #1			GEM BDOS
	ADDQ.L #2,A7
	MOVE #-1,-(A7)		cursor on
	MOVE #1,-(A7)
	MOVE #21,-(A7)		cursconf
	TRAP #14
	ADDQ.L #6,A7
	CLR -(A7)		p_term0...back to desktop
	TRAP #1

var	DS.W 20			20 word variables
pic	DC.B 'picture.pc3',0
	EVEN
	END

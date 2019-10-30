*	Extended formatter - double sided 81 track x 10 sector
* 	By R.A.Waddilove
*	Last modified 30/7/89

	OPT O+			all optimising on

	MOVE.L 4(A7),A6		get base page in A6
	MOVE.L $C(A6),D0	get text segment size
	ADD.L $14(A6),D0	add data segment
	ADD.L  $1C(A6),D0	add uninitialised bit
	ADD.L #$100,D0		add base page length
	ADDA.L D0,A6		buffer starts here

	PEA prompt(PC)   	Print prompt
	MOVE.W #9,-(A7)
	TRAP #1          	BDOS 9
	ADDQ.L #6,A7      	Tidy stack
	MOVE #8,-(A7)		C_NECIN
	TRAP #1			wait for keypress
	ADDQ.L #2,A7

	PEA okmess(PC)   	Print formatting message
	MOVE.W #9,-(A7)
	TRAP #1          	BDOS 9
	ADDQ.L #6,A7      	Tidy stack

	MOVE #0,D7		FOR i=0 TO 80
loop	MOVE #0,D0		format side 0
	BSR format
	CMPI #0,D0		everything ok?
	BNE error
	MOVE #1,D0		format side 1
	BSR format
	CMPI #0,D0		everything ok?
	BNE error
	ADDQ #1,D7		NEXT track?
	CMP #81,D7
	BNE loop

	MOVE #2400,D0
	MOVEA.L A6,A5		copy buffer address
loop1	CLR.L (A5)+		zero buffer
	DBRA D0,loop1

* 	Zero directory
	MOVE #1,D0		side 1
	MOVE #0,D1		track 0
	BSR write		zero track
	CMPI #0,D0		everything ok?
	BNE error

*	Create boot sector
	MOVE #0,-(A7)		not executable boot sector
	MOVE #3,-(A7)		80 track double side
	MOVE.L #$1000001,-(A7)	random serial number
	MOVE.L A6,-(A7)		buffer address
	MOVE #18,-(A7)		_PROTOBT
	TRAP #14		make prototype boot sector
	ADDA.L #14,A7		tidy stack

*	Modify boot sector
	MOVE.B #10,24(A6)	10 sectors per track
	MOVE.B #84,19(A6)	84+6*256 (1620) sectors
	MOVE.B #6,20(A6)

*	Write boot sector
	MOVE #0,D0		side 0
	MOVE #0,D1		track 0
	BSR write		write boot sector & directory
	CMPI #0,D0		everything ok?
	BEQ exit

error	PEA errmess(PC)   	Print error message
	MOVE.W #9,-(A7)
	TRAP #1          	BDOS 9
	ADDQ.L #6,A7      	Tidy stack
	MOVE #8,-(A7)		C_NECIN
	TRAP #1			wait for keypress
	ADDQ.L #2,A7		tidy stack

exit	MOVE.W #0,-(A7)  	Return to Desktop
	TRAP #1          	BDOS 1

*********************************************************************
* Write side D0, track D1, buffer A6
*********************************************************************
write	MOVE #10,-(A7)		10 sectors
	MOVE D0,-(A7)		side D0
	MOVE D1,-(A7)		track D1
	MOVE #1,-(A7)		sector 1
	MOVE #0,-(A7)		drive 0
	MOVE.L #0,-(A7)		not used
	MOVE.L A6,-(A7)		buffer address
	MOVE #9,-(A7)		_FLOPWR
	TRAP #14		write
	ADDA.L #20,A7		tidy stack
	RTS

*********************************************************************
* Format side D0, track D7, buffer A6
*********************************************************************
format	MOVE #$E5E5,-(A7)	format code
	MOVE.L #$87654321,-(A7)	magic number
	MOVE #1,-(A7)		interleave factor
	MOVE D0,-(A7)		side D0
	MOVE D7,-(A7)		track D7
	MOVE #10,-(A7)		10 sectors per track
	MOVE #0,-(A7)		drive 0
	MOVE.L #0,-(A7)		not used
	MOVE.L A6,-(A7)		buffer address=A6
	MOVE #10,-(A7)		_FLOPFMT
	TRAP #14		format track
	ADDA.L #26,A7		tidy stack
	RTS

	EVEN
prompt	DC.B "******* Extended Formatter *******",13,10
	DC.B " Double sided 81 track x 10 sector",13,10
	DC.B " Insert disc to format in Drive A",13,10
	DC.B " Then press a key...",0
	EVEN
okmess	DC.B 13,10," Formatting...",0
	EVEN
errmess	DC.B 13,10," An error has occurred!"
	DC.B 13,10," Press a key to exit...",0
	EVEN
	END
	
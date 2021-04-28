*********************************
*	Extended formatter	*
* 	 By R.A.Waddilove	*
*     ST User September 1989    *
*      Last modified 1/7/89	*
*********************************

	OPT O+			all optimising on

tracks	EQU 80			81 tracks (0-80)
sectors	EQU 10			10 sectors per track

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

	MOVE #0,D7		FOR i=0 TO track
loop	MOVE #$E5E5,-(A7)	format code
	MOVE.L #$87654321,-(A7)	magic number
	MOVE #1,-(A7)		interleave factor
	MOVE #0,-(A7)		side 0
	MOVE D7,-(A7)		track D7
	MOVE #sectors,-(A7)	10 sectors per track
	MOVE #0,-(A7)		drive 0
	MOVE.L #0,-(A7)		not used
	MOVE.L A6,-(A7)		buffer address
	MOVE #10,-(A7)		_FLOPFMT
	TRAP #14		format track
	ADDA.L #26,A7		tidy stack
	CMPI #0,D0		everything ok?
	BNE error
	ADDQ #1,D7		NEXT track?
	CMP #tracks,D7
	BNE loop

	MOVE #2400,D0
	MOVEA.L A6,A5		copy buffer address
loop1	CLR.L (A5)+		zero buffer
	DBRA D0,loop1

	MOVE #0,-(A7)		not executable boot sector
	MOVE #2,-(A7)		80 track single side
	MOVE.L #$1000001,-(A7)	random serial number
	MOVE.L A6,-(A7)		buffer address
	MOVE #18,-(A7)		_PROTOBT
	TRAP #14		make prototype boot sector
	ADDA.L #14,A7		tidy stack

	MOVE.B #sectors,24(A6)	10 sectors per track
	MOVE.B #42,19(A6)	42+3*256 sectors
	MOVE.B #3,20(A6)

	MOVE #sectors,-(A7)	number of sectors
	MOVE #0,-(A7)		side 0
	MOVE #0,-(A7)		track 0
	MOVE #1,-(A7)		sector 1
	MOVE #0,-(A7)		drive 0
	MOVE.L #0,-(A7)		not used
	MOVE.L A6,-(A7)		buffer address
	MOVE #9,-(A7)		_FLOPWR
	TRAP #14		write boot sector & directory
	ADDA.L #20,A7		tidy stack
	CMPI #0,D0		everything ok?
	BEQ exit

error	PEA errmess(PC)   	Print error message
	MOVE.W #9,-(A7)
	TRAP #1          	BDOS 9
	ADDQ.L #6,A7      	Tidy stack
	MOVE #8,-(A7)		C_NECIN
	TRAP #1			wait for keypress
	ADDQ.L #2,A7		tidy stack
	BRA exit

exit	MOVE.W #0,-(A7)  	Return to Desktop
	TRAP #1          	BDOS 1

prompt	DC.B 13,10,"Insert disc to format in Drive A"
	DC.B 13,10,"Then press a key:",0
	EVEN
okmess	DC.B 13,10,"Formatting...",0
	EVEN
errmess	DC.B 13,10,"An error has occurred"
	DC.B 13,10,"Press a key to exit...",0
	EVEN
	END
	
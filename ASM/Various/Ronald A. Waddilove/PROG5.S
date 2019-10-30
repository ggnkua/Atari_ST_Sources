*	Program IV
*	Read a file from disc

*	Open the file for reading
	MOVE #0,-(A7)		File mode = 0 = read
	PEA name(PC)		Filename
	MOVE #61,-(A7)		f_open
	TRAP #1			GEMDOS
	ADDQ.L #8,A7		Tidy stack
	MOVE D0,D7		Save file handle in D7

*	Read data from the file
loop	PEA buffer(PC)		Address of I/O buffer
	MOVE.L #1,-(A7)		One byte to read
	MOVE D7,-(A7)		File handle
	MOVE #63,-(A7)		f_read
	TRAP #1			GEMDOS
	ADDA.L #12,A7		Tidy stack
	CMPI.B #1,D0		Finished? (D0<0)
	BMI close

*	Print the data on the screen
	CLR D0			D0 = 0
	MOVE.B buffer(PC),D0	Get character
	MOVE D0,-(A7)		Stack it
	MOVE #2,-(A7)		c_conout
	TRAP #1
	ADDQ.L #4,A7
	BRA loop		Another one...

*	Close the file
close	MOVE D7,-(A7)		File handle
	MOVE #62,-(A7)		f_close
	TRAP #1			GEMDOS
	ADDQ.L #4,A7		Tidy stack

*	Wait for a keypress
	MOVE #8,-(A7)		c_necin
	TRAP #1
	ADDQ.L #2,A7
*	Return to desktop
exit	CLR -(A7)		p_term0
	TRAP #1

buffer	DC.W 0			I/O buffer
name	DC.B 'ALPHABET.ASC',0	Filename
	EVEN

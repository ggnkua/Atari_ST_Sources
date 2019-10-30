*	Program IV
*	Write a file to disc

*	Create the file and make it readable and writeable
	MOVE #0,-(A7)		File attributes = 0 = read/write
	PEA name(PC)		Filename
	MOVE #60,-(A7)		f_create
	TRAP #1			GEMDOS
	ADDQ.L #8,A7		Tidy stack
	MOVE D0,D7		Save file handle in D7

*	Write the data to the file
	LEA buffer(PC),A6	A6 points to buffer
	MOVE #'A',D6		Put Ascii 'A' in D6
loop	MOVE.B D6,(A6)		Put A in buffer
	MOVE.L A6,-(A7)		Address of buffer
	MOVE.L #1,-(A7)		One byte to write
	MOVE D7,-(A7)		File handle
	MOVE #64,-(A7)		f_write
	TRAP #1			GEMDOS
	ADDA.L #12,A7		Tidy stack
	ADDQ.B #1,D6		Next letter
	CMPI.B #'Z',D6		Finished?
	BLE loop

*	Close the file
	MOVE D7,-(A7)		File handle
	MOVE #62,-(A7)		f_close
	TRAP #1			GEMDOS
	ADDQ.L #4,A7		Tidy stack

*	Return to desktop
	CLR -(A7)		p_term0
	TRAP #1

buffer	DC.W 0			I/O buffer
name	DC.B 'ALPHABET.ASC',0	Filename
	EVEN

***************************************
*	Change a file's attributes    *
***************************************

* Print the input prompt string
	PEA prompt(PC)		address of string
	MOVE.W #9,-(A7)		c_conws
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Input the filename of the file to alter
 	PEA name(PC)		stack input buffer address
	MOVE.W #10,-(A7)	c_conrs
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack

* Alter the attributes - hide the file
	MOVE.W #2,-(A7)		hide filename
	MOVE.W #1,-(A7)		set attributes
	PEA name+2(PC)		stack address of name
	MOVE.W #67,-(A7)	f_attrib
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Finished, so return to the desktop
	CLR -(A7)		p_term_old
	TRAP #1			Gem Bdos


prompt	DC.B 'Enter file to hide: ',0
name	DC.B 63,0		input buffer
	DS.B 64			filename stored here
	EVEN

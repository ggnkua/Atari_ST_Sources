*****************************************
*	Delete a file.			*
*	Atari ST User, May 1990.	*
*****************************************

* Print the input prompt string
	PEA prompt(PC)		address of string
	MOVE.W #9,-(A7)		c_conws
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Input the filename of the file to delete 
 	PEA name(PC)		stack input buffer address
	MOVE.W #10,-(A7)	c_conrs
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack

* Delete the file using f_delete
	PEA name+2(PC)		stack address of name
	MOVE.W #65,-(A7)	f_delete
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Finished, so return to the desktop
	CLR -(A7)		p_term_old
	TRAP #1			Gem Bdos


prompt	DC.B 'Enter file to delete: ',0
name	DC.B 63,0		input buffer
	DS.B 64			name stored here
	EVEN

***************************************
*	Delete a directory	      *
***************************************

* Print the input prompt string
	PEA prompt(PC)		address of string
	MOVE.W #9,-(A7)		c_conws
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Input the name of the directory to delete
 	PEA name(PC)		stack input buffer address
	MOVE.W #10,-(A7)	c_conrs
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack

* Delete the directory using d_delete
	PEA name+2(PC)		stack address of name
	MOVE.W #58,-(A7)	d_delete
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Finished, so return to the desktop
	CLR -(A7)		p_term_old
	TRAP #1			Gem Bdos


prompt	DC.B 'Enter directory to delete: ',0
name	DC.B 63,0		input buffer
	DS.B 64			name stored here
	EVEN

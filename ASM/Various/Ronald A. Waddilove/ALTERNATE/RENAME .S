*****************************************
*	Rename a file.			*
*	Atari ST User, May 1990.	*
*****************************************

* Print the old name input prompt
	PEA prompt1(PC)		address of string
	MOVE.W #9,-(A7)		c_conws
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Input the old name of the file
 	PEA oldname(PC)		stack input buffer address
	MOVE.W #10,-(A7)	c_conrs
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack

* Print the new name input prompt
	PEA prompt2(PC)		address of string
	MOVE.W #9,-(A7)		c_conws
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack up

* Input the new name of the file
 	PEA newname(PC)		stack input buffer address
	MOVE.W #10,-(A7)	c_conrs
	TRAP #1			Gem Bdos
	ADDQ.L #6,A7		tidy stack

* Rename the file from oldname to newname
	PEA newname+2(PC)	stack new filename
	PEA oldname+2(PC)	stack old filename
	CLR -(A7)		dummy value - 0
	MOVE.W #86,-(A7)	f_rename
	TRAP #1			Gem Bdos
	ADDA.L #12,A7		tidy stack up

* Finished, so return to the desktop
	CLR -(A7)		p_term_old
	TRAP #1			Gem Bdos

prompt1	DC.B 13,10,'Enter old filename: ',0
prompt2	DC.B 13,10,'Enter new filename: ',0
oldname	DC.B 63,0
	DS.B 64			old name stored here
newname	DC.B 63,0
	DS.B 64			new name stored here
	EVEN

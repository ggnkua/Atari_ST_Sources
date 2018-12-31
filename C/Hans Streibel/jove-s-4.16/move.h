/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

extern void
	b_char proto((int n)),
	f_char proto((int n)),
	f_word proto((int num)),
	line_move proto((int dir, int n, bool line_cmd));

extern int
	how_far proto((LinePtr line,int col));

/* Commands: */

extern void
	BackChar proto((void)),
	BackWord proto((void)),
	Bof proto((void)),
	Bol proto((void)),
	Bos proto((void)),
	Eof proto((void)),
	Eol proto((void)),
	Eos proto((void)),
	ForChar proto((void)),
	ForWord proto((void)),
	ForIdent proto((void)),
	NextLine proto((void)),
	PrevLine proto((void));

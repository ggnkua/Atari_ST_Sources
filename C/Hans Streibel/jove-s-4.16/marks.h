/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

extern void
	AllMarkReset proto((Buffer *b,LinePtr line)),
	DFixMarks proto((LinePtr line1,int char1,LinePtr line2,int char2)),
	DelMark proto((Mark *m)),
	IFixMarks proto((LinePtr line1, int char1, LinePtr line2, int char2)),
	MarkSet proto((Mark *m, LinePtr line, int column)),
	ToMark proto((Mark *m)),
	flush_marks proto((Buffer *)),
	do_set_mark proto((LinePtr l, int c)),
	set_mark proto((void));

extern Mark
	*CurMark proto((void)),
	*MakeMark proto((LinePtr line,int column));

/* Commands: */

extern void
	PopMark proto((void)),
	ExchPtMark proto((void)),
	SetMark proto((void));

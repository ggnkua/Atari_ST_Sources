/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* ??? Why, for example, are GCchunks, lfreelist, and lfreereg here? -- DHR */

extern Bufpos *DoYank proto((
	LinePtr fline, int fchar,
	LinePtr tline, int tchar,
	LinePtr atline, int atchar,
	Buffer *whatbuf));

extern void
	ins_str proto((const char *str)),
	ins_str_wrap proto((const char *str, bool ok_nl, int wrap_off)),
	LineInsert proto((int num)),
	open_lines proto((int n)),
	overwrite proto((DAPchar c, int n)),
	insert_c proto((DAPchar c,int n)),
	GCchunks proto((void)),
	lfreelist proto((LinePtr first)),
	lfreereg proto((LinePtr line1,LinePtr line2)),
	n_indent proto((int goal));

#ifdef ABBREV
extern void	MaybeAbbrevExpand proto((void));
#endif

extern LinePtr
	nbufline proto((void));

/* Commands: */

extern void
#ifdef LISP
	AddSpecial proto((void)),	/* add lisp special form */
	GSexpr proto((void)),	/* Grind S Expression. */
#endif
	DoParen proto((void)),
	LineAI proto((void)),
	Newline proto((void)),
	OpenLine proto((void)),
	QuotChar proto((void)),
	SelfInsert proto((void)),
	Tab proto((void)),
	YankPop proto((void));


/* Variables: */

extern int	CIndIncrmt;	/* VAR: how much each indentation level pushes over in C mode */
extern int	PDelay;		/* VAR: paren flash delay in tenths of a second */

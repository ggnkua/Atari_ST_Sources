/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef HIGHLIGHTING

typedef struct LErange {
	unsigned
		start,	/* starting column for highlighting */
		width;	/* width of highlighting */
	void (*norm) ptrproto((bool));
	void (*high) ptrproto((bool));
} *LineEffects;

#define	NOEFFECT	((LineEffects) NULL)
extern void US_effect proto((bool));

#else /* !HIGHLIGHTING */

typedef bool	LineEffects;	/* standout or not */
#define	NOEFFECT	NO

#endif /* !HIGHLIGHTING */

struct screenline {
	char
		*s_line,
		*s_roof;	/* character after last */
	LineEffects s_effects;
};

extern struct screenline
	*Screen,
	*Curline;

extern char *cursend;

extern int
	AbortCnt,

	CapLine,	/* cursor line and cursor column */
	CapCol;

extern bool
	BufSwrite proto((int linenum)),
	swrite proto((char *line, LineEffects hl, bool abortable));

extern LineEffects
	WindowRange proto((Window *w));

extern void
	Placur proto((int line,int col)),
	cl_eol proto((void)),
	cl_scr proto((bool doit)),
	clrline proto((char *cp1,char *cp2)),
	i_set proto((int nline,int ncol)),
	make_scr proto((void)),
	v_ins_line proto ((int num, int top, int bottom)),
	v_del_line proto ((int num, int top, int bottom)),
	SO_effect proto((bool)),
	SO_off proto((void));

#define	TABDIST(col)	(tabstop - (col)%tabstop)	/* cols to next tabstop */

/* Variables: */

extern int	tabstop;		/* VAR: expand tabs to this number of spaces */

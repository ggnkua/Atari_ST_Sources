/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

extern Bufpos
	*c_indent proto((bool brace)),
	*m_paren proto((DAPchar p_type, int dir, bool can_mismatch, bool can_stop));

extern void	mp_error proto((void));

/* Variables: */

extern int	CArgIndent;		/* VAR: how to indent arguments to C functions */
#ifdef CMT_FMT
extern char	CmtFmt[80];		/* VAR: comment format */
#endif

/* Commands: */
extern void
	BList proto((void)),
	BSexpr proto((void)),
	BUpList proto((void)),
#ifdef CMT_FMT
	Comment proto((void)),
#endif
	FDownList proto((void)),
	FList proto((void)),
	FSexpr proto((void)),
	LRShift proto((void)),
	RRShift proto((void));

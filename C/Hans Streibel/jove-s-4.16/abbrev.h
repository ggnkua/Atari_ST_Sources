/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef ABBREV	/* the body is the rest of this file */

extern void	AbbrevExpand proto((void));

/* Variables: */

extern bool	AutoCaseAbbrev;		/* VAR: automatically do case on abbreviations */

/* Commands: */
extern void
	BindMtoW proto((void)),
	DefMAbbrev proto((void)),
	DefGAbbrev proto((void)),
	SaveAbbrevs proto((void)),
	RestAbbrevs proto((void)),
	EditAbbrevs proto((void));

#endif /* ABBREV */

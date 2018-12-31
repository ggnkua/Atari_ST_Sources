/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

extern void
	find_tag proto((char *tag,bool localp));

/* Commands: */

extern void
	FDotTag proto((void)),
	FindTag proto((void)),
	IncFSearch proto((void)),
	IncRSearch proto((void)),
	QRepSearch proto((void)),
	RegReplace proto((void)),
	RepSearch proto((void)),
	FSrchND proto((void)),
	ForSearch proto((void)),
	RSrchND proto((void)),
	RevSearch proto((void));

/* Variables: */

extern ZXchar	SExitChar;		/* VAR: type this to stop i-search */
extern char	TagFile[FILESIZE];	/* VAR: default tag file */
extern bool	UseRE;			/* VAR: use regular expressions in search */

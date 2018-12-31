/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef RECOVER	/* the body is the rest of this file */

extern void
	SyncRec proto((void)),
	rectmpname proto((char *)),
	recclose proto((void)),
	recremove proto((void));

extern int	ModCount;	/* number of buffer mods since last sync */

/* Variables: */

extern int	SyncFreq;	/* VAR: how often to sync the file pointers */

#endif /* RECOVER */

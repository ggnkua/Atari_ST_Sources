/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "term.h"

#include "fp.h"

/* universal termcap-like definitions (declared in jove.h) */

int
	SG = 0,		/* number of magic cookies left by SO and SE */
	LI,		/* number of lines */
	ILI,		/* number of internal lines (LI - 1) */
	CO;		/* number of columns (CO <= MAXCOLS) */

bool
	TABS = NO;		/* terminal supports tabs */

#ifndef UNIX
void
settout()
{
# ifndef NO_JSTDOUT
	flushscreen();		/* flush the one character buffer */
	ScrBufSize = min(MAXTTYBUF, 256);
	jstdout = fd_open("/dev/tty", F_WRITE|F_LOCKED, 1, (char *)NULL, ScrBufSize);
# endif
}
#endif /* !UNIX */

/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef MOUSE	/* the body is the rest of this file */

extern void
	MouseOn proto((void)),
	MouseOff proto((void)),

	xjMousePoint proto((void)),
	xjMouseMark proto((void)),
	xjMouseWord proto((void)),
	xjMouseLine proto((void)),
	xjMouseYank proto((void)),
	xjMouseCopyCut proto((void)),

	xtMouseYank proto((void)),
	xtMousePointYank proto((void)),
	xtMouseCutPointYank proto((void)),
	xtMouseExtend proto((void)),
	xtMouseMark proto((void)),
	xtMouseMarkDragPointCopy proto((void)),
	xtMouseNull proto((void)),
	xtMousePoint proto((void));

extern bool	XtermMouse;	/* VAR: should we enable xterm mouse? */

#endif /* MOUSE */

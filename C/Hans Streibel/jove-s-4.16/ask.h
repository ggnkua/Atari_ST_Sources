/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

extern bool
	Asking,		/* are we on read a string from the terminal? */
	InRealAsk;	/* are we currently executing real_ask()? */

extern int
	AskingWidth;	/* width of question being asked */

extern char
	Minibuf[LBSIZE];

#define NULL_ASK_EXT	((bool (*) ptrproto((ZXchar))) NULL)

extern char
	*ask_file proto((const char *prmt, char *def, char *buf)),
	*ask proto((char *, char *, ...)),
	*do_ask proto((const char *, bool (*) ptrproto((ZXchar)), const char *, const char *, ...));

extern bool	yes_or_no_p proto((char *, ...));

extern void	minib_add proto((char *str, bool movedown));

/* Variables: */

extern ZXchar	AbortChar;	/* VAR: cancels command input */
#ifdef F_COMPLETION
extern bool	DispBadFs;		/* VAR: display filenames with bad extensions? */
extern char	BadExtensions[128];	/* VAR: extensions (e.g. ".o") to ignore */
# ifndef MAC	/* no environment in MacOS */
extern bool	DoEVexpand;		/* VAR: should we expand evironment variables? */
# endif
#endif
extern bool	OneKeyConfirmation;		/* VAR: single y or n keystroke sufficient? */

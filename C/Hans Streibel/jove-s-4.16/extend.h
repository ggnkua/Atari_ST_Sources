/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* values for the `flags' argument to complete (may be combined) */
#define CASEIND		001	/* map all to lower case */
#define ALLOW_OLD	002	/* accept member */
#define ALLOW_INDEX	004	/* accept index number as answer (on CR) */
#define ALLOW_NEW	010	/* accept non-member (on CR) */
#define ALLOW_EMPTY	020	/* accept empty answer (on CR) */

extern int	InJoverc;	/* depth in sourcing */

extern bool	joverc proto((char *file));

#ifdef USE_PROTOTYPES
struct variable;	/* forward declaration preventing prototype scoping */
#endif /* USE_PROTOTYPES */

extern void
	DoAutoExec proto((char *new, char *old)),
	vpr_aux proto((const struct variable *, char *, size_t)),
	vset_aux proto((const struct variable *, char *));

extern ZXchar
	addgetc proto((void));

extern int
	ask_int proto((char *def, char *prompt, int base)),
	complete proto((char **possible, const char *def, const char *prompt, int flags));

extern bool	chr_to_int proto((char *cp, int base, bool allints, int *result));

/* Commands: */
extern void
	BufPos proto((void)),
	CAutoExec proto((void)),
	Extend proto((void)),
	MAutoExec proto((void)),
	PrVar proto((void)),
	SetVar proto((void)),
	Source proto((void));

/*
 * Definitions etc. for regexp(3) routines.
 *
 * Caveat:  this is V8 regexp(3) [actually, a reimplementation thereof],
 * not the System V one.
 */

#define void	int		/* Atari ST MegaMax C doesn't know void */
#define strchr	index

#define NSUBEXP  10
typedef struct regexp {
	char *startp[NSUBEXP];
	char *endp[NSUBEXP];
	char regstart;		/* Internal use only. */
	char reganch;		/* Internal use only. */
	char *regmust;		/* Internal use only. */
	int regmlen;		/* Internal use only. */
	char program[1];	/* Unwarranted chumminess with compiler. */
} regexp;

#ifndef REGEXP
extern regexp *regcomp();
extern int regexec();
#endif
extern void regsub();
extern void regerror();

/*
 * The first byte of the regexp internal "program" is actually this magic
 * number; the start node begins in the second byte.
 */
#define	MAGIC	0234

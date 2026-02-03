/*
 *
 * Crtinit: C run-time initialization code.
 * Written by Eric R. Smith, and placed in the public domain.
 * Use at your own risk.
 *
 */

#if 0
#define STRICTLY_COMPATIBLE_WITH_STANDARD
#endif

#include <basepage.h>
#include <osbind.h>
#include <support.h>
#include "lib.h"

#define isspace(c) ((c) == ' '||(c) == '\t')
#define isdigit(c) ((c) >= '0' && (c) <= '9')

#define MINFREE	(8L * 1024L)		/* free at least this much mem */
					/* on top */
#define MINKEEP (9L * 1024L)		/* keep at least this much mem */

BASEPAGE *_base;
char **environ;
static long argc;
static char **argv;

unsigned long _PgmSize;		/* total size of program area */

static long parseargs	__PROTO((BASEPAGE *));

void _crtinit()
{
	register BASEPAGE *bp;
	register long m;
	register long freemem;
	extern void etext();	/* a "function" to fake out pc-rel addressing */

	bp = _base;

/* make m the total number of bytes required by program sans stack/heap */
	m = (bp->p_tlen + bp->p_dlen + bp->p_blen + sizeof(BASEPAGE));
	m = (m + 3L) & (~3L);

/* shrink the TPA */
	(void)Mshrink(bp, m);

/* keep length of program area */
	_PgmSize = m;

/* establish handlers,  call the main routine */
//	_init_signal();

/* start profiling, if we were linked with gcrt0.o */
//	_monstartup((void *)bp->p_tbase, (void *)((long)etext - 1));

	Pterm(main(0, "", "\000\000"));
}


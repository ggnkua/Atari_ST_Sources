#include <setjmp.h>

static	int	_catchval;		/* catch/throw return value */

int catch(id, fn)			/* execute fn() within a catch frame */
	register jmp_buf *id;
	register int (*fn)();
	{
	return(setjmp(id) ? _catchval : ((*fn)()));
	}

throw(id, rv)				/* return rv to the id catch */
	register jmp_buf *id;
	register int rv;
	{
	_catchval = rv;
	longjmp(id, 1);
	}

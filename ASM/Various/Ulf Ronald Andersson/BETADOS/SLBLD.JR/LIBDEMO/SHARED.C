/*
	@(#)slbload/shared.c
	
	Julian F. Reschke, 22. September 1998
*/

#include <stdio.h>
#include <tos.h>

int errno;

long cdecl
slb_init (void)
{
	extern BASPAG start_of_text;
	BASPAG *mybp = &start_of_text - 1;

	fprintf (stderr, "test.slb: slb_init() called, command line is "
		"`%s'\n", mybp->p_cmdlin);

	return 0;
}

void cdecl
slb_exit (void)
{
	fprintf (stderr, "test.slb: slb_exit() called\n");
}

long cdecl
slb_open (BASPAG *bp)
{
	fprintf (stderr, "test.slb: slb_open() by PD %p\n", bp);
	return 0;
}

void cdecl
slb_close (BASPAG *bp)
{
	fprintf (stderr, "test.slb: slb_close() by PD %p\n", bp);
}

long cdecl
test_fun (BASPAG *bp, long fn, int nargs, ...)
{
	fprintf (stderr, "test.slb: function %ld called by PD %p with %d words of stack information\n",
		fn, bp, nargs);
	
	return 0;
}

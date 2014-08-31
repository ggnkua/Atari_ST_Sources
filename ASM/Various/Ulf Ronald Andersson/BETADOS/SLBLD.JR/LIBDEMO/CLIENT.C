/*
	@(#)slbload/client.c
	
	Julian F. Reschke, 22. September 1998
*/

#include <stdio.h>
#include <tos.h>

typedef void *SLB;
typedef long cdecl (*SLB_EXEC) (SLB *slb, long fn, int params, ...);

long
Slbopen (const char *name, const char *path, long min_ver,
	SLB *sl, SLB_EXEC *fn)
{
	return gemdos (0x16, name, path, min_ver, sl, fn);
}

long
Slbclose (SLB sl)
{
	return gemdos (0x17, sl);
}

int
main (void)
{
	long ret;
	SLB sl;
	SLB_EXEC sx;
	
	ret = Slbopen ("shared.slb", ".", 0, &sl, &sx);
	
	if (ret < 0) {
		fprintf (stderr, "Slbload -> %ld\n", ret);
		return (int) ret;
	}

	ret = sx (sl, 0, (int) (sizeof (char *)) / 2, "Test");

	Slbclose (sl);
	
	return 0;
}
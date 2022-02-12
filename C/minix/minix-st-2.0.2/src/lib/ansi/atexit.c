/* $Header: atexit.c,v 1.1 89/12/18 15:11:09 eck Exp $ */

#include	<stdlib.h>

#define	NEXITS	32

extern void (*__functab[NEXITS])(void);
extern int __funccnt;

int
atexit(void (*func)(void))
{
	if (__funccnt >= NEXITS)
		return 1;
	__functab[__funccnt++] = func;
	return 0;
}

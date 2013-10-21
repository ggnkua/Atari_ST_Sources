/* Test frame new thread safe memory allocation system
 *
 * (c) 2000 by Henk Robbers @ Amsterdam
 *
 */
#define DBG 0
#define TLIB 0
#define FASE1 0

#include <prelude.h>
#include <tos_gem.h>
#include <stdio.h>

#define HOWMANY 5000
#define PREF 50

#if TLIB				/* Profile malloc from standard library */
#include "stdlib.h"
#else

#include "xa_mem.h"

void out(char *txt)
{
	XA_block *this;
	
	printf(txt);
	this = XA_default_base.first;
	if (!this)
		printf("Empty\n");
	else
	while (this)
	{
		XA_unit *at = this->used.first,
		        *fr = this->free.first;
		printf("block %ld, %ld\n", this, this->size);
		while (at)
		{
			printf("    unit  %d: %ld, %ld\n", at->key, at, at->size);
			at = at->next;
		}
		while (fr)
		{
			printf("    free  %d: %ld, %ld\n", fr->key, fr, fr->size);
			fr = fr->next;
		}
		this = this->next;
	}
}
#endif

#if !TLIB
XA_report punit
{
	printf("**** %s: ", txt);
	if (!unit)
	{
		printf("nil\n");
	othw
		XA_unit *prior = unit->prior, *next = unit->next;
		printf("%ld :: %ld, p:%ld :: %ld, n:%ld :: %ld, block %ld :: %ld\n",
			unit, unit->size,
			prior, prior?prior->size:-1,
			next, next?next->size:-1,
			blk, blk->size);
	}
}
#endif

int i;
void *mm[HOWMANY];

int main(void)
{
#if !TLIB
	typedef void *v;
	v m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15;
#if DBG
	long p = Fcreate("memtest.txt", 0);
	Fforce(1,p);
	printf("blockprefix=%ld, unitprefix=%ld\n", blockprefix, unitprefix);
#endif
#if FASE1
	m1 = XA_alloc(nil, 16000, 1, 0);
	m2 = XA_alloc(nil, 100, 2, 0);
	m3 = XA_alloc(nil, 200, 3, 0);
	m4 = XA_alloc(nil, 300, 4, 0);
	m5 = XA_alloc(nil, 500, 5, 0);
	m6 = XA_alloc(nil, 17000, 6, 0);
	m7 = XA_alloc(nil, 600, 7, 0);
	m8 = XA_alloc(nil, 700, 8, 0);
	m9 = XA_alloc(nil, 110, 9, 0);
	m10 = XA_alloc(nil, 120, 10, 0);

	out("\nAfter malloc's\n\n");

	XA_free(nil, m4);
	out("\nAfter freeing m4\n\n");

	XA_free(nil, m3);
	out("\nAfter freeing m3\n\n");

	XA_free(nil, m6);
	out("\nAfter freeing m6\n\n");

	XA_free(nil, m5);
	out("\nAfter freeing m5\n\n");

	XA_free(nil, m9);
	out("\nAfter freeing m9\n\n");

	XA_free(nil, m8);
	out("\nAfter freeing m8\n\n");

	XA_free(nil, m7);
	out("\nAfter freeing m7\n\n");

	XA_free(nil, m2);
	out("\nAfter freeing m2\n\n");

	XA_free(nil, m1);
	out("\nAfter freeing m1\n\n");

	XA_free(nil, m10);
	out("\nAfter freeing m10\n\n");
	XA_free_all(nil,-1,-1);
#endif		/* FASE1 */
#endif		/* TLIB */
	{
		char *q;
		q = malloc(20);
#if 0
		for (i=0; i<HOWMANY; i++)
			mm[i] = malloc(PREF+i%PREF);
#else
		for (i=0; i<HOWMANY; i++)
			mm[i] = 0;
		for (i=0; i<HOWMANY*2; i++)
		{
			int j = Random()%HOWMANY;
			if (!mm[j])
				mm[j]=malloc(PREF+j%PREF);
		}
		for (i = 0; i < HOWMANY; i+=2)		/* Now free half of it. */
			if (mm[i])
			{
				free(mm[i]);
				mm[i] = 0;
			}
		for (i=0; i<HOWMANY*2; i++)			/* Fill it up again. */
		{
			int j = Random()%HOWMANY;
			if (!mm[j])
				mm[j]=malloc(PREF+j%PREF);
		}
#endif
#if !TLIB && DBG
	XA_sanity(nil,punit);
#endif

		for (i=0; i<HOWMANY; i++)
			if (mm[i])
				free(mm[i]);
		free(q);
	}
#if DBG && !TLIB
	printf("\nLeak check\n\n");
	if (XA_leaked(nil, -1,-1, punit))
		printf("Leaks detected!!\n");
	Fclose(p);
#endif
	return 0;
}
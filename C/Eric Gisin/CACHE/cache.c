/*
 * Floppy Disk Cache (Atari ST)
 *
 * Copyright 1988, Eric Gisin <egisin@UWaterloo.CA>
 * this program may be copied as long as this copyright notice is retained.
 * the author will not be liable for any damages resulting from the use of this program.
 *
 * Usage: cache [drive][size]
 *	can be loaded twice to handle two drives.
 *
 * The cache is based on paging and page replacement techniques
 * used in virtual memory systems. The replacement algorithm is
 * similiar to "not frequently used" (NFU).
 *
 * each sector of the disk has a (struct) Cache element
 * that contains a pointer to a cache buffer,
 * and an "average usage" value.  The average is a combination
 * of long term usage and short term usage (somethink like 4bsd's load avg).
 * there are also averages for total IO, read, write, hits, and reclaims.
 * an average is increased for each reference (read/write),
 * and all averages are decreased (by a percentage) every 100 accesses.
 * the reference function is:	avg += A_INC;	A_INC = 16;
 * the update function is:	avg -= 1/8*avg;
 * for these parameters, the total avg will tend between 12800 and 14400.
 */

#include <osbind.h>
#include "cache.h"

/* cache.c can compile with DLIBS or MWC */
#ifndef	MWC
#define	DLIBS
#endif

#ifdef MJC
#define	ASM	1	/* inline assembler */
#endif

#define	reg	register

#ifdef OK
typedef	long (*Func)();		/* function returning long */
#else
typedef	char *	Func;		/* good enough */
#endif

/* define system variables */
#define	bios_rw	(*(Func*)0x000476)	/* bios read/write routine */
#define	bios_mc	(*(Func*)0x00047E)	/* bios media change routine */

#ifdef OK
Func	old_rw;
Func	cur_mc;
#else
long	(*old_rw)();		/* previous rwabs routine */
long	(*cur_mc)();		/* current mediach routine */
#endif

/* per-device data */
int	c_dev = 0;		/* cached device, A: */
int	disable;		/* flag to disable */
short	stats [STATS];		/* global averages */
Cache	cache [NSECT];		/* per sector averages and cbufs indices */
short	csize;			/* size of cache in sectors */
Sector*	cbufs;			/* cached sector buffers */
short	cycle;			/* count from 100 to 0 */
short	nfree;			/* next free cache sector */

#ifdef DLIBS

extern char *_base, *_break;	/* program basepage, heap break */
long	_STKSIZ = -2L;		/* grab all free memory for heap */

#else	/* MWC */

#include <basepage.h>
#define	_base	((char *)BP)
#define	_break	_stack		/* MWC combines _STKSIZ and _break as _stack */
char   *_break = (char *)300*1024L; /* grab 300K for heap */

#endif

char	header [] = "ST Floppy Disk Cache (by Eric Gisin)\r\n";

/*
 * setup bios disk IO routines, terminate and stay resident.
 */
main(argc, argv)
	int argc;
	char **argv;
{
	long stack;
	extern long cache_rw();
	extern char *sbrk(/*size_t n*/);

	Cconws(header);

	if (argc > 1) {
		char *arg = argv[1];
		if ('a' <= *arg && *arg <= 'z')
			c_dev = *arg++ - 'a';
		if ('A' <= *arg && *arg <= 'Z')
			c_dev = *arg++ - 'A';
		csize = atoi(arg) * 1024/sizeof(Sector);
	}
	if (csize < 100)
		csize = 100;		/* 50K is minimum */

#ifndef DEBUG
	if (Rwabs(CSTAT, (char*)NULL, 0, 0, c_dev) != NULL) { /* already loaded */
		Cconws("Cache already loaded\r\n");
		return 0;
	}
#endif

#if 0
	cbufs = (Sector*) sbrk(csize * sizeof(Sector));
#else				/* avoid loading long multiply */
	cbufs = (Sector*) sbrk((size_t)&((Sector*)NULL)[csize]);
#endif
	if (cbufs == NULL) {
		Cconws("Not enough memory\r\n");
		Pterm(-1);
	}

	/* set up our routines for bios rwabs */
	stack = Super(NULL);		/* super mode */
	old_rw = bios_rw;
	bios_rw = cache_rw;
	cur_mc = bios_mc;
	Super(stack);			/* user mode */

	cache_init();

	Ptermres(_break - _base, 0);	/* terminate, stay resident */
}

/* clear the cache */
cache_init()
{
  reg	int	i;

	cycle = CYCLE;
	nfree = 0;
	for (i = 0; i < STATS; i ++)
		stats[i] = 0;
	for (i = 0; i < NSECT; i ++) {
		cache[i].avg = 0;
		cache[i].buf = NOBUF;
	}
	return 0;
}

/* our BIOS rwabs routine */
long
cache_rw(func, addr, count, sect, dev)
	int	func;		/* IO function */
	Sector*	addr;		/* buffer address */
	int	count;		/* sector count */
	int	sect;		/* sector number */
	int	dev;		/* disk drive */
{
  reg	int	s;
  reg	int	i;
	int	n;
	long	l;

	if (dev != c_dev || disable)
		return (*old_rw)(func, addr, count, sect, dev);

	/* recognize magic function for cstat */
	if (func == CSTAT)
		return (sect==0) ? stats : cache;

	if (func == CINIT)
		return cache_init();

	/* check for media change */
	/* floppy rwabs will return -14 if real media change */
	if ((*cur_mc)(dev) != 0) {
		l = (*old_rw)(0, 0xFC0000, 0, 0, dev);	/* dummy read */
		if (l != 0) {
			cache_init();
			return l;	/* always -14 (media changed)? */
		}
	}

	if (sect < 0 || count < 0 || sect+count < 0)
		return -5;		/* sector out of range */

	/* update cache averages */
	for (i = 0; i < count; i ++) {
		s = sect + i;
		stats[TOTAL] += A_INC;
		stats[((func&1)==0) ? READS : WRITES] += A_INC;
		if (s < NSECT)
			cache[s].avg += A_INC;
		if (-- cycle < 0) {
			cycle = CYCLE;
			update_averages();
		}
	}

	/* copy cache to read buffer */
	if ((func&1)==0 && sect>0) {
	    for (i = 0; i < count; i ++) {
		s = sect + i;
		n = cache[s].buf;
		if (n == NOBUF)
			break;
		copy_sector(&cbufs[n], addr++);
		stats[HITS] += A_INC;
	    }
	    sect += i;	count -= i;
	}

	/* do BIOS IO */
	l = (*old_rw)(func, addr, count, sect, dev);
	if (l != 0)
		return l;

	/* update cache from IO buffer */
	for (i = 0; i < count; i ++) {
		s = sect + i;
		n = cache[s].buf;
		if (n == NOBUF)
			get_free(s);
		n = cache[s].buf;
		if (n != NOBUF)
			copy_sector(addr + i, &cbufs[n]);
	}

	return 0;
}

/*
 * update averages.
 * this is called once per N accesses.
 */
update_averages()
{
  reg	int	i;
	int	n;

	for (i = 0; i < STATS; ++ i) {
		stats[i] -= stats[i]+7 >> 3;
	}

	for (i = 0; i < NSECT; ++ i) {
		cache[i].avg -= cache[i].avg+7 >> 3;
		n = cache[i].buf;
		if (!(n == NOBUF || 0<=n && n<csize)) {
			disable = 1;
			Cconws("<cache: internal error>");
		}
	}
}

/*
 * get cache block with lowest avg less than requested block.
 * somewhat inefficient, but should not be called often.
 */
get_free(c)
	int	c;			/* sector */
{
  reg	int	s;
  reg	Cache *	p;
  reg	Cache *	m;

	if (nfree < csize) {
		cache[c].buf = nfree++;
		return;
	}

	/* find sector with a buffer and lowest avg */
	p = &cache[0];
	m = &cache[c];
	for (s = 0; s < NSECT; s ++, p ++)
		if (p->buf != NOBUF && p->avg <= m->avg)
			m = p;

	/* if that sector has lower avg than requested sector, reclaim */
	if (m->avg < cache[c].avg) {
		cache[c].buf = m->buf;
		m->buf = NOBUF;
		stats[RECLMS] += A_INC;
	}
}

copy_sector(s, d)
	Sector *s;
	Sector *d;
{
	int	i;
  reg	char   *dp = d->data;	/* A5 in MJC */
  reg	char   *sp = s->data;	/* A4 in MJC */

	if ((s&1) | (d&1)) {	/* odd address! */
		i = sizeof(Sector);
		while (--i >= 0)
			*dp++ = *sp++;
	} else {
#ifndef	ASM
		/* usually generates loop: move.w (A0)+, (A1)+; dbra D0, loop */
		*d = *s;
#else
		/* this is twice as fast as above */
		sizeof(Sector)/sizeof(long)/4 - 1;	/* result to D0 */
		/* isn't machine language fun!	  loop: */
		asm(= 10972);			/* move.l (A4)+, (A5)+ */
		asm(= 10972);			/* move.l (A4)+, (A5)+ */
		asm(= 10972);			/* move.l (A4)+, (A5)+ */
		asm(= 10972);			/* move.l (A4)+, (A5)+ */
		asm(= 20936 = -10);		/* dbra D0, loop */
#endif
	}
}

/* allocate n bytes from heap (stack segment). NULL on error */
char *sbrk(n)
	size_t n;
{
	extern char *_break;		/* current heap break */
	char *p = _break;
	int dummy;			/* &dummy is almost SP */

	_break += n;
	if (_break+256 > (char*)&dummy) {
		_break = p;
		return NULL;
	}
	return p;
}

#if 0
int brk(p)
	char *p;			/* new break address */
{
	int dummy;			/* &dummy is almost SP */
	extern char *_break;		/* current break address */
	extern char *end;		/* initial _break; */

	if (p < end || p+256 > (char *)&dummy)
		return -1;
	_break = p;
	return 0;
}
#endif

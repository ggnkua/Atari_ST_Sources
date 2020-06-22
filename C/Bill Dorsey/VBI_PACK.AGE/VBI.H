/* vbi.h -- vertical blank interrupt handler [Version 1.0  01/01/87]
 *
 * Copyright (C) 1987 by Amgem, Inc.
 *
 * Permission is hereby granted for anyone to make or distribute copies of
 * this program provided the copyright notice and this permission notice are
 * retained.
 *
 * This software, or software containing all or part of it, may not be sold
 * except with express permission of the authors.
 *
 * Authors:  Bill Dorsey & John Iarocci
 *
 * If you have any questions or comments, the authors may be reached at
 * The Tanj BBS, (301)-251-0675.  Updates and bug fixes may also be obtained
 * through the above service.
 *
 * The code which follows was compiled using the Mark Williams C compiler,
 * but should be portable with little work to other C compilers.  See the
 * associated documentation for notes on how to convert it for use with other
 * C compilers
 */

/* operating system variables */
#define	VBLSEM		((int *) 0x452L)
#define VBLQUEUE	((int (***)()) 0x456L)
#define PSG		((char *) 0xff8800L)
#define PSG2		((char *) 0xff8802L)
#define GPIP		((char *) 0xfffa01L)

/* process states */
#define	FREE		0
#define READY		1
#define SLEEP		2

/* return values */
#define OK		(-1)
#define SYSERR		(-2)

/* system values */
#define TICKSPERSEC	70	/* 70 for MONO, 50 for RGB */
#define QUANTUM		5	/* should be a factor of tickspersec */
#define INTERVAL	(TICKSPERSEC/QUANTUM)
#define NPROC		8	/* maximum number of processes */

/* misc macros */
#define DISABLE		*VBLSEM=0
#define ENABLE		*VBLSEM=1

typedef struct {
  int state;
  int (*func)();
  int count;
} PROC;

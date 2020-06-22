/* vbishell.c -- vertical blank interrupt handler shell
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

#include <osbind.h>
#include "vbi.h"

extern PROC proctab[NPROC];

main()
{
  int pid1,pid2;
  long i;
  int process1(),process2();

  if (init() == SYSERR) {
    printf("Installation failure\n");
    exit(1);
  }

  if ((pid1=create(process1)) == SYSERR)	/* create process 1 */
    printf("Could not create process 1\n");
  if ((pid2=create(process2)) == SYSERR)	/* create process 2 */
    printf("Could not create process 2\n");
  printf("Now entering loop...\n");
  for (i=0; i<2000000L; i++)			/* delay for a while */
    ;
  if (delete(pid1) == SYSERR)			/* delete process 1 */
    printf("Could not delete process 1\n");
  if (delete(pid2) == SYSERR)			/* delete process 2 */
    printf("Could not delete process 2\n");
  if (remove() == SYSERR)			/* remove VBI handler */
    printf("Could not remove VBI handler\n");
  exit(0);					/* return to OS */
}

int process1()
{
  Bconout(2,'A');			/* output 'A' to console */
  sleep(4);				/* 4 seconds until next call */
}

int process2()
{
  Bconout(2,'B');			/* output 'B' to console */
  sleep(5);				/* 5 seconds until next call */
}

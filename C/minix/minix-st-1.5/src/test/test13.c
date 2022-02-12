/* test 13 */

/* File: pipes.c - created by Marty Leisner */
/* Leisner.Henr         1-Dec-87  8:55:04 */

/* Copyright (C) 1987 by Martin Leisner. All rights reserved. */
/* Used by permission. */

#include <stdio.h>

#define BLOCK_SIZE 	1000
#define NUM_BLOCKS	1000
char buffer[BLOCK_SIZE];

main()
{
  int pipefd[2];
  register int i;
  pipe(pipefd);

  printf("Test 13 ");
  fflush(stdout);		/* have to flush for child's benefit */

  pipe(pipefd);

  switch (fork()) {
      case 0:
	/* Child code */
	for (i = 0; i < NUM_BLOCKS; i++)
		if (read(pipefd[0], buffer, BLOCK_SIZE) != BLOCK_SIZE) break;
	;
	exit();
	break;
      case -1:
	perror("fork broke");
	exit();
      default:
	/* Parent code */
	for (i = 0; i < NUM_BLOCKS; i++)
		write(pipefd[1], buffer, BLOCK_SIZE);

	wait((char *) 0);
	break;
  }
  printf("ok\n");
}

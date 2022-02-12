/* test 12 */

/* Copyright (C) 1987 by Martin Leisner. All rights reserved. */
/* Used by permission. */

#include <stdio.h>

#define NUM_TIMES	1000
main()
{
  register int i;
  int k;

  printf("Test 12 ");
  fflush(stdout);		/* have to flush for child's benefit */

  for (i = 0; i < NUM_TIMES; i++) switch (fork()) {
	    case 0:	exit();	  		break;
	    case -1:
		printf("fork broke\n");
		exit();
	    default:	wait(&k);	  		break;
	}

  printf("ok\n");
}

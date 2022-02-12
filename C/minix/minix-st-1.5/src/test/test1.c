/* test 1 */

#include <signal.h>
#include <stdio.h>

#define SIGNUM 10
#define MAX_ERROR 4

int glov, gct;
extern int errno;
int errct;
int subtest = 1;

main()
{
  int i;

  printf("Test  1 ");
  fflush(stdout);		/* have to flush for child's benefit */

  for (i = 0; i < 15; i++) {
	test10();
	test11();
  }
  if (errct == 0)
	printf("ok\n");
  else
	printf(" %d errors\n", errct);
  exit(0);
}

test10()
{
  int i, n, pid;

  n = 4;
  for (i = 0; i < n; i++) {
	if ((pid = fork())) {
		if (pid < 0) {
			printf("\nTest 1 fork failed\n");
			exit(1);
		}
		parent();
	} else
		child(i);
  }
}

parent()
{

  int n;

  n = getpid();
  wait(&n);
}

child(i)
int i;
{
  int n;

  n = getpid();
  exit(i);
}

test11()
{
  int i, k, func();

  for (i = 0; i < 4; i++) {
	glov = 0;
	signal(SIGNUM, func);
	if ((k = fork())) {
		if (k < 0) {
			printf("Test 1 fork failed\n");
			exit(1);
		}
		parent1(k);
	} else
		child1(k);
  }
}


parent1(childpid)
int childpid;
{

  int n;

  for (n = 0; n < 5000; n++);
  while (kill(childpid, SIGNUM) < 0)	/* null statement */
	;
  wait(&n);
}

func()
{
  glov++;
  gct++;
}

child1(k)
int k;
{
  while (glov == 0);
  exit(gct);
}



e(n)
int n;
{
  int err_num = errno;		/* save errno in case printf clobbers it */

  printf("Subtest %d,  error %d  errno=%d  ", subtest, n, errno);
  errno = err_num;		/* restore errno, just in case */
  perror("");
  if (errct++ > MAX_ERROR) {
	printf("Too many errors; test aborted\n");
	exit(1);
  }
}

/* test 4 */

#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int pid0, pid1, pid2, pid3, s;
int i, fd;
int nextb;
char *tempfile = "test4.temp";
char buf[1024];

main()
{
  int k;

  creat(tempfile, 0777);
  printf("Test  4 ");
  fflush(stdout);		/* have to flush for child's benefit */

  for (k = 0; k < 20; k++) {
	subr();
  }
  printf("ok\n");
  unlink(tempfile);
}


subr()
{
  if (pid0 = fork()) {
	/* Parent 0 */
	if (pid0 < 0) nofork();
	if (pid1 = fork()) {
		/* Parent 1 */
		if (pid1 < 0) nofork();
		if (pid2 = fork()) {
			/* Parent 2 */
			if (pid2 < 0) nofork();
			if (pid3 = fork()) {
				/* Parent 3 */
				if (pid3 < 0) nofork();
				for (i = 0; i < 10000; i++);
				kill(pid2, 9);
				kill(pid1, 9);
				kill(pid0, 9);
				wait(&s);
				wait(&s);
				wait(&s);
				wait(&s);
			} else {
				fd = open(tempfile, O_RDONLY);
				lseek(fd, 20480L * nextb, 0);
				for (i = 0; i < 10; i++) read(fd, buf, 1024);
				nextb++;
				close(fd);
				exit(0);
			}
		} else {
			while (1) getpid();
		}
	} else {
		while (1) getpid();
	}
  } else {
	while (1) getpid();
  }
}

nofork()
{
  printf("Fork failed.  Not enough memory.\n");
  exit(1);
}

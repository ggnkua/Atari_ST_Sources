/* rmdir - remove a directory		Author: Bruce Evans */

#include <minix/minlib.h>
#include <sys/types.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

_PROTOTYPE(int main, (int argc, char **argv));

int main(argc, argv)
int argc;
char **argv;
{
  int error;
  char *prog_name;
  int save_errno;

  prog_name = argv[0];
  if (argc < 2) {
	std_err("Usage: ");
	std_err(prog_name);
	std_err(" dir...\n");
	exit(1);
  }
  error = 0;
  while (--argc != 0) {
	if (rmdir(*++argv) != 0) {
		save_errno = errno;
		std_err(prog_name);
		std_err(": ");
		errno = save_errno;
		perror(*argv);
		error = 1;
	}
  }
  return(error);
}

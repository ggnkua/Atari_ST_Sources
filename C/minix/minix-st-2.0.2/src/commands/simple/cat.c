/* cat - concatenates files  		Author: Andy Tanenbaum */

/* 30 March 90 - Slightly modified for efficiency by Norbert Schlenker. */


#include <errno.h>
#include <sys/types.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <minix/minlib.h>
#include <stdio.h>

#define CHUNK_SIZE	4096

static int unbuffered;
static char ibuf[CHUNK_SIZE];
static char obuf[CHUNK_SIZE];
static char *op = obuf;

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void copyfile, (int ifd, int ofd));
_PROTOTYPE(void flush, (void));
_PROTOTYPE(void fatal, (void));

int excode = 0;

int main(argc, argv)
int argc;
char *argv[];
{
  int i, fd;

  i = 1;
  /* Check for the -u flag -- unbuffered operation. */
  if (argc >= 2 && argv[1][0] == '-' && argv[1][1] == 'u' && argv[1][2] == 0) {
	unbuffered = 1;
	i = 2;
  }
  if (i >= argc) {
	copyfile(STDIN_FILENO, STDOUT_FILENO);
  } else {
	for ( ; i < argc; i++) {
		if (argv[i][0] == '-' && argv[i][1] == 0) {
			copyfile(STDIN_FILENO, STDOUT_FILENO);
		} else {
			fd = open(argv[i], O_RDONLY);
			if (fd < 0) {
				std_err("cat: cannot open ");
				std_err(argv[i]);
				std_err(": ");
				std_err(strerror (errno));
				std_err("\n");
				excode = 1;
			} else {
				copyfile(fd, STDOUT_FILENO);
				close(fd);
			}
		}
	}
  }
  flush();
  return(excode);
}

void copyfile(ifd, ofd)
int ifd, ofd;
{
  int n;

  while (1) {
	n = read(ifd, ibuf, CHUNK_SIZE);
	if (n < 0) fatal();
	if (n == 0) return;
	if (unbuffered || (op == obuf && n == CHUNK_SIZE)) {
		if (write(ofd, ibuf, n) != n) fatal();
	} else {
		int bytes_left;

		bytes_left = &obuf[CHUNK_SIZE] - op;
		if (n <= bytes_left) {
			memcpy(op, ibuf, (size_t)n);
			op += n;
		} else {
			memcpy(op, ibuf, (size_t)bytes_left);
			if (write(ofd, obuf, CHUNK_SIZE) != CHUNK_SIZE)
				fatal();
			n -= bytes_left;
			memcpy(obuf, ibuf + bytes_left, (size_t)n);
			op = obuf + n;
		}
	}
  }
}

void flush()
{
  if (op != obuf)
	if (write(STDOUT_FILENO, obuf, (size_t) (op - obuf)) <= 0) fatal();
}

void fatal()
{
  perror("cat");
  exit(1);
}

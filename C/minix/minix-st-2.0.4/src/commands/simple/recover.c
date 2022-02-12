/* recover - un-remove a file		Author: Andy Tanenbaum */

/* Unlike most UNIX systems, MINIX provides a way to recover a file that
 * has been accidently rm'ed.  The recovery is done using Terrence Holm's
 * 'de' (disk editor) program, plus some patches to FS that keep the i-node
 * number in the directory, even after the file has been removed.  A file
 * cannot be recovered after its directory slot has been reused.
 *
 * Usage:
 *	recover file ...
 *
 * Note: the file names must be fully explicit; wild cards are not allowed.
 * It is not possible, for example, to say recover *.c.  All the files must
 * be named in full.  Since the last two bytes of the directory entry are
 * used for the i-node number, only the first 12 characters of the file name
 * count.  Full 14 character file names can be specified, however, only the
 * last two characters, in fact, play no role in locating the file.
 */

#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <sys/wait.h>
#include <minix/minlib.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void recover, (char *file));
_PROTOTYPE(void fatal, (char *file));
_PROTOTYPE(void usage, (void));

int main(argc, argv)
int argc;
char *argv[];
{
  int i;

  if (argc == 1) usage();

  for (i = 1; i < argc; i++) recover(argv[i]);
  return(0);
}

void recover(file)
char *file;
{
  pid_t pid;
  int r, status;

  switch ((pid = fork())) {
  case -1:
	fatal("fork()");
  case 0:
	signal(SIGHUP, SIG_IGN);
	signal(SIGINT, SIG_IGN);
	signal(SIGQUIT, SIG_IGN);
	signal(SIGTERM, SIG_IGN);

	execl("/usr/bin/de", "de", "-r", file, (char *) NULL);
	fatal("/usr/bin/de");
  default:
	while (waitpid(pid, &status, 0) < 0) {
		if (errno != EINTR) fatal("waitpid()");
	}
	if (status != 0) exit(1);
  }
}

void fatal(label)
char *label;
{
  int err= errno;

  std_err("recover: ");
  std_err(label);
  std_err(": ");
  std_err(strerror(err));
  std_err("\n");
  exit(1);
}

void usage()
{
  std_err("Usage: recover file ...\n");
  exit(1);
}

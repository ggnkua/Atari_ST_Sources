/* mount - mount a file system		Author: Andy Tanenbaum */

#include <errno.h>
#include <sys/types.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <minix/minlib.h>
#include <stdio.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void list, (void));
_PROTOTYPE(void usage, (void));
_PROTOTYPE(void tell, (char *this));

int main(argc, argv)
int argc;
char *argv[];
{
  int ro, n, v;
  char *vs;
  char special[PATH_MAX+1], mounted_on[PATH_MAX+1], version[10], rw_flag[10];

  if (argc == 1) list();	/* just list /etc/mtab */
  if (argc < 3 || argc > 4) usage();
  if (argc == 4 && *argv[3] != '-' && *(argv[3] + 1) != 'r') usage();
  ro = (argc == 4 ? 1 : 0);
  if (mount(argv[1], argv[2], ro) < 0) {
	if (errno == EINVAL) {
		std_err("mount: ");
		std_err(argv[1]);
		std_err(" is not a valid file system.\n");
		exit(1);
	}
	if (errno == ENFILE) {
		std_err("mount: not enough internal table space available\n");
		exit(1);
	}
	perror("mount");
	exit(1);
  }

  /* The mount has completed successfully. Tell the user. */
  tell(argv[1]);
  tell(" is read-");
  tell(ro ? "only" : "write");
  tell(" mounted on ");
  tell(argv[2]);
  tell("\n");

  /* Update /etc/mtab. */
  n = load_mtab("mount");
  if (n < 0) exit(1);		/* something is wrong. */

  /* Loop on all the /etc/mtab entries, copying each one to the output buf. */
  while (1) {
	n = get_mtab_entry(special, mounted_on, version, rw_flag);
	if (n < 0) break;
	n = put_mtab_entry(special, mounted_on, version, rw_flag);
	if (n < 0) {
		std_err("mount: /etc/mtab has grown too large\n");
		exit(1);
	}
  }
  v = fsversion(argv[1], "mount");
  if (v == 1)
	vs = "1";
  else if (v == 2)
	vs = "2";
  else
	vs = "0";
  n = put_mtab_entry(argv[1], argv[2], vs, (ro ? "ro" : "rw") );
  if (n < 0) {
	std_err("mount: /etc/mtab has grown too large\n");
	exit(1);
  }

  n = rewrite_mtab("mount");
  return(0);
}


void list()
{
  int n;
  char special[PATH_MAX+1], mounted_on[PATH_MAX+1], version[10], rw_flag[10];

  /* Read and print /etc/mtab. */
  n = load_mtab("mount");
  if (n < 0) exit(1);

  while (1) {
	n = get_mtab_entry(special, mounted_on, version, rw_flag);
	if  (n < 0) break;
	write(1, special, strlen(special));
	if (strcmp(mounted_on, "/") == 0) {
		write(1, " is root device\n", 16);
	} else {
		write(1, " is mounted on ", 15);
		write(1, mounted_on, strlen(mounted_on));
		write(1, "\n", 1);
	}
  }
  exit(0);
}


void usage()
{
  std_err("Usage: mount special name [-r]\n");
  exit(1);
}


void tell(this)
char *this;
{
  write(1, this, strlen(this));
}

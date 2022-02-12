/* pathchk - check pathnames		Author: V. Archer */

/* Copyright 1991 by Vincent Archer
 *	You may freely redistribute this software, in source or binary
 *	form, provided that you do not alter this copyright mention in any
 *	way.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <minix/minlib.h>
#include <stdio.h>

/* Global variables. */
char directory[PATH_MAX + 1];
char POSIX_CHAR_SET[] = "\
.#-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_~";

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void perr, (char *name, char *msg));
_PROTOTYPE(void usage, (void));

/* Perror-like function, but with a user supplied message rather than an
 * error one. The standard limits-related messages are not very clear on
 * what is wrong. :-)
 */
void perr(name, msg)
char *name, *msg;
{
  std_err(name);
  std_err(":");
  std_err(msg);
}


/* Main module. Since only one option (-p) is allowed, do not include all
 * the getopt() stuff.
 */
int main(argc, argv)
int argc;
char *argv[];
{
  char *name, *arg;
  int pflag, length, maxl;
  int rtstat = 0;
  uid_t uid;
  gid_t gid;
  mode_t mask;
  struct stat perms;
  int Maxname;

  argc--;
  argv++;
  if (argc && !strcmp(*argv, "-p")) {
	argc--;
	argv++;
	pflag = 1;
  } else
	pflag = 0;
  uid = getuid();
  gid = getgid();

  if (!argc) usage();

  while (argc--) {
	arg = *argv++;
#if PATH_MAX != _POSIX_PATH_MAX
	if (pflag) {
		if (strlen(arg) > _POSIX_PATH_MAX) {
			perr(arg, "pathname too long for Posix\n");
			rtstat = 1;
			continue;
		}
	} else
#endif
	if (strlen(arg) > PATH_MAX) {
		perr(arg, "pathname too long\n");
		rtstat = 1;
		continue;
	}
	length = 0;
	maxl = 0;
	directory[0] = '.';
	directory[1] = '\0';
	if (pflag) {
		Maxname = _POSIX_NAME_MAX;
	} else
		Maxname = pathconf(directory, _PC_NAME_MAX);

	for (name = arg; *name; name++) {
		if (*name == '/') {
			if (length > Maxname) break;
/* I do not allow a//b (empty component). Too ugly. */
			if (length == 0 && maxl) {
				perr(arg, "empty component\n");
				rtstat = 1;
				break;
			}
			length = 0;

			if (!pflag && directory[0]) {
				if (maxl == 0) {
					directory[0] = '/';
					directory[1] = '\0';
				} else {
					strncpy(directory, arg, (size_t) maxl);
					directory[maxl] = '\0';
				}

				if (stat(directory, &perms) == 0) {
					Maxname = pathconf(directory, _PC_NAME_MAX);
					if (uid) {
						if (uid == perms.st_uid)
							mask = S_IXUSR;
						else if (gid == perms.st_gid)
							mask = S_IXGRP;
						else
							mask = S_IXOTH;
						if (!(mask & perms.st_mode)) {
							perr(arg, "not searchable\n");
							rtstat = 1;
							break;
						}
					}
				} else
					directory[0] = '\0';
			}
		} else {
			if (!strchr(POSIX_CHAR_SET, *name)) {
				perr(arg, "illegal character\n");
				rtstat = 1;
				name = "";
				length = 0;	/* do not print 2 msgs */
				break;
			}
			length++;
		}
		maxl++;
	}
	if (length > Maxname) {
		perr(arg, pflag ? "component name too long for Posix\n"
		     : "component name too long\n");
		rtstat = 1;
	}
  }
  return(rtstat);
}


/* Posix command prototype. */
void usage()
{
  std_err("Usage: pathchk [-p] file...\n");
  exit(1);
}

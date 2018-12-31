/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "tune.h"
#include "paths.h"
#include <stdio.h>
#include <string.h>

#ifdef REALSTDC
# include <stdlib.h>
# define proto(x)        x
#else
# define proto(x)		()
extern char	*getenv proto((const char *));
#endif

/* A couple of bits stolen from externs.h: */

extern int	access proto((const char */*path*/, int /*mode*/));
#ifndef W_OK
#   define W_OK	2
#   define F_OK	0
#endif

# if !defined(ZTCDOS) && !defined(__BORLANDC__)
/* Zortech incorrectly defines argv as const char **.
 * Borland incorrectly defines argv as char *[] and omits some consts
 * on execl and execlp parameters.
 * On the other hand, each supplies declarations for these functions.
 */
extern int	execlp proto((const char */*file*/, const char */*arg*/, ...));
# endif


static char	ShareDir[FILESIZE] = SHAREDIR;

#ifdef MINT
/* extern char *fixpath();*/
extern int __default_mode__;
/* long _stksize = 20000L; */
#endif

int
main(argc, argv)
int	argc;
char	*argv[];
{
	char
		cmd[FILESIZE*3],
		fname[FILESIZE],
		*home,
		teachjove[FILESIZE];

#ifdef MINT
	__default_mode__ |= _IOBIN;
#endif

	if (argc == 3 && strcmp(argv[1], "-s") == 0) {
		if (strlen(argv[2]) >= FILESIZE*sizeof(char)) {
			printf("teachjove: -s argument too long\n");
			exit(-1);
		}
		strcpy(ShareDir, argv[2]);
	} else if (argc != 1) {
		printf("Usage: teachjove [-s sharedir]\n");
		exit(-1);
	}
	/* ??? "teach-jove" is too long for MSDOS */
	(void) sprintf(teachjove, "%s/teach-jove", ShareDir);
	if ((home = getenv("HOME")) == NULL) {
		printf("teachjove: cannot find your home!\n");
		exit(-1);
	}
	/* ??? "teach-jove" is too long for MSDOS */
	(void) sprintf(fname, "%s/teach-jove", home);
	if (access(fname, F_OK) != 0) {
		(void) sprintf(cmd, "cp %s %s; chmod 644 %s", teachjove, fname, fname);
		system(cmd);
	}
	(void) execlp("jove", "teachjove", fname, (char *) NULL);
	printf("teachjove: cannot execl jove!\n");
	return 1;
}

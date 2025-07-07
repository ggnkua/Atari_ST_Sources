/*
 * runtos: a small program that will launch a TOS or TTP program
 * in a TOSWIN window.
 *
#ifdef WWA_EXT_TOSRUN
 * Invokes TOSWIN_W (from $PATH) if the TOSRUN pipe cannot be found.
 *   (WWA_RUN_TOSWIN)
#endif
 *
 * To compile:
 *     gcc -O -mshort -o runtos.prg runtos.c -lgem16
 * To run:
 *     runtos someprog.tos arg1 arg2 arg3
 *
#ifdef WWA_EXT_TOSRUN
 *
 * OR  runtos -w x y w h someprog.tos arg1 arg2 arg3            (WWA_WIN_RUN)
 * OR  runtos -f fontname fontsize someprog.tos arg1 arg2 arg3  (WWA_FONT_RUN)
 * OR  runtos -g someprog.prg arg1 arg2 arg3                    (WWA_GEM_RUN)
 *
 * -w and -f can be used at same time, but no use with -g.
 *
#endif
 *
 * OR
 *     Using the desktop, do an "Install Application" on runtos.prg.
 *     For "document type", use .TOS. Now, double clicking on a TOS
 *     program will automatically start it up in a TOSWIN window.
 *     (unfortunately, it will also cause all TOSWIN windows to be
 *     hidden -- you'll have to select "TOS programs" from the DESK
 *     menu to get them back again).
 * BUGS
 *     See above. Also, it would be nice to have a "runttp.prg"
 *     that would prompt for .TTP arguments. This is left as an
 *     exercise for the interested reader.
 *
 * "runtos" was written by Eric R. Smith and is hereby placed in
 * the public domain.
 *
 * Thw WWA_* extensions were written by Warwick W. Allison and
 * are also hereby placed in the public domain.
 */

#ifdef WWA_EXT_TOSRUN
#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include <mintbind.h>
#include <stdlib.h>
#include <support.h>
#include <unistd.h>
#else
#include <minimal.h>
#endif

long _stksize = 2*1024;

int
main(int argc, char **argv)
{
/* BUG: shouldn't have a fixed size buffer */
	static char buf[1024];
#ifdef WWA_EXT_TOSRUN
#ifdef WWA_GEM_RUN
	static char prg[128];
#endif
#endif
	char *where = buf;
	int i, fd;
	long r;
	int options=1;

	if (!argv[1]) return 2;

#ifdef WWA_EXT_TOSRUN
	while (argv[1][0]=='-' && options) {
		switch (argv[1][1]) {
		 default:
			options=0;
#ifdef WWA_GEM_RUN
		break; case 'g':
			*where++ = '\01';
			argv++;
#endif
#ifdef WWA_WIN_RUN
		break; case 'w':
			if (argv[2] && argv[3] && argv[4] && argv[5]) {
				int x=atoi(argv[2]);
				int y=atoi(argv[3]);
				int w=atoi(argv[4]);
				int h=atoi(argv[5]);

				if (w && h) {
					where += sprintf(where,"\002%d %d %d %d ",x,y,w,h);
				}

				argv+=5;
			} else {
				options=0;
			}
#endif
#ifdef WWA_FONT_RUN
		break; case 'f':
			if (argv[2] && argv[3]) {
				int fontsize=atoi(argv[3]);
				if (fontsize) {
					where += sprintf(where,"\003%s@%d ",argv[2],fontsize);
				}
				argv+=3;
			} else {
				options=0;
			}
#endif
		}
	}
#endif

/* first, put the path */
	*where++ = Dgetdrv() + 'A';
	*where++ = ':';
	Dgetpath(where, 0);
	if (!*where) *where = '\\';
	strcat(where, " ");

#ifdef WWA_EXT_TOSRUN
/* WWA - previously, no conversion was done.  However, TOSWIN assumes DOS */
/* next, put the program (in TOS format) */
#ifdef WWA_UNIX_RUN
	if (unx2dos(argv[1],prg)) {
		strcat(where, argv[1]);
	} else
#endif
#endif
		strcat(where, prg);

/* finally, put the arguments */
	for (i = 2; argv[i]; i++) {
		strcat(where, " ");
		strcat(where, argv[i]);
	}

#ifdef WWA_RUN_TOSWIN
	fd = Fopen("U:\\PIPE\\TOSRUN", 2);

	if (fd < 0) {
		/* Failed - try running TOSWIN */
		char* ext[3]={"PRG","APP",0};
		char* path=getenv("PATH");
		char* filename=findfile("TOSWIN_W",path ? path : ".,\\bin",ext);
		if (!filename) filename=findfile("TOSWIN",path ? path : ".,\\bin",ext);
		if (!filename) return 1;

		unx2dos(filename,prg);

		if (Pexec(PE_ASYNC_LOADGO,prg,"",0)<0
		  && Pexec(PE_ASYNC_LOADGO,prg,"",0)<0) return 1;

		/* Give it a fleeting chance of getting up */
		Syield();

		/* Retry 5 times to connect to pipe, wait 1 second each time */
		for (i=0; fd<0 && i<5; i++) {
			fd = Fopen("U:\\PIPE\\TOSRUN", 2);
			if (fd < 0) sleep(1);
		}
	}
#else
	if (fd < 0) return 1;
#endif

	r = strlen(buf) + 1;

	if (Fwrite(fd, r, buf) != r)
		return 1;

	return 0;
}

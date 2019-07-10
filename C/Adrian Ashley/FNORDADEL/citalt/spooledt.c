/*
 * spooledt.c -- edit citadel spoolfiles
 */

#include "ctdl.h"
#include "config.h"

#ifdef ATARIST
#include <osbind.h>
#define	pexec	Pexec
#endif
#ifdef MSDOS
long far pexec(int, char far *, char far *, char far *);
#endif

extern struct config cfg;
extern int netfl;

char *program = "spooledt";

main(argc, argv)
char **argv;
{
    char editor[128];
    char edittail[128];
    char temp[128];
    char *p, *getenv();
    int nodeloc;
    long status;

    if (argc != 2) {
	fprintf(stderr, "usage: %s nodename\n", program);
	exit(1);
    }
    if (readSysTab(NO)) {
	ctdlfile(temp, cfg.netdir, "ctdlnet.sys");
	if ((netfl=dopen(temp, O_RDWR)) < 0)
	    crashout("cannot open %s", temp);
	nodeloc = netnmidx(argv[1]);
	if (nodeloc == ERROR)
	    crashout("no node %s", argv[1]);
	ctdlfile(&edittail[1], cfg.netdir, "%d.nfs", nodeloc);
	edittail[0] = strlen(&edittail[1]);

	if ((p=getenv("EDITOR")) == NULL) {
#ifdef ATARIST
	    ctdlfile(editor, cfg.sysdir, "editor.prg");
#endif
#ifdef MSDOS
	    ctdlfile(editor, cfg.sysdir, "editor.exe");
#endif
	    p = editor;
	}
	if ((status=pexec(0, p, edittail, 0L)) < 0)
	    crashout("editor <%s> returns status %d", p, (int)(status));
    }
}

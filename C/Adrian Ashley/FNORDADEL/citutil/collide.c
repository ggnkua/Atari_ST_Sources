/*
 * collide -- see hash collisions.
 */

#include "ctdl.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

int logfl;				/* log file descriptor		*/
char *program = "collide";

void
check(name)
char *name;
{
    int j, h, count;

    h = hash(name);
    for (count=j=0; j<cfg.logsize; j++)
	if (logTab[j].ltnmhash == h) {
	    getlog(&logBuf, logTab[j].ltlogSlot, logfl);
	    printf("hash(%s) -> %s\n", name, logBuf.lbname);
	    count++;
	}
    if (count == 0)
	printf("%s not matched\n", name);
}

main(argc,argv)
int  argc;
char **argv;
{
    int i;
    PATHBUF fn;
    char name[80];
    extern char VERSION[];

    printf("%s for Fnordadel V%s\n", program, VERSION);
    
    if (readSysTab(FALSE)) {

	initlogBuf(&logBuf);

	ctdlfile(fn, cfg.sysdir, "ctdllog.sys");
	if ((logfl = dopen(fn, O_RDONLY)) < 0)
	    crashout("Can't open %s", fn);

	if (argc > 1)
	    for (i=1; i<argc; i++)
		check(argv[i]);
	else
	    while (1) {
		printf("name> ");gets(name);
		if (strlen(name) < 1)
		    break;
		check(name);
	    }
	dclose(fn);

	killlogBuf(&logBuf);
    }
    if (fromdesk())
	hitkey();
}

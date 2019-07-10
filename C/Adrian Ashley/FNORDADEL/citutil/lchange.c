/*
 * lchange.c -- change the # of entries in the citadel log
 *
 * 88Jan03 orc	Modified to allow expansion of the userlog
 * 87Dec31 orc	Created
 */

#include "ctdl.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

int oldlog, newlog, newlogsize, oldlogsize;
char *program = "lchange";

/* Get a yes/no response from console */
int
getyesno(void)
{
    int c;

    while (1) {
	c = toupper(getch());
	if (c == 'Y' || c == 'N')
	    break;
    }
    putchar(c);
    putchar('\n');
    if (c == 'N')
	return NO;
    else
	return YES;
}

int
main(int argc, char **argv)
{
    int i, p;
    PATHBUF logfile;
    PATHBUF newfile;

    setbuf(stdout, NULL);
    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (argc == 2)
	newlogsize = atoi(argv[1]);
    else {
	fprintf(stderr,"usage: %s <new log size>\n", program);
	if (fromdesk())
	    hitkey();
	exit(1);
    }

    if ((newlogsize > MAXLOGSIZE) || (newlogsize < MINLOGSIZE))
	crashout("new logsize must be between %d and %d", MINLOGSIZE,
		MAXLOGSIZE);
    else if (newlogsize > SANELOGSIZE) {
	printf("Do you really want %d log entries? (y/n) ", newlogsize);
	if (!getyesno())
	    crashout("Okay");
    }
    else if (newlogsize == cfg.logsize)
	crashout("logsize is already %d", newlogsize);

    if (readSysTab(YES) && makelock(&p)) {
	initlogBuf(&logBuf);

	ctdlfile(logfile, cfg.sysdir, "ctdllog.sys");
	ctdlfile(newfile, cfg.sysdir, "ctdllog.new");

	oldlog = dopen(logfile,O_RDONLY);
	if (oldlog < 0) {
	    writeSysTab();
	    wipelock(&p);
	    crashout("cannot open %s", logfile);
	}
	dunlink(newfile);
	newlog = dcreat(newfile);
	if (newlog < 0) {
	    writeSysTab();
	    wipelock(&p);
	    crashout("cannot create %s", newfile);
	}
	oldlogsize = cfg.logsize;
	cfg.logsize = newlogsize;

	if (cfg.logsize > oldlogsize) {
	    logTab = (struct lTable *) realloc(logTab, sizeof(*logTab) * 
		cfg.logsize);
	    if (!logTab) {
		writeSysTab();
		wipelock(&p);
		crashout("out of memory");
	    }
	    for (i = oldlogsize; i < cfg.logsize; i++) {
		logTab[i].ltpwhash =
		logTab[i].ltnmhash = logTab[i].ltnewest = 0;
	    }
	}
	for (i = 0; i < cfg.logsize; i++) {
	    if (i < oldlogsize) {
		getlog(&logBuf, logTab[i].ltlogSlot, oldlog);
		if readbit(logBuf,uINUSE)
		    printf("log %3d: %s\n", i, logBuf.lbname);
	    }
	    else {
		memset(&logBuf, 0, LB_SIZE);
		memset(logBuf.lbgen, 0, GEN_BULK);
		memset(logBuf.lbmail, 0, MAIL_BULK);
		printf("New log %3d\r",i);
	    }
	    putlog(&logBuf, logTab[i].ltlogSlot = i, newlog);
	}
	if (cfg.logsize > oldlogsize)
	    putchar('\n');
	dclose(newlog);
	dclose(oldlog);
	dunlink(logfile);
	drename(newfile,logfile);
	fprintf(stderr, "New log size is %d; \
Don't forget to modify ctdlcnfg.sys!\n", cfg.logsize);
	writeSysTab();
	wipelock(&p);

	killlogBuf(&logBuf);
    }
    if (fromdesk())
	hitkey();
}

/*
 * clog.c -- display information about the Fnordadel userlog.
 * 
 * 90Dec07 AA	Hacked a bit for gcc port
 * 88Nov16 orc	change field order around, clean up option parsing
 * 88Jan30 orc	-t flag for constructing userlists
 * 87Aug16 orc	Some hacks for v3.1
 * 87Mar28 orc	changes for major release.
 * 87Mar02 orc	-a flag put in to find illegal aides.
 * 87Mar01 orc	rewritten for the ST.
 */

#include "ctdl.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

char *program = "clog";
int logfl;
int findnorm = YES;
int passwd = NO;
int tabled = NO;
int showall = NO;
int sorttime = NO;

#define MAXUSERS 100
char *users[MAXUSERS];

int usercount = 0, seen = 0, txp = 0;

static void
showlog(int i)
{
    register int j;

    if (tabled) {
	txp = (1 + txp) % 3;
	printf(txp ? "%-25.25s" : "%s\n", logBuf.lbname);
    }
    else if (findnorm || readbit(logBuf,uAIDE)) {
	seen++;
	printf("%4d%c ",i, readbit(logBuf,uINUSE) ? ':' : '!');
	if (showall) {
	    for (j=0; j < NAMESIZE; j++)
		putchar(isprint(logBuf.lbname[j]) ? logBuf.lbname[j] : '?');
	}
	else
	    printf("%-20.20s", logBuf.lbname);

	if (passwd)
	    printf(" %-20.20s", logBuf.lbpw);
	printf(" %s", makedate(logBuf.lblast, NO));
	if readbit(logBuf,uSYSOP)
	    printf(", Sys");
	else if readbit(logBuf,uAIDE)
	    printf(", Aid");
	if readbit(logBuf,uEXPERT)
	    printf(", Exp");
	if readbit(logBuf,uNETPRIVS)
	    printf(", Net");
	if (!readbit(logBuf,uMAILPRIV))
	    printf(", No-Mail");
	if (!readbit(logBuf,uDOORPRIV))
	    printf(", No-Door");
	if readbit(logBuf,uTWIT)
	    printf(", TWT");
	putchar('\n');
    }
}

int
main(int argc, char **argv)
{
    int i, j, entry;
    char *p;
    int pos;
    PATHBUF fn;
    extern char VERSION[];

#if 0
    setbuf(stdout, NULL);	/* Avoid stdout buffering */
#endif

    printf("%s for Fnordadel V%s\n", program, VERSION);
    
    while (argc > 1) {
	--argc, ++argv;
	p = *argv;
	if (*p == '-') {
	    while (*++p)
		switch (toupper(*p)) {
		case 'A': findnorm = NO;	break;
		case 'T': tabled   = YES;	break;
		case 'P': passwd   = YES;	break;
		case 'C': showall  = YES;	break;
		case 'O': sorttime = YES;	break;
		}
	}
	else if (usercount < MAXUSERS)
	    users[usercount++] = p;
    }

    if (readSysTab(NO)) {
	initlogBuf(&logBuf);

	ctdlfile(fn, cfg.sysdir, "ctdllog.sys");
	if ((logfl = dopen(fn, O_RDONLY)) < 0)
	    crashout("Can't open %s", fn);

	for (i = 0; i < cfg.logsize; i++) {
	    pos = sorttime ? logTab[i].ltlogSlot : i;
	    getlog(&logBuf, pos, logfl);
	    if (showall || readbit(logBuf,uINUSE)) {
		entry++;
		for (j = 0; j < usercount; j++)
		    if (labelcmp(logBuf.lbname, users[j]) == 0)
			break;
		if (usercount == 0 || j < usercount)
		    showlog(pos);
	    }
	}

	if (tabled && txp)
	    putchar('\n');
	else
	    printf("%d/%d user%s, %d log entries\n", seen, entry,
		(entry != 1) ? "s" : "", cfg.logsize);

	killlogBuf(&logBuf);
    }
    if (fromdesk())
	hitkey();
}

/*
 * flipbits -- Flip selected logBuf status bits for all users
 *
 * 91May31 RWH	Created from vlog.c
 */
#include "ctdl.h"
#include "config.h"
#include "log.h"

extern struct config	cfg;
extern struct logBuffer	logBuf;
extern struct lTable	*logTab;

int logfl;	/* log file descriptor */

char *program = "flipbits";

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

main(void)
{
    int i;
    int setnet, setmail, setdoor, netval, mailval, doorval;
    char fn[100];
    extern char VERSION[];
    
    setbuf(stdout, NULL);

    printf("flipbits %s\n", VERSION);

    if (!readSysTab(FALSE))
	exit(1);

    setnet = setmail = setdoor = netval = mailval = doorval = NO;

    printf("Set the net priv bit? ");
    if (getyesno()) {
	setnet = YES;
	printf("Bestow net privs ('Y') or remove them ('N')? ");
	if (getyesno())
	    netval = YES;
    }

    printf("Set the mail priv bit? ");
    if (getyesno()) {
	setmail = YES;
	printf("Bestow mail privs ('Y') or remove them ('N')? ");
	if (getyesno())
	    mailval = YES;
    }

    printf("Set the door priv bit? ");
    if (getyesno()) {
	setdoor = YES;
	printf("Bestow door privs ('Y') or remove them ('N')? ");
	if (getyesno())
	    doorval = YES;
    }

    if (setnet || setmail || setdoor) {
	initlogBuf(&logBuf);

	ctdlfile(fn, cfg.sysdir, "ctdllog.sys");
	if ((logfl = dopen(fn, O_RDONLY)) < 0)
	    crashout("Can't open %s\n", fn);

	for (i=0; i<cfg.logsize; i++) {
            getlog(&logBuf,i,logfl);
	    printf("%4d: %s\n", i, logBuf.lbname);
            if (readbit(logBuf,uINUSE) && !readbit(logBuf, uAIDE) &&
		!readbit(logBuf, uSYSOP)) {
		if (setnet)
		    if (netval)
			set(logBuf,uNETPRIVS);
		    else
			clear(logBuf,uNETPRIVS);

		if (setmail)
		    if (mailval)
			set(logBuf,uMAILPRIV);
		    else
			clear(logBuf,uMAILPRIV);

		if (setdoor)
		    if (doorval)
			set(logBuf,uDOORPRIV);
		    else
			clear(logBuf,uDOORPRIV);

		putlog(&logBuf,i,logfl);
	    }
	}

	dclose(logfl);
	killlogBuf(&logBuf);
    }

    if (fromdesk())
	hitkey();
}

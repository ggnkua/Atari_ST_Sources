/*
 * mchange.c -- change the value of #mailslots (the maximum number of mail
 * messages that users may see at one time)
 *
 * 90Jun05 A&R	Created as part of 1.3 release.
 */

#include "ctdl.h"
#include "room.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

char *program = "mchange";
int newmailslots;

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

void
modifyroom(void)
{
    getRoom(MAILROOM);
    NUMMSGS = newmailslots;
    roomBuf.msg = (theMessages *)realloc(roomBuf.msg, MSG_BULK);
    putRoom(MAILROOM);
}

void
modifylogs(void)
{
    int i, oldlog, newlog, oldmailslots, j, shrink = 0;
    PATHBUF oldfile, newfile;

    ctdlfile(oldfile, cfg.sysdir, "ctdllog.sys");
    if ((oldlog = dopen(oldfile, O_RDONLY)) < 0)
	crashout("cannot open %s", oldfile);

    ctdlfile(newfile, cfg.sysdir, "ctdllog.tmp");
    if ((newlog = dcreat(newfile)) < 0)
	crashout("cannot create %s", newfile);

    oldmailslots = MAILSLOTS;
    if (newmailslots < oldmailslots)
	shrink = oldmailslots - newmailslots; 

    for (i = 0; i < cfg.logsize; i++) {
	MAILSLOTS = oldmailslots;
	getlog(&logBuf, i, oldlog);
	printf("Modifying log #%d", i);
	if (readbit(logBuf, uINUSE))
	    printf(" (%s)", logBuf.lbname);
	putchar('\n');
	MAILSLOTS = newmailslots;
	if (shrink > 0)	/* we're shrinking! Hep! */
	    for (j = 0; j < MAILSLOTS - shrink; j++) {
		logBuf.lbmail[j].msgloc = logBuf.lbmail[shrink + j].msgloc;
		logBuf.lbmail[j].msgno = logBuf.lbmail[shrink + j].msgno;
	    }

	logBuf.lbmail = (theMessages *) realloc(logBuf.lbmail, MAIL_BULK);

	if (shrink < 0)	{	/* We're expanding! Watch out! */
	    for (j = newmailslots - 1; j > 0 - shrink; j--) {
		logBuf.lbmail[j].msgloc = logBuf.lbmail[shrink + j].msgloc;
		logBuf.lbmail[j].msgno = logBuf.lbmail[shrink + j].msgno;
	    }
	    for (j = 0; j < -shrink; j++)	/* zero new entries */
		zero_struct(logBuf.lbmail[j]);
	}
	putlog(&logBuf, i, newlog);
    }
    MAILSLOTS = oldmailslots;

    dclose(oldlog);
    dclose(newlog);

    if (dunlink(oldfile))
	crashout("cannot unlink %s", oldfile);
    if (drename(newfile, oldfile))
	crashout("cannot rename %s to %s", oldfile, newfile);
}

main(int argc, char **argv)
{
    int p, junk;

    setbuf(stdout, NULL);
    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (argc == 2)
	newmailslots = atoi(argv[1]);
    else {
	fprintf(stderr, "usage: %s <new max number of mailslots>\n", program);
	if (fromdesk())
	    hitkey();
	exit(1);
    }

    if ((newmailslots > MAXMAILSLOTS) || (newmailslots < MINMAILSLOTS))
	crashout("new mailslots must be between %d and %d", MINMAILSLOTS,
		MAXMAILSLOTS);
    else if (newmailslots > SANEMAILSLOTS) {
	printf("Do you really want %d mail slots? (y/n) ", newmailslots);
	if (!getyesno())
	    crashout("Okay");
    }
    else if (newmailslots == MAILSLOTS)
	crashout("mailslots is already %d", newmailslots);

    if (readSysTab(FALSE) && makelock(&p)) {
	initroomBuf(&roomBuf);
	initlogBuf(&logBuf);

	modifylogs();	/* hack on all the log entries */
	modifyroom();	/* hack on room0001.sys */

	printf("Be sure to change ctdlcnfg.sys to reflect the new value of\n");
	printf("mailslots (%d).  Then run configur.  If you don't, your\n",
	    newmailslots);
	printf("system will explode.\n"); 
	MAILSLOTS = newmailslots;
	junk = writeSysTab();
	wipelock(&p);

	killroomBuf(&roomBuf);
	killlogBuf(&logBuf);
    }
    if (fromdesk())
	hitkey();
    exit(0);
}

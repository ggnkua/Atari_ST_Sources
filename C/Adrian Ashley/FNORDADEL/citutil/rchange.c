/*
 * rchange.c -- change the value of #maxrooms (the maximum number of room
 * 		slots available for use.
 *
 * 90May29 RH	Created as part of 1.3 release.
 */

#include "ctdl.h"
#include "log.h"
#include "room.h"
#include "config.h"
#include "citlib.h"

char *program = "rchange";
int newmaxrooms, maxused;

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

/* If we are increasing the number of rooms, create the new room files */
int
addrooms(void)
{
    int i;

    if (newmaxrooms < MAXROOMS)
	return NO;

    memset(&roomBuf, 0, RB_SIZE);
    roomBuf.msg = (theMessages *) realloc(roomBuf.msg, MSG_BULK);
    roomTab = (struct rTable *) realloc(roomTab, (sizeof *roomTab) *
	newmaxrooms);
    for (i = MAXROOMS; i < newmaxrooms; i++) {
	printf("Creating new room %d\n", i);
	thisRoom = i;	/* needed by noteRoom()! */
	putRoom(i);
	noteRoom();
    }
    return YES;
}

/* If we are reducing the number of rooms, delete unneeded room files */
int
deleterooms(void)
{
    int i;
    PATHBUF sysfile;
    LABEL fn;

    for (i = newmaxrooms; i < MAXROOMS; i++) {
	printf("Deleting unused room %d\n", i);
	sprintf(fn, "room%04d.sys", i);
	ctdlfile(sysfile, cfg.roomdir, fn);
	if (dunlink(sysfile))
	    crashout("couldn't delete %s", sysfile);
    }
    return YES;
}

/* In case we're reducing the number of rooms, scan those to be thrown out
   to make sure they're empty. */
int
scanrooms(void)
{
    int i;

    if (newmaxrooms > MAXROOMS)
	return NO;

    for (i = MAXROOMS - 1; !readbit(roomTab[i],INUSE); i--)
	/* nothing */;
    maxused = i + 1;
    printf("Last roomslot in use is %d.\n", i);
    if (maxused == MAXROOMS) {
	printf("No compression possible.\n");
	return NO;
    }
    if (maxused > newmaxrooms) {
	printf("Error: desired size of %d cannot be achieved.\n", newmaxrooms);
	printf("The best that can be done is %d; go ahead? (y/n) ", maxused);
	if (!getyesno())
	    return NO;
	else
	    newmaxrooms = maxused;
    }
    roomTab = (struct rTable *) realloc(roomTab, (sizeof *roomTab) *
	newmaxrooms);
    return deleterooms();
}

void
modifylogs(void)
{
    int i, oldlog, newlog, oldmaxrooms;
    PATHBUF oldfile, newfile;

    ctdlfile(oldfile, cfg.sysdir, "ctdllog.sys");
    if ((oldlog = dopen(oldfile, O_RDONLY)) < 0)
	crashout("cannot open %s", oldfile);

    ctdlfile(newfile, cfg.sysdir, "ctdllog.tmp");
    if ((newlog = dcreat(newfile)) < 0)
	crashout("cannot create %s", newfile);

    oldmaxrooms = MAXROOMS;

    for (i = 0; i < cfg.logsize; i++) {
	MAXROOMS = oldmaxrooms;
	getlog(&logBuf, i, oldlog);
	printf("Modifying log #%d", i);
	if (readbit(logBuf, uINUSE))
	    printf(" (%s)", logBuf.lbname);
	putchar('\n');
	MAXROOMS = newmaxrooms;
	logBuf.lbgen = (char *) realloc(logBuf.lbgen, GEN_BULK);
	putlog(&logBuf, i, newlog);
    }
    MAXROOMS = oldmaxrooms;

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
	newmaxrooms = atoi(argv[1]);
    else {
	fprintf(stderr, "usage: %s <new max number of rooms>\n", program);
	if (fromdesk())
	    hitkey();
	exit(1);
    }

    if ((newmaxrooms > MAXMAXROOMS) || (newmaxrooms < MINMAXROOMS))
	crashout("maxrooms must be between %d and %d", MINMAXROOMS,
		MAXMAXROOMS);
    else if (newmaxrooms > SANEMAXROOMS) {
	printf("Do you really want %d rooms? (y/n) ", newmaxrooms);
	if (!getyesno())
	    crashout("Okay");
    }
    else if (newmaxrooms == MAXROOMS)
	crashout("maxrooms is already %d", newmaxrooms);

    if (readSysTab(FALSE) && makelock(&p)) {
	initroomBuf(&roomBuf);
	initlogBuf(&logBuf);

	if (addrooms() || scanrooms()) { 	/* did we change anything? */
	    modifylogs();			/* resize logBuf.lbgen */
	    printf("Be sure to change ctdlcnfg.sys to reflect the new value of\n");
	    printf("maxrooms (%d).  Then run configur.  If you don't, your\n",
		newmaxrooms);
	    printf("system will explode.\n"); 
	    MAXROOMS = newmaxrooms;
	    junk = writeSysTab();
	}
    wipelock(&p);
    }
    if (fromdesk())
	hitkey();
    exit(0);
}

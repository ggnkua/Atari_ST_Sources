/*
 * dosysop.c -- Sysop-specific commands for citadel.
 *
 * 89Jan21 RH	Disallowed remote-sysop use of [T], [Z], [G], [R].
 * 89Jan18 AA	[T]elephone uses dialer(); added [G]otomodem command.
 * 88Jul13 orc	Created.
 */

#include "ctdl.h"
#include "event.h"
#include "calllog.h"
#include "protocol.h"
#include "door.h"
#include "terminat.h"
#include "config.h"
#include "room.h"
#include "net.h"
#include "log.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * douser()		do something with a user
 * viewuser()		view user status flags
 * killuser()		vape a user
 * aidetoggle()		toggle aide privileges
 * twittoggle()		toggle twit status
 * nettoggle()		toggle net privileges
 * mailtoggle()		toggle mail privileges
 * creditsetting()	toggle credit setting
 * resetlimits()	reset user daily limits
 * dostatus()		status-altering commands
 * doSysop()		sysop-only commands
 */

/*
 * douser() -- do something with a user
 */
static void
douser(int (*pc)())
{
    LABEL who;
    int account;
    struct logBuffer user, *p;

    getNormStr("", who, NAMESIZE, YES);
    if (strlen(who) < 1)
	return;
    if (loggedIn && (stricmp(logBuf.lbname, who) == 0)) {
	p = &logBuf;
	account = 0;	/* assuming the logged in user has been bubbled */
    }
    else {
	p = &user;
	initlogBuf(p);
	if ((account = getnmidx(who, p, logfl)) == ERROR) {
	    mprintf("No such person\r");
	    killlogBuf(p);
	    return;
	}
    }
    if ((*pc)(p, account))
	putlog(p, logTab[account].ltlogSlot, logfl);
    if (p == &user)
	killlogBuf(&user);
}

/*
 * viewuser() -- view the various status bits of a user account
 */
static void
viewuser(void)
{
    LABEL who;
    int account;
    struct logBuffer user, *p;

    getNormStr("", who, NAMESIZE, YES);
    if (strlen(who) < 1)
	return;
    if (loggedIn && (stricmp(logBuf.lbname, who) == 0)) {
	p = &logBuf;
	account = 0;	/* assuming the logged in user has been bubbled */
    }
    else {
	p = &user;
	initlogBuf(p);
	if ((account = getnmidx(who, p, logfl)) == ERROR) {
	    mprintf("No such person\r");
	    killlogBuf(p);
	    return;
	}
    }
    mprintf("\r`%s' has the following status flags set:\r", p->lbname);
    if (readpbit(p,uSYSOP))
	mprintf("Sysop, ");
    if (readpbit(p,uAIDE))
	mprintf("Aide, ");
    if (readpbit(p,uNETPRIVS))
	mprintf("Net privs, ");
    if (readpbit(p,uMAILPRIV))
	mprintf("Mail privs, ");
    if (readpbit(p,uDOORPRIV))
	mprintf("Door privs, ");
    if (readpbit(p,uTWIT))
	mprintf("Twit, ");
    mprintf("credits = %d\r",p->credit);
    mprintf("\r`%s' has the following daily limit values:\r", p->lbname);
    mprintf("%ldK downloaded\r", p->lbdownloadlimit / 1024L);
    mprintf("%d calls made\r", p->lbcalls);
    mprintf("%d minutes connect time\r", p->lbtime);
    mprintf("%d close calls made\r", p->lbclosecalls);
    if (p == &user)
	killlogBuf(&user);
}

/*
 * killuser() - vape out a user
 */
static int
killuser(struct logBuffer *p, int slot)
{
    LABEL name;
    
    if (p->credit)
	mprintf("%s has %s. - ", p->lbname,
		 plural("net credit", (long)(p->credit)));
    if (getNo(confirm)) {
	strcpy(name, p->lbname);
	if (loggedIn && logTab[slot].ltlogSlot == logindex)
	    terminate(YES, tKILLUSER);
	mprintf("%s killed\r", name);
	killhold(slot);
	clearp(p,uINUSE);	/* replaces zero_struct(*p) -- AA 90Jan31 */
	logTab[slot].ltpwhash = logTab[slot].ltnmhash = 0;
	return 1;
    }
    return 0;
}

/*
 * aidetoggle() - toggle aide status
 */
static int
aidetoggle(struct logBuffer *p, int slot)
{
    mprintf("%s %s Aide privileges - ", p->lbname,
	    readpbit(p,uAIDE)?"loses":"gets");
    if (getNo(confirm)) {
	if (readpbit(p,uAIDE)) {	/* About to lose Aide status?	*/
	    if (readpbit(p,uSYSOP)) {	/* Remove Sysop status too	*/
		mprintf("Warning: %s will lose Sysop status - ", p->lbname);
		if (!getNo(confirm))
		    return 0;
		clearp(p,uSYSOP);
	    }
	}
	else				/* Make Aide> known to user	*/
	    if (LBGEN(*p,AIDEROOM) != roomTab[AIDEROOM].rtgen)
		p->lbgen[AIDEROOM] = (roomTab[AIDEROOM].rtgen << GENSHIFT)
					+ MAXVISIT - 1;
	flipp(p,uAIDE);
	return 1;
    }
    return 0;
}

/*
 * sysoptoggle() - toggle sysop status
 */
static int
sysoptoggle(struct logBuffer *p, int slot)
{
    mprintf("%s %s Sysop privileges - ", p->lbname,
	    readpbit(p,uSYSOP)?"loses":"gets");
    if (getNo(confirm)) {
	flipp(p,uSYSOP);
	if (!readpbit(p,uSYSOP))	/* Not a Sysop any more		    */
	    aidetoggle(p, slot);	/* Give option to turn off Aide too */
	else {				/* Is a Sysop now, set Aide too	    */
	    setp(p,uAIDE);		/* Make Aide> known to user	    */
	    if (LBGEN(*p,AIDEROOM) != roomTab[AIDEROOM].rtgen)
		p->lbgen[AIDEROOM] = (roomTab[AIDEROOM].rtgen << GENSHIFT)
					+ MAXVISIT - 1;
	}
	return 1;
    }
    return 0;
}

/*
 * twittoggle() - toggle twit status
 */
static int
twittoggle(struct logBuffer *p, int slot)
{
    mprintf("%s %s twit status - ", p->lbname,
	    readpbit(p,uTWIT)?"loses":"gets");
    if (getNo(confirm)) {
	/* If we're giving TWIT status to an Aide or Sysop, sound a warning. */
	if (!readpbit(p,uTWIT)) {
	    if (readpbit(p,uAIDE) || readpbit(p,uSYSOP)) {
		mprintf("Warning: %s will lose Sysop and/or Aide status - ",
		    p->lbname);
		if (!getNo(confirm))
		    return 0;
		clearp(p,uAIDE);
		clearp(p,uSYSOP);
	    }
	    clearp(p,uNETPRIVS);	/* Toast net privs too */
	}
	flipp(p,uTWIT);
	return 1;
    }
    return 0;
}

/*
 * nettoggle() - flip net privs for a user
 */
static int
nettoggle(struct logBuffer *p, int slot)
{
    mprintf("%s %s net privileges - ", p->lbname,
	readpbit(p,uNETPRIVS) ? "loses":"gets");
    if (getNo(confirm)) {
	flipp(p,uNETPRIVS);
	return 1;
    }
    return 0;
}

/*
 * mailtoggle() - flip mail privs for a user
 */
static int
mailtoggle(struct logBuffer *p, int slot)
{
    mprintf("%s %s mail privileges - ", p->lbname,
	readpbit(p,uMAILPRIV) ? "loses":"gets");
    if (getNo(confirm)) {
	flipp(p,uMAILPRIV);
	return 1;
    }
    return 0;
}

/*
 * doortoggle() - flip door privs for a user
 */
static int
doortoggle(struct logBuffer *p, int slot)
{
    mprintf("%s %s door privileges - ", p->lbname,
	readpbit(p,uDOORPRIV) ? "loses":"gets");
    if (getNo(confirm)) {
	flipp(p,uDOORPRIV);
	return 1;
    }
    return 0;
}

/*
 * creditsetting() - give a user net credits
 */
static int
creditsetting(struct logBuffer *p, int slot)
{
    if (readpbit(p,uNETPRIVS) || nettoggle(p, slot)) {
	mprintf("%s has %s; ", p->lbname, plural("credit", (long)(p->credit)));
	p->credit = asknumber("new setting", 0L, 32000L, p->credit);
	return 1;
    }
    return 0;
}

/*
 * resetlimits() - reset user daily limits (download, calls, etc.)
 */
static int
resetlimits(struct logBuffer *p, int slot)
{
    mprintf("`%s' has the following daily limit values:\r", p->lbname);
    mprintf("%ldK downloaded\r", p->lbdownloadlimit / 1024L);
    mprintf("%d calls made\r", p->lbcalls);
    mprintf("%d minutes connect time\r", p->lbtime);
    mprintf("%d close calls made\r", p->lbclosecalls);
    mprintf("Reset these values - ");
    if (getNo(confirm)) {
	p->lbdownloadlimit = 0L;
	p->lbcalls = 0;
	p->lbtime = 0;
	p->lbclosecalls = 1;
	return 1;
    }
    return 0;
}

/*
 * dostatus() - handles all user status settings
 */
static void
dostatus(void)
{
    while (onLine()) {
	outFlag = OUTOK;
	mprintf("\rstatus cmd: ");

	switch (toupper(getnoecho())) {
	case 'A':
	    mprintf("Toggle Aide status for: ");
	    douser(aidetoggle);
	    break;
	case 'C':
	    mprintf("Credit setting for: ");
	    douser(creditsetting);
	    break;
	case 'D':
	    mprintf("Toggle door privs for: ");
	    douser(doortoggle);
	    break;
	case 'K':
	    mprintf("Kill user: ");
	    douser(killuser);
	    break;
	case 'M':
	    mprintf("Toggle mail privs for: ");
	    douser(mailtoggle);
	    break;
	case 'N':
	    mprintf("Toggle net privs for: ");
	    douser(nettoggle);
	    break;
	case 'R':
	    mprintf("Reset daily limits for: ");
	    douser(resetlimits);
	    break;
/* Sysop status code added by RH 90Aug04 */
	case 'S':
	    mprintf("Toggle Sysop status for: ");
	    douser(sysoptoggle);
	    break;
/* Twit status code added by RH 89Jan22 */
	case 'T':
	    mprintf("Toggle twit status for: ");
	    douser(twittoggle);
	    break;
	case 'X':
	    mprintf("Exit status menu.\r");
	    return;
	case 'V':
	    mprintf("View user: ");
	    viewuser();
	    break;
	case '?':
	    menu("ctdlstat");
	    break;
	default:
	    whazzit();
	}
    }
}

/*
 * userlist_menu() - general manipulation of user lists
 *			(for purge, restrict, etc.)
 */
static void
userlist_menu(list, name, filename, num, flag)
struct user **list;	/* Head of the list */
char *name;		/* Generic name for whatever we're doing, IE "purge" */
char *filename;		/* Filename (relative to #sysdir) of the list */
int *num;		/* Pointer to total number of users in this list */
char *flag;		/* Ptr to flag indicating that the function is on/off */
{
    struct user *p, *q;
    int i;
    FILE *f;
    LABEL username;
    PATHBUF sysfile;

    while (onLine()) {
	outFlag = OUTOK;
	mprintf("\r%s cmd: ", name);

	switch (toupper(getnoecho())) {
	case 'A':
	    getNormStr("Add user", username, NAMESIZE, YES);
	    if (strlen(username) >= 1) {
		q = (struct user *) xmalloc(sizeof (struct user));
		strcpy(q->name, username);
		q->next = NULL;
		if (!*list) {
		    *list = q;
		    *num = 1;
		}
		else {
		    p = *list;
		    while (p->next)
			p = p->next;
		    p->next = q;
		    (*num)++;
		}
	    }
	    break;
	case 'D':
	    if (*list) {
		getNormStr("Delete user", username, NAMESIZE, YES);
		if (strlen(username) >= 1) {
		    if (!stricmp((*list)->name, username)) {	/* 1st one? */
			p = *list;		/* preserve *list (for free) */
			if (*num == 1) {	/* only one loaded? */
			    *list = NULL;	/* nuke the whole list, then */
			    *flag = NO;
			}
			else			/* no? ok, just nuke 1st one */
			    *list = (*list)->next;
			(*num)--;
			free(p);		/* free the space */
		    } 
		    else {
			p = *list;
			while (p->next)
			    if (stricmp(p->next->name, username) != 0)
				p = p->next;
			    else
				break;
			if (p->next) {
			    q = p->next;
			    p->next = p->next->next;
			    free(q);
			    (*num)--;
			}
		    }		
		}
	    }
	    else
		mprintf("\rNo %s IDs loaded, sorry.\r", name);
	    break;
	case 'S':
	    mprintf("Switch %s %s feature - ", (*flag ? "off" : "on"), name);
	    if (getNo(confirm))
		*flag = !(*flag);
	    break;
	case 'V':
	    mprintf("\r%s feature is %sabled, %d IDs loaded\r", name,
		(*flag ? "en" : "dis"), *num);
	    if (p = *list) {
		while (p) {
		    mprintf(" %s,", p->name);
		    p = p->next;
		}
		mprintf("\b\r");
	    }
	    else if (*num != 0)
mprintf(" Hey! It says I've got some IDs loaded, but I can't find them...\r");
	    break;
	case 'W':
	    if (*list) {
		mprintf("Write %s list\r", name);
		ctdlfile(sysfile, cfg.sysdir, filename);
		if (f = safeopen(sysfile, "w")) {
		    i = 0; p = *list;
		    while(p) {
			fprintf(f, "%s\n", p->name);
			i++;
			p = p->next;
		    }
		    mprintf("%d names written\r", i);
		    fclose(f);
		}
	        else
		    mprintf("Couldn't open %s\r", sysfile);
	    }
	    else
		mprintf("No names in %s list\r", name);
	    break;
	case 'X':
	    mprintf("Exit %s menu.\r", name);
	    return;
	case '?':
	    menu("ctdllist");
	    break;
	default:
	    whazzit();
	}
    }
}

/*
 * doSysop() - handles the sysop-only menu
 */
int
doSysop(void)
{
#define AUTOLIST	100
    int	 *list = (int*)(&msgBuf);
    LABEL who;
    int   size, count, callcode;
    int   i, j, k;
    int   netNo;
    long  timeTil;
    extern void rundoor(struct doorway *door, char *tail);

    if (!(onConsole || remoteSysop)) {
	if (!readbit(logBuf,uSYSOP) || strlen(cfg.sysPassword) == 0)
	    return YES;
	getNormStr("Sysop password", (char *)list, 80, NO);
	if (strcmp((char *)list, cfg.sysPassword) != 0)
	    return YES;
	remoteSysop = YES;
    }

    while (onLine()) {
	outFlag = OUTOK;
	mprintf("\rsysop cmd: ");

	switch (toupper(getnoecho())) {
	case 'B':
	    setBaud((int)getNumber("Baudrate", 0l, (long)(NUMBAUDS-1)));
	    break;
	case 'E':
	    mprintf("Echo %s\r", (seemodem = !seemodem) ? on : off);
	    break;
	case 'F':
	    if (loggedIn) {
		getNormStr("File grab", (char *)list, 80, YES);
		if (strlen((char *)list) > 0 && !ingestFile((char *)list))
		    mprintf("No %s\r", (char *)list);
	    }
	    break;
	case 'C':
	    cfg.flags.NOCHAT = !cfg.flags.NOCHAT;
	    mprintf("Chat %s\r", (cfg.flags.NOCHAT) ? off : on);
	    break;
	case 'D':
	    Debug = !Debug;
	    mprintf("Debugging %s\r", Debug ? on : off);
	    if (!Debug) {
		if (debuglog) {
		    fclose(debuglog);
		    debuglog = NULL;
		}
	    } else {
		PATHBUF fn;

		ctdlfile(fn, cfg.auditdir, "debuglog.sys");
		if ((debuglog = safeopen(fn, "a")) == NULL)
		    mprintf("error: cannot open debug logfile.\r");
	    }
	    break;
	case 'V':
	case 'I':
	    mprintf("Fnordadel%s V%s-%d\r", MACHINE, VERSION, PATCHNUM);
	    mprintf("Chat mode %sabled\r", (cfg.flags.NOCHAT)?"dis":"en");
	    if (Debug)
		mprintf("Debugging on (logging %s)\r", debuglog ? "on" : "off");
	    if (netDebug)
		mprintf("Network debugging on\r");
	    if (netymodem)
		mprintf("Ymodem on\r");
	    if (checkloops)
		mprintf("Loop-zapper on\r");
	    mprintf("%d purge IDs loaded, purging %s\r",
		numpurge, msgpurge ? "on" : "off");
	    mprintf("%d restricted IDs loaded, restrictions %s\r",
		numrestrict, restrict ? "on" : "off");
	    mprintf("Heap: %ld bytes.\r", (long)Malloc(-1L));
	    break;
	case 'M':
	    mprintf("System now on MODEM\r");
	    if (onConsole) {
		onConsole = NO;
		modemOpen();
	    }
	    return NO;
	case 'O':
	    if (shell) {
		mprintf("Outside commands\r");
		rundoor(shell,NULL);
	    }
	    else
		mprintf("No shell defined!\r");
	    break;
/* Telephone code modified to use dialer() by AA 89Jan17 */
	case 'T':
	    if (onConsole) {
	        if ((netNo = getSysName("Telephone",who)) != ERROR) {
		    modemOpen();
		    if ((callcode = dialer(netNo, YES)) == 0) {
		       connect(NO, NO, NO);
		       break;
		    }
		    if (callcode != 0 && dropDTR)
			modemClose();
	        }
	    }
	    break;
	case 'Z':
	    if (onConsole) {
	    	mprintf("Autodial\r");
	   	size = 0;
	    	do {
		    if ((j=getSysName("System", who)) != ERROR)
		    	list[size++] = j;
	    	} while (who[0] && size < AUTOLIST);
	    	if (size < 1)
		    break;
	    	count = asknumber("Redial attempts (0 cancels)", -1L, 9999L, 25L);

	    	for (j = 0; count > 0; ) {
		    modemOpen();
		    xprintf("try %d: ", count);
		    if ((callcode = dialer(list[j++], YES)) == 0) {
		    	xputc(7);
		    	connect(NO, NO, NO);
			if (!gotcarrier()) {
			    for (k=j-1; k < size-1; k++)
				list[k] = list[k + 1];
			    size--;
			    j--;
			    if (j == size) {
				count--;
				j = 0;
			    }
			}
			if ((size == 0) || (gotcarrier()))
			    break;
		    }
		    else if (callcode == 2)
		    	break;
		    else if (j >= size) {
		    	count--;
		    	j = 0;
		    }
		    xputs("\r\033K");
	    	}
	    	if (callcode != 0 && dropDTR)
		    modemClose();
	    }
	    break;
	case 'S':
	    setclock();
	    break;
	case 'X':
	    mprintf("Exit sysop menu.\r");
	    return NO;
	case 'A':
	    mprintf("Abnormal system exit- ");
	    if (!getNo(confirm))
		break;
	    Abandon = YES;
	    exitValue = (int)asknumber("Exit value", 0L, 32000L, (remoteSysop ?
		REMOTE_EXIT : SYSOP_EXIT));
	    return NO;
	case 'Q':
	    mprintf("Exit program- ");
	    if (!getNo(confirm))
		break;
	    Abandon = YES;
	    exitValue = remoteSysop ? REMOTE_EXIT : SYSOP_EXIT;
	    return NO;
	case 'N':
	    mprintf("Net menu\r");
	    netmenu();
	    break;
	case 'U':
	    mprintf("User status menu\r");
	    dostatus();
	    break;
	case 'R':
	    mprintf("Reinitialize modem\r");
	    if (onConsole)
		hangup();
	    else
		terminate(YES, tREINIT);
	    if (dropDTR) modemClose();
	    break;
	case 'G':
	    if (onConsole) {
	    	modemOpen();
	    	connect(NO, NO, NO);
	    }
	    break;
	case 'Y':
	    if (evtRunning) {
		long hr, min, sec, dy;
		long timeLeft(), upTime();

		timeTil = timeLeft(evtClock);
		sec= timeTil%60L; timeTil /= 60L;
		min= timeTil%60L; timeTil /= 60L;
		hr = timeTil%24L;
		dy = timeTil/24L;

		mprintf("Next event: `%s', triggers in ", nextEvt->evtMsg);
		if (dy > 0)
		    mprintf("%s, ", plural("day", dy));
		if (hr > 0)
		    mprintf("%s, ", plural("hour", hr));
		if (min > 0)
		    mprintf("%s, ", plural("minute", min));
		mprintf("%s\r", plural("second", sec));
	    }
	    else
		mprintf("No scheduled events.\r");
	    for (i=0; i<cfg.evtCount; i++) {
		mprintf("%2d: %-19s (%c%02d) @ %d:%02d", i,
			    evtTab[i].evtMsg, evtChar[evtTab[i].evtType],
			    evtTab[i].evtFlags,
			    evtTab[i].evtTime/60, evtTab[i].evtTime%60);
		/*
		 * print out what days this event will be active in...
		 */
		if (evtTab[i].evtDay != 0x7f)
		    showdays(evtTab[i].evtDay, NO);
		doCR();
	    }
	    doCR();
	    for (i=0; i<cfg.poll_count; i++) {
		mprintf("poll %02d from %d:%02d to %d:%02d ",
			pollTab[i].p_net,
			pollTab[i].p_start/60, pollTab[i].p_start%60,
			pollTab[i].p_end/60,   pollTab[i].p_end%60);
		/*
		 * print out what days this event will be active in...
		 */
		if (pollTab[i].p_days != 0x7f)
		    showdays(pollTab[i].p_days, NO);
		doCR();
	    }
	    break;
	case 'W':
	    mprintf("Restrict menu\r");
	    userlist_menu(&restlist, "restriction", "restrict.sys",
		&numrestrict, &restrict);
	    break;
	case 'P':
	    mprintf("Purge menu\r");
	    userlist_menu(&purgelist, "purge", "purge.sys", &numpurge,
		&msgpurge);
	    break;
	case '?':
	    menu("ctdlopt");
	    break;
	default:
	    whazzit();
	}
    }
}

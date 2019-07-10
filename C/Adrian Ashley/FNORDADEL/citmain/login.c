/*
 * login.c -- login code for Citadel bulletin board system
 */

/*
 * 91Feb10 RH	Split login-related stuff from log.c
 * 91Jan04 AA	Hooks put in for auto login/logout/newuser doors
 * 90Jan23 R&A	login(), terminate() and ancillaries totally rebuilt
 * ...previous history deleted for space reasons...
 */

#include "ctdl.h"
#include "event.h"
#include "calllog.h"
#include "room.h"
#include "log.h"
#include "terminat.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * * bubblelog()	slide a logTab entry to logTab[0]
 * getpwlog()		find the user with a given password
 * * dorestrict()	see if user should be let past login restrictions
 * * doinherit()	see if user should inherit any ruggie properties
 * * newuserlogin()	log in a new user
 * login() 		log a user in
 * setlog() 		Initialize logbuffer for caller
 */

char	loggedIn=NO;		/* Global have-caller flag	*/
char	sameuser=NO;
int	badpw = NO;
time_t	today;			/* Time of user login		*/
char	marktime[11] = "";	/* last login (for status line)	*/
short	oldcatChar;		/* Record cfg.catChar & cfg.catSector	*/
short	oldcatSector;		/* at user login.			*/

struct previnfo prevuser;	/* Name & flags of previous user */

int logfl;
extern void rundoor(struct doorway *door, char *tail);

/*
 * bubblelog() - slide a logtable entry to logTab[0]
 */
static void
bubblelog(int start)
{
    struct lTable temp;

    logTab[start].ltnewest = cfg.newest;
    copy_struct(logTab[start], temp);
    while (--start >= 0)
	copy_struct(logTab[start], logTab[1+start]);
    copy_struct(temp, logTab[0]);
}

/*
 * getpwlog() - find the user with a given password
 */
int
getpwlog(LABEL pw, struct logBuffer *p)
{
    register pwh, i;

    if (strlen(pw) < 2)
	return ERROR;
    for (pwh=hash(pw), i=0; i < cfg.logsize; i++)
	if (logTab[i].ltpwhash == pwh) {
	    getlog(p, logTab[i].ltlogSlot, logfl);
	    if (stricmp(pw, p->lbpw) == 0)
		return i;
	}
    return ERROR;
}

/*
 * dorestrict() -- checks to see if the user trying to sign on should be
 *	allowed to do so
 */
static int
dorestrict(char *name, int newuser)
{
    struct user *i;

    if (onConsole || (cfg.sysopName &&
	stricmp(name, &cfg.codeBuf[cfg.sysopName]) == 0))
	return NO;
    else if (restrict && restlist) {
	i = restlist;
	while (i)
	    if (stricmp(i->name, name) != 0)
		i = i->next;
	    else
		break;
	if (!i) {
	    if (!blurb("restrict", YES))
		mprintf("\rThe system is closed.  Call back later.\r");
	    terminate(YES, tRESTRICT);
	    return YES;
	}
    }
    else if (newuser && (readbit(prevuser, uTWIT))) {
	if (!blurb("restrict", YES))
	    mprintf("\rThe system is closed.  Call back later.\r");
	terminate(YES, tRESTRICT);
	return YES;
    }
    return NO;
}

/*
 * doinherit() -- causes ruggie status to be inherited by the user signing on,
 *	if the previous user signed off by .TS
 */
static int
doinherit(void)
{
    if (onConsole || (cfg.sysopName &&
	stricmp(logBuf.lbname, &cfg.codeBuf[cfg.sysopName]) == 0))
	return NO;
    else if (sameuser && (readbit(prevuser, uTWIT))) {
	set(logBuf, uTWIT);
	putlog(&logBuf, logindex, logfl);
	return YES;
    }
    return NO;
}

/*
 * newuserlogin() -- gets new user info
 */
static int
newuserlogin(char *username, char *password)
{
    LABEL nm, pw;
    struct logBuffer temp;
    int  good, g, h, i;
    long low;

    initlogBuf(&temp);

    heldMessage = NO;		/* wipe out any held message */

    /*
     * Set user defaults as specified in ctdlcnfg.sys
     */
    logBuf.flags = 0L;		/* wipe all status flags */
    set(logBuf,uLINEFEEDS);
    if (cfg.flags.DEFSHOWTIME)
	set(logBuf,uSHOWTIME);
    if (cfg.flags.DEFLASTOLD)
	set(logBuf,uLASTOLD);
    if (cfg.flags.DEFFLOORMODE)
	set(logBuf,uFLOORMODE);
    if (cfg.flags.DEFREADMORE)
	set(logBuf,uREADMORE);
    if (cfg.flags.DEFNUMLEFT)
	set(logBuf,uNUMLEFT);
    if (cfg.flags.DEFAUTONEW)
	set(logBuf,uAUTONEW);

    logBuf.lbnulls = 0;
    logBuf.lbwidth = cfg.syswidth;

    /*
     * Now configure ourselves and possibly print password warning
     */
    config('W');			/* terminal width */
    config('E');			/* then expert mode */
    config('Y');			/* default transfer protocol */
    if (readbit(logBuf,uEXPERT)) {	/* if expert, then */
	config('N');			/* nulls */
	config('L');			/* linefeeds */
	config('T');			/* time of messages */
	config('O');			/* last old on [n]ew */
	config('F');			/* floor mode */
	config('P');			/* more mode on message read */
	config('A');			/* auto-new msgs in Lobby> */
	config('R');			/* show (n left) in msg hdr */
	logBuf.lbreadnum = 10;		/* Default for .R<#> */
    }
    else
	(void) blurb("password", NO);

    do {
	/* get name and check for uniqueness... */
	while (onLine()) {
	    if (username[0]) {
		strcpy(nm, username);
		username[0] = 0;
	    }
	    else {
		outFlag = OUTOK;
		getNormStr("What is your name", nm, NAMESIZE, YES);
	    }
	    if (strlen(nm) < 1) {
		killlogBuf(&temp);
		return ERROR;
	    }
	    else if (dorestrict(nm, YES)) {
		killlogBuf(&temp);
		return ERROR;
	    }
	    else if (strpbrk(nm, "@_%!") == 0) {
		h = hash(nm);
		for (i = cfg.logsize - 1; i >= 0; --i)
		    if (h == logTab[i].ltnmhash)
			break;
		if (i < 0 && h != hash("citadel") && h != hash("sysop"))
		    break;
	    }
	    mprintf("We already have a %s\r", nm);
	}

	/* get password and check for uniqueness...	*/
	while (onLine()) {
	    if (password[0]) {
		strcpy(pw, password);
		password[0] = 0;
	    }
	    else {
		echo = NO;
		getNormStr("What is your password", pw, NAMESIZE, YES);
		echo = YES;
	    }
	    if (strlen(pw) < 1) {
		killlogBuf(&temp);
		return ERROR;
	    }
	    if (getpwlog(pw, &temp) == ERROR)
		break;
	    mprintf("Poor password\r");
	}

	mprintf("\rName: %s\r", nm);
	echo = NO;
	mprintf(  "Password: %s\r\r", pw);
	echo = YES;
    } while (!getYesNo("OK") && onLine());

    if (onLine()) {
	logMessage(L_IN, nm, '+');

	/*
	 * grab oldest log entry for the new one.
	 */
	bubblelog(cfg.logsize-1);

	logTab[0].ltpwhash = hash(pw);
	logTab[0].ltnmhash = hash(nm);
	logTab[0].ltnewest = cfg.newest;
	strcpy(logBuf.lbname, nm);
	strcpy(logBuf.lbpw, pw);
	set(logBuf,uINUSE);

	/* If the defined #sysop is signing on, set up default privs */
	if (cfg.sysopName &&
		stricmp(logBuf.lbname,&cfg.codeBuf[cfg.sysopName]) == 0) {
	    set(logBuf,uSYSOP);
	    set(logBuf,uAIDE);
	    set(logBuf,uNETPRIVS);
	    set(logBuf,uMAILPRIV);
	    set(logBuf,uDOORPRIV);
	}
	else {		/* Normal user */
	    if (cfg.flags.ALLNET)
		set(logBuf,uNETPRIVS);
	    else
		clear(logBuf,uNETPRIVS);

	    if (cfg.flags.NOMAIL)
		clear(logBuf,uMAILPRIV);
	    else
		set(logBuf,uMAILPRIV);

	    if (cfg.flags.ALLDOOR)
		set(logBuf,uDOORPRIV);
	    else
		clear(logBuf,uDOORPRIV);
	}

	logBuf.lblast = time(NULL);
	logBuf.lbdownloadlimit = 0L;		/* How many K downloaded */
	logBuf.lbcalls = 0;		/* How many calls today */
	logBuf.lbtime = 0;		/* How many minutes connected today */
	logBuf.lbclosecalls = 0;	/* How many close calls today */

	if (cfg.newusermsgs)
	    low = (cfg.newest - cfg.oldest > cfg.newusermsgs) ?
		(cfg.newest - cfg.newusermsgs) : cfg.oldest;
	else
	    low = cfg.oldest;

	logBuf.lbvisit[0] = cfg.newest;
	for (i=1; i<MAXVISIT-1; i++)
	    logBuf.lbvisit[i] = low;
	logBuf.lbvisit[MAXVISIT-1]= cfg.oldest;

	memset(logBuf.lbmail, 0, MAIL_BULK);
	for (i=0; i<MAXROOMS; i++) {
	    g = roomTab[i].rtgen;
	    if (!readbit(roomTab[i],PUBLIC))
		g = (g+MAXGEN-1) % MAXGEN;
	    logBuf.lbgen[i] = (g << GENSHIFT) + (MAXVISIT-1);
	}
	roomTab[MAILROOM].rtlastMessage = 0L;

	/* cheat -- force* the user to read policy.hlp */
	help("policy", YES);

	killlogBuf(&temp);
	return logTab[0].ltlogSlot;
    }
    killlogBuf(&temp);
    return ERROR;
}

/*
 * login() -- the menu-level routine to log someone in
 */
int
login(char prefix)
{
    LABEL username, password;
    int ltentry;		/* entry in logTab[] */
    long lastmsg, lastcall;

    outFlag = OUTOK;
    if ((cfg.flags.GETNAME)) {
	getNormStr("\rname", username, NAMESIZE, YES);
	if (!username[0])
	    return NO;
    }
    else
	username[0] = '\0';
	
    if (!onLine())	/* fix for login-loop bug?  AA 90Jul27 */
	return NO;

    echo = NO;
    if ((cfg.flags.GETNAME))
	getNormStr("password", password, NAMESIZE, NO);
    else
	getNormStr("\rEnter password (just carriage return if new)", password,
	    NAMESIZE, NO);	/* <- 'prefix' changed to 'NO' by AA 90Jul08 */ 

    echo = YES;

    if (!onLine())	/* added by AA 90Jul27 */
	return NO;

    ltentry = getpwlog(password, &logBuf);
    if ((ltentry!=ERROR) && username[0] && stricmp(logBuf.lbname,username) !=0)
	ltentry = ERROR;

    if (ltentry == ERROR) {		/* must be a new user, then */
	if (strlen(password) > 1 && !onConsole)
	    if (badpw)
		pause(2000);		/* discourage password-guessing */
	    else
		badpw = YES;
	if (!((cfg.flags.LOGINOK) || onConsole)) {
	    outFlag = IMPERVIOUS;
	    if (!blurb("deny", YES))
		mprintf("Bad password.\r");
	    outFlag = OUTOK;
	    if (newuser_door)
		rundoor(newuser_door, NULL);
	    return NO;			/* added by AA 90Feb18 */
	}
	if (!getNo("No record. Enter as new user"))
	    return NO;
	if ((logindex = newuserlogin(username,password)) == ERROR)
	    return NO;
	else
	    if (newuser_door)
		rundoor(newuser_door, NULL);
	today = logBuf.lblast;
    }
    else {
	logindex = logTab[ltentry].ltlogSlot;
	logMessage(L_IN, logBuf.lbname, NO);
	if (dorestrict(logBuf.lbname, NO))
	    return NO;
	bubblelog(ltentry);
	today = time(NULL);
    }

    /*
     * Now that the user is logged in, check various login limitations.
     * First, reduce limits if the last login wasn't today.  For the
     * call and time limits, roll excess usage over to the new call,
     * unless the Sysop has set 'autozerolimit' to set limits to 0 anyway.
     */
    if (DAY(today) != DAY(logBuf.lblast)) {
	logBuf.lbdownloadlimit = 0L;

	if (cfg.maxcalls)
	    logBuf.lbcalls = (cfg.flags.AUTOZEROLIMIT ? 0 :
	    		      MAX(0, logBuf.lbcalls - cfg.maxcalls));
	else
	    logBuf.lbcalls = 0;

	if (cfg.maxtime)
	    logBuf.lbtime = (cfg.flags.AUTOZEROLIMIT ? 0 :
	    			MAX(0, logBuf.lbtime - cfg.maxtime));
	else
	    logBuf.lbtime = 0;

	if (cfg.maxclosecalls)
	    logBuf.lbclosecalls = (cfg.flags.AUTOZEROLIMIT ? 1 :
			MAX(1, logBuf.lbclosecalls - cfg.maxclosecalls));
	else
	    logBuf.lbclosecalls = 1;
    }
    if (cfg.maxcalls) {				/* Track user calls? */
	logBuf.lbcalls++;			/* Another normal call */
	if (!(readbit(logBuf,uAIDE) || onConsole) &&
	    logBuf.lbcalls > cfg.maxcalls) {
	    if (!blurb("maxcalls", YES)) {	/* Too many calls */
		mprintf("\rYou have exceeded the daily call limit of %d calls.\r", cfg.maxcalls);
		mprintf("Call back tomorrow.\r");
	    }
	    terminate(YES, tMAXCALLS);		/* Punt user */
	    return NO;
	}
    }
    if (cfg.maxtime) {				/* Track user connect time? */
	if (!(readbit(logBuf,uAIDE) || onConsole) &&
	    logBuf.lbtime > cfg.maxtime) {
	    if (!blurb("maxtime", YES)) {	/* Too much time */
		mprintf("\rYou have exceeded the daily connect-time limit of %d minutes.\r", cfg.maxtime);
		mprintf("Call back tomorrow.\r");
	    }
	    terminate(YES, tMAXTIME);		/* Punt user */
	    return NO;
	}
    }
    if (cfg.maxclosecalls && cfg.closetime) {	/* Track user close calls? */
	short	gap = MINUTE(today) - MINUTE(logBuf.lblast);

	if (gap >= 0 && gap <= cfg.closetime) {	/* It's a close call */
	    logBuf.lbclosecalls++;
	    if (!(readbit(logBuf,uAIDE) || onConsole) &&
		logBuf.lbclosecalls > cfg.maxclosecalls) {
		if (!blurb("maxclose", YES)) {	/* Too many */
		    mprintf("\rYou have too many closely-grouped calls.  ");
		    mprintf("(Calls which are less than %d minutes apart);",
			cfg.closetime);
		    mprintf("the current limit is %d calls.  ",
			cfg.maxclosecalls);
		    mprintf("Call back tomorrow.\r");
		}
		terminate(YES, tMAXCLOSECALLS);		/* Punt user */
		return NO;
	    }
	}
    }

    /* User got past all login limits, so log him in for real. */
    loggedIn = YES;
    logBuf.lblast = today;		/* Update last call time */
    highlogin = cfg.newest;		/* set `high msg at login' variable */

    oldcatChar = cfg.catChar;		/* Record message file pointers in  */
    oldcatSector = cfg.catSector;	/* case we need to purge user msgs. */

    memcpy(&origlogBuf, &logBuf, LB_SIZE);
    memcpy(origlogBuf.lbgen, logBuf.lbgen, GEN_BULK);
    memcpy(origlogBuf.lbmail, logBuf.lbmail, MAIL_BULK);

    setlog();
    strcpy(marktime, tod(YES));		/* set time of login for status line */
    /*
     * reset event trigger because a user might have logged in within the
     * 5 minute warning period
     */
    if (evtRunning && isPreemptive(nextEvt)) {
	evtTrig = 300L;
	warned = NO;
    }

    if (login_door)
	rundoor(login_door, NULL);
    (void) blurb("notice", NO);
    doinherit();			/* check for ruggie inheritance */

    /* Print out new messages in the lobby if the user wants it. */
    if (readbit(logBuf, uAUTONEW))
	doRead(NO, 3, '\n');

    listRooms(readbit(logBuf,uEXPERT) ? l_NEW : (l_NEW|l_OLD));
    if (readbit(logBuf,uFLOORMODE))	/* list floors for him too, if he */
	listFloor(l_NEW|l_EXCL);	/* wants us to. */

    lastmsg = MAILNUM(logBuf.lbmail[MAILSLOTS - 1].msgno);
    lastcall = logBuf.lbvisit[logBuf.lbgen[MAILROOM] & CALLMASK];
    if (lastmsg > lastcall && lastmsg > cfg.oldest && thisRoom != MAILROOM)
	mprintf("\r * You have private mail in Mail> * ");

    if (heldMessage = chkhold(logindex))
	iprintf("\r* You have a held message *\r");

    doCR();
    statroom();

    return YES;				/* Thuh End. */
}

/*
 * setlog() - initialize logBuf for logged & unlogged people
 */
void
setlog(void)
{
    int g, i, j;

    remoteSysop = NO;		/* no sysop functions for you, boyo */
    lastRoom = -1;		/* no backing up, either */
    getRoom(thisRoom);		/* reload room pointers for you */

    for (i=0; i < MAXROOMS; i++)
	indices[i].visited = iNEVER;

    if (loggedIn) {
	/*
	 * set gen on all unknown rooms  --  INUSE or no
	 */
	for (i=0; i < MAXROOMS; i++) {
	    if (!readbit(roomTab[i],PUBLIC)) {
		/*
		 * it is private -- is it unknown?
		 */
		if ((LBGEN(logBuf,i) != roomTab[i].rtgen) ||
			     (!readbit(logBuf,uAIDE) && i == AIDEROOM) ) {
		    /*
		     * yes -- set gen = (realgen-1) % MAXGEN
		     */
		    j = (roomTab[i].rtgen + (MAXGEN-1)) % MAXGEN;
		    logBuf.lbgen[i] = (j << GENSHIFT) + (MAXVISIT-1);
		}
	    }
	    else if (LBGEN(logBuf,i) != roomTab[i].rtgen)  {
		/*
		 * newly created public room -- remember to visit it
		 */
		j = roomTab[i].rtgen - (logBuf.lbgen[i] >> GENSHIFT);
		if (j < 0)
		    g = -j;
		else
		    g = j;
		if (g != FORGET_OFFSET)
		    logBuf.lbgen[i] = (roomTab[i].rtgen << GENSHIFT) +1;
	    }
	}
	/*
	 * mark mail> for new private mail.
	 */
	roomTab[MAILROOM].rtlastMessage = 
		MAILNUM(logBuf.lbmail[MAILSLOTS-1].msgno);
	/*
	 * slide lbvisit array down and change lbgen entries to match
	 */
	for (i=MAXVISIT-1; i > 0; i--)
	    logBuf.lbvisit[i] = logBuf.lbvisit[i-1];

	for (i=0; i < MAXROOMS; i++) {
	    if ((logBuf.lbgen[i] & CALLMASK) < MAXVISIT-2)
		logBuf.lbgen[i]++;
	    indices[i].lastgen = logBuf.lbgen[i];
	}
    }
    else {
	/* Following changed from a zero_struct(logBuf) call by AA 90Jan31 */
	memset(&logBuf, 0, LB_SIZE);
	memset(logBuf.lbgen, 0, GEN_BULK);
	memset(logBuf.lbmail, 0, MAIL_BULK);

	logBuf.lbwidth = cfg.syswidth;
	logBuf.lbclosecalls = 1;
	set(logBuf,uSHOWTIME);
	set(logBuf,uLINEFEEDS);
	set(logBuf,uMAILPRIV);

	/*
	 * set up logBuf so everything is new...
	 */
	for (i=0; i<MAXVISIT; i++)
	    logBuf.lbvisit[i] = cfg.oldest;
	/*
	 * no mail messages for anonymous folks
	 */
	roomTab[MAILROOM].rtlastMessage = cfg.newest;

	for (i = 0; i < MAXROOMS;  i++) {
	    g = roomTab[i].rtgen;
	    if (!readbit(roomTab[i],PUBLIC))
		g = (g+MAXGEN-1) % MAXGEN;
	    indices[i].lastgen = logBuf.lbgen[i]
			       = (g << GENSHIFT) + (MAXVISIT-1);
	}
    }
    logBuf.lbvisit[0] = cfg.newest;
}

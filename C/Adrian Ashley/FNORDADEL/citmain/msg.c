/*
 * msg.c -- message handling for Citadel bulletin board system
 */

/*
 * 90Nov03 AA	This msg.c replaces old Fnordadel msg.c; lots of munging.
 * 89Mar30 orc	printdraft() moved in from room.c
 * 88Nov24 orc	New rn interface installation.
 * 88Jul16 orc	Add [C]opy command.
 * 88Jun01 orc	revamped net-message posting routines
 * 88May29 orc	check for read-from-date added to monster read-message loop
 * 88Feb13 orc	msgToDisk() cleaned up, moved to libmsg.c
 * 87Sep08 orc	msg1.c reintegrated.
 * 87Aug15 orc	put low-level functions into libmsg.c
 * 87Apr22 orc	Allow name@system to addresses in mail
 * 87Mar30 orc	anonymous room support.
 * 87Jan22 orc	have mPeek() "--more--" after each screenful.
 * 87Jan18 orc	change the messagebase to use 4K sectors.
 * 87Jan17 orc	remove all uchar references & clean up sign extention problems.
 * 86Dec27 orc	68K, the saga continues.
 *	.
 *	.
 *	.
 * 82Nov03 CrT	Individual history begun.  General cleanup.
 */

#include "ctdl.h"
#include "net.h"
#include "protocol.h"
#include "dateread.h"
#include "editor.h"
#include "msg.h"
#include "log.h"
#include "room.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"

/*
 * externally visible functions defined here:
 *
 * mAbort()		Did someone [N]/[P]/[S]?
 * printdraft()		prints a message+header
 * permission()		Can we enter a net message?
 * addressee()		get an addressee for netmail
 * promote()		turn a message into a net message
 * entermesg()		enter a message
 * heldmesg()		enter a held message
 * localmesg()		enter a local message
 * nettedmesg()		enter a networked message
 * pick1mesg()		picks out a message
 * read1mesg()		reads a single message
 * msgbrk()		return msg[] index of 1st msg above lim
 * showMessages()	print a roomful of msgs
 */

char    outFlag = OUTOK;		/* current output mode		*/
char	heldMessage;
LABEL	oldTarget;
char	*program = "Citadel";

int	*msgsentered;			/* msgs entered per room this call */

static char	pullMessage;		/* true to pull current message	*/
static char	journalMessage;		/* true to journal current message */
static char	pMESS = 0;		/* inside a message for mAbort */

int justLocals;		/* local messages only? */
int singleMsg;		/* pause after each message for N/S */
LABEL msguser;		/* display messages from/to this user */

static int msgNo;	/* for deleting messages */
static short r1_loc;
static long r1_id;

/*
 * codes that can be returned from the more interface
 */
#define	rSTOP	  0	/* stop reading       */
#define	rNEXT	  1	/* read next message  */
#define	rBACK	  2	/* read prev message  */
#define rAGAIN	  3	/* read me again      */
#define	rNUKE	  4	/* deleted the mesg   */
#define	rCOMMENT  5	/* reply to mesg      */
#define	rHELD	  6	/* continue held mesg */
#define rPROMOTE  7	/* promote msg to net */

static int
candelete(void)
{
    register int i = MAILSLOTS - 1;

    /*
     * Aides & Sysops can delete anything (except Mail TO them);
     * message authors can delete their messages during their current login;
     * and message authors can delete Mail before it has been read.
     */

#if 0	/* The old code */
    cd = (readbit(logBuf,uAIDE)
	  || (!stricmp(logBuf.lbname,msgBuf.mbauth) && (highlogin < msgNo))
	  || (!stricmp(logBuf.lbname,msgBuf.mbauth)
		&& (thisRoom == MAILROOM)
		&& readbit(msgBuf,mMAILRECEIVED)
	     )
	 );
    return cd;
#else
    if ((readbit(logBuf,uAIDE) && thisRoom != MAILROOM)
	|| (!stricmp(logBuf.lbname,msgBuf.mbauth)
	    && (highlogin < roomBuf.msg[msgNo].msgno)
 	   )
	)
	return YES;
    else if (!stricmp(logBuf.lbname,msgBuf.mbauth) && (thisRoom == MAILROOM)) {
	while (i > -1 && MAILNUM(logBuf.lbmail[i].msgno) != msgBuf.mbid)
	    i--;
	if ((i == -1) || ((i > -1) && (logBuf.lbmail[i].msgno & RECEIVED)))
	    return NO;
	else
	    return YES;
    }
    return NO;
#endif
}

/*
 * ab_process() -- sets output control depending on a [p] or more: response
 */
static int
ab_process(int c)
{
    switch (c) {
    case 'J':   outFlag = OUTPARAGRAPH; break;		/* [J]ump paragraph */
    case 'D':   if (pMESS && (pullMessage = candelete())) {
		    outFlag = OUTOK;			/* delete message */
		    return YES;
		}
		break;
    case 'N':   outFlag = OUTNEXT; return YES;		/* [N]ext message */

    case 'Q':
    case 'S':   outFlag = OUTSKIP; return YES;		/* [S]top reading */

    case 'B':						/* previous message */
    case 'A':	if (pMESS) {				/* [A]gain   */
		    pMESS = c;
		    outFlag = OUTAGAIN;
		    return YES;
		}
    }
    return NO;
}

/*
 * mAbort() -- returns YES if the user has aborted typeout
 */
int
mAbort(void)
{
    char c;

    /* Check for abort/pause from user */
    if (outFlag != OUTOK)
	return NO;
    else if (BBSCharReady()) {
	c = getnoecho();
	if (c == N0_KEY && receive(1) == N1_KEY && receive(1) == N2_KEY) {
	    if (netAck()) {	/* try 60 seconds to confirm netting	*/
		OutOfNet();
		outFlag = OUTSKIP;
		return YES;
	    }
	    mflush();
	}
	else if ((c=toupper(c)) == 'P')
	    if ((c=toupper(getnoecho())) == 'J' && pMESS) {
		journalMessage = SomeSysop();
		return NO;
	    }
	if (ab_process(c))
	    return YES;
    }
    else if (haveCarrier && !gotcarrier())
	modIn();		/* Let modIn() report the problem	*/
    return NO;
}

/*
 * printdraft() -- print a message in progress
 */
int
printdraft(void)
{
    putheader(0);
    mformat(msgBuf.mbtext);
    return outFlag;
}

/*
 * fakefullcase() -- converts a message in uppercase-only to a reasonable mix.
 *
 * Algorithm: First alphabetic after a period is uppercase, all others are
 * lowercase, excepting pronoun "I" is a special case.  We assume an
 * imaginary period preceding the text.
 */
static void
fakefullcase(register char *text)
{
    register char firstin;

    for (firstin=YES; *text; ++text)
	if (*text == '.' || *text == '!' || *text == '?')
	    firstin = YES;
	else if (isalpha(*text)) {
	    if (*text == 'i' && isspace(text[-1]) && !isalpha(text[1]))
		*text = 'I';
	    else
		*text = firstin ? toupper(*text) : tolower(*text);
	    firstin = NO;
	}
}

/*
 * deletemail() - nuke a message from Mail>.  Danged complicated!
 */
static int
deletemail(int m)
{
    FILE *mail, *mail2, *safeopen();
    LABEL node;
    PATHBUF fn, fn2;
    char temp[80];
    int i, j, logidx, found = NO;
    long id;
    struct logBuffer lbuf2;
    char *notdel1 = "\rThe mail has already been sent; not deleted.\r";

    /* FIRST: Check if the message was netmail. If so, find it in the .ml file
       and remove it.  If it isn't found, it was sent: don't bother deleting
       from logBuf. */

    if (parsepath(msgBuf.mbto, node, NO)) {
	i = srchNetNm(node);
	if (i == ERROR) {
	    mprintf("\rCan't find net node %s; mail not deleted.\r", node);
	    return NO;
	}
	ctdlfile(fn, cfg.netdir, "%d.ml", i);
	if ((mail = safeopen(fn, "r")) == NULL) {
	    if (Debug)
		xprintf("Can't find mail file %d.ml, node %s.\n", i, node);
	    mprintf(notdel1);
	    return NO;
	}
	ctdlfile(fn2, cfg.netdir, "tmp.ml");
	if ((mail2 = safeopen(fn2, "w")) == NULL)
	    crashout("Cannot open temp mail deletion file");
	while (fgets(temp, 80, mail))
	    if ((sscanf(temp, "%ld", &id) == 1) && (id != pullMId))
		fputs(temp, mail2);
	    else
		found = YES;
	fclose(mail);
	fclose(mail2);
	if (!found) {
	    mprintf(notdel1);
	    dunlink(fn2);
	    return NO;
	}
	else {
	    dunlink(fn);
	    drename(fn2, fn);
	}
    }

    /* NEXT: Delete the message from the current (IE: author's) logBuf */
    for (i=m; i>0; i--) {
	logBuf.lbmail[i].msgloc = logBuf.lbmail[i-1].msgloc;
	logBuf.lbmail[i].msgno  = logBuf.lbmail[i-1].msgno;
    }
    logBuf.lbmail[0].msgno  = 0L;
    logBuf.lbmail[0].msgloc = 0 ;
    putlog(&logBuf, logindex, logfl);
    update_mail();	/* make Mail> room reflect logBuf! -- AA 90Jul20 */

    /* LAST: Delete the message from the recipient's logBuf, if found */
    initlogBuf(&lbuf2);
    if ((logidx = getnmlog(msgBuf.mbto, &lbuf2, logfl)) != ERROR) {
	for (j=MAILSLOTS-1; ((j>-1) && 
		(MAILNUM(lbuf2.lbmail[j].msgno) != pullMId)); j--)
	    /* nothing */ ;
	if (j>=0) {		/* Message found, so delete it */
	    for (i=j; i>0; i--) {
		lbuf2.lbmail[i].msgloc = lbuf2.lbmail[i-1].msgloc;
		lbuf2.lbmail[i].msgno  = lbuf2.lbmail[i-1].msgno;
	    }
	    lbuf2.lbmail[0].msgno  = 0L;
	    lbuf2.lbmail[0].msgloc = 0 ;
	    putlog(&lbuf2, logidx, logfl);
	}
    }
    killlogBuf(&lbuf2);
    return YES;
}

/*
 * copymessage() -- Moves a message for pullmessage()
 */
static int
copymessage(int m, int mode)
{
    LABEL blah;
    int   i, roomTarg, ourRoom = thisRoom;

    if (mode == 'M' || mode == 'C') {
	iprintf("%s to (C/R=`%s')? ", (mode=='M') ? "Move" : "Copy", oldTarget);
	getString("", blah, 20, ESC, YES);
	if (blah[0] == ESC || !onLine())
	    return NO;
	if (strlen(blah) == 0)
	    strcpy(blah, oldTarget);

	/* The 'YES' parameter to canEnter means, 'let the user specify a full
	   room name that is public but Zed'. */
	if ((roomTarg = roomExists(blah)) == ERROR || !canEnter(roomTarg,YES)) {
	    if ((roomTarg = partialExist(blah)) == ERROR) {
		iprintf("`%s' does not exist.\r", blah);
		return NO;
	    }
	    else {
		thisRoom = roomTarg;
		if (partialExist(blah) != ERROR) {
		    thisRoom = ourRoom;
		    iprintf("`%s' is ambiguous.\r", blah);
		    return NO;
		}
		thisRoom = ourRoom;
	    }
	}
	if (roomTarg == MAILROOM) {
	    iprintf("Sorry, can't %s messages to Mail>.\r",
		(mode=='M') ? "move" : "copy");
	    return NO;
	}
	strcpy(oldTarget, roomTab[roomTarg].rtname);
	mprintf("%s message to %s - ", (mode == 'M' ? "move" : "copy"),
		oldTarget);
	if (!getNo(confirm))
	    return NO;
    }
    else {
	iprintf("Delete- ");
	if (thisRoom == AIDEROOM) {
	    iprintf("Can't delete messages from Aide>.\r");
	    return NO;
	}
	if (!getNo(confirm))
	    return NO;
    }

    pullMLoc = roomBuf.msg[m].msgloc;
    pullMId  = roomBuf.msg[m].msgno ;

    if (mode != 'C') {
	/*
	 * delete the message from this room.
	 */
	if (thisRoom == MAILROOM) {
	    if (!deletemail(m))
		return NO;
	}
	else {
	    for (i = m; i < NUMMSGS - 1; i++) {
		roomBuf.msg[i].msgloc = roomBuf.msg[i + 1].msgloc;
		roomBuf.msg[i].msgno = roomBuf.msg[i + 1].msgno;
	    }
	    NUMMSGS--;
	    roomBuf.msg = (theMessages *) realloc(roomBuf.msg, MSG_BULK);
	}
    }
    noteRoom();
    putRoom(ourRoom);

    if (mode != 'D') {
	getRoom(roomTarg);
	note2Message(pullMId, pullMLoc);
	noteRoom();
	putRoom(thisRoom);
/* Archive the moved/copied message. Code snipped from notemessage() by
   RH/AA 90Oct22. */
	if (readbit(roomBuf,ARCHIVE)) {
	    char *fn;

	    if ((fn = findArchiveName(thisRoom)) == NULL) {
		sprintf(msgBuf.mbtext, "Archive error in `%s'.",roomBuf.rbname);
		aideMessage(NO);
	    }
	    else {
		findMessage(pullMLoc, pullMId);
		getmsgstr(msgBuf.mbtext, MAXTEXT);
		msgToDisk(fn);
	    }
	}
	getRoom(ourRoom);
	sprintf(msgBuf.mbtext, "Following message %sed from %s> to %s> by %s",
			    (mode=='M') ? "mov" : "copi",
			    roomBuf.rbname, oldTarget, uname());
    }
    else
	sprintf(msgBuf.mbtext, "Following message deleted from %s> by %s",
			    roomBuf.rbname, uname());

    /* Don't put Mail> or anon msg in Aide> */
    if ((thisRoom == MAILROOM) || readbit(msgBuf,mANONMESSAGE))
	aideMessage(NO);
    else
	aideMessage(YES);
    iprintf("Done.\r");
    return YES;
}


/*
 * permission() -- tells us whether we've got net-privs
 */
int
permission(int complain)
{
    char isnetroom = (thisRoom==MAILROOM || readbit(roomBuf,SHARED));

    if (isnetroom && (readbit(roomBuf,AUTONET) || readbit(logBuf,uNETPRIVS)))
	return YES;
    if (complain)
	mprintf(isnetroom ? "You don't have net privileges\r"
			  : "This is not a net-room\r");
    return NO;
}

/*
 * chkaddress() -- makes sure we can deliver this message
 */
extern char Misvalid;		/* for putmessage() caching... */
extern char Mlocal;		/* are we a local message */
extern int  Mindex;		/* if so, logidx, else netidx */
extern int  Mcost;		/* cost for netmesg */

static int
chkaddress(struct logBuffer *who, int *logp)
{
    LABEL temp;
    char *plural();

    *logp = ERROR;
    if (thisRoom != MAILROOM)
	return YES;
#if 0
    if (Debug)
	splitF(debuglog, "chkaddress: Misvalid == %d, Mlocal == %d, Mindex \
== %d\n", Misvalid, Mlocal, Mindex);
#endif
    if (Misvalid) {
	if (Mlocal && Mindex != ERROR) {
#if 0
	    if (Debug)
		splitF(debuglog, "chkaddress: calling getlog(%d)\n", Mindex);
#endif
	    getlog(who, (*logp)=Mindex, logfl);
	}
	return YES;
    }
    if (parsepath(msgBuf.mbto, temp, NO)) {
	if (permission(NO) && (Mindex = findnode(temp, &Mcost)) != ERROR) {
	    if (Mcost <= logBuf.credit || SomeSysop()) {
		Mlocal = NO;
		set(msgBuf,mNETMESSAGE);
		return Misvalid=YES;
	    }
	    mprintf("You need %s to mail this.\r",
		plural("credit", (long)(Mcost)));
	    return Misvalid=NO;
	}
    }
    else if ( (stricmp(msgBuf.mbto, logBuf.lbname) == 0) || 
	      ( (cfg.sysopName) &&
	        (stricmp(logBuf.lbname, &cfg.codeBuf[cfg.sysopName]) == 0) &&
	        (stricmp(msgBuf.mbto, "Sysop") == 0)
	      )
	    ) {
	mprintf("Not to yourself!\r");
        return Misvalid=NO;
    }
    else if ((readbit(logBuf,uAIDE) && stricmp(msgBuf.mbto, program)==0) ||
		(stricmp(msgBuf.mbto, "Sysop") == 0)) {
	Mindex = ERROR;
	Mlocal = YES;
	return Misvalid=YES;
    }
    else if (((*logp) = Mindex = getnmlog(msgBuf.mbto,who,logfl)) != ERROR) {
	strcpy(msgBuf.mbto, who->lbname);	/* To set proper case, etc. */
	Mlocal = YES;
	return Misvalid=YES;
    }
    mprintf("Cannot deliver mail to `%s'.\r", msgBuf.mbto);
    return Misvalid=NO;
}

/*
 * addressee() -- gets a net address from the caller
 */
int
addressee(int netflag)
{
    char *p,*s;
    LABEL system;
    struct logBuffer person;
    int logno, temp;

    if (!netflag)
	system[0] = 0;
    else if (getSysName("System", system) == ERROR)
	return NO;

    if (!msgBuf.mbto[0])
	getNormStr("To", msgBuf.mbto, ADDRSIZE, YES);

    if (msgBuf.mbto[0]) {
	if (msgBuf.mbto[0] == '@')
	    return NO;

	/* The purpose of this mummery is to eliminate stuff like
	   "somebody @somewhere", replacing it with the correct
	   "somebody@somewhere". */
	if (p = strchr(msgBuf.mbto, '@')) {
	    s = p--;
	    while (*p == ' ')
		--p;
	    if (s != ++p) {
		while (*s)
		    *p++ = *s++;
		*p = '\0';
	    }
	}

	if (system[0])
	    sprintf(ENDOFSTR(msgBuf.mbto), "@%s", system);
	initlogBuf(&person);
	temp = chkaddress(&person, &logno);
	killlogBuf(&person);
	return temp;
    }
    return NO;
}

/*
 * promote() -- converts a message into a net-message
 */
void
promote(void)
{
    strcpy(msgBuf.mboname, &cfg.codeBuf[cfg.nodeName]);
    strcpy(msgBuf.mborg,   &cfg.codeBuf[cfg.organization]);
    strcpy(msgBuf.mbroute, "@O");
    strcpy(msgBuf.mbdomain, &cfg.codeBuf[cfg.domain]);
    set(msgBuf,mNETMESSAGE);
}

/*
 * default_netted() -- this macro defines when a message should default to net.
 *
 * Currently, this is when the room is
 *	(a) Autonet, or
 *	(b) Shared AND the user has net privs.
 */
#define default_netted() \
(readbit(roomBuf,AUTONET)||(readbit(logBuf,uNETPRIVS)&&readbit(roomBuf,SHARED)))

/*
 * createmesg() -- sets up for entering a message
 */
static int
createmesg(char *to, int netflag, int isreply)
{
    zero_struct(msgBuf);
    if (thisRoom == MAILROOM) {
	if ( !(loggedIn && (readbit(logBuf,uAIDE) || !(cfg.flags.NOMAIL)))) {
	    strcpy(msgBuf.mbto, "Sysop");
	    netflag = NO;
	}
	else if (to)
	    copystring(msgBuf.mbto, to, ADDRSIZE);
	if (!addressee(netflag))
	    if (isreply && SomeSysop()) {	/* Give Sysops 2nd try */
		msgBuf.mbto[0] = 0;		/* But only during [R]eply */
		if (!addressee(netflag))
		    return NO;
	    }
	    else				/* Normal users get one try */
		return NO;
    }
    else if (netflag && readbit(roomBuf,SHARED))
	promote();
    if (loggedIn)
	strcpy(msgBuf.mbauth, logBuf.lbname);
    if (readbit(roomBuf,ANON))
	set(msgBuf,mANONMESSAGE);
    return YES;
}

/*
 * bodymesg() is the guts of the enter-a-message system
 */
static int
bodymesg(int protocol)
{
    struct logBuffer who;
    char *pc;
    int logno, temp;
#undef toupper

    if (getText(protocol, eMESSAGE)) {	/* in orc's code this was a call to memo() */
	for (pc=msgBuf.mbtext; *pc; ++pc)
	    if (toupper(*pc) != *pc)
		break;
	if (!*pc)
	    fakefullcase(msgBuf.mbtext);
	initlogBuf(&who);
	/* If this message gets saved, it'll have an ID one greater than */
	/* the current newest.  If not, who cares? */
	msgBuf.mbsrcid = 1+cfg.newest;
#if 0
	if (Debug)
	    splitF(debuglog, "bodymesg: Misvalid == %d, Mlocal == %d, Mindex \
== %d\n", Misvalid, Mlocal, Mindex);
#endif
	temp = (chkaddress(&who, &logno) && storeMessage(&who, logno));
	killlogBuf(&who);
	if (temp) {
	    msgsentered[thisRoom]++;	/* add another one to the list */
	    return YES;
	}
    }
    Misvalid = NO;
    return NO;
}

/*
 * entermesg() is for the [e] command
 */
int
entermesg(int protocol)
{
    if (!createmesg(NULL, default_netted(), NO))
	return NO;

    return bodymesg(protocol);
}

/*
 * replymesg() is for mail and/or .read more
 */
static int
replymesg(void)
{
    char *author = NULL;
    NETADDR returnto;

    if (!(readbit(logBuf,uAIDE) || onConsole) &&
	 (	((thisRoom != MAILROOM) && cfg.maxmsgs &&
			(msgsentered[thisRoom] >= cfg.maxmsgs)) ||
		((thisRoom == MAILROOM) && cfg.maxmailmsgs &&
			(msgsentered[thisRoom] >= cfg.maxmailmsgs))
	 )
       ) {
	if (!blurb("maxmsg", YES))
	    mprintf("\rSorry, you have reached the limit of %d messages.\r",
		(thisRoom != MAILROOM) ? cfg.maxmsgs : cfg.maxmailmsgs);
	    return NO;
    }

    if (thisRoom == MAILROOM) {
	/*
	 * get the return address all set up
	 */
	strcpy(returnto, msgBuf.mbauth);
	if (msgBuf.mboname[0])
	    sprintf(ENDOFSTR(returnto), "@%s", msgBuf.mboname);
	author = returnto;
    }
    return createmesg(author, default_netted(), YES)
		     ? bodymesg(ASCII)
		     : NO;
}

/*
 * heldmesg() continues a held message
 */
int
heldmesg(int protocol)
{
    extern int logindex;

    Misvalid = heldMessage = NO;
    if (gethold(logindex)) {
	/*
	 * wipe out previous netting flags
	 */
	if (msgBuf.mboname[0]) {
	    if (thisRoom == MAILROOM || !permission(NO)) {
		msgBuf.mboname[0] = msgBuf.mborg[0] =
		msgBuf.mborig[0]  = msgBuf.mbroute[0] =
		msgBuf.mbdomain[0] = 0;
		clear(msgBuf,mNETMESSAGE);
	    }
	}
	else if (thisRoom != MAILROOM && default_netted())
	    promote();

	if (loggedIn)
	    strcpy(msgBuf.mbauth, logBuf.lbname);

	/*
	 * do we need a to: address?
	 */
	if (thisRoom == MAILROOM) {
	    if (!addressee(NO)) {
		heldMessage = puthold(logindex);
		return NO;
	    }
	}
	else msgBuf.mbto[0] = 0;
	/*
	 * then just start reediting
	 */
	return bodymesg(protocol);
    }
    return NO;
}

/*
 * localmesg() is for forcing a local message from the word go
 */
int
localmesg(int protocol)
{
    if (createmesg(NULL, NO, NO))
	return bodymesg(protocol);
    return NO;
}

/*
 * nettedmesg() is for forcing a net-message from the word go
 */
int
nettedmesg(int protocol)
{
    if (permission(YES) && createmesg(NULL, YES, NO))
	return bodymesg(protocol);
    return NO;
}

/*
 * printaword() takes a word off disk and prints it out
 */
static CACHE = 0;

static int
printaword(void)
{
    register c, i=0;

    if (CACHE)
	c = CACHE;
    else
	while ((c=getmsgchar()) && c <= ' ')
	    msgBuf.mbtext[i++] = c;

    for (; c > ' '; c=getmsgchar())
	msgBuf.mbtext[i++] = c;

    for (; c && c <= ' '; c=getmsgchar())
	msgBuf.mbtext[i++] = c;

    msgBuf.mbtext[i] = 0;

    printword(msgBuf.mbtext);
    mAbort();
    return (CACHE=c);
}

/*
 * _delete() a message
 */
static int
_delete(void)
{
    register c;
    char *okchars, *prompt;

    pullMessage = NO;
    okchars = (readbit(logBuf,uAIDE) ? "ACDM" : "AD");
    prompt  = (readbit(logBuf,uAIDE) ? "[A]bort, [C]opy, [D]elete, [M]ove" :
		"[A]bort, [D]elete");
    while (onLine()) {
	iprintf("\r%s: ", prompt);
	c = toupper(getnoecho());
	if (strchr(okchars, c) == NULL && c != SPECIAL) {
	    oChar(BELL);
	    continue;
	}
	if ((c == 'D' || c == 'M' || c == 'C') && copymessage(msgNo, c))
	    return YES;
	else if (c == SPECIAL || c == 'A')
	    break;
    }
    doCR();
    return NO;
}
    
/*
 * msgprintmsg() -- finds, loads, and prints a message
 */
static void
msgprintmsg(void)
{
    findMessage(r1_loc, r1_id);
    getmsgstr(msgBuf.mbtext, MAXTEXT);
    printdraft();
    doCR();
}
    
/*
 * _journal() a message
 */
static void
_journal(void)
{
    if (sendARinit()) {
	msgprintmsg();
	sendARend();
    }
    journalMessage = NO;
}

/*
 * _mutate() -- promote a message from local to net
 */
static int
_mutate(void)
{
    findMessage(r1_loc, r1_id);	/* Grab the message */
    getmsgstr(msgBuf.mbtext, MAXTEXT);

    promote();			/* fill in network fields in msgBuf */
    msgBuf.mbsrcid = 1+cfg.newest;

    return (storeMessage(NULL, ERROR));
#if 0	/* TODO: figure out a clean way to handle this in displaymesg() */
    copymessage(msgNo, 'D');	/* delete current message */
#endif
}

/*
 * markreceived() -- mark a mail message as having been read by the recipient
 */
static void
markreceived(void)
{
    register int i = msgNo;	/* msgNo is global index into the reader's */
				/* lbmail array of the message being read */
    struct logBuffer lbuf2;
    int logidx, j;

    if (thisRoom != MAILROOM)	/* Sanity, anyone? */
	return;

    /* Mark if reader is recipient and not already marked */
    if (!stricmp(msgBuf.mbto,logBuf.lbname)
		&& !(logBuf.lbmail[i].msgno & RECEIVED)) {

	/* Mark is reader's logBuf */
	logBuf.lbmail[i].msgno |= RECEIVED;
	putlog(&logBuf, logindex, logfl);

	/* Mark as received in sender's logBuf also, if found */
	initlogBuf(&lbuf2);
	if ((logidx = getnmlog(msgBuf.mbauth,&lbuf2,logfl)) != ERROR) {
	    for (j = MAILSLOTS - 1;
		 ((j > -1) &&
		  (MAILNUM(lbuf2.lbmail[j].msgno) !=
					MAILNUM(logBuf.lbmail[i].msgno)));
		j--)
		/* nothing */;
	    if (j >= 0) {
		lbuf2.lbmail[j].msgno |= RECEIVED;
		putlog(&lbuf2, logidx, logfl);
	    }
	}
	killlogBuf(&lbuf2);
    }
}

/*
 * canreply() -- valid to reply to this message?
 */
static int
canreply(void)
{
    NETADDR replyaddr;
    NETADDR node;
    int cost;

    if (loggedIn) {
	if (thisRoom == MAILROOM) {
	    if (msgBuf.mbauth[0]) {
		if (stricmp(logBuf.lbname,msgBuf.mbauth) == 0) {
		    mprintf("Not to yourself!\r");
		    return NO;
		}
		else if (stricmp(msgBuf.mbauth, program) == 0) {
		    mprintf("Not to `%s'!\r", program);
		    return NO;
		}
		strcpy(replyaddr, msgBuf.mbauth);	/* Get reply path */
		if (msgBuf.mboname[0])
		    strcpy(node, msgBuf.mboname);	/* Get origin node */
		else if (!parsepath(replyaddr, node, NO))	/* Net-mail? */
		    return YES;				/* No, let it go */
		if (findnode(node, &cost) == ERROR && !SomeSysop()) {
		    mprintf("No known node `%s'.\r", node);
		    return NO;
		}
		else if (cost > logBuf.credit && !SomeSysop()) {
		    mprintf("You don't have enough net credits.\r");
		    return NO;
		}
		else	/* Let Sysops reply even if 0 creds or unknown node */
		    return YES;
	    }
	}
	else if (readbit(logBuf,uAIDE) || !readbit(roomBuf,READONLY))
	    return YES;
	else {
	    mprintf("This room is read-only.\r");
	    return NO;
	}
    }
    mprintf("You must log in first.\r");
    return NO;
}

static int
canpromote(void)
{
    if (SomeSysop()) {
	if (thisRoom == MAILROOM) {
	    iprintf("can't do this in Mail> yet.\r");
	    return NO;
	}
	if (!readbit(roomBuf,SHARED)) {
	    iprintf("not a shared room!\r");
	    return NO;
	}
	if (readbit(msgBuf,mNETMESSAGE)) {
	    iprintf("already a net message!\r");
	    return NO;
	}
	return YES;
    }
    return NO;
}
/*
 * tailmesg() -- do processing at the end of a message
 */
static int
tailmesg(int canbackup)
{
    int c;
    char *formRoom();

    if (thisRoom == MAILROOM && !TheSysop())
	markreceived();

    if (journalMessage)
	_journal();

    if (pullMessage) {
#if 0
	msgprintmsg();		/* reprint the message just to be sure */
#endif
	if (_delete())		/* and kill the puppy off. */
	    return rNUKE;
    }
    if (singleMsg) {
prompt: iprintf("\rMore cmd%s: ", readbit(logBuf,uEXPERT) ? "" :
	    " ([N]ext, [R]eply, e[X]it, [?]=menu)");
	while (onLine()) {
	    switch (c=toupper(getnoecho())) {
	    case 'A': iprintf("Again\r");		return rAGAIN;
	    case ' ':
	    case '\n':
	    case 'N': iprintf("Next\r");		return rNEXT;
	    case HUP:
	    case 'S':
	    case 'Q':
	    case 'X': iprintf("Exit\r\r");		return rSTOP;
	    case 'R':
		    if (canreply()) {
			iprintf("Reply\r");
			return rCOMMENT;
		    }
		    goto prompt;
	    case 'H':
		    if (heldMessage && (msgBuf.mbto[0] || canreply())) {
			iprintf("Continue held\r");
			return rHELD;
		    }
		    else if (!heldMessage)
			iprintf("No held message.\r");
		    goto prompt;
	    case 'M':		/* mark as received */
		    if (TheSysop() && thisRoom == MAILROOM) {
			iprintf("Mark as received\r");

			if (stricmp(msgBuf.mbto, logBuf.lbname) != 0)
			    iprintf("Nope, it isn't to you.\r");
			else {
			    markreceived();
			    iprintf("Message marked.\r");
			}
			goto prompt;
		    }
		    break;
	    case 'D':
		    if (candelete()) {
			iprintf("Delete\r");
			if (_delete())
			    return rNUKE;
			goto prompt;		/* decided not to delete.. */
		    }
		    break;
	    case 'O':
		    if (!SomeSysop())
			break;
		    if (canpromote()) {
			iprintf("Promote to net-message\r");
			return rPROMOTE;
		    }
		    goto prompt;
	    case 'J':
		    if (SomeSysop()) {
			iprintf("Journal\r");
			_journal();
			goto prompt;
		    }
		    break;
	    case 'B':
		    if (canbackup) {
			iprintf("Back up\r");
			return rBACK;
		    }
		    break;
	    case '?':
		    menu("more");
		    goto prompt;
	    }
	    oChar(BELL);
	}
    }
    return rNEXT;
}

/*
 * printmesg() -- print out a message
 */
static int leftover = 0;
static char onlyheaders;
static char printrv;

static char
printmesg(void)
{
    char status;

    outFlag = OUTOK;
    CACHE = 0;
    pMESS = 1;			/* enable message deletes */

    putheader(leftover);
    while (printaword() && (outFlag == OUTOK || outFlag == OUTPARAGRAPH))
	;
    status = outFlag;
    if (pMESS != 'B')			/* kludge */
	pMESS = 0;
    if (outFlag == OUTSKIP)
	outFlag = OUTOK;
    iprintf(status == OUTSKIP ? "\r\r" : "\r");		/* AA 90Dec04 */
    return status;
}

/*
 * legitimate() filters out bad messages
 */
static int
legitimate(void)
{
    if (justLocals == YES && ROUTEOK(&msgBuf)
	    && ROUTECHAR(&msgBuf) != ROUTE_ORIG)
	return NO;
    if (justLocals == ERROR && ROUTEOK(&msgBuf)
    	    && ROUTECHAR(&msgBuf) == ROUTE_ORIG)
	return NO;
    if (wantuser && strlen(msguser)) {
    	int au = !(whereis(msgBuf.mbauth,msguser,0,strlen(msgBuf.mbauth)) < 0);
	int to = !(whereis(msgBuf.mbto,  msguser,0,strlen(msgBuf.mbto  )) < 0);

	if ((wantuser == YES && !au && !to)
		|| (wantuser == ERROR && (au || to)))
	    return NO;
    }
    if (dPass != dEVERY && !dateok(msgtime(msgBuf.mbdate, "12:00 am")))
	return NO;
    return YES;
}

/*
 * pick1mesg() -- return the slot of a message ID
 */
int
pick1mesg(long id)
{
    register i;

    for (i=0; i<NUMMSGS; i++)
	if (id == roomBuf.msg[i].msgno)
	    return i;
    return ERROR;
}

/*
 * read1mesg() -- read a single message
 *		  In the case of .R<number>, canbackup is ERROR,
 *		  else it is YES or NO, indicating whether the user can
 *		  back up to the previous message.
 */
int
read1mesg(int msgNo, int canbackup)
{
    int status = rNEXT;

    r1_loc = roomBuf.msg[msgNo].msgloc;
    r1_id  = roomBuf.msg[msgNo].msgno;
    journalMessage = pullMessage = NO;

    if (canbackup == ERROR) {		/* Hack for .R<number> */
	leftover = 1;
	canbackup = NO;
    }

    if (r1_id >= cfg.oldest) {
	--leftover;
	if (findMessage(r1_loc, r1_id)) {
	    /*
	     * strip out messages we don't want
	     */
	    if (legitimate()) {
		if (onlyheaders) {
		    if (readbit(msgBuf,mANONMESSAGE) || SomeSysop())
			mprintf("%ld ", r1_id);
		    if (SomeSysop())
			mprintf("(%ld) ", msgBuf.mbsrcid);
		    mprintf("%s %s", msgBuf.mbdate, msgBuf.mbtime);
		    if (thisRoom != MAILROOM
			    || (stricmp(logBuf.lbname, msgBuf.mbauth) != 0)) {
			mprintf(": from %s", msgBuf.mbauth);
			if (msgBuf.mboname[0])
			    mprintf(" @ %s%s%s", msgBuf.mboname,
				msgBuf.mbdomain[0] ? "." : "", msgBuf.mbdomain);
		    }
		    else
			mprintf(": to %s", msgBuf.mbto);
		    if (Debug) {
			xprintf("\nFlags: ");
			if (readbit(msgBuf,mIMPERVIOUS))
			    xprintf("IMP ");
			if (readbit(msgBuf,mNETMESSAGE))
			    xprintf("NET ");
			if (readbit(msgBuf,mUUCPMESSAGE))
			    xprintf("UUCP ");
			if (readbit(msgBuf,mMULTIMAIL))
			    xprintf("MULT ");
			if (readbit(msgBuf,mANONMESSAGE))
			    xprintf("ANON ");
			if (readbit(msgBuf,mTWITMESSAGE))
			    xprintf("TWIT ");
			if (readbit(msgBuf,mSYSOPMESSAGE))
			    xprintf("SYS ");
			if (readbit(msgBuf,mPREFORMATTED))
			    xprintf("PREF ");
		    }
		    if (msgBuf.mbsub[0])
			mprintf("\rSubject: %s", msgBuf.mbsub);
		    if (outFlag == OUTSKIP) {
			outFlag = OUTOK;
			mprintf("\r\r");
			return rSTOP;
		    }
		    else
			mprintf("\r");
		}
		else if (usingWCprotocol == ASCII) {
		    while (1) {
			switch (status = printmesg()) {
			    case OUTSKIP:	return rSTOP;
			    case OUTNEXT:	return rNEXT;
			    case OUTAGAIN:
				if (pMESS == 'B' && canbackup) {
				    pMESS = 0;
				    return rBACK;
				}
				break;
			    default:
				if ((status = tailmesg(canbackup)) != rAGAIN)
				    return status;
				break;
			}
			findMessage(r1_loc, r1_id);
		    }
		}
		else {
		    getmsgstr(msgBuf.mbtext, MAXTEXT);
		    printdraft();
		    doCR();
		}
	    }
	    else {
		outFlag = OUTOK;
		if (mAbort())		/* AA 91Jan23 */
		    return rSTOP;
	    }
	}
	else {
	    mprintf("Can't find #%ld in sector %d\r", r1_id, r1_loc);
	    if (outFlag == OUTSKIP) {
		outFlag = OUTOK;
		mprintf("\r\r");
		return rSTOP;
	    }
	}
    }
    return rNEXT;
}

/*
 * displaymesg() -- display a bunch of messages in a room
 */
static void
displaymesg(int first, int last, int direction)
{
    int *backup;
    int bup=0;
    int status;
    int tempnum;

    backup = (int *)xmalloc(NUMMSGS * sizeof(int));

    for (msgNo = first; onLine(); ) {
	if (Debug)
	    xprintf("Msgno: %d, last: %d\n", msgNo, last);
	switch (status = read1mesg(msgNo, (bup > 0))) {
	case rSTOP: outFlag = OUTSKIP;				goto getout;
	case rBACK: msgNo = backup[--bup]; leftover += 2;	break;
	case rNUKE:			/* deleted a message, adjust ptrs */
	    if (thisRoom != MAILROOM) {
		if (direction > 0) {
		    if (msgNo > --last)
			goto getout;
		}
		else {
		    register i;

		    if (--msgNo < last)
			goto getout;
		    for (i=0; i < bup; i++)
			--backup[i];
		}
	    }
	    else {	/* MAILROOM */
		if (direction > 0) {
		    register i;

		    for (i=(bup-1); i>=0; --i)
			++backup[i];
		    ++msgNo;
		    if (msgNo > last)
			goto getout;
		}
		else if (msgNo == (last++))
		    goto getout;
	    }
	    if (Debug)
		xprintf("Post-delete: Msgno: %d, last: %d\n", msgNo, last);
	    break;
	case rHELD:
	case rCOMMENT:
	case rPROMOTE:		/* AA 91Jan13 */
	    tempnum = NUMMSGS;	/* How many msgs before the save? */
	    if ((status == rHELD) ? heldmesg(ASCII) :
			(status == rCOMMENT ? replymesg() : _mutate())) {
		register i, j, msgslost;

		/* If we were on the last msg when the new msg was	*/
		/* saved, then exit without further mucking.		*/
		if (msgNo == last)
		    goto getout;

		if (thisRoom != MAILROOM) {
		    /* In the case of non-Mail> rooms, if we were not	*/
		    /* at the last msg before the save, we might be at	*/
		    /* or beyond it now due to dynamic room resizing.	*/

		    /* If the room resized by increasing one msg, no	*/
		    /* mucking required.				*/
		    if (NUMMSGS == tempnum + 1) {
			backup[bup++] = msgNo;
			msgNo += direction;
			break;
		    }

		    /* The room did not increase in size by one msg, so	*/
		    /* we must have lost some of the old ones during	*/
		    /* the save.					*/
		    msgslost = (tempnum - NUMMSGS);	/* # msgs lost */

		    for (backup[bup++] = msgNo, j=i=0; i<bup; i++)
			if ((backup[i] -= (msgslost + 1)) >= 0)
			    backup[j++] = backup[i];
		    bup = j;

		    if (direction > 0) {
			msgNo -= msgslost;
			last -= (msgslost + 1);
			if (msgNo > last)	/* Lost all remaining */
			    goto getout;	/* msgs.              */
			leftover = last - msgNo + 1;
		    }
		    else {	/* reverse */
			msgNo -= (msgslost + 2);
			if (msgNo < last)	/* Lost all remaining */
			    goto getout;	/* msgs.              */
			leftover -= (msgslost + 1);
		    }
		}
		else {	/* MAILROOM */
		    /* In the case of Mail>, if we were not at the last	*/
		    /* msg before the save, we are not now at the last	*/
		    /* msg.  Muck around to continue reading.		*/

		    for (backup[bup++] = msgNo, j=i=0; i<bup; i++)
			if (--backup[i] >= 0)
			    backup[j++] = backup[i];
		    bup = j;

		    /* New msgs go in at high index vals, old msgs are	*/
		    /* at low index vals.  If reading forward, --last	*/
		    /* so we don't read newly-entered msg.  If reading	*/
		    /* reverse, --last so we catch up with oldest msg,	*/
		    /* which got bumped down one slot.			*/
		    if (--last < 0)
			last = 0;

		    /* The msg we were pointing at got bumped down one	*/
		    /* slot, so follow it with the pointer.		*/
		    if (--msgNo < 0)
			msgNo = 0;

		    /* Now move in desired direction. */
		    msgNo += direction;
		}
		break;
	    }
	    if (Debug)
		xprintf("Post-save: Msgno: %d, last: %d\n", msgNo, last);
	    /* else fall into default if heldmesg/replymesg didn't save a msg */
	default:
	    if (msgNo == last)
		goto getout;
	    backup[bup++] = msgNo;
	    msgNo += direction;
	    break;
	}
    }
getout:		/* yeah, I know, a goto... sometimes you just HAVE to. */
	free(backup);
	return;
}

/*
 * msgbrk() -- return the msg[] index of the first message above lim
 */
int
msgbrk(register long lim)
{
    register brk;

    if (lim < cfg.oldest)	/* make damn sure we have valid messages */
	lim = cfg.oldest;
    for (brk=0; brk < NUMMSGS && roomBuf.msg[brk].msgno <= lim; brk++)
	;
    return brk;
}

/*
 * showMessages() -- displays a bunch of messages
 */
void
showMessages(int which, int reverse)
{
    int start, brk, end;

    if (thisRoom == MAILROOM)
	if (!loggedIn) {
	    help("policy", NO);
	    return;
	}
	else echo = onConsole;

    brk = msgbrk(logBuf.lbvisit[logBuf.lbgen[thisRoom] & CALLMASK]);
    onlyheaders = which & 0xf0;

    switch (which & 0x0f) {
    case OLDaNDnEW:
	start = 0;
	end   = NUMMSGS - 1;
	leftover = (thisRoom == MAILROOM ? msgCount(0) : NUMMSGS);
	break;
    case OLDoNLY:
	start = 0;
	end   = brk - 1;
	leftover = brk;
	break;
    default:
	start = brk;
	end   = NUMMSGS - 1;
	/* adjust start for oldToo diddling */
	if (readbit(logBuf,uLASTOLD) && thisRoom != MAILROOM && start > 0)
	   --start;
       leftover = NUMMSGS - start;
       break;
    }
    if (start <= end) {
	if (reverse) {
	    brk = start;
	    start = end;
	    end = brk;
	}
	/*
	 * if we are set for .rm, always do More:, otherwise if we're in
	 * Mail>, do more too.
	 */

#if 0	/* don't need this here anymore... it's done in doRead(). */
	if ((thisRoom==MAILROOM && which==NEWoNLY) || readbit(logBuf,uREADMORE))
	    singleMsg = YES;
#endif
	displaymesg(start, end, reverse ? (-1) : (1));
    }
    onlyheaders = NO;
    leftover = 0;
    echo = YES;
}

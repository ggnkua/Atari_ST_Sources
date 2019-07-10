/*
 * postmsg.c -- message posting routines
 *
 * 88Aug05 orc	msgprintf() moved in, functions staticised as needed
 * 88Jul13 orc	New mail routing code installed.
 * 88Feb14 orc	Created
 */

#include "ctdl.h"
#include "net.h"
#include "protocol.h"
#include "config.h"
#include "msg.h"
#include "room.h"
#include "log.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

#include <stdarg.h>

/*
 * postmail()		Post/validate mail
 * _spool()		(guts of) write a message to disk
 * * putspool()		Write a message to disk
 * * savenetmail()	update pointers and billing info
 * * msgputchar()	Writes successive message chars to disk
 * * msgflush()		Wraps up message-to-disk store
 * * msgprintf()	printf() for saving a message to ctdlmsg
 * * putmessage()	Stores a message to disk
 * * noteLogMessage()	Enter message into log record
 * note2Message()	NoteMessage() local
 * * notemessage()	Enter message into current room
 * msgToDisk()		Archive a message to the disk
 * storeMessage()	save a message
 */

char Misvalid = NO;		/* are we caching a message address? */
				/* turned off by holding, saving, or */
				/* [N] save in editText */
char Mlocal;			/* is it a local or net-message? */
int  Mindex;			/* what is netpos/logpos? */
int  Mcost;			/* what did it cost? */

/*
 * putfield() stores nonblank fields to disk
 */
static void
putfield(FILE *fd, char key, char *field)
{
    if (*field) {
	fprintf(fd, "%c%s", key, field);
	fputc(0, fd);
    }
}

void
_spool(FILE *f)
{
    register char *s;
    LABEL tempstr;

    fprintf(f, "\377%lu", 1+cfg.newest); putc(0,f);	/* message ID	*/
    putfield(f, 'D', msgBuf.mbdate);			/* date		*/
    putfield(f, 'C', msgBuf.mbtime);			/* time		*/
    putfield(f, 'R', roomBuf.rbname);			/* room name	*/
    putfield(f, 'A', msgBuf.mbauth);			/* author	*/
    putfield(f, 'T', msgBuf.mbto);			/* destination	*/
    putfield(f, 'I', msgBuf.mborg);			/* org info	*/
    putfield(f, 'J', msgBuf.mbsub);			/* subject info	*/

    putfield(f, 'Z', msgBuf.mbroute);			/* network info	*/
    putfield(f, 'N', msgBuf.mboname);
    putfield(f, 'O', msgBuf.mborig);
    putfield(f, 'X', msgBuf.mbdomain);

/* srcid added by AA & RH 91Jan01 */
    if (msgBuf.mbsrcid > 0L) {
	sprintf(tempstr, "%u %u",
	    (unsigned short)((msgBuf.mbsrcid & 0xffff0000L) >> 16),
	    (unsigned short)(msgBuf.mbsrcid & 0x0000ffffL));
	putfield(f, 'S', tempstr);
    }

/* flags added by AA 90Oct31 */
    sprintf(tempstr, "F%lx", msgBuf.flags);
    putfield(f, '7', tempstr);				/* flags	*/

    putc('M', f);
    for (s = msgBuf.mbtext; *s; s++)
	putc(*s, f);
}

/*
 * putspool() - stores a message to disk
 */
static void
putspool(FILE *f)
{
    _spool(f);
    putc(0, f);
}

/*
 * postmail() - try to deliver or forward electronic mail.
 *
 * This routine is used only by mailers, because mail originating locally
 * needs accounting and a prettier format.
 */
int
postmail(int savemail)
{
    struct logBuffer logb;
    FILE   *spl;
    LABEL   nextnode;
    LABEL   lastnode;
    PATHBUF splfile;
    NETADDR      from, to;
    int     cost;
    int     oldnet, oldroom;
    int     where, logidx;

    Misvalid = NO;
    oldnet=thisNet;
    strcpy(to, msgBuf.mbto);
    strcpy(lastnode, msgBuf.mboname);

    if ((cfg.flags.FORWARD_MAIL) && parsepath(to, nextnode, savemail)) {
	if ((where=findnode(nextnode, &cost)) != ERROR) {
	    if (savemail) {
		msgBuf.mborig[0] = msgBuf.mboname[0] = 0;

		sprintf(from, "%s!%s", lastnode, msgBuf.mbauth);
		strcpy(msgBuf.mbauth, from);

		changeto(to, nextnode);

		ctdlfile(splfile, cfg.netdir, "%d.fwd", where);
		if (spl = safeopen(splfile,"ab")) {
		    putspool(spl);
		    fclose(spl);
		    /*
		     * netBuf already points at the proper netnode...
		     */
		    set(netBuf,MAILPENDING);
		    putNet(where);
		}
		else where = ERROR;
	    }
	}
	getNet(oldnet);
	return (where != ERROR);
    }
    Misvalid = NO;
    initlogBuf(&logb);
    logidx = getnmlog(msgBuf.mbto, &logb, logfl);
    if (logidx != ERROR || stricmp(msgBuf.mbto, "Sysop") == 0) {
	if (savemail) {
#ifdef megadebug
	    xputs("Savemail cookie");
#endif
	    oldroom=thisRoom;
	    getRoom(MAILROOM);
	    if (logidx != ERROR)
		strcpy(msgBuf.mbto, logb.lbname);
	    set(msgBuf,mNETMESSAGE);
	    storeMessage(&logb, logidx);
	    getRoom(oldroom);
	}
	killlogBuf(&logb);
	return YES;
    }
    killlogBuf(&logb);
    return NO;
}

/*
 * savenetmail() - update pointers and billing info for netmail
 */
static void
savenetmail(int cost)
{
    FILE *mail;
    PATHBUF mailfile;

    ctdlfile(mailfile, cfg.netdir, "%d.ml", thisNet);
    if (mail = safeopen(mailfile, "a")) {
	fprintf(mail, "%ld %d\n", 1+cfg.newest, cfg.catSector);
	fclose(mail);
	if (!SomeSysop())		/* Don't waste creds on Sysops */
	    logBuf.credit -= cost;
	putlog(&logBuf, logindex, logfl);
	if (!readbit(netBuf,MAILPENDING)) {
	    set(netBuf,MAILPENDING);
	    putNet(thisNet);
	}
    }
    else
	mprintf("Queuing error!\r");
}

/*
 * msgputchar() - write out a character to the messagefile
 */
static int
msgputchar(unsigned char c)
{
    long address;

    if (mbsector[mbindex] == (char)0xFF)	/* killed a message */
	logBuf.lbvisit[MAXVISIT-1] = ++cfg.oldest;

    mbsector[(mbindex)++] = c;
    if ((mbindex %= BLKSIZE) == 0) {
	/*
	 * write this sector out....
	 */
	crypte(mbsector, BLKSIZE, 0);
	address = (long)(mboffset) * (long)(BLKSIZE);

	dseek(msgfl, address, 0);
	if (dwrite(msgfl, (mbsector), BLKSIZE) != BLKSIZE)
	    crashout("msgfile write error");

	mboffset = (++(mboffset)) % cfg.maxMSector;

	/*
	 * ... and read in the next
	 */
	dseek(msgfl, ((long)(mboffset)) * ((long)BLKSIZE), 0);

	if (dread(msgfl, (mbsector), BLKSIZE) != BLKSIZE)
	    crashout("msgfile read error");
	crypte(mbsector, BLKSIZE, 0);
    }
    return YES;
}

/*
 * msgflush() - wraps up writing a message to disk.
 *	Takes into account 2nd msg file if necessary
 */
static void
msgflush(void)
{
    long address = (long)(mboffset) * (long)(BLKSIZE);

    crypte(mbsector, BLKSIZE, 0);

    dseek(msgfl, address, 0);
    if (dwrite(msgfl, mbsector, BLKSIZE) != BLKSIZE)
	crashout("msgfile flush error");

    crypte(mbsector, BLKSIZE, 0);
}

/*
 * msgprintf() - printf() to ctdlmsg.sys
 */
void
msgprintf(char *format, ...)
{
    va_list arg;
    char string[MAXWORD];
    register char *p;

    va_start(arg, format);
    vsprintf(string, format, arg);
    va_end(arg);
    for (p=string; *p;)
	msgputchar(*p++);
    msgputchar(0);
}

/*
 * putmessage() - stores a message to disk.
 *
 * Always called before notemessage() - newest not ++ed
 */
static int
putmessage(void)
{
    LABEL destnode;
    int cost, nbpos;
    register char *p;

    msgseek(cfg.catSector, cfg.catChar);	/* set up for write	*/

    msgprintf("\377%lu", 1+cfg.newest);

    msgprintf("R%s", roomBuf.rbname);
    strcpy(msgBuf.mbroom, roomBuf.rbname);	/* set up for archive code */

    if (msgBuf.mbsrcid != 0L)			/* added by AA/RH 91Jan01 */
	msgprintf("S%u %u",
	    (unsigned short)((msgBuf.mbsrcid & 0xffff0000L) >> 16),
	    (unsigned short)(msgBuf.mbsrcid & 0x0000ffffL));

    if (readbit(roomTab[thisRoom],ANON) && readbit(msgBuf,mANONMESSAGE)) {
	msgprintf("D****");
	msgprintf("C ");
    }
    else {
	msgprintf("D%s", msgBuf.mbdate[0] ? msgBuf.mbdate : formDate());
	msgprintf("C%s", msgBuf.mbtime[0] ? msgBuf.mbtime : tod(YES));
	if (msgBuf.mbauth[0])
	    msgprintf("A%s", msgBuf.mbauth);
	clear(msgBuf,mANONMESSAGE);
    }

    msgprintf("7F%lx", msgBuf.flags);    /* flags added by AA 90Oct31 */
	
    if (msgBuf.mbto[0]) {	/* private message -- write addressee	*/
	/*
	 * The Mxxx stuff checks the addressee cache for who to mail
	 * the message to.  After writing the message, make the cache
	 * invalid no matter what.
	 */
	if (!Misvalid) {
	    if (parsepath(msgBuf.mbto, destnode, NO)) {
		Mlocal = NO;
		Mindex = findnode(destnode, &Mcost);
	    }
	}
	if (Misvalid && !Mlocal) {
	    getNet(Mindex);
	    savenetmail(Mcost);
	}
	Misvalid = NO;
	msgprintf("T%s", msgBuf.mbto);
    }
    else if (ROUTEOK(&msgBuf)) {
	msgprintf("Z%s", msgBuf.mbroute);
	if (ROUTECHAR(&msgBuf) == ROUTE_LOCAL)
	    roomBuf.rblastLocal = 1+cfg.newest;
	else
	    roomBuf.rblastNet = 1+cfg.newest;

	if (msgBuf.mborg[0])
	    msgprintf("I%s", msgBuf.mborg);
    }

    if (msgBuf.mbsub[0])
	msgprintf("J%s", msgBuf.mbsub);
    if (msgBuf.mboname[0])
	msgprintf("N%s", msgBuf.mboname);
    if (msgBuf.mborig[0])
	msgprintf("O%s", msgBuf.mborig);
    if (msgBuf.mbdomain[0])
	msgprintf("X%s", msgBuf.mbdomain);

    /*
     * after everything else, write out the message....
     */
    msgputchar('M');
    for (p=msgBuf.mbtext; *p;  p++)
	msgputchar(*p);
    msgputchar(0);

    msgflush();
    return YES;
}

/*
 * noteLogMessage() - slots message into log record
 */
static void
noteLogMessage(struct logBuffer *p, int logno)
{
    int i;

#ifdef megadebug
    xprintf("noteLogMessage(%p,%d)\n", (char far *)p, logno);
#endif

    for (i=0; i < MAILSLOTS - 1; i++) {		/* slide email pointers down */
	p->lbmail[i].msgloc = p->lbmail[1+i].msgloc;
	p->lbmail[i].msgno  = p->lbmail[1+i].msgno;
    }

    p->lbmail[MAILSLOTS - 1].msgno  = cfg.newest; /* slot this message in */
    p->lbmail[MAILSLOTS - 1].msgloc = cfg.catSector;

    putlog(p, logno, logfl);
}

/*
 * note2Message() - makes room for a new message.
 */
void
note2Message(long id, int loc)
{
#ifdef megadebug
    xprintf("note2Message(%ld,%d)\n", id, loc);
#endif

    NUMMSGS++;
    roomBuf.msg = (theMessages *)realloc(roomBuf.msg, MSG_BULK);
    roomBuf.msg[NUMMSGS - 1].msgno = id;
    roomBuf.msg[NUMMSGS - 1].msgloc = loc;
}

/*
 * notemessage() - slots message into current room
 */
static void
notemessage(struct logBuffer *logptr, int logidx)
{
    struct logBuffer lbuf2;
    int logidx2;
    char *fn;
    char *arcp;
    PATHBUF sysopmail;

    initlogBuf(&lbuf2);

    logBuf.lbvisit[0] = ++cfg.newest;
    write_checkpoint();		/* --aa 91Jun03 */
    if (thisRoom != MAILROOM) {
	note2Message(cfg.newest, cfg.catSector);
	noteRoom();
	putRoom(thisRoom);
    }
    else {
	if (stricmp(msgBuf.mbto, "Sysop") == 0)  {
	    getRoom(AIDEROOM);
	    /*
	     * enter in Aide> room -- 'sysop' is special
	     */
	    note2Message(cfg.newest, cfg.catSector);
	    /*
	     * write it to disk
	     */
	    noteRoom();
	    putRoom(AIDEROOM);
	    getRoom(MAILROOM);
	}
	else if (stricmp(msgBuf.mbto, program) == 0) {
	    for (logidx2 = 0; logidx2 < cfg.logsize; logidx2++) {
		if (logidx2 != logindex) { /* Don't save to author */
		    getlog(&lbuf2, logidx2, logfl);
		    if readbit(lbuf2,uINUSE)
			noteLogMessage(&lbuf2, logidx2);
		}
	    }
	}
	else if (logptr && logidx != ERROR)
	    noteLogMessage(logptr, logidx);	/* note in recipient	*/

	if (loggedIn) {
	    if (logindex != logidx)
		noteLogMessage(&logBuf, logindex);/* note in ourself	*/
	    update_mail();			/* update room also	*/
	}

	/* Check for Sysop mail archiving */
	if (cfg.sysopName && (cfg.flags.ARCHIVE_MAIL)) {
	    arcp = &cfg.codeBuf[cfg.sysopName];	/* Get defined sysop name */

	    /* Archive if: (1) It's to a local user, who is named #sysop,
			   (2) It's from the #sysop,
			   (3) It's to "Citadel" */
	    if ((logptr && logidx != ERROR &&
		    (stricmp(logptr->lbname,arcp) == 0)) ||
		(stricmp(logBuf.lbname,arcp) == 0) ||
		(stricmp(msgBuf.mbto, program) == 0)) {
		ctdlfile(sysopmail, cfg.auditdir, "sysop.msg");
		msgToDisk(sysopmail);
	    }
	}
    }

    msgBuf.mbto[0] = 0;
    cfg.catSector= mboffset;
    cfg.catChar  = mbindex;
    if readbit(roomBuf,ARCHIVE) {
	if ((fn = findArchiveName(thisRoom)) == NULL) {
	    sprintf(msgBuf.mbtext, "Archive error in `%s'.",roomBuf.rbname);
	    aideMessage(NO);
	}
	else
	    msgToDisk(fn);
    }
    killlogBuf(&lbuf2);
}

/*
 * msgToDisk() - Puts a message to the given disk file
 */
void
msgToDisk(char *filename)
{
    if (ARsetup(filename)) {
	putheader(0);
	mformat(msgBuf.mbtext);
	doCR();
	sendARend();
    }
    else
	mprintf("ERROR: Couldn't open output file %s\r", filename);
}


/*
 * storeMessage() - save a message
 */
int
storeMessage(struct logBuffer *who, int idx)
{
    struct logBuffer lbuf2;
    int logidx2;
    register int status = YES;

    initlogBuf(&lbuf2);

/* Check for mail to "Sysop".  If found, replace "Sysop" with the defined
   Sysop name. */
    if ((thisRoom == MAILROOM) && (stricmp(msgBuf.mbto, "Sysop") == 0))  {
	if (cfg.sysopName)
	    logidx2 = getnmlog(&cfg.codeBuf[cfg.sysopName], &lbuf2, logfl);
	if (logidx2 != ERROR) {
	    strcpy(msgBuf.mbto, lbuf2.lbname);
	    idx = logidx2;
	    who = &lbuf2;
	}
    }
    if (putmessage())
	notemessage(who, idx);
    else
	status = NO;
    killlogBuf(&lbuf2);
    return status;
}

/*
 * aideMessage() - saves auto message in Aide>
 */
void
aideMessage(int noteDeletedMessage)
{
    int ourRoom;

    /* Ensures not a net message    */
    msgBuf.mboname[0] = msgBuf.mborig[0] =
    msgBuf.mborg[0]   = msgBuf.mbdate[0] =
    msgBuf.mbtime[0]  = msgBuf.mbto[0]   = 
    msgBuf.mbdomain[0] = 0;

    msgBuf.flags = msgBuf.mbsrcid = 0L;

    /* message is already set up in msgBuf.mbtext */
    putRoom(ourRoom = thisRoom);
    getRoom(AIDEROOM);

    strcpy(msgBuf.mbauth, program);
    storeMessage(NULL, ERROR);

    if (noteDeletedMessage) {
	note2Message(pullMId, pullMLoc);

	/* Archive code snipped from notemessage() by RWH 91Apr03 */
	if readbit(roomBuf,ARCHIVE) {
	    char *fn;

	    if ((fn = findArchiveName(thisRoom)) == NULL) {
		sprintf(msgBuf.mbtext, "Archive error in `%s'.",roomBuf.rbname);
		storeMessage(NULL, ERROR);	/* Replaces aideMessage(NO); */
	    }
	    else {
		findMessage(pullMLoc, pullMId);
		getmsgstr(msgBuf.mbtext, MAXTEXT);
		msgToDisk(fn);
	    }
	}
    }

    noteRoom();
    putRoom(AIDEROOM);

    getRoom(ourRoom);
}


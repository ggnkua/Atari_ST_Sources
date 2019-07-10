/* #define notdef 1 */

/*
 * netrcv.c - Slave mode networker
 *
 * 90Dec14 RH	Add donetpurge() for purging of incoming net traffic
 * 90Oct03 AA	Add support for single-file C86-style requests (sheesh!)
 * 90Aug31 AA	Add support for C86-style file requests
 * 88Jul21 orc	Add support for OPTIONS command
 * 87Dec23 orc	remove NeedsProcessing() macros and do processing on a
 *		call-by-call basis
 * 87Nov03 orc	pull password from node identify packet
 * 87May17 orc	Sendfile support.
 * 87Apr01 orc	hacked up for STadel.
 * 86Aug20 HAW	History not maintained due to space problems.
 */

#include <stdarg.h>
#include "ctdl.h"
#include "net.h"
#include "msg.h"
#include "log.h"
#include "config.h"
#include "room.h"
#include "dirlist.h"
#include "protocol.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * * reply()		Replies to caller
 * * stabilize()	Attempts to stabilize communication
 * * check_for_init()	Looks for networking init sequence
 * * getNetBaud() 	Gets baud of network caller
 * issharing()		Is this room netting with caller?
 * nmcalled()		Got a caller while in net mode.
 * * getnetlogin()	get the network login packet from caller
 * called()		Deal with a network caller
 * * chkproto()		Handle the OPTIONS command.
 * * catchfile()	Receive a sent file
 * * targetCheck()	Checks for existence of recipients
 * * check_mail()	Does negative acks on netMail
 * * getnetmail()	Grabs mail from caller
 * * c86filereq()	Handle C-86 style file requests
 * * flingfile()	Handles request for file transfer
 * * catchroom()	Handles request for room networking
 * slavemode()		Receive stuff, like it says.
 * netopt()		parse an options string.
 * donetpurge()		Purge incoming net traffic
 * * doNetRooms()	Integrates temporary files
 * doResults()		Processes results
 * * getnetcmd()	Gets next command from caller
 */

struct cmd_data {
    unsigned command;
    char arg[4][NAMESIZE];
} ;

char *sr_sent = NULL;
char *sr_rcvd = NULL;
char processMail;
char netrmspool[] = "$netroom.%d";
char netmlspool[] = "$tmpmail";
int posID = NO;

/* types for flingfile(): */
#define FR_NORMAL 0
#define FR_C86MULTI 1
#define FR_C86SINGLE 2

/*
 * standard `huh?' reply for OS oddities.
 */
static char oops[] = "System error";

/*
 * reply() -- Replies to caller
 */
static void
reply(int state, ...)
{
    if (beginWC()) {
	(*sendPFchar)(state);
	if (state == NO) {
	    va_list ap;
	    char *reason;

	    va_start(ap, state);
	    reason = va_arg(ap, char *);		
	    wcprintf("%s", reason);
	    splitF(netLog, "Reply BAD: %s.\n", reason);
	    va_end(ap);
	}
	endWC();
    }
    else
	neterror(YES, "Hangup during net reply.");
}

/*
 * issharing() - See if given room slot is shared with system that has called
 */
int
issharing(int slot)
{
    register idx, room;

    for (idx=0; idx < SHARED_ROOMS; idx++) {
	room = netBuf.shared[idx].NRidx;
	if (room == slot && netBuf.shared[idx].NRgen == roomTab[slot].rtgen)
	    return idx;
    }
    return ERROR;
}

/*
 * check_for_init() -- Looks for networking initialization sequence
 *
 * loosened up a bit for 3.2a -- a CR will automatically drop into state 2 no
 * matter what the previous character was.
 */
static int
check_for_init(void)
{
    int count;
    unsigned ch, seq;

    for (seq=0, count=100; count >= 0; --count) {
	if (MIReady()) {
	    ch = getraw();
	    if (netDebug)
		splitF(netLog, "%d.%d ", ch, seq);
	    switch (ch) {
	    case 07:seq = 1;		break;		/* \a */
	    case 13:seq = 2;		break;		/* \r */
	    case 69:if (seq==2)		return YES;	/* e  */
	    default:seq = 0;		break;
	    }
	}
	else pause(1);
    }
    return NO;
}

/*
 * getNetBaud() -- gets baud of network caller
 */
static int
getNetBaud(void)
{
    int retry=15;
    int baud, HOLD, valid;
    char laterMessage[100];
    
    if (cfg.flags.SEARCH_BAUD)
	HOLD = (int)((cfg.flags.MODEMCC) && (mmesgbaud() != ERROR));
    else {
	setBaud(cfg.sysBaud);
	HOLD = YES;
    }
    
    pause(100); 	/* Pause a full second */
    while (retry-- > 0 && gotcarrier()) {
	mflush();

	if (HOLD) {
	    if (netDebug)
		splitF(netLog, "-HOLD\n");
	    valid = check_for_init();
	}
	else {
	    for (baud=cfg.sysBaud; baud >= 0 && gotcarrier(); --baud) {
		setBaud(baud);
		if (netDebug)
		    splitF(netLog, "-%d\n", baud);
		/*
		 * if we pulled in a valid init sequence, slap into
		 * net mode.
		 */
		if (valid = check_for_init()) {
		    HOLD = YES;
		    break;
		}
	    }
	}

	if (valid && netAck())
	    return YES;
    }

    /*
     * lost carrier or timed out...
     */
    if (gotcarrier()) {
	sprintf(laterMessage,
		"The system will be networking for another %d minutes.\r\n",
		netTimeLeft());

	if (HOLD)
	    modputs(laterMessage);
	else
	    for (baud = cfg.sysBaud; baud >= 0; baud--) {
		setBaud(baud);
		modputs(laterMessage);
	    }
	hangup();
    }
    return NO;
}

/*
 * stabilize() -- Attempts to stabilize communication on receiver end.
 */
static int
stabilize(void)
{
    return (getNetBaud() && gotcarrier());
}

/*
 * nmcalled() - deal with a caller from network mode
 */
void
nmcalled(void)
{
    splitF(netLog, "Caller detected @ %s.\n", tod(NO));
    if (stabilize())
	called();
    else
	splitF(netLog, "Call not stabilized.\n");
}

/*
 * getnetcmd() - Gets next command from caller
 */
static int
getnetcmd(struct cmd_data *cmd, int login)
{
    register i;
    register char *ptr;

    for (i=0;i<SECTSIZE;i++)
	sectBuf[i] = 0;
    zero_struct(*cmd);

    counter = 0;
    if (login)
	sectBuf[counter++] = LOGIN;

    if (enterfile(increment, usingWCprotocol) && gotcarrier()) {

#ifdef notdef
	for (i=0; i<128; i++)
	    xprintf(isprint(sectBuf[i]) ? "%c " : "%02x ", 0xff & sectBuf[i]);
#endif

	cmd->command = 0xff & sectBuf[0];
	for (i=0, ptr=sectBuf; *++ptr && i<4; i++, ptr = ENDOFSTR(ptr)) {
	    copystring(cmd->arg[i], ptr, NAMESIZE);

#ifdef notdef
	    splitF(netLog, "cmd->arg[%d] = %s\n", i, cmd->arg[i]);
#endif

	}
	return cmd->command;
    }
    return cmd->command = HANGUP;
}

/*
 * getnetlogin() - get the network login packet from caller
 */
static void
getnetlogin(void)
{
    struct cmd_data login;

    posID = NO;		/* Assume we don't know the caller */
    if (getnetcmd(&login, YES) != HANGUP) {
	normID(login.arg[0], rmt_id);
	strcpy(rmtname, login.arg[1]);

	if (rmtname[0] == 0)
	    neterror(YES, "Bad login packet.");
	else if ((rmtslot = srchNetId(rmt_id)) == ERROR)     /* Know caller? */
	    neterror(NO, "New caller `%s' (%s).", rmtname, rmt_id);
	else if (strlen(netBuf.myPasswd)) {	/* Is there a password? */
	    if(login.arg[2][0] > ' ')		/* Did they send a password? */
		if (strcmp(login.arg[2], netBuf.myPasswd) != 0)	{/* No match */
		    splitF(netLog, "Bad password `%s'.\n", login.arg[2]);
		    neterror(YES, "Bad password `%s'", login.arg[2]);
		}
		else {						/* Match */
		    splitF(netLog, "Received & verified password.\n");
		    posID = YES;
		}
	}
	else		/* We know the caller & no password is defined */
	    posID = YES;
	splitF(netLog, "Call from `%s' (%s).\n", rmtname, rmt_id);
    }
}

/*
 * called() - deal with a network caller.
 */
void
called(void)
{
    usingWCprotocol = XMODEM;
    getnetlogin();
    if (gotcarrier()) {
	doSetup();
	slavemode(NO, posID);
	splitF(netLog, "Done with %s @ %s.\n", rmtname, tod(NO));
 	hangup();
	doResults();
    }
}

/*
 * chkproto() - handle the OPTIONS command for Fnordadel/STadel & Cit-86
 */
static void
chkproto(char *optstr, int cit86)
{
    char *rec;
    char proto;

    if (cit86) {	/* Handling Cit-86 ITL change command? */
	/* "0" == XMODEM, "1" == YMODEM, "2" == WXMODEM, "3" == ZMODEM */
	/* We currently accept only YMODEM from a Citadel-86 */
	if ((*optstr) == '1') {
	    reply(YES);
	    splitF(netLog, "Using %s.\n", protocol[usingWCprotocol=YMODEM]);
	}
	else reply(NO, "Unsupported protocol");
    }
    else {	/* Assume we're talking to another Fnordadel/STadel */
	if (rec=netopt(optstr, &proto)) {
	    if (netWCstartup("Proto")) { /* "Y" packet has protocol in it */
		wcprintf("%c%s", YES, rec);
		endWC();
	    }
	    splitF(netLog, "Using %s.\n", protocol[usingWCprotocol=proto]);
	}
	else
	    reply(NO, optstr);
    }
}

/*
 * catchfile() - Receive a sent file
 */
static void
catchfile(char *fname, char *size, int gotID)
{
    LABEL fn;
    long atol(), free, sectors, usable;
    int count=0;

    if (netchdir(&cfg.codeBuf[cfg.receiptdir])) {
	strcpy(fn, fname);
	usable = sysRoomLeft();
	diskSpaceLeft(&cfg.codeBuf[cfg.receiptdir], &sectors, &free);

	splitF(netLog,
		"Receiving file `%s' (%s bytes, %ld free, %ld usable)%s.\n",
		fn, size, free, usable, (gotID ? "" : " from unknown node"));
	neterror(NO,
		"Receiving file `%s' (%s bytes, %ld free, %ld usable)%s.\n",
		fn, size, free, usable, (gotID ? "" : " from unknown node"));

	/* Will we accept file sends from unknown nodes? */
	if (!gotID && !(cfg.flags.ANONFILEXFER))
	    reply(NO, "Not accepting files");
	else if (atol(size) > MIN(free, usable))	/* Enough free space? */
	    reply(NO, "No room for file");
	else {
	    while (upfd = safeopen(fn, "rb")) {
		fclose(upfd);
		sprintf(fn, "a.%d", count++);
	    }
	    upfd = safeopen(fn, "wb");
	    reply(YES);
	    enterfile(sendARchar, usingWCprotocol);
	    fclose(upfd);
	    neterror(NO, count ? "Received file `%s' (saved as `%s')." :
		"Received file `%s'.", fname, fn);
	}
    }
    else
	reply(NO, oops);
    homeSpace();
}

/*
 * targetCheck() - checks for existence of recipients
 */
static void
targetCheck(void)
{
    if (msgBuf.mbto[0] && postmail(NO))
	return;
    
    wcprintf("%c%s", msgBuf.mbto[0] ? NO_RECIPIENT : BAD_FORM, msgBuf.mbauth);
    wcprintf("%s", msgBuf.mbto);
    wcprintf("%s @ %s", msgBuf.mbdate, msgBuf.mbtime);
}

/*
 * check_mail() - does negative acks on netMail
 */
static void
check_mail(void)
{
    if (processMail) {
	reply(YES);
	splitF(netLog, "Checking mail.\n");
	if (beginWC()) {
	    readMail(NO, targetCheck);
	    endWC();
	}
    }
    else
	reply(NO, "No mail to check");
}

/*
 * getnetmail() - Grabs mail from caller
 */
static void
getnetmail(int gotID)
{
    char    success;
    PATHBUF tempfile;

    /* Will we accept net mail from unknown nodes? */
    if (!gotID && !(cfg.flags.ANONNETMAIL)) {
	reply(NO, "Not accepting mail");
	return;
    }

    splitF(netLog, "Receiving mail%s.\n", gotID ? "" : " from unknown node");
    ctdlfile(tempfile, cfg.netdir, netmlspool);
    if (upfd = safeopen(tempfile, "wb")) {
	reply(YES);
	success = enterfile(sendARchar, usingWCprotocol);
	fclose(upfd);
	if (success)
	    processMail = YES;
	else
	    dunlink(tempfile);
    }
    else
	reply(NO, oops);
}

/* new C86 file request code put in by AA 90Aug31 */
static int
c86filereq(struct dirList *fn)
{
    FILE *fp;
    int status = YES;

    /*
     * The C86Net standard says that the correct response to a file request
     * is a series of header/file pairs for each file to be sent, terminated
     * with a null header.  The headers are of the format:
     *		<filename><0><size in 128 byte sectors><0><trash>
     * and a null header is one in which the <filename> is of zero-length.
     * After each header, the file is sent by ordinary ITL transfer.
     */

    if (fp = safeopen(fn->fd_name, "rb")) {
	if (beginWC()) {
	    wcprintf("%s", fn->fd_name);
	    wcprintf("%d", ((fn->fd_size / 128) + ((fn->fd_size % 128) > 0)));
	    endWC();
	}
	status = typeWC(fp);
	fclose(fp);
    }
    return status;
}

/*
 * flingfile() - sendfile driver
 */
static void
flingfile(char *room, char *files, int style, int gotID)
{
    int  roomSlot;
    char msg[60];
    struct dirList *f;

    splitF(netLog, "File `%s' requested from room `%s'%s.\n", files, room,
	(gotID ? "" : " by unknown node"));
    neterror(NO, "File `%s' requested from room `%s'%s.\n", files, room,
	(gotID ? "" : " by unknown node"));

    /* Will we accept file requests from unknown nodes? */
    if (!gotID && !(cfg.flags.ANONFILEXFER)) {
	reply(NO, "Not sending files");
	return;
    }

    if ((roomSlot = roomExists(room)) == ERROR ||
		    !(readbit(roomTab[roomSlot],ISDIR) &&
		      readbit(roomTab[roomSlot],NETDOWNLOAD)) ) {
	sprintf(msg, "Room `%s' does not exist", room);
	reply(NO, msg);
	return;
    }
    getRoom(roomSlot);

    if (netchdir(roomBuf.rbdirname)) {
	if ((f = getdirentry(files)) == NULL) {
	    sprintf(msg, "No file `%s'", files);
	    reply(NO, msg);
	    return;
	}
	reply(YES);
/* new C86 file request code put in by AA 90Aug31 */
/* ...and rehacked to support FR_C86SINGLE by AA 90Oct03 */
	if (style == FR_NORMAL) {
	    char netproto = usingWCprotocol;

	    batchWC = YES;		/* xmodem batch download... */
	    usingWCprotocol=YMODEM;
	    wildcard(download, files, 0L);
	    usingWCprotocol = netproto;
	}
	else if (style == FR_C86MULTI) {
	    wildcard(c86filereq, files, 0L);
	    if (beginWC()) {	    /* send terminating null header */
		wcprintf("");
		wcprintf("0");
		endWC();
	    }
	}
	else {	/* must be FR_C86SINGLE */
	    FILE *fp;

	    fp = safeopen(f->fd_name, "rb");
	    (void) typeWC(fp);
	    fclose(fp);
	}
    }
    else reply(NO, oops);
}

/*
 * catchroom() - Get a shared room
 */
static void
catchroom(char *rmname, int gotID)
{
    int  slot;
    char success;
    int  arraySlot;
    char *p;
    char msg[60];
    PATHBUF tempfile;

    p = chk_name(net_alias, thisNet, rmname);

    if ((slot = roomExists(p)) == ERROR) {
#if 0
	sprintf(msg, "Room `%s' does not exist", p);
#else
	sprintf(msg, "Room `%s' does not exist", rmname);
#endif
	reply(NO, msg);
	if (netDebug)
	    neterror(NO, (p == rmname) ? "Local room `%s' does not exist.\n" :
		"Local room `%s' (alias for `%s') does not exist.\n",
		p, rmname);
	return;
    }

    if (rmtslot == ERROR || !gotID || !readbit(roomTab[slot],SHARED)
			  || (arraySlot = issharing(slot)) == ERROR) {
#if 0
	sprintf(msg, "Room `%s' is not shared with you", p);
#else
	sprintf(msg, "Room `%s' is not shared with you", rmname);
#endif
	reply(NO, msg);
	if (netDebug)
	    neterror(NO, (p == rmname) ?
		"Local room `%s' is not shared with you.\n" :
		"Local room `%s' (alias for `%s') is not shared with you.\n",
		p, rmname);
	return;
    }

    ctdlfile(tempfile, cfg.netdir, netrmspool, slot);

    if ((upfd = safeopen(tempfile, "wb")) == NULL) {
	reply(NO, oops);
	return;
    }

    reply(YES);
    splitF(netLog, (p == rmname) ? "Receiving room `%s'.\n" :
	"Receiving room `%s' (alias for `%s').\n", p, rmname);
    success = enterfile(sendARchar, usingWCprotocol);
    fclose(upfd);
    if (success)
	sr_rcvd[arraySlot] = YES;
    else
	dunlink(tempfile);
}

/*
 * slavemode() - process net commands
 */
void
slavemode(int reversed, int gotID)
{
    LABEL msg;
    struct cmd_data cmd;

    splitF(netLog, "Remote system %sknown.\n", gotID ? "" : "not yet ");
    while (gotcarrier())
	switch(getnetcmd(&cmd, NO)) {
	    case HANGUP:
		return;
	    case SEND_MAIL:
		getnetmail(gotID);
		break;
	    case CHECK_MAIL:
		check_mail();
		break;
	    case SINGLE_FILE_REQUEST:		/* <grrrrrrrrrr> */
		flingfile(cmd.arg[0], cmd.arg[1], FR_C86SINGLE, gotID);
		break;
	    case FILE_REQUEST:
		flingfile(cmd.arg[0], cmd.arg[1], FR_C86MULTI, gotID);
		break;
	    case BATCH_REQUEST:
		flingfile(cmd.arg[0], cmd.arg[1], FR_NORMAL, gotID);
		break;
	    case SEND_FILE:
		catchfile(cmd.arg[0], cmd.arg[2], gotID);
		break;
	    case NET_ROOM:
		catchroom(cmd.arg[0], gotID);
		break;
	    case ROLE_REVERSAL:
		if (reversed)
		    reply(NO, "double role-reverse");
		else if (rmtslot != ERROR && gotID) {
		    splitF(netLog, "Now in master mode.\n");
		    reply(YES);

		    /* If we're dealing with a Cit-86, we need to send	*/
		    /* our password and request options set-up.		*/
		    if (readbit(netBuf,CIT86)) {
			if (netBuf.herPasswd[0])
			    netcommand(C86NETPW, netBuf.herPasswd, NULL);
			if (netcommand(C86ITLCHG, "1", NULL))
			    splitF(netLog, "Using %s.\n",
				protocol[usingWCprotocol=YMODEM]);
		    }

		    mastermode(YES);
		}
		else {
		    reply(NO, "Not tonight, I have a headache");
		    splitF(netLog, "Denied request for role-reversal.\n");
		}
		return;
	    case OPTIONS:
		chkproto(cmd.arg[0], NO);
		break;
	    case C86ITLCHG:
		chkproto(cmd.arg[0], YES);
		break;
	    case C86NETPW:
		reply(YES);
		if (stricmp(cmd.arg[0],netBuf.myPasswd) != 0) {
		    splitF(netLog, "Bad password `%s'.\n", cmd.arg[0]);
		    neterror(YES, "Bad password `%s'.", cmd.arg[0]);
		}
		else {
		    gotID = YES;
		    splitF(netLog, "Received & verified Cit-86 password.\n");
		}
		break;
	    default:
		sprintf(msg, "<%d> unknown", cmd.command);
		reply(NO, msg);
		break;
	}
}

/*
 * netopt() - parse a network options string and return a pointer to the list
 *		of options we will support during this session.
 */
char *
netopt(char *optstr, char *proto)
{
    for (; *optstr; ++optstr)
	switch (*optstr) {
	/*case 'w': *proto = WXMODEM; return "w";*/
	case 'y': *proto = YMODEM;  return "y";
	}
    *proto = XMODEM;		/* always set to base level protocol */
    return NULL;		/* and return a FAIL code */
}

/*
 * doSetup() - set up for networking with a specific system
 */
void
doSetup(void)
{
    int i;

/* sr_sent and sr_rcvd changed for dynamic SHARED_ROOMS by RH 90Mar05 */
    if (!sr_sent)
	sr_sent = (char *)xmalloc(SHARED_ROOMS * sizeof(char));
    if (!sr_rcvd)
	sr_rcvd = (char *)xmalloc(SHARED_ROOMS * sizeof(char));

    processMail = checkNegMail = NO;

    for (i=0; i<SHARED_ROOMS; i++) {
	sr_sent[i] = NO;
	sr_rcvd[i] = NO;
    }
}

/*
 * donetpurge() - sees to the purging of undesirable incoming traffic
 */

static int
donetpurge(void)
{
    char *temp;
    int len;
    struct user *p;

    if (purgelist) {
	p = purgelist;
	while (p) {
	    if ((temp = strchr(msgBuf.mbauth, '@')) == NULL)
		len = strlen(msgBuf.mbauth);
	    else {
		len = (int) (temp - msgBuf.mbauth);
		++temp;		/* Point at node name of origin */
	    }
	    if ((strnicmp(msgBuf.mbauth,p->name,len) != 0) &&
		(stricmp(msgBuf.mboname,p->name) != 0) &&
		(temp == NULL || (stricmp(temp,p->name) != 0)))
		p = p->next;
	    else
		return YES;
	}
    }
    return NO;
}

/*
 * doNetRooms() - integrates temporary files into data base
 */

#define fixRC(idx)	(netBuf.shared[idx].NRhub ? ROUTE_HUB : ROUTE_LOCAL)

static void
doNetRooms(void)
{
    char no_zap;
    int idx;
    int roomNo;
    time_t now;
    PATHBUF tempfile, fn;
    FILE *spl, *discard;

    init_zap();
    for (idx = 0; idx < SHARED_ROOMS; idx++) {
	if (sr_rcvd[idx]) {
	    ctdlfile(tempfile, cfg.netdir, netrmspool,
			    roomNo=netBuf.shared[idx].NRidx);
	    
	    if ((spl = safeopen(tempfile, "rb")) == NULL) {
		neterror(YES, "Can't open file `%s'.", tempfile);
		close_zap();
		return;
	    }
	    getRoom(roomNo);
	    while (getspool(spl)) {
		/*
		 * make ABSOLUTELY sure that the routing address is
		 * properly set up
		 */
		if (!msgBuf.mbroute[0])
		    sprintf(msgBuf.mbroute, "@L%s", rmt_id);

		/* added by A&R 91Feb04 */
		set(msgBuf,mNETMESSAGE);
		/*
		 * forbid message-bouncing
		 */
		if (stricmp(&cfg.codeBuf[cfg.nodeId], msgBuf.mborig) != 0) {
		    /*
		     * Set the message route char to reflect what this
		     * node thinks the link is.
		     *
		     * ?->Local : @H, @O -> @L
		     * ?->Hub   : @L, @O -> @H
		     *
		     * Unless the room is a forwarder, that is...
		     */
		    ROUTECHAR(&msgBuf) = fixRC(idx);

		    /* Does the message pass the loop-zapper & purger? */
#if 0
		    if (notseen()) {
			if (msgpurge && donetpurge())	/* Purge this msg? */
			    splitF(netLog, "purge %s <%s in %s, %s@%s>\n",
				msgBuf.mboname, msgBuf.mbauth, msgBuf.mbroom,
				msgBuf.mbdate, msgBuf.mbtime);
			else
			    storeMessage(NULL, ERROR);
		    }
		    else
			splitF(netLog, "reject %s (%s) <%s in %s, %s@%s>\n",
					msgBuf.mboname, msgBuf.mborig,
					msgBuf.mbauth, msgBuf.mbroom,
					msgBuf.mbdate, msgBuf.mbtime);
#else
		    if ((no_zap = notseen()) &&
			!(msgpurge && (cfg.flags.PURGENET) && donetpurge()))
			storeMessage(NULL, ERROR);
		    else {
			splitF(netLog, "%s system %s (%s):\n<%s in %s, %s@%s>.\n",
			    no_zap ? "Purge" : "Zap",
			    msgBuf.mboname, msgBuf.mborig, msgBuf.mbauth,
			    msgBuf.mbroom, msgBuf.mbdate, msgBuf.mbtime);
			neterror(NO, "%s system %s (%s):\n<%s in %s, %s@%s>.\n",
			    no_zap ? "Purge" : "Zap",
			    msgBuf.mboname, msgBuf.mborig, msgBuf.mbauth,
			    msgBuf.mbroom, msgBuf.mbdate, msgBuf.mbtime);
			if ((cfg.flags.KEEPDISCARDS)) {
			    ctdlfile(fn, cfg.netdir, "%lx.dis",
				(now = time(NULL)));
			    while (getdirentry(fn)) {
				now--;
				ctdlfile(fn, cfg.netdir, "%lx.dis", now);
			    }

			    if ((discard = safeopen(fn, "wb")) == NULL)
				neterror(YES, "Can't open discard file `%s'.",
					fn);
			    else {
				strcpy(msgBuf.mbroom, roomBuf.rbname);
				_spool(discard);
				fclose(discard);
			    }
			}
		    }
#endif
		}
	    }
	    fclose(spl);
	    dunlink(tempfile);
	}
    }
    close_zap();
}

/*
 * doResults() - processes results of receiving thingies and such
 */
void
doResults(void)
{
    int idx;

    modemClose();	/* don't let calls in while processing stuff */
    if (processMail)
	readMail(YES, inMail);
    if (rmtslot == ERROR) {		/* unregistered callers can't */
	modemOpen();
	return;				/* do anything but send mail  */
    }
    if (checkNegMail)
	readNegMail();
    doNetRooms();
    /*
     * update shared room indices for all rooms that we sent to the
     * other system.
     */
    for (idx=0; idx<SHARED_ROOMS; idx++)
	if (sr_sent[idx])
	    netTab[thisNet].Tshared[idx].NRlast =
		      netBuf.shared[idx].NRlast = cfg.newest;

    putNet(thisNet);
    modemOpen();	/* back in business! */
}

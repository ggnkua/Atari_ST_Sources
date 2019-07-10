/* #define NCDEBUG 1 */

/*
 * netcall.c -- master mode networking.
 *
 * 90Dec15 RH	Added support for Citadel-86 style net passwords
 * 88Jul21 orc	support OPTIONS commands for selecting net protocol
 * 88Jul16 orc	replace old network file request/sendfile code
 * 87Dec23 orc	remove NeedsProcessing() macros and do processing on a
 *		call-by-call basis
 * 87Oct22 orc	obsolete R_FILE_REQ, NET_PASSWD
 *		Have role-reverse and node init do password exchange
 * 87Sep16 orc	use netPrintMsg() for network message dumping...
 * 87Jul26 orc	allow l-d role reversal.
 * 87May17 orc	network sendfile.
 * 87May15 orc	printMess parameter mismatch straightened out.
 * 87Apr01 orc	hacked up for STadel.
 *		(All system-independancies 'temporarily' commented out)
 * 86Aug20 HAW	History not maintained due to space problems.
 */

#include <stdarg.h>
#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "msg.h"
#include "room.h"
#include "dirlist.h"
#include "protocol.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * * netlogin()		Sends ID to the receiver
 * caller()		Network with callee
 * mastermode()		assume role of sender
 * caller_stabilize()	Tries to stabilize the call
 * sendMail()		send normal mail to receiver
 * sendRouteMail()	send forwarded mail to receiver
 * checkMail()		negative acknowledgement on netmail>
 * readNegMail()	reads and processes negative acks
 * * throwMessages()	send a single shared room
 * sendSharedRooms()	Sends all shared rooms to receiver
 * netcommand()		Sends a command to the receiver
 * s_n_m()		Send normal mail
 * s_f_m()		Send forwarded mail
 */

char checkNegMail;
char netmlcheck[] = "$chkmail";
char *strchr();

/*
 * netWCstartup()
 */
int
netWCstartup(char *from)
{
    if (beginWC())
	return YES;
    neterror(YES, "Lockup during setup for `%s'.", from);
    return NO;
}

/*
 * netlogin() - Sends ID to the receiver
 */
static void
netlogin(void)
{
    if (!readbit(netBuf,CIT86))		/* Talking to Fnordadel/STadel? */
	netcommand(LOGIN, &cfg.codeBuf[cfg.nodeId], &cfg.codeBuf[cfg.nodeName],
	    netBuf.herPasswd, NULL);
    else				/* Talking to Cit-86, don't send pw */
	netcommand(LOGIN, &cfg.codeBuf[cfg.nodeId], &cfg.codeBuf[cfg.nodeName],
	    NULL);
}

/*
 * caller_stabilize() - Tries to stabilize the call
 */
static int
caller_stabilize(void)
{
    int tries, j;
    register short x1, x2, x3;

    pause(20);
    for (tries = 0; tries < 20 && gotcarrier(); tries++) {
	modputs(N_SEQ);
	/*modout(07); pause(10); modout(13); pause(10); modout(69);*/
	for (j=0; j<50 && (x1=receive(1)) != ERROR && x1 != N0_REP; j++)
	    if (netDebug)
		splitF(netLog, "%c", x1);

	if (x1 == N0_REP) {
	    if ((x2 = receive(2)) != ERROR)
		x3 = receive(2);
	    if (x2 == N1_REP && x3 == N2_REP) {
		modout(ACK);
		if (netDebug)
		    splitF(netLog, "[ACK]\n");
		return gotcarrier();
	    }
	    else if (netDebug)
		splitF(netLog, "<%d,%d>", x2, x3);
	    /*
	     * called someone when they're calling me -- bye!
	     */
	    if (x1 == N0_KEY && x2 == N1_KEY && x3 == N2_KEY)
		break;
	}
    }
    splitF(netLog, "Not stabilized.\n");
    hangup();
    return FALSE;
}

/*
 * caller() -- called someone for networking
 */
int
caller(void)
{
    char proto;

    splitF(netLog, "Have carrier.\n");
    if (!caller_stabilize())
	return NOT_STABILISED;

    usingWCprotocol = XMODEM;
    netlogin();
    if (gotcarrier()) {
	doSetup();

	/* Request net protocols appropriate for the receiving system */
	if (readbit(netBuf,CIT86)) {	/* Calling a Citadel-86? */

	    if (netBuf.herPasswd[0])	/* Send net password first? */
		netcommand(C86NETPW, netBuf.herPasswd, NULL);

	    if (netcommand(C86ITLCHG, "1", NULL))    /* Only Ymodem for now */
		splitF(netLog, "Using %s.\n", protocol[usingWCprotocol=YMODEM]);
	}
	else {		/* Assume we're talking to Fnordadel/STadel */
	    if (netcommand(OPTIONS, netymodem ? "y" : "wy", NULL) &&
			(netopt(1+sectBuf, &proto)))
		splitF(netLog, "Using %s.\n", protocol[usingWCprotocol=proto]);
	}
	mastermode(NO);

	doResults();
	splitF(netLog, "Done @ %s.\n\n", tod(NO));
	return CALL_OK;
    }
    return NO_ID;
}

/*
 * s_n_m() -- Send normal mail
 */
static int
s_n_m(void)
{
    FILE  *mail;
    char  c, temp[80];
    PATHBUF fn;
    int   msgs = 0, ournet = thisNet, cost;
    NETADDR    to;
    LABEL first;
    int   loc;
    long  id;

    ctdlfile(fn, cfg.netdir, "%d.ml", thisNet);

    if ((mail=safeopen(fn, "r")) == NULL)
	return 0;

    route_char = 0;
    while (fgets(temp,80,mail) && !WCError)
	if (sscanf(temp, "%ld %d", &id, &loc) == 2 && findMessage(loc,id)) {
	    splitF(netLog, "Sending mail to `%s' from `%s'.\n",
		msgBuf.mbto, msgBuf.mbauth);
	    strcpy(to, msgBuf.mbto);
	    parsepath(to, first, YES);		/* get pathname and */
	    findnode(first, &cost);		/* modify to: field */
	    changeto(to, first);
	    sendXmh();
	    (*sendPFchar)('M');
	    while ((*sendPFchar)(c=getmsgchar()) && c)
		;
	    msgs++;
	}
    fclose(mail);
    getNet(ournet);
    if (WCError) {
	hangup();
	return 0;
    }
    dunlink(fn);
    return msgs;
}

/*
 * s_f_m() - Send forwarded mail
 */
static int
s_f_m(FILE *spl)
{
    register i,c;
    int count = 0;

    route_char = 0;
    while (getspool(spl) && !WCError) {
	splitF(netLog, "Forwarding mail to `%s' from `%s @ %s'.\n",
	    msgBuf.mbto, msgBuf.mbauth, msgBuf.mboname);
	sendXmh();
	(*sendPFchar)('M');
	for (i=0; (c=msgBuf.mbtext[i]) && !WCError; i++)
	    (*sendPFchar)(c);
	(*sendPFchar)(0);
	++count;
    }
    if (WCError) {
	hangup();
	return 0;
    }
    return count;
}

/*
 * sendMail()
 */
static void
sendMail(void)
{
    PATHBUF fn;
    FILE *spl;

    splitF(netLog, "Sending mail.\n");
    if (netcommand(SEND_MAIL, NULL) && netWCstartup("Mail")) {
	splitF(netLog, "Sent %s.\n", plural("message", (long)s_n_m()) );
	if (gotcarrier()) {
	    ctdlfile(fn, cfg.netdir, "%d.fwd", thisNet);
	    if (spl = safeopen(fn, "rb")) {
		splitF(netLog, "Forwarded %s.\n",
		    plural("message",(long)s_f_m(spl)));
		fclose(spl);
	    }
	    if (gotcarrier()) {
		endWC();
		dunlink(fn);
		clear(netBuf,MAILPENDING);
	    }
	}
    }
}

/*
 * checkMail() - negative acknowledgement on netmail
 */
static void
checkMail(void)
{
    PATHBUF chkfile;

    ctdlfile(chkfile, cfg.netdir, netmlcheck);

    if (upfd=safeopen(chkfile, "wb")) {
	splitF(netLog, "Asking for checkmail.\n");
	if (netcommand(CHECK_MAIL, NULL) && enterfile(sendARchar, usingWCprotocol))
	    checkNegMail = YES;
	fclose(upfd);
    }
    else neterror(NO, "Couldn't create `%s'.", chkfile);
}

/*
 * throwMessages() - throw messages from a room
 */
static void
throwMessages(int index)
{
    register idx;
    char *tosend;
    long lastmsg = 0;

    /* 
     * Hub -> ?   : @L, @O -> @H
     * Local -> ? : @H, @O -> @L
     */
    if (netBuf.shared[index].NRhub) {	/* figure out sending classes	*/
	tosend = "OLH";			/* send all messages here	*/
	route_char = ROUTE_HUB;		/* mapped to @H			*/
    }
    else {
	tosend = "OH";			/* send originate & hub messages*/
	route_char = ROUTE_LOCAL;
    }
    
    if (!netWCstartup("Share"))
	return;
    /*
     * send messages that are > than the last message we sent and that
     * citadel can find and that have the route-char set and are
     * properly routable.
     */
    for (idx = 0; idx < NUMMSGS; idx++)
	if (netBuf.shared[index].NRlast < roomBuf.msg[idx].msgno
		&& findMessage(roomBuf.msg[idx].msgloc,
			       roomBuf.msg[idx].msgno)) {
#ifdef NCDEBUG
	    splitF(netLog, "message#%ld,route=<%s>,auth=<%s>\n",
			    roomBuf.msg[idx].msgno,
			    msgBuf.mbroute,
			    msgBuf.mbauth);
#endif

	    if (ROUTEOK(&msgBuf) && strchr(tosend, ROUTECHAR(&msgBuf))
		    && stricmp(ROUTEFROM(&msgBuf), rmt_id) != 0) {
		netPrintMsg(roomBuf.msg[idx].msgloc,roomBuf.msg[idx].msgno);
		/*
		 * update lastMess to last message actually sent...
		 */
		if (roomBuf.msg[idx].msgno > lastmsg)
		    lastmsg = roomBuf.msg[idx].msgno;
	    }
	}

    if (WCError)
	hangup();
    else {
	endWC();
#ifdef NCDEBUG
	splitF(netLog, "old lastMess=%ld, lastmsg=%ld\n",
			netBuf.shared[index].NRlast, lastmsg);
#endif
	sr_sent[index] = YES;
    }
}

/*
 * sendSharedRooms() - Sends all shared rooms to receiver
 */
static void
sendSharedRooms(void)
{
    int idx;
    char *p;
    extern int mesgpending(struct netroom *nr);

    for (idx = 0; gotcarrier() && idx < SHARED_ROOMS; idx++) {
	if (sharing(idx))
	    if (mesgpending(&netBuf.shared[idx])) {
		getRoom(netBuf.shared[idx].NRidx);
		p = chk_alias(net_alias, thisNet, roomBuf.rbname);

		splitF(netLog, (p == roomBuf.rbname) ? "Sending room `%s'.\n" :
			"Sending room `%s' (alias for `%s').\n",
			roomBuf.rbname, p);

		if (netcommand(NET_ROOM, p, NULL))
		    throwMessages(idx);
		else if (netDebug)
		    neterror(NO, (p == roomBuf.rbname) ?
			"Couldn't send room `%s'.\n" :
			"Couldn't send room `%s' (alias for `%s').\n",
			roomBuf.rbname, p);
	    }
	    else			/* nothing to send is the moral */
		sr_sent[idx] = YES;	/* equivalent of sending stuff  */
    }
}

/*
 * mastermode() - assume role of sender
 */
void
mastermode(int reversed)
{
    if readbit(netBuf,MAILPENDING) {
	if (gotcarrier())
	    sendMail();
	if (gotcarrier())
	    checkMail();
    }
    if (gotcarrier())
	sendSharedRooms();
    if (gotcarrier())
	nfs_process();
    if (gotcarrier())
	if ((readbit(netBuf,LD_RR) || !netBuf.ld)
		&& !reversed && netcommand(ROLE_REVERSAL, NULL)) {
	    splitF(netLog, "Now in slave mode.\n");
	    slavemode(YES, YES);	/* 2nd YES indicates positive ID */
	}
	else
	    netcommand(HANGUP, NULL);
    hangup();
}

/*
 * readNegMail() - reads and processes negative acks
 */
void
readNegMail(void)
{
    int key;
    NETADDR author, target;
    PATHBUF context, chkfile;
    FILE *spl;

    ctdlfile(chkfile, cfg.netdir, netmlcheck);

    if ((spl = safeopen(chkfile, "rb")) == NULL)
	return;
    while ((key = getc(spl)) != EOF && key != NO_ERROR) {
	zero_struct(msgBuf);
	strcpy(msgBuf.mbauth, program);
	getstrspool(spl, author, ADDRSIZE);
	getstrspool(spl, target, ADDRSIZE);
	getstrspool(spl, context, ADDRSIZE);
	if (key == NO_RECIPIENT && strlen(author) > 0
				&& stricmp(author, program) != 0) {
	    strcpy(msgBuf.mbto, author);
	    sprintf(msgBuf.mbtext, "Cannot deliver mail to `%s@%s' (%s).",
				    target, rmtname, context);
	    postmail(YES);
	}
    }
    fclose(spl);
    dunlink(chkfile);
}

/*
 * netcommand() -- Sends a command
 */
int
netcommand(int cmd, ...)
{
    va_list args;
    char *p;
    int count;

    if (!netWCstartup("Cmd"))
	return NO;
    if (cmd != LOGIN)
	(*sendPFchar)(cmd);
    va_start(args,cmd);
    for (count=0; count<4 && (p=va_arg(args, char*)) != NULL; count++)
	wcprintf("%s", p);
    va_end(args);
    (*sendPFchar)(0);
    endWC();

    counter = 0;
    if (cmd == HANGUP || cmd == LOGIN)	/* hup?  Okay... */
	return YES;
    if (enterfile(increment, usingWCprotocol) && gotcarrier()) {
	if (sectBuf[0])
	    return YES;
	if (cmd != OPTIONS)
	    neterror(NO, "Replies `%s'.", &sectBuf[1]);
    }
    else
	neterror(YES, "Hangup during command <%d>.", cmd);
    return NO;
}


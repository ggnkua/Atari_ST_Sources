/*
 * citpeek.c - Sneak a peek at Fnordadel datafiles; for privileged eyes only!
 *
 * 90Dec05 AA	Munged a bit for gcc
 * 90Aug03 AA	Menu mode added; showconfig() filled in
 * 90Mar25 AA	Created.
 */

#include "ctdl.h"
#include "net.h"
#include "room.h"
#include "log.h"
#include "msg.h"
#include "floor.h"
#include "config.h"
#include "citlib.h"

/* globals */
char *program = "citpeek";
int logfl;				/* log file descriptor		*/
char echo;
char Debug = NO;
typedef char BINBUF[33];		/* buffer to hold long (binary)	*/

int missing[4] = { NO, NO, NO, NO };
#define MSG 0
#define LOG 1
#define NET 2
#define FLR 3

/* stolen from output.c */
char prevchar = 0;
char *CRfill = NULL;
void (*CRftn)() = NULL;
char outFlag = OUTOK;
struct logBuffer logBuf;

/* FIXME: */
char remoteSysop;

extern int PATCHNUM;

/*
 * binary() -- take a long value and turn into a string of ones & zeros
 */
void
binary(long value, char *str)
{
    register long val = value;
    register int i;

    strcpy(str,"00000000000000000000000000000000");
    for (i=1; i<=32; i++) {
	str[32-i] = (val&1L) ? '1' : '0';
	val = val>>1;
    }
}

/*
 * getnormstr() -- get a string and delete extraneous blanks, etc
 *		   returns NO if blank line is input, YES otherwise
 */
int
getnormstr(char *prompt, char *buf, int lim)
{
    int c, i;

    if (strlen(prompt) > 0)
	printf("%s: ", prompt);

    i = 0;
    while ( (c = getch()) != '\r') {
	/* handle delete chars: */
	if (c == '\b') {
	    if (i > 0) {
		i--;
		fputs("\b \b", stdout);
	    }
	    else
		putchar(BELL);
	}
	else if (i < lim) {
	    buf[i++] = c;
	    putchar((c>=32) ? c : '@');
	}
	else
	    putchar(BELL);
    }
    putchar('\n');
    buf[i] = 0;

    normalise(buf);

    return(*buf == '\0' ? NO : YES);
}

/*
 * showconfig() -- print information about struct cfg
 */
void
showconfig(void)
{
    int i;

    printf("showconfig()\n");
    printf("maxMSector: %d\tcatChar: %d\tcatSector: %d\n",
	cfg.maxMSector, cfg.catChar, cfg.catSector);
    printf("oldest: %ld\tnewest: %ld\n", cfg.oldest, cfg.newest);
    printf("cryptSeed: %d\tlogsize: %d\tmailslots: %d\tmaxrooms: %d\n",
	cfg.cryptSeed, cfg.logsize, cfg.mailslots, cfg.maxrooms);
    printf("sharedrooms: %d\tmaxmsgs: %d\tmaxmailmsgs: %d\tmaxcalls: %d\n",
	cfg.sharedrooms, cfg.maxmsgs, cfg.maxmailmsgs, cfg.maxcalls);
    printf("maxtime: %d\tmaxclosecalls: %d\tclosetime: %d\tmincalltime: %d\n",
	cfg.maxtime, cfg.maxclosecalls, cfg.closetime, cfg.mincalltime);
    printf("newusermsgs: %d\n", cfg.newusermsgs);

    printf("flags:\n");
    if (cfg.flags.ENTEROK)
	printf("\tENTEROK");
    if (cfg.flags.READOK)
	printf("\tREADOK");
    if (cfg.flags.LOGINOK)
	printf("\tLOGINOK");
    if (cfg.flags.ROOMOK)
	printf("\tROOMOK");
    if (cfg.flags.NOMAIL)
	printf("\tNOMAIL");
    if (cfg.flags.ALLNET)
	printf("\tALLNET");
    if (cfg.flags.GETNAME)
	printf("\tGETNAME");
    if (cfg.flags.KEEPHOLD)
	printf("\tKEEPHOLD");
    if (cfg.flags.AIDE_FORGET)
	printf("\tAIDE_FORGET");
    if (cfg.flags.SHOWRECD)
	printf("\tSHOWRECD");
    if (cfg.flags.NOCHAT)
	printf("\tNOCHAT");
    if (cfg.flags.DISKUSAGE)
	printf("\tDISKUSAGE");
    if (cfg.flags.ARCHIVE_MAIL)
	printf("\tARCHIVE_MAIL");
    if (cfg.flags.SYSOPSLEEP)
	printf("\tSYSOPSLEEP");
    if (cfg.flags.AIDEKILLROOM)
	printf("\tAIDEKILLROOM");
    if (cfg.flags.DEBUG)
	printf("\tDEBUG");
    if (cfg.flags.FZAP)
	printf("\tFZAP");
    if (cfg.flags.FNETLOG)
	printf("\tFNETLOG");
    if (cfg.flags.FNETDEB)
	printf("\tFNETDEB");
    if (cfg.flags.USA)
	printf("\tUSA");
    if (cfg.flags.PATHALIAS)
	printf("\tPATHALIAS");
    if (cfg.flags.FORWARD_MAIL)
	printf("\tFORWARD_MAIL");
    if (cfg.flags.SEARCH_BAUD)
	printf("\tSEARCH_BAUD");
    if (cfg.flags.CONNECTPROMPT)
	printf("\tCONNECTPROMPT");
    if (cfg.flags.MODEMCC)
	printf("\tMODEMCC");
    if (cfg.flags.HAYES)
	printf("\tHAYES");
    if (cfg.flags.ANONNETMAIL)
	printf("\tANONNETMAIL");
    if (cfg.flags.ANONFILEXFER)
	printf("\tANONFILEXFER");
    if (cfg.flags.PURGENET)
	printf("\tPURGENET");
    if (cfg.flags.KEEPDISCARDS)
	printf("\tKEEPDISCARDS");
    printf("\n");

    /* codeBuf[] */
    printf("nodeName: %s (%d)\n", &cfg.codeBuf[cfg.nodeName], cfg.nodeName);
    printf("nodeTitle: %s (%d)\n", &cfg.codeBuf[cfg.nodeTitle],	cfg.nodeTitle); 
    printf("nodeId: %s (%d)\n", &cfg.codeBuf[cfg.nodeId], cfg.nodeId);
    printf("shell: %s (%d)\tsysopName: %s (%d)\thub: %s (%d)\n",
	&cfg.codeBuf[cfg.shell], cfg.shell, &cfg.codeBuf[cfg.sysopName],
	cfg.sysopName, &cfg.codeBuf[cfg.hub], cfg.hub);
    printf("organization: %s (%d)\n", &cfg.codeBuf[cfg.organization],
	cfg.organization);
    printf("sysdir: %s (%d)\thelpdir: %s (%d)\tmsgdir: %s (%d)\n",
	&cfg.codeBuf[cfg.sysdir], cfg.sysdir, &cfg.codeBuf[cfg.helpdir],
	cfg.helpdir, &cfg.codeBuf[cfg.msgdir], cfg.msgdir);
    printf("netdir: %s (%d)\tauditdir: %s (%d)\n",
	&cfg.codeBuf[cfg.netdir], cfg.netdir,
	&cfg.codeBuf[cfg.auditdir], cfg.auditdir);
    printf("receiptdir: %s (%d)\troomdir: %s (%d)\n",
	&cfg.codeBuf[cfg.receiptdir], cfg.receiptdir,
	&cfg.codeBuf[cfg.roomdir], cfg.roomdir);
    printf("holddir: %s (%d)\n",
	&cfg.codeBuf[cfg.holddir], cfg.holddir);
    printf("modemSetup: %s (%d)\n", &cfg.codeBuf[cfg.modemSetup],
	cfg.modemSetup);
    for (i=0; i<NUMBAUDS; i++)
	printf("mCCs[%d]: %s (%d)\n", i, &cfg.codeBuf[cfg.mCCs[i]],
	    cfg.mCCs[i]);
    printf("dialPrefix: %s (%d)\tdialSuffix: %s (%d)\n",
	&cfg.codeBuf[cfg.dialPrefix], cfg.dialPrefix,
	&cfg.codeBuf[cfg.dialSuffix], cfg.dialSuffix);
    /* end of codeBuf[] */

    printf("sysPassword: %s\n", cfg.sysPassword);
    printf("recSize: %d\tsyswidth: %d\tcall_log: %d\n", cfg.recSize,
	cfg.syswidth, cfg.call_log);
    printf("evtCount: %d\tfloorCount: %d\tzap_count: %d\tnetSize: %d\n",
	cfg.evtCount, cfg.floorCount, cfg.zap_count, cfg.netSize);
    printf("poll_count: %d\tpoll_delay: %ld\tsysBaud: %d\n",
	cfg.poll_count, cfg.poll_delay, cfg.sysBaud);
    printf("probug: %d\tconnectDelay: %d\tlocal_time: %d\tld_time: %d\n",
	cfg.probug, cfg.connectDelay, cfg.local_time, cfg.ld_time);
    printf("download: %ld\tld_cost: %d\thubcost: %d\n", cfg.download,
	cfg.ld_cost, cfg.hubcost);
    putchar('\n');
}

/*
 * showfloor() -- print out stuff about the floors
 */
void
showfloor(void)
{
    printf("showfloor()\n");
}

/*
 * showlog() -- examine userlog entries
 */
void
showlog(void)
{
    LABEL username;
    BINBUF binflags;
    int i;

    while (getnormstr("Name of user to display (<CR> to end)", username,
	NAMESIZE-1)) {			/* get max. 19 characters */
	for (i=0; i<cfg.logsize; i++)
	    if (hash(username) == logTab[i].ltnmhash)
		break;
	if (i<cfg.logsize) {
	    getlog(&logBuf, logTab[i].ltlogSlot, logfl);
	    binary(logBuf.flags, binflags);
	    printf("\nUsername: %s\n", logBuf.lbname);
	    printf("\tPassword:\t%s\n", logBuf.lbpw);
	    printf("\tflags:\t\t0x%lx (%s)\n", logBuf.flags, binflags);
	    printf("\tlbnulls:\t%d\n", (int)logBuf.lbnulls);
	    printf("\tlbwidth:\t%d\n", (int)logBuf.lbwidth);
	    printf("\tcredit:\t\t%d\n", logBuf.credit);
	    printf("\tlbdownloadlimit:\t%ld\n", logBuf.lbdownloadlimit);
	    printf("\tlbcalls:\t%d\n", logBuf.lbcalls);
	    printf("\tlbtime:\t\t%d\n", logBuf.lbtime);
	    printf("\tlbclosecalls:\t%d\n", logBuf.lbclosecalls);
	    printf("\tlbreadnum:\t%d\n", logBuf.lbreadnum);
	    printf("\tlblast:\t\t%ld (%s)\n\n", logBuf.lblast,
		makedate(logBuf.lblast, YES));
	    if (conGetYesNo("Display mail pointers")) {
		printf("\tlbmail:\tmsgno\t\tmsgloc\n");
		for (i = 0; i < MAILSLOTS; i++)
		    printf("\t\t%ld (%lx)\t%d\n",
			MAILNUM(logBuf.lbmail[i].msgno),
			logBuf.lbmail[i].msgno,
			logBuf.lbmail[i].msgloc);
	    }
	    printf("\n");	/* The end */
	}
	else
	    printf("\nNo user by that name.\n\n");
    }
}

/*
 * Support functions for printing messages; most of these things stolen from
 * output.c and hacked for console-only output.
 */

void
doCR(void)
{
    doNL('\r');
    prevchar = '\r';
}

void
doNL(char c)
{
    register i;
    extern int column;

    prevchar = ' ';
    column = 1;
    if (c == '\f')
	mprintf("^L");
    putchar('\n');
}

void
oChar(char c)
{
    prevchar = c;			/* for end-of-paragraph code	*/
    if (c == '\n')			/* suck up soft newlines	*/
	c = ' ';
    putchar(c);
}

int
mAbort(void)
{
    return NO;
}

/* end of support funcs */

/*
 * showmsg() -- view individual messages in ctdlmsg.sys
 */
void
showmsg(void)
{
    LABEL input;
    long id = 1L;
    short loc = 1;
    int i;
    short j;

    logBuf.lbnulls = 0;
    logBuf.lbwidth = 79;	/* for the formatter */

    while (getnormstr("\nEnter msg ID# & optional sector loc as 'xxxx [yy]'; <CR> to end",
			input, NAMESIZE - 1)) {
	i = sscanf(input, "%ld %hd", &id, &loc);
	if (i == 2) {
	    if (findMessage(loc, id)) {
		getmsgstr(msgBuf.mbtext, MAXTEXT);
		putheader(0);
		mformat(msgBuf.mbtext);
		putchar('\n');
	    }
	}
	else if (i == 1) {
	    for (j = 0; j < cfg.maxMSector; j++) {
		if (findMessage(j, id)) {
		    printf("Found it in sector %d\n", j);
		    getmsgstr(msgBuf.mbtext, MAXTEXT);
		    putheader(0);
		    mformat(msgBuf.mbtext);
		    putchar('\n');
		    break;
		}
	    }
	}
	else
	    printf("fargup.\n");
    }
}

/*
 * shownet() -- examine network nodes from ctdlnet.sys
 */
void
shownet(void)
{
    LABEL nodename;
    BINBUF binflags, binnets;
    int i;

    while (getnormstr("Name of net node to display (<CR> to end)", nodename,
	NAMESIZE-1)) {			/* get max. 19 characters */
	for (i=0; i<cfg.netSize; i++)
	    if (readbit(netTab[i],N_INUSE) && 
		(hash(nodename) == netTab[i].ntnmhash))
		break;
	if (i<cfg.netSize) {
	    getNet(i);
	    binary(netBuf.flags, binflags);
	    binary(netBuf.what_net, binnets);
	    printf("\nNodename: %s (slot %d)\n", netBuf.netName, i);
	    printf("\tnetId:\t\t%s\n", netBuf.netId);
	    printf("\tmyPasswd:\t%s\n",
		(netBuf.myPasswd[0] == '\0' ? "<none>" : netBuf.myPasswd));
	    printf("\therPasswd:\t%s\n",
		(netBuf.herPasswd[0] == '\0' ? "<none>" : netBuf.herPasswd));
	    printf("\tflags:\t\t0x%lx (%s)\n", netBuf.flags, binflags);
	    printf("\tld (pollcount):\t%d\n", netBuf.ld);
	    printf("\tdialer:\t\t%d\n", netBuf.dialer);
	    printf("\tpoll_day:\t0x%x\n", netBuf.poll_day);
	    printf("\twhat_net:\t0x%lx (%s)\n", netBuf.what_net, binnets);
	    printf("\tbaudCode:\t%d\n", netBuf.baudCode);
	    printf("\taccess:\t\t%s\n",
		(netBuf.access[0] == '\0' ? "<none>" : netBuf.access));
	    printf("\n");	/* The end */
	}
	else
	    printf("\nNo node by that name.\n\n");
    }
}

/*
 * showroom() -- print data from roomnnnn.sys
 */
void
showroom(void)
{
    LABEL roomname, floorname;
    BINBUF binflags;
    int i, j;

    while (getnormstr("Name of room to display (<CR> to end)", roomname,
	NAMESIZE-1)) {			/* get 19 character roomnames */
	for (i=0; i<MAXROOMS; i++)
	    if (stricmp(roomname, roomTab[i].rtname) == 0)
		break;
	if (i<MAXROOMS) {
	    getRoom(i);
	    /* find the name of the floor this room is on */
	    for (j=0; j<cfg.floorCount; j++)
		if ((floorTab[j].flInUse) &&
		    (roomBuf.rbfloorGen == floorTab[j].flGen)) {
		    strcpy(floorname, floorTab[j].flName);
		    break;
		}
	    binary(roomBuf.flags, binflags);
	    printf("\nRoomname: %s\n", roomBuf.rbname);
	    printf("\trbgen:\t\t%u\n", roomBuf.rbgen);
	    printf("\trbfloorgen:\t%d (%s)\n", roomBuf.rbfloorGen, floorname);
	    printf("\tflags:\t\t0x%lx (%s)\n", roomBuf.flags, binflags);
	    printf("\trblastNet:\t%ld\n", roomBuf.rblastNet);
	    printf("\trblastLocal:\t%ld\n", roomBuf.rblastLocal);
	    printf("\trblastMessage:\t%ld\n", roomBuf.rblastMessage);
	    printf("\trbdirname:\t%s\n",
		(roomBuf.rbdirname[0]=='\0' ? "<none>" : roomBuf.rbdirname)); 
	    printf("\tnummsgs:\t%u\n", roomBuf.nummsgs);
	    printf("\n");	/* The end */
	}
	else
	    printf("\nNo room by that name.\n\n");
    }
}

/*
 * shlogtab() -- print data from the logTab[]
 */
void
shlogtab(void)
{
    register int i;

    printf("\nContents of logTab[i]:\n\n");
    printf("   i  ltpwhash  ltnmhash  ltlogSlot  ltnewest\n\n");
    for (i=0; i<cfg.logsize; i++)
	printf("%4d%10d%10d%11d%10ld\n", i, logTab[i].ltpwhash,
	    logTab[i].ltnmhash, logTab[i].ltlogSlot, logTab[i].ltnewest);
    printf("\n\tThe End\n");
}

/*
 * shnettab() -- print data from the netTab[]
 */
void
shnettab(void)
{
    register int i, j;
    LABEL nodename;

    printf("\nContents of netTab[i]: (* == in use)\n\n");
    printf("    i  ntnmhash  ntidhash  flags  ld  dialer  poll_day  what_net\n\n");
    for (i=0; i<cfg.netSize; i++)
	printf(" %c%3d%10d%10d%7lx%4d%8d%10x%10lx\n",
	    (readbit(netTab[i],N_INUSE) ? '*' : ' '), i,
	    netTab[i].ntnmhash, netTab[i].ntidhash, netTab[i].flags,
	    netTab[i].ld, netTab[i].dialer, netTab[i].poll_day,
	    netTab[i].what_net);
    printf("\n\tThe End\n");

    while (getnormstr("\nName of node to display further info (<CR> to end)",
	nodename, NAMESIZE-1)) {		/* get max. 19 characters */
	for (i=0; i<cfg.netSize; i++)
	    if (readbit(netTab[i],N_INUSE) && 
		(hash(nodename) == netTab[i].ntnmhash))
		break;
	if (i<cfg.netSize) {	/* found the one we're looking for */
	    printf("\nContents of netTab[%d].Tshared[j]:\n\n", i);
	    printf("  j  NRlast  NRgen  NRidx  NRhub  roomTab[NRidx].rtname\n\n");
	    for (j=0; j<SHARED_ROOMS; j++)
		printf("%3d%8ld%7u%7d%7d%23s\n", j,
		    netTab[i].Tshared[j].NRlast, netTab[i].Tshared[j].NRgen,
		    netTab[i].Tshared[j].NRidx, netTab[i].Tshared[j].NRhub,
		    (netTab[i].Tshared[j].NRidx == ERROR) ? "<none>" :
		    roomTab[netTab[i].Tshared[j].NRidx].rtname);
	    printf("\n\tThe End\n");
	}
	else
	    printf("\nNo node by that name.\n\n");
    }
}

/*
 * shroomtab() -- print data from the roomTab[]
 */
void
shroomtab(void)
{
    register int i;

    printf("\nContents of roomTab[i]: (* == in use)\n\n");
    printf("    i rtgen flags               rtname lastNet lastLocal lastMsg \
floorGen\n\n");
    for (i=0; i<MAXROOMS; i++)
	printf(" %c%3d%6u%6lx%21s%8ld%9ld%8ld%9d\n",
	    (readbit(roomTab[i],INUSE) ? '*' : ' '), i,
	    roomTab[i].rtgen, roomTab[i].flags,
	    roomTab[i].rtname, roomTab[i].rtlastNet, roomTab[i].rtlastLocal,
	    roomTab[i].rtlastMessage, roomTab[i].rtfloorGen);
    printf("\n\tThe End\n");
}

void
report_missing(int which)
{
    char *p;

    missing[which] = YES;
    switch (which) {
	case MSG: p = "message";	break;
	case LOG: p = "log";		break;
	case NET: p = "net";		break;
	case FLR: p = "floor";		break;
	default:			break;
    }
    printf("%s file missing!\n", p);
}

/*
 * main()
 */
main(int argc, char **argv)
{
    char *p,cmd;
    PATHBUF sysfile;
    int done = NO;

    setbuf(stdout, NULL);	/* avoid 1E99 "fflush(stdout);" calls */

    printf("%s for Fnordadel V%s-%d\n", program, VERSION, PATCHNUM);

    if (!readSysTab(NO)) {	/* can we read the ctdltabl.sys ? */
	if (fromdesk())		/* no?  so much for that idea. */
	    hitkey();
	exit(1);
    }

    initlogBuf(&logBuf);	/* initialise variable-sized parts of */
    initnetBuf(&netBuf);	/* the structures */
    initroomBuf(&roomBuf);

    /* open sysfiles */
    ctdlfile(sysfile, cfg.msgdir, "ctdlmsg.sys");
    if ((msgfl = xopen(sysfile)) < 0)
	report_missing(MSG);

    ctdlfile(sysfile, cfg.sysdir, "ctdllog.sys");
    if ((logfl = xopen(sysfile)) < 0)
	report_missing(LOG);

    ctdlfile(sysfile, cfg.sysdir, "ctdlflr.sys");
    if (!getdirentry(sysfile))
	report_missing(FLR);
    loadfloor();		/* load up the floor table */

    ctdlfile(sysfile, cfg.netdir, "ctdlnet.sys");
    if ((netfl = xopen(sysfile)) < 0)
	report_missing(NET);

    while (!done) {
	printf("\nCommand: ");
	cmd = toupper(getch());
	doCR();
	switch (cmd) {
	case 'C':
	    showconfig();
	    break;
	case 'F':
	    showfloor();
	    break;
	case 'K':
	    shlogtab();
	    break;
	case 'L':
	    showlog();
	    break;
	case 'M':
	    showmsg();
	    break;
	case 'N':
	    shownet();
	    break;
	case 'O':
	    shnettab();
	    break;
	case 'R':
	    showroom();
	    break;
	case 'S':
	    shroomtab();
	    break;
	case '?':
	    printf("\n C - struct cfg\n F - floorTab[]\n K - logTab[]");
	    printf("\n L - ctdllog.sys\n M - ctdlmsg.sys");
	    printf("\n N - ctdlnet.sys\n O - netTab[]");
	    printf("\n R - ctldroom.sys\n S - roomTab[]\n X - EXIT\n");
	    break;
	case 'X':
	    done = YES;
	    break;
	default:
	    putchar('\007');
	    break;
	}
    }

    killlogBuf(&logBuf);	/* kill variable-sized parts of */
    killnetBuf(&netBuf);	/* the structures */
    killroomBuf(&roomBuf);

    if (fromdesk())
	hitkey();
    exit(0);
}

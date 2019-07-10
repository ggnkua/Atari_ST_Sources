/*
 * conv32.c -- convert Fnordadel 1.31-28 system to Fnordadel 1.32-0
 *
 * 91Feb06 RH	Scabbed from conv33d.c.
 */

#include "ctdl.h"	/* for Fnordadel 1.32-0 definitions */
#include "net.h"
#include "log.h"
#include "room.h"
#include "floor.h"
#include "config.h"
#include "msg.h"
#include "citlib.h"

/* Fnordadel 1.31-28 definitions */
/* (or reasonable approximations thereof) */

#define xreadbit(s,m)	((s.xflags & m)?1:0)	/* returns 0 or 1 only  */

#define	xORGSIZE	40

#define xMAXCODE	500	/* codebuffer inside cfg		*/
#define xNUMBAUDS	5

#define xPTR_SIZE	(sizeof (void *))	/* could cause problems */

#define xMAILSLOTS	xcfg.xmailslots		/* # mail msgs per user	*/
#define xMAXROOMS	xcfg.xmaxrooms		/* # of rooms allowed	*/
#define xSHARED_ROOMS	xcfg.xsharedrooms	/* # rooms shareable	*/

struct {
    unsigned xcfgSize;
    unsigned xlogSize;
    unsigned xroomSize;
    unsigned xevtSize;
} xsysHeader;

struct xconfig {
    short xmaxMSector;		/* Max # of sectors (simulated) 	*/
    short xcatChar;		/* Location of next write in msg file	*/
    short xcatSector;
    long xoldest;		/* 32-bit ID# of first message in system*/
    long xnewest;		/* 32-bit ID# of last  message in system*/

    short xcryptSeed;		/* xor crypt offset			*/
    int	 xlogsize;		/* number of log entries supported	*/
    int  xmailslots;		/* mailslots..sharedrooms stolen	*/
    int  xmaxrooms;		/* shamelessly from Hue, Jr. & Cit-86	*/
    int  xsharedrooms;		/* and modified beyond all recognition	*/
    int  xmaxmsgs;		/* Max number of messages enterable per	*/
				/* user per room per login session	*/

    long xflags;		/* various boolean flags (see flags.h)	*/
#define xNOMAIL	0x0010L		/* the only flag actually used		*/

    /*
     * system identification for users & networking.
     */
    OFFSET xnodeName;		/* name for networking			*/
    OFFSET xnodeTitle;		/* name displayed for callers		*/
    OFFSET xnodeId;		/* phone number/network id		*/
    OFFSET xshell;		/* shell to execute if you do an ^LO	*/
    OFFSET xsysopName;		/* user to throw SYSOP mail at.		*/
    OFFSET xhub;			/* for forwarding mail.			*/
    OFFSET xorganization;	/* descriptive field for headers	*/
    /*
     * system directory offsets in codeBuf
     */
    OFFSET xsysdir;		/* where we keep various system files	*/
    OFFSET xroomdir;		/* where the room files go		*/
    OFFSET xhelpdir;		/* .hlp, .mnu, .blb files		*/
    OFFSET xmsgdir;		/* primary messagefile			*/
    OFFSET xnetdir;		/* where net files are found		*/
    OFFSET xauditdir;		/* where audit files are found		*/
    OFFSET xreceiptdir;		/* where sendfile stuff goes		*/
    OFFSET xholddir;		/* where held messages go		*/

    OFFSET xmodemSetup;		/* string to set up the modem		*/
    OFFSET xmCCs[xNUMBAUDS];	/* strings for getting condition codes	*/
				/* from the modem			*/
    OFFSET xdialPrefix;		/* string to prefix telephone #'s with	*/
    OFFSET xdialSuffix;		/* string to append to telephone #'s	*/

    char xsysPassword[60];	/* Remote sysop 			*/
    char xfilter[128];		/* input character translation table	*/
    char xcodeBuf[xMAXCODE];	/* strings buffer			*/
    char xshave[8];		/* shave-and-a-haircut/2 bits pauses	*/

    int  xrecSize;		/* how many K we can recieve.		*/
    short xsyswidth;		/* default terminal width		*/
    char xcall_log;		/* if > 0, keep a call-log.		*/

    int  xevtCount;		/* number of events to deal with...	*/
    int  xfloorCount;		/* number of floors to deal with...	*/
    int  xarch_count;		/* number of external archivers we have */
    int  xzap_count;		/* loop zap table size			*/
    int  xnetSize;		/* How many on the net? 		*/

    int  xpoll_count;		/* # polling events			*/
    long xpoll_delay;		/* idle time before polling systems	*/

    char xsysBaud;		/* What's our baud rate going to be?	*/
    char xprobug;
    int  xconnectDelay;		/* wait after connect before autobauding*/
    int  xlocal_time;		/* how long to wait 'til local hangup	*/
    int  xld_time;		/* how long to wait 'til l-d hangup	*/
    /*
     * accounting variables
     */
    long xdownload;		/* download limit...			*/
    char xld_cost;		/* cost to mail to a l-d system		*/
    char xhubcost;		/* cost to route mail through #hub	*/
};

typedef struct {
    long xmsgno;		/* every message gets unique#           */
    short xmsgloc;		/* sector message starts in             */
} xtheMessages;

struct xrTable { 		/* The summation of a room		*/
    unsigned short xrtgen;	/* generation # of room 		*/
    long xflags;		/* public/private etc (see flags.h)	*/
    LABEL xrtname;		/* name of room 			*/
    long xrtlastNet;		/* # of last net message in room	*/
    long xrtlastLocal;		/* # of last @L message in room		*/
    long xrtlastMessage;	/* # of most recent message in room	*/
    char xrtfloorGen;		/* floor this room is in		*/
};

struct xaRoom {			/* The appearance of a room:		*/
    unsigned short xrbgen;	/* generation # of room 		*/
    long 	xflags;		/* public/private etc (see flags.h)	*/
    char 	xrbfloorGen;	/* floor this room is in		*/
    LABEL	xrbname;	/* name of room 			*/
    long	xrblastNet;
    long	xrblastLocal;
    long	xrblastMessage;
    char	xrbdirname[100];/* user directory for this room's files */
    unsigned short xnummsgs;	/* # of msgs currently visible in room	*/
    xtheMessages *xmsg;
};

struct xflTab {
    LABEL xflName;		/* floor name				*/
    char xflGen;		/* floor generation #			*/
    BOOL xflInUse;		/* is this floor in use?		*/
};

#define xLB_SIZE         (sizeof (xlogBuf) - (xPTR_SIZE * 2))
#define xMAIL_BULK       (xMAILSLOTS * sizeof (xtheMessages))
#define xGEN_BULK        (xMAXROOMS * sizeof (char))
#define xLB_TOTAL_SIZE   (xLB_SIZE + xMAIL_BULK + xGEN_BULK)
#define xinitlogBuf(x)	(x)->xlbgen = (char *)xmalloc(xGEN_BULK),\
			(x)->xlbmail = (xtheMessages *)xmalloc(xMAIL_BULK)

struct xlTable { 		/* Summation of a person:		*/
    short xltpwhash;		/* hash of password			*/
    short xltnmhash;		/* hash of name 			*/
    short xltlogSlot;		/* location in userlog.buf		*/
    long  xltnewest;		/* last message on last call		*/
};

struct xlogBuffer {		/* The appearance of a user:		*/
    char  xlbnulls;		/* #nulls, lCase, lFeeds		*/
    long  xflags;		/* all sorts of flags (see flags.h)	*/
    char  xlbwidth;		/* terminal width			*/
    short xcredit;		/* Credit for long distance calls	*/
    LABEL xlbname;		/* caller's name			*/
    LABEL xlbpw; 		/* caller's password			*/
    long  xlblimit;		/* # bytes the user can download today	*/
    time_t xlblast;		/* last day the user logged in		*/
    long  xlbvisit[MAXVISIT];	/* newestLo for this and 3 prev. visits */
    char  *xlbgen;		/* 5 bits gen, 3 bits lastvisit		*/
    xtheMessages *xlbmail;
};

struct xmsgB {			/* This is what a msg looks like	*/
    long    xmbid;		/* local number of message		*/
    LABEL   xmbdate;		/* `D'-creation date			*/
    LABEL   xmbtime;		/* `C'-creation time			*/
    LABEL   xmbroom;		/* `R'-creation room			*/
    NETADDR xmbauth;		/* `A'-name of author			*/
    NETADDR xmbto;		/* `T'-private message to		*/
    char    xmborg[ORGSIZE];	/* `I'-organisation field		*/
    long    xflags;		/* `7F'-various `bits' of information	*/
    char    xmbroute[NAMESIZE+2];/* `Z'-routing code of message		*/
    LABEL   xmboname;		/* `N'-system name			*/
    LABEL   xmborig;		/* `O'-US xxx xxx xxxx style ID		*/
    LABEL   xmbdomain;		/* `X'-domain of originating system	*/
    long    xmbsrcid;		/* `S'-ID on source system; for C-86	*/
    char    xmbtext[MAXTEXT];	/* buffer text is edited in		*/
};

#define xNB_SIZE         (sizeof (xnetBuf)  - xPTR_SIZE)
#define xSR_BULK         (xSHARED_ROOMS * sizeof (struct xnetroom))
#define xNB_TOTAL_SIZE   (xNB_SIZE + xSR_BULK)

struct xnetroom {
    long     xNRlast;		/* Highest net message in this room	*/
    unsigned short xNRgen;
    short    xNRidx;		/* roomTab[] position of shared room	*/
    short    xNRhub;		/* backboned with the other system?	*/
};

struct xnetBuffer {
    LABEL  xnetId;		/* Node id				*/
    LABEL  xnetName;		/* Node name				*/
    LABEL  xmyPasswd;		/* password I expect from other node	*/
    LABEL  xherPasswd;		/* password other node expects from me	*/
    long   xflags;		/* Flags				*/
    char   xld;			/* LD system? -- also poll count	*/
    char   xdialer;		/* external dialer #			*/
    char   xpoll_day;		/* days to poll				*/    
    long   xwhat_net;		/* which networks this node is in	*/
    char   xbaudCode;		/* Baud code for this node		*/
    char   xaccess[40];		/* For alternative access		*/
    struct xnetroom *xshared;
};


int ofl;		/* 1.31-28 files */
int nfl;		/* 1.32-0 files */
PATHBUF ofn, nfn;

struct xconfig xcfg;
struct xrTable *xroomTab;
struct xaRoom xroomBuf;
struct xlTable *xlogTab;
struct xlogBuffer xlogBuf;
struct xflTab xfloorBuf;	/* Unusual, but this is an unusual program. */
struct xnetBuffer xnetBuf;

struct config cfg;
struct aRoom roomBuf;
struct logBuffer logBuf;
struct flTab *floorTab;
struct netBuffer netBuf;

char *program = "conv32";

void roomfile(void);
void logfile(void);
void floorfile(void);
void netfile(void);

int
main(int argc, char **argv)
{

    /* First grab the 1.31-28 cfg struct from ctdltabl.sys */
    if ((ofl = dopen("ctdltabl.sys", O_RDONLY)) < 0) {
	printf("no ctdltabl.sys!\n");
	exit(1);
    }
    if (dread(ofl, &xsysHeader, sizeof xsysHeader) != sizeof xsysHeader) {
	fprintf(stderr,"could not read %u bytes\n", sizeof xsysHeader);
	dclose(ofl);
	exit(1);
    }
    if (dread(ofl, &xcfg, sizeof xcfg) != sizeof xcfg) {
	fprintf(stderr,"could not read %u bytes\n", sizeof xcfg);
	dclose(ofl);
	exit(1);
    }
    dclose(ofl);

    if (xsysHeader.xcfgSize != sizeof xcfg) {
	printf("size mismatch in old ctdltabl.sys - cfg %d %d\n",
	    xsysHeader.xcfgSize, sizeof xcfg);
	exit(1);
    }
    else if (xsysHeader.xevtSize != xcfg.xevtCount) {
	printf("size mismatch in old ctdltabl.sys - event %d %d\n",
	    xsysHeader.xevtSize, xcfg.xevtCount);
	exit(1);
    }
    else if (xsysHeader.xroomSize != sizeof(*xroomTab) * xMAXROOMS) {
	printf("size mismatch in old ctdltabl.sys - room %d %d\n",
	    xsysHeader.xroomSize, sizeof(*xroomTab) * xMAXROOMS);
	exit(1);
    }
    else if (xsysHeader.xlogSize != sizeof(*xlogTab) * xcfg.xlogsize) {
	printf("size mismatch in old ctdltabl.sys - log %d %d\n",
	    xsysHeader.xlogSize, sizeof(*xlogTab) * xcfg.xlogsize);
	exit(1);
    }

    /* Steal some values that we'll need later */
    cfg.cryptSeed = xcfg.xcryptSeed;
    cfg.oldest = xcfg.xoldest;
    cfg.newest = xcfg.xnewest;
    cfg.maxrooms = xMAXROOMS;
    cfg.mailslots = xMAILSLOTS;
    cfg.sharedrooms = xSHARED_ROOMS;
    cfg.floorCount = xcfg.xfloorCount;
    memcpy(cfg.codeBuf, xcfg.xcodeBuf, xMAXCODE);
    cfg.sysdir = xcfg.xsysdir;
    cfg.netdir = xcfg.xnetdir;
    cfg.msgdir = xcfg.xmsgdir;
    cfg.roomdir = xcfg.xroomdir;
    cfg.flags.NOMAIL = (xreadbit(xcfg,xNOMAIL)) ? 1 : 0;

#if 0
    roomfile();
    floorfile();
    netfile();
#endif

    logfile();

    if (fromdesk())
	hitkey();
    return 0;
}

/*
 * logfile() -- convert the log file.
 *		Leaves the old one in #sysdir/ctdllog.old.
 */
void
logfile(void)
{
    int i, j, size;
    PATHBUF tempfn;

    ctdlfile(ofn, cfg.sysdir, "ctdllog.sys");
    ctdlfile(nfn, cfg.sysdir, "ctdllog.$$$");
    dunlink(nfn);
    if ((ofl = dopen(ofn, O_RDONLY)) >= 0) {
	nfl = dcreat(nfn);
	initlogBuf(&logBuf);
	xinitlogBuf(&xlogBuf);
	i = 0;
	while (dread(ofl, &xlogBuf, xLB_SIZE) == xLB_SIZE) {
	    crypte((char *)&xlogBuf, xLB_SIZE, i*3);
	    if ((size=dread(ofl, xlogBuf.xlbgen, xGEN_BULK)) != xGEN_BULK) {
		printf("xgetlog(%d) read %d/expected %d", i, size, xGEN_BULK);
		exit(-1);
	    }
	    if ((size=dread(ofl, xlogBuf.xlbmail, xMAIL_BULK)) != xMAIL_BULK) {
		crashout("xgetlog(%d) read %d/expected %d", i, size, xMAIL_BULK);
		exit(-1);
	    }
	    printf("user %d: ",i);
	    if (xreadbit(xlogBuf, uINUSE))
		printf("%s\n", xlogBuf.xlbname);
	    else
		putchar('\r');
	    fflush(stdout);

	/* The same stuff */
	    logBuf.lbnulls = xlogBuf.xlbnulls;
	    logBuf.flags = xlogBuf.xflags;
	    logBuf.lbwidth = xlogBuf.xlbwidth;
	    logBuf.credit = xlogBuf.xcredit;
	    strcpy(logBuf.lbname, xlogBuf.xlbname);
	    strcpy(logBuf.lbpw, xlogBuf.xlbpw);
	    logBuf.lbdownloadlimit = xlogBuf.xlblimit;
	    logBuf.lblast = xlogBuf.xlblast;
	    copy_array(xlogBuf.xlbvisit, logBuf.lbvisit);
	    for (j=0; j < xMAXROOMS; j++)
		logBuf.lbgen[j] = xlogBuf.xlbgen[j];
	    for (j=0; j < xMAILSLOTS; j++) {
		logBuf.lbmail[j].msgno = xlogBuf.xlbmail[j].xmsgno;
		logBuf.lbmail[j].msgloc = xlogBuf.xlbmail[j].xmsgloc;
	    }

	/* The new stuff */
	    logBuf.lbcalls = 0;
	    logBuf.lbtime = 0;
	    logBuf.lbclosecalls = 1;
	    logBuf.lbreadnum = 10;
	    if (cfg.flags.NOMAIL)
		clear(logBuf,uMAILPRIV);
	    else
		set(logBuf,uMAILPRIV);

	    putlog(&logBuf, i, nfl);
	    i++;
	}
	dclose(nfl);
	dclose(ofl);
	printf("converted %d log record%s\n", i, (i != 1) ? "s" : "");
	ctdlfile(tempfn, cfg.sysdir, "ctdllog.old");
	dunlink(tempfn);
	drename(ofn, tempfn);
	drename(nfn, ofn);
    }
    else
	printf("ctdllog.sys not found\n");
}

#if 0
/*
 * roomfile() -- converts #sysdir/ctdlroom.sys to #sysdir/roomnnnn.sys.
 * 		 Leaves the old ctdlroom.sys as ctdlroom.33d.
 */
void
roomfile(void)
{
    int i, j;

    NUMMSGS = xMSGSPERRM;
    roomBuf.msg = (theMessages *)xmalloc(MSG_BULK);

    ctdlfile(ofn, cfg.sysdir, "ctdlroom.sys");
    if ((ofl = dopen(ofn, O_RDONLY)) >= 0) {
	i = 0;
	while (dread(ofl, &xroomBuf, sizeof xroomBuf) == sizeof xroomBuf) {
	    printf("room %d: ",i);
	    crypte((char *)&xroomBuf, sizeof xroomBuf, i);
	    if (xroomBuf.xrbflags.xINUSE)
		printf("%s", xroomBuf.xrbname);
	    else
		putchar('\r');
	    fflush(stdout);

	    roomBuf.rbgen = xroomBuf.xrbgen;
	    roomBuf.flags = 0L;
	    if (xroomBuf.xrbflags.xINUSE)	set(roomBuf,INUSE);
	    if (xroomBuf.xrbflags.xPUBLIC)	set(roomBuf,PUBLIC);
	    if (xroomBuf.xrbflags.xISDIR)	set(roomBuf,ISDIR);
	    if (xroomBuf.xrbflags.xPERMROOM)	set(roomBuf,PERMROOM);
	    if (xroomBuf.xrbflags.xSKIP)	set(roomBuf,SKIP);
	    if (xroomBuf.xrbflags.xUPLOAD)	set(roomBuf,UPLOAD);
	    if (xroomBuf.xrbflags.xDOWNLOAD)	set(roomBuf,DOWNLOAD);
	    if (xroomBuf.xrbflags.xSHARED)	set(roomBuf,SHARED);
	    if (xroomBuf.xrbflags.xARCHIVE)	set(roomBuf,ARCHIVE);
	    if (xroomBuf.xrbflags.xANON)	set(roomBuf,ANON);
	    if (xroomBuf.xrbflags.xINVITE)	set(roomBuf,INVITE);
	    if (xroomBuf.xrbflags.xNETDOWNLOAD)	set(roomBuf,NETDOWNLOAD);
	    if (xroomBuf.xrbflags.xAUTONET)	set(roomBuf,AUTONET);
	    if (xroomBuf.xrbflags.xREADONLY)	set(roomBuf,READONLY);

	    roomBuf.rbfloorGen = xroomBuf.xrbflags.xfloorGen;
	    strcpy(roomBuf.rbname, xroomBuf.xrbname);
	    roomBuf.rblastNet = xroomBuf.xrblastNet;
	    roomBuf.rblastLocal = xroomBuf.xrblastLocal;
	    roomBuf.rblastMessage = xroomBuf.xrblastMessage;
	    strcpy(roomBuf.rbdirname, xroomBuf.xrbdirname);
	    for (j=0; j < xMSGSPERRM; j++) {
		roomBuf.msg[j].msgno = (i == MAILROOM ? 0L :
						xroomBuf.xmsg[j].xrbmsgNo);
		roomBuf.msg[j].msgloc = (i == MAILROOM ? 0 :
						xroomBuf.xmsg[j].xrbmsgLoc);
	    }
	    putRoom(thisRoom = i);
	    if (readbit(roomBuf,INUSE) && i != MAILROOM)
		printf(" (%d msgs preserved)\n", NUMMSGS);
	    else if (i == MAILROOM)
		putchar('\n');
	    if (NUMMSGS != xMSGSPERRM) {
		NUMMSGS = xMSGSPERRM;
		roomBuf.msg = (theMessages *)realloc(roomBuf.msg, MSG_BULK);
	    }	
	    i++;
	}
	dclose(ofl);
	ctdlfile(nfn, cfg.sysdir, "ctdlroom.33d");
	drename(ofn, nfn);
	printf("converted %d room%s\n", i, (i != 1) ? "s" : "");
    }
    else
	printf("ctdlroom.sys not found.\n");
}

/*
 * floorfile() -- convert the floor file.
 *		  Leaves the old one in #sysdir/ctdlflr.33d.
 */
void
floorfile(void)
{
    int i;
    PATHBUF tempfn;

    ctdlfile(ofn, cfg.sysdir, "ctdlflr.sys");
    ctdlfile(nfn, cfg.sysdir, "ctdlflr.$$$");
    dunlink(nfn);
    if ((ofl = dopen(ofn, O_RDONLY)) >= 0) {
	nfl = dcreat(nfn);
	i = 0;
	floorTab = (struct flTab *)xmalloc(cfg.floorCount * 
						sizeof(struct flTab));
	while (dread(ofl, &xfloorBuf, sizeof xfloorBuf) == sizeof xfloorBuf
		&& i < cfg.floorCount) {
	    printf("floor %d: ", i);
	    if (xfloorBuf.xflInUse)
		printf("%s\n", xfloorBuf.xflName);
	    else
		putchar('\r');
	    fflush(stdout);

	    strcpy(floorTab[i].flName, xfloorBuf.xflName);
	    floorTab[i].flGen = xfloorBuf.xflGen;
	    floorTab[i].flInUse = xfloorBuf.xflInUse;
	    i++;
	}
	dwrite(nfl, floorTab, cfg.floorCount * sizeof floorTab[0]);
	dclose(nfl);
	dclose(ofl);
	printf("converted %d floor%s\n", i, (i != 1) ? "s" : "");
	ctdlfile(tempfn, cfg.sysdir, "ctdlflr.33d");
	dunlink(tempfn);
	drename(ofn, tempfn);
	drename(nfn, ofn);
    }
    else
	printf("ctdlflr.sys not found.\n");
}

/*
 * netfile() -- convert the net file.
 *		Leaves the old one in #netdir/ctdlnet.33d.
 */
void
netfile(void)
{
    int i, j;
    PATHBUF tempfn;

    ctdlfile(ofn, cfg.netdir, "ctdlnet.sys");
    ctdlfile(nfn, cfg.netdir, "ctdlnet.$$$");
    dunlink(nfn);
    if ((ofl = dopen(ofn, O_RDONLY)) >= 0) {
	nfl = dcreat(nfn);
	initnetBuf(&netBuf);
	i = 0;
	while (dread(ofl, &xnetBuf, sizeof xnetBuf) == sizeof xnetBuf) {
	    printf("node %d: ",i);
	    crypte((char *)&xnetBuf, sizeof xnetBuf, i);
	    if (xnetBuf.xnbflags.xin_use)
		printf("%s\n", xnetBuf.xnetName);
	    else
		putchar('\r');
	    fflush(stdout);

	    strcpy(netBuf.netId, xnetBuf.xnetId);
	    strcpy(netBuf.netName, xnetBuf.xnetName);
	    strcpy(netBuf.myPasswd, xnetBuf.xmyPasswd);
	    strcpy(netBuf.herPasswd, xnetBuf.xherPasswd);
	    netBuf.flags = 0L;
	    if (xnetBuf.xnbflags.xin_use)	set(netBuf,N_INUSE);
	    if (xnetBuf.xnbflags.xmailpending)	set(netBuf,MAILPENDING);
	    if (xnetBuf.xnbflags.xfilepending)	set(netBuf,FILEPENDING);
	    if (xnetBuf.xnbflags.xrec_only)	set(netBuf,REC_ONLY);
	    if (xnetBuf.xnbflags.xld_rr)	set(netBuf,LD_RR);
	    netBuf.ld		= xnetBuf.xnbflags.xld;
	    netBuf.dialer	= xnetBuf.xnbflags.xdialer;
	    netBuf.poll_day	= xnetBuf.xnbflags.xpoll_day;
	    netBuf.what_net	= xnetBuf.xnbflags.xwhat_net;
	    netBuf.baudCode	= xnetBuf.xbaudCode;
	    strcpy(netBuf.access, xnetBuf.xaccess);   
	    for (j = 0; j < xSHARED_ROOMS; j++) {
		netBuf.shared[j].NRlast = xnetBuf.xshared[j].xNRlast;
		netBuf.shared[j].NRgen = xnetBuf.xshared[j].xNRgen;
		netBuf.shared[j].NRidx = xnetBuf.xshared[j].xNRidx;
		netBuf.shared[j].NRhub = xnetBuf.xshared[j].xNRhub;
	    }
	    crypte((char *)&netBuf, NB_SIZE, i);
	    dwrite(nfl, &netBuf, NB_SIZE);
	    dwrite(nfl, netBuf.shared, SR_BULK);
	    crypte((char *)&netBuf, NB_SIZE, i);
	    i++;
	}
	dclose(nfl);
	dclose(ofl);
	printf("converted %d node%s\n", i, (i != 1) ? "s" : "");
	ctdlfile(tempfn, cfg.netdir, "ctdlnet.33d");
	dunlink(tempfn);
	drename(ofn, tempfn);
	drename(nfn, ofn);
    }
    else
	printf("ctdlnet.sys not found.\n");
}
#endif

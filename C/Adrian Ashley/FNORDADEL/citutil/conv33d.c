/*
 * conv33d.c -- convert STadel 3.3d system to Fnordadel 1.3
 *
 * 90Dec28 AA	Hacked on again
 * 90Sep05 AA	Created.
 */

#include "ctdl.h"	/* for Fnordadel definitions */
#include "net.h"
#include "log.h"
#include "msg.h"
#include "room.h"
#include "config.h"
#include "floor.h"
#include "citlib.h"

/* STadel 3.3d definitions */
/* (or reasonable approximations thereof) */

#define	xORGSIZE	80

#define xMSGSPERRM	58
#define xMAXROOMS	64
#define xSHARED_ROOMS	16

#define xMAXCODE	400	/* codebuffer inside cfg		*/
#define xNUMBAUDS	5

/* This is from 3.4a -- is it the same as 3.3d?  It's the same size...	*/

struct xconfig {
    short  maxMSector;		/* Max # of sectors (simulated) 	*/
    short  catChar;		/* Location of next write in msg file	*/
    short  catSector;

    long oldest;		/* 32-bit ID# of first message in system*/
    long newest;		/* 32-bit ID# of last  message in system*/

    short  dft_page;		/* default pagelength			*/
    short  dft_profile;		/* default profile			*/

    short  cryptSeed;		/* xor crypt offset			*/
    short  sizeLTentry;		/* contains size of a logTab entry	*/
    short  MAXLOGTAB;		/* number of log entries supported	*/

    /*
     * system identification for users & networking.
     */
    short  nodeName;		/* name for networking			*/
    short  nodeTitle;		/* name displayed for callers		*/
    short  nodeId;		/* phone number/network id		*/
    /*
     * system directory offsets in codeBuf
     */
    short  sysdir;		/* where we keep various system files	*/
    short  helpdir;		/* .hlp, .mnu, .blb files		*/
    short  msgdir;		/* primary messagefile			*/
    char mirror;		/* Auto backup of message files?	*/
    short  mirrordir;		/* directory to put autobackup msgfile	*/
    short  netdir;		/* where net files are found		*/
    short  auditdir;		/* where audit files are found		*/
    short  receiptdir;		/* where sendfile stuff goes		*/
    short  holddir;		/* where held messages go		*/
    short  tempdir;		/* temporaries (defaults to netdir)	*/

    short  recSize;		/* how many K we can recieve.		*/

    char unlogEnterOk;		/* TRUE if OK to enter messages anon	*/
    char unlogReadOk;		/* TRUE if unlogged folks can read mess */
    char unlogLoginOk;		/* TRUE if spontan. new accounts ok.	*/
    char nonAideRoomOk; 	/* TRUE general folks can make rooms	*/
    char noMail;		/* TRUE if mail is not allowed		*/
    char allNet;		/* TRUE if all users get net privvies	*/
    char paranoid;		/* force remote callers to login	*/
    char aideforget;		/* aides can forget rooms		*/
    char keephold;		/* keep held messages between logins	*/
    char usa;			/* is this system in north america?	*/
    char call_log;		/* if > 0, keep a call-log.		*/
    char pathalias;		/* do intelligent mail routing		*/
    char forward_mail;		/* forward mail through this node?	*/
    char noChat;		/* TRUE to suppress chat attempts	*/
    char debug; 		/* turns debug printout on and off	*/
    char diskusage;		/* do a df() after each directory	*/
    char fZap;			/* default flags for +zap,		*/
    char fNetlog;		/* 		     +netlog,		*/
    char fNetdeb;		/* 		     +netdebug		*/

    short  evtCount;		/* number of events to deal with...	*/
    short  floorCount;		/* number of floors to deal with...	*/
    short  zap_count;		/* loop zap table size			*/
    short  netSize;		/* How many on the net? 		*/
    short  poll_count;		/* # polling events			*/

    short  com_port;		/* com port that the modem is on...	*/
				/* (only useful for MS-DOS version)	*/
    long poll_delay;		/* idle time before polling systems	*/

    char sysPassword[60];	/* Remote sysop 			*/
    char filter[128];		/* input character translation table	*/
    char codeBuf[xMAXCODE];	/* strings buffer			*/
    char shave[8];		/* shave-and-a-haircut/2 bits pauses	*/

    char sysBaud;		/* What's our baud rate going to be?	*/
    char search_baud;		/* TRUE to do flip flop search for baud */
    char connectPrompt;		/* prompt for C/R when connected	*/
    short  connectDelay;	/* how long to wait after connect before*/
				/* autobauding				*/
    short  modemSetup;		/* string to set up the modem		*/
    short  mCCs[xNUMBAUDS];	/* strings for getting condition codes	*/
				/* from the modem			*/
    char modemCC;		/* does the modem do condition codes?	*/
    char probug;		/* prometheus 2400 baud modem bug...	*/
    short  dialPrefix;		/* string to prefix telephone #'s with	*/
    short  dialSuffix;		/* string to append to telephone #'s	*/
    short  local_time;		/* how long to wait 'til local hangup	*/
    short  ld_time;		/* how long to wait 'til l-d hangup	*/

    short  shell;		/* shell to execute if you do an ^LO	*/
    short  sysopName;		/* user to throw SYSOP mail at.		*/
    short  archiveMail;		/* archive all this users' mail		*/
    short  hub;			/* for forwarding mail.			*/
    short  organization;	/* descriptive field for headers	*/
    short  dft_width;		/* default terminal width		*/
    /*
     * accounting variables
     */
    long download;		/* download limit...			*/
    char ld_cost;		/* cost to mail to a l-d system		*/
    char hubcost;		/* cost to route mail through #hub	*/
} ;

#define BitField(name,size)	char name

struct xrflags { 		/* Room flags				*/
    BitField(xINUSE,1);		/* Room in use? 			*/
    BitField(xPUBLIC,1);	/* Room public? 			*/
    BitField(xISDIR,1);		/* Room directory?			*/
    BitField(xPERMROOM,1);	/* Room permanent?			*/
    BitField(xSKIP,1);		/* Room skipped? (temporary for user)	*/
    BitField(xUPLOAD,1);	/* Can room be uploaded to?		*/
    BitField(xDOWNLOAD,1);	/* Can room be downloaded from? 	*/
    BitField(xSHARED,1);	/* Is this a shared room?		*/
    BitField(xARCHIVE,1);	/* Is this room archived somewhere?	*/
    BitField(xANON,1);		/* is this an anonymous room?		*/
    BitField(xINVITE,1);	/* is this an invitation-only room?	*/
    BitField(xNETDOWNLOAD,1);	/* net-downloadable room?		*/
    BitField(xAUTONET,1);	/* (shared room -- net all messages?)	*/
    BitField(xREADONLY,1);	/* readonly room?			*/

    char xfloorGen;		/* floor this room is in		*/
} ;

struct xaRoom {			/* The appearance of a room:		*/
    unsigned short xrbgen;		/* generation # of room 		*/
    struct xrflags xrbflags;	/* same bits as flags above		*/
    LABEL	xrbname;	/* name of room 			*/
    long	xrblastNet;
    long	xrblastLocal;
    long	xrblastMessage;
    char	xrbfill[8];
    char	xrbdirname[100];/* user directory for this room's files */
    struct xaRmsg {
	long xrbmsgNo;		/* every message gets unique#		*/
	short xrbmsgLoc;	/* sector message starts in		*/
    } xmsg[xMSGSPERRM];
} ;

struct xflTab {
    LABEL xflName;		/* floor name				*/
    char xflGen;		/* floor generation #			*/
    char xflInUse;		/* is this floor in use?		*/
    char xflexp0;		/* 4 expansion fields			*/
    char xflexp1;
    char xflexp2;
    char xflexp3;
} ;

/* 3.4a struct: */
#define	BIT(x)	(1<<(x))

struct xlflags { 		/* Flags for person in log		*/
    char xPROTOCOL;		/* Default upload/download protocol	*/
    BitField(xLFMASK,1);	/* Linefeeds?				*/
    BitField(xEXPERT,1);	/* Expert?				*/
    BitField(xAIDE,1);		/* Vice-Grand-Poobah?			*/
    BitField(xL_INUSE,1);	/* Is this slot in use? 		*/

    char xREADING;		/* options for reading messages		*/
#define	dLONG	BIT(0)			/* multiline headers?		*/
#define	dTIME	BIT(1)			/* print time on short headers	*/
#define	dSUBJ	BIT(2)			/* print subject field		*/
#define	dMORE	BIT(3)			/* pause between messages	*/
#define	dORG	BIT(4)			/* print org fields		*/
#define	dOLDTOO	BIT(5)			/* print last old on new	*/
#define	dNUMBER	BIT(6)			/* show message numbers		*/
#define	dFLOOR	BIT(7)			/* floor-by-floor display	*/

    char xPAGELENGTH;		/* for pagination			*/
    BitField(xNET_PRIVS,1);	/* do we have netprivs?			*/
    BitField(xASKSUBJECT,1);	/* ask for subject when entering mesg	*/
} ;

struct xlogBuffer {		/* The appearance of a user:		*/
    char  xlbnulls;		/* #nulls, lCase, lFeeds		*/
    struct xlflags xlbflags;	/* UCMASK, LFMASK, EXPERT, AIDE, INUSE	*/
    char  xlbwidth;		/* terminal width			*/
    short xcredit;		/* Credit for long distance calls	*/
    LABEL xlbname;		/* caller's name			*/
    LABEL xlbpw; 		/* caller's password			*/
    long  xlblimit;		/* # bytes the user can download today	*/
    long  xlblast;		/* last day the user logged in		*/
    char  xlbgen[xMAXROOMS];	/* 5 bits gen, 3 bits lastvisit		*/
    long  xlbvisit[MAXVISIT];	/* newestLo for this and 3 prev. visits */
    short xlbslot[xMSGSPERRM];	/* for private mail			*/
    long  xlbId[xMSGSPERRM];	/* for private mail			*/
} ;

/* ******************************************************************** */

#if 0
/* 3.3b struct: */
struct xmsgB {			/* This is what a msg looks like	*/
    short  xAAAIIEEE;		/* a little bit of alignment...		*/
    char xmbtext[MAXTEXT];	/* buffer text is edited in		*/
    LABEL xmbid;		/* local number of message		*/
    LABEL xmbdate;		/* creation date			*/
    LABEL xmbtime;		/* creation time			*/
    LABEL xmbroom;		/* creation room			*/
    NETADDR xmbauth;		/* name of author			*/
    NETADDR xmbto;		/* private message to			*/
    short xmbcost;		/* postage due for this message		*/
    char  xmbroute[NAMESIZE+2];	/* routing code of message		*/
    LABEL xmboname;		/* short human name for origin system	*/
    LABEL xmborig;		/* US xxx xxx xxxx style ID		*/
    char  xmborg[ORGSIZE];	/* organisation field			*/
} ;
#else
/* 3.4a struct: */
struct xmsgB {			/* This is what a msg looks like	*/
    long  xmbid;		/* local number of message		*/
    LABEL xmbdate;		/* `D'-creation date			*/
    LABEL xmbtime;		/* `C'-creation time			*/
    LABEL xmbroom;		/* `R'-creation room			*/
    NETADDR xmbauth;		/* `A'-name of author			*/
    NETADDR xmbto;		/* `T'-private message to		*/
    NETADDR xmbreply;		/* `?'-reply-to address			*/
    char  xmborg[xORGSIZE];	/* `I'-organisation field		*/
    char  xmbsubj[xORGSIZE];	/* `J'-subject of this message		*/
    char  xmbmsgid[xORGSIZE];	/* `Q'-message-id of this message	*/
    long  xmbseq;		/* `S'-former mbsrcid, for Hue.		*/
    char  xmbroute[NAMESIZE+2];	/* `Z'-routing code of message		*/
    LABEL xmboname;		/* `N'-system name			*/
    LABEL xmborig;		/* `O'-US xxx xxx xxxx style ID		*/
    short xAAAIIEEE;		/* a little bit of alignment...		*/
    char xmbtext[MAXTEXT];	/* `M'-message text			*/
} ;
#endif

/* ******************************************************************** */

struct xnflags {
    char xin_use;		/* Is this record even in use?		*/
    char xmailpending;		/* Outgoing mail?			*/
    char xfilepending;		/* Any file requests?			*/
    char xnetprotocol;		/* protocol to use with this node	*/

    char xld;			/* long-distance system (also pollcnt)	*/
    char xrec_only;		/* can we call this L-D system?		*/
    char xdialer;		/* external dialer #n?			*/
    char xld_rr;		/* allow l-d role reversal?		*/

    long xwhat_net;		/* which networks this node is in	*/
    char xpoll_day;		/* days we must poll this node		*/
    char xrefuse;		/* don't route netmail through this node*/

    char xexpand1;		/* and a few expansion slots...		*/
    char xexpand2;
} ;

struct xnetroom {
    long     xNRlast;		/* Highest net message in this room	*/
    unsigned short xNRgen;
    short    xNRidx;		/* roomTab[] position of shared room	*/
    short    xNRhub;		/* backboned with the other system?	*/
};

struct xnetBuffer {
    LABEL  xnetId;		/* Node id			*/
    LABEL  xnetName;		/* Node name			*/
    LABEL  xmyPasswd;		/* password I expect from other node */
    LABEL  xherPasswd;		/* password other node expects from me */
    struct xnflags xnbflags;	/* Flags			*/
    char   xbaudCode;		/* Baud code for this node	*/
    struct xnetroom xshared[xSHARED_ROOMS];
    char   xaccess[40];		/* For alternative access	*/
};


int ofl;		/* 3.3d files */
int nfl;		/* 1.3 files */
PATHBUF ofn, nfn;

struct xconfig xcfg;
struct xaRoom xroomBuf;
struct xlogBuffer xlogBuf;
struct xflTab xfloorBuf;	/* Unusual, but this is an unusual program. */
struct xnetBuffer xnetBuf;

struct config cfg;
struct aRoom roomBuf;
struct logBuffer logBuf;
struct flTab *floorTab;
struct netBuffer netBuf;

char *program = "conv33d";

void roomfile(void);
void logfile(void);
void floorfile(void);
void netfile(void);

int
main(int argc, char **argv)
{
    struct {
	unsigned short a, b, c, d;
    } dummy;	/* dummy sysHeader */

    /* First grab the 3.3d cfg struct from ctdltabl.sys */
    ofl = dopen("ctdltabl.sys", O_RDONLY);
    dread(ofl, &dummy, sizeof dummy);
    dread(ofl, &xcfg, sizeof xcfg);
    dclose(ofl);

    /* Steal some values that we'll need later */
    cfg.cryptSeed = xcfg.cryptSeed;
    cfg.oldest = xcfg.oldest;
    cfg.newest = xcfg.newest;
    cfg.maxrooms = xMAXROOMS;
    cfg.mailslots = xMSGSPERRM;
    cfg.sharedrooms = xSHARED_ROOMS;
    cfg.floorCount = xcfg.floorCount;
    memcpy(cfg.codeBuf, xcfg.codeBuf, xMAXCODE);
    cfg.sysdir = xcfg.sysdir;
    cfg.netdir = xcfg.netdir;
    cfg.msgdir = xcfg.msgdir;
    cfg.roomdir = xcfg.sysdir;

    roomfile();
    logfile();
    floorfile();
    netfile();

    if (fromdesk())
	hitkey();
    return 0;
}

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
 * logfile() -- convert the log file.
 *		Leaves the old one in #sysdir/ctdllog.33d.
 */
void
logfile(void)
{
    int i, j;
    PATHBUF tempfn;

    ctdlfile(ofn, cfg.sysdir, "ctdllog.sys");
    ctdlfile(nfn, cfg.sysdir, "ctdllog.$$$");
    dunlink(nfn);
    if ((ofl = dopen(ofn, O_RDONLY)) >= 0) {
	nfl = dcreat(nfn);
	initlogBuf(&logBuf);
	i = 0;
	while (dread(ofl, &xlogBuf, sizeof xlogBuf) == sizeof xlogBuf) {
	    crypte((char *)&xlogBuf, sizeof xlogBuf, i*3);
	    printf("user %d: ",i);
	    if (xlogBuf.xlbflags.xL_INUSE)
		printf("%s\n", xlogBuf.xlbname);
	    else
		putchar('\r');
	    fflush(stdout);

	    logBuf.lbnulls = xlogBuf.xlbnulls;
	    logBuf.flags = 0L;
	    if (xlogBuf.xlbflags.xLFMASK)	set(logBuf,uLINEFEEDS);
	    if (xlogBuf.xlbflags.xEXPERT)	set(logBuf,uEXPERT);
	    if (xlogBuf.xlbflags.xAIDE)		set(logBuf,uAIDE);
	    if (xlogBuf.xlbflags.xL_INUSE)	set(logBuf,uINUSE);
	    if (xlogBuf.xlbflags.xNET_PRIVS)	set(logBuf,uNETPRIVS);
	    if (xlogBuf.xlbflags.xREADING & dTIME)	set(logBuf,uSHOWTIME);
	    if (xlogBuf.xlbflags.xREADING & dMORE)	set(logBuf,uREADMORE);
	    if (xlogBuf.xlbflags.xREADING & dOLDTOO)	set(logBuf,uLASTOLD);
	    if (xlogBuf.xlbflags.xREADING & dFLOOR)	set(logBuf,uFLOORMODE);
	    if (xcfg.noMail)
		clear(logBuf,uMAILPRIV);
	    else
		set(logBuf,uMAILPRIV);

	    logBuf.lbwidth = xlogBuf.xlbwidth;
	    logBuf.credit = xlogBuf.xcredit;
	    strcpy(logBuf.lbname, xlogBuf.xlbname);
	    strcpy(logBuf.lbpw, xlogBuf.xlbpw);
	    logBuf.lbdownloadlimit = xlogBuf.xlblimit;
	    logBuf.lblast = xlogBuf.xlblast;
	    copy_array(xlogBuf.xlbvisit, logBuf.lbvisit);
	    /*
	     * note that we're just borrowing the xlbgen array for use in
	     * lbgen...
	     */
	    logBuf.lbgen = xlogBuf.xlbgen;
	    logBuf.lbreadnum = 10;
	    for (j=0; j < xMSGSPERRM; j++) {
		logBuf.lbmail[j].msgno = xlogBuf.xlbId[j];
		logBuf.lbmail[j].msgloc = xlogBuf.xlbslot[j];
	    }

	    putlog(&logBuf, i, nfl);
	    i++;
	}
	dclose(nfl);
	dclose(ofl);
	printf("converted %d log record%s\n", i, (i != 1) ? "s" : "");
	ctdlfile(tempfn, cfg.sysdir, "ctdllog.33d");
	dunlink(tempfn);
	drename(ofn, tempfn);
	drename(nfn, ofn);
    }
    else
	printf("ctdllog.sys not found\n");
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

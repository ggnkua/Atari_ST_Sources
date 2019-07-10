/*
 * config.h -- configuration structure and stuff for Fnordadel
 *
 * 91Apr29 AA	Extracted from ctdl.h and other places.
 */

#ifndef _CONFIG_H
#define _CONFIG_H

#ifndef NUMBAUDS
#include "modem.h"
#endif

typedef unsigned short	OFFSET;

/* Following #defines robbed from Hue, Jr.'s Cit-86 and modified at will */
#define MAILSLOTS       cfg.mailslots	/* # mail msgs users can have	*/
#define MAXROOMS	cfg.maxrooms	/* # of rooms allowed in system	*/
#define SHARED_ROOMS	cfg.sharedrooms	/* # rooms shared with a system	*/

#define MAXCODE	500		/* codebuffer inside cfg		*/

typedef unsigned short	ushort;
typedef unsigned int	uint;

/*
 * Citadel programs use readSysTab() and writeSysTab() to write an image of
 * the external variables in RAM to disk, and later restore it.  The image is
 * stored in CTDLTABL.SYS .  If CTDLTABL.SYS is lost, CONFIGUR will
 * automatically reconstruct it the hard way when invoked, and write a new
 * CTDLTABL.SYS out when finished.  CTDLTABL.SYS is always destroyed after
 * reading, to minimize the possibility of reading an out-of-date version.
 * In general, the technique works well and saves time and head-banging on
 * bootup.  You should, however, note carefully the following caution:
 *
 *  o  Whenever you change the declarations in Ctdl.h you should:
 *   -->  destroy the current CTDLTABL.SYS file
 *   -->  recompile and reload all citadel programs which access CTDLTABL.SYS
 *	  -- currently CITADEL.TOS & CONFIGUR.TOS, plus utilities
 *   -->  use CONFIGUR.TOS to build a new CTDLTABL.SYS file
 *
 * If you ignore these warnings, little pixies will prick you in your
 * sleep for the rest of your life.
 */

struct _cfgflags {
	/* user-oriented stuff */
	uint	ENTEROK 	: 1;	/* OK to enter messages anon	*/
	uint	READOK		: 1;	/* unlogged folks can read mess */
	uint	LOGINOK		: 1;	/* spontan. new accounts ok.	*/
	uint	ROOMOK		: 1;	/* general folks can make rooms	*/
	uint	INFOOK		: 1;
	uint	NOMAIL		: 1;	/* mail not allowed by default?	*/
	uint	ALLDOOR		: 1;
	uint	ALLNET		: 1;	/* all users get net privvies	*/
	uint	GETNAME		: 1;	/* force callers to login with
					   name as well as password	*/
	uint	KEEPHOLD	: 1;	/* keep held mail messages?	*/
	uint	AUTOZEROLIMIT	: 1;

	/* user configuration defaults */
	uint	DEFSHOWTIME	: 1;
	uint	DEFLASTOLD	: 1;
	uint	DEFFLOORMODE	: 1;
	uint	DEFREADMORE	: 1;
	uint	DEFNUMLEFT	: 1;
	uint	DEFAUTONEW	: 1;

	/* sysop-oriented stuff */
	uint	AIDE_FORGET	: 1;	/* aides can forget rooms	*/
	uint	SHOWRECD	: 1;	/* show "rec'd" flag in Mail>?	*/
	uint	NOCHAT		: 1;	/* suppress chat attempts	*/
	uint	DISKUSAGE	: 1;	/* do a df() after each dir	*/
	uint	ARCHIVE_MAIL	: 1;	/* archive the sysop's mail	*/
	uint	SYSOPSLEEP	: 1;	/* let Sysop sleep at console?	*/
	uint	AIDEKILLROOM	: 1;	/* let Aides kill rooms?	*/
	uint	VAPORIZE	: 1;
	
	/* defaults */
	uint	DEBUG		: 1;	/* turns debug printout on/off	*/
	uint	FZAP		: 1;	/* default flags for +zap,	*/
	uint	FNETLOG		: 1;	/* 		     +netlog,	*/
	uint	FNETDEB		: 1;	/*		     +netdebug	*/

	/* modem and net stuff */
	uint	USA		: 1;	/* system in north america?	*/
	uint	PATHALIAS	: 1;	/* do intelligent mail routing	*/
	uint	FORWARD_MAIL	: 1;	/* forward mail thru this node?	*/
	uint	SEARCH_BAUD	: 1;	/* do flip flop search for baud */
	uint	CONNECTPROMPT	: 1;	/* prompt for CR when connected	*/
	uint	MODEMCC		: 1;	/* modem do condition codes?	*/
	uint	HAYES		: 1;	/* recognise codes in dialing	*/
	uint	ANONNETMAIL	: 1;	/* will we accept net mail from	*/
					/* an unknown net node?		*/
	uint	ANONFILEXFER	: 1;	/* will we do a file xfer	*/
					/* with an unknown net node?	*/
	uint	PURGENET	: 1;	/* Purge net traffic w/ +purge?	*/
	uint	KEEPDISCARDS	: 1;	/* keep files reject by loop	*/
					/* zapper or net purger?	*/
	/* misc stuff */
	uint	BANNERBLB	: 1;
} ;

struct config {
    ushort maxMSector;		/* Max # of sectors (simulated) 	*/
    ushort catChar;		/* Location of next write in msg file	*/
    ushort catSector;
    ushort cryptSeed;		/* xor crypt offset			*/
    long oldest;		/* 32-bit ID# of first message in system*/
    long newest;		/* 32-bit ID# of last  message in system*/

    ushort logsize;		/* number of log entries supported	*/
    ushort mailslots;		/* mailslots..sharedrooms stolen	*/
    ushort maxrooms;		/* shamelessly from Hue, Jr. & Cit-86	*/
    ushort sharedrooms;		/* and modified beyond all recognition	*/
    ushort maxmsgs;		/* Max number of messages enterable per	*/
				/* user per room per login session	*/
    ushort maxmailmsgs;		/* Max number of messages enterable per	*/
				/* user in Mail> per login session	*/
    int  anonmailmax;		/* Max size of mail msgs from users not	*/
				/* loggedIn.				*/
    int  infomax;		/* Max size of info files from users	*/
				/* not Aides or Co-Sysops.		*/
    ushort maxcalls;		/* Max number of calls per user per day	*/
    ushort maxtime;		/* Max number of minutes connect time	*/
				/* per user per day			*/
    ushort maxclosecalls;	/* Max number close calls / user / day	*/
    ushort closetime;		/* Max number of minutes separating two	*/
				/* calls to qualify as "close calls"	*/
    ushort mincalltime;		/* minimum time credited for each call	*/
    ushort newusermsgs;		/* # msgs to show new users; all, if 0	*/
    ushort evtclosetime;	/* if less than this many seconds to a	*/
    				/* scheduled event, don't allow doors.	*/
#if 0
    long flags;			/* various boolean flags (see flags.h)	*/
#else
    struct _cfgflags flags;
#endif
    /*
     * system identification for users & networking.
     */
    OFFSET nodeName;		/* name for networking			*/
    OFFSET nodeTitle;		/* name displayed for callers		*/
    OFFSET nodeId;		/* phone number/network id		*/
    OFFSET shell;		/* shell to execute if you do an ^LO	*/
    OFFSET sysopName;		/* user to throw SYSOP mail at.		*/
    OFFSET hub;			/* for forwarding mail.			*/
    OFFSET organization;	/* descriptive field for headers	*/
    OFFSET domain;		/* Cit-86 style domain			*/
    /*
     * system directory offsets in codeBuf
     */
    OFFSET sysdir;		/* where we keep various system files	*/
    OFFSET roomdir;		/* where the room files go		*/
    OFFSET helpdir;		/* .hlp, .mnu, .blb files		*/
    OFFSET msgdir;		/* primary messagefile			*/
    OFFSET netdir;		/* where net files are found		*/
    OFFSET auditdir;		/* where audit files are found		*/
    OFFSET receiptdir;		/* where sendfile stuff goes		*/
    OFFSET holddir;		/* where held messages go		*/

    OFFSET modemSetup;		/* string to set up the modem		*/
    OFFSET mCCs[NUMBAUDS];	/* strings for getting condition codes	*/
				/* from the modem			*/
    OFFSET dialPrefix;		/* string to prefix telephone #'s with	*/
    OFFSET dialSuffix;		/* string to append to telephone #'s	*/

    char sysPassword[60];	/* Remote sysop 			*/
    char filter[128];		/* input character translation table	*/
    char codeBuf[MAXCODE];	/* strings buffer			*/
    char shave[8];		/* shave-and-a-haircut/2 bits pauses	*/

    ushort recSize;		/* how many K we can recieve.		*/
    ushort numbanners;		/* how many rotating banners.		*/
    ushort syswidth;		/* default terminal width		*/
    char call_log;		/* if > 0, keep a call-log.		*/

    int  evtCount;		/* number of events to deal with...	*/
    int  floorCount;		/* number of floors to deal with...	*/
    int  arch_count;		/* number of external archivers we have */
    int  zap_count;		/* loop zap table size			*/
    int  netSize;		/* How many on the net? 		*/

    int  poll_count;		/* # polling events			*/
    long poll_delay;		/* idle time before polling systems	*/

    char sysBaud;		/* What's our baud rate going to be?	*/
    char probug;
    int  connectDelay;		/* wait after connect before autobauding*/
    int  local_time;		/* how long to wait 'til local hangup	*/
    int  ld_time;		/* how long to wait 'til l-d hangup	*/
    /*
     * accounting variables
     */
    long download;		/* download limit...			*/
    char ld_cost;		/* cost to mail to a l-d system		*/
    char hubcost;		/* cost to route mail through #hub	*/
} ;


#endif /* _CONFIG_H */


/*
 * log.h -- structures and defines for the Fnordadel user log
 *
 * 91Apr29 AA	Extracted from ctdl.h and elsewhere.
 */

#ifndef _LOG_H
#define _LOG_H

#define MINLOGSIZE	1
#define MAXLOGSIZE	999
#define SANELOGSIZE	150

#define MINMAILSLOTS	2
#define MAXMAILSLOTS	999
#define SANEMAILSLOTS	50

/*
 * userlog stuff
 */
#define MAXVISIT	8	/* #visits we remember old newestLo for */
#define GENSHIFT	3	/* Where the generation # is		*/
#define CALLMASK	7	/* For finding last visit		*/

/* Following #defines robbed from Hue, Jr.'s Cit-86 */
#define LB_SIZE         (sizeof (logBuf) - (PTR_SIZE * 2))
#define MAIL_BULK       (MAILSLOTS * sizeof (theMessages))
#define GEN_BULK        (MAXROOMS * sizeof (char))
#define LB_TOTAL_SIZE   (LB_SIZE + MAIL_BULK + GEN_BULK)

struct logBuffer {		/* The appearance of a user:		*/
    char  lbnulls;		/* #nulls, lCase, lFeeds		*/
    long  flags;		/* all sorts of flags (see flags.h)	*/
    char  lbwidth;		/* terminal width			*/
    short credit;		/* Credit for long distance calls	*/
    LABEL lbname;		/* caller's name			*/
    LABEL lbpw; 		/* caller's password			*/
    long  lbdownloadlimit;	/* # bytes the user can download today	*/
    short lbcalls;		/* # calls the user has made today	*/
    short lbtime;		/* # minutes of connect time today	*/
    short lbclosecalls;		/* # close calls the user has made	*/
    short lbreadnum;		/* default # msgs to read using .R<#>	*/
    time_t lblast;		/* last day the user logged in		*/
    long  lbvisit[MAXVISIT];	/* newestLo for this & a few prev. visits */
    char  *lbgen;		/* 5 bits gen, 3 bits lastvisit		*/
    theMessages *lbmail;
} ;

/*
 * userlog flags (formerly struct lflags)
 */
#define uSYSOP		 0x0001L	/* Sysop?			*/
#define uLINEFEEDS	 0x0002L	/* Linefeeds?			*/
#define uEXPERT		 0x0004L	/* Expert?			*/
#define uAIDE		 0x0008L	/* Vice-Grand-Poobah?		*/
#define uINUSE		 0x0010L	/* Is this slot in use? 	*/
#define uSHOWTIME	 0x0020L	/* Show time of msg creation?	*/
#define uLASTOLD	 0x0040L	/* Print out last old on [N]ew?	*/
#define uNETPRIVS	 0x0080L	/* User have net privileges?	*/
#define uFLOORMODE	 0x0100L	/* using floor configuration?	*/
#define uTWIT		 0x0200L	/* Twit?			*/
#define uPROTO1		 0x0400L	/* Next 3 flags: default xfer	*/
#define uPROTO2		 0x0800L	/* protocol.  000 == Xmodem	*/
#define uPROTO3		 0x1000L
#define uREADMORE	 0x2000L	/* have read cmds use More: ?	*/
#define uNUMLEFT	 0x4000L	/* display (n left) in msg hdr?	*/
#define uMAILPRIV	 0x8000L	/* can use the Mail> room?	*/
#define uDOORPRIV	0x10000L	/* can use doors?		*/
#define uAUTONEW	0x20000L	/* auto-new msgs in Lobby>?	*/

/* following put in by RH/AA 91Jan01 */
/* High bit of 32-bit msgno value in lbmail is set iff the mail is received. */
/* Use MAILNUM() to get a 'pure' msgno. */
#define RECEIVED	0x80000000L
#define MAILMSGMASK	0x7fffffffL
#define MAILNUM(i)	(i & MAILMSGMASK)

#define LBGEN(p,x)	(((p).lbgen[x] >> GENSHIFT) & 0x1F)

struct lTable { 		/* Summation of a person:		*/
    short ltpwhash;		/* hash of password			*/
    short ltnmhash;		/* hash of name 			*/
    short ltlogSlot;		/* location in userlog.buf		*/
    long  ltnewest;		/* last message on last call		*/
} ;

/* Miscellaneous structure for linked list of userID names; RH 89Dec21	*/
struct user {
    LABEL name;
    struct user *next;
};

#define initlogBuf(x)	(x)->lbgen = (char *)xmalloc(GEN_BULK),\
			(x)->lbmail = (theMessages *)xmalloc(MAIL_BULK)

#define killlogBuf(x)	free((x)->lbgen), free((x)->lbmail)

#define copylogBuf(x, y)	memcpy(y, x, LB_SIZE),\
			memcpy((y)->lbmail, (x)->lbmail, MAIL_BULK),\
			memcpy((y)->lbgen, (x)->lbgen, GEN_BULK)


#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif

/* citlib\getlog.c */
void getlog _P((struct logBuffer *p, int n, int file));

/* citlib\getnmidx.c */
int getnmidx _P((char *name, struct logBuffer *log, int file));
int getnmlog _P((char *name, struct logBuffer *log, int file));

/* citlib\putlog.c */
void putlog _P((struct logBuffer *p, int n, int file));

#undef _P



#endif

/*
 * net.h -- header file for the Citadel networker
 *
 * 91Apr29 AA	Renamed from ctdlnet.h, moved some stuff in here from ctdl.h
 * 88Aug10 orc	removed old-style netmail structures
 * 88Jul16 orc	removed old-style net file req/sendfile structures
 * 88Jul12 orc	remote-command byte changed to avoid conflict with c-86
 * 87Dec23 orc	Strip out NeedsProcessing() macros and handle on the fly
 * 87Dec18 orc	Datastructure support for external autodialers
 * 87Nov08 orc	network roomshare routing
 * 87Jul24 orc	net password data structure support, autonet support
 * 87May17 orc	extracted from ctdl.h
 */

#ifndef _NET_H
#define _NET_H

/*
 * Network request codes
 */
#define HANGUP		0	/* Terminate networking 		*/
#define	LOGIN		255	/* login to other side			*/
#define SEND_MAIL	1	/* Send mail				*/
#define SINGLE_FILE_REQUEST 2	/* Request one file; used only by C86	*/
#define FILE_REQUEST	3	/* Request a number of files (C86style)	*/
#define NET_ROOM	5	/* Send a shared room			*/
#define CHECK_MAIL	6	/* Check for recipient validity 	*/
#define SEND_FILE	7	/* Send a file to another system	*/
#define ROLE_REVERSAL	201	/* Reverse roles			*/

#define	COMPACTION	10	/* C-86 compaction option -- unused	*/
#define	OPTIONS		11	/* send options string			*/
#define	BATCH_SEND	12	/* ymodem batch files during networking	*/
#define	BATCH_REQUEST	13	/* ymodem batch files during networking	*/

#define C86ITLCHG	100	/* Cit-86 version of OPTIONS		*/
#define C86NETPW	202	/* Cit-86 version of net passwords	*/

#define ROUTE_SIG	'@'	/* mbroute[0]				*/
#define	ROUTE_ORIG	'O'	/* message originated here		*/
#define	ROUTE_LOCAL	'L'	/* message came from a local system	*/
#define	ROUTE_HUB	'H'	/* message came from a hub		*/


#define	N_SEQ	"\007\rE"	/* network mode is requested by a 7\rE	*/
				/* sequence				*/
#define	N0_KEY	7			/* each sequence character	*/
#define	N1_KEY	'\r'
#define	N2_KEY	'E'
#define	N0_REP	(0xff & ~N0_KEY)	/* and each reply character	*/
#define	N1_REP	(0xff & ~N1_KEY)
#define	N2_REP	(0xff & ~N2_KEY)

/*
 * How message routing goes:
 *
 * all* netmessages are given a mbroute id.
 * two classes of link:  local & hub.
 * a hub link mails all messages (@O, @L, @H) and addresses them to @H
 * a local link mails all @O and @H messages, addressing them to @L
 *
 *	[Local ->@L][-> Hub ->@H][-> Hub ->@L][-> Local]
 *
 */

#define ROUTEOK(x)	(((x)->mbroute[0]) == ROUTE_SIG)
#define ROUTECHAR(x)	((x)->mbroute[1])
#define ROUTEFROM(x)	(&((x)->mbroute[2]))

#define	CALL_OK		0	/* callout went ok			*/
#define	NO_ID		1	/* couldn't exchange network ids	*/
#define	NOT_STABILISED	2	/* callout not stabilised		*/

#define NO_ERROR	0	/* No error (ends transmission) 	*/
#define NO_RECIPIENT	1	/* No recipient found			*/
#define BAD_FORM	2	/* Something's wrong			*/
#define UNKNOWN 	99	/* Something's REALLY wrong (eek!)	*/

#define	iDIRECT	0		/* mail directly to system		*/
#define	iALIAS	1		/* mail route found in netalias.sys	*/
#define	iHUBBED	2		/* mail forwarded to a #hub		*/
#define	iDOMAIN	3		/* mail passed to another domain	*/

struct netroom {
    long     NRlast;		/* Highest net message in this room	*/
    unsigned short NRgen;
    short    NRidx;		/* roomTab[] position of shared room	*/
    short    NRhub;		/* backboned with the other system?	*/
};

/* Following #defines invented on our own */
#define MINSHAREDROOMS	1
#define MAXSHAREDROOMS	999
#define SANESHAREDROOMS	20

/* Following #defines robbed from Hue, Jr.'s Cit-86 */
#define NT_SIZE         (sizeof (*netTab) - PTR_SIZE)
#define NB_SIZE         (sizeof (netBuf)  - PTR_SIZE)
#define SR_BULK         (SHARED_ROOMS * sizeof (struct netroom))
#define NT_TOTAL_SIZE   (NT_SIZE + SR_BULK)
#define NB_TOTAL_SIZE   (NB_SIZE + SR_BULK)

struct netBuffer {
    LABEL  netId;		/* Node id				*/
    LABEL  netName;		/* Node name				*/
    LABEL  myPasswd;		/* password I expect from other node	*/
    LABEL  herPasswd;		/* password other node expects from me	*/
    long   flags;		/* Flags				*/
    char   ld;			/* LD system? -- also poll count	*/
    char   dialer;		/* external dialer #			*/
    char   poll_day;		/* days to poll				*/    
    long   what_net;		/* which networks this node is in	*/
    char   baudCode;		/* Baud code for this node		*/
    char   access[40];		/* For alternative access		*/
    struct netroom *shared;
};

#define sharing(i) 	(netBuf.shared[i].NRidx >= 0 \
    && readbit(roomTab[netBuf.shared[i].NRidx],SHARED) \
    && roomTab[netBuf.shared[i].NRidx].rtgen == netBuf.shared[i].NRgen)

struct netTable {
    short	ntnmhash;
    short	ntidhash;
    long	flags ;
    char   	ld;		/* LD system? -- also poll count	*/
    char   	dialer;		/* external dialer #			*/
    char   	poll_day;	/* days to poll				*/    
    long	what_net;	/* which networks this node is in	*/
    struct netroom *Tshared;
};

/*
 * network flags (formerly struct nflags)
 */
#define N_INUSE		0x0001L	/* Is this record even in use?		*/
#define MAILPENDING	0x0002L	/* Outgoing mail?			*/
#define FILEPENDING	0x0004L	/* Any file requests?			*/
#define REC_ONLY	0x0008L	/* can we call this L-D system?		*/
#define LD_RR		0x0010L	/* allow l-d role reversal?		*/
#define CIT86		0x0020L	/* is this a citadel-86?		*/

/* The following #defines robbed (sorta) from Hue, Jr.'s Cit-86 */
#define initnetBuf(x)	(x)->shared = (struct netroom *) xmalloc(SR_BULK)
#define killnetBuf(x)	free((x)->shared)

struct poll_t {
    short p_net;	/* net to poll */
    short p_start;	/* minutes after midnight */
    short p_end;	/* minutes after midnight */
    short p_days;	/* days to poll this system: (xxxxxxxx xSFRWTMS) */
} ;

#define	poll_today(x, d)	((x) & (1<<(d)))

#endif /* _NET_H */

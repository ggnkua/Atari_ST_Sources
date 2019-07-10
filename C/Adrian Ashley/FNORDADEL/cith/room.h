/*
 * room.h -- structures and defines for Fnordadel rooms
 *
 * 91Apr29 AA	Extracted from ctdl.h and other places.
 */

#ifndef _ROOM_H
#define _ROOM_H

#define NUMMSGS		roomBuf.nummsgs	/* # of msgs in this room	*/

#define MINMAXROOMS	3	/* Don't make this <3, or you will die */
#define MAXMAXROOMS	999	/* The rest are our own whims */
#define SANEMAXROOMS	64

/*
 * special system rooms that will always be there.
 */
#define LOBBY		0	/* Lobby> is >always< room 0.		*/
#define MAILROOM	1	/* Mail>  is >always< room 1.		*/
#define AIDEROOM	2	/* Aide> is >always< room 2.		*/

/*
 * Room data
 */
#define MAXGEN	       32	/* six bits of generation => 64 of them */
#define FORGET_OFFSET  (MAXGEN / 2)	/* For forgetting rooms 	*/

/* Following #defines robbed from Hue, Jr.'s Cit-86 and then hacked on	*/
#define MSG_BULK	(NUMMSGS * sizeof (theMessages))
#define RB_SIZE		(sizeof(roomBuf) - (PTR_SIZE))

struct rTable { 		/* The summation of a room		*/
    unsigned short rtgen;	/* generation # of room 		*/
    long flags;			/* public/private etc (see flags.h)	*/
    LABEL rtname;		/* name of room 			*/
    long rtlastNet;		/* # of last net message in room	*/
    long rtlastLocal;		/* # of last @L message in room		*/
    long rtlastMessage;		/* # of most recent message in room	*/
    char rtfloorGen;		/* floor this room is in		*/
} ;

struct aRoom {			/* The appearance of a room:		*/
    unsigned short rbgen;	/* generation # of room 		*/
    long 	flags;		/* public/private etc (see flags.h)	*/
    char 	rbfloorGen;	/* floor this room is in		*/
    LABEL	rbname;		/* name of room 			*/
    long	rblastNet;
    long	rblastLocal;
    long	rblastMessage;
    char	rbdirname[100];	/* user directory for this room's files */
    unsigned short nummsgs;	/* # of msgs currently visible in room	*/
    theMessages *msg;
} ;

/*
 * room flags (formerly struct rflags)
 */
#define INUSE		0x0001L		/* Room in use?			*/
#define PUBLIC		0x0002L		/* Room public?			*/
#define ISDIR		0x0004L		/* Room directory?		*/
#define PERMROOM	0x0008L		/* Room permanent?		*/
#define SKIP		0x0010L		/* Room skipped? (temp for user)*/
#define UPLOAD		0x0020L		/* Can room be uploaded to?	*/
#define DOWNLOAD	0x0040L		/* Can room be downloaded from?	*/
#define SHARED		0x0080L		/* Is this a shared room?	*/
#define ARCHIVE		0x0100L		/* Is this room archived?	*/
#define ANON		0x0200L		/* is this an anonymous room?	*/
#define INVITE		0x0400L		/* is this an invite-only room?	*/
#define NETDOWNLOAD	0x0800L		/* net-downloadable room?	*/
#define AUTONET		0x1000L		/* net all messages?		*/
#define READONLY	0x2000L		/* readonly room?		*/
#define DESCRIPTION	0x4000L		/* description on file?		*/

#define initroomBuf(x)	(x)->msg = (theMessages *) xmalloc(0)
#define killroomBuf(x)	if ((x)->msg) free((x)->msg)

#define USTKSIZ	16			/* allow up to 16 ungotos	*/

struct Index {				/* save-list of room info */
    int visited;			/* state of room */
#define	iNEVER	0				/* not seen yet */
#define	iGOTO	1				/* seen & goto'ed past */
#define	iSKIP	2				/* seen & skipped past */
    char lastgen;			/* geninfo about room at login */
} ;

#define	l_OLD	0x0001		/* flag bits for listRoom()/listFloor()	*/
#define	l_NEW	0x0002
#define	l_FGT	0x0004		/* list forgottten rooms		*/
#define l_EXCL	0x0008		/* don't list current room/floor	*/
#define	l_LONG	0x0010		/* long listing (for ;k...)		*/
#define	x_DIR	0x0020
#define	x_NET	0x0040
#define	x_PUB	0x0080
#define	x_PRIV	0x0100

#endif

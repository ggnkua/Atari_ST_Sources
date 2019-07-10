/*
 * ctdl.h -- header file for all Citadel C files
 */

/*
 * 91Apr29 AA	Broke up into lots of other files -- ctdl.h is now common stuff
 * 90Nov05 AA	Hacks for gcc/ANSI compatibility
 * 90Oct31 AA	Added cfg.roomdir.
 * 90Oct22 A&R	'MAXLOGTAB' (which we've hated for aeons) --> 'logsize'.  Also
 *		added MAX, MIN & SANE limits for maxrooms, mailslots,
 *		sharedrooms, logsize.
 * 90Aug23 AA	Now #includes "citlib.h" for library declarations
 * 90Jan30 A&R	Major hacks for msgs/room, room/system and other limits.
 *		(Thanks to Hue, Jr. for some inspiration and code.)
 * 89Oct14 AA	Changed all boolean variables to bitfields.
 * 88Jul12 orc	Moved many fields around, removed unneeded ones
 * 88Mar21 orc	Add 19200 baud support macros, aideforget flag, filler
 *		for future expansion.
 * 88Feb13 orc	Protocol #defines into protocol.h.
 * 88Jan30 orc	rbmoderator field removed from roomBuf structure, table
 *		message fields put in its place.
 * 87Oct27 orc	dirList & event stuff put into dirlist.h, event.h
 * 87Oct15 orc	add cfg.usa for european systems.
 * 87Sep06 orc	#define HUP (return for iChar())
 * 87Aug25 orc	put modem-cc detection stuff into config structure
 * 87Jul24 orc	put in autonet defines, allow 16 bits for l-d credits,
 *		put expansion fields into structures.
 * 87May19 orc	Ymodem yanked; system dependent stuff put into sysdep.h
 * 87May17 orc	networking stuff extracted and put into ctdlnet.h,
 *		data structures added for generalised event handling.
 * 87Mar28 orc	major enhancements for version 1.00ST
 * 87Feb28 orc	add #define for doExit() so return codes are* returned
 * 87Feb07 orc	mini-terpreter indices removed from cfg, modemSetup string
 *		added in.
 * 87Jan17 orc	net stuff #ifdef'ed out
 * 87Jan05 orc	roomfl, msgfl, logfl changed from FILE*
 * 86Dec23 orc	Once again the trek to 68000land has begun
 * 85Oct16 HAW	Add code for OFFICE-STUFF parameter.
 * 85Aug29 HAW	Install code to allow double msg files for autobackup.
 * 85Jun19 HAW	Implant exit values so batch files can be made useful.
 * 85May27 HAW	Start adding networking gunk.
 * 85May22 HAW	MAXLOGTAB now sysop selectable.
 * 85May06 HAW	Add daily bailout parameter.
 * 85May05 HAW	Add SYSDISK parameter.
 * 85Mar20 HAW	Add timestamp code.
 * 85Feb21 HAW	Add directory names.
 * 85Feb20 HAW	Implement IMPERVIOUS flag.
 * 85Feb18 HAW	Insert global variables for baud search.
 * 85Jan20 HAW	Insert code to read from system clock.
 * 84Aug30 HAW	Begin conversion to MS-DOS
 */

#ifndef _CTDL_H
#define _CTDL_H

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <string.h>

#include <fcntl.h>
#include <osbind.h>

#include "sysdep.h"

/*
 * General form of bitfields.  Must have `long flags;' in structure.
 *
 * Usage examples:  (Assuming `struct config cfg;' is declared)
 * 	set(cfg,ENTEROK);		to set cfg.enterok to 1
 *	clear(cfg,PATHALIAS);		to set cfg.pathalias to 0
 *	i = (char)readbit(cfg,NOMAIL);	to read the value of cfg.nomail
 *
 * NOTE:  You must coerce the return value of readbit(); it's a long
 * if you don't, and this is a Bad Thing.
 */

#define flip(s,m)	s.flags ^= m		/* XOR to flip a bit	*/
#define set(s,m)	s.flags |= m		/* OR to set bit	*/
#define clear(s,m)	s.flags &= ~m
				/* AND with inverted mask to clear bit	*/
#define readbit(s,m)	((s.flags & m)?1:0)	/* returns 0 or 1 only  */

/*
 * could use
 * 	#define readbit(s,m)	(s.flags & m)
 * if it is sufficient to return 0 if off, any other long value if on.
 * NOTE, however, that you have to remember that the returned value
 * is (long); if you don't, you could get erroneous results.
 */

/* following are slight variations on the theme (this time with ptr deref): */

#define flipp(s,m)	s->flags ^= m		/* XOR to flip a bit	*/
#define setp(s,m)	s->flags |= m		/* OR to set bit	*/
#define clearp(s,m)	s->flags &= ~m
				/* AND with inverted mask to clear bit	*/
#define readpbit(s,m)	((s->flags & m)?1:0)	/* returns 0 or 1 only  */


#define	NODESIZE	10
#define NAMESIZE	20		/* length of room names		*/
#define PATHSIZE	100		/* maximum length of paths	*/
#define ADDRSIZE	128		/* and net addresses		*/

typedef char LABEL[NAMESIZE];		/* Semi-generic 		*/
typedef char PATHBUF[PATHSIZE];
typedef char NETADDR[ADDRSIZE];

typedef char	BOOL;

#define PTR_SIZE        (sizeof (void *))         /* could cause problems */

#define YES	1
#define NO	0
#define	TRUE	1
#define	FALSE	0
#define ERROR	(-1)

/* ASCII characters: */
#define HUP       0
#define SOH	  1
#define STX	  2
#define CNTRLC	  3
#define EOT	  4
#define ACK	  6
#define BELL	  7
#define BACKSPACE 8
#define TAB	  9
#define NEWLINE	 10
#define CNTRLO	 15
#define	DLE	 16
#define SYN	 22
#define CNTRLl	 12
#define XOFF	 19
#define	XON	 17
#define NAK	 21
#define CAN	 24
#define CNTRLZ	 26
#define ESC	 27
#define SPECIAL	ESC
#define DEL	127

#define SECTSIZE	128	/* Size of a Xmodem sector		*/
#define YMSECTSIZE	1024	/* Size of a Ymodem sector		*/
#define BLKSIZE	4096		/* size of a messagebase sector		*/

/* Following typedef robbed from Hue, Jr.'s Cit-86 */
typedef struct {
    long msgno;			/* every message gets unique #          */
    short msgloc;		/* sector message starts in             */
} theMessages;

/* values for showMess routine */
#define NEWoNLY 	0
#define OLDaNDnEW	1
#define OLDoNLY 	2
#define GLOBALnEW	3

/*  output XON/XOFF etc flag... */
#define OUTOK		0	/* normal output			*/
#define OUTAGAIN	1	/* a pause has been requested		*/
#define OUTNEXT 	2	/* quit this message, get the next	*/
#define OUTSKIP 	3	/* stop current process 		*/
#define OUTPARAGRAPH	4	/* skip to next paragraph		*/
#define IMPERVIOUS	5	/* make current output unstoppable	*/
#define OUTBACKUP	6	/* go to previous item			*/

#define NEITHER 	0	/* don't echo input at all		*/
#define CALLER		1	/* echo to caller only --passwords etc	*/
#define BOTH		2	/* echo to caller and console both	*/

/*
 * Various `standard' exit stati
 */
#define SYSOP_EXIT	0		/* horrid error or ^Lq		*/
#define CRASH_EXIT	2		/* possibly fixable error	*/
#define REMOTE_EXIT	3		/* ^Lq from remote		*/

/*
 * Useful pseudo functions
 */
#define onLine()	((haveCarrier || onConsole) && !eventExit)
#define okRoom(i)	\
    (!readbit(logBuf,uFLOORMODE) || (roomTab[i].rtfloorGen == floorTab[thisFloor].flGen))
#define TheSysop()	(readbit(logBuf,uSYSOP) && (onConsole || remoteSysop))
#define SomeSysop()	(readbit(logBuf,uSYSOP))
#define DAY(t)		(t / 86400L)	/* Seconds -> days */
#define MINUTE(t)	(t / 60L)	/* Seconds -> minutes */

#define zero_struct(x)	memset(&(x), 0, sizeof(x))
#define zero_array(x)	memset( (x), 0, sizeof(x))
#define copy_struct(src, dest)	memcpy(&(dest), &(src), sizeof(src))
#define copy_array(src, dest)	memcpy( (dest),  (src), sizeof(src))

#define ABS(x)		((x<0) ? (-(x)) : (x))
#define MIN(x,y)        ((x) < (y) ? (x) : (y))
#define MAX(x,y)        ((x) > (y) ? (x) : (y))

#endif /* _CTDL_H */

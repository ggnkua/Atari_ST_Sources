/*
 * msgio.c -- low-level message i/o
 *
 * 90Nov06 AA	Munged for gcc / STadel 3.4a stuff
 * 90Aug27 AA	Split off from libmsg.c
 */

#include "ctdl.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"

/* We must find a better place for these things... */
struct msgB	msgBuf;		/* The -sole- message buffer		*/
int	msgfl;			/* file descriptor for the msg file	*/
int	pullMLoc;
long	pullMId;

short mbindex = 0;		/* offset in this sector	*/
short mboffset = 0xffff;	/* this sector..		*/
char  mbsector[BLKSIZE];	/* contents of this sector	*/

/*
 * getmsgchar() - reads a character from messagefile
 */
getmsgchar()
{
    unsigned short gotten;

    gotten = 0xff & mbsector[mbindex++];

    if ((mbindex %= BLKSIZE) == 0) {
	/*
	 * time to read next sector in:
	 */
	mboffset = (++(mboffset)) % cfg.maxMSector;

	dseek(msgfl, ((long)BLKSIZE)*(long)(mboffset), 0);

	if (dread(msgfl, mbsector, BLKSIZE) != BLKSIZE)
	    crashout("msgfile read error");
	crypte(mbsector, BLKSIZE, 0);
    }
    return gotten;
}

/*
 * getmsgstr() - reads a string from messagefile
 */
getmsgstr(char *place, register int length)
{
    register i=0;
    register short c;

    length--;
    while (c = getmsgchar())
	if (i < length)
	    place[i++] = c;
    place[i] = 0;
}

/*
 * msgseek() - sets location to begin reading message from
 */
msgseek(int sector, int byte)
{
    if (sector >= cfg.maxMSector)
	return;
	/*crashout("msgfile seek error (%u,%d)", sector, byte);*/

    mbindex = byte;
    if (sector != mboffset) {
	mboffset = sector;
	dseek(msgfl, (long)sector * (long) BLKSIZE, 0);
	if (dread(msgfl, mbsector, BLKSIZE) != BLKSIZE)
	    crashout("msgfile seek fail");
	crypte(mbsector, BLKSIZE, 0);
    }
}

/*
 * wipemsgs() - wipes out all messages from one sector/offset location to
 *		a second sector/offset location
 */
void
wipemsgs(short oldsector, short oldchar, short newsector, short newchar)
{
    short i;
    char *crashmsg = "msgfile write error %d in wipemsgs()";

    if (oldsector >= cfg.maxMSector || newsector >= cfg.maxMSector)
	crashout("msgfile seek error in wipemsgs()");

    memset(mbsector, 0, BLKSIZE);
    crypte(mbsector, BLKSIZE, 0);

    /* Find first byte to start the wipe-out on */
    dseek(msgfl, (long)oldsector * (long)BLKSIZE + (long)oldchar, 0);

    if (newsector == oldsector) {
	if (newchar < oldchar)		/* Sanity check */
	    crashout("wipemsgs() error: newchar < oldchar");
	else if (newchar == oldchar)	/* Anything really to be done? */
	    return;			/* Nope. */

	/* Wipe a bit of current sector and we're done */
	if (dwrite(msgfl, mbsector, newchar - oldchar) != (newchar - oldchar))
	    crashout(crashmsg, 1);
    }
    else {
	/* Wipe remainder of current sector */
	if (dwrite(msgfl, mbsector, BLKSIZE - oldchar) != (BLKSIZE - oldchar))
	    crashout(crashmsg, 2);

	i = (oldsector + 1) % cfg.maxMSector;	/* Next sector to wipe */
	if (i == 0)				/* Start of file? */
	    dseek(msgfl, 0, 0);

	while (i != newsector) {		/* Full sector wipes */
	    if (dwrite(msgfl, mbsector, BLKSIZE) != BLKSIZE)
		crashout(crashmsg, 3);
	    i = (++(i)) % cfg.maxMSector;
	    if (i == 0)				/* Start of file? */
		dseek(msgfl, 0, 0);
	}

	/* Wipe beginning of last sector */
	if (dwrite(msgfl, mbsector, BLKSIZE - newchar) != (BLKSIZE - newchar))
	    crashout(crashmsg, 4);
    }
}

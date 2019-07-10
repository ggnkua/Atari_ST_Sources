/*
 * putroom.c -- put a room record to disk
 *
 * 90Aug27 AA	Split off from libroom.c
 */

#include "ctdl.h"
#include "room.h"
#include "config.h"
#include "citlib.h"

void
putRoom(rm)
int rm;
{
    int actual;
    PATHBUF sysfile;
    LABEL fn;
    unsigned tempnummsgs;
#define tMSG_BULK	(tempnummsgs * sizeof(theMessages))

    roomsanity();		/* Check the nature of the universe -- again */
    tempnummsgs = NUMMSGS;

    crypte((char *)&roomBuf, RB_SIZE, rm);	/* encrypt the room? */

    sprintf(fn, "room%04d.sys", rm);
    ctdlfile(sysfile, cfg.roomdir, fn);

    if ((roomfl = dcreat(sysfile)) < 0)
	crashout("cannot create room file %s\n", sysfile);

    if ((actual=dwrite(roomfl, &roomBuf, RB_SIZE)) != RB_SIZE)
	crashout("putRoom(%d) roomBuf: wrote %d/expected %d", rm, actual,
	    RB_SIZE);

    if (tempnummsgs)
	if ((actual=dwrite(roomfl, roomBuf.msg, tMSG_BULK)) != tMSG_BULK)
	    crashout("putRoom(%d) msg: wrote %d/expected %d", rm, actual,
		tMSG_BULK);

    dclose(roomfl);
    crypte((char *)&roomBuf, RB_SIZE, rm);	/* decrypt the room? */
}

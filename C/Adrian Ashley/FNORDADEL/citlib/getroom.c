/*
 * getroom.c -- get a room record off disk
 *
 * 90Aug27 AA	Split off from libroom.c
 */

#include "ctdl.h"
#include "room.h"
#include "config.h"
#include "citlib.h"

/* Need a better place for these... */
struct aRoom roomBuf;			/* Room buffer			*/
int roomfl;				/* Room file descriptor 	*/
int thisRoom = LOBBY;			/* Current room 		*/

void
getRoom(rm)
int rm;
{
    int  actual;
    PATHBUF sysfile;
    LABEL fn;

    thisRoom = rm;

    sprintf(fn, "room%04d.sys", rm);
    ctdlfile(sysfile, cfg.roomdir, fn);
    roomfl = xopen(sysfile);

    if ((actual=dread(roomfl, &roomBuf, RB_SIZE)) != RB_SIZE)
	crashout("getRoom(%d) roomBuf: read %d/expected %d", rm, actual,
	    RB_SIZE);
    crypte((char *)&roomBuf, RB_SIZE, rm);

    if (NUMMSGS) {
	roomBuf.msg = (theMessages *) realloc(roomBuf.msg, MSG_BULK);
	if ((actual=dread(roomfl, roomBuf.msg, MSG_BULK)) != MSG_BULK)
	    crashout("getRoom(%d) msg: read %d/expected %d", rm, actual,
		MSG_BULK);
    }

    dclose(roomfl);
    if (thisRoom == MAILROOM)
	update_mail();
    else
	roomsanity();		/* Check the nature of the universe */
}

void
roomsanity()
{
    int i,j;

    if (thisRoom == MAILROOM)
	return;
    for (i = 0; i < NUMMSGS; i++)
	if (roomBuf.msg[i].msgno >= cfg.oldest)	/* stop at first valid msg */
	    break;
    if (i > 0) { /* Did we stop at any point past 0? IE: any invalid msgs? */
	for (j = i; j < NUMMSGS; j++)	/* shuffle valid ones down, if any */
	    roomBuf.msg[j - i] = roomBuf.msg[j];
	NUMMSGS -= i;
	roomBuf.msg = (theMessages *)realloc(roomBuf.msg, MSG_BULK);
    }
}

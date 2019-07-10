/*
 * noteroom.c -- enter a room in RAM index
 *
 * 90Aug27 AA	Split off from libroom.c
 */

#include "ctdl.h"
#include "room.h"
#include "config.h"
#include "log.h"
#include "citlib.h"

void
noteRoom()
{
    int i;
    long last;

    last = 0l;
    for (i = 0; i < NUMMSGS; i++)
	if (roomBuf.msg[i].msgno > last)
	    last = roomBuf.msg[i].msgno;

    roomBuf.rblastMessage = roomTab[thisRoom].rtlastMessage = last;
    roomTab[thisRoom].rtlastLocal = roomBuf.rblastLocal;
    roomTab[thisRoom].rtlastNet   = roomBuf.rblastNet;
    strcpy(roomTab[thisRoom].rtname, roomBuf.rbname);
    roomTab[thisRoom].rtgen = roomBuf.rbgen;
    roomTab[thisRoom].flags = roomBuf.flags;
    roomTab[thisRoom].rtfloorGen = roomBuf.rbfloorGen;
}

void
update_mail()
{
    int i;

    for (i=0; i < MAILSLOTS; i++) {
	roomBuf.msg[i].msgloc = logBuf.lbmail[i].msgloc;
	roomBuf.msg[i].msgno  = MAILNUM(logBuf.lbmail[i].msgno);
    }
    noteRoom();
}

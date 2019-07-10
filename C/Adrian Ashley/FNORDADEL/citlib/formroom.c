/*
 * formroom.c -- format a room name into standard format
 *
 * 90Aug27 AA	Split off from libmisc.c
 */

#include "ctdl.h"
#include "room.h"
#include "citlib.h"

char *
formRoom(roomno, markprivate)
int roomno, markprivate;
{
    static char display[40];
    int one, two;
    static char frMatrix[2][2] = { { '>', ')' } , { ']', ':' } };

    one = (int)readbit(roomTab[roomno],ISDIR) ? 1 : 0;
    two = (int)readbit(roomTab[roomno],SHARED) ? 1 : 0;
    if readbit(roomTab[roomno],INUSE) {
	sprintf(display, "%s%c%s",
		roomTab[roomno].rtname, frMatrix[one][two],
		(markprivate && !readbit(roomTab[roomno],PUBLIC)) ? "*" : "");
	return display;
    }
    return "";
}

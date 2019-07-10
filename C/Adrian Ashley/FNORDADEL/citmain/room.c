/*
 * room.c - room code for Fnordadel bulletin board system
 *
 * 90Nov09 AA	Threw old rooma.c & roomb.c into a pot, added orc's room.c,
 *		mixed well and came up with this.
 * 89May11 orc	Many misc functions moved out, movement rewritten
 * 89Mar30 orc	Rooma and roomb reintegrated
 *	.
 *	.
 * 82Nov05 CrT	main() splits off to become citadel.c
 */

#include "ctdl.h"
#include "room.h"
#include "protocol.h"
#include "editor.h"
#include "msg.h"
#include "log.h"
#include "floor.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"

/*
 * statroom()		tells us # new messages etc
 * steproom()		Stonehedge style +/- movement
 * canEnter()		Legal to enter this room?
 * * showskipped()	Shows the rooms we've skipped, reset ptrs
 * nextroom()		Find the next room with unread msgs
 * gotoroom()		goto a named room
 * listRooms()		lists known rooms
 * * pushroom()		save current room # for ungoto.
 * roomExists()		returns slot# of named room else ERROR
 * indexRooms()		build RAM index to ctdlroom.sys
 * initialArchive()	does initial archive of a room
 * makeRoom()		make new room via user dialogue
 */

int lastRoom;				/* last room stack ptr		*/
int lastStack[USTKSIZ];			/* last rooms visited		*/
struct Index *indices;			/* logged-in state of rooms	*/

char remoteSysop = NO;			/* Is current user a sysop	*/

char *on = "on";
char *off = "off";
char *no = "no";
char *yes = "yes";

/*
 * roomExists() - returns slot# of named room
 */
int
roomExists(char *room)
{
    register int i;

    for (i = 0; i < MAXROOMS; i++)
	if (readbit(roomTab[i],INUSE) && stricmp(room, roomTab[i].rtname) == 0)
	    return i;
    return ERROR;
}

/*
 * canEnter() - ok to enter this room?
 *
 * ok to enter iff
 * a) the room is in use, and
 * b) you're an aide or it's not the aideroom, and
 * c.1) the generation numbers match, or
 * c.2) you're the sysop, or
 * c.3.1) you're an aide and
 * c.3.2) it's not invite and
 * c.3.3) aideforget isn't set, or
 * c.4) the room is public and enterifZ is TRUE
 *
 * enterifZ: if YES, allow room entry if public & forgotten.
 *	     if NO, do not allow room entry if public & forgotten.
 */
int
canEnter(int i, int enterifZ)
{
    return (readbit(roomTab[i],INUSE)
		&& (readbit(logBuf,uAIDE) || i != AIDEROOM)
		&& (roomTab[i].rtgen == LBGEN(logBuf,i)
		    || TheSysop()    /* changed from SomeSysop - AA 90Dec05 */
		    || (readbit(logBuf,uAIDE) && !(readbit(roomTab[i],INVITE)
						   || (cfg.flags.AIDE_FORGET)))
		    || (enterifZ && readbit(roomTab[i],PUBLIC))
		   )
	   );
}

/*
 * showskipped() shows the rooms we've skipped, then resets all the
 * skip pointers
 */
static void
showskipped(void)
{
    register i;
    int skip = 0;

    for (i=0; i < MAXROOMS; i++)
	if (readbit(roomTab[i],INUSE) && roomTab[i].rtgen == LBGEN(logBuf,i)) {
	    if (indices[i].visited == iSKIP) {
#if 1
		if (skip == 0)
		    iprintf("\rSkipped rooms:\r");
		iprintf(" %s ", formRoom(i, YES));
		indices[i].visited = iNEVER;
#endif
		skip++;
	    }
#if 0
	    else if (roomTab[i].rtlastMessage >
		    (1+logBuf.lbvisit[logBuf.lbgen[i] & CALLMASK]))
		return;
#endif
	}
    if (skip) {
#if 0
	mprintf("\rSkipped rooms:\r");
	for (i=LOBBY; i < MAXROOMS; i++) {
	    if (indices[i].visited == iSKIP && readbit(roomTab[i],INUSE)) {
		mprintf(" %s ", formRoom(i, YES));
		indices[i].visited = iNEVER;
	    }
	}
#endif
	doCR();
    }
}

/*
 * nextroom() - returns the next room with unread messages.
 *
 * loops through all the valid rooms, starting after the current
 * one.  If it finds a room that is completely accessible (on current
 * floor if floor mode), mark it and fall out of the loop, otherwise
 * if it's accessible but not on the floor, and if not floorhack, then
 * mark it and continue.
 * at the end of the loop, check if room was marked.  If it was, then
 * goto that room and return its index, otherwise goto the lobby (if
 * floorhack, then the `first' room on the current floor) and return
 * ERROR
 */
int
nextroom(int mode)
{
    register idx;
    register mark = ERROR;
    register visitmask;
    extern char floorhook;

    for (idx=(1+thisRoom)%MAXROOMS; idx != thisRoom; idx = (1+idx)%MAXROOMS) {
	visitmask = logBuf.lbgen[idx] & CALLMASK;
	if (canEnter(idx,NO) && indices[idx].visited == iNEVER
	     && roomTab[idx].rtlastMessage > logBuf.lbvisit[visitmask]
	     && roomTab[idx].rtlastMessage >= cfg.oldest) {
	    if (okRoom(idx)) {
		mark = idx;	/* exactly what we want - we're done */
		break;
	    }
	    else if (mark == ERROR && !floorhook)   /* maybe what we want.. */
		mark = idx;
	}
    }
    if (mark == ERROR) {
	if (!readbit(logBuf,uEXPERT))
	    iprintf("- no more rooms with new messages\r");
	toroom(floorhook ? gotoFloor(floorTab[thisFloor].flGen) : LOBBY, mode);
    }
    else
	toroom(mark, mode);
    iprintf("%s\r", roomBuf.rbname);	/* changed from mprintf - AA 90Dec04 */
    statroom();
    if (mark == ERROR)
	showskipped();
    return mark;
}

/*
 * msgCount() - counts the # of valid messages in a room
 */
int
msgCount(register int brk)
{
    int counted = 0;

    while (brk < NUMMSGS)
	if (roomBuf.msg[brk++].msgno >= cfg.oldest)
	    ++counted;
    return counted;
}

/*
 * statroom() tells us # new messages etc
 */
statroom()
{
    int total=1, new=1;

    if (loggedIn || thisRoom != MAILROOM) {
	if (thisRoom == MAILROOM) {
	    total = msgCount(0);
	}
	else
	    total = NUMMSGS;
	new = msgCount(msgbrk(logBuf.lbvisit[logBuf.lbgen[thisRoom] &
		CALLMASK]));
    }

    if (readbit(roomBuf,READONLY))
	iprintf("%s[readonly]\r", readbit(logBuf,uEXPERT) ?
	    "" : "This room is ");

    iprintf("  %s\r", plural("message", (long)total));
    if (new && (loggedIn || thisRoom == MAILROOM))
	iprintf("  %d new", new);
}

/*
 * pushroom() Save room # and last message there for ungoto
 */
static
pushroom(int room)
{
    register int i;

    indices[room].lastgen = logBuf.lbgen[room];

    /* Don't put sequential movement to the same room on the stack */
    if ((lastRoom > -1) && (lastStack[lastRoom] == room))
	return;

    if (lastRoom < USTKSIZ-1)
	lastRoom++;
    else for (i=1;i<USTKSIZ;i++)
	lastStack[i-1] = lastStack[i];
    lastStack[lastRoom] = room;
}

/*
 * toroom() save current room in ungoto stack, load next room, update visited[]
 */
void
toroom(int roomno, int skipflag)
{
    pushroom(thisRoom);
    if (skipflag == 'G' && loggedIn)
	logBuf.lbgen[thisRoom] = roomBuf.rbgen << GENSHIFT;

    indices[thisRoom].visited = (skipflag == 'S') ? iSKIP : iGOTO;
    getRoom(roomno);
}

/*
 * gotoname() returns the index of (and sets up gen numbers if it's a
 *				    private room) a named room.
 */
int
gotoname(char *name)
{
    register int where;

    if ((where = roomExists(name)) != ERROR) {
	/*
	 * do we know of this room?
	 * if the generation #'s are different and it's invitational,
	 * then only sysops are allowed.
	 * if it's the aideroom, only aides are allowed.
	 * if it's not public, only logged-in people are allowed.
	 * if we are searching for a partial name, we will not be invited
	 * into any other rooms. (added security)
	 */
	if ((where == AIDEROOM && !readbit(logBuf,uAIDE))
		|| !(readbit(roomTab[where],PUBLIC) || loggedIn)) {
	    return partialExist(name);
	}
	if (LBGEN(logBuf,where) != roomTab[where].rtgen) {
	    if (readbit(roomTab[where],INVITE) && !SomeSysop()) {
		return partialExist(name);
	    }
	    logBuf.lbgen[where] =
		(roomTab[where].rtgen<<GENSHIFT)+MAXVISIT-1;
	}
	return where;
    }
    return partialExist(name);
}

/*
 * steproom() - Stonehenge type movement (+/-)
 */
void
steproom(int expand, int forward)
{
    int i = thisRoom;
    int step = forward?(1):(-1);
    
    do {
	if ((i += step) < 0)
	    i = MAXROOMS-1;
	else if (i >= MAXROOMS)
	    i = 0;
	if (canEnter(i,NO) && okRoom(i)) {
	    toroom(i, expand ? 'G' : 'S');
	    break;
	}
    } while (i != thisRoom);
    mprintf("%s\r", roomBuf.rbname);
    statroom();
}

/*
 * gotoroom() is the fn to travel to a named room
 */
void
gotoroom(char *name, char mode)
{
    int newroom;

    if ((newroom = gotoname(name)) != ERROR) {
	toroom(newroom, mode);
	statroom();
    }
    else
	mprintf("no %s room\r", name);
}

/*
 * legalMatch() - finds a legal room that matches the target
 */
static int
legalMatch(int i, char *target)
{
    return whereis(roomTab[i].rtname,target,0,strlen(roomTab[i].rtname)) >= 0;
}

static int
hasForgotten(int i)
{
    int j;

    if readbit(roomTab[i],PUBLIC) {
	j = roomTab[i].rtgen - LBGEN(logBuf,i);
	return (j == FORGET_OFFSET) || (j == -FORGET_OFFSET);
    }
    return NO;
}

static char pHidden;

int
hasNew(int i)
{
    long newest = roomTab[i].rtlastMessage;
    long visit = logBuf.lbvisit[logBuf.lbgen[i] & CALLMASK];

    return (newest > cfg.oldest && newest > visit);
}

static int
noNew(int i)
{
    return !hasNew(i);
}

LABEL target;	/* for .kr<pattern> */

/*
 * is this room what we're looking for?
 */
int
rvalid(int rmno, short mode)
{
    if (!readbit(roomTab[rmno],INUSE))
	return 0;
    if ((mode & x_DIR) && !readbit(roomTab[rmno],ISDIR))
	return 0;
    if ((mode & x_NET) && !readbit(roomTab[rmno],SHARED))
	return 0;
    if ((mode & x_PUB) && !readbit(roomTab[rmno],PUBLIC))
	return 0;
    if ((mode & x_PRIV) && readbit(roomTab[rmno],PUBLIC))
	return 0;
    if (target[0] && !legalMatch(rmno, target))
	return 0;
    return 1;
}

static int
pickRooms(int (*pc)(), short mode, int showifZ)
{
    register i, count;
    char *formRoom();

    for (count=i=0; i<MAXROOMS; i++) {
	if (canEnter(i,showifZ) && okRoom(i) && rvalid(i, mode) && (*pc)(i) ) {
	    count++;
	    mprintf(" %s ", formRoom(i, YES));
	    if (!readbit(roomTab[i],PUBLIC))
		pHidden++;
	}
    }
    return count;
}

/*
 * listRooms() lists known rooms
 */
void
listRooms(short mode)
{
    if (mode & l_FGT) {
	mprintf("Forgotten public rooms:\r");
	if (pickRooms(hasForgotten, mode, YES))
	    doCR();
    }
    else {
	pHidden = 0;
	if (mode & l_NEW) {
	    mprintf("\rRooms with unread messages:\r");
	    if (pickRooms(hasNew, mode, NO))
		doCR();
	}
	if (mode & l_OLD) {
	    mprintf("\rNo unseen msgs in:\r");
	    if (pickRooms(noNew, mode, NO))
		doCR();
	}
	if (pHidden && !readbit(logBuf,uEXPERT))
	    mprintf("* => hidden room\r");
    }
}

/*
 * partialExist() - look for a partial match with a roomname
 */
int
partialExist(LABEL target)
{
    register int i;

    for (i = (1 + thisRoom) % MAXROOMS; i != thisRoom; i = (1 + i) % MAXROOMS)
	if (legalMatch(i, target) && canEnter(i,NO)) {
	    return i;
	}
    return ERROR;
}

/*
 * indexRooms() - rebuild roomTab[] and delete empty rooms.
 */
void
indexRooms(void)
{
    int goodRoom, m, slot, killed = 0;

    for (slot = 0;  slot < MAXROOMS;  slot++) {
	if (readbit(roomTab[slot],INUSE)) {
	    goodRoom = (roomTab[slot].rtlastMessage > cfg.oldest
				    || readbit(roomTab[slot], PERMROOM)
				    || readbit(roomTab[slot], SHARED));

	    if (goodRoom) {
		/* clean out unused floor references */
		if (findFloor(roomTab[slot].rtfloorGen) == ERROR) {
		    getRoom(slot);
		    roomBuf.rbfloorGen = LOBBYFLOOR;
		    noteRoom();
		    putRoom(slot);
		}
	    }
	    else { /* !goodRoom */
		PATHBUF fn;

		getRoom(slot);
		++killed;
		if (readbit(logBuf, uAIDE))
		    mprintf("%sJust killed %s\r", (killed == 1 ? "\r" : ""),
			roomBuf.rbname);
		clear(roomBuf,INUSE);
		clear(roomBuf,ISDIR);
		clear(roomBuf,PERMROOM);

		clear(roomBuf,DESCRIPTION);
		ctdlfile(fn, cfg.roomdir, "room%04d.inf", thisRoom);
		dunlink(fn);

		noteRoom();
		putRoom(slot);
		strcat(msgBuf.mbtext, roomBuf.rbname);
		strcat(msgBuf.mbtext, "> ");
	    }
	}
    }
}

/*
 * makeRoom() - create a new room
 */
void
makeRoom(void)
{
    register i;
    int oldroom;
    LABEL nm;
    FILE *spl;

    /* update lastMessage for current room: */
    logBuf.lbgen[thisRoom] = roomBuf.rbgen << GENSHIFT;
    oldroom = thisRoom;

    indexRooms();

    for (thisRoom = 1 + MAILROOM; thisRoom < MAXROOMS; thisRoom++)
	if (!readbit(roomTab[thisRoom],INUSE))
	    break;

    if (thisRoom >= MAXROOMS) {
	mprintf("- No room!\r");
reclaim:
	getRoom((thisRoom == oldroom) ? LOBBY : oldroom);
	/*
	 * if we were sitting in a room that got killed by indexing,
	 * leap to the lobby, otherwise leap back to that room.
	 */
	return;
    }
    getNormStr("\rName of new room", nm, NAMESIZE, YES);
    if (strlen(nm) == 0)
	goto reclaim;

    if (roomExists(nm) >= 0) {
	mprintf("A '%s' already exists.\r", nm);
	goto reclaim;
    }
    if (!readbit(logBuf,uEXPERT))
	(void) blurb("newroom", NO);

    roomBuf.flags = 0L;
    set(roomBuf,INUSE);
    roomBuf.rbdirname[0] = 0;
    if (getYesNo("Public room"))
	set(roomBuf,PUBLIC);

    mprintf("'%s', a %s room\r", nm, readbit(roomBuf,PUBLIC) ? "public":"private");

    if(!getNo("Install it"))
	goto reclaim;

    strcpy(roomBuf.rbname, nm);
/* Start with no message pointers */
    NUMMSGS = 0;
    roomBuf.msg = (theMessages *)realloc(roomBuf.msg, MSG_BULK);
    roomBuf.rbgen = (roomTab[thisRoom].rtgen + 1) % MAXGEN;
    roomBuf.rbfloorGen = floorTab[thisFloor].flGen;
    
    roomBuf.rblastNet = roomBuf.rblastLocal = 0l;

    /* room description code by AA 91Feb22 */
    if (((cfg.flags.INFOOK) || readbit(logBuf, uAIDE)) &&
	getYesNo("Would you like to enter a description of the room")) {
	zero_struct(msgBuf);
	if (loggedIn)
	    strcpy(msgBuf.mbauth, logBuf.lbname);
	if (getText(ASCII, eINFO)) {
	    PATHBUF fn;

	    ctdlfile(fn, cfg.roomdir, "room%04d.inf", thisRoom);
	    if ((spl = safeopen(fn, "wb")) != NULL) {
		_spool(spl);
		fclose(spl);
		set(roomBuf,DESCRIPTION);
	    }
	    else
		mprintf("error! could not save description\r");
	}
    }

    noteRoom(); 			/* index new room	*/
    putRoom(thisRoom);

    /* update logBuf: */
    logBuf.lbgen[thisRoom] = roomBuf.rbgen << GENSHIFT;
    sprintf(msgBuf.mbtext, "%s> created by %s", nm, uname());
    aideMessage(NO);
}

/*
 * initialArchive() of a room
 */
void
initialArchive(fn)
char *fn;
{
    int idx;

    puthold(ERROR);
    for (idx = 0; idx < NUMMSGS; idx++)
	if (findMessage(roomBuf.msg[idx].msgloc, roomBuf.msg[idx].msgno)) {
	    iprintf("%lu  ", msgBuf.mbid);
	    getmsgstr(msgBuf.mbtext, MAXTEXT);
	    msgToDisk(fn);
	}
    iprintf("\r");
    gethold(ERROR);
}

/*
 * getList() - get & process a bunch of names
 */
void
getList(int (*fn)(char *), char *prompt)
{
     LABEL buffer;

     iprintf("%s (Empty line to end)\r", prompt);
     do {
	 iprintf(": ");
	 getNormStr("", buffer, NAMESIZE, YES);
	 if (strlen(buffer) != 0 && !(*fn)(buffer))
	     break;
     } while (strlen(buffer) != 0);
}

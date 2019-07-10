/*
 * floor.c - functions having to do with floors.
 *
 * 88Jul19 orc	Allow more than 16 floors.
 * 87Dec30 orc	Change listFloor() again to show the rooms associated
 *		with each floor
 * 87Dec25 orc	Allow people to do trivial floor renames
 * 87Nov03 orc	Don't allow reading unless the user is authorised
 * 87Oct11 orc	listFloor() rewritten to look more like c-86 listfloor
 * 87Aug12 orc	Created.
 */

#include "ctdl.h"
#include "protocol.h"
#include "floor.h"
#include "room.h"
#include "log.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * * findGen()		Find a unused generation number
 * makeFloor()		Create a floor.
 * addToFloor()		Add new rooms to a floor.
 * addARoom()		Put a given room on a floor.
 * killFloor()		Kill off a floor and (optionally) all the rooms	in it.
 * doFloor()		do a floor command.
 * skipFloor()		skip all the rooms on this floor.
 * * jumpFloor()	move to the next/last floor.
 * gotoFloor()		return an accessable room on a given floor.
 * listFloor()		List accessable floors.
 * * lFloor()		Do the actual floor listing for read/unread floors
 * floorExists()	Does this floor exist?
 */

char floorhook = NO;			/* hook for floor-oriented reads*/

/*
 * findGen() - Find a unused generation number
 */
static char
findGen(void)
{
    register char gen;
    register rover;

    for (gen=0; gen < 1+cfg.floorCount; gen++) {
	for (rover=0; rover<cfg.floorCount; rover++)
	    if (floorTab[rover].flInUse && (gen == floorTab[rover].flGen))
		break;
	if (rover >= cfg.floorCount)
	    return gen;
    }
    return 1+cfg.floorCount;
}

/*
 * addARoom() - Put a given room on a floor.
 */
static int
addARoom(char *buffer)
{
    int i;

    /* The 'YES' parameter to canEnter means 'let the user move the room if it
       is public but Zed'. */
    if ((i=roomExists(buffer)) != ERROR && (canEnter(i,YES))) {
	if (i == LOBBY || i == MAILROOM || i == AIDEROOM)
	    mprintf("Can't move %s\r", formRoom(i,NO));
	else {
	    getRoom(i);
	    roomBuf.rbfloorGen = floorTab[thisFloor].flGen;
	    noteRoom();
	    putRoom(i);
	}
    }
    else
	mprintf("%s not found\r",buffer);
    return YES;
}

/*
 * makeFloor() - Create a floor.
 */
static void
makeFloor(void)
{
    LABEL floor;
    int i, nFloor, nRoom, sFloor;
    struct flTab *new;

    mprintf("create floor\r");
    getNormStr("Name of new floor", floor, NAMESIZE, YES);
    if (strlen(floor) == 0)
	return;

    for (i=0; i<cfg.floorCount; i++)
	if (floorTab[i].flInUse && stricmp(floorTab[i].flName, floor) == 0) {
	    mprintf("a [%s] already exists!\r", floor);
	    return;
	}
    for (nFloor=0; floorTab[nFloor].flInUse && nFloor<cfg.floorCount; nFloor++)
	;
    if (nFloor >= cfg.floorCount)
	if (new = (struct flTab *)realloc(floorTab, (1+cfg.floorCount) * sizeof floorTab[0])) {
	    floorTab = new;
	    cfg.floorCount++;
	}
	else {
	    mprintf("Cannot create floor!\r");
	    return;
	}
    strcpy(floorTab[nFloor].flName, floor);
    floorTab[nFloor].flGen   = findGen();
    floorTab[nFloor].flInUse = YES;

    sFloor = thisFloor;
    thisFloor = nFloor;
    getList(addARoom, "Rooms in this floor");

    updtfloor();
    if (floorTab[nFloor].flInUse) {
	sprintf(msgBuf.mbtext,"floor [%s] created by %s\r", floor, uname());
	aideMessage(NO);
    }

    if ((nRoom = gotoFloor(floorTab[nFloor].flGen)) != ERROR) {
	thisFloor = nFloor;
	getRoom(nRoom);
    }
}

/*
 * addToFloor()	- add new rooms to a floor.
 */
static void
addToFloor(void)
{
    int hold;

    putRoom(hold=thisRoom);
    getList(addARoom, "Rooms to add to this floor");
    updtfloor();
    getRoom(hold);
}

/*
 * killFloor() - kill off a floor and (optionally) all the rooms in it.
 */
static void
killFloor(void)
{
    int i, first = YES;
    char kGen;
    int roomKill;

    mprintf("kill floor - ");
    if (!(cfg.flags.AIDEKILLROOM) && !SomeSysop()) {
	mprintf("sorry, the Sysop has disabled this Aide command.\r");
	return;
    }
    if (thisFloor == LOBBYFLOOR) {
	mprintf("not this floor!\r");
	return;
    }

    sprintf(msgBuf.mbtext,"Floor [%s] killed by %s\r.",
	floorTab[thisFloor].flName, uname());

    if (getNo(confirm)) {
	putRoom(thisRoom);
	roomKill = onConsole ? getYesNo("Kill all rooms on this floor?") : NO;

	kGen = floorTab[thisFloor].flGen;
	for (i=0; i<MAXROOMS; i++)
	    if (readbit(roomTab[i],INUSE) && roomTab[i].rtfloorGen == kGen) {
		getRoom(i);
		if (roomKill) {
		    clear(roomBuf,INUSE);
		    sprintf(ENDOFSTR(msgBuf.mbtext), "%s %s>",
				first ? "Rooms deleted:" : ",",
				roomBuf.rbname);
		    first = NO;
		}
		else
		    roomBuf.rbfloorGen = LOBBYFLOOR;
		noteRoom();
		putRoom(i);
	    }
	updtfloor();
	aideMessage(NO);
	thisFloor = LOBBYFLOOR;
	getRoom(LOBBY);
    }
}

/*
 * floorExists() - Does this floor exist?
 */
static int
floorExists(LABEL floor)
{
    register i;

    for (i=0; i<cfg.floorCount; i++)
	if (floorTab[i].flInUse && stricmp(floor, floorTab[i].flName) == 0)
	    return i;
    return ERROR;
}

/*
 * floorMatch() - Partial string match for floors
 */
static int
floorMatch(LABEL floor)
{
    register i;
    register char *p;

    for (i=0; i<cfg.floorCount; i++) {
	p = floorTab[i].flName;
	if (floorTab[i].flInUse && whereis(p, floor, 0, strlen(p)) >= 0)
	    return i;
    }
    return ERROR;
}

/*
 * doFWork() - for makeFKnown/makeFUnknown.
 */
static int
doFWork(char *user, int delta)
{
    struct logBuffer person;
    int target, change=0, newVal;
    register i;

    initlogBuf(&person);
    if ((target = getnmlog(user, &person, logfl)) == ERROR)
	mprintf("'%s' not found\r", user);
    else {
	/*
	 * can't invite people to Lobby>, Mail>, or Aide>
	 */
	for (i=1+AIDEROOM; i<MAXROOMS; i++)
	    if (readbit(roomTab[i],INUSE)
		  && roomTab[i].rtfloorGen == floorTab[thisFloor].flGen){
		newVal = (roomTab[i].rtgen + delta) % MAXGEN;
		if ((person.lbgen[i] >> GENSHIFT) != newVal) {
		    change++;
		    person.lbgen[i] = (newVal << GENSHIFT) + MAXVISIT - 1;
		}
	    }
	if (change)
	    putlog(&person, target, logfl);
    }
    killlogBuf(&person);
    return YES;
}

/*
 * makeFKnown() - invite a user onto this floor
 */
static int
makeFKnown(char *user)
{
    return doFWork(user, 0);
}

/*
 * makeFUnknown() - evict a user
 */
static int
makeFUnknown(char *user)
{
    return doFWork(user, MAXGEN-1);
}

/*
 * floorAide() - floor-oriented aide functions
 */
static int
floorAide(void)
{
    LABEL floor;
    int idx;

    if (loggedIn && readbit(logBuf,uAIDE)) {
	mprintf("aide ");
	switch (toupper(getnoecho())) {
	case 'C':
	    makeFloor();
	    break;
	case 'R':
	    getNormStr("rename floor; new name", floor, NAMESIZE, YES);
	    if (strlen(floor) == 0)
		break;
	    else if ((idx=floorExists(floor)) != ERROR && idx != thisFloor)
		mprintf("That floor already exists!\r");
	    else {
		sprintf(msgBuf.mbtext,"floor [%s] renamed to [%s] by %s",
			    floorTab[thisFloor].flName,
			    floor,
			    uname());
		aideMessage(NO);
		strcpy(floorTab[thisFloor].flName, floor);
		updtfloor();
	    }
	    break;
	case 'I':
	    mprintf("invite users to [%s]\r", floorTab[thisFloor].flName);
	    getList(makeFKnown, "users to invite");
	    break;
	case 'E':
	    mprintf("evict users from [%s]\r", floorTab[thisFloor].flName);
	    getList(makeFUnknown, "users to evict");
	    break;
	case 'M':
	    mprintf("move rooms to this floor\r");
	    addToFloor();
	    break;
	case 'K':
	    killFloor();
	    break;
	case '?':
	    menu("aideflr");
	    break;
	default:
	    return YES;
	}
	return NO;
    }
    return YES;
}

/*
 * jumpFloor() - move to the next/last floor.
 */
static void
jumpFloor(int forward, int skipflag)
{
    register char nRoom;
    register int rover = thisFloor;
    register int step = forward ? (1) : (-1);

    do {
	rover += step;
	if (rover >= cfg.floorCount)
	    rover = LOBBYFLOOR;
	else if (rover < 0)
	    rover = cfg.floorCount-1;
	if (floorTab[rover].flInUse
		&& (nRoom = gotoFloor(floorTab[rover].flGen)) != ERROR) {
	    toroom(nRoom, skipflag);
	    break;
	}
    } while (rover != thisFloor);
    mprintf("[%s]\r", floorTab[thisFloor=rover].flName);
    statroom();
}

/*
 * zFloor() - forget all the rooms on a floor.
 */
static void
zFloor(void)
{
    register rover;
    register i;

    mprintf("forget");
    if (thisFloor == LOBBYFLOOR)
	mprintf("- not this floor\r");
    else {
	mprintf(" [%s]- ", floorTab[thisFloor].flName);
	if (getNo(confirm)) {
	    for (rover=0; rover<MAXROOMS; rover++)
		if (readbit(roomTab[rover],INUSE)
			    && roomTab[rover].rtfloorGen
				  == floorTab[thisFloor].flGen) {
		    i = (roomTab[rover].rtgen + FORGET_OFFSET) % MAXGEN;
		    logBuf.lbgen[rover] = i << GENSHIFT;
		}
	    nextroom('Z');	/* Bogus skipflag to percolate down to	*/
				/* toroom(), so it won't undo above gen	*/
				/* setting for current room.		*/
	}
    }
}

/*
 * doFloor() - do a floor command.
 */
int
doFloor(char c)
{
    LABEL where;
    int nFloor, nRoom;

    switch (c=toupper(c)) {
    case 'G':
	    mprintf("goto ");
	    getString("", where, NAMESIZE, '?', YES);
	    if (strcmp(where, "?") == 0) {
		doCR();
		listFloor(l_OLD|l_NEW|l_LONG);
	    }
	    else if (strlen(where) > 0) {
		normalise(where);
		if ( ((nFloor=floorExists(where)) == ERROR
			&& (nFloor=floorMatch(where)) == ERROR)
			|| ((nRoom=gotoFloor(floorTab[nFloor].flGen)) == ERROR) ) {
		    mprintf("No such floor\r");
		    return;
		}
		toroom(nRoom, 'G');
		statroom();
	    }
	    else
		jumpFloor(YES, 'G');
	    break;
    case 'K':
	    mprintf("known floors:\r");
	    listFloor(l_OLD|l_NEW|l_LONG);
	    break;
    case '>':
    case '<':
	    jumpFloor(c == '>', 'S');
	    break;
    case 'S':
	    mprintf("skip [%s] goto ", floorTab[thisFloor].flName);
	    jumpFloor(YES, 'S');
	    break;
    case 'C':
	    mprintf("%s mode\r", readbit(logBuf,uFLOORMODE)?"Normal":"FLOOR");
	    flip(logBuf,uFLOORMODE);
	    break;
    case 'Z':
	    zFloor();
	    break;
    case 'R':
	    floorhook = YES;
	    doRead(YES, 0, 'r');
	    floorhook = NO;
	    break;
    case 'A':
	    return floorAide();
    case '?':
	    menu("floor");
	    break;
    default:
	    return YES;
    }
    return NO;
}

/*
 * gotoFloor() - return an accessible room on a given floor.
 */
int
gotoFloor(char genNumber)
{
    register idx;

    for (idx=0; idx<MAXROOMS; idx++)
	if (canEnter(idx,NO) && roomTab[idx].rtfloorGen == genNumber)
	    return idx;

    return ERROR;
}

/*
 * listFloor() - List accessible floors
 */
void
listFloor(short mask)
{
    target[0] = 0;	/* Wipe out partial room name spec from .K */
    if (mask & l_NEW) {
	mprintf("\rFloors with unread messages:\r");
	lFloor(mask & ~l_OLD);
    }
    if (mask & l_OLD) {
	mprintf("\rNo unseen messages in:\r");
	lFloor(mask & ~l_NEW);
    }
}

void
lFloor(short mask)
{
    register i, j, count;
    int flag, matched;

    for (matched = i = 0; i < cfg.floorCount; i++)
	if (floorTab[i].flInUse && ((mask & l_EXCL) == 0 || i != thisFloor)) {
	    for (flag=l_OLD, count=j=0; j<MAXROOMS; j++) {
		if (roomTab[j].rtfloorGen == floorTab[i].flGen
				&& canEnter(j,NO) && rvalid(j, mask)) {
		    count++;
		    if (hasNew(j)) {
			flag=l_NEW;
			break;
		    }
		}
	    }
	    if (count && (mask & flag) != 0) {
		matched++;
		mprintf("[%s]", floorTab[i].flName);
		if (mask & l_LONG) {
		    for (j = strlen(floorTab[i].flName); j<NAMESIZE; j++)
			mformat(".");
		    CRfill = "%23c";
		    CRftn = retfmt;
		    for (j=0; j<MAXROOMS; j++)
			if (roomTab[j].rtfloorGen == floorTab[i].flGen
					&& canEnter(j,NO) && rvalid(j, mask))
			    mprintf(" %s ", formRoom(j, YES));
		    CRftn = NULL;
		    doCR();
		}
		else mprintf("  ");
	    }
	}
    if (matched && !(mask&l_LONG))
	doCR();
}


/*
 * findFloor() -- return the floor # associated with a gen number
 */
int
findFloor(char gen)
{
    register rover;

    for (rover=0; rover < cfg.floorCount; rover++)
	if (floorTab[rover].flInUse && floorTab[rover].flGen == gen)
	    return rover;
    return ERROR;
}

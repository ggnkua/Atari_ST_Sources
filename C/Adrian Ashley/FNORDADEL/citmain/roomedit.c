/*
 * roomedit.c - Edit-room function & friends
 *
 * 88Jul15 orc	modified to reduce possibility of stack overflows
 * 87Oct07 orc	extracted from roomb.c
 */

#include "ctdl.h"
#include "net.h"
#include "protocol.h"
#include "editor.h"
#include "room.h"
#include "config.h"
#include "log.h"
#include "msg.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * roomreport()		formats a summary of the current room
 * * togglemsg()	Toggle a switch and print a message
 * whosnetting()	List systems sharing this room
 * * addToList()	Adds a system to a room networking list
 * * setBB()		Set/clear backbone setting for a node
 * * takeFromList()	Removes a system from a networking list
 * * forgetRoom()	Cause users to forget a private room
 * editroom()		room editing menu
 */

static char *public_str = "public";
static char *private_str = "private";
static char *perm_str = "permanent";
static char *temp_str = "temporary";

/*
 * roomreport() - formats a summary of the current room
 */
void
roomreport(char *buffer)
{
    sprintf(buffer, "a %s%s%s%s%s, %s%sroom",
	    readbit(roomBuf,SHARED)   ? "shared, "   : "",
	    readbit(roomBuf,READONLY) ? "readonly, " : "",
	    readbit(roomBuf,ARCHIVE)  ? "archived, " : "",
	    readbit(roomBuf,ANON)     ? "anonymous, ": "",
	    readbit(roomBuf,PUBLIC)
		    ? public_str
		    : readbit(roomBuf,INVITE)
				     ? "invitation-only"
				     : private_str,
	    readbit(roomBuf,PERMROOM) ? perm_str     : temp_str,
	    readbit(roomBuf,ISDIR)    ? ", directory " : " ");

    if (readbit(roomBuf,SHARED) && readbit(roomBuf,AUTONET))
	strcat(buffer," (autonetting)");

    if (readbit(logBuf, uAIDE) && readbit(roomBuf,ISDIR))
	sprintf(ENDOFSTR(buffer), " (directory %s%s%s%s)",
	    roomBuf.rbdirname[0] ? roomBuf.rbdirname : "<undefined>",
	    readbit(roomBuf,DOWNLOAD) ? ", readable" : "",
	    readbit(roomBuf,UPLOAD) ? ", writable" : "",
	    readbit(roomBuf,NETDOWNLOAD) ? ", net readable" : "");
}

/*
 * togglemsg() - toggle a switch and print a message
 */
static int room_changed;

static void
togglemsg(char *name, long mask)
{
    flip(roomBuf,mask);
    mprintf("%s%s\r", readbit(roomBuf,mask) ? "" : "not ", name);
    room_changed++;
}

/*
 * whosnetting() - write out what systems share this room
 */
void
whosnetting(void)
{
    register i, slot;

    mprintf("Systems sharing this room:\r");
    for (i=0; i<cfg.netSize; i++)
	if readbit(netTab[i],N_INUSE) {
	    getNet(i);
	    if ((slot=issharing(thisRoom)) != ERROR)
		mprintf(netBuf.shared[slot].NRhub ? "%-21s(backbone)\r"
						  : "%s\r",  netBuf.netName);
	}
}

/*
 * addToList() - Adds a system to a room networking list
 */
static int
addToList(char *name)
{
    int slot, i, idx;

    if (name[0] == '?') {
	listnodes(NO);
	return YES;
    }

    if ((slot = netnmidx(name)) == ERROR) {
	mprintf("No '%s' known\r", name);
	return YES;
    }

    getNet(slot);

    if (issharing(thisRoom) != ERROR)
	return YES;

    for (i=0; i<SHARED_ROOMS; i++) {
	if ((idx = netBuf.shared[i].NRidx) >= 0) {
	    /*
	     * check if this room needs to have sharing cleared.
	     */
	    if (netBuf.shared[i].NRgen != roomTab[idx].rtgen
				    || !readbit(roomTab[idx],SHARED)) {
		netBuf.shared[i].NRidx = ERROR;
		break;
	    }
	}
	else break;
    }

    if (i >= SHARED_ROOMS) {
	mprintf("Already sharing %d rooms with %s\r", SHARED_ROOMS, name);
	return YES;
    }

    netBuf.shared[i].NRidx  = thisRoom;
    netBuf.shared[i].NRlast = cfg.newest;
    netBuf.shared[i].NRgen  = roomBuf.rbgen;
    netBuf.shared[i].NRhub  = NO;
    putNet(slot);
    return YES;
}

/*
 * setBB() - set/clear backbone setting for a node
 */
static int
setBB(char *name)
{
    int slot, i;

    if ((slot = netnmidx(name)) != ERROR) {
	getNet(slot);
	if ((i=issharing(thisRoom)) != ERROR) {
	    netBuf.shared[i].NRhub = !netBuf.shared[i].NRhub;
	    putNet(slot);
	    mprintf("%s is %sbackboned to %s\r",
		    roomBuf.rbname, (netBuf.shared[i].NRhub ? "" : "not "),
		    netBuf.netName);
	}
	else
	    mprintf("This room isn't shared with `%s'\r", netBuf.netName);
    }
    else
	mprintf("No `%s'\r", name);
    return YES;
}

/*
 * takeFromList() - Removes a system from a room networking list
 */
static int
takeFromList(char *name)
{
    int slot, i;

    if ((slot = netnmidx(name)) != ERROR) {
	getNet(slot);
	if ((i=issharing(thisRoom)) != ERROR) {
	    netBuf.shared[i].NRidx = -1;
	    putNet(slot);
	}
    }
    else
	mprintf("No `%s'\r", name);
    return YES;
}

/*
 * forgetRoom() - cause users to forget a private room.
 */
static void
forgetRoom(int shared, int toinvite)
{
    char msg[40];

    sprintf(msg, "Cause %s users to forget room", toinvite ? "all":"non-aide");
    if (getYesNo(msg)) {
	if (!shared || getYesNo("This will force you to re-enter \
all of the systems sharing; are you sure?")) {
	    roomBuf.rbgen = (roomBuf.rbgen +1) % MAXGEN;
	    logBuf.lbgen[thisRoom] = (logBuf.lbgen[thisRoom] & CALLMASK) +
					       (roomBuf.rbgen << GENSHIFT);
	    roomTab[thisRoom].rtgen = roomBuf.rbgen;
	}
    }
}

/*
 * doMakeWork() - for makeKnown/makeUnknown.
 */
static int
doMakeWork(char *user, int val)
{
    struct logBuffer person;
    int target;

    initlogBuf(&person);
    if ((target = getnmlog(user, &person, logfl)) == ERROR) {
	iprintf("'%s' not found\r", user);
    }
    else if (LBGEN(person, thisRoom) != val){
	person.lbgen[thisRoom] = (val << GENSHIFT) + MAXVISIT - 1;
	putlog(&person, target, logfl);
    }
    killlogBuf(&person);
    return YES;
}

/*
 * makeKnown() - invite a user into this room
 */
static int
makeKnown(char *user)
{
    return doMakeWork(user, roomBuf.rbgen);
}

/*
 * makeUnknown() - evict a user from this room
 */
static int
makeUnknown(char *user)
{
    return doMakeWork(user, (roomBuf.rbgen + (MAXGEN-1)) % MAXGEN);
}

/*
 * editroom() - room-editing menu
 */
void
editroom(void)
{
    FILE *spl;
    LABEL nm;
    PATHBUF fn;
    int r;
    char c, wasDir, wasShare, message[60];
    char *desc, *menufile;
    char *cmds;		/* commands that can be used for editing */
#define	AIDEEDIT	"TMOPVCIEKL"
#define	SYSOPEDIT	"TMOPDARWYSUVNZCIEKL"

#define	SPECEDIT	"MDARWVNIEKL"		/* for the Aide> room */
#define	LOBBYEDIT	"MDARWYZSUVNCIEKL"	/* for the Lobby room */

#define	DIREDIT		"RWN"
#define	SHAREEDIT	"UYZ"

    if (thisRoom == LOBBY || thisRoom == AIDEROOM) {
	if (!SomeSysop())
	    cmds = NULL;
	else if (thisRoom == LOBBY) {
	    menufile = "lobbedit";
	    cmds = LOBBYEDIT;
	}
	else {
	    menufile = "specedit";
	    cmds = SPECEDIT;
	}
    }
    else if (SomeSysop()) {
	menufile = "roomedit";
	cmds = SYSOPEDIT;
    }
    else {
	menufile = "aideedit";
	cmds = AIDEEDIT;
    }

    if (thisRoom == MAILROOM || !cmds) {
	mprintf("- you can't edit %s\r", formRoom(thisRoom, NO));
	return;
    }

    wasDir = (char)readbit(roomBuf,ISDIR);
    wasShare = (char)readbit(roomBuf,SHARED);
    set(roomBuf,INUSE);
    room_changed = 0;

    sprintf(msgBuf.mbtext,"%s, formerly ", formRoom(thisRoom, NO));
    roomreport(ENDOFSTR(msgBuf.mbtext));
    desc = ENDOFSTR(msgBuf.mbtext);

    doCR();
    if (!readbit(logBuf,uEXPERT))
	mprintf("%s\r", desc);
    while (onLine()) {
	outFlag = OUTOK;
	mprintf("\rEdit (%s): ", roomBuf.rbname);
	if ((c=toupper(getnoecho())) == 'X') {
	    mprintf("Exit room-editing\r");
	    break;
	}

	if (c == '?')
	    menu(menufile);
	else if (!strchr(cmds,c)
			    || (strchr(SHAREEDIT,c) && !readbit(roomBuf,SHARED))
			    || (strchr(DIREDIT,c) && !readbit(roomBuf,ISDIR)))
	    whazzit();
	else switch (c) {
	case 'T':
	    mprintf("Room type%s? ", readbit(logBuf,uEXPERT)?"":"(P/H/I)");
	    switch (toupper(getnoecho())) {
	    case 'P':
		mprintf("public\r");
		set(roomBuf,PUBLIC);
		clear(roomBuf,INVITE);
		room_changed++;
		break;
	    case 'H':
		mprintf("hidden\r");
		clear(roomBuf,PUBLIC);
		clear(roomBuf,INVITE);
		room_changed++;
		forgetRoom(wasShare, NO);
		break;
	    case 'I':
		mprintf("invitation-only\r");
		clear(roomBuf,PUBLIC);
		set(roomBuf,INVITE);
		room_changed++;
		forgetRoom(wasShare, YES);
		break;
	    default:
		whazzit();
	    }
	    break;
	case 'M':
	    flip(roomBuf,READONLY);
	    mprintf("%s room\r", readbit(roomBuf,READONLY)?"Readonly":"Normal");
	    room_changed++;
	    break;
	case 'O':
	    flip(roomBuf,ANON);
	    mprintf("%s room\r", readbit(roomBuf,ANON)?"Anonymous":"Normal");
	    room_changed++;
	    break;
	case 'P':
	    flip(roomBuf,PERMROOM);
	    mprintf("%s room\r", readbit(roomBuf,PERMROOM)?perm_str:temp_str);
	    room_changed++;
	    break;
	case 'D':
	    if (getYesNo("Directory room")) {
		set(roomBuf,ISDIR);
		if (!wasDir) {
		    wasDir = YES;
		    set(roomBuf,PERMROOM);
		    set(roomBuf,UPLOAD);
		    set(roomBuf,NETDOWNLOAD);
		    set(roomBuf,DOWNLOAD);
		}
		getArea(&roomBuf);
	    }
	    else
		clear(roomBuf,ISDIR);
	    room_changed++;
	    break;
	case 'A':
	    if readbit(roomBuf,ARCHIVE) {
		clear(roomBuf,ARCHIVE);
		mprintf("not archived\r");
		room_changed++;
	    }
	    else if (getNo("Archive this room")) {
		getNormStr("Archive to what file", message, 60, YES);
		if (strlen(message) && addArchiveList(thisRoom, message)) {
		    mprintf("Doing the initial archive:\r");
		    initialArchive(message);
		    set(roomBuf,ARCHIVE);
		    room_changed++;
		}
	    }
	    break;
	case 'R':
	    togglemsg("readable", DOWNLOAD);
	    break;
	case 'W':
	    togglemsg("writeable", UPLOAD);
	    break;
	case 'Y':
	    getList(setBB, "Set/Clear backbone status");
	    break;
	case 'S':
	    if (getYesNo("Shared room")) {
		set(roomBuf,SHARED);
		sprintf(message,"Systems to %s",wasShare ?
			"add to network list for this room" :
			"network this room with");
		getList(addToList, message);
		wasShare = YES;
	    }
	    else
		clear(roomBuf,SHARED);
	    room_changed++;
	    break;
	case 'U':
	    getList(takeFromList, "Systems to remove from room-sharing");
	    break;
	case 'V':
	    roomreport(desc);
	    mprintf("Values:\r%s\r", desc);
	    if (SomeSysop() && readbit(roomBuf,SHARED))
		whosnetting();
	    break;
	case 'N':
	    togglemsg("network readable", NETDOWNLOAD);
	    break;
	case 'Z':
	    togglemsg("autonet", AUTONET);
	    break;
	case 'K':	/* room description added by AA 91Feb21 */
	    ctdlfile(fn, cfg.roomdir, "room%04d.inf", thisRoom);
	    if (!readbit(roomBuf,DESCRIPTION))
		mprintf("no description on file!\r");
	    else if (getNo("nuke the room description")) {
		dunlink(fn);
		clear(roomBuf,DESCRIPTION);
	    }
	    break;
	case 'L':	/* room description added by AA 91Feb21 */
	    ctdlfile(fn, cfg.roomdir, "room%04d.inf", thisRoom);

	    if (readbit(roomBuf,DESCRIPTION) &&	/* there is one already? */
				(spl = safeopen(fn, "rb")) != NULL) {
		getspool(spl);
		fclose(spl);
	    }
	    else {				/* prepare for a new one */
		zero_struct(msgBuf);
		if (loggedIn)
		    strcpy(msgBuf.mbauth, logBuf.lbname);
	    }

	    if (getText(ASCII, eINFO)) {	/* Save it! */
		if ((spl = safeopen(fn, "wb")) != NULL) {
		    /* fill in some needed fields */
		    strcpy(msgBuf.mbtime, tod(YES));
		    strcpy(msgBuf.mbdate, formDate());
		    if (loggedIn)
			strcpy(msgBuf.mbauth, logBuf.lbname);
		    /* write it to disk */
		    _spool(spl);
		    fclose(spl);
		    set(roomBuf,DESCRIPTION);
		}
		else {
		    mprintf("can't save description!\r");
		    clear(roomBuf,DESCRIPTION);
		}
	    }
	    else if (readbit(roomBuf,DESCRIPTION)) {
		if (!getYes("keep old description")) {
		    clear(roomBuf,DESCRIPTION);
		    dunlink(fn);
		}
	    }
	    break;
	case 'C':
	    getNormStr("Change name to", nm, NAMESIZE, YES);
	    if (strlen(nm) > 0) {
		/* do room name check */
		if ((r = roomExists(nm)) >= 0 && r != thisRoom)
		     mprintf("A %s already exists!\r", nm);
		else {
		    strcpy(roomBuf.rbname, nm);   /* also in room itself  */
		    room_changed++;
		}
	    }
	    break;
	case 'I':		/* invite a user in... */
	    if readbit(roomBuf,PUBLIC)
		mprintf("This is not a private room!\r");
	    else
		getList(makeKnown,"Users to invite");
	    break;
	case 'E':		/* evict a user */
	    if readbit(roomBuf,PUBLIC)
		mprintf("This is not a private room!\r");
	    else
		getList(makeUnknown,"Users to evict");
	    break;
	}
    }
    noteRoom();
    putRoom(thisRoom);

    if (room_changed) {
	sprintf(desc, ", has been edited to %s, ", formRoom(thisRoom, NO));
	roomreport(ENDOFSTR(msgBuf.mbtext));
	sprintf(ENDOFSTR(msgBuf.mbtext),", by %s.", uname());
	aideMessage(NO);
    }
    return;
}

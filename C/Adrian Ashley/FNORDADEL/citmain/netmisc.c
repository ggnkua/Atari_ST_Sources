/* #define NMDEBUG */

/*
 * netmisc.c -- Miscellaneous networking functions.
 *
 * 88Jul16 orc	Replace old-style sendfile/request-file code.
 * 88Jun01 orc	netValidate, isNettable, netInfo moved to msg.c
 * 88Feb15 orc	Cosmetic changes.
 * 87Nov01 orc	wrShared() was losing rooms -- fixed.
 * 87Sep16 orc	netPrintMsg() created for network message sending.
 * 87Sep06 orc	Networking control functions split off to NETMAIN.C
 * 87Aug27 orc	use grabCC() to figure net baud, rewrite main loop of
 *		netController, write code to set poll limits for l-d netting.
 * 87Aug08 orc	Use netTimeLeft() when a 'normal user' calls in during
 *		networking.
 * 87Jul31 orc	System dies when some user calls in during networking
 *		(mPrintf without protocol set...)
 * 87Jul24 orc	Multi-net support
 * 87May24 orc	shared rooms aren't working -- fix them.
 * 87May17 orc	Sendfile support.
 * 87May04 orc	l-d receive-only support.
 * 87Apr22 orc	netValidate() & isNettable() created for name@system
 *		destination addresses.
 * 87Apr01 orc	Hacked up for STadel.
 * 86Aug20 HAW	History not maintained due to space problems.
 */

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "room.h"
#include "msg.h"
#include "event.h"
#include "dirlist.h"
#include "terminat.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * normID()		Normalizes a node id.
 * srchNetNm()		Searches net for the given node name.
 * srchNetId()		Searches net for the given Id.
 * * nettoggle()	flip net privs for a user
 * * creditsetting()	give a user net credits
 * listnodes()		Write up nodes on the net.
 * * getSendFiles()	Get files to send to another system
 * * fileRequest()	For network requests of files.
 * * addNetNode()	Add a node to the net listing
 * * showNode()		Show the values for a net node
 * * roomsIshare()	list all the rooms a node shares
 * * editNode()		Edit a net node
 * netmenu()		Handles networking for the sysop
 * mesgpending()	does a given room have messages?
 * netmesg()		Does this system need to share something
 * netPrintMsg()	Put a message out in network form
 * * subtract()		accumulate filesizes.
 * sysRoomLeft()	how much room left in net recept area
 * netchdir()		cd() or error out.
 */

static char *bauds[] = { "300", "1200", "2400", "9600", "19200" };

char *strchr();

#define netPending(i)	(readbit(netTab[i],N_INUSE) \
			&& (readbit(netTab[i],MAILPENDING) \
			|| readbit(netTab[i],FILEPENDING) || netmesg(i) ))

char route_char = 'L';	/* routing code -- set by dumpNetRoom */

/*
 * normID() - Normalizes a node id
 */
int
normID(register char *source, register char *dest)
{
    while (!isalpha(*source) && *source)
	source++;
    if (!*source) return FALSE;
    *dest++ = toupper(*source++);
    while (!isalpha(*source) && *source)
	source++;
    if (!*source) return FALSE;
    *dest++ = toupper(*source++);
    while (*source) {
	if (isdigit(*source))
	    *dest++ = *source;
	source++;
    }
    *dest = 0;
    return TRUE;
}

/*
 * srchNetNm() - Searches net for the given name.
 */
int
srchNetNm(char *name)
{
    int rover;

    for (rover = 0; rover < cfg.netSize; rover++) {
	if (readbit(netTab[rover],N_INUSE)
			&& hash(name) == netTab[rover].ntnmhash) {
	    getNet(rover);
	    if (stricmp(netBuf.netName, name) == 0)
		return rover;
	}
    }
    return ERROR;
}

/*
 * srchNetId() - Searches net for the given Id.
 */
int
srchNetId(char *forId)
{
    int rover;
    LABEL temp;

    for (rover = 0; rover < cfg.netSize; rover++) {
	if (readbit(netTab[rover],N_INUSE)
			&& hash(forId) == netTab[rover].ntidhash) {
	    getNet(rover);
	    normID(netBuf.netId, temp);
	    if (stricmp(temp, forId) == 0)
		return rover;
	}
    }
    return ERROR;
}

/*
 * shownets() - show the nets that a given node is in
 */
static void
shownets(long mask)
{
    int c, i;

    for (c=' ', i=0; i<32; i++)
	if (mask & (1L << (long)i)) {
	    mprintf("%c%d", c, i);
	    c = ',';
	}
}

/*
 * listnodes() - write up nodes on the net
 */
void
listnodes(int extended)
{
    int rover;

    outFlag = OUTOK;
    for (rover = 0; rover < cfg.netSize; rover++) {
	getNet(rover);
	if readbit(netBuf,N_INUSE)
	    if (extended) {
		mprintf("%c %-20.20s %-20.20s%c%c%c%c %5s",
			netPending(rover) ? '*' : ' ',
			netBuf.netName, netBuf.netId,
			readbit(netBuf,CIT86) ? 'C' : ' ',
			readbit(netBuf,REC_ONLY) ? 'R' : ' ',
			readbit(netBuf,MAILPENDING) ? 'M' : ' ',
			readbit(netBuf,FILEPENDING) ? 'F' : ' ',
			bauds[netBuf.baudCode]);
		shownets(netBuf.what_net);
		doCR();
	    }
	    else if (netBuf.what_net)
		mprintf("%s\r", netBuf.netName);
    }
}

/*
 * getSendFiles() - Send files to another system
 */
static void
getSendFiles(void)
{
    LABEL   sysName;
    PATHBUF sysFile;
    int     sendidx;

    if ((sendidx = getSysName("To", sysName)) == ERROR)
	return;

    getNormStr("File(s)", sysFile, 100, YES);
    if (strlen(sysFile) < 1)
	return;
    
    if (getdirentry(sysFile))
	nfs_put(sendidx, SEND_FILE, sysFile, NULL, NULL);
    else
	mprintf("File not found\r");
}

/*
 * fileRequest() - network request files.
 */
static void
fileRequest(void)
{
    LABEL   reqroom;
    LABEL   reqfile;
    PATHBUF reqdir;
    LABEL   system;
    int     reqidx;

    if ((reqidx = getSysName("From", system)) == ERROR)
	return;
    getNormStr("What room", reqroom, NAMESIZE, YES);
    if (strlen(reqroom) < 1)
	return;
    getNormStr("Filename", reqfile, NAMESIZE, YES);
    if (strlen(reqfile) < 1)
	return;
    getNormStr("Destination directory", reqdir, PATHSIZE, YES);
    if (strlen(reqdir) < 1)
	return;
    if (xchdir(reqdir))
	nfs_put(reqidx, FILE_REQUEST, reqfile, reqdir, reqroom);
    else
	mprintf("Directory not found\r");
}

/*
 * addNetNode() - Add a node to the net
 */
static void
addNetNode(void)
{
    int newidx, i, netidhash;
    LABEL temp;

    /* Following changed from zero_struct(netBuf) by AA 90Jan31 */
    memset(&netBuf, 0, NB_SIZE);
    memset(netBuf.shared, 0, SR_BULK);

    while (1) {
	getNormStr("System name", netBuf.netName, NAMESIZE, YES);
	if (strlen(netBuf.netName) == 0)
	    return;
	if (netnmidx(netBuf.netName) != ERROR)
	    mprintf("%s already exists!\r",netBuf.netName);
	else if (NNisok(netBuf.netName))
	    break;
	else
	    mprintf("Illegal character in name\r");
    }
    getNormStr("System ID", netBuf.netId, NAMESIZE, YES);
    if (strlen(netBuf.netId) == 0)
	return;
    normID(netBuf.netId, temp);
    netidhash = hash(temp);
    for (i=0; i < cfg.netSize; i++)
	if (netidhash == netTab[i].ntidhash) {
	    mprintf("There's already a node with that ID.\r");
	    return;
	}
    netBuf.baudCode = getNumber("Baudrate", 0L, (long)(NUMBAUDS-1));
    netBuf.ld      = !getYesNo("Is system local");
    set(netBuf,LD_RR);
    clear(netBuf,REC_ONLY);
    set(netBuf,N_INUSE);
    netBuf.what_net= 1L;
    netBuf.dialer  = 0;
    netBuf.poll_day= 0;

    for (newidx = 0; newidx < cfg.netSize; newidx++)
	if (!readbit(netTab[newidx],N_INUSE))
	    break;
    if (newidx >= cfg.netSize) {
	newidx = cfg.netSize;
	netTab = realloc(netTab, sizeof (*netTab) * ++cfg.netSize);
	netTab[newidx].Tshared = (struct netroom *) xmalloc(SR_BULK);
    }

    for (i = 0; i < SHARED_ROOMS; i++)
	netBuf.shared[i].NRidx = -1;

    netTab[newidx].ntnmhash = hash(netBuf.netName);
    netTab[newidx].ntidhash = netidhash;

    putNet(newidx);
}

static void
showNode(void)
{
    mprintf("\rID: %s\r", netBuf.netId);
    if (strlen(netBuf.access))
	mprintf("Access: %s\r", netBuf.access);

    if (strlen(netBuf.myPasswd) || strlen(netBuf.herPasswd))
	mprintf("Passwords: local = `%s', remote = `%s'\r",
	    netBuf.myPasswd, netBuf.herPasswd);

    mprintf("A ");

    if readbit(netBuf,REC_ONLY)
	mprintf("receive-only ");

    if (netBuf.ld) {
	if (!readbit(netBuf,LD_RR))
	    mprintf("non-role-reversing ");
	mprintf("l-d ");
	if (netBuf.ld > 1)
	    mprintf("(poll count=%d) ", netBuf.ld);
    }
    else
	mprintf("local ");
    if readbit(netBuf,CIT86)
	mprintf("Cit-86 ");

    mprintf("system running at %s baud.\r", bauds[netBuf.baudCode]);

    if readbit(netBuf,MAILPENDING)
	mprintf("[mail pending]\r");
    if readbit(netBuf,FILEPENDING)
	mprintf("[files pending]\r");
    if (netBuf.dialer)
	mprintf("Dialer #%d\r", 0xff & netBuf.dialer);

    mprintf("this node is ");
    if (netBuf.what_net) {
	mprintf("in net:");
	shownets(netBuf.what_net);
	if (netBuf.poll_day) {
	    mprintf("\rpolls on:");
	    showdays(netBuf.poll_day, YES);
	}
    }
    else
	mprintf("not assigned to a net");
    doCR();
}

/*
 * roomsIshare() - list all the rooms a node shares
 */
static void
roomsIshare(int place)
{
    int i, first = 1;
    int rmidx;
    char *rmalias, *rmname;

    for (i=0; i<SHARED_ROOMS; i++) {
	rmidx = netBuf.shared[i].NRidx;
	if (rmidx >= 0 && netBuf.shared[i].NRgen == roomTab[rmidx].rtgen) {
	    rmname = roomTab[rmidx].rtname;
	    rmalias= chk_alias(net_alias, place, rmname);
	    mprintf( (rmname != rmalias) ? "%s %s (alias for %s)" : "%s %s",
					(first ? "" : ","), rmname, rmalias);
	    mprintf("%s", mesgpending(&netBuf.shared[i]) ? " * " : "");
	    first = 0;
	}
    }
    doCR();
}

/*
 * editNode() Edit a net node
 */
static void
editNode(void)
{
    LABEL sysname, temp;
    PATHBUF temp2;
    int i, place, pd;
    char nets[80];
    long mask, l, k, atol();
    char *p, *strtok();

    if ((place=getSysName("Node to edit", sysname)) == ERROR)
	return;
    showNode();

    while (onLine()) {
	outFlag = OUTOK;
	mprintf("\r(%s) edit fn: ", netBuf.netName);
	switch (toupper(getnoecho())) {
	    case '?':
		menu("netedit");
		break;
	    case 'A':
		getString("Access string", netBuf.access, 40, 0, YES);
		break;
	    case 'R':
		mprintf("Rooms shared\r");
		roomsIshare(place);
		break;
	    case 'X':
		mprintf("Exit to net menu");
		normID(netBuf.netId, temp);
		netTab[place].ntnmhash = hash(netBuf.netName);
		netTab[place].ntidhash = hash(temp);
		putNet(place);
		return;
	    case 'B':
		netBuf.baudCode = asknumber("Baudrate", 0l, (long)(NUMBAUDS-1),
							      netBuf.baudCode);
		break;
	    case 'F':
		getNormStr("Set poll days", nets, 80, YES);
		if (stricmp(nets,"all") == 0)
		    netBuf.poll_day = 0x7f;
		else {
		    pd = 0;
		    for (p=strtok(nets,"\t ,"); p; p=strtok(NULL,"\t ,")) {
			for (i=0; i<7; ++i)
/* NOTE: _alt_day[] has Mon first, while _day[] has Sun first. */
			    if (stricmp(p,_alt_day[i]) == 0) {
				pd |= (1<<i);
				break;
			    }
			if (i>=7) {
			    mprintf("bad day %s\r", p);
			    pd = -1;
			    break;
			}
		    }
		    if (pd >= 0)
			netBuf.poll_day = pd;
		}
		break;
	    case 'N':
		getNormStr("Name change to", temp, NAMESIZE, YES);
		if (strlen(temp) != 0)
		    if (netnmidx(temp) != ERROR)
			mprintf("%s already exists!\r",temp);
		    else if (NNisok(temp))
			strcpy(netBuf.netName, temp);
		    else
			mprintf("Bad nodename\r");
		break;
	    case 'I':
		getString("New node ID", temp, NAMESIZE, 0, YES);
		if (strlen(temp) != 0)
		    strcpy(netBuf.netId, temp);
		break;
	    case 'K':
		mprintf("Kill node\r");
		if readbit(netBuf,MAILPENDING)
		    mprintf("There is outgoing mail.\r");
		if (getNo("confirm (did you unshare all net rooms?)")) {
		    clear(netBuf,N_INUSE);
		    putNet(place);
/* next line added by AA 90Sep05 */
		    netTab[place].ntnmhash = netTab[place].ntidhash = 0;
		    ctdlfile(temp2, cfg.netdir, "%d.ml", thisNet);
		    dunlink(temp2);
		    ctdlfile(temp2, cfg.netdir, "%d.fwd", thisNet);
		    dunlink(temp2);
		    ctdlfile(temp2, cfg.netdir, "%d.nfs", thisNet);
		    dunlink(temp2);
		    mprintf("Killed.\r");
		    return;
		}
		break;
	    case 'L':
		netBuf.ld = !getYesNo("Is system local");
		break;
	    case 'T':
		if (getYesNo("Is system a Cit-86"))
		    set(netBuf,CIT86);
		else
		    clear(netBuf,CIT86);
		break;
	    case 'C':
		if (!getYesNo("Ok to call this system"))
		    set(netBuf,REC_ONLY);
		else
		    clear(netBuf,REC_ONLY);
		break;
	    case 'V':
		showNode();
		break;
	    case 'P':
		mprintf("Passwords\r");
		mprintf("local = `%s'\rremote = `%s'\r",
			netBuf.myPasswd, netBuf.herPasswd);
		if (getYesNo("Change passwords")) {
		    getNormStr("Local pw", netBuf.myPasswd, NAMESIZE, YES);
		    getNormStr("Remote pw",netBuf.herPasswd,NAMESIZE, YES);
		}
		break;
	    case 'U':
		getNormStr("Use what nets", nets, 79, YES);
		if (strlen(nets) > 0) {
		    p = &nets[strchr("+-",nets[0]) ? 1 : 0];
		    for (mask=0L,p=strtok(p,"\t ,"); p; p=strtok(NULL,"\t ,")){
			k = atol(p);	/* explicit evaluation to avoid */
			l = 1L << k;	/* compiler weirdnesses		*/
			mask |= l;
		    }
		    switch (nets[0]) {
		    case '+':
			netBuf.what_net |= mask;
			break;
		    case '-':
			netBuf.what_net &= ~mask;
			break;
		    default:
			netBuf.what_net = mask;
			break;
		    }
		}
		break;
	    case 'E':
		mformat("External dialer ");
		mprintf(netBuf.dialer ? "(dial_%d.prg)" : "(none)",
						0xff & netBuf.dialer);
		doCR();
		netBuf.dialer = asknumber("New dialer (0 to disable)",
						   0L, 10L,
						   netBuf.dialer);
		break;
	    case 'Z':
		if (netBuf.ld) {
		    mprintf("Poll count=%d\r", netBuf.ld);
		    netBuf.ld = getNumber("New poll count", 1L, 127L);
		    break;
		} /* else fall into next case, which has the same test... */
	    case 'D':
		if (netBuf.ld) {
		    if (getYes("Allow l-d role reversal"))
			set(netBuf,LD_RR);
		    else
			clear(netBuf,LD_RR);
		    break;
		} /* else fall into default case */
	    default:
		whazzit();
		break;
	}
    }
}

static int
dodiscard(struct dirList *fn)
{
    FILE *spl;
    PATHBUF path;
    int rm, aideroom;

    ctdlfile(path, cfg.netdir, fn->fd_name);
    if ((spl = safeopen(path, "rb")) == NULL) {
	mprintf("Can't open %s!\r", path);
	return 0;
    }

    getspool(spl);
    fclose(spl);

#if 0
    msgBuf.mbid = cfg.newest + 1;	/* Kluge for printdraft() */

    if ((rm = thisRoom) == roomExists(msgBuf.mbroom)) {
	getRoom(AIDEROOM);
	printdraft();
	getRoom(rm);
    }
    else
	printdraft();
#else
    mprintf("\r   In room %s:", msgBuf.mbroom);
    printdraft();
#endif

prompt:
    outFlag = OUTOK;
    mprintf("\r\r[A]gain, [D]elete, [I]ntegrate, [N]ext, [S]top: ");
    while (onLine()) {
	switch (toupper(getnoecho())) {
	case 'A':
	    mprintf("Again\r");
#if 0
	    if ((rm = thisRoom) == roomExists(msgBuf.mbroom)) {
		getRoom(AIDEROOM);
		printdraft();
		getRoom(rm);
	    }
	    else
		printdraft();
#else
		mprintf("   In room %s:\r", msgBuf.mbroom);
		printdraft();
#endif
	    goto prompt;
	case 'D':
	    mprintf("Delete\r");
	    if (getYes("Confirm")) {
		dunlink(path);
		return 1;
	    }
	    goto prompt;
	case 'I':
	    mprintf("Integrate\r");
	    aideroom = NO;
	    if (getYes("Confirm")) {
		if ((rm = roomExists(msgBuf.mbroom)) != ERROR || (aideroom = 
		getYes("The room no longer exists!  Put in Aide> instead"))) {
		    getRoom(aideroom ? AIDEROOM : rm);
		    storeMessage(NULL, ERROR);
		    if (getYes("Delete it"))
			dunlink(path);
		    return 1;
		}
	    }
	    goto prompt;
	case 'N':
	    mprintf("Next\r");
	    return 1;
	case 'S':
	    mprintf("Stop\r");
	    return 0;
	default:
	    oChar(BELL);
	}
    }
    return 0;
}

/*
 * netmenu() - Sysop net management
 */
void
netmenu(void)
{
    char tmp[10];
    int  topoll, idx, oldroom, count, i;
    struct dirList *list;
    LABEL sysname;

    while (onLine()) {
	outFlag = OUTOK;
	mprintf("\rNet function: ");
	switch (toupper(getnoecho())) {
	case 'R':
	    mprintf("Request File\r");
	    fileRequest();
	    break;
	case 'S':
	    mprintf("Send File\r");
	    getSendFiles();
	    break;
	case 'X':
	    mprintf("Exit to main menu");
	    return;
	case 'V':
	    mprintf("View netlist\r");
	    listnodes(YES);
	    break;
	case 'F':
	    if ((idx = getSysName("Node to force-poll", sysname)) == ERROR)
		break;
	    if (loggedIn)
		terminate(YES, tPOLLPUNT);	/* POLLPUNT is close enough */
	    openNet();
	    modemOpen();
	    if (callout(idx))
		caller();
	    closeNet();	
	    haveCarrier = onConsole = FALSE;
	    justLostCarrier = TRUE;
	    break;
	case 'P':
	    getNormStr("Poll what net", tmp, 9, YES);
	    if (strlen(tmp) > 0 && (topoll=atoi(tmp)) >= 0 && topoll <= 32) {
		pollnet(topoll);
		haveCarrier = onConsole = FALSE;
		justLostCarrier = TRUE;
	    }
	    break;
	case 'A':
	    mprintf("Add node- ");
	    addNetNode();
	    break;
	case 'E':
	    mprintf("Edit- ");
	    editNode();
	    break;
	case 'D':
	    mprintf("Discarded messages\r");
	    xchdir(&cfg.codeBuf[cfg.netdir]);
	    count = scandir("*.dis", &list);
	    mprintf("\rThere %s %d discarded message%s.\r",
		(count == 1) ? "is" : "are", count, (count == 1) ? "" : "s");
	    if (count != 0) {
		oldroom = thisRoom;
		for (i=0; i<count && dodiscard(&list[i]); i++)
		    ;
		if (thisRoom != oldroom)
		    getRoom(oldroom);
	    }
	    freedir(list, count);
	    break;
	case '?':
	    menu("netopt");
	    break;
	default:
	    whazzit();
	}
    }
}

/*
 * getSysName() - Get a node for file send/request
 */
int
getSysName(char *prompt, char *system)
{
    int place;

    getString(prompt, system, NAMESIZE, '?', YES);
    if (strcmp(system, "?") == 0) {
	mprintf("Systems:\r");
	listnodes(NO);
    }
    else {
	normalise(system);
	if (strlen(system) < 1)
	    return ERROR;
	if ((place = netnmidx(system)) == ERROR) {
	    mprintf("%s not listed!\r", system);
	}
	else
	    return place;
    }
    return ERROR;
}

/*
 * mesgpending() - Any messages to be shared with other nodes?
 */
int
mesgpending(struct netroom *nr)
{
    register rmidx = nr->NRidx;

    if (rmidx >= 0 && nr->NRgen == roomTab[rmidx].rtgen) {
#ifdef NMDEBUG
	xprintf("L room: %d, roomTab: %ld, netroom: %ld\n", rmidx,
	    roomTab[rmidx].rtlastNet, nr->NRlast);
	if (nr->NRhub)
	    xprintf("H room: %d, roomTab: %ld, netroom: %ld\n", rmidx,
		roomTab[rmidx].rtlastLocal, nr->NRlast);
#endif
	return (roomTab[rmidx].rtlastNet > nr->NRlast)
		|| (nr->NRhub && (roomTab[rmidx].rtlastLocal > nr->NRlast));
    }
    return NO;
}

/*
 * netmesg() - Does this system has a room with data to share?
 */
int
netmesg(int slot)
{
    register i;

    for (i = 0; i < SHARED_ROOMS; i++)
	if (mesgpending(&netTab[slot].Tshared[i]))
	    return YES;
    return NO;
}

/*
 * netPrintMsg() - networking dump of a message
 */
void
netPrintMsg(short loc, long id)
{
    register c;

    if (!findMessage(loc,id))	/* can't find it...	*/
	return;
    /*
     * send message text proper
     */
    sendXmh();
    (*sendPFchar)('M');
    while ((*sendPFchar)(c=getmsgchar()) && c)
	;
}

/*
 * sendXmh() - throw message headers across the net
 */
void
sendXmh(void)
{
    LABEL srcid;

    if (msgBuf.mbauth[0])	wcprintf("A%s", msgBuf.mbauth);
    if (msgBuf.mbdate[0])	wcprintf("D%s", msgBuf.mbdate);
    if (msgBuf.mbtime[0])	wcprintf("C%s", msgBuf.mbtime);
    if (msgBuf.mbroom[0])	wcprintf("R%s", msgBuf.mbroom);
    if (msgBuf.mbto[0])		wcprintf("T%s", msgBuf.mbto);
    if (msgBuf.mbdomain[0])	wcprintf("X%s", msgBuf.mbdomain);
    if (msgBuf.mbsub[0])	wcprintf("J%s", msgBuf.mbsub);

    wcprintf("N%s", msgBuf.mboname[0]
			? msgBuf.mboname
			: &cfg.codeBuf[cfg.nodeName]);
    wcprintf("O%s", msgBuf.mborig[0]
			? msgBuf.mborig
			: &cfg.codeBuf[cfg.nodeId]);
    wcprintf("I%s", msgBuf.mborg);

    if (msgBuf.mbsrcid != 0L)	/* added by AA/RH 91Jan01 */
	wcprintf("S%u %u",
	    (unsigned short)((msgBuf.mbsrcid & 0xffff0000L) >> 16),
	    (unsigned short)(msgBuf.mbsrcid & 0x0000ffffL));

    if (route_char) {
	/*
	 * either Z@L<id> or Z@H<id>
	 */
	normID(&cfg.codeBuf[cfg.nodeId], srcid);
	wcprintf("Z@%c%s", route_char, srcid);
    }
}

/*
 * subtract() - accumulate filesizes
 */
static long remaining;

static int
subtract(struct dirList *p)
{
    remaining -= p->fd_size;
    return YES;
}

/*
 * sysRoomLeft() - how much room left in net receipt area
 */
long
sysRoomLeft(void)
{
    remaining = 1024L * cfg.recSize;
    wildcard(subtract, "*.*", 0L);
    return remaining;
}

/*
 * netchdir() - change directory or die
 */
int
netchdir(char *path)
{
    if (cd(path)) {
	splitF(netLog, "No directory `%s'.\n", path);
	return NO;
    }
    return YES;
}

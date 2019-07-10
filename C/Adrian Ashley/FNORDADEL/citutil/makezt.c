/*
 * makezt.c -- Create zaploop tables
 *
 * 91Jan03 AA	Hacked up to know about the new nodename, gen & lastid fields
 * 88Jul04 orc	Fixed (patriotically)
 * 88Jun20 orc	Created.
 */

#include "ctdl.h"
#include "zaploop.h"
#include "msg.h"
#include "room.h"
#include "config.h"
#include "citlib.h"

#ifdef TEST
char inNet = YES;
char loggedIn = NO;
#endif

char *program = "makezt";

static struct zaploop zapnode;
static int zapdbx;
static short zapcur = ERROR;
static struct mupdate {
    time_t mulast;		/* newest message found here... (date) */
    long mulastid;		/* highest message id found here */
    short muloc;		/* bucket for this message	*/
} *nzmsg;
static int nzsize;

char checkloops = 1;

time_t today;	/* holds current time for compares against msg time/dates */

#ifdef TEST
/*
 * decoy routines to avoid linker hysterics
 */
mprintf() {}
mAbort() {}
xprintf() {}

/*
 * decoy variables to avoid linker hysterics
 */
char haveCarrier;
char usingWCprotocol = 0;
char echo;
int (*sendPFchar)();
#endif

/*
 * normID() -- Normalizes a node id.
 */
int
normID(LABEL source, LABEL dest)
{
    while (!isalpha(*source) && *source)
	source++;
    if (!*source) return NO;
    *dest++ = toupper(*source++);
    while (!isalpha(*source) && *source)
	source++;
    if (!*source) return NO;
    *dest++ = toupper(*source++);
    while (*source) {
	if (isdigit(*source))
	    *dest++ = *source;
	source++;
    }
    *dest = 0;
    return YES;
}

/*
 * roomAt() -- what room is this?
 */
int
roomAt(char *rmname)
{
    for (thisRoom = AIDEROOM + 1; thisRoom < MAXROOMS; thisRoom++)
	if (stricmp(roomTab[thisRoom].rtname, rmname) == 0)
	    return thisRoom;
    return thisRoom = ERROR;
}

/*
 * init_zap() - open the zaploop database
 */
void
init_zap(void)
{
    PATHBUF zapfile;

    ctdlfile(zapfile, cfg.netdir, "ctdlloop.zap");

    dunlink(zapfile);
    if ((zapdbx = dcreat(zapfile)) < 0)
	crashout("cannot open %s\n", zapfile);
    nzmsg = (struct mupdate *)malloc(sizeof *nzmsg);
    nzsize = 0;
}

static void
getx(short i)
{
    zapcur = i;
    dseek(zapdbx, zapcur * sizeof zapnode, SEEK_SET);
    dread(zapdbx, &zapnode, sizeof(zapnode));
}

static void
putx(void)
{
    if (zapcur != ERROR) {
	dseek(zapdbx, zapcur * sizeof zapnode, SEEK_SET);
	dwrite(zapdbx, &zapnode, sizeof(zapnode));
    }
}

/*
 * close_zap() - close the zaploop database
 */
void
close_zap(void)
{
    register i;

    if (nzmsg) {
	for (i = 0; i < nzsize; i++)
	    if (nzmsg[i].mulast > 0L || nzmsg[i].mulastid > 0L) {
		getx(nzmsg[i].muloc);
		zapnode.lxlast = nzmsg[i].mulast;
		zapnode.lxlastid = nzmsg[i].mulastid;
		putx();
	    }
	free(nzmsg);
	nzmsg = NULL;
	nzsize = 0;
    }
    if (zapdbx >= 0)
	dclose(zapdbx);
    zapdbx = -1;
}

/*
 * makebucket() -- make up a new zap entry for this address/room
 */
static int
makebucket(char *address, char *name, short chain)
{
    long pos = dseek(zapdbx, 0L, SEEK_END);	/* seek to eof */

    if (pos >= 0)
	pos /= sizeof zapnode;
    zapcur = pos;
    strcpy(zapnode.lxaddr, address);
    strcpy(zapnode.lxname, name);
    zapnode.lxlast = 0L;
    zapnode.lxlastid = 0L;
    zapnode.lxchain = chain;
    zapnode.lxroom = thisRoom;
    zapnode.lxgen = roomTab[thisRoom].rtgen;
    putx();
    return zapcur;
}

/*
 * loadx() -- load up the appropriate zap record for a node
 */
static int
loadx(char *addr, char *name)
{
    register int i;
    register short ahash = hash(addr);

#define	THIS(x)	(stricmp(x,zapnode.lxaddr) == 0 && zapnode.lxroom == thisRoom)

    if (addr[0] == 0 || strlen(addr) > 12)
	return 0;
    if (zapcur != ERROR && THIS(addr))
	return 1;
    for (i = 0; i < cfg.zap_count; i++)
	if (ahash == zap[i].zhash) {
	    getx(zap[i].zbucket);
	    if (stricmp(addr, zapnode.lxaddr) != 0)
		continue;
	    while (zapnode.lxroom != thisRoom && zapnode.lxchain >= 0)
		getx(zapnode.lxchain);
	    if (zapnode.lxroom != thisRoom)
		zap[i].zbucket = makebucket(addr, name, zap[i].zbucket);
	    else {	/* right room, so check gen */
		if (zapnode.lxgen != roomTab[thisRoom].rtgen) {
		    zapnode.lxgen = roomTab[thisRoom].rtgen;   /* update gen */
		    zapnode.lxlast = zapnode.lxlastid = 0L;	/* reset */
		    putx();
		}
	    }
	    return 1;
	}
    /*
     * new node id -- add a new record
     */
    if (zap = (struct zaphash *)
		realloc(zap, (1+cfg.zap_count) * sizeof(struct zaphash))) {
	zap[cfg.zap_count].zhash = ahash;
	zap[cfg.zap_count].zbucket = makebucket(addr, name, -1);
	cfg.zap_count++;
	printf("Created new zap entry for %s (%s)\n", msgBuf.mboname,
	    roomTab[thisRoom].rtname);
	return 1;
    }
    fprintf(stderr, "(loadx) Out of memory.\n");
    checkloops = 0;
    return 0;
}

/* 
 * notseen() - looping message?
 *
 * Algorithm: We reject a message if:
 * 
 *   a) Its time & date is EARLIER than the latest message received AND
 *	its message id is LESS THAN that of the latest message received, or
 *   b) If the message has no id, we reject it iff its time & date is EARLIER.
 *
 * Extras: we ignore all messages bearing time/date stamps more than 1 day
 * later than our current time.  This helps weed out messages which have come
 * in from systems whose clocks have been screwed up.
 */
int
notseen(void)
{
    time_t last = msgtime(msgBuf.mbdate, msgBuf.mbtime);
    long lastid = msgBuf.mbsrcid;
    LABEL chk;
    int i;
    struct mupdate *tmp;

    if (last == ERROR) {
	printf("Message with unparsable date (%s %s) encountered\n",
	    msgBuf.mbdate, msgBuf.mbtime);
	return 1;
    }
    if (last > today) {
	printf("Message with spurious date (%s) encountered\n",
	    makedate(last, YES));
	return 1;
    }
    if (lastid < 0L || lastid > 1000000L) {
	printf("Message with invalid mbsrcid (%ld) encountered\n",
	    msgBuf.mbsrcid);
	return 1;
    }

    if (checkloops && normID(msgBuf.mborig, chk) && loadx(chk, msgBuf.mboname))
	if (last > zapnode.lxlast || lastid > zapnode.lxlastid) {
	    for (i = 0; i < nzsize; i++)
		if (nzmsg[i].muloc == zapcur)  {
		    if (last > nzmsg[i].mulast)
			nzmsg[i].mulast = last;
		    if (lastid > nzmsg[i].mulastid)
			nzmsg[i].mulastid = lastid;
		    return 1;	    
		}
	    tmp = (struct mupdate *)
		realloc(nzmsg, (1 + nzsize) * sizeof(struct mupdate));
	    if (tmp) {
		nzmsg = tmp;
		nzmsg[nzsize].mulast	= last;
		nzmsg[nzsize].mulastid	= lastid;
		nzmsg[nzsize].muloc	= zapcur;
		++nzsize;
		return 1;
	    }
	    fprintf(stderr, "(loopzapper) out of memory\n");
	    checkloops = 0;
	}
	else
	    return 0;
    return 1;
}

/*
 * doMessages() -- loops thru msg file until finished.
 */
void
doMessages(void)
{
    long msg, first;
    int total = 0;	     /* For stat keeping. */
    PATHBUF msgFile;
    struct tm *cur;

    if (zap) {
	free(zap);
	zap = (struct zaphash *)malloc(sizeof *zap);
    }
    cfg.zap_count = 0;
    init_zap();
    today = time(NULL) + (24 * 60 * 60);	/* add an extra day */

    ctdlfile(msgFile, cfg.msgdir, "ctdlmsg.sys");
    if ((msgfl = dopen(msgFile, O_RDWR)) < 0)
	crashout("no %s", msgFile);

    msgseek(0, 0);
    getmessage();
    printf("Msg #%ld (srcid %ld) %s%s%s (%s) %s %s\n", msgBuf.mbid,
	msgBuf.mbsrcid, msgBuf.mbauth, msgBuf.mboname[0] ? "@" : "", 
	msgBuf.mboname, msgBuf.mbroom, msgBuf.mbdate, msgBuf.mbtime);
    first = msgBuf.mbid;
    if (roomAt(msgBuf.mbroom) > AIDEROOM)
	notseen();
    
    total = 1;
    do {
	total++;
	getmessage();
	printf("Msg #%ld (srcid %ld) %s%s%s (%s) %s %s\n", msgBuf.mbid,
	    msgBuf.mbsrcid, msgBuf.mbauth, msgBuf.mboname[0] ? "@" : "", 
	    msgBuf.mboname, msgBuf.mbroom, msgBuf.mbdate, msgBuf.mbtime);
	msg = msgBuf.mbid;
	if (roomAt(msgBuf.mbroom) > AIDEROOM)
	    notseen();
    } while (msg != first);
    printf("%d messages seen\n", total);

    close_zap();

    printf("%d systems in zaptable\n", cfg.zap_count);
}

main()
{
    printf("%s for Fnordadel V%s\n", program, VERSION);
    if (readSysTab(YES)) {
	doMessages();
	printf("wrote %d bytes to ctdltabl.sys\n", writeSysTab());
    }
    if (fromdesk())
	hitkey();
}

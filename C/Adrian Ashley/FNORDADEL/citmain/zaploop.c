/*
 * zaploop.c - shut down message looping via brute-force
 *
 * 91Jan03 AA	Now uses date AND msgid as criteria; also stores gen & nodename
 * 90Nov25 AA	Hacked a bit for gcc
 * 88Jun17 orc	created.
 */

#include "ctdl.h"
#include "zaploop.h"
#include "room.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

static struct zaploop zapnode;
static int zapdbx;
static short zapcur = ERROR;
static struct mupdate {
    time_t mulast;		/* newest message found here... (date) */
    long mulastid;		/* highest message id found here */
    short muloc;		/* bucket for this message	*/
} *nzmsg;
static int nzsize;

char checkloops = 0;

#if 0
static time_t
msgtime(void)
{
    struct tm msgt;
    int year = 0, mon, mday = 0, hour, min;
    char apm;
    int count;
    char *p;

    zero_struct(msgt);

    p = msgBuf.mbdate;
    if (*p) {
	while (isdigit(*p)) {
	    year = (year * 10) + (*p - '0');
	    p++;
	}
	mon = 1;
	while (strnicmp(p, monthTab[mon], 3) && ++mon <= 12)
	    ;
	if (mon > 12)
	    return ERROR;
	while (!isdigit(*p))
	    p++;
	while (isdigit(*p)) {
	    mday = (mday * 10) + (*p - '0');
	    p++;
	}
    }
    count = sscanf(msgBuf.mbtime, "%d:%d %cm", &hour, &min, &apm);
    if (count < 2)
	return ERROR;
    if (hour == 12)
	hour = 0;
    if (count == 3) {
	if (apm == 'p')
	    hour += 12;
	else if (apm != 'a')
	    return ERROR;
    }
    msgt.tm_year = year;
    msgt.tm_mon  = mon - 1;
    msgt.tm_mday = mday;
    msgt.tm_hour = hour;
    msgt.tm_min  = min;
    return mktime(&msgt);
}
#endif

/*
 * init_zap() - open the zaploop database
 */
void
init_zap(void)
{
    PATHBUF zapfile;

    ctdlfile(zapfile, cfg.netdir, "ctdlloop.zap");

    if ((zapdbx = dopen(zapfile,O_RDWR)) < 0) {
	splitF(netLog, "cannot open %s\n", zapfile);
	checkloops=0;
    }
    nzmsg = (struct mupdate *)malloc(sizeof *nzmsg);
    nzsize = 0;
    if (!nzmsg) {
	splitF(netLog, "(zl) Out of memory\n");
	dclose(zapdbx);
	checkloops=0;
    }
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
	splitF(netLog, "Created new zap entry for %s (%s)\n",
			msgBuf.mboname, roomTab[thisRoom].rtname);
	return 1;
    }
    splitF(netLog, "(loadx) Out of memory.\n");
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
 */
int
notseen(void)
{
    time_t last = msgtime(msgBuf.mbdate, msgBuf.mbtime);
    long lastid = msgBuf.mbsrcid;
    LABEL chk;
    int i;
    struct mupdate *tmp;

    if (checkloops && normID(msgBuf.mborig,chk) && loadx(chk, msgBuf.mboname)){
	if ((last != ERROR && last > zapnode.lxlast)
	     || lastid > zapnode.lxlastid) {
	    if (netDebug && (last <= zapnode.lxlast ||
		    (lastid && lastid <= zapnode.lxlastid))) {
		splitF(netLog, "Message from %s (%s):\n    <%s in %s, %s@%s>\n",
		    msgBuf.mboname, msgBuf.mborig, msgBuf.mbauth,
		    msgBuf.mbroom, msgBuf.mbdate, msgBuf.mbtime);
		if (last <= zapnode.lxlast)
		    splitF(netLog, "    fails date check: msg date %ld, zap date %ld\n",
			last, zapnode.lxlast);
		else if (zapnode.lxlastid && lastid <= zapnode.lxlastid)
		    splitF(netLog, "    fails id check: msg id %ld, zap id %ld\n",
			lastid, zapnode.lxlastid);
	    }
	    for (i = 0; i < nzsize; i++)
		if (nzmsg[i].muloc == zapcur)  {
#if 0
		    if (last > nzmsg[i].mulast)
			nzmsg[i].mulast = last;
		    if (lastid > nzmsg[i].mulastid)
			nzmsg[i].mulastid = lastid;
#else
		    nzmsg[i].mulast = last;
		    if (lastid)
			nzmsg[i].mulastid = lastid;
#endif
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
	    splitF(netLog, "(loopzapper) out of memory\n");
	    checkloops = 0;
	}
	else {		/* zap the message */
	    if (netDebug)
		splitF(netLog,
"zap: %s (%s), msglast = %lu zaplast = %lu msglastid = %ld zaplastid = %ld\n",
		    zapnode.lxaddr, roomTab[zapnode.lxroom].rtname, last,
		    zapnode.lxlast, lastid, zapnode.lxlastid);
	    return 0;
	}
    }
    return 1;
}

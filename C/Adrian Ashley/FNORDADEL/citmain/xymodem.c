/* #define XMDEBUG 1 */

/*
 * xymodem.c - WC and other protocol drivers for file and message xfers
 *
 * protocols supported or "about to be" supported:
 *
 *	Xmodem, Ymodem, WXmodem, Vanilla
 *	Zmodem, Kermit, Capture, Archive
 *
 * 90Nov08 AA	Added orc's hold message stuff to sendC*() functions
 * 88Nov20 orc	WXmodem commented out
 * 88Sep06 orc	WXmodem fixed to understand carrier-loss.
 * 88Jul08 orc	Ymodem batch upload hooks added in.
 * 88Jul01 orc	Capture `protocol' added in.
 * 88May29 orc	WXmodem added in (cross fingers...)
 * 88Feb11 orc	Support file download limits.
 * 88Feb01 orc	Try allowing Xmodem CRC during networking
 * 88Jan03 orc	Have Vanilla transfers check for carrier
 * 87Oct31 orc	After enterfile() abort, eat characters from modem
 * 87Sep08 orc	Use table-driven CRC calculation.
 * 87Aug11 orc	Ymodem batch added in.
 * 87Aug08 orc	Ymodem added in (cross fingers...)
 * 87Jul28 orc	Vanilla ascii protocol added in
 * 87Jul27 orc	Hacked up from old XYmodem.c
 */

#include "ctdl.h"
#include "dirlist.h"
#include "calllog.h"
#include "log.h"
#include "room.h"
#include "config.h"
#include "protocol.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * beginWC()		initializes protocol transfers
 * endWC()		shuts down after a protocol transfer
 * enterfile()		accept a file using some protocol
 * * rec?file()		receive a file via some protocol
 * * send?init()	set up for sending a file
 * * send?char()	send a character via some protocol
 * * send?end()		finish up sending via some protocol
 * * outWCpacket()	Send a WC packet to modem
 * * sWCpacket()	Send  & verify a WC packet
 * * gWCpacket()	Get a WC packet
 * * flingYpacket()	Send a Ymodem packet
 * calcrc()		Calculate the CRC for a packet
 * calck()		Calculate the checksum for a packet
 */

static char current;
static int  blocknum;
static int  CRCmode;
static int  xmp;
static char lasterror;
static char packet[YMSECTSIZE];
static int  dirty;	/* dirty line?  (more than 10 errors total?) */
static int  rYbatch;	/* receiving Ymodem batch? */
static long rYsize;	/* size of incoming file for ymodem batch */
LABEL  rYfile;		/* file coming in from remote */
static FILE *spl;	/* Used by sendCchar, sendCinit, sendCend */

#ifdef WXWORKING
#define WXWSIZE	4	/* wxmodem -- 4 packet window */
#define WXMASK	03	/* wxmodem -- wx packet ack -- 2 bits */

static int window;	/* # wxmodem packets outstanding */
static struct windex {	/* packet descriptors for wxmodem packets */
    int  pn;		/* the packet we've got waiting for us */
    char *p;		/* where it's hiding */
} queued[WXWSIZE];
#endif

char WCError;		/* needed by other modules... */
char batchWC;		/* is this gonna be a batch transfer? */

#define MAX_RETRY	10
#define CRC_START	'C'
#define WX_START	'W'

int (*sendPFchar)(int);
short calcrc(char *, short);
short calck(char *, short);

/*
 * can_can() - dump a pair of cancels out the modem
 */
static void
can_can(void)
{
    if (gotcarrier()) {
	modout(CAN);
	modout(CAN);
    }
}

#ifdef WXWORKING
/*
 * outWX() - throw a WX character out the modem
 */
static void
outWX(register char c)
{
    if (c == DLE || c == SYN || c == XON || c == XOFF) {
	modout(DLE);
	c ^= 64;
    }
    modout(c);
}

/*
 * sWXpack() - fling a wxmodem packet
 */
static int
sWXpack(int idx)
{
    int i;
    short crc;
    register char *p = queued[idx].p;

    modout(SYN); modout(SYN);
    modout(SOH);
    outWX(queued[idx].pn);
    outWX(~queued[idx].pn);
    crc = calcrc(p, SECTSIZE);
    for (i=0; i<SECTSIZE; i++, p++)
	outWX(*p);
    outWX(crc>>8);
    outWX(crc);
#ifdef WXDEBUG
    xprintf("\r>%5d:%dw", blocknum, idx);
    for (i=0; i<window; i++)
	xprintf("/%02x", 0xff & queued[i].pn);
    xprintf("\n");
#else
    xprintf("\r>%5dw\r", queued[idx].pn);
#endif
}

/*
 * waitforack() - of a wxmodem packet.
 */
static void
waitforack(int delay)
{
    struct windex scroll;
    register c, j, i;
    int newwin;

    while (window > 0 && (c=receive(delay)) != ERROR)
	switch (c) {
	case ACK:
	    if ((c=receive(5)) != ERROR) {
		c &= WXMASK;
#ifdef WXDEBUG
		xprintf("\rACK %d ", c);
#endif
		for (i=0; i<window; i++)
		    if ( (char)(queued[i].pn & WXMASK) == (char)c) {
			for (newwin=j=0; ++i < WXWSIZE; j++) {
			    copy_struct(queued[j],    scroll);
			    copy_struct(queued[i], queued[j]);
			    copy_struct(scroll,    queued[i]);
			    if (i < window)
				newwin++;
			}
			window=newwin;
			break;
		    }
#ifdef WXDEBUG
		for (i=0; i<window; i++)
		    xprintf("/%02x", 0xff & queued[i].pn);
		xprintf("/window=%d\n", window);
#endif
	    }
	    break;
	case NAK:
	    if ((c=receive(5)) != ERROR) {
		c &= WXMASK;
#ifdef WXDEBUG
		xprintf("\rNAK %d (window=%d)\n", c, window);
#endif
		for (i=0; i<window; i++)
		    if ((char)(queued[i].pn & WXMASK) == (char)c) {
			for (j=0; j<=i && gotcarrier(); j++)
			    sWXpack(j);
			break;
		    }
	    }
	    break;
	case CAN:
	    if (receive(5) == CAN) {
		can_can();
		WCError++;
		return;
	    }
	}
}
#endif

/*
 * capture protocol stuff
 */
int
sendCchar(int c)
{
    putc(c, spl);
    return 1;
}

int
sendCinit(void)
{
    extern char heldMessage;
    FILE *safeopen();
    int sendCchar();
    extern char holdtemplate[];
    extern int logindex;
    PATHBUF hold;

    ctdlfile(hold, cfg.holddir, holdtemplate, logindex);
    if (spl = safeopen(hold, "ab")) {
	sendPFchar = sendCchar;
	if (!heldMessage) {
	   /*
	    * dummy up a message header
	    */
	   putc(0xff,spl);
	   putc(0,   spl);
	   putc('M', spl);
	   heldMessage = YES;
	}
	return 1;
    }
    return 0;
}

int
sendCend(void)
{
    fclose(spl);
    return 1;
}

/*
 * outWCpacket() - dump a WC packet to modem.
 */
static void
outWCpacket(short pknum, register char *pk, register short pksize)
{
    short cksum;
    /*char lc=1;*/

    cksum = CRCmode?calcrc(pk, pksize):calck(pk, pksize);
    modout((pksize==YMSECTSIZE)?STX:SOH);
    modout(pknum);
    modout(~pknum);
    /*xprintf("{");*/
    while (pksize-- > 0) {
	/*
	 *  if (isprint(*pk))
	 *      xputc(*pk);
	 *  else if (*pk)
	 *      xprintf(" %d", 0xff & *pk);
	 *  else if (lc != *pk)
	 *      xputc(249);
	 *  lc = *pk;
	 */
	modout(*pk++);
    }
    /*xputs("}");*/
    if (CRCmode)
	modout(cksum>>8);
    modout(cksum);
}

/*
 * sWCpacket - send & verify a WC packet
 */
static int
sWCpacket(char pknum, char *pk, short pksize)
{
    register int reply, retry;

    for (retry=0; gotcarrier() && retry<MAX_RETRY; ++retry) {
	xprintf("\r>%5d%c\r", blocknum, (pksize==YMSECTSIZE)?'y':'x');
	outWCpacket(pknum, pk, pksize);
	while ((reply=receive(15)) != ERROR && reply != ACK && reply != NAK)
	    if (reply == CAN && receive(5) == CAN)	/* ^X^X cancels */
		goto sWCerr;
	if (reply == ACK) {
	    current++;
	    blocknum++;
	    /*
	     * adjust the dirtiness factor of the line.
	     */
	    if (pksize == SECTSIZE) {	/* xmodem sectors */
		if (retry)
		    dirty += 2;
		else if (dirty)
		    --dirty;
	    }
	    else if (retry > 3)		/* 1k sectors */
		dirty = 32;
	    return YES;
	}
    }
sWCerr:
    can_can();
    WCError++;
    return NO;
}

static int
sendXchar(int c)		/* send Xmodem char */
{
    packet[xmp++] = (char)c;
    if (xmp == SECTSIZE) {		/* packet full -- send it... */
	xmp = 0;
	return sWCpacket(current, packet, SECTSIZE);
    }
    return YES;
}

/*
 * flingYpacket - send a Ymodem packet.
 */
static int
flingYpacket(register int size)
{
    register char *pp;

    while (size%SECTSIZE != 0)
	packet[size++] = 0;

    if (dirty || size < YMSECTSIZE) {
	for (pp = packet; size > 0; pp += SECTSIZE, size -= SECTSIZE)
	    if (!sWCpacket(current, pp, SECTSIZE))
		return NO;
	return YES;
    }
    return sWCpacket(current, packet, YMSECTSIZE);
}

static int
sendYchar(int c)		/* send Ymodem char */
{
    packet[xmp++] = (char) c;
    if (xmp == YMSECTSIZE) {		/* packet full -- send it... */
	xmp = 0;
	return flingYpacket(YMSECTSIZE);
    }
    return YES;
}


#ifdef WXWORKING
static int
sendWXchar(int c)
{
    register retry;

    queued[window].p[xmp++] = c;
    if (xmp == SECTSIZE) {
	queued[window].pn = blocknum;
	sWXpack(window);
	window++;
	current++;
	blocknum++;
	xmp = 0;
	waitforack(0);
	for (retry=0; window >= WXWSIZE && retry < 5 && gotcarrier(); retry++) {
	    waitforack(10);
	    if (window >= WXWSIZE)
		sWXpack(WXWSIZE-1);
	}
	if (retry >= 5 || !gotcarrier()) {
	    WCError++;
	    can_can();
	    return NO;
	}
    }
    return YES;
}
#endif

static int
sendVchar(int c)		/* send Vanilla character */
{
    modout((c==CAN)?'@':c);
    return gotcarrier();
}

/*
 * send?init() - prepare the universe for sending a file via some protocol.
 */

static int
sendXinit(void)		/* send Xmodem init */
{
    register int c, count;

    sendPFchar = sendXchar;	
    WCError = CRCmode = NO;
    blocknum = current = 1;
    xmp = dirty = 0;

    for (count=10; gotcarrier() && count>0; ) {
	if ((c=receive(10)) == ERROR)
	    --count;
	else if (c == CRC_START || c == NAK) {
	    CRCmode = (c == CRC_START);
	    if (!(CRCmode || inNet))
		xprintf("checksum\n");
	    return YES;
	}
	else if (c == CAN && receive(1) == CAN)
	    break;
    }
    WCError++;
    return NO;
}

#ifdef WXWORKING
static char downshift;

static int
sendWXinit(void)
{
    int sendWXchar();
    register i,c;

    sendPFchar = sendWXchar;	
    window = xmp = 0;
    blocknum = current = 1;
    downshift = NO;

    for (i=0; i<WXWSIZE; i++)
	queued[i].p = &packet[SECTSIZE*i];

    for (i=0;i<3;i++) {
	if ((c=receive(10)) == WX_START)
	    return YES;
    }
    if (gotcarrier()) {
	downshift = YES;
	return sendXinit();
    }
    else return NO;
}
#endif

int
sendARinit(void)
{
    static char journal[80] = "";
    char temp[120], file[80];

    sprintf(temp, "file to journal to (");
    if (strlen(journal) > 0)
	sprintf(ENDOFSTR(temp), "C/R = `%s', ", journal);
    strcat(temp, "ESC aborts)");

    usingWCprotocol = ASCII;
    getString(temp, file, 80, ESC, YES);

    if (file[0] != ESC && (strlen(file) || strlen(journal)) ) {
	if (strlen(file) == 0)
	    strcpy(file, journal);
	else
	    strcpy(journal, file);
	return ARsetup(file);
    }
    return 0;
}

/*
 * send?end() - Terminate the download
 */
static int
sendXend(void)		/* send Xmodem end */
{
    register int retry;

    if (gotcarrier() && !WCError) {
	while (xmp != 0 && sendXchar(0))
	    ;
	for (retry=0; gotcarrier() && retry<MAX_RETRY; retry++) {
	    modout(EOT);
	    if (receive(5) == ACK)
		return YES;
	}
    }
    return NO;
}

static int
sendYend(void)		/* send Ymodem end */
{
    register int retry;

    if (!WCError && flingYpacket(xmp))
	for (retry=0; gotcarrier() && retry<MAX_RETRY; retry++) {
	    modout(EOT);
	    if (receive(5) == ACK)
		return YES;
	}
    return NO;
}

#ifdef WXWORKING
static int
sendWXend(void)
{
    register retry;

    if (downshift)
	return sendXend();
    if (WCError)
	return NO;
    while (xmp)
	sendWXchar(0);
    for (retry=0; window && retry<5 && gotcarrier(); retry++) {
	waitforack(10);
	if (window)
	    sWXpack(window-1);
    }
    if (retry < 5 && gotcarrier()) {
	for (retry=0; retry<10; retry++) {
	    modout(EOT);
	    if (receive(5) == ACK)
		break;
	}
    }
    else {
	can_can();
	WCError++;
    }
    return !WCError;
}
#endif

/*
 * sendYhdr() - send batch header block.
 * If the filename is null, shutdown the batch transfer.
 */
int
sendYhdr(char *name, long size)
{
    char *p;

    if (sendXinit()) {	/* set up to send block 0 */
	blocknum = current = 0;
	if (name) {
	    for (p=name; *p; p++)		/* send the filename in     */
		sendXchar(tolower(*p));		/* lowercase to make ymodem */
	    sendXchar(0);			/* implementors happy       */
	    wcprintf("%ld",size);		/* then flip the size out   */
	}
	else
	    sendXchar(0);
	while (xmp > 0 && !WCError)
	    sendXchar(0);
    }
    return !WCError;
}

/*
 * parseYheader() - got a ymodem header block, so cut it up
 */
#define	YOK	0			/* Header checked out */
#define YDUP	1			/* got two headers */
#define	YNULL	2			/* got null header */
#define	YOOPS	3			/* file open error */

static int
parseYheader(void)
{
    register char *p;
    char *strrchr();

    if (rYbatch)
	return YDUP;
    else if (packet[0]) {
	rYbatch = YES;			/* reset start-o-file flgs*/
	p = 1 + ENDOFSTR(packet);	/* skip over the filename */
	if (*p)				/* and grab the filesize  */
	    sscanf(p, "%ld", &rYsize);
	copystring(rYfile, (p = strrchr(packet,'/')) ? p : packet, NAMESIZE);
	splitF(netLog, "Receiving `%s' (%s)\n",rYfile, plural("byte",rYsize));
	if (batchWC && (upfd = safeopen(rYfile, "wb")) == NULL)
	    return YOOPS;
	return YOK;
    }
    return YNULL;
}

/*
 * gWCpacket -- get a WC packet
 */
static int
gWCpacket(char *packet, char *sector, int size)
{
    register char *p;
    register int c, count;
    char pn, cpn;
    short crc;
#ifdef XMDEBUG
    char lc=0;
#endif

    /*
     * here comes a packet of one flavour or another...
     */
#ifdef XMDEBUG
    xprintf("\r<%c%4d%c\n", lasterror, blocknum, (size!=SECTSIZE)?'y':'x');
#else
    xprintf("\r<%c%4d%c\r", lasterror, blocknum, (size!=SECTSIZE)?'y':'x');
#endif

    lasterror='-';

    pn = receive(2);
    cpn= receive(2);

#ifdef XMDEBUG
    xprintf("[");
#endif
    for (p=packet,count=0; count < size; count++)
	if ( (c=receive(2)) == ERROR) {
#ifdef XMDEBUG
	    xputs("<TIMEOUT>]");
#endif
	    return 0;
	}
	else {
	    *p++ = c;
#ifdef XMDEBUG
	    if (isprint(c))
		xputc(c);
	    else if (c)
		xprintf(" %02x", 0xff & c);
	    else if (lc != c)
		xputc(249);
	    lc = c;
#endif
	}
#ifdef XMDEBUG
    xputs("]");
#endif

    lasterror = 'c';
    if (CRCmode) {
	crc  = receive(2) << 8;
	crc |= receive(2) & 0xFF;
	if (crc != calcrc(packet, size))
	    return 0;
    }
    else if (receive(2) != calck(packet, size))
	return 0;
    /*
     * make sure that the packet numbers match..
     */
    if (cpn == ~pn) {
	lasterror = ' ';
	*sector = pn;
	return 1;
    }
    lasterror = '?';
    return 0;
}

/*
 * rec?file() - accept a file from the modem via some protocol.
 *
 * returns 0 if everything worked, -1 if a batch error happened or a null
 * headerblock came in,	and 1 if something blew up
 */
int
recXfile(int (*pc)(int))		/* receive X/Ymodem packet */
{
    register int retry, count, size;
    register char *p;
    char pn;
    int c;
    char lastSector;
    char startingup;

#ifdef XMDEBUG
/*    xprintf("recXfile(): batchWC %d  usingWCprotocol %d\n", batchWC,
	usingWCprotocol); */
#endif
    rYbatch = NO;
    rYsize  = -1L;
xgo:
    lastSector = 0;
    startingup = YES;
    lasterror = ' ';
    blocknum = current = 1;	/* Start on block #1 */
    retry = 0;

    while (gotcarrier() && retry < MAX_RETRY) {
#ifdef XMDEBUG
	xprintf("recXfile(): top of loop: retry %d startingup %d blocknum %d\n",
		retry, startingup, blocknum);
#endif
	/*
	 * start off by acking the last packet or by requesting a
	 * transfer mode.
	 */
	if (startingup) {
	    CRCmode = (retry<5);
	    modout(CRCmode ? CRC_START : NAK);
#ifdef XMDEBUG
	    xputs(CRCmode ? "CRC?" : "chksum?");
#endif
	}
	else {
	    modout(retry ? NAK : ACK);
#ifdef XMDEBUG
	    xputs(retry ? "NAK" : "ACK");
#endif
	}
	c = receive(5);
	if (c == SOH || c == STX) {
#ifdef XMDEBUG
	    xputs(c == SOH ? "got SOH" : "got STX");
#endif
	    startingup = NO;
	    size = (c==SOH) ? SECTSIZE : YMSECTSIZE;
	    if (gWCpacket(packet, &pn, size)) {
#ifdef XMDEBUG
		xprintf("got WCpacket pn %d (expecting blocknum %d)\n", pn,
			blocknum);
#endif
		if (blocknum == 1) {
		    if (pn == 0) {
			if ((c = parseYheader()) == YOK) {
			    modout(ACK);
			    goto xgo;
			}
			else if (c == YNULL) {
			    modout(ACK);
			    return -1;
			}
			else
			    break;
		    }
		    else if (batchWC && !rYbatch)
			break;
		}
		if (pn == current) {
		    current++;
		    lastSector++;
		    blocknum++;
#ifdef XMDEBUG
		    xprintf("got proper packet, size %d\n", size);
#endif
		    for (p=packet,count=0; count < size; count++) {
			if (rYsize == 0)
			    break;
#if 0
			if ( !((*pc)(*p++)) ) {	/* changed from `...==ERROR' */
#ifdef XMDEBUG
			    xputs("(*pc) puked");
#endif
			    goto xcan;		/* by AA 90Sep04 */
			}
#else
			if ((*pc)(*p++) == ERROR) {
#ifdef XMDEBUG
			    xputs("(*pc) puked");
#endif
			    goto xcan;
			}
#endif
			if (rYsize > 0)
			    rYsize--;
		    }
#ifdef XMDEBUG
		    xputs("packet properly put");
#endif
		    retry=0;
		    continue;
		}
		else if (pn == lastSector) {
		    retry=0;
		    break;
		}
	    }
	}
	else if (c == EOT) {
#ifdef XMDEBUG
	    xputs("[EOT]{ACK}");
#endif
	    modout(ACK);
	    if (batchWC)		/* batch receive, close 'er down */
		fclose(upfd);
	    else if (rYbatch)		/* got batch during single */
		can_can();		/* so shut down the other end */
	    return 0;
	}
	else if (c == CAN) {
	    if ((c=receive(5)) == CAN || c == ERROR) {
#ifdef XMDEBUG
		xputs("[CAN]");
#endif
		goto xout;
	    }
	}
	while (receive(1) != ERROR)	/* garbage -- synchronise */
	    ;
	retry++;
    }
xcan:
#ifdef XMDEBUG
    xputs("[CAN-retry]");
#endif
    can_can();
xout:
    if (batchWC && rYbatch) {
	fclose(upfd);
	dunlink(rYfile);
    }
    return 1;
}

#ifdef WXWORKING
static int
getWXchar(void)
{
    int c;
    clock_t x;

    while ((c=receive(10)) != ERROR) {
	if (c == DLE) {
	    if ((c = receive(10)) == ERROR)
		break;
	    c ^= 64;
	}
	else if (c == SYN)
	    break;
	else if (c == XOFF) {
	    x = clock();
	    while (timeSince(x) < 10)
		if (receive(1) == XON)
		    break;
	    continue;
	}
	else if (c == XON)
	    continue;
	return 0xff & c;
    }
    return ERROR;
}

static int
recWXcore(register short c, int (*pc)(int))
{
    int retry;
    register int i;
    char pn, cpn;
    short crc;

    for (current=blocknum=1, retry=0; c != EOT && retry++ < MAX_RETRY;) {
	xprintf("\r<%5dw\r", blocknum);
	while (c == SYN)
	    c = receive(10);

	if (c != SOH)
	    goto wxerror;
	
	if ((i=getWXchar()) == ERROR)
	    goto wxerror;
	pn = i;

	if ((i=getWXchar()) == ERROR)
	    goto wxerror;
	cpn = i;

	if (pn = ~cpn)	/* !!!!!!!!!! */
	    goto wxerror;
	for (i=0; i<SECTSIZE; i++)
	    if ((c=getWXchar()) == ERROR)
		goto wxerror;
	    else
		packet[i] = c;
	if ((crc=getWXchar()) == ERROR)
	    goto wxerror;
	if ((c=getWXchar()) == ERROR)
	    goto wxerror;
	crc <<= 8;
	crc |= c;
	if (crc == calcrc(packet, SECTSIZE) && pn == current) {
	    for (i=0; i<SECTSIZE; i++)
		if ((*pc)(packet[i]) == ERROR)
		    goto wxdie;
	    current++;
	    blocknum++;
	    retry = 0;
	}
	/*
	 * any other sector?  Tch -- try to resynch at the sector we want.
	 */
    wxerror:
	if (!gotcarrier())
	    return 1;
	modout(retry ? NAK : ACK);
	modout(current & WXMASK);
	while ((c=receive(10)) != ERROR && c != EOT && c != SYN && c != SOH)
	    ;
    }
    if (c == EOT) {
	modout(ACK);
	return 0;
    }
wxdie:
    can_can();
    return 1;
}

static int
recWXfile(int (*pc)(int))
{
    int i, c;

    for (i=0; i<3; i++) {
	modout(WX_START);
	if ((c=receive(10)) == SOH || c == SYN)
	    return recWXcore(c, pc);
    }
    return recXfile(pc);
}
#endif

static int
recVfile(int (*pc)(int))		/* receive Vanilla file */
{
    register int c;

    while ((c = receive(10)) != ERROR) {
	if (c == CAN) {
	    if ((c = receive(2)) == CAN)
		return NO;
	    else {
		(*pc)(CAN);
		(*pc)(c);
	    }
	}
	else
	    (*pc)(c);
    }
    return YES;
}

/*
 * calcrc() - calculate crc for a packet
 */
static short crctb[256] = {	/* sacrifice memory for speed */
	0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
	0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
	0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
	0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
	0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
	0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
	0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
	0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
	0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
	0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
	0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
	0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
	0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
	0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
	0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
	0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
	0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
	0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
	0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
	0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
	0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
	0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
	0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
	0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
	0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
	0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
	0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
	0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
	0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
	0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
	0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
	0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
} ;

static short
calcrc(register char *p, register short count)
{
    register short c, crc;

    for (crc=0; count > 0; --count) {
	c = 0xff & (*p++);	/* grab the character, kill sign extend */
	crc = crctb[(0xff & (crc>>8)) ^ c] ^ ((0xff & crc) << 8);
    }
    return crc;
}

/*
 * calck() - calculate checksum for a packet
 */
static short
calck(register char *p, register short size)
{
    register unsigned short cks;

    for (cks=0; size>0; --size)
	cks = (cks + *p++) & 0xFF;
    return cks;
}

/*
 * beginWC() - set up the system for a WC download
 */
int
beginWC(void)
{
    switch (usingWCprotocol) {
    case VANILLA: sendPFchar = sendVchar;	return YES;
#ifdef WXWORKING
    case WXMODEM: return sendWXinit();
#endif
    case YMODEM:
	    if (sendXinit()) {
		sendPFchar = sendYchar;
		return 1;
	    }
	    else return 0;
    case CAPTURE: return sendCinit();
    case TODISK:  return sendARinit();
    default:      return sendXinit();
    }
}

/*
 * endWC() - fix up the system after a WC download
 */
int
endWC(void)
{
    switch (usingWCprotocol) {
    case VANILLA: can_can(); return 1;
#ifdef WXWORKING
    case WXMODEM: return sendWXend();
#endif
    case YMODEM:  return sendYend();
    case CAPTURE: return sendCend();
    case TODISK:  return sendARend();
    default:      return sendXend();
    }
}

/*
 * enterfile() - accepts a file from the modem using some protocol
 */
int
enterfile(int (*pc)(int), char mode)
{
    batchWC = NO;
    switch (mode) {
    case VANILLA: WCError = recVfile(pc);  break;
#ifdef WXWORKING
    case WXMODEM: WCError = recWXfile(pc); break;
#endif
    default:      WCError = recXfile(pc);  break;
    }
    if (WCError)
	while (receive(1) != ERROR)
	    ;
    return !WCError;
}

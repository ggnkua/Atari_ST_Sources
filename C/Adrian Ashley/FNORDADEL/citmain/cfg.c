/*
 * cfg.c - configuration program for Citadel bulletin board system
 *
 * 90Nov21 AA	Message scanning routines redone to use lib functions (mostly)
 * 90Oct31 AA	Added support for #roomdir and #define showrecd
 * 90Jul21 AA	Entire program completely reworked, at long last
 * 88Jul03 orc	Utility functions put into cfgmisc.c
 * 87Sep07 orc	Ripped out of old CONFG.C, CONFG1.C
 */

#include "ctdl.h"
#include "net.h"
#include "log.h"
#include "msg.h"
#include "room.h"
#include "floor.h"
#include "config.h"
#include "event.h"
#include "calllog.h"
#include "zaploop.h"
#include "archiver.h"
#include "citlib.h"
#include "configur.h"	/* cfg-wide declarations */

char *program = "configur";

int gotTabl = NO;	/* Did we read ctdltabl.sys at the start? */
int attended = YES;	/* Is someone there to answer questions? */
int scanfiles = YES;	/* Shall we scan the datafiles or just ctdlcnfg.sys? */
int tozap[4] = { NO, NO, NO, NO }; /* Array telling us what to reinitialise */
int roomsmissing = NONE; /* Like tozap[], but need to know more about rooms. */
int failed = 0;		/* Did any initialisations fail? */
int do_checkpoint = NO;	/* shall we speed up the msg scan at our peril? */

int logfl;

char baseroom[80] = "Lobby";
char lobbyfloor[80] = "";
long mailcount = 0L;
char msgline[200];
int lineno = 0;		/* line in ctdlcnfg.sys we're looking at right now.. */
int offset = 1;
char *nextcode;
int arg;
int dotimeout = 0;
int hourout = -1;
struct evt_type timeEvent = { 0, 0x7f, EVENT_TIMEOUT, 0, "timeout", 480, 1 };

static int zapcur = ERROR;
static struct zaploop zapnode;
static int zapfl;

int depend[DEPENDSIZE];
int derr = NO;		/* error flag for configur dependency checker	*/

int
main(int argc, char **argv)
{
    char *crashmsg = "can't do %s because there's no ctdltabl.sys";
    char *p, *ap, *strchr();
    int i, lock;
    extern char VERSION[];

    setbuf(stdout, NULL);
    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (!(gotTabl = readSysTab(YES)))
	setupdefaults();

    parsecnfg();	/* read ctdlcnfg.sys, inserting into struct cfg */

    if (!makelock(&lock))
	exit(1);

    if (argc < 2)	/* No arguments at all */
	attended = scanfiles = YES;
    else {		/* Parse the arguments */
	for (i=1; i<argc; i++) {
	    if (*(ap = argv[i]) == '+') {
		scanfiles = NO;		/* assume that if we use at least one
					   '+' arg, we don't want to scan */
		if (gotTabl) {
		    if (*++ap) {	/* anything past the '+'? */
			if (p = strchr(ap, '=')) {
			    *p++ = 0;
			    arg = atoi(p);
			}
			else if (strncmp(ap, "no", 2) == 0) {
			    arg = 0;
			    ap += 2;
			}
			else
			    arg = 1;
			setvariable(ap, arg);
		    }
		}
		else if (attended)		/* No tabl.sys, can't do it! */
		    crashout(crashmsg, argv[i]);
		else
		    printf(crashmsg, argv[i]);
	    }
	    else if (stricmp(ap, "-c") == 0)
		do_checkpoint = YES;
	    else
		attended = NO;	/* must be 'configur <dummyarg>' */
	}
    }

    checkdepend(depend);	/* Check dependencies, printing error msgs */
    if (derr)
	crashout("Cannot continue.  Fix error(s) and try again.");
    openfiles();	/* sets tozap[]/roomsmissing values if files missing */

    /* By the time we reach here, tozap[] values will be YES iff the file(s)
	were missing; roomsmissing will be set. */

    if (attended)
	querysysop();	/* Ask all the niggly questions about what to reinit */

    if (scanfiles) {
	if (!tozap[MSGS])		msgscan();
	if (roomsmissing == NONE) 	roomscan();
	if (!tozap[LOG])		logscan();
	if (!tozap[FLOOR])		floorscan();
	if (!tozap[NET])		netscan(NO);
	zapscan();
    }

    /* ___init() functions return YES if they've successfully inited */
    if (tozap[MSGS])	if (!msginit())			failed++;
    if (roomsmissing)	if (!roominit(roomsmissing))	failed++;
    if (tozap[LOG])	if (!loginit())			failed++;
    if (tozap[FLOOR])	if (!floorinit())		failed++;
    if (tozap[NET])	if (!netscan(YES))		failed++;

    if (failed)		/* Just to be on the safe side */
	crashout("Unable to initialise all files");

    if (dotimeout) {	/* Hate to put this here, but where else can it go? */
	timeEvent.evtRel = hourout*60;
	addevent(&timeEvent);
    }

    if (mailcount)
	printf("%ld mail message%s.\n", mailcount, (mailcount > 1) ? "s" : "");
    printf("Wrote %d bytes to ctdltabl.sys.\n", writeSysTab());
    cleanup();
    wipelock(&lock);
    exit(0);
}

void
setupdefaults(void)		/* Sets up a reasonable default struct cfg */
{
    int i;

    zero_struct(cfg);

    /* shave-and-a-haircut/two bits pause pattern for ringing sysop: */
    cfg.shave[0] = 40;
    cfg.shave[1] = 20;
    cfg.shave[2] = 20;
    cfg.shave[3] = 40;
    cfg.shave[4] = 80;
    cfg.shave[5] = 40;
    cfg.shave[6] =250;	/* which will sign-extend to infinity... */

    /* initialize input character-translation table:	*/
    for (i = 0; i < 32; i++)
	cfg.filter[i] = 0;
    for (i = 32; i < 128; i++)
	cfg.filter[i] = i;

    cfg.filter[SPECIAL]= SPECIAL;
    cfg.filter[CNTRLl] = CNTRLl;
    cfg.filter[DEL]    = cfg.filter[BACKSPACE] = BACKSPACE;
    cfg.filter[XOFF]   = 'P';
    cfg.filter['\r']   = '\n';
    cfg.filter[CNTRLO] = 'N';

    /*
     * Set up some defaults
     */
    cfg.flags.DEFSHOWTIME = 1;
    cfg.flags.DEFFLOORMODE = 1;
    cfg.flags.NOCHAT = 1;
    cfg.flags.USA = 1;
    cfg.flags.AIDEKILLROOM = 1;	/* Allow Aides to kill rooms */
    cfg.flags.ANONNETMAIL = 1;	/* Allow net mail from unknown nodes */
    cfg.flags.ANONFILEXFER = 1;	/* Allow file xfers with unknown nodes */
    cfg.flags.FORWARD_MAIL = 1;	/* Allow mail to route through here */

    cfg.newusermsgs = 50;
    cfg.recSize = 100;
    cfg.local_time = 25;
    cfg.ld_time    = 50;
    cfg.anonmailmax = 1000;	/* Smaller mail msgs for unloggedIn users */
    cfg.infomax = 1000;		/* Size of info files for normal users */
    cfg.syswidth   = 39;
    cfg.floorCount = 1;		/* will be reset later on... */
    cfg.ld_cost = 1;		/* one AMU to send mail to a ld site */
    cfg.hubcost = 2;		/* two AMU's to have it flung */
    cfg.poll_delay = 5;
    cfg.codeBuf[0] = '.';	/* make a dummy directory for sysdir... */
}

void
parsecnfg(void)
{
    FILE *cfgfile, *pwdfile, *fopen();
    char line[90], cmd[90], var[90];
    char *fgets();

    if (evtTab) {		/* always wipe the event table */
	cfg.evtCount = 0;
	free(evtTab);
	evtTab = NULL;
    }
    if (pollTab) {		/* always wipe the poll table */
	cfg.poll_count = 0;
	free(pollTab);
	pollTab = NULL;
    }
    if (archTab) {		/* always wipe the archivers table */
	cfg.arch_count = 0;
	free(archTab);
	archTab = NULL;
    }

    nextcode = &cfg.codeBuf[offset=1];
    zero_array(depend);		/* Just to be safe... */
    /*
     * Nuke all codeBuf[] offsets if this is a `configur +', in case
     * one or more of them has been undefined.
     */
    if (gotTabl)
	cfg.nodeName = cfg.nodeTitle = cfg.nodeId = cfg.shell = cfg.sysopName =
	cfg.hub = cfg.organization = cfg.domain = cfg.sysdir = cfg.roomdir =
	cfg.helpdir = cfg.msgdir = cfg.netdir = cfg.auditdir = cfg.receiptdir =
	cfg.holddir = cfg.modemSetup = cfg.dialPrefix = cfg.dialSuffix = 0;

    if ((cfgfile = fopen(CFG, "r")) == NULL)
	crashout("can't open %s", CFG);

    while (fgets(line, 90, cfgfile)) {
	cmd[0] = 0;
	lineno++;
	strtok(line,"\n");
	strcpy(msgline, line);

	if (nextcode >= &cfg.codeBuf[MAXCODE])
	    crashout("codeBuf overflow!");

	if (sscanf(line, "%s", cmd) > 0) {
	    if (stricmp(cmd, "#event") == 0)
		buildevent(line);
	    else if (stricmp(cmd, "#polling") == 0)
		buildpoll(line);
	    else if (stricmp(cmd, "#archiver") == 0)
		buildarch(line);
	    else if (stricmp(cmd, "#nodeTitle") == 0) {
		cfg.nodeTitle = readXstring(line, MAXCODE, YES);
		depend[NODETITLE]++;
	    }
	    else if (stricmp(cmd, "#modemSetup") == 0) {
		cfg.modemSetup = readXstring(line, MAXCODE, YES);
	    }
	    else if (stricmp(cmd, "#reply300") == 0) {
		cfg.mCCs[ONLY_300] = readXstring(line, MAXCODE, YES);
		cfg.flags.MODEMCC = 1;
	    }
	    else if (stricmp(cmd, "#reply1200") == 0) {
		cfg.mCCs[UPTO1200] = readXstring(line, MAXCODE, YES);
		cfg.flags.MODEMCC = 1;
	    }
	    else if (stricmp(cmd, "#reply2400") == 0) {
		cfg.mCCs[UPTO2400] = readXstring(line, MAXCODE, YES);
		cfg.flags.MODEMCC = 1;
	    }
	    else if (stricmp(cmd, "#reply9600") == 0) {
		cfg.mCCs[UPTO9600] = readXstring(line, MAXCODE, YES);
		cfg.flags.MODEMCC = 1;
	    }
	    else if (stricmp(cmd, "#reply19200") == 0) {
		cfg.mCCs[UPTO19200] = readXstring(line, MAXCODE, YES);
		cfg.flags.MODEMCC = 1;
	    }
	    else if (stricmp(cmd, "#sysdir") == 0) {
		cfg.sysdir = readDstring(line);
		depend[SYSDIR]++;
	    }
	    else if (stricmp(cmd, "#roomdir") == 0) {
		cfg.roomdir = readDstring(line);
		depend[ROOMDIR]++;
	    }
	    else if (stricmp(cmd, "#holddir") == 0) {
		cfg.holddir = readDstring(line);
		depend[HOLDDIR]++;
	    }
	    else if (stricmp(cmd, "#helpdir") == 0) {
		cfg.helpdir = readDstring(line);
		depend[HELPDIR]++;
	    }
	    else if (stricmp(cmd, "#msgdir") == 0) {
		cfg.msgdir = readDstring(line);
		depend[MSGDIR]++;
	    }
	    else if (stricmp(cmd, "#auditdir") == 0) {
		cfg.auditdir = readDstring(line);
		depend[AUDITDIR]++;
	    }
	    else if (stricmp(cmd, "#netdir") == 0
		|| stricmp(cmd, "#spooldir") == 0) {
		cfg.netdir = readDstring(line);
		depend[NETDIR]++;
	    }
	    else if (stricmp(cmd, "#receiptdir") == 0) {
		cfg.receiptdir = readDstring(line);
		depend[RECEIPTDIR]++;
	    }
	    else if (stricmp(cmd, "#shell") == 0) {
		cfg.shell = readXstring(line, MAXCODE, NO);
	    }
	    else if (stricmp(cmd, "#sysop") == 0) {
		cfg.sysopName = readXstring(line, NAMESIZE, NO);
	    }
	    else if (stricmp(cmd, "#sysPassword") == 0) {
		readString(line, cfg.sysPassword, NO);
		if (cfg.sysPassword[0]) {
		    if ((pwdfile = fopen(cfg.sysPassword, "r")) == NULL)
			printf("Can't open system password file %s.\n",cfg.sysPassword);
		    else {
			fgets(cfg.sysPassword, 59, pwdfile);
			fclose(pwdfile);
			strtok(cfg.sysPassword,"\n");
			if (strlen(cfg.sysPassword) < 15)
			    printf("System password is too short -- ignored.\n");
			else continue;
		    }
		}
		cfg.sysPassword[0] = 0;
	    }
	    else if (stricmp(cmd, "#callOutSuffix") == 0) {
		cfg.dialSuffix = readXstring(line, MAXCODE, YES);
		depend[NETSUFFIX]++;
	    }
	    else if (stricmp(cmd, "#callOutPrefix") == 0) {
		cfg.dialPrefix = readXstring(line, MAXCODE, YES);
		depend[NETPREFIX]++;
	    }
	    else if (stricmp(cmd, "#nodeName") == 0) {
		cfg.nodeName = readXstring(line, NAMESIZE, NO);
		if (NNisok(&cfg.codeBuf[cfg.nodeName])) {
		    depend[NODENAME]++;
		    if (strlen(&cfg.codeBuf[cfg.nodeName]) >= NODESIZE)
			printf("Node name is longer than %d characters.\n",
				NODESIZE-1);
		}
		else
		    dependerr("Illegal character in node name.");
	    }
	    else if (stricmp(cmd, "#nodeId") == 0) {
		cfg.nodeId = readXstring(line, NAMESIZE, NO);
		depend[NODEID]++;
            }
	    else if (stricmp(cmd, "#organization") == 0)
		cfg.organization = readXstring(line, ORGSIZE, NO);
	    else if (stricmp(cmd, "#domain") == 0)
		cfg.domain = readXstring(line, NAMESIZE, NO);
	    else if (stricmp(cmd, "#hub") == 0)
		cfg.hub = readXstring(line, NAMESIZE, NO);
	    else if (stricmp(cmd, "#basefloor") == 0) {
		readString(line, lobbyfloor, YES);
		if (strlen(lobbyfloor) > NAMESIZE-1)
		    dependerr("#basefloor too long; must be less than 20 chars.");
	    }
	    else if (stricmp(cmd, "#baseroom") == 0) {
		readString(line, baseroom, YES);
		if (strlen(baseroom) > NAMESIZE-1)
		    dependerr("#baseroom too long; must be less than 20 chars.");
	    }
	    else if (strcmp(cmd, "#define") == 0) {
		if (sscanf(line, "%s %s %d", cmd, var, &arg) == 3)
		    setvariable(var, arg);
		else {
		    sprintf(cmd, "Bad #define setting for `%s'.", var);
		    dependerr(cmd);
		}
	    }
	    else if (cmd[0] == '#') {
		/*
		 * Allow C-86 style #VAR VALUE things....
		 */
		strcpy(var, &cmd[1]);
		if (sscanf(line, "%s %d", cmd, &arg) == 2)
		    setvariable(var, arg);
		else {
		    sprintf(cmd, "Bad variable setting for `%s'.", var);
		    dependerr(cmd);
		}
	    }
	}
    }
    /* We now have enough information to do this... */
    initroomBuf(&roomBuf);
    initlogBuf(&logBuf);
    initnetBuf(&netBuf);

    cfg.codeBuf[0] = '\0';	/* Nuke the first char in codeBuf */
}

/* Support functions for parsecnfg() start here */

static char ws[] = "\t ";

void
buildevent(char *line)
{
    int eHr, eMin, eFlags;
    char *eType, *eName;
    struct evt_type anEvt;
    char *when, *time, *dura, *flag;
    int dayCode;

    zero_struct(anEvt);
    when = NULL;

    strtok(line, ws);
    eType = strtok(NULL, ws);
    time = strtok(NULL, ws);
    if (time && !isdigit(*time)) {
	when = time;
	time = strtok(NULL, ws);
    }
    dura = strtok(NULL, ws);
    eName= strtok(NULL, ws);
    flag = strtok(NULL, ws);
    if (!flag)
	dependerr("Improperly formed #event.");

    if ((dayCode = decodeday(when)) == 0)
	dependerr("Bad day code in #event.");

    sscanf(time, "%d:%d", &eHr, &eMin);
    anEvt.evtTime= (eHr*60) + eMin;
    anEvt.evtDay = dayCode;
    anEvt.evtLen = atoi(dura);
    anEvt.evtFlags = eFlags = atoi(flag);
    copystring(anEvt.evtMsg, eName, NAMESIZE);
    if (stricmp("timeout", eType) == 0)
	anEvt.evtType = EVENT_TIMEOUT;
    else if (stricmp("preemptive", eType) == 0)
	anEvt.evtType = EVENT_PREEMPTIVE;
    else if (stricmp("network", eType) == 0)
	anEvt.evtType = EVENT_NETWORK;
    else
	dependerr("Bad event type.");
    addevent(&anEvt);
}

void
addevent(struct evt_type *evt)
{
    struct evt_type *tmp;
    int i;

    tmp = (struct evt_type *)xmalloc(sizeof(*evtTab) * (1+cfg.evtCount));

    for (i=0; i<cfg.evtCount; i++)
	copy_struct(evtTab[i], tmp[i]);
    if (evtTab)
	free(evtTab);
    evtTab = tmp;

    copy_struct(*evt, evtTab[cfg.evtCount]);
    cfg.evtCount++;
}

void
buildpoll(char *line)
{
    char *net, *start, *end, *when;
    int hr, min;
    int ac;
    struct poll_t temp;
    struct poll_t *tmp;
    int i;

    strtok(line, ws);
    net = strtok(NULL, ws);
    start = strtok(NULL, ws);
    end = strtok(NULL, ws);
    when = strtok(NULL, ws);

    if (net && start && end) {
	temp.p_net = atoi(net);
	if (temp.p_net < 0 || temp.p_net > 31)
	    dependerr("Bad #poll net.");

	if ((ac=sscanf(start, "%d:%d", &hr, &min)) < 1)
	    dependerr("Malformed #poll start time.");
	if (ac == 1)
	    min = 0;
	temp.p_start = (hr*60)+min;
	
	if ((ac=sscanf(end, "%d:%d", &hr, &min)) < 1)
	    dependerr("Malformed #poll end time.");
	if (ac == 1)
	    min = 0;
	temp.p_end = (hr*60)+min;

	if ((temp.p_days = decodeday(when)) == 0)
	    dependerr("Bad #poll days.");

	tmp = (struct poll_t *)xmalloc(sizeof(*pollTab) * (1+cfg.poll_count));

	for (i=0; i<cfg.poll_count; i++)
	    copy_struct(pollTab[i], tmp[i]);
	if (pollTab)
	    free(pollTab);
	pollTab = tmp;

	copy_struct(temp, pollTab[cfg.poll_count]);
	cfg.poll_count++;
    }
    else
	dependerr("#poll syntax error.");
}

int
decodeday(char *when)	/* produces bitmap: xxxxxxxx xSFRWTMS */
{
    static int daycode;
    static char *dy;
    static int i;

    daycode = 0x7f;
    if (when && stricmp(when, "all") != 0) {
	daycode = 0;
	for (dy=strtok(when,","); dy; dy=strtok(NULL,",")) {
	    for (i=0; i<7; i++)
		if (stricmp(dy, _day[i]) == 0)
		    break;
	    if (i<7) {
		daycode |= (1<<i);
	    }
	    else {
		return 0;
	    }
	}
    }
    return daycode;
}

void
buildarch(char *line)
{
    struct archiver ar, *tmp;
    char *ext, *door;
    int i;

    strtok(line, ws);
    ext = strtok(NULL, ws);
    door = strtok(NULL, ws);

    if (ext && door) {
	strcpy(ar.extension, ext);
	strcpy(ar.doorname, door);
	tmp = (struct archiver *)xmalloc(sizeof(*archTab) * (1+cfg.arch_count));

	for (i=0; i<cfg.arch_count; i++)
	    copy_struct(archTab[i], tmp[i]);
	if (archTab)
	    free(archTab);
	archTab = tmp;

	copy_struct(ar, archTab[cfg.arch_count]);
	cfg.arch_count++;
    }
    else
	dependerr("#archiver syntax error.");
}

int
readXstring(char *line, int maxsize, int flag)
{
    int retval = offset;

    readString(line, nextcode, flag);

    if (strlen(nextcode) >= maxsize)
	crashout("(line %d): Argument too long; must be less than %d! --> %s",
	    lineno, maxsize, msgline);
    else if (*nextcode == 0)
	return 0;

    while (*nextcode++)
	offset++;
    offset++;

    return retval;
}

int
readDstring(char *from)
{
    int retval = offset;
    int size;

    readString(from, nextcode, FALSE);

    if (*nextcode == 0)
	return 0;
    size = strlen(nextcode);
    if (size-- > 0 && nextcode[size] == '\\')
	nextcode[size] = 0;
    while (*nextcode++)
	offset++;
    offset++;

    return retval;
}
	    
void
readString(char *source, char *destination, char doproc)
{
    char string[300], last = 0;
    int  i, j;

    for (i = 0; source[i] != '"'; i++)
        ;
    for (j = 0, i++; source[i] != '"' || last == '\\'; i++, j++) {
	string[j] = source[i];
	if (doproc)
	    last = source[i];
    }

    string[j] = 0;
    strcpy(destination, string);
    if (doproc)
	doformat(destination);
}

void
doformat(char *s)
{
    register char *p, *q;
    register int i;

    for (p=q=s; *q; ++q) {
	if (*q == '\\')
	    switch (*++q) {
	    case 'n' :
		*p++ = '\n';
		break;
	    case 't' :
		*p++ = '\t';
		break;
	    case 'b' :
		*p++ = '\b';
		break;
	    case 'r' :
		*p++ = '\r';
		break;
	    case 'f' :
		*p++ = '\f';
		break;
	    default :
		if (isdigit(*q)) {
		    for (i=0; isdigit(*q); ++q)
			i = (i<<3) + (*q - '0');
		    *p = i;
		    --q;
		}
		else
		    *p++ = *q;
		break;
	    }
	    else
		*p++ = *q;
    }
    *p = 0;
}

void
dependerr(char *errorstring)
{
    printf("ERROR: %s\n", errorstring);
    derr = YES;
}

#define setflag(x,y)	cfg.flags.y = (x ? 1 : 0) 

void
setvariable(char *var, int arg)
{
    char tmp[80];

    if (stricmp(var, "CRYPTSEED") == 0)
	cfg.cryptSeed = arg;
    else if (stricmp(var, "MESSAGEK") == 0) {
	long msgsize = (1024L * (long)arg) + (long)(BLKSIZE-1);

	cfg.maxMSector = msgsize/BLKSIZE;
	depend[MESSAGEK]++;
    }
    else if (stricmp(var, "LOGSIZE") == 0) {
	if (gotTabl && (cfg.logsize != arg)) {
	    printf("LOGSIZE has changed, old=%d, new=%d.\n", cfg.logsize,
		arg);
	    printf("Run lchange.prg or fix your ctdlcnfg.sys file.\n");
	    exit(7);
	}
	cfg.logsize = arg;
	if (!gotTabl) {
	    logTab = (struct lTable *) xmalloc(sizeof(*logTab) * arg);
	    memset(logTab, 0, sizeof(*logTab) * arg);
	}
	depend[LTABSIZE]++;
    }
    else if (stricmp(var, "MAXROOMS") == 0) {
	if (gotTabl && (cfg.maxrooms != arg)) {
	    printf("MAXROOMS has changed, old=%d, new=%d.\n", cfg.maxrooms,
		arg);
	    printf("Run rchange.prg or fix your ctdlcnfg.sys file.\n");
	    exit(7);
	}
	cfg.maxrooms = arg;
	if (!gotTabl) {
	    roomTab = (struct rTable *) xmalloc(sizeof(*roomTab) * arg);
	    memset(roomTab, 0, sizeof(*roomTab) * arg);
	}
    }
    else if (stricmp(var, "MAILSLOTS") == 0)
	if (gotTabl && (cfg.mailslots != arg)) {
	    printf("MAILSLOTS has changed, old=%d, new=%d.\n", cfg.mailslots,
		arg);
	    printf("Run rchange.prg or fix your ctdlcnfg.sys file.\n");
	    exit(7);
	}
	else
	    cfg.mailslots = arg;
    else if (stricmp(var, "SHAREDROOMS") == 0)
	if (gotTabl && (cfg.sharedrooms != arg)) {
	    printf("SHAREDROOMS has changed, old=%d, new=%d.\n",
		cfg.sharedrooms, arg);
	    printf("Run nchange.prg or fix your ctdlcnfg.sys file.\n");
	    exit(7);
	}
	else
	    cfg.sharedrooms = arg;
    else if (stricmp(var, "TIMEOUT") == 0)
	dotimeout = arg;
    else if (stricmp(var, "HOUROUT") == 0) {
	if (arg > 23)
	    dependerr("Illegal HOUROUT (must be 0 to 23).");
	else
	    hourout = arg;
    }
    else if (stricmp(var, "POLL-DELAY") == 0) {
	if (arg < 1)
	    dependerr("POLL-DELAY must be > 0.");
	else
	    cfg.poll_delay = 60L * arg;
    }
    else if (stricmp(var, "MSGENTER") == 0)
	cfg.maxmsgs = arg;
    else if (stricmp(var, "MAILENTER") == 0)
	cfg.maxmailmsgs = arg;
    else if (stricmp(var, "ANONMAILMAX") == 0) {
	if (arg < 100 || arg > MAXTEXT) {
	    sprintf(tmp, "ANONMAILMAX must be between 100 and %d.", MAXTEXT);
	    dependerr(tmp);
	}
	cfg.anonmailmax = arg;
    }
    else if (stricmp(var, "INFOMAX") == 0) {
	if (arg < 100 || arg > MAXTEXT) {
	    sprintf(tmp, "INFOMAX must be between 100 and %d.", MAXTEXT);
	    dependerr(tmp);
	}
	cfg.infomax = arg;
    }
    else if (stricmp(var, "MAXCALLS") == 0)
	cfg.maxcalls = arg;
    else if (stricmp(var, "MAXTIME") == 0)
	cfg.maxtime = arg;
    else if (stricmp(var, "MAXCLOSECALLS") == 0)
	cfg.maxclosecalls = arg;
    else if (stricmp(var, "CLOSETIME") == 0)
	cfg.closetime = arg;
    else if (stricmp(var, "MINCALLTIME") == 0)
	cfg.mincalltime = arg;
    else if (stricmp(var, "NEWUSERMSGS") == 0)
	cfg.newusermsgs = arg;
    else if (stricmp(var, "EVENTCLOSETIME") == 0)
	cfg.evtclosetime = arg;
    else if (stricmp(var, "WIDTH") == 0) {
	if (arg < 10 || arg > 255)
	    dependerr("WIDTH must be between 10 and 255.");
	cfg.syswidth = arg;
    }
    else if (stricmp(var, "DOWNLOAD") == 0)
	cfg.download = 1024L * arg;
    else if (stricmp(var, "LD-COST") == 0)
	cfg.ld_cost = arg;
    else if (stricmp(var, "HUB-COST") == 0)
	cfg.hubcost = arg;
    else if (stricmp(var, "LOCAL-TIME") == 0)
	cfg.local_time = arg;
    else if (stricmp(var, "LD-TIME") == 0)
	cfg.ld_time = arg;
    else if (stricmp(var, "RECEIPTK") == 0)
	cfg.recSize = arg;
    else if (stricmp(var, "CONNECTDELAY") == 0)
	cfg.connectDelay = arg;
    else if (stricmp(var, "SYSBAUD") == 0) {
	cfg.sysBaud = arg;
	depend[SYSBAUD]++;
	if (arg >= NUMBAUDS)
	    dependerr("Invalid SYSBAUD.");
    }
    else if (stricmp(var, "INIT-SPEED") == 0)
	cfg.probug = arg;
    else if (stricmp(var, "NUMBANNERS") == 0) {
	if (arg < 0 || arg > 999)
	    dependerr("NUMBANNERS must be between 0 and 999.");
	cfg.numbanners = arg;
    }
    /*
     * binary flags from here on:
     */
    else if (stricmp(var, "AUDIT-CALLS") == 0)	/* audit calls      */
	set_audit(arg, aLOGIN);
    else if (stricmp(var, "AUDIT-FILES") == 0)	/* audit downloads  */
	set_audit(arg, aDNLOAD);
    else if (stricmp(var, "AUDIT-EXIT") == 0)	/* system shutdowns */
	set_audit(arg, aEXIT);
    else if (stricmp(var, "CALL-LOG") == 0)
	set_audit(arg, aLOGIN|aEXIT);
    else if (stricmp(var, "ESC") == 0)
	cfg.filter[ESC] = (arg) ? ESC : 0;
    else if (stricmp(var, "SHOWUSAGE") == 0)
	setflag(arg, DISKUSAGE);
    else if (stricmp(var, "LOGINOK") == 0)
	setflag(arg, LOGINOK);
    else if (stricmp(var, "ENTEROK") == 0)
	setflag(arg, ENTEROK);
    else if (stricmp(var, "READOK") == 0)
	setflag(arg, READOK);
    else if (stricmp(var, "ROOMOK") == 0)
	setflag(arg, ROOMOK);
    else if (stricmp(var, "INFOOK") == 0)
	setflag(arg, INFOOK);
    else if (stricmp(var, "ALLMAIL") == 0)
	setflag(!arg, NOMAIL);
    else if (stricmp(var, "ALLNET") == 0)
	setflag(arg, ALLNET);
    else if (stricmp(var, "ALLDOOR") == 0)
    	setflag(arg, ALLDOOR);
    else if (stricmp(var, "DEFSHOWTIME") == 0)
    	setflag(arg, DEFSHOWTIME);
    else if (stricmp(var, "DEFLASTOLD") == 0)
    	setflag(arg, DEFLASTOLD);
    else if (stricmp(var, "DEFFLOORMODE") == 0)
    	setflag(arg, DEFFLOORMODE);
    else if (stricmp(var, "DEFREADMORE") == 0)
    	setflag(arg, DEFREADMORE);
    else if (stricmp(var, "DEFNUMLEFT") == 0)
    	setflag(arg, DEFNUMLEFT);
    else if (stricmp(var, "DEFAUTONEW") == 0)
	setflag(arg, DEFAUTONEW);
    else if (stricmp(var, "GETNAME") == 0)
	setflag(arg, GETNAME);
    else if (stricmp(var, "BANNERBLB") == 0)
	setflag(arg, BANNERBLB);
    else if (stricmp(var, "SHOWRECD") == 0)
	setflag(arg, SHOWRECD);
    else if (stricmp(var, "AUTOZEROLIMIT") == 0)
	setflag(arg, AUTOZEROLIMIT);
    else if (stricmp(var, "KEEPHOLD") == 0)
	setflag(arg, KEEPHOLD);
    else if (stricmp(var, "KEEPDISCARDS") == 0)
	setflag(arg, KEEPDISCARDS);
    else if (stricmp(var, "SYSOPSLEEP") == 0)
	setflag(arg, SYSOPSLEEP);
    else if (stricmp(var, "AIDE-FORGET") == 0)
	setflag(arg, AIDE_FORGET);
    else if (stricmp(var, "AIDEKILLROOM") == 0)
	setflag(arg, AIDEKILLROOM);
    else if (stricmp(var, "VAPORIZE") == 0)
	setflag(arg, VAPORIZE);
    else if (stricmp(var, "ANONNETMAIL") == 0)
	setflag(arg, ANONNETMAIL);
    else if (stricmp(var, "ANONFILEXFER") == 0)
	setflag(arg, ANONFILEXFER);
    else if (stricmp(var, "HAYES") == 0)
	setflag(arg, HAYES);
    else if (stricmp(var, "ZAPLOOPS") == 0)
	setflag(arg, FZAP);
    else if (stricmp(var, "PURGENET") == 0)
	setflag(arg, PURGENET);
    else if (stricmp(var, "NETLOG") == 0)
	setflag(arg, FNETLOG);
    else if (stricmp(var, "NETDEBUG") == 0)
	setflag(arg, FNETDEB);
    else if (stricmp(var, "DEBUG") == 0)
	setflag(arg, DEBUG);
    else if (stricmp(var, "CHAT") == 0)
	setflag(!arg, NOCHAT);
    else if (stricmp(var, "USA") == 0)
	setflag(arg, USA);
    else if (stricmp(var, "SEARCHBAUD") == 0)
	setflag(arg, SEARCH_BAUD);
    else if (stricmp(var, "CONNECTPROMPT") == 0)
	setflag(arg, CONNECTPROMPT);
    else if (stricmp(var, "FORWARD-MAIL") == 0)
	setflag(arg, FORWARD_MAIL);
    else if (stricmp(var, "ARCHIVE-MAIL") == 0)
	setflag(arg, ARCHIVE_MAIL);
    else if (stricmp(var, "PATHALIAS") == 0)
	setflag(arg, PATHALIAS);
    else
	printf("No such variable `%s'.\n", var);
}

void
set_audit(int x, short bit)
{
    if (x)
	cfg.call_log |= bit;
    else
	cfg.call_log &= ~bit;
}

void
checkdepend(int depend[])
{
    int i;

    if (depend[SYSDIR])
	exists(cfg.sysdir);
    else
	dependerr("#sysdir not defined.");

    if (depend[HELPDIR])
	exists(cfg.helpdir);
    else {
	puts("#helpdir not defined -- using #sysdir.");
	cfg.helpdir = cfg.sysdir;
    }

    if (depend[ROOMDIR])
	exists(cfg.roomdir);
    else {
	puts("#roomdir not defined -- using #sysdir.");
	cfg.roomdir = cfg.sysdir;
    }

    if (depend[HOLDDIR])
	exists(cfg.holddir);
    else {
	puts("#holddir not defined -- using #sysdir.");
	cfg.holddir = cfg.sysdir;
    }

    if (depend[MSGDIR])
	exists(cfg.msgdir);
    else {
	puts("#msgdir not defined -- using #sysdir.");
	cfg.msgdir = cfg.sysdir;
    }
    if (depend[AUDITDIR])
	exists(cfg.auditdir);
    else {
	puts("#auditdir not defined -- using #sysdir.");
	cfg.auditdir = cfg.sysdir;
    }
    if (depend[NETDIR])
	exists(cfg.netdir);
    else
	dependerr("No #netdir.");
    if (depend[RECEIPTDIR])
	exists(cfg.receiptdir);
    else {
	if (depend[NETDIR])
	    puts("#receiptdir not defined -- using #netdir.");
	else
	    dependerr("#receiptdir not defined.");
	cfg.receiptdir = cfg.netdir;
    }

    if (!depend[NODETITLE])
	dependerr("No NODETITLE defined.");
    if (!depend[MESSAGEK])
	dependerr("No MESSAGEK defined.");
    if (!depend[LTABSIZE])
	dependerr("No LOGSIZE defined.");
    if (!depend[SYSBAUD])
	dependerr("No SYSBAUD defined.");
    if (!depend[NETPREFIX])
	dependerr("No CALLOUTPREFIX defined.");
    if (!depend[NETSUFFIX])
	dependerr("No CALLOUTSUFFIX defined.");
    if (!depend[NODENAME])
	dependerr("No NODENAME defined.");
    if (!depend[NODEID])
	dependerr("No NODEID defined.");

    if (dotimeout && hourout < 0)
	dependerr("HOUROUT not defined for TIMEOUT.");
    if (cfg.flags.MODEMCC)
	if (!(cfg.flags.SEARCH_BAUD))
	    puts("Modem result codes are defined but SEARCHBAUD isn't.");
	else for (i=0; i<cfg.sysBaud; i++)
	    if (cfg.mCCs[i] == 0)
		dependerr("Baud rate detection not fully defined.");

    if ((cfg.maxrooms > MAXMAXROOMS) || (cfg.maxrooms < MINMAXROOMS)) {
	printf("ERROR: maxrooms must be between %d and %d.\n", MINMAXROOMS,
		MAXMAXROOMS);
	derr = YES;
    }
    else if (cfg.maxrooms > SANEMAXROOMS && roomsmissing == NONE)
	printf("WARNING: maxrooms > %d; make sure this is what you want.\n",
		SANEMAXROOMS);

    if ((cfg.mailslots > MAXMAILSLOTS) || (cfg.mailslots < MINMAILSLOTS)) {
	printf("ERROR: mailslots must be between %d and %d.\n", MINMAILSLOTS,
		MAXMAILSLOTS);
	derr = YES;
    }
    else if (cfg.mailslots > SANEMAILSLOTS && tozap[LOG])
	printf("WARNING: mailslots > %d; make sure this is what you want.\n",
		SANEMAILSLOTS);

    if ((cfg.sharedrooms > MAXSHAREDROOMS) || (cfg.sharedrooms < MINSHAREDROOMS)) {
	printf("ERROR: sharedrooms must be between %d and %d.\n", MINSHAREDROOMS,
		MAXSHAREDROOMS);
	derr = YES;
    }
    else if (cfg.sharedrooms > SANESHAREDROOMS && tozap[NET])
	printf("WARNING: sharedrooms > %d; make sure this is what you want.\n",
		SANESHAREDROOMS);

    if ((cfg.logsize > MAXLOGSIZE) || (cfg.logsize < MINLOGSIZE)) {
	printf("ERROR: logsize must be between %d and %d.\n", MINLOGSIZE,
		MAXLOGSIZE);
	derr = YES;
    }
    else if (cfg.logsize > SANELOGSIZE && tozap[LOG])
	printf("WARNING: logsize > %d; make sure this is what you want.\n",
		SANELOGSIZE);
}

void
exists(OFFSET where)
{
    char here[200];
    char c;

    getcd(here);
    if (cd(&cfg.codeBuf[where]) != 0) {
	if (attended) {
	    printf("Directory %s does not exist; create it? ",
		    &cfg.codeBuf[where]);
	    fflush(stdout);
	    putchar(c = toupper(getch()));
	    if (c != '\n') putchar('\n');
	    if (c == 'Y') {
		if (mkdir(&cfg.codeBuf[where]) != 0)
		    crashout("Cannot create directory!");
	    }
	    else
		exit(3);
	}
	else
	    crashout("Directory '%s' does not exist.", &cfg.codeBuf[where]);
    }
    cd(here);
}

/* FOOBAR! End of support functions for parsecnfg() */

void
openfiles(void)
{
    PATHBUF sysfile, here;
    int i, dummyfl, missing = 0, found = 0;

    ctdlfile(sysfile, cfg.msgdir, "ctdlmsg.sys");
    if ((msgfl = dopen(sysfile, O_RDWR)) < 0)
	tozap[MSGS] = YES;
    ctdlfile(sysfile, cfg.sysdir, "ctdllog.sys");
    if ((logfl = dopen(sysfile, O_RDWR)) < 0)
	tozap[LOG] = YES;
    ctdlfile(sysfile, cfg.netdir, "ctdlnet.sys");
    if ((netfl = dopen(sysfile, O_RDWR)) < 0)
	tozap[NET] = YES;

    ctdlfile(sysfile, cfg.sysdir, "ctdlflr.sys");
    if (!getdirentry(sysfile))
	tozap[FLOOR] = YES;

    /* Now we want to (as quickly as possible) check for the presence or
	absence of room files.  We only need to know if NONE, SOME or ALL
	of them are missing. */

    getcd(here);
    cd(&cfg.codeBuf[cfg.roomdir]);
    for (i=0; i < MAXROOMS; i++) {
	sprintf(sysfile, "room%04d.sys", i);
	if (!getdirentry(sysfile)) {
	    if (!tozap[MSGS])
		printf("Room file %s not found.\n", sysfile);
	    missing++;
	    if (found) break;	/* Some missing, some found? Stop checking. */
	}
	else {
	    found++;
	    if (missing) break;	/* ditto ^ */
	}
    }
    cd(here);

    if (found == 0)
	roomsmissing = ALL;
    else if (missing == 0)
	roomsmissing = NONE;
    else roomsmissing == SOME;
}

void
querysysop(void)
{
    /* If there were are any datafiles missing, or if we're scanning the
	files anyway and we say that we want to nuke some instead...: */
    if (ANYTOZAP() || (scanfiles &&
		conGetYesNo("Wipe messages, rooms, users and/or netnodes"))) {
	if (tozap[MSGS])
	    printf("Message file was missing, so I'll reinitialise it.\n");
	else
	    tozap[MSGS] = conGetYesNo("Wipe out the message file");
	if (tozap[LOG])
	    printf("Log file was missing, so I'll reinitialise it.\n");
	else
	    tozap[LOG] = conGetYesNo("Wipe out all the users");
	if (tozap[NET])
	    printf("Net file was missing, so I'll reinitialise it.\n");
	else
	    tozap[NET] = conGetYesNo("Wipe out the net list");
	if (tozap[FLOOR])
	    printf("Floor file was missing, so I'll reinitialise it.\n");
	else
	    tozap[FLOOR] = conGetYesNo("Wipe out all the floors");
	if (roomsmissing)
	    printf("%s rooms were missing, so I'll reinitialise them.\n",
		(roomsmissing == ALL ? "All" : "Some"));
	else
	    roomsmissing = (conGetYesNo("Wipe out all the rooms") ? ALL : NONE);
	    /* Pretend that rooms were all missing if we want to nuke them */
    }
    return;
}

/*
 * we use the special getmsg() here instead of the more general library
 * routine getmessage(), because the latter pulls in the whole header
 * while we need only the ID and room name.  Quicker this way.
 */
int
msgscan(void)
{
    int atoi();
    long first;
    long newest;
    short catsect, catchar;

    if (!do_checkpoint || !read_checkpoint(&newest, &catsect, &catchar)) {
	catsect = catchar = 0;
	newest = 0L;
    }
    msgseek(catsect, catchar);
    getmsg();

    fprintf(stderr, "\r%6ld\r", msgBuf.mbid);
    cfg.newest = cfg.oldest = first = msgBuf.mbid;
    cfg.catSector = mboffset;
    cfg.catChar = mbindex;

    if (do_checkpoint) {
	/*
	 * When we use the checkpoint method we seek to where we think the
	 * newest message is, and scan until we reach a message which is lower
	 * than the preceding one.  We assume that this message is in fact
	 * cfg.oldest.  If there is an internal inconsistency in the message
	 * base, there will be undefined but probably nasty ramifications.
 	 */
	for (getmsg(); msgBuf.mbid > cfg.newest; getmsg()) {
	    fprintf(stderr, "%6ld\r", msgBuf.mbid);
	    cfg.newest = first = msgBuf.mbid;
	    cfg.catSector = mboffset;
	    cfg.catChar = mbindex;
	}
	cfg.oldest = msgBuf.mbid;
	mailcount = 0L;		/* Checkpointing invalidates mail msg count */
	if (first != newest) {
	    printf("Inconsistency in checkpoint value for newest message.\n");
	    printf("You should probably reconfigure without the `-c' switch.\n");
	}
    }
    else {
	/*
	 * The default behaviour is to scan the message base from start to
	 * finish (or more precisely, from start back to start again), keeping
	 * a running tally of the highest and lowest messages seen.
	 */
	for (getmsg(); msgBuf.mbid != first; getmsg()) {
	    fprintf(stderr, "%6ld\r", msgBuf.mbid);

	    /* find highest and lowest message IDs: */
	    if (msgBuf.mbid < cfg.oldest)
		cfg.oldest = msgBuf.mbid;
	    if (msgBuf.mbid > cfg.newest) {
		cfg.newest = msgBuf.mbid;
		cfg.catSector = mboffset;
		cfg.catChar = mbindex;
	    }
	}
    }

    printf("Messages run from %ld to %ld.\n", cfg.oldest, cfg.newest);
    return YES;
}

void
getmsg(void)
{
    register int c;
    LABEL temp;
    long r, atol();

    msgBuf.mbroom[0] = 0;

    while (getmsgchar() != 0xff)
	;

    getmsgstr(temp, NAMESIZE);
    if ((r = atol(temp)) > 0L)		/* valid msgid? */
	msgBuf.mbid = r;
    else
	return;

    while ((c=getmsgchar()) != 'M') {
	if (c == 'R')
	    getmsgstr(msgBuf.mbroom, NAMESIZE);
	else while (c=getmsgchar())
	    ;
    }
    if (strcmp(msgBuf.mbroom, "Mail") == 0)
	mailcount++;
    getmsgstr(msgBuf.mbtext, MAXTEXT);
}

void
roomscan(void)
{
    int slot, roomcount = 0;

    for (slot = 0;  slot < MAXROOMS;  slot++) {
	getRoom(slot);
	verifyroomok(slot);
	putRoom(slot);
	noteRoom();
	if (readbit(roomBuf,INUSE)) {
	    roomcount++;
	    printf("room %3d: %s\n", slot, roomBuf.rbname);
	}
    }
    printf("%d valid rooms.\n", roomcount);
}

void
verifyroomok(int slot)	/* Assumes that roomBuf already contains room #slot */
{
    int goodmsgs = 0, i;
    theMessages *templist;

    /* Set up defaults that we need in special rooms: */
    switch (slot) {
    case LOBBY:
	if (!readbit(roomBuf,INUSE))
		strcpy(roomBuf.rbname, baseroom);
 	else if (strcmp(roomBuf.rbname, baseroom) != 0)
		printf("Warning -- #baseroom should be %s.\n", roomBuf.rbname);
	clear(roomBuf,INVITE);
	set(roomBuf,PERMROOM);
	set(roomBuf,INUSE);
	set(roomBuf,PUBLIC);
	break;
    case MAILROOM:
	strcpy(roomBuf.rbname, "Mail");
	set(roomBuf,PERMROOM);
	set(roomBuf,PUBLIC);
	set(roomBuf,INUSE);
	NUMMSGS = MAILSLOTS;
	roomBuf.msg = (theMessages *) myrealloc(roomBuf.msg, MAIL_BULK);
	memset(roomBuf.msg, 0, MAIL_BULK); /* zero the array just to be sure */
	break;
    case AIDEROOM:
	strcpy(roomBuf.rbname, "Aide");
	set(roomBuf,PERMROOM);
 	clear(roomBuf,PUBLIC);
	set(roomBuf,INUSE);
	break;
    default:
	break;
    }

    if (readbit(roomBuf,INUSE) && slot != MAILROOM) {
	if (tozap[MSGS]) {		/* we zapped the message base! */
	    roomBuf.rblastMessage = roomBuf.rblastNet = roomBuf.rblastLocal=0L;
	    NUMMSGS = 0;
	    roomBuf.msg = (theMessages *) myrealloc(roomBuf.msg, MSG_BULK);
	}
	else {				/* scan the array for good messages */
	    templist = (theMessages *)xmalloc(MSG_BULK);
	    for (i = 0; i < NUMMSGS; i++) {
		if (roomBuf.msg[i].msgno <= cfg.newest &&
			roomBuf.msg[i].msgno >= cfg.oldest) {
		    templist[goodmsgs].msgno = roomBuf.msg[i].msgno;
		    templist[goodmsgs].msgloc = roomBuf.msg[i].msgloc;
		    goodmsgs++;
		}
	    }
	    if (goodmsgs != NUMMSGS) {	/* did we compact it at all? */
		NUMMSGS = goodmsgs;
		free(roomBuf.msg);		/* Yes.  Free the old list */
		roomBuf.msg = templist;		/* and point at the new one */
		roomBuf.msg = (theMessages *)myrealloc(roomBuf.msg, MSG_BULK);
	    }
	    else
		free(templist);		/* oh well, we didn't need it... */
	}

	if ((!goodmsgs) && (!readbit(roomBuf,PERMROOM))) /* No messages in a */
	    clear(roomBuf,INUSE);			 /* temp room? NUKE! */

	if (roomBuf.rblastNet > cfg.newest)
	    roomBuf.rblastNet = 0L;
	if (roomBuf.rblastLocal > cfg.newest)
	    roomBuf.rblastLocal = 0L;
	if (tozap[FLOOR])		/* Are we going to or did we */
	    roomBuf.rbfloorGen = LOBBY;		/* zap the floor table? */
    }	/* if INUSE and !MAILROOM */
    return;
}

int
logscan(void)
{
    register int i, j;
    register int modified = NO;
#define BIT30	0x40000000L

    for (i = 0; i < cfg.logsize; i++) {
	logTab[i].ltlogSlot = i;

	getlog(&logBuf, i, logfl);

	if (readbit(logBuf,uINUSE)) {
	    if (tozap[MSGS]) {		/* did we nuke the msgbase? */
		logTab[i].ltnewest = 1L;
		memset(logBuf.lbmail, 0, MAIL_BULK);
		modified = YES;
	    }
	    else
		logTab[i].ltnewest = logBuf.lbvisit[0];

	    logTab[i].ltnmhash = hash(logBuf.lbname);
	    logTab[i].ltpwhash = hash(logBuf.lbpw  );

	    for (j=0; j < MAILSLOTS; j++) {
#if 0
		/* UGLY HACK! DO NOT TOUCH IF NOT WEARING GLOVES! */
		/* This is a stupid hack designed to quietly eliminate msg */
		/* pointers which are of the old negated variety, changing */
		/* them to ABS()'ed versions of their former selves. */
		if (logBuf.lbmail[j].msgno & BIT30) {
		    logBuf.lbmail[j].msgno = ABS(logBuf.lbmail[j].msgno);
		    modified = YES;
		}
#endif
		/* Now check the message to ensure it's a valid one. */
		/* If it isn't, get rid of it. */
		if (MAILNUM(logBuf.lbmail[j].msgno) &&
		    (MAILNUM(logBuf.lbmail[j].msgno) < cfg.oldest ||
		    MAILNUM(logBuf.lbmail[j].msgno) > cfg.newest)) {
		    logBuf.lbmail[j].msgno = 0L;
		    logBuf.lbmail[j].msgloc = 0;
		    modified = YES;
		}
	    }

#if 0
	    /* ANOTHER UGLY HACK!  AAAAAIIIIIIIIIEEE!	*/
	    /* This one is to silently change the format of logBuf.lblast */
	    /* by checking to see if it's less than about 663374000 (the */
	    /* time_t representation of the evening of 91Jan08, the date */
	    /* of this awful hack.) */
	    if (logBuf.lblast < 663374000L) {	/* it's the old style */
		logBuf.lblast = 663374000L;
		modified = YES;
	    }
#endif

	    if (modified)
		putlog(&logBuf, i, logfl);
	    printf("log %3d: %s\n", i, logBuf.lbname);
	}
	else {
	    logTab[i].ltnmhash = 0;
	    logTab[i].ltpwhash = 0;
	}

    }
    puts("--------");
    /* excuse the nasty cast, but I have to shut up gcc somehow... */
    qsort((void *)logTab, (size_t)cfg.logsize, sizeof logTab[0], 
	(int (*)(const void *, const void *))logsort);
}

int
logsort(const struct lTable *s1, const struct lTable *s2)
{
    if (s1->ltnmhash == 0 && s2->ltnmhash == 0)
	return 0;
    if (s1->ltnmhash == 0 && s2->ltnmhash != 0)
	return 1;
    if (s1->ltnmhash != 0 && s2->ltnmhash == 0)
	return -1;
    if (s1->ltnewest < s2->ltnewest)
	return 1;
    if (s1->ltnewest > s2->ltnewest)
	return -1;
    return 0;
}

int
floorscan(void)
{
    register i, floorfl;
    PATHBUF fn;

    ctdlfile(fn, cfg.sysdir, "ctdlflr.sys");
    if ((floorfl = dopen(fn, O_RDONLY)) < 0)
	crashout("Can't open floor file %s", fn);
    cfg.floorCount = (1L+dseek(floorfl, 0L, 2)) / sizeof floorTab[0];
    dclose(floorfl);

    loadfloor();
    updtfloor();

    for (i=0; i < cfg.floorCount; i++)
	if (floorTab[i].flInUse)
	    printf("floor %3d: %s\n", i, floorTab[i].flName);
    puts("--------");
}

int
netscan(int init)	/* init: Nuke the net list? */
{
    LABEL temp;
    PATHBUF netfile;
    register i, m;
    register struct netroom *p;

    if (init) {
	cfg.netSize = 0;
	ctdlfile(netfile, cfg.netdir, "ctdlnet.sys");
	if ((netfl = dcreat(netfile)) < 0)
	    crashout("could not create net file %s", netfile);
    }
    else
	cfg.netSize = (int) ((1L + dseek(netfl, 0l, 2)) / (NB_TOTAL_SIZE));

    if (!netTab) {
	netTab = (struct netTable *)xmalloc(sizeof(*netTab) * cfg.netSize);
	memset(netTab, 0, sizeof(*netTab) * cfg.netSize);
    }
    else if (init)
	netTab = (struct netTable *)myrealloc(netTab, 0);
    for (i=0; i<cfg.netSize; i++) {
	getNet(i);
	netTab[i].Tshared = (struct netroom *) xmalloc(SR_BULK);
	memset(netTab[i].Tshared, 0, SR_BULK);
	if (strlen(netBuf.netName) > NAMESIZE) {
	    netBuf.flags = netTab[i].flags = 0L;	/* Kill bogus node */
	    putNet(i);
	}
	if (readbit(netBuf,N_INUSE)) {
	    for (m=0; m<SHARED_ROOMS; m++) {
		p = &netBuf.shared[m];
		if (tozap[MSGS])
		    p->NRlast = 0L;
		if (p->NRidx >= 0 && roomTab[p->NRidx].rtgen != p->NRgen)
		    p->NRidx = -1;
		if (p->NRidx > MAXROOMS || p->NRidx < -1 ||  /* Sanity checks */
		    p->NRlast > cfg.newest || p->NRlast < 0) {
		    printf("Corrupted shared room found & fixed: node %s, slot %d, room %d.\n",
			netBuf.netName, i, m);
		    p->NRlast = 0L; p->NRgen = p->NRhub = 0; p->NRidx = -1;
		}
	    }
	    normID(netBuf.netId, temp);
	    netTab[i].ntnmhash = hash(netBuf.netName);
	    netTab[i].ntidhash = hash(temp);
	    putNet(i);
	    printf("System %3d: %-12s\n", i, netBuf.netName);
	}
	else {
	    netTab[i].flags = 0L;
	}
    }
    puts("--------");
    return YES;
}

int
normID(LABEL source, LABEL dest)
{
    while (!isalpha(*source) && *source)
	source++;
    if (!*source)
	return NO;
    *dest++ = toupper(*source++);
    while (!isalpha(*source) && *source)
	source++;
    if (!*source)
	return NO;
    *dest++ = toupper(*source++);
    while (*source) {
	if (isdigit(*source))
	    *dest++ = *source;
	source++;
    }
    *dest = 0;
    return YES;
}

void
zapscan(void)
{
    PATHBUF zapfile;
    int zh, idx, zfsize;
    int *linktab;

    ctdlfile(zapfile, cfg.netdir, "ctdlloop.zap");
    cfg.zap_count = 0;
    zap = NULL;
    if ((zapfl = dopen(zapfile, O_RDWR)) < 0) {
	if ((zapfl = dcreat(zapfile)) < 0)
	    crashout("cannot create zaptable %s", zapfile);
	else
	    dclose(zapfl);
	return;
    }

    zfsize = (1L + dseek(zapfl, 0L, SEEK_END)) / sizeof(zapnode);
    printf("zfsize = %d.\n", zfsize);
    linktab = (int *)xmalloc(zfsize * sizeof(*linktab));

    for (idx = 0; idx < zfsize; idx++)
	linktab[idx] = 0;
    zero_struct(zapnode);

    for (idx = zfsize - 1; idx >= 0;) {
	getx(idx);
	linktab[idx] = 1;
	zh = hash(zapnode.lxaddr);

	zap = (struct zaphash *)realloc(zap, (1+cfg.zap_count) * sizeof zap[0]);
	if (!zap) {
	    printf("Ran out of memory reallocating zaphash!\n");
	    zap = NULL;
	    cfg.zap_count = 0;
	    free(linktab);
	    break;
	}
	zap[cfg.zap_count].zhash = zh;
	zap[cfg.zap_count].zbucket = idx;
	printf("%3d:%-20s%d", cfg.zap_count, zapnode.lxname, idx);

	while (zapnode.lxchain >= 0) {
	    if (linktab[zapnode.lxchain]) {
		printf("-chain rebuild collision at %d.\n", zapnode.lxchain);
		zap = NULL;
		cfg.zap_count = 0;
		free(linktab);
		return;
	    }
	    linktab[zapnode.lxchain] = 1;
	    printf("->%d", zapnode.lxchain);
	    getx(zapnode.lxchain);
	}
	putchar('\n');
	cfg.zap_count++;
	while (idx >= 0 && linktab[idx])
	    --idx;
    }
    printf("%d zaptable entries.\n", cfg.zap_count);
    puts("--------");
    free(linktab);
    dclose(zapfl);
}

int
getx(int i)
{
    zapcur = i;
    dseek(zapfl, zapcur * sizeof zapnode, SEEK_SET);
    dread(zapfl, &zapnode, sizeof(zapnode));
}

int
putx(void)
{
    dseek(zapfl, zapcur * sizeof zapnode, SEEK_SET);
    dwrite(zapfl, &zapnode, sizeof(zapnode));
}

int
msginit(void)
{
    PATHBUF fn;
    ctdlfile(fn, cfg.msgdir, "ctdlmsg.sys");
    if ((msgfl = dcreat(fn)) < 0)
	crashout("Can't create message file %s!", fn);
    realmsginit(msgfl);
    return YES;
}

void
realmsginit(int fl)	/* fl: (opened) file handle to init */
{
    int i;
    unsigned int sect;

    memset(mbsector, 0, BLKSIZE);

    /* put null message in first sector... */
    mbsector[0] = 0xFF;	/*   \				      */
    mbsector[1] =  '1';	/*    >  Message ID "1" MS-DOS style  */
    mbsector[2] =   0;	/*   /				      */
    mbsector[3] =  'M';	/*   \	  Null messsage 	      */
    mbsector[4] =   0;	/*   /				      */

    cfg.newest = cfg.oldest = 1L;
    cfg.catSector = 0;
    cfg.catChar = 5;

    printf("\r%ld bytes to be cleared.\n0",
		(long)BLKSIZE * (long)(cfg.maxMSector));
    fflush(stdout);

    crypte(mbsector, BLKSIZE, 0);	/* encrypt	*/
    if (dwrite(fl, mbsector, BLKSIZE) != BLKSIZE)
	crashout(": write failed");
    crypte(mbsector, BLKSIZE, 0);	/* decrypt	*/

    memset(mbsector, 0, BLKSIZE);

    crypte(mbsector, BLKSIZE, 0);	/* encrypt	*/

    for (sect = 1; sect < cfg.maxMSector; sect++) {
	printf("\r%ld", (long)(1+sect)*(long)BLKSIZE);
	fflush(stdout);
	if (dwrite(fl,mbsector, BLKSIZE) != BLKSIZE)
	    crashout(": write failed");
    }
    putchar('\n');
    crypte(mbsector, BLKSIZE, 0);	/* decrypt	*/
    return;
}

int
roominit(int which)	/* which: Initialise SOME or ALL rooms? */
{
    int i, roomfl;
    PATHBUF roomfile;

    if (which != SOME && which != ALL)		/* Sanity check */
	crashout("roominit() called with incorrect arg %d", which);

    for (i=0; i < MAXROOMS; i++) {
	ctdlfile(roomfile, cfg.roomdir, "room%04d.sys", i);
	/* If we want to blithely nuke all rooms, or if this one is not	*/
	/* found, blort a fresh room into it.				*/
	if (which == ALL || (which == SOME && (!getdirentry(roomfile))))
	    writenewroom(thisRoom = i);
	else		/* The room file exists, so simply load it */
	    getRoom(i);
	if (readbit(roomBuf,INUSE))
	    printf("room %d: %s\n", i, roomBuf.rbname);
	else
	    printf("room %d:\r", i);
	noteRoom();
    }
    return YES;
}

void
writenewroom(int slot)
{
    if (slot < 0 || slot > MAXROOMS - 1)	/* Sanity check */
	crashout("writenewroom() called with illegal arg %d", slot);

    memset(&roomBuf, 0, RB_SIZE);
    verifyroomok(slot);		/* will set up defaults for us if necessary */
    putRoom(slot);
    return;
}

int
loginit(void)
{
    register int i;
    PATHBUF fn;

    ctdlfile(fn, cfg.sysdir, "ctdllog.sys");
    if ((logfl = dcreat(fn)) < 0)
	crashout("Can't create log file %s!", fn);

    memset(&logBuf, 0, LB_SIZE);
    memset(logBuf.lbmail, 0, MAIL_BULK);
    for (i=0; i<MAXROOMS; i++)
	logBuf.lbgen[i] = (logBuf.lbgen[i] & ~CALLMASK) + MAXVISIT-1;

    /* write empty buffer all over file; */
    for (i = 0; i < cfg.logsize; i++) {
	printf("Clearing log #%d\r", i);
	putlog(&logBuf, i, logfl);
	logTab[i].ltnewest = logBuf.lbvisit[0];
	logTab[i].ltlogSlot = i;
	logTab[i].ltnmhash = hash(logBuf.lbname);
	logTab[i].ltpwhash = hash(logBuf.lbpw  );
    }
    putchar('\n');
    return YES;
}

int
floorinit(void)
{
    int i, floorfl;
    PATHBUF fn;

    ctdlfile(fn, cfg.sysdir, "ctdlflr.sys");
    if ((floorfl = dcreat(fn)) < 0)
	crashout("Can't create floor file %s!", fn);
    dclose(floorfl);

    cfg.floorCount = 1;
    floorTab = (struct flTab *)xmalloc(cfg.floorCount * sizeof floorTab[0]);
    zero_struct(floorTab[0]);
    floorTab[i].flInUse = YES;
    floorTab[i].flGen = LOBBYFLOOR;
    strcpy(floorTab[i].flName, lobbyfloor[0] ? lobbyfloor : baseroom);

    printf(" 0: %s\n",floorTab[i].flName);
    updtfloor();

    return YES;
}

void
cleanup(void)
{
    killroomBuf(&roomBuf);
    killlogBuf(&logBuf);
    killnetBuf(&netBuf);

    dclose(msgfl);
    dclose(logfl);
    dclose(netfl);
}

#if 0
mprintf() {}
#endif

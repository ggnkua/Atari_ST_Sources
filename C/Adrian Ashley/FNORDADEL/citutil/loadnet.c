/*
 * loadnet.c - convert the output of dumpnet back into a netTab[]
 *
 * 88Aug07 orc	restore external dialer setting, lastmessage settings
 * 88Jul30 orc	add -NNN flag for setting lastmessage
 * 88Apr27 orc	created.
 */

#include "ctdl.h"
#include "net.h"
#include "room.h"
#include "config.h"
#include "event.h"
#include "citlib.h"

char *program = "loadnet";
long lastmessage;
#if 0
struct logBuffer logBuf;	/* MENTAL! */	/* ????????????? */
#endif

void plusnode();

int
getaline(char *s, FILE *fd)
{
    int rc;
    int idx;

    for (idx=0;idx<80;idx++)
	s[idx] = 0;
    rc = fgets(s,80,fd) ? 1 : 0;
    s[idx=79] = 0;
    while (s[idx] == 0 || s[idx] == '\r' || s[idx] == '\n') {
	s[idx--] = 0;
	if (idx < 0)
	    break;
    }
    return rc;
}

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

void
plusnode(char *line0, FILE *fd)
{
    char *node, *id, *p, *strchr();
    static char line[81];
    long lastin, atol();
    int i, netidhash;
    int rmno;
    LABEL temp;

    /* Following replaces a zero_struct(netBuf); AA 90Jan31 */
    memset(&netBuf, 0, NB_SIZE);
    memset(netBuf.shared, 0, SR_BULK);

    strtok(line0," ");
    node = strtok(NULL,"@");
    id   = strtok(NULL,"\0");
    if (node && id && node[0] && id[0]) {
	if (!NNisok(node))
	    crashout("bad nodename <%s>", node);
	if (netnmidx(node) >= 0)
	    crashout("duplicate node name <%s>", node);
	normID(id, temp);		/* replaces normID() call below */
	netidhash = hash(temp);
#if 0
	for (i=0; i < cfg.netSize; i++)
	    if (netidhash == netTab[i].ntidhash)
		crashout("duplicate node ID <%s> (conflict: slot %d)", id, i);
#endif
    }
    else
	crashout("Bad nodename/node id");

    strcpy(netBuf.netName, node);
    strcpy(netBuf.netId,   id);
    set(netBuf,N_INUSE);

    printf("creating node %s @ %s\n", node, id);

    getaline(line,fd);
    if (strncmp(line, "mypw", 4) != 0)
	crashout("bad mypw line (%s) in node %s", line, node);
    p = strtok(line, " ");
    p = strtok(NULL, "\0");
    if (p)
	strcpy(netBuf.myPasswd, p);

    getaline(line,fd);
    if (strncmp(line, "herpw", 5) != 0)
	crashout("bad herpw line (%s) in node %s", line, node);
    p = strtok(line, " ");
    p = strtok(NULL, "\0");
    if (p)
	strcpy(netBuf.herPasswd, p);
        
    getaline(line,fd);
    sscanf(line, "%lx", &netBuf.flags);

    getaline(line,fd);
    netBuf.baudCode = line[0]-'0';
    for (p=strtok(1+line,","); p; p=strtok(NULL,","))
	switch (p[0]) {
	case 'L':
	    netBuf.ld = atoi(1+p);
	    break;
	case 'D':
	    netBuf.dialer = atoi(1+p);
	    break;
	}

    getaline(line,fd);
    if (strncmp(line, "access", 6) != 0)
	crashout("bad access line (%s) in node %s", line, node);
    p = strtok(line, " ");
    p = strtok(NULL, "\0");
    if (p)
	strcpy(netBuf.access, p);
        
    getaline(line,fd);
    sscanf(line, "%lx,%x",&netBuf.what_net, &netBuf.poll_day);

    netTab = realloc(netTab, (++cfg.netSize) * sizeof(*netTab));
    netTab[cfg.netSize-1].Tshared = (struct netroom *) xmalloc(SR_BULK);
    memset(netTab[cfg.netSize-1].Tshared, 0, SR_BULK);	/* AA 91Jan21 */

    /* normID() and hash() moved up a ways */
    netTab[cfg.netSize-1].ntnmhash = hash(netBuf.netName);
    netTab[cfg.netSize-1].ntidhash = netidhash;
    for (i=0; i<SHARED_ROOMS; i++)
	netBuf.shared[i].NRidx = -1;
    
    for (i=0; getaline(line,fd); i++) {
	if ((strlen(line) < 1) || (strncmp(line, "#node", 5) == 0))
	    break;					/* Sanity check */
	if (p=strchr(line, '\t')) {
	    *p++ = 0;
	    while (*p == ' ' || *p == '\t')
		++p;
	    lastin = atol(p);
	    if (lastin > cfg.newest)
		lastin = cfg.newest;
	}
	else lastin = lastmessage;
	
	if (i < SHARED_ROOMS) {
	    printf("sharing %s\n", line);
	    if ((rmno = roomExists(line)) >= 0) {
		netBuf.shared[i].NRidx = rmno;
		netBuf.shared[i].NRlast= lastin;
		netBuf.shared[i].NRgen = roomTab[rmno].rtgen;
		netBuf.shared[i].NRhub = netBuf.ld ? 1 : 0;
		if (!readbit(roomTab[rmno],SHARED)) {
		    getRoom(rmno);
		    set(roomBuf,SHARED);
		    noteRoom();
		    putRoom(rmno);
		}
	    }
	    else
		fprintf(stderr, "room %s does not exist!\n", line);
	}
    }
    putNet(cfg.netSize-1);
}

/*
 * writeNet(): write up nodes on the net.  Format:
 *
 *	#node name@id
 *	mypw myPasswd
 *	herpw herPasswd
 *	flags
 *	baud,dialer,ld
 *	access
 *	whatnet,poll-days
 *	[rooms shared]
 *		.
 *		.
 *		.
 *	<blank line>
 */
void
loadnodes(FILE *fd)
{
    static char line[80];

    while (getaline(line,fd)) {
	if (strncmp(line,"#node",5) != 0)
	    continue;
	plusnode(line, fd);
    }
    printf("loaded %d node%s\n", cfg.netSize, (cfg.netSize != 1)?"s":"");
}

/*
 * roomExists(): returns slot# of named room
 */
int
roomExists(char *room)
{
    int i;

    for (i = 0; i < MAXROOMS; i++)
	if (readbit(roomTab[i],INUSE) && stricmp(room, roomTab[i].rtname) == 0)
	    return i;
    return ERROR;
}

main(int argc, char **argv)
{
    static char temp[200];
    char c;
    FILE *listing, *fopen();
    long atol();

    printf("%s for Fnordadel V%s\n", program, VERSION);

    lastmessage = 0L;
    if (argc > 1 && argv[1][0] == '-') {
	++argv, --argc;
	lastmessage = atol(1 + *argv);
    }

    if (argc != 2)
	crashout("usage: loadnet [-last-message] [net-list-file]");
    if ((listing=fopen(argv[1],"r")) == NULL)
	crashout("loadnet: cannot open `%s'", argv[1]);
    fflush(stdin);
    printf("\007WARNING!!! This program will wipe all* traffic pending on\
 your network!!\nContinue (Y/N)? ");
    c = getchar();
    if (c != 'Y' && c != 'y') {
	if (fromdesk())
	    hitkey();
	exit(0);
    }
    if (readSysTab(YES)) {

	initnetBuf(&netBuf);
	initroomBuf(&roomBuf);

	if (lastmessage < 0) {
	    lastmessage = cfg.newest + lastmessage;
	    if (lastmessage < cfg.oldest)
		lastmessage = cfg.oldest;
	}
	else if (lastmessage == 0 || lastmessage > cfg.newest)
	    lastmessage = cfg.newest;

	ctdlfile(temp, cfg.netdir, "ctdlnet.sys");
	drename(temp,"ctdlnet.tmp");
	free(netTab);
	cfg.netSize = 0;
	netTab = malloc(0);
	dunlink(temp);
	if ((netfl = dcreat(temp)) < 0)
	    crashout("can't open netfile");
	loadnodes(listing);
	fclose(listing);
	writeSysTab();
	dclose(netfl);
    }
    if (fromdesk())
	hitkey();
}

/*
 * netmap.c - generate roomsharing maps for a system
 *
 * 88Jul30 orc	Add -p flag to only list public rooms
 * 88Jun21 orc	Created.
 */

#include "ctdl.h"
#include "net.h"
#include "room.h"
#include "config.h"
#include "citlib.h"

char *program = "netmap";
char private=YES;
struct alias *net_alias;	/* changed from char * by AA 90Dec14 */

void
normalise(s)
char *s;
{
    char *pc = s;

    /* find end of string   */
    while (*pc)   {
	if (*pc < ' ')
	    *pc = ' ';   /* zap tabs etc... */
	pc++;
    }

    /* no trailing spaces: */
    while (pc>s && isspace(*(pc-1)))
	pc--;
    *pc = 0;

    /* no leading spaces: */
    while (*s == ' ') {
	for (pc=s; *pc; pc++)
	    *pc = *(pc+1);
    }

    /* no double blanks */
    for (; *s;) {
	if (*s == ' ' && *(s+1) == ' ') {
	    for (pc=s; *pc; pc++)
		*pc = *(pc+1);
	}
	else s++;
    }
}

void
sharelist(place)
int place;
{
    int i, rm, room;
    char *rmalias, *rmname;

    getNet(place);
    for (rm=i=0; i<SHARED_ROOMS; i++)  {
	room = netBuf.shared[i].NRidx;
	if (room >= 0 && roomTab[room].rtgen == netBuf.shared[i].NRgen) {
	    if (private || readbit(roomTab[room],PUBLIC)) {
		rmname = roomTab[room].rtname;
		rmalias= chk_alias(net_alias, place, rmname);

		if (rm == 0)
		    printf(" %s", netBuf.netName);
		printf( (rmname!=rmalias) ? "%s %s(%s)" : "%s %s",
			(rm%3 == 0) ? "\n\t" : ",", rmname, rmalias);
		if (netBuf.shared[i].NRhub)
		    putchar('*');
		rm++;
	    }
	}
    }
    if (rm > 0)
	putchar('\n');
}

main(argc, argv)
char **argv;
{
    register i;
    PATHBUF temp;

    if (argc > 1 && stricmp(argv[1], "-P") == 0)
	private = NO;

    if (readSysTab(FALSE)) {
    
	printf("%s for %s (Fnordadel V%s)\n", program,
		&cfg.codeBuf[cfg.nodeName], VERSION);
	initnetBuf(&netBuf);

	ctdlfile(temp, cfg.netdir, "ctdlnet.sys");
	if ((netfl = dopen(temp, O_RDWR)) < 0)
	    crashout("can't open netfile");

	ctdlfile(temp, cfg.netdir, "alias.sys");
	net_alias = load_alias(temp);

	for (i=0; i<cfg.netSize; i++)
	    if readbit(netTab[i],N_INUSE)
		sharelist(i);

    }
    if (fromdesk())
	hitkey();
}

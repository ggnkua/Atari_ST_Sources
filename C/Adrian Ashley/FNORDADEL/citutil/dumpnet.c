/*
 * dumpnet.c -- make an ascii printout of the netlist for easy transfer
 *		between versions of Fnordadel
 *
 * 88Aug07 orc	add last-message & external dialer stuff to dump
 * 88Apr27 orc	created
 */

#include "ctdl.h"
#include "net.h"
#include "event.h"
#include "config.h"
#include "room.h"
#include "citlib.h"

extern char VERSION[];

char *program = "dumpnet";
FILE *outfl;

void
dumprooms()
{
    int i, room;

    for (i = 0; i < SHARED_ROOMS; i++) {
	room = netBuf.shared[i].NRidx;
	if (room >= 0 && roomTab[room].rtgen == netBuf.shared[i].NRgen)
	    fprintf(outfl, "%s\t%ld\n", roomTab[room].rtname, 
		netBuf.shared[i].NRlast);
    }
}

/*
 ************************************************
 *	writeNet() write up nodes on the net.	*
 *	format:					*
 *		#node name@id			*
 *		mypw myPasswd			*
 *		herpw herPasswd			*
 *		flags				*
 *		baud,dialer,ld			*
 *		access <access>			*
 *		whatnet,poll-days		*
 *		[rooms shared]			*
 *		.				*
 *		.				*
 *		.				*
 *		blank line			*
 ************************************************
 */
void
dumpnodes()
{
    int i;

    for (i = 0; i < cfg.netSize; i++) {
	getNet(i);
	if readbit(netBuf,N_INUSE) {
	    fprintf(outfl, "#node %s@%s\n",netBuf.netName, netBuf.netId);
	    fprintf(outfl, "mypw %s\n", netBuf.myPasswd);
	    fprintf(outfl, "herpw %s\n", netBuf.herPasswd);
	    fprintf(outfl, "%08lx\n", netBuf.flags);
	    fprintf(outfl, "%d,L%d,D%d\n", netBuf.baudCode, netBuf.dialer,
		netBuf.ld);
	    fprintf(outfl, "access %s\n", netBuf.access);
	    fprintf(outfl, "%08lx,%02x\n",netBuf.what_net, netBuf.poll_day);

	    dumprooms();
	    fputc('\n', outfl);
	}
    }
}

main(argc, argv)
int argc;
char *argv[];
{
    PATHBUF filename;

    printf("%s for Fnordadel V%s\n\n", program, VERSION);
    if (readSysTab(FALSE)) {
	initnetBuf(&netBuf);
	ctdlfile(filename, cfg.netdir, "ctdlnet.sys");
	netfl = dopen(filename,O_RDONLY);
	if (netfl < 0)
	    crashout("can't open %s", filename);
	if (argc >= 2) {
	    if ((outfl = fopen(argv[1], "w")) == NULL)
		crashout("can't open output file '%s'", argv[1]);	
	} else
	    outfl = stdout;
	dumpnodes();
	dclose(netfl);
	if (outfl != stdout)
	    fclose(outfl);
    }
    if (fromdesk())
	hitkey();
}

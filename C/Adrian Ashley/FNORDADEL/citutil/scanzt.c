/*
 * scanzt.c -- Display information from zaploop tables
 *
 * 91Jan03 AA	Hacked to recognise new stored values (gen, nodename, lastid)
 * 88Jun20 orc	Created.
 */

#include "ctdl.h"
#include "zaploop.h"
#include "room.h"
#include "config.h"
#include "citlib.h"

char *program = "scanzt";

static struct zaploop zapnode;
static int zapdbx;
static int zapcur = ERROR;

char usingWCprotocol=0;
int (*sendPFchar)();

/*
 * init_zap() - open the zaploop database
 */
void
init_zap(void)
{
    PATHBUF zapfile;

    ctdlfile(zapfile, cfg.netdir, "ctdlloop.zap");

    if ((zapdbx = dopen(zapfile,O_RDWR)) < 0)
	printf("cannot open %s\n", zapfile);
}

static void
getx(int bucket)
{
    zapcur = bucket;
    dseek(zapdbx, zapcur * sizeof zapnode, SEEK_SET);
    dread(zapdbx, &zapnode, sizeof(zapnode));
}

main()
{
    int i, gotvalid = NO;
    char *fmt   = "%-20.19s%-14.14s%-20.19s%-17.16s%8ld\n";
    char *title = "%-20.19s%-14.14s%-20.19s%-17.16s%8s\n";

/*    setbuf(stdout, NULL); */
    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (readSysTab(FALSE)) {
	init_zap();
	putchar('\n');
	printf(title, "Node Name", "Node ID", "Room", "Date/Time", "Msg ID");
	putchar('\n');
	for (i = 0; i < cfg.zap_count; i++) {
	    gotvalid = NO;
	    getx(zap[i].zbucket);
	    if (roomTab[zapnode.lxroom].rtgen == zapnode.lxgen) {
		printf(fmt, zapnode.lxname, zapnode.lxaddr, 
		    roomTab[zapnode.lxroom].rtname,
		    makedate(zapnode.lxlast, YES), zapnode.lxlastid);
		gotvalid = YES;
	    }
	    while (zapnode.lxchain >= 0) {
		getx(zapnode.lxchain);
		if (roomTab[zapnode.lxroom].rtgen == zapnode.lxgen) {
		    if (!gotvalid)
			printf(fmt, zapnode.lxname, zapnode.lxaddr, 
			    roomTab[zapnode.lxroom].rtname,
			    makedate(zapnode.lxlast, YES), zapnode.lxlastid);
		    else
			printf(fmt, "", "", roomTab[zapnode.lxroom].rtname,
			    makedate(zapnode.lxlast, YES), zapnode.lxlastid);
		    gotvalid = YES;
		}
	    }
	    putchar('\n');
	}
    }
    if (fromdesk())
	hitkey();
}

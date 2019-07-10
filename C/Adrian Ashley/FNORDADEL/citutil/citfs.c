/*
 * citfs.c -- spool file send/receive requests outside citadel
 *
 * 91Jan13 AA	Now echoes spooling information to the console.
 * 90Jul21 AA	Created.
 */

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "citlib.h"

char *program = "citfs";
char *usage = "usage: \n\t`%s -s <system> <file1> ... [fileN]' to send;\n\
\t`%s -r <system> <room> <targetdir> <file1> ... [fileN]' to receive\n";

#define SEND 1
#define REQUEST 2

#define ENOERR 0

void
nfs_put(int place, int cmd, char *file, char *dir, char *room)
{
    FILE *nfs;
    PATHBUF filename;
    char line[256];

    ctdlfile(filename, cfg.netdir, "%d.nfs", place);
    if (nfs=safeopen(filename, "a")) {
	switch (cmd) {
	case FILE_REQUEST:
	    sprintf(line, "REQUEST %s %s %s\n", file, dir, room);
	    fputs(line, nfs);
	    printf(line);
	    break;
	case SEND_FILE:
	    sprintf(line, "SEND %s\n", file);
	    fputs(line, nfs);
	    printf(line);
	    break;
	}
	getNet(place);
	if (!readbit(netBuf,FILEPENDING)) {
	    set(netBuf,FILEPENDING);
	    putNet(place);
	}
	fclose(nfs);
    }
    else
	printf("cannot open `%s'\n ", filename);
}

int
main(int argc, char **argv)
{
    LABEL system, room, destdir;
    PATHBUF filename;
    char *p;
    int mode, arg, netidx;

    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (argc < 4)	/* can't do anything with this... */
	crashout(usage, program, program);

    if (readSysTab(FALSE)) {
	p = argv[1];
	if (*p == '-') {
	    switch(tolower(*(++p))) {
	    case 's':	mode = SEND;
			break;
	    case 'r':	mode = REQUEST;
			if (argc < 6)
			    crashout(usage, program, program);
			break;
	    default: crashout(usage, program, program); /*NOTREACHED*/
	    }
	}
	else
	    crashout(usage, program, program);

	initnetBuf(&netBuf);

	ctdlfile(filename, cfg.netdir, "ctdlnet.sys");
	if ((netfl = dopen(filename, O_RDWR)) < 0)
	    crashout("can't open netfile `%s'", filename);

	strcpy(system, argv[2]);
	if ((netidx = netnmidx(system))	== ERROR)
	    crashout("Bad system `%s'", argv[2]);

	if (mode == REQUEST) {
	    strcpy(room, argv[3]);
	    strcpy(destdir, argv[4]);
	    if (cd(destdir) != ENOERR)
		crashout("Bad target directory `%s'", destdir);
	    arg = 5;
	}
	else	/* mode == SEND */
	    arg = 3;

	for ( ; arg < argc; arg++) {
	    if (mode == REQUEST)
		nfs_put(netidx, FILE_REQUEST, argv[arg], destdir, room);
	    else	/* mode == SEND */
		if (getdirentry(argv[arg]))
		    nfs_put(netidx, SEND_FILE, argv[arg], NULL, NULL);
		else
		    printf("File `%s' not found\n", argv[arg]);
	}
	dclose(netfl);
	killnetBuf(&netBuf);
	writeSysTab();	/* added by AA 90Aug31 -- must save FILEPENDING flag */
    }
    if (fromdesk())
	hitkey();
}

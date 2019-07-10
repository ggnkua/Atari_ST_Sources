/*
 * nfs.c - network send/requestfile functions
 *
 * 90Aug31 AA	C86-style file request support added.
 * 88Jul16 orc	Created.
 */

#include "ctdl.h"
#include "net.h"
#include "dirlist.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

/*
 * nfs_put()		spool a file request
 * * nf_request()	ask for file(s) from caller
 * * netsendsingle()	send a single file
 * * nf_send()		fling files across the net
 * nfs_process()	process file requests
 */

/*
 * nfs_put() - spool a file request for the specified netnode
 */
void
nfs_put(int place, int cmd, char *file, char *dir, char *room)
{
    FILE *nfs;
    char *filename = msgBuf.mbtext;

    ctdlfile(filename, cfg.netdir, "%d.nfs", place);
    if (nfs=safeopen(filename, "a")) {
	switch (cmd) {
	case FILE_REQUEST:
	    fprintf(nfs, "REQUEST %s %s %s\n", file, dir, room);
	    break;
	case SEND_FILE:
	    fprintf(nfs, "SEND %s\n", file);
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
	mprintf("cannot open %s\r", filename);
}

/*
 * nf_request() - ask for file(s) from caller
 */
static void
nf_request(char *room, char *file, char *direct)
{
    int status, nullheader, count = 0;
    LABEL fn;

    if (!netchdir(direct))
	return;

/* C86-style file requests added by AA 90Aug31 */
    if (readbit(netBuf,CIT86)) {
	if (netcommand(FILE_REQUEST, room, file, NULL)) {
	    splitF(netLog, "C86-style request file `%s' from room `%s'.\n",
		file, room);
	    neterror(NO, "C86-style request file `%s' from room `%s'.\n",
		file, room);
	    do {
		counter = 0;	/* <THWACK>	AA 90Sep10 */
		if (enterfile(increment, usingWCprotocol) && gotcarrier()) {
		    if (!(nullheader = !(sectBuf[0]))) {
			count = 0;
			strcpy(fn, sectBuf);
			splitF(netLog, "Receiving file `%s'.\n", fn);
			while (getdirentry(fn))
			   sprintf(fn, "a.%d", count++);
			upfd = safeopen(fn, "wb");
			status = enterfile(sendARchar, usingWCprotocol);
			fclose(upfd);
			if (status)	/* did the thingie succeed? */
			    neterror(NO, count ?
				"Received file `%s' (saved as `%s')." :
				"Received file `%s'.", sectBuf, fn);
			else		/* nope, guess not. */
			    dunlink(fn);
		    }
		}
		else
		    nullheader = YES;	/* if anything goofs up, bail out */
	    } while (gotcarrier() && !nullheader);
	}
    }
    else {
	if (netcommand(BATCH_REQUEST, room, file, NULL)) {
	    splitF(netLog, "Request file `%s' from room `%s'.\n", file, room);
	    neterror(NO, "Request file `%s' from room `%s'.\n", file, room);
	    batchWC = YES;
	    while ((status=recXfile(sendARchar)) == 0)
		;
	    batchWC = NO;
	}
    }

    homeSpace();
}

/*
 * netsendsingle() - send a file
 */
static int
netsendsingle(struct dirList *fn)
{
    FILE *fd;
    LABEL size;
    int status = 1;

    if (fd = safeopen(fn->fd_name, "rb")) {
	sprintf(size, "%ld", fn->fd_size);
	splitF(netLog, "Sending file `%s' (%s).\n",
			fn->fd_name, plural("byte", fn->fd_size));
	neterror(NO, "Sending file `%s' (%s).\n",
			fn->fd_name, plural("byte", fn->fd_size));
	status = netcommand(SEND_FILE, fn->fd_name, "1", size, NULL)
			&& typeWC(fd);
	fclose(fd);
    }
    return status;
}

/*
 * nf_send() - fling files across the net
 */
static void
nf_send(char *pathspec)
{
    char *p, *strrchr();
    LABEL filename;

    if (p=strrchr(pathspec,'\\')) {
	*p++ = 0;
	copystring(filename, p, NAMESIZE);
    }
    else if (p = strrchr(pathspec, ':')) {
	copystring(filename, ++p, NAMESIZE);
	*p = 0;
    }
    else {
	copystring(filename, pathspec, NAMESIZE);
	*pathspec = 0;
    }
    if (netchdir(pathspec)) {
	wildcard(netsendsingle, filename, 0L);
	homeSpace();
    }
}

/*
 * nfs_process() - process file requests
 */
void
nfs_process(void)
{
    FILE *nfs, *ffs;
    char thisline[160];
    char *cmd, *file, *dir, *room;
    PATHBUF filename;
    PATHBUF failname;

    ctdlfile(filename, cfg.netdir, "%d.nfs", rmtslot);
    if (nfs=safeopen(filename,"r")) {
	while (fgets(thisline, 158, nfs) && gotcarrier())
	    if (cmd = strtok(thisline, "\t "))
		switch (*cmd) {
		case 'S':
		    if (file=strtok(NULL,"\t\n "))
			nf_send(file);
		    break;
		case 'R':
		    file = strtok(NULL, "\t ");
		    dir  = strtok(NULL, "\t ");
		    room = strtok(NULL, "\n");
		    if (room)
			nf_request(room, file, dir);
		    break;
		}
	if (gotcarrier()) {
	    clear(netBuf,FILEPENDING);
	    fclose(nfs);
	    dunlink(filename);
	}
	else {
	    /*
	     * lost carrier -- respool the rest of the requests.
	     */
	    ctdlfile(failname, cfg.netdir, "$pending");
	    if (ffs = safeopen(failname, "w")) {
		while (fgets(thisline,158,nfs))
		    fputs(thisline, ffs);
		fclose(nfs);
		fclose(ffs);
		dunlink(filename);
		drename(failname, filename);
	    }
	}
    }
    else	/* there was no .nfs file, so there can't have been anything */
	clear(netBuf,FILEPENDING);	/* pending, really... */
}


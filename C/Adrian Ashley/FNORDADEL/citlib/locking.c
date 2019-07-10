/************************************************************************
 *			      locking.c					*
 *		     Locking routines for citadel			*
 *									*
 * 90Aug27 AA	Renamed from liblock.c					*
 * 88Feb09 orc	Created.						*
 *									*
 ************************************************************************/

#include "ctdl.h"
#include "config.h"
#include "citlib.h"

char LOCKFILE[] = "CITADEL.LCK";

int
makelock(p)
int *p;
{
    PATHBUF tmp;
    int tp;

    ctdlfile(tmp, cfg.sysdir, LOCKFILE);
    dunlink(tmp);

    if ((tp=dopen(tmp,O_RDONLY)) >= 0) {
	dclose(tp);
	fprintf(stderr, "Citadel is active!\n");
	return 0;
    }
    return ((*p = dcreat(tmp)) >= 0);
}

void
wipelock(p)
int *p;
{
    PATHBUF tmp;

    dclose(*p);
    ctdlfile(tmp, cfg.sysdir, LOCKFILE);
    dunlink(tmp);
}

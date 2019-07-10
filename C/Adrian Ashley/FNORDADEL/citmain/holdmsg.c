/*
 * hold.c - Store a message away for a rainy day
 *
 * 90Nov08 AA	Borrowed from STadel 3.4a
 */

#include "ctdl.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"

char holdtemplate[] = "hold%04x";

FILE *safeopen();

int
puthold(int idx)
{
    PATHBUF hold;
    FILE *spl;

    ctdlfile(hold, cfg.holddir, holdtemplate, idx);
    if (spl = safeopen(hold, "wb")) {
	_spool(spl);
	fclose(spl);
	return YES;
    }
    return NO;
}

int
gethold(int idx)
{
    PATHBUF hold;
    FILE *spl;

    ctdlfile(hold, cfg.holddir, holdtemplate, idx);
    if (spl = safeopen(hold, "rb")) {
	getspool(spl);
	fclose(spl);
	dunlink(hold);
	return YES;
    }
    return NO;
}

void
killhold(int idx)
{
    PATHBUF hold;

    /*puts("killhold");*/
    ctdlfile(hold, cfg.holddir, holdtemplate, idx);
    dunlink(hold);
}

int
chkhold(int idx)
{
    PATHBUF hold;
    FILE *f;

    /*puts("chkhold");*/
    ctdlfile(hold, cfg.holddir, holdtemplate, idx);
    if (f=safeopen(hold, "r")) {
	fclose(f);
	return YES;
    }
    return NO;
}

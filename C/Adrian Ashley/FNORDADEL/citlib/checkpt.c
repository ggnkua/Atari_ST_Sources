/*
 * checkpt.c -- ctdlmsg.sys checkpointing for Fnordadel
 *
 * 91Jun03 AA	Created.
 */

#include "config.h"
#include "ctdl.h"

extern struct config cfg;
static char *checkfn = "checkpt.sys";

/* Write cfg.newest, cfg.catSector and cfg.catChar */

void
write_checkpoint()
{
	PATHBUF fn;
	FILE *f;

	ctdlfile(fn, cfg.sysdir, checkfn);
	f = fopen(fn, "w");
	if (f == NULL)
		return;
	fprintf(f, "%ld\n%hd\n%hd\n", cfg.newest, cfg.catSector, cfg.catChar);
	fclose(f);
	return;
}

int
read_checkpoint(long *newest, short *catsector, short *catchar)
{
	PATHBUF fn;
	FILE *f;
	int r;

	ctdlfile(fn, cfg.sysdir, checkfn);
	f = fopen(fn, "r");
	if (f == NULL)
		return NO;
	r = fscanf(f, "%ld %hd %hd", newest, catsector, catchar);
	fclose(f);
	if (r != 3)
		return NO;
	return YES;
}

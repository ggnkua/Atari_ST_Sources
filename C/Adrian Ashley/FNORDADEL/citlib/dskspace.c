/*
 * dskspace.c
 *
 * 90Aug27 AA	Split from libdep.c
 */

#include "ctdl.h"
#include <osbind.h>

int
diskSpaceLeft(path, sectors, bytes)
char *path;
long *bytes;
long *sectors;
{
    struct {
	long b_free;
	long b_total;
	long b_secsiz;
	long b_clsiz;
    } freespace;
    int drive;

    if (path[1] == ':' && path[0])
	drive = toupper(path[0]) - '@';
    else
	drive = 0;
    Dfree(&freespace, drive);

    *bytes = freespace.b_free * freespace.b_secsiz * freespace.b_clsiz;
    *sectors = ((*bytes) + (long)(SECTSIZE-1)) / (long)(SECTSIZE);
    return TRUE;
}

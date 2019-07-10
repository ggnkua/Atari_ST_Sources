/*
 * getcd.c
 *
 * 90Aug27 AA	Split from libdep.c
 */

#include "ctdl.h"
#include <osbind.h>

void
getcd(path)
PATHBUF path;
{
    strcpy(path,"A:");
    path[0] += Dgetdrv();
    Dgetpath(&path[2],0);
    if (!path[2])
	(void)strcpy(&path[2], "\\");
}

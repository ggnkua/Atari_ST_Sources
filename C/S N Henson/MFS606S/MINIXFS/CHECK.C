/* This File is part of Minixfs, Copyright 1991,1992,1993 S.N.Henson */

#include "minixfs.h"
#include "global.h"
#include "proto.h"

/* Range checkers, see if inode/zone read ranges are allowed:
 * if STRICT is set halt system on error, otherwise just print
 * out an alert.
 */

#ifdef STRICT
#define badfilesys()	l_sync(); FATAL("Minixfs: Bad Filesystem, Reboot \
and run fsck");
#else
#define badfilesys()	ALERT("Minixfs: Bad Filesystem, Repair with fsck")
#endif

void chk_zone(start,count,drive)
long start;
int count,drive;
{
	super_info *psblk=super_ptr[drive];
	if(start < psblk->sblk.s_firstdatazn ||
		start+count > psblk->sblk.s_zones)
	{
		ALERT("Minixfs Zone Range Error Drive %c Zone %ld Count %d",
		drive+'A',start,count);
		badfilesys();
	}
	return;
}

void chk_iblock(start,psblk)
long start;
super_info *psblk;
{
	if(start < psblk->ioff || start >= psblk->sblk.s_firstdatazn)
	{
		ALERT("Minixfs Inode Range Error Drive %c Block %ld",
	psblk->dev+'A',start);
		badfilesys();
	}
	return;
}


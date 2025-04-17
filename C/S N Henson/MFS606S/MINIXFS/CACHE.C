/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N. Henson */

#include "minixfs.h"
#include "global.h"
#include "proto.h"

/* For this kind of file system a cache is absolutely essential ,
without it your hard-disk will sound like a buzz-saw .... the 
idea is fairly simple , for every block requested if it is not in 
the cache load it in at the current position .Then return a 
pointer to the block . Additionally all writes go to the cache if
an entry exists for the specified block . This means that when a 
cache entry is overwritten we must write out the entry if it is
'dirty' , the function l_sync() writes out the entire cache along
with the zone and inode bitmaps. All functions , except write , call
l_sync() on each call . Write calls l_sync() only after a certain
amount of data has been written , this stops lots of little writes
taking too much time .... However for an increase in performance , 
three caches are used , one for inodes one for directories and indirection 
blocks , one for files , these are kmalloc()'ed at the same time so that 
one follows the other in memory , this simplifies cache-flushing for example.
*/

/* Initialise cache */
int init_cache()
{
	cache *ctemp;
	long i;
		/* Start with system cache */
	ctemp=Kmalloc((icache_size+scache_size+ucache_size)*(SIZEOF(cache)+BLOCK_SIZE));
	if(!ctemp)
	{
		CCONWS("Can't Allocate Cache: Using defaults");
		ctemp=Kmalloc((ICACHE_SIZE+SCACHE_SIZE+UCACHE_SIZE)*(SIZEOF(cache)+BLOCK_SIZE));
		if(!ctemp)
		{
			CCONWS("Can't Allocate Default Cache: Minixfs not installed");
			return 1;
		}
		icache_size=ICACHE_SIZE;
		ucache_size=UCACHE_SIZE;
		scache_size=SCACHE_SIZE;
	}

	syscache.start=ctemp;
	syscache.end=&ctemp[scache_size];
	syscache.pos=syscache.start;
	icache.start=syscache.end;
	icache.end=&icache.start[icache_size];
	icache.pos=icache.start;
	usrcache.start=icache.end;
	usrcache.pos=usrcache.start;
	usrcache.end=&usrcache.start[ucache_size];
	/* Invalidate all entries , initialise buffer pointers */
	for(ctemp=syscache.start,i=0;ctemp!=usrcache.end;ctemp++,i++)
	{
		ctemp->buffer= ((bufr *)(usrcache.end))+i;
		ctemp->status=0;
	}

/* Initialise dummy guess */
	dummy.iguess=icache.start;
	dummy.zguess=usrcache.start;
	dummy.izguess=syscache.start;
	dummy.dizguess=syscache.start;

	return 0;
}


void
l_sync()
{
    cache *p;
    int i;
/* Write out dirty cache entries */
    for(p=syscache.start;p!=usrcache.end;p+=writeout(&usrcache,p)) continue;

    /* Now inode and zone bitmaps */
    for(i=0;i<NUM_DRIVES;i++)
    {
	if(super_ptr[i]) {
		super_info *psblk;
		psblk=super_ptr[i];
		if(psblk==DFS) continue;

		if(psblk->idirty && psblk->zdirty)
			crwabs(3,psblk->ibitmap,psblk->sblk.s_imap_blks+
				psblk->sblk.s_zmap_blks,2,i);
		else
		{
			if(psblk->idirty)
			   crwabs(3,psblk->ibitmap,psblk->sblk.s_imap_blks,2,i);
		 	if(psblk->zdirty)
			     crwabs(3,psblk->zbitmap,psblk->sblk.s_zmap_blks,
						   psblk->sblk.s_imap_blks+2,i);
		}
		psblk->idirty=0;
		psblk->zdirty=0;
	}
    }
}

/* Return cache entry for numr,drive if it exists or NULL, this uses a 'guess'
 * pointer for the caches: start at the point an entry was last found, this
 * should be reduce cache searching a bit.
 */

cache *in_cache(numr,drive,control,guess)
long numr;
int drive;
cache_control *control;
cache **guess;
{
	cache *p;

	if(guess)
	{

		for(p=*guess;p!=control->end;p++)
			if((p->block==numr) && (p->drive==drive) && p->status)
							return (*guess=p);
		for(p=control->start;p!=*guess;p++)
			if((p->block==numr) && (p->drive==drive) && p->status)
							return (*guess=p);
	}
	else
	{
		for(p=control->start;p!=control->end;p++)
			if((p->block==numr) && (p->drive==drive) && p->status)
							return p;
	}

	return NULL;
}

/* Return a pointer to block numr,drive loading and updating cache if needed */

bufr *cget_block(numr,drive,control)
long numr;
int drive;
cache_control * control;
{
	return(cache_get(numr,drive,control,NOGUESS)->buffer);
}

/* Return a pointer to a cache entry buffer for numr,drive with the dirty 
 * flag set, if not in cache create a new entry but do *not* read in data
 * from the disk, this is useful for example when an entire disk block will
 * be written in one go.
 */

cache *cache_put(numr,drive,control)
long numr;
int drive;
cache_control *control;
{
	cache *p;
	if(!(p=in_cache(numr,drive,control,NOGUESS)))
	{
		if(control!=&icache) chk_zone(numr,1,drive);
		if(control->pos==control->end) control->pos=control->start;
		p=control->pos++;
		writeout(control,p);
		p->drive=drive;
		p->block=numr;
	}

	p->status=2;
	return (p);
}

cache *
cache_get(numr,drive,control,guess)
long numr;
int drive;
cache_control *control;
cache **guess;
{
	cache *p;
	if( (p=in_cache(numr,drive,control,guess)) )return(p);
	/* Read block in */
	if(control->pos==control->end)
		control->pos=control->start;
	/* Write out dirty entries before they are overwritten */
	if(control->pos->status >1 ) writeout(control,control->pos);

	/* This is the only check done on I/O into cache. If invalid
	 * blocks can never enter the cache then all should be OK
	 * later on. Unless the memory gets trashed. Interesting hack:
	 * if iblock is in range and all inode blocks are used (as will
	 * usually be the case) then the inode number producing it should
	 * be in range too, so no checking on inode numbers need be done.
	 */

	if(control==&icache) chk_iblock(numr,super_ptr[drive]);
	else chk_zone(numr,1,drive) ;


	crwabs(2,control->pos->buffer,1,numr,drive);
	/* Update Cache */
	control->pos->drive=drive;
	control->pos->block=numr;
	control->pos->status=1;

	if(guess) *guess=control->pos;
	return ( control->pos++ );
}

/* Write out block, search cache and if 'hit' update and mark as dirty 
 * after copying the data across, otherwise flush current entry.
 */

int
cput_block(numr,drive,buf,control)
long numr;
int drive;
void *buf;
cache_control *control;
{
	cache *p;

	if( (p=in_cache(numr,drive,control,NOGUESS)) ){
		if(buf!=p->buffer) bcopy(buf,p->buffer,BLOCK_SIZE);
		p->status=2;
		return 0;
	}

	if(control->pos==control->end) control->pos=control->start;
	writeout(control,control->pos);

	if(control!=&icache) chk_zone(numr,1,drive);

	bcopy(buf,control->pos->buffer,BLOCK_SIZE);
	/* Update Cache */
	control->pos->drive=drive;
	control->pos->block=numr;
	control->pos->status=2;
	control->pos++;
	return 0;
}

/* From the cache-pointer 'p' write out dirty entries that are consecutive
 * all in one go, this should cut down on I/O quite a lot.
 */

long writeout(control,p)
cache_control *control;
cache *p;
{
	cache *q;
	long i;

	if(p->status<2) return 1;
	/* Determined how many blocks are consecutive */
	for(q=p,i=0;q!=control->end;q++,i++)
	{
		if( (q->drive!=p->drive) || (q->block!=p->block+i) || 
			(q->status < 2) ) break;
		q->status=1;
	}

	crwabs(3,p->buffer,i,p->block,p->drive);

	return i;
}

/* From the current cache position, read up to the num zones pointed to by
 * zone_list in. Flush the cache and read in as much as possible in one go.
 * Stop at first non-consecutive zone.
 */

long readin(zone_list,num,drive,control)
long *zone_list;
int num;
int drive;
cache_control *control;
{
	cache *p;
	int i,j;

	if(!*zone_list) return 0;
	for(i=1;i<num;i++)if(zone_list[i]!=zone_list[0]+i) break;
	if(control->pos==control->end) control->pos=control->start;
	i=min(control->end-control->pos,i);
	/* If any entries already in cache, forget it */
	for(p=control->start;p!=control->end;p++) if( (p->drive==drive) 
	&& (p->block >= zone_list[0]) && (p->block < zone_list[0]+i) ) 
		return 0;

	/* Write out at least 'i' entries */
	for(p=control->pos; p < control->pos+i ; )
	{
		if(p->status < 2) p++;
		else p+=writeout(control,p);
	}

	chk_zone(zone_list[0],i,drive);

	crwabs(2,control->pos->buffer,i,zone_list[0],drive);
	for(p=control->pos,j=0;j<i;j++,p++)
	{
		p->block=zone_list[j];
		p->drive=drive;
		p->status=1;
	}
	control->pos+=i;
	return i;
}

/* Invalidate all cache entries for a given drive */

void m_invalidate(drv)
int drv;
{
	int warned=0;
	cache *p;
	for(p=syscache.start;p!=usrcache.end;p++)
	if(p->drive==drv && p->status)
	{
		if(p->status==2 && !warned++)
		ALERT("Cache entry not written out when drive %c invalidated",drv+'A');
		p->status=0;
	}
}

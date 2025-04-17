/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N.Henson */

#include "minixfs.h"
#include "proto.h"
#include "global.h"

/* Inode routines */

/* Read an inode from the cache , if the filesystem is V1 convert to V2
 * first , this greatly simplifies matters as other routines can then deal
 * exclusively with V2 inodes.
 */

int read_inode(num,rip,drv)
unsigned num;
d_inode *rip;
int drv;
{
	bufr *tmp;
	super_info *psblk=super_ptr[drv];
	num-=1;
	tmp=cget_block(num/psblk->ipb+psblk->ioff,drv,&icache);
	if(psblk->version) *rip=tmp->binode[num%psblk->ipb];
	else
	{
		d_inode1 *oldrip;
		int i;
		oldrip=&tmp->binode1[num%psblk->ipb];
		/* Convert V1 inode to V2 */
		rip->i_mode=oldrip->i_mode;
		rip->i_nlinks=oldrip->i_nlinks;
		rip->i_uid=oldrip->i_uid;
		rip->i_gid=oldrip->i_gid;
		rip->i_size=oldrip->i_size;
		rip->i_atime=oldrip->i_mtime;
		rip->i_mtime=oldrip->i_mtime;
		rip->i_ctime=oldrip->i_mtime;
		for(i=0;i< NR_ZONE_NUMS;i++) rip->i_zone[i]=oldrip->i_zone[i];
		rip->i_zone[NR_ZONE_NUMS]=0;
	}
	return(0);
}

/* Write out an inode , assuming it is V2. If the filesystem is V1 it converts
 * the supplied inode first.
 */

int write_inode(num,rip,drv)
unsigned num;
d_inode *rip;
int drv;
{
	cache *tmp;
	super_info *psblk=super_ptr[drv];
	num-=1;
	tmp=cache_get(num/psblk->ipb+psblk->ioff,drv,&icache,NOGUESS);
	if(psblk->version) tmp->buffer->binode[num%psblk->ipb]=*rip;
	else
	{
		d_inode1 *oldrip;
		int i;
		oldrip=&tmp->buffer->binode1[num%psblk->ipb];
		/* Convert V2 inode to V1 */
		oldrip->i_mode=rip->i_mode;
		oldrip->i_nlinks=rip->i_nlinks;
		oldrip->i_uid=rip->i_uid;
		oldrip->i_gid=rip->i_gid;
		oldrip->i_size=rip->i_size;
		oldrip->i_mtime=rip->i_mtime;
		for(i=0;i<NR_ZONE_NUMS;i++) oldrip->i_zone[i]=rip->i_zone[i];
	}
	tmp->status=2;
	return(0);
}

/* 'get' an inode from the cache, return a pointer to the inode and
 * if the pointer 'flag' is non-zero, return a pointer to the 'status' 
 * flag as well. Need two versions for this as well.
 */

d_inode1 *get_inode1(inum,drive,flag,guess)
unsigned inum;
int drive;
int **flag;
cache **guess;
{
	cache *tmp;
	super_info *psblk=super_ptr[drive];
	inum-=1;
	tmp=cache_get((inum>>L_IPB)+psblk->ioff,drive,&icache,guess);
	if(flag) *flag=&tmp->status;

	return &tmp->buffer->binode1[inum & (INODES_PER_BLOCK-1)] ;
}

d_inode *get_inode2(inum,drive,flag,guess)
unsigned inum;
int drive;
int **flag;
cache **guess;
{
	cache *tmp;
	super_info *psblk=super_ptr[drive];
	inum-=1;
	tmp=cache_get((inum>>L_IPB2)+psblk->ioff,drive,&icache,guess);

	if(flag) *flag=&tmp->status;

	return &tmp->buffer->binode[inum & (INODES_PER_BLOCK2-1)] ;
}

/* Truncate an inode to 'count' zones, this is used by unlink() as well as
 * (f)truncate() . Bit tricky this , we have to note which blocks to free,
 * and free indirection/double indirection blocks too but iff all the blocks
 * inside them are free too. We also need to keep count of how much to leave 
 * alone , sparse files complicate this a bit .... so do 2 fs versions ....
 */

void trunc_inode(rip,drive,count,zap)
d_inode *rip;	
int drive;
long count;			/* number of blocks to leave */
int zap;			/* flag to alter inode */
{
	int i,j;
	bufr *tmp;
	char some,dirty;
	super_info *psblk=super_ptr[drive];
	char vers;
	vers=psblk->version;
	/* Handle zones in inode first */
	if(count<psblk->dzpi)
	{
		for(i=count;i<psblk->dzpi;i++) {
			if(rip->i_zone[i])
				free_zone(rip->i_zone[i],drive);
			if(zap)rip->i_zone[i]=0;
		}
		count=0;
	}
	else count-=psblk->dzpi;
/* Handle indirect zone */
	if(count< psblk->zpind) {
		some=0;
		dirty=0;
		if(rip->i_zone[7]) {
			tmp=get_zone(rip->i_zone[7],drive);
			for(i=0;i<psblk->zpind;i++) {
				if(PIND(vers,tmp,i)) {
					if(count)some=1;
					else {
						free_zone(PIND(vers,tmp,i),drive);
						if(zap)PIND(vers,tmp,i)=0;
						dirty=1;
					}
				}	
				if(count)count--;
			}
			if(!some) {
				free_zone(rip->i_zone[7],drive);
				if(zap)rip->i_zone[7]=0;
			}
			else if(dirty) 
				write_zone(rip->i_zone[7],tmp,drive,&syscache);
		}
	}
	else count-=psblk->zpind;
	/* Handle double indirect ... */
	if(rip->i_zone[8]) {
		some=0;
		dirty=0;
		read_zone(rip->i_zone[8],&temp,drive,&syscache);
		for(i=0;i<psblk->zpind;i++) {
			if(IND(vers,temp,i)) {
			    char lsome,ldirty; /* local some,dirty for inds */
			    lsome=0;
			    ldirty=0;
			    tmp=get_zone(IND(vers,temp,i),drive);
			    for(j=0;j<psblk->zpind;j++) {
				if(PIND(vers,tmp,j)) {
					if(count) { 
						some=1;
						lsome=1;
					}
					else {
						free_zone(PIND(vers,tmp,j),drive);
						if(zap)PIND(vers,tmp,j)=0;
						ldirty=1;
						dirty=1;
					}
				}
				if(count)count--;
			    }
			    if(!lsome) {
				free_zone(IND(vers,temp,i),drive);
				if(zap)IND(vers,temp,i)=0;
			    }
			    else if(ldirty)
				write_zone(IND(vers,temp,i),tmp,drive,&syscache);
			}
			else 
			{
				if(count>=psblk->zpind)count-=psblk->zpind;
				else count=0;
			}
		}
		if(!some) {
			free_zone(rip->i_zone[8],drive);
			if(zap)rip->i_zone[8]=0;
		}
		else if(dirty)write_zone(rip->i_zone[8],&temp,drive,&syscache);
	}
}

/* Inode version of (f)truncate , truncates a file to size 'length' ,
 * not used at present ...
 */

long itruncate(inum,drive,length)
unsigned inum;
int drive;
long length;
{
	long count;
	d_inode rip;
	read_inode(inum,&rip,drive);
	/* Regulars only , clever directory compaction stuff later ... */
	if(!IS_REG(rip))return EACCDN;
	/* If file smaller than 'length' nothing to do */
	if(rip.i_size <= length)
	{
#if 0
		rip.i_size=length;
#endif
		return 0;
	}
	count=(length+1023)/1024;
	trunc_inode(&rip,drive,count,1);
	rip.i_size=length;	
	write_inode(inum,&rip,drive);
	if(cache_mode) l_sync();
	return 0;
}



/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N.Henson */

/* Bitmap handling stuff */

#include "minixfs.h"
#include "proto.h"
#include "global.h"

long count_bits(buf,num)
ushort *buf;
long num;
{
	long i,count;
	count = 0;
	for(i = 0; i < num/16; i++) {
		if(buf[i]==65535U)count+=16;
		else count+=bitcount(buf[i]);
	}
	count += bitcount((ushort)(buf[num/16] & (( 1l<< (num%16)) -1l)));
	return(count);
}

int bitcount(wrd)
unsigned int wrd;
{
	ushort i;
	int count;

	count=0;
	for (i = 1; i != 0; i <<= 1)
	  if (wrd & i)
	    count++;	
	return(count);
}

long alloc_zone(drive)
int drive;
{
	long save;

	super_info *psblk=super_ptr[drive];

	if( !(save=alloc_bit(psblk->zbitmap,psblk->sblk.s_zones
			-psblk->sblk.s_firstdatazn+1,psblk->zlast)) )
		return 0;
	psblk->zdirty=1; /* Mark zone bitmap as dirty */
	if(save>psblk->zlast)psblk->zlast=save;
	return(save+psblk->sblk.s_firstdatazn-1);
}

unshort alloc_inode(drive)
int drive;
{
	ushort save;	
	super_info *psblk=super_ptr[drive];

	if(!(save=alloc_bit(psblk->ibitmap,psblk->sblk.s_ninodes+1l,
								psblk->ilast)))
		return 0;
	psblk->idirty=1;	/* Mark inode bitmap as dirty */
	if(save>psblk->ilast)psblk->ilast=save;
	return(save);
}

/* Release a zone */
int free_zone(zone,drive)
long zone;
int drive;
{
	super_info *psblk=super_ptr[drive];
	long save,ret;
	save=zone+1-psblk->sblk.s_firstdatazn;
	ret=free_bit(psblk->zbitmap,save);
	psblk->zdirty=1; /* Mark zone bitmap as dirty */
	if(save<psblk->zlast)psblk->zlast=save;
	if(!ret) ALERT("Drive %d zone %ld freeing already free zone !",drive,zone);
	return(ret);
}

/* Release an inode */
int free_inode(inum,drive)
unsigned inum;
int drive;
{
	long ret;
	super_info *psblk=super_ptr[drive];
	ret=free_bit(psblk->ibitmap,inum);
	if(inum<psblk->ilast)psblk->ilast=inum;
	psblk->idirty=1;	/* Mark inode bitmap as dirty */
	if(!ret) ALERT("Drive %d inode %d , freeing already free inode!",drive,inum);
	return(ret);
}


/* This routine is used for allocating both free inodes and free zones 
 * Search a bitmap for a zero , then return its bit number and change it
 * to a one ...... but without exceeding 'num' bits 
 */

long alloc_bit(buf,num,last)
ushort *buf;
long num,last;
{
	long i,j,k;

	k=1;
	for(i=last>>4;(i<=(num>>4)) && (buf[i]==65535U);i++)
		;
	if( i > (num>>4) )
		return(0);
	else {
		for(j=0;j<16;j++) {
			if(!(buf[i] & k)) {
				long free;
				free=i*16+j;
				if(free>=num)return 0;
				buf[i]|=k;
				return(free);
			}
			k<<=1;
		}
	}
	ALERT("minixfs: alloc_bit: This can't happen !");
	return 0;
}

/* zero a bit of a bitmap return 0 if already zero */

long free_bit(buf,bitnum)
ushort *buf;
long bitnum;
{
	register long index=bitnum>>4;
	register ushort bit = 1 << (bitnum & 15);
	long ret;

	ret=buf[index] & bit;
	buf[index]&= ~bit;
	return(ret);
}


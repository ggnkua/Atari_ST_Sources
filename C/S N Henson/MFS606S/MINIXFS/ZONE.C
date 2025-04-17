/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N. Henson */

#include "minixfs.h"
#include "proto.h"
#include "global.h"

int read_zone(num,buf,drive,control)
long num ;
void *buf;
int drive;
cache_control *control;
{
	if(num) bcopy(cget_block(num,drive,control),buf,(size_t)BLOCK_SIZE);
	else bzero(buf,(size_t)BLOCK_SIZE);
	return(0);
}

/* Only ever used for directories so always syscache */
bufr *get_zone(num,drive)
long num ;
int drive;
{
    return(cget_block(num,drive,&syscache));
}

/* Zone cache stuff (same as cache stuff but with checking) */
cache *cget_zone(num,drive,control,guess)
long num;
int drive;
cache_control *control;
cache **guess;
{
	return (cache_get(num,drive,control,guess));
}

cache *cput_zone(num,drive,control)
long num;
int drive;
cache_control *control;
{
	return (cache_put(num,drive,control));
}

int write_zone(num,buf,drive,control)
long num ;
void *buf;
int drive;
cache_control *control;
{
	cput_block(num,drive,buf,control);
	return(0);
}

/* This is a 'clever' write_zone which recognises consecutive blocks and
 * queues requests until it gets one out of sequence.This allows large
 * i/o requests to be done with a single Rwabs for consecutive blocks
 * which is much faster than lots of little ones.
 */

int write_zones(num,buf,drive,control)
long num;
void *buf;
int drive;
cache_control *control;
{
	static void *qstart,*qnext;
	static long nstart,nnext,count;
	static short qdrive=-1;
	cache *p;
	int i;

	if( (p=in_cache(num,drive,control,NOGUESS)) )
	{
		bcopy(buf,p->buffer,(size_t)BLOCK_SIZE);
		p->status=1;
	}

	if(buf!=qnext || nnext!=num || qdrive!=drive || count > MAX_RWS )
	{
		/* Flush out queue */
		if(qdrive!=-1) 
		{
		chk_zone(nstart,count,drive);
		if(count<8) for(i=0;i<count;i++) 
			write_zone(nstart+i,qstart+(i<<L_BS),qdrive,control);
		else crwabs(3,qstart,count,nstart,qdrive);
		}
		qdrive=drive;
		qstart=buf;
		qnext=buf+BLOCK_SIZE;
		nstart=num;
		nnext=num+1;
		count=1;
	}
	else 
	{
		qnext+=BLOCK_SIZE;
		count++;
		nnext++;
	}
	return 0;
}

/* This is an equivalent for read ... but this is a bit harder as it is
 * not obvious what to do with the cache . What we finally do is to
 * always get data from the cache if we can , though this could easily
 * turn a large consecutive i/o request into lots of little ones . The
 * cache is not filled from the new read unless we are only reading
 * 1 zone ... basically this assumes that if the user reads several zones
 * then the program will be doing doing some sort of cacheing itself .
 */

int read_zones(num,buf,drive,control)
long num;
void *buf;
int drive;
cache_control *control;
{
	static void *qstart,*qnext;
	static long nstart,nnext,count;
	static short qdrive=-1;
	cache *p;
	/* Read from cache if necessary */

	if( (p=in_cache(num,drive,control,NOGUESS)) )
	{
		bcopy(p->buffer,buf,(size_t)BLOCK_SIZE);
		drive=-1; /* Force flush of queued entries */
	}

	if( qdrive!=drive || buf!=qnext || nnext!=num || (count > MAX_RWS) )
	{
		/* Flush out queue */
		if(qdrive!=-1)
		{
			if(count==1) read_zone(nstart,qstart,qdrive,control);
			else {
				if(nnext) crwabs(2,qstart,count,nstart,qdrive);
				else bzero(qstart,count*(size_t)BLOCK_SIZE);
			}
		}
		qdrive=drive;
		qstart=buf;
		qnext=buf;
		nstart=num;
		nnext=num;
		count=0;
	}
	if(qdrive!=-1)
	{
		qnext+=BLOCK_SIZE;
		count++;
		if(nnext)nnext++;
	}
	return 0;
}

/* This routine finds the zone 'numr' of an inode , traversing indirect
 * and double indirect zones as required if flag!=0 zones are added as
 * required . Having two filesystem versions makes this a bit trickier, in
 * fact although using a single routine looks more elegant it is slow,
 * so two versions are used.
 */

long find_zone(rip,numr,drive,flag)
d_inode *rip;
long numr;
int drive;
int flag;
{
	super_info *psblk=super_ptr[drive];

	return psblk->version ? find_zone2(rip,numr,drive,flag,&dummy) : 
					find_zone1(rip,numr,drive,flag);
}

long find_zone11(rip,numr,drive,flag,fch)
d_inode1 *rip;
long numr;
int drive;
int flag;
f_cache *fch;
{
	long temp_zone;
	unshort *zptr,*zptr2;
	cache *tmp,*tmp2;

	/* Past EOF ? */
	if(!flag && (numr*BLOCK_SIZE >= rip->i_size) ) return(0);

	/* Zone in inode ? */
	if(numr < NR_DZONE_NUM)
	{
		temp_zone=rip->i_zone[numr];
		if(temp_zone || !flag ) return temp_zone;
		return(rip->i_zone[numr]=alloc_zone(drive));
	}
	numr-=NR_DZONE_NUM;
	/* In indirect zone then ? */
	if(numr < NR_INDIRECTS)
	{
		if(rip->i_zone[7])
		{
			tmp=
			cget_zone(rip->i_zone[7],drive,&syscache,&fch->izguess);
			zptr=&tmp->buffer->bind1[numr];
			if( *zptr || !flag )return *zptr;
			if( (*zptr=alloc_zone(drive)) ) tmp->status=2;
			return *zptr;
		}
		else
		{
			if(!flag || !(rip->i_zone[7]=alloc_zone(drive))) return 0;
			tmp=cput_zone(rip->i_zone[7],drive,&syscache);
			fch->izguess=tmp;
			bzero(tmp->buffer,(size_t)BLOCK_SIZE);
			return tmp->buffer->bind1[numr]=alloc_zone(drive);
		}
	}
	/* Erk double indirect .... */
	numr-=NR_INDIRECTS;
	{

	    	if(rip->i_zone[8]) {
		tmp2=cget_zone(rip->i_zone[8],drive,&syscache,&fch->dizguess);
			zptr2=&tmp2->buffer->bind1[numr>>LNR_IND];
			if(*zptr2)
			{
		     	tmp=cget_zone(*zptr2,drive,&syscache,&fch->izguess);
				zptr=&tmp->buffer->bind1[numr & (NR_INDIRECTS-1)];
				if(*zptr || !flag)return *zptr;
				if( (*zptr=alloc_zone(drive)) ) tmp->status=2;
				return *zptr;
		  	}
		  	else 
		  	{
		     		if(!flag ||!(*zptr2=alloc_zone(drive)) )return 0;
				tmp2->status=2;
				tmp=cput_zone(*zptr2,drive,&syscache);
				fch->izguess=tmp;
		     		bzero(tmp->buffer,(size_t)BLOCK_SIZE);
				zptr=&tmp->buffer->bind1[numr & (NR_INDIRECTS-1)];
				return *zptr=alloc_zone(drive);
		  	}
		}
		if(!flag || !(rip->i_zone[8]=alloc_zone(drive)) ) return 0;
	
		tmp2=cput_zone(rip->i_zone[8],drive,&syscache);
		fch->dizguess=tmp2;
		bzero(tmp2->buffer,(size_t)BLOCK_SIZE);
		zptr2=&tmp2->buffer->bind1[numr>>LNR_IND];
		if(!(*zptr2=alloc_zone(drive))) return 0;

		tmp=cput_zone(*zptr2,drive,&syscache);
		fch->izguess=tmp;
		bzero(tmp->buffer,(size_t)BLOCK_SIZE);
		zptr=&tmp->buffer->bind1[numr & (NR_INDIRECTS-1)];
		return *zptr=alloc_zone(drive) ;
	}
}

long find_zone1(rip,numr,drive,flag)
d_inode *rip;
long numr;
int drive;
int flag;
{
	long temp_zone;
	unshort *zptr,*zptr2;
	cache *tmp,*tmp2;

	/* Past EOF ? */
	if(!flag && (numr*BLOCK_SIZE >= rip->i_size) ) return(0);

	/* Zone in inode ? */
	if(numr < NR_DZONE_NUM)
	{
		temp_zone=rip->i_zone[numr];
		if(temp_zone || !flag ) return temp_zone;
		return(rip->i_zone[numr]=alloc_zone(drive));
	}
	numr-=NR_DZONE_NUM;
	/* In indirect zone then ? */
	if(numr < NR_INDIRECTS)
	{
		if(rip->i_zone[7])
		{
			tmp=cget_zone(rip->i_zone[7],drive,&syscache,NOGUESS);
			zptr=&tmp->buffer->bind1[numr];
			if( *zptr || !flag )return *zptr;
			if( (*zptr=alloc_zone(drive)) ) tmp->status=2;
			return *zptr;
		}
		else
		{
			if(!flag || !(rip->i_zone[7]=alloc_zone(drive))) return 0;
			tmp=cput_zone(rip->i_zone[7],drive,&syscache);
			bzero(tmp->buffer,(size_t)BLOCK_SIZE);
			return tmp->buffer->bind1[numr]=alloc_zone(drive);
		}
	}
	/* Erk double indirect .... */
	numr-=NR_INDIRECTS;
	{

	    	if(rip->i_zone[8]) {
			tmp2=cget_zone(rip->i_zone[8],drive,&syscache,NOGUESS);
			zptr2=&tmp2->buffer->bind1[numr>>LNR_IND];
			if(*zptr2)
			{
		     		tmp=cget_zone(*zptr2,drive,&syscache,NOGUESS);
				zptr=&tmp->buffer->bind1[numr & (NR_INDIRECTS-1)];
				if(*zptr || !flag)return *zptr;
				if( (*zptr=alloc_zone(drive)) ) tmp->status=2;
				return *zptr;
		  	}
		  	else 
		  	{
		     		if(!flag ||!(*zptr2=alloc_zone(drive)) )return 0;
				tmp2->status=2;
				tmp=cput_zone(*zptr2,drive,&syscache);
		     		bzero(tmp->buffer,(size_t)BLOCK_SIZE);
				zptr=&tmp->buffer->bind1[numr & (NR_INDIRECTS-1)];
				return *zptr=alloc_zone(drive);
		  	}
		}
		if(!flag || !(rip->i_zone[8]=alloc_zone(drive)) ) return 0;
	
		tmp2=cput_zone(rip->i_zone[8],drive,&syscache);
		bzero(tmp2->buffer,(size_t)BLOCK_SIZE);
		zptr2=&tmp2->buffer->bind1[numr>>LNR_IND];
		if(!(*zptr2=alloc_zone(drive))) return 0;

		tmp=cput_zone(*zptr2,drive,&syscache);
		bzero(tmp->buffer,(size_t)BLOCK_SIZE);
		zptr=&tmp->buffer->bind1[numr & (NR_INDIRECTS-1)];
		return *zptr=alloc_zone(drive) ;
	}
}

long find_zone2(rip,numr,drive,flag,fch)
d_inode *rip;
long numr;
int drive;
int flag;
f_cache *fch;
{
	long temp_zone;
	long *zptr,*zptr2;
	cache *tmp,*tmp2;

	/* Past EOF ? */
	if((numr*BLOCK_SIZE >= rip->i_size) && !flag ) return(0);

	/* Zone in inode ? */
	if(numr < NR_DZONE_NUM2)
	{
		temp_zone=rip->i_zone[numr];
		if(temp_zone || !flag ) return temp_zone;
		return(rip->i_zone[numr]=alloc_zone(drive));
	}
	numr-=NR_DZONE_NUM2;
	/* In indirect zone then ? */
	if(numr < NR_INDIRECTS2)
	{
		if(rip->i_zone[7])
		{
			tmp=
			cget_zone(rip->i_zone[7],drive,&syscache,&fch->izguess);
			zptr=&tmp->buffer->bind[numr];
			if( *zptr || !flag )return *zptr;
			if( (*zptr=alloc_zone(drive)) ) tmp->status=2;
			return *zptr;
		}
		else
		{
			if(!flag || !(rip->i_zone[7]=alloc_zone(drive))) return 0;
			tmp=cput_zone(rip->i_zone[7],drive,&syscache);
			bzero(tmp->buffer,(size_t)BLOCK_SIZE);
			return tmp->buffer->bind[numr]=alloc_zone(drive);
		}
	}
	/* Erk double indirect .... */
	numr-=NR_INDIRECTS2;
	{

	    	if(rip->i_zone[8]) {
		  tmp2=cget_zone(rip->i_zone[8],drive,&syscache,&fch->dizguess);
			zptr2=&tmp2->buffer->bind[numr>>LNR_IND2];
			if(*zptr2)
			{
		     		tmp=
				cget_zone(*zptr2,drive,&syscache,&fch->izguess);
				zptr=&tmp->buffer->bind[numr & (NR_INDIRECTS2-1)];
				if(*zptr || !flag)return *zptr;
				if( (*zptr=alloc_zone(drive)) ) tmp->status=2;
				return *zptr;
		  	}
		  	else 
		  	{
		     		if(!flag ||!(*zptr2=alloc_zone(drive)) )return 0;
				tmp2->status=2;
				tmp=cput_zone(*zptr2,drive,&syscache);
		     		bzero(tmp->buffer,(size_t)BLOCK_SIZE);
				zptr=&tmp->buffer->bind[numr & (NR_INDIRECTS2-1)];
				return *zptr=alloc_zone(drive);
		  	}
		}
		if(!flag || !(rip->i_zone[8]=alloc_zone(drive)) ) return 0;
	
		tmp2=cput_zone(rip->i_zone[8],drive,&syscache);
		bzero(tmp2->buffer,(size_t)BLOCK_SIZE);
		zptr2=&tmp2->buffer->bind[numr>>LNR_IND2];
		if(!(*zptr2=alloc_zone(drive))) return 0;

		tmp=cput_zone(*zptr2,drive,&syscache);
		bzero(tmp->buffer,(size_t)BLOCK_SIZE);
		zptr=&tmp->buffer->bind[numr & (NR_INDIRECTS-1)];
		return *zptr=alloc_zone(drive) ;
	}
}

/* This reads zone number 'numr' of an inode .
 * It returns the actual number of valid characters in 'numr' , this is only
 * used for directories so it is hard-coded for the system cache. 
 */

int next_zone(rip,numr,buf,drive)
d_inode *rip;
long numr;
void *buf;
int drive;
{
	long ztemp;
	long ret;

	ret=min(rip->i_size-numr*BLOCK_SIZE,BLOCK_SIZE);
	if(ret <= 0)return 0;
	ztemp=find_zone(rip,numr,drive,0);
	read_zone(ztemp,buf,drive,&syscache);
	return (int)ret;
}

/* As above but reads in cache pointer */

int cnext_zone(rip,numr,buf,drive)
d_inode *rip;
long numr;
bufr **buf;
int drive;
{
	long ztemp;
	long ret;

	ret=min(rip->i_size-numr*BLOCK_SIZE,BLOCK_SIZE);
	if(ret <= 0)return 0;
	ztemp=find_zone(rip,numr,drive,0);
	*buf=get_zone(ztemp,drive);
	return (int)ret;
}

/* l_write is used internally for doing things a normal user cannot such
 * as writing to a directory ... it accepts 5 parameters , an inode num
 * a position (current position of write) a count which is the number of
 * characters to write,a buffer and a drive , it updates i_size as needed 
 * and allocates zones as required , it is nastier than a read because it 
 * has to write partial blocks within valid blocks and to write beyond EOF
 */

long l_write(inum,pos,len,buf,drive)
unsigned inum;
long pos;
long len;
const void *buf;
int drive;
{
    return super_ptr[drive]->version ? l_write2(inum,pos,len,buf,drive) :
					l_write1(inum,pos,len,buf,drive);
}

long l_write1(inum,pos,len,buf,drive)
unsigned inum;
long pos;
long len;
const void *buf;
int drive;
{
    register const void *p = buf;	/* Current position in buffer */
    d_inode1 *rip;
    long chunk;
    long left=len;
    long zne;
    cache_control *control;
    int *status;

    rip=get_inode1(inum,drive,&status,NOGUESS);

 	/* Work out which cache to use */
    control = IS_DIR((*rip)) ? &syscache : &usrcache;
    if(pos==-1l) pos=rip->i_size; /* If pos==-1 append */
    chunk=pos/BLOCK_SIZE;

    while(left)	/* Loop while characters remain to be written */
    {
	long zoff;
	ushort wleft;
	cache *cp;

	zne=find_zone11(rip,chunk++,drive,1,&dummy); /* Current zone in file */

	if(zne==0) break;			/* Partition full */
	zoff = pos & (BLOCK_SIZE -1);		/* Current zone position */
	wleft=min(BLOCK_SIZE-zoff,left);	/*Left to write in curr blk*/	
	if((zoff) || ( (left < BLOCK_SIZE) && (pos+left<rip->i_size)))
	{
		cp=cget_zone(zne,drive,control,NOGUESS);
		cp->status=2;
	}
	else 
	{
		cp=cput_zone(zne,drive,control);
		if(wleft!=BLOCK_SIZE)bzero(cp->buffer->bdata,(size_t)BLOCK_SIZE);
	}
	bcopy(p,&cp->buffer->bdata[zoff],(size_t)wleft);
	pos+=wleft;
	p+=wleft;
	if(pos>rip->i_size)rip->i_size=pos;
	left-=wleft;
    }

    rip->i_mtime=Unixtime(Timestamp(), Datestamp());
    *status=2;

    return(len-left);
}

long l_write2(inum,pos,len,buf,drive)
unsigned inum;
long pos;
long len;
const void *buf;
int drive;
{
    register const void *p = buf;	/* Current position in buffer */
    d_inode *rip;
    long chunk;
    long left=len;
    long zne;
    cache_control *control;
    int *status;

    rip=get_inode2(inum,drive,&status,NOGUESS);

 	/* Work out which cache to use */
    control = IS_DIR((*rip)) ? &syscache : &usrcache;
    if(pos==-1l) pos=rip->i_size; /* If pos==-1 append */
    chunk=pos/BLOCK_SIZE;

    while(left)	/* Loop while characters remain to be written */
    {
	long zoff;
	ushort wleft;
	cache *cp;

	zne=find_zone2(rip,chunk++,drive,1,&dummy); /* Current zone in file */

	if(zne==0)break;			/* Partition full */
	zoff = pos & (BLOCK_SIZE -1);		/* Current zone position */
	wleft=min(BLOCK_SIZE-zoff,left);	/*Left to write in curr blk*/	
	if((zoff) || ( (left < BLOCK_SIZE) && (pos+left<rip->i_size)))
	{
		cp=cget_zone(zne,drive,control,NOGUESS);
		cp->status=2;
	}
	else 
	{
		cp=cput_zone(zne,drive,control);
		if(wleft!=BLOCK_SIZE)bzero(cp->buffer->bdata,(size_t)BLOCK_SIZE);
	}
	bcopy(p,&cp->buffer->bdata[zoff],(size_t)wleft);
	pos+=wleft;
	p+=wleft;
	if(pos>rip->i_size)rip->i_size=pos;
	left-=wleft;
    }

    rip->i_mtime=Unixtime(Timestamp(), Datestamp());
    *status=2;

    return(len-left);
}

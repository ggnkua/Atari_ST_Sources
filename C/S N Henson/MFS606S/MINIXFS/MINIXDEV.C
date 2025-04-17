/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N. Henson */

#include "minixfs.h"
#include "proto.h"
#include "global.h"

DEVDRV minix_dev = {
	m_open, m_write, m_read,
	m_seek, m_ioctl, m_datime,
	m_close,m_select, m_unselect
};

#ifndef FUTIME
#define FUTIME		(('F'<< 8) | 3)
#endif

#ifndef FTRUNCATE
#define FTRUNCATE	(('F'<< 8) | 4)
#endif

/* Minix fs device driver */

/* Under minixfs there is no 'per file structure' , that is all references to
the same file are independent.This complicates file sharing a bit , the 'next'
field points to the next fileptr for the minixfs , so that a search checks the
list sequentially (the global variable 'firstptr' is the start of the list) ,
references to the same file are grouped together so that the first reference
can act as a list pointer to denyshare() , though the last reference's 'next'
pointer is temporarily set to NULL to keep denyshare() happy.
*/

long m_open(f)
FILEPTR *f;
{
	FILEPTR *lst,*elst,*tmplst;
	f_cache *fch,*old_fch;
	d_inode rip;

	/* do some sanity checking */
	read_inode(f->fc.index,&rip,f->fc.dev);

	if (!IS_REG(rip)) {
		DEBUG("m_open: not a regular file");
		return EACCDN;
	}


	/* Set up f_cache structure */
	if( ! (fch=(f_cache *)Kmalloc(sizeof(f_cache)) ) )
	{
		DEBUG("No memory for f_cache structure");
		return ENSMEM;
	}
	bzero(fch,sizeof(f_cache));

	f->devinfo=(long)fch;

	/* Find first pointer to same file , if any */
	for(lst=firstptr;lst;lst=lst->next)
	    if((f->fc.dev==lst->fc.dev) && (f->fc.index==lst->fc.index))break;
	if(lst)
	{
		/* Find last pointer to file */
		for(elst=lst;elst->next;elst=elst->next)
		if((elst->next->fc.dev!=lst->fc.dev) || 
			(elst->next->fc.index!=lst->fc.index))break;

		tmplst=elst->next;
		elst->next=0;

		if(Denyshare(lst,f))
		{
			elst->next=tmplst;
			Kfree(fch);
			return EACCDN;
		}
		elst->next=f;
		/* If truncating invalidate all f_cache zones */
		if(f->flags & O_TRUNC)
		{
			FILEPTR *p;
			for (p = lst; p; p = p->next)
			  ((f_cache *) p->devinfo)->lzone = 0;
		}
		f->next=tmplst;
		fch->lfirst=((f_cache *)elst->devinfo)->lfirst;

		/* If file opened already, fill in guesses from first entry */
		old_fch=(f_cache *)lst->devinfo;
		fch->iguess=old_fch->iguess;
		fch->izguess=old_fch->izguess;
		fch->dizguess=old_fch->dizguess;		
		fch->zguess=usrcache.start;
	}
	else
	{
		/* Stick new fptr at top */
		f->next=firstptr;
		firstptr=f;
		fch->lfirst=(LOCK **)Kmalloc(sizeof(LOCK *)); /* List of locks */
		*fch->lfirst=0;	/* No locks yet */
		fch->iguess=icache.start;
		fch->zguess=usrcache.start;
		fch->izguess=syscache.start;
		fch->dizguess=syscache.start;
	}
	/* should we truncate the file? */
	if (f->flags & O_TRUNC) {
		trunc_inode(&rip,f->fc.dev,0L,1);
		rip.i_size = 0;
		rip.i_mtime = Unixtime(Timestamp(), Datestamp());
		write_inode(f->fc.index,&rip,f->fc.dev);

		if(cache_mode) l_sync();

	}
	return 0;
}

long m_close(f, pid)
	FILEPTR *f;
	int pid;
{
	FILEPTR **last;
	f_cache *fch=(f_cache *)f->devinfo;

	/* If locked remove any locks for this pid */
	if(f->flags & O_LOCK)
	{
		LOCK *lck, **oldl;
		TRACE("minixfs: removing locks for pid %d",pid);
		oldl = fch->lfirst;
		lck = *oldl;
		while(lck)
		{
			if(lck->l.l_pid == pid) 
			{
				*oldl=lck->next;
				Kfree(lck);
			}
			else oldl = &lck->next;

			lck = *oldl;
		}
	}

	if (f->links <= 0) {
		/* Last fptr ? */
		if (inode_busy (f->fc.index, f->fc.dev, 0) < 2)
		{
			/* Free LOCK pointer */
			Kfree(fch->lfirst);
			if(f->fc.aux & AUX_DEL)
			{
				d_inode rip;
				DEBUG("minixfs: Deleting unlinked file");
				read_inode(f->fc.index,&rip,f->fc.dev);
				trunc_inode(&rip, f->fc.dev,0L,0);
				rip.i_mode=0;
				write_inode(f->fc.index,&rip,f->fc.dev);
				free_inode(f->fc.index,f->fc.dev);
			}
		}
		Kfree(fch);
		for (last = &firstptr;; last = &(*last)->next)
		  {
		    if (*last == f)
		      {
			*last = f->next;
			break;
		      }
		    else if (!*last)
		      {
			ALERT ("Minixfs FILEPTR chain corruption!");
			break;
		      }
		  }
	}
	if(cache_mode) l_sync(); /* always sync on close */

	return 0;
}

/* Minix read , all manner of horrible things can happen during 
 * a read , if fptr->pos is not block aligned we need to copy a partial
 * block then a load of full blocks then a final possibly partial block
 * any of these can hit EOF and we mustn't copy anything past EOF ...
 * my poor head :-( 
 */

long m_read(f,buf,len)
FILEPTR *f;
char *buf;
long len;
{
	if(super_ptr[f->fc.dev]->version) return m_read2(f,buf,len);
	return m_read1(f,buf,len);

}

long m_read1(f,buf,len)
FILEPTR *f;
char *buf;
long len;
{
	d_inode1 *rip;
	long chunk,znew,rc,actual_read;
	int i;
	f_cache *fch=(f_cache *)f->devinfo;

	chunk=f->pos>>L_BS;

	rip=get_inode1(f->fc.index,f->fc.dev,0,&fch->iguess);

	actual_read=min(rip->i_size-f->pos,len); /* Number of characters read */

	rc=actual_read;	/* Characters remaining to read */
	if(rc<=0) return 0;	/* At or past EOF */

	/* Every PRE_READ blocks, try to read in PRE_READ zones into cache */

	if( (chunk>=fch->lzone) && ( (len>>L_BS) < PRE_READ) )
	{
		for(i=0;i<PRE_READ;i++)
			fch->zones[i]=find_zone11(rip,i+chunk,f->fc.dev,0,fch);

		fch->fzone=chunk;
		fch->lzone=chunk+PRE_READ;
		readin(fch->zones,PRE_READ,f->fc.dev,&usrcache);
	}

	/* Are we block aligned ? If not read/copy partial block */
	if(f->pos & (BLOCK_SIZE-1))
	{
		int bpos=f->pos & (BLOCK_SIZE-1);
		int valid=min(rc,BLOCK_SIZE-bpos);

		if( (chunk >= fch->fzone) && (chunk < fch->lzone) )
					znew=fch->zones[chunk-fch->fzone];
		else znew=0;

		if(!znew)
			znew=find_zone11(rip,chunk,f->fc.dev,0,fch);

		chunk++;
		if(znew)	/* Sparse file ? */
bcopy(cache_get(znew,f->fc.dev,&usrcache,&fch->zguess)->buffer->bdata+bpos,buf,
									 valid);

		else bzero(buf,valid);
		buf+=valid;
		rc-=valid;
	}

	if(rc>>L_BS) /* Any full blocks to read ? */
	{
		for(i=0;i < rc>>L_BS;i++)
		{

			if( (chunk>=fch->fzone) && (chunk < fch->lzone) )
				znew=fch->zones[chunk-fch->fzone];
			else znew=0;
			if(!znew)
				znew=find_zone11(rip,chunk,f->fc.dev,0,fch);
			chunk++;
			read_zones(znew,buf,f->fc.dev,&usrcache);
			buf+=BLOCK_SIZE;
		}
		read_zones(0,NULL,-1,&usrcache);
		rc &=BLOCK_SIZE-1;

	}

	if(rc) /* Anything left ? */
	{

		if( (chunk>=fch->fzone) && (chunk < fch->lzone))
					znew=fch->zones[chunk-fch->fzone];
		else znew=0;
		if(!znew)
			znew=find_zone11(rip,chunk,f->fc.dev,0,fch);
		if(znew)
bcopy(cache_get(znew,f->fc.dev,&usrcache,&fch->zguess)->buffer->bdata,buf,rc);
		else bzero(buf,rc);
	}

	f->pos+=actual_read;
	return actual_read;
}

long m_read2(f,buf,len)
FILEPTR *f;
char *buf;
long len;
{
	d_inode *rip;
	long chunk,znew,rc,actual_read;
	int i;

	int *status;
	f_cache *fch=(f_cache *)f->devinfo;


	chunk=f->pos>>L_BS;
	rip = get_inode2(f->fc.index,f->fc.dev,&status,&fch->iguess);

	actual_read=min(rip->i_size-f->pos,len); /* Number of characters read */

	rc=actual_read;	/* Characters remaining to read */
	if(rc<=0) return 0;	/* At or past EOF */

	/* Every PRE_READ blocks , try to read in PRE_READ zones into cache */

	if(chunk>=fch->lzone && (len>>L_BS < PRE_READ ) )
	{
		for(i=0;i<PRE_READ;i++)
			fch->zones[i]=find_zone2(rip,i+chunk,f->fc.dev,0,fch);
		readin(fch->zones,PRE_READ,f->fc.dev,&usrcache);
		fch->fzone=chunk;
		fch->lzone=chunk+PRE_READ;
	}

	/* Are we block aligned ? If not read/copy partial block */
	if(f->pos & (BLOCK_SIZE-1))
	{
		int bpos=f->pos & (BLOCK_SIZE-1);
		int valid=min(rc,BLOCK_SIZE-bpos);

		if( (chunk >= fch->fzone) && (chunk < fch->lzone) )
					znew=fch->zones[chunk-fch->fzone];
		else znew=0;

		if(!znew)
			znew=find_zone2(rip,chunk,f->fc.dev,0,fch);
		chunk++;
		if(znew)	/* Sparse file ? */
bcopy(cache_get(znew,f->fc.dev,&usrcache,&fch->zguess)->buffer->bdata+bpos
								    ,buf,valid);
		else bzero(buf,valid);
		buf+=valid;
		rc-=valid;
	}

	if(rc>>L_BS) /* Any full blocks to read ? */
	{
		int i;
		for(i=0;i < rc>>L_BS;i++)
		{
			if( (chunk>=fch->fzone) && (chunk < fch->lzone) )
				znew=fch->zones[chunk-fch->fzone];
			else znew=0;
			if(!znew) 
				znew=find_zone2(rip,chunk,f->fc.dev,0,fch);
			chunk++;
			read_zones(znew,buf,f->fc.dev,&usrcache);
			buf+=BLOCK_SIZE;
		}
		read_zones(0,NULL,-1,&usrcache);
		rc &=BLOCK_SIZE-1;

	}

	if(rc) /* Anything left ? */
	{
		if( (chunk>=fch->fzone) && (chunk < fch->lzone))
					znew=fch->zones[chunk-fch->fzone];
		else znew=0;
		if(!znew)
			znew=find_zone2(rip,chunk,f->fc.dev,0,fch);
		if(znew)
bcopy(cache_get(znew,f->fc.dev,&usrcache,&fch->zguess)->buffer->bdata,buf,rc);
		else bzero(buf,rc);
	}

	/* Normally we dont care about setting atime , since the writing of
	 * inodes will simply ignore the extra fields for V1 filesystems ,
	 * however read doesn't usually write inodes so we check if its V2
	 * since its silly writing to a V1 filesystem with the modified access
	 * time because it wont be stored ! Also for floppies never update atime
	 * this is a bit of a hack , should really test write protection and act
	 * accordingly. Also note l_sync() is not called here , it's hardly the
	 * end of the world if atime is not updated because of a crash and it
	 * improves performance a bit by delaying the update until m_close().
	 */

	if(f->fc.dev > 1)
	{
		rip->i_atime=Unixtime(Timestamp(),Datestamp());
		*status=2;
	}

	f->pos+=actual_read;
	return actual_read;
}

/* seek is a bit easier */

long m_seek(f,offset,flag)
FILEPTR *f;
long offset;
int flag;
{
	d_inode rip;

	read_inode(f->fc.index,&rip,f->fc.dev);
	switch(flag) {
	case SEEK_SET :
		if( offset >= 0 ) f->pos=offset;
		else return(ERANGE);
		break;

	case SEEK_CUR :
		if(f->pos+offset >= 0 ) f->pos+=offset;
		else return(ERANGE);
		break;

	case SEEK_END :
		if(rip.i_size >= -offset ) f->pos=rip.i_size + offset; 
		else return(ERANGE);
		break;

	default :
		return(EINVFN);

	}
	return (f->pos);
}

long m_write(f,buf,len)
FILEPTR *f;
char *buf;
long len;
{
	long ret;

	ret=l_write(f->fc.index,f->pos,len,buf,f->fc.dev);

	if(ret<0) return ret;

	if(cache_mode==ROBUST) l_sync();

	f->pos+=ret;

	return(ret);
}

long m_ioctl(f,mode,buf)
FILEPTR *f;
int mode;
void *buf;
{
    switch (mode)
      {
      case FIONREAD:
      case FIONWRITE:
	{
		*((long *) buf)=1;
		return 0;
	}

/* File locking code , unlike sharing *lfirst of the f_cache structure 
 * exists on a 'per-file' basis, this simplifies things somewhat.
 */

      case F_SETLK:
      case F_GETLK:
	{

		f_cache *fch;
		LOCK t, *lck, **lastlck;

		struct flock *fl;

		int cpid;	/* Current proc pid */

		fch=(f_cache *)f->devinfo;

		if(!lockok)
		{
			DEBUG("Locking Not Installed");
			return EINVFN;
		}

		fl= ( struct flock *)buf;
		t.l=*fl;

		switch(t.l.l_whence)
		{

			case SEEK_SET:
			break;

			case SEEK_CUR:
			t.l.l_start+=f->pos;
			break;

			case SEEK_END:
			{
				d_inode rip;
				read_inode(f->fc.index,&rip,f->fc.dev);
				t.l.l_start=rip.i_size-t.l.l_start;
			}
			break;

			default:
			DEBUG("Invalid value for l_whence");
			return EINVFN;
		}
		
		if(t.l.l_start < 0) t.l.l_start=0;
		t.l.l_whence=0;

		if(mode == F_GETLK) {
			lck = Denylock(*fch->lfirst,&t);
			if(lck) *fl = lck->l;
			else fl->l_type = F_UNLCK;
			return 0;	
		}

		cpid=Getpid();

		if(t.l.l_type==F_UNLCK)
		{
			/* Try to find the lock */
			lastlck = fch->lfirst;
			for (lck = *lastlck; lck; lck = lck->next)
			 if( lck->l.l_pid == cpid &&
			     lck->l.l_start == t.l.l_start &&
			     lck->l.l_len == t.l.l_len)
			   {
			     *lastlck = lck->next;
			     Kfree (lck);
			     return 0;
			   }
			 else
			   lastlck = &lck->next;
			return ENSLOCK;
		}

		lck=Denylock(*fch->lfirst,&t);

		if(lck) return ELOCKED;

		lck = Kmalloc(SIZEOF(LOCK));

		if(!lck) return ENSMEM;

		lck->l = t.l;
		lck->l.l_pid = cpid;

		/* Insert lck at top of list */
		lck->next=*fch->lfirst;
		*fch->lfirst=lck;

		f->flags |=O_LOCK;	/* Lock op done on FILEPTR */
		return 0;
	}

      case FUTIME:
	{
	  d_inode rip;
	  short *timeptr = (short *) buf;

	  if( !(f->flags & O_WRONLY) ) return EACCDN;
	  read_inode (f->fc.index, &rip, f->fc.dev);
	  rip.i_atime = Unixtime (timeptr[0], timeptr[1]);
	  rip.i_mtime = Unixtime (timeptr[2], timeptr[3]);
	  rip.i_ctime = Unixtime (Timestamp (), Datestamp ());

	  write_inode (f->fc.index, &rip, f->fc.dev);
	  if (cache_mode != TURBO)
	    l_sync ();
	  return 0;
	}

      case FTRUNCATE:
	{
	  if( !(f->flags & O_WRONLY) ) return EACCDN;

	  itruncate(f->fc.index,f->fc.dev,*((long *)buf));

	  if (cache_mode != TURBO)
	    l_sync ();
	  return 0;
	}

      default:
	return EINVFN;
      }
}

/* Made this a bit like utimes, sets atime,mtime and ctime=current time */

long m_datime(f,timeptr,flag)
FILEPTR *f;
int *timeptr;
int flag;
{
	d_inode rip;
	super_info *psblk;
	psblk=super_ptr[f->fc.dev];
	read_inode(f->fc.index,&rip,f->fc.dev);
	switch (flag)
	{

		case 0 :
		*((long *)timeptr)=Dostime(_corr(rip.i_mtime));
		break;
	
		case 1 :
		rip.i_mtime=Unixtime(timeptr[0],timeptr[1]);
		rip.i_atime=rip.i_mtime;
		rip.i_ctime=Unixtime(Timestamp(),Datestamp());
		write_inode(f->fc.index,&rip,f->fc.dev);

		if(cache_mode) l_sync();

		break;

		default :
		return -1;
		break;
	}	
	return 0;
}

long m_select(f,proc,mode)
FILEPTR *f;
long proc;
int mode;
{
	return 1;
}

void m_unselect(f,proc,mode)
FILEPTR *f;
long proc;
int mode;
{
/* Do nothing */
}


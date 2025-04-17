/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N.Henson */

#include "minixfs.h"
#include "proto.h"
#include "global.h"

FILESYS minix_filesys = {
	(FILESYS *) 0,
	FS_CASESENSITIVE | FS_LONGPATH,
	m_root, m_lookup, m_creat, m_getdev,
	m_getxattr, m_chattr, m_chown,
	m_chmode, m_mkdir,
	m_rmdir, m_remove, m_getname,
	m_rename, m_opendir, m_readdir,
	m_rewinddir, m_closedir,
	m_pathconf, m_dfree,
	m_wlabel, m_rlabel,
	m_symlink, m_readlink,
	m_hardlink, m_fscntl, m_dskchng,
	m_release,m_dupcookie
};

extern DEVDRV minix_dev;

/*
 * the kernel calls this when it detects a disk change
 */

long m_dskchng(d)
int d;
{
	FILEPTR *f, **last;
	super_info *psblk;
	psblk=super_ptr[d];
	TRACE("Disk Change drive %c",d+'A');

	if(psblk && psblk!=DFS)
	{
		Kfree(psblk->ibitmap);
		Kfree(psblk);
	}
	super_ptr[d]=0;

/* this may affect the m_getname cache, too */
	if (lpath && (d == lroot.dev || d == ldir.dev)) {
		Kfree(lpath);
		lpath = 0;
	}

/* Since the disk has changed always invalidate cache */
	m_invalidate(d);

	/* Free any memory associated to file pointers of this drive. */
	last = &firstptr;
	for (f = *last; f != 0; f = *last)
	  {
	    if (f->fc.dev == d)
	      {
		f_cache *fch = (f_cache *) f->devinfo;
		/* The lock structure is shared between the fileptr's.
		   Make sure that it is freed only once. */
		if (!f->next || f->next->fc.dev != d
		    || f->next->fc.index != f->fc.index)
		  {
		    LOCK *lck, *nextlck;
		    nextlck = *fch->lfirst;
		    while ((lck = nextlck) != 0)
		      {
			nextlck = lck->next;
			Kfree (lck);
		      }
		    Kfree (fch->lfirst);
		  }
		Kfree (fch);
		/* Remove this fileptr from the list. */
		*last = f->next;
		f->next = 0;
	      }
	    else
	      last = &f->next;
	  }
	    
	minix_sanity(d);

	return 1;
}

/*
 * Note: in the first round of initialisations, we assume that floppy
 * drives (A and B) don't belong to us; but in a later disk change,
 * they may very well be ours, so we remember that. This is means that a
 * minix disk inserted into a drive will be unrecognisable at boot up and
 * a forced disk change is needed. However for MiNT 1.05 (and presumably
 * later) drives are initialised on first access so this isn't needed.
 */

long m_root(dev,dir)
int dev;
fcookie *dir;
{
	int ret;
	static first_init = 2;
	extern FILESYS dummy_filesys;

	ret=0;
	if( (kernel->maj_version==0 ) || 
		(kernel->maj_version==1 && kernel->min_version < 5 ) ) {
		/* the first 2 checks (on A: and B:) we fail automatically */
		if (first_init ) {
			--first_init;
			return -1;
		}
	}

		/* If not present , see if it's valid */
	if( super_ptr[dev] || ( dev >= 0 && (ret=minix_sanity(dev)) ) ) {
		if(ret==-1 || super_ptr[dev]==DFS ) dir->fs = &dummy_filesys;
		else
		{
			dir->fs=&minix_filesys;
			dir->aux=0;
			dir->index=ROOT_INODE;
		}
		dir->dev=dev;
		return 0;
	}
	return -1;
}

long m_lookup(dir,name,entry)
fcookie *dir; 
char *name;
fcookie *entry;
{
	if(!*name)
	{
		*entry=*dir;
		return 0;
	}
	if(dir->index==ROOT_INODE && !strcmp(name,".."))
	{
		*entry=*dir;
		DEBUG("m_lookup returned EMOUNT");
		return EMOUNT;
	}
	entry->index=search_dir(name,dir->index,dir->dev,FIND);
	if(entry->index < 0 ) return entry->index ;
	entry->dev=dir->dev;
	entry->aux=0;
	entry->fs=&minix_filesys;
	return 0;
}

long m_creat(dir,name,mode,attr,entry)
fcookie *dir;
char *name;
unsigned mode;
int attr;
fcookie *entry;
{
	long pos;
	d_inode ripnew;
	unshort newfile;
	char *ext;
	
	/* Create dir entry */	
	if((pos=search_dir(name,dir->index,dir->dev,ADD))<0)
	{	
		return pos;
	}

	/* Get new inode */
	if(!(newfile=alloc_inode(dir->dev)))
	{
		DEBUG("m_getdev: no free inodes");
		return EWRITF;
	}
	/* Set up inode */
	bzero(&ripnew,sizeof(d_inode));

/* If  creating a file with approriate extensions 
 * automatically give it execute permissions .
 */
	if(do_trans(AEXEC_TOS,dir->dev) && ( ext=strrchr(name,'.') ) )
	{
		ext++;
		if( 
		/* Insert your favourite extensions here */
		  !(  Stricmp(ext,"TTP") && Stricmp(ext,"PRG") 
		   && Stricmp(ext,"APP") && Stricmp(ext,"TOS") 
		   && Stricmp(ext,"ACC") && Stricmp(ext, "GTP")))
				mode |= 0111;
	}
	ripnew.i_mode= I_REGULAR | mode;
	ripnew.i_uid=Getuid();
	ripnew.i_gid=Getgid();
	ripnew.i_nlinks=1;

	ripnew.i_mtime=Unixtime(Timestamp(), Datestamp());
	ripnew.i_atime=ripnew.i_mtime;
	ripnew.i_ctime=ripnew.i_mtime;

	write_inode(newfile,&ripnew,dir->dev);
	l_write(dir->index,pos,2L,&newfile,dir->dev);

	if(cache_mode) l_sync();

	entry->fs = dir->fs;
	entry->dev = dir->dev;
	entry->index=newfile;
	entry->aux=0;
	return 0;
}

DEVDRV * m_getdev(file,special)
fcookie *file;
long *special;
{
	return(&minix_dev);
}

long m_getxattr(file,xattr)
fcookie *file;
XATTR *xattr;
{
        d_inode rip;
	long time_tmp;
	super_info *psblk;
	psblk=super_ptr[file->dev];
	read_inode(file->index,&rip,file->dev);
	/* Minix and gcc use different values for FIFO's */
	if((rip.i_mode & I_TYPE) == I_NAMED_PIPE)
		xattr->mode = S_IFIFO | (rip.i_mode & ALL_MODES);
        else xattr->mode=rip.i_mode;

	/* We could potentially have trouble with symlinks too */
#if I_SYMLINK != S_IFLNK
	if( (rip.i_mode & I_TYPE) == I_SYMLINK)
		xattr->mode = S_IFLNK | (rip.i_mode & ALL_MODES);
#endif

	/* Fake attr field a bit , to keep TOS happy */
	if(IS_DIR(rip))xattr->attr=FA_DIR;
	else xattr->attr=(rip.i_mode & 0222) ? 0 : FA_RDONLY;

        xattr->index=file->index;
        xattr->dev=file->dev;
#if 0
	/* Char and block special files need major/minor device nos filled in */
	if(((rip.i_mode & I_TYPE) == I_CHAR_SPECIAL )||
		( (rip.i_mode & I_TYPE) == I_BLOCK_SPECIAL ))
			xattr->reserved=rip.i_zone[0];
        else xattr->reserved=0;
#endif
        xattr->nlink=rip.i_nlinks;
        xattr->uid=rip.i_uid;
        xattr->gid=rip.i_gid;
        xattr->size=rip.i_size;
	xattr->blksize = BLOCK_SIZE;
/* Note: the nblocks calculation is accurate only if the file is
 * contiguous. It usually will be, and if it's not, it shouldn't
 * matter ('du' will return values that are slightly too high)
 */
	xattr->nblocks = (xattr->size + (BLOCK_SIZE-1)) / BLOCK_SIZE;
	if (xattr->nblocks >= psblk->dzpi)
		xattr->nblocks++;	/* correct for the indirection block */
	if (xattr->nblocks > psblk->ndbl) {
		xattr->nblocks++;	/* correct for double indirection block */
		xattr->nblocks += ((xattr->nblocks-(psblk->ndbl+2))/psblk->zpind);
				/* and single indirection blocks */
	}

	time_tmp=Dostime(_corr(rip.i_mtime));
	xattr->mtime=time_tmp >> 16;
	xattr->mdate=time_tmp & (0xffff);
	time_tmp=Dostime(_corr(rip.i_atime));
	xattr->atime=time_tmp >> 16;
	xattr->adate=time_tmp & (0xffff);
	time_tmp=Dostime(_corr(rip.i_ctime));
	xattr->ctime=time_tmp >> 16;
	xattr->cdate=time_tmp & (0xffff);

	xattr->reserved1=0;
	xattr->reserved2=0;
	xattr->reserved3[0]=0;
	xattr->reserved3[1]=0;

	return 0;
}

long m_chown(file, uid , gid)
fcookie *file;
int uid,gid;
{

	d_inode rip;
	read_inode(file->index,&rip,file->dev);
 	if(uid!=-1)rip.i_uid=uid;
	if(gid!=-1)rip.i_gid=gid;
	rip.i_ctime=Unixtime(Timestamp(),Datestamp());
	write_inode(file->index,&rip,file->dev);
	if(cache_mode) l_sync();
	return 0;
}

long m_chmode(file, mode)
fcookie *file;
unsigned mode;
{
        d_inode rip;
	super_info *psblk=super_ptr[file->dev];

        read_inode(file->index,&rip,file->dev);

        rip.i_mode=(rip.i_mode & I_TYPE)|(mode & ALL_MODES);                
	if(psblk->version)rip.i_ctime=Unixtime(Timestamp(),Datestamp());
	write_inode(file->index,&rip,file->dev);
	if(cache_mode) l_sync();
        return 0;
}


long m_mkdir(dir,name,mode)
fcookie *dir;
char *name;
unsigned mode;
{
	unshort newdir;
	d_inode rip,ripnew;
	long pos;
	int incr;
	dir_struct blank[MAX_INCREMENT*2];
	incr=super_ptr[dir->dev]->increment;
	if((pos=search_dir(name,dir->index,dir->dev,ADD))<0)return pos;
	read_inode(dir->index,&rip,dir->dev);
	if(rip.i_nlinks>=MINIX_MAX_LINK)return EACCDN;
	/* Get new inode */
	if(!(newdir=alloc_inode(dir->dev)))return EACCDN;

	/* Set up inode */
	bzero(&ripnew,sizeof(d_inode));
	ripnew.i_mode=I_DIRECTORY | (mode & 0777);
	ripnew.i_uid=Getuid();
	ripnew.i_gid=Getgid();
	ripnew.i_nlinks=2;
	ripnew.i_mtime=Unixtime(Timestamp(), Datestamp());
	ripnew.i_ctime=ripnew.i_mtime;
	ripnew.i_atime=ripnew.i_mtime;
	write_inode(newdir,&ripnew,dir->dev);

	/* Set up new directory */
	strcpy(blank[0].d_name,".");
	blank[0].d_inum=newdir;
	strcpy(blank[incr].d_name,"..");
	blank[incr].d_inum=dir->index;
	if(l_write((unsigned)newdir,-1L,(long)(DIR_ENTRY_SIZE*2*incr),
		blank,dir->dev)!=(incr*DIR_ENTRY_SIZE*2) )
	{
		ripnew.i_mode=0;
		ripnew.i_nlinks=0;
		write_inode(newdir,&ripnew,dir->dev);
		free_inode(newdir,dir->dev);
		if(cache_mode) l_sync();
		return EACCDN;
	}
	rip.i_nlinks++;
	write_inode(dir->index,&rip,dir->dev);
	l_write(dir->index,pos,2L,&newdir,dir->dev);

	if(cache_mode) l_sync();

	return(0);
}

long m_rmdir(dir,name)
fcookie *dir;
char *name;
{
	long chunk,left;
	long inum;
	int i,incr;
	d_inode rip,rip2;
	if((inum=search_dir(name,dir->index,dir->dev,FIND))<0)return inum;
	read_inode(inum,&rip,dir->dev);
	read_inode(dir->index,&rip2,dir->dev);
	if(!IS_DIR(rip))return EFILNF;
	incr=super_ptr[dir->dev]->increment;
	/* Check if dir is actually empty */
	for(chunk=0;(left=next_zone(&rip,chunk,&temp,dir->dev)/DIR_ENTRY_SIZE);
		chunk++)
	{
		for(i=0;i<left;i+=incr)
		   if (temp.bdir[i].d_inum
		       && (temp.bdir[i].d_name[0] != '.'
			   || temp.bdir[i].d_name[1] != 0)
		       && (temp.bdir[i].d_name[0] != '.'
			   || temp.bdir[i].d_name[1] != '.'
			   || temp.bdir[i].d_name[2] != 0))
			return EACCDN ;
	}
	if(!inode_busy(inum,dir->dev,1))
	{
		trunc_inode(&rip,dir->dev,0L,0);
		rip.i_mode=0;
		free_inode(inum,dir->dev);
	}
	rip.i_nlinks=0;
	write_inode(inum,&rip,dir->dev);
	read_inode(dir->index,&rip,dir->dev);
	rip.i_mtime=Unixtime(Timestamp(), Datestamp());
	rip.i_nlinks--;
	write_inode(dir->index,&rip,dir->dev);
	search_dir(name,dir->index,dir->dev,KILL);

	if( lpath && (ldir.dev==dir->dev) && (ldir.index==inum) )
	{
		Kfree(lpath);
		lpath=0;
	}

	if(cache_mode) l_sync();

	return(0);
}

/* Unix-like unlink ... only works on regular files and symlinks but it should
 * be safe to unlink an open file
 */

long m_remove(dir,name)
fcookie *dir;
char *name;
{
	long inum,ret;
	d_inode rip;
	inum=search_dir(name,dir->index,dir->dev,FIND);
	if(inum<0) return inum;
	read_inode(inum,&rip,dir->dev);
	if(!IS_REG(rip) && ((rip.i_mode & I_TYPE) != I_SYMLINK) ) return EACCDN;

	if((ret=search_dir(name,dir->index,dir->dev,KILL))<0) return ret;	
	if(--rip.i_nlinks==0)
	{
		if(!inode_busy(inum,dir->dev,1)) /* Is inode busy ? */
		{
			trunc_inode(&rip,dir->dev,0L,0);
			rip.i_mode=0;
			free_inode(inum,dir->dev);
		}
	}
	write_inode(inum,&rip,dir->dev);

	if(cache_mode) l_sync();

	return(0);
}

/* This function is inefficient , it uses the standard sys V method of 
 * finding out the pathname of the cwd : for each part of the path, search
 * the parent for a link with the same inode number as '..' , append this to the
 * path until we get to root dir , then reverse order of dirs. This way no 
 * temporary buffers are allocated which could overflow or kmalloc to fail ...
 */

/* In fact its so inefficient a mini-cache remembers the last call info */

long m_getname(root,dir,pathname,length)
fcookie *root,*dir;
char *pathname;
short length;
{
	long inum,pinum;
	int chunk;
	long left;
	int incr;
	short plength;

	if(no_length) length=PATH_MAX;

	if(lpath && lroot.dev==root->dev && 
		lroot.index==root->index && ldir.dev==dir->dev && 
		ldir.index==dir->index)
	{
		TRACE("m_getname: cache hit");
		if(length <= llength) return ENAMETOOLONG;
		strcpy(pathname,lpath);
		return 0;
	}

	*pathname=0;

	if( dir->dev==root->dev && dir->index==root->index ) return 0;

	incr=super_ptr[dir->dev]->increment;
	inum=dir->index;
	plength=0;
	while(inum!=root->index && inum!=ROOT_INODE)
	{
		d_inode rip;
		bufr *tmp;
		pinum=search_dir("..",inum,dir->dev,FIND); 
		/* Parent inum */

		if(pinum < 0) /* If this happens we're in trouble */
		{
			ALERT("No .. in inode %d , drive %c",inum,dir->dev+'A');
			return pinum;
		}
		read_inode(pinum,&rip,dir->dev);
		for(chunk=0;
		(left=cnext_zone(&rip,chunk,&tmp,dir->dev)/DIR_ENTRY_SIZE) &&
		inum!=pinum ;chunk++)
		{
			char tname[MNAME_MAX+1];
			int i;
			for(i=0;i<left && inum!=pinum ;i+=incr)
			if(tmp->bdir[i].d_inum==inum)
			{
				strncpy(tname,tmp->bdir[i].d_name,MMAX_FNAME(incr));
				tname[MMAX_FNAME(incr)]=0;
				strrev(tname);
				plength+=strlen(tname)+1;
				if(length <= plength) return ENAMETOOLONG;
				strcat(pathname,tname);
				strcat(pathname,"\\");
				inum=pinum;
			}
		}
		if(left==0 && inum!=pinum) {
			ALERT("m_getname inode %d orphaned or bad ..",inum);
			return EINTRN;
		}
	}
	if(inum==ROOT_INODE && root->index!=ROOT_INODE)
	{
		DEBUG("m_getname: Hmmmm root is not a parent of dir");
		return EINTRN;
	}
	strrev(pathname);
	if(lpath)Kfree(lpath);
	if( (lpath=Kmalloc(strlen(pathname)+1)) )
	{
		strcpy(lpath,pathname);
		llength=plength;
	}

	lroot=*root;
	ldir=*dir;
	return 0;
}


long m_opendir(dirh,flag)
DIR *dirh;
int flag;
{
        d_inode rip;
	read_inode(dirh->fc.index,&rip,dirh->fc.dev);
	dirh->index=0;
	return 0;
}

long m_readdir(dirh,name,namelen,fc)
DIR *dirh;
char *name;
int namelen;
fcookie *fc;
{
        d_inode rip;
	bufr *tmp;
	unsigned entry,chunk;
	super_info *psblk;
	long limit;
	int flag,incr;
	psblk=super_ptr[dirh->fc.dev];
	if(dirh->flags) flag=do_trans(DIR_TOS,dirh->fc.dev);
	else flag=0;
	if(!dirh->fc.index)return EACCDN;
	entry=dirh->index % NR_DIR_ENTRIES;
	chunk=dirh->index / NR_DIR_ENTRIES;	
	read_inode(dirh->fc.index,&rip,dirh->fc.dev);
	incr=psblk->increment;

	while( (limit=cnext_zone(&rip,chunk,&tmp,dirh->fc.dev)/DIR_ENTRY_SIZE) )
	{
		while( entry < limit)
	  	{
			dir_struct *try=&tmp->bdir[entry];
			entry+=incr;
			if(try->d_inum)
			{
				char *tmpnam;
				tmpnam=tosify(try->d_name,flag,MMAX_FNAME(incr));

				if (dirh->flags==0)
				{
					namelen -= sizeof(long);
					if (namelen <= 0) return ERANGE;
					*((long *)name) = (long)try->d_inum;
					name += sizeof(long);
	       			}

				strncpy(name,tmpnam,namelen);
				dirh->index=entry+chunk*NR_DIR_ENTRIES;
			/* set up a file cookie for this entry */
				fc->dev = dirh->fc.dev;
				fc->aux = 0;
				fc->index = (long)try->d_inum;
				fc->fs = &minix_filesys;
				if(strlen(tmpnam) >= namelen) 
					return ENAMETOOLONG;
				/* If turbo mode set atime here: we'll only
				 * change the cache here so it wont cause
				 * lots of I/O
				 */
				if( cache_mode==TURBO
					&& super_ptr[dirh->fc.dev]->version
					&& dirh->fc.dev > 1 )
							   set_atime(&dirh->fc);
				return 0;
			}
		}
		if(entry!=NR_DIR_ENTRIES)return ENMFIL;
		else entry=0;
		chunk++;
	}
	return ENMFIL;
}

long m_rewinddir(dirh)
DIR *dirh;
{
	dirh->index=0;
	return 0;
}

long m_closedir(dirh)
DIR *dirh;
{

/* Access time is set here if we aren't in TURBO cache mode. Otherwise we
 * would be sync'ing on every dir read which would be far too slow. See note
 * in set_atime().
 */

	if( cache_mode!=TURBO && super_ptr[dirh->fc.dev]->version && 
			dirh->fc.dev > 1 )
	{
		set_atime(&dirh->fc);
		l_sync();
	}

	dirh->fc.index=0;
	return 0;
}

/* Set the atime of a V2 inode for directories. There is a snag here: if the
 * disk is changed then this is likely not to be written out before the whole
 * cache is invalidated. So we set the status to '3' which means that it is
 * not alerted if this is dirty when invalidated (hardly the end of the world
 * if the atime is slightly wrong!)
 */
void set_atime(fc)
fcookie *fc;
{
	d_inode *rip;
	int *status;
	rip=get_inode2(fc->index,fc->dev,&status,NOGUESS);
	rip->i_atime=Unixtime(Timestamp(),Datestamp());
	if(*status!=2) *status=3;
}


long m_rlabel(dir,name,namelen)
fcookie *dir;
char *name;
int namelen;
{
	return EFILNF;
}

long m_wlabel(dir,name)
fcookie *dir;
char *name;
{
	return EACCDN;
}

long m_dfree(dir,buffer)
fcookie *dir;
long *buffer;
{
	super_info *psblk ;
	psblk = super_ptr[dir->dev];
	buffer[1] = psblk->sblk.s_zones-psblk->sblk.s_firstdatazn;
	buffer[0] = buffer[1] - count_bits(psblk->zbitmap,buffer[1]+1)+1;
	buffer[2]=512L;
	buffer[3]=2L;
	return(0);
}

long m_fscntl(dir,name,cmd,arg)
fcookie *dir;
char *name;
int cmd;
long arg;
{
	FILEPTR *f;
	mfs_info *inf;
	super_info *psblk;
	long inum;
	int uid,id;
	d_inode rip;
	extern long init_addr;

	uid = Geteuid ();

	switch(cmd)
	{
		case MFS_VERIFY:
		*((long *)arg)=MFS_MAGIC;
		return 0;

		/* Sync the filesystem */
		case MFS_SYNC:
		TRACE("Done l_sync()");
		l_sync();
		return 0;

		/* Invalidate all cache entries for a given drive */
		case MFS_CINVALID:
		if(uid) return EACCDN;
		m_invalidate(dir->dev);
		return 0;

		/* Invalidate all fileptrs for a given drive */
		case MFS_FINVALID:
		if(uid) return EACCDN;
		id=Getpid();
		for(f=firstptr;f;f=f->next)if(f->fc.dev==dir->dev)m_close(f,id);
		return 0;

		case MFS_INFO:
		psblk=super_ptr[dir->dev];
		inf=(mfs_info *)arg;
		inf->total_zones=psblk->sblk.s_zones-psblk->sblk.s_firstdatazn;
		inf->total_inodes=psblk->sblk.s_ninodes;
		inf->version=psblk->version+1;
		inf->increment=psblk->increment;		
		inf->free_inodes=inf->total_inodes-
			count_bits(psblk->ibitmap,inf->total_inodes+1)+1;
		inf->free_zones=inf->total_zones-count_bits(psblk->zbitmap,inf->total_zones+1)+1;
		return 0;

		case MFS_IMODE:
		if(uid) return EACCDN;
		inum=search_dir(name,dir->index,dir->dev,FIND);
		if(inum < 0 ) return inum;
		read_inode(inum,&rip,dir->dev);
		rip.i_mode=arg;
		write_inode(inum,&rip,dir->dev);
		return 0;

		case MFS_GTRANS:
		*((long *) arg)=fs_mode[dir->dev];
		return 0;

		case MFS_STRANS:
		if(uid) return EACCDN;
		fs_mode[dir->dev]=*((long *)arg);
		return 0;

		case MFS_PHYS:
		*((struct phys_part *)arg)=ppart[dir->dev];
		return 0;

		case MFS_IADDR:
		*((long *)arg)=(long)&init_addr;
		return 0;

		case MFS_UPDATE:
		if(cache_mode!=TURBO) return -1;
		switch(arg)
		{
			case 0:
			return update_suspend;

			case 1:
			TRACE("Minixfs: update suspended");
			update_suspend=1;
			return 0;

			case 2:
			TRACE("Minixfs: update restarted");
			update_suspend=0;
			return 0;

			case 3:
			return update_pid;

			default:
			return EINVFN;
		}

		default:
		return EINVFN;
	}
}

/* m_rename , move a file or directory . Directories need special attention 
 * because if /usr/foo is moved to /usr/foo/bar then the filesystem will be
 * damaged by making the /usr/foo directory inaccessible. The sanity checking
 * performed is very simple but should cover all cases: Start at the parent
 * of the destination , check if this is the source inode , if not then 
 * move back to '..' and check again , repeatedly check until the root inode
 * is reached , if the source is ever seen on the way back to the root then
 * the rename is invalid , otherwise it should be OK.
 */

long m_rename(olddir,oldname,newdir,newname)
fcookie *olddir;
char *oldname;
fcookie *newdir;
char *newname;
{
	long finode,ret;
	d_inode rip;
	long pos;
	char dirmove,dirren;
	dirmove=0;
	dirren=0;
/* Check cross drives */
	if(olddir->dev!=newdir->dev)return EXDEV;

/* Check new doesn't exist and path is otherwise valid */
	finode=search_dir(newname,newdir->index,newdir->dev,FIND);
	if(finode>0) return EACCDN;
	if(finode!=EFILNF) return finode;

/* Check old path OK */
	if((finode=search_dir(oldname,olddir->index,olddir->dev,FIND))<0)
		return finode;

	read_inode(finode,&rip,olddir->dev);

/* Sanity check movement of directories */
	if(IS_DIR(rip))
	{
		dirren=1;
	 	if(olddir->index!=newdir->index)
		{
#ifdef MFS_NMOVE_DIR
			return EACCDN;
#else
			d_inode riptemp;
			ret=is_parent(newdir->index,finode,olddir->dev);
			if(ret < 0) return ret;
			if(ret) return EACCDN;
			read_inode(newdir->index,&riptemp,newdir->dev);
			if(riptemp.i_nlinks==MINIX_MAX_LINK) return EACCDN;
			TRACE("minixfs: valid directory move");
			dirmove=1;
#endif
		}
	}

	/* Check the m_getname cache is not invalidated by this move ....
	if no dir move, invalidate if the ldir is the name being changed ,
	if we move dir's then if the olddir is a parent of ldir , invalidate */

	if (lpath && ldir.dev == olddir->dev
	    && (ldir.index == finode
		|| (dirmove && is_parent (ldir.index, finode, olddir->dev) > 0)))
	{
		Kfree (lpath);
		lpath=0;
	}
		
/* Create new entry */
      if((pos=search_dir(newname,newdir->index,newdir->dev,ADD))<0) return pos;
/* Delete old path */
	if((finode=search_dir(oldname,olddir->index,olddir->dev,KILL))<0)
			return finode;
	{
	  unshort ino = finode;
	  l_write (newdir->index, pos, 2L, &ino, newdir->dev);
	}

/* When moving directories , fixup things like '..' and nlinks of old and
 * new dirs
 */

	if(dirmove)
	{
		pos=search_dir("..",finode,newdir->dev,POS);
		if(pos<0) 
		{
			ALERT("m_rename: no .. in inode %ld",finode);
			return EACCDN;
		}
		if(pos!=DIR_ENTRY_SIZE*super_ptr[newdir->dev]->increment)
		  ALERT("m_rename: Unexpected .. position in inode %ld",finode);
		{
		  unshort ino = newdir->index;
		  l_write (finode, pos, 2L, &ino, newdir->dev);
		}
		read_inode(olddir->index,&rip,olddir->dev);
		rip.i_nlinks--;
		write_inode(olddir->index,&rip,olddir->dev);
		read_inode(newdir->index,&rip,newdir->dev);
		rip.i_nlinks++;
		write_inode(newdir->index,&rip,newdir->dev);
	}

	if(cache_mode) l_sync();

/* Check the m_getname cache is not invalidated by this move ....
 * if no dir alter, invalidate if the ldir is the name being changed ,
 * if we alter dir's then if the moved dir is a parent of ldir , invalidate.
 */

	if (lpath && ldir.dev == olddir->dev
	    && (ldir.index == finode
		|| (dirren && is_parent (ldir.index, finode, olddir->dev) > 0)))
	{
		Kfree (lpath);
		lpath=0;
	}

	return 0;
}

/* Minix hard-link , you can't make a hardlink to a directory ... it causes
 * too much trouble , use symbolic links instead.
 */

long m_hardlink(fromdir,fromname,todir,toname)
fcookie *fromdir;
char *fromname;
fcookie *todir;
char *toname;
{
	long finode;
	d_inode rip;
	long pos;

/* Check cross drives */
	if(fromdir->dev!=todir->dev)return EXDEV;

/* Check new doesn't exist and path is otherwise valid */
	finode=search_dir(toname,todir->index,todir->dev,FIND);
	if(finode>0) return EACCDN;
	if(finode!=EFILNF) return finode;

/* Check old path OK */
	if((finode=search_dir(fromname,fromdir->index,fromdir->dev,FIND))<0)
		return finode;

	read_inode(finode,&rip,fromdir->dev);
	if(!IS_REG(rip) || (rip.i_nlinks >=MINIX_MAX_LINK) ) return EACCDN;

/* Create new entry */
	if((pos=search_dir(toname,todir->index,todir->dev,ADD))<0) return pos;
	{
	  unshort ino = finode;
	  l_write (todir->index, pos, 2L, &ino, todir->dev);
	}
	rip.i_nlinks++;
	rip.i_ctime=Unixtime(Timestamp(),Datestamp());
	write_inode(finode,&rip,fromdir->dev);

	if(cache_mode) l_sync();

	return 0;
}

/* Symbolic links ... basically similar to a regular file with one zone */

long m_symlink(dir,name,to)
fcookie *dir;
char *name;
char *to;
{
	d_inode rip;
	long pos;
	unshort newinode;

	if(!*to)
	{
		DEBUG("m_symlink: invalid null filename");
		return EACCDN;
	}

	if(strlen(to)>=SYMLINK_NAME_MAX)
	{
		DEBUG("minixfs: Symbolic link name too long");		
		return ERANGE;
	}

	if((pos=search_dir(name,dir->index,dir->dev,ADD))<0) return pos;

	if(!(newinode=alloc_inode(dir->dev)))
	{
		DEBUG("minixfs: symlink drive %c,no free inodes",dir->dev+'A');
		return EACCDN;
	}
	

	bzero(&rip,sizeof(d_inode));
	rip.i_mode=I_SYMLINK | 0777;
	rip.i_size=strlen(to)+1;
	rip.i_uid=Getuid();
	rip.i_gid=Getgid();
	rip.i_mtime=Unixtime(Timestamp(),Datestamp());
	rip.i_ctime=rip.i_mtime;
	rip.i_atime=rip.i_mtime;
	rip.i_nlinks=1;

	if(!(rip.i_zone[0]=alloc_zone(dir->dev)))
	{
		free_inode(newinode,dir->dev);
		DEBUG("minixfs: symlink drive %c no free zones",dir->dev+'A');
		return EACCDN;
	}
	btos_cpy((char *)&temp,to);
 	write_zone(rip.i_zone[0],&temp,dir->dev,&syscache);
	write_inode(newinode,&rip,dir->dev);
	l_write(dir->index,pos,2L,&newinode,dir->dev);

	if(cache_mode) l_sync();

	return 0;
}

long m_readlink(file,buf,len)
fcookie *file;
char *buf;
int len;
{
	long inum = file->index;
	d_inode rip;

	read_inode(inum,&rip,file->dev);
	if( (rip.i_mode & I_TYPE)!=I_SYMLINK)
	{
		DEBUG("minixfs: attempted readlink on non-symlink");
		return EACCDN;
	}
	read_zone(rip.i_zone[0],&temp,file->dev,&syscache);
	if(stob_ncpy(buf, (char *) &temp,len))
	{
		DEBUG("m_readlink: name too long");
		return ERANGE;
	}
	TRACE("m_readlink returned %s",buf);

	return 0;
}

/* the only settable attribute is FA_RDONLY; if the bit is set,
 * the mode is changed so that no write permission exists
 */
long m_chattr(file,attr)
fcookie *file;
int attr;
{
        long inum = file->index;
	int drive = file->dev;
	d_inode rip;

	if ( (attr & FA_RDONLY) ) {
		read_inode(inum,&rip,drive);
		rip.i_mode &= ~(0222);	/* turn off write permission */
		rip.i_ctime=Unixtime(Timestamp(),Datestamp());
		write_inode(inum,&rip,drive);
		if(cache_mode) l_sync();
	} else if (attr == 0) {
		read_inode(inum,&rip,drive);
		if ( (rip.i_mode & 0222) == 0 ) {
			rip.i_mode |= ( (rip.i_mode&0444) >> 1 );
				/* turn write permission back on */
			rip.i_ctime=Unixtime(Timestamp(),Datestamp());
			write_inode(inum,&rip,drive);
			if(cache_mode) l_sync();
		}
	}
	return 0;
}

long m_pathconf(dir,which)
fcookie *dir;
int which;
{
	switch(which) {
	case -1:
		return DP_MAXREQ;
	case DP_IOPEN:
		return UNLIMITED;
	case DP_MAXLINKS:
		 return MINIX_MAX_LINK;
	case DP_PATHMAX:
		return UNLIMITED; /* At last ! */
	case DP_NAMEMAX:
		return MMAX_FNAME(super_ptr[dir->dev]->increment);
	case DP_ATOMIC:
		return BLOCK_SIZE;	/* we can write at least a block atomically */
	case DP_TRUNC:
		return DP_AUTOTRUNC;
	case DP_CASE:
		return DP_CASESENS;	/* Well sort of ... */
	default:
		return EINVFN;
	}
}

long m_release(fc)
fcookie *fc;
{
	return 0;
}

long m_dupcookie(dest,src)
fcookie *dest,*src;
{
	*dest=*src;
	return 0;
}



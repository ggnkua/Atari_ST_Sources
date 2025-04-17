/* Filesystem checker : Contains most of the elements of BSD fsck(8) that
 * make sense under minix filesystems.
 * Copyright 1992 S.N. Henson, all rights reserved.
 * Version 0.0 pre-alpha [i.e. likely to be buggy].
 */

/* Patchlevel 6 */

#include <sys/types.h>
#include <unistd.h>
#include <alloc.h>
#include <time.h>
#include <stdio.h>
#include <macros.h>		/* For min(x,y) */
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "fs.h"
#include "fsck.h"
#include "global.h"
#include "proto.h"
#include "stproto.h"

void do_fsck()
{
	int pass;
	long i;

	read_tables();

/* Filesystem dependent check */

	if( Super->s_firstdatazn != ( 2+Super->s_zmap_blks+Super->s_imap_blks
			+(Super->s_ninodes+IPB-1)/IPB) )
			sfatal("Invalid First Data Zone");

/* Allocate status arrays */

	ibitmap=calloc(BLOCKSIZE*(Super->s_zmap_blks*2 + Super->s_imap_blks) +
					sizeof(inode_stat)*Super->s_ninodes,1);

	if(!ibitmap)fatal("No memory for Zone bitmaps");

	zbitmap=(unsigned *)( ( (long)ibitmap )+ BLOCKSIZE*Super->s_imap_blks);
	szbitmap=(unsigned *)( ( (long)zbitmap ) + BLOCKSIZE*Super->s_zmap_blks);
	inode_status=(inode_stat *)(szbitmap +(szbitmap-zbitmap));

	setbit(0,szbitmap);

	/* Flags for root inode */
	inode_status->flag |= I_FOUND;
	inode_status->parent= ROOT_INODE;

	/* Read in all bitmaps */
	read_blocks(2,Super->s_imap_blks+Super->s_zmap_blks,ibitmap);
	ioff=2+Super->s_imap_blks+Super->s_zmap_blks;

	check_root();

	printf("Pass 1 Checking All Inodes\n");

	ist=inode_status;
	next_init();

	for(cino=ROOT_INODE;cino<=maxino;cino++,ist++)
	{
		next_inode();
		if(badroot && (cino==ROOT_INODE) ) continue;
		ist->links=rip->i_nlinks;
		switch(rip->i_mode & I_TYPE)
		{
			case I_NOT_ALLOC:
			ist->flag|=I_FREE;
			if(rip->i_nlinks)
			{
				printf("Non zero link count for Free inode %ld\n",cino);
				if(ask("Alter?","Altered"))
				{
					rip->i_nlinks=0;
					ist->links=0;
					cdirty=1;
				}
			}
			break;

			case I_CHAR_SPECIAL:
			nchr++;
			break;

			case I_BLOCK_SPECIAL:
			nblk++;
			break;

			case I_NAMED_PIPE:
			nfifo++;
			break;

			case I_REGULAR:
			nreg++;
			traverse_zones(pass1);
			break;

			case I_DIRECTORY:
			ndir++;
			if(rip->i_size & (DSIZE*incr-1))
			{
				inerr("Partial Entry");
				if(ask("Truncate?","Truncated"))
				{
					rip->i_size &= ~(DSIZE*incr-1);
					cdirty=1;
					trunc=2;
				}
			}
			traverse_zones(pass1);
			trunc=0;
			ist->flag|=I_DIR;
			break;

			case I_SYMLINK:
			nsym++;
			traverse_zones(pass1);
			break;

			default:
			printf("Unknown Mode 0%o Inode %ld\n",rip->i_mode,cino);
			if(ask("Clear?","Cleared"))
			{
				*rip=zinode;
				cdirty=1;
				ist->links=0;
			}
		}
	}

	if(fzlist)
	{
		if(preen) fatal("Duplicate zones found when preening");
		printf("Pass 1a finding duplicate zones\n");
		next_init();
		for(cino=ROOT_INODE;cino<=maxino;cino++)
		{
			next_inode();
			if(badroot && (cino==ROOT_INODE) ) continue; 
			switch(rip->i_mode & I_TYPE)
			{
				case I_SYMLINK:
				case I_REGULAR:
				case I_DIRECTORY:
				traverse_zones(pass1a);

				default:
				break;
			}
		}
	}

	next_init();

	if(badroot) fix_root();

	for(pass=0;pass<4;pass++)
	{
		char first=0;
		switch(pass)
		{
			case 0:
			printf("Pass 2 Reading Directories\n");
			break;
			
			case 1:
			printf("Pass 3 Checking Connectivity\n");
			break;

			case 2:
			case 3:
			first=0;
			break;
		}
		read_inode_init();
		ist=inode_status;
		for(cino=ROOT_INODE;cino<=maxino;cino++,ist++)
		{
			if(!(ist->flag & I_DIR)) continue;
			if( (pass==2) && !(ist->flag & I_LINK) ) continue;
			if( (pass==3) && ( !(ist->flag & (I_FDD|I_FIXDD)) 
					|| !(ist->flag & I_DD) ) ) continue;
			read_inode();
			switch(pass)
			{
				case 0:
				check_dots();
				break;

				case 1:
				traverse_dir(pass2);
				break;

				case 2:
				if(!first)
				{
					printf("Pass 3a Fixing Directories\n");
					first=1;
				}
				traverse_dir(pass2a);
				break;

				case 3:
				if(!first)
				{
					printf("Pass 3b Fixing Dots\n");
					first=1;
				}
				fix_dots();
				break;
			}
		}
	}
	ist=inode_status;

	if(inolist)
	{
		ilist *p;
		for(p=inolist;p;p=p->next) show_name(p);
	}

	for(cino=ROOT_INODE;cino<=maxino;cino++,ist++)
	{

		if( !(ist->flag & I_FOUND) && !(ist->flag & I_FREE) )
		{
			inerr("Orphaned Inode");
			if(ask("Reconnect?","Reconnected"))
			{
			    dir_struct tdir[DPB/2];
			    unsigned tino;
			    if(lfinode || mklost() )
			    {
				read_inode();
				cdirty=1;
				tino=cino;
				rip->i_nlinks++;

				/* Fix link count as well */
				rip->i_nlinks-=ist->links;
				ist->links=0;

				/* Update '..' */
				if(ist->flag & I_DD)
				{
				    dir_struct dir[DPB];
				    read_zone(rip->i_zone[0],dir);
				    dir[incr].d_inum=lfinode;
				    write_zone(rip->i_zone[0],dir);

				    if(chk_irange(ist->parent))
				    {	
					inode_status[ist->parent-1].links++;
					cino=ist->parent;
					read_inode();
					cdirty=1;
					rip->i_nlinks--;
				    }

				}

				cino=lfinode;
				sprintf(tdir[0].d_name,"%d",tino);
				tdir[0].d_inum=tino;

				read_inode();
				if(ist->flag & I_DD) rip->i_nlinks++;
				cdirty=1;
				add_dirent(tdir);
				cino=tino;
			    }
			else printf("Cannot Reconnect\n");
			}	
		}

		if(ist->links)
		{
			printf("Inode %ld Bad Link Count\n",cino);
			if(ask("Alter?","Altered"))
			{
				read_inode();
				rip->i_nlinks-=ist->links;
				ist->links=0;
				cdirty=1;
			}
		}

	}

	read_inode_init();

	printf("Checking Zone Bitmap\n");
	for(i=1;i<=maxzone-minzone+1;i++)
	{
		if(!isset(i,szbitmap))
		{
			zfree++;
			if(isset(i,zbitmap)) berr++;
		}
		else if(!isset(i,zbitmap)) berr++;
	}

	if(berr)
	{
		printf("Zone Bitmap : %ld Errors\n",berr);
		if(ask("Install A New Map?","Fixed"))
		{
			for(i=1;i<=maxzone-minzone+1;i++)
			{
				if(isset(i,szbitmap)) setbit(i,zbitmap);
				else clrbit(i,zbitmap);
			}
			write_blocks(2+Super->s_imap_blks,Super->s_zmap_blks,zbitmap);
		}
	}
	else printf("Zone Bitmap OK\n");

	berr=0;
	ist=inode_status;
	printf("Checking Inode Bitmap\n");

	for(i=ROOT_INODE;i<=maxino;i++,ist++)
	{
		if( ist->flag & I_FREE)
		{
			ifree++;
			if(isset(i,ibitmap)) berr++;
		}
		else if(!isset(i,ibitmap)) berr++;
	}

	if(berr)
	{
		printf("Inode Bitmap : %ld Errors\n",berr);
		if(ask("Install A New Map?","Fixed"))
		{
			ist=inode_status;
			for(i=ROOT_INODE;i<=maxino;i++,ist++)
			{
				if(ist->flag & I_FREE) clrbit(i,ibitmap);
				else setbit(i,ibitmap);
			}
			write_blocks(2,Super->s_imap_blks,ibitmap);
		}
	}
	else printf("Inode Bitmap OK\n");

	read_inode_init();

}

/* traverse_zones passes pointers of the zone numbers of inode 'rip' to the 
 * function argument, if the value returned is non-zero then number was altered.
 * Also pass a 'level' parameter, this is zero for zone numbers, 1 for 
 * indirection blocks and 2 for double indirection blocks.
 */

static void traverse_zones(func)
int (*func)(zone_nr *zone,unsigned level);
{
	zone_nr i,j;
	zone_nr tmp1[NINDIR],tmp2[NINDIR];

	zonecount=(rip->i_size+BLOCKSIZE-1)/BLOCKSIZE;
	indcount=NO_IND(zonecount);
	dindcount=NO_DBL(zonecount);

	if(trunc!=2) trunc=0; /* 2 means silently truncate (directory) */
	done_trunc=0;

	for(i=0;i<NR_ZONE;i++)
		if( (*func)(&rip->i_zone[i],(i<NDIR) ? 0 : (i-NDIR+1) ) )
								       cdirty=1;

	if( chk_range(rip->i_zone[NDIR]) )
	{
		int zdirty=0;
		read_zone(rip->i_zone[NDIR],tmp1);

		for(i=0;i<NINDIR;i++) if( (*func)(&tmp1[i],0) ) zdirty=1;
		if(zdirty) write_zone(rip->i_zone[NDIR],tmp1);
	}
	else zonecount-=NINDIR;

	if( chk_range(rip->i_zone[NDIR+1]) )
	{
		int zdirty=0;
		read_zone(rip->i_zone[NDIR+1],tmp1);
		for(i=0;i<NINDIR;i++)
		{
			if( (*func)(&tmp1[i],1) )
			{
				zdirty=1;
				continue;
			}
			if( chk_range(tmp1[i]) )
			{
				int zdirty2=0;
				read_zone(tmp1[i],tmp2);
				for(j=0;j<NINDIR;j++)
					if( (*func)(&tmp2[j],0) ) zdirty2=1;
				if(zdirty2) write_zone(tmp1[i],tmp2);
			}
			else zonecount-=NINDIR;

			if(zdirty) write_zone(rip->i_zone[NDIR+1],tmp1);
		}
	}
}

/* Pass 1 zone traversal , check zone range and note in bitmap, do truncation
 * if too many zones.
 */

static int pass1(zone,level)
zone_nr *zone;
unsigned level;
{

	if(!done_trunc || trunc)
	{
		switch(level)
		{
			case 0:

			if(zonecount==0)
			{
				if(*zone && ( trunc || do_trunc() ) )
				{
					*zone=0;
					return 1;
				}
			}
			else zonecount--;
			break;

			case 1:
			if(indcount==0)
			{
				if(*zone && ( trunc || do_trunc() ) )
				{
					*zone=0;
					return 1;
				}
			}
			else indcount--;
			break;

			case 2:
			if(dindcount==0)
			{
				if(*zone && (trunc || do_trunc() ) )
				{
					*zone=0;
					return 1;
				}
			}
			else dindcount--;
			break;
		}
	}

	if(!*zone) return 0; /* zero is legitimate */
	if( (*zone < minzone) || (*zone > maxzone) )
	{
		printf("Zone number out of range in inode %ld\n",cino);
		if(ask("Remove?","Removed"))
		{
			*zone=0;
			return 1;
		}
	}

	if(mark_zone(*zone)) add_dup(*zone);
	return 0;
}

/* Comment : at the end of pass 1 we have a (possibly empty) list of duplicate
 * zones. The crucial point is that they are in the order of finding by 
 * traverse_zones, except the first element is missing, this is tackled by
 * pass1a.
 */

/* Pass 1a zone traversal , find first duplicate zones and fix */

static int pass1a(zone,level)
zone_nr *zone;
unsigned level;
{
	if(!chk_range(*zone)) return 0;
	if(is_dup(*zone))
	{
		/* Found first member of duplicate zones, prepend
		 * to list.
		 */

		zlist *new;
		new=malloc(sizeof(zlist));
		if(!new) fatal("No memory for duplist\n");
		new->next=fzlist;
		new->mod=rip->i_mtime;
		new->inum=cino;
		new->zone=*zone;
		new->flag=0;
		fzlist=new;
		do_dup(*zone);
	}
	if(is_rem(*zone))
	{
		printf("Removing Zone %ld Inode %ld\n",(long)*zone,cino);
		*zone=0;
		return 1;
	}
	return 0;
}

/* add_dup(zone) adds 'zone' to the duplicate list, this is put at the end
 * so that the duplicate zone reflects the position of finding.
 */

static void add_dup(zone)
zone_nr zone;
{
	zlist *tlist;
	tlist=(zlist *)malloc(sizeof(zlist));
	if(!tlist) fatal("No memory for duplicate list");
	tlist->zone=zone;
	tlist->inum=cino;
	tlist->mod=rip->i_mtime;
	tlist->next=NULL;
	tlist->flag=0;
	if(lzlist)
	{
		lzlist->next=tlist;
		lzlist=tlist;
	}
	else
	{
		fzlist=tlist;
		lzlist=tlist;
	}
}

/* This determines what happens when duplicate zones are all found, the
 * flag FOUND is set on each zone so that we now know that all the list
 * of duplicates for this zone is complete. The user has the choice to
 * remove each zone. Each removal is noted by the flag REMOVE, so that
 * when the zones are tested by is_rem(), they are removed in order.
 */

static void do_dup(zone)
zone_nr zone;
{
	zlist *p;
	printf("Zone %ld is multiply allocated\nInode list:\n",(long)zone);
	for(p=fzlist;p;p=p->next)
	{
		if(p->zone!=zone)continue;
		p->flag|=FOUND;
		printf("Inode %d\n",p->inum);
		printf("Mod time %s\n",ctime(&p->mod));
		if(ask("Remove Zone?","Removed")) p->flag |=REMOVE;
	}
}

/* Return non-zero if 'zone' is a duplicate. If the FOUND flag is set for
 * this zone ignore the request, as it means that this duplicate zone list
 * is complete.
 */

static int is_dup(zone)
zone_nr zone;
{
	zlist *p;
	for(p=fzlist;p;p=p->next)
		if(p->zone==zone)
		{
			if(p->flag & FOUND) return 0;
			return 1;
		}
	return 0;
}

/* Returns non-zero if zone is marked for removing, if it is marked then
 * remove the zone member from the duplicate list. If it isn't then set 
 * the flag IGNORE so that subsequent is_rem()'s pass over it silently.
 * If the zone is removed and no zones remain with this number, free its
 * entry in the zone bitmap.
 */

static int is_rem(zone)
zone_nr zone;
{
	zlist *p,*q;
	for(p=fzlist,q=0;p;p=p->next)
	{
		if( (p->zone==zone) && !(p->flag & IGNORE))
		{
			if(p->flag & REMOVE)
			{
				if(!q) fzlist=p->next;
				else q->next=p->next;
				free(p);
				if(p==lzlist) lzlist=q;
				/* Last reference ? */
				for(p=fzlist;p && (p->zone!=zone);p=p->next) ;
				if(!p) unmark_zone(zone);
				return 1;
			}
			p->flag |= IGNORE;
			return 0;
		}
		q=p;
	}
	return 0;
}

/* check_root() test the root inode, determine directory increment if none
 * specified.
 */

static void check_root()
{
	dir_struct dir[DPB];
	int i;
	read_inode_init();
	cino=ROOT_INODE;
	read_inode();
	if((rip->i_mode & I_TYPE)!=I_DIRECTORY)
	{
		fprintf(stderr,"Root Inode Not a Directory\n");
		if(!incr)
		{
			fprintf(stderr,"Enter Increment Manually with '-d' option\n");
			close_device();
			exit(1);
		}
		if(!ask("Reallocate?","Reallocated"))
		{
			close_device();
			exit(1);
		}
		badroot=1;
		return;
	}

	if(incr) return;
	if(!chk_range(rip->i_zone[0]))
	{
		fprintf(stderr,"Bad First Zone In Root Inode\n");
		if(!ask("Assume Increment 1?","Assuming increment 1"))
		{
			close_device();
			exit(1);
		}
		incr=1;
		return;	
	}

	read_zone(rip->i_zone[0],dir);

	if(strcmp(dir->d_name,"."))
	{
		fprintf(stderr,"No or bad '.' in Root Inode.\n");
		fprintf(stderr,"Use the '-d' option to set increment.\n");
		close_device();
		exit(1);
	}

	for(i=1;i<DPB;i++) if(!strcmp(dir[i].d_name,"..")) break;

	if(NPOW2(i) || (i > 8))
	{
		fprintf(stderr,"Can't Work Out Increment: Use the -d option\n");
		close_device();
		exit(1);
	}

	incr=i;
	return;
}

/* traverse_dir(), send all the entries of a dir (with the entry number),
 * to the function 'func'. If this returns non-zero then the entry was
 * modified, BUG: Ignores double-indirection block, but anyone with a
 * directory this big must be doing it to try and fool us (it means more
 * than 33000 entries !).
 */

static void traverse_dir(func)
int (*func)();
{
	unsigned entry=0;
	long nentries=rip->i_size/(DSIZE*incr),i;
	zone_nr nzones=(nentries+DPB/incr-1)/(DPB/incr);
	dir_struct dir[DPB];
	zone_nr znr;
	for(znr=0;znr < min(NDIR,nzones); znr++)
	{
		if(chk_range(rip->i_zone[znr]))
		{
			int zdirty=0;
			read_zone(rip->i_zone[znr],dir);
			for(i=0;(i<min(DPB/incr,nentries)) && !quit_trav;
								    i++,entry++)
				if((*func)(&dir[i*incr],entry)) zdirty=1;
			if(zdirty) write_zone(rip->i_zone[znr],dir);
			if(quit_trav) return;
		}
		else entry +=DPB/incr;
		nentries-=DPB/incr;
		if(nentries<=0) return;
	}
	nzones-=NDIR;
	if(chk_range(rip->i_zone[NDIR]) )
	{
		zone_nr tmp[NINDIR];
		read_zone(rip->i_zone[NDIR],tmp);
		for(znr=0;znr<min(NINDIR,nzones);znr++)
		{
			if(chk_range(tmp[znr]))
			{
				int zdirty=0;
				read_zone(tmp[znr],dir);
				for(i=0;(i<min(DPB/incr,nentries)) && !quit_trav;
								i++,entry++)
					if( (*func)(&dir[i*incr],entry) )zdirty=1;
				if(zdirty) write_zone(tmp[znr],dir);
				if(quit_trav) return;
			}
			else entry +=DPB/incr;
			nentries-=DPB/incr;
			if(nentries<=0) return;
		}
	}
}

/* Add an entry to a dir, this uses traverse_dir to see if there are any
 * free slots, if not then add a zone.
 */

static long lastentry;
static dir_struct *add;
static dir_struct newzone[DPB];

static int add_dirent(adir)
dir_struct *adir;
{
	long tsize,zoneadd,addz;
	tsize=rip->i_size;
	/* Expand the dir by one entrylength, reset later if get empty slot */
	rip->i_size+=DSIZE*incr;
	rip->i_size &= ~(DSIZE*incr-1);
	lastentry=rip->i_size/(DSIZE*incr)-1;
	add=adir;
	quit_trav=0;
	traverse_dir(addfunc);
	if(quit_trav)
	{
		/* If not last entry, restore size */
		if(quit_trav==1) rip->i_size=tsize;
		else cdirty=1;
		quit_trav=0;
		return 0;
	}

	/* OK, need to add a zone, ignore any zone numbers already here,
	 * if there are any then they are bogus and should have been 
	 * removed in pass1.
	 */

	cdirty=1;
	zoneadd=rip->i_size/BLOCKSIZE;

	if(!(addz=alloc_zone()))
	{
		printf("No free Zones\n");
		return 1;
	}
	/* Room in direct zones ? */
	if(zoneadd<NDIR) rip->i_zone[zoneadd]=addz;
	else
	/* Nope, need indirecton block */
	{
		zone_nr tmp[NINDIR];
		zoneadd-=NDIR;
		if(zoneadd >= NINDIR)
		{
			printf("Can't Expand Directory, Too Large\n");
			clrbit(addz-minzone+1,szbitmap);
			return 1;
		}
		if(!chk_range(rip->i_zone[NDIR]))
		{
			bzero((char *)tmp,BLOCKSIZE);
			if( !(rip->i_zone[NDIR]=alloc_zone()) )		
			{
				printf("No Free Zones\n");
				clrbit(addz-minzone+1,szbitmap);
				return 1;
			}
		}
		else read_zone(rip->i_zone[NDIR],tmp);
		tmp[zoneadd]=addz;
		write_zone(rip->i_zone[NDIR],tmp);
	}
	cpdir(newzone,adir);

	write_zone(addz,newzone);
	return 0;
}

static int addfunc(dir,entry)
dir_struct *dir;
unsigned entry;
{
	if(entry<2) return 0;
	/* If free , or last entry, overwrite */
	if(!dir->d_inum || entry==lastentry)
	{
		cpdir(dir,add);
		quit_trav=1;
		if(entry==lastentry) quit_trav=2;
		return 1;
	}
	return 0;
}

static char *tname;
static unsigned ifind;

static void show_name(inl)
ilist *inl;
{
	inode_stat *itmp;

	char *tmpfnam;

	long pathlen;

	if(!(tname=malloc(incr*16-1)) ) fatal("Out of memory");

	/* Estimate maximum filename length of file
	 * do this by counting how many directories we pass
	 * through on way to root. Then assume all maximum
	 * length.
	 */

	for(pathlen=0,itmp=&inode_status[inl->iparent-1];;)
	{
		if(!(itmp->flag & I_FOUND)) break;
		pathlen++;
		if(itmp==inode_status) break;
		itmp=&inode_status[itmp->parent-1];
	}

	/* original link not counted so far and include \'s */

	pathlen = (pathlen+1)*incr*17-1;

	tmpfnam = malloc(pathlen);

	if(!tmpfnam) fatal("Out of Memory");

	strcpy(tmpfnam,inl->name);
	strrev(tmpfnam);
	strcat(tmpfnam,"\\");

	itmp=&inode_status[inl->iparent-1];
	ifind=inl->iparent;

	while(ifind!=ROOT_INODE)
	{
		if(itmp->flag & I_FOUND)
		{
			lookup_name(itmp);
			if(!*tname)
			{
				fprintf(stderr,
				    "Can't find name of inode %d\n",inl->inum);
				return;
			}
			strrev(tname);
			strcat(tmpfnam,tname);
			strcat(tmpfnam,"\\");
		}
		else
		{
			strcat(tmpfnam,"(nahpro)");
			/* "orphan" backwards, geddit? */
			break;
		}		
		ifind=itmp->parent;
		itmp=&inode_status[itmp->parent-1];
		
	}

	strrev(tmpfnam);
	fprintf(stderr,"Inode %5d Filename: %s\n",inl->inum,tmpfnam);

	free(tname);
	free(tmpfnam);
}

static void lookup_name(in)
inode_stat *in;
{
	cino=in->parent;
	tname[0]=0;
	read_inode();
	traverse_dir(i_to_name);
	quit_trav=0;
}	

static int i_to_name(dir,entry)
dir_struct *dir;
unsigned entry;
{
	if(entry < 2 ) return 0;	/* Ignore dots */
	if(dir->d_inum==ifind) 
	{
		strncpy(tname,dir->d_name,incr*16-2);
		tname[incr*16-2]=0;
		quit_trav=1;
	}
	return 0;
}

/* Make a 'lost+found' directory if none exists */

static int mklost()
{
	unsigned tino;
	unsigned ctemp;
	zone_nr tzone;
	int i;
	dir_struct dir[DPB];
	printf("No lost+found directory\n");
	if(!ask("Create?","Created")) return 0;
	tino=alloc_inode();
	if(!tino) return 0;
	if(!(tzone=alloc_zone())) return 0;
	ctemp=cino;
	cino=tino;
	read_inode();
	for(i=1;i<NR_ZONE;i++) rip->i_zone[i]=0;
	rip->i_zone[0]=tzone;
	rip->i_mode=I_DIRECTORY | 0755;
	rip->i_mtime=time(NULL);
	rip->i_uid=0;
	rip->i_gid=0;
	rip->i_size=DSIZE*2*incr;
	rip->i_nlinks=2;
	cdirty=1;
	strcpy(dir[0].d_name,".");
	dir[0].d_inum=tino;
	strcpy(dir[incr].d_name,"..");
	dir[incr].d_inum=ROOT_INODE;
	write_zone(tzone,dir);

	strcpy(dir[0].d_name,lfname);
	dir[0].d_inum=tino;

	cino=ROOT_INODE;
	read_inode();
	rip->i_nlinks++;
	cdirty=1;

	add_dirent(dir);

	cino=ctemp;
	lfinode=tino;

	inode_status[tino-1].flag = I_DIR|I_D|I_DD|I_FOUND;
	inode_status[tino-1].links=0;
	inode_status[tino-1].parent=ROOT_INODE;

	return 1;
}

/* Simple enoungh this one : check '.' and '..' are present, check '.' points
 * to this directory, note the value of '..' . Make elementary fixes as well.
 */

static void check_dots()
{
	dir_struct dir[DPB];
	int dirty=0;
	if(chk_range(rip->i_zone[0]))
	{
		read_zone(rip->i_zone[0],dir);
		if(strcmp(dir->d_name,"."))
		{
		    printf("No '.' in directory inode %ld\n",cino);
		    if(ask("Fix?","Fixed"))
		    {
			/* If this entry is occupied, add an identical entry
			 * to the dir, because this one will be overwritten.
			 */
			if(chk_irange(dir->d_inum)) add_dirent(dir);

			strcpy(dir[0].d_name,".");
			dir->d_inum=cino;
			dirty=1;
			ist->flag|=I_D;
		    }
		}
		else ist->flag|=I_D;

		if(dir->d_inum!=cino)
		{
			printf("Bad '.' Entry in directory inode %ld\n",cino);
			if(ask("Fix?","Fixed"))
			{
				dir->d_inum=cino;
				dirty=1;
			}
		}

		if(strcmp(dir[incr].d_name,".."))
		{
			printf("Missing '..' in directory inode %ld",cino);
			if(ask("Fix?","Fixed"))
			{
				if(chk_irange(dir[incr].d_inum)) 
							add_dirent(&dir[incr]);

				strcpy(dir[incr].d_name,"..");
				dir[incr].d_inum=0;	/* Can't fix this yet */
				ist->flag|=I_FDD;
				ist->flag|=I_DD;
				dirty=1;
			}
		}
		else
		{
			ist->parent=dir[incr].d_inum;
			ist->flag|=I_DD;
		}
		if(dirty) write_zone(rip->i_zone[0],dir);
	}
}

/* Check inode numbers against list after checking _pass2 wont kill the entry */

static int pass2(dir,entry)
dir_struct *dir;
unsigned entry;
{
	int ret;
	ret=_pass2(dir,entry);

	if(!ret)
	{
		llist *p;
		for(p=inums;p;p=p->next) if(dir->d_inum==p->member) break;
		if(p)
		{
			ilist *nxt;
			nxt=malloc(sizeof(ilist)+incr*16);
			if(!nxt) fatal("Out of memory");
			strncpy(nxt->name,dir->d_name,incr*16-2);
			nxt->name[incr*16-2]=0;
			nxt->inum=dir->d_inum;
			nxt->iparent=cino;
			nxt->next=inolist;
			inolist=nxt;
		}
	}

	return ret;
}

/* OK this is the nasty bit. At this point we know the value of '..' in a
 * directory (if present). Check all directory entries and offer fixes, also
 * mark each inode as it is 'found' and update link counts.
 */

static int _pass2(dir,entry)
dir_struct *dir;
unsigned entry;
{
	inode_stat *iarr;

	if(!dir->d_inum) return 0;

	if(!chk_irange(dir->d_inum))
	{
		inerr("Ilegal Inode Number\n");
		if(ask("Delete?","Deleted"))
		{
			dir->d_inum=0;
			return 1;
		}
		return 0;	/* Can't do anything else with it */
	}

	if( (cino==ROOT_INODE) && !strcmp(dir->d_name,lfname))lfinode=dir->d_inum;

	iarr=&inode_status[dir->d_inum-1];
	iarr->links--;

	if(badname(dir->d_name))
	{
		printf("Bad Name %.*s in Directory Inode %ld\n",
					MMAX_FNAME(incr),dir->d_name,cino);
		if(ask("Delete?","Deleted"))
		{
			dir->d_inum=0;
			iarr->links++;
			return 1;
		}
	}

	if(entry && (!strcmp(dir->d_name,".")))
	{
		inerr("Extra '.' entry");
		if(ask("Delete?","Deleted"))
		{
			dir->d_inum=0;
			iarr->links++;
			return 1;
		}
		return 0;
	}

	if( (entry!=1) && !strcmp(dir->d_name,"..") )
	{
		inerr("Extra '..' entry");
		if(ask("Delete?","Deleted"))
		{
			dir->d_inum=0;
			iarr->links++;
			return 1;
		}
		return 0;
	}

	if( ( (entry==0) && (ist->flag & I_D) )
				|| ( (entry==1) && (ist->flag & I_DD ) ) )
			return 0;

	if(iarr->flag & I_FREE)
	{
		inerr("Bad Link To Free Inode");
		if(ask("Delete?","Deleted"))
		{
			dir->d_inum=0;
			iarr->links++;
			return 1;
		}
		return 0;
	}

	/* Tricky bit : link to directory. For this pass only recognise as
	 * 'found' if the link is present in the correct parent directory.
	 * If this isn't the case either '..' is wrong or this is an illegal
	 * hard link, this is resolved on the next pass.
	 * If it isn't a directory then mark found, as multiple links are OK.
	 */
	if(iarr->flag & I_DIR)
	{
		if (iarr->parent==cino)
		{
	/* If the 'FOUND' flag is set then multiple links in this dir */
			if(iarr->flag & I_FOUND)
			{
				inerr("Illegal Hard Link To Directory");
				if(ask("Remove","Removed"))
				{
					dir->d_inum=0;
					iarr->links++;
					return 1;
				}
			}
			else iarr->flag |= I_FOUND;
		}
		else ist->flag |= I_LINK;
	}
	else iarr->flag |= I_FOUND;

	return 0;
}

/* At this point all directories which have a link in '..' have the flag
 * I_FOUND. So if a hard link to a directory is found then it is one of:
 * 1. An erroneous hard link (if it isn't in the parent and I_FOUND set).
 * 2. A proper link but the value of '..' is wrong in the linked dir.
 * If '..' is wrong and two hard links are found then the first is taken to
 * be valid, there isn't any real way to find out the genuine link in this
 * case.
 */

static int pass2a(dir,entry)
dir_struct *dir;
unsigned entry;
{
	inode_stat *iarr;
	/* Ignore dot's and invalid links */
	if( (!entry && (ist->flag & I_D) )||
	    (entry==1 && (ist->flag & I_DD) ) ||
		!chk_irange(dir->d_inum) ) return 0;	
	iarr=&inode_status[dir->d_inum-1];
	/* If not dir , ignore */

	if(! (iarr->flag & I_DIR) ) return 0;

	/* Is this the parent ? */
	if(iarr->parent==cino) return 0;

	/* Does parent have a valid link ? */
	if(iarr->flag & I_FOUND)
	{
		printf("Bad Hard Link to Directory in Inode %ld\n",cino);
		if(ask("Remove?","Removed"))
		{
			dir->d_inum=0;
			iarr->links++;
			return 1;
		}
		return 0;
	}

	/* Hmm '..' parent has no link, must be invalid '..' */

	iarr->flag|=I_FOUND;
	iarr->flag|=I_FIXDD;
	iarr->parent=cino;
	return 0;
}

/* Almost there: fix any directories '..' entries if there is an
 * error found, if the I_FDD flag is set, do the changes silently.
 */

static void fix_dots()
{
	dir_struct dir[DPB];
	if(!(ist->flag & I_FDD)) 
	{
		inerr("Bad '..' entry");
		if(!ask("Fix?","Fixed")) return;
	}
	read_zone(rip->i_zone[0],dir);
	if(chk_irange(dir[incr].d_inum))
				inode_status[dir[incr].d_inum-1].links++;
	dir[incr].d_inum=ist->parent;
	inode_status[ist->parent-1].links--;
	write_zone(rip->i_zone[0],dir);
}

/* Inode readers : there are two of these. next_inode() is used in the
 * initial stages where all inodes have to be read twice, it uses a big
 * buffer for this purpose, if the 'cdirty' flag is set then it writes out
 * the buffer first.
 */

static d_inode *ncache_start,*ncache_end,*ncache;
static long ncache_blk;

/* Initialise and flush big cache */
static void next_init()
{
	if(!ncache_start)
	{
		ncache_start=malloc(NSIZE*BLOCKSIZE);
		if(!ncache_start)fatal("No memory for inode cache");
		ncache_end=ncache_start+NSIZE*IPB;
	}
	if(cdirty) write_blocks(ncache_blk,NSIZE,ncache_start);
	cdirty=0;
	ncache=ncache_start;
	ncache_blk=0;
}

static void next_inode()
{
	if(ncache_blk==0)
	{
		read_blocks(ioff,NSIZE,ncache_start);
		ncache_blk=ioff;
	}
	if(ncache!=ncache_end)
	{
		rip=ncache;
		ncache++;
		return;
	}
	if(cdirty)
	{
		cdirty=0;
		write_blocks(ncache_blk,NSIZE,ncache_start);
	}
	ncache_blk+=NSIZE;
	read_blocks(ncache_blk,NSIZE,ncache_start);
	ncache=ncache_start;
	rip=ncache;
	ncache++;
	return;
}

static d_inode ltmp[IPB];

static void read_inode_init()
{
	if(cdirty)
	{
		write_blocks(ncache_blk,1,ltmp);
		cdirty=0;
	}
	ncache_blk=0;
}

static void read_inode()
{
	zone_nr blk=ioff+(cino-1)/IPB  ;
	if(!cino || (cino>maxino) )fatal("Internal error: inode out of range");
	if(ncache_blk!=blk)
	{
		if(cdirty)
		{
			cdirty=0;
			write_blocks(ncache_blk,1,ltmp);
		}
		ncache_blk=blk;
		read_blocks(ncache_blk,1,ltmp);
	}
	rip=&ltmp[(cino-1)%IPB];
}

static long alloc_inode()
{
	long ret;
	inode_stat *istmp=inode_status;
	for(ret=0;ret<maxino;ret++,istmp++)if(istmp->flag &I_FREE) return ret+1;
	return 0;
}

/* Reallocate root inode. Here the root inode is set up as a dir with '.','..'
 * and 'lost+found'. The connectivity algorithm should then be able to reconnect
 * all the orphaned inodes. Note: at this point the inode structures should at
 * least be set up, and the shadow zone bitmap, so we can safely allocate new
 * zones/inodes.
 */

static void fix_root()
{
	long z1,z2;
	time_t now;

	dir_struct rdir[DPB];

	cino=ROOT_INODE;
	/* First things first : allocate 2 zones */
	z1=alloc_zone();

	z2=alloc_zone();

	if(!z1 || !z2) 
		fatal("No Free Zones To Reallocate Root Inode");

	lfinode=alloc_inode();

	if(!lfinode)
		fatal("No Free Inodes To Reallocate 'lost+found'");

	/* Setup inode status flags */
	inode_status->flag= I_DIR | I_FOUND;
	inode_status->links=3;
	inode_status[lfinode-1].flag= I_DIR;
	inode_status[lfinode-1].links=2;

	read_inode_init();
	read_inode();

	now=time((time_t *)NULL);

	*rip=zinode;

	/* Setup root inode */
	rip->i_size= DSIZE*incr*3;		/* 3 entries */
	rip->i_mode= I_DIRECTORY | 0777;	/* Dir + 777 mode */
	rip->i_zone[0]=z1;			/* 1 Zone */
	rip->i_mtime=now;
	rip->i_nlinks=3;
#ifdef V2
	rip->i_atime=now;
	rip->i_ctime=now;
#endif

	/* Root Directory */
	bzero(rdir,BLOCKSIZE);
			
	strcpy(rdir[0].d_name,".");
	rdir[0].d_inum=ROOT_INODE;
	strcpy(rdir[incr].d_name,"..");
	rdir[incr].d_inum=ROOT_INODE;
	strcpy(rdir[incr*2].d_name,lfname);
	rdir[incr*2].d_inum=lfinode;

	write_zone(z1,rdir);
	cdirty=1;

	cino=lfinode;
	read_inode();

	/* Setup 'lost+found' inode */
	
	*rip=zinode;

	rip->i_size=DSIZE*incr*2;
	rip->i_mode=I_DIRECTORY | 0777;
	rip->i_zone[0]=z2;
	rip->i_mtime=now;
	rip->i_nlinks=2;
#ifdef V2
	rip->i_atime=now;
	rip->i_ctime=now;
#endif

	/* l+f dir same as root except for '.' */
	rdir[0].d_inum=lfinode;

	write_zone(z2,rdir);
	cdirty=1;

	read_inode_init();
}

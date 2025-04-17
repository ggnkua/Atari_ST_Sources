/* Minixfs version 0.60 , Copyright S.N. Henson 1991,1992,1993
 * see the file 'copying' for more info.
 */

/* Define all global variables */
#define EXTERN /**/

#include "minixfs.h"
#include "proto.h"
#include "global.h"
#include "xhdi.h"
#include "pun.h"
#include <basepage.h>
#include <mintbind.h>
#include <signal.h>

/* This rubbish ensures that str(XXX) gets expanded then stringifyed */
#define str(x) _stringify(x)
#define _stringify(x) #x

/* Initialisation routine called first by the kernel */

extern FILESYS minix_filesys;

typedef long (*lfptr)();

lfptr old_rwabs,old_getbpb,old_mediach;

unsigned long shadmap;

extern long kludge_rwabs(),kludge_getbpb(),kludge_mediach(),setstack();

FILESYS *
minix_init(k)
	struct kerinfo *k;
{
	unsigned long p2,vdrvs;
	int i;

	kernel = k;
	CCONWS("Minix file system driver for MiNT. Version " 
	str(MFS_MAJOR) "." str(MFS_MINOR) "\r\n"
	"Copyright 1991,1992,1993 S.N.Henson\r\n");
#ifdef MFS_PLEV
	CCONWS("Patch Level " str(MFS_PLEV) "\r\n");
#endif
	CCONWS("Please read the file COPYING for conditions of use.\r\n");

	if( (k->maj_version > 0) || (k->min_version >= 94) ) lockok=1;
	else CCONWS("File Locking not Installed , Use MiNT 0.94 or newer\r\n");

	if( (k->maj_version==0) && (k->min_version < 97) ) no_length=1;

	/* Allocate Cache */
	if(init_cache()) return NULL; 

	/* See if there are any shadow drives */

	vdrvs=*((unsigned long *)0x4c2);

	for(i=0,p2=1;i<NUM_DRIVES;i++,p2<<=1)
	{
		if(ppart[i].start !=-1 )
		{
			if(vdrvs & p2)
			ALERT("Minixfs: shadow drive %c: not installed: drive"
				" already exists!",i+'A');
			else
			{
				ALERT("Shadow Drive %c Installed",i+'A');
				shadmap |= p2;
			}
		}
	}

	*((unsigned long *)0x4c2) = vdrvs | shadmap;

	if(shadmap)  /* Any shadows installed ? */
	{
		/* Set new system vectors */
		old_rwabs = *((lfptr *) 0x476);
		old_getbpb = *((lfptr *) 0x472);
		old_mediach = *((lfptr *) 0x47e);

		*((lfptr *) 0x476) = kludge_rwabs;
		*((lfptr *) 0x472) = kludge_getbpb;
		*((lfptr *) 0x47e) = kludge_mediach;
	}

	switch(cache_mode)
	{
		case ROBUST:
		CCONWS("Robust mode\r\n");
		break;

		case NORMAL:
		CCONWS("Normal mode\r\n");
		break;

		case TURBO:
		CCONWS("TURBO mode\r\n");
		break;
	}

/* If we are in Turbo mode then run a backround updater.
 * This is a variant of the code used in 'thread.c' in mintlib
 */

	if(cache_mode==TURBO)
	{
		BASEPAGE *b;

		b = (BASEPAGE *)p_exec(5, 0L, "", 0L);	/* create a basepage */

		(void)m_shrink(0,b, 512l);		/* Basepage + stack */

		b->p_tbase = (char *)update;		/* text start = func to start */
		b->p_hitpa = ((char *)b) + 512;

		update_pid = (short) p_exec(104, "update", b, 0L);
		/* run in backround */

	}

	return &minix_filesys;
}

/* Note: update is a user level process and must act accordingly i.e. use
 * the syscalls not the dos/bios tables.
 */

int update(bp)
long bp;
{
	setstack(bp+512);

	/* Trap most signals */

	Psignal(SIGALRM,do_sync);
	Psignal(SIGTERM,do_sync);
	Psignal(SIGQUIT,do_sync);
	Psignal(SIGHUP,do_sync);
	Psignal(SIGTSTP,do_sync);
	Psignal(SIGINT,do_sync);

	for(;;)
	{
		Talarm(sync_time);
		Pause();
	}
}

char mfspath[]="A:";

void do_sync(signum)
long signum;
{
	int i;
	if(update_suspend) return;
	for(i=0;i<NUM_DRIVES;i++)
	{
		if(super_ptr[i])
		{
			mfspath[0]='A'+i;
			Dcntl(MFS_SYNC,mfspath,0);
			return;
		}
	}
}


/* Sanity checker, checks a filesystem is minix and then sets up all internal
 * structures accordingly, e.g. superblock and directory increment. Returns
 * '1' if the filesystem is minix, 0 otherwise. Uses get_hddinf to try all
 * possible means to access the drive.
 */

int
minix_sanity(drv)
int drv;
{
	int i;
	d_inode rip;
	struct hdinfo *dsk;
	char is_phys;
	long err;
	super_info *psblk;

	if(!( *(long *)0x4c2 & (1l<<drv)))
	{
		DEBUG("Invalid drive %c:",drv+'A');
		return 0;
	}

	dsk=&disk[drv];
	psblk=Kmalloc(sizeof(super_info));
	if(!psblk)
	{
		ALERT("Minixfs: No memory for super_info structure");
		return 0;
	}

	psblk->dev=drv;

	if(ppart[drv].start!=-1) /* Is this a physical partition ? */
	{
		struct phys_part *pp;
		pp=&ppart[drv];
		dsk->start=pp->start;
		dsk->size=pp->finish-dsk->start+1;
		dsk->scsiz=pp->scsiz;
		dsk->major = pp->shadow;
		(void)GETBPB(drv); 	/* Satisfy disk changes */
		dsk->rwmode = RW_PHYS;
		if(dsk->start > 0xfff0)
		{
			if(no_plrecno(dsk->major))
			{
				ALERT("Cannot access physical parition %c:",drv+'A');
				Kfree(psblk);
				return 0;
			}
			dsk->rwmode |= RW_LRECNO;
		}
		is_phys=1;
	}
	else
	{
	    is_phys=0;
	    if( (err=get_hddinf(drv,dsk,0)) )
	    {
		DEBUG("Cannot access partition %c: %s.",drv+'A',hdd_err[err]);
		Kfree(psblk);
		return 0;
	    }
	}

	super_ptr[drv]=psblk;

	crwabs(2,&temp,1,SUPER_BLOCK,drv);

	psblk->sblk=*((super_block *)&temp);

	if(( (psblk->sblk.s_magic==SUPER_MAGIC) || 
	     (psblk->sblk.s_magic==SUPER_V2))
		&& psblk->sblk.s_ninodes) {
		if(psblk->sblk.s_log_zsize) {
		DEBUG("Cannot read Drive %c Zone-size > Block-size",drv+'A');
			super_ptr[drv]=DFS;
			Kfree(psblk);
			return -1;
		}
		if(psblk->sblk.s_magic==SUPER_MAGIC)
		{
			TRACE("Drive %c V1 filesyetem",drv+'A');
			psblk->version=0;
			psblk->ipb=INODES_PER_BLOCK;
			psblk->zpind=NR_INDIRECTS;
			psblk->sblk.s_zones=psblk->sblk.s_nzones;
			psblk->dzpi=NR_DZONE_NUM;
			psblk->ndbl=NR_DBL;
		}
		else
		{
			TRACE("Drive %c V2 filesystem",drv+'A');
			psblk->version=1;
			psblk->ipb=INODES_PER_BLOCK2;
			psblk->zpind=NR_INDIRECTS2;
			psblk->dzpi=NR_DZONE_NUM2;
			psblk->ndbl=NR_DBL2;

		}

		/* Check if lrecno needed/supported */
		if(set_lrecno(dsk,psblk->sblk.s_zones))
		{
			ALERT("No way to acess large partition %c:",drv+'A');
			Kfree(psblk);
			super_ptr[drv]=DFS;
			return -1;
		}

		psblk->ioff = psblk->sblk.s_imap_blks + psblk->sblk.s_zmap_blks
									 + 2 ;
		read_inode(ROOT_INODE,&rip,drv);
		if(IS_DIR(rip)) {
		  void *p;
		  int dot=-1,dotdot=-1;
		  p=Kmalloc((unsigned) (BLOCK_SIZE*(psblk->sblk.s_imap_blks+
			psblk->sblk.s_zmap_blks)));
		  if(!p) {
			DEBUG("No room for bitmaps");
			Kfree(psblk);
			super_ptr[drv]=DFS;
			return -1;
		  }
		  psblk->ibitmap=p;
		  psblk->zbitmap=p+BLOCK_SIZE*psblk->sblk.s_imap_blks;
		  crwabs(2,p,psblk->sblk.s_imap_blks+psblk->sblk.s_zmap_blks
									,2,drv);
		  psblk->idirty=0;
		  psblk->zdirty=0;
		  psblk->zlast=0;
		  psblk->ilast=0;

/* Final step , read in the root directory zone 1 and check the '.' and '..'
 * spacing , The spacing between the '.' and '..' will be used as an indicator
 * of the directory entry size. If in doubt assume a normal minix filesystem.
 */

		  read_zone(rip.i_zone[0],&temp,drv,&syscache);

		  for(i=0;i<min(NR_DIR_ENTRIES,rip.i_size/DIR_ENTRY_SIZE);i++)
		  {
			if(temp.bdir[i].d_inum)
			{
				if(!strcmp(temp.bdir[i].d_name,"."))
				{
					if(dot==-1) dot=i;
					else
					{
						ALERT ("Drive %c multiple \".\" in root dir!!", drv + 'A');
						dot=-1;
						i=NR_DIR_ENTRIES;
					}
				}

				if(!strcmp(temp.bdir[i].d_name,".."))
				{
					if(dotdot==-1) dotdot=i;
					else
					{
						ALERT ("Drive %c multiple \"..\" in root directory", drv + 'A');
						dotdot=-1;
						i=NR_DIR_ENTRIES;
					}
				}
			}
		  }

		  if( (dotdot==-1) || (dot==-1) )
		  {
			ALERT("Drive %c no . or .. in root directory",drv+'A');
			Kfree(psblk->ibitmap);
			Kfree(psblk);
			super_ptr[drv]=DFS;
			return -1;
		  }
		  else psblk->increment=dotdot-dot;

		  if( (psblk->increment < 1) || NPOW2(psblk->increment))
		  {
			ALERT("Drive %c weird . .. positions",drv+'A');
			Kfree(psblk->ibitmap);
			Kfree(psblk);
			super_ptr[drv]=DFS;
			return -1;
		  }

		   if(psblk->increment > MAX_INCREMENT)
		  {
			ALERT("Drive %c Increment %d",drv+'A',psblk->increment);
			ALERT("This minix.xfs binary can only handle %d",MAX_INCREMENT);
			ALERT("Recompile with a higher MAX_INCREMENT");
			Kfree(psblk->ibitmap);
			Kfree(psblk);
			super_ptr[drv]=DFS;
			return -1;
		  }
		  return 1;
		}
		else {
			ALERT("root inode on drive %c is not a directory??",
				drv+'A');
			Kfree(psblk->ibitmap);
			Kfree(psblk);
			super_ptr[drv]=DFS;
			return -1;
		}
	}

	Kfree(psblk);

	if(is_phys)
	{
		ALERT("Physical partition %c: not minix!!",drv+'A');
		super_ptr[drv]=DFS;
		return -1;
	}
	super_ptr[drv]=0;
	return 0;
}

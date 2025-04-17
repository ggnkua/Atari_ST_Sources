/* minit Minix INITializer . Freely distributable Minix filesys creator.
 * Copyright S N Henson 1991,1992,1993.
 * Use entirely at your own risk ! If it trashes your hard-drive then
 * it isn't my fault ! 
 */

/* Version 0.24 */


#include <mintbind.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

#include "minixfs/hdio.h"
#include "minixfs/xhdi.h"
#include "minixfs/pun.h"

#define MNAME_MAX 14

int shift,drive=-1;
long numblocks,numinodes,incr=1;

/* various flags */
char protect,sonly,zbpb,v2,lrecno,tst;

struct hdinfo hdinf;

unsigned char block_buf[1024];

/* Structures we will need */

typedef struct  {
  unsigned short  s_ninodes;	/* # usable inodes on the minor device */
  unsigned short  s_nzones;	/* total device size, including bit maps etc */
  unsigned short s_imap_blks;	/* # of blocks used by inode bit map */
  unsigned short s_zmap_blks;	/* # of blocks used by zone bit map */
  unsigned short s_firstdatazn;	/* number of first data zone */
  short int s_log_zsize;	/* log2 of blocks/zone */
  unsigned long s_max_size;	/* maximum file size on this device */
  short s_magic;		/* magic number to recognize super-blocks */
  short pad;			/* padding */
  long s_zones;			/* equivalent to 's_nzones' for V2 */
} super_block;



typedef struct {		/* directory entry */
  unsigned short d_inum;	/* inode number */
  char d_name[MNAME_MAX];		/* character string */
} dir_struct;

typedef struct {		/* disk inode. */
  unsigned short i_mode;		/* file type, protection, etc. */
  unsigned short i_uid;			/* user id of the file's owner */
  unsigned long  i_size;		/* current file size in bytes */
  unsigned long  i_mtime;		/* when was file data last changed */
  unsigned char i_gid;			/* group number */
  unsigned char i_nlinks;		/* how many links to this file */
  unsigned short i_zone[9];	/* block nums for direct, ind, and dbl ind */
} d_inode;

typedef struct {
unsigned short i_mode;
unsigned short i_nlinks;
unsigned short i_uid;
unsigned short i_gid;
unsigned long i_size;
unsigned long i_atime;
unsigned long i_mtime;
unsigned long i_ctime;
long i_zone[10];
} d_inode2;

/* prototypes */

#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif


void main P((int argc , char **argv ));
int nrwabs P((int rw , void *buf , unsigned count , long recno , int drive ));
void get_block P((long num ));
void put_block P((long num ));
void check_lrecno P((void ));
void warn P((void ));

#undef P

void main(argc,argv)
int argc;
char **argv;
{
	extern int optind,opterr;
	extern char *optarg;
	long hderr;
	int c ;
	static char err=0;
	int i,j;
	_BPB *bpb;
	unsigned short ioff,zone1;
        super_block *sblk=(super_block *)block_buf,csblk;
        d_inode *rip=(d_inode *)block_buf;
	d_inode2 *ripn=(d_inode2 *)block_buf;
        dir_struct *dir=(dir_struct *)block_buf;
	unsigned short *srt=(unsigned short *)block_buf;
	long icount, zcount;

	struct
	{
		long start;
		long finish;
		char shadow;
		char scsiz;
	} pp;

	/* Parse command-line options */
	opterr=0;
	while((c=getopt(argc,argv,"b:B:i:I:n:pPSZztV"))!=EOF)
	{
        	switch(c){

        		case 'B':
			case 'b':
			numblocks=atol(optarg);
			break;

			case 'n':
			incr=atol(optarg);
			break;
	
			case 'i':
			case 'I':
			numinodes=atol(optarg);
			break;

			case 'P':
			protect=1;
			break;

			case 'p':
			protect=2;
			break;

			case 'S':
			sonly=1;
			break;

			case 'Z':
			zbpb=1;
			break;	

			case 'z':
			zbpb=2;
			break;

			case 'V':
			v2=1;
			break;

			case 't':
			tst=1;
			break;

			case '?':
			err=1;
			break;
		}
	}

	if(argc-optind!=1 || err || (zbpb && protect) )
	{
		fprintf(stderr,"Minix-compatible filesystem initializer\n");
		fprintf(stderr,"Copyright S N Henson 1991,1992,1993\n");
		fprintf(stderr,"Version 0.24\n"); 
		fprintf(stderr,"Usage\t(auto)\t: minit drive\n");
		fprintf(stderr,"\t(manual): minit -b blocks -i inodes drive\n");
		fprintf(stderr,"Also :\t-S only write out super-block\n");
		fprintf(stderr,"\t-P protect filesystem with null disk\n");
		fprintf(stderr,"\t-p make null disk of existing filestystem\n");
		fprintf(stderr,"\t-Z protect with zero BPB\n");
		fprintf(stderr,"\t-z zero BPB of existing filesystem\n");
		fprintf(stderr,"\t-V make a V2 filesystem\n");
		fprintf(stderr,"\t-n dirincrement\n");
		fprintf(stderr,"\t-t test mode (no writing)\n");
		exit(1);
	}
	drive=(argv[optind][0] & ~32)-'A' ;

	/* Sanity checking time */

	if((incr < 1) || (incr > 16) || ( (incr) & (incr-1) ) )
	{
		fprintf(stderr,"Dirincrement must be a power of two between\n");
		fprintf(stderr,"1 and 16 (inclusive)\n");
		exit(1);
	}

	if( (numinodes < 0) || (numinodes > 65535) )
	{
		fprintf(stderr,"Need at least 1 and no more than 65535 inodes\n");
		exit(1);
	}

	/* Test for physical partition */
	if(!Dcntl(0x109,argv[optind],&pp) && pp.start!=-1) 
	{

		hdinf.start=pp.start;
		hdinf.size=pp.finish-hdinf.start+1;
		hdinf.scsiz=pp.scsiz;
		hdinf.major = pp.shadow;
		(void)Getbpb(drive); 	/* Satisfy disk changes */
		hdinf.rwmode = RW_PHYS;
		if(hdinf.start > 0xfffe)
		{
			if(no_plrecno(hdinf.major))
			fprintf(stderr,"Cannot access Drive %c:\n",drive+'A');
			hdinf.rwmode |= RW_LRECNO;
		}
	}
	else if( (hderr=get_hddinf(drive,&hdinf,0)) )
	{
		fprintf(stderr,"Cannot access Drive %c: %s\n",drive+'A',
								hdd_err[hderr]);
		exit(1);
	}

	if(tst)
	{
		struct hdinfo hdinf2;
		unsigned int llrecno,xhret,tmode,no_phys;
		no_phys=0;
		llrecno=no_lrecno(drive);
		if(llrecno && llrecno!=3)
				fprintf(stderr,"Logical lrecno error\n");
		else fprintf(stderr,"Logical lrecno OK\n");
		if( !(xhret=XHGetVersion() ) )
		{
		  fprintf(stderr,"XHDI not supported\n");
		  if( (no_phys=get_hddinf(drive,&hdinf2,1)) )
			fprintf(stderr,"Can't get physical drive info: %s\n",hdd_err[no_phys]);
		  else
		  {	
		    llrecno=no_plrecno(hdinf2.major);
		    if(llrecno && llrecno!=3)
				fprintf(stderr,"Physical lrecno error\n");
			else fprintf(stderr,"Physical lrecno OK\n");
		  }
		}
		else fprintf(stderr,"XHDI supported version %x.%02x\n", xhret>>8,xhret & 0xff);

		fprintf(stderr,"\nHard disk access information:\nAccess mode: ");
		tmode=hdinf.rwmode & ~RW_LRECNO;
		switch(tmode)
		{
		  case RW_NORMAL:
		  fprintf(stderr,"Normal mode\n");
		  break;

		  case RW_XHDI:
		  fprintf(stderr,"XHDI mode\n");
		  break;

		  case RW_PHYS:
		  fprintf(stderr,"Physical mode\n");
		  break;
		}
		tmode=hdinf2.rwmode & ~RW_LRECNO;
		if(!no_phys)
		{
		  fprintf(stderr,"Partition start: %ld\n",hdinf2.start);
		  if(hdinf2.size)
			fprintf(stderr,"Partition size: %ld\n",hdinf2.size);	
		  if(tmode==RW_PHYS)
		  {
			unsigned ddev;
			char *sbus;
			ddev=hdinf2.minor;
			fprintf(stderr,"Unit number %d\n",ddev);
			if( ddev & PUN_IDE) sbus="IDE";
			else
			{
				if( ddev & PUN_SCSI) sbus="SCSI";
				else sbus="ACSI";
			}
			fprintf(stderr,"%s bus: device %d.(",sbus,
							       ddev & PUN_UNIT);
			if(ddev & PUN_REMOVABLE) fprintf(stderr,"Removable)\n");
			else fprintf(stderr,"Non-removable)\n");
		  }
		  else fprintf(stderr,"Major number %d Minor number %d\n",
						     hdinf2.major,hdinf2.minor);
		}

		if(hdinf.rwmode & RW_LRECNO)
					    fprintf(stderr,"Lrecno access\n\n");
		else fprintf(stderr,"Non lrecno access\n\n");

	}

	if(!numblocks) numblocks=hdinf.size>>hdinf.scsiz;
	else if(hdinf.size && (numblocks > hdinf.size>>hdinf.scsiz))
	{
		fprintf(stderr,"Partition has only %ld blocks\n",
						       hdinf.size>>hdinf.scsiz);
		exit(1);
	}

	/* read in boot sector */
	get_block(0);

	/* If size of partition not known try BPB/boot sector */
	if(!numblocks)
	{
		bpb = Getbpb(drive);
		if(!bpb || (bpb->recsiz & 511))
		{
			fprintf(stderr,"Can't figure out partition size: "
							 "try the -b option\n");
			exit(1);
		}

		numblocks=( (block_buf[19]+( ((long)block_buf[20])<<8))*
							       bpb->recsiz)>>10;
		if(numblocks < 40 )
		{
	     		fprintf(stderr,"%ld blocks ? Is that bootsector OK ?\n",numblocks);
	     		exit(1);
		}
	}

	if(!v2 && (numblocks > 65535) )
	{
		fprintf(stderr,"V1 filesystems can be at most 65535 blocks\n");
		exit(1);
	}

	if(set_lrecno(&hdinf,numblocks))
	{
		fprintf(stderr,"Can't access partition\n");
		exit(1);
	}

	get_block(numblocks-1); /* Try to read last block */

	if(numinodes==0)
	{
		numinodes = numblocks/3;
	
		/* Round up inode number to nearest block */

		if(v2) numinodes = (numinodes + 15) & ~15;

		else numinodes=(numinodes + 31 ) & ~31;
	}

	if(numinodes > 65535) numinodes = 65535;

	if(protect==2)
	{
		get_block(1);
		if( (sblk->s_magic != 0x137f) && (sblk->s_magic!=0x2468) )
		{
			fprintf(stderr,"Fatal: bad magic number\n");
			exit(1);
		}
	}

	if(!tst) warn();

	/* Set up boot sector */

	if(!sonly && (protect || zbpb) )
	{
		get_block(0);
		if(protect)
		{
			/* Make GEMDOS think we have a tiny partition */
			/* With root directory immediately after super-block */
			block_buf[16]=2;
			block_buf[17]=16;
			block_buf[18]=0;
			block_buf[22]=1;
			block_buf[23]=0;
		}
		else if(zbpb)
		{
			block_buf[16]=block_buf[17]=block_buf[18]=0;
			block_buf[22]=block_buf[23]=0;
		}
		strcpy((char *)(&block_buf[2]),"MINIX");
		put_block(0);
		if(zbpb==2) exit(0);
	}

	/* OK lets work out some stuff */

	if(protect==2) get_block(1);
	else
	{
		bzero(block_buf,1024l);
		/* Super block */
        	sblk->s_ninodes=numinodes;
        	if(v2) sblk->s_zones=numblocks;
		else sblk->s_nzones=numblocks;
        	sblk->s_imap_blks=(numinodes+8192)/8192;
		sblk->s_zmap_blks=(numblocks+8191)/8192;
		sblk->s_firstdatazn=2+sblk->s_imap_blks+sblk->s_zmap_blks
			+ ( v2 ? ((numinodes+15)/16) : ((numinodes+31)/32)) ;
		sblk->s_log_zsize=0;
		sblk->s_max_size= v2 ? 0x4041c00l : 0x10081c00l;
		sblk->s_magic= v2 ? 0x2468 : 0x137f;
	}

	/* If protecting fill up the pseudo root directory with vol names */
	if(protect)
	{
		bzero(&block_buf[512],512);
		for(i=512;i<1024;i+=32) 
		{
			strncpy((char*)&block_buf[i],"MINIXFS    ",11);   
			block_buf[i+11]=0x08;
		}
	}

	put_block(1);

	if( sonly || protect==2 ) exit(0);	

	csblk=*sblk;

	ioff=2+sblk->s_imap_blks+sblk->s_zmap_blks;
	zone1=sblk->s_firstdatazn;

	bzero(block_buf,1024l);

	/* Inode bitmaps */

	icount = numinodes + 1;
	for(i=2;i<2+csblk.s_imap_blks;i++)
	{
		if(i==2)
		{
			srt[0]=3;
		}
		if(icount < 8192) /* Need to mark dead inodes as used */
		{
			if(icount & 15)
			{
				srt[icount/16] = 0xffff << (icount & 15);
				icount+= 16 - (icount & 15);
			}
			for(j=icount/16;j<512;j++)srt[j]=0xffff;
		}
		put_block(i);
		if(i==2)srt[0]=0;
		icount-=8192;
	}		

	bzero(block_buf,1024l);

        /* Zone bitmaps */

	zcount = numblocks + 1 - csblk.s_firstdatazn;
	for(i=2+csblk.s_imap_blks;i<ioff;i++)
	{
		if(i==2+csblk.s_imap_blks)
		{
			srt[0]=3;
		}
		if (zcount < 8192) /* Need to mark dead zones as used */
		{
			if(zcount & 15)
			{
				srt[zcount/16] = 0xffff << (zcount & 15);
				zcount+= 16 - (zcount & 15);
			}
			for(j=zcount/16;j<512;j++)srt[j]=0xffff;
		}
		put_block(i);
		if(i==2+csblk.s_imap_blks)srt[0]=0;
		zcount-=8192;
	}		

	bzero(block_buf,1024l);

	/* Initialise inodes */
	
	for(i=ioff;i<ioff+
			(v2 ? ((numinodes +15)/16) : ((numinodes+31)/32 )) ;i++)
	{
		if(i==ioff) /* Root inode , initialise it properly */
		{
			if(v2)
			{
				ripn->i_mode=040777; /* Directory */
				ripn->i_size=32*incr;
				ripn->i_mtime=time((time_t *)0);
				ripn->i_ctime=ripn->i_mtime;
				ripn->i_atime=ripn->i_mtime;
				ripn->i_nlinks=2;
				ripn->i_zone[0]=zone1;
			}
			else
			{
				rip->i_mode=040777; /* Directory */
				rip->i_size=32*incr;
				rip->i_mtime=time((time_t *)0);
				rip->i_nlinks=2;
				rip->i_zone[0]=zone1;
			}
		}	
		put_block(i);
		if(i==ioff)bzero(block_buf,1024l);
	}

	bzero(block_buf,1024l);
	/* And finally the root directory */
	dir[0].d_inum=1;
	strcpy(dir[0].d_name,".");
	dir[incr].d_inum=1;
	strcpy(dir[incr].d_name,"..");
	put_block(zone1);
	if(!tst) fprintf(stderr,"Initialised OK.\n");
	fprintf(stderr,"%ld Blocks, %ld Inodes.\n",numblocks,numinodes);

	/* Force media change on specified drive */
	if(Dlock(1,drive)) 
		fprintf(stderr,"Can't Lock Drive, Reboot to be sure\n");

	exit(0);
}

void get_block(num)
long num;
{
	long r;

	if( (r = block_rwabs(2,block_buf,1,num,&hdinf)) )
	{
		fprintf(stderr,"Fatal Read Error %ld block %ld\n",r,num);
		exit(2);
	}
}

void put_block(num)
long num;
{
	long r;

	if(tst) return;

	if( (r = block_rwabs(3,block_buf,1,num,&hdinf)) )
	{
		fprintf(stderr,"Fatal Write Error %ld block %ld\n",r,num);
		exit(2);
	}
}

void warn()
{
	int ch;
	fprintf(stderr,"WARNING ! THIS %s TOTALLY DESTROY ANY DATA ON ",
			      (sonly || protect==2 || zbpb==2 ) ? "MAY":"WILL");
	fprintf(stderr,"DRIVE %c !\n",drive+'A');
	fprintf(stderr,"Are you ABSOLUTELY SURE you want to do this (y/n)?\n");
	ch=Crawcin() & 0xff ;
	if(ch!='Y' && ch!='y')
	{
		fprintf(stderr,"Aborted\n");
		exit(0);
	}
}

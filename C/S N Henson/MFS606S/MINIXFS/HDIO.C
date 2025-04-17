#include "pun.h"
#include "xhdi.h"

#include <string.h>

#ifdef MFS_XFS
#include "minixfs.h"
#include "global.h"
#define XRWABS RWABS
#define DWARN(mes,drive) ALERT("Drive %c: " mes,drive)
#else
#define DWARN(mes,drive) fprintf(stderr,"Drive %c: " mes "\n",drive)
#define ALERT(x)	 fprintf(stderr,x "\n")
#define NEED_SUPER
#define RWABS Rwabs
#define Kmalloc malloc
#define Kfree free
#define GETBPB Getbpb
#include <osbind.h>
#include <alloc.h>
#include <stdio.h>
#include "hdio.h"

#define XRWABS(a,b,c,d,e,f) \
trap_13_wwlwwwl((short)(0x04),(short)(a),(long)(b),(short)(c),(short)(d)\
,(short)(e),(long)(f) )

#define trap_13_wwlwwwl(n, a, b, c, d, e, f)				\
({									\
	register long retvalue __asm__("d0");				\
	volatile short _a = (volatile short)(a);			\
	volatile long  _b = (volatile long) (b);			\
	volatile short _c = (volatile short)(c);			\
	volatile short _d = (volatile short)(d);			\
	volatile short _e = (volatile short)(e);			\
	volatile long  _f = (volatile long) (f);			\
	    								\
	__asm__ volatile						\
	("\
		movl	%5,sp@-; \
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movl    %1,sp@-; \
		movw    %0,sp@-	"					\
	:					      /* outputs */	\
	: "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e), "r"(_f) /* inputs  */ \
	);								\
									\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #13;	\
		addw    #18,sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#endif

/* List of error codes for get_hddinf */

char *hdd_err[] = { 
"OK",
"Bad BPB on floppy drive",
"Need drive A-P for PUN_INFO",
"Invalid or no PUN_INFO structure",
"Invalid drive",
"Physical mode disabled for ICD software",
"Physical lrecno error",
"XHInqDev2 failed (old XHDI version?) and bad BPB",
"XHInqDev failed",
"Unrecognised partition id",
"XHInqTarget failed",
"Unsupported physical sector size" };


/*
 * Hard disk info. This is a general purpose routine to handle minixfs' needs
 * for hard disks. If this function returns non-zero then the partition 
 * cannot be accessed. XHDI and pun_info are used to get partition info.
 * The structure 'hdinf' is filled in as approproiate.
 *
 * If this looks awful then that's because it *is*.
 */

static char rno_xhdi,try_xhdi;
static char try_lrecno,rno_lrecno;
static char try_plrecno,rno_plrecno;

char is_icd;

int get_hddinf(drive,hdinf,flag)
int drive;
struct hdinfo *hdinf;
char flag;
{
	long ret;
#ifdef NEED_SUPER
	long tstack;
	tstack=Super(0l);
	if(!((*(long *)0x4c2) & (1l<<drive))) return 4;
#endif
	ret = _get_hddinf(drive,hdinf,flag);
#ifdef NEED_SUPER
	Super(tstack);
#endif
	return ret;
}

int _get_hddinf(drive,hdinf,flag)
int drive;
struct hdinfo *hdinf; 
char flag;
{
	_BPB *bpb;

	hdinf->major=drive;	/* May get overwritten later */

	bpb=GETBPB(drive); 
	if( flag ) bpb=0;

	/* Step 1: if bpb OK and sector size 512 bytes or 1K we may get away
	 * with normal Rwabs.
	 */

	/* NBB: ICD software does something peculiar with the pun_info 
	 * structure. I don't know exactly what. HOWEVER it looks like
	 * the six bytes before pun_ptr contain the magic number 
	 * 'ICDB' followed by a version number. Also there are four longs
	 * between end of pun and partition_start elements which are all
	 * zeros. Anyway we look for ICDB and then reference four elements
	 * further up partition_start.
	 */
	if( !bpb || (bpb->recsiz!=512 && bpb->recsiz!=1024) )
	{
		long tsecsiz;
		char mpid[4];

		/* OK can't use normal Rwabs: try XHDI or pun_info */

		/* Bypass this rubbish for floppies */
		if(drive < 2 ) return 1;

		/* Try and get info from pun_inf structure */
		if( no_xhdi() )
		{
			struct pun_info *pinf;
			char *icd_magic;
			if(drive >= MAXUNITS) return 2;
			if(!(*(long *)0x516)) return 3;
			pinf=PUN_PTR;
			icd_magic=((char *)pinf)-6;
			if(!pinf || (PUN_VALID & pinf->pun[drive]) ) return 4;
			hdinf->scsiz = 1;

			if(strncmp(icd_magic,"ICDB",4))
				hdinf->start = pinf->partition_start[drive];
			else
			{
				is_icd=1;
#ifdef NO_ICD_PHYS
				return 5;
#else
				hdinf->start = pinf->partition_start[drive+4];
#endif
			}
			hdinf->size = 0;
			hdinf->minor = pinf->pun[drive];
			hdinf->major = (hdinf->minor & PUN_DEV) +2;
			hdinf->rwmode = RW_PHYS;
			/* We want to access at least first few sectors */
			if(hdinf->start > 0xfff0)
			{
				if(no_plrecno(hdinf->major)) return 6;
				else hdinf->rwmode |= RW_LRECNO;
			}
			return 0;
		}

		hdinf->rwmode = RW_XHDI | RW_LRECNO;

		/* Hmmmm Getbpb failed or bad secsize: see what XHDI can do */

		if( XHInqDev2(drive,&hdinf->major,&hdinf->minor,&hdinf->start,
							  0,&hdinf->size,mpid) )
		{
			if(!bpb) return 7;
			if( XHInqDev(drive,&hdinf->major,&hdinf->minor,
						    &hdinf->start,0) ) return 8;
		}

		/* See if it's a recognised partition id or bpb OK*/

		if(!bpb && strcmp(mpid,"RAW") && strcmp(mpid,"MIX")) return 9;

		/* Get physical sector size */
		if( XHInqTarget(hdinf->major,hdinf->minor,&tsecsiz,0,0) )
								      return 10;

		if(tsecsiz==512) hdinf->scsiz=1;
		else 
		{
			if(tsecsiz==1024) hdinf->scsiz=0;
			else return 11;
		}
		return 0;
	}
	if(bpb->recsiz==512) hdinf->scsiz=1;
	else hdinf->scsiz=0;
	hdinf->size=0;
	hdinf->rwmode = RW_NORMAL;
	return 0;
}

/* This function is called after get_hddinf and is used to finalise the
 * accessibility of a partition. The 'size' parameter is the size of the
 * partition in K; this info will typically come from the super block of
 * a filesystem. 
 * Return values:
 * 0	OK
 * 1	Partition inaccessible.
 */

int set_lrecno(hdinf,size)
struct hdinfo *hdinf;
long size;
{

	if(hdinf->scsiz) size <<=1;
	if( ( (hdinf->rwmode & RW_MODE) == RW_XHDI) && hdinf->size
						       && (hdinf->size < size) )
	{
		DWARN("Filesystem size bigger than partition size!",
								hdinf->major);
	}
	else hdinf->size = size;

	hdinf->rwmode |= RW_CHECK;

	if(hdinf->rwmode & RW_LRECNO) return 0;

	switch(hdinf->rwmode & RW_MODE)
	{
		case RW_NORMAL:
		if(size > 0xfffe) 
		{
			if(no_lrecno(hdinf->major))
			{
			/* No logical lrecno: try forced physical mode access */
				int drive;
				drive = hdinf->major;
				if(get_hddinf(drive,hdinf,1)) return 1;
				else return (set_lrecno(hdinf,size));
			}
			else hdinf->rwmode |= RW_LRECNO;
		}
		return 0;

		case RW_PHYS:
		if(size+hdinf->start >= 0xfffe)
		{
			if(no_plrecno(hdinf->major)) return 1;
			hdinf->size = size;
			hdinf->rwmode |= RW_LRECNO;
		}
		return 0;
	}

	return 1;	/* This can't happen */
}

/* Test for 'lrecno' parameter on drive 'drive': mode' is RWABS mode to use 
 * (2=logical,10=physical).
 * Return values:
 * 0 OK
 * 1 Read error.
 * 2 No lrecno recognised.
 * 3 Error reading large sector number (possibly OK if partition too small).
 * 4 Wraparound bug present.
 * 5 Allocation error.
 */

int test_lrecno(drive,mode)
int drive;
int mode;
{
	char *block_buf1,*block_buf2;
	int size;
	_BPB *bpb;
	if(mode & 8) size=1024;
	else
	{
		bpb=GETBPB(drive);
		if(!bpb) size=1024;
		else size=bpb->recsiz;
	}
	block_buf1=Kmalloc(size<<1);
	block_buf2=block_buf1+size;
	bzero(block_buf1,size<<1);

	if(!block_buf1) return 5;

	/* read in boot sector */
	if(RWABS(mode,block_buf1,1,0,drive)) 
	{
		Kfree(block_buf1);
		return 1;
	}

	/* read it in with lrecno */	
	if( XRWABS(mode,block_buf2,1,-1,drive,0l) ) 
	{
		Kfree(block_buf1);
		return 2;
	}

	/* Compare the two */
	if(bcmp(block_buf1,block_buf2,size))
	{
		Kfree(block_buf1);
		return 2;
	}

	/* read in next sector with lrecno */
	if(XRWABS(mode,block_buf2,1,-1,drive,1l))
	{
		Kfree(block_buf1);
		return 1;
	}

	/* compare the two */
	if(!bcmp(block_buf1,block_buf2,size))
	{
		Kfree(block_buf1);
		return 2;
	}

	/* Check for lrecno bug, this causes the upper word of a long sector
	 * number to be ignored. Read in sector 0 and 0x10000, if the bug is
	 * present then these will be identical.
	 */
	bzero(block_buf2,size);

	if(XRWABS(mode,block_buf2,1,-1,drive,0x10000l))
	{
		Kfree(block_buf1);
		return 3;
	}
	else if(!bcmp(block_buf1,block_buf2,size))
	{
		Kfree(block_buf1);
		return 4;
	}

	Kfree(block_buf1);
	return 0;

}

int no_lrecno(drv)
int drv;
{
	if( !try_lrecno )
	{
		rno_lrecno = test_lrecno(drv,2) ;
		try_lrecno = 1;
	}
	return rno_lrecno;
}

int no_plrecno(drv)
int drv;
{
#ifdef NO_ICD_PHYS
	if(is_icd) return 1;
#endif
	if( !try_plrecno ) 
	{

		try_plrecno = 1;
		rno_plrecno = test_lrecno(drv,10) ;
	}
	return rno_plrecno;
}

int no_xhdi()
{
	if( !try_xhdi ) 
	{
		if( !XHGetVersion() ) rno_xhdi=1;
		try_xhdi=1;
	}
	return rno_xhdi;
}

/* 
 * This is (finally!) the I/O function hdinf uses. It reads/writes in 1K chunks
 * and calls the relevant functions according to the hdinf structure.
 */

long block_rwabs(rw,buf,num,recno,hdinf)
int rw;
void *buf;
unsigned num;
long recno;
struct hdinfo *hdinf;
{
	if( hdinf->scsiz )
	{
		recno <<=1;
		num <<=1;
	}

	if( (hdinf->rwmode & RW_CHECK) && (recno+num > hdinf->size) )
	{
		DWARN("Attempted access outside partition",hdinf->major);
		return -1;
	}

	switch(hdinf->rwmode & (RW_MODE|RW_LRECNO))
	{
		case RW_NORMAL:
		return RWABS(rw,buf,num,(unsigned)recno,hdinf->major);

		case RW_NORMAL | RW_LRECNO:
		return XRWABS(rw,buf,num,-1,hdinf->major,recno);

		case RW_PHYS:
		return RWABS(rw | 8,buf,num,(unsigned)(recno+hdinf->start),
								  hdinf->major);

		case RW_PHYS | RW_LRECNO:
		return XRWABS(rw | 8,buf,num,-1,hdinf->major,
							    recno+hdinf->start);

		case RW_XHDI | RW_LRECNO:
		return XHReadWrite(hdinf->major,hdinf->minor,rw,
						    recno+hdinf->start,num,buf);
	}
	return 1;	/* This can't happen ! */
}

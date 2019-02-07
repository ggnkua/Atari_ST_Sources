/*
 * new version with multiple LUN support
 *
 */

#include <portab.h>
#include <osbind.h>

#define NEW 1	/* support multiple LUN code */
#define OLD 0	/* support the old version   */

/********************************************************/
/*                                                      */
/* SUPRA CORPORATION                                    */
/*    Hard Disk drivers for the Atari 520 ST            */
/*                                                      */
/* 1 July 1986                                          */
/*                                                      */
/*                                                      */
/********************************************************/


/********************************************************/
/*   PART 2                                             */
/*                                                      */
/*        Actual low level routines to access a dma     */
/*        device.  These routines are also compatible   */
/*        with the Atari hard disk drives               */
/*                                                      */
/********************************************************/

WORD *flock      = 0x43eL;
BYTE *gpip       = 0xfffa01L;
WORD *diskctl_w  = 0xff8604L;
LONG *diskctl_l  = 0xff8604L;
WORD *fifo       = 0xff8606L;
BYTE *dmahigh    = 0xff8609L;
BYTE *dmamid     = 0xff860bL;
BYTE *dmalow     = 0xff860dL;

LONG save_ssp;

LONG luns[] = {
		0x00000000L,		/* unit 0 */
		0x00200000L		/* unit 1 */
	} ;

#define   READY     0x0008aL
#define   ZERO      0x1008aL
#define   SENSE     0x3008aL
#define   READ      0x8008aL
#define   WRITE     0xa008aL

#define   LONG_DELAY  690000L
#define   SHORT_DELAY 23000L
#define   V_SHORT_DLY 500L
#define   FLOCK_ON    -1
#define   FLOCK_OFF   0

extern VOID end_hd();

VOID
sup_on()
{
	save_ssp = Super(0L);
}

VOID
sup_off()
{
	Super(save_ssp);
}

WORD
wait(time)
LONG time;
{

	while(time--) {
		if( (*gpip & 0x20) == 0)
			return(0);
	}         
	return(-1);
}

VOID
fifo_rd(count)
WORD count;
{
	long zero = 0L;

	*fifo = 0x90;
	*fifo = 0x190;
	*fifo = 0x90;
	*diskctl_w = count;
	*fifo = 0x8a;
	*diskctl_l = zero; /* this forces a move not a clr */
}

VOID
fifo_wrt(count)
WORD count;
{

	*fifo = 0x90;
	*fifo = 0x190;
	*diskctl_w = count;
	*fifo = 0x18a;
	*diskctl_l = 0x100L;
}

#if OLD
/* old read: */
WORD
hd_read(sectno,count,buf,dma)
LONG sectno;
WORD count;
LONG buf;
WORD dma;
{
	WORD err;

	sup_on();
	err = select_sector(READ,sectno,count,buf,dma,0L); /* goofed */
	if( err == 0 ) {
		fifo_rd(count);
		err = get_status(0x8a);
	}
	end_hd();
	sup_off();
	return(err);
}
#endif

#if NEW
WORD
nhd_read(sectno,count,buf,dma,drive)
LONG sectno;
WORD count;
LONG buf;
WORD dma;
WORD drive;	/* 0 or 1 */
{
	WORD err;

	sup_on();
	err = select_sector(READ,sectno,count,buf,dma,luns[drive]); /* goofed */
	if( err == 0 ) {
		fifo_rd(count);
		err = get_status(0x8a);
	}
	end_hd();
	sup_off();
	return(err);
}
#endif

#if OLD
WORD
hd_write(sectno,count,buf,dma)
LONG sectno;
WORD count;
LONG buf;
WORD dma;
{
	WORD err;

	sup_on();
	err = select_sector(WRITE,sectno,count,buf,dma,0L); /* goofed */
	if( err == 0 ) {
		fifo_wrt(count);
		err = get_status(0x18a);
	}
	end_hd();
	sup_off();
	return(err);
}
#endif

#if NEW
/* new version */
WORD
nhd_write(sectno,count,buf,dma,drive)
LONG sectno;
WORD count;
LONG buf;
WORD dma;
WORD drive;
{
	WORD err;

	sup_on();
	err = select_sector(WRITE,sectno,count,buf,dma,luns[drive]); /* goofed */
	if( err == 0 ) {
		fifo_wrt(count);
		err = get_status(0x18a);
	}
	end_hd();
	sup_off();
	return(err);
}
#endif

WORD
get_status(mode)
WORD mode;
{
	WORD err;

	err = wait(LONG_DELAY);
	if( !err ) {
		*fifo = mode;
		err = *diskctl_w & 0xff;
	}
	return(err);
}

VOID
end_hd()
{
	WORD dummy;

	*fifo = 0x80;
	dummy = *diskctl_w;
	*flock    = FLOCK_OFF;
}

VOID
set_dma(buf)
LONG buf;
{

	*dmalow = (BYTE) (buf & 0xff);
	*dmamid = (BYTE) ((buf >> 8) & 0xff);
	*dmahigh = (BYTE) ((buf >> 16) & 0xff);
}


WORD
select_sector(command,sectno,count,buf,dma,goofydrive)
LONG command,sectno;
WORD count;
LONG buf;
WORD dma;
LONG goofydrive; /* This is the new drive #, shifted to left 5. */
		 /* drive 0 would be 0. drive 1 would be, uh, 32. (0x20) */
{
	WORD err;

	*flock = FLOCK_ON;
	if ( buf )
		set_dma(buf);
	*fifo = 0x88;
	*diskctl_l = ( (LONG) dma << 21) | command;
	err = wait(SHORT_DELAY);
	if( !err ) {
		/* 
		 * old:
		 * *diskctl_l  = ( (LONG) dma << 21) 
		 *		 | (sectno & 0x1f0000) 
		 *		 | 0x8a;
		 *
		 * newer (but still wrong) :
		 * *diskctl_l = ( (LONG) dma << 21) 
		 *		| (goofydrive & 0xe00000L) 
		 *		| (sectno & 0x1f 0000L) 
		 *		| 0x8a;
		 *
		 * The second one (and the first one) BOTH output the SCSI 
		 * device number here where it isn't needed.  All that is
		 * needed is the unit number. 
		 * 
		 * NOTE: this means the original SUPRA driver as ul'd
		 *       is WRONG if using multiple SCSI devices. 
		 *
		 * dlm  --- August 3, 1987
		 */
		*diskctl_l = (goofydrive & 0xe00000L) 
			     | (sectno & 0x1f0000L) 
			     | 0x8a ;
	 
		err = wait(SHORT_DELAY);
		if( !err ) {
			*diskctl_l = (sectno & 0xff00) << 8 | 0x8a;
			err = wait(SHORT_DELAY);
			if( !err ) {
				*diskctl_l = (sectno & 0xff) << 16 | 0x8a;
				err = wait(SHORT_DELAY);
				if( !err ) {
					*diskctl_l = (LONG) (count & 0xff) <<
							 16 | 0x8a;
					err = wait(SHORT_DELAY);
				}
			}
		}
	}
	return(err);
}

WORD
send_dcb(count,dma,command,forever)
WORD count,dma,forever;
LONG command;
{
	WORD err;

	sup_on();
	err = select_sector(command,0L,count,0L,dma,0L);  /* goofed */
 	if ( !err ) {
		*diskctl_l = 0x8aL;
		do {
			err = wait(SHORT_DELAY);
		} while( err && forever );
		err = get_status(0x8a);
	}
	end_hd();
	sup_off();
	return(err);
}

WORD
sc_zero(dma)
WORD dma;
{

	return( send_dcb(0,dma,ZERO,0) ) ;
}

WORD
sc_ready(dma)
WORD dma;
{

	return( send_dcb(0,dma,READY,0) ) ;
}

WORD
byte_rd(buf,len)
BYTE *buf;
WORD len;
{
	WORD i;

	*diskctl_l = 0x8aL;
	wait(SHORT_DELAY);
	i=0;
	while( len ) {
		if( wait(V_SHORT_DLY) == -1 ) {
			buf[i++] =  (BYTE) (*diskctl_w & 0xff);
			len--;
		}
		else
			break;
	}
	wait(SHORT_DELAY);
	return(i);
}

#if OLD
WORD
hd_sense(dma,buf,len)
WORD dma,len;
BYTE *buf;
{
	WORD err;

	sup_on();
	err = select_sector(SENSE,0L,len,0L,dma,0L); /* goofed */
	if( err == 0 ) {
		byte_rd(buf,len);
		err = get_status(0x8a);
	}
	end_hd();
	sup_off();

	return(err);
}
#endif

#if NEW
WORD
nhd_sense(dma,buf,len, drive)
WORD dma,len;
BYTE *buf;
WORD drive;
{
	WORD err;

	sup_on();

	err = select_sector(SENSE,0L,len,0L,dma,luns[drive]); /* goofed */

	if( err == 0 ) {
		byte_rd(buf,len);
		err = get_status(0x8a);
	}

	end_hd();
	sup_off();

	return(err);
}
#endif

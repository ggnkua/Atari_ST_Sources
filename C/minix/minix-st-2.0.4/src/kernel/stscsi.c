/*
 * This file contains a driver for the SCSI Controller on the Atari TT.
 *
 * The driver supports two operations: read a block and write a block.
 * It accepts two messages, one for reading and one for writing,
 * both using message format m2 and with the same parameters:
 *
 *    m_type      DEVICE    PROC_NR     COUNT    POSITION  ADRRESS
 * ----------------------------------------------------------------
 * |  DEV_READ  | device  | proc nr |  bytes  |  offset | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * | DEV_WRITE  | device  | proc nr |  bytes  |  offset | buf ptr |
 * |--------------------------------------------------------------|
 * |SCATTERED_IO| device  | proc nr | requests|         | iov ptr |
 * |------------+---------+---------+---------+---------+---------|
 * | DEV_OPEN   | device  | proc nr |         |         |         |
 * |------------+---------+---------+---------+---------+---------|
 * | DEV_CLOSE  | device  | proc nr |         |         |         |
 * ----------------------------------------------------------------
 *
 * The file contains one entry point:
 *
 *	scsi_task: main entry when system is brought up
 *
 * A single TT may have several drives with different scsi id attached to it.
 *
 * Note that the driver is written for the situation where there is only one TT
 * present on the SCSI bus, which acts as initiator. 
 * Using the TT as target, or connecting multiple TT's to use one disk is not
 * supported (although it is technically feasible)
 *
 * Each physical drive contains normally up to 4 partitions, but when extended
 * partitioning is used this can be up to 12.
 * each physical drive contains 16 minor devices, so that
 *	DEVICE = (contr << (MINOR_SHIFT+1) | (drive << MINOR_SHIFT | minor;
 * These 16 minor devices per drive are interpreted as follows:
 *	d+0:	whole disk
 *	d+1:	partition 1	according to drive descriptor
 *	d+2:	partition 2	according to drive descriptor
 *	d+3:	partition 3	according to drive descriptor
 *	d+4:	partition 4	according to drive descriptor
 *	d+5:	partition 5	according to drive descriptor
 *	d+6:	partition 6	according to drive descriptor
 *	d+7:	partition 7	according to drive descriptor
 *	d+8:	partition 8	according to drive descriptor
 *	d+9:	partition 9	according to drive descriptor
 *	d+10:	partition 10	according to drive descriptor
 *	d+11:	partition 11	according to drive descriptor
 *	d+12:	partition 12	according to drive descriptor
 *	d+13:	drive descriptor (sector 0)
 *	d+14:	not used (later: whole disk but no badblock translation)
 *	d+15:	not used (later: head into shipping position)
 *
 * The suggested naming scheme is hd followed by the drive number and a 
 * 	letter (a-p) specifiying the partition. 
 *	E.g. /dev/hd1c will correspond with partition 2 on drive 1
 *		drive 1 is the drive at controller 0, lun 1.
 *
 * TODO:
 * - support removable media (hooks are already present)
 * - find out which partitions are minix and which not
 * - obey bad sector info
 * - only access partitions with pi_id == "MIX" (prog to modify pi_id?)
 */

#include "kernel.h"
#if (MACHINE == ATARI)
#include <minix/callnr.h>
#include <minix/com.h>
#include <string.h>
#include "proc.h"
#include "staddr.h"
#include "sthdc.h"
#include "stscsi.h"
#include "stscsidma.h"

#if (NR_SCSI_DRIVES == 0)
void scsiint()
{
}

void scsidmaint()
{
}
#else /* NR_SCSI_DRIVES > 0 */

#undef ADD_PARTS
#define ADD_PARTS 0
#define	SCAT_SECTORS	12	/* sectors buffered with scattered io */
#define TRACE(x)	/* x */
#define DEBUG(x)	/* x */

/* Parameters for the disk drive. */
#define SECTOR_SIZE	512	/* physical sector size in bytes */
#define MINORS_DRIVE	16
#define MINOR_SHIFT	4	/* 2 ** MINOR_SHIFT == #minors/drive */
#define	MAX_MINOR	(NR_SCSI_DRIVES<<MINOR_SHIFT)
#define MAX_ERRORS	10	/* how often to try rd/wt before quitting */
#define MAX_SEC0_ERRORS	 3	/* how often to try rd/wt sector 0 before */
				/* quitting, must not be too high because */
				/* non existing drives give error messages*/
				
/* timing constants */
#define	SCSI_POLL	10000	/* polling of scsi bits */

/* initiator scsi id bit */
#define	INITIATOR_ID_BIT	0x80	/* initiator has scsi id 7 */

PRIVATE struct pi pi[MAX_MINOR];/* begin and size of any minor device */
PRIVATE message mess;		/* message buffer for in and out */

PRIVATE int open_count[NR_SCSI_DRIVES];

#if (SCAT_SECTORS != 0)
_PROTOTYPE( PRIVATE int do_hvrdwt, (message *mp)			);
#endif
_PROTOTYPE( PRIVATE int do_open, (message *mp)				);
_PROTOTYPE( PRIVATE int do_ioctl, (message *mp)				);
_PROTOTYPE( PRIVATE int do_close, (message *mp)				);
_PROTOTYPE( PRIVATE int do_rdwt, (message *mp)				);
_PROTOTYPE( PRIVATE int do_transfer, (int rw, int pnr, int minor,
			long pos, int count, vir_bytes vadr)		);
_PROTOTYPE( PRIVATE void wait_req, (char *s)				);
_PROTOTYPE( PRIVATE void wait_req_done, (char *s)			);
_PROTOTYPE( PRIVATE int do_xfer, (int drive, phys_bytes address,
			long sector, int count, int rw)			);
_PROTOTYPE( PRIVATE void snd, (int c)					);
_PROTOTYPE( PRIVATE int rcv, (void)					);

/*===========================================================================*
 *				scsi_task				     *
 *===========================================================================*/
PUBLIC void scsi_task()
{
  register int r, caller, procno;

  TRACE(printf("scsi: task started\n"));

  /*
   * The main loop of the disk task.
   * It waits for a message, carries it out, and sends a reply.
   */
  while (TRUE) {
	receive(ANY, &mess);
	if (mess.m_source < 0)
		panic("disk task got message from ", mess.m_source);
	TRACE(printf("hd: received %d from %d\n",mess.m_type,mess.m_source));
	caller = mess.m_source;
	procno = mess.PROC_NR;

	switch (mess.m_type) {
	    case DEV_OPEN:	r = do_open(&mess);	break;
	    case DEV_CLOSE:	r = do_close(&mess);	break;
	    case DEV_READ:
	    case DEV_WRITE:	r = do_rdwt(&mess);	break;
#if (SCAT_SECTORS == 0)
	    case SCATTERED_IO:	r = do_vrdwt(&mess, do_rdwt);	break;
#else
	    case SCATTERED_IO:	r = do_hvrdwt(&mess);	break;
#endif
	    case DEV_IOCTL:	r = do_ioctl(&mess);	break;
	    default:		r = EINVAL;		break;
	}
	
	/* Finally, prepare and send the reply message. */
	mess.m_type = TASK_REPLY;	
	mess.REP_PROC_NR = procno;
	mess.REP_STATUS = r;	/* # of bytes transferred or error code */
	send(caller, &mess);	/* send reply to caller */
  }
}

/*===========================================================================*
 *				scsidmaint				     *
 *===========================================================================*/
PUBLIC void scsidmaint()
{
  unsigned char control_value;
  char *addr;
  unsigned long endaddr;
  int i;
  
  TRACE(printf("got scsi dma interrupt\n"));
  
  wait_req("no request in dma interrupt");
  SCSI_HW->MR2 = 0;
	
  control_value = SCSIDMA->dma_control;
  if (control_value & BERR) panic("bus error during scsi dma tranfer", NO_NUM);
  
  /* if a dma transfer does not fill a double word the control software must
     copy the data residue register to the destination address;
     dma_addr always contains the address of the last byte which is tranferred
     so its contents can be used to determine which part of the data residue
     register still needs to be written */
     
  endaddr = ((unsigned long)(SCSIDMA->dma_addr[AD_UP]) << 24) +
            ((unsigned long)(SCSIDMA->dma_addr[AD_UP_MID]) << 16) +
            ((unsigned long)(SCSIDMA->dma_addr[AD_LOW_MID]) << 8) +
             (unsigned long)(SCSIDMA->dma_addr[AD_LOW]);
            
  addr = (char *)(endaddr & ~3);
  i = 0;
  
  switch (endaddr & 3) {
  case 3:
  	*addr++ = SCSIDMA->data_residue[i++];
  	/* fall through for next byte */
  case 2:
  	*addr++ = SCSIDMA->data_residue[i++];
  	/* fall through for next byte */
  case 1:
  	*addr++ = SCSIDMA->data_residue[i++];
  	break;
  case 0:
  	break;
  }
  
  interrupt(SCSI);
}

/*===========================================================================*
 *				scsiint					     *
 *===========================================================================*/
PUBLIC void scsiint()
{
  register int temp;
   
  /* this should never occur
     the else is not really needed since panic never returns
     most of the interrupts are disabled because we're not 
     interested in them or because we have other ways to detect
     the event signalled by the interrupt (e.g. for end of dma the dma
     controller also generates an interrupt).
  */
     
  TRACE(printf("got scsi dma interrupt\n"));
  
  temp = SCSI_HW->BSR;
  if ((temp & INT) == 0) panic("spurious scsi interrupt", NO_NUM);
  else
    if (temp & EDMA) panic("end of dma interrupt", NO_NUM);
    else
      if (temp & SPER) panic("scsi parity interrupt", NO_NUM);
      else
        if (temp & PHSM) panic("scsi phase mismatch interrupt", NO_NUM);
        else
           if (temp & MBSY) panic("scsi busy loss interrupt", NO_NUM);
           else 
           {
	     temp = SCSI_HW->CSB & (SEL | IO) ;
	     if (temp == (SEL | IO)) panic("scsi reselection interrupt", NO_NUM);
	     else
	       if (temp & SEL) panic("scsi selection interrupt", NO_NUM);
	       else
	         if (!temp) panic("scsi bus reset interrupt", NO_NUM);
	         else panic("unknown scsi interrupt", NO_NUM);
           }
}

#if (SCAT_SECTORS > 0)
/*===========================================================================*
 *				do_hvrdwt				     *
 *===========================================================================*/
PRIVATE int do_hvrdwt(mp)
register message *mp;
{
/* Fetch a vector of i/o requests and handle them for hard disk. Use an inter-
 * nal buffer for contiguous requests to avoid overhead for single block dma
 * requests from FS and keep up with iterleave 1:1 for non-caching disk con-
 * trollers (makes io upto 3 times faster). Return status in the user vector.
 */

  register struct iorequest_s *iop;
  static struct iorequest_s iovec[NR_BUFS];
  phys_bytes iovec_phys, usrvec_phys, phys_ptr;
  unsigned nr_requests;
  static char buff[SCAT_SECTORS * SECTOR_SIZE];
  register long startpos, endpos;
  register unsigned request;
  register int result, limit, current;

  nr_requests = mp->COUNT;
  if (nr_requests > sizeof iovec / sizeof iovec[0])
	panic("FS gave scsi driver too big an i/o vector", nr_requests);
  iovec_phys = umap(proc_ptr, D, (vir_bytes) iovec, (vir_bytes) sizeof iovec);
  usrvec_phys = numap(mp->PROC_NR, (vir_bytes) mp->ADDRESS,
		      (vir_bytes) (nr_requests * sizeof iovec[0]));
  if (usrvec_phys == 0)
	panic("FS gave hd driver bad i/o vector", (int) mp->ADDRESS);
  phys_copy(usrvec_phys, iovec_phys, (phys_bytes)nr_requests * sizeof iovec[0]);

  iop = iovec;
  for(current = 0, limit = 1; current < nr_requests; limit = current + 1) {
	request = iop->io_request & ~OPTIONAL_IO;
	if (request == DEV_READ || request == DEV_WRITE) {
	    /* Handle all requests fitting in buff at once. Read requests should
	     * not skip more then 4 sectors. Write requests must be contiguous.
	     */
	    startpos = endpos = iop->io_position;
	    for (limit = current; limit < nr_requests; limit++, iop++) {
		if ((iop->io_request & ~OPTIONAL_IO) != request		    ||
		    iop->io_position+iop->io_nbytes > startpos+sizeof(buff) ||
		    (request == DEV_WRITE && iop->io_position != endpos)   ||
		    (request == DEV_READ &&
		    iop->io_position >= endpos + 4*SECTOR_SIZE))
			break;
		/* Copy to buffer on write requests */
		if (request == DEV_WRITE) {
		    if ((phys_ptr = numap(mp->PROC_NR, (vir_bytes) iop->io_buf,
					  (vir_bytes) iop->io_nbytes)) == 0)
			break;	/* Something wrong with user's address */
		    phys_copy( phys_ptr,
			(phys_bytes) &buff[iop->io_position-startpos],
			(phys_bytes) iop->io_nbytes );
		}
		endpos = iop->io_position + iop->io_nbytes;
	    }
	    if (limit == current) limit++;
	    iop = &iovec[current];
	}
	if (limit > current+1) {
	    result = do_transfer( request, WINCHESTER, mp->DEVICE, startpos,
				  (int) (endpos-startpos), (vir_bytes) buff );
	    if (result == endpos-startpos) {
		for (; current < limit; iop++, current++) {
		    result = 0;
		    if (request == DEV_READ) {
			if ((phys_ptr=numap(mp->PROC_NR, (vir_bytes)iop->io_buf,
					    (vir_bytes) iop->io_nbytes)) == 0)
				result = EINVAL;	/* user addr wrong */
			else phys_copy(
				(phys_bytes) &buff[iop->io_position - startpos],
				phys_ptr, (phys_bytes) iop->io_nbytes );
		    }
		    iop->io_nbytes = result;
		}
	    } else			/* do single transfers on error. */
		limit = current+1;	/* may cause additional transfers ! */
	}
	if (limit == current+1) {
	    result = do_transfer( iop->io_request & ~OPTIONAL_IO, mp->PROC_NR,
				  mp->DEVICE, iop->io_position, iop->io_nbytes,
				  (vir_bytes) iop->io_buf );
	    if (result == 0) break;	/* EOF */
	    if (result < 0) {
		iop->io_nbytes = result;
		if (iop->io_request & OPTIONAL_IO) break;  /* abort if opt */
	    } else
		iop->io_nbytes -= result;
	    current++; limit++; iop++;
	}
  }

  phys_copy(iovec_phys, usrvec_phys, (phys_bytes)nr_requests * sizeof iovec[0]);
  return(OK);
}
#endif

/*===========================================================================*
 *				do_open					     *
 *===========================================================================*/
PRIVATE int do_open(mp)
register message *mp;
{
  /* this function initialises the partition table for a device */
  static struct hi hi;		/* buffer for drive descriptor */
  register int r, maxminor, minor, dev;
  int errors;
 
  if ((mp->DEVICE & 15) == 15)
	return(OK);
  dev = mp->DEVICE >> MINOR_SHIFT;
  if (open_count[dev]++ != 0) return(OK);
  /* this function is called too often (on every partition mount) */
  minor = dev << MINOR_SHIFT;
  maxminor = minor + NPARTS + 8;
  /* read sector 0 of the drive */
  /* retry a number of times */
  for (errors = 0; errors < MAX_SEC0_ERRORS; errors++) {
      r = do_xfer(dev, (phys_bytes)&hi, 0L, 1, DEV_READ);
      if (r == OK)
	break;		/* if successful, exit loop */
  }
  /* if the read failed return */
  /* if the read succeeded fill partition table */
  /* note that since pi is in the data segment all entries are */
  /* initialised to 0 (which is also PI_INVALID) */
    
  if (r != OK) {
	open_count[dev]--;
	return(r);
  }
  /* the first minor number is for the whole device */
  pi[minor].pi_start = 0;
  pi[minor].pi_size = hi.hd_size;
  pi[minor].pi_flag = PI_VALID;
  
  for (r = 0, minor++; (r < NPARTS) && (minor <= maxminor); r++) {
      if (strncmp(hi.hd_pi[r].pi_id, "XGM", 3) == 0)
      {	/* yikes, an extended partition */
      	/* only one extended partition can occur in the root sector */
	struct hi hiext; /* buffer for extended part. drive descriptor */
	register int s, ext; /* ext gives the number of the extended part. */
	long offset;	 /* where the next extended root sector is */
	
        ext = r;
	hiext.hd_pi[ext].pi_start = 0;
	/* extended partitions contain an extended root sector
	   which is filled with one regular, and zero or one
	   extended partitions. 
	   The start of all extended partitions is relative to the
	   extended partition in the real root sector
          */
          while (ext >= 0)
          {
	    offset = hi.hd_pi[r].pi_start + hiext.hd_pi[ext].pi_start;
	    ext = -1;
	    /* retry a number of times */
	    for (errors = 0; errors < MAX_SEC0_ERRORS; errors++) {
	        s = do_xfer(dev, (phys_bytes)&hiext,
	                    offset, 1, DEV_READ);
	        if (s == OK)
		    break;		/* if successful, exit loop */
	    }
	    for (s = 0; (s < NPARTS) && (minor <= maxminor); s++) {
	    	if (hiext.hd_pi[s].pi_flag == PI_VALID)
	    	{
	            if (strncmp(hiext.hd_pi[s].pi_id, "XGM", 3) == 0)
	                ext = s;
		    else 
		    {
			if (strncmp(hiext.hd_pi[s].pi_id, "GEM", 3) != 0 &&
			    strncmp(hiext.hd_pi[s].pi_id, "BGM", 3) != 0 &&
			    strncmp(hiext.hd_pi[s].pi_id, "MIX", 3) != 0 )
					pi[minor].pi_flag = PI_INVALID;
			else {
			    pi[minor] = hiext.hd_pi[s];
			    pi[minor].pi_start += offset;
			    /* some sanity checks */
			    if ((pi[minor].pi_start + pi[minor].pi_size - 1 >
			           hi.hd_pi[r].pi_start + hi.hd_pi[r].pi_size) ||
			        (pi[minor].pi_start < hi.hd_pi[r].pi_start) ||
			        (pi[minor].pi_size < 0))
				    pi[minor].pi_flag = PI_INVALID;
			}
			minor++;
		    }
	    	}
	    }
	}
      } else {
	if (strncmp(hi.hd_pi[r].pi_id, "GEM", 3) != 0 &&
	    strncmp(hi.hd_pi[r].pi_id, "BGM", 3) != 0 &&
	    strncmp(hi.hd_pi[r].pi_id, "MIX", 3) != 0 )
			pi[minor].pi_flag = PI_INVALID;
	else
			pi[minor] = hi.hd_pi[r];
	minor++;
      }
  }
#if (ADDPARTS != 0)
  for (r = 0; (r < ADDPARTS) && (minor <= maxminor); r++, minor++){
	/* It is better to check. The danger is too big, in case you
	 * boot with a wrong diskette. (jw)
	 */
	if (strncmp(hi.hd_addpi[r].pi_id, "GEM", 3) != 0 &&
	    strncmp(hi.hd_addpi[r].pi_id, "BGM", 3) != 0 &&
	    strncmp(hi.hd_addpi[r].pi_id, "MIX", 3) != 0 )
			pi[minor].pi_flag = PI_INVALID;
	else
			pi[minor] = hi.hd_addpi[r];
  }
#endif
  /* the next partition is for sector 0 */
  pi[maxminor + 1].pi_size = 1;
  pi[maxminor + 1].pi_flag = PI_VALID;

  minor = dev << MINOR_SHIFT;
  for (r = 0; r < MINORS_DRIVE; r++, minor++)
     if (pi[minor].pi_flag != PI_INVALID)
     {
	    
	/* some sanity checks */
        if ((pi[minor].pi_start + pi[minor].pi_size -1 > hi.hd_size) ||
	    (pi[minor].pi_start < 0) ||
	    (pi[minor].pi_size < 0))
		pi[minor].pi_flag = PI_INVALID;
  	TRACE(
		printf("hd%d%c: 1st=%D, tot=%D\n", minor >> MINOR_SHIFT,
			(minor % MINORS_DRIVE) + 'a',
			pi[minor].pi_start,
			pi[minor].pi_size
		);
	);
      }
  return(OK);
}

/*===========================================================================*
 *				do_close				     *
 *===========================================================================*/
PRIVATE int do_close(mp)
register message *mp;
{
  /* this function initialises the partition table for a device */
  register int minor, r;
  register int dev;

  if ((mp->DEVICE & 15) == 15)
	return(OK);
  dev = mp->DEVICE >> MINOR_SHIFT;
  if (open_count[dev] == 0) {
  	printf("hd: Closing non open device %d\n", mp->DEVICE);
  	return(OK);
  }
  /* if mp->COUNT != 0 then the caller still has another pointer to the
     device (created by a dup or fork call), so don't do the final close */
  if (mp->COUNT != 0) return(OK);
  if (--open_count[dev] != 0) return(OK);
  minor = dev << MINOR_SHIFT;
  for (r = 0; r < MINORS_DRIVE; r++, minor++)
     pi[minor].pi_flag = PI_INVALID;
  return(OK);
}

/*===========================================================================*
 *				do_rdwt					     *
 *===========================================================================*/
PRIVATE int do_rdwt(mp)
register message *mp;
{
  return(do_transfer( mp->m_type, mp->PROC_NR, mp->DEVICE, mp->POSITION,
		      mp->COUNT, (vir_bytes) mp->ADDRESS ));
}

/*===========================================================================*
 *				do_transfer				     *
 *===========================================================================*/
PRIVATE int do_transfer(rw, pnr, minor, pos, count, vadr)
int rw;				/* DEV_READ, DEV_WRITE */
int pnr;			/* Process number */
register int minor;		/* minor device number affected */
long pos;			/* position off data on device */
register int count;		/* byte count to transfer */
vir_bytes vadr;			/* virtual src/dst of user buffer */
{
  register struct proc	*rp;
  register long		secnum, avail;
  register phys_bytes	address;
  int			r, errors, drive;

  drive = minor >> MINOR_SHIFT;
  if (drive < 0 || drive >= NR_SCSI_DRIVES)
	return(EIO);
  if (pi[minor].pi_flag == PI_INVALID)
	return(EIO);
  if ((pos % SECTOR_SIZE) != 0)
	return(EINVAL);
  secnum = (long)(pos / SECTOR_SIZE);
  if ((count % SECTOR_SIZE) != 0)
	return(EINVAL);
  rp = proc_addr(pnr);
  address = umap(rp, D, vadr, (vir_bytes) count);
  if (address == 0)
	return(EINVAL);
  count /= SECTOR_SIZE;
  TRACE(printf("hd%d: %s: sec=%D; cnt=%d\n",
	minor, rw == DEV_READ ? "read" : "write", secnum, count));
  avail = pi[minor].pi_size - secnum;
  if (avail <= 0)
	return(0);
  if (avail < count)
	count = avail;
  if (count <= 0)
	return(0);
  secnum += pi[minor].pi_start;
  rp->p_physio = 1;		/* disable (un)shadowing */
  /* This loop allows a failed operation to be repeated. */
  for (errors = 0; errors < MAX_ERRORS; errors++) {
	r = do_xfer(drive, address, secnum, count, rw);
	if (r == OK)
		break;		/* if successful, exit loop */
  }
  rp->p_physio = 0;		/* enable (un)shadowing */
  if (r != OK)
	return(EIO);
  return(count * SECTOR_SIZE);
}

/*===========================================================================*
 *				wait_req				     *
 *===========================================================================*/
 
PRIVATE void wait_req(s)
char *s;
{
    register int i = SCSI_POLL;
    
    /* wait for a request. the REQ line is active low */
    while(!(SCSI_HW->CSB & REQ)) if(!i--) {
/*
    	panic(s, NO_NUM);
*/
printf("wait_req: %s\n", s);
    }
}

/*===========================================================================*
 *				wait_req_done				     *
 *===========================================================================*/
 
PRIVATE void wait_req_done(s)
char *s;
{
    register int i = SCSI_POLL;
    
    /* wait for a request. the REQ line is active low */
    while(SCSI_HW->CSB & REQ) if(!i--) {
/*
    	panic(s, NO_NUM);
*/
printf("wait_req_done: %s\n", s);
    }
}

/*===========================================================================*
 *				do_xfer					     *
 *===========================================================================*/

PRIVATE int do_xfer(drive, address, sector, count, rw)
int		drive;
phys_bytes 	address;
long		sector;
int		count;
int		rw;
{
    register int i;
    phys_bytes byte_cnt = count * SECTOR_SIZE;
    unsigned char cmd;
    
    TRACE(printf("hd drive:%d address:0x%lx sector:%ld count=%d cmd:%s\n",
	  drive, address, sector, count, (rw==DEV_READ)?"READ":"WRITE")
    );
  
    /* initialise some scsi registers */
    
    SCSI_HW->ICR = 0;
    SCSI_HW->TCR = 0;
    
    TRACE(printf("checking if the scsi bus is free\n"));
    
    if (SCSI_HW->CSB & BSY) {
        /* I've chosen to reset the bus if it is not free
           other alternatives are to return without resetting, 
           or to issue a panic.
           Most likely this condition was caused when the system was
           rebooted when the SCSI bus was busy, so resetting seems to be
           the best action 
        */
    	printf("SCSI bus is busy, resetting it.");
    	SCSI_HW->ICR = ASS_RST;
    	SCSI_HW->ICR = 0;
    	return(EBUSY);
    }
    
    /* arbitration phase */
    
    /* since we assume that we are the only initiator there is no arbitration 
       phase. If we are not busy the scsi bus must be free */
    
    /* selection phase */
    
    TRACE(printf("start selection\n"));
    
    SCSI_HW->SER = 0;
    SCSI_HW->ODR = INITIATOR_ID_BIT | (1<<drive);
    SCSI_HW->ICR = ASS_DBUS | ASS_SEL;
    i = SCSI_POLL;
    while(!(SCSI_HW->CSB & BSY)) if(!i--) {
    	printf("No response from scsi device %d.\n", drive);
    	SCSI_HW->ICR = 0;
    	return(EIO);
    }
    SCSI_HW->ICR = 0;
    
    TRACE(printf("Selected.\n"));
    
    /* setup dma */
    
    if (rw == DEV_READ)
    {
        SCSIDMA->dma_control = 0;
        cmd = HD_RD;
    }
    else /* rw == DEV_WRITE */
    {
        SCSIDMA->dma_control = DIR;
        cmd = HD_WR;
    }
    
    SCSIDMA->dma_addr[AD_UP]      = (char) (address >> 24);
    SCSIDMA->dma_addr[AD_UP_MID]  = (char) (address >> 16);
    SCSIDMA->dma_addr[AD_LOW_MID] = (char) (address >>  8);
    SCSIDMA->dma_addr[AD_LOW]     = (char) (address      );
    SCSIDMA->dma_byte_cnt[AD_UP]      = (char) (byte_cnt >> 24);
    SCSIDMA->dma_byte_cnt[AD_UP_MID]  = (char) (byte_cnt >> 16);
    SCSIDMA->dma_byte_cnt[AD_LOW_MID] = (char) (byte_cnt >>  8);
    SCSIDMA->dma_byte_cnt[AD_LOW]     = (char) (byte_cnt      );
    
    TRACE(printf("Command phase.\n"));
    
    SCSI_HW->TCR = ASS_CD;
    
    wait_req("No request for command phase");
        
    if ((SCSI_HW->CSB & CSB_PHASE_MASK) != COMMAND_PHASE)
    	panic("command phase not reached", SCSI_HW->CSB & CSB_PHASE_MASK);
    	
    snd((unsigned char)(cmd&0x1F));
    snd((unsigned char)(((drive>>1)<<5) | (sector >> 16)));
    snd((unsigned char)(sector >> 8));
    snd((unsigned char)(sector));
    snd((unsigned char)(count));
    snd(0);
    SCSI_HW->TCR = 0;
    
    if (rw == DEV_READ)
    {
        wait_req("No request for data in phase");
	if ((SCSI_HW->CSB & CSB_PHASE_MASK) != DATA_IN_PHASE)
    	    panic("Data in phase not reached", SCSI_HW->CSB & CSB_PHASE_MASK);
	TRACE(printf("Data in phase.\n"));
	SCSI_HW->TCR = ASS_IO;
        SCSI_HW->MR2 = PINT | PCHK | DMA;
	SCSI_HW->SDI = 0;
	SCSIDMA->dma_control = ENABLE;
	receive(HARDWARE, &mess);	/* Wait for interrupt. */
    }
    else /* rw == DEV_WRITE */
    {
        wait_req("No request for data out phase");
	if ((SCSI_HW->CSB & CSB_PHASE_MASK) != DATA_OUT_PHASE)
    	    panic("Data out phase not reached", SCSI_HW->CSB & CSB_PHASE_MASK);
	TRACE(printf("Data out phase.\n"));
	SCSI_HW->ICR = ASS_DBUS;
        SCSI_HW->MR2 = PINT | PCHK | DMA;
	SCSI_HW->SDS = 0;
	SCSIDMA->dma_control = ENABLE | DIR;
	receive(HARDWARE, &mess);	/* Wait for interrupt. */
	SCSI_HW->ICR = 0;
    }
    
    wait_req("No request for status phase");
    
    if ((SCSI_HW->CSB & CSB_PHASE_MASK) != STATUS_PHASE)
    	panic("Status phase not reached", SCSI_HW->CSB & CSB_PHASE_MASK);
    	
    TRACE(printf("Status phase.\n"));
    
    i = rcv();
    if (i & 0x1e) panic("scsi status phase didn't return GOOD\n", i);
    	
    wait_req("No request for message in phase");
    
    if ((SCSI_HW->CSB & CSB_PHASE_MASK) != MESSAGE_IN_PHASE)
    	panic("Message in phase not reached", SCSI_HW->CSB & CSB_PHASE_MASK);
    	
    TRACE(printf("Message in phase.\n"));
    
    i = rcv();
    if (i) panic("scsi message in phase didn't return COMMAND COMPLETE\n", i);

    TRACE(printf("Target disconnected\n"));
    
    return(OK);
}

PRIVATE void snd(c)
int c;
{
    TRACE(printf("snd sends: %02x\n", c));
    
    wait_req("No request for snd");
    SCSI_HW->ODR = c;
    SCSI_HW->ICR = ASS_DBUS;
    SCSI_HW->ICR = ASS_DBUS | ASS_ACK;
    wait_req_done("Request for snd not terminated");
    SCSI_HW->ICR = 0;
}

PRIVATE int rcv()
{
    int c;
    
    wait_req("No request for rcv");
    c = SCSI_HW->CSD;
    
    TRACE(printf("rcv got: %02x\n", c));
    
    /* acknowledge reception */
    SCSI_HW->ICR = ASS_ACK;
    wait_req_done("Request for rcv not terminated");
    SCSI_HW->ICR = 0;

    return(c);
}

#include <sgtty.h>
/*===========================================================================*
 *				do_ioctl				     *
 *===========================================================================*/
PRIVATE int do_ioctl(mp)
register message *mp;
{
#if 0
  register phys_bytes	uaddress, kaddress;
  register struct proc	*rp;
  register int r, drive, wrbit = 0;
  int i;
  struct   scsi_cmd kcmd;
  /*  buf is used to temporarily hold the command bytes */
  static   unsigned char buf[SECTOR_SIZE];

  rp = proc_addr(mp->PROC_NR);
  switch(mp->TTY_REQUEST) {
     case SCSI_READ:
     case SCSI_WRITE:
     	  if ((mp->DEVICE & 15) != 15)
     	  	return(EINVAL);
	  uaddress = umap(rp, D, (vir_bytes) mp->ADDRESS, (vir_bytes) sizeof(struct scsi_cmd));
	  break;
     default:
	  return(EINVAL);
  }
  if (uaddress == 0)
	return(EINVAL);
  switch(mp->TTY_REQUEST) {
     case SCSI_WRITE:
	  wrbit = WRBIT;
     case SCSI_READ:
	  /* copy the command block */
	  kaddress = umap(proc_ptr, S, (vir_bytes) &kcmd, (vir_bytes) sizeof(kcmd));
	  phys_copy(uaddress, kaddress, (vir_bytes) sizeof(kcmd));

	  /* copy the command bytes */
	  uaddress = umap(rp, D, (vir_bytes) kcmd.cmd, (vir_bytes) kcmd.cmd_cnt);
	  if (uaddress == 0)
		return(EINVAL);
	  kaddress = umap(proc_ptr, S, (vir_bytes) buf, (vir_bytes) kcmd.cmd_cnt);
	  phys_copy(uaddress, kaddress, (vir_bytes) kcmd.cmd_cnt);

	  uaddress = umap(rp, D, (vir_bytes) kcmd.buf, (vir_bytes) kcmd.size);
	  if (uaddress == 0)
		return(EINVAL);

	  if (kcmd.size > SECTOR_SIZE)
		return(EINVAL);

	  drive = mp->DEVICE >> MINOR_SHIFT;
	  buf[0] = ((drive>>1)<<5) | buf[0];
	  dmagrab(WINCHESTER, hdcint);
	  dmaaddr(uaddress);		/* DMA address setup */
	  r = do_cmd(buf, kcmd.cmd_cnt, (kcmd.size + 511)/512, wrbit);	/* command parameters */
	  if (r == OK) {
		receive(HARDWARE, &mess);	/* Wait for interrupt. */
#ifdef OLDSUPRA
		IDISABLE();
#endif
		r = dmardat(wrbit | FDC | HDC | A0, HDC_DELAY);

	  }
#if (FASTDISK == 0)
		for (i = 0; i< COMMAND_DELAY; i++) /* nothing */;
#endif
	  dmafree(WINCHESTER);
	  break;
  }
  return(r);
#endif
}
#endif
#endif

/* This file contains the device dependent part of a driver for the WD
 * winchester controller from Western Digital (WX-2 and related controllers).
 * It was written by Adri Koppes.
 *
 * The file contains one entry point:
 *
 *	 xt_winchester_task:	main entry when system is brought up
 *
 *
 * Changes:
 *	10 Apr 1987 by Gary Oliver: use with the Western Digital WX-2.
 *		  ? by Harry McGavran: robust operation on turbo clones.
 *		  ? by Mike Mitchell: WX-2 auto configure operation.
 *	 2 May 1992 by Kees J. Bot: device dependent/independent split.
 *	27 May 2000 by Kees J. Bot: d-d/i rewrite.
 */

#include "kernel.h"
#include "driver.h"
#include "drvlib.h"

#if ENABLE_XT_WINI

/* If the DMA buffer is large enough then use it always. */
#define USE_BUF		(DMA_BUF_SIZE > BLOCK_SIZE)

/* I/O Ports used by winchester disk task. */
#define WIN_DATA       0x320	/* winchester disk controller data register */
#define WIN_STATUS     0x321	/* winchester disk controller status register */
#define WST_REQ	       0x001	/* Request bit */
#define WST_INPUT      0x002	/* Set if controller is writing to cpu */
#define WST_BUS	       0x004	/* Command/status bit */
#define WST_BUSY       0x008	/* Busy */
#define WST_DRQ        0x010	/* DMA request */
#define WST_IRQ        0x020	/* Interrupt request */
#define WIN_SELECT     0x322	/* winchester disk controller select port */
#define WIN_DMA	       0x323	/* winchester disk controller dma register */
#define DMA_ADDR       0x006	/* port for low 16 bits of DMA address */
#define DMA_TOP	       0x082	/* port for top 4 bits of 20-bit DMA addr */
#define DMA_COUNT      0x007	/* port for DMA count (count =	bytes - 1) */
#define DMA_FLIPFLOP   0x00C	/* DMA byte pointer flop-flop */
#define DMA_MODE       0x00B	/* DMA mode port */
#define DMA_INIT       0x00A	/* DMA init port */

/* Winchester disk controller command bytes. */
#define WIN_RECALIBRATE	0x01	/* command for the drive to recalibrate */
#define WIN_SENSE	0x03	/* command for the controller to get its status */
#define WIN_READ	0x08	/* command for the drive to read */
#define WIN_WRITE	0x0a	/* command for the drive to write */
#define WIN_SPECIFY	0x0C	/* command for the controller to accept params	*/
#define WIN_ECC_READ	0x0D	/* command for the controller to read ecc length */

#define DMA_INT		   3	/* Command with dma and interrupt */
#define INT		   2	/* Command with interrupt, no dma */
#define NO_DMA_INT	   0	/* Command without dma and interrupt */

/* DMA channel commands. */
#define DMA_READ	0x47	/* DMA read opcode */
#define DMA_WRITE	0x4B	/* DMA write opcode */

/* Parameters for the disk drive. */
#ifndef NR_SECTORS
/* For RLL drives NR_SECTORS has to be defined in the makefile or in config.h.
 * There is some hope of getting it from the parameter table for these drives,
 * and then this driver should use wn_sectors like at_wini.c.
 * Unfortunately it is not standard in XT parameter tables.
 */
#define NR_SECTORS	  17	/* number of sectors per track */
#endif

/* Error codes */
#define ERR		 (-1)	/* general error */
#define ERR_BAD_SECTOR	 (-2)	/* block marked bad detected */

/* Miscellaneous. */
#define MAX_DRIVES         2	/* this driver support two drives (d0 - d1) */
#define MAX_ERRORS	   4	/* how often to try rd/wt before quitting */
#define MAX_RESULTS	   4	/* max number of bytes controller returns */
#define NR_DEVICES      (MAX_DRIVES * DEV_PER_DRIVE)
#define SUB_PER_DRIVE	(NR_PARTITIONS * NR_PARTITIONS)
#define NR_SUBDEVS	(MAX_DRIVES * SUB_PER_DRIVE)
#define MAX_WIN_RETRY  32000	/* max # times to try to output to WIN */
#if AUTO_BIOS
#define AUTO_PARAM     0x1AD	/* drive parameter table starts here in sect 0	*/
#define AUTO_ENABLE	0x10	/* auto bios enabled bit from status reg */
/* some start up parameters in order to extract the drive parameter table */
/* from the winchester. these should not need changed. */
#define AUTO_CYLS	 306	/* default number of cylinders */
#define AUTO_HEADS	   4	/* default number of heads */
#define AUTO_RWC	 307	/* default reduced write cylinder */
#define AUTO_WPC	 307	/* default write precomp cylinder */
#define AUTO_ECC	  11	/* default ecc burst */
#define AUTO_CTRL	   5	/* default winchester stepping speed byte */
#endif

/* Variables. */
PRIVATE struct wini {		/* main drive struct, one entry per drive */
  unsigned wn_cylinders;	/* number of cylinders */
  unsigned wn_heads;		/* number of heads */
  unsigned wn_reduced_wr;	/* first cylinder with reduced write current */
  unsigned wn_precomp;		/* first cylinder with write precompensation */
  unsigned wn_max_ecc;		/* maximum ECC burst length */
  unsigned wn_ctlbyte;		/* control byte for COMMANDS (10-Apr-87 GO) */
  unsigned wn_open_ct;		/* in-use count */
  struct device wn_part[DEV_PER_DRIVE];    /* disks and partitions */
  struct device wn_subpart[SUB_PER_DRIVE]; /* subpartitions */
} wini[MAX_DRIVES], *w_wn;

PRIVATE int win_tasknr;			/* my task number */
PRIVATE int w_need_reset = FALSE;	/* set when controller must be reset */
PRIVATE int nr_drives;			/* Number of drives */
PRIVATE int w_switches;			/* Drive type switches */
PRIVATE int w_drive;			/* selected drive */
PRIVATE struct device *w_dv;		/* device's base and size */
PRIVATE char w_results[MAX_RESULTS];/* the controller can give lots of output */


FORWARD _PROTOTYPE( struct device *w_prepare, (int device) );
FORWARD _PROTOTYPE( char *w_name, (void) );
FORWARD _PROTOTYPE( int w_transfer, (int proc_nr, int opcode, off_t position,
					iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( void w_dma_setup, (int opcode, phys_bytes address,
							unsigned count) );
FORWARD _PROTOTYPE( int w_1rdwt, (int opcode, unsigned long block,
					phys_bytes address, unsigned count) );
FORWARD _PROTOTYPE( int win_results, (void) );
FORWARD _PROTOTYPE( void win_out, (int val) );
FORWARD _PROTOTYPE( int w_reset, (void) );
FORWARD _PROTOTYPE( int w_handler, (irq_hook_t hook) );
FORWARD _PROTOTYPE( int win_specify, (int drive) );
FORWARD _PROTOTYPE( int check_init, (void) );
FORWARD _PROTOTYPE( int read_ecc, (void) );
FORWARD _PROTOTYPE( int hd_wait, (int bits) );
FORWARD _PROTOTYPE( int com_out, (int mode, u8_t *command) );
FORWARD _PROTOTYPE( void init_params, (void) );
FORWARD _PROTOTYPE( int w_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int w_do_close, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void w_init, (void) );
FORWARD _PROTOTYPE( void copy_param, (char *src, struct wini *dest) );
FORWARD _PROTOTYPE( void w_geometry, (struct partition *entry));


/* Entry points to this driver. */
PRIVATE struct driver w_dtab = {
  w_name,	/* current device's name */
  w_do_open,	/* open or mount request, initialize device */
  w_do_close,	/* release device */
  do_diocntl,	/* get or set a partition's geometry */
  w_prepare,	/* prepare for I/O on a given minor device */
  w_transfer,	/* do the I/O */
  nop_cleanup,	/* no cleanup needed */
  w_geometry	/* tell the geometry of the disk */
};


/*===========================================================================*
 *				xt_winchester_task			     *
 *===========================================================================*/
PUBLIC void xt_winchester_task()
{
  static irq_hook_t hook;

  win_tasknr = proc_number(proc_ptr);

  init_params();

  put_irq_handler(&hook, XT_WINI_IRQ, w_handler);
  enable_irq(&hook);	/* ready for winchester interrupts */

  driver_task(&w_dtab);
}


/*===========================================================================*
 *				w_prepare				     *
 *===========================================================================*/
PRIVATE struct device *w_prepare(device)
int device;
{
/* Prepare for I/O on a device. */

  if (device < NR_DEVICES) {			/* d0, d0p[0-3], d1, ... */
	w_drive = device / DEV_PER_DRIVE;	/* save drive number */
	w_wn = &wini[w_drive];
	w_dv = &w_wn->wn_part[device % DEV_PER_DRIVE];
  } else
  if ((unsigned) (device -= MINOR_d0p0s0) < NR_SUBDEVS) {/*d[0-7]p[0-3]s[0-3]*/
	w_drive = device / SUB_PER_DRIVE;
	w_wn = &wini[w_drive];
	w_dv = &w_wn->wn_subpart[device % SUB_PER_DRIVE];
  } else {
	return(NIL_DEV);
  }
  return(w_drive < nr_drives ? w_dv : NIL_DEV);
}


/*===========================================================================*
 *				w_name					     *
 *===========================================================================*/
PRIVATE char *w_name()
{
/* Return a name for the current device. */
  static char name[] = "xt-d0";

  name[4] = '0' + w_drive;
  return name;
}


/*===========================================================================*
 *				w_transfer				     *
 *===========================================================================*/
PRIVATE int w_transfer(proc_nr, opcode, position, iov, nr_req)
int proc_nr;			/* process doing the request */
int opcode;			/* DEV_GATHER or DEV_SCATTER */
off_t position;			/* offset on device to read or write */
iovec_t *iov;			/* pointer to read or write request vector */
unsigned nr_req;		/* length of request vector */
{
  iovec_t *iop, *iov_end = iov + nr_req;
  int r, errors;
  unsigned nbytes, count, chunk, dma_count;
  unsigned long block;
  unsigned long dv_size = cv64ul(w_dv->dv_size);
  phys_bytes dma_phys, first_dma_phys;
  phys_bytes user_base = proc_vir2phys(proc_addr(proc_nr), 0);

  /* Check disk address. */
  if ((position & SECTOR_MASK) != 0) return(EINVAL);

  errors = 0;

  while (nr_req > 0) {
	/* How many bytes to transfer? */
	nbytes = 0;
	for (iop = iov; iop < iov_end; iop++) {
		if (USE_BUF && nbytes + iop->iov_size > DMA_BUF_SIZE) {
			/* Don't do half a segment if you can avoid it. */
			if (nbytes == 0) nbytes = DMA_BUF_SIZE;
			break;
		}
		nbytes += iop->iov_size;
		if ((nbytes & SECTOR_MASK) != 0) return(EINVAL);
	}

	/* Which block on disk and how close to EOF? */
	if (position >= dv_size) return(OK);		/* At EOF */
	if (position + nbytes > dv_size) nbytes = dv_size - position;
	block = div64u(add64ul(w_dv->dv_base, position), SECTOR_SIZE);

	/* Degrade to per-sector mode if there were errors. */
	if (errors > 0) nbytes = SECTOR_SIZE;

	if (!USE_BUF) {
		/* How many bytes can be found on consecutive pages? */
		first_dma_phys = user_base + iov[0].iov_addr;
		count = 0;
		for (iop = iov; count < nbytes; iop++) {
			/* Memory chunk to DMA. */
			dma_phys = user_base + iop->iov_addr;
			if (dma_phys != first_dma_phys + count) break;

			dma_count = dma_bytes_left(dma_phys);
			if (dma_count < iop->iov_size) {
				/* Can't do this segment fully. */
				if (count == 0)
					count = dma_count & ~SECTOR_MASK;
				break;
			}
			count += iop->iov_size;
		}
		if (count == 0) {
			/* The first segment crosses a 64K boundary. */
			first_dma_phys = tmp_phys;
			count = SECTOR_SIZE;
			if (opcode == DEV_SCATTER) {
				phys_copy(user_base + iov[0].iov_addr,
						first_dma_phys,
						(phys_bytes) SECTOR_SIZE);
			}
		}
		if (count < nbytes) nbytes = count;
	} else {
		first_dma_phys = tmp_phys;
		if (opcode == DEV_SCATTER) {
			/* Copy from user space to the DMA buffer. */
			count = 0;
			for (iop = iov; count < nbytes; iop++) {
				chunk = iov->iov_size;
				if (count + chunk > nbytes)
					chunk = nbytes - count;
				phys_copy(user_base + iop->iov_addr,
						first_dma_phys + count,
						(phys_bytes) chunk);
				count += chunk;
			}
		}
	}

	/* First check to see if a reset is needed. */
	if (w_need_reset) w_reset();

	/* Now set up the DMA chip. */
	w_dma_setup(opcode, first_dma_phys, count);

	/* Perform the transfer. */
	r = w_1rdwt(opcode, block, first_dma_phys, nbytes);

	if (r != OK) {
		/* An error occurred, try again sector by sector unless */
		if (r == ERR_BAD_SECTOR || ++errors == MAX_ERRORS) return(EIO);

		/* Reset if halfway. */
		if (errors == MAX_ERRORS / 2) w_need_reset = TRUE;
		continue;
	}

	if (opcode == DEV_GATHER) {
		if (!USE_BUF) {
			/* Copy to the badly placed segment. */
			if (first_dma_phys == tmp_phys) {
				phys_copy(first_dma_phys,
						user_base + iov[0].iov_addr,
						(phys_bytes) SECTOR_SIZE);
			}
		} else {
			/* Copy from the DMA buffer to user space. */
			count = 0;
			for (iop = iov; count < nbytes; iop++) {
				chunk = iov->iov_size;
				if (count + chunk > nbytes)
					chunk = nbytes - count;
				phys_copy(first_dma_phys + count,
						user_base + iop->iov_addr,
						(phys_bytes) chunk);
				count += chunk;
			}
		}
	}

	/* Book the bytes successfully transferred. */
	position += nbytes;
	for (;;) {
		if (nbytes < iov->iov_size) {
			/* Not done with this one yet. */
			iov->iov_addr += nbytes;
			iov->iov_size -= nbytes;
			break;
		}
		nbytes -= iov->iov_size;
		iov->iov_addr += iov->iov_size;
		iov->iov_size = 0;
		if (nbytes == 0) {
			/* The rest is optional, so we return to give FS a
			 * chance to think it over.
			 */
			return(OK);
		}
		iov++;
		nr_req--;
	}
  }
  return(OK);
}


/*==========================================================================*
 *				w_dma_setup				    *
 *==========================================================================*/
PRIVATE void w_dma_setup(opcode, address, count)
int opcode;			/* DEV_GATHER or DEV_SCATTER */
phys_bytes address;		/* address in memory */
unsigned count;			/* bytes to transfer */
{
/* The IBM PC can perform DMA operations by using the DMA chip.  To use it,
 * the DMA (Direct Memory Access) chip is loaded with the 20-bit memory address
 * to by read from or written to, the byte count minus 1, and a read or write
 * opcode.  This routine sets up the DMA chip.  Note that the chip is not
 * capable of doing a DMA across a 64K boundary (e.g., you can't read a
 * 512-byte block starting at physical address 65520).
 */

  /* Set up the DMA registers. */
  outb(DMA_FLIPFLOP, 0);		/* write anything to reset it */
  outb(DMA_MODE, opcode == DEV_SCATTER ? DMA_WRITE : DMA_READ);
  outb(DMA_ADDR, (int) address >>  0);
  outb(DMA_ADDR, (int) address >>  8);
  outb(DMA_TOP, (int) (address >> 16));
  outb(DMA_COUNT, (count - 1) >> 0);
  outb(DMA_COUNT, (count - 1) >> 8);
}


/*=========================================================================*
 *				w_1rdwt					   *
 *=========================================================================*/
PRIVATE int w_1rdwt(opcode, block, address, count)
int opcode;			/* DEV_GATHER or DEV_SCATTER */
unsigned long block;		/* block on disk */
phys_bytes address;		/* address in memory */
unsigned int count;		/* bytes to transfer */
{
/* Read or write count bytes starting with the given block. */

  unsigned cylinder, sector, head, secspcyl = w_wn->wn_heads * NR_SECTORS;
  u8_t command[6];
  message mess;

  cylinder = block / secspcyl;
  head = (block % secspcyl) / NR_SECTORS;
  sector = block % NR_SECTORS;

  /* The command is issued by outputting 6 bytes to the controller chip. */
  command[0] = opcode == DEV_SCATTER ? WIN_WRITE : WIN_READ;
  command[1] = head | (w_drive << 5);
  command[2] = ((cylinder & 0x0300) >> 2) | sector;
  command[3] = cylinder & 0xFF;
  command[4] = count >> SECTOR_SHIFT;
  command[5] = w_wn->wn_ctlbyte;

  if (com_out(DMA_INT, command) != OK)
	return(ERR);

  outb(DMA_INIT, 3);	/* initialize DMA */

  /* Block, waiting for disk interrupt. */
  receive(HARDWARE, &mess);

  /* Get controller status and check for errors. */
  if (win_results() == OK)
	return(OK);
  if ((w_results[0] & 63) == 24)
	read_ecc();
  else
	w_need_reset = TRUE;
  return(ERR);
}


/*==========================================================================*
 *				win_results				    *
 *==========================================================================*/
PRIVATE int win_results()
{
/* Extract results from the controller after an operation. */

  int i, status;
  u8_t command[6];

  status = inb(WIN_DATA);
  outb(WIN_DMA, 0);
  if (!(status & 2))		/* Test "error" bit */
	return(OK);
  command[0] = WIN_SENSE;
  command[1] = w_drive << 5;
  if (com_out(NO_DMA_INT, command) != OK)
	return(ERR);

  /* Loop, extracting bytes from WIN */
  for (i = 0; i < MAX_RESULTS; i++) {
	if (hd_wait(WST_REQ) != OK)
		return(ERR);
	status = inb(WIN_DATA);
	w_results[i] = status & BYTE;
  }
  if (hd_wait(WST_REQ) != OK)	/* Missing from			*/
	 return (ERR);		/* Original.  11-Apr-87 G.O.	*/

  status = inb(WIN_DATA);	 /* Read "error" flag */

  if (((status & 2) != 0) || (w_results[0] & 0x3F)) {
	return(ERR);
  } else
	return(OK);
}


/*===========================================================================*
 *				win_out					     *
 *===========================================================================*/
PRIVATE void win_out(val)
int val;		/* write this byte to winchester disk controller */
{
/* Output a byte to the controller.  This is not entirely trivial, since you
 * can only write to it when it is listening, and it decides when to listen.
 * If the controller refuses to listen, the WIN chip is given a hard reset.
 */
  int r;

  if (w_need_reset) return;	/* if controller is not listening, return */

  do {
	r = inb(WIN_STATUS);
  } while((r & (WST_REQ | WST_BUSY)) == WST_BUSY);

  outb(WIN_DATA, val);
}


/*===========================================================================*
 *				w_reset					     *
 *===========================================================================*/
PRIVATE int w_reset()
{
/* Issue a reset to the controller.  This is done after any catastrophe,
 * like the controller refusing to respond.
 */

  int r, i, drive;
  u8_t command[6];
  message mess;

  /* Strobe reset bit low. */
  outb(WIN_STATUS, 0);

  milli_delay(5);	/* Wait for a while */

  outb(WIN_SELECT, 0);	/* Issue select pulse */
  for (i = 0; i < MAX_WIN_RETRY; i++) {
	r = inb(WIN_STATUS);
	if (r & (WST_DRQ | WST_IRQ))
		return(ERR);

	if ((r & (WST_BUSY | WST_BUS | WST_REQ)) ==
		(WST_BUSY | WST_BUS | WST_REQ))
		break;
  }

  if (i == MAX_WIN_RETRY) {
	printf("%s: reset failed, status = %x\n", w_name(), r);
	return(ERR);
  }

  /* Reset succeeded.  Tell WIN drive parameters. */
  w_need_reset = FALSE;

  for (drive = 0; drive < nr_drives; drive++) {
	if (win_specify(drive) != OK)
		return (ERR);

	command[0] = WIN_RECALIBRATE;
	command[1] = drive << 5;
	command[5] = wini[drive].wn_ctlbyte;

	if (com_out(INT, command) != OK)
		return(ERR);

	receive(HARDWARE, &mess);

	if (win_results() != OK) {
		/* No actual drive present? */
		nr_drives = drive;
	}
  }
  return(nr_drives > 0 ? OK : ERR);
}


/*==========================================================================*
 *				w_handler				    *
 *==========================================================================*/
PRIVATE int w_handler(hook)
irq_hook_t *hook;
{
/* Disk interrupt, send message to winchester task and reenable interrupts. */

  int r, i;

  outb(DMA_INIT, 0x07);		/* Disable int from DMA */

  for (i = 0; i < MAX_WIN_RETRY; ++i) {
	r = inb(WIN_STATUS);
	if (r & WST_IRQ)
		break;		/* Exit if end of int */
  }

  interrupt(win_tasknr);
  return 1;
}


/*============================================================================*
 *				win_specify				      *
 *============================================================================*/
PRIVATE int win_specify(drive)
int drive;
{
  struct wini *wn = &wini[drive];
  u8_t command[6];

  command[0] = WIN_SPECIFY;		/* Specify some parameters */
  command[1] = drive << 5;		/* Drive number */

  if (com_out(NO_DMA_INT, command) != OK)	/* Output command block */
	return(ERR);

	/* No. of cylinders (high byte) */
  win_out(wn->wn_cylinders >> 8);

	/* No. of cylinders (low byte) */
  win_out(wn->wn_cylinders);

	/* No. of heads */
  win_out(wn->wn_heads);

	/* Start reduced write (high byte) */
  win_out(wn->wn_reduced_wr >> 8);

	/* Start reduced write (low byte) */
  win_out(wn->wn_reduced_wr);

	/* Start write precompensation (high byte) */
  win_out(wn->wn_precomp >> 8);

	/* Start write precompensation (low byte) */
  win_out(wn->wn_precomp);

	/* Ecc burst length */
  win_out(wn->wn_max_ecc);

  if (check_init() != OK) {  /* See if controller accepted parameters */
	w_need_reset = TRUE;
	return(ERR);
  } else
	return(OK);
}


/*============================================================================*
 *				check_init				      *
 *============================================================================*/
PRIVATE int check_init()
{
/* Routine to check if controller accepted the parameters */
  int r, s;

  if (hd_wait(WST_REQ | WST_INPUT) == OK) {
	r = inb(WIN_DATA);

	do {
		s = inb(WIN_STATUS);
	} while(s & WST_BUSY);		/* Loop while still busy */

	if (r & 2)		/* Test error bit */
		return(ERR);
	else
		return(OK);
  } else
	return (ERR);	/* Missing from original: 11-Apr-87 G.O. */
}


/*============================================================================*
 *				read_ecc				      *
 *============================================================================*/
PRIVATE int read_ecc()
{
/* Read the ecc burst-length and let the controller correct the data */

  int r;
  u8_t command[6];

  command[0] = WIN_ECC_READ;
  if (com_out(NO_DMA_INT, command) == OK && hd_wait(WST_REQ) == OK) {
	r = inb(WIN_DATA);
	if (hd_wait(WST_REQ) == OK) {
		r = inb(WIN_DATA);
		if (r & 1)
			w_need_reset = TRUE;
	}
  }
  return(ERR);
}


/*============================================================================*
 *				hd_wait					      *
 *============================================================================*/
PRIVATE int hd_wait(bits)
int bits;
{
/* Wait until the controller is ready to receive a command or send status */

  int r, i = 0;

  do {
	r = inb(WIN_STATUS) & bits;
  } while ((i++ < MAX_WIN_RETRY) && r != bits);		/* Wait for ALL bits */

  if (i >= MAX_WIN_RETRY) {
	w_need_reset = TRUE;
	return(ERR);
  } else
	return(OK);
}


/*============================================================================*
 *				com_out					      *
 *============================================================================*/
PRIVATE int com_out(mode, commandp)
int mode;
u8_t *commandp;
{
/* Output the command block to the winchester controller and return status */

  int i, r;

  outb(WIN_DMA, mode);
  outb(WIN_SELECT, mode);
  for (i = 0; i < MAX_WIN_RETRY; i++) {
	r = inb(WIN_STATUS);
	if (r & WST_BUSY)
		break;
  }

  if (i == MAX_WIN_RETRY) {
	w_need_reset = TRUE;
	return(ERR);
  }


  for (i = 0; i < 6; i++) {
	if (hd_wait(WST_REQ) != OK)
		break;		/* No data request pending */

	r = inb(WIN_STATUS);

	if ((r & (WST_BUSY | WST_BUS | WST_INPUT)) !=
		(WST_BUSY | WST_BUS))
		break;

	outb(WIN_DATA, commandp[i]);
  }

  if (i != 6)
	return(ERR);
  else
	return(OK);
}


/*==========================================================================*
 *				init_params				    *
 *==========================================================================*/
PRIVATE void init_params()
{
/* This routine is called at startup to initialize the number of drives and
 * the controller.
 */
  u16_t parv[2];
  unsigned int drive;
  int dtype;
  phys_bytes address, buf_phys;
  char buf[16];

  /* Get the number of drives from the bios */
  buf_phys = vir2phys(buf);
  phys_copy(0x475L, buf_phys, 1L);
  nr_drives = buf[0] & 0xFF;
  if (nr_drives > MAX_DRIVES) nr_drives = MAX_DRIVES;

  /* Read the switches from the controller */
  w_switches = inb(WIN_SELECT);

#if AUTO_BIOS
  /* If no auto configuration or not enabled then go to the ROM. */
  if (!(w_switches & AUTO_ENABLE)) {
#endif
	for (drive = 0; drive < nr_drives; drive++) {
		/* Calculate the drive type */
		dtype = (w_switches >> (2 * drive)) & 03;

		/* Copy the BIOS parameter vector */
		phys_copy(WINI_0_PARM_VEC * 4L, vir2phys(parv), 4L);

		/* Calculate the parameters' address and copy them to buf */
		address = hclick_to_physb(parv[1]) + parv[0] + 16 * dtype;
		phys_copy(address, buf_phys, 16L);

		/* Copy the parameters to the structure of the drive. */
		copy_param(buf, &wini[drive]);
	}
#if AUTO_BIOS
  }
#endif
}


/*============================================================================*
 *				w_do_open				      *
 *============================================================================*/
PRIVATE int w_do_open(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
/* Device open: Initialize the controller and read the partition table. */

  static int init_done = FALSE;

  if (!init_done) { w_init(); init_done = TRUE; }

  if (w_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);

  if (w_wn->wn_open_ct++ == 0) {
	/* Partition the disk. */
	partition(&w_dtab, w_drive * DEV_PER_DRIVE, P_PRIMARY);
  }
  return(OK);
}


/*============================================================================*
 *				w_do_close				      *
 *============================================================================*/
PRIVATE int w_do_close(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
/* Device close: Release a device. */

  if (w_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);
  w_wn->wn_open_ct--;
  return(OK);
}


/*==========================================================================*
 *				w_init					    *
 *==========================================================================*/
PRIVATE void w_init()
{
  /* Initialize the controller. */

  int drive;
  struct wini *wn;
#if AUTO_BIOS

  for (drive = 0; drive < nr_drives; drive++) {
	/* Get the drive parameters from sector zero of the drive if the
	 * autoconfig mode of the controller has been selected.
	 */
	if (w_switches & AUTO_ENABLE) {
		/* Set up some phony parameters so that we can read the
		 * first sector from the winchester.  All drives will have
		 * one cylinder and one head but set up initially to the
		 * mini scribe drives from IBM.
		 */
		wn = &wini[drive];
		wn->wn_cylinders = AUTO_CYLS;
		wn->wn_heads = AUTO_HEADS;
		wn->wn_reduced_wr = AUTO_RWC;
		wn->wn_precomp = AUTO_WPC;
		wn->wn_max_ecc = AUTO_ECC;
		wn->wn_ctlbyte = AUTO_CTRL;
		wn->wn_part[0].dv_size = cvu64(SECTOR_SIZE);
	}
  }

  /* Initialize controller to read parameters from the drives. */
  if (nr_drives > 0 && w_reset() != OK) nr_drives = 0;

  for (drive = 0; drive < nr_drives; drive++) {
	if (w_switches & AUTO_ENABLE) {
		/* read the first sector from the drive */
		w_dma_setup(DEV_GATHER, tmp_phys, SECTOR_SIZE);
		if (w_1rdwt(DEV_GATHER, 0, tmp_phys, SECTOR_SIZE) != OK) {
			printf("%s: can't read parameters\n", w_name());
			nr_drives = drive;
			break;
		}

		/* save the parameter tables for later use */
		copy_param(&tmp_buf[AUTO_PARAM], &wini[drive]);
	}
  }
#endif

  if (nr_drives > 0 && w_reset() != OK) nr_drives = 0;

  /* Set the size of each disk. */
  for (drive = 0; drive < nr_drives; drive++) {
	(void) w_prepare(drive * DEV_PER_DRIVE);
	wn = w_wn;
	wn->wn_part[0].dv_size = mul64u((unsigned long) wn->wn_cylinders *
				wn->wn_heads * NR_SECTORS, SECTOR_SIZE);
	printf("%s: %d cylinders, %d heads, %d sectors per track\n",
		w_name(), wn->wn_cylinders, wn->wn_heads, NR_SECTORS);
  }
}


/*==========================================================================*
 *				copy_param				    *
 *==========================================================================*/
PRIVATE void copy_param(src, dest)
char *src;
struct wini *dest;
{
/* This routine copies the parameters from src to dest.  */

  dest->wn_cylinders = bp_cylinders(src);
  dest->wn_heads = bp_heads(src);
  dest->wn_reduced_wr = bp_reduced_wr(src);
  dest->wn_precomp = bp_precomp(src);
  dest->wn_max_ecc = bp_max_ecc(src);
  dest->wn_ctlbyte = bp_ctlbyte(src);
}


/*============================================================================*
 *				w_geometry				      *
 *============================================================================*/
PRIVATE void w_geometry(entry)
struct partition *entry;
{
  entry->cylinders = w_wn->wn_cylinders;
  entry->heads = w_wn->wn_heads;
  entry->sectors = NR_SECTORS;
}
#endif /* ENABLE_XT_WINI */

/*     device dependent part of a hard disk driver for ibm ps/2 esdi adapter
 *
 *     written by doug burks, based on other minix wini drivers.
 *     some additions by art roberts
 *
 *     references:
 *        ibm personal system/2 hardware technical reference  (1988)
 *        ibm 60/120mb fixed disk drive technical reference  (1988)
 *
 *     caveats:
 *       * this driver has been reported to work on ibm ps/2 models 50 and
 *         70 with ibm's 60/120mb hard disks.
 *       * for a true esdi adapter, changes will have to be made, but this
 *         certainly serves as a good start.
 *       * no timeouts are implemented, so this driver could hang under
 *         adverse conditions.
 *       * the error processing has not been tested.  my disk works too well.
 *
 * The file contains one entry point:
 *
 *   esdi_winchester_task:	main entry when system is brought up
 *
 *
 * Changes:
 *	 3 May 1992 by Kees J. Bot: device dependent/independent split.
 *	27 May 2000 by Kees J. Bot: d-d/i rewrite.
 */
#include "kernel.h"
#include "driver.h"
#include "drvlib.h"

#if ENABLE_ESDI_WINI

/* If the DMA buffer is large enough then use it always. */
#define USE_BUF		(DMA_BUF_SIZE > BLOCK_SIZE)


/*****  esdi i/o adapter ports  */

#define  CMD_REG   0x3510	/* command interface register            */
#define  STAT_REG  0x3510	/* status interface register             */
#define  BCTL_REG  0x3512	/* basic control register                */
#define  BST_REG   0x3512	/* basic status register                 */
#define  ATT_REG   0x3513	/* attention register                    */
#define  INT_REG   0x3513	/* interrupt status register             */


/*****  basic status register bits  */

#define  DMA_ENA   0x80		/* DMA enabled?                          */
#define  INT_PND   0x40		/* interrupt pending?                    */
#define  CMD_PRG   0x20		/* command in progress?                  */
#define  BUSY      0x10		/* is adapter busy?                      */
#define  STR_FUL   0x08		/* status interface register set?        */
#define  CMD_FUL   0x04		/* command interface register full?      */
#define  XFR_REQ   0x02		/* data transfer operation ready?        */
#define  INT_SET   0x01		/* adapter sending interrupt?            */


/*****  attention register commands  */

#define  ATT_CMD   0x01		/* command request                       */
#define  ATT_EOI   0x02		/* end of interrupt processing           */
#define  ATT_ABT   0x03		/* abort the current command             */
#define  ATT_RST   0xE4		/* reset the esdi adapter                */


/*****  dma register addresses  */

#define  DMA_EXTCMD  0x18	/* extended function register            */
#define  DMA_EXEC    0x1A	/* extended function execute             */


/*****  miscellaneous  */

#define  ERR            (-1)	/* general error code                    */
#define  MAX_ERRORS     4	/* maximum number of read/write retries  */
#define  MAX_DRIVES     2	/* maximum number of physical drives     */
#define  NR_DEVICES     (MAX_DRIVES*DEV_PER_DRIVE)
				/* Maximum number of logical devices     */
#define  SUB_PER_DRIVE	(NR_PARTITIONS * NR_PARTITIONS)
#define  NR_SUBDEVS	(MAX_DRIVES * SUB_PER_DRIVE)

#define  SYS_PORTA      0x92	/* system control port a                 */
#define  LIGHT_ON       0xC0	/* fixed-disk activity light reg. mask   */


/*****  variables  */

PRIVATE struct wini {		/* disk/partition information            */
  unsigned open_ct;			/* in-use count			 */
  struct device part[DEV_PER_DRIVE];	/* disks and partitions		 */
  struct device subpart[SUB_PER_DRIVE];	/* subpartitions		 */            
} wini[MAX_DRIVES], *w_wn;

PRIVATE int win_tasknr;		/* my task number			 */
PRIVATE int nr_drives;		/* actual number of physical disk drive  */
PRIVATE int command[4];		/* controller command buffer             */
PRIVATE unsigned int status_block[9];	/* status block output from a command */
PRIVATE int dma_channel;	/* fixed disk dma channel number         */
PRIVATE int w_drive;		/* selected drive                        */
PRIVATE int w_istat;		/* interrupt status of last command      */
PRIVATE struct device *w_dv;	/* device's base and size                */


/*****  functions  */

FORWARD _PROTOTYPE( struct device *w_prepare, (int device) );
FORWARD _PROTOTYPE( char *w_name, (void) );
FORWARD _PROTOTYPE( int w_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int w_do_close, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void w_init, (void) );
FORWARD _PROTOTYPE( int w_command, (int device, int cmd, int num_words) );
FORWARD _PROTOTYPE( int w_transfer, (int proc_nr, int opcode, off_t position,
					iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( int w_1rdwt, (int opcode, unsigned long block,
					phys_bytes address, unsigned count) );
FORWARD _PROTOTYPE( int w_att_write, (int value) );
FORWARD _PROTOTYPE( void w_interrupt, (int dma) );
FORWARD _PROTOTYPE( int w_handler, (irq_hook_t *hook) );
FORWARD _PROTOTYPE( void w_dma_setup, (int opcode, phys_bytes address,
							unsigned count) );
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
 *				esdi_winchester_task			     *
 *===========================================================================*/
PUBLIC void esdi_winchester_task()
{
  win_tasknr = proc_number(proc_ptr);

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
	w_dv = &w_wn->part[device % DEV_PER_DRIVE];
  } else
  if ((unsigned) (device -= MINOR_d0p0s0) < NR_SUBDEVS) {/*d[0-7]p[0-3]s[0-3]*/
	w_drive = device / SUB_PER_DRIVE;
	w_wn = &wini[w_drive];
	w_dv = &w_wn->subpart[device % SUB_PER_DRIVE];
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
  static char name[] = "esdi-d0";

  name[6] = '0' + w_drive;
  return name;
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

  if (w_wn->open_ct++ == 0) {
	/* partition the disk */
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
  w_wn->open_ct--;
  return(OK);
}


/*============================================================================*
 *                              w_init                                        *
 *============================================================================*/
PRIVATE void w_init()
{
/*     initializes everything needed to run the hard disk
 *
 *     the following items are initialized:
 *       -- hard disk attributes stored in bios
 *       -- dma transfer channel, read from system register
 *       -- dma transfer and interrupts [disabled]
 *
 *     the hard disk adapter is initialized when the ibm ps/2 is turned on,
 *     using the programmable option select registers.  thus the only
 *     additional initialization is making sure the dma transfer and interrupts
 *     are disabled.  other initialization problems could be checked for, such
 *     as an operation underway.  the paranoid could add a check for adapter
 *     activity and abort the operations.  the truly paranoid can reset the
 *     adapter.  until such worries are proven, why bother?
 */
  unsigned int drive;		/* hard disk drive number                */
  unsigned long size;		/* hard disk size			 */
  static irq_hook_t hook;	/* interrupt hook			 */

  /* get the number of drives from the bios */
  phys_copy(0x475L, tmp_phys, 1L);
  nr_drives = tmp_buf[0];
  if (nr_drives > MAX_DRIVES) nr_drives = MAX_DRIVES;

  put_irq_handler(&hook, AT_WINI_IRQ, w_handler);
  enable_irq(&hook);		/* ready for winchester interrupts */

  for (drive = 0; drive < nr_drives; ++drive) {
	(void) w_prepare(drive * DEV_PER_DRIVE);
	if (w_command(drive, 0x0609, 6) != OK) {
		printf("%s: unable to get parameters\n", w_name());
		nr_drives = drive;
		break;
	}
	/* size of the drive */
	size =  ((unsigned long) status_block[2] <<  0) |
		((unsigned long) status_block[3] << 16);
	if (drive == 0) {
		if (w_command(7, 0x060A, 5) != OK) {
			printf("%s: unable to get dma channel\n", w_name());
			nr_drives = 0;
			return;
		}
		dma_channel = (status_block[2] & 0x3C00) >> 10;
	}
	printf("%s: %lu sectors\n", w_name(), size);
	w_wn->part[0].dv_size = mul64u(size, SECTOR_SIZE);
  }
}


/*===========================================================================*
 *                          w_command                                        *
 *===========================================================================*/
PRIVATE int w_command(device, cmd, num_words)
int device;			/* i device to operate on                */
				/*   1-2   physical disk drive number    */
				/*   7     hard disk controller          */
int cmd;			/* i command to execute                  */
int num_words;			/* i expected size of status block       */
{
/*     executes a command for a particular device
 *
 *     the operation is conducted as follows:
 *       -- create the command block
 *       -- initialize for command reading by the controller
 *       -- write the command block to the controller, making sure the
 *          controller has digested the previous command word, before shoving
 *          the next down its throat
 *       -- wait for an interrupt
 *       -- read expected number of words of command status information
 *       -- return the command status block
 *
 *     reading and writing registers is accompanied by enabling and disabling
 *     interrupts to ensure that the status register contents still apply when
 *     the desired register is read/written.
 */
  register int ki;		/* -- scratch --                         */
  int status;			/* disk adapter status register value    */

  device <<= 5;			/* adjust device for our use             */
  command[0] = cmd | device;	/* build command block                   */
  command[1] = 0;

  w_att_write(device | ATT_CMD);

  for (ki = 0; ki < 2; ++ki) {
	outw(CMD_REG, command[ki]);
	unlock();
	while (TRUE) {
		lock();
		status = inb(BST_REG);
		if (!(status & CMD_FUL)) break;
		unlock();
	}
  }
  unlock();

  w_interrupt(0);
  if (w_istat != (device | 0x01)) {
	w_att_write(device | ATT_ABT);
	w_interrupt(0);
	return(ERR);
  }
  for (ki = 0; ki < num_words; ++ki) {
	while (TRUE) {
		lock();
		status = inb(BST_REG);
		if (status & STR_FUL) break;
		unlock();
	}
	status_block[ki] = inw(STAT_REG);
	unlock();
  }
  w_att_write(device | ATT_EOI);

  return(OK);
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
  phys_bytes dma_phys;
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
		/* How many bytes can be found on consecutive chunks? */
		dma_phys = user_base + iov[0].iov_addr;
		count = 0;
		for (iop = iov; count < nbytes; iop++) {
			if (iop->iov_addr != iov[0].iov_addr + count) break;
			count += iop->iov_size;
		}
		if (count < nbytes) nbytes = count;
	} else {
		dma_phys = tmp_phys;
		if (opcode == DEV_SCATTER) {
			/* Copy from user space to the DMA buffer. */
			count = 0;
			for (iop = iov; count < nbytes; iop++) {
				chunk = iov->iov_size;
				if (count + chunk > nbytes)
					chunk = nbytes - count;
				phys_copy(user_base + iop->iov_addr,
						dma_phys + count,
						(phys_bytes) chunk);
				count += chunk;
			}
		}
	}

	/* Turn on the disk activity light. */
	outb(SYS_PORTA, inb(SYS_PORTA) | LIGHT_ON);

	/* Perform the transfer. */
	r = w_1rdwt(opcode, block, dma_phys, nbytes);

	/* Turn off the disk activity light. */
	outb(SYS_PORTA, inb(SYS_PORTA) & ~LIGHT_ON);

	if (r != OK) {
		/* An error occurred, try again sector by sector unless */
		if (++errors == MAX_ERRORS) return(EIO);
		continue;
	}

	if (USE_BUF && opcode == DEV_GATHER) {
		/* Copy from the DMA buffer to user space. */
		count = 0;
		for (iop = iov; count < nbytes; iop++) {
			chunk = iov->iov_size;
			if (count + chunk > nbytes)
				chunk = nbytes - count;
			phys_copy(dma_phys + count,
					user_base + iop->iov_addr,
					(phys_bytes) chunk);
			count += chunk;
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


/*===========================================================================*
 *				w_1rdwt					     *
 *===========================================================================*/
PRIVATE int w_1rdwt(opcode, block, address, count)
int opcode;			/* DEV_GATHER or DEV_SCATTER */
unsigned long block;		/* block on disk */
phys_bytes address;		/* address in memory */
unsigned int count;		/* bytes to transfer */
{
/*     reads/writes a single block of data from/to the hard disk
 *
 *     the read/write operation performs the following steps:
 *       -- create the command block
 *       -- initialize the command reading by the controller
 *       -- write the command block to the controller, making sure the
 *            controller has digested the previous command word, before
 *            shoving the next down its throat.
 *       -- wait for an interrupt, which must return a 'data transfer ready'
 *            status.  abort the command if it doesn't.
 *       -- set up and start up the direct memory transfer
 *       -- wait for an interrupt, signalling the end of the transfer
 */
  int device;			/* device mask for the command register  */
  int ki;			/* -- scratch --                         */
  int status;			/* basic status register value           */

  device = w_drive << 5;
  command[0] = (opcode == DEV_SCATTER ? 0x4602 : 0x4601) | device;
  command[1] = count >> SECTOR_SHIFT;
  command[2] = (int) (block & 0xFFFF);
  command[3] = (int) (block >> 16);

  w_att_write(device | ATT_CMD);

  for (ki = 0; ki < 4; ++ki) {
	outw(CMD_REG, command[ki]);
	unlock();
	while (TRUE) {
		lock();
		status = inb(BST_REG);
		if (!(status & CMD_FUL)) break;
		unlock();
	}
  }
  unlock();

  w_interrupt(0);
  if (w_istat != (device | 0x0B)) {
	w_att_write(device | ATT_ABT);
	w_interrupt(0);
	return(ERR);
  }
  w_dma_setup(opcode, address, count);

  w_interrupt(1);

  w_att_write(device | ATT_EOI);

  if ((w_istat & 0x0F) > 8) return(ERR);
  return(OK);
}



/*==========================================================================*
 *                            w_att_write                                   *
 *==========================================================================*/
PRIVATE int w_att_write(value)
register int value;
{
/*     writes a command to the esdi attention register
 *
 *     waits for the controller to finish its business before sending the
 *     command to the controller.  note that the interrupts must be off to read
 *     the basic status register and, if the controller is ready, must not be
 *     turned back on until the attention register command is sent.
 */
  int status;			/* basic status register value           */

  while (TRUE) {
	lock();
	status = inb(BST_REG);
	if (!(status & (INT_PND | BUSY))) break;
	unlock();
  }
  outb(ATT_REG, value);
  unlock();

  return(OK);
}



/*===========================================================================*
 *                          w_interrupt                                      *
 *===========================================================================*/
PRIVATE void w_interrupt(dma)
int dma;			/* i dma transfer is underway            */
{
/*     waits for an interrupt from the hard disk controller
 *
 *     enable interrupts on the hard disk and interrupt controllers (and dma if
 *     necessary).  wait for an interrupt.  when received, return the interrupt
 *     status register value.
 *
 *     an interrupt can be detected either from the basic status register or
 *     through a system interrupt handler.  the handler is used for all
 *     interrupts, due to the expected long times to process reads and writes
 *     and to avoid busy waits.
 */
  message dummy;		/* -- scratch --                         */

  outb(BCTL_REG, dma ? 0x03 : 0x01);

  receive(HARDWARE, &dummy);

  outb(BCTL_REG, 0);
  if (dma) outb(DMA_EXTCMD, 0x90 + dma_channel);
}



/*==========================================================================*
 *				w_handler				    *
 *==========================================================================*/
PRIVATE int w_handler(hook)
irq_hook_t *hook;
{
/* Disk interrupt, send message to winchester task and reenable interrupts. */

  w_istat = inb(INT_REG);
  interrupt(win_tasknr);
  return 1;
}



/*==========================================================================*
 *			w_dma_setup					    *
 *==========================================================================*/
PRIVATE void w_dma_setup(opcode, address, count)
int opcode;
phys_bytes address;
unsigned int count;
{
/*     programs the dma controller to move data to and from the hard disk.
 *
 *     uses the extended mode operation of the ibm ps/2 interrupt controller
 *     chip, rather than the intel 8237 (pc/at) compatible mode.
 */

  lock();
  outb(DMA_EXTCMD, 0x90 + dma_channel);
  /* Disable access to dma channel 5     */
  outb(DMA_EXTCMD, 0x20 + dma_channel);
  /* Clear the address byte pointer      */
  outb(DMA_EXEC, (int)  address >>  0);		/* address bits 0..7   */
  outb(DMA_EXEC, (int)  address >>  8);		/* address bits 8..15  */
  outb(DMA_EXEC, (int) (address >> 16));	/* address bits 16..19 */
  outb(DMA_EXTCMD, 0x40 + dma_channel);
  /* Clear the count byte pointer        */
  outb(DMA_EXEC, (count - 1) >> 0);		/* count bits 0..7     */
  outb(DMA_EXEC, (count - 1) >> 8);		/* count bits 8..15    */
  outb(DMA_EXTCMD, 0x70 + dma_channel);
  /* Set the transfer mode               */
  outb(DMA_EXEC, opcode == DEV_SCATTER ? 0x44 : 0x4C);
  outb(DMA_EXTCMD, 0xA0 + dma_channel);
  /* Enable access to dma channel 5      */
  unlock();
}


/*============================================================================*
 *				w_geometry				      *
 *============================================================================*/
PRIVATE void w_geometry(entry)
struct partition *entry;
{
  entry->cylinders = div64u(w_wn->part[0].dv_size, SECTOR_SIZE) / (64 * 32);
  entry->heads = 64;
  entry->sectors = 32;
}
#endif /* ENABLE_ESDI_WINI */

/*
 * $PchId: esdi_wini.c,v 1.9 1999/01/13 21:35:40 philip Exp $
 */

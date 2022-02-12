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
#define  ERR_BAD_SECTOR (-2)	/* block marked bad detected             */
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
  struct device part[DEV_PER_DRIVE];	/* primary partitions: hd[0-4]   */
  struct device subpart[SUB_PER_DRIVE];	/* subpartitions: hd[1-4][a-d] */
} wini[MAX_DRIVES], *w_wn;

PRIVATE struct trans {
  struct iorequest_s *iop;	/* belongs to this I/O request           */
  unsigned long block;		/* first sector to transfer              */
  unsigned count;		/* byte count                            */
  phys_bytes phys;		/* user physical address                 */
  phys_bytes dma;		/* DMA physical address                  */
} wtrans[NR_IOREQS];

PRIVATE int win_tasknr;		/* my task number			 */
PRIVATE int nr_drives;		/* actual number of physical disk drive  */
PRIVATE int command[4];		/* controller command buffer             */
PRIVATE unsigned int status_block[9];	/* status block output from a command */
PRIVATE int dma_channel;	/* fixed disk dma channel number         */
PRIVATE struct trans *w_tp;	/* to add transfer requests              */
PRIVATE unsigned w_count;	/* number of bytes to transfer           */
PRIVATE unsigned long w_nextblock;	/* next block on disk to transfer */
PRIVATE int w_opcode;		/* DEV_READ or DEV_WRITE                 */
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
FORWARD _PROTOTYPE( int w_schedule, (int proc_nr, struct iorequest_s *iop) );
FORWARD _PROTOTYPE( int w_finish, (void) );
FORWARD _PROTOTYPE( int w_transfer, (struct trans *tp, unsigned count) );
FORWARD _PROTOTYPE( int w_att_write, (int value) );
FORWARD _PROTOTYPE( void w_interrupt, (int dma) );
FORWARD _PROTOTYPE( int w_handler, (int irq) );
FORWARD _PROTOTYPE( void w_dma_setup, (struct trans *tp, unsigned count) );
FORWARD _PROTOTYPE( void w_geometry, (struct partition *entry));


/* Entry points to this driver. */
PRIVATE struct driver w_dtab = {
  w_name,	/* current device's name */
  w_do_open,	/* open or mount request, initialize device */
  w_do_close,	/* release device */
  do_diocntl,	/* get or set a partition's geometry */
  w_prepare,	/* prepare for I/O on a given minor device */
  w_schedule,	/* precompute cylinder, head, sector, etc. */
  w_finish,	/* do the I/O */
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

  /* Nothing to transfer as yet. */
  w_count = 0;

  if (device < NR_DEVICES) {			/* hd0, hd1, ... */
	w_drive = device / DEV_PER_DRIVE;	/* save drive number */
	w_wn = &wini[w_drive];
	w_dv = &w_wn->part[device % DEV_PER_DRIVE];
  } else
  if ((unsigned) (device -= MINOR_hd1a) < NR_SUBDEVS) {	/* hd1a, hd1b, ... */
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
  static char name[] = "esdi-hd5";

  name[7] = '0' + w_drive * DEV_PER_DRIVE;
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

  /* get the number of drives from the bios */
  phys_copy(0x475L, tmp_phys, 1L);
  nr_drives = tmp_buf[0];
  if (nr_drives > MAX_DRIVES) nr_drives = MAX_DRIVES;

  put_irq_handler(AT_WINI_IRQ, w_handler);
  enable_irq(AT_WINI_IRQ);	/* ready for winchester interrupts */

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
	w_wn->part[0].dv_size = size << SECTOR_SHIFT;
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
	out_word(CMD_REG, command[ki]);
	unlock();
	while (TRUE) {
		lock();
		status = in_byte(BST_REG);
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
		status = in_byte(BST_REG);
		if (status & STR_FUL) break;
		unlock();
	}
	status_block[ki] = in_word(STAT_REG);
	unlock();
  }
  w_att_write(device | ATT_EOI);

  return(OK);
}


/*===========================================================================*
 *				w_schedule				     *
 *===========================================================================*/
PRIVATE int w_schedule(proc_nr, iop)
int proc_nr;			/* process doing the request */
struct iorequest_s *iop;	/* pointer to read or write request */
{
/* Gather I/O requests on consecutive blocks so they may be read/written
 * in one command if using a buffer.  Check and gather all the requests
 * and try to finish them as fast as possible if unbuffered.
 */
  int r, opcode;
  unsigned long pos;
  unsigned nbytes, count;
  unsigned long block;
  phys_bytes user_phys, dma_phys;

  /* This many bytes to read/write */
  nbytes = iop->io_nbytes;
  if ((nbytes & SECTOR_MASK) != 0) return(iop->io_nbytes = EINVAL);

  /* From/to this position on the device */
  pos = iop->io_position;
  if ((pos & SECTOR_MASK) != 0) return(iop->io_nbytes = EINVAL);

  /* To/from this user address */
  user_phys = numap(proc_nr, (vir_bytes) iop->io_buf, nbytes);
  if (user_phys == 0) return(iop->io_nbytes = EINVAL);

  /* Read or write? */
  opcode = iop->io_request & ~OPTIONAL_IO;

  /* Which block on disk and how close to EOF? */
  if (pos >= w_dv->dv_size) return(OK);		/* At EOF */
  if (pos + nbytes > w_dv->dv_size) nbytes = w_dv->dv_size - pos;
  block = (w_dv->dv_base + pos) >> SECTOR_SHIFT;

  if (USE_BUF && w_count > 0 && block != w_nextblock) {
	/* This new request can't be chained to the job being built */
	if ((r = w_finish()) != OK) return(r);
  }

  /* The next consecutive block */
  if (USE_BUF) w_nextblock = block + (nbytes >> SECTOR_SHIFT);

  /* While there are "unscheduled" bytes in the request: */
  do {
	count = nbytes;

	if (USE_BUF) {
		if (w_count == DMA_BUF_SIZE) {
			/* Can't transfer more than the buffer allows. */
			if ((r = w_finish()) != OK) return(r);
		}

		if (w_count + count > DMA_BUF_SIZE)
			count = DMA_BUF_SIZE - w_count;
	} else {
		if (w_tp == wtrans + NR_IOREQS) {
			/* All transfer slots in use. */
			if ((r = w_finish()) != OK) return(r);
		}
	}

	if (w_count == 0) {
		/* The first request in a row, initialize. */
		w_opcode = opcode;
		w_tp = wtrans;
	}

	if (USE_BUF) {
		dma_phys = tmp_phys + w_count;
	} else {
		/* Note: No 64K boundary problem, the better PS/2's have a
		 * working DMA chip.
		 */
		dma_phys = user_phys;
	}

	/* Store I/O parameters */
	w_tp->iop = iop;
	w_tp->block = block;
	w_tp->count = count;
	w_tp->phys = user_phys;
	w_tp->dma = dma_phys;

	/* Update counters */
	w_tp++;
	w_count += count;
	block += count >> SECTOR_SHIFT;
	user_phys += count;
	nbytes -= count;
  } while (nbytes > 0);

  return(OK);
}


/*===========================================================================*
 *				w_finish				     *
 *===========================================================================*/
PRIVATE int w_finish()
{
/*     carries out the I/O requests gathered in wtrans[]
 *
 *     fills the disk information structure for one block at a time or many
 *     in a row before calling 'w_transfer' to do the dirty work.  while
 *     unsuccessful operations are re-tried, this may be superfluous, since
 *     the controller does the same on its own.  turns on the fixed disk
 *     activity light, while busy.  computers need blinking lights, right?
 */

  struct trans *tp = wtrans, *tp2;
  unsigned count;
  int r, errors = 0, many = USE_BUF;

  if (w_count == 0) return(OK);	/* Spurious finish. */

  do {
	if (w_opcode == DEV_WRITE) {
		tp2 = tp;
		count = 0;
		do {
			if (USE_BUF || tp2->dma == tmp_phys) {
				phys_copy(tp2->phys, tp2->dma,
						(phys_bytes) tp2->count);
			}
			count += tp2->count;
			tp2++;
		} while (many && count < w_count);
	} else {
		count = many ? w_count : tp->count;
	}

	/* Turn on the disk activity light. */
	out_byte(SYS_PORTA, in_byte(SYS_PORTA) | LIGHT_ON);

	/* Perform the transfer. */
	r = w_transfer(tp, count);

	/* Turn off the disk activity light. */
	out_byte(SYS_PORTA, in_byte(SYS_PORTA) & ~LIGHT_ON);

	if (r != OK) {
		/* An error occurred, try again block by block unless */
		if (r == ERR_BAD_SECTOR || ++errors == MAX_ERRORS)
			return(tp->iop->io_nbytes = EIO);

		many = 0;
		continue;
	}
	errors = 0;

	w_count -= count;

	do {
		if (w_opcode == DEV_READ) {
			if (USE_BUF || tp->dma == tmp_phys) {
				phys_copy(tp->dma, tp->phys,
						(phys_bytes) tp->count);
			}
		}
		tp->iop->io_nbytes -= tp->count;
		count -= tp->count;
		tp++;
	} while (count > 0);
  } while (w_count > 0);

  return(OK);
}


/*===========================================================================*
 *				w_transfer				     *
 *===========================================================================*/
PRIVATE int w_transfer(tp, count)
struct trans *tp;		/* pointer to the transfer struct */
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
  command[0] = (w_opcode == DEV_WRITE ? 0x4602 : 0x4601) | device;
  command[1] = count >> SECTOR_SHIFT;
  command[2] = (int) (tp->block & 0xFFFF);
  command[3] = (int) (tp->block >> 16);

  w_att_write(device | ATT_CMD);

  for (ki = 0; ki < 4; ++ki) {
	out_word(CMD_REG, command[ki]);
	unlock();
	while (TRUE) {
		lock();
		status = in_byte(BST_REG);
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
  w_dma_setup(tp, count);

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
	status = in_byte(BST_REG);
	if (!(status & (INT_PND | BUSY))) break;
	unlock();
  }
  out_byte(ATT_REG, value);
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

  out_byte(BCTL_REG, dma ? 0x03 : 0x01);

  receive(HARDWARE, &dummy);

  out_byte(BCTL_REG, 0);
  if (dma) out_byte(DMA_EXTCMD, 0x90 + dma_channel);
}



/*==========================================================================*
 *				w_handler				    *
 *==========================================================================*/
PRIVATE int w_handler(irq)
int irq;
{
/* Disk interrupt, send message to winchester task and reenable interrupts. */

  w_istat = in_byte(INT_REG);
  interrupt(win_tasknr);
  return 1;
}



/*==========================================================================*
 *			w_dma_setup					    *
 *==========================================================================*/
PRIVATE void w_dma_setup(tp, count)
struct trans *tp;
unsigned int count;
{
/*     programs the dma controller to move data to and from the hard disk.
 *
 *     uses the extended mode operation of the ibm ps/2 interrupt controller
 *     chip, rather than the intel 8237 (pc/at) compatible mode.
 */

  lock();
  out_byte(DMA_EXTCMD, 0x90 + dma_channel);
  /* Disable access to dma channel 5     */
  out_byte(DMA_EXTCMD, 0x20 + dma_channel);
  /* Clear the address byte pointer      */
  out_byte(DMA_EXEC, (int)  tp->dma >>  0);	/* address bits 0..7   */
  out_byte(DMA_EXEC, (int)  tp->dma >>  8);	/* address bits 8..15  */
  out_byte(DMA_EXEC, (int) (tp->dma >> 16));	/* address bits 16..19 */
  out_byte(DMA_EXTCMD, 0x40 + dma_channel);
  /* Clear the count byte pointer        */
  out_byte(DMA_EXEC, (count - 1) >> 0);		/* count bits 0..7     */
  out_byte(DMA_EXEC, (count - 1) >> 8);		/* count bits 8..15    */
  out_byte(DMA_EXTCMD, 0x70 + dma_channel);
  /* Set the transfer mode               */
  out_byte(DMA_EXEC, w_opcode == DEV_WRITE ? 0x44 : 0x4C);
  out_byte(DMA_EXTCMD, 0xA0 + dma_channel);
  /* Enable access to dma channel 5      */
  unlock();
}


/*============================================================================*
 *				w_geometry				      *
 *============================================================================*/
PRIVATE void w_geometry(entry)
struct partition *entry;
{
  entry->cylinders = (w_wn->part[0].dv_size >> SECTOR_SHIFT) / (64 * 32);
  entry->heads = 64;
  entry->sectors = 32;
}
#endif /* ENABLE_ESDI_WINI */

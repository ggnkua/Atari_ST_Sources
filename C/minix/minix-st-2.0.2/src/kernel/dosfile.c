/* This file contains the "DOS file as disk" driver.	Author: Kees J. Bot
 * It uses MS-DOS calls to read or write a large DOS		4 May 1998
 * file that is used as a Minix disk.  Minix will have to
 * be started under DOS for this to work, of course.
 *
 * The file contains two entry points:
 *
 *	 dosfile_task:	main entry when system is brought up
 *	 dosfile_stop:	called on halt or reboot to close DOS files
 */

#include "kernel.h"
#include "driver.h"
#include "drvlib.h"

#if ENABLE_DOSFILE

/* If the DMA buffer is large enough then use it always. */
#define USE_BUF		(DMA_BUF_SIZE > BLOCK_SIZE)

/* Limit byte count to something DOS will find reasonable. */
#define MAX_COUNT	MIN(DMA_BUF_SIZE, 16384)

/* Parameters for the disk drive. */
#define MAX_DRIVES         4	/* this driver supports this many "drives" */
#define NR_DEVICES      (MAX_DRIVES * DEV_PER_DRIVE)

/* Variables. */
PRIVATE struct drive {		/* main drive struct, one entry per drive */
  unsigned long curpos;		/* current position within the "disk" */
  unsigned clustersize;		/* cluster size of the drive the file is on */
  unsigned open_ct;		/* in-use count */
  int dfd;			/* DOS file descriptor if open_ct > 0 */
  char rw;			/* opened read-write? */
  struct device part[DEV_PER_DRIVE];    /* primary partitions: dosd[0-4] */
} drive[MAX_DRIVES], *d_dr;

PRIVATE struct trans {
  struct iorequest_s *iop;	/* belongs to this I/O request */
  unsigned long pos;		/* first byte to transfer */
  unsigned count;		/* byte count */
  phys_bytes phys;		/* user physical address */
  phys_bytes buf;		/* buffer physical address */
} dtrans[NR_IOREQS];

PRIVATE struct trans *d_tp;		/* to add transfer requests */
PRIVATE unsigned d_count;		/* number of bytes to transfer */
PRIVATE unsigned long d_nextpos;	/* next block on disk to transfer */
PRIVATE int d_opcode;			/* DEV_READ or DEV_WRITE */
PRIVATE int d_drive;			/* selected drive */
PRIVATE struct device *d_dv;		/* device's base and size */

FORWARD _PROTOTYPE( struct device *d_prepare, (int device) );
FORWARD _PROTOTYPE( char *d_name, (void) );
FORWARD _PROTOTYPE( int d_schedule, (int proc_nr, struct iorequest_s *iop) );
FORWARD _PROTOTYPE( int d_finish, (void) );
FORWARD _PROTOTYPE( int d_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int d_do_close, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void dosclose, (int handle) );
FORWARD _PROTOTYPE( char *doserror, (int err) );
FORWARD _PROTOTYPE( void d_geometry, (struct partition *entry));


/* Entry points to this driver. */
PRIVATE struct driver d_dtab = {
  d_name,	/* current device's name */
  d_do_open,	/* open or mount request, initialize device */
  d_do_close,	/* release device */
  do_diocntl,	/* get or set a partition's geometry */
  d_prepare,	/* prepare for I/O on a given minor device */
  d_schedule,	/* precompute cylinder, head, sector, etc. */
  d_finish,	/* do the I/O */
  nop_cleanup,	/* no cleanup needed */
  d_geometry	/* tell the geometry of the disk */
};


/*===========================================================================*
 *				dosfile_task				     *
 *===========================================================================*/
PUBLIC void dosfile_task()
{
  driver_task(&d_dtab);
}


/*===========================================================================*
 *				d_prepare				     *
 *===========================================================================*/
PRIVATE struct device *d_prepare(device)
int device;
{
/* Prepare for I/O on a device. */

  /* Nothing to transfer as yet. */
  d_count = 0;

  if (device < NR_DEVICES) {			/* dosd0, dosd1, ... */
	d_drive = device / DEV_PER_DRIVE;	/* save drive number */
	d_dr = &drive[d_drive];
	d_dv = &d_dr->part[device % DEV_PER_DRIVE];
  } else {
	return(NIL_DEV);
  }
  return(d_drive < MAX_DRIVES ? d_dv : NIL_DEV);
}


/*===========================================================================*
 *				d_name					     *
 *===========================================================================*/
PRIVATE char *d_name()
{
/* Return a name for the current device. */
  static char name[] = "dosd15";
  unsigned device = d_drive * DEV_PER_DRIVE;

  if (device < 10) {
	name[4] = '0' + device;
	name[5] = 0;
  } else {
	name[4] = '0' + device / 10;
	name[5] = '0' + device % 10;
  }
  return name;
}


/*===========================================================================*
 *				d_schedule				     *
 *===========================================================================*/
PRIVATE int d_schedule(proc_nr, iop)
int proc_nr;			/* process doing the request */
struct iorequest_s *iop;	/* pointer to read or write request */
{
/* Gather I/O requests on consecutive blocks so they may be read/written
 * in one DOS read/write command if using a buffer.  Check and gather all the
 * requests and try to finish them as fast as possible if unbuffered.
 */
  int r, opcode;
  unsigned long pos;
  unsigned nbytes, count;
  phys_bytes user_phys, buf_phys;

  /* This many bytes to read/write */
  nbytes = iop->io_nbytes;

  /* From/to this position on the device */
  pos = iop->io_position;

  /* To/from this user address */
  user_phys = numap(proc_nr, (vir_bytes) iop->io_buf, nbytes);
  if (user_phys == 0) return(iop->io_nbytes = EINVAL);

  /* Read or write? */
  opcode = iop->io_request & ~OPTIONAL_IO;

  /* Which block on disk and how close to EOF? */
  if (pos >= d_dv->dv_size) return(OK);		/* At EOF */
  if (pos + nbytes > d_dv->dv_size) nbytes = d_dv->dv_size - pos;
  pos = d_dv->dv_base + pos;

  if (USE_BUF && d_count > 0 && pos != d_nextpos) {
	/* This new request can't be chained to the job being built */
	if ((r = d_finish()) != OK) return(r);
  }

  /* The next consecutive byte */
  if (USE_BUF) d_nextpos = pos + nbytes;

  /* While there are "unscheduled" bytes in the request: */
  do {
	count = nbytes;

	if (USE_BUF) {
		if (d_count == MAX_COUNT) {
			/* Can't transfer more than the buffer allows. */
			if ((r = d_finish()) != OK) return(r);
		}

		if (d_count + count > MAX_COUNT)
			count = MAX_COUNT - d_count;
	} else {
		if (d_tp == dtrans + NR_IOREQS) {
			/* All transfer slots in use. */
			if ((r = d_finish()) != OK) return(r);
		}
	}

	if (d_count == 0) {
		/* The first request in a row, initialize. */
		d_opcode = opcode;
		d_tp = dtrans;
	}

	if (USE_BUF) {
		buf_phys = tmp_phys + d_count;
	} else {
		/* Memory chunk to copy. */
		buf_phys = user_phys;

		if (buf_phys >= (1L << 20)) {
			/* DOS can only address the first megabyte. */
			if (count > DMA_BUF_SIZE) count = DMA_BUF_SIZE;
			buf_phys = tmp_phys;
		}
	}

	/* Store I/O parameters */
	d_tp->iop = iop;
	d_tp->pos = pos;
	d_tp->count = count;
	d_tp->phys = user_phys;
	d_tp->buf = buf_phys;

	/* Update counters */
	d_tp++;
	d_count += count;
	pos += count;
	user_phys += count;
	nbytes -= count;
  } while (nbytes > 0);

  return(OK);
}


/*===========================================================================*
 *				d_finish				     *
 *===========================================================================*/
PRIVATE int d_finish()
{
/* Carry out the I/O requests gathered in dtrans[]. */

  struct trans *tp = dtrans, *tp2;
  unsigned count;

  if (d_count == 0) return(OK);	/* Spurious finish. */

  do {
	if (d_opcode == DEV_WRITE) {
		tp2 = tp;
		count = 0;
		do {
			if (USE_BUF || tp2->buf == tmp_phys) {
				phys_copy(tp2->phys, tp2->buf,
						(phys_bytes) tp2->count);
			}
			count += tp2->count;
			tp2++;
		} while (USE_BUF && count < d_count);
	} else {
		count = USE_BUF ? d_count : tp->count;
	}

	/* Need to seek to a new position? */
	if (tp->pos != d_dr->curpos) {
		reg86.b.intno = 0x21;
		reg86.w.ax = 0x4200;	/* LSEEK absolute */
		reg86.w.bx = d_dr->dfd;
		reg86.w.dx = tp->pos & 0xFFFF;
		reg86.w.cx = tp->pos >> 16;
		level0(int86);
		if (reg86.w.f & 0x0001) {	/* Seek failed */
			printf("%s: seek to %lu failed: %s\n",
				d_name(), tp->pos, doserror(reg86.w.ax));
			d_dr->curpos = -1;
			return(tp->iop->io_nbytes = EIO);
		}
		d_dr->curpos = tp->pos;
	}

	/* Do the transfer using a DOS read or write call */
	reg86.b.intno = 0x21;
	reg86.b.ah = d_opcode == DEV_WRITE ? 0x40 : 0x3F;
	reg86.w.bx = d_dr->dfd;
	reg86.w.cx = count;
	reg86.w.dx = tp->buf % HCLICK_SIZE;
	reg86.w.ds = tp->buf / HCLICK_SIZE;
	level0(int86);
	if ((reg86.w.f & 0x0001) || reg86.w.ax != count) {
		/* Read or write error or unexpected EOF */
		d_dr->curpos = -1;
		return(tp->iop->io_nbytes = EIO);
	}

	d_dr->curpos += count;
	d_count -= count;

	do {
		if (d_opcode == DEV_READ) {
			if (USE_BUF || tp->buf == tmp_phys) {
				phys_copy(tp->buf, tp->phys,
						(phys_bytes) tp->count);
			}
		}
		tp->iop->io_nbytes -= tp->count;
		count -= tp->count;
		tp++;
	} while (count > 0);
  } while (d_count > 0);

  return(OK);
}


/*============================================================================*
 *				d_do_open				      *
 *============================================================================*/
PRIVATE int d_do_open(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
/* Device open: Open the DOS file and read the partition table. */
  char *file;
  struct drive *dr;

  if (d_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);
  dr = d_dr;

  if (dr->open_ct == 0) {
	if ((file = k_getenv(d_name())) == NULL) {
		printf("%s: boot environent variable '%s' not set\n",
			d_name(), d_name());
		return(EIO);
	}

	/* Check if DOS 3.0 or better present. */
	reg86.b.intno = 0x21;
	reg86.w.ax = 0x3000;	/* GET DOS VERSION */
	level0(int86);
	if (reg86.b.al < 3) {
		printf("%s: No DOS 3.0+ running\n", d_name());
		return(EIO);
	}

	/* Open the DOS file. */
	dr->rw = 1;
	reg86.b.intno = 0x21;
	reg86.w.ax = 0x3D22;	/* OPEN read-write & deny write */
	reg86.w.dx = vir2phys(file) % HCLICK_SIZE;
	reg86.w.ds = vir2phys(file) / HCLICK_SIZE;
	level0(int86);
	if ((reg86.w.f & 0x0001) && reg86.w.ax == 5) {
		/* Open failed (access denied), try read-only */
		dr->rw = 0;
		reg86.b.intno = 0x21;
		reg86.w.ax = 0x3D40;	/* OPEN read-only */
		reg86.w.dx = vir2phys(file) % HCLICK_SIZE;
		reg86.w.ds = vir2phys(file) / HCLICK_SIZE;
		level0(int86);
	}
	if (reg86.w.f & 0x0001) {
		printf("%s: can't open '%s': %s\n",
			d_name(), file, doserror(reg86.w.ax));
		return(EIO);
	}
	dr->dfd = reg86.w.ax;		/* File handle */

	reg86.b.intno = 0x21;
	reg86.w.ax = 0x4202;	/* LSEEK to end */
	reg86.w.bx = dr->dfd;
	reg86.w.dx = 0;
	reg86.w.cx = 0;
	level0(int86);
	if (reg86.w.f & 0x0001) {	/* Seek failed */
		printf("%s: can't determine size of '%s': %s\n",
			d_name(), file, doserror(reg86.w.ax));
		dosclose(dr->dfd);
		return(EIO);
	}
	dr->curpos = ((u32_t) reg86.w.dx << 16) | reg86.w.ax;
	if (dr->part[0].dv_size != dr->curpos) {
		printf("%s: using '%s', %lu bytes%s\n",
			d_name(), file, dr->curpos,
			dr->rw ? "" : " (read-only)");
		dr->part[0].dv_size = dr->curpos;
	}

	reg86.b.intno = 0x21;
	reg86.b.ah = 0x1C;	/* GET ALLOCATION INFO */
	reg86.b.dl = 0x00;	/* default drive or ... */
	if ((unsigned) ((file[0] & 0xDF) - 'A') < 26 && file[1] == ':') {
		reg86.b.dl = (file[0] & 0xDF) - '@';	/* ... this drive */
	}
	level0(int86);
	if (reg86.b.al == 0 || reg86.b.al > 63 ||
			(file[0] == '/' && file[1] == '/')) {
		/* Weird return value or a network path, 32 will do. */
		reg86.b.al = 32;
	}
	dr->clustersize = reg86.b.al << SECTOR_SHIFT;

	/* Read-only "disk" to be opened for writing? */
	if (!dr->rw && (m_ptr->COUNT & W_BIT)) {
		/* Oops, back out... */
		dosclose(dr->dfd);
		return(EACCES);
	}

	/* Partition the "disk". */
	partition(&d_dtab, d_drive * DEV_PER_DRIVE, P_PRIMARY);
  }
  dr->open_ct++;
  return(OK);
}


/*============================================================================*
 *				d_do_close				      *
 *============================================================================*/
PRIVATE int d_do_close(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
/* Device close: Release a device. */

  if (d_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);
  if (--d_dr->open_ct == 0) dosclose(d_dr->dfd);
  return(OK);
}


/*============================================================================*
 *				dosfile_stop				      *
 *============================================================================*/
PUBLIC void dosfile_stop()
{
/* Prepare for halt or reboot, i.e. make sure all is closed. */

  struct drive *dr;

  for (dr = drive; dr < drive + MAX_DRIVES; dr++) {
	if (dr->open_ct > 0) dosclose(dr->dfd);
  }
}


/*============================================================================*
 *				dosclose				      *
 *============================================================================*/
PRIVATE void dosclose(handle)
int handle;				/* file handle */
{
/* Close a DOS file. */
  reg86.b.intno = 0x21;
  reg86.b.ah = 0x3E;	/* CLOSE */
  reg86.w.bx = handle;
  level0(int86);
}


/*============================================================================*
 *				doserror				      *
 *============================================================================*/
PRIVATE char *doserror(err)
int err;
{
/* Translate some DOS error codes to text. */
  static struct errlist {
	int	err;
	char	*what;
  } errlist[] = {
	{  0, "No error" },
	{  1, "Function number invalid" },
	{  2, "File not found" },
	{  3, "Path not found" },
	{  4, "Too many open files" },
	{  5, "Access denied" },
	{  6, "Invalid handle" },
	{ 12, "Access code invalid" },
  };
  struct errlist *ep;
  static char unknown[]= "Error 65535";
  unsigned e;
  char *p;

  for (ep = errlist; ep < errlist + sizeof(errlist)/sizeof(errlist[0]); ep++) {
	if (ep->err == err) return ep->what;
  }
  p = unknown + sizeof(unknown) - 1;
  e = err;
  do *--p = '0' + (e % 10); while ((e /= 10) > 0);
  strcpy(unknown + 6, p);
  return unknown;
}


/*============================================================================*
 *				d_geometry				      *
 *============================================================================*/
PRIVATE void d_geometry(entry)
struct partition *entry;
{
  /* The number of sectors per track is chosen to match the cluster size
   * to make it easy for people to place partitions on cluster boundaries.
   */
  entry->cylinders = d_dr->part[0].dv_size / d_dr->clustersize / 64;
  entry->heads = 64;
  entry->sectors = d_dr->clustersize >> SECTOR_SHIFT;
}
#endif /* ENABLE_DOSFILE */

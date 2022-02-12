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
#include <stdlib.h>
#include <ibm/int86.h>

#if ENABLE_DOSFILE

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
  struct device part[DEV_PER_DRIVE];    /* disks and partitions */
} drive[MAX_DRIVES], *d_dr;

PRIVATE int d_drive;			/* selected drive */
PRIVATE struct device *d_dv;		/* device's base and size */

FORWARD _PROTOTYPE( struct device *d_prepare, (int device) );
FORWARD _PROTOTYPE( char *d_name, (void) );
FORWARD _PROTOTYPE( int d_transfer, (int proc_nr, int opcode, off_t position,
					iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( int d_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int d_do_close, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void dosclose, (int handle) );
FORWARD _PROTOTYPE( char *doserror, (unsigned err) );
FORWARD _PROTOTYPE( void d_geometry, (struct partition *entry));


/* Entry points to this driver. */
PRIVATE struct driver d_dtab = {
  d_name,	/* current device's name */
  d_do_open,	/* open or mount request, initialize device */
  d_do_close,	/* release device */
  do_diocntl,	/* get or set a partition's geometry */
  d_prepare,	/* prepare for I/O on a given minor device */
  d_transfer,	/* do the I/O */
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

  if (device < NR_DEVICES) {			/* d0, d0p[0-3], d1, ... */
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
  static char name[] = "dosfile-d0";

  name[9] = '0' + d_drive;
  return name;
}


/*===========================================================================*
 *				d_transfer				     *
 *===========================================================================*/
PRIVATE int d_transfer(proc_nr, opcode, position, iov, nr_req)
int proc_nr;			/* process doing the request */
int opcode;			/* DEV_GATHER or DEV_SCATTER */
off_t position;			/* offset on device to read or write */
iovec_t *iov;			/* pointer to read or write request vector */
unsigned nr_req;		/* length of request vector */
{
  struct drive *dr = d_dr;
  iovec_t *iop, *iov_end = iov + nr_req;
  unsigned nbytes, count, chunk;
  unsigned long pos;
  unsigned long dv_size = cv64ul(d_dv->dv_size);
  phys_bytes user_base = proc_vir2phys(proc_addr(proc_nr), 0);

  while (nr_req > 0) {
	/* How many bytes to transfer? */
	nbytes = 0;
	for (iop = iov; iop < iov_end; iop++) {
		if (nbytes + iop->iov_size > MAX_COUNT) {
			/* Don't do half a segment if you can avoid it. */
			if (nbytes == 0) nbytes = MAX_COUNT;
			break;
		}
		nbytes += iop->iov_size;
	}

	/* Which block on disk and how close to EOF? */
	pos = position;
	if (pos >= dv_size) return(OK);		/* At EOF */
	if (pos + nbytes > dv_size) nbytes = dv_size - pos;
	pos = cv64ul(d_dv->dv_base) + pos;

	if (opcode == DEV_SCATTER) {
		/* Copy from user space to the DMA buffer. */
		count = 0;
		for (iop = iov; count < nbytes; iop++) {
			chunk = iov->iov_size;
			if (count + chunk > nbytes) chunk = nbytes - count;
			phys_copy(user_base + iop->iov_addr, tmp_phys + count,
							(phys_bytes) chunk);
			count += chunk;
		}
	}

	/* Need to seek to a new position? */
	if (pos != dr->curpos) {
		reg86.b.intno = 0x21;
		reg86.w.ax = 0x4200;	/* LSEEK absolute */
		reg86.w.bx = dr->dfd;
		reg86.w.dx = pos & 0xFFFF;
		reg86.w.cx = pos >> 16;
		level0(int86);
		if (reg86.w.f & 0x0001) {	/* Seek failed */
			printf("%s: seek to %lu failed: %s\n",
				d_name(), pos, doserror(reg86.w.ax));
			dr->curpos = -1;
			return(EIO);
		}
		dr->curpos = pos;
	}

	/* Do the transfer using a DOS read or write call */
	reg86.b.intno = 0x21;
	reg86.b.ah = opcode == DEV_SCATTER ? 0x40 : 0x3F;
	reg86.w.bx = dr->dfd;
	reg86.w.cx = nbytes;
	reg86.w.dx = tmp_phys % HCLICK_SIZE;
	reg86.w.ds = tmp_phys / HCLICK_SIZE;
	level0(int86);
	if ((reg86.w.f & 0x0001) || reg86.w.ax != nbytes) {
		/* Read or write error or unexpected EOF */
		dr->curpos = -1;
		return(EIO);
	}
	dr->curpos += nbytes;

	if (opcode == DEV_GATHER) {
		/* Copy from the DMA buffer to user space. */
		count = 0;
		for (iop = iov; count < nbytes; iop++) {
			chunk = iov->iov_size;
			if (count + chunk > nbytes) chunk = nbytes - count;
			phys_copy(tmp_phys + count, user_base + iop->iov_addr,
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
	if ((file = getenv(d_name())) == NULL) {
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
	if (cv64ul(dr->part[0].dv_size) != dr->curpos) {
		printf("%s: using '%s', %lu bytes%s\n",
			d_name(), file, dr->curpos,
			dr->rw ? "" : " (read-only)");
		dr->part[0].dv_size = cvul64(dr->curpos);
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

	/* Partition the "disk". */
	partition(&d_dtab, d_drive * DEV_PER_DRIVE, P_PRIMARY);
  }

  /* Record one more user. */
  dr->open_ct++;

  if (!dr->rw && (m_ptr->COUNT & W_BIT)) {
	/* Read-only "disk" can't be opened for writing. */
	if (--dr->open_ct == 0) dosclose(dr->dfd);
	return(EACCES);
  }
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
unsigned err;
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
  char *p;

  for (ep = errlist; ep < errlist + sizeof(errlist)/sizeof(errlist[0]); ep++) {
	if (ep->err == err) return ep->what;
  }
  p = unknown + sizeof(unknown) - 1;
  do *--p = '0' + (err % 10); while ((err /= 10) > 0);
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
  entry->cylinders = cv64ul(d_dr->part[0].dv_size) / d_dr->clustersize / 64;
  entry->heads = 64;
  entry->sectors = d_dr->clustersize >> SECTOR_SHIFT;
}
#endif /* ENABLE_DOSFILE */

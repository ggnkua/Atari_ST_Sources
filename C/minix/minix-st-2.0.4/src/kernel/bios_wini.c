/* This file contains the "device dependent" part of a hard disk driver that
 * uses the ROM BIOS.  It makes a call and just waits for the transfer to
 * happen.  It is not interrupt driven and thus will (*) have poor performance.
 * The advantage is that it should work on virtually any PC, XT, 386, PS/2
 * or clone.  The demo disk uses this driver.  It is suggested that all
 * MINIX users try the other drivers, and use this one only as a last resort,
 * if all else fails.
 *
 * (*) The performance is within 10% of the AT driver for reads on any disk
 *     and writes on a 2:1 interleaved disk, it will be DMA_BUF_SIZE bytes
 *     per revolution for a minimum of 60 kb/s for writes to 1:1 disks.
 *
 * The file contains one entry point:
 *
 *	 bios_winchester_task:	main entry when system is brought up
 *
 *
 * Changes:
 *	30 Apr 1992 by Kees J. Bot: device dependent/independent split.
 *	14 May 2000 by Kees J. Bot: d-d/i rewrite.
 */

#include "kernel.h"
#include "driver.h"
#include "drvlib.h"
#include <ibm/int86.h>

#if ENABLE_BIOS_WINI

/* Error codes */
#define ERR		 (-1)	/* general error */

/* Parameters for the disk drive. */
#define MAX_DRIVES         4	/* this driver supports 4 drives (d0 - d3)*/
#define MAX_SECS	 255	/* bios can transfer this many sectors */
#define NR_DEVICES      (MAX_DRIVES * DEV_PER_DRIVE)
#define SUB_PER_DRIVE	(NR_PARTITIONS * NR_PARTITIONS)
#define NR_SUBDEVS	(MAX_DRIVES * SUB_PER_DRIVE)

/* Variables. */
PRIVATE struct wini {		/* main drive struct, one entry per drive */
  unsigned cylinders;		/* number of cylinders */
  unsigned heads;		/* number of heads */
  unsigned sectors;		/* number of sectors per track */
  unsigned open_ct;		/* in-use count */
  int int13ext;			/* IBM/MS INT 13 extensions supported? */
  struct device part[DEV_PER_DRIVE];	/* disks and partitions */
  struct device subpart[SUB_PER_DRIVE]; /* subpartitions */
} wini[MAX_DRIVES], *w_wn;

PRIVATE int nr_drives = MAX_DRIVES;	/* Number of drives */
PRIVATE int w_drive;			/* selected drive */
PRIVATE struct device *w_dv;		/* device's base and size */

FORWARD _PROTOTYPE( struct device *w_prepare, (int device) );
FORWARD _PROTOTYPE( char *w_name, (void) );
FORWARD _PROTOTYPE( int w_transfer, (int proc_nr, int opcode, off_t position,
					iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( int w_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int w_do_close, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void w_init, (void) );
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
 *				bios_winchester_task			     *
 *===========================================================================*/
PUBLIC void bios_winchester_task()
{
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
  static char name[] = "bios-d0";

  name[6] = '0' + w_drive;
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
  struct wini *wn = w_wn;
  iovec_t *iop, *iov_end = iov + nr_req;
  int errors;
  unsigned nbytes, count, chunk;
  unsigned long block;
  unsigned long dv_size = cv64ul(w_dv->dv_size);
  unsigned secspcyl = wn->heads * wn->sectors;
  phys_bytes user_base = proc_vir2phys(proc_addr(proc_nr), 0);
  static struct int13ext_rw {
	u8_t	len;
	u8_t	res1;
	u16_t	count;
	u16_t	addr[2];
	u32_t	block[2];
  } i13e_rw;

  /* Check disk address. */
  if ((position & SECTOR_MASK) != 0) return(EINVAL);

  errors = 0;

  while (nr_req > 0) {
	/* How many bytes to transfer? */
	nbytes = 0;
	for (iop = iov; iop < iov_end; iop++) {
		if (nbytes + iop->iov_size > DMA_BUF_SIZE) {
			/* Don't do half a segment if you can avoid it. */
			if (nbytes == 0) nbytes = DMA_BUF_SIZE;
			break;
		}
		nbytes += iop->iov_size;
	}
	if ((nbytes & SECTOR_MASK) != 0) return(EINVAL);

	/* Which block on disk and how close to EOF? */
	if (position >= dv_size) return(OK);		/* At EOF */
	if (position + nbytes > dv_size) nbytes = dv_size - position;
	block = div64u(add64ul(w_dv->dv_base, position), SECTOR_SIZE);

	/* Degrade to per-sector mode if there were errors. */
	if (errors > 0) nbytes = SECTOR_SIZE;

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

	/* Do the transfer */
	if (wn->int13ext) {
		/* Set up an extended read or write BIOS call. */
		reg86.b.intno = 0x13;
		reg86.w.ax = opcode == DEV_SCATTER ? 0x4300 : 0x4200;
		reg86.b.dl = 0x80 + w_drive;
		reg86.w.si = vir2phys(&i13e_rw) % HCLICK_SIZE;
		reg86.w.ds = vir2phys(&i13e_rw) / HCLICK_SIZE;
		i13e_rw.len = 0x10;
		i13e_rw.res1 = 0;
		i13e_rw.count = nbytes >> SECTOR_SHIFT;
		i13e_rw.addr[0] = tmp_phys % HCLICK_SIZE;
		i13e_rw.addr[1] = tmp_phys / HCLICK_SIZE;
		i13e_rw.block[0] = block;
		i13e_rw.block[1] = 0;
	} else {
		/* Set up an ordinary read or write BIOS call. */
		unsigned cylinder = block / secspcyl;
		unsigned sector = (block % wn->sectors) + 1;
		unsigned head = (block % secspcyl) / wn->sectors;

		reg86.b.intno = 0x13;
		reg86.b.ah = opcode == DEV_SCATTER ? 0x03 : 0x02;
		reg86.b.al = nbytes >> SECTOR_SHIFT;
		reg86.w.bx = tmp_phys % HCLICK_SIZE;
		reg86.w.es = tmp_phys / HCLICK_SIZE;
		reg86.b.ch = cylinder & 0xFF;
		reg86.b.cl = sector | ((cylinder & 0x300) >> 2);
		reg86.b.dh = head;
		reg86.b.dl = 0x80 + w_drive;
	}
	level0(int86);
	if (reg86.w.f & 0x0001) {
		/* An error occurred, try again sector by sector unless */
		if (++errors == 2) return(EIO);
		continue;
	}

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
  w_wn->open_ct--;
  return(OK);
}


/*===========================================================================*
 *				w_init					     *
 *===========================================================================*/
PRIVATE void w_init()
{
/* This routine is called at startup to initialize the drive parameters. */

  int drive;
  struct wini *wn;
  unsigned long capacity;
  static struct int13ext_params {
	u16_t	len;
	u16_t	flags;
	u32_t	cylinders;
	u32_t	heads;
	u32_t	sectors;
	u32_t	capacity[2];
	u16_t	bts_per_sec;
	u16_t	config[2];
  } i13e_par;

  /* Get the geometry of the drives */
  for (drive = 0; drive < nr_drives; drive++) {
	(void) w_prepare(drive * DEV_PER_DRIVE);
	wn = w_wn;
	reg86.b.intno = 0x13;
	reg86.b.ah = 0x08;	/* Get drive parameters. */
	reg86.b.dl = 0x80 + drive;
	level0(int86);
	nr_drives = !(reg86.w.f & 0x0001) ? reg86.b.dl : drive;
	if (nr_drives > MAX_DRIVES) nr_drives = MAX_DRIVES;
	if (drive >= nr_drives) break;

	wn->heads = reg86.b.dh + 1;
	wn->sectors = reg86.b.cl & 0x3F;
	wn->cylinders = (reg86.b.ch | ((reg86.b.cl & 0xC0) << 2)) + 1;

	capacity = (unsigned long) wn->cylinders * wn->heads * wn->sectors;

	reg86.b.intno = 0x13;
	reg86.b.ah = 0x41;	/* INT 13 Extensions - Installation check */
	reg86.w.bx = 0x55AA;
	reg86.b.dl = 0x80 + drive;
	if (pc_at) level0(int86);

	if (!(reg86.w.f & 0x0001) && reg86.w.bx == 0xAA55
				&& (reg86.w.cx & 0x0001)) {
		/* INT 13 Extensions available. */
		reg86.b.intno = 0x13;
		reg86.b.ah = 0x48;	/* Ext. Get drive parameters. */
		reg86.b.dl = 0x80 + drive;
		reg86.w.si = vir2phys(&i13e_par) % HCLICK_SIZE;
		reg86.w.ds = vir2phys(&i13e_par) / HCLICK_SIZE;
		i13e_par.len = 0x001E;	/* Input size of parameter packet */
		level0(int86);
		if (!(reg86.w.f & 0x0001)) {
			wn->int13ext = 1;	/* Extensions can be used. */
			capacity = i13e_par.capacity[0];
			if (i13e_par.capacity[1] != 0) capacity = 0xFFFFFFFF;
		}
	}

	if (wn->int13ext) {
		printf("%s: %lu sectors\n", w_name(), capacity);
	} else {
		printf("%s: %d cylinders, %d heads, %d sectors per track\n",
			w_name(), wn->cylinders, wn->heads, wn->sectors);
	}
	wn->part[0].dv_size = mul64u(capacity, SECTOR_SIZE);
  }
}


/*============================================================================*
 *				w_geometry				      *
 *============================================================================*/
PRIVATE void w_geometry(entry)
struct partition *entry;
{
  entry->cylinders = w_wn->cylinders;
  entry->heads = w_wn->heads;
  entry->sectors = w_wn->sectors;
}
#endif /* ENABLE_BIOS_WINI */

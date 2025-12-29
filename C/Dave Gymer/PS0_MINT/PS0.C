/*
 * ps0 - a simple device driver for raw floppy disks
 *
 * This program is written by Dave Gymer and is hereby placed in
 * the public domain.
 * The code is based on the clock device by Eric R Smith.
 *
 * Some improvements you could make:
 *	- ioctl calls to reset disk characteristics on the fly
 *	- maybe an ioctl call to format a track or whole disk
 *	- command line arguments during installation governing which drive
 * 	to use
 *	- write Floprd(2) and Flopwr(2) in this code to aboid calling the
 *	Xbios altogether, and also allow it to do hard disks, too (bloody
 *	dangerous if you can overwrite the boot block!)
 *	- write TOS/minix-ST/minix-PC filing systems that use this (in a hard
 *	disk version, most likely) instead of Rwabs(2) [ya think I'm kiddin?]
 */

#include <minimal.h>
#include <osbind.h>
#include <basepage.h>
#include <mintbind.h>
#include "filesys.h"
#include "atarierr.h"

/* characteristics of the floppy in question */
#define DRIVE	0	/* BIOS drive number, 0 == A:, 1 == B: */
#define TRACKS	80	/* tracks per disk */
#define SIDES	2	/* sides per track */
#define SECTORS	9	/* sectors per track */
#define SECSIZE	512L	/* bytes per sector */
#define BLOCKSIZE (SECSIZE * SECTORS)

/* the name of the device we're installing */
/* I call mine /dev/ps0, cos that's what it's called on my Linux PC. */
char name[] = "U:\\dev\\ps0";

/* kernel information */
struct kerinfo *kernel;
#define TGETTIME (*kernel->dos_tab[0x2c])
#define TGETDATE (*kernel->dos_tab[0x2a])

#define SPRINTF (*kernel->sprintf)
#define DEBUG (*kernel->debug)
#define ALERT (*kernel->alert)
#define TRACE (*kernel->trace)
#define FATAL (*kernel->fatal)
#define KMALLOC(sz) (*kernel->kmalloc)((long) (sz))
#define KFREE (*kernel->kfree)

/* assumption: 16 bit shorts if !__MSHORT__ and 16 bit ints if __MSHORT__ */
#ifdef __MSHORT__
#define word int
#else
#define word short
#endif

/* device driver information */
static long	floppy_open	P_((FILEPTR *)),
		floppy_write	P_((FILEPTR *, char *, long)),
		floppy_read	P_((FILEPTR *, char *, long)),
		floppy_lseek	P_((FILEPTR *, long, word)),
		floppy_ioctl	P_((FILEPTR *, word, void *)),
		floppy_datime	P_((FILEPTR *, word *, word)),
		floppy_close	P_((FILEPTR *));

static long 	floppy_select();
static void	floppy_unselect();

DEVDRV floppy_device = {
	floppy_open, floppy_write, floppy_read, floppy_lseek, floppy_ioctl,
	floppy_datime, floppy_close, floppy_select, floppy_unselect,
	0, 0, 0
};

struct dev_descr devinfo = {
	&floppy_device, 0, 0, (struct tty *)0, 0L, 0L, 0L, 0L
};

/* Install time, for floppy_datime. */

static word install_date;
static word install_time;

/* structure to hold a block buffer */
typedef struct floppy_block {
	int track;
	int side;
	long byte;
	enum { INVALID, VALID, DIRTY, ATEOF } state;
	char *buffer;
} FLOBLOCK;

/*
 * the main program just installs the device, and then does Ptermres
 * to remain resident
 */

main()
{
	kernel = (struct kerinfo *)Dcntl(DEV_INSTALL, name, &devinfo);
	if (!kernel || ((long) kernel) == -32) {
		Cconws("Unable to install floppy device\r\n");
		Pterm(1);
	}
	install_time = TGETTIME();
	install_date = TGETDATE();
	Ptermres(256L + _base->p_tlen + _base->p_dlen + _base->p_blen, 0);
}

/*
 * utility functions
 * note that blocks are whole tracks
 */

/* read a block */

static int
read_block(floblock)
	FLOBLOCK *floblock;
{
	int rv;

	rv = Floprd(floblock->buffer, 0L, DRIVE, 1,
		    floblock->track, floblock->side, SECTORS);
	if (rv) {
		DEBUG("Floprd failed in read_buf");
		floblock->state = INVALID;
	} else
		floblock->state = VALID;
	return rv;
}

/* flush a block */

static int
flush_block(floblock)
	FLOBLOCK *floblock;
{
	int rv;

	if (floblock->state != DIRTY)
		return 0;
	rv = Flopwr(floblock->buffer, 0L, DRIVE, 1,
		    floblock->track, floblock->side, SECTORS);
	if (rv)
		DEBUG("Flopwr failed in flush_block");
	else
		floblock->state = VALID;
	return rv;
}

/* convert long seek position into floppy_block */

static void
seek2int(pos, floblock)
	long pos;
	FLOBLOCK *floblock;
{
	if (pos < 0)
		pos = 0;
	floblock->byte = pos % BLOCKSIZE;
	pos /= BLOCKSIZE;
	floblock->side = pos % SIDES;
	pos /= SIDES;
	floblock->track = pos;
	if (floblock->track >= TRACKS) {
		floblock->track = TRACKS;
		floblock->side = 0;
		floblock->byte = 0;
		floblock->state = ATEOF;
	}
}

/* convert floppy_block into long seek position */

static long
int2seek(floblock)
	FLOBLOCK *floblock;
{
	return ((long) floblock->track * SIDES + floblock->side) * BLOCKSIZE
		+ floblock->byte;
}

/* move to next block - read it, after flushing the old one */

static int
next_block(floblock)
	FLOBLOCK *floblock;
{
	int rv = 0;

	if (floblock->state != ATEOF) {
		rv = flush_block(floblock);
		if (++floblock->side == SIDES) {
			floblock->side = 0;
			if (++floblock->track == TRACKS) {
				floblock->state = ATEOF;
				floblock->side = 0;
			}
		}
		if (floblock->state != ATEOF)
			if (rv)
				floblock->state = INVALID;
			else
				rv = read_block(floblock);
		floblock->byte = 0;
	}
	return rv;
}

/*
 * here are the actual device driver functions
 */

static long
floppy_open(f)
	FILEPTR *f;
{
	int rv;
	FLOBLOCK *floblock = (FLOBLOCK *) KMALLOC(sizeof(FLOBLOCK));

	if (!floblock)
		return ENSMEM;
	floblock->buffer = (char *) KMALLOC(BLOCKSIZE);
	if (!floblock->buffer)
		return ENSMEM;
	f->devinfo = (long) floblock;
	floblock->state = INVALID;
	floblock->track = 0;
	floblock->side = 0;
	floblock->byte = 0;
	return 0;
}

static long
floppy_write(f, buf, bytes)
	FILEPTR *f; char *buf; long bytes;
{
	FLOBLOCK *floblock = (FLOBLOCK *) f->devinfo;
	int rv = 0;
	long bytes_written = 0;

	if (floblock->state == INVALID)	/* not started yet */
		rv = read_block(floblock);

	/* keep going until we've written enough, or there's an error or EOF */
	while (!rv && floblock->state != ATEOF && bytes) {
		if (floblock->byte < BLOCKSIZE) {	/* data in buffer */
			char *ptr = floblock->buffer + floblock->byte;
			long num = BLOCKSIZE - floblock->byte;

			if (num > bytes)
				num = bytes;
			bytes_written += num;
			bytes -= num;
			floblock->byte += num;
			while (num--)
				*ptr++ = *buf++;
			floblock->state = DIRTY;
		} else		/* must get next block */
			rv = next_block(floblock);
	}
	return rv ? rv : bytes_written;
}

static long
floppy_read(f, buf, bytes)
	FILEPTR *f; char *buf; long bytes;
{
	FLOBLOCK *floblock = (FLOBLOCK *) f->devinfo;
	int rv = 0;
	long bytes_read = 0;

	if (floblock->state == INVALID)	/* not started yet */
		rv = read_block(floblock);

	/* keep going until we've read enough, or there's an error or EOF */
	while (!rv && floblock->state != ATEOF && bytes) {
		if (floblock->byte < BLOCKSIZE) {	/* data in buffer */
			char *ptr = floblock->buffer + floblock->byte;
			long num = BLOCKSIZE - floblock->byte;

			if (num > bytes)
				num = bytes;
			bytes_read += num;
			bytes -= num;
			floblock->byte += num;
			while (num--)
				*buf++ = *ptr++;
		} else		/* must get next block */
			rv = next_block(floblock);
	}
	return rv ? rv : bytes_read;
}

static long
floppy_lseek(f, where, whence)
	FILEPTR *f; long where; word whence;
{
	long newpos = where;
	FLOBLOCK *floblock = (FLOBLOCK *) f->devinfo;

	switch (whence) {
		case SEEK_SET:
			break;
		case SEEK_CUR:
			newpos += int2seek(floblock);
			break;
		case SEEK_END:
			newpos = SIDES * TRACKS * BLOCKSIZE - newpos;
			break;
		default:
			DEBUG("ps0: illegal whence (%d) in seek", whence);
			return ERANGE;
	}
	if (int2seek(floblock) % BLOCKSIZE != newpos % BLOCKSIZE) {
		if (flush_block(floblock))
			DEBUG("flush_block failed in floppy_lseek");
		floblock->state = INVALID;
	}
	seek2int(newpos, floblock);
	return newpos;
}

static long
floppy_ioctl(f, mode, buf)
	FILEPTR *f; word mode; void *buf;
{
	switch (mode) {
		case FIONREAD:
		case FIONWRITE:
			/*
			 * we never block - use BLOCKSIZE as a sensible
			 * number to read as a chunk
			 */
			*((long *) buf) = BLOCKSIZE;
			return 0;
		default:
			return EINTRN;
	}
}

static long
floppy_datime(f, timeptr, wrflag)
	FILEPTR *f;
	word *timeptr;
	word wrflag;
{
	if (wrflag)
		return EINVFN;
	*timeptr++ = install_time;
	*timeptr++ = install_date;
	return 0;
}

static long
floppy_close(f)
	FILEPTR *f;
{
	int rv = 0;
	FLOBLOCK *floblock = (FLOBLOCK *) f->devinfo;

	if (!f->links) {
		rv = flush_block(floblock);	/* flush the buffer */
		KFREE(floblock->buffer);
		KFREE(floblock);
	}
	return rv;
}

static long
floppy_select()
{
	return 1;	/* we're always ready for I/O */
}

static void
floppy_unselect()
{
	/* nothing for us to do here */
}

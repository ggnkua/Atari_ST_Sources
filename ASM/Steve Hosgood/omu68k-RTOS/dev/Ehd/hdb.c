/*******************************************************************************
 *	Hd.c	Hard disk driver
 *******************************************************************************
 */
# include	<errno.h>
# include	"../../include/buf.h"
# include	"hd.h"
# include	"scsi.h"
# include	"devbuf.h"

# define	HDNOTRACKS	1216	/* No of tracks on a drive */
# define	HDNOSECTORS	34	/* Number of sectors per track */

struct Drive_info drive_info[NHDDEVS];
int	no_hdopen;		/* Total number of hard disks open */

hdopen(dev)
int	dev;
{
	int	err;

	if((dev < 0) || (dev >= NHDDEVS)) return -1;

	/* If first open to any drive initialise system */
	if(!no_hdopen++){
		si_init();
		initdevbuf();
	}

	/* If drive is not already open initialise it */
	if(!drive_info[dev].d_nopen++){
		if(err = hdrestore(dev)) return -1;
	}
	return 0;
}

hdclose(dev)
int	dev;
{
	int	err;

	/* Close drives entry */
	no_hdopen--;
	if(!(--drive_info[dev].d_nopen)){
		if(err = hdrestore(dev)) return -1;
	}
	return 0;
}

hdstrat(buf)
struct	buf *buf;
{
	int	err;

	/* Verify device and track number */
	if((buf->b_dev < 0) || (buf->b_dev >= NHDDEVS)){
		buf->b_flags = ABORT;
		hderr("HD: No such dev", buf);
		return error(ENXIO);
	}

	if((buf->b_bno < 0) || (buf->b_bno > (HDNOSECTORS * HDNOTRACKS))){
		buf->b_flags = ABORT;
		hderr("HD: block out of range", buf);
		return error(ENXIO);
	}

	/* Check if write if so put straight to disk */
	if(buf->b_flags == WRITE)
		err = hdwrite(buf);	/* copy to disk */

	else
		err = hdread(buf);	/* go get a buffer */

	/* Test if error occured if so report it and return -1 */
	if(err == ERROR){
		buf->b_flags = ABORT;
		return error(EIO);
	}
	else return err;
}

hdioctl(dev, req, data)
int	dev, req;
int	*data;
{
	int	err;

	if((dev < 0) || (dev >= NHDDEVS)) return -1;
	switch(req){
	case HDFORMAT:
		if(err = si_cmd(SIFORMAT, dev, 0, 1, 0)) return -1;
		break;
	case HDCERTIFY:
		if(err = si_cmd(SICERTIFY, dev, 1, 0, 0)) return -1;
		break;
	}
	return 0;
}

/*
 *	Hdrestore()	Restores drive
 */
hdrestore(dev)
int	dev;
{
	return si_cmd(SIREZERO, dev, 0, 0, 0);
}

/*
 *	Hdread()	Read from disk
 */
hdread(buf)
struct	buf *buf;
{
	int	err;
	struct	Dbuf *dbuf;

	err = 0;
	if(fromdevbuf(buf) == -1){
		dbuf = getdevbuf();
		err = si_cmd(SIREAD, buf->b_dev, buf->b_bno, 2, dbuf->data);
		dbuf->flags = READABLE;
		dbuf->mindev = buf->b_dev;
		dbuf->bstart = buf->b_bno;
		dbuf->bend = buf->b_bno + 2;
		if(fromdevbuf(buf) == -1) err = -1;
	}
	return err;
}

/*
 *	Hdwrite()	Write to disk
 */
hdwrite(buf)
struct	buf *buf;
{
	struct Dbuf *dbuf;

	/* If in buffer system remove */
	if(dbuf = checkdevbuf(buf)){
		dbuf->flags = AVAILABLE;
		if(dbuf->prev) dbuf->prev->next = dbuf->next;
		if(dbuf->next) dbuf->next->prev = dbuf;
	}
	return si_cmd(SIWRITE, buf->b_dev, buf->b_bno, 1, buf->b_buf);
}

/*
 *	Hderr()		Hard disk error
 */
hderr(str, buf)
char	*str;
struct buf *buf;
{
	printf("%s device %d block %d\n\r",str, buf->b_dev, buf->b_bno);
	return error(EIO);
}

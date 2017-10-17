/*
 * Provide routines to operate on in-core inodes.
 * S.Hosgood, 23.feb.84
 */

# include       "../include/param.h"
# include       "../include/file.h"
# include       "../include/ino.h"
# include       "../include/buf.h"
# include       "../include/dev.h"
# include       "../include/inode.h"
# include	"../include/stat.h"

/* Define cache of inodes */
struct inode ibuf[NINODES];

/*
 * Scan inode table for wanted node, if not there, read in. Lock node.
 */
struct inode *
getiptr(mdev, dminor, ino)
struct dev *mdev;
{
	int	i, p, mode;
	struct	inode *iptr;
	struct	buf *bptr;
	struct	dinode *diptr;

	if (iptr = i_find(mdev, dminor, ino)) {
		/* found a slot, lock it and read from disk if it was free */
		if (iptr->i_nlocks++ == 0) {
			/* read in from disk to this slot */
			bptr = getibuf(mdev, dminor, ino);
			diptr = getdiptr(bptr, ino);

			mode = diptr->di_mode & S_IFMT;
			iptr->i_mode = diptr->di_mode;
			iptr->i_flag = 0;
			iptr->i_nlink = diptr->di_nlink;
			iptr->i_mdev = mdev;
			iptr->i_minor = dminor;
			iptr->i_ino = ino;
			iptr->i_uid = diptr->di_uid;
			iptr->i_gid = diptr->di_gid;
			iptr->i_atime = diptr->di_atime;
			iptr->i_mtime = diptr->di_mtime;
			iptr->i_ctime = diptr->di_ctime;
			iptr->i_size = 0;

			/* copy block addresses NOTE speed could use pointers */

			for (i=p=0; i < 13; i++) {
				iptr->i_addr[i] = ((diptr->di_addr[p]<<16)&0xFF0000)+
					((diptr->di_addr[p+1]<<8)&0xFF00)
						+((diptr->di_addr[p+2])&0xFF);
				p+=3;
			}

			/* establish file type */
			if (mode == S_IFREG || mode == S_IFDIR) {
				/* regular file */
				iptr->i_size = diptr->di_size;
			}
		}

	}
	else
		printf("inode table overflow\n");

	return iptr;
}

/*
 * Freeiptr - clears an in-core inode copy.
 *              If inode was changed, write to disk.
 *		If mode of inode was 0 (not in use) then just add to free list
 */
freeiptr(iptr)
struct inode *iptr;
{
	if (iptr) {
		if (iptr->i_nlocks) {
			iptr->i_nlocks--;
		}

		if (iptr->i_nlocks == 0) {
			/* check if any links exist, else clear inode */
			if (iptr->i_nlink == 0) {
				itrunc(iptr);
				iptr->i_mode = 0;
				makeifree(iptr->i_mdev, iptr->i_minor, iptr->i_ino);
				iptr->i_flag |= ICHG;
			}

			/* write to disk if changed */
			iwrite(iptr);
		}
	}
	else
		printf("Zero iptr to free?\n");

	return;
}

/*
 * Relock - makes a locked inode belong to another holder.
 */
struct inode *
relock(iptr)
struct inode *iptr;
{

	if (iptr) {
		iptr->i_nlocks++;
	}

	return iptr;
}

/*
 * Isdir - checks given locked inode to see if its a directory.
 */
isdir(iptr)
struct inode *iptr;
{

	return (iptr->i_mode & S_IFMT) == S_IFDIR;
}

/*
 * Getibuf - reads buffer containing given inode, on given dev.
 */
struct buf *
getibuf(mdev, dminor, ino)
struct dev *mdev;
{
	struct buf *b_ptr;

	b_ptr = getbuf(mdev, dminor, ((ino-1) / INOPB) + 2, ALLBUF);
	return b_ptr;
}

/*
 * Getdiptr - points to given inode, assuming block contains it.
 */
struct dinode *
getdiptr(b_ptr, ino)
struct buf *b_ptr;
{
	struct dinode *di_ptr;

	di_ptr = (struct dinode *)b_ptr->b_buf;
	di_ptr += ((ino - 1) % INOPB);
	return di_ptr;
}

/*
 * Iflush - called by 'sync' to flush changed inodes to disk.
 */
iflush()
{
	int i;

	for (i = 0; i < NINODES; i++)
		iwrite(&ibuf[i]);

	return;
}

/*
 * Iwrite - writes given inode back to disk.
 */
iwrite(iptr)
struct inode *iptr;
{
	int i, p;
	struct buf *bptr;
	struct dinode *diptr;

	if (iptr->i_flag & ICHG) {
		bptr = getibuf(iptr->i_mdev, iptr->i_minor, iptr->i_ino);
		diptr = getdiptr(bptr, iptr->i_ino);
		diptr->di_mode = iptr->i_mode;
		diptr->di_nlink = iptr->i_nlink;
		diptr->di_size = iptr->i_size;
		diptr->di_uid = iptr->i_uid;
		diptr->di_gid = iptr->i_gid;
		diptr->di_ctime = iptr->i_ctime;
		diptr->di_mtime = iptr->i_mtime;
		diptr->di_atime = iptr->i_atime;

/* Put block numbers into disk struct NOTE pointers would speed up */

		for (i=p=0; i < 13; i++) {
			diptr->di_addr[p++]  = (iptr->i_addr[i]>>16);
			diptr->di_addr[p++]  = (iptr->i_addr[i]>>8);
			diptr->di_addr[p++]  = (iptr->i_addr[i]);
		}

		/* mark block as dirty */
		bptr->b_flags |= WRITE;

		/* mark inode as clean */
		iptr->i_flag &= ~ICHG;
	}

	return;
}

/*
 * Iexpand - allow size of inode to increment during writes and seeks..
 */
iexpand(iptr, n)
long n;
struct inode *iptr;
{

	if (iptr) {
		if (iptr->i_size < n) {
			iptr->i_size = n;
			iptr->i_flag |= ICHG;
		}
	}

	return;
}

/*
 * Isize - return size of inode.
 */
isize(iptr)
struct inode *iptr;
{

	return iptr->i_size;
}

/*
 * I_find - scans icache for a given inode on a given device, or if the given
 *		inode number is zero, scans for any inode on the device.
 *		Returns a pointer to the icache entry, or a free entry with
 *		its 'i_nlocks' field set to 0. Null return if there's no space
 *		for a free inode.
 */
struct inode *
i_find(mdev, dminor, ino)
struct dev *mdev;
{
	struct inode *iptr, *ifree;

	ifree = NULLIPTR;

	for (iptr = ibuf; iptr < &ibuf[NINODES]; iptr++) {
		/* remember any free slots found */
		if (iptr->i_nlocks == 0)
			ifree = iptr;
		else if (iptr->i_mdev == mdev && iptr->i_minor == dminor) {
			/* found an entry on the right device */
			if (ino == 0 || ino == iptr->i_ino)
				/* i-number matches if it was given */
				return iptr;
		}
	}

	/* if a free slot was found, return it, else NULL if no space */
	return ifree;
}

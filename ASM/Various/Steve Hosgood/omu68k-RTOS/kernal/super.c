/*
 * Super-Block processing (free list etc).
 * S.Hosgood 5.mar.84
 * Modded to update free block and inode count, and use byteclr()
 * T.Barnaby 4.March.1985
 */

# include	"../include/param.h"
# include       "../include/inode.h"
# include       "../include/filsys.h"
# include       "../include/buf.h"
# include       "../include/fblk.h"
# include       "../include/dev.h"
# include       "../include/ino.h"
# include	"../include/signal.h"
# include	<errno.h>
# include	"../include/procs.h"

long time();

/*
 * Getfree - removes a free block from a disk, returns its number.
 *              Block is cleared.
 */
getfree(mdev, min_dev)
struct dev *mdev;
{
	long fb, count;
	struct buf *s_buf, *fb_buf;
	struct filsys *s_blk;
	struct fblk *fb_ptr;

	fb = 0;

	/* obtain superblock for this volume */
	s_buf = getbuf(mdev, min_dev, SUPERB, ALLBUF);
	s_buf->b_flags |= B_BUSY;		/* Mark buffer as busy */
	s_blk = ( struct filsys * ) s_buf->b_buf;

	/* check if any free list */
	if (s_blk->s_nfree){
		/* free blocks exist */
		fb = s_blk->s_free[--s_blk->s_nfree];

		/* Checks if block number valid, if not set it to 0 to prevent
		 * further use and return 0, only done if not last block on
		 * disk.
		 */
		if((fb < (long)s_blk->s_isize) || (fb > (long)s_blk->s_fsize)){
			if(fb || s_blk->s_nfree){
				printf("Physblk: Free list up the creek! block %d\n",fb);
				s_blk->s_free[++s_blk->s_nfree] = 0;
				fb = 0;
			}
		}
		s_buf->b_flags |= WRITE;
	}

	/* check if we need secondary free block search */
	if (fb){
		if (s_blk->s_nfree == 0){
			/* read in next block in free chain */
			fb_buf = getbuf(mdev, min_dev, fb, ALLBUF);
			fb_ptr = ( struct fblk * ) fb_buf->b_buf;
			s_blk->s_nfree = fb_ptr->df_nfree;

			for (count = 0; count < s_blk->s_nfree; count++)
				s_blk->s_free[count] = fb_ptr->df_free[count];
		}
	}
	else{
		printf("Physblk: No space on filestore %d,%d\n", mdev - &bdevsw[0], min_dev);
	}

	/* read in and clear free block */
	if (fb){
		fb_buf = getbuf(mdev, min_dev, fb, ALLBUF);
		byteclr(fb_buf->b_buf,BSIZE);
		fb_buf->b_flags |= WRITE;

		/* Update free block count */
		if((--s_blk->s_tfree) < 0) s_blk->s_tfree = 0;
		s_buf->b_flags |= WRITE;
	}
	s_buf->b_flags &= ~B_BUSY;	/* No longer busy */

	return fb;
}

/*
 * Makefree - makes a block appear on the free-list.
 */
makefree(mdev, min_dev, bno)
struct dev *mdev;
{
	int count;
	struct buf *s_buf, *fb_buf;
	struct filsys *s_blk;
	struct fblk *fb_ptr;

	/* obtain superblock for this volume */
	s_buf = getbuf(mdev, min_dev, SUPERB, ALLBUF);
	s_buf->b_flags |= B_BUSY;		/* Mark buffer as busy */
	s_blk = ( struct filsys * ) s_buf->b_buf;

	/* check if we need to use a new chain block */
	if (s_blk->s_nfree >= NICFREE){
		/* get block to be freed, use as chain block */
		fb_buf = getbuf(mdev, min_dev, bno, ALLBUF);
		fb_ptr = ( struct fblk * ) fb_buf->b_buf;
		fb_ptr->df_nfree = s_blk->s_nfree;

		for (count = 0; count < s_blk->s_nfree; count++){
			fb_ptr->df_free[count] = s_blk->s_free[count];
		}

		fb_buf->b_flags |= WRITE;
		s_blk->s_nfree = 0;
	}

	/* enter block to be freed into superblock */
	s_blk->s_free[s_blk->s_nfree++] = bno;

	/* Update free block count */
	s_blk->s_tfree++;
	s_buf->b_flags |= WRITE;
	s_buf->b_flags &= ~B_BUSY;	/* No longer busy */

	return;
}

/*
 * Lockfree - returns pointer to a locked inode from the free inode list.
 */
struct inode *
lockfree(mdev, min_dev)
struct dev *mdev;
{
	int	fi, count;
	long	now;
	struct	buf *s_buf;
	struct	filsys *s_blk;
	struct	inode *fi_ptr;

	/* obtain superblock for this volume */
	s_buf = getbuf(mdev, min_dev, SUPERB, ALLBUF);
	s_buf->b_flags |= B_BUSY;		/* Mark buffer as busy */
	s_blk = ( struct filsys * ) s_buf->b_buf;
	fi_ptr = NULLIPTR;

	/* scan down free i-list. */
	while (s_blk->s_ninode){
		fi = s_blk->s_inode[--s_blk->s_ninode];
		s_buf->b_flags |= WRITE;
		if (fi_ptr = getiptr(mdev, min_dev, fi)){
			if (fi_ptr->i_mode == 0)
				/* found a clear inode */
				break;

			printf("inode %d was busy\n", fi);
			freeiptr(fi_ptr);
			fi_ptr = NULLIPTR;
		}
	}

	/* if list exhausted, scan for a free inode */
	if (! fi_ptr) {
		for (fi = 3; fi < ((s_blk->s_isize - 2) * INOPB); fi++) {
			if (fi_ptr = getiptr(mdev, min_dev, fi)) {
				if (fi_ptr->i_mode == 0){
					/* This is clear, Now trys to read
					 * in the next INOPB - 1 more inodes
					 * into the super-block free-list.
					 */
					addifree(mdev, min_dev, s_blk, fi);
					break;
				}
				freeiptr(fi_ptr);
				fi_ptr = NULLIPTR;
			}
		}
	}

	if (fi_ptr) {
		/* make mode non-zero to indicate capture */
		fi_ptr->i_flag = 0;
		fi_ptr->i_mode = 1;
		fi_ptr->i_uid = cur_proc->uid;
		fi_ptr->i_gid = cur_proc->gid;

		/* set create time etc */
		now = time(( long * ) 0);
		fi_ptr->i_atime = fi_ptr->i_mtime = fi_ptr->i_ctime = now;

		for (count = 0; count < 13; count++)
			fi_ptr->i_addr[count] = 0;

		fi_ptr->i_flag |= ICHG;
		fi_ptr->i_size = 0;

		s_buf->b_flags |= WRITE;

		/* Update free inode count obtain superblock for this volume */
		if((--s_blk->s_tinode) < 0) s_blk->s_tinode = 0;
		s_buf->b_flags |= WRITE;
	}
	else{
		printf("no inodes on disk %d\n", min_dev);
		error(ENOSPC);
	}

	s_buf->b_flags &= ~B_BUSY;	/* No longer busy */

	return fi_ptr;
}

/*
 *	Addifree()	Adds the next INOPB -1 from the given inode number
 *			to the superblock inode free list if they are free.
 */
addifree(mdev, min_dev, s_blk, fi)
struct	dev *mdev;
int	min_dev;
struct	filsys *s_blk;
int	fi;
{
	long	fit;
	struct	inode *fi_ptr;

	/* This bit doesn't work as any free inodes aquired are subtracted
	 * From the total number of free nodes on the disk (Whoops)
	 * I shall do this better sometime.......
	 */
	return;

	fit = ((s_blk->s_isize - 2) * INOPB);	/* Last + 1 inode */
	if((fi + INOPB) < fit) fit = fi + INOPB;/* Gets last inode to look at */

	/* Scans next NIOPB - 1 inodes, if free adds to super-block free list */
	for(fi++; fi < fit; fi++){
		if(fi_ptr = getiptr(mdev, min_dev, fi)){
			freeiptr(fi_ptr);
		}
	}
}

/*
 * Makeifree - enters inode in free inode list.
 */
makeifree(mdev, min_dev, fi)
struct dev *mdev;
{
	struct buf *s_buf;
	struct filsys *s_blk;

	s_buf = getbuf(mdev, min_dev, SUPERB, ALLBUF);
	s_buf->b_flags |= B_BUSY;		/* Mark buffer as busy */
	s_blk = ( struct filsys * ) s_buf->b_buf;

	if (s_blk->s_ninode < NICINOD){
		s_blk->s_inode[s_blk->s_ninode++] = fi;

	}
	/* Update free inode count */
	s_blk->s_tinode++;
	s_buf->b_flags |= WRITE;
	s_buf->b_flags &= ~B_BUSY;	/* No longer busy */

	return;
}

/*
 * Set_time - sets system clock from superblock time.
 */
set_time()
{
	struct buf *s_buf;
	struct filsys *s_blk;

	/* get root volume superblock */
	s_buf = getbuf(&bdevsw[0], 0, SUPERB, ALLBUF);
	s_blk = ( struct filsys * ) s_buf->b_buf;

	setime(s_blk->s_time);
	return;
}

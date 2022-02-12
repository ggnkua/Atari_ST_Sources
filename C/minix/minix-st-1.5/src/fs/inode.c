/* This file manages the inode table.  There are procedures to allocate and
 * deallocate inodes, acquire, erase, and release them, and read and write
 * them from the disk.
 *
 * The entry points into this file are
 *   get_inode:	   search inode table for a given inode; if not there, read it
 *   put_inode:	   indicate that an inode is no longer needed in memory
 *   alloc_inode:  allocate a new, unused inode
 *   wipe_inode:   erase some fields of a newly allocated inode
 *   free_inode:   mark an inode as available for a new file
 *   update_times: update atime, ctime, and mtime
 *   rw_inode:	   read a disk block and extract an inode, or corresp. write
 *   dup_inode:	   indicate that someone else is using an inode table entry
 */

#include "fs.h"
#include <sys/stat.h>
#include <minix/boot.h>
#include "buf.h"
#include "file.h"
#include "fproc.h"
#include "inode.h"
#include "super.h"

/*===========================================================================*
 *				get_inode				     *
 *===========================================================================*/
PUBLIC struct inode *get_inode(dev, numb)
dev_t dev;			/* device on which inode resides */
ino_t numb;			/* inode number */
{
/* Find a slot in the inode table, load the specified inode into it, and
 * return a pointer to the slot.  If 'dev' == NO_DEV, just return a free slot.
 */

  register struct inode *rip, *xp;

  /* Search the inode table both for (dev, numb) and a free slot. */
  xp = NIL_INODE;
  for (rip = &inode[0]; rip < &inode[NR_INODES]; rip++) {
	if (rip->i_count > 0) { /* only check used slots for (dev, numb) */
		if (rip->i_dev == dev && rip->i_num == numb) {
			/* This is the inode that we are looking for. */
			rip->i_count++;
			return(rip);	/* (dev, numb) found */
		}
	} else
		xp = rip;	/* remember this free slot for later */
  }

  /* Inode we want is not currently in use.  Did we find a free slot? */
  if (xp == NIL_INODE) {	/* inode table completely full */
	err_code = ENFILE;
	return(NIL_INODE);
  }

  /* A free inode slot has been located.  Load the inode into it. */
  xp->i_dev = dev;
  xp->i_num = numb;
  xp->i_count = 1;
  if (dev != NO_DEV) rw_inode(xp, READING);	/* get inode from disk */
  xp->i_update = 0;		/* all the times are initially up-to-date */

  return(xp);
}


/*===========================================================================*
 *				put_inode				     *
 *===========================================================================*/
PUBLIC void put_inode(rip)
register struct inode *rip;	/* pointer to inode to be released */
{
/* The caller is no longer using this inode.  If no one else is using it either
 * write it back to the disk immediately.  If it has no links, truncate it and
 * return it to the pool of available inodes.
 */

  if (rip == NIL_INODE) return;	/* checking here is easier than in caller */
  if (--rip->i_count == 0) {	/* i_count == 0 means no one is using it now */
	if ((rip->i_nlinks & BYTE) == 0) {
		/* i_nlinks == 0 means free the inode. */
		truncate(rip);	/* return all the disk blocks */
		rip->i_mode = I_NOT_ALLOC;	/* clear I_TYPE field */
		free_inode(rip->i_dev, rip->i_num);
	}
	else if (rip->i_pipe == I_PIPE) truncate(rip);
	rip->i_pipe = NO_PIPE;  /* should always be cleared */

	if (rip->i_dirt == DIRTY) rw_inode(rip, WRITING);
  }
}

/*===========================================================================*
 *				alloc_inode				     *
 *===========================================================================*/
PUBLIC struct inode *alloc_inode(dev, bits)
dev_t dev;			/* device on which to allocate the inode */
mode_t bits;			/* mode of the inode */
{
/* Allocate a free inode on 'dev', and return a pointer to it. */

  register struct inode *rip;
  register struct super_block *sp;
  int major, minor;
  ino_t numb;
  bit_nr b;

  /* Acquire an inode from the bit map. */
  sp = get_super(dev);		/* get pointer to super_block */
  b=alloc_bit(sp->s_imap,(bit_nr)sp->s_ninodes+1, sp->s_imap_blocks,(bit_nr)0);
  if (b == NO_BIT) {
	err_code = ENFILE;
	major = (int) (sp->s_dev >> MAJOR) & BYTE;
	minor = (int) (sp->s_dev >> MINOR) & BYTE;
	printf("Out of i-nodes on %sdevice %d/%d\n",
		sp->s_dev == ROOT_DEV ? "root " : "", major, minor);
	return(NIL_INODE);
  }
  numb = (ino_t) b;

  /* Try to acquire a slot in the inode table. */
  if ( (rip = get_inode(NO_DEV, numb)) == NIL_INODE) {
	/* No inode table slots available.  Free the inode just allocated. */
	free_bit(sp->s_imap, b);
  } else {
	/* An inode slot is available. Put the inode just allocated into it. */
	rip->i_mode = bits;
	rip->i_nlinks = (nlink_t) 0;
	rip->i_uid = fp->fp_effuid;
	rip->i_gid = fp->fp_effgid;
	rip->i_dev = dev;	/* was provisionally set to NO_DEV */

	/* Fields not cleared already are cleared in wipe_inode().  They have
	 * been put there because truncate() needs to clear the same fields if
	 * the file happens to be open while being truncated.  It saves space
	 * not to repeat the code twice.
	 */
	wipe_inode(rip);
  }

  return(rip);
}

/*===========================================================================*
 *				wipe_inode				     *
 *===========================================================================*/
PUBLIC void wipe_inode(rip)
register struct inode *rip;	/* The inode to be erased. */
{
/* Erase some fields in the inode.  This function is called from alloc_inode()
 * when a new inode is to be allocated, and from truncate(), when an existing
 * inode is to be truncated.
 */

  register int i;

  rip->i_size = 0;
  rip->i_update = MTIME;	/* mark mtime for update later */
  rip->i_dirt = DIRTY;
  for (i = 0; i < NR_ZONE_NUMS; i++)
	rip->i_zone[i] = NO_ZONE;
}


/*===========================================================================*
 *				free_inode				     *
 *===========================================================================*/
PUBLIC void free_inode(dev, numb)
dev_t dev;			/* on which device is the inode */
ino_t numb;			/* number of inode to be freed */
{
/* Return an inode to the pool of unallocated inodes. */

  register struct super_block *sp;

  /* Locate the appropriate super_block. */
  sp = get_super(dev);
  free_bit(sp->s_imap, (bit_nr) numb);
}

/*===========================================================================*
 *				update_times				     *
 *===========================================================================*/
PUBLIC void update_times(rip)
register struct inode *rip;	/* pointer to inode to be read/written */
{
/* Various system calls are required by the standard to update atime, ctime,
 * or mtime.  Since updating a time requires sending a message to the clock
 * task--an expensive business--the times are marked for update by setting
 * bits in i_update.  When a stat, fstat, or sync is done, or an inode is 
 * released, update_times() may be called to actually fill in the times
 */

  time_t cur_time;

  cur_time = clock_time();
  if (rip->i_update & ATIME) rip->i_atime = cur_time;
  if (rip->i_update & CTIME) rip->i_ctime = cur_time;
  if (rip->i_update & MTIME) rip->i_mtime = cur_time;
  rip->i_update = 0;		/* they are all up-to-date now */
}


/*===========================================================================*
 *				rw_inode				     *
 *===========================================================================*/
PUBLIC void rw_inode(rip, rw_flag)
register struct inode *rip;	/* pointer to inode to be read/written */
int rw_flag;			/* READING or WRITING */
{
/* An entry in the inode table is to be copied to or from the disk. */

  register struct buf *bp;
  register d_inode *dip;
  register struct super_block *sp;
  block_nr b;

  /* Get the block where the inode resides. */
  sp = get_super(rip->i_dev);
  b = (block_nr) (rip->i_num - 1)/INODES_PER_BLOCK +
				sp->s_imap_blocks + sp->s_zmap_blocks + 2;
  bp = get_block(rip->i_dev, b, NORMAL);
  dip = bp->b_inode + (rip->i_num - 1) % INODES_PER_BLOCK;

  /* Do the read or write. */
  if (rw_flag == READING) {
	copy((char *)rip, (char *)dip, INODE_SIZE); /* copy to inode*/
  } else {
	if (rip->i_update) update_times(rip);	/* times need updating */
	copy((char *)dip, (char *)rip, INODE_SIZE); /* copy from inode */
	bp->b_dirt = DIRTY;
  }

  put_block(bp, INODE_BLOCK);
  rip->i_dirt = CLEAN;
}


/*===========================================================================*
 *				dup_inode				     *
 *===========================================================================*/
PUBLIC void dup_inode(ip)
struct inode *ip;		/* The inode to be duplicated. */
{
/* This routine is a simplified form of get_inode() for the case where
 * the inode pointer is already known.
 */

  ip->i_count++;
}


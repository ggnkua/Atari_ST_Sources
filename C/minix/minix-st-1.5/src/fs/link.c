/* This file handles the LINK and UNLINK system calls.  It also deals with
 * deallocating the storage used by a file when the last UNLINK is done to a
 * file and the blocks must be returned to the free block pool.
 *
 * The entry points into this file are
 *   do_link:	perform the LINK system call
 *   do_unlink:	perform the UNLINK and RMDIR system calls
 *   do_rename:	perform the RENAME system call
 *   truncate:	release all the blocks associated with an inode
 */

#include "fs.h"
#include <sys/stat.h>
#include <string.h>
#include <minix/callnr.h>
#include "buf.h"
#include "file.h"
#include "fproc.h"
#include "inode.h"
#include "param.h"

#define SAME 1000
PRIVATE char dot2[NAME_MAX] =  "..\0\0\0\0\0\0\0\0\0\0\0";

/*===========================================================================*
 *				do_link					     *
 *===========================================================================*/
PUBLIC int do_link()
{
/* Perform the link(name1, name2) system call. */

  register struct inode *ip, *rip;
  register int r;
  char string[NAME_MAX];
  struct inode *new_ip;

  /* See if 'name' (file to be linked) exists. */
  if (fetch_name(name1, name1_length, M1) != OK) return(err_code);
  if ( (rip = eat_path(user_path)) == NIL_INODE) return(err_code);

  /* Check to see if the file has maximum number of links already. */
  r = OK;
  if ( (rip->i_nlinks & BYTE) == LINK_MAX) r = EMLINK;

  /* Only super_user may link to directories. */
  if (r == OK)
	if ( (rip->i_mode & I_TYPE) == I_DIRECTORY && !super_user) r = EPERM;

  /* If error with 'name', return the inode. */
  if (r != OK) {
	put_inode(rip);
	return(r);
  }

  /* Does the final directory of 'name2' exist? */
  if (fetch_name(name2, name2_length, M1) != OK) {
	put_inode(rip);
	return(err_code);
  }
  if ( (ip = last_dir(user_path, string)) == NIL_INODE) r = err_code;

  /* If 'name2' exists in full (even if no space) set 'r' to error. */
  if (r == OK) {
	if ( (new_ip = advance(ip, string)) == NIL_INODE) {
		r = err_code;
		if (r == ENOENT) r = OK;
	} else {
		put_inode(new_ip);
		r = EEXIST;
	}
  }

  /* Check for links across devices. */
  if (r == OK)
	if (rip->i_dev != ip->i_dev) r = EXDEV;

  /* Try to link. */
  if (r == OK)
	r = search_dir(ip, string, &rip->i_num, ENTER);

  /* If success, register the linking. */
  if (r == OK) {
	rip->i_nlinks++;
	rip->i_dirt = DIRTY;
  }

  /* Done.  Release both inodes. */
  put_inode(rip);
  put_inode(ip);
  return(r);
}


/*===========================================================================*
 *				do_unlink				     *
 *===========================================================================*/
PUBLIC int do_unlink()
{
/* Perform the unlink(name) or rmdir(name) system call. The code for these two
 * is almost the same.  They differ only in some condition testing.  Unlink()
 * may be used by the superuser to do dangerous things; rmdir() may not.
 */

  register struct inode *rip;
  struct inode *rldirp;
  register struct fproc *rfp;
  int r, r1;
  ino_t numb;
  mode_t old_mode;
  uid_t old_uid;
  char string[NAME_MAX];

  /* Get the last directory in the path. */
  if (fetch_name(name, name_length, M3) != OK) return(err_code);
  if ( (rldirp = last_dir(user_path, string)) == NIL_INODE)
	return(err_code);

  /* The last directory exists.  Does the file also exist? */
  r = OK;
  if ( (rip = advance(rldirp, string)) == NIL_INODE) r = err_code;

  /* If error, return inode. */
  if (r != OK) {
	put_inode(rldirp);
	return(r);
  }
  old_mode = rip->i_mode;	/* save mode; it must be fudged for . and .. */
  old_uid =  rip->i_uid;	/* save uid;  it must be fudged for . and .. */

  /* Now test if the call is allowed, separately for unlink() and rmdir(). */
  if (fs_call == UNLINK) {
	/* Only the su may unlink directories, but the su can unlink any dir.*/
	if ( (rip->i_mode & I_TYPE) == I_DIRECTORY && !super_user) r = EPERM;

	/* Actually try to unlink the file; fails if parent is mode 0 etc. */
	if (r == OK) r = search_dir(rldirp, string, (ino_t *) 0, DELETE);
  } else {
	/* The call is rmdir().  Five conditions have to met for this call:
	 * 	- The file must be a directory
	 *	- The directory must be empty (except for . and ..)
	 *	- It must not be /
 	 *	- The path must not end in . or ..
	 *	- The directory must not be anybody's working directory
	 */
	if ( (rip->i_mode & I_TYPE) != I_DIRECTORY) r = ENOTDIR;
	if (search_dir(rip, "", &numb, LOOK_UP) == OK) r = ENOTEMPTY;
	if (strcmp(user_path, "/") == 0) r = EPERM;	/* can't remove root */
	if (strcmp(string, ".") == 0 || strcmp(string, "..") == 0) r = EPERM;
	for (rfp = &fproc[INIT_PROC_NR + 1]; rfp < &fproc[NR_PROCS]; rfp++) {
		if (rfp->fp_workdir == rip || rfp->fp_rootdir == rip) {
			r = EBUSY;	/* can't remove anybody's working dir*/
			break;
		}
	}

	/* Actually try to unlink the file; fails if parent is mode 0 etc. */
	if (r == OK) r = search_dir(rldirp, string, (ino_t *) 0, DELETE);

	/* If all the conditions have been met, remove . and .. from the dir.
	 * If the directory is not searchable, it will not be possible to
 	 * unlink . and .. even though this is legal, so change the mode.
	 */
	if (r == OK) {
		rip->i_mode |= S_IRWXU;	/* turn on all the owner bits */
		rip->i_uid = fp->fp_effuid;	/* may not fail due to uid */
		if ( (r = search_dir(rip, ".",  (ino_t *) 0, DELETE)) == OK)
			rip->i_nlinks --;	/* . pts to dir being removed*/
		if ( (r1 = search_dir(rip, "..", (ino_t *) 0, DELETE)) == OK)
			rldirp->i_nlinks--;	/* .. points to parent dir */
		rip->i_dirt = DIRTY;
		rldirp->i_dirt = DIRTY;
		if (r1 != OK) r = r1;
		rip->i_mode = old_mode;	/* restore the old mode */
		rip->i_uid = old_uid;
	}
  }

  if (r == OK) {
	rip->i_nlinks--;
	rip->i_dirt = DIRTY;
  }

  /* If unlink was possible, it has been done, otherwise it has not. */
  rip->i_mode = old_mode;	/* restore mode in case it has been changed */
  put_inode(rip);
  put_inode(rldirp);
  return(r);
}


/*===========================================================================*
 *				do_rename				     *
 *===========================================================================*/
PUBLIC int do_rename()
{
/* Perform the rename(name1, name2) system call. */

  struct inode *old_dirp, *old_ip;	/* ptrs to old dir, file inodes */
  struct inode *new_dirp, *new_ip;	/* ptrs to new dir, file inodes */
  int r = OK;				/* error flag; initially no error */
  int odir, ndir;			/* TRUE iff {old|new} file is dir */
  char string[NAME_MAX+1], old_string[NAME_MAX+1];
  char old_name[PATH_MAX+1];
  ino_t numb;
  
  /* See if 'name1' (existing file) exists.  Get dir and file inodes. */
  if (fetch_name(name1, name1_length, M1) != OK) return(err_code);
  if ( (old_dirp = last_dir(user_path, string)) == NIL_INODE) return(err_code);

  if ( (old_ip = advance(old_dirp, string)) == NIL_INODE) r = err_code;
  strcpy(old_name, user_path);	/* save the old name here */
  strcpy(old_string, string);	/* save last component of the name here */

  /* See if 'name2' (new name) exists.  Get dir and file inodes. */
  if (fetch_name(name2, name2_length, M1) != OK) r = err_code;
  if ( (new_dirp = last_dir(user_path, string)) == NIL_INODE) r = err_code;
  new_ip = advance(new_dirp, string);	/* not required to exist */

  /* If it is ok, check for a variety of possible errors. */
  if (r == OK) {
	/* The old path must not be a prefix of the new one. */
	if (strncmp(old_name, user_path, strlen(old_name)) == 0) r = EINVAL;

	/* The old path must not be . or .. */
	if (strcmp(old_name, ".")==0 || strcmp(old_name, "..")==0) r = EINVAL;

	/* Both directories must be on the same device. */
	if (old_dirp->i_dev != new_dirp->i_dev) r = EXDEV;

	/* Both directories must be writable and searchable. */
	if (forbidden(old_dirp, W_BIT | X_BIT, 0)) r = EACCES;
	if (forbidden(new_dirp, W_BIT | X_BIT, 0)) r = EACCES;

	/* Some tests apply only if the new path exists. */
	odir = S_ISDIR(old_ip->i_mode);	/* TRUE iff old file is dir */
	if (new_ip != NIL_INODE) {
		ndir = S_ISDIR(new_ip->i_mode);	/* TRUE iff new file is dir */
		if (odir == TRUE && ndir == FALSE) r = ENOTDIR;
		if (odir == FALSE && ndir == TRUE) r = EISDIR;
		if (old_ip->i_num == new_ip->i_num) r = SAME; /* old=new */
		if (ndir == TRUE) {
			if (search_dir(new_ip, "", &numb, LOOK_UP) == OK)
				r = ENOTEMPTY;
		}
	}
  }

  /* The rename will probably work.  The only thing that could still go wrong
   * is being unable to make the new directory entry (directory has to grow by
   * one block and cannot because the disk is completely full).  Two cases can
   * be distinguished now, depending on whether the 'new' entry exists or not.
   *   Case 1 ('new' entry does not exist): create a dir entry for it.
   *   Case 2 ('new' entry exists): update inum in existing dir entry.
   */
  if (r == OK) {
	/* For both cases we need the number of the old inode entry. */
	numb = old_ip->i_num;		/* inode number of old file */

	/* For case 1, make new entry; for case 2, delete then enter. */
	if (new_ip == NIL_INODE) {
		/* There is no entry for 'new'.  Make one.*/
		r = search_dir(new_dirp, string, &numb, ENTER);	/* can fail */
		if (r == OK && odir) {
			new_dirp->i_nlinks++;  /* new entry created */
			new_dirp->i_dirt = DIRTY;
		}
	} else {
		/* There is already an entry for 'new'.  Slot can be reused. */
		(void) search_dir(new_dirp, string, (ino_t *) 0, DELETE);
		(void) search_dir(new_dirp, string, &numb, ENTER); 
		new_ip->i_nlinks--;	/* entry deleted from parent's dir */
		new_ip->i_dirt = DIRTY;
		if (odir) new_ip->i_nlinks--;	/* new_ip's .  is going away */
	}

	/* Delete the directory entry for 'old', but do not change link ct. */
	if (r == OK) {
		if (odir) {
			old_dirp->i_nlinks--;	/* old_ip's .. is going away */
			old_dirp->i_dirt = DIRTY;
			numb = new_dirp->i_num;
			(void) search_dir(old_ip, "..", (ino_t *) 0, DELETE);
			(void) search_dir(old_ip, dot2, &numb ,ENTER);
		}
		(void) search_dir(old_dirp, old_string, (ino_t *)0, DELETE);

		/* Mark times for updating later. */
		old_dirp->i_update = CTIME | MTIME;
		new_dirp->i_update = CTIME | MTIME;
	}
  }	
	
  /* Release the inodes. */
  put_inode(old_dirp);
  put_inode(old_ip);
  put_inode(new_dirp);
  put_inode(new_ip);
  return(r == SAME ? OK : r);
}

/*===========================================================================*
 *				truncate				     *
 *===========================================================================*/
PUBLIC void truncate(rip)
register struct inode *rip;	/* pointer to inode to be truncated */
{
/* Remove all the zones from the inode 'rip' and mark it dirty. */

  register block_nr b;
  register zone_nr z, *iz;
  off_t position;
  zone_type zone_size;
  int scale, file_type, waspipe;
  struct buf *bp;
  dev_t dev;

  file_type = rip->i_mode & S_IFMT;	/* check to see if file is special */
  if (file_type == S_IFCHR || file_type == S_IFBLK) return;
  dev = rip->i_dev;		/* device on which inode resides */
  scale = scale_factor(rip);
  zone_size = (zone_type) BLOCK_SIZE << scale;
  if (waspipe = (rip->i_pipe == I_PIPE))
	rip->i_size = PIPE_SIZE;	/* pipes can shrink */

  /* Step through the file a zone at a time, finding and freeing the zones. */
  for (position = 0; position < rip->i_size; position += zone_size) {
	if ( (b = read_map(rip, position)) != NO_BLOCK) {
		z = (zone_nr) b >> scale;
		free_zone(dev, z);
	}
  }

  /* All the data zones have been freed.  Now free the indirect zones. */
  free_zone(dev, rip->i_zone[NR_DZONE_NUM]);	/* single indirect zone */
  if ( (z = rip->i_zone[NR_DZONE_NUM+1]) != NO_ZONE) {
	b = (block_nr) z << scale;
	bp = get_block(dev, b, NORMAL);	/* get double indirect zone */
	for (iz = &bp->b_ind[0]; iz < &bp->b_ind[NR_INDIRECTS]; iz++) {
		free_zone(dev, *iz);
	}

	/* Now free the double indirect zone itself. */
	put_block(bp, INDIRECT_BLOCK);
	free_zone(dev, z);
  }

  /* Leave zone numbers for de(1) to recover file after an unlink(2).  */
  if (waspipe)
	wipe_inode(rip);	/* clear out inode for pipes */
  rip->i_dirt = DIRTY;
}

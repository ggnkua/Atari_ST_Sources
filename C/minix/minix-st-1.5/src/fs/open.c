/* This file contains the procedures for creating, opening, closing, and
 * seeking on files.
 *
 * The entry points into this file are
 *   do_creat:	perform the CREAT system call
 *   do_mknod:	perform the MKNOD system call
 *   do_open:	perform the OPEN system call
 *   do_close:	perform the CLOSE system call
 *   do_lseek:  perform the LSEEK system call
 *   do_mkdir:	perform the MKDIR system call
 */

#include "fs.h"
#include <minix/callnr.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "buf.h"
#include "file.h"
#include "fproc.h"
#include "inode.h"
#include "param.h"

PRIVATE char mode_map[] = {R_BIT, W_BIT, R_BIT|W_BIT, 0};
PRIVATE char dot1[NAME_MAX] = ".\0\0\0\0\0\0\0\0\0\0\0\0";
PRIVATE char dot2[NAME_MAX] =  "..\0\0\0\0\0\0\0\0\0\0\0";

FORWARD int common_open();
FORWARD struct inode *new_node();
FORWARD int pipe_open();

/*===========================================================================*
 *				do_creat				     *
 *===========================================================================*/
PUBLIC int do_creat()
{
/* Perform the creat(name, mode) system call. */
  /* get name */
  if (fetch_name(name, name_length, M3) != OK) return(err_code);
  return common_open(O_WRONLY | O_CREAT | O_TRUNC, (mode_t) mode);
}


/*===========================================================================*
 *				do_mknod				     *
 *===========================================================================*/
PUBLIC int do_mknod()
{
/* Perform the mknod(name, mode, addr) system call. */

  register mode_t bits;
  unsigned int size;

  /* Only the super_user may make nodes other than fifos. */
  if (!super_user && ((mode & I_TYPE) != I_NAMED_PIPE)) return(EPERM);
  if (fetch_name(name1, name1_length, M1) != OK) return(err_code);
  bits = (mode & I_TYPE) | (mode & ALL_MODES & fp->fp_umask);
  size = (unsigned int) name2;
  put_inode(new_node(user_path, bits, (zone_nr) addr), (off_t)size*BLOCK_SIZE);
  return(err_code);
}


/*===========================================================================*
 *				new_node				     *
 *===========================================================================*/
PRIVATE struct inode *new_node(path, bits, z0, lsize)
char *path;			/* pointer to path name */
mode_t bits;			/* mode of the new inode */
zone_nr z0;			/* zone number 0 for new inode */
off_t lsize;			/* size of the special file */
{
/* New_node() is called by common_open(), do_mknod(), and do_mkdir().  
 * In all cases it allocates a new inode, makes a directory entry for it on 
 * the path 'path', and initializes it.  It returns a pointer to the inode if 
 * it can do this; otherwise it returns NIL_INODE.  It always sets 'err_code'
 * to an appropriate value (OK or an error code).
 */

  register struct inode *rlast_dir_ptr, *rip;
  register int r;
  char string[NAME_MAX];

  /* See if the path can be opened down to the last directory. */
  if ((rlast_dir_ptr = last_dir(path, string)) == NIL_INODE) return(NIL_INODE);

  /* The final directory is accessible. Get final component of the path. */
  rip = advance(rlast_dir_ptr, string);
  if ( rip == NIL_INODE && err_code == ENOENT) {
	/* Last path component does not exist.  Make new directory entry. */
	if ( (rip = alloc_inode(rlast_dir_ptr->i_dev, bits)) == NIL_INODE) {
		/* Can't creat new inode: out of inodes. */
		put_inode(rlast_dir_ptr);
		return(NIL_INODE);
	}

	/* Force inode to the disk before making directory entry to make
	 * the system more robust in the face of a crash: an inode with
	 * no directory entry is much better than the opposite.
	 */
	rip->i_nlinks++;
	rip->i_zone[0] = z0;		/* major/minor device numbers */
	rip->i_size = lsize;		/* size (needed for block specials) */
	rw_inode(rip, WRITING);		/* force inode to disk now */

	/* New inode acquired.  Try to make directory entry. */
	if ((r = search_dir(rlast_dir_ptr, string, &rip->i_num,ENTER)) != OK) {
		put_inode(rlast_dir_ptr);
		rip->i_nlinks--;	/* pity, have to free disk inode */
		rip->i_dirt = DIRTY;	/* dirty inodes are written out */
		put_inode(rip);	/* this call frees the inode */
		err_code = r;
		return(NIL_INODE);
	}

  } else {
	/* Either last component exists, or there is some problem. */
	if (rip != NIL_INODE)
		r = EEXIST;
	else
		r = err_code;
  }

  /* Return the directory inode and exit. */
  put_inode(rlast_dir_ptr);
  err_code = r;
  return(rip);
}


/*===========================================================================*
 *				do_open					     *
 *===========================================================================*/
PUBLIC int do_open()
{
/* Perform the open(name, flags,...) system call. */

  int create_mode = 0;
  int r;

  /* If O_CREAT is set, open has three parameters, otherwise two. */
  if (mode & O_CREAT) {
	create_mode = c_mode;	
	r = fetch_name(c_name, name1_length, M1);
  } else {
	r = fetch_name(name, name_length, M3);
  }

  if (r != OK) return(err_code); /* name was bad */
  return common_open(mode, (mode_t) create_mode);
}


/*===========================================================================*
 *				common_open				     *
 *===========================================================================*/
PRIVATE int common_open(oflags, omode)
register int oflags;
mode_t omode;
{
/* Common code from do_creat and do_open. */

  register struct inode *rip;
  register int r;
  register mode_t bits;
  struct filp *fil_ptr;
  dev_t dev;
  int nonblocking, exist = TRUE;

  /* Remap the bottom two bits of oflags. */
  bits = (mode_t) mode_map[oflags & O_ACCMODE];

  /* See if file descriptor and filp slots are available. */
  if ( (r = get_fd(0, bits, &fd, &fil_ptr)) != OK) return(r);

  /* If O_CREATE is set, try to make the file. */ 
  if (oflags & O_CREAT) {
  	/* Create a new inode by calling new_node(). */
        omode = I_REGULAR | (omode & ALL_MODES & fp->fp_umask);
    	rip = new_node(user_path, omode, NO_ZONE, (off_t) 0);
    	r = err_code;
    	if (r == OK) exist = FALSE;      /* we just created the file */
	else if (r != EEXIST) return(r); /* other error */
	else exist = !(oflags & O_EXCL); /* file exists, if the O_EXCL 
					    flag is set this is an error */
  } else {
	 /* Scan path name. */
    	if ( (rip = eat_path(user_path)) == NIL_INODE) return(err_code);
  }


  /* Only do the normal open code if we didn't just create the file. */
  if (exist) {

#if 0	/* I doubt this, but what does POSIX say?
	 * I fixed the test anyway, to go with fixing the O_TRUNC test.
	 * BDE
	 */

  	/* O_TRUNC and O_CREAT implies W_BIT */
	if ((oflags & (O_TRUNC | O_CREAT)) == (O_CREAT | O_TRUNC))
		bits |= W_BIT;
#endif

  	/* Check protections. */
  	if ((r = forbidden(rip, bits, 0)) == OK) {
  		/* Opening reg. files directories and special files differ. */
	  	switch (rip->i_mode & I_TYPE) {
    		   case I_REGULAR: 
			/* Truncate regular file if O_TRUNC. */
			if (oflags & O_TRUNC) {
				truncate(rip);
				wipe_inode(rip);
			}
			break;
 
	    	   case I_DIRECTORY: 
			/* Directories may be read but not written. */
			r = (bits & W_BIT ? EISDIR : OK);
			break;

	     	   case I_CHAR_SPECIAL:
     		   case I_BLOCK_SPECIAL:
			/* Invoke the driver for special processing. */
			dev = (dev_t) rip->i_zone[0];
			nonblocking = oflags & O_NONBLOCK;
			r = dev_open(rip, (int) bits, nonblocking);
			break;

		   case I_NAMED_PIPE:
			r = pipe_open(rip, bits, oflags);
			break;
 		}
  	}
  }

  /* If error, release inode. */
  if (r != OK) {
	put_inode(rip);
	return(r);
  }
  
  /* Claim the file descriptor and filp slot and fill them in. */
  fp->fp_filp[fd] = fil_ptr;
  fil_ptr->filp_count = 1;
  fil_ptr->filp_ino = rip;
  fil_ptr->filp_flags = oflags;
  return(fd);
}

/*===========================================================================*
 *				pipe_open				     *
 *===========================================================================*/
PRIVATE int pipe_open(rip, bits, oflags)
register struct inode *rip;
register mode_t bits;
register int oflags;
{
/*  This function is called from do_creat and do_open, it checks if
 *  there is at least one reader/writer pair for the pipe, if not
 *  it suspends the caller, otherwise it revives all other blocked
 *  processes hanging on the pipe.
 */

  if (find_filp(rip, bits & W_BIT ? R_BIT : W_BIT) == NIL_FILP) { 
	if (oflags & O_NONBLOCK) return(bits & W_BIT ? ENXIO : OK);
	suspend(XOPEN); /* suspend caller */
  } else if (susp_count > 0) {/* revive blocked processes */
	release(rip, OPEN, susp_count);
	release(rip, CREAT, susp_count);
  }
  rip->i_pipe = I_PIPE; 

  return OK ;
}


/*===========================================================================*
 *				do_close				     *
 *===========================================================================*/
PUBLIC int do_close()
{
/* Perform the close(fd) system call. */

  register struct filp *rfilp;
  register struct inode *rip;
  int rw;
  int mode_word;

  /* First locate the inode that belongs to the file descriptor. */
  if ( (rfilp = get_filp(fd)) == NIL_FILP) return(err_code);
  rip = rfilp->filp_ino;	/* 'rip' points to the inode */

  /* Check to see if the file is special. */
  mode_word = rip->i_mode & I_TYPE;
  if (mode_word == I_CHAR_SPECIAL || mode_word == I_BLOCK_SPECIAL) {
	if (mode_word == I_BLOCK_SPECIAL)  {
		/* Invalidate cache entries unless special is mounted or ROOT*/
		do_sync();	/* purge cache */
		if (mounted(rip) == FALSE) invalidate((dev_t) rip->i_zone[0]);
	}
	if (rfilp->filp_count == 1) dev_close(rip);	/* about to become 0 */
  }

  /* If the inode being closed is a pipe, release everyone hanging on it. */
  if (rip->i_pipe) {
	rw = (rfilp->filp_mode & R_BIT ? WRITE : READ);
	release(rip, rw, NR_PROCS);
  }

  /* If a write has been done, the inode is already marked as DIRTY. */
  if (--rfilp->filp_count == 0) put_inode(rip);

  fp->fp_filp[fd] = NIL_FILP;
  return(OK);
}


/*===========================================================================*
 *				do_lseek				     *
 *===========================================================================*/
PUBLIC int do_lseek()
{
/* Perform the lseek(ls_fd, offset, whence) system call. */

  register struct filp *rfilp;
  register off_t pos;

  /* Check to see if the file descriptor is valid. */
  if ( (rfilp = get_filp(ls_fd)) == NIL_FILP) return(err_code);

  /* No lseek on pipes. */
  if (rfilp->filp_ino->i_pipe == I_PIPE) return(ESPIPE);

  /* The value of 'whence' determines the algorithm to use. */
  switch(whence) {
	case 0:	pos = offset;	break;
	case 1: pos = rfilp->filp_pos + offset;	break;
	case 2: pos = rfilp->filp_ino->i_size + offset;	break;
	default: return(EINVAL);
  }

  /* Check if pos is invalid. */
  if (pos < 0 || pos > MAX_FILE_POS) return(EINVAL);

  if (pos != rfilp->filp_pos)
	rfilp->filp_ino->i_seek = ISEEK;	/* inhibit read ahead */
  rfilp->filp_pos = pos;

  reply_l1 = pos;		/* insert the long into the output message */
  return(OK);
}


/*===========================================================================*
 *				do_mkdir				     *
 *===========================================================================*/
PUBLIC int do_mkdir()
{
/* Perform the mkdir(name, mode) system call. */

  int r1, r2;			/* status codes */
  ino_t dot, dotdot;		/* inode numbers for . and .. */
  mode_t bits;			/* mode bits for the new inode */
  char string[NAME_MAX];	/* last component of the new dir's path name */
  register struct inode *rip, *ldirp;

  /* First make the inode. If that fails, return error code. */
  if (fetch_name(name1, name1_length, M1) != OK) return(err_code);
  bits = S_IFDIR | (mode & RWX_MODES & fp->fp_umask);
  rip = new_node(user_path, bits, (zone_nr) 0, (off_t) 0);
  if (rip == NIL_INODE) return(err_code);
  if (err_code == EEXIST) {
	put_inode(rip);		/* can't make dir: it already exists */
	return(err_code);
  }

  /* Get the inode numbers for . and .. to enter in the directory. */
  ldirp = last_dir(user_path, string);	/* pointer to new dir's parent */
  dotdot = ldirp->i_num;	/* parent's inode number */
  dot = rip->i_num;		/* inode number of the new dir itself */

  /* Now make dir entries for . and .. unless the disk is completely full. */
  rip->i_mode |= S_IRWXU;	/* make sure . and .. can be entered */
  r1 = search_dir(rip, dot1, &dot, ENTER);	/* enter . in the new dir */
  r2 = search_dir(rip, dot2, &dotdot, ENTER);	/* enter .. in the new dir */
  rip->i_mode = bits;		/* now set mode correctly */

  /* If both . and .. were successfully entered, increment the link counts. */
  if (r1 == OK && r2 == OK) {
	/* Normal case.  It was possible to enter . and .. in the new dir. */
	rip->i_nlinks++;	/* this accounts for . */
	ldirp->i_nlinks++;	/* this accounts for .. */
	ldirp->i_dirt = DIRTY;	/* mark parent's inode as dirty */
  } else {
	/* It was not possible to enter . or .. probably disk was full. */
	(void) search_dir(rip, ".",  (ino_t *) 0, DELETE);
	(void) search_dir(rip, "..", (ino_t *) 0, DELETE);
	(void) search_dir(ldirp, string, (ino_t *) 0, DELETE);
	rip->i_nlinks--;	/* undo the increment done in new_node() */
  }
  rip->i_dirt = DIRTY;		/* either way, i_nlinks has changed */

  put_inode(ldirp);		/* return the inode of the parent dir */
  put_inode(rip);		/* return the inode of the newly made dir */
  return(err_code);		/* new_node() always sets 'err_code' */
}

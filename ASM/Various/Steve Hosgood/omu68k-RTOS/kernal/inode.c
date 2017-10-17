/*
 * Inode.c - Manipulations of incore inode copies.
 *
 */

# include	"../include/param.h"
# include       <sys/dir.h>
# include       "../include/stat.h"
# include       "../include/file.h"
# include       "../include/inode.h"
# include       "../include/dev.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/mount.h"
# include	<errno.h>

/*
 *	Mknod()		Makes special file entry
 */
mknod(name, mode, addr)
int mode,addr;
char *name;
{
	int status;
	struct inode *i_ptr;

	status = -1;
	/* Only for super_user */
	if (!cur_proc->euid){
		if (i_ptr = namlock(name, CREATE, NULLIPTR)) {
			if (i_ptr->i_mode == 1) {
				/* set attributes masked by umask */
				i_ptr->i_mode = mode & ~(cur_proc->umask);
				i_ptr->i_addr[0] = addr;
				status = 0;
			}
			else
				/* node already there */
				status = -1;

			freeiptr(i_ptr);
		}
	}
	else error(EPERM);

	return status;
}

/*
 *	Mkmod()		Makes special module device entry
 */
mkmod(name1, mode, dev, name2)
int mode, dev;
char *name1, *name2;
{
	int	status;
	struct	inode *i_ptr1, *i_ptr2;

	status = -1;

	/* Only for super_user */
	if(!cur_proc->euid){
		/* Create node if possible */
		if(i_ptr1 = namlock(name1, CREATE, NULLIPTR)){
			if(i_ptr1->i_mode == 1){
				/* If Newly created node, get module inode */
				if(i_ptr2 = namlock(name2, SEARCH, NULLIPTR)){
					/* set attributes masked by umask */
					i_ptr1->i_mode = mode & ~(cur_proc->umask);
					i_ptr1->i_addr[0] = dev;
					i_ptr1->i_addr[1] = i_ptr2->i_ino;
					status = 0;
					freeiptr(i_ptr2);
				}
				/* Module named dose not exist */
				else status = -1;
			}
			/* node already there */
			else status = -1;

			freeiptr(i_ptr1);
		}
	}
	else error(EPERM);

	return status;
}

chdir(path)
char *path;
{
	struct inode *iptr;


	if (iptr = namlock(path, SEARCH, NULLIPTR)) {


		/* check this too is a directory */
		if (isdir(iptr)) {
			/* ok - allow change */
			if (cur_proc->wd)
				freeiptr(cur_proc->wd);
			cur_proc->wd = iptr;
			return 0;
		}

		/* not directory - free locked inode */
		freeiptr(iptr);
	}

	return -1;
}

/*
 * Link - create a new link to a file.
 */
link(name1, name2)
char *name1, *name2;
{
	int status;
	struct inode *iptr;

	status = -1;
	if (iptr = namlock(name1, SEARCH, NULLIPTR)) {
		if (namlock(name2, MKLINK, iptr)) {
			/* sucessful link creation */
			iptr->i_nlink++;
			iptr->i_flag |= ICHG;
			status = 0;
		}

		freeiptr(iptr);
	}

	return status;
}

/*
 * Unlink - remove directory entry.
 */
unlink(name)
char *name;
{
	struct inode *iptr;

	if (iptr = namlock(name, DELETE, NULLIPTR)) {
		/* decrement link count */
		iptr->i_nlink--;
		iptr->i_flag |= ICHG;
		freeiptr(iptr);
		return 0;
	}

	return -1;
}

/*
 * Chmod - changes mode of file with given name.
 */
chmod(name, mode)
int mode;
char *name;
{
	struct inode *iptr;

	if (iptr = namlock(name, SEARCH, NULLIPTR)) {
		/* Check if root or owner of file */
 		if((!cur_proc->euid) || (iptr->i_uid == cur_proc->euid)){
			iptr->i_mode &= 0170000;
			iptr->i_mode |= mode & 07777;
			/* Only super-user can set swap bit */
			if(cur_proc->euid) iptr->i_mode &= ~S_ISVTX;
			iptr->i_flag |= ICHG;
			freeiptr(iptr);
			return 0;
		}
	}

	return -1;
}

/*
 * Utime - changes times of file with given name.
 */
utime(name, timep)
char	*name;
time_t	timep[2];
{
	struct inode *iptr;

	if (iptr = namlock(name, SEARCH, NULLIPTR)) {
		/* Check if root or owner of file */
 		if((!cur_proc->euid) || (iptr->i_uid == cur_proc->euid)){
			iptr->i_atime = timep[0];
			iptr->i_mtime = timep[1];
			iptr->i_flag |= ICHG;
			freeiptr(iptr);
			return 0;
		}
	}
	return -1;
}

/*
 * Namlock, given a name, search directories and return a pointer to a
 *              locked inode (or NULL) corresponding to the name.
 *              Mode may be 'SEARCH', 'CREATE' or 'DELETE': the directory
 *              may therefore get modified.
 */
struct inode *
namlock(name, mode, iptr)
char *name;
int mode;
struct inode *iptr;
{
	char *cptr, ch;
	struct inode *cur_i;

	/* if name starts with '/' start at root */


	if (*name == '/') {
		cur_i = getiptr(&bdevsw[RDEV_MAJ], RDEV_MIN, ROOTINO);
		name++;
	}
	else if (*name == ':' ) {
		cur_i = 0;
		/* allow funnies to permit use with no /dev directory */
		if (!strcmp(name+1, "console")) {
			/* non standard alias for console dev [C 0 0] */
			cur_i = lockfree(&bdevsw[RDEV_MAJ], RDEV_MIN);
			cur_i->i_mode = S_IFCHR;
			cur_i->i_addr[0] = 0;
		}
		else if (!strcmp(name+1, "fd0")) {
			/* non standard alias for root dev [B 0 0] */
			cur_i = lockfree(&bdevsw[RDEV_MAJ], RDEV_MIN);
			cur_i->i_mode = S_IFBLK;
			cur_i->i_addr[0] = 0;
		}

		return cur_i;
	}
	else
		/* use current directory */
		cur_i = relock(cur_proc->wd);

	/* Loop while some of 'name' exists granted, reading directories */
	while (cur_i){

		/* scrap spare '/' s */
		while (*name == '/')
			name++;

		/* check name still exists */
		if (*name == '\0')
			break;

		/* skip to next delimiter and make null */
		for (cptr = name; ((ch = *cptr) && ch != '/'); cptr++);

		/* cptr points to delimiter, 'ch' is delimiter */
		*cptr = '\0';
		cur_i = srchdir(name, cur_i, (ch == '\0')? mode: SEARCH, iptr);

		/* if delimiter was '/' carry on, else finish */
		if (ch == '/') {
			*cptr++ = '/';
			name = cptr;
		}
		else
			break;
	}

	return cur_i;
}

/*
 * Srchdir - a pointer to a directory inode is reqd. Mode may be:-
 *      CREATE - look for name, if there, truncate file, else make entry and
 *              get blank inode to match.
 *      DELETE - expect name to exist, lock inode, remove entry in dir.
 *      SEARCH - just search directory, lock inode if present, else return 0.
 *      MKLINK - look for name, error if found, else create name pointing
 *              to locked inode 'l_iptr'.
 *	EOPEN  - Same as search except set inode for single buffer opeation
 *		when found.
 *
 *      In all cases, 0 return is a failure.
 *	In all sucessful cases, a pointer to a locked inode is returned.
 *      In all cases the directory inode pointer is unlocked.
 */
struct inode *
srchdir(name, iptr, mode, l_iptr)
char *name;
struct inode *iptr, *l_iptr;
int mode;
{
	int freeslot, nami, cur_slot, update, mounted;
	struct direct dbuf;
	struct file file;
	struct inode *c_iptr;


	mounted = update = nami = 0;
	freeslot = -1;
	cur_slot = 0;
	file.f_mode = 0;	/* Std file access */

	if (isdir(iptr)) {
		if (strcmp(name, "..") == 0) {
			/* '..' may be on a different device */
			while (iptr->i_ino == ROOTINO && (c_iptr = m_volparent(iptr)))
				/* it was, so look for ".." on parent dir */
				iptr = c_iptr;
		}

		/* Check if directory accessable */
		if(!i_access(iptr, IAEXEC)){
			/* If not return error */
			c_iptr = NULLIPTR;
			freeiptr(iptr);
			return c_iptr;
		}

		/* Search directory - possibly 'under' mounted volume */
		if (f_open(&file, relock(iptr), READABLE) != -1) {

			while (1) {
				/* stop if directory exhausted */
				/* marginally quicker to use b_read not f_read etc */
				if (b_read(&file, &dbuf, sizeof dbuf) != sizeof dbuf) {

					/* if possible, position at empty slot */
					if (freeslot != -1)
						b_seek(&file, ( long ) freeslot, 0);
					break;
				}

				/* see if slot occupied */
				if (dbuf.d_ino) {
					/* stop if name matches */
					if (strncmp(dbuf.d_name, name, DIRSIZ) == 0) {
						nami = dbuf.d_ino;
						b_seek(&file, ( long ) cur_slot, 0);
						break;
					}
				}
				else {
					/* remember location of clear slot */
					if (freeslot == -1)
						freeslot = cur_slot;
				}

				/* note new position in directory and try again */
				cur_slot += sizeof dbuf;
			}

			/* may be positioned by wanted slot or a clear one */
			if (nami) {
				/* get inode for file 'nami' - maybe mounted */
				c_iptr = m_getiptr(iptr, nami, &mounted);

				/* at wanted slot */
				switch (mode) {
				case DELETE:
					if (mounted) {
						freeiptr(c_iptr);
						c_iptr = NULLIPTR;
					}
					else {
						dbuf.d_ino = 0;
						update = 1;
					}

					break;

				case MKLINK:
					/* illegal if name exists */
					freeiptr(c_iptr);
					c_iptr = NULLIPTR;
					/* fall thru' */

				case CREATE:
				case SEARCH:
					break;

				case EOPEN:
					/* Sets inode for one buffer operation*/
					c_iptr->i_flag |= IONEBUF;
					break;
				}
			}
			else {
				/* positioned by free slot */
				switch (mode) {
				case DELETE:
				case SEARCH:
				case EOPEN:
					/* error if name doesn't exist */
					c_iptr = NULLIPTR;
					break;

				case MKLINK:
					/* must ban cross-dev links (later)
					 * Later has arived! TB.
					 */
					if((iptr->i_mdev == l_iptr->i_mdev) &&
						(iptr->i_minor == l_iptr->i_minor)){ 
						dbuf.d_ino = l_iptr->i_ino;
						c_iptr = l_iptr;
						update = 1;
					}
					else{
						c_iptr = NULLIPTR;
						error(EXDEV);
					}
					break;

				case CREATE:
					if (c_iptr = lockfree(iptr->i_mdev, iptr->i_minor)) {
						/* created ok */
						dbuf.d_ino = c_iptr->i_ino;
						c_iptr->i_nlink++;
						update = 1;
					}
				}

				/* if updating, copy new name */
				if (update)
					strncpy(dbuf.d_name, name, DIRSIZ);
			}

			/* Update directory if reqd and file accessable
			 * Check if directory has write permission,
			 * If the file is a directory then only a super-user
			 * can update it.
			 */
			if (update){
				if(i_access(iptr, IAWRITE) && (!isdir(c_iptr)
					|| !cur_proc->euid)){
					b_write(&file, &dbuf, sizeof dbuf);
				}
				else{
					freeiptr(c_iptr);
					c_iptr = NULLIPTR;
				}
			}

			f_close(&file);
		}
	}
	else
		c_iptr = NULLIPTR;

	/* always free given directory inode */
	freeiptr(iptr);
	return c_iptr;
}

/*
 * Istat - returns contents of inode structure coded as per 'stat' and 'fstat'
 */
istat(iptr, statptr)
struct inode *iptr;
struct stat *statptr;
{

	statptr->st_dev = makedev(iptr->i_mdev - &bdevsw[0], iptr->i_minor);
	statptr->st_ino = iptr->i_ino;
	statptr->st_mode = iptr->i_mode;
	statptr->st_nlink = iptr->i_nlink;
	statptr->st_uid = iptr->i_uid;
	statptr->st_gid = iptr->i_gid;
	statptr->st_rdev = iptr->i_addr[0];
	statptr->st_size = iptr->i_size;
	statptr->st_atime = iptr->i_atime;
	statptr->st_mtime = iptr->i_mtime;
	statptr->st_ctime = iptr->i_ctime;
	return;
}

/*
 *	I_access()	Check inode for access permission effective uid, gid.
 */
i_access(iptr, mode)
struct inode *iptr;
int mode;
{
	mode &= IACCSS;		/* Mask mode bits */

	/* Check if newly created inode if so allow access */
	if(iptr->i_mode == 1) return 1;

	/* Scan each mode section, if root all section */
	if((iptr->i_mode & mode) == mode) return 1;
	if((iptr->i_uid == cur_proc->euid) || !cur_proc->euid){
		if((iptr->i_mode & (mode<<6)) == (mode<<6)) return 1;
	}
	if((iptr->i_gid == cur_proc->egid) || !cur_proc->euid){
		if((iptr->i_mode & (mode<<3)) == (mode<<3)) return 1;
	}
	/* Access denied, shucks */
	error(EACCES);
	return 0;
}
/*
 *	I_raccess()	Check inode for access permission real uid, gid.
 */
i_raccess(iptr, mode)
struct inode *iptr;
int mode;
{
	mode &= IACCSS;		/* Mask mode bits */

	/* Check if newly created inode if so allow access */
	if(iptr->i_mode == 1) return 1;

	/* Scan each mode section, if root all section */
	if((iptr->i_mode & mode) == mode) return 1;
	if((iptr->i_uid == cur_proc->uid) || !cur_proc->uid){
		if((iptr->i_mode & (mode<<6)) == (mode<<6)) return 1;
	}
	if((iptr->i_gid == cur_proc->gid) || !cur_proc->uid){
		if((iptr->i_mode & (mode<<3)) == (mode<<3)) return 1;
	}
	/* Access denied, shucks */
	error(EACCES);
	return 0;
}

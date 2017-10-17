/******************************************************************************
 *	Fio.c	File input output block, character or special.
 ******************************************************************************
 *
 *	f_close()	Altered so that if a pipe is being closed
 *			pipe links are removed and the pipe inode
 *			is released, and any process waiting are woken up.
 *
 *			T.Barnaby 15-1-86
 *
 */

# include	"../include/signal.h"
# include	"../include/param.h"
# include       "../include/inode.h"
# include       "../include/buf.h"
# include       "../include/file.h"
# include       "../include/dev.h"
# include	"../include/procs.h"
# include	"../include/stat.h"

# define	VOID	char

/*
 * F_open - file pointed-to be 'file' is opened and uses locked inode 'iptr'.
 */
f_open(file, iptr, mode)
struct inode *iptr;
struct file *file;
int	mode;
{
	int	devcode, (*fnc)();
	int	err;

	if (iptr) {
		file->f_mode = mode; 
		file->f_inode = iptr;
		file->f_curblk = 0;
		file->f_curchar = 0;

		switch (iptr->i_mode & S_IFMT) {
		case S_IFDIR:
		case S_IFREG:
			file->f_type = STD;
			file->f_handler = iptr->i_mdev;
			file->f_dev = iptr->i_minor;
			break;

		case S_IFBLK:
			file->f_type = B_SPECL;
			devcode = iptr->i_addr[0];
			file->f_handler = &bdevsw[devcode >> 8];
			file->f_dev = devcode & 0xFF;
			break;

		case S_IFCHR:
			file->f_type = C_SPECL;
			devcode = iptr->i_addr[0];
			file->f_handler = &cdevsw[devcode >> 8];
			file->f_dev = devcode & 0xFF;
			break;

		case S_IFBMD:
			file->f_type = B_SPECL;
			devcode = iptr->i_addr[0];
			file->f_handler = &bdevsw[devcode >> 8];
			file->f_dev = devcode & 0xFF;
			if(dmodopen(file) == -1) return -1;
			break;

		case S_IFCMD:
			file->f_type = C_SPECL;
			devcode = iptr->i_addr[0];
			file->f_handler = &cdevsw[devcode >> 8];
			file->f_dev = devcode & 0xFF;
			if(dmodopen(file) == -1) return -1;
			break;

		default:
			/* file type unknown */
			return -1;
		}

		err = 0;

		/* File open - open device it's using */
		if (fnc = file->f_handler->openfnc)
			err = (*fnc)(file->f_dev);

		/* If error remove device driver */
		if(err == -1){
			/* Do special module device driver closes if nesecary */
			switch (file->f_inode->i_mode & S_IFMT) {
			case S_IFBMD:
			case S_IFCMD:
				dmodclose(file);
				break;
			default:
				break;
			}
		}

		/* if no open fnc, assume it's not needed */
		return err;
	}

	/* no access */
	return -1;
}

/*
 * F_creat - create a standard type file ready for writing. Uses locked
 *              inode 'iptr'. If 'iptr' had existed, and it was a regular
 *              file, then it is truncated.
 */
f_creat(file, iptr, mode, perm)
struct inode *iptr;
struct file *file;
int	mode, perm;
{

	if (iptr) {
		/* check if file did exist */
		if (iptr->i_mode == 1) {
			/* new file mask with umask */
			iptr->i_mode = S_IFREG | (perm & ~(cur_proc->umask));
		}
		else if ((iptr->i_mode & S_IFMT) == S_IFREG)
			/* truncate old file */
			itrunc(iptr);

		return f_open(file, iptr, mode);
	}

	/* no access */
	return -1;
}

f_write(file, buffer, nbytes)
struct file *file;
char *buffer;
{

	file->f_inode->i_flag |= IUPD;	/* Flag indicates file modified */

	switch (file->f_type) {
	case STD:
	case B_SPECL:
		return b_write(file, buffer, nbytes);

	case C_SPECL:
		return c_write(file, buffer, nbytes);
	}

	/* type unknown */
	return -1;
}

f_ioctl(file, request, argp)
struct file *file;
VOID *argp;
{

	switch (file->f_type) {
	case STD:
		return b_ioctl(file, request, argp);

	case C_SPECL:
		return c_ioctl(file, request, argp);
	}

	/* invalid file type.. */
	return -1;
}

f_read(file, buffer, nbytes)
struct file *file;
char *buffer;
{
	switch (file->f_type) {
	case STD:
	case B_SPECL:
		return b_read(file, buffer, nbytes);

	case C_SPECL:
		return c_read(file, buffer, nbytes);
	}

	/* type unknown */
	return -1;
}

long
f_seek(file, pos, mode)
long pos;
struct file *file;
{
	long b_seek();

	switch (file->f_type) {
	case STD:
	case B_SPECL:
		return b_seek(file, pos, mode);

	case C_SPECL:
		return 0;
	}

	/* type unknown */
	return -1;
}

f_close(file)
struct file *file;
{
	int	err;
	int	(*fnc)();
	long	now;

	err = 0;

	/* Update file accessed and modified times */
	now = time((long *)0);
	file->f_inode->i_atime = now;

	/* Only update modified time if modification did occur */
	if(file->f_inode->i_flag & IUPD){
		file->f_inode->i_mtime = now;
		file->f_inode->i_flag &= ~IUPD;
	}

	/* If closeing a pipe, delete the cross pipe file links
	 * and if the second close on the pipe inode (ie both read
	 * and write have finished, second close) then set inodes
	 * i_nlink to 0 to indicate that the inode is no longer
	 * required and can be returned the free list with all its
	 * associated blocks
	 */
	if(file->f_mode & PIPE){
# ifdef TPIPES
printf("Closeing pipe %d mode %d\n\r",cur_proc->pid,file->f_mode);
# endif
		if(file->f_pipelink) file->f_pipelink->f_pipelink = 0;
		file->f_pipelink = 0;
		if(file->f_inode->i_nlocks == 1) file->f_inode->i_nlink = 0;
		/* Wakes up any processes waiting on this pipes end */
		wakeup((caddr_t)file);
	}
	file->f_inode->i_flag |= ICHG;

	/* close device which file used */
	if (fnc = file->f_handler->closefnc)
		err = (*fnc)(file->f_dev);

	/* Do special module device driver closes if nesecary */
	switch (file->f_inode->i_mode & S_IFMT) {
	case S_IFBMD:
	case S_IFCMD:
		dmodclose(file);
		break;
	default:
		break;
	}

	freeiptr(file->f_inode);

	/* if no close function, assume device needs no closing */
	return err;
}

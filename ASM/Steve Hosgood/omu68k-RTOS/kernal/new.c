/******************************************************************************
 *	New.c		New bits added to omu		T. Barnaby
 ******************************************************************************
 */

# include       "../include/param.h"
# include       "../include/file.h"
# include       "../include/inode.h"
# include	"../include/signal.h"
# include       "../include/procs.h"
# include	"../include/dev.h"
# include       "../include/excep.h"
# include       "../include/stat.h"
# include       <errno.h>
# include	<sys/ioctl.h>

# define        OPEN            SEARCH
# define	VOID		char

/*
 *	Chown()		Change ownership of a file (only if superuser)
 */
chown(name, owner, group)
char *name;
int owner;
int group;
{
	struct inode *iptr;

	/* Check if if root else disallowed */
	if(cur_proc->euid) return error(EPERM);

	/* attempt to get inode */
	if (iptr = namlock(name, SEARCH, NULLIPTR)) {

		iptr->i_uid = owner;		/* Set id */
		iptr->i_gid = group;		/* Set group id */
		iptr->i_mode &= ~S_ISUID;	/* Clears set uid bit */
		iptr->i_flag |= ICHG;		/* Set write flag */
		freeiptr(iptr);			/* Free the iptr */
		return 0;
	}

	/* couldn't read inode */
	return -1;
}
/*
 *	Dev_flush()	Tempary device flush routine
 */
dev_flush()
{
	fdioctl(0,TIOCFLUSH,0);
	fdioctl(1,TIOCFLUSH,0);
#ifndef	MBOMU
	fdioctl(2,TIOCFLUSH,0);
	fdioctl(3,TIOCFLUSH,0);
#endif	MBOMU
}

/*
 *	Pause()		Pause system call sends process to sleep
 */
pause(){

	/* Send process to sleep awaiting an event that will never happen
	 * Will return only when a signal is recieved and returns the signal
	 * number that awoke it.
	 */
	return sleep(1,PWAIT);
}

/*
 *	Umask()		Sets up user mode mask
 */
umask(compmode)
int compmode;
{
	int oldmask;

	oldmask = cur_proc->umask;
	cur_proc->umask = compmode & IACCESS;
	return oldmask;
}
/*
 *	Getbdev()	Gets block device switch entry.
 */
getbdev(dev, pointer)
int dev;
struct dev *pointer;
{
	if((dev < 0) || (dev >= NBDEVS)) return error(-1);
	bytecp(&bdevsw[dev], pointer, sizeof(struct dev));
	return (int)pointer;
}
/*
 *	Setbdev()	Sets block device switch entry, super-user only.
 */
setbdev(dev, pointer)
int dev;
struct dev *pointer;
{
	if((dev < 0) || (dev >= NBDEVS)) return error(-1);
	if(cur_proc->euid) return error(-1);
	bytecp(pointer, &bdevsw[dev], sizeof(struct dev));
	return 0;
}
/*
 *	Getcdev()	Gets character device switch entry.
 */
getcdev(dev, pointer)
int dev;
struct dev *pointer;
{
	if((dev < 0) || (dev >= NCDEVS)) return error(-1);
	bytecp(&cdevsw[dev], pointer, sizeof(struct dev));
	return (int)pointer;
}
/*
 *	Setcdev()	Sets character device switch entry, super-user only.
 */
setcdev(dev, pointer)
int dev;
struct dev *pointer;
{
	if((dev < 0) || (dev >= NCDEVS)) return error(-1);
	if(cur_proc->euid) return error(-1);
	bytecp(pointer, &cdevsw[dev], sizeof(struct dev));
	return 0;
}
/*
 *	Lock()		Lock process in core.
 *			Turns on/off process switch.
 */
lock(flag)
int flag;
{
	/* Disables process switch interupt only if superuser */
	if(cur_proc->euid) return error(EPERM);

	/* Sets processes status register mask for no process switch
	 * interupt, sets processes flag to indicate this.
	 */
	if(flag){
		cur_proc->flag |= SULOCK;
		cur_proc->reg->sr = PLSWITCH << 8;
	}
	else{
		cur_proc->flag &= ~SULOCK;
		cur_proc->reg->sr = 0x0000;
	}
	return 0;
}

/*
 *	Setcrt()	Sets the processes controling crt
 */
setcrt(tty)
int	tty;
{
	int	otty;

	otty = cur_proc->tty;
	cur_proc->tty = tty;
	return otty;
}

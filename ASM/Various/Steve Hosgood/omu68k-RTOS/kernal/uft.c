# include       "../include/param.h"
# include	"../include/signal.h"
# include       "../include/procs.h"
# include       "../include/inode.h"
# include       "../include/file.h"
# include       "../include/stat.h"
# include       <errno.h>

# define        OPEN            SEARCH
# define	VOID		char

int f_open(), f_creat();
long f_seek();
struct file uft[NFILES], *check_fd();

/*
 * Open - makes an entry in User File Table, returns file descriptor.
 */
open(name, mode)
int mode;
char *name;
{
	return gen_open(name, (mode+1)&3, OPEN, 0, f_open);
}

/*
 * Creat - makes an entry in User File Table, returns file descriptor.
 */
creat(name, perm)
char *name;
int perm;
{

	return gen_open(name, 2, CREATE, perm, f_creat);
}

/*
 * Read - check supplied file descriptor, perform a read if mode ok.
 */
read(fd, buffer, nbytes)
int fd,nbytes;
char *buffer;
{
	struct file *uft_ptr;

	uft_ptr = check_fd(fd);
	if (uft_ptr && (uft_ptr->f_mode & READABLE))
		return f_read(uft_ptr, buffer, nbytes);

	/* file not opened for reading */
	return -1;
}

/*
 * Write - check supplied file descriptor, perform a write if mode ok.
 */
write(fd, buffer, nbytes)
int fd,nbytes;
char *buffer;
{
	struct file *uft_ptr;

	uft_ptr = check_fd(fd);
	if (uft_ptr && (uft_ptr->f_mode & WRITEABLE))
		return f_write(uft_ptr, buffer, nbytes);

	/* file not opened for writing */
	return -1;
}

/*
 * Lseek - check supplied file descriptor, perform a seek if fd ok.
 */
long
lseek(fd, off, mode)
int fd,mode;
long off;
{
	struct file *uft_ptr;

	if (uft_ptr = check_fd(fd))
		return f_seek(uft_ptr, off, mode);

	/* file not open */
	return -1;
}

/*
 * Ioctl - check descriptor, perform io-control if it's valid.
 */
ioctl(fd, request, argp)
int fd,request;
VOID *argp;
{
	struct file *uft_ptr;

	if (uft_ptr = check_fd(fd)) {
		return f_ioctl(uft_ptr, request, argp);
	}

	/* file not open */
	return error(EBADF);
}

/*
 * Fstat - return information concerning open file descriptor.
 */
fstat(fd, ptr)
int fd;
struct stat *ptr;
{
	struct file *uft_ptr;

	if (uft_ptr = check_fd(fd)) {
		istat(uft_ptr->f_inode, ptr);
		return 0;
	}

	/* file not open */
	return -1;
}

/*
 * Stat - return information concerning named file.
 */
stat(name, ptr)
char *name;
struct stat *ptr;
{
	struct inode *iptr;

	/* attempt to get inode */
	if (iptr = namlock(name, SEARCH, NULLIPTR)) {
		istat(iptr, ptr);
		freeiptr(iptr);
		return 0;
	}

	/* couldn't read inode */
	return -1;
}
/*
 *	Access()	Access checking system call.
 */
access(name, mode)
char *name;
int mode;
{
	struct inode *iptr;

	mode &= IACCSS;		/* Mask mode bits */

	/* attempt to get inode */
	if (iptr = namlock(name, SEARCH, NULLIPTR)) {
		/* Check for access in given mode real uid, gid */
		if(i_raccess(iptr, mode)){
			freeiptr(iptr);
			return 0;
		}
		else{
			freeiptr(iptr);
			return -1;
		}
	}

	/* couldn't read inode */
	return -1;
}

/*
 *	Nopens()	Number of opens of the specified file
 */
nopens(fd)
int	fd;
{
	struct file *uft_ptr;

	if (uft_ptr = check_fd(fd)) {
		return uft_ptr->f_inode->i_nlocks;
	}

	/* file not open */
	return error(EBADF);
}

/*
 *	Ispipe()	Checks if file channel is a pipe
 */
ispipe(fd)
int	fd;
{
	struct file *uft_ptr;

	if (uft_ptr = check_fd(fd)) {
		if(uft_ptr->f_mode & PIPE)
			return 1;
		else
			return 0;
	}

	/* file not open */
	return error(EBADF);
}

/*
 * Close - check supplied file descriptor, perform a close if fd ok.
 */
close(fd)
int fd;
{
	struct file *uft_ptr;
	int err;

	if (uft_ptr = check_fd(fd)) {
		cur_proc->slots[fd] = 0;

		if (--uft_ptr->f_ndup <= 0) {
			/* really close file on last duplicate close */
			err = f_close(uft_ptr);
			uft_ptr->f_mode = 0;
			return err;
		}

		/* assume OK if not the last close of a file */
		return 0;
	}

	/* file not open */
	return -1;
}

/*
 * Sync - writes changed inodes and blocks back to disk.
 */
sync()
{

	iflush();
	bflush();	/* Flushes all buffers that have been written */
/*	bflush_all();	*/ /* Flushes all buffers on umounted file systems */
	dev_flush();
	return;
}

/*
 * Gen_open - deal with open or creat calls..
 */
gen_open(name, mode, type, perm, fnc)
int mode,type,perm;
char *name;
int (*fnc)();
{
	int slot, amode;
	struct file *uft_ptr;
	struct inode *iptr;

#ifdef TKERNAL
printf("genopen %s, %x, %x, %x, %x\n\r",name,mode,type,perm,fnc); 
#endif

	/* Set up access mode bit format (rwx) */
	amode = 0;
	if(mode & 1) amode |= IAREAD;
	if(mode & 2) amode |= IAWRITE;

	/* Get a free slot in user and system file tables */
	if((slot = getslot()) == -1) return slot;

	/* Set up file pointer to created slot */
	uft_ptr = cur_proc->slots[slot];

	/* attempt to get inode */
	if (iptr = namlock(name, type, NULLIPTR)) {
		/* Check for access note mode 1 is read */
		if(i_access(iptr, amode)){

			if ( !(isdir(iptr) && mode >= 2)) {
				if ((*fnc)(uft_ptr, iptr, mode, perm) != -1){
					return slot;
				}
			}
		}
		/* Unable to open because of permisions */
		freslot(slot);
		freeiptr(iptr);
		return error(EACCES);
	}
	else {
		freslot(slot);
		return error(ENOENT);
	}
}

/*
 * Check_fd - returns ptr to uft entry for file given by user's fd.
 */
struct file *
check_fd(fd)
int fd;
{

	if ((fd < 0) || (fd >= NFPERU) || (!cur_proc->slots[fd])){
		/* illegal fd */
		error(EBADF);
		return 0;
	}

	/* Else ok */
	return cur_proc->slots[fd];
}

/*
 * Dup_all - makes dups of open files in parent, gives to child.
 */
dup_all(par, child)
struct procs *par, *child;
{
	int t;
	struct file **p_ptr, **c_ptr;

	p_ptr = par->slots;
	c_ptr = child->slots;

	for (t = 0; t < NFPERU; t++) {
		if (*p_ptr) {
			(*p_ptr)->f_ndup++;
		}
		*c_ptr++ = *p_ptr++;
		
	}

	return;
}

/*
 * Dup 2- Internal version of duplicate file descriptor.
 */
dup2(fd, nfd)
int fd, nfd;
{
	return dup((fd + 64), nfd);
}

/*
 * Dup - duplicate file descriptor.
 */
dup(fd,nfd)
int fd, nfd;
{
	int t;
	struct file *old, **new;

	if(fd<0) return -1;
	/* Checks if dup2 call ( >=64 ) */
	if(fd>=64) {
		fd -= 64;
		if (old = check_fd(fd)) {
			if((nfd >= 0) && (nfd < NFPERU)) {
				new = cur_proc->slots;
				new += nfd;
				if(*new) close(nfd);
				*new = old;
				old->f_ndup++;
				return nfd;
			}
		}
	}
	/* Normal dup call */
	else{
		if (old = check_fd(fd)) {
			new = cur_proc->slots;
			for (t = 0; t < NFPERU; t++) {
				if (! *new) {
					*new = old;
					old->f_ndup++;
					return t;
				}
				new++;
			}
		}
	}

	/* error original wasn't open */
	return -1;
}

/*
 *	Pdup - Interprocess duplicate file descriptor.
 *		returns local file descripter if succesful
 */
pdup(fd, pid, pfd)
int fd, pid, pfd;
{
	int	t;
	struct	file *old, **new;

	/* Checks if remote process descriptor OK */
	if((pid < 0) || (pid > NPROC) || !proc_table[pid].stat) return -1;

	/* Checks if remote process file descriptor OK */
	if((pfd < 0) || (pfd > NFPERU)) return -1;

	/* Checks if local file descriptor OK */
	if(old = check_fd(fd)){
		new = &proc_table[pid].slots[pfd];
		/* If there is an open file on the remote file slot close it */
		if(*new){
			/* Perform close of remote processes file */
			if(--(*new)->f_ndup <= 0){
				/* really close file on last duplicate close */
				f_close(*new);
				(*new)->f_mode = 0;
			}
		}
		*new = old;
		old->f_ndup++;
		/* Signal any processes looking at this file */
		fileevent(old);
		return fd;
	}
	return -1;
}

/*
 *	Getslot()	Gets a free slot in the processes file slots
 *			and links it to a slot in the system file table.
 */
getslot(){
	int fd, slot;
	struct file *uft_ptr, **slot_ptr;

	slot_ptr = cur_proc->slots;
	for (slot = 0; slot < NFPERU; slot++) {

		if (! *slot_ptr) {
			/* user has slot free - has uft got space? */
			uft_ptr = uft;
			for (fd = 0; fd < NFILES; fd++) {

				if (uft_ptr->f_mode == 0) {
					/* found an entry so use it */
					uft_ptr->f_mode = 1;
					*slot_ptr = uft_ptr;
					uft_ptr->f_ndup = 1;

					return slot;
				}

				uft_ptr++;
			}
			return error(ENFILE);
		}
		slot_ptr++;
	}

	/* no file slot */
	return error(EMFILE);
}

/*
 *	freslot()	Frees a slot in the processes file slots, and
 *			from the system file table.
 */
freslot(slot)
int slot;
{
	struct file *uft_ptr;

	uft_ptr = cur_proc->slots[slot];
	uft_ptr->f_ndup = 0;
	uft_ptr->f_mode = 0;
	cur_proc->slots[slot] = 0;
}

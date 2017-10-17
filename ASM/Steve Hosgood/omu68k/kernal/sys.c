/*
 * Start-up and Syscall Interface for 68000 Unix, T.Barnaby, 20/5/85
 * Note:
 *      There is a routine in the kernel for each of the system calls.
 *      These internal routines replace the library versions as far as
 *      the kernel code is concerned. The library calls invoke the
 *      syscall interface, which of course is not needed from within
 *      the kernel. There is one exception: the 'exece' call is called
 *      via the syscall even within the kernel, this is because the
 *      registers must be saved and stacked, the syscall is the easiest
 *      method. The internal routine for 'exece' is called 'kexece'.
 *	
 */

# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	<errno.h>
# include	<sys/ioctl.h>
# include	"../include/memory.h"
# include	"../include/state.h"
# include	"../include/dev.h"
# include	"../include/stat.h"

# define	SHELLNAME	""		/* Initial shell "sh", "csh",
						 * or "" internal shell */
# define	SHELLPATH	"/bin/sh"	/* Path if not internal */

# define	REG(x)		(cur_proc->reg->x)	/* Register address */

extern struct inode ibuf[];
extern long end;		/* End of bss */

extern char concurent;		/* Concurancy control */
extern char swtchflag;

extern struct dev dbdevsw[], dcdevsw[];	/* Default device switches */

/* Proccess table, pointer and no of entries initialisation */
struct procs proc_table[NPROC];
struct procs *cur_proc;
long	proclen = sizeof(struct procs);	/* Sets size of process table */
int	proc_index;

long    lseek();
long *saveargs();
char *putst();

/* Kernal state definition structure */
struct	State state;

/* Main kernel entry point */
main()
{
	char *argv[3];

	/* Set kernal state definition
	 */
	state.concur = SCTSWTCH;
	state.warning = SCWARN;
	state.test = 0;
	state.uptime = STFILES;		/* Update time on files only */

	/* Initialise device switches */
	bytecp(dbdevsw, bdevsw, sizeof(struct dev) * NBDEVS);
	bytecp(dcdevsw, cdevsw, sizeof(struct dev) * NCDEVS);

	/* set process table at slot 0 initialise process entry for kernal
	 * internal shell
	 */
	proc_index = 0;			/* First entry in process table */
	cur_proc = &proc_table[0];
	cur_proc->flag = SLOAD|SLOCK;	/* Process cannot be swapped!!! */
	cur_proc->stat = SRUN;		/* Process is running (hopefully) */
	cur_proc->psize.entry = 0x1000;
	cur_proc->psize.ebss = (long)&end;
	strcpy(cur_proc->name,"kernal+shell");

	cur_proc->tty = -1;		/* Set group tty to unknown */

	/* Initialise memory */
	mem_init();
	getmem(KERNELSEG,0);
	cur_proc->majseg = KERNELSEG;	/* Process is in kernel segment */
	cur_proc->minseg = 0;		/* Process is in all of segment */

	/* Initialise exceptions */
	excep_init();

	/* Initialise board specific bits */
	mach_init();

	/* Initialise timer */
	time_init();

	/* Start interupts */
	spl0();

	/* Open root disk */
	if(bdevsw[RDEV_MAJ].openfnc(RDEV_MIN) == -1)
		panic("No disk");

	/* Name of external shell 'shell' */
	argv[0] = SHELLNAME;
	argv[1] = "-";
	argv[2] = 0;

	/* Start off shell */
	if(!argv[0][0]){
		sh(2,argv);			/* Internal shell */
	}
	else syscall(75,SHELLPATH, argv, 0);	/* Do XEQ for disk shell */

	/* back to monitor if 'shell' returns */
	bdevsw[RDEV_MAJ].closefnc(RDEV_MIN);

	/* Closes down any machine dependent bits */
	mach_shut();
	return;
}


/*
 *	Sys -	Main KERNEL function entry point, called by machine code:
 *		current process info has been put into proc_table.
 */
sys(){
	char name1[50], name2[50];
	int id;
	short smask;

#ifdef TKCALLS
 if((REG(d0)&0xFFFF)!=4) 
	printf("SYSTEM CALL %d, %d, %d, %d\n\r",REG(d0)&0xffff,
		REG(a0),REG(d1),REG(a1));
#endif

	/* Disables process switch and quit signal checking */
	smask = smaskon(cur_proc, EVALL);

	id = REG(d0) & 0xFFFF;		/* Word access only */
	REG(sr) &= ~CARRY;		/* Clears carry, no error */
	cur_proc->errno = 0;		/* No error */

	/* service each call seperately */
	switch (id) {
	case 1:
		/* Exit call , terminate proccess */
		REG(d0) = kexit(REG(a0) << 8);
		break;

	case 2:
		/* Fork - create new proccess */
		REG(d0) = kfork();
		break;

	case 3:
		/* Read call */
		REG(d0) = read(REG(a0), ( char * ) REG(d1), REG(a1));
		break;

	case 4:
		/* Write call */
		REG(d0) = write(REG(a0), ( char * ) REG(d1), REG(a1));
		break;

	case 5:
		/* Open call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = open(name1, REG(d1));
		break;

	case 6:
		/* Close call */
		REG(d0) = close(REG(a0));
		break;

	case 7:
		/* Wait for signal */
		REG(d0) = kwait(REG(a0));
		break;

	case 8:
		/* Creat call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = creat(name1, REG(d1));
		break;

	case 9:
		/* Link call */
		strncpy(name1, REG(a0), 50);
		strncpy(name2, REG(d1), 50);
		REG(d0) = link(name1, name2);
		break;

	case 10:
		/* Unlink call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = unlink(name1);
		break;

	case 11:
		/* Execute new process exec */
		strncpy(name1, REG(a0), 50);
		REG(d0) = kexece(name1, REG(d1),0);
#ifdef TXEQ
printf("INternal exec return\n\r");
#endif
		break;

	case 12:
		/* Chdir call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = chdir(name1);
		break;

	case 13:
		/* Time call */
		REG(d0) = time();
		break;

	case 14:
		/* Mknod call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = mknod(name1, REG(d1), REG(a1));
		break;

	case 15:
		/* Chmod call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = chmod(name1, REG(d1));
		break;

	case 16:
		/* Chown call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = chown(name1, REG(d1), REG(a1));
		break;

	case 17:
		/* Sbrk call */
		REG(d0) = sbrk(( char * ) REG(a0));
		break;

	case 18:
		/* Stat call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = stat(name1, ( struct stat * ) REG(d1));
		break;

	case 19:
		/* Lseek call */
		REG(d0) = lseek(REG(a0), REG(d1), REG(a1));
		break;

	case 20:
		/* Getpid call */
		REG(d0) = cur_proc->pid;
		break;

	case 21:
		/* Mountfs call */
		strncpy(name1,REG(a0),50);
		strncpy(name2,REG(d1),50);
		REG(d0) = mount(name1, name2, REG(a1));
		break;

	case 22:
		/* Umountfs call */
		strncpy(name1,REG(a0),50);
		REG(d0) = umount(name1);
		break;

	case 23:
		/* Setuid call */
		REG(d0) = setuid(REG(a0));
		break;

	case 24:
		/* Getuid call */
		REG(d0) = getuid();
		break;

	case 25:
		/* Stime call */
		REG(d0) = setime(REG(a0));
		break;

	case 27:
		/* Alarm call */
		REG(d0) = alarm(REG(a0));
		break;

	case 28:
		/* Fstat call */
		REG(d0) = fstat(REG(a0), ( struct stat * ) REG(d1));
		break;

	case 29:
		/* Pause system call */
		REG(d0) = pause();
		break;

	case 30:
		/* Utime call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = utime(name1, REG(d1));
		break;

	case 31:
		/* Stty call */
		REG(d0) = ioctl(REG(a0),TIOCSETP, REG(d1));
		break;

	case 32:
		/* Stty call */
		REG(d0) = ioctl(REG(a0),TIOCGETP, REG(d1));
		break;

	case 33:
		/* Access call */
		strncpy(name1, REG(a0), 50);
		REG(d0) = access(name1,REG(d1));
		break;

	case 35:
		/* Ftime call */
		REG(d0) = ftime(REG(a0));
		break;

	case 36:
		/* Sync call */
		sync();
		REG(d0) = 0;
		break;

	case 37:
		/* Kill proccess call */
		REG(d0) = kill(REG(a0),REG(d1));
		break;

	case 41:
		/* Dup call */
		REG(d0) = dup(REG(a0), REG(d1));
		break;

	case 42:
		/* Pipe call */
		REG(d0) = pipe();
		break;

	case 43:
		/* Times call */
		REG(d0) = times(REG(a0));
		break;

	case 45:
		/* Locking call */
		REG(d0) = 0;
		return;

	case 46:
		/* Setgid call */
		REG(d0) = setgid(REG(a0));
		break;

	case 47:
		/* Getgid call */
		REG(d0) = getgid();
		break;

	case 48:
		/* Signal call */
		REG(d0) = (long)signal(REG(a0),REG(d1));
		break;

	case 53:
		/* Lock process call */
		REG(d0) = lock(REG(a0));
		break;

	case 54:
		/* Ioctl call */
		REG(d0) = ioctl(REG(a0), REG(d1), ( char * ) REG(a1));
		break;

	case 59:
		/* Execute new process exece */
		strncpy(name1, REG(a0), 50);
		REG(d0) = kexece(name1,REG(d1),REG(a1));
		break;

	case 60:
		/* Set up umask */
		REG(d0) = umask(REG(a0));
		break;

	case 64:
		/* Onfile event call (call signal SIGEVFILE on file ready) */
		REG(d0) = onfile(REG(a0), REG(d1));
		break;

	case 65:
		/* Inter process Comunication syscall */
		REG(d0) = comms(REG(a0), REG(d1));
		break;

	case 66:
		/* Gets block device switch entry */
		REG(d0) = getbdev(REG(a0), REG(d1));
		break;

	case 67:
		/* Sets block device switch entry */
		REG(d0) = setbdev(REG(a0), REG(d1));
		break;

	case 68:
		/* Gets character device switch entry */
		REG(d0) = getcdev(REG(a0), REG(d1));
		break;

	case 69:
		/* Sets character device switch entry */
		REG(d0) = setcdev(REG(a0), REG(d1));
		break;

	case 70:
		/* Get memory segments data */
		REG(d0) = getseg(REG(a0), REG(d1));
		break;

	case 71:
		/* Set memory segments data */
		REG(d0) = setseg(REG(a0), REG(d1));
		break;

	case 72:
		/* Perform a process switch */
		pswitch(REG(a0));
		REG(d0) = 0;
		break;

	case 73:
		/* Get information on proccess table entries */
		REG(d0) = p_status(REG(a0),REG(d1));
		break;

	case 74:
		/* Get information on swapspace entries */
		REG(d0) = s_status(REG(a0),REG(d1));
		break;


	case 75:
		/* xeq execute from internal shell (Don't fork) */
		strncpy(name1, REG(a0), 50);
		REG(d0) = xeq(name1,REG(d1),REG(a1),REG(d2));
		break;

	case 76:
		/* Return OMU's version number */
		REG(d0) = VERSION;
		break;

	case 77:
		/* Make special module mode */
		strncpy(name1, REG(a0), 50);
		strncpy(name2, REG(d2), 50);
		REG(d0) = mkmod(name1, REG(d1), REG(a1), name2);
		break;

	case 78:
		/* Find out how many opens there are on a file desc */
		REG(d0) = nopens(REG(a0));
		break;

	case 79:
		/* Send process to sleep */
		REG(d0) = sleep((caddr_t)REG(a0), REG(d1));
		break;

	case 80:
		/* Wake up processes */
		REG(d0) = wakeup((caddr_t)REG(a0));
		break;

	case 81:
		/* Get area of memory for process */
		REG(d0) = getmem(MODULESEG, REG(a0));
		break;

	case 82:
		/* End area of memory for process */
		REG(d0) = endmem(MODULESEG, REG(a0));
		break;

	case 83:
		/* Set trap for process to sleep */
		REG(d0) = (long)settrap(REG(a0), (caddr_t)REG(d1));
		break;

	case 84:
		/* Set controlling tty for process */
		REG(d0) = setcrt(REG(a0));
		break;

	default:
		/* illegal system call */
		REG(d0) = error(-1);
		if(state.warning)
			printf("KERNAL	- Illegal system call %d\n",id);
	}

#ifdef TKCALLS
if(id!=4){
printf("Going back to trap %d address %x, %x\n",REG(d0),REG(pc),REG(usp));
}
#endif

	/* Error handling */
	if(REG(d0) == -1) error(-1);

	/* Sets d0 for return of error */
	if(cur_proc->errno) REG(d0) = cur_proc->errno;

	smaskoff(cur_proc,smask);		/* Renable process switch */

	/* Event checking , did a signal, event or proccess switch occur while
	 * in the process of executing a system call.
	 */
	checkev(EVALL);

	return;
}

/*****************************************************************************r
 *	Error sets error flag for return
 ******************************************************************************
 *
 *	If the error has already been noted use first error number
 */

error(err)
int err;
{
	REG(sr) |= CARRY;		/* Sets carry flag */
	REG(d0) = err;			/* Sets d0 for error */
	/* If first notice of error then set error number */
	if(!cur_proc->errno) cur_proc->errno = err;
	return -1;
}

/*
 *	User id commands
 */
setuid(uid)
short uid;
{
	/* Only allow if super user */
	if(!cur_proc->euid){
		cur_proc->uid = cur_proc->euid = uid;
		return 0;
	}
	return error(EPERM);
}
getuid(){
	REG(d1)= cur_proc->euid;
	return (cur_proc->uid);
}
setgid(gid)
short gid;
{
	/* Only allow if super user */
	if(!cur_proc->euid){
		cur_proc->gid = cur_proc->egid = gid;
		return 0;
	}
	return error(EPERM);
}
getgid(){
	REG(d1)= cur_proc->egid;
	return (cur_proc->gid);
}

/******************************************************************************
 *	Proc.h		Proccess table
 ******************************************************************************
 */

#define	STACKROOM	8192	/* Room for stack when doing sbrk */
#define	SYSSTACK	2048	/* size of system stack per proccess */

/*
 *	Object		Full address of an object eg file
 */
struct	Object {
	struct	dev *majdev;		/* Pointer to device table entry */
	short	mindev;			/* Minor device number */
	short	inode;			/* Inode number */
};

/*
 *	Psize		Process size definitions
 */
struct	Psize {
	long	fmagic;			/* Program magic number */
	long	tsize;			/* Text size in bytes */
	long	dsize;			/* Data size */
	long	bsize;			/* Bss size */
	long	entry;			/* Program entry point */
	long	ebss;			/* End of bss address */
	long	ustack;			/* Top of user stack */
	long	stacks;			/* Stack size */
};

/*
 *	U_regs		Proccesor registers as held on system stack 74 bytes
 */
struct u_regs {
	long		laststate;	/* Previous state pointer */
	long		d0;	/* Data registers */
	long		d1;
	long		d2;
	long		d3;
	long		d4;
	long		d5;
	long		d6;
	long		d7;

	long		a0;	/* Address registers (you don't say!) */
	long		a1;
	long		a2;
	long		a3;
	long		a4;
	long		a5;
	long		a6;

	long		usp;		/* User stack pointer */
	long		ret;		/* Return from wrapper address */
	long		func;		/* Function being called */
	short		sr;		/* Status register */
	long		pc;		/* Program counter */
};

# define	CARRY	1	/* Carry flag in status register */

/*
 *	Signal		Signals structure (very tempary)
 */
struct signal {
	int	(*func)();	/* Signal function call */
};

/*
 *	Procs		Proccess structure one per process
 *			note no user structure everything is here.
 */
struct procs {
	struct u_regs	*reg;		/* Procesor registers and sysstack */
	struct inode    *wd;		/* Working dir */
	struct	Psize	psize;		/* Process size definitions */

	char		name[PATHLEN];	/* Path name of process */
	struct	Object	object;		/* Object name of process */

	struct file	*slots[NFPERU];	/* File slots */

	short		stat;		/* Process state 0 - none */
	short		flag;		/* Process flags */
	short           pid;		/* Process number */
	short		ppid;		/* Proccess number of parent */
	short		tty;		/* Proccess control tty */
	short		cpu;		/* Cpu usage */
	short		pri;		/* Proccess priority */
	short		nice;		/* Priority */

	unsigned long	sig;		/* Signals pending bit map */
	struct signal	signals[NSIG];	/* Signals */
	long		evenfile;	/* File event enable bit map */
	short		evfile;		/* File event pending number */
	short		evpid;		/* Comms event Process calling pid */
	int		evcoms;		/* Comms event data */

	caddr_t		wchan;		/* Waiting on channel sleep */
	short		exitstatus;	/* Exit status of process */
	short		errno;		/* Error number */
	long		umask;		/* File creation mode mask */
	long		alarm;		/* Alarm counter */
	short		smask;		/* Software interupt mask */

	short		majseg;		/* Major memory segment being used */
	short		minseg;		/* Minor memory segment being used */
	char		paddress[8];	/* Post address */

	short		uid;		/* Users id */
	short		gid;		/* Users group id */
	short		euid;		/* Users effective id */
	short		egid;		/* Users effective group id */

	char		sysstack[SYSSTACK];/* System stack for proccess temp */
};

/*
 *	Stat codes
 */

# define	SSLEEP	1	/* Awaiting event ie asleep */
# define	SWAIT	2	/* Abandoned state */
# define	SRUN	3	/* Running */
# define	SIDL	4	/* Indeterminate state (in creation) */
# define	SZOMB	5	/* Indeterminate state (in termination) */
# define	SSTOP	6	/* Process being traced */

/*
 *	Flag codes
 */

# define	SLOAD	1	/* In core ie runable directly */
# define	SSYS	2	/* Sceduling process not implemented */
# define	SLOCK	4	/* Process cannot be swapped stays in core */
# define	SSWAP	8	/* Process is being swapped out, not imp */
# define	STRC	0x10	/* Process is being traced, not imp */
# define	SWTED	0x20	/* Trace flag2, not imp */
# define	SULOCK	0x40	/* User setable lock locks process into core */

/*
 *	Smask	Software interupt mask (Function bits set are masked)
 *		and Event checking flags (Only function bits set are checked)
 */

# define	EVOFF		0	/* Nothing masked */
# define	EVSWTCH		1	/* Checks if process switch required */
# define	EVSIGQUIT	2	/* Checks signals to quit process */
# define	EVSIGUSER	4	/* Checks signals to jump to user func*/

# define	EVALLSIG	6	/* Checks all signal events */
# define	EVALL		7	/* Checks all events this process */

extern struct procs *cur_proc;
extern struct procs proc_table[];

extern	int	proc_index;

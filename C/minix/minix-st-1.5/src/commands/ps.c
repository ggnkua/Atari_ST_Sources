/* ps - print status			Author: Peter Valkenburg */

/* ps.c, Peter Valkenburg (valke@psy.vu.nl), january 1990.
 *
 * This is a V7 ps(1) look-alike for MINIX 1.5.0.  It can use a database with
 * information on system addresses as an extra, and has some additional fields.
 * It does not support the 'k' option (i.e. cannot read memory from core file).
 * If you want to compile this for non-IBM PC architectures, the header files
 * require that you have your CHIP, MACHINE etc. defined.
 *
 * VERY IMPORTANT NOTE:
 *	To use ps, kernel/kernel, fs/fs, and mm/mm must be in the /usr/src
 *	(or the #includes below must be changed).  Furthermore, all of
 *	must contain symbol tables.  This can be arranged using the -s flag
 *	and the ast program.  For example in fs, one would have
 *
 *	asld -s -i -o fs $l/head.s $(obj) $l/libc.a $l/end.s >symbol.out
 *	ast -X fs		# include symbol.out in fs
 *
 */

/*
 * Most fields are similar to V7 ps(1), except for CPU, NICE, PRI which are
 * absent, RECV which replaces WCHAN, and RUID and PGRP that are extras.
 * The info is obtained from the following fields of proc, mproc and fproc:
 * F	- kernel status field, p_flags
 * S	- kernel status field, p_flags; mm status field, mp_flags (R if p_flags
 * 	  is 0; Z if mp_flags == HANGING; T if mp_flags == STOPPED; else W).
 * UID	- mm eff uid field, mp_effuid
 * RUID	- mm real uid field, mp_realuid
 * PID	- mm pid field, mp_pid
 * PPID	- mm parent process index field, mp_parent (used as index in proc).
 * PGRP - mm process group id mp_procgrp
 * ADDR	- kernel physical text address, p_map[T].mem_phys
 * SZ	- kernel physical stack address + stack size - physical text address,
 * 	  p_map[S].mem_phys + p_map[S].mem_len - p_map[T].mem_phys
 * RECV	- kernel process index field for message receiving, p_getfrom
 *	  If sleeping, mm's mp_flags, or fs's fp_task are used for more info.
 * TTY	- fs controlling tty device field, fs_tty.
 * TIME	- kernel user + system times fields, user_time + sys_time
 * CMD	- system process index (converted to mnemonic name obtained by reading
 *	  tasktab array from kmem), or user process argument list (obtained by
 *	  reading reading stack frame; the resulting address is used to get
 *	  the argument vector from user space and converted into a concatenated
 *	  argument list).
 */  	  
 
#include <minix/config.h>
#include <limits.h>
#include <sys/types.h>

#include <minix/const.h>
#undef EXTERN				/* <minix/const.h> defined this */
#define EXTERN				/* so we get proc, mproc and fproc */
#include <minix/type.h>

#include "../kernel/const.h"
#include "../kernel/type.h"
#include "../kernel/proc.h"
#undef printf				/* kernel's const.h defined this */

#include "../mm/mproc.h"
#include "../fs/fproc.h"
#include "../fs/const.h"
#undef printf				/* fs's const.h defined this */


/*----- ps's local stuff below this line ------*/

#include <minix/com.h>
#include <fcntl.h>
#include <a.out.h>
#include <stdio.h>

#define mindev(dev)	(((dev)>>MINOR) & 0377)	/* yield minor device */
#define majdev(dev)	(((dev)>>MAJOR) & 0377)	/* yield major device */

#define	TTY_MAJ		4			/* fixed tty major device */

/* macro to convert memory offsets to rounded kilo-units */
#define	off_to_k(off)	((unsigned) (((off) + 512) / 1024))

/* what we think the relevant identifiers in the namelists are */
#define	ID_PROC		"_proc"		/* from kernel namelist */
#define	ID_MPROC	"_mproc"	/* from mm namelist */
#define	ID_FPROC	"_fproc"	/* from fs namelist */
#define	ID_TASKTAB	"_tasktab"	/* from kernel namelist */

/*
 * Structure for system address info (also layout of ps's database).
 */
typedef struct {
	struct nlist ke_proc[2], ke_tasktab[2];
	struct nlist mm_mproc[2];
	struct nlist fs_fproc[2];
} sysinfo_t;

sysinfo_t sysinfo;			/* sysinfo holds actual system info */

#define	NAME_SIZ	(sizeof(sysinfo.ke_proc[0].n_name))	/* 8 chars */

/* what we think the identfiers of the imported variables in this program are */
#define	PROC	proc
#define	MPROC	mproc
#define	FPROC	fproc
#define	TASKTAB	tasktab

/* default paths for system binaries */
#if (CHIP == M68000)
#define KERNEL_PATH	"/usr/src/kernel/kernel.mix"
#define MM_PATH		"/usr/src/mm/mm.mix"
#define FS_PATH		"/usr/src/fs/fs.mix"
#else
#define KERNEL_PATH	"/usr/src/kernel/kernel"
#define MM_PATH		"/usr/src/mm/mm"
#define FS_PATH		"/usr/src/fs/fs"
# endif

#define	KMEM_PATH	"/dev/kmem"	/* opened for kernel proc table */
#define	MEM_PATH	"/dev/mem"	/* opened for mm/fs + user processes */

int kmemfd, memfd;			/* file descriptors of [k]mem */

#define DBASE_PATH	"/etc/psdatabase"	/* path of ps's database */
#define DBASE_MODE	0644			/* mode for ps's database */

/* paths for system binaries (not relevant if database is used) */
char *kpath = KERNEL_PATH;
char *mpath = MM_PATH;
char *fpath = FS_PATH;

struct tasktab tasktab[NR_TASKS + INIT_PROC_NR + 1];	/* task table */

/*
 * Short and long listing formats:
 *
 *   PID TTY  TIME CMD
 * ppppp  ttmmm:ss ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
 * 
 *   F S UID   PID  PPID  PGRP ADDR  SZ        RECV TTY  TIME CMD
 * fff s uuu ppppp ppppp ppppp aaaa sss rrrrrrrrrrr  ttmmm:ss cccccccccccccccccccc
 * (RAMDSK) FS
 * or
 * (PAUSE) MM
 */
#define S_HEADER "  PID TTY  TIME CMD\n"
#define S_FORMAT "%5d  %3s%3ld:%02ld %.62s\n"
#define L_HEADER "  F S UID   PID  PPID  PGRP ADDR  SZ        RECV TTY  TIME CMD\n"
#define L_FORMAT "%3o %c %3d %5d %5d %5d %4d %3d %11s  %3s%3ld:%02ld %.19s\n"

struct pstat {				/* structure filled by pstat() */
	dev_t ps_dev;			/* major/minor of controlling tty */
	uid_t ps_ruid;			/* real uid */
	uid_t ps_euid;			/* effective uid */
	pid_t ps_pid;			/* process id */
	pid_t ps_ppid;			/* parent process id */
	int ps_pgrp;			/* parent process id */
	int ps_flags;			/* kernel flags */
	int ps_mflags;			/* mm flags */
	int ps_ftask;			/* (possibly pseudo) fs suspend task */
	char ps_state;			/* process state */
	size_t ps_tsize;		/* text size (in bytes) */
	size_t ps_dsize;		/* data size (in bytes) */
	size_t ps_ssize;		/* stack size (in bytes) */
	off_t ps_text;			/* physical text offset */
	off_t ps_data;			/* physical data offset */
	off_t ps_stack;			/* physical stack offset */
	int ps_recv;			/* process number to receive from */
	time_t ps_utime;		/* accumulated user time */
	time_t ps_stime;		/* accumulated system time */
	char *ps_args;			/* concatenated argument string */
};

/* ps_state field values in pstat struct above */
#define	Z_STATE		'Z'		/* Zombie */
#define	W_STATE		'W'		/* Waiting */
#define	S_STATE		'S'		/* Sleeping */
#define	R_STATE		'R'		/* Runnable */
#define	T_STATE		'T'		/* stopped (Trace) */

/*
 * Tname returns mnemonic string for dev_nr.  This is "?" for unknown maj/min
 * pairs.  It is utterly rigid in this implementation...
 */
char *tname(dev_nr)
{
	static char buf[4];
	
	if (majdev(dev_nr) != TTY_MAJ ||	/* yuchhh! */
	    mindev(dev_nr) < 0 || mindev(dev_nr) >= 100)
		return "?  ";
	if (mindev(dev_nr) == 0)
		return "co ";

	sprintf(buf, "t%-2d", mindev(dev_nr));
	return buf;
}

/* return canonical task name of task p_nr; overwritten on each call */
char *taskname(p_nr)
{
	char *cp;
	
	if (p_nr < -NR_TASKS || p_nr > INIT_PROC_NR)
		return "?";
	
	/* strip trailing blanks for right-adjusted output */
	for (cp = tasktab[p_nr + NR_TASKS].name; *cp != '\0'; cp++)
		if (*cp == ' ')
			break;
	*cp = '\0';		
	
	return tasktab[p_nr + NR_TASKS].name;
}

/*
 * Prrecv prints the RECV field for process with pstat buffer pointer bufp.
 * This is either "ANY", "taskname", or "(blockreason) taskname".
 */
char *prrecv(bufp)
struct pstat *bufp;
{
	char *blkstr, *task;		/* reason for blocking and task */
	static char recvstr[20];

	if (bufp->ps_recv == ANY)
		return "ANY";

	task = taskname(bufp->ps_recv);
	if (bufp->ps_state != S_STATE)
		return task;
	
	blkstr = "?";
	if (bufp->ps_recv == MM_PROC_NR) {
		if (bufp->ps_mflags & PAUSED)
			blkstr = "pause";
		else if (bufp->ps_mflags & WAITING)
			blkstr = "wait";
	}
	else if (bufp->ps_recv == FS_PROC_NR) {
		if (-bufp->ps_ftask == XOPEN)
			blkstr = "xopen";
		else if (-bufp->ps_ftask == XPIPE)
			blkstr = "xpipe";
		else
			blkstr = taskname(-bufp->ps_ftask);	
	}
	
	(void) sprintf(recvstr, "(%s) %s", blkstr, task);
	return recvstr;
}

/*
 * Main interprets arguments, gets system addresses, opens [k]mem, reads in
 * process tables from kernel/mm/fs and calls pstat() for relevant entries.
 */
main(argc, argv)
char *argv[];
{
	int i;
	struct pstat buf;
	int db_fd;
	int uid = getuid();		/* real uid of caller */
	int opt_all = FALSE;		/* -a */
	int opt_long = FALSE;		/* -l */
	int opt_notty = FALSE;		/* -x */
	int opt_update = FALSE;		/* -U */

	/* parse arguments; a '-' need not be present (V7/BSD compatability) */
	switch (argc) {
	case 1:		/* plain ps */
		break;
	case 2:		/* ps <[-][alxU]> */
	case 5:		/* ps <[-][alxU]> <kernel mm fs> */
		for (i = (argv[1][0] == '-' ? 1 : 0); argv[1][i] != '\0'; i++)
			switch (argv[1][i]) {
			case 'a':
				opt_all = TRUE;
				break;
			case 'l':
				opt_long = TRUE;
				break;
			case 'x':
				opt_notty = TRUE;
				break;
			case 'U':
				opt_update = TRUE;
				break;
			default:
				usage(argv[0]);
			}	
		break;
	case 4:		/* ps <kernel mm fs> */
		if (argv[1][0] != '-')
			break;
	default:
		usage(argv[0]);
	}
	
	if (argc >= 4) {	/* ps [-][alxU] <kernel mm fs> */
		kpath = argv[argc - 3];
		mpath = argv[argc - 2];
		fpath = argv[argc - 1];
	}
	
	/* fill the sysinfo struct with system address information */
	if (opt_update || (db_fd = open(DBASE_PATH, O_RDONLY)) == -1) {
		strncpy(sysinfo.ke_proc[0].n_name, ID_PROC, NAME_SIZ);
		strncpy(sysinfo.ke_tasktab[0].n_name, ID_TASKTAB, NAME_SIZ);
		if (nlist(kpath, sysinfo.ke_proc) != 0 ||
		    nlist(kpath, sysinfo.ke_tasktab) != 0)
			err("Can't read kernel namelist");
		strncpy(sysinfo.mm_mproc[0].n_name, ID_MPROC, NAME_SIZ);
		if (nlist(mpath, sysinfo.mm_mproc) != 0)
			err("Can't read mm namelist");
		strncpy(sysinfo.fs_fproc[0].n_name, ID_FPROC, NAME_SIZ);
		if (nlist(fpath, sysinfo.fs_fproc) != 0)
			err("Can't read fs namelist");
		if (opt_update) {
			if ((db_fd = creat(DBASE_PATH, DBASE_MODE)) == -1)
				err("Can't creat psdatabase");
			if (write(db_fd, (char *) &sysinfo,
				  sizeof(sysinfo_t)) != sizeof(sysinfo_t))
				err("Can't write psdatabase");
		}		
	}
	else {
		if (read(db_fd, (char *) &sysinfo,
			 sizeof(sysinfo_t)) != sizeof(sysinfo_t))
			err("Can't read psdatabase");	 
	}
	(void) close (db_fd);
	    	
	/* get kernel tables */    	
	if ((kmemfd = open(KMEM_PATH, O_RDONLY)) == -1)
		err(KMEM_PATH);
	if (addrread(kmemfd, (phys_clicks) 0,
		     (vir_bytes) sysinfo.ke_proc[0].n_value,
		     (char *) PROC, sizeof(PROC)) != sizeof(PROC))
		err("Can't get kernel proc table from /dev/kmem");
	if (addrread(kmemfd, (phys_clicks) 0,
		     (vir_bytes) sysinfo.ke_tasktab[0].n_value,
		     (char *) TASKTAB, sizeof(TASKTAB)) != sizeof(TASKTAB))
		err("Can't get kernel task table from /dev/kmem");

	/* get mm/fs tables */
	if ((memfd = open(MEM_PATH, O_RDONLY)) == -1)
		err(MEM_PATH);
	if (addrread(memfd, PROC[NR_TASKS + MM_PROC_NR].p_map[D].mem_phys,
		     (vir_bytes) sysinfo.mm_mproc[0].n_value,
		     (char *) MPROC, sizeof(MPROC)) != sizeof(MPROC))
		err("Can't get mm proc table from /dev/mem");
	if (addrread(memfd, PROC[NR_TASKS + FS_PROC_NR].p_map[D].mem_phys,
		     (vir_bytes) sysinfo.fs_fproc[0].n_value,
		     (char *) FPROC, sizeof(FPROC)) != sizeof(FPROC))
		err("Can't get fs proc table from /dev/mem");
		
	/* now loop through process table and handle each entry */
	printf("%s", opt_long ? L_HEADER : S_HEADER);
	for (i = -NR_TASKS; i < NR_PROCS; i++) {
		if (pstat(i, &buf) != -1 &&
		    (opt_all || buf.ps_euid == uid || buf.ps_ruid == uid) &&
		    (opt_notty || majdev(buf.ps_dev) == TTY_MAJ))
			if (opt_long)
				printf(L_FORMAT,
				       buf.ps_flags, buf.ps_state,
				       buf.ps_euid, buf.ps_pid, buf.ps_ppid,
				       buf.ps_pgrp,
				       off_to_k(buf.ps_text),
				       off_to_k((buf.ps_stack + buf.ps_ssize
				       			- buf.ps_text)),
				       (buf.ps_flags & RECEIVING ?
						prrecv(&buf) :
				       		""),
				       tname(buf.ps_dev),
				       (buf.ps_utime + buf.ps_stime) / HZ / 60,
				       (buf.ps_utime + buf.ps_stime) / HZ % 60,
				       i <= INIT_PROC_NR ? taskname(i) :
						(buf.ps_args == NULL ? "" :
					   		buf.ps_args));
			else
				printf(S_FORMAT,
				       buf.ps_pid, tname(buf.ps_dev),
				       (buf.ps_utime + buf.ps_stime) / HZ / 60,
				       (buf.ps_utime + buf.ps_stime) / HZ % 60,
				       i <= INIT_PROC_NR ? taskname(i) :
						(buf.ps_args == NULL ? "" :
					   		buf.ps_args));
	}
}

/*
 * Get_args inspects /dev/mem, using bufp, and tries to locate the initial
 * stack frame pointer, i.e. the place where the stack started at exec time.
 * It is assumed that the end of the stack frame looks as follows:
 *	argc	<-- initial stack frame starts here
 *	argv[0]
 *	...
 *	NULL	(*)
 *	envp[0]
 *	...
 *	NULL	(**)
 *	argv[0][0] ... '\0'
 *	...
 *	argv[argc - 1][0] ... '\0'
 *	envp[0][0] ... '\0'
 *	...
 *	[trailing '\0']
 * Where the total space occupied by this original stack frame <= ARG_MAX.
 * Get_args reads in the last ARG_MAX bytes of the process' data, and
 * searches back for two NULL ptrs (hopefully the (*) & (**) above).
 * If it finds such a portion, it continues backwards, counting ptrs until:
 * a) either a word is found that has as its value the count (supposedly argc),
 * b) another NULL word is found, in which case the algorithm is reiterated, or
 * c) we wind up before the start of the buffer and fail.
 * Upon success, get_args returns a pointer to the conactenated arg list.
 * Warning: this routine is inherently unreliable and probably doesn't work if
 * ptrs and ints have different sizes.
 */
char *get_args(bufp)
struct pstat *bufp;
{
	union {
#if (CHIP == M68000)
		long stk_i;
#else
		int stk_i;
#endif
		char *stk_cp;
		char stk_c;
	} stk[ARG_MAX / sizeof(char *)], *sp;
	enum {INITIAL, DONE, FAIL, NULL1, NULL2} state;
	int nargv;		/* guessed # of (non-NULL) argv pointers seen */
	int cnt;		/* # of bytes read from stack frame */
	int neos;		/* # of '\0's seen in argv string space */
	off_t l;
	char *cp, *args;
	
	
	if (bufp->ps_ssize < ARG_MAX)
		cnt = bufp->ps_ssize;
	else
		cnt = ARG_MAX;
	/* get last cnt bytes from user stack */
	if (addrread(memfd, (phys_clicks) (bufp->ps_stack >> CLICK_SHIFT),
		     (vir_bytes) (bufp->ps_ssize - cnt),
		     (char *) stk, cnt) != cnt)
		return NULL;
	
	state = INITIAL;
	sp = &stk[cnt / sizeof(char *)];
	while (state != DONE && state != FAIL) {
		if (--sp < &stk[0])
			state = FAIL;	/* wound up before start of buffer */
		switch(state) {
		case INITIAL:	/* no NULL seen yet */
			if (sp[0].stk_cp == NULL)
				state = NULL1;
			break;
		case NULL1:	/* one NULL seen */	
			if (sp[0].stk_cp == NULL) {
				nargv = 0;	/* start counting argv ptrs */
				state = NULL2;
			}	
			/*
			 * What follows is a dirty patch to recognize sh's 
			 * stack frame when it has assigned argv[0] to argv[1],
			 * and has thus blown away its NULL pointer there.
			 */
			else if (sp > &stk[0] && sp[0].stk_cp == sp[-1].stk_cp){
				nargv = 0;
				state = NULL2;
			}
			break;
		case NULL2:	/* two NULLs seen */
			if (sp[0].stk_cp == NULL)
				nargv = 0;	/* restart counting */
			else if (sp[0].stk_i == nargv)
				state = DONE;	/* think i got it */
			/* next is same ugly patch as above */	
			else if (sp > &stk[0] && sp[0].stk_cp == sp[-1].stk_cp)
				nargv = 0;
			else
				nargv++;	/* ? some argv pointer ? */
			break;
		default:	/* FAIL or DONE */
			break;
		}	
	}
	
	if (state != DONE)
		return NULL;

	/* get a local version of argv[0]; l is offset back from end of stack */
	l = bufp->ps_stack + bufp->ps_ssize -
#if (CHIP == INTEL)
		bufp->ps_data - 
#endif
		(vir_bytes) sp[1].stk_cp;
	if (l < 0 || l > cnt)
		return NULL;
	args = &((char *) stk)[cnt - (int) l];
	neos = 0;
	for (cp = args; cp < &((char *) stk)[cnt]; cp++)
		if (*cp == '\0')
			if (++neos >= sp[0].stk_i)
				break;
			else
				*cp = ' ';	
	if (neos != sp[0].stk_i)
		return NULL;			

	return args;
}

/*
 * Pstat collects info on process number p_nr and returns it in buf.
 * It is assumed that tasks do not have entries in fproc/mproc.
 */
int pstat(p_nr, bufp)
struct pstat *bufp;
{
	int p_ki = p_nr + NR_TASKS;	/* kernel proc index */
	
	if (p_nr < -NR_TASKS || p_nr >= NR_PROCS)
		return -1;
	
	if ((PROC[p_ki].p_flags & P_SLOT_FREE) &&
	    !(MPROC[p_nr].mp_flags & IN_USE))
		return -1;

	bufp->ps_flags = PROC[p_ki].p_flags;
	
	if (p_nr >= 0) {
		bufp->ps_dev = FPROC[p_nr].fs_tty;
		bufp->ps_ftask = FPROC[p_nr].fp_task;
	}	
	else {
		bufp->ps_dev = 0;
		bufp->ps_ftask = 0;
	}

	if (p_nr >= 0) {
		bufp->ps_ruid = MPROC[p_nr].mp_realuid;	
		bufp->ps_euid = MPROC[p_nr].mp_effuid;	
		bufp->ps_pid = MPROC[p_nr].mp_pid;
		bufp->ps_ppid = MPROC[MPROC[p_nr].mp_parent].mp_pid;
		bufp->ps_pgrp = MPROC[p_nr].mp_procgrp;
		bufp->ps_mflags = MPROC[p_nr].mp_flags;
	}
	else {
		bufp->ps_pid = bufp->ps_ppid = 0;
		bufp->ps_ruid = bufp->ps_euid = 0;
		bufp->ps_pgrp = 0;
		bufp->ps_mflags = 0;
	}	
	
	/* state is interpretation of combined kernel/mm flags for non-tasks */
	if (p_nr >= 0) {				/* non-tasks */
		if (MPROC[p_nr].mp_flags & HANGING)
			bufp->ps_state = Z_STATE;	/* zombie */
		else if (MPROC[p_nr].mp_flags & STOPPED)
			bufp->ps_state = T_STATE;	/* stopped (traced) */
		else if (PROC[p_ki].p_flags == 0)
			bufp->ps_state = R_STATE;	/* in run-queue */
		else if (MPROC[p_nr].mp_flags & (WAITING | PAUSED) ||
			 FPROC[p_nr].fp_suspended == SUSPENDED)
			bufp->ps_state = S_STATE;	/* sleeping */
		else	
			bufp->ps_state = W_STATE;	/* a short wait */
	}
	else {						/* tasks are simple */
		if (PROC[p_ki].p_flags == 0)
			bufp->ps_state = R_STATE;	/* in run-queue */
		else
			bufp->ps_state = W_STATE;	/* other i.e. waiting */
	}		
		
	bufp->ps_tsize = (size_t) PROC[p_ki].p_map[T].mem_len << CLICK_SHIFT;
	bufp->ps_dsize = (size_t) PROC[p_ki].p_map[D].mem_len << CLICK_SHIFT;
	bufp->ps_ssize = (size_t) PROC[p_ki].p_map[S].mem_len << CLICK_SHIFT;
	bufp->ps_text = (off_t) PROC[p_ki].p_map[T].mem_phys << CLICK_SHIFT;
	bufp->ps_data = (off_t) PROC[p_ki].p_map[D].mem_phys << CLICK_SHIFT;
	bufp->ps_stack = (off_t) PROC[p_ki].p_map[S].mem_phys << CLICK_SHIFT;
	
	bufp->ps_recv = PROC[p_ki].p_getfrom;
	
	bufp->ps_utime = PROC[p_ki].user_time;
	bufp->ps_stime = PROC[p_ki].sys_time;
	
	if (bufp->ps_state == Z_STATE)
		bufp->ps_args = "<defunct>";
	else if (p_nr > INIT_PROC_NR)
		bufp->ps_args = get_args(bufp);
	
	return 0;
}

/*
 * Addrread reads nbytes from offset addr to click base of fd into buf.
 */
int addrread(fd, base, addr, buf, nbytes)
phys_clicks base;
vir_bytes addr;
char *buf;
{
	extern long lseek();
    
	if (lseek(fd, ((long) base << CLICK_SHIFT) + (long) addr, 0) < 0)
		return -1;

	return read(fd, buf, nbytes);
}

usage(pname)
char *pname;
{
	fprintf(stderr, "Usage: %s [-][alxU] [kernel mm fs]\n", pname);
	exit(1);
}

err(s)
char *s;
{
	perror(s);
	exit(2);
}	

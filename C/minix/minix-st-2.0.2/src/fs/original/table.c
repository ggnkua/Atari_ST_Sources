/* This file contains the table used to map system call numbers onto the
 * routines that perform them.
 */

#define _TABLE

#include "fs.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "buf.h"
#include "dev.h"
#include "file.h"
#include "fproc.h"
#include "inode.h"
#include "lock.h"
#include "super.h"

PUBLIC _PROTOTYPE (int (*call_vector[NCALLS]), (void) ) = {
	no_sys,		/*  0 = unused	*/
	do_exit,	/*  1 = exit	*/
	do_fork,	/*  2 = fork	*/
	do_read,	/*  3 = read	*/
	do_write,	/*  4 = write	*/
	do_open,	/*  5 = open	*/
	do_close,	/*  6 = close	*/
	no_sys,		/*  7 = wait	*/
	do_creat,	/*  8 = creat	*/
	do_link,	/*  9 = link	*/
	do_unlink,	/* 10 = unlink	*/
	no_sys,		/* 11 = waitpid	*/
	do_chdir,	/* 12 = chdir	*/
	do_time,	/* 13 = time	*/
	do_mknod,	/* 14 = mknod	*/
	do_chmod,	/* 15 = chmod	*/
	do_chown,	/* 16 = chown	*/
	no_sys,		/* 17 = break	*/
	do_stat,	/* 18 = stat	*/
	do_lseek,	/* 19 = lseek	*/
	no_sys,		/* 20 = getpid	*/
	do_mount,	/* 21 = mount	*/
	do_umount,	/* 22 = umount	*/
	do_set,		/* 23 = setuid	*/
	no_sys,		/* 24 = getuid	*/
	do_stime,	/* 25 = stime	*/
	no_sys,		/* 26 = ptrace	*/
	no_sys,		/* 27 = alarm	*/
	do_fstat,	/* 28 = fstat	*/
	no_sys,		/* 29 = pause	*/
	do_utime,	/* 30 = utime	*/
	no_sys,		/* 31 = (stty)	*/
	no_sys,		/* 32 = (gtty)	*/
	do_access,	/* 33 = access	*/
	no_sys,		/* 34 = (nice)	*/
	no_sys,		/* 35 = (ftime)	*/
	do_sync,	/* 36 = sync	*/
	no_sys,		/* 37 = kill	*/
	do_rename,	/* 38 = rename	*/
	do_mkdir,	/* 39 = mkdir	*/
	do_unlink,	/* 40 = rmdir	*/
	do_dup,		/* 41 = dup	*/
	do_pipe,	/* 42 = pipe	*/
	do_tims,	/* 43 = times	*/
	no_sys,		/* 44 = (prof)	*/
	no_sys,		/* 45 = unused	*/
	do_set,		/* 46 = setgid	*/
	no_sys,		/* 47 = getgid	*/
	no_sys,		/* 48 = (signal)*/
	no_sys,		/* 49 = unused	*/
	no_sys,		/* 50 = unused	*/
	no_sys,		/* 51 = (acct)	*/
	no_sys,		/* 52 = (phys)	*/
	no_sys,		/* 53 = (lock)	*/
	do_ioctl,	/* 54 = ioctl	*/
	do_fcntl,	/* 55 = fcntl	*/
	no_sys,		/* 56 = (mpx)	*/
	no_sys,		/* 57 = unused	*/
	no_sys,		/* 58 = unused	*/
	do_exec,	/* 59 = execve	*/
	do_umask,	/* 60 = umask	*/
	do_chroot,	/* 61 = chroot	*/
	do_setsid,	/* 62 = setsid	*/
	no_sys,		/* 63 = getpgrp	*/

	no_sys,		/* 64 = KSIG: signals originating in the kernel	*/
	do_unpause,	/* 65 = UNPAUSE	*/
	no_sys, 	/* 66 = unused  */
	do_revive,	/* 67 = REVIVE	*/
	no_sys,		/* 68 = TASK_REPLY	*/
	no_sys,		/* 69 = unused */
	no_sys,		/* 70 = unused */
	no_sys,		/* 71 = SIGACTION */
	no_sys,		/* 72 = SIGSUSPEND */
	no_sys,		/* 73 = SIGPENDING */
	no_sys,		/* 74 = SIGPROCMASK */
	no_sys,		/* 75 = SIGRETURN */
	no_sys,		/* 76 = REBOOT */
};


/* Some devices may or may not be there in the next table. */
#define DT(enable, open, rw, close, task) \
	{ (enable ? (open) : no_dev), (enable ? (rw) : no_dev), \
	  (enable ? (close) : no_dev), (enable ? (task) : 0) },

/* The order of the entries here determines the mapping between major device
 * numbers and tasks.  The first entry (major device 0) is not used.  The
 * next entry is major device 1, etc.  Character and block devices can be
 * intermixed at random.  If this ordering is changed, the devices in
 * <include/minix/boot.h> must be changed to correspond to the new values.
 * Note that the major device numbers used in /dev are NOT the same as the 
 * task numbers used inside the kernel (as defined in <include/minix/com.h>).
 * Also note that if /dev/mem is changed from 1, NULL_MAJOR must be changed
 * in <include/minix/com.h>.
 */
PUBLIC struct dmap dmap[] = {
/*  ?   Open       Read/Write   Close       Task #      Device  File
    -   ----       ----------   -----       -------     ------  ----       */
  DT(1, no_dev,    no_dev,      no_dev,     0)           /* 0 = not used   */
  DT(1, dev_opcl,  call_task,   dev_opcl,   MEM)         /* 1 = /dev/mem   */
  DT(1, dev_opcl,  call_task,   dev_opcl,   FLOPPY)      /* 2 = /dev/fd0   */
  DT(ENABLE_WINI,
        dev_opcl,  call_task,   dev_opcl,   WINCHESTER)  /* 3 = /dev/hd0   */
  DT(1, tty_open,  call_task,   dev_opcl,   TTY)         /* 4 = /dev/tty00 */
  DT(1, ctty_open, call_ctty,   ctty_close, TTY)         /* 5 = /dev/tty   */
  DT(1, dev_opcl,  call_task,   dev_opcl,    PRINTER)     /* 6 = /dev/lp    */

#if (MACHINE == IBM_PC)
  DT(ENABLE_NETWORKING,
        net_open,  call_task,   dev_opcl,   INET_PROC_NR)/* 7 = /dev/ip    */
  DT(ENABLE_CDROM,
        dev_opcl,  call_task,   dev_opcl,   CDROM)       /* 8 = /dev/cd0   */
  DT(0, 0,         0,           0,          0)           /* 9 = not used   */
  DT(ENABLE_SCSI,
        dev_opcl,  call_task,   dev_opcl,   SCSI)        /*10 = /dev/sd0   */
  DT(0, 0,         0,           0,          0)           /*11 = not used   */
  DT(ENABLE_DOSDSK,
        dev_opcl,  call_task,   dev_opcl,   DOSDSK)      /*12 = /dev/dosd0 */
  DT(ENABLE_AUDIO,
        dev_opcl,  call_task,   dev_opcl,   AUDIO)       /*13 = /dev/audio */
  DT(ENABLE_AUDIO,
        dev_opcl,  call_task,   dev_opcl,   MIXER)       /*14 = /dev/mixer */
#endif /* IBM_PC */

#if (MACHINE == ATARI)
  DT(ENABLE_SCSI,
        dev_opcl,  call_task,   dev_opcl,   SCSI)        /* 7 = /dev/hdscsi0 */
#endif
};

PUBLIC int max_major = sizeof(dmap)/sizeof(struct dmap);

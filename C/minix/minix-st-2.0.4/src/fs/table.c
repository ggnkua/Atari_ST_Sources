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

PUBLIC _PROTOTYPE (int (*call_vec[]), (void) ) = {
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
#if ENABLE_SYMLINKS
	do_rdlink,	/* 49 = readlink */
	do_lstat,	/* 50 = lstat	*/
#else
	no_sys,		/* 49 = unused	*/
	no_sys,		/* 50 = unused	*/
#endif /* ENABLE_SYMLINKS */
	no_sys,		/* 51 = (acct)	*/
	no_sys,		/* 52 = (phys)	*/
	no_sys,		/* 53 = (lock)	*/
	do_ioctl,	/* 54 = ioctl	*/
	do_fcntl,	/* 55 = fcntl	*/
	no_sys,		/* 56 = (mpx)	*/
#if ENABLE_SYMLINKS
	do_symlink,	/* 57 = symlink	*/
#else
	no_sys,		/* 57 = unused	*/
#endif /* ENABLE_SYMLINKS */
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
	do_reboot,	/* 76 = REBOOT */
	do_svrctl,	/* 77 = SVRCTL */
};
/* This should not fail with "array size is negative": */
extern int dummy[sizeof(call_vec) == NCALLS * sizeof(call_vec[0]) ? 1 : -1];


/* Some devices may or may not be there in the next table. */
#define DT(enable, opcl, io, task) \
  { (enable ? (opcl) : no_dev), (enable ? (io) : 0), (enable ? (task) : 0) },

/* The order of the entries here determines the mapping between major device
 * numbers and tasks.  The first entry (major device 0) is not used.  The
 * next entry is major device 1, etc.  Character and block devices can be
 * intermixed at random.  This ordering determines the device numbers in
 * /dev/ and is thereby more or less cast in stone once allocated.
 * Note that the major device numbers used in /dev are NOT the same as the 
 * task numbers used inside the kernel (as defined in <include/minix/com.h>).
 * Also note that FS knows the device number of /dev/ram to load the RAM disk.
 */
PUBLIC struct dmap dmap[] = {
/*   ?                 Open/Close  I/O       Task #       Device  File
     -                 ----------  --------  -----------  ------  ----       */
  DT(1,                no_dev,     0,        0)            /* 0 = not used   */
  DT(1,                gen_opcl,   gen_io,   MEM)          /* 1 = /dev/mem   */
  DT(1,                gen_opcl,   gen_io,   FLOPPY)       /* 2 = /dev/fd0   */
  DT(NR_CTRLRS >= 1,   gen_opcl,   gen_io,   CTRLR(0))     /* 3 = /dev/c0    */
  DT(1,                tty_opcl,   gen_io,   TTY)          /* 4 = /dev/tty00 */
  DT(1,                ctty_opcl,  ctty_io,  TTY)          /* 5 = /dev/tty   */
  DT(ENABLE_PRINTER,   gen_opcl,   gen_io,   PRINTER)      /* 6 = /dev/lp    */

#if (MACHINE == IBM_PC)
  DT(1,                no_dev,     0,        ANY)          /* 7 = /dev/ip    */
  DT(NR_CTRLRS >= 2,   gen_opcl,   gen_io,   CTRLR(1))     /* 8 = /dev/c1    */
  DT(0,                0,          0,        0)            /* 9 = not used   */
  DT(NR_CTRLRS >= 3,   gen_opcl,   gen_io,   CTRLR(2))     /*10 = /dev/c2    */
  DT(0,                0,          0,        0)            /*11 = not used   */
  DT(NR_CTRLRS >= 4,   gen_opcl,   gen_io,   CTRLR(3))     /*12 = /dev/c3    */
  DT(ENABLE_SB16,      gen_opcl,   gen_io,   SB16)         /*13 = /dev/audio */
  DT(ENABLE_SB16,      gen_opcl,   gen_io,   SB16MIXER)    /*14 = /dev/mixer */
#endif /* IBM_PC */
#if (MACHINE == ATARI)
  DT(1,                no_dev,     0,        ANY)          /* 7 = /dev/ip    */
#endif /* MACHINE == ATARI */
};

PUBLIC int max_major = sizeof(dmap)/sizeof(struct dmap);

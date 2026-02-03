#ifndef _MINTBIND_H
#define _MINTBIND_H

#ifdef __TURBOC__
# ifndef __TOS
#  include <tos.h>
# endif
#else
#ifndef _OSBIND_H
#include <osbind.h>
#endif
#endif

#ifdef __GNUC_INLINE__
#define trap_1_wwlw(n, a, b, c)						\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	short  _c = (short) (c);					\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addw    #10,sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#define trap_1_wwww(n, a, b, c)						\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short  _b = (short)(b);						\
	short  _c = (short)(c);						\
	    								\
	__asm__ volatile						\
	("\
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addw    #10,sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#define trap_1_wwl(n, a, b)						\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	    								\
	__asm__ volatile						\
	("\
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addw    #8,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})

#else

#ifdef __GNUC__
# ifndef __MSHORT__
#  define __LONG_TRAPS__
# endif
#endif

#ifndef __LONG_TRAPS__
# ifndef trap_1_w
#  define trap_1_w(n)		gemdos(n)
#  define trap_1_wl(n,a)		gemdos(n, (long)(a))
#  define trap_1_wll(n, a, b)	gemdos(n, (long)(a), (long)(b))
#  define trap_1_ww(n,a)		gemdos(n, a)
#  define trap_1_www(n,a,b)	gemdos(n, a, b)
#  define trap_1_wwlll(n,a,b,c,d) gemdos(n, a, (long)(b), (long)(c), (long)(d))
#  define trap_1_wwll(n, a, b, c)	gemdos(n, a, (long)(b), (long)(c))
#  define trap_1_wlw(n, a, b)	gemdos(n, (long)(a), b)
#  define trap_1_wlww(n, a, b, c)	gemdos(n, (long)(a), b, c)
#  define trap_13_w(n)		bios(n)
#  define trap_14_w(n)		xbios(n)
# endif
# define trap_1_wwlw(n,a,b,c)	gemdos(n, a, (long)(b), c)
# define trap_1_wwww(n,a,b,c)	gemdos(n, a, b, c)
# define trap_1_wwl(n, a, b)	gemdos(n, a, (long)(b))
#endif /* __LONG_TRAPS__ */

#endif /* __GNUC_INLINE__ */

/* note: none of these functions is declared as (void), despite
 * what the man pages say; this is so that programs can check
 * for a -32 return error from TOS if MiNT is not installed
 */

#define	Syield()						\
		(short)trap_1_w(0xff)
#define Fpipe(ptr)						\
		(short)trap_1_wl(0x100, (long)(ptr))
#define Fcntl(f, arg, cmd)					\
		trap_1_wwlw(0x104, (short)(f), (long)(arg), (short)(cmd))
#define Finstat(f)						\
		trap_1_ww(0x105, (short)(f))
#define Foutstat(f)						\
		trap_1_ww(0x106, (short)(f))
#define Fgetchar(f, mode)					\
		trap_1_www(0x107, (short)(f), (short)(mode))
#define Fputchar(f, ch, mode)					\
		trap_1_wwlw(0x108, (short)(f), (long)(ch), (short)(mode))

#define Pwait()							\
		trap_1_w(0x109)
#define Pnice(delta)						\
		(short)trap_1_ww(0x10a, (short)(delta))
#define Pgetpid()						\
		(short)trap_1_w(0x10b)
#define Pgetppid()						\
		(short)trap_1_w(0x10c)
#define Pgetpgrp()						\
		(short)trap_1_w(0x10d)
#define Psetpgrp(pid, grp)					\
		(short)trap_1_www(0x10e, (short)(pid), (short)(grp))
#define Pgetuid()						\
		(short)trap_1_w(0x10f)
#define Psetuid(id)						\
		(short)trap_1_ww(0x110, (short)(id))
#define Pkill(pid, sig)						\
		(short)trap_1_www(0x111, (short)(pid), (short)(sig))
#define Psignal(sig, handler)					\
		trap_1_wwl(0x112, (short)(sig), (long)(handler))
#define Pvfork()						\
		(short)trap_1_w(0x113)
#define Pgetgid()						\
		(short)trap_1_w(0x114)
#define Psetgid(id)						\
		(short)trap_1_ww(0x115, (short)(id))
#define Psigblock(mask)						\
		trap_1_wl(0x116, (unsigned long)(mask))
#define Psigsetmask(mask)					\
		trap_1_wl(0x117, (unsigned long)(mask))
#define Pusrval(arg)						\
		trap_1_wl(0x118, (long)(arg))
#define Pdomain(arg)						\
		(short)trap_1_ww(0x119, (short)(arg))
#define Psigreturn()						\
		(short)trap_1_w(0x11a)
#define Pfork()							\
		(short)trap_1_w(0x11b)
#define Pwait3(flag, rusage)					\
		trap_1_wwl(0x11c, (short)(flag), (long)(rusage))
#define Fselect(time, rfd, wfd, xfd)				\
		(short)trap_1_wwlll(0x11d, (unsigned short)(time), (long)(rfd), \
				(long)(wfd), (long)(xfd))
#define Prusage(rsp)						\
		(short)trap_1_wl(0x11e, (long)(rsp))
#define Psetlimit(i, val)					\
		trap_1_wwl(0x11f, (short)(i), (long)(val))

#define Talarm(sec)						\
		trap_1_wl(0x120, (long)(sec))
#define Pause()							\
		(short)trap_1_w(0x121)
#define Sysconf(n)						\
		trap_1_ww(0x122, (short)(n))
#define Psigpending()						\
		trap_1_w(0x123)
#define Dpathconf(name, which)					\
		trap_1_wlw(0x124, (long)(name), (short)(which))

#define Pmsg(mode, mbox, msg)					\
		trap_1_wwll(0x125, (short)(mode), (long)(mbox), (long)(msg))
#define Fmidipipe(pid, in, out)					\
		trap_1_wwww(0x126, (short)(pid), (short)(in),(short)(out))
#define Prenice(pid, delta)					\
		(short)trap_1_www(0x127, (short)(pid), (short)(delta))
#define Dopendir(name, flag)					\
		trap_1_wlw(0x128, (long)(name), (short)(flag))
#define Dreaddir(len, handle, buf)				\
		trap_1_wwll(0x129, (short)(len), (long)(handle), (long)(buf))
#define Drewinddir(handle)					\
		trap_1_wl(0x12a, (long)(handle))
#define Dclosedir(handle)					\
		trap_1_wl(0x12b, (long)(handle))
#define Fxattr(flag, name, buf)					\
		trap_1_wwll(0x12c, (short)(flag), (long)(name), (long)(buf))
#define Flink(old, new)						\
		trap_1_wll(0x12d, (long)(old), (long)(new))
#define Fsymlink(old, new)					\
		trap_1_wll(0x12e, (long)(old), (long)(new))
#define Freadlink(siz, buf, linknm)				\
		trap_1_wwll(0x12f, (short)(siz), (long)(buf), (long)(linknm))
#define Dcntl(cmd, name, arg)					\
		trap_1_wwll(0x130, (short)(cmd), (long)(name), (long)(arg))
#define Fchown(name, uid, gid)					\
		trap_1_wlww(0x131, (long)(name), (short)(uid), (short)(gid))
#define Fchmod(name, mode)					\
		trap_1_wlw(0x132, (long)(name), (short)(mode))
#define Pumask(mask)						\
		(short)trap_1_ww(0x133, (short)(mask))
#define Psemaphore(mode, id, tmout)				\
		trap_1_wwll(0x134, (short)(mode), (long)(id), (long)(tmout))
#define Dlock(mode, drive)					\
		trap_1_www(0x135, (short)(mode), (short)(drive))
#define Psigpause(mask)						\
		(short)trap_1_wl(0x136, (unsigned long)(mask))
#define Psigaction(sig, act, oact)				\
		trap_1_wwll(0x137, (short)(sig), (long)(act), (long)(oact))
#define Pgeteuid()						\
		(short)trap_1_w(0x138)
#define Pgetegid()						\
		(short)trap_1_w(0x139)

#define SHMGETBLK	(('M'<< 8) | 0)
#define SIGUSR1 29
#define SIG_IGN (void*)1L

#define O_RWMODE  	0x03	/* isolates file read/write mode */
#	define O_RDONLY	0x00
#	define O_WRONLY	0x01
#	define O_RDWR	0x02
#	define O_EXEC	0x03	/* execute file; used by kernel only */

#define O_APPEND	0x08	/* all writes go to end of file */

#define O_SHMODE	0x70	/* isolates file sharing mode */
#	define O_COMPAT	0x00	/* compatibility mode */
#	define O_DENYRW	0x10	/* deny both read and write access */
#	define O_DENYW	0x20	/* deny write access to others */
#	define O_DENYR	0x30	/* deny read access to others */
#	define O_DENYNONE 0x40	/* don't deny any access to others */

#define O_NOINHERIT	0x80	/* children don't get this file descriptor */

#define O_NDELAY	0x100	/* don't block for i/o on this file */
#define O_CREAT		0x200	/* create file if it doesn't exist */
#define O_TRUNC		0x400	/* truncate file to 0 bytes if it does exist */
#define O_EXCL		0x800	/* fail open if file exists */

#define O_USER		0x0fff	/* isolates user-settable flag bits */

#define O_GLOBAL	0x1000	/* for Fopen: opens a global file handle */

/* kernel mode bits -- the user can't set these! */
#define O_TTY		0x2000	/* FILEPTR refers to a terminal */
#define O_HEAD		0x4000	/* FILEPTR is the master side of a fifo */
#define O_LOCK		0x8000	/* FILEPTR has had locking Fcntl's performed */


#endif /* _MINTBIND_H */

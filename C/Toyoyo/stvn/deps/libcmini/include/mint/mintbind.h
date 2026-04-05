
#ifndef _MINT_MINTBIND_H
#define _MINT_MINTBIND_H 1

#ifndef _FEATURES_H
# include <features.h>
#endif

#ifndef _MINT_OSBIND_H
# include <mint/osbind.h>
#endif

__BEGIN_DECLS

#if !defined(__XATTR) && !defined(__KERNEL__) && !defined(__KERNEL_MODULE__)
#define __XATTR
typedef struct xattr
{
	unsigned short st_mode;
	long           st_ino;	/* must be 32 bits */
	unsigned short st_dev;	/* must be 16 bits */
	unsigned short st_rdev;	/* not supported by the kernel */
	unsigned short st_nlink;
	unsigned short st_uid;	/* must be 16 bits */
	unsigned short st_gid;	/* must be 16 bits */
	long           st_size;
	long           st_blksize;
	long           st_blocks;
	struct {
		union {
			unsigned long  tv_sec; /* actually time&date in DOSTIME format */
			struct {
				unsigned short time;
				unsigned short date;
			} d;
		} u;
	} st_mtim;
#define st_mtime   st_mtim.u.tv_sec
	struct {
		union {
			unsigned long  tv_sec; /* actually time&date in DOSTIME format */
			struct {
				unsigned short time;
				unsigned short date;
			} d;
		} u;
	} st_atim;
#define st_atime   st_atim.u.tv_sec
	struct {
		union {
			unsigned long  tv_sec; /* actually time&date in DOSTIME format */
			struct {
				unsigned short time;
				unsigned short date;
			} d;
		} u;
	} st_ctim;
#define st_ctime   st_ctim.u.tv_sec
	short          st_attr;
	short res1;		/* reserved for future kernel use */
	long res2[2];
} XATTR;
#define FSTAT		(('F'<< 8) | 0)
#endif

/* see compiler.h for __extension__ and AND_MEMORY */

#define trap_1_wllw(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long  _b = (long) (b);						\
	short  _c = (short) (c);					\
	    								\
	__asm__ volatile						\
	(								\
		"movw	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(12),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wwlw(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	short  _c = (short) (c);					\
	    								\
	__asm__ volatile						\
	(								\
		"movw	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(10),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wwww(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short  _b = (short)(b);						\
	short  _c = (short)(c);						\
	    								\
	__asm__ volatile						\
	(								\
		"movw	%4,%%sp@-\n\t"					\
		"movw	%3,%%sp@-\n\t"					\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"addql	#8,%%sp"						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wwwl(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short  _b = (short)(b);						\
	long  _c = (long)(c);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%4,%%sp@-\n\t"					\
		"movw	%3,%%sp@-\n\t"					\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(10),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wwl(n, a, b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%3,%%sp@-\n\t"					\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"addql	#8,%%sp"						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wlllw(n, a, b, c, d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long) (a);						\
	long _b = (long) (b);						\
	long _c = (long) (c);						\
	short _d = (short) (d);						\
	    								\
	__asm__ volatile						\
	(								\
		"movw	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(16),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d) /* inputs  */	\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wlll(n, a, b, c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(14),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)	/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
									\
	retvalue;							\
})

#define trap_1_wwllll(n, a, b, c, d, e)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	long  _c = (long) (c);						\
	long  _d = (long) (d);						\
	long  _e = (long) (e);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%6,%%sp@-\n\t"					\
		"movl	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(20),%%sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e) /* inputs  */ \
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#define trap_1_wllll(n, a, b, c, d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(18),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c),				\
	  "r"(_d)				/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
									\
	retvalue;							\
})

#define trap_1_wwlllll(n, a, b, c, d, e, f)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
	long _e = (long)(e);						\
	long _f = (long)(f);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%7,%%sp@-\n\t"					\
		"movl	%6,%%sp@-\n\t"					\
		"movl	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(24),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c),				\
	  "r"(_d), "r"(_e), "r"(_f)		/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
									\
	retvalue;							\
})

#define trap_1_wlllll(n, a, b, c, d, e)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
	long _e = (long)(e);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%6,%%sp@-\n\t"					\
		"movl	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(22),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c),				\
	  "r"(_d), "r"(_e)			/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
									\
	retvalue;							\
})

#define trap_1_wllllll(n, a, b, c, d, e, f)				\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
	long _e = (long)(e);						\
	long _f = (long)(f);						\
	    								\
	__asm__ volatile						\
	(								\
		"movl	%7,%%sp@-\n\t"					\
		"movl	%6,%%sp@-\n\t"					\
		"movl	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#1\n\t"						\
		"lea	%%sp@(26),%%sp"					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c),				\
	  "r"(_d), "r"(_e), "r"(_f)		/* inputs  */		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
									\
	retvalue;							\
})


#define Srealloc(newsize)					\
		trap_1_wl(0x15, (long)(newsize))
#define Slbopen(name, path, min_ver, sl, fn)			\
		trap_1_wlllll(0x16, (long)(name), (long)(path), (long)(min_ver), (long)(sl), (long)(fn))
#define Slbclose(sl)						\
		trap_1_wl(0x17, (long)(sl))
#define	Syield()						\
		(int)trap_1_w(0xff)
#define Fpipe(ptr)						\
		(int)trap_1_wl(0x100, (long)(ptr))
#define Ffchown(f, uid, gid)					\
		trap_1_wwww(0x101, (short)(f), (short)(uid), (short)(gid))
#define Ffchmod(f, mode)					\
		trap_1_www(0x102, (short)(f), (short)(mode))
#define Fsync(f)						\
		trap_1_ww(0x103, (short)(f))
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
		(int)trap_1_ww(0x10a, (short)(delta))
#define Pgetpid()						\
		(int)trap_1_w(0x10b)
#define Pgetppid()						\
		(int)trap_1_w(0x10c)
#define Pgetpgrp()						\
		(int)trap_1_w(0x10d)
#define Psetpgrp(pid, grp)					\
		(int)trap_1_www(0x10e, (short)(pid), (short)(grp))
#define Pgetuid()						\
		(int)trap_1_w(0x10f)
#define Psetuid(id)						\
		(int)trap_1_ww(0x110, (short)(id))
#define Pkill(pid, sig)						\
		(int)trap_1_www(0x111, (short)(pid), (short)(sig))
#define Psignal(sig, handler)					\
		trap_1_wwl(0x112, (short)(sig), (long)(handler))
#define Pvfork()						\
		trap_1_w(0x113)
#define Pgetgid()						\
		(int)trap_1_w(0x114)
#define Psetgid(id)						\
		(int)trap_1_ww(0x115, (short)(id))
#define Psigblock(mask)						\
		trap_1_wl(0x116, (unsigned long)(mask))
#define Psigsetmask(mask)					\
		trap_1_wl(0x117, (unsigned long)(mask))
#define Pusrval(arg)						\
		trap_1_wl(0x118, (long)(arg))
#define Pdomain(arg)						\
		(int)trap_1_ww(0x119, (short)(arg))
#define Psigreturn()						\
		(void)trap_1_w(0x11a)
#define Pfork()							\
		trap_1_w(0x11b)
#define Pwait3(flag, rusage)					\
		trap_1_wwl(0x11c, (short)(flag), (long)(rusage))
#define Fselect(time, rfd, wfd, xfd)				\
		(int)trap_1_wwlll(0x11d, (unsigned short)(time), (long)(rfd), \
				(long)(wfd), (long)(xfd))
#define Prusage(rsp)						\
		(int)trap_1_wl(0x11e, (long)(rsp))
#define Psetlimit(i, val)					\
		trap_1_wwl(0x11f, (short)(i), (long)(val))

#define Talarm(sec)						\
		trap_1_wl(0x120, (long)(sec))
#define Pause()							\
		(void)trap_1_w(0x121)
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
		(int)trap_1_www(0x127, (short)(pid), (short)(delta))
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
		(int)trap_1_ww(0x133, (short)(mask))
#define Psemaphore(mode, id, tmout)				\
		trap_1_wwll(0x134, (short)(mode), (long)(id), (long)(tmout))
#define Dlock(mode, drive)					\
		(int)trap_1_www(0x135, (short)(mode), (short)(drive))
#define Psigpause(mask)						\
		(void)trap_1_wl(0x136, (unsigned long)(mask))
#define Psigaction(sig, act, oact)					\
		trap_1_wwll(0x137, (short)(sig), (long)(act), (long)(oact))
#define Pgeteuid()						\
		(int)trap_1_w(0x138)
#define Pgetegid()						\
		(int)trap_1_w(0x139)
#define Pwaitpid(pid,flag, rusage)				\
		trap_1_wwwl(0x13a, (short)(pid), (short)(flag), (long)(rusage))
#define Dgetcwd(path, drv, size)				\
		trap_1_wlww(0x13b, (long)(path), (short)(drv), (short)(size))
#define Salert(msg)						\
		trap_1_wl(0x13c, (long)(msg))
/* The following are not yet official... */
#define Tmalarm(ms)						\
		trap_1_wl(0x13d, (long)(ms))
#define Psigintr(vec, sig)					\
		trap_1_www(0x13e, (short)(vec), (short)(sig))
#define Suptime(uptime, avenrun)				\
		trap_1_wll(0x13f, (long)(uptime), (long)(avenrun))
#define Ptrace(request, pid, addr, data)		\
		trap_1_wwwll(0x140, (short)(request), (short)(pid), \
			      (long)(addr), (long)(data))
#define Mvalidate(pid,addr,size,flags)				\
		trap_1_wwlll(0x141, (short)(pid), (long)(addr), (long)(size), (long)(flags))
#define Dxreaddir(len, handle, buf, xattr, xret)		\
		trap_1_wwllll(0x142, (short)(len), (long)(handle), \
			      (long)(buf), (long)(xattr), (long)(xret))
#define Pseteuid(id)						\
		(int)trap_1_ww(0x143, (short)(id))
#define Psetegid(id)						\
		(int)trap_1_ww(0x144, (short)(id))
#define Pgetauid()						\
		(int)trap_1_w(0x145)
#define Psetauid(id)						\
		(int)trap_1_ww(0x146, (short)(id))
#define Pgetgroups(gidsetlen, gidset)				\
		trap_1_wwl(0x147, (short)(gidsetlen), (long)(gidset))
#define Psetgroups(gidsetlen, gidset)				\
		trap_1_wwl(0x148, (short)(gidsetlen), (long)(gidset))
#define Tsetitimer(which, interval, value, ointerval, ovalue)	\
		trap_1_wwllll(0x149, (short)(which), (long)(interval), \
			      (long)(value), (long)(ointerval), (long)(ovalue))
#define Dchroot(dir)						\
		trap_1_wl(0x14a, (long)(dir))
#define Fstat64(flag, name, stat)					\
		trap_1_wwll(0x14b, (short)(flag), (long)(name), (long)(stat))
#define Fseek64(high, low, fh, how, newpos) \
		trap_1_wllwwl(0x14c, (long)(high), (long)(low), (short)(fh), \
		(short)(how), (long)(newpos))
#define Dsetkey(major, minor, key, cipher)				\
		trap_1_wlllw(0x14d, (long)(major), (long)(minor), (long)(key), \
		(short)(cipher))
#define Psetreuid(rid, eid)   \
		(int)trap_1_www(0x14e, (short)(rid), (short)(eid))
#define Psetregid(rid, eid)   \
		(int)trap_1_www(0x14f, (short)(rid), (short)(eid))
#define Sync()   \
		trap_1_w(0x150)
#define Shutdown(restart)  \
		trap_1_wl(0x151, (long)(restart))
#define Dreadlabel(path, label, maxlen)  \
		trap_1_wllw(0x152, (long)(path), (long)(label), (short)(maxlen))
#define Dwritelabel(path, label)  \
		trap_1_wll(0x153, (long)(path), (long)(label))
#define Ssystem(mode, arg1, arg2) \
		trap_1_wwll(0x154, (short)(mode), (long)(arg1), (long)(arg2))
#define Tgettimeofday(tvp, tzp) \
		trap_1_wll(0x155, (long)(tvp), (long)(tzp))
#define Tsettimeofday(tvp, tzp) \
		trap_1_wll(0x156, (long)(tvp), (long)(tzp))
#define Tadjtime(delta, olddelta) \
		trap_1_wll(0x157, (long)(delta), (long)(olddelta))
#define Pgetpriority(which, who) \
		trap_1_www(0x158, (short)(which), (short)(who))
#define Psetpriority(which, who, prio) \
		trap_1_wwww(0x159, (short)(which), (short)(who), (short)(prio))
#define Fpoll(fds, nfds, timeout) \
		trap_1_wlll(0x15a,(long)(fds),(long)(nfds),(long)(timeout))
#define Fwritev(fh, iovp, iovcnt) \
		trap_1_wwll(0x15b,(short)(fh),(long)(iovp),(long)(iovcnt))
#define Freadv(fh, iovp, iovcnt) \
		trap_1_wwll(0x15c,(short)(fh),(long)(iovp),(long)(iovcnt))
#define Ffstat64(fh, stat) \
		trap_1_wwl(0x15d,(short)(fh),(long)(stat))
#define Psysctl(name, namelen, old, oldlenp, new, newlen) \
		trap_1_wllllll(0x15e,(long)(name),(long)(namelen),(long)(old),(long)(oldlenp),(long)(new),(long)(newlen))
#define Pemulation(which, op, a1, a2, a3, a4, a5, a6, a7) \
		trap_1_wwwlllllll(0x15f,(short)(which),(short)(op),(long)(a1),(long)(a2),(long)(a3),(long)(a4),(long)(a5),(long)(a6),(long)(a7))
#define Fsocket(domain, type, protocol) \
		trap_1_wlll(0x160,(long)(domain),(long)(type),(long)(protocol))
#define Fsocketpair(domain, type, protocol, rsv) \
		trap_1_wllll(0x161,(long)(domain),(long)(type),(long)(protocol),(long)(rsv))
#define Faccept(fh, name, namelen) \
		trap_1_wwll(0x162,(short)(fh),(long)(name),(long)(namelen))
#define Fconnect(fh, name, namelen) \
		trap_1_wwll(0x163,(short)(fh),(long)(name),(long)(namelen))
#define Fbind(fh, name, namelen) \
		trap_1_wwll(0x164,(short)(fh),(long)(name),(long)(namelen))
#define Flisten(fh, backlog) \
		trap_1_wwl(0x165,(short)(fh),(long)(backlog))
#define Frecvmsg(fh, msg, flags) \
		trap_1_wwll(0x166,(short)(fh),(long)(msg),(long)(flags))
#define Fsendmsg(fh, msg, flags) \
		trap_1_wwll(0x167,(short)(fh),(long)(msg),(long)(flags))
#define Frecvfrom(fh, buf, len, flags, from, fromlen) \
		trap_1_wwlllll(0x168,(short)(fh),(long)(buf),(long)(len),(long)(flags),(long)(from),(long)(fromlen))
#define Fsendto(fh, buf, len, flags, to, tolen) \
		trap_1_wwlllll(0x169,(short)(fh),(long)(buf),(long)(len),(long)(flags),(long)(to),(long)(tolen))
#define Fsetsockopt(fh, level, name, val, valsize) \
		trap_1_wwllll(0x16a,(short)(fh),(long)(level),(long)(name),(long)(val),(long)(valsize))
#define Fgetsockopt(fh, level, name, val, avalsize) \
		trap_1_wwllll(0x16b,(short)(fh),(long)(level),(long)(name),(long)(val),(long)(avalsize))
#define Fgetpeername(fh, addr, addrlen) \
		trap_1_wwll(0x16c,(short)(fh),(long)(addr),(long)(addrlen))
#define Fgetsockname(fh, addr, addrlen) \
		trap_1_wwll(0x16d,(short)(fh),(long)(addr),(long)(addrlen))
#define Fshutdown(fh, how) \
		trap_1_wwl(0x16e,(short)(fh),(long)(how))
/* 0x16f */
#define Pshmget(key, size, shmflg) \
		trap_1_wlll(0x170,(long)(key),(long)(size),(long)(shmflg))
#define Pshmctl(shmid, cmd, buf) \
		trap_1_wlll(0x171,(long)(shmid),(long)(cmd),(long)(buf))
#define Pshmat(shmid, shmaddr, shmflg) \
		trap_1_wlll(0x172,(long)(shmid),(long)(shmaddr),(long)(shmflg))
#define Pshmdt(shmaddr) \
		trap_1_wl(0x173,(long)(shmaddr))
#define Psemget(key, nsems, semflg) \
		trap_1_wlll(0x174,(long)(key),(long)(nsems),(long)(semflg))
#define Psemctl(semid, semnum, cmd, arg) \
		trap_1_wllll(0x175,(long)(semid),(long)(semnum),(long)(cmd),(long)(arg))
#define Psemop(semid, sops, nsops) \
		trap_1_wlll(0x176,(long)(semid),(long)(sops),(long)(nsops))
#define Psemconfig(flag) \
		trap_1_wl(0x177,(long)(flag))
#define Pmsgget(key, msgflg) \
		trap_1_wll(0x178,(long)(key),(long)(msgflg))
#define Pmsgctl(msqid, cmd, buf) \
		trap_1_wlll(0x179,(long)(msqid),(long)(cmd),(long)(buf))
#define Pmsgsnd(msqid, msgp, msgsz, msgflg) \
		trap_1_wllll(0x17a,(long)(msqid),(long)(msgp),(long)(msgsz),(long)(msgflg))
#define Pmsgrcv(msqid, msgp, msgsz, msgtyp, msgflg) \
		trap_1_wlllll(0x17b,(long)(msqid),(long)(msgp),(long)(msgsz),(long)(msgtyp),(long)(msgflg))
/* 0x17c */
#define Maccess(addr,size,mode) \
		trap_1_wllw(0x17d, (long)(addr), (long)(size), (short)(mode))
/* 0x17e */
/* 0x17f */
#define Fchown16(name, uid, gid, follow_links) \
		trap_1_wlwww(0x180, (long)(name), (short)(uid), (short)(gid), (short)follow_links)
#define Fchdir(fh) \
		trap_1_ww(0x181, (short)(fh))
#define Ffdopendir(fh) \
		trap_1_ww(0x182, (short)(fh))
#define Fdirfd(handle) \
		trap_1_wl(0x183, (long)(handle))

__END_DECLS

#endif /* _MINT_MINTBIND_H */

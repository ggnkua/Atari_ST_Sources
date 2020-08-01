/*
 * @(#)mintbind.h, SozobonX XdLibs (c) jerry g geiger 1995
 *
 * Mnemonic names for MiNT operating system calls
 * based on original mintbind.h (c) by Atari
 * up to MiNT v 1.12
 * last change
 *  -VS: 1995/08/19
 */

#ifndef _MINTBIND_H
#define _MINTBIND_H


#ifdef __MSHORT__

extern	long	gemdos(short, ...);
extern	long	bios(short, ...);
extern	long	xbios(short, ...);
extern	short	bdos(short, ...);

#ifndef _TOSBIND_H
#define trap_1_w(n)			gemdos(n)
#define trap_1_wl(n,a)			gemdos(n, (long)(a))
#define trap_1_wll(n, a, b)		gemdos(n, (long)(a), (long)(b))
#define trap_1_ww(n,a)			gemdos(n, (short)(a))
#define trap_1_www(n,a,b)		gemdos(n, (short)(a), (short)(b))
#define trap_1_wwlll(n,a,b,c,d) 	gemdos(n, a, (long)(b), (long)(c), (long)(d))
#define trap_1_wwll(n, a, b, c)		gemdos(n, a, (long)(b), (long)(c))
#define trap_1_wlw(n, a, b)		gemdos(n, (long)(a), (short)(b))
#define trap_1_wlww(n, a, b, c)		gemdos(n, (long)(a), (short)(b), (short)(c))
#define trap_13_w(n)			bios(n)
#define trap_14_w(n)			xbios(n)
#endif /* _TOSBIND_H */

#define trap_1_wwlw(n,a,b,c)		gemdos(n, (short)(a), (long)(b), (short)(c))
#define trap_1_wwww(n,a,b,c)		gemdos(n, (short)(a), (short)(b), (short)(c))
#define trap_1_wwl(n, a, b)		gemdos(n, (short)(a), (long)(b))
#define trap_1_wwwl(n,a,b,c)		gemdos(n, (short)(a), (short)(b), (long)(c))
#define trap_1_wwllll(n,a,b,c,d,e)	gemdos(n, (short)(a), (short)(b), \
						(long)(c), (long)(d), (long)(e))
#define trap_1_wllw(n, a, b, c)		gemdos(n, (long)(a), (long)(b), (short)(c))

#else

#ifndef _TOSBIND_H
extern	long	trap_1_w(short n);
extern	long	trap_1_wl(short n, long a);
extern	long	trap_1_wll(short n, long a, long b);
extern	long	trap_1_ww(short n, short a);
extern	long	trap_1_www(short n, short a, short b);
extern	long	trap_1_wwlll(short n, short a, long b, long c, long d);
extern	long	trap_1_wwll(short n, short a, long b, long c);
extern	long	trap_1_wlw(short n, long a, short b);
extern	long	trap_1_wlww(short n, long a, short b, short c);
extern	long	trap_13_w(short n);
extern	long	trap_14_w(short n);
#endif /* _TOSBIND_H */

extern	long	trap_1_wwlw(short c, short a, long b, short c);
extern	long	trap_1_wwww(short c, short a, short b, short c);	
extern	long	trap_1_wwl(short n, short a, long b);
extern	long	trap_1_wwwl(short n, short b, short c, long l);
extern	long	trap_1_wwllll(short n, short a, short b, long c, long d, long e);
extern	long	trap_1_wllw(short n, long a, long b, short c);

#endif /* __MSHORT__ */

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
	/* new 0.94 PL 12	*/
#define Pgeteuid()						\
		(short)trap_1_w(0x138)
#define Pgetegid()						\
		(short)trap_1_w(0x139)
	/* new 0.96 PL 3	*/
/* if there are terminated children, clean up and return their info:
 * <pid><exitcode> if rusage fill in the values *rusage
 * if there are children, but still running, wait for them;
 * if there are no children, return an error
 */
#define Pwaitpid(pid, nohang, rsp) \
		(long)trap_1_wwwl(0x13a, (short)pid, (short)nohang, (long*)rsp)
	/* new 0.96 PL 13	*/
#define Dgetcwd(path, dev, size) \
		(long)trap_1_wlww(0x13b, (char *)path, short(dev), (short)size)
	/* new 0.97 PL 2	*/
#define Salert(string) \
		(long)trap_1_wl(0x13c, (char *)string)
	/* new 1.10 PL 2	*/
	/* alarm < 0 : only return cur alarm = 0: cancel, millisec	*/
#define Tmalarm(alarm) \
		(long)trap_1_wl(0x13d, (long)alarm)
	/* new 1.11	*/
/*
 * p_sigintr: Set an exception vector to send us the specified signal.
 */
#define Psigintr(vec, sig) \
		(long)trap_1_www(0x13e, (short)vec, (short)sig)
#define Suptime(cur_uptime, loadaverage) \
		(long)trap_1_wll(0x13f,(long*)cur_uptime, (long*)loadaverage)
#define Dxreaddir(len, handle, buf, xattr, xret) \
		(long)trap_1_wwllll(0x142, (short)len, (long)handle, \
					(char *)buf, (struct Xattr*)xattr, (long*)xret)
#define Pseteuid(eid) \
		(long)trap_1_ww(0x143, (short)eid)
#define Psetegid(egid) \
		(short)trap_1_ww(0x144, (short)egid)
	/* audit user id functions	*/
#define Pgetauid() \
		(long)trap_1_w(0x145)
#define Psetauid(id) \
		(long)trap_1_ww(0x146, (short)id)
#define Pgetgroups(gidsetlen, gidset) \
		(short)trap_1_wwl(0x147, (short)gidsetlen, (long*)gidset)
#define Psetgroups(gidsetlen, gidset) \
		(short)trap_1_wwl(0x148, (short)gidsetlen, (long*)gidset)
/*
 * t_setitimer(which, interval, value, ointerval, ovalue):
 * schedule an interval timer
 * which is ITIMER_REAL (0) for SIGALRM, ITIMER_VIRTUAL (1) for SIGVTALRM,
 * or ITIMER_PROF (2) for SIGPROF.
 * the rest of the parameters are pointers to millisecond values.
 * interval is the value to which the timer will be reset
 * value is the current timer value
 * ointerval and ovalue are the previous values
 */
#define Tsetitimer(which, interval, value, ointerval, ovalue) \
		(short)trap_1_wwllll(0x149, (short)which, (long*)interval,\
				(long*)value, (long*)ointerval, (long*)ovalue)
	/* new 1.12	*/
#define Dreadlabel(path, label, size) \
		(long)trap_1_wllw(0x152, (char *)path, (char *)label, (short)size)
#define Dwritelabel(path, label) \
		(long)trap_1_wll(0x153, (char *)path, (char *)label)

#endif /* _MINTBIND_H */

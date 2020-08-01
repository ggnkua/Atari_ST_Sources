/*
 *	mintbind.h
 */

#ifndef _MINTBIND_H
#define _MINTBIND_H

#ifndef _OSBIND_H
#include <osbind.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif


#if defined(__C68__) || defined(__SOZOBON__)

#ifdef __C68__

__EXTERN long _trap_1_wwl	__PROTO((short,short,long));
__EXTERN long _trap_1_wwlw	__PROTO((short,short,long,short));
__EXTERN long _trap_1_wwww	__PROTO((short,short,short,short));
__EXTERN long _trap_1_wwwl	__PROTO((short,short,short,long));

#else

#define	_trap_1_wwl	gemdos
#define _trap_1_wwlw	gemdos
#define _trap_1_wwww	gemdos
#define _trap_1_wwwl	gemdos

#endif

#define	Syield()		(short)_trap_1_w((short)0xff)
#define Fpipe(ptr)		(short)_trap_1_wl((short)0x100,(long)(ptr))
#define Fcntl(f,arg,cmd)	_trap_1_wwlw((short)0x104,(short)(f),(long)(arg),(short)(cmd))
#define Finstat(f)		_trap_1_ww((short)0x105,(short)(f))
#define Foutstat(f)		_trap_1_ww((short)0x106,(short)(f))
#define Fgetchar(f,mode)	_trap_1_www((short)0x107,(short)(f),(short)(mode))
#define Fputchar(f,ch,mode)	_trap_1_wwlw((short)0x108,(short)(f),(long)(ch),(short)(mode))
#define Pwait()			_trap_1_w((short)0x109)
#define Pnice(delta)		(short)_trap_1_ww((short)0x10a,(short)(delta))
#define Pgetpid()		(short)_trap_1_w((short)0x10b)
#define Pgetppid()		(short)_trap_1_w((short)0x10c)
#define Pgetpgrp()		(short)_trap_1_w((short)0x10d)
#define Psetpgrp(pid, grp)	(short)_trap_1_www((short)0x10e,(short)(pid),(short)(grp))
#define Pgetuid()		(short)_trap_1_w((short)0x10f)
#define Psetuid(id)		(short)_trap_1_ww((short)0x110,(short)(id))
#define Pkill(pid,sig)		(short)_trap_1_www((short)0x111,(short)(pid),(short)(sig))
#define Psignal(sig, handler)	_trap_1_wwl((short)0x112,(short)(sig),(long)(handler))
#define Pvfork()		_trap_1_w((short)0x113)
#define Pgetgid()		(short)_trap_1_w((short)0x114)
#define Psetgid(id)		(short)_trap_1_ww((short)0x115,(short)(id))
#define Psigblock(mask)		_trap_1_wl((short)0x116,(unsigned long)(mask))
#define Psigsetmask(mask)	_trap_1_wl((short)0x117,(unsigned long)(mask))
#define Pusrval(arg)		_trap_1_wl((short)0x118,(long)(arg))
#define Pdomain(arg)		(short)_trap_1_ww((short)0x119,(short)(arg))
#define Psigreturn()		(void)_trap_1_w((short)0x11a)
#define Pfork()			_trap_1_w((short)0x11b)
#define Pwait3(flag, rusage)	_trap_1_wwl((short)0x11c,(short)(flag),(long)(rusage))
#define Fselect(time,r,w,x)	(short)_trap_1_wwlll((short)0x11d,(unsigned short)(time),(long)(r),(long)(w),(long)(x))
#define Prusage(rsp)		(short)_trap_1_wl((short)0x11e,(long)(rsp))
#define Psetlimit(i,val)	_trap_1_wwl((short)0x11f,(short)(i),(long)(val))
#define Talarm(sec)		_trap_1_wl((short)0x120,(long)(sec))
#define Pause()			(void)_trap_1_w((short)0x121)
#define Sysconf(n)		_trap_1_ww((short)0x122,(short)(n))
#define Psigpending()		_trap_1_w((short)0x123)
#define Dpathconf(name, which)	_trap_1_wlw((short)0x124,(long)(name),(short)(which))
#define Pmsg(mode, mbox, msg)	_trap_1_wwll((short)0x125,(short)(mode),(long)(mbox),(long)(msg))
#define Fmidipipe(pid,in,out)	_trap_1_wwww((short)0x126,(short)(pid),(short)(in),(short)(out))
#define Prenice(pid, delta)	(short)_trap_1_www((short)0x127,(short)(pid),(short)(delta))
#define Dopendir(name, flag)	_trap_1_wlw((short)0x128,(long)(name),(short)(flag))
#define Dreaddir(len,hdl,buf)	_trap_1_wwll((short)0x129,(short)(len),(long)(hdl),(long)(buf))
#define Drewinddir(hdl)		_trap_1_wl((short)0x12a,(long)(hdl))
#define Dclosedir(handle)	_trap_1_wl((short)0x12b,(long)(handle))
#define Fxattr(flag,name,buf)	_trap_1_wwll((short)0x12c,(short)(flag),(long)(name),(long)(buf))
#define Flink(old,new)		_trap_1_wll((short)0x12d,(long)(old),(long)(new))
#define Fsymlink(old, new)	_trap_1_wll((short)0x12e,(long)(old),(long)(new))
#define Freadlink(siz,buf,lnkn)	_trap_1_wwll((short)0x12f,(short)(siz),(long)(buf),(long)(lnkn))
#define Dcntl(cmd,name,arg)	_trap_1_wwll((short)0x130,(short)(cmd),(long)(name),(long)(arg))
#define Fchown(name, uid, gid)	_trap_1_wlww((short)0x131,(long)(name),(short)(uid),(short)(gid))
#define Fchmod(name, mode)	_trap_1_wlw((short)0x132,(long)(name),(short)(mode))
#define Pumask(mask)		(short)_trap_1_ww((short)0x133,(short)(mask))
#define Psemaphore(mode,id,out)	_trap_1_wwll((short)0x134,(short)(mode),(long)(id),(long)(out))
#define Dlock(mode, drive)	(short)_trap_1_www((short)0x135,(short)(mode),(short)(drive))
#define Psigpause(mask)		(void)_trap_1_wl((short)0x136,(unsigned long)(mask))
#define Psigaction(sig,act,oac)	_trap_1_wwll((short)0x137,(short)(sig),(long)(act),(long)(oac))
#define Pgeteuid()		(short)_trap_1_w((short)0x138)
#define Pgetegid()		(short)_trap_1_w((short)0x139)
#define Pwaitpid(pid,flag,rusg)	_trap_1_wwwl((short)0x13a,(short)(pid),(short)(flag),(long)(rusg))
#define Dgetcwd(path,drv,size)	_trap_1_wlww((short)0x13b,(long)(path),(short)(drv),(short)(size))
#define Salert(msg)		_trap_1_wl((short)0x13c,(long)(msg))

/* The following are not yet official... */
#define Tmalarm(ms)		_trap_1_wl((short)0x13d,(long)(ms))
#define Psigintr(vec, sig)	_trap_1_www((short)0x13e,(short)(vec),(short)(sig))
#define Suptime(uptime,avenrun)	_trap_1_wll((short)0x13f,(long)(uptime),(long)(avenrun))


#else /* !__C68__ */

/* Support for GCC, Pure C/Turbo C and Lattice C
 * has been removed - if you've got one of these
 * compilers, use the original mintbind.h to add
 * the needed bits...
 */

#endif /* __C68__ */

#ifdef __cplusplus
}
#endif

#endif /* _MINTBIND_H */

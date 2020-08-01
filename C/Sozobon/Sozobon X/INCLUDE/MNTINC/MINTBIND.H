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

#if defined(__C68__) || defined(__SOZOBONX__)

#define	Syield()		(short)gemdos((short)0xff)
#define Fpipe(ptr)		(short)gemdos((short)0x100,(long)(ptr))
#define Fcntl(f,arg,cmd)	gemdos((short)0x104,(short)(f),(long)(arg),(short)(cmd))
#define Finstat(f)		gemdos((short)0x105,(short)(f))
#define Foutstat(f)		gemdos((short)0x106,(short)(f))
#define Fgetchar(f,mode)	gemdos((short)0x107,(short)(f),(short)(mode))
#define Fputchar(f,ch,mode)	gemdos((short)0x108,(short)(f),(long)(ch),(short)(mode))
#define Pwait()			gemdos((short)0x109)
#define Pnice(delta)		(short)gemdos((short)0x10a,(short)(delta))
#define Pgetpid()		(short)gemdos((short)0x10b)
#define Pgetppid()		(short)gemdos((short)0x10c)
#define Pgetpgrp()		(short)gemdos((short)0x10d)
#define Psetpgrp(pid, grp)	(short)gemdos((short)0x10e,(short)(pid),(short)(grp))
#define Pgetuid()		(short)gemdos((short)0x10f)
#define Psetuid(id)		(short)gemdos((short)0x110,(short)(id))
#define Pkill(pid,sig)		(short)gemdos((short)0x111,(short)(pid),(short)(sig))
#define Psignal(sig, handler)	gemdos((short)0x112,(short)(sig),(long)(handler))
#define Pvfork()		gemdos((short)0x113)
#define Pgetgid()		(short)gemdos((short)0x114)
#define Psetgid(id)		(short)gemdos((short)0x115,(short)(id))
#define Psigblock(mask)		gemdos((short)0x116,(unsigned long)(mask))
#define Psigsetmask(mask)	gemdos((short)0x117,(unsigned long)(mask))
#define Pusrval(arg)		gemdos((short)0x118,(long)(arg))
#define Pdomain(arg)		(short)gemdos((short)0x119,(short)(arg))
#define Psigreturn()		(void)gemdos((short)0x11a)
#define Pfork()			gemdos((short)0x11b)
#define Pwait3(flag, rusage)	gemdos((short)0x11c,(short)(flag),(long)(rusage))
#define Fselect(time,r,w,x)	(short)gemdos((short)0x11d,(unsigned short)(time),(long)(r),(long)(w),(long)(x))
#define Prusage(rsp)		(short)gemdos((short)0x11e,(long)(rsp))
#define Psetlimit(i,val)	gemdos((short)0x11f,(short)(i),(long)(val))
#define Talarm(sec)		gemdos((short)0x120,(long)(sec))
#define Pause()			(void)gemdos((short)0x121)
#define Sysconf(n)		gemdos((short)0x122,(short)(n))
#define Psigpending()		gemdos((short)0x123)
#define Dpathconf(name, which)	gemdos((short)0x124,(long)(name),(short)(which))
#define Pmsg(mode, mbox, msg)	gemdos((short)0x125,(short)(mode),(long)(mbox),(long)(msg))
#define Fmidipipe(pid,in,out)	gemdos((short)0x126,(short)(pid),(short)(in),(short)(out))
#define Prenice(pid, delta)	(short)gemdos((short)0x127,(short)(pid),(short)(delta))
#define Dopendir(name, flag)	gemdos((short)0x128,(long)(name),(short)(flag))
#define Dreaddir(len,hdl,buf)	gemdos((short)0x129,(short)(len),(long)(hdl),(long)(buf))
#define Drewinddir(hdl)		gemdos((short)0x12a,(long)(hdl))
#define Dclosedir(handle)	gemdos((short)0x12b,(long)(handle))
#define Fxattr(flag,name,buf)	gemdos((short)0x12c,(short)(flag),(long)(name),(long)(buf))
#define Flink(old,new)		gemdos((short)0x12d,(long)(old),(long)(new))
#define Fsymlink(old, new)	gemdos((short)0x12e,(long)(old),(long)(new))
#define Freadlink(siz,buf,lnkn)	gemdos((short)0x12f,(short)(siz),(long)(buf),(long)(lnkn))
#define Dcntl(cmd,name,arg)	gemdos((short)0x130,(short)(cmd),(long)(name),(long)(arg))
#define Fchown(name, uid, gid)	gemdos((short)0x131,(long)(name),(short)(uid),(short)(gid))
#define Fchmod(name, mode)	gemdos((short)0x132,(long)(name),(short)(mode))
#define Pumask(mask)		(short)gemdos((short)0x133,(short)(mask))
#define Psemaphore(mode,id,out)	gemdos((short)0x134,(short)(mode),(long)(id),(long)(out))
#define Dlock(mode, drive)	(short)gemdos((short)0x135,(short)(mode),(short)(drive))
#define Psigpause(mask)		(void)gemdos((short)0x136,(unsigned long)(mask))
#define Psigaction(sig,act,oac)	gemdos((short)0x137,(short)(sig),(long)(act),(long)(oac))
#define Pgeteuid()		(short)gemdos((short)0x138)
#define Pgetegid()		(short)gemdos((short)0x139)
#define Pwaitpid(pid,flag,rusg)	gemdos((short)0x13a,(short)(pid),(short)(flag),(long)(rusg))
#define Dgetcwd(path,drv,size)	gemdos((short)0x13b,(long)(path),(short)(drv),(short)(size))
#define Salert(msg)		gemdos((short)0x13c,(long)(msg))

/* The following are not yet official... */
#define Tmalarm(ms)		gemdos((short)0x13d,(long)(ms))
#define Psigintr(vec, sig)	gemdos((short)0x13e,(short)(vec),(short)(sig))
#define Suptime(uptime,avenrun)	gemdos((short)0x13f,(long)(uptime),(long)(avenrun))

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

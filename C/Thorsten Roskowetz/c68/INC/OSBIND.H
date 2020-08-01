/*
 *	osbind.h
 */

#ifndef _OSBIND_H
#define _OSBIND_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _OSTRUCT_H
#include <ostruct.h>
#endif


#if defined(__C68__) || defined(__SOZOBON__)

#ifdef __C68__

#define gemdos	_trap_1_
#define xbios	_trap_14_
#define bios	_trap_13_

#if !defined(__STDC__) && !defined(__MSHORT__)
#error does not work with -trad and -mlong
#endif

__EXTERN long _trap_1_w		__PROTO((short));
__EXTERN long _trap_1_ww	__PROTO((short,short));
__EXTERN long _trap_1_wl	__PROTO((short,long));
__EXTERN long _trap_1_wlw	__PROTO((short,long,short));
__EXTERN long _trap_1_wwll	__PROTO((short,short,long,long));
__EXTERN long _trap_1_wlww	__PROTO((short,long,short,short));
__EXTERN long _trap_1_www	__PROTO((short,short,short));
__EXTERN long _trap_1_wll	__PROTO((short,long,long));
__EXTERN long _trap_1_wwlll	__PROTO((short,short,long,long,long));
__EXTERN long _trap_1_wwwll	__PROTO((short,short,short,long,long));
__EXTERN long _trap_13_wl	__PROTO((short,long));
__EXTERN long _trap_13_w	__PROTO((short));
__EXTERN long _trap_13_ww	__PROTO((short,short));
__EXTERN long _trap_13_www	__PROTO((short,short,short));
__EXTERN long _trap_13_wwlwww	__PROTO((short,short,long,short,short,short));
__EXTERN long _trap_13_wwl	__PROTO((short,short,long));
__EXTERN long _trap_14_wwl	__PROTO((short,short,long));
__EXTERN long _trap_14_wwll	__PROTO((short,short,long,long));
__EXTERN long _trap_14_ww	__PROTO((short,short));
__EXTERN long _trap_14_w	__PROTO((short));
__EXTERN long _trap_14_wllw	__PROTO((short,long,long,short));
__EXTERN long _trap_14_wl	__PROTO((short,long));
__EXTERN long _trap_14_www	__PROTO((short,short,short));
__EXTERN long _trap_14_wllwwwww __PROTO((short,long,long,short,short,short,short,short));
__EXTERN long _trap_14_wllwwwwlw __PROTO((short,long,long,short,short,short,short,long,short));
__EXTERN long _trap_14_wllwwwwwlw __PROTO((short,long,long,short,short,short,short,short,long,short));
__EXTERN long _trap_14_wwwwwww	__PROTO((short,short,short,short,short,short,short));
__EXTERN long _trap_14_wlll	__PROTO((short,long,long,long));
__EXTERN long _trap_14_wllww	__PROTO((short,long,long,short,short));
__EXTERN long _trap_14_wwwwl	__PROTO((short,short,short,short,long));
__EXTERN long _trap_14_wwwl	__PROTO((short,short,short,long));
__EXTERN long _trap_14_wlwlw	__PROTO((short,long,short,long,short));

#else

#define _trap_1_w		gemdos
#define _trap_1_ww		gemdos
#define _trap_1_wl		gemdos
#define _trap_1_wlw		gemdos
#define _trap_1_wwll		gemdos
#define _trap_1_wlww		gemdos
#define _trap_1_www		gemdos
#define _trap_1_wll		gemdos
#define _trap_1_wwlll		gemdos
#define _trap_1_wwwll		gemdos
#define _trap_13_wl		bios
#define _trap_13_w		bios
#define _trap_13_ww		bios
#define _trap_13_www		bios
#define _trap_13_wwlwww		bios
#define _trap_13_wwl		bios
#define _trap_14_wwl		xbios
#define _trap_14_wwll		xbios
#define _trap_14_ww		xbios
#define _trap_14_w		xbios
#define _trap_14_wllw		xbios
#define _trap_14_wl		xbios
#define _trap_14_www		xbios
#define _trap_14_wllwwwww	xbios
#define _trap_14_wllwwwwlw	xbios
#define _trap_14_wllwwwwwlw	xbios
#define _trap_14_wwwwwww	xbios
#define _trap_14_wlll		xbios
#define _trap_14_wllww		xbios
#define _trap_14_wwwwl		xbios
#define _trap_14_wwwl		xbios
#define _trap_14_wlwlw		xbios

#endif

__EXTERN long gemdos	__PROTO((short,...));
__EXTERN long xbios	__PROTO((short,...));
__EXTERN long bios	__PROTO((short,...));


/*
 *	GEMDOS	(trap1)
 */
#define Pterm0()	(void)_trap_1_w((short)0x00)
#define Cconin()	_trap_1_w((short)0x01)
#define Cconout(c)	(void)_trap_1_ww((short)0x02,(short)(c))
#define Cauxin()	(short)_trap_1_w((short)0x03)
#define Cauxout(c)	(void)_trap_1_ww((short)0x04,(short)(c))
#define Cprnout(c)	(short)_trap_1_ww((short)0x05,(short)(c))
#define Crawio(w)	_trap_1_ww((short)0x06,(short)(w))
#define Crawcin()	_trap_1_w((short)0x07)
#define Cnecin()	_trap_1_w((short)0x08)
#define Cconws(s)	(short)_trap_1_wl((short)0x09,(long)(s))
#define Cconrs(buf)	(void)_trap_1_wl((short)0x0A,(long)(buf))
#define Cconis()	(short)_trap_1_w((short)0x0B)
#define Dsetdrv(d)	_trap_1_ww((short)0x0E,(short)(d))
#define Cconos()	(short)_trap_1_w((short)0x10)
#define Cprnos()	(short)_trap_1_w((short)0x11)
#define Cauxis()	(short)_trap_1_w((short)0x12)
#define Cauxos()	(short)_trap_1_w((short)0x13)
#define Dgetdrv()	(short)_trap_1_w((short)0x19)
#define Fsetdta(dta)	(void)_trap_1_wl((short)0x1A,(long)(dta))
#define Super(ptr)	_trap_1_wl((short)0x20,(long)(ptr))
#define Tgetdate()	(short)_trap_1_w((short)0x2A)
#define Tsetdate(date)	(short)_trap_1_ww((short)0x2B,(short)(date))
#define Tgettime()	(short)_trap_1_w((short)0x2C)
#define Tsettime(time)	(short)_trap_1_ww((short)0x2D,(short)(time))
#define Fgetdta()	(_DTA*)_trap_1_w((short)0x2F)
#define Sversion()	(short)_trap_1_w((short)0x30)
#define Ptermres(sv,rv)	(void)_trap_1_wlw((short)0x31,(long)(sv),(short)(rv))
#define Dfree(buf,d)	(short)_trap_1_wlw((short)0x36,(long)(buf),(short)(d))
#define Dcreate(path)	(short)_trap_1_wl((short)0x39,(long)(path))
#define Ddelete(path)	(short)_trap_1_wl((short)0x3A,(long)(path))
#define Dsetpath(path)	(short)_trap_1_wl((short)0x3B,(long)(path))
#define Fcreate(fn,md)	(short)_trap_1_wlw((short)0x3C,(long)(fn),(short)(md))
#define Fopen(fn,md)	(short)_trap_1_wlw((short)0x3D,(long)(fn),(short)(md))
#define Fclose(h)	(short)_trap_1_ww((short)0x3E,(short)(h))
#define Fread(h,ct,bf)	_trap_1_wwll((short)0x3F,(short)(h),(long)(ct),(long)(bf))
#define Fwrite(h,ct,bf)	_trap_1_wwll((short)0x40,(short)(h),(long)(ct),(long)(bf))
#define Fdelete(fn)	(short)_trap_1_wl((short)0x41,(long)(fn))
#define Fseek(off,h,md)	_trap_1_wlww((short)0x42,(long)off,(short)(h),(short)(md))
#define Fattrib(f,w,a)	(short)_trap_1_wlww((short)0x43,(long)(f),(short)(w),(short)(a))
#define Fdup(h)		(short)_trap_1_ww((short)0x45,(short)(h))
#define Fforce(hs,hn)	(short)_trap_1_www((short)0x46,(short)(hs),(short)(hn))
#define Dgetpath(buf,d)	(short)_trap_1_wlw((short)0x47,(long)(buf),(short)(d))
#define Malloc(size)	(long)_trap_1_wl((short)0x48,(long)(size))
#define Mfree(ptr)	(short)_trap_1_wl((short)0x49,(long)(ptr))
#define Mshrink(ptr,sz)	(short)_trap_1_wwll((short)0x4A,(short)0,(long)(ptr),(long)(sz))
#define Pexec(md,p,t,e)	_trap_1_wwlll((short)0x4B,(short)(md),(long)(p),(long)(t),(long)(e))
#define Pterm(rv)	(void)_trap_1_ww((short)0x4C,(short)(rv))
#define Fsfirst(sp,at)	(short)_trap_1_wlw((short)0x4E,(long)(sp),(short)(at))
#define Fsnext()	(short)_trap_1_w((short)0x4F)
#define Frename(z,o,n)	(short)_trap_1_wwll((short)0x56,(short)(z),(long)(o),(long)(n))
#define Fdatime(t,h,w)	_trap_1_wlww((short)0x57,(long)(t),(short)(h),(short)(w))

/* GEMDOS extensions */
#define Maddalt(st,sz)	_trap_1_wll((short)0x14,(long)(st),(long)(sz))
#define Mxalloc(am,md)	_trap_1_wlw((short)0x44,(long)(am),(short)(md))

/* Network Gemdos Extension */
#define Flock(h,md,s,l)	_trap_1_wwwll((short)0x5C,(short)(h),(short)(md),(long)(s),(long)(l))


/*
 *	BIOS	(trap13)
 */
#define Getmpb(mpb)		(void)_trap_13_wl((short)0x0,(long)(mpb))
#define Bconstat(dev)		(short)_trap_13_ww((short)0x1,(short)(dev))
#define Bconin(dev)		_trap_13_ww((short)0x2,(short)(dev))
#define Bconout(dev,c)		_trap_13_www((short)0x3,(short)(dev),(short)(c))
#define Rwabs(wflg,buf,n,sec,d)	_trap_13_wwlwww((short)0x4,(short)(wflg),(long)(buf),(short)(n),(short)(sec),(short)(d))
#define Setexc(vnum,vptr)	(void(*))_trap_13_wwl((short)0x5,(short)(vnum),(long)(vptr))
#define Tickcal()		_trap_13_w((short)0x6)
#define Getbpb(d)		(_BPB*)_trap_13_ww((short)0x7,(short)(d))
#define Bcostat(dev)		_trap_13_ww((short)0x8,(short)(dev))
#define Mediach(d)		_trap_13_ww((short)0x9,(short)(d))
#define Drvmap()		_trap_13_w((short)0xA)
#define Kbshift(mode)		_trap_13_ww((short)0xB,(short)(mode))
#define Getshift()		Kbshift(-1)


/*
 *		XBIOS	(trap14)
 */
#define Initmous(type,param,vptr)	(void)_trap_14_wwll((short)0x0,(short)(type),(long)(param),(long)(vptr))
#define Ssbrk(amnt)			(void*)_trap_14_ww((short)0x1,(short)(amnt))
#define Physbase()			(void*)_trap_14_w((short)0x2)
#define Logbase()			(void*)_trap_14_w((short)0x3)
#define Getrez()			(short)_trap_14_w((short)0x4)
#define Setscreen(lscrn,pscrn,rez)	(void)_trap_14_wllw((short)0x5,(long)(lscrn),(long)pscrn,(short)(rez))
#define Setpalette(palptr)		(void)_trap_14_wl((short)0x6,(long)(palptr))
#define Setcolor(colornum,mixture)	(short)_trap_14_www((short)0x7,(short)(colornum),(short)(mixture))
#define Floprd(buf,x,d,sect,trk,side,n)	(short)_trap_14_wllwwwww((short)0x8,(long)(buf),(long)(x),(short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define Flopwr(buf,x,d,sect,trk,side,n)	(short)_trap_14_wllwwwww((short)0x9,(long)(buf),(long)(x),(short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define Flopfmt(b,x,d,spt,trk,sd,i,m,v) (short)_trap_14_wllwwwwwlw((short)0xA,(long)(b),(long)(x),(short)(d),(short)(spt),(short)(trk),(short)(sd),(short)(i),(long)(m),(short)(v))
#define Midiws(cnt,ptr)			(void)_trap_14_wwl((short)0xC,(short)(cnt),(long)(ptr))
#define Mfpint(vnum,vptr)		(void)_trap_14_wwl((short)0xD,(short)(vnum),(long)(vptr))
#define Iorec(iodev)			(_IOREC*)_trap_14_ww((short)0xE,(short)(iodev))
#define Rsconf(baud,flow,uc,rs,ts,sc)	_trap_14_wwwwwww((short)0xF,(short)(baud),(short)(flow),(short)(uc),(short)(rs),(short)(ts),(short)(sc))
#define Keytbl(nrml,shft,caps)		(_KEYTAB*)_trap_14_wlll((short)0x10,(long)(nrml),(long)(shft),(long)(caps))
#define Random()			_trap_14_w((short)0x11)
#define Protobt(buf,serial,dsktyp,exec) (void)_trap_14_wllww((short)0x12,(long)(buf),(long)(serial),(short)(dsktyp),(short)(exec))
#define Flopver(buf,x,d,sect,trk,sd,n)	(short)_trap_14_wllwwwww((short)0x13,(long)(buf),(long)(x),(short)(d),(short)(sect),(short)(trk),(short)(sd),(short)(n))
#define Scrdmp()			(void)_trap_14_w((short)0x14)
#define Cursconf(func,rate)		(short)_trap_14_www((short)0x15,(short)(func),(short)(rate))
#define Settime(time)			(void)_trap_14_wl((short)0x16,(long)(time))
#define Gettime()			(long)_trap_14_w((short)0x17)
#define Bioskeys()			(void)_trap_14_w((short)0x18)
#define Ikbdws(len_minus1,ptr)		(void)_trap_14_wwl((short)0x19,(short)(len_minus1),(long)(ptr))
#define Jdisint(vnum)			(void)_trap_14_ww((short)0x1A,(short)(vnum))
#define Jenabint(vnum)			(void)_trap_14_ww((short)0x1B,(short)(vnum))
#define Giaccess(data,reg)		(char)_trap_14_www((short)0x1C,(char)(data),(short)(reg))
#define Offgibit(ormask)		(void)_trap_14_ww((short)0x1D,(short)(ormask))
#define Ongibit(andmask)		(void)_trap_14_ww((short)0x1E,(short)(andmask))
#define Xbtimer(timer,ctrl,data,vnum)	(void)_trap_14_wwwwl((short)0x1F,(short)(timer),(short)(ctrl),(short)(data),(long)(vnum))
#define Dosound(ptr)			(void)_trap_14_wl((short)0x20,(long)(ptr))
#define Setprt(config)			(short)_trap_14_ww((short)0x21,(short)(config))
#define Kbdvbase()			(_KBDVECS*)_trap_14_w((short)0x22)
#define Kbrate(delay,reprate)		(short)_trap_14_www((short)0x23,(short)(delay),(short)(reprate))
#define Prtblk(pblkptr)			(void)_trap_14_wl((short)0x24,(long)(pblkptr))
#define Vsync()				(void)_trap_14_w((short)0x25)
#define Supexec(funcptr)		(void)_trap_14_wl((short)0x26,(long)(funcptr))
#define Puntaes()			(void)_trap_14_w((short)0x27)
#define Floprate(drive,seekrate)	(short)_trap_14_www((short)0x29,(short)(drive),(short)(seekrate))
#define Blitmode(mode)			(void)_trap_14_ww((short)0x40,(short)(mode))

/* TOS030 XBios */
#define DMAread(sec,cnt,buf,dev)	_trap_14_wlwlw((short)0x2A,(long)(sec),(short)(cnt),(long)(buf),(short)(dev))
#define DMAwrite(sec,cnt,buf,dev)	_trap_14_wlwlw((short)0x2B,(long)(sec),(short)(cnt),(long)(buf),(short)(dev))
#define Bconmap(devno)			_trap_14_ww((short)0x2C,(short)(devno))
#define NMVaccess(op,start,cnt,buf)	(short)_trap_14_wwwwl((short)0x2E,(short)(op),(short)(start),(short)(cnt),(long)(buf))
#define EsetShift(shftMode)		(void)_trap_14_ww((short)0x50,(short)(shftMode))
#define EgetShift()			(short)_trap_14_w((short)0x51)
#define Esetbank(bankNum)		(short)_trap_14_ww((short)0x52,(short)(bankNum))
#define EsetColor(colorNum,color)	(short)_trap_14_www((short)0x53,(short)(colorNum),(short)(color))
#define EsetPalette(colNum,cnt,palPtr)	(void)_trap_14_wwwl((short)0x54,(short)(colNum),(short)(cnt),(long)(palPtr))
#define EgetPalette(colNum,cnt,palPtr)	(void)_trap_14_wwwl((short)0x55,(short)(colNum),(short)(cnt),(long)(palPtr))
#define EsetGray(switch)		(short)_trap_14_ww((short)0x56,(short)(switch))
#define EsetSmear(switch)		(short)_trap_14_ww((short)0x57,(short)(switch))

/* ST BOOK Xbios */
#define	Waketime(w_date,w_time)		(void)_trap_14_www((short)0x2F,(unsigned short)(w_date),(unsigned short)(w_time))


#else /* !__C68__ */

/* Support for GCC, Pure C/Turbo C and Lattice C
 * has been removed - if you've got one of these
 * compilers, use the  original  osbind.h to add
 * the needed bits...
 */

#endif /* __C68__ */


#ifdef __cplusplus
}
#endif

#endif /* _OSBIND_H */

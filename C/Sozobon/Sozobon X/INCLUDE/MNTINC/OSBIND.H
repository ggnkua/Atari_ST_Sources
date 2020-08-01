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

#if defined(__C68__) || defined(__SOZOBONX__)

__EXTERN long gemdos	__PROTO((short, ...));
__EXTERN long bios	__PROTO((short, ...));
__EXTERN long xbios	__PROTO((short, ...));

/*
 *	GEMDOS	(trap1)
 */
#define Pterm0()	(void)gemdos((short)0x00)
#define Cconin()	gemdos((short)0x01)
#define Cconout(c)	(void)gemdos((short)0x02,(short)(c))
#define Cauxin()	(short)gemdos((short)0x03)
#define Cauxout(c)	(void)gemdos((short)0x04,(short)(c))
#define Cprnout(c)	(short)gemdos((short)0x05,(short)(c))
#define Crawio(w)	gemdos((short)0x06,(short)(w))
#define Crawcin()	gemdos((short)0x07)
#define Cnecin()	gemdos((short)0x08)
#define Cconws(s)	(short)gemdos((short)0x09,(char*)(s))
#define Cconrs(buf)	(void)gemdos((short)0x0A,(char*)(buf))
#define Cconis()	(short)gemdos((short)0x0B)
#define Dsetdrv(d)	gemdos((short)0x0E,(short)(d))
#define Cconos()	(short)gemdos((short)0x10)
#define Cprnos()	(short)gemdos((short)0x11)
#define Cauxis()	(short)gemdos((short)0x12)
#define Cauxos()	(short)gemdos((short)0x13)
#define Dgetdrv()	(short)gemdos((short)0x19)
#define Fsetdta(dta)	(void)gemdos((short)0x1A,(_DTA*)(dta))
#define Super(ptr)	gemdos((short)0x20,(long)(ptr))
#define Tgetdate()	(short)gemdos((short)0x2A)
#define Tsetdate(date)	(short)gemdos((short)0x2B,(short)(date))
#define Tgettime()	(short)gemdos((short)0x2C)
#define Tsettime(time)	(short)gemdos((short)0x2D,(short)(time))
#define Fgetdta()	(_DTA*)gemdos((short)0x2F)
#define Sversion()	(short)gemdos((short)0x30)
#define Ptermres(sv,rv)	(void)gemdos((short)0x31,(long)(sv),(short)(rv))
#define Dfree(buf,d)	(short)gemdos((short)0x36,(void*)(buf),(short)(d))
#define Dcreate(path)	(short)gemdos((short)0x39,(char*)(path))
#define Ddelete(path)	(short)gemdos((short)0x3A,(char*)(path))
#define Dsetpath(path)	(short)gemdos((short)0x3B,(char*)(path))
#define Fcreate(fn,md)	(short)gemdos((short)0x3C,(char*)(fn),(short)(md))
#define Fopen(fn,md)	(short)gemdos((short)0x3D,(char*)(fn),(short)(md))
#define Fclose(h)	(short)gemdos((short)0x3E,(short)(h))
#define Fread(h,ct,bf)	gemdos((short)0x3F,(short)(h),(long)(ct),(char*)(bf))
#define Fwrite(h,ct,bf)	gemdos((short)0x40,(short)(h),(long)(ct),(char*)(bf))
#define Fdelete(fn)	(short)gemdos((short)0x41,(char*)(fn))
#define Fseek(off,h,md)	gemdos((short)0x42,(long)off,(short)(h),(short)(md))
#define Fattrib(f,w,a)	(short)gemdos((short)0x43,(char*)(f),(short)(w),(short)(a))
#define Fdup(h)		(short)gemdos((short)0x45,(short)(h))
#define Fforce(hs,hn)	(short)gemdos((short)0x46,(short)(hs),(short)(hn))
#define Dgetpath(buf,d)	(short)gemdos((short)0x47,(char*)(buf),(short)(d))
#define Malloc(size)	(long)gemdos((short)0x48,(long)(size))
#define Mfree(ptr)	(short)gemdos((short)0x49,(void*)(ptr))
#define Mshrink(ptr,sz)	(short)gemdos((short)0x4A,(short)0,(void*)(ptr),(long)(sz))
#define Pexec(md,p,t,e)	gemdos((short)0x4B,(short)(md),(char*)(p),(void*)(t),(void*)(e))
#define Pterm(rv)	(void)gemdos((short)0x4C,(short)(rv))
#define Fsfirst(sp,at)	(short)gemdos((short)0x4E,(char*)(sp),(short)(at))
#define Fsnext()	(short)gemdos((short)0x4F)
#define Frename(z,o,n)	(short)gemdos((short)0x56,(short)(z),(char*)(o),(char*)(n))
#define Fdatime(t,h,w)	gemdos((short)0x57,(_DOSTIME*)(t),(short)(h),(short)(w))

/* GEMDOS extensions */
#define Maddalt(st,sz)	gemdos((short)0x14,(void*)(st),(long)(sz))
#define Mxalloc(am,md)	gemdos((short)0x44,(long)(am),(short)(md))

/* Network Gemdos Extension */
#define Flock(h,md,s,l)	gemdos((short)0x5C,(short)(h),(short)(md),(long)(s),(long)(l))


/*
 *	BIOS	(trap13)
 */
#define Getmpb(mpb)		(void)bios((short)0x0,(_MPB*)(mpb))
#define Bconstat(dev)		(short)bios((short)0x1,(short)(dev))
#define Bconin(dev)		bios((short)0x2,(short)(dev))
#define Bconout(dev,c)		bios((short)0x3,(short)(dev),(short)(c))
#define Rwabs(wflg,buf,n,sec,d)	bios((short)0x4,(short)(wflg),(char*)(buf),(short)(n),(short)(sec),(short)(d))
#define Setexc(vnum,vptr)	(void(*))bios((short)0x5,(short)(vnum),(long)(vptr))
#define Tickcal()		bios((short)0x6)
#define Getbpb(d)		(_BPB*)bios((short)0x7,(short)(d))
#define Bcostat(dev)		bios((short)0x8,(short)(dev))
#define Mediach(d)		bios((short)0x9,(short)(d))
#define Drvmap()		bios((short)0xA)
#define Kbshift(mode)		bios((short)0xB,(short)(mode))
#define Getshift()		Kbshift(-1)


/*
 *		XBIOS	(trap14)
 */
#define Initmous(type,param,vptr)	(void)xbios((short)0x0,(short)(type),(_PARAM*)(param),(long)(vptr))
#define Ssbrk(amnt)			(void*)xbios((short)0x1,(short)(amnt))
#define Physbase()			(void*)xbios((short)0x2)
#define Logbase()			(void*)xbios((short)0x3)
#define Getrez()			(short)xbios((short)0x4)
#define Setscreen(lscrn,pscrn,rez)	(void)xbios((short)0x5,(long)(lscrn),(long)pscrn,(short)(rez))
#define Setpalette(palptr)		(void)xbios((short)0x6,(void*)(palptr))
#define Setcolor(colornum,mixture)	(short)xbios((short)0x7,(short)(colornum),(short)(mixture))
#define Floprd(buf,x,d,sect,trk,side,n)	(short)xbios((short)0x8,(void*)(buf),(long)(x),(short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define Flopwr(buf,x,d,sect,trk,side,n)	(short)xbios((short)0x9,(void*)(buf),(long)(x),(short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define Flopfmt(b,x,d,spt,trk,sd,i,m,v) (short)xbios((short)0xA,(void*)(b),(long)(x),(short)(d),(short)(spt),(short)(trk),(short)(sd),(short)(i),(long)(m),(short)(v))
#define Midiws(cnt,ptr)			(void)xbios((short)0xC,(short)(cnt),(void*)(ptr))
#define Mfpint(vnum,vptr)		(void)xbios((short)0xD,(short)(vnum),(long)(vptr))
#define Iorec(iodev)			(_IOREC*)xbios((short)0xE,(short)(iodev))
#define Rsconf(baud,flow,uc,rs,ts,sc)	xbios((short)0xF,(short)(baud),(short)(flow),(short)(uc),(short)(rs),(short)(ts),(short)(sc))
#define Keytbl(nrml,shft,caps)		(_KEYTAB*)xbios((short)0x10,(long)(nrml),(long)(shft),(long)(caps))
#define Random()			xbios((short)0x11)
#define Protobt(buf,serial,dsktyp,exec) (void)xbios((short)0x12,(void*)(buf),(long)(serial),(short)(dsktyp),(short)(exec))
#define Flopver(buf,x,d,sect,trk,sd,n)	(short)xbios((short)0x13,(void*)(buf),(long)(x),(short)(d),(short)(sect),(short)(trk),(short)(sd),(short)(n))
#define Scrdmp()			(void)xbios((short)0x14)
#define Cursconf(func,rate)		(short)xbios((short)0x15,(short)(func),(short)(rate))
#define Settime(time)			(void)xbios((short)0x16,(long)(time))
#define Gettime()			(long)xbios((short)0x17)
#define Bioskeys()			(void)xbios((short)0x18)
#define Ikbdws(len_minus1,ptr)		(void)xbios((short)0x19,(short)(len_minus1),(void*)(ptr))
#define Jdisint(vnum)			(void)xbios((short)0x1A,(short)(vnum))
#define Jenabint(vnum)			(void)xbios((short)0x1B,(short)(vnum))
#define Giaccess(data,reg)		(char)xbios((short)0x1C,(char)(data),(short)(reg))
#define Offgibit(ormask)		(void)xbios((short)0x1D,(short)(ormask))
#define Ongibit(andmask)		(void)xbios((short)0x1E,(short)(andmask))
#define Xbtimer(timer,ctrl,data,vnum)	(void)xbios((short)0x1F,(short)(timer),(short)(ctrl),(short)(data),(long)(vnum))
#define Dosound(ptr)			(void)xbios((short)0x20,(void*)(ptr))
#define Setprt(config)			(short)xbios((short)0x21,(short)(config))
#define Kbdvbase()			(_KBDVECS*)xbios((short)0x22)
#define Kbrate(delay,reprate)		(short)xbios((short)0x23,(short)(delay),(short)(reprate))
#define Prtblk(pblkptr)			(void)xbios((short)0x24,(_PBDEF*)(pblkptr))
#define Vsync()				(void)xbios((short)0x25)
#define Supexec(funcptr)		(void)xbios((short)0x26,(long)(funcptr))
#define Puntaes()			(void)xbios((short)0x27)
#define Floprate(drive,seekrate)	(short)xbios((short)0x29,(short)(drive),(short)(seekrate))
#define Blitmode(mode)			(void)xbios((short)0x40,(short)(mode))

/* TOS030 XBios */
#define DMAread(sec,cnt,buf,dev)	xbios((short)0x2A,(long)(sec),(short)(cnt),(void*)(buf),(short)(dev))
#define DMAwrite(sec,cnt,buf,dev)	xbios((short)0x2B,(long)(sec),(short)(cnt),(void*)(buf),(short)(dev))
#define Bconmap(devno)			xbios((short)0x2C,(short)(devno))
#define NMVaccess(op,start,cnt,buf)	(short)xbios((short)0x2E,(short)(op),(short)(start),(short)(cnt),(void*)(buf))
#define EsetShift(shftMode)		(void)xbios((short)0x50,(short)(shftMode))
#define EgetShift()			(short)xbios((short)0x51)
#define Esetbank(bankNum)		(short)xbios((short)0x52,(short)(bankNum))
#define EsetColor(colorNum,color)	(short)xbios((short)0x53,(short)(colorNum),(short)(color))
#define EsetPalette(colNum,cnt,palPtr)	(void)xbios((short)0x54,(short)(colNum),(short)(cnt),(void*)(palPtr))
#define EgetPalette(colNum,cnt,palPtr)	(void)xbios((short)0x55,(short)(colNum),(short)(cnt),(void*)(palPtr))
#define EsetGray(switch)		(short)xbios((short)0x56,(short)(switch))
#define EsetSmear(switch)		(short)xbios((short)0x57,(short)(switch))

/* ST BOOK Xbios */
#define	Waketime(w_date,w_time)		(void)xbios((short)0x2F,(unsigned short)(w_date),(unsigned short)(w_time))

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

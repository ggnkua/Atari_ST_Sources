/*
 * @(#)tosbind.h, SozobonX XdLibs (c) jerry g geiger 1995
 *
 * Mnemonic names for TOS operating system calls
 * last change
 *  -VS 1995/08/19
 */

#ifndef _TOSBIND_H
#define _TOSBIND_H

#ifndef __MSHORT__
/* if inlines are not allowed, then declare things external */
extern long trap_1_w (short n);
extern long trap_1_ww (short n, short a);
extern long trap_1_wl (short n, long a);
extern long trap_1_wlw (short n, long a, short b);
extern long trap_1_wwll (short n, short a, long b, long c);
extern long trap_1_wlww (short n, long a, short b, short c);
extern long trap_1_www (short n, short a, short b);
extern long trap_1_wll (short n, long a, long b);
extern long trap_1_wwlll (short n, short a, long b, long c, long d);
extern long trap_1_wwwll (short n, short a, short b, long c, long d);
extern long trap_13_wl (short n, long a);
extern long trap_13_w (short n);
extern long trap_13_ww (short n, short a);
extern long trap_13_www (short n, short a, short b);
extern long trap_13_wwlwww (short n, short a, long b, short c, short d, short e);
extern long trap_13_wwl (short n, short a, long b);
extern long trap_14_wwl (short n, short a, long b);
extern long trap_14_wwll (short n, short a, long b, long c);
extern long trap_14_ww (short n, short a);
extern long trap_14_w (short n);
extern long trap_14_wllw (short n, long a, long b, short c);
extern long trap_14_wl (short n, long a);
extern long trap_14_www (short n, short a, short b);
extern long trap_14_wllwwwww (short n, long a, long b, short c, short d, short e, short f, short g);
extern long trap_14_wllwwwwlw (short n, long a, long b, short c, short d, short e, short f, long g, short h);
extern long trap_14_wllwwwwwlw (short n, long a, long b, short c, short d, short e, short f, short g, long h, short i);
extern long trap_14_wwwwwww (short n, short a, short b, short c, short d, short e, short f);
extern long trap_14_wlll (short n, long a, long b, long c);
extern long trap_14_wllww (short n, long a, long b, short c, short d);
extern long trap_14_wwwwl (short n, short a, short b, short c, long d);
extern long trap_14_wwwl (short n, short a, short b, long c);
extern long trap_14_wlwlw (short n, long a, short b, long c, short d);

# else /* __MSHORT__ */

#ifndef _OSBIND_H
extern	long	gemdos(short, ...);
extern	long	bios(short, ...);
extern	long	xbios(short, ...);
extern	short	bdos();
#endif /* _OSBIND_H */

#define trap_1_w	gemdos
#define trap_1_ww	gemdos
#define trap_1_wl	gemdos
#define trap_1_wlw	gemdos
#define trap_1_www	gemdos
#define trap_1_wll	gemdos
#define trap_1_wwll	gemdos
#define trap_1_wlww	gemdos
#define trap_1_wwlll	gemdos
#define trap_1_wwwll	gemdos

#define trap_13_w	bios
#define trap_13_ww	bios
#define trap_13_wl	bios
#define trap_13_www	bios
#define trap_13_wwl	bios
#define trap_13_wwlwww	bios

#define trap_14_w	xbios
#define trap_14_ww	xbios
#define trap_14_wl	xbios
#define trap_14_www	xbios
#define trap_14_wwl	xbios
#define trap_14_wwll	xbios
#define trap_14_wllw	xbios
#define trap_14_wlll	xbios
#define trap_14_wwwl	xbios
#define trap_14_wwwwl	xbios
#define trap_14_wllww	xbios
#define trap_14_wwwwwww	xbios
#define trap_14_wllwwwww	xbios
#define trap_14_wllwwwwlw	xbios
#define trap_14_wllwwwwwlw	xbios
#define trap_14_wlwlw	xbios

# endif /* __MSHORT__ */

/* DEFINITIONS FOR OS FUNCTIONS */

/*
 *     GEMDOS  (trap1)
 */
#define	       Pterm0()					       	       \
       (void)trap_1_w((short)(0x00))
#define	       Cconin()						       \
       (long)trap_1_w((short)(0x01))
#define	       Cconout(c)					       \
       (void)trap_1_ww((short)(0x02),(short)(c))
#define	       Cauxin()						       \
       (long)trap_1_w((short)(0x03))
#define	       Cauxout(c)					       \
       (void)trap_1_ww((short)(0x04),(short)(c))
#define	       Cprnout(c)					       \
       (void)trap_1_ww((short)(0x05),(short)(c))
#define	       Crawio(data)					       \
       (long)trap_1_ww((short)(0x06),(short)(data))
#define	       Crawcin()					       \
       (long)trap_1_w((short)(0x07))
#define	       Cnecin()						       \
       (long)trap_1_w((short)(0x08))
#define	       Cconws(s)					       \
       (void)trap_1_wl((short)(0x09),(long)(s))
#define	       Cconrs(buf)					       \
       (void)trap_1_wl((short)(0x0A),(long)(buf))
#define	       Cconis()						       \
       (short)trap_1_w((short)(0x0B))
#define	       Dsetdrv(d)					       \
       (long)trap_1_ww((short)(0x0E),(short)(d))
#define	       Cconos()						       \
       (short)trap_1_w((short)(0x10))
#define	       Cprnos()						       \
       (short)trap_1_w((short)(0x11))
#define	       Cauxis()						       \
       (short)trap_1_w((short)(0x12))
#define	       Cauxos()						       \
       (short)trap_1_w((short)(0x13))
#define	       Dgetdrv()					       \
       (short)trap_1_w((short)(0x19))
#define	       Fsetdta(dta)					       \
       (void)trap_1_wl((short)(0x1A),(long)(dta))

/*
 * The next binding is not quite right if used in another than the usual ways:
 *	1. Super(1L) from either user or supervisor mode
 *	2. ret = Super(0L) from user mode and after this Super(ret) from
 *	   supervisor mode
 * We get the following situations (usp, ssp relative to the start of Super):
 *	Parameter	Userstack	Superstack	Calling Mode	ret
 *	   1L		   usp		   ssp		    user	 0L
 *	   1L		   usp		   ssp		 supervisor	-1L
 *	   0L		  usp-6		   usp		    user	ssp
 *	   0L		   ssp		  ssp-6		 supervisor   ssp-6
 *	  ptr		  usp-6		  ptr+6		    user	ssp
 *	  ptr		  usp+6		   ptr		 supervisor	 sr
 * The usual C-bindings are safe only because the "unlk a6" is compensating
 * the errors when you invoke this function. In this binding the "unlk a6" at
 * the end of the calling function compensates the error made in sequence 2
 * above (the usp is 6 to low after the first call which is not corrected by
 * the second call).
 */
#define	       Super(ptr)					       \
       (long)trap_1_wl((short)(0x20),(long)(ptr))
	/* Tos 1.4: Super(1L) : rets -1L if in super mode, 0L otherwise */
#define	       Tgetdate()					       \
       (short)trap_1_w((short)(0x2A))
#define	       Tsetdate(date)					       \
       (long)trap_1_ww((short)(0x2B),(short)(date))
#define	       Tgettime()					       \
       (short)trap_1_w((short)(0x2C))
#define	       Tsettime(time)					       \
       (long)trap_1_ww((short)(0x2D),(short)(time))
#define	       Fgetdta()					       \
       (DTA *)trap_1_w((short)(0x2F))
#define	       Sversion()					       \
       (short)trap_1_w((short)(0x30))
#define	       Ptermres(save,rv)				       \
       (void)trap_1_wlw((short)(0x31),(long)(save),(short)(rv))
#define	       Dfree(buf,d)					       \
       (long)trap_1_wlw((short)(0x36),(long)(buf),(short)(d))
#define	       Dcreate(path)					       \
       (short)trap_1_wl((short)(0x39),(long)(path))
#define	       Ddelete(path)					       \
       (long)trap_1_wl((short)(0x3A),(long)(path))
#define	       Dsetpath(path)					       \
       (long)trap_1_wl((short)(0x3B),(long)(path))
#define	       Fcreate(fn,mode)					       \
       (long)trap_1_wlw((short)(0x3C),(long)(fn),(short)(mode))
#define	       Fopen(fn,mode)					       \
       (long)trap_1_wlw((short)(0x3D),(long)(fn),(short)(mode))
#define	       Fclose(handle)					       \
       (long)trap_1_ww((short)(0x3E),(short)(handle))
#define	       Fread(handle,cnt,buf)				       \
       (long)trap_1_wwll((short)(0x3F),(short)(handle),	       \
			 (long)(cnt),(long)(buf))
#define	       Fwrite(handle,cnt,buf)				       \
       (long)trap_1_wwll((short)(0x40),(short)(handle),	       \
			 (long)(cnt),(long)(buf))
#define	       Fdelete(fn)					       \
       (long)trap_1_wl((short)(0x41),(long)(fn))
#define	       Fseek(where,handle,how)				       \
       (long)trap_1_wlww((short)(0x42),(long)(where),	       \
			 (short)(handle),(short)(how))
#define	       Fattrib(fn,rwflag,attr)				       \
       (short)trap_1_wlww((short)(0x43),(long)(fn),	       \
			  (short)(rwflag),(short)(attr))
#define	       Fdup(handle)					       \
       (long)trap_1_ww((short)(0x45),(short)(handle))
#define	       Fforce(Hstd,Hnew)				       \
       (long)trap_1_www((short)(0x46),(short)(Hstd),(short)(Hnew))
#define	       Dgetpath(buf,d)					       \
       (long)trap_1_wlw((short)(0x47),(long)(buf),(short)(d))
#define	       Malloc(size)					       \
       (long)trap_1_wl((short)(0x48),(long)(size))
#define	       Mfree(ptr)					       \
       (long)trap_1_wl((short)(0x49),(long)(ptr))
#define	       Mshrink(ptr,size)				       \
       (long)trap_1_wwll((short)(0x4A),(short)0,(long)(ptr),(long)(size))
#define	       Pexec(mode,prog,tail,env)		       \
       (long)trap_1_wwlll((short)(0x4B),(short)(mode),(long)(prog),   \
			   (long)(tail),(long)(env))
#define	       Pterm(rv)					       \
       (void)trap_1_ww((short)(0x4C),(short)(rv))
#define	       Fsfirst(filespec,attr)				       \
       (long)trap_1_wlw((short)(0x4E),(long)(filespec),(short)(attr))
#define	       Fsnext()						       \
       (long)trap_1_w((short)(0x4F))
#define	       Frename(zero,old,new)				       \
       (short)trap_1_wwll((short)(0x56),(short)(zero),	       \
			  (long)(old),(long)(new))
#define	       Fdatime(timeptr,handle,rwflag)			       \
       (long)trap_1_wlww((short)(0x57),(long)(timeptr),	       \
			 (short)(handle),(short)(rwflag))
#define	       Flock(handle,mode,start,length)			       \
       (long)trap_1_wwwll((short)(0x5C),(short)(handle),       \
			  (short)(mode),(long)(start),(long)(length))

/*
 *     BIOS    (trap13)
 */
#define Getmpb(ptr)					       \
       (void)trap_13_wl((short)(0x00),(long)(ptr))
#define	       Bconstat(dev)					       \
       (short)trap_13_ww((short)(0x01),(short)(dev))
#define	       Bconin(dev)					       \
       (long)trap_13_ww((short)(0x02),(short)(dev))
#define	       Bconout(dev,c)					       \
       (long)trap_13_www((short)(0x03),(short)(dev),(short)((c) & 0xFF))
/* since AHDI 3.1 there is a new call to Rwabs with one more parameter */
#define	       Rwabs(rwflag,buf,n,sector,d)			\
       (long)trap_13_wwlwww((short)(0x04),(short)(rwflag),(long)(buf), \
			     (short)(n),(short)(sector),(short)(d))
#define	       Setexc(vnum,vptr) 				      \
       (void (*) (void))trap_13_wwl((short)(0x05),(short)(vnum),(long)(vptr))
#define	       Tickcal()					       \
       (long)trap_13_w((short)(0x06))
#define	       Getbpb(d)					       \
       (void *)trap_13_ww((short)(0x07),(short)(d))
#define	       Bcostat(dev)					       \
       (short)trap_13_ww((short)(0x08),(short)(dev))
#define	       Mediach(dev)					       \
       (short)trap_13_ww((short)(0x09),(short)(dev))
#define	       Drvmap()						       \
       (long)trap_13_w((short)(0x0A))
#define	       Kbshift(data)					       \
       (long)trap_13_ww((short)(0x0B),(short)(data))
#define	       Getshift()					       \
	Kbshift(-1)


/*
 *     XBIOS   (trap14)
 */

#define	       Initmous(type,param,vptr)			       \
       (void)trap_14_wwll((short)(0x00),(short)(type),	       \
			  (long)(param),(long)(vptr))
#define Ssbrk(size)					       \
       (void *)trap_14_ww((short)(0x01),(short)(size))
#define	       Physbase()					       \
       (void *)trap_14_w((short)(0x02))
#define	       Logbase()					       \
       (void *)trap_14_w((short)(0x03))
#define	       Getrez()						       \
       (short)trap_14_w((short)(0x04))
#define	       Setscreen(lscrn,pscrn,rez)			       \
       (void)trap_14_wllw((short)(0x05),(long)(lscrn),(long)(pscrn), \
			  (short)(rez))
#define	       Setpalette(palptr)				       \
       (void)trap_14_wl((short)(0x06),(long)(palptr))
#define	       Setcolor(colornum,mixture)			       \
       (short)trap_14_www((short)(0x07),(short)(colornum),(short)(mixture))
#define	       Floprd(buf,x,d,sect,trk,side,n)			       \
       (short)trap_14_wllwwwww((short)(0x08),(long)(buf),(long)(x), \
	 (short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define	       Flopwr(buf,x,d,sect,trk,side,n)			       \
       (short)trap_14_wllwwwww((short)(0x09),(long)(buf),(long)(x), \
	       (short)(d),(short)(sect),(short)(trk),(short)(side),(short)(n))
#define	       Flopfmt(buf,x,d,spt,t,sd,i,m,v)		       \
       (short)trap_14_wllwwwwwlw((short)(0x0A),(long)(buf),(long)(x), \
	  (short)(d),(short)(spt),(short)(t),(short)(sd),(short)(i),  \
	  (long)(m),(short)(v))
#define	       Midiws(cnt,ptr)					       \
       (void)trap_14_wwl((short)(0x0C),(short)(cnt),(long)(ptr))
#define	       Mfpint(vnum,vptr)				       \
       (void)trap_14_wwl((short)(0x0D),(short)(vnum),(long)(vptr))
#define	       Iorec(ioDEV)					       \
       (void *)trap_14_ww((short)(0x0E),(short)(ioDEV))
#define	       Rsconf(baud,flow,uc,rs,ts,sc)			       \
       (long)trap_14_wwwwwww((short)(0x0F),(short)(baud),(short)(flow), \
			  (short)(uc),(short)(rs),(short)(ts),(short)(sc))
	/* ret old val: MSB -> ucr:8, rsr:8, tsr:8, scr:8 <- LSB */
#define	       Keytbl(nrml,shft,caps)				       \
       (void *)trap_14_wlll((short)(0x10),(long)(nrml), \
			    (long)(shft),(long)(caps))
#define	       Random()						       \
       (long)trap_14_w((short)(0x11))
#define	       Protobt(buf,serial,dsktyp,exec)			       \
       (void)trap_14_wllww((short)(0x12),(long)(buf),(long)(serial), \
			   (short)(dsktyp),(short)(exec))
#define	       Flopver(buf,x,d,sect,trk,sd,n)			       \
       (short)trap_14_wllwwwww((short)(0x13),(long)(buf),(long)(x),(short)(d),\
	       (short)(sect),(short)(trk),(short)(sd),(short)(n))
#define	       Scrdmp()						       \
       (void)trap_14_w((short)(0x14))
#define	       Cursconf(rate,attr)				       \
       (short)trap_14_www((short)(0x15),(short)(rate),(short)(attr))
#define	       Settime(time)					       \
       (void)trap_14_wl((short)(0x16),(long)(time))
#define	       Gettime()					       \
       (long)trap_14_w((short)(0x17))
#define	       Bioskeys()					       \
       (void)trap_14_w((short)(0x18))
#define	       Ikbdws(len_minus1,ptr)				       \
       (void)trap_14_wwl((short)(0x19),(short)(len_minus1),(long)(ptr))
#define	       Jdisint(vnum)					       \
       (void)trap_14_ww((short)(0x1A),(short)(vnum))
#define	       Jenabint(vnum)					       \
       (void)trap_14_ww((short)(0x1B),(short)(vnum))
#define	       Giaccess(data,reg)				       \
       (short)trap_14_www((short)(0x1C),(short)(data),(short)(reg))
#define	       Offgibit(ormask)					       \
       (void)trap_14_ww((short)(0x1D),(short)(ormask))
#define	       Ongibit(andmask)					       \
       (void)trap_14_ww((short)(0x1E),(short)(andmask))
#define	       Xbtimer(timer,ctrl,data,vptr)			       \
       (void)trap_14_wwwwl((short)(0x1F),(short)(timer),(short)(ctrl), \
			   (short)(data),(long)(vptr))
#define	       Dosound(ptr)					       \
       (void)trap_14_wl((short)(0x20),(long)(ptr))
#define	       Setprt(config)					       \
       (short)trap_14_ww((short)(0x21),(short)(config))
#define	       Kbdvbase()					       \
       (KBDVECS*)trap_14_w((short)(0x22))
#define	       Kbrate(delay,reprate)				       \
       (short)trap_14_www((short)(0x23),(short)(delay),(short)(reprate))
#define	       Prtblk(pblkptr)					       \
       (void)trap_14_wl((short)(0x24),(long)(pblkptr)) /* obsolete ? */
#define	       Vsync()						       \
       (void)trap_14_w((short)(0x25))
#define	       Supexec(funcptr)					       \
       (long)trap_14_wl((short)(0x26),(long)(funcptr))
#define	       Floprate(drive,rate)				       \
       (short)trap_14_www((short)(0x29),(short)(drive),(short)(rate))
#define	       Blitmode(flag)					       \
       (short)trap_14_ww((short)(0x40),(short)(flag))
/*
 * Flag:
 *  -1: get config
 * !-1: set config	previous config returned
 *	bit
 *	 0	0 blit mode soft	1 blit mode hardware
 *	 1	0 no blitter		1 blitter present
 *	2..14   reserved
 *	 15	must be zero on set/returned as zero
 * blitmode (bit 0) forced to soft if no blitter(bit 1 == 0).
 */

/*
 * extensions for TT TOS
 */

#define         Mxalloc(amt,flag)					\
	(long)trap_1_wlw((short)(0x44),(long)(amt),(short)(flag))
#define		Maddalt(start,size)					\
	(long)trap_1_wll((short)(0x14),(long)(start),(long)(size))

#define         EsetShift(mode)						\
	(void)trap_14_ww((short)(80),(short)mode)
#define         EgetShift()						\
	(short)trap_14_w((short)(81))
#define         EsetBank(bank)						\
	(short)trap_14_ww((short)(82),(short)bank)
#define         EsetColor(num,val)					\
	(short)trap_14_www((short)(83),(short)num,(short)val)
#define         EsetPalette(start,count,ptr)				\
	(void)trap_14_wwwl((short)(84),(short)start,(short)count,(long)ptr)
#define         EgetPalette(start,count,ptr)				\
	(void)trap_14_wwwl((short)(85),(short)start,(short)count,(long)ptr)
#define         EsetGray(mode)						\
	(short)trap_14_ww((short)(86),(short)mode)
#define         EsetSmear(mode)						\
	(short)trap_14_ww((short)(87),(short)mode)

#define		DMAread(sector,count,buffer,devno)			\
	(long)trap_14_wlwlw((short)0x2a,(long)sector,(short)count,(long)buffer, \
			    (short)devno)
#define		DMAwrite(sector,count,buffer,devno)			\
	(long)trap_14_wlwlw((short)0x2b,(long)sector,(short)count,(long)buffer, \
			(short)devno)
#define		Bconmap(dev)						\
	(long)trap_14_ww((short)0x2c,(short)(dev))
#define		NVMaccess(op,start,count,buf)				\
	(short)trap_14_wwwwl((short)0x2e,(short)op,(short)start,(short)count, \
			(long)buf)

/*  Wake-up call for ST BOOK -- takes date/time pair in DOS format. */

#define	       Waketime(w_date, w_time)					\
       (void)trap_14_www((short)(0x2f),(unsigned short)(w_date),	\
				       (unsigned short)(w_time))

#endif	/* _TOSBIND_H */

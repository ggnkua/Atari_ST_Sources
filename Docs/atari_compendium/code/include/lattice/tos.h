/*
 * Master TOS Header File (Pragmas/Protos for Lattice 'C')
 * Composed by Scott Sanders
 *
 * Last Update: 9/24/94 (SDS)
 */
 
#ifndef _tos_h_
#define _tos_h_

#include <TOSDEFS.H>

/******************************************** GEMDOS *****/

LONG gemdos( WORD, ... );

LONG *__ngv(WORD);
LONG __lgc(WORD,const char *);
LONG __lgcc(WORD,const char *,const char *);
LONG __lgcs(WORD,const char *,WORD);
LONG __lgcss(WORD,const char *,WORD,WORD);
LONG __lgds(WORD,char *,WORD);
LONG __lgl(WORD,LONG);
LONG __lglss(WORD,LONG,WORD,WORD);
LONG __lgns(WORD,LONG *,WORD);
LONG __lgp(WORD,void *);
LONG __lgpl(WORD,void *,LONG);
LONG __lgrss(WORD,WORD *,WORD,WORD);
LONG __lgs(WORD,WORD);
LONG __lgscc(WORD,WORD,const char *,const char *);
LONG __lgsccc(WORD,WORD,const char *,const char *,const char *);
LONG __lgscp(WORD,WORD,const char *,void *);
LONG __lgsdc(WORD,WORD,char *,const char *);
LONG __lgsl(WORD,WORD,LONG);
LONG __lgsld(WORD,WORD,LONG,char *);
LONG __lgsll(WORD,WORD,LONG,LONG);
LONG __lgssll(WORD,WORD,WORD,LONG,LONG);
LONG __lgslp(WORD,WORD,LONG,void *);
LONG __lgslq(WORD,WORD,LONG,const void *);
LONG __lgspp(WORD,WORD,void *,void *);
LONG __lgsls(WORD,WORD,LONG,WORD);
LONG __lgsn(WORD,WORD,LONG *);
LONG __lgspl(WORD,WORD,void *,LONG);
LONG __lgss(WORD,WORD,WORD);
LONG __lgssn(WORD,WORD,WORD,void *);
LONG __lgsss(WORD,WORD,WORD,WORD);
LONG __lgu(WORD,UWORD);
LONG __lgv(WORD);
LONG __sgunnn(WORD,unsigned,LONG *,LONG *,LONG *);
LONG __vgn(WORD,LONG *);
WORD __sgr(WORD,WORD *);
WORD __sgs(WORD,WORD);
WORD __sgsl(WORD,WORD,LONG);
WORD __sgsls(WORD,WORD,LONG,WORD);
WORD __sgss(WORD,WORD,WORD);
WORD __sgv(WORD);
UWORD __ugv(WORD);
void (*__stdargs __ggsg(WORD,WORD,void (*__stdargs)(LONG)));
void *__pgl(WORD,LONG);
void *__pgls(WORD,LONG,WORD);
void *__pgp(WORD,void *);
void *__pgs(WORD,WORD);
void *__pgv(WORD);
void __vgc(WORD,const char *);
void __vgls(WORD,LONG,WORD);
void __vgp(WORD,void *);
void __vgs(WORD,WORD);
void __vgv(WORD);

LONG *__nbv(WORD);
LONG *__nbv(WORD);

#pragma inline __vgc((WORD),)		{register d2,a2; "4e41";}
#pragma inline __vgls((WORD),,(WORD))	{register d2,a2; "4e41";}
#pragma inline __vgn((WORD),)		{register d2,a2; "4e41";}
#pragma inline __vgp((WORD),)		{register d2,a2; "4e41";}
#pragma inline __vgs((WORD),(WORD))		{register d2,a2; "4e41";}
#pragma inline __vgv((WORD))			{register d2,a2; "4e41";}
#pragma inline d0=__ggsg((WORD),(WORD),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgc((WORD),)		{register d2,a2; "4e41";}
#pragma inline d0=__lgcc((WORD),,)		{register d2,a2; "4e41";}
#pragma inline d0=__lgcs((WORD),,(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgcss((WORD),,(WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgds((WORD),,(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgl((WORD),)		{register d2,a2; "4e41";}
#pragma inline d0=__lglss((WORD),,(WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgns((WORD),,(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgp((WORD),)		{register d2,a2; "4e41";}
#pragma inline d0=__lgpl((WORD),,)		{register d2,a2; "4e41";}
#pragma inline d0=__lgrss((WORD),,(WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgs((WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgscc((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsccc((WORD),(WORD),,,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgscp((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgspp((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsdc((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsl((WORD),(WORD),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsld((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsll((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgssll((WORD),(WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgssn((WORD),(WORD),(WORD),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgslp((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgslq((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsls((WORD),(WORD),,(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgsn((WORD),(WORD),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgspl((WORD),(WORD),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgss((WORD),(WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgsss((WORD),(WORD),(WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgu((WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__lgv((WORD))		{register d2,a2; "4e41";}
#pragma inline d0=__ngv((WORD))		{register d2,a2; "4e41";}
#pragma inline d0=__pgl((WORD),)		{register d2,a2; "4e41";}
#pragma inline d0=__pgls((WORD),,(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__pgp((WORD),)   		{register d2,a2; "4e41";}
#pragma inline d0=__pgs((WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__pgv((WORD))		{register d2,a2; "4e41";}
#pragma inline d0=__sgr((WORD),)		{register d2,a2; "4e41";}
#pragma inline d0=__sgs((WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__sgsl((WORD),(WORD),)	{register d2,a2; "4e41";}
#pragma inline d0=__sgsls((WORD),(WORD),,(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__sgss((WORD),(WORD),(WORD))	{register d2,a2; "4e41";}
#pragma inline d0=__sgunnn((WORD),(WORD),,,)	{register d2,a2; "4e41";}
#pragma inline d0=__sgv((WORD))		{register d2,a2; "4e41";}
#pragma inline d0=__ugv((WORD))		{register d2,a2; "4e41";}
					
#pragma inline d0=__nbv((WORD))		{register d2,a2; "4e4d";}
#pragma inline d0=__nxv((WORD))	{register d2,a2; "4e4e";}
					
#define Pterm0()		__vgv(0x0)
#define Cconin()		__lgv(0x1)
#define Cconout(a)		__vgs(0x2,a)
#define Cauxin()		__sgv(0x3)
#define Cauxout(a)		__vgs(0x4,a)
#define Cprnout(a)		__lgs(0x5,a)
#define Crawio(a)		__lgs(0x6,a)
#define Crawcin()		__lgv(0x7)
#define Cnecin()		__lgv(0x8)
#define Cconws(a)		__vgc(0x9,a)
#define Cconrs(a)		__vgp(0x0a,a)
#define Cconis()		__sgv(0x0b)
#define Dsetdrv(a)		__lgs(0x0e,a)
#define Cconos()		__sgv(0x10)
#define Cprnos()		__sgv(0x11)
#define Cauxis()		__sgv(0x12)
#define Cauxos()		__sgv(0x13)
#define Maddalt(a,b)		__lgpl(0x14,a,b)
#define Dgetdrv()		__sgv(0x19)
#define Fsetdta(a)		__vgp(0x1a,a)
#define Super(a)		__pgp(0x20,a)
#define Tgetdate()		__ugv(0x2a)
#define Tsetdate(a)		__lgu(0x2b,a)
#define Tgettime()		__ugv(0x2c)
#define Tsettime(a)		__lgu(0x2d,a)
#define Fgetdta()		__pgv(0x2f)
#define Sversion()		__ugv(0x30)
#define Ptermres(a,b)		__vgls(0x31,a,b)
#define Dfree(a,b)		__lgns(0x36,a,b)
#define Dcreate(a)		__lgc(0x39,a)
#define Ddelete(a)		__lgc(0x3a,a)
#define Dsetpath(a)		__lgc(0x3b,a)
#define Fcreate(a,b)		__lgcs(0x3c,a,b)
#define Fopen(a,b)		__lgcs(0x3d,a,b)
#define Fclose(a)		__lgs(0x3e,a)
#define Fread(a,b,c)		__lgslp(0x3f,a,b,c)
#define Fwrite(a,b,c)		__lgslq(0x40,a,b,c)
#define Fdelete(a)		__lgc(0x41,a)
#define Fseek(a,b,c)		__lglss(0x42,a,b,c)
#define Fattrib(a,b,c)	__lgcss(0x43,a,b,c)
#define Mxalloc(a,b)		__pgls(0x44,a,b)
#define Fdup(a)		__lgs(0x45,a)
#define Fforce(a,b)		__lgss(0x46,a,b)
#define Dgetpath(a,b)		__lgds(0x47,a,b)
#define Malloc(a)		__pgl(0x48,a)
#define Mfree(a)		__lgp(0x49,a)
#define Mshrink(a,b)		__lgspl(0x4a,0,a,b)
#define Pexec(a,b,c,d)	__lgsccc(0x4b,a,b,c,d)
#define Pterm(a)		__vgs(0x4c,a)
#define Fsfirst(a,b)		__lgcs(0x4e,a,b)
#define Fsnext()		__lgv(0x4f)
#define Frename(a,b,c)	__lgscc(0x56,a,b,c)
#define Fdatime(a,b,c)	__lgrss(0x57,a,b,c)
#define Flock(a,b,c,d)	__lgssll(0x5c,a,b,c,d)

#define Syield()		__sgv(0xff)
#define Fpipe(a)		__sgr(0x100,a)
#define Fcntl(a,b,c)		__sgsls(0x104,a,b,c)
#define Finstat(a)		__lgs(0x105,a)
#define Foutstat(a)		__lgs(0x106,a)
#define Fgetchar(a,b)		__lgss(0x107,a,b)
#define Fputchar(a,b,c)	__lgsls(0x108,a,b,c)
#define Pwait()		__lgv(0x109)
#define Pnice(a)		__sgs(0x10a,a)
#define Pgetpid()		__sgv(0x10b)
#define Pgetppid()		__sgv(0x10c)
#define Pgetpgrp()		__sgv(0x10d)
#define Psetpgrp(a,b)		__sgss(0x010e,a,b)
#define Pgetuid()		__sgv(0x10f)
#define Psetuid(a)		__sgs(0x110,a)
#define Pkill(a,b)		__sgss(0x111,a,b)
#define Psignal(a,b)		__ggsg(0x112,a,b)
#define Pvfork()		__sgv(0x113)
#define Pgetgid()		__sgv(0x114)
#define Psetgid(a)		__sgs(0x115,a)
#define Psigblock(a)		__lgl(0x116,a)
#define Psigsetmask(a)	__lgl(0x117,a)
#define Pusrval(a)		__lgl(0x118,a)
#define Pdomain(a)		__sgs(0x119,a)
#define Psigreturn()		__lgv(0x11a)
#define Pfork()		__lgv(0x11b)
#define Pwait3(a,b)		__lgsn(0x11c,a,b)
#define Fselect(a,b,c,d)	__sgunnn(0x11d,a,b,c,d)
#define Prusage(a)		__lgn(0x11e,a)
#define Psetlimit(a,b)	__lgsl(0x11f,a,b)
#define Talarm(a)		__lgl(0x120,a)
#define Pause()		__vgv(0x121)
#define Sysconf(a)		__lgs(0x122,a)
#define Psigpending()		__lgv(0x123)
#define Dpathconf(a,b)	__lgcs(0x124,a,b)
#define Pmsg(a,b,c)		__lgslp(0x125,a,b,c)
#define Fmidipipe(a,b,c)	__lgsss(0x126,a,b,c)
#define Prenice(a,b)		__sgss(0x127,a,b)
#define Dopendir(a,b)		__lgcs(0x128,a,b)
#define Dreaddir(a,b,c)	__lgslp(0x129,a,b,c)
#define Drewinddir(a)		__lgl(0x12a,a)
#define Dclosedir(a)		__lgl(0x12b,a)
#define Fxattr(a,b,c)		__lgscp(0x12c,a,b,c)
#define Flink(a,b)		__lgcc(0x12d,a,b)
#define Fsymlink(a,b)		__lgcc(0x12e,a,b)
#define Freadlink(a,b,c)	__lgsdc(0x12f,a,b,c)
#define Dcntl(a,b,c)		__lgscp(0x130,a,b,c)
#define Fchown(a,b,c)		__lgcss(0x131,a,b,c)
#define Fchmod(a,b)		__lgcs(0x132,a,b)
#define Pumask(a)		__lgu(0x133,a)
#define Psemaphore(a,b,c)	__lgsll(0x134,a,b,c)
#define Dlock(a,b)		__lgss(0x135,a,b)
#define Psigpause(a)		__lgl(0x136, a)
#define Psigaction(a,b,c)	__lgspp(0x137,a,b,c)
#define Pgeteuid()		__sgv(0x138)
#define Pgetegid()		__sgv(0x139)
#define Pwaitpid(a,b,c)	__lgssn(0x13A,a,b,c)
#define Dgetcwd(a,b,c)	__lgxss(0x13B,a,b,c)
#define Salert(a)		__vgc(0x13C,a)

#define Dos_tab()		__ngv(-1)
#define Bios_tab()		__nbv(-1)
#define Xbios_tab()		__nxv(-1)

/* Lattice GEMDOS Extension */
WORD _mediach(WORD);		/* force GEMDOS media change */

/**************************************************** BIOS bindings */

LONG bios( WORD, ... );

void __vbp(WORD,void *);
LONG __lbs(WORD,WORD);
LONG __lbss(WORD,WORD,WORD);
LONG __lbspsss(WORD,WORD,void *,WORD,WORD,WORD);
LONG __lbspsssl(WORD,WORD,void *,WORD,WORD,WORD,LONG);
void (*__fbsf(WORD,WORD,void (*)()))();
LONG __lbv(WORD);
void *__pbs(WORD,WORD);
ULONG __mbv(WORD);
LONG *__nbv(WORD);

#pragma inline d0=__nbv((WORD))		{register d2,a2; "4e4d";}
#pragma inline __vbp((WORD),)		{register d2,a2; "4e4d";}
#pragma inline d0=__lbs((WORD),(WORD))	{register d2,a2; "4e4d";}
#pragma inline d0=__lbss((WORD),(WORD),(WORD))	{register d2,a2; "4e4d";}
#pragma inline d0=__lbspsss((WORD),(WORD),,(WORD),(WORD),(WORD))	{register d2,a2; "4e4d";}
#pragma inline d0=__lbspsssl((WORD),(WORD),,(WORD),(WORD),(WORD),)	{register d2,a2; "4e4d";}
#pragma inline d0=__fbsf((WORD),(WORD),)	{register d2,a2; "4e4d";}
#pragma inline d0=__lbv((WORD))		{register d2,a2; "4e4d";}
#pragma inline d0=__pbs((WORD),(WORD))	{register d2,a2; "4e4d";}
#pragma inline d0=__mbv((WORD))		{register d2,a2; "4e4d";}

#define Getmpb(a)			__vbp(0,a)
#define Bconstat(a)			__lbs(1,a)
#define Bconin(a)			__lbs(2,a)
#define Bconout(a,b)			__lbss(3,a,b)
#define Rwabs(a,b,c,d,e)		__lbspsss(4,a,b,c,d,e)
#define Lrwabs(a,b,c,d,e)		__lbspsssl(4,a,b,c,-1,d,e)
#define Setexc(a,b)			__fbsf(5,a,b)
#define Tickcal()			__lbv(6)
#define Getbpb(a)			__pbs(7,a)
#define Bcostat(a)			__lbs(8,a)
#define Mediach(a)			__lbs(9,a)
#define Drvmap()			__mbv(10)
#define Kbshift(a)			__lbs(11,a)

/**************************************************** XBIOS bindings */

LONG xbios( WORD, ... );

UCHAR __dxss(WORD,WORD,WORD);
LONG __lxg(WORD,LONG (*)(void));
LONG __lxv(WORD);
LONG __lxp(WORD,void *);
ULONG __mxssssss(WORD,WORD,WORD,WORD,WORD,WORD,WORD);
void *__pxs(WORD,WORD);
void *__pxv(WORD);
char **__rxccc(WORD,const char *,const char *,const char *);
void **__rxv(WORD);
WORD __sxppsssss(WORD,void *,void *,WORD,WORD,WORD,WORD,WORD);
WORD __sxprsssssls(WORD,void *,WORD *,WORD,WORD,WORD,WORD,WORD,LONG,WORD);
WORD __sxs(WORD,WORD);
WORD __sxss(WORD,WORD,WORD);
WORD __sxv(WORD);
void __vxc(WORD,const char *);
void __vxm(WORD,ULONG);
ULONG __mxv(WORD);
void __vxp(WORD,void *);
WORD __sxp(WORD,void *);
void __vxplss(WORD,void *,LONG,WORD,WORD);
void __vxpps(WORD,void *,void *,WORD);
void __vxs(WORD,WORD);
void __vxsf(WORD,WORD,void (*)(void));
void __vxsl(WORD,WORD,LONG);
void __vxsp(WORD,WORD,void *);
void __vxspf(WORD,WORD,void *,void (*)());
void __vxsssf(WORD,WORD,WORD,WORD,void (*)());
void __vxv(WORD);
LONG __lxlsps(WORD,LONG,WORD,void *,WORD);
WORD __sxsssd(WORD,WORD,WORD,WORD,char *);
LONG __lxs(WORD,WORD);
void __vxssr(WORD,WORD,WORD,WORD *);
LONG __lxsl(WORD,WORD,LONG);
LONG *__nxv(WORD);
WORD __sxsp(WORD,WORD,void *);
LONG __lxspls(WORD,WORD,void *,LONG,WORD);
LONG __lxsqls(WORD,WORD,void *,LONG,WORD);
LONG __lxsp(WORD,WORD,void *);
LONG __lxssc(WORD,WORD,WORD,const char *);
LONG __lxss(WORD,WORD,WORD);
LONG __lxsss(WORD,WORD,WORD,WORD);
LONG __lxssss(WORD,WORD,WORD,WORD,WORD);
LONG __lxssp(WORD,WORD,WORD,void *);
LONG __lxspp(WORD,WORD,void *,void *);
WORD __sxll(WORD,LONG,LONG);
WORD __sxcsc(WORD,const char *,WORD,const char *);
void __vxclcl(WORD,const char *,LONG,const char *,LONG);
void __vxnlnl(WORD,LONG *,LONG,LONG *,LONG);
void __vxnn(WORD,LONG *,LONG *);
void __vxccllln(WORD,const char *,const char *,LONG,LONG,LONG,LONG *);
void __vxcls(WORD,const char *,LONG,WORD);
void __vxrlrl(WORD,WORD *,LONG,WORD *,LONG);
void __vxelel(WORD,UCHAR *,LONG,UCHAR *,LONG);
void __vxfo(WORD,void (*)(),LONG (*)());
void __vxllpp(WORD,LONG,LONG,void *,void *);
void __lxcc(WORD,const char *,const char *);
UCHAR __dxv(WORD);
void __vxssp(WORD,WORD,WORD,void *);
void __vxppss(WORD,void *,void *,WORD,WORD);
void __vxlls(WORD,LONG,LONG,WORD);
void __vxuu(WORD,UWORD,UWORD);

#pragma inline __vxcls((WORD),,,(WORD))	{register d2,a2; "4e4e";}
#pragma inline __vxppss((WORD),,,(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline __vxlls((WORD),,,(WORD))	{register d2,a2; "4e4e";}
#pragma inline __vxssp((WORD),(WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxcc((WORD),,)		{register d2,a2; "4e4e";}
#pragma inline d0=__dxv((WORD))		{register d2,a2; "4e4e";}
#pragma inline __vxllpp((WORD),,,,)		{register d2,a2; "4e4e";}
#pragma inline __vxfo((WORD),,)		{register d2,a2; "4e4e";}
#pragma inline __vxrlrl((WORD),,,,)		{register d2,a2; "4e4e";}
#pragma inline __vxccllln((WORD),,,,,,)	{register d2,a2; "4e4e";}
#pragma inline __vxclcl((WORD),,,,)		{register d2,a2; "4e4e";}
#pragma inline __vxnlnl((WORD),,,,)		{register d2,a2; "4e4e";}
#pragma inline __vxnn((WORD),,)		{register d2,a2; "4e4e";}
#pragma inline d0=__sxsp((WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__sxll((WORD),,)		{register d2,a2; "4e4e";}
#pragma inline d0=__sxcsc((WORD),,(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxspls((WORD),(WORD),,,(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxsqls((WORD),(WORD),,,(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxp((WORD),)		{register d2,a2; "4e4e";}
#pragma inline d0=__lxsp((WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxssc((WORD),(WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxss((WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxsss((WORD),(WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxssss((WORD),(WORD),(WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxsssss((WORD),(WORD),(WORD),(WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxspp((WORD),(WORD),,)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxssp((WORD),(WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__nxv((WORD))		{register d2,a2; "4e4e";}
#pragma inline d0=__lxsl((WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline __vxssr((WORD),(WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxs((WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxsssd((WORD),(WORD),(WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxlsps((WORD),,(WORD),,(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__dxss((WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxg((WORD),)		{register d2,a2; "4e4e";}
#pragma inline d0=__lxv((WORD))		{register d2,a2; "4e4e";}
#pragma inline d0=__mxssssss((WORD),(WORD),(WORD),(WORD),(WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__pxs((WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__pxv((WORD))		{register d2,a2; "4e4e";}
#pragma inline d0=__rxccc((WORD),,,)	{register d2,a2; "4e4e";}
#pragma inline d0=__rxv((WORD))		{register d2,a2; "4e4e";}
#pragma inline d0=__sxppsssss((WORD),,,(WORD),(WORD),(WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxprsssssls((WORD),,,(WORD),(WORD),(WORD),(WORD),(WORD),,(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxs((WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxss((WORD),(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxv((WORD))		{register d2,a2; "4e4e";}
#pragma inline __vxc((WORD),)		{register d2,a2; "4e4e";}
#pragma inline __vxm((WORD),)		{register d2,a2; "4e4e";}
#pragma inline d0=__mxv((WORD))		{register d2,a2; "4e4e";}
#pragma inline __vxp((WORD),)		{register d2,a2; "4e4e";}
#pragma inline d0=__sxp((WORD),)		{register d2,a2; "4e4e";}
#pragma inline __vxplss((WORD),,,(WORD),(WORD))	{register d2,a2; "4e4e";}
#pragma inline __vxpps((WORD),,,(WORD))	{register d2,a2; "4e4e";}
#pragma inline __vxs((WORD),(WORD))		{register d2,a2; "4e4e";}
#pragma inline __vxsf((WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline __vxsl((WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline __vxsp((WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline __vxspf((WORD),(WORD),,)	{register d2,a2; "4e4e";}
#pragma inline __vxsssf((WORD),(WORD),(WORD),(WORD),)	{register d2,a2; "4e4e";}
#pragma inline __vxv((WORD))			{register d2,a2; "4e4e";}
#pragma inline __vxuu((WORD),(UWORD),(UWORD))  	{register d2,a2; "4e4e";}

#define Initmous(a,b,c)		  	__vxspf(0,a,b,c)
#define Ssbrk(a)			  	__lxs(1,a)
#define Physbase()			  	__pxv(2)
#define Logbase()			  	__pxv(3)
#define Getrez()			  	__sxv(4)
#define Setscreen(a,b,c)		  	__vxpps(5,a,b,c)
#define VsetScreen(a,b,c)			__vxppss(0x05,a,b,3,d)
#define Setpallete(a)				__vxp(6,a)
#define Setpalette(a)				__vxp(6,a)
#define Setcolor(a,b)				__sxss(7,a,b)
#define Floprd(a,b,c,d,e,f,g)	  	__sxppsssss(8,a,b,c,d,e,f,g)
#define Flopwr(a,b,c,d,e,f,g)	  	__sxppsssss(9,a,b,c,d,e,f,g)
#define Flopfmt(a,b,c,d,e,f,g,h,i)		__sxprsssssls(10,a,b,c,d,e,f,g,h,i)
#define Midiws(a,b)			  	__vxsp(12,a,b)
#define Mfpint(a,b)			  	__vxsf(13,a,b)
#define Iorec(a)			  	__pxs(14,a)
#define Rsconf(a,b,c,d,e,f)			__mxssssss(15,a,b,c,d,e,f)
#define Keytbl(a,b,c)				__rxccc(16,a,b,c)
#define Random()			  	__lxv(17)
#define Protobt(a,b,c,d)		  	__vxplss(18,a,b,c,d)
#define Flopver(a,b,c,d,e,f,g)		__sxppsssss(19,a,b,c,d,e,f,g)
#define Scrdmp()			  	__vxv(20)
#define Cursconf(a,b)				__sxss(21,a,b)
#define Settime(a)			  	__vxm(22,a)
#define Gettime()			  	__mxv(23)
#define Bioskeys()			  	__vxv(24)
#define Ikbdws(a,b)			  	__vxsl(25,a,b)
#define Jdisint(a)			  	__vxs(26,a)
#define Jenabint(a)			  	__vxs(27,a)
#define Giaccess(a,b)				__dxss(28,a,b)
#define Offgibit(a)			  	__vxs(29,a)
#define Ongibit(a)			  	__vxs(30,a)
#define Xbtimer(a,b,c,d)		  	__vxsssf(31,a,b,c,d)
#define Dosound(a)			  	__vxc(32,a)
#define Setprt(a)			  	__sxs(33,a)
#define Kbdvbase()			  	__rxv(34)
#define Kbrate(a,b)			  	__sxss(35,a,b)
#define Prtblk(a)			  	__sxp(36,a)
#define Vsync()			  	__vxv(37)
#define Supexec(a)			  	__lxg(38,a)
#define Puntaes()			  	__vxv(39)
#define Floprate(a,b)				__sxss(41,a,b)
#define DMAread(a,b,c,d)		  	__lxlsps(42,a,b,c,d)
#define DMAwrite(a,b,c,d)			__lxlsps(43,a,b,c,d)
#define Bconmap(a)			  	__lxs(44,a)
#define NVMaccess(a,b,c,d)			__sxsssd(46,a,b,c,d)
#define WakeTime(a,b)				__vxuu(47,a,b)
#define EsetShift(a)				__sxs(50,a)
#define EgetShift()			  	__sxv(51)
#define EsetBank(a)			  	__sxs(52,a)
#define EsetColor(a,b)		  	__sxss(53,a,b)
#define EsetPalette(a,b,c)			__vxssr(54,a,b,c)
#define EgetPalette(a,b,c)			__vxssr(55,a,b,c)
#define EsetGray(a)			  	__sxs(56,a)
#define EsetSmear(a)				__sxs(57,a)
#define Blitmode(a)			  	__sxs(64,a)
#define VgetMonitor()				__sxv(0x59)
#define VgetRGB(a,b,c)		  	__vxssp(0x5E,a,b,c)
#define VgetSize(a)			  	__lxs(0x5B,a)
#define VsetMask(a,b,c)		  	__vxlls(0x5C,a,b,c)
#define VsetMode(a)			  	__sxs(0x58,a)
#define VsetRGB(a,b,c)		  	__vxssp(0x5D,a,b,c)
#define VsetSync(a)			  	__vxs(0x5A,a)
#define Dsp_DoBlock(a,b,c,d)			__vxclcl(96,a,b,c,d)
#define Dsp_BlkHandShake(a,b,c,d)		__vxclcl(97,a,b,c,d)
#define Dsp_BlkUnpacked(a,b,c,d)		__vxnlnl(98,a,b,c,d)
#define Dsp_InStream(a,b,c,d)	  	__vxclln(99,a,b,c,d)
#define Dsp_OutStream(a,b,c,d)		__vxclln(100,a,b,c,d)
#define Dsp_IOStream(a,b,c,d,e,f)		__vxccllln(101,a,b,c,d,e,f)
#define Dsp_RemoveInterrupts(a)		__vxs(102,a)
#define Dsp_GetWordSize()			__sxv(103)
#define Dsp_Lock()			  	__sxv(104)
#define Dsp_Unlock()				__vxv(105)
#define Dsp_Available(a,b)			__vxnn(106,a,b)
#define Dsp_Reserve(a,b)		  	__sxll(107,a,b)
#define Dsp_LoadProg(a,b,c)			__sxcsc(108,a,b,c)
#define Dsp_ExecProg(a,b,c)			__vxcls(109,a,b,c)
#define Dsp_ExecBoot(a,b,c)			__vxcls(110,a,b,c)
#define Dsp_LodToBinary(a,b)			__lxcc(111,a,b)
#define Dsp_TriggerHC(a)		  	__vxs(112,a)
#define Dsp_RequestUniqueAbility()		__sxv(113)
#define Dsp_GetProgAbility()			__sxv(114)
#define Dsp_FlushSubroutines()		__vxv(115)
#define Dsp_LoadSubroutine(a,b,c)		__sxcls(116,a,b,c)
#define Dsp_InqSubrAbility(a)	  	__sxs(117,a)
#define Dsp_RunSubroutine(a)			__sxs(118,a)
#define Dsp_Hf0(a)			  	__sxs(119,a)
#define Dsp_Hf1(a)			  	__sxs(120,a)
#define Dsp_Hf2()			  	__sxv(121)
#define Dsp_Hf3()			  	__sxv(122)
#define Dsp_BlkWords(a,b,c,d)	  	__vxrlrl(123,a,b,c,d)
#define Dsp_BlkBytes(a,b,c,d)	  	__vxelel(124,a,b,c,d)
#define Dsp_HStat()			  	__dxv(125)
#define Dsp_SetVectors(a,b)			__vxfo(126,a,b)
#define Dsp_MultBlocks(a,b,c,d)		__vxllpp(127,a,b,c,d)
#define Locksnd()			  	__lxv(0x80)
#define Unlocksnd()			  	__lxv(0x81)
#define Soundcmd(a,b)				__lxss(0x82,a,b)
#define Setbuffer(a,b,c)		  	__lxspp(0x83,a,b,c)
#define Setmode(a)			  	__lxs(0x84,a)
#define Settracks(a,b)		  	__lxss(0x85,a,b)
#define Setmontrack(a)		  	__lxs(0x86,a)
#define Setinterrupt(a,b)			__lxss(0x87,a,b)
#define Buffoper(a)			  	__lxs(0x88,a)
#define Dsptristate(a,b)		  	__lxss(0x89,a,b)
#define Gpio(a,b)			  	__lxss(0x8A,a,b)
#define Devconnect(a,b,c,d,e)	  	__lxsssss(0x8B,a,b,c,d,e)
#define Sndstatus(a)				__lxs(0x8C,a)
#define Buffptr(a)			  	__lxp(0x8D,a)

/**************************************************** AES ********/

int __regargs _AESif(unsigned int);

extern VOIDP _AESpb[6];

extern WORD _AEScontrol[5];
extern WORD _AESglobal[15];
extern WORD _AESintin[16];
extern WORD _AESintout[7];
extern VOIDP _AESaddrin[3];
extern VOIDP _AESaddrout[1];

WORD appl_init(void);
WORD appl_read(WORD,WORD,void *);
WORD appl_write(WORD,WORD,void *);
WORD appl_find(const char *);
WORD appl_tplay(EVNTREC *,WORD,WORD);
WORD appl_trecord(EVNTREC *,WORD);
WORD appl_exit(void);
WORD appl_search(WORD,char *,WORD *,WORD *);
WORD appl_getinfo(WORD,WORD *,WORD *,WORD *,WORD *);
WORD evnt_keybd(void);
WORD evnt_button(WORD,WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD evnt_mouse(WORD,WORD,WORD,WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD evnt_mesag(WORD *);
WORD evnt_timer(WORD,WORD);
WORD evnt_multi(WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD *,WORD,WORD,WORD *,WORD *,WORD *,WORD *,WORD *,WORD *);
WORD evnt_dclick(WORD,WORD);
WORD form_do(OBJECT *,WORD);
WORD form_dial(WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD);
WORD form_alert(WORD,const char *);
WORD form_error(WORD);
WORD form_center(OBJECT *,WORD *,WORD *,WORD *,WORD *);
WORD form_keybd(OBJECT *,WORD,WORD,WORD,WORD *,WORD *);
WORD form_button(OBJECT *,WORD,WORD,WORD *);
WORD fsel_input(char *,char *,WORD *);
WORD fsel_exinput(char *,char *,WORD *,const char *);
WORD graf_rubberbox(WORD,WORD,WORD,WORD,WORD *,WORD *);
WORD graf_dragbox(WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD *,WORD *);
WORD graf_movebox(WORD,WORD,WORD,WORD,WORD,WORD);
WORD graf_growbox(WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD);
WORD graf_shrinkbox(WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD);
WORD graf_watchbox(OBJECT *,WORD,WORD,WORD);
WORD graf_slidebox(OBJECT *,WORD,WORD,WORD);
WORD graf_handle(WORD *,WORD *,WORD *,WORD *);
WORD graf_mouse(WORD,void *);
WORD graf_mkstate(WORD *,WORD *,WORD *,WORD *);
WORD menu_bar(OBJECT *, WORD);
WORD menu_icheck(OBJECT *,WORD,WORD);
WORD menu_ienable(OBJECT *,WORD,WORD);
WORD menu_tnormal(OBJECT *,WORD,WORD);
WORD menu_text(OBJECT *,WORD,const char *);
WORD menu_register(WORD,const char *);
WORD menu_popup(MENU *,WORD,WORD,MENU *);
WORD menu_attach(WORD,OBJECT *,WORD,MENU *);
WORD menu_istart(WORD,OBJECT *,WORD,WORD);
WORD menu_settings(WORD,MN_SET *);
WORD objc_add(OBJECT *,WORD,WORD);
WORD objc_delete(OBJECT *,WORD);
WORD objc_draw(OBJECT *,WORD,WORD,WORD,WORD,WORD,WORD);
WORD objc_find(OBJECT *,WORD,WORD,WORD,WORD);
WORD objc_offset(OBJECT *,WORD,WORD *,WORD *);
WORD objc_order(OBJECT *,WORD,WORD);
WORD objc_edit(OBJECT *,WORD,WORD,WORD *,WORD);
WORD objc_change(OBJECT *,WORD,WORD,WORD,WORD,WORD,WORD,WORD,WORD);
WORD objc_sysvar(WORD,WORD,WORD,WORD,WORD *,WORD *);
WORD objc_xywh(OBJECT *,WORD,GRECT *);
void objc_walk(OBJECT *,WORD,WORD,WORD,WORD (*)(OBJECT *,WORD));
/* Rectangle manipulation definitions */
void rc_constrain(const GRECT *,GRECT *);
void rc_copy(const GRECT *,GRECT *);
WORD rc_equal(const GRECT *,const GRECT *);
WORD __builtin_memcmp(const void *, const void *, ULONG);
#define rc_equal(p1,p2)	(!__builtin_memcmp(p1,p2,sizeof(GRECT)))
WORD rc_intersect(const GRECT *,GRECT *);
WORD rc_inside(WORD,WORD,const GRECT *);
void rc_union(const GRECT *,GRECT *);
void rc_center(const GRECT *,GRECT *);
WORD rsrc_load(const char *);
WORD rsrc_free(void);
WORD rsrc_gaddr(WORD,WORD,void *);
WORD rsrc_saddr(WORD,WORD,void *);
WORD rsrc_obfix(OBJECT *,WORD);
WORD rsrc_rcfix(void *);
WORD scrp_read(char *);
WORD scrp_write(const char *);
WORD shel_read(char *,char *);
WORD shel_write(WORD,WORD,WORD,const char *,const char *);
WORD shel_get(char *,WORD);
WORD shel_put(const char *,WORD);
WORD shel_find(char *);
WORD shel_envrn(char **, const char *);
WORD wind_create(WORD,WORD,WORD,WORD,WORD);
WORD wind_open(WORD,WORD,WORD,WORD,WORD);
WORD wind_close(WORD);
WORD wind_delete(WORD);
WORD wind_get(WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD wind_set(WORD,WORD,...);
WORD wind_find(WORD,WORD);
WORD wind_update(WORD);
WORD wind_calc(WORD,WORD,WORD,WORD,WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD wind_new(void);
WORD wind_newdesk(OBJECT *,WORD);
WORD wind_info(WORD,const char *);
WORD wind_title(WORD,const char *);
WORD wind_redraw(WORD,GRECT *,WORD (*)(WORD,GRECT *));

LONG _pack( WORD, WORD );
#pragma	inline	d0=_pack( d0,	d1 )	{ "E188"; "E188"; "0281"; "0000"; "FFFF";	"8081"; }

/********************************************************** VDI *******/

int __regargs _VDIif(ULONG,ULONG);

extern WORD *_VDIpb[5];

extern WORD _VDIcontrl[];	/* default 11	*/
extern WORD _VDIintin[];	/* default 128 */
extern WORD _VDIintout[];	/* default 128 */
extern WORD _VDIptsin[];	/* default 8 */
extern WORD _VDIptsout[];	/* default 10	*/

#ifndef FIX31
typedef LONG fix31;
#endif

void vqt_devinfo(WORD,WORD,WORD *,char *);
void vqt_fontheader(WORD,void *,char *);
void vqt_trackkern(WORD,fix31 *,fix31 *);
void vqt_pairkern(WORD,WORD,WORD,fix31 *,fix31 *);
void vst_charmap(WORD,WORD);
void vst_kern(WORD,WORD,WORD,WORD *,WORD *);
void v_getbitmap_info(WORD,WORD,fix31 *,fix31 *,fix31 *,fix31 *,WORD *,WORD *,void **);
void v_ftext_offset(WORD,WORD,WORD,char *,WORD *);
void v_ftext_offset16(WORD,WORD,WORD,WORD *,WORD,WORD *);
void v_ftext16(WORD,WORD,WORD,WORD *,WORD);
void vqt_f_extent16(WORD,WORD *,WORD,WORD *);
void v_getoutline(WORD,WORD,WORD *,char *,WORD,WORD *);
fix31 vst_arbpt32(WORD,fix31,WORD *,WORD *,WORD *,WORD *);
void vqt_advance32(WORD,WORD,fix31 *,fix31 *);
fix31 vst_setsize32(WORD,fix31,WORD *,WORD *,WORD *,WORD *);
void v_opnwk(WORD *,WORD *,WORD *);
void v_xopnwk(WORD *,WORD *,WORD *,WORD,WORD,void **);	/* GDOS extended version */
void v_clswk(WORD);
void v_updwk(WORD);
void v_xupdwk(WORD,void **,WORD,WORD *);			/* GDOS extended version */
WORD vst_load_fonts(WORD,WORD);
void vst_unload_fonts(WORD,WORD);
WORD v_bez_con(WORD,WORD);
void v_bez_qual(WORD,WORD,WORD *);
void v_set_app_buff(void *,WORD);
WORD v_flushcache(WORD);
WORD v_loadcache(WORD,const char *,WORD);
WORD v_savecache(WORD,const char *);
void vst_scratch(WORD,WORD);
void vst_error(WORD,WORD,WORD *);
#define v_bez_on(x)	v_bez_con(x, 1)
#define v_bez_off(x)	((void)v_bez_con(x, 0))
void v_ftext(WORD,WORD,WORD,const char *);
void v_bez(WORD,WORD,const WORD *,const char *,WORD *,WORD *,WORD *);
void v_bez_fill(WORD,WORD,const WORD *,const char *,WORD *,WORD *,WORD *);
void v_bez(WORD,WORD,const WORD *,const char *,WORD *,WORD *,WORD *);
void v_bez_fill(WORD,WORD,const WORD *,const char *,WORD *,WORD *,WORD *);
void v_meta_extents(WORD,WORD,WORD,WORD,WORD);
void v_write_meta(WORD,WORD,WORD *,WORD,WORD *);
void vm_filename(WORD,const char *);
void v_pgcount(WORD,WORD);
void vm_pagesize(WORD,WORD,WORD);
void vm_coords(WORD,WORD,WORD,WORD,WORD);
WORD vq_gdos(void);
ULONG vq_vgdos(void);
#pragma inline d0=vq_vgdos()	{register d2,a2; "70fe4e42";}
#ifdef _SHORTINT
#pragma inline d0=vq_gdos()	{register d2,a2; "70fe4e42548056c0";}
#else
#pragma inline d0=vq_gdos()	{register d2,a2; "70fe4e425480";}
#endif
void v_opnvwk(WORD *,WORD *,WORD *);
void v_clsvwk(WORD);
void v_clrwk(WORD);
void vs_clip(WORD,WORD,WORD *);
void v_pline(WORD,WORD,WORD *);
void v_pmarker(WORD,WORD,WORD *);
void v_gtext(WORD,WORD,WORD,const char *);
void v_fillarea(WORD,WORD,WORD *);
void v_cellarray(WORD,WORD *,WORD,WORD,WORD,WORD,WORD *);
void v_contourfill(WORD,WORD,WORD,WORD);
void vr_recfl(WORD,WORD *);
void v_bar(WORD,WORD *);
void v_arc(WORD,WORD,WORD,WORD,WORD,WORD);
void v_pieslice(WORD,WORD,WORD,WORD,WORD,WORD);
void v_circle(WORD,WORD,WORD,WORD);
void v_ellarc(WORD,WORD,WORD,WORD,WORD,WORD,WORD);
void v_ellpie(WORD,WORD,WORD,WORD,WORD,WORD,WORD);
void v_ellipse(WORD,WORD,WORD,WORD,WORD);
void v_rbox(WORD,WORD *);
void v_rfbox(WORD,WORD *);
void v_justified(WORD,WORD,WORD,const char *,WORD,WORD,WORD);
WORD vswr_mode(WORD,WORD);
void vs_color(WORD,WORD,const WORD *);
WORD vsl_type(WORD,WORD);
void vsl_udsty(WORD,WORD);
WORD vsl_width(WORD,WORD);
WORD vsl_color(WORD,WORD);
void vsl_ends(WORD,WORD,WORD);
WORD vsm_type(WORD,WORD);
WORD vsm_height(WORD,WORD);
WORD vsm_color(WORD,WORD);
void vst_height(WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD vst_point(WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD vst_rotation(WORD,WORD);
WORD vst_font(WORD,WORD);
WORD vst_color(WORD,WORD);
WORD vst_effects(WORD,WORD);
void vst_alignment(WORD,WORD,WORD,WORD *,WORD *);
WORD vsf_interior(WORD,WORD);
WORD vsf_style(WORD,WORD);
WORD vsf_color(WORD,WORD);
WORD vsf_perimeter(WORD,WORD);
void vsf_udpat(WORD,WORD *,WORD);
WORD vst_arbpt(WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD vst_setsize(WORD,WORD,WORD *,WORD *,WORD *,WORD *);
WORD vst_skew(WORD,WORD);
void vro_cpyfm(WORD,WORD,WORD *,MFDB *,MFDB *);
void vrt_cpyfm(WORD,WORD,WORD *,MFDB *,MFDB *,WORD *);
void vr_trnfm(WORD,MFDB *,MFDB *);
void v_get_pixel(WORD,WORD,WORD,WORD *,WORD *);
WORD vsin_mode(WORD,WORD,WORD);
void vrq_locator(WORD,WORD,WORD,WORD *,WORD *,WORD *);
WORD vsm_locator(WORD,WORD,WORD,WORD *,WORD *,WORD *);
void vrq_valuator(WORD,WORD,WORD *,WORD *);
void vsm_valuator(WORD,WORD,WORD *,WORD *,WORD *);
void vrq_choice(WORD,WORD,WORD *);
WORD vsm_choice(WORD,WORD *);
void vrq_string(WORD,WORD,WORD,WORD *,char *);
WORD vsm_string(WORD,WORD,WORD,WORD *,char *);
void vsc_form(WORD,MFORM *);
void vex_timv(WORD,WORD (*)(void),WORD (**)(void),WORD *);
void v_show_c(WORD,WORD);
void v_hide_c(WORD);
void vq_mouse(WORD,WORD *,WORD *,WORD *);
void vex_butv(WORD,WORD __regargs (*)(WORD),WORD __regargs (**)(WORD));
void vex_motv(WORD,WORD __regargs (*)(WORD,WORD),WORD __regargs (**)(WORD,WORD));
void vex_curv(WORD,WORD __regargs (*)(WORD,WORD),WORD __regargs (**)(WORD,WORD));
void vq_key_s(WORD,WORD *);
void vq_extnd(WORD,WORD,WORD *);
void vq_xextnd(WORD,WORD,WORD *,WORD,WORD);	/* GDOS extended version */
void vq_color(WORD,WORD,WORD,WORD *);
void vql_attributes(WORD,WORD *);
void vqm_attributes(WORD,WORD *);
void vqf_attributes(WORD,WORD *);
void vqt_attributes(WORD,WORD *);
void vqt_extent(WORD,const char *,WORD[8]);
void vqt_f_extent(WORD, const char *, WORD[8]);
WORD vqt_width(WORD,WORD,WORD *,WORD *,WORD *);
WORD vqt_name(WORD,WORD,char *);
WORD vqt_f_name(WORD,WORD,char *,WORD *);
void vq_cellarray(WORD,WORD *,WORD,WORD,WORD *,WORD *,WORD *,WORD *);
void vqin_mode(WORD,WORD,WORD *);
void vqt_fontinfo(WORD,WORD *,WORD *,WORD *,WORD *,WORD *);
void vqt_advance(WORD,WORD,WORD *,WORD *,WORD *,WORD *);
void vq_chcells(WORD,WORD *,WORD *);
void v_exit_cur(WORD);
void v_enter_cur(WORD);
void v_curup(WORD);
void v_curdown(WORD);
void v_curright(WORD);
void v_curleft(WORD);
void v_curhome(WORD);
void v_eeos(WORD);
void v_eeol(WORD);
void vs_curaddress(WORD,WORD,WORD);
void v_curtext(WORD,const char *);
void v_rvon(WORD);
void v_rvoff(WORD);
void vq_curaddress(WORD,WORD *,WORD *);
WORD vq_tabstatus(WORD);
void v_hardcopy(WORD);
void v_dspcur(WORD,WORD,WORD);
void v_rmcur(WORD);
void v_form_adv(WORD);
void v_output_window(WORD,WORD *);
void v_clear_disp_list(WORD);
void v_bit_image(WORD,const char *,WORD,WORD,WORD,WORD,WORD,WORD *);
void vq_scan(WORD,WORD *,WORD *,WORD *,WORD *,WORD *);
void v_alpha_text(WORD,const char *);
WORD vs_palette(WORD,WORD);
void vqp_films(WORD,char *);
void vqp_state(WORD,WORD *,WORD *,WORD *,WORD *,WORD *,WORD *);
void vsp_state(WORD,WORD,WORD,WORD,WORD,WORD,const WORD *);
void vsp_save(WORD);
void vsp_message(WORD);
WORD vqp_error(WORD);
void v_offset(WORD,WORD);
void v_font(WORD,void *);

/******************************************************** VDIWORK ***/

#define VDIWORK 0
#if (VDIWORK)
WORD OpenVwork( VDI_Workstation * );
WORD OpenWork( WORD, VDI_Workstation * );
#endif
#endif
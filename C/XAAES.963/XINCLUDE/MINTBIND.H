#ifndef _MINTBIND_H
#define _MINTBIND_H

#ifndef _OSBIND_H
#include <osbind.h>
#endif

begin_decls

#ifdef __TURBOC__

/* we supply a library of bindings for TurboC / PureC */

int Syield( void );				/* GEMDOS 0xff */
int Fpipe( short *ptr );			/* GEMDOS 0x100 */
long Fcntl( int f, long arg, int cmd);		/* GEMDOS 0x104 */
long Finstat( int f );				/* GEMDOS 0x105 */
long Foutstat( int f );				/* GEMDOS 0x106 */
long Fgetchar(int f, int mode);			/* GEMDOS 0x107 */
long Fputchar( int f, long c, int mode ); 	/* GEMDOS 0x108 */
long Pwait( void );				/* GEMDOS 0x109 */
int Pnice( int delta );				/* GEMDOS 0x10a */
int Pgetpid( void );				/* GEMDOS 0x10b */
int Pgetppid( void );				/* GEMDOS 0x10c */
int Pgetpgrp( void );				/* GEMDOS 0x10d */
int Psetpgrp(int pid, int newgrp);		/* GEMDOS 0x10e */
int Pgetuid( void );				/* GEMDOS 0x10f */
int Psetuid( int id );				/* GEMDOS 0x110 */
int Pkill( int pid, int sig );			/* GEMDOS 0x111 */
/* HR: Sigh! The binding expects the pointer in d0. Shit, shit, shit!
   I get so tired by this kind of things. */
long Psignal(int sig, long handler);		/* GEMDOS 0x112 */
long Pvfork( void );				/* GEMDOS 0x113 */
int Pgetgid( void );				/* GEMDOS 0x114 */
int Psetgid(int id);				/* GEMDOS 0x115 */
long Psigblock(unsigned long mask);		/* GEMDOS 0x116 */
long Psigsetmask(unsigned long mask);		/* GEMDOS 0x117 */
long Pusrval(long arg);				/* GEMDOS 0x118 */
int Pdomain(int newdom);			/* GEMDOS 0x119 */
void Psigreturn( void );			/* GEMDOS 0x11a */
long Pfork( void );				/* GEMDOS 0x11b */
long Pwait3(int flag, long *rusage);		/* GEMDOS 0x11c */
int Fselect(unsigned int timeout, long *rfds, long *wfds, long *xfds); /* GEMDOS 0x11d */
int Prusage( long r[8] );			/* GEMDOS 0x11e */
long Psetlimit(int lim, long value);		/* GEMDOS 0x11f */
long Talarm( long secs );			/* GEMDOS 0x120 */
void Pause( void );				/* GEMDOS 0x121 */
long Sysconf( int n );				/* GEMDOS 0x122 */
long Psigpending( void );			/* GEMDOS 0x123 */
long Dpathconf( const char *name, int n );	/* GEMDOS 0x124 */
long Pmsg( int mode, long mbox, void *msg ); 	/* GEMDOS 0x125 */
long Fmidipipe( int pid, int in, int out );	/* GEMDOS 0x126 */
int Prenice( int pid, int delta );		/* GEMDOS 0x127 */
long Dopendir( const char *name, int flag );	/* GEMDOS 0x128 */
long Dreaddir( int buflen, long dir, char *buf); /*GEMDOS 0x129 */
long Drewinddir( long dir );			/* GEMDOS 0x12a */
long Dclosedir( long dir );			/* GEMDOS 0x12b */
long Fxattr( int flag, char *name, void *buf );	/* GEMDOS 0x12c */
long Flink( char *oldname, char *newname );	/* GEMDOS 0x12d */
long Fsymlink( char *oldname, char *newname );	/* GEMDOS 0x12e */
long Freadlink( int siz, char *buf, char *name); /*GEMDOS 0x12f */
long Dcntl( int cmd, char *name, long arg );	/* GEMDOS 0x130 */
long Fchown( char *name, int uid, int gid);	/* GEMDOS 0x131 */
long Fchmod( char *name, int mode );		/* GEMDOS 0x132 */
int Pumask( int mask );				/* GEMDOS 0x133 */
long Psemaphore(int mode, long id, long timeout); /* GEMDOS 0x134 */
int Dlock( int mode, int drive );		/* GEMDOS 0x135 */
void Psigpause( unsigned long mask);		/* GEMDOS 0x136 */
long Psigaction(int sig, long act, long oact);	/* GEMDOS 0x137 */
int Pgeteuid( void );				/* GEMDOS 0x138 */
int Pgetegid( void );				/* GEMDOS 0x139 */
long Pwaitpid(int pid, int flag, long *rusage);	/* GEMDOS 0x13a */
long Dgetcwd(char *path, int drv, int size);	/* GEMDOS 0x13b */
long Salert(char *msg);				/* GEMDOS 0x13c */

/* The following are not yet official... */
long Tmalarm( long secs );			/* GEMDOS 0x13d */
long Psigintr( short vec, short sig);		/* GEMDOS 0x13e */
long Suptime( long *uptime, long *avenrun);		/* GEMDOS 0x13f */
long Pvalidate(short pid, void *address, long length, long *flags);	/* GEMDOS 0x141 */
long Dxreaddir( short len, long handle, char * buf, long xattr, long *xret );	/* GEMDOS 0x142 */
short Dseteuid( short id );			/* GEMDOS 0x143 */
short Dsetegid( short id );			/* GEMDOS 0x144 */
short Dsetauid( short id );			/* GEMDOS 0x145 */
short Dgetauid( short id );			/* GEMDOS 0x146 */
long Pgetgroups( short gidsetlen, _GID_T *gidset );	/* GEMDOS 0x147 */
long Psetgroups( short gidsetlen, _GID_T *gidset );	/* GEMDOS 0x148 */
long Tsetitimer( short which, long *interval, long *value, long *ointerval, long *ovalue );	/* GEMDOS 0x149 */
short Psetreuid( short rid, short eid );	/* GEMDOS 0x14e */
short Psetregid( short rid, short eid );	/* GEMDOS 0x14f */
long Sync( void );				/* GEMDOS 0x150 */
void Shutdown( long restart );			/* GEMDOS 0x151 */
char *Dreadlabel( char *path, char *label, short maxlen );		/* GEMDOS 0x152 */
char *Dwritelabel( char *path, char *label);		/* GEMDOS 0x153 */
long Ssystem(short mode, long arg1, long arg2);    /* GEMDOS 0x154 */
long Tgettimeofday(long tvp, long tzp);            /* GEMDOS 0x155 */
long Tsettimeofday(long tvp, long tzp);            /* GEMDOS 0x156 */
long Pgetpriority(short which, short who);         /* GEMDOS 0x158 */
long Psetpriority(short which, short who, short pri);          /* GEMDOS 0x159 */

#else /* !__TURBOC__ */

#ifdef __LATTICE__

void _vmv(int);
short _smv(int);
int _imv(int);
long _lmv(int);

int _im8(int,long[8]);
void _vml(int,long);
short _sms(int,int);
short _smr(int,short *);
long _lms(int,int);
long _lml(int,long);
long _lmu(int,unsigned long);
long _lmp(int,void *);
long _lmC(int,const char *);

void _vmls(int,long,int);
short _smss(int,int,int);
short _smsl(int,int,long);
short _smls(int,long,int);

long _lmss(int,int,int);
long _lmsl(int,int,long);
long _lmsp(int,int,void *);
long _lmps(int,void *,int);
long _lmCs(int,const char *,short);
long _lmpp(int,void *,void *);
long _lmCC(int,const char *,const char *);

short _smsls(int,int,long,int);
int _imssq(int,int,int,long *);
long _lmsss(int,int,int,int);
long _lmsls(int,int,long,int);
long _lmsll(int,int,int,long);
long _lmslp(int,int,long,void *);
long _lmspl(int,int,void *,long);
long _lmsCl(int,int,const char *,long);
long _lmspp(int,int,void *,void *);
long _lmspC(int,int,void *,const char *);
long _lmlss(int,long,int,int);
long _lmCss(int,const char *,int,int);
long _lmcss(int,char *,int,int);
short _smsqqq(int,int,long *,long *,long *);

#pragma inline _vmv((short))	{register d2,a2; "4e41";}
#pragma inline d0=_smv((short))	{register d2,a2; "4e41";}
#pragma inline d0=_imv((short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmv((short))	{register d2,a2; "4e41";}

#pragma inline d0=_im8((short),)	{register d2,a2; "4e41";}
#pragma inline _vml((short),)	{register d2,a2; "4e41";}
#pragma inline d0=_sms((short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_smr((short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lms((short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lml((short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lmu((short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lmp((short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lmC((short),)	{register d2,a2; "4e41";}

#pragma inline _vmls((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=_smss((short),(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_smsl((short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=_smls((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmss((short),(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmsl((short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lmsp((short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lmps((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmCs((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmpp((short),,)	{register d2,a2; "4e41";}
#pragma inline d0=_lmCC((short),,)	{register d2,a2; "4e41";}

#pragma inline d0=_smsls((short),(short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=_imssq((short),(short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lmsss((short),(short),(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmsls((short),(short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmsll((short),(short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=_lmlss((short),,(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmslp((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=_lmspl((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=_lmsCl((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=_lmspp((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=_lmspC((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=_lmlss((short),,(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmCss((short),,(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_lmcss((short),,(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=_smsqqq((short),(short),,,)	{register d2,a2; "4e41";}

#define Syield() _smv(0xff)
#define Fpipe(a) _smr(0x100, a)
#define Fcntl(a, b, c) _smsls(0x104, a, (long)b, c)
#define Finstat(a) _lms(0x105, a)
#define Foutstat(a) _lms(0x106, a)
#define Fgetchar(a, b) _lmss(0x107, a, b)
#define Fputchar(a, b, c) _lmsls(0x108, a, b, c)
#define Pwait() _lmv(0x109)
#define Pnice(a) _sms(0x10a, a)
#define Pgetpid() _smv(0x10b)
#define Pgetppid() _smv(0x10c)
#define Pgetpgrp() _smv(0x10d)
#define Psetpgrp(a, b) _smss(0x10e, a, b)
#define Pgetuid() _smv(0x10f)
#define Psetuid(a) _sms(0x110, a)
#define Pkill(a, b) _smss(0x111, a, b)
#define Psignal(a, b) _lmsl(0x112, a, b)
#define Pvfork() _smv(0x113)
#define Pgetgid() _smv(0x114)
#define Psetgid(a) _sms(0x115, a)
#define Psigblock(a) _lmu(0x116, a)
#define Psigsetmask(a) _lmu(0x117, a)
#define Pusrval(a) _lml(0x118, a)
#define Pdomain(a) _sms(0x119, a)
#define Psigreturn() _vmv(0x11a)
#define Pfork() _lmv(0x11b)
#define Pwait3(a, b) _lmsp(0x11c, a, b)
#define Fselect(a, b, c, d) _smsqqq(0x11d, a, b, c, d)
#define Prusage(a) _im8(0x11e, a)
#define Psetlimit(a, b) _lmsl(0x11f, a, b)
#define Talarm(a) _lml(0x120, a)
#define Pause() _vmv(0x121)
#define Sysconf(a) _lms(0x122, a)
#define Psigpending() _lmv(0x123)
#define Dpathconf(a, b) _lmCs(0x124, a, b)
#define Pmsg(a, b, c) _lmslp(0x125, a, b, c)
#define Fmidipipe(a, b, c) _lmsss(0x126, a, b, c)
#define Prenice(a, b) _smss(0x127, a, b)
#define Dopendir(a, b) _lmps(0x128, a, b)
#define Dreaddir(a, b, c) _lmslp(0x129, a, b, c)
#define Drewinddir(a) _lml(0x12a, a)
#define Dclosedir(a) _lml(0x12b, a)
#define Fxattr(a, b, c) _lmspp(0x12c, a, b, c)
#define Flink(a, b) _lmCC(0x12d, a, b)
#define Fsymlink(a, b) _lmCC(0x12e, a, b)
#define Freadlink(a, b, c) _lmspC(0x12f, a, b, c)
#define Dcntl(a, b, c) _lmsCl(0x130, a, b, (long)c)
#define Fchown(a, b, c) _lmCss(0x131, a, b, c)
#define Fchmod(a, b) _lmCs(0x132, a, b)
#define Pumask(a) _sms(0x133, a)
#define Psemaphore(a, b, c) _lmsll(0x134, a, b, c)
#define Dlock(a, b) _smss(0x135, a, b)
#define Psigpause(a) _vml(0x136,a)
#define Psigaction(a, b, c) _lmsll(0x137, a, (long)b, (long)c)
#define Pgeteuid() _imv(0x138)
#define Pgetegid() _imv(0x139)
#define Pwaitpid(a, b, c) _imssq(0x13a, a, b, c)
#define Dgetcwd(a, b, c) _lmcss(0x13b, a, b, c)
#define Salert(a) _lmC(0x13c, a)

#else /* !__LATTICE__ */

#ifdef __GNUC_INLINE__

/* see osbind.h for __extension__ and AND_MEMORY */

#define trap_1_wwlw(n, a, b, c)						\
__extension__								\
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
		lea	sp@(10),sp " \
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
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
	("\
		movw    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addqw    #8,sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
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
	("\
		movl    %4,sp@-; \
		movw    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		lea     sp@(10),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)     /* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
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
	("\
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addqw    #8,sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b)		/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})

#if __GNUC__ > 1
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
	("\
		movl    %6,sp@-; \
		movl    %5,sp@-; \
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movw    %2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		lea     sp@(20),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e) /* inputs  */ \
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})
#else
#define trap_1_wwllll(n, a, b, c, d, e)					\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);			\
	long  _b = (long) (b);			\
	long  _c = (long) (c);			\
	long  _d = (long) (d);			\
	long  _e = (long) (e);			\
	    								\
	__asm__ volatile						\
	("\
		movl    %4,sp@-; \
		movl    %3,sp@-; \
		movl    %2,sp@-; \
		movl    %1,sp@-; \
		movw    %0,sp@-	"					\
	:					      /* outputs */	\
	: "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e) /* inputs  */	\
	);								\
									\
	__asm__ volatile						\
	("\
		movw    %1,sp@-; \
		trap    #1;	\
		lea     sp@(20),sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n)				/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	);								\
	retvalue;							\
})
#endif

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
# define trap_1_wwwl(n,a,b,c)	gemdos(n, a, b, (long)(c))
# define trap_1_wwllll(n, a, b, c, d, e) \
		gemdos(n, a, (long)(b), (long)(c), (long)(d), (long)(e))
#endif /* __LONG_TRAPS__ */

#endif /* __GNUC_INLINE__ */

#define	Syield()						\
		(int)trap_1_w(0xff)
#define Fpipe(ptr)						\
		(int)trap_1_wl(0x100, (long)(ptr))
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
#define Mvalidate(pid,addr,size)  \
        trap_1_wwll(0x141, (short)(pid), (long)(addr), (long)(size))
#define Dxreaddir(len, handle, buf, xattr, xret)		\
		trap_1_wwllll(0x142, (short)(len), (long)(handle), \
			      (long)(buf), (long)(xattr), (long)(xret))
#define Pseteuid(id)						\
		(int)trap_1_ww(0x143, (short)(id))
#define Psetegid(id)						\
		(int)trap_1_ww(0x144, (short)(id))
#define Psetauid(id)						\
		(int)trap_1_ww(0x145, (short)(id))
#define Pgetauid()						\
		(int)trap_1_w(0x146)
#define Pgetgroups(gidsetlen, gidset)				\
		trap_1_wwl(0x147, (short)(gidsetlen), (long)(gidset))
#define Psetgroups(gidsetlen, gidset)				\
		trap_1_wwl(0x148, (short)(gidsetlen), (long)(gidset))
#define Tsetitimer(which, interval, value, ointerval, ovalue)	\
		trap_1_wwllll(0x149, (short)(which), (long)(interval), \
			      (long)(value), (long)(ointerval), (long)(ovalue))
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
		trap_1_wwll(0x154, (int)(mode), (long)(arg1), (long)(arg2))
#define Tgettimeofday(tvp, tzp) \
		trap_1_wll(0x155, (long)(tvp), (long)(tzp))
#define Tsettimeofday(tvp, tzp) \
		trap_1_wll(0x156, (long)(tvp), (long)(tzp))
#define Pgetpriority(which, who) \
		trap_1_www(0x158, (short)(which), (short)(who))
#define Psetpriority(which, who, prio) \
		trap_1_wwww(0x159, (short)(which), (short)(who), (short)(prio))

#endif /* __LATTICE__ */
#endif /* __TURBOC__ */

end_decls

#endif /* _MINTBIND_H */


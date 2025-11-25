#ifndef _MINTBIND_H
#define _MINTBIND_H

/*
 *  mintbind.h, short version, contains PureC headers only
 */

#ifndef __TURBOC__
#error "mintbind.h: Pure C version"
#endif

#ifndef __TOS
#include <tos.h>
#endif

int Syield( void );				/* GEMDOS 0xff */
int Fpipe( short *ptr );			/* GEMDOS 0x100 */
long Fcntl( int f, long arg, int cmd);		/* GEMDOS 0x104 */
#define Fcntl(f, arg, cmd) Fcntl(f, (long)(arg), cmd)
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
#define Dreaddir(buflen, dir, buf) Dreaddir(buflen, (long)(dir), buf)
long Drewinddir( long dir );			/* GEMDOS 0x12a */
#define Drewinddir(dir) Drewinddir((long)(dir))
long Dclosedir( long dir );			/* GEMDOS 0x12b */
#define Dclosedir(dir) Dclosedir((long)(dir))
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
#define Psigaction(sig, act, oact) \
	Psigaction(sig, (long)(act), (long)(oact))
int Pgeteuid( void );				/* GEMDOS 0x138 */
int Pgetegid( void );				/* GEMDOS 0x139 */
int Pwaitpid(int pid, int flag, long *rusage);	/* GEMDOS 0x13a */
long Dgetcwd(char *path, int drv, int size);	/* GEMDOS 0x13b */
long Salert(char *msg);				/* GEMDOS 0x13c */

#endif

/*
 * PS-Control
 * MINTBIND.H
 * September 1992 by Richard Kurz
 * fÅr's TOS-Magazin
 */

#if !defined( _MINTBIND_H )
#define _MINTBIND_H

#if !defined( __TOS )
#include <tos.h>
#endif

/* Die zusÑtzlichen MiNT-Befehle */

long 	Dclosedir(long dirh);
long 	Dcntl(int cmd,char *name,long arg);
int 	Dlock(int mode,int drv);
long 	Dopendir(char *name,int flag);
long 	Dpathconf(char *name,int mode);
long 	Dreaddir(int len,long dirh,char *buf);
long 	Drewinddir(long dirh);
long 	Fchmod(char *name,int mode);
long 	Fchown(char *name,int uid,int gid);
long 	Fcntl(int fh,long arg,int cmd);
long 	Fgetchar(int fh,int mode);
long 	Finstat(int fh);
long 	Flink(char *oldname,char *newname);
long 	Fmidipipe(int pid,int in,int out);
long 	Foutstat(int fh);
int 	Fpipe(int *ushr);
long 	Fputchar(int fh,long ch,int mode);
long 	Freadlink(int len,char *buf,char *name);
int 	Fselect(int timeout,long *rfds,long *wfds,long *xfds);
long 	Fsymlink(char *oldname,char *newname);
long 	Fxattr(int flag,char *name,void *xattr) ;
void 	Pause(void);
int 	Pdomain(int dom);
long 	Pfork(void);
int 	Pgetgid(void);
int 	Pgetpgrp(void);
int 	Pgetpid(void);
int 	Pgetppid(void);
int 	Pgetuid(void);
int 	Pkill(int pid,int sig);
long 	Pmsg(int mode,long mboxid,void *msg);
int 	Pnice(int delta);
int 	Prenice(int pid,int delta);
int 	Prusage(long *r);
long 	Psemaphore(int mode,long id,long timeout);
int 	Psetgid(int id);
long 	Psetlimit(int lim,long value);
int 	Psetpgrp(int pid,int newgrp);
int 	Psetuid(int uid);
long 	Psigaction(int sig,long act,long oact);
long 	Psigblock(unsigned long mask);
long 	Psignal(int sig,long handler);
void 	Psigpause(unsigned long mask);
long 	Psigpending(void);
void 	Psigreturn(void);
long 	Psigsetmask(unsigned long mask);
int 	Pumask(int mask);
long 	Pusrval(long arg);
long 	Pvfork(void);
long 	Pwait(void);
long 	Pwait3(int flag,long *rusage);
int		Syield(void);
long 	Sysconf(int n);
long 	Talarm(long time);

/* MiNT Signale */

#define SIGKILL     9
#define SIGTERM     15
#define SIGSTOP     17
#define SIGTSTP     18
#define SIGCONT     19

/* MiNT Fehlermeldungen */

/* BIOS Fehler */
#define ERROR   -1      /* allgemeiner Fehler */
#define EDRVNR  -2      /* Laufwerk nicht bereit */
#define EUNCMD  -3      /* unbekanntes Kommando */
#define E_CRC   -4      /* CRCFehler */
#define EBADRQ  -5      /* falscher Zugriff */
#define E_SEEK  -6      /* seek Fehler */
#define EMEDIA  -7      /* unbekanntes Medium */
#define ESECNF  -8      /* Sector nicht gefunden */
#define EPAPER  -9      /* kein Papier mehr */
#define EWRITF  -10     /* Fehler beim Schreiben */
#define EREADF  -11     /* Fehler beim Lesen */

#define EWRPRO  -13     /* Laufwerk ist schreibgeschÅtzt */
#define E_CHNG  -14     /* Medium wurde gewechselt */
#define EUNDEV  -15     /* unbekannter Device */
#define EBADSF  -16     /* schlechter Sektor beim Formatieren */
#define EOTHER  -17     /* andere Diskette einlegen */

/* GEMDOS Fehler */
#define EINVFN  -32
#define EFILNF  -33
#define EPTHNF  -34
#define ENHNDL  -35
#define EACCDN  -36
#define EIHNDL  -37
#define ENSMEM  -39
#define EIMBA   -40
#define EDRIVE  -46
#define EXDEV   -48     
#define ENMFIL  -49
#define ELOCKED -58
#define ENSLOCK -59
#define ERANGE  -64
#define EINTRN  -65
#define EPLFMT  -66
#define ENOEXEC EPLFMT
#define EGSBF   -67
#define ENAMETOOLONG ERANGE
#define ELOOP -80
#define EMOUNT  -200

/* Struktur fÅr Fxattr */

typedef struct xattr
{
    unsigned int    mode;
    long            index;
    unsigned int    dev;
    unsigned int    reserved1;
    unsigned int    nlink;
    unsigned int    uid;
    unsigned int    gid;
    long            size;
    long            blksize, nblocks;
    int             mtime, mdate;
    int             atime, adate;
    int             ctime, cdate;
    int             attr;
    int             reserved2;
    long            reserved3[2];
} XATTR;

#define PPROCADDR   (('P'<< 8) | 1)
#define PBASEADDR   (('P'<< 8) | 2)
#define PCTXTSIZE   (('P'<< 8) | 3)

#endif /* _MINTBIND_H */

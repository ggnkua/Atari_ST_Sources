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

#define Syield()                    gemdos(0xff)
#define Fpipe(ptr)                  gemdos(0x100, (long)(ptr))
#define Fcntl(f, arg, cmd)          gemdos(0x104, (int)(f), (long)(arg), (int)(cmd))
#define Finstat(f)                  gemdos(0x105, (int)(f))
#define Foutstat(f)                 gemdos(0x106, (int)(f))
#define Fgetchar(f, mode)           gemdos(0x107, (int)(f), (int)(mode))
#define Fputchar(f, ch, mode)       gemdos(0x108, (int)(f), (long)(ch), (int)(mode))

#define Pwait()                     gemdos(0x109)
#define Pnice(delta)                gemdos(0x10a, (int)(delta))
#define Pgetpid()                   gemdos(0x10b)
#define Pgetppid()                  gemdos(0x10c)
#define Pgetpgrp()                  gemdos(0x10d)
#define Psetpgrp(pid, grp)          gemdos(0x10e, (int)(pid), (int)(grp))
#define Pgetuid()                   gemdos(0x10f)
#define Psetuid(id)                 gemdos(0x110, (int)(id))
#define Pkill(pid, sig)             gemdos(0x111, (int)(pid), (int)(sig))
#define Psignal(sig, handler)       gemdos(0x112, (int)(sig), (long)(handler))
#define Pvfork()                    gemdos(0x113)
#define Pgetgid()                   gemdos(0x114)
#define Psetgid(id)                 gemdos(0x115, (int)(id))
#define Psigblock(mask)             gemdos(0x116, (unsigned long)(mask))
#define Psigsetmask(mask)           gemdos(0x117, (unsigned long)(mask))
#define Pusrval(arg)                gemdos(0x118, (long)(arg))
#define Pdomain(arg)                gemdos(0x119, (int)(arg))
#define Psigreturn()                gemdos(0x11a)
#define Pfork()                     gemdos(0x11b)
#define Pwait3(flag, rusage)        gemdos(0x11c, (int)(flag), (long)(rusage))
#define Fselect(time, rfd, wfd, xfd)gemdos(0x11d, (unsigned int)(time), (long)(rfd),(long)(wfd), (long)(xfd))
#define Prusage(rsp)                gemdos(0x11e, (long)(rsp))
#define Psetlimit(i, val)           gemdos(0x11f, (int)(i), (long)(val))

#define Talarm(sec)                 gemdos(0x120, (long)(sec))
#define Pause()                     gemdos(0x121);
#define Sysconf(n)                  gemdos(0x122, (int)(n))
#define Psigpending()               gemdos(0x123)
#define Dpathconf(name, which)      gemdos(0x124, (long)(name), (int)(which))

#define Pmsg(mode, mbox, msg)       gemdos(0x125, (int)(mode), (long)(mbox), (long)(msg))
#define Fmidipipe(pid, in, out)     gemdos(0x126, (int)(pid), (int)(in),(int)(out))
#define Prenice(pid, delta)         gemdos(0x127, (int)(pid), (int)(delta))
#define Dopendir(name, flag)        gemdos(0x128, (long)(name), (int)(flag))
#define Dreaddir(len, handle, buf)  gemdos(0x129, (int)(len), (long)(handle), (long)(buf))
#define Drewinddir(handle)          gemdos(0x12a, (long)(handle))
#define Dclosedir(handle)           gemdos(0x12b, (long)(handle))
#define Fxattr(flag, name, buf)     gemdos(0x12c, (int)(flag), (long)(name), (long)(buf))
#define Flink(old, new)             gemdos(0x12d, (long)(old), (long)(new))
#define Fsymlink(old, new)          gemdos(0x12e, (long)(old), (long)(new))
#define Freadlink(siz, buf, linknm) gemdos(0x12f, (int)(siz), (long)(buf), (long)(linknm))
#define Dcntl(cmd, name, arg)       gemdos(0x130, (int)(cmd), (long)(name), (long)(arg))
#define Fchown(name, uid, gid)      gemdos(0x131, (long)(name), (int)(uid), (int)(gid))
#define Fchmod(name, mode)          gemdos(0x132, (long)(name), (int)(mode))
#define Pumask(mask)                gemdos(0x133, (int)(mask))
#define Psemaphore(mode, id, tmout) gemdos(0x134, (int)(mode), (long)(id), (long)(tmout))
#define Dlock(mode, drive)          gemdos(0x135, (int)(mode), (int)(drive))
/* Erst ab MiNT 0.95 */
#define Psigpause(mask)				(int)gemdos(0x136, (unsigned long)(mask))
#define Psigaction(sig, act, oact)	gemdos(0x137, (int)(sig), (long)(act), (long)(oact))
#define Pgeteuid()					(int)gemdos(0x138)
#define Pgetegid()					(int)gemdos(0x139)

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

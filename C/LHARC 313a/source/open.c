/* based upon Dale Schumacher's dLibs library */
/* extensively modified by ers */

#include <compiler.h>
#include <osbind.h>
#include <mintbind.h>
#include <limits.h>
#include <fcntl.h>
#include <ioctl.h>
#include <errno.h>
#include <unistd.h>
#include <stdarg.h>
#include <stat.h>
#include "d:\pure\mintlib\lib.h"

/*
 * the MiNT kernel uses 0x08 for O_APPEND. For
 * backwards compatibility with old .o files,
 * we leave the definition in fcntl.h the same,
 * but adjust the file masks here.
 */

static int __umask = -1;
extern int __mint;

static void _get_umask __PROTO((void));

/*
 * function to set the initial value of __umask
 */

static void
_get_umask()
{

 __umask=Pumask(0);
 if(__umask==-32) __umask=0;
 else (void)Pumask(__umask);
}

/* NOTE: we assume here that every compiler that can handle __PROTO
 *       is __STDC__ and can handle the >>...<< ellipsis
 *       (see also unistd.h)
 */

#ifdef __STDC__
int open(const char *_filename, int iomode, ...)
#else
int open(_filename, iomode, pmode)
    const char *_filename;
    int iomode;
    unsigned pmode;
#endif
{
    int rv;
    int modemask;           /* which bits get passed to the OS? */
    char filename[PATH_MAX];
    long fcbuf;         /* a temporary buffer for Fcntl */

#ifdef __STDC__
    unsigned pmode;
    va_list argp;
    va_start(argp, iomode);
    pmode = va_arg(argp, unsigned int);
    va_end(argp);
#endif

    _unx2dos(_filename, filename);

/* use the umask() setting to get the right permissions */
    if (__umask == -1)
        _get_umask();
    pmode &= ~__umask;

/* set the file access modes correctly */
    iomode = iomode & ~O_SHMODE;

    if (__mint >= 9) {
        modemask = O_ACCMODE | O_SHMODE | O_SYNC | O_NDELAY
                           | O_CREAT | O_TRUNC | O_EXCL;
        iomode |= O_DENYNONE;
        if (__mint >= 96) {
            modemask |= _REALO_APPEND;
            if (iomode & O_APPEND)
                iomode |= _REALO_APPEND;
        }
    } else {
        modemask = O_ACCMODE;
    }

    if(Fattrib(filename, 0, 0) >= 0)        /* file exists */
    {
        if((iomode & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL)) {
            errno = EEXIST;
            return -1;
        }
        rv = (int)Fopen(filename,iomode & modemask);
        if ((iomode & ~modemask & O_TRUNC) && (rv >= 0)) {
            /* Give up if the mode flags conflict */
            if (iomode & O_RDONLY) {
                (void)Fclose(rv);
                errno = EACCES;
                return -1;
            }
            /* Try the FTRUNCATE first.  If it fails, have GEMDOS
               truncate it, then reopen with the correct modes.
            */
            fcbuf = 0L;
            if ((__mint <= 90)
                || (Fcntl(rv, (long) &fcbuf, FTRUNCATE) < 0)) {
                (void)Fclose(rv);
                rv = (int)Fcreate(filename, 0x00);
                if (rv < 0) {
                    errno = -rv;
                    return -1;
                }

                else if ((iomode & modemask)!=O_WRONLY) {
                    (void)Fclose(rv);
                    rv = (int)Fopen(filename,iomode & modemask);

                }
            }
        }
    }
    else                    /* file doesn't exist */
    {
        if(iomode & O_CREAT) {
            if (__mint >= 9)
              rv = (int) Fopen (filename, iomode & modemask);
            else {
                rv = (int)Fcreate(filename, 0x00);
                if (rv >= 0 && (iomode & modemask)!=O_WRONLY) {
                (void)Fclose(rv);
                rv = (int)Fopen(filename,iomode & modemask);
                }
            }
            if (rv >= 0 && __mint >= 9)
                (void)Fchmod(filename, pmode);
        }
        else
            rv = -ENOENT;
    }

    if (rv < (__SMALLEST_VALID_HANDLE)) {
        if ((rv == -EPATH) && (_enoent(filename)))
            rv = -ENOENT;
        errno = -rv;
        return __SMALLEST_VALID_HANDLE - 1;
    }
    if (__mint) {
        /* Relocate the handle to the lowest positive numbered handle
           available
        */
        fcbuf = Fcntl(rv, (long) 0, F_DUPFD);
        if (fcbuf >= 0) {
          if (fcbuf < rv) {
        (void) Fclose(rv);
            rv = (int) fcbuf;
          } else {
            (void) Fclose((int) fcbuf);
          }
        }
            /* clear the close-on-exec flag */
        fcbuf = (long)Fcntl(rv, (long)0, F_GETFD);
        (void)Fcntl(rv, fcbuf & ~FD_CLOEXEC, F_SETFD);
    }
    if ((iomode & O_APPEND) && !(modemask & _REALO_APPEND))
        (void)Fseek(0L, rv, SEEK_END);

    /* Important side effect:  isatty(rv) sets up flags under TOS */
    if (isatty(rv) && (!(iomode & O_NOCTTY)) && (!(isatty(-1)))) {
          /* If the process is a session leader with no controlling tty,
             and the tty that was opened is not already the controlling
             tty of another process, the tty becomes the controlling tty
             of the process.  Note that MiNT has no concept of a session
             leader so we really only check that it is a process group
             leader.
          */
      if ((!__mint)
              || ((Pgetpgrp() == Pgetpid())
                  && (Fcntl(rv, &fcbuf, TIOCGPGRP) >= 0)
                  && (fcbuf == 0))) {
            (void) Fforce(-1, rv);  /* new controlling tty */
            __open_stat[__OPEN_INDEX(-1)] = __open_stat[__OPEN_INDEX(rv)];
      }
    }

    return(rv);
}

int
creat(name, mode)
    const char *name;
    unsigned   mode;
{
    return open(name, O_WRONLY|O_CREAT|O_TRUNC, mode);
}

/* umask -- change default file creation mask */

int umask(complmode)
       int complmode;
{
    int old_umask;

    if (__umask == -1)
        _get_umask();
    old_umask = __umask;
    __umask = complmode;
    if (__mint >= 9)
        return Pumask(complmode);
    return old_umask;
}

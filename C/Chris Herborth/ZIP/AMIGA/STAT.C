/* Here we have a handmade stat() function because Aztec's c.lib stat() */
/* does not support an st_mode field, which we need... also a chmod().  */

/* This stat() is by Paul Wells, modified by Paul Kienitz. */
/* for use with Aztec C >= 5.0 and Lattice C <= 4.01  */

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#ifdef AZTEC_C
#  include <clib/exec_protos.h>
#  include <clib/dos_protos.h>
#  include <pragmas/exec_lib.h>
#  include <pragmas/dos_lib.h>
#  include "amiga/z-stat.h"             /* fake version of stat.h */
#else
#  include <sys/types.h>
#  include <sys/stat.h>
#  include <proto/exec.h>
#  include <proto/dos.h>
#endif

#ifndef SUCCESS
#  define SUCCESS (-1)
#  define FAILURE (0)
#endif

extern int stat(char *file,struct stat *buf);

stat(file,buf)
char *file;
struct stat *buf;
{

        struct FileInfoBlock *inf;
        struct FileLock *lock;
        long ftime;

        if( (lock = (struct FileLock *)Lock(file,SHARED_LOCK))==0 )
                /* file not found */
                return(-1);

        if( !(inf = (struct FileInfoBlock *)AllocMem(
                (long)sizeof(struct FileInfoBlock),MEMF_PUBLIC|MEMF_CLEAR)) )
        {
                UnLock((BPTR)lock);
                return(-1);
        }

        if( Examine((BPTR)lock,inf)==FAILURE )
        {
                FreeMem((char *)inf,(long)sizeof(*inf));
                UnLock((BPTR)lock);
                return(-1);
        }

        /* fill in buf */
        buf->st_dev         =
        buf->st_nlink       =
        buf->st_uid         =
        buf->st_gid         =
        buf->st_rdev        = 0;
        
        buf->st_ino         = inf->fib_DiskKey;
        buf->st_blocks      = inf->fib_NumBlocks;
        buf->st_size        = inf->fib_Size;

        /* now the date.  AmigaDOS has weird datestamps---
         *      ds_Days is the number of days since 1-1-1978;
         *      however, as Unix wants date since 1-1-1970...
         */

        ftime =
                (inf->fib_Date.ds_Days * 86400 )                +
                (inf->fib_Date.ds_Minute * 60 )                 +
                (inf->fib_Date.ds_Tick / TICKS_PER_SECOND )     +
                (86400 * 8 * 365 )                              +
                (86400 * 2 );  /* two leap years */

    /*  ftime += timezone;  */

        buf->st_ctime =
        buf->st_atime =
        buf->st_mtime = ftime;

        buf->st_mode = (inf->fib_DirEntryType < 0 ? S_IFREG : S_IFDIR);

        /* lastly, throw in the protection bits */
        buf->st_mode |= ((inf->fib_Protection ^ 0xF) & 0xFF);

        FreeMem((char *)inf, (long)sizeof(*inf));
        UnLock((BPTR)lock);

        return(0);

}



/* opendir(), readdir(), closedir() and rmdir() by Paul Kienitz: */

unsigned short disk_not_mounted;

static DIR *dir_cleanup_list = NULL;    /* for resource tracking */

DIR *opendir(char *path)
{
    DIR *dd = AllocMem(sizeof(DIR), MEMF_PUBLIC);
    if (!dd) return NULL;
    if (!(dd->d_parentlock = Lock(path, MODE_OLDFILE))) {
        disk_not_mounted = IoErr() == ERROR_DEVICE_NOT_MOUNTED;
        FreeMem(dd, sizeof(DIR));
        return NULL;
    } else
        disk_not_mounted = 0;
    if (!Examine(dd->d_parentlock, &dd->d_fib) || dd->d_fib.fib_EntryType < 0) {
        UnLock(dd->d_parentlock);
        FreeMem(dd, sizeof(DIR));
        return NULL;
    }
    dd->d_cleanuplink = dir_cleanup_list;       /* track them resources */
    if (dir_cleanup_list)
        dir_cleanup_list->d_cleanupparent = &dd->d_cleanuplink;
    dd->d_cleanupparent = &dir_cleanup_list;
    dir_cleanup_list = dd;
    return dd;
}

void closedir(DIR *dd)
{
    if (dd) {
        if (dd->d_cleanuplink)
            dd->d_cleanuplink->d_cleanupparent = dd->d_cleanupparent;
        *(dd->d_cleanupparent) = dd->d_cleanuplink;
        if (dd->d_parentlock)
            UnLock(dd->d_parentlock);
        FreeMem(dd, sizeof(DIR));
    }
}

/* CALL THIS WHEN HANDLING CTRL-C OR OTHER UNEXPECTED EXIT! */
void close_leftover_open_dirs(void)
{
    while (dir_cleanup_list)
        closedir(dir_cleanup_list);
}

DIR *readdir(DIR *dd)
{
    return (ExNext(dd->d_parentlock, &dd->d_fib) ? dd : NULL);
}

int rmdir(char *path)
{
    return (DeleteFile(path) ? 0 : IoErr());
}


int chmod(char *filename, int bits)     /* bits are as for st_mode */
{
    long protmask = (bits & 0xFF) ^ 0xF;
    return !SetProtection(filename, protmask);
}


#ifdef AZTEC_C

/* This here removes unnecessary bulk from the executable with Aztec: */
void _wb_parse()  { }

/* This here pretends we have time zone support and suchlike when we don't: */
int timezone = 0;
void tzset()  { }

/* fake a unix function that does not apply to amigados: */
int umask()  { return 0; }

int _OSERR;

#  include <signal.h>

/* C library signal() messes up debugging yet adds no actual usefulness */
typedef void (*__signal_return_type)(int);
__signal_return_type signal()  { return SIG_ERR; }


/* The following replaces Aztec's argv-parsing function for compatibility with
the standard AmigaDOS handling of *E, *N, and *".  It also fixes the problem
the standard _cli_parse() has of accepting only lower-ascii characters. */

int _argc, _arg_len;
char **_argv, *_arg_lin;

void _cli_parse(struct Process *pp, long alen, register UBYTE *aptr)
{
    register UBYTE *cp;
    register struct CommandLineInterface *cli;
    register short c;
    register short starred = 0;

    cli = (struct CommandLineInterface *) (pp->pr_CLI << 2);
    cp = (UBYTE *) (cli->cli_CommandName << 2);
    _arg_len = cp[0] + alen + 2;
    if (!(_arg_lin = AllocMem((long) _arg_len, 0L)))
        return;
    c = cp[0];
    strncpy(_arg_lin, cp + 1, c);
    _arg_lin[c] = 0;
    for (cp = _arg_lin + c + 1; alen && (*aptr < '\n' || *aptr > '\r'); alen--)
        *cp++ = *aptr++;
    *cp = 0;
    for (_argc = 1, aptr = cp = _arg_lin + c + 1; ; _argc++) {
        while (*cp == ' ' || *cp == '\t')
            cp++;
        if (!*cp)
            break;
        if (*cp == '"') {
            cp++;
            while (c = *cp++) {
                if (starred) {
                    if (c | 0x20 == 'n')
                        *aptr++ = '\n';
                    else if (c | 0x20 == 'e')
                        *aptr++ = 27;
                    else
                        *aptr++ = c;
                    starred = 0;
                } else if (c == '"') {  
                    *aptr++ = 0;
                    break;
                } else if (c == '*')
                    starred = 1;
                else
                    *aptr++ = c;
            }
        } else {
            while ((c = *cp++) && c != ' ' && c != '\t')
                *aptr++ = c;
            *aptr++ = 0;
        }
        if (c == 0)
            --cp;
    }
    *aptr = 0;
    if (!(_argv = AllocMem((_argc + 1) * sizeof(*_argv), 0L))) {
        _argc = 0;
        return;
    }
    for (c = 0, cp = _arg_lin; c < _argc; c++) {
        _argv[c] = cp;
        cp += strlen(cp) + 1;
    }
    _argv[c] = NULL;
}

#endif /* AZTEC_C */

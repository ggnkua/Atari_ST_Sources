/* opendir routine */

/* under MiNT (v0.9 or better) these use the appropriate system calls.
 * under TOS or older versions of MiNT, they use Fsfirst/Fsnext
 *
 * Written by Eric R. Smith and placed in the public domain
 */

#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#include <limits.h>
#include <dirent.h>
#include <errno.h>
#include <mint/mintbind.h>
#include "lib.h"


/* Important note: Metados can have opendir for some device and do not
 * have it for others, so there is no point in having a status variable
 * saying there is an opendir call. Check this every time.
 */

/* a new value for DIR->status, to indicate that the file system is not
 * case sensitive.
 */
#define _NO_CASE  8

DIR *opendir(const char *uname)
{
    DIR *d;
    long r;
    _DTA *olddta;
    char namebuf[PATH_MAX];
    char dirpath[PATH_MAX];
    char *p;
    char *name;

    strcpy(namebuf, uname);
    name = namebuf;

    d = malloc(sizeof(DIR));
    if (!d)
        return NULL;

    d->handle = 0xff000000L;  /* indicate that the handle is invalid */

    /* TOS emulation routines */

    p = name;
    if (p)
    {
        /* find the end of the string */
        for (p = name; *p; p++)
            if (*p == '/')
                *p = '\\';

        /* make sure the string ends in '\' */
		if ( (p != name) && (*(p-1) != '\\') )
        {
            *p++ = '\\';
        }
    
    }

    strcpy(p, "*.*");
    olddta = Fgetdta();
    Fsetdta(&(d->dta));
    r = Fsfirst(name, 0x17);
    Fsetdta(olddta);

    if (r == 0)
    {
        d->status = _STARTSEARCH;
    } else if (r == -ENOENT)
    {
        d->status = _NMFILE;
    } else
    {
        free(d);
        __set_errno(-r);
        return NULL;
    }
    d->buf.d_off = 0;

    /* for rewinddir: if necessary, build a relative path */
    if (name[1] == ':')   /* absolute path, no problem */
    {
        dirpath[0] = 0;
    } else
    {
        dirpath[0] = Dgetdrv() + 'A';
        dirpath[1] = ':';
        dirpath[2] = 0;
        if (*name != '\\')
            (void)Dgetpath(dirpath + 2, 0);
    }
    d->dirname = malloc(strlen(dirpath) + strlen(name) + 1);
    if (d->dirname)
    {
        strcpy(d->dirname, dirpath);
        strcat(d->dirname, name);
    }
    return d;
}

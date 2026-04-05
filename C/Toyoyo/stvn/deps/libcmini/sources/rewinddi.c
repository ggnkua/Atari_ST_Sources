/* rewinddir routine */

/* under MiNT (v0.9 or better) these use the appropriate system calls.
 * under TOS or older versions of MiNT, they use Fsfirst/Fsnext
 *
 * Written by Eric R. Smith and placed in the public domain
 */

#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <dirent.h>
#include <errno.h>
#include <sys/types.h>
#include <mint/mintbind.h>

#include "lib.h"

/* See the comment in opendir.c/readdir.c for the use (or better non-use)
 * of a status variable for the system call being implemented.
 */

void rewinddir(DIR *dirp)
{
    long r;
    _DTA *olddta;

    /* I wish POSIX had allowed an error to occur here! */
    if (!dirp->dirname)
    {
        return;
    }

    olddta = Fgetdta();
    Fsetdta(&(dirp->dta));
    r = Fsfirst(dirp->dirname, 0x17);
    Fsetdta(olddta);
    if (r == 0)
    {
        dirp->status = _STARTSEARCH;
    } else
    {
        dirp->status = _NMFILE;
    }
    dirp->buf.d_off = 0;
}

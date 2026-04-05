/* readdir routine */

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
#include <mint/osbind.h>
#include <mint/mintbind.h>
#include <errno.h>
#include "lib.h"


/* Important note: under Metados, some file systems can have opendir/readdir/
 * closedir, so we must not have a status variable for these ones.
 * Instead, check the directory struct if there was an opendir call.
 */

/* a new value for DIR->status, to indicate that the file system is not
 * case sensitive.
 */
#define _NO_CASE  8

struct dirent *readdir(DIR *d)
{
    long r;
    _DTA *olddta;
    struct dirent *dd = &d->buf;

    if (d == NULL)
    {
        __set_errno(EBADF);
        return NULL;
    }
    
    /* ordinary TOS search, using Fsnext. Note that the first time through,
     * Fsfirst has already provided valid data for us; for subsequent
     * searches, we need Fsnext.
     */
    if (d->status == _NMFILE)
        return 0;
    if (d->status == _STARTSEARCH)
    {
        d->status = _INSEARCH;
    } else
    {
        olddta = Fgetdta();
        Fsetdta(&(d->dta));
        r = Fsnext();
        Fsetdta(olddta);
        if (r == -ENMFILES)
        {
            d->status = _NMFILE;
            return NULL;
        } else if (r)
        {
            __set_errno(-r);
            return 0;
        }
    }
    dd->d_ino = __inode++;
    dd->d_off++;
    strcpy(dd->d_name, d->dta.dta_name);
    dd->d_namlen = (short)strlen(dd->d_name);
    return dd;
}

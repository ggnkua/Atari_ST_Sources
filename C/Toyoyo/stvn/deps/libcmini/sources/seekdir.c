/* seekdir routine */

/* under MiNT (v0.9 or better) these use the appropriate system calls.
 * under TOS or older versions of MiNT, they use Fsfirst/Fsnext
 *
 * Written by Eric R. Smith and placed in the public domain
 */

#include <sys/types.h>

#include <limits.h>
#include <dirent.h>
#include "lib.h"

/* not POSIX */

void seekdir(DIR *dirp, long int pos)
{
    rewinddir(dirp);
    while (dirp->buf.d_off != pos)
    {
        if (!readdir(dirp))
            break;
    }
}

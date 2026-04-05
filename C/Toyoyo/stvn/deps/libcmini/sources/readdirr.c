/* readdir routine */

/* under MiNT (v0.9 or better) these use the appropriate system calls.
 * under TOS or older versions of MiNT, they use Fsfirst/Fsnext
 *
 * Written by Eric R. Smith and placed in the public domain
 */

#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>
#include "lib.h"



/* Reentrant version of readdir, use is deprecated because it imposes
   a performance loss.  The ordinary readdir() is already thread-safe
   in the MiNTLib but the existence of readdir_r() may facilitate 
   writing or compiling portable code.  */
int readdir_r(DIR *dirp, struct dirent *entry, struct dirent **result)
{
    if (result == NULL || *result == NULL || entry == NULL)
    {
        __set_errno(EBADF);
        return -1;
    }
    *result = readdir(dirp);
    if (*result == NULL)
        return -1;
    
    *entry = **result;
    return 0;
}

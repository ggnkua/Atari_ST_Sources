#include <stdio.h>
#include <mint/osbind.h>
#include <errno.h>
#include "lib.h"

int unlink(const char *filename)
{
    int retval;

    if (filename == NULL)
    {
        __set_errno(EFAULT);

        return -1;
    }

    retval = (int) Fdelete(filename);

    if (retval < 0)
    {
        /*
         * check if file exists or if it is a directory. Both cases should
         * return an appropriate error (-ENOENT or -ENOTDIR)
         */

        __set_errno(-retval);
        return -1;
    }
    return 0;       /* no error */
}

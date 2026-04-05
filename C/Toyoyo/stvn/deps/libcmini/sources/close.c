#include <mint/osbind.h>
#include <stdio.h>
#include "lib.h"


int close(int fd)
{
    long ret;

    ret = Fclose(fd);

    if (ret < 0)
    {
        __set_errno(-ret);
        return -1;
    }
    return 0;
}

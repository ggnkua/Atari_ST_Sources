#include <stdio.h>
#include <errno.h>
#include "lib.h"

int (fileno)(FILE *stream)
{
    if (stream != NULL)
        return FILE_GET_HANDLE(stream);
    __set_errno(EBADF);
    return -1;
}

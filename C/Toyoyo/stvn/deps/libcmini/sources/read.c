#include <mint/osbind.h>
#include <stdio.h>
#include <unistd.h>
#include "lib.h"

ssize_t read(int fd, void *buf, size_t nbytes)
{
    long result;

    result = Fread(fd, nbytes, buf);

    if (result < 0)
    {
        __set_errno(-result);
        return -1;
    }
    return result;
}

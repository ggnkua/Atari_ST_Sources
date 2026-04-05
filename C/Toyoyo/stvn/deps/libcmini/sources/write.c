#include <mint/osbind.h>
#include <unistd.h>
#include "lib.h"

/* posix write needed by C++ in libstdc++-v3/libsupc++/pure.cc */
ssize_t write(int fd, const void *buf, size_t nbytes)
{
    long result;

    result = Fwrite(fd, nbytes, buf);

    if (result < 0)
    {
        __set_errno(-result);
        return -1;
    }
    return result;
}

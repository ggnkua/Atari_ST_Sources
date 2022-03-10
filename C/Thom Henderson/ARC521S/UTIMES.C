
/* bsd utimes emulation for Sys V */
/* by Jon Zeeff */

#include <sys/types.h>


struct timeval {
     long    tv_sec;
     long    tv_usec;
};

utimes(path,tvp)
char *path;
struct timeval tvp[2];
{
    time_t utimbuf[2];

    utimbuf[0] = (time_t) tvp[0].tv_sec;
    utimbuf[1] = (time_t) tvp[1].tv_sec;

    return utime(path,utimbuf);
}

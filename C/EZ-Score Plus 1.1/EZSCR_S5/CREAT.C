#include <errno.h>
#include <fcntl.h>
#include <osbind.h>

int creat(path, pmode)
char *path;
int pmode;
{
    int refnum;
    extern short _binary[];

    if (strcmp(path, "CON:") && strcmp(path, "AUX:") && strcmp(path, "PRT:")) {
	if ((refnum = Fcreate(path, 0)) < 0) {
	    errno = refnum;
	    return -1;
	}
	_binadd(refnum, pmode & O_BINARY);
    }
    else
	refnum = open(path, O_RDWR | (pmode & O_BINARY));

    return refnum;
}

#include <errno.h>
#include <stdio.h>
#include <osbind.h>

putscr(buf, nbyte)
char *buf;
int nbyte;
{
    while (nbyte--) {
	if (*buf == '\n')
	    Cconout('\r');
	Cconout(*buf++);
    }
}

putaux(buf, nbyte)
char *buf;
int nbyte;
{
    while (nbyte--)
	Cauxout(*buf++);
}

putprn(buf, nbyte)
char *buf;
int nbyte;
{
    while (nbyte--)
	Cprnout(*buf++);
}

int write(fildes, buf, nbyte)
int fildes;
register char *buf;
unsigned nbyte;
{
    int count;
    register char *bp = buf;
    char *tp;
    char *crlf = "\r\n";
    long tl;

    if (fildes == STDCON) {
	putscr(buf, nbyte);
	count = nbyte;
    }
    else if (fildes == STDAUX) {
	putaux(buf, nbyte);
	count = nbyte;
    }
    else if (fildes == STDPRT) {
	putprn(buf, nbyte);
	count = nbyte;
    }
    else {
	tp = buf;
	count = 0;
	if (!_bintst(fildes)) { /* translated mode */
	    while (bp-buf < nbyte) {
		if (*bp == '\n') {
		    if (bp-tp > 0) {
			tl = bp-tp;
			if ((errno = Fwrite(fildes, tl, tp)) != tl) 
			    return -1;
			count += errno;
		    }
		    if ((errno = Fwrite(fildes, 2L, crlf)) != 2) return -1;
		    count++;
		    tp = ++bp;
		}
		else
		    bp++;
	    }
	}
	else
	    bp = buf+nbyte;
	tl = bp-tp;
	if ((errno = Fwrite(fildes, tl, tp)) != tl) return -1;
	count += errno;
	errno = 0;
    }

    return count;
}

#include <errno.h>
#include <stdio.h>
#include <osbind.h>

#define BUFFLEN 80    /* size of stdin input buffer */

int getkey(fildes)
int fildes;
{
    int i;
    int ch;
    static char buff[BUFFLEN];	  /* input buffer for stdin */
    static int frontbuff = 0, endbuff = 0;

    if (fildes == STDCON) {	/* CON: */
	if (frontbuff == endbuff) {
	    frontbuff = endbuff = 0;
	    while (1) {
		ch = Crawcin();
		if (ch == '\b') {
		    if (frontbuff) {
			frontbuff--;
			Cconout(27);    /* ESC */
			Cconout('D');   /* D - backup a space */
		    }
		}
		else {
		    if (ch == '\r') {
			buff[frontbuff++] = '\n';
			Cconout('\r'); Cconout('\n');
			break;
		    }
		    if (ch == 3)    /* ^C */
			exit(2);
		    if (ch == 26) {  /* ^Z, EOF */
			buff[frontbuff++] = ch;
			Cconout('\r'); Cconout('\n');
			break;
		    }
		    buff[frontbuff++] = ch;
		    Cconout(ch);
		}
	    }
	}
	return buff[endbuff] == 26 ? -1 : buff[endbuff++];
    }

    else if (fildes == STDAUX)
	return Cauxin();

    else 
	return -1;	/* Don't know about any other devices */
}

int read(fildes, buf, nbyte)
int fildes;
char *buf;
unsigned nbyte;
{
    long count;
    register char *bp = buf;
    register char *tp;

    count = nbyte;
    errno = 0;
    if (fildes <= STDCON) {
	count = 0;
	while (nbyte--)
	    if ((*bp = getkey(fildes)) == -1)
		break;
	    else {
		bp++;
		count++;
	    }
	if (!count)
	    return -1;
	return count;	/* don't translate from keyboard */
    }
    else
	  if ((errno = count = Fread(fildes, count, buf)) < 0) return -1;

    if (!_bintst(fildes)) { /* translate CR/LF to LF */
	nbyte = count;
	tp = bp = buf;
	while (nbyte) {
	    if (bp-buf >= count) {
		if ((errno = Fread(fildes, (long)nbyte, tp)) < 0) return -1;
		if (!errno) 	/* reached EOF */
		    break;
		count -= nbyte-errno;
		bp = tp;
	    }

	    if (*bp == '\r')
		bp++;
	    else {
		*tp++ = *bp++;
	    	nbyte--;
	    }
	}
	count = tp-buf;
    }
    errno = 0;
    return count;
}

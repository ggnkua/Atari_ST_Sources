/* getln.c */

#include "osbind.h"
#include "mydefs.h"

#define	QUANTUM		512L		/* #bytes to eat at a time */
#define	LNBUFSIZ	(QUANTUM*2)


static char getlnbuf[LNBUFSIZ];		/* buffer */
int getlnind;				/* current spot in buffer */
int getlncnt = 0;			/* #chars in buffer */


/*
 * Get line from file into buffer,
 * return NULL or ptr to beginning of line.
 *
 * If `fd' is -1, reset the line buffer.
 *
 */
char *getln(fd)
int fd;
{
    register int i;
    register char *p, *d;
    int readamt = -1;			/* 0 if last read() yeilded 0 bytes */

    if (fd == -1)
    {
	getlncnt = 0;			/* initialize, return NULL */
	return NULL;
    }

    if (getlncnt == 0)
	getlnind = 0;

  for (;;)
  {
    /*
     * Scan for next end-of-line;
     * (\r or \n, eat \n after \r).
     */
    for (i = 0, p = &getlnbuf[getlnind]; i < getlncnt; ++i, ++p)
	if (*p == '\r' ||
	    *p == '\n')
	{
	    if (*p == '\r' &&
		(i+1) < getlncnt && p[1] == '\n')
		    ++i;

	    *p = '\0';
	    p = &getlnbuf[getlnind];
	    ++i;
	    getlnind += i;
	    getlncnt -= i;
	    return p;
	}

    /*
     * Handle hanging lines by ignoring them. (*sigh*)
     * (input file is exhausted, no \r or \n on last line)
     */
    if (!readamt && getlncnt)
    {
	getlncnt = 0;
	*p = '\0';
	return NULL;
    }

    /*
     * Truncate and return absurdly long lines.
     */
    if (getlncnt >= QUANTUM)
    {
	getlnbuf[getlnind + getlncnt - 1] = '\0';
	getlncnt = 0;
	return &getlnbuf[getlnind];
    }


    /*
     * Relocate what's left of a line to the beginning
     * of the buffer, and read some more of the file in;
     * return NULL if the buffer's empty and on EOF.
     */
    if (getlnind != 0)
    {
	p = &getlnbuf[getlnind];
	d = &getlnbuf[0];
	for (i = 0; i < getlncnt; ++i)
	    *d++ = *p++;
	getlnind = 0;
    }

    if ((readamt = Fread(fd, QUANTUM, &getlnbuf[getlnind + getlncnt])) < 0)
	return NULL;
    getlncnt += readamt;

    if (getlncnt == 0)
	return NULL;
  }
}


/*
 * Get '\'-continued line from a file
 * into a buffer;
 * return 0 on EOF, 1 on successful getLine.
 *
 */
int cgetln(fd, buf)
int fd;
char *buf;
{
    char *b, *s;

    b = buf;
    while ((s = getln(fd)) != NULL)
    {
	while (*s)
	    *b++ = *s++;
	if (s[-1] != '\\')
	    break;		
    }

    *b = '\0';
    if (b != buf ||
	s != NULL) return 1;
    return 0;
}

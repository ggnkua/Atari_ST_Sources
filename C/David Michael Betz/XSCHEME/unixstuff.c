/* unixstuff.c - unix specific routines */

#include "xscheme.h"

#define LBSIZE 200

/* external variables */
extern LVAL s_unbound,true;
extern FILE *tfp;
extern int errno;

/* local variables */
static char lbuf[LBSIZE];
/* static int lpos[LBSIZE]; */
static int lindex;
static int lcount;
static long rseed = 1L;

/* osinit - initialize */
osinit(banner)
  char *banner;
{
    printf("%s\n",banner);
    lindex = 0;
    lcount = 0;
}

/* osfinish - clean up before returning to the operating system */
osfinish()
{
}

/* oserror - print an error message */
oserror(msg)
  char *msg;
{
    printf("error: %s\n",msg);
}

/* osrand - return a random number between 0 and n-1 */
int osrand(n)
  int n;
{
    long k1;

    /* make sure we don't get stuck at zero */
    if (rseed == 0L) rseed = 1L;

    /* algorithm taken from Dr. Dobbs Journal, November 1985, page 91 */
    k1 = rseed / 127773L;
    if ((rseed = 16807L * (rseed - k1 * 127773L) - k1 * 2836L) < 0L)
	rseed += 2147483647L;

    /* return a random number between 0 and n-1 */
    return ((int)(rseed % (long)n));
}

/* osaopen - open an ascii file */
FILE *osaopen(name,mode)
  char *name,*mode;
{
    return (fopen(name,mode));
}

/* osbopen - open a binary file */
FILE *osbopen(name,mode)
  char *name,*mode;
{
    return (fopen(name,mode));
}

/* osclose - close a file */
int osclose(fp)
  FILE *fp;
{
    return (fclose(fp));
}

/* ostell - get the current file position */
long ostell(fp)
  FILE *fp;
{
    return (ftell(fp));
}

/* osseek - set the current file position */
int osseek(fp,offset,whence)
  FILE *fp; long offset; int whence;
{
    return (fseek(fp,offset,whence));
}

/* osagetc - get a character from an ascii file */
int osagetc(fp)
  FILE *fp;
{
    return (getc(fp));
}

/* osaputc - put a character to an ascii file */
int osaputc(ch,fp)
  int ch; FILE *fp;
{
    return (putc(ch,fp));
}

/* osbgetc - get a character from a binary file */
int osbgetc(fp)
  FILE *fp;
{
    return (getc(fp));
}

/* osbputc - put a character to a binary file */
int osbputc(ch,fp)
  int ch; FILE *fp;
{
    return (putc(ch,fp));
}

/* ostgetc - get a character from the terminal */
int ostgetc()
{
    /* int ch; */

    /* check for a buffered character */
    if (lcount--)
	return (lbuf[lindex++]);

    /* get an input line */
    do {
	fgets(lbuf,LBSIZE,stdin);
    } while ((lcount = strlen(lbuf)) == 0);

    /* write it to the transcript file */
    if (tfp)
	for (lindex = 0; lindex < lcount; ++lindex)
	    osaputc(lbuf[lindex],tfp);
    lindex = 0; lcount--;

    /* return the first character */
    return (lbuf[lindex++]);
}

/* ostputc - put a character to the terminal */
ostputc(ch)
  int ch;
{
    /* check for control characters */
    oscheck();

    /* output the character */
    putchar(ch);

    /* output the character to the transcript file */
    if (tfp)
	osaputc(ch,tfp);
}

/* osflush - flush the terminal input buffer */
osflush()
{
    lindex = lcount = 0;
}

/* oscheck - check for control characters during execution */
oscheck()
{
}

/* xsystem - execute a system command */
LVAL xsystem()
{
    char *cmd="sh";
    if (moreargs())
	cmd = (char *)getstring(xlgastring());
    xllastarg();
    return (system(cmd) == 0 ? true : cvfixnum((FIXTYPE)errno));
}

/* ossymbols - enter os specific symbols */
ossymbols()
{
}

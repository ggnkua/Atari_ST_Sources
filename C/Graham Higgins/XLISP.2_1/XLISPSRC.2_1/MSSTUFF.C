/* msstuff.c - ms-dos specific routines */

#include "xlisp.h"

#define LBSIZE 200

/* external variables */
extern LVAL s_unbound,true;
extern FILE *tfp;
extern int errno;

/* make sure we get a large stack */
int _stklen = 32766;

/* local variables */
static char lbuf[LBSIZE];
static int lpos[LBSIZE];
static int lindex;
static int lcount;
static int lposition;
static long rseed = 1L;

/* osinit - initialize */
osinit(banner)
  char *banner;
{
    printf("%s\n",banner);
    lposition = 0;
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
    char bmode[10];
    strcpy(bmode,mode); strcat(bmode,"b");
    return (fopen(name,bmode));
}

/* osclose - close a file */
int osclose(fp)
  FILE *fp;
{
    return (fclose(fp));
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
    int ch;

    /* check for a buffered character */
    if (lcount--)
	return (lbuf[lindex++]);

    /* get an input line */
    for (lcount = 0; ; )
	switch (ch = xgetc()) {
	case '\r':
		lbuf[lcount++] = '\n';
		xputc('\r'); xputc('\n'); lposition = 0;
		if (tfp)
		    for (lindex = 0; lindex < lcount; ++lindex)
			osaputc(lbuf[lindex],tfp);
		lindex = 0; lcount--;
		return (lbuf[lindex++]);
	case '\010':
	case '\177':
		if (lcount) {
		    lcount--;
		    while (lposition > lpos[lcount]) {
			xputc('\010'); xputc(' '); xputc('\010');
			lposition--;
		    }
		}
		break;
	case '\032':
		xflush();
		return (EOF);
	default:
		if (ch == '\t' || (ch >= 0x20 && ch < 0x7F)) {
		    lbuf[lcount] = ch;
		    lpos[lcount] = lposition;
		    if (ch == '\t')
			do {
			    xputc(' ');
			} while (++lposition & 7);
		    else {
			xputc(ch); lposition++;
		    }
		    lcount++;
		}
		else {
		    xflush();
		    switch (ch) {
		    case '\003':	xltoplevel();	/* control-c */
		    case '\007':	xlcleanup();	/* control-g */
		    case '\020':	xlcontinue();	/* control-p */
		    case '\032':	return (EOF);	/* control-z */
		    default:		return (ch);
		    }
		}
	}
}

/* ostputc - put a character to the terminal */
ostputc(ch)
  int ch;
{
    /* check for control characters */
    oscheck();

    /* output the character */
    if (ch == '\n') {
	xputc('\r'); xputc('\n');
	lposition = 0;
    }
    else {
	xputc(ch);
	lposition++;
   }

   /* output the character to the transcript file */
   if (tfp)
	osaputc(ch,tfp);
}

/* osflush - flush the terminal input buffer */
osflush()
{
    lindex = lcount = lposition = 0;
}

/* oscheck - check for control characters during execution */
oscheck()
{
    int ch;
    if (ch = xcheck())
	switch (ch) {
	case '\002':	/* control-b */
	    xflush();
	    xlbreak("BREAK",s_unbound);
	    break;
	case '\003':	/* control-c */
	    xflush();
	    xltoplevel();
	    break;
	case '\024':	/* control-t */
	    xinfo();
	    break;
	}
}

/* xinfo - show information on control-t */
static xinfo()
{
    extern int nfree,gccalls;
    extern long total;
    char buf[80];
    sprintf(buf,"\n[ Free: %d, GC calls: %d, Total: %ld ]",
	    nfree,gccalls,total);
    errputstr(buf);
}

/* xflush - flush the input line buffer and start a new line */
static xflush()
{
    osflush();
    ostputc('\n');
}

/* xgetc - get a character from the terminal without echo */
static int xgetc()
{
    return (bdos(7) & 0xFF);
}

/* xputc - put a character to the terminal */
static xputc(ch)
  int ch;
{
    bdos(6,ch);
}

/* xcheck - check for a character */
static int xcheck()
{
    return (bdos(6,0xFF));
}

/* xsystem - execute a system command */
LVAL xsystem()
{
    char *cmd="COMMAND";
    if (moreargs())
	cmd = (char *)getstring(xlgastring());
    xllastarg();
    return (system(cmd) == 0 ? true : cvfixnum((FIXTYPE)errno));
}

/* xgetkey - get a key from the keyboard */
LVAL xgetkey()
{
    xllastarg();
    return (cvfixnum((FIXTYPE)xgetc()));
}

/* ossymbols - enter os specific symbols */
ossymbols()
{
}

/* ststuff.c - atari-st specific routines */

#include <osbind.h>
#include "xscheme.h"

#define STRMAX         100             /* maximum length of a string constant */
/* char buf[STRMAX+1] = { 0 }; */
static char buf[200];

#define LBSIZE 200

/* set MWC memory parameters */
long _stksize = 16384;	/* stack must be 16K */

/* external variables */
extern LVAL s_unbound,true;
extern FILE *tfp;
extern int errno;

/* local variables */
static char lbuf[LBSIZE];
static int lpos[LBSIZE];
static int lindex;
static int lcount;
static int lposition;
static long rseed = 1L;

#ifdef __STDC__
static void xinfo(void);
static void xflush(void);
static int xgetc(void);
static void xputc(int ch);
static int xcheck(void);
#endif

/* main - the main routine */
void main(argc,argv)
  int argc; char *argv[];
{
    xlmain(argc,argv);
}

/* osinit - initialize */
void osinit(banner)
  char *banner;
{
    ostputs(banner);
    ostputc('\n');
    lposition = 0;
    lindex = 0;
    lcount = 0;
}

/* osfinish - clean up before returning to the operating system */
void osfinish()
{
}

/* oserror - print an error message */
void oserror(msg)
  char *msg;
{
    ostputs("error: ");
    ostputs(msg);
    ostputc('\n');
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
		    case '\034':	xlwrapup();	/* control-\ */
		    default:		return (ch);
		    }
		}
	}
}

/* ostputc - put a character to the terminal */
void ostputc(ch)
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

/* ostputs - output a string to the terminal */
void ostputs(str)
  char *str;
{
    while (*str != '\0')
	ostputc(*str++);
}

/* osflush - flush the terminal input buffer */
void osflush()
{
    lindex = lcount = lposition = 0;
}

/* oscheck - check for control characters during execution */
void oscheck()
{
    switch (xcheck()) {
    case '\002':	/* control-b */
	xflush();
	xlbreak();
	break;
    case '\003':	/* control-c */
	xflush();
	xltoplevel();
	break;
    case '\024':	/* control-t */
	xinfo();
	break;
    case '\023':	/* control-s */
	while (xcheck() != '\021')
	    ;
	break;
    case '\034':	/* control-\ */
	xlwrapup();
	break;
    }
}

/* xinfo - show information on control-t */
static void xinfo()
{
/*
    extern int nfree,gccalls;
    extern long total;
    char buf[80];
    sprintf(buf,"\n[ Free: %d, GC calls: %d, Total: %ld ]",
	    nfree,gccalls,total);
    errputstr(buf);
*/
}

/* xflush - flush the input line buffer and start a new line */
static void xflush()
{
    osflush();
    ostputc('\n');
}

/* xgetc - get a character from the terminal without echo */
static int xgetc()
{
    int ch;
    while ((ch = Crawio(0xFF)) == 0)
	;
    return (ch & 0xFF);
}

/* xputc - put a character to the terminal */
static void xputc(ch)
  int ch;
{
    Crawio(ch);
}

/* xcheck - check for a character */
static int xcheck()
{
    return (Crawio(0xFF));
}

/* file name extension table */
char *ext[] = { ".prg",".tos",".ttp",NULL };

/* xsystem - the built-in function 'system' */
LVAL xsystem()
{
    char *str,*p,cmd[100];
    int cmdlen,sts,i;

    /* get the command string */
    str = getstring(xlgastring());
    xllastarg();

    /* get the command name */
    for (p = cmd, cmdlen = 0; *str && !isspace(*str); ++cmdlen)
	*p++ = *str++;
    *p = '\0';

    /* skip spaces between the command name and the arguments */
    while (*str && isspace(*str))
	++str;

    /* make a counted ascii argument list */
    for (p = &buf[1], buf[0] = '\0'; *str; ++buf[0])
	*p++ = *str++;
    *p = '\0';

    /* try each extension */
    for (i = 0; ext[i]; ++i) {
	strcpy(&cmd[cmdlen],ext[i]);
	if ((sts = Pexec(0,cmd,buf,"")) != -33)
	    break;
    }

    /* return the completion status */
    return (cvfixnum((FIXTYPE)sts));
}

/* xgetkey - get a key from the keyboard */
LVAL xgetkey()
{
    xllastarg();
    return (cvfixnum((FIXTYPE)xgetc()));
}

/* ossymbols - lookup important symbols */
void ossymbols()
{
}

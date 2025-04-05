/* ststuff.c - atari-st specific routines */

#include <osbind.h>
#include "xlisp.h"

#define LBSIZE 200

/* set MWC memory parameters */
long _stksize = 16384;	/* stack must be 16K */

/* external variables */
extern LVAL s_unbound,true;
extern int errno;
extern FILE *tfp;
extern char buf[];

/* line buffer variables */
static char lbuf[LBSIZE];
static int  lpos[LBSIZE];
static int lindex;
static int lcount;
static int lposition;

/* osinit - initialize */
osinit(banner)
  char *banner;
{
    printf("\033v%s\n",banner);
    lposition = 0;
    lindex = 0;
    lcount = 0;
}

/* osfinish - clean up before a return to the operating system */
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
    return (rand() % n);
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
    char rmode[5];
    strcpy(rmode,mode); strcat(rmode,"b");
    return (fopen(name,rmode));
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

/* oscheck - check for control characters during execution */
oscheck()
{
    int ch;
    if (ch = xcheck())
	switch (ch) {
	case '\002':	xflush(); xlbreak("BREAK",s_unbound); break;
	case '\003':	xflush(); xltoplevel(); break;
	}
}

/* osflush - flush the input line buffer */
osflush()
{
    lindex = lcount = 0;
}

/* xflush - flush the input line buffer */
static xflush()
{
    ostputc('\n');
    osflush();
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
static xputc(ch)
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

/* ossymbols - lookup important symbols */
ossymbols()
{
}

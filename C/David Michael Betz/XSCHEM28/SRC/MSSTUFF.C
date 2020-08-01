/* msstuff.c - ms-dos specific routines */

#ifdef NOTDEF
#include <dos.h>
#endif
#include <time.h>
#include "xscheme.h"

#define LBSIZE 200

unsigned _stklen=16384;

/* external variables */
extern LVAL s_unbound,true;
extern FILE *tfp;
#ifdef CODEBLDR
#include <errno.h>
#else
extern int errno;
#endif

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
    return (bdos(7,0,0) & 0xFF);
}

/* xputc - put a character to the terminal */
static void xputc(ch)
  int ch;
{
    bdos(6,ch,0);
}

/* xcheck - check for a character */
static int xcheck()
{
    return (bdos(6,0xFF,0) & 0xFF);
}

#ifdef NOTDEF
/* xinbyte - read a byte from an input port */
LVAL xinbyte()
{
    int portno;
    LVAL val;
    val = xlgafixnum(); portno = (int)getfixnum(val);
    xllastarg();
    return (cvfixnum((FIXTYPE)inp(portno)));
}

/* xoutbyte - write a byte to an output port */
LVAL xoutbyte()
{
    int portno,byte;
    LVAL val;
    val = xlgafixnum(); portno = (int)getfixnum(val);
    val = xlgafixnum(); byte = (int)getfixnum(val);
    xllastarg();
    outp(portno,byte);
    return (NIL);
}

/* xint86 - invoke a system interrupt */
LVAL xint86()
{
    union REGS inregs,outregs;
    struct SREGS sregs;
    LVAL inv,outv,val;
    int intno;

    /* get the interrupt number and the list of register values */
    val = xlgafixnum(); intno = (int)getfixnum(val);
    inv = xlgavector();
    outv = xlgavector();
    xllastarg();

    /* check the vector lengths */
    if (getsize(inv) != 9)
        xlerror("incorrect vector length",inv);
    if (getsize(outv) != 9)
	xlerror("incorrect vector length",outv);

    /* load each register from the input vector */
    val = getelement(inv,0);
    inregs.x.ax = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,1);
    inregs.x.bx = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,2);
    inregs.x.cx = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,3);
    inregs.x.dx = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,4);
    inregs.x.si = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,5);
    inregs.x.di = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,6);
    sregs.es = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,7);
    sregs.ds = (fixp(val) ? (int)getfixnum(val) : 0);
    val = getelement(inv,8);
    inregs.x.cflag = (fixp(val) ? (int)getfixnum(val) : 0);

    /* do the system interrupt */
    int86x(intno,&inregs,&outregs,&sregs);

    /* store the results in the output vector */
    setelement(outv,0,cvfixnum((FIXTYPE)outregs.x.ax));
    setelement(outv,1,cvfixnum((FIXTYPE)outregs.x.bx));
    setelement(outv,2,cvfixnum((FIXTYPE)outregs.x.cx));
    setelement(outv,3,cvfixnum((FIXTYPE)outregs.x.dx));
    setelement(outv,4,cvfixnum((FIXTYPE)outregs.x.si));
    setelement(outv,5,cvfixnum((FIXTYPE)outregs.x.di));
    setelement(outv,6,cvfixnum((FIXTYPE)sregs.es));
    setelement(outv,7,cvfixnum((FIXTYPE)sregs.ds));
    setelement(outv,8,cvfixnum((FIXTYPE)outregs.x.cflag));
    
    /* return the result list */
    return (outv);
}

/* getnext - get the next fixnum from a list */
static int getnext(plist)
  LVAL *plist;
{
    LVAL val;
    if (consp(*plist)) {
        val = car(*plist);
	*plist = cdr(*plist);
	if (!fixp(val))
	    xlerror("expecting an integer",val);
        return ((int)getfixnum(val));
    }
    return (0);
}
#endif

/* xtime - get the current time */
LVAL xtime()
{
    xllastarg();
    return (cvfixnum((FIXTYPE)time((time_t)0)));
}

/* xdifftime - get the difference between two time values */
LVAL xdifftime()
{
    time_t t1,t2;
    LVAL val;
    val = xlgafixnum(); t1 = (time_t)getfixnum(val);
    val = xlgafixnum(); t2 = (time_t)getfixnum(val);
    xllastarg();
    return (cvflonum((FLOTYPE)difftime(t1,t2)));
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
void ossymbols()
{
}

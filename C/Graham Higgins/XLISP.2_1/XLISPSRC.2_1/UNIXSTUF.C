/* uxstuff.c - minixST/unix specific routines */
/* stolen from sttuff.c */

#include "xlisp.h"
#include <signal.h>

/* external variables */
extern LVAL s_unbound,true;
extern int errno;
extern FILE *tfp;
static void (*old_handler)();

static void intr()
{
    xltoplevel();
}

/* osinit - initialize */
osinit(banner)
  char *banner;
{
    fprintf(stderr, "%s\n",banner);
    old_handler = signal(SIGINT, intr);
}

/* osfinish - clean up before a return to the operating system */
osfinish()
{
    signal(SIGINT, old_handler);
}

/* oserror - print an error message */
oserror(msg)
  char *msg;
{
    fprintf(stderr, "error: %s\n",msg);
}

/* osrand - return a random number between 0 and n-1 */
int osrand(n)
  int n;
{
    extern long rand();
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
    return (fopen(name,mode));
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
	return(getchar());
}

/* ostputc - put a character to the terminal */
ostputc(ch)
  int ch;
{
    putchar(ch);

   /* output the character to the transcript file */
   if (tfp)
	putc(ch,tfp);
}

/* oscheck - check for control characters during execution */
oscheck()
{
}

/* osflush - flush the input line buffer */
osflush()
{
	fflush(stdin);
}

/* xsystem - the built-in function 'system' */
LVAL xsystem()
{
    char *cmd = "";
    if (moreargs())
	cmd = (char *)getstring(xlgastring());
    xllastarg();
    return (system(cmd) == 0 ? true : cvfixnum((FIXTYPE)errno));
}

/* ossymbols - lookup important symbols */
ossymbols()
{
}

#include <sgtty.h>

/* xgetkey - get a key from the keyboard */
LVAL xgetkey()
{
    struct sgttyb s;
    char c;
    int i = fileno(stdin);

    gtty(i, &s);
    s.sg_flags |= RAW;
    s.sg_flags &= ~ECHO;
    stty(i, &s);
    read(i, &c, 1);
    s.sg_flags &= ~RAW;
    s.sg_flags |= ECHO;
    stty(i, &s);
    xllastarg();
    return (cvfixnum((FIXTYPE)c));
}

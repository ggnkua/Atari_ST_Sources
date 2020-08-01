/* xlio - xlisp i/o routines */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern LVAL s_stdin,s_stdout,s_stderr,s_debugio,s_traceout,s_unbound;
extern int xlfsize;

/* xlgetc - get a character from a file or stream */
int xlgetc(fptr)
  LVAL fptr;
{
    LVAL lptr,cptr;
    FILE *fp;
    int ch;

    /* check for input from nil */
    if (fptr == NIL)
	ch = EOF;

    /* otherwise, check for input from a stream */
    else if (ustreamp(fptr)) {
	if ((lptr = gethead(fptr)) == NIL)
	    ch = EOF;
	else {
	    if (!consp(lptr) || (cptr = car(lptr)) == NIL || !charp(cptr))
		xlfail("bad stream");
	    sethead(fptr,lptr = cdr(lptr));
	    if (lptr == NIL)
		settail(fptr,NIL);
	    ch = getchcode(cptr);
	}
    }

    /* otherwise, check for a buffered character */
    else if (ch = getsavech(fptr))
	setsavech(fptr,'\0');

    /* otherwise, check for terminal input or file input */
    else {
	fp = getfile(fptr);
	if (fp == stdin || fp == stderr)
	    ch = ostgetc();
	else
	    ch = osagetc(fp);
    }

    /* return the character */
    return (ch);
}

/* xlungetc - unget a character */
xlungetc(fptr,ch)
  LVAL fptr; int ch;
{
    LVAL lptr;
    
    /* check for ungetc from nil */
    if (fptr == NIL)
	;
	
    /* otherwise, check for ungetc to a stream */
    if (ustreamp(fptr)) {
	if (ch != EOF) {
	    lptr = cons(cvchar(ch),gethead(fptr));
	    if (gethead(fptr) == NIL)
		settail(fptr,lptr);
	    sethead(fptr,lptr);
	}
    }
    
    /* otherwise, it must be a file */
    else
	setsavech(fptr,ch);
}

/* xlpeek - peek at a character from a file or stream */
int xlpeek(fptr)
  LVAL fptr;
{
    LVAL lptr,cptr;
    int ch;

    /* check for input from nil */
    if (fptr == NIL)
	ch = EOF;

    /* otherwise, check for input from a stream */
    else if (ustreamp(fptr)) {
	if ((lptr = gethead(fptr)) == NIL)
	    ch = EOF;
	else {
	    if (!consp(lptr) || (cptr = car(lptr)) == NIL || !charp(cptr))
		xlfail("bad stream");
	    ch = getchcode(cptr);
	}
    }

    /* otherwise, get the next file character and save it */
    else {
	ch = xlgetc(fptr);
	setsavech(fptr,ch);
    }

    /* return the character */
    return (ch);
}

/* xlputc - put a character to a file or stream */
xlputc(fptr,ch)
  LVAL fptr; int ch;
{
    LVAL lptr;
    FILE *fp;

    /* count the character */
    ++xlfsize;

    /* check for output to nil */
    if (fptr == NIL)
	;

    /* otherwise, check for output to an unnamed stream */
    else if (ustreamp(fptr)) {
	lptr = consa(cvchar(ch));
	if (gettail(fptr))
	    rplacd(gettail(fptr),lptr);
	else
	    sethead(fptr,lptr);
	settail(fptr,lptr);
    }

    /* otherwise, check for terminal output or file output */
    else {
	fp = getfile(fptr);
	if (fp == stdout || fp == stderr)
	    ostputc(ch);
	else
	    osaputc(ch,fp);
    }
}

/* xlflush - flush the input buffer */
int xlflush()
{
    osflush();
}

/* stdprint - print to *standard-output* */
stdprint(expr)
  LVAL expr;
{
    xlprint(getvalue(s_stdout),expr,TRUE);
    xlterpri(getvalue(s_stdout));
}

/* stdputstr - print a string to *standard-output* */
stdputstr(str)
  char *str;
{
    xlputstr(getvalue(s_stdout),str);
}

/* errprint - print to *error-output* */
errprint(expr)
  LVAL expr;
{
    xlprint(getvalue(s_stderr),expr,TRUE);
    xlterpri(getvalue(s_stderr));
}

/* errputstr - print a string to *error-output* */
errputstr(str)
  char *str;
{
    xlputstr(getvalue(s_stderr),str);
}

/* dbgprint - print to *debug-io* */
dbgprint(expr)
  LVAL expr;
{
    xlprint(getvalue(s_debugio),expr,TRUE);
    xlterpri(getvalue(s_debugio));
}

/* dbgputstr - print a string to *debug-io* */
dbgputstr(str)
  char *str;
{
    xlputstr(getvalue(s_debugio),str);
}

/* trcprin1 - print to *trace-output* */
trcprin1(expr)
  LVAL expr;
{
    xlprint(getvalue(s_traceout),expr,TRUE);
}

/* trcputstr - print a string to *trace-output* */
trcputstr(str)
  char *str;
{
    xlputstr(getvalue(s_traceout),str);
}



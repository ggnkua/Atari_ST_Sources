/* xsio - xscheme i/o routines */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* global variables */
FIXTYPE xlfsize;

/* external variables */
extern LVAL s_stdin,s_stdout,s_stderr,s_unbound;

/* xlgetc - get a character from a file or stream */
int xlgetc(fptr)
  LVAL fptr;
{
    FILE *fp;
    int ch;

    /* check for input from nil */
    if (fptr == NIL)
	ch = EOF;

    /* otherwise, check for a buffered character */
    else if (ch = getsavech(fptr))
	setsavech(fptr,'\0');

    /* otherwise, check for terminal input or file input */
    else {
	fp = getfile(fptr);
	if (fp == stdin || fp == stderr)
	    ch = ostgetc();
	else if ((getpflags(fptr) & PF_BINARY) != 0)
	    ch = osbgetc(fp);
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
    /* check for ungetc from nil */
    if (fptr == NIL)
	;
	
    /* otherwise, it must be a file */
    else
	setsavech(fptr,ch);
}

/* xlpeek - peek at a character from a file or stream */
int xlpeek(fptr)
  LVAL fptr;
{
    int ch;

    /* check for input from nil */
    if (fptr == NIL)
	ch = EOF;

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
    FILE *fp;

    /* count the character */
    ++xlfsize;

    /* check for output to nil */
    if (fptr == NIL)
	;

    /* otherwise, check for terminal output or file output */
    else {
	fp = getfile(fptr);
	if (fp == stdout || fp == stderr)
	    ostputc(ch);
	else if ((getpflags(fptr) & PF_BINARY) != 0)
	    osbputc(ch,fp);
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
    xlprin1(expr,getvalue(s_stdout));
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
    xlprin1(expr,getvalue(s_stderr));
    xlterpri(getvalue(s_stderr));
}

/* errputstr - print a string to *error-output* */
errputstr(str)
  char *str;
{
    xlputstr(getvalue(s_stderr),str);
}

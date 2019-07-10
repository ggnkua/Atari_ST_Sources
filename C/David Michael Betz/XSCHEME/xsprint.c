/* xsprint.c - xscheme print routine */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* global variables */
int prbreadth = -1;
int prdepth = -1;

/* local variables */
static char buf[200];

/* external variables */
extern LVAL true,s_printcase,k_downcase;
extern LVAL s_fixfmt,s_flofmt,s_unbound;

/* xlprin1 - print an expression with quoting */
xlprin1(expr,file)
  LVAL expr,file;
{
    print(file,expr,TRUE,0);
}

/* xlprinc - print an expression without quoting */
xlprinc(expr,file)
  LVAL expr,file;
{
    print(file,expr,FALSE,0);
}

/* xlterpri - terminate the current print line */
xlterpri(fptr)
  LVAL fptr;
{
    xlputc(fptr,'\n');
}

/* xlputstr - output a string */
xlputstr(fptr,str)
  LVAL fptr; char *str;
{
    while (*str)
	xlputc(fptr,*str++);
}

/* print - internal print routine */
LOCAL print(fptr,vptr,escflag,depth)
  LVAL fptr,vptr; int escflag,depth;
{
    int breadth,size,i;
    LVAL nptr,next;

    /* print nil */
    if (vptr == NIL) {
	xlputstr(fptr,"()");
	return;
    }

    /* check value type */
    switch (ntype(vptr)) {
    case SUBR:
    case XSUBR:
	    putsubr(fptr,"Subr",vptr);
	    break;
    case CSUBR:
	    putsubr(fptr,"CSubr",vptr);
	    break;
    case CONS:
	    if (prdepth >= 0 && depth >= prdepth) {
		xlputstr(fptr,"(...)");
		break;
	    }
	    xlputc(fptr,'(');
	    breadth = 0;
	    for (nptr = vptr; nptr != NIL; nptr = next) {
		if (prbreadth >= 0 && breadth++ >= prbreadth) {
		    xlputstr(fptr,"...");
		    break;
		}
	        print(fptr,car(nptr),escflag,depth+1);
		if (next = cdr(nptr))
		    if (consp(next))
			xlputc(fptr,' ');
		    else {
			xlputstr(fptr," . ");
			print(fptr,next,escflag,depth+1);
			break;
		    }
	    }
	    xlputc(fptr,')');
	    break;
    case VECTOR:
	    xlputstr(fptr,"#(");
	    for (i = 0, size = getsize(vptr); i < size; ++i) {
		if (i != 0) xlputc(fptr,' ');
		print(fptr,getelement(vptr,i),escflag,depth+1);
	    }
	    xlputc(fptr,')');
	    break;
    case OBJECT:
	    putatm(fptr,"Object",vptr);
	    break;
    case SYMBOL:
	    putsym(fptr,getstring(getpname(vptr)),escflag);
	    break;
    case PROMISE:
	    if (getpproc(vptr) != NIL)
		putatm(fptr,"Promise",vptr);
	    else
		putatm(fptr,"Forced-promise",vptr);
	    break;
    case CLOSURE:
	    putclosure(fptr,"Procedure",vptr);
	    break;
    case METHOD:
	    putclosure(fptr,"Method",vptr);
	    break;
    case FIXNUM:
	    putnumber(fptr,getfixnum(vptr));
	    break;
    case FLONUM:
	    putflonum(fptr,getflonum(vptr));
	    break;
    case CHAR:
	    if (escflag)
		putcharacter(fptr,getchcode(vptr));
	    else
		xlputc(fptr,getchcode(vptr));
	    break;
    case STRING:
	    if (escflag)
	        putstring(fptr,getstring(vptr));
	    else
	        xlputstr(fptr,getstring(vptr));
	    break;
    case PORT:
	    putatm(fptr,"Port",vptr);
	    break;
    case CODE:
	    putcode(fptr,"Code",vptr);
	    break;
    case CONTINUATION:
	    putatm(fptr,"Escape-procedure",vptr);
	    break;
    case ENV:
	    putatm(fptr,"Environment",vptr);
	    break;
    case FREE:
	    putatm(fptr,"Free",vptr);
	    break;
    default:
	    putatm(fptr,"Foo",vptr);
	    break;
    }
}

/* putatm - output an atom */
LOCAL putatm(fptr,tag,val)
  LVAL fptr; char *tag; LVAL val;
{
    sprintf(buf,"#<%s #",tag); xlputstr(fptr,buf);
    sprintf(buf,AFMT,val); xlputstr(fptr,buf);
    xlputc(fptr,'>');
}

/* putconstant - output a constant */
LOCAL putconstant(fptr,tag,sym,escflag)
  LVAL fptr; char *tag,*sym; int escflag;
{
    xlputstr(fptr,tag);
    putsym(fptr,sym,escflag);
}

/* putstring - output a string */
LOCAL putstring(fptr,str)
  LVAL fptr; char *str;
{
    int ch;

    /* output the initial quote */
    xlputc(fptr,'"');

    /* output each character in the string */
    while (ch = *str++)

	/* check for a control character */
	if (ch < 040 || ch == '\\' || ch == '"') {
	    xlputc(fptr,'\\');
	    switch (ch) {
	    case '\033':
		    xlputc(fptr,'e');
		    break;
	    case '\n':
		    xlputc(fptr,'n');
		    break;
	    case '\r':
		    xlputc(fptr,'r');
		    break;
	    case '\t':
		    xlputc(fptr,'t');
		    break;
	    case '\\':
	    case '"':
		    xlputc(fptr,ch);
		    break;
	    default:
		    putoct(fptr,ch);
		    break;
	    }
	}

	/* output a normal character */
	else
	    xlputc(fptr,ch);

    /* output the terminating quote */
    xlputc(fptr,'"');
}

/* putsym - output a symbol */
LOCAL putsym(fptr,str,escflag)
  LVAL fptr; char *str; int escflag;
{
    int ch;

    /* check for printing without escapes */
    if (!escflag) {
	xlputstr(fptr,str);
	return;
    }

    /* output each character */
    if (getvalue(s_printcase) == k_downcase) {
	while ((ch = *str++) != '\0')
	    xlputc(fptr,isupper(ch) ? tolower(ch) : ch);
    }
    else {
	while ((ch = *str++) != '\0')
	    xlputc(fptr,islower(ch) ? toupper(ch) : ch);
    }
}

/* putsubr - output a subr/fsubr */
LOCAL putsubr(fptr,tag,val)
  LVAL fptr; char *tag; LVAL val;
{
    extern FUNDEF funtab[];
    sprintf(buf,"#<%s %s>",tag,funtab[getoffset(val)].fd_name);
    xlputstr(fptr,buf);
}

/* putclosure - output a closure */
LOCAL putclosure(fptr,tag,val)
  LVAL fptr; char *tag; LVAL val;
{
    putcode(fptr,tag,getcode(val));
}

/* putcode - output a code object */
LOCAL putcode(fptr,tag,val)
  LVAL fptr; char *tag; LVAL val;
{
    LVAL name;
    if (name = getelement(val,1)) {
	sprintf(buf,"#<%s %s>",tag,getstring(getpname(name)));
	xlputstr(fptr,buf);
    }
    else
	putatm(fptr,tag,val);
}

/* putnumber - output a number */
LOCAL putnumber(fptr,n)
  LVAL fptr; FIXTYPE n;
{
    LVAL fmt = getvalue(s_fixfmt);
    sprintf(buf,(stringp(fmt) ? (char *)getstring(fmt) : IFMT),n);
    xlputstr(fptr,buf);
}

/* putoct - output an octal byte value */
LOCAL putoct(fptr,n)
  LVAL fptr; int n;
{
    sprintf(buf,"%03o",n);
    xlputstr(fptr,buf);
}

/* putflonum - output a flonum */
LOCAL putflonum(fptr,n)
  LVAL fptr; FLOTYPE n;
{
    LVAL fmt = getvalue(s_flofmt);
    sprintf(buf,(stringp(fmt) ? (char *)getstring(fmt) : FFMT),n);
    xlputstr(fptr,buf);
}

/* putcharacter - output a character value */
LOCAL putcharacter(fptr,ch)
  LVAL fptr; int ch;
{
    switch (ch) {
    case '\n':
	xlputstr(fptr,"#\\Newline");
	break;
    case ' ':
	xlputstr(fptr,"#\\Space");
	break;
    default:
	sprintf(buf,"#\\%c",ch);
	xlputstr(fptr,buf);
	break;
    }
}

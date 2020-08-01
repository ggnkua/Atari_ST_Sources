/* xlfio.c - xlisp file i/o */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern LVAL k_direction,k_input,k_output;
extern LVAL s_stdin,s_stdout,true;
extern unsigned char buf[];
extern int xlfsize;

/* external routines */
extern FILE *osaopen();

/* forward declarations */
FORWARD LVAL getstroutput();
FORWARD LVAL printit();
FORWARD LVAL flatsize();
FORWARD LVAL openit();

/* xread - read an expression */
LVAL xread()
{
    LVAL fptr,eof,rflag,val;

    /* get file pointer and eof value */
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdin));
    eof = (moreargs() ? xlgetarg() : NIL);
    rflag = (moreargs() ? xlgetarg() : NIL);
    xllastarg();

    /* read an expression */
    if (!xlread(fptr,&val,rflag != NIL))
	val = eof;

    /* return the expression */
    return (val);
}

/* xprint - built-in function 'print' */
LVAL xprint()
{
    return (printit(TRUE,TRUE));
}

/* xprin1 - built-in function 'prin1' */
LVAL xprin1()
{
    return (printit(TRUE,FALSE));
}

/* xprinc - built-in function princ */
LVAL xprinc()
{
    return (printit(FALSE,FALSE));
}

/* xterpri - terminate the current print line */
LVAL xterpri()
{
    LVAL fptr;

    /* get file pointer */
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdout));
    xllastarg();

    /* terminate the print line and return nil */
    xlterpri(fptr);
    return (NIL);
}

/* printit - common print function */
LOCAL LVAL printit(pflag,tflag)
  int pflag,tflag;
{
    LVAL fptr,val;

    /* get expression to print and file pointer */
    val = xlgetarg();
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdout));
    xllastarg();

    /* print the value */
    xlprint(fptr,val,pflag);

    /* terminate the print line if necessary */
    if (tflag)
	xlterpri(fptr);

    /* return the result */
    return (val);
}

/* xflatsize - compute the size of a printed representation using prin1 */
LVAL xflatsize()
{
    return (flatsize(TRUE));
}

/* xflatc - compute the size of a printed representation using princ */
LVAL xflatc()
{
    return (flatsize(FALSE));
}

/* flatsize - compute the size of a printed expression */
LOCAL LVAL flatsize(pflag)
  int pflag;
{
    LVAL val;

    /* get the expression */
    val = xlgetarg();
    xllastarg();

    /* print the value to compute its size */
    xlfsize = 0;
    xlprint(NIL,val,pflag);

    /* return the length of the expression */
    return (cvfixnum((FIXTYPE)xlfsize));
}

/* xopen - open a file */
LVAL xopen()
{
    char *name,*mode;
    FILE *fp;
    LVAL dir;

    /* get the file name and direction */
    name = (char *)getstring(xlgetfname());
    if (!xlgetkeyarg(k_direction,&dir))
	dir = k_input;

    /* get the mode */
    if (dir == k_input)
	mode = "r";
    else if (dir == k_output)
	mode = "w";
    else
	xlerror("bad direction",dir);

    /* try to open the file */
    return ((fp = osaopen(name,mode)) ? cvfile(fp) : NIL);
}

/* xclose - close a file */
LVAL xclose()
{
    LVAL fptr;

    /* get file pointer */
    fptr = xlgastream();
    xllastarg();

    /* make sure the file exists */
    if (getfile(fptr) == NULL)
	xlfail("file not open");

    /* close the file */
    osclose(getfile(fptr));
    setfile(fptr,NULL);

    /* return nil */
    return (NIL);
}

/* xrdchar - read a character from a file */
LVAL xrdchar()
{
    LVAL fptr;
    int ch;

    /* get file pointer */
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdin));
    xllastarg();

    /* get character and check for eof */
    return ((ch = xlgetc(fptr)) == EOF ? NIL : cvchar(ch));
}

/* xrdbyte - read a byte from a file */
LVAL xrdbyte()
{
    LVAL fptr;
    int ch;

    /* get file pointer */
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdin));
    xllastarg();

    /* get character and check for eof */
    return ((ch = xlgetc(fptr)) == EOF ? NIL : cvfixnum((FIXTYPE)ch));
}

/* xpkchar - peek at a character from a file */
LVAL xpkchar()
{
    LVAL flag,fptr;
    int ch;

    /* peek flag and get file pointer */
    flag = (moreargs() ? xlgetarg() : NIL);
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdin));
    xllastarg();

    /* skip leading white space and get a character */
    if (flag)
	while ((ch = xlpeek(fptr)) != EOF && isspace(ch))
	    xlgetc(fptr);
    else
	ch = xlpeek(fptr);

    /* return the character */
    return (ch == EOF ? NIL : cvchar(ch));
}

/* xwrchar - write a character to a file */
LVAL xwrchar()
{
    LVAL fptr,chr;

    /* get the character and file pointer */
    chr = xlgachar();
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdout));
    xllastarg();

    /* put character to the file */
    xlputc(fptr,getchcode(chr));

    /* return the character */
    return (chr);
}

/* xwrbyte - write a byte to a file */
LVAL xwrbyte()
{
    LVAL fptr,chr;

    /* get the byte and file pointer */
    chr = xlgafixnum();
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdout));
    xllastarg();

    /* put byte to the file */
    xlputc(fptr,(int)getfixnum(chr));

    /* return the character */
    return (chr);
}

/* xreadline - read a line from a file */
LVAL xreadline()
{
    unsigned char buf[STRMAX+1],*p,*sptr;
    LVAL fptr,str,newstr;
    int len,blen,ch;

    /* protect some pointers */
    xlsave1(str);

    /* get file pointer */
    fptr = (moreargs() ? xlgetfile() : getvalue(s_stdin));
    xllastarg();

    /* get character and check for eof */
    len = blen = 0; p = buf;
    while ((ch = xlgetc(fptr)) != EOF && ch != '\n') {

	/* check for buffer overflow */
	if (blen >= STRMAX) {
 	    newstr = newstring(len + STRMAX + 1);
	    sptr = getstring(newstr); *sptr = '\0';
	    if (str) strcat(sptr,getstring(str));
	    *p = '\0'; strcat(sptr,buf);
	    p = buf; blen = 0;
	    len += STRMAX;
	    str = newstr;
	}

	/* store the character */
	*p++ = ch; ++blen;
    }

    /* check for end of file */
    if (len == 0 && p == buf && ch == EOF) {
	xlpop();
	return (NIL);
    }

    /* append the last substring */
    if (str == NIL || blen) {
	newstr = newstring(len + blen + 1);
	sptr = getstring(newstr); *sptr = '\0';
	if (str) strcat(sptr,getstring(str));
	*p = '\0'; strcat(sptr,buf);
	str = newstr;
    }

    /* restore the stack */
    xlpop();

    /* return the string */
    return (str);
}


/* xmkstrinput - make a string input stream */
LVAL xmkstrinput()
{
    int start,end,len,i;
    unsigned char *str;
    LVAL string,val;

    /* protect the return value */
    xlsave1(val);
    
    /* get the string and length */
    string = xlgastring();
    str = getstring(string);
    len = getslength(string) - 1;

    /* get the starting offset */
    if (moreargs()) {
	val = xlgafixnum();
	start = (int)getfixnum(val);
    }
    else start = 0;

    /* get the ending offset */
    if (moreargs()) {
	val = xlgafixnum();
	end = (int)getfixnum(val);
    }
    else end = len;
    xllastarg();

    /* check the bounds */
    if (start < 0 || start > len)
	xlerror("string index out of bounds",cvfixnum((FIXTYPE)start));
    if (end < 0 || end > len)
	xlerror("string index out of bounds",cvfixnum((FIXTYPE)end));

    /* make the stream */
    val = newustream();

    /* copy the substring into the stream */
    for (i = start; i < end; ++i)
	xlputc(val,str[i]);

    /* restore the stack */
    xlpop();

    /* return the new stream */
    return (val);
}

/* xmkstroutput - make a string output stream */
LVAL xmkstroutput()
{
    return (newustream());
}

/* xgetstroutput - get output stream string */
LVAL xgetstroutput()
{
    LVAL stream;
    stream = xlgaustream();
    xllastarg();
    return (getstroutput(stream));
}

/* xgetlstoutput - get output stream list */
LVAL xgetlstoutput()
{
    LVAL stream,val;

    /* get the stream */
    stream = xlgaustream();
    xllastarg();

    /* get the output character list */
    val = gethead(stream);

    /* empty the character list */
    sethead(stream,NIL);
    settail(stream,NIL);

    /* return the list */
    return (val);
}

/* xformat - formatted output function */
LVAL xformat()
{
    LVAL fmtstring,stream,val;
    unsigned char *fmt;
    int ch;

    /* protect some pointers */
    xlstkcheck(2);
    xlsave(fmtstring);
    xlsave(stream);

    /* get the stream and format string */
    stream = xlgetarg();
    if (stream == NIL)
	val = stream = newustream();
    else {
	if (stream == true)
	    stream = getvalue(s_stdout);
	else if (!streamp(stream) && !ustreamp(stream))
	    xlbadtype(stream);
	val = NIL;
    }
    fmtstring = xlgastring();
    fmt = getstring(fmtstring);

    /* process the format string */
    while (ch = *fmt++)
	if (ch == '~') {
	    switch (*fmt++) {
	    case '\0':
		xlerror("expecting a format directive",cvstring(fmt-1));
	    case 'a': case 'A':
		xlprint(stream,xlgetarg(),FALSE);
		break;
	    case 's': case 'S':
		xlprint(stream,xlgetarg(),TRUE);
		break;
	    case '%':
		xlterpri(stream);
		break;
	    case '~':
		xlputc(stream,'~');
		break;
	    case '\n':
		while (*fmt && *fmt != '\n' && isspace(*fmt))
		    ++fmt;
		break;
	    default:
		xlerror("unknown format directive",cvstring(fmt-1));
	    }
	}
	else
	    xlputc(stream,ch);
    
    /* get the output string for a stream argument of NIL */
    if (val) val = getstroutput(val);
    xlpopn(2);
        
    /* return the value */
    return (val);
}

/* getstroutput - get the output stream string (internal) */
LOCAL LVAL getstroutput(stream)
  LVAL stream;
{
    unsigned char *str;
    LVAL next,val;
    int len,ch;

    /* compute the length of the stream */
    for (len = 0, next = gethead(stream); next != NIL; next = cdr(next))
	++len;

    /* create a new string */
    val = newstring(len + 1);
    
    /* copy the characters into the new string */
    str = getstring(val);
    while ((ch = xlgetc(stream)) != EOF)
	*str++ = ch;
    *str = '\0';

    /* return the string */
    return (val);
}


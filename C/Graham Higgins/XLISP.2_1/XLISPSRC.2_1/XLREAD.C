/* xlread - xlisp expression input routine */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* symbol parser modes */
#define DONE	0
#define NORMAL	1
#define ESCAPE	2

/* external variables */
extern LVAL s_stdout,true,s_dot;
extern LVAL s_quote,s_function,s_bquote,s_comma,s_comat;
extern LVAL s_rtable,k_wspace,k_const,k_nmacro,k_tmacro;
extern LVAL k_sescape,k_mescape;
extern char buf[];

/* external routines */
extern FILE *osaopen();
extern double atof();
extern ITYPE;

#define WSPACE "\t \f\r\n"
#define CONST1 "!$%&*+-./0123456789:<=>?@[]^_{}~"
#define CONST2 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

/* forward declarations */
FORWARD LVAL callmacro();
FORWARD LVAL psymbol(),punintern();
FORWARD LVAL pnumber(),pquote(),plist(),pvector(),pstruct();
FORWARD LVAL readlist(),tentry();

/* xlload - load a file of xlisp expressions */
int xlload(fname,vflag,pflag)
  char *fname; int vflag,pflag;
{
    char fullname[STRMAX+1];
    LVAL fptr,expr;
    CONTEXT cntxt;
    FILE *fp;
    int sts;

    /* protect some pointers */
    xlstkcheck(2);
    xlsave(fptr);
    xlsave(expr);

    /* default the extension */
    if (needsextension(fname)) {
	strcpy(fullname,fname);
	strcat(fullname,".lsp");
	fname = fullname;
    }

    /* allocate a file node */
    fptr = cvfile(NULL);

    /* open the file */
    if ((fp = osaopen(fname,"r")) == NULL) {
	xlpopn(2);
	return (FALSE);
    }
    setfile(fptr,fp);

    /* print the information line */
    if (vflag)
	{ sprintf(buf,"; loading \"%s\"\n",fname); stdputstr(buf); }

    /* read, evaluate and possibly print each expression in the file */
    xlbegin(&cntxt,CF_ERROR,true);
    if (setjmp(cntxt.c_jmpbuf))
	sts = FALSE;
    else {
	while (xlread(fptr,&expr,FALSE)) {
	    expr = xleval(expr);
	    if (pflag)
		stdprint(expr);
	}
	sts = TRUE;
    }
    xlend(&cntxt);

    /* close the file */
    osclose(getfile(fptr));
    setfile(fptr,NULL);

    /* restore the stack */
    xlpopn(2);

    /* return status */
    return (sts);
}

/* xlread - read an xlisp expression */
int xlread(fptr,pval,rflag)
  LVAL fptr,*pval; int rflag;
{
    int sts;

    /* read an expression */
    while ((sts = readone(fptr,pval)) == FALSE)
	;

    /* return status */
    return (sts == EOF ? FALSE : TRUE);
}

/* readone - attempt to read a single expression */
int readone(fptr,pval)
  LVAL fptr,*pval;
{
    LVAL val,type;
    int ch;

    /* get a character and check for EOF */
    if ((ch = xlgetc(fptr)) == EOF)
	return (EOF);

    /* handle white space */
    if ((type = tentry(ch)) == k_wspace)
	return (FALSE);

    /* handle symbol constituents */
    else if (type == k_const) {
	xlungetc(fptr,ch);
	*pval = psymbol(fptr);
	return (TRUE);	    
    }

    /* handle single and multiple escapes */
    else if (type == k_sescape || type == k_mescape) {
	xlungetc(fptr,ch);
	*pval = psymbol(fptr);
	return (TRUE);
    }
    
    /* handle read macros */
    else if (consp(type)) {
	if ((val = callmacro(fptr,ch)) && consp(val)) {
	    *pval = car(val);
	    return (TRUE);
	}
	else
	    return (FALSE);
    }

    /* handle illegal characters */
    else
	xlerror("illegal character",cvfixnum((FIXTYPE)ch));
}

/* rmhash - read macro for '#' */
LVAL rmhash()
{
    LVAL fptr,mch,val;
    int escflag,ch;

    /* protect some pointers */
    xlsave1(val);

    /* get the file and macro character */
    fptr = xlgetfile();
    mch = xlgachar();
    xllastarg();

    /* make the return value */
    val = consa(NIL);

    /* check the next character */
    switch (ch = xlgetc(fptr)) {
    case '\'':
		rplaca(val,pquote(fptr,s_function));
		break;
    case '(':
		xlungetc(fptr,ch);
		rplaca(val,pvector(fptr));
		break;
    case 'b':
    case 'B':
		rplaca(val,pnumber(fptr,2));
		break;
    case 'o':
    case 'O':
		rplaca(val,pnumber(fptr,8));
		break;
    case 'x':
    case 'X':
    		rplaca(val,pnumber(fptr,16));
		break;
    case 's':
    case 'S':
		rplaca(val,pstruct(fptr));
		break;
    case '\\':
		xlungetc(fptr,ch);
		pname(fptr,&escflag);
		ch = buf[0];
		if (strlen(buf) > 1) {
		    upcase(buf);
		    if (strcmp(buf,"NEWLINE") == 0)
			ch = '\n';
		    else if (strcmp(buf,"SPACE") == 0)
			ch = ' ';
		    else
			xlerror("unknown character name",cvstring(buf));
		}
		rplaca(val,cvchar(ch));
		break;
    case ':':
	        rplaca(val,punintern(fptr));
		break;
    case '|':
    		pcomment(fptr);
		val = NIL;
		break;
    default:
		xlerror("illegal character after #",cvfixnum((FIXTYPE)ch));
    }

    /* restore the stack */
    xlpop();

    /* return the value */
    return (val);
}

/* rmquote - read macro for '\'' */
LVAL rmquote()
{
    LVAL fptr,mch;

    /* get the file and macro character */
    fptr = xlgetfile();
    mch = xlgachar();
    xllastarg();

    /* parse the quoted expression */
    return (consa(pquote(fptr,s_quote)));
}

/* rmdquote - read macro for '"' */
LVAL rmdquote()
{
    unsigned char buf[STRMAX+1],*p,*sptr;
    LVAL fptr,str,newstr,mch;
    int len,blen,ch,d2,d3;

    /* protect some pointers */
    xlsave1(str);

    /* get the file and macro character */
    fptr = xlgetfile();
    mch = xlgachar();
    xllastarg();

    /* loop looking for a closing quote */
    len = blen = 0; p = buf;
    while ((ch = checkeof(fptr)) != '"') {

	/* handle escaped characters */
	switch (ch) {
	case '\\':
		switch (ch = checkeof(fptr)) {
		case 't':
			ch = '\011';
			break;
		case 'n':
			ch = '\012';
			break;
		case 'f':
			ch = '\014';
			break;
		case 'r':
			ch = '\015';
			break;
		default:
			if (ch >= '0' && ch <= '7') {
			    d2 = checkeof(fptr);
			    d3 = checkeof(fptr);
			    if (d2 < '0' || d2 > '7'
			     || d3 < '0' || d3 > '7')
				xlfail("invalid octal digit");
			    ch -= '0'; d2 -= '0'; d3 -= '0';
			    ch = (ch << 6) | (d2 << 3) | d3;
			}
			break;
		}
	}

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

    /* return the new string */
    return (consa(str));
}

/* rmbquote - read macro for '`' */
LVAL rmbquote()
{
    LVAL fptr,mch;

    /* get the file and macro character */
    fptr = xlgetfile();
    mch = xlgachar();
    xllastarg();

    /* parse the quoted expression */
    return (consa(pquote(fptr,s_bquote)));
}

/* rmcomma - read macro for ',' */
LVAL rmcomma()
{
    LVAL fptr,mch,sym;
    int ch;

    /* get the file and macro character */
    fptr = xlgetfile();
    mch = xlgachar();
    xllastarg();

    /* check the next character */
    if ((ch = xlgetc(fptr)) == '@')
	sym = s_comat;
    else {
	xlungetc(fptr,ch);
	sym = s_comma;
    }

    /* make the return value */
    return (consa(pquote(fptr,sym)));
}

/* rmlpar - read macro for '(' */
LVAL rmlpar()
{
    LVAL fptr,mch;

    /* get the file and macro character */
    fptr = xlgetfile();
    mch = xlgachar();
    xllastarg();

    /* make the return value */
    return (consa(plist(fptr)));
}

/* rmrpar - read macro for ')' */
LVAL rmrpar()
{
    xlfail("misplaced right paren");
}

/* rmsemi - read macro for ';' */
LVAL rmsemi()
{
    LVAL fptr,mch;
    int ch;

    /* get the file and macro character */
    fptr = xlgetfile();
    mch = xlgachar();
    xllastarg();

    /* skip to end of line */
    while ((ch = xlgetc(fptr)) != EOF && ch != '\n')
	;

    /* return nil (nothing read) */
    return (NIL);
}

/* pcomment - parse a comment delimited by #| and |# */
LOCAL pcomment(fptr)
  LVAL fptr;
{
    int lastch,ch,n;

    /* look for the matching delimiter (and handle nesting) */
    for (n = 1, lastch = -1; n > 0 && (ch = xlgetc(fptr)) != EOF; ) {
	if (lastch == '|' && ch == '#')
	    { --n; ch = -1; }
	else if (lastch == '#' && ch == '|')
	    { ++n; ch = -1; }
	lastch = ch;
    }
}

/* pnumber - parse a number */
LOCAL LVAL pnumber(fptr,radix)
  LVAL fptr; int radix;
{
    int digit,ch;
    long num;
    
    for (num = 0L; (ch = xlgetc(fptr)) != EOF; ) {
	if (islower(ch)) ch = toupper(ch);
	if (!('0' <= ch && ch <= '9') && !('A' <= ch && ch <= 'F'))
	    break;
	if ((digit = (ch <= '9' ? ch - '0' : ch - 'A' + 10)) >= radix)
	    break;
	num = num * (long)radix + (long)digit;
    }
    xlungetc(fptr,ch);
    return (cvfixnum((FIXTYPE)num));
}

/* plist - parse a list */
LOCAL LVAL plist(fptr)
  LVAL fptr;
{
    LVAL val,expr,lastnptr,nptr;

    /* protect some pointers */
    xlstkcheck(2);
    xlsave(val);
    xlsave(expr);

    /* keep appending nodes until a closing paren is found */
    for (lastnptr = NIL; nextch(fptr) != ')'; )

	/* get the next expression */
	switch (readone(fptr,&expr)) {
	case EOF:
	    badeof(fptr);
	case TRUE:

	    /* check for a dotted tail */
	    if (expr == s_dot) {

		/* make sure there's a node */
		if (lastnptr == NIL)
		    xlfail("invalid dotted pair");

		/* parse the expression after the dot */
		if (!xlread(fptr,&expr,TRUE))
		    badeof(fptr);
		rplacd(lastnptr,expr);

		/* make sure its followed by a close paren */
		if (nextch(fptr) != ')')
		    xlfail("invalid dotted pair");
	    }

	    /* otherwise, handle a normal list element */
	    else {
		nptr = consa(expr);
		if (lastnptr == NIL)
		    val = nptr;
		else
		    rplacd(lastnptr,nptr);
		lastnptr = nptr;
	    }
	    break;
	}

    /* skip the closing paren */
    xlgetc(fptr);

    /* restore the stack */
    xlpopn(2);

    /* return successfully */
    return (val);
}

/* pvector - parse a vector */
LOCAL LVAL pvector(fptr)
  LVAL fptr;
{
    LVAL list,val;
    int len,i;

    /* protect some pointers */
    xlsave1(list);

    /* read the list */
    list = readlist(fptr,&len);

    /* make a vector of the appropriate length */
    val = newvector(len);

    /* copy the list into the vector */
    for (i = 0; i < len; ++i, list = cdr(list))
	setelement(val,i,car(list));

    /* restore the stack */
    xlpop();

    /* return successfully */
    return (val);
}

/* pstruct - parse a structure */
LOCAL LVAL pstruct(fptr)
  LVAL fptr;
{
    extern LVAL xlrdstruct();
    LVAL list,val;
    int len;

    /* protect some pointers */
    xlsave1(list);

    /* read the list */
    list = readlist(fptr,&len);

    /* make the structure */
    val = xlrdstruct(list);

    /* restore the stack */
    xlpop();

    /* return successfully */
    return (val);
}

/* pquote - parse a quoted expression */
LOCAL LVAL pquote(fptr,sym)
  LVAL fptr,sym;
{
    LVAL val,p;

    /* protect some pointers */
    xlsave1(val);

    /* allocate two nodes */
    val = consa(sym);
    rplacd(val,consa(NIL));

    /* initialize the second to point to the quoted expression */
    if (!xlread(fptr,&p,TRUE))
	badeof(fptr);
    rplaca(cdr(val),p);

    /* restore the stack */
    xlpop();

    /* return the quoted expression */
    return (val);
}

/* psymbol - parse a symbol name */
LOCAL LVAL psymbol(fptr)
  LVAL fptr;
{
    int escflag;
    LVAL val;
    pname(fptr,&escflag);
    return (escflag || !isnumber(buf,&val) ? xlenter(buf) : val);
}

/* punintern - parse an uninterned symbol */
LOCAL LVAL punintern(fptr)
  LVAL fptr;
{
    int escflag;
    pname(fptr,&escflag);
    return (xlmakesym(buf));
}

/* pname - parse a symbol/package name */
LOCAL int pname(fptr,pescflag)
  LVAL fptr; int *pescflag;
{
    int mode,ch,i;
    LVAL type;

    /* initialize */
    *pescflag = FALSE;
    mode = NORMAL;
    i = 0;

    /* accumulate the symbol name */
    while (mode != DONE) {

	/* handle normal mode */
	while (mode == NORMAL)
	    if ((ch = xlgetc(fptr)) == EOF)
		mode = DONE;
	    else if ((type = tentry(ch)) == k_sescape) {
		i = storech(buf,i,checkeof(fptr));
		*pescflag = TRUE;
	    }
	    else if (type == k_mescape) {
		*pescflag = TRUE;
		mode = ESCAPE;
	    }
	    else if (type == k_const
		 ||  (consp(type) && car(type) == k_nmacro))
		i = storech(buf,i,islower(ch) ? toupper(ch) : ch);
	    else
		mode = DONE;

	/* handle multiple escape mode */
	while (mode == ESCAPE)
	    if ((ch = xlgetc(fptr)) == EOF)
		badeof(fptr);
	    else if ((type = tentry(ch)) == k_sescape)
		i = storech(buf,i,checkeof(fptr));
	    else if (type == k_mescape)
		mode = NORMAL;
	    else
		i = storech(buf,i,ch);
    }
    buf[i] = 0;

    /* check for a zero length name */
    if (i == 0)
	xlerror("zero length name");

    /* unget the last character and return it */
    xlungetc(fptr,ch);
    return (ch);
}

/* readlist - read a list terminated by a ')' */
LOCAL LVAL readlist(fptr,plen)
  LVAL fptr; int *plen;
{
    LVAL list,expr,lastnptr,nptr;
    int ch;

    /* protect some pointers */
    xlstkcheck(2);
    xlsave(list);
    xlsave(expr);

    /* get the open paren */
    if ((ch = nextch(fptr)) != '(')
	xlfail("expecting an open paren");
    xlgetc(fptr);

    /* keep appending nodes until a closing paren is found */
    for (lastnptr = NIL, *plen = 0; (ch = nextch(fptr)) != ')'; ) {

	/* check for end of file */
	if (ch == EOF)
	    badeof(fptr);

	/* get the next expression */
	switch (readone(fptr,&expr)) {
	case EOF:
	    badeof(fptr);
	case TRUE:
	    nptr = consa(expr);
	    if (lastnptr == NIL)
		list = nptr;
	    else
		rplacd(lastnptr,nptr);
	    lastnptr = nptr;
	    ++(*plen);
	    break;
	}
    }

    /* skip the closing paren */
    xlgetc(fptr);

    /* restore the stack */
    xlpopn(2);

    /* return the list */
    return (list);
}

/* storech - store a character in the print name buffer */
LOCAL int storech(buf,i,ch)
  char *buf; int i,ch;
{
    if (i < STRMAX)
	buf[i++] = ch;
    return (i);
}

/* tentry - get a readtable entry */
LVAL tentry(ch)
  int ch;
{
    LVAL rtable;
    rtable = getvalue(s_rtable);
    if (!vectorp(rtable) || ch < 0 || ch >= getsize(rtable))
	return (NIL);
    return (getelement(rtable,ch));
}

/* nextch - look at the next non-blank character */
LOCAL int nextch(fptr)
  LVAL fptr;
{
    int ch;

    /* return and save the next non-blank character */
    while ((ch = xlgetc(fptr)) != EOF && isspace(ch))
	;
    xlungetc(fptr,ch);
    return (ch);
}

/* checkeof - get a character and check for end of file */
LOCAL int checkeof(fptr)
  LVAL fptr;
{
    int ch;

    if ((ch = xlgetc(fptr)) == EOF)
	badeof(fptr);
    return (ch);
}

/* badeof - unexpected eof */
LOCAL badeof(fptr)
  LVAL fptr;
{
    xlgetc(fptr);
    xlfail("unexpected EOF");
}

/* isnumber - check if this string is a number */
int isnumber(str,pval)
  char *str; LVAL *pval;
{
    int dl,dr;
    char *p;

    /* initialize */
    p = str; dl = dr = 0;

    /* check for a sign */
    if (*p == '+' || *p == '-')
	p++;

    /* check for a string of digits */
    while (isdigit(*p))
	p++, dl++;

    /* check for a decimal point */
    if (*p == '.') {
	p++;
	while (isdigit(*p))
	    p++, dr++;
    }

    /* check for an exponent */
    if ((dl || dr) && *p == 'E') {
	p++;

	/* check for a sign */
	if (*p == '+' || *p == '-')
	    p++;

	/* check for a string of digits */
	while (isdigit(*p))
	    p++, dr++;
    }

    /* make sure there was at least one digit and this is the end */
    if ((dl == 0 && dr == 0) || *p)
	return (FALSE);

    /* convert the string to an integer and return successfully */
    if (pval) {
	if (*str == '+') ++str;
	if (str[strlen(str)-1] == '.') str[strlen(str)-1] = 0;
	*pval = (dr ? cvflonum(atof(str)) : cvfixnum(ICNV(str)));
    }
    return (TRUE);
}

/* defmacro - define a read macro */
defmacro(ch,type,offset)
  int ch; LVAL type; int offset;
{
    extern FUNDEF funtab[];
    LVAL subr;
    subr = cvsubr(funtab[offset].fd_subr,funtab[offset].fd_type,offset);
    setelement(getvalue(s_rtable),ch,cons(type,subr));
}

/* callmacro - call a read macro */
LVAL callmacro(fptr,ch)
  LVAL fptr; int ch;
{
    LVAL *newfp;

    /* create the new call frame */
    newfp = xlsp;
    pusharg(cvfixnum((FIXTYPE)(newfp - xlfp)));
    pusharg(cdr(getelement(getvalue(s_rtable),ch)));
    pusharg(cvfixnum((FIXTYPE)2));
    pusharg(fptr);
    pusharg(cvchar(ch));
    xlfp = newfp;
    return (xlapply(2));
}

/* upcase - translate a string to upper case */
LOCAL upcase(str)
  unsigned char *str;
{
    for (; *str != '\0'; ++str)
	if (islower(*str))
	    *str = toupper(*str);
}

/* xlrinit - initialize the reader */
xlrinit()
{
    LVAL rtable;
    char *p;
    int ch;

    /* create the read table */
    rtable = newvector(256);
    setvalue(s_rtable,rtable);

    /* initialize the readtable */
    for (p = WSPACE; ch = *p++; )
	setelement(rtable,ch,k_wspace);
    for (p = CONST1; ch = *p++; )
	setelement(rtable,ch,k_const);
    for (p = CONST2; ch = *p++; )
	setelement(rtable,ch,k_const);

    /* setup the escape characters */
    setelement(rtable,'\\',k_sescape);
    setelement(rtable,'|', k_mescape);

    /* install the read macros */
    defmacro('#', k_nmacro,FT_RMHASH);
    defmacro('\'',k_tmacro,FT_RMQUOTE);
    defmacro('"', k_tmacro,FT_RMDQUOTE);
    defmacro('`', k_tmacro,FT_RMBQUOTE);
    defmacro(',', k_tmacro,FT_RMCOMMA);
    defmacro('(', k_tmacro,FT_RMLPAR);
    defmacro(')', k_tmacro,FT_RMRPAR);
    defmacro(';', k_tmacro,FT_RMSEMI);
}


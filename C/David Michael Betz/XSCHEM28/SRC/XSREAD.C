/* xsread.c - xscheme input routines */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* external variables */
extern LVAL true;

/* external routines */
extern double atof();
extern ITYPE;

/* forward declarations */
#ifdef __STDC__
static void read_cdr(LVAL fptr,LVAL last);
static void read_comment(LVAL fptr);
static LVAL read_list(LVAL fptr);
static LVAL read_vector(LVAL fptr);
static LVAL read_comma(LVAL fptr);
static LVAL read_quote(LVAL fptr,char *sym);
static LVAL read_symbol(LVAL fptr);
static LVAL read_string(LVAL fptr);
static LVAL read_special(LVAL fptr);
static LVAL read_radix(LVAL fptr,int radix);
static int isradixdigit(int ch,int radix);
static int getdigit(int ch);
static int getsymbol(LVAL fptr,char *buf);
static int isnumber(char *str,LVAL *pval);
static int scan(LVAL fptr);
static int checkeof(LVAL fptr);
static int issym(int ch);
#else
static LVAL read_list(),read_quote(),read_comma(),read_symbol();
static LVAL read_radix(),read_string(),read_special();
#endif

/* xlread - read an expression */
int xlread(fptr,pval)
  LVAL fptr,*pval;
{
    int ch;

    /* check the next non-blank character */
    while ((ch = scan(fptr)) != EOF)
	switch (ch) {
	case '(':
	    *pval = read_list(fptr);
	    return (TRUE);
	case ')':
	    xlfail("misplaced right paren");
	case '\'':
	    *pval = read_quote(fptr,"QUOTE");
	    return (TRUE);
	case '`':
	    *pval = read_quote(fptr,"QUASIQUOTE");
	    return (TRUE);
	case ',':
	    *pval = read_comma(fptr);
	    return (TRUE);
	case '"':
	    *pval = read_string(fptr);
	    return (TRUE);
	case '#':
	    *pval = read_special(fptr);
	    return (TRUE);
	case ';':
    	    read_comment(fptr);
    	    break;
	default:
	    xlungetc(fptr,ch);
	    *pval = read_symbol(fptr);
	    return (TRUE);
	}
    return (FALSE);
}

/* read_list - read a list */
static LVAL read_list(fptr)
  LVAL fptr;
{
    LVAL last,val;
    int ch;
    
    cpush(NIL); last = NIL;
    while ((ch = scan(fptr)) != EOF)
	switch (ch) {
	case ';':
	    read_comment(fptr);
	    break;
	case ')':
	    return (pop());
	default:
	    xlungetc(fptr,ch);
	    if (!xlread(fptr,&val))
		xlfail("unexpected EOF");
	    if (val == xlenter(".")) {
		if (last == NIL)
		    xlfail("misplaced dot");
		read_cdr(fptr,last);
		return (pop());
	    }
	    else {
		val = cons(val,NIL);
		if (last) rplacd(last,val);
		else settop(val);
		last = val;
	    }
	    break;
	}
    xlfail("unexpected EOF");
    return (NIL); /* never reached */
}

/* read_cdr - read the cdr of a dotted pair */
static void read_cdr(fptr,last)
  LVAL fptr,last;
{
    LVAL val;
    int ch;
    
    /* read the cdr expression */
    if (!xlread(fptr,&val))
	xlfail("unexpected EOF");
    rplacd(last,val);
    
    /* check for the close paren */
    while ((ch = scan(fptr)) == ';')
	read_comment(fptr);
    if (ch != ')')
	xlfail("missing right paren");
}

/* read_comment - read a comment (to end of line) */
static void read_comment(fptr)
  LVAL fptr;
{
    int ch;
    while ((ch = xlgetc(fptr)) != EOF && ch != '\n')
	;
    if (ch != EOF) xlungetc(fptr,ch);
}

/* read_vector - read a vector */
static LVAL read_vector(fptr)
  LVAL fptr;
{
    int len=0,ch,i;
    LVAL last,val;
    
    cpush(NIL); last = NIL;
    while ((ch = scan(fptr)) != EOF)
	switch (ch) {
	case ';':
	    read_comment(fptr);
	    break;
	case ')':
	    val = newvector(len);
	    for (last = pop(), i = 0; i < len; ++i, last = cdr(last))
		setelement(val,i,car(last));
	    return (val);
	default:
	    xlungetc(fptr,ch);
	    if (!xlread(fptr,&val))
		xlfail("unexpected EOF");
	    val = cons(val,NIL);
	    if (last) rplacd(last,val);
	    else settop(val);
	    last = val;
	    ++len;
	    break;
	}
    xlfail("unexpected EOF");
    return (NIL); /* never reached */
}

/* read_comma - read a unquote or unquote-splicing expression */
static LVAL read_comma(fptr)
  LVAL fptr;
{
    int ch;
    if ((ch = xlgetc(fptr)) == '@')
	return (read_quote(fptr,"UNQUOTE-SPLICING"));
    else {
	xlungetc(fptr,ch);
	return (read_quote(fptr,"UNQUOTE"));
    }
}

/* read_quote - parse the tail of a quoted expression */
static LVAL read_quote(fptr,sym)
  LVAL fptr; char *sym;
{
    LVAL val;
    if (!xlread(fptr,&val))
	xlfail("unexpected EOF");
    cpush(cons(val,NIL));
    settop(cons(xlenter(sym),top()));
    return (pop());
}

/* read_symbol - parse a symbol name (or a number) */
static LVAL read_symbol(fptr)
  LVAL fptr;
{
    char buf[STRMAX+1];
    LVAL val;
    if (!getsymbol(fptr,buf))
	xlfail("expecting symbol name");
    return (isnumber(buf,&val) ? val : xlenter(buf));
}

/* read_string - parse a string */
static LVAL read_string(fptr)
  LVAL fptr;
{
    char buf[STRMAX+1];
    int ch,i;

    /* get symbol name */
    for (i = 0; (ch = checkeof(fptr)) != '"'; ) {
	if (ch == '\\')
	    ch = checkeof(fptr);
	if (i < STRMAX)
	    buf[i++] = ch;
    }
    buf[i] = '\0';

    /* return a string */
    return (cvstring(buf));
}

/* read_special - parse an atom starting with '#' */
static LVAL read_special(fptr)
  LVAL fptr;
{
    char buf[STRMAX+1],buf2[STRMAX+3];
    int ch;
    switch (ch = checkeof(fptr)) {
    case '!':
	if (getsymbol(fptr,buf)) {
	    if (strcmp(buf,"TRUE") == 0)
		return (true);
	    else if (strcmp(buf,"FALSE") == 0)
		return (NIL);
	    else if (strcmp(buf,"NULL") == 0)
		return (NIL);
	    else {
		sprintf(buf2,"#!%s",buf);
		return (xlenter(buf2));
	    }
	}
	else
	    xlfail("expecting symbol after '#!'");
	break;
    case '\\':
	ch = checkeof(fptr);	/* get the next character */
	xlungetc(fptr,ch);	/* but allow getsymbol to get it also */
	if (getsymbol(fptr,buf)) {
	    if (strcmp(buf,"NEWLINE") == 0)
		ch = '\n';
	    else if (strcmp(buf,"SPACE") == 0)
		ch = ' ';
	    else if (strlen(buf) > 1)
		xlerror("unexpected symbol after '#\\'",cvstring(buf));
	}
	else			/* wasn't a symbol, get the character */
	    ch = checkeof(fptr);
	return (cvchar(ch));
    case '(':
	return (read_vector(fptr));
    case 'b':
    case 'B':
	return (read_radix(fptr,2));
    case 'o':
    case 'O':
	return (read_radix(fptr,8));
    case 'd':
    case 'D':
	return (read_radix(fptr,10));
    case 'x':
    case 'X':
        return (read_radix(fptr,16));
    default:
	xlungetc(fptr,ch);
	if (getsymbol(fptr,buf)) {
	    if (strcmp(buf,"T") == 0)
		return (true);
	    else if (strcmp(buf,"F") == 0)
		return (NIL);
	    else
		xlerror("unexpected symbol after '#'",cvstring(buf));
	}
	else
	    xlerror("unexpected character after '#'",cvchar(xlgetc(fptr)));
	break;
    }
    return (NIL); /* never reached */
}

/* read_radix - read a number in a specified radix */
static LVAL read_radix(fptr,radix)
  LVAL fptr; int radix;
{
    FIXTYPE val;
    int ch;

    /* get symbol name */
    for (val = (FIXTYPE)0; (ch = xlgetc(fptr)) != EOF && issym(ch); ) {
        if (islower(ch)) ch = toupper(ch);
	if (!isradixdigit(ch,radix))
	    xlerror("invalid digit",cvchar(ch));
        val = val * radix + getdigit(ch);
    }

    /* save the break character */
    xlungetc(fptr,ch);

    /* return the number */
    return (cvfixnum(val));
}

/* isradixdigit - check to see if a character is a digit in a radix */
static int isradixdigit(ch,radix)
  int ch,radix;
{
    switch (radix) {
    case 2:	return (ch >= '0' && ch <= '1');
    case 8:	return (ch >= '0' && ch <= '7');
    case 10:	return (ch >= '0' && ch <= '9');
    case 16:	return ((ch >= '0' && ch <= '9')
                     || (ch >= 'A' && ch <= 'F'));
    }
    return (FALSE); /* never reached */
}

/* getdigit - convert an ascii code to a digit */
static int getdigit(ch)
  int ch;
{
    return (ch <= '9' ? ch - '0' : ch - 'A' + 10);
}

/* getsymbol - get a symbol name */
static int getsymbol(fptr,buf)
  LVAL fptr; char *buf;
{
    int ch,i;

    /* get symbol name */
    for (i = 0; (ch = xlgetc(fptr)) != EOF && issym(ch); )
	if (i < STRMAX)
	    buf[i++] = (islower(ch) ? toupper(ch) : ch);
    buf[i] = '\0';

    /* save the break character */
    xlungetc(fptr,ch);
    return (buf[0] != '\0');
}

/* isnumber - check if this string is a number */
static int isnumber(str,pval)
  char *str; LVAL *pval;
{
    int dl,dot,dr;
    char *p;

    /* initialize */
    p = str; dl = dot = dr = 0;

    /* check for a sign */
    if (*p == '+' || *p == '-')
	p++;

    /* check for a string of digits */
    while (isdigit(*p))
	p++, dl++;

    /* check for a decimal point */
    if (*p == '.') {
	p++; dot = 1;
	while (isdigit(*p))
	    p++, dr++;
    }

    /* check for an exponent */
    if ((dl || dr) && *p == 'E') {
	p++; dot = 1;

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
	*pval = (dot ? cvflonum(atof(str)) : cvfixnum(ICNV(str)));
    }
    return (TRUE);
}

/* scan - scan for the first non-blank character */
static int scan(fptr)
  LVAL fptr;
{
    int ch;

    /* look for a non-blank character */
    while ((ch = xlgetc(fptr)) != EOF && isspace(ch))
	;

    /* return the character */
    return (ch);
}

/* checkeof - get a character and check for end of file */
static int checkeof(fptr)
  LVAL fptr;
{
    int ch;
    if ((ch = xlgetc(fptr)) == EOF)
	xlfail("unexpected EOF");
    return (ch);
}

/* issym - is this a symbol character? */
static int issym(ch)
  int ch;
{
    register char *p;
    if (!isspace(ch)) {
	for (p = "()';"; *p != '\0'; )
	    if (*p++ == ch)
		return (FALSE);
	return (TRUE);
    }
    return (FALSE);
}

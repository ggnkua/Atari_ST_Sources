/* xlstr - xlisp string and character built-in functions */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* local definitions */
#define fix(n)	cvfixnum((FIXTYPE)(n))
#define TLEFT	1
#define TRIGHT	2

/* external variables */
extern LVAL k_start,k_end,k_1start,k_1end,k_2start,k_2end;
extern LVAL true;
extern char buf[];

/* external procedures */
extern char *strcat();

/* forward declarations */
FORWARD LVAL strcompare();
FORWARD LVAL chrcompare();
FORWARD LVAL changecase();
FORWARD LVAL trim();

/* string comparision functions */
LVAL xstrlss() { return (strcompare('<',FALSE)); } /* string< */
LVAL xstrleq() { return (strcompare('L',FALSE)); } /* string<= */
LVAL xstreql() { return (strcompare('=',FALSE)); } /* string= */
LVAL xstrneq() { return (strcompare('#',FALSE)); } /* string/= */
LVAL xstrgeq() { return (strcompare('G',FALSE)); } /* string>= */
LVAL xstrgtr() { return (strcompare('>',FALSE)); } /* string> */

/* string comparison functions (not case sensitive) */
LVAL xstrilss() { return (strcompare('<',TRUE)); } /* string-lessp */
LVAL xstrileq() { return (strcompare('L',TRUE)); } /* string-not-greaterp */
LVAL xstrieql() { return (strcompare('=',TRUE)); } /* string-equal */
LVAL xstrineq() { return (strcompare('#',TRUE)); } /* string-not-equal */
LVAL xstrigeq() { return (strcompare('G',TRUE)); } /* string-not-lessp */
LVAL xstrigtr() { return (strcompare('>',TRUE)); } /* string-greaterp */

/* strcompare - compare strings */
LOCAL LVAL strcompare(fcn,icase)
  int fcn,icase;
{
    int start1,end1,start2,end2,ch1,ch2;
    unsigned char *p1,*p2;
    LVAL str1,str2;

    /* get the strings */
    str1 = xlgastring();
    str2 = xlgastring();

    /* get the substring specifiers */
    getbounds(str1,k_1start,k_1end,&start1,&end1);
    getbounds(str2,k_2start,k_2end,&start2,&end2);

    /* setup the string pointers */
    p1 = &getstring(str1)[start1];
    p2 = &getstring(str2)[start2];

    /* compare the strings */
    for (; start1 < end1 && start2 < end2; ++start1,++start2) {
	ch1 = *p1++;
	ch2 = *p2++;
	if (icase) {
	    if (isupper(ch1)) ch1 = tolower(ch1);
	    if (isupper(ch2)) ch2 = tolower(ch2);
	}
	if (ch1 != ch2)
	    switch (fcn) {
	    case '<':	return (ch1 < ch2 ? fix(start1) : NIL);
	    case 'L':	return (ch1 <= ch2 ? fix(start1) : NIL);
	    case '=':	return (NIL);
	    case '#':	return (fix(start1));
	    case 'G':	return (ch1 >= ch2 ? fix(start1) : NIL);
	    case '>':	return (ch1 > ch2 ? fix(start1) : NIL);
	    }
    }

    /* check the termination condition */
    switch (fcn) {
    case '<':	return (start1 >= end1 && start2 < end2 ? fix(start1) : NIL);
    case 'L':	return (start1 >= end1 ? fix(start1) : NIL);
    case '=':	return (start1 >= end1 && start2 >= end2 ? true : NIL);
    case '#':	return (start1 >= end1 && start2 >= end2 ? NIL : fix(start1));
    case 'G':	return (start2 >= end2 ? fix(start1) : NIL);
    case '>':	return (start2 >= end2 && start1 < end1 ? fix(start1) : NIL);
    }
}

/* case conversion functions */
LVAL xupcase()   { return (changecase('U',FALSE)); }
LVAL xdowncase() { return (changecase('D',FALSE)); }

/* destructive case conversion functions */
LVAL xnupcase()   { return (changecase('U',TRUE)); }
LVAL xndowncase() { return (changecase('D',TRUE)); }

/* changecase - change case */
LOCAL LVAL changecase(fcn,destructive)
  int fcn,destructive;
{
    unsigned char *srcp,*dstp;
    int start,end,len,ch,i;
    LVAL src,dst;

    /* get the string */
    src = xlgastring();

    /* get the substring specifiers */
    getbounds(src,k_start,k_end,&start,&end);
    len = getslength(src) - 1;

    /* make a destination string */
    dst = (destructive ? src : newstring(len+1));

    /* setup the string pointers */
    srcp = getstring(src);
    dstp = getstring(dst);

    /* copy the source to the destination */
    for (i = 0; i < len; ++i) {
	ch = *srcp++;
	if (i >= start && i < end)
	    switch (fcn) {
	    case 'U':	if (islower(ch)) ch = toupper(ch); break;
	    case 'D':	if (isupper(ch)) ch = tolower(ch); break;
	    }
	*dstp++ = ch;
    }
    *dstp = '\0';

    /* return the new string */
    return (dst);
}

/* trim functions */
LVAL xtrim()      { return (trim(TLEFT|TRIGHT)); }
LVAL xlefttrim()  { return (trim(TLEFT)); }
LVAL xrighttrim() { return (trim(TRIGHT)); }

/* trim - trim character from a string */
LOCAL LVAL trim(fcn)
  int fcn;
{
    unsigned char *leftp,*rightp,*dstp;
    LVAL bag,src,dst;

    /* get the bag and the string */
    bag = xlgastring();
    src = xlgastring();
    xllastarg();

    /* setup the string pointers */
    leftp = getstring(src);
    rightp = leftp + getslength(src) - 2;

    /* trim leading characters */
    if (fcn & TLEFT)
	while (leftp <= rightp && inbag(*leftp,bag))
	    ++leftp;

    /* trim character from the right */
    if (fcn & TRIGHT)
	while (rightp >= leftp && inbag(*rightp,bag))
	    --rightp;

    /* make a destination string and setup the pointer */
    dst = newstring((int)(rightp-leftp+2));
    dstp = getstring(dst);

    /* copy the source to the destination */
    while (leftp <= rightp)
	*dstp++ = *leftp++;
    *dstp = '\0';

    /* return the new string */
    return (dst);
}

/* getbounds - get the start and end bounds of a string */
LOCAL getbounds(str,skey,ekey,pstart,pend)
  LVAL str,skey,ekey; int *pstart,*pend;
{
    LVAL arg;
    int len;

    /* get the length of the string */
    len = getslength(str) - 1;

    /* get the starting index */
    if (xlgkfixnum(skey,&arg)) {
	*pstart = (int)getfixnum(arg);
	if (*pstart < 0 || *pstart > len)
	    xlerror("string index out of bounds",arg);
    }
    else
	*pstart = 0;

    /* get the ending index */
    if (xlgkfixnum(ekey,&arg)) {
	*pend = (int)getfixnum(arg);
	if (*pend < 0 || *pend > len)
	    xlerror("string index out of bounds",arg);
    }
    else
	*pend = len;

    /* make sure the start is less than or equal to the end */
    if (*pstart > *pend)
	xlerror("starting index error",cvfixnum((FIXTYPE)*pstart));
}

/* inbag - test if a character is in a bag */
LOCAL int inbag(ch,bag)
  int ch; LVAL bag;
{
    unsigned char *p;
    for (p = getstring(bag); *p != '\0'; ++p)
	if (*p == ch)
	    return (TRUE);
    return (FALSE);
}

/* xstrcat - concatenate a bunch of strings */
LVAL xstrcat()
{
    LVAL *saveargv,tmp,val;
    unsigned char *str;
    int saveargc,len;

    /* save the argument list */
    saveargv = xlargv;
    saveargc = xlargc;

    /* find the length of the new string */
    for (len = 0; moreargs(); ) {
	tmp = xlgastring();
	len += (int)getslength(tmp) - 1;
    }

    /* create the result string */
    val = newstring(len+1);
    str = getstring(val);

    /* restore the argument list */
    xlargv = saveargv;
    xlargc = saveargc;
    
    /* combine the strings */
    for (*str = '\0'; moreargs(); ) {
	tmp = nextarg();
	strcat(str,getstring(tmp));
    }

    /* return the new string */
    return (val);
}

/* xsubseq - return a subsequence */
LVAL xsubseq()
{
    unsigned char *srcp,*dstp;
    int start,end,len;
    LVAL src,dst;

    /* get string and starting and ending positions */
    src = xlgastring();

    /* get the starting position */
    dst = xlgafixnum(); start = (int)getfixnum(dst);
    if (start < 0 || start > getslength(src) - 1)
	xlerror("string index out of bounds",dst);

    /* get the ending position */
    if (moreargs()) {
	dst = xlgafixnum(); end = (int)getfixnum(dst);
	if (end < 0 || end > getslength(src) - 1)
	    xlerror("string index out of bounds",dst);
    }
    else
	end = getslength(src) - 1;
    xllastarg();

    /* setup the source pointer */
    srcp = getstring(src) + start;
    len = end - start;

    /* make a destination string and setup the pointer */
    dst = newstring(len+1);
    dstp = getstring(dst);

    /* copy the source to the destination */
    while (--len >= 0)
	*dstp++ = *srcp++;
    *dstp = '\0';

    /* return the substring */
    return (dst);
}

/* xstring - return a string consisting of a single character */
LVAL xstring()
{
    LVAL arg;

    /* get the argument */
    arg = xlgetarg();
    xllastarg();

    /* make sure its not NIL */
    if (null(arg))
	xlbadtype(arg);

    /* check the argument type */
    switch (ntype(arg)) {
    case STRING:
	return (arg);
    case SYMBOL:
	return (getpname(arg));
    case CHAR:
	buf[0] = (int)getchcode(arg);
	buf[1] = '\0';
	return (cvstring(buf));
    default:
	xlbadtype(arg);
    }
}

/* xchar - extract a character from a string */
LVAL xchar()
{
    LVAL str,num;
    int n;

    /* get the string and the index */
    str = xlgastring();
    num = xlgafixnum();
    xllastarg();

    /* range check the index */
    if ((n = (int)getfixnum(num)) < 0 || n >= getslength(str) - 1)
	xlerror("index out of range",num);

    /* return the character */
    return (cvchar(getstring(str)[n]));
}

/* xcharint - convert an integer to a character */
LVAL xcharint()
{
    LVAL arg;
    arg = xlgachar();
    xllastarg();
    return (cvfixnum((FIXTYPE)getchcode(arg)));
}

/* xintchar - convert a character to an integer */
LVAL xintchar()
{
    LVAL arg;
    arg = xlgafixnum();
    xllastarg();
    return (cvchar((int)getfixnum(arg)));
}

/* xuppercasep - built-in function 'upper-case-p' */
LVAL xuppercasep()
{
    int ch;
    ch = getchcode(xlgachar());
    xllastarg();
    return (isupper(ch) ? true : NIL);
}

/* xlowercasep - built-in function 'lower-case-p' */
LVAL xlowercasep()
{
    int ch;
    ch = getchcode(xlgachar());
    xllastarg();
    return (islower(ch) ? true : NIL);
}

/* xbothcasep - built-in function 'both-case-p' */
LVAL xbothcasep()
{
    int ch;
    ch = getchcode(xlgachar());
    xllastarg();
    return (isupper(ch) || islower(ch) ? true : NIL);
}

/* xdigitp - built-in function 'digit-char-p' */
LVAL xdigitp()
{
    int ch;
    ch = getchcode(xlgachar());
    xllastarg();
    return (isdigit(ch) ? cvfixnum((FIXTYPE)(ch - '0')) : NIL);
}

/* xcharcode - built-in function 'char-code' */
LVAL xcharcode()
{
    int ch;
    ch = getchcode(xlgachar());
    xllastarg();
    return (cvfixnum((FIXTYPE)ch));
}

/* xcodechar - built-in function 'code-char' */
LVAL xcodechar()
{
    LVAL arg;
    int ch;
    arg = xlgafixnum(); ch = getfixnum(arg);
    xllastarg();
    return (ch >= 0 && ch <= 127 ? cvchar(ch) : NIL);
}

/* xchupcase - built-in function 'char-upcase' */
LVAL xchupcase()
{
    LVAL arg;
    int ch;
    arg = xlgachar(); ch = getchcode(arg);
    xllastarg();
    return (islower(ch) ? cvchar(toupper(ch)) : arg);
}

/* xchdowncase - built-in function 'char-downcase' */
LVAL xchdowncase()
{
    LVAL arg;
    int ch;
    arg = xlgachar(); ch = getchcode(arg);
    xllastarg();
    return (isupper(ch) ? cvchar(tolower(ch)) : arg);
}

/* xdigitchar - built-in function 'digit-char' */
LVAL xdigitchar()
{
    LVAL arg;
    int n;
    arg = xlgafixnum(); n = getfixnum(arg);
    xllastarg();
    return (n >= 0 && n <= 9 ? cvchar(n + '0') : NIL);
}

/* xalphanumericp - built-in function 'alphanumericp' */
LVAL xalphanumericp()
{
    int ch;
    ch = getchcode(xlgachar());
    xllastarg();
    return (isupper(ch) || islower(ch) || isdigit(ch) ? true : NIL);
}

/* character comparision functions */
LVAL xchrlss() { return (chrcompare('<',FALSE)); } /* char< */
LVAL xchrleq() { return (chrcompare('L',FALSE)); } /* char<= */
LVAL xchreql() { return (chrcompare('=',FALSE)); } /* char= */
LVAL xchrneq() { return (chrcompare('#',FALSE)); } /* char/= */
LVAL xchrgeq() { return (chrcompare('G',FALSE)); } /* char>= */
LVAL xchrgtr() { return (chrcompare('>',FALSE)); } /* char> */

/* character comparision functions (case insensitive) */
LVAL xchrilss() { return (chrcompare('<',TRUE)); } /* char-lessp */
LVAL xchrileq() { return (chrcompare('L',TRUE)); } /* char-not-greaterp */
LVAL xchrieql() { return (chrcompare('=',TRUE)); } /* char-equalp */
LVAL xchrineq() { return (chrcompare('#',TRUE)); } /* char-not-equalp */
LVAL xchrigeq() { return (chrcompare('G',TRUE)); } /* char-not-lessp */
LVAL xchrigtr() { return (chrcompare('>',TRUE)); } /* char-greaterp */

/* chrcompare - compare characters */
LOCAL LVAL chrcompare(fcn,icase)
  int fcn,icase;
{
    int ch1,ch2,icmp;
    LVAL arg;
    
    /* get the characters */
    arg = xlgachar(); ch1 = getchcode(arg);

    /* convert to lowercase if case insensitive */
    if (icase && isupper(ch1))
	ch1 = tolower(ch1);

    /* handle each remaining argument */
    for (icmp = TRUE; icmp && moreargs(); ch1 = ch2) {

	/* get the next argument */
	arg = xlgachar(); ch2 = getchcode(arg);

	/* convert to lowercase if case insensitive */
	if (icase && isupper(ch2))
	    ch2 = tolower(ch2);

	/* compare the characters */
	switch (fcn) {
	case '<':	icmp = (ch1 < ch2); break;
	case 'L':	icmp = (ch1 <= ch2); break;
	case '=':	icmp = (ch1 == ch2); break;
	case '#':	icmp = (ch1 != ch2); break;
	case 'G':	icmp = (ch1 >= ch2); break;
	case '>':	icmp = (ch1 > ch2); break;
	}
    }

    /* return the result */
    return (icmp ? true : NIL);
}


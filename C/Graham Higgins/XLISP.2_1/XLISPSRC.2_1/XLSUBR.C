/* xlsubr - xlisp builtin function support routines */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern LVAL k_test,k_tnot,s_eql;

/* xlsubr - define a builtin function */
LVAL xlsubr(sname,type,fcn,offset)
  char *sname; int type; LVAL (*fcn)(); int offset;
{
    LVAL sym;
    sym = xlenter(sname);
    setfunction(sym,cvsubr(fcn,type,offset));
    return (sym);
}

/* xlgetkeyarg - get a keyword argument */
int xlgetkeyarg(key,pval)
  LVAL key,*pval;
{
    LVAL *argv=xlargv;
    int argc=xlargc;
    for (argv = xlargv, argc = xlargc; (argc -= 2) >= 0; argv += 2) {
	if (*argv == key) {
	    *pval = *++argv;
	    return (TRUE);
	}
    }
    return (FALSE);
}

/* xlgkfixnum - get a fixnum keyword argument */
int xlgkfixnum(key,pval)
  LVAL key,*pval;
{
    if (xlgetkeyarg(key,pval)) {
	if (!fixp(*pval))
	    xlbadtype(*pval);
	return (TRUE);
    }
    return (FALSE);
}

/* xltest - get the :test or :test-not keyword argument */
xltest(pfcn,ptresult)
  LVAL *pfcn; int *ptresult;
{
    if (xlgetkeyarg(k_test,pfcn))	/* :test */
	*ptresult = TRUE;
    else if (xlgetkeyarg(k_tnot,pfcn))	/* :test-not */
	*ptresult = FALSE;
    else {
	*pfcn = getfunction(s_eql);
	*ptresult = TRUE;
    }
}

/* xlgetfile - get a file or stream */
LVAL xlgetfile()
{
    LVAL arg;

    /* get a file or stream (cons) or nil */
    if (arg = xlgetarg()) {
	if (streamp(arg)) {
	    if (getfile(arg) == NULL)
		xlfail("file not open");
	}
	else if (!ustreamp(arg))
	    xlerror("bad argument type",arg);
    }
    return (arg);
}

/* xlgetfname - get a filename */
LVAL xlgetfname()
{
    LVAL name;

    /* get the next argument */
    name = xlgetarg();

    /* get the filename string */
    if (symbolp(name))
	name = getpname(name);
    else if (!stringp(name))
	xlerror("bad argument type",name);

    /* return the name */
    return (name);
}

/* needsextension - check if a filename needs an extension */
int needsextension(name)
  char *name;
{
    char *p;

    /* check for an extension */
    for (p = &name[strlen(name)]; --p >= &name[0]; )
	if (*p == '.')
	    return (FALSE);
	else if (!islower(*p) && !isupper(*p) && !isdigit(*p))
	    return (TRUE);

    /* no extension found */
    return (TRUE);
}

/* xlbadtype - report a "bad argument type" error */
LVAL xlbadtype(arg)
  LVAL arg;
{
    xlerror("bad argument type",arg);
}

/* xltoofew - report a "too few arguments" error */
LVAL xltoofew()
{
    xlfail("too few arguments");
}

/* xltoomany - report a "too many arguments" error */
xltoomany()
{
    xlfail("too many arguments");
}

/* eq - internal eq function */
int eq(arg1,arg2)
  LVAL arg1,arg2;
{
    return (arg1 == arg2);
}

/* eql - internal eql function */
int eql(arg1,arg2)
  LVAL arg1,arg2;
{
    /* compare the arguments */
    if (arg1 == arg2)
	return (TRUE);
    else if (arg1) {
	switch (ntype(arg1)) {
	case FIXNUM:
	    return (fixp(arg2) ? getfixnum(arg1)==getfixnum(arg2) : FALSE);
	case FLONUM:
	    return (floatp(arg2) ? getflonum(arg1)==getflonum(arg2) : FALSE);
	default:
	    return (FALSE);
	}
    }
    else
	return (FALSE);
}

/* equal - internal equal function */
int equal(arg1,arg2)
  LVAL arg1,arg2;
{
    /* compare the arguments */
    if (arg1 == arg2)
	return (TRUE);
    else if (arg1) {
	switch (ntype(arg1)) {
	case FIXNUM:
	    return (fixp(arg2) ? getfixnum(arg1)==getfixnum(arg2) : FALSE);
	case FLONUM:
	    return (floatp(arg2) ? getflonum(arg1)==getflonum(arg2) : FALSE);
	case STRING:
	    return (stringp(arg2) ? strcmp(getstring(arg1),
					   getstring(arg2)) == 0 : FALSE);
	case CONS:
	    return (consp(arg2) ? equal(car(arg1),car(arg2))
			       && equal(cdr(arg1),cdr(arg2)) : FALSE);
	default:
	    return (FALSE);
	}
    }
    else
	return (FALSE);
}

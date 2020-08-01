/* xlsys.c - xlisp builtin system functions */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern jmp_buf top_level;
extern FILE *tfp;

/* external symbols */
extern LVAL a_subr,a_fsubr,a_cons,a_symbol;
extern LVAL a_fixnum,a_flonum,a_string,a_object,a_stream;
extern LVAL a_vector,a_closure,a_char,a_ustream;
extern LVAL k_verbose,k_print;
extern LVAL true;

/* external routines */
extern FILE *osaopen();

/* xload - read and evaluate expressions from a file */
LVAL xload()
{
    unsigned char *name;
    int vflag,pflag;
    LVAL arg;

    /* get the file name */
    name = getstring(xlgetfname());

    /* get the :verbose flag */
    if (xlgetkeyarg(k_verbose,&arg))
	vflag = (arg != NIL);
    else
	vflag = TRUE;

    /* get the :print flag */
    if (xlgetkeyarg(k_print,&arg))
	pflag = (arg != NIL);
    else
	pflag = FALSE;

    /* load the file */
    return (xlload(name,vflag,pflag) ? true : NIL);
}

/* xtranscript - open or close a transcript file */
LVAL xtranscript()
{
    unsigned char *name;

    /* get the transcript file name */
    name = (moreargs() ? getstring(xlgetfname()) : NULL);
    xllastarg();

    /* close the current transcript */
    if (tfp) osclose(tfp);

    /* open the new transcript */
    tfp = (name ? osaopen(name,"w") : NULL);

    /* return T if a transcript is open, NIL otherwise */
    return (tfp ? true : NIL);
}

/* xtype - return type of a thing */
LVAL xtype()
{
    LVAL arg;

    if (!(arg = xlgetarg()))
	return (NIL);

    switch (ntype(arg)) {
    case SUBR:		return (a_subr);
    case FSUBR:		return (a_fsubr);
    case CONS:		return (a_cons);
    case SYMBOL:	return (a_symbol);
    case FIXNUM:	return (a_fixnum);
    case FLONUM:	return (a_flonum);
    case STRING:	return (a_string);
    case OBJECT:	return (a_object);
    case STREAM:	return (a_stream);
    case VECTOR:	return (a_vector);
    case CLOSURE:	return (a_closure);
    case CHAR:		return (a_char);
    case USTREAM:	return (a_ustream);
    case STRUCT:	return (getelement(arg,0));
    default:		xlfail("bad node type");
    }
}

/* xbaktrace - print the trace back stack */
LVAL xbaktrace()
{
    LVAL num;
    int n;

    if (moreargs()) {
	num = xlgafixnum();
	n = getfixnum(num);
    }
    else
	n = -1;
    xllastarg();
    xlbaktrace(n);
    return (NIL);
}

/* xexit - get out of xlisp */
LVAL xexit()
{
    xllastarg();
    wrapup();
}

/* xpeek - peek at a location in memory */
LVAL xpeek()
{
    LVAL num;
    int *adr;

    /* get the address */
    num = xlgafixnum(); adr = (int *)getfixnum(num);
    xllastarg();

    /* return the value at that address */
    return (cvfixnum((FIXTYPE)*adr));
}

/* xpoke - poke a value into memory */
LVAL xpoke()
{
    LVAL val;
    int *adr;

    /* get the address and the new value */
    val = xlgafixnum(); adr = (int *)getfixnum(val);
    val = xlgafixnum();
    xllastarg();

    /* store the new value */
    *adr = (int)getfixnum(val);

    /* return the new value */
    return (val);
}

/* xaddrs - get the address of an XLISP node */
LVAL xaddrs()
{
    LVAL val;

    /* get the node */
    val = xlgetarg();
    xllastarg();

    /* return the address of the node */
    return (cvfixnum((FIXTYPE)val));
}


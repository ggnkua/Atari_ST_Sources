/* xssym.c - symbol handling routines */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* external variables */
extern LVAL obarray;

/* forward declarations */
#ifdef __STDC__
static LVAL findprop(LVAL sym,LVAL prp);
#else
LVAL findprop();
#endif

/* xlsubr - define a builtin function */
void xlsubr(sname,type,fcn,offset)
  char *sname; int type; LVAL (*fcn)(); int offset;
{
    LVAL sym;
    sym = xlenter(sname);
    setvalue(sym,cvsubr(type,fcn,offset));
}

/* xlenter - enter a symbol into the obarray */
LVAL xlenter(name)
  char *name;
{
    LVAL array,sym;
    int i;

    /* get the current obarray and the hash index for this symbol */
    array = getvalue(obarray);
    i = hash(name,HSIZE);

    /* check if symbol is already in table */
    for (sym = getelement(array,i); sym; sym = cdr(sym))
	if (strcmp(name,getstring(getpname(car(sym)))) == 0)
	    return (car(sym));

    /* make a new symbol node and link it into the list */
    sym = cons(cvsymbol(name),getelement(array,i));
    setelement(array,i,sym);
    sym = car(sym);

    /* return the new symbol */
    return (sym);
}

/* xlgetprop - get the value of a property */
LVAL xlgetprop(sym,prp)
  LVAL sym,prp;
{
    LVAL p;
    return ((p = findprop(sym,prp)) == NIL ? NIL : car(p));
}

/* xlputprop - put a property value onto the property list */
void xlputprop(sym,val,prp)
  LVAL sym,val,prp;
{
    LVAL pair;
    if ((pair = findprop(sym,prp)) != NIL)
	rplaca(pair,val);
    else
	setplist(sym,cons(prp,cons(val,getplist(sym))));
}

/* findprop - find a property pair */
static LVAL findprop(sym,prp)
  LVAL sym,prp;
{
    LVAL p;
    for (p = getplist(sym); consp(p) && consp(cdr(p)); p = cdr(cdr(p)))
	if (car(p) == prp)
	    return (cdr(p));
    return (NIL);
}

/* hash - hash a symbol name string */
int hash(str,len)
  char *str; int len;
{
    int i;
    for (i = 0; *str; )
	i = (i << 2) ^ *str++;
    i %= len;
    return (i < 0 ? -i : i);
}

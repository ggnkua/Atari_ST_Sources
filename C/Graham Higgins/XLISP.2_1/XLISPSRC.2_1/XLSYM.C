/* xlsym - symbol handling routines */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern LVAL obarray,s_unbound;
extern LVAL xlenv,xlfenv,xldenv;

/* forward declarations */
FORWARD LVAL findprop();

/* xlenter - enter a symbol into the obarray */
LVAL xlenter(name)
  char *name;
{
    LVAL sym,array;
    int i;

    /* check for nil */
    if (strcmp(name,"NIL") == 0)
	return (NIL);

    /* check for symbol already in table */
    array = getvalue(obarray);
    i = hash(name,HSIZE);
    for (sym = getelement(array,i); sym; sym = cdr(sym))
	if (strcmp(name,getstring(getpname(car(sym)))) == 0)
	    return (car(sym));

    /* make a new symbol node and link it into the list */
    xlsave1(sym);
    sym = consd(getelement(array,i));
    rplaca(sym,xlmakesym(name));
    setelement(array,i,sym);
    xlpop();

    /* return the new symbol */
    return (car(sym));
}

/* xlmakesym - make a new symbol node */
LVAL xlmakesym(name)
  char *name;
{
    LVAL sym;
    sym = cvsymbol(name);
    if (*name == ':')
	setvalue(sym,sym);
    return (sym);
}

/* xlgetvalue - get the value of a symbol (with check) */
LVAL xlgetvalue(sym)
  LVAL sym;
{
    LVAL val;

    /* look for the value of the symbol */
    while ((val = xlxgetvalue(sym)) == s_unbound)
	xlunbound(sym);

    /* return the value */
    return (val);
}

/* xlxgetvalue - get the value of a symbol */
LVAL xlxgetvalue(sym)
  LVAL sym;
{
    register LVAL fp,ep;
    LVAL val;

    /* check the environment list */
    for (fp = xlenv; fp; fp = cdr(fp))

	/* check for an instance variable */
	if ((ep = car(fp)) && objectp(car(ep))) {
	    if (xlobgetvalue(ep,sym,&val))
		return (val);
	}

	/* check an environment stack frame */
	else {
	    for (; ep; ep = cdr(ep))
		if (sym == car(car(ep)))
		    return (cdr(car(ep)));
	}

    /* return the global value */
    return (getvalue(sym));
}

/* xlsetvalue - set the value of a symbol */
xlsetvalue(sym,val)
  LVAL sym,val;
{
    register LVAL fp,ep;

    /* look for the symbol in the environment list */
    for (fp = xlenv; fp; fp = cdr(fp))

	/* check for an instance variable */
	if ((ep = car(fp)) && objectp(car(ep))) {
	    if (xlobsetvalue(ep,sym,val))
		return;
	}

	/* check an environment stack frame */
	else {
	    for (; ep; ep = cdr(ep))
		if (sym == car(car(ep))) {
		    rplacd(car(ep),val);
		    return;
		}
	}

    /* store the global value */
    setvalue(sym,val);
}

/* xlgetfunction - get the functional value of a symbol (with check) */
LVAL xlgetfunction(sym)
  LVAL sym;
{
    LVAL val;

    /* look for the functional value of the symbol */
    while ((val = xlxgetfunction(sym)) == s_unbound)
	xlfunbound(sym);

    /* return the value */
    return (val);
}

/* xlxgetfunction - get the functional value of a symbol */
LVAL xlxgetfunction(sym)
  LVAL sym;
{
    register LVAL fp,ep;

    /* check the environment list */
    for (fp = xlfenv; fp; fp = cdr(fp))
	for (ep = car(fp); ep; ep = cdr(ep))
	    if (sym == car(car(ep)))
		return (cdr(car(ep)));

    /* return the global value */
    return (getfunction(sym));
}

/* xlsetfunction - set the functional value of a symbol */
xlsetfunction(sym,val)
  LVAL sym,val;
{
    register LVAL fp,ep;

    /* look for the symbol in the environment list */
    for (fp = xlfenv; fp; fp = cdr(fp))
	for (ep = car(fp); ep; ep = cdr(ep))
	    if (sym == car(car(ep))) {
		rplacd(car(ep),val);
		return;
	    }

    /* store the global value */
    setfunction(sym,val);
}

/* xlgetprop - get the value of a property */
LVAL xlgetprop(sym,prp)
  LVAL sym,prp;
{
    LVAL p;
    return ((p = findprop(sym,prp)) ? car(p) : NIL);
}

/* xlputprop - put a property value onto the property list */
xlputprop(sym,val,prp)
  LVAL sym,val,prp;
{
    LVAL pair;
    if (pair = findprop(sym,prp))
	rplaca(pair,val);
    else
	setplist(sym,cons(prp,cons(val,getplist(sym))));
}

/* xlremprop - remove a property from a property list */
xlremprop(sym,prp)
  LVAL sym,prp;
{
    LVAL last,p;
    last = NIL;
    for (p = getplist(sym); consp(p) && consp(cdr(p)); p = cdr(last)) {
	if (car(p) == prp)
	    if (last)
		rplacd(last,cdr(cdr(p)));
	    else
		setplist(sym,cdr(cdr(p)));
	last = cdr(p);
    }
}

/* findprop - find a property pair */
LOCAL LVAL findprop(sym,prp)
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
  char *str;
{
    int i;
    for (i = 0; *str; )
	i = (i << 2) ^ *str++;
    i %= len;
    return (i < 0 ? -i : i);
}

/* xlsinit - symbol initialization routine */
xlsinit()
{
    LVAL array,p;

    /* initialize the obarray */
    obarray = xlmakesym("*OBARRAY*");
    array = newvector(HSIZE);
    setvalue(obarray,array);

    /* add the symbol *OBARRAY* to the obarray */
    p = consa(obarray);
    setelement(array,hash("*OBARRAY*",HSIZE),p);
}

/* xsfun1.c - xscheme built-in functions - part 1 */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* gensym variables */
static char gsprefix[STRMAX+1] = { 'G',0 };	/* gensym prefix string */
static int gsnumber = 1;			/* gensym number */

/* external variables */
extern LVAL xlenv,xlval,default_object,true;
extern LVAL s_unbound;

/* external routines */
extern int eq(),eqv(),equal();

/* forward declarations */
#ifdef __STDC__
static LVAL cxr(char *adstr);
static LVAL member(int (*fcn)());
static LVAL assoc(int (*fcn)());
static LVAL nth(int carflag);
static LVAL vref(LVAL vector);
static LVAL vset(LVAL vector);
static LVAL eqtest(int (*fcn)());
#else
static LVAL cxr();
static LVAL member();
static LVAL assoc();
static LVAL nth();
static LVAL eqtest();
static LVAL vref();
static LVAL vset();
#endif

/* xcons - construct a new list cell */
LVAL xcons()
{
    LVAL carval,cdrval;
    
    /* get the two arguments */
    carval = xlgetarg();
    cdrval = xlgetarg();
    xllastarg();

    /* construct a new cons node */
    return (cons(carval,cdrval));
}

/* xcar - built-in function 'car' */
LVAL xcar()
{
    LVAL list;
    list = xlgalist();
    xllastarg();
    return (list ? car(list) : NIL);
}

/* xicar - built-in function '%car' */
LVAL xicar()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (car(arg));
}

/* xcdr - built-in function 'cdr' */
LVAL xcdr()
{
    LVAL arg;
    arg = xlgalist();
    xllastarg();
    return (arg ? cdr(arg) : NIL);
}

/* xicdr - built-in function '%cdr' */
LVAL xicdr()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (cdr(arg));
}

/* cxxr functions */
LVAL xcaar() { return (cxr("aa")); }
LVAL xcadr() { return (cxr("da")); }
LVAL xcdar() { return (cxr("ad")); }
LVAL xcddr() { return (cxr("dd")); }

/* cxxxr functions */
LVAL xcaaar() { return (cxr("aaa")); }
LVAL xcaadr() { return (cxr("daa")); }
LVAL xcadar() { return (cxr("ada")); }
LVAL xcaddr() { return (cxr("dda")); }
LVAL xcdaar() { return (cxr("aad")); }
LVAL xcdadr() { return (cxr("dad")); }
LVAL xcddar() { return (cxr("add")); }
LVAL xcdddr() { return (cxr("ddd")); }

/* cxxxxr functions */
LVAL xcaaaar() { return (cxr("aaaa")); }
LVAL xcaaadr() { return (cxr("daaa")); }
LVAL xcaadar() { return (cxr("adaa")); }
LVAL xcaaddr() { return (cxr("ddaa")); }
LVAL xcadaar() { return (cxr("aada")); }
LVAL xcadadr() { return (cxr("dada")); }
LVAL xcaddar() { return (cxr("adda")); }
LVAL xcadddr() { return (cxr("ddda")); }
LVAL xcdaaar() { return (cxr("aaad")); }
LVAL xcdaadr() { return (cxr("daad")); }
LVAL xcdadar() { return (cxr("adad")); }
LVAL xcdaddr() { return (cxr("ddad")); }
LVAL xcddaar() { return (cxr("aadd")); }
LVAL xcddadr() { return (cxr("dadd")); }
LVAL xcdddar() { return (cxr("addd")); }
LVAL xcddddr() { return (cxr("dddd")); }

/* cxr - common car/cdr routine */
static LVAL cxr(adstr)
  char *adstr;
{
    LVAL list;

    /* get the list */
    list = xlgalist();
    xllastarg();

    /* perform the car/cdr operations */
    while (*adstr && consp(list))
	list = (*adstr++ == 'a' ? car(list) : cdr(list));

    /* make sure the operation succeeded */
    if (*adstr && list)
	xlbadtype(list);

    /* return the result */
    return (list);
}

/* xsetcar - built-in function 'set-car!' */
LVAL xsetcar()
{
    LVAL arg,newcar;

    /* get the cons and the new car */
    arg = xlgacons();
    newcar = xlgetarg();
    xllastarg();

    /* replace the car */
    rplaca(arg,newcar);
    return (arg);
}

/* xisetcar - built-in function '%set-car!' */
LVAL xisetcar()
{
    LVAL arg,newcar;

    /* get the cons and the new car */
    arg = xlgetarg();
    newcar = xlgetarg();
    xllastarg();

    /* replace the car */
    rplaca(arg,newcar);
    return (arg);
}

/* xsetcdr - built-in function 'set-cdr!' */
LVAL xsetcdr()
{
    LVAL arg,newcdr;

    /* get the cons and the new cdr */
    arg = xlgacons();
    newcdr = xlgetarg();
    xllastarg();

    /* replace the cdr */
    rplacd(arg,newcdr);
    return (arg);
}

/* xisetcdr - built-in function '%set-cdr!' */
LVAL xisetcdr()
{
    LVAL arg,newcdr;

    /* get the cons and the new cdr */
    arg = xlgetarg();
    newcdr = xlgetarg();
    xllastarg();

    /* replace the cdr */
    rplacd(arg,newcdr);
    return (arg);
}

/* xlist - built-in function 'list' */
LVAL xlist()
{
    LVAL last,next,val;

    /* initialize the list */
    val = NIL;

    /* add each argument to the list */
    if (moreargs()) {
        val = last = cons(nextarg(),NIL);
        while (moreargs()) {
	    next = nextarg();
	    push(val);
	    next = cons(next,NIL);
	    rplacd(last,next);
	    last = next;
	    val = pop();
	}
    }

    /* return the list */
    return (val);
}

/* xliststar - built-in function 'list*' */
LVAL xliststar()
{
    LVAL last,next,val;

    /* initialize the list */
    val = last = NIL;

    /* add each argument to the list */
    if (moreargs()) {
        for (;;) {
	    next = nextarg();
	    if (moreargs()) {
		push(val);
		next = cons(next,NIL);
		val = pop();
		if (val) rplacd(last,next);
		else val = next;
		last = next;
	    }
	    else {
		if (val) rplacd(last,next);
		else val = next;
		break;
	    }
	}
    }

    /* return the list */
    return (val);
}

/* xappend - built-in function 'append' */
LVAL xappend()
{
    LVAL next,this,last,val;

    /* append each argument */
    for (val = last = NIL; xlargc > 1; )

	/* append each element of this list to the result list */
	for (next = xlgalist(); consp(next); next = cdr(next)) {
	    push(val);
	    this = cons(car(next),NIL);
	    val = pop();
	    if (last == NIL) val = this;
	    else rplacd(last,this);
	    last = this;
	}

    /* tack on the last argument */
    if (moreargs()) {
	if (last == NIL) val = xlgetarg();
	else rplacd(last,xlgetarg());
    }

    /* return the list */
    return (val);
}

/* xreverse - built-in function 'reverse' */
LVAL xreverse()
{
    LVAL next,val;
    
    /* get the list to reverse */
    next = xlgalist();
    xllastarg();

    /* append each element of this list to the result list */
    for (val = NIL; consp(next); next = cdr(next)) {
	push(val);
	val = cons(car(next),top());
	drop(1);
    }

    /* return the list */
    return (val);
}

/* xlastpair - built-in function 'last-pair' */
LVAL xlastpair()
{
    LVAL list;

    /* get the list */
    list = xlgalist();
    xllastarg();

    /* find the last cons */
    if (consp(list))
	while (consp(cdr(list)))
	    list = cdr(list);

    /* return the last element */
    return (list);
}

/* xlength - built-in function 'length' */
LVAL xlength()
{
    FIXTYPE n;
    LVAL arg;

    /* get the argument */
    arg = xlgalist();
    xllastarg();

    /* find the length */
    for (n = (FIXTYPE)0; consp(arg); ++n)
	arg = cdr(arg);

    /* return the length */
    return (cvfixnum(n));
}

/* xmember - built-in function 'member' */
LVAL xmember()
{
    return (member(equal));
}

/* xmemv - built-in function 'memv' */
LVAL xmemv()
{
    return (member(eqv));
}

/* xmemq - built-in function 'memq' */
LVAL xmemq()
{
    return (member(eq));
}

/* member - common routine for member/memv/memq */
static LVAL member(fcn)
  int (*fcn)();
{
    LVAL x,list,val;

    /* get the expression to look for and the list */
    x = xlgetarg();
    list = xlgalist();
    xllastarg();

    /* look for the expression */
    for (val = NIL; consp(list); list = cdr(list))
	if ((*fcn)(x,car(list))) {
	    val = list;
	    break;
	}

    /* return the result */
    return (val);
}

/* xassoc - built-in function 'assoc' */
LVAL xassoc()
{
    return (assoc(equal));
}

/* xassv - built-in function 'assv' */
LVAL xassv()
{
    return (assoc(eqv));
}

/* xassq - built-in function 'assq' */
LVAL xassq()
{
    return (assoc(eq));
}

/* assoc - common routine for assoc/assv/assq */
static LVAL assoc(fcn)
  int (*fcn)();
{
    LVAL x,alist,pair,val;

    /* get the expression to look for and the association list */
    x = xlgetarg();
    alist = xlgalist();
    xllastarg();

    /* look for the expression */
    for (val = NIL; consp(alist); alist = cdr(alist))
	if ((pair = car(alist)) != NIL && consp(pair))
	    if ((*fcn)(x,car(pair),fcn)) {
		val = pair;
		break;
	    }

    /* return the result */
    return (val);
}

/* xlistref - built-in function 'list-ref' */
LVAL xlistref()
{
    return (nth(TRUE));
}

/* xlisttail - built-in function 'list-tail' */
LVAL xlisttail()
{
    return (nth(FALSE));
}

/* nth - internal nth function */
static LVAL nth(carflag)
  int carflag;
{
    LVAL list,arg;
    int n;

    /* get n and the list */
    list = xlgalist();
    arg = xlgafixnum();
    xllastarg();

    /* range check the index */
    if ((n = (int)getfixnum(arg)) < 0)
	xlerror("index out of range",arg);

    /* find the nth element */
    for (; consp(list) && n; n--)
	list = cdr(list);

    /* make sure the list was long enough */
    if (n)
	xlerror("index out of range",arg);

    /* return the list beginning at the nth element */
    return (carflag && consp(list) ? car(list) : list);
}

/* xboundp - is this a value bound to this symbol? */
LVAL xboundp()
{
    LVAL sym;
    sym = xlgasymbol();
    xllastarg();
    return (boundp(sym) ? true : NIL);
}

/* xsymvalue - get the value of a symbol */
LVAL xsymvalue()
{
    LVAL sym;
    sym = xlgasymbol();
    xllastarg();
    return (getvalue(sym));
}

/* xsetsymvalue - set the value of a symbol */
LVAL xsetsymvalue()
{
    LVAL sym,val;

    /* get the symbol */
    sym = xlgasymbol();
    val = xlgetarg();
    xllastarg();

    /* set the global value */
    setvalue(sym,val);

    /* return its value */
    return (val);
}

/* xsymplist - get the property list of a symbol */
LVAL xsymplist()
{
    LVAL sym;

    /* get the symbol */
    sym = xlgasymbol();
    xllastarg();

    /* return the property list */
    return (getplist(sym));
}

/* xsetsymplist - set the property list of a symbol */
LVAL xsetsymplist()
{
    LVAL sym,val;

    /* get the symbol */
    sym = xlgasymbol();
    val = xlgetarg();
    xllastarg();

    /* set the property list */
    setplist(sym,val);
    return (val);
}

/* xget - get the value of a property */
LVAL xget()
{
    LVAL sym,prp;

    /* get the symbol and property */
    sym = xlgasymbol();
    prp = xlgasymbol();
    xllastarg();

    /* retrieve the property value */
    return (xlgetprop(sym,prp));
}

/* xput - set the value of a property */
LVAL xput()
{
    LVAL sym,val,prp;

    /* get the symbol and property */
    sym = xlgasymbol();
    prp = xlgasymbol();
    val = xlgetarg();
    xllastarg();

    /* set the property value */
    xlputprop(sym,val,prp);

    /* return the value */
    return (val);
}

/* xtheenvironment - built-in function 'the-environment' */
LVAL xtheenvironment()
{
    xllastarg();
    return (xlenv);
}

/* xprocenvironment - built-in function 'procedure-environment' */
LVAL xprocenvironment()
{
    LVAL arg;
    arg = xlgaclosure();
    xllastarg();
    return (getenv(arg));
}

/* xenvp - built-in function 'environment?' */
LVAL xenvp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (envp(arg) ? true : NIL);
}

/* xenvbindings - built-in function 'environment-bindings' */
LVAL xenvbindings()
{
    LVAL env,frame,names,val,this,last;
    int len,i;

    /* get the environment */
    env = xlgetarg();
    xllastarg();

    /* check the argument type */
    if (closurep(env))
	env = getenv(env);
    else if (!envp(env))
	xlbadtype(env);

    /* initialize */
    frame = car(env);
    names = getelement(frame,0);
    len = getsize(frame);
    check(1);

    /* build a list of dotted pairs */
    for (val = last = NIL, i = 1; i < len; ++i, names = cdr(names)) {
	push(val);
	this = cons(cons(car(names),getelement(frame,i)),NIL);
	val = pop();
	if (last) rplacd(last,this);
	else val = this;
	last = this;
    }
    return (val);
}

/* xenvparent - built-in function 'environment-parent' */
LVAL xenvparent()
{
    LVAL env;
    env = xlgaenv();
    xllastarg();
    return (cdr(env));
}

/* xvector - built-in function 'vector' */
LVAL xvector()
{
    LVAL vect,*p;
    vect = newvector(xlargc);
    for (p = &vect->n_vdata[0]; moreargs(); )
	*p++ = xlgetarg();
    return (vect);
}

/* xmakevector - built-in function 'make-vector' */
LVAL xmakevector()
{
    LVAL arg,val,*p;
    int len;
    
    /* get the vector size */
    arg = xlgafixnum();
    len = (int)getfixnum(arg);

    /* check for an initialization value */
    if (moreargs()) {
	arg = xlgetarg();	/* get the initializer */
	xllastarg();		/* make sure that's the last argument */
	cpush(arg);		/* save the initializer */
	val = newvector(len);	/* create the vector */
	p = &val->n_vdata[0];	/* initialize the vector */
	for (arg = pop(); --len >= 0; )
	    *p++ = arg;
    }

    /* no initialization value */
    else
	val = newvector(len);	/* defaults to initializing to NIL */
    
    /* return the new vector */
    return (val);
}

/* xvlength - built-in function 'vector-length' */
LVAL xvlength()
{
    LVAL arg;
    arg = xlgavector();
    xllastarg();
    return (cvfixnum((FIXTYPE)getsize(arg)));
}

/* xivlength - built-in function '%vector-length' */
LVAL xivlength()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (cvfixnum((FIXTYPE)getsize(arg)));
}

/* xvref - built-in function 'vector-ref' */
LVAL xvref()
{
    return (vref(xlgavector()));
}

/* xivref - built-in function '%vector-ref' */
LVAL xivref()
{
    return (vref(xlgetarg()));
}

/* vref - common code for xvref and xivref */
static LVAL vref(vector)
  LVAL vector;
{
    LVAL index;
    int i;

    /* get the index */
    index = xlgafixnum();
    xllastarg();

    /* range check the index */
    if ((i = (int)getfixnum(index)) < 0 || i >= getsize(vector))
	xlerror("index out of range",index);

    /* return the vector element */
    return (getelement(vector,i));
}

/* xvset - built-in function 'vector-set!' */
LVAL xvset()
{
    return (vset(xlgavector()));
}

/* xivset - built-in function '%vector-set!' */
LVAL xivset()
{
    return (vset(xlgetarg()));
}

/* vset - common code for xvset and xivset */
static LVAL vset(vector)
  LVAL vector;
{
    LVAL index,val;
    int i;

    /* get the index and the new value */
    index = xlgafixnum();
    val = xlgetarg();
    xllastarg();

    /* range check the index */
    if ((i = (int)getfixnum(index)) < 0 || i >= getsize(vector))
	xlerror("index out of range",index);

    /* set the vector element and return the value */
    setelement(vector,i,val);
    return (val);
}

/* xvectlist - built-in function 'vector->list' */
LVAL xvectlist()
{
    LVAL vect;
    int size;

    /* get the vector */
    vect = xlgavector();
    xllastarg();
    
    /* make a list from the vector */
    cpush(vect);
    size = getsize(vect);
    for (xlval = NIL; --size >= 0; )
	xlval = cons(getelement(vect,size),xlval);
    drop(1);
    return (xlval);
}

/* xlistvect - built-in function 'list->vector' */
LVAL xlistvect()
{
    LVAL vect,*p;
    int size;

    /* get the list */
    xlval = xlgalist();
    xllastarg();

    /* make a vector from the list */
    size = length(xlval);
    vect = newvector(size);
    for (p = &vect->n_vdata[0]; --size >= 0; xlval = cdr(xlval))
	*p++ = car(xlval);
    return (vect);
}

/* xmakearray - built-in function 'make-array' */
LVAL xmakearray()
{
    LVAL makearray1(),val;
    val = makearray1(xlargc,xlsp);
    drop(xlargc);
    return (val);
}

LVAL makearray1(argc,argv)
  int argc; LVAL *argv;
{
    int size,i;
    LVAL arg;

    /* check for the end of the list of dimensions */
    if (--argc < 0)
	return (NIL);

    /* get this dimension */
    arg = *argv++;
    if (!fixp(arg))
	xlbadtype(arg);
    size = (int)getfixnum(arg);

    /* make the new array */
    cpush(newvector(size));

    /* fill the array and return it */
    for (i = 0; i < size; ++i)
	setelement(top(),i,makearray1(argc,argv));
    return (pop());
}

/* xaref - built-in function 'array-ref' */
LVAL xaref()
{
    LVAL array,index;
    int i;

    /* get the array */
    array = xlgavector();

    /* get each array index */
    while (xlargc > 1) {
	index = xlgafixnum(); i = (int)getfixnum(index);
	if (i < 0 || i > getsize(array))
	    xlerror("index out of range",index);
	array = getelement(array,i);
	if (!vectorp(array))
	    xlbadtype(array);
    }
    cpush(array); ++xlargc;
    return (xvref());
}

/* xaset - built-in function 'array-set!' */
LVAL xaset()
{
    LVAL array,index;
    int i;

    /* get the array */
    array = xlgavector();

    /* get each array index */
    while (xlargc > 2) {
	index = xlgafixnum(); i = (int)getfixnum(index);
	if (i < 0 || i > getsize(array))
	    xlerror("index out of range",index);
	array = getelement(array,i);
	if (!vectorp(array))
	    xlbadtype(array);
    }
    cpush(array); ++xlargc;
    return (xvset());
}

/* xnull - built-in function 'null?' */
LVAL xnull()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (null(arg) ? true : NIL);
}

/* xatom - built-in function 'atom?' */
LVAL xatom()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (atom(arg) ? true : NIL);
}

/* xlistp - built-in function 'list?' */
LVAL xlistp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (listp(arg) ? true : NIL);
}

/* xnumberp - built-in function 'number?' */
LVAL xnumberp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (numberp(arg) ? true : NIL);
}

/* xbooleanp - built-in function 'boolean?' */
LVAL xbooleanp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (arg == true || arg == NIL ? true : NIL);
}

/* xpairp - built-in function 'pair?' */
LVAL xpairp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (consp(arg) ? true : NIL);
}

/* xsymbolp - built-in function 'symbol?' */
LVAL xsymbolp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (symbolp(arg) ? true : NIL);
}

/* xintegerp - built-in function 'integer?' */
LVAL xintegerp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (fixp(arg) ? true : NIL);
}

/* xrealp - built-in function 'real?' */
LVAL xrealp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (floatp(arg) ? true : NIL);
}

/* xcharp - built-in function 'char?' */
LVAL xcharp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (charp(arg) ? true : NIL);
}

/* xstringp - built-in function 'string?' */
LVAL xstringp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (stringp(arg) ? true : NIL);
}

/* xvectorp - built-in function 'vector?' */
LVAL xvectorp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (vectorp(arg) ? true : NIL);
}

#define isprocedure(x) \
(closurep(x) || continuationp(x) || subrp(x) || xsubrp(x))

/* xprocedurep - built-in function 'procedure?' */
LVAL xprocedurep()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (isprocedure(arg) ? true : NIL);
}

/* xobjectp - built-in function 'object?' */
LVAL xobjectp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (objectp(arg) ? true : NIL);
}

/* xdefaultobjectp - built-in function 'default-object?' */
LVAL xdefaultobjectp()
{
    LVAL arg;
    arg = xlgetarg();
    xllastarg();
    return (arg == default_object ? true : NIL);
}

/* xeq - built-in function 'eq?' */
LVAL xeq()
{
    return (eqtest(eq));
}

/* xeqv - built-in function 'eqv?' */
LVAL xeqv()
{
    return (eqtest(eqv));
}

/* xequal - built-in function 'equal?' */
LVAL xequal()
{
    return (eqtest(equal));
}

/* eqtest - common code for eq?/eqv?/equal? */
static LVAL eqtest(fcn)
  int (*fcn)();
{
    LVAL arg1,arg2;
    arg1 = xlgetarg();
    arg2 = xlgetarg();
    xllastarg();
    return ((*fcn)(arg1,arg2) ? true : NIL);
}

/* xgensym - generate a symbol */
LVAL xgensym()
{
    char sym[STRMAX+11]; /* enough space for prefix and number */
    LVAL x;

    /* get the prefix or number */
    if (moreargs()) {
	if ((x = xlgetarg()) == NIL)
	    xlerror("bad argument type",x);
	else
	    switch (ntype(x)) {
	    case SYMBOL:
		x = getpname(x);
	    case STRING:
		strncpy(gsprefix,getstring(x),STRMAX);
		gsprefix[STRMAX] = '\0';
		break;
	    case FIXNUM:
		gsnumber = (int)getfixnum(x);
		break;
	    default:
		xlerror("bad argument type",x);
	    }
    }
    xllastarg();

    /* create the pname of the new symbol */
    sprintf(sym,"%s%d",gsprefix,gsnumber++);

    /* make a symbol with this print name */
    return (cvsymbol(sym));
}

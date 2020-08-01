/* xlstruct.c - the defstruct facility */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern LVAL xlenv,xlfenv;
extern LVAL s_lambda,s_quote,lk_key,true;
extern char buf[];

/* local variables */
static prefix[STRMAX+1];

/* xmkstruct - the '%make-struct' function */
LVAL xmkstruct()
{
    LVAL type,val;
    int i;

    /* get the structure type */
    type = xlgasymbol();

    /* make the structure */
    val = newstruct(type,xlargc);

    /* store each argument */
    for (i = 1; moreargs(); ++i)
	setelement(val,i,nextarg());
    xllastarg();

    /* return the structure */
    return (val);
}

/* xcpystruct - the '%copy-struct' function */
LVAL xcpystruct()
{
    LVAL str,val;
    int size,i;
    str = xlgastruct();
    xllastarg();
    size = getsize(str);
    val = newstruct(getelement(str,0),size-1);
    for (i = 1; i < size; ++i)
	setelement(val,i,getelement(str,i));
    return (val);
}

/* xstrref - the '%struct-ref' function */
LVAL xstrref()
{
    LVAL str,val;
    int i;
    str = xlgastruct();
    val = xlgafixnum(); i = (int)getfixnum(val);
    xllastarg();
    return (getelement(str,i));
}

/* xstrset - the '%struct-set' function */
LVAL xstrset()
{
    LVAL str,val;
    int i;
    str = xlgastruct();
    val = xlgafixnum(); i = (int)getfixnum(val);
    val = xlgetarg();
    xllastarg();
    setelement(str,i,val);
    return (val);
}

/* xstrtypep - the '%struct-type-p' function */
LVAL xstrtypep()
{
    LVAL type,val;
    type = xlgasymbol();
    val = xlgetarg();
    xllastarg();
    return (structp(val) && getelement(val,0) == type ? true : NIL);
}

/* xdefstruct - the 'defstruct' special form */
LVAL xdefstruct()
{
    LVAL structname,slotname,defexpr,sym,tmp,args,body;
    LVAL options,oargs,slots;
    char *pname;
    int slotn;
    
    /* protect some pointers */
    xlstkcheck(6);
    xlsave(structname);
    xlsave(slotname);
    xlsave(defexpr);
    xlsave(args);
    xlsave(body);
    xlsave(tmp);
    
    /* initialize */
    args = body = NIL;
    slotn = 0;

    /* get the structure name */
    tmp = xlgetarg();
    if (symbolp(tmp)) {
	structname = tmp;
	strcpy(prefix,getstring(getpname(structname)));
	strcat(prefix,"-");
    }

    /* get the structure name and options */
    else if (consp(tmp) && symbolp(car(tmp))) {
	structname = car(tmp);
	strcpy(prefix,getstring(getpname(structname)));
	strcat(prefix,"-");

	/* handle the list of options */
	for (options = cdr(tmp); consp(options); options = cdr(options)) {

	    /* get the next argument */
	    tmp = car(options);
	    
	    /* handle options that don't take arguments */
	    if (symbolp(tmp)) {
		pname = getstring(getpname(tmp));
		xlerror("unknown option",tmp);
	    }

	    /* handle options that take arguments */
	    else if (consp(tmp) && symbolp(car(tmp))) {
		pname = getstring(getpname(car(tmp)));
		oargs = cdr(tmp);

		/* check for the :CONC-NAME keyword */
		if (strcmp(pname,":CONC-NAME") == 0) {

		    /* get the name of the structure to include */
		    if (!consp(oargs) || !symbolp(car(oargs)))
			xlerror("expecting a symbol",oargs);

		    /* save the prefix */
		    strcpy(prefix,getstring(getpname(car(oargs))));
		}

		/* check for the :INCLUDE keyword */
		else if (strcmp(pname,":INCLUDE") == 0) {

		    /* get the name of the structure to include */
		    if (!consp(oargs) || !symbolp(car(oargs)))
			xlerror("expecting a structure name",oargs);
		    tmp = car(oargs);
		    oargs = cdr(oargs);

		    /* add each slot from the included structure */
		    slots = xlgetprop(tmp,xlenter("*STRUCT-SLOTS*"));
		    for (; consp(slots); slots = cdr(slots)) {
			if (consp(car(slots)) && consp(cdr(car(slots)))) {

			    /* get the next slot description */
			    tmp = car(slots);

			    /* create the slot access functions */
			    addslot(car(tmp),car(cdr(tmp)),++slotn,&args,&body);
			}
		    }

		    /* handle slot initialization overrides */
		    for (; consp(oargs); oargs = cdr(oargs)) {
			tmp = car(oargs);
			if (symbolp(tmp)) {
			    slotname = tmp;
			    defexpr = NIL;
			}
			else if (consp(tmp) && symbolp(car(tmp))) {
			    slotname = car(tmp);
			    defexpr = (consp(cdr(tmp)) ? car(cdr(tmp)) : NIL);
			}
			else
			    xlerror("bad slot description",tmp);
			updateslot(args,slotname,defexpr);
		    }
		}
		else
		    xlerror("unknown option",tmp);
	    }
	    else
		xlerror("bad option syntax",tmp);
	}
    }

    /* get each of the structure members */
    while (moreargs()) {
	
	/* get the slot name and default value expression */
	tmp = xlgetarg();
	if (symbolp(tmp)) {
	    slotname = tmp;
	    defexpr = NIL;
	}
	else if (consp(tmp) && symbolp(car(tmp))) {
	    slotname = car(tmp);
	    defexpr = (consp(cdr(tmp)) ? car(cdr(tmp)) : NIL);
	}
	else
	    xlerror("bad slot description",tmp);
	
	/* create a closure for non-trival default expressions */
	if (defexpr != NIL) {
	    tmp = newclosure(NIL,s_lambda,xlenv,xlfenv);
	    setbody(tmp,cons(defexpr,NIL));
	    tmp = cons(tmp,NIL);
	    defexpr = tmp;
	}

	/* create the slot access functions */
	addslot(slotname,defexpr,++slotn,&args,&body);
    }
    
    /* store the slotnames and default expressions */
    xlputprop(structname,args,xlenter("*STRUCT-SLOTS*"));

    /* enter the MAKE-xxx symbol */
    sprintf(buf,"MAKE-%s",getstring(getpname(structname)));
    sym = xlenter(buf);

    /* make the MAKE-xxx function */
    args = cons(lk_key,args);
    tmp = cons(structname,NIL);
    tmp = cons(s_quote,tmp);
    body = cons(tmp,body);
    body = cons(xlenter("%MAKE-STRUCT"),body);
    body = cons(body,NIL);
    setfunction(sym,
		xlclose(sym,s_lambda,args,body,xlenv,xlfenv));

    /* enter the xxx-P symbol */
    sprintf(buf,"%s-P",getstring(getpname(structname)));
    sym = xlenter(buf);

    /* make the xxx-P function */
    args = cons(xlenter("X"),NIL);
    body = cons(xlenter("X"),NIL);
    tmp = cons(structname,NIL);
    tmp = cons(s_quote,tmp);
    body = cons(tmp,body);
    body = cons(xlenter("%STRUCT-TYPE-P"),body);
    body = cons(body,NIL);
    setfunction(sym,
		xlclose(sym,s_lambda,args,body,NIL,NIL));

    /* enter the COPY-xxx symbol */
    sprintf(buf,"COPY-%s",getstring(getpname(structname)));
    sym = xlenter(buf);

    /* make the COPY-xxx function */
    args = cons(xlenter("X"),NIL);
    body = cons(xlenter("X"),NIL);
    body = cons(xlenter("%COPY-STRUCT"),body);
    body = cons(body,NIL);
    setfunction(sym,
		xlclose(sym,s_lambda,args,body,NIL,NIL));

    /* restore the stack */
    xlpopn(6);

    /* return the structure name */
    return (structname);
}

/* xlrdstruct - convert a list to a structure (used by the reader) */
LVAL xlrdstruct(list)
  LVAL list;
{
    LVAL structname,sym,slotname,expr,last,val;

    /* protect the new structure */
    xlsave1(expr);

    /* get the structure name */
    if (!consp(list) || !symbolp(car(list)))
	xlerror("bad structure initialization list",list);
    structname = car(list);
    list = cdr(list);

    /* enter the MAKE-xxx symbol */
    sprintf(buf,"MAKE-%s",getstring(getpname(structname)));

    /* initialize the MAKE-xxx function call expression */
    expr = cons(xlenter(buf),NIL);
    last = expr;

    /* turn the rest of the initialization list into keyword arguments */
    while (consp(list) && consp(cdr(list))) {

	/* get the slot keyword name */
	slotname = car(list);
	if (!symbolp(slotname))
	    xlerror("expecting a slot name",slotname);
	sprintf(buf,":%s",getstring(getpname(slotname)));

	/* add the slot keyword */
	rplacd(last,cons(xlenter(buf),NIL));
	last = cdr(last);
	list = cdr(list);

	/* add the value expression */
	rplacd(last,cons(car(list),NIL));
	last = cdr(last);
	list = cdr(list);
    }

    /* make sure all of the initializers were used */
    if (consp(list))
	xlerror("bad structure initialization list",list);

    /* invoke the creation function */
    val = xleval(expr);

    /* restore the stack */
    xlpop();

    /* return the new structure */
    return (val);
}

/* xlprstruct - print a structure (used by printer) */
xlprstruct(fptr,vptr,flag)
  LVAL fptr,vptr; int flag;
{
    LVAL next;
    int i,n;
    xlputc(fptr,'#'); xlputc(fptr,'S'); xlputc(fptr,'(');
    xlprint(fptr,getelement(vptr,0),flag);
    next = xlgetprop(getelement(vptr,0),xlenter("*STRUCT-SLOTS*"));
    for (i = 1, n = getsize(vptr) - 1; i <= n && consp(next); ++i) {
	if (consp(car(next))) { /* should always succeed */
	    xlputc(fptr,' ');
	    xlprint(fptr,car(car(next)),flag);
	    xlputc(fptr,' ');
	    xlprint(fptr,getelement(vptr,i),flag);
	}
	next = cdr(next);
    }
    xlputc(fptr,')');
}

/* addslot - make the slot access functions */
LOCAL addslot(slotname,defexpr,slotn,pargs,pbody)
  LVAL slotname,defexpr; int slotn; LVAL *pargs,*pbody;
{
    LVAL sym,args,body,tmp;
    
    /* protect some pointers */
    xlstkcheck(4);
    xlsave(sym);
    xlsave(args);
    xlsave(body);
    xlsave(tmp);
    
    /* construct the update function name */
    sprintf(buf,"%s%s",prefix,getstring(getpname(slotname)));
    sym = xlenter(buf);
    
    /* make the access function */
    args = cons(xlenter("S"),NIL);
    body = cons(cvfixnum((FIXTYPE)slotn),NIL);
    body = cons(xlenter("S"),body);
    body = cons(xlenter("%STRUCT-REF"),body);
    body = cons(body,NIL);
    setfunction(sym,
		xlclose(sym,s_lambda,args,body,NIL,NIL));

    /* make the update function */
    args = cons(xlenter("V"),NIL);
    args = cons(xlenter("S"),args);
    body = cons(xlenter("V"),NIL);
    body = cons(cvfixnum((FIXTYPE)slotn),body);
    body = cons(xlenter("S"),body);
    body = cons(xlenter("%STRUCT-SET"),body);
    body = cons(body,NIL);
    xlputprop(sym,
	      xlclose(NIL,s_lambda,args,body,NIL,NIL),
	      xlenter("*SETF*"));

    /* add the slotname to the make-xxx keyword list */
    tmp = cons(defexpr,NIL);
    tmp = cons(slotname,tmp);
    tmp = cons(tmp,NIL);
    if ((args = *pargs) == NIL)
	*pargs = tmp;
    else {
	while (cdr(args) != NIL)
	    args = cdr(args);
	rplacd(args,tmp);
    }
    
    /* add the slotname to the %make-xxx argument list */
    tmp = cons(slotname,NIL);
    if ((body = *pbody) == NIL)
	*pbody = tmp;
    else {
	while (cdr(body) != NIL)
	    body = cdr(body);
	rplacd(body,tmp);
    }

    /* restore the stack */
    xlpopn(4);
}

/* updateslot - update a slot definition */
LOCAL updateslot(args,slotname,defexpr)
  LVAL args,slotname,defexpr;
{
    LVAL tmp;
    for (; consp(args); args = cdr(args))
	if (slotname == car(car(args))) {
	    if (defexpr != NIL) {
		xlsave1(tmp);
		tmp = newclosure(NIL,s_lambda,xlenv,xlfenv);
		setbody(tmp,cons(defexpr,NIL));
		tmp = cons(tmp,NIL);
		defexpr = tmp;
		xlpop();
	    }
	    rplaca(cdr(car(args)),defexpr);
	    break;
	}
    if (args == NIL)
	xlerror("unknown slot name",slotname);
}


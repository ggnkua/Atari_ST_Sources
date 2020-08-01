/* xlcont - xlisp special forms */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern LVAL xlenv,xlfenv,xldenv,xlvalue;
extern LVAL s_setf,s_car,s_cdr,s_nth,s_aref,s_get;
extern LVAL s_svalue,s_sfunction,s_splist;
extern LVAL s_lambda,s_macro;
extern LVAL s_comma,s_comat;
extern LVAL s_unbound;
extern LVAL true;

/* external routines */
extern LVAL makearglist();

/* forward declarations */
FORWARD LVAL bquote1();
FORWARD LVAL let();
FORWARD LVAL flet();
FORWARD LVAL prog();
FORWARD LVAL progx();
FORWARD LVAL doloop();
FORWARD LVAL evarg();
FORWARD LVAL match();
FORWARD LVAL evmatch();

/* dummy node type for a list */
#define LIST	-1

/* xquote - special form 'quote' */
LVAL xquote()
{
    LVAL val;
    val = xlgetarg();
    xllastarg();
    return (val);
}

/* xfunction - special form 'function' */
LVAL xfunction()
{
    LVAL val;

    /* get the argument */
    val = xlgetarg();
    xllastarg();

    /* create a closure for lambda expressions */
    if (consp(val) && car(val) == s_lambda && consp(cdr(val)))
	val = xlclose(NIL,s_lambda,car(cdr(val)),cdr(cdr(val)),xlenv,xlfenv);

    /* otherwise, get the value of a symbol */
    else if (symbolp(val))
	val = xlgetfunction(val);

    /* otherwise, its an error */
    else
	xlerror("not a function",val);

    /* return the function */
    return (val);
}

/* xbquote - back quote special form */
LVAL xbquote()
{
    LVAL expr;

    /* get the expression */
    expr = xlgetarg();
    xllastarg();

    /* fill in the template */
    return (bquote1(expr));
}

/* bquote1 - back quote helper function */
LOCAL LVAL bquote1(expr)
  LVAL expr;
{
    LVAL val,list,last,new;

    /* handle atoms */
    if (atom(expr))
	val = expr;

    /* handle (comma <expr>) */
    else if (car(expr) == s_comma) {
	if (atom(cdr(expr)))
	    xlfail("bad comma expression");
	val = xleval(car(cdr(expr)));
    }

    /* handle ((comma-at <expr>) ... ) */
    else if (consp(car(expr)) && car(car(expr)) == s_comat) {
	xlstkcheck(2);
	xlsave(list);
	xlsave(val);
	if (atom(cdr(car(expr))))
	    xlfail("bad comma-at expression");
	list = xleval(car(cdr(car(expr))));
	for (last = NIL; consp(list); list = cdr(list)) {
	    new = consa(car(list));
	    if (last)
		rplacd(last,new);
	    else
		val = new;
	    last = new;
	}
	if (last)
	    rplacd(last,bquote1(cdr(expr)));
	else
	    val = bquote1(cdr(expr));
	xlpopn(2);
    }

    /* handle any other list */
    else {
	xlsave1(val);
	val = consa(NIL);
	rplaca(val,bquote1(car(expr)));
	rplacd(val,bquote1(cdr(expr)));
	xlpop();
    }

    /* return the result */
    return (val);
}

/* xlambda - special form 'lambda' */
LVAL xlambda()
{
    LVAL fargs,arglist,val;

    /* get the formal argument list and function body */
    xlsave1(arglist);
    fargs = xlgalist();
    arglist = makearglist(xlargc,xlargv);

    /* create a new function definition */
    val = xlclose(NIL,s_lambda,fargs,arglist,xlenv,xlfenv);

    /* restore the stack and return the closure */
    xlpop();
    return (val);
}

/* xgetlambda - get the lambda expression associated with a closure */
LVAL xgetlambda()
{
    LVAL closure;
    closure = xlgaclosure();
    return (cons(gettype(closure),
                 cons(getlambda(closure),getbody(closure))));
}

/* xsetq - special form 'setq' */
LVAL xsetq()
{
    LVAL sym,val;

    /* handle each pair of arguments */
    for (val = NIL; moreargs(); ) {
	sym = xlgasymbol();
	val = xleval(nextarg());
	xlsetvalue(sym,val);
    }

    /* return the result value */
    return (val);
}

/* xpsetq - special form 'psetq' */
LVAL xpsetq()
{
    LVAL plist,sym,val;

    /* protect some pointers */
    xlsave1(plist);

    /* handle each pair of arguments */
    for (val = NIL; moreargs(); ) {
	sym = xlgasymbol();
	val = xleval(nextarg());
	plist = cons(cons(sym,val),plist);
    }

    /* do parallel sets */
    for (; plist; plist = cdr(plist))
	xlsetvalue(car(car(plist)),cdr(car(plist)));

    /* restore the stack */
    xlpop();

    /* return the result value */
    return (val);
}

/* xsetf - special form 'setf' */
LVAL xsetf()
{
    LVAL place,value;

    /* protect some pointers */
    xlsave1(value);

    /* handle each pair of arguments */
    while (moreargs()) {

	/* get place and value */
	place = xlgetarg();
	value = xleval(nextarg());

	/* expand macros in the place form */
	if (consp(place))
	    place = xlexpandmacros(place);
	
	/* check the place form */
	if (symbolp(place))
	    xlsetvalue(place,value);
	else if (consp(place))
	    placeform(place,value);
	else
	    xlfail("bad place form");
    }

    /* restore the stack */
    xlpop();

    /* return the value */
    return (value);
}

/* placeform - handle a place form other than a symbol */
LOCAL placeform(place,value)
  LVAL place,value;
{
    LVAL fun,arg1,arg2;
    int i;

    /* check the function name */
    if ((fun = match(SYMBOL,&place)) == s_get) {
	xlstkcheck(2);
	xlsave(arg1);
	xlsave(arg2);
	arg1 = evmatch(SYMBOL,&place);
	arg2 = evmatch(SYMBOL,&place);
	if (place) toomany(place);
	xlputprop(arg1,value,arg2);
	xlpopn(2);
    }
    else if (fun == s_svalue) {
	arg1 = evmatch(SYMBOL,&place);
	if (place) toomany(place);
	setvalue(arg1,value);
    }
    else if (fun == s_sfunction) {
	arg1 = evmatch(SYMBOL,&place);
	if (place) toomany(place);
	setfunction(arg1,value);
    }
    else if (fun == s_splist) {
	arg1 = evmatch(SYMBOL,&place);
	if (place) toomany(place);
	setplist(arg1,value);
    }
    else if (fun == s_car) {
	arg1 = evmatch(CONS,&place);
	if (place) toomany(place);
	rplaca(arg1,value);
    }
    else if (fun == s_cdr) {
	arg1 = evmatch(CONS,&place);
	if (place) toomany(place);
	rplacd(arg1,value);
    }
    else if (fun == s_nth) {
	xlsave1(arg1);
	arg1 = evmatch(FIXNUM,&place);
	arg2 = evmatch(LIST,&place);
	if (place) toomany(place);
	for (i = (int)getfixnum(arg1); i > 0 && consp(arg2); --i)
	    arg2 = cdr(arg2);
	if (consp(arg2))
	    rplaca(arg2,value);
	xlpop();
    }
    else if (fun == s_aref) {
	xlsave1(arg1);
	arg1 = evmatch(VECTOR,&place);
	arg2 = evmatch(FIXNUM,&place); i = (int)getfixnum(arg2);
	if (place) toomany(place);
	if (i < 0 || i >= getsize(arg1))
	    xlerror("index out of range",arg2);
	setelement(arg1,i,value);
	xlpop();
    }
    else if (fun = xlgetprop(fun,s_setf))
	setffunction(fun,place,value);
    else
	xlfail("bad place form");
}

/* setffunction - call a user defined setf function */
LOCAL setffunction(fun,place,value)
  LVAL fun,place,value;
{
    LVAL *newfp;
    int argc;

    /* create the new call frame */
    newfp = xlsp;
    pusharg(cvfixnum((FIXTYPE)(newfp - xlfp)));
    pusharg(fun);
    pusharg(NIL);

    /* push the values of all of the place expressions and the new value */
    for (argc = 1; consp(place); place = cdr(place), ++argc)
	pusharg(xleval(car(place)));
    pusharg(value);

    /* insert the argument count and establish the call frame */
    newfp[2] = cvfixnum((FIXTYPE)argc);
    xlfp = newfp;

    /* apply the function */
    xlapply(argc);
}
		       
/* xdefun - special form 'defun' */
LVAL xdefun()
{
    LVAL sym,fargs,arglist;

    /* get the function symbol and formal argument list */
    xlsave1(arglist);
    sym = xlgasymbol();
    fargs = xlgalist();
    arglist = makearglist(xlargc,xlargv);

    /* make the symbol point to a new function definition */
    xlsetfunction(sym,xlclose(sym,s_lambda,fargs,arglist,xlenv,xlfenv));

    /* restore the stack and return the function symbol */
    xlpop();
    return (sym);
}

/* xdefmacro - special form 'defmacro' */
LVAL xdefmacro()
{
    LVAL sym,fargs,arglist;

    /* get the function symbol and formal argument list */
    xlsave1(arglist);
    sym = xlgasymbol();
    fargs = xlgalist();
    arglist = makearglist(xlargc,xlargv);

    /* make the symbol point to a new function definition */
    xlsetfunction(sym,xlclose(sym,s_macro,fargs,arglist,NIL,NIL));

    /* restore the stack and return the function symbol */
    xlpop();
    return (sym);
}

/* xcond - special form 'cond' */
LVAL xcond()
{
    LVAL list,val;

    /* find a predicate that is true */
    for (val = NIL; moreargs(); ) {

	/* get the next conditional */
	list = nextarg();

	/* evaluate the predicate part */
	if (consp(list) && (val = xleval(car(list)))) {

	    /* evaluate each expression */
	    for (list = cdr(list); consp(list); list = cdr(list))
		val = xleval(car(list));

	    /* exit the loop */
	    break;
	}
    }

    /* return the value */
    return (val);
}

/* xwhen - special form 'when' */
LVAL xwhen()
{
    LVAL val;

    /* check the test expression */
    if (val = xleval(xlgetarg()))
	while (moreargs())
	    val = xleval(nextarg());

    /* return the value */
    return (val);
}

/* xunless - special form 'unless' */
LVAL xunless()
{
    LVAL val=NIL;

    /* check the test expression */
    if (xleval(xlgetarg()) == NIL)
	while (moreargs())
	    val = xleval(nextarg());

    /* return the value */
    return (val);
}

/* xcase - special form 'case' */
LVAL xcase()
{
    LVAL key,list,cases,val;

    /* protect some pointers */
    xlsave1(key);

    /* get the key expression */
    key = xleval(nextarg());

    /* find a case that matches */
    for (val = NIL; moreargs(); ) {

	/* get the next case clause */
	list = nextarg();

	/* make sure this is a valid clause */
	if (consp(list)) {

	    /* compare the key list against the key */
	    if ((cases = car(list)) == true ||
                (listp(cases) && keypresent(key,cases)) ||
                eql(key,cases)) {

		/* evaluate each expression */
		for (list = cdr(list); consp(list); list = cdr(list))
		    val = xleval(car(list));

		/* exit the loop */
		break;
	    }
	}
	else
	    xlerror("bad case clause",list);
    }

    /* restore the stack */
    xlpop();

    /* return the value */
    return (val);
}

/* keypresent - check for the presence of a key in a list */
LOCAL int keypresent(key,list)
  LVAL key,list;
{
    for (; consp(list); list = cdr(list))
	if (eql(car(list),key))
	    return (TRUE);
    return (FALSE);
}

/* xand - special form 'and' */
LVAL xand()
{
    LVAL val;

    /* evaluate each argument */
    for (val = true; moreargs(); )
	if ((val = xleval(nextarg())) == NIL)
	    break;

    /* return the result value */
    return (val);
}

/* xor - special form 'or' */
LVAL xor()
{
    LVAL val;

    /* evaluate each argument */
    for (val = NIL; moreargs(); )
	if ((val = xleval(nextarg())))
	    break;

    /* return the result value */
    return (val);
}

/* xif - special form 'if' */
LVAL xif()
{
    LVAL testexpr,thenexpr,elseexpr;

    /* get the test expression, then clause and else clause */
    testexpr = xlgetarg();
    thenexpr = xlgetarg();
    elseexpr = (moreargs() ? xlgetarg() : NIL);
    xllastarg();

    /* evaluate the appropriate clause */
    return (xleval(xleval(testexpr) ? thenexpr : elseexpr));
}

/* xlet - special form 'let' */
LVAL xlet()
{
    return (let(TRUE));
}

/* xletstar - special form 'let*' */
LVAL xletstar()
{
    return (let(FALSE));
}

/* let - common let routine */
LOCAL LVAL let(pflag)
  int pflag;
{
    LVAL newenv,val;

    /* protect some pointers */
    xlsave1(newenv);

    /* create a new environment frame */
    newenv = xlframe(xlenv);

    /* get the list of bindings and bind the symbols */
    if (!pflag) xlenv = newenv;
    dobindings(xlgalist(),newenv);
    if (pflag) xlenv = newenv;

    /* execute the code */
    for (val = NIL; moreargs(); )
	val = xleval(nextarg());

    /* unbind the arguments */
    xlenv = cdr(xlenv);

    /* restore the stack */
    xlpop();

    /* return the result */
    return (val);
}

/* xflet - built-in function 'flet' */
LVAL xflet()
{
    return (flet(s_lambda,TRUE));
}

/* xlabels - built-in function 'labels' */
LVAL xlabels()
{
    return (flet(s_lambda,FALSE));
}

/* xmacrolet - built-in function 'macrolet' */
LVAL xmacrolet()
{
    return (flet(s_macro,TRUE));
}

/* flet - common flet/labels/macrolet routine */
LOCAL LVAL flet(type,letflag)
  LVAL type; int letflag;
{
    LVAL list,bnd,sym,fargs,val;

    /* create a new environment frame */
    xlfenv = xlframe(xlfenv);

    /* bind each symbol in the list of bindings */
    for (list = xlgalist(); consp(list); list = cdr(list)) {

	/* get the next binding */
	bnd = car(list);

	/* get the symbol and the function definition */
	sym = match(SYMBOL,&bnd);
	fargs = match(LIST,&bnd);
	val = xlclose(sym,type,fargs,bnd,xlenv,(letflag?cdr(xlfenv):xlfenv));

	/* bind the value to the symbol */
	xlfbind(sym,val);
    }

    /* execute the code */
    for (val = NIL; moreargs(); )
	val = xleval(nextarg());

    /* unbind the arguments */
    xlfenv = cdr(xlfenv);

    /* return the result */
    return (val);
}

/* xprog - special form 'prog' */
LVAL xprog()
{
    return (prog(TRUE));
}

/* xprogstar - special form 'prog*' */
LVAL xprogstar()
{
    return (prog(FALSE));
}

/* prog - common prog routine */
LOCAL LVAL prog(pflag)
  int pflag;
{
    LVAL newenv,val;
    CONTEXT cntxt;

    /* protect some pointers */
    xlsave1(newenv);

    /* create a new environment frame */
    newenv = xlframe(xlenv);

    /* establish a new execution context */
    xlbegin(&cntxt,CF_RETURN,NIL);
    if (setjmp(cntxt.c_jmpbuf))
	val = xlvalue;
    else {

	/* get the list of bindings and bind the symbols */
	if (!pflag) xlenv = newenv;
	dobindings(xlgalist(),newenv);
	if (pflag) xlenv = newenv;

	/* execute the code */
	tagbody();
	val = NIL;

	/* unbind the arguments */
	xlenv = cdr(xlenv);
    }
    xlend(&cntxt);

    /* restore the stack */
    xlpop();

    /* return the result */
    return (val);
}

/* xgo - special form 'go' */
LVAL xgo()
{
    LVAL label;

    /* get the target label */
    label = xlgetarg();
    xllastarg();

    /* transfer to the label */
    xlgo(label);
}

/* xreturn - special form 'return' */
LVAL xreturn()
{
    LVAL val;

    /* get the return value */
    val = (moreargs() ? xleval(nextarg()) : NIL);
    xllastarg();

    /* return from the inner most block */
    xlreturn(NIL,val);
}

/* xrtnfrom - special form 'return-from' */
LVAL xrtnfrom()
{
    LVAL name,val;

    /* get the return value */
    name = xlgasymbol();
    val = (moreargs() ? xleval(nextarg()) : NIL);
    xllastarg();

    /* return from the inner most block */
    xlreturn(name,val);
}

/* xprog1 - special form 'prog1' */
LVAL xprog1()
{
    return (progx(1));
}

/* xprog2 - special form 'prog2' */
LVAL xprog2()
{
    return (progx(2));
}

/* progx - common progx code */
LOCAL LVAL progx(n)
  int n;
{
    LVAL val;

    /* protect some pointers */
    xlsave1(val);

    /* evaluate the first n expressions */
    while (moreargs() && --n >= 0)
	val = xleval(nextarg());

    /* evaluate each remaining argument */
    while (moreargs())
	xleval(nextarg());

    /* restore the stack */
    xlpop();

    /* return the last test expression value */
    return (val);
}

/* xprogn - special form 'progn' */
LVAL xprogn()
{
    LVAL val;

    /* evaluate each expression */
    for (val = NIL; moreargs(); )
	val = xleval(nextarg());

    /* return the last test expression value */
    return (val);
}

/* xprogv - special form 'progv' */
LVAL xprogv()
{
    LVAL olddenv,vars,vals,val;

    /* protect some pointers */
    xlstkcheck(2);
    xlsave(vars);
    xlsave(vals);

    /* get the list of variables and the list of values */
    vars = xlgalist(); vars = xleval(vars);
    vals = xlgalist(); vals = xleval(vals);

    /* bind the values to the variables */
    for (olddenv = xldenv; consp(vars); vars = cdr(vars)) {
	if (!symbolp(car(vars)))
	    xlerror("expecting a symbol",car(vars));
	if (consp(vals)) {
	    xldbind(car(vars),car(vals));
	    vals = cdr(vals);
	}
	else
	    xldbind(car(vars),s_unbound);
    }

    /* evaluate each expression */
    for (val = NIL; moreargs(); )
	val = xleval(nextarg());

    /* restore the previous environment and the stack */
    xlunbind(olddenv);
    xlpopn(2);

    /* return the last test expression value */
    return (val);
}

/* xloop - special form 'loop' */
LVAL xloop()
{
    LVAL *argv,arg,val;
    CONTEXT cntxt;
    int argc;

    /* protect some pointers */
    xlsave1(arg);

    /* establish a new execution context */
    xlbegin(&cntxt,CF_RETURN,NIL);
    if (setjmp(cntxt.c_jmpbuf))
	val = xlvalue;
    else
	for (argv = xlargv, argc = xlargc; ; xlargv = argv, xlargc = argc)
	    while (moreargs()) {
		arg = nextarg();
		if (consp(arg))
		    xleval(arg);
	    }
    xlend(&cntxt);

    /* restore the stack */
    xlpop();

    /* return the result */
    return (val);
}

/* xdo - special form 'do' */
LVAL xdo()
{
    return (doloop(TRUE));
}

/* xdostar - special form 'do*' */
LVAL xdostar()
{
    return (doloop(FALSE));
}

/* doloop - common do routine */
LOCAL LVAL doloop(pflag)
  int pflag;
{
    LVAL newenv,*argv,blist,clist,test,val;
    CONTEXT cntxt;
    int argc;

    /* protect some pointers */
    xlsave1(newenv);

    /* get the list of bindings, the exit test and the result forms */
    blist = xlgalist();
    clist = xlgalist();
    test = (consp(clist) ? car(clist) : NIL);
    argv = xlargv;
    argc = xlargc;

    /* create a new environment frame */
    newenv = xlframe(xlenv);

    /* establish a new execution context */
    xlbegin(&cntxt,CF_RETURN,NIL);
    if (setjmp(cntxt.c_jmpbuf))
	val = xlvalue;
    else {

	/* bind the symbols */
	if (!pflag) xlenv = newenv;
	dobindings(blist,newenv);
	if (pflag) xlenv = newenv;

	/* execute the loop as long as the test is false */
	for (val = NIL; xleval(test) == NIL; doupdates(blist,pflag)) {
	    xlargv = argv;
	    xlargc = argc;
	    tagbody();
	}

	/* evaluate the result expression */
	if (consp(clist))
	    for (clist = cdr(clist); consp(clist); clist = cdr(clist))
		val = xleval(car(clist));

	/* unbind the arguments */
	xlenv = cdr(xlenv);
    }
    xlend(&cntxt);

    /* restore the stack */
    xlpop();

    /* return the result */
    return (val);
}

/* xdolist - special form 'dolist' */
LVAL xdolist()
{
    LVAL list,*argv,clist,sym,val;
    CONTEXT cntxt;
    int argc;

    /* protect some pointers */
    xlsave1(list);

    /* get the control list (sym list result-expr) */
    clist = xlgalist();
    sym = match(SYMBOL,&clist);
    list = evmatch(LIST,&clist);
    argv = xlargv;
    argc = xlargc;

    /* initialize the local environment */
    xlenv = xlframe(xlenv);
    xlbind(sym,NIL);

    /* establish a new execution context */
    xlbegin(&cntxt,CF_RETURN,NIL);
    if (setjmp(cntxt.c_jmpbuf))
	val = xlvalue;
    else {

	/* loop through the list */
	for (val = NIL; consp(list); list = cdr(list)) {

	    /* bind the symbol to the next list element */
	    xlsetvalue(sym,car(list));

	    /* execute the loop body */
	    xlargv = argv;
	    xlargc = argc;
	    tagbody();
	}

	/* evaluate the result expression */
	xlsetvalue(sym,NIL);
	val = (consp(clist) ? xleval(car(clist)) : NIL);

	/* unbind the arguments */
	xlenv = cdr(xlenv);
    }
    xlend(&cntxt);

    /* restore the stack */
    xlpop();

    /* return the result */
    return (val);
}

/* xdotimes - special form 'dotimes' */
LVAL xdotimes()
{
    LVAL *argv,clist,sym,cnt,val;
    CONTEXT cntxt;
    int argc,n,i;

    /* get the control list (sym list result-expr) */
    clist = xlgalist();
    sym = match(SYMBOL,&clist);
    cnt = evmatch(FIXNUM,&clist); n = getfixnum(cnt);
    argv = xlargv;
    argc = xlargc;

    /* initialize the local environment */
    xlenv = xlframe(xlenv);
    xlbind(sym,NIL);

    /* establish a new execution context */
    xlbegin(&cntxt,CF_RETURN,NIL);
    if (setjmp(cntxt.c_jmpbuf))
	val = xlvalue;
    else {

	/* loop through for each value from zero to n-1 */
	for (val = NIL, i = 0; i < n; ++i) {

	    /* bind the symbol to the next list element */
	    xlsetvalue(sym,cvfixnum((FIXTYPE)i));

	    /* execute the loop body */
	    xlargv = argv;
	    xlargc = argc;
	    tagbody();
	}

	/* evaluate the result expression */
	xlsetvalue(sym,cnt);
	val = (consp(clist) ? xleval(car(clist)) : NIL);

	/* unbind the arguments */
	xlenv = cdr(xlenv);
    }
    xlend(&cntxt);

    /* return the result */
    return (val);
}

/* xblock - special form 'block' */
LVAL xblock()
{
    LVAL name,val;
    CONTEXT cntxt;

    /* get the block name */
    name = xlgetarg();
    if (name && !symbolp(name))
	xlbadtype(name);

    /* execute the block */
    xlbegin(&cntxt,CF_RETURN,name);
    if (setjmp(cntxt.c_jmpbuf))
	val = xlvalue;
    else
	for (val = NIL; moreargs(); )
	    val = xleval(nextarg());
    xlend(&cntxt);

    /* return the value of the last expression */
    return (val);
}

/* xtagbody - special form 'tagbody' */
LVAL xtagbody()
{
    tagbody();
    return (NIL);
}

/* xcatch - special form 'catch' */
LVAL xcatch()
{
    CONTEXT cntxt;
    LVAL tag,val;

    /* protect some pointers */
    xlsave1(tag);

    /* get the tag */
    tag = xleval(nextarg());

    /* establish an execution context */
    xlbegin(&cntxt,CF_THROW,tag);

    /* check for 'throw' */
    if (setjmp(cntxt.c_jmpbuf))
	val = xlvalue;

    /* otherwise, evaluate the remainder of the arguments */
    else {
	for (val = NIL; moreargs(); )
	    val = xleval(nextarg());
    }
    xlend(&cntxt);

    /* restore the stack */
    xlpop();

    /* return the result */
    return (val);
}

/* xthrow - special form 'throw' */
LVAL xthrow()
{
    LVAL tag,val;

    /* get the tag and value */
    tag = xleval(nextarg());
    val = (moreargs() ? xleval(nextarg()) : NIL);
    xllastarg();

    /* throw the tag */
    xlthrow(tag,val);
}

/* xunwindprotect - special form 'unwind-protect' */
LVAL xunwindprotect()
{
    extern CONTEXT *xltarget;
    extern int xlmask;
    CONTEXT cntxt,*target;
    int mask,sts;
    LVAL val;

    /* protect some pointers */
    xlsave1(val);

    /* get the expression to protect */
    val = xlgetarg();

    /* evaluate the protected expression */
    xlbegin(&cntxt,CF_UNWIND,NIL);
    if (sts = setjmp(cntxt.c_jmpbuf)) {
	target = xltarget;
	mask = xlmask;
	val = xlvalue;
    }
    else
	val = xleval(val);
    xlend(&cntxt);
	
    /* evaluate the cleanup expressions */
    while (moreargs())
	xleval(nextarg());

    /* if unwinding, continue unwinding */
    if (sts)
	xljump(target,mask,val);

    /* restore the stack */
    xlpop();

    /* return the value of the protected expression */
    return (val);
}

/* xerrset - special form 'errset' */
LVAL xerrset()
{
    LVAL expr,flag,val;
    CONTEXT cntxt;

    /* get the expression and the print flag */
    expr = xlgetarg();
    flag = (moreargs() ? xlgetarg() : true);
    xllastarg();

    /* establish an execution context */
    xlbegin(&cntxt,CF_ERROR,flag);

    /* check for error */
    if (setjmp(cntxt.c_jmpbuf))
	val = NIL;

    /* otherwise, evaluate the expression */
    else {
	expr = xleval(expr);
	val = consa(expr);
    }
    xlend(&cntxt);

    /* return the result */
    return (val);
}

/* xtrace - special form 'trace' */
LVAL xtrace()
{
    LVAL sym,fun,this;

    /* loop through all of the arguments */
    sym = xlenter("*TRACELIST*");
    while (moreargs()) {
	fun = xlgasymbol();

	/* check for the function name already being in the list */
	for (this = getvalue(sym); consp(this); this = cdr(this))
	    if (car(this) == fun)
		break;

	/* add the function name to the list */
	if (null(this))
	    setvalue(sym,cons(fun,getvalue(sym)));
    }
    return (getvalue(sym));
}

/* xuntrace - special form 'untrace' */
LVAL xuntrace()
{
    LVAL sym,fun,this,last;

    /* loop through all of the arguments */
    sym = xlenter("*TRACELIST*");
    while (moreargs()) {
	fun = xlgasymbol();

	/* remove the function name from the list */
	last = NIL;
	for (this = getvalue(sym); consp(this); this = cdr(this)) {
	    if (car(this) == fun) {
		if (last)
		    rplacd(last,cdr(this));
		else
		    setvalue(sym,cdr(this));
		break;
	    }
	    last = this;
	}
    }
    return (getvalue(sym));
}

/* dobindings - handle bindings for let/let*, prog/prog*, do/do* */
LOCAL dobindings(list,env)
  LVAL list,env;
{
    LVAL bnd,sym,val;

    /* protect some pointers */
    xlsave1(val);

    /* bind each symbol in the list of bindings */
    for (; consp(list); list = cdr(list)) {

	/* get the next binding */
	bnd = car(list);

	/* handle a symbol */
	if (symbolp(bnd)) {
	    sym = bnd;
	    val = NIL;
	}

	/* handle a list of the form (symbol expr) */
	else if (consp(bnd)) {
	    sym = match(SYMBOL,&bnd);
	    val = evarg(&bnd);
	}
	else
	    xlfail("bad binding");

	/* bind the value to the symbol */
	xlpbind(sym,val,env);
    }

    /* restore the stack */
    xlpop();
}

/* doupdates - handle updates for do/do* */
LOCAL doupdates(list,pflag)
  LVAL list; int pflag;
{
    LVAL plist,bnd,sym,val;

    /* protect some pointers */
    xlstkcheck(2);
    xlsave(plist);
    xlsave(val);

    /* bind each symbol in the list of bindings */
    for (; consp(list); list = cdr(list)) {

	/* get the next binding */
	bnd = car(list);

	/* handle a list of the form (symbol expr) */
	if (consp(bnd)) {
	    sym = match(SYMBOL,&bnd);
	    bnd = cdr(bnd);
	    if (bnd) {
		val = evarg(&bnd);
		if (pflag)
		    plist = cons(cons(sym,val),plist);
		else
		    xlsetvalue(sym,val);
	    }
	}
    }

    /* set the values for parallel updates */
    for (; plist; plist = cdr(plist))
	xlsetvalue(car(car(plist)),cdr(car(plist)));

    /* restore the stack */
    xlpopn(2);
}

/* tagbody - execute code within a block and tagbody */
LOCAL tagbody()
{
    LVAL *argv,arg;
    CONTEXT cntxt;
    int argc;

    /* establish an execution context */
    xlbegin(&cntxt,CF_GO,NIL);
    argc = xlargc;
    argv = xlargv;

    /* check for a 'go' */
    if (setjmp(cntxt.c_jmpbuf)) {
	cntxt.c_xlargc = argc;
	cntxt.c_xlargv = argv;
    }

    /* execute the body */
    while (moreargs()) {
	arg = nextarg();
	if (consp(arg))
	    xleval(arg);
    }
    xlend(&cntxt);
}

/* match - get an argument and match its type */
LOCAL LVAL match(type,pargs)
  int type; LVAL *pargs;
{
    LVAL arg;

    /* make sure the argument exists */
    if (!consp(*pargs))
	toofew(*pargs);

    /* get the argument value */
    arg = car(*pargs);

    /* move the argument pointer ahead */
    *pargs = cdr(*pargs);

    /* check its type */
    if (type == LIST) {
	if (arg && ntype(arg) != CONS)
	    xlerror("bad argument type",arg);
    }
    else {
	if (arg == NIL || ntype(arg) != type)
	    xlerror("bad argument type",arg);
    }

    /* return the argument */
    return (arg);
}

/* evarg - get the next argument and evaluate it */
LOCAL LVAL evarg(pargs)
  LVAL *pargs;
{
    LVAL arg;

    /* protect some pointers */
    xlsave1(arg);

    /* make sure the argument exists */
    if (!consp(*pargs))
	toofew(*pargs);

    /* get the argument value */
    arg = car(*pargs);

    /* move the argument pointer ahead */
    *pargs = cdr(*pargs);

    /* evaluate the argument */
    arg = xleval(arg);

    /* restore the stack */
    xlpop();

    /* return the argument */
    return (arg);
}

/* evmatch - get an evaluated argument and match its type */
LOCAL LVAL evmatch(type,pargs)
  int type; LVAL *pargs;
{
    LVAL arg;

    /* protect some pointers */
    xlsave1(arg);

    /* make sure the argument exists */
    if (!consp(*pargs))
	toofew(*pargs);

    /* get the argument value */
    arg = car(*pargs);

    /* move the argument pointer ahead */
    *pargs = cdr(*pargs);

    /* evaluate the argument */
    arg = xleval(arg);

    /* check its type */
    if (type == LIST) {
	if (arg && ntype(arg) != CONS)
	    xlerror("bad argument type",arg);
    }
    else {
	if (arg == NIL || ntype(arg) != type)
	    xlerror("bad argument type",arg);
    }

    /* restore the stack */
    xlpop();

    /* return the argument */
    return (arg);
}

/* toofew - too few arguments */
LOCAL toofew(args)
  LVAL args;
{
    xlerror("too few arguments",args);
}

/* toomany - too many arguments */
LOCAL toomany(args)
  LVAL args;
{
    xlerror("too many arguments",args);
}


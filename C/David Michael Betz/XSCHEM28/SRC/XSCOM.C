/* xscom.c - a simple scheme bytecode compiler */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"
#include "xsbcode.h"

/* size of code buffer */
#define CMAX	4000

/* continuation types */
#define C_RETURN	-1
#define C_NEXT		-2

/* macro to check for a lambda list keyword */
#define lambdakey(x)	((x) == lk_optional || (x) == lk_rest)

/* external variables */
extern LVAL lk_optional,lk_rest,true;

/* local variables */
static LVAL info;		/* compiler info */

/* code buffer */
static unsigned char cbuff[CMAX];	/* base of code buffer */
static int cbase;			/* base for current function */
static int cptr;			/* code buffer pointer */

/* forward declarations */
#ifdef __STDC__
static void do_expr(LVAL expr,int cont);
static int in_ntab(LVAL expr,int cont);
static int in_ftab(LVAL expr,int cont);
static void do_define(LVAL form,int cont);
static void define1(LVAL list,LVAL body,int cont);
static void do_set(LVAL form,int cont);
static void do_setvar(LVAL form,int cont);
static void do_quote(LVAL form,int cont);
static void do_lambda(LVAL form,int cont);
static void cd_fundefinition(LVAL fun,LVAL fargs,LVAL body);
static void parse_lambda_list(LVAL fargs,LVAL body);
static int find_internal_definitions(LVAL body,LVAL last);
static void do_delay(LVAL form,int cont);
static void do_let(LVAL form,int cont);
static void do_named_let(LVAL form,int cont);
static void cd_let(LVAL name,LVAL form,int cont);
static void do_letrec(LVAL form,int cont);
static void do_letstar(LVAL form,int cont);
static void letstar1(LVAL blist,LVAL body);
static int push_dummy_values(LVAL blist);
static int push_init_expressions(LVAL blist);
static void parse_let_variables(LVAL blist,LVAL body);
static void set_bound_variables(LVAL blist);
static LVAL make_code_object(LVAL fun);
static void do_cond(LVAL form,int cont);
static void do_and(LVAL form,int cont);
static void do_or(LVAL form,int cont);
static void do_if(LVAL form,int cont);
static void do_begin(LVAL form,int cont);
static void do_while(LVAL form,int cont);
static void do_access(LVAL form,int cont);
static void do_setaccess(LVAL form,int cont);
static void do_call(LVAL form,int cont);
static int push_args(LVAL form);
static void do_nary(int op,int n,LVAL form,int cont);
static int push_nargs(LVAL form,int n);
static void do_literal(LVAL lit,int cont);
static void do_identifier(LVAL sym,int cont);
static void do_continuation(int cont);
static int add_level(void);
static void remove_level(int oldcbase);
static int findvariable(LVAL sym,int *plev,int *poff);
static int findcvariable(LVAL sym,int *poff);
static int findliteral(LVAL lit);
static void cd_variable(int op,LVAL sym);
static void cd_evariable(int op,int lev,int off);
static void cd_literal(LVAL lit);
static int putcbyte(int b);
static int putcword(int w);
static void fixup(int chn);
#else
static void do_define(),do_set(),do_quote(),do_lambda(),do_delay();
static void do_let(),do_letrec(),do_letstar(),do_cond(),do_and(),do_or();
static void do_if(),do_begin(),do_while(),do_access();
static LVAL make_code_object();
#endif

/* integrable function table */
typedef struct { char *nt_name; int nt_code,nt_args; } NTDEF;
static NTDEF *nptr,ntab[] = {
	"ATOM",			OP_ATOM,	1,
	"EQ?",			OP_EQ,		2,
	"NULL?",		OP_NULL,	1,
	"NOT",			OP_NULL,	1,
	"CONS",			OP_CONS,	2,
	"CAR",			OP_CAR,		1,
	"CDR",			OP_CDR,		1,
	"SET-CAR!",		OP_SETCAR,	2,
	"SET-CDR!",		OP_SETCDR,	2,
	"+",			OP_ADD,		-2,
	"-",			OP_SUB,		-2,
	"*",			OP_MUL,		-2,
	"QUOTIENT",		OP_QUO,		-2,
	"<",			OP_LSS,		-2,
	"=",			OP_EQL,		-2,
	">",			OP_GTR,		-2,
	0
};

/* special form table */
typedef struct { char *ft_name; void (*ft_fcn)(); } FTDEF;
static FTDEF ftab[] = {
	"QUOTE",	do_quote,
	"LAMBDA",	do_lambda,
	"DELAY",	do_delay,
	"LET",		do_let,
	"LET*",		do_letstar,
	"LETREC",	do_letrec,
	"DEFINE",	do_define,
	"SET!",		do_set,
	"IF",		do_if,
	"COND",		do_cond,
	"BEGIN",	do_begin,
	"SEQUENCE",	do_begin,
	"AND",		do_and,
	"OR",		do_or,
	"WHILE",	do_while,
	"ACCESS",	do_access,
	0
};

/* xlcompile - compile an expression */
LVAL xlcompile(expr,ctenv)
  LVAL expr,ctenv;
{
    /* initialize the compile time environment */
    info = cons(NIL,NIL); cpush(info);
    rplaca(info,newframe(ctenv,1));
    rplacd(info,cons(NIL,NIL));

    /* setup the base of the code for this function */
    cbase = cptr = 0;

    /* setup the entry code */
    putcbyte(OP_FRAME);
    putcbyte(1);

    /* compile the expression */
    do_expr(expr,C_RETURN);

    /* build the code object */
    settop(make_code_object(NIL));
    return (pop());
}

/* xlfunction - compile a function */
LVAL xlfunction(fun,fargs,body,ctenv)
  LVAL fun,fargs,body,ctenv;
{
    /* initialize the compile time environment */
    info = cons(NIL,NIL); cpush(info);
    rplaca(info,newframe(ctenv,1));
    rplacd(info,cons(NIL,NIL));

    /* setup the base of the code for this function */
    cbase = cptr = 0;

    /* compile the lambda list and the function body */
    parse_lambda_list(fargs,body);
    do_begin(body,C_RETURN);

    /* build the code object */
    settop(make_code_object(fun));
    return (pop());
}

/* do_expr - compile an expression */
static void do_expr(expr,cont)
  LVAL expr; int cont;
{
    LVAL fun;
    if (consp(expr)) {
	fun = car(expr);
 	if (!symbolp(fun) || (!in_ntab(expr,cont) && !in_ftab(expr,cont)))
	    do_call(expr,cont);
    }
    else if (symbolp(expr))
	do_identifier(expr,cont);
    else
	do_literal(expr,cont);
}

/* in_ntab - check for a function in ntab */
static int in_ntab(expr,cont)
  LVAL expr; int cont;
{
    char *pname;
    pname = getstring(getpname(car(expr)));
    for (nptr = ntab; nptr->nt_name; ++nptr)
	if (strcmp(pname,nptr->nt_name) == 0) {
	    do_nary(nptr->nt_code,nptr->nt_args,expr,cont);
	    return (TRUE);
	}
    return (FALSE);
}

/* in_ftab - check for a function in ftab */
static int in_ftab(expr,cont)
  LVAL expr; int cont;
{
    char *pname;
    FTDEF *fptr;
    pname = getstring(getpname(car(expr)));
    for (fptr = ftab; fptr->ft_name; ++fptr)
	if (strcmp(pname,fptr->ft_name) == 0) {
	    (*fptr->ft_fcn)(cdr(expr),cont);
	    return (TRUE);
	}
    return (FALSE);
}

/* do_define - handle the (DEFINE ... ) expression */
static void do_define(form,cont)
  LVAL form; int cont;
{
    if (atom(form))
	xlerror("expecting symbol or function template",form);
    define1(car(form),cdr(form),cont);
}

/* define1 - helper routine for do_define */
static void define1(list,body,cont)
  LVAL list,body; int cont;
{
    LVAL fargs;
    int off;

    /* handle nested definitions */
    if (consp(list)) {
	cpush(cons(xlenter("LAMBDA"),NIL));	/* (LAMBDA) */
	rplacd(top(),cons(cdr(list),NIL));	/* (LAMBDA args) */
	rplacd(cdr(top()),body);		/* (LAMBDA args body) */
	settop(cons(top(),NIL));		/* ((LAMBDA args body)) */
	define1(car(list),top(),cont);
	drop(1);
    }
    
    /* compile procedure definitions */
    else {

	/* make sure it's a symbol */
	if (!symbolp(list))
	    xlerror("expecting a symbol",list);

	/* check for a procedure definition */
	if (consp(body)
        &&  consp(car(body))
        &&  car(car(body)) == xlenter("LAMBDA")) {
	    fargs = car(cdr(car(body)));
	    body = cdr(cdr(car(body)));
	    cd_fundefinition(list,fargs,body);
	}

	/* compile the value expression or procedure body */
	else
	    do_begin(body,C_NEXT);
    
	/* define the variable value */
	if (findcvariable(list,&off))
	    cd_evariable(OP_ESET,0,off);
	else
	    cd_variable(OP_GSET,list);
	do_literal(list,cont);
    }
}

/* do_set - compile the (SET! ... ) expression */
static void do_set(form,cont)
  LVAL form; int cont;
{
    if (atom(form))
	xlerror("expecting symbol or ACCESS form",form);
    else if (symbolp(car(form)))
	do_setvar(form,cont);
    else if (consp(car(form)))
	do_setaccess(form,cont);
    else
	xlerror("expecting symbol or ACCESS form",form);
}

/* do_setvar - compile the (SET! var value) expression */
static void do_setvar(form,cont)
  LVAL form; int cont;
{
    int lev,off;
    LVAL sym;

    /* get the variable name */
    sym = car(form);

    /* compile the value expression */
    form = cdr(form);
    if (atom(form))
	xlerror("expecting value expression",form);
    do_expr(car(form),C_NEXT);

    /* set the variable value */
    if (findvariable(sym,&lev,&off))
	cd_evariable(OP_ESET,lev,off);
    else
	cd_variable(OP_GSET,sym);
    do_continuation(cont);
}

/* do_quote - compile the (QUOTE ... ) expression */
static void do_quote(form,cont)
  LVAL form; int cont;
{
    if (atom(form))
	xlerror("expecting quoted expression",form);
    do_literal(car(form),cont);
}

/* do_lambda - compile the (LAMBDA ... ) expression */
static void do_lambda(form,cont)
  LVAL form; int cont;
{
    if (atom(form))
	xlerror("expecting argument list",form);
    cd_fundefinition(NIL,car(form),cdr(form));
    do_continuation(cont);
}

/* cd_fundefinition - compile the function */
static void cd_fundefinition(fun,fargs,body)
  LVAL fun,fargs,body;
{
    int oldcbase;

    /* establish a new environment frame */
    oldcbase = add_level();

    /* compile the lambda list and the function body */
    parse_lambda_list(fargs,body);
    do_begin(body,C_RETURN);

    /* build the code object */
    cpush(make_code_object(fun));
    
    /* restore the previous environment */
    remove_level(oldcbase);

    /* compile code to create a closure */
    do_literal(pop(),C_NEXT);
    putcbyte(OP_CLOSE);
}

/* parse_lambda_list - parse the formal argument list */
static void parse_lambda_list(fargs,body)
  LVAL fargs,body;
{
    LVAL arg,restarg,new,last;
    int frame,slotn;
    
    /* setup the entry code */
    putcbyte(OP_FRAME);
    frame = putcbyte(0);

    /* initialize the argument name list and slot number */
    restarg = last = NIL;
    slotn = 1;
    
    /* handle each required argument */
    while (consp(fargs)
    &&     (arg = car(fargs)) != NIL
    &&     !lambdakey(arg)) {

	/* make sure the argument is a symbol */
	if (!symbolp(arg))
	    xlerror("variable must be a symbol",arg);

	/* add the argument name to the name list */
	new = cons(arg,NIL);
	if (last) rplacd(last,new);
	else setelement(car(car(info)),0,new);
	last = new;

	/* generate an instruction to move the argument into the frame */
	putcbyte(OP_MVARG);
	putcbyte(slotn++);
	
	/* move the formal argument list pointer ahead */
	fargs = cdr(fargs);
    }

    /* check for the '#!optional' argument */
    if (consp(fargs)
    &&  car(fargs) == lk_optional) {
	fargs = cdr(fargs);

	/* handle each optional argument */
	while (consp(fargs)
	&&     (arg = car(fargs)) != NIL
	&&     !lambdakey(arg)) {

	    /* make sure the argument is a symbol */
	    if (!symbolp(arg))
		xlerror("#!optional variable must be a symbol",arg);

	    /* add the argument name to the name list */
	    new = cons(arg,NIL);
	    if (last) rplacd(last,new);
	    else setelement(car(car(info)),0,new);
	    last = new;

	    /* move the argument into the frame */
	    putcbyte(OP_MVOARG);
	    putcbyte(slotn++);
	
	    /* move the formal argument list pointer ahead */
	    fargs = cdr(fargs);
	}
    }

    /* check for the '#!rest' argument */
    if (consp(fargs)
    &&  car(fargs) == lk_rest) {
	fargs = cdr(fargs);

	/* handle the rest argument */
	if (consp(fargs)
	&&  (restarg = car(fargs)) != NIL
	&&  !lambdakey(restarg)) {

	    /* make sure the argument is a symbol */
	    if (!symbolp(restarg))
		xlerror("#!rest variable must be a symbol",restarg);

	    /* add the argument name to the name list */
	    new = cons(restarg,NIL);
	    if (last) rplacd(last,new);
	    else setelement(car(car(info)),0,new);
	    last = new;

	    /* make the #!rest argument list */
	    putcbyte(OP_MVRARG);
	    putcbyte(slotn++);

	    /* move the formal argument list pointer ahead */
	    fargs = cdr(fargs);
	}
	else
	    xlerror("expecting the #!rest variable",fargs);
    }

    /* check for the a dotted tail */
    if (restarg == NIL && symbolp(fargs)) {
	restarg = fargs;

	/* add the argument name to the name list */
	new = cons(restarg,NIL);
	if (last) rplacd(last,new);
	else setelement(car(car(info)),0,new);
	last = new;

	/* make the #!rest argument list */
	putcbyte(OP_MVRARG);
	putcbyte(slotn++);
	fargs = NIL;
    }

    /* check for the end of the argument list */
    if (fargs != NIL)
	xlerror("bad argument list tail",fargs);

    /* make sure the user didn't supply too many arguments */
    if (restarg == NIL)
	putcbyte(OP_ALAST);
	
    /* scan the body for internal definitions */
    slotn += find_internal_definitions(body,last);
	
    /* fixup the frame instruction */
    cbuff[cbase+frame] = slotn;
}

/* find_internal_definitions - find internal definitions */
static int find_internal_definitions(body,last)
  LVAL body,last;
{
    LVAL define,sym,new;
    int n=0;

    /* look for all (define...) forms */
    for (define = xlenter("DEFINE"); consp(body); body = cdr(body))
	if (consp(car(body)) && car(car(body)) == define) {
	    sym = cdr(car(body)); /* the rest of the (define...) form */
	    if (consp(sym)) {     /* make sure there is a second subform */
		sym = car(sym);   /* get the second subform */
		while (consp(sym))/* check for a procedure definition */
		    sym = car(sym);
		if (symbolp(sym)) {
		    new = cons(sym,NIL);
		    if (last) rplacd(last,new);
		    else setelement(car(car(info)),0,new);
		    last = new;
		    ++n;
		}
	    }
	}
    return (n);
}

/* do_delay - compile the (DELAY ... ) expression */
static void do_delay(form,cont)
  LVAL form; int cont;
{
    int oldcbase;

    /* check argument list */
    if (atom(form))
	xlerror("expecting delay expression",form);

    /* establish a new environment frame */
    oldcbase = add_level();

    /* setup the entry code */
    putcbyte(OP_FRAME);
    putcbyte(1);

    /* compile the expression */
    do_expr(car(form),C_RETURN);

    /* build the code object */
    cpush(make_code_object(NIL));
    
    /* restore the previous environment */
    remove_level(oldcbase);

    /* compile code to create a closure */
    do_literal(pop(),C_NEXT);
    putcbyte(OP_DELAY);
    do_continuation(cont);
}

/* do_let - compile the (LET ... ) expression */
static void do_let(form,cont)
  LVAL form; int cont;
{
    /* handle named let */
    if (consp(form) && symbolp(car(form)))
	do_named_let(form,cont);
    
    /* handle unnamed let */
    else
        cd_let(NIL,form,cont);
}

/* do_named_let - compile the (LET name ... ) expression */
static void do_named_let(form,cont)
  LVAL form; int cont;
{
    int oldcbase,nxt;

    /* save a continuation */
    if (cont != C_RETURN) {
	putcbyte(OP_SAVE);
	nxt = putcword(0);
    }
    
    /* establish a new environment frame */
    oldcbase = add_level();
    setelement(car(car(info)),0,cons(car(form),NIL));

    /* setup the entry code */
    putcbyte(OP_FRAME);
    putcbyte(2);
    
    /* compile the let expression */
    cd_let(car(form),cdr(form),C_RETURN);

    /* build the code object */
    cpush(make_code_object(NIL));
    
    /* restore the previous environment */
    remove_level(oldcbase);

    /* compile code to create a closure */
    do_literal(pop(),C_NEXT);
    putcbyte(OP_CLOSE);

    /* apply the function */
    putcbyte(OP_CALL);
    putcbyte(1);

    /* target for the continuation */
    if (cont != C_RETURN)
	fixup(nxt);
}

/* cd_let - code a let expression */
static void cd_let(name,form,cont)
  LVAL name,form; int cont;
{
    int oldcbase,nxt,lev,off,n;

    /* make sure there is a binding list */
    if (atom(form) || !listp(car(form)))
	xlerror("expecting binding list",form);

    /* save a continuation */
    if (cont != C_RETURN) {
	putcbyte(OP_SAVE);
	nxt = putcword(0);
    }
    
    /* push the initialization expressions */
    n = push_init_expressions(car(form));

    /* establish a new environment frame */
    oldcbase = add_level();

    /* compile the binding list */
    parse_let_variables(car(form),cdr(form));

    /* compile the body of the let/letrec */
    do_begin(cdr(form),C_RETURN);

    /* build the code object */
    cpush(make_code_object(NIL));
    
    /* restore the previous environment */
    remove_level(oldcbase);

    /* compile code to create a closure */
    do_literal(pop(),C_NEXT);
    putcbyte(OP_CLOSE);

    /* store the procedure */
    if (name && findvariable(name,&lev,&off))
	cd_evariable(OP_ESET,lev,off);

    /* apply the function */
    putcbyte(OP_CALL);
    putcbyte(n);

    /* target for the continuation */
    if (cont != C_RETURN)
	fixup(nxt);
}

/* do_letrec - compile the (LETREC ... ) expression */
static void do_letrec(form,cont)
  LVAL form; int cont;
{
    int oldcbase,nxt,n;

    /* make sure there is a binding list */
    if (atom(form) || !listp(car(form)))
	xlerror("expecting binding list",form);

    /* save a continuation */
    if (cont != C_RETURN) {
	putcbyte(OP_SAVE);
	nxt = putcword(0);
    }
    
    /* push the initialization expressions */
    n = push_dummy_values(car(form));

    /* establish a new environment frame */
    oldcbase = add_level();

    /* compile the binding list */
    parse_let_variables(car(form),cdr(form));

    /* compile instructions to set the bound variables */
    set_bound_variables(car(form));
    
    /* compile the body of the let/letrec */
    do_begin(cdr(form),C_RETURN);

    /* build the code object */
    cpush(make_code_object(NIL));
    
    /* restore the previous environment */
    remove_level(oldcbase);

    /* compile code to create a closure */
    do_literal(pop(),C_NEXT);
    putcbyte(OP_CLOSE);

    /* apply the function */
    putcbyte(OP_CALL);
    putcbyte(n);

    /* target for the continuation */
    if (cont != C_RETURN)
	fixup(nxt);
}

/* do_letstar - compile the (LET* ... ) expression */
static void do_letstar(form,cont)
  LVAL form; int cont;
{
    int nxt;
    
    /* make sure there is a binding list */
    if (atom(form) || !listp(car(form)))
	xlerror("expecting binding list",form);

    /* handle the case where there are bindings */
    if (consp(car(form))) {
    
	/* save a continuation */
	if (cont != C_RETURN) {
	    putcbyte(OP_SAVE);
	    nxt = putcword(0);
	}
    
	/* build the nested lambda expressions */
	letstar1(car(form),cdr(form));
    
	/* target for the continuation */
	if (cont != C_RETURN)
	    fixup(nxt);
    }
    
    /* handle the case where there are no bindings */
    else
	do_begin(cdr(form),cont);
}

/* letstar1 - helper routine for let* */
static void letstar1(blist,body)
  LVAL blist,body;
{
    int oldcbase,n;

    /* push the next initialization expressions */
    cpush(cons(car(blist),NIL));
    n = push_init_expressions(top());

    /* establish a new environment frame */
    oldcbase = add_level();

    /* handle the case where there are more bindings */
    if (consp(cdr(blist))) {
	parse_let_variables(top(),NIL);
	letstar1(cdr(blist),body);
    }
    
    /* handle the last binding */
    else {
	parse_let_variables(top(),body);
	do_begin(body,C_RETURN);
    }
	
    /* build the code object */
    settop(make_code_object(NIL));
    
    /* restore the previous environment */
    remove_level(oldcbase);

    /* compile code to create a closure */
    do_literal(pop(),C_NEXT);
    putcbyte(OP_CLOSE);

    /* apply the function */
    putcbyte(OP_CALL);
    putcbyte(n);
}

/* push_dummy_values - push dummy values for a 'letrec' expression */
static int push_dummy_values(blist)
  LVAL blist;
{
    int n=0;
    if (consp(blist)) {
	putcbyte(OP_NIL);
	for (; consp(blist); blist = cdr(blist), ++n)
	    putcbyte(OP_PUSH);
    }
    return (n);
}

/* push_init_expressions - push init expressions for a 'let' expression */
static int push_init_expressions(blist)
  LVAL blist;
{
    int n;
    if (consp(blist)) {
	n = push_init_expressions(cdr(blist));
	if (consp(car(blist)) && consp(cdr(car(blist))))
	    do_expr(car(cdr(car(blist))),C_NEXT);
	else
	    putcbyte(OP_NIL);
	putcbyte(OP_PUSH);
	return (n+1);
    }
    return (0);
}

/* parse_let_variables - parse the binding list */
static void parse_let_variables(blist,body)
  LVAL blist,body;
{
    LVAL arg,new,last;
    int frame,slotn;
    
    /* setup the entry code */
    putcbyte(OP_FRAME);
    frame = putcbyte(0);

    /* initialize the argument name list and slot number */
    last = NIL;
    slotn = 1;
    
    /* handle each required argument */
    while (consp(blist) && (arg = car(blist)) != NIL) {

	/* make sure the argument is a symbol */
	if (symbolp(arg))
	    new = cons(arg,NIL);
	else if (consp(arg) && symbolp(car(arg)))
	    new = cons(car(arg),NIL);
	else
	    xlerror("invalid binding",arg);

	/* add the argument name to the name list */
	if (last) rplacd(last,new);
	else setelement(car(car(info)),0,new);
	last = new;

	/* generate an instruction to move the argument into the frame */
	putcbyte(OP_MVARG);
	putcbyte(slotn++);
	
	/* move the formal argument list pointer ahead */
	blist = cdr(blist);
    }
    putcbyte(OP_ALAST);

    /* scan the body for internal definitions */
    slotn += find_internal_definitions(body,last);
	
    /* fixup the frame instruction */
    cbuff[cbase+frame] = slotn;
}

/* set_bound_variables - set bound variables in a 'letrec' expression */
static void set_bound_variables(blist)
  LVAL blist;
{
    int lev,off;
    for (; consp(blist); blist = cdr(blist)) {
	if (consp(car(blist)) && consp(cdr(car(blist)))) {
	    do_expr(car(cdr(car(blist))),C_NEXT);
	    if (findvariable(car(car(blist)),&lev,&off))
		cd_evariable(OP_ESET,lev,off);
	    else
		xlerror("compiler error -- can't find",car(car(blist)));
	}
    }
}

/* make_code_object - build a code object */
static LVAL make_code_object(fun)
  LVAL fun;
{
    unsigned char *cp;
    LVAL code,p;
    int i;

    /* create a code object */
    code = newcode(FIRSTLIT + length(car(cdr(info)))); cpush(code);
    setbcode(code,newstring(cptr - cbase));
    setcname(code,fun);			       	 /* function name */
    setvnames(code,getelement(car(car(info)),0));/* lambda list variables */

    /* copy the literals into the code object */
    for (i = FIRSTLIT, p = car(cdr(info)); consp(p); p = cdr(p), ++i)
	setelement(code,i,car(p));

    /* copy the byte codes */
    for (i = cbase, cp = (unsigned char *)getstring(getbcode(code)); i < cptr; )
	*cp++ = cbuff[i++];

    /* return the new code object */
    return (pop());
}

/* do_cond - compile the (COND ... ) expression */
static void do_cond(form,cont)
  LVAL form; int cont;
{
    int nxt,end;
    if (consp(form)) {
	for (end = 0; consp(form); form = cdr(form)) {
	    if (atom(car(form)))
		xlerror("expecting a cond clause",form);
	    do_expr(car(car(form)),C_NEXT);
	    putcbyte(OP_BRF);
	    nxt = putcword(0);
	    if (cdr(car(form)))
		do_begin(cdr(car(form)),cont);
	    else
		do_continuation(cont);
	    if (cont == C_NEXT) {
		putcbyte(OP_BR);
		end = putcword(end);
	    }
	    fixup(nxt);
	}
	fixup(end);
    }
    else
	putcbyte(OP_NIL);
    do_continuation(cont);
}

/* do_and - compile the (AND ... ) expression */
static void do_and(form,cont)
  LVAL form; int cont;
{
    int end;
    if (consp(form)) {
	for (end = 0; consp(form); form = cdr(form)) {
	    if (cdr(form)) {
		do_expr(car(form),C_NEXT);
		putcbyte(OP_BRF);
		end = putcword(end);
	    }
	    else
		do_expr(car(form),cont);
	}
	fixup(end);
    }
    else
	putcbyte(OP_T);
    do_continuation(cont);
}

/* do_or - compile the (OR ... ) expression */
static void do_or(form,cont)
  LVAL form; int cont;
{
    int end;
    if (consp(form)) {
	for (end = 0; consp(form); form = cdr(form)) {
	    if (cdr(form)) {
		do_expr(car(form),C_NEXT);
		putcbyte(OP_BRT);
		end = putcword(end);
	    }
	    else
		do_expr(car(form),cont);
	}
	fixup(end);
    }
    else
	putcbyte(OP_NIL);
    do_continuation(cont);
}

/* do_if - compile the (IF ... ) expression */
static void do_if(form,cont)
  LVAL form; int cont;
{
    int nxt,end;

    /* compile the test expression */
    if (atom(form))
	xlerror("expecting test expression",form);
    do_expr(car(form),C_NEXT);

    /* skip around the 'then' clause if the expression is false */
    putcbyte(OP_BRF);
    nxt = putcword(0);

    /* skip to the 'then' clause */
    form = cdr(form);
    if (atom(form))
	xlerror("expecting then clause",form);

    /* compile the 'then' and 'else' clauses */
    if (consp(cdr(form))) {
	if (cont == C_NEXT) {
	    do_expr(car(form),C_NEXT);
	    putcbyte(OP_BR);
	    end = putcword(0);
	}
	else {
	    do_expr(car(form),cont);
	    end = -1;
	}
	fixup(nxt);
	do_expr(car(cdr(form)),cont);
	nxt = end;
    }

    /* compile just a 'then' clause */
    else
	do_expr(car(form),cont);

    /* handle the end of the statement */
    if (nxt >= 0) {
	fixup(nxt);
	do_continuation(cont);
    }
}

/* do_begin - compile the (BEGIN ... ) expression */
static void do_begin(form,cont)
  LVAL form; int cont;
{
    if (consp(form))
	for (; consp(form); form = cdr(form))
	    if (consp(cdr(form)))
		do_expr(car(form),C_NEXT);
	    else
		do_expr(car(form),cont);
    else {
	putcbyte(OP_NIL);
	do_continuation(cont);
    }
}

/* do_while - compile the (WHILE ... ) expression */
static void do_while(form,cont)
  LVAL form; int cont;
{
    int loop,nxt;

    /* make sure there is a test expression */
    if (atom(form))
	xlerror("expecting test expression",form);

    /* skip around the 'body' to the test expression */
    putcbyte(OP_BR);
    nxt = putcword(0);

    /* compile the loop body */
    loop = cptr - cbase;
    do_begin(cdr(form),C_NEXT);

    /* label for the first iteration */
    fixup(nxt);

    /* compile the test expression */
    nxt = cptr - cbase;
    do_expr(car(form),C_NEXT);

    /* skip around the 'body' if the expression is false */
    putcbyte(OP_BRT);
    putcword(loop);

    /* compile the continuation */
    do_continuation(cont);
}

/* do_access - compile the (ACCESS var env) expression */
static void do_access(form,cont)
  LVAL form; int cont;
{
    LVAL sym;

    /* get the variable name */
    if (atom(form) || !symbolp(car(form)))
	xlerror("expecting symbol",form);
    sym = car(form);

    /* compile the environment expression */
    form = cdr(form);
    if (atom(form))
	xlerror("expecting environment expression",form);
    do_expr(car(form),C_NEXT);

    /* get the variable value */
    cd_variable(OP_AREF,sym);
    do_continuation(cont);
}

/* do_setaccess - compile the (SET! (ACCESS var env) value) expression */
static void do_setaccess(form,cont)
  LVAL form; int cont;
{
    LVAL aform,sym;

    /* make sure this is an access form */
    aform = car(form);
    if (atom(aform) || car(aform) != xlenter("ACCESS"))
	xlerror("expecting an ACCESS form",aform);

    /* get the variable name */
    aform = cdr(aform);
    if (atom(aform) || !symbolp(car(aform)))
	xlerror("expecting symbol",aform);
    sym = car(aform);

    /* compile the environment expression */
    aform = cdr(aform);
    if (atom(aform))
	xlerror("expecting environment expression",aform);
    do_expr(car(aform),C_NEXT);
    putcbyte(OP_PUSH);

    /* compile the value expression */
    form = cdr(form);
    if (atom(form))
	xlerror("expecting value expression",form);
    do_expr(car(form),C_NEXT);

    /* set the variable value */
    cd_variable(OP_ASET,sym);
    do_continuation(cont);
}

/* do_call - compile a function call */
static void do_call(form,cont)
  LVAL form; int cont;
{
    int nxt,n;
    
    /* save a continuation */
    if (cont != C_RETURN) {
	putcbyte(OP_SAVE);
	nxt = putcword(0);
    }
    
    /* compile each argument expression */
    n = push_args(cdr(form));

    /* compile the function itself */
    do_expr(car(form),C_NEXT);

    /* apply the function */
    putcbyte(OP_CALL);
    putcbyte(n);

    /* target for the continuation */
    if (cont != C_RETURN)
	fixup(nxt);
}

/* push_args - compile the arguments for a function call */
static int push_args(form)
  LVAL form;
{
    int n;
    if (consp(form)) {
	n = push_args(cdr(form));
	do_expr(car(form),C_NEXT);
	putcbyte(OP_PUSH);
	return (n+1);
    }
    return (0);
}

/* do_nary - compile nary operator expressions */
static void do_nary(op,n,form,cont)
  int op,n; LVAL form; int cont;
{
    if (n < 0 && (n = (-n)) != length(cdr(form)))
	do_call(form,cont);
    else {
	push_nargs(cdr(form),n);
	putcbyte(op);
	do_continuation(cont);
    }
}

/* push_nargs - compile the arguments for an inline function call */
static int push_nargs(form,n)
  LVAL form; int n;
{
    if (consp(form)) {
	if (n == 0)
	    xlerror("too many arguments",form);
	if (push_nargs(cdr(form),n-1))
	    putcbyte(OP_PUSH);
	do_expr(car(form),C_NEXT);
	return (TRUE);
    }
    if (n)
	xlerror("too few arguments",form);
    return (FALSE);
}

/* do_literal - compile a literal */
static void do_literal(lit,cont)
  LVAL lit; int cont;
{
    cd_literal(lit);
    do_continuation(cont);
}

/* do_identifier - compile an identifier */
static void do_identifier(sym,cont)
  LVAL sym; int cont;
{
    int lev,off;
    if (sym == true)
	putcbyte(OP_T);
    else if (findvariable(sym,&lev,&off))
	cd_evariable(OP_EREF,lev,off);
    else
	cd_variable(OP_GREF,sym);
    do_continuation(cont);
}

/* do_continuation - compile a continuation */
static void do_continuation(cont)
  int cont;
{
    switch (cont) {
    case C_RETURN:
	putcbyte(OP_RETURN);
	break;
    case C_NEXT:
	break;
    }
}

/* add_level - add a nesting level */
static int add_level()
{
    int oldcbase;
    
    /* establish a new environment frame */
    rplaca(info,newframe(car(info),1));
    rplacd(info,cons(NIL,cdr(info)));

    /* setup the base of the code for this function */
    oldcbase = cbase;
    cbase = cptr;

    /* return the old code base */
    return (oldcbase);
}

/* remove_level - remove a nesting level */
static void remove_level(oldcbase)
  int oldcbase;
{
    /* restore the previous environment */
    rplaca(info,cdr(car(info)));
    rplacd(info,cdr(cdr(info)));

    /* restore the base and code pointer */
    cptr = cbase;
    cbase = oldcbase;
}

/* findvariable - find an environment variable */
static int findvariable(sym,plev,poff)
  LVAL sym; int *plev,*poff;
{
    int lev,off;
    LVAL e,a;
    for (e = car(info), lev = 0; envp(e); e = cdr(e), ++lev)
	for (a = getelement(car(e),0), off = 1; consp(a); a = cdr(a), ++off)
	    if (sym == car(a)) {
		*plev = lev;
		*poff = off;
		return (TRUE);
	    }
    return (FALSE);
}

/* findcvariable - find an environment variable in the current frame */
static int findcvariable(sym,poff)
  LVAL sym; int *poff;
{
    int off;
    LVAL a;
    a = getelement(car(car(info)),0);
    for (off = 1; consp(a); a = cdr(a), ++off)
	if (sym == car(a)) {
	    *poff = off;
	    return (TRUE);
	}
    return (FALSE);
}

/* findliteral - find a literal in the literal frame */
static int findliteral(lit)
  LVAL lit;
{
    int o = FIRSTLIT;
    LVAL t,p;
    if ((t = car(cdr(info))) != NIL) {
	for (p = NIL; consp(t); p = t, t = cdr(t), ++o)
	    if (equal(lit,car(t)))
		return (o);
	rplacd(p,cons(lit,NIL));
    }
    else
	rplaca(cdr(info),cons(lit,NIL));
    return (o);
}

/* cd_variable - compile a variable reference */
static void cd_variable(op,sym)
  int op; LVAL sym;
{
    putcbyte(op);
    putcbyte(findliteral(sym));
}

/* cd_evariable - compile an environment variable reference */
static void cd_evariable(op,lev,off)
  int op,lev,off;      
{
    putcbyte(op);
    putcbyte(lev);
    putcbyte(off);
}

/* cd_literal - compile a literal reference */
static void cd_literal(lit)
  LVAL lit;
{
    if (lit == NIL)
	putcbyte(OP_NIL);
    else if (lit == true)
	putcbyte(OP_T);
    else {
	putcbyte(OP_LIT);
	putcbyte(findliteral(lit));
    }
}

/* putcbyte - put a code byte into data space */
static int putcbyte(b)
  int b;
{
    int adr;
    if (cptr >= CMAX)
	xlabort("insufficient code space");
    adr = (cptr - cbase);
    cbuff[cptr++] = b;
    return (adr);
}

/* putcword - put a code word into data space */
static int putcword(w)
  int w;
{
    int adr;
    adr = putcbyte(w >> 8);
    putcbyte(w);
    return (adr);
}

/* fixup - fixup a reference chain */
static void fixup(chn)
  int chn;
{
    int val,hval,nxt;

    /* store the value into each location in the chain */
    val = cptr - cbase; hval = val >> 8;
    while (chn) {
	nxt = (cbuff[cbase+chn] << 8) | (cbuff[cbase+chn+1]);
	cbuff[cbase+chn] = hval;
	cbuff[cbase+chn+1] = val;
	chn = nxt;
    }
}

/* length - find the length of a list */
int length(list)
  LVAL list;
{
    int len;
    for (len = 0; consp(list); list = cdr(list))
	++len;
    return (len);
}

/* instruction output formats */
#define FMT_NONE	0
#define FMT_BYTE	1
#define FMT_LOFF	2
#define FMT_WORD	3
#define FMT_EOFF	4

typedef struct { int ot_code; char *ot_name; int ot_fmt; } OTDEF;
OTDEF otab[] = {
{	OP_BRT,		"BRT",		FMT_WORD	},
{	OP_BRF,		"BRF",		FMT_WORD	},
{	OP_BR,		"BR",		FMT_WORD	},
{	OP_LIT,		"LIT",		FMT_LOFF	},
{	OP_GREF,	"GREF",		FMT_LOFF	},
{	OP_GSET,	"GSET",		FMT_LOFF	},
{	OP_EREF,	"EREF",		FMT_EOFF	},
{	OP_ESET,	"ESET",		FMT_EOFF	},
{	OP_SAVE,	"SAVE",		FMT_WORD	},
{	OP_CALL,	"CALL",		FMT_BYTE	},
{	OP_RETURN,	"RETURN",	FMT_NONE	},
{	OP_T,		"T",		FMT_NONE	},
{	OP_NIL,		"NIL",		FMT_NONE	},
{	OP_PUSH,	"PUSH",		FMT_NONE	},
{	OP_CLOSE,	"CLOSE",	FMT_NONE	},
{	OP_DELAY,	"DELAY",	FMT_NONE	},

{	OP_FRAME,	"FRAME",	FMT_BYTE	},
{	OP_MVARG,	"MVARG",	FMT_BYTE	},
{	OP_MVOARG,	"MVOARG",	FMT_BYTE	},
{	OP_MVRARG,	"MVRARG",	FMT_BYTE	},
{	OP_ADROP,	"ADROP",	FMT_NONE	},
{	OP_ALAST,	"ALAST",	FMT_NONE	},

{	OP_AREF,	"AREF",		FMT_LOFF	},
{	OP_ASET,	"ASET",		FMT_LOFF	},

{0,0,0}
};

/* decode_procedure - decode the instructions in a code object */
void decode_procedure(fptr,fun)
  LVAL fptr,fun;
{
    int len,lc;
    LVAL code,env;
    code = getcode(fun);
    env = getenv(fun);
    len = getslength(getbcode(code));
    for (lc = 0; lc < len; )
	lc += decode_instruction(fptr,code,lc,env);
}

/* decode_instruction - decode a single bytecode instruction */
int decode_instruction(fptr,code,lc,env)
  LVAL fptr,code; int lc; LVAL env;
{
    unsigned char *cp;
    char buf[100];
    OTDEF *op;
    NTDEF *np;
    int i,n=1;
    LVAL tmp;

    /* get a pointer to the bytecodes for this instruction */
    cp = (unsigned char *)getstring(getbcode(code)) + lc;

    /* show the address and opcode */
    if ((tmp = getcname(code)) != NIL)
	sprintf(buf,"%s:%04x %02x ",getstring(getpname(tmp)),lc,*cp);
    else {
	sprintf(buf,AFMT,code); xlputstr(fptr,buf);
    	sprintf(buf,":%04x %02x ",lc,*cp);
    }
    xlputstr(fptr,buf);

    /* display the operands */
    for (op = otab; op->ot_name; ++op)
	if (*cp == op->ot_code) {
	    switch (op->ot_fmt) {
	    case FMT_NONE:
		sprintf(buf,"      %s\n",op->ot_name);
		xlputstr(fptr,buf);
		break;
	    case FMT_BYTE:
		sprintf(buf,"%02x    %s %02x\n",cp[1],op->ot_name,cp[1]);
		xlputstr(fptr,buf);
		n += 1;
		break;
	    case FMT_LOFF:
		sprintf(buf,"%02x    %s %02x ; ",cp[1],op->ot_name,cp[1]);
		xlputstr(fptr,buf);
		xlprin1(getelement(code,cp[1]),fptr);
		xlterpri(fptr);
		n += 1;
		break;
	    case FMT_WORD:
		sprintf(buf,"%02x %02x %s %02x%02x\n",cp[1],cp[2],
			op->ot_name,cp[1],cp[2]);
		xlputstr(fptr,buf);
		n += 2;
		break;
	    case FMT_EOFF:
		if ((i = cp[1]) == 0)
		    tmp = getvnames(code);
		else {
		    for (tmp = env; i > 1; --i) tmp = cdr(tmp);
		    tmp = getelement(car(tmp),0);
		}
		for (i = cp[2]; i > 1; --i) tmp = cdr(tmp);
		sprintf(buf,"%02x %02x %s %02x %02x ; ",cp[1],cp[2],
			op->ot_name,cp[1],cp[2]);
		xlputstr(fptr,buf);
		xlprin1(car(tmp),fptr);
		xlterpri(fptr);
		n += 2;
		break;
	    }
	    return (n);
	}
    
    /* check for an integrable function */
    for (np = ntab; np->nt_name; ++np)
	if (*cp == np->nt_code) {
	    sprintf(buf,"      %s\n",np->nt_name);
	    xlputstr(fptr,buf);
	    return (n);
	}

    /* unknown opcode */
    sprintf(buf,"      <UNKNOWN>\n");
    xlputstr(fptr,buf);
    return (n);
}

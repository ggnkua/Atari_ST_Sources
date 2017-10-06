/* bobcom.c - the bytecode compiler */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

/*
	1.3ST	12/25/91	Ported to Atari ST and Mark Williams C
						Ansi void * declarations removed
*/

#include <setjmp.h>
#include "bob.h"

/* partial value structure */
typedef struct 
{
	int (*fcn)();
	int val;
} PVAL;

/* variable access function codes */
#define LOAD	1
#define STORE	2
#define PUSH	3
#define DUP		4

/* global variables */
int decode = 0; 		/* flag for decoding functions */

/* local variables */
static ARGUMENT *arguments;		/* argument list */
static ARGUMENT *temporaries;	/* temporary variable list */
static LITERAL  *literals;		/* literal list */
static VALUE	 methodclass;	/* class of the current method */
static unsigned  char *cbuff;	/* code buffer */
static int cptr;				/* code pointer */

/* break/continue stacks */
#define SSIZE	10
static int bstack[SSIZE],*bsp;
static int cstack[SSIZE],*csp;

/* external variables */
extern jmp_buf error_trap;	/* trap for compile errors */
extern VALUE  symbols;		/* symbol table */
extern VALUE  classes;		/* class table */
extern VALUE *sp;			/* stack pointer */
extern int 	  t_value;		/* token value */
extern char   t_token[];	/* token string */

/* forward declarations */
CLASS *get_class();
VECTOR *do_code();
char *copystring();
char *getmemory();

/* init_compiler - initialize the compiler */
int init_compiler(cmax)
int cmax;
{
    char *calloc();
    
    literals = NULL;
    set_nil(&methodclass);
    return ((cbuff = (unsigned char *)calloc(1,cmax)) != NULL);
}

/* mark_compiler - mark compiler variables */
mark_compiler()
{
    LITERAL *lit;
    
    for (lit = literals; lit != NULL; lit = lit->lit_next)
		mark(&lit->lit_value);
    mark(&methodclass);
}

/* compile_definitions - compile class or function definitions */
int compile_definitions(getcf,getcd)
int (*getcf)(); 
char *getcd;
{
    char name[TKNSIZE+1];
    int tkn,i;

    if (setjmp(error_trap))			 /* trap errors */
		return (FALSE);

    init_scanner(getcf,getcd);		 /* initialize */
    bsp = &bstack[-1];
    csp = &cstack[-1];

    while ((tkn = token()) != T_EOF) /* process statements until end of file */
    {
		switch (tkn) 
		{
		case T_IDENTIFIER:
			strcpy(name,t_token);
			do_function(name);
			break;
		case T_CLASS:
			do_class();
			break;
		default:
			parse_error("Expecting a declaration");
			break;
		}
    }
    return (TRUE);
}

/* do_class - handle class declarations */
static int do_class()
{
    ARGUMENT *mvars,*smvars,*fargs,**table,*p;
    char cname[TKNSIZE+1],id[TKNSIZE+1];
    DICT_ENTRY *entry;
    int type,tkn,i;

    mvars = smvars = fargs = NULL;			 /* initialize */
    check(1);
    
    /* get the class name */
    frequire(T_IDENTIFIER);
    strcpy(cname,t_token);
    
    if ((tkn = token()) == ':') 			 /* get the optional base class */
    {
		frequire(T_IDENTIFIER);
		push_class(get_class(t_token));
		info("Class '%s', Base class '%s'", 
				cname, getcstring(id, sizeof(id), clgetname(sp)));
    }
    else 
    {
		push_nil();
		stoken(tkn);
		info("Class '%s'",cname);
    }
    frequire('{');

    set_class(sp,newclass(cname,sp));		 /* create the new class object */
    addentry(&classes,cname,ST_CLASS)->de_value = *sp;

    while ((tkn = token()) != '}') 			 /* handle each variable declaration */
    {
		if ((type = tkn) == T_STATIC)			 /* check for static members */
			tkn = token();

		if (tkn != T_IDENTIFIER)				 /* get the first identifier */
			parse_error("Expecting a member declaration");
		strcpy(id,t_token);

		if ((tkn = token()) == '(') 			 /* check for a member function declaration */
		{
			get_id_list(&fargs,")");
			frequire(')');
			addentry(clgetfunctions(sp),id,
				 type == T_STATIC ? ST_SFUNCTION : ST_FUNCTION);
			freelist(&fargs);
		}
		else 									 /* handle data members */
		{
			table = (type == T_STATIC ? &smvars : &mvars);
			addargument(table,id);
			if (tkn == ',')
				get_id_list(table,";");
			else
				stoken(tkn);
		}	    
		frequire(';');
	}

    i = (isnil(clgetbase(sp)) ? 0 : clgetsize(clgetbase(sp))); /* store the member variable names */
    for (p = mvars; p != NULL; p = p->arg_next) 
    {
		entry = addentry(clgetmembers(sp),p->arg_name,ST_DATA);
		set_integer(&entry->de_value,i++);
    }
    sp->v.v_class->cl_size = i;
    freelist(&mvars);

    for (p = smvars; p != NULL; p = p->arg_next)		 /* store the static member variable names */
		addentry(clgetmembers(sp),p->arg_name,ST_SDATA);
    freelist(&smvars);
    ++sp;
}

/* findmember - find a class member */
static DICT_ENTRY *findmember(class,name)
CLASS *class; char *name;
{
    DICT_ENTRY *entry;
    
    if ((entry = findentry(&class->cl_members,name)) != NULL)
		return (entry);
    return (findentry(&class->cl_functions,name));
}

/* rfindmember - recursive findmember */
static DICT_ENTRY *rfindmember(class,name)
CLASS *class; char *name;
{
    DICT_ENTRY *entry;
    
    if ((entry = findmember(class,name)) != NULL)
		return (entry);
    else
		if (!isnil(&class->cl_base))
			return (rfindmember(claddr(&class->cl_base),name));
    return (NULL);
}

/* do_function - handle function declarations */
static do_function(name)
char *name;
{
    switch (token()) 
    {
    case '(':
		do_regular_function(name);
		break;
    case T_CC:
		check(1);
		push_class(get_class(name));
		do_member_function(sp);
		++sp;
		break;
    default:
		parse_error("Expecting a function declaration");
		break;
    }
}

/* do_regular_function - parse a regular function definition */
static do_regular_function(name)
char *name;
{
	info("Function '%s'",name);			 /* enter the function name */
    check(1);
    push_var(addentry(&symbols,name,ST_SFUNCTION));

    set_bytecode(&sp->v.v_var->de_value,do_code(name,&nil)); /* compile the body of the function */
    ++sp;

    freelist(&arguments); freelist(&temporaries);	 /* free the argument and temporary symbol lists */
}

/* do_member_function - parse a member function definition */
static do_member_function(class)
VALUE *class;
{
    char name[TKNSIZE+1],selector[TKNSIZE+1];
    DICT_ENTRY *entry;
    int tkn;
    
    frequire(T_IDENTIFIER);					 /* get the selector */
    strcpy(selector,t_token);
    frequire('(');
	getcstring(name,sizeof(name),clgetname(class));
	info("Member function '%s::%s'",name,selector);

    if ((entry = findmember(claddr(class),selector)) != NULL /* make sure the type matches the declaration */
		&&  entry->de_type != ST_FUNCTION
		&&  entry->de_type != ST_SFUNCTION)
			parse_error("Illegal redefinition");

    check(1);								 /* compile the code */
    push_var(addentry(clgetfunctions(class),selector,ST_FUNCTION));
    set_bytecode(&sp->v.v_var->de_value,do_code(selector,class));
    ++sp;

    freelist(&arguments); freelist(&temporaries);	 /* free the argument and temporary symbol lists */
}

/* do_code - compile the code part of a function or method */
static VECTOR *do_code(name,class)
char *name; VALUE *class;
{
    unsigned char *src,*dst;
    int tcnt=0,nlits,tkn,i;
    LITERAL *lit;

    arguments = temporaries = NULL;		 /* initialize */
    cptr = 0;

	if (!isnil(class))					 /* add the implicit 'this' argument for member functions */
		addargument(&arguments,"this");
    methodclass = *class;
    
    get_id_list(&arguments,";)");		 /* get the argument list */

    if ((tkn = token()) == ';')  		 /* get temporary variables */
    {
		tcnt = get_id_list(&temporaries,")");
		tkn = token();
    }
    require(tkn,')');
    
    if (tcnt > 0) 						/* reserve space for the temporaries */
    {
		putcbyte(OP_TSPACE);
		putcbyte(tcnt);
    }

    /* store the bytecodes, class and function name as the first literals */
    
    addliteral(&literals,&lit);			/* will become the bytecode string */
    addliteral(&literals,&lit);			/* class */
    lit->lit_value = *class;
    make_lit_string(name);				/* function name */

    putcbyte(OP_PUSH);					/* compile the code */
    frequire('{');
    do_block();
    putcbyte(OP_RETURN);

    /* count the number of literals */
    
    for (nlits = 0, lit = literals; lit != NULL; lit = lit->lit_next)
		++nlits;

    check(1); 							/* build the function */
    push_bytecode(newvector(nlits));
    
    /* create the code string */
    
    set_string(&literals->lit_value,newstring(cptr));
    src = cbuff;
    dst = strgetdata(&literals->lit_value);
    while (--cptr >= 0)
		*dst++ = *src++;
    
    /* copy the literals */
    
    for (i = 0, lit = literals; i < nlits; ++i, lit = lit->lit_next)
		vecsetelement(sp,i,lit->lit_value);
    freeliterals(&literals);

    if (decode) 				/* show the generated code */
		decode_procedure(sp);

    return (vecaddr(sp++)); 	/* return the code object */
}

/* get_class - get the class associated with a symbol */
static CLASS *get_class(name)
char *name;
{
    DICT_ENTRY *sym;
    
    sym = findentry(&classes,name);
    if (sym == NULL || sym->de_value.v_type != DT_CLASS)
		parse_error("Expecting a class name");
    return (claddr(&sym->de_value));
}

/* do_statement - compile a single statement */
static do_statement()
{
    int tkn;
    switch (tkn = token()) 
    {
    case T_IF:			do_if();		break;
    case T_WHILE:		do_while();		break;
    case T_DO:			do_dowhile();	break;
    case T_FOR:			do_for();		break;
    case T_BREAK:		do_break();		break;
    case T_CONTINUE:	do_continue();	break;
    case T_RETURN:		do_return();	break;
    case '{':			do_block();		break;
    case ';':			;				break;
    default:			stoken(tkn);
						do_expr();
						frequire(';');  break;
    }
}

/* do_if - compile the IF/ELSE expression */
static do_if()
{
    int tkn,nxt,end;

    do_test();					 	/* compile the test expression */

    putcbyte(OP_BRF);			 	/* skip around the 'then' clause if the expression is false */
    nxt = putcword(0);

    do_statement();					/* compile the 'then' clause */
    
    if ((tkn = token()) == T_ELSE)  /* compile the 'else' clause */
    {
		putcbyte(OP_BR);
		end = putcword(0);
		fixup(nxt,cptr);
		do_statement();
		nxt = end;
    }
    else
		stoken(tkn);

    fixup(nxt,cptr);				 /* handle the end of the statement */
}

/* addbreak - add a break level to the stack */
static int *addbreak(lbl)
int lbl;
{
    int *old=bsp;
    
    if (++bsp < &bstack[SSIZE])
		*bsp = lbl;
    else
		parse_error("Too many nested loops");
    return (old);
}

/* rembreak - remove a break level from the stack */
static int rembreak(old,lbl)
int *old,lbl;
{
   return (bsp > old ? *bsp-- : lbl);
}

/* addcontinue - add a continue level to the stack */
static int *addcontinue(lbl)
int lbl;
{
    int *old=csp;
    
    if (++csp < &cstack[SSIZE])
		*csp = lbl;
    else
		parse_error("Too many nested loops");
    return (old);
}

/* remcontinue - remove a continue level from the stack */
static remcontinue(old)
int *old;
{
    csp = old;
}

/* do_while - compile the WHILE expression */
static do_while()
{
    int nxt,end,*ob,*oc;

    nxt = cptr;				 /* compile the test expression */
    do_test();

    putcbyte(OP_BRF);		 /* skip around the loop body if the expression is false */
    end = putcword(0);

    ob = addbreak(end);		 /* compile the loop body */
    oc = addcontinue(nxt);
    do_statement();
    end = rembreak(ob,end);
    remcontinue(oc);

    putcbyte(OP_BR);		 /* branch back to the start of the loop */
    putcword(nxt);

    fixup(end,cptr);		 /* handle the end of the statement */
}

/* do_dowhile - compile the DO/WHILE expression */
static do_dowhile()
{
    int nxt,end=0,*ob,*oc;

    nxt = cptr; 			/* remember the start of the loop */

    ob = addbreak(0); 		/* compile the loop body */
    oc = addcontinue(nxt);
    do_statement();
    end = rembreak(ob,end);
    remcontinue(oc);

    frequire(T_WHILE); 		/* compile the test expression */
    do_test();
    frequire(';');

    putcbyte(OP_BRT);	 	/* branch to the top if the expression is true */
    putcword(nxt);

    fixup(end,cptr); 		/* handle the end of the statement */
}

/* do_for - compile the FOR statement */
static do_for()
{
    int tkn,nxt,end,body,update,*ob,*oc;

    frequire('('); 			/* compile the initialization expression */
    if ((tkn = token()) != ';') 
    {
		stoken(tkn);
		do_expr();
		frequire(';');
    }

    nxt = cptr; 			/* compile the test expression */
    if ((tkn = token()) != ';') 
    {
		stoken(tkn);
		do_expr();
		frequire(';');
    }

    putcbyte(OP_BRT); 		/* branch to the loop body if the expression is true */
    body = putcword(0);

    putcbyte(OP_BR); 		/* branch to the end if the expression is false */
    end = putcword(0);

    update = cptr; 			/* compile the update expression */
    if ((tkn = token()) != ')') 
    {
		stoken(tkn);
		do_expr();
		frequire(')');
    }

    putcbyte(OP_BR); 		/* branch back to the test code */
    putcword(nxt);

    fixup(body,cptr); 		/* compile the loop body */
    ob = addbreak(end);
    oc = addcontinue(update);
    do_statement();
    end = rembreak(ob,end);
    remcontinue(oc);

    putcbyte(OP_BR); 		/* branch back to the update code */
    putcword(update);

    fixup(end,cptr); 		/* handle the end of the statement */
}

/* do_break - compile the BREAK statement */
static do_break()
{
    if (bsp >= bstack) 
    {
		putcbyte(OP_BR);
		*bsp = putcword(*bsp);
    }
    else
		parse_error("Break outside of loop");
}

/* do_continue - compile the CONTINUE statement */
static do_continue()
{
    if (csp >= cstack) 
    {
		putcbyte(OP_BR);
		putcword(*csp);
    }
    else
		parse_error("Continue outside of loop");
}

/* do_block - compile the {} expression */
static do_block()
{
    int tkn;
    
    if ((tkn = token()) != '}') 
    {
		do 
		{
			stoken(tkn);
			do_statement();
		} while ((tkn = token()) != '}');
    }
    else
		putcbyte(OP_NIL);
}

/* do_return - handle the RETURN expression */
static do_return()
{
    do_expr();
    frequire(';');
    putcbyte(OP_RETURN);
}

/* do_test - compile a test expression */
static do_test()
{
    frequire('(');
    do_expr();
    frequire(')');
}

/* do_expr - parse an expression */
static do_expr()
{
    PVAL pv;
    
    do_expr1(&pv);
    rvalue(&pv);
}

/* rvalue - get the rvalue of a partial expression */
static rvalue(pv)
PVAL *pv;
{
    if (pv->fcn) 
    {
		(*pv->fcn)(LOAD,pv->val);
		pv->fcn = NULL;
    }
}

/* chklvalue - make sure we've got an lvalue */
static chklvalue(pv)
PVAL *pv;
{
    if (pv->fcn == NULL)
		parse_error("Expecting an lvalue");
}

/* do_expr1 - handle the ',' operator */
static do_expr1(pv)
PVAL *pv;
{
    int tkn;
    
    do_expr2(pv);
    while ((tkn = token()) == ',') 
    {
		rvalue(pv);
		do_expr1(pv); rvalue(pv);
    }
    stoken(tkn);
}

/* do_expr2 - handle the assignment operators */
static do_expr2(pv)
PVAL *pv;
{
    int tkn,nxt,end;
    PVAL rhs;
    
    do_expr3(pv);
    while ((tkn = token()) == '='
				||     tkn == T_ADDEQ || tkn == T_SUBEQ
				||     tkn == T_MULEQ || tkn == T_DIVEQ || tkn == T_REMEQ
				||     tkn == T_ANDEQ || tkn == T_OREQ  || tkn == T_XOREQ
				||     tkn == T_SHLEQ || tkn == T_SHLEQ) 
	{
		chklvalue(pv);
		switch (tkn) 
		{
		case '=':
							(*pv->fcn)(PUSH);
							do_expr1(&rhs); rvalue(&rhs);
							(*pv->fcn)(STORE,pv->val);
							break;
		case T_ADDEQ:	    do_assignment(pv,OP_ADD);	    break;
		case T_SUBEQ:	    do_assignment(pv,OP_SUB);	    break;
		case T_MULEQ:	    do_assignment(pv,OP_MUL);	    break;
		case T_DIVEQ:	    do_assignment(pv,OP_DIV);	    break;
		case T_REMEQ:	    do_assignment(pv,OP_REM);	    break;
		case T_ANDEQ:	    do_assignment(pv,OP_BAND);	    break;
		case T_OREQ:	    do_assignment(pv,OP_BOR);	    break;
		case T_XOREQ:	    do_assignment(pv,OP_XOR);	    break;
		case T_SHLEQ:	    do_assignment(pv,OP_SHL);	    break;
		case T_SHREQ:	    do_assignment(pv,OP_SHR);	    break;
		}
		pv->fcn = NULL;
    }
    stoken(tkn);
}

/* do_assignment - handle assignment operations */
static do_assignment(pv,op)
PVAL *pv; int op;
{
    PVAL rhs;
    
    (*pv->fcn)(DUP);
    (*pv->fcn)(LOAD,pv->val);
    putcbyte(OP_PUSH);
    do_expr1(&rhs); rvalue(&rhs);
    putcbyte(op);
    (*pv->fcn)(STORE,pv->val);
}

/* do_expr3 - handle the '?:' operator */
static do_expr3(pv)
PVAL *pv;
{
    int tkn,nxt,end;
    
    do_expr4(pv);
    while ((tkn = token()) == '?') 
    {
		rvalue(pv);
		putcbyte(OP_BRF);
		nxt = putcword(0);
		do_expr1(pv); rvalue(pv);
		frequire(':');
		putcbyte(OP_BR);
		end = putcword(0);
		fixup(nxt,cptr);
		do_expr1(pv); rvalue(pv);
		fixup(end,cptr);
    }
    stoken(tkn);
}

/* do_expr4 - handle the '||' operator */
static do_expr4(pv)
PVAL *pv;
{
    int tkn,end=0;
    
    do_expr5(pv);
    while ((tkn = token()) == T_OR) 
    {
		rvalue(pv);
		putcbyte(OP_BRT);
		end = putcword(end);
		do_expr5(pv); rvalue(pv);
    }
    fixup(end,cptr);
    stoken(tkn);
}

/* do_expr5 - handle the '&&' operator */
static do_expr5(pv)
PVAL *pv;
{
    int tkn,end=0;
    
    do_expr6(pv);
    while ((tkn = token()) == T_AND) 
    {
		rvalue(pv);
		putcbyte(OP_BRF);
		end = putcword(end);
		do_expr6(pv); rvalue(pv);
    }
    fixup(end,cptr);
    stoken(tkn);
}

/* do_expr6 - handle the '|' operator */
static do_expr6(pv)
PVAL *pv;
{
    int tkn;
    
    do_expr7(pv);
    while ((tkn = token()) == '|') 
    {
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr7(pv); rvalue(pv);
		putcbyte(OP_BOR);
    }
    stoken(tkn);
}

/* do_expr7 - handle the '^' operator */
static do_expr7(pv)
PVAL *pv;
{
    int tkn;
    
    do_expr8(pv);
    while ((tkn = token()) == '^') 
    {
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr8(pv); rvalue(pv);
		putcbyte(OP_XOR);
    }
    stoken(tkn);
}

/* do_expr8 - handle the '&' operator */
static do_expr8(pv)
PVAL *pv;
{
    int tkn;
    
    do_expr9(pv);
    while ((tkn = token()) == '&') 
    {
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr9(pv); rvalue(pv);
		putcbyte(OP_BAND);
    }
    stoken(tkn);
}

/* do_expr9 - handle the '==' and '!=' operators */
static do_expr9(pv)
PVAL *pv;
{
    int tkn,op;
    
    do_expr10(pv);
    while ((tkn = token()) == T_EQ || tkn == T_NE) 
    {
		switch (tkn) 
		{
		case T_EQ: op = OP_EQ; break;
		case T_NE: op = OP_NE; break;
		}
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr10(pv); rvalue(pv);
		putcbyte(op);
    }
    stoken(tkn);
}

/* do_expr10 - handle the '<', '<=', '>=' and '>' operators */
static do_expr10(pv)
PVAL *pv;
{
    int tkn,op;
    
    do_expr11(pv);
    while ((tkn = token()) == '<' || tkn == T_LE || tkn == T_GE || tkn == '>') 
    {
		switch (tkn) 
		{
		case '<':  op = OP_LT; break;
		case T_LE: op = OP_LE; break;
		case T_GE: op = OP_GE; break;
		case '>':  op = OP_GT; break;
		}
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr11(pv); rvalue(pv);
		putcbyte(op);
    }
    stoken(tkn);
}

/* do_expr11 - handle the '<<' and '>>' operators */
static do_expr11(pv)
PVAL *pv;
{
    int tkn,op;
    
    do_expr12(pv);
    while ((tkn = token()) == T_SHL || tkn == T_SHR) 
    {
		switch (tkn) 
		{
		case T_SHL: op = OP_SHL; break;
		case T_SHR: op = OP_SHR; break;
		}
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr12(pv); rvalue(pv);
		putcbyte(op);
    }
    stoken(tkn);
}

/* do_expr12 - handle the '+' and '-' operators */
static do_expr12(pv)
PVAL *pv;
{
    int tkn,op;
    
    do_expr13(pv);
    while ((tkn = token()) == '+' || tkn == '-') 
    {
		switch (tkn) 
		{
		case '+': op = OP_ADD; break;
		case '-': op = OP_SUB; break;
		}
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr13(pv); rvalue(pv);
		putcbyte(op);
    }
    stoken(tkn);
}

/* do_expr13 - handle the '*' and '/' operators */
static do_expr13(pv)
PVAL *pv;
{
    int tkn,op;
    
    do_expr14(pv);
    while ((tkn = token()) == '*' || tkn == '/' || tkn == '%') 
    {
		switch (tkn) 
		{
		case '*': op = OP_MUL; break;
		case '/': op = OP_DIV; break;
		case '%': op = OP_REM; break;
		}
		rvalue(pv);
		putcbyte(OP_PUSH);
		do_expr14(pv); rvalue(pv);
		putcbyte(op);
    }
    stoken(tkn);
}

/* do_expr14 - handle unary operators */
static do_expr14(pv)
PVAL *pv;
{
    int tkn;
    
    switch (tkn = token()) 
    {
    case '-':
		do_expr15(pv); rvalue(pv);
		putcbyte(OP_NEG);
		break;
    case '!':
		do_expr15(pv); rvalue(pv);
		putcbyte(OP_NOT);
		break;
    case '~':
		do_expr15(pv); rvalue(pv);
		putcbyte(OP_BNOT);
		break;
    case T_INC:
		do_preincrement(pv,OP_INC);
		break;
    case T_DEC:
		do_preincrement(pv,OP_DEC);
		break;
    case T_NEW:
		do_new(pv);
		break;
    default:
		stoken(tkn);
		do_expr15(pv);
		return;
    }
}

/* do_preincrement - handle prefix '++' and '--' */
static do_preincrement(pv,op)
PVAL *pv;
{
    do_expr15(pv);
    chklvalue(pv);
    (*pv->fcn)(DUP);
    (*pv->fcn)(LOAD,pv->val);
    putcbyte(op);
    (*pv->fcn)(STORE,pv->val);
    pv->fcn = NULL;
}

/* do_postincrement - handle postfix '++' and '--' */
static do_postincrement(pv,op)
PVAL *pv;
{
    chklvalue(pv);
    (*pv->fcn)(DUP);
    (*pv->fcn)(LOAD,pv->val);
    putcbyte(op);
    (*pv->fcn)(STORE,pv->val);
    putcbyte(op == OP_INC ? OP_DEC : OP_INC);
    pv->fcn = NULL;
}

/* do_new - handle the 'new' operator */
static do_new(pv)
PVAL *pv;
{
    char selector[TKNSIZE+1];
    LITERAL *lit;
    CLASS *class;

    frequire(T_IDENTIFIER);
    strcpy(selector,t_token);

    class = get_class(selector);

    code_literal(addliteral(&literals,&lit));
    set_class(&lit->lit_value,class);

    putcbyte(OP_NEW);
    pv->fcn = NULL;
    
    do_send(selector,pv);
}

/* do_expr15 - handle function calls */
static do_expr15(pv)
PVAL *pv;
{
    char selector[TKNSIZE+1];
    int tkn;
    do_primary(pv);
    
    while ((tkn = token()) == '(' || tkn == '[' || tkn == T_MEMREF
						|| tkn == T_INC || tkn == T_DEC)
	{					
		switch (tkn) 
		{
		case '(':
			do_call(pv);
			break;
		case '[':
			do_index(pv);
			break;
		case T_MEMREF:
			frequire(T_IDENTIFIER);
			strcpy(selector,t_token);
			do_send(selector,pv);
			break;
		case T_INC:
			do_postincrement(pv,OP_INC);
			break;
		case T_DEC:
			do_postincrement(pv,OP_DEC);
			break;
		}
	}	
	stoken(tkn);
}

/* do_primary - parse a primary expression and unary operators */
static do_primary(pv)
PVAL *pv;
{
    char id[TKNSIZE+1];
    DICT_ENTRY *entry;
    CLASS *class;
    int tkn;
    
    switch (token()) 
    {
    case '(':
		do_expr1(pv);
		frequire(')');
		break;
    case T_NUMBER:
		do_lit_integer((long)t_value);
		pv->fcn = NULL;
		break;
    case T_STRING:
		do_lit_string(t_token);
		pv->fcn = NULL;
		break;
    case T_NIL:
		putcbyte(OP_NIL);
		break;
    case T_IDENTIFIER:
		strcpy(id,t_token);
		if ((tkn = token()) == T_CC) 
		{
			class = get_class(id);
			frequire(T_IDENTIFIER);
			if (!findclassvariable(class,t_token,pv))
			parse_error("Not a class member");
		}
		else 
		{
			stoken(tkn);
			findvariable(id,pv);
		}
		break;
    default:
		parse_error("Expecting a primary expression");
		break;
    }
}

/* do_call - compile a function call */
static do_call(pv)
PVAL *pv;
{
    int tkn,n=0;
    
    rvalue(pv);								/* get the value of the function */

    if ((tkn = token()) != ')')  			/* compile each argument expression */
    {
		stoken(tkn);
		do 
		{
			putcbyte(OP_PUSH);
			do_expr2(pv); rvalue(pv);
			++n;
		} while ((tkn = token()) == ',');
    }
    require(tkn,')');
    putcbyte(OP_CALL);
    putcbyte(n);

    pv->fcn = NULL; 						/* we've got an rvalue now */
}

/* do_send - compile a message sending expression */
static do_send(selector,pv)
char *selector; PVAL *pv;
{
    LITERAL *lit;
    int tkn,n=1;
    
	rvalue(pv); 						/* get the receiver value */

	putcbyte(OP_PUSH);			 		/* generate code to push the selector */
    code_literal(addliteral(&literals,&lit));
    set_string(&lit->lit_value,makestring(selector));

    frequire('('); 						/* compile the argument list */
    if ((tkn = token()) != ')') 
    {
		stoken(tkn);
		do 
		{
			putcbyte(OP_PUSH);
			do_expr2(pv); rvalue(pv);
			++n;
		} while ((tkn = token()) == ',');
    }
    require(tkn,')');

    putcbyte(OP_SEND); 					/* send the message */
    putcbyte(n);

    pv->fcn = NULL; 					/* we've got an rvalue now */
}

/* do_index - compile an indexing operation */
static do_index(pv)
PVAL *pv;
{
    int code_index();
    
    rvalue(pv);
    putcbyte(OP_PUSH);
    do_expr(pv);
    frequire(']');
    pv->fcn = code_index;
}

/* get_id_list - get a comma separated list of identifiers */
static int get_id_list(list,term)
ARGUMENT **list; char *term;
{
    char *strchr();
    int tkn,cnt=0;
    
    tkn = token();
    if (!strchr(term,tkn)) 
    {
		stoken(tkn);
		do 
		{
			frequire(T_IDENTIFIER);
			addargument(list,t_token);
			++cnt;
		} while ((tkn = token()) == ',');
    }
    stoken(tkn);
    return (cnt);
}

/* addargument - add a formal argument */
static addargument(list,name)
ARGUMENT **list; char *name;
{
    ARGUMENT *arg;
    
    arg = (ARGUMENT *)getmemory(sizeof(ARGUMENT));
    arg->arg_name = copystring(name);
    arg->arg_next = *list;
    *list = arg;
}

/* freelist - free a list of arguments or temporaries */
static freelist(plist)
ARGUMENT **plist;
{
    ARGUMENT *this,*next;
    
    for (this = *plist, *plist = NULL; this != NULL; this = next) 
    {
		next = this->arg_next;
		free(this->arg_name);
		free(this);
    }
}

/* findarg - find an argument offset */
static int findarg(name)
char *name;
{
    ARGUMENT *arg;
    int n;
    
    for (n = 0, arg = arguments; arg; n++, arg = arg->arg_next)
		if (strcmp(name,arg->arg_name) == 0)
			return (n);
    return (-1);
}

/* findtmp - find a temporary variable offset */
static int findtmp(name)
char *name;
{
    ARGUMENT *tmp;
    int n;
    
    for (n = 0, tmp = temporaries; tmp; n++, tmp = tmp->arg_next)
		if (strcmp(name,tmp->arg_name) == 0)
			return (n);
    return (-1);
}

/* finddatamember - find a class data member */
static DICT_ENTRY *finddatamember(name)
char *name;
{
    DICT_ENTRY *entry;
    VALUE *class;
    
    if (!isnil(class)) 
    {
		class = &methodclass;
		do 
		{
			if ((entry = findentry(clgetmembers(class),name)) != NULL)
			return (entry);
			class = clgetbase(class);
		} while (!isnil(class));
    }
    return (NULL);
}

/* addliteral - add a literal */
static int addliteral(list,pval)
LITERAL **list,**pval;
{
    LITERAL **plit,*lit;
    int n=0;
    
    for (plit = list; (lit = *plit) != NULL; plit = &lit->lit_next)
		++n;
    lit = (LITERAL *)getmemory(sizeof(LITERAL));
    set_nil(&lit->lit_value);
    lit->lit_next = NULL;
    *pval = *plit = lit;
    return (n);
}

/* freeliterals - free a list of literals */
static freeliterals(plist)
LITERAL **plist;
{
    LITERAL *this,*next;
    for (this = *plist, *plist = NULL; this != NULL; this = next) 
    {
		next = this->lit_next;
		free(this);
    }
}

/* frequire - fetch a token and check it */
static frequire(rtkn)
int rtkn;
{
    require(token(),rtkn);
}

/* require - check for a required token */
static require(tkn,rtkn)
int tkn,rtkn;
{
    char msg[100],tknbuf[100],*tkn_name();
    
    if (tkn != rtkn) 
    {
		strcpy(tknbuf,tkn_name(rtkn));
		sprintf(msg,"Expecting '%s', found '%s'",tknbuf,tkn_name(tkn));
		parse_error(msg);
    }
}

/* do_lit_integer - compile a literal integer */
static do_lit_integer(n)
long n;
{
    LITERAL *lit;
    
    code_literal(addliteral(&literals,&lit));
    set_integer(&lit->lit_value,n);
}

/* do_lit_string - compile a literal string */
static do_lit_string(str)
char *str;
{
    code_literal(make_lit_string(str));
}

/* make_lit_string - make a literal string */
static int make_lit_string(str)
char *str;
{
    LITERAL *lit;
    int n;
    
    n = addliteral(&literals,&lit);
    set_string(&lit->lit_value,makestring(str));
    return (n);
}

/* make_lit_variable - make a literal reference to a variable */
static int make_lit_variable(sym)
DICT_ENTRY *sym;
{
    LITERAL *lit;
    int n;
    
    n = addliteral(&literals,&lit);
    set_var(&lit->lit_value,sym);
    return (n);
}

/* findvariable - find a variable */
static findvariable(id,pv)
char *id; PVAL *pv;
{    
    int code_argument(),code_temporary(),code_variable();
    DICT_ENTRY *entry;
    int n;
    
    if ((n = findarg(id)) >= 0) 
    {
		pv->fcn = code_argument;
		pv->val = n;
    }
    else 
		if ((n = findtmp(id)) >= 0) 
		{
		pv->fcn = code_temporary;
		pv->val = n;
		}
		else 
			if (isnil(&methodclass) || !findclassvariable(claddr(&methodclass),
					id,pv)) 
			{
				pv->fcn = code_variable;
				pv->val = make_lit_variable(addentry(&symbols,id,ST_SDATA));
			}
}

/* findclassvariable - find a class member variable */
static int findclassvariable(class,name,pv)
CLASS *class; char *name; PVAL *pv;
{
    int code_member(),code_variable();
    DICT_ENTRY *entry;
    
    if ((entry = rfindmember(class,name)) == NULL)
		return (FALSE);
    switch (entry->de_type) 
    {
    case ST_DATA:
		pv->fcn = code_member;
		pv->val = entry->de_value.v.v_integer;
		break;
    case ST_SDATA:
		pv->fcn = code_variable;
       	pv->val = make_lit_variable(entry);
		break;
    case ST_FUNCTION:
		findvariable("this",pv);
		do_send(name,pv);
		break;
    case ST_SFUNCTION:
		code_variable(LOAD,make_lit_variable(entry));
		pv->fcn = NULL;
		break;
    }
    return (TRUE);
}

/* code_argument - compile an argument reference */
static code_argument(fcn,n)
int fcn,n;
{
    switch (fcn) 
    {
    case LOAD:	putcbyte(OP_AREF); putcbyte(n); break;
    case STORE:	putcbyte(OP_ASET); putcbyte(n); break;
    }
}

/* code_temporary - compile a temporary variable reference */
static code_temporary(fcn,n)
int fcn,n;
{
    switch (fcn) 
    {
    case LOAD:	putcbyte(OP_TREF); putcbyte(n); break;
    case STORE:	putcbyte(OP_TSET); putcbyte(n); break;
    }
}

/* code_member - compile a data member reference */
static code_member(fcn,n)
int fcn,n;
{
    switch (fcn) 
    {
    case LOAD:	putcbyte(OP_MREF); putcbyte(n); break;
    case STORE:	putcbyte(OP_MSET); putcbyte(n); break;
    }
}

/* code_variable - compile a variable reference */
static code_variable(fcn,n)
int fcn,n;
{
    switch (fcn) 
    {
    case LOAD:	putcbyte(OP_REF); putcbyte(n); break;
    case STORE:	putcbyte(OP_SET); putcbyte(n); break;
    }
}

/* code_index - compile an indexed reference */
static code_index(fcn)
int fcn;
{
    switch (fcn) 
    {
    case LOAD:	putcbyte(OP_VREF); break;
    case STORE:	putcbyte(OP_VSET); break;
    case PUSH:  putcbyte(OP_PUSH); break;
    case DUP:	putcbyte(OP_DUP2); break;
    }
}

/* code_literal - compile a literal reference */
static code_literal(n)
int n;
{
    putcbyte(OP_LIT);
    putcbyte(n);
}

/* putcbyte - put a code byte into data space */
static int putcbyte(b)
int b;
{
    if (cptr >= CMAX)
		parse_error("Insufficient code space");
    cbuff[cptr] = b;
    return (cptr++);
}

/* putcword - put a code word into data space */
static int putcword(w)
int w;
{
    putcbyte(w);
    putcbyte(w >> 8);
    return (cptr-2);
}

/* fixup - fixup a reference chain */
static fixup(chn,val)
int chn,val;
{
    int hval,nxt;
    
    for (hval = val >> 8; chn != 0; chn = nxt) 
    {
		nxt = (cbuff[chn] & 0xFF) | (cbuff[chn+1] << 8);
		cbuff[chn] = val;
		cbuff[chn+1] = hval;
    }
}

/* copystring - make a copy of a string */
static char *copystring(str)
char *str;
{
    char *val;
    
    val = getmemory(strlen(str)+1);
    strcpy(val,str);
    return (val);
}

/* getmemory - allocate memory and complain if there isn't enough */
static char *getmemory(size)
int size;
{
    char *calloc(),*val;
    
    if ((val = calloc(1,size)) == NULL)
		error("Insufficient memory");
    return (val);
}

/* xsint.c - xscheme bytecode interpreter */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"
#include "xsbcode.h"

/* sample rate (instructions per sample) */
#define SRATE	1000

/* macros to get the address of the code string for a code object */
#define getcodestr(x) ((unsigned char *)getstring(getbcode(x)))

/* globals */
int trace=FALSE;	/* trace enable */
int xlargc;		/* argument count */
jmp_buf bc_dispatch;	/* bytecode dispatcher */

/* external variables */
extern LVAL xlfun,xlenv,xlval;
extern LVAL s_stdin,s_stdout,s_unbound;
extern LVAL s_unassigned,default_object,true;

/* external routines */
extern LVAL xadd(),xsub(),xmul(),xdiv(),xlss(),xeql(),xgtr();

/* local variables */
static unsigned char *base,*pc;
static int sample=SRATE;

#ifdef __STDC__
static LVAL findvar(LVAL env,LVAL var,int *poff);
static LVAL make_continuation(void);
static void restore_continuation(void);
static void badfuntype(LVAL arg);
static void badargtype(LVAL arg);
#else
static LVAL findvar();
static LVAL make_continuation();
#endif

/* xtraceon - built-in function 'trace-on' */
LVAL xtraceon()
{
    xllastarg()
    trace = TRUE;
    return (NIL);
}

/* xtraceoff - built-in function 'trace-off' */
LVAL xtraceoff()
{
    xllastarg()
    trace = FALSE;
    return (NIL);
}

/* xlexecute - execute byte codes */
void xlexecute(fun)
  LVAL fun;
{
    register LVAL tmp;
    register unsigned int i;
    register int k;
    FIXTYPE fixtmp;
    int off;

    /* initialize the registers */
    xlfun = getcode(fun);
    xlenv = getenv(fun);
    xlval = NIL;

    /* initialize the argument count */
    xlargc = 0;

    /* set the initial pc */
    base = pc = getcodestr(xlfun);

    /* setup a target for the error handler */
    setjmp(bc_dispatch);
    
    /* execute the code */
    for (;;) {

	/* check for control codes */
	if (--sample <= 0) {
	    sample = SRATE;
	    oscheck();
	}

	/* print the trace information */
	if (trace)
	    decode_instruction(curoutput(),xlfun,(int)(pc-base),xlenv);

	/* execute the next bytecode instruction */
	switch (*pc++) {
	case OP_BRT:
		i = *pc++ << 8; i |= *pc++;
		if (xlval) pc = base + i;
		break;
	case OP_BRF:
		i = *pc++ << 8; i |= *pc++;
		if (!xlval) pc = base + i;
		break;
	case OP_BR:
		i = *pc++ << 8; i |= *pc++;
		pc = base + i;
		break;
	case OP_LIT:
		xlval = getelement(xlfun,*pc++);
		break;
	case OP_GREF:
		tmp = getelement(xlfun,*pc++);
		if ((xlval = getvalue(tmp)) == s_unbound) {
		    xlval = getvalue(xlenter("*UNBOUND-HANDLER*"));
		    if (xlval != NIL) {
			oscheck();
			pc -= 2; /* backup the pc */
			tmp = make_continuation();
			check(2);
			push(tmp);
			push(getelement(xlfun,pc[1]));
			xlargc = 2;
			xlapply();
		    }
		    else
			xlerror("unbound variable",tmp);
		}
		break;
	case OP_GSET:
		setvalue(getelement(xlfun,*pc++),xlval);
		break;
	case OP_EREF:
		k = *pc++;
		tmp = xlenv;
		while (--k >= 0) tmp = cdr(tmp);
		xlval = getelement(car(tmp),*pc++);
		break;
	case OP_ESET:
		k = *pc++;
		tmp = xlenv;
		while (--k >= 0) tmp = cdr(tmp);
		setelement(car(tmp),*pc++,xlval);
		break;
	case OP_AREF:
		i = *pc++;
		tmp = xlval;
		if (!envp(tmp)) badargtype(tmp);
		if ((tmp = findvar(tmp,getelement(xlfun,i),&off)) != NIL)
		    xlval = getelement(car(tmp),off);
		else
		    xlval = s_unassigned;
		break;
	case OP_ASET:
		i = *pc++;
		tmp = pop();
		if (!envp(tmp)) badargtype(tmp);
		if ((tmp = findvar(tmp,getelement(xlfun,i),&off)) == NIL)
		    xlerror("no binding for variable",getelement(xlfun,i));
		setelement(car(tmp),off,xlval);
		break;
	case OP_SAVE:	/* save a continuation */
		i = *pc++ << 8; i |= *pc++;
		check(3);
		push(cvsfixnum((FIXTYPE)i));
		push(xlfun);
		push(xlenv);
		break;
	case OP_CALL:	/* call a function (or built-in) */
		xlargc = *pc++;	/* get argument count */
		xlapply();	/* apply the function */
		break;
	case OP_RETURN:	/* return to the continuation on the stack */
		xlreturn();
		break;
	case OP_FRAME:	/* create an environment frame */
		i = *pc++;	/* get the frame size */
		xlenv = newframe(xlenv,i);
		setelement(car(xlenv),0,getvnames(xlfun));
		break;
	case OP_MVARG:	/* move required argument to frame slot */
		i = *pc++;	/* get the slot number */
		if (--xlargc < 0)
		    xlfail("too few arguments");
		setelement(car(xlenv),i,pop());
		break;
	case OP_MVOARG:	/* move optional argument to frame slot */
		i = *pc++;	/* get the slot number */
		if (xlargc > 0) {
		    setelement(car(xlenv),i,pop());
		    --xlargc;
		}
		else
		    setelement(car(xlenv),i,default_object);
		break;
	case OP_MVRARG:	/* build rest argument and move to frame slot */
		i = *pc++;	/* get the slot number */
		for (xlval = NIL, k = xlargc; --k >= 0; )
		    xlval = cons(xlsp[k],xlval);
		setelement(car(xlenv),i,xlval);
		drop(xlargc);
		break;
	case OP_ALAST:	/* make sure there are no more arguments */
		if (xlargc > 0)
		    xlfail("too many arguments");
		break;
	case OP_T:
		xlval = true;
		break;
	case OP_NIL:
		xlval = NIL;
		break;
	case OP_PUSH:
		cpush(xlval);
		break;
	case OP_CLOSE:
		if (!codep(xlval)) badargtype(xlval);
		xlval = cvclosure(xlval,xlenv);
		break;
	case OP_DELAY:
		if (!codep(xlval)) badargtype(xlval);
		xlval = cvpromise(xlval,xlenv);
		break;
	case OP_ATOM:
		xlval = (atom(xlval) ? true : NIL);
		break;
	case OP_EQ:
		xlval = (xlval == pop() ? true : NIL);
		break;
	case OP_NULL:
		xlval = (xlval ? NIL : true);
		break;
	case OP_CONS:
		xlval = cons(xlval,pop());
		break;
	case OP_CAR:
		if (!listp(xlval)) badargtype(xlval);
		xlval = (xlval ? car(xlval) : NIL);
		break;
	case OP_CDR:
		if (!listp(xlval)) badargtype(xlval);
		xlval = (xlval ? cdr(xlval) : NIL);
		break;
	case OP_SETCAR:
		if (!consp(xlval)) badargtype(xlval);
		rplaca(xlval,pop());
		break;
	case OP_SETCDR:
		if (!consp(xlval)) badargtype(xlval);
		rplacd(xlval,pop());
		break;
	case OP_ADD:
		tmp = pop();
		if (fixp(xlval) && fixp(tmp))
		    xlval = cvfixnum(getfixnum(xlval) + getfixnum(tmp));
		else {
		    push(tmp); push(xlval); xlargc = 2;
		    xlval = xadd();
		}
		break;
	case OP_SUB:
		tmp = pop();
		if (fixp(xlval) && fixp(tmp))
		    xlval = cvfixnum(getfixnum(xlval) - getfixnum(tmp));
		else {
		    push(tmp); push(xlval); xlargc = 2;
		    xlval = xsub();
		}
		break;
	case OP_MUL:
		tmp = pop();
		if (fixp(xlval) && fixp(tmp))
		    xlval = cvfixnum(getfixnum(xlval) * getfixnum(tmp));
		else {
		    push(tmp); push(xlval); xlargc = 2;
		    xlval = xmul();
		}
		break;
	case OP_QUO:
		tmp = pop();
		if (fixp(xlval) && fixp(tmp)) {
		    if ((fixtmp = getfixnum(tmp)) == (FIXTYPE)0)
			xlfail("division by zero");
		    xlval = cvfixnum(getfixnum(xlval) / fixtmp);
		}
		else if (fixp(xlval))
		    badargtype(tmp);
		else
		    badargtype(xlval);
		break;
	case OP_LSS:
		tmp = pop();
		if (fixp(xlval) && fixp(tmp))
		    xlval = (getfixnum(xlval) < getfixnum(tmp) ? true : NIL);
		else {
		    push(tmp); push(xlval); xlargc = 2;
		    xlval = xlss();
		}
		break;
	case OP_EQL:
		tmp = pop();
		if (fixp(xlval) && fixp(tmp))
		    xlval = (getfixnum(xlval) == getfixnum(tmp) ? true : NIL);
		else {
		    push(tmp); push(xlval); xlargc = 2;
		    xlval = xeql();
		}
		break;
	case OP_GTR:
		tmp = pop();
		if (fixp(xlval) && fixp(tmp))
		    xlval = (getfixnum(xlval) > getfixnum(tmp) ? true : NIL);
		else {
		    push(tmp); push(xlval); xlargc = 2;
		    xlval = xgtr();
		}
		break;
	default:
		xlerror("bad opcode",cvsfixnum((FIXTYPE)*--pc));
		break;
	}
    }
}

/* findvar - find a variable in an environment */
static LVAL findvar(env,var,poff)
  LVAL env,var; int *poff;
{
    LVAL names;
    int off;
    for (; env != NIL; env = cdr(env)) {
	names = getelement(car(env),0);
	for (off = 1; names != NIL; ++off, names = cdr(names))
	    if (var == car(names)) {
		*poff = off;
		return (env);
	    }
    }
    return (NIL);
}

/* xlapply - apply a function to arguments */
/*	The function should be in xlval and the arguments should
	be on the stack.  The number of arguments should be in xlargc.
*/
void xlapply()
{
    LVAL tmp;

    /* check for null function */
    if (null(xlval))
	badfuntype(xlval);

    /* dispatch on function type */
    switch (ntype(xlval)) {
    case SUBR:
	xlval = (*getsubr(xlval))();
	xlreturn();
	break;
    case XSUBR:
	(*getsubr(xlval))();
	break;
    case CLOSURE:
	xlfun = getcode(xlval);
	xlenv = getenv(xlval);
	base = pc = getcodestr(xlfun);
	break;
    case OBJECT:
	xlsend(xlval,xlgasymbol());
	break;
    case METHOD:
	xlfun = getcode(xlval);
	xlenv = cons(top(),getenv(xlval));
	base = pc = getcodestr(xlfun);
	break;
    case CONTINUATION:
	tmp = xlgetarg();
	xllastarg();
	restore_continuation();
	xlval = tmp;
	xlreturn();
	break;
    default:
	badfuntype(xlval);
    }
}

/* xlreturn - return to a continuation on the stack */
void xlreturn()
{
    LVAL tmp;
    
    /* restore the enviroment and the continuation function */
    xlenv = pop();
    tmp = pop();
    
    /* dispatch on the function type */
    switch (ntype(tmp)) {
    case CODE:
    	xlfun = tmp;
    	tmp = pop();
	base = getcodestr(xlfun);
	pc = base + (int)getsfixnum(tmp);
	break;
    case CSUBR:
	(*getsubr(tmp))();
	break;
    default:
	xlerror("bad continuation",tmp);
    }
}

/* make_continuation - make a continuation */
static LVAL make_continuation()
{
    LVAL cont,*src,*dst;
    int size;

    /* save a continuation on the stack */
    check(3);
    push(cvsfixnum((FIXTYPE)(pc - base)));
    push(xlfun);
    push(xlenv);

    /* create and initialize a continuation object */
    size = (int)(xlstktop - xlsp);
    cont = newcontinuation(size);
    for (src = xlsp, dst = &cont->n_vdata[0]; --size >= 0; )
	*dst++ = *src++;
    
    /* return the continuation */
    return (cont);
}

/* restore_continuation - restore a continuation to the stack */
/*	The continuation should be in xlval.
*/
static void restore_continuation()
{
    LVAL *src;
    int size;
    size = getsize(xlval);
    for (src = &xlval->n_vdata[size], xlsp = xlstktop; --size >= 0; )
	*--xlsp = *--src;
}

/* gc_protect - protect the state of the interpreter from the collector */
void gc_protect(protected_fcn)
  void (*protected_fcn)();
{
    int pcoff;
    pcoff = pc - base;
    (*protected_fcn)();
    if (xlfun) {
	base = getcodestr(xlfun);
	pc = base + pcoff;
    }
}

/* badfuntype - bad function error */
static void badfuntype(arg)
  LVAL arg;
{
    xlerror("bad function type",arg);
}

/* badargtype - bad argument type error */
static void badargtype(arg)
  LVAL arg;
{
    xlbadtype(arg);
}

/* xlstkover - value stack overflow */
void xlstkover()
{
    xlabort("value stack overflow");
}

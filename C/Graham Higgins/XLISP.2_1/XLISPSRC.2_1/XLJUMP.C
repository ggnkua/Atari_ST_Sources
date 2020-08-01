/* xljump - execution context routines */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern CONTEXT *xlcontext,*xltarget;
extern LVAL xlvalue,xlenv,xlfenv,xldenv;
extern int xlmask;

/* xlbegin - beginning of an execution context */
xlbegin(cptr,flags,expr)
  CONTEXT *cptr; int flags; LVAL expr;
{
    cptr->c_flags = flags;
    cptr->c_expr = expr;
    cptr->c_xlstack = xlstack;
    cptr->c_xlenv = xlenv;
    cptr->c_xlfenv = xlfenv;
    cptr->c_xldenv = xldenv;
    cptr->c_xlcontext = xlcontext;
    cptr->c_xlargv = xlargv;
    cptr->c_xlargc = xlargc;
    cptr->c_xlfp = xlfp;
    cptr->c_xlsp = xlsp;
    xlcontext = cptr;
}

/* xlend - end of an execution context */
xlend(cptr)
  CONTEXT *cptr;
{
    xlcontext = cptr->c_xlcontext;
}

/* xlgo - go to a label */
xlgo(label)
  LVAL label;
{
    CONTEXT *cptr;
    LVAL *argv;
    int argc;

    /* find a tagbody context */
    for (cptr = xlcontext; cptr; cptr = cptr->c_xlcontext)
	if (cptr->c_flags & CF_GO) {
	    argc = cptr->c_xlargc;
	    argv = cptr->c_xlargv;
	    while (--argc >= 0)
		if (*argv++ == label) {
		    cptr->c_xlargc = argc;
		    cptr->c_xlargv = argv;
		    xljump(cptr,CF_GO,NIL);
		}
	}
    xlfail("no target for GO");
}

/* xlreturn - return from a block */
xlreturn(name,val)
  LVAL name,val;
{
    CONTEXT *cptr;

    /* find a block context */
    for (cptr = xlcontext; cptr; cptr = cptr->c_xlcontext)
	if (cptr->c_flags & CF_RETURN && cptr->c_expr == name)
	    xljump(cptr,CF_RETURN,val);
    xlfail("no target for RETURN");
}

/* xlthrow - throw to a catch */
xlthrow(tag,val)
  LVAL tag,val;
{
    CONTEXT *cptr;

    /* find a catch context */
    for (cptr = xlcontext; cptr; cptr = cptr->c_xlcontext)
	if ((cptr->c_flags & CF_THROW) && cptr->c_expr == tag)
	    xljump(cptr,CF_THROW,val);
    xlfail("no target for THROW");
}

/* xlsignal - signal an error */
xlsignal(emsg,arg)
  char *emsg; LVAL arg;
{
    CONTEXT *cptr;

    /* find an error catcher */
    for (cptr = xlcontext; cptr; cptr = cptr->c_xlcontext)
	if (cptr->c_flags & CF_ERROR) {
	    if (cptr->c_expr && emsg)
		xlerrprint("error",NULL,emsg,arg);
	    xljump(cptr,CF_ERROR,NIL);
	}
}

/* xltoplevel - go back to the top level */
xltoplevel()
{
    stdputstr("[ back to top level ]\n");
    findandjump(CF_TOPLEVEL,"no top level");
}

/* xlbrklevel - go back to the previous break level */
xlbrklevel()
{
    findandjump(CF_BRKLEVEL,"no previous break level");
}

/* xlcleanup - clean-up after an error */
xlcleanup()
{
    stdputstr("[ back to previous break level ]\n");
    findandjump(CF_CLEANUP,"not in a break loop");
}

/* xlcontinue - continue from an error */
xlcontinue()
{
    findandjump(CF_CONTINUE,"not in a break loop");
}

/* xljump - jump to a saved execution context */
xljump(target,mask,val)
  CONTEXT *target; int mask; LVAL val;
{
    /* unwind the execution stack */
    for (; xlcontext != target; xlcontext = xlcontext->c_xlcontext)

	/* check for an UNWIND-PROTECT */
	if ((xlcontext->c_flags & CF_UNWIND)) {
	    xltarget = target;
	    xlmask = mask;
	    break;
	}
	   
    /* restore the state */
    xlstack = xlcontext->c_xlstack;
    xlenv = xlcontext->c_xlenv;
    xlfenv = xlcontext->c_xlfenv;
    xlunbind(xlcontext->c_xldenv);
    xlargv = xlcontext->c_xlargv;
    xlargc = xlcontext->c_xlargc;
    xlfp = xlcontext->c_xlfp;
    xlsp = xlcontext->c_xlsp;
    xlvalue = val;

    /* call the handler */
    longjmp(xlcontext->c_jmpbuf,mask);
}

/* findandjump - find a target context frame and jump to it */
LOCAL findandjump(mask,error)
  int mask; char *error;
{
    CONTEXT *cptr;

    /* find a block context */
    for (cptr = xlcontext; cptr; cptr = cptr->c_xlcontext)
	if (cptr->c_flags & mask)
	    xljump(cptr,mask,NIL);
    xlabort(error);
}


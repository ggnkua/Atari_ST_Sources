/* xldebug - xlisp debugging support */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xlisp.h"

/* external variables */
extern int xldebug;
extern int xlsample;
extern LVAL s_debugio,s_unbound;
extern LVAL s_tracenable,s_tlimit,s_breakenable;
extern LVAL true;
extern char buf[];

/* external routines */
extern char *malloc();

/* forward declarations */
FORWARD LVAL stacktop();

/* xlabort - xlisp serious error handler */
xlabort(emsg)
  char *emsg;
{
    xlsignal(emsg,s_unbound);
    xlerrprint("error",NULL,emsg,s_unbound);
    xlbrklevel();
}

/* xlbreak - enter a break loop */
xlbreak(emsg,arg)
  char *emsg; LVAL arg;
{
    breakloop("break","return from BREAK",emsg,arg,TRUE);
}

/* xlfail - xlisp error handler */
xlfail(emsg)
  char *emsg;
{
    xlerror(emsg,s_unbound);
}

/* xlerror - handle a fatal error */
xlerror(emsg,arg)
  char *emsg; LVAL arg;
{
    if (getvalue(s_breakenable) != NIL)
	breakloop("error",NULL,emsg,arg,FALSE);
    else {
	xlsignal(emsg,arg);
	xlerrprint("error",NULL,emsg,arg);
	xlbrklevel();
    }
}

/* xlcerror - handle a recoverable error */
xlcerror(cmsg,emsg,arg)
  char *cmsg,*emsg; LVAL arg;
{
    if (getvalue(s_breakenable) != NIL)
	breakloop("error",cmsg,emsg,arg,TRUE);
    else {
	xlsignal(emsg,arg);
	xlerrprint("error",NULL,emsg,arg);
	xlbrklevel();
    }
}

/* xlerrprint - print an error message */
xlerrprint(hdr,cmsg,emsg,arg)
  char *hdr,*cmsg,*emsg; LVAL arg;
{
    /* print the error message */
    sprintf(buf,"%s: %s",hdr,emsg);
    errputstr(buf);

    /* print the argument */
    if (arg != s_unbound) {
	errputstr(" - ");
	errprint(arg);
    }

    /* no argument, just end the line */
    else
	errputstr("\n");

    /* print the continuation message */
    if (cmsg) {
	sprintf(buf,"if continued: %s\n",cmsg);
	errputstr(buf);
    }
}

/* breakloop - the debug read-eval-print loop */
LOCAL int breakloop(hdr,cmsg,emsg,arg,cflag)
  char *hdr,*cmsg,*emsg; LVAL arg; int cflag;
{
    LVAL expr,val;
    CONTEXT cntxt;
    int type;

    /* print the error message */
    xlerrprint(hdr,cmsg,emsg,arg);

    /* flush the input buffer */
    xlflush();

    /* do the back trace */
    if (getvalue(s_tracenable)) {
	val = getvalue(s_tlimit);
	xlbaktrace(fixp(val) ? (int)getfixnum(val) : -1);
    }

    /* protect some pointers */
    xlsave1(expr);

    /* increment the debug level */
    ++xldebug;

    /* debug command processing loop */
    xlbegin(&cntxt,CF_BRKLEVEL|CF_CLEANUP|CF_CONTINUE,true);
    for (type = 0; type == 0; ) {

	/* setup the continue trap */
	if (type = setjmp(cntxt.c_jmpbuf))
	    switch (type) {
	    case CF_CLEANUP:
		continue;
	    case CF_BRKLEVEL:
		type = 0;
		break;
	    case CF_CONTINUE:
		if (cflag) {
		    dbgputstr("[ continue from break loop ]\n");
		    continue;
		}
		else xlabort("this error can't be continued");
	    }

	/* print a prompt */
	sprintf(buf,"%d> ",xldebug);
	dbgputstr(buf);

	/* read an expression and check for eof */
	if (!xlread(getvalue(s_debugio),&expr,FALSE)) {
	    type = CF_CLEANUP;
	    break;
	}

	/* save the input expression */
	xlrdsave(expr);

	/* evaluate the expression */
	expr = xleval(expr);

	/* save the result */
	xlevsave(expr);

	/* print it */
	dbgprint(expr);
    }
    xlend(&cntxt);

    /* decrement the debug level */
    --xldebug;

    /* restore the stack */
    xlpop();

    /* check for aborting to the previous level */
    if (type == CF_CLEANUP)
	xlbrklevel();
}

/* baktrace - do a back trace */
xlbaktrace(n)
  int n;
{
    LVAL *fp,*p;
    int argc;
    for (fp = xlfp; (n < 0 || n--) && *fp; fp = fp - (int)getfixnum(*fp)) {
	p = fp + 1;
	errputstr("Function: ");
	errprint(*p++);
	if (argc = (int)getfixnum(*p++))
	    errputstr("Arguments:\n");
	while (--argc >= 0) {
	    errputstr("  ");
	    errprint(*p++);
	}
    }
}

/* xldinit - debug initialization routine */
xldinit()
{
    xlsample = 0;
    xldebug = 0;
}


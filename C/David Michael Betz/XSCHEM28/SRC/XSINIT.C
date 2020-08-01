/* xsinit.c - xscheme initialization routines */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"
#include "xsbcode.h"

/* macro to store a byte into a bytecode vector */
#define pb(x)	(*bcode++ = (x))

/* global variables */
LVAL lk_optional,lk_rest;
LVAL obarray,true,eof_object,default_object,s_unassigned;
LVAL cs_map1,cs_foreach1,cs_withfile1,cs_load1,cs_force1;
LVAL c_lpar,c_rpar,c_dot,c_quote,s_quote;
LVAL s_eval,s_unbound,s_stdin,s_stdout,s_stderr;
LVAL s_printcase,k_upcase,k_downcase;
LVAL s_fixfmt,s_flofmt;

/* external variables */
extern jmp_buf top_level;
extern FUNDEF funtab[];
extern int xsubrcnt;
extern int csubrcnt;

/* xlinitws - create an initial workspace */
void xlinitws(ssize)
  unsigned int ssize;
{
    unsigned char *bcode;
    int type,i;
    LVAL code;
    FUNDEF *p;

    /* allocate memory for the workspace */
    xlminit(ssize);

    /* initialize the obarray */
    s_unbound = NIL; /* to make cvsymbol work */
    obarray = cvsymbol("*OBARRAY*");
    setvalue(obarray,newvector(HSIZE));

    /* add the symbol *OBARRAY* to the obarray */
    setelement(getvalue(obarray),
               hash(getstring(getpname(obarray)),HSIZE),
               cons(obarray,NIL));

    /* enter the eof object */
    eof_object = cons(xlenter("**EOF**"),NIL);
    
    /* enter the default object */
    default_object = cons(xlenter("**DEFAULT**"),NIL);

    /* initialize the error handlers */
    setvalue(xlenter("*ERROR-HANDLER*"),NIL);
    setvalue(xlenter("*UNBOUND-HANDLER*"),NIL);
    
    /* install the built-in functions */
    for (i = 0, p = funtab; p->fd_subr != NULL; ++i, ++p) {
	type = (i < xsubrcnt ? XSUBR : (i < csubrcnt ? CSUBR : SUBR));
	xlsubr(p->fd_name,type,p->fd_subr,i);
    }
    xloinit(); /* initialize xsobj.c */

    /* setup some synonyms */
    setvalue(xlenter("NOT"),getvalue(xlenter("NULL?")));
    setvalue(xlenter("PRIN1"),getvalue(xlenter("WRITE")));
    setvalue(xlenter("PRINC"),getvalue(xlenter("DISPLAY")));

    /* enter all of the symbols used by the runtime system */
    xlsymbols();

    /* set the initial values of the symbols #T, T and NIL */
    setvalue(true,true);
    setvalue(xlenter("T"),true);
    setvalue(xlenter("NIL"),NIL);

    /* default to lowercase output of symbols */
    setvalue(s_printcase,k_downcase);

    /* setup the print formats for numbers */
    setvalue(s_fixfmt,cvstring(IFMT));
    setvalue(s_flofmt,cvstring(FFMT));
    
    /* build the 'eval' function */
    code = newcode(4); cpush(code);
    setelement(code,0,newstring(0x12));
    setelement(code,1,xlenter("EVAL"));
    setelement(code,2,cons(xlenter("X"),NIL));
    setelement(code,3,xlenter("COMPILE"));
    drop(1);

    /* store the byte codes */
    bcode = (unsigned char *)getstring(getbcode(code));

pb(OP_FRAME);pb(0x02);		/* 0000 12 02    FRAME 02		*/
pb(OP_MVARG);pb(0x01);		/* 0002 13 01    MVARG 01		*/
pb(OP_ALAST);			/* 0004 1a       ALAST			*/
pb(OP_SAVE);pb(0x00);pb(0x10);	/* 0005 0b 00 10 SAVE 0010		*/
pb(OP_EREF);pb(0x00);pb(0x01);	/* 0008 09 00 01 EREF 00 01 ; x		*/
pb(OP_PUSH);			/* 000b 10       PUSH			*/
pb(OP_GREF);pb(0x03);		/* 000c 05 03    GREF 03 ; compile	*/
pb(OP_CALL);pb(0x01);		/* 000e 0c 01    CALL 01		*/
pb(OP_CALL);pb(0x00);		/* 0010 0c 00    CALL 00		*/

    setvalue(getelement(code,1),cvclosure(code,NIL));

    /* setup the initialization code */
    code = newcode(6); cpush(code);
    setelement(code,0,newstring(0x11));
    setelement(code,1,xlenter("*INITIALIZE*"));
    setelement(code,3,cvstring("xscheme.ini"));
    setelement(code,4,xlenter("LOAD"));
    setelement(code,5,xlenter("*TOPLEVEL*"));
    drop(1);

    /* store the byte codes */
    bcode = (unsigned char *)getstring(getbcode(code));

pb(OP_FRAME);pb(0x01);		/* 0000 12 01    FRAME 01		*/
pb(OP_ALAST);			/* 0002 1a       ALAST			*/
pb(OP_SAVE); pb(0x00); pb(0x0d);/* 0003 0b 00 0d SAVE 000d		*/
pb(OP_LIT);  pb(0x03);		/* 0006 04 03    LIT 03 ; "xscheme.ini"	*/
pb(OP_PUSH);			/* 0008 10       PUSH			*/
pb(OP_GREF); pb(0x04);		/* 0009 05 04    GREF 04 ; load		*/
pb(OP_CALL); pb(0x01);		/* 000b 0c 01    CALL 01		*/
pb(OP_GREF); pb(0x05);		/* 000d 05 05    GREF 05 ; *toplevel*	*/
pb(OP_CALL); pb(0x00);		/* 000f 0c 00    CALL 00		*/

    setvalue(getelement(code,1),cvclosure(code,NIL));

    /* setup the main loop code */
    code = newcode(9); cpush(code);
    setelement(code,0,newstring(0x28));
    setelement(code,1,xlenter("*TOPLEVEL*"));
    setelement(code,3,cvstring("\n> "));
    setelement(code,4,xlenter("DISPLAY"));
    setelement(code,5,xlenter("READ"));
    setelement(code,6,xlenter("EVAL"));
    setelement(code,7,xlenter("WRITE"));
    setelement(code,8,xlenter("*TOPLEVEL*"));
    drop(1);

    /* store the byte codes */
    bcode = (unsigned char *)getstring(getbcode(code));

pb(OP_FRAME);pb(0x01);		/* 0000 12 01    FRAME 01		*/
pb(OP_ALAST);			/* 0002 1a       ALAST			*/
pb(OP_SAVE); pb(0x00); pb(0x0d);/* 0003 0b 00 0d SAVE 000d		*/
pb(OP_LIT);  pb(0x03);		/* 0006 04 03    LIT 03 ; "\n> "		*/
pb(OP_PUSH);			/* 0008 10       PUSH			*/
pb(OP_GREF); pb(0x04);		/* 0009 05 04    GREF 04 ; display	*/
pb(OP_CALL); pb(0x01);		/* 000b 0c 01    CALL 01		*/
pb(OP_SAVE); pb(0x00); pb(0x24);/* 000d 0b 00 24 SAVE 0024		*/
pb(OP_SAVE); pb(0x00); pb(0x1f);/* 0010 0b 00 1f SAVE 001f		*/
pb(OP_SAVE); pb(0x00); pb(0x1a);/* 0013 0b 00 1a SAVE 001a		*/
pb(OP_GREF); pb(0x05);		/* 0016 05 05    GREF 05 ; read		*/
pb(OP_CALL); pb(0x00);		/* 0018 0c 00    CALL 00		*/
pb(OP_PUSH);			/* 001a 10       PUSH			*/
pb(OP_GREF); pb(0x06);		/* 001b 05 06    GREF 06 ; eval		*/
pb(OP_CALL); pb(0x01);		/* 001d 0c 01    CALL 01		*/
pb(OP_PUSH);			/* 001f 10       PUSH			*/
pb(OP_GREF); pb(0x07);		/* 0020 05 07    GREF 07 ; write	*/
pb(OP_CALL); pb(0x01);		/* 0022 0c 01    CALL 01		*/
pb(OP_GREF); pb(0x08);		/* 0024 05 08    GREF 08 ; *toplevel*	*/
pb(OP_CALL); pb(0x00);		/* 0026 0c 00    CALL 00		*/

    setvalue(getelement(code,1),cvclosure(code,NIL));
}

/* xlsymbols - lookup/enter all symbols used by the runtime system */
void xlsymbols()
{
    LVAL sym;
    
    /* top-level procedure symbol */
    s_eval = xlenter("EVAL");
    
    /* enter the symbols used by the system */
    true         = xlenter("#T");
    s_unbound	 = xlenter("*UNBOUND*");
    s_unassigned = xlenter("#!UNASSIGNED");

    /* enter the i/o symbols */
    s_stdin  = xlenter("*STANDARD-INPUT*");
    s_stdout = xlenter("*STANDARD-OUTPUT*");
    s_stderr = xlenter("*ERROR-OUTPUT*");
    
    /* enter the symbols used by the printer */
    s_fixfmt = xlenter("*FIXNUM-FORMAT*");
    s_flofmt = xlenter("*FLONUM-FORMAT*");

    /* enter the lambda list keywords */
    lk_optional = xlenter("#!OPTIONAL");
    lk_rest     = xlenter("#!REST");

    /* enter symbols needed by the reader */
    c_lpar   = xlenter("(");
    c_rpar   = xlenter(")");
    c_dot    = xlenter(".");
    c_quote  = xlenter("'");
    s_quote  = xlenter("QUOTE");

    /* 'else' is a useful synonym for #t in cond clauses */
    sym = xlenter("ELSE");
    setvalue(sym,true);

    /* setup stdin/stdout/stderr */
    setvalue(s_stdin,cvport(stdin,PF_INPUT));
    setvalue(s_stdout,cvport(stdout,PF_OUTPUT));
    setvalue(s_stderr,cvport(stderr,PF_OUTPUT));

    /* enter *print-case* and its keywords */
    k_upcase	= xlenter("UPCASE");
    k_downcase	= xlenter("DOWNCASE");
    s_printcase	= xlenter("*PRINT-CASE*");

    /* get the built-in continuation subrs */
    cs_map1 = getvalue(xlenter("%MAP1"));
    cs_foreach1 = getvalue(xlenter("%FOR-EACH1"));
    cs_withfile1 = getvalue(xlenter("%WITH-FILE1"));
    cs_load1 = getvalue(xlenter("%LOAD1"));
    cs_force1 = getvalue(xlenter("%FORCE1"));

    /* initialize xsobj.c */
    obsymbols();
}

/* xsftab.c - built-in function table */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* external variables */
extern LVAL s_stdin,s_stdout;

/* external functions */
extern void
    xapply(),xcallcc(),xmap(),xmap1(),xforeach(),xforeach1(),
    xforce(),xforce1(),xcallwi(),xcallwo(),xwithfile1(),
    xload(),xloadnoisily(),xload1(),xsendsuper(),clnew();
extern LVAL
    clisnew(),clanswer(),obisnew(),obclass(),obshow(),
    xcons(),xcar(),xcdr(),
    xcaar(),xcadr(),xcdar(),xcddr(),
    xcaaar(),xcaadr(),xcadar(),xcaddr(),
    xcdaar(),xcdadr(),xcddar(),xcdddr(),
    xcaaaar(),xcaaadr(),xcaadar(),xcaaddr(),
    xcadaar(),xcadadr(),xcaddar(),xcadddr(),
    xcdaaar(),xcdaadr(),xcdadar(),xcdaddr(),
    xcddaar(),xcddadr(),xcdddar(),xcddddr(),
    xsetcar(),xsetcdr(),xlist(),xliststar(),
    xappend(),xreverse(),xlastpair(),xlength(),xlistref(),xlisttail(),
    xmember(),xmemv(),xmemq(),xassoc(),xassv(),xassq(),
    xsymvalue(),xsetsymvalue(),xsymplist(),xsetsymplist(),xgensym(),
    xboundp(),xget(),xput(),
    xtheenvironment(),xprocenvironment(),xenvp(),xenvbindings(),xenvparent(),
    xvector(),xmakevector(),xvlength(),xvref(),xvset(),
    xvectlist(),xlistvect(),
    xmakearray(),xaref(),xaset(),
    xsymstr(),xstrsym(),
    xnull(),xatom(),xlistp(),xnumberp(),xbooleanp(),
    xpairp(),xsymbolp(),xintegerp(),xrealp(),xcharp(),xstringp(),xvectorp(),
    xprocedurep(),xobjectp(),xdefaultobjectp(),
    xinputportp(),xoutputportp(),xportp(),
    xeq(),xeqv(),xequal(),
    xzerop(),xpositivep(),xnegativep(),xoddp(),xevenp(),
    xexactp(),xinexactp(),
    xadd1(),xsub1(),xabs(),xgcd(),xrandom(),
    xadd(),xsub(),xmul(),xdiv(),xquo(),xrem(),xmin(),xmax(),
    xsin(),xcos(),xtan(),xasin(),xacos(),xatan(),
    xxexp(),xsqrt(),xexpt(),xxlog(),xtruncate(),xfloor(),xceiling(),xround(),
    xlogand(),xlogior(),xlogxor(),xlognot(),
    xlss(),xleq(),xeql(),xgeq(),xgtr(),
    xstrlen(),xstrnullp(),xstrappend(),xstrref(),xsubstring(),
    xstrlist(),xliststring(),
    xstrlss(),xstrleq(),xstreql(),xstrgeq(),xstrgtr(),
    xstrilss(),xstrileq(),xstrieql(),xstrigeq(),xstrigtr(),
    xcharint(),xintchar(),
    xchrlss(),xchrleq(),xchreql(),xchrgeq(),xchrgtr(),
    xchrilss(),xchrileq(),xchrieql(),xchrigeq(),xchrigtr(),
    xread(),xrdchar(),xrdbyte(),xrdshort(),xrdlong(),xeofobjectp(),
    xwrite(),xwrchar(),xwrbyte(),xwrshort(),xwrlong(),
    xdisplay(),xnewline(),xprint(),xprbreadth(),xprdepth(),
    xopeni(),xopeno(),xopena(),xopenu(),xclosei(),xcloseo(),xclose(),
    xgetfposition(),xsetfposition(),xcurinput(),xcuroutput(),
    xtranson(),xtransoff(),xgetarg(),xexit(),xcompile(),xdecompile(),xgc(),
    xsave(),xrestore(),xtraceon(),xtraceoff(),xreset(),xerror(),
    xicar(),xicdr(),xisetcar(),xisetcdr(),xivlength(),xivref(),xivset();

/* include machine specific declarations */
#include "osdefs.h"

int xsubrcnt = 12;	/* number of XSUBR functions */
int csubrcnt = 17;	/* number of CSUBR functions + xsubrcnt */

typedef LVAL (*FP)();

/* built-in functions */
FUNDEF funtab[] = {

	/* functions that call eval or apply (# must match xsubrcnt) */
{	"APPLY",				(FP)xapply     	},
{	"CALL-WITH-CURRENT-CONTINUATION",	(FP)xcallcc    	},
{	"CALL/CC",				(FP)xcallcc    	},
{	"MAP",					(FP)xmap       	},
{	"FOR-EACH",				(FP)xforeach	},
{	"CALL-WITH-INPUT-FILE",			(FP)xcallwi  	},
{	"CALL-WITH-OUTPUT-FILE",		(FP)xcallwo  	},
{	"LOAD",					(FP)xload    	},
{	"LOAD-NOISILY",				(FP)xloadnoisily},
{	"SEND-SUPER",				(FP)xsendsuper	},
{	"%CLASS-NEW",				(FP)clnew      	},
{	"FORCE",				(FP)xforce     	},

	/* continuations for xsubrs (# must match csubrcnt) */
{	"%MAP1",				(FP)xmap1      	},
{	"%FOR-EACH1",				(FP)xforeach1	},
{	"%WITH-FILE1",				(FP)xwithfile1	},
{	"%LOAD1",				(FP)xload1     	},
{	"%FORCE1",				(FP)xforce1    	},

	/* methods */
{	"%CLASS-ISNEW",				clisnew		},
{	"%CLASS-ANSWER",			clanswer	},
{	"%OBJECT-ISNEW",			obisnew		},
{	"%OBJECT-CLASS",			obclass		},
{	"%OBJECT-SHOW",				obshow		},

	/* list functions */
{	"CONS",					xcons		},
{	"CAR",					xcar		},
{	"CDR",					xcdr		},
{	"CAAR",					xcaar		},
{	"CADR",					xcadr		},
{	"CDAR",					xcdar		},
{	"CDDR",					xcddr		},
{	"CAAAR",				xcaaar		},
{	"CAADR",				xcaadr		},
{	"CADAR",				xcadar		},
{	"CADDR",				xcaddr		},
{	"CDAAR",				xcdaar		},
{	"CDADR",				xcdadr		},
{	"CDDAR",				xcddar		},
{	"CDDDR",				xcdddr		},
{	"CAAAAR", 				xcaaaar		},
{	"CAAADR",				xcaaadr		},
{	"CAADAR",				xcaadar		},
{	"CAADDR",				xcaaddr		},
{	"CADAAR",		 		xcadaar		},
{	"CADADR",				xcadadr		},
{	"CADDAR",				xcaddar		},
{	"CADDDR",				xcadddr		},
{	"CDAAAR",				xcdaaar		},
{	"CDAADR",				xcdaadr		},
{	"CDADAR",				xcdadar		},
{	"CDADDR",				xcdaddr		},
{	"CDDAAR",				xcddaar		},
{	"CDDADR",				xcddadr		},
{	"CDDDAR",				xcdddar		},
{	"CDDDDR",				xcddddr		},
{	"LIST",					xlist		},
{	"LIST*",				xliststar	},
{	"APPEND",				xappend		},
{	"REVERSE",				xreverse	},
{	"LAST-PAIR",				xlastpair	},
{	"LENGTH",				xlength		},
{	"MEMBER",				xmember		},
{	"MEMV",					xmemv		},
{	"MEMQ",					xmemq		},
{	"ASSOC",				xassoc		},
{	"ASSV",					xassv		},
{	"ASSQ",					xassq		},
{	"LIST-REF",				xlistref	},
{	"LIST-TAIL",				xlisttail	},

	/* destructive list functions */
{	"SET-CAR!",				xsetcar		},
{	"SET-CDR!",				xsetcdr		},


	/* symbol functions */
{	"BOUND?",				xboundp		},
{	"SYMBOL-VALUE",				xsymvalue	},
{	"SET-SYMBOL-VALUE!",			xsetsymvalue	},
{	"SYMBOL-PLIST",				xsymplist	},
{	"SET-SYMBOL-PLIST!",			xsetsymplist	},
{	"GENSYM",				xgensym		},
{	"GET",					xget		},
{	"PUT",					xput		},

	/* environment functions */
{	"THE-ENVIRONMENT",			xtheenvironment	},
{	"PROCEDURE-ENVIRONMENT",		xprocenvironment},
{	"ENVIRONMENT?",				xenvp		},
{	"ENVIRONMENT-BINDINGS",			xenvbindings	},
{	"ENVIRONMENT-PARENT",			xenvparent	},

	/* vector functions */
{	"VECTOR",				xvector		},
{	"MAKE-VECTOR",				xmakevector	},
{	"VECTOR-LENGTH",			xvlength	},
{	"VECTOR-REF",				xvref		},
{	"VECTOR-SET!",				xvset		},

	/* array functions */
{	"MAKE-ARRAY",				xmakearray	},
{	"ARRAY-REF",				xaref		},
{	"ARRAY-SET!",				xaset		},

	/* conversion functions */
{	"SYMBOL->STRING",			xsymstr		},
{	"STRING->SYMBOL",			xstrsym		},
{	"VECTOR->LIST",				xvectlist	},
{	"LIST->VECTOR",				xlistvect	},
{	"STRING->LIST",				xstrlist	},
{	"LIST->STRING",				xliststring	},
{	"CHAR->INTEGER",			xcharint	},
{	"INTEGER->CHAR",			xintchar	},

	/* predicate functions */
{	"NULL?",				xnull		},
{	"ATOM?",				xatom		},
{	"LIST?",				xlistp		},
{	"NUMBER?",				xnumberp	},
{	"BOOLEAN?",				xbooleanp	},
{	"PAIR?",				xpairp		},
{	"SYMBOL?",				xsymbolp	},
{	"COMPLEX?",				xrealp		}, /*(1)*/
{	"REAL?",				xrealp		},
{	"RATIONAL?",				xintegerp	}, /*(1)*/
{	"INTEGER?",				xintegerp	},
{	"CHAR?",				xcharp		},
{	"STRING?",				xstringp	},
{	"VECTOR?",				xvectorp	},
{	"PROCEDURE?",				xprocedurep	},
{	"PORT?",				xportp		},
{	"INPUT-PORT?",				xinputportp	},
{	"OUTPUT-PORT?",				xoutputportp	},
{	"OBJECT?",				xobjectp	},
{	"EOF-OBJECT?",				xeofobjectp	},
{	"DEFAULT-OBJECT?",			xdefaultobjectp	},
{	"EQ?",					xeq		},
{	"EQV?",					xeqv		},
{	"EQUAL?",				xequal		},

	/* arithmetic functions */
{	"ZERO?",				xzerop		},
{	"POSITIVE?",				xpositivep	},
{	"NEGATIVE?",				xnegativep	},
{	"ODD?",					xoddp		},
{	"EVEN?",				xevenp		},
{	"EXACT?",				xexactp		},
{	"INEXACT?",				xinexactp	},
{	"TRUNCATE",				xtruncate	},
{	"FLOOR",				xfloor		},
{	"CEILING",				xceiling	},
{	"ROUND",				xround		},
{	"1+",					xadd1		},
{	"-1+",					xsub1		},
{	"ABS",					xabs		},
{	"GCD",					xgcd		},
{	"RANDOM",				xrandom		},
{	"+",					xadd		},
{	"-",					xsub		},
{	"*",					xmul		},
{	"/",					xdiv		},
{	"QUOTIENT",				xquo		},
{	"REMAINDER",				xrem		},
{	"MIN",					xmin		},
{	"MAX",					xmax		},
{	"SIN",					xsin		},
{	"COS",					xcos		},
{	"TAN",					xtan		},
{	"ASIN",					xasin		},
{	"ACOS",					xacos		},
{	"ATAN",					xatan		},
{	"EXP",					xxexp		},
{	"SQRT",					xsqrt		},
{	"EXPT",					xexpt		},
{	"LOG",					xxlog		},

	/* bitwise logical functions */
{	"LOGAND",				xlogand		},
{	"LOGIOR",				xlogior		},
{	"LOGXOR",				xlogxor		},
{	"LOGNOT",				xlognot		},

	/* numeric comparison functions */
{	"<",					xlss		},
{	"<=",					xleq		},
{	"=",					xeql		},
{	">=",					xgeq		},
{	">",					xgtr		},

	/* string functions */
{	"STRING-LENGTH",			xstrlen		},
{	"STRING-NULL?",				xstrnullp	},
{	"STRING-APPEND",			xstrappend	},
{	"STRING-REF",				xstrref		},
{	"SUBSTRING",				xsubstring	},
{	"STRING<?",				xstrlss		},
{	"STRING<=?",				xstrleq		},
{	"STRING=?",				xstreql		},
{	"STRING>=?",				xstrgeq		},
{	"STRING>?",				xstrgtr		},
{	"STRING-CI<?",				xstrilss	},
{	"STRING-CI<=?",				xstrileq	},
{	"STRING-CI=?",				xstrieql	},
{	"STRING-CI>=?",				xstrigeq	},
{	"STRING-CI>?",				xstrigtr	},

	/* character functions */
{	"CHAR<?",				xchrlss		},
{	"CHAR<=?",				xchrleq		},
{	"CHAR=?",				xchreql		},
{	"CHAR>=?",				xchrgeq		},
{	"CHAR>?",				xchrgtr		},
{	"CHAR-CI<?",				xchrilss	},
{	"CHAR-CI<=?",				xchrileq	},
{	"CHAR-CI=?",				xchrieql	},
{	"CHAR-CI>=?",				xchrigeq	},
{	"CHAR-CI>?",				xchrigtr	},

	/* I/O functions */
{	"READ",					xread		},
{	"READ-CHAR",				xrdchar		},
{	"READ-BYTE",				xrdbyte		},
{	"READ-SHORT",				xrdshort	},
{	"READ-LONG",				xrdlong		},
{	"WRITE",				xwrite		},
{	"WRITE-CHAR",				xwrchar		},
{	"WRITE-BYTE",				xwrbyte		},
{	"WRITE-SHORT",				xwrshort	},
{	"WRITE-LONG",				xwrlong		},
{	"DISPLAY",				xdisplay	},
{	"PRINT",				xprint		},
{	"NEWLINE",				xnewline	},

	/* print control functions */
{	"PRINT-BREADTH",			xprbreadth	},
{	"PRINT-DEPTH",				xprdepth	},

	/* file I/O functions */
{	"OPEN-INPUT-FILE",			xopeni		},
{	"OPEN-OUTPUT-FILE",			xopeno		},
{	"OPEN-APPEND-FILE",			xopena		},
{	"OPEN-UPDATE-FILE",			xopenu		},
{	"CLOSE-PORT",				xclose		},
{	"CLOSE-INPUT-PORT",			xclosei		},
{	"CLOSE-OUTPUT-PORT",			xcloseo		},
{	"GET-FILE-POSITION",			xgetfposition	},
{	"SET-FILE-POSITION!",			xsetfposition	},
{	"CURRENT-INPUT-PORT",			xcurinput	},
{	"CURRENT-OUTPUT-PORT",			xcuroutput	},

	/* utility functions */
{	"TRANSCRIPT-ON",			xtranson	},
{	"TRANSCRIPT-OFF",			xtransoff	},
{	"GETARG",				xgetarg		},
{	"EXIT",					xexit		},
{	"COMPILE",				xcompile	},
{	"DECOMPILE",				xdecompile	},
{	"GC",					xgc		},
{	"SAVE",					xsave		},
{	"RESTORE",				xrestore	},
{	"RESET",				xreset		},
{	"ERROR",				xerror		},

	/* debugging functions */
{	"TRACE-ON",				xtraceon	},
{	"TRACE-OFF",				xtraceoff	},

	/* internal functions */
{	"%CAR",					xicar		},
{	"%CDR",					xicdr		},
{	"%SET-CAR!",				xisetcar	},
{	"%SET-CDR!",				xisetcdr	},
{	"%VECTOR-LENGTH",			xivlength	},
{	"%VECTOR-REF",				xivref		},
{	"%VECTOR-SET!",				xivset		},

/* include machine specific table entries */
#include "osptrs.h"

{0,0} /* end of table marker */

};

/* Notes:

   (1)	This version only supports integers and reals.

*/

/* curinput - get the current input port */
LVAL curinput()
{
    return (getvalue(s_stdin));
}

/* curoutput - get the current output port */
LVAL curoutput()
{
    return (getvalue(s_stdout));
}

/* eq - internal 'eq?' function */
int eq(arg1,arg2)
  LVAL arg1,arg2;
{
    return (arg1 == arg2);
}

/* eqv - internal 'eqv?' function */
int eqv(arg1,arg2)
  LVAL arg1,arg2;
{
    /* try the eq test first */
    if (arg1 == arg2)
	return (TRUE);

    /* compare fixnums, flonums and characters */
    if (!null(arg1)) {
	switch (ntype(arg1)) {
	case FIXNUM:
	    return (fixp(arg2)
	         && getfixnum(arg1) == getfixnum(arg2));
	case FLONUM:
	    return (floatp(arg2)
	         && getflonum(arg1) == getflonum(arg2));
	case CHAR:
	    return (charp(arg2)
	         && getchcode(arg1) == getchcode(arg2));
	}
    }
    return (FALSE);
}

/* equal - internal 'equal?' function */
int equal(arg1,arg2)
  LVAL arg1,arg2;
{
    /* try the eq test first */
    if (arg1 == arg2)
	return (TRUE);

    /* compare fixnums, flonums, characters, strings, vectors and conses */
    if (!null(arg1)) {
	switch (ntype(arg1)) {
	case FIXNUM:
	    return (fixp(arg2)
	         && getfixnum(arg1) == getfixnum(arg2));
	case FLONUM:
	    return (floatp(arg2)
	         && getflonum(arg1) == getflonum(arg2));
	case CHAR:
	    return (charp(arg2)
	         && getchcode(arg1) == getchcode(arg2));
	case STRING:
	    return (stringp(arg2)
	         && strcmp(getstring(arg1),getstring(arg2)) == 0);
	case VECTOR:
	    return (vectorp(arg2)
	         && vectorequal(arg1,arg2));
	case CONS:
	    return (consp(arg2)
	         && equal(car(arg1),car(arg2))
	         && equal(cdr(arg1),cdr(arg2)));
	}
    }
    return (FALSE);
}

/* vectorequal - compare two vectors */
int vectorequal(v1,v2)
  LVAL v1,v2;
{
    int len,i;

    /* compare the vector lengths */
    if ((len = getsize(v1)) != getsize(v2))
	return (FALSE);

    /* compare the vector elements */
    for (i = 0; i < len; ++i)
	if (!equal(getelement(v1,i),getelement(v2,i)))
	    return (FALSE);
    return (TRUE);
}

/* xltoofew - too few arguments to this function */
LVAL xltoofew()
{
    xlfail("too few arguments");
    return (NIL); /* never reached */
}

/* xltoomany - too many arguments to this function */
void xltoomany()
{
    xlfail("too many arguments");
}

/* xlbadtype - incorrect argument type */
LVAL xlbadtype(val)
  LVAL val;
{
    xlerror("incorrect type",val);
    return (NIL); /* never reached */
}

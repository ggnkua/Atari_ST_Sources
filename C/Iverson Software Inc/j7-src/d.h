/* ----------------------------------------------------------------------- */
/* J-Source Version 7 - COPYRIGHT 1993 Iverson Software Inc.               */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 7 license agreement:  You may use, copy, and           */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* Debug Definitions                                                       */


typedef struct DCST{  /* DCST - debug common stack structure               */
 struct AST a;
 struct DCST *lnk;    /* link to next debug stack entry                    */
 I t;                 /* type of stack entry                               */
 I ln;                /* # of parse tokens or line number or error num     */
 I n;                 /* parse index or defn monad/dyad or script tso      */
 A p;                 /* parse tokens or defn self or script C*            */
 A m;                 /* mgst name                                         */
} *DC;


#define DCPARS  1L    /* type of debug stack entry */
#define DCDEFN  2L
#define DCSCRP  3L
#define DCDEBG  4L
#define DCNAME  5L

#define DSZ	    ((sizeof(struct DCST)-sizeof(struct AST))/sizeof(I))
#define DSZX	(sizeof(struct DCST)/sizeof(I))

#define DCF(f)  void f(si)DC si;


extern B        dbcheck();
extern I       *deba();
extern DC       debadd();
extern void	    debug();
extern B		debugb;
extern void     debz();
extern B        deresetf;
extern B        drun;
extern DC       sitop;


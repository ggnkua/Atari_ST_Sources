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
/* LinkJ:  Declarations and Definitions                                    */


#define LINKJ 1

typedef char B;
typedef char C;
typedef long I;
typedef struct {I t,c,n,r,s[1];} *A;
typedef struct {A k,v;} K;
typedef A(*AF)();


 /* Fields of Type A */

#define AT(a)   ((a)->t)        /* Type.  One of the constants below.      */
#define AC(a)   ((a)->c)        /* Reference count.  Do not touch.         */
#define AN(a)   ((a)->n)        /* Number of elements.                     */
#define AR(a)   ((a)->r)        /* Rank (number of elements in the shape). */
#define AH      4L              /* Number of header words in A.            */
#define AS(a)   ((a)->s)        /* Ptr to the first element of the shape.  */
#define AV(a)   ((I*)(a)+AH+AR(a))  /* Ptr to the first array element.     */


 /* Values for AT(a) */

#define BOOL            1L      /* B  Boolean                              */
#define CHAR            2L      /* C  literal (character)                  */
#define INT             4L      /* I  integer                              */
#define FL              8L      /* D  floating point (double)              */
#define CMPX            16L     /* Z  complex                              */
#define BOX             32L     /* A  boxed                                */
#define BOXK            64L     /* K  box with key                         */


 /* Event Codes */

#define EVBREAK         1
#define EVDEFN          2
#define EVDOMAIN        3
#define EVILNAME        4
#define EVILNUM         5
#define EVINDEX         6
#define EVFACE          7
#define EVINPRUPT       8
#define EVLENGTH        9
#define EVLIMIT         10
#define EVNONCE         11
#define EVNOTASGN       12
#define EVOPENQ         13
#define EVRANK          14
#define EVSPELL         15
#define EVSYNTAX        16
#define EVSYSTEM        17
#define EVVALUE         18
#define EVWSFULL        19

#define NEVM            19      /* number of event codes                   */


 /* Useful Definitions */

#define ASSERT(b,e)     {if(!(b)){jerr=e; R 0;}}
#define F1(f)           A f(y)A y;
#define F2(f)           A f(x,y)A x,y;
#define R               return
#define RZ(exp)         {if(!(exp))R 0;}


 /* External Declarations */

extern B asgn;
extern C jerr;

extern C jc();                  /* C jc(I,AF*,AF*);                        */
extern C jfr();                 /* C jfr(A);                               */
extern C jinit();               /* C jinit(void);                          */
extern A jma();                 /* A jma(I,I,I);                           */
extern A jpr();                 /* A jpr(A);                               */
extern A jset();                /* A jset(C*,A);                           */
extern A jx();                  /* A jx(C*);                               */

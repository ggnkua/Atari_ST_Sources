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
/* Definitions for the Parser and Translators                              */


#define ACTION(f)       A  f(b,e,stack)I b,e;A *stack;
#define TACT(f)         AA f(b,e,stack)I b,e;AA*stack;

typedef struct{A a,t;} AA;
typedef AA(*AAF)();
typedef struct{I c[4];AF f;AAF vf,cf;I b,e,k;} PT;

extern AA               vadv(),   cadv();
extern AA               vconj(),  cconj();
extern AA               vcurry(), ccurry();
extern AA               vdyad(),  cdyad();
extern AA               vforkv(), cforkv();
extern AA               vhookv(), chookv();
extern AA               vformo(), cformo();
extern AA               vis();
extern AA               vmonad(), cmonad();
extern AA               vpunc();

extern PT               cases[];
extern I                ncases;
extern B                tfail;
extern A                tname;
extern A                tparse();
extern A                ttokens();
extern A                tval;

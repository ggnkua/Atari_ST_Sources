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
/* Macros and Defined-Constants for Verbs                                  */


#define SF1(f,Tv,Tx,exp)        void f(v,x)Tv*v;Tx*x;{*x=(exp);}
#define SF2(f,Tv,Tx,exp)        void f(u,v,x)Tv*u,*v;Tx*x;{*x=(exp);}

extern void     band();
extern void     bdiv();
extern void     beq();
extern void     bge();
extern void     bgt();
extern void     ble();
extern void     blt();
extern void     bminus();
extern void     bminus2();
extern void     bnand();
extern void     bne();
extern void     bnor();
extern void     bor();
extern void     bplus();
extern void     bplus2();
extern void     dbin();
extern void     ddiv();
extern void     deq();
extern void     dgcd();
extern void     dge();
extern void     dgt();
extern void     dlcm();
extern void     dle();
extern void     dlt();
extern void     dmax();
extern void     dmin();
extern void     dminus();
extern void     dne();
extern void     dplus();
extern void     dren();
extern void     dtymes();
extern void     idiv();
extern void     ieq();
extern void     igcd();
extern void     ige();
extern void     igt();
extern void     ilcm();
extern void     ile();
extern void     ilt();
extern void     imax();
extern void     imin();
extern void     iminus();
extern void     ine();
extern void     iplus();
extern void     irem();
extern void     itymes();
extern void     jbin();
extern void     jcir();
extern void     jdiv();
extern void     jeq();
extern void     jgcd();
extern void     jlcm();
extern void     jminus();
extern void     jne();
extern void     jplus();
extern void     jpow();
extern void     jrem();
extern void     jtymes();
extern D        xcos();
extern D        xcosh();
extern D        xexp();
extern D        xsin();
extern D        xsinh();
extern Z        zceil();
extern Z        zcir();
extern Z        zconjug();
extern Z        zdiv();
extern B        zeq();
extern Z        zexp();
extern Z        zfloor();
extern Z        zgcd();
extern Z        zlcm();
extern Z        zlog();
extern D        zmag();
extern Z        zminus();
extern Z        znonce1();
extern Z        znonce2();
extern Z        zplus();
extern Z        zpow();
extern Z        zrem();
extern Z        zsqrt();
extern Z        ztymes();
extern Z        ztrend();

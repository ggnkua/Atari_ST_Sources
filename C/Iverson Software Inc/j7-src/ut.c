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
/* Tolerant and Fuzzy Comparisons                                          */

#include "j.h"


B teq(u,v)D u,v;{D x;
 if(u==v)R 1;
 if(0<u!=0<v)R 0;
 x=0<u?MAX(u,v):-MIN(u,v);
 R x==inf ? u==v : ABS(u-v)<=qct*x;
}

B tlt(u,v)D u,v;{R u< v&&!teq(u,v);}

B tle(u,v)D u,v;{R u<=v|| teq(u,v);}

D tfloor(v)D v;{D x=floor(0.5+v); R x-!tle(x,v);}

D tceil(v) D v;{D x=floor(0.5+v); R x+ tlt(x,v);}


B feq(u,v) D u,v;{R ABS(u-v)<=qfuzz*MAX(ABS(u),ABS(v));}

B freal(v)Z v;{R ABS(v.im)<=qfuzz*ABS(v.re);}


/* See  R. Bernecky, Comparison Tolerance, SATN-23, IPSA, 1977-06-10       */
/* For finite numbers, the following defns hold:                           */
/*   teq(u,v)   ABS(u-v)<=qct*MAX(ABS(u),ABS(v))                           */
/*   tne(u,v)   !teq(u,v)                                                  */
/*   tlt(u,v)   (u< v)&&tne(u,v)                                           */
/*   tle(u,v)   (u<=v)||teq(u,v)                                           */
/*   tge(u,v)   (u>=v)||teq(u,v)                                           */
/*   tgt(u,v)   (u> v)&&tne(u,v)                                           */
/*   tfloor(v)  x=floor(0.5+v), x-tgt(x,v)                                 */
/*   tceil(v)   x=floor(0.5+v), x+tlt(x,v)                                 */

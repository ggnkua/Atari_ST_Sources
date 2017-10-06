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
/* LinkJ Example                                                           */

#include <stdio.h>
#include <string.h>
#include "lj.h"


#if LINKJ

/* nelm() implements   10!:0 y; the number of elements of array y.         */
/* ntr()  implements x 10!:0 y; the first x elements of integer array y.   */

static F1(nelm){A z;
 RZ(z=jma(INT,1L,0L));          /* allocate space for result               */
 *AV(z)=AN(y);                  /* set the single value of result          */
 R z;
}

static F2(ntr){A z;I n;
 ASSERT(0==AR(x),EVRANK);       /* x must be scalar                        */
 ASSERT(INT&AT(x),EVDOMAIN);    /* x must be integral                      */
 ASSERT(INT&AT(y),EVDOMAIN);    /* y must be integral                      */
 n=*AV(x);                      /* value of x                              */
 ASSERT(n<=AN(y),EVLENGTH);     /* x<#,y                                   */
 RZ(z=jma(INT,n,1L));           /* allocate space for result               */
 *AS(z)=n;                      /* the shape of z                          */
 memcpy(AV(z),AV(y),4*n);       /* copy into result, 4 bytes per element   */
 R z;
}

C jc(k,f1,f2)I k;AF*f1,*f2;{
 switch(k){
  case 0:
   *f1=nelm;                    /* monad of 10!:0                          */
   *f2=ntr;                     /* dyad  of 10!:0                          */
   R 1;                         /* indicate no error                       */
  default:
   ASSERT(0,EVNONCE);           /* 10!:k where k is not 0. error for now.  */
}}

main(){A t;C s[456];
 jinit();
 while(1){
  printf("   ");
  if(NULL==gets(s)||'\004'==*(s+strlen(s)-1))exit(0);
  t=jx(s);
  if(jerr)printf("jerr: %d\n",jerr); else if(!asgn)jpr(t);
}}

#endif

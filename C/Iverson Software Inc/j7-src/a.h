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
/* Macros and Defined-Constants for Adverbs & Conjunctions                 */


#define GAPPEND         0L
#define GINSERT         3L
#define GTRAIN          6L

#define CONJCASE(a,w)   (2*!(VERB&AT(a))+!(VERB&AT(w)))
#define NN              3               /* NOUN NOUN                       */
#define NV              2               /* NOUN VERB                       */
#define VN              1               /* VERB NOUN                       */
#define VV              0               /* VERB VERB                       */

#define DECLF           V*sv=VAV(self);A fs=sv->f;                   \
                        AF f1=fs?VAV(fs)->f1:0,f2=fs?VAV(fs)->f2:0

#define DECLFG          V*sv=VAV(self);A fs=sv->f,gs=sv->g;          \
                        AF f1=fs?VAV(fs)->f1:0,f2=fs?VAV(fs)->f2:0,  \
                           g1=gs?VAV(gs)->f1:0,g2=gs?VAV(gs)->f2:0

#define PREF1(f)        {I m=mr(self);            F1RANK(  m,f,self);}
#define PREF2(f)        {I l=lr(self),r=rr(self); F2RANK(l,r,f,self);}

#define AS1(f,exp)      DF1(f){PROLOG;DECLF ;A z; PREF1(f); z=(exp); EPILOG(z);}
#define AS2(f,exp)      DF2(f){PROLOG;DECLF ;A z; PREF2(f); z=(exp); EPILOG(z);}
#define CS1(f,exp)      DF1(f){PROLOG;DECLFG;A z; PREF1(f); z=(exp); EPILOG(z);}
#define CS2(f,exp)      DF2(f){PROLOG;DECLFG;A z; PREF2(f); z=(exp); EPILOG(z);}

#define ADERIV(id,f1,f2,m,l,r)  fdef(id,VERB,f1,f2,w,0L,0L,0L,m,l,r)
#define CDERIV(id,f1,f2,m,l,r)  fdef(id,VERB,f1,f2,a,w ,0L,0L,m,l,r)

#define SCALARFN(id,w)  (id==ID(w)&&!lr(w)&&!rr(w))


extern A        fdef();
extern A        gadv();
extern A        gconj();
extern A        gtrain();
extern B        nameless();
extern A        vtrans();
extern A        xtrans();

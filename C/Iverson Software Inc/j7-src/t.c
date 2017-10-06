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
/* Tables: primitive symbols and character types                           */

#include "j.h"

P ps[]={
/*   0 00             */ {0,    0,         0,        0,    0,    0,    0      },
/*  33 21 !  CBANG    */ {VERB, fact,      outof,    RMAX, 0,    0,    0      },
/*  34 22    CQQ      */ {CONJ, 0,         qq,       0,    0,    0,    0      },
/*  35 23 #  CPOUND   */ {VERB, tally,     repeat,   RMAX, 1,    RMAX, 0      },
/*  36 24 $  CDOLLAR  */ {VERB, shape,     reitem,   RMAX, 1,    RMAX, 0      },
/*  37 25 %  CDIV     */ {VERB, recip,     divide,   RMAX, 0,    0,    CDIV   },
/*  38 26 &  CAMP     */ {CONJ, 0,         amp,      0,    0,    0,    0      },
/*  40 28 (  CLPAR    */ {LPAR, 0,         0,        0,    0,    0,    0      },
/*  41 29 )  CRPAR    */ {RPAR, 0,         0,        0,    0,    0,    0      },
/*  42 2a *  CSTAR    */ {VERB, signum,    tymes,    RMAX, 0,    0,    0      },
/*  43 2b +  CPLUS    */ {VERB, conjug,    plus,     RMAX, 0,    0,    CPLUS  },
/*  44 2c ,  CCOMMA   */ {VERB, ravel,     over,     RMAX, RMAX, RMAX, 0      },
/*  45 2d -  CMINUS   */ {VERB, negate,    minus,    RMAX, 0,    0,    CMINUS },
/*  46 2e .  CDOT     */ {CONJ, 0,         dot,      0,    0,    0,    0      },
/*  47 2f /  CSLASH   */ {ADV,  slash,     0,        0,    0,    0,    0      },
/*  58 3a :  CCOLON   */ {CONJ, 0,         colon,    0,    0,    0,    0      },
/*  59 3b ;  CSEMICO  */ {VERB, raze,      link,     RMAX, RMAX, RMAX, 0      },
/*  60 3c <  CLT      */ {VERB, box,       lt,       RMAX, 0,    0,    COPE   },
/*  61 3d =  CEQ      */ {VERB, sclass,    eq,       RMAX, 0,    0,    0      },
/*  62 3e >  CGT      */ {VERB, ope,       gt,       0,    0,    0,    CBOX   },
/*  63 3f ?  CQUERY   */ {VERB, roll,      deal,     RMAX, 0,    0,    0      },
/*  64 40 @  CAT      */ {CONJ, 0,         atop,     0,    0,    0,    0      },
/*  91 5b [  CLEFT    */ {VERB, left1,     left2,    RMAX, RMAX, RMAX, CLEFT  },
/*  92 5c \  CBSLASH  */ {ADV,  bslash,    0,        0,    0,    0,    0      },
/*  93 5d ]  CRIGHT   */ {VERB, right1,    right2,   RMAX, RMAX, RMAX, CRIGHT },
/*  94 5e ^  CEXP     */ {VERB, expn1,     expn2,    RMAX, 0,    0,    CLOG   },
/*  96 60 `  CGRAVE   */ {CONJ, 0,         tie,      0,    0,    0,    0      },
/* 123 7b {  CLBRACE  */ {VERB, catalog,   from,     1,    0,    RMAX, 0      },
/* 124 7c |  CSTILE   */ {VERB, mag,       residue,  RMAX, 0,    0,    0      },
/* 125 7d }  CRBRACE  */ {ADV,  rbrace,    0,        0,    0,    0,    0      },
/* 126 7e ~  CTILDE   */ {ADV,  swap,      0,        0,    0,    0,    0      },
/* 128 80 =. CASGN    */ {ASGN, 0,         0,        0,    0,    0,    0      },
/* 129 81 =: CGASGN   */ {ASGN, 0,         0,        0,    0,    0,    0      },
/* 130 82 <. CMIN     */ {VERB, floor1,    minimum,  RMAX, 0,    0,    0      },
/* 131 83 <: CLE      */ {VERB, decrem,    le,       RMAX, 0,    0,    CGE    },
/* 132 84 >. CMAX     */ {VERB, ceil1,     maximum,  RMAX, 0,    0,    0      },
/* 133 85 >: CGE      */ {VERB, increm,    ge,       RMAX, 0,    0,    CLE    },
/* 135 87 _: CUSCO    */ {VERB, num1,      num2,     RMAX, RMAX, RMAX, 0      },
/* 136 88 +. COR      */ {VERB, rect,      gcd,      RMAX, 0,    0,    0      },
/* 137 89 +: CNOR     */ {VERB, duble,     nor,      RMAX, 0,    0,    CHALVE },
/* 138 8a *. CAND     */ {VERB, polar,     lcm,      RMAX, 0,    0,    0      },
/* 139 8b *: CNAND    */ {VERB, square,    nand,     RMAX, 0,    0,    CSQRT  },
/* 140 8c -. CNOT     */ {VERB, not,       less,     RMAX, RMAX, RMAX, CNOT   },
/* 141 8d -: CMATCH   */ {VERB, halve,     match,    RMAX, RMAX, RMAX, CDOUBLE},
/* 142 8e %. CDOMINO  */ {VERB, minv,      mdiv,     2,    RMAX, 2,    CDOMINO},
/* 143 8f %: CROOT    */ {VERB, sqroot,    root,     RMAX, 0,    0,    CSQUARE},
/* 144 90 ^. CLOG     */ {VERB, logar1,    logar2,   RMAX, 0,    0,    CEXP   },
/* 145 91 ^: CPOWOP   */ {CONJ, 0,         powop,    0,    0,    0,    0      },
/* 146 92 $. CGOTO    */ {NAME, 0,         0,        0,    0,    0,    0      },
/* 147 93 $: CSELF    */ {VERB, self1,     self2,    RMAX, RMAX, RMAX, 0      },
/* 148 94 ~. CNUB     */ {VERB, nub,       0,        RMAX, 0,    0,    0      },
/* 149 95 ~: CNE      */ {VERB, nubsieve,  ne,       RMAX, 0,    0,    0      },
/* 150 96 |. CREV     */ {VERB, reverse,   rotate,   RMAX, 0,    RMAX, CREV   },
/* 151 97 |: CCANT    */ {VERB, cant1,     cant2,    RMAX, 1,    RMAX, CCANT  },
/* 152 98 .. CDOTDOT  */ {CONJ, 0,         even,     0,    0,    0,    0      },
/* 153 99 .: CDOTCO   */ {CONJ, 0,         odd,      0,    0,    0,    0      },
/* 154 9a :. COBVERSE */ {CONJ, 0,         obverse,  0,    0,    0,    0      },
/* 155 9b :: CADVERSE */ {CONJ, 0,         adverse,  0,    0,    0,    0      },
/* 156 9c ,. CCOMDOT  */ {VERB, table,     overr,    RMAX, RMAX, RMAX, 0      },
/* 157 9d ,: CLAMIN   */ {VERB, lamin1,    lamin2,   RMAX, RMAX, RMAX, CHEAD  },
/* 158 9e ;. CCUT     */ {CONJ, 0,         cut,      0,    0,    0,    0      },
/* 159 9f ;: CWORDS   */ {VERB, words,     0,        1,    0,    0,    0      },
/* 160 a0 #. CBASE    */ {VERB, base1,     base2,    1,    1,    1,    CABASE },
/* 161 a1 #: CABASE   */ {VERB, abase1,    abase2,   RMAX, 1,    0,    CBASE  },
/* 162 a2 @. CATDOT   */ {CONJ, 0,         agenda,   0,    0,    0,    0      },
/* 163 a3 @: CATCO    */ {CONJ, 0,         atco,     0,    0,    0,    0      },
/* 164 a4 /. CSLDOT   */ {ADV,  sldot,     0,        0,    0,    0,    0      },
/* 165 a5 /: CGRADE   */ {VERB, grade1,    grade2,   RMAX, RMAX, RMAX, CGRADE },
/* 166 a6 \. CBSDOT   */ {ADV,  bsdot,     0,        0,    0,    0,    0      },
/* 167 a7 \: CDGRADE  */ {VERB, dgrade1,   dgrade2,  RMAX, RMAX, RMAX, 0      },
/* 168 a8 [. CLEV     */ {CONJ, 0,         lev,      0,    0,    0,    0      },
/* 169 a9 [: CLBKCO   */ {VERB, 0,         0,        RMAX, RMAX, RMAX, 0      },
/* 170 aa ]. CDEX     */ {CONJ, 0,         dex,      0,    0,    0,    0      },
/* 172 ac {. CTAKE    */ {VERB, head,      take,     RMAX, 1,    RMAX, CLAMIN },
/* 173 ad {: CTAIL    */ {VERB, tail,      0,        RMAX, 0,    0,    0      },
/* 174 ae }. CDROP    */ {VERB, behead,    drop,     RMAX, 1,    RMAX, 0      },
/* 175 af }: CCTAIL   */ {VERB, curtail,   0,        RMAX, 0,    0,    0      },
/* 177 b1 `: CGRCO    */ {CONJ, 0,         evger,    0,    0,    0,    0      },
/* 178 b2 ". CEXEC    */ {VERB, exec1,     exec2,    1,    1,    1,    CTHORN },
/* 179 b3 ": CTHORN   */ {VERB, thorn1,    thorn2,   RMAX, 1,    1,    CEXEC  },
/* 180 b4 &. CUNDER   */ {CONJ, 0,         under,    0,    0,    0,    0      },
/* 181 b5 &: CAMPCO   */ {CONJ, 0,         ampco,    0,    0,    0,    0      },
/* 182 b6 !. CFIT     */ {CONJ, 0,         fit,      0,    0,    0,    0      },
/* 183 b7 !: CIBEAM   */ {CONJ, 0,         foreign,  0,    0,    0,    0      },
/* 192 c0 a. CALP     */ {NOUN, 0,         0,        0,    0,    0,    0      },
/* 193 c1 A. CATOMIC  */ {VERB, adot1,     adot2,    1,    0,    RMAX, 0      },
/* 194 c2 b. CBOOL    */ {ADV,  bool,      0,        0,    0,    0,    0      },
/* 195 c3 c. CEIGEN   */ {VERB, eig1,      eig2,     2,    0,    2,    0      },
/* 196 c4 C. CCYCLE   */ {VERB, cdot1,     cdot2,    1,    1,    RMAX, CCYCLE },
/* 197 c5 D. CDDOT    */ {CONJ, 0,         ddot,     0,    0,    0,    0      },
/* 198 c6 e. CEPS     */ {VERB, razein,    eps,      RMAX, RMAX, RMAX, 0      },
/* 199 c7 E. CEBAR    */ {VERB, 0,         ebar,     0,    RMAX, RMAX, 0      },
/* 200 c8 f. CFIX     */ {ADV,  fix,       0,        0,    0,    0,    0      },
/* 201 c9 i. CIOTA    */ {VERB, iota,      indexof,  1,    RMAX, RMAX, 0      },
/* 202 ca j. CJDOT    */ {VERB, jdot1,     jdot2,    RMAX, 0,    0,    0      },
/* 203 cb o. CCIRCLE  */ {VERB, pix,       circle,   RMAX, 0,    0,    0      },
/* 204 cc p. CPOLY    */ {VERB, poly1,     poly2,    1,    1,    0,    CPOLY  },
/* 205 cd r. CRDOT    */ {VERB, rdot1,     rdot2,    RMAX, 0,    0,    0      },
/* 206 ce s. CTEXT    */ {ADV,  0,         0,        0,    0,    0,    0      },
/* 207 cf t. CTAYLOR  */ {ADV,  taylor,    0,        0,    0,    0,    0      },
/* 208 d0 T. CTAYN    */ {CONJ, 0,         tayn,     0,    0,    0,    0      },
/* 209 d1 x. CALPHA   */ {NAME, 0,         0,        0,    0,    0,    0      },
/* 210 d2 y. COMEGA   */ {NAME, 0,         0,        0,    0,    0,    0      },

/* 224 e0 0: CZERO    */         /* same as 135 87 _: */
/* 225 e1 1: CONE     */         /* same as 135 87 _: */
/* 226 e2 2: CTWO     */         /* same as 135 87 _: */
/* 227 e3 3: CTHREE   */         /* same as 135 87 _: */
/* 228 e4 4: CFOUR    */         /* same as 135 87 _: */
/* 229 e5 5: CFIVE    */         /* same as 135 87 _: */
/* 230 e6 6: CSIX     */         /* same as 135 87 _: */
/* 231 e7 7: CSEVEN   */         /* same as 135 87 _: */
/* 232 e8 8: CEIGHT   */         /* same as 135 87 _: */
/* 233 e9 9: CNINE    */         /* same as 135 87 _: */
};

UC psptr[256]={
  0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 0 */
  0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 1 */
  0,  1,  2,  3,  4,  5,  6,  0,    7,  8,  9, 10, 11, 12, 13, 14, /* 2 */
  0,  0,  0,  0,  0,  0,  0,  0,    0,  0, 15, 16, 17, 18, 19, 20, /* 3 */
 21,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 4 */
  0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0, 22, 23, 24, 25,  0, /* 5 */
 26,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* 6 */
  0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0, 27, 28, 29, 30,  0, /* 7 */
 31, 32, 33, 34, 35, 36,  0, 37,   38, 39, 40, 41, 42, 43, 44, 45, /* 8 */
 46, 47, 48, 49, 50, 51, 52, 53,   54, 55, 56, 57, 58, 59, 60, 61, /* 9 */
 62, 63, 64, 65, 66, 67, 68, 69,   70, 71, 72,  0, 73, 74, 75, 76, /* a */
  0, 77, 78, 79, 80, 81, 82, 83,    0,  0,  0,  0,  0,  0,  0,  0, /* b */
 84, 85, 86, 87, 88, 89, 90, 91,   92, 93, 94, 95, 96, 97, 98, 99, /* c */
100,101,102,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* d */
 37, 37, 37, 37, 37, 37, 37, 37,   37, 37,  0,  0,  0,  0,  0,  0, /* e */
  0,  0,  0,  0,  0,  0,  0,  0,    0,  0,  0,  0,  0,  0,  0,  0, /* f */
};
/*    1   2   3   4   5   6   7     8   9   a   b   c   d   e   f   */


C ctype[256]={
 0,  0,  0,  0,  0,  0,  0,  0,  0, CS,  0,  0,  0,  0,  0,  0, /* 0                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* 1                  */
CS,  0,  0,  0,  0,  0,  0, CQ,  0,  0,  0,  0,  0,  0, CD,  0, /* 2  !"#$%&'()*+,-./ */
C9, C9, C9, C9, C9, C9, C9, C9, C9, C9, CC,  0,  0,  0,  0,  0, /* 3 0123456789:;<=>? */
 0, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, /* 4 @ABCDEFGHIJKLMNO */
CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA,  0,  0,  0,  0, C9, /* 5 PQRSTUVWXYZ[\]^_ */
 0, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, /* 6 `abcdefghijklmno */
CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA,  0,  0,  0,  0,  0, /* 7 pqrstuvwxyz{|}~  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* 8                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* 9                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* a                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* b                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* c                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* d                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* e                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* f                  */
};
/*   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f   */

C wtype[256]={
 0,  0,  0,  0,  0,  0,  0,  0,  0, CS,  0,  0,  0,  0,  0,  0, /* 0                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* 1                  */
CS,  0,  0,  0,  0,  0,  0, CQ,  0,  0,  0,  0,  0,  0, CD,  0, /* 2  !"#$%&'()*+,-./ */
C9, C9, C9, C9, C9, C9, C9, C9, C9, C9, CC,  0,  0,  0,  0,  0, /* 3 0123456789:;<=>? */
 0, CA, CB, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CN, CA, /* 4 @ABCDEFGHIJKLMNO */
CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA,  0,  0,  0,  0, C9, /* 5 PQRSTUVWXYZ[\]^_ */
 0, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, /* 6 `abcdefghijklmno */
CA, CA, CA, CA, CA, CA, CA, CA, CA, CA, CA,  0,  0,  0,  0,  0, /* 7 pqrstuvwxyz{|}~  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* 8                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* 9                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* a                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* b                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* c                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* d                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* e                  */
 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, /* f                  */
};
/*   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f   */

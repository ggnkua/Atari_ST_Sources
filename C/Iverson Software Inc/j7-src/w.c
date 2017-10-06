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
/* Spelling and Word Formation                                             */

#include "j.h"
#include "d.h"


#define SS              0    /* space                           */
#define SX              1    /* base                            */
#define SA              2    /* alphanumeric                    */
#define SN              3    /* N                               */
#define SNB             4    /* NB                              */
#define SNZ             5    /* NB.                             */
#define S9              6    /* numeric                         */
#define SQ              7    /* quote                           */
#define SQQ             8    /* even quotes                     */
#define SZ              9    /* trailing comment                */

#define EI              1    /* emit (b,i-1); b=.i              */
#define EN              2    /* b=.i                            */

typedef struct {C new,effect;} ST;

static ST state[10][9]={
/*SS */ {{SX,EN},{SS,0 },{SA,EN},{SN,EN},{SA,EN},{S9,EN},{SX,EN},{SX,EN},{SQ,EN}},
/*SX */ {{SX,EI},{SS,EI},{SA,EI},{SN,EI},{SA,EI},{S9,EI},{SX,0 },{SX,0 },{SQ,EI}},
/*SA */ {{SX,EI},{SS,EI},{SA,0 },{SA,0 },{SA,0 },{SA,0 },{SX,0 },{SX,0 },{SQ,EI}},
/*SN */ {{SX,EI},{SS,EI},{SA,0 },{SA,0 },{SNB,0},{SA,0 },{SX,0 },{SX,0 },{SQ,EI}},
/*SNB*/ {{SX,EI},{SS,EI},{SA,0 },{SA,0 },{SA,0 },{SA,0 },{SNZ,0},{SX,0 },{SQ,EI}},
/*SNZ*/ {{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SX,0 },{SX,0 },{SZ,0 }},
/*S9 */ {{SX,EI},{SS,EI},{S9,0 },{S9,0 },{S9,0 },{S9,0 },{S9,0 },{SX,0 },{SQ,EI}},
/*SQ */ {{SQ,0 },{SQ,0 },{SQ,0 },{SQ,0 },{SQ,0 },{SQ,0 },{SQ,0 },{SQ,0 },{SQQ,0}},
/*SQQ*/ {{SX,EI},{SS,EI},{SA,EI},{SN,EI},{SA,EI},{S9,EI},{SX,EI},{SX,EI},{SQ,0 }},
/*SZ */ {{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 },{SZ,0 }}
};
/*         CX      CS      CA      CN      CB      C9      CD      CC      CQ   */

static F1(wordil){A z;C e,nv,s,t;I b,i,m,n,*x,xb,xe;ST p;UC*v;
 RZ(w);
 nv=0; s=SS;
 n=AN(w); v=(UC*)AV(w); GA(z,INT,1+n+n,1,0); x=1+AV(z);
 for(i=0;i<n;++i){
  p=state[s][wtype[v[i]]]; e=p.effect;
  if(e==EI){
   t&=s==S9;
   if(t){if(!nv){nv=1; xb=b;} xe=i;}
   else{if(nv){nv=0; *x++=xb; *x++=xe-xb;} *x++=b; *x++=i-b;}
  }
  s=p.new;
  if(e){b=i; t=s==S9;}
 }
 if(s==SQ){jsignalx(EVOPENQ,w,-1L); debug(); R 0;}
 t&=s==S9;
 if(t){*x++=xb=nv?xb:b; *x++=n-xb;}
 else{if(nv){*x++=xb; *x++=xe-xb;} if(s!=SS){*x++=b; *x++=n-b;}}
 m=x-AV(z); *AV(z)=s==SZ||s==SNZ?-m/2:m/2;
 R z;
}

F1(words){A t,*x,z;C*s;I k,n,*y;
 F1RANK(1,words,0);
 ASSERT(CHAR&AT(w)||!AN(w),EVDOMAIN);
 RZ(t=wordil(w));
 s=(C*)AV(w); y=AV(t); n=*y++; n=0>n?-n:n;
 GA(z,BOX,n,1,0); x=(A*)AV(z);
 DO(n, k=*y++; *x++=str(*y++,s+k););
 R z;
}


static A conname(n,s)I n;C*s;{A z;
 ASSERT(vnm(n,s),EVILNAME);
 GA(z,NAME,n,1,0); MC(AV(z),s,n);
 R z;
}

static A constr(n,s)I n;C*s;{A z;C b,c,p,*t,*x;I m=0;
 p=0; t=s; DO(n-2, c=*++t; b=c==CQUOTE; if(!b||p)m++;    p=b&&!p;);
 GA(z,CHAR,m,1!=m,0); x=(C*)AV(z);
 p=0; t=s; DO(n-2, c=*++t; b=c==CQUOTE; if(!b||p)*x++=c; p=b&&!p;);
 R z;
}

static F2(enstack){A t,*x,z;C c,d,e,p,*s,*wi;I i,n,*u,wl;
 RZ(a&&w);
 s=(C*)AV(w); u=AV(a); n=*u++; n=0>n?-(1+n):n;
 GA(z,BOX,5+n,1,0); x=(A*)AV(z); *x++=mark;
 for(i=0;i<n;i++){
  wi=s+*u++; wl=*u++;
  c=e=*wi; p=ctype[c];
  if(1<wl){
   d=*(wi+wl-1);
   if(p!=C9&&d==CESC1||p!=CA&&d==CESC2) e=spellin(wl,wi);
  }
  if(!e||127<(UC)c){jsignalx(EVSPELL,w,wi-s); debug(); R 0;}
  RZ(t=ds(e));
  if(AT(t)&MARK)switch(p){
   case CA: RZ(*x++=conname(wl,wi)); break;
   case CS:
   case C9: RZ(*x++=connum(wl,wi));  break;
   case CQ: RZ(*x++=constr(wl,wi));  break;
   default: ASSERT(0,EVDOMAIN);
  } else *x++=t;
 }
 *x++=mark; *x++=mark; *x++=mark; *x++=mark;
 R z;
}

F1(tokens){R enstack(wordil(w),w);}


static C spell[3][59]={
 '=',     '<',     '>',     '_',     '+',     '*',     '-',     '%',
 '^',     '$',     '~',     '|',     '.',     ':',     ',',     ';',
 '#',     '@',     '/',     CBSLASH, '[',     ']',     '{',     '}',
 '`',     CQQ,     '&',     '!',     '?',     'a',     'A',     'b',
 'c',     'C',     'D',     'e',     'E',     'f',     'i',     'j',
 'o',     'p',     'r',     's',     't',     'T',     'x',     'y',     
 '0',     '1',     '2',     '3',     '4',     '5',     '6',     '7',
 '8',     '9',     0,

 CASGN,   CFLOOR,  CCEIL,   1,       COR,     CAND,    CNOT,    CDOMINO,
 CLOG,    CGOTO,   CNUB,    CREV,    CDOTDOT, COBVERSE,CCOMDOT, CCUT,
 CBASE,   CATDOT,  CSLDOT,  CBSDOT,  CLEV,    CDEX,    CTAKE,   CDROP,
 CGRDOT,  CEXEC,   CUNDER,  CFIT,    CQRYDOT, CALP,    CATOMIC, CBOOL,
 CEIGEN,  CCYCLE,  CDDOT,   CEPS,    CEBAR,   CFIX,    CIOTA,   CJDOT,
 CCIRCLE, CPOLY,   CRDOT,   CTEXT,   CTAYLOR, CTAYN,   CALPHA,  COMEGA,  
 1,       1,       1,       1,       1,       1,       1,       1,
 1,       1,       0,

 CGASGN,  CLE,     CGE,     CUSCO,   CNOR,    CNAND,   CMATCH,  CROOT,
 CPOWOP,  CSELF,   CNE,     CCANT,   CDOTCO,  CADVERSE,CLAMIN,  CWORDS,
 CABASE,  CATCO,   CGRADE,  CDGRADE, CLBKCO,  CRBKCO,  CTAIL,   CCTAIL,
 CGRCO,   CTHORN,  CAMPCO,  CIBEAM,  CQRYCO,  1,       1,       1,
 1,       1,       1,       1,       1,       1,       1,       1,
 1,       1,       1,       1,       1,       1,       1,       1,
 CZERO,   CONE,    CTWO,    CTHREE,  CFOUR,   CFIVE,   CSIX,    CSEVEN,  
 CEIGHT,  CNINE,   0,
};

static C nu[12][5]={
 'A','T',  CAT,     CATDOT,  CATCO,
 'B','S',  CBSLASH, CBSDOT,  CDGRADE,
 'C','A',  CEXP,    CLOG,    CPOWOP,
 'G','R',  CGRAVE,  CGRDOT,  CGRCO,
 'L','B',  CLEFT,   CLEV,    CLBKCO,
 'L','C',  CLBRACE, CTAKE,   CTAIL,
 'N','O',  CPOUND,  CBASE,   CABASE,
 'R','B',  CRIGHT,  CDEX,    CRBKCO,
 'R','C',  CRBRACE, CDROP,   CCTAIL,
 'S','H',  CDOLLAR, CGOTO,   CSELF,
 'S','T',  CSTILE,  CREV,    CCANT,
 'T','I',  CTILDE,  CNUB,    CNE,
};

C spellin(n,s)I n;C*s;{C d,p,q,*t;I j,k;
 switch(n){
  case 1:
   R *s;
  case 2:
   d=*(s+1); j=d==CESC1?1:d==CESC2?2:0;
   R j&&(t=(C*)strchr(spell[0],*s)) ? spell[j][k=t-spell[0],k] : 0;
   /* k is workaround for TurboC bug */
  case 3:
  case 4:
   if(CESC1!=*(s+n-1))R 0;
   p=*s; q=*(1+s); d=*(2+s); j=CESC1==d?2:d=='1'?3:d=='2'?4:0;
   if(j)DO(12, if(p==nu[i][0]&&q==nu[i][1])R nu[i][j];);
  default:
   R 0;
}}

void spellit(c,s)C c,*s;{C*q;I k;
 s[1]=0;
 switch(c){
  case CHOOK:  s[0]='2'; break;
  case CFORK:  s[0]='3'; break;
  case CADVF:  s[0]='4'; break;
  case CHOOKO: s[0]='5'; break;
  case CFORKO: s[0]='6'; break;
  default:
   if(0<=c&&c<=127) s[0]=c;
   else if(q=(C*)strchr(spell[1],c)){k=q-spell[1]; s[0]=spell[0][k]; s[1]=CESC1;}
   else if(q=(C*)strchr(spell[2],c)){k=q-spell[2]; s[0]=spell[0][k]; s[1]=CESC2;}
}}   /* spell out ID c in s */

A spellout(c)C c;{C s[2]; spellit(c,s); R str(s[1]?2L:1L,s);}

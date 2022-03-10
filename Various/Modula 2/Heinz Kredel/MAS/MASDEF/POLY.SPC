

(* ---------- integer recursive polynomial unit --- *)

SPECIFICATION IPOL;
(*Integer recursive polynomial specification. *)
(*1*) SORT ipol, pol, dip, atom;
(*2*) SIGNATURE IPzero ()                : ipol;
      SIGNATURE IPSUM  (atom,ipol,ipol)  : ipol;            
      SIGNATURE IPNEG  (atom,ipol)       : ipol;
      SIGNATURE IPDIF  (atom,ipol,ipol)  : ipol;
(*3*) SIGNATURE IPPROD (atom,ipol,ipol)  : ipol;
      SIGNATURE IPEXP  (atom,ipol,ipol)  : ipol;
(*4*) SIGNATURE PFDIP  (dip,atom,pol)    ;
(*9*) END IPOL.


IMPLEMENTATION IPOL;
(*2*) PROCEDURE IPzero();
      BEGIN RETURN(0) END IPzero;
(*2*) PROCEDURE IPDIF(r,a,b);
      BEGIN RETURN(IPSUM(r,a,IPNEG(r,b))) END IPDIF;
(*9*) END IPOL.


MODEL RING;
(*Integer recursive polynomial are a model for rings. *)
(*1*) IMPORT IPOL;
(*2*) MAP ZERO(ipol)      -> IPzero();
      MAP SUM(ipol,ipol)  -> IPSUM(DESC,VAL,VAL)  WHEN EQ(DESC,DESC);
      MAP NEG(ipol)       -> IPNEG(DESC,VAL);
      MAP DIF(ipol,ipol)  -> IPDIF(DESC,VAL,VAL)  WHEN EQ(DESC,DESC);
(*3*) MAP PROD(ipol,ipol) -> IPPROD(DESC,VAL,VAL) WHEN EQ(DESC,DESC);
      MAP EXP(ipol,atom)  -> IPEXP(DESC,VAL,VAL);
(*9*) END RING.


(* ---------- distributive rational polynomial unit --- *)

SPECIFICATION DIRP;
(*Distributive rational polynomial specification. *)
(*1*) SORT dip, dirp, diip, pol, atom;
(*2*) SIGNATURE DIRPSM (dirp,dirp)         : dirp;            
      SIGNATURE DIRPNG (dirp)              : dirp;
      SIGNATURE DIRPDF (dirp,dirp)         : dirp;
(*3*) SIGNATURE DIRPPR (dirp,dirp)         : dirp;
(*4*) SIGNATURE DIPFP  (atom,pol)          : dip;
(*6*) SIGNATURE DIIFRP (dirp)              : diip;
      SIGNATURE DIRFIP (diip)              : dirp;
(*9*) END DIRP.


IMPLEMENTATION DIRP;
(*2*) PROCEDURE DIRPDF(a,b);
      BEGIN RETURN(DIRPSM(a,DIRPNG(b))) END DIRPDF;
(*9*) END DIRP.


MODEL RING;
(*Distributive rational polynomial are a model for rings. *)
(*1*) IMPORT DIRP;
(*2*) MAP SUM(dirp,dirp)  -> DIRPSM(VAL,VAL);
      MAP NEG(dirp)       -> DIRPNG(VAL);
      MAP DIF(dirp,dirp)  -> DIRPDF(VAL,VAL);
(*4*) MAP PROD(dirp,dirp) -> DIRPPR(VAL,VAL);
      MAP EXP(dirp,dirp)  -> DIRPEX(VAL,VAL);
(*9*) END RING.


(* ---------- distributive rational polynomial list unit --- *)

SPECIFICATION DIRL;
(*Distributive rational polynomial list specification. *)
(*1*) SORT dip, dirp, diip, pol, atom, dc;
(*2*) SIGNATURE PDREAD  ()          : dc;            
      SIGNATURE PDWRITE (dc)        ;            
(*3*) SIGNATURE DIRLRD  ()          : dirl;            
      SIGNATURE DIRLWR  (dirl)      ;            
      SIGNATURE PREADD  (dc)        : dirl;            
      SIGNATURE PWRITED (dirl)      ;            
(*4*) SIGNATURE DIILFR  (dirl)      : diil;            
(*5*) SIGNATURE DIRPNF  (dirl,dirp) : dirp;            
      SIGNATURE DIRPGB  (dirl,atom) : dirl;            
      SIGNATURE DIRPGB1 (dirl)      : dirl;            
      SIGNATURE DIRLIS  (dirl)      : dirl;            
(*6*) SIGNATURE SetTflag(atom)      ;            
(*9*) END DIRL.


IMPLEMENTATION DIRL;
(*Distributive rational polynomial list implementation. *)
      VAR s: atom;
(*2*) PROCEDURE DIRPGB1(a) : dirl;
      BEGIN RETURN(DIRPGB(a,s)) END DIRPGB1;            
(*3*) PROCEDURE SetTflag(a);
      BEGIN s:=a END SetTflag;            
(*4*) BEGIN 
            s:=1;      
(*9*) END DIRL.


MODEL OBJECT;
(*Distributive rational polynomial lists are a model for objects. *)
(*1*) IMPORT DIRL;
(*2*) MAP DECREAD(dirl)   -> PDREAD();
      MAP DECWRITE(dirl)  -> PDWRITE(VAL);
(*3*) MAP READ(dirl)      -> PREADD(DESC);
      MAP WRITE(dirl)     -> PWRITED(DESC,VAL);
(*9*) END OBJECT.


(* ---------- gb structure unit --- *)

MODEL GBRING;
(*Distributive rational polynomial lists are a model for 
Groebner base rings. *)
      IMPORT DIRL;
(*2*) MAP NF(dirl,dirp) -> DIRPNF(VAL,VAL);
      MAP GB(dirl)      -> DIRPGB1(VAL);
      MAP IRR(dirl)     -> DIRLIS(VAL);
(*9*) END GBRING.


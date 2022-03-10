

(* ---------- integer unit --- *)

SPECIFICATION INTEGER;
(*Integral numbers specification. *)
(*1*) SORT INT;
(*2*) SIGNATURE IWRITE (INT)             ;
      SIGNATURE IREAD  (INT)             : INT;
(*3*) SIGNATURE Ione   ()                : INT;
      SIGNATURE Izero  ()                : INT;
(*4*) SIGNATURE IPROD  (INT,INT)         : INT;
      SIGNATURE ISUM   (INT,INT)         : INT;            
      SIGNATURE IDIF   (INT,INT)         : INT;
      SIGNATURE INEG   (INT)             : INT;
      SIGNATURE IQR    (INT,INT,INT,INT) ;
      SIGNATURE IGCD   (INT,INT)         : INT;
(*9*) END INTEGER.


IMPLEMENTATION INTEGER;
(*1*) PROCEDURE Ione();
      BEGIN RETURN(1) END Ione;
(*2*) PROCEDURE Izero();
      BEGIN RETURN(0) END Izero;
(*9*) END INTEGER.


MODEL RING;
(*Integers are a model for rings. *)
(*1*) IMPORT INTEGER;
(*2*) MAP READ(INT)      -> IREAD(); 
      MAP WRITE(INT)     -> IWRITE(VAL);
(*3*) MAP ONE(INT)       -> Ione();
      MAP ZERO(INT)      -> Izero();
(*4*) MAP PROD(INT,INT)  -> IPROD(VAL,VAL);
      MAP SUM(INT,INT)   -> ISUM(VAL,VAL);
      MAP DIF(INT,INT)   -> IDIF(VAL,VAL);
      MAP NEG(INT)       -> INEG(VAL);
(*9*) END RING.


(* ---------- rational number unit --- *)

SPECIFICATION RATIONAL;
(*Rational numbers specification. *)
(*1*) SORT RAT, INT, atom;
(*2*) SIGNATURE RNWRITE (RAT)     ;
      SIGNATURE RNDRD   (RAT)     : RAT;
(*3*) SIGNATURE RNone   ()        : RAT;
      SIGNATURE RNzero  ()        : RAT;
(*4*) SIGNATURE RNPROD  (RAT,RAT) : RAT;
      SIGNATURE RNSUM   (RAT,RAT) : RAT;
      SIGNATURE RNDIF   (RAT,RAT) : RAT;
      SIGNATURE RNNEG   (RAT)     : RAT;
      SIGNATURE RNINV   (RAT)     : RAT;
      SIGNATURE RNQ     (RAT,RAT) : RAT;
(*5*) SIGNATURE RNINT   (INT)     : RAT;
      SIGNATURE RNprec  (atom)    ;
(*9*) END RATIONAL.


IMPLEMENTATION RATIONAL;
      VAR s: atom;
(*1*) PROCEDURE RNone();
      BEGIN RETURN(RNINT(1)) END RNone;
(*2*) PROCEDURE RNzero();
      BEGIN RETURN(RNINT(0)) END RNzero;
(*3*) PROCEDURE RNWRITE(a);
      BEGIN IF s < 0 THEN RNWRIT(a) ELSE RNDWR(a,s) END; 
            END RNWRITE;
(*4*) PROCEDURE RNprec(a);
      BEGIN s:=a END RNprec;
(*8*) BEGIN 
            s:=-1; 
(*9*) END RATIONAL.


MODEL FIELD;
(*Rational numbers are a model for fields. *)
(*1*) IMPORT RATIONAL;
(*2*) MAP READ(RAT)      -> RNDRD(); 
      MAP WRITE(RAT)     -> RNWRITE(VAL);
(*3*) MAP ONE(RAT)       -> RNone();
      MAP ZERO(RAT)      -> RNzero();
(*4*) MAP PROD(RAT,RAT)  -> RNPROD(VAL,VAL);
      MAP SUM(RAT,RAT)   -> RNSUM(VAL,VAL);
      MAP DIF(RAT,RAT)   -> RNDIF(VAL,VAL);
      MAP NEG(RAT)       -> RNNEG(VAL);
      MAP Q(RAT,RAT)     -> RNQ(VAL,VAL);
      MAP REZIP(RAT)     -> RNINV(VAL);
(*9*) END FIELD.


(* ---------- modular integer unit --- *)

SPECIFICATION MODINT;
(*Modular integers specification. *)
(*1*) SORT MI, INT, mod;
(*2*) SIGNATURE MIWRIT (MI)         ;
      SIGNATURE MIREAD (mod,MI)     : MI;
(*3*) SIGNATURE MIone  (mod)        : MI;
      SIGNATURE MIzero ()           : MI;
(*4*) SIGNATURE MIPROD (mod,MI,MI)  : MI;
      SIGNATURE MISUM  (mod,MI,MI)  : MI;
      SIGNATURE MIDIF  (mod,MI,MI)  : MI;
      SIGNATURE MINEG  (mod,MI)     : MI;
      SIGNATURE MIINV  (mod,MI)     : MI;
      SIGNATURE MIQ    (mod,MI,MI)  : MI;
(*5*) SIGNATURE MIHOM  (mod,INT)    : MI;
(*9*) END MODINT.


IMPLEMENTATION MODINT;
(*1*) PROCEDURE MIone(m);
      BEGIN RETURN(MIHOM(m,1)) END MIone;
(*2*) PROCEDURE MIzero();
      BEGIN RETURN(0) END MIzero;
(*3*) PROCEDURE MIREAD(m);
      BEGIN RETURN(MIHOM(m,IREAD())) END MIREAD;
(*4*) PROCEDURE MIWRIT(x);
      BEGIN IWRITE(x) END MIWRIT;
(*9*) END MODINT.


MODEL FIELD;
(*Integers mod p are a model for fields. *)
(*1*) IMPORT MODINT;
      IMPORT INTEGER;
(*2*) MAP READ(MI)      -> MIREAD(DESC); 
      MAP WRITE(MI)     -> MIWRIT(VAL);
      MAP DECREAD(MI)   -> IREAD(); 
      MAP DECWRITE(MI)  -> IWRITE(VAL);
(*3*) MAP ONE(MI)       -> MIone(DESC);
      MAP ZERO(MI)      -> MIzero();
(*4*) MAP PROD(MI,MI)   -> MIPROD(DESC,VAL,VAL) WHEN EQ(DESC,DESC);
      MAP SUM(MI,MI)    -> MISUM(DESC,VAL,VAL)  WHEN EQ(DESC,DESC);
      MAP DIF(MI,MI)    -> MIDIF(DESC,VAL,VAL)  WHEN EQ(DESC,DESC);
      MAP NEG(MI)       -> MINEG(DESC,VAL);
      MAP Q(MI,MI)      -> MIQ(DESC,VAL,VAL)    WHEN EQ(DESC,DESC);
      MAP REZIP(MI)     -> MIINV(DESC,VAL);
(*9*) END FIELD.


(* ---------- floating point number unit --- *)

SPECIFICATION FLOATING;
(*Floating point numbers specification. *)
(*1*) SORT FLOAT, INT, RAT, atom;
(*2*) SIGNATURE APWRIT (FLOAT)       ;
      SIGNATURE APREAD (FLOAT)       : FLOAT;
(*3*) SIGNATURE APone  ()            : FLOAT;
      SIGNATURE APzero ()            : FLOAT;
(*2*) SIGNATURE APPROD (FLOAT,FLOAT) : FLOAT;
      SIGNATURE APSUM  (FLOAT,FLOAT) : FLOAT;
      SIGNATURE APDIF  (FLOAT,FLOAT) : FLOAT;
      SIGNATURE APNEG  (FLOAT)       : FLOAT;
      SIGNATURE APINV  (FLOAT)       : FLOAT;
      SIGNATURE APQ    (FLOAT,FLOAT) : FLOAT;
(*5*) SIGNATURE APFINT (INT)         : FLOAT;
      SIGNATURE APFRN  (RAT)         : FLOAT;
      SIGNATURE RNFAP  (FLOAT)       : RAT;
      SIGNATURE APSPRE (atom)        ;
(*9*) END FLOATING.


IMPLEMENTATION FLOATING;
(*1*) PROCEDURE APone();
      BEGIN RETURN(APFINT(1)) END APone;
(*2*) PROCEDURE APzero();
      BEGIN RETURN(APFINT(0)) END APzero;
(*3*) PROCEDURE APDIF(a,b);
      BEGIN RETURN(APDIFF(a,b)) END APDIF;
(*4*) PROCEDURE APINV(a);
      BEGIN RETURN(APQ(APFINT(1),a)) END APINV;
(*9*) END FLOATING.


MODEL FIELD;
(*AP floating numbers are (nearly) a model for fields. *)
(*1*) IMPORT FLOATING;
(*2*) MAP READ(FLOAT)        -> APREAD(); 
      MAP WRITE(FLOAT)       -> APWRIT(VAL);
(*3*) MAP ONE(FLOAT)         -> APone();
      MAP ZERO(FLOAT)        -> APzero();
(*4*) MAP PROD(FLOAT,FLOAT)  -> APPROD(VAL,VAL);
      MAP SUM(FLOAT,FLOAT)   -> APSUM(VAL,VAL);
      MAP DIF(FLOAT,FLOAT)   -> APDIF(VAL,VAL);
      MAP NEG(FLOAT)         -> APNEG(VAL);
      MAP Q(FLOAT,FLOAT)     -> APQ(VAL,VAL);
      MAP REZIP(FLOAT)       -> APINV(VAL);
(*9*) END FIELD.



(* ---------- specifications of abstract items --- *)

SPECIFICATION OBJECT;
(*Object specification. *)
(*1*) SORT obj;
(*2*) SIGNATURE READ     (obj) : obj;
      SIGNATURE WRITE    (obj) ;
(*3*) SIGNATURE DECREAD  (obj) : obj;
      SIGNATURE DECWRITE (obj) ;
(*4*) SIGNATURE DEFAULT  (obj) : obj;
      SIGNATURE COERCE   (obj) : obj;
(*9*) END OBJECT.


SPECIFICATION AMONO;
(*Abelian monoid specification. *)
(*1*) IMPORT OBJECT[ amono/obj ];
(*2*) SIGNATURE ZERO (amono)       : amono;
(*3*) SIGNATURE SUM  (amono,amono) : amono;
(*9*) END AMONO.


SPECIFICATION AGROUP;
(*Abelian group specification. *)
(*1*) IMPORT AMONO[ ag/amono ];
(*2*) SIGNATURE DIF  (ag,ag) : ag;
      SIGNATURE NEG  (ag)    : ag;
(*9*) END AGROUP.


SPECIFICATION XRING;
(*Ring specification extending A group. *)
(*1*) IMPORT AGROUP[ xring/ag ];
(*2*) SIGNATURE ONE  (xring)       : xring;
(*3*) SIGNATURE PROD (xring,xring) : xring;
      SIGNATURE EXP  (xring,xring) : xring;
(*9*) END XRING.


SPECIFICATION RING;
(*Ring specification combining an A group and an A moniod. *)
(*1*) SORT atom;
      IMPORT AGROUP[ ring/ag ];
      IMPORT AMONO [ ring/amono, ONE/ZERO, PROD/SUM ];
(*3*) SIGNATURE EXP  (ring,atom) : ring;
(*9*) END RING.


SPECIFICATION MODULE(Ring (*: spec*));
(*Module specification. *)
(*1*) IMPORT AGROUP[ melem/ag ];
      (*IMPORT Ring;*)
      SORT ring;
(*3*) SIGNATURE SPROD (ring,melem) : melem;
(*9*) END MODULE.


SPECIFICATION ERING;
(*Euclidean ring specification. *)
(*1*) IMPORT RING[ er/ring ];
(*2*) SIGNATURE QR  (er,er,er,er) ;
      SIGNATURE GCD (er,er)       : er;
(*9*) END ERING.


SPECIFICATION GBRING;
(*Groebner base ring specification. *)
      IMPORT RING[ gbring/ring ];
(*2*) SIGNATURE NF  (gbring,ring) : ring;            
      SIGNATURE GB  (gbring)      : gbring;            
      SIGNATURE IRR (gbring)      : gbring;            
(*9*) END GBRING.


SPECIFICATION XFIELD;
(*Field specification extending ring. *)
(*1*) IMPORT RING[ xfield/ring ];
(*2*) SIGNATURE REZIP (xfield)        : xfield;
      SIGNATURE Q     (xfield,xfield) : xfield;
(*9*) END XFIELD.


SPECIFICATION FIELD;
(*Field specification combining two A groups. *)
(*1*) SORT atom;
      IMPORT AGROUP[ field/ag ];
      IMPORT AGROUP[ field/ag, ONE/ZERO, PROD/SUM, REZIP/NEG, Q/DIF ];
(*3 SIGNATURE EXP  (field ,atom) : field; *)
(*9*) END FIELD.


(* ----------- implementations of abstract items --- *)

IMPLEMENTATION RING;
(*1*) PROCEDURE EXP(X,n);
      VAR   x: ring;
      VAR   i: atom;
      BEGIN 
      (*1*) IF n <= 0 THEN x:=ONE(X); RETURN(x) END;
      (*3*) i:=n; x:=X; 
            WHILE i > 1 DO i:=i-1; 
                  x:=PROD(x,X) END;
            RETURN(x)
      (*9*) END EXP;
(*9*) END RING.




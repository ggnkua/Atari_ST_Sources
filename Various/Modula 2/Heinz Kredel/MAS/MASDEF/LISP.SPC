

(* ---------- atom unit --- *)

SPECIFICATION ATOM;
(*Atoms specification. *)
(*1*) SORT atom;
(*2*) SIGNATURE Aone     ()          : atom;
      SIGNATURE Azero    ()          : atom;
(*3*) SIGNATURE MUL      (atom,atom) : atom;
      SIGNATURE ADD      (atom,atom) : atom;
      SIGNATURE SUB      (atom)      : atom;
      SIGNATURE SUB      (atom,atom) : atom;
      SIGNATURE POW      (atom,atom) : atom;
      SIGNATURE QUOT     (atom,atom) : atom;
      SIGNATURE REM      (atom,atom) : atom;
(*4*) SIGNATURE Adefault ()          : atom;
(*9*) END ATOM.


IMPLEMENTATION ATOM;
(*1*) PROCEDURE Aone();
      BEGIN RETURN(1) END Aone;
(*2*) PROCEDURE Azero();
      BEGIN RETURN(0) END Azero;
(*3*) PROCEDURE Adefault();
      BEGIN RETURN(0) END Adefault;
(*9*) END ATOM.


MODEL RING;
(*Atoms are a model for rings. *)
(*1*) IMPORT ATOM;
      IMPORT INTEGER;
(*2*) MAP READ(atom)       -> IREAD(); 
      MAP WRITE(atom)      -> IWRITE(VAL);
      MAP DEFAULT(atom)    -> Adefault();
(*3*) MAP ONE(atom)        -> Aone();
      MAP ZERO(atom)       -> Azero();
(*4*) MAP PROD(atom,atom)  -> MUL(VAL,VAL);
      MAP SUM(atom,atom)   -> ADD(VAL,VAL);
      MAP DIF(atom,atom)   -> SUB(VAL,VAL);
      MAP NEG(atom)        -> SUB(VAL);
(*9*) END RING.


(* ---------- list unit --- *)

SPECIFICATION Lists; (*LIST is a keyword ! *)
(*List processing specification. *)
(*1*) SORT list, object, atom;
(*2*) SIGNATURE NullList ()                        : list;
      SIGNATURE COMP     (object, list)            : list;
      SIGNATURE LIST     (object, (*...,*) object) : list;
      SIGNATURE CONC     (list,list)               : list;
      SIGNATURE CCONC    (list,list)               : list;
(*3*) SIGNATURE FIRST    (list)                    : object;
      SIGNATURE RED      (list)                    : list;
      SIGNATURE ADV      (list, object, list)      ;
(*4*) SIGNATURE INV      (list)                    : list;
      SIGNATURE CINV     (list)                    : list;
(*5*) SIGNATURE SFIRST   (list,object)             ;
      SIGNATURE SRED     (list,list)               ;
(*7*) SIGNATURE EQUAL    (object,object)           : atom;
      SIGNATURE LENGTH   (list)                    : atom;
(*9*) END Lists.


IMPLEMENTATION Lists; 
(*1*) PROCEDURE NullList(): list;
      RETURN(LIST()) NullList;
(*9*) END Lists.


(* ---------- bool unit --- *)

SPECIFICATION BOOL;
(*Boolean specification. *)
(*1*) SORT bool, object;
(*2*) SIGNATURE true     ()              : bool;
      SIGNATURE false    ()              : bool;
(*3*) SIGNATURE EQ       (object,object) : bool;
      SIGNATURE NE       (object,object) : bool;
      SIGNATURE LE       (object,object) : bool;
      SIGNATURE GE       (object,object) : bool;
      SIGNATURE LT       (object,object) : bool;
      SIGNATURE GT       (object,object) : bool;
(*4   (*key words*) 
      SIGNATURE OR       (bool,bool)     : bool;
      SIGNATURE AND      (bool,bool)     : bool;
      SIGNATURE NOT      (bool)          : bool;
      *)
(*9*) END BOOL.


IMPLEMENTATION BOOL;
(*1*) PROCEDURE true();
      BEGIN RETURN(T) END true;
(*2*) PROCEDURE false();
      BEGIN RETURN(LIST()) END false;
(*9*) END BOOL.


(* ----------- representation unit --- *)

SPECIFICATION REPRESENTATION;
(*Representation specification. *)
(*1*) SORT elem, name, rep, pair, bool, func;
(*2*) SIGNATURE NewRep       ()              : rep;
      SIGNATURE SetRep       (name,elem,rep) ;
      SIGNATURE GetRep       (name,rep)      : elem;
      SIGNATURE CopyRep      (rep)           : rep;
      SIGNATURE StepRep      (rep)           : pair;
      SIGNATURE ForEachinRep (rep,func)      : rep;
      SIGNATURE FullRep      (rep)           : bool;
      SIGNATURE Pair         (name,elem)     : pair;
      SIGNATURE NullPair     ()              : pair;
(*9*) END REPRESENTATION.


IMPLEMENTATION REPRESENTATION; 
(*1*) PROCEDURE Pair(a,b): pair;
      RETURN(LIST(a,b)) Pair;
(*2*) PROCEDURE NullPair(): pair;
      RETURN(LIST()) NullPair;
(*9*) END REPRESENTATION.


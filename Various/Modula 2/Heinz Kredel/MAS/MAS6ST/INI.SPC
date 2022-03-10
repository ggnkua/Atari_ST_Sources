
BEGIN
 CLOUT("Loading specifications ...");
 (*OUT("NUL:");*) x:=T; (* define T for parser *)
 PRAGMA(SLOPPY); 
 (*PRAGMA(GENPARSE);  ensure non-generic parse *)
 END.

(* read required specifications. *)

IN("spec/abstr.spc").   (* abstract items *)

IN("spec/lisp.spc").    (* builtin lisp functions *)

IN("spec/arith.spc").   (* basic arithmetic *)

IN("spec/term.spc").    (* elementary term structures *)

IN("spec/poly.spc").    (* polynomials *)

CLOUT(" ... exposing units ... ").

(*specifics. *)
EXPOSE ATOM. 
EXPOSE REPRESENTATION. 
EXPOSE Lists. 

EXPOSE INTEGER. 
EXPOSE RATIONAL.
EXPOSE MODINT. 
EXPOSE FLOATING. 

EXPOSE PROPLOG.
EXPOSE PEANO.

EXPOSE IPOL.
EXPOSE DIRP.
EXPOSE DIRL.

(*generics. *)
EXPOSE OBJECT. 
EXPOSE AGROUP. 
EXPOSE FIELD. 
EXPOSE RING. 
EXPOSE GBRING. 

BEGIN 
 PRAGMA(FUSSY); 
 (*SHUT("NUL:");*)
 (*PRAGMA(GENPARSE); allow generic parse, if required *)
 CLOUT("... finished.");
 END.


IMPLEMENTATION MODULE LPRTERMINATION;

(* 27-Nov-93, Holger Kleinschmidt *)

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, REG, VAL;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  t   : TermRecPtr;
  r   : INTEGER;
  acc : BOOLEAN;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE IsAPP ( ): BOOLEAN;
BEGIN
 RETURN(NOT acc);
END IsAPP;

(*---------------------------------------------------------------------------*)

PROCEDURE SetTermResult ((* EIN/ -- *) ret : INTEGER );
BEGIN
 r := ret;
END SetTermResult;

(*---------------------------------------------------------------------------*)

PROCEDURE InstallTerm ((*    /AUS *) VAR term : TermRec;
                       (* EIN/ -- *)     proc : PROC    );
BEGIN
 term.next := t;
 term.proc := proc;
 t         := ADR(term);
END InstallTerm;

(*---------------------------------------------------------------------------*)

PROCEDURE FINALIZE ((* -- /AUS *) VAR ret : INTEGER );
BEGIN
 WHILE t <> NIL DO
   t^.proc;
   t := t^.next;
 END;
 ret := r;
END FINALIZE;

(*---------------------------------------------------------------------------*)

PROCEDURE TERMINATE ((* EIN/ -- *) ret : INTEGER );

PROCEDURE Pterm (p1,f:INTEGER); CODE(4E41H);

BEGIN
 Pterm(ret, 76)
END TERMINATE;

(*---------------------------------------------------------------------------*)

PROCEDURE Terminate ((* EIN/ -- *) ret : INTEGER );

VAR r : INTEGER;

BEGIN
 FINALIZE(r);
 TERMINATE(ret);
END Terminate;

(*===========================================================================*)

BEGIN (* LPRTERMINATION *)
 (* Die Abfrage auf ein ACC funktioniert nur, weil durch die Initialisierung
  * von 'System' und 'Terminal' (das von 'System' importiert wird) Register
  * A0 nicht geaendert wird. Bei einem anderen 'System' oder 'Terminal'
  * muss A0 zu Beginn der Initialisierung gerettet und zum Schluss wieder
  * restauriert werden!!!
  *)
 BasePageP := VAL(ADDRESS,REG(8));
 acc       := (BasePageP <> NIL) AND (BasePageP^.pParent = NIL);
 (* Wenn das Programm unter Kontrolle des Laders laeuft, ist A0
  * hoechstwahrscheinlich nicht NIL, aber pParent ist keinesfalls NIL,
  * so dass "IsAPP()" dort immer TRUE liefert.
  *)
 r := 0;
 t := NIL;
END LPRTERMINATION.

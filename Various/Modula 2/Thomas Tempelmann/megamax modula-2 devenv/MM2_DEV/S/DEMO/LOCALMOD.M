
(*
 * Dies Modul hat keine Funktion. Es demonstriert lediglich, wie der
 * Megamax-Compiler den IMPORT & EXPORT bei lokalen Modulen behandelt.
 *)

(*
 * Zuerst das Definitionsmodul
 * ---------------------------
 *)

DEFINITION MODULE LocalModules;

  EXPORT ExportProc1, ExportProc2;
    (*
     * Export-Listen sind auch weiterhin mîglich, auch QUALIFIED.
     *)

  PROCEDURE ExportProc1;  (* Sie wird in einem lokalen Modul implementiert *)

  PROCEDURE ExportProc2;  (* Sie wird in einem lokalen Modul implementiert *)

END LocalModules.

(*
 * Jetzt das Implementationsmodul
 * ------------------------------
 *)

IMPLEMENTATION MODULE LocalModules;

IMPORT InOut;

TYPE GlobalTyp = CARDINAL;

PROCEDURE ProcFromLocal3;       (* FORWARD-Deklaration, um diese Proc schon *)
  FORWARD;                      (* vor ihrer Impl. im 3. Modul zu benutzen. *)

(* 1. lokales Modul *)

MODULE Local1;

  IMPORT GlobalTyp;             (* ist nun auch hier sichtbar *)
  
  IMPORT ProcFromLocal3;        (* kommt aus 3. lok. Modul - FORWARD-Dekl. *)

  EXPORT Local1Typ, ExportProc1;(* werden auûen sichtbar *)

  TYPE Local1Typ = INTEGER;

  VAR v: GlobalTyp;

  PROCEDURE ExportProc1;        (* Sie wird global (im Def-Modul) exportiert *)
    BEGIN (* ...*) END ExportProc1;

  END Local1;

(* 2. lokales Modul *)

MODULE Local2;

  IMPORT Local1Typ;             (* ist nun auch hier sichtbar *)
  (*
   * ein "IMPORT Local1" brÑchte nichts, da Local1
   * nicht qualifiziert exportiert wird.
   *)

  IMPORT ExportProc2;
  (*
   * statt Ex- ist auch Import des im Def-Modul exportierten Bezeichners
   * mîglich, um ihn hier im lokalen Modul zu implementieren. Allerdings
   * ist der Export die bei anderen Compilern Åblichere Art, deshalb sollten
   * Sie den Export (wie im Modul 'Local1') dem Import vorziehen.
   *)

  EXPORT QUALIFIED Local2Typ;   (* wird auûen nur qualifiziert sichtbar *)

  TYPE Local2Typ = CHAR;

  VAR v: Local1Typ;             (* unqualifizierter Zugriff *)

  PROCEDURE ExportProc2;        (* Sie wird global (im Def-Modul) exportiert *)
    BEGIN (* ...*) END ExportProc2;

  END Local2;

(* 3. lokales Modul *)

MODULE Local3;
  
  FROM Local2 IMPORT Local2Typ; (* ist mîglich, weil qualif. Export *)
  IMPORT Local2;                (* auch nur mîglich wegen qualif. Export *)
  (*
   * Beide obigen Importe entsprechen dem aus externen Definition-Modulen.
   * Denn in externen Def-Modulen werden die Bezeichner alle automatisch
   * qualifiziert exportiert, wie dies explizit bei 'Local2' geschieht.
   *)

  FROM InOut IMPORT WriteString;(* NatÅrlich geht's auch bei externen Modulen*)

  EXPORT ProcFromLocal3;        (* Wurde bereits vorher benutzt (FORWARD) *)

  VAR v1: Local2Typ;            (* unqualifizierter Zugriff von 1. Import *)
      v2: Local2.Local2Typ;     (* qualifizierter Zugriff von 2. Import *)

  PROCEDURE ProcFromLocal3;
    BEGIN (* ... *) END ProcFromLocal3;

  END Local3;

(* wieder globales Modul *)

VAR v1: Local1Typ;              (* nur unqualifiziert ansprechbar *)
    v2: Local2.Local2Typ;       (* nur qualifiziert ansprechbar *)

END LocalModules.

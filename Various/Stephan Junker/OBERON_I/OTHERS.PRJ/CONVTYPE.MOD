MODULE ConvTypes;

(*****************************************************************************)
(* ISO-ConvTypes, STJ-Oberon-2-Version                                       *)
(* --------------------------------------------------------------------------*)
(* Stellt Typen fuer die Konvertierung zwischen Strings und Werten zur       *)
(* Verfuegung.                                                               *)
(* --------------------------------------------------------------------------*)
(* 02-Sep-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

IMPORT SYSTEM;

CONST
  (* Klassifizierung einer Stringrepraesentation *)

  strAllRight* = 0;
    (* Die Stringrepraesentation ist korrekt bzgl. der entsprechenden
       Konvertierung. *)
  strOutOfRange* = 1;
    (* Die Stringrepraesentation ist korrekt bzgl. der entsprechenden
       Konvertierung, aber der Wert ueberschreitet den entsprechenden
       Wertebereich. *)
  strWrongFormat* = 2;
    (* Die Stringrepraesentation ist nicht korrekt bzgl. der entsprechenden
       Konvertierung. *)
  strEmpty* = 3;
    (* Der String enthaelt kein Zeichen (ausser Leerzeichen). *)


CONST
  (* Klassifizierung der Eingabe fuer einen endlichen Automaten zur
     Konvertierung. *)

  padding* = 0;
    (* fuehrende Leerzeichen an diesem Punkt der Eingabe -- ignorieren *)
  valid* = 1;
    (* gueltiges Zeichen an diesem Punkt der Eingabe -- akzeptieren *)
  invalid* = 2;
    (* ungueltiges Zeichen an diesem Punkt der Eingabe -- abweisen *)
  terminator* = 3;
    (* beendendes Zeichen an diesem Punkt der Eingabe -- (gehoert nicht
       mehr zur Repraesentation) *)

TYPE
  (* Typ der Prozedur fuer den Zustand des endlichen Automaten
     zur Konvertierung. *)

  ScanState* =
    PROCEDURE(c:CHAR; VAR class:SHORTINT; VAR state:ARRAY OF SYSTEM.BYTE);

END ConvTypes.


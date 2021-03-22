DEFINITION MODULE ErrBase;

(*
 * Programmgesteuertes Auslîsen von Laufzeitfehlern
 *)

FROM SYSTEM IMPORT ADDRESS;

FROM SysTypes IMPORT ExcDesc;

TYPE RtnCond = ( mayContinue,    (* Programm darf fortgefÅhrt werden. *)
                 mustAbort );    (* Programm sollte beendet werden. *)

     ErrResp = ( selfCaused,     (* Fehler selbst verursacht. *)
                 callerCaused ); (* Fehler von Aufrufer verursacht. *)

PROCEDURE RaiseError (    no    : INTEGER;       (* Fehlernummer *)
                      REF msg   : ARRAY OF CHAR; (* Text, max. 32 Zeichen *)
                          causer: ErrResp;
                          cont  : RtnCond );
  (*
   * Meldet einen Laufzeitfehler.
   *
   * 'msg' darf ein Leerstring sein.
   *)

(*
  TRAP Instruktionen in Assembler sind wie folgt kodiert:
    1. Word:
      Trap-Instruktion, normalerweise 'TRAP #6'
    2. Word:
      Bit 15: 0 = Ein Text, mit einem Nullbyte beendet, folgt hiernach.
      Bit 14: Fehlerverursacher, 1=diese Routine, 0=aufrufende Routine
              (funktioniert nur, wenn die Erzeugung des Link-Codes am
              Prozedurbeginn nicht unterdrÅckt ist).
      Bit 13: 1 = Programm kann hiernach weiter ausgefÅhrt werden.
      Bit 12: immer Eins
      Bit 11-0: Fehlernummer, Bit 11 wirkt als Vorzeichenbit und wird
              zur 16 Bit-Zahl nach Bit 12-15 kopiert.
*)

(* ======================================================================== *)
(*                    Systemfunktionen - nicht verwenden!                   *)
(* ======================================================================== *)

TYPE ErrHdlProc = PROCEDURE (     (* errNo:   *) INTEGER,
                                  (* msg:     *) ARRAY OF CHAR, (* max. 32 Z.*)
                                  (* causer:  *) ErrResp,
                                  (* cont:    *) RtnCond,
                              VAR (* excData: *) ExcDesc );

VAR ErrHdl: ErrHdlProc;
  (*
   * Die Routine erhÑlt bei Aufruf einen Stack von 600 Bytes;
   * Das Installieren und Restaurieren dieses Vektors muû
   * vom Aufrufer durchgefÅhrt werden, vor allem bei Prozeûende!
   *)

VAR ExcInstalled: BOOLEAN;

PROCEDURE InstallExc; (* Erfolg ist Åber 'ExcInstalled' zu ermitteln! *)
PROCEDURE RemoveExc;

END ErrBase.

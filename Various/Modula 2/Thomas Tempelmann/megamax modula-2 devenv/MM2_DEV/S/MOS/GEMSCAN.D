DEFINITION MODULE GEMScan;

(*
 * Dies Modul dient zum Anzeigen einer Aufruferkette.
 * Die Funktion wird z.B. vom Modul 'GEMError' nach einem
 * Laufzeitfehler benutzt.
 *)

FROM SYSTEM IMPORT LONGWORD;

FROM SysTypes IMPORT ScanDesc;

FROM MOSGlobals IMPORT NameStr;

CONST   MaxDepth = 19;

VAR     CallingChain: ARRAY [0..MaxDepth] OF RECORD
                        relAddr   : LONGCARD;              (* rel. Moduladr. *)
                        modName   : ARRAY [0..19] OF CHAR; (* Modulname *)
                        sourceName: NameStr;               (* Sourcename *)
                        procName  : ARRAY [0..19] OF CHAR; (* Prozedurname *)
                        codeOpts  : LONGWORD;              (* Comp-Options *)
                      END;

        ChainDepth: INTEGER;  (* <0 : CallingChain leer *)


PROCEDURE InitChain ( firstPosition: ScanDesc );
  (*
   * Initialisiert eine Aufruferkette. Der tiefste Aufrufer wird in
   * 'firstPosition' bergeben.
   * Die Funktion initialisiert dann fr jeden Aufrufer ein Element
   * des Feldes 'CallingChain'. 'ChainDepth' enth„lt den h”chsten
   * verwendeten Feldindex.
   *)

PROCEDURE InputScan ( REF msg: ARRAY OF CHAR; VAR index: CARDINAL );
  (*
   * Zeigt die Informationen aus dem Feld mit dem Index 'index' mit
   * Hilfe der GEM-Alert-Box an.
   * Dann kann der Anwender den Index erh”hen oder erniedrigen oder
   * diese Funktion verlassen.
   * Hinterher enth„lt 'index' die Feldnummer, die zuletzt angezeigt
   * wurde.
   *)

END GEMScan.

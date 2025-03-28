(******************************************************************************)
(* Modulname           : HandleWodan (DEFINITION)                             *)
(* Copyright           : ST Computer & D. Rabich                              *)
(* Datum               :  1. Juni 1989                                        *)
(* letztes Edier-Datum : 11. Oktober 1989                                     *)
(* Version             : 1.00a                                                *)
(* Entwicklungssystem  : Megamax Modula-2                                     *)
(******************************************************************************)

DEFINITION MODULE HandleWodan;
(*$Q+,M-,N-,V+,P-,R-,S-*)


(* Importe *)
FROM GEMGlobals IMPORT PtrObjTree;
FROM Keyboard   IMPORT SpecialCode;
FROM Strings    IMPORT String;
FROM SYSTEM     IMPORT ADDRESS;


(* Typen *)
TYPE StringArray     = ARRAY [alt1..altZ] OF String;
     LokalParameter  = RECORD (* fÅr Fremdaufruf und internen Gebrauch *)
                         Aktiv       : BOOLEAN;
                         Position    : SpecialCode;
                         StringAdr   : POINTER TO StringArray
                       END;


(* Fehlermeldung, falls Installation nicht mîglich *)
PROCEDURE NoInstallation;

(* Setzt die Adresse der Strings *)
PROCEDURE SetStringAdr (SAdr : ADDRESS);

(* Accessory initialisieren,                                    *)
(* RÅckgabe: TRUE, falls erfolgreich, FALSE sonst               *)
PROCEDURE InitAcc : BOOLEAN;

(* Parameter initialisieren,                                    *)
(* RÅckgabe: TRUE, falls Wodan aktiv, FALSE, falls Wodan passiv *)
PROCEDURE InitParameter : BOOLEAN;

(* Accessory-Ablauf,                                            *)
(* RÅckgabe: TRUE, falls Wodan aktiv, FALSE, falls Wodan passiv *)
PROCEDURE HandleAcc : BOOLEAN;

(* Accessory canceln (Warteschleife) *)
PROCEDURE CancelAcc;


END HandleWodan.

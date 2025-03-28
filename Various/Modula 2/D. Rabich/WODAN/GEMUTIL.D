(******************************************************************************)
(* Modulname           : GEMUtility (DEFINITION)                              *)
(* Copyright           : D. Rabich                                            *)
(* Datum               :  3. Juni 1989                                        *)
(* letztes Edier-Datum : 10. Juni 1989                                        *)
(* Version             : 1.00a                                                *)
(* Entwicklungssystem  : Megamax Modula-2                                     *)
(******************************************************************************)

DEFINITION MODULE GEMUtility;
(*$Q+,M-,N-,V+,P-,R-,S-*)


(* Importe *)
FROM GEMGlobals IMPORT PtrObjTree, ObjState;
FROM GrafBase   IMPORT Rectangle;


(* Maus als Biene, Sanduhr, ... *)
PROCEDURE ShowBusy;

(* Maus als Pfeil *)
PROCEDURE ShowArrow;

(* Maus zeigen *)
PROCEDURE ShowMouse;

(* Maus verstecken *)
PROCEDURE HideMouse;

(* Platz, den das Objekt belegt *)
PROCEDURE objectSpace (obj : CARDINAL) : Rectangle;

(* Platz, den das Objekt bzgl. Offset belegt *)
PROCEDURE objOffsetSpace (obj : CARDINAL) : Rectangle;

(* Objekt-Status entfernen *)
PROCEDURE clearObjState (obj : CARDINAL; which : ObjState; redraw : BOOLEAN);

(* Objekt-Status setzen *)
PROCEDURE setObjState (obj : CARDINAL; which : ObjState; redraw : BOOLEAN);

(* Zeichenkette holen *)
PROCEDURE getTextString (tree    : PtrObjTree;
                         obj     : CARDINAL;
                         VAR str : ARRAY OF CHAR);

(* Zeichenkette setzen *)
PROCEDURE setTextString (tree    : PtrObjTree;
                         obj     : CARDINAL;
                         VAR str : ARRAY OF CHAR);
(* VAR nur wegen der Geschwindigkeit *)

(* Character setzen *)
PROCEDURE setTextChar (tree   : PtrObjTree;
                       obj    : CARDINAL;
                       char   : CHAR);

(* Dialog vorbereiten *)
PROCEDURE prepareBox (tree : PtrObjTree) : Rectangle;

(* Dialog nachbereiten *)
PROCEDURE releaseBox (tree : PtrObjTree; space : Rectangle);


END GEMUtility.

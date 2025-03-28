(******************************************************************************)
(* Modulname           : GEMUtility (IMPLEMENTATION)                          *)
(* Copyright           : D. Rabich                                            *)
(* Datum               :  3. Juni 1989                                        *)
(* letztes Edier-Datum : 11. Oktober 1989                                     *)
(* Version             : 1.00b                                                *)
(* Entwicklungssystem  : Megamax Modula-2                                     *)
(******************************************************************************)

IMPLEMENTATION MODULE GEMUtility;
(*$Q+,M-,N-,V+,P-,R-,S-*)


(* GEM-Routinen *)
FROM GEMGlobals  IMPORT PtrObjTree, Root, ObjState, OStateSet, MaxDepth,
                        MButtonSet, SpecialKeySet;
FROM AESForms    IMPORT FormDial, FormDialMode, FormCenter;
FROM AESGraphics IMPORT MouseForm, GrafMouse, MouseKeyState;
FROM AESObjects  IMPORT ChangeObjState, DrawObject, ObjectOffset;
FROM AESWindows  IMPORT UpdateWindow;

FROM ObjHandler  IMPORT CurrObjTree, ObjectState, ObjectSpace, BorderThickness,
                        SetCurrObjTree, AssignTextStrings, SetPtrChoice,
                        GetTextStrings, ObjTreeError;

(* Graphik-Routinen *)
FROM GrafBase    IMPORT Rect, Rectangle, TransRect, Point;

(* Strings-Routine *)
FROM Strings     IMPORT String;

(* System-Routine *)
FROM SYSTEM      IMPORT ADR;


(* Typ *)
TYPE MouseImageStruct = RECORD
                          MfXhot    : CARDINAL;
                          MfYhot    : CARDINAL;
                          MfNPlanes : CARDINAL;
                          MfFg      : CARDINAL;
                          MfBg      : CARDINAL;
                          MfMask    : ARRAY [0..15] OF CARDINAL;
                          MfData    : ARRAY [0..15] OF CARDINAL
                        END;


(* Variablen *)
VAR MouseImage : MouseImageStruct; (* Maus-Form *)
    MousePos   : Point;


(* Maus "besch„ftigt" *)
PROCEDURE ShowBusy;

  BEGIN
    GrafMouse (userCursor, ADR(MouseImage))
  END ShowBusy;


(* Maus als Pfeil *)
PROCEDURE ShowArrow;

  BEGIN
    GrafMouse (arrow, NIL)
  END ShowArrow;


(* Maus sichtbar *)
PROCEDURE ShowMouse;

  BEGIN
    GrafMouse (mouseOn, NIL)
  END ShowMouse;


(* Maus unsichtbar *)
PROCEDURE HideMouse;

  BEGIN
    GrafMouse (mouseOff, NIL)
  END HideMouse;


(* Platzbedarf ermitteln *)
PROCEDURE objectSpace (obj : CARDINAL) : Rectangle;

 VAR space : Rectangle;

  BEGIN
    space := ObjectSpace (obj);
    IF shadowObj IN ObjectState (obj)   (* Schattierung beachten *)
    THEN
      space.w := space.w + 2 * ABS (BorderThickness(obj));
      space.h := space.h + 2 * ABS (BorderThickness(obj))
    END;
    RETURN space
  END objectSpace;


(* Platzbedarf bzgl. Offset *)
PROCEDURE objOffsetSpace (obj : CARDINAL) : Rectangle;

  BEGIN
    RETURN TransRect (objectSpace(obj), ObjectOffset(CurrObjTree(), obj))
  END objOffsetSpace;


(* Status entfernen *)
PROCEDURE clearObjState (obj : CARDINAL; which : ObjState; redraw : BOOLEAN);

  VAR state : OStateSet;

  BEGIN
    state := ObjectState (obj);
    EXCL (state, which);
    ChangeObjState (CurrObjTree(), obj, objOffsetSpace(obj), state, redraw)
  END clearObjState;


(* Status setzen *)
PROCEDURE setObjState (obj : CARDINAL; which : ObjState; redraw : BOOLEAN);

  VAR state : OStateSet;

  BEGIN
    state := ObjectState (obj);
    INCL (state, which);
    ChangeObjState (CurrObjTree(), obj, objOffsetSpace(obj), state, redraw)
  END setObjState;


(* Zeichenkette holen *)
PROCEDURE getTextString (tree    : PtrObjTree;
                         obj     : CARDINAL;
                         VAR str : ARRAY OF CHAR);

  VAR voidStr : String;

  BEGIN
    SetCurrObjTree (tree, FALSE);
    GetTextStrings (obj, str, voidStr, voidStr);
    IF ObjTreeError ()
    THEN
      str[0]:=0C
    END
  END getTextString;


(* Zeichenkette setzen *)
PROCEDURE setTextString (tree    : PtrObjTree;
                         obj     : CARDINAL;
                         VAR str : ARRAY OF CHAR);

  BEGIN
    SetCurrObjTree (tree, FALSE);
    AssignTextStrings (obj, setOnly, str, noChange, '', noChange, '')
  END setTextString;


(* Character setzen *)
PROCEDURE setTextChar (tree   : PtrObjTree;
                       obj    : CARDINAL;
                       char   : CHAR);

  BEGIN
    SetCurrObjTree (tree, FALSE);
    tree^[obj].spec.letter := char
  END setTextChar;


(* Dialog vorbereiten *)
PROCEDURE prepareBox (tree : PtrObjTree) : Rectangle;

  VAR space    : Rectangle;
      Keys     : SpecialKeySet;
      Buts     : MButtonSet;

  BEGIN
    ShowArrow;                        (* Maus als Pfeil                  *)
    UpdateWindow (TRUE);              (* Keine Fenstererneuerung         *)
    SetCurrObjTree (tree, FALSE);
    space := FormCenter (tree);       (* zentrieren                      *)
    space := objOffsetSpace (Root);   (* Schattierung beachten           *)
    MouseKeyState (MousePos, Buts, Keys);
    FormDial (reserveForm, Rect (MousePos.x, MousePos.y, 20, 20),
                           space);            (* Hintergrund reservieren *)
    FormDial (growForm,    Rect (MousePos.x, MousePos.y, 20, 20),
                           space);            (* Rechtecke               *)
    DrawObject (tree, Root, MaxDepth, space); (* Dialogbox ausgeben      *)
    RETURN space
  END prepareBox;


(* Dialog nachbereiten *)
PROCEDURE releaseBox (tree : PtrObjTree; space : Rectangle);

  BEGIN
    FormDial (freeForm,   Rect (MousePos.x, MousePos.y, 20, 20),
                          space);             (* Hintergrund freigeben   *)
    FormDial (shrinkForm, Rect (MousePos.x, MousePos.y, 20, 20),
                          space);             (* Rechtecke               *)
    UpdateWindow (FALSE)                      (* Fenster erneuern        *)
  END releaseBox;


BEGIN

  (* Mausform setzen *)
  WITH MouseImage DO
    MfXhot     := $0;         MfYhot     := $0;    (* Hot-Spot                *)
    MfNPlanes  := $1;                              (* Farbebenen              *)
    MfFg       := $0;         MfBg       := $1;    (* Vorder- und Hintergrund *)
    MfMask[ 0] := $3FFC;      MfMask[ 1] := $3FFC; (* Maske                   *)
    MfMask[ 2] := $3FFC;      MfMask[ 3] := $1FF8;
    MfMask[ 4] := $1FF8;      MfMask[ 5] := $1FF8;
    MfMask[ 6] := $1FF8;      MfMask[ 7] := $0FF0;
    MfMask[ 8] := $0FF0;      MfMask[ 9] := $1FF8;
    MfMask[10] := $1FF8;      MfMask[11] := $1FF8;
    MfMask[12] := $1FF8;      MfMask[13] := $3FFC;
    MfMask[14] := $3FFC;      MfMask[15] := $3FFC;
    MfData[ 0] := $0000;      MfData[ 1] := $1FF8; (* Daten                   *)
    MfData[ 2] := $0810;      MfData[ 3] := $0C30;
    MfData[ 4] := $0E30;      MfData[ 5] := $0FF0;
    MfData[ 6] := $07E0;      MfData[ 7] := $0340;
    MfData[ 8] := $0340;      MfData[ 9] := $0420;
    MfData[10] := $0910;      MfData[11] := $0890;
    MfData[12] := $0BD0;      MfData[13] := $0FF0;
    MfData[14] := $1FF8;      MfData[15] := $0000
  END

END GEMUtility.

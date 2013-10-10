MODULE ProgDefDemo;

(* /////////////////////////////////////////////////////////////////////////
 *
 * Dies ist ein Demo-Programm fÅr die Anwendung von benutzerdefinierten
 * Objekten.
 *
 * Das Programm benîtigt die Resource-Datei "PROGDEF.RSC"; ggf. ist sie
 * in den Ordner, in dem auch der Programmcode steht (USER\MOD\), zu kopieren.
 *
 * Das Programm stammt von Harry Bîck, Åberarbeitet von Thomas Tempelmann.
 *
 * ////////////////////////////////////////////////////////////////////// *)

FROM GEMEnv          IMPORT InitGem, GemActive, ExitGem, GemError,
                            CurrGemHandle, RC, GemHandle, DeviceHandle;
FROM AESResources    IMPORT ResourcePart, ResourceAddr, LoadResource,
                            FreeResource;
FROM AESObjects      IMPORT DrawObject;
FROM AESForms        IMPORT FormDo, FormCenter, FormDial, FormDialMode,
                            FormAlert;
FROM AESWindows      IMPORT UpdateWindow;
FROM EasyGEM0        IMPORT ShowMouse, HideMouse, ShowArrow, ShowBee;
FROM ObjHandler      IMPORT SetCurrObjTree,
                            SetObjType, ProgDefCarrier, MakeProgDefProc,
                            CreateSpecification, SetProgDefSpec;
FROM GEMGlobals      IMPORT MaxStr, PtrMaxStr, ObjSpec, ObjType, ObjFlag,
                            ObjState, OStateSet, OFlagSet, PtrObjSpec,
                            ApplBlock, ParmBlock, PtrObjTree,
                            TextEffect, TEffectSet, TVertJust, THorJust;
FROM GrafBase        IMPORT Rectangle, Point, Rect, Pnt, WritingMode,
                            ClipRect, MinPoint;

FROM VDIAttributes   IMPORT SetWritingMode, SetTextEffects,
                            SetAbsTHeight, SetTAlignment;
FROM VDIControls     IMPORT SetClipping, DisableClipping;
FROM VDIOutputs      IMPORT GrafText;

FROM SYSTEM          IMPORT ADR, LONGWORD;
FROM Storage         IMPORT ALLOCATE;
FROM MOSGlobals      IMPORT MemArea, MEM, fInsufficientMemory;
FROM PrgCtrl         IMPORT TermProcess;


(* Diese Konstanten stammen aus dem vom RCP erzeugten D-File: *)

CONST
  Form1    =   0;  (* Formular/Dialog *)
  Frame    =   0;  (* BOX in Baum FORM1 *)
  Head1    =   1;  (* STRING in Baum FORM1 *)
  Head2    =   2;  (* STRING in Baum FORM1 *)
  Head3    =   3;  (* STRING in Baum FORM1 *)
  Button2u =   4;  (* BUTTON in Baum FORM1 *)


CONST
  noRCS = "[3][ RSC-File ist nicht da! ][ ENDE ]";


TYPE   StringRec = POINTER TO RECORD
                                str      : PtrMaxStr;
                                effect   : TEffectSet;
                                fontSize : CARDINAL;
                                carrier  : ApplBlock;
                              END;

VAR     GemHdl             : GemHandle;
        DevHdl             : DeviceHandle;
        ResourceFileLoaded : BOOLEAN;


PROCEDURE StartApplication (REF RscFile: ARRAY OF CHAR): BOOLEAN;

  VAR  i, res: CARDINAL;
       ok    : BOOLEAN;

  BEGIN
    ResourceFileLoaded:= FALSE;
    InitGem (RC, DevHdl, ok);
    IF NOT ok THEN
      TermProcess (fInsufficientMemory)
    END;
    GemHdl:= CurrGemHandle ();
    UpdateWindow (TRUE);
    ShowBee ();
    IF LENGTH (RscFile) # 0 THEN       (* soll ResourceFile gelesen werden? *)
      LoadResource (RscFile);                          (* lade ResourceFile *)
      IF GemError () THEN
        ok:= FALSE;
        FormAlert (1, noRCS, res);                (* melde "Datei nicht da" *)
      ELSE
        ResourceFileLoaded:= TRUE;
      END;
    END;
    ShowArrow ();
    UpdateWindow (FALSE);
    RETURN ok
  END StartApplication;

PROCEDURE CloseApplication ();
  BEGIN
    IF ResourceFileLoaded THEN                    (* wenn Resource geladen, *)
      FreeResource ();                            (* gib sie wieder frei    *)
    END;
    ExitGem (GemHdl);                                           (* GEM ade! *)
  END CloseApplication;


(*
 * Die folgende Prozedur ist die benutzerdefinierte Funktion fÅr
 * das Zeichnen von Strings mit Attributen.
 * Dazu wird unten diese Prozedur mittels "MakeProgDefProc" als
 * Objekt-Zeichenfunktion vorbereitet und dann mit "SetProgDefSpec"
 * auf die gewÅnschten Objekte angemeldet.
 * Die Attribute werden beim Anmelden in einem extra angelegten Record
 * (StringRec) festgelegt und ein Zeiger darauf hier in 'param' Åbergeben.
 *)

PROCEDURE DrawText  (tree  : PtrObjTree;        (* Baum *)
                     index : CARDINAL;          (* Objektnr. *)
                     prevS,
                     currS : OStateSet;
                     space,
                     clip  : Rectangle;
                     param : LONGWORD): OStateSet;

  VAR   obj: StringRec;
        d  : CARDINAL;
        p  : Point;

  BEGIN
    (* Vorsicht: Hier dÅrfen VDI, aber keine AES-Routinen gerufen werden! *)
    
    obj:= StringRec (param);                             (* ObjektDaten holen *)
    
    SetTextEffects (DevHdl, obj^.effect);                 (* Parameter setzen *)
    IF (obj^.fontSize # 0) THEN
      SetAbsTHeight (DevHdl, obj^.fontSize, d, d, d, d);
    END;
    SetWritingMode (DevHdl, replaceWrt);
    
    p:= MinPoint (space);                         (* StringPosition berechnen *)
    p.y:= p.y + space.h - 2;
    
    SetClipping (DevHdl, clip);                            (* String ausgeben *)
    GrafText (DevHdl, p, obj^.str^);
    DisableClipping (DevHdl);
    
    RETURN OStateSet {}
  END DrawText;


VAR
        procHandle         : ProgDefCarrier;
        procStack          : ARRAY [1..500] OF CARDINAL; (* 1 KB reicht *)

        strObj1,
        strObj2            : StringRec;

        Baum               : PtrObjTree;
        exit               : CARDINAL;
        dialSpace          : Rectangle;

BEGIN
  IF StartApplication ('PROGDEF.RSC') THEN

    Baum:= ResourceAddr (treeRsrc, Form1);
    SetCurrObjTree (Baum, FALSE);
    dialSpace:= FormCenter (Baum);
    FormDial (reserveForm, dialSpace, dialSpace); (* Platz f. Box reservieren *)

    (* Prozedur 'DrawText' fÅr benutzerdef. Objekt vorbereiten *)
    MakeProgDefProc (procHandle, DrawText, MEM (procStack));

    (*
     * Parameter fÅr 'DrawText' vorbereiten.
     * Wir haben vor, die ersten beiden der drei vorhandenen String-Objekte
     * (Head1 und Head2) in der Box als benutzerdef. Objekte mittels
     * 'DrawText' zeichnen zu lassen.
     * Das erste Objekt soll fett und unterstrichen, das zweite nur unter-
     * strichen gezeichnet werden. Das dritte Objekt bleibt weiterhin
     * ein normales Text-Objekt und kann vom GEM nur ohne bestimmte
     * Attribute gezeichnet werden.
     *)
    NEW (strObj1);                        (* Parameter f. 1. Objekt anlegen *)
    (* Wir merken uns den Zeiger auf den Text des String-Objekts, da
     * 'spec.more' bei Aufruf von 'SetProgDefSpec' auf die benutzerdef.
     * Funktion umgesetzt wird: *)
    strObj1^.str:= PtrMaxStr (Baum^[Head1].spec.more);
    strObj1^.effect:= TEffectSet {thickText, underlineText};
    strObj1^.fontSize:= 0;
    (* Objekt-Typ umdefinieren: *)
    SetObjType (Head1, progDefObj);
    (* Speicher zuweisen, in dem das Handle der benutzerdef. Proz. sowie der
     * Parameter 'strObj1' gesichert werden kann: *)
    CreateSpecification (Head1, ADR (strObj1^.carrier));
    (* und nun die benutzerdef. Proz. und den Zeiger auf die Parms setzen: *)
    SetProgDefSpec (Head1, procHandle, strObj1);

    NEW (strObj2);                        (* Parameter f. 2. Objekt anlegen *)
    strObj2^.str:= PtrMaxStr (Baum^[Head2].spec.more);
    strObj2^.effect:= TEffectSet {underlineText};
    strObj2^.fontSize:= 0;
    SetObjType (Head2, progDefObj);
    CreateSpecification (Head2, NIL(*ADR (strObj2^.carrier)*));
    SetProgDefSpec (Head2, procHandle, strObj2);

    UpdateWindow (TRUE);
    HideMouse;
    DrawObject (Baum, 0, 8, dialSpace);                  (* zeichne die Box *)
    ShowMouse;
    UpdateWindow (FALSE);
    LOOP
      FormDo (Baum, 0, exit);                               (* fÅhre Dialog *)
      IF (exit = Button2u) THEN EXIT END;
    END;
    
    FormDial (freeForm, dialSpace, dialSpace);    (* Platz f. Box freigeben *)
    
    CloseApplication;
  END; (* IF *)
END ProgDefDemo.

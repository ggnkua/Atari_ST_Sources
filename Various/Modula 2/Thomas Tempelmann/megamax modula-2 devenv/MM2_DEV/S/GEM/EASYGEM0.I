IMPLEMENTATION MODULE EasyGEM0;
(*$R-, Y+*)

(*  --------------------------------------------------------------------------
 *  System-Version: MOS 1.1
 *  --------------------------------------------------------------------------
 *  Version       : 1.2
 *  --------------------------------------------------------------------------
 *  Text-Version  : V#0057
 *  --------------------------------------------------------------------------
 *  Modul-Holder  : Manuel Chakravarty
 *  --------------------------------------------------------------------------
 *  Copyright July 1988 by Manuel Chakravarty
 *  Vertriebsrechte fÅr ATARI ST unter MEGAMAX Modula-2
 *                  liegen bei Application Systems Heidelberg
 *  --------------------------------------------------------------------------
 *  MCH : Manuel Chakravarty
 *  --------------------------------------------------------------------------
 *  Datum    Autor  Version  Bemerkung (Arbeitsbericht)
 *
 *  19.07.88 MCH    0.01     Definitionen + Impl. von 'ShowArrow', 'ShowBee',
 *                           'HideMouse', 'ShowMouse', 'ObjectSpaceWithShadow',
 *                           'AbsObjectSpace', 'SetObjStateElem',
 *                           'ObjectStateElem', 'ToggleObjState', 'SetObjFlag',
 *                           'ObjectFlag', 'SetTextString', 'GetTextString',
 *                           'PrepareBox', 'ReleaseBox' und 'DoSimpleBox'.
 *  20.07.88 MCH    0.02     Def + Impl. von 'ForceDeskRedraw' und
 *                           'DrawObjInWdw'
 *  23.07.88 MCH    0.03     Def. + Impl. von 'DeskSize' + 'CharSize'
 *  07.08.88 MCH    0.04     Advanced dialog box managment
 *  25.08.88 MCH    0.05     'ObjectSpaceWithShadow' -> 'ObjectSpaceWithAttrs'
 *  17.08.89 MCH    0.06     'WrapAlert' def. + impl.
 *  10.09.89 TT     1.1      WrapAlert: stdWidth=29, Verbesserungen
 *  01.12.89 TT     1.2      'TreeAddress', 'TextStringAddress' def. + impl.
 *  01.02.91 TT              FormAlert: Null-Terminierung raus, da unnîtig.
 *  26.03.91 TT              PreprareBox: AbsObjectSpace berÅcksichtigt.
 *  05.07.91 TT              DoSimpleBox: Nach FormDo wird Bit 15 v. ExitBut
 *                           gelîscht.
 *  --------------------------------------------------------------------------
 *  Modul-Beschreibung:
 *
 *  Dieses Modul stellt eine Reihe von oft gebrauchten GEM-Funktionen zur
 *  VerfÅgung, die auf den verschiedenen AES-Funktionen und den Routinen
 *  des Moduls 'ObjHandler' aufbauen.
 *  --------------------------------------------------------------------------
 *)


FROM SYSTEM             IMPORT ASSEMBLER, ADDRESS, WORD;

(*  MOS  *)

FROM MOSGlobals         IMPORT OutOfStack;

FROM Strings            IMPORT String,
                               PosLen, Length, Insert;

FROM StrConv            IMPORT CardToStr, IntToStr, StrToLCard, StrToLInt;

(*  GEM  *)

FROM GrafBase           IMPORT Rectangle, Point,
                               Pnt, Rect, TransRect, ClipRect, MinPoint;

FROM GEMGlobals         IMPORT Root, MaxDepth,
                               PtrObjTree, OStateSet, OFlagSet, ObjState,
                               ObjFlag, ObjType, PtrMaxStr;

FROM GEMEnv             IMPORT DeviceHandle,
                               MouseInput;

FROM VDIInquires        IMPORT GetFaceInfo;

FROM AESObjects         IMPORT ObjectOffset, DrawObject, ChangeObjState;

FROM AESForms           IMPORT FormDialMode,
                               FormDial, FormCenter, FormDo;

FROM AESWindows         IMPORT DeskHandle, WSizeMode, RListMode,
                               WindowSize, MouseControl, WindowRectList;

FROM AESGraphics        IMPORT MouseForm,
                               GrafMouse;

FROM AESResources       IMPORT ResourcePart,
                               ResourceAddr;

FROM ObjHandler         IMPORT SetPtrChoice,
                               BorderThickness, ObjectState, ObjectSpace,
                               SetCurrObjTree, ObjTreeError, GetTextStrings,
                               AssignTextStrings, SetObjState, SetObjFlags,
                               ObjectFlags, SetObjSpace, ObjectType;


VAR     (*  global dummys  *)

        voidI   : INTEGER;
        voidC   : CARDINAL;
        voidO   : BOOLEAN;


                (*  Routinen zum Erfragen von GEM-Parametern  *)
                (*  ========================================  *)

PROCEDURE DeskSize (): Rectangle;

  BEGIN
    RETURN WindowSize (DeskHandle, workSize)
  END DeskSize;

PROCEDURE CharSize (    devHandle: DeviceHandle;
                    VAR boxWidth,
                        boxHeight: CARDINAL);

  VAR   bottom, top:    CARDINAL;
        width      :    INTEGER;
  
  BEGIN
    GetFaceInfo (devHandle, voidC, voidC, bottom, voidC, voidC, voidC, top,
                 width, voidI, voidI, voidI);
    boxWidth := CARDINAL (width);
    boxHeight := top + bottom + 1;
  END CharSize;
  

                                (*  Mauszeiger  *)
                                (*  ==========  *)

PROCEDURE ShowArrow;

  BEGIN
    GrafMouse (arrow, NIL)
  END ShowArrow;

PROCEDURE ShowBee;

  BEGIN
    GrafMouse (bee, NIL)
  END ShowBee;

PROCEDURE HideMouse;

  BEGIN
    GrafMouse (mouseOff, NIL)
  END HideMouse;

PROCEDURE ShowMouse;

  BEGIN
    GrafMouse (mouseOn, NIL)
  END ShowMouse;

                                (*  FormAlert  *)
                                (*  =========  *)

PROCEDURE WrapAlert (VAR s: ARRAY OF CHAR; width: CARDINAL);
  VAR trennIdx,lastIdx,zeilBeg,zeilEnd,len: INTEGER; ok: BOOLEAN;
  CONST stdWidth=29;
  BEGIN
    IF width = 0 THEN width:= stdWidth END;
    len:= Length (s);
    trennIdx:= -1; (* abs. Laufvar. *)
    zeilBeg:= 0; (* Zeilenanfang *)
    REPEAT
      lastIdx:= trennIdx;
      zeilEnd:= PosLen ('|',s,trennIdx+1);
      trennIdx:= PosLen (' ',s,trennIdx+1);
      IF zeilEnd<trennIdx THEN
        trennIdx:= zeilEnd
      END;
      IF trennIdx > (zeilBeg + INTEGER(width)) THEN
        IF lastIdx < zeilBeg THEN
          (* Noch kein Space zum Trennen gefunden -> Zeile brechen *)
          Insert ('|', zeilBeg+INTEGER(width), s, ok); INC (len);
          INC (zeilBeg, width+1);
        ELSE
          s[lastIdx]:= '|';
          zeilBeg:= lastIdx+1;
        END;
        trennIdx:= zeilBeg-1
      ELSIF trennIdx = zeilEnd THEN
        zeilBeg:= zeilEnd+1
      END
    UNTIL trennIdx=len
  END WrapAlert;

(* wird bei FormAlert gar nicht benîtigt:

        PROCEDURE stringIntoCFormat (REF str: ARRAY OF CHAR);
        
          (*$L-*)
          BEGIN
            ASSEMBLER
                MOVE.L  (A7)+,A2        ; Rette RÅckkehraddr.
                MOVE.W  -(A3),D1        ; HIGH(str) -> D1
                MOVE.L  A7,D0           ; Berechne neuen Top of Stack
                SUB.W   D1,D0
                SUBQ.L  #2,D0
                BTST    #0,D0
                BEQ     cont
                SUBQ.L  #1,D0           ; nur grade Stackaddr. erlaubt
        cont
                CMP.L   A3,D0
                BCC     cont2           ; springe, falls kein Stack Overflow
                TRAP    #6
                DC.W    OutOfStack
        cont2
                MOVE.L  D0,A0           ; rette Zeiger auf Stringanfang
                EXG     D0,A7
                MOVE.L  D0,-(A7)        ; orginal Stackaddr. merken
                MOVE.L  -(A3),A1        ; ADR(str) -> A1
                MOVE.L  A0,D2           ; rette Zeiger auf Stringanfang
        loop
                MOVE.B  (A1)+,(A0)+
                DBEQ    D1,loop         ; kopiere bis zum Stringende
                CLR.B   (A0)+           ; und hÑnge #0 als Endezeichen an
                MOVE.L  A2,-(A7)        ; RÅckkehraddr. fÅr RTS auf den Stack
            END;
          END stringIntoCFormat;
          (*$L=*)
*)

PROCEDURE FormAlert (    defBut: CARDINAL;
                     REF str   : ARRAY OF CHAR;
                     VAR retBut: CARDINAL);

  CONST GEMTrap         = 2;
        AESCode         = 200;
        FORM_ALERT      = 52;

  VAR   A_CONTRL: RECORD
                    opcode  : CARDINAL;
                    sintin  : CARDINAL;
                    sintout : CARDINAL;
                    saddrin : CARDINAL;
                    saddrout: CARDINAL
                  END;
        GLOBAL  : RECORD
                    ap_version: INTEGER;
                    ap_count  : INTEGER;
                    ap_id     : INTEGER;
                    ap_private: INTEGER;
                    ap_ptree  : ADDRESS;
                    ap_1resv  : ADDRESS;
                    ap_2resv  : ADDRESS;
                    ap_3resv  : ADDRESS;
                    ap_4resv  : ADDRESS;
                  END;
        INTIN   : INTEGER;
        INTOUT  : INTEGER;
        ADDRIN  : ADDRESS;
        ADDROUT : ADDRESS;
        AESPB   : RECORD
                    contrl : ADDRESS;
                    global : ADDRESS;
                    intin  : ADDRESS;
                    intout : ADDRESS;
                    addrin : ADDRESS;
                    addrout: ADDRESS;
                  END;
                           
  BEGIN
    ASSEMBLER
    
        ;  Init. pb
        ;
        LEA     A_CONTRL(A6), A0
        MOVE.L  A0, AESPB.contrl(A6)
        LEA     GLOBAL(A6), A0
        MOVE.L  A0, AESPB.global(A6)
        LEA     INTIN(A6), A0
        MOVE.L  A0, AESPB.intin(A6)
        LEA     INTOUT(A6), A0
        MOVE.L  A0, AESPB.intout(A6)
        LEA     ADDRIN(A6), A0
        MOVE.L  A0, AESPB.addrin(A6)
        LEA     ADDROUT(A6), A0
        MOVE.L  A0, AESPB.addrout(A6)
        
        ;  calc. input parms
        ;
(* das ist gar nicht nîtig:
        MOVE.L  str(A6), (A3)+
        MOVE.W  str+4(A6), (A3)+
        JSR     stringIntoCFormat   ; schiebe string mit #0 auf den A7-Stack
        MOVE.L  D2, ADDRIN(A6)    ; ADR(astring) steht nach 'stringIn..' in D2
*)
        ;stattdessen:
        MOVE.L  str(A6), ADDRIN(A6) ; ADR(str)
        MOVE.W  defBut(A6), INTIN(A6)
        
        ;  set control record
        ;
        MOVE.W  #FORM_ALERT, A_CONTRL.opcode(A6)
        MOVE.W  #1, A_CONTRL.sintin(A6)
        MOVE.W  #1, A_CONTRL.sintout(A6)
        MOVE.W  #1, A_CONTRL.saddrin(A6)
        CLR.W   A_CONTRL.saddrout(A6)
        
        ;  set global record
        ;
        CLR.W   GLOBAL.ap_id(A6)
        
        ;  call AES
        ;
        LEA     AESPB(A6), A0
        MOVE.L  A0, D1
        MOVE.W  #AESCode, D0
        TRAP    #GEMTrap
        
        ;  restore and calc. output parm.
        ;
        ;nicht mehr nîtig: MOVE.L  (A7), A7    ; String wieder vom Stack entfernen
        MOVE.L  retBut(A6), A1
        MOVE.W  INTOUT(A6), (A1)
    END;
  END FormAlert;
  
PROCEDURE TextStringAddress (idx: CARDINAL): PtrMaxStr;

  BEGIN
    RETURN ResourceAddr (textString, idx)
  END TextStringAddress;
  


                (*  Routinen fÅr den Umgang mit ObjektbÑumen  *)
                (*  ========================================  *)
                
PROCEDURE TreeAddress (idx: CARDINAL): PtrObjTree;

  BEGIN
    RETURN ResourceAddr (treeRsrc, idx)
  END TreeAddress;
  

PROCEDURE ObjectSpaceWithAttrs (tree: PtrObjTree; obj: CARDINAL): Rectangle;

  VAR   space: Rectangle;
        flags: OFlagSet;
        state: OStateSet;
        thick,
        delta: INTEGER;
  
  BEGIN
    SetCurrObjTree (tree, FALSE);
    space := ObjectSpace (obj);
    flags := ObjectFlags (obj);
    state := ObjectState (obj);
    WITH space DO
    
      IF ObjectType (obj) = buttonObj THEN
        thick := -1;
        IF selectExitFlg IN flags THEN DEC (thick) END;
        IF defaultFlg IN flags THEN DEC (thick) END;
      ELSE
        thick := BorderThickness (obj);
      END;
      IF thick < 0 THEN
        x := x + thick; w := w - 2 * thick;
        y := y + thick; h := h - 2 * thick;
      END;
      
      IF thick < 0 THEN delta := (-3) - thick ELSE delta := -3 END;
      IF (delta < 0) AND (outlineObj IN state) THEN
        x := x + delta; w := w - 2 * delta;
        y := y + delta; h := h - 2 * delta;
      END;
      
      IF shadowObj IN state THEN
        w := w + 2 * ABS (thick);
        h := h + 2 * ABS (thick);
      END;
      
    END;
    
    RETURN space;
  END ObjectSpaceWithAttrs;

PROCEDURE AbsObjectSpace (tree: PtrObjTree; obj: CARDINAL): Rectangle;

  VAR   space,
        spaceWithAttrs: Rectangle;
        offset        : Point;

  BEGIN
    spaceWithAttrs := ObjectSpaceWithAttrs (tree, obj);
    space := ObjectSpace (obj);
    offset := ObjectOffset (tree, obj);
    WITH offset DO
      x := x - space.x + spaceWithAttrs.x;
      y := y - space.y + spaceWithAttrs.y;
    END;
    RETURN TransRect (spaceWithAttrs, offset);
  END AbsObjectSpace;

PROCEDURE SetObjStateElem (tree : PtrObjTree; obj: CARDINAL;
                           elem : ObjState;
                           value: BOOLEAN);

  VAR     state   : OStateSet;
  
  BEGIN
    SetCurrObjTree (tree, FALSE);
    state := ObjectState (obj);
    IF value THEN
      INCL (state, elem)
    ELSE
      EXCL (state, elem)
    END;
    SetObjState (obj, state);
  END SetObjStateElem;
        
PROCEDURE ObjectStateElem (tree : PtrObjTree; obj: CARDINAL;
                           elem : ObjState                  ): BOOLEAN;

  VAR   state: OStateSet;

  BEGIN
    SetCurrObjTree (tree, FALSE);
    state := ObjectState (obj);
    RETURN elem IN state
  END ObjectStateElem;

PROCEDURE ToggleObjState (tree  : PtrObjTree; obj: CARDINAL;
                          elem  : ObjState;
                          redraw: BOOLEAN);
                          
  VAR     state           : OStateSet;
  
  BEGIN
    SetCurrObjTree (tree, FALSE);
    state := ObjectState (obj);
    IF elem IN state THEN
      EXCL (state, elem)
    ELSE
      INCL (state, elem)
    END;
    ChangeObjState (tree,obj, AbsObjectSpace (tree, obj), state, redraw);
  END ToggleObjState;
  
PROCEDURE SetObjFlag (tree : PtrObjTree; obj: CARDINAL;
                      elem : ObjFlag;
                      value: BOOLEAN);

  VAR     flags   : OFlagSet;
  
  BEGIN
    SetCurrObjTree (tree, FALSE);
    flags := ObjectFlags (obj);
    IF value THEN
      INCL (flags, elem)
    ELSE
      EXCL (flags, elem)
    END;
    SetObjFlags (obj, flags);
  END SetObjFlag;

PROCEDURE ObjectFlag (tree : PtrObjTree; obj: CARDINAL;
                      elem : ObjFlag                   ): BOOLEAN;

  VAR   flags: OFlagSet;
  
  BEGIN
    SetCurrObjTree (tree, FALSE);
    flags := ObjectFlags (obj);
    RETURN elem IN flags
  END ObjectFlag;

PROCEDURE SetTextString (    tree: PtrObjTree; obj: CARDINAL;
                         REF str : ARRAY OF CHAR);

  BEGIN
    SetCurrObjTree (tree, FALSE);
    AssignTextStrings (obj, setOnly,str, noChange,'',noChange,'');
  END SetTextString;

PROCEDURE GetTextString (    tree: PtrObjTree; obj: CARDINAL;
                         VAR str : ARRAY OF CHAR);

  VAR voidStr : String;
  
  BEGIN
    SetCurrObjTree (tree, FALSE);
    GetTextStrings (obj, str, voidStr,voidStr);
    IF ObjTreeError () THEN str[0]:=0C END;
  END GetTextString;


                (*  Routinen zum Animieren von Dialogboxen  *)
                (*  ======================================  *)

PROCEDURE PrepareBox (    box  : PtrObjTree;
                          orgin: Rectangle;
                      VAR space: Rectangle);

  BEGIN
    MouseInput (TRUE); MouseControl (TRUE); ShowArrow;
    
    space:= FormCenter (box);
    space:= AbsObjectSpace (box, Root);
    FormDial (reserveForm, orgin,space);
    IF orgin.w >= 0 THEN FormDial (growForm, orgin,space) END;
    DrawObject (box,Root,MaxDepth, space);
  END PrepareBox;

PROCEDURE ReleaseBox (box   : PtrObjTree;
                      orgin,
                      space : Rectangle);

  BEGIN
    IF orgin.w >= 0 THEN FormDial (shrinkForm, orgin,space) END;
    FormDial (freeForm, orgin,space);
    
    MouseControl (FALSE); MouseInput (FALSE);
  END ReleaseBox;

PROCEDURE DoSimpleBox (    box    : PtrObjTree;
                           orgin  : Rectangle;
                       VAR exitBut: CARDINAL);

  VAR     space   : Rectangle;
  
  BEGIN
    PrepareBox (box, orgin, space);
    FormDo (box,Root, exitBut);
    ASSEMBLER
        MOVE.L  exitBut(A6),A0
        ANDI    #$7FFF,(A0)
    END;
    SetCurrObjTree (box, FALSE);
    ToggleObjState (box,exitBut, selectObj,TRUE);
    ReleaseBox (box, orgin, space);
  END DoSimpleBox;


        (*  advanced dialog managment  *)

PROCEDURE DeselectButton (tree: PtrObjTree; button: CARDINAL);

  BEGIN
    ToggleObjState (tree, button, selectObj, TRUE);
  END DeselectButton;

PROCEDURE ToggleSelectBox (tree: PtrObjTree; selectBox: CARDINAL);

  BEGIN
    ToggleObjState (tree, selectBox, selectObj, TRUE);
  END ToggleSelectBox;

PROCEDURE ToggleCheckBox (tree: PtrObjTree; checkBox: CARDINAL);

  BEGIN
    ToggleObjState (tree, checkBox, checkObj, TRUE);
  END ToggleCheckBox;

PROCEDURE ToggleCheckPlus (    tree    : PtrObjTree;
                               checkBox: CARDINAL;
                           REF fellows : ARRAY OF CARDINAL);

  VAR   i: CARDINAL;
  
  BEGIN
    ToggleCheckBox (tree, checkBox);
    FOR i := 0 TO HIGH (fellows) DO
      ToggleObjState (tree, fellows[i], disableObj, TRUE)
    END;
  END ToggleCheckPlus;

PROCEDURE SetGetBoxCard (    tree : PtrObjTree;
                             obj  : CARDINAL;
                             mode : SetGetMode;
                         VAR value: CARDINAL);
                         
  VAR   lValue: LONGCARD;

  BEGIN
    lValue := LONG (value);
    SetGetBoxLCard (tree, obj, mode, lValue);
    value := SHORT (lValue);
  END SetGetBoxCard;
  
PROCEDURE SetGetBoxLCard (    tree : PtrObjTree;
                              obj  : CARDINAL;
                              mode : SetGetMode;
                          VAR value: LONGCARD);

  VAR   str: String;
        pos: CARDINAL;

  BEGIN
    IF mode = setValue THEN
      SetTextString (tree, obj, CardToStr (value, 0));
    ELSE
      GetTextString (tree, obj, str);
      pos := 0;
      value := StrToLCard (str, pos, voidO);
    END;
  END SetGetBoxLCard;
  

PROCEDURE SetGetBoxInt (    tree : PtrObjTree;
                            obj  : CARDINAL;
                            mode : SetGetMode;
                        VAR value: INTEGER);
                        
  VAR   lValue: LONGINT;

  BEGIN
    lValue := LONG (value);
    SetGetBoxLInt (tree, obj, mode, lValue);
    value := SHORT (lValue);
  END SetGetBoxInt;
  
PROCEDURE SetGetBoxLInt (    tree : PtrObjTree;
                             obj  : CARDINAL;
                             mode : SetGetMode;
                         VAR value: LONGINT);

  VAR   str: String;
        pos: CARDINAL;

  BEGIN
    IF mode = setValue THEN
      SetTextString (tree, obj, IntToStr (value, 0));
    ELSE
      GetTextString (tree, obj, str);
      pos := 0;
      value := StrToLInt (str, pos, voidO);
    END;
  END SetGetBoxLInt;
  
PROCEDURE SetGetBoxStr (    tree : PtrObjTree;
                            obj  : CARDINAL;
                            mode : SetGetMode;
                        VAR str  : ARRAY OF CHAR);

  BEGIN
    IF mode = setValue THEN SetTextString (tree, obj, str)
    ELSE GetTextString (tree, obj, str) END;
  END SetGetBoxStr;
  

PROCEDURE SetGetBoxState (    tree : PtrObjTree;
                              obj  : CARDINAL;
                              mode : SetGetMode;
                              state: ObjState;
                          VAR value: BOOLEAN);

  BEGIN
    IF mode = setValue THEN SetObjStateElem (tree, obj, state, value)
    ELSE value := ObjectStateElem (tree, obj, state) END;
  END SetGetBoxState;
  

PROCEDURE SetGetBoxEnum (    tree : PtrObjTree;
                             REF refs : ARRAY OF ObjEnumRef;
                             mode : SetGetMode;
                         VAR value: WORD);

  VAR   i: CARDINAL;

  BEGIN
    FOR i := 0 TO HIGH (refs) DO
      IF mode = setValue THEN
        SetObjStateElem (tree, refs[i].obj, selectObj, refs[i].value = value)
      ELSE
        IF ObjectStateElem (tree, refs[i].obj, selectObj) THEN
          value := refs[i].value
        END;
      END;
    END;
  END SetGetBoxEnum;
  


                (*  Routinen fÅr das Desktop- und Wdw-Managment  *)
                (*  ===========================================  *)
                
PROCEDURE ForceDeskRedraw;
  
  BEGIN
    FormDial (freeForm, Rect (0,0,0,0), WindowSize (DeskHandle, workSize));
  END ForceDeskRedraw;
  

PROCEDURE DrawObjInWdw (tree  : PtrObjTree; obj: CARDINAL;
                        drawBg: BOOLEAN;
                        window: CARDINAL);

  VAR     frame, space   : Rectangle;
  
  BEGIN
        (*  move upper left corner of the root object in the
         *  upper left corner of the window, if it is not the desk.
         *)
         
    SetCurrObjTree (tree, FALSE);
    IF window # DeskHandle THEN
      SetObjSpace (Root, TransRect (ObjectSpace (Root),
                                    MinPoint (WindowSize (window, workSize))))
    END;
    
    space := AbsObjectSpace (tree, obj);
    IF drawBg THEN obj := Root END;
    
    frame := WindowRectList (window, firstElem);
    WHILE frame.w # 0 DO
    
      frame := ClipRect (frame, space);
      IF frame.w # 0 THEN DrawObject (tree,obj, MaxDepth, frame) END;
      frame := WindowRectList (window, nextElem);
      
    END;
  END DrawObjInWdw;


END EasyGEM0.
(* $FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$00003E53$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$000013AA$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0$FFF6B3E0Ä$0000086CT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$0000417A$00004162$00004170$0000418D$00004181$00004219$000008C6$0000086C$00000806$0000086C$000008C3$00000858$0000086C$FFEDE5B0$0000417A$0000418D¥ÄÅ*)

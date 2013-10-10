MODULE GagACC;
(*$E MAC*)

(*
 * Dies ist eine etwas komplexeres GEM- und Accessory-Demo.
 * Es zeigt auch die Anwendung von "FormDo" sowie dem "Redraw"
 * von Fenstern.
 *
 * Es ist eine Art Wecker, der zehn Minuten vor Erreichen einer
 * bestimmbaren Tageszeit jede Minute eine Meldung anzeigt.
 *
 * Zuvor muû die GEM-Resource-Datei "GAG.RSC" mit dem NRSC.PRG
 * geladen und gleich wieder gespeichert werden, um das benîtigte
 * Definitionsmodul "GAG.D" mit den Object-Konstanten zu erhalten.
 * Dann kînnen die Module Åbersetzt und gelinkt werden und "GAGACC.ACC"
 * mit "GAG.RSC" als Accessory auf die Bootdisk kopiert werden.
 *
 * Das Programm wurde von Hannes Krohn wÑhrend der CeBIT '90
 * programmiert.
 *)

IMPORT Gag;

FROM AESEvents          IMPORT  accClose,       accOpen,        Event,
                                EventSet,       MessageBuffer,  MultiEvent,
                                MessageEvent,   RectEnterMode,  windRedraw;
FROM AESForms           IMPORT  FormAlert,      FormCenter,     FormDial,
                                FormDialMode,   FormDo;
FROM AESGraphics        IMPORT  GrafMouse,      MouseForm;
FROM AESMenus           IMPORT  RegisterAcc;
FROM AESObjects         IMPORT  DrawObject;
FROM AESResources       IMPORT  LoadResource,   ResourceAddr,   ResourcePart;
FROM AESWindows         IMPORT  CalcWindow,     CloseWindow,    CreateWindow,
                                DeleteWindow,   NoWindow,       OpenWindow,
                                RListMode,      WCalcMode,      WElementSet,
                                UpdateWindow,   WindowRectList;
FROM Clock              IMPORT  CurrentTime;
FROM PrgCtrl            IMPORT  Accessory;
FROM GEMEnv             IMPORT  InitApplication,ExitApplication,GemError;
FROM GEMGlobals         IMPORT  GemChar,        MButtonSet,     PtrObjTree,
                                PtrTEdInfo,     Root,           MaxDepth,
                                SpecialKeySet;
FROM GrafBase           IMPORT  BitsPerWord,    ClipRect,       Point,
                                Rect,           Rectangle,      WordBitSet;
FROM MOSGlobals         IMPORT  Time;
FROM StrConv            IMPORT  CardToStr,      NumToStr,       StrToCard;
FROM Strings            IMPORT  Append,         Assign,         Concat,
                                Copy,           Split,          Empty;
FROM SYSTEM             IMPORT  ADR;

PROCEDURE SelectObj (tree : PtrObjTree; obj : CARDINAL; sel : BOOLEAN);
VAR
        state : WordBitSet;
BEGIN
  state := tree^[obj].state;
  IF sel THEN
    INCL (state, b0)
  ELSE
    EXCL (state, b0)
  END;
  tree^[obj].state := state;
END SelectObj;

PROCEDURE ObjSelected (tree : PtrObjTree; obj : CARDINAL) : BOOLEAN;
BEGIN
  RETURN b0 IN tree^[obj].state
END ObjSelected;

VAR
        success : BOOLEAN;
        msgBuf : MessageBuffer;
        mouseLoc : Point;
        buttons : MButtonSet;
        keyState : SpecialKeySet;
        key : GemChar;
        doneClicks : CARDINAL;
        occuredEvents : EventSet;
        fooC : CARDINAL;
        tree : PtrObjTree;
        open : BOOLEAN;
        wHandle : CARDINAL;
        windSpace : Rectangle;
        time : LONGCARD;
        r : Rectangle;
        t : Time;
        stage : CARDINAL;
        dispText : ARRAY [1..30] OF CHAR;
        title : ARRAY [1..10] OF CHAR;
        active : BOOLEAN;
        accId : CARDINAL;
        msgTime : Time;
        msgPre : CARDINAL;
        
PROCEDURE Config;
VAR
        tree : PtrObjTree;
        resButton : CARDINAL;
        diagRect : Rectangle;
        hStr, mStr : ARRAY [0..2] OF CHAR;
        allStr : ARRAY [0..4] OF CHAR;
        tedPtr : PtrTEdInfo;
        fooC : CARDINAL;
        
BEGIN
  tree := ResourceAddr (treeRsrc, Foset);
  
  (* Buttons selektieren, Werte einsetzen *)
  Assign (NumToStr (msgPre, 10, 0, '0'), hStr, success);
  tedPtr := tree^[Ftpre].spec.more;
  Assign (hStr, tedPtr^.textPtr^, success);
  
  Assign (NumToStr (msgTime.hour, 10, 0, '0'), hStr, success);
  Assign (NumToStr (msgTime.minute, 10, 0, '0'), mStr, success);
  tedPtr := tree^[Fttime].spec.more;
  Concat (hStr, mStr, tedPtr^.textPtr^, success);
  SelectObj (tree, Btan, active);
  SelectObj (tree, Btaus, ~active);
  SelectObj (tree, Btfertig, FALSE);
  
  (* Dialog animieren *)
  diagRect := FormCenter (tree);
  FormDial (reserveForm, diagRect, diagRect);
  GrafMouse (mouseOff, NIL);
  DrawObject (tree, Root, MaxDepth, diagRect);
  GrafMouse (mouseOn, NIL);
  FormDo (tree, Root, resButton);
  FormDial (freeForm, diagRect, diagRect);
  
  (* Werte auslesen *)
  active := ObjSelected (tree, Btan);
  Assign (tedPtr^.textPtr^, allStr, success);
  WHILE LENGTH (allStr) < 4 DO
    Append ('0', allStr, success)
  END;
  Split (allStr, 2, hStr, mStr, success);
  fooC := 0;
  msgTime.hour := StrToCard (hStr, fooC, success);
  fooC := 0;
  msgTime.minute := StrToCard (mStr, fooC, success);
  tedPtr := tree^[Ftpre].spec.more;
  fooC := 0;
  msgPre := StrToCard (tedPtr^.textPtr^, fooC, success);
  IF open AND ~active THEN
    CloseWindow (wHandle);
    DeleteWindow (wHandle);
    open := FALSE;
    stage := 0
  END
END Config;

PROCEDURE SetText (text : ARRAY OF CHAR);
VAR
        boxSpace, textSpace : Rectangle;
        success : BOOLEAN;
BEGIN
  Assign (text, dispText, success);
  boxSpace := tree^[Root].space;
  textSpace := tree^[Text].space;
  textSpace.w := 8 * LENGTH (text);
  boxSpace.w := 2 * textSpace.x + textSpace.w;
  boxSpace.h := 2 * textSpace.y + textSpace.h;
  tree^[Root].space := boxSpace;
  tree^[Text].space := textSpace;
  tree^[Text].spec.more := ADR (dispText);
  boxSpace := FormCenter (tree);
  windSpace := CalcWindow (calcBorder, WElementSet{}, boxSpace);
  CreateWindow (WElementSet{}, windSpace, wHandle);
  IF wHandle # NoWindow THEN
    OpenWindow (wHandle, windSpace);
  END
END SetText;

BEGIN
  InitApplication (success);
  IF success THEN
    IF NOT Accessory() THEN
      FormAlert (1, "[0][GAGACC lÑuft nur |als Accessory!][OK]", fooC);
      ExitApplication;
      RETURN
    END;
    LoadResource ("GAG.RSC");
    IF GemError () THEN
      FormAlert (1, "[0][Accessory GAGACC: |GAG.RSC fehlt!][OK]", fooC);
      success:= FALSE
    ELSE
      tree := ResourceAddr (treeRsrc, Box);
      Assign ("  GagAcc", title, success);
      RegisterAcc (ADR (title), accId, success)
    END
  END;
  IF ~success THEN
    LOOP
      MessageEvent (msgBuf)
    END
  ELSE
    msgTime.hour := 17;
    msgTime.minute := 50;
    msgPre := 10;
    time := 8000;
    open := FALSE;
    stage := 0;
    active := TRUE;
    LOOP
      MultiEvent (EventSet {message, timer},
                            0, MButtonSet{}, MButtonSet{},
                            lookForEntry, Rect (0,0,0,0),
                            lookForEntry, Rect (0,0,0,0),
                            msgBuf,
                            time,
                            mouseLoc, buttons,
                            keyState, key,
                            doneClicks,
                            occuredEvents);
      UpdateWindow (TRUE);
      IF (timer IN occuredEvents) AND active THEN
        (* Action ! *)
        t := CurrentTime ();
        
        (* Um 17.50 h Warnung! *)
        IF (((t.hour = msgTime.hour) AND (t.minute >= msgTime.minute))
            OR (t.hour > msgTime.hour))
        AND (stage = 0) THEN
          IF ~open THEN
            (* Warnung ausgeben *)
            dispText := "Noch ";
            Append (CardToStr (msgPre, 0), dispText, success);
            IF msgPre = 1 THEN
              Append (" Minute!", dispText, success);
            ELSE
              Append (" Minuten!", dispText, success);
            END;
            SetText (dispText);
          ELSE
            IF wHandle # NoWindow THEN
              CloseWindow (wHandle);
              DeleteWindow (wHandle);
              INC (stage);
              IF msgTime.minute >= (60 - msgPre) THEN
                INC (msgTime.hour);
                DEC (msgTime.minute, (60 - msgPre))
              ELSE
                INC (msgTime.minute, msgPre)
              END
            END
          END;
          open := ~open
        END;
            
        (* Um 18.00h blinken *)
        IF (((t.hour = msgTime.hour) AND (t.minute >= msgTime.minute)) OR
            (t.hour > msgTime.hour)) AND (stage = 1) THEN
          IF open THEN
            IF wHandle # NoWindow THEN
              CloseWindow (wHandle);
              DeleteWindow (wHandle);
            END
          ELSE
            (* Fenster îffnen *)
            SetText ("Jetzt ist aber Schluû!");
          END;
          open := ~open
        END
      ELSIF message IN occuredEvents THEN
        WITH msgBuf DO
          CASE msgType OF
            accClose : IF (aClsMId = accId) AND open THEN
                         (* Fenster wurde bereits geschlossen
                           CloseWindow (wHandle);
                         *)
                         DeleteWindow (wHandle);
                         open := FALSE;
                         stage := 1
                       END|
            accOpen : IF aOpnMId = accId THEN
                        Config;
                      END|
            windRedraw : IF rdrwHdl = wHandle THEN
                           GrafMouse (mouseOff, NIL);
                           r := WindowRectList (wHandle, firstElem);
                           WHILE (r.w # 0) OR (r.h # 0) DO
                             r := ClipRect (r, rdrwFrame);
                             IF (r.w # 0) AND (r.h # 0) THEN
                               DrawObject (tree, Root, MaxDepth, r)
                             END;
                             r := WindowRectList (wHandle, nextElem);
                           END;
                           GrafMouse (mouseOn, NIL);
                         END
          ELSE
            (* ignorieren *)
          END
        END
      END;
      UpdateWindow (FALSE)
    END (* LOOP *)
  END;
END GagACC.

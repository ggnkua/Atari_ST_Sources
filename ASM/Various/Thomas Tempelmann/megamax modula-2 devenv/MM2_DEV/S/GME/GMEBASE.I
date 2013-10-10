IMPLEMENTATION MODULE GMEBase;
(*$Y+*)
(*$R-*)
(*$Z+*)

(*    ACHTUNG! Dies Modul darf keine anderen GME-Module importieren! *)

(* (C) 1990 by Johannes Leckebusch
   Stand: 12. 12. 90
*)

(* !JL 11.12.90: "Puffer kann nicht gelîscht werden.107" entfernt! *)
(*  TT 12.12.90: ConfigPuffer-Init nach GMEKernel verlegt
                 DeleteTail optimiert
    TT 13.12.90: Init: mit Aggregat; InitAES: Window wg. ACC-Redraw geîffnet;
                 "REF" bei einigen String-Parametern eingesetzt.
    TT 18.12.90: Alert-Meldungen mit "WrapAlert"
*)


(* Zusammenziehung von:
   EditConst, EditTypes, KeyBase, ScreenBase, EditBefehle, EditBuffer,
   EditBase.
*)

(*    ACHTUNG! Dies Modul darf keine anderen GME-Module importieren! *)

FROM SYSTEM  IMPORT ADDRESS, ADR, CAST, TSIZE;
FROM SysUtil0 IMPORT Byte, Cardinal;
FROM SysUtil1 IMPORT SuperPoke, SuperPeek (*, Byte, Cardinal*);

FROM BIOS IMPORT Device, BConStat, BConIn, KBShiftBits, KBShifts;

FROM Convert IMPORT ConvCard;
IMPORT Directory, FileNames;

FROM AESWindows IMPORT CreateWindow, WElementSet, OpenWindow;
FROM AESMisc IMPORT SelectFile;
FROM GEMGlobals IMPORT MouseButton, MButtonSet, FillType;
FROM GrafBase IMPORT Point, Rectangle, WritingMode;
FROM VDIAttributes IMPORT SetWritingMode, SetFillType, SetFillIndex,
  SetLineType, SetFillPerimeter;

FROM VDIOutputs IMPORT Bar, FillRectangle;

FROM XBIOS IMPORT ConfigureCursor;

IMPORT EasyGEM0;

FROM VDIEscapes IMPORT CursorText, CursorHome, EraseToEndOfScreen,
                       EraseToEndOfLine, LocateCursor, GetCursorLocation,
                       ReverseVideoOn, ReverseVideoOff, DisplayCursor,
                       RemoveCursor, GetCharCells;

FROM VDIInputs IMPORT GetMouseState;

FROM VDIControls IMPORT SetClipping, DisableClipping;

FROM AESGraphics IMPORT MouseForm, (*arrow, bee, flatHand,*)
  GrafMouse;

FROM AESForms IMPORT FormAlert;

FROM GEMEnv IMPORT DeviceHandle, InitGem, RC, GrafHandle, ExitGem,
  CurrGemHandle;

FROM AESWindows IMPORT UpdateWindow;

FROM Strings IMPORT Assign, Append, Insert, Length, Pos;

FROM GEMDOS IMPORT GetDrv, GetPath, Version;

(*
IMPORT Storage;
FROM Storage IMPORT Inconsistent;
*)
IMPORT Granule;

IMPORT FastStrings;

(*    ACHTUNG! Dies Modul darf keine anderen GME-Module importieren! *)


(* KeyBase *)

PROCEDURE KeyReady(): BOOLEAN;
BEGIN RETURN BConStat (CON);
END KeyReady;

PROCEDURE KillKeyInput;
VAR     Long:   LONGCARD;
BEGIN WHILE BConStat (CON) DO Long := BConIn (CON); END;
END KillKeyInput;


PROCEDURE Init;
CONST tabConst = eineScanTabelle {
  TEsc,T1,T2,T3,T4,T5,T6,T7,T8,T9,T0,Tsz,TApo,TBackspace,TTab,Tq,Tw,Te,
  Tr,Tt,Tz,Tu,Ti,To,Tp,Tue,TPlus,TRet,NoKey,Ta,Ts,Td,Tf,Tg,Th,Tj,Tk,Tl,
  Toe,Tae,TNum,NoKey,TTild,Ty,Tx,Tc,Tv,Tb,Tn,Tm,TKomma,TPunkt,TMinus,NoKey,
  NoKey,NoKey,TLeer,NoKey,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,NoKey,NoKey,
  CHome,CUp,NoKey,NMinus,CLeft,NoKey,CRight,NPlus,NoKey,CDown,NoKey,CInsert,
  TDel,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,NoKey,NoKey,TGr,CUndo,CHelp,NLeftp,
  NRightp,NSlash,NAsterix,N7,N8,N9,N4,N5,N6,N1,N2,N3,N0,NPoint,NEnter,
  CLeft,CRight,NoKey,NoKey,CHome,T1,T2,T3,T4,T5,T6,T7,T8,T9,T0,Tsz,TApo};
BEGIN
  ScanTab:= tabConst;
END Init;

PROCEDURE ReadKey (VAR k: einKey; VAR s: einStatus);

VAR     Long:           LONGCARD;
        L, H:           CARDINAL;
        kstatus:        CARDINAL;
        sc:             CARDINAL;
        str:            ARRAY [0..10] OF CHAR;
BEGIN
  LOOP
    IF BConStat (CON) THEN
      Long := BConIn (CON);
      (* L := SHORT (Long MOD 65536); *)
      H := SHORT (Long DIV 65536);
      sc := H MOD 256;
      kstatus := H DIV 256;
      IF ODD (kstatus) THEN
        kstatus := kstatus DIV 2; INC (kstatus);
      ELSE
        kstatus := kstatus DIV 2;
      END;
      s := CAST (einStatus, kstatus);
      
      IF (sc >= MinScanCode) & (sc <= MaxScanCode) THEN
        k := ScanTab [sc];
      ELSE
        k := KeyError;
      END;
      
      EXIT;
    END (* IF *);
  END (* LOOP *);
END ReadKey;

(* Tastatur so initialisieren, daû KBShifts mit abgefragt werden *)
(* Das folgende stammt von Peter Hellinger *)

CONST   TastenKlick     = 0;    (* gesetzt = Tastaturklick ein  *)
        TastenRepeat    = 1;    (* gesetzt = Wiederholung ein   *)
        Glocke          = 2;    (* Ding-Dong bei Ctrl-G         *)
        Kbshift         = 3;    (* Tastaturzustand              *)

(* Man sieht: Mit conterm kann man allerlei Geschichten machen.
 * Andererseits, es gibt ja auch noch das Kontrollfeld...
 *)

TYPE    ByteSet         = SET OF [0..7];
                          (* Damit wir nachher elegant mit INCL und
                           * EXCL das Bit setzten bzw. lîschen kînnen.
                           *)

CONST   CConTerm =      0484HL;

VAR     ConTerm (*[0484H]*)  : ByteSet; (* Sysvar, ist nur ein Byte! *)
        (*stack           : ADDRESS; (* Stackadresse fÅr GEMDOS.Super *)*)
        BitGesetzt      : BOOLEAN; (* Flag, ob Kbshift gesetzt *)

PROCEDURE TastInit;
BEGIN
 BitGesetzt:= FALSE;
 (* Super (stack); (* Zugriff nur im Supervisor-Modus! *) *)
 (* Erstmal abfragen, ob das Bit nicht schon gesetzt ist. Es kînnte sich
  * bereits ein anderes Programm (ACC etc.) dieser Methode bedienen, dem
  * wir bei einem bedingungslosem TastReset ja den "Boden unter den
  * FÅûen" wegziehen wÅrden...
  *)
 SuperPeek (CConTerm, ConTerm);
 IF Kbshift IN ConTerm THEN
  BitGesetzt:= TRUE;
 ELSE
  INCL (ConTerm, Kbshift); (* Bit setzen *)
 END;
 SuperPoke (CConTerm, ConTerm);
END TastInit;

PROCEDURE TastReset;
BEGIN
 IF NOT BitGesetzt THEN  (* Nur Reset wenn vorher nicht gesetzt! *)
  EXCL (ConTerm, Kbshift); (* Bit lîschen *)
 SuperPoke (CConTerm, ConTerm);
 END;
END TastReset;

(* ScreenBase *)

CONST   ceditor =       ">>> GME: Golem Mini Editor 1.2 <<<";

CONST
  IFMaus =              TRUE;
  cTrace =              FALSE;

VAR
  ok:                   BOOLEAN;
  CursorAn:             BOOLEAN;
  CursorBlink:          BOOLEAN;
  alteBlinkrate:        INTEGER;
  altesAttribut:        INTEGER;

VAR
  Status:               INTEGER;
  MausIstSichtbar:      BOOLEAN;
  oldx, oldy:           CARDINAL;
  OldKnoepfe:           ButtonSet;

  topbox:               Rectangle;

PROCEDURE TopBox;
BEGIN
  SetFillPerimeter (ScreenHandle, FALSE);
  WITH topbox DO
    x := 0; y := CharHeight + 3;
    w := ScreenWidth; h := CharHeight - 3;
  END (* WITH *);
  SetFillType (ScreenHandle, hollowFill);
  FillRectangle (ScreenHandle, topbox);
  
  SetFillPerimeter (ScreenHandle, TRUE);
  WITH topbox DO
    (*x := 1; *)y := CharHeight + 4;
    (*w := ScreenWidth - 2;*) h := CharHeight - 4;
  END (* WITH *);
  SetFillType (ScreenHandle, dottPattern);
  SetFillIndex (ScreenHandle, 2);
  Bar (ScreenHandle, topbox);
END TopBox;

PROCEDURE GetVersion (VAR version: ARRAY OF CHAR);
BEGIN Assign (ceditor, version, ok);
END GetVersion;

(* ******************** Cursorsteuerung ******************** *)

PROCEDURE WrapOff;
VAR
  p:                    ARRAY [0..1] OF CHAR;

BEGIN
  p [0] := escape; p [1] := 'w';
  CursorText (ScreenHandle, p);
END WrapOff;


PROCEDURE WrapOn;
VAR     p:      ARRAY [0..1] OF CHAR;
BEGIN
  p [0] := escape; p [1] := 'v';
  CursorText (ScreenHandle, p);
END WrapOn;


PROCEDURE WriteChar (c: CHAR);
BEGIN
  MausAus;
  CursorText (ScreenHandle, c);
END WriteChar;

PROCEDURE WriteLine (REF s: ARRAY OF CHAR);
BEGIN
  MausAus;
  CursorText (ScreenHandle, s);
END WriteLine;

PROCEDURE WriteConst (REF s: ARRAY OF CHAR);
BEGIN WriteLine (s); END WriteConst;

PROCEDURE Trace (REF s: ARRAY OF CHAR);
BEGIN
  IF cTrace THEN
    WriteLn; WriteLine (s);
  END;
END Trace;

PROCEDURE WhereXY (VAR x, y: CARDINAL);
BEGIN
  GetCursorLocation (ScreenHandle, x, y);
END WhereXY;

PROCEDURE GotoXY (x0, y0: CARDINAL);
VAR (*$Reg*)x,(*$Reg*)y: CARDINAL;
BEGIN
  x:= x0;
  y:= y0;
  (* Boeser GEM-Fehler: Absturz bei illegalen x/y-Werten: *)
  INC (x);
  IF x > CharsInLine THEN x := CharsInLine; END;
  IF y > LinesOnScreen THEN y := LinesOnScreen; END;
  INC (y, 3); (* LinesOnScreen wurde in diesem Modul um 3 reduziert!!! *)
  LocateCursor (ScreenHandle, x, y);
  IF ~CursorAn THEN
    (*CursorEin;*)
    
    WriteChar (escape); WriteChar ("f");
    (*CursorAn := TRUE;
    *)
  END (* IF *);
END GotoXY;

PROCEDURE CursorEin;
VAR     x, y:   CARDINAL;
        dummy:  INTEGER;
BEGIN
  IF ~CursorAn THEN
    MausAus;
    IF ~CursorBlink THEN
      dummy := ConfigureCursor (2, alteBlinkrate);
      CursorBlink := TRUE;
    END;
    WriteChar (escape); WriteChar ("e");
    CursorAn := TRUE;
  END;
END CursorEin;

PROCEDURE CursorStumm;
VAR     d:      INTEGER;
        dummy:  INTEGER;
BEGIN
  IF CursorBlink THEN
    d := ConfigureCursor (0, -1);
    d := ConfigureCursor (3, -1); CursorBlink := FALSE;
    d := ConfigureCursor (1, -1); CursorAn := TRUE;
  END;
END CursorStumm;

PROCEDURE CursorSchnell;
VAR     d:      INTEGER;
        x, y:   CARDINAL;
        dummy:  INTEGER;
BEGIN
  IF ~CursorAn THEN CursorEin; END;
  d := ConfigureCursor (2, 10); CursorBlink := TRUE;
END CursorSchnell;

PROCEDURE CursorAus;
VAR     d:      INTEGER;
        dummy:  INTEGER;
BEGIN
  IF CursorAn THEN
    WriteChar (escape); WriteChar ("f");
    CursorAn := FALSE;
  END;
END CursorAus;

PROCEDURE LoescheZeile;
BEGIN
  MausAus; EraseToEndOfLine (ScreenHandle);
END LoescheZeile;

PROCEDURE LoescheBild;
BEGIN
  MausAus;
  GotoXY (0, 0);
  EraseToEndOfScreen (ScreenHandle);
END LoescheBild;

PROCEDURE LoescheEndeBild;
BEGIN
  MausAus; EraseToEndOfScreen (ScreenHandle);
END LoescheEndeBild;

PROCEDURE HighLight;
BEGIN
  ReverseVideoOn (ScreenHandle);
END HighLight;

PROCEDURE Normal;
BEGIN
  ReverseVideoOff (ScreenHandle);
END Normal;

PROCEDURE WriteLn;
BEGIN
  WriteChar (cr); WriteChar (lf);
END WriteLn;

PROCEDURE InsertLn;
BEGIN
  WriteChar (escape); WriteChar (lineins);
END InsertLn;

PROCEDURE DeleteLn;
BEGIN
  WriteChar (escape); WriteChar (linedel);
END DeleteLn;

(* ************************ Maussteuerung ******************* *)

PROCEDURE MausPos (VAR x, y: CARDINAL; VAR bewegt: BOOLEAN;
                   VAR Knoepfe: ButtonSet);
VAR     iStatus, count, count2: INTEGER;
        position:               Point;
        buttons:                MButtonSet;
BEGIN
  IF (x # oldx) OR (y # oldy) THEN
    MausEin; (*DisplayCursor (ScreenHandle, x, y);*)
  END;
  (* GetMouseState (ScreenHandle, iStatus, x, y); *)
  GetMouseState (ScreenHandle, position, buttons);
  (*<TDI Knoepfe := ButtonSet (iStatus); TDI>*)
  (*<MM2 *) Knoepfe := CAST (ButtonSet, buttons); (* MM2> *)

  x := position.x; y := position.y;
  IF (x # oldx) OR (y # oldy) OR (Knoepfe # OldKnoepfe) THEN
    bewegt := TRUE; oldx := x; oldy := y; OldKnoepfe := Knoepfe;
  ELSE bewegt := FALSE;
  END (* IF *);
  
  IF bewegt THEN MausEin; END;
END MausPos;

VAR     StartX, StartY, OldX, OldY:     INTEGER;

PROCEDURE Box (sx, sy, ex, ey: INTEGER);
(* VAR     pxy:    PxyArrayType; *)
VAR     rect:   Rectangle;
BEGIN
  WITH rect DO
    x := sx; y := sy; w := ex - sx; h := ey - sy;
  END (* WITH *);
  MausAus;
  Bar (ScreenHandle, rect);
  MausEin;
END Box;

PROCEDURE StartBox (x, y: INTEGER);
VAR m:          INTEGER;
    (* p:          PxyArrayType; *)
    rect:       Rectangle;
BEGIN
  SetWritingMode (ScreenHandle, reverseWrt);

  (* Warum geht das nicht: ??? *)
  SetFillType (ScreenHandle, hollowFill);
  DisableClipping (ScreenHandle);
  StartX := x; StartY := y;
  OldX := x + 1; OldY := y + 1;
  Box (StartX, StartY, OldX, OldY);
END StartBox;

PROCEDURE GummiBox (x, y: INTEGER);
BEGIN
  IF (x # OldX) OR (y # OldY) THEN
    Box (StartX, StartY, OldX, OldY);
    Box (StartX, StartY, x, y);
    OldX := x; OldY := y;
  END (* IF *);
END GummiBox;

PROCEDURE LoeschBox;
BEGIN
  Box (StartX, StartY, OldX, OldY);
END LoeschBox;

PROCEDURE MausDoppel (VAR x, y: CARDINAL; VAR bewegt: BOOLEAN;
                      VAR Knoepfe: ButtonSet);
VAR     count:                          CARDINAL;
        oldbutton:                      ButtonSet;
BEGIN
  MausPos (x, y, bewegt, Knoepfe); (* Need actual x, y *)
  StartBox (x, y);
  count := 0; (* Entprellphase *)
  REPEAT (* Mausknopf loslassen bzw. GEM-Entprellung *)
    MausPos (x, y, bewegt, Knoepfe);
    INC (count);
    IF Knoepfe # ButtonSet {} THEN
      GummiBox (x, y); count := 0;
    END (* IF Knopf noch nicht losgelassen *);
    (* Knopf mindestens 30 Takte offen *)
  UNTIL (Knoepfe = ButtonSet {}) & (count > 30);
  LoeschBox;
  count := 0;
  REPEAT (* zweiten Klick erkennen oder RETURN nach 300 Takten *)
    MausPos (x, y, bewegt, Knoepfe);
    INC(count);
  UNTIL (Knoepfe # ButtonSet {}) OR (count > 300);
END MausDoppel;

VAR     MausForm:       MouseForm;

PROCEDURE MausEin;
BEGIN
  CursorStumm;
  IF ~MausIstSichtbar THEN
    EasyGEM0.ShowMouse;
    MausIstSichtbar := TRUE;
  END;
  IF MausForm # arrow THEN
    MausForm := arrow;
    GrafMouse (MausForm, NIL);
  END;
END MausEin;

PROCEDURE MausBusy;
BEGIN
  CursorStumm;
  IF ~MausIstSichtbar THEN
    EasyGEM0.ShowMouse;
    MausIstSichtbar := TRUE;
  END;
  IF MausForm # bee THEN
    MausForm := bee;
    GrafMouse (MausForm, NIL);
  END;
END MausBusy;

PROCEDURE MausAus;
BEGIN
  IF MausIstSichtbar THEN
    EasyGEM0.HideMouse;
    MausIstSichtbar := FALSE;
  END;
END MausAus;

PROCEDURE Nachricht (REF m: ARRAY OF CHAR);
VAR     alert:  ARRAY [0..199] OF CHAR;
        i:      CARDINAL;
        dummy:  LONGCARD;
BEGIN
  IF IFMaus THEN
    CursorAus;
    Assign (m, alert, ok);
    EasyGEM0.WrapAlert (alert, 0);
    Insert ('[3][', 0, alert, ok);
    Append ('][ OK ]', alert, ok);
    MausEin;
    FormAlert (1, alert, i);
    CursorEin;
  END (* IF Maus *);
END Nachricht;

PROCEDURE FrageJaNein (default: CARDINAL; m: ARRAY OF CHAR): BOOLEAN;
TYPE    CharSet = SET OF CHAR;
VAR     alert:  ARRAY [0..199] OF CHAR;
        dummy:  CHAR;
        ok:     BOOLEAN;
        retBut: CARDINAL;
BEGIN
  IF IFMaus THEN
    CursorAus;
    Assign (m, alert, ok);
    EasyGEM0.WrapAlert (alert, 0);
    Insert ('[1][', 0, alert, ok);
    Append ('][ JA | NEIN ]', alert, ok);
    MausEin;
    FormAlert (default, alert, retBut);
    CursorEin;
    RETURN retBut = 1;
  END (* IF Maus *);
END FrageJaNein;

PROCEDURE Auswahl (VAR default: CARDINAL; m: ARRAY OF CHAR);
TYPE    CharSet = SET OF CHAR;
VAR     alert:  ARRAY [0..199] OF CHAR;
        dummy:  CHAR;
        ok:     BOOLEAN;
        retBut: CARDINAL;
BEGIN
  IF IFMaus THEN
    CursorAus;
    Assign (m, alert, ok);
    EasyGEM0.WrapAlert (alert, 0);
    Insert ('[1][', 0, alert, ok);
    Append ('][ JA |NEIN|ABBRUCH]', alert, ok);
    MausEin;
    FormAlert (default, alert, retBut);
    CursorEin;
    default := retBut;
  END (* IF Maus *);
END Auswahl;

PROCEDURE InitAES;
VAR     str:            ARRAY [0..99] OF CHAR;
        i:              CARDINAL;
        wc, hc, sh: CARDINAL;
        ok:             BOOLEAN;
VAR     rows, columns:  CARDINAL;
        rectangle:      Rectangle;
  
BEGIN
  InitGem (RC, ScreenHandle, ok);
  ApId := CurrGemHandle();
  
  (* Get AES VDI handle *)
  GrafHandle (CharWidth, CharHeight, wc, hc, sh);
  
  rectangle := EasyGEM0.DeskSize();
  INC (rectangle.h);
  ScreenWidth := rectangle.w (*639*);
  ScreenHeight := rectangle.h (*399*);
  
  (* "Window" Åber ganze Screen îffnen, damit wir Redraw-Msgs bekommen *)
  CreateWindow (WElementSet{}, rectangle, WindowHandle);
  OpenWindow (WindowHandle, rectangle);
  
  GrafMouse (arrow, NIL);
  GetCharCells (ScreenHandle, LinesOnScreen, CharsInLine);
  DEC (LinesOnScreen, 3);
END InitAES;

PROCEDURE ClearAES;
BEGIN
  UpdateWindow (FALSE);
  ExitGem (ApId);
END ClearAES;

(* EditBuffer *)

PROCEDURE InitBuffer;
BEGIN
  UndoPuffer := NIL; ClipBoard := NIL; HilfsPuffer := NIL;
  ConfigPuffer := NIL; EditPuffer := NIL; AlternEdit := NIL;
  FehlerPuffer := NIL; MailPuffer := NIL; GolemPuffer := NIL;
  SendePuffer := NIL; Tausch := NIL; PSCPuffer := NIL;
  LoadPuffer := NIL; DruckerBatch := NIL; TextVergleichP := NIL;
  WaehlPuffer := NIL; DruckPuff := NIL; StartPuffer := NIL;
  Puffer1 := NIL; Puffer2 := NIL; Puffer3 := NIL; Puffer4 := NIL;
END InitBuffer;

(* InitBuffer nicht im Initialisierungsteil aufrufen - Problem mit
   Initialisierungsreihenfolge! Wird in EditBase gerufen! *)

(************************** EditBase *********************************)

(* Fehlernummer: 100 *)


(* The Little Golem Editor. Begonnen 13. 06. 86
   (C) 1986, 1988 by Johannes Leckebusch, Wolfgang Huber, Walter Sonnenberg.
   Version: Siehe ceditor
   Stand: 13. 02. 89
*)

VAR checkInconsistency: BOOLEAN;

PROCEDURE ALLOCATE (VAR p: ADDRESS; l: LONGCARD);
  BEGIN
    (*
    IF checkInconsistency & Inconsistent() THEN
      Nachricht ('Error before ALLOCATE'); HALT;
    END;
    *)
    (* Storage.ALLOCATE (p, l); *)
    Granule.ALLOCATE (p, l);
    (*
    IF checkInconsistency & Inconsistent() THEN
      Nachricht ('Error after ALLOCATE'); HALT;
    END;
    *)
  END ALLOCATE;
  
PROCEDURE DEALLOCATE (VAR p: ADDRESS; l: LONGCARD);
  BEGIN
    (*
    IF checkInconsistency & Inconsistent() THEN
      Nachricht ('Error before DEALLOCATE'); HALT;
    END;
    *)
    (* Storage.DEALLOCATE (p, l); *)
    Granule.DEALLOCATE (p, l);
    (*
    IF checkInconsistency & Inconsistent() THEN
      Nachricht ('Error after DEALLOCATE'); HALT;
    END;
    *)
  END DEALLOCATE;

VAR     dummyC:         CARDINAL;

PROCEDURE DeAllocLine (VAR p: einLinePointer);
VAR     groesse:        CARDINAL;
BEGIN
  groesse := p^.laenge;
  IF groesse > 0 THEN
    groesse := ((groesse - 1) DIV cAllocate + 1) * cAllocate;
    DEALLOCATE (p^.ZeilPointer, VAL (LONGCARD, groesse));
  END (* IF *);
  DISPOSE (p);
END DeAllocLine;

PROCEDURE AllocLine (VAR p: einLinePointer; groesse: CARDINAL);
BEGIN
  NEW (p);
  IF p # NIL THEN
    WITH p^ DO
      terminator[0] := nul;
      IF groesse > 0 THEN (* Aenderung 18. 11. 87 *)
        laenge := (groesse DIV cAllocate + 1) * cAllocate;
        ALLOCATE (ZeilPointer, VAL (LONGCARD, laenge));
      ELSE
        ZeilPointer := ADR (terminator);
        laenge := 0;
      END (* IF groesse *);
      IF ZeilPointer = NIL THEN
        DISPOSE (p);
      ELSE
        vorige := NIL; naechste := NIL;
      END (* IF ZeilPointer *);
    END (* WITH *);
  END (* IF *);
END AllocLine;

PROCEDURE GetLine (p: einLinePointer; VAR s: ARRAY OF CHAR);
  (* Kopiere Zeileninhalt in String *)
VAR     index, l:       CARDINAL;
BEGIN
  (*index := 0;*)
  IF p # NIL THEN
    WITH p^ DO
      FastStrings.Assign (ZeilPointer^, s);
    END (* WITH p *);
  ELSE s [0] := nul;
  END (* IF p # NIL *);
END GetLine;

PROCEDURE PutLine (VAR p: einLinePointer;
                   REF s: ARRAY OF CHAR);
  (* Kopiere String in eine Zeile (Allocate optimiert) *)
VAR     index, l:       CARDINAL;
        oldstring:      einStringPointer;
        dummy:          CHAR;
BEGIN
  IF p = NIL THEN RETURN END;
  l := FastStrings.Length (s); (* Compile error 89 bei FastStrings!!! *)
  IF l > 0 THEN (* Aenderung 18. 11. 87 *)
    index := (l DIV cAllocate + 1) * cAllocate;
    (* Laenge plus 1, um sicherzustellen, daû String nullterminated *)
    ELSE index := 0;
  END (* IF *);
  IF index # p^.laenge THEN
    oldstring := p^.ZeilPointer;
    IF index > 0 THEN
      ALLOCATE (p^.ZeilPointer, LONG (index));
      (* Compilerfehler 89        ^^^ *)
    ELSE
      p^.ZeilPointer := ADR (p^.terminator);
    END (* IF *);
    IF p^.ZeilPointer = NIL THEN
      p^.ZeilPointer := oldstring; RETURN;
    END (* IF *);
    IF p^.laenge > 0 THEN
      DEALLOCATE (oldstring, LONG (p^.laenge));
    END;
    p^.laenge := index;
  END (* IF neue alloziieren *);
  WITH p^ DO
    FastStrings.Assign (s, ZeilPointer^);
  END (* WITH p^ *);
END PutLine;

PROCEDURE DeallocPuffer (VAR Puff: einPufferPointer);
VAR       Help:                 einLinePointer;
          MerkInd:              MerkIndex;
          MerkPunkt, hM:        einMerkPointer;
BEGIN
  WITH Puff^ DO
    Help := Puffer^.naechste;
    WHILE (Help # NIL) DO
      IF Help^.vorige^.laenge > 0 THEN (* Aenderung 18. 11. 87! *)
        DEALLOCATE (Help^.vorige^.ZeilPointer, LONG (Help^.vorige^.laenge));
      END (* IF *);
      DISPOSE (Help^.vorige);
      IF Help^.naechste = NIL THEN (* Aenderung 18. 11. 87! *)
        IF Help^.laenge > 0 THEN
          DEALLOCATE (Help^.ZeilPointer, LONG (Help^.laenge));
        END (* IF *);
        DISPOSE (Help);
      ELSE Help := Help^.naechste;
      END (* IF *);
    END (* WHILE *);
    
    FOR MerkInd := LetztePosition TO ErsteZeile BY -1 DO
      (* rÅckwÑrts, weil ErsteZeile und LaufendeZeile bei aktueller
         Indexliste Duplikatpointer enthalten kînnen, die mitten in
         MerkPunktlisten liegen *)
         
      WITH MerkPunkte [MerkInd] DO
        IF (merkinfo # NIL) & (merkinfo^.laenge > 0) THEN
          IF merkinfo^.ZeilPointer # NIL THEN
            DEALLOCATE (merkinfo^.ZeilPointer, LONG (merkinfo^.laenge));
          END;
        END (* IF *);
        IF merkinfo # NIL THEN DISPOSE (merkinfo); END;
        IF MerkInd > LaufendeZeile THEN
          MerkPunkt := nextMerk;
          WHILE MerkPunkt # NIL DO
            hM := MerkPunkt; MerkPunkt := MerkPunkt^.nextMerk;
            DISPOSE (hM);
          END (* WHILE *);
        END (* IF MerkInd > LaufendeZeile *);
      END (* WITH *);
    END (* FOR *);
  END (* WITH *);
END DeallocPuffer;

PROCEDURE Loeschen (VAR Puff: einPufferPointer);
BEGIN
  MausBusy;
  DeallocPuffer (Puff);
  PuffInit (Puff);
END Loeschen;

PROCEDURE PufferLeer (Puff: einPufferPointer): BOOLEAN;
BEGIN
  IF (Puff = NIL) THEN
    Nachricht ('Interner Fehler|PufferLeer NIL!101');
    RETURN FALSE;
  END;
  RETURN (Puff^.Puffer^.naechste^.naechste = NIL) &
         (Puff^.Puffer^.naechste^.ZeilPointer^[0] = nul);
END PufferLeer;

PROCEDURE FindeLeerpuffer (Puff: einPufferPointer): einPufferPointer;
VAR     hp:     einPufferPointer;
BEGIN
  IF (Puff = NIL) THEN
    Nachricht ('Interner Fehler|FindeLeerpuffer NIL.102');
    RETURN NIL;
  END;
  hp := Puff;
  WHILE (~PufferLeer (hp)) & (*(hp = MailPuffer) & (hp = HilfsPuffer) &*)
        (hp^.NaechsterPuffer # Puff) DO
    hp := hp^.NaechsterPuffer;
  END (* WHILE *);
  IF ~PufferLeer (hp) THEN
     hp := InsertPuffer (Puff);
  END (* IF *);
  RETURN hp;
END FindeLeerpuffer;

PROCEDURE InsertPuffer (Puff: einPufferPointer): einPufferPointer;
VAR     h:      einPufferPointer;
BEGIN
  IF (Puff = NIL) THEN
    Nachricht ('Interner Fehler|InsertPuffer NIL.103');
    RETURN NIL;
  END;
  h := Puff^.NaechsterPuffer;
  NEW (Puff^.NaechsterPuffer);
  IF Puff^.NaechsterPuffer = NIL THEN
    Puff^.NaechsterPuffer := h;
    Nachricht ('Kein Platz fÅr weitere |Puffer!104');
    RETURN Puff;
  ELSE
    PuffInit (Puff^.NaechsterPuffer);
    IF Puff^.NaechsterPuffer # NIL THEN
      Puff^.NaechsterPuffer^.NaechsterPuffer := h;
      RETURN Puff^.NaechsterPuffer;
    ELSE Nachricht ('Kein Platz fÅr |Pufferinitialisierung!105');
      RETURN Puff;
    END (* IF *);
  END (* IF *);
END InsertPuffer;

PROCEDURE DeletePuffer (VAR Puff: einPufferPointer);
VAR     h, v:    einPufferPointer;
BEGIN
  h := Puff^.NaechsterPuffer;
  IF (h # Puff) & (Moden {Editiert} * Puff^.Modus = Moden {}) THEN
    v := h;
    WHILE v^.NaechsterPuffer # Puff DO
      v := v^.NaechsterPuffer;
    END (* WHILE --> v ist der vorige Puffer *);
    IF Puff = UndoPuffer   THEN UndoPuffer   := h; END;
    IF Puff = ClipBoard    THEN ClipBoard    := h; END;
    IF Puff = HilfsPuffer  THEN HilfsPuffer  := h; END;
    IF Puff = ConfigPuffer THEN ConfigPuffer := h; END;
    IF Puff = EditPuffer   THEN EditPuffer   := h; END;
    IF Puff = AlternEdit   THEN AlternEdit   := h; END;
    IF Puff = FehlerPuffer THEN FehlerPuffer := h; END;
    IF Puff = MailPuffer   THEN MailPuffer   := h; END;
    IF Puff = GolemPuffer  THEN GolemPuffer  := h; END;
    IF Puff = SendePuffer  THEN SendePuffer  := h; END;
    IF Puff = PSCPuffer    THEN PSCPuffer    := h; END;
    IF Puff = Tausch       THEN Tausch       := h; END;
    DeallocPuffer (Puff);
    v^.NaechsterPuffer := h; Puff := h;
    (* Nachricht ('Puffer entfernt'); *)
  ELSE (* Nachricht ('Puffer kann nicht|gelîscht werden.107'); *)
  END (* IF nicht letzter Puffer *)
END DeletePuffer;

PROCEDURE PutConstLine (VAR p: einLinePointer; REF s: ARRAY OF CHAR);
BEGIN
  PutLine (p, s);
END PutConstLine;

PROCEDURE PuffInit (VAR Puff: einPufferPointer);
VAR     merkindex:      MerkIndex;
BEGIN
(*
  IF Inconsistent() THEN Nachricht ('Error before PuffInit'); HALT; END;
  checkInconsistency:= FALSE;
*)
  IF Puff = NIL THEN RETURN END;
  WITH Puff^ DO
    AllocLine (Puffer, 0);
    IF Puffer = NIL THEN
      Puff := NIL;
(*
      checkInconsistency:= TRUE;
      IF Inconsistent() THEN Nachricht ('Error after PuffInit'); HALT; END;
*)
      RETURN;
    END;
    WITH Puffer^ DO
      AllocLine (naechste, 0);
      IF naechste = NIL THEN Puff := NIL; checkInconsistency:= TRUE;
(*
        IF Inconsistent() THEN Nachricht ('Error after PuffInit'); HALT; END;
*)
        RETURN;
      END;
      naechste^.vorige := Puffer;
    END (* WITH *);
    
    FOR merkindex :=  ErsteZeile TO LetztePosition DO
      WITH Puff^.MerkPunkte [merkindex] DO
        zeilpos := 1; charpos := 0;
        merkline := Puffer^.naechste;
        nextMerk := NIL;
        AllocLine (merkinfo, 0);
        IF merkinfo = NIL THEN Puff := NIL; checkInconsistency:= TRUE;
(*
          IF Inconsistent() THEN Nachricht ('Error after PuffInit'); HALT; END;
*)
          RETURN;
        END;
        CASE merkindex OF
          ErsteZeile:           PutConstLine (merkinfo, 'ErsteZeile');|
          LaufendeZeile:        PutConstLine (merkinfo, 'LaufendeZeile');|
          MerkPunkt1:           PutConstLine (merkinfo, 'MerkPunkt1');|
          MerkPunkt2:           PutConstLine (merkinfo, 'MerkPunkt2');|
          CompilerInfo:         PutConstLine (merkinfo, 'Kein_Fehler');|
          BlockMarke1:          PutConstLine (merkinfo, 'BlockMarke1');|
          BlockMarke2:          PutConstLine (merkinfo, 'BlockMarke2');|
          PufferVergleich:      PutConstLine (merkinfo, 'PufferVergleich');|
          IndexListe:           PutConstLine (merkinfo, 'IndexListe');|
          DruckerSteuer:        PutConstLine (merkinfo, 'DruckerSteuer');|
          Protokoll:            PutConstLine (merkinfo, 'Protokoll');|
          Textbausteine:        PutConstLine (merkinfo, 'Textbausteine');|
          Datei:                PutConstLine (merkinfo, 'Datei');|
          M13:                  PutConstLine (merkinfo, 'M13');|
          M14:                  PutConstLine (merkinfo, 'M14');|
          LetztePosition:       PutConstLine (merkinfo, 'LetztePosition');
        END (* CASE *);
      END (* WITH MerkPunkte *);
    END (* FOR merkindex *);
    
    WITH Puff^.MerkPunkte [ErsteZeile] DO
      zeilpos := 0;
    END (* WITH *);
    ZeilenAnzahl := 1; (*VirtualX := 0;*)
    
    MagicRevision :=    cRevision;
    Modus :=            ConfigPuffer^.Modus;
    EXCL (Modus, Editiert);
    Pfad := '';         Name := '';
    TabWeite :=         ConfigPuffer^.TabWeite;
    Max :=              ConfigPuffer^.Max;
    SchreibZaehler :=   ConfigPuffer^.SchreibZaehler;
  END (* WITH *);
  checkInconsistency:= TRUE;
(*
  IF Inconsistent() THEN Nachricht ('Error after PuffInit'); HALT; END;
*)
END PuffInit;

(**************************** ENDE EditBase *********************)

(****************** Von Editdirectory ********************)

CONST TOS14   = 1500H;

VAR   version : CARDINAL;

PROCEDURE DeleteTail (VAR s: ARRAY OF CHAR);
VAR     i:      CARDINAL;
        dummy: ARRAY [0..12] OF CHAR;
BEGIN
  (*
  i := Length (s);
  WHILE (i > 0) & (s [i - 1] # '\') DO
    DEC (i);
    s [i] := CHR (0);
  END (* WHILE *);
  *)
  FileNames.SplitPath (s, s, dummy);
END DeleteTail;

PROCEDURE GetPfad (VAR pf: ARRAY OF CHAR);
VAR   Drive:          CARDINAL;
      p:              ARRAY [0..126] OF CHAR;
      suff:           ARRAY [0..5] OF CHAR;
      ind, i:         CARDINAL;
(*
  Holt akt. Pfad nach 'pf' und fÅgt '*.*' an wenn 'pf' vorher nicht leer,
  wird der Suffix fÅr die Maske Åbernommen
*)
BEGIN
  IF (pf [0] = nul) OR (pf [0] = '*') THEN     (* 28. 11. 87 Le *)
    (*
    ind := Length (pf);
    IF ind > 0 THEN
      DEC (ind);
      WHILE (ind > 0) & (pf [ind] # '.') DO DEC (ind); END;
      IF ind > 0 THEN
        i := ind;
        WHILE (pf [ind] # nul) DO
          suff [ind - i] := pf [ind]; INC (ind);
        END (* WHILE *);
        suff [ind - i] := nul;
      END (* IF *);
    ELSE
      suff [0] := nul;
    END (* IF *);
    GetDrv (Drive);
    p [0] := CHR (0);
    pf [0] := CHR (ORD ('A') + Drive);
    pf [1] := ':'; pf [2] := CHR (0);
    GetPath (p, Drive + 1);
    Append (p, pf, ok);
    Append ('\*', pf, ok);
    IF suff [0] # nul THEN Append (suff, pf, ok)
    ELSE Append ('.*', pf, ok);
    END (* IF kein alter Suffix *);
    *)
    (* !TT 12.12.90 - neue Version *)
    FileNames.SplitName (pf, p, suff);
    IF suff[0] = '' THEN suff:= '*' END;
    FastStrings.Insert ('*.', 0, suff);
    Directory.GetDefaultPath (p);
    FileNames.ConcatPath (p, suff, pf);
  END (* IF pf leer *);
END GetPfad;

PROCEDURE GetDirectory (VAR Pfad, FileName: ARRAY OF CHAR;
                        Meldung: ARRAY OF CHAR;
                        VAR Butt: INTEGER; GEM: BOOLEAN);
VAR     i:      CARDINAL;
        m:      ARRAY [0..30] OF CHAR;
        ok:     BOOLEAN;
BEGIN
  IF ~GEM THEN MausEin; END;
  GetPfad (Pfad);
  (*
   IF (version >= TOS14) THEN
    Assign (Meldung, m);
    AESAddrIn[0] := ADR (Pfad);
    AESAddrIn[1] := ADR (FileName);
    AESAddrIn[2] := ADR (m);
    AESCallResult := GemCall (91,0,2,3,0);
    Butt:= AESIntOut[1];
   ELSE (* TOS-Version kann das nicht! Normalen Selector verwenden! *)
   *)
    GotoXY (0, 0); LoescheZeile; HighLight; WriteLine (Meldung); Normal;
    MausEin;
    SelectFile (Pfad, FileName, ok);
  (*END;*)
  IF ok THEN Butt := 1 ELSE Butt := 0; END;
  IF Butt # 1 THEN (* Abbruch *)
    Assign ('', FileName, ok);
  END (* IF Butt *);
  IF ~GEM THEN
    MausAus;
    LoescheBild;
  END (* IF NOT GEM *);
END GetDirectory;

(*
BEGIN
 Version (version);
END EditDirectory.
*)

BEGIN (* GMEBASE Initialisierung *)

  PuffRecSize := TSIZE (einPufferDeskriptor); (* EditConst *)

  Init; (* KeyBase *)
  
  (* ScreenBase: *)

  CursorAn := FALSE;
  CursorBlink := FALSE;
  MausForm := arrow;
  InitAES;
  WrapOff;      (* Automatischen Zeilenumbruch ausschalten *)
  MausIstSichtbar := TRUE;
  alteBlinkrate := ConfigureCursor (5, -1);
  altesAttribut := alteBlinkrate MOD 256;
  alteBlinkrate := alteBlinkrate DIV 256;

  LoescheBild;
  GotoXY (20, 10); WriteConst (ceditor);
  
  GotoXY (15, 12); WriteConst (   '(C) 1987, 1988, 1989, 1990 by Johannes Leckebusch');
  GotoXY (15, 13); WriteConst (   '*************************************************');
  GotoXY (0,0); WriteLn;
    
  MausEin;
  oldx := 0; oldy := 0;
  OldKnoepfe := ButtonSet {};

  Trace ('ScreenBase ready');
  WITH topbox DO
    x := 0; y := CharHeight + 3;
    w := ScreenWidth; h := CharHeight - 4;
  END (* WITH *);
  TopBox;

  Version (version); (* FrÅher in EditDirectory *)

(* BEGIN (* EditBase *); *)

  DoClipboard := FALSE; (* FrÅher in EditCommand!!! *)
  AutoCount := 0;
  Trace ('GMEBase ready!');

END GMEBase.

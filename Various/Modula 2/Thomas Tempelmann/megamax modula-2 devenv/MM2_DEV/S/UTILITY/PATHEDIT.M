
(*                                 PathEdit
 *                                 ========
 *
 *      Dieses Modul dient zum Editieren der aktuellen Pfadlisten.
 *
 *      -- Alle Menus kînnen Åber Tastendruck und Mausklick bedient werden.
 *      -- Beim Edieren kann durch <Help> ein Fenster geîffnet werden, das
 *         einen Kurzbeschreibung enthÑlt.
 *      -- Die MaximallÑnge der Pfade wird durch die Konstante 'MaxLen'
 *         bestimmt.
 *      -- Werden neue EintrÑge zu einer Pfadliste hinzugefÅgt, so fÅhrt
 *         dies dazu, daû Speicher vom Betriebssystem angefordert werden
 *         muû, der oberhalb des Programmbereichs von 'PathEdit' liegen kann.
 *         Dies fÅhrt dann zu einem hÑûlichen 'Speicherloch'!
 *         Um dies zu umgehen, kann man an die Pfadliste im 'SHELL.INF'-
 *         File 'leere' EintrÑge anhÑngen. Ein solcher Entrag besteht nur
 *         aus einem '.'.
 *
 *----------------------------------------------------------------------------
 *
 *      Autor : Manuel Chakravarty      Erstellungsbeginn: 09.03.1988
 *
 *      System: MEGAMAX Modula-2 V 1.0  Interne Version : V#0209
 *
 *
 * 01.04.88 | 1.0  MCH  | Erste verîffentlichte Version
 * 15.04.88 | 1.1  TT   | Deutsche Texte; Default-Pfade auch bestimmbar;
 *                        Bei F3 kein Address-Error, wenn Cursor auf EOL;
 *                        Close-Klick bei CHWdw und EditWdw mîglich.
 *
 *----------------------------------------------------------------------------
 *)
 
 
MODULE PathEdit;
(*$R-*)

FROM SYSTEM IMPORT ADDRESS, ADR;

FROM Storage IMPORT ALLOCATE, SysAlloc, DEALLOCATE;

FROM Lists IMPORT LCarrier, List,
                  ResetList, InsertEntry, RemoveEntry, AppendEntry,
                  CurrentEntry, NextEntry, PrevEntry, NoOfEntries,
                  SysCreateList, DeleteList, ListEmpty;

FROM PathCtrl IMPORT PathEntry, PathList;

FROM ShellMsg IMPORT StdPaths, DefPaths, ImpPaths, ModPaths, SymPaths, SrcPaths;

FROM Strings IMPORT String,
                    Length, Assign, Delete, Append, Insert, Space, Upper;

FROM GrafBase IMPORT Point, Rectangle,
                     Rect;

FROM GEMGlobals IMPORT GemChar, MButtonSet, SpecialKeySet, MouseButton;

FROM GEMEnv IMPORT RC, GemHandle, DeviceHandle,
                   InitGem, CurrGemHandle, ExitGem;

FROM AESEvents IMPORT Event, RectEnterMode;

FROM AESForms IMPORT FormAlert;

FROM EventHandler IMPORT EventProc, HandleEvents;

FROM TextWindows IMPORT Window, ShowMode, ForceMode, WindowQuality,
                        WQualitySet, DetectMode, DetectResult,
                        Open, Close, WriteString, WriteLn, GotoXY, WritePg,
                        Write, Read, CondRead, Show, Hide, DetectChar,
                        WasClosed, GetPos;


CONST   (* Auswahl der Sprache fÅr die Texte *)
        German          = TRUE;
        English         = FALSE;

        MaxPaths        = 30;   (*  Maximale Anzahl von Pfaden pro Liste   *)
        MaxLen          = 30;   (*  Maximale PfadlÑnge (Siehe 'Paths' bzw.
                                 *  Konstante 'pathSize' in 'MShell'.)
                                 *)
        LineOffset      = 3;

(*$? German:
        EOLMsg          = '[Ende der Liste]';
*)
(*$? English:
        EOLMsg          = '[End of list]';
*)

TYPE    PtrPathList     = POINTER TO PathList;
        PathsNoSet      = SET OF [0..MaxPaths - 1];
        WindowRec       = RECORD
                            used        : BOOLEAN;
                            hdl         : Window;
                            list        : PathList;
                            marked      : PathsNoSet;
                            org         : PtrPathList;
                            changed     : BOOLEAN;
                            headline    : String;
                          END;
        
VAR     EditWdw, ShowWdw,
        CHWdw           : WindowRec;
        EventProcs      : ARRAY [1..2] OF EventProc;
        
        Dev             : DeviceHandle;
        Gem             : GemHandle;
        Quit            : BOOLEAN;
        
        VoidO, OK       : BOOLEAN;
        VoidC           : CARDINAL;
        VoidADR         : ADDRESS;
        
        
(*  CursOn -- Erzeugt VT-52-Code fÅr 'Cursor sichtbar machen'.
 *)
 
PROCEDURE CursOn (hdl:Window);

BEGIN
  Write (hdl, 33C); Write (hdl, 'e');
END CursOn;
        
(*  CursOff -- Erzeugt VT-52-Code fÅr 'Cursor unsichtbar machen'.
 *)
 
PROCEDURE CursOff (hdl:Window);

BEGIN
  Write (hdl, 33C); Write (hdl, 'f');
END CursOff;
        
(*  ReverseOn -- Erzeugt VT-52-Code fÅr 'Inverse Schrift'.
 *)
 
PROCEDURE ReverseOn (hdl:Window);

BEGIN
  Write (hdl, 33C); Write (hdl, 'p');
END ReverseOn;
        
(*  ReverseOff -- Erzeugt VT-52-Code fÅr 'Normale Schrift'.
 *)
 
PROCEDURE ReverseOff (hdl:Window);

BEGIN
  Write (hdl, 33C); Write (hdl, 'q');
END ReverseOff;
        
PROCEDURE ClearEndOfLine (hdl:Window);

BEGIN
  Write (hdl, 33C); Write (hdl, 'K'); (*  Clear end of line  *)
END ClearEndOfLine;
        
(* SetListToElemNo -- Positioniert den Listenzeiger der Liste 'l' auf das
 *                    'no'te Listenelement. Besitzt die Liste nicht genug
 *                    Elemente so wird 'success = FALSE' geliefert, sonst
 *                    'success = TRUE'. (Erste Elem. hat Pos. = 0)
 *)
 
PROCEDURE SetListToElemNo (VAR l:PathList; no:CARDINAL; VAR success:BOOLEAN);

BEGIN
  ResetList (l);
  LOOP
    success:=(NextEntry (l) # NIL);
    IF ~ success OR (no = 0) THEN EXIT  (*  Schleifenaussprung!  *)
    ELSE DEC (no) END;
  END;
END SetListToElemNo;

(*  InsertListIntoList -- Die List 'source' wird in die List 'dest' eingefÅgt.
 *                        Dabei wird bei dem 'pos'ten Element von 'dest' mit
 *                        dem EinfÅgen begonnen. (Erste Elem. hat Pos. = 0)
 *                        Die Liste 'source' wird dabei gelîscht.
 *)

PROCEDURE InsertListIntoList (VAR source, dest:PathList; pos:CARDINAL);

VAR     entry   : PathEntry;
        success : BOOLEAN;

BEGIN
  SetListToElemNo (dest, pos, success);
  VoidADR:=PrevEntry (dest);
  WHILE ~ ListEmpty (source) DO
    ResetList (source);
    entry:=NextEntry (source);
    RemoveEntry (source, VoidO);
    IF success THEN
      InsertEntry (dest, entry, VoidO)
    ELSE
      AppendEntry (dest, entry, VoidO)
    END;
  END;
  DeleteList (source, VoidO);
END InsertListIntoList;

(*  EraseList -- Lîscht eine vollstÑndige List.
 *)
 
PROCEDURE EraseList (VAR l:PathList);

VAR     err     : BOOLEAN;
        entry   : PathEntry;

BEGIN
  ResetList (l);
  entry:=PrevEntry (l);
  RemoveEntry (l, err);
  WHILE ~ err DO
    DISPOSE (entry);
    entry:=CurrentEntry (l);
    RemoveEntry (l, err);
  END;
  DeleteList (l, VoidO);
END EraseList;

(*  CopyList -- Erzeugt eine Kopie der Liste 'l'. Die Kopie belegt einen
 *              vollstÑndig eigenen Speicherbereich. 'success = FALSE', falls
 *              der benîtigte Speicherplatz nicht alloc. werdewn konnte.
 *)
 
PROCEDURE CopyList (VAR copy:PathList;l:PathList; VAR success:BOOLEAN);

VAR     entry, entry2   : PathEntry;

BEGIN
  SysCreateList (copy, success); success:=~ success;
  IF ~ success THEN RETURN END;
  
  ResetList (l);
  entry:=NextEntry (l);
  WHILE entry # NIL DO          (*  FÅr jedes Listenelement ein mal  *)
  
    SysAlloc (entry2, SIZE (entry2^));
    IF entry2 = NIL THEN EraseList (copy); success:=FALSE; RETURN END;
    Assign (entry^, entry2^, VoidO);
    AppendEntry (copy, entry2, success); success:=~ success;
    IF ~ success THEN DISPOSE (entry2); EraseList (copy); RETURN END;
    entry:=NextEntry (l);
    
  END;
END CopyList;

(*  WriteList -- Gibt die List 'wdw.list' in das Fenster 'wdw.hdl' aus.
 *               Der Fensterinhalt wird vorher gelîscht und in die ersten
 *               drei Zeilen wird die öberschrift 'wdw.headline' ausgegeben.
 *)
        
PROCEDURE WriteList (wdw:WindowRec);

  (*  write0 -- Rekursive Proc., die alle Elemente der Liste 'l' untereinander
   *            ausgibt, die zwischen dem aktuellen Listenelement und dem
   *            Listenende liegen (inklusive).
   *)

  PROCEDURE write0 (l:PathList);
  
  VAR   elem    : PathEntry;
  
  BEGIN
    elem:=NextEntry (l);
    IF elem # NIL THEN
      WriteString (wdw.hdl, elem^); WriteLn (wdw.hdl);
      write0 (l);
    END;
  END write0;
  
BEGIN
  WITH wdw DO
  
    WritePg (hdl);              (*  öberschrift  *)
    ReverseOn (hdl);
    WriteLn (hdl); WriteString (hdl, headline); WriteLn (hdl); WriteLn (hdl);
    ReverseOff (hdl);
    
    ResetList (list);
    write0 (list);              (*  Liste  *)
    
    WriteString (hdl, EOLMsg);  (*  End of list message  *)
    
  END;
END WriteList;

(*  CopyMarked -- Erzeugt eine Liste, die aus Kopien der markierten Elemente
 *                von 'rec' besteht. Ist 'success = FALSE' so war nicht mehr
 *                genug Speicher vorhanden.
 *)
 
PROCEDURE CopyMarked (VAR list:PathList; rec:WindowRec; VAR success:BOOLEAN);

VAR     no      : CARDINAL;
        entry,
        entry2  : PathEntry;

BEGIN
  SysCreateList (list, success); success:=~ success;
  IF ~ success THEN RETURN END;
  
  ResetList (rec.list);
  no:=0; entry:=NextEntry (rec.list);
  WHILE entry # NIL DO
  
    IF no IN rec.marked THEN    (*  Markiert? => Kopieren  *)
      SysAlloc (entry2, SIZE (entry^));
      IF entry2 = NIL THEN EraseList (list); success:=FALSE; RETURN END;
      Assign (entry^, entry2^, VoidO);
      AppendEntry (list, entry2, success); success:=~ success;
      IF ~ success THEN DISPOSE (entry2); EraseList (list); RETURN END;
    END;
    
    INC (no); entry:=NextEntry (rec.list);
    
  END;
END CopyMarked;

(*  OutOfMemory -- Meldet dem User, daû der Speicherplatz fÅr diese Anwendung
 *                 nicht ausreicht und leitet die Prgm.terminierung ein.
 *)

PROCEDURE OutOfMemory;

BEGIN
  (*$? German:
    FormAlert(1, '[3][Kein Speicherplatz mehr !][ Ende ]', VoidC);
  *)
  (*$? English:
    FormAlert(1, '[3][Out of memory!][ Quit ]', VoidC);
  *)
  Quit:=TRUE;
END OutOfMemory;

(*  SetList -- Initialisiert das Window-RECORD 'wdw' derart, daû ihm die
 *             Liste 'ptrl^' und die öberschrift 'headline' zugewiesen werden.
 *             Ist 'backUp = TRUE', so wird eine Kopie der Orginalliste
 *             erzeugt, so das es mîglich ist die Liste zu edieren, ohne
 *             gleich das Orginal zu zerstîren.
 *)

PROCEDURE SetList (VAR wdw:WindowRec;ptrl:PtrPathList;head:String;
                   backUp:BOOLEAN);

BEGIN
  WITH wdw DO
    used:=TRUE;         (*  REC als benutzt markieren  *)
    
    IF backUp THEN
    
      (*  Liste kopieren  *)
    
      org:=ptrl;
      CopyList (list, ptrl^, OK);
      IF ~ OK THEN
        OutOfMemory;
        RETURN;
      END;
      
    ELSE list:=ptrl^; END;
    
    changed:=FALSE;
    headline:=head;
    WriteList (wdw);    (*  Liste ins Fenster schreiben  *)
    Show (hdl);         (*  und Fenster anzeigen  *)
  END;
END SetList;

(*  FreeWdw -- Die fÅr den Ediervorgang erzeugt Listenkopie wird wieder frei-
 *             gegeben. Vorher wird geprÅft ob die Liste verÑndert wurde.
 *             Falls ja, wird der Benutzer gefragt, ob er diese énderungen
 *             Åbernehmen mîchte.
 *             Ist dies der Fall, so wird die Orginalliste derart verÑndert,
 *             das mîglichst kein 'Speicherloch' entsteht.
 *)

PROCEDURE FreeWdw (VAR wdw:WindowRec);

CONST   Yes     = 1;

VAR     but     : CARDINAL;
        entry,
        entry2  : PathEntry;

BEGIN
  IF wdw.changed THEN
    (*$? German:
      FormAlert (Yes, '[2][énderungen speichern ?][ Ja |Nein]', but);
    *)
    (*$? English:
      FormAlert (Yes, '[2][Fix changed list ?][ Yes | No ]', but);
    *)
    IF but = Yes THEN
    
      (*  Orginalliste aktuallisieren:
       *
       *    Zuerst werden alle schon vorhandenene Elemente der Org.liste
       *    auf den neusten Stand gebracht. Wird erst das Ende der Org.-
       *    liste erreicht, so wird diese notgedrungen mit neu alloc.
       *    Speicher erweitert (Pech!!?). Wird aber zuerst das Ende der
       *    modifizierten Liste erreicht, so wird der ÅberflÅssige Teil
       *    der Org.liste freigegeben.
       *)
    
      ResetList (wdw.org^);             (*  Listen von Anfang an bearbeiten  *)
      ResetList (wdw.list);
      entry:=NextEntry (wdw.org^);      (*  Ersten Eintrag holen  *)
      entry2:=NextEntry (wdw.list);
      WHILE (entry # NIL) OR (entry2 # NIL) DO
      
        IF entry # NIL THEN
          IF entry2 # NIL THEN
            
            (*  Beide Listen besitzen noch einen Eintrag => Zuweisung  *)
            
            Assign (entry2^, entry^, VoidO);
            
          ELSE
          
            (*  Orginalliste ist zu lang => öberflÅssigen Speicherplatz frei-
             *                              geben.
             *)
          
            entry2:=PrevEntry (wdw.list);
            RemoveEntry (wdw.org^, VoidO);
            DISPOSE (entry);
            
          END;
        ELSE
        
          (*  Orginalliste ist zu kurz => Neuen Eintrag an die Orginalliste
           *                              anhÑngen. (Speicherloch!)
           *)
        
          RemoveEntry (wdw.list, VoidO);
          AppendEntry (wdw.org^, entry2, VoidO);
          entry:=PrevEntry (wdw.org^);
          
        END;
        
        entry:=NextEntry (wdw.org^);    (*  NÑchster Eintrag  *)
        entry2:=NextEntry (wdw.list);
      
      END;
      
    END;
  END;
  EraseList (wdw.list);         (*  Listenkopie freigeben,  *)
  Hide (wdw.hdl);               (*  Fenster vom Screen entfernen  *)
  wdw.used:=FALSE;              (*  und als unbenutzt kennzeichnen  *)
END FreeWdw;
        

(*$J-*)
FORWARD MainMenuKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

FORWARD MainMenuButHdler (clicks:CARDINAL;loc:Point;
                          buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
(*$J=*)

(*  SwitchToMainMenu -- Versetzt das Programm in einen Zustand, in dem es
 *                      die Auswahl eines Eintrags aus dem Hauptmenu erwartet.
 *)
                     
PROCEDURE SwitchToMainMenu;

  PROCEDURE wLn (str:ARRAY OF CHAR);
  
  BEGIN
    WriteString (CHWdw.hdl, '            ');
    WriteString (CHWdw.hdl, str); WriteLn (CHWdw.hdl);
  END wLn;

BEGIN

  (*  Hauptmenu im COMMAND/HELP-Fenster anzeigen  *)
  
  WITH CHWdw DO
    WritePg (hdl);
    WriteLn (hdl); WriteLn (hdl);
    (*$? German:
      wLn ('1.....Default-Pfade');
      wLn ('2.....DEF-Pfade');
      wLn ('3.....IMP-Pfade');
      wLn ('4.....MOD-Pfade');
      wLn ('5.....Source-Pfade');
      wLn ('6.....Symbol-Pfade');
      WriteLn (hdl);
      wLn ('0.....Ende'); WriteLn (hdl); WriteLn (hdl);
      WriteString (hdl, '   WÑhle Taste <0..6> oder mit Maus.');
    *)
    (*$? English:
      wLn ('1.....Default Paths');
      wLn ('2.....DEF Paths');
      wLn ('3.....IMP Paths');
      wLn ('4.....MOD Paths');
      wLn ('5.....Source Paths');
      wLn ('6.....Symbol Paths');
      WriteLn (hdl);
      wLn ('0.....Quit'); WriteLn (hdl); WriteLn (hdl);
      WriteString (hdl, '   Select with <0..6> or with the mouse.');
    *)
    Show (hdl);
    used:=TRUE;
  END;
  
  (*  Diejenigen Proceduren zur Ereignissbehandlung festlegen, die die
   *  Auswahl des Benutzers verarbeiten.
   *)
   
  EventProcs[1].event:=keyboard;            (*  Proc. fÅr Tastaturereignisse  *)
  EventProcs[1].keyHdler:=MainMenuKeyHdler;
  EventProcs[2].event:=mouseButton;
  EventProcs[2].butHdler:=MainMenuButHdler; (*  Proc. fÅr Mausknopfereignisse *)
END SwitchToMainMenu;

(*$J-*)
FORWARD EditKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

FORWARD EditButHdler (clicks:CARDINAL;loc:Point;
                      buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
(*$J=*)

(*  ShowHelp -- "Toggle" Fenster mit Hilfstext (Tastaturbelegung)
 *)
                          
PROCEDURE ShowHelp;

  PROCEDURE wLn (str:ARRAY OF CHAR);
  
  BEGIN
    WriteString (CHWdw.hdl, str); WriteLn (CHWdw.hdl);
  END wLn;

BEGIN
  WITH CHWdw DO
    IF used THEN Hide (hdl); used:=FALSE;  (*  Fenster entfernen  *)
    ELSE
      
      (*  Hilfstext ins COMMAND/HELP-Fenster schreiben  *)
      
      WritePg (hdl);
      ReverseOn (hdl);
      (*$? German:
        wLn (' Bedienungshilfe'); WriteLn (hdl);
        ReverseOff (hdl);
        wLn ('-- Maus o. Cursortasten zum Positionieren,');
        wLn ('   Maus wÑhlt Pfade, wenn im Kopiermodus.');
        wLn ('-- <Backspace> u. <Delete> lîschen Zeichen');
        wLn ('-- <Insert> fÅgt Leerzeichen ein.');
        wLn ('-- <Clr> entfernt ganze Liste.');
        wLn ('-- <F1> zum Kopieren anderer Listen');
        wLn ('        (WÑhlt Pfade im Kopiermodus)');
        wLn ('-- <F2> fÅgt eine Zeile ein.');
        wLn ('-- <F3> lîscht aktuelle Zeile.');
        wLn (' + <Shift> entfernt die Zeile.');
        wLn ('-- <F10> beendet die Eingabe.');
      *)
      (*$? English:
        wLn (' Help-Table'); WriteLn (hdl);
        ReverseOff (hdl);
        wLn ('-- Mouse or cursor-keys to move the cursor');
        wLn ('   Mouse selects paths while in copy-mode');
        wLn ('-- <Backspace> and <Delete> to delete char');
        wLn ('-- <Insert> to insert one blank');
        wLn ('-- <Clr> to erase entire list');
        wLn ('-- <F1> to copy from another list');
        wLn ('        (Selects paths while in copy-mode)');
        wLn ('-- <F2> to insert one line');
        wLn ('-- <F3> to clear the current line');
        wLn (' + <Shift> to delete the current line');
        wLn ('-- <F10> to leave edit mode');
      *)
      
      Show (CHWdw.hdl);         (*  Fenster anzeigen  *)
      used:=TRUE;
      
    END;
  END;
END ShowHelp;

(*  PosEdCurs -- Positioniert den Cursor im Edit-Fenster. Dabei wird darauf
 *               geachtet, daû sich der Cursor immer im Bereich der ange-
 *               zeigten Pfade befindet.
 *)

PROCEDURE PosEdCurs (col,row:CARDINAL);

VAR     r, no           : INTEGER;
        oldCol, oldRow,
        l               : CARDINAL;
        success         : BOOLEAN;
        entry           : PathEntry;

BEGIN
  WITH EditWdw DO
  
    r:=INTEGER (row) - LineOffset;
    IF r < 0 THEN r:=0 END;               (*  Begrenzung nach oben  *)
    no:=NoOfEntries (list);
    IF r > no THEN r:=no END;             (*  Begrenzung nach unten  *)
    SetListToElemNo (list, r, success);
    IF success THEN                       (*  Begrenzung horizontal  *)
      entry:=CurrentEntry (list);
      l:=Length (entry^);
      IF col > l THEN col:=l END;
    ELSE col:=0 END;
    row:=CARDINAL (r) + LineOffset;
    
    (*  Die Cursorposition wird nur verÑndert, falls sich der Cursor noch
     *  nicht an der gewÅnschten Position befindet (Verhindert unîtiges
     *  Geflimmer).
     *)
  
    GetPos (hdl, oldCol, oldRow);
    IF (oldRow # CARDINAL (row)) OR (oldCol # col) THEN
      GotoXY (hdl, col, row)
    END;
    
  END;
END PosEdCurs;

(*  SwitchToEdit -- Versetzt das Programm in einen Zustand, in dem es auf
 *                  Befehle zum Edieren, der Pfade im Edit-Fenster wartet.
 *                  Ist die Åbergebene Liste 'ptrlist^' nicht richtig init.,
 *                  wird ein Alert ausgelîst und 'success =FALSE' geliefert.
 *)

PROCEDURE SwitchToEdit (ptrlist:PtrPathList; name:String; VAR success:BOOLEAN);

BEGIN

  (*  öberprÅfen ob Liste korrekt init. ist.  *)

  success:=(ptrlist^.root # LCarrier (NIL));
  IF ~ success THEN
    (*$? English:
      FormAlert (1,'[3][List is not initialized!][ Abort ]', VoidC);
    *)
    (*$? German:
      FormAlert (1,'[3][Liste ist nicht initialisiert!][ Abbruch ]', VoidC);
    *)
    RETURN
  END;

  (*  Edit-Fenster init., Cursor positionieren und sichtbar machen  *)
  
  SetList (EditWdw, ptrlist, name, TRUE); IF Quit THEN RETURN END;
  PosEdCurs (0,LineOffset);
  CursOn (EditWdw.hdl);
  
  (*  Ereignissverarbeitende Proc.s einsetzen, die Edierkommandos entgegen-
   *  nehmen.
   *)
   
  EventProcs[1].event:=keyboard;
  EventProcs[1].keyHdler:=EditKeyHdler;
  EventProcs[2].event:=mouseButton;
  EventProcs[2].butHdler:=EditButHdler;
END SwitchToEdit;

(*$J-*)
FORWARD CopyKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

FORWARD CopyButHdler (clicks:CARDINAL;loc:Point;
                      buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
(*$J=*)

(*  RestoreNormalEdit -- Schaltet vom Kopiermodus auf den normalen Ediermodus
 *                       zurÅck.
 *)
                          
PROCEDURE RestoreNormalEdit;

VAR     list    : PathList;
        col,row : CARDINAL;

BEGIN

  (*  Markierte Listenelemente in die Liste im Edit-Fenster kopieren  *)
  
  CopyMarked (list, ShowWdw, OK);
  IF ~ OK THEN OutOfMemory
  ELSE
    GetPos (EditWdw.hdl, col, row);
    IF ~ ListEmpty (list) THEN EditWdw.changed:=TRUE END;
    InsertListIntoList (list, EditWdw.list, row - 3)
  END;
  
  (*  VerÑnderte Liste anzeigen, Cursor positionieren und sichtbar machen  *)
  
  WriteList (EditWdw);
  PosEdCurs (col,row);
  CursOn (EditWdw.hdl);
  
  (*  Proc.s einhÑngen, die die Edierkommandos entgegen nehmen  *)
  
  EventProcs[1].event:=keyboard;
  EventProcs[1].keyHdler:=EditKeyHdler;
  EventProcs[2].event:=mouseButton;
  EventProcs[2].butHdler:=EditButHdler;
END RestoreNormalEdit;

(*  PosShowCurs -- Positioniert den Cursor im Kopierfenster (Zeilenweise).
 *)

PROCEDURE PosShowCurs (row:CARDINAL);

VAR     r       : CARDINAL;
        rg      : INTEGER;

BEGIN

  (*  Positionierbereich des Cursors wird auf den Anzeigebereich der Pfade
   *  beschrÑnkt.
   *)
   
  rg:=INTEGER (row) - 3;
  IF rg < 0 THEN rg:=0 END;
  r:=NoOfEntries (ShowWdw.list);
  IF rg > INTEGER (r) THEN rg:=INTEGER (r) END;
  row:=CARDINAL (rg + 3);
  
  (*  Pos. nur verÑndern, wenn neue Pos. ungleich alter Pos. ist  *)
  
  GetPos (ShowWdw.hdl, VoidC,r);
  IF r # row THEN GotoXY (ShowWdw.hdl, 0,row) END;
END PosShowCurs;

(*  SelectCopyPath -- Ein Pfad im Kopierfenster wurde angewÑhlt (F1 oder
 *                    angeklickt). Sein Status, markiert oder nicht, wird
 *                    in dieser Proc. umgeschaltet.
 *)

PROCEDURE SelectCopyPath (row:CARDINAL);

VAR     no              : CARDINAL;
        entry           : PathEntry;
        success         : BOOLEAN;
        
  (*  reWrite -- Der aktuelle Eintrag ('entry') wird ins Fenster geschrieben.
   *             Ist 'reverse = TRUE', so wird er invertiert dargestellt,
   *             sonst normal.
   *)

  PROCEDURE reWrite (reverse:BOOLEAN);

  BEGIN
    WITH ShowWdw DO
      IF reverse THEN ReverseOn (hdl) END;
      GotoXY (hdl, 0,row);
      WriteString (hdl, entry^);
      ClearEndOfLine (hdl);
      GotoXY (hdl, 0,row);
      IF reverse THEN ReverseOff (hdl) END;
    END;
  END reWrite;
  
  (*  getEntry -- Ermittelt aktuellen ('no'ten) Eintrag.
   *)
  
  PROCEDURE getEntry;
  
  BEGIN
    SetListToElemNo (ShowWdw.list, no, success);
    entry:=CurrentEntry (ShowWdw.list);
  END getEntry;
  
BEGIN
  no:=row - 3;
  getEntry;
  IF success THEN WITH ShowWdw DO
  
    (*  Toggle State  *)
    
    IF no IN marked THEN EXCL (marked, no) ELSE INCL (marked, no) END;
    
    reWrite (no IN marked);  (*  and write Path (invers or normal)  *)
    
  END END;
END SelectCopyPath;

(*  StartCopyMode -- Leitet den Kopiermodus ein.
 *)

PROCEDURE StartCopyMode;

BEGIN

  (*  Liste und Cursor anzeigen  *)
  
  WriteList (ShowWdw);
  PosShowCurs (3);
  CursOn (ShowWdw.hdl);
  
  (*  Proc.s setzen, die die Auswahlbefehle des Kopiermodus akzeptieren  *)
  
  EventProcs[1].event:=keyboard;
  EventProcs[1].keyHdler:=CopyKeyHdler;
  EventProcs[2].event:=mouseButton;
  EventProcs[2].butHdler:=CopyButHdler;
END StartCopyMode;


(*$J-*)
FORWARD CSelKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

FORWARD CSelButHdler (clicks:CARDINAL;loc:Point;
                      buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
(*$J=*)
                      
(*  SwitchToCopy -- Initalisiert den Kopiermodus, indem die Liste erfragt
 *                  wird, aus der kopiert werden soll.
 *)
                          
PROCEDURE SwitchToCopy;

  PROCEDURE wLn (str:ARRAY OF CHAR);
  
  BEGIN
    WriteString (ShowWdw.hdl, Space ((MaxLen - 18) DIV 2));
    WriteString (ShowWdw.hdl, str); WriteLn (ShowWdw.hdl);
  END wLn;

BEGIN

  (*  Listenauswahl-Menu anzeigen  *)
  
  WITH ShowWdw DO
    WritePg (hdl);
    WriteLn (hdl);
    (*$? German:
      wLn ('    Kopiere von'); WriteLn (hdl);
      wLn ('1.....Default-Pfaden');
      wLn ('2.....DEF-Pfaden');
      wLn ('3.....IMP-Pfaden');
      wLn ('4.....MOD-Pfaden');
      wLn ('5.....Source-Pfaden');
      wLn ('6.....Symbol-Pfaden');
      WriteLn (hdl); WriteLn (hdl);
      wLn ('WÑhle Taste <1..6>');
      wLn ('oder wÑhle mit Maus.');
    *)
    (*$? English:
      wLn ('    Copy from'); WriteLn (hdl);
      wLn ('1.....Default Paths');
      wLn ('2.....DEF Paths');
      wLn ('3.....IMP Paths');
      wLn ('4.....MOD Paths');
      wLn ('5.....Source Paths');
      wLn ('6.....Symbol Paths');
      WriteLn (hdl); WriteLn (hdl);
      wLn ('Select with <1..6>');
      wLn ('or with the mouse.');
    *)
    Show (hdl);
    used:=TRUE;
    marked:=PathsNoSet {};
  END;
  
  (*  Proc.s einsetzen, die eine Auswahl aus dem Listenauswahl-Menu ver-
   *  arbeiten.
   *)
  
  EventProcs[1].event:=keyboard;
  EventProcs[1].keyHdler:=CSelKeyHdler;
  EventProcs[2].event:=mouseButton;
  EventProcs[2].butHdler:=CSelButHdler;
END SwitchToCopy;

TYPE    MainCommand     = (quit, edDft, edDef, edImp, edMod, edSrc, edSym);

(*  DoMainCommand -- FÅhrt eine Befehl aus dem Hauptmenu aus.
 *)

PROCEDURE DoMainCommand (cmd:MainCommand);

VAR     success : BOOLEAN;

BEGIN
  CASE cmd OF
  
    quit        : Quit:=TRUE|   (*  Prgm.terminierung einleiten  *)
    
    (*  Edieren einer Pfadliste einleiten  *)
    
    (*$? German:
      edDft: SwitchToEdit (ADR (StdPaths), ' Default-Pfade ', success)|
      edDef: SwitchToEdit (ADR (DefPaths), ' Definitions-Pfade ', success)|
      edImp: SwitchToEdit (ADR (ImpPaths), ' Implementations-Pfade ', success)|
      edMod: SwitchToEdit (ADR (ModPaths), ' Hauptmodul-Pfade ', success)|
      edSrc: SwitchToEdit (ADR (SrcPaths), ' Source-Pfade ', success)|
      edSym: SwitchToEdit (ADR (SymPaths), ' Symbol-Pfade ', success)|
    *)
    (*$? English:
      edDft: SwitchToEdit (ADR (StdPaths), ' Default Paths ', success)|
      edDef: SwitchToEdit (ADR (DefPaths), ' Definition Paths ', success)|
      edImp: SwitchToEdit (ADR (ImpPaths), ' Implementation Paths ', success)|
      edMod: SwitchToEdit (ADR (ModPaths), ' Main Module Paths ', success)|
      edSrc: SwitchToEdit (ADR (SrcPaths), ' Source Paths ', success)|
      edSym: SwitchToEdit (ADR (SymPaths), ' Symbol Paths ', success)|
    *)
  END;
  
  IF success THEN
    Hide (CHWdw.hdl);  (*  Hauptmenufenster deaktivieren  *)
    CHWdw.used:=FALSE;
  END;
END DoMainCommand;

TYPE    CopyListCmd = (copyDft, copyDef, copyImp, copyMod, copySrc, copySym);

(*  SetCopyList -- Bearbeitet eine Auswahl aus dem Listenauswahl-Menu.
 *)

PROCEDURE SetCopyList (cmd:CopyListCmd);

  PROCEDURE set0 (l:PathList; name:ARRAY OF CHAR);
  
  BEGIN
    ShowWdw.list:=l;
    Assign (name, ShowWdw.headline, VoidO);
  END set0;

BEGIN
  CASE cmd OF   (*  Entsprechende Liste wird gesetzt  *)
  
    (*$? German:
      copyDft     : set0 (StdPaths, ' Default-Pfade ')|
      copyDef     : set0 (DefPaths, ' Definitions-Pfade ')|
      copyImp     : set0 (ImpPaths, ' Implementations-Pfade ')|
      copyMod     : set0 (ModPaths, ' Hauptmodul-Pfade ')|
      copySrc     : set0 (SrcPaths, ' Source-Pfade ')|
      copySym     : set0 (SymPaths, ' Symbol-Pfade ')|
    *)
    (*$? English:
      copyDft     : set0 (StdPaths, ' Default Paths ')|
      copyDef     : set0 (DefPaths, ' Definition Paths ')|
      copyImp     : set0 (ImpPaths, ' Implementation Paths ')|
      copyMod     : set0 (ModPaths, ' Main Module Paths ')|
      copySrc     : set0 (SrcPaths, ' Source Paths ')|
      copySym     : set0 (SymPaths, ' Symbol Paths ')|
    *)
    
  END;
  
  StartCopyMode;  (*  und der Kopiermodus eingeleitet  *)
END SetCopyList;


(*  MainMenuKeyHdler -- Akzeptiert die Tastaturereignisse, wÑhrend der Aus-
 *                      wahl aus dem Hauptmenu.
 *)

PROCEDURE MainMenuKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

BEGIN
  CASE ch.ascii OF
    '0' : DoMainCommand (quit)|
    '1' : DoMainCommand (edDft)|
    '2' : DoMainCommand (edDef)|
    '3' : DoMainCommand (edImp)|
    '4' : DoMainCommand (edMod)|
    '5' : DoMainCommand (edSrc)|
    '6' : DoMainCommand (edSym)|
  ELSE
  END;
  RETURN FALSE;
END MainMenuKeyHdler;

(*  MainMenuButHdler -- Akzeptiert die Mausknopfereignisse, wÑhrend der Aus-
 *                      wahl aus dem Hauptmenu.
 *)

PROCEDURE MainMenuButHdler (clicks:CARDINAL;loc:Point;
                            buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
                            
VAR     p       : Point;
        hdl     : Window;
        col, row: CARDINAL;
        box     : Rectangle;
        result  : DetectResult;
                     
BEGIN
  p:=loc;
  DetectChar (CHWdw.hdl,0, takePnt,p,
              hdl, col,row, box, result);
  IF result = foundChar THEN
    CASE row OF
      9   : DoMainCommand (quit)|
      2   : DoMainCommand (edDft)|
      3   : DoMainCommand (edDef)|
      4   : DoMainCommand (edImp)|
      5   : DoMainCommand (edMod)|
      6   : DoMainCommand (edSrc)|
      7   : DoMainCommand (edSym)|
    ELSE
    END;
  END;
  RETURN FALSE;
END MainMenuButHdler;


(*  EditKeyHdler -- Akzeptiert die Tastaturereignisse wÑhrend des Ediermodus.
 *)

PROCEDURE EditKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

CONST   backspace       = 14;   (*  Liste alle Scancodes fÅr Sonderfunktionen *)
        return          = 28;
        f1              = 59;
        f2              = 60;
        f3              = 61;
        f10             = 68;
        shiftf3         = 86;
        clr             = 71;
        up              = 72;
        left            = 75;
        right           = 77;
        down            = 80;
        insert          = 82;
        delete          = 83;
        help            = 98;
        
VAR     col, row        : CARDINAL;
        entry           : PathEntry;
        success         : BOOLEAN;
        
  (*  move -- Bewegt den Cursor um 'c' Spalten und 'r' Zeilen.
   *)

  PROCEDURE move (c,r:INTEGER);

  BEGIN
    IF (INTEGER (col) + c) >= 0 THEN col:=INTEGER (col) + c
    ELSE
      col:=MaxLen;
      r:=r - 1;
    END;
    IF (INTEGER (row) + r) >= 0 THEN row:=INTEGER (row) + r END;
  END move;
  
  (*  reWrite -- Schreibt den aktuellen Eintrag in das Fenster.
   *)
  
  PROCEDURE reWrite;

  BEGIN
    WITH EditWdw DO
      GotoXY (hdl, 0, row);
      WriteString (hdl, entry^);
      Write (hdl, 33C); Write (hdl, 'K'); (*  Clear end of line  *)
      GotoXY (hdl, col,row);
    END;
  END reWrite;
  
  (*  getEntry -- Ermittelt den aktuellen ('no'ten) Eintrag.
   *              Ergebniss in 'entry', auûerdem ist der aktuellen Eintrag
   *              in dem Listen-Carrier entsprechend gesetzt.
   *              'success = FALSE', falls der Eintrag nicht existiert.
   *)
  
  PROCEDURE getEntry;
  
  BEGIN
    SetListToElemNo (EditWdw.list, row - 3, success);
    entry:=CurrentEntry (EditWdw.list);
  END getEntry;
  
  (*  writeHole -- Schreibt die komplette Liste erneut in das Fesnter.
   *)
  
  PROCEDURE writeHole;
  
  BEGIN
    WriteList (EditWdw);
  END writeHole;
  
  
VAR     err     : BOOLEAN;
        l       : CARDINAL;
  
BEGIN

  (*  Cursorposition ermitteln und Cursor verstecken  *)
  
  GetPos (EditWdw.hdl, col,row);
  CursOff (EditWdw.hdl);
  
  CASE ORD (ch.scan) OF     (*  Sondertasten auswerten  *)
  
    f10         : Hide (EditWdw.hdl); FreeWdw (EditWdw);
                  SwitchToMainMenu; RETURN FALSE|       (*  Edieren beenden  *)

    help        : ShowHelp|             (*  Hilfstext anzeigen  *)

    up          : move (0,-1)|          (*  Cursor eine Zeile nach oben  *)
    left        : move (-1,0)|          (*  Cursor eine Spalte nach links  *)
    right       : move (1,0)|           (*  Cursor eine Spalte nach rechts *)
    down        : move (0,1)|           (*  Cursor eine Zeile nach unten  *)
    return      : col:=0; move (0,1)|   (*  Unten + Zeilenanfang  *)
    
    backspace   : getEntry;             (*  Del. char left from Curs.  *)
                  IF success AND (col # 0) THEN
                    col:=col - 1;
                    Delete (entry^, col,1, VoidO);
                    reWrite;
                    EditWdw.changed:=TRUE;
                  END|
    delete      : getEntry;             (*  Del. char at Curs.pos  *)
                  IF success THEN
                    Delete (entry^, col,1, VoidO);
                    reWrite;
                    EditWdw.changed:=TRUE;
                  END|
    insert      : getEntry;             (* Starting from Curs.pos, shift right*)
                  IF success THEN
                    IF Length (entry^) < MaxLen THEN
                      Insert (' ', col, entry^, VoidO);
                      reWrite;
                      EditWdw.changed:=TRUE;
                    END;
                  END|
                  
    clr         : EraseList (EditWdw.list);  (*  Lîsche die gesamte Liste  *)
                  SysCreateList (EditWdw.list, VoidO);
                  writeHole;
                  EditWdw.changed:=TRUE|
    
    f1          : SwitchToCopy|         (*  Kopiere von anderer Liste  *)
    f2          : getEntry;             (*  Insert one line before curr. line *)
                  SysAlloc (entry, SIZE (entry^));
                  IF entry = NIL THEN OutOfMemory; RETURN FALSE END;
                  entry^:='';
                  VoidADR:=PrevEntry (EditWdw.list);
                  InsertEntry (EditWdw.list, entry, err);
                  IF err THEN OutOfMemory; DISPOSE (entry); RETURN FALSE END;
                  writeHole;
                  EditWdw.changed:=TRUE|
    f3          : getEntry;             (*  Erase contents of curr. line  *)
                  IF success THEN
                    entry^:='';
                    reWrite;
                    EditWdw.changed:=TRUE
                  END|
    shiftf3     : getEntry;             (*  Delete curr. entry  *)
                  IF success THEN
                    RemoveEntry (EditWdw.list, VoidO);
                    DISPOSE (entry);
                    writeHole;
                    EditWdw.changed:=TRUE
                  END|
 
  ELSE
  
    WITH EditWdw DO
      IF (ch.ascii >= ' ') AND (ORD (ch.ascii) < 128) THEN
      
        (*  Verarbeite TastendrÅcke im Bereich der sichtbaren Zeichen  *)
        
        getEntry;       (*  Ermittle aktuellen Eintrag  *)
        
        IF ~ success THEN   (*  Ex. nicht => Neuen Eintrag anfÅgen  *)
        
          SysAlloc (entry, SIZE (entry^));      (*  Alloc.  *)
          IF entry = NIL THEN
            OutOfMemory; RETURN FALSE
          END;
          entry^:='';                           (*  Lîschen und anfÅgen  *)
          AppendEntry (list, entry, success); success:=~ success;
          IF ~ success THEN
            DISPOSE (entry);
            OutOfMemory;
            RETURN FALSE
          END;
          ClearEndOfLine (hdl);;                (*  Darstellen  *)
          GotoXY (hdl, col, row + 1);
          WriteString (hdl, EOLMsg);
          GotoXY (hdl, col, row);
          
        END;
        
        Upper (ch.ascii);   (*  Nur Groûbuchstaben in Pfadlisten  *)
        l:=Length (entry^);
        IF col < l THEN
          entry^[col]:=ch.ascii                 (*  öberschreiben  *)
        ELSE
          Append (ch.ascii, entry^, VoidO)      (*  oder anhÑngen  *)
        END;
        Write (hdl, ch.ascii);                  (*  Zeichen darstellen  *)
        IF col < (MaxLen - 1) THEN INC (col) END;
        changed:=TRUE;
        
      END;
    END;
  
  END;
  
  (*  Neue Cursorpos. setzen und Cursor sichtbar machen  *)
  
  PosEdCurs (col,row);
  IF (CARDINAL (LONG (ch.scan)) # f1) THEN CursOn (EditWdw.hdl) END;
  
  RETURN FALSE;
END EditKeyHdler;

(*  EditButHdler -- Akzeptiert die Mausknopfereignisse wÑhrend des Ediermodus.
 *)

PROCEDURE EditButHdler (clicks:CARDINAL;loc:Point;
                        buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
                     
VAR     p               : Point;
        hdl             : Window;
        col, row        : CARDINAL;
        box             : Rectangle;
        result          : DetectResult;
                     
BEGIN
  p:=loc;
  DetectChar (EditWdw.hdl,0, takePnt,p,
              hdl, col,row, box, result);
              
  (*  Falls Klick im Fenster, so wird der Cursor unter dem Mauszeiger pos.  *)
  
  IF result = foundChar THEN PosEdCurs (col,row) END;
  RETURN FALSE;
END EditButHdler;

(*  CopyKeyHdler -- Akzeptiert die Tastaturereignisse wÑhrend des Kopiermodus.
 *)

PROCEDURE CopyKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

CONST   f1              = 59;   (*  Scancodes der benîtigten Sondertasten  *)
        f10             = 68;
        up              = 72;
        down            = 80;
        help            = 98;
        
VAR     col, row        : CARDINAL;
        entry           : PathEntry;
        success         : BOOLEAN;
        
  (*  Bewegt den Cursor um 'r' Zeilen
   *)

  PROCEDURE move (r:INTEGER);

  BEGIN
    IF (INTEGER (row) + r) >= 0 THEN row:=INTEGER (row) + r END;
  END move;
  
VAR     err     : BOOLEAN;
        l       : CARDINAL;
  
BEGIN
  GetPos (ShowWdw.hdl, col,row);
  CursOff (ShowWdw.hdl);
  CASE ORD (ch.scan) OF
  
    f10         : Hide (ShowWdw.hdl); ShowWdw.used:=FALSE;
                  RestoreNormalEdit; RETURN FALSE| (*  Ende des Kopierenmodus *)
                  
    help        : ShowHelp|     (*  Helptable anzeigen  *)
    
    up          : move (-1)|    (*  Cursor einen Zeile nach oben  *)
    down        : move (1)|     (*  Cursor einen Zeile nach unten  *)
    
    f1          : SelectCopyPath (row)|  (*  Aktuellen Eintrag anwÑhlen  *)
 
  ELSE
  END;
  PosShowCurs (row);
  CursOn (ShowWdw.hdl);
  RETURN FALSE;
END CopyKeyHdler;

(*  CopyButHdler -- Akzeptiert die Mausknopfereignisse wÑhrend des Kopiermodus.
 *)

PROCEDURE CopyButHdler (clicks:CARDINAL;loc:Point;
                        buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
                     
VAR     p               : Point;
        hdl             : Window;
        row, r          : CARDINAL;
        box             : Rectangle;
        result          : DetectResult;
                     
BEGIN
  p:=loc;
  DetectChar (ShowWdw.hdl,0, takePnt,p,
              hdl, VoidC,row, box, result);
              
  (*  Falls Klick im Fenster, so wird der Cursor pos. und der entsprechnede
   *  Eintrag selektiert.
   *)
   
  IF result = foundChar THEN
    CursOff (ShowWdw.hdl);
    PosShowCurs (row);
    GetPos (ShowWdw.hdl, VoidC,r);
    IF row = r THEN SelectCopyPath (row) END;
    CursOn (ShowWdw.hdl);
  END;
  RETURN FALSE;
END CopyButHdler;


(*  CSelKeyHdler -- Akzeptiert die Tastaturereignisse, wÑhrend des Listen-
 *                  auswahl-Menus.
 *)

PROCEDURE CSelKeyHdler (VAR ch:GemChar; VAR keys: SpecialKeySet) :BOOLEAN;

BEGIN
  CASE ch.ascii OF
    '1' : SetCopyList (copyDft)|
    '2' : SetCopyList (copyDef)|
    '3' : SetCopyList (copyImp)|
    '4' : SetCopyList (copyMod)|
    '5' : SetCopyList (copySrc)|
    '6' : SetCopyList (copySym)|
  ELSE
  END;
  RETURN FALSE;
END CSelKeyHdler;

(*  CSelButHdler -- Akzeptiert die Mausknopfereignisse, wÑhrend des Listen-
 *                  auswahl-Menus.
 *)

PROCEDURE CSelButHdler (clicks:CARDINAL;loc:Point;
                            buts:MButtonSet;keys:SpecialKeySet) :BOOLEAN;
                            
VAR     p       : Point;
        hdl     : Window;
        col, row: CARDINAL;
        box     : Rectangle;
        result  : DetectResult;
                     
BEGIN
  p:=loc;
  DetectChar (ShowWdw.hdl,0, takePnt,p,
              hdl, col,row, box, result);
  IF result = foundChar THEN
    CASE row OF
      3   : SetCopyList (copyDft)|
      4   : SetCopyList (copyDef)|
      5   : SetCopyList (copyImp)|
      6   : SetCopyList (copyMod)|
      7   : SetCopyList (copySrc)|
      8   : SetCopyList (copySym)|
    ELSE
    END;
  END;
  RETURN FALSE;
END CSelButHdler;


(*  Master -- Verteilt die Events.
 *)
 
PROCEDURE Master;

BEGIN
  REPEAT
    HandleEvents (1, MButtonSet{msBut1},MButtonSet{msBut1},
                  lookForEntry,Rect (0,0,0,0), lookForEntry,Rect (0,0,0,0),
                  0L,
                  EventProcs,2);
    IF EditWdw.used & WasClosed (EditWdw.hdl) THEN
      Hide (EditWdw.hdl); FreeWdw (EditWdw); SwitchToMainMenu
    ELSIF CHWdw.used & WasClosed (CHWdw.hdl) THEN
      DoMainCommand (quit)
    END
  UNTIL Quit;
END Master;


PROCEDURE InitModule () :BOOLEAN;

VAR     success : BOOLEAN;
        ch      : CHAR;

BEGIN
  Quit:=FALSE;
  
  (*  Beim GEM anmelden.
   *)
  
  InitGem (RC, Dev, OK);
  IF ~ OK THEN RETURN FALSE END;
  Gem:=CurrGemHandle ();
  
  (*  Benîtigte Fenster anfordern.
   *)
  
  CHWdw.used:=FALSE;
  Open (CHWdw.hdl, 42,13, WQualitySet{movable, closable, titled}, hideWdw,
        noForce, ' PathEdit by MCH / V1.1 ', -1,-1,-1,-1, OK);
  IF ~ OK THEN RETURN FALSE END;

  EditWdw.used:=FALSE;
  Open (EditWdw.hdl, MaxLen,MaxPaths + 4, WQualitySet{movable, closable,
    titled, dynamic}, hideWdw, forceCursor, ' Edit-Window ', -1,-1,60,-1, OK);
  success:=OK;

  ShowWdw.used:=FALSE;
  Open (ShowWdw.hdl, MaxLen,MaxPaths + 4, WQualitySet{movable, titled, dynamic},
        hideWdw, forceCursor, ' Copy-Window ', -1,-1,50,15, OK);
  success:=success AND OK;
  
  IF ~ success THEN WITH CHWdw DO
  
    (*  Fehlermeldung und Term., falls nicht genug Fenster erzeugt werden
     *  kînnen.
     *)
     
    WriteLn (hdl); WriteLn (hdl);
    ReverseOn (hdl);
    (*$? German:
      WriteString (hdl, 'Es ist nicht genÅgend Speicherplatz vorhanden !');
    *)
    (*$? English:
      WriteString (hdl, 'Out of memory !');
    *)
    ReverseOff (hdl);
    WriteLn (hdl); WriteLn (hdl);
    (*$? German:
      WriteString (hdl, 'Bitte irgendeine Taste drÅcken...'); Read (hdl, ch);
    *)
    (*$? English:
      WriteString (hdl, 'Press any key...'); Read (hdl, ch);
    *)

  END END;
  
  SwitchToMainMenu;     (*  Mit dem Hauptmenu anfangen  *)
  
  IF ~ success THEN ExitGem (Gem) END;
  
  RETURN success
END InitModule;

PROCEDURE ExitModule;

BEGIN
  (*  Fenster freigeben.
   *)
  Close (ShowWdw.hdl);
  Close (EditWdw.hdl); IF EditWdw.used THEN EraseList (EditWdw.list) END;
  Close (CHWdw.hdl);
  
  ExitGem (Gem);        (*  Beim GEM abmelden  *)
END ExitModule;


BEGIN
  IF InitModule () THEN
    Master;
    ExitModule;
  END;
END PathEdit.

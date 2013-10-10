MODULE WLTest;

(*
 * Dies Modul demonstiert die Anwendung des Moduls "WindowLists", das
 * auf bequeme Weise Listen in Fenstern verwaltet.
 *)

FROM SYSTEM IMPORT ADDRESS,
                   ADR;

FROM InOut IMPORT WriteCard, WriteLn, WriteString;

FROM Storage IMPORT ALLOCATE, DEALLOCATE;

FROM Strings IMPORT String, Relation,
                    Empty, Append, Assign, Concat, Length, PosLen, Delete,
                    Compare;

IMPORT FastStrings;

FROM Lists IMPORT List,
                  ResetList, PrevEntry, DeleteList, CreateList, AppendEntry,
                  NoOfEntries, RemoveEntry, CurrentEntry, InsertEntry,
                  NextEntry;

FROM Directory IMPORT DirEntry, FileAttr, FileAttrSet, DirQuery;

FROM FileNames IMPORT SplitPath, ConcatPath;

FROM GrafBase IMPORT Point, Rectangle,
                     Rect;

FROM GEMGlobals IMPORT GemChar, MouseButton, MButtonSet, SpecialKeySet, MaxStr;

FROM AESEvents IMPORT RectEnterMode, Event;

FROM EventHandler IMPORT EventProc,
                         HandleEvents;

FROM WindowLists IMPORT WindowList, NoWindowList, DetectModeWL, AttributesWL,
                        AttributeWL, MaxWindowWL, CenterWindowWL, ErrorStateWL,
                        CreateWL, DeleteWL, SetListWL, GetListWL,
                        ShowWindowWL, HideWindowWL, DetectWindowWL,
                        SetEntryAttributesWL, EntryAttributesWL, StateWL;


TYPE    PtrWEnv = POINTER TO RECORD
                    path        : String;
                    wl          : WindowList;
                  END;
        
        Entry   = POINTER TO DirEntry;


VAR     WEnv    : PtrWEnv;
        
        Worker  : ARRAY [0..1] OF EventProc;
        
        Success,
        Quit    : BOOLEAN;
        
        VoidO   : BOOLEAN;


FORWARD EntryToStr (entry, env: ADDRESS; VAR str: MaxStr);

FORWARD CloseWList (wl: WindowList; env: ADDRESS);

FORWARD OpenFolder (wl: WindowList; env, entry: ADDRESS; selMode: LONGCARD);


VAR     CurrList        : List;

PROCEDURE InsertEntryInCurr (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR   data: Entry;
        e   : Entry;
        subdir,
        ins : BOOLEAN;

  BEGIN
    IF (entry.name [0] # '.') THEN
    
      NEW (data);
      data^ := entry;
      subdir:= subdirAttr IN data^.attr;

      (*  alphabetic order, folders first
       *)
       
      ResetList (CurrList);
      LOOP
        e := NextEntry (CurrList);
        IF e = NIL THEN
          AppendEntry (CurrList, data, VoidO); EXIT
        ELSE
          ins := subdir AND NOT (subdirAttr IN e^.attr);
          IF ~ ins AND (data^.attr = e^.attr) THEN
            ins := (Compare (data^.name, e^.name) = less);
          END;
          IF ins THEN
            e := PrevEntry (CurrList);
            InsertEntry (CurrList, data, VoidO);
            EXIT
          END;
        END;
      END;
    
    END;
      
    RETURN TRUE
  END InsertEntryInCurr;
  

PROCEDURE newList (wEnvPtr: PtrWEnv);

  VAR   res     : INTEGER;
        wildName: String;

  BEGIN
    ConcatPath (wEnvPtr^.path, '*.*', wildName);
    CreateList (CurrList, VoidO);
    DirQuery (wildName, FileAttrSet{subdirAttr}, InsertEntryInCurr, res);
    SetListWL (wEnvPtr^.wl, CurrList, EntryToStr, CloseWList, OpenFolder,
               wEnvPtr, 16, wEnvPtr^.path);
  END newList;

PROCEDURE killList (wEnvPtr: PtrWEnv);

  VAR   l       : List;
        entry   : Entry;

  BEGIN
    GetListWL (wEnvPtr^.wl, l);
    
    ResetList (l);
    entry := PrevEntry (l);
    WHILE entry # NIL DO
      RemoveEntry (l, VoidO);
      DISPOSE (entry);
      entry := CurrentEntry (l);
    END;
    DeleteList (l, VoidO);
    IF VoidO THEN HALT END;
  END killList;
  
  
PROCEDURE EntryToStr (entry, env: ADDRESS; VAR str: MaxStr);

  VAR   data    : Entry;

  BEGIN
    data := Entry (entry);
    
    IF subdirAttr IN data^.attr THEN
      Assign (' '+7C, str, VoidO)
    ELSE
      Assign ('  ', str, VoidO);
    END;
    Append (' ', str, VoidO);
    FastStrings.Append (data^.name, str);
    Append (' ', str, VoidO);
  END EntryToStr;

PROCEDURE CloseWList (wl: WindowList; env: ADDRESS);

  VAR   wEnv: PtrWEnv;
        i, j,
        len : INTEGER;
        folderName: String;

  BEGIN
    wEnv := PtrWEnv (env);
    
    WITH wEnv^ DO
      killList (wEnv);
      
      (* Prfen ob Root-Dir oder Ordner ge”ffnet ist. *)
       
      (*  Der Pfadname ist immer mit einem '\' abgeschlossen,
       *  deshalb kann einfach das letzte Zeichen entfernt werden. *)
      Delete (path, Length (path)-1, 1, VoidO);
      SplitPath (path, path, folderName);

      IF Empty (folderName) THEN
      
        (* Wir waren im Root -> Fenster schliežen *)
        path := '';
        HideWindowWL (wl);
        
      ELSE
        
        (* Vorigen Ordner anzeigen *)
        (*  ('path' enth„lt schon neuen Namen) *)
        newList (wEnv);
        
      END;
    END;
  END CloseWList;
  
PROCEDURE OpenFolder (wl: WindowList; entry, env: ADDRESS; selMode: LONGCARD);

  VAR   wEnvPtr : PtrWEnv;
        data    : Entry;
        attrs   : AttributesWL;

  BEGIN
    wEnvPtr := PtrWEnv (env);
    data := Entry (entry);
    
    attrs := EntryAttributesWL (wl, entry);
    IF selectedWL IN attrs THEN EXCL (attrs, selectedWL)
    ELSE INCL (attrs, selectedWL) END;
    SetEntryAttributesWL (wl, entry, attrs);
    
    IF subdirAttr IN data^.attr THEN
      killList (wEnvPtr);
      Append (data^.name, wEnvPtr^.path, VoidO);
      Append ('\', wEnvPtr^.path, VoidO);
      newList (wEnvPtr);
    END;
  END OpenFolder;
  

  
PROCEDURE KeyHdler (VAR ch: GemChar; VAR k: SpecialKeySet): BOOLEAN;

  BEGIN
    IF CAP (ch.ascii) = 'Q' THEN Quit := TRUE
    ELSIF (CAP (ch.ascii) >= 'A') AND (CAP (ch.ascii) <= 'P') THEN
      WITH WEnv^ DO
        IF Empty (path) THEN
          Append (CAP (ch.ascii), WEnv^.path, VoidO);
          Append (':\', path, VoidO);
          newList (WEnv);
          ShowWindowWL (wl);
        END;
      END
    END;
    RETURN FALSE
  END KeyHdler;

PROCEDURE ButHdler (clicks: CARDINAL; loc: Point; buts: MButtonSet;
                    keys: SpecialKeySet): BOOLEAN;

  VAR   wl   : WindowList;
        entry,
        env  : ADDRESS;

  BEGIN
    DetectWindowWL (WEnv^.wl, 0, loc, selectWL, 0L, wl, entry, env, VoidO);
    RETURN FALSE
  END ButHdler;
  
  
BEGIN
  NEW (WEnv);
  CreateWL (WEnv^.wl, TRUE,  Rect (CenterWindowWL, CenterWindowWL,
                                   MaxWindowWL, MaxWindowWL));
  IF StateWL (WEnv^.wl) = okWL THEN
    WEnv^.path := '';
    
    WriteString ('Demo zum Modul "WindowLists"');
    WriteLn;
    WriteString ("Drcke 'Q' zum Beenden,");
    WriteLn;
    WriteString ("Laufwerksbuchstaben ('A'-'P'), um Fenster zu ”ffnen");
    WriteLn;
    
    Worker[0].event := keyboard;
    Worker[0].keyHdler := KeyHdler;
    Worker[1].event := mouseButton;
    Worker[1].butHdler := ButHdler;
    Quit := FALSE;
    REPEAT
      HandleEvents (2, MButtonSet{msBut1}, MButtonSet{msBut1},
                    lookForEntry, Rect (0,0,0,0),
                    lookForEntry, Rect (0,0,0,0),
                    0L,
                    Worker, 0);
    UNTIL Quit;
    
    IF ~ Empty (WEnv^.path) THEN killList (WEnv) END;
    DeleteWL (WEnv^.wl);
  END;
  DISPOSE (WEnv);
END WLTest.

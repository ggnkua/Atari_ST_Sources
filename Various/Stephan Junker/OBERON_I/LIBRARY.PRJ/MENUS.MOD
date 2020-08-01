MODULE Menus;  (* Stephan Junker  30.1.93 / 25.11.93 *)


IMPORT S:=SYSTEM, Str:=Strings, Objc, Evnt, Mn:=Menu, DCL, Task,
       Error, GemApp;


CONST keychars = '  1234567890ž   QWERTZUIOPš+  ASDFGHJKL™Ž  ~YXCVBNM';
      zifchars = '()/*7894561230';


TYPE
  MenuProc* = PROCEDURE ();
  procdef   = RECORD (DCL.Element)
                Shifts : SET;
                Scan   : INTEGER;
                Title  : INTEGER;
                Entry  : INTEGER;
                Proc   : MenuProc;
              END(*RECORD*);
  proc      = POINTER TO procdef;
  Menu*     = POINTER TO MenuDesc;
  MenuDesc* = RECORD
                Procs : DCL.List;
                Tree  : S.PTR;
              END;


VAR
  title*,entry* : INTEGER;
  (*
   contain the values of the selected menu item if a procedure stored
   with Menu.Set is called
   *)

  ptitle, pentry: ARRAY 10 OF INTEGER; ptex: INTEGER;

  Active: Menu;
  taskMenu: ARRAY 10 OF Menu;



PROCEDURE(m : Menu) Init*(objTree : S.PTR);
 BEGIN
  m.Tree := objTree;
  NEW( m.Procs); m.Procs.Init;
 END Init;


PROCEDURE(m : Menu) Set*(title,entry : INTEGER; Proc : MenuProc);
  (* stores a procedure which is called if the desired menu item is
     selected. If the corresponding menu entry contains a key definition,
     the procedure is also called if the key is pressed *)
  VAR p : proc;

 PROCEDURE GetScan(c : CHAR; String : ARRAY OF CHAR) : INTEGER;
   VAR i : INTEGER;
  BEGIN
   i := 0; Str.Cap(c);
   WHILE String[i] # 0X DO
     IF String[i] = c THEN RETURN i END(*IF*);
     INC(i);
   END(*WHILE*);
   RETURN -100
  END GetScan;

 PROCEDURE GetKey;
  VAR Ptr : Objc.ptr;
      i   : INTEGER;
      Zifferblock,Reading,KeyRead : BOOLEAN;
      StringPtr : Str.ptr;
      Shifts : SET; Scan : INTEGER;

  PROCEDURE ClearStored;
   BEGIN
    Shifts := {}; Zifferblock := FALSE;
    KeyRead := FALSE; Reading := FALSE;
   END ClearStored;

  BEGIN
   StringPtr := Objc.GetSpec(m.Tree,entry);
   i := 0; ClearStored;
   WHILE StringPtr^[i] # 0X DO
     IF StringPtr^[i] # " " THEN
       IF KeyRead THEN ClearStored END;
       IF StringPtr^[i] = "^" THEN
         Reading := TRUE;
         INCL(Shifts,Evnt.CONTROL)
       ELSIF StringPtr^[i] = 7X THEN
         Reading := TRUE;
         INCL(Shifts,Evnt.ALTERNATE)
       ELSIF StringPtr^[i] = 1X THEN
         Reading := TRUE;
         INCL(Shifts,Evnt.LSHIFT)
       ELSIF StringPtr^[i] = "#" THEN
         Reading := TRUE;
         Zifferblock := TRUE;
       ELSIF (StringPtr^[i] = "F") AND
             (StringPtr^[i+1] >= "1") AND (StringPtr^[i+1] <= "9") THEN
         INC(i);
         Scan := ORD(StringPtr^[i]) + 0AH;
         IF (StringPtr^[i] = "1") AND (StringPtr^[i+1] = "0") THEN
           INC(i); Scan := 44H;
         END(*IF*);
         IF Evnt.LSHIFT IN Shifts THEN INC(Scan,19H) END(*IF*);
         KeyRead := TRUE;
       ELSIF Reading THEN
         IF Zifferblock THEN Scan := GetScan(StringPtr^[i],zifchars) + 63H;
         ELSE Scan := GetScan(StringPtr^[i],keychars) END(*IF*);
         KeyRead := TRUE;
       END(*IF*);
     END;
     INC(i);
   END(*WHILE*);
   IF KeyRead THEN
     p.Shifts := Shifts; p.Scan := Scan;
   END;
  END GetKey;

 BEGIN
  NEW(p); m.Procs.Add(p);
  p.Title := title; p.Entry := entry; p.Proc := Proc; p.Scan := 0;
  GetKey;
 END Set;


PROCEDURE PushTitleEntry;
 BEGIN
  ptitle[ptex] := title; pentry[ptex] := entry; INC(ptex);
 END PushTitleEntry;


PROCEDURE PopTitleEntry;
 BEGIN
  DEC(ptex); title := ptitle[ptex]; entry := pentry[ptex];
 END PopTitleEntry;


PROCEDURE(m : Menu) Show*;
  (* shows a menu bar *)
 BEGIN
  PushTitleEntry;
  Active := m; Mn.Show(m.Tree);
 END Show;


PROCEDURE Hide*();
  (* hides the menu bar which was shown last *)
 BEGIN
  IF Active # NIL THEN
    Mn.Hide(Active.Tree); Active := NIL;
    PopTitleEntry;
  END(*IF*);
 END Hide;


PROCEDURE Init;
 BEGIN
  taskMenu[ Task.level-1] := Active;
  IF Active # NIL THEN
    Mn.Hide(Active.Tree); Active := NIL;
  END;
 END Init;


PROCEDURE Exit;
 BEGIN
  Hide;
  IF Task.level > 0 THEN
    Active := taskMenu[ Task.level-1];
    IF Active # NIL THEN Active.Show END;
  END;
 END Exit;


PROCEDURE StoreTitleEntry(t, e: INTEGER);
 BEGIN
  title := t; entry := e;
 END StoreTitleEntry;


PROCEDURE HandleMsgEvent() : BOOLEAN;
  VAR
    p : proc;
 BEGIN
  IF (GemApp.message[0] = Evnt.MNSELECTED) & (Active # NIL) THEN
    p := Active.Procs.root;
    StoreTitleEntry( GemApp.message[3], GemApp.message[4]);
    WHILE p # NIL DO
      IF p.Entry = entry THEN
        p.Proc();
        Mn.Tnormal(Active.Tree,title);
        RETURN TRUE
      END(*IF*);
      p := p.next;
    END(*WHILE*);
  END;
  RETURN FALSE
 END HandleMsgEvent;


PROCEDURE HandleKeyEvent() : BOOLEAN;
  VAR
    p : proc;
 BEGIN
  IF (Active # NIL) THEN
    p := Active.Procs.root;
    WHILE (p # NIL)
       & ((p.Shifts # GemApp.shiftbits) OR (p.Scan # GemApp.scancode)) DO
      p := p.next
    END;
    IF p # NIL THEN
      StoreTitleEntry(p.Title, p.Entry);
      Mn.Tinverted(Active.Tree,title);
      p.Proc();
      Mn.Tnormal(Active.Tree,title);
      RETURN TRUE
    END;
  END;
  RETURN FALSE
 END HandleKeyEvent;


BEGIN
(* does not work correctly
  Task.StoreInit( Init);
  Task.StoreExit( Exit);
*)
  GemApp.messageProcs.AddProc( HandleMsgEvent);
  GemApp.keyboardProcs.AddProc( HandleKeyEvent);
END Menus.

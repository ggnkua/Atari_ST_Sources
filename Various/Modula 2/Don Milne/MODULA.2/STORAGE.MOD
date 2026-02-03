r
IMPLEMENTATION MODULE Storage;

FROM SYSTEM IMPORT ADDRESS, TSIZE;

IMPORT GEMDOS;

(*
FROM SYSCIO IMPORT Read, Write, 
                   WriteLn, WriteString, WriteLongCard,
                   GoToXY;
*)

TYPE MemRecord  = RECORD
       CASE BOOLEAN OF
         TRUE  : MemBaseAddr : ADDRESS;
       | FALSE : MemBase     : LONGCARD;
       END;
       MemSize : LONGCARD;
     END;
     UsrMemPtr    = POINTER TO UsrMemRecord;
     UsrMemRecord = RECORD
       State:       (Unknown, InUse, Free);
       Size:        LONGCARD;
       Prev:        UsrMemPtr;
       Next:        UsrMemPtr;
     END;

VAR SysMemory:  MemRecord;
    UsrOverHead:LONGCARD;
    UsrMemHead: UsrMemPtr;

    RetNil:     BOOLEAN;

PROCEDURE Allocate(VAR Addr : ADDRESS; Amount : LONGCARD);

VAR Tnode:      UsrMemPtr;
    Nnode:      UsrMemPtr;

BEGIN

  Tnode := UsrMemHead;

  WHILE (Tnode        # NIL)   AND
        ((Tnode^.State # Free) OR
         (Tnode^.Size  < (UsrOverHead + Amount))) DO
        Tnode := Tnode^.Next;
  END;

  IF Tnode = NIL
     THEN Addr := NIL;
     ELSE WITH Tnode^ DO
               Nnode := ADDRESS(LONGCARD(Tnode) + UsrOverHead + Amount);
               Nnode^.State := Free;
               Nnode^.Size  := Size - (UsrOverHead + Amount);
               Nnode^.Prev  := Tnode;
               Nnode^.Next  := Next;
               Size  := Amount;
               Next  := Nnode;
               State := InUse;
          END;
          Addr := ADDRESS(LONGCARD(Tnode) + UsrOverHead);
  END;

END Allocate;

PROCEDURE DeAllocate(VAR Addr : ADDRESS; Amount : LONGCARD);

VAR Tnode:      UsrMemPtr;

BEGIN

  IF (Addr = NIL) OR
     (Amount = 0)
     THEN RETURN;
  END;

  Tnode := ADDRESS(LONGCARD(Addr) - UsrOverHead);

  WITH Tnode^ DO
       State := Free;
       IF Prev # NIL
          THEN IF Prev^.State = Free
                  THEN Prev^.Size := Prev^.Size + UsrOverHead + Size;
                       Prev^.Next := Next;
               END;
       END;
       IF Next # NIL
          THEN IF Next^.State = Free
                  THEN Size := Size + UsrOverHead + Next^.Size;
                       Next := Next^.Next;
               END;
       END;
  END;

END DeAllocate;

PROCEDURE ALLOCATE(VAR Addr : ADDRESS; Size : CARDINAL);

BEGIN

  Allocate(Addr, LONGCARD(Size));

END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr : ADDRESS; Size : CARDINAL);

BEGIN

  DeAllocate(Addr, LONGCARD(Size));

END DEALLOCATE;

PROCEDURE CreateHeap(Amount : LONGCARD; GiveNIL : BOOLEAN) : BOOLEAN;

BEGIN

  IF GiveNIL
     THEN RetNil := TRUE;
     ELSE RetNil := FALSE;
  END;

  WITH SysMemory DO
       GEMDOS.Alloc(LONGCARD(-1),MemBaseAddr);
       MemSize := MemBase;
       IF MemSize < Amount
          THEN RETURN FALSE;
       END;
       MemSize := Amount;
       GEMDOS.Alloc(MemSize,MemBaseAddr);
  END;

  UsrMemHead := SysMemory.MemBaseAddr;

  WITH UsrMemHead^ DO
       State := Free;
       Size  := SysMemory.MemSize;
       Prev  := NIL;
       Next  := NIL;
  END;

  UsrOverHead := TSIZE(UsrMemRecord);

  RETURN TRUE;

END CreateHeap;

(*
PROCEDURE ReportMemory(ColOff : CARDINAL);

VAR Tnode:      UsrMemPtr;
    Nnode:      UsrMemPtr;
    c:          CARDINAL;

BEGIN

  FOR c := 1 TO 24 DO
      GoToXY(0 + ColOff,c); WriteString('                  ');
  END;

  Tnode := UsrMemHead;

  c := 1;

  WHILE (Tnode        # NIL) DO
        GoToXY(0 + ColOff,c); WriteLongCard(LONGCARD(Tnode),10);
        CASE Tnode^.State OF
          Unknown : WriteString(' Unknown');
        | Free    : WriteString(' Free');
        | InUse   : WriteString(' InUse');
        END;
        INC(c);
        Tnode := Tnode^.Next;
  END;

END ReportMemory;

PROCEDURE RunTest;

TYPE NewEntryPtr= POINTER TO NewEntryDef;
     NewEntryDef= RECORD
       Data:      ARRAY[1..100] OF CHAR;
       Prev:      NewEntryPtr;
       Next:      NewEntryPtr;
     END;

VAR c:          CARDINAL;
    NewEntryHead:NewEntryPtr;
    NewEntry:   NewEntryPtr;
    CurEntry:   NewEntryPtr;
    CReply:     CHAR;

BEGIN

  GoToXY(01,01); Write(CHR(27)); Write('E');

  IF NOT CreateHeap(128 * 1024,TRUE)
     THEN WriteString('CreateHeap Failure');
     ELSE NewEntryHead := NIL;
          c := 0;

          REPEAT ALLOCATE(NewEntry,TSIZE(NewEntryDef));
                 NewEntry^.Prev := NIL;
                 NewEntry^.Next := NIL;
                 IF NewEntryHead = NIL
                    THEN NewEntryHead := NewEntry;
                    ELSE CurEntry^.Next:= NewEntry;
                         NewEntry^.Prev:= CurEntry;
                 END;
                 CurEntry := NewEntry;
                 ReportMemory(20);
                 Write(CHR(13)); WriteLongCard(LONGCARD(NewEntry),10); WriteLn;
                 INC(c);
          UNTIL  (c = 10) OR
                 (NewEntry = NIL);

          WHILE CurEntry # NIL DO
                ReportMemory(40);
                GoToXY(01,01); Read(CReply);
                NewEntry := CurEntry^.Prev;
                DEALLOCATE(CurEntry,TSIZE(NewEntryDef));
                CurEntry := NewEntry;
          END;

          NewEntryHead := NIL;
          c := 0;

          REPEAT ALLOCATE(NewEntry,TSIZE(NewEntryDef));
                 NewEntry^.Prev := NIL;
                 NewEntry^.Next := NIL;
                 IF NewEntryHead = NIL
                    THEN NewEntryHead := NewEntry;
                    ELSE CurEntry^.Next:= NewEntry;
                         NewEntry^.Prev:= CurEntry;
                 END;
                 CurEntry := NewEntry;
                 ReportMemory(60);
                 Write(CHR(13)); WriteLongCard(LONGCARD(NewEntry),10); WriteLn;
                 INC(c);
          UNTIL  (c = 10) OR
                 (NewEntry = NIL);

  END;

  WriteLn;
  Read(CReply);

END RunTest;
*)

BEGIN

  RetNil := TRUE;

  WITH SysMemory DO
       MemBase := 0;
       MemSize := 0;
  END;

  UsrMemHead := NIL;

  (*RunTest;*)

END Storage.

Press <CR> to continue: 
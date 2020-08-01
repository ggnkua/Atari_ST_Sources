MODULE Storage;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |2.1.93   |correction for Oberon
S. Junker  |2.5.93   |level reset after exit
----------------------------------------------------------------------------
*)

IMPORT S := SYSTEM, Error, Task, DCL:=DoubleChainedList;

CONST segsize = 32000; seginx = segsize DIV 2;

TYPE allocseg   = RECORD(DCL.elem)
                    SegLen : LONGINT; (* Gesamtl„nge *)
                    Free   : INTEGER; (* Anzahl freie Bytes *)
                  END(*RECORD*);
     segptr     = POINTER TO allocseg;

VAR Allocs : segptr; Level  : INTEGER;
    PrevLev : ARRAY 100 OF INTEGER; plinx : INTEGER;
    PrevPLinx : ARRAY 20 OF INTEGER; pplinx : INTEGER;

PROCEDURE Set*(Lev : INTEGER);
 (* sets the level stored with every allocation. This offers the possibility
    to allocate several times and deallocate everything with FreeLevel.
    Lev should be higher than 100 or negative, because it is stored instead
    of the task number. Every Task.Init sets the level to the task number.
    If an allocation may not be deallocated on Task.Exit, the level can be
    changed to a negative number. This memory can only be deallocated by
    FreeLevel and program termination *)
 BEGIN
  PrevLev[plinx] := Level; INC(plinx); Level := Lev;
 END Set;

PROCEDURE Reset*;
 (* restores the level that was used before the last call of Set. Nesting
    allowed *)
 BEGIN
  DEC(plinx); Level := PrevLev[plinx];
 END Reset;

PROCEDURE- Malloc(NBytes : LONGINT) : LONGINT 72,1;

PROCEDURE- Mfree(Adr : S.PTR) : INTEGER 73,1;

PROCEDURE FreeRam* () : LONGINT;
 (* Return amount of available (GEMDOS) memory *)
 BEGIN
  RETURN Malloc(-1);
 END FreeRam;

PROCEDURE NewSegment(Length : LONGINT; VAR Segment : segptr) : BOOLEAN;
 (* allocate new segment mit size Length and initialize it *)
  VAR Seg : segptr;
 BEGIN
  Seg := Malloc(Length);
  IF Seg # NIL THEN Seg.SegLen := Length;
    DCL.New(Allocs,Seg,Level); Segment := Seg;
    RETURN TRUE
  END(*IF*);
  Error.NumOut(-39); RETURN FALSE
 END NewSegment;

PROCEDURE FindSpace(NumBytes : INTEGER) : LONGINT;
 (* find space in one of the segments. Allocate a new one if no space *)
  VAR Pos : INTEGER;
      Seg : segptr;
 BEGIN
  Seg := Allocs;
  WHILE Seg # NIL DO
    IF (Seg.Handle = Level) AND (Seg.Free >= NumBytes) THEN
      DEC(Seg.Free,NumBytes);
      RETURN S.VAL(LONGINT,Seg) + Seg.SegLen - (Seg.Free + NumBytes)
    END(*IF*);
    Seg := Seg.Next;
  END(*WHILE*);
  IF NOT NewSegment(segsize+SIZE(allocseg),Seg) THEN RETURN 0 END;
  Seg.Free := segsize - NumBytes; 
  RETURN S.VAL(LONGINT,Seg) + SIZE(allocseg);
 END FindSpace;

PROCEDURE Alloc*(NumBytes : LONGINT) : LONGINT;
 (* only for use in System. Users must use NEW and SYSTEM.NEW to allocate
    memory. Allocates desired amount of memory and returns address of the
    memory. If no memory is available, 0 is returned. NEW and SYSTEM.NEW
    check for 0 and call HALT(OUTOFMEM). This should show an error message
    and terminate the current task (see Task) *)
  VAR Seg : segptr;
 BEGIN
  INC(NumBytes, S.ANL(NumBytes,1) ); (* NumBytes even *)
  IF NumBytes > segsize THEN
    IF NOT NewSegment(NumBytes+SIZE(allocseg),Seg) THEN RETURN 0 END;
    Seg.Free := 0; 
    RETURN S.VAL(LONGINT,Seg) + SIZE(allocseg)
  END(*IF*);
  RETURN FindSpace( SHORT(NumBytes) )
 END Alloc;

PROCEDURE FreeLevel*(Level : INTEGER);
 (* free all memory allocated under Level *)
  VAR Seg,s : segptr; Adr : LONGINT;
 BEGIN
  Seg := Allocs;
  WHILE Seg # NIL DO s := Seg.Next;
    IF Seg.Handle = Level THEN
      DCL.Extract(Allocs,Seg); Error.NumOut( Mfree(Seg) );
    END(*IF*);
    Seg := s;
  END(*WHILE*);
 END FreeLevel;

PROCEDURE* FreeAll;
 (* frees all memory allocated under the current process *)
  VAR Seg,s : segptr;
 BEGIN
  IF Task.Closed THEN Allocs := NIL
  ELSE Seg := Allocs;
    WHILE Seg # NIL DO s := Seg.Next;
      IF (Seg.Task = Task.Current) AND (Seg.Handle >= 0) THEN
        DCL.Extract(Allocs,Seg); Error.NumOut( Mfree(Seg) );
      END;
      Seg := s;
    END(*WHILE*);
  END;
  IF Task.Current # 0 THEN DEC(pplinx); plinx := PrevPLinx[pplinx]; Reset END;
 END FreeAll;

PROCEDURE* Init;
 BEGIN
  Set(Task.Current); PrevPLinx[pplinx] := plinx; INC(pplinx);
 END Init;

BEGIN
  Task.FreeMem := FreeAll; Task.StoreInit(Init);
END Storage.

MODULE GC;

(*
 GC is the abbreviation of Garbage Collector. A garbage collector
 scans the memory for allocated data which is not referenced
 anymore. This data is then disposed. This GC offers a special feature:
 It installs a coroutine in module XCoroutines. If this coroutine is
 executed, it performs a small part of the collection and transfers
 execution to the previously active coroutine. This way, garbage is
 constantly removed without the user taking notice of it. It is of course
 possible to do a complete collection at once. When memory gets short, the
 collector is automatically called by Storage.
 *)


IMPORT
  S:=SYSTEM, Storage, Sys, Program;



CONST
  data = "D";
  BaseTypesOffset = 46;



TYPE
  PtrProc* = PROCEDURE (ptr: S.PTR);

  NotifyList = POINTER TO NotifyListDesc;
  NotifyListDesc = RECORD
    next: NotifyList;
    proc: PtrProc;
    ptr : S.PTR;
  END;



VAR
  hasDisposed: BOOLEAN;
  previousCollect: Storage.GarbageCollectProc;
  notifyList: NotifyList;



PROCEDURE StartAddress() : S.PTR;
 BEGIN
   RETURN S.ADR(data) + 14;
 END StartAddress;


(* PROCEDURE MarkMemory *)

  PROCEDURE MarkCollect(mem: Storage.MemEntry);
   BEGIN
    IF mem.magic = Storage.UsedMark THEN
      mem.magic := Storage.CollMark
    END;
   END MarkCollect;

PROCEDURE MarkMemory;
 BEGIN
  Storage.Do( MarkCollect);
 END MarkMemory;


PROCEDURE ListPointersDo(typ: INTEGER; adr, list: S.PTR; aBlock: PtrProc);
  VAR
    ptr, tdp, base, firstList: S.PTR;
    offset, numElem, size, baseOffset: LONGINT;
    type: INTEGER;
 BEGIN
  baseOffset := BaseTypesOffset;
  firstList := list;
  LOOP
    DEC(list, 4);
    S.GET(list, offset);
    IF offset = -1 THEN (*  end of list *)
      IF typ = 9 THEN
        S.GET( firstList + baseOffset, list);
        INC(baseOffset, 4);
        IF list = firstList THEN EXIT END;
      ELSE
        EXIT
      END;
    ELSIF offset > 0 THEN (* a type descriptor *)
      tdp := offset;
      DEC(list, 4); S.GET( list, offset);
      S.GET(tdp+4, type);
      IF type = 9 THEN (* record with pointers *)
        ListPointersDo( 9, adr+offset, tdp, aBlock);
      ELSIF type = 10 THEN (* fixed array with pointers *)
        S.GET(tdp+10, base);
        S.GET(tdp+6, numElem);
        ArrayPointersDo( adr+offset, base, numElem, aBlock);
      END;
    ELSE
      aBlock(adr-offset)
    END;
  END;
 END ListPointersDo;


PROCEDURE ArrayPointersDo(adr, tdp: S.PTR; numElem: LONGINT; aBlock: PtrProc);
  VAR
    size: LONGINT;
    type: INTEGER;
 BEGIN
  IF tdp = -1 THEN (* array of pointer *)
    WHILE numElem > 0 DO
      aBlock(adr);
      INC(adr, 4);
      DEC(numElem);
    END;
  ELSE
    S.GET( tdp, size);
    WHILE numElem > 0 DO
      TdpPointersDo(adr, tdp, aBlock); INC(adr, size);
      DEC(numElem);
    END;
  END;
 END ArrayPointersDo;


PROCEDURE OpenArrayPointersDo(adr, tdp: S.PTR; aBlock: PtrProc);
  VAR
    numElem, num, dim: LONGINT;
    type: INTEGER;
 BEGIN
  S.GET( tdp+6, tdp);
  S.GET( adr-8, numElem);
  dim := 12;
  LOOP
    IF tdp = -1 THEN EXIT END;
    S.GET( tdp+4, type);
    IF type # 12 THEN EXIT END;
    S.GET( adr-dim, num);
    numElem := numElem * num;
  END;
  ArrayPointersDo(adr, tdp, numElem, aBlock);
 END OpenArrayPointersDo;


PROCEDURE TdpPointersDo(adr, tdp: S.PTR; aBlock: PtrProc);
  VAR
    type: INTEGER;
    numElem: LONGINT;
 BEGIN
  S.GET(tdp+4, type);
  IF ODD(type) THEN  (* record *)
    ListPointersDo(type, adr, tdp, aBlock);
  ELSIF type = 12 THEN (* open array with pointers *)
    OpenArrayPointersDo(adr, tdp, aBlock);
  ELSIF type = 10 THEN (* fixed array with pointers *)
    S.GET( tdp+6, numElem);
    S.GET(tdp+10, tdp);
    ArrayPointersDo(adr, tdp, numElem, aBlock);
  END;
 END TdpPointersDo;


PROCEDURE ScanMem(ptr: S.PTR; mem: Storage.MemEntry);
  VAR
    adr: S.PTR;
 BEGIN
  IF mem.magic = Storage.CollMark THEN
    mem.magic := Storage.UsedMark;
    S.GET( ptr-4, adr);
    IF Program.AddressInData(adr) THEN
      TdpPointersDo(ptr, adr, Scan);
    END;
  END;
 END ScanMem;


(* PROCEDURE ScanModules; *)

  PROCEDURE Scan(ptr: S.PTR);
    VAR
      mem: Storage.MemEntry;
      adr: S.PTR;
   BEGIN
    S.GET(ptr, ptr);
    IF ptr = NIL THEN RETURN END;
    IF Storage.IsMemAdr(ptr, mem) THEN ScanMem(ptr, mem) END;
   END Scan;

PROCEDURE ScanModules;
  VAR
    currentVariable, currentList: S.PTR;
 BEGIN
  currentList := StartAddress();
  REPEAT
    S.GET( currentList-4, currentVariable);
    ListPointersDo(0, currentVariable, currentList-4, Scan);
    S.GET(currentList, currentList);
  UNTIL currentList = StartAddress();
 END ScanModules;


PROCEDURE ScanStack;
  VAR
    end: LONGINT;
    mem: Storage.MemEntry;
 BEGIN
  end := Sys.stackEnd + Sys.stackSize;
(*$-p *)
  ASSEMBLER
    MOVE.L  A7,A0
  loop:
    CMPA.L  end,A0
    BHS.B   exit

    MOVE.L  (A0),D0
    BTST    #0,D0
    BNE.B   noPtr

    MOVE.L  A0,-(SP)
    MOVE.L  D0,-(SP)
    PEA     mem
    JSR     Storage.IsMemAdr
    ADDQ.L  #8,SP
    MOVE.L  (SP)+,A0

    TST.B   D0
    BEQ.B   noPtr

    MOVE.L  A0,-(SP)
    MOVE.L  mem,-(SP)
    BSR     ScanMem
    ADDQ.L  #4,SP
    MOVE.L  (SP)+,A0

    ADDQ.L  #4,A0
    BRA.B   loop
  noPtr:
    ADDQ.L  #2,A0
    BRA.B   loop
  exit:

  END;
(*$+p *)
 END ScanStack;


PROCEDURE Finalize(mem: Storage.MemEntry);
  VAR
    tdp, obj: S.PTR;
    entry, prev: NotifyList;
 BEGIN
  S.GET( S.VAL( S.PTR, mem) + 6, tdp);
  obj := S.VAL( S.PTR, mem) + 10;
  prev := S.ADR( notifyList);
  entry := notifyList;
  WHILE entry # NIL DO
    IF (entry.ptr = obj) THEN
      entry.proc( obj);
      Storage.Dispose(entry);
      prev.next := entry.next (* remove notifier *)
    ELSE
      IF (entry.ptr = tdp) THEN entry.proc( obj) END;
      prev := prev.next;
    END;
    entry := entry.next;
  END;
  Storage.DisposeMem(mem);
  hasDisposed := TRUE;
 END Finalize;


(* PROCEDURE FreeMemory; *)

  PROCEDURE Free(mem: Storage.MemEntry);
   BEGIN
    IF mem.magic = Storage.CollMark THEN
      Finalize(mem);
    END;
   END Free;

PROCEDURE FreeMemory;
 BEGIN
  Storage.Do( Free);
 END FreeMemory;


PROCEDURE Collect*;
(*
 Collect all garbage.
 *)
 BEGIN
  MarkMemory;
  ScanModules;
  ScanStack;
  FreeMemory;
 END Collect;


PROCEDURE AllPointersDo*(proc: PtrProc);
(*
 Execute proc for every pointer known to the system. The pointer given to
 proc is a pointer to the pointer! This way it is possible to change all
 references of an object to another object (but time consuming).
 *)
  VAR
    list, adr: S.PTR;
 BEGIN
  list := StartAddress();
  REPEAT
    S.GET( list-4, adr);
    ListPointersDo( 0, adr, list, proc);
    S.GET( list, list);
  UNTIL list = StartAddress();
 END AllPointersDo;


PROCEDURE NotifyIfCollectable*(obj: S.PTR; proc: PtrProc);
(*
 Store proc to be called if an object of the same kind as obj is
 collectable. You have to allocate a new object for obj.
 *)
  VAR
    entry: NotifyList;
    tdp  : S.PTR;
 BEGIN
  ASSEMBLER
    MOVE.L  12(A6),A0
    MOVE.L  -4(A0),tdp
  END;
  NEW(entry); entry.proc := proc; entry.ptr := tdp;
  entry.next := notifyList;
  notifyList := entry;
 END NotifyIfCollectable;


PROCEDURE RemoveNotifyProc*(proc: PtrProc);
(*
 Remove proc from the list of procedures to notify.
 *)
  VAR
    prev, curr: NotifyList;
 BEGIN
  prev := S.ADR( notifyList );
  curr := notifyList;
  WHILE curr # NIL DO
    IF curr.proc = proc THEN
      prev.next := curr.next;
    ELSE
      prev := curr;
    END;
    curr := curr.next;
  END;
 END RemoveNotifyProc;


PROCEDURE RegisterObject*(obj: S.PTR; finalizer: PtrProc);
(*
 Register <finalizer> to be called if <obj> is going to be collected.
 *)
  VAR
    entry: NotifyList;
 BEGIN
  NEW(entry); entry.proc := finalizer; entry.ptr := obj;
  entry.next := notifyList;
  notifyList := entry;
 END RegisterObject;


PROCEDURE CollectGarbage() : BOOLEAN;
 BEGIN
  hasDisposed := FALSE;
  Collect;
  IF hasDisposed THEN RETURN TRUE END;
  RETURN previousCollect();
 END CollectGarbage;


BEGIN
  previousCollect := Storage.CollectGarbage;
  Storage.CollectGarbage := CollectGarbage;
END GC.
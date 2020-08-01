MODULE Storage; (* SJ 11.3.95 *)


(*
 Storage implements memory management.

 Basic technique: Memory below MaxBlockAllocSize is allocated in blocks
 of size BlockSize. More memory is allocated directly by GEMDOS. All blocks
 are entered in a linear list with blockRoot as root.

 Storage usually needs 6 bytes memory overhead for every allocation.
 These are 2 bytes magic word, 2 bytes length of the previous allocation,
 and 2 bytes length of the current allocation.

 If you store data in memory which should be disposed on memory shortage,
 follow these rules:
 Store the contents of Storage.CollectGarbage in a procedure variable.
 Enter your own procedure in Storage.CollectGarbage. If this procedure is
 called, free memory and return true (= memory has been disposed). If you
 have no memory to dispose, return the value returned by the procedure
 previously stored. Here is an example:

  VAR
    previousCollect: Storage.GarbageCollectProc;

  PROCEDURE FreeSomething() : BOOLEAN;
  (*
   Free a part of the allocated memory and return true if something could
   be removed.
   *)
   BEGIN
    ...
   END FreeSomething;

  PROCEDURE Collect() : BOOLEAN;
   BEGIN
    IF FreeSomething() THEN RETURN TRUE END;
    RETURN previousCollect();
   END Collect;

  BEGIN
    previousCollect := Storage.CollectGarbage;
    Storage.CollectGarbage := Collect;
  END .

 If CollectGarbage returns false, there is no more memory to dispose and
 HALT(Sys.OUTOFMEM) is called.

 Storage uses magic words to identify correct memory locations. If a wild
 running program destroys memory, it might be detected by Storage and
 HALT(Sys.MEMERR) is called. There is no correction possibility and
 resuming program execution will result in severe system errors.

 Note: Most of the exported identifiers are for use by the garbage
 collector.
 *)

(*
 Interna:
 The block contains at least two memory entries: Immediately behind the
 block header is the first entry with .psize = 0. At the end of the block,
 there is a second entry which has .nsize = 0. This way, the beginning and
 end of a block can be detected without knowing the first and last address.
 *)


IMPORT
  S:=SYSTEM, Sys, Memory, GEMDOS;


CONST
  NFA = 10;
  BlockSize = 32*1024; (* 10 K <= BlockSize <= 128 K *)
  BlockHeaderSize = 12;
  BlockDataSize = S.VAL( INTEGER, BlockSize-BlockHeaderSize);
    (* must be below 32K (MemEntry.size) *)
  MaxBlockAllocSize = BlockSize * 3 DIV 4;

  (* magic numbers *)
  FreeMark* = 6543H; UsedMark* = 6544H; CollMark* = 6545H;
  FinalMark* = 6546H; SysMark* = 6547H;
  FirstMagic = FreeMark; LastMagic = SysMark; (* allowed range *)

  (* TD offsets *)
  TDLength = 0; TDType = 4;
  RTDName = 6; RTDBaseTyps = 46; RTDTBPs = 86;
  ATDNofel = 6; ATDBaseTyp = 10;
  OTDBaseTypSize = 0; OTDBaseTyp = 6;
  TDTRecord = 0; TDTArray = 1; TDTOpenArr = 2; TDTHasPtr = 3;


TYPE
  Block* = POINTER TO BlockHeader;
  BlockHeader* = RECORD
    next, prev: Block;
    size: LONGINT;
  END;

  MemEntryDesc* = RECORD
    magic-: INTEGER;
    psize-: INTEGER;
    nsize-: INTEGER;
  END;
  MemEntry* = POINTER TO MemEntryDesc;

  MemProc* = PROCEDURE (mem: MemEntry);
  BlockProc* = PROCEDURE (block: Block);
  GarbageCollectProc* = PROCEDURE() : BOOLEAN;



VAR
  CollectGarbage*: GarbageCollectProc;
  (*
   To be set by the GC. You may link a different procedure collecting your
   own garbage.
   *)
  keepFree*: LONGINT;
  (*
   Keep the amount of memory specified by this variable available by GEMDOS
   in order to execute other programs. Default: 200K.
   *)
  blockRoot: Block;
  currentMemEntry: MemEntry;
  largestPreviousFree: LONGINT;



PROCEDURE New*(tdptr: S.PTR; VAR ptr: S.PTR); (* first proc number! *)
(*
 IF tdp describes an open array, the lengths in the different dimensions
 are found above tdp as longints.
 *)
  VAR
    size, dimlen, bsize, addsize, i: LONGINT;
    type: INTEGER;
    set : SET;
    dimptr, tdp: S.PTR;
 BEGIN
  addsize := 4; (* tdp *)
  S.GET( tdptr + TDType, type);
  set := S.VAL( SET, LONG( type));
  IF TDTOpenArr IN set THEN
    tdp := tdptr;
    dimptr := S.ADR( tdptr) + 4;
    size := 1;
    REPEAT
      INC(addsize, 4);
      S.GET( dimptr, dimlen); INC(dimptr, 4);
      size := size * dimlen;
      S.GET( tdp + OTDBaseTypSize, bsize);
      S.GET( tdp + OTDBaseTyp, tdp);
    UNTIL tdp = -1;
    size := size * bsize;
  ELSE
    S.GET( tdptr, size);
  END;
  INC(size, addsize);  (* for tdptr *)
  Allocate( size, ptr);
  IF TDTOpenArr IN set THEN
    i := addsize - 4;
    dimptr := S.ADR( tdptr) + i;
    REPEAT
      S.GET( dimptr, dimlen); DEC(dimptr, 4);
      S.PUT( ptr, dimlen); INC(ptr, 4);
      DEC(i, 4);
    UNTIL i <= 0;
  END;
  S.PUT( ptr, tdptr); INC(ptr, 4);
  IF TDTHasPtr IN set THEN
    Memory.Fill(ptr, size-addsize, 0);  (* pointers initialized NIL *)
  END;
 END New;


PROCEDURE SNew*(size: LONGINT; VAR ptr: S.PTR); (* second proc number! *)
 BEGIN
  Allocate( size, ptr);
  S.PUT(ptr-SIZE(MemEntryDesc), SysMark)
 END SNew;


PROCEDURE Dispose*(ptr: S.PTR); (* third proc number! *)
  VAR
    mem: MemEntry;
 BEGIN
  IF IsMemAdr(ptr, mem) THEN
    DisposeMem( mem);
  ELSE
    HALT(Sys.NOMEMADR)
  END;
 END Dispose;

(*$-p *)

PROCEDURE TestMem(mem: S.PTR) : BOOLEAN;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A0
    MOVE.W  (A0),D0
    CMPI.W  #FirstMagic,D0
    BLO.B   error

    CMPI.W  #LastMagic,D0
    BHI.B   error

    MOVEQ   #1,D0
    RETURN

  error:
    MOVEQ   #0,D0
    RETURN

  END;
 END TestMem;


PROCEDURE CheckMem(mem: S.PTR);
 BEGIN
  ASSEMBLER

    MOVE.L  mem,-(SP)
    BSR     TestMem
    ADDQ.L  #4,SP
    TST.B   D0
    BNE.B   end

    MOVE.W  #Sys.MEMERR,-(SP)
    JSR     Sys.halt
    ADDQ.L  #2,SP

  end:

  END;
 END CheckMem;


PROCEDURE Do*(proc: MemProc);
(*
 Execute proc for every memory entry with that entry as parameter.
 Use assembler for speed. Check for destroyed memory.
 *)
 BEGIN
  ASSEMBLER

    MOVE.L  blockRoot,A0    ; A0 = ^current block

  blockLoop:
    MOVE.L  A0,D0
    BEQ.B   end

    LEA     BlockHeaderSize(A0),A1  ; A1 = ^current memory

  memLoop:
    MOVEM.L A0-A1,-(SP)
    MOVE.L  A1,-(SP)
    BSR     CheckMem

    MOVE.L  proc,A0       ; A1 still on stack
    JSR     (A0)
    ADDQ.L  #4,SP
    MOVEM.L (SP)+,A0-A1

    MOVEQ   #0,D0
    MOVE.W  4(A1),D0
    ADD.L   D0,D0
    ADDA.L  D0,A1         ; next mem

    TST.W   4(A1)         ; nsize = 0 -> end
    BNE.B   memLoop

    MOVE.L  (A0),A0       ; next block
    BRA.B   blockLoop

  end:

  END;
 END Do;


PROCEDURE IsMemAdr*(ptr: S.PTR; VAR mem: MemEntry) : BOOLEAN;
(*
 Answer true if ptr marks the start of a memory entry and store the memory
 entry in mem.
 *)
 BEGIN
  (*
   Don't use Do because not every block needs to be checked.
   *)
  ASSEMBLER

    MOVE.L  ptr,D1          ; to compare
    MOVE.L  blockRoot,A0    ; A0 = ^current block

  blockLoop:
    MOVE.L  A0,D0
    BEQ.B   notFound        ; no block found

    CMP.L   D0,D1
    BLO.B   nextBlock

    ADD.L   8(A0),D0
    CMP.L   D0,D1
    BHS.B   nextBlock

    ; the correct block is in A0

    LEA     BlockHeaderSize(A0),A1  ; A1 = ^current memory
    CMP.L   A1,D1
    BLO.B   nextBlock

    TST.L   2(A1)         ; 0 = large block
    BEQ.B   largeBlock

  memLoop:
(*  leaving this out accelerates GC by more than factor 2!
    MOVE.L  A1,-(SP)
    BSR     CheckMem
    MOVE.L  (SP)+,A1
*)
    MOVE.L  A1,D2

    MOVEQ   #0,D0
    MOVE.W  4(A1),D0
    ADD.L   D0,D0
    ADDA.L  D0,A1         ; next mem

    CMPA.L  ptr,A1
    BLS.B   nextMem

  found:
    MOVE.L  mem,A0
    MOVE.L  D2,(A0)
    MOVEQ   #1,D0
    RETURN

  nextMem:
    TST.W   4(A1)         ; nsize = 0 -> end
    BNE.B   memLoop

  notFound:
    MOVEQ   #0,D0
    RETURN

  largeBlock:
    MOVE.L  A1,D2
    MOVE.L  A0,D0
    ADD.L   8(A0),D0      ; end address
    CMP.L   D0,D1
    BLO.B   found

  nextBlock:
    MOVE.L  (A0),A0       ; next block
    BRA.B   blockLoop

  END;
 END IsMemAdr;


PROCEDURE NextEntryUnchecked(mem: MemEntry) : MemEntry;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A1
    MOVEQ   #0,D0
    MOVE.W  4(A1),D0
    ADD.L   D0,D0
    ADDA.L  D0,A1         ; next mem

    MOVE.L  A1,D0
    RETURN

  END;
 END NextEntryUnchecked;


PROCEDURE NextEntry(mem: MemEntry) : MemEntry;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A1
    MOVEQ   #0,D0
    MOVE.W  4(A1),D0
    ADD.L   D0,D0
    ADDA.L  D0,A1         ; next mem

    MOVE.L  A1,-(SP)
    BSR     CheckMem
    MOVE.L  (SP)+,D0
    RETURN

  END;
 END NextEntry;


PROCEDURE PrevEntry(mem: MemEntry) : MemEntry;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A1
    MOVEQ   #0,D0
    MOVE.W  2(A1),D0
    ADD.L   D0,D0
    SUBA.L  D0,A1         ; prev mem

    MOVE.L  A1,-(SP)
    BSR     CheckMem
    MOVE.L  (SP)+,D0
    RETURN

  END;
 END PrevEntry;


PROCEDURE MemSize(mem: MemEntry) : LONGINT;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A1
    MOVEQ   #0,D0
    MOVE.W  4(A1),D0
    ADD.L   D0,D0
    RETURN

  END;
 END MemSize;


PROCEDURE FirstEntry(mem: MemEntry) : BOOLEAN;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A1
    TST.W   2(A1)
    SEQ     D0
    NEG.B   D0
    RETURN

  END;
 END FirstEntry;


PROCEDURE LastEntry(mem: MemEntry) : BOOLEAN;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A1
    TST.W   4(A1)
    SEQ     D0
    NEG.B   D0
    RETURN

  END;
 END LastEntry;


PROCEDURE CreateEntry( addr: S.PTR; psize, nsize: LONGINT);
 BEGIN
  ASSEMBLER

    MOVE.L  addr,A1
    MOVE.W  #FreeMark,(A1)+
    MOVE.L  psize,D0
    LSR.L   #1,D0
    MOVE.W  D0,(A1)+
    MOVE.L  nsize,D0
    LSR.L   #1,D0
    MOVE.W  D0,(A1)+

  END;
 END CreateEntry;


PROCEDURE SetMemSize( addr: S.PTR; nsize: LONGINT);
 BEGIN
  ASSEMBLER

    MOVE.L  addr,A1
    MOVE.L  nsize,D0
    LSR.L   #1,D0
    MOVE.W  D0,4(A1)

  END;
 END SetMemSize;


PROCEDURE SetPrevSize( addr: S.PTR; psize: LONGINT);
 BEGIN
  ASSEMBLER

    MOVE.L  addr,A1
    MOVE.L  psize,D0
    LSR.L   #1,D0
    MOVE.W  D0,2(A1)

  END;
 END SetPrevSize;


PROCEDURE BlockOf(mem: MemEntry) : Block;
 BEGIN
  ASSEMBLER

    MOVE.L  mem,A1

  memLoop:
    MOVEQ   #0,D0
    MOVE.W  2(A1),D0
    BEQ.B   end

    ADD.L   D0,D0
    SUBA.L  D0,A1         ; prev mem

    MOVE.L  A1,-(SP)
    BSR     CheckMem
    MOVE.L  (SP)+,A1
    BRA.B   memLoop

  end:
    LEA     -BlockHeaderSize(A1),A1
    MOVE.L  A1,D0
    RETURN

  END;
 END BlockOf;

(*$+p *)

PROCEDURE RemoveBlock(block: Block);
 BEGIN
  IF block.prev = NIL THEN
    blockRoot := block.next;
  ELSE
    block.prev.next := block.next
  END;
  IF block.next # NIL THEN
    block.next.prev := block.prev
  END;
  IF (S.VAL( S.PTR, currentMemEntry) < S.VAL( S.PTR, block) + block.size)
      & (S.VAL( S.PTR, currentMemEntry) >= S.VAL( S.PTR, block)) THEN
    currentMemEntry := NIL
  END;
  IF GEMDOS.Mfree( block) = -40 THEN
    HALT(Sys.NOMEMADR)
  END;
 END RemoveBlock;


PROCEDURE DisposeMem*(mem: MemEntry);
  VAR
    pmem, nmem: MemEntry;
    memSize: LONGINT;
 BEGIN
  mem.magic := FreeMark;
  IF mem.nsize = 0 THEN  (* marks long block *)
    RemoveBlock( BlockOf(mem) )
  ELSE
    nmem := NextEntry(mem);
    IF ~FirstEntry(mem) THEN
      pmem := PrevEntry(mem);
      IF pmem.magic = FreeMark THEN
        INC( pmem.nsize, mem.nsize);
        INC( nmem.psize, mem.psize);
        mem := pmem;
      END;
    END;
    IF ~LastEntry(nmem) & (nmem.magic = FreeMark) THEN
      IF nmem = currentMemEntry THEN currentMemEntry := mem END;
      INC( mem.nsize, nmem.nsize);
      nmem := NextEntry(mem);
      nmem.psize := mem.nsize;
    END;
    IF FirstEntry(mem) & LastEntry(nmem) THEN (* completely free *)
      RemoveBlock( BlockOf(mem) );
    ELSE
      memSize := MemSize( mem);
      IF memSize > largestPreviousFree THEN
        largestPreviousFree := memSize;
      END;
    END;
  END;
 END DisposeMem;


PROCEDURE MarkNotCollectable*(ptr: S.PTR);
(*
 Mark the object identified by ptr to be not collectable. This must be done
 if the pointer only exists on the stack, i.e. in local variables. Then you
 must prevent the object from being collected on an out of memory
 collection. There might be other cases when this is necessary.
 *)
  VAR
    mem: MemEntry;
 BEGIN
  IF IsMemAdr(ptr, mem) THEN
    mem.magic := SysMark
  END;
 END MarkNotCollectable;


PROCEDURE AllocNewBlock(size: LONGINT) : BOOLEAN;
  VAR
    block: Block;
    d: INTEGER;
    memSize: LONGINT;
 BEGIN
  block := GEMDOS.Malloc(size);
  IF (block = NIL) OR (GEMDOS.Malloc(-1) < keepFree) THEN
    IF block # NIL THEN d := GEMDOS.Mfree(block) END;
    IF ~CollectGarbage() THEN HALT(Sys.OUTOFMEM) END;
    RETURN FALSE
  ELSE
    block.next := blockRoot; block.prev := NIL;
    IF blockRoot # NIL THEN blockRoot.prev := block END;
    blockRoot := block; block.size := size;
    memSize := size - BlockHeaderSize - SIZE( MemEntryDesc);
    CreateEntry( S.VAL( S.PTR, block) + BlockHeaderSize, 0, memSize);
    CreateEntry( S.VAL( S.PTR, block) + size - SIZE( MemEntryDesc), memSize, 0);
    RETURN TRUE
  END;
 END AllocNewBlock;


PROCEDURE AllocateMem(mem: MemEntry; size: LONGINT);
  VAR
    memSize: LONGINT;
 BEGIN
  mem.magic := UsedMark;
  IF MemSize(mem) - SIZE(MemEntryDesc) > size THEN
    memSize := MemSize(mem);
    SetPrevSize( NextEntry(mem), memSize - size);
    SetMemSize( mem, size);
    CreateEntry( NextEntryUnchecked(mem), size, memSize - size);
  END;
 END AllocateMem;


PROCEDURE AllocSmall(size: LONGINT; VAR addr: S.PTR);
  VAR
    mem: MemEntry;
    largest: LONGINT;

  PROCEDURE SetCurrentMemEntry(mem: MemEntry);
   BEGIN
    currentMemEntry := NextEntry( mem);
    IF currentMemEntry.magic # FreeMark THEN
      currentMemEntry := NIL;
    END;
   END SetCurrentMemEntry;

  PROCEDURE ~CatchMem(mem: MemEntry);
    VAR
      memsize: LONGINT;
   BEGIN
    IF (mem.magic = FreeMark) THEN
      memsize := MemSize(mem);
      IF memsize > largest THEN largest := memsize END;
      IF (memsize >= size) THEN
        IF memsize = largestPreviousFree THEN
          DEC( largestPreviousFree, size)
        END;
        AllocateMem( mem, size);
        addr := mem;
        SetCurrentMemEntry( mem);
        RETURN ^
      END;
    END;
   END CatchMem;

 BEGIN
  LOOP
    (*check space in currentMemEntry *)
    IF (currentMemEntry # NIL) & (MemSize( currentMemEntry) >= size) THEN (* space enough *)
      AllocateMem(currentMemEntry, size);
      addr := currentMemEntry;
      SetCurrentMemEntry( currentMemEntry);
      RETURN;
    END;

    (* no space in currentMemEntry, check previous memory *)
    IF largestPreviousFree >= size THEN (* is possible but not guarenteed *)
      largest := 0;
      Do( CatchMem);
      largestPreviousFree := largest; (* not found enough *)
    END;

    (* allocate new block *)
    IF AllocNewBlock( BlockSize) THEN
      (* new block: enter in currentMemEntry *)
      currentMemEntry := S.VAL( S.PTR, blockRoot) + BlockHeaderSize;
    END;
  END;
 END AllocSmall;


PROCEDURE AllocBig(size: LONGINT; VAR addr: S.PTR);
(*
 Allocate from GEMDOS
 *)
  VAR
    mem: MemEntry;
 BEGIN
  REPEAT UNTIL AllocNewBlock(size + BlockHeaderSize);
  mem := S.VAL( S.PTR, blockRoot) + BlockHeaderSize;
  mem.magic := UsedMark;
  mem.psize := 0; mem.nsize := 0;
  addr := mem;
 END AllocBig;


PROCEDURE Allocate(size: LONGINT; VAR addr: S.PTR);
 BEGIN
  INC(size, SIZE(MemEntryDesc) );
  IF ODD(size) THEN INC(size) END;
  IF size <= MaxBlockAllocSize THEN
    AllocSmall( SHORT( size), addr);
  ELSE
    AllocBig( size, addr)
  END;
  INC(addr, SIZE(MemEntryDesc) );
 END Allocate;


PROCEDURE Statistics*(
    VAR freeMem, allocatedMem, adminMem, largestBlock : LONGINT);
(*
 Answer the free memory in freeMem and the allocated memory in
 allocatedMem. Answer the memory needed for administration in adminMem and
 the largest free block in largestBlock.
 *)
  VAR
    gmem : ARRAY 100 OF LONGINT;
    gfre : LONGINT;
    i, d : INTEGER;
    largest: LONGINT;
    keptFree: S.PTR;

  PROCEDURE ~Add( mem: MemEntry);
    VAR
      memSize: LONGINT;
   BEGIN
    memSize := MemSize( mem);
    IF mem.magic = FreeMark THEN
      INC( freeMem, memSize-SIZE(MemEntryDesc));
      IF memSize > largest THEN largest := memSize END;
    ELSE
      IF memSize = 0 THEN (* large block *)
        INC( allocatedMem, BlockOf( mem).size)
      ELSE
        INC( allocatedMem, memSize-SIZE(MemEntryDesc));
      END;
    END;
    INC( adminMem, SIZE(MemEntryDesc));
   END Add;

 BEGIN
  freeMem := 0;
  allocatedMem := 0;
  adminMem := 0;
  largestBlock := 0;
  largest := 0;
  Do( Add );
  largestPreviousFree := largest;

  keptFree := GEMDOS.Malloc(keepFree);
  gfre := GEMDOS.Malloc(-1);
  IF gfre > largest THEN largest := gfre END;
  i := 0;
  WHILE (i < 100) AND (gfre >= BlockSize) DO
    gmem[i] := GEMDOS.Malloc(gfre-100);
    INC(i);
    INC( freeMem, gfre);
    gfre := GEMDOS.Malloc(-1);
  END;
  WHILE i > 0 DO
    DEC(i);
    d := GEMDOS.Mfree(gmem[i]);
  END;
  d := GEMDOS.Mfree(keptFree);
  largestBlock := largest;
 END Statistics;


PROCEDURE AddBlocks*(root: Block);
(*
 To be used to enter the blocks already allocated by the loader.
 *)
  VAR
    block: Block;
 BEGIN
  IF root # NIL THEN
    block := root;
    WHILE block.next # NIL DO
      block := block.next;
    END;
    block.next := blockRoot; blockRoot := root;
  END;
 END AddBlocks;


PROCEDURE NoGarbageCollection() : BOOLEAN;
 BEGIN
  IF keepFree > 0 THEN
    DEC(keepFree, 100000);
    IF keepFree < 0 THEN keepFree := 0 END;
    RETURN TRUE
  END;
  RETURN FALSE
 END NoGarbageCollection;


BEGIN
  keepFree := 200000;
  CollectGarbage := NoGarbageCollection;
END Storage.
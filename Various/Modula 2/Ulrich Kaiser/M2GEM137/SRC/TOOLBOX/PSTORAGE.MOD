IMPLEMENTATION MODULE pSTORAGE;

(*
A portable Storage Module.

"(*Addr:= NIL;*)" means: "Addr:= NIL; isn't necessary"

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM SYSTEM IMPORT ADDRESS;

#ifdef LPRM2
IMPORT Heap;
#elif (defined FTLM2)

#else
IMPORT Storage;
#endif

#if (defined ANAM2) || (defined XAM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);

VAR Success: BOOLEAN;

BEGIN
  Storage.CondAllocate(Addr,Size,Success);
  IF NOT Success THEN
    Addr:= NIL;
  END;
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr,Size);
END DEALLOCATE;

#elif (defined TDIM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.ALLOCATE(Addr,LONGCARD(Size));
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr,LONGCARD(Size));
(*Addr:= NIL;*)
END DEALLOCATE;

#elif (defined FSTM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.ALLOCATE(Addr,Size);
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr,Size);
(*Addr:= NIL;*)
END DEALLOCATE;

#elif (defined MM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.ALLOCATE(Addr,Size);
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr,Size);
(*Addr:= NIL;*)
END DEALLOCATE;

#elif (defined LPRM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Addr:= NIL;
  Heap.Allocate(Addr,Size);
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Heap.Deallocate(Addr,Size);
  Addr:= NIL;
END DEALLOCATE;

#elif (defined SPCM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.ALLOCATE(Addr,Size);
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr); (* ! *)
END DEALLOCATE;

#elif (defined HM2) || (defined XHM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.ALLOCATE(Addr,Size);
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr,Size);
END DEALLOCATE;

#elif (defined LM2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  IF NOT Storage.Available(Size) THEN
    Addr:= NIL;
  ELSE
    Storage.ALLOCATE(Addr,Size);
  END;
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr,Size);
(*Addr:= NIL;*)
END DEALLOCATE;

#elif (defined TSM2_1)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  IF Storage.HeapAvail(Storage.MainHeap) <= VAL(CARDINAL,Size DIV 16) THEN
    Addr:= NIL;
  ELSE
    Storage.HeapAllocate(Storage.MainHeap,Addr,VAL(CARDINAL,Size DIV 16));
  END;
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.HeapDeallocate(Storage.MainHeap,Addr,VAL(CARDINAL,Size DIV 16));
(*Addr:= NIL;*)
END DEALLOCATE;

#elif (defined TSM2_2)
PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  IF NOT Storage.FarAvailable(Size) THEN
    Addr:= NIL;
  ELSE
    Storage.FarALLOCATE(Addr,Size);
  END;
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.FarDEALLOCATE(Addr,Size);
(*Addr:= NIL;*)
END DEALLOCATE;
#endif

#ifdef TDIM2
CONST HEAPSIZE = 10000H; (* 64kB *)

BEGIN
 IF NOT Storage.CreateHeap(HEAPSIZE,TRUE) THEN
   HALT;
 END;
#endif
END pSTORAGE.

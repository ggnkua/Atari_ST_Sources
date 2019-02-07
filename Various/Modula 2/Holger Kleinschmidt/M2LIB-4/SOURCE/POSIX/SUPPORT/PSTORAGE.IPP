IMPLEMENTATION MODULE pSTORAGE;
__IMP_SWITCHES__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif

/* if defined, use module 'mem' for storage allocation, otherwise use
 * M2-system's storage allocator.
 */
#if 0
#define __USE_MEM__
#endif

#if 0
#define _DEBUG
#endif

(*
A portable Storage Module.

"(*Addr:= NIL;*)" means: "Addr:= NIL; isn't necessary"

UK __DATE__ __TIME__
modified by hk
*)

#ifdef __USE_MEM__
#warning ...using 'mem' for storage allocation

FROM SYSTEM IMPORT ADDRESS;
FROM PORTAB IMPORT NULL;
IMPORT mem;
#ifdef _DEBUG
FROM DosIO IMPORT WriteString,WriteInt,WriteLn;
#endif

PROCEDURE ALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
#ifdef _DEBUG
WriteString("ALLOCATE: "); WriteInt(Size, 1); WriteLn;
#endif
  Addr:=mem.malloc(Size);
  IF Addr=NULL THEN
    Addr:=NIL;
  END;
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
#ifdef _DEBUG
WriteString("DEALLOCATE: "); WriteInt(Size, 1); WriteLn;
#endif
  mem.free(Addr);
  Addr:=NIL;
END DEALLOCATE;

#else
#warning ...using M2-system storage allocator

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
  IF ~Success THEN
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
  Storage.ALLOCATE(Addr,Size);
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR Addr: ADDRESS; Size: SIZETYPE);
BEGIN
  Storage.DEALLOCATE(Addr,Size);
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
  Addr:= NIL;
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
  IF ~Storage.Available(Size) THEN
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
  IF ~Storage.FarAvailable(Size) THEN
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
 IF ~Storage.CreateHeap(HEAPSIZE,TRUE) THEN
   HALT;
 END;
#endif
#endif /* __USE_MEM__ */
END pSTORAGE.

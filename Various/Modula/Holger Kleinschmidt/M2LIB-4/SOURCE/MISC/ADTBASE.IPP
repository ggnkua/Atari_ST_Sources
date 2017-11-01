IMPLEMENTATION MODULE ADTBase;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* Die einzelnen Heap-Bloecke der Speicherverwaltung werden in einer linearen*)
(* Liste verkettet, so dass lediglich ein Zeiger pro Heap-Block noetig ist.  *)
(* Ebenso werden die einzelnen Speicherbloecke innerhalb des Heap-Blocks in  *)
(* einer linearen Liste verkettet, indem jeder Block die Adresse des naech-  *)
(* sten freien Blocks enthaelt; dazu wird bei der Initialisierung in die     *)
(* ersten Bytes jedes Blocks die Adresse des physikalisch naechstliegenden   *)
(* Blocks geschrieben, und beim letzten Block wird NIL eingetragen zur Kenn- *)
(* zeichnung, dass in diesem Heap-Block nichts mehr frei ist. Wird bei der   *)
(* Speicheranforderung dieses NIL entdeckt, so wird ein neuer Heap-Block     *)
(* angefordert, und dessen Adresse im vorigen Block vermerkt.                *)
(* Die Liste der freien Bloecke wird nun stackartig verwaltet (auch ueber    *)
(* Heap-Block-Grenzen hinweg!), wobei "DEALLOC" die Push-Operation und       *)
(* "ALLOC" die Pop-Operation darstellt; der letzte mit "DEALLOC" freigege-   *)
(* bene Bereich wird also mit dem naechsten "ALLOC" wieder belegt. Die ge-   *)
(* naue Funktionsweise kann leicht aus dem Programmtext herausgelesen werden.*)
(* Da die Adressen nur fuer die Verbindung der freien Bloecke benoetigt wer- *)
(* den, koennen sie bei den belegten Bereichen dem freien Speicher zugeschla-*)
(* gen werden, so dass kein Speicher fuer die Verwaltung benoetigt wird.     *)
(* --------------------------------------------------------------------------*)
(* Okt-91 / 16-Dez-95, Holger Kleinschmidt                                   *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) TSIZE;

FROM PORTAB IMPORT
(* CONST*) MAXSIGNEDWORD, MAXUNSIGNEDWORD,
(* TYPE *) UNSIGNEDWORD, UNSIGNEDLONG;

FROM ISOStorage IMPORT
(* PROC *) ALLOCATE, DEALLOCATE;

IMPORT EXCEPTIONS;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  HeapPtr = POINTER TO ADDRESS; (* Fuer die Verkettung der Heap-Bloecke *)

  ADTHeap = POINTER TO HeapInfo;
  HeapInfo = RECORD
    esize    : UNSIGNEDWORD;
      (* Elementgroesse *)
    ecount   : UNSIGNEDWORD;
      (* Elemente pro Heap-Block *)
    bsize    : UNSIGNEDLONG;
      (* Heap-Block-Groesse *)
    firstblk : HeapPtr;
      (* erster Heap-Block *)
    free     : HeapPtr;
      (* naechster freier Speicherbereich (top of stack) *)
  END;

VAR
  ADTSource : EXCEPTIONS.ExceptionSource;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE newHeapBlock ((* EIN/AUS *) VAR blk  : HeapPtr;
                        (* EIN/ -- *)     elen : UNSIGNEDWORD;
                        (* EIN/ -- *)     ecnt : UNSIGNEDWORD;
                        (* EIN/ -- *)     blen : UNSIGNEDLONG );

VAR __REG__ newblk : HeapPtr;
    __REG__ cnt    : UNSIGNEDWORD;

BEGIN
 ALLOCATE(blk, blen);
 newblk := blk;
 cnt    := ecnt - 1;
 IF newblk # NIL THEN
   (* Die Verkettung zaehlt nicht zum freien Speicher *)
   newblk := ADDADR(newblk, TSIZE(HeapPtr));
   WHILE cnt > 0 DO
     (* Jeder Speicherbereich bekommt die Adresse des physikalisch
      * naechsten Speicherbereichs.
      *)
     newblk^ := ADDADR(newblk, elen);
     newblk  := newblk^;
     DEC(cnt);
   END;
   newblk^ := NIL; (* Kennzeichnung: letzter Speicherbereich im Heap-Block *)
 END; (* IF newblk *)
END newHeapBlock;

(*---------------------------------------------------------------------------*)

PROCEDURE InstallADTHeap ((* EIN/ -- *)     elemsize : CARDINAL;
                          (* EIN/ -- *)     blksize  : CARDINAL;
                          (* -- /AUS *) VAR heap     : ADTHeap;
                          (* -- /AUS *) VAR done     : BOOLEAN );

BEGIN
 done := FALSE;
 heap := NIL;
 IF   (elemsize = 0) OR (elemsize > VAL(CARDINAL,CAST(UNSIGNEDWORD,MAXSIGNEDWORD)))
   OR (blksize  = 0) OR (blksize  > VAL(CARDINAL,MAXUNSIGNEDWORD))
 THEN
   RETURN;
 END;

 IF elemsize < VAL(CARDINAL,TSIZE(ADDRESS)) THEN
   elemsize := VAL(CARDINAL,TSIZE(ADDRESS));
 ELSIF ODD(elemsize) THEN
   INC(elemsize);
 END;

 NEW(heap);
 done := heap # NIL;
 IF done THEN
   WITH heap^ DO
     esize    := VAL(UNSIGNEDWORD,elemsize);
     ecount   := VAL(UNSIGNEDWORD,blksize);
     bsize    :=   VAL(UNSIGNEDLONG,elemsize)
                 * VAL(UNSIGNEDLONG,blksize)
                 + VAL(UNSIGNEDLONG,TSIZE(HeapPtr));
     firstblk := NIL;
     free     := NIL;
   END; (* WITH *)
 END; (* IF done *)
END InstallADTHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE FreeADTHeap ((* EIN/AUS *) heap : ADTHeap );

VAR oldblk : HeapPtr;

BEGIN
 WITH heap^ DO
   WHILE firstblk # NIL DO
     oldblk   := firstblk;
     firstblk := firstblk^;
     DEALLOCATE(oldblk, bsize);
   END;
   free := NIL;
 END;
END FreeADTHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE DeInstallADTHeap ((* EIN/AUS *) VAR heap : ADTHeap );
BEGIN
 FreeADTHeap(heap);
 DISPOSE(heap);
 heap := NIL;
END DeInstallADTHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE ALLOC ((* -- /AUS *) VAR mem  : ADDRESS;
                 (* EIN/ -- *)     heap : ADTHeap );

VAR newblk : HeapPtr;
    cast   : HeapPtr;

BEGIN
 WITH heap^ DO
   IF free # NIL THEN
     mem  := CAST(ADDRESS,free);
     free := free^;
   ELSE
     newHeapBlock(newblk, esize, ecount, bsize);
     IF newblk = NIL THEN
       mem := NIL;
       RETURN;
     END;
     newblk^  := firstblk;
     firstblk := newblk;
     cast     := ADDADR(newblk, TSIZE(HeapPtr));
     free     := cast^;
     mem      := cast;
   END;
 END;
END ALLOC;

(*---------------------------------------------------------------------------*)

PROCEDURE DEALLOC ((* EIN/AUS *) VAR mem  : ADDRESS;
                   (* EIN/ -- *)     heap : ADTHeap );

VAR cast : HeapPtr;

BEGIN
 cast := mem;
 WITH heap^ DO
   cast^ := free;
   free  := cast;
 END;
 mem := NIL;
END DEALLOC;

(*---------------------------------------------------------------------------*)

PROCEDURE RaiseADTException ((* EIN/ -- *) exc : ADTExceptions;
                             (* EIN/ -- *) msg : ARRAY OF CHAR  );

BEGIN
 EXCEPTIONS.RAISE(ADTSource, ORD(exc), msg);
END RaiseADTException;

(*---------------------------------------------------------------------------*)

PROCEDURE IsADTException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(ADTSource));
END IsADTException;

(*---------------------------------------------------------------------------*)

PROCEDURE ADTException ( ): ADTExceptions;
BEGIN
 RETURN(VAL(ADTExceptions,EXCEPTIONS.CurrentNumber(ADTSource)));
END ADTException;

(*===========================================================================*)

BEGIN (* ADTBase *)
 EXCEPTIONS.AllocateSource(ADTSource);
END ADTBase.

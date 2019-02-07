IMPLEMENTATION MODULE Stacks;
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
(* Zur Speicherverwaltung siehe Kopftext des "Queues"-Implementationsmoduls. *)
(* Im Gegensatz zu einer Queue braucht beim Stack nur die Adresse des ober-  *)
(* sten Blocks bekannt zu sein, da auch nur von dieser Seite auf den Stack   *)
(* zugegriffen wird.                                                         *)
(*                                                                           *)
(*                                                                           *)
(*       stack                oberster Block         unterster Block         *)
(*                                                   voll                    *)
(*          | <----                                                          *)
(*          |      |         ________________        ________________        *)
(*  ________V______|_       |                |      :                :       *)
(* | stackAdr        |      |   noch frei    |      :                :       *)
(* |-----------------|      |................|      :   belegt       :       *)
(* :                 :   -->| oberstes Elem  |      :                :       *)
(* |-----------------|  |   |----------------|      :----------------:       *)
(* | stackTop        |--    :   belegt       :      : unterstes Elem :       *)
(* |-----------------|      |----------------|      |----------------|       *)
(* | topBlk          |----->| naechsterBlock |-~~~~>|     NIL        |       *)
(* |_________________|      |________________|      |________________|       *)
(*                                                                           *)
(*                                                                           *)
(* --------------------------------------------------------------------------*)
(* Okt-91 / 16-Dez-95, Holger Kleinschmidt                                   *)
(*****************************************************************************)

/* Wenn das nachfolgende Makro aktiviert ist (#if 1), wird Code fuer
 * Sicherheitschecks am Anfang jeder Prozedur erzeugt.
 */
#if 1
#define __CHECKS__
#endif


VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;

FROM PORTAB IMPORT
(* CONST*) MAXSIGNEDWORD, MAXUNSIGNEDWORD,
(* TYPE *) ANYTYPE, UNSIGNEDWORD, UNSIGNEDLONG;

FROM ISOStorage IMPORT
(* PROC *) ALLOCATE, DEALLOCATE;

FROM blk IMPORT
(* PROC *) memset, memmove;

FROM ADTBase IMPORT
(* TYPE *) ADTExceptions,
(* PROC *) RaiseADTException;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  STACKMAGIC = 0A987ABCEH;

TYPE
  block = POINTER TO ADDRESS;

  Stack = POINTER TO StackInfo;
  StackInfo = RECORD
#ifdef __CHECKS__
    magic    : UNSIGNEDLONG;
      (* fuer Konsistenzpruefung *)
#endif
    blkSize  : UNSIGNEDLONG;
      (* Groesse eines Speicherblocks *)
    elemSize : UNSIGNEDWORD;
      (* Groesse eines Stackelements *)
    maxElems : UNSIGNEDWORD;
      (* Max. Elemente im Block *)
    nElems   : UNSIGNEDWORD;
      (* Anzahl der Stackelemente *)
    topElems : UNSIGNEDWORD;
      (* Anzahl der Elemente im obersten Block *)
    stackTop : ADDRESS;
      (* Adresse des obersten Elementes *)
    topBlk   : block;
      (* Adresse des obersten Blocks *)
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReleaseBlock ((* EIN/ -- *) stack : Stack );
(* Lokale Hilfsprozedur fuer "Delete", "Clear", "Drop" und "Pop".
   Entfernt ohne Sicherheitsabfrage den obersten Block vom Stack.
   Der Speicherplatz des Blocks wird freigegeben.
*)
VAR oldBlk : block;

BEGIN
 WITH stack^ DO
   oldBlk := topBlk;   (* Element muss referenzierbar bleiben *)
   topBlk := topBlk^;  (* Element aus der Zeigerkette nehmen  *)
   DEALLOCATE(oldBlk, blkSize);
 END;
END ReleaseBlock;

(*---------------------------------------------------------------------------*)

PROCEDURE Create ((* EIN/ -- *)     eSize : CARDINAL;
                  (* EIN/ -- *)     bSize : CARDINAL;
                  (* -- /AUS *) VAR stack : Stack;
                  (* -- /AUS *) VAR done  : BOOLEAN );

BEGIN
 done  := FALSE;
 stack := NIL;
 IF   (eSize = 0) OR (eSize > VAL(CARDINAL,CAST(UNSIGNEDWORD,MAXSIGNEDWORD)))
   OR (bSize = 0) OR (bSize > VAL(CARDINAL,MAXUNSIGNEDWORD))
 THEN
   RETURN;
 END;

 NEW(stack); (* Speicherplatz fuer Stack-Header *)
 IF stack # NIL THEN
   WITH stack^ DO
     blkSize :=   VAL(UNSIGNEDLONG,bSize)
                * VAL(UNSIGNEDLONG,eSize)
                + VAL(UNSIGNEDLONG,TSIZE(block));

     ALLOCATE(topBlk, blkSize);
     (* Speicherplatz fuer ersten Block *)

     IF topBlk # NIL THEN
       done     := TRUE;
       topBlk^  := NIL;   (* letzter Block *)
       elemSize := VAL(UNSIGNEDWORD,eSize);
       maxElems := VAL(UNSIGNEDWORD,bSize);
       nElems   := 0;
       topElems := 0;
       (* zeigt vor das erste Element, da noch kein Element im Stack *)
       stackTop := ADDADR(SUBADR(topBlk, elemSize), TSIZE(block));
#ifdef __CHECKS__
       magic    := STACKMAGIC; (* Stack definiert *)
#endif
     ELSE
       DISPOSE(stack);
     END;
   END; (* WITH stack^ *)
 END; (* IF stack # NIL*)

 IF ~done THEN
   stack := NIL;
 END;
END Create;

(*---------------------------------------------------------------------------*)

PROCEDURE Clear ((* EIN/ -- *) stack : Stack );
BEGIN
 WITH stack^ DO
#ifdef __CHECKS__
   IF (stack = NIL) OR (magic # STACKMAGIC) THEN
     RaiseADTException(notAnADT, "Stacks.Clear/Delete: <stack> not defined");
   END;
#endif
   WHILE topBlk^ # NIL DO
     (* Alle evtl. vorhandenen Bloecke ausser dem ersten entfernen *)
     ReleaseBlock(stack);
   END;(* WHILE topBlk^ *)
   nElems   := 0;
   topElems := 0;
   stackTop := ADDADR(SUBADR(topBlk, elemSize), TSIZE(block));
 END; (* WITH stack^*)
END Clear;

(*---------------------------------------------------------------------------*)

PROCEDURE Delete ((* EIN/AUS *) VAR stack : Stack );
BEGIN
 WITH stack^ DO
   Clear(stack);
#ifdef __CHECKS__
   magic := 0;
#endif
   (* Jetzt noch obersten Block und den Stack-Header entfernen *)
   DEALLOCATE(topBlk, blkSize);
   DISPOSE(stack);
   stack := NIL;
 END;
END Delete;

(*---------------------------------------------------------------------------*)

PROCEDURE IsEmpty ((* EIN/ -- *) stack : Stack ): BOOLEAN;
BEGIN
#ifdef __CHECKS__
 IF (stack = NIL) OR (stack^.magic # STACKMAGIC) THEN
   RaiseADTException(notAnADT, "Stacks.IsEmpty: <stack> not defined");
 END;
#endif
 RETURN(stack^.nElems = 0);
END IsEmpty;

(*---------------------------------------------------------------------------*)

PROCEDURE Size ((* EIN/ -- *) stack : Stack ): CARDINAL;
BEGIN
#ifdef __CHECKS__
 IF (stack = NIL) OR (stack^.magic # STACKMAGIC) THEN
   RaiseADTException(notAnADT, "Stacks.Size: <stack> not defined");
 END;
#endif
 RETURN(VAL(CARDINAL,stack^.nElems));
END Size;

(*---------------------------------------------------------------------------*)

PROCEDURE Push ((* EIN/ -- *)     stack : Stack;
                (* EIN/ -- *) VAR val   : ARRAY OF ANYTYPE );

VAR newBlk : block;

BEGIN
 WITH stack^ DO
#ifdef __CHECKS__
   IF (stack = NIL) OR (magic # STACKMAGIC) THEN
     RaiseADTException(notAnADT, "Stacks.Push: <stack> not defined");
   END;
   IF elemSize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "Stacks.Push: wrong element size");
   END;
#endif

   IF topElems = maxElems THEN
     (* Fuer das neue Element ist kein Platz mehr im Block,
      * also neuen Block anfordern.
      *)
     ALLOCATE(newBlk, blkSize);
     IF newBlk = NIL THEN
       RaiseADTException(noMem, "Stacks.Push: out of memory");
     END;
     newBlk^  := topBlk; (* neuen Block am Anfang einklinken *)
     topBlk   := newBlk;
     topElems := 1;
     stackTop := ADDADR(topBlk, TSIZE(block));
   ELSE
     INC(topElems);
     stackTop := ADDADR(stackTop, elemSize);
   END; (* IF topElems *)
   memmove(stackTop, ADR(val), VAL(UNSIGNEDLONG,elemSize));
   INC(nElems);
 END; (* WITH stack^ *)
END Push;

(*---------------------------------------------------------------------------*)

PROCEDURE Top ((* EIN/ -- *)     stack : Stack;
               (* -- /AUS *) VAR val   : ARRAY OF ANYTYPE );

BEGIN
 WITH stack^ DO
#ifdef __CHECKS__
   IF (stack = NIL) OR (magic # STACKMAGIC) THEN
     RaiseADTException(notAnADT, "Stacks.Top: <stack> not defined");
   END;
   IF elemSize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "Stacks.Top: wrong element size");
   END;
#endif
   IF nElems = 0 THEN
     RaiseADTException(noEntry, "Stacks.Top: stack is empty");
   END;
   memmove(ADR(val), stackTop, VAL(UNSIGNEDLONG,elemSize));
 END;
END Top;

(*---------------------------------------------------------------------------*)

PROCEDURE Pop ((* EIN/ -- *)     stack : Stack;
               (* -- /AUS *) VAR val   : ARRAY OF ANYTYPE );

BEGIN
 WITH stack^ DO
#ifdef __CHECKS__
   IF (stack = NIL) OR (magic # STACKMAGIC) THEN
     RaiseADTException(notAnADT, "Stacks.Pop: <stack> not defined");
   END;
   IF elemSize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "Stacks.Pop: wrong element size");
   END;
#endif
   IF nElems = 0 THEN
     RaiseADTException(noEntry, "Stacks.Pop: stack is empty");
   END;

   memmove(ADR(val), stackTop, VAL(UNSIGNEDLONG,elemSize));
   DEC(nElems);
   IF topElems > 1 THEN
     (* Wenn noch ein Element auf dem Stack ist, und das
      * naechste Element noch innerhalb dieses Blocks ist,
      * koennen Index und Adresse einfach verringert werden.
      *)
     DEC(topElems);
     stackTop := SUBADR(stackTop, elemSize);
   ELSE (* <stack> leer oder lediglich oberster Block leer *)
     IF nElems > 0 THEN
       (* Wenn lediglich der oberste Block leer ist,
        * aber nicht der Stack - d.h. es existieren noch
        * weitere Bloecke -, den obersten Block entfernen.
        * Der Zeiger aufs oberste Element muss aufs
        * oberste Element des naechsten Blocks zeigen.
        *)
       ReleaseBlock(stack);

       topElems := maxElems;
       stackTop := ADDADR(SUBADR(topBlk, elemSize), blkSize);
     ELSE (* der Stack ist jetzt leer *)
       topElems := 0;
       stackTop := ADDADR(SUBADR(topBlk, elemSize), TSIZE(block));
     END;
   END;
 END; (* WITH stack^ *)
END Pop;

END Stacks.

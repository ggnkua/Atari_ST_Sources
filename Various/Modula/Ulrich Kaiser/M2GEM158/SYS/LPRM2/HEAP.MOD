IMPLEMENTATION MODULE Heap;

(*****************************************************************************)
(*  Rekompiliertes und korrigiertes LPR-Modula-Originalmodul                 *)
(*                                                                           *)
(*  Juli '90 / 13-Mae-95, Holger Kleinschmidt                                *)
(*****************************************************************************)

IMPORT GEMX;

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) VAL, ADR, TSIZE;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  MemBlkPtr = POINTER TO MemBlk;

  MemBlk = RECORD
    next : MemBlkPtr; (* naechster (freier) Block *)
    size : LONGINT;   (* Blockgroesse inkl. TSIZE(MemBlk) *)
  END;

CONST
  USED = VAL(MemBlkPtr,987654321D);

VAR
  MemStartPtr : MemBlkPtr;        (* -$20 *)
  MemStart    : MemBlk;           (* -$28 *)
  xinfo       : GEMX.ExtInfoPtr;  (* -$2C *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Allocate ((* -- /AUS *) VAR speicher : ADDRESS;
                    (* EIN/ -- *)     anzahl   : LONGINT );

VAR free   : MemBlkPtr;
    before : MemBlkPtr;

BEGIN
 IF anzahl < 0D THEN
   speicher := NIL;
   RETURN
 END;
 INC(anzahl, VAL(LONGINT,TSIZE(MemBlk))); (* Verwaltungsbedarf *)
 IF ODD(anzahl) THEN
   INC(anzahl);
 END;

 before := MemStartPtr;
 free   := before^.next;

 LOOP
   (* FIRST FIT *)
   IF free^.size >= anzahl THEN
     (* Der aktuelle Block der Freispeicherliste hat eine
      * ausreichende Groesse.
      *)
(**** Original (Fehler!):
     IF free^.size = anzahl THEN
 ****)
     IF free^.size - VAL(LONGINT,TSIZE(MemBlk)) <= anzahl THEN
       (* Es ist kein Platz fuer einen neuen Block, ohne dass die
        * Verwaltung des alten Blocks ueberschrieben wuerde.
        * (size ist die Groesse von freiem Platz + Verwaltung, und
        * bei einem neuen Block muesste Platz fuer zwei Verwaltungen sein!)
        * Also einfach diesen Block ausketten.
        *)
       before^.next := free^.next;
     ELSE
       (* sonst den gewuenschten Block am Ende des aktuellen
        * Blocks abknapsen, und die neue Blockgroesse speichern.
        *)
       DEC(free^.size, anzahl);
       INC(VAL(ADDRESS,free), free^.size);
       free^.size := anzahl;
     END;
     free^.next  := USED;
     speicher    := VAL(ADDRESS,free) + VAL(ADDRESS,TSIZE(MemBlk));
     MemStartPtr := before;
     RETURN;
   END; (* IF free^.size *)

   IF free = MemStartPtr THEN
     speicher := NIL;
     (* Hier evtl. Speicher anfordern *)
     RETURN;
   END;
   before := free;
   free   := free^.next;
 END; (* LOOP *)
END Allocate;

(*---------------------------------------------------------------------------*)

PROCEDURE Deallocate ((* EIN/AUS *) VAR speicher : ADDRESS;
                      (* EIN/ -- *)     anzahl   : LONGINT );

VAR free   : MemBlkPtr;
    before : MemBlkPtr;

BEGIN
 IF (speicher = NIL) OR ODD(speicher) THEN
   RETURN
 END;

 free := speicher - VAL(ADDRESS,TSIZE(MemBlk));

 IF free^.next <> USED THEN
   RETURN
 END;

 before := MemStartPtr;

 (* Block suchen, der physikalisch vor dem freizugebenden liegt *)
 LOOP
   IF    (VAL(ADDRESS,free) > VAL(ADDRESS,before))
     AND (VAL(ADDRESS,free) < VAL(ADDRESS,before^.next))
   THEN
     EXIT;
   END;
   IF     (VAL(ADDRESS,before) >= VAL(ADDRESS,before^.next))
      AND (   (VAL(ADDRESS,free) >  VAL(ADDRESS,before))
           OR (VAL(ADDRESS,free) <  VAL(ADDRESS,before^.next)))
   THEN
     EXIT;
   END;

   before := before^.next;
   IF before = MemStartPtr THEN
     HALT;
   END;
 END; (* LOOP *)

 IF VAL(LONGINT,free) + free^.size = VAL(LONGINT,before^.next) THEN
   INC(free^.size, before^.next^.size);
   free^.next := before^.next^.next;
 ELSE
   free^.next := before^.next;
 END;

 IF VAL(LONGINT,before) + before^.size = VAL(LONGINT,free) THEN
   INC(before^.size, free^.size);
   before^.next := free^.next;
 ELSE
   before^.next := free;
 END;

 MemStartPtr := before;
END Deallocate;

(*===========================================================================*)

BEGIN (* Heap *)
  MemStart.next := VAL(MemBlkPtr,  GEMX.BasePagePtr^.BssBase
                                 + GEMX.BasePagePtr^.BssLen); (* <-- GEMX *)
  MemStart.size := 0;

  MemStart.next^.next := ADR(MemStart);
  xinfo := VAL(GEMX.ExtInfoPtr,GEMX.BasePagePtr^.CodeBase);
(**** Original (unnoetig, aber ohne Folgen):
  MemStart.next^.size := xinfo^.heapSize - VAL(LONGINT,TSIZE(MemBlk));
 ****)
  MemStart.next^.size := xinfo^.heapSize;
  IF MemStart.next^.size < 0D THEN
    MemStart.next^.size := 0D;
  END;
  IF ODD(MemStart.next^.size) THEN
    DEC(MemStart.next^.size);
  END;
  MemStartPtr := ADR(MemStart);
END Heap.

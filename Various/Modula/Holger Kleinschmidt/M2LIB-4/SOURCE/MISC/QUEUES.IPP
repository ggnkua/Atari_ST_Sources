IMPLEMENTATION MODULE Queues;
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
(* Vor saemtlichen Operationen mit den Queues steht folgende Abfrage:        *)
(*                                                                           *)
(*       IF (queue # NIL) & (queue^.magic = QUEUEMAGIC) THEN              *)
(*                                                                           *)
(* Sie garantiert mit ziemlicher Sicherheit, dass die uebergebene Queuevari- *)
(* able einen definierten Wert hat, d.h. mit "Create()" erzeugt wurde, und   *)
(* nicht irgendein Pointer ist, der irgendwohin zeigt.                       *)
(*                                                                           *)
(* Bei dynamischen Datenstrukturen wie so einer Warteschlange steht man vor  *)
(* dem Problem der Speicherverwaltung. Einerseits sollen die Operationen     *)
(* schnell erfolgen, andererseits soll aber kein Speicher verschwendet wer-  *)
(* den.                                                                      *)
(* Wird fuer die Struktur ein statischer Speicherbereich zu Uebersetzungszeit*)
(* festgelegt, so sind die Queueoperationen sicherlich schnell, da zur Lauf- *)
(* zeit kein Speicher angefordert und freigegeben werden muss. Allerdings    *)
(* kann der einmal festgelegte Speicher in der Groesse nicht mehr veraendert *)
(* werden; d.h. es kann sowohl sein, dass der Speicher zur Laufzeit nicht    *)
(* mehr ausreicht, als auch, dass der Speicher die meiste Zeit unbenutzt     *)
(* bleibt.                                                                   *)
(* Wird hingegen fuer jedes neu in die Queue einzufuegende Element ein neuer *)
(* Speicherblock angefordert bzw. beim Herausnehmen des Elements freigege-   *)
(* ben, so wird der Speicher zwar optimal ausgenutzt, aber die Operationen   *)
(* werden entsprechend langsam.                                              *)
(*                                                                           *)
(* Da die Art des Zugriffs bei Queues (und auch bei Stacks) genau bekannt    *)
(* ist -- naemlich am Ende anfuegen, vom Anfang entfernen, keine anderen Zu- *)
(* griffe --, kann ein Kompromiss zwischen Geschwindigkeit und Speicheraus-  *)
(* nutzung geschlossen werden:                                               *)
(* Speicher wird nicht fuer jedes neue Element angefordert und freigegeben,  *)
(* sondern immer in Bloecken zu mehreren Elementen, d.h. erst wenn ein Block *)
(* voll ist, wird wieder ein neuer Speicherblock angefordert, und erst wenn  *)
(* ein Block leer ist, wird der Speicher fuer ihn freigegeben. Die Bloecke   *)
(* sind durch eine lineare Liste mit Header verbunden. Im Header sind unter  *)
(* anderem die Adressen des ersten und letzten Blocks enthalten, so dass ohne*)
(* die Liste zu durchsuchen sowohl auf das Frontelement als auch das letzte  *)
(* Element zugegriffen werden kann. Die Verzeigerung ist in folgendem Dia-   *)
(* gramm dargestellt, fuer genauere Informationen sollte der Quelltext durch-*)
(* geackert werden.                                                          *)
(*                                                                           *)
(*       queue                erster Block           letzter Block           *)
(*                                                                           *)
(*          |<----                                                           *)
(*          |     |         ________________        ________________         *)
(*  ________V_____|_       |                |      :                :        *)
(* | queueAdr       |      |   belegt       |   -->:   noch frei    :        *)
(* |----------------|      |----------------|  |   :................:        *)
(* :                :   -->| erstes Element |  |   : letztes Element:        *)
(* |----------------|  |   |................|  |   :----------------:        *)
(* | queueFront     |--    :  wieder frei   :  |   :    belegt      :        *)
(* |----------------|      |----------------|  |   |----------------|        *)
(* | frontBlk       |----->| naechsterBlock |-~~~~>|     NIL        |        *)
(* |----------------|      |________________|  |   |________________|        *)
(* | queueTail      |--------------------------          ^                   *)
(* |----------------|                                    |                   *)
(* | tailBlk        |------------------------------------                    *)
(* |________________|                                                        *)
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
(* PROC *) memmove;

FROM ADTBase IMPORT
(* TYPE *) ADTExceptions,
(* PROC *) RaiseADTException;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  QUEUEMAGIC = 0A987ABCDH;

TYPE
  block = POINTER TO ADDRESS;

  Queue = POINTER TO QueueInfo;
  QueueInfo = RECORD
#ifdef __CHECKS__
    magic      : UNSIGNEDLONG;
      (* fuer Konsistenzpruefung *)
#endif
    blkSize    : UNSIGNEDLONG;
      (* Groesse eines Speicherblocks *)
    nElems     : UNSIGNEDWORD;
      (* Anzahl der Queueelemente *)
    elemSize   : UNSIGNEDWORD;
      (* Groesse eines Queueelements *)
    maxElem    : UNSIGNEDWORD;
      (* Max. Elementindex im Block *)
    frontElem  : UNSIGNEDWORD;
      (* Index des ersten Elements im ersten Block *)
    tailElem   : UNSIGNEDWORD;
      (* Index des naechsten Elements im letzten Block *)
    queueFront : ADDRESS;
      (* Adresse des ersten Elements *)
    frontBlk   : block;
      (* Adresse des ersten Blocks *)
    queueTail  : ADDRESS;
      (* Adresse des naechsten Elements im letzten Block *)
    tailBlk    : block;
      (* Adresse des letzten Blocks *)
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReleaseBlock ((* EIN/ -- *) queue : Queue);
(* Lokale Hilfsprozedur fuer "Delete()", "Clear()" und "Remove()".
   Entfernt ohne Sicherheitsabfrage den ersten Block der Queue
   und gibt dessen Speicherplatz frei.
*)
VAR oldBlk : block;

BEGIN
 WITH queue^ DO
   oldBlk   := frontBlk;   (* Element muss referenzierbar bleiben *)
   frontBlk := frontBlk^;  (* Element aus der Zeigerkette nehmen  *)
   DEALLOCATE(oldBlk, blkSize);
 END;
END ReleaseBlock;

(*---------------------------------------------------------------------------*)

PROCEDURE Create ((* EIN/ -- *)     eSize : CARDINAL;
                  (* EIN/ -- *)     bSize : CARDINAL;
                  (* -- /AUS *) VAR queue : Queue;
                  (* -- /AUS *) VAR done  : BOOLEAN );

BEGIN
 done  := FALSE;
 queue := NIL;
 IF   (eSize = 0) OR (eSize > VAL(CARDINAL,CAST(UNSIGNEDWORD,MAXSIGNEDWORD)))
   OR (bSize = 0) OR (bSize > VAL(CARDINAL,MAXUNSIGNEDWORD))
 THEN
   RETURN;
 END;

 NEW(queue); (* Speicherplatz fuer Queue-Header *)
 IF queue # NIL THEN
   WITH queue^ DO
     blkSize :=   VAL(UNSIGNEDLONG,bSize)
                * VAL(UNSIGNEDLONG,eSize)
                + VAL(UNSIGNEDLONG,TSIZE(block));

     ALLOCATE(frontBlk, blkSize);
     (* Speicherplatz fuer den ersten Block *)

     IF frontBlk # NIL THEN
       done       := TRUE;
       tailBlk    := frontBlk;
       tailBlk^   := NIL;   (* letzter Block *)
       nElems     := 0;
       maxElem    := VAL(UNSIGNEDWORD,bSize - 1);
       elemSize   := VAL(UNSIGNEDWORD,eSize);
       queueFront := ADDADR(frontBlk, TSIZE(block));
       queueTail  := queueFront;
       frontElem  := 0;
       tailElem   := 0;
#ifdef __CHECKS__
       magic      := QUEUEMAGIC;
#endif
     ELSE
       DISPOSE(queue);
     END; (* IF frontBlk # NIL *)
   END; (* WITH queue^ *)
 END; (* IF queue # NIL *)

 IF ~done THEN
   queue := NIL;
 END;
END Create;

(*---------------------------------------------------------------------------*)

PROCEDURE Clear ((* EIN/ -- *) queue : Queue );
BEGIN
 WITH queue^ DO
#ifdef __CHECKS__
   IF (queue = NIL) OR (magic # QUEUEMAGIC) THEN
     RaiseADTException(notAnADT, "Queues.Clear/Delete: <queue> not defined");
   END;
#endif
   WHILE frontBlk^ # NIL DO
     ReleaseBlock(queue);  (* Alle Bloecke bis auf einen entfernen *)
   END;
   nElems     := 0;
   frontElem  := 0;
   tailElem   := 0;
   queueFront := ADDADR(frontBlk, TSIZE(block));
   queueTail  := queueFront;
 END;
END Clear;

(*---------------------------------------------------------------------------*)

PROCEDURE Delete ((* EIN/AUS *) VAR queue : Queue );
BEGIN
 WITH queue^ DO
   Clear(queue);
#ifdef __CHECKS__
   magic := 0;
#endif
   (* Jetzt noch den ersten Block und den Queue-Header entfernen *)
   DEALLOCATE(frontBlk, blkSize);
   DISPOSE(queue);
   queue := NIL;
 END;
END Delete;

(*---------------------------------------------------------------------------*)

PROCEDURE IsEmpty ((* EIN/ -- *) queue : Queue ): BOOLEAN;
BEGIN
#ifdef __CHECKS__
 IF (queue = NIL) OR (queue^.magic # QUEUEMAGIC) THEN
   RaiseADTException(notAnADT, "Queues.IsEmpty: <queue> not defined");
 END;
#endif
 RETURN(queue^.nElems = 0);
END IsEmpty;

(*---------------------------------------------------------------------------*)

PROCEDURE Size ((* EIN/ -- *) queue : Queue ): CARDINAL;
BEGIN
#ifdef __CHECKS__
 IF (queue = NIL) OR (queue^.magic # QUEUEMAGIC) THEN
   RaiseADTException(notAnADT, "Queues.Size: <queue> not defined");
 END;
#endif
 RETURN(VAL(CARDINAL,queue^.nElems));
END Size;

(*---------------------------------------------------------------------------*)

PROCEDURE Insert ((* EIN/ -- *)     queue : Queue;
                  (* EIN/ -- *) VAR val   : ARRAY OF ANYTYPE );

VAR newBlk : block;

BEGIN
 WITH queue^ DO
#ifdef __CHECKS__
   IF (queue = NIL) OR (magic # QUEUEMAGIC) THEN
     RaiseADTException(notAnADT, "Queues.Insert: <queue> not defined");
   END;
   IF elemSize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "Queues.Insert: wrong element size");
   END;
#endif

   IF tailElem > maxElem THEN
     (* Fuer das neue Element ist kein Platz mehr im Block,
      * also neuen Block anfordern.
      *)
     ALLOCATE(newBlk, blkSize);
     IF newBlk = NIL THEN
       RaiseADTException(noMem, "Queues.Insert: out of memory");
     END;

     newBlk^   := NIL;    (* Ende der Liste              *)
     tailBlk^  := newBlk; (* an bisher letzten anhaengen *)
     tailBlk   := newBlk; (* als neuen letzten merken    *)
     tailElem  := 0;
     queueTail := ADDADR(tailBlk, TSIZE(block));
   END; (* IF tailElem *)

   memmove(queueTail, ADR(val), VAL(UNSIGNEDLONG,elemSize));
   INC(nElems);
   INC(tailElem);
   queueTail := ADDADR(queueTail, elemSize);
 END; (* WITH queue^ *)
END Insert;

(*---------------------------------------------------------------------------*)

PROCEDURE Look ((* EIN/ -- *)     queue : Queue;
                (* -- /AUS *) VAR val   : ARRAY OF ANYTYPE );

BEGIN
 WITH queue^ DO
#ifdef __CHECKS__
   IF (queue = NIL) OR (magic # QUEUEMAGIC) THEN
     RaiseADTException(notAnADT, "Queues.Look: <queue> not defined");
   END;
   IF elemSize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "Queues.Look: wrong element size");
   END;
#endif
   IF nElems = 0 THEN
     RaiseADTException(noEntry, "Queues.Look: queue is empty");
   END;
   memmove(ADR(val), queueFront, VAL(UNSIGNEDLONG,elemSize));
 END;
END Look;

(*---------------------------------------------------------------------------*)

PROCEDURE Remove ((* EIN/ -- *)     queue : Queue;
                  (* -- /AUS *) VAR val   : ARRAY OF ANYTYPE );

BEGIN
 WITH queue^ DO
#ifdef __CHECKS__
   IF (queue = NIL) OR (magic # QUEUEMAGIC) THEN
     RaiseADTException(notAnADT, "Queues.Remove: <queue> not defined");
   END;
   IF elemSize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "Queues.Remove: wrong element size");
   END;
#endif
   IF nElems = 0 THEN
     RaiseADTException(noEntry, "Queues.Remove: queue is empty");
   END;

   memmove(ADR(val), queueFront, VAL(UNSIGNEDLONG,elemSize));
   DEC(nElems);
   IF frontElem = maxElem THEN
     (* Der vorderste Block wird leer *)
     IF nElems > 0 THEN
       (* Wenn lediglich der vordere Block leer wird,
        * aber nicht die Queue - d.h. es existieren noch
        * weitere Bloecke -, den vorderen Block entfernen.
        * Der Zeiger auf das letzte Element bleibt erhalten.
        *)
       ReleaseBlock(queue);
     ELSE (* <queue> ist jetzt leer *)
       tailElem  := 0;
       queueTail := ADDADR(frontBlk, TSIZE(block));
     END;

     (* Das Frontelement beginnt auf jeden Fall am
      * Anfang des 'frontBlk's, egal ob in der Queue
      * noch was drin ist.
      *)
     frontElem  := 0;
     queueFront := ADDADR(frontBlk, TSIZE(block));
   ELSE
     INC(frontElem);
     queueFront := ADDADR(queueFront, elemSize);
   END;
 END; (* WITH queue^ *)
END Remove;

END Queues.

IMPLEMENTATION MODULE mem;
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
(* Dieser Implementierung liegen, neben eigenen Ideen, folgende andere       *)
(* Implementierungen zugrunde:                                               *)
(*                                                                           *)
(* o Das LPR-Heap, das nichts anderes als eine direkte Uebernahme (samt      *)
(*   Fehler!) des Beispiels aus dem "Kernighan/Ritchie" ist.                 *)
(* o Die MiNTLib-Implementierung.                                            *)
(*                                                                           *)
(* Die verwendete Hauptdatenstruktur ist eine verschachtelte Liste. Die obere*)
(* Ebene bildet eine doppelt verkettete, zirkulaere Liste, in der die von    *)
(* Gemdos angeforderten oder per "AddHeap()" zur Verfuegung gestellten       *)
(* Speicherbloecke (Heaps) stehen. Innerhalb jedes Heap-Speicherblocks       *)
(* befinden sich die freien Bloecke, die fuer den Benutzer zur Verfuegung    *)
(* stehen; sie stehen ebenfalls in einer doppelt verketteten, zirkulaeren    *)
(* Liste. Die Bloecke in beiden Listen sind nach aufsteigenden Adressen      *)
(* sortiert. Global gibt es einen Zeiger auf den Heap, der bei der naechsten *)
(* Prozedur als erstes durchsucht wird, und fuer jeden Heap  gibt es einen   *)
(* Zeiger, der auf den naechsten zu testenden freien Block zeigt. Indem mit  *)
(* der Suche nach freien Bloecken nicht immer am Anfang der Liste begonnen   *)
(* wird, soll die Speicherfragmentierung gleichmaessiger verteilt werden.    *)
(* Jeder Heap-Block enthaelt einen freien Dummy-Block, der nicht vergeben    *)
(* wird, so dass der Zeiger auf den naechsten freien Block immer gueltig     *)
(* bleibt, auch wenn im Heap kein freier Block mehr zur Verfuegung steht.    *)
(* Die freien Bloecke werden nach dem First-Fit-Verfahren vergeben, d.h. es  *)
(* wird der erste Block hinreichender Groesse genommen.                      *)
(* Bei der Freigabe belegter Bloecke wird getestet, ob direkt vor und hinter *)
(* dem freizugebenden Block weitere freie Bloecke stehen. Wenn das der Fall  *)
(* ist, werden die Bloecke zu einem entsprechend groesseren freien Block     *)
(* vereinigt, was die Speicherfragmentierung vermindert.                     *)
(*                                                                           *)
(* Um die Anforderungen mehrerer Prozesse (Threads) behandeln zu koennen,    *)
(* wird folgendes getan:                                                     *)
(* Fuer eine feste Anzahl (NThreads) gleichzeitig aktiver Threads kann       *)
(* jeweils eine eigene Speicherverwaltung eingerichtet werden, die voellig   *)
(* unabhaengig von den anderen arbeitet. Die Speicherverwaltungen werden     *)
(* durch jeweils eigene Root-Heap-Bloecke gekennzeichnet und anhand der      *)
(* Prozesskennung ausgewaehlt. Die eigtl. Prozeduren zur Verwaltung erhalten *)
(* zusaetzlich den entsprechenden Root-Block, sind aber sonst allgemein      *)
(* gehalten. Da die Liste der Root-Bloecke eine globale Variable ist, darf   *)
(* der (veraendernde) Zugriff nur von einem Thread gleichzeitig erfolgen. Aus*)
(* diesem Grund werden die Threads ueber den 'Psemaphore'-Aufruf miteinander *)
(* synchronisiert; zusaetzlich werden zwischenzeitlich auch die Interrupts   *)
(* gesperrt.                                                                 *)
(* Unter TOS ist der 'Psemaphore'-Aufruf nicht vorhanden, es ist aber auch   *)
(* keine Synchronisation noetig, da Prozesse nicht parallel ablaufen. Dagegen*)
(* ist es aber genauso wie unter MiNT noetig, mit "vfork()" oder "tfork()"   *)
(* erzeugte Unterprozesse bei der Speicherverwaltung separat zu behandeln,   *)
(* denn hierbei werden neue Basepages erzeugt, womit Gemdos sie als separate *)
(* Prozesse ansieht, denen auch eigener Speicher gehoert, bzw. deren Speicher*)
(* bei Prozessende automatisch freigegeben wird!                             *)
(* Probleme mit der Synchronisation gibt es nur, wenn zwar die 'P[v]fork'-   *)
(* und erweiterten 'Pexec'-Aufrufe existieren, aber nicht 'Psemaphore'. So   *)
(* etwas gibt es allerdings zur Zeit nicht.                                  *)
(* --------------------------------------------------------------------------*)
(* 05-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

/* Wenn das nachfolgende Makro aktiviert ist (#if 1), wird Code fuer
 * Sicherheitschecks erzeugt. Sollte nur abgeschaltet werden, wenn
 * Speicherplatz gespart werden muss (8 Bytes Overhead statt 12 Bytes
 * bei belegten Bloecken).
 */
#if 1
#define __CHECKS__
#endif

/* Diese Option ist nur zum Testen der Implementierung gedacht, nicht fuer
 * den Benutzer.
 */
#if 0
#ifdef __CHECKS__
#define _DEBUG
#endif
#endif

/* Wenn diese Option gesetzt ist, koennen Speicheranforderungen mehrerer
 * Threads korrekt bearbeitet werden. Ohne diese Option gibt es nur eine
 * ``normale'' Speicherverwaltung, die nichts von Threads weiss, aber
 * etwas schneller ist.
 */
#if 1
#define __THREADSAFE__
#else
#warning Storage allocation is not thread-save!
#endif

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT
OSCALL_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) TSIZE, ADR;

FROM PORTAB IMPORT
(* CONST*) MAXUNSIGNEDLONG, NULL,
(* TYPE *) UNSIGNEDLONG, SIGNEDLONG, UNSIGNEDWORD, SIGNEDWORD;

FROM types IMPORT
(* TYPE *) sizeT, pidT, StrPtr;

FROM OSCALLS IMPORT
(* PROC *) Malloc, Mfree, Psemaphore, Psigblock, Psigsetmask;

FROM blk IMPORT
(* PROC *) memmove, memfill, memchr;

FROM er IMPORT
(* CONST*) eACCDN, EINVAL, ENOMEM, ESRCH,
(* VAR  *) errno;

FROM DosSystem IMPORT
(* PROC *) GetPageSize, ActPid, atexit;
#ifdef _DEBUG
FROM DosIO IMPORT WriteString, WriteHex, WriteInt, WriteLn;
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#ifdef __CHECKS__
CONST
  RootMagic  = 0FEDBA111H;
  HeapMagic  = 0FEDBA333H;
  FreeMagic  = 0FEDBA555H;
  AllocMagic = 0FEDBA777H;
#endif

CONST
  MinGemdosBlkSize = LC(32768);

TYPE
  BlkPtr = POINTER TO Blk;

  (* Steht am Anfang jedes von "malloc()" angeforderten Speicherblocks *)
  Blk = RECORD
    size : UNSIGNEDLONG;
      (* Groesse des Speicherblocks inkl. Verwaltung *)
    prev : BlkPtr;
      (* bei freien Bloecken Zeiger auf den vorigen freien Block,
         bei belegten Bloecken Zeiger auf den zugehoerigen Heap-Block.
       *)
#ifdef __CHECKS__
    type : UNSIGNEDLONG;
      (* Typ des Speicherblocks: 'FreeMagic' oder 'AllocMagic' *)
#endif
    (* Nur bei freien Bloecken: *)
    next : BlkPtr;
      (* Zeiger auf den naechsten freien Block *)
  END;

CONST
  BlkOverhead      = TSIZE(Blk);
  FreeBlkOverhead  = TSIZE(BlkPtr);
  AllocBlkOverhead = BlkOverhead - FreeBlkOverhead;

CONST
  MinBlkSize = FreeBlkOverhead;

TYPE
  HeapBlkPtr = POINTER TO HeapBlk;

  (* Steht am Anfang jedes Heap-Speicherblocks *)
  HeapBlk = RECORD
    size     : UNSIGNEDLONG;
      (* Gesamtgroesse des Speicherblocks *)
    nblks    : SIGNEDLONG;
      (* Anzahl belegter Bloecke *)
#ifdef __CHECKS__
    nfree    : SIGNEDLONG;
      (* Anzahl freier Bloecke *)
#endif
    temp     : BOOLEAN;
      (* Flag: Block wird an Gemdos zurueckgegeben *)
    nextfree : BlkPtr;
      (* Naechster freier Block, auf den zugegriffen wird *)
    prev     : HeapBlkPtr;
      (* <- voriger Heap-Speicherblock *)
    next     : HeapBlkPtr;
      (* -> naechster Heap-Speicherblock *)
#ifdef __CHECKS__
    type     : UNSIGNEDLONG;
      (* Typ des Speicherblocks: 'RootMagic' oder 'HeapMagic' *)
#endif
    freeblk  : Blk;
      (* Dummy-Block, der immer frei ist (fuer 'nextfree') *)
  END;

CONST
  HeapBlkOverhead = TSIZE(HeapBlk);


CONST
  (* Max. Anzahl gleichzeitig die Speicherverwaltung benutzender Threads *)
  NThreads = 8;

TYPE
  RootBlock = RECORD
    heap    : HeapBlk;
    nextblk : HeapBlkPtr;
    pid     : pidT;
#ifdef __CHECKS__
    nperm   : SIGNEDLONG;
    ntemp   : SIGNEDLONG;
#endif
  END;

VAR
  PageSize    : UNSIGNEDLONG;
  ThreadRoots : ARRAY [0..NThreads-1] OF RootBlock;
#ifdef __THREADSAFE__
  Sync        : BOOLEAN; (* Flag: Synchronisation von Threads moeglich *)

  Sema : RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: id  : SIGNEDLONG;
     |TRUE : asc : UNSIGNEDWORD;
             pid : SIGNEDWORD;
    END;
  END;

CONST
  SemaCreate  = 0;
  SemaDestroy = 1;
  SemaRequest = 2;
  SemaRelease = 3;

  SemaBlock  = LIC(-1);
  SemaIgnore = LIC(0);
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#ifdef _DEBUG
PROCEDURE testintegrity ((* EIN/ -- *) VAR root : RootBlock );

(* Wenn dieser Test erfolgreich verlaeuft, ist ziemlich sicher, dass
   die Listenstruktur OK ist.
 *)
VAR hblk  : HeapBlkPtr;
    blk   : BlkPtr;
    bcntf : SIGNEDLONG;
    bcntb : SIGNEDLONG;
    hcntp : SIGNEDLONG;
    hcntt : SIGNEDLONG;
    hcntr : SIGNEDLONG;


BEGIN
 hblk  := ADR(root.heap);
 hcntp := 0;
 hcntt := 0;
 hcntr := 0;
 REPEAT
   IF ODD(CAST(UNSIGNEDLONG,hblk)) THEN
     WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
     HALT; CODE(4AFCH);
   END;
   WITH hblk^ DO
     IF ODD(CAST(UNSIGNEDLONG,nextfree)) THEN
       WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
       HALT; CODE(4AFCH);
     END;
     IF ODD(CAST(UNSIGNEDLONG,prev)) THEN
       WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
       HALT; CODE(4AFCH);
     END;
     IF ODD(CAST(UNSIGNEDLONG,next)) THEN
       WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
       HALT; CODE(4AFCH);
     END;
     IF type = RootMagic THEN
       INC(hcntr);
       IF temp OR (size # LC(0)) OR (nblks # LIC(0)) OR (nfree # LIC(0)) OR (nextfree # ADR(root.heap.freeblk)) THEN
         WriteInt(__LINE__,1); WriteString(": Veraenderung am Root-Block!"); WriteLn;
         HALT; CODE(4AFCH);
       END;
     ELSIF type = HeapMagic THEN
       IF nblks < LIC(0) THEN
         WriteInt(__LINE__,1); WriteString(": Weniger als keine Bloecke?"); WriteLn;
         HALT; CODE(4AFCH);
       END;
       IF (DIFADR(next^.prev, hblk) # LIC(0)) OR (DIFADR(prev^.next, hblk) # LIC(0)) THEN
         WriteInt(__LINE__,1); WriteString(": Verzeigerung des Heap-Bloecke fehlerhaft!"); WriteLn;
         HALT; CODE(4AFCH);
       END;
       IF   (DIFADR(nextfree, ADR(hblk^.freeblk)) < LIC(0))
         OR (DIFADR(nextfree, ADDADR(hblk, size)) > LIC(0))
       THEN
         WriteInt(__LINE__,1); WriteString(": naechster freier Block nicht innerhalb des Heap-Blocks!"); WriteLn;
         HALT; CODE(4AFCH);
       END;
       IF nextfree^.type # FreeMagic THEN
         WriteInt(__LINE__,1); WriteString(": In der Liste steht ein falscher Blocktyp!"); WriteLn;
         HALT; CODE(4AFCH);
       END;
       blk := nextfree;
       REPEAT
         IF ODD(CAST(UNSIGNEDLONG,blk)) THEN
           WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         IF ODD(CAST(UNSIGNEDLONG,blk^.prev)) THEN
           WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         IF ODD(CAST(UNSIGNEDLONG,blk^.next)) THEN
           WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         IF blk^.type # FreeMagic THEN
           WriteInt(__LINE__,1); WriteString(": Falscher Blocktyp in Liste der freien Bloecke!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         IF DIFADR(ADDADR(blk, blk^.size), ADDADR(hblk, size)) > LIC(0) THEN
           WriteInt(__LINE__,1); WriteString(": Freier Block teilweise ausserhalb des Heap-Blocks!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         IF   (DIFADR(blk^.next^.prev, blk) # LIC(0))
           OR (DIFADR(blk^.prev^.next, blk) # LIC(0))
         THEN
           WriteInt(__LINE__,1); WriteString(": Verzeigerung der freien Bloecke fehlerhaft!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         blk := blk^.next;
       UNTIL DIFADR(blk, nextfree) = LIC(0);
       blk   := ADDADR(hblk, HeapBlkOverhead);
       bcntf := 0;
       bcntb := 0;
       REPEAT
         IF ODD(CAST(UNSIGNEDLONG,blk)) THEN
           WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         IF ODD(CAST(UNSIGNEDLONG,blk^.prev)) THEN
           WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         IF blk^.type = AllocMagic THEN
           INC(bcntb);
           IF DIFADR(blk^.prev, hblk) # LIC(0) THEN
             WriteInt(__LINE__,1); WriteString(": Belegter Block zeigt nicht auf zugehoerigen Heap-Block!"); WriteLn;
             HALT; CODE(4AFCH);
           END;
           IF DIFADR(ADDADR(blk, blk^.size), ADDADR(hblk, size)) > LIC(0) THEN
             WriteInt(__LINE__,1); WriteString(": Belegter Block teilweise ausserhalb des Heap-Blocks!"); WriteLn;
             HALT; CODE(4AFCH);
           END;
         ELSIF blk^.type = FreeMagic THEN
           IF ODD(CAST(UNSIGNEDLONG,blk^.next)) THEN
             WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
             HALT; CODE(4AFCH);
           END;
           INC(bcntf);
           IF DIFADR(ADDADR(blk, blk^.size), ADDADR(hblk, size)) > LIC(0) THEN
             WriteInt(__LINE__,1); WriteString(": Freier Block teilweise ausserhalb des Heap-Blocks!"); WriteLn;
             HALT; CODE(4AFCH);
           END;
           IF   (DIFADR(blk^.next^.prev, blk) # LIC(0))
             OR (DIFADR(blk^.prev^.next, blk) # LIC(0))
           THEN
             WriteInt(__LINE__,1); WriteString(": Verzeigerung der freien Bloecke fehlerhaft!"); WriteLn;
             HALT; CODE(4AFCH);
           END;
           IF (blk^.next^.type # FreeMagic) OR (blk^.prev^.type # FreeMagic) THEN
             WriteInt(__LINE__,1); WriteString(": In der Liste steht ein falscher Blocktyp!"); WriteLn;
             HALT; CODE(4AFCH);
           END;
           IF DIFADR(ADDADR(blk, blk^.size), blk^.next) = LIC(0) THEN
             WriteInt(__LINE__,1); WriteString(": Aufeinanderfolgende freie Bloecke!"); WriteLn;
             HALT; CODE(4AFCH);
           END;
         ELSE
           WriteInt(__LINE__,1); WriteString(": Unbekannter Blocktyp!"); WriteLn;
           HALT; CODE(4AFCH);
         END;
         blk := ADDADR(blk, blk^.size);
       UNTIL DIFADR(blk, ADDADR(hblk, size)) >= LIC(0);
       IF DIFADR(blk, ADDADR(hblk, size)) # LIC(0) THEN
         WriteInt(__LINE__,1); WriteString(": Letzter Block endet nicht mit Heap-Block!"); WriteLn;
         HALT; CODE(4AFCH);
       END;
       IF (bcntb # nblks) OR (bcntf # nfree) THEN
         WriteInt(__LINE__,1); WriteString(": Anzahl der Bloecke stimmt nicht ueberein!"); WriteLn;
         HALT; CODE(4AFCH);
       END;
     ELSE
       WriteInt(__LINE__,1); WriteString(": Falscher Heap-Blocktyp!"); WriteLn;
       HALT; CODE(4AFCH);
     END;
     IF temp THEN
       INC(hcntt);
     ELSE
       INC(hcntp);
     END;
   END;
   hblk := hblk^.next;
 UNTIL DIFADR(hblk, ADR(root.heap)) = LIC(0);
 IF (hcntp # root.nperm) OR (hcntt # root.ntemp) OR (hcntr # LIC(1)) THEN
   WriteInt(__LINE__,1); WriteString(": Anzahl der Heap-Bloecke stimmt nicht ueberein!"); WriteLn;
   HALT; CODE(4AFCH);
 END;
END testintegrity;

(*---------------------------------------------------------------------------*)
#endif /* _DEBUG */

PROCEDURE ROUND ((* EIN/ -- *) val   : UNSIGNEDLONG;
                 (* EIN/ -- *) bound : UNSIGNEDLONG ): UNSIGNEDLONG;

(* <val> auf das kleinste Vielfache von <bound> groesser <val> runden *)
BEGIN
 RETURN(((val + bound - LC(1)) DIV bound) * bound);
END ROUND;

(*---------------------------------------------------------------------------*)

PROCEDURE BlkSize ((* EIN/ -- *) size : UNSIGNEDLONG ): UNSIGNEDLONG;
BEGIN
 IF size < VAL(UNSIGNEDLONG,MinBlkSize) THEN
   size := VAL(UNSIGNEDLONG,MinBlkSize);
 ELSIF ODD(size) THEN
   INC(size);
 END;
 RETURN(size + VAL(UNSIGNEDLONG,AllocBlkOverhead));
END BlkSize;

(*---------------------------------------------------------------------------*)

PROCEDURE GemdosBlkSize ((* EIN/ -- *) size : UNSIGNEDLONG ): UNSIGNEDLONG;
BEGIN
 INC(size, VAL(UNSIGNEDLONG,HeapBlkOverhead));
 IF size < MinGemdosBlkSize THEN
   size := MinGemdosBlkSize;
 END;
 RETURN(ROUND(size, PageSize));
END GemdosBlkSize;

(*---------------------------------------------------------------------------*)

PROCEDURE FindFreeBlkLink ((* EIN/ -- *) hblk : HeapBlkPtr;
                           (* EIN/ -- *) blk  : BlkPtr     ): BlkPtr;

(* Liefert einen Zeiger auf den freien Block, der gemaess seiner
 * Speicheradresse als naechster vor <blk> liegt.
 *)
VAR prev : BlkPtr;

BEGIN
 prev := hblk^.nextfree;
 LOOP
   IF  (CAST(UNSIGNEDLONG,blk) > CAST(UNSIGNEDLONG,prev))
     & (CAST(UNSIGNEDLONG,blk) < CAST(UNSIGNEDLONG,prev^.next))
   THEN
     (* zwischen zwei existierenden Bloecken *)
     RETURN(prev);
   END;
   IF  (CAST(UNSIGNEDLONG,prev) >= CAST(UNSIGNEDLONG,prev^.next))
     & (   (CAST(UNSIGNEDLONG,blk) > CAST(UNSIGNEDLONG,prev))
        OR (CAST(UNSIGNEDLONG,blk) < CAST(UNSIGNEDLONG,prev^.next)))
   THEN
     (* Neues "Ende" oder neuer "Anfang" der Liste *)
     RETURN(prev);
   END;
   prev := prev^.next;
   IF DIFADR(prev, hblk^.nextfree) = LIC(0) THEN
     (* Keinen Platz gefunden, Pointer kaputt? *)
     errno := EINVAL;
     RETURN(NULL);
   END;
 END;
END FindFreeBlkLink;

(*---------------------------------------------------------------------------*)

PROCEDURE LinkHeap ((* EIN/AUS *) VAR root : RootBlock;
                    (* EIN/ -- *)     new  : HeapBlkPtr;
                    (* EIN/ -- *)     len  : UNSIGNEDLONG;
                    (* EIN/ -- *)     perm : BOOLEAN      ): BOOLEAN;

(* Nimmt einen neuen Heap-Block in die Verwaltung auf *)
VAR         blk : BlkPtr;
#ifdef MM2
            pre : HeapBlkPtr;
#else
    __REG__ pre : HeapBlkPtr;
#endif
BEGIN
 pre := root.nextblk;
 (* Die Liste der Heap-Bloecke ist nach aufsteigenden Adressen sortiert.
  * Platz fuer neuen Heap-Block suchen.
  *)
 LOOP
   (* Hier kann nicht mit DIFADR gearbeitet werden, da die Adressen
    * unterschiedlicher GEMDOS-Bloecke ueber den gesamten 32-Bit-Adressraum
    * verteilt sein koennen (VME-Bus-RAM hat Adressen $FExxxxxx). Der
    * Vergleich muss also unbedingt vorzeichenlos erfolgen.
    *)
   IF  (CAST(UNSIGNEDLONG,new) > CAST(UNSIGNEDLONG,pre))
     & (CAST(UNSIGNEDLONG,new) < CAST(UNSIGNEDLONG,pre^.next))
   THEN
     (* zwischen zwei existierenden Bloecken *)
     EXIT;
   END;
   IF  (CAST(UNSIGNEDLONG,pre) >= CAST(UNSIGNEDLONG,pre^.next))
     & (   (CAST(UNSIGNEDLONG,new) > CAST(UNSIGNEDLONG,pre))
        OR (CAST(UNSIGNEDLONG,new) < CAST(UNSIGNEDLONG,pre^.next)))
   THEN
     (* Neues "Ende" oder neuer "Anfang" der Liste *)
     EXIT;
   END;
   pre := pre^.next;
   IF DIFADR(pre, root.nextblk) = LIC(0) THEN
     (* Keinen Platz gefunden, Pointer kaputt? *)
     errno := EINVAL;
     RETURN(FALSE);
   END;
 END;

 (* Neuen Heap-Block in die Liste einfuegen *)
 WITH new^ DO
#ifdef __CHECKS__
   type     := HeapMagic;
#endif
   next     := pre^.next;
   prev     := pre;
   size     := len;
   nblks    := 0;
#ifdef __CHECKS__
   nfree    := 1; (* Dummy-Block nicht mitzaehlen *)
#endif
   temp     := ~perm;
   nextfree := ADDADR(new, HeapBlkOverhead);
   (* Freien Dummy-Block initialisieren. Durch 'size' = 0
    * wird er weder bei "malloc()" vergeben noch bei "free()"
    * mit dem rechten Nachbarn verschmolzen.
    *)
#ifdef __CHECKS__
   freeblk.type := FreeMagic;
#endif
   freeblk.size := 0;
   freeblk.prev := nextfree;
   freeblk.next := nextfree;
 END;
 pre^.next^.prev := new;
 pre^.next       := new;

 (* Blockverwaltung innerhalb des neuen Heap-Blocks einrichten *)
 blk := ADDADR(new, HeapBlkOverhead);
 WITH blk^ DO
#ifdef __CHECKS__
   type := FreeMagic;
#endif
   size := len - VAL(UNSIGNEDLONG,HeapBlkOverhead);
   prev := ADR(new^.freeblk);
   next := prev;
 END;

 (* Startadresse fuer naechstes "malloc()" setzen *)
 root.nextblk := new;
#ifdef __CHECKS__
 IF perm THEN
   INC(root.nperm);
 ELSE
   INC(root.ntemp);
 END;
#endif
 RETURN(TRUE);
END LinkHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE ThreadNewHeap ((* EIN/AUS *) VAR root : RootBlock;
                         (* EIN/ -- *)     len  : UNSIGNEDLONG;
                         (* EIN/ -- *)     perm : BOOLEAN      ): BOOLEAN;

VAR new  : HeapBlkPtr;
    res  : INTEGER;
    void : BOOLEAN;

BEGIN
 len := GemdosBlkSize(len);

 IF Malloc(len, new) THEN
   IF LinkHeap(root, new, len, perm) THEN
     RETURN(TRUE);
   ELSE
     void := Mfree(new, res);
     RETURN(FALSE);
   END;
 ELSE
   errno := ENOMEM;
   RETURN(FALSE);
 END;
END ThreadNewHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE ThreadAddHeap ((* EIN/AUS *) VAR root : RootBlock;
                         (* EIN/ -- *)     adr  : ADDRESS;
                         (* EIN/ -- *)     len  : UNSIGNEDLONG ): BOOLEAN;

BEGIN
 IF len < VAL(UNSIGNEDLONG,HeapBlkOverhead + BlkOverhead) THEN
   (* Block ist zu klein *)
   errno := ENOMEM;
   RETURN(FALSE);
 ELSE
   RETURN(LinkHeap(root, adr, len, TRUE));
 END;
END ThreadAddHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE ThreadFree ((* EIN/AUS *) VAR root : RootBlock;
                      (* EIN/ -- *)     adr  : ADDRESS   );

VAR blk  : BlkPtr;
    pre  : BlkPtr;
    hblk : HeapBlkPtr;
    res  : INTEGER;
#ifdef __CHECKS__
    comb : BOOLEAN;
#endif

BEGIN
 IF adr = NULL THEN
   (* Spezialfunktion von "free()" *)
   RETURN;
 END;
#ifdef __CHECKS__
 IF (adr = NIL) OR ODD(CAST(UNSIGNEDLONG,adr)) THEN
   errno := EINVAL;
   RETURN;
 END;
#endif
 blk  := SUBADR(adr, AllocBlkOverhead);
#ifdef __CHECKS__
 IF blk^.type # AllocMagic THEN
   errno := EINVAL;
   RETURN;
 END;
#endif
 hblk := CAST(HeapBlkPtr,blk^.prev);
#ifdef __CHECKS__
 IF hblk^.type # HeapMagic THEN
   errno := EINVAL;
   RETURN;
 END;
#endif
#ifdef _DEBUG
 memfill(adr, 0FFFFFFFFH, blk^.size - VAL(UNSIGNEDLONG,AllocBlkOverhead));
#endif

 pre := FindFreeBlkLink(hblk, blk);
 IF pre = NULL THEN
   RETURN;
 END;

 (* Block in die Liste der freien Bloecke einklinken, und dabei versuchen
  * mit den direkten Nachbarn zu einem groesseren Block zu verschmelzen.
  * Vorsicht: Doppelt verkettete Liste...
  *)
 IF DIFADR(ADDADR(blk, blk^.size), pre^.next) = LIC(0) THEN
   (* 'blk' mit rechtem freiem Nachbarn kombinieren; dieser verschwindet *)
#ifdef __CHECKS__
   comb := TRUE;
#endif
   WITH pre^.next^ DO
     INC(blk^.size, size);
     blk^.next := next;
#ifdef __CHECKS__
     type := 0;
#endif
     size := 0;
     prev := NULL;
     next := NULL;
   END;
 ELSE
#ifdef __CHECKS__
   comb := FALSE;
#endif
   blk^.next := pre^.next;
 END;

 IF DIFADR(ADDADR(pre, pre^.size), blk) = LIC(0) THEN
   (* 'blk' mit linkem freiem Nachbarn 'pre' kombinieren; 'blk' verschwindet *)
   WITH blk^ DO
     INC(pre^.size, size);
     pre^.next  := next;
     next^.prev := pre;
#ifdef __CHECKS__
     type := 0;
#endif
     size := 0;
     prev := NULL;
     next := NULL;
   END;
#ifdef __CHECKS__
   IF comb THEN
     DEC(hblk^.nfree);
   END;
#endif
 ELSE
   WITH blk^ DO
#ifdef __CHECKS__
     type       := FreeMagic;
#endif
     prev       := pre;
     pre^.next  := blk;
     next^.prev := blk;
   END;
#ifdef __CHECKS__
   IF ~comb THEN
     INC(hblk^.nfree);
   END;
#endif
 END;

 root.nextblk   := hblk;
 hblk^.nextfree := pre;
 DEC(hblk^.nblks);

 IF (hblk^.nblks = LIC(0)) & hblk^.temp THEN
   (* Gemdos-Block ist restlos geleert, also aus Liste nehmen und freigeben *)
   hblk^.prev^.next := hblk^.next;
   hblk^.next^.prev := hblk^.prev;

#ifdef __CHECKS__
   DEC(root.ntemp);
#endif
   root.nextblk := hblk^.next;

   IF ~Mfree(hblk, res) THEN
     errno := res;
     RETURN;
   END;
 END;
#ifdef _DEBUG
 testintegrity(root);
#endif
END ThreadFree;

(*---------------------------------------------------------------------------*)

PROCEDURE ThreadMalloc ((* EIN/AUS *) VAR root : RootBlock;
                        (* EIN/ -- *)     size : sizeT     ): ADDRESS;

VAR __REG__ free : BlkPtr;
    __REG__ hblk : HeapBlkPtr;

BEGIN
 size := BlkSize(size);

 hblk := root.nextblk;
 LOOP
   free := hblk^.nextfree;
   LOOP
     IF free^.size >= size THEN
       (* Dieser freie Block ist gross genug *)
       root.nextblk   := hblk;
       hblk^.nextfree := free^.next;
       (* Naechstes "malloc()" beginnt mit der Suche beim Block danach *)
       INC(hblk^.nblks);
       IF free^.size - VAL(sizeT,BlkOverhead) <= size THEN
         (* Platz reicht nicht, um einen freien Block abzuspalten, deswegen
          * den kompletten, etwas zu grossen Block nehmen.
          *)
         free^.prev^.next := free^.next;
         free^.next^.prev := free^.prev;
#ifdef __CHECKS__
         DEC(hblk^.nfree);
#endif
       ELSE
         (* Neuer Block am Ende des freien Blocks und dessen Groesse
          * entsprechend verringern.
          *)
         DEC(free^.size, size);
         free := ADDADR(free, free^.size);
         free^.size := size;
       END;
#ifdef __CHECKS__
       free^.type := AllocMagic;
#endif
       free^.prev := CAST(BlkPtr,hblk);
#ifdef _DEBUG
       IF ODD(CAST(UNSIGNEDLONG,ADDADR(free, AllocBlkOverhead))) THEN
         WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
         HALT; CODE(4AFCH);
       END;
       memfill(ADDADR(free, AllocBlkOverhead), 0FFFFFFFFH, free^.size - VAL(UNSIGNEDLONG,AllocBlkOverhead));
       testintegrity(root);
#endif
       RETURN(ADDADR(free, AllocBlkOverhead));
     END;
     free := free^.next;
     IF DIFADR(free, hblk^.nextfree) = LIC(0) THEN
       (* Liste komplett durchlaufen, aber kein freier Block ist gross genug *)
       EXIT;
     END;
   END; (* LOOP *)
   hblk := hblk^.next; (* Naechsten Heap-Block probieren *)
   IF DIFADR(hblk, root.nextblk) = LIC(0) THEN
     (* Liste der Heap-Bloecke komplett durchlaufen, aber keiner hat einen
      * ausreichend grossen freien Block. Deswegen einen neuen Heap-Block
      * bei Gemdos anforden.
      *)
     IF ~ThreadNewHeap(root, size, FALSE) THEN
       (* Gemdos hat auch nichts mehr *)
       RETURN(NULL);
     END;
     (* Mit dem gerade angeforderten Gemdos-Block weitermachen *)
     hblk := root.nextblk;
   END;
 END; (* LOOP *)
END ThreadMalloc;

(*---------------------------------------------------------------------------*)

PROCEDURE ThreadRealloc ((* EIN/AUS *) VAR root : RootBlock;
                         (* EIN/ -- *)     adr  : ADDRESS;
                         (* EIN/ -- *)     size : sizeT     ): ADDRESS;

VAR __REG__ nsize : UNSIGNEDLONG;
    __REG__ dsize : UNSIGNEDLONG;
    __REG__ osize : UNSIGNEDLONG;
#ifdef MM2
            tmp   : BlkPtr;
            pre   : BlkPtr;
#else
    __REG__ tmp   : BlkPtr;
    __REG__ pre   : BlkPtr;
#endif
            blk   : BlkPtr;
            rest  : BlkPtr;
            hblk  : HeapBlkPtr;
            save  : Blk;

BEGIN
 (* Spezialfunktionen von "realloc()" *)
 IF adr = NULL THEN
   RETURN(ThreadMalloc(root, size));
 ELSIF size = VAL(sizeT,0) THEN
   ThreadFree(root, adr);
   RETURN(NULL);
 END;

#ifdef __CHECKS__
 IF (adr = NIL) OR ODD(CAST(UNSIGNEDLONG,adr)) THEN
   errno := EINVAL;
   RETURN(NULL);
 END;
#endif
 blk  := SUBADR(adr, AllocBlkOverhead);
#ifdef __CHECKS__
 IF blk^.type # AllocMagic THEN
   errno := EINVAL;
   RETURN(NULL);
 END;
#endif
 hblk := CAST(HeapBlkPtr,blk^.prev);
#ifdef __CHECKS__
 IF hblk^.type # HeapMagic THEN
   errno := EINVAL;
   RETURN(NULL);
 END;
#endif

 osize := blk^.size;
 nsize := BlkSize(size);
 IF osize < nsize THEN
   (* Block soll vergroessert werden. Erstmal testen, ob hinter dem
    * Block ein freier Block genuegender Groesse liegt, so dass die
    * Verschmelzung der beiden die gewuenschte Groesse liefert.
    *)
   pre := FindFreeBlkLink(hblk, blk);
   IF pre = NULL THEN
     RETURN(NULL);
   END;
   tmp   := pre^.next;
   dsize := osize + tmp^.size;
   IF (DIFADR(ADDADR(blk, osize), tmp) = LIC(0)) & (dsize >= nsize) THEN
     (* Der rechte 'tmp' Nachbar ist ein freier Block ausreichender Groesse *)
     IF dsize - VAL(sizeT,BlkOverhead) <= nsize THEN
       (* Platz reicht nicht, um einen freien Block abzuspalten, deswegen
        * den kompletten rechten Nachbarn dazunehmen.
        *)
       pre^.next       := tmp^.next;
       pre^.next^.prev := pre;

       WITH tmp^ DO
#ifdef __CHECKS__
         type := 0;
#endif
         size := 0;
         next := NULL;
         prev := NULL;
       END;
       blk^.size := dsize;
#ifdef __CHECKS__
       DEC(hblk^.nfree);
#endif
     ELSE
       (* Der hintere Teil des rechten Nachbarn 'tmp' kann als freier Block
        * zurueckgegeben werden.
        *)
       rest := ADDADR(blk, nsize);
       (* Den alten Header zwischenspeichern, da der Header des neuen Blocks
        * noch innerhalb des alten Headers liegen koennte.
        *)
       save := tmp^;
       WITH tmp^ DO
#ifdef __CHECKS__
         type := 0;
#endif
         size := 0;
         next := NULL;
         prev := NULL;
       END;
       WITH rest^ DO
#ifdef __CHECKS__
         type := FreeMagic;
#endif
         next := save.next;
         prev := pre;
         size := dsize - nsize;
       END;
       save.next^.prev := rest;
       pre^.next       := rest;
       blk^.size       := nsize;
     END;
     (* Wenn der Heap-Zeiger auf den naechsten freien Block auf den rechten
      * Nachbarn zeigt, muss er jetzt korrigiert werden, da der rechte
      * Nachbar nicht mehr existiert, bzw. nach hinten verschoben wurde.
      *)
     IF DIFADR(hblk^.nextfree, tmp) = LIC(0) THEN
       hblk^.nextfree := pre^.next;
     END;
   ELSE
     (* Es bleibt nichts anderes uebrig als einen neuen Block der
      * gewuenschten Groesse anzufordern, die Daten umzukopieren und
      * den alten Block dann freizugeben. Da dabei Platz fuer beide
      * Bloecke benoetigt wird, kann es sein, dass der neue Block nicht
      * angefordert werden kann, obwohl insgesamt noch genuegend Platz
      * frei waere.
      *)
     tmp := ThreadMalloc(root, size);
     IF tmp # NULL THEN
       memmove(tmp, adr, osize - VAL(UNSIGNEDLONG,AllocBlkOverhead));
       ThreadFree(root, adr);
     END;
     adr := tmp;
   END;
 ELSIF osize - VAL(sizeT,BlkOverhead) >= nsize THEN
   (* Die Groesse des Blockes wird soweit verringert, dass der Rest
    * freigegeben werden kann.
    *)
   pre := FindFreeBlkLink(hblk, blk);
   IF pre = NULL THEN
     RETURN(NULL);
   END;
   tmp  := pre^.next;
   rest := ADDADR(blk, nsize);
   IF DIFADR(ADDADR(blk, osize), tmp) = LIC(0) THEN
     (* Der rechte Nachbar 'tmp' ist ein freier Block, deswegen muss der
      * freigegebene Teil mit dem Nachbarn verschmolzen werden.
      *)
     save := tmp^;
     WITH tmp^ DO
#ifdef __CHECKS__
       type := 0;
#endif
       size := 0;
       next := NULL;
       prev := NULL;
     END;
     WITH rest^ DO
       next := save.next;
       size := save.size + osize - nsize;
     END;
     IF DIFADR(hblk^.nextfree, tmp) = LIC(0) THEN
       (* Der naechste freie Block beginnt jetzt vorher *)
       hblk^.nextfree := rest;
     END;
   ELSE
     (* Der Rest wird einfach zu einem neuen freien Block *)
     WITH rest^ DO
       next := pre^.next;
       size := osize - nsize;
     END;
#ifdef __CHECKS__
     INC(hblk^.nfree);
#endif
   END;
   WITH rest^ DO
#ifdef __CHECKS__
     type       := FreeMagic;
#endif
     next^.prev := rest;
     prev       := pre;
   END;
   pre^.next := rest;
   blk^.size := nsize;
 END;
#ifdef _DEBUG
 IF ODD(CAST(UNSIGNEDLONG,adr)) THEN
   WriteInt(__LINE__,1); WriteString(": Ungerade Adresse!"); WriteLn;
   HALT; CODE(4AFCH);
 END;
 blk := SUBADR(adr, AllocBlkOverhead);
 memfill(ADDADR(blk, osize), 0FFFFFFFFH, blk^.size - osize);
 testintegrity(root);
#endif
 RETURN(adr);
END ThreadRealloc;

(*---------------------------------------------------------------------------*)

PROCEDURE InitRoot ((* EIN/ -- *)     id   : pidT;
                    (* -- /AUS *) VAR root : RootBlock );
BEGIN
 WITH root DO
   pid     := id;
#ifdef __CHECKS__
   nperm   := 1;
   ntemp   := 0;
#endif
   nextblk := ADR(heap);

#ifdef __CHECKS__
   heap.type     := RootMagic;
#endif
   heap.temp     := FALSE;
   heap.size     := 0;
   heap.nblks    := 0;
#ifdef __CHECKS__
   heap.nfree    := 0;
#endif
   heap.nextfree := ADR(heap.freeblk);
   heap.prev     := ADR(heap);
   heap.next     := ADR(heap);

#ifdef __CHECKS__
   heap.freeblk.type := FreeMagic;
#endif
   heap.freeblk.size := 0;
   heap.freeblk.prev := ADR(heap.freeblk);
   heap.freeblk.next := ADR(heap.freeblk);
 END;
END InitRoot;

(*---------------------------------------------------------------------------*)
#ifdef __THREADSAFE__
PROCEDURE LockThread ( ): UNSIGNEDLONG;

VAR mask : UNSIGNEDLONG;
    done : BOOLEAN;
    res  : INTEGER;

BEGIN
 mask := Psigblock(0FFFFFFFFH);
 done := Psemaphore(SemaRequest, Sema.id, SemaBlock, res);
 RETURN(mask);
END LockThread;

(*---------------------------------------------------------------------------*)

PROCEDURE UnlockThread ((* EIN/ -- *) sigmask : UNSIGNEDLONG );

VAR done : BOOLEAN;
    res  : INTEGER;

BEGIN
 done    := Psemaphore(SemaRelease, Sema.id, SemaIgnore, res);
 sigmask := Psigsetmask(sigmask);
END UnlockThread;

(*---------------------------------------------------------------------------*)
#endif
PROCEDURE RegisterThread ((* EIN/ -- *) pid : pidT ): BOOLEAN;
#ifdef __THREADSAFE__
VAR         mask : UNSIGNEDLONG;
            min  : UNSIGNEDWORD;
    __REG__ i    : UNSIGNEDWORD;
    __REG__ id   : pidT;
            free : BOOLEAN;
#endif
BEGIN
#ifdef __THREADSAFE__
 mask := LockThread();
 i    := 0;
 min  := 0;
 free := FALSE;
 LOOP
   id := ThreadRoots[i].pid;
   IF id = pid THEN
     (* Prozess ist schon angemeldet -> Fehler  *)
     free := FALSE;
     EXIT;
   ELSIF ~free & (id < 0) THEN
     free := TRUE;
     min  := i;
   END;
   INC(i);
   IF i = NThreads THEN
     (* Kein Platz mehr -> Fehler *)
     EXIT;
   END;
 END;
 IF free THEN
   InitRoot(pid, ThreadRoots[min]);
 END;
 UnlockThread(mask);
 RETURN(free);
#else
 RETURN(TRUE);
#endif
END RegisterThread;

(*---------------------------------------------------------------------------*)

PROCEDURE UnregisterThread ((* EIN/ -- *) pid : pidT );
#ifdef __THREADSAFE__
VAR         mask : UNSIGNEDLONG;
    __REG__ i    : UNSIGNEDWORD;
#endif
BEGIN
#ifdef __THREADSAFE__
 mask := LockThread();
 i    := 0;
 WHILE (i < NThreads) & (ThreadRoots[i].pid # pid) DO
   INC(i);
 END;
 IF i < NThreads THEN
   ThreadRoots[i].pid := -1;
   (* Evtl. noch vorhandene Gemdos-Speicherbloecke stehen jetzt nicht mehr
    * unter Kontrolle von 'mem' und koennen auch nicht freigegeben werden!
    *)
 END;
 UnlockThread(mask);
#endif
END UnregisterThread;

(*---------------------------------------------------------------------------*)

PROCEDURE RegisterMe ( ): BOOLEAN;
BEGIN
 RETURN(RegisterThread(ActPid()));
END RegisterMe;

(*---------------------------------------------------------------------------*)

PROCEDURE UnregisterMe;
BEGIN
 UnregisterThread(ActPid());
END UnregisterMe;

(*---------------------------------------------------------------------------*)

PROCEDURE malloc ((* EIN/ -- *) size : sizeT ): ADDRESS;
#ifdef __THREADSAFE__
VAR         mask : UNSIGNEDLONG;
    __REG__ i    : UNSIGNEDWORD;
            pid  : pidT;
            adr  : ADDRESS;
#endif
BEGIN
#ifdef __THREADSAFE__
 mask := LockThread();
 pid  := ActPid();
 i    := 0;
 WHILE (i < NThreads) & (ThreadRoots[i].pid # pid) DO
   INC(i);
 END;
 IF i < NThreads THEN
   adr   := ThreadMalloc(ThreadRoots[i], size);
 ELSE
   adr   := NULL;
   errno := ESRCH; (* Thread nicht registriert *)
 END;
 UnlockThread(mask);
 RETURN(adr);
#else
 RETURN(ThreadMalloc(ThreadRoots[0], size));
#endif
END malloc;

(*---------------------------------------------------------------------------*)

PROCEDURE free ((* EIN/ -- *) adr : ADDRESS );
#ifdef __THREADSAFE__
VAR         mask : UNSIGNEDLONG;
    __REG__ i    : UNSIGNEDWORD;
            pid  : pidT;
#endif
BEGIN
#ifdef __THREADSAFE__
 mask := LockThread();
 pid  := ActPid();
 i    := 0;
 WHILE (i < NThreads) & (ThreadRoots[i].pid # pid) DO
   INC(i);
 END;
 IF i < NThreads THEN
   ThreadFree(ThreadRoots[i], adr);
 ELSE
   errno := ESRCH;
 END;
 UnlockThread(mask);
#else
 ThreadFree(ThreadRoots[0], adr);
#endif
END free;

(*---------------------------------------------------------------------------*)

PROCEDURE realloc ((* EIN/ -- *) adr  : ADDRESS;
                   (* EIN/ -- *) size : sizeT   ): ADDRESS;

#ifdef __THREADSAFE__
VAR         mask : UNSIGNEDLONG;
    __REG__ i    : UNSIGNEDWORD;
            pid  : pidT;
#endif
BEGIN
#ifdef __THREADSAFE__
 mask := LockThread();
 pid  := ActPid();
 i    := 0;
 WHILE (i < NThreads) & (ThreadRoots[i].pid # pid) DO
   INC(i);
 END;
 IF i < NThreads THEN
   adr   := ThreadRealloc(ThreadRoots[i], adr, size);
 ELSE
   adr   := NULL;
   errno := ESRCH;
 END;
 UnlockThread(mask);
 RETURN(adr);
#else
 RETURN(ThreadRealloc(ThreadRoots[0], adr, size));
#endif
END realloc;

(*---------------------------------------------------------------------------*)

PROCEDURE NewHeap ((* EIN/ -- *) size : UNSIGNEDLONG;
                   (* EIN/ -- *) perm : BOOLEAN      ): BOOLEAN;

#ifdef __THREADSAFE__
VAR         mask : UNSIGNEDLONG;
    __REG__ i    : UNSIGNEDWORD;
            pid  : pidT;
            done : BOOLEAN;
#endif
BEGIN
#ifdef __THREADSAFE__
 mask := LockThread();
 pid  := ActPid();
 i    := 0;
 WHILE (i < NThreads) & (ThreadRoots[i].pid # pid) DO
   INC(i);
 END;
 IF i < NThreads THEN
   done  := ThreadNewHeap(ThreadRoots[0], size, perm);
 ELSE
   done  := FALSE;
   errno := ESRCH;
 END;
 UnlockThread(mask);
 RETURN(done);
#else
 RETURN(ThreadNewHeap(ThreadRoots[0], size, perm));
#endif
END NewHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE AddHeap ((* EIN/ -- *) adr  : ADDRESS;
                   (* EIN/ -- *) size : UNSIGNEDLONG ): BOOLEAN;

#ifdef __THREADSAFE__
VAR         mask : UNSIGNEDLONG;
    __REG__ i    : UNSIGNEDWORD;
            pid  : pidT;
            done : BOOLEAN;
#endif
BEGIN
#ifdef __THREADSAFE__
 mask := LockThread();
 pid  := ActPid();
 i    := 0;
 WHILE (i < NThreads) & (ThreadRoots[i].pid # pid) DO
   INC(i);
 END;
 IF i < NThreads THEN
   done  := ThreadAddHeap(ThreadRoots[0], adr, size);
 ELSE
   done  := FALSE;
   errno := ESRCH;
 END;
 UnlockThread(mask);
 RETURN(done);
#else
 RETURN(ThreadAddHeap(ThreadRoots[0], adr, size));
#endif
END AddHeap;

(*---------------------------------------------------------------------------*)

PROCEDURE calloc ((* EIN/ -- *) cnt  : sizeT;
                  (* EIN/ -- *) size : sizeT ): ADDRESS;

VAR total : UNSIGNEDLONG;
    mem   : ADDRESS;

BEGIN
 total := cnt * size;
 mem   := malloc(total);
 IF mem # NULL THEN
   memfill(mem, LC(0), total);
 END;
 RETURN(mem);
END calloc;

(*---------------------------------------------------------------------------*)

PROCEDURE strdup ((* EIN/ -- *) s : StrPtr ): StrPtr;

VAR new : StrPtr;
    len : sizeT;

BEGIN
#if no_MIN_MAX
 len := DIFADR(memchr(s, 0, MAXUNSIGNEDLONG), s) + LIC(1);
#else
 len := DIFADR(memchr(s, 0, MAX(sizeT)), s) + LIC(1);
#endif
 new := malloc(len);
 IF new # NULL THEN
   memmove(new, s, len);
 END;
 RETURN(new);
END strdup;

#ifdef __THREADSAFE__
(*---------------------------------------------------------------------------*)
#ifdef HM2
(*$E+*)
#endif
PROCEDURE Finalize;
VAR done : BOOLEAN;
    res  : INTEGER;
BEGIN
 (* Bevor die Semaphore beseitigt werden kann, muss sie erst
  * angefordert werden!
  *)
 done := Psemaphore(SemaRequest, Sema.id, SemaBlock, res);
 done := Psemaphore(SemaDestroy, Sema.id, SemaIgnore, res);
END Finalize;
#ifdef HM2
(*$E=*)
#endif
#endif /* __THREADSAFE__ */
(*===========================================================================*)

#ifdef __THREADSAFE__
VAR res : INTEGER;
    i   : UNSIGNEDWORD;
#endif
BEGIN (* mem *)
 PageSize := GetPageSize();

 InitRoot(ActPid(), ThreadRoots[0]);

#ifdef __THREADSAFE__
 FOR i := 1 TO NThreads - 1 DO
   ThreadRoots[i].pid := -1;
 END;

 Sync := FALSE;
 i    := 0;
 (* Vermutlich eindeutige Semaphore-Id *)
 Sema.asc := 4D32H; (* "M2" *)
 Sema.pid := VAL(SIGNEDWORD,ActPid());
 (* Wenn diese Semaphore schon existiert, die pid solange hochzaehlen,
  * bis die Semaphore eindeutig ist.
  *)
 LOOP
   IF Psemaphore(SemaCreate, Sema.id, SemaIgnore, res) THEN
     (* Nach dem Erzeugen, Semaphore erstmal wieder freigeben *)
     Sync := Psemaphore(SemaRelease, Sema.id, SemaIgnore, res);
     EXIT;
   ELSIF res = eACCDN THEN
     (* Existiert bereits, neue Id probieren *)
     INC(Sema.pid);
     INC(i);
     IF i > 100 THEN
       (* Sicherung gegen Endlosschleife *)
       EXIT;
     END;
   ELSE
     (* Semaphore kann nicht angelegt werden *)
     Sync := FALSE;
     EXIT;
   END;
 END;

#ifdef ISOM2
FINALLY (* mem *)
 Finalize;
#else
 res := atexit(Finalize);
#endif
#endif /* __THREADSAFE__ */
END mem.

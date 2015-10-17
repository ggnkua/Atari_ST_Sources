IMPLEMENTATION MODULE StorUtils;
(*------------------------------------------------------------------------*)
(* Debuggingroutien mit Hilfe von Storage                                 *)
(* Erstellt unter Verwendung von NewStorTest                              *)
(*------------------------------------------------------------------------*)
(* Autor:                                                                 *)
(* Gerd Castan, Hoehbergstr. 16, 70327 Stuttgart                          *)
(* EMail: G.Castan@physik.uni-stuttgart.de                                *)
(*------------------------------------------------------------------------*)
(* Version | Datum    | Arbeitsbericht                                    *)
(* 1.01    | 26.03.94 | Addr/Block/BlockExactInStorage,findBlock          *)
(* 2.01    | 26.03.94 | GetAllocInfo,TestStorage                          *)
(* 2.02    | 27.03.94 | Zum Betatest Freigegeben von Gc                   *)
(* 2.03    | 27.03.94 | findBlock entwanzt; Freigegeben von Gc            *)
(*------------------------------------------------------------------------*)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, ADR, BYTE;
FROM Storage IMPORT More;
FROM StorBase IMPORT Inconsistent, FullStorBaseAccess, MemSize;

(*------------------------------------------------------------------------*)
(* Datenstrukturen aus NewStorTest                                        *)
(*------------------------------------------------------------------------*)

TYPE
        PtrHead = POINTER TO Head;

        HeadLink = RECORD
                     n: INTEGER;  (* rel. offset von block.data *)
                     p: INTEGER;  (* rel. offset von block.data *)
                   END;

        Head  = RECORD;           (* werden nur fÅr used-Bereiche benutzt *)
                  hd: HeadLink;
                  root: INTEGER;  (* rel. Offset von Block.data (pos.Wert) *)
                  level: INTEGER;
                  size: INTEGER;  (* used-Grîûe, kann ungerade sein!     *)
                                  (* -- muû immer vor 'hd.data' stehen   *)
                                  (* damit 'fullBlk' funktioniert!       *)
                  data: BYTE      (* Beginn der Daten *)
                END;
CONST
        HeadSize = 10;            (* TSIZE (Head ohne data) *)

TYPE
        PtrLink = POINTER TO Link;

        Link = RECORD
                 next: PtrLink;
                 prev: PtrLink;
               END;

        PtrBlock = POINTER TO Block;

        Block = RECORD
                  blk: Link;
                  size: LONGINT;  (* Grîûe des verfÅgbaren Bereichs *)
                                  (*  kann ungerade sein!           *)
                                  (* Bit 30: <full>                 *)
                  CASE : CARDINAL OF
                  | 0: (* full *)
                    level: INTEGER;
                    full: CARDINAL; (* = 0, wenn full *)
                    fullData: BYTE
                  | 1: (* root *)
                    blRov: PtrBlock (* zeigt direkt auf letzten Block *)
                  | 2: (* not full *)
                    hd: HeadLink;
                    hdRov: INTEGER; (* letzer hd, wo alloc durchgef. wurde *)
                    free: LONGINT;  (* gesamter freier Bereich in Block *)
                    hds : BYTE      (* Beginn der Header/Freibereiche *)
                  END
                END;
CONST
        BlockSize     = 22;  (* TSIZE (Block ohne hds) *)
        BlockFullSize = 16;  (* TSIZE (Block, 0) *)

VAR RootPtr: PtrBlock;

(*------------------------------------------------------------------------*)
(* Zugriff auf Datenstrukturen aus NewStorTest                            *)
(*------------------------------------------------------------------------*)

PROCEDURE abs (bl: PtrBlock; hd: INTEGER): ADDRESS;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; RETURN ADR (bl^.hds) + LONGCARD (LONG (hd))
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        ADDA.W  D0,A0
        ADDA.W  #BlockSize,A0
        MOVE.L  A0,(A3)+
    END
  END abs;
  (*$L=*)

PROCEDURE sizeHd (bl: PtrBlock; hd: INTEGER): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; hdp:= abs (bl, hd);
        ; RETURN val (hdp^.size)
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.W  Head.size+BlockSize(A0,D0.W),D0
        ADDQ    #1,D0
        ANDI    #$FFFE,D0
        MOVE    D0,(A3)+
    END;
  END sizeHd;
  (*$L=*)

PROCEDURE blkFull (bl: PtrBlock): BOOLEAN;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        BTST    #6,Block.size(A0)
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END blkFull;
  (*$L=*)

PROCEDURE blkSize (bl: PtrBlock): LONGINT;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  Block.size(A0),D0
        ANDI.L  #$00FFFFFF,D0
        MOVE.L  D0,(A3)+
    END
  END blkSize;
  (*$L=*)

PROCEDURE nextHd (bl: PtrBlock; hd: INTEGER): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; hdp:= abs (bl, hd);
        ; RETURN hdp^.hd.n
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.W  Head.hd.n+BlockSize(A0,D0.W),(A3)+
    END;
  END nextHd;
  (*$L=*)

(*------------------------------------------------------------------------*)
(* Interne Prozeduren                                                     *)
(*------------------------------------------------------------------------*)

PROCEDURE
  findBlock (addr: ADDRESS; VAR full: BOOLEAN; VAR size: LONGINT): PtrBlock;
  (* Sucht in den internen Datenstrukturen nach dem Block, der adr enthÑlt.
   * Dabei ist es unerheblich, ob sdr zur internen Verwaltung gehîrt oder
nicht.
   * Wenn kein Block gefunden wurde, oder adr innerhalb RootPtr^ ist,
   * wird NIL zurÅckgegeben.
   * full: Block ist nicht weiter unterteilt.
   *)
  VAR
    bl: PtrBlock;
    count: CARDINAL;  (* Zur Sicherheit Endlosschleife vermeiden *)
BEGIN
  count := 0;
  bl:= RootPtr;
  IF bl=NIL THEN RETURN NIL END;                    (* Nur zur Sicherheit *)
  LOOP
    (* Alles durchsucht oder Fehler? *)
    bl:= ADDRESS (bl^.blk.next);
    IF bl=NIL THEN RETURN NIL END;                  (* Nur zur Sicherheit *)
    IF bl = RootPtr THEN RETURN NIL END;

    full := blkFull(bl);
    (* addr innerhalb Block? *)
    IF full THEN
      IF (LONGINT(ADR(bl^.fullData))<=LONGINT(addr))
      AND (LONGINT(addr)<LONGINT(ADR(bl^.fullData))+blkSize(bl)) THEN
        size := blkSize(bl);
        RETURN bl
      END;
    ELSE
      IF (LONGINT(ADR(bl^.hds))<=LONGINT(addr))
      AND (LONGINT(addr)<LONGINT(ADR(bl^.hds))+blkSize(bl)) THEN
        size := blkSize(bl);
        RETURN bl
      END;
    END;

    (* Endlosschleife? *)
    INC (count);
    IF count=MAX(CARDINAL) THEN RETURN NIL END;
  END;
END findBlock;


PROCEDURE
  findHead (bl: PtrBlock; addr: ADDRESS; VAR hd: PtrHead; VAR size: INTEGER);
  VAR
    freeBeg, usedBeg: INTEGER;
    ad              : ADDRESS;
BEGIN
  freeBeg:= 0;            (* End of last used area *)
  usedBeg:= bl^.hd.n;     (* Start of new used area *)
  LOOP
    IF usedBeg < 0 THEN
      (* rest ist hîchstens frei *)
      (*RETURN*)
    ELSE

    END;
    hd:= abs (bl, usedBeg);

    (* addr innerhalb des allocierten Bereichs? *)
    ad:= ADR (hd^.data);
    IF (LONGINT(ad)<=LONGINT(addr))
    AND (LONGINT(addr)<=LONGINT(ad)+LONG(hd^.size)) THEN
      (* Gefunden: *)
      size := hd^.size;
      RETURN
    END;

    IF usedBeg < 0 THEN
      (* rest ist hîchstens frei *)
      hd := NIL; size := 0;
      RETURN
    END;

    freeBeg:= usedBeg + HeadSize + sizeHd (bl, usedBeg);
    usedBeg:= nextHd (bl, usedBeg)
  END
END findHead;


(*------------------------------------------------------------------------*)
(* Exportierte Prozeduren                                                 *)
(*------------------------------------------------------------------------*)


PROCEDURE GetAllocInfo (addr: ADDRESS; VAR start: ADDRESS; VAR size: LONGCARD);
  (* Wenn addr zu einem Speicherblock gehîrt, der mit Storage.ALLOCATE
   * angefordert wurde, gibt start den Beginn und size die LÑnge dieses
   * Speicherblocks an, sonst ist start=NIL und size=0.
   *)
VAR
    bl: PtrBlock;
    hd: PtrHead;
    l : INTEGER;
    full: BOOLEAN;
    blsize: LONGINT;
BEGIN
  bl := findBlock(addr, full, blsize);

  (* Gar kein Block gefunden? *)
  IF bl=NIL THEN start := NIL; size := 0; RETURN END;

  (* Block nicht weiter unterteilt? *)
  IF full THEN
    start := ADR(bl^.fullData);
    size := VAL(LONGCARD, blsize);
    RETURN
  END;

  (* Innerhalb des Blocks weitersuchen: *)
  findHead (bl, addr, hd, l);
  IF hd=NIL THEN start := NIL; size := 0; RETURN END;

  start := ADR (hd^.data);
  (*size := VAL (LONGCARD, LONG(hd^.size));*)
  size := VAL (LONGCARD, LONG(l));
END GetAllocInfo;


PROCEDURE AddrInStorage (addr: ADDRESS): BOOLEAN;
  (* Gehîrt addr zu einem Speicherblock, der mit Storage.ALLOCATE angefordert
   * wurde?
   *)
  VAR
    start : ADDRESS;
    blsize: LONGCARD;
BEGIN
  GetAllocInfo (addr, start, blsize);
  RETURN start#NIL
END AddrInStorage;


PROCEDURE BlockInStorage (addr: ADDRESS; size: LONGCARD): BOOLEAN;
  (* Paût addr in einen Speicherblock, der mit Storage.ALLOCATE angefordert
   * wurde?
   *)
  VAR
    start : ADDRESS;
    blsize: LONGCARD;
BEGIN
  GetAllocInfo (addr, start, blsize);

  (* Gar kein Block gefunden? *)
  IF start=NIL THEN RETURN FALSE END;

  RETURN (LONGCARD(start)<=LONGCARD(addr)) AND
         (LONGCARD(addr)+size<=LONGCARD(start)+blsize)

END BlockInStorage;


PROCEDURE BlockExactInStorage (addr: ADDRESS; size: LONGCARD): BOOLEAN;
  (* Paût addr exakt in einen Speicherblock, der mit Storage.ALLOCATE
   * angefordert wurde?
   *)
VAR
    start : ADDRESS;
    blsize: LONGCARD;
BEGIN
  GetAllocInfo (addr, start, blsize);

  (* Gar kein Block gefunden? *)
  IF start=NIL THEN RETURN FALSE END;

  RETURN (LONGCARD(start)=LONGCARD(addr)) AND
         (LONGCARD(addr)+size=LONGCARD(start)+blsize)

END BlockExactInStorage;


PROCEDURE TestStorage (): StorageError;
  (* Unterzieht die interne Speicherverwaltung von Storage einem
   * PlausibilitÑtstest.
   * Wird storageOk zurÅckgegeben, ist (wahrscheinlich) alles in Ordnung.
   *
   * Wenn nicht, gibt es dafÅr 2 mîgliche Ursachen:
   * - Ein Fehler in Storage.
   *   In diesem Fall geben die Fehlermeldungen an, wo der Fehler zu suchen ist.
   * - Wahrscheinlicher: Ihr Programm oder ein parallel laufendes Programm
   *   hat wild in den Speicher geschrieben.
   *   In diesem Fall zÑhlt nur, ob storageOk oder etwas anderes
   *   zurÅckgegeben wurde.
   *   Welcher Fehler zurÅckgegeben wird ist hier uninteressant.
   *)
  VAR
    bl    : PtrBlock;
    blPrev: PtrBlock;
    count : CARDINAL;  (* Zur Sicherheit Endlosschleife vermeiden *)
    full  : BOOLEAN;
    fullStorBaseAccess: BOOLEAN;
    freeBeg, usedBeg  : INTEGER;
    hd                : PtrHead;
    prevHd            : PtrHead;
BEGIN
  IF Inconsistent() THEN RETURN storageInconsistent END;
  fullStorBaseAccess := FullStorBaseAccess();

  count := 0;
  bl:= RootPtr;
  IF bl=NIL THEN RETURN storageNIL END;
  LOOP
    blPrev := bl;
    bl:= ADDRESS (bl^.blk.next);

    (* VorwÑrtsverkettung endet bei RootPtr *)
    IF bl=NIL THEN RETURN storageNIL END;

    (* bl ungerade? *)
    IF LONGCARD(bl) MOD 2 = 1 THEN
      RETURN storageOdd
    END;

    (* RÅckwÑrtsverkettung testen: *)
    IF PtrBlock(bl^.blk.prev)#blPrev THEN
      RETURN storagePrev1
    END;

    (* Fertig? *)
    IF bl = RootPtr THEN RETURN storageOK END;

    IF fullStorBaseAccess AND (MemSize(bl)=0) THEN
      (* Block scheint nicht Åber StorBase.ALLOCATE geholt worden zu sein *)
      RETURN storageNotAlloc
    END;

    full := blkFull(bl);
    IF ~full THEN
      (* Block ist granuliert: *)
      freeBeg:= 0;            (* End of last used area *)
      usedBeg:= bl^.hd.n;     (* Start of new used area *)
      hd := NIL;
      LOOP
        IF usedBeg < 0 THEN
          (* rest ist hîchstens frei *)
          EXIT
        END;

        prevHd := hd;
        hd:= abs (bl, usedBeg);

        (* RÅckwÑrtsverkettung testen: *)
        IF (prevHd#NIL)
        AND (abs (bl, hd^.hd.p)#prevHd) THEN
          RETURN storagePrev2
        END;

        (* Zeiger auf nÑchstes muû grîûer als Zeiger auf aktuelles sein: *)
        IF (hd^.hd.n>0) AND (hd^.hd.n<=usedBeg) THEN
          RETURN storageNext2
        END;

        (* Aktueller Zeiger + Platz fÅr Daten muû < nÑchster Zeiger sein: *)
        IF (hd^.hd.n>0) AND (usedBeg+hd^.size>=hd^.hd.n) THEN
          RETURN storageSize2
        END;

        freeBeg:= usedBeg + HeadSize + sizeHd (bl, usedBeg);
        usedBeg:= nextHd (bl, usedBeg)
      END (* LOOP 2 *)

    END; (* IF ~full *)

    (* Endlosschleife? *)
    INC (count);
    IF count=MAX(CARDINAL) THEN RETURN storageCircle1 END;
  END; (* LOOP 1 *)
END TestStorage;

BEGIN
  More ($4EF3, ADR (RootPtr));
END StorUtils.

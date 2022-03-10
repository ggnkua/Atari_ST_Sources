IMPLEMENTATION MODULE IndexFiles;

(*                             Von Michael H.                               *)
(*  portiert nach M-2 August '91 von Christian Felsch und Peter Oleski.     *)       
(*  Diese ISAM ist Public Domain und darf von jedem fÅr zivile Aufgaben     *)
(*  benutzt werden. Eine Nutzung fÅr militÑrische Zwecke ist untersagt !    *)
(*                         Diese ISAM ist Peace-Ware !                      *)
(*                         ---------------------------                      *)
(*  Diese ISAM darf verÑndert und erweitert werden. Bei guten Erweiterungen *)
(*  und Fehlern benachrichtigung bitte an uns senden.                       *)
(*  Die ISAM hat unsere Platte NICHT zerstîrt aber wir Åbernehmen keine     *)
(*  Verantwortung fÅr nichts.                                               *)
(*  Wir bitten aber, falls diese ISAM einmal eine Verwendung findet, uns    *)
(*  mit dem Satz ' ISAM by Jau-Team ' zu erwÑhnen.                          *)
(*  Wird mit dieser Bibliothek ein kommerzielles Programm erstellt, so ist  *)
(*  uns ein kostenloses Exemplar zuzusenden                                 *)
(*  Zu erreichen unter:                                                     *)
(*                                                                          *)
(*      E-Mail: Peter Oleski        oder   Christian Felsch @ HH (MausNet)  *)
(*  gelbe Post: Eiûendorfergrenzweg 83a     Bevenser Weg 18                 *)
(*                             2100 Hamburg 90                              *)


 FROM MOSGlobals  IMPORT fCRCError, fFileNotFound, fNoMoreFiles, fFileExists,
                         fInsufficientMemory;
 FROM IsamGlobals IMPORT ErrorCode, PageStackSize, TaPageStackPtr, True, False,
                         TaPageMapPtr, PagePtr, TaStackRecPtr, IsamKeyStr,
                         MaxKeyLen, KeyTooLargeError, KeySizeMismatchError,
                         Page, IndexType, IdxFile, PageSize, Item, Order, Move,
                         CreateHeader, ReadHeader, CloseInternFile, FileUpdated,
                         TaRecordBuffer, TaPageMap, TaPageStack, TaRecBuf, TaStackRec;
 FROM FixFiles    IMPORT FixPut, FixGet, FixFlush, FixNew, FixDel;
 FROM SYSTEM      IMPORT BYTE, ADDRESS, ADR, CAST, TSIZE;
 FROM Storage     IMPORT ALLOCATE, DEALLOCATE, MemAvail;
 FROM Strings     IMPORT Copy, Assign, StrEqual, Compare, Relation;
 FROM Files       IMPORT Create, Open, Close, Access, ReplaceMode, State,
                         GetFileName;
 FROM Directory   IMPORT Delete;
 FROM PrgCtrl     IMPORT TermProcess;
 FROM Block       IMPORT Clear;

 
 CONST ItemOverhead = TSIZE(Item) - TSIZE(IsamKeyStr);
       PageOverhead = TSIZE(Page) - PageSize * TSIZE(Item);


 TYPE IndexStack = POINTER TO IndexEntry;
  
      IndexEntry = RECORD 
                    Vorg    : IndexStack;
                    IndexPtr: POINTER TO IdxFile;
                   END;

      PageBlock  = ARRAY [0..MaxInt] OF BYTE;


 VAR IndexStapel : IndexStack;
     ExitProcSave: ADDRESS;
     TaPageStk   : TaPageStackPtr;
     TaPgMap     : TaPageMapPtr;
     ok          : BOOLEAN;


 PROCEDURE PackPage(VAR Seite: Page; key: BYTE);
  VAR I,KeyL: INTEGER;
      P     : POINTER TO PageBlock;

  BEGIN
   KeyL:=INTEGER(LONG(key));
   P:= ADR(Seite);
   IF (KeyL # MaxKeyLen) THEN 
    FOR I := 1 TO Seite.ItemsOnPage DO
     Move(ADR(Seite.ItemArray[I]),
          ADR(P^[(I - 1) * (KeyL + ItemOverhead) + PageOverhead]),
          KeyL + ItemOverhead);
    END(*FOR*);
   END(*IF*);
  END PackPage; 


 PROCEDURE UnpackPage(VAR Seite: Page; key: BYTE);
  VAR I,KeyL : INTEGER;
      P      : POINTER TO PageBlock;

  BEGIN
   KeyL:=INTEGER(LONG(key));
   P:= ADR(Seite);
   IF (KeyL # MaxKeyLen) THEN 
    FOR I := Seite.ItemsOnPage TO 1 BY -1 DO
     Move(ADR(P^[(I - 1) * (KeyL + ItemOverhead) + PageOverhead]),
          ADR(Seite.ItemArray[I]),
          KeyL + ItemOverhead);
    END(*FOR*);
   END(*IF*);
  END UnpackPage; 


 PROCEDURE IndexMake(VAR Index : IdxFile; FName: ARRAY OF CHAR; 
                         key   : BYTE;    Typ  : IndexType);

  VAR SeitenGroesze,
      KeyLen        : INTEGER;       
      IndexPtr      : IndexStack; 
      
  BEGIN 
   KeyLen:=INTEGER(LONG(key));
   IF (KeyLen > MaxKeyLen) THEN          (* SchlÅssel zu lang ? *)
    ErrorCode := KeyTooLargeError;
    RETURN;
   END(*IF*);
   Clear(ADR(Index),SIZE(Index));
   SeitenGroesze := (KeyLen + ItemOverhead) * PageSize + PageOverhead;
   Create(Index.DataF.DosDatei, FName, readWrite, noReplace);
   ErrorCode := State(Index.DataF.DosDatei);
   IF (ErrorCode # 0) THEN
    RETURN;
   END(*IF*);
   Index.Typ := Typ;
   Index.KeyL := key;
   CreateHeader(Index.DataF, SeitenGroesze, 0);
   IF (ErrorCode # 0) THEN
    Close(Index.DataF.DosDatei);
    RETURN;
   END(*IF*);
   NEW(IndexPtr);
   IndexPtr^.Vorg := IndexStapel;
   IndexPtr^.IndexPtr := ADR(Index);
   IndexStapel := IndexPtr;
  END IndexMake; 


 PROCEDURE IndexOpen(VAR Index : IdxFile; FName:  ARRAY OF CHAR;
                         key   : BYTE;    Typ  :  IndexType);

  VAR SeitenGroesze,
      KeyLen        : INTEGER;  
      IndexPtr      : IndexStack; 

  BEGIN 
   KeyLen:=INTEGER(LONG(key));
   IF (KeyLen > MaxKeyLen) THEN 
    ErrorCode := KeyTooLargeError;
    RETURN;
   END(*IF*);
   Clear(ADR(Index),SIZE(Index));
   SeitenGroesze := (KeyLen + ItemOverhead) * PageSize + PageOverhead;
   Open(Index.DataF.DosDatei,FName,readWrite);
   ErrorCode := State(Index.DataF.DosDatei);
   IF (ErrorCode # 0) THEN 
    RETURN;
   END(*IF*);
   ReadHeader(Index.DataF, 0);
   IF (ErrorCode # 0) THEN
    Close(Index.DataF.DosDatei);
    RETURN;
   END(*IF*);
   IF (SeitenGroesze # INTEGER(Index.DataF.ItemSize)) THEN  (* falsche SchlÅsselgrî·e? *)
    Close(Index.DataF.DosDatei);
    ErrorCode := KeySizeMismatchError;
    RETURN;
   END(*IF*);
   IF Index.DataF.Integritaet # True THEN         (* Datei nicht geschlossen? *)
    ErrorCode := fCRCError;
   END(*IF*);
   Index.Typ := Typ;
   Index.KeyL := key;
   Index.WurzelDsNr := Index.DataF.Int1;
   Index.SeitenDsNr := 0;
   NEW(IndexPtr);
   IndexPtr^.Vorg := IndexStapel;
   IndexPtr^.IndexPtr := ADR(Index);
   IndexStapel := IndexPtr;
  END IndexOpen; 


 PROCEDURE StoreIndexHeader(VAR Index: IdxFile);
  VAR I: INTEGER;

  BEGIN
   FOR I := 1 TO PageStackSize DO
    WITH TaPageStk^[I]^ DO
     IF IndexFPtr = ADR(Index) THEN
      IndexFPtr := NIL;
      IF Updated=True THEN
       PackPage(Seite,Index.KeyL);
       FixPut(Index.DataF,PageRef,Seite);
       IF (ErrorCode # 0) THEN 
        RETURN;
       END(*IF*);
       Updated := False;
      END(*IF*);
     END(*IF*);
    END(*WITH*);
   END(*FOR*);
   Index.DataF.Int1 := Index.WurzelDsNr;
  END StoreIndexHeader; 


 PROCEDURE CloseInternIndex(VAR Index : IdxFile);

  BEGIN
   StoreIndexHeader(Index);
   IF (ErrorCode = 0) THEN
    CloseInternFile(Index.DataF);
   END(*IF*);
  END CloseInternIndex;


 PROCEDURE IndexClose(VAR Index : IdxFile);
  VAR StapelPtr, NachfPtr: IndexStack;

  BEGIN
   NachfPtr := NIL; 
   StapelPtr := IndexStapel;
   WHILE (StapelPtr # NIL) AND (StapelPtr^.IndexPtr # ADR(Index)) DO 
    NachfPtr := StapelPtr;
    StapelPtr := StapelPtr^.Vorg;
   END(*WHILE*);
   IF (StapelPtr # NIL) AND (StapelPtr^.IndexPtr = ADR(Index)) THEN
    IF (NachfPtr # NIL) THEN
     NachfPtr^.Vorg := StapelPtr^.Vorg
    ELSE
     IndexStapel := StapelPtr^.Vorg;
    END(*IF*);
    DISPOSE(StapelPtr);
    CloseInternIndex(Index);
   ELSE                                   (* Index war nicht vorhanden *)
    ErrorCode := fFileNotFound;
(*    Write(#7);*)
   END(*IF*);
  END IndexClose;


 PROCEDURE IndexFlush(VAR Index: IdxFile);

  BEGIN
   StoreIndexHeader(Index);
   IF (ErrorCode = 0) THEN
    FixFlush(Index.DataF);
   END(*IF*);
  END IndexFlush; 


 PROCEDURE IndexErase(VAR Index : IdxFile);
  VAR name: ARRAY [0..137] OF CHAR;
  
  BEGIN
   GetFileName(Index.DataF.DosDatei,name); 
   CloseInternIndex(Index);
   IF (ErrorCode = 0) THEN
    Delete(name,ErrorCode);
   END(*IF*);
  END IndexErase; 


 PROCEDURE TaLast(i : CARDINAL);
  VAR j: INTEGER;

  BEGIN
   j:= 1;
   WHILE (TaPgMap^[j] # i) AND (j < PageStackSize) DO
    INC(j);
   END(*WHILE*);
   IF j < PageStackSize THEN
    Move(ADR(TaPgMap^[j+1]), ADR(TaPgMap^[j]), 
                             (PageStackSize - j) * SIZE(TaPgMap^[1]) );
   END(*IF*);
   TaPgMap^[PageStackSize] := i;
  END TaLast; 


 PROCEDURE GetPage(VAR Index: IdxFile; R: LONGINT; VAR PgPtr : PagePtr);
  VAR I     : INTEGER;
      Found : BOOLEAN;

  BEGIN
   ErrorCode := 0;
   I := 0;
   REPEAT 
    INC(I);
    WITH TaPageStk^[I]^ DO
     Found := (IndexFPtr = ADR(Index)) AND (PageRef = R);
    END(*WITH*);
   UNTIL Found OR (I = PageStackSize);
   IF ~(Found) THEN 
    I := TaPgMap^[1];
    WITH TaPageStk^[I]^ DO 
     IF Updated=True THEN 
      PackPage(Seite, IndexFPtr^.KeyL);
      FixPut(IndexFPtr^.DataF, PageRef, Seite);
      IF (ErrorCode # 0) THEN 
       RETURN;
      END(*IF*);
     END(*IF*);
     FixGet(Index.DataF, R, Seite, 1);
     IF (ErrorCode # 0) THEN 
      RETURN;
     END(*IF*);
     UnpackPage(Seite, Index.KeyL);
     IndexFPtr := ADR(Index);
     PageRef := R;
     Updated := False;
    END(*WITH*);
   END(*IF*);
   TaLast(I);
   PgPtr := ADR(TaPageStk^[I]^);
  END GetPage; 


 PROCEDURE NewPage(VAR Index: IdxFile; VAR R: LONGINT; VAR PgPtr: PagePtr);
  VAR I: INTEGER;

  BEGIN
   I := TaPgMap^[1];
   WITH TaPageStk^[I]^ DO 
    IF Updated=True THEN 
     PackPage(Seite, IndexFPtr^.KeyL);
     FixPut(IndexFPtr^.DataF, PageRef, Seite);
     IF (ErrorCode # 0) THEN 
      RETURN;
     END(*IF*);
    END(*IF*);
    FixNew(Index.DataF, R);
    IF (ErrorCode # 0) THEN 
     RETURN;
    END(*IF*);
    IndexFPtr := ADR(Index);
    PageRef := R;
    Updated := False;
   END(*WITH*);;
   TaLast(I);
   PgPtr := ADR(TaPageStk^[I]^);
  END NewPage; 


 PROCEDURE UpdatePage(PgPtr: PagePtr);
  VAR  f:TaStackRecPtr;
      
  BEGIN
   f:=ADR(PgPtr^);
   f^.Updated := True;
   FileUpdated(f^.IndexFPtr^.DataF);
  END UpdatePage;


 PROCEDURE ReturnPage(VAR PgPtr : PagePtr);
  VAR f:TaStackRecPtr;
     
  BEGIN
   f:=ADR(PgPtr^);
   WITH f^ DO
    FixDel(IndexFPtr^.DataF,PageRef);
    IndexFPtr := NIL;
    Updated := False;
   END(*WITH*);
  END ReturnPage;
  

 PROCEDURE AdjustKey(VAR K: ARRAY OF CHAR;  KeyL : BYTE);
  VAR i,key: CARDINAL; 
      h    : IsamKeyStr;
  
  BEGIN
   key:=CARDINAL(LONG(KeyL));         (* String auf KeyLen bringen *)
   IF LENGTH(K) > key THEN
    Clear(ADR(h),SIZE(h));
    Copy(K,0,key,h,ok);
    Assign(h,K,ok);  
   END(*IF*);   
  END AdjustKey; 

 PROCEDURE TaCompKeys(VAR K1,K2: ARRAY OF CHAR; DR1,DR2: LONGINT; 
                                                 Dup: IndexType): LONGINT;

  BEGIN 
   IF StrEqual(K1,K2) THEN
    IF (Dup = Dups) THEN
     RETURN (DR1 - DR2);
    ELSE
     RETURN 0;                   
    END(*IF*);
   ELSE
    IF Compare(K1,K2) = greater THEN  
     RETURN 1
    ELSE  
     RETURN - 1;
    END(*IF*);
   END(*IF*)
  END TaCompKeys;
  

 PROCEDURE IndexReset(VAR Index : IdxFile);

  BEGIN
   Index.SeitenDsNr := 0;
  END IndexReset;


 PROCEDURE IndexNext(VAR Index  : IdxFile; VAR DataRecNum : LONGINT;
                     VAR ProcKey: ARRAY OF CHAR);

  VAR R      : LONGINT;
      PagPtr : PagePtr;

  BEGIN
   ErrorCode := 0;
   WITH Index DO 
    IF (SeitenDsNr = 0) THEN
     R := WurzelDsNr
    ELSE 
     WITH Pfad[SHORT(SeitenDsNr)] DO 
      GetPage(Index, PageRef, PagPtr);
      IF (ErrorCode # 0) THEN 
       RETURN;
      END(*IF*);
      R := PagPtr^.ItemArray[SHORT(ItemArrIndex)].PageRef;
     END(*WITH*);
    END(*IF*);
    WHILE (R # 0) DO 
     INC(SeitenDsNr);
     WITH Pfad[SHORT(SeitenDsNr)] DO 
      PageRef := R;
      ItemArrIndex := 0;
     END(*WITH*);
     GetPage(Index,R,PagPtr);
     IF (ErrorCode # 0) THEN 
      RETURN;
     END(*IF*);
     R := PagPtr^.BckwPageRef;
    END(*WHILE*);
    IF (SeitenDsNr # 0) THEN
     WHILE (SeitenDsNr > 1) AND
           (Pfad[SHORT(SeitenDsNr)].ItemArrIndex = LONG(PagPtr^.ItemsOnPage)) DO
      DEC(SeitenDsNr);
      GetPage(Index, Pfad[SHORT(SeitenDsNr)].PageRef, PagPtr);
      IF (ErrorCode # 0) THEN
       RETURN;
      END(*IF*);
     END(*WHILE*);
     IF (Pfad[SHORT(SeitenDsNr)].ItemArrIndex < LONG(PagPtr^.ItemsOnPage)) THEN
      WITH Pfad[SHORT(SeitenDsNr)] DO 
       INC(ItemArrIndex);
       WITH PagPtr^.ItemArray[SHORT(ItemArrIndex)] DO 
        Assign(Key,ProcKey,ok);
        DataRecNum := DataRef;
       END(*WITH*);
      END(*WITH*);
     ELSE 
      SeitenDsNr := 0;
     END(*IF*);
    END(*IF*);
    IF (SeitenDsNr # 0) THEN 
     ErrorCode := 0;
    ELSE 
     ErrorCode := fNoMoreFiles;
    END(*IF*);
   END(*WITH*);
  END IndexNext; 

 PROCEDURE IndexPrev(VAR Index  : IdxFile; VAR DataRecNum : LONGINT;
                     VAR ProcKey: ARRAY OF CHAR);

  VAR R      : LONGINT;
      PagPtr : PagePtr;

  BEGIN
   ErrorCode := 0;
   WITH Index DO
    IF (SeitenDsNr = 0) THEN
     R := WurzelDsNr
    ELSE 
     WITH Pfad[SHORT(SeitenDsNr)] DO 
      GetPage(Index, PageRef, PagPtr);
      IF (ErrorCode # 0) THEN 
       RETURN;
      END(*IF*);
      DEC(ItemArrIndex);
      IF (ItemArrIndex = 0) THEN
       R := PagPtr^.BckwPageRef
      ELSE 
       R := PagPtr^.ItemArray[SHORT(ItemArrIndex)].PageRef;
      END(*IF*);
     END(*WITH*);
    END(*IF*);
    WHILE (R # 0) DO 
     GetPage(Index, R, PagPtr);
     IF (ErrorCode # 0) THEN 
      RETURN;
     END(*IF*);
     INC(SeitenDsNr);
     WITH Pfad[SHORT(SeitenDsNr)] DO 
      PageRef := R;
      ItemArrIndex := PagPtr^.ItemsOnPage;
     END(*WITH*);
     WITH PagPtr^ DO
      R := ItemArray[ItemsOnPage].PageRef;
     END(*WITH*);
    END(*WHILE*);
    IF (SeitenDsNr # 0) THEN
     WHILE (SeitenDsNr > 1) AND (Pfad[SHORT(SeitenDsNr)].ItemArrIndex = 0) DO 
      DEC(SeitenDsNr);
      GetPage(Index,Pfad[SHORT(SeitenDsNr)].PageRef,PagPtr);
      IF (ErrorCode # 0) THEN
       RETURN;
      END(*IF*);
     END(*WHILE*);
     IF (Pfad[SHORT(SeitenDsNr)].ItemArrIndex > 0) THEN
      WITH PagPtr^.ItemArray[SHORT(Pfad[SHORT(SeitenDsNr)].ItemArrIndex)] DO 
       Assign(Key,ProcKey,ok);
       DataRecNum := DataRef;
      END(*WITH*);
     ELSE 
      SeitenDsNr := 0;
     END(*IF*);
    END(*IF*);
    IF (SeitenDsNr # 0) THEN
     ErrorCode := 0
    ELSE 
     ErrorCode := fNoMoreFiles;
    END(*IF*);
   END(*WITH*);
  END IndexPrev; 

 PROCEDURE FindIntern(VAR Index  : IdxFile; VAR DataRecNum : LONGINT;
                      VAR ProcKey: ARRAY OF CHAR);

      (* Sucht nach der exakten Position von ProcKey (bei Dups: + DataRecNum). *)
      (* Positioniert ggf. auf virtuellen Zwischenpositionen.      *)
      (* Setzt ErrorCode = 0 nur wenn exakt gefunden, sonst auf fNotFound *)
      
  VAR PrPgRef  : LONGINT;
      C        : LONGINT;
      K, L, R  : INTEGER;
      RKey     : IsamKeyStr;
      PagPtr   : PagePtr;
      MatchRef : LONGINT;

  BEGIN
   MatchRef := DataRecNum;
   WITH Index DO 
    AdjustKey(ProcKey, KeyL);
    ok := FALSE; 
    ErrorCode := fFileNotFound;
    SeitenDsNr := 0;
    PrPgRef := WurzelDsNr;
    WHILE (PrPgRef # 0) AND ~(ok) DO 
     INC(SeitenDsNr);
     Pfad[SHORT(SeitenDsNr)].PageRef := PrPgRef;
     GetPage(Index, PrPgRef, PagPtr);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     WITH PagPtr^ DO 
      L := 1;
      R := ItemsOnPage;
      REPEAT 
       K := (L + R) DIV 2;
       C := TaCompKeys(ProcKey,ItemArray[K].Key,MatchRef,
                       ItemArray[K].DataRef,Typ);
       IF (C <= 0) THEN
        R := K - 1;
       END(*IF*);
       IF (C >= 0) THEN
        L := K + 1;
       END(*IF*);
      UNTIL (R < L);
      IF (L - R > 1) THEN
       DataRecNum := ItemArray[K].DataRef;
       R := K;
       ok:= TRUE; 
       ErrorCode := 0;
      END(*IF*);
      IF (R = 0) THEN
       PrPgRef := BckwPageRef
      ELSE 
       PrPgRef := ItemArray[R].PageRef;
      END(*IF*);
     END(*WITH*);
     Pfad[SHORT(SeitenDsNr)].ItemArrIndex := R;
    END(*WHILE*);
    IF ~(ok) AND (SeitenDsNr > 0) THEN
     WHILE (SeitenDsNr > 1) AND (Pfad[SHORT(SeitenDsNr)].ItemArrIndex = 0) DO
      DEC(SeitenDsNr);
     END(*WHILE*);
     IF (Pfad[SHORT(SeitenDsNr)].ItemArrIndex = 0) THEN
      SeitenDsNr := 0;
     END(*IF*);
    END(*IF*);
   END(*WITH*);
   IF ~(ok) AND (ErrorCode = 0) THEN
    ErrorCode := fFileNotFound;
   END(*IF*);
(*   WriteLn;
   WriteInt(ErrorCode);
   WriteString('FInt');
   WriteLn;    *)
  END FindIntern; 
 

 PROCEDURE IndexFind(VAR Index  : IdxFile; VAR DataRecNum: LONGINT;
                         ProcKey: IsamKeyStr);

  VAR TempKey: IsamKeyStr;

  BEGIN
   DataRecNum := 0;
   FindIntern(Index, DataRecNum, ProcKey);
   IF (ErrorCode = fFileNotFound) AND (Index.Typ = Dups) THEN
    Assign(ProcKey,TempKey,ok);
    IndexNext(Index, DataRecNum, ProcKey);
    IF (ErrorCode = 0) AND (StrEqual(ProcKey,TempKey)) THEN
     ErrorCode := 0
    ELSE 
     ErrorCode := fFileNotFound;
    END(*IF*);
   END(*IF*);
  END IndexFind; 

 PROCEDURE IndexRefind(VAR Index  : IdxFile; DataRecNum: LONGINT;
                           ProcKey: IsamKeyStr);

  VAR TempKey: IsamKeyStr;

  BEGIN
   FindIntern(Index, DataRecNum, ProcKey);
   IF (ErrorCode = fFileNotFound) AND (Index.Typ = Dups) THEN
    Assign(ProcKey,TempKey,ok);
    IndexNext(Index, DataRecNum, ProcKey);
    IF (ErrorCode = 0) AND (StrEqual(ProcKey,TempKey)) THEN
     ErrorCode := 0
    ELSE 
     ErrorCode := fFileNotFound;
    END(*IF*);
   END(*IF*);
  END IndexRefind;


 PROCEDURE IndexSearch(VAR Index  : IdxFile; VAR DataRecNum: LONGINT;
                       VAR ProcKey: ARRAY OF CHAR);

  BEGIN
   DataRecNum := 0;
   FindIntern(Index, DataRecNum, ProcKey);
   IF (ErrorCode # 0) THEN
    IndexNext(Index, DataRecNum, ProcKey);
    IF (ErrorCode = fNoMoreFiles) THEN
     ErrorCode := fFileNotFound;
    END(*IF*);
   END(*IF*);
  END IndexSearch; 


 PROCEDURE IndexAdd(VAR Index  : IdxFile; DataRecNum: LONGINT;
                        ProcKey: ARRAY OF CHAR);

  VAR PrPgRef1,
      PrPgRef2, 
      Differenz : LONGINT;
      I,Mitte,
      Links     : INTEGER;
      PassUp    : BOOLEAN;
      PagePtr1,
      PagePtr2  : PagePtr;
      ProcItem1,
      ProcItem2 : Item;

  PROCEDURE Search(PrPgRef1 : LONGINT);
   VAR Rechts: INTEGER;

   PROCEDURE Insert;
    VAR i : INTEGER;

    BEGIN   (* Insert *)
     GetPage(Index, PrPgRef1, PagePtr1);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     WITH PagePtr1^ DO 
      IF (ItemsOnPage < PageSize) THEN
       ItemsOnPage := ItemsOnPage + 1;
       FOR i := ItemsOnPage TO Rechts + 2 BY -1 DO
        ItemArray[i] := ItemArray[i - 1];
       END(*FOR*);
       ItemArray[Rechts + 1] := ProcItem1;
       PassUp := FALSE;
      ELSE 
       NewPage(Index, PrPgRef2, PagePtr2);
       IF (ErrorCode # 0) THEN
        RETURN;
       END(*IF*);
       IF (Rechts <= Order) THEN
        IF (Rechts = Order) THEN
         ProcItem2 := ProcItem1
        ELSE 
         ProcItem2 := ItemArray[Order];
         FOR i := Order TO Rechts + 2 BY -1 DO
          ItemArray[i] := ItemArray[i - 1];
         END(*FOR*);
         ItemArray[Rechts + 1] := ProcItem1;
        END(*IF*);
        FOR i:= 1 TO Order DO
         PagePtr2^.ItemArray[i] := ItemArray[i + Order];
        END(*FOR*);
       ELSE 
        DEC(Rechts, Order);
        ProcItem2 := ItemArray[Order + 1];
        FOR i := 1 TO Rechts - 1 DO
         PagePtr2^.ItemArray[i] := ItemArray[i + Order + 1];
        END(*FOR*);
        PagePtr2^.ItemArray[Rechts] := ProcItem1;
        FOR i := Rechts + 1 TO Order DO
         PagePtr2^.ItemArray[i] := ItemArray[i + Order];
        END(*FOR*);
       END(*IF*);
       ItemsOnPage := Order;
       PagePtr2^.ItemsOnPage := Order;
       PagePtr2^.BckwPageRef := ProcItem2.PageRef;
       ProcItem2.PageRef := PrPgRef2;
       ProcItem1 := ProcItem2;
       UpdatePage(PagePtr2);
      END(*IF*);
     END;
     UpdatePage(PagePtr1);
    END Insert;

   BEGIN    (* Search *)
    IF (PrPgRef1 = 0) THEN
     PassUp := TRUE;
     WITH ProcItem1 DO 
      Assign(ProcKey,Key,ok);
      DataRef := DataRecNum;
      PageRef := 0;
     END(*WITH*);;
    ELSE 
     GetPage(Index, PrPgRef1, PagePtr1);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     WITH PagePtr1^ DO 
      Links := 1;
      Rechts := ItemsOnPage;
      REPEAT 
       Mitte := (Links + Rechts) DIV 2;
       Differenz := TaCompKeys(ProcKey,ItemArray[Mitte].Key,DataRecNum,
                               ItemArray[Mitte].DataRef,Index.Typ);
       IF (Differenz <= 0) THEN
        Rechts := Mitte - 1;
       END(*IF*);
       IF (Differenz >= 0) THEN
        Links := Mitte + 1;
       END(*IF*);
      UNTIL (Rechts < Links);
      IF (Links - Rechts > 1) THEN
       ok := FALSE;
       PassUp := FALSE;
      ELSE 
       IF (Rechts = 0) THEN
        Search(BckwPageRef)
       ELSE 
        Search(ItemArray[Rechts].PageRef);
       END(*IF*);
       IF (ErrorCode # 0) THEN
        RETURN;
       END(*IF*);
       IF PassUp THEN
        Insert;
       END(*IF*);
      END(*IF*);
     END(*WITH*);
    END(*IF*);
   END Search;


  BEGIN    (* IndexAdd *)
   ErrorCode := 0;
   WITH Index DO 
    AdjustKey(ProcKey, KeyL);
    ok := TRUE;
    Search(WurzelDsNr);
    IF (ErrorCode # 0) THEN
     RETURN;
    END(*IF*);
    IF PassUp THEN
     PrPgRef1 := WurzelDsNr;
     NewPage(Index, WurzelDsNr, PagePtr1);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     WITH PagePtr1^ DO 
      ItemsOnPage := 1;
      BckwPageRef := PrPgRef1;
      ItemArray[1] := ProcItem1;
     END(*WITH*);
     UpdatePage(PagePtr1);
    END(*IF*);
    SeitenDsNr := 0;
   END(*WITH*);
   IF (ErrorCode = 0) AND ~(ok) THEN
    ErrorCode := fFileExists;
   END(*IF*);
  END IndexAdd; 


 PROCEDURE IndexDel(VAR Index  : IdxFile; DataRecNum : LONGINT;
                        ProcKey: ARRAY OF CHAR);

  VAR PageTooSmall : BOOLEAN;
      PagPtr       : PagePtr;

  PROCEDURE DelB(PrPgRef : LONGINT);
   VAR C,I,K,L,R,
       XPageRef  : LONGINT;
       PagPtr    : PagePtr;

   PROCEDURE UnderFlow(PrPgRef,PrPgRef2 : LONGINT; R: LONGINT);
    VAR I, K,
        LItem    : INTEGER;
        LPageRef : LONGINT;
        PagPtr,
        PagePtr2,
        L        : PagePtr;

    BEGIN
     GetPage(Index, PrPgRef, PagPtr);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     GetPage(Index, PrPgRef2, PagePtr2);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     IF (R < LONG(PagPtr^.ItemsOnPage)) THEN
      R := R + 1;
      LPageRef := PagPtr^.ItemArray[SHORT(R)].PageRef;
      GetPage(Index,LPageRef,L);
      IF (ErrorCode # 0) THEN
       RETURN;
      END(*IF*);
      K := (L^.ItemsOnPage - Order + 1) DIV 2;
      PagePtr2^.ItemArray[Order] := PagPtr^.ItemArray[SHORT(R)];
      PagePtr2^.ItemArray[Order].PageRef := L^.BckwPageRef;
      IF (K > 0) THEN
       FOR I := 1 TO K - 1 DO
        PagePtr2^.ItemArray[I + Order] := L^.ItemArray[I];
       END(*FOR*);
       PagPtr^.ItemArray[SHORT(R)] := L^.ItemArray[K];
       PagPtr^.ItemArray[SHORT(R)].PageRef := LPageRef;
       L^.BckwPageRef := L^.ItemArray[K].PageRef;
       L^.ItemsOnPage := L^.ItemsOnPage - K;         
       FOR I := 1 TO L^.ItemsOnPage DO
        L^.ItemArray[I] := L^.ItemArray[I + K];       
       END(*FOR*);
       PagePtr2^.ItemsOnPage := Order - 1 + K;
       PageTooSmall := FALSE;
       UpdatePage(L);
      ELSE 
       FOR I := 1 TO Order DO
        PagePtr2^.ItemArray[I + Order] := L^.ItemArray[I];
       END(*FOR*);
       FOR I := SHORT(R) TO PagPtr^.ItemsOnPage - 1 DO
        PagPtr^.ItemArray[I] := PagPtr^.ItemArray[I + 1];
       END(*FOR*);
       PagePtr2^.ItemsOnPage := PageSize;
       PagPtr^.ItemsOnPage := PagPtr^.ItemsOnPage - 1;
       ReturnPage(L);
       PageTooSmall := PagPtr^.ItemsOnPage < Order;
      END(*IF*);
      UpdatePage(PagePtr2);
     ELSE 
      IF (R = 1) THEN
       LPageRef := PagPtr^.BckwPageRef
      ELSE 
       LPageRef := PagPtr^.ItemArray[SHORT(R) - 1].PageRef;
      END(*IF*);
      GetPage(Index,LPageRef,L);
      IF (ErrorCode # 0) THEN
       RETURN;
      END(*IF*);
      LItem := L^.ItemsOnPage + 1;
      K := (LItem - Order) DIV 2;
      IF (K > 0) THEN
       FOR I := Order - 1 TO 1 BY -1 DO
        PagePtr2^.ItemArray[I + K] := PagePtr2^.ItemArray[I];
       END(*FOR*);
       PagePtr2^.ItemArray[K] := PagPtr^.ItemArray[SHORT(R)];
       PagePtr2^.ItemArray[K].PageRef := PagePtr2^.BckwPageRef;
       LItem := LItem - K;
       FOR I := K - 1 TO 1 BY -1 DO
        PagePtr2^.ItemArray[I] := L^.ItemArray[I + LItem];
       END(*FOR*);
       PagePtr2^.BckwPageRef := L^.ItemArray[LItem].PageRef;
       PagPtr^.ItemArray[SHORT(R)] := L^.ItemArray[LItem];
       PagPtr^.ItemArray[SHORT(R)].PageRef := PrPgRef2;
       L^.ItemsOnPage := LItem - 1;
       PagePtr2^.ItemsOnPage := Order - 1 + K;
       PageTooSmall := FALSE;
       UpdatePage(PagePtr2);
      ELSE 
       L^.ItemArray[LItem] := PagPtr^.ItemArray[SHORT(R)];
       L^.ItemArray[LItem].PageRef := PagePtr2^.BckwPageRef;
       FOR I := 1 TO Order - 1 DO
        L^.ItemArray[I + LItem] := PagePtr2^.ItemArray[I];
       END(*FOR*);
       L^.ItemsOnPage := PageSize;
       PagPtr^.ItemsOnPage := PagPtr^.ItemsOnPage - 1;
       ReturnPage(PagePtr2);
       IF (ErrorCode # 0) THEN
        RETURN;
       END(*IF*);
       PageTooSmall := PagPtr^.ItemsOnPage < Order;
      END(*IF*);
      UpdatePage(L);
     END(*IF*);
     UpdatePage(PagPtr);
    END UnderFlow;

   PROCEDURE DelA(PrPgRef2: LONGINT);
    VAR C        : LONGINT;
        XPageRef : LONGINT;
        PagePtr2 : PagePtr;

    BEGIN
     GetPage(Index, PrPgRef2, PagePtr2);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     WITH PagePtr2^ DO 
      XPageRef := ItemArray[ItemsOnPage].PageRef;
      IF (XPageRef # 0) THEN
       C := ItemsOnPage;
       DelA(XPageRef);
       IF (ErrorCode # 0) THEN
        RETURN;
       END(*IF*);
       IF PageTooSmall THEN
        UnderFlow(PrPgRef2, XPageRef, C);
        IF (ErrorCode # 0) THEN
         RETURN;
        END(*IF*);
       END(*IF*);
      ELSE 
       GetPage(Index, PrPgRef, PagPtr);
       IF (ErrorCode # 0) THEN
        RETURN;
       END(*IF*);
       ItemArray[ItemsOnPage].PageRef := PagPtr^.ItemArray[SHORT(K)].PageRef;
       PagPtr^.ItemArray[SHORT(K)] := ItemArray[ItemsOnPage];
       ItemsOnPage := ItemsOnPage - 1;
       PageTooSmall := ItemsOnPage < Order;
       UpdatePage(PagPtr);
       UpdatePage(PagePtr2);
      END(*IF*);
     END(*WITH*);
    END DelA;

   BEGIN        (* DelB *)
    IF (PrPgRef = 0) THEN
     ok:= FALSE;
     PageTooSmall := FALSE;
    ELSE 
     GetPage(Index, PrPgRef, PagPtr);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     WITH PagPtr^ DO 
      L := 1;
      R := ItemsOnPage;
      REPEAT 
       K := (L + R) DIV 2;
       C := TaCompKeys(ProcKey,ItemArray[SHORT(K)].Key,DataRecNum,
                       ItemArray[SHORT(K)].DataRef,Index.Typ);
       IF (C <= 0) THEN
        R := K - 1;
       END(*IF*);
       IF (C >= 0) THEN
        L := K + 1;
       END(*IF*);
      UNTIL (L > R);
      IF (R = 0) THEN
       XPageRef := BckwPageRef
      ELSE 
       XPageRef := ItemArray[SHORT(R)].PageRef;
      END(*IF*);
      IF (L - R > 1) THEN
       DataRecNum := ItemArray[SHORT(K)].DataRef;
       IF (XPageRef = 0) THEN
        ItemsOnPage := ItemsOnPage - 1;
        PageTooSmall := ItemsOnPage < Order;
        FOR I := K TO LONG(ItemsOnPage) DO
         ItemArray[SHORT(I)] := ItemArray[SHORT(I) + 1];
        END(*FOR*);
        UpdatePage(PagPtr);
       ELSE 
        DelA(XPageRef);
        IF (ErrorCode # 0) THEN
         RETURN;
        END(*IF*);
        IF PageTooSmall THEN
         UnderFlow(PrPgRef, XPageRef, R);
         IF (ErrorCode # 0) THEN
          RETURN;
         END(*IF*);
        END(*IF*);
       END(*IF*);
      ELSE 
       DelB(XPageRef);
       IF (ErrorCode # 0) THEN
        RETURN;
       END(*IF*);
       IF PageTooSmall THEN
        UnderFlow(PrPgRef, XPageRef, R);
        IF (ErrorCode # 0) THEN 
         RETURN;
        END(*IF*);
       END(*IF*);
      END(*IF*);
     END(*WITH*);
    END(*IF*);
   END DelB;

  BEGIN      (* IndexDel *)
   ErrorCode := 0;
   WITH Index DO 
    AdjustKey(ProcKey, KeyL);
    ok:= TRUE;
    DelB(WurzelDsNr);
    IF PageTooSmall THEN
     GetPage(Index, WurzelDsNr, PagPtr);
     IF (ErrorCode # 0) THEN
      RETURN;
     END(*IF*);
     IF (PagPtr^.ItemsOnPage = 0) THEN
      WurzelDsNr := PagPtr^.BckwPageRef;
      ReturnPage(PagPtr);
      IF (ErrorCode # 0) THEN
       RETURN;
      END(*IF*);
     END(*IF*);
    END(*IF*);
    SeitenDsNr := 0;
   END(*WITH*);
   IF (ErrorCode = 0) AND ~(ok) THEN 
    ErrorCode := fFileNotFound;
   END(*IF*);
  END IndexDel;


 PROCEDURE InitPages;
                           (* Allocate for stack, pagemap, record, buffer. *)
  VAR i: INTEGER;

  BEGIN
   IF (MemAvail() < (TSIZE(TaRecordBuffer) + TSIZE(TaPageMap) +
                   TSIZE(TaPageStack) + 
                   PageStackSize * TSIZE(TaStackRecPtr))) THEN
    TermProcess(fInsufficientMemory);
   END(*IF*);
   NEW(TaPageStk);
   NEW(TaPgMap);
   FOR i := 1 TO PageStackSize DO 
    TaPgMap^[i] := i;
    NEW(TaPageStk^[i]);
(*    FillChar(TaPageStk^[i]^, SizeOf(TaStackRec), 0); *)
Clear(TaPageStk^[i],TSIZE(TaStackRec));
   END(*FOR*);
   NEW(TaRecBuf);
  END InitPages;

 PROCEDURE ExitIsam;

  BEGIN 
(*   WHILE (IndexStapel # NIL) DO
    Close(IndexStapel^.IndexPtr^);
   END(*WHILE*);
   ExitProc := ExitProcSave; *)
  END ExitIsam;


 BEGIN
  InitPages;
  IndexStapel := NIL;
(*  ExitProcSave := ExitProc;
  ExitProc := ADR(ExitIsam);   *)
 END IndexFiles.

IMPLEMENTATION MODULE FixFiles;

(*                             Von Michael H.                               *)
(*  portiert nach M-2 August '91 von Christian Felsch und Peter Oleski.     *)       
(*  Diese ISAM ist Public Domain und darf von jedem fr zivile Aufgaben     *)
(*  benutzt werden. Eine Nutzung fr milit„rische Zwecke ist untersagt !    *)
(*                         Diese ISAM ist Peace-Ware !                      *)
(*                         ---------------------------                      *)
(*  Diese ISAM darf ver„ndert und erweitert werden. Bei guten Erweiterungen *)
(*  und Fehlern benachrichtigung bitte an uns senden.                       *)
(*  Die ISAM hat unsere Platte NICHT zerst”rt aber wir bernehmen keine     *)
(*  Verantwortung fr nichts.                                               *)
(*  Wir bitten aber, falls diese ISAM einmal eine Verwendung findet, uns    *)
(*  mit dem Satz ' ISAM by Jau-Team ' zu erw„hnen.                          *)
(*  Wird mit dieser Bibliothek ein kommerzielles Programm erstellt, so ist  *)
(*  uns ein kostenloses Exemplar zuzusenden                                 *)
(*  Zu erreichen unter:                                                     *)
(*                                                                          *)
(*      E-Mail: Peter Oleski        oder   Christian Felsch @ HH (MausNet)  *)
(*  gelbe Post: Eižendorfergrenzweg 83a     Bevenser Weg 18                 *)
(*                             2100 Hamburg 90                              *)



 FROM IsamGlobals IMPORT MaxDataRecSize, MinDataRecSize, RecTooSmallError, 
                         RecTooLargeError, RecSizeMismatchError, ErrorCode,
                         FixFile, TaRecBuf, True, False,
                         PutHeader, FileUpdated, CreateHeader,
                         ReadHeader, CloseInternFile, Move;
 FROM Files       IMPORT Create, Open, ReplaceMode, Access, Flush, State, 
                         Close, GetFileName;
 FROM Binary      IMPORT WriteBytes, ReadBytes, Seek, SeekMode;
 FROM SYSTEM      IMPORT LOC, CAST, ADR, TSIZE;
 FROM Storage     IMPORT ALLOCATE, DEALLOCATE;
 FROM MOSGlobals  IMPORT fCRCError, fInvalidHandle;
 FROM Directory   IMPORT Delete, Rename;  
 FROM Block       IMPORT Clear;


 TYPE FileStack = POINTER TO FileEntry;
      FileEntry = RECORD 
                   Vorg    : FileStack;
                   DateiPtr: POINTER TO FixFile;
                  END(*RECORD*);
                  

 VAR  DateiStapel: FileStack;


 PROCEDURE FixFlush(VAR Datei: FixFile);

  BEGIN 
   Datei.Integritaet := True;
   PutHeader(Datei);
   IF (ErrorCode = 0) THEN 
    Flush(Datei.DosDatei);
   END(*IF*); 
  END FixFlush;


 PROCEDURE FixGet(VAR Datei : FixFile;      SatzNr  : LONGINT;
                  VAR Buffer: ARRAY OF LOC; Anz     : CARDINAL);
  VAR d : LONGCARD;
       
  BEGIN
   Seek(Datei.DosDatei, LONGINT(LONG(Datei.ItemSize)) * SatzNr,fromBegin);
   ErrorCode := State(Datei.DosDatei);
   IF (ErrorCode = 0) THEN 
    ReadBytes(Datei.DosDatei, ADR(Buffer), Anz * Datei.ItemSize,d);
    ErrorCode := State(Datei.DosDatei);
   END(*IF*);
  END FixGet;


 PROCEDURE FixPut(VAR Datei : FixFile; SatzNr   : LONGINT;
                  VAR Buffer: ARRAY OF LOC);

  BEGIN 
   Seek(Datei.DosDatei,LONGINT(LONG(Datei.ItemSize)) * SatzNr,fromBegin);
   ErrorCode := State(Datei.DosDatei);
   IF ErrorCode = 0 THEN 
    WriteBytes(Datei.DosDatei,ADR( Buffer), Datei.ItemSize);
    ErrorCode:= State(Datei.DosDatei) ; 
    IF ErrorCode = 0 THEN 
     FileUpdated(Datei);
    END(*IF*);
   END(*IF*);
  END FixPut; 


 PROCEDURE FixMake(VAR Datei : FixFile;  FName      : ARRAY OF CHAR;
                       RecLen: CARDINAL; ZaehlStart : CARDINAL);

  VAR DateiPtr : FileStack; 

  BEGIN 
   ErrorCode := 0;
   IF (RecLen > MaxDataRecSize) THEN 
    ErrorCode := RecTooLargeError;
   END(*IF*);
   IF (RecLen < MinDataRecSize) THEN 
    ErrorCode := RecTooSmallError;
   END(*IF*);
   IF (ErrorCode # 0) THEN 
    RETURN;
   END(*IF*);
   Clear(ADR(Datei),SIZE(Datei));
   Create(Datei.DosDatei,FName,readWrite,noReplace);
   ErrorCode := State(Datei.DosDatei);
   IF (ErrorCode # 0) THEN                      
    RETURN;
   END(*IF*);
   CreateHeader(Datei, RecLen, ZaehlStart);      (* Datei-Parameter-Satzes *)
   IF (ErrorCode # 0) THEN 
    Close(Datei.DosDatei);
    RETURN;
   END(*IF*);                                  (* Datei in die Datei-Liste *)
   NEW(DateiPtr);
   DateiPtr^.Vorg := DateiStapel;
   DateiPtr^.DateiPtr := ADR(Datei);
   DateiStapel := DateiPtr;
  END FixMake; 


 PROCEDURE FixRecSize(DateiName : ARRAY OF CHAR) : LONGINT;
  VAR Datei : FixFile;

  BEGIN 
   Clear(ADR(Datei),SIZE(Datei));
   Open(Datei.DosDatei,DateiName,readWrite);
   ErrorCode := State(Datei.DosDatei);
   IF (ErrorCode # 0) THEN 
    RETURN -1;
   END(*IF*);
   ReadHeader(Datei, 0);                   (* Einlesen der Datei-Parameter *)
   IF (ErrorCode = 0) THEN 
    RETURN Datei.ItemSize;
   END(*IF*);
   Close(Datei.DosDatei);
  END FixRecSize;
  

 PROCEDURE FixOpen(VAR Datei   : FixFile;  FName   : ARRAY OF CHAR;
                       RecLen  : CARDINAL; MaxCount: CARDINAL);

  VAR DateiPtr : FileStack; 

  BEGIN 
   ErrorCode := 0;
   IF (RecLen > MaxDataRecSize) THEN 
    ErrorCode := RecTooLargeError;
   END(*IF*);
   IF (RecLen < MinDataRecSize) THEN 
    ErrorCode := RecTooSmallError;
   END(*IF*);
   IF (ErrorCode # 0) THEN 
    RETURN;
   END(*IF*);
   Clear(ADR(Datei),SIZE(Datei));
   Open(Datei.DosDatei,FName,readWrite);
   ErrorCode := State(Datei.DosDatei);
   IF (ErrorCode # 0) THEN 
    RETURN;
   END(*IF*);
   ReadHeader(Datei, MaxCount);             (* Einlesen der Datei-Parameter *)
   IF (ErrorCode # 0) THEN
    RETURN;
   END(*IF*);
   IF (RecLen # Datei.ItemSize) THEN 
    Close(Datei.DosDatei);
    ErrorCode := RecSizeMismatchError;
    RETURN;
   END(*IF*);
   IF (Datei.Integritaet # True) THEN         (* Wurde Datei nicht geschlossen? *)
    ErrorCode := fCRCError;
   END(*IF*);
   NEW(DateiPtr);                                (* Datei in die Dateiliste *)
   DateiPtr^.Vorg := DateiStapel;
   DateiPtr^.DateiPtr := ADR(Datei);
   DateiStapel := DateiPtr;
  END FixOpen; 


 PROCEDURE FixClose(VAR Datei: FixFile);
  VAR NachfPtr, 
      StapelPtr: FileStack;
 
  BEGIN
   NachfPtr := NIL; 
   StapelPtr := DateiStapel;
   WHILE (StapelPtr # NIL) AND (StapelPtr^.DateiPtr # ADR(Datei)) DO 
    NachfPtr := StapelPtr;
    StapelPtr := StapelPtr^.Vorg;
   END;
   IF (StapelPtr # NIL) AND (StapelPtr^.DateiPtr = ADR(Datei)) THEN
    IF (NachfPtr # NIL) THEN 
     NachfPtr^.Vorg := StapelPtr^.Vorg
    ELSE 
     DateiStapel := StapelPtr^.Vorg;
    END(*IF*);
    DEALLOCATE(StapelPtr,0);
    CloseInternFile(Datei);
   ELSE 
    ErrorCode := fInvalidHandle;
    (*Write(CHR(7));*)
   END(*IF*);
  END FixClose;


 PROCEDURE FixErase(VAR Datei : FixFile);
  VAR name: ARRAY [0..137] OF CHAR;
  
  BEGIN
   GetFileName(Datei.DosDatei,name);           (* Dateiname fr Delete merken *)
   FixClose(Datei);
   IF (ErrorCode # 0) THEN 
    RETURN;
   END(*IF*);
   Delete(name,ErrorCode);
  END FixErase; 


 PROCEDURE FixRename(VAR Datei : FixFile; fNeu: ARRAY OF CHAR);
  VAR name: ARRAY [0..137] OF CHAR;
  
  BEGIN
   GetFileName(Datei.DosDatei,name);           (* Dateiname fr Rename merken *)
   FixClose(Datei);
   IF (ErrorCode # 0) THEN 
    RETURN;
   END(*IF*);
   Rename(name, fNeu,ErrorCode);
  END FixRename; 


 PROCEDURE FixNew(VAR Datei  : FixFile; VAR SatzNr : LONGINT);
  VAR n : LONGCARD;
    
  BEGIN
   ErrorCode := State(Datei.DosDatei);       (* ioIgnore  *)
   ErrorCode := 0;
   IF (Datei.FirstFree = -1) THEN 
    SatzNr := Datei.NumRec;
    TaRecBuf^.I := 0;
    Seek(Datei.DosDatei,LONGINT(LONG(Datei.ItemSize)) * SatzNr,fromBegin);
    WriteBytes(Datei.DosDatei, TaRecBuf, Datei.ItemSize);
    ErrorCode := State(Datei.DosDatei);
    IF (ErrorCode = 0) THEN 
     INC(Datei.NumRec);
    END(*IF*);
   ELSE 
    SatzNr := Datei.FirstFree;
    Seek(Datei.DosDatei,LONGINT(LONG(Datei.ItemSize)) * SatzNr,fromBegin);
    ReadBytes(Datei.DosDatei, TaRecBuf, TSIZE(LONGINT), n );
    ErrorCode := State(Datei.DosDatei);
    IF (ErrorCode = 0) THEN 
     Datei.FirstFree := TaRecBuf^.I;
     DEC(Datei.NumberFree);
    END(*IF*);
   END(*IF*);
  END FixNew; 


 PROCEDURE FixAdd(VAR Datei : FixFile; VAR SatzNr : LONGINT;
                  VAR Buffer: ARRAY OF LOC);

  BEGIN
   FixNew(Datei, SatzNr);
   IF (ErrorCode = 0) THEN 
    FixPut(Datei, SatzNr, Buffer);
   END(*IF*);
  END FixAdd; 


 PROCEDURE FixDel(VAR Datei  : FixFile; SatzNr : LONGINT);
  
  BEGIN 
   FixGet(Datei, SatzNr, TaRecBuf^, 1);
   TaRecBuf^.I := Datei.FirstFree;
   FixPut(Datei, SatzNr, TaRecBuf^);
   Datei.FirstFree := SatzNr;
   INC(Datei.NumberFree);
   FileUpdated(Datei);
  END FixDel; 


 PROCEDURE FixTotal(VAR Datei : FixFile): LONGINT;

  BEGIN 
    RETURN Datei.NumRec;
  END FixTotal; 


 PROCEDURE FixSize(VAR Datei: FixFile): LONGINT;

  BEGIN 
    RETURN Datei.NumRec * LONGINT(LONG(Datei.ItemSize));
  END FixSize; 


 PROCEDURE FixUsed(VAR Datei: FixFile) : LONGINT;

  BEGIN
   RETURN Datei.NumRec - Datei.NumberFree - 1;
  END FixUsed; 


 PROCEDURE FixCounter(VAR Datei: FixFile) : CARDINAL;

  BEGIN
   RETURN Datei.Zaehler;
  END FixCounter; 


 PROCEDURE FixflushAll;
  VAR pDatei: FileStack;

  BEGIN
   pDatei := DateiStapel;
   WHILE (pDatei # NIL) DO
    FixFlush(pDatei^.DateiPtr^);
    pDatei := pDatei^.Vorg;
   END(*WHILE*);
  END FixflushAll;


(* PROCEDURE ExitUnit;

  BEGIN       
   FixflushAll;
   ExitProc := ExitProcSave;
  END;
  *)

 BEGIN
  DateiStapel := NIL;
(*  ExitProcSave := ExitProc;
  ExitProc := ADR(ExitUnit);   *)
 END FixFiles.

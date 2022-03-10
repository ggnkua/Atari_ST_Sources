IMPLEMENTATION MODULE IsamGlobals;

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


 FROM Binary      IMPORT ReadBytes, WriteBytes, Seek, SeekMode, FileSize;
 FROM Files       IMPORT Flush, Close, State;
 FROM SYSTEM      IMPORT ADR, BYTE, CAST, ADDRESS, ASSEMBLER,WORD;
 FROM Storage     IMPORT ALLOCATE;
 FROM MOSGlobals  IMPORT fAccessDenied, fCRCError;
 FROM Block       IMPORT Clear;
 

(*$L-*)
PROCEDURE xor(a,b: WORD) : WORD;
BEGIN
  ASSEMBLER     
        MOVE    -(A3),D1        ; D1: b
        MOVE    -(A3),D0        ; D0: a
        EOR     D1,D0           ; XOR heižt beim 68000 EOR!
        MOVE    D0,(A3)+        ; Funktionswert zurckgeben
  END
END xor;

 PROCEDURE Move(Quelle,Ziel: ADDRESS; Anzahl: LONGCARD);
  
  BEGIN
   ASSEMBLER
       MOVE.L     -(A3),D1
       MOVE.L     -(A3),A1
       MOVE.L     -(A3),A0
       BRA        ERSTEMAL

    SCHLEIFE:  
       MOVE.B     (A0)+,(A1)+

    ERSTEMAL:  
       DBF        D1,SCHLEIFE
   END;
  END Move;
(*$L=*)

 PROCEDURE CheckChar(REF Daten :ARRAY OF WORD ; Groesse: INTEGER): CHAR;
  VAR
   x: WORD;
   c,d: CARDINAL;
  
  BEGIN
   FOR d:= 0 TO HIGH(Daten) DO
    x:= xor(x,Daten[d]);
   END;
   c:=CAST(CARDINAL,x);
   RETURN CHR(c MOD 255);
  END CheckChar;


 PROCEDURE PutHeader(VAR DatF: FixFile);

  BEGIN
   Clear(TaRecBuf,SIZE(TaRecBuf^));
   Move(ADR(DatF.FirstFree), TaRecBuf, FileHeaderSize);
   DatF.CheckSum1 := CheckChar(DatF.FirstFree, FileHeaderSize-2);
   DatF.CheckSum2 := CheckChar(DatF.FirstFree, FileHeaderSize-1);
   Move(ADR(DatF.FirstFree), TaRecBuf, FileHeaderSize);
   Seek(DatF.DosDatei, 0,fromBegin);
   WriteBytes(DatF.DosDatei, TaRecBuf, FileHeaderSize );
   ErrorCode := State(DatF.DosDatei);
  END PutHeader;


 PROCEDURE ReadHeader(VAR DatF: FixFile; MaxCount : CARDINAL);
  VAR d : LONGCARD;
      
  BEGIN
   WITH DatF DO 
    Seek(DosDatei,0,fromBegin);
    ReadBytes(DosDatei, TaRecBuf, FileHeaderSize,d);
    ErrorCode := State(DosDatei);
    IF (ErrorCode = 0) THEN 
     Move(TaRecBuf,ADR(FirstFree), FileHeaderSize);
     IF (ItemSize > 0 ) THEN 
      NumRec := LONGINT(FileSize(DosDatei)) DIV LONG(INTEGER(ItemSize));
     ELSE 
      NumRec := 0;
     END(*IF*);
     IF (MaxCount > 0) THEN
      IF (Zaehler >= MaxCount) THEN 
       ErrorCode := fAccessDenied
      ELSE
       IF (CheckSum1 <> CheckChar(FirstFree, FileHeaderSize-2) ) OR
          (CheckSum2 <> CheckChar(FirstFree, FileHeaderSize-1) ) THEN 
        ErrorCode := fCRCError
       ELSE 
        INC(Zaehler);
        PutHeader(DatF);
       END(*IF*);
      END(*IF*);
     ELSE 
      INC(DatF.Zaehler);
      PutHeader(DatF);
     END(*IF*);
    END(*IF*);
   END(*WITH*);
  END ReadHeader; 


 PROCEDURE FileUpdated(VAR DatF: FixFile);

  BEGIN
   IF (DatF.Integritaet=True) THEN 
    DatF.Integritaet := False;
    PutHeader(DatF);
    IF (ErrorCode = 0) THEN 
     Flush(DatF.DosDatei);
    END(*IF*);
   END(*IF*);
  END FileUpdated; 


 PROCEDURE CreateHeader(VAR DatF: FixFile; RecLen: CARDINAL; ZaehlStart : CARDINAL);

  BEGIN
   WITH DatF DO 
    Clear(TaRecBuf,SIZE(TaRecBuf^));
    FirstFree := -1;
    NumberFree := 0;
    ItemSize := RecLen;
    Integritaet := True;
    Zaehler := ZaehlStart;
    CheckSum1 := CheckChar(FirstFree, FileHeaderSize-2);
    CheckSum2 := CheckChar(FirstFree, FileHeaderSize-1);
    Move(ADR(FirstFree), TaRecBuf, FileHeaderSize);
    Seek(DosDatei, 0,fromBegin);
    WriteBytes(DosDatei, TaRecBuf, RecLen);
    ErrorCode := State(DosDatei);
    NumRec := 1;
   END(*WITH*);
  END CreateHeader; 


 PROCEDURE FlushFile(VAR DatF: FixFile);

  BEGIN 
   DatF.Integritaet := True;
   PutHeader(DatF);
   IF (ErrorCode = 0) THEN 
    Flush(DatF.DosDatei);
   END(*IF*); 
  END FlushFile;


 PROCEDURE CloseInternFile(VAR DatF: FixFile);

  BEGIN
   DatF.Integritaet := True;     
   PutHeader(DatF);
   IF (ErrorCode = 0) THEN
    Close(DatF.DosDatei);
    ErrorCode := State(DatF.DosDatei);
   END(*IF*);
  END CloseInternFile; 




 BEGIN
  NEW(TaRecBuf);
 END IsamGlobals.

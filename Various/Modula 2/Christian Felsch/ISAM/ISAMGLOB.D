DEFINITION MODULE IsamGlobals;
 
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


 (* Modul mit allen Konstanten und Type fÅr ISAM sowie der   *)
 (* Prozeduren zur Verwaltung des Status-Headers der Dateien *)

 (*  I  : Eingabewerte vom Benutzer                       *)
 (*  o  : nur interne Statusinformationen werden geÑndert *)
 (*  O  : relevante Informationen werden zurÅckgeliefert  *)


 FROM SYSTEM    IMPORT ADDRESS, BYTE;
 FROM Files     IMPORT File;
  

 CONST Order          = 64;    (* Ordnung des B+Tree *)
       PageSize       = 2 * Order;  
       PageStackSize  = 32;    (* Anzahl der B+Tree Seiten im Cache *)
       MaxHeight      = 8;     (* Maximale Hîhe des B+Tree *)
       MaxDataRecSize = 10240; (* Maximale Grî·e eines Datensatzes in Bytes *)
       MaxKeyLen      = 16;    (* Maximale LÑnge eines Indexeintrags *)
 
       FileHeaderSize = 19;
       MinDataRecSize = FileHeaderSize;
       RestartCode    = 200;

       RecTooLargeError     = 10; (* selbstdefinierte FehlerCodes   *)
       RecTooSmallError     = 11;
       RecSizeMismatchError = 12;
       KeyTooLargeError     = 13;
       KeySizeMismatchError = 14;

       True                 = 'T';           (* FÅr einen Boolean, der *)
       False                = 'F';           (* nur ein Byte lang ist  *)
                                             (*  echt heftig           *)

 TYPE  IndexType      = (Singles, Dups, AutoInc); (* siehe 'Readme' File *)

       FixFile        = RECORD                         (* Aufbau Datendateien *)
                         DosDatei    : File;
                         NumRec      : LONGINT;
                         FirstFree   : LONGINT;
                         NumberFree  : LONGINT;
                         Int1        : LONGINT;
                         ItemSize    : CARDINAL;
                         Integritaet : CHAR;
                         Zaehler     : CARDINAL;
                         CheckSum1   : CHAR;
                         CheckSum2   : CHAR;
                        END(*RECORD*);

      IsamKeyStr      = ARRAY [0..MaxKeyLen] OF CHAR;            (* SchlÅssel *)

      Item            = RECORD                            (* Eintrag der Page *)
                         DataRef, 
                         PageRef : LONGINT;
                         Key     : IsamKeyStr;
                        END(*RECORD*);

      Page            = RECORD                          (* Element des B+Tree *)
                         ItemsOnPage : INTEGER[0..PageSize];
                         BckwPageRef : LONGINT;
                         ItemArray   : ARRAY [1..PageSize] OF Item;
                        END(*RECORD*);

      PagePtr         = POINTER TO Page;
  
      TaSearchStep    = RECORD
                         PageRef,
                         ItemArrIndex : LONGINT;
                        END(*RECORD*);

      Path            = ARRAY [1..MaxHeight] OF TaSearchStep;
  
      IdxFile         = RECORD                         (* Aufbau Indexdateien *)
                         DataF       : FixFile;
                         Typ         : IndexType;
                         KeyL        : BYTE;
                         WurzelDsNr,
                         SeitenDsNr  : LONGINT;
                         Pfad        : Path;
                        END(*RECORD*);

      IndexFilePtr    = POINTER TO IdxFile;

      TaStackRec      = RECORD
                         Seite     : Page;
                         IndexFPtr : IndexFilePtr;
                         PageRef   : LONGINT;
                         Updated   : CHAR;
                        END(*RECORD*);

      TaStackRecPtr   = POINTER TO TaStackRec;

      TaPageStack     = ARRAY [1..PageStackSize] OF TaStackRecPtr;

      TaPageStackPtr  = POINTER TO TaPageStack;

      TaPageMap       = ARRAY [1..PageStackSize] OF CARDINAL;

      TaPageMapPtr    = POINTER TO TaPageMap;

      TaRecordBuffer  = RECORD
                         CASE :INTEGER OF
                          0 : Seite : TaStackRec; |
                          1 : R : ARRAY [1..MaxDataRecSize] OF BYTE;|
                          2 : I : LONGINT;|
                         END(*CASE*);
                        END(*RECORD*);

      TaRecordBufPtr  = POINTER TO TaRecordBuffer;

      Profile         = RECORD 
                         Handle : BYTE;
                         Lg     : CARDINAL;
                        END(*RECORD*);


 VAR ErrorCode : INTEGER;
     TaRecBuf  : TaRecordBufPtr;

 
 PROCEDURE CreateHeader(VAR DatF      : FixFile;        (* O *)
                            RecLen    : CARDINAL;       (* I *)
                            ZaehlStart: CARDINAL);      (* I *)
                            
  (* Kreiert neun Status-Header fÅr eine Datendatei und schreibt ihn *)


 PROCEDURE ReadHeader(VAR DatF     : FixFile;           (* O *)
                          MaxCount : CARDINAL);         (* I *)

  (* Liest den Status-Header einer Datendatei ein *)
  

 PROCEDURE PutHeader(VAR DatF: FixFile);                (* I/o *) 
  (* Schreibt den Status-Header in eine Datendatei *)
  
  
 PROCEDURE FileUpdated(VAR DatF: FixFile);              (* I/o *)
 
  (* Updated eine Dateindatei, wenn noch nicht alles gesichert *)
  (* wurde. ( Siehe auch <Flush> ) *)
  

 PROCEDURE CloseInternFile(VAR DatF: FixFile);          (* I/o *)
 
  (* Schlieût Datendatei *)


(*---------------------------------------------------------------------------*)

 PROCEDURE Move(Quelle, Ziel: ADDRESS; Anzahl: LONGCARD);
 
  (* Kopiert <Anzahl> Bytes von <Quelle> nach <Ziel>  *)
 
END IsamGlobals.
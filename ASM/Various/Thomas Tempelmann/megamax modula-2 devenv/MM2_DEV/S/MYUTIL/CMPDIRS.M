MODULE CmpDirs; (*$E MTP *)

IMPORT GEMDOSIO;

FROM Clock IMPORT Time, Date, UnpackTime, UnpackDate;

FROM SysUtil0 IMPORT VarEqual;

FROM ArgCV IMPORT PtrArgStr, InitArgCV;

FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, Read, ReadString;

FROM Files IMPORT File, Access, Open, Close, State;

FROM Binary IMPORT FileSize, ReadBytes;

FROM Directory IMPORT DirQuery, DirEntry, subdirAttr, archiveAttr, FileAttrSet;

FROM Strings IMPORT StrEqual, String, Empty, Append, Assign, Length, Space,
        Upper, Concat;

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, ASSEMBLER;

VAR subdirs, ok: BOOLEAN;
    c: CHAR;
    res: INTEGER;
    destpath: String;

PROCEDURE missing (s: ARRAY OF CHAR; dir: BOOLEAN);
  BEGIN
    WriteLn;
    WriteString (s);
    IF dir THEN
      WriteString (Space (40-Length(s)));
      WriteString (' <DIR>')
    END;
  END missing;

PROCEDURE GetDirEntry ( fileName: ARRAY OF CHAR;
                        VAR entry: DirEntry; VAR found: BOOLEAN );
  (*
   * Liefert die Directory-Daten einer Datei.
   * Existiert die Datei nicht auf dem angegebenen Pfad oder ist der
   * angegebene Name ein Unterverzeichnis oder ein Volume-Label,
   * liefert 'found' FALSE.
   *)

  (*$L-*)
  
  PROCEDURE str0;
    BEGIN
      ASSEMBLER
        ; D0: HIGH (s)
        ; A0: ADR (s)
        ; D2 erhalten !
        MOVE.L  (A7)+,A1
        
        MOVE    D0,D1
        ADDQ    #3,D1
        BCLR    #0,D1
        
        ; LINK:
        PEA     (A5)
        MOVE.L  A7,A5
        SUBA.W  D1,A7
        
        CMPA.L  A3,A7
        BLS     E
        MOVE.L  A7,A2
        
     L: MOVE.B  (A0)+,(A2)+
        DBRA    D0,L
        CLR.B   (A2)+
        
        MOVE.L  A7,D0
        JMP     (A1)
     
     E: TRAP    #6      ; OUT OF STACK
        DC.W    -10
      END
    END str0;

  PROCEDURE setDta;
    BEGIN
      ASSEMBLER
        ; get old DTA
        MOVE    #$2F,-(A7)
        TRAP    #1
        MOVE.L  D0,D3           ; alten DTA merken in D3
        ; set new DTA
        MOVE.L  D4,-(A7)
        MOVE    #$1A,-(A7)
        TRAP    #1
        ADDQ.L  #8,A7
      END
    END setDta;

  PROCEDURE rstDta;
    BEGIN
      ASSEMBLER
        ; reset old DTA, erhalte D0 !
        MOVE.L  D0,-(A7)
        MOVE.L  D3,-(A7)
        MOVE    #$1A,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  (A7)+,D0
      END
    END rstDta;

  BEGIN
    ASSEMBLER
        MOVE.L  -14(A3),A0
        MOVE.W  -10(A3),D0
        BSR     str0
        
        MOVEM.L D3/D4,-(A7)
        
        ; DTA anlegen
        SUBA.W  #44,A7
        MOVE.L  A7,D4
        
        CLR.W   -(A7)           ; Attribut
        MOVE.L  D0,-(A7)        ; zuerst D0 (^name) sichern
        BSR     setDta          ; dann DTA sichern/umsetzen
        MOVE    #$4E,-(A7)
        TRAP    #1              ; FSFIRST
        ADDQ.L  #8,A7
        BSR     rstDta
        
        MOVE.L  -8(A3),A1       ; ADR (entry)
        
        ; Name in Dir vorhanden ?
        TST.L   D0
        BMI     fals
        
        ; PrÅfen, ob es ein normales File ist (nicht Subdir/volID)
        MOVE.B  21(A7),D0
        ANDI    #11000%,D0
        BNE     fals
        
        ; DirEntry kopieren, DTA ist direkt auf dem Systemstack
        ; name
        MOVEQ   #5,D0
        LEA     $1E(A7),A0
    L0: MOVE.W  (A0)+,(A1)+
        DBRA    D0,L0
        ; attr
        MOVE.B  21(A7),(A1)+
        CLR.B   (A1)+
        ; time
        MOVE    22(A7),(A3)+
        MOVE.L  A1,-(A7)
        JSR     UnpackTime
        MOVE.L  (A7)+,A1
        MOVE.L  -6(A3),(A1)+
        MOVE.W  -(A3),(A1)+
        SUBQ.L  #4,A3
        ; date
        MOVE    24(A7),(A3)+
        MOVE.L  A1,-(A7)
        JSR     UnpackDate
        MOVE.L  (A7)+,A1
        MOVE.L  -6(A3),(A1)+
        MOVE.W  -(A3),(A1)+
        SUBQ.L  #4,A3
        ; size
        MOVE.L  26(A7),(A1)+
        MOVEQ   #1,D0
        BRA     ende
        
      fals
        ; entry lîschen
        MOVEQ   #14,D0
    l1: CLR.W   (A1)+
        DBRA    D0,l1
        MOVEQ   #0,D0
        
      ende
        MOVE.L  -(A3),A0        ; ok
        MOVE    D0,(A0)
        
        SUBA.W  #10,A3          ; name + entry
        ADDA.W  #44,A7
        MOVEM.L (A7)+,D3/D4
        UNLK    A5
    END
  END GetDirEntry;
  (*$L=*)

PROCEDURE checkFile (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR dest: String; f: File; destentry: DirEntry;

  BEGIN
    Concat (destpath, entry.name, dest, ok);
    GetDirEntry (dest, destentry, ok);
    IF NOT ok
    OR ((destentry.attr-FileAttrSet{archiveAttr}) # (entry.attr-FileAttrSet{archiveAttr}))
    OR NOT VarEqual (destentry.time, entry.time)
    OR NOT VarEqual (destentry.date, entry.date)
    OR (destentry.size # entry.size)
    OR NOT StrEqual (destentry.name, entry.name) THEN
      Concat (path, entry.name, dest, ok);
      missing (dest, FALSE)
    END;
    RETURN TRUE
  END checkFile;

PROCEDURE checkDDir (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  BEGIN
    RETURN FALSE
  END checkDDir;

PROCEDURE checkDir (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR lastpath, dest, source: String;

  BEGIN
    IF subdirAttr IN entry.attr THEN
      IF entry.name[0] # '.' THEN
        Concat (path, entry.name, source, ok);
        (*
          WriteLn;
          WriteString ('// Path ');
          WriteString (source);
        *)
        Append ('\', source, ok);
        lastpath:= destpath;
        Append (entry.name, destpath, ok);
        Append ('\', destpath, ok);
        Concat (destpath, '*.*', dest, ok);
        DirQuery (dest, FileAttrSet {}, checkDDir, res);
        IF (res < 0) AND (res # -33) THEN
          missing (source, TRUE);
        ELSE
          Append ('*.*', source, ok);
          DirQuery (source, FileAttrSet {}, checkFile, res);
          DirQuery (source, FileAttrSet {subdirAttr}, checkDir, res);
          IF res < 0 THEN
            HALT
          END
        END;
        destpath:= lastpath;
      END
    END;
    RETURN TRUE
  END checkDir;


VAR     argv: ARRAY [0..3] OF PtrArgStr;
        argc: CARDINAL;
        n1: String;
        ch: CHAR;

BEGIN
  InitArgCV ( argc, argv );
  IF argc > 2 THEN
    Assign (argv[1]^, n1, ok);
    Assign (argv[2]^, destpath, ok);
    subdirs:= argc > 3
  ELSE
    WriteString ('First folder  ? ');
    ReadString (n1);
    IF Empty (n1) THEN RETURN END;
    WriteString ('Second folder ? ');
    ReadString (destpath);
    IF Empty (destpath) THEN RETURN END;
  END;
  
  Upper (n1);
  Upper (destpath);
  (*
  WriteString ('// Path ');
  WriteString (n1);
  *)
  Append ('*.*', n1, ok);
  DirQuery (n1, FileAttrSet {}, checkFile, res);
  DirQuery (n1, FileAttrSet {subdirAttr}, checkDir, res);
  IF res < 0 THEN
    WriteLn;
    WriteString ('Error #');
    WriteInt (res,0)
  END;
  
  WriteLn;
END CmpDirs.

(* $FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$000012A9$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3A$FFF68C3AÄ$0000129DT.......T.......T.......T.......T.......T..T....T.......T.......T.......T.......$000012D2$000012A9$0000129D$000012D0$000012C5$00001363$000013C8$0000025F$00000528$0000026B$FFF2F840$00000098$00001282$000012AE$000001AC$000012AAîÄÄ*)

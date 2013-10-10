MODULE Serialize;

(*    =======================================
       Vertraulich! Keinesfalls weitergeben!
      =======================================
   
      Seriennummern im Compiler eintragen
        
      17.11.87  jm   /0.0/  Suchen der Seriennummern
      15.12.87  jm   /1.0/  lauffÑhige Version
      29.02.88  jm   /1.1/  neues SchlÅsselverfahren mit Offset
     
*)

FROM Files   IMPORT File, Open, Create, Close, Remove, State,
                    Access, ReplaceMode;
FROM Binary  IMPORT SeekMode, Seek, ReadBytes, ReadWord, WriteWord, FileSize;
FROM Paths   IMPORT PathList, StdPaths, SearchFile, ListPos;
FROM InOut   IMPORT WriteString, FlushKbd, BusyRead, WriteLn, Read, WriteCard, 
 ReadCard, WriteHex;
FROM Storage IMPORT ALLOCATE;
FROM Strings IMPORT Concat;
FROM StrConv IMPORT CardToStr;
FROM SYSTEM  IMPORT ADDRESS;
FROM PrgCtrl IMPORT TermProcess;


CONST   compname = 'A:\M2.MOD';       (* Name des Codefiles *)
          NrKeys = 2;                 (* Anzahl verschiedener SchlÅssel *)
        maxCount = 10;                (* max. Anzahl Referenzen pro Nummer *)

TYPE     PosList = ARRAY [1..maxCount] OF LONGCARD;

VAR
            value,                    (* Werte der Default-Seriennummern *)
             lead,                    (* LeadIn-Worte   -"-              *)
         expCount,                    (* erwartete Anzahl der Vorkommen  *)
            patch: ARRAY [0..NrKeys] OF CARDINAL;
          offsets: ARRAY [0..NrKeys] OF PosList;

             Offs,
           RegLen,
         FeedBack,
          Iterate: ARRAY [1..NrKeys] OF CARDINAL;


PROCEDURE err (s: ARRAY OF CHAR; fatal: BOOLEAN);
  VAR c: CHAR;
  BEGIN
    WriteLn; WriteString ('>> '); WriteString (s); WriteLn;
    IF fatal THEN
      Read (c); TermProcess (1);
    END
  END err;
  

PROCEDURE ReadCompiler (VAR a: ADDRESS; VAR size: LONGCARD;
                         name: ARRAY OF CHAR): BOOLEAN;
  
  (* Sucht Datei <name> auf DefaultPath,
     reserviert Speicher und liest Datei ein.
     <a>    := Anfangsadresse der Datei im Speicher;
     <size> := LÑnge  -"- .
     Ergebnis := 'Datei gefunden, genug Platz zum Einlesen gehabt'
  *)
  
  VAR         f: File;
             ok: BOOLEAN;
           path: PathList;
           read: LONGCARD;
       realname: ARRAY [0..127] OF CHAR;
       
  BEGIN
    path := StdPaths();
    SearchFile (name, path, fromStart, ok, realname);
    IF NOT ok THEN RETURN FALSE END;
    Open (f, realname, readOnly);
    size := FileSize (f);
    ALLOCATE (a, size);
    IF a = NIL THEN RETURN FALSE END;
    ReadBytes (f, a, size, read);
    IF size # read THEN RETURN FALSE END;
    Close (f);
    RETURN TRUE
  END ReadCompiler;


PROCEDURE Search (        a: ADDRESS; len: LONGCARD; targ1, targ2: CARDINAL;
                  VAR count: CARDINAL;
                    VAR pos: PosList);
  BEGIN
    ASSEMBLER
      MOVE.L   pos(A6),A1
      CLR.W    D3
      MOVE.L   a(A6),A0
      MOVE.L   len(A6),D1
      MOVE.W   targ1(A6),D0
      MOVE.W   targ2(A6),D4
   
   lp CMP.W    (A0)+,D0         ;Suchschleife
      BNE      nix
      CMP.W    (A0),D4
      BNE      nix
      MOVE.L   A0,D2
      SUB.L    a(A6),D2
      MOVE.L   D2,(A1)+
      ADDQ.L   #1,D3
  nix SUBQ.L   #2,D1
      BHI      lp
      
      MOVE.L   count(A6),A0
      MOVE.W   D3,(A0)          ;setze Count
    END
  END Search;


PROCEDURE FindOffsets;
  
  (*  Liest Datei <compname> nach Suche auf DefaultPath.
      Durchsucht nach Auftreten von <lead>, <value> und prÅft
      jeweils, ob <expcount> Vorkommen gefunden.
      Bricht im Fehlerfall mit Meldung ab.
  *)
      
  VAR   a: ADDRESS;
        l: LONGCARD;
 count, k: CARDINAL;
   errmsg: ARRAY [0..127] OF CHAR;
    dummy: BOOLEAN;
  
  BEGIN
    IF ReadCompiler (a, l, compname) THEN
      FOR k := 0 TO NrKeys DO
        Search (a, l, lead [k], value [k], count, offsets [k]);
        IF count # expCount [k] THEN
          Concat ('Falsche Anzahl SchlÅsseleintrÑge: ',
                   CardToStr (count, 0), errmsg, dummy);
          err (errmsg, TRUE)
        END;
      END
    ELSE
      err ('Compiler kann nicht gelesen werden!', TRUE)
    END;
  END FindOffsets;
  
  
PROCEDURE encode (start, len, feedback, iter, off: CARDINAL): CARDINAL; (*$L-*)
    
  (* Schieberegister rechtsrum, Bits 0..<len>,
     RÅckkopplung aus Bit <feedback>, auf <start>-Wert loslassen.
     <iter> Iterationen durchfÅhren; <Off> addieren;
     Ergebnis auf Cardinal kÅrzen
  *)
  
  BEGIN
    ASSEMBLER
      MOVE.W  -(A3),D3        ;Offset
      MOVE.W  -(A3),D2        ;Iterationen
      MOVE.W  -(A3),D0        ;rÅckgefÅhrtes Bit
      MOVE.W  -(A3),D4        ;RegisterlÑnge -1
      CLR.L   D1
      MOVE.W  -(A3),D1        ;Startwert
      BRA     l1
   l2 BTST    D0,D1           ;Bit0 := Bit0 EOR Bit(D0)
      BEQ     nochg           ; "
      BCHG    #0,D1           ; "
nochg LSR.L   #1,D1           ;einmal rechts schieben
      BCC     l1              ;und Bit0 in Bit(D4) rotieren
      BSET    D4,D1
   l1 DBF     D2,l2
      ADD.W   D3,D1           ;Offset dazu
      MOVE.W  D1,(A3)+        ;Ergebnis zurÅck
    END
  END encode;         (*$L+*)
  
  
PROCEDURE CheckSer;
 
   (* prÅft, ob die angegebenen SchlÅsselverfahren konsistent
      sind mit den angegebenen Default-EintrÑgen.
      Im Fehlerfall Abbruch mit Meldung.
   *)
   
   VAR  k: CARDINAL;
   
   BEGIN
     FOR k := 1 TO NrKeys DO
       IF encode (value[0], RegLen[k], FeedBack[k], Iterate[k], Offs[k])
          # value [k]
         THEN err ('SchlÅsselverfahren paût nicht zu Default-EintrÑgen', TRUE)
       END
     END
   END CheckSer;
   

PROCEDURE CalcSer (mySer: CARDINAL);
  
  (* öbergabe der Seriennummer in <mySer>.
     Setzt ARRAY <patch> auf verschlÅsselte Seriennummern.
     Verwendet Beschreibung der SchlÅsselverfahren in
     <RegLen>, <FeedBack>, <Iterate>.           *)
  
  VAR  k: CARDINAL;
  
  BEGIN
    patch [0] := mySer;
    WriteString ('   Nr. '); WriteCard (mySer, 4);
    WriteString ('   SchlÅssel '); WriteHex (patch [0], 7);
    FOR k := 1 TO NrKeys DO
      patch [k] :=
             encode (mySer, RegLen[k], FeedBack[k], Iterate[k], Offs [k]);
      WriteHex (patch[k], 7);
    END;
    WriteLn;
  END CalcSer;
  
  
PROCEDURE OpenCompiler (VAR f: File; name: ARRAY OF CHAR): BOOLEAN;
  
  (* Sucht Datei <name> auf DefaultPath,
     reserviert Speicher und liest Datei ein.
     <a>    := Anfangsadresse der Datei im Speicher;
     <size> := LÑnge  -"- .
     Ergebnis := 'Datei gefunden, genug Platz zum Einlesen gehabt'
  *)
  
  VAR       ok: BOOLEAN;
           path: PathList;
       realname: ARRAY [0..127] OF CHAR;
       
  BEGIN
    path := StdPaths();
    SearchFile (name, path, fromStart, ok, realname);
    IF NOT ok THEN
      err ('Datei nicht gefunden', FALSE); RETURN FALSE
    END;
    Open (f, realname, readWrite);
    IF State (f) < 0 THEN
      err ('Datei gefunden, aber nicht zu îffnen', FALSE); RETURN FALSE
    END;
    RETURN TRUE
  END OpenCompiler;


PROCEDURE PatchSerial (mySer: CARDINAL): BOOLEAN;
  
  VAR  j, k: CARDINAL;
          f: File;
          w: CARDINAL;
          
  BEGIN
    CalcSer (mySer);
    IF NOT OpenCompiler (f, compname) THEN
      RETURN FALSE
    END;
    FOR j := 0 TO NrKeys DO
      FOR k := 1 TO expCount [j] DO
        Seek (f, offsets [j, k], fromBegin);
        ReadWord (f, w);
        IF w # value [j] THEN
          IF (j=0) & (k=1) THEN
            err ('Falsche Seriennummern gefunden: Datei unverÑndert', FALSE);
            Close (f);
          ELSE
            err ('Falsche Seriennummern gefunden: Datei gelîscht', FALSE);
            Remove (f);
          END;
          RETURN FALSE
        END;
        Seek (f, -2L, fromPos);
        WriteWord (f, patch [j])
      END
    END;
    Close (f);
    RETURN TRUE
  END PatchSerial;
  
  
VAR   mySer, mySerE, i: CARDINAL;
          c: CHAR;

BEGIN
  
  (* Konstanten fÅr SchlÅssel *)
  
  RegLen [1] := 17; FeedBack [1] := 7; Iterate [1] :=  39; Offs [1] := $2302;
  RegLen [2] := 16; FeedBack [2] := 3; Iterate [2] := 367; Offs [2] := $3C78;
   
  (* Default-Seriennummern im Compiler *)
  
  value [0] := $4711;  expCount [0] := 3;  lead [0] := $0641;
  value [1] := $1ADE;  expCount [1] := 1;  lead [1] := $343C;
  value [2] := $312F;  expCount [2] := 1;  lead [2] := $0240;
  
  (* Seriennummern im Compiler suchen *)
  
  WriteString ('Serialize /1.1/:  Seriennummern in Compiler eintragen ');
  WriteLn; WriteLn;
  
  WriteString ('KonsistenzprÅfung der angegebenen SchlÅssel:'); WriteLn;
  CheckSer;
  WriteString ('   ok.'); WriteLn; WriteLn;
  
  WriteString ('Suchen der Seriennummern:'); WriteLn;
  WriteString ('   '); WriteString (compname);
  WriteString (' auf DefaultPath ?'); WriteLn;
  WriteString ('   Taste drÅcken!'); WriteLn;
  Read (c);
  
  FindOffsets;
  WriteString ('   ok.'); WriteLn; WriteLn;
  
  (* neue Seriennummern eintragen *)
  
  LOOP
    WriteString ('Neue Seriennummer eintragen:'); WriteLn;
    WriteString ('   '); WriteString (compname);
    WriteString (' auf DefaultPath ?'); WriteLn;
    WriteString ('   Start eingeben (0 stoppt): ');
    ReadCard (mySer);
    IF mySer = 0 THEN EXIT END;
    WriteLn;
    WriteString ('   Ende eingeben (0 stoppt) : ');
    ReadCard (mySerE);
    IF mySerE = 0 THEN EXIT END;
    
    FOR i:= mySer TO mySerE DO
      FlushKbd;
      WriteLn;
      WriteString ('ESC stops, SPACE writes...');
      REPEAT BusyRead (c) UNTIL (c=33C) OR (c=' ');
      WriteLn;
      IF c=33C THEN EXIT END;
      IF PatchSerial (i) THEN
        WriteString ('   ok.'); WriteLn;
      END;
    END;
    WriteLn;
  END;
  
END Serialize.


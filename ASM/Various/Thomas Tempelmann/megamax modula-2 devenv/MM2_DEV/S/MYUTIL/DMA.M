MODULE DMA;
(*$Q+,G+,C-*)

(* Module Version V#052, Gdos /1.3l/, Begonnen: 19.12.85 *)
(* (c) 1985 by Frank Mersmann                            *)

(*
  08.10.90 - berÅcksichtigt nun auch DLE-Codes
  18.12.90 - kommt mit absolut definierten Vars klar
  25.05.94 - "IMPORT Bla, Fasel;" statt nur "IMPORT BlaBla;" von Gerd Castan
  28.05.94 - folgende Typdeklaration fuehrt nicht mehr zu einem Fehler:
             TYPE    BCONMAP = POINTER TO
                       RECORD
                        maptab:     POINTER TO ARRAY [0..5] OF PROC;
                        maptabsize: sINTEGER;
                       END;
             Gerd Castan -> Version 1.4
  
  HINWEISE:
   - Der Stack sollte 100 KB groû sein,
   - das Prg sollte gelinkt werden, weil sonst nicht genug Speicher bei
     2MB vorhanden ist.
   - SimpleError sollte wg. HALT-Aufrufen mitgelinkt werden
   - Die Module GEMShare, ModBase, MOSCtrl und Runtime sollten nicht geparsed
     werden, weil die Arbeit, sie zu entfernen, groû ist.
*)

(* Programm Kurzbeschreibung
   -------------------------
   
   Wer kennt nicht die folgende Situation:
   Eine bestimmte Variable oder eine bestimmte Procedure soll importiert
   werden, aber der Identifier ist nicht genau bekannt. Heisst die Variable
   nun MaxString oder MaxStr und wird sie aus Strings oder aus GdosTypes
   importiert. Hat FileOpen 3, 4 oder 5 Parameter usw.
   Dann beginnt die grosse Suchaktion in diversen Listings (hoffentlich
   richtige Version).
   
   DMA kann evtl. Abhilfe schaffen. Das Programm erzeugt eine geordnete
   Liste aller exportierten Identifier.
   
                              DMA erwartet, dass alle im System benutzten
   Module als Definition Module Textfiles (xxxx-.Text) auf dem Prefix
   Volume vorhanden sind. Nach Start merkt es sich alle Eintraege der Ex-
   portlisten und notiert, ob es sich um Const, Type, Var oder Proceduren
   handelt. Im letzten Fall wird soviel wie moeglich vom Procedureaufruf
   (Parameter) notiert. Die exportierten Identifier werden alphabetisch
   sortiert und koennen anschliessend auf dem Bildschirm, Drucker, serieller
   Schnittstelle oder dem File :DMA.Result.Text ausgegeben werden. Mit
   der so erstellten Liste reduzieren sich die Suchzeiten erheblich.
   
   
   Bemerkung 1: Das Programm enthaelt sicher noch den einen oder anderen
                Fehler, da es in grosser Eile geschrieben wurde. Fuer Hin-
                weise waere ich dankbar.
   
   Bemerkung 2: Das Programm ist nicht auf Geschwindigkeit getrimmt. Dazu
                haette man verschiedene Teile in Assembler schreiben und
                auf Rekursion verzichten muessen. Es ist aber ein gutes
                Beispiel, wie elegant man bestimmte Probleme (PutInList,
                GetSymbol) mit einer Hochsprache wie Modula-2 loesen kann.
*)

IMPORT TOSIO;

FROM Storage            IMPORT  Allocate,
                                DeAllocate,
                                memavail;
FROM Strings            IMPORT  Append,
                                DelTrailingBlanks,
                                Assign,
                                Space,
                                String,
                                Concat,
                                Copy,
                                Upper,
                                Delete,
                                StrEqual,
                                Empty,
                                Length,
                                Relation,
                                Compare;
IMPORT FastStrings;
FROM FuncStrings IMPORT UpStr;
FROM Files              IMPORT  GetStateMsg,
                                File,
                                Access,
                                State,
                                ResetState,
                                Open,
                                Close,
                                Remove,
                                Create,
                                ReplaceMode;
FROM Binary             IMPORT  FileSize,
                                ReadBytes;
FROM InOut              IMPORT  WritePg,
                                Read,
                                ReadCard,
                                WriteString,
                                WriteCard,
                                ReadString,
                                Write,
                                WriteLn;
IMPORT Text;
FROM Directory          IMPORT  DirEntry,
                                FileAttrSet,
                                DirQuery;



CONST   maxkey        = 17;
        Version       = '/1.4 Atari/';
        
        TAB = CHR (9);

TYPE    MaxStr        = ARRAY [0..127] OF CHAR;
        IdStr         = ARRAY [0..29] OF CHAR;

        tKeySize      = [0..maxkey];
        
        tSymbol       = (null, eql, comma, rparen, lparen, rbrack, lbrack,
                         lset, rset, number, ident, colon, semicolon, endid,
                         ofid, arrayid, recordid, caseid, setid, pointerid,
                         beginid, constid, enumid, typeid, varid, procid,
                         defid, modid, period, fromid, importid, expid,
                         qualid, pervid, eof);
        
        tCharsSet     = SET OF CHAR;
        
        tKeyRec       = RECORD
                          KeyWord : IdStr;
                          Symbol  : tSymbol
                        END;
        
        tKeyArray     = ARRAY tKeySize OF tKeyRec;
        
        tExIdPtr      = POINTER TO tExLiIdent;
        tExLiIdent    = RECORD
                          Ident       : IdStr;
                          UpIdent     : IdStr;
                          ModIdent    : IdStr;
                          ProcHeading : MaxStr;
                          ObjClass    : tSymbol;
                          NextId      : tExIdPtr
                        END;
        
        tBlockBuf     = ARRAY [0..511] OF WORD;

CONST   TestFlag = FALSE;        (* TRUE: gelesene Chars ausgeben *)

VAR     ok            : BOOLEAN;        (* FÅr String-Funktionsergebnisse *)
        BufInx,                         (* Index in Block Buffer *)
        i,
        ZeilCnt,
        DirInx,
        Laenge,                         (* des Input Files *)
        LastDirInx,
        RelBlk        : CARDINAL;       (* Position in Infile *)
        BufHigh       : LONGCARD;       (* Belegte Bytes in Read-Buffer *)
        GlobCh, LastCh: CHAR;           (* letzter gelesener Char aus File *)
        GetAgain      : BOOLEAN;
        DefModIdent   : IdStr;          (* Name des Definition Modules *)
        IdentBuf      : IdStr;          (* letzter gelesener Identifier *)
        NumberBuf     : String;         (* letzte gelesene Zahl(en) *)
        InFile        : File;
        GlobSym       : tSymbol;        (* letztes gelesenes Symbol *)
        ExIdRootPtr   : tExIdPtr;       (* Root^ der Liste *)
        KeyArray      : tKeyArray;      (* zu untersuchende Schluesselworte *)
        BlockBuf      : tBlockBuf;      (* Text Puffer *)
        DiEntry       : DirEntry;

CONST
    IdChars   = tCharsSet {'0'..'9', 'A'..'Z', '_', 'a'..'z', '@'};
    NumChars  = tCharsSet {'+', '-', '0'..'9', 'E', 'e'};


  PROCEDURE Init () : BOOLEAN;
  (* Einmalige Initialisierung *)
  
  VAR   ch            : CHAR;
  
  BEGIN
    WritePg;
    WriteString (Space(19));
    WriteString ('Definition Module Analyzer ');
    WriteString (Version);     Writeln;
    WriteString (Space(19));
    Writeln;
    Writeln;
    WriteString ('Create an ordered List of all exported Objects');
    Writeln;
    Writeln;
    
    KeyArray[0].KeyWord := 'DEFINITION';
    KeyArray[0].Symbol  := defid;
    KeyArray[1].KeyWord := 'MODULE';
    KeyArray[1].Symbol  := modid;
    KeyArray[2].KeyWord := 'FROM';
    KeyArray[2].Symbol  := fromid;
    KeyArray[3].KeyWord := 'IMPORT';
    KeyArray[3].Symbol  := importid;
    KeyArray[4].KeyWord := 'EXPORT';
    KeyArray[4].Symbol  := expid;
    KeyArray[5].KeyWord := 'QUALIFIED';
    KeyArray[5].Symbol  := qualid;
    KeyArray[6].KeyWord := 'CONST';
    KeyArray[6].Symbol  := constid;
    KeyArray[7].KeyWord := 'TYPE';
    KeyArray[7].Symbol  := typeid;
    KeyArray[8].KeyWord := 'VAR';
    KeyArray[8].Symbol  := varid;
    KeyArray[9].KeyWord := 'PROCEDURE';
    KeyArray[9].Symbol  := procid;
    KeyArray[10].KeyWord := 'END';
    KeyArray[10].Symbol  := endid;
    KeyArray[11].KeyWord := 'ARRAY';
    KeyArray[11].Symbol  := arrayid;
    KeyArray[12].KeyWord := 'OF';
    KeyArray[12].Symbol  := ofid;
    KeyArray[13].KeyWord := 'RECORD';
    KeyArray[13].Symbol  := recordid;
    KeyArray[14].KeyWord := 'SET';
    KeyArray[14].Symbol  := setid;
    KeyArray[15].KeyWord := 'POINTER';
    KeyArray[15].Symbol  := pointerid;
    KeyArray[16].KeyWord := 'CASE';
    KeyArray[16].Symbol  := caseid;
    KeyArray[17].KeyWord := 'PERVASIVE';
    KeyArray[17].Symbol  := pervid;
    
    ExIdRootPtr := NIL;
    RETURN TRUE
  END Init;
  
  
  PROCEDURE InitNewDefMod;
  (* Initialisierung fuer jedes neue File *)
  BEGIN
    RelBlk := 0;
    GlobCh := ' ';
    GlobSym := null;
  END InitNewDefMod;
  
  
  PROCEDURE Error (nummer:INTEGER);
  (* Nicht interessant, wenn der Compiler Def Modul uebersetzen kann *)
  VAR   s             : String;
  
  BEGIN
    IF nummer < 0 THEN
        Writeln;
        Writeln;
        WriteString ('Zeile ');
        WriteCard (ZeilCnt, 0);
        Write (':');
        Writeln;
        IF Nummer > -200 THEN
          GetStateMsg (nummer,s);
        ELSE
          WriteString ('DMA Syntax Error: ');
          CASE Nummer OF
            -200 : s := 'DEFINITION MODULE declaration expected' |
            -201 : s := 'END ident. expected' |
            -202 : s := 'Identifier expected' |
            -203 : s := '";" expected' |
            -204 : s := 'QUALIFIED expected'
          END
        END;
        
        WriteString (s);
        Writeln;
        Halt
    END
  END Error;
  
  
  PROCEDURE OpenFile (FileName : String);
  (* Erstes / naechstes Textfile oeffnen *)
  BEGIN
    Open (InFile, FileName, readOnly);
    Error (state(infile));
    Laenge:= SHORT (FileSize (InFile) DIV 1024L)
             + ORD ( SHORT (FileSize (InFile) MOD 1024L) # 0);
    WriteString ('... parsing ');
    WriteString (FileName);
    ZeilCnt:= 1;
    (*$? TestFlag:
      WriteLn;
      WriteString ('LÑnge: ');
      WriteCard (Laenge,0);
      WriteString (' Blocks');
    *)
    Writeln;
  END OpenFile;
  
  
  PROCEDURE ReadFile;
  (* Naechsten Block in Buffer einlesen *)
  BEGIN
    ReadBytes (InFile, ADR (BlockBuf), 1024, BufHigh);
    (*$? TestFlag:
      WriteLn;
      WriteString ('Read block ');
      WriteCard (relBlk,0);
      WriteString (', ');
      WriteCard (BufHigh,0);
      WriteString (' bytes.');
      WriteLn;
    *)
    Error (State (infile));
    Inc (RelBlk);
    BufInx := 0
  END ReadFile;
  
  
  PROCEDURE FindIdent (    RootPtr : tExIdPtr;
                       VAR FindPtr : tExIdPtr;
                           FindId  : IdStr) : BOOLEAN;
  (* Suche den Eintrag FindId in der Liste. Gross / klein wird
     nicht unterschieden *)
  VAR ch: CHAR;
  BEGIN
    FindPtr := RootPtr;
    Upper (FindId);
    ch:= FindId [0];
    LOOP
      IF FindPtr = NIL THEN RETURN FALSE END;
      IF FindPtr^.UpIdent[0] = ch THEN
        IF Compare (FindPtr^.UpIdent, FindId) = equal THEN
          RETURN TRUE
        END
      END;
      FindPtr := FindPtr^.NextId
    END;
  END FindIdent;
  
  
  PROCEDURE List;
  (* Sortierte Liste auf verschiednen Units ausgeben *)
  VAR   i, width, mwidth, lines: CARDINAL;
        ch, tch       : CHAR;
        tabs          : BOOLEAN;
        OutName       : String;
        OutStr        : MaxStr;
        outf          : File;
        ListPtr       : tExIdPtr;
        
  BEGIN
    REPEAT
      Writeln;
      WriteString ('Select Unit for ordered List');
      Writeln;
      Writeln;
      WriteString ('C)RT,  F)ile,  P)rinter,  S)erial,  Q)uit ?');
      Read (ch);
      Writeln;
      
      CASE Cap (ch) OF
        'F' : WriteString ('Filename? ');
              ReadString (OutName);
              Writeln |
        'P' : OutName := 'PRN:' |
        'Q' : |
        'S' : OutName := 'AUX:'|
      ELSE
        OutName := 'CON:'
      END;
      
      IF Cap (ch) # 'Q' THEN

        Writeln;
        WriteString ('Separate lines by TABs? (Y/n) ');
        Read (tch);
        tabs:= CAP (tch) # 'N';
        Writeln;
        
        WriteString ('Lines per side/screen? (0 means no FF) ');
        ReadCard (lines);
        
        WriteString ('Max length of lines? (0 means infinite) ');
        ReadCard (width);
        Writeln;

        Create (outf, OutName, writeSeqTxt, replaceOld);
        
        (*
         * Zuerst einmal die Breite der Modulnamen bestimmen
         *)
        IF NOT tabs THEN
          ListPtr := ExIdRootPtr;
          mwidth:= 0;
          WHILE ListPtr # NIL DO
            IF mwidth < Length (ListPtr^.ModIdent) THEN
              mwidth:= Length (ListPtr^.ModIdent);
            END;
            ListPtr := ListPtr^.NextId
          END;
        END;
        INC (mwidth);
        IF width > 0 THEN
          DEC (width, mwidth + 2);
        ELSE
          width:= MAX (CARDINAL)
        END;
        
        i:= 0;
        ListPtr := ExIdRootPtr;
        WHILE ListPtr # NIL DO
          Assign (ListPtr^.ModIdent, OutStr, ok);
          Text.WriteString (outf, OutStr);
          IF tabs THEN
            Text.Write (outf, TAB)
          ELSE
            Text.WriteString (outf, Space (mwidth - Length (outStr)));
          END;
          IF ListPtr^.ObjClass = procid THEN
            Text.WriteString (outf, 'P');
            IF tabs THEN Text.Write (outf, TAB) ELSE Text.Write (outf, ' '); END;
            IF Length (ListPtr^.ProcHeading) > width THEN
              FastStrings.Copy (ListPtr^.ProcHeading, 0, width-2, OutStr);
              Append ('..', OutStr, ok)
            ELSE
              Assign (ListPtr^.ProcHeading, OutStr, ok)
            END;
            Text.WriteString (outf, OutStr)
          ELSE
            CASE ListPtr^.ObjClass OF
              constid : Text.Write (outf, 'C') |
              enumid  : Text.Write (outf, 'E') |
              typeid  : Text.Write (outf, 'T') |
              varid   : Text.Write (outf, 'V')
            ELSE
              Text.Write (outf, '?')
            END;
            IF tabs THEN Text.Write (outf, TAB) ELSE Text.Write (outf, ' '); END;
            Text.WriteString (outf, ListPtr^.Ident)
          END;
          Text.Writeln (outf);
          Inc (i);
          
          CASE Cap (ch) OF
            'C' : IF (lines > 0) & (i MOD lines = 0) THEN
                    Text.Writeln (outf);
                    Text.WriteString (outf, 'type /SPACE/ to continue');
                    Read (globch);
                    Text.Writeln (outf);
                    Text.Writeln (outf)
                  END |
            'F' : |
            'P' : IF (lines > 0) & (i MOD lines = 0) THEN Text.Write (outf, 12C) END
          ELSE
          END;
          
          ListPtr := ListPtr^.NextId
        END;
        Close (outf)
      END
    UNTIL Cap (ch) = 'Q';
  END List;
  
  
  
  (* ++++++++++ Die folgenden Proceduren gehoeren zum Scanner ++++++++++ *)
  
  PROCEDURE GetChar;
  (*$L-*)
  (* naechstes Zeichen aus Textbuffer einlesen. "Besonderheiten" des Editors
     und alte UCSD-File-Nullen beruecksichtigen.
  *)
    PROCEDURE GetC;
    BEGIN
    ASSEMBLER
    STARTGETC   LEA     BlockBuf,A0             ;^ auf Char Buffer *)
                MOVE.W  BufInx,D0               ;Offset in Char Buffer
                CLR.W   D1
                MOVE.B  00(A0,D0.W),D1
                ADDQ.W  #01,D0                  ;Index erhoehen
                MOVE.W  D0,BufInx               ;Index wieder ablegen
                MOVE.L  BufHigh,D2
                CMP.W   D2,D0                   ;kein Zeichen mehr da?
                BCS     ZEICHENDA
                MOVEM.W D0-D1,-(A7)
                JSR     ReadFile                ;naechsten 1024 Zeichen
                MOVEM.W (A7)+,D0-D1
      ZEICHENDA
    END
    END GetC;
    
  BEGIN
  ASSEMBLER
                TST     GetAgain
                BEQ     START
                CLR     GetAgain
                MOVE.B  LastCh,GlobCh
                BRA     ende
  START         BSR     GetC
                TST.B   D1                      ;00 gelesen ?
                BEQ.S   MAKEBLANK
                CMP.B   #16,D1                  ;<DLE> gelesen ?
                BEQ.S   isdle
                CMP.B   #$0D,D1                 ;<CR> gelesen ?
                BEQ.S   zeile
                CMP.B   #$0A,D1                 ;<CR> gelesen ?
                BNE.S   KEINCRORDLE
                BRA.S   MAKEBLANK               ;nur bei CR ZeilCnt erhîhen
  isdle         BSR     GetC
                BRA.S   MAKEBLANK
  zeile         ADDQ    #1,ZeilCnt
  MAKEBLANK     MOVE.B  #' ',D1                 ;durch Blank ersetzen
  KEINCRORDLE   MOVE.B  D1,GlobCh               ;1 Char transferieren
                MOVE.B  D1,LastCh
  ende
  END;
    (*$? TestFlag: Write (GlobCh) *)
  END GetChar;
  (*$L=*)
  
  
  PROCEDURE Identifier;
  (* Identifier zusammenbauen und pruefen, ob Keywort *)
  VAR   Match         : BOOLEAN;
        i             : CARDINAL;
  
  BEGIN
    IdentBuf := '';
    REPEAT
      FastStrings.Append (GlobCh, IdentBuf);
      GetChar
    UNTIL NOT (GlobCh IN IdChars);

    i := 0;     Match := FALSE;
    REPEAT
      Match := StrEqual(IdentBuf, KeyArray[i].KeyWord);
      Inc (i)
    UNTIL Match OR (i > maxkey);
    
    IF Match
      THEN GlobSym := KeyArray[i-1].Symbol
      ELSE GlobSym := ident
    END
  END Identifier;
  
  
  PROCEDURE Numbers;
  (* Nummern zusammenbauen *)
  BEGIN
    NumberBuf := '';    GlobSym := number;
    REPEAT
      FastStrings.Append (GlobCh, NumberBuf);
      GetChar
    UNTIL NOT (GlobCh IN NumChars)
  END Numbers;
  
  
  PROCEDURE Comment;
  (* Eleminiert auch verschachtelte Kommentare *)
  BEGIN
    REPEAT
      WHILE GlobCh # '*' DO
        IF GlobCh = '(' THEN
          GetChar;
          IF GlobCh = '*' THEN Comment END
        ELSE
          GetChar
        END
      END;
      GetChar
    UNTIL GlobCh = ')';
    GetChar
  END Comment;
    
    
  PROCEDURE GetSymbol;
  (* naechstes Symbol erkennen *)
  BEGIN
    LOOP        (* Schrott eleminieren *)
      CASE GlobCh OF
        0C         : IF RelBlk > Laenge
                       THEN GlobCh := ' ';   EXIT
                       ELSE GetChar
                     END |
        1C..' '    : GetChar |
      ELSE
        EXIT
      END
    END;  (* loop *)
    
    CASE GlobCh OF
      ' '      : GlobSym := eof;        GlobCh := 0C |
      '!'      : GlobSym := null;       GetChar |
      '"'      : GlobSym := null;       GetChar |  (* ; *)
      '$'      : Globsym := null;       GetChar |
      '%'      : Globsym := null;       GetChar |
      '&'      : Globsym := null;       GetChar |
      "'"      : Globsym := null;       GetChar |
      '('      : GetChar;
                 IF GlobCh = '*'
                   THEN Comment;        GetSymbol
                   ELSE GlobSym := lparen
                 END|
      ')'      : GlobSym := rparen;     GetChar |
      ','      : GlobSym := comma;      GetChar |
      '.'      : GlobSym := period;     GetChar |
      '0'..'9' : Numbers |
      ':'      : GlobSym := colon;      GetChar |
      ';'      : GlobSym := semicolon;  GetChar |
      '='      : GlobSym := eql;        GetChar |
      '_'      : Identifier |
      '@'      : Identifier |
      'A'..'Z' : Identifier |
      '['      : GlobSym := lbrack;     GetChar |
      ']'      : GlobSym := rbrack;     GetChar |
      'a'..'z' : Identifier |
      '{'      : GlobSym := lset;       GetChar |
      '|'      : GlobSym := null;       GetChar |
      '}'      : GlobSym := rset;       GetChar |
      '~'      : GlobSym := null;       GetChar
    ELSE
                 Globsym := null;       GetChar
    END
  END GetSymbol;
  
  
  
  (* ++++++++++ Die folgenden Proceduren gehoeren zum Parser ++++++++++ *)
  
  
  PROCEDURE Insert (VAR RootP : tExIdPtr; VAR NewP : tExIdPtr);
  (* Do it, but do it recursive *)
  BEGIN
    IF RootP = NIL THEN
      RootP := NewP
    ELSIF less = Compare (RootP^.UpIdent, NewP^.UpIdent) THEN
      Insert (RootP^.NextId, NewP)
    ELSE
      NewP^.NextId := RootP;
      RootP := NewP
    END
  END Insert;

  PROCEDURE PutInList;
  (* neuen Identifier in Liste einfuegen *)
  VAR   NewPtr        : tExIdPtr;

  BEGIN
    New (NewPtr);
    IF NewPtr = NIL THEN
      WriteString ('Out of memory!');
      WriteLn;
      HALT
    END;
    WITH NewPtr^ DO
      Ident := IdentBuf;
      UpIdent := Ident;
      Upper (UpIdent);
      ModIdent := DefModIdent;
      ObjClass := null;
      NextId := NIL
    END;
    Insert (ExIdRootPtr, NewPtr)
  END PutInList;
  
  
  PROCEDURE ConstDecl;
  (* CONST - Deklarationen bearbeiten *)
  VAR   FindPtr       : tExIdPtr;
  
  BEGIN
    IF GlobSym = ident
      THEN
        WHILE GlobSym = ident DO
          PutInList;
          IF FindIdent (ExIdRootPtr, FindPtr, IdentBuf)
            THEN FindPtr^.ObjClass := constid
          END;
          REPEAT GetSymbol UNTIL GlobSym = semicolon;
          GetSymbol
        END  (* while *)
      ELSE Error (-202)
    END
  END ConstDecl;
  
  VAR   TypeName      : IdStr;  (* Name des aktuellen Typs *)
  
  PROCEDURE Types;
  VAR   FindPtr       : tExIdPtr;
  BEGIN
    CASE GlobSym OF
      lparen    : (* AufzÑhlungstyp *)
                  GetSymbol;
                  IF GlobSym = ident
                    THEN
                      WHILE GlobSym = ident DO
                        Append (' - ', IdentBuf, ok);
                        FastStrings.Append (TypeName, IdentBuf);
                        PutInList;
                        IF FindIdent (ExIdRootPtr, FindPtr, IdentBuf)
                          THEN FindPtr^.ObjClass := enumid
                        END;
                        REPEAT GetSymbol UNTIL (GlobSym = comma) OR
                                               (GlobSym = rparen);
                        GetSymbol
                      END  (* while *)
                    ELSE Error (-202)
                  END|
      ident     : |
      arrayid   : WHILE GlobSym # ofid DO GetSymbol END;  GetSymbol; Types; |
      caseid,
      recordid  : WHILE GlobSym # endid DO
                    GetSymbol;
                    IF (GlobSym = recordid) OR (GlobSym = caseid) THEN
                      Types
                    END
                  END;
                  GetSymbol |
      setid     : |
      pointerid : GetSymbol;      (* TO; Gerd Castan 28.05.94 *)
                  GetSymbol;
                  Types; |
      procid    : IF GlobCh = '(' THEN
                    WHILE GlobSym # rparen DO GetSymbol END
                  END
    ELSE
    END;
    (* semicolon ueberlesen: *)
    WHILE (GlobSym # semicolon) & (GlobSym # endid) DO GetSymbol END
  END Types;
  
  
  PROCEDURE TypeDecl;
  (* TYPE - Deklarationen bearbeiten *)
  VAR   FindPtr       : tExIdPtr;
  
  BEGIN
    IF GlobSym = ident
      THEN
        WHILE GlobSym = ident DO
          PutInList;
          IF FindIdent (ExIdRootPtr, FindPtr, IdentBuf)
            THEN FindPtr^.ObjClass := typeid;
            TypeName := IdentBuf; (* Namen dieses Typs merken *)
          END;
          GetSymbol;
          IF GlobSym = eql THEN GetSymbol; Types END;
          GetSymbol
        END   (* while *)
      ELSE Error (-202)
    END
  END TypeDecl;
  
  
  PROCEDURE VarDecl;
  (* VAR - Deklarationen bearbeiten *)
  VAR   FindPtr       : tExIdPtr;
  
  BEGIN
    IF GlobSym = ident THEN
      WHILE GlobSym = ident DO
        PutInList;
        IF FindIdent (ExIdRootPtr, FindPtr, IdentBuf) THEN
          FindPtr^.ObjClass := varid
        END;
        GetSymbol;
        IF GlobSym = lbrack THEN
          REPEAT
            GetSymbol;
          UNTIL GlobSym = rbrack;
          GetSymbol;
        END;
        IF GlobSym = colon THEN GetSymbol; Types END;
        GetSymbol
      END  (* while *)
    ELSE
      Error (-202)
    END
  END VarDecl;
  
  PROCEDURE ProcDecl;
  (* PROC - Deklarationen bearbeiten *)
  VAR   ProcBuf       : MaxStr;
        FindPtr       : tExIdPtr;
  
    PROCEDURE MyAppend;
    VAR spc: BOOLEAN;
    BEGIN
      WHILE GlobCh = ' ' DO GetChar END; (* fÅhrende Leerz. weg *)
      spc:= TRUE;
      LOOP
        CASE GlobCh OF
          ' ' : (* nur ein Leerz. lassen wir zu *)
                IF NOT spc THEN
                  Append (' ', ProcBuf, ok);
                  spc:= TRUE
                END;
                GetChar|
          '(' : GetChar;
                IF GlobCh = '*' THEN
                  Comment
                ELSE
                  GetAgain:= TRUE;
                  GlobCh:= '(';
                  spc:= FALSE;
                  EXIT
                END|
          (*IdChars:*)
          '0'..'9', 'A'..'Z', '_', 'a'..'z', '@':
                spc:= FALSE;
                Append (GlobCh, ProcBuf, ok);
                GetChar
        ELSE
          EXIT
        END;
      END;
      IF spc THEN
        DelTrailingBlanks (ProcBuf);
      END
    END MyAppend;
    
    
  BEGIN  (* of ProcDecl *)
    IF GlobSym = ident THEN
      Assign (IdentBuf, ProcBuf, ok);
      
      WHILE (GlobCh # '(') AND (GlobCh # ';') DO MyAppend END;
      
      IF GlobCh ='(' THEN
        GetChar;
        Append (' (', ProcBuf, ok); (* Ein Leerz. vor '(' einsetzen *)
        LOOP
          MyAppend;
          Append (GlobCh, ProcBuf, ok);
          IF (GlobCh = ':') OR (GlobCh = ';') THEN
            Append (' ', ProcBuf, ok);
          ELSIF GlobCh = ')' THEN
            EXIT
          END;
          GetChar
        END;
        GetChar;
        LOOP
          MyAppend;
          Append (GlobCh, ProcBuf, ok);
          IF (GlobCh = ':') THEN
            Append (' ', ProcBuf, ok);
          END;
          IF GlobCh = ';' THEN EXIT END;
          GetChar
        END;
      END;
      
      PutInList;
      IF FindIdent (ExIdRootPtr, FindPtr, IdentBuf) THEN
        FindPtr^.ObjClass := procid;
        FindPtr^.ProcHeading := ProcBuf
      END;
      GetSymbol;
      GetSymbol
    ELSE
      Error (-202)
    END
  END ProcDecl;
  
  
  PROCEDURE Block;
  
  VAR   NoMatch       : BOOLEAN;
  
  BEGIN
    NoMatch := FALSE;
    
    REPEAT
      CASE GlobSym OF
        constid : GetSymbol;    ConstDecl |
        typeid  : GetSymbol;    TypeDecl |
        varid   : GetSymbol;    VarDecl |
        procid  : GetSymbol;    ProcDecl
      ELSE
        NoMatch := TRUE
      END
    UNTIL (GlobSym = endid) OR NoMatch
  END Block;
  
  
  PROCEDURE ImportHdl;
  (* Importliste ueberlesen *)
  BEGIN
    WHILE (GlobSym = fromid) OR (GlobSym = importid) DO
      IF GlobSym = importid THEN
        (* IMPORT Bla, Fasel; Gerd Castan 25.05.94 *)
        (* lies "ident", "," nach "IMPORT" *)
        WHILE GlobSym # semicolon DO GetSymbol END;
        GetSymbol;
        
        (* Original:
        (* IMPORT BlaBla; *)
        GetSymbol;
        IF GlobSym # ident THEN Error (-202)
        ELSE
          GetSymbol;
          IF GlobSym # semicolon THEN Error (-202) END;
          GetSymbol
        END
        *)
      ELSE
        (* FROM DingsDa IMPORT Bla, BlaBla...; *)
        GetSymbol;                          (* lies "Ident" nach "FROM" *)
        IF GlobSym = ident
          THEN
            GetSymbol;                      (* lies "IMPORT" *)
            IF GlobSym = importid
              THEN              (* lies "ident", "," nach "IMPORT" *)
                WHILE GlobSym # semicolon DO GetSymbol END;
                GetSymbol;
            END
          ELSE Error (-202)
        END  (* IF GlobSym = ident *)
      END  (* IF ... ELSE *)
    END (* WHILE *)
  END ImportHdl;
  
  
  
  PROCEDURE QualIdents;
  BEGIN
    WHILE GlobSym # semicolon DO
      (* Exportliste nicht in die Liste aufnehmen
        PutInList;
      *)
      GetSymbol;
      IF GlobSym = comma THEN GetSymbol END
    END;
    GetSymbol
  END QualIdents;
  
  
  PROCEDURE ExportHdl;
  BEGIN
    GetSymbol;                          (* lies "QUALIFIED" oder "Ident" *)
    IF GlobSym = qualid THEN GetSymbol END;  (* "ident" nach "QUALIFIED" *)
    IF GlobSym = pervid THEN GetSymbol END;  (* "ident" nach "PERVASIVE" *)
    QualIdents;
    IF GlobSym = expid THEN ExportHdl END
  END ExportHdl;
  
  
  PROCEDURE DefModule;
  BEGIN
    IF GlobSym = defid
      THEN
        GetSymbol;                      (* lies "MODULE" *)
        IF GlobSym = modid
          THEN
            GetSymbol;                  (* lies "Ident" nach "MODULE" *)
            IF GlobSym = ident
              THEN                      (* save "Ident" fuer spaeter *)
                DefModIdent := IdentBuf;
                GetSymbol;
                IF GlobSym = semicolon THEN
                  GetSymbol;
                  IF (GlobSym = fromid) OR
                     (GlobSym = importid ) THEN ImportHdl END;
                  IF GlobSym = expid THEN
                    WriteString ('Exportliste wird ignoriert!');
                    WriteLn;
                    ExportHdl
                  END;
                  Block;
                  IF GlobSym = endid THEN
                    GetSymbol;             (* lies Module "Ident" *)
                    IF (GlobSym = ident) AND
                      StrEqual (UpStr (DefModIdent), UpStr (IdentBuf))
                    THEN
                      GetSymbol;
                      IF GlobSym # period THEN Error (-201) END
                    ELSE
                      Error (-201)
                    END
                  ELSE
                    Error (-201)
                  END
                ELSE
                  Error (-203)
                END
              ELSE Error (-200)
            END
          ELSE Error (-200)
        END
      ELSE Error (-200)
    END
  END DefModule;
  
  
  PROCEDURE Parse;
  BEGIN
    GetSymbol;
    DefModule;
  END Parse;
  

PROCEDURE parsefile (REF p:ARRAY OF CHAR; d: DirEntry): BOOLEAN;
  VAR s:String;
  BEGIN
    InitNewDefMod;
    Concat (p,d.name,s,ok);
    OpenFile (s);
    ReadFile;
    Parse;
    Close (InFile);
    RETURN TRUE
  END parseFile;

VAR result: INTEGER; path: STRING;

BEGIN   (* of DMA *)
  IF Init () THEN
    LOOP
      Writeln;
      WriteString ('Filename (with wildcards): ');
      ReadString (path);
      IF Empty (path) THEN EXIT END;
      Writeln;
      DirQuery (path, FileAttrSet {}, parseFile, result)
    END;
    List
  END
END DMA.

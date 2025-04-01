IMPLEMENTATION MODULE DicBase; (* SYSTEM:  Megamax Modula-2, 2.2 *)

FROM EasyGEM0   IMPORT  FormAlert;
FROM PrgCtrl    IMPORT  TermProcess;
FROM SYSTEM     IMPORT  TSIZE, ADDRESS, ADR;
FROM Storage    IMPORT  ALLOCATE, DEALLOCATE;
FROM Binary     IMPORT  WriteBytes, ReadBytes, FileSize;
FROM Directory  IMPORT  SplitPath, PathExists, CreateDir;
FROM Strings    IMPORT  Length, Compare, Relation, String, Concat, Assign;
FROM Files      IMPORT  File, Access, Open, Close, Create, State,
                        GetStateMsg, ReplaceMode;
FROM MOSGlobals IMPORT  PathStr, FileStr, fReadFault, GeneralErr,
                        OutOfMemory;
                        
CONST lmax = 200;
      endBut  = '][Abbruch]';
      sign    = '[1][';
      fail         = ' failed';
      concStr      = 'Conc failed';
      fileToMemStr = 'FileToMem failed';
      openStr      = 'Open failed';
      closeStr     = 'Close failed';
      createStr    = 'Create ';
      makePathStr  = 'MakePath ';
      
TYPE  LString = ARRAY [0..lmax] OF CHAR;


PROCEDURE allocate (VAR adr: ADDRESS; n: LONGCARD);
  BEGIN
    ALLOCATE (adr, n); Check (adr = NIL, OutOfMemory, '');
  END allocate;

PROCEDURE NthPos (c: CHAR; VAR s: ARRAY OF CHAR; n: CARDINAL): CARDINAL;

(*  Sucht nach n-maligem auftreten von 'c' in dem String 's'.
 *  Bei Erfolg wird die n.te Position zurÅckgegeben, ansonsten 0.
 *)
   
  VAR nth, i : CARDINAL;
  BEGIN
    nth := 0;
    FOR i := 0 TO Length (s)-1 DO
      IF s[i] = c THEN INC (nth); END;
      IF n = nth THEN RETURN i; END;
    END;
    RETURN 0;
  END NthPos;
  
PROCEDURE Conc3 (s1, s2, s3: ARRAY OF CHAR): LString;
  VAR s   : LString;
      scs : BOOLEAN;
  BEGIN
    Concat (s1, s2, s, scs); Check (~scs, 0, concStr);
    Concat (s, s3, s, scs);  Check (~scs, 0, concStr);
    RETURN s;
  END Conc3;

PROCEDURE Conc5 (s1, s2, s3, s4, s5: ARRAY OF CHAR): LString;
  BEGIN
    RETURN Conc3 (Conc3 (s1,s2,s3),s4,s5);
  END Conc5;

PROCEDURE Check (err: BOOLEAN; errNo: INTEGER; txt: ARRAY OF CHAR);
  VAR errMsg: String;
  BEGIN
    IF err THEN
      errMsg := '';
      IF errNo < 0 THEN GetStateMsg (errNo, errMsg); END;
      FormAlert (1, Conc5 (sign, txt, '|', errMsg, endBut), voidC);
      TermProcess (errNo);
    END;
  END Check;

PROCEDURE inc (c: CHAR): CHAR;
  BEGIN
    INC (c); RETURN c;
  END inc;

PROCEDURE CardToMem (x: CARDINAL; adr: ADDRESS);
  BEGIN
    ByteCopy (ADR (x), CardSize, adr);
  END CardToMem;

PROCEDURE MemToCard (adr: ADDRESS): CARDINAL;
  VAR x: CARDINAL;
  BEGIN
    ByteCopy (adr, AdrSize, ADR (x)); RETURN x;
  END MemToCard;

PROCEDURE cmp (a, b: CPtr): Relation;
  BEGIN
    LOOP
      IF    a^ < b^ THEN  RETURN  less;         (* nur C-Strings *)
      ELSIF a^ > b^ THEN  RETURN  greater;
      ELSIF a^ = 0C THEN  RETURN  equal;  END;
      INC (a); INC (b);
    END;
  END cmp;
  
PROCEDURE MakePath (VAR path: ARRAY OF CHAR);

(*  Diese Prozedur erzeugt, falls noch nicht vorhanden 'path' *)
  
  VAR part   : String;
      lpath  : String;
      res    : INTEGER;
      i, pos : CARDINAL;
      
  BEGIN
    SplitPath (path, lpath, voidS);
    IF NOT PathExists (lpath) THEN
      i := 1;
      REPEAT
        INC (i);
        Assign (lpath, part, voidO);
        pos := NthPos ('\', lpath, i);
        IF pos > 0 THEN
          part[pos+1] := 0C;
          IF ~PathExists (part) THEN
            part[pos] := 0C;
            CreateDir (part, res);
            Check (res # 0, res, Conc3 (makePathStr, lpath, fail));
          END;
        END;
      UNTIL Compare (part, lpath) = equal;
    END;
  END MakePath;
  
PROCEDURE open (VAR f: File; VAR fn: ARRAY OF CHAR; mode: Access);
  BEGIN
    Open (f, fn, mode);
    Check (State (f) # 0, State (f), Conc3 ('Open ', fn, fail));
  END open;

PROCEDURE create (VAR  f  : File;
                  VAR fn  : ARRAY OF CHAR;
                       m  : Access;
                      rpm : ReplaceMode);
  
  BEGIN
    MakePath (fn);
    Create (f, fn, m, rpm);
    Check (State (f) # 0, State (f), Conc3 (createStr, fn, fail));
  END create;
  
PROCEDURE close (VAR f: File);
  BEGIN
    Close (f); Check (State (f) # 0, State (f), closeStr);
  END close;

PROCEDURE FileToMem (VAR fn: ARRAY OF CHAR;
                     VAR adr: ADDRESS; VAR n: LONGCARD);
  
  VAR bytesRead : LONGCARD;
      f         : File;
      
  BEGIN
    open (f, fn, readOnly);
    IF adr = NIL THEN
      n := FileSize (f);
      allocate (adr, n);
    ELSE
      Check (n < FileSize (f), OutOfMemory, fileToMemStr);
    END;
    ReadBytes (f, adr, n, bytesRead);
    Check (n # bytesRead, fReadFault, fileToMemStr);
    close (f);
  END FileToMem;
                        
PROCEDURE MemToFile (VAR fn: ARRAY OF CHAR; adr: ADDRESS; n: LONGCARD);

  VAR f   : File;
      res : INTEGER;
  BEGIN
    create (f, fn, readWrite, replaceOld);
    WriteBytes (f, adr, n);
    Check (res # 0, res, Conc3 ('MemToFile ', fn, fail));
    close (f);
  END MemToFile;

PROCEDURE FILESIZE (VAR fn: ARRAY OF CHAR): LONGCARD;
  
  VAR size : LONGCARD;
      f    : File;
  BEGIN
    open (f, fn, readOnly); size := FileSize (f); close (f);
    RETURN size;
  END FILESIZE;

(*$L-*)
PROCEDURE ByteCopy (from: ADDRESS; n: CARDINAL; to: ADDRESS);
  BEGIN
    ASSEMBLER
         MOVE.L  -(A3),A1       ; A1 := to
         MOVE.W  -(A3),D0       ; D0 := n
         MOVE.L  -(A3),A0       ; A0 := from
         BRA     start
copy     MOVE.B  (A0)+,(A1)+
start    DBF     D0, copy
    END;
  END ByteCopy;
(*$L=*)

END DicBase.
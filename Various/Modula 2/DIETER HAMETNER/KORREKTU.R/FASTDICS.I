IMPLEMENTATION MODULE FastDics; (* Megamax Modula-2, 2.2 *)
 
 (* StrTab: ARRAY in dem Nullterminierte Strings und deren Positionen im Dic
  *         gespeichert werden.
  *
  *             +---------------------------------+
  *             | [CHAR,...,CHAR] [0C] [LONGCARD] |
  *             +---------------------------------+
  *             | [CHAR,...,CHAR] [0C] [LONGCARD] |
  *             +---------------------------------+
  * Bottom *--> | ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ |
  *
  *             | ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ |
  *             +---------------------------------+
  *)
  
FROM SysUtil0   IMPORT  ClearVar;
FROM Storage    IMPORT  DEALLOCATE;
FROM SYSTEM     IMPORT  ADR, ADDRESS;
FROM Strings    IMPORT  Length, String, Relation;
FROM XInOut     IMPORT  WriteS, WriteSSL, WriteLn, WriteSSSL;
FROM DicBase    IMPORT  AdrSize, voidO, Check, allocate, SPtr,
                        CPtr, ByteCopy;

CONST minLen = 354L;           insFailST = 'Insert failed STab overflow';
      wLen   = 25L;            insFailPT = 'Insert failed PTab overflow';
      lowers = 59;
      
PROCEDURE Insert (VAR fd: FastDic; VAR zstr: ARRAY OF CHAR; pos: LONGCARD);
  VAR l: CARDINAL;
  BEGIN
    WITH fd DO
      l := Length (zstr) + 1;
      Check (akt_STab + ADDRESS (LONG (l)) > max_STab, 0, insFailST);
      Check (akt_PTab > max_PTab, 0, insFailPT);
      PTab^ [akt_PTab] := SPtr (akt_STab);     INC (akt_PTab);
      PTab^ [akt_PTab] := SPtr (akt_STab);
      ByteCopy (ADR (zstr), l,    akt_STab);  INC (akt_STab, l);
      ByteCopy (ADR (pos), AdrSize, akt_STab);  INC (akt_STab, AdrSize);
    END;
  END Insert;

PROCEDURE cmp (a: CPtr; b: CPtr; VAR found: SPtr): Relation;
  VAR old: SPtr;                           (* kleineres Element merken *)
  BEGIN
    old := SPtr (b);
    LOOP
      IF    (a^ < b^) THEN                 RETURN less;
      ELSIF (a^ > b^) THEN  found := old;  RETURN greater;
      ELSIF (a^ = 0C) THEN                 RETURN equal;  END;
      INC (a); INC (b);
    END;
  END cmp;

PROCEDURE GetPos (fd: FastDic; VAR zstr: ARRAY OF CHAR; VAR pos: LONGCARD);

(*  Vorbedingung: mind. ein Element existiert das <= 'zstr' ist.
 *  Der Rest ist bin„re Suche auf einem sortierten Array
 *)

  VAR j,k,l,i: INTEGER;
      found  : SPtr;
  BEGIN
    i := 0; j := fd.akt_PTab - 1;
    REPEAT
      k := (i + j) DIV 2;
      CASE cmp (ADR (zstr), CPtr (fd.PTab^ [k]), found) OF
        less    : j := k - 1;
      | equal   : pos := MAX (LONGCARD); RETURN;
      | greater : i := k + 1;
      END;
    UNTIL i > j;
    l := Length (found^) + 1;
    ByteCopy (found, l, ADR (zstr)); INC (found, l);
    ByteCopy (found, AdrSize, ADR (pos));
  END GetPos;
  
PROCEDURE CreateFastDic (VAR fd: FastDic; every: CARDINAL;
                         words: LONGCARD): BOOLEAN;
  VAR n: CARDINAL;
  BEGIN
    n := SHORT (words DIV LONG (every));
    WITH fd DO
      akt_PTab := 0;  max_PTab := (n + lowers);
      allocate (PTab, max_PTab * AdrSize);
      allocate (STab, minLen + wLen * LONG (n));
      akt_STab := STab;  max_STab := STab;
      INC (max_STab, minLen + wLen * LONG (n));
    END;
    RETURN TRUE;
  END CreateFastDic;

PROCEDURE CloseFastDic (VAR fd: FastDic);
  BEGIN
    WITH fd DO
      DEALLOCATE (PTab, (max_PTab - akt_PTab) * AdrSize);
      max_PTab := akt_PTab;
      DEALLOCATE (STab, (LONGCARD (max_STab) - LONGCARD(akt_STab)));
      max_STab := akt_STab;
    END;
  END CloseFastDic;
  
PROCEDURE ReleaseFastDic (VAR fd: FastDic);
  BEGIN
    DEALLOCATE (fd.PTab, 0);  DEALLOCATE (fd.STab, 0);
    ClearVar (fd);
  END ReleaseFastDic;
END FastDics.
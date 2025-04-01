IMPLEMENTATION MODULE Dics; (* Megamax Modula-2, 2.2 *)
 
(* Format eines Dictionarys: (Regul„rer Ausdruck)
 *
 *   Dictionary    ::= [offset, coded Strings]*
 *   coded strings ::= 0C, x, [delta CHAR*]*,  x aus {y|IsLower (x)}
 *   delta (a[0..n], b[0..m]) ist das minimale i, mit a[i] # b[i].
 *)
 
FROM SysUtil0   IMPORT  ClearVar;
FROM Block      IMPORT  Clear, Copy;
FROM Characters IMPORT  IsAlpha, IsLower;
FROM SYSTEM     IMPORT  ADDRESS, ADR;
FROM MOSGlobals IMPORT  OutOfMemory, FileStr;
FROM Storage    IMPORT  Enlarge, ALLOCATE, DEALLOCATE;
FROM Strings    IMPORT  Assign, Relation, Lower, Length, String;
FROM FastDics   IMPORT  FastDic, CreateFastDic, CloseFastDic, Insert,
                        GetPos;
FROM DicBase    IMPORT  FileToMem, MemToFile, ByteCopy, Check, cmp, inc,
                        CardSize, voidO, CPtr, FILESIZE, allocate;

CONST startChar = 'a';   fail = ' failed';
      MinSize   = 236L;
      enoughMemStr = 'enoughMem failed';
      
TYPE  Dic_Rec = RECORD
                   every : CARDINAL;
                   tree  : FastDic;
                   dic   : POINTER TO ARRAY [0L..100L*100L*100L] OF CHAR;
                   size, max, step : LONGCARD;
                   OffsetTable   : ARRAY [0C..377C] OF LONGCARD;
                 END;
                     
        Dic = POINTER TO Dic_Rec;
        
        strRec = RECORD
                   Str       : String;
                   Len, RLen : CARDINAL;
                   StartPos  : LONGCARD;
                 END;
                 
        strTab = ARRAY [0..2] OF strRec;
        
        moveRec = RECORD
                    ReadPos, MaxPos      : LONGCARD;
                    vorIx, aktIx, nachIx : CARDINAL;
                    StrTab               : strTab;
                  END;
        
        TYPE Zustand = (zahl,char);

PROCEDURE DicAdr (d: Dic; i: LONGCARD): CPtr;
  BEGIN
    RETURN CPtr (ADR (d^.dic^ [i]));
  END DicAdr;
  
PROCEDURE CardToMem (card: CARDINAL; adr: ADDRESS);
  BEGIN
    ByteCopy (ADR (card), CardSize, adr);
  END CardToMem;

PROCEDURE MemToCard (adr: ADDRESS): CARDINAL;
  VAR card: CARDINAL;
  BEGIN
    ByteCopy (adr, CardSize, ADR (card));
    RETURN card;
  END MemToCard;

PROCEDURE Get_Index_Adr (d: Dic; i: LONGCARD): CPtr;
  BEGIN
    RETURN ADR (d^.dic^ [i]);
  END Get_Index_Adr;
  
PROCEDURE Get_Offset_Adr (d: Dic; c: CHAR): ADDRESS;
  BEGIN
    RETURN ADR (d^.dic^ [d^.OffsetTable [c]]);
  END Get_Offset_Adr;
  
PROCEDURE Get_Offset_Pos (d: Dic; c: CHAR): LONGCARD;
  BEGIN
    RETURN d^.OffsetTable [c];
  END Get_Offset_Pos;
  
PROCEDURE Get_0CHAR_Pos (d: Dic; c: CHAR): LONGCARD;
  BEGIN
    RETURN d^.OffsetTable [c] + 2L;
  END Get_0CHAR_Pos;
  
PROCEDURE Get_Word_Pos (d: Dic; c: CHAR): LONGCARD;
  BEGIN
    RETURN d^.OffsetTable [c] + 4L;
  END Get_Word_Pos;
  
PROCEDURE Get_Max (d: Dic; c: CHAR): LONGCARD;
  VAR max: LONGCARD;
  BEGIN
    max := Get_Offset_Pos (d, inc (c));  DEC (max);  RETURN max;
  END Get_Max;
  
PROCEDURE SaveDic (fn: FileStr; d: Dic);
  VAR offset : LONGCARD;
      c      : CHAR;
  BEGIN
    FOR c := startChar TO MAX (CHAR) DO
      IF IsLower (c) THEN
        offset := Get_Offset_Pos (d, inc (c));
        DEC (offset, Get_Offset_Pos (d, c));
        CardToMem (SHORT (offset), Get_Offset_Adr (d, c));
      END;
    END;
    MemToFile (fn, d^.dic, d^.size);
  END SaveDic;
  
PROCEDURE ReleaseDic (VAR d: Dic);
  BEGIN
    DEALLOCATE (d^.dic, 0); DEALLOCATE (d, 0); d := NIL;
  END ReleaseDic;
  
VAR G_pos, G_cnt: LONGCARD;
    G_lcnt      : CARDINAL;

PROCEDURE QueryDic (d: Dic; str: ARRAY OF CHAR;
                    elemProc: queryProc);

  PROCEDURE queryAux (c: CHAR): BOOLEAN;
  
    VAR i, pos  : LONGCARD;
        max     : LONGCARD;
        j       : CARDINAL;
        cPtr    : CPtr;
        zstr    : String;
        zustand : Zustand;
    BEGIN
      G_lcnt := 0;
      pos := Get_Word_Pos (d, c);  cPtr := Get_Index_Adr (d, pos);
      zustand := char;  zstr[0] := c; j := ORD (cPtr^); INC (cPtr);
      max := Get_Max (d, c);
      IF pos > max  THEN RETURN TRUE; END;
      FOR i := pos + 1L TO max DO
        IF zustand = zahl THEN
          zstr[j] := 0C; j := ORD (cPtr^); INC (cPtr);
          zustand := char;
          G_pos := i; INC (G_cnt);
          IF ~elemProc(d,zstr) THEN RETURN FALSE; END;
          INC (G_lcnt);
        ELSE
          zstr[j] := cPtr^; INC (cPtr); INC (j);
        END;
        IF cPtr^ < startChar THEN zustand := zahl; END;
      END;
      G_pos := Get_Max (d, c); zstr [j] := 0C;
      RETURN elemProc (d, zstr);
    END queryAux;
    
  VAR c: CHAR;
  BEGIN
    IF str[0] = 0C THEN
      FOR c := startChar TO MAX (CHAR) DO
        IF IsLower (c) AND ~queryAux (c) THEN RETURN; END;
      END;
    ELSE
      voidO := queryAux (str[0]);
    END;
  END QueryDic;

PROCEDURE count (d: Dic; VAR voidS: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    RETURN TRUE;
  END count;

PROCEDURE CountWords (d: Dic): LONGCARD;
  BEGIN
    G_cnt := 0;  QueryDic (d, '', count);  RETURN G_cnt;
  END CountWords;

PROCEDURE insert (d: Dic; VAR zstr: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    IF (G_lcnt MOD d^.every = 0) THEN  Insert (d^.tree, zstr, G_pos);  END;
    RETURN TRUE;
  END insert;

PROCEDURE SetSpellMode (d: Dic; every: CARDINAL);
  BEGIN
    d^.every := every;
    voidO := CreateFastDic (d^.tree, every, CountWords (d));
    QueryDic (d, '', insert);
    CloseFastDic (d^.tree);
  END SetSpellMode;

PROCEDURE CreateDic (VAR d: Dic; over, step: LONGCARD);
  VAR j : CARDINAL;
      c : CHAR;
  BEGIN
    allocate (d, SIZE (d^));
    allocate (d^.dic, MinSize + over);
    j := 0;
    FOR c := 1C TO MAX (CHAR) DO
      d^.OffsetTable [c] := j;
      IF IsLower (c) THEN
        d^.dic^[j]   := 0C;
        d^.dic^[j+1] := 4C;
        d^.dic^[j+2] := 0C;
        d^.dic^[j+3] := c;
        INC (j, 4);
      END;
    END;
    d^.step  := step;
    d^.max   := MinSize + over;
    d^.size  := MinSize;
    d^.every := 0;
  END CreateDic;

PROCEDURE LoadDic (fn: FileStr; VAR d: Dic;
                   over, step: LONGCARD);

  VAR c      : CHAR;
      offset : LONGCARD;
      scs    : BOOLEAN;
  BEGIN
    allocate (d, SIZE (d^));          (* falsches Format bzw. fehler-*)
    d^.size := FILESIZE (fn);         (* hafte Daten werden nicht    *)
    allocate (d^.dic, d^.size+over);  (* erkannt!                    *)
    FileToMem (fn, d^.dic, d^.size);
    d^.max := d^.size + over;
    d^.step := step;
    ClearVar (d^.OffsetTable);
    offset := 0;
    FOR c := 1C TO MAX (CHAR) DO
      IF IsLower (c) THEN
        d^.OffsetTable [c] := offset;
        INC (offset, MemToCard (DicAdr (d, offset)));
      ELSE
        d^.OffsetTable [c] := offset;
      END;
    END;
  END LoadDic;

PROCEDURE UpdateOffsetTable (d: Dic; c: CHAR; shift: INTEGER);
  BEGIN
    FOR c := inc (c) TO MAX (CHAR) DO
      INC (d^.OffsetTable [c], shift);
    END;
    INC (d^.size, shift);
  END UpdateOffsetTable;
  
PROCEDURE enoughMem (d: Dic; c: CHAR; shift: CARDINAL;
                     pos: LONGCARD; VAR scs: BOOLEAN);
                     
  (* Falls ein fehlerfreies STORAGE.Enlarge vorliegt l„žt sich
   * diese Prozedur leicht flexibler gestalten! Das aktuelle Enlarge
   * hat aber leider so seine Probleme.
   *)
  BEGIN
    Check (d^.max - d^.size <= LONG (shift), 0, enoughMemStr);
    UpdateOffsetTable (d, c, shift);
    Copy (DicAdr (d, pos), d^.size-pos, DicAdr (d, pos + LONG (shift)));
  END enoughMem;

PROCEDURE GetDeltaPos (REF a, b: ARRAY OF CHAR): CARDINAL;
  VAR i: CARDINAL;
  BEGIN
    FOR i := 0 TO MAX (CARDINAL) DO
      IF (a[i] # b[i]) THEN  RETURN i;  END;
    END;
  END GetDeltaPos;
  
PROCEDURE GetRestLen (REF s: ARRAY OF CHAR; pos: CARDINAL): CARDINAL;
  VAR i: CARDINAL;
  BEGIN
    i := 0;
    IF s[0] # 0C THEN
      REPEAT
        INC (i);  INC (pos);
      UNTIL (pos > HIGH (s)) OR (s[pos] = 0C);
    END;
    RETURN i;
  END GetRestLen;
  
PROCEDURE Compact (REF a: ARRAY OF CHAR; al,ar : CARDINAL;
                   REF b: ARRAY OF CHAR; bl    : CARDINAL;
                   REF c: ARRAY OF CHAR; cl,cr : CARDINAL;
                   VAR x: ARRAY OF CHAR; VAR xl, shift: CARDINAL);

  (* kompaktiert 'b' und 'c' zu 'x' *)

  VAR delta, j, i: CARDINAL;
  BEGIN
    delta := GetDeltaPos (a,b); (* Es gilt: delta >= 1, bl >= 1 *)
    x[0] := CHR (delta); j := 1;
    FOR i := delta TO bl-1 DO
      x[j] := b[i]; INC (j);
    END;
    delta := GetDeltaPos (b,c);
    IF delta # 0 THEN                   (* am ende einfgen *)
      x[j] := CHR (delta);
      xl  := j + 1;
      shift := j + cl - delta - cr;
    ELSE
      xl := j;  shift := j;
    END;
  END Compact;
  
PROCEDURE InitMoveRec (d: Dic; REF str: ARRAY OF CHAR;
                       VAR MoveRec: moveRec);
  BEGIN
    WITH MoveRec DO
      ReadPos := Get_Word_Pos (d, str [0]);
      MaxPos  := Get_Offset_Pos (d, inc (str [0]));
      vorIx  := 0; aktIx  := 1; nachIx := 2;
      StrTab [vorIx].Str := ' ';
      StrTab [vorIx].Len := 1;
      StrTab [vorIx].RLen := 1;
      StrTab [vorIx].StartPos := Get_0CHAR_Pos (d, str [0]);
      StrTab [aktIx]  := StrTab [vorIx];
      StrTab [nachIx] := StrTab [vorIx];
    END;
  END InitMoveRec;
  
PROCEDURE Move (d: Dic; VAR MoveRec: moveRec);
  VAR i: CARDINAL;
  BEGIN
    WITH MoveRec DO
      vorIx  := (vorIx  + 1) MOD 3;
      aktIx  := (aktIx  + 1) MOD 3;
      nachIx := (nachIx + 1) MOD 3;
      IF ReadPos >= MaxPos THEN
        StrTab [nachIx].Str := 377C;
        StrTab [nachIx].StartPos := MaxPos;
        StrTab [nachIx].Len  := 0;
        StrTab [nachIx].RLen := 0;
      ELSE
        StrTab [nachIx].Str      := StrTab [aktIx].Str;
        StrTab [nachIx].StartPos := ReadPos;
        StrTab [nachIx].RLen     := 0;
        i := ORD (d^.dic^ [ReadPos]);
        StrTab [nachIx].Len := i;
        INC (ReadPos);
        REPEAT
          StrTab [nachIx].Str [i] := d^.dic^ [ReadPos];
          INC (StrTab [nachIx].RLen);
          INC (ReadPos);
          INC (i);
        UNTIL (d^.dic^ [ReadPos] < startChar) OR (ReadPos > MaxPos);
        StrTab [nachIx].Len     := i;
        StrTab [nachIx].Str [i] := 0C;
      END;
    END;
  END Move;

PROCEDURE InsertDic (d: Dic; REF str: ARRAY OF CHAR; VAR scs: BOOLEAN);
       
  VAR MoveRec     : moveRec;
      cStr, zstr  : String;
      cLen, shift : CARDINAL;
      rel         : Relation;
  BEGIN
    scs := TRUE;
    IF (str[0] = 0C) THEN RETURN; END;
    Assign (str, zstr, scs);
    InitMoveRec (d, zstr, MoveRec);
    WITH MoveRec DO
      Move (d, MoveRec);
      LOOP
        Move (d, MoveRec);
        CASE cmp (ADR (zstr), ADR (StrTab [aktIx].Str)) OF
        | equal : RETURN;
        | less  : EXIT;
        ELSE END;
      END;
      Compact (StrTab [vorIx].Str, StrTab [vorIx].Len, StrTab [vorIx].RLen,
               str, Length (str),
               StrTab [aktIx].Str, StrTab [aktIx].Len, StrTab [aktIx].RLen,
               cStr, cLen, shift);
      enoughMem (d, str[0], shift, StrTab [aktIx].StartPos, scs);
      IF ~scs THEN HALT; END;
      ByteCopy (ADR (cStr), cLen, Get_Index_Adr (d, StrTab [aktIx].StartPos));
    END;
  END InsertDic;

PROCEDURE FindDic (d: Dic; REF str: ARRAY OF CHAR): BOOLEAN;

  VAR i, pos, max: LONGCARD;
      j          : CARDINAL;
      zstr       : String;
      cPtr       : CPtr;
      rel        : Relation;
  BEGIN
    IF d^.every = 0 THEN  RETURN FALSE;  END;
    Assign (str, zstr, voidO);  Lower (zstr);
    GetPos (d^.tree, zstr, pos); IF pos = MAX (LONGCARD) THEN  RETURN TRUE;  END;
    max := Get_Max (d, zstr[0]);
    j := Length (zstr);
    cPtr := Get_Index_Adr (d, pos);
    IF pos > max  THEN RETURN TRUE; END;
    FOR i := pos TO max DO
      INC (j);
      IF cPtr^ < startChar THEN
        zstr [j-1] := 0C;
        rel := cmp (ADR (zstr), ADR (str));
        IF    rel = equal   THEN  RETURN  TRUE;
        ELSIF rel = greater THEN  RETURN  FALSE; END;
        j := ORD (cPtr^);
      END;
      INC (cPtr);
      zstr [j] := cPtr^;
    END;
    zstr [j+1] := 0C;
    RETURN cmp (ADR (zstr), ADR (str)) = equal;
  END FindDic;

PROCEDURE DeleteDic (d: Dic; REF str: ARRAY OF CHAR);
  
  VAR MoveRec        : moveRec;
      writePos       : LONGCARD;
      shift          : INTEGER;
      from, to       : ADDRESS;
      delta, i, cLen : CARDINAL;
      zstr           : String;
      c              : CHAR;
      
  BEGIN
    Assign (str, zstr, voidO); c := zstr[0];
    InitMoveRec (d, c, MoveRec);
    
    (* Vorbed: akt <= nach < str *)
    (* Return: nach = str        *)
    (* Insert: akt < str < nach  *)
    
    WITH MoveRec DO
      Move (d, MoveRec);
      (*$W-*)
      REPEAT
        Move (d, MoveRec);
        IF cmp (ADR (zstr), ADR (StrTab [aktIx].Str)) = equal THEN
          IF StrTab [nachIx].Len = 0 THEN
            shift := - (StrTab [aktIx].RLen)+1;
          ELSE
            writePos := StrTab [aktIx].StartPos;
            delta    := GetDeltaPos (StrTab [vorIx].Str, StrTab [nachIx].Str);
            d^.dic^ [writePos] := CHR (delta);
            cLen := 0;
            FOR i := delta TO StrTab [nachIx].Len-1 DO
              INC (writePos);
              INC (cLen);
              d^.dic^ [writePos] := StrTab [nachIx].Str[i];
            END;
            
(* shift = neue L„nge - alte L„nge *)
(*       = (1+aRLen + 1+cRlen/neu) - (1+aRLen+ 1+bRlen +1+cRlen);*)
(*       = (cRlen/neu) - (bRlen +1+cRlen);*)
                    
            shift := cLen - (StrTab [aktIx].RLen + 1 +
                     StrTab [nachIx].RLen);
          END;
          from := Get_Index_Adr (d, ReadPos); to := from;
          INC (to, shift);
          Copy (from, d^.size - ReadPos, to);
          UpdateOffsetTable (d, c, shift);
          RETURN;
        END;
      UNTIL cmp (ADR (zstr), ADR (StrTab [aktIx].Str)) = less;
      RETURN;
    END;
  (*$W=*)
  END DeleteDic;
END Dics.

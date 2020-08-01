MODULE OCErr; (* SJ  10.3.94 *)


IMPORT
  S:=SYSTEM, Par:=OCPar, FN:=Filename, File, NStr:=NumStr, Files:=BFiles,
  Str:=Strings, IO, Task;


VAR
  scanerr* : BOOLEAN;
  NumErr*, NumWarn* : INTEGER;
  CallOnError* : PROCEDURE;

  lastpos: LONGINT; lastline : INTEGER; (*error position in source file*)
  errfile : Files.File; err: Files.Rider;
  FileName, ErrName : ARRAY 80 OF CHAR;


PROCEDURE Pos() : LONGINT;
 BEGIN
  RETURN Par.position - Par.source - 2
 END Pos;


PROCEDURE WriteString(s : ARRAY OF CHAR);
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE s[i] # 0X DO
    err.Write(s[i]); INC(i);
  END;
  IO.WriteString(s);
 END WriteString;


PROCEDURE WriteLn;
 BEGIN
  err.Write(0DX); err.Write(0AX);
  IO.WriteLn;
 END WriteLn;


PROCEDURE WriteInt(i : LONGINT);
 VAR
   s : ARRAY 10 OF CHAR;
 BEGIN
  NStr.LIntTo(i,10,s); WriteString(s);
 END WriteInt;


PROCEDURE GetLine() : INTEGER;
  VAR
    pos : LONGINT; c : CHAR;
 BEGIN
  pos := Pos();
  IF pos < lastpos THEN
    WHILE (pos < lastpos) & (lastpos > 0) DO
      S.GET(Par.source + lastpos,c);
      IF c = 0AX THEN DEC(lastline) END;
      DEC(lastpos);
    END(*WHILE*);
  ELSE
    IF lastpos < 0 THEN lastpos := 0 END(*IF*);
    WHILE (pos > lastpos) DO
      S.GET(Par.source + lastpos,c);
      IF c = 0AX THEN INC(lastline) END;
      INC(lastpos);
    END;
  END(*IF*);
  RETURN lastline
 END GetLine;


PROCEDURE GetCol() : INTEGER;
  VAR
    pos : LONGINT; c : CHAR; Col : INTEGER;
 BEGIN
  pos := Pos(); Col := 1;
  WHILE pos > 0 DO
    S.GET(Par.source + pos,c);
    IF c = 0AX THEN RETURN Col END;
    INC(Col); DEC(pos);
  END;
  RETURN Col
 END GetCol;


PROCEDURE WriteErrorLine(VAR Error : ARRAY OF CHAR);
  (* writes a line into the error file with the format given in ErrorFormat *)
  VAR i,j : INTEGER;
      s   : ARRAY 50 OF CHAR;
      p   : POINTER TO ARRAY 50 OF CHAR;
 BEGIN
  COPY(Par.ErrorFormat,s); i := 0; j := 0;
  WHILE s[i] # 0X DO
    IF s[i] = "\" THEN
      IF j < i THEN s[i] := 0X; p := S.ADR(s[j]); WriteString(p^) END;
      INC(i,2); j := i;
      CASE s[i-1] OF
        "d" : WriteString(FileName) |
        "z" : WriteInt( GetLine() ) |
        "s" : WriteInt( GetCol() ) |
        "p" : WriteInt( Pos() ) |
        "f" : WriteString(Error) |
        ELSE DEC(j)
      END;
    ELSE INC(i);
    END;
  END;
  IF j < i THEN p := S.ADR(s[j]); WriteString(p^) END;
  WriteLn;
 END WriteErrorLine;


PROCEDURE WriteWarn(n : INTEGER);
  VAR s : ARRAY 80 OF CHAR;
 BEGIN
  IF Par.WarningsOut THEN
    CASE n OF
      1 : s := "A variable change using ADR(...) may cause trouble on optimizing";
    | 2 : s := "Function does not return anything"
    | 3 : s := "Local variable used in strange addressing mode"
      ELSE NStr.IntTo(n,10,s)
    END(*CASE*);
    Str.Insert("Warning : ",0,s);
    WriteErrorLine(s);
  END;
 END WriteWarn;


PROCEDURE WriteErr(n : INTEGER);
  VAR
    s : ARRAY 80 OF CHAR;
 BEGIN
  IF n > 500 THEN
    CASE n-500 OF
      0 : s := "Out of labels" |
      1 : s := "Too much open loops" |
    ELSE NStr.IntTo(n,10,s)
    END(*CASE*);
    Str.Insert("Internal error: ", 0, s);
  ELSE
    CASE n OF
      14  : s := "Equal sign expected" |
      23  : s := "Period expected" |
      24  : s := "Comma expected" |
      25  : s := "Colon expected" |
      27  : s := "Right parenthesis expected" |
      29  : s := "Right brace expected" |
      30  : s := "OF expected" |
      31  : s := "THEN expected" |
      32  : s := "DO expected" |
      34  : s := "Left parenthesis expected" |
      38  : s := "Assignment expected" |
      39  : s := "Value expected" |
      42  : s := "Identifier expected" |
      43  : s := "Semicolon expected" |
      45  : s := "END expected" |
      56  : s := "Procedure returns something" |
      58  : s := "Record expected" |
      59  : s := "Pointer expected" |
      61  : s := "Constant value expected" |
      62  : s := "Type expected" |
      63  : s := "Variable expected" |
      64  : s := "Procedure expected" |
      66  : s := "MODULE expected" |
      100 : s := "String too long (max. 255)" |
      101 : s := "String not ended" |
      102 : s := "Identifier too long (max. 39)" |
      103 : s := "Illegal digit in number" |
      104 : s := "Number has too much digits" |
      105 : s := "Exponent too high" |
      106 : s := "Number too high" |
      107 : s := "Comment not ended" |
      108 : s := "Identifiers do not match" |
      109 : s := "Identifier already defined" |
      110 : s := "Only global identifiers can be exported" |
      111 : s := "Statement expected" |
      112 : s := "Illegal factor" |
      113 : s := "No more registers available" |
      114 : s := "No calculation with that data type" |
      115 : s := "Incompatible assignment" |
      116 : s := "Only integer types allowed" |
      117 : s := "Only boolean types allowed" |
      118 : s := "Incompatible operand types" |
      119 : s := "Only allowed in extended mode" |
      120 : s := "Only set type allowed" |
      121 : s := "Assignment expected" |
      122 : s := "Constant expression expected" |
      123 : s := "Case range too big" |
      124 : s := "Identifier already defined" |
      125 : s := "Variable is no array" |
      126 : s := "Constant index out of range" |
      127 : s := "Unknown identifier" |
      128 : s := "No open array allowed" |
      129 : s := "Pointer base type only record or array" |
      130 : s := "Procedure call of a function" |
      131 : s := "Type cannot be returned" |
      132 : s := "Less actual than formal parameters" |
      133 : s := "More actual than formal parameters" |
      134 : s := "A shortened array type needs space for length" |
      135 : s := "Function call of a procedure" |
      136 : s := "Address cannot be loaded" |
      137 : s := "Base type expected" |
      138 : s := "Type cannot vary, test useless" |
      139 : s := "Bind parameter expected" |
      140 : s := "Just one bind parameter possible" |
      141 : s := "Binding only to record or pointer to record" |
      142 : s := "Binding variable must be VAR or pointer" |
      143 : s := "No increment (decrement) possible" |
      144 : s := "Only strings (array of char) allowed" |
      145 : s := "Variable is no pointer" |
      146 : s := "Only static variables allowed" |
      147 : s := "Variable size must be less than 32K" |
      148 : s := "Type guard only for pointers and (VAR) records" |
      149 : s := "Wrong type for type guard" |
      150 : s := "No same base type" |
      151 : s := "Register number out of range (0 <= r <= 15 (23 with FPU))" |
      152 : s := "Real or Longreal expected" |
      153 : s := "Longint, Pointer, PTR or ProcTyp expected" |
      154 : s := "Only simple types (1, 2 or 4 bytes) allowed" |
      155 : s := "No minimum or maximum of that type" |
      156 : s := "No static size available" |
      157 : s := "Numerical type expected" |
      158 : s := "Character type expected" |
      159 : s := "Wrong type" |
      160 : s := "No valid dimension" |
      161 : s := "Value out of range for CC (0 <= cc <= 15)" |
      162 : s := "Internal overflow error" |
      163 : s := "Defect symbol file" |
      164 : s := "Parameter list not identical" |
      165 : s := "Assignment to read only variable" |
      166 : s := "Procedure does not return anything" |
      168 : s := "Function call expected" |
      169 : s := "Not allowed in data segment" |
      170 : s := "Not allowed in bss segment" |
      171 : s := "Size identifier expected" |
      172 : s := "Unknown or false assembler command" |
      173 : s := "Address register expected" |
      174 : s := "Index register expected" |
      175 : s := "Not available on 68000" |
      176 : s := "Scale factor expected (1, 2, 4, or 8)" |
      177 : s := "Illegal addressing mode" |
      178 : s := "Addressing mode not allowed for 68000" |
      179 : s := "Command not available on 68000" |
      180 : s := "Command only available with FPU" |
      181 : s := "No valid symbol file" |
      182 : s := "Keys of imported symbol files do not match" |
      183 : s := "Wrong link register used" |
      184 : s := "Error in symbol file" |
      185 : s := "Only allowed in assembler" |
      186 : s := "Symbol file not found" |
      187 : s := "No more base types" |
      188 : s := "No more data registers available" |
      189 : s := "No more address registers available" |
      190 : s := "No more fpu registers available" |
      191 : s := "Not yet implemented" |
      192 : s := "String should be a character" |
      193 : s := "Record field expected" |
      194 : s := "Pointer to record or VAR record expected" |
      195 : s := "Data register expected" |
      196 : s := "FPU registers cannot be mixed with others" |
      197 : s := "An 68030 command could not be emulated" |
      198 : s := "An FPU command could not be emulated" |
      199 : s := "Label expected" |
    ELSE
      CASE n OF	(* too much for V1.24 *)
        200 : s := "Only 10 type extension levels possible" |
        201 : s := "No type descriptor available" |
        202 : s := "More inherits than base types" |
        203 : s := "LONGINT only" |
        204 : s := "Must have same types" |
        205 : s := "No additional RETURN possible" |
        206 : s := "No direct call allowed" |
        207 : s := "Assignment procedure only local to a global procedure" |
        208 : s := "Forward definition has different export mark" |
        209 : s := "Local variable size limited to 32K" |
      ELSE NStr.IntTo(n,10,s)
      END;
    END(*CASE*);
  END;
  WriteErrorLine(s);
 END WriteErr;


PROCEDURE Mark*(n: INTEGER);
  VAR
    pos: LONGINT; s : ARRAY 10 OF CHAR;
 BEGIN
  pos := Pos();
  IF (lastpos + Par.ErrDist < pos) & (NumErr < Par.MaxErr) THEN
    IF n < 0 THEN
      WriteWarn( - n ); INC(NumWarn);
    ELSE
      INC(NumErr); scanerr := TRUE; WriteErr( n );
      IF CallOnError # NIL THEN
        CallOnError;
      END;
    END ;
  END;
  IF Par.debug THEN HALT(199) END;
 END Mark;


PROCEDURE Init*(VAR name : ARRAY OF CHAR);
  VAR
    d : BOOLEAN;
 BEGIN
  scanerr := FALSE; lastpos := -1000; lastline := 1;
  NumErr := 0; NumWarn := 0;
  COPY(name,ErrName); FN.SetExt("ERR",ErrName);
  COPY(name, FileName);
  errfile := Files.New(ErrName);
  err.Set(errfile, 0);
 END Init;


PROCEDURE Exit*;
  VAR
    d : BOOLEAN;
 BEGIN
  IF errfile # NIL THEN
    IF Par.WarningsOut AND (NumWarn # 0) OR (NumErr # 0) THEN
      errfile.Register;
    END;
    errfile.Close;
    errfile := NIL;
  END;
 END Exit;


END OCErr.
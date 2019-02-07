IMPLEMENTATION MODULE M2Input;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 03-Jan-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC


FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, UNSIGNED;

FROM types IMPORT
(* TYPE *) HT, LF;

FROM ctype IMPORT
(* PROC *) Cisspace, Cisalnum, isalnum, Cisdigit;

FROM IOConsts IMPORT
(* TYPE *) ReadResults;

FROM IOChan IMPORT
(* PROC *) Skip, TextRead, ReadResult;

FROM StreamFile IMPORT
(* CONST*) read,
(* TYPE *) ChanId, OpenResults,
(* PROC *) Open, Close;

FROM StdChans IMPORT
(* PROC *) InChan;

FROM M2Syms IMPORT
(* TYPE *) Symbols, SymbolSet,
(* PROC *) IsElem;

FROM M2StrTable IMPORT
(* TYPE *) StrRepr,
(* PROC *) CreateStrRepr, NewStrRepr, AddStrReprCh, EndStrRepr, SetSymbol,
           GetSymbol, HasSymbol, EmptyStrRepr;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  BUFSIZE = 128;

VAR
  EOF      : BOOLEAN;
  EOL      : BOOLEAN;
  DONE     : BOOLEAN;
  InOpen   : BOOLEAN;
  InFile   : ChanId;
  InBuf    : ARRAY [0..BUFSIZE-1] OF CHAR;
  BufSize  : UNSIGNEDWORD;
  BufIdx   : UNSIGNEDWORD;
  LineNo   : UNSIGNEDWORD;
  ColNo    : UNSIGNEDWORD;
  InCh     : CHAR;
  Ellipsis : BOOLEAN;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE OpenInput ((* EIN/ -- *) REF file : ARRAY OF CHAR ): BOOLEAN;

VAR res : OpenResults;

BEGIN
 Open(InFile, file, read, res);
 IF res = opened THEN
   InOpen := TRUE;
 ELSE
   InFile := InChan();
   InOpen := FALSE;
 END;
 RETURN(InOpen);
END OpenInput;

(*---------------------------------------------------------------------------*)

PROCEDURE InitInput;

VAR read : UNSIGNED;

BEGIN
 TextRead(InFile, ADR(InBuf), BUFSIZE, read);
 BufSize  := VAL(UNSIGNEDWORD,read);
 LineNo   := 1;
 ColNo    := 0;
 Ellipsis := FALSE;
 IF BufSize = 0 THEN
   InCh := 0C;
   IF ReadResult(InFile) = endOfInput THEN
     EOF := TRUE;
   ELSE
     EOL := TRUE;
   END;
   DONE := FALSE;
 ELSE
   InCh := InBuf[0];
   EOL  := FALSE;
   EOF  := FALSE;
   DONE := TRUE;
 END;
END InitInput;

(*---------------------------------------------------------------------------*)

PROCEDURE CloseInput;
BEGIN
 IF InOpen THEN
   Close(InFile);
   InOpen := FALSE;
 END;
 InFile := InChan();
 InCh   := 0C;
 DONE   := FALSE;
 EOL    := FALSE;
 EOF    := TRUE;
END CloseInput;

(*---------------------------------------------------------------------------*)

PROCEDURE NextChar;

VAR read : UNSIGNED;

BEGIN
 (* Nach Haeufigkeit geordnet, wegen Geschwindigkeit *)
 IF InCh >= ' ' THEN
   INC(ColNo);
   INC(BufIdx);
 ELSIF EOL THEN
   Skip(InFile);
   ColNo := 0;
   INC(LineNo);
   DONE := TRUE;
   EOL  := FALSE;
 ELSIF InCh = HT THEN
   ColNo := ((ColNo DIV TabSize) + 1) * TabSize;
   INC(BufIdx);
 ELSIF EOF THEN
   RETURN;
 ELSE
   INC(ColNo);
   INC(BufIdx);
 END;
 (* DONE = TRUE, EOF = FALSE, EOL = FALSE *)

 IF BufIdx < BufSize THEN
   InCh := InBuf[BufIdx];
 ELSE
   TextRead(InFile, ADR(InBuf), BUFSIZE, read);
   BufSize := VAL(UNSIGNEDWORD,read);
   BufIdx  := 0;
   IF BufSize = 0 THEN
     DONE := FALSE;
     IF ReadResult(InFile) = endOfLine THEN
       InCh := LF;
       EOL  := TRUE;
     ELSE
       InCh := 0C;
       EOF  := TRUE;
     END;
   ELSE
     InCh  := InBuf[0];
   END;
 END;
END NextChar;

(*---------------------------------------------------------------------------*)

PROCEDURE NextToken ((* -- /AUS *) VAR sym  : Symbols;
                     (* -- /AUS *) VAR esym : Symbols;
                     (* -- /AUS *) VAR pos  : InputPos;
                     (* -- /AUS *) VAR repr : StrRepr );

PROCEDURE ReadOption;
(* Ueberliest ISO-Compileroption, Zeilenenden duerfen nicht auftreten *)
VAR EndOption : BOOLEAN;

BEGIN
 EndOption := FALSE;
 NextChar;
 LOOP
   IF ~DONE THEN
     EXIT;
   ELSIF InCh = '*' THEN
     NextChar;
     IF InCh = '>' THEN
       EndOption := TRUE;
       NextChar;
       EXIT;
     END;
   ELSE
     NextChar;
   END;
 END;

 esym := Option;
 IF EndOption THEN
   sym := Option;
 ELSIF EOF THEN
   sym := UnexpectedEof;
 ELSE
   sym := UnexpectedEol;
 END;
END ReadOption;

PROCEDURE ReadComment;
(* Ueberliest geschachtelte Kommentare, Zeilenenden duerfen auftreten *)
VAR CommentLevel : UNSIGNEDWORD;

BEGIN
 CommentLevel := 1;
 NextChar;
 LOOP
   IF EOF THEN
     EXIT;
   ELSIF InCh = '*' THEN
     NextChar;
     IF InCh = ')' THEN
       NextChar;
       DEC(CommentLevel);
       IF CommentLevel = 0 THEN
         EXIT;
       END;
     END;
   ELSIF InCh = '(' THEN
     NextChar;
     IF InCh = '*' THEN
       NextChar;
       INC(CommentLevel);
     END;
   ELSE
     NextChar;
   END;
 END; (* LOOP *)

 IF CommentLevel = 0 THEN
   sym  := Comment;
 ELSE
   esym := Comment;
   sym  := UnexpectedEof;
 END;
END ReadComment;

PROCEDURE ReadNumber;
(* Liest eine Zahlkonstante oder oktale Zeichenkonstante.
 * Es wird alles bis zum naechsten Begrenzungszeichen als Token gelesen.
 * Die korrekte Syntax und der Typ muessen durch den
 * Parser festgestellt werden.
 *)
BEGIN
 sym := NumberSym;
 NewStrRepr;
 REPEAT
   AddStrReprCh(InCh);
   NextChar;
 UNTIL ~(Cisalnum(InCh) OR (InCh = '_'));

 IF InCh = '.' THEN
   (* Realzahl oder Ganzzahl gefolgt von Ellipse *)
   NextChar;
   IF InCh = '.' THEN
     (* Ist Ganzzahl *)
     EndStrRepr(repr);
     SetSymbol(repr, NumberSym);
     Ellipsis := TRUE;
     RETURN;
   END;
   AddStrReprCh('.');
   WHILE Cisdigit(InCh) DO
     AddStrReprCh(InCh);
     NextChar;
   END;
   IF (InCh = 'E') OR (InCh = 'D') THEN
     AddStrReprCh(InCh);
     NextChar;
     IF (InCh = '-') OR (InCh = '+') THEN
       (* Spezieller Fall: Das erste Vorzeichen hinter
        * einem Exponentzeichen ist kein Begrenzungszeichen.
        *)
       AddStrReprCh(InCh);
       NextChar;
     END;
   END;
   WHILE Cisalnum(InCh) OR (InCh = '_') DO
     (* Auch Buchstaben *)
     AddStrReprCh(InCh);
     NextChar;
   END;
 END;
 EndStrRepr(repr);
 SetSymbol(repr, NumberSym);
END ReadNumber;

PROCEDURE ReadString;
(* Ueberliest String- und Charakterkonstanten.
 * Zeilenenden duerfen nicht auftreten -> UnexpectedEol.
 *)
VAR delim : CHAR;

BEGIN
 delim := InCh;
 NewStrRepr;
 NextChar;
 WHILE DONE & (InCh <> delim) DO
   AddStrReprCh(InCh);
   NextChar;
 END;
 EndStrRepr(repr);
 SetSymbol(repr, StringSym);

 esym := StringSym;
 IF InCh = delim THEN
   sym := StringSym;
   NextChar;
 ELSIF EOF THEN
   sym := UnexpectedEof;
 ELSE
   sym := UnexpectedEol;
   NextChar;
 END;
END ReadString;

PROCEDURE ReadIdent;
(* Liest einen beliebigen Bezeichner ein *)
BEGIN
 NewStrRepr;
 REPEAT
   AddStrReprCh(InCh);
   NextChar;
 UNTIL ~(isalnum(InCh) OR (InCh = '_'));
 EndStrRepr(repr);

 IF HasSymbol(repr) THEN
   (* Vordefinierter Bezeichner (Schluesselwort) *)
   GetSymbol(repr, sym);
 ELSE
   sym := IdentSym;
   SetSymbol(repr, IdentSym);
 END;
END ReadIdent;

PROCEDURE HandleColon;
BEGIN
 NextChar;
 IF InCh = '=' THEN
   sym := AssignSym;
   NextChar;
 ELSIF InCh = ')' THEN
   sym := RightBraceSym;
   NextChar;
 ELSE
   sym := ColonSym;
 END;
END HandleColon;

PROCEDURE HandlePoint;
BEGIN
 NextChar;
 IF Ellipsis THEN
   (* Erster Punkt der Ellipse wurde schon in "ReadNumber()" gelesen *)
   sym      := EllipsisSym;
   Ellipsis := FALSE;
 ELSIF InCh = '.' THEN
   sym := EllipsisSym;
   NextChar;
 ELSE
   sym := PeriodSym;
 END;
END HandlePoint;

PROCEDURE HandleLess;
BEGIN
 NextChar;
 IF InCh = '>' THEN
   sym := NotEqualsSym;
   NextChar;
 ELSIF InCh = '=' THEN
   sym := LessOrEqualSym;
   NextChar;
 ELSIF InCh = '*' THEN
   ReadOption;
 ELSE
   sym := LessSym;
 END;
END HandleLess;

PROCEDURE HandleGreater;
BEGIN
 NextChar;
 IF InCh = '=' THEN
   sym := GreaterOrEqualSym;
   NextChar;
 ELSE
   sym := GreaterSym;
 END;
END HandleGreater;

PROCEDURE HandleLeftParen;
BEGIN
 NextChar;
 IF InCh = ':' THEN
   sym := LeftBraceSym;
   NextChar;
 ELSIF InCh = '!' THEN
   sym := LeftBracketSym;
   NextChar;
 ELSIF InCh = '*' THEN
   ReadComment;
 ELSE
   sym := LeftParenSym;
 END;
END HandleLeftParen;

PROCEDURE HandleExclamation;
BEGIN
 NextChar;
 IF InCh = ')' THEN
   sym := RightBracketSym;
   NextChar;
 ELSE
   sym := CaseOpSym;
 END;
END HandleExclamation;

BEGIN (* NextToken *)
 EmptyStrRepr(repr);
 REPEAT
   WHILE Cisspace(InCh) DO
     NextChar;
   END;
   pos.line := LineNo;
   pos.col  := ColNo;
   IF EOF THEN
     sym := EofSym;
     RETURN;
   END;

   CASE InCh OF
     0C..37C :
           sym := CtrlCh;          NextChar;
    |';' : sym := SemicolonSym;    NextChar;
    |')' : sym := RightParenSym;   NextChar;
    |',' : sym := CommaSym;        NextChar;
    |'|' : sym := CaseOpSym;       NextChar;
    |'{' : sym := LeftBraceSym;    NextChar;
    |'}' : sym := RightBraceSym;   NextChar;
    |'=' : sym := EqualsSym;       NextChar;
    |'[' : sym := LeftBracketSym;  NextChar;
    |']' : sym := RightBracketSym; NextChar;
    |'+' : sym := PlusSym;         NextChar;
    |'-' : sym := MinusSym;        NextChar;
    |'*' : sym := MulSym;          NextChar;
    |'/' : sym := DivisionSym;     NextChar;
    |'&' : sym := AndSym;          NextChar;
    |'~' : sym := NotSym;          NextChar;
    |'#' : sym := NotEqualsSym;    NextChar;
    |'^','@' :
           sym := DerefSym;        NextChar;
    |':' : HandleColon;
    |'!' : HandleExclamation;
    |'.' : HandlePoint;
    |'<' : HandleLess;
    |'>' : HandleGreater;
    |'(' : HandleLeftParen;
    |'0'..'9' :
           ReadNumber;
    |'A'..'Z','a'..'z','_' :
           ReadIdent;
    |'"', "'" :
           ReadString;
   ELSE    sym  := ErrorSym;
           esym := ErrorSym;       NextChar;
   END; (* CASE *)
 UNTIL (sym < CtrlCh) OR (sym > Comment);
END NextToken;

(*---------------------------------------------------------------------------*)

PROCEDURE SkipUntil ((* EIN/ -- *) VAR stopset : SymbolSet;
                     (* -- /AUS *) VAR sym     : Symbols;
                     (* -- /AUS *) VAR esym    : Symbols;
                     (* -- /AUS *) VAR pos     : InputPos;
                     (* -- /AUS *) VAR repr    : StrRepr );

BEGIN
 REPEAT
   NextToken(sym, esym, pos, repr);
 UNTIL (sym >= UnexpectedEof) OR IsElem(sym, stopset);
END SkipUntil;

(*===========================================================================*)

VAR repr : StrRepr;

BEGIN (* M2Input *)
 InOpen := FALSE;
 InFile := InChan();
 InCh   := 0C;
 DONE   := FALSE;
 EOL    := FALSE;
 EOF    := TRUE;

 CreateStrRepr("AND", AndSym, repr);
 CreateStrRepr("ARRAY", ArraySym, repr);
 CreateStrRepr("BEGIN", BeginSym, repr);
 CreateStrRepr("BY", BySym, repr);
 CreateStrRepr("CASE", CaseSym, repr);
 CreateStrRepr("CONST", ConstSym, repr);
 CreateStrRepr("DEFINITION", DefinitionSym, repr);
 CreateStrRepr("DIV", DivSym, repr);
 CreateStrRepr("DO", DoSym, repr);
 CreateStrRepr("ELSE", ElseSym, repr);
 CreateStrRepr("ELSIF", ElsifSym, repr);
 CreateStrRepr("END", EndSym, repr);
 CreateStrRepr("EXIT", ExitSym, repr);
 CreateStrRepr("EXCEPT", ExceptSym, repr);
 CreateStrRepr("EXPORT", ExportSym, repr);
 CreateStrRepr("FINALLY", FinallySym, repr);
 CreateStrRepr("FOR", ForSym, repr);
 CreateStrRepr("FORWARD", ForwardSym, repr);
 CreateStrRepr("FROM", FromSym, repr);
 CreateStrRepr("IF", IfSym, repr);
 CreateStrRepr("IMPLEMENTATION", ImplementationSym, repr);
 CreateStrRepr("IMPORT", ImportSym, repr);
 CreateStrRepr("IN", InSym, repr);
 CreateStrRepr("LOOP", LoopSym, repr);
 CreateStrRepr("MOD", ModSym, repr);
 CreateStrRepr("MODULE", ModuleSym, repr);
 CreateStrRepr("NOT", NotSym, repr);
 CreateStrRepr("OF", OfSym, repr);
 CreateStrRepr("OR", OrSym, repr);
 CreateStrRepr("PACKEDSET", PackedsetSym, repr);
 CreateStrRepr("POINTER", PointerSym, repr);
 CreateStrRepr("PROCEDURE", ProcedureSym, repr);
 CreateStrRepr("QUALIFIED", QualifiedSym, repr);
 CreateStrRepr("RECORD", RecordSym, repr);
 CreateStrRepr("REM", RemSym, repr);
 CreateStrRepr("RETRY", RetrySym, repr);
 CreateStrRepr("REPEAT", RepeatSym, repr);
 CreateStrRepr("RETURN", ReturnSym, repr);
 CreateStrRepr("SET", SetSym, repr);
 CreateStrRepr("THEN", ThenSym, repr);
 CreateStrRepr("TO", ToSym, repr);
 CreateStrRepr("TYPE", TypeSym, repr);
 CreateStrRepr("UNTIL", UntilSym, repr);
 CreateStrRepr("VAR", VarSym, repr);
 CreateStrRepr("WHILE", WhileSym, repr);
 CreateStrRepr("WITH", WithSym, repr);
END M2Input.

IMPLEMENTATION MODULE M2Syms;
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
(* 16-Dez-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC


FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, WORDSET, WORDSETRANGE;

IMPORT ISOStrings;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE GetSymStr ((* EIN/ -- *)     sym  : Symbols;
                     (* -- /AUS *) VAR str  : ARRAY OF CHAR;
                     (* -- /AUS *) VAR done : BOOLEAN       );

VAR s : ARRAY [0..19] OF CHAR;

BEGIN
 CASE sym OF
   ColonSym          : s := ":";
  |CommaSym          : s := ",";
  |EllipsisSym       : s := "..";
  |EqualsSym         : s := "=";
  |PeriodSym         : s := ".";
  |SemicolonSym      : s := ";";
  |LeftParenSym      : s := "(";
  |RightParenSym     : s := ")";
  |NotEqualsSym      : s := "#";
  |PlusSym           : s := "+";
  |MinusSym          : s := "-";
  |MulSym            : s := "*";
  |DivisionSym       : s := "/";
  |AssignSym         : s := ":=";
  |LessSym           : s := "<";
  |GreaterSym        : s := ">";
  |LessOrEqualSym    : s := "<=";
  |GreaterOrEqualSym : s := ">=";
  |AndSym            : s := "AND";
  |NotSym            : s := "NOT";
  |SingleQuoteSym    : s := "'";
  |DoubleQuoteSym    : s := '"';
  |CaseOpSym         : s := "|";
  |DerefSym          : s := "^";
  |LeftBracketSym    : s := "[";
  |RightBracketSym   : s := "]";
  |LeftBraceSym      : s := "{";
  |RightBraceSym     : s := "}";
  |ArraySym          : s := "ARRAY";
  |BeginSym          : s := "BEGIN";
  |BySym             : s := "BY";
  |CaseSym           : s := "CASE";
  |ConstSym          : s := "CONST";
  |DefinitionSym     : s := "DEFINITION";
  |DivSym            : s := "DIV";
  |DoSym             : s := "DO";
  |ElseSym           : s := "ELSE";
  |ElsifSym          : s := "ELSIF";
  |EndSym            : s := "END";
  |ExitSym           : s := "EXIT";
  |ExceptSym         : s := "EXCEPT";
  |ExportSym         : s := "EXPORT";
  |FinallySym        : s := "FINALLY";
  |ForSym            : s := "FOR";
  |ForwardSym        : s := "FORWARD";
  |FromSym           : s := "FROM";
  |IfSym             : s := "IF";
  |ImplementationSym : s := "IMPLEMENTATION";
  |ImportSym         : s := "IMPORT";
  |InSym             : s := "IN";
  |LoopSym           : s := "LOOP";
  |ModSym            : s := "MOD";
  |ModuleSym         : s := "MODULE";
  |OfSym             : s := "OF";
  |OrSym             : s := "OR";
  |PackedsetSym      : s := "PACKEDSET";
  |PointerSym        : s := "POINTER";
  |ProcedureSym      : s := "PROCEDURE";
  |QualifiedSym      : s := "QUALIFIED";
  |RecordSym         : s := "RECORD";
  |RemSym            : s := "REM";
  |RetrySym          : s := "RETRY";
  |RepeatSym         : s := "REPEAT";
  |ReturnSym         : s := "RETURN";
  |SetSym            : s := "SET";
  |ThenSym           : s := "THEN";
  |ToSym             : s := "TO";
  |TypeSym           : s := "TYPE";
  |UntilSym          : s := "UNTIL";
  |VarSym            : s := "VAR";
  |WhileSym          : s := "WHILE";
  |WithSym           : s := "WITH";
  |NumberSym         : s := "<Number>";
  |StringSym         : s := "<String>";
  |IdentSym          : s := "<Ident>";
  |CtrlCh            : s := "<Control Char>";
  |Option            : s := "<Option>";
  |Comment           : s := "<Comment>";
  |UnexpectedEol     : s := "<Unexpected Eol>";
  |UnexpectedEof     : s := "<Unexpected Eof>";
  |EofSym            : s := "<Eof>";
 ELSE                  s := "<Error>";
 END;
 ISOStrings.Assign(s, str);
 done := ISOStrings.CanAssignAll(ISOStrings.Length(s), str);
END GetSymStr;

(*--------------------------------------------------------------------------*)

PROCEDURE IsElem ((* EIN/ -- *)     sym : Symbols;
                  (* EIN/ -- *) VAR set : SymbolSet ): BOOLEAN;

BEGIN
 RETURN(   VAL(WORDSETRANGE,VAL(UNSIGNEDWORD,sym) MOD 16)
        IN set[VAL(UNSIGNEDWORD,sym) DIV 16]);
END IsElem;

(*--------------------------------------------------------------------------*)

PROCEDURE Clear ((* -- /AUS *) VAR set : SymbolSet );

VAR i : UNSIGNEDWORD;

BEGIN
 FOR i := 0 TO NWSets - 1 DO
   set[i] := WORDSET{};
 END
END Clear;

(*--------------------------------------------------------------------------*)

PROCEDURE Incl ((* EIN/ -- *)     sym : Symbols;
                (* EIN/AUS *) VAR set : SymbolSet );

BEGIN
 INCL(set[VAL(UNSIGNEDWORD,sym) DIV 16],
      VAL(WORDSETRANGE,VAL(UNSIGNEDWORD,sym) MOD 16));
END Incl;

END M2Syms.

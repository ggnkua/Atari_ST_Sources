IMPLEMENTATION MODULE LongConv;
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
(****************************************************************************)
(* 27-Okt-95, Holger Kleinschmidt                                           *)
(****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

#if !ISO_recursive_proc_decl
FROM SYSTEM IMPORT ADR;
FROM PORTAB IMPORT ANYTYPE;
#endif

FROM PORTAB IMPORT
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD;

IMPORT ConvTypes, EXCEPTIONS, LowLong;

FROM FConvBase IMPORT
(* CONST*) MaxLExp, MinLExp,
(* PROC *) FloatLength, FixLength, strToReal;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#if !ISO_recursive_proc_decl
TYPE
  ScanStatePtr = POINTER TO ConvTypes.ScanState;
#endif

VAR
  longConvSource : EXCEPTIONS.ExceptionSource;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#if (defined HM2)
(*$E+*)
#endif
PROCEDURE Term ((* EIN/ -- *)     inputCh   : CHAR;
                (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
                (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
                (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
 chClass   := ConvTypes.terminator;
#if ISO_recursive_proc_decl
 nextState := Term;
#else
 stateP  := CAST(ScanStatePtr,ADR(nextState));
 stateP^ := Term;
#endif
END Term;

(*---------------------------------------------------------------------------*)

PROCEDURE WE ((* EIN/ -- *)     inputCh   : CHAR;
              (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
              (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
              (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
#if ISO_recursive_proc_decl
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass   := ConvTypes.valid;
   nextState := WE;
 ELSE
   chClass   := ConvTypes.terminator;
   nextState := Term;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := ConvTypes.valid;
   stateP^ := WE;
 ELSE
   chClass := ConvTypes.terminator;
   stateP^ := Term;
 END;
#endif
END WE;

(*---------------------------------------------------------------------------*)

PROCEDURE SE ((* EIN/ -- *)     inputCh   : CHAR;
              (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
              (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
              (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
#if ISO_recursive_proc_decl
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass   := ConvTypes.valid;
   nextState := WE;
 ELSE
   chClass   := ConvTypes.invalid;
   nextState := SE;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := ConvTypes.valid;
   stateP^ := WE;
 ELSE
   chClass := ConvTypes.invalid;
   stateP^ := SE;
 END;
#endif
END SE;

(*---------------------------------------------------------------------------*)

PROCEDURE E ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
             (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
             (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
#if ISO_recursive_proc_decl
 CASE inputCh OF
   '-','+' : chClass   := ConvTypes.valid;
             nextState := SE;
  |'0'..'9': chClass   := ConvTypes.valid;
             nextState := WE;
 ELSE        chClass   := ConvTypes.invalid;
             nextState := E;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 CASE inputCh OF
   '-','+' : chClass := ConvTypes.valid;
             stateP^ := SE;
  |'0'..'9': chClass := ConvTypes.valid;
             stateP^ := WE;
 ELSE        chClass := ConvTypes.invalid;
             stateP^ := E;
 END;
#endif
END E;

(*---------------------------------------------------------------------------*)

PROCEDURE F ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
             (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
             (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
#if ISO_recursive_proc_decl
 CASE inputCh OF
   '0'..'9': chClass   := ConvTypes.valid;
             nextState := F;
  |'E', 'e': chClass   := ConvTypes.valid;
             nextState := E;
 ELSE        chClass   := ConvTypes.terminator;
             nextState := Term;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 CASE inputCh OF
   '0'..'9': chClass := ConvTypes.valid;
             stateP^ := F;
  |'E', 'e': chClass := ConvTypes.valid;
             stateP^ := E;
 ELSE        chClass := ConvTypes.terminator;
             stateP^ := Term;
 END;
#endif
END F;

(*---------------------------------------------------------------------------*)

PROCEDURE P ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
             (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
             (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
#if ISO_recursive_proc_decl
 CASE inputCh OF
   '0'..'9': chClass   := ConvTypes.valid;
             nextState := P;
  |'.'     : chClass   := ConvTypes.valid;
             nextState := F;
  |'E', 'e': chClass   := ConvTypes.valid;
             nextState := E;
 ELSE        chClass   := ConvTypes.terminator;
             nextState := Term;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 CASE inputCh OF
   '0'..'9': chClass := ConvTypes.valid;
             stateP^ := P;
  |'.'     : chClass := ConvTypes.valid;
             stateP^ := F;
  |'E', 'e': chClass := ConvTypes.valid;
             stateP^ := E;
 ELSE        chClass := ConvTypes.terminator;
             stateP^ := Term;
 END;
#endif
END P;

(*---------------------------------------------------------------------------*)

PROCEDURE RS ((* EIN/ -- *)     inputCh   : CHAR;
              (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
              (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
              (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
#if ISO_recursive_proc_decl
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass   := ConvTypes.valid;
   nextState := P;
 ELSE
   chClass   := ConvTypes.invalid;
   nextState := RS;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := ConvTypes.valid;
   stateP^ := P;
 ELSE
   chClass := ConvTypes.invalid;
   stateP^ := RS;
 END;
#endif
END RS;

(*---------------------------------------------------------------------------*)

PROCEDURE ScanReal ((* EIN/ -- *)     inputCh   : CHAR;
                    (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
                    (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
                    (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
#if ISO_recursive_proc_decl
 CASE inputCh OF
   ' '     : chClass   := ConvTypes.padding;
             nextState := ScanReal;
  |'-','+' : chClass   := ConvTypes.valid;
             nextState := RS;
  |'0'..'9': chClass   := ConvTypes.valid;
             nextState := P;
 ELSE        chClass   := ConvTypes.invalid;
             nextState := ScanReal;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 CASE inputCh OF
   ' '     : chClass := ConvTypes.padding;
             stateP^ := ScanReal;
  |'-','+' : chClass := ConvTypes.valid;
             stateP^ := RS;
  |'0'..'9': chClass := ConvTypes.valid;
             stateP^ := P;
 ELSE        chClass := ConvTypes.invalid;
             stateP^ := ScanReal;
 END;
#endif
END ScanReal;
#if (defined HM2)
(*$E=*)
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE FormatReal ((* EIN/ -- *) str : ARRAY OF CHAR ): ConvResults;

VAR res  : ConvTypes.ConvResults;
    void : LONGREAL;

BEGIN
 void := strToReal(str, LowLong.small, MinLExp, LowLong.large, MaxLExp, res);
 RETURN(res);
END FormatReal;

(*---------------------------------------------------------------------------*)

PROCEDURE ValueReal ((* EIN/ -- *) str : ARRAY OF CHAR ): LONGREAL;

VAR res : ConvTypes.ConvResults;
    val : LONGREAL;

BEGIN
 val := strToReal(str, LowLong.small, MinLExp, LowLong.large, MaxLExp, res);
 IF (res # ConvTypes.strAllRight) & (res # ConvTypes.strOutOfRange) THEN
   EXCEPTIONS.RAISE(longConvSource, ORD(res),
                    "LongConv.ValueReal: invalid real format");
 ELSE
   RETURN(val);
 END;
END ValueReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthFloatReal ((* EIN/ -- *) real    : LONGREAL;
                           (* EIN/ -- *) sigFigs : CARDINAL ): CARDINAL;
BEGIN
 RETURN(VAL(CARDINAL,FloatLength(real, FALSE, TRUE, VAL(UNSIGNEDWORD,sigFigs))));
END LengthFloatReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthEngReal ((* EIN/ -- *) real    : LONGREAL;
                         (* EIN/ -- *) sigFigs : CARDINAL ): CARDINAL;
BEGIN
 RETURN(VAL(CARDINAL,FloatLength(real, TRUE, TRUE, VAL(UNSIGNEDWORD,sigFigs))));
END LengthEngReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthFixedReal ((* EIN/ -- *) real  : LONGREAL;
                           (* EIN/ -- *) place : INTEGER ): CARDINAL;
BEGIN
 RETURN(VAL(CARDINAL,FixLength(real, TRUE, VAL(SIGNEDWORD,place))));
END LengthFixedReal;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRConvException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(longConvSource));
END IsRConvException;

(*===========================================================================*)

BEGIN (* LongConv *)
 EXCEPTIONS.AllocateSource(longConvSource);
END LongConv.

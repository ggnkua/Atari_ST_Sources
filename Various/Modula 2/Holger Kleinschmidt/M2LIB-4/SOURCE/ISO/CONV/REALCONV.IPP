IMPLEMENTATION MODULE RealConv;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_REAL__
(*$!r+: Modul muss mit $r- uebersetzt werden! *)
#else
(*$!r-: Modul muss mit $r+ uebersetzt werden! *)
#endif
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

IMPORT ConvTypes, EXCEPTIONS;
#if (defined HM2) && (defined __LONG_REAL__)
IMPORT LowLong;
#else
IMPORT LowReal;
#endif

FROM FConvBase IMPORT
#if (defined HM2) && (defined __LONG_REAL__)
(* CONST*) MaxLExp, MinLExp,
(* TYPE *) RealFormat,
(* PROC *) FloatLength, FixLength, strToReal, formLen, checkLReal;
#else
(* CONST*) MaxExp, MinExp,
(* TYPE *) RealFormat,
(* PROC *) FloatLength, FixLength, strToReal, formLen, checkReal;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#if !ISO_recursive_proc_decl
TYPE
  ScanStatePtr = POINTER TO ConvTypes.ScanState;
#endif

VAR
  realConvSource : EXCEPTIONS.ExceptionSource;

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
    void : REAL;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 void := strToReal(str, LowLong.small, MinLExp, LowLong.large, MaxLExp, res);
#elif (defined TDIM2)
 void := SHORT(strToReal(str, LONG(LowReal.small), MinExp, LONG(LowReal.large), MaxExp, res));
#else
 void := strToReal(str, LowReal.small, MinExp, LowReal.large, MaxExp, res);
#endif
 RETURN(res);
END FormatReal;

(*---------------------------------------------------------------------------*)

PROCEDURE ValueReal ((* EIN/ -- *) str : ARRAY OF CHAR ): REAL;

VAR res : ConvTypes.ConvResults;
    val : REAL;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 val := strToReal(str, LowLong.small, MinLExp, LowLong.large, MaxLExp, res);
#elif (defined TDIM2)
 val := SHORT(strToReal(str, LONG(LowReal.small), MinExp, LONG(LowReal.large), MaxExp, res));
#else
 val := strToReal(str, LowReal.small, MinExp, LowReal.large, MaxExp, res);
#endif
 IF (res # ConvTypes.strAllRight) & (res # ConvTypes.strOutOfRange) THEN
   EXCEPTIONS.RAISE(realConvSource, ORD(res),
                    "RealConv.ValueReal: invalid real format");
 ELSE
   RETURN(val);
 END;
END ValueReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthFloatReal ((* EIN/ -- *) real    : REAL;
                           (* EIN/ -- *) sigFigs : CARDINAL ): CARDINAL;

VAR form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) THEN
#else
 IF checkReal(real, form) THEN
#endif
#ifdef TDIM2
   RETURN(VAL(CARDINAL,FloatLength(LONG(real), FALSE, FALSE, VAL(UNSIGNEDWORD,sigFigs))));
#else
#if (defined HM2) && (defined __LONG_REAL__)
   RETURN(VAL(CARDINAL,FloatLength(real, FALSE, TRUE, VAL(UNSIGNEDWORD,sigFigs))));
#else
   RETURN(VAL(CARDINAL,FloatLength(real, FALSE, FALSE, VAL(UNSIGNEDWORD,sigFigs))));
#endif
#endif
 ELSE
   RETURN(formLen(form));
 END;
END LengthFloatReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthEngReal ((* EIN/ -- *) real    : REAL;
                         (* EIN/ -- *) sigFigs : CARDINAL ): CARDINAL;

VAR form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) THEN
#else
 IF checkReal(real, form) THEN
#endif
#ifdef TDIM2
   RETURN(VAL(CARDINAL,FloatLength(LONG(real), TRUE, FALSE, VAL(UNSIGNEDWORD,sigFigs))));
#else
#if (defined HM2) && (defined __LONG_REAL__)
   RETURN(VAL(CARDINAL,FloatLength(real, TRUE, TRUE, sigFigs)));
#else
   RETURN(VAL(CARDINAL,FloatLength(real, TRUE, FALSE, sigFigs)));
#endif
#endif
 ELSE
   RETURN(formLen(form));
 END;
END LengthEngReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthFixedReal ((* EIN/ -- *) real  : REAL;
                           (* EIN/ -- *) place : INTEGER ): CARDINAL;

VAR form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) THEN
#else
 IF checkReal(real, form) THEN
#endif
#ifdef TDIM2
   RETURN(VAL(CARDINAL,FixLength(LONG(real), FALSE, VAL(SIGNEDWORD,place))));
#else
#if (defined HM2) && (defined __LONG_REAL__)
   RETURN(VAL(CARDINAL,FixLength(real, TRUE, VAL(SIGNEDWORD,place))));
#else
   RETURN(VAL(CARDINAL,FixLength(real, FALSE, VAL(SIGNEDWORD,place))));
#endif
#endif
 ELSE
   RETURN(formLen(form));
 END;
END LengthFixedReal;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRConvException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(realConvSource));
END IsRConvException;

(*===========================================================================*)

BEGIN (* RealConv *)
 EXCEPTIONS.AllocateSource(realConvSource);
END RealConv.

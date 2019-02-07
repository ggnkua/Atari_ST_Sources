IMPLEMENTATION MODULE StdInOut;
__IMP_SWITCHES__
__DEBUG__
__DRIVER__
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
(* 24-Jul-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

#define _echo ((defined LPRM2) || (defined SPCM2) || (defined HM2) || \
(defined TDIM2))

VAL_INTRINSIC
CAST_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNED, UNSIGNEDWORD;

IMPORT IOConsts;

FROM IOLink IMPORT
(* TYPE *) DeviceTable, DeviceTablePtr;

FROM StdChanBase IMPORT
(* VAR  *) StdInChanId, StdOutChanId, StdErrChanId;

IMPORT InOut, types;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  LOOKED : BOOLEAN;
  cbuf   : CHAR;

(*===========================================================================*)
(* Geraeteprozeduren fuer den 'StdIn'-Kanal                                  *)
(*===========================================================================*)

#ifdef HM2
(*$E+*)
#endif
PROCEDURE inLook ((* EIN/ -- *)     tid : DeviceTablePtr;
                  (* -- /AUS *) VAR ch  : CHAR;
                  (* -- /AUS *) VAR res : IOConsts.ReadResults );

BEGIN
 IF ~LOOKED THEN
   InOut.Read(cbuf);
   LOOKED := TRUE;
 END;
 ch := cbuf;
 IF (cbuf = types.CR) OR (cbuf = types.LF) THEN
   res := IOConsts.endOfLine;
 ELSIF cbuf = types.EOT THEN
   res := IOConsts.endOfInput;
 ELSE
   res := IOConsts.allRight;
 END;
 tid^.result := res;
END inLook;

(*---------------------------------------------------------------------------*)

PROCEDURE inSkip ((* EIN/ -- *) tid : DeviceTablePtr );

VAR c : CHAR;

BEGIN
 IF LOOKED THEN
   LOOKED := FALSE;
   c      := cbuf;
 ELSE
   InOut.Read(c);
 END;
#if _echo
 InOut.Write(c);
#endif
 tid^.result := IOConsts.allRight;
END inSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE inSkipLook ((* EIN/ -- *)     tid : DeviceTablePtr;
                      (* -- /AUS *) VAR ch  : CHAR;
                      (* -- /AUS *) VAR res : IOConsts.ReadResults );

BEGIN
 inSkip(tid);
 inLook(tid, ch, res);
END inSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE inRawRead ((* EIN/ -- *)     tid       : DeviceTablePtr;
                     (* EIN/ -- *)     to        : ADDRESS;
                     (* EIN/ -- *)     maxChars  : UNSIGNED;
                     (* -- /AUS *) VAR charsRead : UNSIGNED       );

VAR c   : CHAR;
    ptr : types.StrPtr;
    i   : UNSIGNEDWORD;

BEGIN
 ptr := CAST(types.StrPtr,to);
 i   := 0;
 IF maxChars = VAL(UNSIGNED,0) THEN
   charsRead   := 0;
   tid^.result := IOConsts.allRight;
   RETURN;
 END;

 IF LOOKED THEN
   c := cbuf;
 ELSE
   InOut.Read(c);
 END;

 WHILE maxChars > VAL(UNSIGNED,0) DO
   IF c = types.EOT THEN
     LOOKED      := TRUE;
     cbuf        := c;
     charsRead   := VAL(UNSIGNED,i);
     tid^.result := IOConsts.endOfInput;
     RETURN;
   END;
#if _echo
   InOut.Write(c);
#endif
   ptr^[i] := c;
   INC(i);
   DEC(maxChars);
   InOut.Read(c);
 END;
 LOOKED    := TRUE;
 cbuf      := c;
 charsRead := VAL(UNSIGNED,i);
 IF i > 0 THEN
   tid^.result := IOConsts.allRight;
 END;
END inRawRead;

(*---------------------------------------------------------------------------*)

PROCEDURE inTextRead ((* EIN/ -- *)     tid       : DeviceTablePtr;
                      (* EIN/ -- *)     to        : ADDRESS;
                      (* EIN/ -- *)     maxChars  : UNSIGNED;
                      (* -- /AUS *) VAR charsRead : UNSIGNED       );

VAR c   : CHAR;
    ptr : types.StrPtr;
    i   : UNSIGNEDWORD;

BEGIN
 ptr := CAST(types.StrPtr,to);
 i   := 0;
 IF maxChars = VAL(UNSIGNED,0) THEN
   charsRead   := 0;
   tid^.result := IOConsts.allRight;
   RETURN;
 END;

 IF LOOKED THEN
   c := cbuf;
 ELSE
   InOut.Read(c);
 END;

 LOOP
   IF maxChars = VAL(UNSIGNED,0) THEN
     EXIT;
   END;
   IF (c = types.CR) OR (c = types.LF) THEN
     tid^.result := IOConsts.endOfLine;
     EXIT;
   ELSIF c = types.EOT THEN
     tid^.result := IOConsts.endOfInput;
     EXIT;
   END;
#if _echo
   InOut.Write(c);
#endif
   ptr^[i] := c;
   INC(i);
   DEC(maxChars);
   InOut.Read(c);
 END;
 LOOKED    := TRUE;
 cbuf      := c;
 charsRead := VAL(UNSIGNED,i);
 IF i > 0 THEN
   tid^.result := IOConsts.allRight;
 END;
END inTextRead;

(*===========================================================================*)
(* Geraeteprozeduren fuer den 'StdOut'-Kanal                                 *)
(*===========================================================================*)

PROCEDURE outWriteLn ((* -- / -- *) tid : DeviceTablePtr );
BEGIN
 InOut.WriteLn;
END outWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE outRawWrite ((* -- / -- *) tid          : DeviceTablePtr;
                       (* EIN/ -- *) from         : ADDRESS;
                       (* EIN/ -- *) charsToWrite : UNSIGNED       );

VAR c   : CHAR;
    ptr : types.StrPtr;
    i   : UNSIGNEDWORD;

BEGIN
 ptr := CAST(types.StrPtr,from);
 i   := 0;
 WHILE charsToWrite > VAL(UNSIGNED,0) DO
   InOut.Write(ptr^[i]);
   INC(i);
   DEC(charsToWrite);
 END;
END outRawWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE outTextWrite ((* -- / -- *) tid          : DeviceTablePtr;
                        (* EIN/ -- *) from         : ADDRESS;
                        (* EIN/ -- *) charsToWrite : UNSIGNED       );


VAR c   : CHAR;
    ptr : types.StrPtr;
    i   : UNSIGNEDWORD;

BEGIN
 ptr := CAST(types.StrPtr,from);
 i   := 0;
 WHILE charsToWrite > VAL(UNSIGNED,0) DO
   InOut.Write(ptr^[i]);
   INC(i);
   DEC(charsToWrite);
 END;
END outTextWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE outFlush ((* -- / -- *) tid : DeviceTablePtr );
END outFlush;
#ifdef HM2
(*$E=*)
#endif

(*===========================================================================*)

BEGIN
 LOOKED := FALSE;
 cbuf   := 0C;

 WITH StdInChanId^ DO
   doLook     := inLook;
   doSkip     := inSkip;
   doSkipLook := inSkipLook;
   doRawRead  := inRawRead;
   doTextRead := inTextRead;
 END;

 WITH StdOutChanId^ DO
   doWriteLn   := outWriteLn;
   doRawWrite  := outRawWrite;
   doTextWrite := outTextWrite;
   doFlush     := outFlush;
 END;

 WITH StdErrChanId^ DO
   doLook      := inLook;
   doSkip      := inSkip;
   doSkipLook  := inSkipLook;
   doRawRead   := inRawRead;
   doTextRead  := inTextRead;

   doWriteLn   := outWriteLn;
   doRawWrite  := outRawWrite;
   doTextWrite := outTextWrite;
 END;
END StdInOut.

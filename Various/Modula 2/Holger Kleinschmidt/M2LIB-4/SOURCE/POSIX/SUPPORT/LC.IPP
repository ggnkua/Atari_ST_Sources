IMPLEMENTATION MODULE LC;
__IMP_SWITCHES__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD;

IMPORT LCPOSIX;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR id : UNSIGNEDWORD;

BEGIN
 (* Bei Progammstart gilt das POSIX/C-Locale *)
 Time       := LCPOSIX.Time;
 Numeric    := LCPOSIX.Numeric;
 Monetary   := LCPOSIX.Monetary;
 Ctype      := LCPOSIX.Ctype;
 Messages   := LCPOSIX.Messages;

 FOR id := 0 TO 5 DO
   Idents[id] := LCPOSIX.Ident;
 END;
END LC.

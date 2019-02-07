IMPLEMENTATION MODULE TConvUtil;
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

(* 10-Aug-96, Holger Kleinschmidt *)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD;

FROM ISOStrings IMPORT
(* PROC *) Equal, Length;

FROM ConvTypes IMPORT
(* TYPE *) ConvResults, ScanClass, ScanState;

FROM InOut IMPORT WriteString, Write, WriteLn, WriteCard;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  EOS = 0C;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE PutRes ((* EIN/ -- *) res : ConvResults );
BEGIN
 CASE res OF
   strAllRight    : WriteString(" strAllRight");
  |strOutOfRange  : WriteString(" strOutOfRange");
  |strWrongFormat : WriteString(" strWrongFormat");
  |strEmpty       : WriteString(" strEmpty");
 END;
END PutRes;

PROCEDURE PutClass ((* EIN/ -- *) class : ScanClass );
BEGIN
 CASE class OF
   padding    : WriteString(" padding");
  |valid      : WriteString(" valid");
  |invalid    : WriteString(" invalid");
  |terminator : WriteString(" terminator");
 END;
END PutClass;

PROCEDURE WriteStrErr ((* EIN/ -- *) VAR str      : ARRAY OF CHAR;
                       (* EIN/ -- *)     len      : CARDINAL;
                       (* EIN/ -- *) VAR expected : ARRAY OF CHAR );

VAR rlen : CARDINAL;

BEGIN
 rlen := Length(str);
 IF Equal(str, expected) & (len = rlen) THEN
   WriteString(" OK");
 ELSE
   WriteLn;
   WriteString("*** berechnet: "); WriteLn;
   WriteString("*** L„nge = "); WriteCard(len, 1); WriteLn;
   WriteString("*** Repr. = "); WriteString(str); WriteLn;
   WriteString("+++ erwartet: "); WriteLn;
   WriteString("+++ L„nge = "); WriteCard(rlen, 1); WriteLn;
   WriteString("+++ Repr. = "); WriteString(expected);
 END;
 WriteLn;
END WriteStrErr;

PROCEDURE FindNum ((* EIN/ -- *) VAR repr  : ARRAY OF CHAR;
                   (* EIN/ -- *)     state : ScanState;
                   (* -- /AUS *) VAR first : CARDINAL;
                   (* -- /AUS *) VAR next  : CARDINAL;
                   (* -- /AUS *) VAR termC : ScanClass     );

VAR
  ch    : CHAR;
  len   : UNSIGNEDWORD;
  index : UNSIGNEDWORD;
  class : ScanClass;

BEGIN
 len   := Length(repr);
 index := 0;
 first := VAL(CARDINAL,len);
 LOOP
   IF index = len THEN
     ch := EOS;
   ELSE
     ch := repr[index];
   END;
   state(ch, class, state);
   CASE class OF
     padding:
    |valid:
       IF VAL(CARDINAL,index) < first THEN
         first := VAL(CARDINAL,index);
       END;
    |invalid, terminator:
       IF VAL(CARDINAL,index) < first THEN
         first := VAL(CARDINAL,index);
       END;
       EXIT;
   END;
   INC(index);
 END;
 next  := VAL(CARDINAL,index);
 termC := class;
END FindNum;

PROCEDURE TestScan ((* EIN/ -- *) VAR repr  : ARRAY OF CHAR;
                    (* EIN/ -- *)     state : ScanState;
                    (* EIN/ -- *)     first : CARDINAL;
                    (* EIN/ -- *)     next  : CARDINAL;
                    (* EIN/ -- *)     term  : ScanClass     );

VAR f  : CARDINAL;
    n  : CARDINAL;
    t  : ScanClass;

BEGIN
 FindNum(repr, state, f, n, t);
 IF (f = first) & (n = next) & (t = term) THEN
   WriteString(" OK");
 ELSE
   WriteLn;
   WriteString("*** berechnet: "); WriteLn;
   WriteString("***   erstes: "); WriteCard(f, 1); WriteLn;
   WriteString("*** n„chstes: "); WriteCard(n, 1); PutClass(t);WriteLn;
   WriteString("+++ erwartet: "); WriteLn;
   WriteString("+++   erstes: "); WriteCard(first, 1); WriteLn;
   WriteString("+++ n„chstes: "); WriteCard(next, 1); PutClass(term);
 END;
 WriteLn;
END TestScan;

END TConvUtil.

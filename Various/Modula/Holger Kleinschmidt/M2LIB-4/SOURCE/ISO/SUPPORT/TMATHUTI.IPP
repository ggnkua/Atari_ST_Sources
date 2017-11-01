IMPLEMENTATION MODULE TMathUtil;
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

(* 01-Feb-95, Holger Kleinschmidt *)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) SIGNED, UNSIGNED;

FROM InOut IMPORT WriteString, Write, WriteLn, WriteInt;
FROM pOUT IMPORT PutInt, PutCard, PutReal;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE WriteErr ((* EIN/ -- *) x        : REAL;
                    (* EIN/ -- *) expected : REAL );

VAR e : REAL;

BEGIN
 IF expected # 0.0 THEN
   WriteString("rel.F.: ");
   e := ABS((x - expected) / expected);
 ELSE
   WriteString("abs.F.: ");
   e := ABS(x);
 END;
 IF e = 0.0 THEN
   WriteString("exakt innerhalb Stellenzahl, OK");
 ELSE
   PutReal(e, 10);
   IF e < MaxErr THEN
     WriteString(", OK");
   ELSE
     WriteLn;
     WriteString("*** berechnet: "); PutReal(x, Digs); WriteLn;
     WriteString("+++  erwartet: "); PutReal(expected, Digs);
   END;
 END;
 WriteLn;
END WriteErr;

PROCEDURE TestR2R ((* EIN/ -- *) arg      : REAL;
                   (* EIN/ -- *) expected : REAL );

BEGIN
 WriteString(procname);
 Write('(');
 PutReal(arg, Digs);
 WriteString(") : ");
 WriteErr(procR2R(arg), expected);
END TestR2R;

PROCEDURE TestRR2R ((* EIN/ -- *) arg1     : REAL;
                    (* EIN/ -- *) arg2     : REAL;
                    (* EIN/ -- *) expected : REAL );

BEGIN
 WriteString(procname);
 Write('(');
 PutReal(arg1, Digs);
 Write(',');
 PutReal(arg2, Digs);
 WriteString(") : ");
 WriteErr(procRR2R(arg1, arg2), expected);
END TestRR2R;

PROCEDURE TestI2R ((* EIN/ -- *) arg      : SIGNED;
                   (* EIN/ -- *) expected : REAL   );

BEGIN
 WriteString(procname);
 Write('(');
 PutInt(arg, 1);
 WriteString(") : ");
 WriteErr(procI2R(arg), expected);
END TestI2R;

PROCEDURE TestC2R ((* EIN/ -- *) arg      : UNSIGNED;
                   (* EIN/ -- *) expected : REAL     );

BEGIN
 WriteString(procname);
 Write('(');
 PutCard(arg, 1);
 WriteString(") : ");
 WriteErr(procC2R(arg), expected);
END TestC2R;

PROCEDURE TestR2I ((* EIN/ -- *) arg      : REAL;
                   (* EIN/ -- *) expected : SIGNED );

VAR res : SIGNED;

BEGIN
 WriteString(procname);
 Write('(');
 PutReal(arg, Digs);
 WriteString(") :");
 res := procR2I(arg);
 IF res = expected THEN
   WriteString(" OK");
 ELSE
   WriteLn;
   WriteString("*** berechnet: "); PutInt(res, 1); WriteLn;
   WriteString("+++  erwartet: "); PutInt(expected, 1);
 END;
 WriteLn;
END TestR2I;

PROCEDURE TestR2C ((* EIN/ -- *) arg      : REAL;
                   (* EIN/ -- *) expected : UNSIGNED );

VAR res : UNSIGNED;

BEGIN
 WriteString(procname);
 Write('(');
 PutReal(arg, Digs);
 WriteString(") :");
 res := procR2C(arg);
 IF res = expected THEN
   WriteString(" OK");
 ELSE
   WriteLn;
   WriteString("*** berechnet: "); PutCard(res, 1); WriteLn;
   WriteString("+++  erwartet: "); PutCard(expected, 1);
 END;
 WriteLn;
END TestR2C;

BEGIN (* TMathUtil *)
 MaxErr := 1.0E-5;
 Digs   := 16;
END TMathUtil.

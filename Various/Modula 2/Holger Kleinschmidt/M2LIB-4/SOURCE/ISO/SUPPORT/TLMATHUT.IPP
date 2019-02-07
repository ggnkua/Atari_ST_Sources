IMPLEMENTATION MODULE TLMathUtil;
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

(* 12-Sep-95, Holger Kleinschmidt *)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) SIGNED, UNSIGNED;

FROM InOut IMPORT WriteString, Write, WriteLn, WriteInt;
FROM pOUT IMPORT PutInt, PutCard, PutLReal;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if LONGREAL_var
TYPE
  lrc = RECORD
    CASE : BOOLEAN OF
      FALSE : lr  : LONGREAL;
     |TRUE  : lc1 : LONGCARD;
              lc2 : LONGCARD;
    END;
  END;

VAR
  cast : lrc;

VAR
  null : LONGREAL;
#else
CONST
  null = LRC(0.0,0);
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE WriteErr ((* EIN/ -- *) x        : LONGREAL;
                    (* EIN/ -- *) expected : LONGREAL );

VAR e : LONGREAL;

BEGIN
 IF expected # null THEN
   WriteString("rel.F.: ");
   e := ABS((x - expected) / expected);
 ELSE
   WriteString("abs.F.: ");
   e := ABS(x);
 END;
 IF e = null THEN
   WriteString("exakt innerhalb Stellenzahl, OK");
 ELSE
   PutLReal(e, 10);
   IF e < MaxErr THEN
     WriteString(", OK");
   ELSE
     WriteLn;
     WriteString("*** berechnet: "); PutLReal(x, Digs); WriteLn;
     WriteString("+++  erwartet: "); PutLReal(expected, Digs);
   END;
 END;
 WriteLn;
END WriteErr;

PROCEDURE TestR2R ((* EIN/ -- *) arg      : LONGREAL;
                   (* EIN/ -- *) expected : LONGREAL );

BEGIN
 WriteString(procname);
 Write('(');
 PutLReal(arg, Digs);
 WriteString(") : ");
 WriteErr(procR2R(arg), expected);
END TestR2R;

PROCEDURE TestRR2R ((* EIN/ -- *) arg1     : LONGREAL;
                    (* EIN/ -- *) arg2     : LONGREAL;
                    (* EIN/ -- *) expected : LONGREAL );

BEGIN
 WriteString(procname);
 Write('(');
 PutLReal(arg1, Digs);
 Write(',');
 PutLReal(arg2, Digs);
 WriteString(") : ");
 WriteErr(procRR2R(arg1, arg2), expected);
END TestRR2R;

PROCEDURE TestI2R ((* EIN/ -- *) arg      : SIGNED;
                   (* EIN/ -- *) expected : LONGREAL   );

BEGIN
 WriteString(procname);
 Write('(');
 PutInt(arg, 1);
 WriteString(") : ");
 WriteErr(procI2R(arg), expected);
END TestI2R;

PROCEDURE TestC2R ((* EIN/ -- *) arg      : UNSIGNED;
                   (* EIN/ -- *) expected : LONGREAL     );

BEGIN
 WriteString(procname);
 Write('(');
 PutCard(arg, 1);
 WriteString(") : ");
 WriteErr(procC2R(arg), expected);
END TestC2R;

PROCEDURE TestR2I ((* EIN/ -- *) arg      : LONGREAL;
                   (* EIN/ -- *) expected : SIGNED );

VAR res : SIGNED;

BEGIN
 WriteString(procname);
 Write('(');
 PutLReal(arg, Digs);
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

PROCEDURE TestR2C ((* EIN/ -- *) arg      : LONGREAL;
                   (* EIN/ -- *) expected : UNSIGNED );

VAR res : UNSIGNED;

BEGIN
 WriteString(procname);
 Write('(');
 PutLReal(arg, Digs);
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

BEGIN (* TLMathUtil *)
#if LONGREAL_var
 WITH cast DO
   lc1 := 000000000H; lc2 := 000000000H; null := lr;
   lc1 := 03DDB7CDFH; lc2 := 0D9D7BDBAH; MaxErr := lr; (* 1.0000000000000E-10 *)
 END;
#else
 MaxErr := 1.0E-10;
#endif
 Digs   := 16;
END TLMathUtil.

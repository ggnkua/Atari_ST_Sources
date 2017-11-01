IMPLEMENTATION MODULE DosTime;
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
(* 06-Jan-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, UNSIGNEDLONG, WORDSET;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
#if reverse_set
  SecMask  = WORDSET{11..15}; (* 0..29 ( x 2 ) *)
  MinMask  = WORDSET{5..10};  (* 0..59 *)
  HourMask = WORDSET{0..4};   (* 0..23 *)

  DayMask  = WORDSET{11..15}; (* 1..31 *)
  MonMask  = WORDSET{7..10};  (* 1..12 *)
  YearMask = WORDSET{0..6};   (* 0..119 ( + 1980 ) *)
#else
  SecMask  = WORDSET{0..4};   (* 0..29 ( x 2 ) *)
  MinMask  = WORDSET{5..10};  (* 0..59 *)
  HourMask = WORDSET{11..15}; (* 0..23 *)

  DayMask  = WORDSET{0..4};   (* 1..31 *)
  MonMask  = WORDSET{5..8};   (* 1..12 *)
  YearMask = WORDSET{9..15};  (* 0..119 ( + 1980 ) *)
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE DecodeDate ((* EIN/ -- *)     date    : WORDSET;
                      (* EIN/ -- *)     time    : WORDSET;
                      (* -- /AUS *) VAR decoded : DosDate );

BEGIN
 WITH decoded DO
   year := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,date * YearMask) DIV 512 + 1980);
   mon  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,date * MonMask) DIV 32);
   day  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,date * DayMask));
   IF mon > 0 THEN
     DEC(mon);
   END;

   hour := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,time * HourMask) DIV 2048);
   min  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,time * MinMask) DIV 32);
   sec  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,time * SecMask) * 2);
 END;
END DecodeDate;

(*---------------------------------------------------------------------------*)

PROCEDURE EncodeDate ((* EIN/ -- *) VAR encoded : DosDate;
                      (* -- /AUS *) VAR date    : WORDSET;
                      (* -- /AUS *) VAR time    : WORDSET );

BEGIN
 WITH encoded DO
   date :=
       CAST(WORDSET,VAL(UNSIGNEDWORD,(year - 1980) * 512)) * YearMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,(mon + 1) * 32)) * MonMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,day)) * DayMask;

   time :=
       CAST(WORDSET,VAL(UNSIGNEDWORD,hour * 2048)) * HourMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,min * 32)) * MinMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,sec DIV 2)) * SecMask;
 END;
END EncodeDate;

(*---------------------------------------------------------------------------*)

PROCEDURE DateToSeconds ((* EIN/ -- *) VAR date : DosDate ): UNSIGNEDLONG;
BEGIN
 WITH date DO
   RETURN(VAL(UNSIGNEDLONG,  (year - 1970) * 365
                           + (year - 1969) DIV 4
                           + MonthDays[year MOD 4 = 0][mon]
                           + day - 1
          ) * SECSPERDAY
          + VAL(UNSIGNEDLONG,hour) * SECSPERHOUR
          + VAL(UNSIGNEDLONG,min)  * SECSPERMIN
          + VAL(UNSIGNEDLONG,sec)
         );
 END;
END DateToSeconds;

(*---------------------------------------------------------------------------*)

PROCEDURE SecondsToDate ((* EIN/ -- *)     time : UNSIGNEDLONG;
                         (* -- /AUS *) VAR date : DosDate      );

VAR __REG__ days  : UNSIGNEDLONG;
    __REG__ tmp1  : UNSIGNEDLONG;
    __REG__ tmp2  : UNSIGNEDWORD;
    __REG__ years : INTEGER;
            leap  : BOOLEAN;

BEGIN
 WITH date DO
   tmp1 := time;
   days := tmp1 DIV SECSPERDAY;
   tmp1 := tmp1 MOD SECSPERDAY;
   wday := INT((days + VAL(UNSIGNEDLONG,4)) MOD VAL(UNSIGNEDLONG,7));
   hour := INT(tmp1 DIV SECSPERHOUR);
   tmp1 := tmp1 MOD SECSPERHOUR;
   min  := INT(tmp1 DIV SECSPERMIN);
   sec  := INT(tmp1 MOD SECSPERMIN);

   years := 1970;
   tmp1  := 365;
   tmp2  := 2;
   WHILE days >= tmp1 DO
     INC(years);
     DEC(days, tmp1);
     DEC(tmp2);
     IF tmp2 = 0 THEN
       tmp1 := 366;
       tmp2 := 4;
     ELSE
       tmp1 := 365;
     END;
   END;

   year := years;
   yday := INT(days);

   leap := tmp2 = 4;
   tmp2 := 0;
   WHILE days >= VAL(UNSIGNEDLONG,DaysPerMonth[leap][tmp2]) DO
     DEC(days, VAL(UNSIGNEDLONG,DaysPerMonth[leap][tmp2]));
     INC(tmp2);
   END;

   mon := INT(tmp2);
   day := INT(days) + 1;
 END;
END SecondsToDate;

(*===========================================================================*)

VAR i : UNSIGNEDWORD;

BEGIN (* DosTime *)
#if ISO_value_constructor && !(defined MM2_43c)
 DaysPerMonth := DayMonth{{31,28,31,30,31,30,31,31,30,31,30,31},
                          {31,29,31,30,31,30,31,31,30,31,30,31}};

 MonthDays    := DayMonth{{0,31,59,90,120,151,181,212,243,273,304,334},
                          {0,31,60,91,121,152,182,213,244,274,305,335}};
#else
 DaysPerMonth[FALSE][0]  := 31;
 DaysPerMonth[FALSE][1]  := 28;
 DaysPerMonth[FALSE][2]  := 31;
 DaysPerMonth[FALSE][3]  := 30;
 DaysPerMonth[FALSE][4]  := 31;
 DaysPerMonth[FALSE][5]  := 30;
 DaysPerMonth[FALSE][6]  := 31;
 DaysPerMonth[FALSE][7]  := 31;
 DaysPerMonth[FALSE][8]  := 30;
 DaysPerMonth[FALSE][9]  := 31;
 DaysPerMonth[FALSE][10] := 30;
 DaysPerMonth[FALSE][11] := 31;

 DaysPerMonth[TRUE]    := DaysPerMonth[FALSE];
 DaysPerMonth[TRUE][1] := 29;

 MonthDays[FALSE][0] := 0;
 FOR i := 0 TO 10 DO
   MonthDays[FALSE][i+1] := MonthDays[FALSE][i] + DaysPerMonth[FALSE][i];
 END;
 MonthDays[TRUE][0] := 0;
 FOR i := 0 TO 10 DO
   MonthDays[TRUE][i+1] := MonthDays[TRUE][i] + DaysPerMonth[TRUE][i];
 END;
#endif
END DosTime.

IMPLEMENTATION MODULE SysClock;
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
(* 12-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD;

FROM OSCALLS IMPORT
(* PROC *) Pgeteuid;

FROM types IMPORT
(* TYPE *) int, long, timeT, TimevalRec, TimevalPtr;

FROM DosTime IMPORT
(* VAR  *) DaysPerMonth;

FROM tim IMPORT
(* TYPE *) TmRec, TmPtr,
(* VAR  *) timezone, altzone,
(* PROC *) localtime, mktime;

FROM sys IMPORT
(* TYPE *) gettimeofday, settimeofday;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE CanGetClock ( ) : BOOLEAN;
BEGIN
 RETURN(TRUE);
END CanGetClock;

(*---------------------------------------------------------------------------*)

PROCEDURE CanSetClock ( ) : BOOLEAN;
BEGIN
 (* Die Uhr darf entweder vom Supervisor gestellt werden, oder dann, wenn
  * es keine effektiven Benutzerkennungen gibt.
  *)
 RETURN(Pgeteuid() <= 0);
END CanSetClock;

(*---------------------------------------------------------------------------*)

PROCEDURE IsValidDateTime ((* EIN/ -- *) userData : DateTime ) : BOOLEAN;

PROCEDURE isLeapyear ((* EIN/ -- *) year : CARDINAL ): BOOLEAN;
BEGIN
 RETURN((year MOD 4 = 0) & (year MOD 100 # 0) OR (year MOD 400 = 0));
END isLeapyear;

BEGIN (* IsValidDateTime *)
 WITH userData DO
   RETURN(  (VAL(UNSIGNEDWORD,hour) <= 23)
          & (VAL(UNSIGNEDWORD,minute) <= 59)
          & (VAL(UNSIGNEDWORD,second) <= 59)
          & (VAL(UNSIGNEDWORD,month) >= 1) & (VAL(UNSIGNEDWORD,month) <= 12)
          & (VAL(UNSIGNEDWORD,day) >= 1)
          & (VAL(UNSIGNEDWORD,day) <= DaysPerMonth[isLeapyear(year)][month-1]));
 END;
END IsValidDateTime;

(*---------------------------------------------------------------------------*)

PROCEDURE GetClock ((* -- /AUS *) VAR userData : DateTime );

VAR tm : TmPtr;
    tv : TimevalRec;

BEGIN
 WITH userData DO
   year           := 0;
   month          := 1;
   day            := 1;
   hour           := 0;
   minute         := 0;
   second         := 0;
   fractions      := LC(0);
   zone           := 0;
   summerTimeFlag := FALSE;

   IF gettimeofday(ADR(tv), NULL) < 0 THEN
     RETURN;
   END;
   tm := localtime(tv.tvSec);
   IF tm # NULL THEN
     WITH tm^ DO
       year           := VAL(CARDINAL,tmYear) + 1900;
       month          := VAL(Month,tmMon + 1);
       day            := VAL(Day,tmMDay);
       hour           := VAL(Hour,tmHour);
       minute         := VAL(Min,tmMin);
       second         := VAL(Sec,tmSec);
       fractions      := VAL(Fraction,tv.tvUSec);
       zone           := VAL(UTCDiff,tmGmtOff DIV VAL(long,60));
       summerTimeFlag := tmIsDst > 0;
     END;
   END;
 END;
END GetClock;

(*---------------------------------------------------------------------------*)

PROCEDURE SetClock ((* EIN/ -- *) userData : DateTime );

VAR void : INTEGER;
    tv   : TimevalRec;
    tm   : TmRec;

BEGIN
 WITH tm DO WITH userData DO
   tmYear    := VAL(int,year) - 1900;
   tmMon     := VAL(int,month) - 1;
   tmMDay    := VAL(int,day);
   tmHour    := VAL(int,hour);
   tmMin     := VAL(int,minute);
   tmSec     := VAL(int,second);
   tv.tvUSec := VAL(long,fractions);
 END; END;
 tv.tvSec := mktime(ADR(tm));
 IF tv.tvSec # VAL(long,-1) THEN
   void := settimeofday(ADR(tv), NULL);
 END;
END SetClock;

END SysClock.

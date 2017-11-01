IMPLEMENTATION MODULE DateLib;
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
(* Die Algorithmen zur Umrechnung zwischen julianischem und kalendarischem   *)
(* Datum sind aus:                                                           *)
(*                                                                           *)
(*   Oliver Montenbruck,                                                     *)
(*   Practical Ephemeris Calculations,                                       *)
(*   Springer                                                                *)
(*                                                                           *)
(* Es gibt aber auch die deutsche Originalfassung:                           *)
(*                                                                           *)
(*   Oliver Montenbruck,                                                     *)
(*   Grundlagen der Ephemeridenrechnung                                      *)
(*   Verlag Sterne und Weltraum, Dr.Vehrenberg GmbH                          *)
(*                                                                           *)
(* Die Anpassung an Ganzzahlrechnung stammt von mir, wobei die gebrochenen   *)
(* Zahlen - wo noetig - zu Bruechen erweitert und/oder in ganzzahligen und   *)
(* gebrochenen Anteil aufgespalten wurden, und diese Brueche erweitert so er-*)
(* weitert wurden, dass sich ganze Zahlen ergaben. Fuer positive Zahlen      *)
(* laesst sich dann schreiben:                                               *)
(*                                                                           *)
(*    entier(a / b) = trunc(a / b) = a DIV b                                 *)
(* --------------------------------------------------------------------------*)
(* Mai-91 / 06-Jan-96, Holger Kleinschmidt                                   *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM types IMPORT
(* CONST*) EOS;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDLONG, SIGNEDLONG, UNSIGNEDWORD;

FROM DosTime IMPORT
(* VAR  *) DaysPerMonth, MonthDays;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
 julStart  : Date;
 julEnd    : Date;
 gregStart : Date;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE FirstJulCal ((* -- /AUS *) VAR first : Date );
BEGIN
 first := julStart;
END FirstJulCal;

(*---------------------------------------------------------------------------*)

PROCEDURE LastJulCal ((* -- /AUS *) VAR last : Date );
BEGIN
 last := julEnd;
END LastJulCal;

(*---------------------------------------------------------------------------*)

PROCEDURE FirstGregCal ((* -- /AUS *) VAR first : Date );
BEGIN
 first := gregStart;
END FirstGregCal;

(*---------------------------------------------------------------------------*)

PROCEDURE IsLeapyear ((* EIN/ -- *) year : INTEGER ): BOOLEAN;
BEGIN
 IF year > gregStart.year THEN
   (* Da 1582 kein Schaltjahr war, braucht nicht auf das genaue
    * Datum der Einfuehrung des Gregorianischen Kalenders
    * geachtet zu werden.
    *)
   RETURN((year MOD 4 = 0) & (year MOD 100 # 0) OR (year MOD 400 = 0));
 ELSE
   (* Absolutwert, da die MODULO-Bildung bei negativen Zahlen
    * moeglicherweise von Compiler zu Compiler unterschiedlich ist.
    *)
   RETURN(ABS(year) MOD 4 = 0);
 END;
END IsLeapyear;

(*---------------------------------------------------------------------------*)

PROCEDURE CompareDate ((* EIN/ -- *) date1 : Date;
                       (* EIN/ -- *) date2 : Date ): DateRelation;

VAR __REG__ yearEqual : BOOLEAN;

BEGIN
  WITH date1 DO
    yearEqual := year = date2.year;

    IF   (year < date2.year)
      OR yearEqual & (month < date2.month)
      OR yearEqual & (month = date2.month) & (day < date2.day)
    THEN
      RETURN(dEarlier);
    ELSIF yearEqual & (month = date2.month) & (day = date2.day) THEN
      RETURN(dEqual);
    ELSE
      RETURN(dLater);
    END;
  END; (* WITH *)
END CompareDate;

(*---------------------------------------------------------------------------*)

PROCEDURE CheckDate ((* EIN/ -- *) date : Date ): Calendar;
BEGIN
 WITH date DO
   IF   (day > 0)
      & (month <= 11)
      & (day <= VAL(CARDINAL,DaysPerMonth[IsLeapyear(year)][VAL(UNSIGNEDWORD,month)]))
   THEN
     IF CompareDate(date, gregStart) # dEarlier THEN
       RETURN(gregDate);
     ELSIF   (CompareDate(date, julStart) # dEarlier)
           & (CompareDate(date, julEnd) # dLater)
     THEN
       RETURN(julDate);
     END;
   END;
 END;
 RETURN(noDate);
END CheckDate;

(*---------------------------------------------------------------------------*)

PROCEDURE JulianDate ((* EIN/ -- *) date : Date ): UNSIGNEDLONG;

CONST time = LIC(0);

VAR         greg : BOOLEAN;
            m    : CARDINAL;
    __REG__ B    : SIGNEDLONG;
    __REG__ y    : SIGNEDLONG;

BEGIN
 greg := CompareDate(date, gregStart) # dEarlier;

 WITH date DO
   IF month <= 1 THEN
     DEC(year);
     m := month + 1 + 12 + 1;
   ELSE
     m := month + 1 + 1;
   END;
   y := VAL(SIGNEDLONG,year);

   IF greg THEN
     B := y DIV VAL(SIGNEDLONG,400) - y DIV VAL(SIGNEDLONG,100);
   ELSE
     B := -2;
   END;

   IF y < VAL(SIGNEDLONG,0) THEN  (* int(365.25 * y) *)
     (*   trunc(365.25 * y                 - 0.75)
      * = trunc(365 * y  +  0.25 * y       - 0.75)
      * =       365 * y  +  trunc(0.25 * y - 0.75)    | mit 4 erweitern
      * =       365 * y  +  trunc((1 * y - 3) / 4)
      *)
     y := VAL(SIGNEDLONG,365) * y + (y - VAL(SIGNEDLONG,3)) DIV VAL(SIGNEDLONG,4);
   ELSE
     y := VAL(SIGNEDLONG,365) * y + y DIV VAL(SIGNEDLONG,4);
   END;

   RETURN(  y
          (*   int(30.6001 * month)    | mit 5 erweitern
           * = int((153 * month) / 5)
           *)
          + VAL(SIGNEDLONG,(153 * m) DIV 5)
          + B
          + LIC(1720997)                       (* 1720966.5 *)
          + VAL(SIGNEDLONG,day)
          + time                               (* 0.5 = 12:00:00 *)
         );
 END;
END JulianDate;

(*---------------------------------------------------------------------------*)

PROCEDURE CalendarDate ((* EIN/ -- *)     julian : UNSIGNEDLONG;
                        (* -- /AUS *) VAR cal    : Date         );

CONST gregDays = LC(2299161); (* jul. Tagesdatum des 15.10.1582 *)

 VAR  b, c, D,
      d, e    : SIGNEDLONG;
      f       : CARDINAL;

BEGIN
 IF julian < gregDays THEN
   c := julian + VAL(UNSIGNEDLONG,1524);
 ELSE
   (* b := int(( julian - 1867216.25D)      / 36524.25D)
    *    = int(((julian - 1867216) - 0.25)  / 36524.25) | mit 4 erweitern
    *    = int(((julian - 1867216) * 4 - 1) / 146097)
    *)
   b := ((julian - LC(1867216)) * LC(4) - LC(1)) DIV LC(146097);

   c := CAST(SIGNEDLONG,julian) + b - b DIV LIC(4) + LIC(1525);
 END;

 (* d := int(( c - 122.1)         / 365.25)
  *    = int(((c - 122) - 0.1)    / 365.25)  | mit 20 erweitert
  *    = int(((c - 122) * 20 - 2) / 7305)
  *)
 d := ((c - LIC(122)) * LIC(20) - LIC(2)) DIV LIC(7305);

 (* e := int(365.25            * d)
  *    = int((365 + 0.25)      * d)
  *    = 365 * d + int(0.25    * d)    | mit 4 erweitern
  *    = 365 * d + int((1 * d) / 4)
  *)
 e := d * LIC(365) + d DIV LIC(4);

 (* f := int(( c - e) / 30.6001D)  | mit 5 erweitert
  *    = int(((c - e) * 5) / 153)
  *)
 f := VAL(CARDINAL,((c - e) * LIC(5)) DIV LIC(153));

 WITH cal DO
   (* day := c - e - int( 30.6001 * f)   | mit 5 erweitert
    *      = c - e - int((153 * f) / 5)
    *)
   day   := VAL(CARDINAL,c - e) - (153 * f) DIV 5;

   month := VAL(CARDINAL,f - 1 - 12 * (f DIV 14) - 1);
   year  := VAL(INTEGER,d) - 4715 - (7 + VAL(INTEGER,month) + 1) DIV 10;
 END;
END CalendarDate;

(*---------------------------------------------------------------------------*)

PROCEDURE DayOfWeek ((* EIN/ -- *) date : Date): Weekday;
BEGIN
 RETURN(VAL(Weekday, JulianDate(date) MOD VAL(UNSIGNEDLONG,7)));
END DayOfWeek;

(*---------------------------------------------------------------------------*)

PROCEDURE DayOfYear ((* EIN/ -- *) date : Date ): CARDINAL;

VAR m    : INTEGER;
    days : CARDINAL;

BEGIN
 WITH date DO
   IF month > 11 THEN
     RETURN(0)
   END;
   RETURN(  VAL(CARDINAL,MonthDays[IsLeapyear(year)][VAL(UNSIGNEDWORD,month)])
          + day
         );
  END; (* WITH *)
END DayOfYear;

(*---------------------------------------------------------------------------*)

PROCEDURE DaysInMonth ((* EIN/ -- *) date : Date ): CARDINAL;
BEGIN
 WITH date DO
   IF month <= 11 THEN
     RETURN(VAL(CARDINAL,DaysPerMonth[IsLeapyear(year)][VAL(UNSIGNEDWORD,month)]));
   ELSE
     RETURN(0);
   END;
 END;
END DaysInMonth;

(*---------------------------------------------------------------------------*)

PROCEDURE DateDiff ((* EIN/ -- *) date1 : Date;
                    (* EIN/ -- *) date2 : Date ): SIGNEDLONG;
BEGIN
 RETURN(CAST(SIGNEDLONG,JulianDate(date1)) - CAST(SIGNEDLONG,JulianDate(date2)));
END DateDiff;

(*---------------------------------------------------------------------------*)

PROCEDURE DateAdd ((* EIN/ -- *)     date : Date;
                   (* EIN/ -- *)     days : SIGNEDLONG;
                   (* -- /AUS *) VAR new  : Date       );
BEGIN
 CalendarDate(CAST(SIGNEDLONG,JulianDate(date)) + days, new);
END DateAdd;

(*===========================================================================*)

BEGIN (* DateLib *)
 WITH julStart DO
   day   := 1;
   month := 0;
   year  := -4712;
 END;
 WITH julEnd DO
   day   := 4;
   month := 9;
   year  := 1582;
 END;
 WITH gregStart DO
   day   := 15;
   month := 9;
   year  := 1582;
 END;
END DateLib.

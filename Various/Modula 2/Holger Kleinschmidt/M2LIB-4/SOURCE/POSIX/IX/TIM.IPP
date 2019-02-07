IMPLEMENTATION MODULE tim;
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
(* Programmiert mit Unterstuetzung der MiNTLib und der ``echten'' GnuLib    *)
(* (= glibc).                                                               *)
(* -------------------------------------------------------------------------*)
(* 10-Aug-96, Holger Kleinschmidt                                           *)
(****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL, MINSIGNED,
(* TYPE *) UNSIGNEDLONG, SIGNEDLONG, UNSIGNEDWORD, SIGNED, UNSIGNED, WORDSET;

FROM ISOStrings IMPORT
(* PROC *) Length, Assign;

FROM er IMPORT
(* CONST*) EINVAL,
(* VAR  *) errno;

FROM types IMPORT
(* CONST*) EOS, MAXSTR, HT, LF,
(* TYPE *) double, sizeT, timeT, StrPtr, StrRange;

FROM ctype IMPORT
(* PROC *) todigit, tocard, Cisdigit;

FROM str IMPORT
(* PROC *) AssignM2ToC, AssignCToM2, strlen, strcat, strcmp;

FROM DosSystem IMPORT
(* TYPE *) PrefLanguage,
(* PROC *) Language;

FROM DosTime IMPORT
(* CONST*) SECSPERDAY,
(* TYPE *) DayMonth, DosDate,
(* VAR  *) DaysPerMonth, MonthDays,
(* PROC *) DateToSeconds, SecondsToDate;

FROM args IMPORT
(* PROC *) getenv;

FROM LCTypes IMPORT
(* TYPE *) LCTime;

IMPORT LC, LCPOSIX;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  MAXNUMSTR = 21;

TYPE
  NumStr = ARRAY [0..MAXNUMSTR] OF CHAR;

CONST
  MAXZSTR = 9;

TYPE
  ZoneStr = ARRAY [0..MAXZSTR] OF CHAR;

TYPE
  ChangeType = (M, J0, J1);

  Change = RECORD
    CASE type : ChangeType OF
      M : month : CARDINAL; (* [1..12] *)
          week  : CARDINAL; (* [1..5] *)
          day   : CARDINAL; (* [0..6] *)
    ELSE  yday  : CARDINAL; (* [0/1..365] *)
    END;
    secs : SIGNEDLONG;
      (* Tageszeit des Wechsels in Sekunden *)
    at   : timeT;
      (* Zeit des Zonenwechsels in Sekunden seit 1.1.1970, lokaler Zeit *)
    year : UNSIGNEDWORD;
      (* Jahr, fuer das 'at' berechnet wurde (0: ungueltig) *)
  END;

TYPE
  FormBuf = ARRAY [0..100] OF CHAR;

CONST
  STD = 0;
  DST = 1;

CONST
  MaxTzEnv = 80;

VAR
  tzchange : ARRAY [STD..DST] OF Change;
  tzinit   : BOOLEAN;
  tzenv    : ARRAY [0..MaxTzEnv] OF CHAR;
  ascbuf   : FormBuf; (* Statischer Speicher fuer "asctime()" *)
  tmrecbuf : TmRec;   (* Statischer Speicher fuer "local/gmtime()" *)
  TzName   : ARRAY [STD..DST] OF ZoneStr;
  UTCName  : ARRAY [0..3] OF CHAR; (* "UTC" *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE difftime ((* EIN/ -- *) time2 : timeT;
                    (* EIN/ -- *) time1 : timeT ): double;
BEGIN
#if (defined MM2)
 RETURN(VAL(LONGREAL,time2 - time1));
#elif (defined LPRM2) || (defined SPCM2)
 RETURN(FLOATD(time2 - time1));
#elif (defined HM2)
 RETURN(LFLOAT(time2 - time1));
#elif (defined TDIM2)
 IF time2 >= time1 THEN
   RETURN(FLOATD(LONGCARD(time2 - time1)));
 ELSE
   RETURN(-FLOATD(LONGCARD(time1 - time2)));
 END;
#endif
END difftime;

(*---------------------------------------------------------------------------*)

(* year : [1900/1970..2099]
   mon  : [0..11]
   day  : [1..31]
   hour : [0..23]
   min  : [0..59]
   sec  : [0..59]

   Im Zeitraum von 1901 bis 2099 ist jede durch Vier teilbare Jahreszahl
   ein Schaltjahr, da 2000 durch 400 teilbar und damit ebenfalls ein
   Schaltjahr ist. Wird jetzt noch beruecksichtigt, dass 1900 kein
   Schaltjahr war, kann die Anzahl der Tage seit dem 1.1.1900 bis zum
   31.12 des letzten Jahres wie folgt berechnet werden:

     year = 1900:
     ydays00 := 0

     1900 < year < 2100:
     ydays00 := (year - 1900) * 365 + (year - 1900 - 1) DIV 4
                -------------------   -----------------------
                ``normale'' Tage      Schalttage
                                      1904 war das erste Schaltjahr seit 1900,
                                      d.h. bei einem Datum im Jahr 1905 wird
                                      zum ersten Mal ein Schalttag zu den
                                      Tagen des vorangegangenen Jahres
                                      hinzugezaehlt:
                                      1905 - 1900 - 1 = 4, 4 DIV 4 = 1

   Dann kommen noch die Tage der vollstaendigen Monate des laufenden
   Jahres hinzu:

     mdays := MonthDays[year MOD 4 = 0][month];

   Und schliesslich die vollstaendigen Tage im laufenden Monat:

     ddays := day - 1;

   Die vollstaendigen (julianischen) Tage seit dem 1.1.1900 ergeben sich
   dann aus:

     jdays00 := ydays00 + mdays + ddays;


   Der 1.1.1900 war ein Montag; wird der Sonntag mit Null kodiert, ergibt
   sich der Wochentag aus

     wday := (jdays00 + 1) MOD 7;

   =======================================================================

   Sollen die vollstaendigen Tage seit dem 1.1.1970 bestimmt werden,
   sieht die Formel fuer 'ydays' so aus:

     year = 1970:
     ydays70 := 0
     1970 < year < 2100:
     ydays70 := (year - 1970) * 365 + (year - 1970 + 1) DIV 4
                -------------------   -----------------------
                ``normale'' Tage      Schalttage
                                      1972 war das erste Schaltjahr seit 1970,
                                      ab 1973 wird zum ersten Mal ein
                                      Schalttag hinzugezaehlt:
                                      1973 - 1970 + 1 = 4, 4 DIV 4 = 1

   Die Formeln fuer 'mdays' und 'ddays' bleiben gleich, so dass fuer die
   Tage seit dem 1.1.1970 gilt:

     jdays70 := ydays70 + mdays + ddays;

   Da der 1.1.1970 ein Donnerstag war (= 4), gilt fuer den Wochentag

     wday := (jdays70 + 4) MOD 7;

   =======================================================================

   Der Tag des Jahres im Bereich [0..365] ergibt sich aus:

     yday := mdays + ddays;


   =======================================================================

   Sollen die vergangenen Sekunden ermittelt werden, muessen die
   vergangenen vollen Tage nur noch mit der Anzahl der Sekunden pro Tag
   multipliziert und die Tageszeit addiert werden

     secs00 := jdays00 * (60 * 60 * 24) + (60 * 60 * hour) + (60 * min) + sec
     secs70 := jdays70 * (60 * 60 * 24) + (60 * 60 * hour) + (60 * min) + sec

 *)


PROCEDURE FormInt ((* EIN/ -- *)     num   : INTEGER;
                   (* EIN/ -- *)     width : UNSIGNEDWORD;
                   (* EIN/ -- *)     prec  : UNSIGNEDWORD;
                   (* EIN/ -- *)     from  : UNSIGNEDWORD;
                   (* -- /AUS *) VAR str   : ARRAY OF CHAR ): UNSIGNEDWORD;

(* Schreibt <num> im Format '%<width>.<prec>d' ab der Position <from> nach
   <str> und liefert die Position des naechsten Zeichens.
   <str> wird nicht mit einem Nullbyte abgeschlossen, und es wird
   angenommen, dass <str> ausreichend gross ist.
 *)
VAR __REG__ neg    : BOOLEAN;
    __REG__ i      : UNSIGNEDWORD;
    __REG__ dst    : UNSIGNEDWORD;
    __REG__ val    : UNSIGNED;
            digits : NumStr;


BEGIN
 IF width > MAXNUMSTR THEN
   width := MAXNUMSTR;
 END;
 neg := num < 0;
 IF neg & (VAL(SIGNED,num) # MINSIGNED) THEN
   val := VAL(UNSIGNED,-VAL(SIGNED,num));
 ELSE
   val := VAL(UNSIGNED,num);
 END;

 i := 0;
 WHILE val > VAL(UNSIGNED,0) DO
   digits[i] := todigit(VAL(CARDINAL,val MOD VAL(UNSIGNED,10)));
   val       := val DIV VAL(UNSIGNED,10);
   INC(i);
 END;
 WHILE i < prec DO
   digits[i] := '0';
   INC(i);
 END;
 IF neg THEN
   digits[i] := '-';
   INC(i);
 END;
 WHILE i < width DO
   digits[i] := ' ';
   INC(i);
 END;

 dst := from;
 WHILE i > 0 DO
   DEC(i);
   str[dst] := digits[i];
   INC(dst);
 END;
 RETURN(dst);
END FormInt;

(*---------------------------------------------------------------------------*)

PROCEDURE Standard;
BEGIN
 daylight := FALSE;
 timezone := 0;
 altzone  := 0;

 TzName[STD] := "UTC";
 tzname[STD] := ADR(TzName[STD]);
 (* Falls 'daylight' auf TRUE gesetzt aber kein Aenderungszeitpunkt
  * angegeben, die US-Regeln verwenden.
  *)
 WITH tzchange[STD] DO
   type  := M;
   month := 4;
   week  := 1;
   day   := 0;
   secs  := 2 * 60 * 60;

   year  := 0;
 END;
 TzName[DST] := "";
 tzname[DST] := ADR(TzName[DST]);
 WITH tzchange[DST] DO
   type  := M;
   month := 10;
   week  := 5;
   day   := 0;
   secs  := 2 * 60 * 60;

   year  := 0;
 END;
END Standard;

(*---------------------------------------------------------------------------*)

PROCEDURE Default;
BEGIN
 CASE Language() OF
   lFRG: daylight  := TRUE;
         timezone  := -(1 * 60 * 60);
         altzone   := -(2 * 60 * 60);

         TzName[STD] := "MET";
         tzname[STD] := ADR(TzName[STD]);
         WITH tzchange[STD] DO
           type  := M;
           month := 3;
           week  := 5;
           day   := 0;
           secs  := 2 * 60 * 60;

           year  := 0;
         END;
         TzName[DST] := "MEST";
         tzname[DST] := ADR(TzName[DST]);
         WITH tzchange[DST] DO
           type  := M;
           month := 10;
           week  := 5;
           day   := 0;
           secs  := 3 * 60 * 60;

           year  := 0;
         END;

 ELSE    Standard;
 END;
END Default;

(*---------------------------------------------------------------------------*)

PROCEDURE Impdep;
BEGIN
 Default;
END Impdep;

(*---------------------------------------------------------------------------*)

PROCEDURE tzset;

VAR tzval : StrPtr;
    tzidx : StrRange;
    tzlen : StrRange;
    i     : [STD..DST];
    neg   : BOOLEAN;
    c     : CHAR;

PROCEDURE ParseName ((* -- /AUS *) VAR name : ZoneStr ): BOOLEAN;

(* Wenn ein Fehler auftritt, wird FALSE zurueckgegeben und <name> nicht
   veraendert.
 *)
VAR __REG__ i : StrRange;
    __REG__ c : CHAR;

BEGIN
 i := tzidx;
 c := tzval^[i];
 IF c = ':' THEN
   (* Name darf nicht mit Doppelpunkt beginnen *)
   RETURN(FALSE);
 END;
 WHILE (c # 0C) & (c # '+') & (c # '-') & (c # ',') & ~Cisdigit(c) DO
   (* Name zuende, wenn Stringende, Vorzeichen, Komma oder Ziffer auftritt *)
   INC(i);
   c := tzval^[i];
 END;
 IF i - tzidx < 3 THEN
   (* Name muss aus mindestens drei Zeichen bestehen *)
   tzidx := i;
   RETURN(FALSE);
 END;
 AssignCToM2(ADR(tzval^[tzidx]), i - tzidx, name);
 tzidx := i;
 RETURN(TRUE);
END ParseName;

PROCEDURE tonum ((* EIN/ -- *)     min : CARDINAL;
                 (* EIN/ -- *)     max : CARDINAL;
                 (* -- /AUS *) VAR num : CARDINAL ): BOOLEAN;

VAR __REG__ i    : StrRange;
    __REG__ c    : CHAR;
    __REG__ unit : CARDINAL;

BEGIN
 i    := tzidx;
 c    := tzval^[i];
 unit := 0;
 WHILE Cisdigit(c) DO
   IF unit <= max THEN
     unit := unit * 10 + tocard(c);
   END;
   INC(i);
   c := tzval^[i];
 END;
 IF i = tzidx THEN
   (* Mindestens eine Ziffer *)
   RETURN(FALSE);
 END;
 IF unit > max THEN
   unit := max;
 ELSIF unit < min THEN
   unit := min;
 END;
 num   := unit;
 tzidx := i;
 RETURN(TRUE);
END tonum;

PROCEDURE ParseOffset ((* EIN/ -- *)     maxh : CARDINAL;
                       (* -- /AUS *) VAR sec  : SIGNEDLONG ): BOOLEAN;

(* Wenn ein Fehler auftritt, wird FALSE zurueckgegeben und <sec> nicht
   veraendert.
 *)
VAR __REG__ i    : StrRange;
    __REG__ c    : CHAR;
    __REG__ secs : UNSIGNEDLONG;
            unit : CARDINAL;

BEGIN
 (* Stunden *)
 IF ~tonum(0, maxh, unit) THEN
   RETURN(FALSE);
 END;
 secs := VAL(UNSIGNEDLONG,unit) * VAL(UNSIGNEDLONG,60 * 60);

 IF tzval^[tzidx] # ':' THEN
   (* Nur Stunden angegeben *)
   sec := CAST(SIGNEDLONG,secs);
   RETURN(TRUE);
 END;

 (* Minuten *)
 INC(tzidx);
 IF ~tonum(0, 59, unit) THEN
   RETURN(FALSE);
 END;
 secs := secs + VAL(UNSIGNEDLONG,unit) * VAL(UNSIGNEDLONG,60);

 IF tzval^[tzidx] # ':' THEN
   (* Nur Stunden und Minuten angegeben *)
   sec := CAST(SIGNEDLONG,secs);
   RETURN(TRUE);
 END;

 (* Sekunden *)
 INC(tzidx);
 IF ~tonum(0, 59, unit) THEN
   RETURN(FALSE);
 END;
 secs := secs + VAL(UNSIGNEDLONG,unit);

 sec := CAST(SIGNEDLONG,secs);
 RETURN(TRUE);
END ParseOffset;

PROCEDURE ParseChange ((* -- /AUS *) VAR date : Change ): BOOLEAN;

VAR m, w, d : CARDINAL;

BEGIN
 IF tzval^[tzidx] = 'M' THEN
   INC(tzidx);
   IF ~tonum(1, 12, m) THEN
     RETURN(FALSE);
   END;
   IF tzval^[tzidx] # '.' THEN
     RETURN(FALSE);
   END;
   INC(tzidx);
   IF ~tonum(1, 5, w) THEN
     RETURN(FALSE);
   END;
   IF tzval^[tzidx] # '.' THEN
     RETURN(FALSE);
   END;
   INC(tzidx);
   IF ~tonum(0, 6, d) THEN
     RETURN(FALSE);
   END;
   WITH date DO
     type  := M;

     month := m;
     week  := w;
     day   := d;
   END;
   RETURN(TRUE);
 ELSIF tzval^[tzidx] = 'J' THEN
   INC(tzidx);
   IF ~tonum(1, 365, d) THEN
     RETURN(FALSE);
   END;
   date.yday := d;
   date.type := J1;
   RETURN(TRUE);
 ELSIF Cisdigit(tzval^[tzidx]) THEN
   IF ~tonum(0, 365, d) THEN
     RETURN(FALSE);
   END;
   date.yday := d;
   date.type := J0;
   RETURN(TRUE);
 END;
 RETURN(FALSE);
END ParseChange;

BEGIN (* tzset *)
 tzval := getenv("TZ");
 IF   tzinit
    &
      (   (tzval = NULL) & (tzenv[0] = EOS)
       OR (strcmp(tzval, ADR(tzenv)) = 0))
 THEN
  (* Es hat sich nichts gegenueber dem letzten "tzset()"-Aufruf geaendert *)
   RETURN;
 END;
 AssignCToM2(tzval, MaxTzEnv, tzenv);
 (* tzenv ist auf jeden Fall mit einem Nullbyte abgeschlossen, so dass es
  * als C-String verwendet werden kann.
  *)
 Default;
 tzinit := TRUE;
 IF tzval = NULL THEN
   RETURN;
 END;
 tzlen := VAL(StrRange,strlen(tzval));
 IF tzlen = 0 THEN
   Standard;
   RETURN;
 END;

 tzidx := 0;
 IF tzval^[0] = ':' THEN
   Impdep;
   RETURN;
 END;

 IF ~ParseName(TzName[STD]) THEN
   (* Der Name der Standardzeitzone muss angegeben sein *)
   RETURN;
 END;
 c   := tzval^[tzidx];
 neg := c = '-';
 IF neg OR (c = '+') THEN
   INC(tzidx);
 END;
 IF ~ParseOffset(12, timezone) THEN
   (* Der Offset der Standardzeitzone muss angegeben sein *)
   RETURN;
 END;
 IF neg THEN
   (* Zeitzone ist oestlich von UTC *)
   timezone := -timezone;
 END;

 IF (tzidx = tzlen) OR ~ParseName(TzName[DST]) THEN
   (* Keine Sommerzeit oder Name der Sommerzeitzone falsch *)
   daylight := FALSE;
   altzone  := timezone;
   RETURN;
 END;
 (* Default: Sommerzeit ist der Normalzeit eine Stunde voraus *)
 daylight := TRUE;
 altzone  := timezone - VAL(SIGNEDLONG,60 * 60);
 IF tzidx = tzlen THEN
   RETURN;
 END;

 c := tzval^[tzidx];
 IF (c = '-') OR (c = '+') OR Cisdigit(c) THEN
   neg := c = '-';
   IF neg OR (c = '+') THEN
     INC(tzidx);
   END;
   IF ~ParseOffset(12, altzone) THEN
     RETURN;
   END;
   IF neg THEN
     altzone := -altzone;
   END;
 END;

 IF tzidx = tzlen THEN
   (* Kein Aenderungszeitpunkt angegeben *)
   RETURN;
 END;

 FOR i := STD TO DST DO
   IF tzval^[tzidx] # ',' THEN
     RETURN;
   END;
   INC(tzidx);
   IF ~ParseChange(tzchange[i]) THEN
     RETURN;
   END;
   IF tzval^[tzidx] = '/' THEN
     INC(tzidx);
     IF ~ParseOffset(24, tzchange[i].secs) THEN
       RETURN;
     END;
   END;
 END;
END tzset;

(*---------------------------------------------------------------------------*)

PROCEDURE DstChange ((* EIN/ -- *) y : UNSIGNEDWORD );

(* Bestimmt Beginn und Ende der Sommerzeit fuer das Jahr <y>.
   Zuvor muss "tzset()" aufgerufen werden, um die jeweiligen Grenzen
   zu ermitteln. Falls die Werte beim letzten Aufruf fuer das gleiche
   <y> bestimmt wurden, wird nicht nochmal neu berechnet.
 *)
VAR __REG__ jdays : CARDINAL;
    __REG__ wday  : CARDINAL;
    __REG__ yday  : CARDINAL;
    __REG__ mday  : CARDINAL;
            i     : [STD..DST];

BEGIN
 FOR i := STD TO DST DO
   WITH tzchange[i] DO
     IF y = year THEN
       (* Wert fuer dieses Jahr wurde schon berechnet *)
       RETURN;
     END;
     jdays := (y - 1970) * 365 + (y - 1969) DIV 4;
     (* jdays: Tage seit 1.1.70 bis zum Anfang des Jahres *)

     CASE type OF
       J0: INC(jdays, yday);
           (* jdays: Tage seit 1.1.70 *)

      |J1: IF (y MOD 4 = 0) & (yday > 59) THEN
             (* 29.2. extra beruecksichtigen *)
             INC(jdays, yday);
           ELSE
             INC(jdays, yday - 1);
           END;
           (* jdays: Tage seit 1.1.70 *)
     ELSE
       INC(jdays, VAL(CARDINAL,MonthDays[y MOD 4 = 0][month-1]));
       (* jdays: Tage seit 1.1.70 bis zum Anfang des Monats *)
       wday := (jdays + 4) MOD 7;
       (* wday: Wochentag des ersten Tags im Monat *)
       IF day >= wday THEN
         (* Erster 'day'-Tag befindet sich in der gleichen Woche *)
         mday := day - wday;
       ELSE
         (* Erster 'day'-Tag befindet sich in der naechsten Woche *)
         mday := (day + 7) - wday;
       END;
       (* mday: Tag im Monat [0..30] des ersten 'day'-Tags *)
       INC(mday, (week - 1) * 7);
       IF mday >= VAL(CARDINAL,DaysPerMonth[y MOD 4 = 0][month-1]) THEN
         (* Monat hat nur vier 'day'-Tage *)
         DEC(mday, 7);
       END;
       (* mday: Tag im Monat [0..30] des 'week'-ten 'day'-Tags *)
       INC(jdays, mday);
       (* jdays: Tage seit 1.1.70 *)
     END;
     at   := VAL(UNSIGNEDLONG,jdays) * SECSPERDAY + CAST(UNSIGNEDLONG,secs);
     year := y;
   END; (* WITH *)
 END;
END DstChange;

(*---------------------------------------------------------------------------*)

PROCEDURE local2UTC ((* EIN/ -- *) tm : timeT ): timeT;

VAR date : DosDate;

BEGIN
 IF tm < VAL(timeT,0) THEN
   RETURN(tm);
 END;
 tzset;                   (* TZ auswerten *)
 SecondsToDate(tm, date); (* Jahr bestimmen *)
 DstChange(date.year);    (* Beginn und Ende der Sommerzeit bestimmen *)

 (* tm: Sekunden seit 1.1.70 0:00:00 UTC *)
 IF (tzchange[STD].at <= tm) & (tm < tzchange[DST].at) THEN
   (* Datum waehrend lokaler Sommerzeit *)
   RETURN(tm + altzone);
 ELSE
   (* Datum waehrend lokaler Standardzeit *)
   RETURN(tm + timezone);
 END;
END local2UTC;

(*---------------------------------------------------------------------------*)

PROCEDURE UTC2local ((* EIN/ -- *) tm : timeT ): timeT;

VAR date : DosDate;

BEGIN
 IF tm < VAL(timeT,0) THEN
   RETURN(tm);
 END;
 tzset; (* TZ auswerten *)
 (* Jahr bestimmen. Funktioniert nicht, wenn im Zeitraum zwischen
  * UTC-Zeit und lokaler Zeit ein Jahreswechsel stattfindet und es
  * in diesen Jahren unterschiedliche Zeitpunkte fuer den Wechsel
  * zwischen Sommer- und Standardzeit gibt.
  *)
 SecondsToDate(tm, date);
 DstChange(date.year);    (* Beginn und Ende der Sommerzeit bestimmen *)

 IF (tzchange[STD].at <= tm - altzone) & (tm - altzone < tzchange[DST].at) THEN
   (* Datum waehrend lokaler Sommerzeit *)
   RETURN(tm - altzone);
 ELSE
   (* Datum waehrend lokaler Standardzeit *)
   RETURN(tm - timezone);
 END;
END UTC2local;

(*---------------------------------------------------------------------------*)

PROCEDURE localtime ((* EIN/ -- *) tm : timeT ): TmPtr;

VAR date : DosDate;

BEGIN
 IF tm < VAL(timeT,0) THEN
   errno := EINVAL;
   RETURN(NULL);
 END;
 SecondsToDate(tm, date);
 WITH tmrecbuf DO WITH date DO
   tmSec  := INT(sec);
   tmMin  := INT(min);
   tmHour := INT(hour);
   tmMDay := INT(day);
   tmMon  := INT(mon);
   tmYear := INT(year - 1900);
   tmWDay := INT(wday);
   tmYDay := INT(yday);

   tzset;           (* TZ auswerten *)
   DstChange(year); (* Beginn und Ende der Sommerzeit bestimmen *)

   IF (tzchange[STD].at <= tm) & (tm < tzchange[DST].at) THEN
     (* Datum waehrend lokaler Sommerzeit *)
     tmIsDst  := DST;
     tmGmtOff := altzone;
     tmZone   := tzname[DST];
   ELSE
     (* Datum waehrend lokaler Standardzeit *)
     tmIsDst  := STD;
     tmGmtOff := timezone;
     tmZone   := tzname[STD];
   END;
 END; END;
 RETURN(ADR(tmrecbuf));
END localtime;

(*---------------------------------------------------------------------------*)

PROCEDURE gmtime ((* EIN/ -- *) tm : timeT ): TmPtr;

VAR date : DosDate;

BEGIN
 tm := local2UTC(tm);
 IF tm < VAL(timeT,0) THEN
   errno := EINVAL;
   RETURN(NULL);
 END;
 (* tm: Sekunden seit 1.1.70 0:00:00 UTC *)

 SecondsToDate(tm, date);
 WITH tmrecbuf DO WITH date DO
   tmSec    := INT(sec);
   tmMin    := INT(min);
   tmHour   := INT(hour);
   tmMDay   := INT(day);
   tmMon    := INT(mon);
   tmYear   := INT(year - 1900);
   tmWDay   := INT(wday);
   tmYDay   := INT(yday);
   tmIsDst  := STD;
   tmGmtOff := 0;
   tmZone   := ADR(UTCName);
 END; END;
 RETURN(ADR(tmrecbuf));
END gmtime;

(*---------------------------------------------------------------------------*)

PROCEDURE asctime ((* EIN/ -- *) tmrec : TmPtr ): StrPtr;

VAR __REG__ idx : UNSIGNEDWORD;

BEGIN
 IF tmrec = NULL THEN
   errno := EINVAL;
   RETURN(NULL);
 END;

 ascbuf := "??? ???";
 WITH tmrec^ DO
   WITH LCPOSIX.Time^ DO
     IF (tmWDay >= 0) & (tmWDay <= 6) THEN
       ascbuf[0] := abday[VAL(UNSIGNEDWORD,tmWDay)]^[0];
       ascbuf[1] := abday[VAL(UNSIGNEDWORD,tmWDay)]^[1];
       ascbuf[2] := abday[VAL(UNSIGNEDWORD,tmWDay)]^[2];
     END;
     IF (tmMon >= 0) & (tmMon <= 11) THEN
       ascbuf[4] := abmon[VAL(UNSIGNEDWORD,tmMon)]^[0];
       ascbuf[5] := abmon[VAL(UNSIGNEDWORD,tmMon)]^[1];
       ascbuf[6] := abmon[VAL(UNSIGNEDWORD,tmMon)]^[2];
     END;
   END;
   idx := FormInt(tmMDay, 3, 1, 7, ascbuf);
   ascbuf[idx] := ' ';
   idx := FormInt(tmHour, 0, 2, idx + 1, ascbuf);
   ascbuf[idx] := ':';
   idx := FormInt(tmMin, 0, 2, idx + 1, ascbuf);
   ascbuf[idx] := ':';
   idx := FormInt(tmSec, 0, 2, idx + 1, ascbuf);
   ascbuf[idx] := ' ';
   idx := FormInt(1900 + tmYear, 0, 1, idx + 1, ascbuf);
   ascbuf[idx]   := LF;
   ascbuf[idx+1] := 0C;
 END;
 RETURN(ADR(ascbuf));
END asctime;

(*---------------------------------------------------------------------------*)

PROCEDURE ctime ((* EIN/ -- *) tm : timeT ): StrPtr;
BEGIN
 RETURN(asctime(localtime(tm)));
END ctime;

(*---------------------------------------------------------------------------*)

PROCEDURE mktime ((* EIN/ -- *) tmrec : TmPtr ): timeT;

VAR __REG__ tmp  : INTEGER;
    __REG__ mlen : INTEGER;
    __REG__ norm : BOOLEAN;
    __REG__ i    : UNSIGNEDWORD;
            time : timeT;
            date : DosDate;

BEGIN
 IF tmrec = NULL THEN
   errno := EINVAL;
   RETURN(-1);
 END;

 WITH tmrec^ DO
   (* Sekunden normalisieren mit Uebertrag auf Minuten *)
   tmp := tmSec;
   IF tmp < 0 THEN
     tmp   := -tmp - 1;
     tmSec := 59 - tmp MOD 60;
     DEC(tmMin, tmp DIV 60 + 1);
   ELSIF tmp > 59 THEN
     tmSec := tmp MOD 60;
     INC(tmMin, tmp DIV 60);
   END;

   (* Minuten normalisieren mit Uebertrag auf Stunden *)
   tmp := tmMin;
   IF tmp < 0 THEN
     tmp   := -tmp - 1;
     tmMin := 59 - tmp MOD 60;
     DEC(tmHour, tmp DIV 60 + 1);
   ELSIF tmp > 59 THEN
     tmMin := tmp MOD 60;
     INC(tmHour, tmp DIV 60);
   END;

   (* Stunden normalisieren mit Uebertrag auf Tage im Monat *)
   tmp := tmHour;
   IF tmp < 0 THEN
     tmp    := -tmp - 1;
     tmHour := 23 - tmp MOD 24;
     DEC(tmMDay, tmp DIV 24 + 1);
   ELSIF tmp > 23 THEN
     INC(tmMDay, tmp DIV 24);
     tmHour := tmp MOD 24;
   END;

   norm := TRUE;
   REPEAT
     (* Monate normalisieren mit Uebertrag auf Jahre *)
     tmp := tmMon;
     IF tmp < 0 THEN
       tmp   := -tmp - 1;
       tmMon := 11 - tmp MOD 12;
       DEC(tmYear, tmp DIV 12 + 1);
     ELSIF tmp > 11 THEN
       INC(tmYear, tmp DIV 12);
       tmMon := tmp MOD 12;
     ELSE
       norm := FALSE;
     END;

     (* Tage normalisieren mit Uebertrag auf Monate *)
     mlen := INT(DaysPerMonth[tmYear MOD 4 = 0][tmMon]);
     tmp  := tmMDay - 1; (* Tage von Null an gezaehlt fuer Berechnung *)
     IF tmp < 0 THEN
       tmp    := -tmp - 1;
       tmMDay := mlen - tmp MOD mlen;
       DEC(tmMon, tmp DIV mlen + 1);
       norm := TRUE;
     ELSIF tmp >= mlen THEN
       tmMDay := tmp MOD mlen + 1;
       INC(tmMon, tmp DIV mlen);
       norm := TRUE;
     END;
   UNTIL ~norm;

   i := VAL(UNSIGNEDWORD,tmYear);
   WITH date DO
     sec  := VAL(UNSIGNEDWORD,tmSec);
     min  := VAL(UNSIGNEDWORD,tmMin);
     hour := VAL(UNSIGNEDWORD,tmHour);
     day  := VAL(UNSIGNEDWORD,tmMDay);
     mon  := VAL(UNSIGNEDWORD,tmMon);
     year := i + 1900;
   END;
   time := DateToSeconds(date);

   (* Die restlichen Felder neu berechnen *)

   tmYDay := INT(MonthDays[i MOD 4 = 0][tmMon]) + tmMDay - 1;
   tmWDay := (i * 365 + (i + 1) DIV 4 + VAL(UNSIGNEDWORD,tmYDay) + 1) MOD 7;
   tzset; (* TZ auswerten *)
   DstChange(date.year);
   IF (tzchange[STD].at <= time) & (time < tzchange[DST].at) THEN
     (* Datum waehrend lokaler Sommerzeit *)
     tmIsDst  := DST;
     tmGmtOff := altzone;
     tmZone   := tzname[DST];
   ELSE
     (* Datum waehrend lokaler Standardzeit *)
     tmIsDst  := STD;
     tmGmtOff := timezone;
     tmZone   := tzname[STD];
   END;

   RETURN(time);
 END; (* WITH *)
END mktime;

(*---------------------------------------------------------------------------*)

PROCEDURE strftime ((* EIN/ -- *) buf     : StrPtr;
                    (* EIN/ -- *) maxsize : sizeT;
                    (* EIN/ -- *) format  : StrPtr;
                    (* EIN/ -- *) tmrec   : TmPtr   ): sizeT;

VAR         fbuf   : FormBuf;
            hour12 : INTEGER;
    __REG__ len    : UNSIGNEDWORD;
    __REG__ fidx   : UNSIGNEDWORD;
    __REG__ bidx   : UNSIGNEDWORD;
    __REG__ c      : CHAR;

BEGIN
 IF tmrec = NULL THEN
   errno := EINVAL;
   RETURN(0);
 END;

 tzset;
 IF VAL(sizeT,MAXSTR) < maxsize THEN
   maxsize := VAL(sizeT,MAXSTR);
 END;
 WITH tmrec^ DO
   hour12 := tmHour;
   IF hour12 = 0 THEN
     hour12 := 12;
   ELSIF hour12 > 12 THEN
     DEC(hour12, 12);
   END;
   fidx := 0;
   bidx := 0;
   LOOP
     c := format^[fidx];
     IF c = 0C THEN
       EXIT;
     END;
     INC(fidx);
     IF c = '%' THEN
       c := format^[fidx];
       IF c = 0C THEN
         EXIT;
       END;
       INC(fidx);

       CASE c OF
         'a',
         'A' : IF (tmWDay >= 0) & (tmWDay <= 6) THEN
                 WITH LC.Time^ DO
                   IF c = 'A' THEN
                     AssignCToM2(day[VAL(UNSIGNEDWORD,tmWDay)], 0, fbuf);
                   ELSE
                     AssignCToM2(abday[VAL(UNSIGNEDWORD,tmWDay)], 0, fbuf);
                   END;
                 END;
                 len := VAL(UNSIGNEDWORD,Length(fbuf));
               ELSE
                 fbuf := "???";
                 len  := 3;
               END;
        |'b',
         'h',
         'B' : IF (tmMon >= 0) & (tmMon <= 11) THEN
                 WITH LC.Time^ DO
                   IF c = 'B' THEN
                     AssignCToM2(mon[VAL(UNSIGNEDWORD,tmMon)], 0, fbuf);
                   ELSE
                     AssignCToM2(abmon[VAL(UNSIGNEDWORD,tmMon)], 0, fbuf);
                   END;
                 END;
                 len := VAL(UNSIGNEDWORD,Length(fbuf));
               ELSE
                 fbuf := "???";
                 len  := 3;
               END;
        |'c' : len := VAL(UNSIGNEDWORD,strftime(CAST(StrPtr,ADR(fbuf)),
                                                VAL(sizeT,SIZE(fbuf)),
                                                LC.Time^.dtfmt,
                                                tmrec));
        |'C' : len := FormInt((1900 + tmYear) DIV 100, 0, 2, 0, fbuf);
        |'D' : len := FormInt(tmMon + 1, 0, 2, 0, fbuf);
               fbuf[len] := '/';
               len := FormInt(tmMDay, 0, 2, len + 1, fbuf);
               fbuf[len] := '/';
               len := FormInt(tmYear MOD 100, 0, 2, len + 1, fbuf);
        |'d' : len := FormInt(tmMDay, 0, 2, 0, fbuf);
        |'e' : len := FormInt(tmMDay, 2, 1, 0, fbuf);
        |'H' : len := FormInt(tmHour, 0, 2, 0, fbuf);
        |'I' : len := FormInt(hour12, 0, 2, 0, fbuf);
        |'k' : len := FormInt(tmHour, 2, 1, 0, fbuf);
        |'l' : len := FormInt(hour12, 2, 1, 0, fbuf);
        |'j' : len := FormInt(tmYDay, 0, 3, 0, fbuf);
        |'M' : len := FormInt(tmMin, 0, 2, 0, fbuf);
        |'m' : len := FormInt(tmMon + 1, 0, 2, 0, fbuf);
        |'n' : len := 1; fbuf[0] := LF;
        |'p' : WITH LC.Time^ DO
                 IF tmHour < 12 THEN
                   AssignCToM2(ampm[0], 0, fbuf);
                 ELSE
                   AssignCToM2(ampm[1], 0, fbuf);
                 END;
               END;
               len := VAL(UNSIGNEDWORD,Length(fbuf));
        |'R' : len := FormInt(tmHour, 0, 2, 0, fbuf);
               fbuf[len] := ':';
               len := FormInt(tmMin, 0, 2, len + 1, fbuf);
        |'r' : len := FormInt(hour12, 0, 2, 0, fbuf);
               fbuf[len] := ':';
               len := FormInt(tmMin, 0, 2, len + 1, fbuf);
               fbuf[len] := ':';
               len := FormInt(tmSec, 0, 2, len + 1, fbuf);
               fbuf[len]   := ' ';
               fbuf[len+1] := EOS;
               WITH LC.Time^ DO
                 IF tmHour < 12 THEN
                   strcat(ADR(fbuf), ampm[0]);
                 ELSE
                   strcat(ADR(fbuf), ampm[1]);
                 END;
               END;
               len := VAL(UNSIGNEDWORD,Length(fbuf));
        |'S' : len := FormInt(tmSec, 0, 2, 0, fbuf);
        |'T' : len := FormInt(tmHour, 0, 2, 0, fbuf);
               fbuf[len] := ':';
               len := FormInt(tmMin, 0, 2, len + 1, fbuf);
               fbuf[len] := ':';
               len := FormInt(tmSec, 0, 2, len + 1, fbuf);
        |'t' : len := 1; fbuf[0] := HT;
        |'U' : len := FormInt((tmYDay - tmWDay + 7) DIV 7, 0, 2, 0, fbuf);
        |'W' : IF tmWDay = 0 THEN
                 (* Sonntag gehoert zur letzten Woche *)
                 len := FormInt((tmYDay - tmWDay + 1 + 0) DIV 7, 0, 2, 0, fbuf);
               ELSE
                 len := FormInt((tmYDay - tmWDay + 1 + 7) DIV 7, 0, 2, 0, fbuf);
               END;
        |'w' : len := FormInt(tmWDay, 0, 1, 0, fbuf);
        |'x' : len := VAL(UNSIGNEDWORD,strftime(CAST(StrPtr,ADR(fbuf)),
                                                VAL(sizeT,SIZE(fbuf)),
                                                LC.Time^.dfmt,
                                                tmrec));
        |'X' : len := VAL(UNSIGNEDWORD,strftime(CAST(StrPtr,ADR(fbuf)),
                                                VAL(sizeT,SIZE(fbuf)),
                                                LC.Time^.tfmt,
                                                tmrec));
        |'Y' : len := FormInt(1900 + tmYear, 0, 4, 0, fbuf);
        |'y' : len := FormInt(tmYear MOD 100, 0, 2, 0, fbuf);
        |'Z' : IF tmIsDst = 0 THEN
                 Assign(TzName[STD], fbuf);
               ELSIF tmIsDst > 0 THEN
                 Assign(TzName[DST], fbuf);
               ELSE
                 fbuf := "";
               END;
               len := VAL(UNSIGNEDWORD,Length(fbuf));
        |'%' : len := 1; fbuf[0] := '%';
       ELSE    len := 0; (* Falsches Format ignorieren *)
       END; (* CASE *)

       fbuf[len] := EOS;
       IF VAL(sizeT,bidx) + VAL(sizeT,len) < maxsize THEN
         IF buf # NULL THEN
           AssignM2ToC(fbuf, VAL(StrRange,len), ADDADR(buf, bidx));
         END;
         INC(bidx, len);
       ELSE
         RETURN(0);
       END;
     ELSE
       IF VAL(sizeT,bidx) < maxsize THEN
         IF buf # NULL THEN
           buf^[bidx] := c;
         END;
         INC(bidx);
       ELSE
         RETURN(0);
       END;
     END; (* IF c = '%' *)
   END; (* LOOP *)

   IF VAL(sizeT,bidx) < maxsize THEN
     IF buf # NULL THEN
       buf^[bidx] := 0C;
     END;
     RETURN(VAL(sizeT,bidx));
   ELSE
     RETURN(0);
   END;
 END; (* WITH tmrec^*)
END strftime;

(*===========================================================================*)

BEGIN (* tim *)
 UTCName := "UTC";
 tzinit  := FALSE;
END tim.

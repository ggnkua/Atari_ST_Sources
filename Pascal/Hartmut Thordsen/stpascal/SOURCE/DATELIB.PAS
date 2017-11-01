{$M+,E+} PROGRAM date_library;

{ V2.2, Hartmut Thordsen, Dezember 1987 }

{ Die Algorithmen zur Umwandlung von Gregorianischem und Julianischem Datum
  sind adaptiert aus Hewlett-Packard HP-41C Users' Library Solutions
  "Calendars";	Die Funktionen sind gÅltig vom 1.3.1800 bis 28.2.2100 }

PROCEDURE dmy_date (d, m, y : INTEGER; VAR date : REAL);
BEGIN
d := abs (d) MOD 100;
m := abs (m) MOD 100;
y := abs (y) MOD 10000;
date := d + m/1E2 + y/1E6;
END; { dmy_date }

PROCEDURE date_dmy (date : REAL; VAR d, m, y : INTEGER);
BEGIN
date := abs (date);
d := trunc (date);
date := (date - d) * 100;
m := trunc (date);
y := round ((date - m) * 1E4);
END; { date_dmy }


FUNCTION sysdate_date (sdate : INTEGER) : REAL;
VAR	d, m, y : INTEGER;
	date	: REAL;
BEGIN
d :=  sdate & $001F;
m := ShR ((sdate & $01E0), 5);
y := ShR ((sdate & $FE00), 9) + 1980;
dmy_date (d, m, y, date);
sysdate_date := date;
END; { sysdate_date }

FUNCTION date_sysdate (date : REAL) : INTEGER;
VAR	d, m, y : INTEGER;
BEGIN
date_dmy (date, d, m, y);
m := ShL (m, 5);
y := ShL ((y - 1980), 9);
date_sysdate := d | m | y;
END; { date_sysdate }


FUNCTION get_date : REAL;
	FUNCTION zzzdgd2a : INTEGER; GEMDOS ($2A);
BEGIN
get_date := sysdate_date (zzzdgd2a);
END; { get_date }

PROCEDURE set_date (date : REAL);
	PROCEDURE zzzdgd2b (date : INTEGER); GEMDOS ($2B);
BEGIN
zzzdgd2b (date_sysdate(date));
END; { set_date }


FUNCTION julian_date (greg_date : REAL) : LONG_INTEGER;
CONST	a	= 1720982;
VAR	d, m, y : INTEGER;
	b, c	: LONG_INTEGER;
	last_hundred	: BOOLEAN;
BEGIN
date_dmy (greg_date, d, m, y);
last_hundred := (y < 1900) OR ((y = 1900) AND (m < 3));
IF m <= 2 THEN
    BEGIN y := y - 1; m := m + 12 END;
m := m + 1;
b := y;       { Zuweisung fÅr LONG_INTEGER-Arithmetik notwendig }
b := (b * 365) + (b DIV 4);
c := trunc (30.6001 * m);
c := a + b + c + d;
IF last_hundred THEN c := c + 1;
julian_date := c;
END; { julian_date }

FUNCTION gregorian_date (jul_date : LONG_INTEGER) : REAL;
VAR	d, m, y : INTEGER;
	date	: REAL;
	a, b, c, e, f, g, h	: LONG_INTEGER;
BEGIN
a := jul_date + 68569;
b := (4 * a) DIV 146097;
c := a - ((146097 * b + 3) DIV 4);
e := ((c + 1) * 4000) DIV 1461001;
f := c + 31 - ((1461 * e) DIV 4);
g := (80 * f) DIV 2447;
h := g DIV 11;
d := int (f - ((2447 * g) DIV 80));
m := int (g + 2 - 12*h);
y := int (100 * (b - 49) + e + h);
dmy_date (d, m, y, date);
gregorian_date := date;
END; { gregorian_date }


FUNCTION date_difference (date1, date2 : REAL) : INTEGER;
VAR	j1, j2, diff	: LONG_INTEGER;
BEGIN
j1 := julian_date (date1);
j2 := julian_date (date2);
diff := j1 - j2;
IF abs (diff) < maxint THEN date_difference := int (diff)
ELSE date_difference := 0;
END; { date_difference }

FUNCTION related_date (date : REAL; offset : INTEGER) : REAL;
BEGIN
related_date := gregorian_date (julian_date (date) + offset)
END; { related_date }


FUNCTION weekday (date : REAL) : INTEGER;
VAR	a	: LONG_INTEGER;
BEGIN
a := (julian_date (date) + 1) MOD 7;
weekday := int (a);
END; { weekday }


PROCEDURE weekday_str (wday, width : INTEGER; VAR s : STRING);
VAR	i	: INTEGER;
BEGIN
wday := abs (wday) MOD 7;
CASE wday OF
    0 : s := 'Sonntag'; 	1 : s := 'Montag';	2 : s := 'Dienstag';
    3 : s := 'Mittwoch';	4 : s := 'Donnerstag';	5 : s := 'Freitag';
    OTHERWISE : s := 'Samstag';
    END;
width := abs (width);
IF width <> 0 THEN
    IF width <= length (s) THEN s := copy (s, 1, width)
    ELSE FOR i := 1 TO (width - length (s)) DO s := concat (s, ' ');
END; { weekday_str }


FUNCTION day_of_year (date : REAL) : INTEGER;
VAR	d, m, y : INTEGER;
	firstjan: REAL;
BEGIN
date_dmy (date, d, m, y);
dmy_date (1, 1, y, firstjan);
day_of_year := date_difference (date, firstjan) + 1;
END; { day_of_year }

FUNCTION doy_date (doy, year : INTEGER) : REAL;
VAR	firstjan: REAL;
BEGIN
dmy_date (1, 1, year, firstjan);
doy_date := related_date (firstjan, (doy - 1))
END; { doy_date }

FUNCTION remaining_days (date : REAL) : INTEGER;
VAR	d, m, y : INTEGER;
	firstjan: REAL;
BEGIN
date_dmy (date, d, m, y);
dmy_date (1, 1, y+1, firstjan);
remaining_days := date_difference (firstjan, date) - 1;
END; { remaining_days }


FUNCTION date_earlier (date1, date2 : REAL) : BOOLEAN;
BEGIN
date_earlier := (julian_date (date1)) < (julian_date (date2));
END; { date_earlier }

FUNCTION date_equal (date1, date2 : REAL) : BOOLEAN;
BEGIN
date_equal := (long_round (date1 * 1E6)) = (long_round (date2 * 1E6));
END; { date_equal }


FUNCTION date_future (date : REAL) : BOOLEAN;
BEGIN
date_future := date_earlier (get_date, date);
END; { date_future }

FUNCTION date_past (date : REAL) : BOOLEAN;
BEGIN
date_past := date_earlier (date, get_date);
END; { date_past }


FUNCTION date_ok (date : REAL) : BOOLEAN;
BEGIN
date_ok := date_equal (gregorian_date (julian_date (date)), date)
END; { date_ok }


FUNCTION str_date (s : STRING; VAR date : REAL) : BOOLEAN;
LABEL	1;
VAR	sd, sm, sy	: STRING;
	d, m, y 	: INTEGER;
	date2		: REAL;

	FUNCTION zzzdstr_to_int (s : STRING; VAR x : INTEGER) : BOOLEAN;
	  { abgespeckte Version aus Conversion-Library }
	LABEL	1;
	VAR	negativ : BOOLEAN;
		y	: INTEGER;
		c	: CHAR;
	BEGIN
	zzzdstr_to_int := FALSE;
	IF length(s) = 0 THEN GOTO 1;
	y := 0;
	WHILE (length(s) > 0) DO
	    BEGIN
	    c := s[1];
	    s := copy (s, 2, length(s)-1);
	    IF (c IN ['0'..'9']) AND (y < maxint DIV 10) THEN
		y := y * 10 + (ord(c) - 48)
	    ELSE GOTO 1;
	    END;
	x := y;
	zzzdstr_to_int := TRUE;
	1:
	END; { zzzdstr_to_int }
BEGIN
str_date := FALSE;
IF (pos('/',s) > 1) AND (pos('/',s) < length(s)) THEN
    BEGIN { Format englisch mit Schraegstrichen }
    sy := copy (s,1,pos('/',s)-1);
    s :=  copy (s,pos('/',s)+1,length(s)-pos('/',s));
    IF (pos('/',s) > 1) AND (pos('/',s) < length(s)) THEN
	BEGIN
	sm := copy (s,1,pos('/',s)-1);
	sd := copy (s,pos('/',s)+1,length(s)-pos('/',s));
	END
    ELSE GOTO 1;
    END
ELSE IF (pos('.',s) > 1) AND (pos('.',s) < length(s)) THEN
    BEGIN { Format deutsch mit Punkten }
    sd := copy (s,1,pos('.',s)-1);
    s :=  copy (s,pos('.',s)+1,length(s)-pos('.',s));
    IF (pos('.',s) > 1) AND (pos('.',s) < length(s)) THEN
	BEGIN
	sm := copy (s,1,pos('.',s)-1);
	sy := copy (s,pos('.',s)+1,length(s)-pos('.',s));
	END
    ELSE GOTO 1;
    END
ELSE IF (length(s) >= 6) THEN
    BEGIN { Format deutsch ohne Punkte }
    sd := copy (s,1,2);
    sm := copy (s,3,2);
    sy := copy (s,5,length(s)-4);
    END
ELSE GOTO 1;
IF NOT (zzzdstr_to_int(sd,d) AND zzzdstr_to_int(sm,m) AND
	zzzdstr_to_int(sy,y)) THEN GOTO 1;
IF y < 100 THEN y := y + 1900;
dmy_date (d, m, y, date2);
IF NOT date_ok (date2) THEN GOTO 1;
date := date2;
str_date := TRUE;
1:
END; { str_date }


PROCEDURE date_str (date : REAL; width : INTEGER; VAR s : STRING);
VAR	i, wdate, d, m, y	: INTEGER;
BEGIN
width := abs (width);
s := '';
CASE width OF
    0, 1, 2	: wdate := 0;
    3, 4, 5	: wdate := 3;
    6, 7	: wdate := 6;
    8, 9	: BEGIN
	wdate := 8;
	date_dmy (date, d, m, y);
	y := (y MOD 100) * 100;
	dmy_date (d, m, y, date);
	END;
    OTHERWISE	: wdate := 10;
    END;
date := abs (date) / 100 + 5E-9 {Ausgleich von Rundungsfehlern};
FOR i := 1 TO wdate DO
    BEGIN
    IF i IN [3, 6] THEN s := concat (s, '.')
    ELSE BEGIN
	date := (date - trunc (date)) * 10;
	s := concat (s, chr (trunc (date)+48));
	END;
    END;
FOR i := 1 TO (width - wdate) DO s := concat (s, ' ');
END; { date_str }

BEGIN { leeres Hauptprogramm } END.

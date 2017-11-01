{$M+,E+} PROGRAM time_library;

{ V2.2, Hartmut Thordsen, Dezember 1987 }

PROCEDURE hms_time (h, m, s : INTEGER; VAR t : REAL);
BEGIN
h := abs (h);
m := abs (m) MOD 100;
s := abs (s) MOD 100;
t := h + m/1E2 + s/1E4;
END; { hms_time }

PROCEDURE time_hms (t : REAL; VAR h, m, s : INTEGER);
BEGIN
t := abs (t);
h := trunc (t);
t := (t - h) * 100;
m := trunc (t);
s := round ((t - m) * 1E2);
END; { time_hms }


FUNCTION systime_time (stime : INTEGER) : REAL;
VAR	h, m, s : INTEGER;
	t	: REAL;
BEGIN
h := ShR ((stime & $F800), 11);
m := ShR ((stime & $07E0),  5);
s := ShL ((stime & $001F),  1);
hms_time (h, m, s, t);
systime_time := t;
END; { systime_time }

FUNCTION time_systime (time : REAL) : INTEGER;
VAR	h, m, s : INTEGER;
BEGIN
time_hms (time, h, m, s);
h := ShL (h, 11);
m := ShL (m,  5);
s := s DIV 2;
time_systime := h | m | s;
END; { time_systime }


FUNCTION get_time : REAL;
	FUNCTION zzztgd2c : INTEGER; GEMDOS ($2C);
BEGIN
get_time := systime_time (zzztgd2c);
END; { get_time }

PROCEDURE set_time (time : REAL);
	PROCEDURE zzztgd2d (time : INTEGER); GEMDOS ($2D);
BEGIN
zzztgd2d (time_systime(time));
END; { set_time }


FUNCTION time_dec (time : REAL) : REAL;
VAR	h, m, s : INTEGER;
	t	: REAL;
BEGIN
time_hms (time, h, m, s);
t := h + (m / 60) + (s / 3600);
IF time < 0 THEN t := -t;
time_dec := t;
END;

FUNCTION dec_time (dec : REAL) : REAL;
VAR	h, m, s : INTEGER;
	t	: REAL;
BEGIN
t := abs (dec);
h := trunc (t);
t := t - h;
s := round (t * 3600);
m := s DIV 60;
s := s MOD 60;
hms_time (h, m, s, t);
IF dec < 0 THEN t := -t;
dec_time := t;
END;


FUNCTION add_time (time1, time2 : REAL) : REAL;
VAR	t1, t2	: REAL;
BEGIN
t1 := time_dec (time1);
t2 := time_dec (time2);
add_time := dec_time (t1 + t2);
END;

FUNCTION sub_time (time1, time2 : REAL) : REAL;
BEGIN
sub_time := add_time(time1,-time2);
END;


FUNCTION time_ok (time : REAL) : BOOLEAN;
VAR	h, m, s : INTEGER;
BEGIN
time_hms (time, h, m, s);
time_ok := (m < 60) AND (s < 60);
END; { time_ok }


FUNCTION str_time (s : STRING; VAR time : REAL) : BOOLEAN;
LABEL	1;
VAR	format5 	: BOOLEAN;
	sh, sm, ss	: STRING;
	h, m, sec	: INTEGER;
	t		: REAL;

	FUNCTION zzztstr_to_int (s : STRING; VAR x : INTEGER) : BOOLEAN;
	  { abgespeckte Version aus Conversion-Library }
	LABEL	1;
	VAR	negativ : BOOLEAN;
		y	: INTEGER;
		c	: CHAR;
	BEGIN
	zzztstr_to_int := FALSE;
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
	zzztstr_to_int := TRUE;
	1:
	END; { zzztstr_to_int }
BEGIN
str_time := FALSE;
format5 := FALSE; { Boole'sche Variable fr das Format mm.ss }
sh := '0';
ss := '0';
IF (pos(':',s) > 1) AND (pos(':',s) < length(s)) THEN
    BEGIN { Format mit Doppelpunkten }
    sh := copy (s,1,pos(':',s)-1);
    s :=  copy (s,pos(':',s)+1,length(s)-pos(':',s));
    IF (pos(':',s) > 1) AND (pos(':',s) < length(s)) THEN
	BEGIN
	sm := copy (s,1,pos(':',s)-1);
	ss := copy (s,pos(':',s)+1,length(s)-pos(':',s));
	END
    ELSE sm := s;
    END
ELSE IF (pos('.',s) > 1) AND (pos('.',s) < length(s)) THEN
    BEGIN { Format 5 mit Punkt }
    format5 := TRUE;
    sm := copy (s,1,pos('.',s)-1);
    ss := copy (s,pos('.',s)+1,length(s)-pos('.',s));
    END
ELSE IF (length(s) >= 4) THEN
    BEGIN { Format deutsch ohne Punkte }
    sh := copy (s,1,2);
    IF (length(s) >= 6) THEN
	BEGIN
	sm := copy (s,3,2);
	ss := copy (s,5,length(s)-4);
	END
    ELSE sm := copy (s,3,length(s)-2);
    END
ELSE GOTO 1;
IF NOT (zzztstr_to_int(sh,h) AND zzztstr_to_int(sm,m) AND
	zzztstr_to_int(ss,sec)) THEN GOTO 1;
IF format5 THEN
    BEGIN
    h := m DIV 60;
    m := m MOD 60;
    END;
IF (m > 59) OR (sec > 59) THEN GOTO 1;
hms_time (h, m, sec, time);
str_time := TRUE;
1:
END; { str_time }


PROCEDURE time_str (time : REAL; width : INTEGER; VAR s : STRING);
VAR	i, wtime	: INTEGER;
BEGIN
width := abs (width);
s := '';
CASE width OF
    0, 1	: wtime := 0;
    2, 3, 4	: wtime := 2;
    5, 6, 7	: wtime := 5;
    OTHERWISE	: wtime := 8;
    END;
time := abs (time) / 100 + 5E-7 {Ausgleich von Rundungsfehlern};
FOR i := 1 TO wtime DO
    BEGIN
    IF i IN [3, 6] THEN s := concat (s, ':')
    ELSE BEGIN
	time := (time - trunc (time)) * 10;
	s := concat (s, chr (trunc (time)+48));
	END;
    END;
FOR i := 1 TO (width - wtime) DO s := concat (s, ' ');
END; { time_str }

BEGIN {leeres Hauptprogramm} END.

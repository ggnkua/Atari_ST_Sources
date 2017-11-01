{$M+,E+} PROGRAM conversion_library;

{ V2.2, Hartmut Thordsen, Dezember 1987 }

PROCEDURE zzzctrim (VAR s : STRING);
  { zzzctrim, entfernt Leerzeichen am Anfang und Ende von s. }
BEGIN
WHILE (length(s) > 0) AND (s[1] = ' ') DO
    s := copy (s, 2, length(s)-1);
WHILE (length(s) > 0) AND (s[length(s)] = ' ') DO
    s := copy (s, 1, length(s)-1);
END; { zzzctrim }


FUNCTION str_to_long_int (s : STRING; VAR x : LONG_INTEGER) : BOOLEAN;
LABEL	1;
VAR	negativ : BOOLEAN;
	y	: LONG_INTEGER;
	c	: CHAR;
BEGIN
str_to_long_int := FALSE;
zzzctrim (s);
negativ := FALSE;
y := 0;
CASE s[1] OF
  '+' : s := copy (s, 2, length(s)-1);
  '-' : BEGIN
	negativ := TRUE;
	s := copy (s, 2, length(s)-1);
	END;
  OTHERWISE : ;
  END;
WHILE (length(s) > 0) DO
    BEGIN
    c := s[1];
    s := copy (s, 2, length(s)-1);
    IF (c IN ['0'..'9']) AND (y < long_maxint DIV 10) THEN
	y := y * 10 + (ord(c) - 48)
    ELSE GOTO 1;
    END;
x := y;
IF negativ THEN x := -x;
str_to_long_int := TRUE;
1:
END; { str_to_long_int }


FUNCTION str_to_int (s : STRING; VAR x : INTEGER) : BOOLEAN;
VAR y : LONG_INTEGER;
BEGIN
str_to_int := FALSE;
IF str_to_long_int (s,y) THEN
    IF abs(y) <= maxint THEN
	BEGIN
	str_to_int := TRUE;
	x := INT(y);
	END;
END; { str_to_int }


FUNCTION str_to_real (s : STRING; VAR x : REAL) : BOOLEAN;
LABEL	1;
VAR	snk, sexp	: STRING;
	vk , nk 	: LONG_INTEGER;
	exp, p		: INTEGER;
	y		: REAL;
	negmant, negexp : BOOLEAN;
BEGIN
str_to_real := FALSE;
zzzctrim (s);
exp := 0;
p := pos ('E',s);
IF p <> 0 THEN
    BEGIN
    sexp := copy (s, p+1, length(s)-p);
    s := copy (s, 1, p-1);
    IF str_to_int (sexp,exp) THEN;
    IF (abs(exp) > 37) THEN GOTO 1;
    END;
negexp := FALSE;
IF exp < 0 THEN negexp := TRUE;
exp := abs(exp);
nk := 0;
snk := '';
p := pos ('.',s);
IF p <> 0 THEN snk := copy (s, p+1, length(s)-p);
IF length(snk) > 0 THEN
    IF (snk[1] IN ['0'..'9']) THEN
	BEGIN
	s := copy (s, 1, p-1);
	IF str_to_long_int (snk,nk) THEN;
	IF (nk < 0) THEN GOTO 1;
	END
    ELSE GOTO 1;
vk := 0;
IF NOT str_to_long_int (s,vk) THEN GOTO 1;
negmant := FALSE;
IF vk < 0 THEN negmant := TRUE;
vk := abs(vk);
y := nk / PwrOfTen(length(snk));
y := y + vk;
IF negexp THEN y := y / PwrOfTen(exp)
ELSE y := y * PwrOfTen(exp);
IF negmant THEN y := -y;
x := y;
str_to_real := TRUE;
1:
END; { str_to_real }


PROCEDURE long_int_to_str (x : LONG_INTEGER; VAR s : STRING);
VAR	stellen : INTEGER;
	hilf	: LONG_INTEGER;
BEGIN
s := '';
IF x < 0 THEN
    BEGIN
    s := '-';
    x := abs(x);
    END;
stellen := 1;
WHILE long_round(PwrOfTen(stellen-1)) <= (x DIV 10) DO
    stellen := stellen + 1;
FOR stellen := stellen DOWNTO 1 DO
    BEGIN
    hilf := x;
    x := x MOD long_round(PwrOfTen(stellen-1));
    hilf := hilf - x;
    hilf := hilf DIV long_round(PwrOfTen(stellen-1));
    s := concat(s,chr(int(hilf)+48));
    END;
END; { long_int_to_str }


PROCEDURE int_to_str (x : INTEGER; VAR s : STRING);
VAR	l	: LONG_INTEGER;
BEGIN
l := x;
long_int_to_str (l,s);
END; { int_to_str }


PROCEDURE real_to_str (x : REAL; VAR s : STRING);
CONST	expstep = 3;
VAR	shilf	: STRING;
	vk, exp, n	: INTEGER;
	loopende	: BOOLEAN;
	epsilon 	: REAL;
		{enthÑlt gedachte 12. Ziffer der Mant. mit Wert 5}
BEGIN
IF x = 0.0 THEN s := '0'
ELSE BEGIN
    n := 11; {Anzahl der relevanten Mantissenstellen}
    s := '';
    IF x < 0 THEN s := '-';
    x := abs(x);
    exp := 0;
    IF x < 1.0 THEN
	BEGIN { negativer Exponent }
	WHILE (x * pwroften(-exp) < 1.0) DO
	    exp := exp - expstep;
	x := x * pwroften(-exp);
	END
    ELSE BEGIN { positiver Exponent }
	WHILE (x / pwroften(exp) >= pwroften(expstep)) DO
	    exp := exp + expstep;
	x := x / pwroften(exp);
	END;
    vk := trunc(x);	    { Rundungsfehler bei den ersten drei Ziffern }
    int_to_str (vk, shilf); { nicht berÅcksichtigt, da nicht wahrschein- }
    n := n - length(shilf); { lich -  dann wÑr der Rechner sowieso Mist. }
    s := concat (s, shilf);
    shilf := '';
    x := x - vk;
    IF x <> 0 THEN
	BEGIN { Es existieren Nachkommastellen }
	FOR n := n DOWNTO 1 DO
	    BEGIN
	    x := x * pwroften(1);
	    epsilon := 5 / pwroften(n);
	    IF (x + epsilon) < pwroften(1) THEN
		BEGIN { nur, wenn Ziffer zwischen 0 und 9 liegt }
		shilf := concat (shilf, chr(trunc(x+epsilon)+48));
		x := x - trunc(x+epsilon);
		END
	    ELSE shilf := concat (shilf, '9');
	      { Die letzte Ziffer war 1 zu klein, es werden nur noch 9en
		angehangen. x wird nicht korrigiert, so daû diese Bedingung
		bei jedem weiteren Durchlauf erfÅllt ist. }
	    END;
	loopende := FALSE;
	REPEAT
	    IF length(shilf) > 0 THEN
		IF copy(shilf,length(shilf),1) = '0' THEN
		    delete(shilf,length(shilf),1)
		ELSE loopende := TRUE { alle Nullen entfernt }
	    ELSE loopende := TRUE { nur Nullen }
	    UNTIL loopende;
	IF length(shilf) > 0 THEN
	    s := concat (s, '.', shilf);
	END; { Nachkommastellen-Bearbeitung }
    IF exp <> 0 THEN
	BEGIN
	int_to_str (exp, shilf);
	s := concat (s, 'E', shilf);
	END;
    END;
END; { real_to_str }

BEGIN { leeres Hauptprogramm } END.

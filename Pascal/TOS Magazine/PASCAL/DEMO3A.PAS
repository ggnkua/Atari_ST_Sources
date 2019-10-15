(* Demoprogramm fr Funktionen/Prozeduren der System-Unit *)
(* Ein-/Ausgabe auf dem Bildschirm, Umwandlung etc.       *)

PROGRAM DEMO3A;

VAR wert:REAL;
    zeichenkette:STRING;
    test:INTEGER;
    zeichen:CHAR;

BEGIN
IF ParamCount>0 THEN
        BEGIN
        WRITELN('Kommandozeilen-Parameter:');
        FOR test:=1 TO ParamCount DO WRITELN(ParamStr(test));
        END
ELSE WRITELN('Keine Kommandozeilen-Parameter.');

wert:=10+2/3;
WRITELN('Wert unformatiert: ',wert);
WRITELN('Wert mit Format 8:2 : ',wert:8:2);

STR(wert:8:3,zeichenkette);
WRITELN('Umgewandelt nach STRING: ',zeichenkette);

wert:=12345678;
WRITELN('Exponentialdarstellung: ',wert:13:-1);

zeichenkette:='29.11';
WRITELN('Zeichenkette: ',zeichenkette);
VAL(zeichenkette,wert,test);
IF test=0 THEN WRITELN('Umgewandelt nach REAL: ',wert:8:3)
          ELSE WRITELN('Konvertierung nach REAL fehlgeschlagen.');

RANDOMIZE;
WRITELN('Zufallszahlen 0 <= x < 1:');
FOR test:=1 TO 4 DO WRITELN(RANDOM:8:6);
WRITELN('Zufallszahlen 0 <= x < 1000:');
FOR test:=1 TO 4 DO WRITELN(RANDOM(1000));

zeichen:='a';
WRITELN('UPCASE(',zeichen,')=',UPCASE(zeichen));

FillChar(zeichenkette,sizeof(zeichenkette),'-'); (* Fllen *)
zeichenkette[0]:=CHAR(sizeof(zeichenkette)-1); (* L„nge setzen *)
WRITELN(zeichenkette);

END.

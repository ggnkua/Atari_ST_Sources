PROGRAM Umfangtest;
CONST PI = 3.141592654;
      Anfrage = 'Radius: ';
VAR radius,umfang:REAL;
BEGIN
WRITE(Anfrage);
READLN(radius);
umfang := 2*PI*radius;
WRITELN('Umfang: ',umfang);
END.

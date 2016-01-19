PROGRAM sdemo;

VAR i,j:INTEGER;

PROCEDURE fsound(kanal,frequenz,volumen,modus:INTEGER);
C;

PROCEDURE sound(kanal,periode,volumen,modus:INTEGER);
C;

PROCEDURE pause(zeit:INTEGER);
C;

PROCEDURE setcfreq(periode:INTEGER);
C;

PROCEDURE setloud(kanal,volumen:INTEGER);
C;

PROCEDURE setfreq(kanal,frequenz:INTEGER);
C;

PROCEDURE setnoise(periode:INTEGER);
C;

PROCEDURE setvoice(kanal,modus:INTEGER);
C;

PROCEDURE setcurve(form:INTEGER);
C;

BEGIN
fsound(0,200,15,1);      { Kanal 0 auf 200 Hz }
fsound(1,201,15,1);      { Kanal 1 auf 201 Hz }
fsound(2,199,15,1);      { Kanal 2 auf 199 Hz }

pause(600);              { 3 Sekunden Pause }

setcfreq(7813);          { HÅllperiode 1 Sekunde }
setloud(0,16);           { HÅllkurve aktivieren }
setloud(1,16);
setloud(2,16);

FOR i:=50 TO 400 DO
   BEGIN
   setfreq(0,i);
   setfreq(1,i+1);
   setfreq(2,i-1);
   setcurve(0);        { HÅllkurve starten }
   pause(100);         { Warten }
   i:=i+9;
   END;

setvoice(0,2);           { Rauschen ein }
sound(1,0,0,0);          { Kanal 1 aus }
sound(2,0,0,0);          { Kanal 2 aus }
setcfreq(15625);         { HÅllperiode 2 Sekunden }
setcurve(14);            { Dreieck }

FOR j:=0 TO 2 DO
   BEGIN
   FOR i:=0 TO 31 DO
     BEGIN
     setnoise(i);
     pause(20);
     END;
   FOR i:=30 DOWNTO 1 DO
     BEGIN
     setnoise(i);
     pause(20);
     END;
   END;

FOR i:=0 TO 31 DO
  BEGIN
  setnoise(i);
  setcurve(0);
  pause(120);
  END;

sound(0,0,0,0);          { Ausschalten }
sound(1,0,0,0);
sound(2,0,0,0);
END.


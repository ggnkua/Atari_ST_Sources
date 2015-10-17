MODULE Mathetest;

FROM MathLib0  IMPORT  pi,e,ln,log,ld,exp,pwrOfTen,pwrOfTwo,logar,power,sin,cos,
                       tan,arcsin,arccos,arctan,sinh,cosh,tanh,artanh,sqrt,
                       fraction,rad,deg,real,entier;

FROM InOut     IMPORT  FlushKbd,BusyRead,WriteLn,WriteReal,ReadReal,
        WriteString;


PROCEDURE PI;
 BEGIN
  WriteString ('pi         :'); WriteReal(pi,30,14);WriteLn;
  WriteString ('pi-3       :'); WriteReal(fraction(pi),30,14);WriteLn;
  WriteString ('e          :'); WriteReal(e,30,14);WriteLn;
  WriteString ('e          :'); WriteReal(exp(1.0),30,14);WriteLn;
  WriteString ('e-2        :'); WriteReal(fraction(e),30,14);WriteLn;
  WriteString ('-27        :'); WriteReal(power(-3.0,3.0),30,14);WriteLn;
  WriteString ('1          :'); WriteReal(ln(e),30,14);WriteLn;
  WriteString ('1          :'); WriteReal(logar(e,e),30,14);WriteLn;
  WriteString ('sqrt(4)    :'); WriteReal(sqrt(4.0),30,14);WriteLn;
  WriteString ('4          :'); WriteReal(pwrOfTwo(2.0),30,14);WriteLn;
  WriteString ('1000       :'); WriteReal(pwrOfTen(3.0),30,14);WriteLn;
  WriteString ('pi/2       :'); WriteReal(pi/2.,30,14);WriteLn;
  WriteString ('arccos(0)  :'); WriteReal(arccos(0.),30,14);WriteLn;
  WriteString ('arcsin(1)  :'); WriteReal(arcsin(1.),30,14);WriteLn;
  WriteString ('sin(pi)    :'); WriteReal(sin(pi),30,14);WriteLn;
  WriteString ('sin(pi/2)  :'); WriteReal(sin(pi/2.),30,14);WriteLn;
  WriteString ('sin(0)     :'); WriteReal(sin(0.),30,14);WriteLn;
  WriteString ('cos(0)     :'); WriteReal(cos(0.),30,14);WriteLn;
  WriteString ('cos(pi/2)  :'); WriteReal(cos(pi/2.),30,14);WriteLn;
  WriteString ('cos(pi)    :'); WriteReal(cos(pi),30,14);WriteLn;
 END PI;

PROCEDURE Taste;
  VAR c:CHAR;
  BEGIN
    FlushKbd;
    BusyRead (c);
    IF c = 0C THEN REPEAT BusyRead (c) UNTIL c # 0C END
  END Taste;

BEGIN
  PI;
  Taste;
END Mathetest.

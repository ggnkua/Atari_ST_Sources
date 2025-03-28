MODULE Int2x2pd ; (* FÅr das PD-Modula der TU MÅnchen *)

FROM RealInOut IMPORT ReadReal, WriteReal ;
FROM InOut IMPORT Read, ReadInt, WriteString, WriteLn ;
FROM MathLib0 IMPORT real ;

VAR a, b, integral : REAL ;
    h, x, sum3, sum2 : REAL ;
    k, N : INTEGER ;
    ch : CHAR ;
BEGIN
  WriteString("Dies ist ein Programm zur Berechnung von    ") ; WriteLn ;
  WriteString("Integralen nach der 3/8-Formel.             ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("NÑheres z.B. bei G.Engeln-MÅllges/F.Reutter:") ; WriteLn ; 
  WriteString("Formelsammlung zur Numerischen Mathematik   ") ; WriteLn ;
  WriteString("Mit C-Programmen, BI Wissenschaftsverlag,   ") ; WriteLn ;
  WriteString("Mannheim, 1987                              ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("Es wird die Funktion                        ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("x*x                                         ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("integriert. Bitte geben Sie die Interval-   ") ; WriteLn ;
  WriteString("grenzen und N/3, ein Drittel der            ") ; WriteLn ;
  WriteString("effektiven Stuetzpunkte ein:                ") ; WriteLn ;
  WriteString("[a,b] a:") ;
  ReadReal(a) ; WriteLn ;
  WriteString("[a,b] b:") ;
  ReadReal(b) ; WriteLn ;
  WriteString("N/3:") ;
  ReadInt(N) ;
  h := (b-a)/real(3*N) ;
  sum2 := 0.0 ;
  sum3 := 0.0 ;
  x := a ;

  FOR k := 1 TO N-1 DO
    x := x + h ;
    sum3 := sum3 + x*x ;
    x := x + h ;
    sum3 := sum3 + x*x ;
    x := x + h ;
    sum2 := sum2 + x*x ;
  END ;
  x := x + h ;
  sum3 := sum3 + x*x ;
  x := x + h ;
  sum3 := sum3 + x*x ;

  integral := 0.375 * h * (a*a + b*b + 3.0 * sum3 + 2.0 * sum2) ;
  
  WriteReal(integral, 12) ; WriteLn ;
  Read(ch) ;
END Int2x2pd.

 
  
  
  
  

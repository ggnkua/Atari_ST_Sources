MODULE Int2gralx2 ; (* FÅr TDI Modula V3.00a *)

FROM RealInOut IMPORT ReadLongReal, WriteLongReal ;
FROM InOut IMPORT Read, WriteString, WriteLn ;
FROM LongInOut IMPORT ReadLongInt ;
FROM LongMathLib0 IMPORT longreal ;

VAR a, b, integral : LONGREAL ;
    h, x, sum3, sum2 : LONGREAL ;
    c1, c2, c3 : LONGREAL ; (* daran bin ich nicht schuld ! *)
    N, k : LONGINT ;
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
  WriteString("x^2                                         ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("integriert. Bitte geben Sie die Interval-   ") ; WriteLn ;
  WriteString("grenzen und die N/3, ein Drittel der        ") ; WriteLn ;
  WriteString("effektiven StÅtzpunkte ein:                 ") ; WriteLn ;

  WriteString("[a,b] a:") ;
  ReadLongReal(a) ; WriteLn ;
  WriteString("[a,b] b:") ;
  ReadLongReal(b) ; WriteLn ;
  WriteString("N/3 :") ;
  ReadLongInt(N) ; WriteLn ;
  
  
  h := (b-a)/longreal(3*N) ;
  sum2 := 0.0 ;
  sum3 := 0.0 ;
  x := a ;

  FOR k := 1 TO N-1 DO
    x := x + h ;
    sum3 := sum3 + x * x ;
    x := x + h ;
    sum3 := sum3 + x * x ;
    x := x + h ;
    sum2 := sum2 + x * x ;
  END ;
  x := x + h ;
  sum3 := sum3 + x * x ;
  x := x + h ;
  sum3 := sum3 + x * x ;

  c1 := 0.375 ;
  c2 := 3.0 ;
  c3 := 2.0 ;
  integral := c1 * h * (a * a + b * b + c2 * sum3 + c3 * sum2) ;
  
  WriteLongReal(integral, 12) ; WriteLn ;
  Read(ch) ;
END Int2gralx2.

 
  
  
  
  

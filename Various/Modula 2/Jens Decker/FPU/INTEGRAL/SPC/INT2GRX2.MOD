MODULE Int2grx2 ; (* FÅr SPC Modula-2 V2.01 *)

FROM InOut IMPORT Read, ReadCard, ReadLongreal,
                  WriteLongreal, WriteString, WriteLn ;
FROM LMathLib IMPORT Init, sin, real ;

VAR a, b, integral : LONGREAL ;
    h, x, sum3, sum2 : LONGREAL ;
    N, k : CARDINAL ;
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
  ReadLongreal(a) ; WriteLn ;
  WriteString("[a,b] b:") ;
  ReadLongreal(b) ; WriteLn ;
  WriteString("N/3 :") ;
  ReadCard(N) ; WriteLn ;
  
  Init ; 
   
  h := (b-a)/real(3*N) ;
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

  integral := 0.375D * h * (a * a + b * b + 3.0D * sum3 + 2.0D * sum2) ;
  
  WriteLongreal(integral, 2, 12) ; WriteLn ;
  Read(ch) ;
END Int2grx2.

 
  
  
  
  

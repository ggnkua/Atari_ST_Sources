MODULE IntPd ; (* FÅr das PD-Modula der TU MÅnchen *)

FROM SYSTEM IMPORT ADR, INLINE, SETREG, REG ;
FROM RealInOut IMPORT ReadReal, WriteReal ;
FROM InOut IMPORT Read, ReadInt, WriteInt, WriteString, WriteLn ;

VAR a, b, integral : REAL ;
    N, k, wdhl : INTEGER ;
    ch : CHAR ;
    fpustatus : INTEGER ;
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
  WriteString("sin(x)/x                                    ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("integriert. Bitte geben Sie die Interval-   ") ; WriteLn ;
  WriteString("grenzen und die N/3, ein Drittel der        ") ; WriteLn ;
  WriteString("effektiven StÅtzpunkte ein:                 ") ; WriteLn ;
  WriteString("[a,b] a:") ;
  ReadReal(a) ; WriteLn ;
  WriteString("[a,b] b:") ;
  ReadReal(b) ; WriteLn ;
  WriteString("Die Berechnung lÑuft zur Zeitnahme 10 mal   ") ; WriteLn ;
  WriteString("N/3 :") ;
  ReadInt(N) ; WriteLn ;
  Freset ;
  
  FOR wdhl := 1 TO 10 DO
    FmoveS(a, fp6) ; (* a nach fp6 *) (* NUR EINFACH GENAU !!! *)
    FmoveS(b, fp7) ; (* b nach fp7 *)
  
    FmoveW(N, fp4) ; (* NUR WORD, NICHT LONGWORD WEGEN PD-MODULA !!! *)
    FmulB(3, fp4) ;
    Fmove(fp7, fp5) ;
    Fsub(fp6, fp5) ;
    FdivL(fp4, fp5) ; (* h := b-a/3N nach fp5 *)
  
    Fmovecr(15, fp4) ; (* dreifach gewichtete Summen in fp4 auf 0.0 *)
    Fmovecr(15, fp3) ; (* doppelt gewichtete Summen in fp3 auf 0.0 *)
  
    Fmove(fp6, fp1) ; (* in fp1 soll immer x an f(x) Åbergeben werden *) 
    
    FOR k := 1 TO N-1 DO
      Fadd(fp5, fp1) ; (* h zu a addieren *)    
      Fsin(fp1, fp0) ;
      Fdiv(fp1, fp0) ; (* f(x) = sin(x)/x *)
      Fadd(fp0, fp4) ; (* f(a+(3k-2)h) *)
   
      Fadd(fp5, fp1) ; (* h zu a addieren *)
      Fsin(fp1, fp0) ;
      Fdiv(fp1, fp0) ; (* f(x) = sin(x)/x *)
      Fadd(fp0, fp4) ; (* f(a+(3k-1)h) *)
  
      Fadd(fp5, fp1) ; (* h zu a addieren *)
      Fsin(fp1, fp0) ; 
      Fdiv(fp1, fp0) ; (* f(x) = sin(x)/x *)
      Fadd(fp0, fp3) ; (* f(a+3kh) *)
    END ;
    Fadd(fp5, fp1) ; (* h zu a addieren *)    
    Fsin(fp1, fp0) ;
    Fdiv(fp1, fp0) ; (* f(x) = sin(x)/x *)
    Fadd(fp0, fp4) ; (* f(a+(3k-2)h) *)
   
    Fadd(fp5, fp1) ; (* h zu a addieren *)
    Fsin(fp1, fp0) ;
    Fdiv(fp1, fp0) ; (* f(x) = sin(x)/x *)
    Fadd(fp0, fp4) ; (* f(a+(3k-1)h) *)
  
    FmulB(2, fp3) ; (* Summe zweifach gewichten *) 
    FmulB(3, fp4) ; (* Summe dreifach gewichten *)
    Fadd(fp3, fp4) ; (* Summen addieren *)
    Fmove(fp7, fp1) ;
    Fsin(fp1, fp0) ;
    Fdiv(fp1, fp0) ;
    Fadd(fp0, fp4) ; (* f(b) zur Summe addieren *)
    Fmove(fp6, fp1) ;
    Fsin(fp1, fp0) ;
    Fdiv(fp1, fp0) ;
    Fadd(fp0, fp4) ; (* f(a) zur Summe addieren *)
    Fmul(fp5, fp4) ; 
    FmulD(0.375, fp4) ; (* Integral = 3h/8 * Summe *)
  
    FmoveS(fp4, integral) ; (* NUR EINFACH GENAU WEGEN PD-MODULA !!! *)
  
    Fstatus ;
  END ;   
  WriteReal(integral, 12) ; WriteLn ;
  WriteString("fpustatus: ") ; WriteInt(fpustatus, 6) ; WriteLn ;
  Read(ch) ;
END IntPd.

 
  
  
  
  


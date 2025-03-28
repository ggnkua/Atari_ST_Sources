MODULE Integral ; (* FÅr TDI Modula V3.00a *)

FROM SYSTEM IMPORT SETREG, REGISTER, CODE, ADR ;
FROM RealInOut IMPORT ReadLongReal, WriteLongReal ;
FROM InOut IMPORT Read, WriteInt, WriteString, WriteLn ;
FROM LongInOut IMPORT ReadLongInt ;

VAR a, b, integral : LONGREAL ;
    N, k : LONGINT ;
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
  ReadLongReal(a) ; WriteLn ;
  WriteString("[a,b] b:") ;
  ReadLongReal(b) ; WriteLn ;
  WriteString("N/3 :") ;
  ReadLongInt(N) ; WriteLn ;
  
  (*Freset ;*)
  CODE(04278H,0FA42H);
  
  
  (*FmoveD(a, fp6) ;*)
  SETREG(8,ADR(a));
  CODE(031FCH,05700H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(021D8H,0FA50H,021D0H,0FA50H);
  CODE(04A38H,0FA41H);
  (* a nach fp6 *)
  (*FmoveD(b, fp7) ;*)
  SETREG(8,ADR(b));
  CODE(031FCH,05780H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(021D8H,0FA50H,021D0H,0FA50H);
  CODE(04A38H,0FA41H);
  (* b nach fp7 *)

  (*FmoveL(N, fp4) ;*)
  SETREG(0,N);
  CODE(031FCH,04200H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(021C0H,0FA50H);
  CODE(04A38H,0FA41H);
  
  (*FmulB(3, fp4) ;*)
  CODE(031FCH,05A23H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(011FCH,00003H,0FA50H);
  CODE(04A38H,0FA41H);
  
  (*Fmove(fp7, fp5) ;*)
  CODE(031FCH,01E80H,0FA4AH);
  CODE(04A38H,0FA41H);
  
  (*Fsub(fp6, fp5) ;*)
  CODE(031FCH,01AA8H,0FA4AH);
  CODE(04A38H,0FA41H);
  
  (*FdivL(fp4, fp5) ;*)
  CODE(031FCH,012A0H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
  (* h := b-a/3N nach fp5 *)

  (*Fmovecr(15, fp4) ;*)
  CODE(031FCH,05E0FH,0FA4AH);
  CODE(04A38H,0FA41H);
  (* dreifach gewichtete Summen in fp4 auf 0.0 *)
  (*Fmovecr(15, fp3) ;*)
  CODE(031FCH,05D8FH,0FA4AH);
  CODE(04A38H,0FA41H);
  (* doppelt gewichtete Summen in fp3 auf 0.0 *)

  (*Fmove(fp6, fp1) ;*)
  CODE(031FCH,01880H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* in fp1 soll immer x an f(x) Åbergeben werden *) 
  
  FOR k := 1 TO N-1 DO
    (*Fadd(fp5, fp1) ;*)
    CODE(031FCH,014A2H,0FA4AH);
    CODE(04A38H,0FA41H);
    (* h zu a addieren *)    
    (*Fsin(fp1, fp0) ;*)
    CODE(031FCH,0040EH,0FA4AH);
    CODE(041F8H,0FA41H,04A10H,067FCH);
    
    (*Fdiv(fp1, fp0) ;*)
    CODE(031FCH,00420H,0FA4AH);
    CODE(04A38H,0FA41H);
    CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
    (* f(x) = sin(x)/x *)
    (*Fadd(fp0, fp4) ;*)
    CODE(031FCH,00222H,0FA4AH);
    CODE(04A38H,0FA41H);
    (* f(a+(3k-2)h) *)
 
    (*Fadd(fp5, fp1) ;*)
    CODE(031FCH,014A2H,0FA4AH);
    CODE(04A38H,0FA41H);
    (* h zu a addieren *)
    (*Fsin(fp1, fp0) ;*)
    CODE(031FCH,0040EH,0FA4AH);
    CODE(041F8H,0FA41H,04A10H,067FCH);
    
    (*Fdiv(fp1, fp0) ;*)
    CODE(031FCH,00420H,0FA4AH);
    CODE(04A38H,0FA41H);
    CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
    (* f(x) = sin(x)/x *)
    (*Fadd(fp0, fp4) ;*)
    CODE(031FCH,00222H,0FA4AH);
    CODE(04A38H,0FA41H);
    (* f(a+(3k-1)h) *)

    (*Fadd(fp5, fp1) ;*)
    CODE(031FCH,014A2H,0FA4AH);
    CODE(04A38H,0FA41H);
    (* h zu a addieren *)
    (*Fsin(fp1, fp0) ;*)
    CODE(031FCH,0040EH,0FA4AH);
    CODE(041F8H,0FA41H,04A10H,067FCH);
    
    (*Fdiv(fp1, fp0) ;*)
    CODE(031FCH,00420H,0FA4AH);
    CODE(04A38H,0FA41H);
    CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
    (* f(x) = sin(x)/x *)
    (*Fadd(fp0, fp3) ;*)
    CODE(031FCH,001A2H,0FA4AH);
    CODE(04A38H,0FA41H);
    (* f(a+3kh) *)
  END ;
  (*Fadd(fp5, fp1) ;*)
  CODE(031FCH,014A2H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* h zu a addieren *)    
  (*Fsin(fp1, fp0) ;*)
  CODE(031FCH,0040EH,0FA4AH);
  CODE(041F8H,0FA41H,04A10H,067FCH);
  
  (*Fdiv(fp1, fp0) ;*)
  CODE(031FCH,00420H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
  (* f(x) = sin(x)/x *)
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH,00222H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* f(a+(3k-2)h) *)
 
  (*Fadd(fp5, fp1) ;*)
  CODE(031FCH,014A2H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* h zu a addieren *)
  (*Fsin(fp1, fp0) ;*)
  CODE(031FCH,0040EH,0FA4AH);
  CODE(041F8H,0FA41H,04A10H,067FCH);
  
  (*Fdiv(fp1, fp0) ;*)
  CODE(031FCH,00420H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
  (* f(x) = sin(x)/x *)
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH,00222H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* f(a+(3k-1)h) *)

  (*FmulB(2, fp3) ;*)
  CODE(031FCH,059A3H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(011FCH,00002H,0FA50H);
  CODE(04A38H,0FA41H);
  (* Summe zweifach gewichten *) 
  (*FmulB(3, fp4) ;*)
  CODE(031FCH,05A23H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(011FCH,00003H,0FA50H);
  CODE(04A38H,0FA41H);
  (* Summe dreifach gewichten *)
  (*Fadd(fp3, fp4) ;*)
  CODE(031FCH,00E22H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* Summen addieren *)
  (*Fmove(fp7, fp1) ;*)
  CODE(031FCH,01C80H,0FA4AH);
  CODE(04A38H,0FA41H);
  
  (*Fsin(fp1, fp0) ;*)
  CODE(031FCH,0040EH,0FA4AH);
  CODE(041F8H,0FA41H,04A10H,067FCH);
  
  (*Fdiv(fp1, fp0) ;*)
  CODE(031FCH,00420H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
  
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH,00222H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* f(b) zur Summe addieren *)
  (*Fmove(fp6, fp1) ;*)
  CODE(031FCH,01880H,0FA4AH);
  CODE(04A38H,0FA41H);
  
  (*Fsin(fp1, fp0) ;*)
  CODE(031FCH,0040EH,0FA4AH);
  CODE(041F8H,0FA41H,04A10H,067FCH);
  
  (*Fdiv(fp1, fp0) ;*)
  CODE(031FCH,00420H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
  
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH,00222H,0FA4AH);
  CODE(04A38H,0FA41H);
  (* f(a) zur Summe addieren *)
  (*Fmul(fp5, fp4) ;*)
  CODE(031FCH,01623H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(04E71H);
  
  (*FmulD(0.375, fp4) ;*)
  CODE(031FCH,05623H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(021FCH,03FD8H,00000H,0FA50H);
  CODE(021FCH,00000H,00000H,0FA50H);
  CODE(04A38H,0FA41H);
  (* Integral = 3h/8 * Summe *)

  (*FmoveD(fp4, integral) ;*)
  SETREG(8,ADR(integral));
  CODE(031FCH,07600H,0FA4AH);
  CODE(04A38H,0FA41H);
  CODE(04E71H,04E71H);
  CODE(04A38H,0FA41H);
  CODE(020F8H,0FA50H,020B8H,0FA50H);
  CODE(04A38H,0FA41H);
  

  (*Fstatus ;*)
  SETREG(8,ADR(fpustatus));
  CODE(030B8H,0FA40H);
  
  
  WriteLongReal(integral, 12) ; WriteLn ;
  WriteString("fpustatus: ") ; WriteInt(fpustatus, 6) ; WriteLn ;
  Read(ch) ;
END Integral.

 
  
  
  
  

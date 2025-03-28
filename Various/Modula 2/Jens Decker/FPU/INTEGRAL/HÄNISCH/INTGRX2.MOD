MODULE Integralx2 ;  (* FÅr HÑnisch Modula V3.105 *)

FROM SYSTEM IMPORT LOAD, STORE, CODE, ADR ;
FROM RealInOut IMPORT ReadReal, WriteReal ;
FROM InOut IMPORT Read, ReadLongCard, WriteInt, WriteString, WriteLn ;

VAR a, b, integral : LONGREAL ;
    N, k : LONGCARD ;
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
  WriteString("x^2                                         ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("integriert. Bitte geben Sie die Interval-   ") ; WriteLn ;
  WriteString("grenzen und die N/3, ein Drittel der        ") ; WriteLn ;
  WriteString("effektiven StÅtzpunkte ein:                 ") ; WriteLn ;

  WriteString("[a,b] a:") ;
  ReadReal(a) ; WriteLn ;
  WriteString("[a,b] b:") ;
  ReadReal(b) ; WriteLn ;
  WriteString("N/3 :") ;
  ReadLongCard(N) ; WriteLn ;
  
  (*Freset ;*)
  CODE(04278H);CODE(0FA42H);
  
  
  (*FmoveD(a, fp6) ;*)
  LOAD(ADR(a),8);
  CODE(031FCH);CODE(05700H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(021D8H);CODE(0FA50H);CODE(021D0H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  (* a nach fp6 *)
  (*FmoveD(b, fp7) ;*)
  LOAD(ADR(b),8);
  CODE(031FCH);CODE(05780H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(021D8H);CODE(0FA50H);CODE(021D0H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  (* b nach fp7 *)

  (*FmoveL(N, fp4) ;*)
  LOAD(N, 0);
  CODE(031FCH);CODE(04200H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(021C0H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  
  (*FmulB(3, fp4) ;*)
  CODE(031FCH);CODE(05A23H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(011FCH);CODE(00003H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fmove(fp7, fp5) ;*)
  CODE(031FCH);CODE(01E80H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fsub(fp6, fp5) ;*)
  CODE(031FCH);CODE(01AA8H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*FdivL(fp4, fp5) ;*)
  CODE(031FCH);CODE(012A0H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(04E71H);CODE(04E71H);CODE(04E71H);CODE(04E71H);CODE(04E71H);CODE(04E71H);
  (* h := b-a/3N nach fp5 *)

  (*Fmovecr(15, fp4) ;*)
  CODE(031FCH);CODE(05E0FH);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* dreifach gewichtete Summen in fp4 auf 0.0 *)
  (*Fmovecr(15, fp3) ;*)
  CODE(031FCH);CODE(05D8FH);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* doppelt gewichtete Summen in fp3 auf 0.0 *)

  (*Fmove(fp6, fp1) ;*)
  CODE(031FCH);CODE(01880H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* in fp1 soll immer x an f(x) Åbergeben werden *) 
  
  FOR k := 1 TO N-1 DO
    (*Fadd(fp5, fp1) ;*)
    CODE(031FCH);CODE(014A2H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    (* h zu a addieren *)    
    (*Fmove(fp1, fp0) ;*)
    CODE(031FCH);CODE(00400H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    
    (*Fmul(fp0, fp0) ;*)
    CODE(031FCH);CODE(00023H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    CODE(04E71H);
    (* f(x) = x^2 *)
    (*Fadd(fp0, fp4) ;*)
    CODE(031FCH);CODE(00222H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    (* f(a+(3k-2)h) *)
 
    (*Fadd(fp5, fp1) ;*)
    CODE(031FCH);CODE(014A2H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    (* h zu a addieren *)
    (*Fmove(fp1, fp0) ;*)
    CODE(031FCH);CODE(00400H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    
    (*Fmul(fp0, fp0) ;*)
    CODE(031FCH);CODE(00023H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    CODE(04E71H);
    (* f(x) = x^2 *)
    (*Fadd(fp0, fp4) ;*)
    CODE(031FCH);CODE(00222H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    (* f(a+(3k-1)h) *)

    (*Fadd(fp5, fp1) ;*)
    CODE(031FCH);CODE(014A2H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    (* h zu a addieren *)
    (*Fmove(fp1, fp0) ;*)
    CODE(031FCH);CODE(00400H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    
    (*Fmul(fp0, fp0) ;*)
    CODE(031FCH);CODE(00023H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    CODE(04E71H);
    (* f(x) = x^2 *)
    (*Fadd(fp0, fp3) ;*)
    CODE(031FCH);CODE(001A2H);CODE(0FA4AH);
    CODE(04A38H);CODE(0FA41H);
    (* f(a+3kh) *)
  END ;
  (*Fadd(fp5, fp1) ;*)
  CODE(031FCH);CODE(014A2H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* h zu a addieren *)    
  (*Fmove(fp1, fp0) ;*)
  CODE(031FCH);CODE(00400H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fmul(fp0, fp0) ;*)
  CODE(031FCH);CODE(00023H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(04E71H);
  (* f(x) = x^2 *)
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH);CODE(00222H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* f(a+(3k-2)h) *)
 
  (*Fadd(fp5, fp1) ;*)
  CODE(031FCH);CODE(014A2H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* h zu a addieren *)
  (*Fmove(fp1, fp0) ;*)
  CODE(031FCH);CODE(00400H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fmul(fp0, fp0) ;*)
  CODE(031FCH);CODE(00023H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(04E71H);
  (* f(x) = x^2 *)
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH);CODE(00222H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* f(a+(3k-1)h) *)

  (*FmulB(2, fp3) ;*)
  CODE(031FCH);CODE(059A3H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(011FCH);CODE(00002H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  (* Summe zweifach gewichten *) 
  (*FmulB(3, fp4) ;*)
  CODE(031FCH);CODE(05A23H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(011FCH);CODE(00003H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  (* Summe dreifach gewichten *)
  (*Fadd(fp3, fp4) ;*)
  CODE(031FCH);CODE(00E22H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* Summen addieren *)
  (*Fmove(fp7, fp1) ;*)
  CODE(031FCH);CODE(01C80H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fmove(fp1, fp0) ;*)
  CODE(031FCH);CODE(00400H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fmul(fp0, fp0) ;*)
  CODE(031FCH);CODE(00023H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(04E71H);
  (* f(x) = x^2 *)
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH);CODE(00222H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* f(b) zur Summe addieren *)
  (*Fmove(fp6, fp1) ;*)
  CODE(031FCH);CODE(01880H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fmove(fp1, fp0) ;*)
  CODE(031FCH);CODE(00400H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  
  (*Fmul(fp0, fp0) ;*)
  CODE(031FCH);CODE(00023H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(04E71H);
  (* f(x) = x^2 *)
  (*Fadd(fp0, fp4) ;*)
  CODE(031FCH);CODE(00222H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  (* f(a) zur Summe addieren *)
  (*Fmul(fp5, fp4) ;*)
  CODE(031FCH);CODE(01623H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(04E71H);
  
  (*FmulD(0.375, fp4) ;*)
  CODE(031FCH);CODE(05623H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(021FCH);CODE(03FD8H);CODE(00000H);CODE(0FA50H);
  CODE(021FCH);CODE(00000H);CODE(00000H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  (* Integral = 3h/8 * Summe *)

  (*FmoveD(fp4, integral) ;*)
  LOAD(ADR(integral),8);
  CODE(031FCH);CODE(07600H);CODE(0FA4AH);
  CODE(04A38H);CODE(0FA41H);
  CODE(04E71H);CODE(04E71H);
  CODE(04A38H);CODE(0FA41H);
  CODE(020F8H);CODE(0FA50H);CODE(020B8H);CODE(0FA50H);
  CODE(04A38H);CODE(0FA41H);
  

  (*Fstatus ;*)
  LOAD(ADR(fpustatus),8);
  CODE(030B8H);CODE(0FA40H);
  
  
  WriteReal(integral, 2, 12) ; WriteLn ;
  WriteString("fpustatus: ") ; WriteInt(fpustatus, 6) ; WriteLn ;
  Read(ch) ;
END Integralx2.

 
  
  
  
  

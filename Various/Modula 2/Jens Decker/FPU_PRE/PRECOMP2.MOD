
MODULE Codierung ;
  IMPORT fpuop, tfpuop, Operationstyp, Extensiontyp, Uebergabetyp, 
         Vergleichstyp, Compileridentifizieren, Compiler, Compilertyp,
         WriteString, WriteLn,
         Klammerauf, Klammerzu,
         InOut, ADR, ADDRESS, 
         FehlerMeldung, StrToVal, ValToStr, StrToReal,
         Pos, Length, Copy, Concat ;
  EXPORT Codegenerierung ;

  PROCEDURE Codegenerierung() : BOOLEAN ;
  VAR AnfangZeile,
      FlOp,
      EndeZeile   : ARRAY [0..511] OF CHAR ;
      Einrueckung, i : SHORTCARD ;
      Einrueckstring : ARRAY [0..80] OF CHAR ; (* sollte wohl reichen *)
      CodeWerte : ARRAY [1..6] OF SHORTCARD ;

    PROCEDURE TransferZeile ;
    VAR Laenge : SHORTCARD ;
    BEGIN
      Copy(AnfangZeile, fpuop.Zeile, 0, fpuop.ZeigerAnfang) ;
      Einrueckung := fpuop.ZeigerAnfang ;
      Concat(AnfangZeile, Klammerauf) ;
      Copy(FlOp, fpuop.Zeile, fpuop.ZeigerAnfang, fpuop.Zeiger - fpuop.ZeigerAnfang) ;
      Concat(AnfangZeile, FlOp) ;
      Concat(AnfangZeile, Klammerzu) ;
      WriteString(AnfangZeile) ; WriteLn ;
      Laenge := Length(fpuop.Zeile) ;
      WHILE fpuop.Zeile[fpuop.Zeiger] = " " DO
        INC(fpuop.Zeiger) ;
      END ;
      Copy(EndeZeile, fpuop.Zeile, fpuop.Zeiger, Laenge - fpuop.Zeiger) ; 
      fpuop.Zeile := "" ;
      FOR i := 1 TO Einrueckung DO
        Concat(fpuop.Zeile, " ") ;
      END ;
      Copy(Einrueckstring, fpuop.Zeile, 0, Einrueckung) ;
    END TransferZeile ;

    PROCEDURE Make1Code(w1 : SHORTCARD) ;
    BEGIN
      CodeWerte[1] := w1 ;
      MakeCode(1) ;
    END Make1Code;
    PROCEDURE Make2Code(w1, w2 : SHORTCARD) ;
    BEGIN
      CodeWerte[1] := w1 ; CodeWerte[2] := w2 ;
      MakeCode(2) ;
    END Make2Code;
    PROCEDURE Make3Code(w1, w2, w3 : SHORTCARD) ;
    BEGIN
      CodeWerte[1] := w1 ; CodeWerte[2] := w2 ; CodeWerte[3] := w3 ;
      MakeCode(3) ;
    END Make3Code;
    PROCEDURE Make4Code(w1, w2, w3, w4 : SHORTCARD) ;
    BEGIN
      CodeWerte[1] := w1 ; CodeWerte[2] := w2 ; CodeWerte[3] := w3 ;
      CodeWerte[4] := w4 ; 
      MakeCode(4) ;
    END Make4Code;
    PROCEDURE Make5Code(w1, w2, w3, w4, w5 : SHORTCARD) ;
    BEGIN
      CodeWerte[1] := w1 ; CodeWerte[2] := w2 ; CodeWerte[3] := w3 ;
      CodeWerte[4] := w4 ; CodeWerte[5] := w5 ;
      MakeCode(5) ;
    END Make5Code;
    PROCEDURE Make6Code(w1, w2, w3, w4, w5, w6 : SHORTCARD) ;
    BEGIN
      CodeWerte[1] := w1 ; CodeWerte[2] := w2 ; CodeWerte[3] := w3 ;
      CodeWerte[4] := w4 ; CodeWerte[5] := w5 ; CodeWerte[6] := w6 ;
      MakeCode(6) ;
    END Make6Code;

    PROCEDURE MakeCode(n : SHORTCARD) ; 
    VAR HexCode : ARRAY [0..4] OF CHAR ;
        IntWert : INTEGER ;
        i       : SHORTCARD ;
        error   : BOOLEAN ;
    BEGIN
      Copy(fpuop.Zeile, Einrueckstring, 0, Einrueckung) ;
      CASE Compiler OF
        HaenischM, Megamax :
          FOR i := 1 TO n DO
            Concat(fpuop.Zeile, "CODE(0") ;
            IntWert := CodeWerte[i] ;
            ValToStr(IntWert, FALSE, HexCode, 16, 4, "0", error) ;
            Concat(fpuop.Zeile, HexCode) ;
            Concat(fpuop.Zeile, "H);") ;
          END |
        PDM, TDI, SPC :
          IF Compiler = TDI
            THEN Concat(fpuop.Zeile, "CODE(") ;
            ELSE Concat(fpuop.Zeile, "INLINE(") ;
          END ;
          FOR i := 1 TO n DO
            IF i # 1
              THEN Concat(fpuop.Zeile, ",") ;
            END ;
            IntWert := CodeWerte[i] ;
            ValToStr(IntWert, FALSE, HexCode, 16, 4, "0", error) ;
            Concat(fpuop.Zeile, "0") ;
            Concat(fpuop.Zeile, HexCode) ;
            Concat(fpuop.Zeile, "H") ;
          END ;
          Concat(fpuop.Zeile, ");") ;
      END ;
      WriteString(fpuop.Zeile) ; WriteLn ; INC(fpuop.Zeilennummer) ;
    END MakeCode ;

    PROCEDURE LoadAdr(var : ARRAY OF CHAR) ;
    BEGIN
      Copy(fpuop.Zeile, Einrueckstring, 0, Einrueckung) ;
      CASE Compiler OF
        HaenischM, Megamax :
          Concat(fpuop.Zeile, "LOAD(ADR(") ;
          Concat(fpuop.Zeile, var) ;
          Concat(fpuop.Zeile, "),8);") | (* 8 fÅr a0 *)
        PDM, TDI, SPC :
          Concat(fpuop.Zeile, "SETREG(8,ADR(") ; (* 8 fÅr a0 *)
          Concat(fpuop.Zeile, var) ;
          Concat(fpuop.Zeile, "));") |
      END ;
      WriteString(fpuop.Zeile) ; WriteLn ; INC(fpuop.Zeilennummer) ;
    END LoadAdr ;

    PROCEDURE LoadData ;
    BEGIN
      Copy(fpuop.Zeile, Einrueckstring, 0, Einrueckung) ;
      CASE Compiler OF
        HaenischM, Megamax :
          Concat(fpuop.Zeile, "LOAD(") ;
          Concat(fpuop.Zeile, fpuop.VarNum) ;
          Concat(fpuop.Zeile, ", 0);") | (* 0 fÅr d0 *)
        PDM, TDI, SPC :
          Concat(fpuop.Zeile, "SETREG(0,") ; (* 0 fÅr d0 *)
          Concat(fpuop.Zeile, fpuop.VarNum) ;
          Concat(fpuop.Zeile, ");") ;
      END ; 
      WriteString(fpuop.Zeile) ; WriteLn ; INC(fpuop.Zeilennummer) ;
    END LoadData ;

(*    PROCEDURE StoreData ;
    BEGIN
      Copy(fpuop.Zeile, Einrueckstring, 0, Einrueckung) ;
      CASE Compiler OF
        HaenischM, Megamax :
          Concat(fpuop.Zeile, "STORE(0,") ;
          Concat(fpuop.Zeile, fpuop.VarNum) ;
          Concat(fpuop.Zeile, ");") |
        PDM, SPC :
          Concat(fpuop.Zeile, fpuop.VarNum) ;
          Concat(fpuop.Zeile, ":=REG(0);") |
        TDI : 
          Concat(fpuop.Zeile, fpuop.VarNum) ;
          Concat(fpuop.Zeile, ":=REGISTER(0);") ;
      END ;    
      WriteString(fpuop.Zeile) ; WriteLn ; INC(fpuop.Zeilennummer) ;
    END StoreData ;
*)
    PROCEDURE Nops(AnzNops : SHORTCARD) ;
    BEGIN
      IF AnzNops <= 6
        THEN FOR i := 1 TO AnzNops DO
               CodeWerte[i] := 04E71H ;
             END ;
             IF AnzNops > 0
               THEN MakeCode(AnzNops) ;
             END ;
        ELSE Make4Code(041F8H, 0FA41H, 04A10H, 067FCH) ;
             (* lea $FA41.w, a0 ; tst.b (a0) ; beq.s zu tst.b (a0) *)    
      END ;
    END Nops ;

    PROCEDURE ResponseTest ;
    BEGIN
      Make2Code(04A38H, 0FA41H) ; (* tst.b $fa41.w *)
    END ResponseTest ;

    PROCEDURE RechenCode() : SHORTCARD ;
    VAR Code : SHORTCARD ;
        romoffsetl  : INTEGER ;
        romoffsets  : SHORTCARD ;
        sign, error :BOOLEAN ;
    BEGIN
      IF fpuop.Argument2 < Reg0
        THEN Code := 3 * 8192 ;
      ELSIF fpuop.Argument1 < Reg0
        THEN Code := 2 * 8192 ;
        ELSE Code := 0 * 8192 ;
      END ;
      IF NOT( (fpuop.Operation = movecr) OR (fpuop.Operation = sincos) )
        THEN CASE fpuop.Operation OF
               move   : Code := Code + 0 |
               int    : Code := Code + 1 |
               sinh   : Code := Code + 2 |
               intrz  : Code := Code + 3 |
               sqrt   : Code := Code + 4 |
               lognp1 : Code := Code + 6 |
               etoxm1 : Code := Code + 8 |
               tanh   : Code := Code + 9 |
               atan   : Code := Code + 10 |
               asin   : Code := Code + 12 |
               atanh  : Code := Code + 13 |
               sin    : Code := Code + 14 |
               tan    : Code := Code + 15 |
               etox   : Code := Code + 16 |
               twotox : Code := Code + 17 |
               tentox : Code := Code + 18 |
               logn   : Code := Code + 20 |
               log10  : Code := Code + 21 |
               log2   : Code := Code + 22 |
               abs    : Code := Code + 24 |
               cosh   : Code := Code + 25 |
               neg    : Code := Code + 26 |
               acos   : Code := Code + 28 |
               cos    : Code := Code + 29 |
               getexp : Code := Code + 30 |
               getman : Code := Code + 31 |
               div    : Code := Code + 32 |
               mod    : Code := Code + 33 |
               add    : Code := Code + 34 |
               mul    : Code := Code + 35 |
               sgldiv : Code := Code + 36 |
               rem    : Code := Code + 37 |
               scale  : Code := Code + 38 |
               sglmul : Code := Code + 39 |
               sub    : Code := Code + 40 |
               cmp    : Code := Code + 56 |
               tst    : Code := Code + 58 ;
             END ;  
      ELSIF fpuop.Operation = sincos
        THEN Code := Code + 6 * 8 + ORD(fpuop.Argument3) - ORD(Reg0) ;
        ELSE StrToVal(fpuop.VarNum, romoffsetl, sign, 10, error) ; 
             romoffsets := romoffsetl ;
             Code := Code + romoffsets ;
      END ;
      IF NOT ( ((fpuop.Operation = move) AND (fpuop.Argument2 < Reg0)) OR
               (fpuop.Operation = movecr) )
        THEN IF fpuop.Argument1 = Var
               THEN Code := Code + ORD(fpuop.Extension) * 1024 ;
             ELSIF fpuop.Argument1 = Num
               THEN Code := Code + ORD(fpuop.Extension) * 1024 ;
               ELSE Code := Code + ( ORD(fpuop.Argument1) - ORD(Reg0) ) * 1024 ;
             END ;
             Code := Code + ( ORD(fpuop.Argument2) - ORD(Reg0) ) * 128 ;
      ELSIF fpuop.Operation = movecr
        THEN Code := Code + 7 * 1024 ;
             Code := Code + ( ORD(fpuop.Argument2) - ORD(Reg0) ) * 128 ;
        ELSE Code := Code + ORD(fpuop.Extension) * 1024 ;
             Code := Code + ( ORD(fpuop.Argument1) - ORD(Reg0) ) * 128 ;
      END ;
      RETURN Code ;
    END RechenCode;

    PROCEDURE CmpTst ;
    BEGIN
      IF fpuop.Argument1 >= Reg0
        THEN RegReg ;
        ELSE MemReg ;
      END ;
      LoadAdr(fpuop.Boolean) ;
      Make3Code(031FCH, ORD(fpuop.Argument4), 0FA4EH) ; 
        (* move.w #Condition,$ConditionReg *) 
      Make3Code(00C78H, 00801H, 0FA40H) ; (* cmp.w #0801, $ResponseReg *)
      Make3Code(057C0H, 04400H, 01080H) ; 
        (* seq.b d0 ; addq.b #1,d0 ; move.b d0,(a0) *)
    END CmpTst ;

    PROCEDURE RegReg;
    BEGIN
      Make3Code(031FCH, RechenCode(), 0FA4AH) ; (* move #Code, $CommandReg *)
      CASE fpuop.Operation OF
        abs, add, cmp, getexp, getman, int, intrz,
        move, movecr, neg, scale, sglmul, sub, tst : ResponseTest ;
                                                     Nops(0) |
        mod, mul, sgldiv : ResponseTest ;
                           Nops(1) |
        div, rem, sqrt : ResponseTest ;
                         Nops(6) |
        ELSE Nops(88) ;
      END ;
    END RegReg ;


    PROCEDURE MemReg ;
    VAR longint : LONGINT ;
        real : REAL ;
        longreal : LONGREAL ;
        shortcard : ARRAY [1..4] OF SHORTCARD ;
        adr : ADDRESS ;
        poishortcard : POINTER TO SHORTCARD ;
        error, signed : BOOLEAN ;
    BEGIN
      IF fpuop.Argument1 = Var
        THEN CASE fpuop.Extension OF
               B, W, D, E : LoadAdr(fpuop.VarNum) |
               L, S       : LoadData ;
             END ;
        ELSE CASE fpuop.Extension OF
               B, W : StrToVal(fpuop.VarNum, longint, signed, 10, error) ;
                      shortcard[1] := longint |
               L    : StrToVal(fpuop.VarNum, longint, signed, 10, error) ;
                      adr := ADR(longint) ;
                      poishortcard := adr ;
                      shortcard[1] := poishortcard^ ;
                      poishortcard := adr + 2 ;
                      shortcard[2] := poishortcard^ |
               S    : StrToReal(fpuop.VarNum, longreal, error) ;
                      real := longreal ;
                      adr := ADR(real) ;
                      poishortcard := adr ;
                      shortcard[1] := poishortcard^ ;
                      poishortcard := adr + 2 ;
                      shortcard[2] := poishortcard^ |
               D    : StrToReal(fpuop.VarNum, longreal, error) ;
                      adr := ADR(longreal) ;
                      FOR longint := 1 TO 4 DO
                        poishortcard := adr ;
                        shortcard[longint] := poishortcard^ ;
                        adr := adr + 2 ;
                      END |             
             END ;
      END ; 
      Make3Code(031FCH, RechenCode(), 0FA4AH) ; (* move.w #Code, $CommandReg *)
      ResponseTest ;
      IF fpuop.Argument1 = Var
        THEN CASE fpuop.Extension OF
               B : Make2Code(011D0H, 0FA50H) | (* move.b (a0), $Operand *)
               W : Make2Code(031D0H, 0FA50H) | (* move.w (a0), $Operand *)
               L, S : Make2Code(021C0H, 0FA50H) | (* move.l d0, $Operand *)
               D : Make4Code(021D8H, 0FA50H, 021D0H, 0FA50H) |
                   (* move.l (a0)+, $Operand ; move.l (a0), $Operand *)
               E : Make6Code(021D8H, 0FA50H, 021D8H, 0FA50H, 021D0H, 0FA50H) ;
                   (* 2 mal move.l (a0)+, $Operand ; move.l (a0), $Operand *)
             END ;
        ELSE CASE fpuop.Extension OF
               B : Make3Code(011FCH, shortcard[1], 0FA50H) |
                   (* move.b #$val, $Operand *)              
               W : Make3Code(031FCH, shortcard[1], 0FA50H) |
                   (* move.w #$val, $Operand *)
               L, S : Make4Code(021FCH, shortcard[1], shortcard[2], 0FA50H) | 
                      (* move.l #$val, $Operand *)
               D : Make4Code(021FCH, shortcard[1], shortcard[2], 0FA50H) ; 
                   (* move.l #$valh, $Operand *)
                   Make4Code(021FCH, shortcard[3], shortcard[4], 0FA50H) ; 
                   (* move.l #$vall, $Operand *)
             END ;
      END ;
      ResponseTest ;
      CASE fpuop.Operation OF
        abs, add, cmp, getexp, getman, int, intrz, mod, move,
        movecr, mul, neg, scale, sgldiv, sglmul, sub, tst : Nops(0) |
        div, rem, sqrt : Nops(4) ;
        ELSE Nops(88) ;
      END ;            
    END MemReg ;

    PROCEDURE RegMem ;
    BEGIN
      LoadAdr(fpuop.VarNum) ;
      Make3Code(031FCH, RechenCode(), 0FA4AH) ; (* move #Code,$Command *)
      ResponseTest ;
      CASE fpuop.Extension OF
        B, W, L : Nops(4) |
        S, D : Nops(2) |
        E : Nops(0) ;
      END ;
      ResponseTest ;
      CASE fpuop.Extension OF
        B : Make2Code(010B8H, 0FA50H) | (* move.b #$fa50, (a0) *)
        W : Make2Code(030B8H, 0FA50H) | (* move.w #$fa50, (a0) *)
        L, S : Make2Code(020B8H, 0FA50H) | (* move.l #$fa50, (a0) *)
        D : Make4Code(020F8H, 0FA50H, 020B8H, 0FA50H) | 
            (* move.l #$fa50, (a0)+ ; move.l #$fa50, (a0) *)
        E : Make6Code(020F8H, 0FA50H, 020F8H, 0FA50H, 020B8H, 0FA50H) ;
            (* 2 mal move.l #$fa50, (a0)+ ; move.l #$fa50, (a0) *)
      END ;
      ResponseTest ;
    END RegMem ;

  BEGIN
    TransferZeile ;
    IF fpuop.Operation = reset
      THEN Make2Code(04278H, 0FA42H); (* Coprozessor-Reset *)
    ELSIF fpuop.Operation = status
      THEN fpuop.Extension := L ; (* wichtig fÅr das Modula der TU MÅnchen *)
           LoadAdr("fpustatus") ;
           Make2Code(030B8H, 0FA40H); (* Status-Abfrage *)
    ELSIF fpuop.Operation = cmp 
      THEN CmpTst ;
    ELSIF fpuop.Operation = tst
      THEN fpuop.Argument2 := Reg0 ;
           CmpTst ;
    ELSIF ((fpuop.Argument1 >= Reg0) AND (fpuop.Argument2 >= Reg0)) OR 
          (fpuop.Operation = movecr)
      THEN RegReg ;
    ELSIF (fpuop.Argument1 < Reg0) AND (fpuop.Argument2 >= Reg0)
      THEN MemReg ;
      ELSE RegMem ;
    END ;
    Copy(fpuop.Zeile, Einrueckstring, 0, Einrueckung) ;
    INC(fpuop.Zeilennummer) ;
    Concat(fpuop.Zeile, EndeZeile) ;
    fpuop.Zeiger := Einrueckung ;
    fpuop.ZeigerAnfang := fpuop.Zeiger ;
  END Codegenerierung ;
END Codierung ;

PROCEDURE Compilieren ;
VAR Resultat1, Resultat2, Resultat3 : BOOLEAN ;
    ch       : CHAR ;
    Abschnitt: ARRAY [0..10] OF CHAR ;
BEGIN
  ParserInit ;
  ReadLine(fpuop.Zeile) ;
  IF RDone
    THEN INC(fpuop.Zeilennummer) ;
         fpuop.Zeiger := 0 ;
  END ;
  IF NOT Compileridentifizieren()
    THEN RETURN ;
  END ;
  REPEAT
    fpuop.Operation := noop ;
    fpuop.Argument1 := nouebg ;
    fpuop.Argument2 := nouebg ;
    fpuop.Argument3 := nouebg ;
    fpuop.Argument4 := novgl ;
    fpuop.VarNum := "" ;
    fpuop.Boolean := "" ;
    Resultat1 := Fsuchen() ;
    IF Resultat1 
      THEN Resultat2 := Operationidentifizieren() ;
           IF Resultat2 AND (fpuop.Operation # reset) AND 
              (fpuop.Operation # status) 
             THEN IF Extensionidentifizieren()
                    THEN IF SucheOperand1() 
                           THEN IF OperandenIdentifizieren()
                                  THEN IF Syntaxpruefung()
                                         THEN Resultat3 := Codegenerierung() ;
                                       END ;
                                END ;
                         END ;
                  END ;
             ELSE IF (fpuop.Operation = reset) OR (fpuop.Operation = status) 
                    THEN SucheEnde ;
                         Resultat3 := Codegenerierung() ;
                  END ;
           END ;
    END ;
(*    IF Resultat1 AND Resultat2 AND RDone 
      THEN InOut.WriteString(fpuop.Zeile) ; InOut.WriteLn ;
           InOut.WriteString("Operation: ") ; InOut.WriteString(Operationen[ORD(fpuop.Operation)]) ; InOut.WriteLn ;
           InOut.WriteString("Extension: ") ; InOut.WriteString(Extensions[ORD(fpuop.Extension)]) ; InOut.WriteLn ;
           InOut.WriteString("Argument1: ") ; InOut.WriteString(Operanden[ORD(fpuop.Argument1)]) ; InOut.WriteLn ;
           InOut.WriteString("Argument2: ") ; InOut.WriteString(Operanden[ORD(fpuop.Argument2)]) ; InOut.WriteLn ;
           InOut.WriteString("Argument3: ") ; InOut.WriteString(Operanden[ORD(fpuop.Argument3)]) ; InOut.WriteLn ;
           InOut.WriteString("Argument4: ") ; InOut.WriteString(Vergleiche[ORD(fpuop.Argument4)]) ; InOut.WriteLn ;
           InOut.WriteString("VarNum   : ") ; InOut.WriteString(fpuop.VarNum) ; InOut.WriteLn ;
           InOut.WriteString("Boolean  : ") ; InOut.WriteString(fpuop.Boolean) ; InOut.WriteLn ;
           InOut.WriteLn ;
           InOut.Read(ch) ;
      END ; *)
  UNTIL (NOT (Resultat1 AND RDone)) ;
END Compilieren ;

BEGIN
  ApID := ApplInit() ;
  IF ApID > -1 
    THEN Intro ;
         IF OeffneStreams() 
           THEN Compilieren ; 
              (*  InOut.WriteString(CompIDs[Compiler]) ; InOut.WriteLn ; *)
                SchliesseStreams ;
         END ;
         ApplExit ;
  END ;
END FPUPreprozessor.


MODULE FPUPreprozessor ;  (* FÅr HÑnisch Modula V3.105 *)

(* Projekt       : FPUPreprozessor                                         *)
(* Teil          : Hauptmodul                                              *)
(* Weitere Files : FPU_PREP.TXT Vorarbeiten fÅr den FPUPreprozessor        *)
(*                 FPU_MAKE.INF MakeFile fÅr HÑnisch Modula                *)
(* Beginn        : 07.07.89  long long ago...                              *)
(* akt. Datum    : 02.05.90                                                *)
(* akt. Arbeiten : Anpassung an das Megamax Modula                         *)
(* by Jens Decker         *)
(* Copyright: MAXON Computer GmbH  *)

FROM AESApplications    IMPORT ApplInit, ApplExit ;
FROM AESForms           IMPORT FormAlert ;
FROM BufInOut           IMPORT FilterBase, NumFilter, RDone, ReadLine, WriteLn,
                               WriteString ;
FROM Conversions        IMPORT StrToVal, ValToStr ;
FROM DOSbase            IMPORT tFilename, tPathname ;
FROM Directories        IMPORT Delete, Rename ;
FROM FSelOpen           IMPORT FSelOpen, DummyOpenErr ;
FROM Paths              IMPORT GetCurrentPath, GetPurePath, GetFile ;
FROM GEMAESBase         IMPORT tExitButton, tFSelReturn ;
FROM Streams            IMPORT Close, Open, tStreamHandle, tStreamMode ;
FROM String             IMPORT Concat, Copy, Length, Pos ;
FROM SYSTEM             IMPORT ADR, ADDRESS ;
FROM RealConversions    IMPORT StrToReal ;
IMPORT InOut ;

TYPE Compilertyp = (HaenischM, PDM, TDI, SPC, Megamax, noComp) ;
     Operationstyp = (move, movecr, int, sinh, intrz, sqrt, lognp1, etoxm1,
                      tanh, atan, asin, atanh, sin, tan, etox, twotox,
                      tentox, logn, log10, log2, abs, cosh, neg, acos,
                      cos, getexp, getman, div, mod, add, mul, sgldiv,
                      rem, reset, status, scale, sglmul, sub, sincos, cmp,
                      tst, noop) ;
     Extensiontyp  = (L, S, E, P, W, D, B, Space, Klammer, noext) ; 
                     (* P wird nicht unterstÅtzt *)
     Uebergabetyp  = (Num, Var, Reg0, Reg1, Reg2, Reg3, Reg4, Reg5,
                      Reg6, Reg7, nouebg) ; (* Eventuell noch Konstanten! *)
     Vergleichstyp = (F, EQ, OGT, OGE, OLT, OLE, OGL, ORd, UN, UEQ, UGT,
                      UGE, ULT, ULE, NE, T, SF, SEQ, GT, GE, LT, LE, GL,
                      GLE, NGLE, NGL, NLE, NLT, NGE, NGT, SNE, ST, novgl) ;    
     tfpuop = RECORD
                Operation    : Operationstyp ;
                Extension    : Extensiontyp ;      
                Argument1    : Uebergabetyp ;
                Argument2    : Uebergabetyp ;
                Argument3    : Uebergabetyp ;
                Argument4    : Vergleichstyp ;
                VarNum       : ARRAY [0..79] OF CHAR ;
                Boolean      : ARRAY [0..79] OF CHAR ;
                Zeile        : ARRAY [0..511] OF CHAR ;
                Zeilennummer : INTEGER ;
                Zeiger       : SHORTCARD ;
                ZeigerAnfang : SHORTCARD ;
              END ;

VAR ApID     : SHORTINT ;
    fpuop    : tfpuop ;
    Compiler : Compilertyp ;

PROCEDURE Intro ; (* Kann fÅr die tÑgliche Arbeit auskommentiert werden *)
VAR AlertReturn : tExitButton ;
    AlertText   : ARRAY [1..120] OF CHAR ;
BEGIN
  AlertText :=
  "[0][FPU-Precompiler V1.1 |(c)1989 by Jens Decker |Fichtenweg 7/108 |7400 TÅbingen ][ OK ]" ;
   AlertReturn := FormAlert(FirstExit, AlertText) ;
END Intro ;

PROCEDURE FehlerMeldung(Text : ARRAY OF CHAR) ;
VAR AlertReturn : tExitButton ;
    AlertText   : ARRAY [0..150] OF CHAR ;
    ValStr      : ARRAY [0..5] OF CHAR ;
    Error       : BOOLEAN ;
BEGIN
  AlertText := "[1][ Zeile " ;
  ValToStr(fpuop.Zeilennummer, FALSE, ValStr, 10, 5, "_", Error) ;
  Concat(AlertText, ValStr) ;
  Concat(AlertText, ": |") ;
  Concat(AlertText, Text) ;
  Concat(AlertText, " ][ Abbruch ]") ;
  AlertReturn := FormAlert(FirstExit, AlertText) ;
END FehlerMeldung ;

MODULE StreamHandling ;
  IMPORT FSelOpen, DummyOpenErr, GetCurrentPath,
         GetPurePath, GetFile, Close, Open, Delete, Rename, Concat,
         tFilename, tFSelReturn, tPathname, tStreamHandle,
         tStreamMode ;
  EXPORT OeffneStreams, SchliesseStreams ;

  VAR FileName    : tFilename ;
      PathName    : tPathname ;
      FSelReturn  : tFSelReturn ;
      InputFile,
      OutputFile  : tStreamHandle ;
      ok          : BOOLEAN ; (* Dummy *)

  PROCEDURE OeffneStreams() : BOOLEAN ;
  BEGIN
    InputFile := FSelOpen(PathName, "*.MOD", "Modula-Text auswÑhlen!",
                          DummyOpenErr, ReadOnly, 512) ;
    IF InputFile = -1 
      THEN RETURN FALSE ;
    END ;
    GetFile(PathName, FileName) ;
    GetPurePath(PathName, PathName) ;
    Concat(PathName, "METAFILE") ;
    OutputFile := Open(PathName, WriteOnly, 512) ;
    IF OutputFile = -1
      THEN RETURN FALSE ;
    END ;
    RETURN TRUE ;
  END OeffneStreams ;

  PROCEDURE SchliesseStreams ;
  VAR PathMetaFile : tPathname ;
  BEGIN
    Close(InputFile) ;
    Close(OutputFile) ;
    GetPurePath(PathName, PathName) ;
    Concat(PathName, FileName) ;
    ok := Delete(PathName) ;
    GetPurePath(PathName, PathMetaFile) ;
    Concat(PathMetaFile, "METAFILE") ;
    ok := Rename(PathMetaFile, PathName) ;
  END SchliesseStreams ;

END StreamHandling ;

MODULE Parser ;
  IMPORT fpuop, tfpuop, Compilertyp, Operationstyp, Extensiontyp, 
         Uebergabetyp, Vergleichstyp, Compiler,
         RDone, FehlerMeldung, ReadLine, WriteLn, WriteString, NumFilter, 
         FilterBase, Pos, Length, Copy, InOut ;
  EXPORT ParserInit, Compileridentifizieren, Fsuchen, SucheEnde, 
         Operationidentifizieren, CompIDs,
         Extensionidentifizieren, SucheOperand1, OperandenIdentifizieren,
         Syntaxpruefung, Operationen, Extensions, Operanden,
         Vergleiche, Klammerauf, Klammerzu ;

  TYPE SMALLSTRING = ARRAY [0..7] OF CHAR ;

  VAR Operationen : ARRAY [ORD(move)..ORD(noop)] OF SMALLSTRING ;
      Extensions  : ARRAY [ORD(L)..ORD(noext)] OF SMALLSTRING ;
      Operanden   : ARRAY [ORD(Num)..ORD(nouebg)] OF SMALLSTRING ;
      Vergleiche  : ARRAY [ORD(F)..ORD(novgl)] OF SMALLSTRING ;
      CompIDs     : ARRAY [HaenischM..noComp] OF 
                      ARRAY [1..20] OF CHAR ; 
      Klammerauf,
      Klammerzu   : ARRAY [0..1] OF CHAR ;
      Klauf, Klzu : ARRAY [0..1] OF CHAR ;
      Komma       : ARRAY [0..1] OF CHAR ;
      Semikolon   : ARRAY [0..1] OF CHAR ;

  PROCEDURE ParserInit ;
  BEGIN
    FilterBase := 10 ;
    Klammerauf := "(*" ;
    Klammerzu := "*)" ;
    Klauf := "(" ;
    Klzu := ")" ;
    Komma := "," ;
    Semikolon := ";" ;
    fpuop.Zeilennummer := 0 ;
    Operationen[ORD(move)] := "move" ;
    Operationen[ORD(movecr)] := "movecr" ;
    Operationen[ORD(int)] := "int" ;    
    Operationen[ORD(sinh)] := "sinh" ;       
    Operationen[ORD(intrz)] := "intrz" ;    
    Operationen[ORD(sqrt)] := "sqrt" ;       
    Operationen[ORD(lognp1)] := "lognp1" ;    
    Operationen[ORD(etoxm1)] := "etoxm1" ;       
    Operationen[ORD(tanh)] := "tanh" ;    
    Operationen[ORD(atan)] := "atan" ;       
    Operationen[ORD(asin)] := "asin" ;    
    Operationen[ORD(atanh)] := "atanh" ;       
    Operationen[ORD(sin)] := "sin" ;    
    Operationen[ORD(tan)] := "tan" ;       
    Operationen[ORD(etox)] := "etox" ;    
    Operationen[ORD(twotox)] := "twotox" ;       
    Operationen[ORD(tentox)] := "tentox" ;    
    Operationen[ORD(logn)] := "logn" ;       
    Operationen[ORD(log10)] := "log10" ;    
    Operationen[ORD(log2)] := "log2" ;       
    Operationen[ORD(abs)] := "abs" ;    
    Operationen[ORD(cosh)] := "cosh" ;       
    Operationen[ORD(neg)] := "neg" ;    
    Operationen[ORD(acos)] := "acos" ;       
    Operationen[ORD(cos)] := "cos" ;    
    Operationen[ORD(getexp)] := "getexp" ;       
    Operationen[ORD(getman)] := "getman" ;    
    Operationen[ORD(div)] := "div" ;
    Operationen[ORD(mod)] := "mod" ;
    Operationen[ORD(add)] := "add" ;
    Operationen[ORD(mul)] := "mul" ;
    Operationen[ORD(sgldiv)] := "sgldiv" ;
    Operationen[ORD(rem)] := "rem" ;
    Operationen[ORD(reset)] := "reset" ;
    Operationen[ORD(status)] := "status" ;
    Operationen[ORD(scale)] := "scale" ;
    Operationen[ORD(sglmul)] := "sglmul" ;
    Operationen[ORD(sub)] := "sub" ;
    Operationen[ORD(sincos)] := "sincos" ;
    Operationen[ORD(cmp)] := "cmp" ;
    Operationen[ORD(tst)] := "tst" ;
    Operationen[ORD(noop)] := "" ;
    Extensions[ORD(L)] := "L" ;
    Extensions[ORD(S)] := "S" ;
    Extensions[ORD(E)] := "E" ;
    Extensions[ORD(P)] := "P" ;
    Extensions[ORD(W)] := "W" ;
    Extensions[ORD(D)] := "D" ;
    Extensions[ORD(B)] := "B" ;
    Extensions[ORD(Space)] := " " ;
    Extensions[ORD(Klammer)] := "(" ;
    Extensions[ORD(noext)] := "" ;
    Operanden[ORD(Num)] := "Num" ;
    Operanden[ORD(Var)] := "Var" ;
    Operanden[ORD(Reg0)] := "fp0" ;
    Operanden[ORD(Reg1)] := "fp1" ;
    Operanden[ORD(Reg2)] := "fp2" ;
    Operanden[ORD(Reg3)] := "fp3" ;
    Operanden[ORD(Reg4)] := "fp4" ;
    Operanden[ORD(Reg5)] := "fp5" ;
    Operanden[ORD(Reg6)] := "fp6" ;
    Operanden[ORD(Reg7)] := "fp7" ;
    Operanden[ORD(nouebg)] := "" ;
    Vergleiche[ORD(F)] := "F" ;
    Vergleiche[ORD(EQ)] := "EQ" ;
    Vergleiche[ORD(OGT)] := "OGT" ;
    Vergleiche[ORD(OGE)] := "OGE" ;
    Vergleiche[ORD(OLT)] := "OLT" ;
    Vergleiche[ORD(OLE)] := "OLE" ;
    Vergleiche[ORD(OGL)] := "OGL" ;
    Vergleiche[ORD(ORd)] := "OR" ;
    Vergleiche[ORD(UN)] := "UN" ;
    Vergleiche[ORD(UEQ)] := "UEQ" ;
    Vergleiche[ORD(UGT)] := "UGT" ;
    Vergleiche[ORD(UGE)] := "UGE" ;
    Vergleiche[ORD(ULT)] := "ULT" ;
    Vergleiche[ORD(ULE)] := "ULE" ;
    Vergleiche[ORD(NE)] := "NE" ;
    Vergleiche[ORD(T)] := "T" ;
    Vergleiche[ORD(SF)] := "SF" ;
    Vergleiche[ORD(SEQ)] := "SEQ" ;
    Vergleiche[ORD(GT)] := "GT" ;
    Vergleiche[ORD(GE)] := "GE" ;
    Vergleiche[ORD(LT)] := "LT" ;
    Vergleiche[ORD(LE)] := "LE" ;
    Vergleiche[ORD(GL)] := "GL" ;
    Vergleiche[ORD(GLE)] := "GLE" ;
    Vergleiche[ORD(NGLE)] := "NGLE" ;
    Vergleiche[ORD(NGL)] := "NGL" ;
    Vergleiche[ORD(NLE)] := "NLE" ;
    Vergleiche[ORD(NLT)] := "NLT" ;
    Vergleiche[ORD(NGE)] := "NGE" ;
    Vergleiche[ORD(NGT)] := "NGT" ;
    Vergleiche[ORD(SNE)] := "SNE" ;
    Vergleiche[ORD(ST)] := "ST" ;
    Vergleiche[ORD(novgl)] := "" ;
    CompIDs[HaenischM] := "HÑnisch" ;
    CompIDs[PDM] := "TU MÅnchen" ;
    CompIDs[TDI] := "TDI" ;
    CompIDs[SPC] := "SPC" ;
    CompIDs[Megamax] := "Megamax" ;
    CompIDs[noComp] := "" ;
  END ParserInit ;

  PROCEDURE Compileridentifizieren() : BOOLEAN ;
  VAR posComp  : SHORTINT ;
  BEGIN
    REPEAT
      Compiler := HaenischM ;
      REPEAT
        posComp := Pos(fpuop.Zeile, CompIDs[Compiler], fpuop.Zeiger) ;
        INC(Compiler) ;
      UNTIL (posComp # -1) OR (Compiler = noComp) ;
      DEC(Compiler) ;

      IF posComp = -1 
        THEN WriteString(fpuop.Zeile) ; WriteLn ;
             ReadLine(fpuop.Zeile) ;
             INC(fpuop.Zeilennummer) ;
             fpuop.Zeiger := 0 ;
        ELSE fpuop.Zeiger := posComp + Length(CompIDs[Compiler]) ;
      END ;
    UNTIL (RDone = FALSE) OR (posComp # -1) ;
    IF posComp = -1
      THEN FehlerMeldung("Kein Compiler | definiert!") ;
           RETURN FALSE ;
      ELSE RETURN TRUE ;
    END ;
  END Compileridentifizieren ;

  PROCEDURE Fsuchen() : BOOLEAN ;
  VAR positionF,
      positionKlammerauf : SHORTINT ;
      resultat           : BOOLEAN ;
      F                  : CHAR ;
  BEGIN
    F := "F" ;
    positionF := Pos(fpuop.Zeile, F, fpuop.Zeiger) ;
    positionKlammerauf := Pos(fpuop.Zeile, Klammerauf, fpuop.Zeiger) ;

    IF ((positionF < positionKlammerauf) AND (positionF # -1)) OR
       ((positionF # -1) AND (positionKlammerauf = -1))
      THEN fpuop.Zeiger := positionF + Length(F) ;
           resultat := TRUE ;
    ELSIF ((positionKlammerauf < positionF) AND (positionKlammerauf # -1)) OR 
           ((positionKlammerauf # -1) AND (positionF = -1)) 
      THEN fpuop.Zeiger := positionKlammerauf + Length(Klammerauf) ;
           resultat := Klammernumgehen() ; (* FALSE = F E H L E R ! *)
           IF resultat 
             THEN resultat := Fsuchen() ;
             ELSE FehlerMeldung(" Ein Kommentar wurde | nicht geschlossen!") ; 
           END ;
    ELSIF ((positionF = -1) AND (positionKlammerauf = -1))
      THEN WriteString(fpuop.Zeile) ; WriteLn ;
           ReadLine(fpuop.Zeile) ;
           INC(fpuop.Zeilennummer) ;
           fpuop.Zeiger := 0 ;
           IF RDone
             THEN resultat := Fsuchen() ;
             ELSE resultat := FALSE ;
           END ;
    END ;
    IF resultat
      THEN fpuop.ZeigerAnfang := fpuop.Zeiger - 1 ;
    END ;
    RETURN resultat ;     
  END Fsuchen ;
 
  PROCEDURE Klammernumgehen() : BOOLEAN ;
  VAR positionKlammerzu,
      positionKlammerauf : SHORTINT ;
      Klammerebene       : SHORTCARD ; 
  BEGIN
    Klammerebene := 1 ;
    REPEAT
      positionKlammerzu := Pos(fpuop.Zeile, Klammerzu, fpuop.Zeiger) ;
      positionKlammerauf := Pos(fpuop.Zeile, Klammerauf, fpuop.Zeiger) ;
    
      IF ((positionKlammerzu < positionKlammerauf) AND (positionKlammerzu # -1)) OR
         ((positionKlammerzu # -1) AND (positionKlammerauf = -1))
        THEN fpuop.Zeiger := positionKlammerzu + Length(Klammerzu) ;
             Klammerebene := Klammerebene - 1 ;
      ELSIF ((positionKlammerauf < positionKlammerzu) AND (positionKlammerauf # -1)) OR
         ((positionKlammerauf # -1) AND (positionKlammerzu = -1))
        THEN fpuop.Zeiger := positionKlammerauf + Length(Klammerauf) ;
             Klammerebene := Klammerebene + 1 ;
      ELSIF ((positionKlammerauf = -1) AND (positionKlammerzu = -1))
        THEN WriteString(fpuop.Zeile) ; WriteLn ;
             ReadLine(fpuop.Zeile) ;
             INC(fpuop.Zeilennummer) ;
             fpuop.Zeiger := 0 ;
             IF NOT RDone
               THEN RETURN FALSE ; (* Fehlermeldung in Fsuchen() *)
             END ;
      END ;
    UNTIL Klammerebene = 0 ;
  RETURN TRUE ;
  END Klammernumgehen ;

  PROCEDURE SucheEnde ;
  VAR Position1 : SHORTINT ;
  BEGIN
    Semikolon := ";" ;
    Position1 := Pos(fpuop.Zeile, Semikolon, fpuop.Zeiger) ;
    IF Position1 # -1
      THEN fpuop.Zeiger := Position1 + 1 ;
    END ;
  END SucheEnde ;

  PROCEDURE Operationidentifizieren() : BOOLEAN ;
  VAR Operation    : Operationstyp ;
      OperationsNr : SHORTCARD ;
      Laenge       : SHORTCARD ;
  BEGIN
    Operation := move ;
    OperationsNr := IdentifiziereString(fpuop.Zeile, fpuop.Zeiger, Operationen,
                                        ORD(move), ORD(noop)) ;
    INC(Operation, OperationsNr) ;
    IF Operation = noop
      THEN RETURN FALSE ;
      ELSE fpuop.Operation := Operation ;
           Laenge := Length(Operationen[ORD(Operation)]) ; 
           fpuop.Zeiger := fpuop.Zeiger + Laenge ;
           RETURN TRUE ;
    END ;
  END Operationidentifizieren ;

  PROCEDURE Extensionidentifizieren() : BOOLEAN ;
  VAR Extension   : Extensiontyp ;
      ExtensionNr : SHORTCARD ;
      Laenge      : SHORTCARD ;
  BEGIN
    Extension := L ;
    ExtensionNr := IdentifiziereString(fpuop.Zeile, fpuop.Zeiger, Extensions,
                                       ORD(Extension), ORD(noext)) ;
    INC(Extension, ExtensionNr) ;
    IF (Extension = noext) OR (Extension = P)  (* P nicht implementiert *)   
      THEN FehlerMeldung(" Diese Extension ist | nicht implementiert") ;
           RETURN FALSE ;
    ELSIF (Extension = Space) OR (Extension = Klammer) 
      THEN fpuop.Extension := D ;
      ELSE fpuop.Extension := Extension ;
    END ;
    Laenge := Length(Extensions[ORD(Extension)]) ;
    IF Extension = Klammer
      THEN DEC(Laenge) ;
    END ;
    fpuop.Zeiger := fpuop.Zeiger + Laenge ;
    RETURN TRUE ; 
  END Extensionidentifizieren ;

  PROCEDURE SucheOperand1() : BOOLEAN ;
  VAR Anfang, Ende : SHORTINT ;
  BEGIN
    Anfang := Pos(fpuop.Zeile, Klauf, fpuop.Zeiger) ;
    Ende := Pos(fpuop.Zeile, Klzu, fpuop.Zeiger) ;
    IF Anfang = Pos(fpuop.Zeile, Klammerauf, fpuop.Zeiger) 
      THEN Anfang := -1 ;
    END ;
    IF Ende = Pos(fpuop.Zeile, Klammerzu, fpuop.Zeiger) 
      THEN Ende := -1 ;
    END ;
    IF (Anfang = -1) OR (Ende = -1)  
      THEN FehlerMeldung(" Operandenliste fehlt!") ; 
           RETURN FALSE ;
    ELSIF Anfang > Ende 
      THEN FehlerMeldung(" '(' fehlt!") ;
           RETURN FALSE ;
      ELSE fpuop.Zeiger := Anfang + 1 ;
           WHILE fpuop.Zeile[fpuop.Zeiger] <= " " DO
             INC(fpuop.Zeiger) ;
           END ;
           IF fpuop.Zeile[fpuop.Zeiger] = ")" 
             THEN FehlerMeldung(" Operandenliste fehlt!") ;
                  RETURN FALSE ;
           END ;
    END ;
    RETURN TRUE ;
  END SucheOperand1 ;

  PROCEDURE OperandenIdentifizieren() : BOOLEAN ;
  VAR Operand     : Uebergabetyp ;
      OperandNr   : SHORTCARD ;
      VergleichNr : SHORTCARD ;
      Laenge      : SHORTCARD ;
      Position1,
      Position2   : SHORTINT ;
      Freiraum    : ARRAY [0..1] OF CHAR ;
      Weitermachen: BOOLEAN ;

    PROCEDURE TestRegVar(VAR Argumentx : Uebergabetyp ; 
                         VAR Ablage : ARRAY OF CHAR) : BOOLEAN ;
    BEGIN
      Argumentx := Reg0 ;
      OperandNr := IdentifiziereString(fpuop.Zeile, fpuop.Zeiger, Operanden,
                                       ORD(Argumentx), ORD(nouebg)) ;
      INC(Argumentx, OperandNr - ORD(Argumentx)) ;
      IF Argumentx < nouebg
        THEN Laenge := Length(Operanden[ORD(Argumentx)]) ;
             fpuop.Zeiger := fpuop.Zeiger + Laenge ;
      ELSIF ChIsLetter(fpuop.Zeile[fpuop.Zeiger])
        THEN Freiraum := " " ;
(*             Position1 := Pos(fpuop.Zeile, Freiraum, fpuop.Zeiger) ;
*)             Position1 := Pos(fpuop.Zeile, Komma, fpuop.Zeiger) ;
(*             IF ((Position2 < Position1) AND (Position2 # -1)) OR (Position1 = -1) 
               THEN Position1 := Position2 ;
             END ;
*)             Position2 := Pos(fpuop.Zeile, Klzu, fpuop.Zeiger) ;
             IF ((Position2 < Position1) AND (Position2 # -1)) OR (Position1 = -1) 
               THEN Position1 := Position2 ;
             END ;
             Position2 := fpuop.Zeiger ;
             Copy(Ablage, fpuop.Zeile, fpuop.Zeiger, Position1 - Position2) ;
             Argumentx := Var ;
             fpuop.Zeiger := Position1 ;
      END ;
      RETURN (Argumentx # nouebg) ;
    END TestRegVar ;

    PROCEDURE TestVgl() : BOOLEAN ;
    BEGIN
      fpuop.Argument4 := F ;
      VergleichNr := IdentifiziereString(fpuop.Zeile, fpuop.Zeiger, Vergleiche,
                                       ORD(fpuop.Argument4), ORD(novgl)) ;
      INC(fpuop.Argument4, VergleichNr) ;
      IF fpuop.Argument4 = novgl
        THEN RETURN FALSE ;
        ELSE WHILE fpuop.Zeile[fpuop.Zeiger] # ")" DO
               INC(fpuop.Zeiger) ;
             END ;
             INC(fpuop.Zeiger) ;
             RETURN TRUE ;
      END ;
    END TestVgl ;

    PROCEDURE NaechsterOperand() : BOOLEAN ;
    BEGIN
      Position1 := Pos(fpuop.Zeile, Klzu, fpuop.Zeiger) ;
      Position2 := Pos(fpuop.Zeile, Komma, fpuop.Zeiger) ;
      IF (Position2 < Position1) AND (Position2 # -1)
        THEN fpuop.Zeiger := Position2 + 1 ;
             WHILE fpuop.Zeile[fpuop.Zeiger] <= " " DO
                   INC(fpuop.Zeiger) ;
             END ;
             IF fpuop.Zeile[fpuop.Zeiger] = ")" 
               THEN FehlerMeldung(" Kein Operand hinter dem Komma") ;
                    RETURN FALSE ;
             END ;
        ELSE fpuop.Zeiger := Position1 + 1 ;
             RETURN FALSE ;
      END ;
      RETURN TRUE ;
    END NaechsterOperand ;

  BEGIN
    IF TestRegVar(fpuop.Argument1, fpuop.VarNum)
      THEN IF NOT NaechsterOperand() 
             THEN FehlerMeldung(" Zu wenig Operanden!") ;
                  RETURN FALSE ;
           END ;
    ELSIF NumFilter(fpuop.Zeile[fpuop.Zeiger]) 
      THEN Position1 := Pos(fpuop.Zeile, Freiraum, fpuop.Zeiger) ;
           Position2 := Pos(fpuop.Zeile, Komma, fpuop.Zeiger) ;
           IF ((Position2 < Position1) AND (Position2 # -1)) OR (Position1 = -1) 
             THEN Position1 := Position2 ;
           END ;
           Position2 := Pos(fpuop.Zeile, Klzu, fpuop.Zeiger) ;
           IF ((Position2 < Position1) AND (Position2 # -1)) OR (Position1 = -1) 
             THEN Position1 := Position2 ;
           END ;
           Position2 := fpuop.Zeiger ;
           Copy(fpuop.VarNum, fpuop.Zeile, fpuop.Zeiger, Position1 - Position2) ;
           fpuop.Argument1 := Num ;
           fpuop.Zeiger := Position1 ;
           IF NOT NaechsterOperand()
             THEN FehlerMeldung(" Zu wenig Operanden!") ;
                  RETURN FALSE ;
           END ;
    ELSE IF fpuop.Zeile[fpuop.Zeiger] = Komma[0] 
           THEN FehlerMeldung(" Kein Operand vor dem Komma!") ;
           ELSE InOut.Write(fpuop.Zeile[fpuop.Zeiger]) ; InOut.WriteString("    ") ; InOut.WriteCard(fpuop.Zeiger, 2) ; InOut.WriteLn ;
                FehlerMeldung(" Fehlende Operanden!") ;
         END ;
         RETURN FALSE ;
    END ;

    IF fpuop.Operation = tst 
      THEN Weitermachen := TRUE ;
      ELSE Weitermachen := TestRegVar(fpuop.Argument2, fpuop.VarNum) ;
           IF Weitermachen 
             THEN Weitermachen := NaechsterOperand()
             ELSE FehlerMeldung(" Operand nicht korrekt!") ;
                  RETURN FALSE ;
           END ;
    END ;
    IF Weitermachen 
      THEN IF TestRegVar(fpuop.Argument3, fpuop.Boolean)
             THEN IF NaechsterOperand()
                    THEN IF NOT TestVgl()
                           THEN FehlerMeldung
                                ("Vergleichstyp nicht definiert!") ;
                                RETURN FALSE ;
                         END ;
                  END ;
             ELSE FehlerMeldung(" Operand nicht korrekt!") ;
                         RETURN FALSE ;
           END ;
    END ;
    SucheEnde ;
    RETURN TRUE ;
  END OperandenIdentifizieren ;

  PROCEDURE Syntaxpruefung() : BOOLEAN ;
  BEGIN
    CASE fpuop.Operation OF 
      move : IF (fpuop.Argument1 = Var) AND (fpuop.Argument2 = Var)
               THEN FehlerMeldung(" Fmove immer nur unter | Beteiligung von Registern!") ;
                    RETURN FALSE ;
             END |
      sincos : IF (fpuop.Argument2 < Reg0) OR (fpuop.Argument2 > Reg7) OR 
                  (fpuop.Argument3 < Reg0) OR (fpuop.Argument3 > Reg7)
                 THEN FehlerMeldung(" Fsincos arbeitet nur mit | Registern als Zielen!") ;
                      RETURN FALSE ;
               END |        
      cmp : IF (fpuop.Argument2 < Reg0) OR (fpuop.Argument2 > Reg7)
              THEN FehlerMeldung(" Der zweite Operand muû | ein Register sein!") ;
                   RETURN FALSE ;
            ELSIF fpuop.Argument3 # Var
              THEN FehlerMeldung(" Der dritte Operand muû | eine BOOLEAN-Variable sein!") ;
                   RETURN FALSE ;
            END |
      tst : IF fpuop.Argument3 # Var
              THEN FehlerMeldung(" Der dritte Operand muû | eine BOOLEAN-Variable sein!") ;
                   RETURN FALSE ;
            END |
    ELSE IF fpuop.Argument3 # nouebg
           THEN FehlerMeldung(" Die Operation hat | zwei Operanden!") ;
                RETURN FALSE ;
         ELSIF (fpuop.Argument2 < Reg0) OR (fpuop.Argument2 > Reg7)
           THEN FehlerMeldung(" Der Zieloperand muû ein | Register sein!") ;
                RETURN FALSE ;
         END ;
    END ;
    IF fpuop.Operation = movecr
      THEN IF (fpuop.VarNum[0] = "6") AND (fpuop.VarNum[1] > "3")
             THEN FehlerMeldung(" Der ROM-Offset ist zu groû!") ;
                  RETURN FALSE ;
           END ;
    END ;
    IF (fpuop.Argument1 = Num) AND (fpuop.Extension = E)
      THEN FehlerMeldung(" Zahlen haben maximal | Double-Precision!") ;
           RETURN FALSE ;
    END ; 
    RETURN TRUE ;
  END Syntaxpruefung ;  

  PROCEDURE IdentifiziereString(Zeile : ARRAY OF CHAR ; ZeigerZeile : SHORTCARD ;
                                StringArray : ARRAY OF SMALLSTRING ;
                                ZeigerAnfang, ZeigerEnde : SHORTCARD) 
                              : SHORTCARD ;
  VAR Zeiger1, Zeiger2 : SHORTCARD ;
  BEGIN
    Zeiger1 := ZeigerAnfang ;
    WHILE NOT (Equal(Zeile, StringArray[Zeiger1], ZeigerZeile, 0,
               Length(StringArray[Zeiger1])) OR (Zeiger1 = ZeigerEnde)) DO
      INC(Zeiger1) ;
    END ;
    IF Zeiger1 # ZeigerEnde
      THEN REPEAT
             Zeiger2 := IdentifiziereString(Zeile, ZeigerZeile, StringArray,
                                            Zeiger1 + 1, ZeigerEnde) ;
             IF Length(StringArray[Zeiger2]) > Length(StringArray[Zeiger1])
               THEN Zeiger1 := Zeiger2 ;
             END ;
           UNTIL Zeiger2 = ZeigerEnde ;  
    END ; 
    RETURN Zeiger1 ;
  END IdentifiziereString ;
                              
  PROCEDURE Equal(VAR s1, s2 : ARRAY OF CHAR; p1, p2, l : SHORTCARD) : BOOLEAN ;
  VAR Laenge1, Laenge2 : SHORTCARD ;
  BEGIN
    IF l = 0 
      THEN RETURN TRUE ;  (* Immer gleich *)
    END ;
    Laenge1 := Length(s1) ; Laenge2 := Length(s2) ;
    IF (p1 + l - 1 > Laenge1) OR (p2 + l - 1 > Laenge2)
      THEN RETURN FALSE ; (* Strings zu klein, Absturzgefahr! *) 
    END ;
    
    WHILE (l > 0) AND (s1[p1+l-1] = s2[p2+l-1]) DO
      l := l - 1 ;
    END ;    
    IF l = 0 
      THEN RETURN TRUE ;
      ELSE RETURN FALSE ;
    END ;
  END Equal ; 

  PROCEDURE ChIsLetter(ch: CHAR) : BOOLEAN ;
  BEGIN
    IF ((ch >= "A") AND (ch <= "Z")) OR ((ch >= "a") AND (ch <= "z"))
      THEN RETURN TRUE ;
      ELSE RETURN FALSE ;
    END ;
  END ChIsLetter ;

END Parser ;

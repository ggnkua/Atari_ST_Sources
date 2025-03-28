MODULE FPUPreprozessor ;  (* FÅr HÑnisch Modula V3.105 *)

(* Projekt       : FPUPreprozessor                                         *)
(* Teil          : Hauptmodul                                              *)
(* Weitere Files : FPU_PREP.TXT Vorarbeiten fÅr den FPUPreprozessor        *)
(*                 FPU_MAKE.INF MakeFile fÅr HÑnisch Modula                *)
(* Beginn        : 07.07.89  long long ago...                              *)
(* akt. Datum    : 02.05.90                                                *)
(* akt. Arbeiten : Anpassung an das Megamax Modula                         *)
(* Copyright by Jens Decker, Fichtenweg 7/108, 7400 TÅbingen               *)
(* Vertriebsrechte: Maxon Computer GmbH                                    *)

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

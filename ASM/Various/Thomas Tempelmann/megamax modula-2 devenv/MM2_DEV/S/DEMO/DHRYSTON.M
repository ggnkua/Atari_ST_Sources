MODULE DhryStone;

(*
 * Compilercode-Testprogramm.
 *                                               Version 1.2, 15. Mai 1990
 *
 *   Portiert durch Dirk Steins von C-Source (Version 1.1) nach Modula-2,
 * öberarbeitung und Dokumentation von Thomas Tempelmann.
 *
 *   Register-Variable werden nicht im einzelnen spezifiziert, da dies
 * bei Modula-2 nicht vorgesehen ist.
 *
 *   DafÅr wird in 'Proc1' eine WITH-Anweisung verwendet, fÅr die es in
 * der C-Version nur ein Macro gibt (C bietet kein WITH-Konstrukt). Da
 * aber alles darauf hinweist, daû im Original dieses Programms, das in
 * ADA geschrieben wurde, WITH verwendet wurde, wird es auch hier in der
 * Modula-Version getan, schon allein, weil es sinnvoll fÅr den Test ist.
 *
 *   FÅr den Test sollten alle globalen Optimierungen aktiviert sein
 * und Bereichs-, öberlauf-, Stack- und weitere PrÅfungen deaktiviert
 * sein.
 *
 * ACHTUNG:
 *   Um korrekte Ergebnisse zu erhalten, sollten alle residenten Programme,
 * also Programme im AUTO-Ordner und Accessories, beim Test entfernt werden,
 * weil viele dieser Programme sich in System-Vektoren installieren (zB VBL)
 * und damit den Rechner ein wenig verlangsamen.
 *
 * Ergebnisse:
 *
 * Compiler           Hardware                         Dhrystones/s
 *   SPC 2.0            Atari ST 8MHz                    493
 *   Megamax 3.8        Atari ST 8MHz                    522
 *   FTL 1.18           Atari ST 8MHz                    656   (s. Anm. 1)
 *   HÑnisch 3.105      Atari ST 8MHz                    710
 *   TDI 3.01           Atari ST 8MHz                    717
 *   M2AMIGA 3.3        Amiga 2000 7.16MHz (2MB FastRAM) 847
 *   FST 2.0            IBM AT 286 12MHz                 1060
 *   Megamax 4.0        Atari ST 8MHz                    1061
 *   Rowley 1.34        Atari ST 8MHz                    1500
 *   LogiTech 3.4 DOS   80386 24MHz/0ws                  4755
 *   Rowley 1.34        Sun-3/60  68020 20 MHz           5500
 *   Rowley 1.33        T800  20 MHz                     8500
 *   Rowley 1.33        R3000  16 MHz                    12500
 *
 * Testergebnisse mit der hiesigen Compare-Funktion (s. Anmerkung 2):
 *   SPC 2.0            Atari ST 8MHz                    683
 *
 * Anmerkungen zu den Ergebnissen:
 *  1) Der FTL-Compiler verfÅgt Åber keine "Compare"-Funktion im Strings-Modul,
 *     daher wurde die eigens dafÅr erstellte Routine hier im Testprogramm
 *     (s.u.) benutzt.
 *  2) Einige Modula-Systeme bieten eine sehr langsame "Compare"-Funktion.
 *     Da man sie selbst womîglich gegen eine schnellere, wie die unten
 *     stehende, "Compare"-Funktion austauschen wÅrde, wurden bei diesen
 *     Systemen zwei Ergebnisse ermittelt: mit der Strings-Funktion und
 *     und mit der hiesigen Funktion. Zu beachten ist aber, daû die hiesige
 *     Funktion mit VAR-Parametern arbeitet, sodaû sie nicht allgemein
 *     einsetzbar ist. Dies sollte aber - wegen des Gedankens der eigenen
 *     Optimierung, so beibehalten bleiben!
 *
 *)

FROM SYSTEM     IMPORT ADR;
FROM InOut      IMPORT WriteString, WriteLn, WriteCard, Read;
FROM Strings    IMPORT Compare, Relation;
FROM Storage    IMPORT ALLOCATE;

(**** Compiler-/Library-abhÑngige Importe ****)

    (* fÅr time-Funktion, s.u. *)
    FROM XBIOS      IMPORT SuperExec;
    FROM SYSTEM     IMPORT ADDRESS;


(**** Compiler-abhÑngige Direktiven ****)

    (*$R-   Megamax: no range checks *)
    (*$S-   Megamax: no stack checks *)
    (*$Z+   Megamax: optimize for use of registers in function returns *)

    (* I+   FTL: HIGH() returns CARDINAL (16 Bit) *)


(**** Compiler-abhÑngige Definitionen ****)

    TYPE  Integer    = SHORTINT;  (* mîglichst 16 Bit-Integer *)

    CONST HZ = 200;               (* time() RETURNs 1/200 second (Atari ST) *)


(**** Compiler-/Library-abhÑngige Funktionen ****)

    VAR hz200: LONGCARD;

    PROCEDURE readTimer;
      VAR p: POINTER TO LONGCARD;
      BEGIN
        p:= ADDRESS (04BAH);  (* Adr. des 200 Hz-Timers beim ST *)
        hz200:= p^
      END readTimer;

    PROCEDURE time (): LONGCARD;
      (* Diese Funktion liest den 200 Hz-Timer des ST aus *)
      BEGIN
        SuperExec (readTimer);
        RETURN hz200
      END time;

(* fÅr Systeme, die keine Compare-Funktion haben (z.B. FTL),
 * oder eine DEUTLICH zu langsame Compare-Funktion haben (z.B. SPC):

    TYPE Relation = (less, equal, greater);

    PROCEDURE Compare (VAR left, right: ARRAY OF CHAR): Relation;
      (*
       * Die VAR-Parameter sind fÅr eine individuell auf diese
       * Testanwendung erstellte Funktion legitim. DafÅr
       * bekommt das Modula-System aber auch gleich Minuspunkte,
       * weil es diese Funktion nicht bereitstellt!
       *)
      VAR high, idx: Integer; ch: CHAR;
      BEGIN
        IF HIGH (left) > HIGH (right) THEN
          high:= HIGH (right)
        ELSE
          high:= HIGH (left)
        END;
        idx:= 0;
        REPEAT
          ch:= left [idx];
          IF ch # right [idx] THEN
            IF ch > right [idx] THEN
              RETURN greater
            ELSE
              RETURN less
            END
          END;
          IF ch = 0C THEN
            RETURN equal
          END;
          INC (idx)
        UNTIL (idx > high);
        IF HIGH (left) = HIGH (right) THEN
          RETURN equal
        END;
        IF HIGH (left) > HIGH (right) THEN
          IF left [idx] = 0C THEN
            RETURN equal
          ELSE
            RETURN greater
          END
        ELSE
          IF right [idx] = 0C THEN
            RETURN equal
          ELSE
            RETURN less
          END
        END
      END Compare;
*)

(**** Beginn des unabhÑngigen Programms *)


CONST Version = "1.2";

CONST LOOPS = 10000;  (* fÅr ca. 10 - 20 Sekunden *)


TYPE Enumeration    = (Ident1, Ident2, Ident3, Ident4, Ident5);
TYPE OneToThirty    = Integer [1..30];
TYPE OneToFifty     = Integer [1..50];
TYPE CapitalLetter  = CHAR;
TYPE String30       = ARRAY [0..30] OF CHAR;
TYPE Array1Dim      = ARRAY [0..50] OF Integer;
TYPE Array2Dim      = ARRAY [0..50],[0..50] OF Integer;

TYPE RecordPtr      = POINTER TO RecordType;

     RecordType     = RECORD
                        PtrComp   : RecordPtr;
                        Discr     : Enumeration;
                        EnumComp  : Enumeration;
                        IntComp   : OneToFifty;
                        StringComp: String30;
                      END;


(*
 * Package 1
 *)
VAR
  IntGlob   : Integer;
  BoolGlob  : BOOLEAN;
  Char1Glob : CHAR;
  Char2Glob : CHAR;
  Array1Glob: Array1Dim;
  Array2Glob: Array2Dim;
  PtrGlb    : RecordPtr;
  PtrGlbNext: RecordPtr;


PROCEDURE Func1(CharPar1, CharPar2: CapitalLetter): Enumeration;
  VAR CharLoc1,
      CharLoc2 : CapitalLetter;
  BEGIN
    CharLoc1:= CharPar1;
    CharLoc2:= CharLoc1;
    IF (CharLoc2 # CharPar2) THEN
      RETURN Ident1
    ELSE
      RETURN Ident2
    END
  END Func1;

PROCEDURE Func2 ( VAR StrParI1, StrParI2: String30): BOOLEAN;
  VAR IntLoc: OneToThirty;
      CharLoc: CapitalLetter;
  BEGIN
    IntLoc:= 1;
    WHILE (IntLoc <= 1) DO
      IF (Func1 (StrParI1[IntLoc], StrParI2[IntLoc+1]) = Ident1) THEN
        CharLoc:= 'A';
        INC(IntLoc);
      END;
    END;
    IF (CharLoc >= 'W') & (CharLoc <= 'Z') THEN
      IntLoc:= 7;
    END;
    IF (CharLoc = 'X') THEN
      RETURN TRUE
    ELSE
      IF ( Compare(StrParI1, StrParI2) = greater) THEN
        INC(IntLoc,7);
        RETURN TRUE
      ELSE
        RETURN FALSE
      END
    END;
  END Func2;

PROCEDURE Func3(EnumParIn: Enumeration): BOOLEAN;
  VAR  EnumLoc: Enumeration;
  BEGIN
    EnumLoc:= EnumParIn;
    IF (EnumLoc = Ident3) THEN
      RETURN TRUE
    END;
    RETURN FALSE
  END Func3;


PROCEDURE Proc7 ( IntParI1, IntParI2: OneToFifty; VAR IntParOut: OneToFifty);
  VAR IntLoc: OneToFifty;
  BEGIN
    IntLoc:= IntParI1 + 2;
    IntParOut:= IntParI2 + IntLoc;
  END Proc7;

PROCEDURE Proc3(VAR PtrParOut : RecordPtr);
  BEGIN
    IF (PtrGlb # NIL) THEN
      PtrParOut := PtrGlb^.PtrComp;
    ELSE
      IntGlob := 100;
    END;
    Proc7(10, IntGlob, PtrGlb^.IntComp);
  END Proc3;

PROCEDURE Proc6(EnumParIn : Enumeration; VAR EnumParOut: Enumeration);
  BEGIN
    EnumParOut := EnumParIn;
    IF (~ Func3(EnumParIn) ) THEN
      EnumParOut := Ident4;
    END;
    CASE EnumParIn OF
      Ident1: EnumParOut := Ident1; |
      Ident2: IF (IntGlob > 100) THEN
                EnumParOut := Ident1
              ELSE
                EnumParOut := Ident4
              END |
      Ident3: EnumParOut := Ident2 |
      Ident4: |
      Ident5: EnumParOut := Ident3 |
    END;
  END Proc6;

PROCEDURE Proc1(PtrParIn : RecordPtr);
  BEGIN
    PtrParIn^.PtrComp^ := PtrGlb^;
    PtrParIn^.IntComp := 5;
    WITH PtrParIn^.PtrComp^ DO
      IntComp := PtrParIn^.IntComp;
      PtrComp := PtrParIn^.PtrComp;
      Proc3(PtrComp);
      IF (Discr = Ident1) THEN
        IntComp := 6;
        Proc6(PtrParIn^.EnumComp, EnumComp);
        PtrComp := PtrGlb^.PtrComp;
        Proc7(IntComp, 10, IntComp);
      ELSE
        PtrParIn := PtrParIn^.PtrComp;
      END;
    END;
  END Proc1;

PROCEDURE Proc2(VAR IntParIO : OneToFifty);
  VAR IntLoc  : OneToFifty;
      EnumLoc : Enumeration;
  BEGIN
    IntLoc := IntParIO + 10;
    LOOP
      IF (Char1Glob = 'A') THEN
        DEC(IntLoc);
        IntParIO := IntLoc - IntGlob;
        EnumLoc  := Ident1;
      END;
      IF (EnumLoc = Ident1) THEN
        EXIT
      END;
    END;
  END Proc2;

PROCEDURE Proc4();
  VAR BoolLoc : BOOLEAN;
  BEGIN
    BoolLoc := Char1Glob = 'A';
    BoolLoc := ~ BoolGlob;
    Char2Glob := 'B';
  END Proc4;

PROCEDURE Proc5();
  BEGIN
    Char1Glob := 'A';
    BoolGlob := FALSE;
  END Proc5;

PROCEDURE Proc8 ( VAR Array1Par: Array1Dim; VAR Array2Par: Array2Dim;
                  IntParI1, IntParI2: OneToFifty);
  VAR IntLoc: OneToFifty;
      IntIndex: OneToFifty;
  BEGIN
    IntLoc:= IntParI1 + 5;
    Array1Par[IntLoc]:= IntParI2;
    Array1Par[IntLoc+1]:= Array1Par[IntLoc];
    Array1Par[IntLoc+30]:= IntLoc;
    FOR IntIndex:= IntLoc TO IntLoc+1 DO
      Array2Par[IntLoc][IntIndex]:= IntLoc;
    END;
    INC(Array2Par[IntLoc][IntLoc-1]);
    Array2Par[IntLoc+20][IntLoc]:= Array1Par[IntLoc];
    IntGlob:= 5;
  END Proc8;

PROCEDURE Proc0();
  VAR
    IntLoc1    : OneToFifty;
    IntLoc2    : OneToFifty;
    IntLoc3    : OneToFifty;
    CharLoc    : CHAR;
    CharIndex  : CHAR;
    EnumLoc    : Enumeration;
    String1Loc : String30;
    String2Loc : String30;
    starttime  : LONGCARD;
    benchtime  : LONGCARD;
    nulltime   : LONGCARD;
    i          : [0..LOOPS];

  BEGIN
    starttime := time();
    FOR i := 0 TO LOOPS-1 DO END;
    nulltime := time() - starttime; (* Computes overhead of loop *)

    NEW (PtrGlbNext);
    NEW (PtrGlb);
    PtrGlb^.PtrComp := PtrGlbNext;
    PtrGlb^.Discr := Ident1;
    PtrGlb^.EnumComp := Ident3;
    PtrGlb^.IntComp := 40;
    PtrGlb^.StringComp := "DHRYSTONE PROGRAM, SOME STRING";
    String1Loc := "DHRYSTONE PROGRAM, 1'ST STRING";   (*GOOF*)
    Array2Glob[8][7] := 10;

    (*****************
    -- Start Timer --
    *****************)
    
    starttime := time();
    
    FOR i := 0 TO LOOPS-1 DO
      Proc5();
      Proc4();
      IntLoc1 := 2;
      IntLoc2 := 3;
      String2Loc := "DHRYSTONE PROGRAM, 2'ND STRING";
      EnumLoc := Ident2;
      BoolGlob := ~ Func2(String1Loc, String2Loc);
      WHILE (IntLoc1 < IntLoc2)  DO
        IntLoc3 := 5 * IntLoc1 - IntLoc2;
        Proc7(IntLoc1, IntLoc2, IntLoc3);
        INC(IntLoc1);
      END;
      Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3);
      Proc1(PtrGlb);
      FOR CharIndex := 'A' TO Char2Glob DO
        IF (EnumLoc = Func1(CharIndex, 'C')) THEN
          Proc6(Ident1, EnumLoc);
        END;
      END;
      IntLoc3 := IntLoc2 * IntLoc1;
      IntLoc2 := IntLoc3 DIV IntLoc1;
      IntLoc2 := 7 * (IntLoc3 - IntLoc2) - IntLoc1;
      Proc2(IntLoc1);
    END;
    

    (*****************
    -- Stop Timer --
    *****************)

    benchtime := time() - starttime - nulltime;

    WriteString("Modula-2 Dhrystone (");
    WriteString(Version);
    WriteString(") time for ");
    WriteCard(LOOPS,6);
    WriteString(" passes is ");
    WriteCard(benchtime DIV VAL (LONGCARD, HZ), 5);
    WriteLn;
    WriteString("This machine benchmarks at ");
    WriteCard(VAL (LONGCARD, LOOPS) * VAL (LONGCARD, HZ) DIV benchtime,6);
    WriteString(" dhrystones/second");
    WriteLn;
  END Proc0;

VAR ch: CHAR;

BEGIN
  WriteString ("Running...");
  WriteLn;
  Proc0 ();
  Read (ch);
END DhryStone.

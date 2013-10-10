MODULE D_Main;

(*$R-,S-,Z+ *)

FROM InOut     IMPORT Read, WriteString, WriteLn, ReadInt, WriteInt, Write;
FROM InOut     IMPORT WriteReal;
FROM Storage   IMPORT ALLOCATE;
FROM TimeDate  IMPORT Clock;  (* system dependent !! *)

FROM D_Global  IMPORT OneToThirty, OneToFifty, Enumeration, String30,
                      RecordPointer, Array1DimInteger, Array2DimInteger,
                      RecordType;
FROM D_Pack_1  IMPORT Proc1, Proc2, Proc3, Proc4, Proc5, NextPointerGlob,
                      PointerGlob, Char2Glob, Array1Glob, Array2Glob, BoolGlob;
FROM D_Pack_2  IMPORT Proc6, Proc7, Proc8, Func1, Func2, IntGlob, Char1Glob;

CONST (* for measurement *)

  MicrosecondsPerClock  = 5000;
  ClocksPerSecond       = 200;
        (* On the Atari ST we use the 200 Hz timer value        *)
  TooSmallTime          = 1000;
        (* Measurements should last at least 1000 samples       *)

VAR

  (* Ada version: Variables local in Proc_0 *)

  Int1Glob,
  Int2Glob,
  Int3Glob:       OneToFifty;
  CharIndex:      CHAR;
  EnumGlob:       Enumeration;
  String1Glob,
  String2Glob:    String30;

  (* Variables for measurement *)

  RunIndex,
  NumberOfRuns:         INTEGER;
  BeginClock,
  EndClock,
  SumClocks:            LONGINT;     (* system dependent !!! *)
  Microseconds,
  DhrystonesPerSecond:  REAL;
  I:                    INTEGER;

  (* end of variables for measurement *)

  dummy : CHAR;
  
BEGIN (* main program, corresponds to procedures        *)
      (* Main and Proc_0 in the Ada version             *)

  (* Initializations *)

  ALLOCATE (NextPointerGlob, SIZE(RecordType));

  ALLOCATE (PointerGlob, SIZE(RecordType));

  PointerGlob^.PointerComp := NextPointerGlob;
  PointerGlob^.Discr       := Ident1;
  PointerGlob^.EnumComp    := Ident3;
  PointerGlob^.IntComp     := 40;
  PointerGlob^.StringComp  := "DHRYSTONE PROGRAM, SOME STRING";

  String1Glob := "DHRYSTONE PROGRAM, 1'ST STRING";

  Array2Glob [8,7] := 10;

  WriteLn;
  WriteString ('Dhrystone Benchmark, Version 2.1 (Language: Modula-2)');
  WriteLn;
  WriteLn;
  WriteString ('Please give the number of runs through the benchmark: ');
  ReadInt (NumberOfRuns);
  WriteLn;
  WriteString ('Execution starts, ');
  WriteInt (NumberOfRuns,7);
  WriteString (' runs through Dhrystone');
  WriteLn;
  WriteLn;

  Clock (BeginClock);

  (***************)
  (* Start timer *)
  (***************)

  FOR RunIndex := 1 TO NumberOfRuns DO

     Proc5;
     Proc4;
      (* Char1Glob = 'A', Char2Glob = 'B', BoolGlob = false *)
     Int1Glob := 2;
     Int2Glob := 3;
     String2Glob := "DHRYSTONE PROGRAM, 2'ND STRING";
     EnumGlob := Ident2;
     BoolGlob := NOT Func2 (String1Glob, String2Glob);
      (* BoolGlob = true *)
     WHILE Int1Glob < Int2Glob DO  (* loop body executed once *)
        Int3Glob := 5 * Int1Glob - Int2Glob;
         (* Int3Glob = 7 *)
        Proc7 (Int1Glob, Int2Glob, Int3Glob);
         (* Int3Glob = 7 *)
        Int1Glob := Int1Glob + 1;
     END; (* while *)
      (* Int1Glob = 3 *)
     Proc8 (Array1Glob, Array2Glob, Int1Glob, Int3Glob);
      (* IntGlob = 5 *)
     Proc1 (PointerGlob);
     FOR CharIndex := 'A' TO Char2Glob DO   (* loop body executed twice *)
        IF EnumGlob = Func1 (CharIndex, 'C') THEN
           (* not executed *)
           Proc6 (Ident1, EnumGlob);
           String2Glob := "DHRYSTONE PROGRAM, 3'RD STRING";
           Int2Glob := RunIndex;
           IntGlob := RunIndex;
        END;
     END;
      (* Int1Glob = 3, Int2Glob = 3, Int3Glob = 7 *)
     Int2Glob := Int2Glob * Int1Glob;
     Int1Glob := Int2Glob DIV Int3Glob;
     Int2Glob := 7 * (Int2Glob - Int3Glob) - Int1Glob;
      (* Int1Glob = 1, Int2Glob = 13, Int3Glob = 7 *)
     Proc2 (Int1Glob);
      (* Int1Glob = 5 *)

  END; (* for RunIndex *)

  Clock (EndClock);

  (**************)
  (* Stop timer *)
  (**************)

  WriteString ('Execution ends');
  WriteLn;
  WriteLn;
  
(*
  WriteString ('Final values of the variables used in the benchmark:');
  WriteLn;
  WriteLn;

  WriteString ('IntGlob:                      ');
  WriteInt (IntGlob, 5);
  WriteLn;
  WriteString ('        should be:                5');
  WriteLn;
  WriteString ('BoolGlob:                      ');
  IF BoolGlob = TRUE THEN
     WriteString ('TRUE'); WriteLn;
  ELSE
     WriteString ('FALSE'); WriteLn;
  END;
  WriteString ('        should be:             TRUE');
  WriteLn;
  WriteString ('Char1Glob:                        ');
  Write (Char1Glob);
  WriteLn;
  WriteString ('        should be:                A');
  WriteLn;
  WriteString ('Char2Glob:                        ');
  Write (Char2Glob);
  WriteLn;
  WriteString ('        should be:                B');
  WriteLn;
  WriteString ('Array1Glob [8]:               ');
  WriteInt (Array1Glob [8],5);
  WriteLn;
  WriteString ('        should be:                7');
  WriteLn;
  WriteString ('Array2Glob [8,7]:             ');
  WriteInt (Array2Glob [8,7],5);
  WriteLn;
  WriteString ('        should be:                NumberOfRuns + 10');
  WriteLn;
  WriteString ('PointerGlob^.Discr:           ');
  WriteInt (ORD(PointerGlob^.Discr),5);
  WriteLn;
  WriteString ('        should be:                0');
  WriteLn;
  WriteString ('PointerGlob^.EnumComp:        ');
  WriteInt (ORD(PointerGlob^.EnumComp),5);
  WriteLn;
  WriteString ('        should be:                2');
  WriteLn;
  WriteString ('PointerGlob^.IntComp  :       ');
  WriteInt (PointerGlob^.IntComp,5);
  WriteLn;
  WriteString ('        should be:               17');
  WriteLn;
  WriteString ('PointerGlob^.StringComp:     ');
  FOR I := 1 TO 30 DO
    Write (PointerGlob^.StringComp [I]);
  END;
  WriteLn;
  WriteString ('        should be:           DHRYSTONE PROGRAM, SOME STRING');
  WriteLn;
  WriteString ('NextPointerGlob^.Discr:       ');
  WriteInt (ORD(NextPointerGlob^.Discr),5);
  WriteLn;
  WriteString ('        should be:                0');
  WriteLn;
  WriteString ('NextPointerGlob^.EnumComp:    ');
  WriteInt (ORD(NextPointerGlob^.EnumComp),5);
  WriteLn;
  WriteString ('        should be:                1');
  WriteLn;
  WriteString ('NextPointerGlob^.IntComp:     ');
  WriteInt (NextPointerGlob^.IntComp,5);
  WriteLn;
  WriteString ('        should be:               18');
  WriteLn;
  WriteString ('NextPointerGlob^.StringComp: ');
  FOR I := 1 TO 30 DO
    Write (NextPointerGlob^.StringComp [I]);
  END;
  WriteLn;
  WriteString ('        should be:           DHRYSTONE PROGRAM, SOME STRING');
  WriteLn;
  WriteString ('Int1Glob:                     ');
  WriteInt (Int1Glob, 5);
  WriteLn;
  WriteString ('        should be:                5');
  WriteLn;
  WriteString ('Int2Glob:                     ');
  WriteInt (Int2Glob, 5);
  WriteLn;
  WriteString ('        should be:               13');
  WriteLn;
  WriteString ('Int3Glob:                     ');
  WriteInt (Int3Glob, 5);
  WriteLn;
  WriteString ('        should be:                7');
  WriteLn;
  WriteString ('EnumGlob:                     ');
  WriteInt (ORD(EnumGlob),5);
  WriteLn;
  WriteString ('        should be:                1');
  WriteLn;
  WriteString ('String1Glob:                 ');
  FOR I := 1 TO 30 DO
    Write (String1Glob [I]);
  END;
  WriteLn;
  WriteString ("        should be:           DHRYSTONE PROGRAM, 1'ST STRING");
  WriteLn;
  WriteString ('String2Glob:                 ');
  FOR I := 1 TO 30 DO
    Write (String2Glob [I]);
  END;
  WriteLn;
  WriteString ("        should be:           DHRYSTONE PROGRAM, 2'ND STRING");
  WriteLn;
  WriteLn;
  WriteLn;
*)

  SumClocks := EndClock - BeginClock;

  IF SumClocks < TooSmallTime THEN
     WriteString ('Measured time too small to obtain meaningful results');
     WriteLn;
     WriteString ('Please increase number of runs');
     WriteLn;
  ELSE
     Microseconds := FLOAT(SumClocks) *
                          (FLOAT(MicrosecondsPerClock) / FLOAT(NumberOfRuns));
                               (* Brackets to prevent integer overflow *)
     DhrystonesPerSecond := FLOAT (NumberOfRuns) *
                              (FLOAT(ClocksPerSecond) / FLOAT(SumClocks));
     WriteString ('Microseconds for one run through Dhrystone: ');
     WriteReal   (Microseconds,8,8);
     WriteLn;
     WriteString ('Dhrystones per Second:                      ');
     WriteReal   (DhrystonesPerSecond,8,8);
     WriteLn;
     WriteLn;
   END;
   
  WriteLn; WriteString ('Taste...'); Read (dummy)
END D_Main.
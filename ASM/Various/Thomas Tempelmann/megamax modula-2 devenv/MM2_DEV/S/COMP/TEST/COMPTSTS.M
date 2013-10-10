MODULE CRAZY;

(* Declartion is legal, but the soft~wave compiler chrashes with bus error ! *)
(* Megamax/Tempelmann Compiler is ok! *)

TYPE
  pointer  = POINTER TO pointer;
  empty    = RECORD
             END;

  crazy    = PROCEDURE(crazy): crazy;
  (*    at this point  ^  is an undefined name for TopSpeed Modula *)

BEGIN
END CRAZY.

MODULE MultiCase;

VAR
  c: CHAR;

BEGIN
  CASE c OF
  END;       (* empty case accepted by Megamax *)

  CASE c OF
   'a'..'d': |
   'c'..'e':
     (* invalid case label found by the
                  soft~wave,
                  Megamax,
                  TopSpeed
              compilers
     *)
  END;
END MultiCase.

MODULE FORupper;

FROM
  InOut IMPORT WriteString, WriteLn, Read;

  PROCEDURE Wait;
  VAR dummy: CHAR;
  BEGIN
    Read(dummy)
  END Wait;

CONST
  MaxLoops=10;

VAR
  C, loops: CARDINAL;

BEGIN
  C:=MaxLoops;
  loops:=0;
  WriteString('FOR variable in the upper limit'); WriteLn;
  FOR C:=1 TO C DO
    INC(loops);
  END;

  IF loops=MaxLoops THEN
    WriteString('OK')
  ELSE
    WriteString('Compiler error!')
  END;
  WriteLn;
  Wait
END FORupper.

MODULE IntArr;

VAR
  c : INTEGER;
  c1: ARRAY[1..1] OF INTEGER;

BEGIN
  (* This is illegal, Compiler passed the test. *)
  c1:=c;
END IntArr.

MODULE LocModule;

TYPE
  COLOR = (Red, Green, Blue);

  MODULE M1;
  IMPORT COLOR;
  EXPORT cmd;

    MODULE m2;
    IMPORT COLOR;
    EXPORT cmd;
    TYPE
      cmd = (NOP, GoUp, GoDown);
    VAR
      d: COLOR;
    BEGIN
       (* Addresse nich ansprechbar ???? *)
      d:=Blue;
    END m2;

  VAR c: COLOR;
  VAR cc: cmd;
  BEGIN
    cc:=NOP;
    c:=Red;
  END M1;

VAR
  cc: cmd;

BEGIN
  cc:=NOP;
  (* local Export/Import is OK *)
END LocModule.

MODULE PtrArith;

FROM InOut IMPORT WriteCard, WriteLn;

VAR
  p: POINTER TO INTEGER;

BEGIN
  p:=NIL;
  INC(p)
  (* hier liefert soft~wave Modula 2, da TSIZE(INTEGER)=2 ist!
     Diese Konvention finde ich besser als bei Megamax *)
  ;
  WriteCard(LONGCARD(p), 16); WriteLn;
END PtrArith.

MODULE ShrtBool;

FROM InOut IMPORT WriteString, WriteLn;

  PROCEDURE P(Res, OK: BOOLEAN): BOOLEAN;
  BEGIN
    IF OK THEN
      WriteString('OK')
    ELSE
      WriteString('Compiler error!!!')
    END;
    WriteLn;
    RETURN Res;
  END P;

BEGIN
  WriteString('Short circuit boolean evaluation test'); WriteLn;
  IF P(FALSE, TRUE) AND P(TRUE, FALSE) THEN
  END;
  IF P(TRUE, TRUE) OR P(FALSE, FALSE) THEN
  END;
END ShrtBool.

MODULE SubRange;

FROM
  InOut IMPORT WriteInt;

TYPE
  Positiv = INTEGER[0..32767];

VAR
  I: Positiv;

BEGIN
  (* FOR loop ist legal, der Megamax Compiler erzeugt falsches Range-Check
     code!
     TopSpeed Modula OK.
     Turbo Pascal 5.0 meldet range-check schon beim Compilieren!
  *)

  FOR I:=0 TO -1 DO
    WriteInt(I, 10);
  END

END SubRange.

MODULE FORcard;

CONST
  LargeCard= MAX(CARDINAL)-1;

VAR
  C: CARDINAL;

BEGIN
  (*  Siehe Wirth Ý9.8 FOR-Anweisung : BY muž INTEGER oder CARDINAL-Konstante
     sein! *)
  FOR C:=0 TO MAX(CARDINAL) BY LargeCard DO
  END
END FORcard.

MODULE ProcVar2;

VAR
  p: PROC;

  PROCEDURE Q;

    PROCEDURE E;
    BEGIN
    END E;

  BEGIN
    (* Error Msg is OK! *)
    p:=E;
  END Q;

BEGIN
  p();
END ProcVar2.

MODULE FORtest;

FROM
  InOut IMPORT WriteCard,WriteLn,WriteString,Read;

VAR
  C, loops: CARDINAL;

  PROCEDURE Result(Res: BOOLEAN);
  VAR
    dummy: CHAR;
  BEGIN
    IF Res THEN
      WriteString('OK')
    ELSE
      WriteString('Compiler Error')
    END;
    Read(dummy)
  END Result;

BEGIN
  loops:=0;
  WriteString('FOR loop counter overflow test'); WriteLn;
  FOR C:=0 TO MAX(CARDINAL) BY MAX(INTEGER) DO
    INC(loops);
    WriteCard(C,10); WriteLn
  END;
  Result(loops=3);
END FORtest.
MODULE SelfRef;

TYPE
  (* illegal, soft~wave compiler: crash;
              Megamax           : error msg (OK)
              TopSpeed          : error msg (OK) *)
  rec = rec;

BEGIN
END SelfRef.

MODULE NonLocal;

CONST
  a=1;

  PROCEDURE P();
  CONST
    a1=a;
  (* following Pascal or Modula compiler dosn't find this error:
      UCSD Pascal II.1 - IV.2
      MT +
      Turbo Pascal MSDOS
      Gepard Modula
      IBM Pascal/V
      Megamax Modula
      ...
     Compiler signals the error:
      soft~wave
   *)
    a =2;
  BEGIN
  END P;

BEGIN
END NonLocal.

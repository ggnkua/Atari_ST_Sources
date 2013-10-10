MODULE RealError;

(*
 * Testet diverse Real-Exceptions
 *)

IMPORT GEMDOSIO; (*$E MOS *)
FROM InOut IMPORT Write, WriteString, Read, WriteLn;
FROM EasyExceptions IMPORT Call, Exception, StdErrNo;
FROM HdlError IMPORT GetErrorMsg;
FROM Strings IMPORT Space, String;
IMPORT MathLib0;


PROCEDURE teste (p: PROC; soll: ARRAY OF CHAR);

  VAR s: String; result: Exception;

  BEGIN
    Call (p, result);
    WriteString (soll);
    WriteString (Space (20-LENGTH(soll)));
    WriteString (' -- ');
    GetErrorMsg (StdErrNo (result), s);
    WriteString (s);
    WriteLn;
  END teste;

VAR r1, r2: REAL;

PROCEDURE a;
  BEGIN
    r1:= 0.;
    r2:= 1.;
    r2:= r2 / r1
  END a;

PROCEDURE b;
  BEGIN
    r1:= 0.;
    r2:= r1 / r1
  END b;

PROCEDURE c;
  BEGIN
    r1:= 2.;
    LOOP
      r1:= r1 * r1
    END
  END c;

PROCEDURE d;
  BEGIN
    r1:= MathLib0.ld(0.);
  END d;

PROCEDURE e;
  BEGIN
    r1:= MathLib0.ld(0.);
  END e;

BEGIN
  teste (a, 'DIV BY 0');
  teste (b, 'Ill. Ops');
  teste (c, 'Overflow');
  teste (d, 'OutOfRange');
END RealError.

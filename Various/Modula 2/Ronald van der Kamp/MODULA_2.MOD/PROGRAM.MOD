IMPLEMENTATION MODULE Program;
IMPORT GEMX, GEMDOS, AESForms;
FROM SYSTEM IMPORT ADDRESS,REGISTER,SETREG,CODE;

FROM Strings IMPORT String,Concat;
FROM M2Conversions IMPORT ConvertInteger,ConvertAddrHex;

CONST lastShutDowner = 128;
  D0 = 0 ; D1 = 1 ; (* modula reg numbers *)
  trap1 = 4E41h; (* TRAP #1 *)
  cleard0 = 7000h ; (* MOVEQ.L #0.D0  *)
  stackd1 = 2F01h ; (* MOVE.L D1,-(SP) = *)
  stackfunctionnumber = 3F3Ch ; (* MOVE.W #xxxx,-(SP) *)

(* from Definition:
VAR oldErrorProcessor : GEMX.ErrorProcessorType;
*)

VAR nrShutDowners : INTEGER;
    ShutDowner    : ARRAY[0..lastShutDowner] OF ShutDownProc;

PROCEDURE RunTimeErrorHandler;
VAR s,s1,s2,dest : String;
BEGIN
  SimpleAlert('RUNTIME ERROR !|Re-boot if no further|messages appear');
  ConvertInteger(GEMX.ErrorContext.Error,4,s);
  ConvertAddrHex(GEMX.ErrorContext.PC - ADDRESS(RunTimeErrorHandler),8,s2);
  Concat('ERROR # ',s,s1); Concat(s1,' at Offset ',s); Concat(s,s2,dest);
  FatalError(dest);
END RunTimeErrorHandler;

PROCEDURE Halt();
VAR dummy : BOOLEAN;
BEGIN dummy := GEMDOS.Term(0) END Halt;

PROCEDURE AddShutDowner(formal : ShutDownProc);
BEGIN
  IF nrShutDowners > lastShutDowner THEN
    formal();
    FatalError("Increase lastShutDowner in module 'Program' ");
  END;
  ShutDowner[nrShutDowners] := formal;
  INC(nrShutDowners);
END AddShutDowner;


PROCEDURE NormalExit;
VAR i : INTEGER;
BEGIN
  FOR i := 0 TO nrShutDowners-1 DO
    ShutDowner[nrShutDowners-1-i]()
  END;
  Halt;
END NormalExit;

PROCEDURE FatalError( VAR s : ARRAY OF CHAR);
VAR dummy : INTEGER; as : String;
BEGIN
  Concat("[3][FATAL ERROR|",s,as); Concat(as,"][BAH]",as);
  dummy := AESForms.FormAlert(1,as);
  NormalExit;
END FatalError;

PROCEDURE SimpleAlert( VAR s : ARRAY OF CHAR);
VAR as : String; dummy : INTEGER;
BEGIN
  Concat("[1][",s,as); Concat(as,"][BAH]",as);
  dummy := AESForms.FormAlert(1,as);
END SimpleAlert;

PROCEDURE Mode ( stack : ADDRESS ) : ADDRESS ;
BEGIN
  CODE(cleard0);
  SETREG(D1,stack);
  CODE(stackd1);
  CODE(stackfunctionnumber,20h);
  CODE(trap1);
  RETURN REGISTER (D0);
END Mode;

BEGIN (* init actions of Program *)
  nrShutDowners := 0;
  oldErrorProcessor := GEMX.ErrorProcessor ;
  GEMX.ErrorProcessor := RunTimeErrorHandler;
END Program.


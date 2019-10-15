(* Weitere Elemente der DOS-Bibliothek *)

PROGRAM Demo4E;

USES DOS;

VAR i:INTEGER;
	VerifyStatus,Breakstatus:BOOLEAN;

BEGIN
WRITELN('TOS/DOS-Version ',HI(Dosversion),'.',LO(Dosversion));
IF EnvCount>0 THEN
	BEGIN
	WRITELN('Environment:');
	FOR i:=1 TO EnvCount DO WRITELN(EnvStr(i));
	END;
WRITELN;
WRITELN('Environmentvariable PATH = "',GetEnv('PATH'),'"');
WRITELN;
GetCBreak(BreakStatus);
WRITE('Breakm”glichkeit: ');
IF BreakStatus THEN WRITELN('Ja') ELSE WRITELN('Nein');
GetVerify(VerifyStatus);
WRITE('Schreib-Verify: ');
IF VerifyStatus THEN WRITELN('Ja') ELSE WRITELN('Nein');
END.

(* Verwendung des abstrakten Datentyps *)

PROGRAM Demo3G;

USES Abstrakt; (* Verwende den Abstrakten Datentyp *)

VAR Lifo:ARRAY [1..4] OF POINTER; (* Vier Stapel *)
	i,j:INTEGER;
	

BEGIN
FOR j:=1 TO 4 DO
	BEGIN
	Init(Lifo[j]);
	FOR i:=j TO j*2 DO Push(Lifo[j],i);
	END;
FOR j:=1 TO 4 DO
	BEGIN
	WRITELN('Stapel ',j,':');
	WRITELN;
	WHILE NOT Empty(Lifo[j]) DO
		WRITELN(Pop(Lifo[j]));
	WRITELN;
	END;
END.
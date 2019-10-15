(* Rekursive Fakult„tsberechnung unter Pure Pascal *)

PROGRAM Fakultaet;

FUNCTION fak(n:INTEGER):INTEGER;
BEGIN
IF n<=1	THEN fak:=1
		ELSE fak:=fak(n-1)*n;
END;

BEGIN
WRITELN('Fak(4)=',fak(4));
END.


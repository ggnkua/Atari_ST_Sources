(* Demomodul zum abstrakten Datentyp, von Frank Mathy, TOS 02/92 *)

MODULE TestLifo;

FROM InOut IMPORT WriteString,WriteLn;
FROM Lifo IMPORT Lifo,InitLifo,EmptyLifo,Push,Pop,Name;

VAR Stapel1,Stapel2:Lifo;
    n:Name;

BEGIN
InitLifo(Stapel1);
InitLifo(Stapel2);
Push(Stapel1,'Stapel 1 Wert 1');
Push(Stapel1,'Stapel 1 Wert 2');
Push(Stapel1,'Stapel 1 Wert 3');
Push(Stapel2,'Stapel 2 Wert 1');
Push(Stapel2,'Stapel 2 Wert 2');
WHILE (NOT EmptyLifo(Stapel1)) OR (NOT EmptyLifo(Stapel2)) DO
   IF NOT EmptyLifo(Stapel1) THEN
      Pop(Stapel1,n);
      WriteString(n); WriteLn;
      END; (* IF *)
   IF NOT EmptyLifo(Stapel2) THEN
      Pop(Stapel2,n);
      WriteString(n); WriteLn;
      END; (* IF *)
   END; (* WHILE *)
END TestLifo.

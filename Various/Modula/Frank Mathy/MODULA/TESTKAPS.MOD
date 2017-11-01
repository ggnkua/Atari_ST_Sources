(* Demomodul zur Datenkapsel, von Frank Mathy, TOS 02/92 *)

MODULE TestKapsel;

FROM InOut IMPORT WriteString,WriteLn;
FROM LifoKapsel IMPORT InitLifo,EmptyLifo,Push,Pop,Name;

VAR n:Name;

BEGIN
InitLifo;
Push('Wert 1');
Push('Wert 2');
Push('Wert 3');
WHILE NOT EmptyLifo() DO
   Pop(n);
   WriteString(n); WriteLn;
   END; (* WHILE *)
END TestKapsel.

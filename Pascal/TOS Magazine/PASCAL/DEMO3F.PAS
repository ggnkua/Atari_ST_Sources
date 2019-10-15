(* Verwendung des abstrakten Datentyps *)

PROGRAM Demo3F;

USES LifoUnit; (* Verwende den LIFO-Unit *)

VAR i:INTEGER;

BEGIN
FOR i:=1 TO 10 DO Push(i);
WHILE NOT Empty DO WRITELN(Pop);
END.
PROGRAM OopDemo1;

(* Die Definition des Objekts ZAEHLER *)
TYPE	Zaehler	=	OBJECT
						N	: INTEGER;
						PROCEDURE Init(NewN : INTEGER);
						PROCEDURE Up;
						PROCEDURE Down;
						PROCEDURE Show;
					END;

PROCEDURE Zaehler.Init(NewN : INTEGER);
BEGIN
	N	:= NewN
END;

PROCEDURE Zaehler.Up;
BEGIN
	INC(N)
END;

PROCEDURE Zaehler.Down;
BEGIN
	DEC(N)
END;

PROCEDURE Zaehler.Show;
BEGIN
	WRITELN(N)
END;

(* Hier das eigentliche Programm - ohne Definition *)
VAR	MyInstance	: Zaehler;

BEGIN
	MyInstance.Init(0);
	MyInstance.Show;
	MyInstance.Up;
	MyInstance.Show;
	MyInstance.Down;
	MyInstance.Down;
	MyInstance.Show
END.
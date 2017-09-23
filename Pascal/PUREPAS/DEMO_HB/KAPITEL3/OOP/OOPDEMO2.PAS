PROGRAM OopDemo2;

(* Die Definition des Objekts ZAEHLER *)
TYPE	Zaehler		=	OBJECT
							N	: INTEGER;
							PROCEDURE Init(NewN : INTEGER);
							PROCEDURE Up;
							PROCEDURE Down;
							PROCEDURE Show;
						END;
		AbZaehler	=	OBJECT(Zaehler)
							PROCEDURE Click;
						END;
		AufZaehler	=	OBJECT(Zaehler)
							PROCEDURE Click;
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

PROCEDURE AbZaehler.Click;
BEGIN
	Up
END;

PROCEDURE AufZaehler.Click;
BEGIN
	Down
END;

(* Hier das eigentliche Programm - ohne Definition *)
VAR	ZAb		: AbZaehler;
	ZAuf	: AufZaehler;

BEGIN
	ZAb.Init(0);
	ZAuf.Init(0);
	ZAb.Click;
	ZAb.Show;
	ZAb.Click;
	ZAb.Show;
	ZAuf.Click;
	ZAuf.Show;
	ZAuf.Click;
	ZAuf.Show
END.
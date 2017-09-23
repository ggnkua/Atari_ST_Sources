PROGRAM Rechteck;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(TurtleGeom)
								PROCEDURE Quadrat(Seite : INTEGER);
								PROCEDURE Muster(Seite : INTEGER);
							END;

PROCEDURE TurtleGraphik.Quadrat(Seite : INTEGER);
BEGIN
	Rectangle(Seite, Seite)
END;

PROCEDURE TurtleGraphik.Muster(Seite : INTEGER);
CONST	DiffWinkel	= 5;
VAR		i, iMax	: INTEGER;
BEGIN
	i		:= 0;
	iMax	:= 90 DIV DiffWinkel;
	REPEAT
		Quadrat(Seite);
		Left(DiffWinkel);
		INC(i)
	UNTIL	i = iMax
END;

VAR	MyTurtle	: TurtleGraphik;
	Seite		: INTEGER;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Hide;
		Seite	:= 1000;
		REPEAT
			MyTurtle.Muster(Seite);
			DEC(Seite, 100)
		UNTIL Seite = 0;
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
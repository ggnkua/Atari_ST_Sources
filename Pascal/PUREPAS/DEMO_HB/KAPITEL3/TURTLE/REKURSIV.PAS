PROGRAM Rekursiv;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(TurtleGeom)
								PROCEDURE Quadrat(Seite : INTEGER);
								PROCEDURE Rekursiv(Grad : WORD; Seite : INTEGER);
							END;

PROCEDURE TurtleGraphik.Quadrat(Seite : INTEGER);
BEGIN
	Rectangle(Seite, Seite)
END;

PROCEDURE TurtleGraphik.Rekursiv(Grad : WORD; Seite : INTEGER);
BEGIN
	IF Grad > 0 THEN
	BEGIN
		Quadrat(Seite);
		SELF.Rekursiv(Grad - 1, Seite DIV 2)
	END
END;

VAR	MyTurtle	: TurtleGraphik;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Hide;
		MyTurtle.Rekursiv(5, 1500);
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
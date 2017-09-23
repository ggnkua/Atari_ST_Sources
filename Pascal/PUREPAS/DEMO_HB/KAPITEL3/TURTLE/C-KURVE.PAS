PROGRAM CKurve;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(Turtle)
								PROCEDURE CKurve(Grad, Seite : WORD);
							END;

PROCEDURE TurtleGraphik.CKurve(Grad, Seite : WORD);
BEGIN
	IF Grad = 0 THEN
		Forward(Seite)
	ELSE
	BEGIN
		DEC(Grad);
		SELF.CKurve(Grad, Seite);
		Left(90);
		SELF.CKurve(Grad, Seite);
		Right(90)
	END
END;

VAR	MyTurtle	: TurtleGraphik;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Default(250, -250, 0);
		MyTurtle.Hide;
		MyTurtle.CKurve(12, 12);
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
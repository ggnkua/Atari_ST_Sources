PROGRAM Sierpinski;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(Turtle)
								PROCEDURE Sierpinski(Grad, Seite : WORD);
							END;

PROCEDURE TurtleGraphik.Sierpinski(Grad, Seite : WORD);
VAR	i	: WORD;
	PROCEDURE Kern(Grad, Seite : WORD);
	VAR	Seite2	: WORD;
	BEGIN
		IF Grad > 0 THEN
		BEGIN
			DEC(Grad);
			Seite2	:= ROUND(Seite * SQRT(2.0));
			Kern(Grad, Seite);
			Right(135);
			Forward(Seite);
			Left(45);
			Kern(Grad, Seite);
			Forward(Seite2);
			Left(180);
			Kern(Grad, Seite);
			Right(135);
			Forward(Seite);
			Left(45);
			Kern(Grad, Seite)
		END
	END;
BEGIN
	FOR i:=1 TO 4 DO
	BEGIN
		Kern(Grad, Seite);
		Right(135);
		Forward(Seite);
		Left(45)
	END
END;

VAR	MyTurtle	: TurtleGraphik;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Default(-975, 975, 90);
		MyTurtle.Hide;
		MyTurtle.Sierpinski(6, 10);
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
PROGRAM Hilbert;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(Turtle)
								PROCEDURE Hilbert(Grad, Seite : WORD; r : BOOLEAN);
							END;

PROCEDURE TurtleGraphik.Hilbert(Grad, Seite : WORD; r : BOOLEAN);
VAR	Richtung	: INTEGER;
BEGIN
	IF Grad > 0 THEN
	BEGIN
		IF r THEN
			Richtung	:= 1
		ELSE
			Richtung	:= -1;
		DEC(Grad);
		Turn(-Richtung * 90);
		SELF.Hilbert(Grad, Seite, NOT(r));
		Forward(Seite);
		Turn(Richtung * 90);
		SELF.Hilbert(Grad, Seite, r);
		Forward(Seite);
		SELF.Hilbert(Grad, Seite, r);
		Turn(Richtung * 90);
		Forward(Seite);
		SELF.Hilbert(Grad, Seite, NOT(r));
		Turn(-Richtung * 90)
	END
END;

VAR	MyTurtle	: TurtleGraphik;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Default(-975, -975, 90);
		MyTurtle.Hide;
		MyTurtle.Hilbert(6, 25, TRUE);
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
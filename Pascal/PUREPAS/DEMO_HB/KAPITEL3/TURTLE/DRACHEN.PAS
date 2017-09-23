PROGRAM Drachen;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(Turtle)
								PROCEDURE Drachen(Grad : INTEGER; Seite : WORD);
							END;

PROCEDURE TurtleGraphik.Drachen(Grad : INTEGER; Seite : WORD);
BEGIN
	IF Grad = 0 THEN
		Forward(Seite)
	ELSE
	BEGIN
		IF Grad > 0 THEN
		BEGIN
			SELF.Drachen(Grad - 1, Seite);
			Left(90);
			SELF.Drachen(1 - Grad, Seite)
		END
		ELSE
		BEGIN
			SELF.Drachen(-Grad - 1, Seite);
			Right(90);
			SELF.Drachen(Grad + 1, Seite)
		END
	END
END;

VAR	MyTurtle	: TurtleGraphik;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Hide;
		MyTurtle.Drachen(13, 8);
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
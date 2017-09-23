PROGRAM Koch;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(Turtle)
								PROCEDURE Koch(Grad, Seite : WORD);
							END;

PROCEDURE TurtleGraphik.Koch(Grad, Seite : WORD);
VAR	NeuSeite	: WORD;
BEGIN
	IF Grad = 0 THEN
		Forward(Seite)
	ELSE
	BEGIN
		DEC(Grad);
		NeuSeite	:= Seite DIV 3;
		SELF.Koch(Grad, NeuSeite);
		Right(60);
		SELF.Koch(Grad, NeuSeite);
		Left(120);
		SELF.Koch(Grad, NeuSeite);
		Right(60);
		SELF.Koch(Grad, NeuSeite)		
	END
END;

VAR	MyTurtle	: TurtleGraphik;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Default(975, 0, 180);
		MyTurtle.Hide;
		MyTurtle.Koch(4, 2000);
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
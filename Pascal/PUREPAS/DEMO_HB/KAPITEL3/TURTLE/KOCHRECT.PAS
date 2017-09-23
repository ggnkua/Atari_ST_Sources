PROGRAM KochRechteck;

USES Turtles;

TYPE	TurtleGraphik	=	OBJECT(Turtle)
								PROCEDURE KochRechteck(Grad, Seite : WORD);
							END;

PROCEDURE TurtleGraphik.KochRechteck(Grad, Seite : WORD);
VAR	NeuSeite	: WORD;
BEGIN
	IF Grad = 0 THEN
		Forward(Seite)
	ELSE
	BEGIN
		DEC(Grad);
		NeuSeite	:= Seite DIV 3;
		SELF.KochRechteck(Grad, NeuSeite);
		Right(90);
		SELF.KochRechteck(Grad, NeuSeite);
		Left(90);
		SELF.KochRechteck(Grad, NeuSeite);
		Left(90);
		SELF.KochRechteck(Grad, NeuSeite);
		Right(90);
		SELF.KochRechteck(Grad, NeuSeite)		
	END
END;

VAR	MyTurtle	: TurtleGraphik;

BEGIN
	MyTurtle.Init;
	IF NOT(MyTurtle.Error) THEN
	BEGIN
		MyTurtle.Default(975, 0, 180);
		MyTurtle.Hide;
		MyTurtle.KochRechteck(4, 2000);
		MyTurtle.Show;
		MyTurtle.Done
	END
END.
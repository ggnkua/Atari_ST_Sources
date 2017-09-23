PROGRAM Example;

VAR	MyMessage	: STRING;

	FUNCTION Fkt : String;
	BEGIN
		Fkt := 'Hello World!'
	END;

BEGIN
	MyMessage := Fkt;
	WRITELN(MyMessage)
END.

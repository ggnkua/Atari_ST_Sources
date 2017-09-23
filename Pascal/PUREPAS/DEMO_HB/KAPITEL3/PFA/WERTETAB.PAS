PROGRAM Wertetabellen;

TYPE	MyFunction = FUNCTION(x : INTEGER) : INTEGER;

VAR	FktVar : MyFunction;

	FUNCTION f(x : INTEGER) : INTEGER;
	BEGIN
		f := x
	END;

	FUNCTION g(x : INTEGER) : INTEGER;
	BEGIN
		g := x * x
	END;

	FUNCTION h(x : INTEGER) : INTEGER;
	BEGIN
		h := x * x * x
	END;

	PROCEDURE Tabelle(min, max : INTEGER; fkt : MyFunction);
	VAR	x : INTEGER;
	BEGIN
		FOR x:=min TO max DO
		BEGIN
			WRITELN(x, ' ', fkt(x))
		END
	END;

BEGIN
	Tabelle(1, 10, f);
	Tabelle(2, 5, g);
	Tabelle(-4, 8, h);

	(* und einmal mit Variable *)
	FktVar := f;
	Tabelle(7,46, FktVar)
END.

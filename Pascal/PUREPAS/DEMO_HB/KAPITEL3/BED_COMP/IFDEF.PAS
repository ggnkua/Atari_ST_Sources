PROGRAM IfDef;

BEGIN
	{$IFDEF DEMO}
	WRITELN('Dieses ist das Demo!');
	{$ENDIF}

	WRITELN('Hello World.');

	{$IFDEF DEMO}
	WRITELN('Das Ende des Demos.')
	{$ELSE}
	WRITELN('Das Ende.')
	{$ENDIF}
END.

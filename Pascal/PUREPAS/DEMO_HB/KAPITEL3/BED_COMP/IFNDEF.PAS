PROGRAM IfNDef;

{$DEFINE MyProgram}

BEGIN
	{$IFNDEF YourProgram}
	WRITE('Hello ');
	{$ENDIF}

	WRITELN('World!')
END.
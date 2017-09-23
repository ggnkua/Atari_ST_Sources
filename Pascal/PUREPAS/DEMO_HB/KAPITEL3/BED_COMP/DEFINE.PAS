PROGRAM Define;

{$DEFINE MySymbol}

BEGIN
	{$IFDEF MySymbol}
	WRITELN('Hello World!');
	{$ENDIF}

	{$UNDEF MySymbol}

	{$IFDEF MySymbol}
	WRITELN('Good Bye World!');
	{$ENDIF}
END.

PROGRAM IfOpt;

CONST
{$IFOPT R+}	RangeCheck	= 'on';
{$ELSE}		RangeCheck	= 'off';
{$ENDIF}

BEGIN
	WRITELN('RangeChecking is ', RangeCheck, '.')
END.
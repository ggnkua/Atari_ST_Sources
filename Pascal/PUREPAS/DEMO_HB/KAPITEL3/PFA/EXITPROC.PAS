PROGRAM Exit_Proc;

VAR	OldProc	: POINTER;

	PROCEDURE MyExitProc;
	BEGIN
		WRITELN('Good bye, World!');
		EXITPROC	:= OldProc
	END;

	PROCEDURE InitExitProc;
	BEGIN
		OldProc		:= EXITPROC;
		EXITPROC	:= @MyExitProc
	END;

BEGIN
	InitExitProc;
	WRITELN('Nun kann passieren, was will.')
END.

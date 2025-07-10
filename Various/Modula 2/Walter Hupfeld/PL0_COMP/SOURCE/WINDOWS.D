DEFINITION MODULE Windows;

FROM TextWindows IMPORT Window;

VAR Done : BOOLEAN;

PROCEDURE OpenTextWindow(VAR u:Window; x,y,w,h:CARDINAL;name:ARRAY OF CHAR);

PROCEDURE CloseTextWindow(u:Window);

PROCEDURE Write(u:Window;ch:CHAR);

PROCEDURE WriteCard(u:Window;x,n:CARDINAL);

PROCEDURE Invert(u:Window;on:BOOLEAN);

PROCEDURE WriteLn(u:Window);

PROCEDURE WriteString(u:Window; a:ARRAY OF CHAR);

PROCEDURE ReadInt(u:Window;VAR x:INTEGER);

PROCEDURE WriteInt(u:Window;x:INTEGER;n:CARDINAL);

PROCEDURE Read(u:Window;ch:CHAR);

END Windows.


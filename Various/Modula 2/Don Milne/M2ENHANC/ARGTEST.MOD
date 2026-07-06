MODULE EchoArgs;

FROM Terminal IMPORT WriteString,WriteLn;
FROM ArgHandler IMPORT argc,argv;

VAR i:CARDINAL;

BEGIN
     FOR i:=0 TO argc DO
         WriteString(argv[i]^); WriteLn;
     END;
END EchoArgs.

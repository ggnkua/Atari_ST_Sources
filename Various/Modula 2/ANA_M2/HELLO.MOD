MODULE Hello;

FROM InOut IMPORT WriteString, WriteLn, Read;

VAR dummy:CHAR;

BEGIN
 WriteString("Hello Modula-Fan !!!"); WriteLn;
 Read(dummy);
END Hello.

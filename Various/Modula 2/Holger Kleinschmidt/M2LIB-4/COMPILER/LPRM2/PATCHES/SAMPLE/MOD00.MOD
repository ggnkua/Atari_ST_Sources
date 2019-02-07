MODULE mod00;

FROM LPRTERMINATION IMPORT InstallTerm, TermRec, SetTermResult;
FROM Terminal IMPORT Read, WriteString, WriteLn;
IMPORT mod1;
IMPORT System;

VAR ch   : CHAR;
    term : TermRec;
    c1,c2:INTEGER;

PROCEDURE Terminator;
BEGIN
 WriteLn;
 WriteString("--- Modul 0: Bye, Bye"); WriteLn;
 Read(ch);
END Terminator;

BEGIN
 InstallTerm(term, Terminator);
 WriteString("+++ Modul 0: Terminierungsprozedur installiert"); WriteLn;
END mod00.

IMPLEMENTATION MODULE mod1;

FROM LPRTERMINATION IMPORT InstallTerm, TermRec, SetTermResult;
FROM Terminal IMPORT Read, WriteString, WriteLn;
IMPORT mod2;

VAR ch   : CHAR;
    term : TermRec;

PROCEDURE Terminator;
BEGIN
 WriteString("--- Modul 1: Bye, Bye"); WriteLn;
 Read(ch);
END Terminator;

BEGIN
 InstallTerm(term, Terminator);
 WriteString("+++ Modul 1: Terminierungsprozedur installiert"); WriteLn;
END mod1.

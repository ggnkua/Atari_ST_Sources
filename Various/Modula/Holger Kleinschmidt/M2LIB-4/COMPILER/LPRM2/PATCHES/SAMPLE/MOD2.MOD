IMPLEMENTATION MODULE mod2;

FROM LPRTERMINATION IMPORT InstallTerm, TermRec, SetTermResult;
FROM Terminal IMPORT Read, WriteString, WriteLn;

VAR ch   : CHAR;
    term : TermRec;

PROCEDURE Terminator;
BEGIN
 WriteString("--- Modul 2: Bye, Bye"); WriteLn;
 Read(ch);
END Terminator;

BEGIN
 InstallTerm(term, Terminator);
 WriteString("+++ Modul 2: Terminierungsprozedur installiert"); WriteLn;
END mod2.

MODULE PL0;

FROM FileSystem IMPORT Lookup, Response,res, Close;

FROM TextWindows IMPORT Window,BusyRead,KeyPressed;

FROM Windows IMPORT OpenTextWindow, Write, WriteLn, WriteString, 
                    CloseTextWindow,Read;
                        
FROM PL0Scanner IMPORT InitScanner, source, CloseScanner;

FROM PL0Parser IMPORT Parse, noerr, EndParser;

FROM PL0Generator IMPORT InitGenerator, EndGenerator;

FROM PL0Interpreter IMPORT Interpret, EndInterpreter;


CONST 
  FLength = 13;
  ESC = 33C;
  DEL = 177C;
   
VAR
  ch : CHAR;
  win : Window;
  FileName : ARRAY [0..FLength] OF CHAR;
  

PROCEDURE ReadName;
VAR
  i : CARDINAL;
BEGIN
  REPEAT UNTIL KeyPressed(); BusyRead(ch);
  FileName := "";
  i := 0;
  WHILE ((CAP(ch)>="A") & (CAP(ch)<="Z")) OR
        ((ch>="0") & (ch<="9")) OR
        (ch=".") OR (ch=DEL) DO
    IF ch=DEL THEN
       IF i>1 THEN Write(win,DEL);
          DEC(i);
       END;
    ELSIF i<FLength THEN
       Write(win,ch);
       FileName[i] := ch;
       INC(i);
    END;
    REPEAT UNTIL KeyPressed(); BusyRead(ch);
  END;
  IF (3<i) AND (i<FLength) AND (FileName[i-1]=".") THEN
     FileName[i] := "P"; INC(i);
     FileName[i] := "L"; INC(i);
     FileName[i] := "0"; INC(i);
     WriteString(win,"PL0");
  END;
  FileName[i] := CHR(0);
END ReadName;


BEGIN
  OpenTextWindow(win,1,3,25,8,"DIALOG");
  LOOP 
    WriteString(win,"in> ");
    ReadName;
    IF ch=ESC THEN EXIT; END;
    Lookup(source,FileName,FALSE);
    IF res = done THEN
       InitScanner;
       InitGenerator;
       Parse;
       Close(source);
       IF noerr THEN
          WriteString(win," interpreting");
          Interpret;
       ELSE
          WriteString(win," incorrect");
       END;
    ELSE
       WriteString(win, " not found");
    END;
    WriteLn(win);
  END;
  CloseScanner;
  EndParser;
  EndGenerator;
  EndInterpreter;
  CloseTextWindow(win);
END PL0.

   

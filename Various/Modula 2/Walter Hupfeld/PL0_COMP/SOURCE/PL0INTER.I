IMPLEMENTATION MODULE PL0Interpreter;

FROM TextWindows IMPORT Window,WritePg;
FROM Windows     IMPORT Done, OpenTextWindow, ReadInt, Write,
                        WriteLn, WriteInt, Invert, CloseTextWindow;


VAR
  win : Window;
  

PROCEDURE Interpret;
CONST 
  stacksize = 1000;
  
VAR
  p,b,t : INTEGER;
  i : Instruction;
  s : ARRAY [0..stacksize-1] OF INTEGER;
  

  PROCEDURE base(l : INTEGER) : INTEGER;
  VAR
    b1 : INTEGER;
    
  BEGIN
    b1 := b;
    WHILE l>0 DO
      b1 := s[b1];
      DEC(l);
    END;
    RETURN b1;  
  END base;
  

BEGIN
  WritePg(win);
  t := 0;
  b := 1;
  p := 0;
  s[1] := 0;
  s[2] := 0;
  s[3] := 0;
  REPEAT
    i := code[p];
    INC(p);
    WITH i DO
      CASE f OF
        0 : INC(t);
            s[t] := a;                          |
        1 : CASE a OF
              0 : t := b - 1;
                  p := s[t+3];
                  b := s[t+2];                        |   
              1 : s[t] := -s[t];                      |
              2 : DEC(t);
                  s[t] := s[t] + s[t+1];              |
              3 : DEC(t);
                  s[t] := s[t] - s[t+1];              |
              4 : DEC(t);
                  s[t] := s[t] * s[t+1];              |
              5 : DEC(t);
                  s[t] := s[t] DIV s[t+1];            |
              6 : s[t] := ORD(ODD(s[t]));             |
              7 : |
              8 : DEC(t);
                  s[t] := ORD(s[t]=s[t+1]);           |
              9 : DEC(t);
                  s[t] := ORD(s[t] # s[t+1]);         |
             10 : DEC(t);
                  s[t] := ORD(s[t] < s[t+1]);         |
             11 : DEC(t);
                  s[t] := ORD(s[t] >= s[t+1]);        |
             12 : DEC(t);
                  s[t] := ORD(s[t] > s[t+1]);         |
             13 : DEC(t);
                  s[t] := ORD(s[t] <= s[t+1]);        |
             14 : INC(t);
                  Write(win,">");
                  Invert(win,TRUE);
                  ReadInt(win,s[t]);
                  IF NOT Done THEN
                     p := 0;
                  END;
                  Invert(win,FALSE);                  |
             15 : WriteInt(win,s[t],7);
                  WriteLn(win);
                  DEC(t);                             |
            END;                                        |
        2 : INC(t);   
            s[t] := s[base(l)+INTEGER(a)];              |
        3 : s[base(l)+INTEGER(a)] := s[t];
            DEC(t);                                     |
        4 : s[t+1] := base(l);
            s[t+2] := b;
            s[t+3] := p;
            b := t + 1;
            p := a;                                     |
        5 : t := t + INTEGER(a);                        |
        6 : p := a;                                     |
        7 : IF s[t]=0 THEN
               p := a;
            END;
            DEC(t);                                     |
      END;
    END;
  UNTIL p=0;
END Interpret;


PROCEDURE EndInterpreter;
BEGIN
  CloseTextWindow(win);
END EndInterpreter;


BEGIN
  OpenTextWindow(win,54,13,25,12,"RESULT");
END PL0Interpreter.

  
            
        

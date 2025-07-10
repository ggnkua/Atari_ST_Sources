

IMPLEMENTATION MODULE PL0Generator;

FROM TextWindows IMPORT Window,WritePg;
FROM Windows IMPORT OpenTextWindow, WriteString, Write,
                        WriteLn, WriteCard, CloseTextWindow;
                        
FROM PL0Interpreter IMPORT Instruction, maxfct, maxadr, code;

VAR
  L : CARDINAL;
  win : Window;
  mnemonic : ARRAY [0..maxfct],[0..3] OF CHAR;
  

PROCEDURE InitGenerator;
BEGIN
  L := 0;
  WritePg(win);
END InitGenerator;


PROCEDURE Label() : CARDINAL;
BEGIN
  RETURN L;
END Label;


PROCEDURE Gen(x,y,z : CARDINAL);
BEGIN
  IF L>=maxadr THEN HALT; END;
  WITH code[L] DO 
    f := x;
    l := y;
    a := z;
  END;
  WriteCard(win,L,4);
  WriteString(win,mnemonic[x]);
  WriteCard(win,y,3);
  WriteCard(win,z,6);
  WriteLn(win);
  INC(L);
END Gen;


PROCEDURE fixup(x : CARDINAL);
BEGIN
  code[x].a := L;
  WriteString(win,"fixup at");
  WriteCard(win,x,4);
  WriteLn(win);
END fixup;


PROCEDURE EndGenerator;
BEGIN
  CloseTextWindow(win);
END EndGenerator;


BEGIN
  OpenTextWindow(win,27,13,25,12,"CODE");
  mnemonic[0] := " LIT";
  mnemonic[1] := " OPR";
  mnemonic[2] := " LOD";
  mnemonic[3] := " STO";
  mnemonic[4] := " CAL";
  mnemonic[5] := " INT";
  mnemonic[6] := " JMP";
  mnemonic[7] := " JPC";
END PL0Generator.



MODULE GetLnSty;


(*
 *  Einfaches Testmodul fr Proc. 'GetLineStyle' aus 'VDIInquires'
 *
 *  Wolfgang Schmitz; Uni Wuppertal, FB 13 (Prof. G. Schauf); 24.04.91
 *)


FROM SYSTEM IMPORT ASSEMBLER;
FROM GEMEnv        IMPORT InitGem, ExitGem, RC, CurrGemHandle,
                          GemHandle, DeviceHandle;
FROM InOut         IMPORT GotoXY, WriteCard, Read, WriteLn, WriteString;
FROM GEMGlobals    IMPORT LineType, LineEnding, MarkerType;
FROM GrafBase      IMPORT WritingMode;
FROM Terminal      IMPORT GetChar;
FROM VDIInquires   IMPORT GetLineStyle, GetMarkerStyle;
FROM VDIAttributes IMPORT SetLineColor, SetLineType, SetLineEndings,
                          SetWritingMode, SetLineWidth;


VAR
  gemHandle: GemHandle;
  devHandle: DeviceHandle;
  ok: BOOLEAN;
  ch: CHAR;

  Ltyp: LineType;
  Lcolor, Lwidth: CARDINAL;
  Lmode: WritingMode;
  Lbegin, Lend: LineEnding;


BEGIN

  InitGem(RC, devHandle, ok);
  gemHandle:= CurrGemHandle();


  SetLineType(devHandle, dottedLn);
  SetLineColor(devHandle, 1);
  SetWritingMode(devHandle, transWrt);
  SetLineEndings(devHandle, arrowedLn, arrowedLn);
  SetLineWidth(devHandle, 3);



  GetLineStyle(devHandle, Ltyp, Lcolor, Lmode, Lbegin, Lend, Lwidth);



  GotoXY(0, 3);
  WriteString('            " SOLL "                " IST "');

  GotoXY(0, 5);
  WriteString('LineType:');
  GotoXY(14, 5);
  WriteCard(ORD(dottedLn), 3);   WriteCard(ORD(Ltyp),24);
  WriteString('              Weiter?  >Taste< ');   GetChar(ch);


  GotoXY(0, 7);
  WriteString('LineColor:');
  GotoXY(14, 7);
  WriteCard(1, 3);   WriteCard(Lcolor, 24);
  WriteString('              Weiter?  >Taste< ');   GetChar(ch);


  GotoXY(0, 9);
  WriteString('LineMode:');
  GotoXY(14, 9);
  WriteCard(ORD(transWrt), 3);   WriteCard(ORD(Lmode), 24);
  WriteString('              Weiter?  >Taste< ');   GetChar(ch);


  GotoXY(0, 11);
  WriteString('LineBegin:');
  GotoXY(14, 11);
  WriteCard(ORD(arrowedLn), 3);   WriteCard(ORD(Lbegin), 24);
  WriteString('              Weiter?  >Taste< ');   GetChar(ch);


  GotoXY(0, 13);
  WriteString('LineEnd:');
  GotoXY(14, 13);
  WriteCard(ORD(arrowedLn), 3);   WriteCard(ORD(Lend), 24);
  WriteString('              Weiter?  >Taste< ');   GetChar(ch);


  GotoXY(0, 15);
  WriteString('LineWidth:');
  GotoXY(14, 15);
  WriteCard(3, 3);   WriteCard(ORD(Lwidth), 24);
  WriteString('              Ende ?  >Taste< ');   GetChar(ch);



ExitGem(gemHandle);





END GetLnSty.

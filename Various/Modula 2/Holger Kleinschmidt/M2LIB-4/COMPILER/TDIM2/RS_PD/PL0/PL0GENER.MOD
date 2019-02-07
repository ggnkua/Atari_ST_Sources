IMPLEMENTATION MODULE PL0Generator;
(*$S-,$T-,$Q+*)

FROM  TextWindows    IMPORT Window, Write, WriteLn,  OpenTextWindow,
                            WriteString, WriteCard, CloseTextWindow;
FROM  PL0Interpreter IMPORT Instruction, maxfct, maxadr, code;

CONST FF = 14c; WINTITLE = " CODE ";

VAR   cL:       CARDINAL;                                 (* current label *)
      win:      Window;
      mnemonic: ARRAY [0..maxfct],[0..3] OF CHAR;

PROCEDURE InitGenerator; BEGIN cL := 0; Write (win, FF) END InitGenerator;

PROCEDURE Label (): CARDINAL; BEGIN RETURN cL END Label;

PROCEDURE Gen (x,y,z: CARDINAL);
 BEGIN IF (cL >= maxadr) THEN HALT END;
   WITH code[cL] DO f := x; l := y; a := z END;
   WriteLn   (win);
   WriteCard (win, cL, 4);
   WriteString (win, mnemonic[x]);
   WriteCard (win, y, 3);
   WriteCard (win, z, 6);
   INC (cL); END Gen;

PROCEDURE fixup (x: CARDINAL);
 BEGIN WriteLn (win); WriteString (win, "fixup at"); WriteCard (win, x, 4);
       code[x].a := cL; END fixup;

PROCEDURE OpenCodeWindow;
 BEGIN OpenTextWindow (win, {0, 6,7, 8}, 215,161, 210,155, WINTITLE);
   END OpenCodeWindow;

PROCEDURE EndGenerator; BEGIN CloseTextWindow (win) END EndGenerator;

BEGIN mnemonic[0] := " LIT";
      mnemonic[1] := " OPR";
      mnemonic[2] := " LOD";
      mnemonic[3] := " STO";
      mnemonic[4] := " CAL";
      mnemonic[5] := " INT";
      mnemonic[6] := " JMP";
      mnemonic[7] := " JPC";
  END PL0Generator.

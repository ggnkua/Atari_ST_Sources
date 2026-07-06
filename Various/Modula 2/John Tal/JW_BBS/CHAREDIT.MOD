MODULE CharEdit;

(*
  Edit 16x16 Character sets.

         Author: J. Tal
           Date: 04/29/1986
 Implementation: Logitech - IBM/PC

          Notes: Modula-2 Version of Charedit.Pas of 7/85 by same author.

                 Inspired by INSTEDIT on Atari 400/800's by Sheldon Leemon
                 (approx 1982).

                 Instedit was the first character set editor I ever used and
                 most of it's functions are in this program.

                 This module will be converted for use onto an ATARI 520ST.
*)


FROM Environment IMPORT Ptr,GotoXY,Cls;
FROM PcKeys      IMPORT InKey,SpecialKey;
FROM PcScreen    IMPORT ReadScreenChar,WriteScreenChar,DisplayString,
                        Normal,Blink,Reverse;
FROM Functions   IMPORT Power,ToSpaces;
FROM InOut       IMPORT WriteLn,WriteCard,ReadCard,OpenOutput,OpenInput,
                        CloseInput,CloseOutput,Done,Read,WriteString,Write;
FROM Keyboard    IMPORT KeyPressed;


CONST
  CharOrg = 30;  (* starting x pos on screen FOR character work area *)
  vertOrg = 4;   (* starting y pos *)
  matrixX = 16;
  matrixY = 16;
  bit = 219;

TYPE
  mainb = ARRAY[0..127] OF ARRAY[1..matrixY] OF CARDINAL;
  st255 = ARRAY[0..254] OF CHAR;
  st80 = ARRAY[0..80] OF CHAR;
  st25 = ARRAY[0..24] OF CHAR;

  CharBits3 = ARRAY[1..matrixX] OF CARDINAL;        (* total row value *)
  CharBits4 = ARRAY[1..matrixY] OF ARRAY[1..matrixX] OF CARDINAL; (* total row/column array *)



VAR
  bytes,IBMbytes : mainb;                     (* character sets *)
  holdBits : CharBits3;                       (* 16 byte holders *)
  i,j : CARDINAL;
  keymat : ARRAY[1..22] OF st80;
  OpenScreen : ARRAY[1..22] OF st80;          (* title screen *)
  blanks: ARRAY[0..80] OF CHAR;
  IbmMemoryBytes: POINTER TO ARRAY[0..127] OF ARRAY[0..7] OF CHAR;


PROCEDURE RealPower(x,n : REAL) : REAL;
BEGIN
   IF n=1.0  THEN
     RETURN x
   ELSIF n <= 0.0 THEN
     RETURN 1.0;
   ELSE
     RETURN (x * RealPower(x,n-1.0));
  END;
END RealPower;

PROCEDURE pause;
VAR
 ch: CHAR;
BEGIN
  DisplayString(25,1,Blink,' Press Any Key ');
  WHILE NOT KeyPressed() DO
  END;
  Read(ch);
  DisplayString(25,1,Normal,'                ');
END pause;


PROCEDURE KeyDecode (scanval: CARDINAL; VAR job: INTEGER;
                                         VAR key: CARDINAL);
BEGIN
 job := -1;

 IF (scanval >= 59) AND (scanval <= 68) THEN
   job := 1;
 ELSIF (scanval >= 84) AND (scanval <= 93) THEN
   job := 2;
 ELSIF (scanval >= 94) AND (scanval <= 103) THEN
   job := 3;
 ELSIF (scanval >= 104) AND (scanval <= 113) THEN
   job := 4;
 END;

 CASE job OF
  -1 : key := 0;
 | 1 : key := scanval - 58;
 | 2 : key := scanval - 83;
 | 3 : key := scanval - 93;
 | 4 : key := scanval - 103;
 END;
END KeyDecode;


PROCEDURE LoadIBM;  (* load 8x8 matrix from memory & convert to 16x16 *)
VAR
  AsciiChar,EightValue,SixteenValue,i1,i2,EX: CARDINAL;
BEGIN
  FOR AsciiChar := 0 TO 127 DO  (* scan each character *)
    FOR i1 := 1 TO 8 DO        (* scan from top to bottom of character *)
      SixteenValue := 0;
      EightValue := ORD(IbmMemoryBytes^[AsciiChar][i1-1]);
      FOR i2 := 1 TO 8 DO      (* test each bit *)
        EX := Power(2,8-i2);
        IF BITSET(EightValue) * BITSET(EX) = BITSET(EX) THEN
          INC(SixteenValue, Power(EX,2)*2+Power(EX,2) );  (* stretch out horizontally *)
        END;
      END;
      IBMbytes[AsciiChar,i1*2-1] := SixteenValue;  (* originally 8, now 16, so *)
      IBMbytes[AsciiChar,i1*2] := SixteenValue;    (* stretch out vertically *)
    END;
  END;
END LoadIBM;


PROCEDURE LoadChars;
VAR
  b,c,r,cardin : CARDINAL;
BEGIN
   DisplayString(24,1,Normal,blanks);
   DisplayString(24,1,Normal,'Character set to load ?');
   GotoXY(25,24);
   OpenInput("SET");
   GotoXY(1,1);
   IF Done THEN
     DisplayString(24,1,Normal,blanks);
     DisplayString(24,1,Normal,'Loading Data ...... ');
     FOR r := 0 TO 127 DO
        FOR c := 1 TO matrixY DO
           ReadCard(cardin);
           bytes[r,c] := cardin;
        END;
      END;
      CloseInput;
   ELSE
      DisplayString(24,1,Normal,blanks);
      DisplayString(24,1,Normal,'load aborted              ');
   END;
   DisplayString(24,1,Normal,blanks);
END LoadChars;


PROCEDURE SaveChars;
 VAR
   b,c,r : CARDINAL;
 BEGIN
  DisplayString(24,1,Normal,'                                         ');
  DisplayString(24,1,Normal,'Character set to save ?');
  GotoXY(26,24);
  OpenOutput("SET");  (* default extension if none given is SET *)
  GotoXY(1,1);
  IF Done THEN
    GotoXY(1,1);
    DisplayString(24,1,Normal,blanks);
    DisplayString(24,1,Normal,'Saving Data ....... ');
    FOR r := 0 TO 127 DO
      FOR c := 1 TO matrixY DO
        WriteCard(bytes[r,c],6);
      END;
      WriteLn;
    END;
    DisplayString(24,1,Normal,blanks);
    CloseOutput;
  ELSE
    DisplayString(23,1,Normal,'save aborted              ');
  END;
END SaveChars;


PROCEDURE guideline;
BEGIN
  DisplayString(24,18,Reverse,'<   Press Key of character you want to Edit  >');
  DisplayString(25,11,Reverse,'<  use cursor keys to move / ALT-F2 to save / End to quit >');
END guideline;


PROCEDURE clrbox;
VAR
 i : CARDINAL;
 clear: ARRAY[0..matrixX-1] OF CHAR;
BEGIN
  ToSpaces(clear,matrixX-1);
  FOR i := 1 TO matrixY DO
    DisplayString(i+vertOrg-1,CharOrg,Normal,clear);
  END;
END clrbox;


PROCEDURE BitsToBytes( bits : CharBits4; VAR ReturnBytes : CharBits3);
VAR
 i1,i2,totbytes : CARDINAL;
BEGIN
 FOR i1 := 1 TO matrixY DO
   totbytes := 0;
   FOR i2 := 1 TO matrixX DO
     IF bits[i1,i2] = 1 THEN
       totbytes := totbytes + Power(2,matrixX-i2);
     END;
   END;
   ReturnBytes[i1] := totbytes;
 END;
END BitsToBytes;


PROCEDURE ByteToBits( abyte : CharBits3; VAR ReturnBits : CharBits4);
VAR
 a,b,i : CARDINAL;
BEGIN
  FOR i := 1 TO matrixY DO
    a := abyte[i];
    FOR b := matrixX-1 TO 0 BY -1 DO
      IF a >= Power(2,b) THEN
        a := a-Power(2,b);
        ReturnBits[i,matrixX-b] := 1;
      ELSE
        ReturnBits[i,matrixX-b] := 0;
      END;
    END;
  END;
 END ByteToBits;


PROCEDURE RotateRight ( VAR bits : CharBits4 ; right : CARDINAL);
VAR
 i1,i2,i3,i4,temp : CARDINAL;
 tempBits1 : CharBits3;
BEGIN
  FOR i1 := 1 TO matrixY DO      (*  down  *)

    FOR i2 := 1 TO matrixX DO               (*  left TO right  *)
      tempBits1[i2] := bits[i1][i2];
    END;

    FOR i3 := 1 TO right DO
      temp := tempBits1[matrixX];
      FOR i4 := matrixX TO 2 BY -1 DO
        tempBits1[i4] := tempBits1[i4-1];
      END;
      tempBits1[1] := temp
    END;

    FOR i2 := 1 TO matrixX DO
      bits[i1,i2] := tempBits1[i2]
    END;

  END;   (* for i1 *)
END RotateRight;


PROCEDURE RotateLeft ( VAR bits : CharBits4 ; left : CARDINAL);
VAR
 i1,i2,i3,i4,temp : CARDINAL;
 tempBits1 : CharBits3;
BEGIN
  FOR i1 := 1 TO matrixY DO
    FOR i2 := 1 TO matrixX DO
      tempBits1[i2] := bits[i1,i2];
    END;

    FOR i3 := 1 TO left DO
      temp := tempBits1[1];
      FOR i4 := 1 TO matrixX-1 DO
        tempBits1[i4] := tempBits1[i4+1];
      END;
      tempBits1[matrixX] := temp
    END;

    FOR i2 := 1 TO matrixX DO
      bits[i1,i2] := tempBits1[i2];
    END;

  END;   (* for i1 *)
END RotateLeft;


PROCEDURE ShiftUp ( VAR sbytes : CharBits3);
VAR
 i,temp: CARDINAL;
BEGIN
  temp := sbytes[1];
  FOR i := 1 TO matrixX -1 DO
    sbytes[i] := sbytes[i + 1];
  END;
  sbytes[matrixX] := temp;
END ShiftUp;

PROCEDURE ShiftDown ( VAR sbytes : CharBits3);
VAR
 i,temp : CARDINAL;
BEGIN
  temp := sbytes[matrixX];
  FOR i := matrixX TO 2 BY -1 DO
    sbytes[i] := sbytes[i - 1];
  END;
  sbytes[1] := temp;
END ShiftDown;


PROCEDURE ReadBits (VAR ProcessBytes : CharBits3);  (* read bits OF CHAR on screen *)
VAR
 a,x,y,totbytes : CARDINAL;
BEGIN
  FOR y := vertOrg TO vertOrg + matrixY-1 DO
    totbytes := 0;

    FOR x := CharOrg TO CharOrg + matrixX-1 DO
      a := ORD(ReadScreenChar(y,x));
      IF a = 219 THEN
        totbytes := totbytes + Power(2,(CharOrg+(matrixX-1)-x));
      END;
    END;

    ProcessBytes[y - (vertOrg-1)] := totbytes;
  END;

END ReadBits;


PROCEDURE WriteBits (ReturnBits : CharBits4);
VAR
 i,b : CARDINAL;
 ch: CHAR;
BEGIN
FOR i := 1 TO matrixY DO
  FOR b := matrixX -1 TO 0 BY -1 DO
    IF ReturnBits[i,matrixX-b] = 1 THEN
      ch := CHR(bit);
    ELSE
      ch := ' ';
    END;
    WriteScreenChar(i+vertOrg-1,CharOrg+(matrixX-1)-b,Normal,ch);
  END;
END;
END WriteBits;


PROCEDURE WriteBytes (abyte : CharBits3);
VAR
 i,b : CARDINAL;
 ch: CHAR;
 ReturnBits : CharBits4;
BEGIN
  ByteToBits(abyte,ReturnBits);
  FOR i := 1 TO matrixY DO
    FOR b := matrixX-1 TO 0 BY -1 DO
      IF ReturnBits[i,matrixX-b] = 1 THEN
        ch := CHR(bit);
      ELSE
        ch := ' ';
      END;
      WriteScreenChar(i+vertOrg-1,CharOrg+(matrixX-1)-b,Normal,ch);
    END;
  END;
END WriteBytes;

PROCEDURE ReplaceChar(Editchar : CARDINAL);  (* replace WITH the way character was at start OF Edit *)
VAR
 a,x,y,totbytes : CARDINAL;
 ProcessBytes : CharBits3;
BEGIN
  ReadBits(ProcessBytes);
  FOR y := 1 TO matrixY DO
    bytes[Editchar][y] := ProcessBytes[y];
  END;
END ReplaceChar;


PROCEDURE ShowBits;
VAR
 a,x,y,totbytes : CARDINAL;
BEGIN
  FOR y := vertOrg TO (vertOrg + matrixY)-1  DO
    totbytes := 0;
    FOR x := CharOrg TO (CharOrg + matrixX)-1  DO
      a := ORD(ReadScreenChar(y,x));
      IF a = 219 THEN
        totbytes := totbytes + Power(2,(CharOrg + (matrixX-1) -x));
      END;
    END;
    GotoXY(CharOrg+matrixX+3,y);
    WriteCard(totbytes,5);
  END;
  GotoXY(1,1);
END ShowBits;


PROCEDURE ModifyChar(job : CARDINAL);   (* Job 1 = inverse
                                               2 = twist
                                               3 = mirror
                                               4 = rotate right
                                               5 = rotate left
                                         *)
VAR
 i,i1,i2,i3 : CARDINAL;
 ProcessBytes,ReturnBytes,tempBits : CharBits3;
 ReturnBits,NewBits : CharBits4;
BEGIN
  CASE job OF
    1 :  ReadBits(ProcessBytes);
         FOR i := 1 TO matrixX DO
            ProcessBytes[i] := TRUNC( (RealPower(2.0,FLOAT(matrixX)) -1.0) - FLOAT(ProcessBytes[i]));
         END;
         WriteBytes(ProcessBytes);

  | 2 :  ReadBits(ProcessBytes);
         ByteToBits(ProcessBytes,ReturnBits);
         FOR i1 := 1 TO matrixY DO
            FOR i2 := 1 TO matrixX DO
              NewBits[i1,i2] := ReturnBits[(matrixX+1)-i2,i1];
            END;
         END;
         WriteBits(NewBits);
  | 3 :

  | 4 :  ReadBits(ProcessBytes);
         ByteToBits(ProcessBytes,ReturnBits);
         RotateRight(ReturnBits,1);
         WriteBits(ReturnBits);

  | 5 :  ReadBits(ProcessBytes);
         ByteToBits(ProcessBytes,ReturnBits);
         RotateLeft(ReturnBits,1);
         WriteBits(ReturnBits);

  | 6 :

  | 7 :  ReadBits(ProcessBytes);
         ShiftUp(ProcessBytes);
         WriteBytes(ProcessBytes);

  | 8 :  ReadBits(ProcessBytes);
         ShiftDown(ProcessBytes);
         WriteBytes(ProcessBytes);

   ELSE
   END;  (* CASE *)
   ShowBits;
END ModifyChar;


PROCEDURE CopyChar;
VAR
 i,Editchar : CARDINAL;
 command : ARRAY [0..1] OF CHAR;
 sendBytes : CharBits3;
BEGIN
  DisplayString(22,31,Normal,'Copy which CHAR ?');
  WHILE NOT InKey(command) DO
  END;
  Editchar := ORD(command[0]);
  DisplayString(22,31,Normal,'                  ');
  FOR i := 1 TO matrixY DO
    sendBytes[i] := bytes[Editchar,i];
  END;
  WriteBytes(sendBytes);
END CopyChar;


PROCEDURE DisplayChar(Editchar : CARDINAL);
VAR
 i: CARDINAL;
 sendBytes : CharBits3;
BEGIN
  FOR i := 1 TO matrixY DO
    sendBytes[i] := bytes[Editchar][i];
    holdBits[i] := sendBytes[i]
  END;

  WriteBytes(sendBytes);

  FOR i := 1 TO matrixX+1 DO
    WriteScreenChar(vertOrg-1,CharOrg-1+i,Normal,CHR(Editchar));
    WriteScreenChar(vertOrg+matrixY,CharOrg-1+i,Normal,CHR(Editchar));
  END;

  FOR i := vertOrg-1 TO vertOrg + matrixY DO
    WriteScreenChar(i,CharOrg-1,Normal,CHR(Editchar));
    WriteScreenChar(i,CharOrg+matrixX,Normal,CHR(Editchar));
  END;

END DisplayChar;


PROCEDURE DisplayIbmChar(Editchar : CARDINAL);
VAR
 i: CARDINAL;
 sendBytes : CharBits3;
BEGIN
 FOR i := 1 TO matrixY DO
   sendBytes[i] := IBMbytes[Editchar,i];
 END;
 WriteBytes(sendBytes);
END DisplayIbmChar;


(* -----------------------------------------------------------------------
                        main routine
 ----------------------------------------------------------------------- *)

PROCEDURE Edit;
VAR
 posx,posy,Editchar,key : CARDINAL;
 job: INTEGER;
 Editing,changed,specialkey : BOOLEAN;
 command,show,hold : CHAR;
 keys: ARRAY[0..1] OF CHAR;
BEGIN
  Cls;
  FOR i := 1 TO 22 DO
    DisplayString(i,1,Normal,keymat[i]);
  END;
  guideline;
  Editchar := 65;
  DisplayChar(Editchar);
  Editing := TRUE;
  show := '*';
  hold := CHR(32);
  posx := CharOrg + (matrixX DIV 2);
  posy := vertOrg + (matrixY DIV 2);
REPEAT
  changed := FALSE;
  IF InKey(keys) THEN
    IF SpecialKey(keys) THEN
      command := keys[1];
      KeyDecode(ORD(command),job,key);
      CASE job OF    (* regular keys - number pad *)
         -1 : CASE ORD(command) OF
                 72 : DEC(posy);
                      IF posy < vertOrg THEN
                        posy := vertOrg;
                      END;
               | 75 : DEC(posx);
                      IF posx < CharOrg THEN
                        posx := CharOrg;
                      END;
               | 77 : INC(posx);
                      IF posx > CharOrg + matrixX -1 THEN
                        posx := CharOrg + matrixX -1;
                      END;
               | 80 : INC(posy);
                      IF posy > vertOrg + matrixY -1 THEN
                        posy := vertOrg + matrixY -1;
                      END;
               | 71 : clrbox;
               | 79 : Editing := FALSE;
                ELSE
                END;  (* CASE -1 command OF *)
         | 1 : CASE key OF
                  1 : hold := ReadScreenChar(posy,posx);
                      IF hold = ' ' THEN
                        hold := CHR(bit)
                      ELSE
                        hold := ' ';
                      END;
                      WriteScreenChar(posy,posx,Normal,hold);
                      ShowBits;
                | 2 : CopyChar;
                | 3 : ModifyChar(7);
                | 4 : ModifyChar(8);
                | 5 : ModifyChar(5);
                | 6 : ModifyChar(4);
                | 7 : ModifyChar(1);
                | 8 : ModifyChar(2);
                | 9 : WriteBytes(holdBits);
                |10 : DisplayIbmChar(Editchar);
                ELSE
                  (* dummy option *)
                END;  (* CASE 1 key OF *)
         | 2 : CASE key OF
                  1 :
                | 2 :
                | 3 :
                | 4 :
                | 5 :
                | 6 :
                | 7 :
                | 8 :
                | 9 :
               | 10 :
                ELSE
                  (* dummy option *)
                END;  (* CASE 2 key OF *)
         | 3 : CASE key OF
                  1 :
                | 2 :
                | 3 :
                | 4 :
                | 5 :
                | 6 :
                | 7 :
                | 8 :
                | 9 :
               | 10 :
                ELSE
                  (* dummy option *)
                END;  (* CASE 3 key OF *)
         | 4 : CASE key OF
                  1 : LoadChars;
                      DisplayChar(Editchar);
                | 2 : ReplaceChar(Editchar);
                      SaveChars;
                | 3 :
                | 4 :
                | 5 :
                | 6 :
                | 7 :
                | 8 :
                | 9 :
               | 10 :
                ELSE
                  (* dummy option *)
                END;  (* CASE 2 key OF *)
      ELSE
      END; (* CASE job OF *)
    ELSE    (* not a specialkey *)
      command := keys[0];
      ReplaceChar(Editchar);
      Editchar := ORD(command);
      DisplayChar(Editchar);
    END;
  ELSE  (* if not inkey - no keys pressed *)
    hold := ReadScreenChar(posy,posx);
    WriteScreenChar(posy,posx,Normal,show);
    WriteScreenChar(posy,posx,Normal,hold);
  END;
UNTIL NOT Editing
END Edit;

(* -----------------------------------------------------------------------
                  beginning of program execution
 ----------------------------------------------------------------------- *)
BEGIN
  Cls;

  IbmMemoryBytes := Ptr(0F000H,0FA6EH);
  ToSpaces(blanks,78);

  OpenScreen[1]  := '-------------------------------------------------------------------------------';
  OpenScreen[2]  := '-------------------------------------------------------------------------------';
  OpenScreen[3]  := '-------------------------------------------------------------------------------';
  OpenScreen[4]  := '-------------------------------------------------------------------------------';
  OpenScreen[5]  := '---@@@@@@.-@@@.-@@@.--@@@@@@.--@@@@@@.---@@@@@@@@.-@@@@@@.----@@@@.--@@@@@@@@.-';
  OpenScreen[6]  := '--@@.---@.--@@.-@@.--@@@.-@@@.-@.---@@@.-@@.--@@@.-@@.-@@@.----@@.---@.@@@@.@.-';
  OpenScreen[7]  := '-@@.--------@.---@.--@@.---@@.-@.----@@.-@@.--------@@.--@@.------------@@.----';
  OpenScreen[8]  := '-@@.--------@@@@@@.--@@.---@@.-@@@@@@@.--@@@@@@.----@@.--@@.---@@.------@@.----';
  OpenScreen[9]  := '-@@.--------@.---@.--@@@@@@@@.--@@@@@.---@@.--------@@.--@@.---@@.------@@.----';
  OpenScreen[10] := '-@@.--------@@.-@@.--@@.---@@.--@@.@@@.--@@.---@@.-@@.--@@.----@@.------@@.----';
  OpenScreen[11] := '--@@@.--@.--@@.-@@.--@@.---@@.-@@@.--@.--@@.---@@.-@@.-@@.-----@@.-----@@@@.---';
  OpenScreen[12] := '----@@@@@.-@@@.-@@@.-@@.---@@.-@@@.--@@.-@@@@@@@@.-@@@@@@.---@@@@@@.-@@@@@@@@.-';
  OpenScreen[13] := '-------------------------------------------------------------------------------';
  OpenScreen[14] := '-------------------------------------------------------------------------------';
  OpenScreen[15] := '-------------------------------------------------------------------------------';
  OpenScreen[16] := '-------------------------------------------------------------------------------';
  OpenScreen[17] := '-------------------    Modula-2   CHARacter set EDITor   ----------------------';
  OpenScreen[18] := '-------------------------------------------------------------------------------';
  OpenScreen[19] := '-------------------      public domain BY John Tal       ----------------------';
  OpenScreen[20] := '-------------------------------------------------------------------------------';
  OpenScreen[21] := '------------------------  version 2.0  04/29/1986  ----------------------------';
  OpenScreen[22] := '-------------------------------------------------------------------------------';


   keymat[1] := '/---------\/---------\                                  /---------\/---------\ ';
   keymat[2] := ':F1       ::F2       :                                  :F1       ::F2       : ';
   keymat[3] := ':         ::         :                                  :         ::         : ';
   keymat[4] := ': write   :: copy ch :                                  :load SET ::save SET : ';
   keymat[5] := ':---------::---------:                                  :---------::---------: ';
   keymat[6] := ':F3       ::F4       :                                  :F3       ::F4       : ';
   keymat[7] := ':         ::         :                                  :         ::         : ';
   keymat[8] := ':rotate Up::rotate Dn:                                  :         ::         : ';
   keymat[9] := ':---------::---------:                                  :---------::---------: ';
  keymat[10] := ':F5       ::F6       :                                  :F5       ::F6       : ';
  keymat[11] := ':         ::         :                                  :         ::         : ';
  keymat[12] := ':rotate <-::rotate ->:                                  :         ::         : ';
  keymat[13] := ':---------::---------:                                  :---------::---------: ';
  keymat[14] := ':F7       ::F8       :                                  :F7       ::F8       : ';
  keymat[15] := ': inverse ::  twist  :                                  :         ::         : ';
  keymat[16] := ':         ::         :                                  :         ::         : ';
  keymat[17] := ':---------::---------:                                  :---------::---------: ';
  keymat[18] := ':F9       ::F10      :                                  :F9       ::F10      : ';
  keymat[19] := ':         ::         :                                  :         ::         : ';
  keymat[20] := ': restore :: ibm ch. :                                  :         ::         : ';
  keymat[21] := '\---------/\---------/                                  \---------/\---------/ ';
  keymat[22] := '<Regular Function Key>                                   <Alt & Function Key>  ';

  FOR i := 1 TO 22 DO
    DisplayString(i,1,Normal,OpenScreen[i]);
  END;

  DisplayString(25,1,Normal,' Standby...... ');

  LoadIBM;

  FOR i := 0 TO 127 DO
    FOR j := 1 TO matrixY DO
      bytes[i][j] := IBMbytes[i][j];
    END;
  END;

  pause;

  Edit;
  Cls;

END CharEdit.



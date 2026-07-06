IMPLEMENTATION MODULE InOutField;

(**********************************************************)
(*   ROLLINS MEDICAL/DENTAL SYSTEMS                       *)
(*   360 CLAUSEN BUILDING                                 *)
(*   23100 PROVIDENCE DRIVE                               *)
(*   SOUTHFIELD, MI  48075-3677                           *)
(*   -------------------------------------------------    *)
(*  |                                                 |   *)
(*  | Field defined Full-Screen I/O                   |   *)
(*  |                                                 |   *)
(*   -------------------------------------------------    *)
(*   Author: John Tal            Created: 02/28/1986      *)
(*   Version:  2.00 a          Last Edit: 04/26/1986      *)
(*                                                        *)
(*   (C) Copyright 1986 ROLLINS MEDICAL/DENTAL SYSTEMS    *)
(*       All Rights Reserved                              *)
(*                                                        *)
(*    Permission is hereby granted to use and modify the  *)
(*  following module in the implementation of customized  *)
(*  software.                                             *)
(*    This permission includes the right to re-distribute *)
(*  the original source code but does not include the     *)
(*  right to redistribute modified source code of this    *)
(*  program.                                              *)
(**********************************************************)


FROM NumberConversion IMPORT StringToCa;
FROM Stringggs          IMPORT Copy,Length,Concat,Pos;
FROM PcScreen         IMPORT Cls,DisplayString,WriteScreenChar,ReadScreenChar,
                             Invisible,Normal,Underline,Blink,Highlight,
                             Reverse;
FROM Functions        IMPORT RightString,ToSpaces,LeftString,RightTrim,LeftPad,
                             RightPad;
FROM Environment      IMPORT GotoXY,Delay,Locate;
FROM Keyboard         IMPORT KeyPressed;
FROM PcKeys           IMPORT InKey,CompareKey,SpecialKey,keybuffer,
                             CarriageReturn,BackSpace,Tab,Escape,LtArrow,
                             RtArrow,UpArrow,DnArrow,ShiftTab,F7;


PROCEDURE SetAttributes(DispAtrib: ARRAY OF CHAR) : CARDINAL;
VAR
  Disp : CARDINAL;
BEGIN
   Disp := 0;
   IF Pos('N',DispAtrib) <= HIGH(DispAtrib) THEN RETURN Normal; END;
   IF Pos('R',DispAtrib) <= HIGH(DispAtrib) THEN RETURN Reverse; END;
   IF Pos('I',DispAtrib) <= HIGH(DispAtrib) THEN RETURN Invisible; END;
   IF Pos('H',DispAtrib) <= HIGH(DispAtrib) THEN
     Disp := Disp + Highlight;    (* OR 8 *)
   END;
   IF Pos('U',DispAtrib) <= HIGH(DispAtrib) THEN
     Disp := Disp + Underline;    (* XOR 6 *)
   END;
   IF Pos('B',DispAtrib) <= HIGH(DispAtrib) THEN
     Disp := Disp + Blink;    (* OR 128 *)
   END;
   RETURN Disp;
END SetAttributes;

PROCEDURE OutField( ScreenControl,ShowData : ARRAY OF CHAR);
VAR
 ScrY,ScrX,ScrL,i : CARDINAL;
 ca : ARRAY[1..5] OF ARRAY[0..24] OF CHAR;
 c,comma,DispColor,TextColor : CARDINAL;
 DispAtrib,CtrlAtrib : ARRAY[0..16] OF CHAR;
 chold,tempStr : ARRAY[0..24] OF CHAR;
 extraStr : ARRAY[0..80] OF CHAR;
 done : BOOLEAN;


BEGIN

   Copy(ScreenControl,0,HIGH(ScreenControl)+1,chold);

   FOR c := 1 TO 5 DO                   (*  pass  1 - isolate y  *)
                                        (*        2 - isolate x  *)
    comma := Pos(',',chold);            (*        3 - isolate C and width  *)
    IF comma > HIGH(chold) THEN
      comma := Length(chold)+1;
    END;
    Copy(chold,0,comma,ca[c]);          (*        4 - isolate display attrib  *)
    Copy(chold,comma+1,255,chold);      (*        5 - isolate control attrib  *)
   END;
   StringToCard(ca[1],ScrY,done);
   StringToCard(ca[2],ScrX,done);
   RightString(tempStr,ca[3],2);
   StringToCard(tempStr,ScrL,done);

   Copy(ca[4],0,HIGH(ca[4]),DispAtrib);
   Copy(ca[5],0,HIGH(ca[5]),CtrlAtrib);

   DispColor := SetAttributes(DispAtrib);

   IF (ScrL > 1) AND (Length(ShowData) < ScrL) THEN
     RightPad(ShowData,ShowData,ScrL);
   END;

   LeftString(ShowData,ShowData,ScrL);
   DisplayString(ScrY,ScrX,DispColor,ShowData);
   (* Locate(ScrY,ScrX); *)
 END OutField;


PROCEDURE InField(ScreenControl : ARRAY OF CHAR; VAR FieldData : ARRAY OF CHAR;
                  VAR FieldNumber : INTEGER);

VAR
 ScrY,ScrX,ScrL,i : CARDINAL;
 CurY,CurX,MoveCursor,WritChar,action : CARDINAL;
 tempx,tempy,comma,c,DispColor,TextColor : CARDINAL;
 fielding,done,specialkey : BOOLEAN;
 command : CHAR;
 tempStr : ARRAY[0..77] OF CHAR;
 chold : ARRAY[0..24] OF CHAR;
 ca : ARRAY[1..5] OF ARRAY[0..24] OF CHAR;
 DispAtrib,CtrlAtrib : ARRAY[0..16] OF CHAR;



PROCEDURE ProcMoveCursor( moveit : CARDINAL);
BEGIN
  CASE moveit OF
      1 :   INC(CurX);         (* move cursor TO right *)
            IF CurX > (ScrX + ScrL -1) THEN
               CurX := ScrX;
            END;
            GotoXY(CurX,CurY);
           |
      2 :   DEC(CurX);         (* move cursor TO left *)
            IF CurX < ScrX THEN
                CurX := (ScrX + ScrL - 1);
            END;
            GotoXY(CurX,CurY)
  END; (* CASE moveit *)
END ProcMoveCursor;


PROCEDURE ProcWritChar (writ,DispColor : CARDINAL);
BEGIN
 CASE writ OF
   0 : Delay(1)
       |
   1 :  WriteScreenChar(CurY,CurX,DispColor,command);
        IF CurX +1 > (ScrX + ScrL -1) THEN
            GotoXY(ScrX,ScrY);
        END;
       |
   2 :  WriteScreenChar(CurY,CurX,DispColor,' ');
        GotoXY(CurX,CurY);
       |
   3 :  ToSpaces(tempStr,(ScrX + ScrL) - CurX);
        DisplayString(CurY,CurX,DispColor,tempStr);
        GotoXY(ScrX,ScrY)
 END; (* CASE writ *)
END ProcWritChar;

 BEGIN

   Copy(ScreenControl,0,HIGH(ScreenControl)+1,chold);

   FOR c := 1 TO 5 DO                   (*  pass  1 - isolate y  *)
                                        (*        2 - isolate x  *)
    comma := Pos(',',chold);            (*        3 - isolate C and width  *)
    IF comma > HIGH(chold) THEN
      comma := Length(chold)+1;
    END;
    Copy(chold,0,comma,ca[c]);          (*        4 - isolate display Atrib  *)
    Copy(chold,comma+1,255,chold);      (*        5 - isolate control Atrib  *)
   END;

   StringToCard(ca[1],ScrY,done);
   StringToCard(ca[2],ScrX,done);
   RightString(tempStr,ca[3],2);
   StringToCard(tempStr,ScrL,done);

   Copy(ca[4],0,HIGH(ca[4]),DispAtrib);
   Copy(ca[5],0,HIGH(ca[5]),CtrlAtrib);

   CurY := ScrY;
   CurX := ScrX;

   DispColor := SetAttributes(DispAtrib);

   GotoXY(ScrX,ScrY);

   FOR i := ScrX TO (ScrX + ScrL - 1) DO
      FieldData[i-ScrX] := ReadScreenChar(ScrY,i);
   END;
   FieldData[ScrL] := CHR(0);

   RightTrim(tempStr,FieldData);
   IF Length(tempStr) < ScrL THEN
     RightPad(FieldData,FieldData,ScrL);
     DisplayString(ScrY,ScrX,DispColor,FieldData);
   END;

   fielding := TRUE;

   REPEAT
    IF InKey(keybuffer)  THEN      (*  IF a key has been pressed  *)
       IF NOT SpecialKey(keybuffer)  THEN  (*  IF NOT arrow key or tabs  *)
           IF ((ORD(keybuffer[0]) > 31) AND (ORD(keybuffer[0]) < 127)) THEN
            (*  IF alpha-numeric, accept and print  *)
               WritChar := 1;      (*  Write the character  *)
               MoveCursor := 1;    (*  move cursor TO right  *)
               action := 1;        (*  Write/move  *)
             ELSIF CompareKey(keybuffer,CarriageReturn) THEN
               fielding := FALSE;  (*  get out OF here  *)
               WritChar := 0;      (*  don't Write anything  *)
               MoveCursor := 0;    (*  don't move the cursor  *)
               action := 0;        (*  don't DO anything  *)
               FieldNumber := -2;  (*  flag that infield loop is over  *)
             ELSIF CompareKey(keybuffer,BackSpace) THEN
               WritChar := 2;      (*  Write a space  *)
               MoveCursor := 2;    (*  move TO left  *)
               action := 3;        (*  move cursor/Write blank/re-pos cur  *)
             ELSIF CompareKey(keybuffer,Tab) THEN
               fielding := FALSE;  (*  get out OF here  *)
               WritChar := 0;      (*  don't Write anything  *)
               MoveCursor := 0;    (*  don't move the cursor  *)
               action := 0;        (*  don't DO anything  *)
               INC(FieldNumber);   (*  increment control VARiable  *)
             ELSIF CompareKey(keybuffer,Escape) THEN
               fielding := FALSE;  (*  get out OF here  *)
               WritChar := 3;      (*  Write spaces in field  *)
               MoveCursor := 0;    (*  don't move the cursor  *)
               action := 4;        (*  Write spaces in field  *)
               INC(FieldNumber)    (*  increment control variable *)
           ELSE
               Delay(1);
           END  (* if ord *)
       ELSE
           IF CompareKey(keybuffer,LtArrow) THEN
               WritChar := 0;       (*  don't Write anything  *)
               MoveCursor := 2;     (*  move TO left  *)
               action := 2;         (*  just move  *)
             ELSIF CompareKey(keybuffer,RtArrow) THEN
               WritChar := 0;       (*  don't Write anything  *)
               MoveCursor := 1;     (*  move TO right  *)
               action := 2;         (*  just move  *)
             ELSIF CompareKey(keybuffer,UpArrow) THEN
               fielding := FALSE;   (*  get out OF here  *)
               WritChar := 0;       (*  don't Write anything  *)
               MoveCursor := 0;     (*  don't move the cursor  *)
               action := 0;         (*  don't DO anything  *)
               DEC(FieldNumber);    (*  decrement control VARiable  *)
             ELSIF CompareKey(keybuffer,DnArrow) THEN
               fielding := FALSE;   (*  get out OF here  *)
               WritChar := 0;       (*  don't Write anything  *)
               MoveCursor := 0;     (*  don't move the cursor  *)
               action := 0;         (*  don't DO anything  *)
               INC(FieldNumber);    (*  increment control VARiable  *)
             ELSIF CompareKey(keybuffer,ShiftTab) THEN
               fielding := FALSE;   (*  get out OF here  *)
               WritChar := 0;       (*  don't Write anything  *)
               MoveCursor := 0;     (*  don't move the cursor  *)
               action := 0;         (*  don't DO anything  *)
               DEC(FieldNumber);    (*  decrement control VARiable  *)
             ELSIF CompareKey(keybuffer,F7) THEN
               HALT                 (*  FOR testing  *)
           ELSE
               Delay(1);
           END;  (* if comparekey  *)
       END; (* IF specialkey  *)

         CASE action OF
            0 : Delay(1);
               |
            1 : ProcWritChar(WritChar,DispColor);
                ProcMoveCursor(MoveCursor);
               |
            2 : ProcMoveCursor(MoveCursor);
               |
            3 :  ProcMoveCursor(MoveCursor);
                 ProcWritChar(WritChar,DispColor);
               |
            4 : ProcWritChar(WritChar,DispColor)
           END; (* CASE action *)

    END; (* IF inkey *)

   UNTIL NOT fielding;

   FOR i := ScrX TO (ScrX + ScrL - 1) DO
      FieldData[i-ScrX] := ReadScreenChar(ScrY,i);
   END;
   FieldData[ScrL] := CHR(0);

 END InField;


END InOutField.

(**********************************************************************)
(*   NAME              : CardGame                                     *)
(*   WRITTEN BY        : Carolyn Rogers                               *)
(*                     : Copyright 1989 Antic Publishing Inc.         *)
(*   DATE WRITTEN      : May 1988                                     *)
(*   LANGUAGE          : MODULA-2 BY TDI Software                     *)
(*   PROGRAM PURPOSE   : Solitare Poker                               *)
(**********************************************************************)
MODULE CardGame;
FROM AESGraphics IMPORT GrafMouseKeyboardState,GrafMouse;
FROM AESForms    IMPORT FormAlert;
FROM BIOS        IMPORT BConIn, Device;
FROM Cards       IMPORT PokerHand,InitDeck,GetFace,GetSuit,PutCard,
                        ReplaceChar,ScoreHand,SortHand,DrawScreen,
                        PlayAgain,LoadCardFile,ShuffleCards;
FROM DropDown    IMPORT AddDropDownMenu,AddDropDownSubMenu,PrintMenuTitle,
                        DropDownMenu;
FROM FileMan     IMPORT Find;
FROM Form        IMPORT InputString;
FROM GEMDOS      IMPORT Open,Close,Create,Read,Write,GetDrv,GetPath,ConOut;
FROM GEMVDIbase  IMPORT VDIWorkOutType,PxyArrayType;
FROM Graphics    IMPORT SPRITE,LoadSprite,PutSprite,InitSprite,LoadPicture;
FROM MyLib       IMPORT OpenStation,SavePalette;
FROM Screen      IMPORT FreeAllPages,ShowPage,SetPage,ClearPage;
FROM String      IMPORT AssignStr,Len,ReplaceStr,InsertStr,PosStr,FillStr;
FROM Stuff       IMPORT DrawFrame;
FROM SYSTEM      IMPORT ADDRESS,ADR;
FROM TextIO      IMPORT WriteCard,WriteLn;
FROM VDIAttribs  IMPORT SetLineColour,SetFillColour,SetFillInteriorStyle;
FROM VDIControls IMPORT CloseVirtualWorkstation;
FROM VDIInputs   IMPORT HideCursor,ShowCursor;
FROM VDIOutputs  IMPORT FillRectangle;
FROM VTMode      IMPORT PutCursor,Print,CursorOff,ClearHome,
                        SelectBackColor,SelectCharColor,CursorOn,
                        CursorLeft,CursorRight;
FROM XBIOS       IMPORT Palette,SetPalette,GetResolution,
                        ScreenPhysicalBase;

TYPE
   PlaySlot  = ARRAY[0..4] OF BOOLEAN;
   HighScore = RECORD
                  Name  : ARRAY[0..30] OF CHAR;
                  Score : CARDINAL;
               END;

VAR
  Path,File                : ARRAY[0..120] OF CHAR;
  Warn,handleid,Resolution : INTEGER;
  Drive                    : CARDINAL;
  Workout                  : VDIWorkOutType;
  Found,OK                 : BOOLEAN;
(*FF*)
PROCEDURE HelpScreen();
VAR
  mx,my,ms,ks : INTEGER; 
  Flag        : BOOLEAN;
BEGIN
   Flag := TRUE; SetPage(3); ShowPage(3);
   WHILE Flag DO
      GrafMouseKeyboardState(mx,my,ms,ks);
      IF (ms = 1) THEN Flag := FALSE END;
   END;
   SetPage(1); ShowPage(1);
END HelpScreen;
(*FF*)
PROCEDURE LoadHighScores(VAR HighMarks : ARRAY OF HighScore);
VAR
  Name       : ARRAY[0..120] OF CHAR;
  Path       : ARRAY[0..120] OF CHAR;
  x,Drive    : CARDINAL;
  FileHandle : INTEGER;
  Bytes      : LONGCARD;
  Flag,Found : BOOLEAN;

BEGIN
   AssignStr(Name,"A:\HIGH.SCO");
   GetDrv(Drive); Name[0] := CHR(65+Drive);
   GetPath(Path,Drive+1);
   IF (Path[0] # 0C) THEN InsertStr(Name,Path,3) END;
   Open(Name,0,FileHandle);
   IF FileHandle >= 0 THEN
      Bytes := SIZE(HighMarks);
      Read(FileHandle,Bytes,ADR(HighMarks));
   ELSE
      FOR x := 0 TO 4 DO
         AssignStr(HighMarks[x].Name,"__________________________");
         HighMarks[x].Score := 0;
      END;
      Create(Name,0,FileHandle);
   END;
   Flag := Close(FileHandle);
END LoadHighScores;

PROCEDURE SaveHighScores(HighMarks : ARRAY OF HighScore);
VAR
  Name            : ARRAY[0..120] OF CHAR;
  Path            : ARRAY[0..120] OF CHAR;
  x,Drive         : CARDINAL;
  Warn,FileHandle : INTEGER;
  Bytes           : LONGCARD;
  Flag            : BOOLEAN;

BEGIN
   AssignStr(Name,"A:\HIGH.SCO");
   GetDrv(Drive); Name[0] := CHR(65+Drive);
   GetPath(Path,Drive+1);
   IF (Path[0] # 0C) THEN InsertStr(Name,Path,3) END;
   Open(Name,0,FileHandle);
   IF FileHandle >= 0 THEN
      Bytes := SIZE(HighMarks);
      Write(FileHandle,Bytes,ADR(HighMarks));
   ELSE
      Warn := FormAlert(1,"[3][ ERROR IN WRITING SCORES TO DISK! ][ OK ]");
   END;
   Flag := Close(FileHandle);
END SaveHighScores;
(*FF*)
PROCEDURE SeeIfHighScore(handle : INTEGER;
                         VAR HighMarks : ARRAY OF HighScore;
                         Score : CARDINAL);
VAR
  x,y,t,Tscore  : CARDINAL;
  ScoreLower    : BOOLEAN;
  Tname,Name    : ARRAY[0..30] OF CHAR;
  
BEGIN
   x := 0; ScoreLower := TRUE;
   WHILE ((x < 5) & (ScoreLower)) DO
     IF Score > HighMarks[x].Score THEN
        ScoreLower := FALSE;
        HighMarks[4].Score := Score;
        Name[0] := 0C;
        PutCursor(4+3,73); WriteCard(HighMarks[4].Score,5);
        InputString(handle,4+3,47,Name,"__________________________");
        AssignStr(HighMarks[4].Name,Name);
        FOR x := Len(HighMarks[4].Name) TO 26 DO 
           HighMarks[4].Name[x] := " ";
        END;
        HighMarks[4].Name[27] := 0C;
        FOR x := 0 TO 3 DO
           IF HighMarks[4].Score > HighMarks[x].Score THEN
              Tscore := HighMarks[x].Score;
              AssignStr(Tname,HighMarks[x].Name);
              HighMarks[x].Score := HighMarks[4].Score;
              AssignStr(HighMarks[x].Name,HighMarks[4].Name);
              HighMarks[4].Score := Tscore;
              AssignStr(HighMarks[4].Name,Tname);
           END;
        END;
        DrawHighScores(handle,HighMarks);
     END;
     INC(x);
   END;
END SeeIfHighScore;

PROCEDURE InitGameCardSlots(VAR SlotEmpty : ARRAY OF PlaySlot);
VAR x,y : CARDINAL;

BEGIN
  (* Init the screen area to empty *)
  FOR x :=  0 TO 4 DO
     FOR y := 0 TO 4 DO
         SlotEmpty[x][y] := TRUE;
     END;
  END;
END InitGameCardSlots;
(*FF*)
PROCEDURE Convert(mx,my : INTEGER; VAR row,col : CARDINAL) : BOOLEAN;
VAR
  Valid : BOOLEAN;

BEGIN
   Valid := TRUE;
   IF (my > 1*8) & (my < 4*8) THEN row := 0;
     ELSIF (my > 5*8) & (my < 8*8) THEN row := 1;
     ELSIF (my > 9*8) & (my < 12*8) THEN row := 2;
     ELSIF (my > 13*8) & (my < 16*8) THEN row := 3;
     ELSIF (my > 17*8) & (my < 20*8) THEN row := 4;
     ELSE row := 0; Valid := FALSE;
   END;
   IF (mx > 4*8) & (mx < 10*8) THEN col := 0;
      ELSIF (mx > 12*8) & (mx < 18*8) THEN col := 1;
      ELSIF (mx > 20*8) & (mx < 26*8) THEN col := 2;
      ELSIF (mx > 28*8) & (mx < 34*8) THEN col := 3;
      ELSIF (mx > 36*8) & (mx < 42*8) THEN col := 4;
      ELSE col := 0; Valid := FALSE;
   END;
   RETURN(Valid);     
END Convert;

PROCEDURE ScoreGame(GameHand : ARRAY OF PokerHand) : CARDINAL;
VAR
  Score,x,y,t             : CARDINAL;
  RowTotal,ColTotal,Total : CARDINAL;
  Hand                    : PokerHand;

BEGIN
   RowTotal := 0; ColTotal := 0; t := 2;
   (* Score rows *)
   FOR x := 0 TO 4 DO
      FOR y := 0 TO 4 DO Hand[y] := GameHand[x][y] END;
      SortHand(Hand); Score := ScoreHand(Hand); 
      RowTotal := RowTotal + Score;
      PutCursor(9+x,54); WriteCard(Score,2);
   END;
   PutCursor(14,53); WriteCard(RowTotal,3);
   (* Score Columns *)
   FOR x := 0 TO 4 DO
      FOR y := 0 TO 4 DO Hand[y] := GameHand[y][x] END;
      SortHand(Hand); Score := ScoreHand(Hand);
      ColTotal := ColTotal + Score;
      PutCursor(9+x,66); WriteCard(Score,2);
   END;
   PutCursor(14,65); WriteCard(ColTotal,3);
   Total := RowTotal + ColTotal;
   PutCursor(14,75); WriteCard(Total,3);
   RETURN(Total);
END ScoreGame;
(*FF*)
PROCEDURE DrawHighScores(handle : INTEGER; HighMarks : ARRAY OF HighScore);
VAR
  Sxy        : PxyArrayType;
  x          : CARDINAL;
  dummy      : INTEGER;

BEGIN
   Sxy[0] := 360; Sxy[1] := 4; Sxy[2] := 624; Sxy[3] := 56;
   HideCursor(handle); 
   dummy := SetFillColour(handle,1); (* white *)
   dummy := SetLineColour(handle,0); (* black *)
   dummy := SetFillInteriorStyle(handle,1); FillRectangle(handle,Sxy);
   DrawFrame(handle,Sxy[0],Sxy[1],Sxy[2],Sxy[3],0,1);
   SelectCharColor(0); SelectBackColor(1);
   Print(2,57,"HIGH SCORES",FALSE);
   FOR x := 0 TO 4 DO
      Print(3+x,47,HighMarks[x].Name,FALSE); 
      PutCursor(3+x,73); WriteCard(HighMarks[x].Score,5);
   END;
   ShowCursor(handle,0);
END DrawHighScores;

PROCEDURE DrawHandScoreValues(handle : INTEGER);
VAR  Sxy   : PxyArrayType;
     Dummy : INTEGER;
BEGIN
   Sxy[0] := 360; Sxy[1] := 115; Sxy[2] := 525; Sxy[3] := 196;
   HideCursor(handle);  
   Dummy := SetFillColour(handle,1); (* white *)
   Dummy := SetFillInteriorStyle(handle,1);
   FillRectangle(handle,Sxy); Dummy := SetLineColour(handle,0); (*black*)
   DrawFrame(handle,Sxy[0],Sxy[1],Sxy[2],Sxy[3],0,1);
   Sxy[0] := 360; Sxy[1] := 58; Sxy[2] := 624; Sxy[3] := 113;
   FillRectangle(handle,Sxy);
   DrawFrame(handle,Sxy[0],Sxy[1],Sxy[2],Sxy[3],0,1);
   SelectCharColor(0); SelectBackColor(1);
   Print(9,47, "Row1:  __ Column1: __",FALSE);
   Print(10,47,"Row2:  __ Column2: __",FALSE);
   Print(11,47,"Row3:  __ Column3: __",FALSE);
   Print(12,47,"Row4:  __ Column4: __",FALSE);
   Print(13,47,"Row5:  __ Column5: __",FALSE);
   Print(14,47,"Total:___ Total:  ___ Score:___",FALSE);
   Print(16,47,"Hand Scoring Values",FALSE);
   Print(17,47,"Straight flush   30",FALSE);
   Print(18,47,"Four of kind     16",FALSE);
   Print(19,47,"Straight         12",FALSE);
   Print(20,47,"Full house       10",FALSE);
   Print(21,47,"Three of kind     6",FALSE);
   Print(22,47,"Flush             5",FALSE);
   Print(23,47,"Two pairs         3",FALSE);
   Print(24,47,"One pair          1",FALSE);
   ShowCursor(handle,0);
END DrawHandScoreValues;

(*FF*)
PROCEDURE DoIt(handleid : INTEGER);
VAR 
  mx,my,ms,ks,Choice,Warn,Res : INTEGER;
  Score,x,y,z,row,col,Drive   : CARDINAL;
  OldFont                     : ADDRESS;
  Logo                        : ARRAY[0..120] OF CHAR;
  Path                        : ARRAY[0..120] OF CHAR;
  OldPalette                  : Palette;
  CardDeck,PlayCards          : ARRAY[0..51] OF CARDINAL;
  SlotEmpty                   : ARRAY[0..4] OF PlaySlot;
  GameHand                    : ARRAY[0..4] OF PokerHand;
  Sxy                         : PxyArrayType;
  Valid,WantToPlay            : BOOLEAN;
  Menu                        : DropDownMenu;
  HighMarks                   : ARRAY [0..4] OF HighScore;
  Sprite1                     : SPRITE;

PROCEDURE Init();
BEGIN
  SavePalette(OldPalette); AssignStr(Logo,"A:\LOGO.SP1");
  GetDrv(Drive); Logo[0] := CHR(65+Drive); GetPath(Path,Drive+1);
  IF (Path[0] # 0C) THEN InsertStr(Logo,Path,3) END;
  InitSprite(Sprite1,handleid);
  HideCursor(handleid); LoadHighScores(HighMarks); 
  AddDropDownMenu(Menu," OPTIONS  ",16,69);
  AddDropDownSubMenu(Menu," New Game ");
  AddDropDownSubMenu(Menu," Help     ");
  AddDropDownSubMenu(Menu," Exit     "); WantToPlay := TRUE;
  LoadCardFile(handleid,ScreenPhysicalBase());
  LoadSprite(Sprite1,Logo);
  SetPage(3); SelectCharColor(0); SelectBackColor(1);
  ReplaceStr(Logo,"LOGO.SP1","POKER.SC1");
  Res := LoadPicture(handleid,Logo); SetPage(1); 
END Init;
(*FF*)
BEGIN
  Init(); HelpScreen();
  WHILE WantToPlay DO
     DrawScreen(handleid); InitDeck(CardDeck);
     InitGameCardSlots(SlotEmpty); ShuffleCards(PlayCards,CardDeck);
     FOR y := 0 TO 4 DO
        FOR x := 0 TO 4 DO PutCard(handleid,502,(y*35)+4,(x*66)+16) END;
     END; 
     DrawHighScores(handleid,HighMarks); DrawHandScoreValues(handleid);
     PrintMenuTitle(handleid,Menu); z := 0; Choice := 0;
     PutCard(handleid,PlayCards[z],166,560); (* stock pile *) 
     GrafMouse(3,0); ShowCursor(handleid,0); PutSprite(Sprite1,556,130,3);
     WHILE (z < 25) & (Choice = 0) DO
        GrafMouseKeyboardState(mx,my,ms,ks);
        IF (ms = 1) THEN
           Valid := Convert(mx,my,row,col);
           IF (Valid) & (SlotEmpty[row][col]) THEN
              SlotEmpty[row][col] := FALSE;
              GameHand[row][col] := PlayCards[z];
              PutCard(handleid,PlayCards[z],(row*35)+4,(col*66)+16);
              INC(z);
              IF (z < 25) THEN PutCard(handleid,PlayCards[z],166,560);
                          ELSE PutCard(handleid,502,166,560);
              END;
           END;
           WHILE(ms = 1) DO GrafMouseKeyboardState(mx,my,ms,ks) END;
        END;      
        Choice := PlayAgain(handleid,Menu);
        IF (Choice = 2) THEN HelpScreen(); Choice := 0; END;
        IF (Choice = 3) THEN
            Warn := FormAlert(2,"[3][ WANT TO QUIT? ][ YES | NO ]");
            IF (Warn = 2) THEN Choice := 0; END; 
        END;
     END; (* End of current game loop *)
     IF Choice = 0 THEN
        Score := ScoreGame(GameHand);
        SeeIfHighScore(handleid,HighMarks,Score);
        REPEAT
          Choice := PlayAgain(handleid,Menu);
          CASE Choice OF
             1 : WantToPlay := TRUE;                          |
             2 : HelpScreen();                                |
             3 : Warn := FormAlert(2,"[3][ WANT TO QUIT? ][ YES | NO ]");
                 IF (Warn = 1) THEN WantToPlay := FALSE; END; |
          ELSE END;
        UNTIL (Choice = 1) OR (Choice = 3);
        GrafMouse(3,0);
     ELSE
        IF (Choice = 3) THEN WantToPlay := FALSE; 
        ELSE WantToPlay := TRUE;
        END;
     END;
  END;    (* End of game loop *) 
  SaveHighScores(HighMarks); FreeAllPages;
  SetPalette(OldPalette); SelectCharColor(1); SelectBackColor(0);
END DoIt;

BEGIN
  OpenStation(handleid,Workout);
  Resolution := GetResolution();
  IF Resolution = 1 THEN
     AssignStr(File,"A:\CARD.SC1"); OK := TRUE;
     GetDrv(Drive); File[0] := CHR(65+Drive); GetPath(Path,Drive+1);
     IF (Path[0] # 0C) THEN InsertStr(File,Path,3) END;
     Found := Find(File);
     IF NOT Found THEN 
        Warn := FormAlert(1,"[1][ CARD.SC1 FILE NOT FOUND! ][ OK ]");
        OK := FALSE;
     END;
     ReplaceStr(File,"CARD.SC1","LOGO.SP1"); Found := Find(File);
     IF NOT Found THEN
         Warn := FormAlert(1,"[1][ LOGO.SP1 FILE NOT FOUND! ][ OK ]");
         OK := FALSE;
     END;
     ReplaceStr(File,"LOGO.SP1","POKER.SC1"); Found := Find(File);
     IF NOT Found THEN
         Warn := FormAlert(1,"[1][ POKER.SC1 FILE NOT FOUND! ][ OK ]");
         OK := FALSE;
     END;
     IF OK THEN DoIt(handleid) END;
  ELSE
     Warn := FormAlert(1,"[1][ MUST BE IN MEDIUM RESOLUTION!][ OK ]");
  END;
  CloseVirtualWorkstation(handleid);
END CardGame.

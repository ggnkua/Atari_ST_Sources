(**********************************************************************)
(*   LIBRARY NAME      : CardGame                                     *)
(*   WRITTEN BY        : Carolyn Rogers                               *)
(*                     : Copyright 1989 Antic Publishing Inc.         *)
(*   DATE WRITTEN      : May 1988                                     *)
(*   LANGUAGE          : MODULA-2 BY TDI Software                     *)
(*   PROGRAM PURPOSE   : Card routines                                *)
(**********************************************************************)
IMPLEMENTATION MODULE Cards;
FROM AESForms    IMPORT FormAlert;
FROM AESGraphics IMPORT GrafMouse;
FROM DropDown    IMPORT DropDownMenu,PrintMenuTitle,RunMenu,MoniterMenu;
FROM GEMDOS      IMPORT Open,Close,Create,Read,Write,DirCreate,
                        GetDrv,ConOut,GetPath;
FROM GEMVDIbase  IMPORT PxyArrayType;
FROM Graphics    IMPORT LoadPicture,InitSprite,PutSprite,GetSprite,SPRITE,
                        FreeSprite;
FROM Screen      IMPORT SetPage,InitScreen,ShowPage;
FROM String      IMPORT Len,AssignStr,MidStr,OverWriteStr,InsertStr;
FROM Stuff       IMPORT DrawFrame,PutPixel;
FROM SysMan      IMPORT GetRandomNumber;
FROM SYSTEM      IMPORT ADDRESS,ADR;
FROM TextIO      IMPORT WriteInt,WriteCard,WriteLn;
FROM VDIAttribs  IMPORT SetFillInteriorStyle,SetFillPerimeterVisibility,
                        SetFillColour;
FROM VDIInputs   IMPORT HideCursor,ShowCursor;
FROM VDIOutputs  IMPORT DrawBar;
FROM VTMode      IMPORT PutCursor,Print,NewColor,SelectCharColor,
                        Black,ClearHome,CursorOff,SelectBackColor;
(*FF*)
PROCEDURE MixText(VAR Str : ARRAY OF CHAR; 
                  Row,Col,StartColor,StopColor,BackGround : CARDINAL);
VAR
  Repeat,Cycle,x : CARDINAL;
 
BEGIN
   Repeat := StopColor - StartColor + 1; Cycle := 0; PutCursor(Row,Col);
   SelectBackColor(3);
   FOR x := 0 TO Len(Str)-1 DO
      IF Str[x] = " " THEN 
         SelectCharColor(BackGround);
      ELSE
         SelectCharColor(StartColor+Cycle); INC(Cycle);
      END;
      ConOut(Str[x]);
      IF (Cycle MOD Repeat) = 0 THEN Cycle := 0 END;
   END;
   SelectCharColor(0);  Print(Row,Col,Str,FALSE); SelectBackColor(1);
END MixText;

PROCEDURE PlayAgain(handle : INTEGER; VAR Menu : DropDownMenu) : INTEGER;
VAR
  InMenu    : BOOLEAN;
  SubMenuId : INTEGER;

BEGIN
   (* 0 - Not in menu  1 - new game 2 - help screen 3 - exit program *)
   SubMenuId := 0;
   InMenu := MoniterMenu(Menu);
   IF InMenu THEN SubMenuId := RunMenu(handle,Menu); GrafMouse(3,0); END;
   RETURN (SubMenuId);
END PlayAgain;

PROCEDURE InitDeck(VAR CardDeck : ARRAY OF CARDINAL);
VAR
  x,y,z : CARDINAL;

BEGIN
  z := 0;
  FOR x := 1 TO 4 DO
    CardDeck[z] := x * 100; INC(z);
    FOR y := 2 TO 13 DO
       CardDeck[z] := (x*100) + y; INC(z);
    END;
  END;
END InitDeck;
(*FF*)
PROCEDURE ShuffleCards(VAR ShuffledDeck,CardDeck : ARRAY OF CARDINAL);
VAR
  Hit    : CARDINAL;
  Card   : LONGCARD;

BEGIN
   Hit := 0;
   WHILE (Hit < 52) DO
      Card := GetRandomNumber(52);
      IF (CardDeck[CARDINAL(Card)] # 0) THEN 
         ShuffledDeck[Hit] := CardDeck[CARDINAL(Card)];
         CardDeck[CARDINAL(Card)] := 0; INC(Hit);
      END;
   END;
END ShuffleCards;

PROCEDURE GetFace (Card : CARDINAL) : CARDINAL;
VAR
  Face : CARDINAL;

BEGIN
  Face := Card MOD 100;
  RETURN (Face);   
END GetFace;

PROCEDURE GetSuit(Card : CARDINAL) : CARDINAL;
VAR
  Face,Suit : CARDINAL;

BEGIN
   Face := GetFace(Card);
   Suit := (Card - Face) DIV 100;
   RETURN (Suit); 
END GetSuit;

PROCEDURE LoadCardFile(handle : INTEGER; ScreenAdr : ADDRESS);
VAR
  Drive      : CARDINAL;
  Resolution : INTEGER;
  Filename   : ARRAY[0..120] OF CHAR;
  Path       : ARRAY[0..120] OF CHAR;

BEGIN
   InitScreen(handle,ScreenAdr); 
   SetPage(2); AssignStr(Filename,"A:\CARD.SC1");
   GetDrv(Drive); Filename[0] := CHR(65+Drive); GetPath(Path,Drive+1);
   IF (Path[0] # 0C) THEN InsertStr(Filename,Path,3) END;
   Resolution := LoadPicture(handle,Filename); SetPage(1);
END LoadCardFile;
(*FF*)
PROCEDURE PutCard(handle : INTEGER; Card,Row,Col : CARDINAL);
VAR
  Face,Suit,x1,y1,x2,y2 : CARDINAL;
  Sprite                : SPRITE;

BEGIN
  IF Card = 502 THEN Face := 2; Suit := 5;     (* blank card   *)
  ELSIF Card = 503 THEN Face := 3; Suit := 5;  (* Empty slot *)
  ELSIF Card = 500 THEN Face := 0; Suit := 5;  (* back of card *)
  ELSE Face := GetFace(Card); Suit := GetSuit(Card);
  END;
  IF Face = 0 THEN Face := 1 END;
  x1 := ((Face-1)*49)+3; y1 := ((Suit-1)*35)+17; 
  x2 := x1 + 46; y2 := y1 + 30; HideCursor(handle);
  InitSprite(Sprite,handle); SetPage(2);
  GetSprite(Sprite,x1,y1,x2,y2,3); SetPage(1);
  PutSprite(Sprite,Col,Row,3); FreeSprite(Sprite); ShowCursor(handle,0);
END PutCard;

PROCEDURE ReplaceChar(VAR Str : ARRAY OF CHAR; Rchar,Tchar : CHAR);
VAR x : CARDINAL;

BEGIN
   FOR x := 0 TO HIGH(Str) DO
      IF (Str[x] = Rchar) THEN Str[x] := Tchar END;
   END;     
END ReplaceChar;

PROCEDURE CheckFlush(Hand : PokerHand) : BOOLEAN;
VAR
  x,FlushSuit,Suit : CARDINAL;
  Flush            : BOOLEAN;

BEGIN
  FlushSuit := GetSuit(Hand[0]); Flush := TRUE;
  FOR x := 1 TO 4 DO
    Suit := GetSuit(Hand[x]);
    IF (Suit # FlushSuit) THEN Flush := FALSE END;
  END;
  RETURN(Flush);
END CheckFlush;
(*FF*)
PROCEDURE CheckStraight(Hand : PokerHand) : BOOLEAN;
VAR
  OldFace,Face,x : CARDINAL;
  Straight       : BOOLEAN;

BEGIN
  OldFace := GetFace(Hand[0]); Straight := TRUE;
  IF ((OldFace = 0) & (GetFace(Hand[1]) = 10)) THEN 
      OldFace := 9;                          (* Maybe Ace high straight *) 
  ELSE 
     IF (OldFace = 0) THEN OldFace := 1 END; (* Maybe Ace low straight  *)
  END;
  FOR x := 1 TO 4 DO
    Face := GetFace(Hand[x]);
    IF (OldFace # Face-1) THEN Straight := FALSE ELSE OldFace := Face END;
  END;
  RETURN(Straight);
END CheckStraight;

PROCEDURE CheckFourKind(Hand : PokerHand) : BOOLEAN;
VAR
   x        : CARDINAL;
   FourKind : BOOLEAN;

BEGIN
   FourKind := TRUE;
   IF (GetFace(Hand[0]) = GetFace(Hand[1])) THEN
      FOR x := 2 TO 3 DO
          IF (GetFace(Hand[0]) # GetFace(Hand[x]))
             THEN FourKind := FALSE END;
     END;
   ELSIF (GetFace(Hand[1]) = GetFace(Hand[2])) THEN
     FOR x := 3 TO 4 DO
         IF (GetFace(Hand[1]) # GetFace(Hand[x]))
            THEN FourKind := FALSE END;
     END;
   ELSE
      FourKind := FALSE;  
   END;
   RETURN (FourKind);
END CheckFourKind;

PROCEDURE CheckThreeKind(Hand : PokerHand) : BOOLEAN;
VAR
  ThreeKind : BOOLEAN;

BEGIN
   IF (GetFace(Hand[0]) = GetFace(Hand[1])) &
      (GetFace(Hand[0]) = GetFace(Hand[2])) THEN ThreeKind := TRUE;
   ELSIF (GetFace(Hand[1]) = GetFace(Hand[2])) &
         (GetFace(Hand[1]) = GetFace(Hand[3])) THEN ThreeKind := TRUE;
   ELSIF (GetFace(Hand[2]) = GetFace(Hand[3])) &
         (GetFace(Hand[2]) = GetFace(Hand[4])) THEN ThreeKind := TRUE;
   ELSE ThreeKind := FALSE END;
   RETURN (ThreeKind);
END CheckThreeKind;
(*FF*)
PROCEDURE CheckPairs(Hand : PokerHand) : CARDINAL;
VAR
  x, Pair : CARDINAL;

BEGIN
     Pair := 0;
     FOR x := 0 TO 3 DO
        IF (GetFace(Hand[x]) = GetFace(Hand[x+1])) THEN INC(Pair) END;
     END;
     RETURN(Pair); (* 0 - No pairs, 1 - One pair, 2 - Two pairs *);
END CheckPairs;

PROCEDURE CheckOnePair(Hand : PokerHand) : BOOLEAN;
VAR
  Pair : CARDINAL;

BEGIN
    Pair := CheckPairs(Hand);
    IF (Pair = 1) THEN RETURN(TRUE) ELSE RETURN(FALSE) END;
END CheckOnePair;

PROCEDURE CheckTwoPair(Hand : PokerHand) : BOOLEAN;
VAR
  Pair : CARDINAL;

BEGIN
    Pair := CheckPairs(Hand);
    IF (Pair = 2) THEN RETURN(TRUE) ELSE RETURN(FALSE) END;
END CheckTwoPair;

PROCEDURE CheckFullHouse(Hand : PokerHand) : BOOLEAN;
VAR
  Pair              : CARDINAL;
  ThreeKind         : BOOLEAN;

BEGIN
   ThreeKind := CheckThreeKind(Hand);
   Pair := CheckPairs(Hand);
   IF (ThreeKind) & (Pair = 3) THEN RETURN (TRUE) ELSE RETURN(FALSE) END;
END CheckFullHouse;
(*FF*)
PROCEDURE ScoreHand (Hand : PokerHand) : CARDINAL;
VAR
  Score          : CARDINAL;
  Flush,Straight : BOOLEAN;

BEGIN
  Flush := CheckFlush(Hand); Straight := CheckStraight(Hand);
  IF (NOT Flush) & (NOT Straight) THEN
     IF (CheckFourKind(Hand)) THEN Score := 16;
        ELSIF (CheckFullHouse(Hand)) THEN Score := 10;
        ELSIF (CheckThreeKind(Hand)) THEN Score := 6;
        ELSIF (CheckTwoPair(Hand)) THEN Score := 3;
        ELSIF (CheckOnePair(Hand)) THEN Score := 1;
        ELSE Score := 0;
     END;
  ELSE
     IF (Flush) & (Straight) THEN Score := 30;
        ELSIF Flush THEN Score := 5;
        ELSE Score := 12;
     END;
  END;
  RETURN(Score);    
END ScoreHand;

PROCEDURE SortHand(VAR Hand : PokerHand);
VAR
  Temp,x,y : CARDINAL;

BEGIN
   FOR x := 0 TO 3 DO
     FOR y := x+1 TO 4 DO
        IF (GetFace(Hand[x]) > GetFace(Hand[y])) THEN
           Temp := Hand[x]; Hand[x] := Hand[y]; Hand[y] := Temp;
        END;
     END;
   END;
END SortHand;

PROCEDURE DrawScreen(handle : INTEGER);
VAR
  Sxy : PxyArrayType;
  Old : INTEGER;

BEGIN
   Sxy[0] := 1; Sxy[1] := 1; Sxy[2] := 638; Sxy[3] := 199; 
   Old := SetFillColour(handle,3); Old := SetFillInteriorStyle(handle,1);
   Old := SetFillPerimeterVisibility(handle,1); HideCursor(handle);
   DrawBar(handle,Sxy); DrawFrame(handle,Sxy[0],Sxy[1],Sxy[2],Sxy[3],1,1);
   Old := SetFillColour(handle,0); Old := SetFillInteriorStyle(handle,0);
   Old := SetFillPerimeterVisibility(handle,1);
END DrawScreen;
END Cards.

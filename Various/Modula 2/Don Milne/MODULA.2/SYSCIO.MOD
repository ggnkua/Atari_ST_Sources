IMPLEMENTATION MODULE SYSCIO;

IMPORT BIOS;

(*
TYPE Devices    = BIOS.Device; (* PRT Printer, Parallel Port
                                  AUX Aux Device, Serial, Modem Port
                                  CON Console, Screen
                                  HSS High Speed Serial, MIDI Port
                                  KBD Intelligent Keyboard *)
*)

VAR WorkString:    ARRAY[0..20] OF CHAR;
    i1,i2,i3:      INTEGER;
    EditWorkStr:   ARRAY[0..60] OF CHAR;
    EditSourceStr: ARRAY[0..20] OF CHAR;

PROCEDURE KeyPressed() : BOOLEAN;

BEGIN

  RETURN BIOS.BConStat(BIOS.CON);

END KeyPressed;

PROCEDURE Read(VAR Data : CHAR);

BEGIN

  WITH KeyBoardData DO
       KeyData.LData1 := BIOS.BConIn(BIOS.CON);
       KeyStatus := BIOS.GetKBShift();
       Data := KeyData.Data4;
  END;

END Read;

PROCEDURE ReadInt(VAR Data : INTEGER);

BEGIN

END ReadInt;

PROCEDURE ReadCard(VAR Data : CARDINAL);

BEGIN

END ReadCard;

PROCEDURE ReadLongInt(VAR Data : LONGINT);

BEGIN

END ReadLongInt;

PROCEDURE ReadLongCard(VAR Data : LONGCARD);

BEGIN

END ReadLongCard;

PROCEDURE ReadString(VAR Data : ARRAY OF CHAR);

BEGIN

END ReadString;

PROCEDURE IValToStr(    IVal : LONGINT;
                    VAR S    : ARRAY OF CHAR;
                        Size : CARDINAL);

VAR I:          CARDINAL;
    Data:       LONGINT;

BEGIN

  FOR I := 0 TO (Size - 1) DO
      S[I] := ' ';
  END;

  Data := IVal;

  IF Data = 0
     THEN S[Size - 1] := '0';
     ELSE I := Size;
          REPEAT DEC(I);
                 S[I] := CHR(CARDINAL(Data MOD 10) + ORD('0'));
                 Data := Data DIV 10;
          UNTIL (Data = 0) OR
                (I    = 0);
  END;

  IF Size < HIGH(S)
     THEN S[Size] := 0C;
  END;

END IValToStr;

PROCEDURE CValToStr(    IVal : LONGCARD;
                    VAR S    : ARRAY OF CHAR;
                        Size : CARDINAL);

VAR I:          CARDINAL;
    Data:       LONGCARD;

BEGIN

  FOR I := 0 TO (Size - 1) DO
      S[I] := ' ';
  END;

  Data := IVal;

  IF Data = 0
     THEN S[Size - 1] := '0';
     ELSE I := Size;
          REPEAT DEC(I);
                 S[I] := CHR(CARDINAL(Data MOD 10) + ORD('0'));
                 Data := Data DIV 10;
          UNTIL (Data = 0) OR
                (I    = 0);
  END;

  IF Size < HIGH(S)
     THEN S[Size] := 0C;
  END;

END CValToStr;

PROCEDURE Write(Data : CHAR);

BEGIN

  BIOS.BConOut(BIOS.CON,Data);

END Write;

PROCEDURE WriteString(VAR Data : ARRAY OF CHAR);

VAR i:  CARDINAL;

BEGIN

  i := 0;

  FOR i := 0 TO HIGH(Data) DO
      IF Data[i] # 0C
         THEN Write(Data[i]);
         ELSE RETURN;
      END;
  END;

END WriteString;

PROCEDURE WriteLongInt(Data : LONGINT; Size : INTEGER);

VAR i: CARDINAL;

BEGIN

  IValToStr(LONGINT(Data),WorkString,Size);

  IF Data < 0
     THEN IF WorkString[0] # ' '
             THEN WorkString[0] := '*';
             ELSE i := 0;
                  WHILE (WorkString[i] = ' ')   DO
                        INC(i);
                  END;
                  WorkString[i - 1] := '-';
          END;
  END;

  WriteString(WorkString);

END WriteLongInt;

PROCEDURE WriteInt(Data : INTEGER; Size : INTEGER);

BEGIN

  WriteLongInt(LONGINT(Data),Size);

END WriteInt;

PROCEDURE WriteLongCard(Data : LONGCARD; Size : INTEGER);

VAR i: CARDINAL;

BEGIN

  CValToStr(Data,WorkString,Size);

  WriteString(WorkString);

END WriteLongCard;

PROCEDURE WriteCard(Data : CARDINAL; Size : INTEGER);

BEGIN

  WriteLongCard(LONGCARD(Data),Size);

END WriteCard;

PROCEDURE WriteLn;

BEGIN

  Write(CHR(13)); Write(CHR(10));

END WriteLn;

PROCEDURE GoToXY(Col,Row : CARDINAL);

BEGIN

  Write(CHR(27)); Write('Y');
  Write(CHR(31 + Row));
  Write(CHR(31 + Col));

END GoToXY;

PROCEDURE EditLongCard(VAR To : ARRAY OF CHAR;
                       VAR Pat: ARRAY OF CHAR;
                           From:LONGCARD);

BEGIN

  CValToStr(From,EditSourceStr,10);

  i2 := HIGH(Pat);

  WHILE (Pat[i2] # 0C) AND
        (i2      # 0)  DO
        DEC(i2);
  END;

  IF i2 = 0
     THEN i2 := HIGH(Pat);
     ELSE DEC(i2);
  END;

  EditWorkStr[i2 + 1] := 0C;

  i1 := 9;

  REPEAT
         CASE Pat[i2] OF
           'Z','z' : EditWorkStr[i2] := EditSourceStr[i1];
                     IF EditWorkStr[i2] = ' '
                        THEN IF (EditWorkStr[i2 + 1] = ',') OR
                                (EditWorkStr[i2 + 1] = '.')
                                THEN EditWorkStr[i2 + 1] := ' ';
                             END;
                     END;
                     IF i1 > 0
                        THEN DEC(i1);
                     END;
                     DEC(i2);
         | '9'     : IF EditSourceStr[i1] = ' '
                        THEN EditWorkStr[i2] := '0';
                        ELSE EditWorkStr[i2] := EditSourceStr[i1];
                     END;
                     IF i1 > 0
                        THEN DEC(i1);
                     END;
                     DEC(i2);
         | '$'     : IF EditWorkStr[i2 + 1] = ' '
                        THEN i3 := i2 + 1;
                             WHILE EditWorkStr[i3] = ' ' DO
                                   INC(i3);
                             END;
                             EditWorkStr[i3 - 1] := '$';
                        ELSE EditWorkStr[i2]     := '$';
                     END;
                     DEC(i2);
         | ','     : IF EditWorkStr[i2 + 1] = ' '
                        THEN EditWorkStr[i2] := ' ';
                             DEC(i2);
                        ELSE EditWorkStr[i2] := ',';
                             DEC(i2);
                     END;
         | '.'     : IF EditWorkStr[i2 + 1] = ' '
                        THEN EditWorkStr[i2] := ' ';
                             DEC(i2);
                        ELSE EditWorkStr[i2] := '.';
                             DEC(i2);
                     END;
         | ELSE      EditWorkStr[i2] := Pat[i2];
                     DEC(i2);
         END;
  UNTIL i2 < 0;

  IF HIGH(To) <= HIGH(EditWorkStr)
     THEN i2 := HIGH(To);
     ELSE i2 := HIGH(EditWorkStr);
  END;

  i1 := 0;

  WHILE (i1 <= i2) AND
        (EditWorkStr[i1] # 0C) DO
        To[i1] := EditWorkStr[i1];
        INC(i1);
  END;

  IF i1 <= i2
     THEN To[i1] := 0C;
  END;

END EditLongCard;


PROCEDURE EditCard(VAR To : ARRAY OF CHAR;
                   VAR Pat: ARRAY OF CHAR;
                       From:CARDINAL);

BEGIN

  EditLongCard(To,Pat,LONGCARD(From));

END EditCard;

PROCEDURE KEyPressed(Dev : Devices) : BOOLEAN;

BEGIN

  RETURN BIOS.BConStat(Dev);

END KEyPressed;

PROCEDURE REad(Dev : Devices; VAR Data : CHAR);

BEGIN

  IF Dev = BIOS.CON
     THEN Read(Data);
     ELSE Data := CHAR(BITSET(BIOS.BConIn(Dev)) * {0..7});
  END;

END REad;

PROCEDURE REadInt(Dev : Devices; VAR Data : INTEGER);

BEGIN

END REadInt;

PROCEDURE REadCard(Dev : Devices; VAR Data : CARDINAL);

BEGIN

END REadCard;

PROCEDURE REadLongInt(Dev : Devices; VAR Data : LONGINT);

BEGIN

END REadLongInt;

PROCEDURE REadLongCard(Dev : Devices; VAR Data : LONGCARD);

BEGIN

END REadLongCard;

PROCEDURE REadString(Dev : Devices; VAR Data : ARRAY OF CHAR);

BEGIN

END REadString;

PROCEDURE WRite(Dev : Devices; Data : CHAR);

BEGIN

  BIOS.BConOut(BIOS.Device(Dev),Data);

END WRite;

PROCEDURE WRiteString(Dev : Devices; VAR Data : ARRAY OF CHAR);

VAR i:  CARDINAL;

BEGIN

  FOR i := 0 TO HIGH(Data) DO
      IF Data[i] # 0C
         THEN WRite(Dev,Data[i]);
         ELSE RETURN;
      END;
  END;

END WRiteString;

PROCEDURE WRiteLongInt(Dev : Devices; Data : LONGINT; Size : INTEGER);

VAR i: CARDINAL;

BEGIN

  IValToStr(LONGINT(Data),WorkString,Size);

  IF Data < 0
     THEN IF WorkString[0] # ' '
             THEN WorkString[0] := '*';
             ELSE i := 0;
                  WHILE (WorkString[i] = ' ')   DO
                        INC(i);
                  END;
                  WorkString[i - 1] := '-';
          END;
  END;

  WRiteString(Dev,WorkString);

END WRiteLongInt;

PROCEDURE WRiteInt(Dev : Devices; Data : INTEGER; Size : INTEGER);

BEGIN

  WRiteLongInt(Dev,LONGINT(Data),Size);

END WRiteInt;

PROCEDURE WRiteLongCard(Dev : Devices; Data : LONGCARD; Size : INTEGER);

VAR i: CARDINAL;

BEGIN

  CValToStr(Data,WorkString,Size);

  WRiteString(Dev,WorkString);

END WRiteLongCard;

PROCEDURE WRiteCard(Dev : Devices; Data : CARDINAL; Size : INTEGER);

BEGIN

  WRiteLongCard(Dev,LONGCARD(Data),Size);

END WRiteCard;

PROCEDURE WRiteLn;

BEGIN

  Write(CHR(13)); Write(CHR(10));

END WRiteLn;

END SYSCIO.

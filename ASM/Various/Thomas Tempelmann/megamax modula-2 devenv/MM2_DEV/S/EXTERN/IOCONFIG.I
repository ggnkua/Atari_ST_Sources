IMPLEMENTATION MODULE IOConfig;

FROM SysTypes IMPORT CHARSET;

PROCEDURE Wirth;
  BEGIN
    HALT
  END Wirth;

PROCEDURE Terminal;
  BEGIN
    HALT
  END Terminal;

PROCEDURE Megamax;
  BEGIN
    EchoCR:= FALSE;
    ReadStringByLine:= TRUE;
    WriteLnAfterReadString:= TRUE;
  END Megamax;

BEGIN
  Megamax;
  LengthOfBufferedLine:= 80;
  Separators:= CHARSET {0C..' '};
END IOConfig.

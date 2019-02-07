MODULE Hello;

FROM ApplMgr   IMPORT ApplInit,ApplExit;
FROM FormMgr   IMPORT FormAlert;
FROM PORTAB    IMPORT UNSIGNEDWORD;
FROM SYSTEM    IMPORT ADR;

VAR Button     : UNSIGNEDWORD;
    AlertString: ARRAY[0..255] OF CHAR;

BEGIN
  IF ApplInit() >= 0 THEN
    AlertString:= "[1][| Hello World! |][  OK  ]";
    Button:= FormAlert(1,ADR(AlertString));
    ApplExit;
  END;
END Hello.

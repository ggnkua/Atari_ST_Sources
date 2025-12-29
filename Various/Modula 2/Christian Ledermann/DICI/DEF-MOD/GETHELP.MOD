IMPLEMENTATION MODULE GetHelp;

FROM INTRINSIC  IMPORT PTR;

FROM ApplMgr    IMPORT ApplWrite,ApplFind;

FROM pSTRING IMPORT APPEND;

FROM PORTAB     IMPORT UNSIGNEDWORD,SIGNEDWORD,ANYPOINTER,ANYTYPE;

VAR    STGuideBuffer : RECORD 
                               I0,
                               I1,
                               I2 : INTEGER;
                          PathPtr : ANYPOINTER;
                               I5,
                               I6,
                               I7 : INTEGER;
                     END(*RECORD*);

    PathBuffer : ARRAY [0..255] OF CHAR;

PROCEDURE CallSTGuide(ID: SIGNEDWORD; Text, Topic: ARRAY OF CHAR):BOOLEAN;
VAR Name : ARRAY[0..8] OF CHAR;
    id   : SIGNEDWORD;
BEGIN
   Name:="ST-GUIDE";
   PathBuffer:="*:\";
   APPEND(Text,PathBuffer);
   APPEND(' ',PathBuffer);
   APPEND(Topic,PathBuffer);
   id:= ApplFind( PTR(Name));
   STGuideBuffer.I0:=4711H;
   STGuideBuffer.I1:=ID;
   STGuideBuffer.I2:=0;
   STGuideBuffer.PathPtr:=PTR(PathBuffer);
   STGuideBuffer.I5:=0;
   STGuideBuffer.I6:=0;
   STGuideBuffer.I7:=0;
   IF (id#-1) THEN
       ApplWrite (id,16,STGuideBuffer);
   END(*IF*);
   RETURN (id#-1);
END CallSTGuide;

END GetHelp.

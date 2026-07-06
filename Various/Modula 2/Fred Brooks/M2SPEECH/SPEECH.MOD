IMPLEMENTATION MODULE          speech;

FROM    SYSTEM  IMPORT  ADDRESS,ADR,BYTE,REGISTER;

FROM    Strings IMPORT  Length;

FROM    GEMX    IMPORT  BasePageType;

FROM    XBIOS   IMPORT  SuperExec;

FROM    GEMDOS  IMPORT  Exec,ExecMode;

FROM    M2Conversions   IMPORT  ConvertCardinal;

TYPE    
        speechcodeptr     =      POINTER TO ARRAY [0..30000] OF BYTE;


VAR
        speechcode                      :       speechcodeptr;
        codeadr                         :       POINTER TO BasePageType;
        filename,nulls                  :       ARRAY [0..15] OF CHAR;
        filehandle,i,j,strlen,result    :       INTEGER;
        done,filter                     :       BOOLEAN;
        entry,talk                      :       ADDRESS;
        recordsize                      :       LONGCARD;
        r,p                             :       CARDINAL;

CONST
        codestart       =       1CH;
        codeinlup       =       2AH;
        codeentry       =       4EH;
        codebuffermax   =       28398;
        codebufferlen   =       28399;
        codebuffer      =       28400;

PROCEDURE       initspeechmodule(): BOOLEAN;
BEGIN
        filter:=TRUE;
        nulls:="";
        filename:="SPEECH.EXE";
        Exec(ExecMode(3),filename,nulls,nulls,result);
        codeadr:=REGISTER(0);

        IF LONGINT(codeadr)<LONGINT(0) THEN
        RETURN FALSE ;
        END; (* no SPEECH.EXE loaded *)

        speechcode:=codeadr^.CodeBase;
        entry:=speechcode;

        speechcode^[14]:=BYTE(78); (* put RTS in code *)
        speechcode^[15]:=BYTE(117);
        FOR i:=0 TO 13 DO          (* put NOP in code *)
            speechcode^[108+(i*2)]:=BYTE(78);
            speechcode^[109+(i*2)]:=BYTE(113);
        END;
        RETURN TRUE;
END     initspeechmodule;

PROCEDURE       setpitch(pitch: CARDINAL);
BEGIN
        pitch:=pitch+12325;
        IF pitch<=12415 THEN
           ConvertCardinal(pitch,6,nulls);
           nulls[0]:='!';
           filter:=FALSE;
           say(nulls);
           filter:=TRUE;
        END;
END             setpitch;

PROCEDURE       setrate(rate: CARDINAL);
BEGIN
        rate:=rate+20;
        IF rate<=127 THEN
           IF rate<100 THEN
              ConvertCardinal(rate,3,nulls);
           ELSE
              ConvertCardinal(rate,4,nulls);
           END;
           nulls[0]:='%';
           filter:=FALSE;
           say(nulls);
           filter:=TRUE;
        END;
END             setrate;

PROCEDURE       say(VAR text: ARRAY OF CHAR);
BEGIN
        strlen:=INTEGER(Length(text));
        IF strlen>0 THEN
           speechcode^[codebuffermax]:=BYTE(254);
           speechcode^[codebufferlen]:=BYTE(strlen);
           FOR i:=0 TO strlen-1 DO
           IF filter THEN
              IF text[i]='.' THEN text[i]:=' ' END;
              IF text[i]='!' THEN text[i]:=' ' END;
              IF text[i]='%' THEN text[i]:=' ' END;
              IF text[i]='[' THEN text[i]:=' ' END;
              IF text[i]=']' THEN text[i]:=' ' END;
              IF text[i]='{' THEN text[i]:=' ' END;
              IF text[i]='}' THEN text[i]:=' ' END;
           END;
           speechcode^[codebuffer+i]:=BYTE(text[i]);
           END;
 
           i:=INTEGER(speechcode^[0]);
           IF i = 72 THEN       (* check for correct code before jumping *)
              talk:=entry+50 ;
              (*$S- *)
              SuperExec(PROC(talk)); 
              (*$S+ *)
           END;
        END;
END     say;

BEGIN
END             speech.
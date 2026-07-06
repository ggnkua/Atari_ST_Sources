MODULE testClip;

(* Jefferson Software Copyright 1986 *)

(* Jefferson Software      *)
(* 12416 N 28th Dr #18-236 *)
(* Phoenix,  AZ 85029-2434 *)
(* (602)243-3106           *)

(* Phase BBS (602)849-1287 (up to 2400 baud) has source *)
(* and answers about Jefferson Software Modula in Sig 8 *)

(* Compuserve ID 73637, 1245 *)

(* Permission to use this source is given to all who   *)
(* agree to include Jefferson Software's copyright     *)
(* notice, address, and phone number in all copies of  *)
(* this source or source derived from this source.     *)
(* Please send any changes, updates or bugs to us at   *)
(* Jefferson Software. If you have code you want to    *)
(* share with us all, send it and any documentation to *)
(* us. Please tell us if you want your name included.  *)

FROM SYSTEM IMPORT ADR;

FROM Terminal IMPORT Read, Write, WriteLn, WriteString;

FROM ClipBoard IMPORT PClipInfo,
  InfoClip, LoadClip, PutClip, UnloadClip;

TYPE Code = (info, load, put, unload);

VAR Info : PClipInfo;
  buf : ARRAY [0..124] OF CHAR;
  ch : CHAR;

PROCEDURE Error(code : Code);
BEGIN
  WriteLn;
  CASE code OF
    info: WriteString('InfoClip error');
  | load: WriteString('LoadClip error');
  | put: WriteString('PutClip error');
  | unload: WriteString('Unloadclip error');
  END;
  WriteLn;
END Error;

PROCEDURE WriteLong(x : LONGINT);
VAR a, k : CARDINAL; dig : ARRAY [0..7] OF CARDINAL;
  n : RECORD
    CASE :CARDINAL OF
      0: d : LONGINT
    | 1: h, l : CARDINAL
    END
  END;
BEGIN
  n.d := x;
  FOR k := 0 TO 3 DO dig[k] := n.l MOD 16; n.l := n.l DIV 16 END;
  FOR k := 0 TO 3 DO dig[k+4] := n.h MOD 16; n.h := n.h DIV 16 END;
  FOR k := 7 TO 0 BY -1 DO 
    a := dig[k]; IF a > 9 THEN a := a + 7 END; Write(CHR(a + 30H));
  END;
END WriteLong;

BEGIN
  WriteLn;
  WriteString('Test of the Clipboard library');
  IF InfoClip(Info) = 0 THEN Error(info);
  ELSE
    WriteLn;
    IF Info^.where = 0 THEN  WriteString('not '); END;
    WriteString('in memory');
    WriteLn;
    IF Info^.dirty = 0 THEN  WriteString('not '); END;
    WriteString('"dirty"');
    WriteLn;
    WriteString(Info^.filename);
    WriteLn;
    WriteString('size '); WriteLong(Info^.size); Write('H');
    WriteLn;
    WriteString('at '); WriteLong(VAL(LONGINT,Info^.location)); Write('H');

    IF (Info^.where = 0) AND (LoadClip() # 0) THEN Error(load);
    ELSE 
      buf := '** Jefferson Software ** ';
      IF PutClip(25D , ADR(buf)) # 0 THEN Error(put);
      ELSE 
        IF UnloadClip() # 0 THEN Error(unload) END;
      END;
    END;
  END;
  Read(ch);
END testClip.

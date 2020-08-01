MODULE Cookie;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |8.3.93   |started
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Supervisor;

TYPE code* = ARRAY 5 OF CHAR;

VAR CookieJar : POINTER TO ARRAY 100 OF LONGINT;

PROCEDURE Available*() : BOOLEAN;
  (* returns TRUE if there is a cookie jar *)
 BEGIN
  Supervisor.On; S.GET(5A0H,CookieJar); Supervisor.Off;
  RETURN CookieJar # NIL
 END Available;

PROCEDURE Search*(Code : code; VAR Cont : LONGINT) : BOOLEAN;
  (* seraches the cookie jar for an entry with code Code and returns TRUE if
     found. Cont then contains the value entered in the jar *)
  VAR i : INTEGER; li : LONGINT;
 BEGIN
  IF Available() THEN i := 0; S.GET(S.ADR(Code),li);
    WHILE CookieJar[i] # 0 DO
      IF CookieJar[i] = li THEN Cont := CookieJar[i+1]; RETURN TRUE END;
      INC(i,2);
    END;
  END;
  RETURN FALSE
 END Search;

PROCEDURE Entry*(Code : code; Cont : LONGINT);
  (* entries a cookie if there is a cookie jar *)
  VAR i : INTEGER; li : LONGINT;
 BEGIN
  IF Available() THEN i := 0; S.GET(S.ADR(Code),li);
    WHILE CookieJar[i] # 0 DO INC(i,2) END;
    IF i DIV 2 < CookieJar[i+1] - 1 THEN
      CookieJar[i+2] := 0; CookieJar[i+3] := CookieJar[i+1];
      CookieJar[i] := li; CookieJar[i+1] := Cont;
    END;
  END;
 END Entry;

PROCEDURE Delete*(Code : code);
  (* deletes an entry in the cookie jar if found *)
  VAR i : INTEGER; li : LONGINT;
 BEGIN
  IF Available() THEN i := 0; S.GET(S.ADR(Code),li);
    WHILE CookieJar[i] # 0 DO
      IF CookieJar[i] = li THEN
        REPEAT
          CookieJar[i] := CookieJar[i+2]; CookieJar[i+1] := CookieJar[i+3];
          INC(i,2);
        UNTIL CookieJar[i-2] = 0;
        RETURN
      END;
      INC(i,2);
    END;
  END;
 END Delete;

END Cookie.
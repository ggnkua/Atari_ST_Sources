MODULE ShowCookies; (*$E MOS *)

(*
 * Zeigt die vorhandenen Cookies.
 * Bei einem Atari ST mit TOS < 1.6 sind in der Regel keine Cookies vorhanden!
 * Mehr dazu im Def-Text von 'CookieJar'.
 *
 * Achtung: Stoppt nicht nach der Ausgabe. In der Shell "Taste nach
 * TOS-Programmen" aktivieren!
 *)

FROM SYSTEM IMPORT CAST, LONGWORD;
FROM Console IMPORT WriteString, WriteLn;
FROM StrConv IMPORT LHexToStr;
FROM CookieJar IMPORT QueryCookies;

VAR shown: BOOLEAN;

PROCEDURE show (cookie: LONGWORD; VAR value: LONGWORD): BOOLEAN;
  TYPE String4 = ARRAY [0..3] OF CHAR;
  BEGIN
    IF shown THEN
      WriteLn
    END;
    WriteString ('Cookie: "');
    WriteString (CAST (String4, cookie));
    WriteString ('", value: ');
    WriteString (LHexToStr (value, 9));
    shown:= TRUE;
    RETURN TRUE
  END show;

BEGIN
  shown:= FALSE;
  QueryCookies (show);
  IF NOT shown THEN
    WriteString ('No cookies!')
  END;
END ShowCookies.

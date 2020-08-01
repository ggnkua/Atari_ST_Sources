MODULE Environment;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |20.4.93  |started
----------------------------------------------------------------------------
*)

IMPORT Sys, NStr:=NumStr, Str:=Strings;


TYPE strptr = POINTER TO ARRAY 10000 OF CHAR;



PROCEDURE Compare*(VAR Env1,Env2 : ARRAY OF CHAR; VAR Pos : INTEGER) : BOOLEAN;
  (* returns true if the strings contain the same variable. Pos contains
     the index of the first character of the variable contents *)
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE (Env1[i] = Env2[i]) DO
    INC(i);
    IF (Env2[i] = 0X) OR (Env2[i] = "=") THEN
      IF Env2[i] = 0X THEN Pos := i;
      ELSE Pos := i+1;
      END;
      RETURN (Env1[i] = "=") OR (Env1[i] = 0X);
    END;
  END;
  RETURN FALSE
 END Compare;


PROCEDURE ReadStr*(Name : ARRAY OF CHAR; VAR String : ARRAY OF CHAR) : BOOLEAN;
  VAR p : strptr; i : INTEGER;
 BEGIN
  p := Sys.Basepage.Env;
  WHILE p[0] # 0X DO
    IF Compare(Name,p^,i) THEN INC(p,LONG(i)); COPY(p^,String);
      RETURN TRUE
    END;
    INC(p,LONG(Str.Length(p^) + 1));
  END;
  RETURN FALSE;
 END ReadStr;


PROCEDURE ReadInt*(Name : ARRAY OF CHAR; Base : INTEGER;
                   VAR Value : LONGINT) : BOOLEAN;
  VAR s : ARRAY 20 OF CHAR;
 BEGIN
  IF ReadStr(Name,s) THEN Value := NStr.ToLInt(Base,s); RETURN NStr.OK END;
  RETURN FALSE
 END ReadInt;

END Environment.
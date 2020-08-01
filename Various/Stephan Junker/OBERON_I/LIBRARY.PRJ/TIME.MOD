MODULE Time; (* SJ 23.1.95 *)


IMPORT
  S:=SYSTEM, XBIOS, NumStr, Strings;


VAR
  time: LONGINT;

(*$-k *)

PROCEDURE ReadHz200;
 BEGIN
  S.GET( 4BAH, time);
 END ReadHz200;

(*$+k *)

PROCEDURE Get*() : LONGINT;
(*
 Answer the number of milliseconds elapsed since boot.
 *)
 BEGIN
  XBIOS.Supexec( ReadHz200);
  RETURN time * 5;
 END Get;


PROCEDURE Calc*(start: LONGINT) : LONGINT;
(*
 Calculate the time elapsed since start in units of 1 millisecond.
 *)
 BEGIN
  RETURN Get() - start;
 END Calc;


PROCEDURE AsString*(t: LONGINT; VAR time: ARRAY OF CHAR);
(*
 Answer a string representing the value t. The time is
 written in units ms or s as appropriate.
 *)
  VAR
    s: ARRAY 10 OF CHAR;
 BEGIN
  IF t >= 1000 THEN  (* s *)
    NumStr.LIntTo(t DIV 1000, 10, time);
    Strings.AppendC(".", time);
    NumStr.LIntTo(t MOD 1000, 10, s);
    Strings.Append(s, time);
    Strings.Append(" s", time)
  ELSE
    NumStr.LIntTo(t, 10, time);
    Strings.Append(" ms", time)
  END;
 END AsString;


END Time.
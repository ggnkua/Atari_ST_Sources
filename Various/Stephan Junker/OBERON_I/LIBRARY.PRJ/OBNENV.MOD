MODULE ObnEnv; (* SJ 16.12.94 *)

(*
 Enters the environment variables defined in OBERON.ENV into the usual
 environment on startup.
 IF CommandLine and ObnEnv are imported, CommandLine must be imported
 first.
 *)


IMPORT
  S:=SYSTEM, Sys, File;



PROCEDURE Copy;
(*
 Copy the environment variables in OBERON.ENV into the usual environment.
 This is done on startup.
 *)
  VAR
    p,len,length,diff : LONGINT;
    begad : S.PTR;
    b,c : CHAR;
 BEGIN
  p := Sys.Basepage.Env;		(* get env len *)
  REPEAT
    REPEAT
      S.GET(p, c); INC(p);
    UNTIL c = 0X;
    S.GET(p, b); INC(p);
  UNTIL b = 0X;				(* double 0 *)
  len := p-Sys.Basepage.Env;
  IF File.Search("OBERON.ENV", length)
      & File.Load("OBERON.ENV", 0, len, begad, length) THEN
    S.PUT(begad+length, 0);
    p := begad; diff := 0;
    REPEAT
      REPEAT
        S.GET(p, c);
        S.PUT(p-diff, c);
        INC(p);
      UNTIL (c = 0DX) OR (c = 0AX) OR (c = 0X);
      IF c # 0X THEN
        S.PUT(p-diff-1, 0);		(* terminate previous var *)
        S.GET(p, c);
        IF c = 0AX THEN			(* 0DX + 0AX *)
          INC(diff);
          INC(p);
          S.GET(p, c);
        END;
      END;
    UNTIL c = 0X;
    S.MOVE(Sys.Basepage.Env, p-diff, len);
    Sys.Basepage.Env := begad;
  END;
 END Copy;


BEGIN
  Copy;
END ObnEnv.

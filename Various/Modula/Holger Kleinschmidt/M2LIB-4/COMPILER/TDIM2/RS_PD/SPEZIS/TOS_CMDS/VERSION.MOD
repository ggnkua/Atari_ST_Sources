MODULE Vers;
(* ½ 1996 by RS. * 17.2.96 *)
(*$T-,$S-,$Q+*)

IMPORT BIOX, GDB, Aux;

VAR   t,d,m: CARDINAL; v: LONGCARD;
      T,D,M: ARRAY [0..5] OF CHAR;

BEGIN d := GDB.Version(); Aux.ChEn (d);
      t := BIOX.vTOS ();
  IF (0  > BIOX.GetCookie ("MiNT", v)) THEN m := 0 ELSE m := SHORT (v) END;
  GDB.ConWS ( " TOS");    Aux.VerSt (t, T); GDB.ConWS (T);
  GDB.ConWS ("; GEMDOS"); Aux.VerSt (d, D); GDB.ConWS (D);
  GDB.ConWS ("; MiNT");   Aux.VerSt (m, M); GDB.ConWS (M); END Vers .

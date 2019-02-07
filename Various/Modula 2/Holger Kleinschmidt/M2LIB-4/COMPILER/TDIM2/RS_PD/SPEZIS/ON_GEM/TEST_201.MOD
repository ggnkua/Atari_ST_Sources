MODULE T201;            (* Test der GEM-Funktion 201. Mit Mini-GEMX linken.*)
(* ½ 1994 ROLF SCHRADER. * 14.7.94 + 9.8.94 *)
(*$S-,$T-,$Q+*)

FROM SYSTEM IMPORT CODE, SETREG,REGISTER;
FROM  Mini  IMPORT wT, (* Halt, *) Pause;

CONST GTRAP = 4E42H;

PROCEDURE onGem (): BOOLEAN;               (* Ist GEM (schon) installiert? *)
 BEGIN SETREG (0, 201); CODE (GTRAP);
   RETURN (LONGINT (REGISTER (0)) # 201) END onGem;

BEGIN wT(33c); wT ("H Test 201: ");
      IF onGem () THEN wT ("ok.") END;
   Pause;
(* Halt; *)
   END T201.

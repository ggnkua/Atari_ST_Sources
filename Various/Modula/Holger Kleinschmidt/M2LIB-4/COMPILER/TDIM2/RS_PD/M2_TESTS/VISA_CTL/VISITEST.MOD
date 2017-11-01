IMPLEMENTATION MODULE VisiTest;              (* Test der Visibility Scopes.*)
(* ½ 1995 by ROLF SCHRADER.  * 9.2.95 *)
(*$S-,$T-,$Q+*)

IMPORT SYSTEM, Mini;
FROM VisiFund IMPORT wHexL,    V1  (* Sollte V1 aus dem ~.DEF verdr„ngen! *);

MODULE SubM;
IMPORT V2;
EXPORT V2;
VAR    V2: CARDINAL;               (* Huch, keine Beschwerde vom Compiler? *)
END (*M*) SubM;

BEGIN Mini.wT (" In V-Test ADR(V1) = "); wHexL (SYSTEM.ADR (V1));
      Mini.Pause; END VisiTest .

IMPLEMENTATION MODULE VisiFund;
(* ½ 1995 by ROLF SCHRADER.   * 9.2.95 *)

IMPORT SYSTEM;
FROM Mini IMPORT wT;

TYPE B4 = RECORD
       CASE: CHAR OF 0c: s: ARRAY [0..3] OF CHAR;
       | 1c: w: SYSTEM.LONGWORD | 2c: l: LONGCARD ELSE c,d: CARDINAL END END;

VAR DS: ARRAY [0..16] OF CHAR;
VAR HOME, LN: B4;

PROCEDURE wHexW (n: CARDINAL);
   VAR s: ARRAY [0..4] OF CHAR; k: CARDINAL;
 BEGIN FOR k := 3 TO 0 BY -1 DO s[k] := DS[n MOD 16]; n := n DIV 16 END;
       s[4] := 0c; wT (s); END wHexW;

PROCEDURE wHexL (n: SYSTEM.LONGWORD); VAR N: B4;
 BEGIN N.w := n; wHexW (N.c); wHexW (N.d) END wHexL;

PROCEDURE Ln; BEGIN wT (LN.s) END Ln;

BEGIN DS := "0123456789ABCDEF"; HOME.l := 1B480000H; LN.l := 0D0A0000H;
   wT (HOME.s); Ln; Ln;
   wT (" In V-Fund ADR(V1) = "); wHexL (SYSTEM.ADR (V1));
   Ln; END VisiFund.

IMPLEMENTATION MODULE Mini;
(* ½ 1994-95 ROLF SCHRADER * 3.2.93 + 9.8.94 *)
(*$T-,$S-,$Q+*)

FROM  SYSTEM IMPORT CODE;

TYPE  LC = LONGCARD;

CONST DTRAP = 4E41H; BTRAP = 4E4DH; XTRAP = 4E4EH; CON = 2;
      PMARK =     8;       (* Stack Offset am Proz.-Anfang: Ret.Adr & Link.*)
      PUSHW = 3F3CH;       (* MOVE.W #*,-(A7);       W.-Konst. auf'n Stack.*)
      SUPBP = 1F6EH;       (* MOVE.B s(A6),d(A7);    Supply Byte-Par; d=1! *)

PROCEDURE Halt;  BEGIN CODE (PUSHW,00, DTRAP) END Halt;
PROCEDURE VSync; BEGIN CODE (PUSHW,37, XTRAP) END VSync;
PROCEDURE Pause; VAR k: LC; BEGIN FOR k := 0 TO 213 DO VSync END END Pause;

PROCEDURE wt (Ch: CHAR);
 BEGIN CODE (PUSHW,0, SUPBP,PMARK,1, PUSHW,CON, PUSHW,3, BTRAP) END wt;
PROCEDURE wT (VAR s: ARRAY OF CHAR); VAR k: CARDINAL;
 BEGIN k:=0; WHILE (k<=HIGH(s)) & (s[k]#0c) DO wt (s[k]); INC(k) END END wT;

PROCEDURE Test;
 BEGIN wT (33c); wT ("H Minimal Program! "); Pause; (* Halt *) END Test;

(*
BEGIN Test *) END Mini.

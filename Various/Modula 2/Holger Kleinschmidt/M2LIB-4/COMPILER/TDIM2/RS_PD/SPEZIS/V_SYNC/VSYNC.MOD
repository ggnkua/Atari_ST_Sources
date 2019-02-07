MODULE vSync;
(* Abfrage der Vertical Sync Rate.*)
(* ½ 1994-95 ROLF SCHRADER. * 18.5.94 + 9.9.95 *)
(*$S-,$T-,$Q+*)

FROM  SYSTEM  IMPORT CODE,PUSH;
CONST BTRAP = 4E4DH; XTRAP = 4E4EH; DTRAP = 4E41H; RTS = 4E75H; CON = 2;
VAR   A200[4BAH],                  (* TOS-Adresse fr den 200Hz Systemtakt.*)
      oldT, actT: LONGCARD;        (* Ged„chtnis, akt. Zeit in 5-msec-Einh.*)

PROCEDURE Halt; BEGIN PUSH (0); CODE (DTRAP) END Halt;

PROCEDURE wt (Ch: CHAR);
 BEGIN PUSH (ORD (Ch)); PUSH (CON); PUSH (3); CODE (BTRAP) END wt;

PROCEDURE SupEx (p: PROC); BEGIN PUSH (p); PUSH (38); CODE (XTRAP) END SupEx;
PROCEDURE VSync; BEGIN PUSH (37); CODE (XTRAP) END VSync;

PROCEDURE a200; (*$P-*) BEGIN actT := A200; CODE (RTS) END a200; (*$P+*)
PROCEDURE Tim5Check; BEGIN oldT := actT; SupEx (a200) END Tim5Check;
PROCEDURE Tim5Delta (): LONGCARD; BEGIN RETURN (actT -oldT) END Tim5Delta;

PROCEDURE wT (VAR s: ARRAY OF CHAR); VAR i: CARDINAL;
 BEGIN i:=0; REPEAT wt (s[i]); INC(i) UNTIL (i> HIGH(s)) OR (s[i]=0c) END wT;
PROCEDURE wC (c: CARDINAL);
 BEGIN IF 9 < c THEN wC (c DIV 10) END; wt (CHR (c MOD 10 +48)) END wC;

CONST KE = 144; K5 = 200;
VAR   k,j: CARDINAL;

BEGIN wT(33c); wT ("H VerticalSyncRate: "); VSync;
      Tim5Check;
      FOR k := 1 TO KE DO VSync END;
      Tim5Check;
   wC ((KE * K5) DIV SHORT (Tim5Delta ()));
   wT (" Hz.");
   FOR k := 0 TO 64000 DO INC (j) END; (* Einige sec warten.*)
(* Halt; *) END vSync.


(* Alternative Implmtrg.: *)
MODULE vSync;
(* ½ 1994 ROLF SCHRADER. * 4.5.94 *)

IMPORT AEI, Ev, VT, VR;
FROM   BIOX  IMPORT VSync;
FROM   Tims  IMPORT Tim5Check, Tim5Delta;

PROCEDURE ShowVSyncRate;
 CONST KE = 140; K5 = 200;
 VAR   k: CARDINAL;
 BEGIN VT.Home; VT.wT (" VerticalSyncRate: "); VSync;
   Tim5Check;
   FOR k := 1 TO KE DO VSync END;
   Tim5Check;
   VR.wFixR (FLOAT (KE * K5) / FLOAT (Tim5Delta ()), 5,3);
   VT.wT (" Hz.");
   END ShowVSyncRate;

BEGIN ShowVSyncRate; Ev.Pause END vSync.

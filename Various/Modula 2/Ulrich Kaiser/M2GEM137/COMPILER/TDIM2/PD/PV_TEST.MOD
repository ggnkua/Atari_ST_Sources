MODULE PVTEST;
(* RS 24.1.94 *)
(* Demonstriert den Compiler-Bug bezgl. indizierter Funktionen-Variablen. *)
(*$Q+*)

IMPORT VT,VZ;

TYPE CD = CARDINAL;
     IG = INTEGER;
     FP = PROCEDURE(): CD;
     P1 = PROCEDURE (VAR IG);
     FA = ARRAY [21..23] OF FP;
     Meths = RECORD R1: P1; FP: FA END;

VAR  iP: ARRAY [0..7] OF Meths;
     j:  IG;

PROCEDURE R0 (VAR x: IG); BEGIN VT.wT (" Function-Test: ") END R0;

PROCEDURE F3 (): CD; BEGIN RETURN 43 END F3;

PROCEDURE Act0 (i: IG): CD; BEGIN RETURN iP[7].FP[i]() END Act0;

PROCEDURE Act1 (i: IG): CD;
                 VAR f: FP; BEGIN f := iP[7].FP[i]; RETURN f () END Act1;

PROCEDURE Init;
 BEGIN WITH iP[0] DO R1 := R0; FP[21] := F3; FP[22] := F3; FP[23] := F3 END;
   FOR j := 1 TO 7 DO iP[j] := iP[0] END; END Init;

BEGIN  Init;
       VT.Home; VT.Ln; VT.Ln;
       iP[4].R1 (j);
  j := iP[7].FP[23](); VZ.wDecW (j, 3);
  j := Act0 (23);      VZ.wDecW (j, 3);
  j := Act1 (23);      VZ.wDecW (j, 3);
  VZ.Pause; END PVTEST.


Auszug aus dem Dis-Assembling:

Act0: procnum = 3

    0H   7000                     MOVEQ   #00H,D0
    2H   4EB9 0000 0000           JSR     00000000H
    8H   4E56 0000                LINK    A6,#0000H

    CH   3A2E 0008                MOVE.W  0008(A6),D5
   10H   0445 0015                SUBI.W  #0015H,D5
   14H   4BBC 0002                CHK     #0002H,D5
   18H   E545                     ASL.W   #2,D5
   1AH   49F9 0000 0074           LEA     00000074H,A4
 > 20H   48E7 0408                MOVEM.L {A4,D5},-(A7)

   24H   558F                     SUBQ.L  #2,A7
   26H   2874 5000                MOVE.L  00H(A4,D5.W),A4
   2AH   4E94                     JSR     (A4)
 > 2CH   3A1F                     MOVE.W  (A7)+,D5

 > 2EH   4CDF 1020                MOVEM.L (A7)+, {D5,A4}
 > 32H   3D45 000A                MOVE.W  D5,000A(A6)

   36H   4E5E                     UNLK    A6
   38H   4E75                     RTS
   3AH   7001                     MOVEQ   #01H,D0
   3CH   4EB9 0000 0000           JSR     00000000H

Act1: procnum = 4

    0H   7004                     MOVEQ   #04H,D0
    2H   4EB9 0000 0000           JSR     00000000H
    8H   4E56 FFFC                LINK    A6,#FFFCH

    CH   3A2E 0008                MOVE.W  0008(A6),D5
   10H   0445 0015                SUBI.W  #0015H,D5
   14H   4BBC 0002                CHK     #0002H,D5
   18H   E545                     ASL.W   #2,D5
   1AH   49F9 0000 0074           LEA     00000074H,A4
   20H   2D74 5000 FFFC           MOVE.L  00H(A4,D5.W),FFFC(A6) ; f

   26H   558F                     SUBQ.L  #2,A7
   28H   286E FFFC                MOVE.L  FFFC(A6),A4
   2CH   4E94                     JSR     (A4)
   2EH   3D5F 000A                MOVE.W  (A7)+,000A(A6)

   32H   4E5E                     UNLK    A6
   34H   4E75                     RTS
   36H   7001                     MOVEQ   #01H,D0
   38H   4EB9 0000 0000           JSR     00000000H

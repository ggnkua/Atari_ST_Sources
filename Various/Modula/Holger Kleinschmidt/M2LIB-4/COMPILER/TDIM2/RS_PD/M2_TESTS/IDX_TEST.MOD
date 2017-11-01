MODULE IndexTst;
(* Demo des Compiler-Bugs bzgl. Indices offener Arrays.*)
(* RS 10.1.94 / 30.7.94 *)
(*$S-,$T-,$Q+ *)

IMPORT VT, VZ;

PROCEDURE WriteString (VAR s: ARRAY OF LONGCARD);
 VAR   k: CARDINAL;
 BEGIN k := 0;
   WHILE (k <= HIGH (s)) (* & (s[k] # 0c) *) DO
          VT.wt (CHAR(s[k])); INC (k) END;
   VT.Ln; VZ.wDecL (LONG (HIGH (s)), 1); VZ.wDecL (LONG (k), 8); VT.Ln;
   END WriteString;

TYPE  RANGE = [0..65000];
VAR   S: ARRAY RANGE OF LONGCARD; K: CARDINAL;

BEGIN VT.Home; VT.Wrap;
      FOR K :=  0000 TO 30000 DO S[K] := LONG (40+ K MOD 3) END;
      FOR K := 30000 TO 50000 DO S[K] := LONG (50+ K MOD 3) END;
      FOR K := 50000 TO 65000 DO S[K] := LONG (60+ K MOD 3) END;
      S[65000] := 0;
      WriteString (S);
      VT.Trap; VT.Ln;
      VZ.wDecL (LONG (HIGH (S)), 1); VT.Ln;
      VZ.Pause;
  END IndexTst.

Auszug aus dem Disassembling:

proc code, procnum = 1

     0H    4E56 FFFE                LINK    A6,#FFFEH
     4H    426E FFFE                CLR.W   FFFE(A6)

     8H    3A2E FFFE                MOVE.W  FFFE(A6),D5
     CH    BA6E 000C                CMP.W   000C(A6),D5
    10H    6220                     BHI     [20H] = 00000032H
    12H    3A2E FFFE                MOVE.W  FFFE(A6),D5
 >  16H    E545                     ASL.W   #2,D5                ; zu kurz!
    18H    286E 0008                MOVE.L  0008(A6),A4
 >  1CH    2834 5000                MOVE.L  00H(A4,D5.W),D4      ; zu kurz!
    20H    1F04                     MOVE.B  D4,-(A7)
    22H    2879 0000 0004           MOVE.L  00000004H,A4
    28H    4E94                     JSR     (A4)
    2AH    548F                     ADDQ.L  #2,A7
    2CH    526E FFFE                ADDQ.W  #1,FFFE(A6)
    30H    60D6                     BRA     [D6H] = 00000008H

    32H    4EB9 0000 0000           JSR     00000000H
    38H    7A00                     MOVEQ   #00H,D5
    3AH    3A2E 000C                MOVE.W  000C(A6),D5
    3EH    2F05                     MOVE.L  D5,-(A7)
    40H    3F3C 0001                MOVE.W  #0001H,-(A7)
    44H    4EB9 0000 0000           JSR     00000000H
    4AH    5C8F                     ADDQ.L  #6,A7
    4CH    7A00                     MOVEQ   #00H,D5
    4EH    3A2E FFFE                MOVE.W  FFFE(A6),D5
    52H    2F05                     MOVE.L  D5,-(A7)
    54H    3F3C 0008                MOVE.W  #0008H,-(A7)
    58H    4EB9 0000 0000           JSR     00000000H
    5EH    5C8F                     ADDQ.L  #6,A7
    60H    4EB9 0000 0000           JSR     00000000H
    66H    4E5E                     UNLK    A6
    68H    4E75                     RTS

init code, procnum = 0

     0H    4EF9 0000 0000           JMP     00000000H
     6H    4E56 0000                LINK    A6,#0000H
     AH    4EB9 0000 0000           JSR     00000000H
    10H    4EB9 0000 0000           JSR     00000000H
    16H    4279 0003 F7A6           CLR.W   0003F7A6H

    1CH    7A00                     MOVEQ   #00H,D5
    1EH    3A39 0003 F7A6           MOVE.W  0003F7A6H,D5
    24H    8AFC 0003                DIVU    #0003H,D5
    28H    4845                     SWAP    D5
    2AH    0645 0028                ADDI.W  #0028H,D5
    2EH    4845                     SWAP    D5
    30H    4245                     CLR.W   D5
    32H    4845                     SWAP    D5
    34H    3839 0003 F7A6           MOVE.W  0003F7A6H,D4
    3AH    4844                     SWAP    D4
    3CH    4244                     CLR.W   D4
    3EH    4844                     SWAP    D4
 .  40H    E584                     ASL.L   #2,D4                ; korrekt.
    42H    49F9 0000 0000           LEA     00000000H,A4
 .  48H    2985 4800                MOVE.L  D5,00H(A4,D4.L)      ; korrekt.
    4CH    5279 0003 F7A6           ADDQ.W  #1,0003F7A6H
    52H    0C79 7531 0003 F7A6      CMPI.W  #7531H,0003F7A6H
    5AH    66C0                     BNE     [C0H] = 0000001CH
    ... 

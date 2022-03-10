
(* Patch um den Bug in der LONGINT-MODULO-Funktion zu beseitigen: *)

(*$P-  No entry/exit code, 'cause jumping directly to DIVU32.*)
PROCEDURE DIVS32 (Dividend, Divisor: LONGINT);
 CONST P1 = 4; (* Offset of dividend/quotient on stack.*)
       P2 = 0; (* Offset of divisor/remainder on stack.*)
 BEGIN
  CODE ( 201FH,         (* MOVE.L  (A7)+, D0 *)
         2E2FH, P1,     (* MOVE.L  4H(A7), D7 ; get dividend *)
         2C2FH, P2,     (* MOVE.L  0H(A7), D6 ; get divisor  *)
        0BF86H,         (* EOR.L   D7, D6    *)
         5BC6H,         (* SMI.B   D6 ; signs different? must neg quotient.*)
         4AAFH, P2,     (* TST.L   0H(A7)    *)
         6A04H,         (* BPL.S   [04]      *)
         44AFH, P2,     (* NEG.L   0H(A7)    *)
         4A87H,         (* TST.L   D7        *)
         5BC7H,         (* SMI.B   D7 ; remainder must get dividend's sign,*)
         6A04H,         (* BPL.S   [04] ;   to be compatible with word-MOD.*)
         44AFH, P1 );   (* NEG.L   4H(A7)    *)
  SETREG (8, DIVU32);
  CODE ( 4E90H,         (* JSR     (A0)      *)
         4A07H,         (* TST.B   D7        *)
         6704H,         (* BEQ.S   [04]      *)
         44AFH, P2,     (* NEG.L   0H(A7)    *)
         4A06H,         (* TST.B   D6        *)
         6704H,         (* BEQ.S   [04]      *)
         44AFH, P1,     (* NEG.L   4H(A7)    *)
         2F00H,         (* MOVE.L  D0, -(A7) *)
         4E75H );       (* RTS *)  END DIVS32;

(*
Disassembling des alten DIVS32:

     procnum = 11
     0H       201F                     MOVE.L  (A7)+,D0
     2H       2E2F 0000                MOVE.L  0000(A7),D7
     6H       2C2F 0004                MOVE.L  0004(A7),D6
     AH       BF86                     EOR.L   D7,D6
     CH       5BC6                     SMI     D6
     EH       4AAF 0004                TST.L   0004(A7)
    12H       6A04                     BPL     [04H] = 00000018H
    14H       44AF 0004                NEG.L   0004(A7)
    18H       4A87                     TST.L   D7
    1AH       5BC7                     SMI     D7
    1CH       6A04                     BPL     [04H] = 00000022H
    1EH       44AF 0000                NEG.L   0000(A7)
    22H       207C 0000 0000           MOVE.L  #0000000H,A0
    28H       4E90                     JSR     (A0)
    2AH       4A07                     TST.B   D7
    2CH       6704                     BEQ     [04H] = 00000032H
    2EH       44AF 0000                NEG.L   0000(A7)
    32H       4A06                     TST.B   D6
    34H       6704                     BEQ     [04H] = 0000003AH
    36H       44AF 0004                NEG.L   0004(A7)
    3AH       2F00                     MOVE.L  D0,-(A7)
    3CH       4E75                     RTS
*)

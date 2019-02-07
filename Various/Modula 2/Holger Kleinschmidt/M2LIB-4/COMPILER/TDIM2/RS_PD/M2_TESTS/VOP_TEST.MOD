MODULE OverflowTest; (* Demo des Bugs der Code-Erzeugung mit der Option V+.*)
(* RS 18.11.94 *)               (* Thanks to Holger Kleinschmidt for hint! *)

(*$V+  overflow checks on! *)

VAR   i: INTEGER;

BEGIN i := MAX (INTEGER);
      i := i + 5;             (* F„lschlicherweise KEINE šberlauf-Meldung! *)
      INC (i, 7);                                 (* šberhaupt kein Check! *)
  END OverflowTest.

(* Disassembling:

    0H   4EF9 0000 0000      JMP     0H
    6H   4E56 0000           LINK    A6,#0H
    AH   33FC 7FFF 0000 0000 MOVE.W  #7FFFH,0H
   12H   3A39 0000 0000      MOVE.W  0H,D5
   18H   5A45                ADDQ.W  #5,D5
>  1AH   6406                BCC     [06H] = 22H ; carry check for CARDINALs
   1CH   003C 0002           ORI     #02H,CCR
   20H   4E76                TRAPV
   22H   33C5 0000 0000      MOVE.W  D5,0H
   28H   5E79 0000 0000      ADDQ.W  #7,0H
   2EH   4E5E                UNLK    A6
   30H   4EF9 0000 0000      JMP     0H
*)

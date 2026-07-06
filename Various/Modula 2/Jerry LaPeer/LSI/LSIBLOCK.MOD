IMPLEMENTATION MODULE LSIBlock;

(*$S-*) (*$T-*) (*$A+*) (*$F-*)

FROM SYSTEM IMPORT BYTE,ADDRESS,
                   CODE, SETREG;
 
CONST BiosTrap = 04E4DH; (* trap #13        *)
      PushW    = 03F00H; (* move.w d0,-(a7) *)

      D0       = 0; A0 =  8;
      D1       = 1; A1 =  9;
      D2       = 2; A2 = 10;
      D3       = 3; A3 = 11;
      D4       = 4; A4 = 12;
      D5       = 5; A5 = 13;
      D6       = 6; A6 = 14;
      D7       = 7; A7 = 15;

PROCEDURE FillMemW(Block : ADDRESS;
                   Count : LONGCARD;
                   Value : BYTE);

VAR i:          LONGCARD;

BEGIN

  IF Count > 0
     THEN i := (Count DIV 4) - 1;
          SETREG(D0, i);
          SETREG(A0, Block);
          SETREG(D6, Value);
          CODE(20C6H);                  (* MOVE.L D6,(A0)+  *)
          CODE(51C8H); CODE(0FFFCH);    (* DBF    D0,REPEAT *)

  END;

END FillMemW;

PROCEDURE MoveMemW(ToBlock,FromBlock : ADDRESS;
                   Count : LONGCARD);

VAR i:          LONGCARD;

BEGIN

  IF Count > 0
     THEN i := (Count DIV 4) - 1;
          SETREG(D0, i);
          SETREG(A1, FromBlock);
          SETREG(A2, ToBlock);
          CODE(24D9H);                  (* MOVE.L (A1)+,(A2)+ *)
          CODE(51C8H); CODE(0FFFCH);    (* DBF    D0,REPEAT   *)

  END;

END MoveMemW;
                   
END LSIBlock.

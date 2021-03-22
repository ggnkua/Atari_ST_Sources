MODULE MagxHC30;
(*$N+*)

(*
 * Init-Prg zum Booten von Mag!X mit dem HC030
 *)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        CLR.L   -(A7)
        MOVE    #$20,-(A7)      ; Super()
        TRAP    #1
        ADDQ.L  #6,A7
        
        MOVE.L  4,A0
        MOVE.L  $4F2,A1
        CMPA.L  4(A1),A0
        BCC     ok
        MOVE.L  A0,4(A1)
ok:
        CLR.W   -(A7)
        TRAP    #1
  END
END MagxHC30.

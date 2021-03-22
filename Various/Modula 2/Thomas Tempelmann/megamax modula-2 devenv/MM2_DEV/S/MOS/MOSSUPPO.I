IMPLEMENTATION MODULE MOSSupport;
(*$Y+,N+,L-*)

(*
  14.02.92 TT: CallSuper, ToSuper, ToUser neu.
*)

FROM SYSTEM IMPORT ASSEMBLER;

PROCEDURE ToSuper;
  BEGIN
    ASSEMBLER
        MOVEQ   #1,D0
        MOVE.L  D0,-(A7)
        MOVE    #$20,-(A7)
        TRAP    #1              ; Super (1)
        MOVE.W  D0,4(A7)
        ADDQ.L  #1,D0
        BEQ     alreadySuper
        TRAP    #1              ; Super (0)
     alreadySuper:
        ADDQ.L  #6,A7
        MOVE.L  D0,4(A7)        ; save SSP
    END
  END ToSuper;

PROCEDURE ToUser;
  BEGIN
    ASSEMBLER
        MOVE.L  4(A7),D0
        BEQ     wasSuper
        MOVE.L  D0,-(A7)
        MOVE    #$20,-(A7)
        TRAP    #1              ; Super (SSP)
        ADDQ.L  #6,A7
      wasSuper
    END
  END ToUser;

PROCEDURE CallSuper;
  BEGIN
    ASSEMBLER
        ; swap rtn-/proc-addr
        SUBQ.L  #4,A7
        JSR     ToSuper
        MOVE.L  8(A7),A0
        JSR     (A0)
        MOVE.L  D0,8(A7)
        JSR     ToUser
        MOVE.L  8(A7),D0
        ADDQ.L  #4,A7
    END
  END CallSuper;

END MOSSupport.

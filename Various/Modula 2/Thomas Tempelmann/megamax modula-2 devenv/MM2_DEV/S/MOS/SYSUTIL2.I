IMPLEMENTATION MODULE SysUtil2;

(*
  27.11.90  TT  Set/LongJump retten/restaurieren auch SSP
  01.05.90  TT  Set/LongJump restaurieren A7 korrekt (war bisher 4 zu niedrig)
  07.12.88  TT  Grunderstellung
*)

(*$L-  global *)
(*$Y+,N+*)

FROM SYSTEM IMPORT ASSEMBLER, WORD, LONGWORD, ADDRESS;

(*
TYPE JumpBuf = RECORD
                 pc: ADDRESS;
                 ssp: LONGWORD;
                 usp: LONGWORD;
                 sr: WORD;
                 d: ARRAY [1..7] OF LONGWORD;
                 a: ARRAY [1..6] OF LONGWORD;
               END;
*)

PROCEDURE SetJump ( VAR hdl: JumpBuf ): INTEGER;
  BEGIN
    ASSEMBLER
        MOVEQ   #1,D0
        MOVE.L  D0,-(A7)        ; Super (1)
        MOVE    #$20,-(A7)
        TRAP    #1
        TST     D0
        BNE     alreadySuper
        ; wir sind im User-Mode
        MOVE.W  D0,4(A7)        ; Super (0)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  -(A3),A0
        MOVE.L  (A7),(A0)+      ; PC
        MOVE.L  D0,(A0)+        ; SSP
        MOVE.L  A7,(A0)+        ; USP
        MOVE    SR,(A0)
        ANDI    #$CFFF,(A0)+    ; SR
        MOVEM.L D1-D7/A1-A6,(A0)
        CLR     (A3)+
        MOVE.L  A7,USP
        MOVE.L  D0,A7           ; SSP wiederherstellen
        ANDI    #$CFFF,SR
        RTS
      alreadySuper:
        ADDQ.L  #6,A7
        MOVE.L  -(A3),A0
        MOVE.L  (A7),(A0)+      ; PC
        MOVE.L  A7,(A0)+        ; SSP
        MOVE.L  USP,A0
        MOVE.L  A0,(A0)+        ; USP
        MOVE    SR,(A0)+        ; SR
        MOVEM.L D1-D7/A1-A6,(A0)
        CLR     (A3)+
    END
  END SetJump;

PROCEDURE LongJump ( VAR hdl: JumpBuf; rtnCode: INTEGER );
  BEGIN
    ASSEMBLER
        MOVEQ   #1,D0
        MOVE.L  D0,-(A7)        ; Super (1)
        MOVE    #$20,-(A7)
        TRAP    #1
        TST     D0
        BNE     alreadySuper
        ; wir sind im User-Mode
        MOVE.W  D0,4(A7)        ; Super (0)
        TRAP    #1
        MOVE.L  D0,A7           ; SSP wiederherstellen
      alreadySuper:
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A2
        MOVE.L  (A2)+,A0        ; PC
        MOVE.L  (A2)+,A7        ; SSP
        MOVE.L  (A2)+,A1        ; USP
        MOVE.L  A1,USP
        MOVE    (A2)+,SR        ; SR
        MOVEM.L (A2),D1-D7/A1-A6
        MOVE    D0,(A3)+
        MOVE.L  A0,(A7)
    END
  END LongJump;

(*
TYPE ModeBuf = RECORD
                 sr: WORD;
                 a7: ADDRESS;
               END;
*)

PROCEDURE InSupervisorMode (): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVEQ   #1,D0
        MOVE.L  D0,-(A7)        ; Super (1)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END InSupervisorMode;

PROCEDURE EnterSupervisorMode ( VAR hdl: ModeBuf );
  BEGIN
    ASSEMBLER
        MOVEQ   #1,D0
        MOVE.L  D0,-(A7)        ; Super (1)
        MOVE    #$20,-(A7)
        TRAP    #1
        TST.L   D0
        BNE     alreadySuper
        ; wir waren im User-Mode
        MOVE.W  D0,4(A7)        ; Super (0)
        TRAP    #1
        ADDQ.L  #6,A7
        
        MOVE.L  -(A3),A2
        MOVE.L  D0,(A2)
        RTS

  alreadySuper:
        ADDQ.L  #6,A7
        MOVE.L  -(A3),A2
        CLR.L   (A2)
    END
  END EnterSupervisorMode;

PROCEDURE LeaveSupervisorMode ( VAR Hdl: ModeBuf );
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  (A0),D0
        BEQ     nix
        MOVE.L  A7,USP          ; zuerst USP restaurieren
        MOVE.L  D0,A7           ; dann SSP restaurieren
        ANDI    #$CFFF,SR       ; zuletzt zurÅck in Usermode
      nix
    END
  END LeaveSupervisorMode;

PROCEDURE SetIRMask ( level: IRLevel );
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     EnterSupervisorMode
        MOVE    SR,D2
        MOVE.W  -(A3),D0
        ANDI    #7,D0
        LSL.W   #8,D0
        ANDI    #$F8FF,D2
        OR      D0,D2
        MOVE    D2,SR
        MOVE.L  A7,(A3)+
        JSR     LeaveSupervisorMode
        ADDQ.L  #4,A7
    END
  END SetIRMask;

PROCEDURE IRMask (): IRLevel;
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     EnterSupervisorMode
        MOVE    SR,D0
        LSR.W   #8,D0
        ANDI    #7,D0
        MOVE    D0,(A3)+
        MOVE.L  A7,(A3)+
        JSR     LeaveSupervisorMode
        ADDQ.L  #4,A7
    END
  END IRMask;

END SysUtil2.

(* $FFEAA8A7$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$000011CB$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353F$FFF0353FÄ$00000060T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000000EE$00000BD7$00000C0A$000001DC$000001A0$00000163$000001AC$00000127$00000226$000001A0$000000B4$0000002E$00000060$000000E6$FFEAA8A7$FFEAA8A7åÄÄ*)

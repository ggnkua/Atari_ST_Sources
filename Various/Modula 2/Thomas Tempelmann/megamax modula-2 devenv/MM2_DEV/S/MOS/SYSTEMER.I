IMPLEMENTATION MODULE SystemError;
(*$M-,N+,L-*)

(*
 * 06.11.90: AbortWithMsg wird mit ADDRESS statt ARRAY OF CHAR-Parm
 * 17.01.94: TermProcess-Aufruf statt direktem Pterm
 *)

(*$Y+*)
FROM SYSTEM IMPORT ASSEMBLER;
FROM SYSTEM IMPORT ADDRESS;
FROM PrgCtrl IMPORT TermProcess;

(*
PROCEDURE alert;
  BEGIN
    ASSEMBLER
        LEA     Data(PC),A1
        LEA     24(A1),A2
        MOVE.L  A0,(A2)
        MOVE.L  A2,16(A1)
        ADDQ    #4,A2
        MOVE.L  A2,8(A1)
        MOVE    #1,(A2)+        ; Default Button-Nr.
        MOVE.L  A2,12(A1)
        ADDQ    #2,A2
        MOVE.L  A2,4(A1)
        LEA     Control(PC),A0
        MOVE.L  A0,(A1)
        CLR.L   10(A2)
        MOVE.L  A1,D1
        MOVE    #$C8,D0
        TRAP    #2
        RTS

Control DC.W    52,1,1,1,0,0
Data    DS      52
    END
  END alert;
*)

(*
PROCEDURE Terminate (msg: ADDRESS);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0        ; msg
        JSR     alert
        MOVE    #-1,(A3)+
        JMP     TermProcess
    END
  END Terminate;

PROCEDURE OutOfMemory;
  BEGIN
    ASSEMBLER
        LEA     msg(PC),A0
        JSR     alert
        MOVE    #-39,(A3)+
        JMP     TermProcess
      msg:
        ASC     '[3][Out of memory][ BYE ]'
    END
  END OutOfMemory;
*)

PROCEDURE Abort (no: INTEGER);
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        BPL     ok
        CMPI    #-32,D0
        BGE     ret1
        CMPI    #-95,D0
        BGT     ok
        MOVEQ   #-93,D0         ; fÅr no < -94
        BRA     ok
      ret1
        SUBI.W  #62,D0          ; fÅr no zw. -1..-32 -> TOS-Error #32 - #63
     ok ; -63 ergibt "TOS-Error #32"
        ; -31 wÑre demnach "TOS-Error #0"
        ; angezeigt werden alle Werte von -33 bis -94
        MOVE    D0,(A3)+
        JMP     TermProcess
    END
  END Abort;

PROCEDURE AbortWithMsg (msg: ADDRESS);
  BEGIN
    ASSEMBLER
        PEA     T1(PC)
        MOVE    #9,-(A7)        ;Cconws
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  -(A3),-(A7)
        BEQ     noText
        (* FÅr ARRAY OF CHAR-Par:
          MOVE    D0,D1
          ADDQ    #3,D1
          BCLR    #0,D1
          SUBA.W  D1,A7
          MOVE.L  A7,A1
        L MOVE.B  (A0)+,(A1)+     ; msg auf Stack kopieren
          DBEQ    D0,L
          CLR.B   (A1)+           ; und Null-terminieren
          MOVE.L  A7,-(A7)
        *)
        MOVE    #9,-(A7)        ;Cconws
        TRAP    #1
        ADDQ.L  #6,A7
      noText
        PEA     T2(PC)
        MOVE    #9,-(A7)        ;Cconws
        TRAP    #1
        MOVE    #-1,(A3)+
        JMP     TermProcess
     T1 DC.B    13,10
        ACZ     'Fatal error: '
     T2 DC.B    13,10
        ASC     'Program aborted!'
        DC.B    13,10,0
        SYNC
    END
  END AbortWithMsg;

PROCEDURE OutOfMemory;
  BEGIN
    ASSEMBLER
        MOVE    #-39,(A3)+
        JMP     TermProcess
    END
  END OutOfMemory;

END SystemError.

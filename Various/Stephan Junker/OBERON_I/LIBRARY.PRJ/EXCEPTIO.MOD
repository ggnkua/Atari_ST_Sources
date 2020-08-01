MODULE Exceptions; (* Stephan Junker  3.12.93 / 25.11.94 *)

(*
 Exceptions links itself into the processors' exception vectors. On these
 exceptions, an error is reported and, if possible, a debugger call is
 allowed.
 *)


IMPORT
  S:=SYSTEM, Sys, Task, XBIOS, Halt, Program;



CONST
  Magic = 4F424E44H; (* OBND *)
  Xbra  = 58425241H; (* XBRA *)



VAR
  errNo: INTEGER;
  oldAd: S.PTR;
  savedSR: INTEGER;


(*$-k-p *)

PROCEDURE LinkNewS;
 BEGIN
  ASSEMBLER

    TST.L  PBusErr
    BNE    ret

    MOVE.L  #BusErr,A0
    MOVE.L  #8,A1
    MOVEQ   #6,D0
    MOVE.L  #AddrErr,D1
    SUB.L   #BusErr,D1
Link:
    MOVE.L  (A1),-4(A0)
    MOVE.L  A0,(A1)+
    ADD  D1,A0
    DBRA  D0,Link

ret:    UNLK  A6
    RTS

CallShow:  BTST  #5,(SP)    ; supervisor mode?
    BNE    JumpOld2

    TST.B  Halt.inException
    BNE  Terminate

    MOVE  (SP),savedSR
    MOVEM.L  D0-A6,Halt.registers
    MOVE.W  #$4E75,Sys.CheckStack
                MOVE.L  2(SP),-(SP)
    JSR  Program.AddressInCode
    ADDQ.L  #4,SP
    MOVE.W  #$BFF9,Sys.CheckStack
    TST.B  D0
    BEQ    JmpOld

Catch:    MOVE.B  #1,Halt.inException
    BCLR  #7,(SP)    ; trace off
    MOVE.L  USP,A0
    MOVE.L  2(SP),-(A0)  ; for call stack
    MOVE.L  (A0),Halt.excAddress
    MOVE.L  A0,Halt.registers+15*4
    MOVE.L  A0,USP
    ADDQ.L  #6,SP
    MOVE  -6(SP),SR  ; user mode
    LINK  A6,#0    ; for call stack

CallHalt:  MOVE.W  errNo,-(SP)
    JSR  Sys.halt  ; will not return
    BRA  CallHalt

JmpOld:    MOVEM.L  Halt.registers,D0-A6

JumpOld2:  MOVE.L  oldAd,-(SP)
    RTS

Terminate:  MOVE.W  #-1,-(SP)
    JSR  Task.Exit

    DC.L  Xbra,Magic
PBusErr:  DC.L  0
BusErr:    MOVE.W  #Sys.BUSERR,errNo
    MOVE.L  -14(PC),oldAd
    BRA  CallShow

    DC.L  Xbra,Magic,0
AddrErr:  MOVE.W  #Sys.ADDRERR,errNo
          MOVE.L  -14(PC),oldAd
    BRA  CallShow

    DC.L  Xbra,Magic,0
IllOp:    MOVE.W  #Sys.ILLERR,errNo
    MOVE.L  -14(PC),oldAd
    BRA  CallShow

    DC.L  Xbra,Magic,0
DivZero:        MOVE.W  #Sys.DIVERR,errNo
    MOVE.L  -14(PC),oldAd
    BRA  CallShow

    DC.L  Xbra,Magic,0
ChkErr:         MOVE.W  #Sys.INXERR,errNo
    MOVE.L  -14(PC),oldAd
    BRA  CallShow

    DC.L  Xbra,Magic,0
OvflErr:        MOVE.W  #Sys.OVFLERR,errNo
    MOVE.L  -14(PC),oldAd
    BRA  CallShow

    DC.L  Xbra,Magic,0
PrivErr:        MOVE.W  #Sys.PRIVERR,errNo
    MOVE.L  -14(PC),oldAd
    BRA  CallShow

LinkOldS*:  LEA  BusErr,A0
    SUBQ.L  #4,A0
    TST.L  (A0)
    BEQ    rts

    MOVE.L  #8,A2
    MOVEQ   #6,D0
    MOVE.L  #AddrErr,D1
    SUB.L   #BusErr,D1
Unlink:
    MOVE.L  (A0),(A2)+
    CLR.L  (A0)
    ADD  D1,A0
    DBRA  D0,Unlink

rts:    RTS

  END;
 END LinkNewS;

(*$+k+p *)

PROCEDURE LinkExc*;
 BEGIN
  XBIOS.Supexec(LinkNewS);
 END LinkExc;


PROCEDURE UnlinkExc*;
 BEGIN
  ASSEMBLER

    PEA  LinkOldS
    MOVE  #38,-(SP)
    TRAP  #14
    ADDQ.L  #6,SP

  END;
 END UnlinkExc;


PROCEDURE UnlinkAll;
 BEGIN
  IF Task.level = 0 THEN UnlinkExc END;
 END UnlinkAll;


BEGIN
  LinkExc;
  Task.StoreExit(UnlinkAll);
END Exceptions.
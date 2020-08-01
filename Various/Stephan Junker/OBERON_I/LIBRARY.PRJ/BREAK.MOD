MODULE Break; (* SJ 4.12.94 *)

(*
 Break implement a means of interrupting an endless loop.
 *)


IMPORT
  S:=SYSTEM, Sys, Program, Halt, Task;



VAR
  romBase, vblad, kbshift : S.PTR;
  registers: ARRAY 16 OF LONGINT;        (* Debug.Registers *)
  savedSR: INTEGER;



PROCEDURE GetKbshift;
  (* speichert in kbshift die Adresse der Shiftbits *)
 BEGIN
  ASSEMBLER

(*$O-*)
    PEA     get_sysbase
    MOVE.W  #$26,-(SP)
    TRAP    #14             ;{{$4f2}+8} nach A0 holen
    ADDQ.L  #6,SP
    MOVE.L  romBase,A0
    MOVEM.L $24(A0),A1-A2   ;kbshift und act_pd ab Blitter-TOS
    MOVE.L  A1,kbshift
    UNLK  A6
    RTS

get_sysbase:
    MOVE.L  $04F2.W,A0      ;Sysbase holen
    MOVE.L  8(A0),A0        ;Anfangsadresse des ROMs holen
    MOVE.L  A0,romBase
    RTS
(*$O+*)

  END;
 END GetKbshift;


PROCEDURE LinkVbl*(link: BOOLEAN);
(*
 Links itself into the VBL interrupt if link is true, unlinks if false.
 It is linked on module initialization.
 *)
 BEGIN
  ASSEMBLER

(*$-p *)
    TST.B  link
    BNE  do_link
; unlink
    TST.L  oldVbl
    BEQ    ret

    PEA     unlink_vbl
    MOVE.W  #$26,-(SP)
    TRAP    #14
    ADDQ.L  #6,SP
    CLR.L  oldVbl

ret:
    RETURN

unlink_vbl:
    MOVE.L  oldVbl,$70.W
    RTS

do_link:
    TST.L  oldVbl
    BNE    ret

    PEA     link_vbl
    MOVE.W  #$26,-(SP)
    TRAP    #14
    ADDQ.L  #6,SP
    RETURN

link_vbl:
    MOVE.L  $70.W,oldVbl
    MOVE.L  #CheckAbortion,$70.W
    RTS

    DC.L  58425241H  ; 'XBRA'
    DC.L  4F424E44H  ; 'OBND'
oldVbl:
    DC.L  0

CheckAbortion:
    SUBQ.W  #1,$452.W
    BMI    return

    TST.B  Halt.inException
    BNE  NoTest

CheckKey:
    MOVEM.L  D0/A0,-(SP)
    MOVE.L  kbshift,A0
    MOVE.B  (A0),D0
    AND.B  #7,D0
    CMP.B  #7,D0
    BNE    NoAbortion

    MOVEM.L  D1-D7/A1-A5,-(SP)
    MOVE.W  #$4E75,Sys.CheckStack
    MOVE.L  58(SP),-(SP)
    JSR  Program.AddressInCode
    ADDQ.L  #4,SP
    MOVE.W  #$BFF9,Sys.CheckStack
    TST.B  D0
    BEQ    NotMyProg

    MOVE.B  #1,Halt.inException

    MOVE.L  USP,A0
    MOVE.L  A0,registers+15*4
    MOVE.L  58(SP),-(A0)  ; for call stack / return
    MOVE.L  (A0),Halt.excAddress
    MOVE.L  A0,USP
    MOVEM.L  (SP)+,D1-D7/A1-A5
    MOVEM.L  (SP)+,D0/A0
    MOVEM.L  D0-A6,registers
    MOVE.L  #CallHalt,2(SP)
    MOVE  (SP),savedSR
    BCLR  #7,(SP)    ; trace off

return:
    ADDQ.W  #1,$452.W
    RTE

NotMyProg:
    MOVEM.L  (SP)+,D1-D7/A1-A5

NoAbortion:
    MOVEM.L  (SP)+,D0/A0
NoTest:
    MOVE.L  oldVbl,-(SP)
    ADDQ.W  #1,$452.W
    RTS

CallHalt:
    LINK  A6,#0    ; for call stack
    MOVE.W  #Sys.BREAK,-(SP)
    JSR  Sys.halt
    ADDQ.L  #2,SP
    UNLK  A6
    MOVE  savedSR,CCR
    MOVEM.L  registers,D0-A6
    RTS
(*$+p *)
  END;
 END LinkVbl;


PROCEDURE UnlinkVbl;
 BEGIN
  IF Task.level = 0 THEN LinkVbl(FALSE) END;
 END UnlinkVbl;


PROCEDURE Link*;
 BEGIN
  LinkVbl(TRUE);
 END Link;


PROCEDURE Unlink*;
 BEGIN
  LinkVbl(FALSE);
 END Unlink;


BEGIN
  GetKbshift;
  Link;
  Task.StoreExit(UnlinkVbl);
END Break.
 TEXT 
Begin:
  MOVEA.L   4(A7),A5
  MOVE.L    12(A5),D0 
  ADD.L     20(A5),D0 
  ADD.L     28(A5),D0 
  ADDI.L    #$100,D0
  MOVE.L    D0,-(A7)
  MOVE.L    A5,-(A7)
  MOVE.W    D0,-(A7)
  MOVE.W    #$4A,-(A7)
  TRAP      #1
  LEA       12(A7),A7 
  LEA       NEW_STACK,A7
  DC.B      $A0,$0A 
  BSR       INIT_SCN
  PEA       FADEDOWN
  MOVE.W    #$26,-(A7)
  TRAP      #$E 
  ADDQ.L    #6,A7 
  LEA       NEW_INTRO,A0
  BSR       DO_PEXEC
  BSR       DO_SETTER 
  LEA       MAGGIE_PRG,A0 
  BSR       DO_PEXEC
  BSR       RESTORE_SCN 
  CLR.W     -(A7) 
  TRAP      #1
DO_SETTER:
  MOVE.W    OLD58(PC),D0
  ANDI.W    #$30,D0 
  ORI.W     #1,D0 
  MOVE.W    D0,-(A7)
  MOVE.W    #$58,-(A7)
  TRAP      #$E 
  ADDQ.W    #4,A7 
  PEA       BLANK_PALS
  MOVE.W    #$26,-(A7)
  TRAP      #$E 
  ADDQ.L    #6,A7 
  RTS 
FADEDOWN
  BSR       SAVE_PALS 
  MOVEQ     #$40,D7 
L0002:
  BSR       WAIT_VBL
  BSR       SET_PALS
  BSR       FADE_DOWN 
  DBF       D7,L0002
  CLR.W     -(A7) 
  PEA       $FFFFFFFF.W 
  PEA       $FFFFFFFF.W 
  MOVE.W    #5,-(A7)
  TRAP      #$E 
  LEA       12(A7),A7 
  BRA       BLANK_PALS
  MOVE.L    A0,-(A7)
  MOVE.W    #$59,-(A7)
  TRAP      #$E 
  ADDQ.L    #2,A7 
  MOVEA.L   (A7)+,A0
  CMP.W     #2,D0 
  BNE.S     DO_PEXEC
  RTS 
DO_PEXEC
  MOVE.L    A7,OLD_STACK
  PEA       NULL(PC)
  PEA       NULL(PC)
  PEA       (A0)
  PEA       $4B0000 
  TRAP      #1
  MOVEA.L   OLD_STACK,A7
  RTS 
FADE_DOWN:
  LEA       NEW_PALS,A0 
  MOVE.W    #$FF,D1 
L0005:
  BFEXTU    (A0){0:6},D0
  SUBQ.W    #1,D0 
  BPL.S     L0006 
  MOVEQ     #0,D0 
L0006:
  BFINS     D0,(A0){0:6}
  BFEXTU    (A0){8:6},D0
  SUBQ.W    #1,D0 
  BPL.S     L0007 
  MOVEQ     #0,D0 
L0007:
  BFINS     D0,(A0){8:6}
  BFEXTU    (A0){24:6},D0 
  SUBQ.W    #1,D0 
  BPL.S     L0008 
  MOVEQ     #0,D0 
L0008:
  BFINS     D0,(A0){24:6} 
  ADDQ.W    #4,A0 
  DBF       D1,L0005
  MOVEQ     #$F,D1
L0009:
  BFEXTU    (A0){4:4},D0
  LSL.W     #1,D0 
  BCLR      #4,D0 
  BEQ.S     L000A 
  BSET      #0,D0 
L000A:
  SUBQ.W    #1,D0 
  BPL.S     L000B 
  MOVEQ     #0,D0 
L000B:
  LSR.W     #1,D0 
  BCC.S     L000C 
  BSET      #3,D0 
L000C:
  BFINS     D0,(A0){4:4}
  BFEXTU    (A0){8:4},D0
  LSL.W     #1,D0 
  BCLR      #4,D0 
  BEQ.S     L000D 
  BSET      #0,D0 
L000D:
  SUBQ.W    #1,D0 
  BPL.S     L000E 
  MOVEQ     #0,D0 
L000E:
  LSR.W     #1,D0 
  BCC.S     L000F 
  BSET      #3,D0 
L000F:
  BFINS     D0,(A0){8:4}
  BFEXTU    (A0){12:4},D0 
  LSL.W     #1,D0 
  BCLR      #4,D0 
  BEQ.S     L0010 
  BSET      #0,D0 
L0010:
  SUBQ.W    #1,D0 
  BPL.S     L0011 
  MOVEQ     #0,D0 
L0011:
  LSR.W     #1,D0 
  BCC.S     L0012 
  BSET      #3,D0 
L0012:
  BFINS     D0,(A0){12:4} 
  ADDQ.W    #2,A0 
  DBF       D1,L0009
  RTS 
SAVE_PALS:
  LEA       OLD_PALS,A0 
  LEA       NEW_PALS,A1 
  LEA       $FFFF9800.W,A2
  MOVE.W    #$FF,D1 
L0014:
  MOVE.L    (A2),(A0)+
  MOVE.L    (A2)+,(A1)+ 
  DBF       D1,L0014
  LEA       $FFFF8240.W,A2
  MOVEQ     #$F,D1
L0015:
  MOVE.W    (A2),(A0)+
  MOVE.W    (A2)+,(A1)+ 
  DBF       D1,L0015
  RTS 
BLANK_PALS
  BSR       WAIT_VBL
  LEA       $FFFF9800.W,A0
  MOVE.W    #$FF,D0 
L0017:
  CLR.L     (A0)+ 
  DBF       D0,L0017
  LEA       $FFFF8240.W,A0
  MOVE.W    #7,D0 
L0018:
  CLR.L     (A0)+ 
  DBF       D0,L0018
  RTS 
WAIT_VBL
  MOVEM.L   A0-A6/D0-D7,-(A7) 
  MOVE.W    #$25,-(A7)
  TRAP      #$E 
  ADDQ.L    #2,A7 
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTS 
  LEA       OLD_PALS,A0 
  BRA.S     SETPALS 
SET_PALS
  LEA       NEW_PALS,A0 
  LEA       $FFFF9800.W,A1
SETPALS:
  MOVE.W    #$FF,D0 
L001C:
  MOVE.L    (A0)+,(A1)+ 
  DBF       D0,L001C
  LEA       $FFFF8240.W,A1
  MOVEQ     #$F,D0
L001D:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L001D
  RTS 
INIT_SCN
  MOVE.W    #3,-(A7)
  TRAP      #$E 
  ADDQ.L    #2,A7 
  MOVE.L    D0,OLDLOGIC 
  MOVE.W    #$FFFF,-(A7)
  MOVE.W    #$58,-(A7)
  TRAP      #$E 
  ADDQ.L    #4,A7 
  MOVE.W    D0,OLD58
  RTS 
RESTORE_SCN:
  MOVE.L    OLDLOGIC,D0 
  MOVE.W    OLD58,D1
  BSR.S     XBIOS_SET_SCREEN
  RTS 
XBIOS_SET_SCREEN
  MOVE.W    D1,-(A7)
  MOVE.W    #3,-(A7)
  MOVE.L    D0,-(A7)
  MOVE.L    D0,-(A7)
  MOVE.W    #5,-(A7)
  TRAP      #$E 
  MOVE.W    #$25,-(A7)
  TRAP      #$E 
  LEA       16(A7),A7 
  RTS 
 DATA 
NEW_INTRO:
  DC.B      'DATA\NEWBEAT.DAT',$00
MAGGIE_PRG
  DC.B      'DATA\SHELL.DAT',$00
NULL
  DC.B      $00 
  DC.B      $00 
  DC.B      $00 
  DC.B      $00 
 BSS
OLD58:
  DS.W      1 
OLDLOGIC
  DS.L      1 
OLD_STACK:
  DS.L      1 
OLD_PALS
  DS.B      1056
NEW_PALS
  DS.B      1456
NEW_STACK:
  DS.L      1 
ZUEND: END

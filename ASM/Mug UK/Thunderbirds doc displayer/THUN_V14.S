;
; Thunderbirds DOC Displayer v1.4 by Nanouk
; -----------------------------------------
;
; Ripped by: MUG U.K (of The Source) - 26/6/1992

; NB: The original version had the music on/off toggle on the ';' key -
;     on a French keyboard this is where the 'M' is !!  I've altered it
;     to be the '#' key to toggle music on/off


letter	equ	1	; if =1 then extra letter file included
pd_list	equ	1	; if =1 then pd list is included !
for_sale	equ	1	; if =1 then advert of my stuff appears !!
link_adv	equ	0	; If =1 then advert for GEMDOS Link-Filer !!

                  PEA       START(PC) 
                  MOVE.W    #$26,-(A7) 	;SUPEXEC
                  TRAP      #$E 
                  ADDQ.L    #6,A7 
                  CLR.W     -(A7) 	;PTERM0
                  TRAP      #1

START:            MOVE.B    $FFFF8260.W,D0
                  ANDI.B    #3,D0 
                  CMPI.B    #2,D0 
                  BEQ       L0005 
                  BSR       INIT_PRG 
                  BSR       L005E 
                  LEA       TOG_TABLE,A6
                  BSR       L002F 
                  BSR       L0034 
                  MOVE.L    A6,L00BC
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L009F,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  LEA       DOC_FILE,A1 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    #TBS_MARK,L00BD 
                  MOVE.L    A1,L00BE
;
; Main Keyboard Loop
;
KEY_LOOP:         MOVE.W    #$FF,-(A7)
                  MOVE.W    #6,-(A7) 	;CRAWIO 
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  MOVE.L    D0,D1 
                  SWAP      D1
                  MOVEA.L   LINE_A,A6
                  MOVE.W    6(A6),D3
                  CMPI.W    #1,D3 
                  BEQ       L000A 
                  CMPI.W    #2,D3 
                  BEQ       L0008 
                  CMPI.W    #3,D3 
                  BEQ       L0004 
                  CMPI.B    #$32,D0 
                  BEQ       L000F 
                  CMPI.B    #$38,D0 
                  BEQ       L000C 
                  CMPI.B    #$11,D0 
                  BEQ       L0004 
                  CMPI.B    #$50,D1 ; CURSOR DOWN
                  BEQ       L000A 
                  CMPI.B    #$48,D1 ; CURSOR UP
                  BEQ       L0008 
                  CMPI.B    #$3C,D0 ; SHIFT & , (<)
                  BEQ       INVRT_PAL 
                  CMPI.B    #$10,D0 
                  BEQ       L0040 
                  CMPI.B    #$19,D1 ; P
                  BEQ       L0045 
                  CMPI.B    #$20,D0 
                  BEQ       L000F 
                  CMPI.B    #$62,D1 
                  BEQ       L004B 
                  CMPI.L    #$14,D1 
                  BEQ       L0006 
                  CMPI.L    #$30,D1 
                  BEQ       L0007 
                  CMPI.B    #$21,D1 
                  BEQ       L0062 
                  CMPI.B    #$31,D1 
                  BEQ       L0065 
                  CMPI.B    #$30,D1 
                  BEQ       L0069 
                  CMPI.B    #$2B,D1 	; ";" = MUSIC ON/OFF
                  BEQ       KEY_M 
                  CMPI.B    #$1F,D1 
                  BEQ       HERTZ 
                  CMPI.B    #$1F,D0 
                  BEQ       L0012 
                  CMPI.B    #$54,D1 
                  BLT.B     L0002 
                  CMPI.B    #$5E,D1 
                  BGT.B     L0002 
                  BRA       L0089 
L0002:            CMPI.B    #$3B,D1 	; Scan from F1
                  BLT.B     L0003 	; less than - no key pressed yet
                  CMPI.B    #$45,D1 	; to F11 !! (code for F10 +1)
                  BGT.B     L0003 	; greater than = no key pressed
                  BRA       L008A 
L0003:            BRA       KEY_LOOP 
L0004:            BSR       RESET_PRG 
L0005:            RTS 
L0006:            BSR       L0054 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  LEA       DOC_FILE,A1 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    #TBS_MARK,L00BD 
                  MOVE.L    A1,L00BE
                  MOVEQ     #1,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L0007:            LEA       TOG_TABLE,A6
                  BSR       L0034 
                  BSR       L002F 
                  MOVEA.L   A6,A5 
                  BSR       L0034 
                  MOVE.L    A6,L00BD
                  BSR       L0054 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEA.L   A5,A1 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    A1,L00BE
                  MOVE.W    L00BF,D0
                  SUBI.W    #$16,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L0008:            MOVEA.L   L00BD,A6
                  CMPA.L    #DOC_FILE,A6
                  BGE.B     L0009 
                  MOVEQ     #1,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L0009:            BSR       L003A 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEA.L   L00BD,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   L00BD,A6
                  BSR       L0034 
                  MOVE.L    A6,L00BD
                  MOVEA.L   L00BE,A6
                  BSR       L0034 
                  MOVE.L    A6,L00BE
                  MOVE.W    L00C0,D0
                  BEQ.B     L0009 
                  SUBQ.W    #1,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L000A:            MOVEA.L   L00BE,A1
                  CMPA.L    #TOG_TABLE,A1 
                  BGE.B     L000B 
                  BSR       L003D 
                  MOVEA.L   $44E.W,A0 
                  LEA       29440(A0),A0
                  MOVEA.L   L00BE,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVE.L    A1,L00BE
                  MOVEA.L   L00BD,A6
                  BSR       L0038 
                  MOVE.L    A6,L00BD
                  MOVE.W    L00C0,D0
                  MOVE.W    L00BF,D1
                  CMP.W     D0,D1 
                  BLE.B     L000B 
                  ADDQ.W    #1,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
L000B:            BRA       KEY_LOOP 
L000C:            MOVEA.L   L00BD,A6
                  CMPA.L    #DOC_FILE,A6
                  BLT.B     L000E 
                  BSR       L002F 
                  CMPA.L    #DOC_FILE,A6
                  BGT.B     L000D 
                  LEA       DOC_FILE,A6 
                  MOVE.W    #$18,L00C0
L000D:            MOVEA.L   A6,A5 
                  BSR       L0034 
                  MOVE.L    A6,L00BD
                  BSR       L0054 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEA.L   A5,A1 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    A1,L00BE
                  SUBI.W    #$17,L00C0
                  MOVE.W    L00C0,D0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
L000E:            BRA       KEY_LOOP 
L000F:            MOVEA.L   L00BE,A6
                  CMPA.L    #TOG_TABLE,A6 
                  BGE.B     L0011 
                  CMPA.L    L00BC,A6
                  BLT.B     L0010 
                  MOVEA.L   L00BC,A6
                  MOVE.L    A6,L00BE
                  MOVE.W    L00BF,D0
                  SUBI.W    #$2D,D0 
                  MOVE.W    D0,L00C0
L0010:            BSR       L0034 
                  MOVE.L    A6,L00BD
                  BSR       L0054 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEA.L   L00BE,A1
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    A1,L00BE
                  MOVE.W    L00C0,D0
                  ADDI.W    #$17,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
L0011:            BRA       KEY_LOOP 
L0012:            MOVE.B    #2,$FFFF8260.W
PRINT:            MOVEA.L   A1,A6 
                  LEA       FONT(PC),A2 
L0014:            MOVE.L    #$10003,L0098 
                  LEA       (A0),A4 
                  MOVE.W    #$4F,D7 
L0015:            MOVEQ     #0,D0 
                  MOVE.B    (A1)+,D0
                  BRA       L0023 
L0016:            MOVE.L    L0098,D1
                  SWAP      D1
                  MOVE.L    D1,L0098
                  MOVE.W    D1,L0019
                  LSL.W     #3,D0 
                  MOVEA.L   A2,A3 
                  ADDA.L    D0,A3 
                  JMP       L001C 
L0017             EQU       *-4 
L0018:            LEA       1(A4),A4
L0019             EQU       *-2 
                  DBF       D7,L0015
                  MOVEA.L   A1,A6 
                  BSR       L0038 
                  MOVEA.L   A6,A1 
L001A:            LEA       1280(A0),A0 
                  DBF       D6,L0014
L001B:            RTS 
L001C:            MOVE.B    (A3)+,0(A4) 
                  MOVE.B    (A3)+,160(A4) 
                  MOVE.B    (A3)+,320(A4) 
                  MOVE.B    (A3)+,480(A4) 
                  MOVE.B    (A3)+,640(A4) 
                  MOVE.B    (A3)+,800(A4) 
                  MOVE.B    (A3)+,960(A4) 
                  MOVE.B    (A3)+,1120(A4)
                  BRA       L0018 
L001D:            MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,0(A4)
                  MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,160(A4)
                  MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,320(A4)
                  MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,480(A4)
                  MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,640(A4)
                  MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,800(A4)
                  MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,960(A4)
                  MOVE.B    (A3)+,D0
                  MOVE.B    D0,D1 
                  LSL.B     #1,D1 
                  OR.B      D1,D0 
                  MOVE.B    D0,1120(A4) 
                  BRA       L0018 
L001E:            MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,0(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,160(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,320(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,480(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,640(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,800(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,960(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,1120(A4) 
                  BRA       L0018 
L001F:            MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,0(A4)
                  MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,160(A4)
                  MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,320(A4)
                  MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,480(A4)
                  MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,640(A4)
                  MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,800(A4)
                  MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,960(A4)
                  MOVE.B    (A3)+,D0
                  ANDI.B    #$AA,D0 
                  MOVE.B    D0,1120(A4) 
                  BRA       L0018 
L0020:            MOVE.B    (A3)+,D0
                  LSR.B     #1,D0 
                  MOVE.B    D0,(A4) 
                  MOVE.B    (A3)+,D0
                  LSR.B     #1,D0 
                  MOVE.B    D0,160(A4)
                  MOVE.B    (A3)+,320(A4) 
                  MOVE.B    (A3)+,480(A4) 
                  MOVE.B    (A3)+,640(A4) 
                  MOVE.B    (A3)+,D0
                  LSL.B     #1,D0 
                  MOVE.B    D0,800(A4)
                  MOVE.B    (A3)+,D0
                  LSL.B     #1,D0 
                  MOVE.B    D0,960(A4)
                  MOVE.B    (A3)+,D0
                  LSL.B     #1,D0 
                  MOVE.B    D0,1120(A4) 
                  BRA       L0018 
L0021:            MOVE.B    (A3)+,0(A4) 
                  MOVE.B    (A3)+,160(A4) 
                  MOVE.B    (A3)+,320(A4) 
                  MOVE.B    (A3)+,480(A4) 
                  MOVE.B    (A3)+,640(A4) 
                  MOVE.B    (A3)+,800(A4) 
                  MOVE.B    (A3)+,960(A4) 
                  MOVE.B    #$FF,1120(A4) 
                  BRA       L0018 
L0022:            MOVE.B    (A3)+,D5
                  MOVE.B    D5,2(A4)
                  MOVE.B    (A3)+,D5
                  MOVE.B    D5,162(A4)
                  MOVE.B    (A3)+,D5
                  MOVE.B    D5,322(A4)
                  MOVE.B    (A3)+,D5
                  MOVE.B    D5,482(A4)
                  MOVE.B    (A3)+,D5
                  MOVE.B    D5,642(A4)
                  MOVE.B    (A3)+,D5
                  MOVE.B    D5,802(A4)
                  MOVE.B    (A3)+,D5
                  MOVE.B    D5,962(A4)
                  MOVE.B    (A3)+,D5
                  MOVE.B    D5,1122(A4) 
                  BRA       L0018 
L0023:            TST.B     D0
                  BEQ       L001B 
                  CMPI.B    #$A,D0
                  BEQ       L001A 
                  CMPI.B    #$D,D0
                  BEQ       L0015 
                  CMPI.B    #9,D0 
                  BNE.B     L0025 
                  MOVE.W    L00A4,D0
                  MOVE.W    #$4F,D1 
                  SUB.W     D7,D1 
                  DIVU      D0,D1 
                  MULU      D0,D1 
                  ADD.W     D0,D1 
                  MOVE.W    #$4F,D7 
                  SUB.W     D1,D7 
                  MOVEQ     #0,D0 
                  MOVE.L    #$30001,D2
L0024:            ADD.W     D2,D0 
                  SWAP      D2
                  DBF       D1,L0024
                  SWAP      D2
                  MOVE.L    D2,L0098
                  LEA       0(A0,D0.W),A4 
                  BRA       L0015 
L0025:            CMPI.B    #$1B,D0 
                  BNE       L0016 
                  MOVE.B    (A1)+,D0
                  ADDQ.B    #1,D7 
                  CMPI.B    #$62,D0 
                  BNE.B     L0026 
                  MOVE.L    #L001D,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L0026:            CMPI.B    #$63,D0 
                  BNE.B     L0027 
                  MOVE.L    #L0022,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L0027:            CMPI.B    #$69,D0 
                  BNE.B     L0028 
                  MOVE.L    #L0020,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L0028:            CMPI.B    #$76,D0 
                  BNE.B     L0029 
                  MOVE.L    #L001E,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L0029:            CMPI.B    #$6E,D0 
                  BNE.B     L002A 
                  MOVE.L    #L001C,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L002A:            CMPI.B    #$70,D0 
                  BNE.B     L002B 
                  MOVE.L    #L001E,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L002B:            CMPI.B    #$71,D0 
                  BNE.B     L002C 
                  MOVE.L    #L001C,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L002C:            CMPI.B    #$75,D0 
                  BNE.B     L002D 
                  MOVE.L    #L0021,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L002D:            CMPI.B    #$6C,D0 
                  BNE.B     L002E 
                  MOVE.L    #L001F,L0017
                  ADDQ.B    #1,D7 
                  BRA       L0015 
L002E:            BRA       L0016 
L002F:            MOVEQ     #$15,D1 
L0030:            SUBA.L    #2,A6 
L0031:            MOVE.B    -(A6),D0
                  CMPI.B    #$A,D0
                  BEQ.B     L0032 
                  CMPI.B    #$D,D0
                  BEQ.B     L0032 
                  CMPA.L    #DOC_FILE,A6
                  BLE.B     L0033 
                  BRA.B     L0031 
L0032:            TST.B     (A6)+ 
                  DBF       D1,L0030
L0033:            RTS 
L0034:            SUBA.L    #2,A6 
L0035:            MOVE.B    -(A6),D0
                  CMPI.B    #$A,D0
                  BEQ.B     L0036 
                  CMPI.B    #$D,D0
                  BEQ.B     L0036 
                  CMPA.L    #DOC_FILE,A6
                  BLE.B     L0037 
                  BRA.B     L0035 
L0036:            TST.B     (A6)+ 
L0037:            RTS 
L0038:            MOVEA.L   A6,A5 
                  MOVE.B    (A6)+,D0
                  CMPI.B    #$A,D0
                  BEQ.B     L0039 
                  CMPI.B    #$D,D0
                  BEQ.B     L0039 
                  BRA.B     L0038 
L0039:            TST.B     (A6)+ 
                  RTS 
                  MOVEA.L   A5,A6 
                  RTS 
L003A:            MOVEA.L   $44E.W,A6 
                  LEA       29280(A6),A5
                  LEA       30560(A6),A6
                  MOVE.W    #$AF,D0 
L003B:            MOVEM.L   (A5),A0-A2/D1-D7
                  MOVEM.L   A0-A2/D1-D7,(A6)
                  MOVEM.L   40(A5),A0-A2/D1-D7
                  MOVEM.L   A0-A2/D1-D7,40(A6)
                  MOVEM.L   80(A5),A0-A2/D1-D7
                  MOVEM.L   A0-A2/D1-D7,80(A6)
                  MOVEM.L   120(A5),A0-A2/D1-D7 
                  MOVEM.L   A0-A2/D1-D7,120(A6) 
                  LEA       -160(A5),A5 
                  LEA       -160(A6),A6 
                  DBF       D0,L003B
                  MOVEM.L   L0099,A0-A2/D1-D7 
                  MOVEQ     #7,D0 
L003C:            MOVEM.L   A0-A2/D1-D7,(A6)
                  MOVEM.L   A0-A2/D1-D7,40(A6)
                  MOVEM.L   A0-A2/D1-D7,80(A6)
                  MOVEM.L   A0-A2/D1-D7,120(A6) 
                  LEA       -160(A6),A6 
                  DBF       D0,L003C
                  RTS 
L003D:            MOVEA.L   $44E.W,A6 
                  LEA       2560(A6),A5 
                  LEA       1280(A6),A6 
                  MOVE.W    #$AF,D0 
L003E:            MOVEM.L   (A5),A0-A2/D1-D7
                  MOVEM.L   A0-A2/D1-D7,(A6)
                  MOVEM.L   40(A5),A0-A2/D1-D7
                  MOVEM.L   A0-A2/D1-D7,40(A6)
                  MOVEM.L   80(A5),A0-A2/D1-D7
                  MOVEM.L   A0-A2/D1-D7,80(A6)
                  MOVEM.L   120(A5),A0-A2/D1-D7 
                  MOVEM.L   A0-A2/D1-D7,120(A6) 
                  LEA       160(A5),A5
                  LEA       160(A6),A6
                  DBF       D0,L003E
                  MOVEM.L   L0099,A0-A2/D1-D7 
                  MOVE.W    #7,D0 
L003F:            MOVEM.L   A0-A2/D1-D7,(A6)
                  MOVEM.L   A0-A2/D1-D7,40(A6)
                  MOVEM.L   A0-A2/D1-D7,80(A6)
                  MOVEM.L   A0-A2/D1-D7,120(A6) 
                  LEA       160(A6),A6
                  DBF       D0,L003F
                  RTS 
L0040:            MOVE.W    #$11,-(A7) 	;CPRNOS 
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  TST.W     D0
                  BEQ       L004A 
                  LEA       DOC_FILE,A6 
L0041:            MOVEQ     #0,D0 
                  MOVE.B    (A6)+,D0
                  BEQ.B     L0044 
                  CMPI.W    #9,D0 
                  BEQ.B     L0043 
                  CMPI.W    #$A,D0
                  BEQ.B     L0043 
                  CMPI.W    #$D,D0
                  BEQ.B     L0043 
                  CMPI.W    #$1B,D0 
                  BNE.B     L0042 
                  TST.B     (A6)+ 
                  BRA.B     L0041 
L0042:            CMPI.W    #$20,D0 
                  BLT.B     L0041 
                  CMPI.W    #$F8,D0 
                  BGT.B     L0043 
                  CMPI.W    #$C0,D0 
                  BGE.B     L0041 
L0043:            CMPI.B    #1,$FFFFFC02.W
                  BEQ       L0044 
                  MOVE.W    D0,-(A7)
                  MOVE.W    #5,-(A7) 	;CPRNOUT
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  TST.W     D0
                  BEQ       L004A 
                  BRA.B     L0041 
L0044:            BRA       KEY_LOOP 
L0045:            MOVE.W    #$11,-(A7) 	;CPRNOS 
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  TST.W     D0
                  BEQ       L004A 
                  MOVEA.L   L00BD,A6
                  MOVEA.L   L00BE,A5
L0046:            MOVEQ     #0,D0 
                  MOVE.B    (A6)+,D0
                  CMPI.W    #9,D0 
                  BEQ.B     L0048 
                  CMPI.W    #$A,D0
                  BEQ.B     L0048 
                  CMPI.W    #$D,D0
                  BEQ.B     L0048 
                  CMPI.W    #$1B,D0 
                  BNE.B     L0047 
                  TST.B     (A6)+ 
                  BRA.B     L0046 
L0047:            CMPI.W    #$20,D0 
                  BLT.B     L0046 
                  CMPI.W    #$F8,D0 
                  BGT.B     L0048 
                  CMPI.W    #$C0,D0 
                  BGE.B     L0046 
L0048:            CMPA.L    A6,A5 
                  BLT.B     L0049 
                  CMPI.B    #1,$FFFFFC02.W
                  BEQ       L0049 
                  MOVE.W    D0,-(A7)
                  MOVE.W    #5,-(A7) 	;CPRNOUT
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  TST.W     D0
                  BEQ       L004A 
                  BRA.B     L0046 
L0049:            BRA       KEY_LOOP 
L004A:            MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L00A0,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVE.W    #7,-(A7) 	;CRAWCIN
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L009F,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L004B:            BSR       L0056 
L004C:            MOVEA.L   $44E.W,A0 
                  LEA       HELP_PAGE,A1
                  MOVEQ     #$18,D6 
                  BSR       PRINT 
                  MOVE.W    #7,-(A7) 	;CRAWCIN
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  SWAP      D0
                  CMPI.B    #$20,D0 
                  BEQ       L004E 
                  CMPI.B    #$14,D0 
                  BEQ       L004D 
                  CMPI.B    #$27,D0 
                  BEQ       L004F 
                  CMPI.B    #$18,D0 
                  BEQ       L0050 
                  CMPI.B    #$19,D0 
                  BEQ       L0051 
                  MOVE.W    INIT_PRT,-(A7) 
                  MOVE.W    #$21,-(A7) 	;SETPRT 
                  TRAP      #$E 
                  ADDQ.L    #4,A7 
                  BSR       L0056 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L009F,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEA.L   L00BD,A6
                  BSR       L0038 
                  MOVEA.L   A6,A1 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L004D:            BCHG      #1,INIT_PRT
                  LEA       COLOR,A0
                  BSR       L0052 
                  LEA       MONO,A0 
                  BSR       L0052 
                  BRA       L004C 
L004E:            BCHG      #2,INIT_PRT
                  LEA       ATARI,A0
                  BSR       L0052 
                  LEA       EPSON,A0
                  BSR       L0052 
                  BRA       L004C 
L004F:            BCHG      #3,INIT_PRT
                  LEA       DRAFT,A0
                  BSR       L0052 
                  LEA       FINAL,A0
                  BSR       L0052 
                  BRA       L004C 
L0050:            BCHG      #4,INIT_PRT
                  LEA       CENTRON,A0
                  BSR       L0052 
                  LEA       RS232,A0
                  BSR       L0052 
                  BRA       L004C 
L0051:            BCHG      #5,INIT_PRT
                  LEA       LISTING,A0
                  BSR       L0052 
                  LEA       A4_FORM,A0
                  BSR       L0052 
                  BRA       L004C 
L0052:            CMPI.B    #$E8,(A0) 
                  BEQ.B     L0053 
                  SUBI.B    #1,(A0) 
                  RTS 
L0053:            ADDI.B    #1,(A0) 
                  RTS 
L0054:            MOVEM.L   L0099,A2-A4/D1-D7 
                  MOVEA.L   $44E.W,A6 
                  LEA       1280(A6),A6 
                  MOVE.W    #$B7,D0 
L0055:            MOVEM.L   A2-A4/D1-D7,(A6)
                  MOVEM.L   A2-A4/D1-D7,40(A6)
                  MOVEM.L   A2-A4/D1-D7,80(A6)
                  MOVEM.L   A2-A4/D1-D7,120(A6) 
                  LEA       160(A6),A6
                  DBF       D0,L0055
                  RTS 
L0056:            MOVEA.L   $44E.W,A0 
                  MOVE.W    #$1F3F,D0 
                  MOVE.L    #$FFFF,D1 
L0057:            MOVE.L    D1,(A0)+
                  DBF       D0,L0057
                  RTS 

INVRT_PAL:        MOVE.L    $FFFF8244.W,D0
                  SWAP      D0
                  MOVE.L    D0,$FFFF8244.W
                  BRA       KEY_LOOP 


INIT_PRG:         BSR       L008B 
                  DC.W      $A000 
                  SUBA.L    #$25A,A0
                  MOVE.L    A0,LINE_A
                  DC.W      $A00A 
                  PEA       $E0001
                  TRAP      #$E 
                  ADDQ.L    #4,A7 
                  MOVEA.L   D0,A0 
                  MOVE.W    4(A0),L00B7 
                  MOVE.W    #5,4(A0)
                  MOVE.W    #4,-(A7) 	;GETREZ 
                  TRAP      #$E 
                  ADDQ.L    #2,A7 
                  MOVE.W    D0,OLD_REZ
                  MOVE.L    $466.W,D0 
L005A:            CMP.L     $466.W,D0 
                  BNE.B     L005A 
                  MOVE.B    #1,$FFFF8260.W	; MEDIUM REZ
                  PEA       $F0001
                  MOVE.W    #$23,-(A7) 	;KBRATE 
                  TRAP      #$E 
                  ADDQ.L    #6,A7 
                  MOVE.B    $484.W,BELL_STAT
                  MOVE.B    #6,$484.W 

                  MOVE.W    INIT_PRT,-(A7) 
                  MOVE.W    #$21,-(A7) 	;SETPRT 
                  TRAP      #$E 
                  ADDQ.L    #4,A7 

                  MOVEM.L   $FFFF8240.W,D0-D1 
                  MOVEM.L   D0-D1,OLD_PAL 
                  MOVEM.L   NEW_PAL,D0-D1 
                  MOVEM.L   D0-D1,$FFFF8240.W 
                  BSR       L0056 
;                  JSR       MUSIC	; for GRAZEY relocated files !!
                  BSR       MUS_ON
                  RTS 

RESET_PRG:        MOVE.W    OLD_REZ,D1
                  MOVE.L    $466.W,D0 
L005C:            CMP.L     $466.W,D0 
                  BNE.B     L005C 
                  MOVE.B    D1,$FFFF8260.W
                  MOVEA.L   $44E.W,A0 
                  MOVE.W    #$1F3F,D0 
L005D:            CLR.L     (A0)+ 
                  DBF       D0,L005D
                  PEA       $E0001
                  TRAP      #$E 
                  ADDQ.L    #4,A7 
                  MOVEA.L   D0,A0 
                  MOVE.W    L00B7,4(A0) 
                  PEA       $F0002
                  MOVE.W    #$23,-(A7) 	;KBRATE 
                  TRAP      #$E 
                  ADDQ.L    #6,A7 

                  MOVEM.L   D0-A6,-(SP)
                  MOVEQ     #0,D0
                  JSR       MUSIC
                  MOVEM.L   (SP)+,D0-A6

                  BSR       MUS_OFF 
                  MOVE.B    BELL_STAT,$484.W
                  MOVEM.L   OLD_PAL,D0-D1 
                  MOVEM.L   D0-D1,$FFFF8240.W 
                  DC.B      $A0,$09 
                  RTS 

L005E:            LEA       DOC_FILE,A0 
                  MOVEQ     #1,D0 
L005F:            MOVE.B    (A0)+,D1
                  BEQ.B     L0061 
                  CMPI.B    #$A,D1
                  BEQ.B     L0060 
                  CMPI.B    #$D,D1
                  BEQ.B     L0060 
                  CMPA.L    #END_DOC,A0 
                  BGE.B     L0061 
                  BRA.B     L005F 
L0060:            MOVE.B    (A0)+,D1
                  ADDQ.W    #1,D0 
                  BRA.B     L005F 
L0061:            MOVE.W    D0,L00BF
                  MOVE.W    #1,L00C0
                  BSR       L0087 
                  LEA       L009E,A0
                  BSR       L0084 
                  RTS 
L0062:            MOVEA.L   L00BD,A6
                  BSR       L0038 
                  BSR       L0038 
                  MOVE.L    A6,L0095
                  LEA       L00A1,A0
                  LEA       L00C1,A1
                  MOVEQ     #$F,D0
                  BSR       L006D 
                  BSR       L0074 
                  CMPA.L    #0,A0 
                  BEQ       L0083 
                  CMPA.L    L00BC,A0
                  BLT.B     L0063 
                  MOVEA.L   A0,A6 
                  MOVEA.L   L00BC,A6
                  MOVE.L    A6,L00BE
                  MOVE.W    L00BF,D0
                  SUBI.W    #$16,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0038 
                  MOVEA.L   A6,A0 
                  PEA       (A0)
                  BRA.B     L0064 
L0063:            PEA       (A0)
                  MOVE.W    L00C0,D0
                  ADD.W     D7,D0 
                  MOVE.W    D0,L00C0
L0064:            MOVE.W    L00C0,D0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   (A7)+,A0
                  MOVEA.L   A0,A6 
                  BSR       L0034 
                  MOVEA.L   A6,A1 
                  BSR       L0034 
                  MOVE.L    A6,L00BD
                  BSR       L0054 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    A1,L00BE
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L009F,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L0065:            MOVEA.L   L00BD,A6
                  BSR       L0038 
                  BSR       L0038 
                  MOVE.L    A6,L0095
                  TST.B     L00C1 
                  BEQ       L0068 
                  BSR       L0074 
                  CMPA.L    #0,A0 
                  BEQ       L0083 
                  CMPA.L    L00BC,A0
                  BLT.B     L0066 
                  MOVEA.L   A0,A6 
                  MOVEA.L   L00BC,A6
                  MOVE.L    A6,L00BE
                  MOVE.W    L00BF,D0
                  SUBI.W    #$16,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0038 
                  MOVEA.L   A6,A0 
                  PEA       (A0)
                  BRA.B     L0067 
L0066:            PEA       (A0)
                  MOVE.W    L00C0,D0
                  ADD.W     D7,D0 
                  MOVE.W    D0,L00C0
L0067:            MOVE.W    L00C0,D0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   (A7)+,A0
                  MOVEA.L   A0,A6 
                  BSR       L0034 
                  MOVEA.L   A6,A1 
                  BSR       L0034 
                  MOVE.L    A6,L00BD
                  BSR       L0054 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    A1,L00BE
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L009F,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
L0068:            BRA       KEY_LOOP 
L0069:            MOVEA.L   L00BD,A6
                  BSR       L0038 
                  LEA       -2(A6),A6 
                  MOVE.L    A6,L0095
                  TST.B     L00C1 
                  BEQ       L006C 
                  BSR       L007B 
                  CMPA.L    #0,A0 
                  BEQ       L0083 
                  CMPA.L    L00BC,A0
                  BLT.B     L006A 
                  MOVEA.L   A0,A6 
                  MOVEA.L   L00BC,A6
                  MOVE.L    A6,L00BE
                  MOVE.W    L00BF,D0
                  SUBI.W    #$16,D0 
                  MOVE.W    D0,L00C0
                  BSR       L0038 
                  MOVEA.L   A6,A0 
                  PEA       (A0)
                  BRA.B     L006B 
L006A:            PEA       (A0)
                  MOVE.W    L00C0,D0
                  SUB.W     D7,D0 
                  MOVE.W    D0,L00C0
L006B:            MOVE.W    L00C0,D0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVEA.L   (A7)+,A0
                  MOVEA.L   A0,A6 
                  BSR       L0034 
                  MOVEA.L   A6,A1 
                  BSR       L0034 
                  MOVE.L    A6,L00BD
                  BSR       L0054 
                  MOVEA.L   $44E.W,A0 
                  LEA       1280(A0),A0 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVE.L    A1,L00BE
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L009F,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
L006C:            BRA       KEY_LOOP 
L006D:            MOVEM.L   A1/D0,-(A7) 
                  MOVEA.L   A0,A1 
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  MOVEA.L   A0,A6 
                  LEA       L009A,A5
                  MOVEM.L   (A5),A2-A4/D1-D7
                  MOVEQ     #7,D0 
L006E:            MOVEM.L   A2-A4/D1-D7,(A6)
                  MOVEM.L   A2-A4/D1-D7,40(A6)
                  MOVEM.L   A2-A4/D1-D7,80(A6)
                  MOVEM.L   A2-A4/D1-D7,120(A6) 
                  LEA       160(A6),A6
                  DBF       D0,L006E
                  MOVE.L    #0,D6 
                  BSR       PRINT 
                  MOVEM.L   (A7)+,A1/D0 
                  MOVE.L    D0,D6 
                  MOVE.L    D0,D7 
L006F:            MOVE.W    #7,-(A7) 	;CRAWCIN
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  CMPI.B    #$D,D0
                  BEQ       L0073 
                  CMPI.B    #8,D0 
                  BNE.B     L0071 
                  ADDQ.W    #1,D6 
                  CMP.B     D6,D7 
                  BGE.B     L0070 
                  SUBQ.W    #1,D6 
                  BRA.B     L006F 
L0070:            SUBA.L    #1,A1 
                  MOVE.L    L0098,D1
                  SUBA.W    D1,A4 
                  SWAP      D1
                  MOVE.L    D1,L0098
                  MOVE.W    D1,L0072
                  MOVE.B    #$FF,0(A4)
                  MOVE.B    #$FF,160(A4)
                  MOVE.B    #$FF,320(A4)
                  MOVE.B    #$FF,480(A4)
                  MOVE.B    #$FF,640(A4)
                  MOVE.B    #$FF,800(A4)
                  MOVE.B    #$FF,960(A4)
                  MOVE.B    #$FF,1120(A4) 
                  BRA.B     L006F 
L0071:            TST.W     D6
                  BLE.B     L006F 
                  MOVE.B    D0,(A1)+
                  LEA       FONT(PC),A2 
                  MOVE.L    L0098,D1
                  SWAP      D1
                  MOVE.L    D1,L0098
                  MOVE.W    D1,L0072
                  LSL.W     #3,D0 
                  MOVEA.L   A2,A3 
                  ADDA.W    D0,A3 
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,0(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,160(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,320(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,480(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,640(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,800(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,960(A4)
                  MOVE.B    (A3)+,D0
                  NOT.B     D0
                  MOVE.B    D0,1120(A4) 
                  LEA       1(A4),A4
L0072             EQU       *-2 
                  DBF       D6,L006F
                  BRA       L006F 
L0073:            CLR.B     (A1)
                  RTS 
L0074:            MOVEQ     #1,D7 
                  LEA       L00C1,A0
                  MOVEA.L   L0095,A1
L0075:            MOVE.B    (A0),D0 
                  MOVE.B    (A1)+,D1
                  CMPI.B    #$A,D1
                  BNE.B     L0076 
                  ADDQ.W    #1,D7 
L0076:            CMPA.L    #TOG_TABLE,A1 
                  BGE.B     L0079 
                  CMP.B     D0,D1 
                  BNE.B     L0075 
L0077:            ADDA.L    #1,A0 
                  TST.B     (A0)
                  BEQ.B     L007A 
                  MOVE.B    (A0),D0 
                  MOVE.B    (A1)+,D1
                  CMPI.B    #$A,D1
                  BNE.B     L0078 
                  ADDQ.W    #1,D7 
L0078:            CMPA.L    #TOG_TABLE,A1 
                  BGE.B     L0079 
                  CMP.B     D0,D1 
                  BEQ.B     L0077 
                  LEA       L00C1,A0
                  BRA.B     L0075 
L0079:            LEA       0.L,A0
                  RTS 
L007A:            MOVEA.L   A1,A0 
                  ADDQ.L    #1,A1 
                  MOVE.L    A1,L0095
                  RTS 
L007B:            MOVEQ     #1,D7 
                  LEA       L00C1,A0
L007C:            TST.B     (A0)+ 
                  BNE.B     L007C 
                  LEA       -2(A0),A0 
                  MOVEA.L   A0,A6 
                  MOVEA.L   L0095(PC),A1
L007D:            MOVE.B    (A0),D0 
                  MOVE.B    (A1),D1 
                  SUBA.L    #1,A1 
                  CMPI.B    #$A,D1
                  BNE.B     L007E 
                  ADDQ.W    #1,D7 
L007E:            CMPA.L    #DOC_FILE,A1
                  BLE.B     L0081 
                  CMP.B     D0,D1 
                  BNE.B     L007D 
L007F:            SUBA.L    #1,A0 
                  TST.B     (A0)
                  BEQ.B     L0082 
                  MOVE.B    (A0),D0 
                  MOVE.B    (A1),D1 
                  SUBA.L    #1,A1 
                  CMPI.B    #$A,D1
                  BNE.B     L0080 
                  ADDQ.W    #1,D7 
L0080:            CMPA.L    #DOC_FILE,A1
                  BLE.B     L0081 
                  CMP.B     D0,D1 
                  BEQ.B     L007F 
                  MOVEA.L   A6,A0 
                  BRA.B     L007D 
L0081:            LEA       0.L,A0
                  RTS 
L0082:            MOVEA.L   A1,A0 
                  ADDQ.L    #1,A1 
                  MOVE.L    A1,L0095
                  RTS 
L0083:            MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L00A2,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  MOVE.W    #7,-(A7) 	;CRAWCIN
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
                  LEA       L009F,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L0084:            ADDA.L    #4,A0 
                  MOVEQ     #0,D1 
                  MOVE.W    #3,D2 
L0085:            MOVE.B    D0,D1 
                  ANDI.B    #$F,D1
                  MOVE.B    L0086(PC,D1.W),-(A0)
                  LSR.L     #4,D0 
                  DBF       D2,L0085
                  RTS 
L0086:            DC.B      '0123456789ABCDEF'
L0087:            MOVEQ     #0,D5 
                  MOVEQ     #0,D6 
                  MOVEQ     #0,D7 
                  MOVEQ     #3,D1 
L0088:            ANDI.L    #$FFFF,D0 
                  DIVU      #$A,D0
                  MOVE.L    D0,D6 
                  SWAP      D6
                  LSL.W     D5,D6 
                  OR.W      D6,D7 
                  ADDQ.W    #4,D5 
                  DBF       D1,L0088
                  MOVE.W    D7,D0 
                  RTS 
L0089:            SUBI.B    #$54,D1 
                  MULU      #6,D1 
                  LEA       L009B(PC),A0
                  ADDA.W    D1,A0 
                  MOVE.L    L00BD,(A0)+ 
                  MOVE.W    L00C0,(A0)
                  BRA       KEY_LOOP 

L008A:            SUBI.W    #$3B,D1 
                  MULU      #6,D1 
                  LEA       L009B(PC),A5
                  ADDA.W    D1,A5 
                  BSR       L0054 
                  PEA       (A5)
                  MOVEA.L   (A5),A6 
                  BSR       L0038 
                  MOVEA.L   A6,A1 
                  MOVEA.L   $44E.L,A0 
                  LEA       1280(A0),A0 
                  MOVEQ     #$16,D6 
                  BSR       PRINT 
                  MOVEA.L   (A7)+,A5
                  MOVE.L    (A5),L00BD
                  MOVE.L    A1,L00BE
                  MOVE.W    4(A5),D0
                  MOVE.W    D0,L00C0
                  BSR       L0087 
                  LEA       L009D,A0
                  BSR       L0084 
                  MOVEA.L   $44E.W,A0 
                  LEA       L009C,A1
                  MOVEQ     #0,D6 
                  BSR       PRINT 
                  BRA       KEY_LOOP 
L008B:            LEA       DOC_FILE(PC),A0 
L008C:            MOVE.B    (A0)+,D0
                  CMPA.L    #TOG_TABLE,A0 
                  BGT.B     L008F 
                  TST.B     D0
                  BNE.B     L008D 
                  MOVE.B    #$20,-1(A0) 
                  BRA.B     L008C 
L008D:            CMPI.B    #$A,D0
                  BNE.B     L008E 
                  MOVE.B    (A0)+,D0
                  CMPI.B    #$A,D0
                  BNE.B     L008C 
                  MOVE.B    #$D,-1(A0)
                  BRA.B     L008C 
L008E:            CMPI.B    #$D,D0
                  BNE.B     L008C 
                  MOVE.B    (A0)+,D0
                  CMPI.B    #$D,D0
                  BNE.B     L008C 
                  MOVE.B    #$A,-1(A0)
                  BRA.B     L008C 
L008F:            RTS 

MUS_ON:           MOVE.L    $4D6.W,OLD_456
                  MOVEM.L   D0-A6,-(SP)
                  LEA       MUSIC,A0
                  MOVE.W    -8(A0),D1	; OFFSET TO CALL FOR INIT
                  MOVE.B    -13(A0),D0	; GET TUNE NO. TO USE
                  ANDI.L    #$FF,D0
                  JSR       0(A0,D1.W)	; JSR MUSIC + D1
                  MOVE.W    -4(A0),D0   ; GET VBL OFFSET
                  ADDA.W    D0,A0	; ADD OFFSET TO START OF MUSIC
                  MOVE.L    A0,$4D6.W	; SHOVE IT ON THE VBL
                  BSET      #0,MUSIC_TOG ; MUSIC PLAYING TOGGLE IS NOW ON
                  MOVEM.L   (SP)+,D0-A6
                  RTS 

MUS_OFF:          MOVE.L    OLD_456,$4D6.W
                  MOVE.L    #$A0A0000,$FFFF8800.W 
                  MOVE.L    #$9090000,$FFFF8800.W 
                  MOVE.L    #$8080000,$FFFF8800.W 
                  BCLR      #0,MUSIC_TOG
                  RTS 

KEY_M:            TST.B     MUSIC_TOG 	; IS MUSIC OFF
                  BNE.B     NO_MUSIC
                  BSR       MUS_ON
                  BRA       KEY_LOOP 
NO_MUSIC          BSR       MUS_OFF 
                  BRA       KEY_LOOP 
HERTZ:            BCHG      #1,$FFFF820A.W
                  BRA       KEY_LOOP 

                  SECTION   DATA 

L0095:            DC.L      DOC_FILE
INIT_PRT:         DC.W      $0005
NEW_PAL:          DC.W      $005,$000,$777,$000
L0098:            DC.B      $00,$01,$00,$03 

L0099:            REPT      10
                  DC.L      $0000FFFF
                  ENDR

L009A:            REPT      10
                  DC.L      $FFFFFFFF
                  ENDR

L009B:            REPT      10
                  DC.L      TBS_MARK
                  DC.B      $00,$01 
                  ENDR      

L009C:            DC.B      27,'v THUNDERBIRDS DOC DISPLAYER 1.4 coded by NANOUK         '
                  DC.B      '         Line '
L009D:            DC.B      '0001/' 
L009E:            DC.B      '0000 ',$1B,'n',$00 
L009F:            DC.B      27,'v Use arrows to scroll up and down, Shift arrows to page, HELP for more ...      ',27,'n',0 
L00A0:            DC.B      27,'v Your printer is not ready !!!!!                             -  PRESS ANY KEY - ',27,'n',0 
L00A1:            DC.B      27,'v Enter text to find : ',27,'n',0 
L00A2:            DC.B      27,'v Not found                                                   -  PRESS ANY KEY - ',27,'n',0,0 

;
; New Font Data
;
FONT:             INCBIN    'FONT.BIN'
                  EVEN


L00A4:            DC.B      $00,$08 
HELP_PAGE:        DC.B      13,10 
                  DC.B      '                       ',27,'bTHE THUNDERBIRDS DOC DISPLAYER V1.4',27,'n',13,10
                  DC.B      13,10 
                  DC.B      ' ñ ',27,'bEDITION',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõõõó ñ ',27,'bPRINTER',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõõõõó',13,10 
                  DC.B      ' Ã                                    Ä Ã                                     Ä',13,10 
                  DC.B      ' ÃScroll up ......... ',1,' / Right buttonÄ ÃPrint page ........................ PÄ',13,10 
                  DC.B      ' ÃScroll down ........ ',2,' / Left buttonÄ ÃPrint all text ............... CTRL PÄ',13,10 
                  DC.B      ' ÃPage up .................... Shift ',1,'Ä ÃAbort printing .................. EscÄ',13,10 
                  DC.B      ' ÃPage down .......... Shift ',2,' / SpaceÄ ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö',13,10 
                  DC.B      ' Ã                                    Ä ñ ',27,'bPRINTER CONFIGURATION',27,'n õõõõõõõõõõõõõõó',13,10 
                  DC.B      ' ÃTop of text .................. Alt TÄ Ã                                     Ä',13,10 
                  DC.B      ' Ãbottom of text ............... Alt BÄ Ã',27,'bD',27,'nriver     '
ATARI:            DC.B      'è ATARI       '
EPSON:            DC.B      'é EPSON FX  Ä',13,10 
                  DC.B      ' Ã                                    Ä Ã',27,'bT',27,'nype       '
COLOR:            DC.B      'è COLOR       '
MONO:             DC.B      'é MONOCHROM Ä',13,10 
                  DC.B      ' ÃFind text ........................ FÄ Ã',27,'bM',27,'node       '
DRAFT:            DC.B      'é DRAFT       '
FINAL:            DC.B      'è FINAL     Ä',13,10 
                  DC.B      ' ÃFind next ........................ NÄ Ã',27,'bO',27,'nutput     '
CENTRON:          DC.B      'é CENTRONICS  '
RS232:            DC.B      'è RS232     Ä',13,10 
                  DC.B      ' ÃFind previous .................... BÄ Ã',27,'bP',27,'naper      '
LISTING:          DC.B      'é LISTING     '
A4_FORM:          DC.B      'è A4 FORMAT Ä',13,10 
                  DC.B      ' Ã                                    Ä ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö',13,10 
                  DC.B      ' ÃShift F1 ',3,' F10 ..... Set mark 1 ',3,' 10Ä ñ ',27,'bUSER',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõó',13,10 
                  DC.B      ' ÃF1 ',3,' F10 .......... Goto mark 1 ',3,' 10Ä Ã                                     Ä',13,10 
                  DC.B      ' ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö ÃChange colors ..................... <Ä',13,10 
                  DC.B      ' ñ ',27,'bGREETINGS',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõó Ã50/60Hz ........................... SÄ',13,10 
                  DC.B      ' Ã                                    Ä ÃMusic ON/OFF ...................... #Ä',13,10 
                  DC.B      ' Ã Hi to : FUZION, ARTIS MAGIA, NGC   Ä ÃQuit ......................... CTRL QÄ',13,10 
                  DC.B      ' Ã YOYO, RAF, MISFITS, MAD VISION...  Ä ÃBoot ....................... CTRL DELÄ',13,10 
                  DC.B      ' ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö',13,10 
                  DC.B      0,0 
TBS_MARK:         DC.B      'TBS!',$0D,$0A
;
; Document File goes here
;
;
; Within document:
;
; ESC+b = Bold On
; ESC+v = Inverse Video On
; ESC+n = Normal Text (cancels either one of the above out)

DOC_FILE

	ifne	letter
	incbin	'e:\articles\detonatr.mug'
	even

	dc.b	13,10
	rept	80
	dc.b	'-'
	endr
	dc.b	13,10
	endc

	ifne	pd_list
	incbin	'e:\articles\pd_list.mug'
	even
	endc

	ifne	for_sale
	dc.b	13,10
	incbin	'e:\articles\for_sale.mug'
	even
	dc.b	13,10
	endc

	ifne	link_adv
	dc.b	13,10
	incbin	'e:\articles\link_ad.doc'
	even
	dc.b	13,10
	endc

	rept	80
	dc.b	'-'
	endr

END_DOC:          DC.W      $2000 
;
; VARIOUS TOGGLES & OFFSETS
;
TOG_TABLE	DC.B	0 
	DC.B	0 
	DC.B	$4D 
	DC.B	$58 
	DC.B	4 
	DC.B	1 	; TUNE NO.
	DC.B	-1 
	DC.B	-1 
	DC.B	-1 
	DC.B	-1 
	DC.W	0		; MUSIC INIT OFFSET
	DC.B	-1 
	DC.B	-1
	DC.W	8 	; MUSIC VBL OFFSET
	DC.W	$37D1 

;
; Music File goes here
;
MUSIC:            INCBIN    'jess_1.ovr'
                  EVEN

 BSS
MUSIC_TOG:        DS.W      1
LINE_A:           DS.B      8
L00B7:            DS.W      1
OLD_REZ:          DS.W      1
OLD_PAL:          DS.B      8
BELL_STAT:        DS.W      1
OLD_456:          DS.L      1
L00BC:            DS.L      1
L00BD:            DS.L      1
L00BE:            DS.L      1
L00BF:            DS.L      1
L00C0:            DS.L      1
L00C1:            DS.B      16
ZUEND: END

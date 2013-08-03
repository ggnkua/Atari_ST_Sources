TEST:=	0

 TEXT 
Begin:
  BSR       L0000 
  LEA       L01FA,A7
	IFEQ	TEST
  MOVE      #$2700,SR ; fuck this!
	ENDC
  BSR       L0003 
  BSR       L0005 
  BSR       L0007 
fuck_it_and_loop:
  BSR       start_mainloop 	; mainloop
  BSR       L0005 	; restore
  BSR       L0004 	; restore
  BSR       L0007 	; wait for ikbd flush?
  BRA       L0001 

; init
L0000:
  CLR.L     -(A7) 
  MOVE.W    #$20,-(A7) 	;SUPER
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.L    D0,L0002
  RTS 

; exit
L0001:
  PEA       0.L 
L0002 EQU       *-4 
  MOVE.W    #$20,-(A7) 	;SUPER
  TRAP      #1
  ADDQ.L    #6,A7 
  CLR.W     -(A7) 	;PTERM0
  TRAP      #1
L0003:
  LEA       L01F9,A0
  MOVE.L    $FFFF8200.W,(A0)+ 
  MOVE.B    $FFFF820A.W,(A0)+ 
  MOVE.B    $FFFF8260.W,(A0)+ 
  MOVEM.L   $FFFF8240.W,D0-D7 
  MOVEM.L   D0-D7,(A0)
  LEA       L01F8,A0
  LEA       $FFFFFA00.W,A1
  MOVEP.W   7(A1),D0
  MOVEP.L   19(A1),D1 
  MOVEP.L   27(A1),D2 
  MOVE.W    D0,(A0)+
  MOVE.L    D1,(A0)+
  MOVE.L    D2,(A0)+
  MOVE.L    $68.W,(A0)+ 
  MOVE.L    $70.W,(A0)+ 
  MOVE.L    $110.W,(A0)+
  MOVE.L    $114.W,(A0)+
  MOVE.L    $118.W,(A0)+
  MOVE.L    $120.W,(A0)+
  MOVE.L    $134.W,(A0)+
  RTS 

L0004:
	IFEQ	TEST
  LEA       L01F9,A0
  STOP      #$2300
  MOVE.L    (A0)+,$FFFF8200.W 
  MOVE.B    (A0)+,$FFFF820A.W 
  MOVE.B    (A0)+,$FFFF8260.W 
  STOP      #$2300
  MOVEM.L   (A0),D0-D7
  MOVEM.L   D0-D7,$FFFF8240.W 
  MOVE      #$2700,SR 
  LEA       L01F8,A0
  LEA       $FFFFFA00.W,A1
  MOVE.W    (A0)+,D0
  MOVE.L    (A0)+,D1
  MOVE.L    (A0)+,D2
  MOVEP.W   D0,7(A1)
  MOVEP.L   D1,19(A1) 
  MOVEP.L   D2,27(A1) 
  MOVE.L    (A0)+,$68.W 
  MOVE.L    (A0)+,$70.W 
  MOVE.L    (A0)+,$110.W
  MOVE.L    (A0)+,$114.W
  MOVE.L    (A0)+,$118.W
  MOVE.L    (A0)+,$120.W
  MOVE.L    (A0)+,$134.W
	ENDC
  RTS 
L0005:
	IFEQ	TEST
  MOVE      #$2700,SR 
  LEA       L0006,A0
  LEA       $FFFFFA00.W,A1
  MOVEQ     #0,D0 
  MOVEP.W   D0,7(A1)
  MOVEP.L   D0,19(A1) 
  MOVEP.L   D0,27(A1) 
  MOVE.B    #$40,23(A1) 
  MOVE.L    A0,$68.W
  MOVE.L    A0,$70.W
  MOVE.L    A0,$110.W 
  MOVE.L    A0,$114.W 
  MOVE.L    A0,$118.W 
  MOVE.L    A0,$120.W 
  MOVE.L    A0,$134.W 
	ENDC
  RTS 
L0006:
  RTE 

; wait key
L0007:
  BTST      #0,$FFFFFC00.W
  BEQ.S     L0008 
  MOVE.B    $FFFFFC02.W,D0
  BRA.S     L0007 

L0008:
  RTS 

  MOVE.L    L0252,D0
  MOVE.L    L0253,L0252 
  MOVE.L    D0,L0253
	IFEQ	TEST
  LSR.W     #8,D0 
  MOVE.L    D0,$FFFF8200.W
	ENDC
  MOVE.W    L01FB,D0
L0009:
  CMP.W     L01FB,D0
  BEQ.S     L0009 
  RTS 
L000A:
	IFEQ	TEST
  MOVE.W    L01FB,D0
  BEQ.S     L000C
	ENDC
  CMP.W     #1,D0 
  BNE.S     L000B 
  LEA       $FFFF8203.W,A0
  MOVEP.L   0(A0),D1
  AND.L     #$FFFFFF,D1 
  MOVE.L    L0252,D0
  CMP.L     D0,D1 
  BLE.S     L000D 

L000B:
	IFEQ	TEST
  CLR.W     L01FB 
L000C:
  TST.W     L01FB 
  BEQ.S     L000C 
	ELSE
	move.w	$0468.w,d0
waitvbl:cmp.w	$0468.w,d0
	beq.s	waitvbl
	bsr	update_view_settings
	ENDC
L000D:
  MOVE.L    L0253,D0
  MOVE.L    L0252,L0253 
  MOVE.L    D0,L0252
	IFEQ	TEST
  LSR.W     #8,D0 
  MOVE.L    D0,$FFFF8200.W
	ENDC
  CLR.W     L01FB 
  RTS 

start_mainloop:
  BSR       L0017 
  BSR       L0012 
  BSR       L0030 
  CLR.W     L01FB 
  MOVE.L    #L0125,L020D

mainloop:
	IFEQ	TEST
  MOVE.W    #0,$FFFF8240.W
	ENDC
  BSR       render_scene 
  CMPI.B    #1,$FFFFFC02.w ;#$62,$FFFFFC02.W			; help?
	IFEQ	TEST
  BNE.S     L0010 
  MOVE.W    #$444,$FFFF8240.W 
	ENDC
L0010:
  BSR       L000A 
  BSR       L002F 

	addq.w	#1,frame_counter

  CMPI.B    #$39,$FFFFFC02.W			; space
  BNE.S     mainloop 
  RTS 

frame_counter:
	dc.w	0

L0011:
  MOVE.L    #$F0000,D0
  MOVE.L    #$F8000,D1
  CLR.B     D0
  CLR.B     D1
  MOVE.L    D0,L0252
  MOVE.L    D1,L0253
  LSR.W     #8,D0 
	IFEQ	TEST
  STOP      #$2300
  MOVE.L    D0,$FFFF8200.W
  MOVE.B    #2,$FFFF820A.W
  CLR.B     $FFFF8260.W 
  STOP      #$2300
	ENDC
  BSR       L0013 
  RTS 
L0012:
	IFEQ	TEST
  MOVE      #$2700,SR 
  MOVE.L    #update_view_settings_irq,$70.W
  MOVE.L    #L0016,$80.W
  MOVE      #$2300,SR 
	ENDC
  RTS 
L0013:
  MOVEA.L   L0252,A0
  MOVEA.L   L0253,A1
  MOVE.W    #$1F3F,D0 
  MOVE.W    L020B,D2
  MOVE.W    D2,D1 
  SWAP      D1
  MOVE.W    D2,D1 
L0014:
  MOVE.L    D1,(A0)+
  MOVE.L    D1,(A1)+
  DBF       D0,L0014
  RTS 

update_view_settings_irq:
  MOVEM.L   A0-A6/D0-D7,-(A7) 
  BSR       update_view_settings 
  ADDQ.W    #1,L01FB
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTE 

L0016:
  ADDQ.W    #2,A7 
  RTS 
L0017:
  BSR       L0020 
  BSR       L0019 
  BSR       L0018 
  BSR       L001D 
  BSR       L0026 
  RTS 
L0018:
  LEA       L0225,A0
  BSR       L0023 
  LEA       L0226,A0
  BSR       L0023 
  RTS 
L0019:
  LEA       L0220,A0
  MOVE.L    #$FFFF,D3 
  MOVEQ     #0,D0 
  MOVE.L    D0,(A0)+
  MOVE.W    #$C7,D6 
L001A:
  ADDQ.W    #1,D0 
  MOVE.W    D0,D1 
  MOVEQ     #$F,D2
L001B:
  ROL.W     #1,D1 
  DBCS      D2,L001B
  MOVE.W    D2,(A0)+
  MOVE.L    D3,D4 
  LSL.L     D2,D4 
  DIVU      D0,D4 
  MOVE.W    D4,D5 
  SWAP      D4
  MOVE.W    D0,D2 
  LSR.W     #1,D2 
  CMP.W     D2,D4 
  BLE.S     L001C 
  ADDQ.W    #1,D5 
L001C:
  MOVE.W    D5,(A0)+
  DBF       D6,L001A
  RTS 
L001D:
  LEA       L0221,A0
  MOVE.W    #4,D1 
L001E:
  LEA       L0117,A1
  MOVE.W    #$7FF,D0
L001F:
  MOVE.L    (A1)+,(A0)+ 
  DBF       D0,L001F
  DBF       D1,L001E
  RTS 
L0020:
  LEA       L01FC,A6
  MOVEQ     #0,D0 
  LEA       L021F,A0
  LEA       L021A,A2
  MOVE.L    A0,0(A6)
  MOVE.L    A2,8(A6)
  MOVE.L    A3,12(A6) 
  MOVE.W    D0,26(A6) 
  MOVE.W    D0,28(A6) 
  MOVE.W    D0,30(A6) 
  MOVE.W    #$A0,32(A6) 
  MOVE.W    #$64,34(A6) 
  MOVE.W    #0,36(A6) 
  MOVE.W    #$13F,40(A6)
  MOVE.W    #0,38(A6) 
  MOVE.W    #$C7,42(A6) 
  MOVE.W    #$1AE,24(A6)
  MOVE.W    #1,72(A6) 
  MOVE.W    #$1C2,L0215 
  BSR       L0022 
  RTS 
L0021:
  LEA       L01FC,A6
  MOVE.W    #$FFFF,70(A6) 
  MOVE.W    #0,68(A6) 
  BSR       L0011 
  MOVE.W    #$32,34(A6) 
  MOVE.W    #$63,42(A6) 
  MOVE.L    #L022F,58(A6) 
  MOVE.L    #$140,62(A6)
  MOVE.W    #1,66(A6) 
  BSR       L0018 
  BSR       L00A1 
  RTS 
L0022:
  LEA       L01FC,A6
  MOVE.W    #$FFFF,70(A6) 
  MOVE.W    #0,68(A6) 
  BSR       L0011 
  MOVE.W    #$64,34(A6) 
  MOVE.W    #$C7,42(A6) 
  MOVE.L    #L022E,58(A6) 
  MOVE.L    #$A0,62(A6) 
  MOVE.W    #0,66(A6) 
  BSR       L0018 
  BSR       L00A1 
  RTS 

; initalise some big structure 4*20 times
L0023:
  CLR.W     (A0)+ 
  LEA       16(A0),A1 
  MOVE.W    #3,D0 
L0024:
  MOVE.L    A1,(A0)+
  MOVE.W    #$14,D1 
  MOVEA.L   A1,A2 
  MOVEQ     #$FFFFFFFF,D2 
L0025:
  MOVE.W    D2,(A2)+
  DBF       D1,L0025
  LEA       5600(A1),A1 
  DBF       D0,L0024
  RTS 
L0026:
  MOVE.L    #L0118,L0205
  MOVE.W    #0,L0204
  RTS 

; a6: x,y,z angles
calc_matrix:
  LEA       L021B,A0
  LEA       L0222,A1			; sincos lut
  MOVE.W    30(A6),D0 
  MOVE.W    26(A6),D1 
  MOVE.W    28(A6),D2 
  AND.W     #$1FFC,D0 
  AND.W     #$1FFC,D1 
  AND.W     #$1FFC,D2 

  MOVE.W    D0,D3 
  MOVE.W    D0,D4 
  ADD.W     D2,D3 
  SUB.W     D2,D4 
  MOVE.L    0(A1,D3.W),D5 
  MOVE.L    0(A1,D4.W),D6 
  ADD.W     D5,D6 
  MOVE.W    D6,(A0)+
  SWAP      D5
  SWAP      D6
  ADD.W     D5,D6 
  MOVE.W    D6,(A0)+
  MOVE.W    0(A1,D2.W),D5 
  ADD.W     D5,D5 
  NEG.W     D5
  MOVE.W    D5,(A0)+
  MOVE.W    D1,D3 
  MOVE.W    D1,D4 
  ADD.W     D2,D3 
  SUB.W     D2,D4 
  MOVE.L    0(A1,D3.W),D5 
  MOVE.L    0(A1,D4.W),D6 
  ADD.W     D5,D6 
  MOVE.W    D6,10(A0) 
  SWAP      D5
  SWAP      D6
  ADD.W     D5,D6 
  MOVE.W    D6,4(A0)
  MOVE.W    D0,D3 
  ADD.W     D1,D0 
  SUB.W     D1,D3 
  MOVE.W    D2,D4 
  MOVE.W    D2,D1 
  NEG.W     D1
  MOVE.W    D1,D5 
  ADD.W     D0,D1 
  ADD.W     D0,D2 
  ADD.W     D3,D4 
  ADD.W     D3,D5 
  MOVE.L    0(A1,D0.W),D0 
  MOVE.L    0(A1,D1.W),D1 
  MOVE.L    0(A1,D2.W),D2 
  MOVE.L    0(A1,D3.W),D3 
  MOVE.L    0(A1,D4.W),D4 
  MOVE.L    0(A1,D5.W),D5 
  SWAP      D0
  SWAP      D3
  SUB.W     D2,D1 
  SUB.W     D5,D4 
  ASR.W     #1,D1 
  ASR.W     #1,D4 
  SUB.W     D0,D1 
  SUB.W     D3,D4 
  MOVE.W    D1,D6 
  ADD.W     D4,D6 
  MOVE.W    D6,(A0)+
  SUB.W     D4,D1 
  MOVE.W    D1,6(A0)
  SWAP      D0
  SWAP      D3
  SWAP      D1
  SWAP      D2
  SWAP      D4
  SWAP      D5
  SUB.W     D2,D1 
  SUB.W     D5,D4 
  ASR.W     #1,D1 
  ASR.W     #1,D4 
  ADD.W     D3,D4 
  ADD.W     D0,D1 
  MOVE.W    D1,D6 
  ADD.W     D4,D6 
  MOVE.W    D6,(A0) 
  SUB.W     D1,D4 
  MOVE.W    D4,4(A0)
  RTS 

transform_3d_2d:
  LEA       L021C,A3
  MOVEA.L   A3,A4 
  LEA       12(A3),A3 
  ADDQ.L    #8,A0 
  MOVEA.L   (A0)+,A2
  MOVE.W    (A2)+,D0
  SUBQ.W    #1,D0 
  LEA       L021B,A1
  MOVEM.W   (A1)+,D1-D3 
;L002A:
transform_loop1:
  MOVE.W    (A2)+,D4
  MOVE.W    D4,D5 
  MOVE.W    D4,D6 
  MULS      D1,D4 
  MULS      D2,D5 
  MULS      D3,D6 
  MOVE.L    D4,(A3)+
  MOVE.L    D5,(A3)+
  MOVE.L    D6,(A3)+
  NEG.L     D4
  NEG.L     D5
  NEG.L     D6
  MOVEM.L   D4-D6,-(A4) 
  DBF       D0,transform_loop1
  LEA       L021D,A3
  MOVEA.L   A3,A4 
  LEA       12(A3),A3 
  MOVEA.L   (A0)+,A2
  MOVE.W    (A2)+,D0
  SUBQ.W    #1,D0 
  MOVEM.W   (A1)+,D1-D3 
;L002B:
transform_loop2:
  MOVE.W    (A2)+,D4
  MOVE.W    D4,D5 
  MOVE.W    D4,D6 
  MULS      D1,D4 
  MULS      D2,D5 
  MULS      D3,D6 
  MOVE.L    D4,(A3)+
  MOVE.L    D5,(A3)+
  MOVE.L    D6,(A3)+
  NEG.L     D4
  NEG.L     D5
  NEG.L     D6
  MOVEM.L   D4-D6,-(A4) 
  DBF       D0,transform_loop2 ;L002B
  LEA       L021E,A3
  MOVEA.L   A3,A4 
  LEA       12(A3),A3 
  MOVEA.L   (A0)+,A2
  MOVE.W    (A2)+,D0
  SUBQ.W    #1,D0 
  MOVEM.W   (A1)+,D1-D3 
transform_loop3:
;L002C:
  MOVE.W    (A2)+,D4
  MOVE.W    D4,D5 
  MOVE.W    D4,D6 
  MULS      D1,D4 
  MULS      D2,D5 
  MULS      D3,D6 
  MOVE.L    D4,(A3)+
  MOVE.L    D5,(A3)+
  MOVE.L    D6,(A3)+
  NEG.L     D4
  NEG.L     D5
  NEG.L     D6
  MOVEM.L   D4-D6,-(A4) 
  DBF       D0,transform_loop3 ;L002C
  MOVEA.L   (A0)+,A0
  MOVE.W    (A0)+,D0
  SUBQ.W    #1,D0 
  LEA       L0119(PC),A4
  MOVEA.L   0(A6),A5
  MOVEQ     #0,D4 
  MOVE.W    24(A6),D4 
  SWAP      D4
  MOVEQ     #0,D5 
  MOVE.W    20(A6),D5 
  SWAP      D5
  ASR.L     #4,D5 
  MOVEQ     #0,D6 
  MOVE.W    22(A6),D6 
  SWAP      D6
  ASR.L     #4,D6 
  TST.W     66(A6)
  BNE.S     perspect_loop2
perspect_loop1:
  MOVEM.L   (A4),A1-A3
  MOVEM.W   (A0)+,D1-D3 
  ADDA.W    D1,A1 
  ADDA.W    D2,A2 
  ADDA.W    D3,A3 
  MOVEM.L   (A1)+,D1-D3 
  ADD.L     (A2)+,D1
  ADD.L     (A3)+,D1
  ADD.L     (A2)+,D2
  ADD.L     (A3)+,D2
  ADD.L     (A2)+,D3
  ADD.L     (A3)+,D3
  ADD.L     D4,D3 
  ADD.L     D5,D1 
  ADD.L     D6,D2 
  SWAP      D3
  ROL.L     #4,D3 
  ASR.L     #3,D1 
  ASR.L     #3,D2 
  DIVS      D3,D1 
  DIVS      D3,D2 
  ADD.W     32(A6),D1 
  ADD.W     34(A6),D2 
  MOVE.W    D1,(A5)+
  MOVE.W    D2,(A5)+
  DBF       D0,perspect_loop1
  RTS 
perspect_loop2:
  MOVEM.L   (A4),A1-A3
  MOVEM.W   (A0)+,D1-D3 
  ADDA.W    D1,A1 
  ADDA.W    D2,A2 
  ADDA.W    D3,A3 
  MOVEM.L   (A1)+,D1-D3 
  ADD.L     (A2)+,D1
  ADD.L     (A3)+,D1
  ADD.L     (A2)+,D2
  ADD.L     (A3)+,D2
  ADD.L     (A2)+,D3
  ADD.L     (A3)+,D3
  ADD.L     D4,D3 
  ADD.L     D5,D1 
  ADD.L     D6,D2 
  SWAP      D3
  ROL.L     #3,D3 
  ASR.L     #3,D1 
  ASR.L     #4,D2 
  DIVS      D3,D1 
  DIVS      D3,D2 
  ADD.W     32(A6),D1 
  ADD.W     34(A6),D2 
  MOVE.W    D1,(A5)+
  MOVE.W    D2,(A5)+
  DBF       D0,perspect_loop2
  RTS 

L002F:
	IFEQ	TEST
  MOVEM.L   L0216,D0-D7 
  MOVEM.L   D0-D7,$FFFF8240.W 
	ENDC
  RTS 
  BSR       L0021 
  RTS 

; unused? unless some offset jmp is in play?
  MOVE.L    #L0125,L020D
  BSR       transform 
  LEA       L0225,A0
  BSR       update_magic_structure 
  BSR       paint_polys 

;  DC.B      $06,$B9,$00,$00,$00,$A0 
;  DC.L      L0252 
	addi.l	#$A0,L0252

  MOVE.L    #L0125,L020D
  NEG.W     L01FD 
  NEG.W     L01FE 
  BSR       transform 
  LEA       L0226,A0
  BSR       update_magic_structure 
  BSR       paint_polys 

;  DC.B      $04,$B9,$00,$00,$00,$A0 
;  DC.L      L0252 
	subi.l	#$A0,L0252
  RTS 

L0030:
  BSR       L0022 
  RTS 

render_scene:
  BSR       transform 
  LEA       L0225,A0
  BSR       update_magic_structure
  BSR       paint_polys 
  RTS 

; a0: poly structure
; this stores addresses and swaps them in the structure
; it also keeps track of a counter at 0(a0)
update_magic_structure:
  MOVEA.L   A0,A1 
  MOVE.W    (A0)+,D0
  ADDA.W    D0,A0 
  MOVE.L    (A0),D1 
  MOVE.L    4(A0),D2
  MOVE.L    D1,L0223
  MOVE.L    D2,L0224
  MOVE.L    D2,(A0) 
  MOVE.L    D1,4(A0)
  ADDQ.W    #8,D0 
  CMP.W     #$10,D0 
  BLT.S     .wrapped 
  CLR.W     D0
.wrapped:
  MOVE.W    D0,(A1) 
  RTS 

update_view_settings:
  MOVE.W    L0211,D0
  ADD.W     #8,D0 
  CMP.W     #$1680,D0 
  BLT.S     L0035 
  MOVE.W    #0,L0204
  SUB.W     #$1680,D0 
L0035:
  MOVE.W    D0,L0211
  LEA       L0118,A0
  ADDA.W    D0,A0 
  MOVE.L    A0,L0205
  ADDI.W    #$24,L0210
  ADDI.W    #$30,L020F
  ADDI.W    #$28,L020E
  MOVE.W    L0210,D0
  MOVE.W    L020E,D1
  MOVE.W    L020F,D2
  AND.W     #$1FFC,D0 
  AND.W     #$1FFC,D1 
  AND.W     #$1FFC,D2 
  LEA       L0221,A0
  MOVE.W    0(A0,D0.W),D0 
  MOVE.W    0(A0,D1.W),D1 
  MOVE.W    0(A0,D2.W),D2 
  MOVE.W    L0215,L01FF 
  ASR.W     #4,D1 
  ASR.W     #4,D2 
  MOVE.W    xrotspeed,D0
  ADD.W     D0,L0200
  MOVE.W    L0213,D0
  ADD.W     D0,L0201
  MOVE.W    L0214,D0
  ADD.W     D0,L0202
  RTS 
L0036:
  CLR.W     D0
  MOVE.B    $FFFFFC02.W,D0
  SUB.W     #$3B,D0 			; function keys?
  BLT       L0037 
  CMP.W     #$A,D0
  BGE.S     L0037 
  ADD.W     D0,D0 
  ADD.W     D0,D0 
  LEA       function_key_routs,A0
  MOVEA.L   0(A0,D0.W),A0 
  JSR       (A0)
L0037:
  RTS 

transform:
  LEA       L01FC,A6
  BSR       calc_matrix
  MOVEA.L   L020D,A0
  BSR       transform_3d_2d
  BSR       L0036
  RTS 

paint_polys:
  MOVEA.L   L020D,A0
  MOVEA.L   L0224,A1
  BSR       scan_convert_polys
  MOVEA.L   L0223,A0
  MOVEA.L   L0224,A1
  CLR.W     L0203 
  LEA       L0219,A2
  MOVE.W    (A1)+,D0
  SUBQ.W    #1,D0
  BMI.S     L0041
  ADDQ.L    #2,A0

	IFEQ	TEST
; what on earth? sets user mode, it seems?
  MOVE      #$300,SR
	ENDC

; poly loop? seems like this is done 6 times + cube = yes
; seems to use poly structure
poly_loop:
  MOVE.W    (A0),D1 
  MOVE.W    (A1),D2 
  CMP.W     D1,D2 
  BEQ.S     L003C 
  TST.W     D1
  BMI.S     L003B 
  BSR       L0043 
  LEA       20(A0),A0 
  ADDQ.L    #2,A1 
  BRA.S     L003F 
L003B:
  BSR       L0042 
  ADDQ.L    #2,A0 
  LEA       20(A1),A1 
  BRA.S     L003F 
L003C:
  TST.W     D1
  BMI.S     L003E 
  TST.W     2(A0) 
  BEQ.S     L003D 
  ADDQ.W    #1,L0203
  MOVE.L    A1,(A2)+
  BSR       L0043 
  LEA       20(A0),A0 
  LEA       20(A1),A1 
  BRA.S     L003F 
L003D:
  BSR       L0045 			; delta stuffs, a0: old trap, a1: new trap
  LEA       20(A0),A0 
  LEA       20(A1),A1 
  BRA.S     L003F
 L003E:
  ADDQ.L    #2,A0 
  ADDQ.L    #2,A1 
L003F:
  DBF       D0,poly_loop
  MOVE.W    L0203,D0
  SUBQ.W    #1,D0 
  BMI.S     L0041 
  LEA       L0219,A2
add_poly_loop:
  MOVEA.L   (A2)+,A1
  BSR       L0042 
  DBF       D0,add_poly_loop
L0041:

; TODO: que?!? ah, fuck what a nasty hack. what is installed there?
; when keeping supervisor, this is not needed..
; i know what this is now. it's for safe a7 abuse.
; an interrupt doesn't cause the a7 stack area to be fucked, only the ssp
; this is cause (some?) paint code runs in user
	IFEQ	TEST
  TRAP      #0
	ELSE
	;addq	#2,sp ;?
	;bra	fuck_it_and_loop
	ENDC
  RTS 

; is this ever used? 
; i guess it's garden variety dead code.
  MOVEM.L   A0-A2/D0,-(A7)
  MOVE.L    L0252,D5
  MOVEQ     #$FFFFFFF8,D4 
  MOVE.W    L020A,D6
  MOVE.W    L020B,D7
  ADD.W     4(A1),D5
  MOVE.W    6(A1),D1
  MOVE.W    8(A1),D0
  SUB.W     D1,D0 
  MOVEA.L   y_offset_table,A2
  ADD.W     D1,D1 
  ADD.W     0(A2,D1.W),D5 
  ADDQ.W    #1,D0 
  MOVEA.L   10(A1),A0 
  CLR.W     18(A1)
  MOVEA.L   14(A1),A1 
  BSR       wipe_new_spans 
  MOVEM.L   (A7)+,A0-A2/D0
  RTS 

; some (partial?) poly painter?
; seems more like a full blown poly clear..
; but it uses fresh tables. so, not a clear??
L0042:
  MOVEM.L   A0-A2/D0,-(A7)
  MOVE.L    L0252,D5
  MOVEQ     #$FFFFFFF8,D4 
  MOVE.W    L020A,D6
  MOVE.W    L020B,D7
  ADD.W     4(A1),D5
  MOVE.W    6(A1),D1
  MOVE.W    8(A1),D0
  SUB.W     D1,D0 
  MOVEA.L   y_offset_table,A2
  ADD.W     D1,D1 
  ADD.W     0(A2,D1.W),D5 
  ADDQ.W    #1,D0 
  MOVEA.L   10(A1),A0 
  CLR.W     18(A1)
  MOVEA.L   14(A1),A1 
  BSR       fill_spans 
  MOVEM.L   (A7)+,A0-A2/D0
  RTS 

; some (partial?) poly painter
; uses old scan tables. has also two cases (probably hi/lo index reversal)
L0043:
  MOVEM.L   A0-A2/D0,-(A7)
  MOVE.L    L0252,D5
  MOVEQ     #$FFFFFFF8,D4 
  MOVE.W    L020A,D6
  MOVE.W    L020B,D7
  ADD.W     4(A0),D5
  MOVE.W    6(A0),D1
  MOVE.W    8(A0),D0
  SUB.W     D1,D0 
  MOVEA.L   y_offset_table,A2
  ADD.W     D1,D1 
  ADD.W     0(A2,D1.W),D5 
  ADDQ.W    #1,D0 
  MOVEA.L   10(A0),A5 
  MOVEA.L   14(A0),A6 
  TST.W     18(A0)
  BEQ.S     L0044 
  BSR       wipe_spans0
  MOVEM.L   (A7)+,A0-A2/D0
  RTS 
L0044:
  BSR       wipe_spans 
  MOVEM.L   (A7)+,A0-A2/D0
  RTS 

; really long and magical poly painter
; a0: trapezoid struct? (old?)
; a1: trapezoid struct? (new?)
L0045:
  MOVEM.L   A0-A2/D0,-(A7)
  MOVEQ     #$FFFFFFF8,D4 
  MOVE.W    L020A,D6
  MOVE.W    L020B,D7
  MOVE.L    L0252,D5			; d5.l=screen
  ADDQ.L    #6,A0 
  MOVE.W    (A0)+,D0			; d0.w=x0?
  MOVE.W    (A0)+,D1			; d1.w=y0?
  MOVEA.L   (A0)+,A5			; a5: old left scans
  MOVEA.L   (A0)+,A6			; a6: old right scans
  TST.W     (A0)			; code path choice
  BEQ       L004D 
  ADDQ.L    #4,A1 
  ADD.W     (A1)+,D5			; screen offset
  MOVE.W    (A1)+,D2			; x1?
  MOVE.W    (A1)+,D3			; y1?
  MOVEA.L   (A1)+,A0			; a0: new left scans
  MOVE.W    #0,4(A1)
  MOVEA.L   (A1)+,A1			; a1: new right scans
  CMP.W     D1,D2 
  BGT       L004B 
  CMP.W     D0,D3 
  BLT       L004B 
  CMP.W     D0,D2 
  BGT.S     L0047 
  BEQ.S     L0046 
  MOVE.W    D3,-(A7)
  MOVE.W    D0,-(A7)
  MOVE.W    D1,-(A7)
  SUB.W     D2,D0 
  ADD.W     D2,D2 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D2.W),D5 
  BSR       wipe_new_spans 
  MOVEM.W   (A7)+,D1-D3 
  BRA.S     L0048 
L0046:
  ADD.W     D0,D0 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D0.W),D5 
  BRA.S     L0048 
L0047:
  MOVEM.W   D1-D3,-(A7) 
  EXG       D2,D0 
  SUB.W     D2,D0 
  ADD.W     D2,D2 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D2.W),D5 
  BSR       wipe_spans0 
  MOVEM.W   (A7)+,D1-D3 
L0048:
  CMP.W     D1,D3 
  BGT.S     L0049 
  BEQ.S     L004A 
  SUB.W     D3,D1 
  SUB.W     D2,D3 
  MOVE.W    D1,-(A7)
  MOVE.W    D3,D0 
  ADDQ.W    #1,D0 
  BSR       wipe_delta_spans 
  MOVE.W    (A7)+,D0
  BSR       wipe_spans0 
  BRA.S     L004C 
L0049:
  SUB.W     D1,D3 
  SUB.W     D2,D1 
  MOVE.W    D3,-(A7)
  MOVE.W    D1,D0 
  ADDQ.W    #1,D0 
  BSR       wipe_delta_spans 
  MOVE.W    (A7)+,D0
  BSR       wipe_new_spans 
  BRA.S     L004C 
L004A:
  SUB.W     D2,D1 
  MOVE.W    D1,D0 
  ADDQ.W    #1,D0 
  BSR       wipe_delta_spans 
  BRA.S     L004C 
L004B:
  SUB.W     D0,D1 
  EXG       D1,D0 
  SUB.W     D2,D3 
  MOVE.W    D3,-(A7)
  MOVE.W    D2,-(A7)
  MOVE.L    D5,-(A7)
  ADD.W     D1,D1 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D1.W),D5 
  ADDQ.W    #1,D0 
  BSR       wipe_spans0 
  MOVE.L    (A7)+,D5
  MOVE.W    (A7)+,D1
  MOVE.W    (A7)+,D0
  ADD.W     D1,D1 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D1.W),D5 
  ADDQ.W    #1,D0 
  BSR       wipe_new_spans 
L004C:
  MOVEM.L   (A7)+,A0-A2/D0
  RTS 
; a1: trapezoid structure
L004D:
  ADDQ.L    #4,A1 
  ADD.W     (A1)+,D5
  MOVE.W    (A1)+,D2				; x?
  MOVE.W    (A1)+,D3				; y?
  MOVEA.L   (A1)+,A0				; a0: left scans
  MOVE.W    #$FFFF,4(A1)
  MOVEA.L   (A1)+,A1				; a1: right scans
  CMP.W     D1,D2 				; y comparison? (left edge longer than right?)
  BGT       L0053 
  CMP.W     D0,D3 
  BLT       L0053 
  CMP.W     D0,D2 
  BGT.S     L004F 
  BEQ.S     L004E 
  MOVE.W    D3,-(A7)
  MOVE.W    D0,-(A7)
  MOVE.W    D1,-(A7)
  SUB.W     D2,D0 
  ADD.W     D2,D2 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D2.W),D5 
  BSR       paint_new_spans 
  MOVEM.W   (A7)+,D1-D3 
  BRA.S     L0050 
L004E:
  ADD.W     D0,D0 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D0.W),D5 
  BRA.S     L0050 
L004F:
  MOVEM.W   D1-D3,-(A7) 
  EXG       D2,D0 			; d2.w=y_start
  SUB.W     D2,D0 
  ADD.W     D2,D2 
  MOVEA.L   y_offset_table,A4			; scan table
  ADD.W     0(A4,D2.W),D5 		; add y_offset to screen offset?
  BSR       wipe_spans 
  MOVEM.W   (A7)+,D1-D3 
L0050:
  CMP.W     D1,D3 
  BGT.S     L0051 
  BEQ.S     L0052 
  SUB.W     D3,D1 
  SUB.W     D2,D3 
  MOVE.W    D1,-(A7)
  MOVE.W    D3,D0 
  ADDQ.W    #1,D0 
  BSR       paint_delta_spans 
  MOVE.W    (A7)+,D0
  BSR       wipe_spans 
  BRA.S     L0054 
L0051:
  SUB.W     D1,D3 
  SUB.W     D2,D1 
  MOVE.W    D3,-(A7)
  MOVE.W    D1,D0 
  ADDQ.W    #1,D0 
  BSR       paint_delta_spans 
  MOVE.W    (A7)+,D0
  BSR       paint_new_spans 
  BRA.S     L0054 
L0052:
  SUB.W     D2,D1 
  MOVE.W    D1,D0 
  ADDQ.W    #1,D0 
  BSR       paint_delta_spans 
  BRA.S     L0054 
L0053:
  SUB.W     D0,D1 
  EXG       D1,D0 
  SUB.W     D2,D3 
  MOVE.W    D3,-(A7)
  MOVE.W    D2,-(A7)
  MOVE.L    D5,-(A7)
  ADD.W     D1,D1 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D1.W),D5 
  ADDQ.W    #1,D0 
  BSR       wipe_spans 
  MOVE.L    (A7)+,D5
  MOVE.W    (A7)+,D1
  MOVE.W    (A7)+,D0
  ADD.W     D1,D1 
  MOVEA.L   y_offset_table,A4
  ADD.W     0(A4,D1.W),D5 
  ADDQ.W    #1,D0 
  BSR       paint_new_spans 
L0054:
  MOVEM.L   (A7)+,A0-A2/D0
  RTS 

scan_convert_polys:
  LEA       200(A1),A2			; a2: slope structures
  LEA       200(A2),A3			; a3: coordinates
  LEA       L01FC,A6
  MOVEM.L   A0-A2,-(A7)
  BSR       calc_slopes_of_all_polys ;L0075
  MOVEA.L   (A7)+,A0
  MOVEA.L   4(A0),A5
  JSR       (A5)
  MOVEM.L   (A7)+,A2/A0 
  MOVE.W    (A0)+,D0
  SUBQ.W    #1,D0 
  BMI.S     L005A 
  TST.W     L0204 			; special flag, wibble/dist mode
  BNE.S     scan_conv_disted_loop 
scan_convert_poly_loop:
  TST.W     (A0)			; culled?
  BPL.S     L0057 			; leave it.. if not, convert.
  ADDQ.L    #2,A0 
  DBF       D0,scan_convert_poly_loop
  BRA.S     L005A 
L0057:
  BSR       convert_to_traps 
  LEA       20(A0),A0 
  DBF       D0,scan_convert_poly_loop
  BRA.S     L005A 
scan_conv_disted_loop:
  TST.W     (A0)
  BPL.S     L0059
  ADDQ.L    #2,A0 
  DBF       D0,scan_conv_disted_loop
  BRA.S     L005A 
L0059:
  BSR       L0065 
  LEA       20(A0),A0 
  DBF       D0,scan_conv_disted_loop
L005A:
  RTS 

; a0: pointers to edge structure indices?
; a1: scan buffer
; a2: ? array of structures (edges!) 10 bytes big each. coords and slopes.
;       nasty union too. slope is overwritten by an address
; [height.w, x_start.w, adr/slope .l, flag.w] (this must be an edge!)
convert_to_traps:
  MOVEA.L   10(A0),A3 			; a3: next bunch of edges?
  MOVE.L    A1,10(A0) 			; replace edge structures pointer with real-life scans
  MOVE.W    (A3)+,D1			; d1.w= #edges in this side
  SUBQ.W    #1,D1
edge_convert_loop0:
  MOVE.W    (A3)+,D2			; d2.w=offset to edge struct
  LEA       2(A2,D2.W),A4 		; a4: structure with height and slope?
  MOVE.W    (A4),D2			; d2.w=+/-height
  BPL.S     L005E
; special sauce: copy scans? why? how? only if height < 0
  TST.W     8(A4)			; flag? if this is 0, then copy and loop..
  BEQ.S     L005D			; if not.. copy and go scanning
  BSR       copy_scans
  DBF       D1,edge_convert_loop0
  MOVE.L    (A5)+,(A1)+
  BRA.S     L0060
L005D:
  MOVE.W    2(A4),D3
  LSL.W     #3,D3
  MOVE.W    D3,(A1)+
  ADDQ.W    #1,D2
  BSR       copy_scans
  DBF       D1,edge_convert_loop0
  MOVE.L    (A5)+,(A1)+
  BRA.S     L0060
L005E:
  NEG.W     D2				; d2.w=-height
  MOVE.W    D2,(A4)+
  MOVE.W    (A4),D3			; d3.w= x_start
  MOVE.L    2(A4),D4
  BMI.S     L005F
; non-negative slope
  MOVE.W    D3,D5
  LSL.W     #3,D5
  MOVE.W    D5,(A1)+			; write first x
  MOVE.L    A1,2(A4)
  CLR.W     6(A4)			; clear flag
  ADDQ.W    #1,D2			; d2.w=1-height
  BSR       convert_scans
  DBF       D1,edge_convert_loop0
  ASR.L     #1,D4
  MOVE.L    D3,D5
  ADD.L     D4,D5
  SWAP      D5
  MOVE.W    D5,D3
  MOVE.L    D3,(A1)+			; write last pair of x
  BRA.S     L0060
; negative slope
L005F:
  MOVE.L    A1,2(A4)
  MOVE.W    #$FFFF,6(A4)
  BSR       convert_scans 
  DBF       D1,edge_convert_loop0
  ASR.L     #1,D4 
  SUB.L     D4,D3 
  MOVE.L    D3,(A1)+
L0060:
  MOVEA.L   14(A0),A3 			; a3: next bunch of edges?
  MOVE.L    A1,14(A0) 			; replace edge structures pointer with real-life scans
  MOVE.W    (A3)+,D1
  SUBQ.W    #1,D1 
convert_edge_loop:
  MOVE.W    (A3)+,D2
  LEA       2(A2,D2.W),A4 
  MOVE.W    (A4),D2 			; d2.w=height
  BPL.S     L0063 			; scan convert if height>0
  TST.W     8(A4) 			; test flag (copy-only if clear)
  BNE.S     L0062 			; otherwise copy once and go scanning.
  BSR       copy_scans 
  DBF       D1,convert_edge_loop
  MOVE.L    (A5)+,(A1)+ 
  RTS 
L0062:
  MOVE.W    2(A4),D3			; d3.w=x_start
  LSL.W     #3,D3 
  MOVE.W    D3,(A1)+			; store first x.
  ADDQ.W    #1,D2 			; d2.w=1-height
  BSR       copy_scans 
  DBF       D1,convert_edge_loop
  MOVE.L    (A5)+,(A1)+ 
  RTS 
L0063:
  NEG.W     D2
  MOVE.W    D2,(A4)+				; store -height
  MOVE.W    (A4),D3 				; d3.w=start_x
  MOVE.L    2(A4),D4				; d4.l=slope
  BPL.S     L0064 
  MOVE.W    #$FFFF,6(A4)			; set flag
  MOVE.W    D3,D5 
  LSL.W     #3,D5 
  MOVE.W    D5,(A1)+				; store first x.
  MOVE.L    A1,2(A4)				; store end of edge in scan buf.
  ADDQ.W    #1,D2
  BSR       convert_scans
  DBF       D1,convert_edge_loop
  ASR.L     #1,D4 
  MOVE.L    D3,D5 
  ADD.L     D4,D5 
  SWAP      D5
  MOVE.W    D5,D3 
  MOVE.L    D3,(A1)+
  RTS 
L0064:
  MOVE.L    A1,2(A4)
  CLR.W     6(A4) 
  BSR       convert_scans 
  DBF       D1,convert_edge_loop
  ASR.L     #1,D4 
  SUB.L     D4,D3 
  MOVE.L    D3,(A1)+
  RTS 

; eh, special scanning? seems like wibble time to me
L0065:
  MOVEA.L   L0205,A6
  MOVE.W    6(A0),D1
  ADD.W     D1,D1 
  ADDA.W    D1,A6 
  MOVE.L    A6,-(A7)
  MOVEA.L   10(A0),A3 
  MOVE.L    A1,10(A0) 
  MOVE.W    (A3)+,D1
  SUBQ.W    #1,D1 
L0066:
  MOVE.W    (A3)+,D2
  LEA       2(A2,D2.W),A4 
  MOVE.W    (A4)+,D2
  NEG.W     D2
  MOVE.W    (A4),D3 
  MOVE.L    2(A4),D4
  BMI.S     L0067 
  MOVE.W    D3,D5 
  LSL.W     #3,D5 
  ADDQ.W    #4,D5 
  ADD.W     (A6)+,D5
  MOVE.W    D5,(A1)+
  ADDQ.W    #1,D2 
  BSR       L0072 
  DBF       D1,L0066
  ASR.L     #1,D4 
  MOVE.L    D3,D5 
  ADD.L     D4,D5 
  SWAP      D5
  MOVE.W    D5,D3 
  SWAP      D3
  ADD.W     (A6)+,D3
  SWAP      D3
  ADD.W     (A6)+,D3
  MOVE.L    D3,(A1)+
  BRA.S     L0068 
L0067:
  BSR       L0072 
  DBF       D1,L0066
  ASR.L     #1,D4 
  SUB.L     D4,D3 
  SWAP      D3
  ADD.W     (A6)+,D3
  SWAP      D3
  MOVE.L    D3,(A1)+
L0068:
  MOVEA.L   (A7)+,A6
  MOVEA.L   14(A0),A3 
  MOVE.L    A1,14(A0) 
  MOVE.W    (A3)+,D1
  SUBQ.W    #1,D1 
L0069:
  MOVE.W    (A3)+,D2
  LEA       2(A2,D2.W),A4 
  MOVE.W    (A4)+,D2
  NEG.W     D2
  MOVE.W    (A4),D3 
  MOVE.L    2(A4),D4
  BPL.S     L006A 
  MOVE.W    D3,D5 
  LSL.W     #3,D5 
  ADDQ.W    #4,D5 
  ADD.W     (A6)+,D5
  MOVE.W    D5,(A1)+
  ADDQ.W    #1,D2 
  BSR       L0072 
  DBF       D1,L0069
  ASR.L     #1,D4 
  MOVE.L    D3,D5 
  ADD.L     D4,D5 
  SWAP      D5
  MOVE.W    D5,D3 
  SWAP      D3
  ADD.W     (A6)+,D3
  SWAP      D3
  ADD.W     (A6)+,D3
  MOVE.L    D3,(A1)+
  RTS 
L006A:
  BSR       L0072 
  DBF       D1,L0069
  ASR.L     #1,D4 
  SUB.L     D4,D3 
  SWAP      D3
  ADD.W     (A6)+,D3
  SWAP      D3
  MOVE.L    D3,(A1)+
  RTS 

; copy?! or?!
; d2.w=height
copy_scans:
  MOVEA.L   4(A4),A5			; a5: old (end/start?) of scans
  ASR.W     #1,D2 
  BCC.S     L006C 
  MOVE.W    (A5)+,(A1)+ 		; copy first scan.
  ADDQ.W    #1,D2 
L006C:
  ADD.W     D2,D2 
  BPL       L006E 
  ADD.W     #$190,D2
  JMP       L006D(PC,D2.W)
L006D:
	rept	200
	MOVE.L	(A5)+,(A1)+
	endr
L006E:
  RTS 

; scan conversion
; d2.w= 1-height
; d3.w= x_start
; d4.l= slope (16:16)
convert_scans:
  MOVE.L    A2,-(A7)
  SWAP      D3
  MOVE.W    #$7FFF,D3 
  ADD.L     D3,D3 
  ADD.L     D4,D3
  ASL.L     #2,D3				; d3.l=(x_start+.5*step)*8 (16:16)
  ASL.L     #3,D4 				; d4.l=slope*8 (16:16)
  LEA       L0232,A2
  ADD.W     D2,D2 
  BPL       L0071 
  MOVE.W    0(A2,D2.W),D2 
  MOVE.W    D3,D6 
  MOVE.W    D4,D7 
  SWAP      D3
  SWAP      D4
  JMP       L0070(PC,D2.W)
L0070:
	rept	200
	MOVE.W	D3,(A1)+
	ADD.W	D7,D6
	ADDX.W	D4,D3
	endr
  SWAP      D3
  SWAP      D4
L0071:
  MOVEA.L   (A7)+,A2
  RTS 

; special scan conversion.. wibble time.
L0072:
  SWAP      D3
  MOVE.W    #$7FFF,D3 
  ADD.L     D3,D3 
  ADD.L     D4,D3 
  ASL.L     #2,D3 
  ASL.L     #3,D4 
  MOVE.L    A2,-(A7)
  LEA       L0230,A2
  ADD.W     D2,D2 
  BPL       L0074 
  MOVE.W    0(A2,D2.W),D2 
  MOVE.W    D3,D6 
  MOVE.W    D4,D7 
  SWAP      D3
  SWAP      D4
  JMP       L0073(PC,D2.W)
L0073:
	rept	200
	MOVE.W	D3,D5
	ADD.W	(A6)+,D5
	MOVE.W	D5,(A1)+
	ADD.W	D7,D6
	ADDX.W	D4,D3
	endr
  SWAP      D3
  SWAP      D4
L0074:
  MOVEA.L   (A7)+,A2
  RTS 

calc_slopes_of_all_polys:
  CLR.W     (A2)
  MOVE.L    A2,4(A6)
  MOVE.L    A3,16(A6) 
  MOVEA.L   24(A0),A5 
  MOVE.W    (A5),D0 
  SUBQ.W    #1,D0 
  LEA       L021A,A4
  MOVE.L    A4,8(A6)
  LEA       L021F,A5
  MOVEQ     #0,D1 
L0076:
  MOVE.L    D1,(A4)+
  DBF       D0,L0076
  MOVE.L    A5,0(A6)
  MOVEA.L   28(A0),A5 
  MOVE.W    (A5)+,D0
  MOVE.W    D0,(A1)+
  SUBQ.W    #1,D0 
  BMI.S     L0079
  MOVEQ     #0,D1 

calc_poly_slopes_loop:
  MOVEA.L   (A5)+,A0
  MOVEM.L   A5/D0-D1,-(A7)
  BSR       calc_poly_slopes
  MOVEM.L   (A7)+,A5/D0-D1
  BEQ.S     .next
  MOVE.W    #$FFFF,(A1)+
.next:
  DBF       D0,calc_poly_slopes_loop
L0079:
  MOVEA.L   16(A6),A1 
  RTS 

; back-face culling..
; and slope calculation..
; a0: polygon structure
calc_poly_slopes:
  MOVEM.L   A0-A1,-(A7) 
  MOVEA.L   0(A6),A3
  LEA       8(A0),A4			; a4: poly rout pointers, indices, count?
  LEA       L0217(PC),A5
  MOVEA.L   (A4)+,A1			; a1: rout ptr 1 (set?)
  MOVEA.L   (A4)+,A2			; a2: rout ptr 2 (term?)
  MOVEM.W   (A4)+,D7/D0-D3
  MOVE.L    0(A3,D0.W),D0 		; xy0
  MOVE.L    0(A3,D1.W),D1 		; xy1 
  MOVE.L    0(A3,D2.W),D2  		; xy2
  MOVE.L    0(A3,D3.W),D3  		; xy3
  SUB.W     D0,D1			; d1.w=y1-y0
  SUB.W     D2,D3 			; d3.w=y3-y2
  SWAP      D0
  SWAP      D1
  SWAP      D2
  SWAP      D3
  SUB.W     D1,D0 			; d0.w=x0-x1
  SUB.W     D3,D2 			; d2.w=x2-x3
  SWAP      D1				; d1.w=y1-y0
  SWAP      D3				; d3.w=y3-y2
  MULS      D1,D2 			; d2.l=(y1-y0)(x2-x3)
  MULS      D3,D0  			; d0.l=(y3-y2)(x0-x1)
; outer product over 4 points? what the? i hope the 3D vectors are perpendicular at least. it's not such a common choice.. 
  SUB.L     D2,D0
  BLT.S     L007B
  BEQ.S     L007F
  JSR       (A2)
  TST.W     4(A0)
  BEQ.S     L007F
  BSR       L0085
  BRA.S     L007C
L007B:
  JSR       (A1)
  BSR.S     make_direct_poly_minmax
; compare top/btm
L007C:
  MOVE.W    38(A6),D2 
  MOVE.W    42(A6),D3 
  CMP.W     D3,D0 
  BGE.S     L007F 
  CMP.W     D2,D1 
  BLE.S     L007F 
  CMP.W     D2,D0 
  BGT.S     L007D 
  MOVE.W    D2,D0
; d0,d1 = clipped top and bottom 
L007D:
  CMP.W     D3,D1 
  BLT.S     L007E 
  MOVE.W    D3,D1 
L007E:
  MOVEM.W   D0-D1,-(A7) 
  MOVE.W    D2,D0 
  MOVE.W    D3,D1 
  LEA       L0217(PC),A0		; a0: start of direct poly
  ADDQ.W    #1,D7 
  MOVE.L    (A0),(A5) 			; wrap it!
  LEA       L0218(PC),A5
  MOVEA.L   A0,A4 
  BSR       L008A 			; clip or something?
  MOVEM.W   (A7)+,D0-D1 
  BSR       L0096 			; some min/max vertex finder?
  MOVEM.L   (A7)+,A0-A1 
  CMP.W     D0,D1 
  BEQ.S     L0080 
  MOVE.L    (A0)+,(A1)+ 
  ADDQ.L    #2,A0 
  MOVE.W    (A0)+,(A1)+ 
  MOVE.W    D0,(A1)+
  MOVE.W    D1,(A1)+
  BSR       L0098 			; does the mean slope calcs
  BSR       L009B 
  ADDQ.L    #2,A1 
  MOVEQ     #0,D0 
  RTS 
L007F:
  MOVEM.L   (A7)+,A0-A1 
L0080:
  MOVEQ     #1,D0 
  RTS 

; makes direct poly with x,y coords from an indexed one.  
; with minmax..
; d7.w=#points ?
; a3: 2D vertices
; a4: indices to vertices (rhymes) (seems like indices are doubled up..)
; a6: structure with minmax
; out
; d0.w=top
; d1.w=btm
make_direct_poly_minmax:
  MOVE.W    D7,D4 
  SUBQ.W    #1,D4 
  MOVE.W    42(A6),D0 			; top
  MOVE.W    38(A6),D1 			; btm
L0082:
  MOVE.W    (A4)+,D6
  MOVE.W    (A4)+,D5			; useless?
  MOVE.L    0(A3,D6.W),D6 		; d6.l=xy
  CMP.W     D6,D0 
  BLT.S     L0083 
  MOVE.W    D6,D0 
L0083:
  CMP.W     D6,D1 
  BGT.S     L0084 
  MOVE.W    D6,D1 
L0084:
  MOVE.L    D6,(A5)+			; store xy
  MOVE.W    D5,(A5)+			; wtf?! store index as well?
  DBF       D4,L0082
  RTS 

L0085:
  MOVE.W    (A4),D6 
  MOVE.W    D7,D4 
  ADD.W     D4,D4 
  ADD.W     D4,D4 
  ADDA.W    D4,A4 
  MOVE.W    D7,D4 
  SUBQ.W    #1,D4 
  MOVE.W    42(A6),D0 
  MOVE.W    38(A6),D1 
  MOVE.W    -(A4),D5
  BRA.S     L0087 
L0086:
  MOVE.W    -(A4),D6
  MOVE.W    -(A4),D5
L0087:
  MOVE.L    0(A3,D6.W),D6 
  CMP.W     D6,D0 
  BLT.S     L0088 
  MOVE.W    D6,D0 
L0088:
  CMP.W     D6,D1 
  BGT.S     L0089 
  MOVE.W    D6,D1 
L0089:
  MOVE.L    D6,(A5)+
  MOVE.W    D5,(A5)+
  DBF       D4,L0086
  RTS 

; clipper?
; d1.w=clipped btm
; a4: direct poly
L008A:
  MOVE.L    A6,-(A7)
  SUBA.W    A6,A6 
  MOVEA.L   A5,A3 
  SUBQ.W    #2,D7 
  MOVE.L    (A4)+,D2
  MOVEA.W   (A4)+,A2
  CMP.W     D1,D2 
  BGT       L008F 
  CMP.W     D0,D2 
  BGE.S     L008D 
L008B:
  MOVE.L    D2,D3 
  MOVEA.L   A2,A1 
  MOVE.L    (A4)+,D2
  MOVEA.W   (A4)+,A2
  CMP.W     D0,D2 
  DBGT      D7,L008B
  TST.W     D7
  BMI       L0091 
  CMP.W     D1,D2 
  BGT.S     L008C 
  BSR       L0092 
  MOVE.W    A1,(A5)+
  MOVE.L    D6,(A5)+
  ADDQ.W    #1,A6 
  DBF       D7,L008D
  BRA       L0091 
L008C:
  BSR       L0092 
  MOVE.W    A1,(A5)+
  MOVE.L    D6,(A5)+
  BSR       L0094 
  MOVE.W    #$FFFF,(A5)+
  MOVE.L    D6,(A5)+
  ADDQ.W    #2,A6 
  DBF       D7,L008F
  BRA       L0091 
; loop that copies the direct poly.. (reordering elements?)
L008D:
  MOVE.L    D2,D3 
  MOVEA.L   A2,A1 
  MOVE.W    A1,(A5)+
  MOVE.L    D2,(A5)+
  MOVE.L    (A4)+,D2
  MOVEA.W   (A4)+,A2
  ADDQ.W    #1,A6 
  CMP.W     D0,D2 
  BLT.S     L008E 
  CMP.W     D1,D2 
  DBGT      D7,L008D
  TST.W     D7
  BMI.S     L0091 
  BSR       L0094 
  MOVE.W    #$FFFF,(A5)+
  MOVE.L    D6,(A5)+
  ADDQ.W    #1,A6 
  DBF       D7,L008F
  BRA.S     L0091 
L008E:
  EXG       D3,D2 
  BSR.S     L0092 
  MOVE.W    #$FFFF,(A5)+
  MOVE.L    D6,(A5)+
  ADDQ.W    #1,A6 
  EXG       D3,D2 
  DBF       D7,L008B
  BRA.S     L0091 
L008F:
  MOVE.L    D2,D3 
  MOVEA.L   A2,A1 
  MOVE.L    (A4)+,D2
  MOVEA.W   (A4)+,A2
  CMP.W     D1,D2 
  DBLT      D7,L008F
  TST.W     D7
  BMI.S     L0091 
  CMP.W     D0,D2 
  BLT.S     L0090 
  EXG       D3,D2 
  BSR.S     L0094 
  MOVE.W    A1,(A5)+
  MOVE.L    D6,(A5)+
  ADDQ.W    #1,A6 
  EXG       D3,D2 
  DBF       D7,L008D
  BRA.S     L0091 
L0090:
  EXG       D3,D2 
  BSR.S     L0094 
  MOVE.W    A1,(A5)+
  MOVE.L    D6,(A5)+
  BSR.S     L0092 
  MOVE.W    #$FFFF,(A5)+
  MOVE.L    D6,(A5)+
  ADDQ.W    #2,A6 
  EXG       D3,D2 
  DBF       D7,L008B
L0091:
  MOVE.W    A6,D7 
  MOVEA.L   (A7)+,A6
  RTS 

; compute slope?
L0092:
  MOVEA.W   D3,A0 
  MOVE.L    D3,D4 
  MOVE.L    D2,D5 
  SWAP      D4
  SWAP      D5
  SUB.W     D5,D4 
  BEQ.S     L0093 
  MOVE.W    D0,D6 
  SWAP      D6
  MOVE.W    D0,D6 
  SUB.W     D2,D6 
  SUB.W     D2,D3 
  MULS      D6,D4 
  DIVS      D3,D4 
  ADD.W     D4,D5 
  MOVE.W    D5,D6 
  MOVE.W    A0,D3 
  SWAP      D6
  RTS 
L0093:
  MOVE.W    D5,D6 
  SWAP      D6
  MOVE.W    D0,D6 
  RTS 

; compute slope?
L0094:
  MOVEA.W   D3,A0 
  MOVE.L    D3,D4 
  MOVE.L    D2,D5 
  SWAP      D4
  SWAP      D5
  SUB.W     D5,D4 
  BEQ.S     L0095 
  MOVE.W    D1,D6 
  SWAP      D6
  MOVE.W    D1,D6 
  SUB.W     D2,D6 
  SUB.W     D2,D3 
  MULS      D6,D4 
  DIVS      D3,D4 
  ADD.W     D4,D5 
  MOVE.W    D5,D6 
  MOVE.W    A0,D3 
  SWAP      D6
  RTS 

L0095:
  MOVE.W    D5,D6 
  SWAP      D6
  MOVE.W    D1,D6 
  RTS 
L0096:
  MOVEA.L   A3,A4 
  MOVE.W    D7,D3 
  SUBQ.W    #1,D3 
L0097:
  ADDQ.L    #2,A4 
  MOVE.L    (A4)+,D2
  CMP.W     D0,D2 
  DBEQ      D3,L0097
  SUBQ.L    #6,A4 
  RTS 

; main slope calcs..
; a6: ?
L0098:
  MOVEA.L   16(A6),A0 
  MOVE.L    A0,(A1)+
  MOVEM.L   A4/A0-A1,-(A7)
  MOVEQ     #0,D2 
  ADDQ.L    #2,A0 
  MOVE.W    (A4),D6 
  MOVE.L    2(A4),D3
L0099:
  CMPA.L    A3,A4 
  BGT.S     L009A 
  MOVEA.L   A5,A4 
L009A:
  MOVE.L    D3,D5 
  MOVE.L    D6,D4 
  MOVE.L    -(A4),D3
  MOVE.W    -(A4),D6
  CMP.W     D0,D3 
  BEQ.S     L0099 
  ADDQ.W    #1,D2 
  BSR       calc_slope 
  CMP.W     D1,D3 
  BNE.S     L0099 
  MOVE.L    A0,16(A6) 
  MOVEM.L   (A7)+,A4/A0-A1
  MOVE.W    D2,(A0) 
  RTS 

L009B:
  MOVEA.L   16(A6),A0 
  MOVE.L    A0,(A1)+
  MOVEM.L   A4/A0-A1,-(A7)
  MOVEQ     #0,D2 
  ADDQ.L    #2,A0 
  MOVE.W    (A4)+,D4
  MOVE.L    (A4)+,D3
L009C:
  CMPA.L    A5,A4 
  BLT.S     L009D 
  MOVEA.L   A3,A4 
L009D:
  MOVE.L    D3,D5 
  MOVE.L    D4,D6 
  MOVE.W    (A4)+,D4
  MOVE.L    (A4)+,D3
  CMP.W     D0,D3 
  BEQ.S     L009C 
  ADDQ.W    #1,D2 
  BSR       calc_slope 
  CMP.W     D1,D3 
  BNE.S     L009C 
  MOVE.L    A0,16(A6) 
  MOVEM.L   (A7)+,A4/A0-A1
  MOVE.W    D2,(A0) 
  RTS 

calc_slope:
  TST.W     D6
  BMI.S     calc_normal_slope 
  MOVEA.L   8(A6),A1
  ADDA.W    D6,A1 
  TST.W     (A1)
  BEQ.S     calc_normal_slope 
  MOVE.W    2(A1),(A0)+ 
  RTS 
calc_normal_slope:
  MOVE.W    #$FFFF,(A1)+
  MOVEA.L   4(A6),A2
  MOVE.W    (A2),D7 
  MOVE.W    D7,(A1) 
  MOVE.W    D7,(A0)+
  LEA       2(A2,D7.W),A1 
  ADD.W     #$A,D7
  MOVE.W    D7,(A2) 
  SUB.W     D3,D5 				; d5.w=dy
  NEG.W     D5					; d5.w=-dy
  MOVE.W    D5,(A1)+				; store -dy.
  LEA       L0220,A2
  ADD.W     D5,D5 
  ADD.W     D5,D5 
  MOVE.L    0(A2,D5.W),D7 			; d5.l=(exp.w<<16)|mantissa.w
  SWAP      D3					; d3.w=x1
  SWAP      D5					; d5.w=x2
  MOVE.W    D5,(A1)+				; store x2.
  SUB.W     D3,D5 				; d5.w=dx
  BPL.S     .pos
; case for negative dx.. 
  NEG.W     D5
  MULU      D7,D5 
  SWAP      D7
  LSR.L     D7,D5 
  MOVE.L    D5,(A1)+				; store dx/dy.
  SWAP      D3
  RTS
; case for positive dx.. 
.pos:
  MULU      D7,D5 
  SWAP      D7
  LSR.L     D7,D5 
  NEG.L     D5
  MOVE.L    D5,(A1)+				; store dx/dy.
  SWAP      D3
  RTS 

L00A1:
  BSR       L00BF 
  BSR       L00BC 
  BSR       L00C8 
  BSR       L00C4 
  BSR       L00B3 
  BSR       L00B0 
  BSR       L00B6 
  BSR       L00B9 
  BSR       L0103 
  BSR       L0106 
  BSR       L0109 
  BSR       L010B 
  BSR       L010D 
  BSR       L010F 
  BSR       gen_mul6_lut 
  RTS 

;-------------------------------------------------------------------------------
; fillers, wipers, delta fill/wipe, etc
; d5.l=screen (+offset?)
;-------------------------------------------------------------------------------

lampje:	dc.w	0

wipe_delta_spans:
;	addq.w	#1,lampje
  SUB.L     L0207,D5					; temporary offset (but what is it?)
  ADD.W     D0,D0 
  LEA       0(A0,D0.W),A2 
  LEA       0(A5,D0.W),A3 
  LEA       0(A1,D0.W),A4 
  MOVE.W    (A2),-(A7)
  MOVE.W    (A3),-(A7)
  MOVE.W    (A4),-(A7)
  MOVE.W    #0,(A2) 
  MOVE.W    #$7210,(A3) 
  LEA       offsetmask_lut0,A4				; normal offsets inside this one..
  LEA       L0234,A2
  LEA       L0237,A3
  PEA       L00A3 
  EXG       A7,D5 
  JMP       wipe_delta_spans_code 
L00A3:
  MOVE.W    (A7)+,-(A1) 
  MOVE.W    (A7)+,-(A5) 
  MOVE.W    (A7)+,-(A0) 
  SUBQ.L    #2,A6 
  ADD.L     L0207,D5
  RTS 

; input:
; d0.w=y index
; a0,a1,a5: edge scan tables
paint_delta_spans:
	addq.w	#1,lampje
  SUB.L     L0207,D5
  ADD.W     D0,D0 
  LEA       0(A0,D0.W),A2 
  LEA       0(A5,D0.W),A3 
  LEA       0(A1,D0.W),A4 
; push scanned x values onto the stack.
  MOVE.W    (A2),-(A7)
  MOVE.W    (A3),-(A7)
  MOVE.W    (A4),-(A7)
; replace old x values (prolly with jump offsets)
  MOVE.W    #0,(A2) 
  MOVE.W    #$E420,(A3) 
  LEA       offsetmask_lut1,A4		; x20 offsets in this one..
  LEA       L0239,A2			; + $FFFF8DF0 = L0238
  LEA       L023C,A3			; + $FFFF8DF0 = L023A
  PEA       L00A5 
  EXG       A7,D5 
  JMP       delta_filler_code
L00A5:
  MOVE.W    (A7)+,-(A1) 
  MOVE.W    (A7)+,-(A5) 
  MOVE.W    (A7)+,-(A0) 
  SUBQ.L    #2,A6 
  ADD.L     L0207,D5
  RTS 

; fully wipe spans (not just sides)
wipe_new_spans:
  ADD.W     D0,D0 
  LEA       0(A0,D0.W),A2 
  LEA       0(A1,D0.W),A3 
  MOVE.W    (A2),-(A7)
  MOVE.W    (A3),-(A7)
  MOVE.W    #0,(A2) 
  MOVE.W    #$2940,(A3) 
  LEA       offsetmask_lut0,A3		; note: this is a lut, no code!
  LEA       offsetmask_lut1,A4
  LEA       L023F,A2			; + $FFFF8DF0 = L023D
  PEA       L00A7 
  EXG       A7,D5 
  JMP       wipe_new_code 
L00A7:
  MOVE.W    (A7)+,(A1)
  MOVE.W    (A7)+,-(A0) 
  RTS 

; this is used in the first frame (must be normal filler, i.e. non-delta)
fill_spans:
  ADD.W     D0,D0 
  LEA       0(A0,D0.W),A2 
  LEA       0(A1,D0.W),A3 
  MOVE.W    (A2),-(A7)
  MOVE.W    (A3),-(A7)
  MOVE.W    #0,(A2) 
  MOVE.W    #$2940,(A3) 
  LEA       offsetmask_lut0,A3
  LEA       offsetmask_lut1,A4
  LEA       L0245,A2
  PEA       L00A9 
  EXG       A7,D5 
  JMP       filler_code
L00A9:
  MOVE.W    (A7)+,(A1)
  MOVE.W    (A7)+,-(A0) 
  RTS 

; this one seems quite exceptional..
; it wipes old stuff so all offsets are already in the scan tables? 
wipe_spans0:
  ADD.W     D0,D0 
  LEA       0(A5,D0.W),A2 
  LEA       0(A6,D0.W),A3 
  MOVE.W    (A2)+,-(A7) 
  MOVE.W    (A3)+,-(A7) 
  MOVE.W    #$7210,-(A2)
  MOVE.W    #$8DF0,-(A3)
  LEA       L0248,A2			; this is no offsetmask lut.. it's a code table
  MOVEA.L   A2,A4
  PEA       L00AB 
  EXG       A7,D5 
  JMP       wipe_code 
L00AB:
  MOVE.W    (A7)+,-(A6) 
  MOVE.W    (A7)+,-(A5) 
  RTS 

paint_new_spans:
  ADD.W     D0,D0 
  LEA       0(A0,D0.W),A2 
  LEA       0(A1,D0.W),A3 
  MOVE.W    (A2),-(A7)
  MOVE.W    (A3),-(A7)
  MOVE.W    #$2940,(A2) 
  MOVE.W    #0,(A3) 
  LEA       L022C,A3
  LEA       L0229,A4
  LEA       L0242,A2
  PEA       L00AD 
  EXG       A7,D5 
  JMP       paint_new_code 
L00AD:
  MOVE.W    (A7)+,(A1)
  MOVE.W    (A7)+,-(A0) 
  RTS 

; cleaning rout? vertical part of delta?
wipe_spans:
  ADD.W     D0,D0 
  LEA       0(A5,D0.W),A2 		; a2: old left scans?
  LEA       0(A6,D0.W),A3 		; a3: old right scans?
  MOVE.W    (A2)+,-(A7) 
  MOVE.W    (A3)+,-(A7) 
  MOVE.W    #$E420,-(A2)
  MOVE.W    #0,-(A3)
  LEA       L022D,A4			; this table is wierd.. no masks.. only 1 offset every 16 records.. 
  MOVE.W    #$7210,D0 
  LEA       L0246,A2			; 
  ADDA.W    D0,A2 
  PEA       L00AF 
  EXG       A7,D5 
  JMP       wipe_code 
L00AF:
  MOVE.W    (A7)+,-(A6) 
  MOVE.W    (A7)+,-(A5) 
  RTS 

;-------------------------------------------------------------------------------
; end of filler starting points
;-------------------------------------------------------------------------------

; some code generation..
L00B0:
  LEA       L023D,A2
  MOVEQ     #0,D4 
  MOVEQ     #$13,D7 
L00B1:
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00B2:
  MOVEA.L   A2,A0 
  MOVE.W    D4,D0 
  MOVE.W    D5,D1 
  BSR       L00DC 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00B2
  ADDQ.W    #1,D4 
  DBF       D7,L00B1
  MOVE.W    #$CB8F,(A2)+
  MOVE.W    #$4E75,(A2)+
  RTS 
L00B3:
  LEA       L0240,A2
  MOVEQ     #0,D4 
  MOVEQ     #$13,D7 
L00B4:
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00B5:
  MOVEA.L   A2,A0 
  MOVE.W    D4,D1 
  MOVE.W    D5,D0 
  BSR       L00DC 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00B5
  ADDQ.W    #1,D4 
  DBF       D7,L00B4
  MOVE.W    #$CB8F,(A2)+
  MOVE.W    #$4E75,(A2)+
  RTS 
L00B6:
  LEA       L0243,A2
  MOVEQ     #0,D4 
  MOVEQ     #$13,D7 
L00B7:
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00B8:
  MOVEA.L   A2,A0 
  MOVE.W    D4,D0 
  MOVE.W    D5,D1 
  BSR       L00E5 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00B8
  ADDQ.W    #1,D4 
  DBF       D7,L00B7
  MOVE.W    #$CB8F,(A2)+
  MOVE.W    #$4E75,(A2)+
  RTS 
L00B9:
  LEA       L0246,A2
  MOVEQ     #0,D4 
  MOVEQ     #$13,D7 
  MOVE.W    #0,D2 
L00BA:
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00BB:
  MOVEA.L   A2,A0 
  MOVE.W    D4,D0 
  MOVE.W    D5,D1 
  MOVE.W    D2,(A0)+
  BSR       L00F2 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00BB
  ADD.W     #$92,D2 
  ADDQ.W    #1,D4 
  DBF       D7,L00BA
  MOVE.W    #$CB8F,2(A2)
  MOVE.W    #$4E75,4(A2)
  RTS 

L00BC:
  LEA       some_span_code_table,A2
  MOVEQ     #0,D4 
  MOVEQ     #$13,D7 
L00BD:
  MOVE.W    D7,-(A7)
  MOVEQ     #0,D5 
  MOVEQ     #$12,D6 
  MOVE.W    #$8DF0,D2 
L00BE:
  MOVEA.L   A2,A0 
  MOVE.W    D4,D0 
  MOVE.W    D5,D1 
  MOVE.W    #$B68,D7
  BSR       L00D5 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  ADD.W     #$B68,D2
  DBF       D6,L00BE
  MOVEA.L   A2,A0 
  MOVE.W    D4,D0 
  MOVE.W    D5,D1 
  MOVE.W    #0,D7 
  BSR       L00D5 
  ADDA.W    #$92,A2 
  ADDQ.W    #1,D4 
  MOVE.W    (A7)+,D7
  DBF       D7,L00BD
  MOVE.W    #$CB8F,(A2)+
  MOVE.W    #$4E75,(A2) 
  RTS 

L00BF:
  TST.W     L020C 
  BNE.S     L00C0 
  MOVE.W    #$C681,L00F8
  BRA.S     L00C1 
L00C0:
  MOVE.W    #$8681,L00F8
L00C1:
  LEA       L0235,A2
  MOVEQ     #0,D2 
  MOVEQ     #0,D4 
  MOVEQ     #$13,D7 
L00C2:
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00C3:
  MOVEA.L   A2,A0 
  MOVE.W    D4,D0 
  MOVE.W    D5,D1 
  BSR       L00CD 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00C3
  ADDQ.W    #1,D4 
  DBF       D7,L00C2
  MOVE.W    #$CB8F,(A2)+
  MOVE.W    #$4E75,(A2) 
  RTS 

; moar k0dgenz
L00C4:
  LEA       L0238,A2
  MOVEQ     #0,D4 
  MOVEQ     #$12,D7 
  MOVEQ     #0,D2 
L00C5:
  MOVE.W    D7,-(A7)
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00C6:
  MOVEA.L   A2,A0 
  MOVE.W    D5,D0 
  MOVE.W    D4,D1 
  MOVE.W    #$92,D7 
  BSR       L00D5 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00C6
  ADDQ.W    #1,D4 
  ADD.W     #$92,D2 
  MOVE.W    (A7)+,D7
  DBF       D7,L00C5
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00C7:
  MOVEA.L   A2,A0 
  MOVE.W    D5,D0 
  MOVE.W    D4,D1 
  MOVE.W    #0,D7 
  BSR       L00D5 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00C7
  MOVE.W    #$CB8F,(A2)+
  MOVE.W    #$4E75,(A2) 
  RTS 
L00C8:
  TST.W     L020C 
  BNE.S     L00C9 
  MOVE.W    #$C681,L00FC
  BRA.S     L00CA 
L00C9:
  MOVE.W    #$8681,L00FC
L00CA:
  LEA       L023A,A2
  MOVEQ     #0,D4 
  MOVEQ     #$FFFFFFFF,D2 
  MOVEQ     #$13,D7 
L00CB:
  MOVEQ     #0,D5 
  MOVEQ     #$13,D6 
L00CC:
  MOVEA.L   A2,A0 
  MOVE.W    D5,D0 
  MOVE.W    D4,D1 
  BSR       L00CD 
  ADDA.W    #$92,A2 
  ADD.W     #1,D5 
  DBF       D6,L00CC
  ADDQ.W    #1,D4 
  DBF       D7,L00CB
  MOVE.W    #$CB8F,(A2)+
  MOVE.W    #$4E75,(A2) 
  RTS 
L00CD:
  MOVE.W    #$4843,(A0)+
  CMP.W     D1,D0 
  BGT.S     L00D0 
  SUB.W     D0,D1 
  LSL.W     #3,D0 
  TST.W     D1
  BEQ.S     L00CF 
  SUBQ.W    #1,D1 
  MOVE.W    #$3F46,D3 
L00CE:
  MOVE.W    D3,(A0)+
  MOVE.W    D0,(A0)+
  ADDQ.W    #8,D0 
  DBF       D1,L00CE
L00CF:
  MOVE.W    #$3F43,(A0)+
  MOVE.W    D0,(A0)+
  BRA.S     L00D2 
L00D0:
  SUB.W     D1,D0 
  LSL.W     #3,D1 
  MOVE.W    #$3F43,(A0)+
  MOVE.W    D1,(A0)+
  SUBQ.W    #1,D0 
  MOVE.W    #$3F47,D3 
L00D1:
  ADDQ.W    #8,D1 
  MOVE.W    D3,(A0)+
  MOVE.W    D1,(A0)+
  DBF       D0,L00D1
L00D2:
  TST.W     D2
  BEQ.S     L00D3 
  LEA       L00FA,A1
  MOVE.W    #$1C,D0 
  BRA.S     L00D4 
L00D3:
  LEA       L00F6,A1
  MOVE.W    #$1C,D0 
L00D4:
  MOVE.W    (A1)+,(A0)+ 
  DBF       D0,L00D4
  RTS 

L00D5:
  MOVE.W    #$4FEF,(A0)+
  MOVE.W    L0208,(A0)+ 
  CMP.W     D1,D0 
  BLE.S     L00D8 
  SUB.W     D1,D0 
  LSL.W     #3,D1 
  MOVE.W    #$4841,(A0)+
  MOVE.W    #$3F41,(A0)+
  MOVE.W    D1,(A0)+
  SUBQ.W    #1,D0 
  MOVE.W    #$3F46,D3 
L00D6:
  ADDQ.W    #8,D1 
  MOVE.W    D3,(A0)+
  MOVE.W    D1,(A0)+
  DBF       D0,L00D6
  LEA       L00FF,A1
  MOVE.W    #2,D0 
L00D7:
  MOVE.W    (A1)+,(A0)+ 
  DBF       D0,L00D7
  RTS 
L00D8:
  SUB.W     D0,D1 
  LSL.W     #3,D0 
  TST.W     D1
  BEQ.S     L00DA 
  SUBQ.W    #1,D1 
  MOVE.W    #$3F47,D3 
L00D9:
  MOVE.W    D3,(A0)+
  MOVE.W    D0,(A0)+
  ADDQ.W    #8,D0 
  DBF       D1,L00D9
L00DA:
  LEA       L00FE,A1
  MOVE.W    #$4841,(A0)+
  MOVE.W    #$3F41,(A0)+
  MOVE.W    D0,(A0)+
  MOVE.W    (A1)+,(A0)+ 
  ADDQ.L    #2,A1 
  MOVE.W    D2,(A0)+
  MOVE.W    (A1)+,(A0)+ 
  MOVE.W    #2,D0 
L00DB:
  MOVE.W    (A1)+,(A0)+ 
  DBF       D0,L00DB
  MOVE.W    (A1)+,(A0)+ 
  ADDQ.L    #2,A1 
  ADD.W     D2,D7 
  MOVE.W    D7,(A0)+
  MOVE.L    (A1)+,(A0)+ 
  RTS 
L00DC:
  CMP.W     D0,D1 
  BLE.S     L00DD 
  MOVE.W    #$32C0,(A0)+
  BRA.S     L00E3 
L00DD:
  MOVE.L    #$32F31002,(A0)+
  EXG       D1,D0 
  SUB.W     D0,D1 
  LSL.W     #3,D0 
  TST.W     D1
  BEQ.S     L00E0 
  MOVE.W    #$4840,(A0)+
  MOVE.W    #$3F40,(A0)+
  MOVE.W    D0,(A0)+
  SUBQ.W    #2,D1 
  BMI.S     L00DF 
  MOVE.W    #$3F46,D2 
L00DE:
  ADDQ.W    #8,D0 
  MOVE.W    D2,(A0)+
  MOVE.W    D0,(A0)+
  DBF       D1,L00DE
L00DF:
  ADDQ.W    #8,D0 
  MOVE.W    #$4842,(A0)+
  MOVE.W    #$3F42,(A0)+
  MOVE.W    D0,(A0)+
  BRA.S     L00E3 
L00E0:
  MOVE.W    #$4840,(A0)+
  MOVE.W    #$4842,(A0)+
  TST.W     L020C 
  BNE.S     L00E1 
  MOVE.W    #$C440,(A0)+
  BRA.S     L00E2 
L00E1:
  MOVE.W    #$8440,(A0)+
L00E2:
  MOVE.W    #$3F42,(A0)+
  MOVE.W    D0,(A0)+
L00E3:
  LEA       L0101,A1
  MOVE.W    #$B,D2
  MOVE.W    (A1)+,(A0)+ 
  MOVE.W    L0208,(A0)+ 
  ADDQ.L    #2,A1 
L00E4:
  MOVE.W    (A1)+,(A0)+ 
  DBF       D2,L00E4
  RTS 
L00E5:
  CMP.W     D0,D1 
  BLE.S     L00E6 
  MOVE.W    #$32C0,(A0)+
  BRA.S     L00E3 
L00E6:
  MOVE.L    #$32F31002,(A0)+
  EXG       D1,D0 
  SUB.W     D0,D1 
  LSL.W     #3,D0 
  TST.W     D1
  BEQ.S     L00ED 
  MOVE.W    #$4840,(A0)+
  TST.W     L020C 
  BNE.S     L00E7 
  MOVE.W    #$816F,(A0)+
  BRA.S     L00E8 
L00E7:
  MOVE.W    #$C16F,(A0)+
L00E8:
  MOVE.W    D0,(A0)+
  SUBQ.W    #2,D1 
  BMI.S     L00EA 
  MOVE.W    #$3F46,D2 
L00E9:
  ADDQ.W    #8,D0 
  MOVE.W    D2,(A0)+
  MOVE.W    D0,(A0)+
  DBF       D1,L00E9
L00EA:
  ADDQ.W    #8,D0 
  MOVE.W    #$4842,(A0)+
  TST.W     L020C 
  BNE.S     L00EB 
  MOVE.W    #$856F,(A0)+
  BRA.S     L00EC 
L00EB:
  MOVE.W    #$C56F,(A0)+
L00EC:
  MOVE.W    D0,(A0)+
  BRA.S     L00F0 
L00ED:
  MOVE.W    #$4840,(A0)+
  MOVE.W    #$4842,(A0)+
  TST.W     L020C 
  BNE.S     L00EE 
  MOVE.W    #$C440,(A0)+
  MOVE.W    #$856F,(A0)+
  BRA.S     L00EF 
L00EE:
  MOVE.W    #$8440,(A0)+
  MOVE.W    #$C56F,(A0)+
L00EF:
  MOVE.W    D0,(A0)+
L00F0:
  LEA       L0101,A1
  MOVE.W    #$B,D2
  MOVE.W    (A1)+,(A0)+ 
  MOVE.W    L0208,(A0)+ 
  ADDQ.L    #2,A1 
L00F1:
  MOVE.W    (A1)+,(A0)+ 
  DBF       D2,L00F1
  RTS 
L00F2:
  CMP.W     D0,D1 
  BGT.S     L00F3 
  EXG       D1,D0 
L00F3:
  SUB.W     D0,D1 
  LSL.W     #3,D0 
  MOVE.W    #$3F47,D3 
L00F4:
  MOVE.W    D3,(A0)+
  MOVE.W    D0,(A0)+
  ADDQ.W    #8,D0 
  DBF       D1,L00F4
  LEA       L0102,A1
  MOVE.W    #6,D0 
  MOVE.W    (A1)+,(A0)+ 
  MOVE.W    L0208,(A0)+ 
  ADDQ.L    #2,A1 
L00F5:
  MOVE.W    (A1)+,(A0)+ 
  DBF       D0,L00F5
  RTS 
L00F6:
  MOVE.W    (A5)+,D0
  MOVE.W    (A0),D1 
  AND.W     D4,D1 
  MOVE.L    0(A4,D1.W),D1 
  MOVE.W    D1,(A0)+
  MOVE.W    (A6)+,D2
  MOVE.W    (A1),D3 
  AND.W     D4,D3 
  MOVE.L    4(A4,D3.W),D3 
  ADD.W     D1,D0 
  CMP.W     D1,D3 
  BLE.S     L00F7 
  MOVE.W    D3,(A1)+
  JMP       0(A2,D0.W)
L00F7:
  BLT.S     L00F9 
L00F8:
  OR.L      D1,D3 
  MOVE.W    D3,(A1)+
  JMP       0(A2,D0.W)
L00F9:
  SWAP      D1
  MOVE.W    D7,D1 
  SWAP      D1
  MOVE.L    D1,D3 
  MOVE.W    D3,(A1)+
  JMP       0(A2,D0.W)
L00FA:
  MOVE.W    (A5)+,D0
  MOVE.W    (A0),D1 
  AND.W     D4,D1 
  MOVE.L    4(A4,D1.W),D1 
  MOVE.W    D1,(A0)+
  MOVE.W    (A6)+,D2
  MOVE.W    (A1),D3 
  AND.W     D4,D3 
  MOVE.L    0(A4,D3.W),D3 
  ADD.W     D1,D0 
  CMP.W     D1,D3 
  BLE.S     L00FB 
  MOVE.W    D3,(A1)+
  JMP       0(A2,D0.W)
L00FB:
  BLT.S     L00FD 
L00FC:
  OR.L      D1,D3 
  MOVE.W    D3,(A1)+
  JMP       0(A2,D0.W)
L00FD:
  SWAP      D1
  MOVE.W    D7,D1 
  SWAP      D1
  MOVE.L    D1,D3 
  MOVE.W    D3,(A1)+
  JMP       0(A2,D0.W)
L00FE:
  CMP.W     #0,D2 
  BLE.S     L0100 
L00FF:
  ADD.W     D2,D3 
  JMP       0(A3,D3.W)
L0100:
  ADD.W     #0,D3 
  JMP       0(A3,D3.W)
L0101:
  LEA       160(A7),A7
  MOVE.W    (A0),D0 
  AND.W     D4,D0 
  MOVE.L    0(A3,D0.W),D0 
  MOVE.W    D0,(A0)+
  MOVE.W    (A1),D1 
  AND.W     D4,D1 
  MOVE.L    0(A4,D1.W),D2 
  ADD.W     D0,D2 
  JMP       0(A2,D2.W)
L0102:
  LEA       160(A7),A7
  MOVE.W    (A5)+,D0
  MOVE.W    (A6)+,D1
  MOVE.W    0(A4,D1.W),D1 
  ADD.W     D0,D1 
  JMP       2(A2,D1.W)
L0103:
  MOVE.W    L020B,D6
  MOVE.W    L020A,D7
  LEA       L0227,A0
  MOVE.W    D7,D0 
  SWAP      D0
  CLR.W     D0
  MOVE.W    D6,D1 
  SWAP      D1
  CLR.W     D1
  BSR       L0113 
  LEA       L0115,A1
  LEA       L0116,A2
  MOVE.W    #0,D2 
  MOVE.W    #0,D3 
  MOVEQ     #$13,D1 
L0104:
  MOVEA.L   A1,A3 
  MOVEA.L   A2,A4 
  MOVEQ     #$F,D0
L0105:
  MOVE.W    (A3)+,D5
  MOVE.W    D5,D4 
  NOT.W     D4
  AND.W     D7,D5 
  AND.W     D6,D4 
  OR.W      D4,D5 
  MOVE.W    D5,(A0)+
  MOVE.W    D2,(A0)+
  MOVE.W    (A4)+,D5
  MOVE.W    D5,D4 
  NOT.W     D4
  AND.W     D7,D5 
  AND.W     D6,D4 
  OR.W      D4,D5 
  MOVE.W    D5,(A0)+
  MOVE.W    D3,(A0)+
  DBF       D0,L0105
  ADD.W     #$92,D2 
  ADD.W     #$92,D3 
  DBF       D1,L0104
  MOVE.W    D6,D0 
  SWAP      D0
  MOVE.W    #$AD6,D0
  MOVE.W    D7,D1 
  SWAP      D1
  MOVE.W    #$AD6,D1
  BSR       L0113 
  RTS 
L0106:
  MOVE.W    L020B,D6
  MOVE.W    L020A,D7
  LEA       L022A,A0
  MOVE.W    D6,D0 
  SWAP      D0
  MOVE.W    #$8DF0,D0 
  MOVE.W    D7,D1 
  SWAP      D1
  MOVE.W    #$8DF0,D1 
  BSR       L0113 
  LEA       L0115,A1
  LEA       L0116,A2
  MOVE.W    #$8DF0,D2 
  MOVE.W    #$8DF0,D3 
  MOVEQ     #$13,D1 
L0107:
  MOVEA.L   A1,A3 
  MOVEA.L   A2,A4 
  MOVEQ     #$F,D0
L0108:
  MOVE.W    (A4)+,D5
  MOVE.W    D5,D4 
  NOT.W     D4
  AND.W     D7,D5 
  AND.W     D6,D4 
  OR.W      D4,D5 
  MOVE.W    D5,(A0)+
  MOVE.W    D2,(A0)+
  MOVE.W    (A3)+,D5
  MOVE.W    D5,D4 
  NOT.W     D4
  AND.W     D7,D5 
  AND.W     D6,D4 
  OR.W      D4,D5 
  MOVE.W    D5,(A0)+
  MOVE.W    D3,(A0)+
  DBF       D0,L0108
  ADD.W     #$B68,D2
  ADD.W     #$B68,D3
  DBF       D1,L0107
  MOVE.W    D7,D0 
  SWAP      D0
  MOVE.W    #$66A8,D0 
  MOVE.W    D6,D1 
  SWAP      D1
  MOVE.W    #$66A8,D1 
  BSR       L0113 
  MOVE.W    #$7210,D2 
  CLR.W     (A0)+ 
  MOVE.W    D2,(A0)+
  CLR.W     (A0)+ 
  MOVE.W    D2,(A0)+
  RTS 
L0109:
  LEA       L022D,A0
  MOVE.W    #$13,D0 
  MOVE.W    #$8DF0,D1 
L010A:
  MOVE.W    D1,(A0) 
  ADDA.W    #$92,A0 
  ADD.W     #$B68,D1
  DBF       D0,L010A
  RTS 
L010B:
  LEA       L022E,A0
  MOVE.W    #$C7,D0 
  MOVEQ     #0,D1 
L010C:
  MOVE.W    D1,(A0)+
  ADD.W     #$A0,D1 
  DBF       D0,L010C
  RTS 
L010D:
  LEA       L022F,A0
  MOVE.W    #$C7,D0 
  MOVEQ     #0,D1 
L010E:
  MOVE.W    D1,(A0)+
  ADD.W     #$140,D1
  DBF       D0,L010E
  RTS 

L010F:
  LEA       L0231,A0
  MOVE.W    #$C8,D0 
  MOVE.W    #$7D0,D1
  MOVEQ     #$A,D2
L0110:
  MOVE.W    D1,-(A0)
  SUB.W     D2,D1 
  DBF       D0,L0110
  RTS 

gen_mul6_lut:
  LEA       mul6_lut_end,A0
  MOVE.W    #$C8,D0 
  MOVE.W    #$4B0,D1
  MOVEQ     #6,D2 
.loop:
  MOVE.W    D1,-(A0)
  SUB.W     D2,D1 
  DBF       D0,.loop
  RTS 

L0113:
  MOVE.W    #$3E7,D2
L0114:
  MOVE.L    D0,(A0)+
  MOVE.L    D1,(A0)+
  DBF       D2,L0114
  RTS 

 DATA 
L0115:
  DC.B      $FF,$FF,$7F,$FF,'?',$FF,$1F,$FF 
  DC.B      $0F,$FF,$07,$FF,$03,$FF,$01,$FF 
  DC.B      $00,$FF,$00,$7F,$00,'?',$00,$1F 
  DC.B      $00,$0F,$00,$07,$00,$03,$00,$01 
L0116:
  DC.B      $80,$00,$C0,$00,$E0,$00,$F0,$00 
  DC.B      $F8,$00,$FC,$00,$FE,$00,$FF,$00 
  DC.B      $FF,$80,$FF,$C0,$FF,$E0,$FF,$F0 
  DC.B      $FF,$F8,$FF,$FC,$FF,$FE,$FF,$FF 
L0117:
  DC.B      $00,$00,$1F,$FF,$00,$1A,$1F,$FE 
  DC.B      $00,'5',$1F,$FE,$00,'G',$1F,$FE 
  DC.B      $00,'b',$1F,$FE,$00,'}',$1F,$FD 
  DC.B      $00,$97,$1F,$FD,$00,$B2,$1F,$FC 
  DC.B      $00,$CD,$1F,$FC,$00,$DF,$1F,$FB 
  DC.B      $00,$FA,$1F,$FA,$01,$14,$1F,$FA 
  DC.B      $01,'/',$1F,$F9,$01,'J',$1F,$F8 
  DC.B      $01,'\',$1F,$F7,$01,'w',$1F,$F6 
  DC.B      $01,$91,$1F,$F4,$01,$AC,$1F,$F3 
  DC.B      $01,$C7,$1F,$F2,$01,$D9,$1F,$F1 
  DC.B      $01,$F4,$1F,$EF,$02,$0E,$1F,$ED 
  DC.B      $02,')',$1F,$EC,$02,'D',$1F,$EA 
  DC.B      $02,'_',$1F,$E8,$02,'p',$1F,$E6 
  DC.B      $02,$8B,$1F,$E4,$02,$A6,$1F,$E2 
  DC.B      $02,$C0,$1F,$E0,$02,$DB,$1F,$DE 
  DC.B      $02,$ED,$1F,$DC,$03,$08,$1F,$D9 
  DC.B      $03,'"',$1F,$D7,$03,'=',$1F,$D4 
  DC.B      $03,'X',$1F,$D2,$03,'i',$1F,$D0 
  DC.B      $03,$84,$1F,$CD,$03,$9F,$1F,$CA 
  DC.B      $03,$B9,$1F,$C7,$03,$D4,$1F,$C3 
  DC.B      $03,$EF,$1F,$C0,$04,$00,$1F,$BE 
  DC.B      $04,$1B,$1F,$BA,$04,'5',$1F,$B7 
  DC.B      $04,'P',$1F,$B3,$04,'k',$1F,$B0 
  DC.B      $04,'|',$1F,$AD,$04,$97,$1F,$AA 
  DC.B      $04,$B1,$1F,$A6,$04,$CC,$1F,$A2 
  DC.B      $04,$E6,$1F,$9E,$04,$F8,$1F,$9B 
  DC.B      $05,$12,$1F,$97,$05,'-',$1F,$92 
  DC.B      $05,'G',$1F,$8E,$05,'b',$1F,$89 
  DC.B      $05,'|',$1F,$85,$05,$8E,$1F,$82 
  DC.B      $05,$A8,$1F,'}',$05,$C3,$1F,'x' 
  DC.B      $05,$DD,$1F,'s',$05,$F7,$1F,'o' 
  DC.B      $06,$09,$1F,'k',$06,'#',$1F,'f' 
  DC.B      $06,'=',$1F,'a',$06,'X',$1F,'\' 
  DC.B      $06,'r',$1F,'V',$06,$83,$1F,'S' 
  DC.B      $06,$9E,$1F,'M',$06,$B8,$1F,'H' 
  DC.B      $06,$D2,$1F,'B',$06,$EC,$1F,'<' 
  DC.B      $07,$06,$1F,'6',$07,$18,$1F,'2' 
  DC.B      $07,'2',$1F,'-',$07,'L',$1F,'&' 
  DC.B      $07,'f',$1F,' ',$07,$80,$1F,$1A 
  DC.B      $07,$92,$1F,$16,$07,$AC,$1F,$0F 
  DC.B      $07,$C6,$1F,$09,$07,$E0,$1F,$02 
  DC.B      $07,$FA,$1E,$FC,$08,$0B,$1E,$F7 
  DC.B      $08,'%',$1E,$F0,$08,'?',$1E,$EA 
  DC.B      $08,'Y',$1E,$E3,$08,'s',$1E,$DB 
  DC.B      $08,$8C,$1E,$D4,$08,$9E,$1E,$D0 
  DC.B      $08,$B7,$1E,$C8,$08,$D1,$1E,$C1 
  DC.B      $08,$EB,$1E,$BA,$09,$05,$1E,$B2 
  DC.B      $09,$16,$1E,$AD,$09,'/',$1E,$A5 
  DC.B      $09,'I',$1E,$9E,$09,'c',$1E,$96 
  DC.B      $09,'|',$1E,$8E,$09,$8D,$1E,$88 
  DC.B      $09,$A7,$1E,$80,$09,$C1,$1E,'x' 
  DC.B      $09,$DA,$1E,'p',$09,$F4,$1E,'h' 
  DC.B      $0A,$0D,$1E,'_',$0A,$1E,$1E,'Z' 
  DC.B      $0A,'7',$1E,'Q',$0A,'Q',$1E,'I' 
  DC.B      $0A,'j',$1E,'@',$0A,$83,$1E,'7' 
  DC.B      $0A,$94,$1E,'1',$0A,$AE,$1E,'(' 
  DC.B      $0A,$C7,$1E,$1F,$0A,$E0,$1E,$16 
  DC.B      $0A,$F9,$1E,$0D,$0B,$0A,$1E,$07 
  DC.B      $0B,'#',$1D,$FE,$0B,'<',$1D,$F4 
  DC.B      $0B,'U',$1D,$EB,$0B,'o',$1D,$E2 
  DC.B      $0B,$88,$1D,$D8,$0B,$98,$1D,$D1 
  DC.B      $0B,$B1,$1D,$C8,$0B,$CA,$1D,$BE 
  DC.B      $0B,$E3,$1D,$B4,$0B,$FC,$1D,$AA 
  DC.B      $0C,$0C,$1D,$A3,$0C,'%',$1D,$99 
  DC.B      $0C,'>',$1D,$8F,$0C,'W',$1D,$84 
  DC.B      $0C,'o',$1D,'z',$0C,$80,$1D,'s' 
  DC.B      $0C,$99,$1D,'i',$0C,$B1,$1D,'^' 
  DC.B      $0C,$CA,$1D,'S',$0C,$E2,$1D,'I' 
  DC.B      $0C,$FB,$1D,'>',$0D,$0B,$1D,'7' 
  DC.B      $0D,'$',$1D,',',$0D,'<',$1D,' ' 
  DC.B      $0D,'T',$1D,$15,$0D,'m',$1D,$0A 
  DC.B      $0D,'}',$1D,$03,$0D,$95,$1C,$F7 
  DC.B      $0D,$AD,$1C,$EC,$0D,$C6,$1C,$E0 
  DC.B      $0D,$DE,$1C,$D5,$0D,$EE,$1C,$CD 
  DC.B      $0E,$06,$1C,$C2,$0E,$1E,$1C,$B6 
  DC.B      $0E,'6',$1C,$AA,$0E,'N',$1C,$9E 
  DC.B      $0E,'f',$1C,$92,$0E,'v',$1C,$8A 
  DC.B      $0E,$8E,$1C,'~',$0E,$A6,$1C,'q' 
  DC.B      $0E,$BE,$1C,'e',$0E,$D5,$1C,'X' 
  DC.B      $0E,$E5,$1C,'P',$0E,$FD,$1C,'D' 
  DC.B      $0F,$15,$1C,'7',$0F,',',$1C,'*' 
  DC.B      $0F,'D',$1C,$1E,$0F,'S',$1C,$15 
  DC.B      $0F,'k',$1C,$08,$0F,$83,$1B,$FC 
  DC.B      $0F,$9A,$1B,$EE,$0F,$B1,$1B,$E1 
  DC.B      $0F,$C9,$1B,$D4,$0F,$D8,$1B,$CB 
  DC.B      $0F,$EF,$1B,$BE,$10,$07,$1B,$B1 
  DC.B      $10,$1E,$1B,$A3,$10,'5',$1B,$95 
  DC.B      $10,'D',$1B,$8C,$10,'[',$1B,$7F 
  DC.B      $10,'r',$1B,'q',$10,$89,$1B,'c' 
  DC.B      $10,$A0,$1B,'U',$10,$B0,$1B,'L' 
  DC.B      $10,$C6,$1B,'>',$10,$DD,$1B,'0' 
  DC.B      $10,$F4,$1B,'"',$11,$0B,$1B,$13 
  DC.B      $11,'!',$1B,$05,$11,'0',$1A,$FB 
  DC.B      $11,'G',$1A,$ED,$11,'^',$1A,$DF 
  DC.B      $11,'t',$1A,$D0,$11,$8A,$1A,$C1 
  DC.B      $11,$99,$1A,$B7,$11,$B0,$1A,$A9 
  DC.B      $11,$C6,$1A,$9A,$11,$DC,$1A,$8B 
  DC.B      $11,$F3,$1A,'|',$12,$01,$1A,'r' 
  DC.B      $12,$17,$1A,'c',$12,'-',$1A,'T' 
  DC.B      $12,'D',$1A,'D',$12,'Z',$1A,'5' 
  DC.B      $12,'o',$1A,'&',$12,'~',$1A,$1B 
  DC.B      $12,$94,$1A,$0C,$12,$AA,$19,$FC 
  DC.B      $12,$C0,$19,$ED,$12,$D5,$19,$DD 
  DC.B      $12,$E4,$19,$D2,$12,$F9,$19,$C2 
  DC.B      $13,$0F,$19,$B2,$13,'$',$19,$A2 
  DC.B      $13,':',$19,$92,$13,'H',$19,$88 
  DC.B      $13,']',$19,'w',$13,'s',$19,'g' 
  DC.B      $13,$88,$19,'W',$13,$9D,$19,'F' 
  DC.B      $13,$B2,$19,'6',$13,$C0,$19,'+' 
  DC.B      $13,$D5,$19,$1A,$13,$EA,$19,$0A 
  DC.B      $13,$FF,$18,$F9,$14,$14,$18,$E8 
  DC.B      $14,'"',$18,$DD,$14,'7',$18,$CC 
  DC.B      $14,'L',$18,$BB,$14,'`',$18,$AA 
  DC.B      $14,'u',$18,$99,$14,$83,$18,$8E 
  DC.B      $14,$97,$18,'|',$14,$AC,$18,'k' 
  DC.B      $14,$C0,$18,'Z',$14,$D5,$18,'H' 
  DC.B      $14,$E9,$18,'7',$14,$F6,$18,'+' 
  DC.B      $15,$0B,$18,$19,$15,$1F,$18,$08 
  DC.B      $15,'3',$17,$F6,$15,'G',$17,$E4 
  DC.B      $15,'T',$17,$D8,$15,'h',$17,$C7 
  DC.B      $15,'|',$17,$B4,$15,$90,$17,$A2 
  DC.B      $15,$A4,$17,$90,$15,$B1,$17,$84 
  DC.B      $15,$C5,$17,'r',$15,$D8,$17,'`' 
  DC.B      $15,$EC,$17,'M',$15,$FF,$17,';' 
  DC.B      $16,$13,$17,')',$16,' ',$17,$1C 
  DC.B      $16,'3',$17,$0A,$16,'F',$16,$F7 
  DC.B      $16,'Y',$16,$E4,$16,'l',$16,$D2 
  DC.B      $16,'y',$16,$C5,$16,$8C,$16,$B2 
  DC.B      $16,$9F,$16,$9F,$16,$B2,$16,$8C 
  DC.B      $16,$C5,$16,'y',$16,$D2,$16,'l' 
  DC.B      $16,$E4,$16,'Y',$16,$F7,$16,'F' 
  DC.B      $17,$0A,$16,'3',$17,$1C,$16,' ' 
  DC.B      $17,'/',$16,$0C,$17,';',$15,$FF 
  DC.B      $17,'M',$15,$EC,$17,'`',$15,$D8 
  DC.B      $17,'r',$15,$C5,$17,$84,$15,$B1 
  DC.B      $17,$90,$15,$A4,$17,$A2,$15,$90 
  DC.B      $17,$B4,$15,'|',$17,$C7,$15,'h' 
  DC.B      $17,$D8,$15,'T',$17,$E4,$15,'G' 
  DC.B      $17,$F6,$15,'3',$18,$08,$15,$1F 
  DC.B      $18,$19,$15,$0B,$18,'+',$14,$F6 
  DC.B      $18,'=',$14,$E2,$18,'H',$14,$D5 
  DC.B      $18,'Z',$14,$C0,$18,'k',$14,$AC 
  DC.B      $18,'|',$14,$97,$18,$8E,$14,$83 
  DC.B      $18,$99,$14,'u',$18,$AA,$14,'`' 
  DC.B      $18,$BB,$14,'L',$18,$CC,$14,'7' 
  DC.B      $18,$DD,$14,'"',$18,$E8,$14,$14 
  DC.B      $18,$F9,$13,$FF,$19,$0A,$13,$EA 
  DC.B      $19,$1A,$13,$D5,$19,'+',$13,$C0 
  DC.B      $19,'<',$13,$AB,$19,'F',$13,$9D 
  DC.B      $19,'W',$13,$88,$19,'g',$13,'s' 
  DC.B      $19,'w',$13,']',$19,$88,$13,'H' 
  DC.B      $19,$92,$13,':',$19,$A2,$13,'$' 
  DC.B      $19,$B2,$13,$0F,$19,$C2,$12,$F9 
  DC.B      $19,$D2,$12,$E4,$19,$DD,$12,$D5 
  DC.B      $19,$ED,$12,$C0,$19,$FC,$12,$AA 
  DC.B      $1A,$0C,$12,$94,$1A,$1B,$12,'~' 
  DC.B      $1A,'+',$12,'h',$1A,'5',$12,'Z' 
  DC.B      $1A,'D',$12,'D',$1A,'T',$12,'-' 
  DC.B      $1A,'c',$12,$17,$1A,'r',$12,$01 
  DC.B      $1A,'|',$11,$F3,$1A,$8B,$11,$DC 
  DC.B      $1A,$9A,$11,$C6,$1A,$A9,$11,$B0 
  DC.B      $1A,$B7,$11,$99,$1A,$C1,$11,$8A 
  DC.B      $1A,$D0,$11,'t',$1A,$DF,$11,'^' 
  DC.B      $1A,$ED,$11,'G',$1A,$FB,$11,'0' 
  DC.B      $1B,$0A,$11,$1A,$1B,$13,$11,$0B 
  DC.B      $1B,'"',$10,$F4,$1B,'0',$10,$DD 
  DC.B      $1B,'>',$10,$C6,$1B,'L',$10,$B0 
  DC.B      $1B,'U',$10,$A0,$1B,'c',$10,$89 
  DC.B      $1B,'q',$10,'r',$1B,$7F,$10,'[' 
  DC.B      $1B,$8C,$10,'D',$1B,$95,$10,'5' 
  DC.B      $1B,$A3,$10,$1E,$1B,$B1,$10,$07 
  DC.B      $1B,$BE,$0F,$EF,$1B,$CB,$0F,$D8 
  DC.B      $1B,$D8,$0F,$C1,$1B,$E1,$0F,$B1 
  DC.B      $1B,$EE,$0F,$9A,$1B,$FC,$0F,$83 
  DC.B      $1C,$08,$0F,'k',$1C,$15,$0F,'S' 
  DC.B      $1C,$1E,$0F,'D',$1C,'*',$0F,',' 
  DC.B      $1C,'7',$0F,$15,$1C,'D',$0E,$FD 
  DC.B      $1C,'P',$0E,$E5,$1C,'X',$0E,$D5 
  DC.B      $1C,'e',$0E,$BE,$1C,'q',$0E,$A6 
  DC.B      $1C,'~',$0E,$8E,$1C,$8A,$0E,'v' 
  DC.B      $1C,$96,$0E,'^',$1C,$9E,$0E,'N' 
  DC.B      $1C,$AA,$0E,'6',$1C,$B6,$0E,$1E 
  DC.B      $1C,$C2,$0E,$06,$1C,$CD,$0D,$EE 
  DC.B      $1C,$D5,$0D,$DE,$1C,$E0,$0D,$C6 
  DC.B      $1C,$EC,$0D,$AD,$1C,$F7,$0D,$95 
  DC.B      $1D,$03,$0D,'}',$1D,$0A,$0D,'m' 
  DC.B      $1D,$15,$0D,'T',$1D,' ',$0D,'<' 
  DC.B      $1D,',',$0D,'$',$1D,'7',$0D,$0B 
  DC.B      $1D,'A',$0C,$F3,$1D,'I',$0C,$E2 
  DC.B      $1D,'S',$0C,$CA,$1D,'^',$0C,$B1 
  DC.B      $1D,'i',$0C,$99,$1D,'s',$0C,$80 
  DC.B      $1D,'z',$0C,'o',$1D,$84,$0C,'W' 
  DC.B      $1D,$8F,$0C,'>',$1D,$99,$0C,'%' 
  DC.B      $1D,$A3,$0C,$0C,$1D,$AA,$0B,$FC 
  DC.B      $1D,$B4,$0B,$E3,$1D,$BE,$0B,$CA 
  DC.B      $1D,$C8,$0B,$B1,$1D,$D1,$0B,$98 
  DC.B      $1D,$DB,$0B,$7F,$1D,$E2,$0B,'o' 
  DC.B      $1D,$EB,$0B,'U',$1D,$F4,$0B,'<' 
  DC.B      $1D,$FE,$0B,'#',$1E,$07,$0B,$0A 
  DC.B      $1E,$0D,$0A,$F9,$1E,$16,$0A,$E0 
  DC.B      $1E,$1F,$0A,$C7,$1E,'(',$0A,$AE 
  DC.B      $1E,'1',$0A,$94,$1E,'7',$0A,$83 
  DC.B      $1E,'@',$0A,'j',$1E,'I',$0A,'Q' 
  DC.B      $1E,'Q',$0A,'7',$1E,'Z',$0A,$1E 
  DC.B      $1E,'b',$0A,$05,$1E,'h',$09,$F4 
  DC.B      $1E,'p',$09,$DA,$1E,'x',$09,$C1 
  DC.B      $1E,$80,$09,$A7,$1E,$88,$09,$8D 
  DC.B      $1E,$8E,$09,'|',$1E,$96,$09,'c' 
  DC.B      $1E,$9E,$09,'I',$1E,$A5,$09,'/' 
  DC.B      $1E,$AD,$09,$16,$1E,$B2,$09,$05 
  DC.B      $1E,$BA,$08,$EB,$1E,$C1,$08,$D1 
  DC.B      $1E,$C8,$08,$B7,$1E,$D0,$08,$9E 
  DC.B      $1E,$D7,$08,$84,$1E,$DB,$08,'s' 
  DC.B      $1E,$E3,$08,'Y',$1E,$EA,$08,'?' 
  DC.B      $1E,$F0,$08,'%',$1E,$F7,$08,$0B 
  DC.B      $1E,$FC,$07,$FA,$1F,$02,$07,$E0 
  DC.B      $1F,$09,$07,$C6,$1F,$0F,$07,$AC 
  DC.B      $1F,$16,$07,$92,$1F,$1A,$07,$80 
  DC.B      $1F,' ',$07,'f',$1F,'&',$07,'L' 
  DC.B      $1F,'-',$07,'2',$1F,'2',$07,$18 
  DC.B      $1F,'8',$06,$FE,$1F,'<',$06,$EC 
  DC.B      $1F,'B',$06,$D2,$1F,'H',$06,$B8 
  DC.B      $1F,'M',$06,$9E,$1F,'S',$06,$83 
  DC.B      $1F,'V',$06,'r',$1F,'\',$06,'X' 
  DC.B      $1F,'a',$06,'=',$1F,'f',$06,'#' 
  DC.B      $1F,'k',$06,$09,$1F,'o',$05,$F7 
  DC.B      $1F,'s',$05,$DD,$1F,'x',$05,$C3 
  DC.B      $1F,'}',$05,$A8,$1F,$82,$05,$8E 
  DC.B      $1F,$86,$05,'s',$1F,$89,$05,'b' 
  DC.B      $1F,$8E,$05,'G',$1F,$92,$05,'-' 
  DC.B      $1F,$97,$05,$12,$1F,$9B,$04,$F8 
  DC.B      $1F,$9E,$04,$E6,$1F,$A2,$04,$CC 
  DC.B      $1F,$A6,$04,$B1,$1F,$AA,$04,$97 
  DC.B      $1F,$AD,$04,'|',$1F,$B0,$04,'k' 
  DC.B      $1F,$B3,$04,'P',$1F,$B7,$04,'5' 
  DC.B      $1F,$BA,$04,$1B,$1F,$BE,$04,$00 
  DC.B      $1F,$C1,$03,$E6,$1F,$C3,$03,$D4 
  DC.B      $1F,$C7,$03,$B9,$1F,$CA,$03,$9F 
  DC.B      $1F,$CD,$03,$84,$1F,$D0,$03,'i' 
  DC.B      $1F,$D2,$03,'X',$1F,$D4,$03,'=' 
  DC.B      $1F,$D7,$03,'"',$1F,$D9,$03,$08 
  DC.B      $1F,$DC,$02,$ED,$1F,$DE,$02,$DB 
  DC.B      $1F,$E0,$02,$C0,$1F,$E2,$02,$A6 
  DC.B      $1F,$E4,$02,$8B,$1F,$E6,$02,'p' 
  DC.B      $1F,$E8,$02,'V',$1F,$EA,$02,'D' 
  DC.B      $1F,$EC,$02,')',$1F,$ED,$02,$0E 
  DC.B      $1F,$EF,$01,$F4,$1F,$F1,$01,$D9 
  DC.B      $1F,$F2,$01,$C7,$1F,$F3,$01,$AC 
  DC.B      $1F,$F4,$01,$91,$1F,$F6,$01,'w' 
  DC.B      $1F,$F7,$01,'\',$1F,$F8,$01,'J' 
  DC.B      $1F,$F9,$01,'/',$1F,$FA,$01,$14 
  DC.B      $1F,$FA,$00,$FA,$1F,$FB,$00,$DF 
  DC.B      $1F,$FC,$00,$C4,$1F,$FC,$00,$B2 
  DC.B      $1F,$FD,$00,$97,$1F,$FD,$00,'}' 
  DC.B      $1F,$FE,$00,'b',$1F,$FE,$00,'G' 
  DC.B      $1F,$FE,$00,'5',$1F,$FE,$00,$1A 
  DC.B      $1F,$FF,$00,$00,$1F,$FE,$FF,$E6 
  DC.B      $1F,$FE,$FF,$CB,$1F,$FE,$FF,$B9 
  DC.B      $1F,$FE,$FF,$9E,$1F,$FD,$FF,$83 
  DC.B      $1F,$FD,$FF,'i',$1F,$FC,$FF,'N' 
  DC.B      $1F,$FC,$FF,'3',$1F,$FB,$FF,'!' 
  DC.B      $1F,$FA,$FF,$06,$1F,$FA,$FE,$EC 
  DC.B      $1F,$F9,$FE,$D1,$1F,$F8,$FE,$B6 
  DC.B      $1F,$F7,$FE,$A4,$1F,$F6,$FE,$89 
  DC.B      $1F,$F4,$FE,'o',$1F,$F3,$FE,'T' 
  DC.B      $1F,$F2,$FE,'9',$1F,$F1,$FE,$27 
  DC.B      $1F,$EF,$FE,$0C,$1F,$ED,$FD,$F2 
  DC.B      $1F,$EC,$FD,$D7,$1F,$EA,$FD,$BC 
  DC.B      $1F,$E8,$FD,$A1,$1F,$E6,$FD,$90 
  DC.B      $1F,$E4,$FD,'u',$1F,$E2,$FD,'Z' 
  DC.B      $1F,$E0,$FD,'@',$1F,$DE,$FD,'%' 
  DC.B      $1F,$DC,$FD,$13,$1F,$D9,$FC,$F8 
  DC.B      $1F,$D7,$FC,$DE,$1F,$D4,$FC,$C3 
  DC.B      $1F,$D2,$FC,$A8,$1F,$D0,$FC,$97 
  DC.B      $1F,$CD,$FC,'|',$1F,$CA,$FC,'a' 
  DC.B      $1F,$C7,$FC,'G',$1F,$C3,$FC,',' 
  DC.B      $1F,$C0,$FC,$11,$1F,$BE,$FC,$00 
  DC.B      $1F,$BA,$FB,$E5,$1F,$B7,$FB,$CB 
  DC.B      $1F,$B3,$FB,$B0,$1F,$B0,$FB,$95 
  DC.B      $1F,$AD,$FB,$84,$1F,$AA,$FB,'i' 
  DC.B      $1F,$A6,$FB,'O',$1F,$A2,$FB,'4' 
  DC.B      $1F,$9E,$FB,$1A,$1F,$9B,$FB,$08 
  DC.B      $1F,$97,$FA,$EE,$1F,$92,$FA,$D3 
  DC.B      $1F,$8E,$FA,$B9,$1F,$89,$FA,$9E 
  DC.B      $1F,$85,$FA,$84,$1F,$82,$FA,'r' 
  DC.B      $1F,'}',$FA,'X',$1F,'x',$FA,'=' 
  DC.B      $1F,'s',$FA,'#',$1F,'o',$FA,$09 
  DC.B      $1F,'k',$F9,$F7,$1F,'f',$F9,$DD 
  DC.B      $1F,'a',$F9,$C3,$1F,'\',$F9,$A8 
  DC.B      $1F,'V',$F9,$8E,$1F,'S',$F9,'}' 
  DC.B      $1F,'M',$F9,'b',$1F,'H',$F9,'H' 
  DC.B      $1F,'B',$F9,'.',$1F,'<',$F9,$14 
  DC.B      $1F,'6',$F8,$FA,$1F,'2',$F8,$E8 
  DC.B      $1F,'-',$F8,$CE,$1F,'&',$F8,$B4 
  DC.B      $1F,' ',$F8,$9A,$1F,$1A,$F8,$80 
  DC.B      $1F,$16,$F8,'n',$1F,$0F,$F8,'T' 
  DC.B      $1F,$09,$F8,':',$1F,$02,$F8,' ' 
  DC.B      $1E,$FC,$F8,$06,$1E,$F7,$F7,$F5 
  DC.B      $1E,$F0,$F7,$DB,$1E,$EA,$F7,$C1 
  DC.B      $1E,$E3,$F7,$A7,$1E,$DB,$F7,$8D 
  DC.B      $1E,$D4,$F7,'t',$1E,$D0,$F7,'b' 
  DC.B      $1E,$C8,$F7,'I',$1E,$C1,$F7,'/' 
  DC.B      $1E,$BA,$F7,$15,$1E,$B2,$F6,$FB 
  DC.B      $1E,$AD,$F6,$EA,$1E,$A5,$F6,$D1 
  DC.B      $1E,$9E,$F6,$B7,$1E,$96,$F6,$9D 
  DC.B      $1E,$8E,$F6,$84,$1E,$88,$F6,'s' 
  DC.B      $1E,$80,$F6,'Y',$1E,'x',$F6,'?' 
  DC.B      $1E,'p',$F6,'&',$1E,'h',$F6,$0C 
  DC.B      $1E,'_',$F5,$F3,$1E,'Z',$F5,$E2 
  DC.B      $1E,'Q',$F5,$C9,$1E,'I',$F5,$AF 
  DC.B      $1E,'@',$F5,$96,$1E,'7',$F5,'}' 
  DC.B      $1E,'1',$F5,'l',$1E,'(',$F5,'R' 
  DC.B      $1E,$1F,$F5,'9',$1E,$16,$F5,' ' 
  DC.B      $1E,$0D,$F5,$07,$1E,$07,$F4,$F6 
  DC.B      $1D,$FE,$F4,$DD,$1D,$F4,$F4,$C4 
  DC.B      $1D,$EB,$F4,$AB,$1D,$E2,$F4,$91 
  DC.B      $1D,$D8,$F4,'x',$1D,$D1,$F4,'h' 
  DC.B      $1D,$C8,$F4,'O',$1D,$BE,$F4,'6' 
  DC.B      $1D,$B4,$F4,$1D,$1D,$AA,$F4,$04 
  DC.B      $1D,$A3,$F3,$F4,$1D,$99,$F3,$DB 
  DC.B      $1D,$8F,$F3,$C2,$1D,$84,$F3,$A9 
  DC.B      $1D,'z',$F3,$91,$1D,'s',$F3,$80 
  DC.B      $1D,'i',$F3,'g',$1D,'^',$F3,'O' 
  DC.B      $1D,'S',$F3,'6',$1D,'I',$F3,$1E 
  DC.B      $1D,'>',$F3,$05,$1D,'7',$F2,$F5 
  DC.B      $1D,',',$F2,$DC,$1D,' ',$F2,$C4 
  DC.B      $1D,$15,$F2,$AC,$1D,$0A,$F2,$93 
  DC.B      $1D,$03,$F2,$83,$1C,$F7,$F2,'k' 
  DC.B      $1C,$EC,$F2,'S',$1C,$E0,$F2,':' 
  DC.B      $1C,$D5,$F2,'"',$1C,$CD,$F2,$12 
  DC.B      $1C,$C2,$F1,$FA,$1C,$B6,$F1,$E2 
  DC.B      $1C,$AA,$F1,$CA,$1C,$9E,$F1,$B2 
  DC.B      $1C,$92,$F1,$9A,$1C,$8A,$F1,$8A 
  DC.B      $1C,'~',$F1,'r',$1C,'q',$F1,'Z' 
  DC.B      $1C,'e',$F1,'B',$1C,'X',$F1,'+' 
  DC.B      $1C,'P',$F1,$1B,$1C,'D',$F1,$03 
  DC.B      $1C,'7',$F0,$EB,$1C,'*',$F0,$D4 
  DC.B      $1C,$1E,$F0,$BC,$1C,$15,$F0,$AD 
  DC.B      $1C,$08,$F0,$95,$1B,$FC,$F0,'}' 
  DC.B      $1B,$EE,$F0,'f',$1B,$E1,$F0,'O' 
  DC.B      $1B,$D4,$F0,'7',$1B,$CB,$F0,'(' 
  DC.B      $1B,$BE,$F0,$11,$1B,$B1,$EF,$F9 
  DC.B      $1B,$A3,$EF,$E2,$1B,$95,$EF,$CB 
  DC.B      $1B,$8C,$EF,$BC,$1B,$7F,$EF,$A5 
  DC.B      $1B,'q',$EF,$8E,$1B,'c',$EF,'w' 
  DC.B      $1B,'U',$EF,'`',$1B,'L',$EF,'P' 
  DC.B      $1B,'>',$EF,':',$1B,'0',$EF,'#' 
  DC.B      $1B,'"',$EF,$0C,$1B,$13,$EE,$F5 
  DC.B      $1B,$05,$EE,$DF,$1A,$FB,$EE,$D0 
  DC.B      $1A,$ED,$EE,$B9,$1A,$DF,$EE,$A2 
  DC.B      $1A,$D0,$EE,$8C,$1A,$C1,$EE,'v' 
  DC.B      $1A,$B7,$EE,'g',$1A,$A9,$EE,'P' 
  DC.B      $1A,$9A,$EE,':',$1A,$8B,$EE,'$' 
  DC.B      $1A,'|',$EE,$0D,$1A,'r',$ED,$FF 
  DC.B      $1A,'c',$ED,$E9,$1A,'T',$ED,$D3 
  DC.B      $1A,'D',$ED,$BC,$1A,'5',$ED,$A6 
  DC.B      $1A,'&',$ED,$91,$1A,$1B,$ED,$82 
  DC.B      $1A,$0C,$ED,'l',$19,$FC,$ED,'V' 
  DC.B      $19,$ED,$ED,'@',$19,$DD,$ED,'+' 
  DC.B      $19,$D2,$ED,$1C,$19,$C2,$ED,$07 
  DC.B      $19,$B2,$EC,$F1,$19,$A2,$EC,$DC 
  DC.B      $19,$92,$EC,$C6,$19,$88,$EC,$B8 
  DC.B      $19,'w',$EC,$A3,$19,'g',$EC,$8D 
  DC.B      $19,'W',$EC,'x',$19,'F',$EC,'c' 
  DC.B      $19,'6',$EC,'N',$19,'+',$EC,'@' 
  DC.B      $19,$1A,$EC,'+',$19,$0A,$EC,$16 
  DC.B      $18,$F9,$EC,$01,$18,$E8,$EB,$EC 
  DC.B      $18,$DD,$EB,$DE,$18,$CC,$EB,$C9 
  DC.B      $18,$BB,$EB,$B4,$18,$AA,$EB,$A0 
  DC.B      $18,$99,$EB,$8B,$18,$8E,$EB,'}' 
  DC.B      $18,'|',$EB,'i',$18,'k',$EB,'T' 
  DC.B      $18,'Z',$EB,'@',$18,'H',$EB,'+' 
  DC.B      $18,'7',$EB,$17,$18,'+',$EB,$0A 
  DC.B      $18,$19,$EA,$F5,$18,$08,$EA,$E1 
  DC.B      $17,$F6,$EA,$CD,$17,$E4,$EA,$B9 
  DC.B      $17,$D8,$EA,$AC,$17,$C7,$EA,$98 
  DC.B      $17,$B4,$EA,$84,$17,$A2,$EA,'p' 
  DC.B      $17,$90,$EA,'\',$17,$84,$EA,'O' 
  DC.B      $17,'r',$EA,';',$17,'`',$EA,'(' 
  DC.B      $17,'M',$EA,$14,$17,';',$EA,$01 
  DC.B      $17,')',$E9,$ED,$17,$1C,$E9,$E0 
  DC.B      $17,$0A,$E9,$CD,$16,$F7,$E9,$BA 
  DC.B      $16,$E4,$E9,$A7,$16,$D2,$E9,$94 
  DC.B      $16,$C5,$E9,$87,$16,$B2,$E9,'t' 
  DC.B      $16,$9F,$E9,'a',$16,$8C,$E9,'N' 
  DC.B      $16,'y',$E9,';',$16,'l',$E9,'.' 
  DC.B      $16,'Y',$E9,$1C,$16,'F',$E9,$09 
  DC.B      $16,'3',$E8,$F6,$16,' ',$E8,$E4 
  DC.B      $16,$0C,$E8,$D1,$15,$FF,$E8,$C5 
  DC.B      $15,$EC,$E8,$B3,$15,$D8,$E8,$A0 
  DC.B      $15,$C5,$E8,$8E,$15,$B1,$E8,'|' 
  DC.B      $15,$A4,$E8,'p',$15,$90,$E8,'^' 
  DC.B      $15,'|',$E8,'L',$15,'h',$E8,'9' 
  DC.B      $15,'T',$E8,'(',$15,'G',$E8,$1C 
  DC.B      $15,'3',$E8,$0A,$15,$1F,$E7,$F8 
  DC.B      $15,$0B,$E7,$E7,$14,$F6,$E7,$D5 
  DC.B      $14,$E2,$E7,$C3,$14,$D5,$E7,$B8 
  DC.B      $14,$C0,$E7,$A6,$14,$AC,$E7,$95 
  DC.B      $14,$97,$E7,$84,$14,$83,$E7,'r' 
  DC.B      $14,'u',$E7,'g',$14,'`',$E7,'V' 
  DC.B      $14,'L',$E7,'E',$14,'7',$E7,'4' 
  DC.B      $14,'"',$E7,'#',$14,$14,$E7,$18 
  DC.B      $13,$FF,$E7,$07,$13,$EA,$E6,$F6 
  DC.B      $13,$D5,$E6,$E6,$13,$C0,$E6,$D5 
  DC.B      $13,$AB,$E6,$C4,$13,$9D,$E6,$BA 
  DC.B      $13,$88,$E6,$A9,$13,'s',$E6,$99 
  DC.B      $13,']',$E6,$89,$13,'H',$E6,'x' 
  DC.B      $13,':',$E6,'n',$13,'$',$E6,'^' 
  DC.B      $13,$0F,$E6,'N',$12,$F9,$E6,'>' 
  DC.B      $12,$E4,$E6,'.',$12,$D5,$E6,'#' 
  DC.B      $12,$C0,$E6,$13,$12,$AA,$E6,$04 
  DC.B      $12,$94,$E5,$F4,$12,'~',$E5,$E5 
  DC.B      $12,'h',$E5,$D5,$12,'Z',$E5,$CB 
  DC.B      $12,'D',$E5,$BC,$12,'-',$E5,$AC 
  DC.B      $12,$17,$E5,$9D,$12,$01,$E5,$8E 
  DC.B      $11,$F3,$E5,$84,$11,$DC,$E5,'u' 
  DC.B      $11,$C6,$E5,'f',$11,$B0,$E5,'W' 
  DC.B      $11,$99,$E5,'I',$11,$8A,$E5,'?' 
  DC.B      $11,'t',$E5,'0',$11,'^',$E5,'!' 
  DC.B      $11,'G',$E5,$13,$11,'0',$E5,$05 
  DC.B      $11,$1A,$E4,$F6,$11,$0B,$E4,$ED 
  DC.B      $10,$F4,$E4,$DE,$10,$DD,$E4,$D0 
  DC.B      $10,$C6,$E4,$C2,$10,$B0,$E4,$B4 
  DC.B      $10,$A0,$E4,$AB,$10,$89,$E4,$9D 
  DC.B      $10,'r',$E4,$8F,$10,'[',$E4,$81 
  DC.B      $10,'D',$E4,'t',$10,'5',$E4,'k' 
  DC.B      $10,$1E,$E4,']',$10,$07,$E4,'O' 
  DC.B      $0F,$EF,$E4,'B',$0F,$D8,$E4,'5' 
  DC.B      $0F,$C1,$E4,'(',$0F,$B1,$E4,$1F 
  DC.B      $0F,$9A,$E4,$12,$0F,$83,$E4,$04 
  DC.B      $0F,'k',$E3,$F8,$0F,'S',$E3,$EB 
  DC.B      $0F,'D',$E3,$E2,$0F,',',$E3,$D6 
  DC.B      $0F,$15,$E3,$C9,$0E,$FD,$E3,$BC 
  DC.B      $0E,$E5,$E3,$B0,$0E,$D5,$E3,$A8 
  DC.B      $0E,$BE,$E3,$9B,$0E,$A6,$E3,$8F 
  DC.B      $0E,$8E,$E3,$82,$0E,'v',$E3,'v' 
  DC.B      $0E,'^',$E3,'j',$0E,'N',$E3,'b' 
  DC.B      $0E,'6',$E3,'V',$0E,$1E,$E3,'J' 
  DC.B      $0E,$06,$E3,'>',$0D,$EE,$E3,'3' 
  DC.B      $0D,$DE,$E3,'+',$0D,$C6,$E3,' ' 
  DC.B      $0D,$AD,$E3,$14,$0D,$95,$E3,$09 
  DC.B      $0D,'}',$E2,$FD,$0D,'m',$E2,$F6 
  DC.B      $0D,'T',$E2,$EB,$0D,'<',$E2,$E0 
  DC.B      $0D,'$',$E2,$D4,$0D,$0B,$E2,$C9 
  DC.B      $0C,$F3,$E2,$BF,$0C,$E2,$E2,$B7 
  DC.B      $0C,$CA,$E2,$AD,$0C,$B1,$E2,$A2 
  DC.B      $0C,$99,$E2,$97,$0C,$80,$E2,$8D 
  DC.B      $0C,'o',$E2,$86,$0C,'W',$E2,'|' 
  DC.B      $0C,'>',$E2,'q',$0C,'%',$E2,'g' 
  DC.B      $0C,$0C,$E2,']',$0B,$FC,$E2,'V' 
  DC.B      $0B,$E3,$E2,'L',$0B,$CA,$E2,'B' 
  DC.B      $0B,$B1,$E2,'8',$0B,$98,$E2,'/' 
  DC.B      $0B,$7F,$E2,'%',$0B,'o',$E2,$1E 
  DC.B      $0B,'U',$E2,$15,$0B,'<',$E2,$0C 
  DC.B      $0B,'#',$E2,$02,$0B,$0A,$E1,$F9 
  DC.B      $0A,$F9,$E1,$F3,$0A,$E0,$E1,$EA 
  DC.B      $0A,$C7,$E1,$E1,$0A,$AE,$E1,$D8 
  DC.B      $0A,$94,$E1,$CF,$0A,$83,$E1,$C9 
  DC.B      $0A,'j',$E1,$C0,$0A,'Q',$E1,$B7 
  DC.B      $0A,'7',$E1,$AF,$0A,$1E,$E1,$A6 
  DC.B      $0A,$05,$E1,$9E,$09,$F4,$E1,$98 
  DC.B      $09,$DA,$E1,$90,$09,$C1,$E1,$88 
  DC.B      $09,$A7,$E1,$80,$09,$8D,$E1,'x' 
  DC.B      $09,'|',$E1,'r',$09,'c',$E1,'j' 
  DC.B      $09,'I',$E1,'b',$09,'/',$E1,'[' 
  DC.B      $09,$16,$E1,'S',$09,$05,$E1,'N' 
  DC.B      $08,$EB,$E1,'F',$08,$D1,$E1,'?' 
  DC.B      $08,$B7,$E1,'8',$08,$9E,$E1,'0' 
  DC.B      $08,$84,$E1,')',$08,'s',$E1,'%' 
  DC.B      $08,'Y',$E1,$1D,$08,'?',$E1,$16 
  DC.B      $08,'%',$E1,$10,$08,$0B,$E1,$09 
  DC.B      $07,$FA,$E1,$04,$07,$E0,$E0,$FE 
  DC.B      $07,$C6,$E0,$F7,$07,$AC,$E0,$F1 
  DC.B      $07,$92,$E0,$EA,$07,$80,$E0,$E6 
  DC.B      $07,'f',$E0,$E0,$07,'L',$E0,$DA 
  DC.B      $07,'2',$E0,$D3,$07,$18,$E0,$CE 
  DC.B      $06,$FE,$E0,$C8,$06,$EC,$E0,$C4 
  DC.B      $06,$D2,$E0,$BE,$06,$B8,$E0,$B8 
  DC.B      $06,$9E,$E0,$B3,$06,$83,$E0,$AD 
  DC.B      $06,'r',$E0,$AA,$06,'X',$E0,$A4 
  DC.B      $06,'=',$E0,$9F,$06,'#',$E0,$9A 
  DC.B      $06,$09,$E0,$95,$05,$F7,$E0,$91 
  DC.B      $05,$DD,$E0,$8D,$05,$C3,$E0,$88 
  DC.B      $05,$A8,$E0,$83,$05,$8E,$E0,'~' 
  DC.B      $05,'s',$E0,'z',$05,'b',$E0,'w' 
  DC.B      $05,'G',$E0,'r',$05,'-',$E0,'n' 
  DC.B      $05,$12,$E0,'i',$04,$F8,$E0,'e' 
  DC.B      $04,$E6,$E0,'b',$04,$CC,$E0,'^' 
  DC.B      $04,$B1,$E0,'Z',$04,$97,$E0,'V' 
  DC.B      $04,'|',$E0,'S',$04,'k',$E0,'P' 
  DC.B      $04,'P',$E0,'M',$04,'5',$E0,'I' 
  DC.B      $04,$1B,$E0,'F',$04,$00,$E0,'B' 
  DC.B      $03,$E6,$E0,'?',$03,$D4,$E0,'=' 
  DC.B      $03,$B9,$E0,'9',$03,$9F,$E0,'6' 
  DC.B      $03,$84,$E0,'3',$03,'i',$E0,'0' 
  DC.B      $03,'X',$E0,'.',$03,'=',$E0,',' 
  DC.B      $03,'"',$E0,')',$03,$08,$E0,$27 
  DC.B      $02,$ED,$E0,'$',$02,$DB,$E0,'"' 
  DC.B      $02,$C0,$E0,' ',$02,$A6,$E0,$1E 
  DC.B      $02,$8B,$E0,$1C,$02,'p',$E0,$1A 
  DC.B      $02,'V',$E0,$18,$02,'D',$E0,$16 
  DC.B      $02,')',$E0,$14,$02,$0E,$E0,$13 
  DC.B      $01,$F4,$E0,$11,$01,$D9,$E0,$0F 
  DC.B      $01,$C7,$E0,$0E,$01,$AC,$E0,$0D 
  DC.B      $01,$91,$E0,$0C,$01,'w',$E0,$0A 
  DC.B      $01,'\',$E0,$09,$01,'J',$E0,$08 
  DC.B      $01,'/',$E0,$07,$01,$14,$E0,$06 
  DC.B      $00,$FA,$E0,$06,$00,$DF,$E0,$05 
  DC.B      $00,$C4,$E0,$04,$00,$B2,$E0,$04 
  DC.B      $00,$97,$E0,$03,$00,'}',$E0,$03 
  DC.B      $00,'b',$E0,$02,$00,'G',$E0,$02 
  DC.B      $00,'5',$E0,$02,$00,$1A,$E0,$02 
  DC.B      $00,$00,$E0,$01,$FF,$E6,$E0,$02 
  DC.B      $FF,$CB,$E0,$02,$FF,$B9,$E0,$02 
  DC.B      $FF,$9E,$E0,$02,$FF,$83,$E0,$03 
  DC.B      $FF,'i',$E0,$03,$FF,'N',$E0,$04 
  DC.B      $FF,'3',$E0,$04,$FF,'!',$E0,$05 
  DC.B      $FF,$06,$E0,$06,$FE,$EC,$E0,$06 
  DC.B      $FE,$D1,$E0,$07,$FE,$B6,$E0,$08 
  DC.B      $FE,$A4,$E0,$09,$FE,$89,$E0,$0A 
  DC.B      $FE,'o',$E0,$0C,$FE,'T',$E0,$0D 
  DC.B      $FE,'9',$E0,$0E,$FE,$27,$E0,$0F 
  DC.B      $FE,$0C,$E0,$11,$FD,$F2,$E0,$13 
  DC.B      $FD,$D7,$E0,$14,$FD,$BC,$E0,$16 
  DC.B      $FD,$A1,$E0,$18,$FD,$90,$E0,$1A 
  DC.B      $FD,'u',$E0,$1C,$FD,'Z',$E0,$1E 
  DC.B      $FD,'@',$E0,' ',$FD,'%',$E0,'"' 
  DC.B      $FD,$13,$E0,'$',$FC,$F8,$E0,$27 
  DC.B      $FC,$DE,$E0,')',$FC,$C3,$E0,',' 
  DC.B      $FC,$A8,$E0,'.',$FC,$97,$E0,'0' 
  DC.B      $FC,'|',$E0,'3',$FC,'a',$E0,'6' 
  DC.B      $FC,'G',$E0,'9',$FC,',',$E0,'=' 
  DC.B      $FC,$11,$E0,'@',$FC,$00,$E0,'B' 
  DC.B      $FB,$E5,$E0,'F',$FB,$CB,$E0,'I' 
  DC.B      $FB,$B0,$E0,'M',$FB,$95,$E0,'P' 
  DC.B      $FB,$84,$E0,'S',$FB,'i',$E0,'V' 
  DC.B      $FB,'O',$E0,'Z',$FB,'4',$E0,'^' 
  DC.B      $FB,$1A,$E0,'b',$FB,$08,$E0,'e' 
  DC.B      $FA,$EE,$E0,'i',$FA,$D3,$E0,'n' 
  DC.B      $FA,$B9,$E0,'r',$FA,$9E,$E0,'w' 
  DC.B      $FA,$84,$E0,'{',$FA,'r',$E0,'~' 
  DC.B      $FA,'X',$E0,$83,$FA,'=',$E0,$88 
  DC.B      $FA,'#',$E0,$8D,$FA,$09,$E0,$91 
  DC.B      $F9,$F7,$E0,$95,$F9,$DD,$E0,$9A 
  DC.B      $F9,$C3,$E0,$9F,$F9,$A8,$E0,$A4 
  DC.B      $F9,$8E,$E0,$AA,$F9,'}',$E0,$AD 
  DC.B      $F9,'b',$E0,$B3,$F9,'H',$E0,$B8 
  DC.B      $F9,'.',$E0,$BE,$F9,$14,$E0,$C4 
  DC.B      $F8,$FA,$E0,$CA,$F8,$E8,$E0,$CE 
  DC.B      $F8,$CE,$E0,$D3,$F8,$B4,$E0,$DA 
  DC.B      $F8,$9A,$E0,$E0,$F8,$80,$E0,$E6 
  DC.B      $F8,'n',$E0,$EA,$F8,'T',$E0,$F1 
  DC.B      $F8,':',$E0,$F7,$F8,' ',$E0,$FE 
  DC.B      $F8,$06,$E1,$04,$F7,$F5,$E1,$09 
  DC.B      $F7,$DB,$E1,$10,$F7,$C1,$E1,$16 
  DC.B      $F7,$A7,$E1,$1D,$F7,$8D,$E1,'%' 
  DC.B      $F7,'t',$E1,',',$F7,'b',$E1,'0' 
  DC.B      $F7,'I',$E1,'8',$F7,'/',$E1,'?' 
  DC.B      $F7,$15,$E1,'F',$F6,$FB,$E1,'N' 
  DC.B      $F6,$EA,$E1,'S',$F6,$D1,$E1,'[' 
  DC.B      $F6,$B7,$E1,'b',$F6,$9D,$E1,'j' 
  DC.B      $F6,$84,$E1,'r',$F6,'s',$E1,'x' 
  DC.B      $F6,'Y',$E1,$80,$F6,'?',$E1,$88 
  DC.B      $F6,'&',$E1,$90,$F6,$0C,$E1,$98 
  DC.B      $F5,$F3,$E1,$A1,$F5,$E2,$E1,$A6 
  DC.B      $F5,$C9,$E1,$AF,$F5,$AF,$E1,$B7 
  DC.B      $F5,$96,$E1,$C0,$F5,'}',$E1,$C9 
  DC.B      $F5,'l',$E1,$CF,$F5,'R',$E1,$D8 
  DC.B      $F5,'9',$E1,$E1,$F5,' ',$E1,$EA 
  DC.B      $F5,$07,$E1,$F3,$F4,$F6,$E1,$F9 
  DC.B      $F4,$DD,$E2,$02,$F4,$C4,$E2,$0C 
  DC.B      $F4,$AB,$E2,$15,$F4,$91,$E2,$1E 
  DC.B      $F4,'x',$E2,'(',$F4,'h',$E2,'/' 
  DC.B      $F4,'O',$E2,'8',$F4,'6',$E2,'B' 
  DC.B      $F4,$1D,$E2,'L',$F4,$04,$E2,'V' 
  DC.B      $F3,$F4,$E2,']',$F3,$DB,$E2,'g' 
  DC.B      $F3,$C2,$E2,'q',$F3,$A9,$E2,'|' 
  DC.B      $F3,$91,$E2,$86,$F3,$80,$E2,$8D 
  DC.B      $F3,'g',$E2,$97,$F3,'O',$E2,$A2 
  DC.B      $F3,'6',$E2,$AD,$F3,$1E,$E2,$B7 
  DC.B      $F3,$05,$E2,$C2,$F2,$F5,$E2,$C9 
  DC.B      $F2,$DC,$E2,$D4,$F2,$C4,$E2,$E0 
  DC.B      $F2,$AC,$E2,$EB,$F2,$93,$E2,$F6 
  DC.B      $F2,$83,$E2,$FD,$F2,'k',$E3,$09 
  DC.B      $F2,'S',$E3,$14,$F2,':',$E3,' ' 
  DC.B      $F2,'"',$E3,'+',$F2,$12,$E3,'3' 
  DC.B      $F1,$FA,$E3,'>',$F1,$E2,$E3,'J' 
  DC.B      $F1,$CA,$E3,'V',$F1,$B2,$E3,'b' 
  DC.B      $F1,$9A,$E3,'n',$F1,$8A,$E3,'v' 
  DC.B      $F1,'r',$E3,$82,$F1,'Z',$E3,$8F 
  DC.B      $F1,'B',$E3,$9B,$F1,'+',$E3,$A8 
  DC.B      $F1,$1B,$E3,$B0,$F1,$03,$E3,$BC 
  DC.B      $F0,$EB,$E3,$C9,$F0,$D4,$E3,$D6 
  DC.B      $F0,$BC,$E3,$E2,$F0,$AD,$E3,$EB 
  DC.B      $F0,$95,$E3,$F8,$F0,'}',$E4,$04 
  DC.B      $F0,'f',$E4,$12,$F0,'O',$E4,$1F 
  DC.B      $F0,'7',$E4,',',$F0,'(',$E4,'5' 
  DC.B      $F0,$11,$E4,'B',$EF,$F9,$E4,'O' 
  DC.B      $EF,$E2,$E4,']',$EF,$CB,$E4,'k' 
  DC.B      $EF,$BC,$E4,'t',$EF,$A5,$E4,$81 
  DC.B      $EF,$8E,$E4,$8F,$EF,'w',$E4,$9D 
  DC.B      $EF,'`',$E4,$AB,$EF,'P',$E4,$B4 
  DC.B      $EF,':',$E4,$C2,$EF,'#',$E4,$D0 
  DC.B      $EF,$0C,$E4,$DE,$EE,$F5,$E4,$ED 
  DC.B      $EE,$DF,$E4,$FB,$EE,$D0,$E5,$05 
  DC.B      $EE,$B9,$E5,$13,$EE,$A2,$E5,'!' 
  DC.B      $EE,$8C,$E5,'0',$EE,'v',$E5,'?' 
  DC.B      $EE,'g',$E5,'I',$EE,'P',$E5,'W' 
  DC.B      $EE,':',$E5,'f',$EE,'$',$E5,'u' 
  DC.B      $EE,$0D,$E5,$84,$ED,$FF,$E5,$8E 
  DC.B      $ED,$E9,$E5,$9D,$ED,$D3,$E5,$AC 
  DC.B      $ED,$BC,$E5,$BC,$ED,$A6,$E5,$CB 
  DC.B      $ED,$91,$E5,$DA,$ED,$82,$E5,$E5 
  DC.B      $ED,'l',$E5,$F4,$ED,'V',$E6,$04 
  DC.B      $ED,'@',$E6,$13,$ED,'+',$E6,'#' 
  DC.B      $ED,$1C,$E6,'.',$ED,$07,$E6,'>' 
  DC.B      $EC,$F1,$E6,'N',$EC,$DC,$E6,'^' 
  DC.B      $EC,$C6,$E6,'n',$EC,$B8,$E6,'x' 
  DC.B      $EC,$A3,$E6,$89,$EC,$8D,$E6,$99 
  DC.B      $EC,'x',$E6,$A9,$EC,'c',$E6,$BA 
  DC.B      $EC,'N',$E6,$CA,$EC,'@',$E6,$D5 
  DC.B      $EC,'+',$E6,$E6,$EC,$16,$E6,$F6 
  DC.B      $EC,$01,$E7,$07,$EB,$EC,$E7,$18 
  DC.B      $EB,$DE,$E7,'#',$EB,$C9,$E7,'4' 
  DC.B      $EB,$B4,$E7,'E',$EB,$A0,$E7,'V' 
  DC.B      $EB,$8B,$E7,'g',$EB,'}',$E7,'r' 
  DC.B      $EB,'i',$E7,$84,$EB,'T',$E7,$95 
  DC.B      $EB,'@',$E7,$A6,$EB,'+',$E7,$B8 
  DC.B      $EB,$17,$E7,$C9,$EB,$0A,$E7,$D5 
  DC.B      $EA,$F5,$E7,$E7,$EA,$E1,$E7,$F8 
  DC.B      $EA,$CD,$E8,$0A,$EA,$B9,$E8,$1C 
  DC.B      $EA,$AC,$E8,'(',$EA,$98,$E8,'9' 
  DC.B      $EA,$84,$E8,'L',$EA,'p',$E8,'^' 
  DC.B      $EA,'\',$E8,'p',$EA,'O',$E8,'|' 
  DC.B      $EA,';',$E8,$8E,$EA,'(',$E8,$A0 
  DC.B      $EA,$14,$E8,$B3,$EA,$01,$E8,$C5 
  DC.B      $E9,$ED,$E8,$D7,$E9,$E0,$E8,$E4 
  DC.B      $E9,$CD,$E8,$F6,$E9,$BA,$E9,$09 
  DC.B      $E9,$A7,$E9,$1C,$E9,$94,$E9,'.' 
  DC.B      $E9,$87,$E9,';',$E9,'t',$E9,'N' 
  DC.B      $E9,'a',$E9,'a',$E9,'N',$E9,'t' 
  DC.B      $E9,';',$E9,$87,$E9,'.',$E9,$94 
  DC.B      $E9,$1C,$E9,$A7,$E9,$09,$E9,$BA 
  DC.B      $E8,$F6,$E9,$CD,$E8,$E4,$E9,$E0 
  DC.B      $E8,$D1,$E9,$F4,$E8,$C5,$EA,$01 
  DC.B      $E8,$B3,$EA,$14,$E8,$A0,$EA,'(' 
  DC.B      $E8,$8E,$EA,';',$E8,'|',$EA,'O' 
  DC.B      $E8,'p',$EA,'\',$E8,'^',$EA,'p' 
  DC.B      $E8,'L',$EA,$84,$E8,'9',$EA,$98 
  DC.B      $E8,'(',$EA,$AC,$E8,$1C,$EA,$B9 
  DC.B      $E8,$0A,$EA,$CD,$E7,$F8,$EA,$E1 
  DC.B      $E7,$E7,$EA,$F5,$E7,$D5,$EB,$0A 
  DC.B      $E7,$C3,$EB,$1E,$E7,$B8,$EB,'+' 
  DC.B      $E7,$A6,$EB,'@',$E7,$95,$EB,'T' 
  DC.B      $E7,$84,$EB,'i',$E7,'r',$EB,'}' 
  DC.B      $E7,'g',$EB,$8B,$E7,'V',$EB,$A0 
  DC.B      $E7,'E',$EB,$B4,$E7,'4',$EB,$C9 
  DC.B      $E7,'#',$EB,$DE,$E7,$18,$EB,$EC 
  DC.B      $E7,$07,$EC,$01,$E6,$F6,$EC,$16 
  DC.B      $E6,$E6,$EC,'+',$E6,$D5,$EC,'@' 
  DC.B      $E6,$C4,$EC,'U',$E6,$BA,$EC,'c' 
  DC.B      $E6,$A9,$EC,'x',$E6,$99,$EC,$8D 
  DC.B      $E6,$89,$EC,$A3,$E6,'x',$EC,$B8 
  DC.B      $E6,'n',$EC,$C6,$E6,'^',$EC,$DC 
  DC.B      $E6,'N',$EC,$F1,$E6,'>',$ED,$07 
  DC.B      $E6,'.',$ED,$1C,$E6,'#',$ED,'+' 
  DC.B      $E6,$13,$ED,'@',$E6,$04,$ED,'V' 
  DC.B      $E5,$F4,$ED,'l',$E5,$E5,$ED,$82 
  DC.B      $E5,$D5,$ED,$98,$E5,$CB,$ED,$A6 
  DC.B      $E5,$BC,$ED,$BC,$E5,$AC,$ED,$D3 
  DC.B      $E5,$9D,$ED,$E9,$E5,$8E,$ED,$FF 
  DC.B      $E5,$84,$EE,$0D,$E5,'u',$EE,'$' 
  DC.B      $E5,'f',$EE,':',$E5,'W',$EE,'P' 
  DC.B      $E5,'I',$EE,'g',$E5,'?',$EE,'v' 
  DC.B      $E5,'0',$EE,$8C,$E5,'!',$EE,$A2 
  DC.B      $E5,$13,$EE,$B9,$E5,$05,$EE,$D0 
  DC.B      $E4,$F6,$EE,$E6,$E4,$ED,$EE,$F5 
  DC.B      $E4,$DE,$EF,$0C,$E4,$D0,$EF,'#' 
  DC.B      $E4,$C2,$EF,':',$E4,$B4,$EF,'P' 
  DC.B      $E4,$AB,$EF,'`',$E4,$9D,$EF,'w' 
  DC.B      $E4,$8F,$EF,$8E,$E4,$81,$EF,$A5 
  DC.B      $E4,'t',$EF,$BC,$E4,'k',$EF,$CB 
  DC.B      $E4,']',$EF,$E2,$E4,'O',$EF,$F9 
  DC.B      $E4,'B',$F0,$11,$E4,'5',$F0,'(' 
  DC.B      $E4,'(',$F0,'?',$E4,$1F,$F0,'O' 
  DC.B      $E4,$12,$F0,'f',$E4,$04,$F0,'}' 
  DC.B      $E3,$F8,$F0,$95,$E3,$EB,$F0,$AD 
  DC.B      $E3,$E2,$F0,$BC,$E3,$D6,$F0,$D4 
  DC.B      $E3,$C9,$F0,$EB,$E3,$BC,$F1,$03 
  DC.B      $E3,$B0,$F1,$1B,$E3,$A8,$F1,'+' 
  DC.B      $E3,$9B,$F1,'B',$E3,$8F,$F1,'Z' 
  DC.B      $E3,$82,$F1,'r',$E3,'v',$F1,$8A 
  DC.B      $E3,'j',$F1,$A2,$E3,'b',$F1,$B2 
  DC.B      $E3,'V',$F1,$CA,$E3,'J',$F1,$E2 
  DC.B      $E3,'>',$F1,$FA,$E3,'3',$F2,$12 
  DC.B      $E3,'+',$F2,'"',$E3,' ',$F2,':' 
  DC.B      $E3,$14,$F2,'S',$E3,$09,$F2,'k' 
  DC.B      $E2,$FD,$F2,$83,$E2,$F6,$F2,$93 
  DC.B      $E2,$EB,$F2,$AC,$E2,$E0,$F2,$C4 
  DC.B      $E2,$D4,$F2,$DC,$E2,$C9,$F2,$F5 
  DC.B      $E2,$BF,$F3,$0D,$E2,$B7,$F3,$1E 
  DC.B      $E2,$AD,$F3,'6',$E2,$A2,$F3,'O' 
  DC.B      $E2,$97,$F3,'g',$E2,$8D,$F3,$80 
  DC.B      $E2,$86,$F3,$91,$E2,'|',$F3,$A9 
  DC.B      $E2,'q',$F3,$C2,$E2,'g',$F3,$DB 
  DC.B      $E2,']',$F3,$F4,$E2,'V',$F4,$04 
  DC.B      $E2,'L',$F4,$1D,$E2,'B',$F4,'6' 
  DC.B      $E2,'8',$F4,'O',$E2,'/',$F4,'h' 
  DC.B      $E2,'%',$F4,$81,$E2,$1E,$F4,$91 
  DC.B      $E2,$15,$F4,$AB,$E2,$0C,$F4,$C4 
  DC.B      $E2,$02,$F4,$DD,$E1,$F9,$F4,$F6 
  DC.B      $E1,$F3,$F5,$07,$E1,$EA,$F5,' ' 
  DC.B      $E1,$E1,$F5,'9',$E1,$D8,$F5,'R' 
  DC.B      $E1,$CF,$F5,'l',$E1,$C9,$F5,'}' 
  DC.B      $E1,$C0,$F5,$96,$E1,$B7,$F5,$AF 
  DC.B      $E1,$AF,$F5,$C9,$E1,$A6,$F5,$E2 
  DC.B      $E1,$9E,$F5,$FB,$E1,$98,$F6,$0C 
  DC.B      $E1,$90,$F6,'&',$E1,$88,$F6,'?' 
  DC.B      $E1,$80,$F6,'Y',$E1,'x',$F6,'s' 
  DC.B      $E1,'r',$F6,$84,$E1,'j',$F6,$9D 
  DC.B      $E1,'b',$F6,$B7,$E1,'[',$F6,$D1 
  DC.B      $E1,'S',$F6,$EA,$E1,'N',$F6,$FB 
  DC.B      $E1,'F',$F7,$15,$E1,'?',$F7,'/' 
  DC.B      $E1,'8',$F7,'I',$E1,'0',$F7,'b' 
  DC.B      $E1,')',$F7,'|',$E1,'%',$F7,$8D 
  DC.B      $E1,$1D,$F7,$A7,$E1,$16,$F7,$C1 
  DC.B      $E1,$10,$F7,$DB,$E1,$09,$F7,$F5 
  DC.B      $E1,$04,$F8,$06,$E0,$FE,$F8,' ' 
  DC.B      $E0,$F7,$F8,':',$E0,$F1,$F8,'T' 
  DC.B      $E0,$EA,$F8,'n',$E0,$E6,$F8,$80 
  DC.B      $E0,$E0,$F8,$9A,$E0,$DA,$F8,$B4 
  DC.B      $E0,$D3,$F8,$CE,$E0,$CE,$F8,$E8 
  DC.B      $E0,$C8,$F9,$02,$E0,$C4,$F9,$14 
  DC.B      $E0,$BE,$F9,'.',$E0,$B8,$F9,'H' 
  DC.B      $E0,$B3,$F9,'b',$E0,$AD,$F9,'}' 
  DC.B      $E0,$AA,$F9,$8E,$E0,$A4,$F9,$A8 
  DC.B      $E0,$9F,$F9,$C3,$E0,$9A,$F9,$DD 
  DC.B      $E0,$95,$F9,$F7,$E0,$91,$FA,$09 
  DC.B      $E0,$8D,$FA,'#',$E0,$88,$FA,'=' 
  DC.B      $E0,$83,$FA,'X',$E0,'~',$FA,'r' 
  DC.B      $E0,'z',$FA,$8D,$E0,'w',$FA,$9E 
  DC.B      $E0,'r',$FA,$B9,$E0,'n',$FA,$D3 
  DC.B      $E0,'i',$FA,$EE,$E0,'e',$FB,$08 
  DC.B      $E0,'b',$FB,$1A,$E0,'^',$FB,'4' 
  DC.B      $E0,'Z',$FB,'O',$E0,'V',$FB,'i' 
  DC.B      $E0,'S',$FB,$84,$E0,'P',$FB,$95 
  DC.B      $E0,'M',$FB,$B0,$E0,'I',$FB,$CB 
  DC.B      $E0,'F',$FB,$E5,$E0,'B',$FC,$00 
  DC.B      $E0,'?',$FC,$1A,$E0,'=',$FC,',' 
  DC.B      $E0,'9',$FC,'G',$E0,'6',$FC,'a' 
  DC.B      $E0,'3',$FC,'|',$E0,'0',$FC,$97 
  DC.B      $E0,'.',$FC,$A8,$E0,',',$FC,$C3 
  DC.B      $E0,')',$FC,$DE,$E0,$27,$FC,$F8 
  DC.B      $E0,'$',$FD,$13,$E0,'"',$FD,'%' 
  DC.B      $E0,' ',$FD,'@',$E0,$1E,$FD,'Z' 
  DC.B      $E0,$1C,$FD,'u',$E0,$1A,$FD,$90 
  DC.B      $E0,$18,$FD,$AA,$E0,$16,$FD,$BC 
  DC.B      $E0,$14,$FD,$D7,$E0,$13,$FD,$F2 
  DC.B      $E0,$11,$FE,$0C,$E0,$0F,$FE,$27 
  DC.B      $E0,$0E,$FE,'9',$E0,$0D,$FE,'T' 
  DC.B      $E0,$0C,$FE,'o',$E0,$0A,$FE,$89 
  DC.B      $E0,$09,$FE,$A4,$E0,$08,$FE,$B6 
  DC.B      $E0,$07,$FE,$D1,$E0,$06,$FE,$EC 
  DC.B      $E0,$06,$FF,$06,$E0,$05,$FF,'!' 
  DC.B      $E0,$04,$FF,'<',$E0,$04,$FF,'N' 
  DC.B      $E0,$03,$FF,'i',$E0,$03,$FF,$83 
  DC.B      $E0,$02,$FF,$9E,$E0,$02,$FF,$B9 
  DC.B      $E0,$02,$FF,$CB,$E0,$02,$FF,$E6 
  DC.B      $E0,$01,$00,$00,$E0,$02,$00,$1A 
  DC.B      $E0,$02,$00,'5',$E0,$02,$00,'G' 
  DC.B      $E0,$02,$00,'b',$E0,$03,$00,'}' 
  DC.B      $E0,$03,$00,$97,$E0,$04,$00,$B2 
  DC.B      $E0,$04,$00,$CD,$E0,$05,$00,$DF 
  DC.B      $E0,$06,$00,$FA,$E0,$06,$01,$14 
  DC.B      $E0,$07,$01,'/',$E0,$08,$01,'J' 
  DC.B      $E0,$09,$01,'\',$E0,$0A,$01,'w' 
  DC.B      $E0,$0C,$01,$91,$E0,$0D,$01,$AC 
  DC.B      $E0,$0E,$01,$C7,$E0,$0F,$01,$D9 
  DC.B      $E0,$11,$01,$F4,$E0,$13,$02,$0E 
  DC.B      $E0,$14,$02,')',$E0,$16,$02,'D' 
  DC.B      $E0,$18,$02,'_',$E0,$1A,$02,'p' 
  DC.B      $E0,$1C,$02,$8B,$E0,$1E,$02,$A6 
  DC.B      $E0,' ',$02,$C0,$E0,'"',$02,$DB 
  DC.B      $E0,'$',$02,$ED,$E0,$27,$03,$08 
  DC.B      $E0,')',$03,'"',$E0,',',$03,'=' 
  DC.B      $E0,'.',$03,'X',$E0,'0',$03,'i' 
  DC.B      $E0,'3',$03,$84,$E0,'6',$03,$9F 
  DC.B      $E0,'9',$03,$B9,$E0,'=',$03,$D4 
  DC.B      $E0,'@',$03,$EF,$E0,'B',$04,$00 
  DC.B      $E0,'F',$04,$1B,$E0,'I',$04,'5' 
  DC.B      $E0,'M',$04,'P',$E0,'P',$04,'k' 
  DC.B      $E0,'S',$04,'|',$E0,'V',$04,$97 
  DC.B      $E0,'Z',$04,$B1,$E0,'^',$04,$CC 
  DC.B      $E0,'b',$04,$E6,$E0,'e',$04,$F8 
  DC.B      $E0,'i',$05,$12,$E0,'n',$05,'-' 
  DC.B      $E0,'r',$05,'G',$E0,'w',$05,'b' 
  DC.B      $E0,'{',$05,'|',$E0,'~',$05,$8E 
  DC.B      $E0,$83,$05,$A8,$E0,$88,$05,$C3 
  DC.B      $E0,$8D,$05,$DD,$E0,$91,$05,$F7 
  DC.B      $E0,$95,$06,$09,$E0,$9A,$06,'#' 
  DC.B      $E0,$9F,$06,'=',$E0,$A4,$06,'X' 
  DC.B      $E0,$AA,$06,'r',$E0,$AD,$06,$83 
  DC.B      $E0,$B3,$06,$9E,$E0,$B8,$06,$B8 
  DC.B      $E0,$BE,$06,$D2,$E0,$C4,$06,$EC 
  DC.B      $E0,$CA,$07,$06,$E0,$CE,$07,$18 
  DC.B      $E0,$D3,$07,'2',$E0,$DA,$07,'L' 
  DC.B      $E0,$E0,$07,'f',$E0,$E6,$07,$80 
  DC.B      $E0,$EA,$07,$92,$E0,$F1,$07,$AC 
  DC.B      $E0,$F7,$07,$C6,$E0,$FE,$07,$E0 
  DC.B      $E1,$04,$07,$FA,$E1,$09,$08,$0B 
  DC.B      $E1,$10,$08,'%',$E1,$16,$08,'?' 
  DC.B      $E1,$1D,$08,'Y',$E1,'%',$08,'s' 
  DC.B      $E1,',',$08,$8C,$E1,'0',$08,$9E 
  DC.B      $E1,'8',$08,$B7,$E1,'?',$08,$D1 
  DC.B      $E1,'F',$08,$EB,$E1,'N',$09,$05 
  DC.B      $E1,'S',$09,$16,$E1,'[',$09,'/' 
  DC.B      $E1,'b',$09,'I',$E1,'j',$09,'c' 
  DC.B      $E1,'r',$09,'|',$E1,'x',$09,$8D 
  DC.B      $E1,$80,$09,$A7,$E1,$88,$09,$C1 
  DC.B      $E1,$90,$09,$DA,$E1,$98,$09,$F4 
  DC.B      $E1,$A1,$0A,$0D,$E1,$A6,$0A,$1E 
  DC.B      $E1,$AF,$0A,'7',$E1,$B7,$0A,'Q' 
  DC.B      $E1,$C0,$0A,'j',$E1,$C9,$0A,$83 
  DC.B      $E1,$CF,$0A,$94,$E1,$D8,$0A,$AE 
  DC.B      $E1,$E1,$0A,$C7,$E1,$EA,$0A,$E0 
  DC.B      $E1,$F3,$0A,$F9,$E1,$F9,$0B,$0A 
  DC.B      $E2,$02,$0B,'#',$E2,$0C,$0B,'<' 
  DC.B      $E2,$15,$0B,'U',$E2,$1E,$0B,'o' 
  DC.B      $E2,'(',$0B,$88,$E2,'/',$0B,$98 
  DC.B      $E2,'8',$0B,$B1,$E2,'B',$0B,$CA 
  DC.B      $E2,'L',$0B,$E3,$E2,'V',$0B,$FC 
  DC.B      $E2,']',$0C,$0C,$E2,'g',$0C,'%' 
  DC.B      $E2,'q',$0C,'>',$E2,'|',$0C,'W' 
  DC.B      $E2,$86,$0C,'o',$E2,$8D,$0C,$80 
  DC.B      $E2,$97,$0C,$99,$E2,$A2,$0C,$B1 
  DC.B      $E2,$AD,$0C,$CA,$E2,$B7,$0C,$E2 
  DC.B      $E2,$C2,$0C,$FB,$E2,$C9,$0D,$0B 
  DC.B      $E2,$D4,$0D,'$',$E2,$E0,$0D,'<' 
  DC.B      $E2,$EB,$0D,'T',$E2,$F6,$0D,'m' 
  DC.B      $E2,$FD,$0D,'}',$E3,$09,$0D,$95 
  DC.B      $E3,$14,$0D,$AD,$E3,' ',$0D,$C6 
  DC.B      $E3,'+',$0D,$DE,$E3,'3',$0D,$EE 
  DC.B      $E3,'>',$0E,$06,$E3,'J',$0E,$1E 
  DC.B      $E3,'V',$0E,'6',$E3,'b',$0E,'N' 
  DC.B      $E3,'n',$0E,'f',$E3,'v',$0E,'v' 
  DC.B      $E3,$82,$0E,$8E,$E3,$8F,$0E,$A6 
  DC.B      $E3,$9B,$0E,$BE,$E3,$A8,$0E,$D5 
  DC.B      $E3,$B0,$0E,$E5,$E3,$BC,$0E,$FD 
  DC.B      $E3,$C9,$0F,$15,$E3,$D6,$0F,',' 
  DC.B      $E3,$E2,$0F,'D',$E3,$EB,$0F,'S' 
  DC.B      $E3,$F8,$0F,'k',$E4,$04,$0F,$83 
  DC.B      $E4,$12,$0F,$9A,$E4,$1F,$0F,$B1 
  DC.B      $E4,',',$0F,$C9,$E4,'5',$0F,$D8 
  DC.B      $E4,'B',$0F,$EF,$E4,'O',$10,$07 
  DC.B      $E4,']',$10,$1E,$E4,'k',$10,'5' 
  DC.B      $E4,'t',$10,'D',$E4,$81,$10,'[' 
  DC.B      $E4,$8F,$10,'r',$E4,$9D,$10,$89 
  DC.B      $E4,$AB,$10,$A0,$E4,$B4,$10,$B0 
  DC.B      $E4,$C2,$10,$C6,$E4,$D0,$10,$DD 
  DC.B      $E4,$DE,$10,$F4,$E4,$ED,$11,$0B 
  DC.B      $E4,$FB,$11,'!',$E5,$05,$11,'0' 
  DC.B      $E5,$13,$11,'G',$E5,'!',$11,'^' 
  DC.B      $E5,'0',$11,'t',$E5,'?',$11,$8A 
  DC.B      $E5,'I',$11,$99,$E5,'W',$11,$B0 
  DC.B      $E5,'f',$11,$C6,$E5,'u',$11,$DC 
  DC.B      $E5,$84,$11,$F3,$E5,$8E,$12,$01 
  DC.B      $E5,$9D,$12,$17,$E5,$AC,$12,'-' 
  DC.B      $E5,$BC,$12,'D',$E5,$CB,$12,'Z' 
  DC.B      $E5,$DA,$12,'o',$E5,$E5,$12,'~' 
  DC.B      $E5,$F4,$12,$94,$E6,$04,$12,$AA 
  DC.B      $E6,$13,$12,$C0,$E6,'#',$12,$D5 
  DC.B      $E6,'.',$12,$E4,$E6,'>',$12,$F9 
  DC.B      $E6,'N',$13,$0F,$E6,'^',$13,'$' 
  DC.B      $E6,'n',$13,':',$E6,'x',$13,'H' 
  DC.B      $E6,$89,$13,']',$E6,$99,$13,'s' 
  DC.B      $E6,$A9,$13,$88,$E6,$BA,$13,$9D 
  DC.B      $E6,$CA,$13,$B2,$E6,$D5,$13,$C0 
  DC.B      $E6,$E6,$13,$D5,$E6,$F6,$13,$EA 
  DC.B      $E7,$07,$13,$FF,$E7,$18,$14,$14 
  DC.B      $E7,'#',$14,'"',$E7,'4',$14,'7' 
  DC.B      $E7,'E',$14,'L',$E7,'V',$14,'`' 
  DC.B      $E7,'g',$14,'u',$E7,'r',$14,$83 
  DC.B      $E7,$84,$14,$97,$E7,$95,$14,$AC 
  DC.B      $E7,$A6,$14,$C0,$E7,$B8,$14,$D5 
  DC.B      $E7,$C9,$14,$E9,$E7,$D5,$14,$F6 
  DC.B      $E7,$E7,$15,$0B,$E7,$F8,$15,$1F 
  DC.B      $E8,$0A,$15,'3',$E8,$1C,$15,'G' 
  DC.B      $E8,'(',$15,'T',$E8,'9',$15,'h' 
  DC.B      $E8,'L',$15,'|',$E8,'^',$15,$90 
  DC.B      $E8,'p',$15,$A4,$E8,'|',$15,$B1 
  DC.B      $E8,$8E,$15,$C5,$E8,$A0,$15,$D8 
  DC.B      $E8,$B3,$15,$EC,$E8,$C5,$15,$FF 
  DC.B      $E8,$D7,$16,$13,$E8,$E4,$16,' ' 
  DC.B      $E8,$F6,$16,'3',$E9,$09,$16,'F' 
  DC.B      $E9,$1C,$16,'Y',$E9,'.',$16,'l' 
  DC.B      $E9,';',$16,'y',$E9,'N',$16,$8C 
  DC.B      $E9,'a',$16,$9F,$E9,'t',$16,$B2 
  DC.B      $E9,$87,$16,$C5,$E9,$94,$16,$D2 
  DC.B      $E9,$A7,$16,$E4,$E9,$BA,$16,$F7 
  DC.B      $E9,$CD,$17,$0A,$E9,$E0,$17,$1C 
  DC.B      $E9,$F4,$17,'/',$EA,$01,$17,';' 
  DC.B      $EA,$14,$17,'M',$EA,'(',$17,'`' 
  DC.B      $EA,';',$17,'r',$EA,'O',$17,$84 
  DC.B      $EA,'\',$17,$90,$EA,'p',$17,$A2 
  DC.B      $EA,$84,$17,$B4,$EA,$98,$17,$C7 
  DC.B      $EA,$AC,$17,$D8,$EA,$B9,$17,$E4 
  DC.B      $EA,$CD,$17,$F6,$EA,$E1,$18,$08 
  DC.B      $EA,$F5,$18,$19,$EB,$0A,$18,'+' 
  DC.B      $EB,$1E,$18,'=',$EB,'+',$18,'H' 
  DC.B      $EB,'@',$18,'Z',$EB,'T',$18,'k' 
  DC.B      $EB,'i',$18,'|',$EB,'}',$18,$8E 
  DC.B      $EB,$8B,$18,$99,$EB,$A0,$18,$AA 
  DC.B      $EB,$B4,$18,$BB,$EB,$C9,$18,$CC 
  DC.B      $EB,$DE,$18,$DD,$EB,$EC,$18,$E8 
  DC.B      $EC,$01,$18,$F9,$EC,$16,$19,$0A 
  DC.B      $EC,'+',$19,$1A,$EC,'@',$19,'+' 
  DC.B      $EC,'U',$19,'<',$EC,'c',$19,'F' 
  DC.B      $EC,'x',$19,'W',$EC,$8D,$19,'g' 
  DC.B      $EC,$A3,$19,'w',$EC,$B8,$19,$88 
  DC.B      $EC,$C6,$19,$92,$EC,$DC,$19,$A2 
  DC.B      $EC,$F1,$19,$B2,$ED,$07,$19,$C2 
  DC.B      $ED,$1C,$19,$D2,$ED,'+',$19,$DD 
  DC.B      $ED,'@',$19,$ED,$ED,'V',$19,$FC 
  DC.B      $ED,'l',$1A,$0C,$ED,$82,$1A,$1B 
  DC.B      $ED,$98,$1A,'+',$ED,$A6,$1A,'5' 
  DC.B      $ED,$BC,$1A,'D',$ED,$D3,$1A,'T' 
  DC.B      $ED,$E9,$1A,'c',$ED,$FF,$1A,'r' 
  DC.B      $EE,$0D,$1A,'|',$EE,'$',$1A,$8B 
  DC.B      $EE,':',$1A,$9A,$EE,'P',$1A,$A9 
  DC.B      $EE,'g',$1A,$B7,$EE,'v',$1A,$C1 
  DC.B      $EE,$8C,$1A,$D0,$EE,$A2,$1A,$DF 
  DC.B      $EE,$B9,$1A,$ED,$EE,$D0,$1A,$FB 
  DC.B      $EE,$E6,$1B,$0A,$EE,$F5,$1B,$13 
  DC.B      $EF,$0C,$1B,'"',$EF,'#',$1B,'0' 
  DC.B      $EF,':',$1B,'>',$EF,'P',$1B,'L' 
  DC.B      $EF,'`',$1B,'U',$EF,'w',$1B,'c' 
  DC.B      $EF,$8E,$1B,'q',$EF,$A5,$1B,$7F 
  DC.B      $EF,$BC,$1B,$8C,$EF,$CB,$1B,$95 
  DC.B      $EF,$E2,$1B,$A3,$EF,$F9,$1B,$B1 
  DC.B      $F0,$11,$1B,$BE,$F0,'(',$1B,$CB 
  DC.B      $F0,'?',$1B,$D8,$F0,'O',$1B,$E1 
  DC.B      $F0,'f',$1B,$EE,$F0,'}',$1B,$FC 
  DC.B      $F0,$95,$1C,$08,$F0,$AD,$1C,$15 
  DC.B      $F0,$BC,$1C,$1E,$F0,$D4,$1C,'*' 
  DC.B      $F0,$EB,$1C,'7',$F1,$03,$1C,'D' 
  DC.B      $F1,$1B,$1C,'P',$F1,'+',$1C,'X' 
  DC.B      $F1,'B',$1C,'e',$F1,'Z',$1C,'q' 
  DC.B      $F1,'r',$1C,'~',$F1,$8A,$1C,$8A 
  DC.B      $F1,$A2,$1C,$96,$F1,$B2,$1C,$9E 
  DC.B      $F1,$CA,$1C,$AA,$F1,$E2,$1C,$B6 
  DC.B      $F1,$FA,$1C,$C2,$F2,$12,$1C,$CD 
  DC.B      $F2,'"',$1C,$D5,$F2,':',$1C,$E0 
  DC.B      $F2,'S',$1C,$EC,$F2,'k',$1C,$F7 
  DC.B      $F2,$83,$1D,$03,$F2,$93,$1D,$0A 
  DC.B      $F2,$AC,$1D,$15,$F2,$C4,$1D,' ' 
  DC.B      $F2,$DC,$1D,',',$F2,$F5,$1D,'7' 
  DC.B      $F3,$0D,$1D,'A',$F3,$1E,$1D,'I' 
  DC.B      $F3,'6',$1D,'S',$F3,'O',$1D,'^' 
  DC.B      $F3,'g',$1D,'i',$F3,$80,$1D,'s' 
  DC.B      $F3,$91,$1D,'z',$F3,$A9,$1D,$84 
  DC.B      $F3,$C2,$1D,$8F,$F3,$DB,$1D,$99 
  DC.B      $F3,$F4,$1D,$A3,$F4,$04,$1D,$AA 
  DC.B      $F4,$1D,$1D,$B4,$F4,'6',$1D,$BE 
  DC.B      $F4,'O',$1D,$C8,$F4,'h',$1D,$D1 
  DC.B      $F4,$81,$1D,$DB,$F4,$91,$1D,$E2 
  DC.B      $F4,$AB,$1D,$EB,$F4,$C4,$1D,$F4 
  DC.B      $F4,$DD,$1D,$FE,$F4,$F6,$1E,$07 
  DC.B      $F5,$07,$1E,$0D,$F5,' ',$1E,$16 
  DC.B      $F5,'9',$1E,$1F,$F5,'R',$1E,'(' 
  DC.B      $F5,'l',$1E,'1',$F5,'}',$1E,'7' 
  DC.B      $F5,$96,$1E,'@',$F5,$AF,$1E,'I' 
  DC.B      $F5,$C9,$1E,'Q',$F5,$E2,$1E,'Z' 
  DC.B      $F5,$FB,$1E,'b',$F6,$0C,$1E,'h' 
  DC.B      $F6,'&',$1E,'p',$F6,'?',$1E,'x' 
  DC.B      $F6,'Y',$1E,$80,$F6,'s',$1E,$88 
  DC.B      $F6,$84,$1E,$8E,$F6,$9D,$1E,$96 
  DC.B      $F6,$B7,$1E,$9E,$F6,$D1,$1E,$A5 
  DC.B      $F6,$EA,$1E,$AD,$F6,$FB,$1E,$B2 
  DC.B      $F7,$15,$1E,$BA,$F7,'/',$1E,$C1 
  DC.B      $F7,'I',$1E,$C8,$F7,'b',$1E,$D0 
  DC.B      $F7,'|',$1E,$D7,$F7,$8D,$1E,$DB 
  DC.B      $F7,$A7,$1E,$E3,$F7,$C1,$1E,$EA 
  DC.B      $F7,$DB,$1E,$F0,$F7,$F5,$1E,$F7 
  DC.B      $F8,$06,$1E,$FC,$F8,' ',$1F,$02 
  DC.B      $F8,':',$1F,$09,$F8,'T',$1F,$0F 
  DC.B      $F8,'n',$1F,$16,$F8,$80,$1F,$1A 
  DC.B      $F8,$9A,$1F,' ',$F8,$B4,$1F,'&' 
  DC.B      $F8,$CE,$1F,'-',$F8,$E8,$1F,'2' 
  DC.B      $F9,$02,$1F,'8',$F9,$14,$1F,'<' 
  DC.B      $F9,'.',$1F,'B',$F9,'H',$1F,'H' 
  DC.B      $F9,'b',$1F,'M',$F9,'}',$1F,'S' 
  DC.B      $F9,$8E,$1F,'V',$F9,$A8,$1F,'\' 
  DC.B      $F9,$C3,$1F,'a',$F9,$DD,$1F,'f' 
  DC.B      $F9,$F7,$1F,'k',$FA,$09,$1F,'o' 
  DC.B      $FA,'#',$1F,'s',$FA,'=',$1F,'x' 
  DC.B      $FA,'X',$1F,'}',$FA,'r',$1F,$82 
  DC.B      $FA,$8D,$1F,$86,$FA,$9E,$1F,$89 
  DC.B      $FA,$B9,$1F,$8E,$FA,$D3,$1F,$92 
  DC.B      $FA,$EE,$1F,$97,$FB,$08,$1F,$9B 
  DC.B      $FB,$1A,$1F,$9E,$FB,'4',$1F,$A2 
  DC.B      $FB,'O',$1F,$A6,$FB,'i',$1F,$AA 
  DC.B      $FB,$84,$1F,$AD,$FB,$95,$1F,$B0 
  DC.B      $FB,$B0,$1F,$B3,$FB,$CB,$1F,$B7 
  DC.B      $FB,$E5,$1F,$BA,$FC,$00,$1F,$BE 
  DC.B      $FC,$1A,$1F,$C1,$FC,',',$1F,$C3 
  DC.B      $FC,'G',$1F,$C7,$FC,'a',$1F,$CA 
  DC.B      $FC,'|',$1F,$CD,$FC,$97,$1F,$D0 
  DC.B      $FC,$A8,$1F,$D2,$FC,$C3,$1F,$D4 
  DC.B      $FC,$DE,$1F,$D7,$FC,$F8,$1F,$D9 
  DC.B      $FD,$13,$1F,$DC,$FD,'%',$1F,$DE 
  DC.B      $FD,'@',$1F,$E0,$FD,'Z',$1F,$E2 
  DC.B      $FD,'u',$1F,$E4,$FD,$90,$1F,$E6 
  DC.B      $FD,$AA,$1F,$E8,$FD,$BC,$1F,$EA 
  DC.B      $FD,$D7,$1F,$EC,$FD,$F2,$1F,$ED 
  DC.B      $FE,$0C,$1F,$EF,$FE,$27,$1F,$F1 
  DC.B      $FE,'9',$1F,$F2,$FE,'T',$1F,$F3 
  DC.B      $FE,'o',$1F,$F4,$FE,$89,$1F,$F6 
  DC.B      $FE,$A4,$1F,$F7,$FE,$B6,$1F,$F8 
  DC.B      $FE,$D1,$1F,$F9,$FE,$EC,$1F,$FA 
  DC.B      $FF,$06,$1F,$FA,$FF,'!',$1F,$FB 
  DC.B      $FF,'<',$1F,$FC,$FF,'N',$1F,$FC 
  DC.B      $FF,'i',$1F,$FD,$FF,$83,$1F,$FD 
  DC.B      $FF,$9E,$1F,$FE,$FF,$B9,$1F,$FE 
  DC.B      $FF,$CB,$1F,$FE,$FF,$E6,$1F,$FE 
L0118:
  DC.B      $04,$00,$FC,$00,$03,$FE,$FC,$02 
  DC.B      $03,$FC,$FC,$04,$03,$F8,$FC,$08 
  DC.B      $03,$F3,$FC,$0D,$03,$EC,$FC,$14 
  DC.B      $03,$E5,$FC,$1B,$03,$DC,$FC,'$' 
  DC.B      $03,$D2,$FC,'.',$03,$C7,$FC,'9' 
  DC.B      $03,$BB,$FC,'E',$03,$AE,$FC,'R' 
  DC.B      $03,$9F,$FC,'a',$03,$90,$FC,'p' 
  DC.B      $03,$7F,$FC,$81,$03,'m',$FC,$93 
  DC.B      $03,'Z',$FC,$A6,$03,'F',$FC,$BA 
  DC.B      $03,'2',$FC,$CE,$03,$1C,$FC,$E4 
  DC.B      $03,$05,$FC,$FB,$02,$ED,$FD,$13 
  DC.B      $02,$D5,$FD,'+',$02,$BB,$FD,'E' 
  DC.B      $02,$A1,$FD,'_',$02,$86,$FD,'z' 
  DC.B      $02,'k',$FD,$95,$02,'N',$FD,$B2 
  DC.B      $02,'1',$FD,$CF,$02,$13,$FD,$ED 
  DC.B      $01,$F5,$FE,$0B,$01,$D6,$FE,'*' 
  DC.B      $01,$B6,$FE,'J',$01,$96,$FE,'j' 
  DC.B      $01,'v',$FE,$8A,$01,'U',$FE,$AB 
  DC.B      $01,'4',$FE,$CC,$01,$13,$FE,$ED 
  DC.B      $00,$F1,$FF,$0F,$00,$CF,$FF,'1' 
  DC.B      $00,$AC,$FF,'T',$00,$8A,$FF,'v' 
  DC.B      $00,'g',$FF,$99,$00,'E',$FF,$BB 
  DC.B      $00,'"',$FF,$DE,$00,$00,$00,$00 
  DC.B      $FF,$DE,$00,'"',$FF,$BB,$00,'E' 
  DC.B      $FF,$99,$00,'g',$FF,'w',$00,$89 
  DC.B      $FF,'U',$00,$AB,$FF,'3',$00,$CD 
  DC.B      $FF,$12,$00,$EE,$FE,$F1,$01,$0F 
  DC.B      $FE,$D0,$01,'0',$FE,$B0,$01,'P' 
  DC.B      $FE,$90,$01,'p',$FE,'p',$01,$90 
  DC.B      $FE,'R',$01,$AE,$FE,'3',$01,$CD 
  DC.B      $FE,$16,$01,$EA,$FD,$F9,$02,$07 
  DC.B      $FD,$DD,$02,'#',$FD,$C1,$02,'?' 
  DC.B      $FD,$A6,$02,'Z',$FD,$8C,$02,'t' 
  DC.B      $FD,'s',$02,$8D,$FD,'Z',$02,$A6 
  DC.B      $FD,'C',$02,$BD,$FD,',',$02,$D4 
  DC.B      $FD,$16,$02,$EA,$FD,$01,$02,$FF 
  DC.B      $FC,$ED,$03,$13,$FC,$DB,$03,'%' 
  DC.B      $FC,$C9,$03,'7',$FC,$B8,$03,'H' 
  DC.B      $FC,$A8,$03,'X',$FC,$99,$03,'g' 
  DC.B      $FC,$8C,$03,'t',$FC,$7F,$03,$81 
  DC.B      $FC,'t',$03,$8C,$FC,'i',$03,$97 
  DC.B      $FC,'`',$03,$A0,$FC,'X',$03,$A8 
  DC.B      $FC,'Q',$03,$AF,$FC,'L',$03,$B4 
  DC.B      $FC,'G',$03,$B9,$FC,'D',$03,$BC 
  DC.B      $FC,'A',$03,$BF,$FC,'@',$03,$C0 
  DC.B      $FC,'@',$03,$C0,$FC,'B',$03,$BE 
  DC.B      $FC,'D',$03,$BC,$FC,'H',$03,$B8 
  DC.B      $FC,'M',$03,$B3,$FC,'S',$03,$AD 
  DC.B      $FC,'Z',$03,$A6,$FC,'b',$03,$9E 
  DC.B      $FC,'k',$03,$95,$FC,'v',$03,$8A 
  DC.B      $FC,$81,$03,$7F,$FC,$8E,$03,'r' 
  DC.B      $FC,$9B,$03,'e',$FC,$AA,$03,'V' 
  DC.B      $FC,$BA,$03,'F',$FC,$CA,$03,'6' 
  DC.B      $FC,$DC,$03,'$',$FC,$EF,$03,$11 
  DC.B      $FD,$02,$02,$FE,$FD,$17,$02,$E9 
  DC.B      $FD,',',$02,$D4,$FD,'B',$02,$BE 
  DC.B      $FD,'Y',$02,$A7,$FD,'q',$02,$8F 
  DC.B      $FD,$8A,$02,'v',$FD,$A3,$02,']' 
  DC.B      $FD,$BD,$02,'C',$FD,$D8,$02,'(' 
  DC.B      $FD,$F3,$02,$0D,$FE,$0F,$01,$F1 
  DC.B      $FE,'+',$01,$D5,$FE,'H',$01,$B8 
  DC.B      $FE,'f',$01,$9A,$FE,$84,$01,'|' 
  DC.B      $FE,$A2,$01,'^',$FE,$C1,$01,'?' 
  DC.B      $FE,$E0,$01,' ',$FE,$FF,$01,$01 
  DC.B      $FF,$1F,$00,$E1,$FF,'?',$00,$C1 
  DC.B      $FF,'_',$00,$A1,$FF,$7F,$00,$81 
  DC.B      $FF,$9F,$00,'a',$FF,$C0,$00,'@' 
  DC.B      $FF,$E0,$00,' ',$00,$00,$00,$00 
  DC.B      $00,' ',$FF,$E0,$00,'@',$FF,$C0 
  DC.B      $00,'`',$FF,$A0,$00,$80,$FF,$80 
  DC.B      $00,$A0,$FF,'`',$00,$C0,$FF,'@' 
  DC.B      $00,$DF,$FF,'!',$00,$FE,$FF,$02 
  DC.B      $01,$1C,$FE,$E4,$01,':',$FE,$C6 
  DC.B      $01,'X',$FE,$A8,$01,'u',$FE,$8B 
  DC.B      $01,$92,$FE,'n',$01,$AE,$FE,'R' 
  DC.B      $01,$CA,$FE,'6',$01,$E5,$FE,$1B 
  DC.B      $02,$00,$FE,$00,$02,$19,$FD,$E7 
  DC.B      $02,'3',$FD,$CD,$02,'K',$FD,$B5 
  DC.B      $02,'b',$FD,$9E,$02,'y',$FD,$87 
  DC.B      $02,$8F,$FD,'q',$02,$A4,$FD,'\' 
  DC.B      $02,$B9,$FD,'G',$02,$CC,$FD,'4' 
  DC.B      $02,$DF,$FD,'!',$02,$F0,$FD,$10 
  DC.B      $03,$01,$FC,$FF,$03,$11,$FC,$EF 
  DC.B      $03,$1F,$FC,$E1,$03,'-',$FC,$D3 
  DC.B      $03,':',$FC,$C6,$03,'F',$FC,$BA 
  DC.B      $03,'P',$FC,$B0,$03,'Z',$FC,$A6 
  DC.B      $03,'b',$FC,$9E,$03,'j',$FC,$96 
  DC.B      $03,'p',$FC,$90,$03,'u',$FC,$8B 
  DC.B      $03,'z',$FC,$86,$03,'}',$FC,$83 
  DC.B      $03,$7F,$FC,$81,$03,$80,$FC,$80 
  DC.B      $03,$80,$FC,$80,$03,'~',$FC,$82 
  DC.B      $03,'|',$FC,$84,$03,'x',$FC,$88 
  DC.B      $03,'t',$FC,$8C,$03,'n',$FC,$92 
  DC.B      $03,'h',$FC,$98,$03,'`',$FC,$A0 
  DC.B      $03,'W',$FC,$A9,$03,'N',$FC,$B2 
  DC.B      $03,'C',$FC,$BD,$03,'7',$FC,$C9 
  DC.B      $03,'*',$FC,$D6,$03,$1D,$FC,$E3 
  DC.B      $03,$0E,$FC,$F2,$02,$FE,$FD,$02 
  DC.B      $02,$EE,$FD,$12,$02,$DC,$FD,'$' 
  DC.B      $02,$CA,$FD,'6',$02,$B7,$FD,'I' 
  DC.B      $02,$A3,$FD,']',$02,$8E,$FD,'r' 
  DC.B      $02,'y',$FD,$87,$02,'c',$FD,$9D 
  DC.B      $02,'L',$FD,$B4,$02,'4',$FD,$CC 
  DC.B      $02,$1C,$FD,$E4,$02,$03,$FD,$FD 
  DC.B      $01,$E9,$FE,$17,$01,$CF,$FE,'1' 
  DC.B      $01,$B5,$FE,'K',$01,$9A,$FE,'f' 
  DC.B      $01,'~',$FE,$82,$01,'b',$FE,$9E 
  DC.B      $01,'F',$FE,$BA,$01,')',$FE,$D7 
  DC.B      $01,$0C,$FE,$F4,$00,$EF,$FF,$11 
  DC.B      $00,$D2,$FF,'.',$00,$B4,$FF,'L' 
  DC.B      $00,$96,$FF,'j',$00,'x',$FF,$88 
  DC.B      $00,'Z',$FF,$A6,$00,'<',$FF,$C4 
  DC.B      $00,$1E,$FF,$E2,$00,$00,$00,$00 
  DC.B      $FF,$E2,$00,$1E,$FF,$C4,$00,'<' 
  DC.B      $FF,$A6,$00,'Z',$FF,$89,$00,'w' 
  DC.B      $FF,'k',$00,$95,$FF,'N',$00,$B2 
  DC.B      $FF,'1',$00,$CF,$FF,$14,$00,$EC 
  DC.B      $FE,$F7,$01,$09,$FE,$DB,$01,'%' 
  DC.B      $FE,$C0,$01,'@',$FE,$A5,$01,'[' 
  DC.B      $FE,$8A,$01,'v',$FE,'p',$01,$90 
  DC.B      $FE,'V',$01,$AA,$FE,'=',$01,$C3 
  DC.B      $FE,'$',$01,$DC,$FE,$0C,$01,$F4 
  DC.B      $FD,$F5,$02,$0B,$FD,$DE,$02,'"' 
  DC.B      $FD,$C8,$02,'8',$FD,$B3,$02,'M' 
  DC.B      $FD,$9F,$02,'a',$FD,$8B,$02,'u' 
  DC.B      $FD,'x',$02,$88,$FD,'f',$02,$9A 
  DC.B      $FD,'U',$02,$AB,$FD,'E',$02,$BB 
  DC.B      $FD,'5',$02,$CB,$FD,$27,$02,$D9 
  DC.B      $FD,$19,$02,$E7,$FD,$0C,$02,$F4 
  DC.B      $FD,$01,$02,$FF,$FC,$F6,$03,$0A 
  DC.B      $FC,$EC,$03,$14,$FC,$E3,$03,$1D 
  DC.B      $FC,$DB,$03,'%',$FC,$D4,$03,',' 
  DC.B      $FC,$CF,$03,'1',$FC,$CA,$03,'6' 
  DC.B      $FC,$C6,$03,':',$FC,$C3,$03,'=' 
  DC.B      $FC,$C1,$03,'?',$FC,$C0,$03,'@' 
  DC.B      $FC,$C0,$03,'@',$FC,$C2,$03,'>' 
  DC.B      $FC,$C4,$03,'<',$FC,$C7,$03,'9' 
  DC.B      $FC,$CB,$03,'5',$FC,$D1,$03,'/' 
  DC.B      $FC,$D7,$03,')',$FC,$DE,$03,'"' 
  DC.B      $FC,$E6,$03,$1A,$FC,$EF,$03,$11 
  DC.B      $FC,$F9,$03,$07,$FD,$04,$02,$FC 
  DC.B      $FD,$10,$02,$F0,$FD,$1D,$02,$E3 
  DC.B      $FD,'+',$02,$D5,$FD,'9',$02,$C7 
  DC.B      $FD,'I',$02,$B7,$FD,'Y',$02,$A7 
  DC.B      $FD,'j',$02,$96,$FD,'|',$02,$84 
  DC.B      $FD,$8E,$02,'r',$FD,$A1,$02,'_' 
  DC.B      $FD,$B5,$02,'K',$FD,$CA,$02,'6' 
  DC.B      $FD,$DF,$02,'!',$FD,$F5,$02,$0B 
  DC.B      $FE,$0C,$01,$F4,$FE,'#',$01,$DD 
  DC.B      $FE,':',$01,$C6,$FE,'S',$01,$AD 
  DC.B      $FE,'k',$01,$95,$FE,$84,$01,'|' 
  DC.B      $FE,$9E,$01,'b',$FE,$B8,$01,'H' 
  DC.B      $FE,$D2,$01,'.',$FE,$EC,$01,$14 
  DC.B      $FF,$07,$00,$F9,$FF,'"',$00,$DE 
  DC.B      $FF,'>',$00,$C2,$FF,'Y',$00,$A7 
  DC.B      $FF,'u',$00,$8B,$FF,$91,$00,'o' 
  DC.B      $FF,$AD,$00,'S',$FF,$C9,$00,'7' 
  DC.B      $FF,$E5,$00,$1B,$00,$00,$00,$00 
  DC.B      $00,$1B,$FF,$E5,$00,'7',$FF,$C9 
  DC.B      $00,'S',$FF,$AD,$00,'n',$FF,$92 
  DC.B      $00,$8A,$FF,'v',$00,$A5,$FF,'[' 
  DC.B      $00,$C0,$FF,'@',$00,$DA,$FF,'&' 
  DC.B      $00,$F5,$FF,$0B,$01,$0F,$FE,$F1 
  DC.B      $01,'(',$FE,$D8,$01,'A',$FE,$BF 
  DC.B      $01,'Z',$FE,$A6,$01,'r',$FE,$8E 
  DC.B      $01,$8A,$FE,'v',$01,$A1,$FE,'_' 
  DC.B      $01,$B8,$FE,'H',$01,$CE,$FE,'2' 
  DC.B      $01,$E4,$FE,$1C,$01,$F9,$FE,$07 
  DC.B      $02,$0D,$FD,$F3,$02,' ',$FD,$E0 
  DC.B      $02,'3',$FD,$CD,$02,'E',$FD,$BB 
  DC.B      $02,'W',$FD,$A9,$02,'g',$FD,$99 
  DC.B      $02,'w',$FD,$89,$02,$86,$FD,'z' 
  DC.B      $02,$94,$FD,'l',$02,$A2,$FD,'^' 
  DC.B      $02,$AE,$FD,'R',$02,$BA,$FD,'F' 
  DC.B      $02,$C5,$FD,';',$02,$CF,$FD,'1' 
  DC.B      $02,$D8,$FD,'(',$02,$E0,$FD,' ' 
  DC.B      $02,$E7,$FD,$19,$02,$EE,$FD,$12 
  DC.B      $02,$F3,$FD,$0D,$02,$F7,$FD,$09 
  DC.B      $02,$FB,$FD,$05,$02,$FD,$FD,$03 
  DC.B      $02,$FF,$FD,$01,$03,$00,$FD,$00 
  DC.B      $03,$00,$FD,$00,$02,$FE,$FD,$02 
  DC.B      $02,$FC,$FD,$04,$02,$F9,$FD,$07 
  DC.B      $02,$F5,$FD,$0B,$02,$F0,$FD,$10 
  DC.B      $02,$EB,$FD,$15,$02,$E4,$FD,$1C 
  DC.B      $02,$DC,$FD,'$',$02,$D4,$FD,',' 
  DC.B      $02,$CB,$FD,'5',$02,$C0,$FD,'@' 
  DC.B      $02,$B5,$FD,'K',$02,$A9,$FD,'W' 
  DC.B      $02,$9D,$FD,'c',$02,$8F,$FD,'q' 
  DC.B      $02,$81,$FD,$7F,$02,'r',$FD,$8E 
  DC.B      $02,'b',$FD,$9E,$02,'R',$FD,$AE 
  DC.B      $02,'A',$FD,$BF,$02,'/',$FD,$D1 
  DC.B      $02,$1D,$FD,$E3,$02,$0A,$FD,$F6 
  DC.B      $01,$F6,$FE,$0A,$01,$E2,$FE,$1E 
  DC.B      $01,$CD,$FE,'3',$01,$B8,$FE,'H' 
  DC.B      $01,$A2,$FE,'^',$01,$8C,$FE,'t' 
  DC.B      $01,'u',$FE,$8B,$01,'^',$FE,$A2 
  DC.B      $01,'F',$FE,$BA,$01,'.',$FE,$D2 
  DC.B      $01,$16,$FE,$EA,$00,$FE,$FF,$02 
  DC.B      $00,$E5,$FF,$1B,$00,$CC,$FF,'4' 
  DC.B      $00,$B3,$FF,'M',$00,$99,$FF,'g' 
  DC.B      $00,$80,$FF,$80,$00,'f',$FF,$9A 
  DC.B      $00,'M',$FF,$B3,$00,'3',$FF,$CD 
  DC.B      $00,$19,$FF,$E7,$00,$00,$00,$00 
  DC.B      $FF,$E7,$00,$19,$FF,$CD,$00,'3' 
  DC.B      $FF,$B4,$00,'L',$FF,$9A,$00,'f' 
  DC.B      $FF,$81,$00,$7F,$FF,'h',$00,$98 
  DC.B      $FF,'P',$00,$B0,$FF,'7',$00,$C9 
  DC.B      $FF,$1F,$00,$E1,$FF,$07,$00,$F9 
  DC.B      $FE,$F0,$01,$10,$FE,$D9,$01,$27 
  DC.B      $FE,$C2,$01,'>',$FE,$AC,$01,'T' 
  DC.B      $FE,$96,$01,'j',$FE,$81,$01,$7F 
  DC.B      $FE,'l',$01,$94,$FE,'W',$01,$A9 
  DC.B      $FE,'D',$01,$BC,$FE,'1',$01,$CF 
  DC.B      $FE,$1E,$01,$E2,$FE,$0C,$01,$F4 
  DC.B      $FD,$FB,$02,$05,$FD,$EA,$02,$16 
  DC.B      $FD,$DA,$02,'&',$FD,$CB,$02,'5' 
  DC.B      $FD,$BD,$02,'C',$FD,$AF,$02,'Q' 
  DC.B      $FD,$A2,$02,'^',$FD,$96,$02,'j' 
  DC.B      $FD,$8A,$02,'v',$FD,$7F,$02,$81 
  DC.B      $FD,'v',$02,$8A,$FD,'m',$02,$93 
  DC.B      $FD,'d',$02,$9C,$FD,']',$02,$A3 
  DC.B      $FD,'V',$02,$AA,$FD,'Q',$02,$AF 
  DC.B      $FD,'L',$02,$B4,$FD,'H',$02,$B8 
  DC.B      $FD,'E',$02,$BB,$FD,'B',$02,$BE 
  DC.B      $FD,'A',$02,$BF,$FD,'@',$02,$C0 
  DC.B      $FD,'@',$02,$C0,$FD,'B',$02,$BE 
  DC.B      $FD,'D',$02,$BC,$FD,'F',$02,$BA 
  DC.B      $FD,'J',$02,$B6,$FD,'O',$02,$B1 
  DC.B      $FD,'T',$02,$AC,$FD,'Z',$02,$A6 
  DC.B      $FD,'a',$02,$9F,$FD,'i',$02,$97 
  DC.B      $FD,'r',$02,$8E,$FD,'{',$02,$85 
  DC.B      $FD,$85,$02,'{',$FD,$90,$02,'p' 
  DC.B      $FD,$9C,$02,'d',$FD,$A8,$02,'X' 
  DC.B      $FD,$B5,$02,'K',$FD,$C3,$02,'=' 
  DC.B      $FD,$D1,$02,'/',$FD,$E0,$02,' ' 
  DC.B      $FD,$F0,$02,$10,$FE,$00,$02,$00 
  DC.B      $FE,$11,$01,$EF,$FE,'#',$01,$DD 
  DC.B      $FE,'5',$01,$CB,$FE,'G',$01,$B9 
  DC.B      $FE,'Z',$01,$A6,$FE,'n',$01,$92 
  DC.B      $FE,$82,$01,'~',$FE,$96,$01,'j' 
  DC.B      $FE,$AB,$01,'U',$FE,$C0,$01,'@' 
  DC.B      $FE,$D6,$01,'*',$FE,$EC,$01,$14 
  DC.B      $FF,$02,$00,$FE,$FF,$18,$00,$E8 
  DC.B      $FF,'/',$00,$D1,$FF,'F',$00,$BA 
  DC.B      $FF,']',$00,$A3,$FF,'t',$00,$8C 
  DC.B      $FF,$8B,$00,'u',$FF,$A3,$00,']' 
  DC.B      $FF,$BA,$00,'F',$FF,$D2,$00,'.' 
  DC.B      $FF,$E9,$00,$17,$00,$00,$00,$00 
  DC.B      $00,$17,$FF,$E9,$00,'.',$FF,$D2 
  DC.B      $00,'F',$FF,$BA,$00,']',$FF,$A3 
  DC.B      $00,'t',$FF,$8C,$00,$8A,$FF,'v' 
  DC.B      $00,$A1,$FF,'_',$00,$B7,$FF,'I' 
  DC.B      $00,$CD,$FF,'3',$00,$E3,$FF,$1D 
  DC.B      $00,$F8,$FF,$08,$01,$0D,$FE,$F3 
  DC.B      $01,'"',$FE,$DE,$01,'6',$FE,$CA 
  DC.B      $01,'J',$FE,$B6,$01,'^',$FE,$A2 
  DC.B      $01,'q',$FE,$8F,$01,$83,$FE,'}' 
  DC.B      $01,$95,$FE,'k',$01,$A6,$FE,'Z' 
  DC.B      $01,$B7,$FE,'I',$01,$C7,$FE,'9' 
  DC.B      $01,$D7,$FE,')',$01,$E6,$FE,$1A 
  DC.B      $01,$F5,$FE,$0B,$02,$02,$FD,$FE 
  DC.B      $02,$10,$FD,$F0,$02,$1C,$FD,$E4 
  DC.B      $02,'(',$FD,$D8,$02,'3',$FD,$CD 
  DC.B      $02,'=',$FD,$C3,$02,'G',$FD,$B9 
  DC.B      $02,'P',$FD,$B0,$02,'X',$FD,$A8 
  DC.B      $02,'`',$FD,$A0,$02,'f',$FD,$9A 
  DC.B      $02,'l',$FD,$94,$02,'q',$FD,$8F 
  DC.B      $02,'v',$FD,$8A,$02,'y',$FD,$87 
  DC.B      $02,'|',$FD,$84,$02,'~',$FD,$82 
  DC.B      $02,$7F,$FD,$81,$02,$80,$FD,$80 
  DC.B      $02,$80,$FD,$80,$02,'~',$FD,$82 
  DC.B      $02,'}',$FD,$83,$02,'z',$FD,$86 
  DC.B      $02,'v',$FD,$8A,$02,'r',$FD,$8E 
  DC.B      $02,'m',$FD,$93,$02,'h',$FD,$98 
  DC.B      $02,'a',$FD,$9F,$02,'Z',$FD,$A6 
  DC.B      $02,'R',$FD,$AE,$02,'J',$FD,$B6 
  DC.B      $02,'@',$FD,$C0,$02,'6',$FD,$CA 
  DC.B      $02,',',$FD,$D4,$02,'!',$FD,$DF 
  DC.B      $02,$15,$FD,$EB,$02,$08,$FD,$F8 
  DC.B      $01,$FB,$FE,$05,$01,$ED,$FE,$13 
  DC.B      $01,$DF,$FE,'!',$01,$D0,$FE,'0' 
  DC.B      $01,$C1,$FE,'?',$01,$B1,$FE,'O' 
  DC.B      $01,$A0,$FE,'`',$01,$8F,$FE,'q' 
  DC.B      $01,'~',$FE,$82,$01,'l',$FE,$94 
  DC.B      $01,'Z',$FE,$A6,$01,'H',$FE,$B8 
  DC.B      $01,'5',$FE,$CB,$01,'"',$FE,$DE 
  DC.B      $01,$0E,$FE,$F2,$00,$FA,$FF,$06 
  DC.B      $00,$E6,$FF,$1A,$00,$D2,$FF,'.' 
  DC.B      $00,$BD,$FF,'C',$00,$A9,$FF,'W' 
  DC.B      $00,$94,$FF,'l',$00,$7F,$FF,$81 
  DC.B      $00,'j',$FF,$96,$00,'U',$FF,$AB 
  DC.B      $00,'?',$FF,$C1,$00,'*',$FF,$D6 
  DC.B      $00,$15,$FF,$EB,$00,$00,$00,$00 
  DC.B      $FF,$EB,$00,$15,$FF,$D6,$00,'*' 
  DC.B      $FF,$C1,$00,'?',$FF,$AC,$00,'T' 
  DC.B      $FF,$98,$00,'h',$FF,$83,$00,'}' 
  DC.B      $FF,'o',$00,$91,$FF,'Z',$00,$A6 
  DC.B      $FF,'G',$00,$B9,$FF,'3',$00,$CD 
  DC.B      $FF,' ',$00,$E0,$FF,$0D,$00,$F3 
  DC.B      $FE,$FA,$01,$06,$FE,$E8,$01,$18 
  DC.B      $FE,$D6,$01,'*',$FE,$C4,$01,'<' 
  DC.B      $FE,$B3,$01,'M',$FE,$A3,$01,']' 
  DC.B      $FE,$92,$01,'n',$FE,$83,$01,'}' 
  DC.B      $FE,'t',$01,$8C,$FE,'e',$01,$9B 
  DC.B      $FE,'W',$01,$A9,$FE,'I',$01,$B7 
  DC.B      $FE,'<',$01,$C4,$FE,'0',$01,$D0 
  DC.B      $FE,'$',$01,$DC,$FE,$19,$01,$E7 
  DC.B      $FE,$0E,$01,$F2,$FE,$04,$01,$FC 
  DC.B      $FD,$FB,$02,$05,$FD,$F2,$02,$0E 
  DC.B      $FD,$EB,$02,$15,$FD,$E3,$02,$1D 
  DC.B      $FD,$DD,$02,'#',$FD,$D7,$02,')' 
  DC.B      $FD,$D1,$02,'/',$FD,$CD,$02,'3' 
  DC.B      $FD,$C9,$02,'7',$FD,$C6,$02,':' 
  DC.B      $FD,$C3,$02,'=',$FD,$C2,$02,'>' 
  DC.B      $FD,$C0,$02,'@',$FD,$C0,$02,'@' 
  DC.B      $FD,$C0,$02,'@',$FD,$C2,$02,'>' 
  DC.B      $FD,$C3,$02,'=',$FD,$C6,$02,':' 
  DC.B      $FD,$C9,$02,'7',$FD,$CD,$02,'3' 
  DC.B      $FD,$D1,$02,'/',$FD,$D6,$02,'*' 
  DC.B      $FD,$DC,$02,'$',$FD,$E3,$02,$1D 
  DC.B      $FD,$EA,$02,$16,$FD,$F2,$02,$0E 
  DC.B      $FD,$FA,$02,$06,$FE,$03,$01,$FD 
  DC.B      $FE,$0D,$01,$F3,$FE,$17,$01,$E9 
  DC.B      $FE,'"',$01,$DE,$FE,'-',$01,$D3 
  DC.B      $FE,'9',$01,$C7,$FE,'E',$01,$BB 
  DC.B      $FE,'R',$01,$AE,$FE,'`',$01,$A0 
  DC.B      $FE,'m',$01,$93,$FE,'|',$01,$84 
  DC.B      $FE,$8B,$01,'u',$FE,$9A,$01,'f' 
  DC.B      $FE,$A9,$01,'W',$FE,$B9,$01,'G' 
  DC.B      $FE,$CA,$01,'6',$FE,$DA,$01,'&' 
  DC.B      $FE,$EB,$01,$15,$FE,$FC,$01,$04 
  DC.B      $FF,$0E,$00,$F2,$FF,' ',$00,$E0 
  DC.B      $FF,'2',$00,$CE,$FF,'D',$00,$BC 
  DC.B      $FF,'V',$00,$AA,$FF,'i',$00,$97 
  DC.B      $FF,'|',$00,$84,$FF,$8F,$00,'q' 
  DC.B      $FF,$A1,$00,'_',$FF,$B4,$00,'L' 
  DC.B      $FF,$C7,$00,'9',$FF,$DA,$00,'&' 
  DC.B      $FF,$ED,$00,$13,$00,$00,$00,$00 
  DC.B      $00,$12,$FF,$EE,$00,'%',$FF,$DB 
  DC.B      $00,'8',$FF,$C8,$00,'K',$FF,$B5 
  DC.B      $00,']',$FF,$A3,$00,'p',$FF,$90 
  DC.B      $00,$82,$FF,'~',$00,$94,$FF,'l' 
  DC.B      $00,$A6,$FF,'Z',$00,$B7,$FF,'I' 
  DC.B      $00,$C8,$FF,'8',$00,$D9,$FF,$27 
  DC.B      $00,$EA,$FF,$16,$00,$FA,$FF,$06 
  DC.B      $01,$0A,$FE,$F6,$01,$1A,$FE,$E6 
  DC.B      $01,')',$FE,$D7,$01,'8',$FE,$C8 
  DC.B      $01,'F',$FE,$BA,$01,'T',$FE,$AC 
  DC.B      $01,'b',$FE,$9E,$01,'o',$FE,$91 
  DC.B      $01,'{',$FE,$85,$01,$87,$FE,'y' 
  DC.B      $01,$93,$FE,'m',$01,$9E,$FE,'b' 
  DC.B      $01,$A8,$FE,'X',$01,$B2,$FE,'N' 
  DC.B      $01,$BB,$FE,'E',$01,$C4,$FE,'<' 
  DC.B      $01,$CC,$FE,'4',$01,$D4,$FE,',' 
  DC.B      $01,$DB,$FE,'%',$01,$E1,$FE,$1F 
  DC.B      $01,$E7,$FE,$19,$01,$ED,$FE,$13 
  DC.B      $01,$F1,$FE,$0F,$01,$F5,$FE,$0B 
  DC.B      $01,$F8,$FE,$08,$01,$FB,$FE,$05 
  DC.B      $01,$FD,$FE,$03,$01,$FF,$FE,$01 
  DC.B      $02,$00,$FE,$00,$02,$00,$FE,$00 
  DC.B      $02,$00,$FE,$00,$01,$FE,$FE,$02 
  DC.B      $01,$FD,$FE,$03,$01,$FB,$FE,$05 
  DC.B      $01,$F8,$FE,$08,$01,$F4,$FE,$0C 
  DC.B      $01,$F0,$FE,$10,$01,$EB,$FE,$15 
  DC.B      $01,$E6,$FE,$1A,$01,$E0,$FE,' ' 
  DC.B      $01,$DA,$FE,'&',$01,$D3,$FE,'-' 
  DC.B      $01,$CB,$FE,'5',$01,$C3,$FE,'=' 
  DC.B      $01,$BB,$FE,'E',$01,$B2,$FE,'N' 
  DC.B      $01,$A8,$FE,'X',$01,$9E,$FE,'b' 
  DC.B      $01,$93,$FE,'m',$01,$88,$FE,'x' 
  DC.B      $01,'}',$FE,$83,$01,'q',$FE,$8F 
  DC.B      $01,'e',$FE,$9B,$01,'X',$FE,$A8 
  DC.B      $01,'K',$FE,$B5,$01,'=',$FE,$C3 
  DC.B      $01,'/',$FE,$D1,$01,'!',$FE,$DF 
  DC.B      $01,$13,$FE,$ED,$01,$04,$FE,$FC 
  DC.B      $00,$F5,$FF,$0B,$00,$E6,$FF,$1A 
  DC.B      $00,$D6,$FF,'*',$00,$C6,$FF,':' 
  DC.B      $00,$B6,$FF,'J',$00,$A6,$FF,'Z' 
  DC.B      $00,$96,$FF,'j',$00,$85,$FF,'{' 
  DC.B      $00,'u',$FF,$8B,$00,'d',$FF,$9C 
  DC.B      $00,'S',$FF,$AD,$00,'C',$FF,$BD 
  DC.B      $00,'2',$FF,$CE,$00,'!',$FF,$DF 
  DC.B      $00,$10,$FF,$F0,$00,$00,$00,$00 
  DC.B      $FF,$F0,$00,$10,$FF,$DF,$00,'!' 
  DC.B      $FF,$CF,$00,'1',$FF,$BE,$00,'B' 
  DC.B      $FF,$AE,$00,'R',$FF,$9E,$00,'b' 
  DC.B      $FF,$8E,$00,'r',$FF,'~',$00,$82 
  DC.B      $FF,'n',$00,$92,$FF,'_',$00,$A1 
  DC.B      $FF,'P',$00,$B0,$FF,'A',$00,$BF 
  DC.B      $FF,'2',$00,$CE,$FF,'$',$00,$DC 
  DC.B      $FF,$16,$00,$EA,$FF,$08,$00,$F8 
  DC.B      $FE,$FB,$01,$05,$FE,$EE,$01,$12 
  DC.B      $FE,$E1,$01,$1F,$FE,$D5,$01,'+' 
  DC.B      $FE,$C9,$01,'7',$FE,$BE,$01,'B' 
  DC.B      $FE,$B3,$01,'M',$FE,$A8,$01,'X' 
  DC.B      $FE,$9E,$01,'b',$FE,$95,$01,'k' 
  DC.B      $FE,$8C,$01,'t',$FE,$83,$01,'}' 
  DC.B      $FE,'{',$01,$85,$FE,'s',$01,$8D 
  DC.B      $FE,'l',$01,$94,$FE,'f',$01,$9A 
  DC.B      $FE,'_',$01,$A1,$FE,'Z',$01,$A6 
  DC.B      $FE,'U',$01,$AB,$FE,'P',$01,$B0 
  DC.B      $FE,'L',$01,$B4,$FE,'I',$01,$B7 
  DC.B      $FE,'F',$01,$BA,$FE,'D',$01,$BC 
  DC.B      $FE,'B',$01,$BE,$FE,'A',$01,$BF 
  DC.B      $FE,'@',$01,$C0,$FE,'@',$01,$C0 
  DC.B      $FE,'@',$01,$C0,$FE,'A',$01,$BF 
  DC.B      $FE,'C',$01,$BD,$FE,'E',$01,$BB 
  DC.B      $FE,'H',$01,$B8,$FE,'K',$01,$B5 
  DC.B      $FE,'N',$01,$B2,$FE,'S',$01,$AD 
  DC.B      $FE,'W',$01,$A9,$FE,']',$01,$A3 
  DC.B      $FE,'b',$01,$9E,$FE,'h',$01,$98 
  DC.B      $FE,'o',$01,$91,$FE,'v',$01,$8A 
  DC.B      $FE,'~',$01,$82,$FE,$86,$01,'z' 
  DC.B      $FE,$8E,$01,'r',$FE,$97,$01,'i' 
  DC.B      $FE,$A0,$01,'`',$FE,$AA,$01,'V' 
  DC.B      $FE,$B4,$01,'L',$FE,$BF,$01,'A' 
  DC.B      $FE,$C9,$01,'7',$FE,$D5,$01,'+' 
  DC.B      $FE,$E0,$01,' ',$FE,$EC,$01,$14 
  DC.B      $FE,$F8,$01,$08,$FF,$04,$00,$FC 
  DC.B      $FF,$11,$00,$EF,$FF,$1E,$00,$E2 
  DC.B      $FF,'+',$00,$D5,$FF,'9',$00,$C7 
  DC.B      $FF,'F',$00,$BA,$FF,'T',$00,$AC 
  DC.B      $FF,'b',$00,$9E,$FF,'p',$00,$90 
  DC.B      $FF,'~',$00,$82,$FF,$8C,$00,'t' 
  DC.B      $FF,$9B,$00,'e',$FF,$A9,$00,'W' 
  DC.B      $FF,$B8,$00,'H',$FF,$C6,$00,':' 
  DC.B      $FF,$D5,$00,'+',$FF,$E3,$00,$1D 
  DC.B      $FF,$F2,$00,$0E,$00,$00,$00,$00 
  DC.B      $00,$0E,$FF,$F2,$00,$1C,$FF,$E4 
  DC.B      $00,'+',$FF,$D5,$00,'9',$FF,$C7 
  DC.B      $00,'G',$FF,$B9,$00,'U',$FF,$AB 
  DC.B      $00,'c',$FF,$9D,$00,'q',$FF,$8F 
  DC.B      $00,'~',$FF,$82,$00,$8B,$FF,'u' 
  DC.B      $00,$98,$FF,'h',$00,$A5,$FF,'[' 
  DC.B      $00,$B2,$FF,'N',$00,$BE,$FF,'B' 
  DC.B      $00,$CA,$FF,'6',$00,$D6,$FF,'*' 
  DC.B      $00,$E1,$FF,$1F,$00,$EC,$FF,$14 
  DC.B      $00,$F7,$FF,$09,$01,$02,$FE,$FE 
  DC.B      $01,$0C,$FE,$F4,$01,$16,$FE,$EA 
  DC.B      $01,$1F,$FE,$E1,$01,'(',$FE,$D8 
  DC.B      $01,'1',$FE,$CF,$01,'9',$FE,$C7 
  DC.B      $01,'A',$FE,$BF,$01,'H',$FE,$B8 
  DC.B      $01,'O',$FE,$B1,$01,'U',$FE,$AB 
  DC.B      $01,'[',$FE,$A5,$01,'a',$FE,$9F 
  DC.B      $01,'f',$FE,$9A,$01,'k',$FE,$95 
  DC.B      $01,'o',$FE,$91,$01,'s',$FE,$8D 
  DC.B      $01,'v',$FE,$8A,$01,'y',$FE,$87 
  DC.B      $01,'{',$FE,$85,$01,'}',$FE,$83 
  DC.B      $01,$7F,$FE,$81,$01,$80,$FE,$80 
  DC.B      $01,$80,$FE,$80,$01,$80,$FE,$80 
  DC.B      $01,$80,$FE,$80,$01,$7F,$FE,$81 
  DC.B      $01,'}',$FE,$83,$01,'{',$FE,$85 
  DC.B      $01,'y',$FE,$87,$01,'v',$FE,$8A 
  DC.B      $01,'s',$FE,$8D,$01,'o',$FE,$91 
  DC.B      $01,'k',$FE,$95,$01,'g',$FE,$99 
  DC.B      $01,'b',$FE,$9E,$01,'\',$FE,$A4 
  DC.B      $01,'W',$FE,$A9,$01,'P',$FE,$B0 
  DC.B      $01,'J',$FE,$B6,$01,'C',$FE,$BD 
  DC.B      $01,'<',$FE,$C4,$01,'4',$FE,$CC 
  DC.B      $01,',',$FE,$D4,$01,'#',$FE,$DD 
  DC.B      $01,$1B,$FE,$E5,$01,$12,$FE,$EE 
  DC.B      $01,$08,$FE,$F8,$00,$FF,$FF,$01 
  DC.B      $00,$F5,$FF,$0B,$00,$EB,$FF,$15 
  DC.B      $00,$E1,$FF,$1F,$00,$D6,$FF,'*' 
  DC.B      $00,$CB,$FF,'5',$00,$C0,$FF,'@' 
  DC.B      $00,$B5,$FF,'K',$00,$A9,$FF,'W' 
  DC.B      $00,$9E,$FF,'b',$00,$92,$FF,'n' 
  DC.B      $00,$86,$FF,'z',$00,'z',$FF,$86 
  DC.B      $00,'n',$FF,$92,$00,'b',$FF,$9E 
  DC.B      $00,'V',$FF,$AA,$00,'J',$FF,$B6 
  DC.B      $00,'=',$FF,$C3,$00,'1',$FF,$CF 
  DC.B      $00,'%',$FF,$DB,$00,$18,$FF,$E8 
  DC.B      $00,$0C,$FF,$F4,$00,$00,$00,$00 
  DC.B      $FF,$F4,$00,$0C,$FF,$E8,$00,$18 
  DC.B      $FF,$DC,$00,'$',$FF,$D0,$00,'0' 
  DC.B      $FF,$C4,$00,'<',$FF,$B8,$00,'H' 
  DC.B      $FF,$AD,$00,'S',$FF,$A1,$00,'_' 
  DC.B      $FF,$96,$00,'j',$FF,$8B,$00,'u' 
  DC.B      $FF,$80,$00,$80,$FF,'u',$00,$8B 
  DC.B      $FF,'j',$00,$96,$FF,'`',$00,$A0 
  DC.B      $FF,'V',$00,$AA,$FF,'L',$00,$B4 
  DC.B      $FF,'B',$00,$BE,$FF,'9',$00,$C7 
  DC.B      $FF,'0',$00,$D0,$FF,$27,$00,$D9 
  DC.B      $FF,$1F,$00,$E1,$FF,$17,$00,$E9 
  DC.B      $FF,$0F,$00,$F1,$FF,$08,$00,$F8 
  DC.B      $FF,$00,$01,$00,$FE,$FA,$01,$06 
  DC.B      $FE,$F3,$01,$0D,$FE,$ED,$01,$13 
  DC.B      $FE,$E7,$01,$19,$FE,$E2,$01,$1E 
  DC.B      $FE,$DD,$01,'#',$FE,$D9,$01,$27 
  DC.B      $FE,$D4,$01,',',$FE,$D1,$01,'/' 
  DC.B      $FE,$CD,$01,'3',$FE,$CA,$01,'6' 
  DC.B      $FE,$C7,$01,'9',$FE,$C5,$01,';' 
  DC.B      $FE,$C3,$01,'=',$FE,$C2,$01,'>' 
  DC.B      $FE,$C1,$01,'?',$FE,$C0,$01,'@' 
  DC.B      $FE,$C0,$01,'@',$FE,$C0,$01,'@' 
  DC.B      $FE,$C0,$01,'@',$FE,$C1,$01,'?' 
  DC.B      $FE,$C3,$01,'=',$FE,$C4,$01,'<' 
  DC.B      $FE,$C6,$01,':',$FE,$C9,$01,'7' 
  DC.B      $FE,$CC,$01,'4',$FE,$CF,$01,'1' 
  DC.B      $FE,$D2,$01,'.',$FE,$D6,$01,'*' 
  DC.B      $FE,$DA,$01,'&',$FE,$DF,$01,'!' 
  DC.B      $FE,$E4,$01,$1C,$FE,$E9,$01,$17 
  DC.B      $FE,$EF,$01,$11,$FE,$F5,$01,$0B 
  DC.B      $FE,$FB,$01,$05,$FF,$01,$00,$FF 
  DC.B      $FF,$08,$00,$F8,$FF,$0F,$00,$F1 
  DC.B      $FF,$16,$00,$EA,$FF,$1E,$00,$E2 
  DC.B      $FF,'&',$00,$DA,$FF,'.',$00,$D2 
  DC.B      $FF,'6',$00,$CA,$FF,'>',$00,$C2 
  DC.B      $FF,'G',$00,$B9,$FF,'P',$00,$B0 
  DC.B      $FF,'Y',$00,$A7,$FF,'b',$00,$9E 
  DC.B      $FF,'k',$00,$95,$FF,'u',$00,$8B 
  DC.B      $FF,'~',$00,$82,$FF,$88,$00,'x' 
  DC.B      $FF,$92,$00,'n',$FF,$9C,$00,'d' 
  DC.B      $FF,$A6,$00,'Z',$FF,$B0,$00,'P' 
  DC.B      $FF,$BA,$00,'F',$FF,$C4,$00,'<' 
  DC.B      $FF,$CE,$00,'2',$FF,$D8,$00,'(' 
  DC.B      $FF,$E2,$00,$1E,$FF,$EC,$00,$14 
  DC.B      $FF,$F6,$00,$0A,$00,$00,$00,$00 
  DC.B      $00,$0A,$FF,$F6,$00,$13,$FF,$ED 
  DC.B      $00,$1D,$FF,$E3,$00,$27,$FF,$D9 
  DC.B      $00,'1',$FF,$CF,$00,':',$FF,$C6 
  DC.B      $00,'D',$FF,$BC,$00,'M',$FF,$B3 
  DC.B      $00,'W',$FF,$A9,$00,'`',$FF,$A0 
  DC.B      $00,'h',$FF,$98,$00,'q',$FF,$8F 
  DC.B      $00,'z',$FF,$86,$00,$82,$FF,'~' 
  DC.B      $00,$8A,$FF,'v',$00,$92,$FF,'n' 
  DC.B      $00,$9A,$FF,'f',$00,$A1,$FF,'_' 
  DC.B      $00,$A8,$FF,'X',$00,$AF,$FF,'Q' 
  DC.B      $00,$B6,$FF,'J',$00,$BD,$FF,'C' 
  DC.B      $00,$C3,$FF,'=',$00,$C9,$FF,'7' 
  DC.B      $00,$CF,$FF,'1',$00,$D4,$FF,',' 
  DC.B      $00,$D9,$FF,$27,$00,$DE,$FF,'"' 
  DC.B      $00,$E2,$FF,$1E,$00,$E6,$FF,$1A 
  DC.B      $00,$EA,$FF,$16,$00,$EE,$FF,$12 
  DC.B      $00,$F1,$FF,$0F,$00,$F4,$FF,$0C 
  DC.B      $00,$F7,$FF,$09,$00,$F9,$FF,$07 
  DC.B      $00,$FB,$FF,$05,$00,$FD,$FF,$03 
  DC.B      $00,$FE,$FF,$02,$00,$FF,$FF,$01 
  DC.B      $01,$00,$FF,$00,$01,$00,$FF,$00 
  DC.B      $01,$00,$FF,$00,$01,$00,$FF,$00 
  DC.B      $01,$00,$FF,$00,$00,$FF,$FF,$01 
  DC.B      $00,$FD,$FF,$03,$00,$FC,$FF,$04 
  DC.B      $00,$FA,$FF,$06,$00,$F8,$FF,$08 
  DC.B      $00,$F6,$FF,$0A,$00,$F3,$FF,$0D 
  DC.B      $00,$F0,$FF,$10,$00,$ED,$FF,$13 
  DC.B      $00,$E9,$FF,$17,$00,$E6,$FF,$1A 
  DC.B      $00,$E2,$FF,$1E,$00,$DD,$FF,'#' 
  DC.B      $00,$D9,$FF,$27,$00,$D4,$FF,',' 
  DC.B      $00,$CF,$FF,'1',$00,$CA,$FF,'6' 
  DC.B      $00,$C4,$FF,'<',$00,$BF,$FF,'A' 
  DC.B      $00,$B9,$FF,'G',$00,$B3,$FF,'M' 
  DC.B      $00,$AC,$FF,'T',$00,$A6,$FF,'Z' 
  DC.B      $00,$9F,$FF,'a',$00,$99,$FF,'g' 
  DC.B      $00,$92,$FF,'n',$00,$8B,$FF,'u' 
  DC.B      $00,$84,$FF,'|',$00,'|',$FF,$84 
  DC.B      $00,'u',$FF,$8B,$00,'m',$FF,$93 
  DC.B      $00,'f',$FF,$9A,$00,'^',$FF,$A2 
  DC.B      $00,'V',$FF,$AA,$00,'O',$FF,$B1 
  DC.B      $00,'G',$FF,$B9,$00,'?',$FF,$C1 
  DC.B      $00,'7',$FF,$C9,$00,'/',$FF,$D1 
  DC.B      $00,$27,$FF,$D9,$00,$1F,$FF,$E1 
  DC.B      $00,$17,$FF,$E9,$00,$0F,$FF,$F1 
  DC.B      $00,$07,$FF,$F9,$00,$00,$00,$00 
  DC.B      $FF,$F9,$00,$07,$FF,$F1,$00,$0F 
  DC.B      $FF,$E9,$00,$17,$FF,$E2,$00,$1E 
  DC.B      $FF,$DA,$00,'&',$FF,$D3,$00,'-' 
  DC.B      $FF,$CC,$00,'4',$FF,$C4,$00,'<' 
  DC.B      $FF,$BD,$00,'C',$FF,$B6,$00,'J' 
  DC.B      $FF,$B0,$00,'P',$FF,$A9,$00,'W' 
  DC.B      $FF,$A2,$00,'^',$FF,$9C,$00,'d' 
  DC.B      $FF,$96,$00,'j',$FF,$90,$00,'p' 
  DC.B      $FF,$8A,$00,'v',$FF,$84,$00,'|' 
  DC.B      $FF,$7F,$00,$81,$FF,'z',$00,$86 
  DC.B      $FF,'u',$00,$8B,$FF,'p',$00,$90 
  DC.B      $FF,'k',$00,$95,$FF,'g',$00,$99 
  DC.B      $FF,'c',$00,$9D,$FF,'_',$00,$A1 
  DC.B      $FF,'[',$00,$A5,$FF,'W',$00,$A9 
  DC.B      $FF,'T',$00,$AC,$FF,'Q',$00,$AF 
  DC.B      $FF,'N',$00,$B2,$FF,'L',$00,$B4 
  DC.B      $FF,'I',$00,$B7,$FF,'G',$00,$B9 
  DC.B      $FF,'E',$00,$BB,$FF,'D',$00,$BC 
  DC.B      $FF,'B',$00,$BE,$FF,'A',$00,$BF 
  DC.B      $FF,'A',$00,$BF,$FF,'@',$00,$C0 
  DC.B      $FF,'@',$00,$C0,$FF,'?',$00,$C1 
  DC.B      $FF,'@',$00,$C0,$FF,'@',$00,$C0 
  DC.B      $FF,'@',$00,$C0,$FF,'A',$00,$BF 
  DC.B      $FF,'B',$00,$BE,$FF,'D',$00,$BC 
  DC.B      $FF,'E',$00,$BB,$FF,'G',$00,$B9 
  DC.B      $FF,'I',$00,$B7,$FF,'K',$00,$B5 
  DC.B      $FF,'M',$00,$B3,$FF,'P',$00,$B0 
  DC.B      $FF,'S',$00,$AD,$FF,'V',$00,$AA 
  DC.B      $FF,'Y',$00,$A7,$FF,'\',$00,$A4 
  DC.B      $FF,'`',$00,$A0,$FF,'c',$00,$9D 
  DC.B      $FF,'g',$00,$99,$FF,'k',$00,$95 
  DC.B      $FF,'p',$00,$90,$FF,'t',$00,$8C 
  DC.B      $FF,'x',$00,$88,$FF,'}',$00,$83 
  DC.B      $FF,$82,$00,'~',$FF,$86,$00,'z' 
  DC.B      $FF,$8B,$00,'u',$FF,$91,$00,'o' 
  DC.B      $FF,$96,$00,'j',$FF,$9B,$00,'e' 
  DC.B      $FF,$A0,$00,'`',$FF,$A6,$00,'Z' 
  DC.B      $FF,$AB,$00,'U',$FF,$B1,$00,'O' 
  DC.B      $FF,$B6,$00,'J',$FF,$BC,$00,'D' 
  DC.B      $FF,$C2,$00,'>',$FF,$C7,$00,'9' 
  DC.B      $FF,$CD,$00,'3',$FF,$D3,$00,'-' 
  DC.B      $FF,$D9,$00,$27,$FF,$DE,$00,'"' 
  DC.B      $FF,$E4,$00,$1C,$FF,$EA,$00,$16 
  DC.B      $FF,$F0,$00,$10,$FF,$F5,$00,$0B 
  DC.B      $FF,$FB,$00,$05,$00,$00,$00,$00 
  DC.B      $00,$05,$FF,$FB,$00,$0B,$FF,$F5 
  DC.B      $00,$10,$FF,$F0,$00,$15,$FF,$EB 
  DC.B      $00,$1B,$FF,$E5,$00,' ',$FF,$E0 
  DC.B      $00,'%',$FF,$DB,$00,'*',$FF,$D6 
  DC.B      $00,'/',$FF,$D1,$00,'4',$FF,$CC 
  DC.B      $00,'9',$FF,$C7,$00,'=',$FF,$C3 
  DC.B      $00,'B',$FF,$BE,$00,'F',$FF,$BA 
  DC.B      $00,'J',$FF,$B6,$00,'N',$FF,$B2 
  DC.B      $00,'R',$FF,$AE,$00,'V',$FF,$AA 
  DC.B      $00,'Z',$FF,$A6,$00,']',$FF,$A3 
  DC.B      $00,'a',$FF,$9F,$00,'d',$FF,$9C 
  DC.B      $00,'g',$FF,$99,$00,'j',$FF,$96 
  DC.B      $00,'l',$FF,$94,$00,'o',$FF,$91 
  DC.B      $00,'q',$FF,$8F,$00,'t',$FF,$8C 
  DC.B      $00,'v',$FF,$8A,$00,'x',$FF,$88 
  DC.B      $00,'y',$FF,$87,$00,'{',$FF,$85 
  DC.B      $00,'|',$FF,$84,$00,'}',$FF,$83 
  DC.B      $00,'~',$FF,$82,$00,$7F,$FF,$81 
  DC.B      $00,$80,$FF,$80,$00,$81,$FF,$7F 
  DC.B      $00,$81,$FF,$7F,$00,$81,$FF,$7F 
  DC.B      $00,$81,$FF,$7F,$00,$81,$FF,$7F 
  DC.B      $00,$81,$FF,$7F,$00,$80,$FF,$80 
  DC.B      $00,$80,$FF,$80,$00,$7F,$FF,$81 
  DC.B      $00,'~',$FF,$82,$00,'}',$FF,$83 
  DC.B      $00,'{',$FF,$85,$00,'z',$FF,$86 
  DC.B      $00,'y',$FF,$87,$00,'w',$FF,$89 
  DC.B      $00,'u',$FF,$8B,$00,'s',$FF,$8D 
  DC.B      $00,'q',$FF,$8F,$00,'o',$FF,$91 
  DC.B      $00,'m',$FF,$93,$00,'j',$FF,$96 
  DC.B      $00,'h',$FF,$98,$00,'e',$FF,$9B 
  DC.B      $00,'b',$FF,$9E,$00,'`',$FF,$A0 
  DC.B      $00,']',$FF,$A3,$00,'Z',$FF,$A6 
  DC.B      $00,'W',$FF,$A9,$00,'T',$FF,$AC 
  DC.B      $00,'P',$FF,$B0,$00,'M',$FF,$B3 
  DC.B      $00,'J',$FF,$B6,$00,'F',$FF,$BA 
  DC.B      $00,'C',$FF,$BD,$00,'?',$FF,$C1 
  DC.B      $00,'<',$FF,$C4,$00,'8',$FF,$C8 
  DC.B      $00,'5',$FF,$CB,$00,'1',$FF,$CF 
  DC.B      $00,'.',$FF,$D2,$00,'*',$FF,$D6 
  DC.B      $00,'&',$FF,$DA,$00,'#',$FF,$DD 
  DC.B      $00,$1F,$FF,$E1,$00,$1C,$FF,$E4 
  DC.B      $00,$18,$FF,$E8,$00,$14,$FF,$EC 
  DC.B      $00,$11,$FF,$EF,$00,$0D,$FF,$F3 
  DC.B      $00,$0A,$FF,$F6,$00,$06,$FF,$FA 
  DC.B      $00,$03,$FF,$FD,$00,$00,$00,$00 
  DC.B      $FF,$FD,$00,$03,$FF,$FA,$00,$06 
  DC.B      $FF,$F7,$00,$09,$FF,$F4,$00,$0C 
  DC.B      $FF,$F0,$00,$10,$FF,$ED,$00,$13 
  DC.B      $FF,$EA,$00,$16,$FF,$E8,$00,$18 
  DC.B      $FF,$E5,$00,$1B,$FF,$E2,$00,$1E 
  DC.B      $FF,$DF,$00,'!',$FF,$DD,$00,'#' 
  DC.B      $FF,$DA,$00,'&',$FF,$D8,$00,'(' 
  DC.B      $FF,$D6,$00,'*',$FF,$D4,$00,',' 
  DC.B      $FF,$D2,$00,'.',$FF,$D0,$00,'0' 
  DC.B      $FF,$CE,$00,'2',$FF,$CC,$00,'4' 
  DC.B      $FF,$CA,$00,'6',$FF,$C9,$00,'7' 
  DC.B      $FF,$C7,$00,'9',$FF,$C6,$00,':' 
  DC.B      $FF,$C5,$00,';',$FF,$C3,$00,'=' 
  DC.B      $FF,$C2,$00,'>',$FF,$C1,$00,'?' 
  DC.B      $FF,$C1,$00,'?',$FF,$C0,$00,'@' 
  DC.B      $FF,$BF,$00,'A',$FF,$BF,$00,'A' 
  DC.B      $FF,$BE,$00,'B',$FF,$BE,$00,'B' 
  DC.B      $FF,$BE,$00,'B',$FF,$BE,$00,'B' 
  DC.B      $FF,$BE,$00,'B',$FF,$BE,$00,'B' 
  DC.B      $FF,$BE,$00,'B',$FF,$BE,$00,'B' 
  DC.B      $FF,$BE,$00,'B',$FF,$BF,$00,'A' 
  DC.B      $FF,$BF,$00,'A',$FF,$C0,$00,'@' 
  DC.B      $FF,$C0,$00,'@',$FF,$C1,$00,'?' 
  DC.B      $FF,$C2,$00,'>',$FF,$C3,$00,'=' 
  DC.B      $FF,$C4,$00,'<',$FF,$C5,$00,';' 
  DC.B      $FF,$C6,$00,':',$FF,$C7,$00,'9' 
  DC.B      $FF,$C8,$00,'8',$FF,$CA,$00,'6' 
  DC.B      $FF,$CB,$00,'5',$FF,$CC,$00,'4' 
  DC.B      $FF,$CE,$00,'2',$FF,$CF,$00,'1' 
  DC.B      $FF,$D1,$00,'/',$FF,$D2,$00,'.' 
  DC.B      $FF,$D4,$00,',',$FF,$D5,$00,'+' 
  DC.B      $FF,$D7,$00,')',$FF,$D9,$00,$27 
  DC.B      $FF,$DA,$00,'&',$FF,$DC,$00,'$' 
  DC.B      $FF,$DE,$00,'"',$FF,$DF,$00,'!' 
  DC.B      $FF,$E1,$00,$1F,$FF,$E3,$00,$1D 
  DC.B      $FF,$E4,$00,$1C,$FF,$E6,$00,$1A 
  DC.B      $FF,$E8,$00,$18,$FF,$EA,$00,$16 
  DC.B      $FF,$EB,$00,$15,$FF,$ED,$00,$13 
  DC.B      $FF,$EE,$00,$12,$FF,$F0,$00,$10 
  DC.B      $FF,$F2,$00,$0E,$FF,$F3,$00,$0D 
  DC.B      $FF,$F5,$00,$0B,$FF,$F6,$00,$0A 
  DC.B      $FF,$F8,$00,$08,$FF,$F9,$00,$07 
  DC.B      $FF,$FA,$00,$06,$FF,$FC,$00,$04 
  DC.B      $FF,$FD,$00,$03,$FF,$FE,$00,$02 
  DC.B      $FF,$FF,$00,$01,$00,$00,$00,$00 
  DC.B      $00,$01,$FF,$FF,$00,$02,$FF,$FE 
  DC.B      $00,$03,$FF,$FD,$00,$04,$FF,$FC 
  DC.B      $00,$04,$FF,$FC,$00,$05,$FF,$FB 
  DC.B      $00,$06,$FF,$FA,$00,$07,$FF,$F9 
  DC.B      $00,$07,$FF,$F9,$00,$08,$FF,$F8 
  DC.B      $00,$09,$FF,$F7,$00,$09,$FF,$F7 
  DC.B      $00,$09,$FF,$F7,$00,$0A,$FF,$F6 
  DC.B      $00,$0A,$FF,$F6,$00,$0A,$FF,$F6 
  DC.B      $00,$0B,$FF,$F5,$00,$0B,$FF,$F5 
  DC.B      $00,$0B,$FF,$F5,$00,$0B,$FF,$F5 
  DC.B      $00,$0B,$FF,$F5,$00,$0B,$FF,$F5 
  DC.B      $00,$0B,$FF,$F5,$00,$0B,$FF,$F5 
  DC.B      $00,$0A,$FF,$F6,$00,$0A,$FF,$F6 
  DC.B      $00,$0A,$FF,$F6,$00,$0A,$FF,$F6 
  DC.B      $00,$09,$FF,$F7,$00,$09,$FF,$F7 
  DC.B      $00,$08,$FF,$F8,$00,$08,$FF,$F8 
  DC.B      $00,$07,$FF,$F9,$00,$07,$FF,$F9 
  DC.B      $00,$06,$FF,$FA,$00,$06,$FF,$FA 
  DC.B      $00,$05,$FF,$FB,$00,$04,$FF,$FC 
  DC.B      $00,$04,$FF,$FC,$00,$03,$FF,$FD 
  DC.B      $00,$02,$FF,$FE,$00,$02,$FF,$FE 
  DC.B      $00,$01,$FF,$FF,$00,$00,$00,$00 
  DCB.W     640,0 
L0119:
  DC.L      L021C 
  DC.L      L021D 
  DC.L      L021E 
; function key routine list
function_key_routs:
  DC.L      L011B 
  DC.L      L011C 
  DC.L      L011D 
  DC.L      L011E 
  DC.L      L011F 
  DC.L      L0120 
  DC.L      L0121 
  DC.L      L0122 
  DC.L      L0123 
  DC.L      L0124 
L011B:
	addq.w	#4,xrotspeed
	rts
L011C:
	subq.w	#4,xrotspeed
	rts
L011D:
  DC.B      $06,'y',$00,$04 
  DC.L      L0213 
  DC.B      'Nu'
L011E:
  DC.B      $04,'y',$00,$04 
  DC.L      L0213 
  DC.B      'Nu'
L011F:
  DC.B      $06,'y',$00,$04 
  DC.L      L0214 
  DC.B      'Nu'
L0120:
  DC.B      $04,'y',$00,$04 
  DC.L      L0214 
  DC.B      'Nu'
L0121:
  DC.B      $0A,'y',$00,$01 
  DC.L      L0204 
  DC.B      'Nu'
L0122:
  DC.B      'Jy'
  DC.L      L0209 
  DC.B      'g',$06,'a',$00,$9E,$86,'`',$04 
  DC.B      'a',$00,$9E,'>a',$00,$9D,$08
  DC.B      'Nu'
L0123:
  DC.B      $06,'y',$00,$04 
  DC.L      L0215 
  DC.B      'Nu'
L0124:
  DC.B      $04,'y',$00,$04 
  DC.L      L0215 
  DC.B      'Nu'
L0125:
  DC.L      L013E 
  DC.L      L013F 
  DC.L      L0126 
  DC.L      L0127 
  DC.L      L0128 
  DC.L      L0129 
  DC.L      L012A 
  DC.L      L012B 
L0126:
  DC.B      $00,$01,$00,'P' 
L0127:
  DC.B      $00,$01,$00,'P' 
L0128:
  DC.B      $00,$01,$00,'P' 
L0129:
  DC.B      $00,$08,$FF,$F4,$FF,$F4,$FF,$F4 
  DC.B      $00,$0C,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $FF,$F4,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$F4,$00,$0C,$00,$0C 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C 
L012A:
  DC.B      $00,$0C 
L012B:
  DC.B      $00,$06 
  DC.L      L012C 
  DC.L      L012F 
  DC.L      L0132 
  DC.L      L0135 
  DC.L      L0138 
  DC.L      L013B 
L012C:
  DC.B      $00,$01,$00,$00,$00,$00,$00,$04 
  DC.L      L012D 
  DC.L      L012E 
  DC.B      $00,$00,$00,$08,$00,$04,$00,$0C 
  DC.B      $00,$04,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$04,$00,$08,$00,$08,$00,$0C 
  DC.B      $00,$0C 
L012D:
  DC.B      '3',$FC,$03,$15 
  DC.L      L024B 
  DC.B      'Nu'
L012E:
  DC.B      'Nu'
L012F:
  DC.B      $00,$02,$00,$00,$00,$00,$00,$04 
  DC.L      L0130 
  DC.L      L0131 
  DC.B      $00,$10,$00,$18,$00,$1C,$00,$14 
  DC.B      $00,$04,$00,$10,$00,$1C,$00,$1C 
  DC.B      $00,$18,$00,$18,$00,$14,$00,$14 
  DC.B      $00,$10 
L0130:
  DC.B      '3',$FC,$04,'T' 
  DC.L      L024B 
  DC.B      'Nu'
L0131:
  DC.B      'Nu'
L0132:
  DC.B      $00,$03,$00,$00,$00,$00,$00,$02 
  DC.L      L0133 
  DC.L      L0134 
  DC.B      $00,$10,$00,$04,$00,$14,$00,$00 
  DC.B      $00,$04,$00,$10,$00,$10,$00,$14 
  DC.B      $00,'$',$00,$04,$00,$00,$00,$00 
  DC.B      $00,' ' 
L0133:
  DC.B      '3',$FC,$05,'D' 
  DC.L      L024A 
  DC.B      'Nu'
L0134:
  DC.B      'Nu'
L0135:
  DC.B      $00,$04,$00,$00,$00,$00,$00,$02 
  DC.L      L0136 
  DC.L      L0137 
  DC.B      $00,$0C,$00,$18,$00,$08,$00,$1C 
  DC.B      $00,$04,$00,$0C,$00,$08,$00,$08 
  DC.B      $00,'(',$00,$18,$00,$18,$00,$1C 
  DC.B      $00,',' 
L0136:
  DC.B      '3',$FC,$04,'G' 
  DC.L      L024A 
  DC.B      'Nu'
L0137:
  DC.B      'Nu'
L0138:
  DC.B      $00,$05,$00,$00,$00,$00,$00,$00 
  DC.L      L0139 				; set and terminate rout?
  DC.L      L013A 				; next poly struct
  DC.B      $00,$10,$00,$0C,$00,$00,$00,$1C 
  DC.B      $00,$04,$00,$10,$00,' ',$00,$00 
  DC.B      $00,$0C,$00,$0C,$00,',',$00,$1C 
  DC.B      $00,$1C 
L0139:
  DC.B      '3',$FC,$01,'E' 
  DC.L      L0249 
  DC.B      'Nu'
L013A:
  DC.B      'Nu'
L013B:
  DC.B      $00,$06,$00,$00,$00,$00,$00,$00 
  DC.L      L013C 
  DC.L      L013D 
  DC.B      $00,$04,$00,$18,$00,$18,$00,$08 
  DC.B      $00,$04,$00,$04,$00,'$',$00,$14 
  DC.B      $00,$14,$00,$18,$00,'(',$00,$08 
  DC.B      $00,$04 
L013C:
  DC.B      '3',$FC,$06,'F' 
  DC.L      L0249 
  DC.B      'Nu'
L013D:
  DC.B      'Nu'
L013E:
  DC.B      'Nu'
L013F:
  DC.B      'L',$B9,$00,$1E 
  DC.L      L0249 
  DC.B      'I',$F9 
  DC.L      L0216 
  DC.B      '8',$FC,$00,$00,'8',$C2,'8',$C1 
  DC.B      '8',$C3,'8',$C1,'8',$C2,'8',$C1 
  DC.B      '8',$C4,'8',$C1,'8',$C2,'8',$C1 
  DC.B      '8',$C3,'8',$C1,'8',$C2,'8',$C1 
  DC.B      '8',$FC,$00,$01,'Nu'
  DC.L      L015B 
  DC.L      L015C 
  DC.L      L0140 
  DC.L      L0141 
  DC.L      L0142 
  DC.L      L0143 
  DC.L      L0144 
  DC.L      L0145 
L0140:
  DC.B      $00,$02,$00,'P',$00,'(' 
L0141:
  DC.B      $00,$02,$00,'P',$00,'2' 
L0142:
  DC.B      $00,$01,$00,'P' 
L0143:
  DC.B      $00,$0E,$FF,$F4,$FF,$F4,$FF,$F4 
  DC.B      $00,$0C,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $FF,$F4,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$F4,$00,$0C,$00,$0C 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$00,$FF,$E8,$FF,$F4,$00,$18 
  DC.B      $00,$00,$FF,$F4,$00,$18,$00,$18 
  DC.B      $FF,$F4,$FF,$E8,$00,$18,$FF,$F4 
  DC.B      $FF,$E8,$00,$00,$FF,$F4 
L0144:
  DC.B      $00,$11 
L0145:
  DC.B      $00,$07 
  DC.L      L0146 
  DC.L      L0149 
  DC.L      L014C 
  DC.L      L014F 
  DC.L      L0152 
  DC.L      L0155 
  DC.L      L0158 
L0146:
  DC.B      $00,$01,$00,$00,$00,$00,$00,$06 
  DC.L      L0147 
  DC.L      L0148 
  DC.B      $00,$00,$00,$08,$00,$04,$00,$0C 
  DC.B      $00,$04,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$04,$00,$08,$00,$08,$00,$0C 
  DC.B      $00,$0C 
L0147:
  DC.B      '3',$FC,$06,'3' 
  DC.L      L024C 
  DC.B      'Nu'
L0148:
  DC.B      'Nu'
L0149:
  DC.B      $00,$02,$00,$00,$00,$00,$00,$06 
  DC.L      L014A 
  DC.L      L014B 
  DC.B      $00,$10,$00,$18,$00,$1C,$00,$14 
  DC.B      $00,$04,$00,$10,$00,$1C,$00,$1C 
  DC.B      $00,$18,$00,$18,$00,$14,$00,$14 
  DC.B      $00,$10 
L014A:
  DC.B      '3',$FC,$05,'B' 
  DC.L      L024C 
  DC.B      'Nu'
L014B:
  DC.B      'Nu'
L014C:
  DC.B      $00,$03,$00,$00,$00,$00,$00,$02 
  DC.L      L014D 
  DC.L      L014E 
  DC.B      $00,$10,$00,$04,$00,$14,$00,$00 
  DC.B      $00,$04,$00,$10,$00,$10,$00,$14 
  DC.B      $00,'$',$00,$04,$00,$00,$00,$00 
  DC.B      $00,' ' 
L014D:
  DC.B      '3',$FC,$02,'C' 
  DC.L      L024A 
  DC.B      'Nu'
L014E:
  DC.B      'Nu'
L014F:
  DC.B      $00,$04,$00,$00,$00,$00,$00,$02 
  DC.L      L0150 
  DC.L      L0151 
  DC.B      $00,$0C,$00,$18,$00,$08,$00,$1C 
  DC.B      $00,$04,$00,$0C,$00,$08,$00,$08 
  DC.B      $00,'(',$00,$18,$00,$18,$00,$1C 
  DC.B      $00,',' 
L0150:
  DC.B      '3',$FC,$04,$12 
  DC.L      L024A 
  DC.B      'Nu'
L0151:
  DC.B      'Nu'
L0152:
  DC.B      $00,$05,$00,$00,$00,$00,$00,$00 
  DC.L      L0153 
  DC.L      L0154 
  DC.B      $00,$10,$00,$0C,$00,$00,$00,$1C 
  DC.B      $00,$04,$00,$10,$00,' ',$00,$00 
  DC.B      $00,$0C,$00,$0C,$00,',',$00,$1C 
  DC.B      $00,$1C 
L0153:
  DC.B      '3',$FC,$03,'A' 
  DC.L      L0249 
  DC.B      'Nu'
L0154:
  DC.B      'Nu'
L0155:
  DC.B      $00,$06,$00,$00,$00,$00,$00,$00 
  DC.L      L0156 
  DC.L      L0157 
  DC.B      $00,$04,$00,$18,$00,$18,$00,$08 
  DC.B      $00,$04,$00,$04,$00,'$',$00,$14 
  DC.B      $00,$14,$00,$18,$00,'(',$00,$08 
  DC.B      $00,$04 
L0156:
  DC.B      '3',$FC,$04,'3' 
  DC.L      L0249 
  DC.B      'Nu'
L0157:
  DC.B      'Nu'
L0158:
  DC.B      $00,$07,$00,$00,$00,$00,$00,$04 
  DC.L      L0159 
  DC.L      L015A 
  DC.B      $00,'4',$00,',',$00,'(',$00,'0' 
  DC.B      $00,$05,$00,'$',$00,'0',$00,'(' 
  DC.B      $00,'4',$00,',',$00,'8',$00,'0' 
  DC.B      $00,'<',$00,'4',$00,'@' 
L0159:
  DC.B      '3',$FC,$01,$F4 
  DC.L      L024B 
  DC.B      'Nu'
L015A:
  DC.B      'Nu'
L015B:
  DC.B      'Nu'
L015C:
  DC.B      'L',$B9,$00,$1E 
  DC.L      L0249 
  DC.B      'I',$F9 
  DC.L      L0216 
  DC.B      '8',$FC,$00,$00,'8',$C2,'8',$C1 
  DC.B      '8',$C3,'8',$C1,'8',$C2,'8',$C1 
  DC.B      '8',$C4,'8',$C1,'8',$C2,'8',$C1 
  DC.B      '8',$C3,'8',$C1,'8',$C2,'8',$C1 
  DC.B      '8',$FC,$00,$01,'Nu'
  DC.L      L0171 
  DC.L      L0172 
  DC.L      L015D 
  DC.L      L015E 
  DC.L      L015F 
  DC.L      L0160 
  DC.L      L0161 
  DC.L      L0162 
L015D:
  DC.B      $00,$03,$00,$80,$00,'F',$00,'F' 
L015E:
  DC.B      $00,$03,$00,$80,$00,'F',$00,'F' 
L015F:
  DC.B      $00,$03,$00,$80,$00,'F',$00,'F' 
L0160:
  DC.B      $00,$0A,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$FF,$F4 
  DC.B      $FF,$F4,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$E8,$FF,$F4,$FF,$E8 
  DC.B      $00,$0C,$00,$00,$00,$00,$FF,$DC 
  DC.B      $FF,$DC,$FF,$F4,$00,$00,$00,$00 
  DC.B      $00,$0C,$FF,$F4,$FF,$DC,$FF,$DC 
  DC.B      $00,$00,$00,$0C,$00,$00 
L0161:
  DC.B      $00,$0F 
L0162:
  DC.B      $00,$06 
  DC.L      L0163 
  DC.L      L0166 
  DC.L      L0169 
  DC.L      L016C 
  DC.L      L016F 
  DC.L      L0170 
L0163:
  DCB.W     2,0 
  DC.B      $00,$01,$00,$00 
  DC.L      L0164 
  DC.L      L0165 
  DC.B      $00,$00,$00,$04,$00,$00,$00,$08 
  DC.B      $00,$03,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$04,$00,$08,$00,$08 
L0164:
  DC.B      '3',$FC,$00,$07 
  DC.L      L0249 
  DC.B      'Xy'
  DC.L      L0251 
  DC.B      'Nu'
L0165:
  DC.B      '3',$FC,$02,'"' 
  DC.L      L0249 
  DC.B      'Nu'
L0166:
  DC.B      $00,$01,$00,$00,$00,$01,$00,$02 
  DC.L      L0167 
  DC.L      L0168 
  DC.B      $00,$08,$00,$04,$00,$08,$00,$0C 
  DC.B      $00,$03,$00,$08,$00,$04,$00,$04 
  DC.B      $00,$10,$00,$0C,$00,$0C 
L0167:
  DC.B      '3',$FC,$00,'p' 
  DC.L      L024A 
  DC.B      'Ty'
  DC.L      L0251 
  DC.B      'Nu'
L0168:
  DC.B      '3',$FC,$03,'3' 
  DC.L      L024A 
  DC.B      'Nu'
L0169:
  DC.B      $00,$02,$00,$00,$00,$01,$00,$04 
  DC.L      L016A 
  DC.L      L016B 
  DC.B      $00,$00,$00,$08,$00,$00,$00,$0C 
  DC.B      $00,$03,$00,$00,$00,$08,$00,$08 
  DC.B      $00,$0C,$00,$0C,$00,$14 
L016A:
  DC.B      'Ry'
  DC.L      L0251 
  DC.B      '3',$FC,$07,$00 
  DC.L      L024B 
  DC.B      'Nu'
L016B:
  DC.B      '3',$FC,$01,$11 
  DC.L      L024B 
  DC.B      'Nu'
L016C:
  DC.B      $00,$03,$00,$01,$00,$00,$00,$06 
  DC.L      L016D 
  DC.L      L016E 
  DC.B      $00,$08,$00,$14,$00,$10,$00,$18 
  DC.B      $00,$04,$00,$08,$00,$18,$00,$10 
  DC.B      $00,$1C,$00,$14,$00,' ',$00,$18 
  DC.B      $00,'$' 
L016D:
  DC.B      '3',$FC,$07,'w' 
  DC.L      L024C 
  DC.B      'Nu'
L016E:
  DC.B      'Nu'
L016F:
  DC.B      $00,$04,$00,$01,$00,$00,$00,$06 
  DC.L      L016D 
  DC.L      L016E 
  DC.B      $00,$08,$00,$1C,$00,' ',$00,$10 
  DC.B      $00,$04,$00,$08,$00,'(',$00,' ' 
  DC.B      $00,',',$00,$1C,$00,'0',$00,$10 
  DC.B      $00,$18 
L0170:
  DC.B      $00,$05,$00,$01,$00,$00,$00,$06 
  DC.L      L016D 
  DC.L      L016E 
  DC.B      $00,$08,$00,'$',$00,$18,$00,' ' 
  DC.B      $00,$04,$00,$08,$00,'$',$00,$18 
  DC.B      $00,'4',$00,'$',$00,'8',$00,' ' 
  DC.B      $00,'(' 
L0171:
  DC.B      'Nu'
L0172:
  DC.B      'L',$B9,$00,$0F 
  DC.L      L0249 
  DC.B      '89'
  DC.L      L0251 
  DC.B      $D8,'D',$D8,'DI',$F9
  DC.L      L0173 
  DC.B      '(t@',$00,'N”I',$F9 
  DC.L      L0216 
  DC.B      '8',$FC,$00,$00,'8',$C0,'8',$C1 
  DC.B      '8',$C4,'8',$C2,'8',$C5,'8',$C6 
  DC.B      '8',$C7,'8',$C3,'8',$C3,'8',$C3 
  DC.B      '8',$C3,'8',$C3,'8',$C3,'8',$C3 
  DC.B      '8',$C3,'By'
  DC.L      L0251 
  DC.B      'Nu'
L0173:
  DC.L      L0174 
  DC.L      L0174 
  DC.L      L0175 
  DC.L      L0175 
  DC.L      L0176 
  DC.L      L0177 
  DC.L      L0176 
  DC.L      L0176 
L0174:
  DC.B      '8',$01,':',$02,'<',$02,'>',$02 
  DC.B      'Nu'
L0175:
  DC.B      '8',$01,':',$02,'<',$01,'>',$01 
  DC.B      'Nu'
L0176:
  DC.B      '8',$00,':',$00,'<',$01,'>',$00 
  DC.B      'Nu'
L0177:
  DC.B      '8',$00,':',$00,'<',$02,'>',$00 
  DC.B      'Nu'
  DC.L      L018C 
  DC.L      L018D 
  DC.L      L0178 
  DC.L      L0179 
  DC.L      L017A 
  DC.L      L017B 
  DC.L      L017C 
  DC.L      L017D 
L0178:
  DC.B      $00,$03,$00,$80,$00,'F',$00,'F' 
L0179:
  DC.B      $00,$03,$00,$80,$00,'F',$00,'F' 
L017A:
  DC.B      $00,$03,$00,$80,$00,'F',$00,'F' 
L017B:
  DC.B      $00,$0A,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$FF,$F4 
  DC.B      $FF,$F4,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$E8,$FF,$F4,$FF,$E8 
  DC.B      $00,$0C,$00,$00,$00,$00,$FF,$DC 
  DC.B      $FF,$DC,$FF,$F4,$00,$00,$00,$00 
  DC.B      $00,$0C,$FF,$F4,$FF,$DC,$FF,$DC 
  DC.B      $00,$00,$00,$0C,$00,$00 
L017C:
  DC.B      $00,$0F 
L017D:
  DC.B      $00,$06 
  DC.L      L017E 
  DC.L      L0181 
  DC.L      L0184 
  DC.L      L0187 
  DC.L      L018A 
  DC.L      L018B 
L017E:
  DCB.W     2,0 
  DC.B      $00,$01,$00,$00 
  DC.L      L017F 
  DC.L      L0180 
  DC.B      $00,$00,$00,$04,$00,$00,$00,$08 
  DC.B      $00,$03,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$04,$00,$08,$00,$08 
L017F:
  DC.B      '3',$FC,$00,$07 
  DC.L      L0249 
  DC.B      'Nu'
L0180:
  DC.B      'Nu'
L0181:
  DC.B      $00,$01,$00,$00,$00,$01,$00,$02 
  DC.L      L0182 
  DC.L      L0183 
  DC.B      $00,$08,$00,$04,$00,$08,$00,$0C 
  DC.B      $00,$03,$00,$08,$00,$04,$00,$04 
  DC.B      $00,$10,$00,$0C,$00,$0C 
L0182:
  DC.B      '3',$FC,$00,'p' 
  DC.L      L024A 
  DC.B      'Nu'
L0183:
  DC.B      'Nu'
L0184:
  DC.B      $00,$02,$00,$00,$00,$01,$00,$04 
  DC.L      L0185 
  DC.L      L0186 
  DC.B      $00,$00,$00,$08,$00,$00,$00,$0C 
  DC.B      $00,$03,$00,$00,$00,$08,$00,$08 
  DC.B      $00,$0C,$00,$0C,$00,$14 
L0185:
  DC.B      '3',$FC,$07,$00 
  DC.L      L024B 
  DC.B      'Nu'
L0186:
  DC.B      'Nu'
L0187:
  DC.B      $00,$03,$00,$01,$00,$00,$00,$06 
  DC.L      L0188 
  DC.L      L0189 
  DC.B      $00,$08,$00,$14,$00,$10,$00,$18 
  DC.B      $00,$04,$00,$08,$00,$18,$00,$10 
  DC.B      $00,$1C,$00,$14,$00,' ',$00,$18 
  DC.B      $00,'$' 
L0188:
  DC.B      '3',$FC,$07,'w' 
  DC.L      L024C 
  DC.B      'Nu'
L0189:
  DC.B      'Nu'
L018A:
  DC.B      $00,$04,$00,$01,$00,$00,$00,$06 
  DC.L      L0188 
  DC.L      L0189 
  DC.B      $00,$08,$00,$1C,$00,' ',$00,$10 
  DC.B      $00,$04,$00,$08,$00,'(',$00,' ' 
  DC.B      $00,',',$00,$1C,$00,'0',$00,$10 
  DC.B      $00,$18 
L018B:
  DC.B      $00,$05,$00,$01,$00,$00,$00,$06 
  DC.L      L0188 
  DC.L      L0189 
  DC.B      $00,$08,$00,'$',$00,$18,$00,' ' 
  DC.B      $00,$04,$00,$08,$00,'$',$00,$18 
  DC.B      $00,'4',$00,'$',$00,'8',$00,' ' 
  DC.B      $00,'(' 
L018C:
  DC.B      'Nu'
L018D:
  DC.B      'L',$B9,$00,$0F 
  DC.L      L0249 
  DC.B      'I',$F9 
  DC.L      L0216 
  DC.B      '8',$FC,$00,$00,'8',$C0,'8',$C1 
  DC.B      '8',$C4,'8',$C2,'8',$C5,'8',$C6 
  DC.B      '8',$C7,'8',$C3,'8',$C3,'8',$C3 
  DC.B      '8',$C3,'8',$C3,'8',$C3,'8',$C3 
  DC.B      '8',$C3,'Nu'
  DC.L      L01A9 
  DC.L      L01AA 
  DC.L      L018E 
  DC.L      L018F 
  DC.L      L0190 
  DC.L      L0191 
  DC.L      L0192 
  DC.L      L0193 
L018E:
  DC.B      $00,$01,$00,$80 
L018F:
  DC.B      $00,$01,$00,$80 
L0190:
  DC.B      $00,$01,$00,$80 
L0191:
  DC.B      $00,$07,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$FF,$F4 
  DC.B      $FF,$F4,$FF,$F4,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$00,$00,$FF,$F4,$00,$00 
  DCB.W     2,0 
  DC.B      $FF,$F4,$FF,$F4,$00,$00,$00,$00 
L0192:
  DC.B      $00,$14 
L0193:
  DC.B      $00,$04 
  DC.L      L0194 
  DC.L      L0197 
  DC.L      L019A 
  DC.L      L019D 
L0194:
  DCB.W     4,0 
  DC.L      L0195 
  DC.L      L0196 
  DC.B      $00,$00,$00,$04,$00,$00,$00,$08 
  DC.B      $00,$03,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$04,$00,$08,$00,$08 
L0195:
  DC.B      '3',$FC,$07,'3' 
  DC.L      L0249 
  DC.B      'Xy'
  DC.L      L0251 
  DC.B      'Nu'
L0196:
  DC.B      '3',$FC,$03,'3' 
  DC.L      L0249 
  DC.B      '~',$04,'A',$F9 
  DC.L      L01A0 
  DC.B      '/H',$00,$04,'I',$E8,$00,$1A
  DC.B      'Nu'
L0197:
  DC.B      $00,$01,$00,$00,$00,$00,$00,$02 
  DC.L      L0198 
  DC.L      L0199 
  DC.B      $00,$08,$00,$04,$00,$08,$00,$0C 
  DC.B      $00,$03,$00,$08,$00,$04,$00,$04 
  DC.B      $00,$10,$00,$0C,$00,$0C 
L0198:
  DC.B      '3',$FC,$03,'s' 
  DC.L      L024A 
  DC.B      'Ty'
  DC.L      L0251 
  DC.B      'Nu'
L0199:
  DC.B      '3',$FC,$02,'"' 
  DC.L      L024A 
  DC.B      '~',$04,'A',$F9 
  DC.L      L01A3 
  DC.B      '/H',$00,$04,'I',$E8,$00,$1A
  DC.B      'Nu'
L019A:
  DC.B      $00,$02,$00,$00,$00,$00,$00,$04 
  DC.L      L019B 
  DC.L      L019C 
  DC.B      $00,$00,$00,$08,$00,$00,$00,$0C 
  DC.B      $00,$03,$00,$00,$00,$08,$00,$08 
  DC.B      $00,$0C,$00,$0C,$00,$14 
L019B:
  DC.B      'Ry'
  DC.L      L0251 
  DC.B      '3',$FC,$03,'7' 
  DC.L      L024B 
  DC.B      'Nu'
L019C:
  DC.B      '3',$FC,$01,$11 
  DC.L      L024B 
  DC.B      '~',$04,'A',$F9 
  DC.L      L01A6 
  DC.B      '/H',$00,$04,'I',$E8,$00,$1A
  DC.B      'Nu'
L019D:
  DC.B      $00,$03,$00,$00,$00,$00,$00,$06 
  DC.L      L019E 
  DC.L      L019F 
  DC.B      $00,$10,$00,$14,$00,$18,$00,$10 
  DC.B      $00,$03,$00,$10,$00,$18,$00,$18 
  DC.B      $00,$1C,$00,$14,$00,' ' 
L019E:
  DC.B      '3',$FC,$00,$05 
  DC.L      L024C 
  DC.B      'Nu'
L019F:
  DC.B      'Nu'
L01A0:
  DCB.W     2,0 
  DC.B      $00,$01,$00,$00 
  DC.L      L01A1 
  DC.L      L01A2 
  DC.B      $00,$00,$00,$14,$00,$10,$00,$04 
  DC.B      $00,$04,$00,$04,$00,'(',$00,$14 
  DC.B      $00,' ',$00,$10,$00,'$',$00,$00 
  DC.B      $00,$00 
L01A1:
  DC.B      '3',$FC,$02,'"' 
  DC.L      L0249 
  DC.B      'Nu'
L01A2:
  DC.B      'Nu'
L01A3:
  DC.B      $00,$01,$00,$00,$00,$01,$00,$02 
  DC.L      L01A4 
  DC.L      L01A5 
  DC.B      $00,$0C,$00,$14,$00,$04,$00,$18 
  DC.B      $00,$04,$00,$04,$00,$10,$00,$0C 
  DC.B      $00,',',$00,$18,$00,$1C,$00,$14 
  DC.B      $00,'(' 
L01A4:
  DC.B      '3',$FC,$03,'3' 
  DC.L      L024A 
  DC.B      'Nu'
L01A5:
  DC.B      'Nu'
L01A6:
  DC.B      $00,$02,$00,$00,$00,$01,$00,$04 
  DC.L      L01A7 
  DC.L      L01A8 
  DC.B      $00,$00,$00,$18,$00,$0C,$00,$10 
  DC.B      $00,$04,$00,$10,$00,$18,$00,$18 
  DC.B      $00,',',$00,$0C,$00,$14,$00,$00 
  DC.B      $00,'$' 
L01A7:
  DC.B      '3',$FC,$01,$11 
  DC.L      L024B 
  DC.B      'Nu'
L01A8:
  DC.B      'Nu'
L01A9:
  DC.B      'Nu'
L01AA:
  DC.B      'L',$B9,$00,$0F 
  DC.L      L0249 
  DC.B      '89'
  DC.L      L0251 
  DC.B      $D8,'D',$D8,'DE',$F9
  DC.L      L0173 
  DC.B      '$r@',$00,'N',$92,'E',$F9 
  DC.L      L0216 
  DC.B      '4',$FC,$00,$00,'4',$C0,'4',$C1 
  DC.B      '4',$C4,'4',$C2,'4',$C5,'4',$C6 
  DC.B      '4',$C7,'4',$C3,'4',$C0,'4',$C1 
  DC.B      '4',$C4,'4',$C2,'4',$C5,'4',$C6 
  DC.B      '4',$C7,'By'
  DC.L      L0251 
  DC.B      'Nu'
  DC.L      L01AB 
  DC.L      L01AC 
  DC.L      L01AD 
  DC.L      L01AE 
  DC.L      L01AF 
  DC.L      L01B0 
L01AB:
  DC.B      $00,$01,$00,'2' 
L01AC:
  DC.B      $00,$02,$00,'2',$00,')' 
L01AD:
  DC.B      $00,$01,$00,'2' 
L01AE:
  DC.B      $00,$08,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$00,$0C,$00,$0C,$FF,$F4 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$FF,$F4 
  DC.B      $00,$0C,$00,$00,$FF,$E8,$FF,$F4 
  DC.B      $00,$00,$00,$18,$FF,$F4,$FF,$F4 
  DC.B      $00,$00,$00,$0C,$00,$0C,$00,$00 
  DC.B      $00,$0C 
L01AF:
  DC.B      $00,$0C 
L01B0:
  DC.B      $00,$04 
  DC.L      L01B1 
  DC.L      L01B2 
  DC.L      L01B3 
  DC.L      L01B4 
L01B1:
  DCB.W     2,0 
  DC.B      $00,$01,$00,$00,$00,$0C,$00,$14 
  DC.B      $00,$10,$00,$08,$00,$04,$00,$0C 
  DC.B      $00,$00,$00,$10,$00,$04,$00,$14 
  DC.B      $00,$08,$00,$08,$00,$0C 
L01B2:
  DC.B      $00,$01,$00,$00,$00,$01,$00,$02 
  DC.B      $00,$10,$00,$04,$00,$00,$00,$14 
  DC.B      $00,$04,$00,$10,$00,$10,$00,$00 
  DC.B      $00,$14,$00,$04,$00,$18,$00,$14 
  DC.B      $00,$04 
L01B3:
  DC.B      $00,$02,$00,$00,$00,$01,$00,$04 
  DC.B      $00,$18,$00,$10,$00,$10,$00,$14 
  DC.B      $00,$03,$00,$10,$00,$04,$00,$14 
  DC.B      $00,' ',$00,$18,$00,$1C 
L01B4:
  DC.B      $00,$03,$00,$00,$00,$01,$00,$06 
  DC.B      $00,$10,$00,$1C,$00,$10,$00,$14 
  DC.B      $00,$03,$00,$10,$00,'$',$00,$1C 
  DC.B      $00,'(',$00,$14,$00,$04 
  DC.L      L01B5 
  DC.L      L01B6 
  DC.L      L01B7 
  DC.L      L01B8 
  DC.L      L01B9 
  DC.L      L01BA 
L01B5:
  DC.B      $00,$01,$00,'2' 
L01B6:
  DC.B      $00,$01,$00,'2' 
L01B7:
  DC.B      $00,$01,$00,'F' 
L01B8:
  DC.B      $00,$06,$00,$0C,$FF,$F4,$00,$00 
  DC.B      $00,$0C,$00,$0C,$00,$00,$FF,$F4 
  DC.B      $00,$0C,$00,$00,$FF,$F4,$FF,$F4 
  DCB.W     3,0 
  DC.B      $FF,$F4,$00,$00,$00,$00,$00,$0C 
L01B9:
  DC.B      $00,$0C 
L01BA:
  DC.B      $00,$04 
  DC.L      L01BB 
  DC.L      L01BC 
  DC.L      L01BD 
  DC.L      L01BE 
L01BB:
  DCB.W     2,0 
  DC.B      $00,$01,$00,$00,$00,$10,$00,$00 
  DC.B      $00,$00,$00,$04,$00,$03,$00,$00 
  DC.B      $00,$00,$00,$04,$00,$04,$00,$10 
  DC.B      $00,$08 
L01BC:
  DC.B      $00,$01,$00,$00,$00,$01,$00,$02 
  DC.B      $00,$08,$00,$0C,$00,$0C,$00,$10 
  DC.B      $00,$03,$00,$0C,$00,$0C,$00,$10 
  DC.B      $00,$10,$00,$08,$00,$14 
L01BD:
  DC.B      $00,$02,$00,$00,$00,$01,$00,$04 
  DC.B      $00,$14,$00,$0C,$00,$14,$00,$00 
  DC.B      $00,$03,$00,$14,$00,$18,$00,$0C 
  DC.B      $00,' ',$00,$00,$00,$1C 
L01BE:
  DC.B      $00,$03,$00,$00,$00,$01,$00,$06 
  DC.B      $00,$14,$00,$08,$00,$14,$00,$04 
  DC.B      $00,$03,$00,$14,$00,'$',$00,$08 
  DC.B      $00,',',$00,$04,$00,'(' 
  DC.L      L01BF 
  DC.L      L01C0 
  DC.L      L01C1 
  DC.L      L01C2 
  DC.L      L01C3 
  DC.L      L01C4 
L01BF:
  DC.B      $00,$01,$00,'2' 
L01C0:
  DC.B      $00,$01,$00,'2' 
L01C1:
  DC.B      $00,$01,$00,'H' 
L01C2:
  DC.B      $00,$06,$00,$0C,$FF,$F4,$00,$00 
  DC.B      $00,$0C,$00,$0C,$00,$00,$FF,$F4 
  DC.B      $00,$0C,$00,$00,$FF,$F4,$FF,$F4 
  DCB.W     3,0 
  DC.B      $FF,$F4,$00,$00,$00,$00,$00,$0C 
L01C3:
  DC.B      $00,$0C 
L01C4:
  DC.B      $00,$08 
  DC.L      L01C5 
  DC.L      L01C6 
  DC.L      L01C7 
  DC.L      L01C8 
  DC.L      L01C9 
  DC.L      L01CA 
  DC.L      L01CB 
  DC.L      L01CC 
L01C5:
  DCB.W     4,0 
  DC.B      $00,$10,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$03,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$04,$00,$10,$00,$08 
L01C6:
  DC.B      $00,$01,$00,$00,$00,$00,$00,$02 
  DC.B      $00,$08,$00,$0C,$00,$0C,$00,$10 
  DC.B      $00,$03,$00,$0C,$00,$0C,$00,$10 
  DC.B      $00,$10,$00,$08,$00,$14 
L01C7:
  DC.B      $00,$02,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$0C,$00,$14,$00,$14,$00,$00 
  DC.B      $00,$03,$00,$14,$00,$1C,$00,$00 
  DC.B      $00,' ',$00,$0C,$00,$18 
L01C8:
  DC.B      $00,$03,$00,$00,$00,$00,$00,$06 
  DC.B      $00,$14,$00,$08,$00,$14,$00,$04 
  DC.B      $00,$03,$00,$14,$00,'$',$00,$08 
  DC.B      $00,',',$00,$04,$00,'(' 
L01C9:
  DC.B      $00,$04,$00,$00,$00,$00,$00,$06 
  DC.B      $00,$0C,$00,$00,$00,$0C,$00,$10 
  DC.B      $00,$03,$00,$0C,$00,' ',$00,$00 
  DC.B      $00,$08,$00,$10,$00,$0C 
L01CA:
  DC.B      $00,$05,$00,$00,$00,$00,$00,$04 
  DC.B      $00,$08,$00,$10,$00,$10,$00,$04 
  DC.B      $00,$03,$00,$10,$00,$04,$00,$04 
  DC.B      $00,',',$00,$08,$00,$10 
L01CB:
  DC.B      $00,$06,$00,$00,$00,$00,$00,$02 
  DC.B      $00,$00,$00,$14,$00,$00,$00,$04 
  DC.B      $00,$03,$00,$00,$00,$1C,$00,$14 
  DC.B      $00,'(',$00,$04,$00,$00 
L01CC:
  DC.B      $00,$07,$00,$00,$00,$00,$00,$00 
  DC.B      $00,$14,$00,$0C,$00,$0C,$00,$08 
  DC.B      $00,$03,$00,$0C,$00,$14,$00,$08 
  DC.B      $00,'$',$00,$14,$00,$18 
  DC.L      L01EB 
  DC.L      L01EC 
  DC.L      L01CD 
  DC.L      L01CE 
  DC.L      L01CF 
  DC.L      L01D0 
  DC.L      L01D1 
  DC.L      L01D2 
L01CD:
  DC.B      $00,$02,$00,'(',$00,'x' 
L01CE:
  DC.B      $00,$01,$00,'d' 
L01CF:
  DC.B      $00,$01,$00,'P' 
L01D0:
  DC.B      $00,$08,$00,$0C,$FF,$F4,$00,$00 
  DC.B      $00,$18,$00,$00,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$00,$00,$FF,$F4,$00,$0C 
  DC.B      $00,$00,$FF,$E8,$00,$00,$FF,$F4 
  DC.B      $FF,$F4,$FF,$F4,$00,$00,$FF,$E8 
  DC.B      $00,$00,$00,$0C,$00,$18,$00,$00 
  DC.B      $00,$0C 
L01D1:
  DC.B      $00,$0E 
L01D2:
  DC.B      $00,$08 
  DC.L      L01D3 
  DC.L      L01D6 
  DC.L      L01D9 
  DC.L      L01DC 
  DC.L      L01DF 
  DC.L      L01E2 
  DC.L      L01E5 
  DC.L      L01E8 
L01D3:
  DCB.W     4,0 
  DC.L      L01D4 
  DC.L      L01D5 
  DC.B      $00,$14,$00,$04,$00,$00,$00,$10 
  DC.B      $00,$04,$00,$00,$00,$04,$00,$04 
  DC.B      $00,$18,$00,$10,$00,$14,$00,$14 
  DC.B      $00,$00 
L01D4:
  DC.B      '3',$FC,$03,'6' 
  DC.L      L024D 
  DC.B      'Nu'
L01D5:
  DC.B      'Nu'
L01D6:
  DC.B      $00,$01,$00,$00,$00,$00,$00,$02 
  DC.L      L01D7 
  DC.L      L01D8 
  DC.B      $00,$10,$00,$08,$00,$04,$00,$0C 
  DC.B      $00,$04,$00,$04,$00,$08,$00,$08 
  DC.B      $00,$0C,$00,$0C,$00,$10,$00,$10 
  DC.B      $00,$18 
L01D7:
  DC.B      '3',$FC,$04,'E' 
  DC.L      L024E 
  DC.B      'Nu'
L01D8:
  DC.B      'Nu'
L01D9:
  DC.B      $00,$02,$00,$00,$00,$00,$00,$00 
  DC.L      L01DA 
  DC.L      L01DB 
  DC.B      $00,$08,$00,$18,$00,$1C,$00,$0C 
  DC.B      $00,$04,$00,$1C,$00,',',$00,$18 
  DC.B      $00,' ',$00,$0C,$00,$0C,$00,$08 
  DC.B      $00,'$' 
L01DA:
  DC.B      '3',$FC,$05,'T' 
  DC.L      L024D 
  DC.B      'Nu'
L01DB:
  DC.B      'Nu'
L01DC:
  DC.B      $00,$03,$00,$00,$00,$00,$00,$02 
  DC.L      L01DD 
  DC.L      L01DE 
  DC.B      $00,$1C,$00,$14,$00,$00,$00,$18 
  DC.B      $00,$04,$00,$00,$00,$00,$00,$14 
  DC.B      $00,$1C,$00,$18,$00,',',$00,$1C 
  DC.B      $00,'(' 
L01DD:
  DC.B      '3',$FC,$06,'c' 
  DC.L      L024E 
  DC.B      'Nu'
L01DE:
  DC.B      'Nu'
L01DF:
  DC.B      $00,$04,$00,$00,$00,$00,$00,$04 
  DC.L      L01E0 
  DC.L      L01E1 
  DC.B      $00,$00,$00,$1C,$00,$00,$00,$04 
  DC.B      $00,$03,$00,$00,$00,'(',$00,$1C 
  DC.B      $00,'0',$00,$04,$00,$04 
L01E0:
  DC.B      '3',$FC,$03,'f' 
  DC.L      L024F 
  DC.B      'Nu'
L01E1:
  DC.B      'Nu'
L01E2:
  DC.B      $00,$05,$00,$00,$00,$00,$00,$06 
  DC.L      L01E3 
  DC.L      L01E4 
  DC.B      $00,$04,$00,$1C,$00,$1C,$00,$08 
  DC.B      $00,$03,$00,$04,$00,'0',$00,$1C 
  DC.B      $00,'$',$00,$08,$00,$08 
L01E3:
  DC.B      '3',$FC,$04,'U' 
  DC.L      L0250 
  DC.B      'Nu'
L01E4:
  DC.B      'Nu'
L01E5:
  DC.B      $00,$06,$00,$00,$00,$00,$00,$06 
  DC.L      L01E6 
  DC.L      L01E7 
  DC.B      $00,$14,$00,$18,$00,$10,$00,$14 
  DC.B      $00,$03,$00,$14,$00,$14,$00,$10 
  DC.B      $00,'4',$00,$18,$00,$1C 
L01E6:
  DC.B      '3',$FC,$05,'D' 
  DC.L      L0250 
  DC.B      'Nu'
L01E7:
  DC.B      'Nu'
L01E8:
  DC.B      $00,$07,$00,$00,$00,$00,$00,$04 
  DC.L      L01E9 
  DC.L      L01EA 
  DC.B      $00,$18,$00,$10,$00,$10,$00,$0C 
  DC.B      $00,$03,$00,$18,$00,'4',$00,$10 
  DC.B      $00,$10,$00,$0C,$00,' ' 
L01E9:
  DC.B      '3',$FC,$06,'3' 
  DC.L      L024F 
  DC.B      'Nu'
L01EA:
  DC.B      'Nu'
L01EB:
  DC.B      'Nu'
L01EC:
  DC.B      'L',$B9,$00,$1E 
  DC.L      L024D 
  DC.B      'I',$F9 
  DC.L      L0216 
  DC.B      '8',$FC,$00,$00,'8',$C1,'8',$C2 
  DC.B      '8',$C1,'8',$C3,'8',$C1,'8',$C2 
  DC.B      '8',$C1,'8',$C4,'8',$C1,'8',$C2 
  DC.B      '8',$C1,'8',$C3,'8',$C1,'8',$C2 
  DC.B      '8',$C1,'Nu'
  DC.L      L01ED 
  DC.L      L01EE 
  DC.L      L01EF 
  DC.L      L01F0 
  DC.L      L01F1 
  DC.L      L01F2 
L01ED:
  DC.B      $00,$02,$00,$14,$00,$1C 
L01EE:
  DC.B      $00,$01,$00,$1E 
L01EF:
  DC.B      $00,$02,$00,$14,$00,$1C 
L01F0:
  DC.B      $00,$08,$FF,$F4,$00,$0C,$FF,$F4 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$00,$0C,$FF,$F4,$00,$0C 
  DC.B      $00,$0C,$FF,$E8,$FF,$F4,$00,$00 
  DC.B      $00,$00,$FF,$F4,$FF,$E8,$00,$18 
  DC.B      $FF,$F4,$00,$00,$00,$00,$FF,$F4 
  DC.B      $00,$18 
L01F1:
  DC.B      $00,$10 
L01F2:
  DC.B      $00,$05 
  DC.L      L01F3 
  DC.L      L01F4 
  DC.L      L01F5 
  DC.L      L01F6 
  DC.L      L01F7 
L01F3:
  DCB.W     4,0 
  DC.B      $00,$08,$00,$04,$00,$0C,$00,$04 
  DCB.W     2,0 
  DC.B      $00,$04,$00,$04,$00,$08,$00,$08 
  DC.B      $00,$0C,$00,$0C 
L01F4:
  DC.B      $00,$01,$00,$00,$00,$00,$00,$10 
  DC.B      $00,$18,$00,$1C,$00,$14,$00,$04 
  DC.B      $00,$1C,$00,$14,$00,$18,$00,$18 
  DC.B      $00,$14,$00,$1C,$00,$10,$00,$10 
L01F5:
  DC.B      $00,$02,$00,$00,$00,$02,$00,$10 
  DC.B      $00,$14,$00,$10,$00,$00,$00,$03 
  DC.B      $00,$10,$00,$1C,$00,$14,$00,'$' 
  DC.B      $00,$00,$00,' ' 
L01F6:
  DC.B      $00,$03,$00,$00,$00,$04,$00,$14 
  DC.B      $00,$04,$00,$14,$00,$00,$00,$03 
  DC.B      $00,$14,$00,'(',$00,$04,$00,$00 
  DC.B      $00,$00,$00,'$' 
L01F7:
  DC.B      $00,$04,$00,$00,$00,$06,$00,$14 
  DC.B      $00,$18,$00,$14,$00,$04,$00,$03 
  DC.B      $00,$18,$00,',',$00,$04,$00,'(' 
  DC.B      $00,$14,$00,$18 

xrotspeed:
	dc.w	0
L0213:	dc.w	0
L0214:	dc.w	30

L0215:
  DS.W      1 

 BSS
L01F8:
  DS.B      38
L01F9:
  DS.B      1062
L01FA:
  DS.L      1 
L01FB:
  DS.W      1 
L01FC:
  DS.B      20
L01FD:
  DS.W      1 
L01FE:
  DS.W      1 
L01FF:
  DS.W      1 
L0200:
  DS.W      1 
L0201:
  DS.W      1 
L0202:
  DS.B      18
L0203:
  DS.L      1 
L0204:
  DS.W      1 
L0205:
  DS.L      1 
y_offset_table:
  DS.L      1 
L0207:
  DS.W      1 
L0208:
  DS.W      1 
L0209:
  DS.W      1 
L020A:
  DS.W      1 
L020B:
  DS.W      1 
L020C:
  DS.W      1 
L020D:
  DS.L      1 
L020E:
  DS.W      1 
L020F:
  DS.W      1 
L0210:
  DS.W      1 
L0211:
  DS.W      1 
L0216:
  DS.B      32
L0217:
  DS.B      400 
L0218:
  DS.B      400 
L0219:
  DS.B      1296
L021A:
  DS.B      400 
L021B:
  DS.B      218 
L021C:
  DS.B      400 
L021D:
  DS.B      400 
L021E:
  DS.B      200 
L021F:
  DS.B      400 
L0220:
  DS.B      804 
L0221:
  DS.B      16384 
L0222:
  DS.B      24576 
L0223:
  DS.L      1 
L0224:
  DS.L      1 
L0225:
  DS.B      22418 
L0226:
  DS.B      22418 
L0227:
  DS.B      8000
offsetmask_lut0:
  DS.L      1 
L0229:
  DS.B      10564 
L022A:
  DS.B      8000
offsetmask_lut1:
  DS.L      1 
L022C:
  DS.B      10564 
L022D:
  DS.B      2920

; -- multiply tables
L022E:
  DS.B      400 

L022F:
  DS.B      800 
L0230:
  DS.W      1 

L0231:
  DS.B      400 
L0232:
  DS.W      1 
mul6_lut_end:
; --

some_span_code_table:
  DS.B      29200 
L0234:
  DS.B      29204 

L0235:
  DS.B      6 
wipe_delta_spans_code:
  DS.B      29194 
L0237:
  DS.B      29204 

L0238:
  DS.B      29200 
L0239:
  DS.B      29204 

L023A:
  DS.B      6 
delta_filler_code:
  DS.B      29194 
L023C:
  DS.B      29204 

L023D:
  DS.B      18
wipe_new_code:
  DS.B      29182 
L023F:
  DS.B      29204 

L0240:
  DS.B      18
paint_new_code:
  DS.B      29182 
L0242:
  DS.B      29204 

L0243:
  DS.B      18
filler_code:
  DS.B      29182 
L0245:
  DS.B      29204 

L0246:
  DS.B      10
wipe_code:
  DS.B      29190 
L0248:
  DS.B      29206 

L0249:
  DS.W      1 
L024A:
  DS.W      1 
L024B:
  DS.W      1 
L024C:
  DS.W      1 
L024D:
  DS.W      1 
L024E:
  DS.W      1 
L024F:
  DS.W      1 
L0250:
  DS.L      1 
L0251:
  DS.W      1 
; log phys screen (on 16 bit bounds)
L0252:
  DS.L      1 
L0253:
  DS.L      1 
ZUEND: END

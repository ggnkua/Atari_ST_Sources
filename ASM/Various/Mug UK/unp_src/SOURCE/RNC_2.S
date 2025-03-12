;
; RNC Packer (Used on Populous II)
; --------------------------------
;
; Header = RNC(+$01)
; a0 = source
; a1 = destination

; Disassembled & Working Out by MUG U.K(tm) - 24/6/1992
; For inclusion in Multi Depacker v2.0 !!

	opt	d+

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_sp

	lea	packed(pc),a0
	lea	destin(pc),a1
	bsr	dpak_rnc

	move.l	old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

dpak_rnc          MOVEM.L   A0-A7/D0-D7,reg_save
                  BSR       L001C 
                  CMP.L     #$524E4301,D0 	; check for 'RNC'
                  BNE.B     L0004 
                  BSR       L001C 
                  LEA       4(A0),A4
                  LEA       0(A4,D0.L),A2 
                  ADDA.L    #$100,A2
                  MOVEA.L   A2,A3 
                  BSR       L001C 
                  LEA       0(A4,D0.L),A6 
                  MOVE.B    -(A6),D3
L0001:            BSR       L0007 
                  ADDQ.W    #1,D5 
                  CMPA.L    A4,A6 
                  BLE.B     L0003 
                  BSR       L000F 
                  BSR       L0015 
                  SUBQ.W    #1,D6 
                  LEA       0(A3,D7.W),A0 
                  EXT.L     D6
                  ADDA.L    D6,A0 
                  TST.W     D7
                  BNE.B     L0002 
                  LEA       1(A3),A0
L0002:            MOVE.B    -(A0),-(A3) 
		MOVE.B	(A0),$FFFF8240.W
                  DBF       D6,L0002
                  BRA.B     L0001 
;
; When finished we end up here
;

L0003:            MOVE.L    A2,D0 
                  SUB.L     A3,D0 
                  MOVEA.L   A3,A0 
                  BRA       L001E 
L0004:            MOVEQ     #0,D0 
                  BRA       L001E 
L0005:            LSL.B     #1,D3 
                  BNE.B     L0006 
                  MOVE.B    -(A6),D3
                  ROXL.B    #1,D3 
L0006:            RTS 

L0007:            MOVEQ     #-1,D5 
                  BSR       L0005 
                  BCC.B     L000D 
                  MOVEQ     #0,D5 
                  BSR       L0005 
                  BCC.B     L000B 
                  LEA       L000E(PC),A0
                  MOVEQ     #3,D1 
L0008:            CLR.W     D5
                  MOVE.B    0(A0,D1.W),D0 
                  EXT.W     D0
                  MOVEQ     #-1,D2 
                  LSL.W     D0,D2 
                  NOT.W     D2
                  SUBQ.W    #1,D0 
L0009:            BSR       L0005 
                  ROXL.W    #1,D5 
                  DBF       D0,L0009
                  TST.W     D1
                  BEQ.B     L000A 
                  CMP.W     D5,D2 
                  DBNE      D1,L0008
L000A:            MOVE.B    4(A0,D1.W),D0 
                  EXT.W     D0
                  ADD.W     D0,D5 
L000B:            MOVE.W    D5,-(A7)
L000C:            MOVE.B    -(A6),-(A3) 
                  DBF       D5,L000C
                  MOVE.W    (A7)+,D5
L000D:            RTS 
L000E:            DC.B      10,3,2,2,14,7,4,1 

L000F:            LEA       L0014(PC),A0
                  MOVEQ     #3,D0 
L0010:            BSR       L0005 
                  BCC.B     L0011 
                  DBF       D0,L0010
L0011:            CLR.W     D6
                  ADDQ.W    #1,D0 
                  MOVE.B    0(A0,D0.W),D1 
                  BEQ.B     L0013 
                  EXT.W     D1
                  SUBQ.W    #1,D1 
L0012:            BSR       L0005 
                  ROXL.W    #1,D6 
                  DBF       D1,L0012
L0013:            MOVE.B    5(A0,D0.W),D1 
                  EXT.W     D1
                  ADD.W     D1,D6 
                  RTS 
L0014:            DC.B      10,2,1,0,0,10,6,4,3,2 
L0015:            MOVEQ     #0,D7 
                  CMP.W     #2,D6 
                  BEQ.B     L0019 
                  MOVEQ     #1,D0 
L0016:            BSR       L0005 
                  BCC.B     L0017 
                  DBF       D0,L0016
L0017:            ADDQ.W    #1,D0 
                  LEA       L001B(PC),A0
                  MOVE.B    0(A0,D0.W),D1 
                  EXT.W     D1
L0018:            BSR       L0005 
                  ROXL.W    #1,D7 
                  DBF       D1,L0018
                  LSL.W     #1,D0 
                  ADD.W     4(A0,D0.W),D7 
                  RTS 
L0019:            MOVEQ     #5,D0 
                  CLR.W     D1
                  BSR       L0005 
                  BCC.B     L001A 
                  MOVEQ     #8,D0 
                  MOVEQ     #$40,D1 
L001A:            BSR       L0005 
                  ROXL.W    #1,D7 
                  DBF       D0,L001A
                  ADD.W     D1,D7 
                  RTS 
L001B:            DC.B      11,4,7,0,1,32,0,0,0,32,0,0
L001C:            MOVEQ     #3,D1 
L001D:            LSL.L     #8,D0 
                  MOVE.B    (A0)+,D0
                  DBF       D1,L001D
                  RTS 

;
; Depacked file is now at 'packed'+268
;

L001E             MOVEM.L   reg_save,A0-A7/D0-D7
                  RTS


;L001E:            MOVE.L    D0,D3 
;                  MOVE.L    A1,D2 
;                  MOVEA.L   A0,A4 
;                  CMPI.W    #$601A,(A4) 
;                  BNE.B     L0022 
;                  TST.W     26(A4)
;                  BNE.B     RELOCATE
;                  LEA       28(A4),A3 
;                  ADDA.L    2(A4),A3
;                  ADDA.L    6(A4),A3
;                  ADDA.L    14(A4),A3 
;                  MOVE.L    (A3)+,D0
;                  BEQ.B     RELOCATE
;                  LEA       28(A4),A2 
;                  ADDA.L    D0,A2 
;                  MOVEQ     #0,D0 
;L001F:            ADD.L     D2,(A2) 
;L0020:            MOVE.B    (A3)+,D0
;                  BEQ.B     RELOCATE
;                  ADDA.L    D0,A2 
;                  CMP.B     #1,D0 
;                  BNE.B     L001F 
;                  ADDA.L    #$FD,A2 
;                  BRA.B     L0020 
;
;
;RELOCATE:         MOVEA.L   68(A7),A2 
;                  MOVE.L    2(A4),12(A2)
;                  MOVE.L    6(A4),20(A2)
;                  MOVE.L    10(A4),28(A2) 
;                  MOVE.L    D2,8(A2)
;                  MOVE.L    D2,D0 
;                  ADD.L     2(A4),D0
;                  MOVE.L    D0,16(A2) 
;                  ADD.L     6(A4),D0
;                  MOVE.L    D0,24(A2) 
;L0022:            MOVE.L    D3,D0 
;                  MOVE.L    D0,-(A7)
;                  MOVE.L    A0,D1 
;                  SUB.L     A1,D1 
;                  MOVE.L    2(A0),D0
;                  ADD.L     6(A0),D0
;                  LEA       28(A0),A0 
;                  SUB.L     D0,(A7) 
;                  ADD.L     (A7)+,D1
;                  rts
;                  MOVE.L    #$5C4E75,-(A7)
;                  MOVE.L    #$204FEF,-(A7)
;                  MOVE.L    #$4CEF7FFF,-(A7)
;                  MOVE.L    #$538166FA,-(A7)
;                  MOVE.L    #$66FA4219,-(A7)
;                  MOVE.L    #$12D85380,-(A7)
;                  MOVE.L    #$2549005C,-(A7)
;                  MOVE.L    #$45FAFFFE,-(A7)
;                  JMP       (A7)
; END

old_sp	ds.l	1
reg_save	ds.l	16

packed	incbin	'd:\credits.dat'
endpack	even

destin	ds.l	1
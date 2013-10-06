;#####################################################################################
;	PROTOTYPES
;#####################################################################################

    xdef	Packer_DepackIce
	xdef	Packer_DepackAtomic

	
;#####################################################################################
	TEXT
;#####################################################################################

;-----------------------------------------------------------------------------------*
;
; Function:    void Packer_DepackIce( void * apData )
;
; Description: depacks ice packed apData to apData
;
; Created:     Axe/Delight
;
;-----------------------------------------------------------------------------------*

Packer_DepackIce:
	move.l	a0,-(a7)

	link	a3,#-120
	movem.l	d0-d7/a0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
	bne	.not_packed
	bsr	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture:
	movem.l	(sp),d0-d7/a0-a3

.move:
	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest:
	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-d7/a0-a6
	unlk	a3
	move.l	(a7)+,a0
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_ober
.get_ober:
	bsr.s	.get_d0_bits
.no_ober:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: 
    bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes



.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l 270-1,15-1,8-1,5-1,2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b 11,4,7,0		; Bits lesen
	dc.w $11f,-1,$1f	; Standard Offset


;-----------------------------------------------------------------------------------*
;
; Function:    void Packer_DepackAtomic( void * apData )
;
; Description: depacks atomic packed apData to apData
;
; Created:     Altair/Vmax
;
;-----------------------------------------------------------------------------------*

Packer_DepackAtomic:
  MOVEM.L   A0-A6/D0-D7,-(A7) 
  CMPI.L    #1096043829,(A0)+ 
  BNE       AM029 
  LINK      A2,#-28 
  MOVE.L    (A0)+,D0
  LEA       4(A0,D0.L),A5 
  MOVE.L    D0,-(A7)
  MOVEA.L   A5,A4 
  LEA       128(A4),A5
  LEA       -12(A4),A4
  MOVE.L    (A0)+,D0
  MOVEA.L   A0,A6 
  ADDA.L    D0,A6 
  SUBQ.W    #1,A6 
  MOVE.B    -(A6),D7
  BRA       AM01F 
AM000:
  MOVE.W    D3,D5 
AM001:
  ADD.B     D7,D7 
AM002:
  DBCS      D5,AM001
  BEQ.S     AM005 
  BCC.S     AM003 
  SUB.W     D3,D5 
  NEG.W     D5
  BRA.S     AM008 
AM003:
  MOVEQ     #3,D6 
  BSR.S     AM00E 
  BEQ.S     AM004 
  BRA.S     AM007 
AM004:
  MOVEQ     #7,D6 
  BSR.S     AM00E 
  BEQ.S     AM006 
  ADDI.W    #15,D5
  BRA.S     AM007 
AM005:
  MOVE.B    -(A6),D7
  ADDX.B    D7,D7 
  BRA.S     AM002 
AM006:
  MOVEQ     #13,D6
  BSR.S     AM00E 
  ADDI.W    #270,D5 
AM007:
  ADD.W     D3,D5 
AM008:
  LEA       AM02A(PC),A4
  MOVE.W    D5,D2 
  BNE.S     AM012 
  ADD.B     D7,D7 
  BNE.S     AM009 
  MOVE.B    -(A6),D7
  ADDX.B    D7,D7 
AM009:
  BCS.S     AM00A 
  MOVEQ     #1,D6 
  BRA.S     AM013 
AM00A:
  MOVEQ     #3,D6 
  BSR.S     AM00E 
  TST.B     -28(A2) 
  BEQ.S     AM00B 
  MOVE.B    -18(A2,D5.W),-(A5)
  BRA       AM01E 
AM00B:
  MOVE.B    (A5),D0 
  BTST      #3,D5 
  BNE.S     AM00C 
  BRA.S     AM00D 
AM00C:
  ADDI.B    #-16,D5 
AM00D:
  SUB.B     D5,D0 
  MOVE.B    D0,-(A5)
  BRA       AM01E 
AM00E:
  CLR.W     D5
AM00F:
  ADD.B     D7,D7 
  BEQ.S     AM011 
AM010:
  ADDX.W    D5,D5 
  DBF       D6,AM00F
  TST.W     D5
  RTS 
AM011:
  MOVE.B    -(A6),D7
  ADDX.B    D7,D7 
  BRA.S     AM010 
AM012:
  MOVEQ     #2,D6 
AM013:
  BSR.S     AM00E 
  MOVE.W    D5,D4 
  MOVE.B    14(A4,D4.W),D6
  EXT.W     D6
  TST.B     -27(A2) 
  BNE.S     AM014 
  ADDQ.W    #4,D6 
  BRA.S     AM018 
AM014:
  BSR.S     AM00E 
  MOVE.W    D5,D1 
  LSL.W     #4,D1 
  MOVEQ     #2,D6 
  BSR.S     AM00E 
  CMP.B     #7,D5 
  BLT.S     AM016 
  MOVEQ     #0,D6 
  BSR.S     AM00E 
  BEQ.S     AM015 
  MOVEQ     #2,D6 
  BSR.S     AM00E 
  ADD.W     D5,D5 
  OR.W      D1,D5 
  BRA.S     AM019 
AM015:
  OR.B      -26(A2),D1
  BRA.S     AM017 
AM016:
  OR.B      -25(A2,D5.W),D1 
AM017:
  MOVE.W    D1,D5 
  BRA.S     AM019 
AM018:
  BSR.S     AM00E 
AM019:
  ADD.W     D4,D4 
  BEQ.S     AM01A 
  ADD.W     -2(A4,D4.W),D5
AM01A:
  LEA       1(A5,D5.W),A4 
  MOVE.B    -(A4),-(A5) 
AM01B:
  MOVE.B    -(A4),-(A5) 
  DBF       D2,AM01B
  BRA.S     AM01E 
AM01C:
  ADD.B     D7,D7 
  BNE.S     AM01D 
  MOVE.B    -(A6),D7
  ADDX.B    D7,D7 
AM01D:
  BCS.S     AM027 
  MOVE.B    -(A6),-(A5) 
AM01E:
  CMPA.L    A5,A3 
  BNE.S     AM01C 
  CMPA.L    A6,A0 
  BEQ.S     AM028 
AM01F:
  MOVEQ     #0,D6 
  BSR       AM00E 
  BEQ.S     AM022 
  MOVE.B    -(A6),D0
  LEA       -26(A2),A1
  MOVE.B    D0,(A1)+
  MOVEQ     #1,D1 
  MOVEQ     #6,D2 
AM020:
  CMP.B     D0,D1 
  BNE.S     AM021 
  ADDQ.W    #2,D1 
AM021:
  MOVE.B    D1,(A1)+
  ADDQ.W    #2,D1 
  DBF       D2,AM020
  ST        -27(A2) 
  BRA.S     AM023 
AM022:
  SF        -27(A2) 
AM023:
  MOVEQ     #0,D6 
  BSR       AM00E 
  BEQ.S     AM025 
  LEA       -18(A2),A1
  MOVEQ     #15,D0
AM024:
  MOVE.B    -(A6),(A1)+ 
  DBF       D0,AM024
  ST        -28(A2) 
  BRA.S     AM026 
AM025:
  SF        -28(A2) 
AM026:
  CLR.W     D3
  MOVE.B    -(A6),D3
  MOVE.B    -(A6),D0
  LSL.W     #8,D0 
  MOVE.B    -(A6),D0
  MOVEA.L   A5,A3 
  SUBA.W    D0,A3 
  BRA.S     AM01C 
AM027:
  BRA       AM000 
AM028:
  MOVE.L    (A7)+,D0
  BSR       AM02B 
  UNLK      A2
AM029:
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTS 
AM02A:
  DC.B      $00,' ',$00,'`',$01,'`',$03,'`' 
  DC.B      $07,'`',$0F,'`',$1F,'`',$00,$01 
  DC.B      $03,$04,$05,$06,$07,$08 
AM02B:
  LSR.L     #4,D0 
  LEA       -12(A6),A6
AM02C:
  MOVE.L    (A5)+,(A6)+ 
  MOVE.L    (A5)+,(A6)+ 
  MOVE.L    (A5)+,(A6)+ 
  MOVE.L    (A5)+,(A6)+ 
  DBF       D0,AM02C
  RTS 


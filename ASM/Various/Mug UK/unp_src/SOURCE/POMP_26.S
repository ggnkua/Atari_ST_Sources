;
; Pompey Pirates v2.6 Depack Routine
; ----------------------------------
;
; A2 = Beginning of packed file
; A4 = End of packed file (1 byte after 'POPI' header)
; A3 = Destination ?
;
; Call in supervisor (palette flash)

unpack	movem.l	d0-a6,-(sp)	; start of packed file
	movea.l	a4,a0 		; finish address
	movea.l	a2,a3
	subq.l	#4,a0 
	adda.l	-(a0),a2
;	movea.l	a2,a4		; save end address for clearing
	subq.l	#4,a0 
	lea	$ffff8240.w,a6
	move.w	(a6),d5		; save current colour

empty	move.b	-(a0),d0		Unpack data.
	beq.s	empty			Not empty.

L0001:MOVEQ     #0,D2 
      BSR.B     L000B 
      BCS.B     L0004 
      MOVE.B    -(A0),D2
L0002:MOVE.B    D2,-(A2)
      BRA.B     L0006 
L0003:MOVEQ     #$F,D4
      MOVEQ     #2,D3 
      BSR.B     L000E 
      BNE.B     L000A 
      MOVE.W    D4,D2 
      BRA.B     L0002 
L0004:BSR.B     L000B 
      BCC.B     L0008 
      BSR.B     L000B 
      BCC.B     L0003 
      BSR.B     L000B 
      BCS.B     L0005 
      MOVEQ     #2,D1 
      BSR.B     L0011 
      EXG       D2,D1 
      ADDQ.W    #1,D2 
      BSET      D1,D2 
      BRA.B     L0002 
L0005:BSR.B     L000B 
      BCS.B     L0007 
      MOVEQ     #$F,D4
      MOVEQ     #3,D3 
      BSR.B     L000E 
      BNE.B     L000A 
      MOVE.B    (A2),-(A2)
L0006:MOVE.W    D2,(A6) 
      MOVE.W    D5,(A6) 
      CMPA.L    A2,A3 
      BLT.B     L0001 

	movem.l	(sp)+,d0-a6
      rts

L0007:MOVEQ     #4,D3 
      BRA.B     L0009 
L0008:BSR.B     L000B 
      BCS.B     L0015 
      MOVEQ     #1,D1 
      BSR.B     L0011 
      MOVE.W    D2,D1 
      BEQ.B     L0014 
      ADDQ.W    #1,D1 
      ADD.W     D1,D1 
      SUBQ.W    #1,D1 
      BSR.B     L0011 
      MOVE.W    D2,D3 
L0009:BSR.B     L000D 
L000A:MOVE.B    0(A2,D2.W),-(A2)
      DBF       D3,L000A
      BRA.B     L0006 
L000B:LSR.B     #1,D0 
      BNE.B     L000C 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L000C:RTS 
L000D:MOVEQ     #0,D4 
L000E:MOVEQ     #1,D1 
      MOVEQ     #0,D2 
L000F:LSR.B     #1,D0 
      BNE.B     L0010 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0010:ADDX.W    D2,D2 
      DBF       D1,L000F
      MOVE.W    D2,D1 
      ADDQ.W    #1,D1 
      LSL.W     #2,D1 
      SUBQ.W    #1,D1 
      EOR.B     D1,D4 
      BNE.B     L0011 
      RTS 
L0011:MOVEQ     #0,D2 
L0012:LSR.B     #1,D0 
      BNE.B     L0013 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0013:ADDX.W    D2,D2 
      DBF       D1,L0012
      RTS 
L0014:BSR.B     L000D 
      MOVE.W    D2,D3 
      MOVEQ     #0,D2 
      BRA.B     L000A 
L0015:MOVEQ     #1,D3 
      MOVE.B    -(A0),D2
      BRA.B     L000A 


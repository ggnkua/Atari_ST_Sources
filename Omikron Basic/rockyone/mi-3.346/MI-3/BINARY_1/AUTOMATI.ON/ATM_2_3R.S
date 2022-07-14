;rockyone			for MI-3 MI-9			26.03.2018
;
; I changed the reading of files sizes
; and the test : end of unpaking
;
;			File packed by automtion v2.3.r
;			Degas and Canvas v1.0
;			---------------------
;
; Destination 	size :  32034 or 3266 for Degas, 32000 for Canvas v1.0
; Files% 	0 degas
;		1 Canvas v1.0
;				    a0            a1        
;			v2_3_r( L source, L destination, W File%  )
;			------------------------------------------
; Return -2 in low d0 
;	If the unpacked size does not match the size of degas file.
;	
;
; Canvas has the palette ( 48 bytes ) before the tag 'LSD!'  
;.........................................................................
;should now be capable of decoding from odd to odd addresses
;11th October 1989
;-------------------------------------------------------------------------
; free d5-d7/a5-a6
; A0 source
; A1 desdination, buffer 32066 bytes

	movem.l	d1-d7/a0-a6,-(sp)
	movem.l	60(sp),a0-a1

*	cmpi.l	#'LSD!',(a0)+		; test performed at MI3-9
*	bne	error
	adda.l	#4,a0			
	move.l	(a0)+,d5		; size source depacked

;.................................ADD....Test file size depacked..........	
	moveq.l	#-2,d0			:R. bad file
	tst.w	68(sp)			;file Canvas v1.0 ".cnv" ?
	beq.s	degas
	cmpi.l	#32000,d5		
	beq.s	ok_file
degas:	cmpi.l	#32034,d5		
	beq.s	ok_file
	cmpi.l	#32066,d5
	bne	end_prg			; bad file !
ok_file: 

;.........................................................................
	movea.l	a1,a4
	adda.w	d5,a1			; end destination

	move.l	(a0),d0			; size source packed
	lea.l	-4(a0,d0.w),a0		; end source

	move.b	-2(a0),d0
	lsl.w   #8,d0
	move.b	-1(a0),d0
	subq.l	#2,a0
	tst.w   d0
	bpl.s	L_1
	subq.l	#1,a0
L_1:	move.b	-(a0),d0
L_2:	lsl.b	#1,d0
	bne.s	L_3
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_3:	BCC.S   L_10
	CLR.W   D1
	LSL.B   #1,D0
	BNE.S   L_4
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_4:	BCC.S   L_9
	LEA	NUMS(PC),A3
	MOVEQ   #3,D3
L_5:	CLR.W   D1
	MOVE.B	0(A3,D3.W),D2
	EXT.W   D2
	MOVEQ   #-1,D4
	LSL.W   D2,D4
	NOT.W   D4
	SUBQ.W	#1,D2
L_6:	LSL.B   #1,D0
	BNE.S   L_7
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_7:	ROXL.W	#1,D1
	DBF	D2,L_6
	TST.W   D3
	BEQ.S   L_8
	CMP.W   D1,D4
	DBNE	D3,L_5
L_8:	MOVE.B	4(A3,D3.W),D2
	EXT.W   D2
	ADD.W   D2,D1
	bra.s	L_9

NUMS:	DC.B	$0A,$03,$02,$02,$0E,$07,$04,$01

L_9:	MOVE.B	-(A0),-(A1)
	DBF	D1,L_9

L_10:	cmpa.l	A4,A1		; end of unpacking ?
	beq	end_file

	LEA	NUMS2(PC),A3
	MOVEQ   #3,D2
L_11:	LSL.B   #1,D0
	BNE.S   L_12
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_12:	BCC.S   L_13
	DBF	D2,L_11

L_13:	CLR.W	D1
	ADDQ.W	#1,D2
	MOVE.B	0(A3,D2.W),D3
	BEQ.S   L_16
	EXT.W   D3
	SUBQ.W	#1,D3
L_14:	LSL.B   #1,D0
	BNE.S   L_15
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_15:	ROXL.W	#1,D1
	DBF	D3,L_14
L_16:	MOVE.B	5(A3,D2.W),D3
	EXT.W   D3
	ADD.W   D3,D1
	BRA	L_161

NUMS2:	DC.B   $0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02

L_161:	CMPI.W	#2,D1
	BEQ.S   L_22
	LEA	NUMS3(PC),A3
	MOVEQ   #1,D3
L_17:	LSL.B   #1,D0
	BNE.S   L_18
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_18:	BCC.S   L_19
	DBF	D3,L_17
L_19:	ADDQ.W	#1,D3
	CLR.W   D2
	MOVE.B	0(A3,D3.W),D4
	EXT.W   D4
L_20:	LSL.B   #1,D0
	BNE.S   L_21
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_21:	ROXL.W	#1,D2
	DBF	D4,L_20
	LSL.W   #1,D3
	ADD.W   4(A3,D3.W),D2
	BRA.S   L_26

NUMS3:	DC.B	$0B,$04,$07,$00,$01,$20,$00,$00
	DC.B	$00,$20,$00,$00

L_22:	CLR.W   D2
	MOVEQ   #5,D3
	CLR.W   D4
	LSL.b   #1,D0
	BNE.S   L_23
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_23:	BCC.S   L_24
	MOVEQ   #8,D3
	MOVEQ   #$40,D4
L_24:	LSL.B   #1,D0
	BNE.S   L_25
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L_25:	ROXL.W	#1,D2
	DBF	D3,L_24
	ADD.W   D4,D2
L_26:	LEA	0(A1,D2.W),A2
	EXT.L   D1
	ADDA.L	D1,A2
	SUBQ.W	#1,D1
L_27:	MOVE.B	-(A2),-(A1)
	DBF	D1,L_27
	BRA	L_2
;.........................................................................
end_file:	moveq.l	#0,d0	
end_prg:	movem.l (sp)+,d1-d7/a0-a6
      		rts
		end
;*************************************************************************
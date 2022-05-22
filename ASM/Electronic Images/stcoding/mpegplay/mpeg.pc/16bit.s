; IDCT/16bit true colour stuff. (CPU end).

; Falcon video register equates

vhz	        EQU $FFFF820A
voff_nl         EQU $FFFF820E
vwrap           EQU $FFFF8210
_stshift	EQU $FFFF8260
_spshift        EQU $FFFF8266
hht             EQU $FFFF8282
hbb             EQU $FFFF8284
hbe             EQU $FFFF8286
hdb             EQU $FFFF8288
hde             EQU $FFFF828A
hss             EQU $FFFF828C
hfs             EQU $FFFF828E
hee             EQU $FFFF8290
vft             EQU $FFFF82A2
vbb             EQU $FFFF82A4
vbe             EQU $FFFF82A6
vdb             EQU $FFFF82A8
vde             EQU $FFFF82AA
vss             EQU $FFFF82AC
vco_hi          EQU $FFFF82C0
vco             EQU $FFFF82C2

	export	Vsetmode,Montype,ASMDITH,ASMIDCT,SETVGA		  

Vsetmode:
	movem.l	d2-d4/a2-a4,-(sp)
	move.w	d0,-(sp)
	move.w	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	movem.l	(sp)+,d2-d4/a2-a4
	rts


Montype:
	movem.l	d2-d4/a2-a4,-(sp)
	move.w	#$59,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d2-d4/a2-a4
	rts

;--------------------------------------------------------------
; ASMDITH --
;	Converts image into 16 bit color.
;--------------------------------------------------------------

ASMDITH:
	movem.l d0-d7/a0-a6,-(sp)  
	move.l	4+60(a7),a0	; lum
	move.l	8+60(a7),a1	; cr
	move.l	12+60(a7),a2	; cb
	move.l	16+60(a7),a3	; out
	move.l	20+60(a7),d0	; rows
	move.l	24+60(a7),d1	; cols
	lea	(a0,d1),a4
	lea	(a3,d1*2),a5
	lea 	$ffffa206,a6
wait0:	BTST.B #1,-4(A6)
	BEQ.S wait0

	clr.l 	-2(a6)		; signal go!
	move.w	d0,d2
	asr.w	#1,d2
	move.w	d2,(a6)
	move.w	d1,d2
	asr.w	#1,d2
	move.w	d2,(a6)
wait1:	BTST.B #1,-4(A6)
	BEQ.S wait1

y_lp:	move.w	d1,d2
x_lp:	move.w	(a0)+,(a6)	; L = *lum1++; L = *lum1++;
	move.w	(a4)+,(a6)	; L = *lum2++; L = *lum2++;
	move.b	(a1)+,d3	; CR = *cr++
	lsl.w	#8,d3
	move.b	(a2)+,d3
	move.w	d3,(a6)		; CB = *cb++
wait2:	BTST.B #0,-4(A6)
	BEQ.S wait2

	move.w  (a6),(a3)+
	move.w  (a6),(a3)+
	move.w  (a6),(a5)+
	move.w  (a6),(a5)+
	subq.w 	#2,d2
	bgt.s 	x_lp

	lea	(a3,d1*2),a3
	lea	(a5,d1*2),a5
	add.w	d1,a0		; lum1 +=cols
	add.w	d1,a4		; lum2 +=cols
	subq.w	#2,d0		; rows-2
	bgt 	y_lp
	movem.l (sp)+,d0-d7/a0-a6
	rts

; Inverse discrete cosine transform (cpu end)
; a0 -> DCT elements

ASMIDCT:
   		moveq	#1,d0
		lea 	$ffffa206,a1
		move.l	d0,-2(a1)
		moveq #8-1,d0
lpd1:
		rept 	8
		move.w	(a0)+,d1
		ext.l	d1
		move.l	d1,-2(a1)
		endm
		dbf d0,lpd1
		lea -128(a0),a0
		moveq #8-1,d0
wait3:		BTST.B #0,-4(A1)
		BEQ.S wait3

lpd2:
		rept 	8
		move.w	(A1),(a0)+
		endm
		dbf d0,lpd2
		rts

; Set Video Mode to VGA True Colour 320x200.
; (hit the h/ware directly)

SETVGA:		movem.l d0-d7/a0-a6,-(sp)  
		move.l	a0,d7
		MOVE.W	#37,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP
		LEA	TC320_VGA(PC),A6
		move #(_spshift),a1
		clr.w	(a1)
		LEA (hht).w,A1
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		LEA (vft).w,A1
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		MOVE.B D7,$FFFF820D.W
		LSR.L #8,D7
		MOVE.B D7,$FFFF8203.W
		LSR.L #8,D7
		MOVE.B D7,$FFFF8201.W
		move #(voff_nl),a1
	        move.w  (a6)+,(a1)
		move #(vwrap),a1
		MOVE.W  (a6)+,(a1)
		movea #(vco),a1
                move.w  (a6)+,(a1)
		movea #(vco_hi),a1
                move.w  (a6)+,(a1)
		movea #(vhz),a1
                move.w  (a6)+,(a1)
		move #(_spshift),a1
		move.w  (a6),(a1)
		movem.l (sp)+,d0-d7/a0-a6
		RTS

TC320_VGA:	DC.W	$00C6 ; hht
		DC.W	$008D ; hbb
		DC.W	$0015 ; hbe
		DC.W	$02AC ; hdb
		DC.W	$0091 ; hde
		DC.W	$0096 ; hss
		DC.W	$0000 ; hfs
		DC.W	$0000 ; hee
		DC.W	$0419 ; vft
		DC.W	$03FF ; vbb
		DC.W	$003F ; vbe
		DC.W	$003F ; vdb
		DC.W	$03FF ; vde
		DC.W	$0415 ; vss
		DC.W	$0000 ; next line offset
		DC.W	$0140 ; vwrap
		DC.W	$0005 ; vco
		DC.W	$0186 ; vco hi
		DC.W	$0000 ; $ffff820a
		DC.W	$0100 ; spshift

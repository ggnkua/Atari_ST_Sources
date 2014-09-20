
;Draw large score font

	SECTION	TEXT

;----------------------------------
;Return pixel length of score in d0.w, pass 32-bit BCD value in d1.l
scorelargelength
	moveq.w	#0,d0							;Length in pixels
	move.l	d1,d2

	;Scan to skip leading zeroes
	moveq.w	#8-1,d4							;Check all 8 digits
.loop
	rol.l	#4,d2
	move.w	d2,d3
	and.w	#$f,d3							;Get BCD digit
	bne.s	.start							;Start with first non-zero digit
	dbra.w	d4,.loop
	moveq.w	#10,d0							;Score is 0
	rts										;Return length of '0' digit

	;Loop and total width of each digit
.loop2
	rol.l	#4,d2
	move.w	d2,d3
	and.w	#$f,d3							;Get BCD digit
.start
	add.w	#10,d0							;Each digit has width of 10 pixels
	cmp.w	#1,d3							;Except '1' which is just 6 pixels
	bne.s	.notone
	subq.w	#4,d0
.notone
	dbra.w	d4,.loop2
	rts

;----------------------------------
;Draw line of large score font, 156 cycles
SCORELARGELINE	MACRO
	movem.w	(a2)+,d4-d7				;28		;Using words is same speed as reading 32-bit mask to use and.l
	and.w	d4,(a1)+				;12
	and.w	d4,(a1)					;12
	or.w	d5,(a1)+				;12
	and.w	d4,(a1)+				;12
	and.w	d4,(a1)+				;12
	and.w	d6,(a1)+				;12
	and.w	d6,(a1)					;12
	or.w	d7,(a1)+				;12
	and.w	d6,(a1)+				;12
	and.w	d6,(a1)					;12
	lea		160-14(a1),a1			;8
	ENDM

;----------------------------------
;Draw large score, pass d0.w as screen X, d1.l as 32-bit BCD and a0.l as screen address
drawscorelarge
	;Scan to skip leading zeroes
	moveq.w	#8-1,d2					;4		;Draw all 8 digits
.loop
	rol.l	#4,d1					;16
	move.w	d1,d3					;4
	and.w	#$f,d3					;8		;Get BCD digit
	bne.s	.start					;10/8	;Found first non-zero digit
	dbra.w	d2,.loop				;10/14
	moveq.w	#1-1,d2					;4		;Set loop to draw single digit
	moveq.l	#0,d1					;4		;Score is 0

	;Loop and draw digits
.loop2
	rol.l	#4,d1					;16
	move.w	d1,d3					;4
	and.w	#$f,d3					;8		;Get BCD digit
.start
	moveq.w	#10,d4					;4		;Each digit has width of 10 pixels
	cmp.w	#1,d3					;8		;Except '1' which is just 6 pixels
	bne.s	.notone					;10/8
	moveq.w	#6,d4					;4
.notone
	lsl.w	#4,d3					;16		;*16 for index
	move.w	d0,d5					;4		;Copy X
	and.w	#$e,d5					;8		;Mask so X is 0...15 and always even
	add.w	d5,d3					;4
	lea		scorelargepreshift,a2	;12
	lea		largepreshifttbl,a3		;12
	add.w	(a3,d3.w),a2			;20		;Preshifted source
	move.w	d0,d5					;4		;Copy X
	lsr.w	#1,d5					;8
	and.w	#$fff8,d5				;8		;Offset for X
	lea		0(a0,d5.w),a1			;12		;Screen destination
	add.w	d4,d0					;4		;Offset X by width of digit

	REPT 18
	SCORELARGELINE					;156	;Draw lines of digit, 2808 cycles
	ENDR

	dbra.w	d2,.loop2				;10/14
	rts

;----------------------------------

	SECTION	DATA

largepreshifttbl							;Index table into preshifted font
	dc.w	(0*1152)+(144*0)				;0
	dc.w	(0*1152)+(144*1)
	dc.w	(0*1152)+(144*2)
	dc.w	(0*1152)+(144*3)
	dc.w	(0*1152)+(144*4)
	dc.w	(0*1152)+(144*5)
	dc.w	(0*1152)+(144*6)
	dc.w	(0*1152)+(144*7)
	dc.w	(1*1152)+(144*0)				;1
	dc.w	(1*1152)+(144*1)
	dc.w	(1*1152)+(144*2)
	dc.w	(1*1152)+(144*3)
	dc.w	(1*1152)+(144*4)
	dc.w	(1*1152)+(144*5)
	dc.w	(1*1152)+(144*6)
	dc.w	(1*1152)+(144*7)
	dc.w	(2*1152)+(144*0)				;2
	dc.w	(2*1152)+(144*1)
	dc.w	(2*1152)+(144*2)
	dc.w	(2*1152)+(144*3)
	dc.w	(2*1152)+(144*4)
	dc.w	(2*1152)+(144*5)
	dc.w	(2*1152)+(144*6)
	dc.w	(2*1152)+(144*7)
	dc.w	(3*1152)+(144*0)				;3
	dc.w	(3*1152)+(144*1)
	dc.w	(3*1152)+(144*2)
	dc.w	(3*1152)+(144*3)
	dc.w	(3*1152)+(144*4)
	dc.w	(3*1152)+(144*5)
	dc.w	(3*1152)+(144*6)
	dc.w	(3*1152)+(144*7)
	dc.w	(4*1152)+(144*0)				;4
	dc.w	(4*1152)+(144*1)
	dc.w	(4*1152)+(144*2)
	dc.w	(4*1152)+(144*3)
	dc.w	(4*1152)+(144*4)
	dc.w	(4*1152)+(144*5)
	dc.w	(4*1152)+(144*6)
	dc.w	(4*1152)+(144*7)
	dc.w	(5*1152)+(144*0)				;5
	dc.w	(5*1152)+(144*1)
	dc.w	(5*1152)+(144*2)
	dc.w	(5*1152)+(144*3)
	dc.w	(5*1152)+(144*4)
	dc.w	(5*1152)+(144*5)
	dc.w	(5*1152)+(144*6)
	dc.w	(5*1152)+(144*7)
	dc.w	(6*1152)+(144*0)				;6
	dc.w	(6*1152)+(144*1)
	dc.w	(6*1152)+(144*2)
	dc.w	(6*1152)+(144*3)
	dc.w	(6*1152)+(144*4)
	dc.w	(6*1152)+(144*5)
	dc.w	(6*1152)+(144*6)
	dc.w	(6*1152)+(144*7)
	dc.w	(7*1152)+(144*0)				;7
	dc.w	(7*1152)+(144*1)
	dc.w	(7*1152)+(144*2)
	dc.w	(7*1152)+(144*3)
	dc.w	(7*1152)+(144*4)
	dc.w	(7*1152)+(144*5)
	dc.w	(7*1152)+(144*6)
	dc.w	(7*1152)+(144*7)
	dc.w	(8*1152)+(144*0)				;8
	dc.w	(8*1152)+(144*1)
	dc.w	(8*1152)+(144*2)
	dc.w	(8*1152)+(144*3)
	dc.w	(8*1152)+(144*4)
	dc.w	(8*1152)+(144*5)
	dc.w	(8*1152)+(144*6)
	dc.w	(8*1152)+(144*7)
	dc.w	(9*1152)+(144*0)				;9
	dc.w	(9*1152)+(144*1)
	dc.w	(9*1152)+(144*2)
	dc.w	(9*1152)+(144*3)
	dc.w	(9*1152)+(144*4)
	dc.w	(9*1152)+(144*5)
	dc.w	(9*1152)+(144*6)
	dc.w	(9*1152)+(144*7)


;Draw small score font

	SECTION	TEXT

;----------------------------------
;Return pixel length of score in d0.w, pass 32-bit BCD value in d1.l
scoresmalllength
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
	moveq.w	#6,d0							;Score is 0
	rts										;Return length of '0' digit

	;Loop and total width of each digit
.loop2
	rol.l	#4,d2
	move.w	d2,d3
	and.w	#$f,d3							;Get BCD digit
.start
	addq.w	#6,d0							;Each digit has width of 6 pixels
	cmp.w	#1,d3							;Except '1' which is just 4 pixels
	bne.s	.notone
	subq.w	#2,d0
.notone
	dbra.w	d4,.loop2
	rts

;----------------------------------
;Draw line of small score font, 92 cycles
SCORESMALLLINE	MACRO
	movem.w	(a2)+,d4-d7				;28
	or.w	d5,\1+2(a1)				;16		;Write on background colour 8
	and.w	d4,\1+6(a1)				;16
	or.w	d7,\1+10(a1)			;16
	and.w	d6,\1+14(a1)			;16
	ENDM

;----------------------------------
;Draw small score, pass d0.w as screen X, d1.l as 32-bit BCD and a0.l as screen address
drawscoresmall
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
	moveq.w	#6,d4					;4		;Each digit has width of 6 pixels
	cmp.w	#1,d3					;8		;Except '1' which is just 4 pixels
	bne.s	.notone					;10/8
	moveq.w	#4,d4					;4
.notone
	lsl.w	#4,d3					;16		;*16 for index
	move.w	d0,d5					;4		;Copy X
	and.w	#$e,d5					;8		;Mask so X is 0...15 and always even
	add.w	d5,d3					;4
	lea		scoresmallpreshift,a2	;12
	lea		smallpreshifttbl,a3		;12
	add.w	(a3,d3.w),a2			;20		;Preshifted source
	move.w	d0,d5					;4		;Copy X
	lsr.w	#1,d5					;8
	and.w	#$fff8,d5				;8		;Offset for X
	lea		0(a0,d5.w),a1			;12		;Screen destination
	add.w	d4,d0					;4		;Offset X by width of digit

	SCORESMALLLINE	160*0			;92		;Draw lines of digit, 920 cycles
	SCORESMALLLINE	160*1
	SCORESMALLLINE	160*2
	SCORESMALLLINE	160*3
	SCORESMALLLINE	160*4
	SCORESMALLLINE	160*5
	SCORESMALLLINE	160*6
	SCORESMALLLINE	160*7
	SCORESMALLLINE	160*8
	SCORESMALLLINE	160*9

	dbra.w	d2,.loop2				;10/14
	rts

;----------------------------------

	SECTION	DATA

smallpreshifttbl							;Index table into preshifted font
	dc.w	(0*640)+(80*0)					;0
	dc.w	(0*640)+(80*1)
	dc.w	(0*640)+(80*2)
	dc.w	(0*640)+(80*3)
	dc.w	(0*640)+(80*4)
	dc.w	(0*640)+(80*5)
	dc.w	(0*640)+(80*6)
	dc.w	(0*640)+(80*7)
	dc.w	(1*640)+(80*0)					;1
	dc.w	(1*640)+(80*1)
	dc.w	(1*640)+(80*2)
	dc.w	(1*640)+(80*3)
	dc.w	(1*640)+(80*4)
	dc.w	(1*640)+(80*5)
	dc.w	(1*640)+(80*6)
	dc.w	(1*640)+(80*7)
	dc.w	(2*640)+(80*0)					;2
	dc.w	(2*640)+(80*1)
	dc.w	(2*640)+(80*2)
	dc.w	(2*640)+(80*3)
	dc.w	(2*640)+(80*4)
	dc.w	(2*640)+(80*5)
	dc.w	(2*640)+(80*6)
	dc.w	(2*640)+(80*7)
	dc.w	(3*640)+(80*0)					;3
	dc.w	(3*640)+(80*1)
	dc.w	(3*640)+(80*2)
	dc.w	(3*640)+(80*3)
	dc.w	(3*640)+(80*4)
	dc.w	(3*640)+(80*5)
	dc.w	(3*640)+(80*6)
	dc.w	(3*640)+(80*7)
	dc.w	(4*640)+(80*0)					;4
	dc.w	(4*640)+(80*1)
	dc.w	(4*640)+(80*2)
	dc.w	(4*640)+(80*3)
	dc.w	(4*640)+(80*4)
	dc.w	(4*640)+(80*5)
	dc.w	(4*640)+(80*6)
	dc.w	(4*640)+(80*7)
	dc.w	(5*640)+(80*0)					;5
	dc.w	(5*640)+(80*1)
	dc.w	(5*640)+(80*2)
	dc.w	(5*640)+(80*3)
	dc.w	(5*640)+(80*4)
	dc.w	(5*640)+(80*5)
	dc.w	(5*640)+(80*6)
	dc.w	(5*640)+(80*7)
	dc.w	(6*640)+(80*0)					;6
	dc.w	(6*640)+(80*1)
	dc.w	(6*640)+(80*2)
	dc.w	(6*640)+(80*3)
	dc.w	(6*640)+(80*4)
	dc.w	(6*640)+(80*5)
	dc.w	(6*640)+(80*6)
	dc.w	(6*640)+(80*7)
	dc.w	(7*640)+(80*0)					;7
	dc.w	(7*640)+(80*1)
	dc.w	(7*640)+(80*2)
	dc.w	(7*640)+(80*3)
	dc.w	(7*640)+(80*4)
	dc.w	(7*640)+(80*5)
	dc.w	(7*640)+(80*6)
	dc.w	(7*640)+(80*7)
	dc.w	(8*640)+(80*0)					;8
	dc.w	(8*640)+(80*1)
	dc.w	(8*640)+(80*2)
	dc.w	(8*640)+(80*3)
	dc.w	(8*640)+(80*4)
	dc.w	(8*640)+(80*5)
	dc.w	(8*640)+(80*6)
	dc.w	(8*640)+(80*7)
	dc.w	(9*640)+(80*0)					;9
	dc.w	(9*640)+(80*1)
	dc.w	(9*640)+(80*2)
	dc.w	(9*640)+(80*3)
	dc.w	(9*640)+(80*4)
	dc.w	(9*640)+(80*5)
	dc.w	(9*640)+(80*6)
	dc.w	(9*640)+(80*7)

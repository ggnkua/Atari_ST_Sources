
;Ticker message scrolling across bottom of screen

MSGHISCOREOFFSET = 74						;Offset of '00000000' in ticker message - MUST be even

	SECTION	TEXT
	
;----------------------------------
;Initialise ticker
tickerinit
	move.l	#tickermsg,currentmsg
	moveq.w	#0,d0
	move.b	d0,tickergap
	move.w	d0,tickerdelay
	bra		tickerclear						;(does RTS)

;----------------------------------
;Clear ticker workspace on initialise
tickerclear
	lea		ticker,a0						;Ticker workspace
	
	moveq.w	#0,d0
	move.w	#21*7-1,d1						;Clear 320+16 pixels by 7 lines
.loop
	move.w	d0,(a0)+
	dbra.w	d1,.loop
	rts
	
;----------------------------------
;Set highscore value in ticker message
tickersethighscore
	lea		tickermsg,a0
	lea		MSGHISCOREOFFSET(a0),a0			;Start of '00000000' in message
	move.l	#$01010101,(a0)					;Blank all 8 digits with empty character
	move.l	#$01010101,4(a0)
	move.l	bcdhighscore,d0					;Read 32-bit BCD high-score

	;Scan to skip leading zeroes
	moveq.w	#8-1,d1							;Scan all 8 digits
.loop
	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2							;Get BCD digit
	bne.s	.go								;Found first non-zero digit
	dbra.w	d1,.loop
	move.b	#'0'-31,(a0)+					;Write score '0'
	rts

	;Loop and write digits
.loop2
	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2							;Get BCD digit
.go
	add.b	#'0'-31,d2
	move.b	d2,(a0)+						;Write digit
	dbra.w	d1,.loop2
	rts
	
;----------------------------------
;Update ticker
tickerupdate						;~=5 rasters
	move.w	tickerdelay,d0					;Are we in the middle of a delay?
	bne.s	.delay							;Yes
	bsr		tickerscroll					;Scroll by a pixel
	bra		tickercheck						;Can add character to end of ticker? (does RTS)

.delay
	subq.w	#1,tickerdelay					;Count down delay
	rts
	
;----------------------------------
;Check if can add next character at end of ticker
tickercheck
	add.b	#1,tickergap					;Add pixel gap after scroll
	move.l	currentmsg,a0
	moveq.w	#0,d0
	move.b	(a0),d0							;Read next character in message
	beq.s	.endmsg							;Check 0 for end of message
	blt.s	.startdelay						;Check <0 for delay
	move.b	fontgaps(pc,d0.w),d1			;Get gap needed for character
	cmp.b	tickergap,d1					;Is gap large enough?
	ble		tickeraddchar					;Yes, add character in d0.w (does RTS)
	rts

.endmsg
	move.l	#tickermsg,currentmsg			;Wrap message back to start
	move.b	#0,tickergap
	bra		tickersethighscore				;Update message with new high-score (does RTS)

.startdelay
	addq.l	#1,currentmsg					;Skip delay character in message
	move.w	#50*5,tickerdelay				;Delay for 5 seconds
	move.b	#0,tickergap
	rts

;----------------------------------

fontgaps
	dc.b	0
	dc.b	6,4,8,8,8,8,8,4,5,5,8,8,5,6,4,8	;  ! " # $ % & ' ( ) * + , - . /
	dc.b	8,5,8,8,8,8,8,8,8,8,4,5,7,6,7,8	;0 1 2 3 4 5 6 7 8 9 : ; < = > ?
	dc.b	8,8,8,7,8,8,8,8,8,4,5,8,8,8,8,8	;@ A B C D E F G H I J K L M N O
	dc.b	8,8,8,8,8,8,8,8,8,8,8,5,8,5,6,6	;P Q R S T U V W X Y Z [ \ ] ^ _
	dc.b	4,8,8,7,8,8,8,8,8,4,5,8,8,8,8,8	;` a b c d e f g h i j k l m n o
	dc.b	8,8,8,8,8,8,8,8,8,8,8,6,4,6,7	;p q r s t u v w x y z { | } ~

;----------------------------------
;Add character in d0.w to ticker
tickeraddchar						;248 cycles, 0.5 rasters
	addq.l	#1,currentmsg			;20		;Skip character in message
	move.b	#0,tickergap			;16
	cmp.w	#1,d0					;8		;Is character a space?
	ble.s	.space					;10/8	;Yes, skip

	lea		tickerimg,a0			;12
	lsl.w	#4,d0					;16		;Each character is 16 bytes
	add.w	d0,a0					;8		;Source plane
	lea		ticker,a1				;12		;Ticker workspace
	movem.w	(a0),d0-d6				;40		;Write character
	or.w	d0,(a1)					;12
	or.w	d1,42*1(a1)				;16
	or.w	d2,42*2(a1)				;16
	or.w	d3,42*3(a1)				;16
	or.w	d4,42*4(a1)				;16
	or.w	d5,42*5(a1)				;16
	or.w	d6,42*6(a1)				;16
.space
	rts

;----------------------------------
;Scroll single plane ticker workspace by a pixel
tickerscroll						;1920 cycles, 3.7 rasters
	lea		ticker,a0				;12		;Ticker workspace
	
	moveq.w	#7-1,d0					;4		;Plane workspace is 7 pixels high
.loop
	moveq.w	#0,d1					;4		;Clear X (faster than using CCR)
	neg.w	d1						;4
	REPT 21							;252
	roxl.w	(a0)+							;Shift plane (stored right to left to allow (a0)+ as faster)
	ENDR
	dbra.w	d0,.loop				;10/14
	rts

;----------------------------------
;Draw line of ticker to Plane 2, 328 cycles
TICKERDRAWLINE	MACRO
	addq.w	#2,a0					;8		;Skip scroll-in word
	move.w	(a0)+,\1+154(a1)		;16		;Copy line to Plane 2 (stored right to left)
	move.w	(a0)+,\1+146(a1)				;This is faster than using MOVEM
	move.w	(a0)+,\1+138(a1)
	move.w	(a0)+,\1+130(a1)
	move.w	(a0)+,\1+122(a1)
	move.w	(a0)+,\1+114(a1)
	move.w	(a0)+,\1+106(a1)
	move.w	(a0)+,\1+98(a1)
	move.w	(a0)+,\1+90(a1)
	move.w	(a0)+,\1+82(a1)
	move.w	(a0)+,\1+74(a1)
	move.w	(a0)+,\1+66(a1)
	move.w	(a0)+,\1+58(a1)
	move.w	(a0)+,\1+50(a1)
	move.w	(a0)+,\1+42(a1)
	move.w	(a0)+,\1+34(a1)
	move.w	(a0)+,\1+26(a1)
	move.w	(a0)+,\1+18(a1)
	move.w	(a0)+,\1+10(a1)
	move.w	(a0)+,\1+2(a1)
	ENDM
	
;----------------------------------
;Draw ticker to screen
tickerdraw							;2328 cycles, 4.5 rasters
	lea		ticker,a0				;12		;Ticker workspace
	move.l	offscreenbse,a1			;20

	TICKERDRAWLINE	160*192			;328	;Draw line of ticker to screen Plane 2
	TICKERDRAWLINE	160*193
	TICKERDRAWLINE	160*194
	TICKERDRAWLINE	160*195
	TICKERDRAWLINE	160*196
	TICKERDRAWLINE	160*197
	TICKERDRAWLINE	160*198
	rts

;----------------------------------

	SECTION	BSS

currentmsg		ds.l	1					;Pointer to current letter in ticker message
tickergap		ds.b	1					;Gap, in pixels, to write in next letter
	EVEN
tickerdelay		ds.w	1					;Delay countdown, in frames, when !=0 to hold ticker
ticker			ds.w	21*7				;Space for 320+16 pixels by 7 lines or total 294 bytes

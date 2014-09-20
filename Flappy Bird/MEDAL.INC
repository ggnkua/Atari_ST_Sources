
;'Game Over' screen

GAMEOVERTIMEOUT = 30*50						;Return to title screen after 30 seconds @ 50Hz

	SECTION	TEXT

;----------------------------------
;Initialise 'Medal' screen
medalinit
	bra		medalreset						;(does RTS)

;----------------------------------
;Reset for 'Game Over' screen
medalreset
	moveq.l	#0,d0
	move.l	d0,bcddisplayscore
	move.w	d0,newbest
	move.w	d0,awardmedal
	move.w	d0,medalcount
	move.w	d0,medaltimeout
	move.l	d0,medalpalette
	move.l	d0,medalpalette+4
	move.w	d0,exitcount
	lea		sparkles,a0
	bsr		medalrandomsparkle
	lea		SPARKLE_SIZE(a0),a0
	bra		medalrandomsparkle				;(does RTS)

;----------------------------------
;'Medal' screen handlers
medalhandler
	move.w	#RASTERSET_MEDAL,nextrasterset
	
	bsr		medaldrawscreen
	addq.w	#1,medalcount
	bra		medalcountscore					;(does RTS)

medalcompletehandler
	bsr		medaldrawscreen
	addq.w	#1,medaltimeout

	move.w	flapbutton,d0					;Read input
	beq.s	.noinput
	lea		gameoversfx,a0
	bsr		soundplay0
	move.w	#RASTERSET_BLACKOUT,nextrasterset
	move.l	#medalgetreadyhandler,handler
	rts										;Return here so don't check time-out
.noinput

	cmp.w	#GAMEOVERTIMEOUT,medaltimeout	;Time-out and go back to title
	bne.s	.notimeout
	move.w	#RASTERSET_BLACKOUT,nextrasterset
	move.l	#medaltitlehandler,handler
.notimeout
	rts

medalgetreadyhandler
	move.w	newbest,d0						;Write high-score to file if new
	beq.s	.nohighscore
	bsr		highscorewrite
.nohighscore
	bsr		skyrandomsky					;Random day or night sky
	bsr		gamebuildscreen					;Rebuild screen on both swap buffer while palette is black
	bsr		birdrandompalette
	bsr		getreadyreset
	move.l	#getreadyhandler,handler
	rts

medaltitlehandler
	move.w	newbest,d0
	beq.s	.nohighscore
	bsr		highscorewrite
.nohighscore
	bsr		skyrandomsky
	bsr		gamebuildscreen
	bsr		birdrandompalette
	bsr		titlereset
	move.l	#titlehandler,handler
	rts

;----------------------------------
;Draw 'Game Over' screen
medaldrawscreen
	bsr		medaldrawbkgnd
	bsr		medaldrawgameover

	move.w	awardmedal,d0
	bsr		medaldraw
	move.w	awardmedal,d0					;Draw sparkles if have medal
	beq.s	.nosparkles
	lea		sparkles,a0
	bsr		medaldrawsparkle
	lea		sparkles+SPARKLE_SIZE,a0
	bsr		medaldrawsparkle
.nosparkles

	move.l	bcddisplayscore,d1				;Score in 32-bit BCD format
	move.l	offscreenbse,a0
	lea		160*65(a0),a0
	bsr		medaldrawscore

	move.l	bcdhighscore,d1					;High-score in 32-bit BCD format
	move.l	offscreenbse,a0
	lea		160*86(a0),a0
	bra		medaldrawscore					;(does RTS)

;----------------------------------
;State to count up score and give award/high-score
medalcountscore
	;Check input to skip count up sequence
	move.w	flapbutton,d0					;Read input
	beq.s	.noinput
	move.l	bcdscore,bcddisplayscore
.noinput

	;Latch for counting up score (vary speed by value of score)
	moveq.w	#3,d1							;Slow speed
	move.l	bcdscore,d0
	cmp.l	#50,d0							;Is score <50? Count slow
	bls.s	.checklatch						;d0<= (unsigned)
	moveq.w	#1,d1							;Normal speed
	cmp.l	#100,d0							;Is score <100? Count normal
	bls.s	.checklatch						;d0<= (unsigned)
	bra.s	.countup						;Fast speed
.checklatch
	move.w	medalcount,d0					;Check latch to add one to count
	and.w	d1,d0
	beq.s	.countup
	rts

.countup
	move.l	bcddisplayscore,d0				;Read 32-bit BCD scores
	move.l	bcdscore,d1
	cmp.l	d0,d1							;Does display score match player score?
	beq.s	.giveaward
	lea		bcddisplayscore,a0				;Increment display score
	bra		gamescoreinc					;(does RTS)

.giveaward
	;Set medal as 20 for bronze, 40 silver, 60 gold and 80+ plantuim 
	move.l	bcdscore,d0						;Read 32-bit BCD score
	lsr.l	#4,d0							;Skip last digit
	cmp.l	#8,d0							;Clamp 0...8
	bls.s	.clamp							;d0<= (unsigned)
	moveq.l	#8,d0
.clamp
	lsr.w	#1,d0							;Divide by 2 for medal index 0...4
	move.w	d0,awardmedal

	lsl.w	#3,d0
	lea		medalpalettes(pc,d0.w),a1		;Source medal palettes
	lea		medalpalette,a2					;Destination palette
	move.l	(a1)+,(a2)+						;Copy 4 colours
	move.l	(a1),(a2)

	;Set new high-score
	move.l	bcdhighscore,d0					;Check if is new high-score
	move.l	bcdscore,d1
	cmp.l	d0,d1
	bls.s	.nohigh							;d1<=d0 (unsigned)
	move.w	#1,newbest						;Set as new high-score
	move.l	bcdscore,bcdhighscore
.nohigh

	move.l	#medalcompletehandler,handler
	rts

;----------------------------------

medalpalettes
	dc.w	$000,$000,$000,$000				;None
	dc.w	$521,$631,$740,$661				;Bronze
	dc.w	$222,$333,$555,$666				;Silver
	dc.w	$530,$651,$661,$671				;Gold
	dc.w	$333,$555,$666,$777				;Platinum

;----------------------------------
;Draw medal score, pass d1.w as score and a0.l as screen address
medaldrawscore
	bsr		scoresmalllength				;Get length of score in d0.w
	neg.w	d0
	add.w	#204,d0							;Right justified
	bra		drawscoresmall					;(does RTS)

;----------------------------------
;Draw 'Game Over' sprite
medaldrawgameover					;7840 cycles, 15 rasters
	move.l	offscreenbse,a1			;20
	lea		160*8+40(a1),a1			;8
	
	INCLUDE	"\SRC\DATA\GAMEOVER.INC"		;Compiled sprite, 7812 cycles
	rts

;----------------------------------
;Draw medal background
medaldrawbkgnd						;32 rasters
	move.l	offscreenbse,a0			;20
	lea		160*48+48(a0),a0		;8
	
	INCLUDE	"\SRC\DATA\MEDALBKG.INC"		;Compiled sprite	
	rts

;----------------------------------

medals
	dc.l	medalsimg+(368*0)
	dc.l	medalsimg+(368*1)
	dc.l	medalsimg+(368*2)
	dc.l	medalsimg+(368*3)
	dc.l	medalsimg+(368*4)

;----------------------------------
;Draw medal, d0.w is medal index
medaldraw							;2084 cycles, 4 rasters
	lsl.w	#2,d0					;12
	move.l	medals(pc,d0.w),a0		;20		;Source medal image
	move.l	offscreenbse,a1			;20
	lea		160*70+56(a1),a1		;8

	REPT 23							;2024
	move.l	(a0)+,(a1)+				;20		;Copy 32 pixels by 23 lines
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)
	lea		160-12(a1),a1			;8		;Next line
	ENDR
	rts

;----------------------------------
;Start random sparkle, pass a0.l as sparkle structure
medalrandomsparkle
	move.w	#0,SPARKLE_FRAME(a0)			;Reset animation frame
	
	bsr		utilrandbyte					;Get random value in d0.b
	and.w	#$3f,d0
	add.w	#16,d0
	move.w	d0,SPARKLE_TIME(a0)				;Store random time before show sparkle
	
	bsr		utilrandword					;Get random value in d0.w
	move.w	d0,d1
	and.w	#$7,d1							;Set 0...7
	move.w	d1,SPARKLE_XSET(a0)
	lsr.w	#3,d0
	and.w	#$f,d0							;Range 0...15
	add.w	#71,d0							;Screen Y
	add.w	d0,d0							;Look up screen line offset
	lea		screenlines,a1
	move.w	(a1,d0.w),SPARKLE_YOFFSET(a0)	;And store
	rts

;----------------------------------

sparkleanim
	dc.l	sparklepreshift+(480*0),sparklepreshift+(480*1),sparklepreshift+(480*2),sparklepreshift+(480*1),sparklepreshift+(480*0)

sparklesets
	dc.w	60*0,56
	dc.w	60*1,56
	dc.w	60*2,56
	dc.w	60*3,56
	dc.w	60*4,64
	dc.w	60*5,64
	dc.w	60*6,64
	dc.w	60*7,64

;----------------------------------
;Animate and draw sparkle, pass a0.l as sparkle structure
medaldrawsparkle					;778 cycles, 1.5 rasters
	move.w	SPARKLE_TIME(a0),d0		;12		;Count down time delay or draw sparkle
	ble.s	.draw					;10/8
	subq.w	#1,d0					;4
	move.w	d0,SPARKLE_TIME(a0)		;12
	rts

.draw
	move.w	SPARKLE_FRAME(a0),d0	;12
	addq.w	#1,d0					;4		;Advance sparkle frame
	cmp.w	#5*4,d0					;8		;Have shown all frames?
	bge		medalrandomsparkle		;10/8	;Yes, random next sparkle (does RTS)
	move.w	d0,SPARKLE_FRAME(a0)	;12
	and.w	#$fffc,d0				;8		;Get index
	move.l	sparkleanim(pc,d0.w),a2	;20		;Look up sprite frame
	move.w	SPARKLE_XSET(a0),d0		;12
	lsl.w	#2,d0					;12
	lea		sparklesets(pc,d0.w),a3	;12
	add.w	(a3)+,a2				;12		;Offset preshift for X
	move.l	offscreenbse,a1			;20
	add.w	(a3)+,a1				;12		;Offset screen for X
	add.w	SPARKLE_YOFFSET(a0),a1	;6		;And Y
	
	REPT 5							;600
	movem.l	(a2)+,d0-d2				;36		;Read Mask and Planes 1+2+3+4
	and.l	d0,(a1)					;20		;Mask and write Planes 1+2+3
	or.l	d1,(a1)+				;20
	and.l	d0,(a1)					;20
	or.w	d2,(a1)					;16
	lea		160-4(a1),a1			;8
	ENDR
	rts

;----------------------------------
;Sparkle structure
	RSRESET
SPARKLE_FRAME		rs.w	1				;Animation frame
SPARKLE_TIME		rs.w	1				;Frames before show sparkle
SPARKLE_XSET		rs.w	1				;X set (one of 8 preshifts)
SPARKLE_YOFFSET		rs.w	1				;Y screen line offset
SPARKLE_SIZE = 8

NUMSPARKLES = 2								;We have 2 sparkles on screen

;----------------------------------

	SECTION	BSS

bcddisplayscore		ds.l	1				;32-bit BCD display score
newbest				ds.w	1				;!=0 if have new high-score
awardmedal			ds.w	1				;Awarded medal, ie 0-none, 1-bronze, 2-silver, 3-gold, 4-platinum
medalcount			ds.w	1				;Display score count latch
medaltimeout		ds.w	1				;Counter to time-out and return to title screen
medalpalette		ds.w	4				;Palette of 4 colours used for medal
sparkles			ds.b	SPARKLE_SIZE*NUMSPARKLES

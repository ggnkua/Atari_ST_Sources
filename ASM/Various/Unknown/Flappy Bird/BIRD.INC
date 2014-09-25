
;Bird drawing and animation

BIRDANIMVEL = $4000							;Velocity for normal wing animation as fixed-point
BIRDANIMFLAPVEL = $8000						;Increased velocity when flap
BIRDANIMDECVEL = $350						;Decrease wing animation
BIRDANIMCLAMPVEL = $1000					;Clamp velocity
	
	SECTION	TEXT

;----------------------------------
;Initialise bird
birdinit
	moveq.l	#0,d0
	move.w	d0,birdx
	move.l	d0,birdy
	move.l	d0,birdvely
	move.w	d0,birdoldy
	move.w	d0,birdoldy+2
	move.l	d0,birdframe
	move.l	#BIRDANIMVEL,birdframevel
	move.l	#BIRDANIMVEL,birdframeclamp
	move.l	#BIRDFLAPVELY_50HZ,birdflapvely
	move.l	#GRAVITY_50HZ,birdgravity
	move.w	d0,birdhit
	move.l	d0,birdpalette
	move.l	d0,birdpalette+4
	rts

;----------------------------------
;Reset bird
birdreset
	moveq.l	#0,d0
	move.w	d0,birdx
	move.l	d0,birdy
	move.l	birdflapvely,birdvely
	move.w	d0,birdoldy
	move.w	d0,birdoldy+2
	move.l	d0,birdframe
	move.l	#BIRDANIMVEL,birdframevel
	move.l	#BIRDANIMVEL,birdframeclamp
	move.w	d0,birdhit
	rts
	
;----------------------------------
;Set random bird palette
birdrandompalette
	bsr		utilrandbyte					;Get random value in d0.b
	and.w	#3,d0							;Mask 0...3
	lsl.w	#3,d0							;*8
	lea		birdpalettes(pc,d0.w),a0		;Source palette
	lea		birdpalette,a1					;Destination palette
	move.l	(a0)+,(a1)+						;Copy 4 colours
	move.l	(a0),(a1)
	rts

;----------------------------------

birdpalettes
	dc.w	$700,$630,$740,$774				;Orange bird
	dc.w	$720,$035,$157,$277				;Blue bird
	dc.w	$740,$510,$710,$730				;Red bird
	dc.w	$700,$630,$740,$774				;Orange bird (duplicate as index 0...3)

;----------------------------------
;Animate bird wings
birdanim
	move.w	birdhit,d0						;Check if we're dead
	bne.s	.dead
	move.l	birdframe,d0
	move.l	birdframevel,d1
	move.l	birdframeclamp,d2
	sub.l	#BIRDANIMDECVEL,d1				;Slow animation speed
	cmp.l	d2,d1
	bge.s	.noclamp
	move.l	d2,d1							;Clamp to slowest speed
.noclamp
	move.l	d1,birdframevel
	add.l	d1,d0
	and.l	#$0003ffff,d0					;Mask frame as 0...3 fixed-point
	move.l	d0,birdframe
	rts
	
.dead
	move.l	#4<<16,birdframe				;Force death frame as fixed-point
	rts
	
;----------------------------------

	dc.w	24*16
	dc.w	24*15
	dc.w	24*14
	dc.w	24*13
	dc.w	24*12
	dc.w	24*11
	dc.w	24*10
	dc.w	24*9
	dc.w	24*8
	dc.w	24*7
	dc.w	24*6
	dc.w	24*5
	dc.w	24*4
	dc.w	24*3
	dc.w	24*2
	dc.w	24*1
birdclip

;----------------------------------
;Draw bird to screen
birddraw							;4300 cycles, 8.5 rasters
	move.w	birdx,d0				;16
	move.w	birdy,d1				;16
	moveq.w	#17-1,d7				;4		;Number of lines to draw

	move.l	offscreenbse,a1			;20
	lsr.w	#1,d0					;8		;Add X screen offset
	and.w	#$fff8,d0				;8
	add.w	d0,a1					;8
	move.w	birdframe,d0			;16
	lsl.w	#2,d0					;12		;Frame as long word index
	move.l	birdframes(pc,d0.w),a0	;20		;Lookup animation sprite frame

	cmp.w	#-17,d1					;8		;Cull on Y (X is always on-screen)
	ble.s	.done					;10/8
	cmp.w	#160,d1					;8
	bge.s	.done					;10/8

	move.w	d1,d1					;4		;Within top of screen?
	bge.s	.topok					;10/8
	add.w	d1,d7					;4		;Clip top
	add.w	d1,d1					;4		;*2
	add.w	birdclip(pc,d1.w),a0	;20		;-ve index into table to offset source
	moveq.w	#0,d1					;4
.topok	
	cmp.w	#160-17,d1				;8		;Within bottom of screen?
	ble.s	.bottomok				;10/8
	add.w	#160-17,d7				;8		;Clip bottom
	sub.w	d1,d7					;4
	ble.s	.done					;10/8
.bottomok

	add.w	d1,d1					;4		;Add Y screen line offset
	lea		screenlines,a2			;12
	add.w	(a2,d1.w),a1			;20

.loop
	movem.l	(a0)+,d0-d5				;60		;Mask/Planes 1+2+3+4 for 32 pixels
	and.l	d0,(a1)					;20
	or.l	d1,(a1)+				;20
	and.l	d0,(a1)					;20
	or.l	d2,(a1)+				;20
	and.l	d3,(a1)					;20
	or.l	d4,(a1)+				;20
	and.l	d3,(a1)					;20
	or.l	d5,(a1)+				;20
	lea		160-16(a1),a1			;8		;Next line
	dbra.w	d7,.loop				;10/14
	
.done
	rts

;----------------------------------

birdframes
	dc.l	birdanimspr+(408*0),birdanimspr+(408*1),birdanimspr+(408*2),birdanimspr+(408*1)
	dc.l	birdanimspr+(408*3)

;----------------------------------
;Clear line of bird, 92 cycles
BIRDCLEARLINE	MACRO
	movem.l	\1(a0),d0-d3			;48
	movem.l	d0-d3,\2(a1)			;44
	ENDM

;----------------------------------
;Clear bird background
birdclear							;1820 cycles, 3.5 rasters
	move.w	birdoldy,d0				;16		;Cycle bird Y for swap buffers
	move.w	birdoldy+2,birdoldy		;28
	move.w	birdy,birdoldy+2		;28

	move.w	d0,d0					;4		;Clamp Y between playable area 0...143
	bge.s	.clamptop				;10/8
	moveq.w	#0,d0					;4
.clamptop
	cmp.w	#143,d0					;8
	ble.s	.clampbottom			;10/8
	move.w	#143,d0					;8
.clampbottom

	move.l	offscreenbse,a1			;20
	lea		56(a1),a1				;8		;Add X screen offset
	move.w	d0,d1					;4
	add.w	d1,d1					;4		;Add Y screen line offset
	lea		screenlines,a2			;12
	add.w	(a2,d1.w),a1			;20

	move.l	skyimg,a0				;20
	sub.w	#95,d0					;8		;Get line in sky source
	ble.s	.clip					;10/8
	lsl.w	#4,d0					;16		;*16
	move.w	d0,d1					;4
	lsl.w	#2,d1					;12		;*64
	add.w	d1,d0					;4		;=*80
	lea		8(a0,d0.w),a0			;8		;Offset to sky line
.clip

	BIRDCLEARLINE	80*0,160*0		;92		;Copy 17 lines of 32 pixels to screen
	BIRDCLEARLINE	80*1,160*1
	BIRDCLEARLINE	80*2,160*2
	BIRDCLEARLINE	80*3,160*3
	BIRDCLEARLINE	80*4,160*4
	BIRDCLEARLINE	80*5,160*5
	BIRDCLEARLINE	80*6,160*6
	BIRDCLEARLINE	80*7,160*7
	BIRDCLEARLINE	80*8,160*8
	BIRDCLEARLINE	80*9,160*9
	BIRDCLEARLINE	80*10,160*10
	BIRDCLEARLINE	80*11,160*11
	BIRDCLEARLINE	80*12,160*12
	BIRDCLEARLINE	80*13,160*13
	BIRDCLEARLINE	80*14,160*14
	BIRDCLEARLINE	80*15,160*15
	BIRDCLEARLINE	80*16,160*16
	rts

;----------------------------------

	SECTION	BSS

birdx				ds.w	1				;Bird XY position
birdy				ds.w	1
birdyfrac			ds.w	1
birdvely			ds.w	1				;Bird velocity as 16:16 fixed-point
birdvelyfrac		ds.w	1
birdoldy			ds.w	2				;Old bird Y positions for swap buffer clears
birdframe			ds.w	1				;Animation frame
birdframefrac		ds.w	1
birdframevel		ds.w	1				;Animation velocity
birdframevelfrac	ds.w	1
birdframeclamp		ds.w	1				;Animation clamp
birdframeclampfrac	ds.w	1
birdflapvely		ds.l	1				;Upward velocity to apply on flap
birdgravity			ds.l	1				;Gravity
birdhit				ds.w	1				;!=0 if bird has hit a pipe or the floor
birdpalette			ds.w	4				;Random palette of 4 colours used for bird
	EVEN

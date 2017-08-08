;syncsine.s
; x write sprite rout for multiple sprites (1/2 bpl?)
; x write mask rout for multie sprites
; x write restoring background for multiple sprites
; x 8 different sized sprites 
;
;
;
;
genSprites		equ false
nr_of_sprites	equ 180-4


scrollspeed 			equ 3	;2				;3
sprite_duration			equ 1500;210*5			;1480
sprite_fadeout_frames	equ 1705;	255*5			;1700
scene_duration_frames	equ 1725


	SECTION TEXT
init_sync_sine
	move.w	#0,$ffff8240

	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)

	move.l	savedscreenpointer,d0
	add.l	#$19120+29*160,d0

	move.l	d0,bssBuffer+clearSpriteListPointer			;
	add.l	#(4+2)*nr_of_sprites+4,d0
	move.l	bssBuffer+clearSpriteListPointer,a0	
	move.l	#-1,(a0)+
	move.l	#-1,(a0)+

	move.l	d0,bssBuffer+clearSpriteListPointer2
	add.l	#(4+2)*nr_of_sprites+4,d0
	move.l	bssBuffer+clearSpriteListPointer2,a0
	move.l	#-1,(a0)+
	move.l	#-1,(a0)+
	
	move.l	d0,bssBuffer+myDrawRoutPointer
	add.l	#10528,d0
	move.l	d0,bssBuffer+myClearRoutPointer
	add.l	#7104,d0
	move.l	d0,bssBuffer+drawRoutsBla				; 
	add.l	#512,d0
	move.l	d0,bssBuffer+clearRoutsBla
	add.l	#512,d0

	move.l	#haxSpace,d0							;26000
	move.l	d0,bssBuffer+x_off_and_mask_pointer
	add.l	#320*4,d0								;-1280
	move.l	d0,bssBuffer+y2pointer
	add.l	#1536*2,d0								;-3072
	move.l	d0,bssBuffer+y1pointer
	add.l	#512*2,d0								;-1024
	move.l	d0,bssBuffer+x1pointer
	add.l	#8*273*2,d0								;-4368
	move.l	d0,bssBuffer+x2pointer
	add.l	#9*128*2,d0								;-2304
	move.l	d0,bssBuffer+z1pointer
	add.l	#512*2,d0								;-1024
	move.l	d0,bssBuffer+advanceSpritesCodePointer	
	add.l	#4578,d0								;-4578

	move.l	d0,bssBuffer+spritespointer

	move.l	bssBuffer+spritespointer,a0
	move.l	#-1,d6
	move.w	#nr_of_sprites-1,d7
.xx
		move.l	d6,(a0)+
	dbra	d7,.xx
	move.w	d6,(a0)+

	IFEQ	genSprites
	jsr		generateSourceFromPi1
	ELSE
	ENDC
	jsr		generateMyDrawRouts
	jsr		genXoffAndMask
	jsr		copyWe

	move.l	#-29*160,sscrl_offset
	jsr		sscrl_setup_list		;Setup syncscroller combinations
	jsr		scroll_movement

	move.l 	screenpointer,d0
	add.l	sscrl_offset,d0			;Add syncscroller offset (scroll position)

	lsr.w	#8,d0
	move.l	d0,$ff8200

	move.w	#$2700,sr
	move.l	#sync_sine_vbl,$70
	move.l	#sync_timer_a,$134.w			;Install our own Timer A
	move.l	#sync_timer_logo,$120.w
	move.w	#$2300,sr	

.mainloop
	wait_for_vbl
			exitOnSpace
	subq.w	#1,sinewaiter
	bge		.mainloop

	move.l	screenpointer,tmppointer

	move.w	#$2700,sr
	move.l	#sync_sine_vbl_noswap,$70
	move.w	#$2300,sr
	rts

offsetThing	dc.w	120*160

copyTransition
	lea		transition+34,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.l	#309*160,a1
	add.l	#309*160,a2

	add.w	offsetThing,a0
	add.w	offsetThing,a1
	add.w	offsetThing,a2

	moveq	#0,d1
.ll
	REPT 20
		add.w	#2,a0
		move.w	(a0)+,d0
		move.w	d1,(a1)+
		move.w	d1,(a2)+

		move.w	d0,(a1)+
		move.w	d0,(a2)+

		move.l	(a0)+,d0

		move.l	d0,(a1)+
		move.l	d0,(a2)+
	ENDR

	sub.w	#160,offsetThing
	bge		.ok
		move.w	#$4e75,copyTransition
.ok	
	rts

tmppointer	dc.l	0

sync_sine_vbl_noswap
	pushall
	jsr		sscrl_setup_list		;Setup syncscroller combinations

	move.l 	tmppointer,d0
	add.l	sscrl_offset,d0			;Add syncscroller offset (scroll position)

	lsr.w	#8,d0
	move.l	d0,$ff8200							; put new screenpointer in effect

	move.w	#$2700,sr
	;Start up Timer A each VBL
	clr.b	$fffffa19.w			;Timer-A control (stop)
	bset	#5,$fffffa07.w			;Interrupt enable A (Timer A)
	bset	#5,$fffffa13.w			;Interrupt mask A (Timer A)
	move.b	#94,$fffffa1f.w			;Timer A Delay (data)
	move.b	#4,$fffffa19.w			;Timer A Predivider (start Timer A)
	
	;Start up Timer B each VBL
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	timer_b_pointer2,$120.w			;Install our own Timer B	
	move.b	#28,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	move.w	#$2300,sr	

	moveq	#0,d0
	lea		$ffff8240,a0
	REPT 8
		move.l	d0,(a0)+
	ENDR
	popall
	rte

timer_b_pointer2	dc.l	sync_timer_logo

sync_sine_vbl
	pushall
	move.w	#0,$ffff8240
	jsr		sscrl_setup_list		;Setup syncscroller combinations
	jsr		scroll_movement

	move.l 	screenpointer,d0
	add.l	sscrl_offset,d0			;Add syncscroller offset (scroll position)

	lsr.w	#8,d0
	move.l	d0,$ff8200							; put new screenpointer in effect
	move.w	#$2700,sr			;Stop all interrupts

	;Start up Timer A each VBL
	clr.b	$fffffa19.w				;Timer-A control (stop)
	bset	#5,$fffffa07.w			;Interrupt enable A (Timer A)
	bset	#5,$fffffa13.w			;Interrupt mask A (Timer A)
	move.b	#94,$fffffa1f.w			;Timer A Delay (data)
	move.b	#4,$fffffa19.w			;Timer A Predivider (start Timer A)
	
	;Start up Timer B each VBL
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	timer_b_pointer2,$120.w			;Install our own Timer B
	move.b	#28,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.w	#$2300,sr

			screenswap
	addq.w	#1,$466

	jsr		fixTimerBPointer
	jsr		pulsePalette
	jsr		copyNever
	jsr		copyNeverAnd

	move.w	cinemaColor,d0
	swap	d0
	move.w	cinemaColor,d0
	lea		$ffff8240,a0
	REPT 8
		move.l	d0,(a0)+
	ENDR

	jsr		checkMusicSyncSine

	cmp.w	#224,syncpaloff
	beq		.skip
	jsr		advanceSprites
	jsr		clearSprites
	jsr		drawSprites

.skip
	subq.w	#1,palsprites
	bge		.ok
		subq.w	#1,palwaiter
		bgt		.ok
			move.w	#3,palwaiter
			sub.w	#2,cinemaColorOff
			bge		.kx
				move.w	#0,cinemaColorOff
.kx
			add.w	#32,syncpaloff
			cmp.w	#224,syncpaloff
			blt		.ok
				move.w	#224,syncpaloff
.ok	
	move.w	#0,cinemaColor
	jsr		copyTransition

	popall
	rte

fixTimerBPointer
	move.w	syncscrolloff,d0
	cmp.w	#141,d0
	bge		.ok

		move.w	#142,d1
		sub.b	d0,d1
		move.b	d1,syncscrollbob
		move.b	#201,d0
		sub.b	d1,d0
		move.b	d0,syncscrollbottom
	rts
.ok		
	subq.w	#1,copyNeverWaiter
	bge		.ok3		
		subq.w	#1,subwaiter
		beq		.ok3
		move.w	#1,subwaiter
		move.w	#-1,doNeverAnd
		sub.w	#32,neveroff
		blt		.normal

.ok3
	tst.w	neverDisplayed
	bne		.normal
		move.w	#270,d1
		sub.b	d0,d1
		move.b	d1,syncscrollbob2
		move.b	#201,d0
		sub.b	d1,d0
		sub.b	#40,d0
		move.b	d0,syncscrollbottom2
		move.w	#-1,copyWeNever
		move.l	#sync_timer_b_never,timer_b_pointer2
	rts
.normal
		move.w	#0,neveroff
		move.w	#-1,neverDisplayed
		move.l	#sync_timer_b,timer_b_pointer2
	rts

subwaiter		dc.w	1
copyNeverWaiter	dc.w	210
copyWeNever		dc.w	0
neverDisplayed 	dc.w	0

cinemaColorOff	dc.w	14
cinemaColorList
	REPT 10
		dc.w	0
	ENDR

	dc.w	$000
	dc.w	$100
	dc.w	$100
	dc.w	$200
	dc.w	$200
	dc.w	$210
	dc.w	$210
	dc.w	$211
	dc.w	$211


; z01 = sizeactive
; z30 = fade
; z31 = fix sprites
checkMusicSyncSine
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	move.b	#0,$b8(a0)
	cmp.w	#1,d0
	bne		.np
		move.w	#-1,zactive
.np

	cmp.w	#$30,d0
	bne		.nofade
		move.w	#0,palsprites
.nofade

	cmp.w	#$31,d0
	bne		.noFix
		move.w	#0,spritesout
.noFix
	rts

zactive		dc.w	0
palwaiter	dc.w	3

;; ok so the syncscroll needs to use raster splits
;; this could be a list of timer b calls, after the first


sine_z_step	dc.w	46
sine_z_step_mask	equ 	256*2-1

sine_x1_step_mask	equ		2048*2-1
sine_x1_step		dc.w	412	;788
sine_x2_step_mask	equ		128*2-1
sine_x2_step		dc.w	44
sine_y1_step_mask	equ		64*2-1
sine_y1_step		dc.w 	14
 
sine_y2_step		dc.w	92
sine_y2_step_mask	equ		512*2-1






nr_of_sprites_skipped	dc.w nr_of_sprites-1
skipwaiter				dc.w	6




;as2
;		move.w	2(a2),d0
;		move.w	2(a2),d0
;		move.l	(a5,d0.w),d0
;		add.w	(a4)+,d0
;		swap	d0
;		add.w	2(a1),d0
;		add.w	2(a1),d0
;		move.l	d0,(a0)+
;ae2

generateaAdvanceSpritesCode
	move.l	bssBuffer+advanceSpritesCodePointer,a0
	move.l	#$302A0000+2,d0
	move.l	#$D06B0000+2,d1
	move.l	#$20350000,d2
	move.l	#$D05C4840,d3
	move.l	#$D0690000+2,d4
	move.l	#$D06E0000+2,d5
	move.w	#$20C0,d6

	move.w	#2,a1
	move.w	#-2*5,a2
	move.w	#2*2,a3

	move.w	#nr_of_sprites-1,d7
.ol
		movem.l	d0-d5,(a0)
		add.w	#6*4,a0
		move.w	d6,(a0)+

		add.w	a1,d0
		sub.w	a2,d1
		add.w	a3,d4
		add.w	a3,d5
	dbra	d7,.ol
	move.w	#$4e75,(a0)
	rts

savedAddressOff	dc.w	0
savedLW1		dc.l	0
savedLW2		dc.l	0

advanceSprites
	move.l	bssBuffer+spritespointer,a0
	move.l	bssBuffer+y1pointer,a1
	move.l	bssBuffer+y2pointer,a6
	move.l	bssBuffer+x1pointer,a2
	move.l	bssBuffer+x2pointer,a3
	move.l	bssBuffer+z1pointer,a4
.skip
	move.l	bssBuffer+x_off_and_mask_pointer,a5

	add.w	sine_y1_step,a1
	add.w	sine_x1_step,a2
	add.w	sine_x2_step,a3
	add.w	#512*4,a3
	add.w	sine_z_step,a4
	add.w	sine_y2_step,a6

	move.w	nr_of_sprites_skipped,d0
	muls	#26,d0
	move.l	bssBuffer+advanceSpritesCodePointer,a0
	move.l	-8(a0,d0.w),savedLW1
	move.l	-4(a0,d0.w),savedLW2
	move.w	d0,savedAddressOff
	move.w	#$207C,-6(a0,d0.w)
	move.l	bssBuffer+spritespointer,-4(a0,d0.w)

	jsr		-6(a0,d0.w)

	move.l	bssBuffer+advanceSpritesCodePointer,a0
	move.w	savedAddressOff,d0
	move.l	savedLW1,-8(a0,d0.w)
	move.l	savedLW2,-4(a0,d0.w)



;	jmp		.jmpd(pc,d0)
;
;.jmpd
;x1o	set 2
;x2o	set 2
;y1o	set 2
;y2o	set 2
;	REPT nr_of_sprites															; 176 * (4+4+2+2+2+4+4+2) = 
;		move.w	x1o(a2),d0				;4			;302A xxxx			move.l	#$302a0000,d0
;		add.w	x2o(a3),d0				;4			;D06B xxxx			move.l	#$d06b0000,d1
;		move.l	(a5,d0.w),d0			;4			;2035 0000			move.l	#$20350000,d2
;		add.w	(a4)+,d0				;2			;D05C				move.l	#$d05c4840,d3
;		swap	d0						;2			;4840				
;		add.w	y1o(a1),d0				;4			;D069 xxxx			move.l	#$d0690000,d4
;		add.w	y2o(a6),d0				;4			;D06E xxxx			move.l	#$d06e0000,d5
;		move.l	d0,(a0)+				;2	-> 24	;20C0				move.w	#$20c0,d6
;x1o set x1o+2
;x2o set x2o-2*5
;y1o set y1o+2*2
;y2o set y2o+2*2	
;	ENDR

;	with multiple sines
;	lea		sine1,a0
;	lea		sine2,a1
;	lea		sine3,a2
;	add.w	off1,a0
;	add.w	off2,a1
;	add.w	off3,a2
;		
;	move.w	(a0)+,d0				;8
;	add.w	(a1)+,d0				;8
;	add.w	(a2)+,d0				;8
;	move.l	(a3,d0.w),(a0)+			;28

	add.w	#2,sine_y1_step
	and.w	#sine_y1_step_mask,sine_y1_step
	sub.w	#10,sine_y2_step
	and.w	#sine_y2_step_mask,sine_y2_step

	add.w	#2,sine_x1_step
	and.w	#sine_x1_step_mask,sine_x1_step
	sub.w	#4,sine_x2_step
	and.w	#sine_x2_step_mask,sine_x2_step
	add.w	#4,sine_z_step
	and.w	#sine_z_step_mask,sine_z_step

	tst.w	spritesout
	ble		.ok
	subq.w	#1,skipwaiter
	bge		.ok
		move.w	#4,skipwaiter

	subq.w	#1,nr_of_sprites_skipped
	bge		.ok
		move.w	#0,nr_of_sprites_skipped
.ok
	rts

sinewaiter		dc.w	scene_duration_frames;	1300				;1733
scroll_waiter	dc.w	scrollspeed
spritesout		dc.w	sprite_duration	;			1050 210*5
palsprites		dc.w	sprite_fadeout_frames							;	255*5
sineintrooff	dc.w	137*160

generateAdvanceSpritesCode
	move.l	bssBuffer+advanceSpritesCodePointer,a0
	move.l	#$302a0000,d0
	move.l	#$d06b0000,d1
	move.l	#$20350000,d2
	move.l	#$d05c4840,d3
	move.l	#$d0690000,d4
	move.l	#$d06e0000,d5
	move.w	#$20c0,d6

	move.w	#2,d0
	move.w	#2,d1
	move.w	#2,d4
	move.w	#2,d5

	move.w	#2,a1
	move.w	#-2*5,a2
	move.w	#2*2,a3
	move.w	#2*2,a4

	move.w	#nr_of_sprites-1,d7
.doCode
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		move.l	d3,(a0)+
		move.l	d4,(a0)+
		move.l	d5,(a0)+
		move.w	d6,(a0)+

		add.w	a1,d0
		add.w	a2,d1
		add.w	a3,d4
		add.w	a4,d5
	dbra	d7,.doCode

	move.w	#$4E75,(a0)
	rts

drawSprites
;	lea		sprites,a0			; this contains x,y,sprite
	move.l	bssBuffer+spritespointer,a0
	move.l	screenpointer2,a1
	add.l	sscrl_offset,a1
	add.l	#160*32,a1
	add.w	sineintrooff,a1
	move.l	a1,usp
	move.l	bssBuffer+clearSpriteListPointer,a3
	move.l	bssBuffer+drawRoutsBla,a5
	lea		nextDraw,a6

nextDraw
	move.w	(a0)+,d0			;8		mask
	blt		exitDraw			
	move.l	usp,a1				;4		screen
	add.w	(a0)+,a1			;12		screen+offset
	move.w	d0,(a3)+			;8		save mask
	move.l	a1,(a3)+			;12		save screen+off
	move.l	(a5,d0.w),a4		;20		determine jump
	jmp		(a4)

exitDraw
	move.l	#-1,(a3)+
	subq.w	#1,sineintrowaiter
	bne		.ok
		move.w	#scrollspeed+1,sineintrowaiter
	sub.w	#160,sineintrooff
	bge		.ok
		move.w	#0,sineintrooff
.ok
	rts

sineintrowaiter
	dc.w	scrollspeed+1



clearSprites
	move.l	bssBuffer+clearSpriteListPointer2,a0
	move.l	bssBuffer+clearRoutsBla,a2
	lea		nextClear,a6
	move.w	#0,d0

nextClear
;	move.l	(a0)+,d1				; move.w	(a0)+,d1
;	blt		exitClear				; blt		exitClear
;	move.l	d1,a1					; move.l	(a0)+,a1
;	move.w	(a0)+,d1				; move.l	(a2,d1.w),a3
;	move.l	(a2,d1.w),a3			; jmp		(a3)			; --> 4 opt
;	jmp		(a3)
	move.w	(a0)+,d1
	blt		exitClear
	move.l	(a0)+,a1
	move.l	(a2,d1.w),a3
	jmp		(a3)


exitClear
	move.l	bssBuffer+clearSpriteListPointer,d0
	move.l	bssBuffer+clearSpriteListPointer2,bssBuffer+clearSpriteListPointer
	move.l	d0,bssBuffer+clearSpriteListPointer2

	subq.w	#1,spritesout
;	tst.w	spritesout
	bge		.end
	addq.w	#1,nr_of_sprites_skipped
	cmp.w	#nr_of_sprites,nr_of_sprites_skipped
	ble		.ok2
		move.w	#nr_of_sprites,nr_of_sprites_skipped
.ok2	
	move.w	nr_of_sprites_skipped,d0
	add.w	d0,d0
	add.w	d0,d0
;	lea		sprites+nr_of_sprites*4,a0
	move.l	bssBuffer+spritespointer,a0
	add.w	#nr_of_sprites*4,a0
	sub.w	d0,(a0)
	move.w	#-1,(a0)
.end
	rts


	IFEQ genSprites
generateSourceFromPi1
	lea		spritegfx+34,a0
	lea		seqsprites,a1
	move.l	a1,a2
	move.w	#8-1,d7
	move.w	#0,d0
.loop
y set 0
		REPT 16
			move.w	y(a0),(a1)+			; 4*16*8
			move.w	d0,(a1)+
y set y+160
		ENDR
		add.w	#16*160,a0
	dbra	d7,.loop
	rts	
	ENDC

	;0051 07E0			ori.w	$7e0,(a1)
	;0069 1FF8 00A0		or.iw	$1ff8,$a0(a1)
	;4ED6				jmp		(a6)
	;3340 0008		move.w	d0,$8(a1)

generateMyDrawRouts
	move.l	bssBuffer+myDrawRoutPointer,a1
	move.l	#nextDraw,a2
	move.l	bssBuffer+drawRoutsBla,a3
	move.l	bssBuffer+clearRoutsBla,a4
	move.l	bssBuffer+myClearRoutPointer,a5
	move.w	#152,a6

	moveq	#0,d3

	move.l	#$00690000,d0			;	ori.w	$0000,off(a1)
	move.w	#$4ED6,d1
	move.w	#8-1,d5
.nextSprite
	move.l	#$33400000,d2
	move.w	#16-1,d6
.doShift
		lea		seqsprites,a0
		add.w	d3,a0
		move.w	#0,d2					;					off
		move.w	#16-1,d7
		move.l	a1,(a3)+
		move.l	a5,(a4)+
.loop
			move.w	(a0)+,d0
			beq		.skip
				move.l	d0,(a1)+
				move.w	d2,(a1)+
				move.l	d2,(a5)+
.skip
			addq.w	#8,d2
			move.w	(a0)+,d0
			beq		.skip2
				move.l	d0,(a1)+
				move.w	d2,(a1)+
				move.l	d2,(a5)+
.skip2
			add.w	a6,d2
			dbra	d7,.loop
		move.w	d1,(a1)+
		move.w	d1,(a5)+

		lea		seqsprites,a0
		add.w	d3,a0
		REPT 16
			move.l	(a0),d4
			ror.l	d4
			move.l	d4,(a0)+
		ENDR
		dbra	d6,.doShift
		add.w	#16*2*2,d3
	dbra	d5,.nextSprite
	rts


;;;;;; syncscroll stuff ripped from DHS; shame on me...
sync_timer_a:	
	movem.l	d0-d2/d7/a0-a3,-(sp)
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer A
		dcb.w 	84-33,$4e71			;Zzzz					;----> do palette here


	move.w	cinemaColor,d0			;3
	swap	d0						;1
	move.w	cinemaColor,d0			;3
	lea		$ffff8240,a0			;2	
	REPT 8	
		move.l	d0,(a0)+			;3*8  = > 33
	ENDR

	clr.b	$ffff820a.w			;60 Hz
		dcb.w 	9,$4e71				;
	move.b	#2,$ffff820a.w			;50 Hz

	lea	$ffff8209.w,a0			;Hardsync
	moveq	#127,d1				;
.sync:		
	tst.b	(a0)				;
	beq.s	.sync				;
	move.b	(a0),d2				;
	sub.b	d2,d1				;
	lsr.l	d1,d1				;

		dcb.w	61,$4e71

	;Do the Syncscroll 
	lea		sscrl_jumplist,a3	;3
	move.l	(a3)+,a0			;3
	moveq	#2,d7				;1
	rept	7
		jsr	(a0)				;4*7=28  Seven scanlines of different linewidth
	endr

	movem.l	(sp)+,d0-d2/d7/a0-a3
	rte

pallols
	dc.w	0
	dc.w	$777		;1
	dc.w	$222		;2
	dc.w	$777		;3
	dc.w	$222		;4
	dc.w	$777		;5
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0


	; highlights
pulsePal
			;2	 ;4	 ;6.  ;8.  ;10. ;12. ;14
	dc.w	$310,$630,$641,$510,$631,$620,$652		;14 off, 7 colors
	dc.w	$300,$620,$631,$410,$621,$610,$642
	dc.w	$300,$520,$621,$400,$620,$600,$641
	dc.w	$200,$510,$620,$400,$620,$600,$640




neverpal	;0	 ;1	  ;2.  ;3. ;4	;5	 ;6	  ;7.  ;8	;9	 ;10. ;11. ;12	;13	 ;14. ;15
	dc.w	$000,$777,$112,$777,$222,$777,$322,$777,$433,$777,$653,$777,$101,$777,$776,$777	;0

	dc.w	$000,$777,$112,$777,$222,$777,$322,$777,$433,$777,$653,$777,$111,$777,$776,$777	;1
	dc.w	$000,$777,$222,$777,$222,$777,$322,$777,$433,$777,$653,$777,$222,$777,$776,$777	;2
	dc.w	$000,$777,$333,$777,$222,$777,$333,$777,$433,$777,$653,$777,$333,$777,$776,$777	;3
	dc.w	$000,$777,$444,$777,$222,$777,$444,$777,$444,$777,$654,$777,$444,$777,$776,$777	;4
	dc.w	$000,$777,$555,$777,$222,$777,$555,$777,$555,$777,$655,$777,$555,$777,$776,$777	;5
	dc.w	$000,$777,$666,$777,$222,$777,$666,$777,$666,$777,$666,$777,$666,$777,$776,$777	;6
	dc.w	$000,$777,$777,$777,$222,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777	;7

	dc.w	$000,$777,$000,$777,$222,$777,$222,$777,$000,$777,$000,$777,$222,$777,$222,$777	;8




	; 1 = bobs
	; 2 = text 1
	; 4 = snakes;
	; 8 = text 2
	; 12 = text....

	; background for the rototext
	;	
syncpal
	IFEQ	loadSyncSinePalette
syncsinePalPlace		ds.b	32*16
	ELSE
			;0	;1	 ;2	  ;3.  ;4.  ;5.  ;6;  ;7.  ;8.  ;9   ;10. ;11. ;12. ;13. ;14. ;15
	dc.w	$000,$777,$112,$777,$222,$777,$322,$777,$433,$777,$653,$777,$101,$777,$776,$777	;224
	dc.w	$000,$666,$112,$666,$222,$666,$322,$666,$433,$666,$653,$666,$101,$666,$776,$776	;192
	dc.w	$000,$555,$112,$555,$222,$555,$322,$555,$433,$555,$653,$655,$101,$555,$776,$776	;160
	dc.w	$000,$444,$112,$444,$222,$444,$322,$444,$433,$444,$653,$654,$101,$444,$776,$776	;128
	dc.w	$000,$333,$112,$333,$222,$333,$322,$333,$433,$433,$653,$653,$101,$333,$776,$776	;96
	dc.w	$000,$222,$112,$222,$222,$222,$322,$322,$433,$433,$653,$653,$101,$222,$776,$776	;64
	dc.w	$000,$111,$112,$112,$222,$222,$322,$322,$433,$433,$653,$653,$101,$111,$776,$776	;32
	dc.w	$000,$000,$112,$112,$222,$222,$322,$322,$433,$433,$653,$653,$101,$101,$776,$776	;0

	ENDC
;	dc.w	$000,$777,$310,$777,$630,$777,$641,$777,$510,$777,$631,$777,$620,$777,$652,$777	;224

syncpaloff	dc.w	0

syncscrolloff		dc.w	0
syncscrollbob		dc.b	140
syncscrollbob2		dc.b	140
syncscrollbottom	dc.b	201-140
syncscrollbottom2	dc.b	201-140

sync_timer_logo
	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#sync_timer_bobs,$120
	move.b  syncscrollbob,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus


	movem.l	_titleScreenPalNew,d1-d7/a0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
	movem.l	d1-d7/a0,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0
	rte


sync_timer_b_never	
	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)
    clr.b   $fffffa1b.w         
	move.l	#sync_timer_never,$120
	move.b  syncscrollbob2,$FFFFFA21.w  
	move.b  #8,$FFFFFA1B.w 				

	lea		syncpal,a0
	add.w	syncpaloff,a0
	movem.l	(a0),d1-d7/a0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
	movem.l	d1-d7/a0,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0
	rte

neveroff	dc.w	8*32

sync_timer_never
	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#sync_timer_after_never,$120
	move.b  #40,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus

	lea		neverpal,a0
	add.w	neveroff,a0
	movem.l	(a0),d1-d7/a0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
	movem.l	d1-d7/a0,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0
	rte	

sync_timer_after_never
	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#sync_timer_b_bottom,$120
	move.b  syncscrollbottom2,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus


	lea		syncpal,a0
	add.w	syncpaloff,a0
	movem.l	(a0),d1-d7/a0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
	movem.l	d1-d7/a0,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0
	rte


sync_timer_bobs
	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#sync_timer_b_bottom,$120
	move.b  syncscrollbottom,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus


	lea		syncpal,a0
	add.w	syncpaloff,a0
	movem.l	(a0),d1-d7/a0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
	movem.l	d1-d7/a0,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0
	rte




; this timer we use when the shit is out of the screen
sync_timer_b:	
	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)

    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#sync_timer_b_bottom,$120
	move.b  #201,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus

	lea		syncpal,a0
	add.w	syncpaloff,a0
	movem.l	(a0),d1-d7/a0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
	movem.l	d1-d7/a0,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0
	rte

sync_timer_b_bottom
	move.w	#$2700,sr
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.w	cinemaColor,$ffff8240
	pushall
	move.l	sndh_pointer,a0
	jsr		8(a0)
	popall
	move.w	#$2300,sr
    rte

cinemaColor	dc.w	$0

scroll_movement:
	subq.w	#1,scroll_waiter
	bge		.t
		move.w	#scrollspeed,scroll_waiter

	cmp.l	#160*401,sscrl_offset
	blt.s	.add
	move.l	#160*401,sscrl_offset
		jmp	.t
.add:		
	add.l	#160,sscrl_offset
	addq.w	#1,syncscrolloff
.t
	rts



sscrl_setup_list:					;Setup the jumptable each VBL
	move.l	screenpointer,d2
	add.l	sscrl_offset,d2
	and.l	#$000000ff,d2

	lea	sscrl_combo_table,a1		;List of all 256/2 offset combos
	lsr.w	#1,d2				;Reduce to 128 combinations
	lsl.w	#3,d2				;Align with address list (8 byte boundary)
	add.l	d2,a1

	lea	sscrl_linewidths,a0		;List of routs with different linewidths
	lea	sscrl_jumplist,a2		;

	rept	7
		moveq	#0,d0
		move.b	(a1)+,d0			;Get routine to run (0-6)
		lsl.w	#2,d0				;Align to address list (4 byte boundary)
		move.l	(a0,d0.w),(a2)+			;Write address to list
	endr

	rts

;-------------- Overscan routines

	;160 byte line
sscrl_line0:	
;	dcb.w	117,$4e71
	REPT 58
		or.l	d7,d7
	ENDR
	nop
	move.l	(a3)+,a0			;3 fetch next address
	rts					;4

	;158 byte line
sscrl_line1:	
;	dcb.w	94,$4e71
	REPT 47
		or.l	d7,d7
	ENDR
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	dcb.w	17,$4e71
	move.l	(a3)+,a0			;3
	rts					;4

	;184 byte line
sscrl_line2:	
	dcb.w	2,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
;	dcb.w	86,$4e71
	REPT 43
		or.l	d7,d7
	ENDR
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	REPT 5
		or.l	d7,d7
	ENDR
;	dcb.w	10,$4e71
	move.l	(a3)+,a0			;3
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	nop
	rts					;4

	;204 byte line
sscrl_line3:	
;	dcb.w	96,$4e71
	REPT 48
		or.l	d7,d7
	ENDR
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	dcb.w	15,$4e71
	move.l	(a3)+,a0			;3
	rts					;4

	;230 byte line
sscrl_line4:	
	dcb.w	2,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
;	dcb.w	88,$4e71
	REPT 44
		or.l	d7,d7
	ENDR
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	dcb.w	8,$4e71
	move.l	(a3)+,a0			;3
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	nop
	rts					;4

	;186 byte line
sscrl_line5:	
	dcb.w	2,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
;	dcb.w	102,$4e71
	REPT 51
		or.l	d7,d7
	ENDR
	move.l	(a3)+,a0			;3
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	nop
	rts					;4

	;54 byte line
sscrl_line6:	
	REPT 21
		or.l	d7,d7
	ENDR
;	dcb.w	42,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	REPT 34
		or.l	d7,d7
	ENDR
	nop
;	dcb.w	69,$4e71
	move.l	(a3)+,a0			;3
	rts					;4



genXoffAndMask
	move.l	bssBuffer+x_off_and_mask_pointer,a0
	move.w	#20-1,d7
	moveq	#0,d0
.ol
	move.w	#16-1,d6
	moveq	#0,d1
.il
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		addq.w	#4,d1
		dbra	d6,.il
	addq.w	#8,d0
	dbra	d7,.ol
	rts


;x_off_and_mask
;xoff set 0
;	REPT 20
;mask set 0
;		REPT 16
;			dc.w	xoff,mask*4
;mask set mask+1
;		ENDR
;xoff set xoff+8
;	ENDR	



_currentSyncOffset	dc.l	0
_copyWeTimes		dc.w	2

copyWe
	move.l	screenpointer2,a0
	move.l	screenpointer,a2
	add.l	_currentSyncOffset,a0
	add.l	#230*160+40,a0
	add.l	#230*160+40,a2
	lea		sync_we,a1
	move.w	#30-1,d7

.ol
x set 0
		REPT 4
			move.w	(a1)+,d0
			move.w	d0,x+2(a0)
			move.w	d0,x+2(a2)
			not.w	d0
			and.w	d0,x+4(a0)
			and.w	d0,x+4(a2)
			move.w	(a1)+,d0
			move.w	d0,x+6(a0)
			move.w	d0,x+6(a2)
			not.w	d0
			and.w	d0,x+4(a0)
			and.w	d0,x+4(a2)
x set x+8
		ENDR
		add.w	#160,a0
		add.w	#160,a2
		dbra	d7,.ol
	rts

copyNeverTimer	dc.w	2
doNeverAnd		dc.w	0
doNeverAndTimes	dc.w	2

copyNeverAnd
	tst.w	doNeverAnd
	beq		.end
		subq.w	#1,doNeverAndTimes
		blt		.end
			move.l	screenpointer2,a0
			add.l	_currentSyncOffset,a0
			add.l	#278*160+80,a0
			lea		sync_never,a1
			move.w	#30-1,d7
.ol
o set 0
			REPT 9
				move.w	(a1)+,d0
				not.w	d0
				and.w	d0,o+4(a0)				;8
				move.w	(a1)+,d0
				not.w	d0
				and.w	d0,o+4(a0)				;
o set o+8
			ENDR
		add.w	#160,a0
		dbra	d7,.ol
.end
	rts

copyNever
	tst.w	copyWeNever
	beq		.end
	subq.w	#1,copyNeverTimer
	bge		.end
	subq.w	#1,_copyWeTimes
	blt		.end
	move.l	screenpointer2,a0
;	move.l	screenpointer,a2
	add.l	_currentSyncOffset,a0
;	add.l	_currentSyncOffset,a2
	add.l	#278*160+80,a0
;	add.l	#280*160+80,a2
	lea		sync_never,a1
	move.w	#30-1,d7
.ol
x set 0
		REPT 9
			move.w	(a1)+,x+2(a0)				;8
			move.w	(a1)+,x+6(a0)				;
x set x+8
		ENDR
		add.w	#160,a0
;		add.w	#160,a2
		dbra	d7,.ol
.end
	rts




pulsePalette
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.b	#$aa,d0
	bne		.ok
		move.w	#-1,bssBuffer+palettePulse
		move.w	#5,bssBuffer+pulsePalDirection
		move.w	#4,bssBuffer+pulsePalWaiter
		move.b	#0,$b8(a0)
.ok

	; we should copy to syncpal here.....

	tst.w	bssBuffer+palettePulse
	beq		.ok2
		lea		syncpal,a6
		lea		pulsePal,a0
		add.w	bssBuffer+pulsePalOff,a0
		movem.w	(a0)+,d0-d6
o set 0
		rept 8
			move.w	d0,o+4(a6)
			move.w	d1,o+8(a6)
			move.w	d2,o+12(a6)
			move.w	d3,o+16(a6)
			move.w	d4,o+20(a6)
			move.w	d5,o+24(a6)
			move.w	d6,o+28(a6)
o set o+32
		endr

		subq.w	#1,bssBuffer+pulsePalWaiter
		bgt		.ok2
			move.w	#4,bssBuffer+pulsePalWaiter


		subq.w	#1,bssBuffer+pulsePalDirection
		blt		.down
.up
		add.w	#14,bssBuffer+pulsePalOff
		cmp.w	#14*4,bssBuffer+pulsePalOff
		bne		.ok
			move.w	#14*3,pulsePalOff
			jmp		.ok2
.down
		sub.w	#14,bssBuffer+pulsePalOff
		bge		.ok2
			move.w	#0,bssBuffer+pulsePalOff
			move.w	#0,bssBuffer+palettePulse
.ok2
	rts

generateSineTables
	lea		y1s,a0							;64 words = 128 data
	move.l	bssBuffer+y1pointer,a2
	move.w	#8-1,d7
.copy
		move.l	a0,a1
		REPT 32
			move.l	(a1)+,(a2)+
		ENDR
	dbra	d7,.copy


	lea		y2s,a0
	move.l	bssBuffer+y2pointer,a2
	move.w	#3-1,d7								; 3 * 512 * 2 = 1536 -> 3072
.copy2
		move.l	a0,a1	
		move.w	#16-1,d6							; 512
.il2	
			REPT 16
				move.l	(a1)+,(a2)+				; 64
			ENDR
		dbra	d6,.il2

	dbra	d7,.copy2

	lea		x1s,a0
	move.l	bssBuffer+x1pointer,a2
	move.w	#8-1,d7
.ol3
		move.l	a0,a1
		move.w	#8-1,d6
.il3
			REPT 17		
				move.l	(a1)+,(a2)+			;68		
			ENDR
		dbra	d6,.il3
		move.w	(a1)+,(a2)+
	dbra	d7,.ol3	

	lea		x2s,a0
	move.l	bssBuffer+x2pointer,a2
	move.w	#9-1,d7
.ol4
		move.l	a0,a1
		move.w	#4-1,d6					;128
.il4
		REPT 16
			move.l	(a1)+,(a2)+			;64
		ENDR
		dbra	d6,.il4
	dbra	d7,.ol4

	lea		z1s,a0
	move.l	bssBuffer+z1pointer,a2
	move.w	#4-1,d7
.ol5
		move.l	a0,a1
		move.w	#4-1,d6
.il5
		REPT 16
			move.l	(a1)+,(a2)+
		ENDR
		dbra	d6,.il5
	dbra	d7,.ol5


	rts

	SECTION DATA





	IFEQ	genSprites
spritegfx
	incbin	"gfx/sinesprite2.pi1"
	ELSE
	ENDC


sscrl_offset:	dc.l	0

sscrl_linewidths:
	dc.l	sscrl_line0			;+000 bytes
	dc.l	sscrl_line1			;-002 bytes
	dc.l	sscrl_line2			;+024 bytes
	dc.l	sscrl_line3			;+044 bytes
	dc.l	sscrl_line4			;+070 bytes
	dc.l	sscrl_line5			;+026 bytes
	dc.l	sscrl_line6			;-106 bytes

sscrl_combo_table:
	dc.b 	0,0,0,0,0,0,0,0  		;0
 	dc.b 	6,4,3,1,1,1,0,0  		;2
 	dc.b 	6,4,3,1,1,0,0,0  		;4
 	dc.b 	6,4,3,1,0,0,0,0  		;6
 	dc.b 	6,4,3,0,0,0,0,0  		;8
 	dc.b 	6,4,2,2,1,0,0,0  		;10
 	dc.b 	6,4,2,2,0,0,0,0  		;12
 	dc.b 	6,5,4,2,0,0,0,0  		;14
 	dc.b 	6,5,5,4,0,0,0,0  		;16
 	dc.b 	2,1,1,1,0,0,0,0  		;18
 	dc.b 	2,1,1,0,0,0,0,0  		;20
 	dc.b 	2,1,0,0,0,0,0,0  		;22
 	dc.b 	2,0,0,0,0,0,0,0  		;24
 	dc.b 	5,0,0,0,0,0,0,0  		;26
 	dc.b 	6,4,4,1,1,1,0,0  		;28
 	dc.b 	6,4,4,1,1,0,0,0  		;30
 	dc.b 	6,4,4,1,0,0,0,0  		;32
 	dc.b 	6,4,4,0,0,0,0,0  		;34
 	dc.b 	3,1,1,1,1,0,0,0  		;36
 	dc.b 	3,1,1,1,0,0,0,0  		;38
 	dc.b 	3,1,1,0,0,0,0,0  		;40
 	dc.b 	3,1,0,0,0,0,0,0  		;42
 	dc.b 	3,0,0,0,0,0,0,0  		;44
 	dc.b 	2,2,1,0,0,0,0,0  		;46
 	dc.b 	2,2,0,0,0,0,0,0  		;48
 	dc.b 	5,2,0,0,0,0,0,0  		;50
 	dc.b 	5,5,0,0,0,0,0,0  		;52
 	dc.b 	6,4,4,2,1,1,0,0  		;54
 	dc.b 	6,4,4,2,1,0,0,0  		;56
 	dc.b 	6,4,4,2,0,0,0,0  		;58
 	dc.b 	6,5,4,4,0,0,0,0  		;60
 	dc.b 	4,1,1,1,1,0,0,0  		;62
 	dc.b 	4,1,1,1,0,0,0,0  		;64
 	dc.b 	4,1,1,0,0,0,0,0  		;66
 	dc.b 	4,1,0,0,0,0,0,0  		;68
 	dc.b 	4,0,0,0,0,0,0,0  		;70
 	dc.b 	2,2,2,0,0,0,0,0  		;72
 	dc.b 	5,2,2,0,0,0,0,0  		;74
 	dc.b 	5,5,2,0,0,0,0,0  		;76
 	dc.b 	5,5,5,0,0,0,0,0 		;78
 	dc.b 	3,3,1,1,1,1,0,0  		;80
 	dc.b 	3,3,1,1,1,0,0,0  		;82
 	dc.b 	3,3,1,1,0,0,0,0  		;84
 	dc.b 	3,3,1,0,0,0,0,0  		;86
 	dc.b 	3,3,0,0,0,0,0,0  		;88
 	dc.b 	4,2,1,1,0,0,0,0  		;90
 	dc.b 	4,2,1,0,0,0,0,0  		;92
 	dc.b 	4,2,0,0,0,0,0,0  		;94
 	dc.b 	5,4,0,0,0,0,0,0  		;96
 	dc.b 	5,2,2,2,0,0,0,0  		;98
 	dc.b 	5,5,2,2,0,0,0,0  		;100
 	dc.b 	5,5,5,2,0,0,0,0  		;102
 	dc.b 	6,4,4,4,0,0,0,0  		;104
 	dc.b 	4,3,1,1,1,1,0,0  		;106
 	dc.b 	4,3,1,1,1,0,0,0  		;108
 	dc.b 	4,3,1,1,0,0,0,0  		;110
 	dc.b 	4,3,1,0,0,0,0,0  		;112
 	dc.b 	4,3,0,0,0,0,0,0  		;114
 	dc.b 	4,2,2,1,0,0,0,0  		;116
 	dc.b 	4,2,2,0,0,0,0,0  		;118
 	dc.b 	5,4,2,0,0,0,0,0  		;120
 	dc.b 	5,5,4,0,0,0,0,0  		;122
 	dc.b 	5,5,2,2,2,0,0,0  		;124
 	dc.b 	5,5,5,2,2,0,0,0  		;126
 	dc.b 	3,3,3,1,1,0,0,0  		;128
 	dc.b 	3,3,3,1,0,0,0,0  		;130
 	dc.b 	3,3,3,0,0,0,0,0  		;132
 	dc.b 	4,4,1,1,1,0,0,0  		;134
 	dc.b 	4,4,1,1,0,0,0,0  		;136
 	dc.b 	4,4,1,0,0,0,0,0  		;138
 	dc.b 	4,4,0,0,0,0,0,0  		;140
 	dc.b 	4,2,2,2,0,0,0,0  		;142
 	dc.b 	5,4,2,2,0,0,0,0  		;144
 	dc.b 	5,5,4,2,0,0,0,0  		;146
 	dc.b 	5,5,5,4,0,0,0,0  		;148
 	dc.b 	5,5,5,2,2,2,0,0  		;150
 	dc.b 	4,3,3,1,1,1,0,0  		;152
 	dc.b 	4,3,3,1,1,0,0,0  		;154
 	dc.b 	4,3,3,1,0,0,0,0  		;156
 	dc.b 	4,3,3,0,0,0,0,0  		;158
 	dc.b 	4,4,2,1,1,0,0,0  		;160
 	dc.b 	4,4,2,1,0,0,0,0  		;162
 	dc.b 	4,4,2,0,0,0,0,0  		;164
 	dc.b 	5,4,4,0,0,0,0,0  		;166
 	dc.b 	5,4,2,2,2,0,0,0  		;168
 	dc.b 	5,5,4,2,2,0,0,0  		;170
 	dc.b 	5,5,5,4,2,0,0,0  		;172
 	dc.b 	3,3,3,3,1,0,0,0  		;174
 	dc.b 	3,3,3,3,0,0,0,0  		;176
 	dc.b 	4,4,3,1,1,1,0,0 		;178
 	dc.b 	4,4,3,1,1,0,0,0 		;180
 	dc.b 	4,4,3,1,0,0,0,0 		;182
 	dc.b 	4,4,3,0,0,0,0,0 		;184
 	dc.b 	4,4,2,2,1,0,0,0  		;186
 	dc.b 	4,4,2,2,0,0,0,0  		;188
 	dc.b 	5,4,4,2,0,0,0,0  		;190
 	dc.b 	5,5,4,4,0,0,0,0  		;192
 	dc.b 	5,5,4,2,2,2,0,0  		;194
 	dc.b 	5,5,5,4,2,2,0,0  		;196
 	dc.b 	4,3,3,3,1,1,0,0  		;198
 	dc.b 	4,3,3,3,1,0,0,0  		;200
 	dc.b 	4,3,3,3,0,0,0,0  		;202
 	dc.b 	4,4,4,1,1,1,0,0  		;204
 	dc.b 	4,4,4,1,1,0,0,0  		;206
 	dc.b 	4,4,4,1,0,0,0,0  		;208
 	dc.b 	4,4,4,0,0,0,0,0  		;210
 	dc.b 	4,4,2,2,2,0,0,0  		;212
 	dc.b 	5,4,4,2,2,0,0,0  		;214
 	dc.b 	5,5,4,4,2,0,0,0  		;216
 	dc.b 	5,5,5,4,4,0,0,0  		;218
 	dc.b 	3,3,3,3,3,0,0,0  		;220
 	dc.b 	4,4,3,3,1,1,1,0  		;222
 	dc.b 	4,4,3,3,1,1,0,0  		;224
 	dc.b 	4,4,3,3,1,0,0,0  		;226
 	dc.b 	4,4,3,3,0,0,0,0  		;228
 	dc.b 	4,4,4,2,1,1,0,0  		;230
 	dc.b 	4,4,4,2,1,0,0,0  		;232
 	dc.b 	4,4,4,2,0,0,0,0  		;234
 	dc.b 	5,4,4,4,0,0,0,0  		;236
 	dc.b 	5,4,4,2,2,2,0,0  		;238
 	dc.b 	5,5,4,4,2,2,0,0  		;240
 	dc.b 	5,5,5,4,4,2,0,0  		;242
 	dc.b 	4,3,3,3,3,1,0,0  		;244
 	dc.b 	4,3,3,3,3,0,0,0  		;246
 	dc.b 	4,4,4,3,1,1,1,0  		;248
 	dc.b 	4,4,4,3,1,1,0,0  		;250
 	dc.b 	4,4,4,3,1,0,0,0  		;252
 	dc.b 	4,4,4,3,0,0,0,0  		;254

sscrl_jumplist:	
	dc.l	sscrl_line0	
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0

seqsprites	incbin	fx/syncsine/syncsprites.bin

	SECTION BSS
	rsreset
myDrawRoutPointer		rs.l	1				; 10528
myClearRoutPointer		rs.l	1				; 7104
spritespointer			rs.l	1

clearSpriteListPointer	rs.l	1				; (4+2)*nr_of_sprites+4 = 6*180+4 = 1084
clearSpriteListPointer2	rs.l	1				;---> 1024 + 16
drawRoutsBla			rs.l	1							; 512
clearRoutsBla			rs.l	1							; 512	

palettePulse			rs.w	1
pulsePalOff				rs.w	1
pulsePalDirection		rs.w	1
pulsePalWaiter			rs.w	1
x_off_and_mask_pointer	rs.l	1
;sprites					ds.b	nr_of_sprites*4+12				; ==> 812	
advanceSpritesCodePointer	rs.l	1				; 4578
; 21
y1pointer					rs.l	1
y2pointer					rs.l	1
x1pointer					rs.l	1
x2pointer					rs.l	1
z1pointer					rs.l	1

;   0:  160 all the way                                         (0) -> 14*160           0 base 			
;   32: 204,158,158,158,158,158,158                             (7) -> 7*160            0 base			
;   64: 204,204,158,158,158,158,158,158,158,158,158,158,158,158 (14) ->                 0 base			
;   96: 204,204,204, 18*158		         						(12) -> 2*160           0 base		
;   128:204,204,204,158,158                                     (5) -> 9*160            0 base
;   160:204,204,204,204,158,158,158,158,158,158,158,158         (12) -> 2*160           0 base
;   192:204,204,204,204,204, 14*158 							(14)                    0
;   224:204,204,204,204,204,204, 20*158                         (7) -> 7*160            -256 base		


;	0: 160 all the way											;				16*160 = 2560
;	32:	1 * 204, 6*158	
;	64: 2 * 204, 12*158
;	96:	96-256 = -160 															2656

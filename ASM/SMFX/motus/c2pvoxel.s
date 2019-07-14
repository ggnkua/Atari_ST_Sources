
;def Render(p, phi, height, horizon, scale_height, distance, screen_width, screen_height):
;    # precalculate viewing angle parameters
;    var sinphi = math.sin(phi);
;    var cosphi = math.cos(phi);
;    
;    # initialize visibility array. Y position for each column on screen 
;    ybuffer = np.zeros(screen_width)
;    for i in range(0, screen_width):
;        ybuffer[i] = screen_height
;
;    # Draw from front to the back (low z coordinate to high z coordinate)
;    dz = 1.
;    z = 1.
;    while z < distance
;        # Find line on map. This calculation corresponds to a field of view of 90°
;        pleft = Point(
;            (-cosphi*z - sinphi*z) + p.x,
;            ( sinphi*z - cosphi*z) + p.y)
;        pright = Point(
;            ( cosphi*z - sinphi*z) + p.x,
;            (-sinphi*z - cosphi*z) + p.y)
;
;        # segment the line
;        dx = (pright.x - pleft.x) / screen_width
;        dy = (pright.y - pleft.y) / screen_width
;
;        # Raster line and draw a vertical line for each segment
;        for i in range(0, screen_width):
;            height_on_screen = (height - heightmap[pleft.x, pleft.y]) / z * scale_height. + horizon
;            DrawVerticalLine(i, height_on_screen, ybuffer[i], colormap[pleft.x, pleft.y])
;            if height_on_screen < ybuffer[i]:
;                ybuffer[i] = height_on_screen
;            pleft.x += dx
;            pleft.y += dy
;
;        # Go to next line and increase step size when you are far away
;        z += dz
;        dz += 0.2
;
;# Call the render function with the camera parameters:
;# position, viewing angle, height, horizon line position, 
;# scaling factor for the height, the largest distance, 
;# screen width and the screen height parameter
;Render( Point(0, 0), 0, 50, 120, 120, 300, 800, 600 )

INCVAL	equ $40000000

	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1
VOXEL_EFFECT_VBL	EQU 9*25
FREE_MOVE			EQU 1
PLAYMUSIC			EQU 0
FLASH				equ 1
DO_SOLID			equ 1
VERTICAL_MOVEMENT_SPEED	equ	3
DITHER				equ 0		; currently broken
SHOW_CPU			equ	0
USE_MYM_DUMP			equ 0
VOXEL_UNDERLINE_WAIT	equ 350

VOXEL_USEFILES	equ 1

BE_PRODUCTIVE_FADE_WAITER		equ 100
BE_PRODUCTIVE_FADE_SPEED		equ 1				; higher is slower


MYM_DUMP1_START					equ 1234-24				; finetuning for MYM dump starting, where -20 is current finetune value, range <= 0
MYM_DUMP1_NR_PATTERNS			equ 16											; dump duration in patterns, patterns * rows * speed = 16*64*3 = 3072
; starting positions for dump, this is where the dumper must start
MYM_DUMP1_SONG_POS				equ	$13											; when dumping starts, use this song position
MYM_DUMP1_CHAN1_PATTR			equ $18											; when dumping starts, channel 1 is using this pattern
MYM_DUMP1_CHAN2_PATTR			equ $6e											; when dumping starts, channel 2 is using this pattern
MYM_DUMP1_CHAN3_PATTR			equ $56											; when dumping starts, channel 3 is using this pattern

MYM_DUMP1_SONG_POS_NEXT			equ $14											; when current song pattern is done, this is the next pattern
MYM_DUMP1_CHAN1_PATTR_NEXT		equ $59											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP1_CHAN2_PATTR_NEXT		equ $6d											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP1_CHAN3_PATTR_NEXT		equ $56											; when song pattern is done, this is next pattern for channel 1

; adjusting player settings for continuing playing, after the dumper has done

MYM_DUMP1_SONG_POS_END			equ	$21											; we need to skip the player, since the dumping has been done, but the
MYM_DUMP1_CHAN1_PATTR_END		equ $60											;	actual player hasnt advanced its position yet, so we modify this here
MYM_DUMP1_CHAN2_PATTR_END		equ $67
MYM_DUMP1_CHAN3_PATTR_END		equ $56

MYM_DUMP1_SONG_POS_NEXT_END		equ $22
MYM_DUMP1_CHAN1_PATTR_NEXT_END	equ $50
MYM_DUMP1_CHAN2_PATTR_NEXT_END	equ $5B
MYM_DUMP1_CHAN3_PATTR_NEXT_END	equ $56
CHECK_VBL_OVERFLOW				equ 0
	ENDC





	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA

	include macro.s

	IFEQ	STANDALONE
			initAndRun	standalone_init

standalone_init
PREPBUFFER	equ 0
	IFEQ	PREPBUFFER
		jsr		prepPanel
	ENDC

	jsr		init_effect
	jsr		init_voxel
.x
	
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts

init_effect
	move.w	#$000,$ffff8240
	move.l	#memBase+65536,d0						;2
	sub.w	d0,d0
	move.l	d0,screenpointer						;3
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts


	ENDC


precalc_voxel
	move.l	screen1,d0
	move.l	d0,screenpointer
		move.l	d0,a0
		lea		32000(a0),a1
		move.l	a1,stillBuffer1		
		lea		96*4*8(a1),a2
		move.l	a2,stillBuffer2
		lea		96*4*8(a2),a3
		move.l	a3,stillBuffer3

	move.l	screen2,d0						;4
	move.l	d0,screenpointer2
	add.l	#$10000,d0
	move.l	d0,heightMapPointer						;5
	add.l	#$10000,d0
	move.l	d0,canvasOffsetListPointer				;6			; this has top and bot sorted 800 bytes
		move.l	d0,d1
		add.l	#1000,d1
		move.l	d1,left0CodePointer
		add.l	#6002,d1							;
		move.l	d1,right12Pointer
		add.l	#1392,d1
		move.l	d1,hmPointer
		add.l	#32128,d1
	add.l	#$10000,d0
	move.l	d0,cshift1Pointer						;7
		move.l	d0,d1
		add.l	#200,d1									;200
		move.l	d1,verticalStaticPointer
		add.l	#17204,d1								;14648
		move.l	d1,canvasPointerVoxel
		add.l	#18432+1000,d1							; 34080
		move.l	d1,vdivtablePointer
		add.l	#6400,d1							; 40480
		move.l	d1,left12Pointer
		add.l	#6122,d1							; 46602
		move.l	d1,left8Pointer	
		add.l	#6002,d1							; 52604
		move.l	d1,left4Pointer
		add.l	#6122,d1							; 58726
		move.l	d1,drawSkyPointer					;562
	add.l	#$10000,d0
	move.l	d0,cshift2Pointer						;8
		move.l	d0,d1
		add.l	#200,d1
		move.l	d1,voxelInner1Pointer
		add.l	#12098,d1
		move.l	d1,voxelInner2Pointer
		add.l	#12098,d1
		move.l	d1,colormapditherPointer
		add.l	#17462,d1
		move.l	d1,panel1Pointer
		add.l	#12800,d1
;	add.l	#$10000,d0
;	add.l	#$10000,d0
	add.l	#$10000,d0
	add.l	#$10000,d0
	add.l	#$10000,d0
;	add.l	#$10000,d0
;	add.l	#$10000,d0
;	add.l	#$10000,d0
	IFEQ	STANDALONE
		move.l	d0,musicBufferPointer
	ENDC

	lea		cshift1,a0
	lea		cshift2,a2
	jsr		copyChunkyTable

	IFEQ	VOXEL_USEFILES
	lea		colormapdither,a0
	move.l	colormapditherPointer,a1
	move.w	#17462/4/4/4-1,d7
.llll
		REPT 16
			move.l	(a0)+,(a1)+
		ENDR
		dbra	d7,.llll
		REPT 27
			move.w	(a0)+,(a1)+
		ENDR
	ELSE
	lea		colormapdithercrk,a0
	move.l	colormapditherPointer,a1
	jsr		cranker
	ENDC

	IFEQ	VOXEL_USEFILES
	lea		heightmap,a0
	move.l	hmPointer,a1
	move.w	#32128/4/4/4-1,d7
.oooo
		REPT 16
			move.l	(a0)+,(a1)+
		ENDR
		dbra	d7,.oooo

	movem.l	heightmap+4,d0-d7
	movem.l	d0-d7,introPal
	ELSE
	lea		heightmapcrk,a0
	move.l	hmPointer,a1
	jsr		cranker
	ENDC

	lea		panel1crk,a0
	move.l	panel1Pointer,a1
	jsr		cranker
	moveq	#0,d0
	REPT 4
		REPT 16
		move.l d0,(a1)+
		ENDR
	ENDR

	jsr		makeVoxelDivTable
	jsr		genSomeList
	jsr		generateDivTable
	jsr		genLeft12Code
	jsr		genLeft8Code
	jsr		genLeft4Code
	jsr		genLeft0Code
	jsr		genDrawSky
	jsr		genRight12Code
	jsr		genVerticalStaticCode
	jsr		generateVoxelInnner


	; prep chunky
;	lea		heightmap+128,a0
	move.l	hmPointer,a0
	add.w	#128,a0
	move.l	heightMapPointer,a1
	jsr		planarToChunky



	IFEQ	DITHER
;	lea		colormapdither+1024+54,a0
	move.l	colormapditherPointer,a0
	add.l	#1024+54,a0
	move.l	heightMapPointer,a1
	addq.w	#1,a1
	jsr		prepColormap
	ELSE
	lea		colormap+128,a0
	move.l	heightMapPointer,a1
	addq.w	#1,a1
	jsr		planarToChunky	
	ENDC

	; scrub memory


;	move.b	#0,$ffffc123
	move.w	#$4e75,precalc_voxel
;	move.b	#0,$ffffc123
	rts


init_voxel
		IFEQ	STANDALONE
	tst.w		musicInit
	bne			.noMusicInit
;		initMusicD	musicmyv,musicmys,musicmysend
		move.w	#-1,musicInit
.noMusicInit
		ENDC

	jsr		precalc_voxel

	move.w	#VOXEL_UNDERLINE_WAIT,tbwait
	IFEQ	DO_SOLID
	movem.l	introPal+7*32,d0-d7
	ELSE
	movem.l	introPal,d0-d7
	ENDC
	movem.l	d1-d7,$ffff8244
	movem.l	d1-d7,voxelPal2+4
;	move.w	#$111,$ffff8242
;	move.b	#0,$ffffc123



;    move.w  #$2700,sr
;    move.l  #.wvbl,$70
;    move.w  #$2300,sr
;
;
;    move.w  #0,$466
;.w  tst.w   $466.w
;    beq     .w
    	move.w	#0,$466
;    	move.w	#$700,$ffff8240

    move.w	#$2700,sr
    move.l	#voxel1_vbl,$70
    move.w	#$2300,sr


    IFEQ	FREE_MOVE
	move.w	#160-96,voxelScreenOff

.ml
	tst.w	$466.w
	beq		.ml
		move.w	#0,$466.w

		jsr		clearCanvasVoxel
		jsr		doVoxel
		jsr		c2p_1to4_static

		jsr		.doKeys
		move.l	screenpointer2,$ffff8200
				swapscreens

	jmp		.ml


.doKeys
	move.b  $fffffc02.w,d0
	; forward
	cmp.b	#$11,d0		;w
	bne		.now
		add.w	#1,px
		and.w	#128-1,px
.now
	; backward
	cmp.b	#$1f,d0
	bne		.nos
		sub.w	#1,px
		and.w	#128-1,px
.nos
	; left
	cmp.b	#$1e,d0		;a
	bne		.noa
		sub.w	#1,py
		and.w	#128-1,py
.noa

	; right
	cmp.b	#$20,d0		;d
	bne		.nod
		add.w	#1,py
		and.w	#128-1,py
.nod

	; rotate left
	cmp.b	#$10,d0		;q
	bne		.noq
   		add.w	#2,phi
 		and.w	#512-1,phi
.noq
	; rotate right
	cmp.b	#$12,d0		;e
	bne		.noe
   		sub.w	#2,phi
 		and.w	#512-1,phi

.noe

	rts



    ELSE
   			IFNE	STANDALONE

		jsr		beProductiveScroll2VBL
		ENDC
		jsr		clearCanvasVoxel
		jsr		moveEffect
		jsr		doVertStripes2
		jsr		doVertStripes2b

.mainloop
	tst.w	$466.w
	beq		.mainloop
		cmp.w	#2,$466.w
		blt		.mainloop
		bgt		.fail
		jmp		.cont
.fail
	IFEQ	CHECK_VBL_OVERFLOW
		move.l	#$700,d0
		lea		$ffff8240,a0
		REPT 16
			move.w	d0,(a0)+
		ENDR
		move.b	#0,$ffffc123
		ENDC
.cont
		move.w	#0,$466.w
		cmp.w	#$777,timer_b_open_curtain+2
		beq		.mainloop
;s		move.w	#0,$ffff8240

		tst.w	doCopyAndStopEffect
		beq		.copyAndStopEffect
			jsr		clearCanvasVoxel
			jsr		moveEffect
			IFNE	STANDALONE
				jsr		beProductiveScroll2VBL
			ENDC
			lea		voxelList,a0
			add.w	voxelListOff,a0
			move.l	(a0),a1
			jsr		(a1)
			jsr		doVertStripes2
			lea		c2pList,a0
			move.l	screenpointer2,$ffff8200
			add.w	voxelListOff,a0
			move.l	(a0),a1
			jsr		(a1)
			jsr		doVertStripes2b
	   		jsr		doMovement
   			jmp		.continue
.copyAndStopEffect
		jsr		moveStillBuffer
.continue
   		addq.w	#1,effectCounter

		move.l	screenpointer2,$ffff8200
				swapscreens
		IFEQ SHOW_CPU
			move.w	#$700,$ffff8240
		ENDC
		cmp.w	#$4e75,copyStillToBuffer
		beq		.endThisPart
	jmp		.mainloop
	ENDC
.endThisPart
	rts  
.wvbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w	

    IFEQ	USE_MYM_DUMP
		jsr		replayMymDump
    ELSE
    	IFNE	STANDALONE
    	jsr		musicPlayer+8
    	ENDC
    ENDC
    rte


mymDone	dc.w	-1





nrMymDumps	dc.w	0
herper	dc.w	4

	IFEQ	STANDALONE
moveStillBuffer
		move.l	stillBuffer1,a0
		move.l	stillBuffer2,a1
		move.l	stillBuffer3,a2
		move.l	screenpointer2,a3
		add.w	#4*160+64,a3
		lea		32(a3),a4
		lea		32(a4),a5

		move.w	vert_off_left,d0
		move.w	d0,d1
		subq.w	#2,d1
		bge		.kk1
			moveq	#0,d1
.kk1
		muls	#320,d0	
		add.l	d0,a3

		moveq	#0,d0
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		move.l	d0,a6
.y set 0
		REPT 9
			movem.l	d0/d2-d7/a6,.y(a3)
.y set .y-320
		ENDR

		move.w	#96-1,d7
		sub.w	d1,d7
		blt		.sskip1
.cp1
		movem.l	(a0)+,d0-d6/a6
		movem.l	d0-d6/a6,(a3)
		lea		320(a3),a3
		dbra	d7,.cp1
.sskip1

		move.w	vert_off_mid,d0
		move.w	d0,d1
		subq.w	#2,d1
		bge		.kk2
			moveq	#0,d1
.kk2
		muls	#320,d0
		add.l	d0,a4

		moveq	#0,d0
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		move.l	d0,a6
.y set 0
		REPT 9
			movem.l	d0/d2-d7/a6,.y(a4)
.y set .y-320
		ENDR

		move.w	#96-1,d7
		sub.w	d1,d7
		blt		.sskip2
.cp2
		movem.l	(a1)+,d0-d6/a6
		movem.l	d0-d6/a6,(a4)
		lea		320(a4),a4
		dbra	d7,.cp2
.sskip2



		move.w	vert_off_right,d0
		move.w	d0,d1
		subq.w	#2,d1
		bge		.kk3
			moveq	#0,d1
.kk3
		muls	#320,d0		; 256 + 64
		add.l	d0,a5

		moveq	#0,d0
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		move.l	d0,a6
.y set 0
		REPT 9
			movem.l	d0/d2-d7/a6,.y(a5)
.y set .y-320
		ENDR

		move.w	#96-1,d7
		sub.w	d1,d7
		blt		.sskip3
.cp3
		movem.l	(a2)+,d0-d6/a6
		movem.l	d0-d6/a6,(a5)
		lea		320(a5),a5
		dbra	d7,.cp3
.sskip3

	subq.w	#1,.waiter_left
	bge		.ok1
		add.w	#VERTICAL_MOVEMENT_SPEED,vert_off_left
		cmp.w	#103,vert_off_left
		blt		.ok1
			move.w	#103,vert_off_left
.ok1

	subq.w	#1,.waiter_mid
	bge		.ok2
		add.w	#VERTICAL_MOVEMENT_SPEED,vert_off_mid
		cmp.w	#103,vert_off_mid
		blt		.ok2
			move.w	#103,vert_off_mid
.ok2


	subq.w	#1,.waiter_right
	bge		.ok3
		add.w	#VERTICAL_MOVEMENT_SPEED,vert_off_right
		cmp.w	#103,vert_off_right
		blt		.ok3
			move.w	#103,vert_off_right
.ok3
;	move.w	#$300,$ffff8240
	rts
.waiter_left		dc.w	10
.waiter_mid			dc.w	18
.waiter_right		dc.w	26
.waiter				dc.w	2
vert_off_left		dc.w	0
vert_off_mid		dc.w	0
vert_off_right		dc.w	0
	ENDC




voxelList
	dc.l	doVoxel
	dc.l	doVoxel2
	dc.l	doVoxel
	dc.l	doVoxel2
	dc.l	doVoxel

c2pList
	dc.l	c2p_1to4_static
	dc.l	c2p_1to4_moving_4
	dc.l	c2p_1to4_moving_8
	dc.l	c2p_1to4_moving_12
	dc.l	c2p_1to4_static2

voxelListOff	dc.w	0
voxelScreenOff	dc.w	-12*8

; so we have 64 = good	160-96 = final, so from right to left is 96/8 = 12 steps
; from left to right, we are 64+96 = 160/8 = 20 steps, so after 8 steps, we want to get the right in



moveEffect
	move.l	screenpointer2,a0
	move.w	voxelScreenOff,d0
	cmp.w	#0,d0
	blt		.cont
		beq		.first
		add.w	d0,a0
		add.w	#4*160,a0
		move.l	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3

		move.w	#96/4-1,d7
.l1
.y set 0
;		REPT 96
			movem.l	d0-d3,.y-8(a0)				;96*6 576
			movem.l	d0-d3,.y-8+320(a0)				;96*6 576
			movem.l	d0-d3,.y-8+640(a0)				;96*6 576
			movem.l	d0-d3,.y-8+960(a0)				;96*6 576
			lea		4*320(a0),a0
		dbra	d7,.l1
;.y set .y+320
;		ENDR
		jmp		.ttt

.first
		add.w	d0,a0
		add.w	#4*160,a0
		move.l	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.w	#96/4-1,d7
.l2
.y set 0
;		REPT 96
			movem.l	d0-d1,.y(a0)				;96*6 576
			movem.l	d0-d1,.y+320(a0)				;96*6 576
			movem.l	d0-d1,.y+640(a0)				;96*6 576
			movem.l	d0-d1,.y+960(a0)				;96*6 576
			lea		4*320(a0),a0
;.y set .y+320
;		ENDR
		dbra	d7,.l2

.ttt
		tst.w	.stopRout
		bne		.cont
			move.w	#$4e75,moveEffect
			rts
.cont
	subq.w	#1,herper
	bge		.kkk
		move.w	#-1,herper
	add.w	#4,voxelListOff
	cmp.w	#16,voxelListOff
	bne		.kkk
		move.w	#0,voxelListOff
		add.w	#8,voxelScreenOff
		cmp.w	#160-96,voxelScreenOff
		bne		.kkk
			move.b	#0,$ffffc12
			move.w	#32000,herper
			move.w	#0,doVert
			move.w	#0,.stopRout
			move.w	#16,voxelListOff
.kkk
	rts
.stopRout	dc.w	-1




	IFEQ	STANDALONE
timer_b_open_curtain
	move.w	#$111,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_mid
	move.w	#$111,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#64,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_bot,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))	
	rte

timer_b_bot
	move.w	#$111,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#64,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	move.w	#$7,$ffff8240
	rte

	ENDC

copyChunkyTable
	move.l	cshift1Pointer,a1
	move.w	#36-1,d7
.l
		move.l	(a0)+,(a1)+
		dbra	d7,.l

	move.l	cshift2Pointer,a3
	move.w	#36-1,d7
.ll
		move.l	(a2)+,(a3)+
		dbra	d7,.ll
	rts


tboc
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
;	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
;	move.l	#open_lower_border,$120.w
	move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain_stable_voxel,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain_stable_voxel
		move.w	#$2700,sr
		movem.l	d0/a0/a1,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	copyChunkyTable

.wait:		dcb.w	134,$4e71 



	REPT 3
	nop
	ENDR



		
		clr.b	$ffff820a.w			;60 Hz
		dcb.w	5,$4e71				;
		move.b	#2,$ffff820a.w			;50 Hz		
		move.w	#0,$ffff8240




			lea		.tab,a0
			add.w	.off,a0
			lea		.tabFull,a1
			add.w	(a0),a1
			lea		$ffff8240+2*1,a0
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.w	(a1)+,(a0)+


			move.w	#-1,underLineHax

			cmp.w	#30*2,.off
			beq		.testwait
				jmp		.subber
.testwait
			subq.w	#1,.framewait
			bge		.kk

.subber
			sub.w	#2,.off
			bge		.kk
;				move.w	#120,tbwait
;				move.w	#65*2,.off
;				subq.w	#1,botTimes
;				bgt		.kk
					move.w	#32000,tbwait
.kk
		movem.l	(sp)+,d0/a0/a1
		rte
.framewait	dc.w	140
.off		dc.w	65*2
;--------------
;DEMOPAL - palette for underline
;--------------		
.tabFull		
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;0
	dc.w	$001,$111,$100,$100,$100,$111,$111,$010,$111,$010,$010,$011,$010,$111,$001		;30
	dc.w	$001,$111,$110,$200,$210,$221,$222,$121,$222,$121,$121,$122,$121,$111,$001		;60
	dc.w	$001,$211,$210,$310,$310,$321,$333,$232,$332,$232,$232,$122,$121,$111,$001		;90
	dc.w	$001,$211,$310,$411,$420,$421,$443,$343,$444,$343,$343,$233,$121,$122,$011		;120
	dc.w	$102,$311,$321,$421,$530,$531,$542,$454,$555,$454,$343,$233,$232,$122,$011		;150
	dc.w	$102,$311,$421,$521,$640,$632,$653,$565,$666,$565,$454,$344,$232,$122,$011		;180
	dc.w	$102,$312,$422,$522,$641,$653,$764,$676,$777,$565,$454,$344,$232,$122,$011		;210
;--------------
;DEMOPAL - fadesteps for each frame, over a course of 65 frames, starts at 65, waits at 30
;--------------		
.tab
	dc.w	0
	dc.w	30			;1
	dc.w	30			;2
	dc.w	30			;3
	dc.w	60			;4
	dc.w	60			;5
	dc.w	90			;6
	dc.w	120			;7
	dc.w	120			;8
	dc.w	150			;9
	dc.w	150			;10
	dc.w	150
	dc.w	150
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	210
	dc.w	210			;20
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210			;30		;---> first color high
	dc.w	210
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	150
	dc.w	150
	dc.w	150
	dc.w	150			;40
	dc.w	120
	dc.w	120
	dc.w	90
	dc.w	60
	dc.w	60
	dc.w	30
	dc.w	30
	dc.w	30
	dc.w	0
	dc.w	0			;50
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0	
	dc.w	0		
	dc.w	0			;60
	dc.w	0			;61
	dc.w	0			;62
	dc.w	0			;63
	dc.w	0			;64
	dc.w	0			;65
	dc.w	0
	dc.w	0
	dc.w	0


underLineHax	dc.w	0

botTimes	dc.w	2

voxelPal2		ds.w	16

voxel1_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblCounter
    move.w  #$0,$ffff8240
		    pushall

	tst.w	underLineHax
	beq		.nh	
		move.w	#$111,$ffff8240+2
.nh


	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	subq.w	#1,tbwait
	blt		.doOpen
	move.l	#timer_b_open_curtain,$120.w



	jmp		.doClose
.doOpen
	move.l	#tboc,$120.w
.doClose
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))


	movem.l	voxelPal2,d0-d7
	movem.l	d1-d7,$ffff8240+4

		    IFEQ	DO_SOLID
	jsr		doPalIn
	jsr		doPalOut	
			ELSE
	cmp.w	#16,voxelListOff
	bne		.skip
		jsr		mergeFlash
		tst.w	vertStripesDone
		bne		.skip
		jsr		mergeFlash2
.skip
			ENDC

	IFEQ	FLASH
	cmp.w	#160-96,voxelScreenOff
	bne		.ok
		subq.w	#1,.flashWaiter
		bge		.ok
		lea		flashPal,a0
		add.w	flashPalOff,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
		swap	d0
		move.w	d0,timer_b_open_curtain+2
		move.w	#0,$ffff8240
			jsr		copyPicture1
			lea		cshift1d,a0
			lea		cshift2d,a2
			jsr		copyChunkyTable

			move.w	#6,.flashWaiter
			sub.w	#32,flashPalOff
			bge		.ok
				move.w	#0,flashPalOff
				move.w	#32000,.flashWaiter
.ok
	ELSE
	cmp.w	#160-96,voxelScreenOff
	bne		.ok	
		subq.w	#1,.ttttw
		bge		.ok
		jsr		drawPictureVoxel
;			lea		cshift1d,a0
;			lea		cshift2d,a2
;			jsr		copyChunkyTable
.ok
	ENDC

			cmp.w	#17,vertWaiter
			bge		.skiplam
				jsr	removePanelLamelsVoxel
.skiplam
		
    IFEQ	USE_MYM_DUMP
		jsr		replayMymDump
	ELSE
    	IFNE	STANDALONE
    	jsr		musicPlayer+8
    	ENDC
	ENDC
	cmp.w	#100,effectCounter
	bne		.kk
		move.w	vblCounter,d0
		move.w	effectCounter,d1
		addq.w	#1,effectCounter
.kk
            popall
    rte
.ttttw			dc.w	2
.flashWaiter	dc.w	0
tbwait			dc.w	350
flashPalOff		dc.w	7*32

	IFEQ	STANDALONE
frameCounter	dc.w	0
effectCounter	dc.w	0
vblCounter		dc.w	0
	ENDC







mergeFlash
	subq.w	#1,.waiter
	bge		.ok
		move.w	#3,.waiter
		lea		introPal,a0
		add.w	flashPalOff,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,voxelPal2
		move.w	d0,$ffff8242
		jsr		updateTexture
		move.w	#0,$fff8240
		sub.w	#32,flashPalOff
		bge		.ok
			move.w	#$4e75,mergeFlash
			move.w	#0,.waiter
.ok
	rts
.waiter	dc.w	1

updateTexture
	lea		cshift1d,a0
	lea		cshift2d,a2
	jsr		copyChunkyTable
	move.w	#$4e75,updateTexture
	rts

mergeFlash2
	subq.w	#1,.waiter
	bge		.ok
		move.w	#0,underLineHax
		move.w	#2,.waiter
	move.w	#$4e75,doMovement
	move.w	#0,doCopyAndStopEffect
	lea		introPal,a0
	add.w	flashPalOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,voxelPal2
	move.w	#0,$fff8240
	move.w	d0,$ffff8242
	sub.w	#32,flashPalOff
	bge		.ok
		move.w	#$4e75,mergeFlash2
		move.w	#0,offset_adjust		
		move.w	#0,.waiter
		move.w	#32*7,flashPalOff
.ok
	jsr		copyStillToBuffer
	rts
.waiter	dc.w	0
doCopyAndStopEffect	dc.w	-1

copyStillToBuffer
	move.l	screenpointer,a0
	move.l	stillBuffer1,a1
	move.l	stillBuffer2,a2
	move.l	stillBuffer3,a3
;	move.l	a0,a1
	add.w	#64+4*160,a0
	move.w	#96-1,d7
.l												; there are 4,4,4 blocks
		movem.l	(a0)+,d0-d6/a6					; first block		
		movem.l	d0-d6/a6,(a1)
		movem.l	(a0)+,d0-d6/a6					; first block		
		movem.l	d0-d6/a6,(a2)
		movem.l	(a0)+,d0-d6/a6					; first block		
		movem.l	d0-d6/a6,(a3)
		lea		32(a1),a1
		lea		32(a2),a2
		lea		32(a3),a3
		lea		320-96(a0),a0

	dbra	d7,.l
	moveq	#0,d0
;	move.w	effectCounter,d0
;	move.b	#0,$ffffc123
;	move.l	stillBuffer1,a0				; 96*4*8 = 3072
;	move.l	stillBuffer2,a1
;	move.l	stillBuffer3,a2
	move.w	#$4e75,copyStillToBuffer
	rts
	IFEQ	STANDALONE
stillBuffer1	dc.l	0
stillBuffer2	dc.l	0
stillBuffer3	dc.l	0
	ENDC

doPalIn
	lea		introPal,a0
	add.w	introPalOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	subq.w	#1,.waiter
	bge		.end
		move.w	#4,.waiter
		sub.w	#32,introPalOff
		bge		.end
			move.w	#0,introPalOff
			move.w	#$4e75,doPalIn
.end
	rts
.waiter	dc.w	50


doPalOut
	cmp.w	#4*172,skipnr
	ble		.ok2
		subq.w	#1,.fadeWaiter
		bge		.ok2
			move.w	#3,.fadeWaiter

		IFEQ	FLASH
		lea		flashPal,a0
		add.w	flashPalOff,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
		move.w	#0,$ffff8240

		add.w	#32,flashPalOff
		cmp.w	#32*8,flashPalOff
		bne		.ok2
			move.w	#32*7,flashPalOff
		ELSE
		lea		introPal,a0
		add.w	introPalOff,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
		move.w	#0,$ffff8240
		add.w	#32,introPalOff
		cmp.w	#32*8,introPalOff
		bne		.ok2
			move.w	#32*7,introPalOff
		ENDC


.ok2
	rts
.fadeWaiter		dc.w	0


;copyPicture1
;;	lea		panel1+128,a0
;	move.l	panel1Pointer,a0
;	add.w	#128,a0
;	move.l	screenpointer,a1
;	move.l	screenpointer2,a2
;	move.w	#200-1,d7
;.cp
;	movem.l	(a0)+,d0-d7
;	movem.l	d0-d7,(a1)
;	movem.l	d0-d7,(a2)
;	movem.l	(a0)+,d0-d7
;	movem.l	d0-d7,32(a1)
;	movem.l	d0-d7,32(a2)
;;	lea		160-8*8(a0),a0
;	lea		160(a1),a1
;	lea		160(a2),a2
;	dbra	d7,.cp
;	rts

drawPictureVoxel
;	lea		panel1+128,a0
	move.l	panel1Pointer,a0
	add.w	#64*2,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#160,a1
	add.w	#160,a2
	moveq	#0,d0
	move.w	drawOffVoxel,d0
	tst.w	.even
	beq		.filler
	blt		.uneven
;		muls	#160,d0
		add.w	d0,a1
		add.w	d0,a2
		divs	#160,d0
		asl.w	#6,d0
		add.w	d0,a0	

		movem.l	(a0)+,d0-d7		;8
		movem.l	d0-d7,(a1)
		movem.l	d0-d7,(a2)		;6	-> 7*8
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32(a1)
		movem.l	d0-d7,32(a2)

;		lea		160-8*8(a0),a0

		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+160(a1)
		movem.l	d0-d7,+160(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+160(a1)
		movem.l	d0-d7,32+160(a2)


		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+320(a1)
		movem.l	d0-d7,+320(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+320(a1)
		movem.l	d0-d7,32+320(a2)


		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+480(a1)
		movem.l	d0-d7,+480(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+480(a1)
		movem.l	d0-d7,32+480(a2)


		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+640(a1)
		movem.l	d0-d7,+640(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+640(a1)
		movem.l	d0-d7,32+640(a2)

		add.w	#10*160,drawOffVoxel
		cmp.w	#200*160,drawOffVoxel
		blt		.end
			neg.w	.even
			move.w	#195*160,drawOffVoxel
;			sub.w	#1*160,drawOffVoxel
		rts
.uneven
;		muls	#160,d0
		add.w	d0,a1
		add.w	d0,a2
		divs	#160,d0
		asl.w	#6,d0
		add.w	d0,a0	
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		movem.l	d0-d7,(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32(a1)
		movem.l	d0-d7,32(a2)

		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+160(a1)
		movem.l	d0-d7,+160(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+160(a1)
		movem.l	d0-d7,32+160(a2)

		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+320(a1)
		movem.l	d0-d7,+320(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+320(a1)
		movem.l	d0-d7,32+320(a2)

		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+480(a1)
		movem.l	d0-d7,+480(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+480(a1)
		movem.l	d0-d7,32+480(a2)

		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,+640(a1)
		movem.l	d0-d7,+640(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+640(a1)
		movem.l	d0-d7,32+640(a2)



		sub.w	#10*160,drawOffVoxel
		bge		.end
			move.w	#0,.even
			move.w	#4*160,drawOffVoxel
.end
	rts
.filler

	add.w	#62+2*160+2,a1
	add.w	#62+2*160+2,a2
	moveq	#-1,d1
	move.w	#%1111111111110000,d2
	move.w	#%0000111111111111,d3
;	muls	#160,d0
	add.w	d0,a1
	add.w	d0,a2
.y set 0
	REPT 3
		move.w	d1,.y(a1)
		move.w	d1,.y(a2)
.y set .y+8
	ENDR
		move.w	d2,.y(a1)
		move.w	d2,.y(a2)
.y set .y+8
	REPT 4
		move.w	d1,.y(a1)
		move.w	d1,.y(a2)
.y set .y+8
	ENDR
		move.w	d3,.y(a1)
		move.w	d3,.y(a2)
.y set .y+8
	REPT 3
		move.w	d1,.y(a1)
		move.w	d1,.y(a2)
.y set .y+8
	ENDR

	add.w	#2*160,drawOffVoxel
	cmp.w	#192*160,drawOffVoxel
	bne		.end
		move.w	#$4e75,drawPictureVoxel
	rts

.even	dc.w	1
drawOffVoxel	dc.w	0

clearCanvasVoxel
	move.l	canvasPointerVoxel,a0
	add.w	#40*96*2,a0

	move.l	#$f0,d0
	move.l	#$0F,d1

	cmp.w	#160-96,voxelScreenOff
	beq		.ok
		lea		voxelList,a1
		add.w	voxelListOff,a1
		move.l	(a1),d2
		cmp.l	#doVoxel,d2
		bne		.ok
			exg	d0,d1
.ok
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,a1
	move.l	d0,a2
	move.l	d1,a3
	move.l	d0,a4
	move.l	d1,a5
	move.w	#4-1,d7
.l
	REPT 40												; 80*4 = 320
		movem.l	d0-d6/a1/a2/a3/a4/a5,-(a0)
	ENDR
	dbra	d7,.l
	rts


generateDivTable
	moveq	#0,d0
	move.w	#100-1,d7
	lea		divTable,a0
	lea		divTable,a1
.doDiv
		move.l	d0,d2

		divs	#96,d2							;144
		move.w	d2,d3			; integer		;4
		sub.w	d2,d2							;4
		lsr.l	#1,d2							;8
		divs	#96,d2			; fraction		;144
		add.w	d2,d2							;4
		swap	d2								;4
		move.w	d3,d2							;4
		swap	d2
		move.l	d2,(a0)+							;20		-->	364*2 = 728	14560
		neg.l	d2
		move.l	d2,-(a1)

		addq.w	#1,d0
	dbra	d7,.doDiv
	rts

doMovement
;	subq.w	#1,.w
;	bge		.noph
;;		move.w	#1,.w
;	  	sub.w	#2,phi
;.noph
	subq.w	#1,.waiter
	bge		.kkk
		subq.w	#1,.times
		blt		.kkk
			add.w	#4,phi
			jmp		.nnn
.kkk
	move.w	#148,phi
.nnn
 	and.w	#512-1,phi
  	sub.l	#$1d000,px
   	and.w	#128-1,px
.hax
  	add.l	#$18000,py
   	and.w	#128-1,py
   	rts
.waiter	dc.w	150
.times	dc.w	128
.w	dc.w	1


px					dc.l	23<<16
py					dc.l	92<<16
pz					dc.l	10
phi					dc.l	0

sinPhi				dc.l	0
cosPhi				dc.l	0

doVoxel
	lea		_sintable512,a5			;	sin
	lea		_sintable512+256,a6		;	cos
	move.w	phi,d7				;	angle phi
	add.w	d7,d7	
	move.w	(a5,d7.w),sinPhi
	move.w	(a6,d7.w),cosPhi			

	move.w	#(192/2-1),d0
	add.w	d0,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,d1
	swap	d1
	move.w	d0,d1

.fixYbuffer
	move.l	d1,d0
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7					;7*4.= 28
	lea		ybuffer+96*2,a0

	REPT 7
	movem.l	d0-d7,-(a0)				;72*7 = 504
	ENDR

	moveq	#1,d0					;dz
	move.l	pz,d1					;z
;	swap	d1
;	move.l	d1,a2
;	add.l	#40<<16,a2				;40 depth
;	swap	d1
	move.l	canvasPointerVoxel,a3		
	add.w	#500,a3
	move.l	a3,usp
	move.l	canvasOffsetListPointer,d3
	move.l	cshift2Pointer,d4
	move.l	heightMapPointer,d6
	
.doDistanceStep
	swap	d1
	cmp.l	#50<<16,d1
	bge		enditvoxel
doIter
		swap	d1
		; rotation of points and angles
;		lea		sinTable,a5			;	sin
;		lea		sinTable+256,a6		;	cos
;		move.w	phi,d7				;	angle phi
;		add.w	d7,d7				
		move.w	d1,d2				;	z
;		muls.w	(a5,d7.w),d2		;	sin phi * z
		muls.w	sinPhi,d2		;	sin phi * z
		add.l	d2,d2				;	nomalize
		move.l	d2,a3				;	a3 = sinPhi
		move.w	d1,d2
;		muls	(a6,d7.w),d2		;	cos phi * z
		muls	cosPhi,d2
		add.l	d2,d2
		move.l	d2,a4				;	a4 = cosPhi
		;pleft.x
		move.l	a4,d2				;	cosPhi
		neg.l	d2					;	-cosPhi
		sub.l	a3,d2				;	-cosPhi - sinPhi
		moveq	#0,d7				;
		move.w	px,d7				;	__.ii	
		swap	d7					;	ii.ff
		add.l	d7,d2				;	-cosPhi - sinPhi + p.x
		add.l	d2,d2				;	shift 1
		swap	d2					;	ff.ii
		move.w	d2,a1				;	a1 = pleft
		;pright.x
		pushd0
		move.l	a4,d0				;	cosPhi
		sub.l	a3,d0				;	cosPhi - sinPhi
		add.l	d7,d0				;	cosPhi - sinPhi + p.x
		swap	d0					;	d0 = pright
		;pleft.y
		move.l	a3,d5				;	sinPhi
		sub.l	a4,d5				;	sinPhi - cosPhi
		moveq	#0,d7				;
		move.w	py,d7				;	__.ii	py
		swap	d7					;	ii.ff
		add.l	d7,d5				;	sinPhi - cosPhi + p.y
		;pright.y
		move.l	a3,d2				;	sinPhi
		neg.l	d2					;	-sinPhi
		sub.l	a4,d2				;	-sinPhi - cosPhi
		add.l	d7,d2				;	-sinPhi - cosPhi + p.y
		swap	d2
		;pleft.y shift
		move.l	d5,d7
		asl.l	#8,d7
		swap	d5
		swap	d7
;        # segment the line
		lea		divTable,a6	
		add.w	d0,d0
		sub.w	a1,d0
		add.w	d0,d0
		and.w	#-4,d0
		move.l	(a6,d0.w),d0		;	dx = (pright.x - pleft.x) / screen_width
		swap	d0
		move.l	d0,a3
		sub.w	d5,d2
		add.w	d2,d2
		add.w	d2,d2
		move.l	(a6,d2.w),d0		;	dy = (pright.y - pleft.y) / screen_width
.prepDoLeftRight
		lea		ybuffer,a5
		pushd1
		asl.l	#8,d0			;ii.ff << 7
		swap	d0				;f_.if
		move.l	d0,a2

		move.w	d7,d0

		moveq	#0,d2
		move.w	a1,d2

		move.l	vdivtablePointer,a0
		sub.w	#10,d1
		asl.w	#6,d1
		add.w	d1,a0

		move.l	cshift1Pointer,d1
;	in use:
	; d0	pleft.y
	; d1	cshift1Pointer
	; d2		
	; d3	local, height / canvasOffsetListPointer
	; d4	cshift2Pointer
	; d5	nr of blocks
	; d6	local -> heightMapPointer
	; d7	

	; a0	vdivtabvle
	; a1	-
	; a2	dy
	; a3	dx
	; a4	canvas
	; a5	yheight buffer
	; a6	canvasOffsetList

	moveq	#0,d5
	moveq	#-2,d7
.doLeftRightExec
doLeftRight macro
	move.w	d0,d6				; pleft.y					;4
	move.b	d2,d6				; pleft_y+pleft_x			;4
	and.w	d7,d6				; zero out lower bit		;4
	add.l	a3,d2											;8
	addx.w	d5,d2											;4
	add.w	a2,d0											;4			60
	move.l	d6,a4				; hightMapPointer			;4
	move.b	(a4)+,\2			; height					;8
	move.w	(a0,\2.w),a1		; nr of blocks				;16			44		
	move.w	(a5)+,d3			; y-height on screen		;8		
	move.l	d3,a6				; pointer					;4		
	sub.w	a1,d3				; number of lines			;4		
	bgt		.incr\@											;8			24
		move.w	a1,-2(a5)		; save new y-height			;12			
		move.b	(a4)+,\2		; color						;8
		move.l	\2,a4										;4	
		move.l	(a4),a1										;12
		move.l	usp,a4										;4
		add.w	(a6),a4										;12
		add.w	#50*4,d3									;8
		jmp		2(pc,d3)										; if I jump forward, I have no problem with range
																; but to determine jump forward, I need to have															
.off set -96*50*2-500+\1
		REPT 50
.off set .off+96*2
			move.l	a1,.off(a4)
		ENDR
.incr\@
	endm

;.xoff set 0
;		REPT 96/4
;		doLeftRight .xoff,d1
;.xoff set .xoff+4
;		doLeftRight .xoff,d4
;.xoff set .xoff+4
;		ENDR
;	move.b	#0,$ffffc123
tmpptr1		jsr		123456.l

.endStuff
	popd1
	popd0
	add.l	d0,d1				; z += dz
	add.l	#INCVAL,d0		; dz += 0.25		8=0.5, 4=0.25 2=0,12
	addx.l	d5,d0

	swap	d1
	cmp.l	#50<<16,d1
	blt		doIter

enditvoxel
	rts


voxelInner1Pointer	ds.l	1
voxelInner2Pointer	ds.l	1

generateVoxelInnner
	move.l	voxelInner1Pointer,a0
	moveq	#0,d1
	move.w	#96*2,d2
	move.w	#96/4-1,d6
.genLoop
	lea		.template,a1
	move.l	(a1)+,(a0)+				;move.w	d0,d6	;	move.b	d2,d6
	move.l	(a1)+,(a0)+				;and.w	d7,d6	;	add.l	a3,d2
	move.l	(a1)+,(a0)+				;addx.w	d5,d2	;	add.w	a2,d0
	move.w	(a1)+,(a0)+				;move.l	d6,a4
	move.l	.d1_1,(a0)+				;move.b (a4)+,d1;	move.w	(a0.d1.w),a1
	move.w	.d1_1+4,(a0)+			;move.b (a4)+,d1;	move.w	(a0.d1.w),a1
	move.l	(a1)+,(a0)+				;move.w	(a5)+,d3;	move.l	d3,a6
	move.l	(a1)+,(a0)+				;sub.w	a1,d3		bgt
	move.w	#$e0,(a0)+				; offset
	add.w	#2,a1
	move.l	(a1)+,(a0)+				;move.w	a1,-2(a5)
	move.l	.d1_2,(a0)+				;move.b (a4)+,d1	move.l	d1,a4
	move.l	(a1)+,(a0)+				;move.l	(a4),a1		move.l	usp,a4
	move.l	(a1)+,(a0)+				;add.w	(a6),a4		add.w	x,d3
	move.w	(a1)+,(a0)+
	move.l	(a1)+,(a0)+				;jmp	2(pc,d3)
	move.w	#50-1,d7
	move.l	.iloop,d0
	move.w	#-96*50*2-500,d0
	add.w	d1,d0
	addq.w	#4,d1
.loop
		add.w	d2,d0
		move.l	d0,(a0)+
	dbra	d7,.loop				

	lea		.template,a1
	move.l	(a1)+,(a0)+				;move.w	d0,d6	;	move.b	d2,d6
	move.l	(a1)+,(a0)+				;and.w	d7,d6	;	add.l	a3,d2
	move.l	(a1)+,(a0)+				;addx.w	d5,d2	;	add.w	a2,d0
	move.w	(a1)+,(a0)+				;move.l	d6,a4
	move.l	.d4_1,(a0)+				;move.b (a4)+,d1;	move.w	(a0.d1.w),a1
	move.w	.d4_1+4,(a0)+
	move.l	(a1)+,(a0)+				;move.w	(a5)+,d3;	move.l	d3,a6
	move.l	(a1)+,(a0)+				;sub.w	a1,d3		bgt
	move.w	#$e0,(a0)+				; offset
	add.w	#2,a1
	move.l	(a1)+,(a0)+				;move.w	a1,-2(a5)
	move.l	.d4_2,(a0)+				;move.b (a4)+,d1	move.l	d1,a4
	move.l	(a1)+,(a0)+				;move.l	(a4),a1		move.l	usp,a4
	move.l	(a1)+,(a0)+				;add.w	(a6),a4		add.w	x,d3
	move.w	(a1)+,(a0)+
	move.l	(a1)+,(a0)+				;jmp	2(pc,d3)
	move.w	#50-1,d7
	move.l	.iloop,d0
	move.w	#-96*50*2-500,d0
	add.w	d1,d0
	addq.w	#4,d1
.loop2
		add.w	d2,d0
		move.l	d0,(a0)+
	dbra	d7,.loop2

	dbra	d6,.genLoop
	move.w	#$4e75,(a0)+
	sub.l	voxelInner1Pointer,a0
	move.l	voxelInner1Pointer,tmpptr1+2



	move.l	voxelInner2Pointer,a0
	moveq	#0,d1
	move.w	#96*2,d2
	move.w	#96/4-1,d6
.genLoop2
	lea		.template,a1
	move.l	(a1)+,(a0)+				;move.w	d0,d6	;	move.b	d2,d6
	move.l	(a1)+,(a0)+				;and.w	d7,d6	;	add.l	a3,d2
	move.l	(a1)+,(a0)+				;addx.w	d5,d2	;	add.w	a2,d0
	move.w	(a1)+,(a0)+				;move.l	d6,a4
	move.l	.d4_1,(a0)+				;move.b (a4)+,d1;	move.w	(a0.d1.w),a1
	move.w	.d4_1+4,(a0)+			;move.b (a4)+,d1;	move.w	(a0.d1.w),a1
	move.l	(a1)+,(a0)+				;move.w	(a5)+,d3;	move.l	d3,a6
	move.l	(a1)+,(a0)+				;sub.w	a1,d3		bgt
	move.w	#$e0,(a0)+				; offset
	add.w	#2,a1
	move.l	(a1)+,(a0)+				;move.w	a1,-2(a5)
	move.l	.d4_2,(a0)+				;move.b (a4)+,d1	move.l	d1,a4
	move.l	(a1)+,(a0)+				;move.l	(a4),a1		move.l	usp,a4
	move.l	(a1)+,(a0)+				;add.w	(a6),a4		add.w	x,d3
	move.w	(a1)+,(a0)+
	move.l	(a1)+,(a0)+				;jmp	2(pc,d3)
	move.w	#50-1,d7
	move.l	.iloop,d0
	move.w	#-96*50*2-500,d0
	add.w	d1,d0
	addq.w	#4,d1
.loop3
		add.w	d2,d0
		move.l	d0,(a0)+
	dbra	d7,.loop3			

	lea		.template,a1
	move.l	(a1)+,(a0)+				;move.w	d0,d6	;	move.b	d2,d6
	move.l	(a1)+,(a0)+				;and.w	d7,d6	;	add.l	a3,d2
	move.l	(a1)+,(a0)+				;addx.w	d5,d2	;	add.w	a2,d0
	move.w	(a1)+,(a0)+				;move.l	d6,a4
	move.l	.d1_1,(a0)+				;move.b (a4)+,d1;	move.w	(a0.d1.w),a1
	move.w	.d1_1+4,(a0)+
	move.l	(a1)+,(a0)+				;move.w	(a5)+,d3;	move.l	d3,a6
	move.l	(a1)+,(a0)+				;sub.w	a1,d3		bgt
	move.w	#$e0,(a0)+				; offset
	add.w	#2,a1
	move.l	(a1)+,(a0)+				;move.w	a1,-2(a5)
	move.l	.d1_2,(a0)+				;move.b (a4)+,d1	move.l	d1,a4
	move.l	(a1)+,(a0)+				;move.l	(a4),a1		move.l	usp,a4
	move.l	(a1)+,(a0)+				;add.w	(a6),a4		add.w	x,d3
	move.w	(a1)+,(a0)+
	move.l	(a1)+,(a0)+				;jmp	2(pc,d3)
	move.w	#50-1,d7
	move.l	.iloop,d0
	move.w	#-96*50*2-500,d0
	add.w	d1,d0
	addq.w	#4,d1
.loop4
		add.w	d2,d0
		move.l	d0,(a0)+
	dbra	d7,.loop4

	dbra	d6,.genLoop2
	move.w	#$4e75,(a0)+
	sub.l	voxelInner2Pointer,a0
	move.l	voxelInner2Pointer,tmpptr2+2

	rts


.d1_1
	move.b	(a4)+,d1
	move.w	(a0,d1.w),a1
.d1_2
	move.b	(a4)+,d1
	move.l	d1,a4
.d4_1
	move.b	(a4)+,d4
	move.w	(a0,d4.w),a1
.d4_2
	move.b	(a4)+,d4
	move.l	d4,a4	
.iloop
	move.l	a1,1234(a4)



.template
	move.w	d0,d6				; pleft.y					;4
	move.b	d2,d6				; pleft_y+pleft_x			;4
	and.w	d7,d6				; zero out lower bit		;4
	add.l	a3,d2											;8
	addx.w	d5,d2											;4
	add.w	a2,d0											;4			60
	move.l	d6,a4				; hightMapPointer			;4
;	move.b	(a4)+,\2
;	move.b	(a4)+,d1			; height					;8
;	move.b	(a4)+,d4			; height					;8
;	move.w	(a0,\2.w),a1		; nr of blocks				;16			44		
;	move.w	(a0,d1.w),a1		; nr of blocks				;16			44		
;	move.w	(a0,d4.w),a1		; nr of blocks				;16			44		
	move.w	(a5)+,d3			; y-height on screen		;8		
	move.l	d3,a6				; pointer					;4		
	sub.w	a1,d3				; number of lines			;4		
	bgt		*+$1234										;8			24
		move.w	a1,-2(a5)		; save new y-height			;12			
;		move.b	(a4)+,\2		; color						;8
;		move.b	(a4)+,d1		; color						;8
;		move.b	(a4)+,d4		; color						;8
;		move.l	\2,a4										;4	
;		move.l	d1,a4										;4	
;		move.l	d4,a4										;4	
		move.l	(a4),a1										;12
		move.l	usp,a4										;4
		add.w	(a6),a4										;12
		add.w	#50*4,d3									;8
		jmp		2(pc,d3)										; if I jump forward, I have no problem with range
																; but to determine jump forward, I need to have	

;.off set -96*50*2-500+\1
;		REPT 50
;.off set .off+96*2
;			move.l	a1,.off(a4)
;		ENDR
.incr

genSomeList
	moveq	#1,d0
	move.l	canvasOffsetListPointer,a0
	move.l	a0,a1
	add.l	#$10000,a1
	move.w	#400-1,d7
.l
		move.l	d0,d6
		lsl.w	#4,d6		;32																		;12							---> lsl.w	
		move.w	d6,d5		;1																		;4
		add.w	d6,d6		;64																		;4
		add.w	d5,d6		;24	
		add.w	d6,d6																	;4
		move.w	d6,(a0)+
		move.w	d6,-(a1)
		addq.w	#1,d0
	dbra	d7,.l
	rts

ybuffer				ds.w	192/2

makeVoxelDivTable
	move.l	vdivtablePointer,a0
	moveq	#10,d1				; z
	move.w	#100-1,d7
.ol
		move.w	#0,d0				; height
		move.w	#15,d6
.il
			moveq	#33,d5								; higher = more cpu free
			sub.w	d0,d5
			muls	#50,d5
			divs	d1,d5
			add.w	#0,d5
			add.w	d5,d5
			add.w	d5,d5
			neg.w	d5
			move.w	d5,(a0)+
			move.w	d5,(a0)+				;4 * 16 * 100
			addq.w	#1,d0
		dbra	d6,.il
		addq.w	#1,d1
	dbra	d7,.ol
	rts



planarToChunky
	lea		16384(a1),a2
	lea		16384(a2),a3
	lea		16384(a3),a4
	move.l	#128-1,d6
.height
	move.l	#8-1,d7
.width
	movem.w	(a0)+,d0-d3		; 4 words
	REPT 16									;28*16=448
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		add.b	d4,d4
		add.b	d4,d4
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
		addq.w	#1,a1
		move.b	d4,(a3)+					; 128 * 8 * 16 = 16k
		addq.w	#1,a3
	ENDR
	dbra	d7,.width

	; 320 width is 160 bytes
	; 128 width is 64 bytes
	; 160-64 added
	add.w	#160-64,a0
	dbra	d6,.height
	rts

stripeOffset	dc.w	0
vertStripesDone	dc.w	-1

doVertStripes2
	tst.w	doVert
	bne		.end

		subq.w	#1,vertWaiter
		bge		.end
	move.l	canvasPointerVoxel,a0
	; 2 longwords per 8 pixels
	move.l	#$0,d0
	move.w	stripeOffset,d7
	cmp.w	#4*96,d7
	ble		.kkk
		move.w	#4*96,d7
		move.w	#0,vertStripesDone
		move.w	#7*32,flashPalOff
.kkk
	neg.w	d7
	lea		.first,a1
	jmp		(a1,d7.w)

.x set 32*4+18364
	REPT 96
		and.l	d0,.x(a0)					; 384
.x set .x-96*2
	ENDR
.first

	move.w	stripeOffset,d7
	cmp.w	#4*96,d7
	ble		.kkk2
		move.w	#4*96,d7
.kkk2

	neg.w	d7
	lea		.second,a1
	jmp		(a1,d7.w)

.x set 32*4
	REPT 96
		and.l	d0,.x(a0)					; 384
.x set .x+96*2
	ENDR
.second

	; sinemove here	

	add.w	#8,stripeOffset
	cmp.w	#4*97,stripeOffset
	ble		.end
		move.w	#4*97,stripeOffset
		IFEQ	DO_SOLID
		move.w	#0,offset_adjust
		ENDC
.end
	rts
vertWaiter	dc.w	VOXEL_EFFECT_VBL
doVert		dc.w	-1




doVertStripes2b
	tst.w	doVert
	bne		.end
		tst.w	vertWaiter
		bge		.end

	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	blt		.skip
		add.w	d0,a6
.skip
	move.w	#%1111111111110000,d6			; 
	move.l	a6,usp

	add.l	off_left,a6
	move.w	stripeOffset,d7
	cmp.w	#96*4,d7
	ble		.kkkk
		move.w	#96*4,d7
.kkkk
	cmp.w	#12*4,d7
	ble		.ok
		move.w	#12*4,d7
.ok
	lea		.jmptab,a5
	neg.w	d7
	jmp		.jmptab(pc,d7)

.y set 6+24+3200+4*160-26*160
	REPT 12
		and.w	d6,.y(a6)
.y set .y-320
	ENDR
.jmptab

	move.w	stripeOffset,d7
	cmp.w	#96*4,d7
	ble		.kkkkk
		move.w	#96*4,d7
.kkkkk
	cmp.w	#(95-12)*4,d7
	ble		.end
		move.l	usp,a6
		add.l	off_right,a6	
		move.w	#%0000111111111111,d6
		sub.w	#(96-12)*4,d7
		neg.w	d7
		jmp		.jmptab2(pc,d7)
.y set 6+48-20*160+16
	REPT 13
		and.w	d6,.y(a6)
.y set .y+320
	ENDR		
.jmptab2
	cmp.w	#4*97,stripeOffset
	blt		.end
		and.w	d6,.y-13*320(a6)
	IFNE DO_SOLID
		and.w	d6,.y-13*320+160+2-8(a6)
		and.w	#%1111111111110000,.y-13*320+160+2-48(a6)
	ENDC
.end
	rts

off_left	dc.l	24*160
off_mid		dc.l	24*160
off_right	dc.l	24*160

adjustOffsets	
	tst.w	offset_adjust
	bne		.ok3

	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7

	move.w	d0,-1280-21*160(a6)
	move.w	d0,-1280-21*160+8(a6)
	move.w	d0,-1280-21*160+16(a6)
	move.w	d0,-1280-21*160+24(a6)
	movem.l	d0-d7,-1280-20*160(a6)

	move.w	d0,-960-21*160(a6)
	move.w	d0,-960-21*160+8(a6)
	move.w	d0,-960-21*160+16(a6)
	move.w	d0,-960-21*160+24(a6)
	movem.l	d0-d7,-960-20*160(a6)

	move.w	d0,-640-21*160(a6)
	move.w	d0,-640-21*160+8(a6)
	move.w	d0,-640-21*160+16(a6)
	move.w	d0,-640-21*160+24(a6)
	movem.l	d0-d7,-640-20*160(a6)

	move.w	d0,-320-21*160(a6)
	move.w	d0,-320-21*160+8(a6)
	move.w	d0,-320-21*160+16(a6)
	move.w	d0,-320-21*160+24(a6)
	movem.l	d0-d7,-320-20*160(a6)

	move.w	d0,-1280+32-21*160(a5)
	move.w	d0,-1280+32-21*160+8(a5)
	move.w	d0,-1280+32-21*160+16(a5)
	move.w	d0,-1280+32-21*160+24(a5)
	movem.l	d0-d7,-1280+32-20*160(a5)

	move.w	d0,-960+32-21*160(a5)
	move.w	d0,-960+32-21*160+8(a5)
	move.w	d0,-960+32-21*160+16(a5)
	move.w	d0,-960+32-21*160+24(a5)
	movem.l	d0-d7,-960+32-20*160(a5)

	move.w	d0,-640+32-21*160(a5)
	move.w	d0,-640+32-21*160+8(a5)
	move.w	d0,-640+32-21*160+16(a5)
	move.w	d0,-640+32-21*160+24(a5)
	movem.l	d0-d7,-640+32-20*160(a5)

	move.w	d0,-320+32-21*160(a5)
	move.w	d0,-320+32-21*160+8(a5)
	move.w	d0,-320+32-21*160+16(a5)
	move.w	d0,-320+32-21*160+24(a5)
	movem.l	d0-d7,-320+32-20*160(a5)

	move.w	d0,-1280+64-21*160(a4)
	move.w	d0,-1280+64-21*160+8(a4)
	move.w	d0,-1280+64-21*160+16(a4)
	move.w	d0,-1280+64-21*160+24(a4)
	movem.l	d0-d7,-1280+64-20*160(a4)

	move.w	d0,-960+64-21*160(a4)
	move.w	d0,-960+64-21*160+8(a4)
	move.w	d0,-960+64-21*160+16(a4)
	move.w	d0,-960+64-21*160+24(a4)
	movem.l	d0-d7,-960+64-20*160(a4)

	move.w	d0,-640+64-21*160(a4)
	move.w	d0,-640+64-21*160+8(a4)
	move.w	d0,-640+64-21*160+16(a4)
	move.w	d0,-640+64-21*160+24(a4)
	movem.l	d0-d7,-640+64-20*160(a4)

	move.w	d0,-320+64-21*160(a4)
	move.w	d0,-320+64-21*160+8(a4)
	move.w	d0,-320+64-21*160+16(a4)
	move.w	d0,-320+64-21*160+24(a4)
	movem.l	d0-d7,-320+64-20*160(a4)

	subq.w	#1,.waiter_left
	bge		.ok1
;		move.w	#1,.waiter_left
		add.l	#4*160,off_left
		cmp.l	#220*160,off_left
		blt		.ok1
			move.l	#220*160,off_left
.ok1
	subq.w	#1,.waiter_mid
	bge		.ok2
;		move.w	#1,.waiter_mid
		add.l	#4*160,off_mid
		cmp.l	#220*160,off_mid
		blt		.ok2
			move.l	#220*160,off_mid
.ok2
	subq.w	#1,.waiter_right
	bge		.ok3
;		move.w	#1,.waiter_right
		add.l	#4*160,off_right
		; and here we also need to adjust the c2p rout
		move.l	#44*160,d0
		sub.l	off_right,d0
		bge		.nosmc
			cmp.w	#13440+10*172,skipnr
			bgt		.end
			moveq	#0,d0
			move.w	skipnr,d0			
			move.l	c2psmcLabelPointer,a3
			sub.l	d0,a3
			move.w	#$4e75,(a3)
			add.w	#2*172,skipnr
.nosmc
		cmp.l	#220*160,off_right
		blt		.ok3
			move.l	#220*160,off_right
.ok3
	rts
.end
;		move.b	#0,$ffffc123
		move.w	#$4e75,adjustOffsets
		move.w	#$4e75,c2p_1to4_static2
		move.w	#$4e75,clearCanvasVoxel
		move.w	#$4e75,moveEffect
		move.w	#$4e75,doVertStripes2
		move.w	#$4e75,doVertStripes2b
		move.w	#$4e75,doVoxel
	rts
.waiter_left		dc.w	2
.waiter_mid			dc.w	11
.waiter_right		dc.w	20
skipnr				dc.w	0
c2psmcLabelPointer	dc.l	0
offset_adjust		dc.w	-1

; 200
; 96*2 = 192 efffect
; 4 lines skipped
; 


c2p_1to4_moving_4
	
	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	blt		.skip
		add.w	d0,a6
.skip
	add.w	#24*160,a6


	tst.w	d0
	blt		.actualSkip
.noSkip
		moveq	#0,d0
		moveq	#0,d6
		moveq	#0,d7
		jmp		.gogo
.actualSkip
		add.w	d0,a6
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d7
		subq.w	#2,d7
		move.w	d7,d6
		subq.w	#2,d6
.gogo


		lea		23*96*2(a0),a0
		add.w	#23*320,a6
		move.l	left4Pointer,a5
		jsr		(a5)

		IFEQ	DO_SOLID

	move.w	voxelScreenOff,d1
	move.l	screenpointer2,a6
	add.w	#12*8,d1
	bgt		.do2
;	blt		.skippp
	add.w	d1,a6
	add.w	#(7+64)*160,a6
	move.w	#%1111000000000000,d0
.y set 0
	REPT 29
		move.w	d0,.y(a6)
.y set .y+320
	ENDR
	jmp	.skippp
.do2
	
	add.w	d1,a6
	add.w	#(7+64)*160,a6
	move.w	#%1111000000000000,d0
	moveq	#-1,d1
.y set 0
	REPT 29
		move.w	d0,.y(a6)
		move.w	d1,.y-8(a6)
.y set .y+320
	ENDR

		ENDC


.skippp


;	; 6, 8*11*2, 8 , 6
;.y set 0
;	REPT 30
;		lea		(a0,d6.w),a0
;		jmp		2(pc,d7.w)
;.x set .y
;		move.l	(a0)+,d0								;2												4
;		movep.l	d0,.x+0(a6)								;4			-> 6
;		REPT 11
;			move.l	(a0)+,d0							;8												8
;			or.l	(a0)+,d0
;			movep.l	d0,.x+1(a6)			
;
;			move.l	(a0)+,d0							;8			--> 11 * 8 * 2 = 176				8
;			or.l	(a0)+,d0
;			movep.l	d0,.x+8(a6)
;.x set .x+8
;		ENDR
;
;			move.l	(a0)+,d0							;8			-> 8
;			or.l	(a0)+,d0
;			movep.l	d0,.x+1(a6)
;
;			move.l	(a0)+,d0							;6			-> 6 --> 196
;			movep.l	d0,.x+8(a6)
;.y set .y+2*160
;	ENDR






; right
	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	move.w	d0,d5
	cmp.w	#-40,d0
	ble		.end
		move.l	a6,a5
		move.l	a6,a4
		add.l	off_left,a6
		add.w	#64,a6
		sub.w	#64,d0
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d6
		move.w	d0,d7
.gogo2



	lea		-20*160(a6),a1
	lsr.w	#1,d0
	add.w	d0,a1
	lsr.w	#1,d0
	move.w	#%1111,d2
	moveq	#-1,d1
	move.w	d2,d3
	not.w	d3
	move.l	drawSkyPointer,a5
	jsr		(a5)
;.y set 0
;	REPT 10
;.x set .y+12*8
;		jmp		2(pc,d0)						;4
;.x set .x-8
;		REPT 12
;			move.w	d1,.x+6(a1)					;4*12 = 48
;.x set .x-8
;		ENDR
;			move.w	d2,.x+6(a1)					;4 = 56 --> 560
;.x set .x-8
;.y set .y+320
;	ENDR

	; here we need to select the steplist
	lea		.stepList,a5		; steplist
	; offset into steplist 
	add.w	#32,d5
	add.l	4(a5,d5.w),a6
	move.l	(a5,d5.w),a5
	move.w	#21-1,d5
	jsr		(a5)

	lea		32*96*2(a0),a0
	add.w	#320+33*320,a6

	move.w	#31-1,d5
	jsr		(a5)


.end
	rts


makeStep4	macro
.y set 0
.loop\@
;	REPT 21
.x set .y		
		move.l	(a0)+,d0					
		movep.l	d0,.x+1(a6)	
		REPT \1
			move.l	(a0)+,d0
			or.l	(a0)+,d0
			movep.l	d0,.x+8(a6)			;24		--> 32	4*32+76=	204/4 = 51				204*6*86 = 105264

			move.l	(a0)+,d0
			or.l	(a0)+,d0
			movep.l	d0,.x+9(a6)
.x set .x+8
		ENDR
;.y set .y+320
		lea		320(a6),a6
		lea		-4(a0,d6),a0
;	ENDR
		dbra	d5,.loop\@
	rts
	endm


.stepList
	dc.l	.step00,88
	dc.l	.step01,80
	dc.l	.step02,72
	dc.l	.step03,64
	dc.l	.step04,56
	dc.l	.step05,48
	dc.l	.step06,40
	dc.l	.step07,32
	dc.l	.step08,24
	dc.l	.step09,16
	dc.l	.step10,8
	dc.l	.step11,0

.step00
	makeStep4 0
.step01
	makeStep4 1
.step02
	makeStep4 2
.step03
	makeStep4 3
.step04
	makeStep4 4
.step05
	makeStep4 5
.step06
	makeStep4 6
.step07
	makeStep4 7
.step08
	makeStep4 8
.step09
	makeStep4 9
.step10
	makeStep4 10
.step11
	makeStep4 11


left4Pointer	ds.l	1			

genLeft4Code
	move.l	left4Pointer,a6
	lea		.left4Template,a5
	move.l	(a5)+,a0					; lea		(a0,d6),a0
	move.l	(a5)+,a1					; jmp		2(pc,d7.w)
	move.l	(a5)+,a2					; move.l	(a0)+,d0		; movep.l	d0,.x(a6)
	add.w	#2,a5
	move.l	(a5)+,a3					; move.l	(a0)+,d0		; or.l		(a0)+,d0
	move.l	(a5)+,d0					; movep.l	d0,.x+1(a6)
	moveq	#0,d5						; y
	move.w	#320,d4						; inc y

	move.w	#30-1,d7
.loop
		move.w	#11-1,d6
		move.w	d5,d0

		move.l	a0,(a6)+
		move.l	a1,(a6)+
		move.l	a2,(a6)+
		move.w	d0,(a6)+				;14
.loopx
			addq.w	#1,d0
			move.l	a3,(a6)+
			move.l	d0,(a6)+

			addq.w	#7,d0
			move.l	a3,(a6)+
			move.l	d0,(a6)+
		dbra	d6,.loopx				;16 * 11

		addq.w	#1,d0
		move.l	a3,(a6)+
		move.l	d0,(a6)+
		addq.w	#7,d0
		move.l	a2,(a6)+
		move.w	d0,(a6)+				;14 			

		add.w	d4,d5
	dbra	d7,.loop
	move.w	#$4e75,(a6)+				; ( 11 * 16 + 28 ) * 30 + 2 = 6122
	rts
.left4Template
	; 6, 8*11*2, 8 , 6
.y set 0
;	REPT 30
		lea		(a0,d6.w),a0
		jmp		2(pc,d7.w)
.x set .y
		move.l	(a0)+,d0								;2												4
		movep.l	d0,.x+0(a6)								;4			-> 6
;		REPT 11
			move.l	(a0)+,d0							;8												8
			or.l	(a0)+,d0
			movep.l	d0,.x+1(a6)			

			move.l	(a0)+,d0							;8			--> 11 * 8 * 2 = 176				8
			or.l	(a0)+,d0
			movep.l	d0,.x+8(a6)
;.x set .x+8
;		ENDR

;			move.l	(a0)+,d0							;8			-> 8
;			or.l	(a0)+,d0
;			movep.l	d0,.x+1(a6)

;			move.l	(a0)+,d0							;6			-> 6 --> 196
;			movep.l	d0,.x+8(a6)
;.y set .y+2*160
;	ENDR

drawSkyPointer	ds.l	1
genDrawSky
	move.l	drawSkyPointer,a6
	lea		.template,a5
	move.l	(a5)+,a0			; jmp
	move.l	(a5)+,d0
	move.l	(a5)+,d1
	move.w	#320,d3
	move.w	#12*8+6,d4			; .y
	move.w	#10-1,d7
.loop
		move.l	a0,(a6)+
		move.w	d4,d2			;.x = .y
		move.w	#12-1,d6
.xloop
			subq.w	#8,d2
			move.w	d2,d0
			move.l	d0,(a6)+
		dbra	d6,.xloop
		subq.w	#8,d2
		move.w	d2,d1
		move.l	d1,(a6)+
		add.w	d3,d4
	dbra	d7,.loop
	move.w	#$4e75,(a6)+			;562
	rts
.template
.y set 0
;	REPT 10
.x set .y+12*8
		jmp		2(pc,d0)						;4
;.x set .x-8
;		REPT 12
			move.w	d1,.x+6(a1)					;4*12 = 48
;.x set .x-8
;		ENDR
			move.w	d2,.x+6(a1)					;4 = 56 --> 560
;.x set .x-8
;.y set .y+320
;	ENDR

c2p_1to4_moving_8
	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	blt		.skip
		add.w	d0,a6
.skip
	add.w	#24*160,a6

	tst.w	d0
	blt		.actualSkip
.noSkip
		moveq	#0,d6
		moveq	#0,d7
		moveq	#0,d0
		jmp		.gogo
.actualSkip
		add.w	d0,a6
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d6
		subq.w	#8,d6
		move.w	d0,d7
		subq.w	#8,d7
.gogo

		lea		23*96*2(a0),a0
		add.w	#23*320,a6

		move.l	left8Pointer,a5
		jsr		(a5)


		IFEQ	DO_SOLID

	move.w	voxelScreenOff,d0
	move.l	screenpointer2,a6
	add.w	#12*8,d0
;	blt		.skippp
	add.w	d0,a6
	add.w	#(7+64)*160,a6
	move.w	#%1111111100000000,d0
.y set 0
	REPT 29
		move.w	d0,.y(a6)
.y set .y+320
	ENDR
		ENDC
;.skippp

;.y set 0
;	REPT 30
;	lea		(a0,d6),a0
;	jmp		2(pc,d7)
;.x set .y
;		REPT 12
;			move.l	(a0)+,d0				;4*8*6*86
;			or.l	(a0)+,d0
;			movep.l	d0,.x+1(a6)			;24		--> 32	4*32+76=	204/4 = 51				204*6*86 = 105264
;
;			move.l	(a0)+,d0
;			or.l	(a0)+,d0
;			movep.l	d0,.x+8(a6)
;.x set .x+8
;		ENDR
;.y set .y+2*160
;	ENDR


; right

	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	move.w	d0,d5
	cmp.w	#-40,d0
	ble		.end
		move.l	a6,a5
		move.l	a6,a4
		add.l	off_left,a6
		add.w	#64,a6
		sub.w	#64,d0
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d6
		move.w	d0,d7
.gogo2

	lea		-20*160(a6),a1
	lsr.w	#1,d0
	add.w	d0,a1
	lsr.w	#1,d0
	move.w	#%11111111,d2
	moveq	#-1,d1
	move.w	d2,d3
	not.w	d3
	move.l	drawSkyPointer,a5
	jsr		(a5)

;.y set 0
;	REPT 10
;.x set .y+12*8
;		jmp		2(pc,d0)
;.x set .x-8
;		REPT 12
;			move.w	d1,.x+6(a1)
;.x set .x-8
;		ENDR
;			move.w	d2,.x+6(a1)
;.x set .x-8
;.y set .y+320
;	ENDR


	; here we need to select the steplist
	lea		.stepList,a5		; steplist
	; offset into steplist 
	add.w	#32,d5
	add.l	4(a5,d5.w),a6
	move.l	(a5,d5.w),a5
	move.w	#21-1,d5
	jsr		(a5)

	lea		32*96*2(a0),a0
	add.w	#320+33*320,a6

	move.w	#31-1,d5
	jsr		(a5)



.end
	rts
makeStep8	macro
.y set 0
.loop\@
;	REPT 21
.x set .y		
		move.l	(a0)+,d0	
		or.l	(a0)+,d0				
		movep.l	d0,.x+1(a6)	
		REPT \1
			move.l	(a0)+,d0
			or.l	(a0)+,d0
			movep.l	d0,.x+8(a6)			;24		--> 32	4*32+76=	204/4 = 51				204*6*86 = 105264

			move.l	(a0)+,d0
			or.l	(a0)+,d0
			movep.l	d0,.x+9(a6)
.x set .x+8
		ENDR
;.y set .y+320
		lea		320(a6),a6
		lea		-8(a0,d6),a0
;	ENDR
		dbra	d5,.loop\@
	rts
	endm


.stepList
	dc.l	.step00,88
	dc.l	.step01,80
	dc.l	.step02,72
	dc.l	.step03,64
	dc.l	.step04,56
	dc.l	.step05,48
	dc.l	.step06,40
	dc.l	.step07,32
	dc.l	.step08,24
	dc.l	.step09,16
	dc.l	.step10,8
	dc.l	.step11,0

.step00
	makeStep8 0
.step01
	makeStep8 1
.step02
	makeStep8 2
.step03
	makeStep8 3
.step04
	makeStep8 4
.step05
	makeStep8 5
.step06
	makeStep8 6
.step07
	makeStep8 7
.step08
	makeStep8 8
.step09
	makeStep8 9
.step10
	makeStep8 10
.step11
	makeStep8 11

left8Pointer	ds.l	1			;6002

genLeft8Code
	move.l	left8Pointer,a6
	lea		.left8Template,a5
	move.l	(a5)+,a0				; lea	(a0,d6),a0
	move.l	(a5)+,a1				; jmp	2(pc,d7)
	move.l	(a5)+,a2				; move.l	(a0)+,d0		or.l	(a0)+,d0
	move.l	(a5)+,d0				; movep.l	d0,xxxx(a6)
	moveq	#0,d1					; .y
	move.w	#320,d2

	move.w	#30-1,d7

.loop
		move.l	a0,(a6)+				
		move.l	a1,(a6)+			;8
		move.w	d1,d0
		move.w	#12-1,d6
.loopx
			addq.w	#1,d0
			move.l	a2,(a6)+
			move.l	d0,(a6)+

			addq.w	#7,d0
			move.l	a2,(a6)+
			move.l	d0,(a6)+		;16				(12*16 + 8) * 30 = 6000
		dbra	d6,.loopx


		add.w	d2,d1
	dbra	d7,.loop
	move.w	#$4e75,(a6)+			; 6002
	rts


.left8Template
.y set 0
;	REPT 30
	lea		(a0,d6),a0
	jmp		2(pc,d7)
.x set .y
;		REPT 12
			move.l	(a0)+,d0				;4*8*6*86
			or.l	(a0)+,d0
			movep.l	d0,.x+1(a6)			;24		--> 32	4*32+76=	204/4 = 51				204*6*86 = 105264

;			move.l	(a0)+,d0
;			or.l	(a0)+,d0
;			movep.l	d0,.x+8(a6)
;.x set .x+8
;		ENDR
;.y set .y+2*160
;	ENDR



c2p_1to4_moving_12
	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	blt		.skip
		add.w	d0,a6
.skip
	add.w	#24*160,a6

	tst.w	d0
	blt		.actualSkip
.noSkip
		moveq	#0,d0
		moveq	#0,d6
		moveq	#0,d7
		jmp		.gogo
.actualSkip
		add.w	d0,a6
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d7
		sub.w	#10,d7
		move.w	d7,d6
		sub.w	#2,d6
.gogo

		lea		23*96*2(a0),a0
		add.w	#23*320,a6

		move.l	left12Pointer,a5
		jsr		(a5)


		IFEQ	DO_SOLID


	move.w	voxelScreenOff,d0
	move.l	screenpointer2,a6
	add.w	#12*8,d0
;	blt		.skippp
	add.w	d0,a6
	add.w	#(7+64)*160,a6
	move.w	#%1111111111110000,d0
.y set 0
	REPT 29
		move.w	d0,.y(a6)
.y set .y+320
	ENDR
;.skippp
		ENDC

;		move.b	#0,$ffffc123
;.y set 0
;	REPT 30
;		lea		(a0,d6),a0				;4
;		jmp		2(pc,d7)				;4
;.x set .y		
;		move.l	(a0)+,d0				;2
;		movep.l	d0,.x+1(a6)				;4		-> 14
;		REPT 11
;			move.l	(a0)+,d0			
;			or.l	(a0)+,d0
;			movep.l	d0,.x+8(a6)			
;
;			move.l	(a0)+,d0
;			or.l	(a0)+,d0
;			movep.l	d0,.x+9(a6)			; 16 * 11 = 176
;.x set .x+8
;		ENDR
;			move.l	(a0)+,d0
;			or.l	(a0)+,d0			
;			movep.l	d0,.x+8(a6)			;8
;
;			move.l	(a0)+,d0
;			movep.l	d0,.x+9(a6)			;6		--> 14			176+14+14 = 6122
;.y set .y+2*160
;	ENDR

; right

	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	move.w	d0,d5
	cmp.w	#-40,d0
	ble		.end
		add.l	off_left,a6
		add.w	#64,a6
		sub.w	#64,d0
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d6
		move.w	d0,d7
.gogo2


	lea		-20*160(a6),a1
	lsr.w	#1,d0
	add.w	d0,a1
	lsr.w	#1,d0
	move.w	#%111111111111,d2
	moveq	#-1,d1
	move.w	d2,d3
	not.w	d3
	move.l	drawSkyPointer,a5
	jsr		(a5)

;.y set 0
;	REPT 10
;.x set .y+12*8
;		jmp		2(pc,d0)
;.x set .x-8
;		REPT 12
;			move.w	d1,.x+6(a1)
;.x set .x-8
;		ENDR
;			move.w	d2,.x+6(a1)
;.x set .x-8
;.y set .y+320
;	ENDR



	; here we need to select the steplist
	lea		stepListRight12,a5		; steplist
	; offset into steplist 
	add.w	#32,d5
	add.l	4(a5,d5.w),a6
	move.l	(a5,d5.w),a5
	move.w	#21-1,d5
	jsr		(a5)

	lea		32*96*2(a0),a0
	add.w	#320+33*320,a6
	move.w	#31-1,d5
	jsr		(a5)

.end
	rts


makeStep12	macro
.y set 0
.loop\@
.x set .y		
		move.l	(a0)+,d0
		movep.l	d0,.x(a6)	

		move.l	(a0)+,d0
		or.l	(a0)+,d0
		movep.l	d0,.x+1(a6)
		REPT \1
			move.l	(a0)+,d0
			or.l	(a0)+,d0
			movep.l	d0,.x+8(a6)			;24		--> 32	4*32+76=	204/4 = 51				204*6*86 = 105264

			move.l	(a0)+,d0
			or.l	(a0)+,d0
			movep.l	d0,.x+9(a6)
.x set .x+8
		ENDR
		lea		320(a6),a6
		lea		-12(a0,d6),a0
		dbra	d5,.loop\@
	rts
	endm

; 1404

stepListRight12
	dc.l	0,88
	dc.l	0,80
	dc.l	0,72
	dc.l	0,64
	dc.l	0,56
	dc.l	0,48
	dc.l	0,40
	dc.l	0,32
	dc.l	0,24
	dc.l	0,16
	dc.l	0,8
	dc.l	0,0

;.step00
;	makeStep12 0
;.step01
;	makeStep12 1
;.step02
;	makeStep12 2
;.step03
;	makeStep12 3
;.step04
;	makeStep12 4
;.step05
;	makeStep12 5
;.step06
;	makeStep12 6
;.step07
;	makeStep12 7
;.step08
;	makeStep12 8
;.step09
;	makeStep12 9
;.step10
;	makeStep12 10
;.step11
;	makeStep12 11


right12Pointer	ds.l	1

genRight12Code
	lea		stepListRight12,a4
	move.l	right12Pointer,a6
	lea		.template,a5
	move.l	(a5)+,a0			; move.l	(a0)+,d0		;	movep.l	d0,.x(a6)
	add.w	#2,a5
	move.l	(a5)+,a1			; move.l	(a0)+,d0		;	or.l	(a0)+,d0
	move.l	(a5)+,d0
	move.l	(a5)+,d1			; lea	320(a6),a6
	move.l	(a5)+,d2			; lea	-12(a0,d6),a0
	move.l	(a5)+,d3			; dbra	
	move.w	#12-1,d7
.genStep
	move.l	a6,(a4)
	add.w	#8,a4
	; base code size
		move.w	#-24,d3
	; setup
		move.w	d7,d6
		sub.w	#11,d6
		neg.w	d6					
		sub.w	d0,d0			;.y = 0
	; now make code
		move.l	a0,(a6)+		; move.l;move.p					;4
		move.w	d0,(a6)+		; movep offset					;2	6
		move.l	a1,(a6)+		; move.l, or.l					;4	10
		addq.w	#1,d0
		move.l	d0,(a6)+		; movep.l + offf				;4	14
		subq.w	#1,d6
		blt		.skip
.loopx
			addq.w	#7,d0
			move.l	a1,(a6)+
			move.l	d0,(a6)+
			addq.w	#1,d0
			move.l	a1,(a6)+
			move.l	d0,(a6)+
			sub.w	#16,d3
		dbra	d6,.loopx
.skip	
		move.l	d1,(a6)+										;
		move.l	d2,(a6)+
		move.l	d3,(a6)+
	move.w	#$4e75,(a6)+
	dbra	d7,.genStep
	;
;	sub.l	right12Pointer,a6
;	move.b	#0,$ffffc123
	rts
.template
	move.l	(a0)+,d0
	movep.l	d0,0(a6)

	move.l	(a0)+,d0
	or.l	(a0)+,d0

	movep.l	d0,0(a6)

	lea		320(a6),a6
	lea		-12(a0,d6),a0
	dbra	d5,.template	



;.y set 0
;.loop\@
;.x set .y		
;		move.l	(a0)+,d0
;		movep.l	d0,.x(a6)	
;
;		move.l	(a0)+,d0
;		or.l	(a0)+,d0
;		movep.l	d0,.x+1(a6)
;		REPT \1
;			move.l	(a0)+,d0
;			or.l	(a0)+,d0
;			movep.l	d0,.x+8(a6)			;24		--> 32	4*32+76=	204/4 = 51				204*6*86 = 105264
;
;			move.l	(a0)+,d0
;			or.l	(a0)+,d0
;			movep.l	d0,.x+9(a6)
;.x set .x+8
;		ENDR
;		lea		320(a6),a6
;		lea		-12(a0,d6),a0
;		dbra	d5,.loop\@
;	rts


left12Pointer	ds.l	1

genLeft12Code
	move.l	left12Pointer,a6
	moveq	#0,d6					; .y
	lea		.left12Template,a5
	move.l	(a5)+,a0			;	lea		(a0,d6),a0
	move.l	(a5)+,a1			;	jmp		2(pc,d7)
	move.l	(a5)+,a2			;	move.l	(a0)+,d0		; movep.l	d0,dddd(a6)
	add.w	#2,a5
	move.l	(a5)+,a3			;	move.l	(a0)+,d0		; or.l	(a0)+,d0
	move.l	(a5)+,d4			;	movep.l	d0,xxxx(a6)

	move.w	#30-1,d7
.loop							; rept 30
		move.w	d6,d4			;.x set .y
		move.l	a0,(a6)+							;4
		move.l	a1,(a6)+							;4
		move.l	a2,(a6)+							;4
		addq.w	#1,d4
		move.w	d4,(a6)+							;2		--> 14
		move.w	#11-1,d0
.loopx	
			addq.w	#7,d4
			move.l	a3,(a6)+		
			move.l	d4,(a6)+
			addq.w	#1,d4
			move.l	a3,(a6)+
			move.l	d4,(a6)+						;16		--> 11*16 = 176 

		dbra	d0,.loopx

		addq.w	#7,d4
		move.l	a3,(a6)+
		move.l	d4,(a6)+
		addq.w	#1,d4
		move.l	a2,(a6)+
		move.w	d4,(a6)+							;14		

		add.w	#320,d6
	dbra	d7,.loop
	move.w	#$4e75,(a6)+							;  14 + 176 + 14 = 204	* 30 = 6120 +2 = 6122
	rts



.left12Template
.y set 0
;	REPT 30
		lea		(a0,d6),a0					;a0
		jmp		2(pc,d7)					;a1
.x set .y		
		move.l	(a0)+,d0					;a2
		movep.l	d0,.x+1(a6)	
;		REPT 11
			move.l	(a0)+,d0				;a3-1
			or.l	(a0)+,d0				;a3-2
			movep.l	d0,.x+8(a6)				;d4
;			move.l	(a0)+,d0
;			or.l	(a0)+,d0
;			movep.l	d0,.x+9(a6)
;.x set .x+8
;		ENDR
;			move.l	(a0)+,d0
;			or.l	(a0)+,d0
;			movep.l	d0,.x+8(a6)
;
;			move.l	(a0)+,d0
;			movep.l	d0,.x+9(a6)
;.y set .y+2*160
;	ENDR	


c2p_1to4_static
; left
	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	blt		.skip
		add.w	d0,a6		
.skip	


	move.l	a6,a5
	move.l	a6,a4
	add.l	off_left,a6
	add.l	off_mid,a5
	add.l	off_right,a4

	tst.w	d0
	blt		.actualSkip
.noSkip
		moveq	#0,d6
		moveq	#0,d7
		moveq	#0,d0
		jmp		.gogo
.actualSkip
		add.w	d0,a6
		add.w	d0,a5
		add.w	d0,a4
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d6
		move.w	d0,d7
.gogo

		;32,32,32
		;32-10 = 22, skip one, is 32
		lea		23*96*2(a0),a0
		add.w	#23*320,a6
		move.l	left0CodePointer,a5
		jsr		(a5)

		IFEQ	DO_SOLID
	move.w	voxelScreenOff,d0
	move.l	screenpointer2,a6
	add.w	#11*8,d0
	blt		.skippp
	add.w	d0,a6
	add.w	#(7+64)*160,a6
	moveq	#-1,d0
.y set 0
	REPT 29
		move.w	d0,.y(a6)
.y set .y+320
	ENDR
.skippp
		ENDC

;.y set 0
;	REPT 30
;		lea		(a0,d6),a0
;		jmp		2(pc,d7)
;
;.x set .y
;	rept 12
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+0(a6)		;24						;4
;	
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+1(a6)		;24						;4	12*16 = 192
;.x set .x+8
;	endr
;.y set .y+320
;	endr

; right part

	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	cmp.w	#-32,d0
	ble		.end
		add.l	off_left,a6
		add.w	#64,a6
		sub.w	#64,d0
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d6
		move.w	d0,d7
.gogo2

	lea		-20*160(a6),a1
	lsr.w	#1,d0
	add.w	d0,a1
	lsr.w	#1,d0
	move.w	#%0,d2
	moveq	#-1,d1
	move.w	d2,d3
	not.w	d3
	move.l	drawSkyPointer,a5
	jsr		(a5)





;.y set 0
;	REPT 10									;	10*12*4 = 480
;.x set .y
;		jmp		2(pc,d0)
;		REPT 12
;			move.w	d1,.x+6(a1)
;.x set .x+8
;		ENDR
;.y set .y+320
;
;	ENDR
; end top line draw
	move.w	#21-1,d5
	jsr		.stepCode


;.y set 0
;	REPT 21
;		jmp		2(pc,d7)
;
;.x set .y
;	rept 12
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+0(a6)		;24						;4
;	
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+1(a6)		;24						;4	12*16 = 192
;.x set .x+8
;	endr
;			lea		(a0,d6),a0
;.y set .y+320
;	endr

	lea		32*96*2(a0),a0
	add.w	#320+33*320,a6

	move.w	#31-1,d5
	jsr		.stepCode

;.y set 0
;	REPT 31
;		jmp		2(pc,d7)
;.x set .y
;	rept 12
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+0(a6)		;24						;4
;	
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+1(a6)		;24						;4	12*16 = 192
;.x set .x+8
;	endr
;		lea		(a0,d6),a0
;.y set .y+320
;	endr
.end
	rts
.stepCode
.y set 0
		jmp		2(pc,d7)
.x set .y
	rept 12
		move.l	(a0)+,d0		;12						;2
		or.l	(a0)+,d0		;16						;2
		movep.l	d0,.x+0(a6)		;24						;4
	
		move.l	(a0)+,d0		;12						;2
		or.l	(a0)+,d0		;16						;2
		movep.l	d0,.x+1(a6)		;24						;4	12*16 = 192
.x set .x+8
	endr
	lea		320(a6),a6
	lea		(a0,d6),a0
	dbra	d5,.stepCode
	rts

left0CodePointer	ds.l	1

genLeft0Code
	move.l	left0CodePointer,a6
	lea		.left0Template,a5
	move.l	(a5)+,a0
	move.l	(a5)+,a1
	move.l	(a5)+,a2
	move.l	(a5)+,d0
	moveq	#0,d2
	move.w	#320,d1

	move.w	#30-1,d7
.loop
		move.w	d2,d0
		move.l	a0,(a6)+
		move.l	a1,(a6)+
		move.w	#12-1,d6						;	8
.loopx
			move.l	a2,(a6)+
			move.l	d0,(a6)+
			addq.w	#1,d0

			move.l	a2,(a6)+
			move.l	d0,(a6)+					;16*12	=	192
			addq.w	#7,d0

		dbra	d6,.loopx
		add.w	d1,d2
	dbra	d7,.loop							; 200 * 30 + 2 = 6002
	move.w	#$4e75,(a6)+
	rts
.left0Template
.y set 0
;	REPT 30
		lea		(a0,d6),a0
		jmp		2(pc,d7)

.x set .y
;	rept 12
		move.l	(a0)+,d0		;12						;2
		or.l	(a0)+,d0		;16						;2
		movep.l	d0,.x+0(a6)		;24						;4
	
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+1(a6)		;24						;4	12*16 = 192
;.x set .x+8
;	endr
;.y set .y+320
;	endr



mylameoff	dc.w	0

c2p_1to4_static2
	IFNE	FLASH
	; here we do the srripes
	move.w	mylameoff,d2
	cmp.w	#47*4+4,d2
	beq		.okkk
	move.l	canvasPointerVoxel,a0
	add.w	#31*96*2,a0

;	neg.w	d2
;	add.w	#47*4,d2

	moveq	#0,d0

	lea		96*2(a0),a1
	lea		32*96*2+96*2(a0),a2	; starts from right
	lea		96*2(a2),a3			; starts from right

	add.w	d2,a0
	add.w	d2,a1
	sub.w	d2,a2
	sub.w	d2,a3

	and.l	d0,(a0)+
	and.l	d0,(a1)+
	and.l	d0,-(a2)
	and.l	d0,-(a3)

	add.w	d2,d2	;8
	jmp		2(pc,d2.w)
	REPT 47
		move.l	d0,(a0)+			; 12*2 and.l	48*47
		move.l	d0,(a1)+
		move.l	d0,-(a2)
		move.l	d0,-(a3)
	ENDR

	subq.w	#1,.stripesWaiter
	bge		.okkk
		add.w	#4,mylameoff
		cmp.w	#47*4+4,mylameoff
		ble		.okkk
			move.w	#47*4+4,mylameoff
.okkk
	ENDC
	; pattern: 
	; left to right:
	; skip, mark, zero

	; right to left
	; zero, mark, skip

	;192/4 = 48 steps

;	move.l	#%01110111011101110111011101110111,d0
;	REPT 48*2
;		and.l	d0,(a0)+
;	ENDR



;	lea		32*96*2(a0),a1
;	REPT 96
;		and.l	d0,(a1)+
;	ENDR


	move.l	canvasPointerVoxel,a0
	add.w	#10*96*2,a0
	move.l	screenpointer2,a6
	move.w	voxelScreenOff,d0
	; voxelscreenoff should be the one that drives the stuff that comes from the right
	blt		.skip
		add.w	d0,a6
.skip
	move.l	a6,a5
	move.l	a6,a4
	add.l	off_left,a6
	add.l	off_mid,a5
	add.l	off_right,a4

	jsr		adjustOffsets
	cmp.w	#$4e75,c2p_1to4_static2
	beq		.end

	; here we need to adjust our offsets and stuff
	; - number of things to jump over
	; - offset to disposition from
	; 12 * 8 * 2 offset
	tst.w	d0
	blt		.actualSkip
.noSkip
		moveq	#0,d6
		moveq	#0,d7
		moveq	#0,d0
		jmp		.gogo
.actualSkip
		add.w	d0,a6
		add.w	d0,a5
		add.w	d0,a4
		neg.w	d0
		add.w	d0,d0
		move.w	d0,d6
		move.w	d0,d7
.gogo
	lsr.w	#2,d0
	moveq	#-1,d1
	lea		-20*160(a6),a1
	lea		-20*160(a5),a2
	lea		-20*160(a4),a3
.y set 0
	REPT 10									;	10*12*4 = 480
.x set .y
		jmp		2(pc,d0)
		REPT 4
			move.w	d1,.x+6(a1)
.x set .x+8
		ENDR
		REPT 4
			move.w	d1,.x+6(a2)
.x set .x+8
		ENDR
		REPT 4
			move.w	d1,.x+6(a3)
.x set .x+8
		ENDR
.y set .y+320

	ENDR
	move.l	verticalStaticPointer,a2
	jsr		(a2)


.end

	rts
.stripesWaiter	dc.w	18
;.y set 0
;	REPT 96-10
;		lea		(a0,d6),a0
;		jmp		2(pc,d7)
;
;.x set .y
;	rept 4
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+0(a6)		;24						;4
;	
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+1(a6)		;24						;4	12*16 = 192
;.x set .x+8
;	endr
;
;	rept 4
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+0(a5)		;24						;4
;	
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+1(a5)		;24						;4	12*16 = 192
;.x set .x+8
;	endr
;
;	rept 4
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+0(a4)		;24						;4
;	
;		move.l	(a0)+,d0		;12						;2
;		or.l	(a0)+,d0		;16						;2
;		movep.l	d0,.x+1(a4)		;24						;4	12*16 = 192
;.x set .x+8
;	endr
;.y set .y+320
;	endr
;c2psmcLabel
;	rts

verticalStaticPointer	ds.l	1

genVerticalStaticCode
	move.l	verticalStaticPointer,a6
	lea		.template,a5
	move.l	(a5)+,a0
	move.l	(a5)+,a1
	move.l	(a5)+,a2
	move.l	(a5)+,d0		
	move.l	(a5)+,d1		
	move.l	(a5)+,d2		
	moveq	#0,d4		;.y =0
	move.w	#320,d5
	IFEQ	USE_MYM_DUMP
		move.w	#96-10-1,d7
	ELSE
		move.w	#86-10-1,d7
	ENDC

.ol	
		move.w	d4,d0
		move.l	a0,(a6)+		; lea
		move.l	a1,(a6)+		; jmp
		move.w	#4-1,d6
.il1
			move.l	a2,(a6)+
			move.l	d0,(a6)+
			addq.w	#1,d0
			move.l	a2,(a6)+
			move.l	d0,(a6)+
			addq.w	#7,d0
		dbra	d6,.il1


		move.w	d0,d1
		move.w	#4-1,d6
.il2
			move.l	a2,(a6)+
			move.l	d1,(a6)+
			addq.w	#1,d1
			move.l	a2,(a6)+
			move.l	d1,(a6)+
			addq.w	#7,d1
		dbra	d6,.il2


		move.w	d1,d2
		move.w	#4-1,d6
.il3
			move.l	a2,(a6)+
			move.l	d2,(a6)+
			addq.w	#1,d2
			move.l	a2,(a6)+
			move.l	d2,(a6)+
			addq.w	#7,d2
		dbra	d6,.il3
		add.w	d5,d4
	dbra	d7,.ol
	move.l	a6,c2psmcLabelPointer
	move.w	#$4e75,(a6)+
;	sub.l	verticalStaticPointer,a6
;	move.b	#0,$ffffc123
	rts
.template
	lea		(a0,d6),a0		;a0
	jmp		2(pc,d7)		;a1
	move.l	(a0)+,d0		;a2.a
	or.l	(a0)+,d0		;a2.b
	movep.l	d0,0(a6)		;d0						
	movep.l	d0,0(a5)		;d1						
	movep.l	d0,0(a4)		;d2						
	


doVoxel2
		lea		_sintable512,a5			;	sin
		lea		_sintable512+256,a6		;	cos
		move.w	phi,d7				;	angle phi
		add.w	d7,d7	
		move.w	(a5,d7.w),sinPhi
		move.w	(a6,d7.w),cosPhi	

	move.w	#(192/2-1),d0
	add.w	d0,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,d1
	swap	d1
	move.w	d0,d1

.fixYbuffer
	move.l	d1,d0
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7					;7*4.= 28
	lea		ybuffer+96*2,a0

	REPT 7
	movem.l	d0-d7,-(a0)				;72*7 = 504
	ENDR

	moveq	#1,d0					;dz
	move.l	pz,d1					;z
;	swap	d1
;	move.l	d1,a2
;	add.l	#40<<16,a2				;40 depth
;	swap	d1
	move.l	canvasPointerVoxel,a3		
	add.w	#500,a3
	move.l	a3,usp
	move.l	heightMapPointer,d6
	move.l	canvasOffsetListPointer,d3
	move.l	cshift2Pointer,d4
	
.doDistanceStep
	swap	d1
	cmp.l	#50<<16,d1
	bge		endIt
doIter2
		swap	d1
		; rotation of points and angles
;		lea		sinTable,a5			;	sin
;		lea		sinTable+256,a6		;	cos
;		move.w	phi,d7				;	angle phi
;		add.w	d7,d7				
		move.w	d1,d2				;	z
;		muls.w	(a5,d7.w),d2		;	sin phi * z
		muls	sinPhi,d2
		add.l	d2,d2				;	nomalize
		move.l	d2,a3				;	a3 = sinPhi
		move.w	d1,d2
;		muls	(a6,d7.w),d2		;	cos phi * z
		muls	cosPhi,d2
		add.l	d2,d2
		move.l	d2,a4				;	a4 = cosPhi
		;pleft.x
		move.l	a4,d2				;	cosPhi
		neg.l	d2					;	-cosPhi
		sub.l	a3,d2				;	-cosPhi - sinPhi
		moveq	#0,d7				;
		move.w	px,d7				;	__.ii	
		swap	d7					;	ii.ff
		add.l	d7,d2				;	-cosPhi - sinPhi + p.x
		add.l	d2,d2				;	shift 1
		swap	d2					;	ff.ii
		move.w	d2,a1				;	a1 = pleft
		;pright.x
		pushd0
		move.l	a4,d0				;	cosPhi
		sub.l	a3,d0				;	cosPhi - sinPhi
		add.l	d7,d0				;	cosPhi - sinPhi + p.x
		swap	d0					;	d4 = pright
		;pleft.y
		move.l	a3,d5				;	sinPhi
		sub.l	a4,d5				;	sinPhi - cosPhi
		moveq	#0,d7				;
		move.w	py,d7				;	__.ii	py
		swap	d7					;	ii.ff
		add.l	d7,d5				;	sinPhi - cosPhi + p.y
		;pright.y
		move.l	a3,d2				;	sinPhi
		neg.l	d2					;	-sinPhi
		sub.l	a4,d2				;	-sinPhi - cosPhi
		add.l	d7,d2				;	-sinPhi - cosPhi + p.y
		swap	d2
		;pleft.y shift
		move.l	d5,d7
		asl.l	#8,d7
		swap	d5
		swap	d7
		;segment the line
		lea		divTable,a6	
		add.w	d0,d0
		sub.w	a1,d0
		add.w	d0,d0
		and.w	#-4,d0
		move.l	(a6,d0.w),d0		;	dx = (pright.x - pleft.x) / screen_width
		swap	d0
		move.l	d0,a3
		sub.w	d5,d2
		add.w	d2,d2
		add.w	d2,d2
		move.l	(a6,d2.w),d0		;	dy = (pright.y - pleft.y) / screen_width
.prepDoLeftRight
		lea		ybuffer,a5
		pushd1
;		pusha2
		asl.l	#8,d0			;ii.ff << 7
		swap	d0				;f_.if
		move.l	d0,a2

;		moveq	#0,d0
		move.w	d7,d0

		moveq	#0,d2
		move.w	a1,d2

		move.l	vdivtablePointer,a0
		sub.w	#10,d1
		asl.w	#6,d1
		add.w	d1,a0

;		move.l	a3,d1
;		swap	d1
;		move.l	d1,a3

		move.l	cshift1Pointer,d1

	moveq	#0,d5
	moveq	#-2,d7

.doLeftRightExec

tmpptr2		jsr		123456.l

;.xoff set 0
;		REPT 96/4
;		doLeftRight .xoff,d4
;.xoff set .xoff+4
;		doLeftRight .xoff,d1
;.xoff set .xoff+4
;		ENDR

.endStuff
;	popa2
	popd1
	popd0
	moveq	#0,d5
	add.l	d0,d1				; z += dz
	add.l	#INCVAL,d0		; dz += 0.25		8=0.5, 4=0.25 2=0,12
	addx.l	d5,d0

	swap	d1
	cmp.l	#50<<16,d1
	blt		doIter2
endIt
	rts

	IFEQ	DITHER
prepColormap
	lea		16384-128(a0),a0
	lea		16384(a1),a2
	lea		16384(a2),a3
	move.w	#128-1,d7
.ol	
		move.w	#128-1,d6
.il
			move.b	(a0)+,d0
			add.b	d0,d0
			add.b	d0,d0
			move.b	d0,(a1)+
			move.b	d0,(a3)+
			addq.w	#1,a1
			addq.w	#1,a3
		dbra	d6,.il
		sub.w	#256,a0
;		add.w	#22,a0

	dbra	d7,.ol
	rts

	ENDC


routListTab
.l set 10
.inc set 1
	REPT 18
	dc.w	.l*4		;0
.l set .l+.inc
	ENDR
flipVoxel dc.w	1

removePanelLamelsVoxel
	nop
	move.l	screenpointer2,a0
;	add.w	#4*160,a0
	move.l	a0,a6
	; 192 per 8 => 24 steps
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	lea		.routList,a3
	lea		routListTab,a4
	tst.w	flipVoxel
	blt		.back

xx2 macro
		move.w	(a4)+,a2
		move.l	(a3,a2),a5
		move.l	a6,a0
		jsr		(a5)
		add.w	#160*14,a6
	endm
	REPT 14
			xx2
	ENDR
	neg.w	flipVoxel
	rts

.back

xx macro
		subq.w	#4,(a4)
;		bge		.ok\@
;			move.w	#0,(a4)
;.ok\@
		move.w	(a4)+,a2
		move.l	(a3,a2),a5
		move.l	a6,a0
		jsr		(a5)
		add.w	#160*14,a6
	endm
	REPT 14
			xx
	ENDR
	neg.w	flipVoxel
	rts





	dc.l	.noClear2	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
.routList
	dc.l	.noClear	;0
	dc.l	.clear4
	dc.l	.clear3
	dc.l	.clear2
	dc.l	.clear1
	REPT 19
		dc.l	.noClear
	ENDR
;		dc.l	noClear2

.noClear2
	move.w	#$4e75,removePanelLamelsVoxel
.noClear
	rts


.clear1
	movem.l	d0-d7,6*160(a0)
	movem.l	d0-d7,6*160+32(a0)
	movem.l	d0-d7,7*160(a0)
	movem.l	d0-d7,7*160+32(a0)
	rts
.clear2
	movem.l	d0-d7,4*160(a0)
	movem.l	d0-d7,4*160+32(a0)
	movem.l	d0-d7,5*160(a0)
	movem.l	d0-d7,5*160+32(a0)

	movem.l	d0-d7,8*160(a0)
	movem.l	d0-d7,8*160+32(a0)
	movem.l	d0-d7,9*160(a0)
	movem.l	d0-d7,9*160+32(a0)
	rts

.clear3
	movem.l	d0-d7,2*160(a0)
	movem.l	d0-d7,2*160+32(a0)
	movem.l	d0-d7,3*160(a0)
	movem.l	d0-d7,3*160+32(a0)

	movem.l	d0-d7,10*160(a0)
	movem.l	d0-d7,10*160+32(a0)
	movem.l	d0-d7,11*160(a0)
	movem.l	d0-d7,11*160+32(a0)
	rts

.clear4
	movem.l	d0-d7,0*160(a0)
	movem.l	d0-d7,0*160+32(a0)
	movem.l	d0-d7,1*160(a0)
	movem.l	d0-d7,1*160+32(a0)

	movem.l	d0-d7,12*160(a0)
	movem.l	d0-d7,12*160+32(a0)
	movem.l	d0-d7,13*160(a0)
	movem.l	d0-d7,13*160+32(a0)
	rts


	section DATA
	IFEQ	FLASH
flashPal	; this is not used
	dc.w	$111,$111,$323,$334,$444,$454,$565,$676,$777,$770,$750,$731,$722,$701,$401,$777		;0
	dc.w	$222,$222,$434,$445,$555,$565,$676,$777,$777,$771,$751,$742,$733,$712,$512,$777		;1
	dc.w	$333,$333,$545,$556,$666,$676,$777,$777,$777,$772,$762,$753,$744,$723,$623,$777		;2
	dc.w	$444,$444,$656,$667,$777,$777,$777,$777,$777,$773,$773,$764,$755,$734,$734,$777		;3
	dc.w	$555,$555,$767,$777,$777,$777,$777,$777,$777,$774,$774,$775,$766,$745,$745,$777		;4
	dc.w	$666,$666,$777,$777,$777,$777,$777,$777,$777,$775,$775,$776,$777,$756,$756,$777		;5
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$776,$776,$777,$777,$767,$777,$777		;6
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777		;7
	ENDC

;--------------
;DEMOPAL - main palette for the voxel part + offsets for highlight
;--------------		
introPal
	dc.w	$000,$111,$000,$112,$212,$123,$323,$233,$432,$632,$344,$445,$742,$555,$752,$774	;$771		;0		
	dc.w	$000,$222,$111,$223,$323,$234,$434,$344,$543,$743,$455,$556,$753,$666,$763,$775	;$772		;1
	dc.w	$000,$333,$222,$334,$434,$345,$545,$455,$654,$754,$566,$667,$764,$777,$764,$776	;$773		;2
	dc.w	$000,$444,$333,$445,$545,$456,$656,$566,$765,$765,$677,$777,$775,$777,$775,$777	;$774		;3
	dc.w	$000,$555,$444,$556,$656,$567,$767,$677,$776,$776,$777,$777,$776,$777,$776,$777	;$775		;4
	dc.w	$000,$666,$555,$667,$767,$677,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777	;$776		;5
	dc.w	$000,$777,$666,$777,$777,$777,$777,$777,$777,$776,$777,$777,$777,$777,$777,$777	;$777		;6
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777	;$777		;7
introPalOff	dc.w	7*32







	IFEQ	DITHER


cshift1
	dc.l	$00000000	;0		
;	dc.l	$a0000000	;1		;%1010
	dc.l	$f0000000	;1		;%1111
	dc.l	$f0000000	;1		;%1111
;	dc.l	$00a00000	;2
	dc.l	$00f00000	;2
	dc.l	$00f00000	;2
;	dc.l	$a0a00000	;3
	dc.l	$f0f00000	;3
	dc.l	$f0f00000	;3
;	dc.l	$0000a000	;4
	dc.l	$0000f000	;4
	dc.l	$0000f000	;4
;	dc.l	$a000a000	;5
	dc.l	$f000f000	;5
	dc.l	$f000f000	;5
;	dc.l	$00a0a000	;6
	dc.l	$00f0f000	;6
	dc.l	$00f0f000	;6
;	dc.l	$a0a0a000	;7
	dc.l	$f0f0f000	;7
	dc.l	$f0f0f000	;7
;	dc.l	$000000a0	;8
	dc.l	$000000f0	;8
	dc.l	$000000f0	;8
;	dc.l	$a00000a0	;9
	dc.l	$f00000f0	;9
	dc.l	$f00000f0	;9
;	dc.l	$00a000a0	;10
	dc.l	$00f000f0	;10
	dc.l	$00f000f0	;10
;	dc.l	$a0a000a0	;11
	dc.l	$f0f000f0	;11
	dc.l	$f0f000f0	;11
;	dc.l	$0000a0a0	;12
	dc.l	$0000f0f0	;12
	dc.l	$0000f0f0	;12
;	dc.l	$a000a0a0	;13
	dc.l	$f000f0f0	;13
	dc.l	$f000f0f0	;13
;	dc.l	$00a0a0a0	;14
	dc.l	$00f0f0f0	;14
	dc.l	$00f0f0f0	;14
;	dc.l	$a0a0a0a0	;15
	dc.l	$f0f0f0f0	;15
	dc.l	$f0f0f0f0	;15
	dc.l	$f0f0f0f0	;15


cshift2
	dc.l	$00000000	;0
;	dc.l	$0a000000	;1
	dc.l	$0f000000	;1
	dc.l	$0f000000	;1
;	dc.l	$000a0000	;2
	dc.l	$000f0000	;2
	dc.l	$000f0000	;2
;	dc.l	$0a0a0000	;3
	dc.l	$0f0f0000	;3
	dc.l	$0f0f0000	;3
;	dc.l	$00000a00	;4
	dc.l	$00000f00	;4
	dc.l	$00000f00	;4
;	dc.l	$0a000a00	;5
	dc.l	$0f000f00	;5
	dc.l	$0f000f00	;5
;	dc.l	$000a0a00	;6
	dc.l	$000f0f00	;6
	dc.l	$000f0f00	;6
;	dc.l	$0a0a0a00	;7
	dc.l	$0f0f0f00	;7
	dc.l	$0f0f0f00	;7
;	dc.l	$0000000a	;8
	dc.l	$0000000f	;8
	dc.l	$0000000f	;8
;	dc.l	$0a00000a	;9
	dc.l	$0f00000f	;9
	dc.l	$0f00000f	;9
;	dc.l	$000a000a	;10
	dc.l	$000f000f	;10
	dc.l	$000f000f	;10
;	dc.l	$0a0a000a	;11
	dc.l	$0f0f000f	;11
	dc.l	$0f0f000f	;11
;	dc.l	$00000a0a	;12
	dc.l	$00000f0f	;12
	dc.l	$00000f0f	;12
;	dc.l	$0a000a0a	;13
	dc.l	$0f000f0f	;13
	dc.l	$0f000f0f	;13
;	dc.l	$000a0a0a	;14
	dc.l	$000f0f0f	;14
	dc.l	$000f0f0f	;14
;	dc.l	$0a0a0a0a	;15
	dc.l	$0f0f0f0f	;15
	dc.l	$0f0f0f0f	;15
	dc.l	$0f0f0f0f	;15

cshift1d
	dc.l	$00000000	;0		
	dc.l	$a0000000	;1		;%1010		5
	dc.l	$f0000000	;1		;%1111
	dc.l	$50a00000	;2
	dc.l	$00f00000	;2
	dc.l	$f0a00000	;3
	dc.l	$f0f00000	;3
	dc.l	$5000a000	;4
	dc.l	$0000f000	;4
	dc.l	$f000a000	;5
	dc.l	$f000f000	;5
	dc.l	$50a0a000	;6
	dc.l	$00f0f000	;6
	dc.l	$f0a0a000	;7
	dc.l	$f0f0f000	;7
	dc.l	$500000a0	;8
	dc.l	$000000f0	;8
	dc.l	$f00000a0	;9
	dc.l	$f00000f0	;9
	dc.l	$50a000a0	;10
	dc.l	$00f000f0	;10
	dc.l	$f0a000a0	;11
	dc.l	$f0f000f0	;11
	dc.l	$5000a0a0	;12
	dc.l	$0000f0f0	;12
	dc.l	$f000a0a0	;13
	dc.l	$f000f0f0	;13
	dc.l	$50a0a0a0	;14
	dc.l	$00f0f0f0	;14
	dc.l	$f0a0a0a0	;15
	dc.l	$f0f0f0f0	;15
	dc.l	$f0f0f0f0	;15


cshift2d
	dc.l	$00000000	;0
	dc.l	$0f000000	;1
	dc.l	$0f000000	;1
	dc.l	$050a0000	;2
	dc.l	$000f0000	;2
	dc.l	$0f0a0000	;3
	dc.l	$0f0f0000	;3
	dc.l	$05000a00	;4
	dc.l	$00000f00	;4
	dc.l	$0f000a00	;5
	dc.l	$0f000f00	;5
	dc.l	$050a0a00	;6
	dc.l	$000f0f00	;6
	dc.l	$0f0a0a00	;7
	dc.l	$0f0f0f00	;7
	dc.l	$0500000a	;8
	dc.l	$0000000f	;8
	dc.l	$0f00000a	;9
	dc.l	$0f00000f	;9
	dc.l	$050a000a	;10
	dc.l	$000f000f	;10
	dc.l	$0f0a000a	;11
	dc.l	$0f0f000f	;11
	dc.l	$05000a0a	;12
	dc.l	$00000f0f	;12
	dc.l	$0f000a0a	;13
	dc.l	$0f000f0f	;13
	dc.l	$050a0a0a	;14
	dc.l	$000f0f0f	;14
	dc.l	$0f0a0a0a	;15
	dc.l	$0f0f0f0f	;15
	dc.l	$0f0f0f0f	;15


	ELSE

cshift1
	dc.l	$00000000	;0		
	dc.l	$f0000000	;1		;%1111
	dc.l	$00f00000	;2
	dc.l	$f0f00000	;3
	dc.l	$0000f000	;4
	dc.l	$f000f000	;5
	dc.l	$00f0f000	;6
	dc.l	$f0f0f000	;7
	dc.l	$000000f0	;8
	dc.l	$f00000f0	;9
	dc.l	$00f000f0	;10
	dc.l	$f0f000f0	;11
	dc.l	$0000f0f0	;12
	dc.l	$f000f0f0	;13
	dc.l	$00f0f0f0	;14
	dc.l	$f0f0f0f0	;15

cshift2
	dc.l	$00000000	;0
	dc.l	$0f000000	;1
	dc.l	$000f0000	;2
	dc.l	$0f0f0000	;3
	dc.l	$00000f00	;4
	dc.l	$0f000f00	;5
	dc.l	$000f0f00	;6
	dc.l	$0f0f0f00	;7
	dc.l	$0000000f	;8
	dc.l	$0f00000f	;9
	dc.l	$000f000f	;10
	dc.l	$0f0f000f	;11
	dc.l	$00000f0f	;12
	dc.l	$0f000f0f	;13
	dc.l	$000f0f0f	;14
	dc.l	$0f0f0f0f	;15
	
cshift1d
	dc.l	$00000000	;0		
	dc.l	$a0000000	;1		;%1010		5
	dc.l	$f0000000	;1		;%1111
	dc.l	$50a00000	;2
	dc.l	$00f00000	;2
	dc.l	$f0a00000	;3
	dc.l	$f0f00000	;3
	dc.l	$5000a000	;4
	dc.l	$0000f000	;4
	dc.l	$f000a000	;5
	dc.l	$f000f000	;5
	dc.l	$50a0a000	;6
	dc.l	$00f0f000	;6
	dc.l	$f0a0a000	;7
	dc.l	$f0f0f000	;7
	dc.l	$500000a0	;8
	dc.l	$000000f0	;8
	dc.l	$f00000a0	;9
	dc.l	$f00000f0	;9
	dc.l	$50a000a0	;10
	dc.l	$00f000f0	;10
	dc.l	$f0a000a0	;11
	dc.l	$f0f000f0	;11
	dc.l	$5000a0a0	;12
	dc.l	$0000f0f0	;12
	dc.l	$f000a0a0	;13
	dc.l	$f000f0f0	;13
	dc.l	$50a0a0a0	;14
	dc.l	$00f0f0f0	;14
	dc.l	$f0a0a0a0	;15
	dc.l	$f0f0f0f0	;15
	dc.l	$f0f0f0f0	;15


cshift2d
	dc.l	$00000000	;0
	dc.l	$0f000000	;1
	dc.l	$0f000000	;1
	dc.l	$050a0000	;2
	dc.l	$000f0000	;2
	dc.l	$0f0a0000	;3
	dc.l	$0f0f0000	;3
	dc.l	$05000a00	;4
	dc.l	$00000f00	;4
	dc.l	$0f000a00	;5
	dc.l	$0f000f00	;5
	dc.l	$050a0a00	;6
	dc.l	$000f0f00	;6
	dc.l	$0f0a0a00	;7
	dc.l	$0f0f0f00	;7
	dc.l	$0500000a	;8
	dc.l	$0000000f	;8
	dc.l	$0f00000a	;9
	dc.l	$0f00000f	;9
	dc.l	$050a000a	;10
	dc.l	$000f000f	;10
	dc.l	$0f0a000a	;11
	dc.l	$0f0f000f	;11
	dc.l	$05000a0a	;12
	dc.l	$00000f0f	;12
	dc.l	$0f000a0a	;13
	dc.l	$0f000f0f	;13
	dc.l	$050a0a0a	;14
	dc.l	$000f0f0f	;14
	dc.l	$0f0a0a0a	;15
	dc.l	$0f0f0f0f	;15
	dc.l	$0f0f0f0f	;15
	ENDC

canvasPointerVoxel				ds.l	1
heightMapPointer			ds.l	1
cshift1Pointer				ds.l	1
cshift2Pointer				ds.l	1
vdivtablePointer			ds.l	1
canvasOffsetListPointer		ds.l	1


; here we cheat the fuck out of 800 bytes :o
									;	ds.b	100*4
divTable	equ $2000				;	ds.b	100*4


    IFEQ    STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
		include		lib/mymdump.s
		include		musicplayer.s
    ENDC

panel1Pointer			dc.l	0
panel1crk				incbin	"data/c2pvoxel/panel5.crk"			;12800		/	4884
	even

hmPointer				dc.l	0
	IFEQ	VOXEL_USEFILES
heightmap				
				incbin	"gfx/c2p/hm_proper3.neo"
;				incbin	"data/c2pvoxel/heightmap2.neo"
	ELSE
;heightmapcrk			incbin	"data/c2pvoxel/hm1.crk"				;32128		/	6753
;heightmapcrk			incbin	"gfx/c2p/hm_proper3.crk"				;32128		/	6753
	even
	ENDC
;heightmap				incbin	"data/c2pvoxel/hm1.neo"				; 128*128 = 8*8*128 = 8192

	IFEQ	DITHER
colormapditherPointer	dc.l	0

	IFEQ	VOXEL_USEFILES
;colormapdither			incbin	"data/c2pvoxel/hmc1.bmp"
colormapdither			incbin	"gfx/c2p/cm_proper1.bmp"
	ELSE
;colormapdithercrk		incbin	"data/c2pvoxel/hmc1.crk"			;17462		/	7454
colormapdithercrk		incbin	"gfx/c2p/cm_proper1.crk"			;17462		/	7454
	even
	ENDC



;colormapdither			incbin	"data/c2pvoxel/hm1c.bmp"			;16384

	ELSE
colormap				incbin	"data/c2pvoxel/p1.neo"
	ENDC


	IFEQ	STANDALONE
_sintable512		include	"data/sintable_amp32768_steps512.s"
	ENDC

	IFEQ	STANDALONE
		IFEQ	PREPBUFFER
panelBuffer	ds.b	200*8*8		;12800
panel1					incbin	"data/c2pvoxel/panel3.neo"


prepPanel
	lea		panel1+128,a0
	lea		panelBuffer,a1
.y set 0
	REPT 200
.x set .y
		REPT 8
			move.l .x(a0),(a1)+
			move.l .x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	lea		panelBuffer,a0
	move.b	#0,$ffffc123
	rts
		ENDC
	ENDC



    IFEQ    STANDALONE
	section BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
musicBufferPointer	ds.l	1
musicInit			ds.w	1
mymFrames			ds.w	1
musicPlayer			ds.w	1
snd					ds.l	1
cummulativeCount	ds.w	1
    ENDC
;canvas				ds.w	96*96*2			;18432

;def Render(p, phi, height, horizon, scale_height, distance, screen_width, screen_height):
;    # precalculate viewing angle parameters
;    var sinphi = math.sin(phi);
;    var cosphi = math.cos(phi);
;    
;    # initialize visibility array. Y position for each column on screen 
;    ybuffer = np.zeros(screen_width)
;    for i in range(0, screen_width):
;        ybuffer[i] = screen_height
;
;    # Draw from front to the back (low z coordinate to high z coordinate)
;    dz = 1.
;    z = 1.
;
;    for i in range(0, screen_width):
;    	while z < distance
;        	# Find line on map. This calculation corresponds to a field of view of 90°
;        	pleft = Point(																			once
;           	 (-cosphi*z - sinphi*z) + p.x,														once
;           	 ( sinphi*z - cosphi*z) + p.y)														once
;        	pright = Point(																			once
;           	 ( cosphi*z - sinphi*z) + p.x,														once
;           	 (-sinphi*z - cosphi*z) + p.y)														once
;
;       	 # segment the line
;       	 dx = (pright.x - pleft.x) / screen_width												once
;       	 dy = (pright.y - pleft.y) / screen_width												once
;
;        # Raster line and draw a vertical line for each segment
;            height_on_screen = (height - heightmap[pleft.x, pleft.y]) / z * scale_height. + horizon
;            DrawVerticalLine(i, height_on_screen, ybuffer[i], colormap[pleft.x, pleft.y])
;            if height_on_screen < ybuffer[i]:
;                ybuffer[i] = height_on_screen
;            pleft.x += dx
;            pleft.y += dy
;
;        # Go to next line and increase step size when you are far away
;        z += dz
;        dz += 0.2
;



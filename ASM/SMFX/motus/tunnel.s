VIEWPORT_W_PX		equ 160
VIEWPORT_H_PX		equ 100
TEXTURE_WIDTH		equ 64		
TEXTURE_HEIGHT		equ 64	
VIEWPORT_HEIGHT 	equ 100
VIEWPORT_WIDTH 		equ 20

GENERATE_FROM_TGA	equ 1

MOVETUNNEL			equ 0


TUNNEL_BARS_TUNER	equ 50

TUNNEL_PLANE_OFFSET		equ 0

PIC_WIDTH	equ 4
PIC_HEIGHT	equ 64*2

OFFSMAPWIDTH 	equ 480

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
TUNNEL_EFFECT_FRAMES_MOVE_WAIT	equ 40
TUNNEL_POETRY_START_SPEED		equ $24000
TUNNEL_POETRY_BREAK_SPEED 		equ $990
	ENDC

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA

	include macro.s

	IFEQ	STANDALONE
			initAndRun	init_effect

init_effect
	jsr		init_demo
;	jsr		prepPoetry
	move.w	#32000,effect_vbl_counter
	jsr		init_tunnel



.demostart


	
.x
		move.l	screenpointer2,$ffff8200
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts



init_demo
	move.w	#$000,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts
	ENDC


init_tunnel_pointers
	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2
	move.l	screen2,d0
	add.l	#$10000,d0																			;1
	move.l	d0,screenpointer3
	add.l	#$10000,d0																			;2
	move.l	d0,d1
	add.l	#$8000,d1											
	move.l	d1,offsmapPointer
	move.l	d0,planartexture1pointer														
	move.l	d0,offsmapPointer
	add.l	#98304,d0								;98304										;65536
	move.l	d0,planartexture2pointer
	add.l	#98304,d0								;98304					196608
	move.l	d0,planartexture3pointer
	add.l	#98304,d0								;98304					294912
	move.l	d0,planartexture4pointer
	add.l	#98304,d0								;9304					393216
	move.l	d0,c2pCopyPointerPointer
	add.l	#4802,d0								;4802					478020
	move.l	d0,texture_tunnelPointer
	add.l	#8192,d0								;8192					486212
	move.l	d0,tunnelCodePointer
	add.l	#240000+2,d0							;						726236				;12 offset
	move.l	d0,poetryBufferPointer
	move.w	#$4e75,init_tunnel_pointers
	rts

precalc_tunnel1
	lea		offsmapcrk,a0
	move.l	offsmapPointer,a1
	jsr		cranker

	jsr		genc2pCode							; this generates the unrolled c2p stuff
	jsr		generateC2PCopy						; generate the copy stuff

	IFEQ	STANDALONE
	lea		planar,a0
	move.l	texture_tunnelPointer,a1
	jsr		convertPlanar2Chunky				; this converts the planar to chunky format
	ELSE
	lea		tunneltext,a0
	move.l	texture_tunnelPointer,a1
	jsr		cranker
	ENDC

	lea		poetrycrk,a0
	move.l	poetryBufferPointer,a1
	jsr		cranker

;	jsr		convertPlanar2Chunky				; this converts the planar to chunky format

	move.w	#$4e75,precalc_tunnel1
	rts


precalc_tunnel2
	IFEQ	GENERATE_FROM_TGA
		jsr		convertOffsmapToTGA
		jsr		generateOffsetFromTGA
	ENDC
	jsr		prepareChunkyTextureBPL1to2			; this prepares the c2p tables




	; precalc fades
	IFNE	STANDALONE
		lea		fadeOutTunnelPal-32,a0
		lea		barFade,a2
		lea		allYellow,a3
		jsr		calcFadeT

		lea		fadeOutTunnelPal-32,a0
		lea		barFade2,a2
		lea		allBlue,a3
		jsr		calcFadeT

		lea		fadeOutTunnelPal-32,a0
		lea		barFade3,a2
		lea		allRed,a3
		jsr		calcFadeT

		lea		fadeOutTunnelPal-32,a0
		lea		barFade4,a2
		lea		allGreen,a3
		jsr		calcFadeT

		lea		fadeOutTunnelPal-32,a0
		lea		barFade5,a2
		lea		allGrey,a3
		jsr		calcFadeT
	ENDC


	move.w	#$4e75,precalc_tunnel2
	rts

calcFadeT
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a2)
	move.l	a2,a0
	lea		32(a2),a2
	move.w	#8-1,d7

.loop
		move.l	a3,a1
		move.w	#16,d0			; 16 colors
		IFNE	STANDALONE
		jsr		fadePalzz
		ENDC
		lea		32(a0),a0
		lea		32(a2),a2
	dbra	d7,.loop
	rts


			
allYellow	
	REPT 16
;		dc.w	$770 ; yellow->green
;		dc.w	$222 ; greyscale 2
;		dc.w 	$562 ; green->purple
		dc.w 	$352 ; green->white->yellow/red
;		dc.w	$333 ; greyscale
;		dc.w	$772 ; yellow->purple
; 		dc.w	$776 ; yellow->purple 2
;		dc.w	$773 ; pastel hell
			ENDR
allBlue
	REPT 16
;		dc.w	$561
;		dc.w	$666
;		dc.w	$451
		dc.w    $573
;		dc.w 	$555
;		dc.w 	$651
;		dc.w	$774
;		dc.w	$763
	ENDR
allRed	
	REPT 16
;		dc.w	$350
;		dc.w	$555
;		dc.w	$330
		dc.w	$777
; 		dc.w 	$777
;		dc.w	$531
;		dc.w	$675
;		dc.w	$643
	ENDR
allGrey
	REPT 16
;		dc.w	$032
;		dc.w 	$333
;		dc.w 	$312
		dc.w 	$621
;		dc.w 	$333
;		dc.w	$211
;		dc.w	$765
;		dc.w	$423
	ENDR
allGreen
	REPT 16
;		dc.w 	$141
;		dc.w 	$444
;		dc.w 	$321
		dc.w 	$751
;		dc.w 	$555
;		dc.w 	$321
;		dc.w	$576
;		dc.w	$533
	ENDR


init_tunnel
	jsr		init_tunnel_pointers
	jsr		precalc_tunnel1
;	move.b	#0,$ffffc123
	jsr		precalc_tunnel2
;	move.b	#0,$ffffc123

;	lea		planar+2,a0
;	movem.l (a0),d0-d7
;	movem.l	d0-d7,$ffff8240.w


    move.w  #$2700,sr
    move.l  #tunnel_vbl,$70
    move.w  #$2300,sr

    jsr		tunnel_mainloop
    IFNE	STANDALONE
	    jsr		clearMem
    ENDC
    rts

tunnel_vbl
    addq.w  #1,$466.w
   	subq.w	#1,effect_vbl_counter   
    addq.w	#1,vblCounter
    
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		tst.w	tunnel_barsout_waiter
		blt		.special
		move.l	#timer_b_open_curtain_stable,$120.w
		jmp		.ccc
.special
		move.l	#timer_b_open_curtain_stable_bars,$120.w
.ccc		
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt

		move.w	#0,$ffff8240
    pushall
    	IFEQ	STANDALONE
    		movem.l	planar+2,d0-d7
    		movem.l	d0-d7,$ffff8240
    	ELSE
    		jsr		doTunnelFades
		ENDC

		tst.w	tunnel_barsout_waiter
		bge		.skipppp
			subq.w	#1,.barFadeOff
			bge		.k1
				move.w	#1,.barFadeOff
				add.w	#32,barFadeOff
				cmp.w	#8*32,barFadeOff
				ble		.k1
					move.w	#8*32,barFadeOff
.k1	
			subq.w	#1,.barFade2Off
			bge		.k2
				move.w	#1,.barFade2Off
				add.w	#32,barFade2Off
				cmp.w	#8*32,barFade2Off
				ble		.k2
					move.w	#8*32,barFade2Off
.k2
			subq.w	#1,.barFade3Off
			bge		.k3
				move.w	#1,.barFade3Off
				add.w	#32,barFade3Off
				cmp.w	#8*32,barFade3Off
				ble		.k3
					move.w	#8*32,barFade3Off
.k3
		
			subq.w	#1,.barFade4Off
			bge		.k4
				move.w	#1,.barFade4Off
				add.w	#32,barFade4Off
				cmp.w	#8*32,barFade4Off
				ble		.k4
					move.w	#8*32,barFade4Off
.k4

			subq.w	#1,.barFade5Off
			bge		.k5
				move.w	#1,.barFade5Off
				add.w	#32,barFade5Off
				cmp.w	#8*32,barFade5Off
				ble		.k1
					move.w	#8*32,barFade5Off
.k5

.skipppp

		move.l	currentPoetryRout,a0
		jsr		(a0)


    cmp.w	#600,vblCounter
    bne		.skip
    	moveq	#0,d0
    	moveq	#0,d1
    	move.w	vblCounter,d0
    	move.w	effectCounter,d1
;    	move.b	#0,$ffffc123
.skip

    IFNE	STANDALONE
		jsr		replayMymDump
    ENDC
    popall
    rte
.barFadeOff		dc.w	13*2+15
.barFade2Off	dc.w	13*0+15
.barFade3Off	dc.w	13*4+15
.barFade4Off	dc.w	13*3+15
.barFade5Off	dc.w	13*1+15

tunnelFadeInOff		dc.w	0
tunnelFadeOutOff		dc.w	7*32
tunnelFadeInWaiter	dc.w	0
tunnelFadeOutWaiter	dc.w	32000
textureSelect		dc.l	0
tunnel_barsout_waiter	dc.w	32000
doTunnelFades
    	subq.w	#1,tunnelFadeInWaiter
    	bge		.nofadein
    		move.w	#3,tunnelFadeInWaiter
    		lea		targetTunnelPal+2,a0
    		add.w	tunnelFadeInOff,a0
    		lea		$ffff8240+2,a1
    		REPT 7
    			move.l	(a0)+,(a1)+
    		ENDR
    		move.w	(a0)+,(a1)+

    		add.w	#32,tunnelFadeInOff
    		cmp.w	#8*32,tunnelFadeInOff
    		bne		.coldone
    			move.w	#0,tunnelFadeInOff
    			move.w	#32000,tunnelFadeInWaiter
    			jmp		.coldone
.nofadein

		subq.w	#1,tunnelFadeOutWaiter
		bge		.coldone
			subq.w	#1,.fadeOutTimes
			bge		.kk
				move.w	#-1,tunnel_barsout_waiter

				move.w	#$4e75,doTunnelFades
				jmp		.coldone
.kk
			move.w	#3,tunnelFadeOutWaiter
    		lea		targetTunnelPal+2,a0
    		add.w	tunnelFadeOutOff,a0
    		lea		$ffff8240+2,a1
    		REPT 7
    			move.l	(a0)+,(a1)+
    		ENDR
    		move.w	(a0)+,(a1)+

    		sub.w	#32,tunnelFadeOutOff
    		bge		.coldone
    			move.w	#32*7,tunnelFadeOutOff
    			move.w	#32000,tunnelFadeOutWaiter
.coldone
	rts
.fadeOutTimes	dc.w	5*8

targetTunnelPal
;	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
;	dc.w	$777,$767,$777,$776,$777,$777,$777,$777,$767,$777,$777,$777,$777,$777,$777,$666
;	dc.w	$777,$756,$776,$775,$776,$777,$777,$666,$656,$677,$777,$777,$777,$777,$777,$555
;	dc.w	$777,$745,$765,$774,$775,$776,$777,$555,$545,$566,$666,$777,$767,$777,$777,$444
;	dc.w	$777,$634,$754,$763,$774,$775,$777,$444,$434,$455,$555,$676,$757,$777,$777,$333
;	dc.w	$777,$523,$643,$752,$763,$774,$777,$333,$323,$344,$444,$565,$646,$777,$777,$222
;	dc.w	$777,$412,$532,$741,$752,$773,$777,$222,$212,$233,$333,$454,$535,$766,$777,$111
;	dc.w	$777,$302,$421,$630,$641,$762,$777,$111,$101,$122,$222,$343,$424,$755,$766,$000



	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$776,$776,$777,$677,$776,$776,$776,$776,$777,$677,$776,$776,$776,$766
	dc.w	$777,$777,$775,$765,$777,$576,$775,$775,$775,$775,$677,$577,$775,$775,$775,$755
	dc.w	$777,$777,$774,$754,$777,$465,$774,$674,$774,$774,$577,$467,$774,$774,$774,$744
	dc.w	$777,$677,$773,$743,$777,$354,$673,$573,$773,$763,$467,$356,$773,$773,$763,$733
	dc.w	$777,$577,$772,$732,$777,$243,$572,$462,$772,$752,$356,$245,$772,$762,$752,$722
	dc.w	$777,$466,$761,$721,$666,$132,$461,$351,$671,$741,$245,$134,$761,$751,$641,$611
	dc.w	$777,$355,$750,$710,$555,$021,$350,$240,$560,$730,$134,$023,$750,$640,$530,$500


fadeOutTunnelPal
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$111,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$100,$000,$000,$000
	dc.w	$222,$200,$200,$200,$000,$010,$000,$000,$000,$000,$000,$000,$200,$100,$000,$111
	dc.w	$333,$310,$300,$300,$100,$120,$010,$000,$000,$011,$000,$000,$310,$210,$100,$111
	dc.w	$444,$420,$400,$400,$200,$230,$020,$010,$000,$022,$001,$000,$420,$320,$200,$222
	dc.w	$555,$530,$510,$500,$300,$340,$130,$020,$000,$133,$012,$001,$530,$430,$310,$333
	dc.w	$666,$640,$620,$600,$400,$450,$240,$130,$010,$244,$023,$012,$640,$530,$420,$444
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$021,$355,$134,$023,$750,$640,$530,$555


currentPoetryRout	dc.l	doNothing
tunnelSequence
	; here we do the tunnel sequence stuff
	; we count vbls to change tunnel thing, and we do fades and stuff
	subq.l	#1,currentCounter
	bge		.end
		lea		tunnelEffectList,a0
		add.w	tunnelEffectListOff,a0
		add.w	#4*6,tunnelEffectListOff
		move.l	(a0)+,textureSelect
		move.l	(a0)+,currentTunnelEffect
		move.l	(a0)+,doLeft
		move.l	(a0)+,currentCounter
		move.l	(a0)+,d0
		move.l	(a0)+,currentPoetryRout
		move.w	d0,jmpOffset

		move.l	currentTunnelEffect,d0
		cmp.l	#doClearScreen,d0
		beq		.end
			move.l	currentCounter,d0
			muls	#3,d0					; number of vbl
			move.w	#5,tunnelFadeInWaiter
			sub.w	#30,d0
			subq.w	#1,.times
			bge		.ok
				sub.w	#TUNNEL_BARS_TUNER,d0
.ok
			move.w	d0,tunnelFadeOutWaiter

.end
		cmp.w	#11*4*6,tunnelEffectListOff
		beq		.stopt

	rts
.stopt
	move.w	#TUNNEL_EFFECT_FRAMES_MOVE_WAIT,moveWaiter
	move.w	#$4e75,tunnelSequence
	rts
.times	dc.w	5
currentCounter	dc.l	1

tunnelFadeInOutFlag		dc.w	1
tunnelFadeOff			dc.w	32*7

tunnelEffectListOff	dc.w	0
tunnelEffectList								; start with right, right
;def:		texture 0 or 1, effect,fade?,duration(vbl/3),offset, change duration for longer/shorter; doClearScreen needs to remain 1
	dc.l	1,doPartTunnel,-1,30,40*49,doPoetry0			; do right tunnel, left half
	dc.l	0,doClearScreen,0,1,0,doNothing					; clear
	dc.l	1,doPartTunnel,0,30,40*39,doPoetry1				; do right tunnel, right half
	dc.l	0,doClearScreen,0,1,0,doNothing					; clear
	dc.l	1,doWholeTunnel,0,60,40*39,doNothing			; do right tunnel, whole
	dc.l	0,doClearScreen,0,1,0,doNothing					; clear
	dc.l	0,doPartTunnel,0,30,0,doPoetry2					; do left tunnel, left half
	dc.l	0,doClearScreen,0,1,0,doNothing					; clear
	dc.l	0,doPartTunnel,-1,30,40*10,doPoetry3			; do left tunnel, right half
	dc.l	0,doClearScreen,0,1,0,doNothing					; clear
	dc.l	0,doWholeTunnel,0,280-16-10,0,doNothing				; do whole and move
	dc.l	0,doNothing,0,600,0,doNothing				; do whole and move
currentTunnelEffect	dc.l	doClearScreen
doLeft				dc.l	0
jmpOffset			dc.w	0
fadeInFlag			dc.w	0
fadeOutFlag			dc.w	0


poetryBufferPointer	dc.l	0

;poetryBuffer
;	ds.b	62*10*2*4		;	4960
;
;prepPoetry
;	lea		poetry+128,a0
;	lea		poetryBuffer,a1
;
;	jsr		cpPrep
;
;	lea		poetry+128+60*160,a0
;
;	jsr		cpPrep
;
;	lea		poetry+128+120*160,a0
;
;	jsr		cpPrep
;
;	lea		poetry+128+80,a0
;
;	jsr		cpPrep
;
;	lea		poetryBuffer,a0
;	move.l	poetryBufferPointer,a1
;	move.w	#62-1,d7
;.lll
;		REPT 20
;			move.l	(a0)+,(a1)+
;		ENDR
;		dbra	d7,.lll
;	move.b	#0,$ffffc123
;	rts
;
;cpPrep
;.y set 0
;	REPT 2
;		REPT 10
;			move.w	#0,(a1)+
;		ENDR
;	ENDR
;	REPT 60
;.x set .y
;		REPT 10
;			move.w	.x(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;	rts
;
;poetry
;	incbin	"data/tunnel/poetry3.neo"


poetrycrk
	incbin	"data/tunnel/poetry2.crk"
	even

poetry0off	dc.l	$0
poetry1off	dc.l	$0
poetry2off	dc.l	$0
poetry3off	dc.l	$0

poetry0Const	dc.l	TUNNEL_POETRY_START_SPEED
poetry1Const	dc.l	TUNNEL_POETRY_START_SPEED
poetry2Const	dc.l	TUNNEL_POETRY_START_SPEED
poetry3Const	dc.l	TUNNEL_POETRY_START_SPEED


poetryOff
.y set 0
	REPT 100
		dc.w	.y
.y set .y+160
	ENDR

doPoetry0
;	lea		poetry+128,a0
;	lea		poetryBuffer,a0
	move.l	poetryBufferPointer,a0
	moveq	#0,d0
	move.b	$ffff8201,d0
	lsl.l	#8,d0
	lsl.l	#8,d0
	move.l	d0,a1
	lea		poetryOff,a2
	move.w	poetry0off,d0
	add.w	d0,d0
	add.w	#TUNNEL_PLANE_OFFSET,a1
	add.w	(a2,d0.w),a1
	move.l	poetry0Const,d0
	add.l	d0,poetry0off
	sub.l	#TUNNEL_POETRY_BREAK_SPEED,poetry0Const
	bge		.k1
		move.l	#0,poetry0Const
.k1

	jmp		doPaint
doPoetry1
;	lea		poetry+128+56*160,a0
;	lea		poetryBuffer+62*2*10,a0
	move.l	poetryBufferPointer,a0
	add.w	#62*2*10,a0
	moveq	#0,d0
	move.b	$ffff8201,d0
	lsl.l	#8,d0
	lsl.l	#8,d0
	move.l	d0,a1
	lea		poetryOff,a2
	move.w	poetry1off,d0
	add.w	d0,d0
	add.w	#TUNNEL_PLANE_OFFSET,a1
	add.w	(a2,d0.w),a1
	move.l	poetry1Const,d0
	add.l	d0,poetry1off
	sub.l	#TUNNEL_POETRY_BREAK_SPEED,poetry1Const
	bge		.k2
		move.l	#0,poetry1Const
.k2

	jmp		doPaint
doPoetry2
;	lea		poetry+128+119*160,a0
;	lea		poetryBuffer+62*2*10*2,a0
	move.l	poetryBufferPointer,a0
	add.w	#62*2*10*2,a0
	moveq	#0,d0
	move.b	$ffff8201,d0
	lsl.l	#8,d0
	lsl.l	#8,d0
	move.l	d0,a1
	lea		poetryOff,a2
	move.w	poetry2off,d0
	add.w	d0,d0
	add.w	#TUNNEL_PLANE_OFFSET,a1
	add.w	(a2,d0.w),a1
	move.l	poetry2Const,d0
	add.l	d0,poetry2off
	sub.l	#TUNNEL_POETRY_BREAK_SPEED,poetry2Const
	bge		.k3
		move.l	#0,poetry2Const
.k3
	jmp		doPaint
doPoetry3
;	lea		poetry+128+80,a0
;	lea		poetryBuffer+62*2*10*3,a0
	move.l	poetryBufferPointer,a0
	add.w	#62*2*10*3,a0
	moveq	#0,d0
	move.b	$ffff8201,d0
	lsl.l	#8,d0
	lsl.l	#8,d0
	move.l	d0,a1
	lea		poetryOff,a2
	move.w	poetry3off,d0
	add.w	d0,d0
	add.w	#TUNNEL_PLANE_OFFSET,a1
	add.w	(a2,d0.w),a1
	move.l	poetry3Const,d0
	add.l	d0,poetry3off
	sub.l	#TUNNEL_POETRY_BREAK_SPEED,poetry3Const
	bge		.k4
		move.l	#0,poetry3Const
.k4
	jmp		doPaint


doPaint	
	moveq	#0,d6
	tst.w	doLeft
	bne		.skip
		add.w	#80,a1
.skip	
.y set -5*160
	REPT 5
.x set .y
		REPT 10
			move.w	d6,.x(a1)
.x set .x+8	
		ENDR
.y set	.y+160
	ENDR
	REPT 62
.x set .y
		REPT 10
		move.w	(a0)+,.x(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	rts

doNothing
	rts

doPartTunnel
	jsr		prepareTunnelTexture
	jsr		doTunnelEffectLeft
	jsr		copyLinesTunnel
	rts

doWholeTunnel
	jsr		prepareTunnelTexture
	jsr		doTunnelEffectWhole
	jsr		copyLinesTunnel
	rts

doClearScreen
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.l	screenpointer3,a2
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.w	#200*4-1,d7
.cl
		movem.l	d0-d6/a3/a4/a5,(a0)
		lea		40(a0),a0
		movem.l	d0-d6/a3/a4/a5,(a1)
		lea		40(a1),a1
		movem.l	d0-d6/a3/a4/a5,(a2)
		lea		40(a2),a2
	dbra	d7,.cl
	rts


timer_b_open_curtain_stable_bars
		movem.l	d1-d2/a0,-(sp)

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		move.l	a1,-(sp)
		lea		$ffff8240,a0
		lea		barFade,a1
		add.w	barFadeOff,a1
		dcb.w	59-6-2-3-2-3,$4e71
		REPT 8
			move.l	(a1)+,(a0)+
		ENDR
;		move.w	#$444,$ffff8240.w

		move.l	(sp)+,a1
		movem.l	(sp)+,d1-d2/a0
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open_curtain_stable_bars2,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte
barFade
	rept 16
		dc.w	$700
	endr
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$111,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$100,$000,$000,$000
	dc.w	$222,$200,$200,$200,$000,$010,$000,$000,$011,$000,$000,$000,$200,$100,$000,$111
	dc.w	$333,$310,$300,$300,$100,$120,$010,$000,$022,$011,$000,$000,$310,$210,$100,$111
	dc.w	$444,$420,$400,$400,$200,$230,$020,$010,$133,$022,$001,$000,$420,$320,$200,$222
	dc.w	$555,$530,$510,$500,$300,$340,$130,$020,$244,$133,$012,$001,$530,$430,$310,$333
	dc.w	$666,$640,$620,$600,$400,$450,$240,$130,$355,$244,$023,$012,$640,$530,$420,$444
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
barFadeOff	dc.w	0

timer_b_open_curtain_stable_bars2
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d0-d7/a0-a3,-(sp)
	
		lea		barFade2,a0
		add.w	barFade2Off,a0
		movem.l	(a0),d3-d7/a1-a3

		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		movem.l	d3-d7/a1-a3,$ffff8240

		movem.l	(sp)+,d0-d7/a0-a3
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open_curtain_stable_bars3,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte
barFade2
	rept 16
		dc.w	$070
	endr
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$111,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$100,$000,$000,$000
	dc.w	$222,$200,$200,$200,$000,$010,$000,$000,$011,$000,$000,$000,$200,$100,$000,$111
	dc.w	$333,$310,$300,$300,$100,$120,$010,$000,$022,$011,$000,$000,$310,$210,$100,$111
	dc.w	$444,$420,$400,$400,$200,$230,$020,$010,$133,$022,$001,$000,$420,$320,$200,$222
	dc.w	$555,$530,$510,$500,$300,$340,$130,$020,$244,$133,$012,$001,$530,$430,$310,$333
	dc.w	$666,$640,$620,$600,$400,$450,$240,$130,$355,$244,$023,$012,$640,$530,$420,$444
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
barFade2Off	dc.w	0


timer_b_open_curtain_stable_bars3
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d0-d7/a0-a3,-(sp)
	
		lea		barFade3,a0
		add.w	barFade3Off,a0
		movem.l	(a0),d3-d7/a1-a3

		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		movem.l	d3-d7/a1-a3,$ffff8240

		movem.l	(sp)+,d0-d7/a0-a3
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open_curtain_stable_bars4,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte
barFade3
	rept 16
		dc.w	$007
	endr
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$111,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$100,$000,$000,$000
	dc.w	$222,$200,$200,$200,$000,$010,$000,$000,$011,$000,$000,$000,$200,$100,$000,$111
	dc.w	$333,$310,$300,$300,$100,$120,$010,$000,$022,$011,$000,$000,$310,$210,$100,$111
	dc.w	$444,$420,$400,$400,$200,$230,$020,$010,$133,$022,$001,$000,$420,$320,$200,$222
	dc.w	$555,$530,$510,$500,$300,$340,$130,$020,$244,$133,$012,$001,$530,$430,$310,$333
	dc.w	$666,$640,$620,$600,$400,$450,$240,$130,$355,$244,$023,$012,$640,$530,$420,$444
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
barFade3Off	dc.w	0

timer_b_open_curtain_stable_bars4
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d0-d7/a0-a3,-(sp)
	
		lea		barFade4,a0
		add.w	barFade4Off,a0
		movem.l	(a0),d3-d7/a1-a3

		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		movem.l	d3-d7/a1-a3,$ffff8240

		movem.l	(sp)+,d0-d7/a0-a3
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open_curtain_stable_bars5,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte
barFade4
	rept 16
		dc.w	$770
	endr
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$111,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$100,$000,$000,$000
	dc.w	$222,$200,$200,$200,$000,$010,$000,$000,$011,$000,$000,$000,$200,$100,$000,$111
	dc.w	$333,$310,$300,$300,$100,$120,$010,$000,$022,$011,$000,$000,$310,$210,$100,$111
	dc.w	$444,$420,$400,$400,$200,$230,$020,$010,$133,$022,$001,$000,$420,$320,$200,$222
	dc.w	$555,$530,$510,$500,$300,$340,$130,$020,$244,$133,$012,$001,$530,$430,$310,$333
	dc.w	$666,$640,$620,$600,$400,$450,$240,$130,$355,$244,$023,$012,$640,$530,$420,$444
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
barFade4Off	dc.w	0

timer_b_open_curtain_stable_bars5
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d0-d7/a0-a3,-(sp)
	
		lea		barFade5,a0
		add.w	barFade5Off,a0
		movem.l	(a0),d3-d7/a1-a3

		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)
		REPT 4
			or.l	d7,d7
		ENDR
		movem.l	d3-d7/a1-a3,$ffff8240

		movem.l	(sp)+,d0-d7/a0-a3
		clr.b	$fffffa1b.w	
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte
barFade5
	rept 16
		dc.w	$707
	endr
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$111,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$100,$000,$000,$000
	dc.w	$222,$200,$200,$200,$000,$010,$000,$000,$011,$000,$000,$000,$200,$100,$000,$111
	dc.w	$333,$310,$300,$300,$100,$120,$010,$000,$022,$011,$000,$000,$310,$210,$100,$111
	dc.w	$444,$420,$400,$400,$200,$230,$020,$010,$133,$022,$001,$000,$420,$320,$200,$222
	dc.w	$555,$530,$510,$500,$300,$340,$130,$020,$244,$133,$012,$001,$530,$430,$310,$333
	dc.w	$666,$640,$620,$600,$400,$450,$240,$130,$355,$244,$023,$012,$640,$530,$420,$444
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
	dc.w	$777,$750,$730,$710,$500,$560,$350,$240,$466,$355,$134,$023,$750,$640,$530,$555
barFade5Off	dc.w	0

    IFEQ	STANDALONE
timer_b_open_curtain_stable
		movem.l	d1-d2/a0,-(sp)

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		dcb.w	59-6,$4e71
timer_b_open_curtain_stable_col
		move.w	#$777,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte

timer_b_close_curtain_stable:	
		move.w	#$2700,sr
		movem.l	d0/a0,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_open_curtain_stable

.wait:		dcb.w	134,$4e71 

		move.w	#$000,$ffff8240.w

		movem.l	(sp)+,d0/a0
		rte
	ENDC

tunnel_mainloop
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	cmp.w	#3,$466.w
    	blt		.w

    	move.w	#0,$466
    	tst.w	effect_vbl_counter
    	blt		.next

    move.l	screenpointer,$ffff8200
    addq.w	#1,effectCounter

	jsr		tunnelSequence


    move.l	currentTunnelEffect,a0
    jsr		(a0)

	IFEQ	MOVETUNNEL
	subq.w	#1,moveWaiter
	bge		.kk
		move.w	.offsetMod,d0
		add.w	d0,jmpOffset
		beq		.doFlip
		cmp.w	#(((OFFSMAPWIDTH-160)/8)-1)*40,jmpOffset
		bne	.kk
.doFlip
			move.w	#23,moveWaiter
			neg.w	d0
			move.w	d0,.offsetMod

.kk
	ENDC
;	swapscreens
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	screenpointer3,screenpointer2
	move.l	d0,screenpointer3


    jmp		.w
.next
	rts
.offsetMod	dc.w	40
moveWaiter	dc.w	32000



copyLinesTunnel
	move.l	screenpointer2,a6
	add.w	#160,a6
	move.l	c2pCopyPointerPointer,a0
;	lea		c2pCopyPointer,a0
	jmp		(a0)

codeBuffer	ds.l	200


; 480 is offsmap width, we do 2*2 , screen is 320 wide
;	normally;
;	40*(OFFSMAPWIDTH-160)/8-2
;	40*(480-160)/8-2		40 per 16 pixels
doTunnelEffectLeft
	move.l	tunnelCodePointer,a5						; the unrolled code blob
	lea		codeBuffer,a6								; stuff to save the overwritten data
	move.l	#$4EFA0000,d0								; jmp	xxxx(pc)	instruction
	add.w	#40*(OFFSMAPWIDTH-80)/8-2,d0				; the distance to jump
	add.w	jmpOffset,a5
.o set 10*40
	REPT 5																					; 5* (20*8 + 4) = 820 bytes
		REPT 20
			move.l	.o(a5),(a6)+								; 100 * 24 = 2400			;4
			move.l	d0,.o(a5)									; 100 * 16 = 1600			;4
			lea		(OFFSMAPWIDTH/8)*40(a5),a5
		ENDR
	ENDR

	sub.w	jmpOffset,d0					; fix last smc
	move.l	d0,-(OFFSMAPWIDTH/8)*40+.o(a5)

	; EXECUTE THE ACTUAL CODE
	moveq	#0,d0
	move.w	jmpOffset,d0		;40, needs to do div 5
	divs	#5,d0
	move.l	screenpointer2,a6
	tst.w	doLeft
	beq		.skippp
		add.w	#80,a6
.skippp
	add.w	#160,a6
	sub.w	d0,a6
	add.w	#160*100,a6
	move.w	jmpOffset,d0	
	move.l	tunnelCodePointer,a5
	jsr		(a5,d0)				;4EFA0002							;	100 * 12 = 1200

	move.l	tunnelCodePointer,a0
	lea		codeBuffer,a1
	move.w	jmpOffset,d0
	add.w	d0,a0
.o set 10*40
	REPT 5
		REPT 20
			move.l	(a1)+,.o(a0)				;100*24 = 2400
			lea		(OFFSMAPWIDTH/8)*40(a0),a0		
		ENDR
	ENDR
	rts	





doTunnelEffectWhole
;;;;;;;;;;; ACTUAL DRAW CODE
;		jmp		40(pc)						;4EFA 0026

	; with 160, no jumps
	; with 320, 40*40 each, because each thing is 20*40, so skip 20*40 for every 160 after, thus x-160
	; so x-160 = 

	; SMC THE MOVING STUFF
	IFEQ	MOVETUNNEL
	move.l	tunnelCodePointer,a5
	lea		codeBuffer,a6
	; value is OFFSMAPWIDTH - 40
	move.l	#$4EFA0000,d0
	add.w	#40*(OFFSMAPWIDTH-160)/8-2,d0
	add.w	jmpOffset,a5
.o set 20*40
	REPT 5																					; 5* (20*8 + 4) = 820 bytes
		REPT 20
			move.l	.o(a5),(a6)+								; 100 * 24 = 2400			;4
			move.l	d0,.o(a5)									; 100 * 16 = 1600			;4		
			lea		(OFFSMAPWIDTH/8)*40(a5),a5
		ENDR
	ENDR

	sub.w	jmpOffset,d0					; fix last smc
	move.l	d0,-(OFFSMAPWIDTH/8)*40+.o(a5)

	ENDC



	; EXECUTE THE ACTUAL CODE
	moveq	#0,d0
	move.w	jmpOffset,d0		;40, needs to do div 5
	divs	#5,d0
	move.l	screenpointer2,a6
	add.w	#160,a6
	sub.w	d0,a6
	add.w	#160*100,a6
	move.w	jmpOffset,d0	
;	add.w	#2,d0
;	lea		c2pCode,a5
	move.l	tunnelCodePointer,a5
	jsr		(a5,d0)				;4EFA0002							;	100 * 12 = 1200





;;;;;; RESTORE THE STUFF
	IFEQ	MOVETUNNEL

;	lea		c2pCode,a0
	move.l	tunnelCodePointer,a0
	lea		codeBuffer,a1
	move.w	jmpOffset,d0
	add.w	d0,a0

.o set 20*40
	REPT 5
		REPT 20
			move.l	(a1)+,.o(a0)				;100*24 = 2400
			lea		(OFFSMAPWIDTH/8)*40(a0),a0		
		ENDR
	ENDR
	ENDC

;	jsr		generatedCodeWhole
;;;;;;;;;;;;;; TEXTURE ROTATION 
;	jsr		moveTunnelTexture
	rts
;	ds.b	64000


;c2pCode
;.y set -160*100
;	REPT VIEWPORT_HEIGHT
;.x set .y
;		REPT 60
;			move.l	$12(a1),d0		;16	-> -8
;			or.l	$12(a2),d0		;20 -> -12
;			or.l	$12(a3),d0		;20 -> -12
;			or.l	$12(a4),d0		;20 -> -12	
;			movep.l	d0,.x(a6)
;
;			move.l	$12(a1),d0
;			or.l	$12(a2),d0
;			or.l	$12(a3),d0
;			or.l	$12(a4),d0					
;			movep.l	d0,.x+1(a6)					;10*4 = 40, 40*20 = 800, 800*100= 80000 space * 3 = 240000
;.x set .x+8
;		ENDR
;.y set .y+320
;	ENDR
;	rts

genc2pCode
	move.l	tunnelCodePointer,a6
	lea		.tmplate,a5
	move.l	(a5)+,d0			; a
	move.l	(a5)+,d1			; b
	move.l	(a5)+,d2			; c
	move.l	(a5)+,d3			; d
	move.l	(a5)+,d4			; e
	move.w	#-160*100,d5		; .xoff
	move.w	#320,a4
	move.w	#VIEWPORT_HEIGHT-1,d7	; .oloop
	move.l	offsmapPointer,a5
.oloop
	move.w	#15-1,d6				;.iloop
	move.w	d5,d4					;.x set .y
.iloop
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,(a6)
		addq.w	#1,d4				; .x set .x+1
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,20(a6)
		addq.w	#7,d4				; .x set .x+1

		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,40(a6)
		addq.w	#1,d4				; .x set .x+1
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,60(a6)
		addq.w	#7,d4				; .x set .x+1

		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,80(a6)
		addq.w	#1,d4				; .x set .x+1
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,100(a6)
		addq.w	#7,d4				; .x set .x+1

		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,120(a6)
		addq.w	#1,d4				; .x set .x+1
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		move.w	(a5)+,d3
		movem.l	d0-d4,140(a6)
		addq.w	#7,d4				; .x set .x+1

		lea		160(a6),a6
	dbra	d6,.iloop
	add.w	a4,d5
	dbra	d7,.oloop
	move.w	#$4e75,(a6)+
	rts

.tmplate
			move.l	$12(a1),d0		;16	-> -8
			or.l	$12(a2),d0		;20 -> -12
			or.l	$12(a3),d0		;20 -> -12
			or.l	$12(a4),d0		;20 -> -12	
			movep.l	d0,1234(a6)

			move.l	$12(a1),d0
			or.l	$12(a2),d0
			or.l	$12(a3),d0
			or.l	$12(a4),d0					
			movep.l	d0,1234(a6)					;10*4 = 40, 40*20 = 800, 800*100= 80000 space * 3 = 240000



moveTunnelTexture
.x
	; y, rotation
	add.l	#TEXTURE_WIDTH*4,_tunneloffset
	; x, zoom
	add.l	#4*2,_tunneloffset

;	move.l	#TEXTURE_WIDTH*4*TEXTURE_WIDTH*2,d0
	move.l	#TEXTURE_WIDTH*4*TEXTURE_WIDTH*2,d0
	move.l	d0,d1
	add.l	texturescroll,d0

	cmp.l	_tunneloffset,d0
	bge		.noloop
		sub.l	d1,_tunneloffset
.noloop

	subq.w	#1,_addtimes
	bne		.exit
;		move.b	#0,$ffffc123
.exit
	rts

_tunneloffset		dc.l	0	;TEXTURE_WIDTH*TEXTURE_WIDTH/64 		; to keep track of the offset which corresponds to the frame within the bumpdata offset
texturescroll		dc.l	0
_addtimes			dc.w	128


prepareChunkyTextureBPL1to2
	moveq	#0,d0

	move.l	texture_tunnelPointer,a0
	lea		TAB1,a1
	move.l	planartexture1pointer,a2
	jsr		generatePlanarTexture

	move.l	texture_tunnelPointer,a0
	lea		TAB2,a1
	move.l	planartexture2pointer,a2
	jsr		generatePlanarTexture

	move.l	texture_tunnelPointer,a0
	lea		TAB3,a1
	move.l	planartexture3pointer,a2
	jsr		generatePlanarTexture

	move.l	texture_tunnelPointer,a0
	lea		TAB4,a1
	move.l	planartexture4pointer,a2
	jsr		generatePlanarTexture

	rts

generatePlanarTexture
	move.l	#TEXTURE_WIDTH*TEXTURE_HEIGHT-1,d7
	move.l	d7,d6
	move.l	a0,a3

	add.l	#TEXTURE_WIDTH*TEXTURE_HEIGHT,a3
	jsr		generateTexture
	jsr		generateTexture

	sub.l	#TEXTURE_WIDTH*TEXTURE_HEIGHT,a3
	jsr		generateTexture
	jsr		generateTexture

	add.l	#TEXTURE_WIDTH*TEXTURE_HEIGHT,a3
	jsr		generateTexture
	jsr		generateTexture

	rts

generateTexture
	move.l	d6,d7
	move.l	a3,a0
.loop
	move.b	(a0)+,d0
	move.l	(a1,d0.w),(a2)+
	dbra	d7,.loop
	rts

	IFEQ	STANDALONE
convertPlanar2Chunky
	move.l	#PIC_WIDTH,d5
	move.l	d5,d6
	lsl.l	#3,d6
	neg.w	d6
	add.w	#160,d6
	move.w	d6,a2				; a2 is remainder to increment each horizontal number

	subq.w	#1,d5

;	lea		texture_tunnel,a1
	move.l	texture_tunnelPointer,a1
	move.l	#PIC_HEIGHT,d7
	subq.w	#1,d7
	lea		planar+34,a0
.ol
	move.w	d5,d6
.il
	movem.w	(a0)+,d0-d3			; 8 bytes
	REPT 16
		moveq	#0,d4
		lsl.w	#1,d3
		roxl.b	d4
		lsl.w	#1,d2
		roxl.b	d4
		lsl.w	#1,d1
		roxl.b	d4
		lsl.w	#1,d0
		roxl.b	d4
		lsl.w	#2,d4
		move.b	d4,(a1)+
	ENDR
		dbra	d6,.il
	add.w	a2,a0
	dbra	d7,.ol
	move.l	texture_tunnelPointer,a0
	move.w	#128*64,d0
	move.b	#0,$ffffc123

	rts
	ENDC

tunneltext	incbin	"data/tunnel/tunneltext6.crk"			;1856
	even



generateC2PCopy
;	move.l	c2pCopyPointer,a0
;	lea		c2pCopyPointer,a0
	move.l	c2pCopyPointerPointer,a0
;	lea		generatedC2P_copy,a0
	move.l	#$4CEE3FFF,a1
	move.l	#$48EE3FFF,a2
	move.l	#$4CEE0FFF,a3
	move.l	#$48EE0FFF,a4

	move.l	#VIEWPORT_HEIGHT-1-1,d7
	moveq	#0,d0
	move.w	#160,d1

	move.w	#56,d2
	move.w	#160*2-112,d3

.loop
	move.l	a1,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5		6
	move.w	d0,(a0)+			;	x

	move.l	a2,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)		6
	move.w	d1,(a0)+			;	x+160

	add.w	d2,d0				;	x+56							8
	move.l	a1,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x+56

	add.w	d2,d1				;	x+160+56						8
	move.l	a2,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160+56

	add.w	d2,d0				;	x+56+56							8
	move.l	a3,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x+56+56

	add.w	d2,d1				;	x+160+56+56						8
	move.l	a4,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160+56+56

	add.w	d3,d0				;	pad to next 					4			48 48*100 = 4802
	add.w	d3,d1				;	pad to next

	dbra	d7,.loop				;4802

	move.w	#$4e75,(a0)+
;	lea		generatedC2P_copy,a6
;	sub.l	a6,a0
;	move.b	#0,$ffffc123

	rts


; OFFSMAP GENERATION ROUTS
; OFFSMAP GENERATION ROUTS
; OFFSMAP GENERATION ROUTS
; OFFSMAP GENERATION ROUTS
; OFFSMAP GENERATION ROUTS
	IFEQ	GENERATE_FROM_TGA
generateFlatOffsetForTGA
	moveq	#0,d1 ;y
	lea 	tga+18,a0
	move.w	#VIEWPORT_H_PX-1,d7
.y:
	moveq	#0,d0 ;x
	move.w	#VIEWPORT_W_PX-1,d6
.x:

;	addq.l #1,a0 ;skip unused channel in the TGA
	move.b	#0,(a0)+
	move.b d1,(a0)+
	move.b d0,(a0)+
;
	addq.b #1,d0

	cmp.b	#64,d0
	bne		.kk
		move.b	#0,d0
.kk

	dbra d6,.x	
	addq.b #1,d1
	cmp.w	#128,d1
	bne		.kk2
		move.b	#0,d1
.kk2
	dbra d7,.y

;	lea		tga+18,a0
;	move.b	#0,$ffffc123
	rts

convertOffsmapToTGA
	lea		tga,a0
	move.b	#0,$ffffc123

;	lea		offsmap,a0
	move.l	offsmapPointer,a0
	lea		tga+18,a1
	move.w	#%11111100,d2
	move.w	#100-1,d7
.doLine
		move.w	#160-1,d6
.doPix
		moveq	#0,d0
		move.w	(a0)+,d0		; this is the compound value, 2 bytes
		move.l	d0,d1
		lsr.w	#8,d1			; first
		and.w	d2,d0
		lsr.w	#2,d0			; second	

		addq.w	#1,a1
		move.b	d1,(a1)+			
		move.b	d0,(a1)+			
	dbra	d6,.doPix
	dbra	d7,.doLine

	lea		tga,a0
	lea		tga+18,a1
	move.b	#0,$ffffc123
	rts

XIA_TGA		equ 1

generateOffsetFromTGA
	lea		tga+18,a0
	move.l	offsmapPointer,a1
;	lea		offsmap,a1
	move.l	a1,a2
	move.w	#VIEWPORT_H_PX-1,d7
.y
	move.w	#OFFSMAPWIDTH-1,d6
.x
	IFEQ	XIA_TGA
		addq.w	#1,a0
		moveq	#0,d0
		moveq	#0,d1

		move.b	(a0)+,d0
		move.b	(a0)+,d1
;		addq.w	#6,d0
;		addq.w	#6,d1
;		asr.w	#2,d0
;		asr.w	#2,d1

		asl.w	#6,d1
		add.w	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,(a1)+

	ELSE
		moveq	#0,d1
		addq.w	#1,a0
		move.b	(a0)+,d1
;		ext.w	d1
;		mulu	#TEXTURE_WIDTH,d1
		asl.w	#6,d1
		add.b	(a0)+,d1
		add.w	d1,d1
		add.w	d1,d1
		move.w	d1,(a1)+
	ENDC
	dbra	d6,.x
	dbra	d7,.y

	sub.l	a2,a1
;	move.b	#0,$ffffc123


	rts
	ENDC




prepareTunnelTexture
;	lea		planartexture1,a1
	move.l	planartexture1pointer,a1
;	lea		planartexture2,a2
	move.l	planartexture2pointer,a2
;	lea		planartexture3,a3
	move.l	planartexture3pointer,a3
;	lea		planartexture4,a4
	move.l	planartexture4pointer,a4

	tst.l	textureSelect
	beq		.noadd
		add.l	#64*64*4*2,a1
		add.l	#64*64*4*2,a2
		add.l	#64*64*4*2,a3
		add.l	#64*64*4*2,a4
.noadd
	; this is the offset for the changing texture
	move.l	texturescroll,d0
	add.l	d0,a1
	add.l	d0,a2
	add.l	d0,a3
	add.l	d0,a4
; EDIT HERE FOR SCROLLS AND RESET
;	jmp		.gogogo
	sub.l	#8,texturescroll
	add.l	#64*4,texturescroll
	cmp.l	#64*64*4,texturescroll
	ble		.gogogo
		sub.l	#64*64*4,texturescroll
.gogogo



	; this is the offset for the moving tunneleffect
	move.l	_tunneloffset,d0
	add.l	d0,a1
	add.l	d0,a2
	add.l	d0,a3
	add.l	d0,a4
	rts

	section DATA



	IFEQ	GENERATE_FROM_TGA
tga		
		incbin		"data/tunnel/twisted_002.tga"
		even
	ENDC
offsmapPointer	ds.l	1

offsmapcrk
	incbin		"data/tunnel/offsmap480.crk"			;96000/58918
	even

	IFEQ	STANDALONE
planar	
	incbin		"gfx/textures/text650donut4.pi1"		; original ukko
;	incbin		"gfx/textures/text650donut3.pi1"		; original ukko
	ENDC
;	incbin		"data/tunnel/text655.pi1"
;	incbin		"data/tunnel/text652.pi1"
;	incbin		"data/tunnel/text654.pi1"

texture_tunnelPointer	ds.l	1


	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s

; if we want to be really anal, we can generate these things
TAB1:
                DC.B $00,$00,$00,$00		;0
                DC.B $C0,$00,$00,$00		;4
                DC.B $00,$C0,$00,$00		;8
                DC.B $C0,$C0,$00,$00		;12
                DC.B $00,$00,$C0,$00		;16
                DC.B $C0,$00,$C0,$00		;20
                DC.B $00,$C0,$C0,$00		;24
                DC.B $C0,$C0,$C0,$00		;28
                DC.B $00,$00,$00,$C0		;32
                DC.B $C0,$00,$00,$C0		;36
                DC.B $00,$C0,$00,$C0		;40
                DC.B $C0,$C0,$00,$C0		;44
                DC.B $00,$00,$C0,$C0		;48
                DC.B $C0,$00,$C0,$C0		;52
                DC.B $00,$C0,$C0,$C0		;56
                DC.B $C0,$C0,$C0,$C0		;60
TAB2:
                DC.B $00,$00,$00,$00		;0
                DC.B $30,$00,$00,$00		;4
                DC.B $00,$30,$00,$00		;8
                DC.B $30,$30,$00,$00		;12
                DC.B $00,$00,$30,$00		;16
                DC.B $30,$00,$30,$00		;20
                DC.B $00,$30,$30,$00		;24
                DC.B $30,$30,$30,$00		;28
                DC.B $00,$00,$00,$30		;32
                DC.B $30,$00,$00,$30		;36
                DC.B $00,$30,$00,$30		;40
                DC.B $30,$30,$00,$30		;44
                DC.B $00,$00,$30,$30		;48
                DC.B $30,$00,$30,$30		;52
                DC.B $00,$30,$30,$30		;56
                DC.B $30,$30,$30,$30		;60
TAB3:
                DC.B $00,$00,$00,$00		;0
                DC.B $0C,$00,$00,$00		;4
                DC.B $00,$0C,$00,$00		;8
                DC.B $0C,$0C,$00,$00		;12
                DC.B $00,$00,$0C,$00		;16
                DC.B $0C,$00,$0C,$00		;20
                DC.B $00,$0C,$0C,$00		;24
                DC.B $0C,$0C,$0C,$00		;28
                DC.B $00,$00,$00,$0C		;32
                DC.B $0C,$00,$00,$0C		;36
                DC.B $00,$0C,$00,$0C		;40
                DC.B $0C,$0C,$00,$0C		;44
                DC.B $00,$00,$0C,$0C		;48
                DC.B $0C,$00,$0C,$0C		;52
                DC.B $00,$0C,$0C,$0C		;56
                DC.B $0C,$0C,$0C,$0C		;60
TAB4:
                DC.B $00,$00,$00,$00		;0
                DC.B $03,$00,$00,$00		;4
                DC.B $00,$03,$00,$00		;8
                DC.B $03,$03,$00,$00		;12
                DC.B $00,$00,$03,$00		;16
                DC.B $03,$00,$03,$00		;20
                DC.B $00,$03,$03,$00		;24
                DC.B $03,$03,$03,$00		;28
                DC.B $00,$00,$00,$03		;32
                DC.B $03,$00,$00,$03		;36
                DC.B $00,$03,$00,$03		;40
                DC.B $03,$03,$00,$03		;44
                DC.B $00,$00,$03,$03		;48
                DC.B $03,$00,$03,$03		;52
                DC.B $00,$03,$03,$03		;56
                DC.B $03,$03,$03,$03		;60
    ENDC

planartexture1pointer		ds.l	1			;16*PIC_WIDTH*PIC_HEIGHT*3*4		;	196608	64*64*3*4 = 49152		16*4*128*3*4 = 98304
planartexture2pointer		ds.l	1
planartexture3pointer		ds.l	1
planartexture4pointer		ds.l	1
generatedCodeWholePointer	ds.l	1
c2pCopyPointerPointer		ds.l	1
tunnelCodePointer			ds.l	1

    rsreset

    IFEQ	STANDALONE
	section BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
screenpointer3		ds.l	1
effectCounter		ds.w	1
vblCounter			ds.w	1
	ENDC

;PIC_WIDTH	equ 4
;PIC_HEIGHT	equ 64*2
	; 16 * 4 * 128 * 3 * 4 = 98304

;planartexture1			ds.b	16*PIC_WIDTH*PIC_HEIGHT*3*4		;	196608	64*64*3*4 = 49152		16*4*128*3*4 = 98304
;planartexture2			ds.b	16*PIC_WIDTH*PIC_HEIGHT*3*4		;	196608				49152	
;planartexture3			ds.b	16*PIC_WIDTH*PIC_HEIGHT*3*4		;	196608				49152
;planartexture4			ds.b	16*PIC_WIDTH*PIC_HEIGHT*3*4		;	196608				49152

;generatedCodeWhole		ds.b	VIEWPORT_WIDTH*VIEWPORT_HEIGHT*40+2	;	20*100*40+2 = 80002


;c2pCopyPointer			ds.b	4000

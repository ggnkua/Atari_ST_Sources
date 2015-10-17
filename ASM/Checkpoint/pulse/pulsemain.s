; we have
;	- intro from cursor
;	- title screen
;	- metaballs (3 small screens)
;	- circledots
;	- grid rotation, zoom
;	- cube greetings
;	- picture
;	- c2p pulse logo
;	- out-scroller
;	- credits



incSync	macro
	IFNE	synccounter
	addq.w	#1,_synccounter
	ENDC
	endm

checkSync macro
	IFNE	synccounter
	moveq	#0,d0
	move.w	_synccounter,d0
;	move.b	#0,$ffffc123
	move.w	#0,_synccounter
	endc
	endm

exitOnSpace macro
	cmp.b 	#$39,$fffffc02.w
	bne		.x\@
		move.w	#-1,demo_exit
		rts
.x\@
	endm

checkScreen	macro
	IFNE	screenCheck
	pushd0
	pushd1
	moveq	#0,d0
	move.b	$ffff8205,d0
	move.l	screenpointer2,d1
	swap 	d1
	cmp.w	d0,d1
	bne		.cont\@
		move.l	screenpointer,d0
		move.l	screenpointer2,d1
		move.b	#0,$ffffc123
.cont\@
	popd1
	popd0
	ENDC
	endm

screenCheck			equ	0
framecount			equ 0
playmusic			equ 1
playmusicinvbl		equ 1
rasters				equ 0
cubeframe			equ 0
synccounter			equ 0

number_of_stars		equ 280-7*10


LOGS            	EQU 1024
EXPS            	EQU 4096
max_nr_of_vertices	equ 6400			; max in vbl with music is 643

    section	text

	include	asm/macro.s

		allocateStackAndShrink
	jsr	saveAndKillTimers
	jsr	disableMouse
	jsr	backupPalAndScrMemAndResolutionAndSetLowRes
	jsr	checkMachineTypeAndSetStuff
	jsr	setScreen64kAligned
	jsr	storeLowerMem
;;;;; SETUP COMPLETE, NOW DO INIT			
.init
	jsr	init_aligned_blocks

	move.l	#no_music,sndh_pointer

	move.w	#$2700,sr
	move.l 	#default_vbl,$70
	move.w	#$2300,sr

	IFNE playmusic
		lea	intromusic,a0
		move.l	a0,sndh_pointer
		jsr		initMusic
	ENDC

	IFNE	synccounter
		move.w	#0,_synccounter
	ENDC


	jsr		cursorFade
	tst.w	demo_exit
	bne		.exit


	move.l	#75-1,d7
.waitsome
		wait_for_vbl
		exitOnSpace
	dbra	d7,.waitsome

	IFNE playmusic
		lea		music,a0
		move.l	a0,sndh_pointer
		jsr		initMusic
	ENDC

	checkSync							;0000018F

	jsr		pulseEffect
	tst.w	demo_exit
	bne		.exit
	checkSync							;000009AC


.meta
	jsr		metaBalls
	tst.w	demo_exit
	bne		.exit
	checkSync							;000003C6

.dots
	jsr		dotsEffect
	tst.w	demo_exit
	bne		.exit
	checkSync							;00000385

.tunnel
	jsr		tunnelEffect
	tst.w	demo_exit
	bne		.exit
	checkSync							;000004C5

.grid
	jsr		doGridTrans
	tst.w	demo_exit
	bne		.exit
	checkSync							;000001E2

.cube
	jsr		doCubeEffect
	tst.w	demo_exit
	bne		.exit
	checkSync							;0000051F

.diag
	jsr		doDiagTrans
	tst.w	demo_exit
	bne		.exit
	checkSync							;00000077

.picture
	jsr		doPicture
	tst.w	demo_exit
	bne		.exit
	checkSync							;00000276

.c2p
	jsr		doC2Peffect
	tst.w	demo_exit
	bne		.exit
	checkSync							;00000340

.scroller
	jsr		doScroller
	tst.w	demo_exit
	bne		.exit
	checkSync							;00000584

.doOuttro
	jsr		doOuttro
	tst.w	demo_exit
	bne		.exit


	;----- END --------------------------------------------
.exit

	move.w	#$2700,sr
	move.l	#dummyvbl,$70.w				;Install our own VBL
	move.l	#dummy,$68.w				;Install our own HBL (dummy)
	move.l	#dummy,$134.w				;Install our own Timer A (dummy)
	move.l	#dummy,$120.w				;Install our own Timer B
	move.l	#dummy,$114.w				;Install our own Timer C (dummy)
	move.l	#dummy,$110.w				;Install our own Timer D (dummy)
	move.l	#dummy,$118.w				;Install our own ACIA (dummy)
	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
	move.w	#$2300,sr

	jsr	restoreLowerMem
	jsr restoresForMachineTypes
	jsr	restorePalAndScreenMemAndResolution
	jsr	restoreTimers
	jsr	stopMusic
	jsr	enableMouse
	rts


; ***************************************** END MAINLOOP ************

;;;;;;;;;;;;;;;;; INITIALIZATION LOWER MEMORY ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; INITIALIZATION LOWER MEMORY ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; INITIALIZATION LOWER MEMORY ;;;;;;;;;;;;;;;;;;;;;;;
init_aligned_blocks
	move.l	screenpointer2,d0
	add.l	#$10000,d0
	move.l	d0,alignpointer1
	move.l	d0,y_block_pointer
	move.l	d0,screenpointer3
	add.l	#$10000,d0
	move.l	d0,alignpointer2
	add.l	#$10000,d0
	move.l	d0,alignpointer3
	add.l	#$10000,d0
	move.l	d0,alignpointer4
	add.l	#$10000,d0
	move.l	d0,alignpointer5
	add.l	#$10000,d0
	move.l	d0,alignpointer6
	add.l	#$10000,d0
	move.l	d0,alignpointer7
	add.l	#$10000,d0
	move.l	d0,alignpointer8
	add.l	#$10000,d0
	move.l	d0,alignpointer9
	add.l	#$10000,d0
	move.l	d0,alignpointer10
	add.l	#$10000,d0
	move.l	d0,alignpointer11
	add.l	#$10000,d0
	move.l	d0,alignpointer12

	; dots pointers
	move.l	alignpointer10,d0
	add.l	#25600,d0
	move.l	d0,tableSourcePointer
	move.l	d0,clearScreen1bplPointer
	add.l	#8542,d0
	move.l	d0,dotsLoopPointer
	add.l	#16074,d0					; 25600 + 8542 + 16074 = 50216 ==> 15320 free

	; poly pointers
	move.l	y_block_pointer,d0
	add.l	#800,d0

	move.l	d0,pointer_10_10
	add.l	#1280,d0
	move.l	d0,pointer_10_12_pos
	add.l	#1280,d0
	move.l	d0,pointer_10_12_neg
	add.l	#1280,d0

	move.l	d0,pointer_12_12
	add.l	#1280,d0
	move.l	d0,pointer_12_14_pos
	add.l	#1280,d0
	move.l	d0,pointer_12_14_neg
	add.l	#1280,d0

	move.l	d0,pointer_14_14
	add.l	#1280,d0
	move.l	d0,pointer_14_16_pos2
	add.l	#1280,d0
	move.l	d0,pointer_14_16_neg2
	add.l	#1280,d0

	move.l	d0,pointer_16_16
	add.l	#1280,d0
	move.l	d0,pointer_16_18_pos
	add.l	#1280,d0
	move.l	d0,pointer_16_18_neg
	add.l	#1280,d0				;12 * 1280 = 15360 + 800 = 16160 --> 49376 left

	move.l	d0,pointer_lines_no_add_neg
	add.l	#162*lineloopsize,d0				;	1458
	move.l	d0,pointer_lines_no_add_pos
	add.l	#162*lineloopsize,d0				;	1458
	move.l	d0,pointer_lines_with_add_neg
	add.l	#194*lineloopsize,d0				;	1728
	move.l	d0,pointer_lines_with_add
	add.l	#194*lineloopsize,d0				;	1728
	move.l	d0,pointer_lines_no_add_neg_2lines
	add.l	#226*lineloopsize,d0				;	2034
	move.l	d0,pointer_lines_no_add_pos_2lines
	add.l	#226*lineloopsize,d0				;	2034
	move.l	d0,pointer_lines_with_add_2lines
	add.l	#258*lineloopsize,d0				;	2304
	move.l	d0,pointer_lines_with_add_neg_2lines
	add.l	#258*lineloopsize,d0				;	2304			---> 15048 ---> 34328 left

	move.l	d0,clearScreenPointer
	add.l	#totalClear+2,d0					;	7202
	move.l	d0,eorFillPointer
	add.l	#totalFill+2,d0						;	14402
	move.l	d0,eorFillPointer2
	add.l	#totalFill2+2,d0					;	8450			--> 4202 left

	move.l	d0,diagLinePointer

	move.l	d0,x_start_pointer_1bpl				;	1280
	add.l	#1280,d0
	move.l	d0,x_end_pointer_1bpl				;	1280
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end y_block_pointer

	move.l	logpointer,d0
	add.l	#2048,d0							;	2048
	move.l	d0,clearScreenPointer2
	add.l	#totalClear2+2,d0					;	4226			--> 
	move.l	d0,cubeObjectPointer
	add.l	#25600,d0
	move.l	d0,vertexprojection2_pointer

	; diag pointer
	move.l	d0,copy4BLPointer

	; now we do smc
	move.l	pointer_10_10,mo10_1+2
	move.l	pointer_10_10,mo10_2+2
	move.l	pointer_10_12_pos,smc10_12_pos+2
	move.l	pointer_10_12_neg,smc10_12_neg+2

	move.l	pointer_12_12,mo12_1+2
	move.l	pointer_12_12,mo12_2+2
	move.l	pointer_12_14_pos,smc12_14_pos+2
	move.l	pointer_12_14_neg,smc12_14_neg+2

	move.l	pointer_14_14,mo14_1+2
	move.l	pointer_14_14,mo14_2+2
	move.l	pointer_14_16_pos2,smc14_16_pos+2
	move.l	pointer_14_16_neg2,smc14_16_neg+2

	move.l	pointer_16_16,mo16_1+2
	move.l	pointer_16_16,mo16_2+2
	move.l	pointer_16_18_pos,smc16_18_pos+2
	move.l	pointer_16_18_neg,smc16_18_neg+2

	lea		lines,a0
	move.l	a0,checker_linePointer
	lea		lines2,a0


	move.l	alignpointer7,d0
	move.l	d0,c2pRoutPointer		; 97202
	add.l	#97202,d0
	move.l	d0,c2pCopyPointer		; 3600+2		; alignpointer4 and alignpointer5 used
	add.l	#3602,d0

	; tunnel effect
	; screenpointer3 == alignpointer1
	; free from alignpointer2 on
	;generatedCodeWholePointer			ds.l	1					;80002
	;generatedCodePointer				ds.l	1					;26402
	;generatedCode2Pointer				ds.l	1					;27202
	;generatedCode3Pointer				ds.l	1					;26402
	move.l	alignpointer2,d0
	move.l	d0,generatedCodeWholePointer				; first
	add.l	#80002,d0
	move.l	d0,generatedCodePointer
	add.l	#26402,d0
	move.l	d0,generatedCode2Pointer
	add.l	#27202,d0
	move.l	d0,generatedCode3Pointer
	add.l	#26402,d0
	;planartexturepointer1				ds.l	1					;49152*2
	;planartexturepointer2				ds.l	1					;49152*2
	;planartexturepointer3				ds.l	1					;49152*2
	;planartexturepointer4				ds.l	1					;49152*2
	move.l	d0,planartexturepointer1
	add.l	#49152*2,d0
	move.l	d0,planartexturepointer2
	add.l	#49152*2,d0
	move.l	d0,planartexturepointer3
	add.l	#49152*2,d0
	move.l	d0,planartexturepointer4
	add.l	#49152*2,d0
	move.l	d0,c2pCopyPointerTunnel


	; greeetings shit
	move.l	xpos_splitted_pointer,d0
	add.w	#2000,d0
	move.l	d0,clearSpritesCodePointer
	add.w	#6000,d0
	move.l	d0,showSpriteCodePointer
	add.w	#12000,d0
	move.l	d0,active_sprite_list_pointer
	add.w	#3500,d0
	move.l	d0,sprite_startpos_pointer
	add.w	#3500,d0

	; scroller pointers
	move.l	screenpointer2,d0
	add.l	#$8000,d0
	move.l	d0,screenpointer4
	;;;;;;;;

	move.l	x_start_pointer_1bpl_scroll,d0
	add.l	#$8000,d0
	move.l	d0,screenpointer5

	move.l	x_start_pointer_2bpl_scroll,d0
	add.l	#$8000,d0
	move.l	d0,screenpointer6

	move.l	x_end_pointer_1bpl_scroll,d0
	add.l	#$8000,d0
	move.l	d0,screenpointer7

	move.l	x_end_pointer_2bpl_scroll,d0
	add.l	#$8000,d0
	move.l	d0,screenpointer8

	move.l	y_block_pointer,d0
	add.w	#800,d0
	move.l	d0,buildListAddPointer
	add.w	#2000,d0
	move.l	d0,buildListSubPointer
	add.w	#2000,d0

	move.l	d0,starLocs
	add.w	#number_of_stars*6,d0
	move.l	d0,starLocs2
	add.w	#number_of_stars*6,d0
	move.l	d0,starLocs3
	add.w	#number_of_stars*6,d0
	move.l	d0,starLocs4
	add.w	#number_of_stars*6,d0
	move.l	d0,starLocs5
	add.w	#number_of_stars*6,d0
	move.l	d0,starLocs6
	add.w	#number_of_stars*6,d0
	move.l	d0,starLocs7
	add.w	#number_of_stars*6,d0
	move.l	d0,starLocs8
	add.w	#number_of_stars*6,d0

	rts


; stores lower memory from $1000-$b000
storeLowerMem
	lea	$1000,a0
	lea	oldLower,a1
.m
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	#$B000,a0
	bne		.m
	rts

; restores lower memory to $1000-$b000
restoreLowerMem
	lea	oldLower,a0
	lea	$1000,a1
.m
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	#$B000,a1
	bne		.m
	rts

init_yblock_aligned
	move.l	y_block_pointer,a1
	move.l	#200-1,d7
	moveq	#0,d0
	move.w	#160,d6
	swap	d6
	move.w	#160,d6
.loop
	move.l	d0,(a1)+
	add.l	d6,d0
	dbra	d7,.loop
	rts


; generate table for individual pixels for each 320 placements on screen
; format: offset,mask
; from left to right
init_xblock_aligned
	move.l	x_block_add_pointer,a1
	move.w	#$8000,d5
	moveq	#0,d1
	moveq	#20-1,d7
.ol
	moveq	#16-1,d6
	move.w	d5,d0
.il
			move.w	d1,(a1)+
			move.w	d0,(a1)+
			lsr.w	#1,d0
		dbra	d6,.il
		addq	#8,d1
	dbra	d7,.ol
	rts	

; if we have no music, nop shit
no_music
	REPT 10
		nop
	ENDR
	rts


default_vbl2:	
		move.l 	screenpointershifter,$ff8200
		addq.w 		#1,$466.w
	incSync
		;Start up Timer B each VBL
		move.w	#$2700,sr			;Stop all interrupts
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		move.w	#$2300,sr			;Interrupts back on
		IFNE	playmusic
		IFNE	playmusicinvbl				
			pusha0
			move.l	sndh_pointer,a0
			jsr		8(a0)
			popa0
		ENDC
		ENDC
        IFNE    framecount
            addq.w  #1,_framecounter
        ENDC
	rte	
;;;;;;;;;;;;;; END INIT ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; END INIT ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; END INIT ;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;; TUNNEL START ;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL START ;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL START ;;;;;;;;;;;;

TUNNEL_VIEWPORT_HEIGHT 	equ 	100
TUNNEL_VIEWPORT_WIDTH 	equ 	20

TUNNEL_TEXTURE_WIDTH	equ 	64		
TUNNEL_TEXTURE_HEIGHT	equ 	64	


TUNNEL_PIC_WIDTH		equ 	4
TUNNEL_PIC_HEIGHT		equ 	64*2

_addtimes				dc.w	128
_tunneloffset			dc.l	64*16	;TUNNEL_TEXTURE_WIDTH*TUNNEL_TEXTURE_WIDTH/64 		; to keep track of the offset which corresponds to the frame within the bumpdata offset

_waitcounter			dc.w	20
_openTunnelWait			dc.w	0

tunnelEffect
	move.l	screenpointer,a0
	jsr		clear4bpl
	move.l	screenpointer2,a0
	jsr		clear4bpl
	move.l	screenpointer3,a0
	jsr		clear4bpl

	; install the vbl, nothing interesting
	move.w	#$2700,sr
	move.l	#c2p_close_curtain_vbl,$70
	move.w	#$2300,sr

	move.l	screenpointer,a0
	jsr		copyStayAtari
			exitOnSpace
	move.l	screenpointer2,a0
	jsr		copyStayAtari
			exitOnSpace
	move.l	screenpointer3,a0
	jsr		copyStayAtari
			exitOnSpace

	jsr		prepareChunkyTextureBPL1to2
			exitOnSpace
	jsr		generateC2PCode1to2		
			exitOnSpace	
	jsr		generateC2PCopyTunnel
			exitOnSpace

	jsr		swapTunnelPalettes

	move.l	#34*2,tunnel_c2poffset3n
	move.l	#33*2,tunnel_c2poffset2n
	move.l	#33*2,tunnel_c2poffset1n
	move.l	#34*2*160,tunnel_c2poffset3
	move.l	#33*2*160,tunnel_c2poffset2
	move.l	#33*2*160,tunnel_c2poffset1
	move.w	#1,c2pdirection1
	move.w	#0,c2pdirection3

waitx
		wait_for_vbl
		subq.w	#1,_waitcounter
	bne		waitx

	move.w	#1,greystart
	move.w	#39*2,greyend

	move.w	#$2700,sr
	move.l	#c2p_tunnel_curtain_vbl,$70
	move.w	#$2300,sr

openTunnel								; 17 fps
	move.l	screenpointer,$ffff8200
	jsr 	doTunnelEffectPartsStart
	jsr		copyLinesTunnel
	jsr		swapscreens_c2p
			exitOnSpace

	tst.w	_openTunnelWait
	bne		.tloop

	move.w	greystart,d0
	sub.w	greyend,d0
	cmp.w	#$25,d0
	bne		openTunnel

	move.w	#$2700,sr
	move.l	#c2p_tunnel_static_vbl,$70
	move.w	#$2300,sr

	addq.w	#1,_openTunnelWait

	jmp		openTunnel

.tloop
	addq.w	#1,_openTunnelWait
	cmp.w	#30,_openTunnelWait
	bne		openTunnel

introducteBlocks						; 16,5 
	move.l	screenpointer,$ffff8200
	jsr		clearCrap
	jsr 	doTunnelEffectPartsStart
	jsr		copyLinesTunnel
	jsr		moveBlocksInit
	jsr		swapscreens_c2p
			exitOnSpace
	tst.w	c2pinitdone
	beq		introducteBlocks

movetunnelinit:
	move.w	#$2700,sr
	move.l	#c2p_tunnel_dynamic_vbl,$70
	move.w	#$2300,sr

	move.l	#0,tunnel_c2poffset1
	move.l	#0,tunnel_c2poffset1n
	move.l	#34*2*160,tunnel_c2poffset2
	move.l	#34*2,tunnel_c2poffset2n
	move.l	#(33+34)*2*160,tunnel_c2poffset3
	move.l	#(33+34)*2,tunnel_c2poffset3n
	move.w	#0,c2pdirection1
	move.w	#0,c2pdirection2
	move.w	#1,c2pdirection3
	move.w	#1,c2pcodecounter
	move.w	#2,c2pcountdown

	jsr		swapTunnelPalettes

movetunnel:								; 16,42
	move.l	screenpointer,$ffff8200
	jsr		clearCrap
	jsr 	doTunnelEffectParts
	jsr		copyLinesTunnel
	jsr		moveBlocks
	jsr		swapscreens_c2p

	tst.w	c2pcodecounter
	bne		.continue
		subq.w	#1,c2pcountdown
		bne		.continue
			jmp		whole
.continue
	cmp.b 	#$39,$fffffc02.w
	bne		movetunnel
		move.w	#-1,demo_exit
		rts


whole										; 16.8
	move.l	#0,tunnel_c2poffset1
	move.l	#0,tunnel_c2poffset1n

	move.l	#34*2*160,tunnel_c2poffset2
	move.l	#34*2,tunnel_c2poffset2n

	move.l	#(33+34)*2*160,tunnel_c2poffset3
	move.l	#(33+34)*2,tunnel_c2poffset3n

	move.l	screenpointer,$ffff8200
	jsr 	doTunnelEffectWhole
	jsr		copyLinesTunnel
	jsr		swapscreens_c2p

	move.w	#33*2,c2p_tunnel_curtain_current_pos
	move.w	#33*2,c2p_tunnel_curtain_current_pos2

	move.w	#$2700,sr
	move.l	#c2p_tunnel_static_curtain_vbl,$70
	move.w	#$2300,sr

	jsr		fixStayAtari

	jsr		swapTunnelPalettes
	move.w	#0,vblcounter
	move.w	#0,effectcounter

normal
	move.l	screenpointer,$ffff8200
	jsr 	doTunnelEffectWhole
	jsr		copyLinesTunnel
	jsr		swapscreens_c2p

	addq.w	#1,effectcounter
	cmp.w	#100,effectcounter
	bne		.next
		move.w	#0,tunnelout
.next
	cmp.w	#140,effectcounter
	bne		.x
		move.l	backup_screenpointer2,screenpointer
		move.l	backup_screenpointer,screenpointer2
		move.l	alignpointer1,screenpointer3
		rts
.x
	cmp.b 	#$39,$fffffc02.w
	bne		normal
	move.w	#-1,demo_exit
	rts


;;;;;;;;;;;;;; TUNNEL ROUTS ;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL ROUTS ;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL ROUTS ;;;;;;;;;;;;
tunnelout
	dc.w	1

c2p_close_curtain_vbl
	addq.w 		#1,$466.w
	incSync
	addq.w	#1,vblcounter

	pushd0
	pusha0
	IFNE	playmusic
	IFNE	playmusicinvbl				
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	ENDC

	moveq	#0,d0
	lea		$ffff8240,a0
	rept 8
		move.l	d0,(a0)+
	endr

	cmp.w	#33*2,greystart
	beq		.noteq
		addq.w	#1,greystart
.noteq
	

	move.w	greystart,d0
	add.w	greyend,d0
	cmp.w	#(33+34)*2,d0
	ble		.noteq2
		subq.w	#2,greyend
.noteq2

	move.w	greystart,d0

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	#greycurtainstart,$120
	move.b	d0,$fffffa21.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa0
	popd0
	rte

greystart
	dc.w	1
greyend
	dc.w	198

c2p_tunnel_curtain_vbl
	addq.w 		#1,$466.w
	incSync
	addq.w	#1,vblcounter

	pushd0
	pusha0
	IFNE	playmusic
	IFNE	playmusicinvbl				
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	ENDC

	moveq	#0,d0
	lea		$ffff8240,a0
	rept 8
		move.l	d0,(a0)+
	endr

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#31*2,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #c2p_curtain1,$120.w        ;Install our own Timer B
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))


	move.w	greystart,d0
	sub.w	greyend,d0
	cmp.w	#$25,d0
	beq		.y
		addq.w	#1,greystart
		subq.w	#2,greyend
	popa0
	popd0
	rte

.y
	popa0
	popd0
	rte

c2p_curtain1
	pusha0
	pusha1
		lea		$ffff8240,a1
		lea		top_palette,a0
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
		pushd0
	move.w	greystart,d0
	sub.w	greyend,d0
	cmp.w	#$23,d0
	beq		.x

	move.w	greystart,d0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	d0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #grey_hbl,$120.w        ;Install our own Timer B
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0	
	popa1
	popa0
	rte

.x
	move.b	#0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	clr.b	$fffffa1b.w			;Timer B control (stop)
	popd0	
	popa1
	popa0
	
	rte

grey_hbl
	pushd0
	pusha1
		lea		$ffff8240,a1
		move.l	#$01110111,d0
		REPT 8
			move.l	d0,(a1)+
		ENDR
	move.w	greyend,d0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	d0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #c2p_curtain2,$120.w        ;Install our own Timer B
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa1
	popd0
	rte


c2p_curtain2
	pusha1
	pusha0
	lea		top_palette,a1
	lea		$ffff8240,a0
	rept 8
		move.l	(a1)+,(a0)+
	endr

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#0,$fffffa21.w
	popa0
	popa1
	rte


greycurtainstart
	pusha0
	pushd0
pm	move.l	#$01110111,d0
	lea		$ffff8240,a0
	REPT 8
	move.l	d0,(a0)+
	ENDR

	move.w	greyend,d0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#greycurtainend,$120
	move.b	d0,$fffffa21.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	popa0
	rte


greycurtainend
	pusha0
	pushd0
	moveq	#0,d0
	lea		$ffff8240,a0
	REPT 8
	move.l	d0,(a0)+
	ENDR
	popd0
	popa0
	rte


copyLinesTunnel
	move.l	screenpointer2,a6
	add.w	#160,a6
	move.l	c2pCopyPointerTunnel,a0
	jmp		(a0)

c2p_tunnel_static_vbl:
	addq.w 		#1,$466.w
	incSync
	addq.w	#1,vblcounter

	move.w	#0,$ffff8240
	pusha0

	IFNE	playmusic
	IFNE	playmusicinvbl				
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	ENDC

	pusha1
	pushd0
	lea		low_palette,a0
	lea		$ffff8240,a1
	rept 8
		move.l	(a0)+,(a1)+
	endr

	move.w	#33*2-4,d0

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	#black_lines1,$120
	move.b	d0,$fffffa21.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	popa1
	popa0
	rte

black_lines1
	pusha0
	pushd0
	lea		$ffff8242,a0
	moveq	#0,d0
	rept 7
		move.l	d0,(a0)+
	endr
	move.w	d0,(a0)+

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#top_palette_timer,$120
	move.b  #6,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
	popa0
	rte

top_palette_timer
	pusha0
	pusha1
	lea		$ffff8242,a0
	lea		top_palette+2,a1
	rept 7
		move.l	(a1)+,(a0)+
	endr
	move.w	(a1)+,(a0)+

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#black_lines2,$120
	move.b  #34*2,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa1
	popa0
	rte

black_lines2
	pusha0
	pushd0
	lea		$ffff8242,a0
	moveq	#0,d0
	rept 7
		move.l	d0,(a0)+
	endr
	move.w	d0,(a0)+

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#mid_palette_timer,$120
	move.b  #6,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
	popa0
	rte


mid_palette_timer
	pusha0
	pusha1
	lea		$ffff8242,a0
	lea		mid_palette+2,a1
	rept 7
		move.l	(a1)+,(a0)+
	endr
	move.w	(a1)+,(a0)+

	clr.b	$fffffa1b.w			;Timer B control (stop)
	popa1
	popa0
	rte


doTunnelEffectPartsStart
	jsr		prepareTunnelTexture
;;;;;;;;;;; ACTUAL DRAW CODE
	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset1,a6
	add.w	#160,a6
	move.l	generatedCodePointer,a0
	jsr		(a0)

	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset2,a6
	add.w	#160,a6
	move.l	generatedCode3Pointer,a0
	jsr		(a0)

	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset3,a6
	add.w	#160,a6
	move.l	generatedCode2Pointer,a0
	jsr		(a0)

	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset3,a6
	add.w	#160,a6
	jsr		doTunnelHole


;;;;;;;;;;;;;; TEXTURE ROTATION 
	jsr		moveTunnelTexture
	rts


doTunnelHole
	lea		tunnelhole,a0
	; we want to do this in the middle so erm; 320-64 = 256/2 = 128
	; 128/16 = 8, so 4 steps, 4*8 bytes
s	set 0
;d	set 4*8
	add.w	#8*8+5*160,a6
	REPT 53
		movem.l	(a0)+,d0-d7		; lets see; this is 8 registers, so 4x 16 pixels = 64
		and.l	d0,(a6)+
		and.l	d1,(a6)+
		and.l	d2,(a6)+
		and.l	d3,(a6)+
		and.l	d4,(a6)+
		and.l	d5,(a6)+
		and.l	d6,(a6)+
		and.l	d7,(a6)+
		add.l	#160-32,a6
	ENDR
	rts

c2pinitdone			dc.w	0
tunnel_c2poffset1n	dc.l	0
tunnel_c2poffset2n	dc.l	34*2
tunnel_c2poffset3n	dc.l	(33+34)*2	
tunnel_c2poffset1	dc.l	0
tunnel_c2poffset2	dc.l	34*2*160
tunnel_c2poffset3	dc.l	(33+34)*2*160
c2pdirection1		dc.w	0
c2pdirection2		dc.w	0
c2pdirection3		dc.w	1
c2pcodecounter		dc.w	1
c2pcountdown		dc.w	3

c2p_tunnel_curtain_current_pos		dc.w	99
c2p_tunnel_curtain_current_pos2		dc.w	0

timer_b_pointer
	ds.l	1

timer_b_raster_pointer
	ds.l	1

top_palette
	dc.w	$000,$101,$212,$323,$434,$544,$654,$653,$663,$764,$774,$223,$445,$566,$777,$000	;	0
	dc.w	$000,$101,$212,$323,$434,$543,$543,$543,$553,$654,$664,$223,$445,$566,$777,$000	;	32
	dc.w	$000,$000,$211,$212,$323,$432,$442,$432,$442,$544,$553,$223,$445,$566,$777,$000	;	64
	dc.w	$000,$000,$100,$101,$212,$321,$331,$322,$331,$433,$443,$223,$445,$566,$777,$000	;	96
	dc.w	$000,$000,$000,$000,$101,$210,$220,$211,$221,$322,$332,$223,$445,$566,$777,$000	;	128	
	dc.w	$000,$000,$000,$000,$000,$100,$110,$100,$110,$211,$221,$112,$445,$566,$777,$000	;	160
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$110,$001,$445,$566,$777,$000	;	192
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$445,$566,$777,$000	;	224
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$445,$566,$777,$000	;	256
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$334,$455,$666,$000	;	288
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$223,$344,$555,$000	;	320
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$112,$233,$444,$000	;	352
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$122,$333,$000	;	384
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$011,$222,$000	;	416
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$111,$000	;	448
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	480
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	480
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	480




mid_palette
	dc.w	$000,$100,$211,$322,$433,$543,$653,$652,$662,$763,$773,$222,$444,$565,$777,$000
low_palette
	dc.w	$000,$200,$311,$422,$533,$643,$753,$752,$762,$763,$773,$322,$544,$665,$777,$000
tmp_palette			
	ds.b	16*2



swapTunnelPalettes
	movem.l	top_palette,d0-d7
	movem.l	d0-d7,tmp_palette
	movem.l	mid_palette,d0-d7
	movem.l	d0-d7,top_palette
	movem.l	tmp_palette,d0-d7
	movem.l	d0-d7,mid_palette
	rts

;codeTemplate
;	move.l	1234(a1),d0			; 2029 04D2
;	or.l	1234(a2),d0			; 80AA 04D2
;	or.l	1234(a3),d0			; 80AB 04D2
;	or.l	1234(a4),d0			; 80AC 04D2
;	movep.l	d0,1234(a6)			; 01CE 04D2

;	move.l	1234(a1),d0			; 2029 04D2
;	or.l	1234(a2),d0			; 80AA 04D2
;	or.l	1234(a3),d0			; 80AB 04D2
;	or.l	1234(a4),d0			; 80AC 04D2
;	movep.l	d0,1234(a6)			; 01CE 04D2	;--> 40 bytes for 16 pixels

generateC2PCode1to2
	move.l	#$20290000,d0	;	move.l	x(a1),d0
	move.l	#$80AA0000,d1	;	or.l	x(a2),d0
	move.l	#$80AB0000,d2	;	or.l	x(a3),d0
	move.l	#$80AC0000,d3	;	or.l	x(a4),d0
	move.l	#$01CE0000,d4	;	movep.l	d0,x(a6)
	lea		tunnel_offsmap,a5		; generated b_off (bumpmap offsets)

	move.l	generatedCodePointer,a0
	move.l	#33-1,d7 	;height					;200/3 = 33,34,33
	jsr		generateC2PCode

	move.l	generatedCode2Pointer,a0
	move.l	#34-1,d7
	move.w	#0,d4
	jsr		generateC2PCode

	move.l	generatedCode3Pointer,a0
	move.l	#33-1,d7
	move.w	#0,d4
	jsr		generateC2PCode

	move.l	generatedCodeWholePointer,a0
	lea		tunnel_offsmap,a5		; generated b_off (bumpmap offsets)
	move.l	#100-1,d7
	move.w	#0,d4
	jsr		generateC2PCode
	rts


generateC2PCode
.doline
	REPT TUNNEL_VIEWPORT_WIDTH		; do this for the number of 16x blocks
		move.w	(a5)+,d0			; get next b_off in x														
		move.l	d0,(a0)+			; move.l x(a1),d0
		move.w	(a5)+,d1			; get next b_off in x															
		move.l	d1,(a0)+			; or.l	x(a2),d0
		move.w	(a5)+,d2			; get next b_off in x															
		move.l	d2,(a0)+			; or.l	x(a3),d0
		move.w	(a5)+,d3			; get next b_off in x															
		move.l	d3,(a0)+			; or.l	x(a4),d0
		move.l	d4,(a0)+			; movep.l	d0,y1(a6)			; 5*4 = 20
		addq.w	#1,d4				; add offset +1 for movep

		move.w	(a5)+,d0			; get next b_off in x														
		move.l	d0,(a0)+			; move.l x(a1),d0
		move.w	(a5)+,d1			; get next b_off in x															
		move.l	d1,(a0)+			; or.l	x(a2),d0
		move.w	(a5)+,d2			; get next b_off in x															
		move.l	d2,(a0)+			; or.l	x(a3),d0
		move.w	(a5)+,d3			; get next b_off in x															
		move.l	d3,(a0)+			; or.l	x(a4),d0
		move.l	d4,(a0)+			; movep.l	d0,y1(a6)			; 5*4 = 20
		addq.w	#7,d4				; add offset +7 for movep
	ENDR
	; jump to the next 2 lines, take into account what we already added to d5 and d6
	add.w	#320-(8*TUNNEL_VIEWPORT_WIDTH),d4
	dbra	d7,.doline
	move.w	#$4e75,(a0)+		;rts of course
	rts

c2p_tunnel_dynamic_vbl:	
	addq.w 		#1,$466.w
	incSync
	addq.w	#1,vblcounter
	move.w	#0,$ffff8240

	IFNE	playmusic
	IFNE	playmusicinvbl				
		pusha0
		move.l	sndh_pointer,a0
		jsr		8(a0)
		popa0
	ENDC
	ENDC

	jsr		fixTimers
	rte

timerblist
	ds.b	30
timerboffset
	ds.w	1


fixTimers
	movem.l	d0-d7/a0-a1,-(sp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	move.l	tunnel_c2poffset3n,d0		; first offset
	tst.w	c2pdirection3
	bne		.x3n
		sub.l	#4,d0
.x3n
	move.l	d0,d1
	add.l	#33*2,d1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	move.l	tunnel_c2poffset2n,d2
	tst.w	c2pdirection2
	bne		.x2n
		sub.l	#4,d2
.x2n
	move.l	d2,d3
	add.l	#33*2,d3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	move.l	tunnel_c2poffset1n,d4
	tst.w	c2pdirection1
	bne		.x1n
		sub.l	#4,d4
.x1n
	move.l	d4,d5
	add.l	#33*2,d5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;	FACT:
;	moveq	#1,d0
;	moveq	#2,d1
;	cmp.l	d0,d1
;	bgt		.x			--> true


	; sort 3 areas
	lea		timerblist,a0

;	if($top_start <= $mid_start){
	cmp.w	d2,d0
	bgt		.mid_before_top
;		if($top_start <= $low_start){
		cmp.w	d4,d0
		bgt		.low_top_mid
;			if($mid_start <= $low_start){				// top-mid-low
			cmp.w	d4,d2
			bgt		.top_low_mid
.top_mid_low
				move.l	#top_palette,a1
				sub.w	d1,d3
				sub.w	#4,d3
				bgt		.ok3
					move.w	d1,(a0)+
					move.l	#low_palette,(a0)+
					move.w	#0,(a0)
					jmp		.timers_order_done
.ok3
				move.w	d1,(a0)+				; schedule top_end
				move.l	#mid_palette,(a0)+
				move.w	d3,(a0)+				; schedule mid_end
				move.l	#low_palette,(a0)+
				move.w	#0,(a0)					; end
				jmp		.timers_order_done
;			}
;			else{		// top-low-mid
.top_low_mid
			; we need to check, if the low is not overlapped
			; we know, top_start < low_start < mid_start
			; we need to know, if low_end <= mid_start
			cmp.w	d5,d2
				move.l	#top_palette,a1
				move.w	d1,(a0)+				; schedule top_end
				move.l	#mid_palette,(a0)+
				move.w	#0,(a0)
				jmp		.timers_order_done
;			}
;		}
;		else{			// low,top,mid
.low_top_mid
			move.l	#low_palette,a1
			sub.w	d0,d1
			sub.w	#3,d1
			bgt		.okd1
				move.w	d0,(a0)+
				move.l	#top_palette,(a0)+
				move.w	#0,(a0)
				jmp		.timers_order_done
.okd1
			move.w	d0,(a0)+
			move.l	#top_palette,(a0)+
			move.w	d1,(a0)+
			move.l	#mid_palette,(a0)+
			move.w	#0,(a0)
			jmp		.timers_order_done
;		}
;	}
;	else{		// mid is before top
.mid_before_top
;	if($mid_start <= $low_start){	// mid,top
	cmp.w	d4,d2
	bgt		.low_mid_top
;		if($top_start <= $low_start){				// mid, top, low
		cmp.w	d4,d0
		bgt		.mid_low_top
.mid_top_low
			move.l	#mid_palette,a1
			sub.w	d0,d1
			sub.w	#3,d1
			bgt		.okd12

				move.w	d0,(a0)+
				move.l	#top_palette,(a0)+
				move.w	#0,(a0)
				jmp		.timers_order_done
.okd12
			move.w	d0,(a0)+
			move.l	#top_palette,(a0)+
			move.w	d1,(a0)+
			move.l	#low_palette,(a0)+
			move.w	#0,(a0)
			jmp		.timers_order_done
;		}
;		else{			// mid, low, top
.mid_low_top
			move.l	#mid_palette,a1
				move.w	d3,(a0)+
				move.l	#top_palette,(a0)+
				move.w	#0,(a0)
				jmp		.timers_order_done
;		}
;	}
;	else{				// low,mid,top
.low_mid_top
		move.l	#low_palette,a1
		sub.w	d2,d0
		sub.w	#4,d0
		bgt		.ok
			move.w	d2,(a0)+
			move.l	#top_palette,(a0)+
			move.w	#0,(a0)
			jmp		.timers_order_done
.ok	
		move.w	d2,(a0)+
		move.l	#mid_palette,(a0)+
		move.w	d0,(a0)+
		move.l	#top_palette,(a0)+
		move.w	#0,(a0)

.timers_order_done

	lea		$ffff8240,a0
	REPT 8
		move.l	(a1)+,(a0)+
	ENDR
	

	lea		timerblist,a0
	move.w	(a0)+,d0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	#black_line_timer,$120
	move.b	d0,$fffffa21.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	move.l	a0,timer_b_pointer

	movem.l	(sp)+,d0-d7/a0-a1
	rts

black_line_timer	
	pusha0
	pushd0
	lea		$ffff8240,a0
	moveq	#0,d0
	rept 8
		move.l	d0,(a0)+
	endr

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#next_pal_timer,$120
	move.b  #6,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	move.l	timer_b_pointer,a0
	move.l	(a0)+,timer_b_raster_pointer
	move.l	a0,timer_b_pointer

	popd0
	popa0
	rte


next_pal_timer
	pusha0
	pusha1
	lea		$ffff8240,a0						;8
	move.l	timer_b_raster_pointer,a1			;16
	rept 8
		move.l	(a1)+,(a0)+
	endr
	pushd0

	move.l	timer_b_pointer,a0
	move.w	(a0)+,d0
	beq		.stoptimer


	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#black_line_timer,$120
	move.b  d0,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	move.l	a0,timer_b_pointer

	popd0
	popa1
	popa0
	rte


.stoptimer
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b  #0,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	popd0
	popa1
	popa0
	rte

prepareChunkyTextureBPL1to2
	moveq	#0,d0

	lea		texture,a0
	lea		TAB1,a1
	move.l	planartexturepointer1,a2
	jsr		generatePlanarTexture

	lea		texture,a0
	lea		TAB2,a1
	move.l	planartexturepointer2,a2
	jsr		generatePlanarTexture

	lea		texture,a0
	lea		TAB3,a1
	move.l	planartexturepointer3,a2
	jsr		generatePlanarTexture

	lea		texture,a0
	lea		TAB4,a1
	move.l	planartexturepointer4,a2
	jsr		generatePlanarTexture
	rts

generatePlanarTexture
	move.l	#TUNNEL_TEXTURE_WIDTH*TUNNEL_TEXTURE_HEIGHT-1,d7
	move.l	d7,d6
	move.l	a0,a3

	add.l	#TUNNEL_TEXTURE_WIDTH*TUNNEL_TEXTURE_HEIGHT,a3
	jsr		generateTexture
	jsr		generateTexture

	sub.l	#TUNNEL_TEXTURE_WIDTH*TUNNEL_TEXTURE_HEIGHT,a3
	jsr		generateTexture
	jsr		generateTexture

	add.l	#TUNNEL_TEXTURE_WIDTH*TUNNEL_TEXTURE_HEIGHT,a3
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

clearCrap
	move.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
;;;;;;;;;; clear 1
	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset1,a6
	; lets clean some shit
	tst.w	c2pdirection1
	bne		.moveup1
.movedown1
		; clear one line above
		sub.l	#160*6-6*20*8,a6
	jmp	.clear1
.moveup1
		add.l	#33*2*160+6*20*8,a6
.clear1
		REPT 17							; 17 * 14 = 
		movem.l	d0-d7/a0-a5,-(a6)
		ENDR
		move.l	d0,-(a6)
		move.l	d0,-(a6)
;;;;;;;;;;; clear2
		move.l	screenpointer2,a6
		add.l	tunnel_c2poffset2,a6
	; lets clean some shit
	tst.w	c2pdirection2
	bne		.moveup2
.movedown2
		; clear one line above
		sub.l	#160*6-6*20*8,a6
	jmp	.clear2
.moveup2
		add.l	#34*2*160+6*20*8,a6
.clear2
		REPT 17							; 17 * 14 = 
		movem.l	d0-d7/a0-a5,-(a6)
		ENDR
		move.l	d0,-(a6)
		move.l	d0,-(a6)
;;;;;;;;;;; clear3
		move.l	screenpointer2,a6
		add.l	tunnel_c2poffset3,a6
	; lets clean some shit
	tst.w	c2pdirection3
	bne		.moveup3
.movedown3
		; clear one line above
		sub.l	#160*6-6*20*8,a6
		jmp	.clear3
.moveup3
	add.l	#33*2*160+6*20*8,a6
.clear3
		REPT 17							; 17 * 14 = 
		movem.l	d0-d7/a0-a5,-(a6)
		ENDR
	move.l	d0,-(a6)
	move.l	d0,-(a6)
	rts

doTunnelEffectParts
	jsr		prepareTunnelTexture
;;;;;;;;;;; ACTUAL DRAW CODE
	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset1,a6
	add.w	#160,a6
	move.l	generatedCodePointer,a0
	jsr		(a0)

	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset2,a6
	add.w	#160,a6
	move.l	generatedCode2Pointer,a0
	jsr		(a0)

	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset2,a6
	add.w	#160,a6
	jsr		doTunnelHole

	move.l	screenpointer2,a6
	add.l	tunnel_c2poffset3,a6
	add.w	#160,a6
	move.l	generatedCode3Pointer,a0
	jsr		(a0)

;;;;;;;;;;;;;; TEXTURE ROTATION 
	jsr		moveTunnelTexture
	rts

doTunnelEffectWhole
	jsr		prepareTunnelTexture
;;;;;;;;;;; ACTUAL DRAW CODE
	move.l	screenpointer2,a6
	add.w	#160,a6
	move.l	generatedCodeWholePointer,a0
	jsr		(a0)

	move.l	screenpointer2,a6
	add.w	#72*160,a6
	jsr		doTunnelHole

;;;;;;;;;;;;;; TEXTURE ROTATION 
	jsr		moveTunnelTexture
	rts

moveBlocksInit
;;;;;;;;;; c2p block 1 ;;;;;;;;;;;;
	tst.w	c2pdirection1
	bne		.up1
.down1
	add.l	#160*2,tunnel_c2poffset1
	add.l	#2,tunnel_c2poffset1n
	; thing is 33 hight, which is 66 lines, so max height: 200-66= 134
	cmp.l	#160*134,tunnel_c2poffset1
	bne		.done1
		move.w	#-1,c2pdirection1
		jmp		.done1
.up1
	sub.l	#160*2,tunnel_c2poffset1
	sub.l	#2,tunnel_c2poffset1n
	bne		.done1
		move.w	#0,c2pdirection1
		subq.w	#1,c2pcodecounter
.done1

;;;;;;;;;; c2p block 2 ;;;;;;;;;;;;
	tst.w	c2pdirection2
	bne		.up2
.down2
	add.l	#160*2,tunnel_c2poffset2
	add.l	#2,tunnel_c2poffset2n
	; thing is 33 hight, which is 66 lines, so max height: 200-66= 134
	cmp.l	#160*134,tunnel_c2poffset2
	bne		.done2
		move.w	#-1,c2pdirection2
		move.w	#1,c2pinitdone
		jmp		.done2
.up2
	sub.l	#160*2,tunnel_c2poffset2
	sub.l	#2,tunnel_c2poffset2n
	bne		.done2
		move.w	#0,c2pdirection2
.done2
	rts

moveBlocks
;;;;;;;;;; c2p block 1 ;;;;;;;;;;;;
	tst.w	c2pdirection1
	bne		.up1
.down1
	add.l	#160*2,tunnel_c2poffset1
	add.l	#2,tunnel_c2poffset1n
	; thing is 33 hight, which is 66 lines, so max height: 200-66= 134
	cmp.l	#160*134,tunnel_c2poffset1
	bne		.done1
		move.w	#-1,c2pdirection1
		jmp		.done1
.up1
	sub.l	#160*2,tunnel_c2poffset1
	sub.l	#2,tunnel_c2poffset1n
	bne		.done1
		move.w	#0,c2pdirection1
		subq.w	#1,c2pcodecounter
.done1

;;;;;;;;;; c2p block 2 ;;;;;;;;;;;;
	tst.w	c2pdirection2
	bne		.up2
.down2
	add.l	#160*2,tunnel_c2poffset2
	add.l	#2,tunnel_c2poffset2n
	; thing is 33 hight, which is 66 lines, so max height: 200-66= 134
	cmp.l	#160*134,tunnel_c2poffset2
	bne		.done2
		move.w	#-1,c2pdirection2
		jmp		.done2
.up2
	sub.l	#160*2,tunnel_c2poffset2
	sub.l	#2,tunnel_c2poffset2n
	bne		.done2
		move.w	#0,c2pdirection2
.done2


;;;;;;;;;; c2p block 3 ;;;;;;;;;;;;
	tst.w	c2pdirection3
	bne		.up3
.down3
	add.l	#160*2,tunnel_c2poffset3
	add.l	#2,tunnel_c2poffset3n
	; thing is 33 hight, which is 66 lines, so max height: 200-66= 134
	cmp.l	#160*134,tunnel_c2poffset3
	bne		.done3
		move.w	#-1,c2pdirection3
		jmp		.done3
.up3
	sub.l	#160*2,tunnel_c2poffset3
	sub.l	#2,tunnel_c2poffset3n
	bne		.done3
		move.w	#0,c2pdirection3
.done3
	rts

c2p_curtain_delta	dc.w	1
c2p_c 				dc.w	4

c2p_tunnel_static_curtain_vbl
	addq.w 		#1,$466.w
	incSync
	addq.w	#1,vblcounter

	movem.l	d0/d1/a0/a1,-(sp)

	IFNE	playmusic
	IFNE	playmusicinvbl				
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	ENDC

	move.w	c2p_tunnel_curtain_current_pos,d0
	subq.w	#6,d0

	move.w	c2p_curtain_delta,d1

	sub.w	d1,c2p_tunnel_curtain_current_pos
	cmp.w	#1,c2p_tunnel_curtain_current_pos				;bgt			!TODO
	bge		.gogo
		move.w	#1,c2p_tunnel_curtain_current_pos
		lea		top_palette+2,a0
		lea		$ffff8242,a1
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+

		move.w	#$2700,sr
		move.l	#c2p_tunnel_stay_atari,$70
		move.w	#$2300,sr
		movem.l	(sp)+,d0/d1/a0/a1
		rte
.gogo

	add.w	d1,d1
	add.w	d1,c2p_tunnel_curtain_current_pos2
	cmp.w	#199,c2p_tunnel_curtain_current_pos2
	ble		.gogo2
		move.w	#199,c2p_tunnel_curtain_current_pos2
.gogo2

	subq.w	#1,c2p_c
	bne		.xx
		addq.w	#1,c2p_curtain_delta
		move.w	#4,c2p_c
.xx


		lea		$ffff8242,a1
		lea		low_palette+2,a0
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+



	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	d0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #c2p_static_curtain1,$120.w        ;Install our own Timer B
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	movem.l	(sp)+,d0/d1/a0/a1
	rte

c2p_static_curtain1
	pusha0
	pushd0
	lea		$ffff8242,a0
	moveq	#0,d0
	rept 7
		move.l	d0,(a0)+
	endr
	move.w	d0,(a0)+

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#top_palette_timer_curtain,$120
	move.b  #6,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	popa0
	rte

top_palette_timer_curtain
	pusha0
	pusha1
		lea	top_palette+2,a0
		lea	$ffff8242,a1
		rept 7
			move.l	(a0)+,(a1)+
		endr
		move.w	(a0),(a1)
	pushd0

	move.w	c2p_tunnel_curtain_current_pos2,d0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#c2p_static_curtain2,$120
	move.b  d0,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	popa1
	popa0
	rte

c2p_static_curtain2
	pusha0
	pushd0
	lea		$ffff8242,a0
	moveq	#0,d0
	rept 7
		move.l	d0,(a0)+
	endr
	move.w	d0,(a0)+

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#mid_palette_timer_curtain,$120
	move.b  #6,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
	popa0
	rte


mid_palette_timer_curtain
	pusha0
	pusha1
		lea	mid_palette+2,a0
		lea	$ffff8242,a1
		rept 7
			move.l	(a0)+,(a1)+
		endr
		move.w	(a0),(a1)
	pushd0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b  #0,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	popd0
	popa1
	popa0
	rte

texturescroll	dc.l	0


prepareTunnelTexture
	move.l	planartexturepointer1,a1
	move.l	planartexturepointer2,a2
	move.l	planartexturepointer3,a3
	move.l	planartexturepointer4,a4

	; this is the offset for the changing texture
	move.l	texturescroll,d0
	add.l	d0,a1
	add.l	d0,a2
	add.l	d0,a3
	add.l	d0,a4

	add.l	#64*4,texturescroll
	cmp.l	#64*64*4*2,texturescroll
	bne		.gogogo
		move.l	#0,texturescroll
.gogogo

	; this is the offset for the moving tunneleffect
	move.l	_tunneloffset,d0
	add.l	d0,a1
	add.l	d0,a2
	add.l	d0,a3
	add.l	d0,a4
	rts

moveTunnelTexture
	; y, rotation
	add.l	#TUNNEL_TEXTURE_WIDTH*4,_tunneloffset
	; x, zoom
	add.l	#4*2,_tunneloffset

	move.l	#TUNNEL_TEXTURE_WIDTH*4*TUNNEL_TEXTURE_WIDTH*2,d0
	move.l	d0,d1
	add.l	texturescroll,d0

	cmp.l	_tunneloffset,d0
	bge		.noloop
		sub.l	d1,_tunneloffset
.noloop
	rts


c2p_tunnel_stay_atari
	addq.w 		#1,$466.w
	incSync
	addq.w	#1,vblcounter

	pusha0
	pusha1
	pushd0

	IFNE	playmusic
	IFNE	playmusicinvbl				
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	ENDC

	tst.w	tunnelout
	bne		.normal
		subq.w	#1,_tunnel_out_palette_counter
		bne		.notzero
			move.w	#7,_tunnel_out_palette_counter
			cmp.w	#480,_top_palette_off
			bge		.cont
			add.w	#32,_top_palette_off
.cont
.notzero
		lea		top_palette,a0
		add.w	_top_palette_off,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
		jmp		.palettedone
.normal

	lea		top_palette,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
.palettedone
	move.w	#199,d0

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l  #open_lower_border,$120.w        ;Install our own Timer B
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	popa1
	popa0
	rte

_top_palette_off				dc.w	0
_tunnel_out_palette_counter		dc.w	7

fixStayAtari
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.l	screenpointer3,a2

	move.l	#3-1,d7
	add.l	#202*160,a0
	add.l	#202*160,a1
	add.l	#202*160,a2

	; 4 lines done
	lea		stforever,a4
	move.l	#6+4,d7
.ol2
	REPT 5
		movem.l	(a4)+,d0-d6
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d1,(a0)+
		move.l	d1,(a1)+
		move.l	d1,(a2)+

		move.l	d2,(a0)+
		move.l	d2,(a1)+
		move.l	d2,(a2)+
		move.l	d3,(a0)+
		move.l	d3,(a1)+
		move.l	d3,(a2)+

		move.l	d4,(a0)+
		move.l	d4,(a1)+
		move.l	d4,(a2)+
		move.l	d5,(a0)+
		move.l	d5,(a1)+
		move.l	d5,(a2)+

		move.l	d6,(a0)+
		move.l	d6,(a1)+
		move.l	d6,(a2)+
		move.l	(a4)+,d6
		move.l	d6,(a0)+
		move.l	d6,(a1)+
		move.l	d6,(a2)+
	ENDR
	dbra	d7,.ol2
	rts


copyStayAtari
	lea		stforever,a1
	add.l	#202*160,a0
	move.l	#28-1,d7
.ol
y set 0
		REPT 20
			move.l	(a1)+,y(a0)	;+	; 20*20*12	=> 4800
			move.l	(a1)+,y+4(a0)	;+	; 20*20*12	=> 4800
y set y+8
		ENDR
		add.w	#160,a0
		dbra	d7,.ol
	rts


open_lower_border
	move.w	#$2700,sr
	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w
   	pushd0
   	pusha0
   	pusha1
	move.b  $FFFFFA21.w,D0
tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   tb_sync

 
    move.b  #0,$FFFF820A.w  
    	lea		foreverpallete(pc),a0			;8
    	add.w	_foreverpallette_offset,a0
    	nop
    	nop
    	lea		$ffff8240,a1
    	move.l	(a0)+,(a1)+					;20

    move.b  #2,$FFFF820A.w  ; 50 hz

    	move.l	(a0)+,(a1)+					;20
    	move.l	(a0)+,(a1)+					;20
    	move.l	(a0)+,(a1)+					;20
    	move.l	(a0)+,(a1)+					;20
    	move.l	(a0)+,(a1)+					;20
    	move.l	(a0)+,(a1)+					;20
    	move.l	(a0)+,(a1)+					;20
 		

 	popa1
 	popa0
	popd0 
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l  #stay_atari_pal2,$120.w        ;Install our own Timer B
	move.b	#16,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))


    rte

_foreverpallette_offset		dc.w	0

stay_atari_split
	move.w	#$700,$ffff8240
    move.b  #0,$fffffa1b.w    
    rte

stay_atari_pal2
	move.w	#$2700,sr
	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w
   	movem.l	d0-d7/a0-a2,-(sp)
   	lea		$ffff8240,a1
   	lea		foreverpallete2,a0
   	add.w	_foreverpallette_offset,a0
   	movem.l	(a0),d1-d7/a2
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync
    movem.l	d1-d7/a2,(a1)
 	clr.b	$fffffa1b.w			;Timer B control (stop)
   
   	cmp.w	#224,_foreverpallette_offset
   	beq		.cont
 	cmp.w	#480,_top_palette_off
	bne		.cont
		subq.w	#1,_foreverpallette_offset_timer
		bne		.cont
		move.w	#2,_foreverpallette_offset_timer
		move.w	_top_palette_off,d0
		add.w	#32,_foreverpallette_offset
.cont
	movem.l	(sp)+,d0-d7/a0-a2
	rte

_foreverpallette_offset_timer	dc.w	2

foreverpallete
	dc.w	$000,$300,$510,$620,$730,$740,$750,$760,$761,$762,$763,$765,$766,$777,$400,$012			;0
	dc.w	$000,$200,$400,$510,$620,$630,$640,$650,$651,$652,$653,$654,$655,$666,$300,$001			;32
	dc.w	$000,$100,$300,$400,$510,$520,$530,$540,$540,$541,$542,$543,$544,$555,$200,$000			;64
	dc.w	$000,$000,$200,$300,$400,$410,$420,$430,$430,$430,$431,$432,$433,$444,$100,$000			;96
	dc.w	$000,$000,$100,$200,$300,$300,$310,$320,$320,$320,$321,$321,$322,$333,$000,$000			;128
	dc.w	$000,$000,$000,$100,$200,$200,$210,$210,$220,$220,$221,$221,$221,$222,$000,$000			;160
	dc.w	$000,$000,$000,$000,$100,$100,$100,$100,$110,$110,$111,$111,$111,$111,$000,$000			;192
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000			;224
foreverpallete2
	dc.w	$000,$010,$120,$230,$340,$440,$550,$560,$660,$670,$770,$773,$776,$777,$000,$012			;0
	dc.w	$000,$000,$010,$120,$230,$330,$440,$450,$550,$560,$660,$662,$665,$666,$000,$001			;32
	dc.w	$000,$000,$000,$010,$120,$220,$330,$340,$440,$450,$550,$551,$554,$555,$000,$000			;64
	dc.w	$000,$000,$000,$000,$010,$110,$220,$230,$330,$340,$440,$441,$443,$444,$000,$000			;96
	dc.w	$000,$000,$000,$000,$000,$000,$110,$120,$220,$230,$330,$331,$332,$333,$000,$000			;128
	dc.w	$000,$000,$000,$000,$000,$000,$000,$010,$110,$120,$220,$221,$222,$222,$000,$000			;160
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$110,$110,$111,$111,$000,$000			;192
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000			;224


;;;;;;;;;;;;;; TUNNEL END ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL END ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL END ;;;;;;;;;;;;;;



;;;;;;;;;;;;;; CURSORFADE START ;;;;;;;;
;;;;;;;;;;;;;; CURSORFADE START ;;;;;;;;
;;;;;;;;;;;;;; CURSORFADE START ;;;;;;;;
cursorFade
	jsr setShitBlack

    jsr   part_diag_cursors
    tst.w	demo_exit
    bne		.end
    moveq   #10,D7          ; no of vbls to wait
.w	
    		wait_for_vbl
    dbra	d7,.w

    jsr     part_raster
    tst.w	demo_exit
    bne		.end

  	move.w	#$2700,sr
  	move.l	#cinemaTimer,$70
  	move.w	#$2300,sr
  	wait_for_vbl

	move.l	screenpointer,a0
	move.l	#0,d0
	move.l	#800-1,d7
.c
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.c

    moveq   #6,D7           ; no of vbls to wait
    jsr		wait


    jsr     top_raster
    tst.w	demo_exit
    bne		.end

    move.l	screenpointer,a0
    jsr		clear4bpl

	move.w	#$2700,sr
	move.l 	#default_vbl2,$70
	move.w	#$2300,sr

.end
	rts
;;;;;;;;;;;;;; CURSORFADE ROUT ;;;;;;;;
;;;;;;;;;;;;;; CURSORFADE ROUT ;;;;;;;;
;;;;;;;;;;;;;; CURSORFADE ROUT ;;;;;;;;
cinemaTimer
	addq.w		#1,$466.w
	incSync
	move.w	#-1,$ffff8240
    move.b  #0,$fffffa1b.w    
	move.l	#startb,$120.w
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
   		pusha0
		move.l	sndh_pointer,a0
		jsr		8(a0)
		popa0

    rte

startb
	move.w	#0,$ffff8240

    move.b  #0,$fffffa1b.w    
	move.l	#startb2,$120.w
    move.b  #199,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
    rte

startb2
	move.w	#-1,$ffff8240
    move.b  #0,$fffffa1b.w    
   	rte

part_diag_cursors:
    st      startpos_flag_2 ; cursor in the lower right corner
    st      position_flag_2 ; starts in lowbyte of the word

    jsr   prepare_cursor_pos
    jsr   prepare_counter

number_diag_loop:
    moveq   #5-1,D6         ; counter: animation steps
draw_diag_animation:
    move.l  cursor_startpos,D0
    move.l  D0,cursor_pos

    move.l  cursor_startpos_2,D0
    move.l  D0,cursor_pos_2

draw_diag_loop:
    jsr     draw_cursor     ; upper left corner
    jsr     draw_cursor_2   ; lower right corner

    jsr     calc_cursorpos  ; upper left corner
    jsr     calc_cursorpos_2 ; lower right corner

    dbra    D7,draw_diag_loop

	cmp.b 	#$39,$fffffc02.w
	bne		.ok
		move.w	#-1,demo_exit
		rts
.ok

    jsr     wvbl

    jsr    restore_counter_1

    dbra    D6,draw_diag_animation

    jsr     calc_cursor_startpos
    jsr     calc_cursor_startpos_2

    jsr	   restore_counter_2 ; for the diag line

    tst.b   D7              ; end of table?
    bpl.s   number_diag_loop

    rts

*******************************************************************************

prepare_cursor_pos:
; upper left
				move.l	screenpointer,a0
;                movea.l scr_adr,A0  ; get screen address
                lea     160(A0),A0      ; start in 2nd line
                move.l  A0,cursor_startpos ; start of the line
                move.l  A0,cursor_pos   ; start of the individual cursor
; lower right
				move.l	screenpointer,a0
;                movea.l scr_adr,A0
                lea     193*160(A0),A0  ; not 192 due to timer b (no line 0!)
                lea     152(A0),A0      ; adjust to lower right corner

                move.l  A0,cursor_startpos_2 ; start of the line
                move.l  A0,cursor_pos_2 ; start of the individual cursor

                rts

prepare_counter:
                moveq   #0,D7
                lea     table_nr_cursors,A2 ; point to tab with counter
                move.b  (A2),D7         ; get first counter (nr of diag cursors)
                subq.b  #1,D7           ; make it dbra compabible

                rts

restore_counter_1:                      ; restores loopcounter during animation
                addi.w  #8,cursordata_offset ; next animation step

                moveq   #0,D7
                move.b  (A2),D7         ; get new counter (nr of diag cursors)
                subq.b  #1,D7           ; make it dbra compatible

                rts

restore_counter_2:                      ; restores loopcounter after animation is done
                moveq   #0,D7
                addq.w  #1,A2           ; point to next counter tab entry
                move.b  (A2),D7         ; get new counter (nr of diag cursors)
                subq.b  #1,D7           ; make it dbra compatible

                move.w  #0,cursordata_offset ; back to first animation step

                rts

                addi.w  #8,cursordata_offset ; next animation step

                moveq   #0,D7
                move.b  (A2),D7         ; get new counter (nr of diag cursors)
                subq.b  #1,D7           ; make it dbra compatible


table_nr_cursors:
                DC.B 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
                DC.B 21,22,23,24,25,25,25,25,25,25,25,25

                DC.B -1
    even
********************************************************************************

wvbl:           clr.l   $466.w
wvbl_wait:      tst.l   $466.w
                beq.s   wvbl_wait

                rts

********************************************************************************

calc_cursorpos: movea.l cursor_pos,A0
                tst.b   position_flag
                beq.s   calc_rightpos

calc_leftpos:   subq.l  #1,A0           ; zeiger auf lowbyte
                lea     8*160(A0),A0    ; 8 zeilen nach unten verschieben
                move.l  A0,cursor_pos

                sf      position_flag

                rts

calc_rightpos:  subq.l  #7,A0           ; zeiger auf highbyte des letzten words
                lea     8*160(A0),A0    ; 8 zeilen nach unten
                move.l  A0,cursor_pos

                st      position_flag

                rts

********************************************************************************

calc_cursorpos_2:                       ; lower right corner
                movea.l cursor_pos_2,A0
                tst.b   position_flag_2
                beq.s   calc_rightpos_2

calc_leftpos_2: addq.l  #1,A0           ;
                lea     -8*160(A0),A0   ; 8 zeilen nach oben verschieben
                move.l  A0,cursor_pos_2

                sf      position_flag_2

                rts

calc_rightpos_2:addq.l  #7,A0           ;
                lea     -8*160(A0),A0   ; 8 zeilen nach oben
                move.l  A0,cursor_pos_2

                st      position_flag_2

                rts

********************************************************************************

debug:          cmpi.b  #$39,$FFFFFC02.w
                bne.s   debug

debug2:         cmpi.b  #$38,$FFFFFC02.w
                bne.s   debug2

                rts

********************************************************************************

calc_cursor_startpos:
                movea.l cursor_startpos,A0
                tst.b   startpos_flag
                bmi.s   calc_rightstartpos

calc_leftstartpos:addq.l #7,A0          ; zeiger auf n„chstes word
                move.l  A0,cursor_startpos
                move.l  A0,cursor_pos

                st      startpos_flag

                rts

calc_rightstartpos:addq.l #1,A0
                move.l  A0,cursor_startpos
                move.l  A0,cursor_pos

                sf      startpos_flag

                rts

********************************************************************************

calc_cursor_startpos_2:                 ; lower right corner
                movea.l cursor_startpos_2,A0
                tst.b   startpos_flag_2
                bmi.s   calc_rightstartpos_2

calc_leftstartpos_2:suba.l #7,A0        ; zeiger auf letztes word
                move.l  A0,cursor_startpos_2
                move.l  A0,cursor_pos_2

                st      startpos_flag_2

                rts

calc_rightstartpos_2:subq.l #1,A0       ; zeiger auf vorangegangenes byte
                move.l  A0,cursor_startpos_2
                move.l  A0,cursor_pos_2

                sf      startpos_flag_2

                rts

********************************************************************************

cursordata_offset:DS.W 1
cursor_startpos:DS.L 1
cursor_pos:     DS.L 1
cursor_startpos_2:DS.L 1
cursor_pos_2:   DS.L 1
diag_counter:   DS.W 1
position_flag:  DS.B 1
position_flag_2:DS.B 1
startpos_flag:  DS.B 1
startpos_flag_2:DS.B 1


draw_cursor:    movea.l cursor_pos,A0

                lea     cursordata,A1
                adda.w  cursordata_offset,A1

                move.b  (A1)+,0*160(A0)
                move.b  (A1)+,1*160(A0)
                move.b  (A1)+,2*160(A0)
                move.b  (A1)+,3*160(A0)
                move.b  (A1)+,4*160(A0)
                move.b  (A1)+,5*160(A0)
                move.b  (A1)+,6*160(A0)
                move.b  (A1)+,7*160(A0)

                rts

draw_cursor_2:  movea.l cursor_pos_2,A0

                lea     cursordata,A1
                adda.w  cursordata_offset,A1

                move.b  (A1)+,0*160(A0)
                move.b  (A1)+,1*160(A0)
                move.b  (A1)+,2*160(A0)
                move.b  (A1)+,3*160(A0)
                move.b  (A1)+,4*160(A0)
                move.b  (A1)+,5*160(A0)
                move.b  (A1)+,6*160(A0)
                move.b  (A1)+,7*160(A0)

                rts

cursordata:

                DC.B %0
                DC.B %0
                DC.B %0
                DC.B %1100000
                DC.B %1100000
                DC.B %0
                DC.B %0
                DC.B %0

                DC.B %0
                DC.B %0
                DC.B %0
                DC.B %1110000
                DC.B %1110000
                DC.B %0
                DC.B %0
                DC.B %0

                DC.B %0
                DC.B %0
                DC.B %11111100
                DC.B %11111100
                DC.B %11111100
                DC.B %11111100
                DC.B %0
                DC.B %0

                DC.B %0
                DC.B %11111110
                DC.B %11111110
                DC.B %11111110
                DC.B %11111110
                DC.B %11111110
                DC.B %11111110
                DC.B %0

                DC.B %11111111
                DC.B %11111111
                DC.B %11111111
                DC.B %11111111
                DC.B %11111111
                DC.B %11111111
                DC.B %11111111
                DC.B %11111111


part_raster:    move    #$2700,SR       ; keinen ir zulassen
                bclr    #5,$FFFFFA15.w  ; tc aus
                move.b  #1,$FFFFFA07.w  ; tb
                move.b  #1,$FFFFFA13.w  ; tb

                move.w  #0,linecounter

                lea     rasterpos,A0 ; left border raster
                move.w  (A0),current_left_rasterend

                lea     rasterpos2,A1
                move.w  (A1),current_right_rasterend

                move.l  #new_tb_1,$0120.w
                move.l  #new_vbl,$70.w
                move    #$2300,SR

rasterwait:     REPT 2
                jsr     wvbl
                ENDR

                tst.w   rasterflag
                beq.s   no_rasterchange

                tst.w   2(A0)
                beq.s   no_rasterchange2

                addq.w  #2,A0
                move.w  (A0),current_left_rasterend

                addq.w  #2,A1
                move.w  (A1),current_right_rasterend

no_rasterchange:

	cmp.b 	#$39,$fffffc02.w
	bne		rasterwait
		move.w	#-1,demo_exit
	rts

no_rasterchange2:

                rts

linecounter:    DS.W 1
current_left_rasterend:DS.W 1
current_right_rasterend:DS.W 2

new_118:        rte

new_vbl:


                addq.w  	#1,$466.w
	incSync
                move.w  #0,linecounter

                move.w  #-1,$FFFF8240.w

                move.b  #0,$FFFFFA1B.w  ; tb aus
                move.b  #1,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
                move.l  #new_tb_1,$0120.w

			pusha0
			move.l	sndh_pointer,a0
			jsr		8(a0)
			popa0


                rte

new_tb_1:       move.w  #$00,$FFFF8240.w
                REPT 30
                nop
                ENDR
                move.w  #-1,$FFFF8240.w

                move    #$2700,SR       ; keine irs zulassen
                move.b  #0,$FFFFFA1B.w  ; tb aus
                move.b  #1,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus

                addq.w  #1,linecounter

                move.w  linecounter,D0
                move.w  current_left_rasterend,D1

                cmp.w   D1,D0
                bne.s   tb1_no_change

                move.l  #new_tb_2,$0120.w

tb1_no_change:  move.w  linecounter,D0
                move.w  current_right_rasterend,D1

                cmp.w   D1,D0
                ble.s   no_right_border

                move.w  #$00,$FFFF8240.w

no_right_border:bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte

new_tb_2:       move.w  #-1,$FFFF8240.w
                move    #$2700,SR       ; keine irs zulassen
                move.b  #0,$FFFFFA1B.w  ; tb aus

                move.b  #1,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus

                addq.w  #1,linecounter

                cmpi.w  #200,linecounter
                beq.s   tb_white_bottom

                REPT 10
                nop
                ENDR

                move.w  linecounter,D0 ; test for right border
                move.w  current_right_rasterend,D1

                cmp.w   D1,D0
                ble.s   no_right_border2

                move.w  #$00,$FFFF8240.w

no_right_border2:

                st      rasterflag

                bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte

tb_white_bottom:move.w  #-1,8240.w

                bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte

rasterflag:     DS.B 1
                EVEN
rasterpos:
                DC.W 5,10,20,40,70,100,130,160,199
                DC.W 170,150,130,120,110,106,103,100
                DC.W 103,106,110,120,130,150,170,199
                DC.W 180,175,172,169,167,169,172,175,180,199,0

rasterpos2:     DC.W 195,190,180,160,130,100,70,40,0
                DC.W 30,50,70,80,90,94,97,100
                DC.W 97,94,90,80,70,50,30,0
                DC.W 20,25,28,31,33,31,28,25,20,0


wait:
wait_loop:      jsr     wvbl
                dbra    D7,wait_loop
                rts


top_raster:     
	move.l  #new_vbl2,$70.w ; point to new vbl (simple cinemascope)
    st      top_flag        ; screen prepared, next vbl can be
                          ; switched on (cinemascope with opened top border)

    moveq   #28,D1          ; line in which tb-colorchange appears
    moveq   #0,D2

    jsr     wvbl

    lea     topraster_table,A0 ; point to top raster position table
    lea     bottomraster_table,A1
    lea     fade_colors,A2  ; ********* new!

topraster_loop: move.b  (A0)+,D1        ; get next top raster position
    move.b  (A1)+,D3

    addq.w  #2,A2

    jsr     wvbl
    jsr     wvbl

    tst.b   (A0)            ; already end of the table?
    beq.s   stop_top

	cmp.b 	#$39,$fffffc02.w
	bne		topraster_loop
		move.w	#-1,demo_exit
	rts

stop_top:       st      top_stop_flag

                move.l  #dummy_vbl,$70.w
                move.l  #dummy_tb,$0120.w
                move.w  #0,$FFFF8240.w

                rts

topraster_table:DC.B 28,27,24,20,15,7,1
                DC.B 4,7,10,12,14,15,16,15,14,12,10,7,4,1
                DC.B 4,7,10,11,10,4,1,1,1,1,1,1,1,1,1
                DC.B 0
                even
bottomraster_table:DC.B 2,6,11,17,24,31,39
                DC.B 34,30,26,24,22,21,20
                DC.B 21,22,25,26,30,34,39
                DC.B 37,35,32,30
                DC.B 32,35,37,39,39,39,39,39,39,39,39
                even
; ************************* new!

fade_colors:    REPT 15
                DC.W -1      ; wait a bit before fading begins
                ENDR
                DC.W $0776,$0775,$0774,$0773,$0772,$0762,$0751,$0641,$0631,$0621,$0521,$0422
                DC.W $0412,$0402,$0302,$0202,$0201,$0101
                REPT 10
                DC.W 0
                ENDR

; *************************

top_flag:       DS.B 1
top_stop_flag:  DS.B 1
                EVEN

*********************************************************************************

new_vbl3:       
				move.w  #$0599,D0       ; open top border
borderloop:     dbra    D0,borderloop

                move.b  #0,$FFFF820A.w
                DS.W 	10,$4E71   ; wait 40 cycles
                move.b  #2,$FFFF820A.w



                tst.b   top_stop_flag   ; at the end of top raster position table?
                beq.s   no_black        ; (= top raster in line 1)

                move.l  #dummy_vbl,$70.w

                move.w  #0,$FFFF8240.w

                bra.s   top_cont

no_black:       move.w  (A2),$FFFF8240.w

top_cont:       addq.w  	#1,$466.w
	incSync

                clr.b   $FFFFFA1B.w     ; tb aus

                move.b  D1,$FFFFFA21.w  ; line of upper rastersplit
                move.b  #8,$FFFFFA1B.w
                move.l  #tb_uppersplit,$0120.w

                move.w  #228,D2
                sub.w   D1,D2           ; D2 = line in which opening of the lower border appears


end_vbl:        rte

*********************************************************************************

tb_uppersplit:  move.w  #0,$FFFF8240.w  ; upper rastersplit

                clr.b   $FFFFFA1B.w
                move.b  D2,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                move.l  #tb_bottom,$0120.w

                pusha0
                	move.l	sndh_pointer,a0
                	jsr		8(a0)
                popa0

                rte

*********************************************************************************

tb_bottom:    




	movem.l	d1-d2/a0,-(sp)
     clr.b   $fffffa1b.w                     ;Timer B control (stop)
 
                move.w  #$2700,sr

        lea $ffff8209.w,a0          ;Hardsync
        moveq   #127,d1
.sync:      tst.b   (a0)
        beq.s   .sync
        move.b  (a0),d2
        sub.b   d2,d1
        lsr.l   d1,d1
        REPT 59
        	nop
        ENDR


    movem.l (sp)+,d1-d2/a0

	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR

	move.b	#2,$ffff820a.w			;50 Hz
    move    #$2400,sr    


                clr.b   $FFFFFA1B.w     ; tb aus

                move.b  D3,$FFFFFA21.w  ; line of lower rastersplit
                move.b  #8,$FFFFFA1B.w
                move.l  #tb_lowersplit,$0120.w

                rte

tb_lowersplit:  move.w  (a2),$FFFF8240.w

                rte

*******************************************************************************

; simple cinemascope raster

new_vbl2:       move.b  #0,$FFFFFA1B.w  ; tb aus

                addq.w  	#1,$466.w
	incSync

                tst.b   top_flag
                beq.s   no_change

                move.l  #new_vbl3,$70.w

no_change:      move.b  #1,$FFFFFA21.w  ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
                move.l  #new_tb_1b,$0120.w

			pusha0
			move.l	sndh_pointer,a0
			jsr		8(a0)
			popa0


                rte

new_tb_1b:      move.w  #$00,$FFFF8240.w

                move    #$2700,SR       ; keine irs zulassen
                move.b  #0,$FFFFFA1B.w  ; tb aus
                move.b  #199,$FFFFFA21.w ; startzeile tb neu initialisieren
                move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus

                move.l  #new_tb_2b,$0120.w

                bclr    #0,$FFFFFA0F.w  ; tb beendet

                rte

new_tb_2b:      move.w  #-1,$FFFF8240.w

                bclr    #0,$FFFFFA0F.w  ; tb beendet
                rte

dummy_vbl:      addq.w  	#1,$466.w
	incSync
                move.w  #0,$FFFF8240.w
        					pusha0
			move.l	sndh_pointer,a0
			jsr		8(a0)
			popa0
                rte

dummy_tb:       rte






sub_clrscr:     move.l	screenpointer,a6
                moveq   #0,D1
                move.w  #4000-1,D0
clrscr_loop:    move.l  D1,(A6)+
                move.l  D1,(A6)+
                move.l  D1,(A6)+
                move.l  D1,(A6)+
                dbra    D0,clrscr_loop

                rts

sub_wvbl:       clr.l   $466.w
wvbl_loop:      tst.l   $466.w
                beq.s   wvbl_loop


                rts



setShitBlack
	lea		$ffff8240,a0
	moveq	#0,d0
	move.l	#$FFFF0000,(a0)+
	REPT 7
		move.l	d0,(a0)+
	ENDR

    rts


;;;;;;;;;;;;;; CURSORFADE END ;;;;;;;;
;;;;;;;;;;;;;; CURSORFADE END ;;;;;;;;
;;;;;;;;;;;;;; CURSORFADE END ;;;;;;;;



;;;;;;;;;;;;;; METABALL START ;;;;;;;;;;
;;;;;;;;;;;;;; METABALL START ;;;;;;;;;;
;;;;;;;;;;;;;; METABALL START ;;;;;;;;;;

metaBalls
.init
	move.l	screenpointer2,d0
	move.l	d0,backup_screenpointer			;c
	move.l	screenpointer,d0
	move.l	d0,backup_screenpointer2		;d

x set 2
	REPT 7
	move.l	#$01110111,$ffff8240+x
x set x+4
	endr

	move.w	#$2700,sr
	move.l	#meta_curtain_vbl,$70
	move.w	#$2300,sr

	jsr		generate2pxTabs				;2 and 3				;19 this generates the 2 px tabs, this way the tabs are set up that the source picture can be read
	jsr		generateC2PMeta				;7 and 8
	jsr		generateC2PCopyMetaBall

	lea		meta1,a3
	jsr		copyMetaBoobRight

	cmp.b 	#$39,$fffffc02.w
	bne		.gogo1
		move.w	#-1,demo_exit
		rts
.gogo1
	move.l	#ball128,at1
	move.l	angleTable2Pointer,at2
	jsr		initC2PUnevenMeta
	move.w	#129,effectcounter

	move.w	#0,$466.w
	move.w	#0,vblcounter
	lea		pal1fade,a0
	move.l	a0,fadepointer
	move.w	#13,fadecounter

	lea		c2ppath1,a0
	move.l	a0,c2ppathpointer1
	lea		c2ppath2,a0
	move.l	a0,c2ppathpointer2
	lea		c2ppath3,a0
	move.l	a0,c2ppathpointer3

	move.w	#4,offset1step
	move.w	#4,offset2step
	move.w	#4,offset3step

	move.w	#66+26,c2poffset1
	move.w	#48+30,c2poffset2
	move.w	#52+28,c2poffset3

	move.w	#160,c2p_x_off

.ml1:	
	move.l	screenpointer,$ffff8200
	jsr		c2p_1to2_per2_meta
	jsr		copy_c2p_lines
	jsr		doc2pOffset
	jsr		swapscreens_c2p

	subq.w	#1,effectcounter
	cmp.w	#-10,effectcounter
	beq		.ml2_init

	cmp.b 	#$39,$fffffc02.w
	bne		.ml1
		move.w	#-1,demo_exit
		rts

.ml2_init
	move.w	#0,fadecounter
	move.w	#0,effectcounter
	jsr		generate2pxTabsMeta				;19 this generates the 2 px tabs, this way the tabs are set up that the source picture can be read

	; first we need to fade
	lea		meta2,a3
	jsr		copyMetaBoobLeft

	move.l	#ball100,at1
	move.l	angleTable2Pointer,at2
	jsr		initC2PUnevenMeta

	move.w	#129,effectcounter
	move.w	#13,fadecounter
	lea		pal2fade,a0
	move.l	a0,fadepointer


	lea		c2ppath1x,a0
	move.l	a0,c2ppathpointer1
	lea		c2ppath2x,a0
	move.l	a0,c2ppathpointer2
	lea		c2ppath3x,a0
	move.l	a0,c2ppathpointer3

	move.w	#2,offset1step
	move.w	#2,offset2step
	move.w	#4,offset3step

	move.w	#0,offset1
	move.w	#20,offset2
	move.w	#40,offset3
	
	move.w	#48+10*256,c2poffset1
	move.w	#50,c2poffset2
	move.w	#40,c2poffset3
	move.w	#64+160,c2p_x_off

.ml2
	move.l	screenpointer,$ffff8200
	jsr		c2p_1to2_per2_meta
	jsr		copy_c2p_lines
	jsr		doc2pOffset
	jsr		swapscreens_c2p
	subq.w	#1,effectcounter
	cmp.w	#-12,effectcounter
	beq		.ml3_init
	cmp.b 	#$39,$fffffc02.w
	bne		.ml2
		move.w	#-1,demo_exit
		rts


.ml3_init
	wait_for_vbl

x set 2
	REPT 7
	move.l	#$01110111,$ffff8240+x
x set x+4
	endr

	lea		meta3,a3
	jsr		copyMetaBoobRight

	move.l	#ball46,at1
	move.l	angleTable2Pointer,at2
	jsr		initC2PUnevenMeta


	lea		c2ppath1,a0
	move.l	a0,c2ppathpointer1
	lea		c2ppath2,a0
	move.l	a0,c2ppathpointer2
	lea		c2ppath3,a0
	move.l	a0,c2ppathpointer3

	move.w	#0,offset1
	move.w	#20,offset2
	move.w	#120,offset3

	move.w	#4,offset1step
	move.w	#4,offset2step
	move.w	#4,offset3step


	move.w	#64,c2poffset1
	move.w	#54,c2poffset2
	move.w	#50,c2poffset3
	move.w	#0+160,c2p_x_off

	move.w	#138,effectcounter
	move.w	#13,fadecounter
	lea		pal3fade,a0
	move.l	a0,fadepointer


.ml3
	move.l	screenpointer,$ffff8200
	jsr		c2p_1to2_per2_meta
	jsr		copy_c2p_lines
	jsr		doc2pOffset
	jsr		swapscreens_c2p
	subq.w	#1,effectcounter
	cmp.w	#-12,effectcounter
	beq		.exit
	cmp.b 	#$39,$fffffc02.w
	bne		.ml3
		move.w	#-1,demo_exit
		rts
.exit
	move.w	#160,c2p_x_off
	rts




;;;;;;;;;;;;;; METABALL ROUT ;;;;;;;;;;
;;;;;;;;;;;;;; METABALL ROUT ;;;;;;;;;;
;;;;;;;;;;;;;; METABALL ROUT ;;;;;;;;;;

meta_curtain_vbl
    move.w	#0,$ffff8240
    addq.w		#1,$466.w
	incSync


    clr.b   $fffffa19.w         	;Timer-A control (stop)
    bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
    bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
    move.b  #48,$fffffa1f.w         ;Timer A Delay (data)
    move.b  #%111,$fffffa19.w       ;Timer A Predivider (start Timer A)
    move.l	#meta_timer_a_curtain_start,$134.w    
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	pusha0
	tst.w	fadecounter
	ble		.nofade
		move.l	fadepointer,a0
		move.l	(a0)+,$ffff8240
		move.l	(a0)+,$ffff8240+2*2
		move.l	(a0)+,$ffff8240+2*4
		move.l	(a0)+,$ffff8240+2*6
		move.l	(a0)+,$ffff8240+2*8
		move.l	(a0)+,$ffff8240+2*10
		move.l	(a0)+,$ffff8240+2*12
		move.l	(a0)+,$ffff8240+2*14
		move.l	a0,fadepointer
		subq.w	#1,fadecounter
.nofade
	tst.w	effectcounter
	bge		.gogo
		move.l	fadepointer,a0
		move.l	(a0)+,$ffff8240
		move.l	(a0)+,$ffff8240+2*2
		move.l	(a0)+,$ffff8240+2*4
		move.l	(a0)+,$ffff8240+2*6
		move.l	(a0)+,$ffff8240+2*8
		move.l	(a0)+,$ffff8240+2*10
		move.l	(a0)+,$ffff8240+2*12
		move.l	(a0)+,$ffff8240+2*14
		move.l	a0,fadepointer
.gogo
	move.l	sndh_pointer,a0
	jsr		8(a0)
	popa0

    rte


meta_timer_a_curtain_start:
	move.w	#$2700,sr			;Stop all interrupts

	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w
   	pushd0

	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
    nop
	
	move.w	#$111,$ffff8240
    clr.b   $fffffa19.w         	;Timer-A control (stop)											;24 => 6

    move.b 	#0,$fffffa1b.w    																		;20 => 5
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)									;28 => 7
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)										;28 => 7
    move.l  #meta_timer_b_curtain_end,$120.w        ;Install our own Timer B						;24 => 6
    move.b  #198,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   	;20 => 5
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))								;20 => 5

	popd0
	rte

meta_timer_b_curtain_end
	move.w	#$2700,sr			;Stop all interrupts
	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w

   	pushd0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
    nop

	move.w	#$000,$ffff8240
	popd0
    rte


generate2pxTabsMeta
	move.l	tab2px_1p,a0
	lea		TAB1,a1
	lea		TAB2,a2
	jsr		calcTabMeta

	move.l	tab2px_2p,a0
	lea		TAB3,a1
	lea		TAB4,a2
	jsr		calcTabMeta
	rts

;;; data layout:
;;; b b
;;; 00000000 00000000
; value range from 0..15
; 00111100 00111100
; 1 bpl = 1
; 2 bpl = 4
; 3 bpl = 8

calcTabMeta
	move.l	#64-1,d7
	moveq	#0,d1
.outer
	move.l	#256-1,d6
	moveq	#0,d0
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			addq.w	#4,d0
			cmp.w	#64,d0
			bne		.noresetin
				subq	#4,d0
.noresetin
		dbra	d6,.inner
		addq.w	#4,d1
		cmp.w	#64,d1
		bne		.noresetout
			subq	#4,d1
.noresetout
	dbra	d7,.outer
	rts

initC2PUnevenMeta
	move.l	at1,a0
	move.l	at2,a1
	move.l	#65536/32-1,d7
.loop
	REPT 32
		move.b	(a0)+,(a1)+
	ENDR
	dbra	d7,.loop
	rts

c2p_1to2_per2_meta
	move.l	c2ppathpointer1,a6
	add.w	offset1,a6
	move.w	(a6),d0
	move.w	d0,d1
	add.w	c2poffset1,d0
	and.w	#%1,d1
	beq		.whole1
	move.l	at1,a0
	and.w	#-2,d0
	jmp		.done1
.whole1
	move.l	at2,a0
.done1
	add.w	d0,a0

	move.l	c2ppathpointer2,a6
	add.w	offset2,a6
	move.w	(a6),d0
	add.w	c2poffset2,d0
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole2
	move.l	at1,a1
	and.w	#-2,d0
	jmp		.done2
.whole2
	move.l	at2,a1
.done2
	add.w	d0,a1

	move.l	c2ppathpointer3,a6
	add.w	offset3,a6
	move.w	(a6),d0
	add.w	c2poffset3,d0
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole3
	move.l	at1,a2
	and.w	#-2,d0
	jmp		.done3
.whole3
	move.l	at2,a2
.done3
	add.w	d0,a2

	move.l	tab2px_1p,d0
	move.l	tab2px_2p,d1
	move.l	screenpointer2,a6
	add.w	c2p_x_off,a6
	move.l	c2pRoutPointer,a4
	jmp		(a4)

generateC2PCopyMetaBall
	move.l	c2pCopyPointer,a0
	move.l	#$4CEE3FFF,a1		;movem.l	x(a6),d0-d7/a0-a5
	move.l	#$48EE3FFF,a2		;movem.l	d0-d7/a0-a5,x(a6)
	move.l	#$4CEE03FF,a3		;movem.l	x(a6),d0-d7/a0-a1
	move.l	#$48EE03FF,a4		;movem.l	d0-d7/a0-a,x(a6)

	move.l	#VIEWPORT_Y-1,d7
	moveq	#0,d0
	move.w	#160,d1

	move.w	#56,d2
	move.w	#160*2-56,d3

.loop
	move.l	a1,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x

	move.l	a2,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160

	add.w	d2,d0				;	x+56+56
	move.l	a3,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x+56+56

	add.w	d2,d1				;	x+160+56+56
	move.l	a4,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160+56+56

	add.w	d3,d0				;	pad to next 
	add.w	d3,d1				;	pad to next

	dbra	d7,.loop

	move.w	#$4e75,(a0)+
	rts

meta_vbl:	
	addq.w 		#1,$466.w
	incSync
	move.w	#0,$ffff8240

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #cinema1,$120.w        ;Install our own Timer B
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

			pusha0

		tst.w	fadecounter
		ble		.nofade
			move.l	fadepointer,a0
			move.l	(a0)+,$ffff8240
			move.l	(a0)+,$ffff8240+2*2
			move.l	(a0)+,$ffff8240+2*4
			move.l	(a0)+,$ffff8240+2*6
			move.l	(a0)+,$ffff8240+2*8
			move.l	(a0)+,$ffff8240+2*10
			move.l	(a0)+,$ffff8240+2*12
			move.l	(a0)+,$ffff8240+2*14
			move.l	a0,fadepointer
			subq.w	#1,fadecounter
.nofade

		tst.w	effectcounter
		bge		.gogo
			move.l	fadepointer,a0
			move.l	(a0)+,$ffff8240
			move.l	(a0)+,$ffff8240+2*2
			move.l	(a0)+,$ffff8240+2*4
			move.l	(a0)+,$ffff8240+2*6
			move.l	(a0)+,$ffff8240+2*8
			move.l	(a0)+,$ffff8240+2*10
			move.l	(a0)+,$ffff8240+2*12
			move.l	(a0)+,$ffff8240+2*14
			move.l	a0,fadepointer
.gogo
		IFNE	playmusic
		IFNE	playmusicinvbl				
			move.l	sndh_pointer,a0
			jsr		8(a0)
		ENDC
		ENDC
        IFNE    framecount
            addq.w  #1,_framecounter
        ENDC
        add.w	#1,vblcounter
		popa0
	rte

cinema1
	move.w	#$111,$ffff8240

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #cinema2,$120.w        ;Install our own Timer B
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

cinema2
	move.w	#0,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	rte	




copyMetaBoobLeft
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.l	screenpointer3,a2
	moveq	#0,d0
	move.l	#200-1,d7
.clear
	REPT 7
		move.l	(a3),(a0)+
		move.l	(a3),(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3),(a0)+
		move.l	(a3),(a1)+
		move.l	(a3)+,(a2)+
	ENDR
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a2)+
	add.w	#160-8*8,a0
	add.w	#160-8*8,a1
	add.w	#160-8*8,a2
	dbra		d7,.clear
	rts

copyMetaBoobRight
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.l	screenpointer3,a2
	moveq	#0,d0
	move.l	#199-1,d7
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a2)+			
	ENDR
o set 96
	moveq	#0,d0
	REPT 5
		move.l	d0,o(a0)
		move.l	d0,o+4(a0)
		move.l	d0,o(a1)
		move.l	d0,o+4(a1)
		move.l	d0,o(a2)
		move.l	d0,o+4(a2)
o set o+160
	ENDR

	add.w	#7*8,a3
	add.w	#13*8,a0
	add.w	#13*8,a1
	add.w	#13*8,a2
.clear
	REPT 7
		move.l	(a3),(a0)+
		move.l	(a3),(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3),(a0)+
		move.l	(a3),(a1)+
		move.l	(a3)+,(a2)+
	ENDR
	add.w	#160-7*8,a0
	add.w	#160-7*8,a1
	add.w	#160-7*8,a2
	dbra		d7,.clear
	rts


generateC2PMeta
	move.l	c2pRoutPointer,a0
	move.l	#$3018D059,a1			; 3018 = move.w (a0)+,d0	D059 = add.w	(a1)+,d0
	move.l	#$D05A2640,a2			; D05A = add.w	(a2)+,d0	2640 = move.l	d0,a3
	move.l	#$2A133218,a3			; 2A13 = move.l	(a3),d5		3218 = move.w	(a0)+,d1
	move.l	#$D259D25A,a4			; D259 = add.w	(a1)+,d1	D25A = add.w	(a2)+,d1
	move.l	#$26418A93,a5			; 2641 = move.l	d1,a3		8A93 = or.l		(a3),d5
	move.l	#$0BCE0000,d0			; 08CE 0000 movep.l	d5,x(a6)

	move.l	#$41E80060,d3			; lea +160(a2),a2
	move.w	#SOURCE_X-12*8,d3
	move.l	d3,a6
	move.l	#$43E90060,d2			; lea +160(a1),a1
	move.w	#SOURCE_X-12*8,d2
	move.l	#$45EA0060,d3			; lea +160(a2),a2
	move.w	#SOURCE_X-12*8,d3

	add.w	#160,d1
	move.w	#320-12*8,d4

	move.l	#100-1,d7
	move.l	#12-1,d5

.ol
	move.l	d5,d6
.il
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#1,d0
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#7,d0
		dbra	d6,.il
	move.l	a6,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add.w	d4,d0
	dbra	d7,.ol

	move.w	#$4e75,(a0)+
	rts
;;;;;;;;;;;;;; METABALL END ;;;;;;;;;;
;;;;;;;;;;;;;; METABALL END ;;;;;;;;;;
;;;;;;;;;;;;;; METABALL END ;;;;;;;;;;


;;;;;;;;;;;;;; TRANS DIAG START ;;;;;;;;
;;;;;;;;;;;;;; TRANS DIAG START ;;;;;;;;
;;;;;;;;;;;;;; TRANS DIAG START ;;;;;;;;
generateCopy4BPL
	move.l	copy4BLPointer,a0
	move.l	#$4CD878FF,d0
	move.l	#$48E978FF,d1
	move.l	#$48EA78FF,d2
	moveq	#0,d3
	move.w	#48,d4
	move.l	#666-1,d7
.loop
		move.l	d0,(a0)+				;movem.l	(a0)+,d0-d7/a3-a6
		move.l	d1,(a0)+				;movem.l	d0-d7/a3-a6,o(a1)
		move.w	d3,(a0)+				; o
		move.l	d2,(a0)+				;movem.l	d0-d7/a3-a6,o(a2)
		move.w	d3,(a0)+				; o
		add.w	d4,d3					; o = o + 48
	dbra	d7,.loop
	move.l	#$4CD800FF,(a0)+			;movem.l	(a0)+,d0-d7
	move.l	#$48E900FF,(a0)+			;movem.l	d0-d7,o(a1)
	move.w	d3,(a0)+					; o
	move.l	#$48EA00FF,(a0)+			;movem.l	d0-d7,o(a2)
	move.w	d3,(a0)+					; o
	move.w	#$4e75,(a0)+				; rts
	rts

doDiagTrans
.init
	jsr		generateCopy4BPL
	move.w	#$2700,sr
	move.l	#diag_vbl_init,$70
	move.w	#$2300,sr

		lea		$ffff8242,a0
		rept 14
			move.w	#diagFaceStart,(a0)+
		endr
		move.w	#$000,(a0)

	lea		diagpicture+34,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	move.l	copy4BLPointer,a3
	jsr		(a3)
;o set 0
;	REPT 666
;		movem.l	(a0)+,d0-d7/a3-a6			; 8 + 4 = 12, need 2 per 16 pixels, so 96 per time, we have 320*200 = 64000 pixels. = 666, and 64 left			;	4CD8 78FF
;		movem.l	d0-d7/a3-a6,o(a1)																															;	48D1 78FF 0000
;		movem.l	d0-d7/a3-a6,o(a2)																															;	48D2 78FF 0000		; 16*666 = 10656
;o set o+48
;	ENDR
;	movem.l	(a0)+,d0-d7						; 4CD8 00FF
;	movem.l	d0-d7,o(a1)						; 48E9 00FF 0000
;	movem.l	d0-d7,o(a2)						; 48EA 00FF 0000

	jsr		generatebplcodes
	jsr		generatedrawlinebyxtable
.wait
	tst.w	diagInit
	bne		.wait
.loop
			wait_for_vbl
	move.l 	screenpointershifter,$ff8200
			swapscreens
	jsr		diagPaletteFade
	jsr		diagFade
			exitOnSpace
	subq.w	#1,diagCounter
	bne		.loop
	rts
;;;;;;;;;;;;;; TRANS DIAG ROUT ;;;;;;;;
;;;;;;;;;;;;;; TRANS DIAG ROUT ;;;;;;;;
;;;;;;;;;;;;;; TRANS DIAG ROUT ;;;;;;;;
diagCounter
	dc.w	70
diagInit
	dc.w	-1
diagbg
	dc.w	0
diacurcolor
	dc.w	diagFaceStart
diacounter
	dc.w	2

diagBgList
	dc.w	$233	;0
	dc.w	$133	;1
	dc.w	$123	;2
	dc.w	$122	;3
	dc.w	$022	;4	
	dc.w	$012	;5
	dc.w	$011	;6
	dc.w	$001	;7
	dc.w	$000	;8
	dc.w	$000	;8


diag_vbl_init:
	addq.w		#1,$466.w
	incSync

	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.l	#diag_start,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on

	IFNE	playmusic				
		pusha0
		move.l	sndh_pointer,a0
		jsr		8(a0)
		popa0
	ENDC

	cmp.w	#44,diagbg
	bge		.done
	subq.w	#1,diacounter
	bne		.end
	move.w	#2,diacounter
	pusha0
	lea		diagFadeTable,a0
	add.w	diagbg,a0
	move.w	(a0),diacurcolor
	popa0

	add.w	#2,diagbg
.end
	rte

.done
	move.w	#0,diagInit
	rte

diag_start
	move.w	diacurcolor,$ffff8240
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
    move.b  #199,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.l	#diag_end,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on
	rte

diag_end
	move.w	#0,$ffff8240
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	rte



diag_vbl:	

	addq.w 		#1,$466.w
	incSync
	;Start up Timer B each VBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on

	IFNE	playmusic				
		pusha0
		move.l	sndh_pointer,a0
		jsr		8(a0)
		popa0
	ENDC
	rte

diag1
	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag2
	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc		
	rts
	
diag3
	move.l	d6,d7

	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc		
	rts

diag4
	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag5
	move.l	d6,d7

	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag6
	move.l	d6,d7

	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag7
	move.l	d6,d7

	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag8
	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag9
	move.l	d6,d7

	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix diag
	rts

diag10
	move.l	d6,d7

	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag11
	move.l	d6,d7

	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag12
	move.l	d6,d7

	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag13
	move.l	d6,d7

	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag14
	move.l	d6,d7

	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diag15
	move.l	d6,d7

	move.l	usp,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#2,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#4,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc

	move.l	d7,d6

	move.l	usp,a0
	add.w	#6,a0
	lea		6(PC),a5			; return for diagline
	jmp 	diagLine			; do the line
	move.w	a4,(a3)				; restore fix smc
	rts

diagPaletteFade
	; order of the colors:
	;	9,	12,	3,	10,	13,	11,	7,	14,	5,	6,	4,	2,	1
	; so we need a lookuptable
	lea	diagCurrentPosition,a0
	lea	diagFadeTable,a1
	lea diagPaletteList,a2
	move.w	#13-1,d7
.cloop
	move.l	(a2)+,a3
	move.w	(a0)+,d0
	ble		.nothing
		asr.w	#2,d0
	;	use d0 to lookup table
		move.w	(a1,d0.w),(a3)
.nothing
	dbra	d7,.cloop
	rts

diagFade
	raster	#$007
	;;;;;; start drawing lines:
	; init values
	moveq	#%1,d0		
	moveq	#%100,d1				
	moveq	#%1000,d2	
	moveq	#%100000,d3	
	moveq	#%1000000,d4
	move.w	#%10000000,d5
	move.l	diagLinePointer,a1
;	lea		drawlinebyxtable,a1		; 12	load our table, which contains: addressroutine,yoffset,jmpoffset, for every x, x= [0,519]
	move.l	screenpointer2,a6
	move.l	a6,usp
	; we free a6 to load our position counter here now
	;;;;;;;;; end of init

	; we can use an array to get our position from, in that case, it should be saved at a6
	; example usage, this can also be done using a jumptable, this is just example code to make life easy

	; first, 20 iter, 0-40

	lea		diagCurrentPosition,a6

	cmp.w	#21*8,(a6)+
	beq		.cont1

	; hax
	move.l	usp,a0
	or.w	#1<<15,2(a0)
	or.w	#1<<15,4(a0)

	move.w	#40*8,d6
	sub.w	-2(a6),d6
	jsr		diag6
	move.w	#40*8*0,d6
	add.w	-2(a6),d6
	jsr		diag6

	move.w	#40*8,d6
	sub.w	-2(a6),d6
	add.w	#8,d6
	jsr		diag6
	move.w	#40*8*0,d6
	add.w	-2(a6),d6
	add.w	#8,d6
	jsr		diag6

	addq.w	#1*8,-2(a6)		
.cont1
	
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont2
	move.w	#40*8*2,d6
	sub.w	-(a6),d6		; -2
	jsr		diag3
	move.w	#40*8*1,d6
	add.w	(a6),d6
	jsr		diag3

	move.w	#40*8*2,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag3
	move.w	#40*8*1,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag3

	addq.w	#1*8,(a6)+

.cont2
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont3
	move.w	#40*8*3,d6
	sub.w	-(a6),d6
	jsr		diag12
	move.w	#40*8*2,d6
	add.w	(a6),d6
	jsr		diag12

	move.w	#40*8*3,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag12
	move.w	#40*8*2,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag12

	addq.w	#1*8,(a6)+

.cont3
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont4
	move.w	#40*8*4,d6
	sub.w	-(a6),d6
	jsr		diag5
	move.w	#40*8*3,d6
	add.w	(a6),d6
	jsr		diag5

	move.w	#40*8*4,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag5
	move.w	#40*8*3,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag5

	addq.w	#1*8,(a6)+

.cont4
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont5
	move.w	#40*8*5,d6
	sub.w	-(a6),d6
	jsr		diag2
	move.w	#40*8*4,d6
	add.w	(a6),d6
	jsr		diag2

	move.w	#40*8*5,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag2
	move.w	#40*8*4,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag2

	addq.w	#1*8,(a6)+

.cont5
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont6
	move.w	#40*8*6,d6
	sub.w	-(a6),d6
	jsr		diag4
	move.w	#40*8*5,d6
	add.w	(a6),d6
	jsr		diag4

	move.w	#40*8*6,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag4
	move.w	#40*8*5,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag4

	addq.w	#1*8,(a6)+

.cont6
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont7
	move.w	#40*8*7,d6
	sub.w	-(a6),d6
	jsr		diag8
	move.w	#40*8*6,d6
	add.w	(a6),d6
	jsr		diag8

	move.w	#40*8*7,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag8
	move.w	#40*8*6,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag8

	addq.w	#1*8,(a6)+

.cont7	
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont8
	move.w	#40*8*8,d6
	sub.w	-(a6),d6
	jsr		diag1
	move.w	#40*8*7,d6
	add.w	(a6),d6
	jsr		diag1

	move.w	#40*8*8,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag1
	move.w	#40*8*7,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag1

	addq.w	#1*8,(a6)+

.cont8
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont9
	move.w	#40*8*9,d6
	sub.w	-(a6),d6
	jsr		diag10
	move.w	#40*8*8,d6
	add.w	(a6),d6
	jsr		diag10

	move.w	#40*8*9,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag10
	move.w	#40*8*8,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag10

	addq.w	#1*8,(a6)+

.cont9
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont10
	move.w	#40*8*10,d6
	sub.w	-(a6),d6
	jsr		diag9
	move.w	#40*8*9,d6
	add.w	(a6),d6
	jsr		diag9

	move.w	#40*8*10,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag9
	move.w	#40*8*9,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag9

	addq.w	#1*8,(a6)+

.cont10
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont11
	move.w	#40*8*11,d6
	sub.w	-(a6),d6
	jsr		diag11
	move.w	#40*8*10,d6
	add.w	(a6),d6
	jsr		diag11

	move.w	#40*8*11,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag11
	move.w	#40*8*10,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag11

	addq.w	#1*8,(a6)+

.cont11
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont12
	move.w	#40*8*12,d6
	sub.w	-(a6),d6
	jsr		diag13
	move.w	#40*8*11,d6
	add.w	(a6),d6
	jsr		diag13

	move.w	#40*8*12,d6
	sub.w	(a6),d6
	add.w	#8,d6
	jsr		diag13
	move.w	#40*8*11,d6
	add.w	(a6),d6
	add.w	#8,d6
	jsr		diag13

	addq.w	#1*8,(a6)+

.cont12
	tst.w	(a6)
	blt		.end
	cmp.w	#21*8+40,(a6)+
	beq		.cont13

	cmp.w	#16,-2(a6)
	blt		.other
	move.w	#40*8*13,d6
	sub.w	-2(a6),d6
	jsr		diag14
	move.w	#40*8*13,d6
	sub.w	-2(a6),d6
	add.w	#8,d6
	jsr		diag14

.other
	move.w	#40*8*12,d6
	add.w	-2(a6),d6
	jsr		diag14
	move.w	#40*8*12,d6
	add.w	-2(a6),d6
	add.w	#8,d6
	jsr		diag14
	addq.w	#1*8,-2(a6)
.cont13

.end
	move.w	#14-1,d7
.addloop
	add.w	#1*8,(a6)+
	dbra	d7,.addloop
	rts


; this generates our 16 routines for each starting pixel 0..15 (not really in that order)
generatebplcodes
; for 1-bitplanes
	lea		lineslist1bpl,a6
	move.l	#16-1,d6
	moveq	#0,d0
; 1-bitplane opcodes
	move.w	#$8B28,d2			;or.b	d5,o(a0)		;1 $0000 0080
	move.w	#$8128,d3			;or.b	d0,o(a0)		;2 $0000 0001
	move.w	#$01E8,d4			;bset	d0,o(a0)		;3 $0000 0002
	move.w	#$8328,d5			;or.b	d1,o(a0)		;4 $0000 0004
	move.w	#$8528,a5			;or.b	d2,o(a0)		;5 $0000 0008
	move.w	#$03E8,a2			;bset 	d1,o(a0)		;6 $0000 0010
	move.w	#$8728,a3			;or.b	d3,o(a0)		;7 $0000 0020
	move.w	#$8928,a4			;or.b	d4,o(a0)		;8 $0000 0040

.generateList
	move.l	(a6)+,a0
	move.w	(a6)+,d0
	move.w	(a6)+,d1
	jsr		generateDrawCode
	dbra	d6,.generateList
	rts

; a0 buffer
; d1 jump offset, instructionwise
; subroute to generate code
generateDrawCode
	moveq	#14-1,d7

	lea		.do_sixteen(pc,d1.w),a1
	jmp		(a1)
.do_sixteen
		move.w	d2,(a0)+							
		move.w	d0,(a0)+
		add.w	#153,d0								;o set o+154
		move.w	d3,(a0)+							
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	d4,(a0)+							
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	d5,(a0)+							
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a5,(a0)+							
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a2,(a0)+							
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a3,(a0)+							
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a4,(a0)+							
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160s

		;;;;;; 2nd round	
		move.w	d2,(a0)+							;or.b	d5,o(a0)		;9						
		move.w	d0,(a0)+
		add.w	#159,d0								;o set o+159
		move.w	d3,(a0)+							;or.b	d0,o(a0)		;10
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	d4,(a0)+							;bset	d0,o(a0)		;11
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	d5,(a0)+							;or.b	d1,o(a0)		;12
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a5,(a0)+							;or.b	d2,o(a0)		;13
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a2,(a0)+							;bset	d1,o(a0)		;14
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a3,(a0)+							;or.b	d3,o(a0)		;15
		move.w	d0,(a0)+
		add.w	#160,d0								;o set o+160
		move.w	a4,(a0)+							;or.b	d4,o(a0)		;16
		move.w	d0,(a0)+		
		add.w	#160,d0								;o set o+160

	dbra	d7,.do_sixteen
	move.w	#$4e75,(a0)+
	rts

; this is where the magic/routine magic happens, big lookup, big fun
; basically for every x position, we also register the offset on the screen, and the offset into the drawing routine,
; size = 519*8 = 4160 bytes, we would need one of these for every draw routine for per bitplane combination, we could also seperate them into multiple tables;
; to reduce redundancy
; layout:
;	first 200 entries are the entries where we dont draw a full diagonal, so we have to return early
;	next 120 entries are the entries where the full diagonal is drawn
;	last 200 lines are the entries where we move to the right
generatedrawlinebyxtable
;	lea		drawlinebyxtable,a0
	move.l	diagLinePointer,a0
	lea		lll,a2

	moveq	#-8,d0			;yoffset
	moveq	#4,d1			;jumpoffset
	moveq	#12-1,d7

.do_first
		move.l	a2,a1
		moveq	#16-1,d6
.do_inner1
		move.l	(a1)+,(a0)+
		move.w	d0,(a0)+			;yoffset
		move.w	d1,(a0)+			;jumpoffset
		addq.w	#4,d1
		dbra	d6,.do_inner1

		addq.w	#8,d0				;yoffset = yoffset + 8
	dbra	d7,.do_first

	move.l	a2,a1
	moveq	#8-1,d6
.do_end8
		move.l	(a1)+,(a0)+
		move.w	d0,(a0)+			;yoffset
		move.w	d1,(a0)+			;jumpoffset
		addq.w	#4,d1
		dbra	d6,.do_end8

;;;;;; end of first part
	move.w	#88,d0				;yoffset = 88
	move.w	#800,d1				;jumpoffset set 200*4
	moveq	#7-1,d7
	moveq	#8-1,d6
		move.l	a2,a1
		add.w	#32,a1
.second_init
		move.l	(a1)+,(a0)+
		move.w	d0,(a0)+			;yoffset
		move.w	d1,(a0)+			;jumpoffset
		dbra	d6,.second_init
		addq.w	#8,d0

.do_second
		moveq	#16-1,d6
		move.l	a2,a1

.do_second_inner
		move.l	(a1)+,(a0)+
		move.w	d0,(a0)+			;yoffset
		move.w	d1,(a0)+			;jumpoffset
		dbra	d6,.do_second_inner

		addq.w	#8,d0
	dbra	d7,.do_second


;;;;;;;;;;;; end second part
	move.w	#160+144,d0			;yvalue set 160+144
	move.w	#199*4,d1			;jumpoffset set 199*4
	move.w	#200-1,d7
	move.l	15*4(a2),a1
.do_last
		move.l	a1,(a0)+
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		add.w	#160,d0
		sub.w	#4,d1
	dbra	d7,.do_last

	rts	

; we use:
;	a0 = screen address + possible offset
;	a1 = routine to use
;	d6 = x
diagLine
;	move.l	usp,a1
;	lea		drawlinebyxtable,a1		; 12	load our table, which contains: addressroutine,yoffset,jmpoffset, for every x, x= [0,519]
	move.l	diagLinePointer,a1
;	move.l	#(1<<16)+%1,d0
;	move.l	#(1<<17)+%10,d7
;	move.l	#(1<<18)+%100,d1
;	move.l	#(1<<19)+%1000,d2
;	move.l	#(1<<21)+%100000,d3
;	move.l	#(1<<22)+%1000000,d4
;	move.l	#(1<<23)+%10000000,d5

													;					76543210
;	moveq	#%1,d0									;4			or.w	00000001
													;			bset	00000010
;	moveq	#%100,d1								;4			or.w	00000100
													;4			bset	00010000
;	moveq	#%1000,d2								;			or.w	00001000
;	moveq	#%100000,d3								;4			or.w	00100000
;	moveq	#%1000000,d4							;4			or.w	01000000
;	move.w	#%10000000,d5							;8			or.w	10000000

;	add.w	d6,d6									;4
;	add.w	d6,d6									;4
;	add.w	d6,d6									;4

	; this is a little expensive overhead, and can be done smarter, but Im lazy atm
	add.w	d6,a1					; 8		add our current value of x, multiplied by 8, since the size of the table is 8 bytes per entry (l/w/w)
	move.l	(a1)+,a2				; 12	we load our routine, which indicates the starting pixel: 1 = 1000 0000, 2 = 0100 0000 etc
	move.l	a2,a3					; 4		we need the address of the routine, in order to do the self modifying code
	add.w	(a1)+,a0				; 12	we add the y-offset to the screen address
	add.w	(a1)+,a3				; 12	we add the table offset for the jumptable to the routine address; here want to return, smc
	move.w	(a3),a4					; 8		save the current instruction, before we overwrite it,
;	move.w	#$4e75,(a3)				; 12	insert rts into the place
	move.w	#$4ED5,(a3)				; 12	 	instead, jump to a5

;	move.l	#(1<<20)+%10000,d6

	jmp		(a2)					; 8		jump to execute code, it does rts for us, since we inserted it 		
			;------> total, 128 cycles + 8 to restore smc overhead
			; improvemnet could be: remove smc --> -28 cycles
			; replace jsr/rts by jumps: -20 cycles
			; remove initialization of registers from function, and do this only once: -40
			; premultiply the x values by 8: -12 cycles
			;-----> total simple possible gain: ~100 cycles in call, which will save a total of around 3000 cycles at the `best' point -> 6 scanlines
			;
			; cost of diag: 16 cycles per pixel -> 3200 cycles for a complete diagonal
			;
			; so for opt, we would `win' near one diagonal
			;
			; additionally: if we use 2 adjecent bitplanes, we may do or.l instead of 2x or.w, but we still remain to have some overhead for the bset, 
			; since this cannot be replaced (we lack the registers); or.l --> 24, 2xbset = 32, so 200 lines would cost:
			;	diag: 400 pixels; 100 pixels by bset-> 1600 cycles, 300 pixels for 24 pixels per 2-> 12 pixels per --> 1600+3600 = 5200, if bitplanes adjecent
			;	6400 cycles for 2 bitplanes not adjecent
			;	8400 3 bitplanes
			;	10400 4 bitplanes

;;;;;;;;;;;;;; TRANS DIAG END ;;;;;;;;
;;;;;;;;;;;;;; TRANS DIAG END ;;;;;;;;
;;;;;;;;;;;;;; TRANS DIAG END ;;;;;;;;




;;;;;;;;;;;;;; PULSE START ;;;;;;;;;;;;;
;;;;;;;;;;;;;; PULSE START ;;;;;;;;;;;;;
;;;;;;;;;;;;;; PULSE START ;;;;;;;;;;;;;
pulsebright	equ	$203
pulsemid	equ	$103
pulsedark	equ	$102

_flatlinecount	dc.w	2
musicwaiter		dc.w	100	

pulseEffect
.offline
.init
	jsr		init_yblock_aligned
	jsr		init_xblock_aligned	
	jsr		initPulseColors
	lea		flatline,a0
	move.l	a0,currentPointAddress


;;;;; mainloop effect
.mainloop_flatline:
			wait_for_vbl
			swapscreens				; dont use jmp when it returns with rts, use branch then
	cmp.w	#40,pulse_text_offset
	beq		.logodone
		cmp.w	#32,pulse_text_offset
		beq		.dologo
		cmp.w	#36,pulse_text_offset
		beq		.dologo
		lea		pulse_text_list,a0
		add.w	pulse_text_offset,a0
		move.l	(a0),a1
		jsr		(a1)
		jsr		pulse_text_color
		addq.w	#1,pulse_text_counter

		jmp		.continue
.dologo
	move.w	#0,$ffff8242
	move.w	#0,$ffff8244
	move.w	#0,$ffff8246
	add.w	#4,pulse_text_offset
	jmp		.continue
.logodone
	move.w	#pulsebright,color1
	move.w	#pulsemid,color2
	move.w	#pulsedark,color3
.continue

			raster	#$100
	jsr		drawPixelThings
	tst.w	_copyLogoWaiter
	bne		.cx
	move.w	#40,pulse_text_offset
	jsr		copyPulseLogo2		

.cx
			raster	#$000

	tst.w	nextstepcounter
	bne		.next
	tst.w	vblcounter
	bne		.next
	move.w	#80,vblcounter
	addq.w	#1,466.w
	jmp		.out_init
.next
	; ---- END ----
	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop_flatline
	move.w	#-1,demo_exit

	move.w	#$2700,sr
	move.l	#default_vbl2,$70
	move.w	#$2300,sr

	rts

.list

	dc.w	$311,	$322,	$211,	$521,	$223,	$214,	$212,	$112,	$121,	$777,	$111,	$655		;1

	dc.w	$422,	$433,	$322,	$632,	$223,	$325,	$323,	$223,	$232,	$777,	$222,	$755		;2

	dc.w	$533,	$544,	$422,	$743,	$334,	$436,	$434,	$334,	$343,	$777,	$333,	$766		;3

;	dc.w	$644,	$655,	$533,	$754,	$445,	$547,	$545,	$445,	$454,	$777,	$444,	$777		;4

;	dc.w	$755,	$766,	$644,	$765,	$556,	$657,	$656,	$556,	$565,	$777,	$555,	$777		;5
	dc.w	$755,	$766,	$644,	$765,	$556,	$657,	$656,	$556,	$565,	$777,	$555,	$777		;6

;	dc.w	$766,	$777,	$755,	$776,	$667,	$767,	$767,	$667,	$676,	$777,	$666,	$777		;7
	dc.w	$766,	$777,	$755,	$776,	$667,	$767,	$767,	$667,	$676,	$777,	$666,	$777		;8

;	dc.w	$777,	$777,	$766,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;9
;	dc.w	$777,	$777,	$766,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;10
	dc.w	$777,	$777,	$766,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;11

;	dc.w	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;12
	dc.w	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;13
;	dc.w	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;14

;	dc.w	$777,	$777,	$766,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;15
;	dc.w	$777,	$777,	$766,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;16
	dc.w	$777,	$777,	$766,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;17

;	dc.w	$766,	$777,	$755,	$776,	$667,	$767,	$767,	$667,	$676,	$777,	$666,	$777		;18
	dc.w	$766,	$777,	$755,	$776,	$667,	$767,	$767,	$667,	$676,	$777,	$666,	$777		;19

;	dc.w	$755,	$766,	$644,	$765,	$556,	$657,	$656,	$556,	$565,	$777,	$555,	$777		;20
	dc.w	$755,	$766,	$644,	$765,	$556,	$657,	$656,	$556,	$565,	$777,	$555,	$777		;21

;	dc.w	$644,	$655,	$533,	$754,	$445,	$547,	$545,	$445,	$454,	$777,	$444,	$777		;22

	dc.w	$533,	$544,	$422,	$743,	$334,	$436,	$434,	$334,	$343,	$777,	$333,	$766		;23

	dc.w	$422,	$433,	$322,	$632,	$223,	$325,	$323,	$223,	$232,	$777,	$222,	$755		;24

	dc.w	$311,	$322,	$211,	$521,	$223,	$214,	$212,	$112,	$121,	$777,	$111,	$655		;25


.out_init
	move.w	#$2700,sr
	move.l 	#default_vbl2,$70
	move.w	#$2300,sr
				checkScreen


	move.l	#25-9-3-1,d7
	lea		.list,a0

.loop
	nop
	nop
	wait_for_vbl
	swapscreens
	nop
	nop
	lea		$ffff8240+8,a1
	REPT 6
	move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.loop

	move.w	#$2700,sr
	move.l	#curtain_vbl,$70
	move.w	#$2300,sr

.out
	swapscreens
	wait_for_vbl
		raster	#$070
	move.w	.bothalf,d6
	jsr		doBottomHalf
	move.w	.bothalfadd,d0
	add.w	d0,.bothalf

	move.w	.tophalf,d4
	jsr		doTopHalf
	move.w	.tophalfadd,d0
	add.w	d0,.tophalf

	subq.w	#1,.addcounter
	bne		.continue2
	cmp.w	#4,.bothalfadd	
	beq		.continue2
		addq.w	#1,.bothalfadd	
		add.w	#160,.tophalfadd
		move.w	.addcounterinc,d0
		move.w	d0,.addcounter
		sub.w	#8,.addcounterinc
.continue2
	raster	#$000

	subq.w	#1,vblcounter
	bne		.notdone
		rts
.notdone
	cmp.b 	#$39,$fffffc02.w
	bne		.out
	move.w	#-1,demo_exit
	rts

.bothalf			dc.w	58
.tophalf			dc.w	0
.bothalfadd			dc.w	1
.tophalfadd			dc.w	160
.addcounter			dc.w	2
.addcounterinc		dc.w	30	
	rts

curtain_vbl
		addq.w		#1,$466.w
	incSync
	incSync
	move.l	screenpointer2,$ffff8200

	movem.l	d0/a0,-(sp)

	move.l	sndh_pointer,a0
	jsr		8(a0)

	subq.w	#1,_localcounter
	bge		.skip

	move.w	dotsCurrentPos,d0

	sub.w	#2,dotsCurrentPos
	cmp.w	#1,dotsCurrentPos				;bgt			!TODO
	bge		.gogo
		move.w	#1,dotsCurrentPos
.gogo
	add.w	#4,dotsWidth
	cmp.w	#199,dotsWidth
	ble		.gogo2
		move.w	#199,dotsWidth
.gogo2

	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	d0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #dots_top1,$120.w        ;Install our own Timer B
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on

.skip
	movem.l	(sp)+,d0/a0

	rte

dotsCurrentPos
	dc.w	99
dotsWidth
	dc.w	0

dots_top1
	move.w	#$111,$ffff8240
	pushd0
	move.w	dotsWidth,d0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	d0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #dots_bot1,$120.w        ;Install our own Timer B
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	rte

dots_bot1
	move.w	#$0,$ffff8240
	pushd0
	move.w	#200,d0
	sub.w	dotsCurrentPos,d0
	sub.w	dotsWidth,d0
	popd0

	clr.b	$fffffa1b.w			;Timer B control (stop)
	rte

_localcounter	dc.w	30





;;;;;;;;;;;;;; GRID TRANS START ;;;;;;;;
;;;;;;;;;;;;;; GRID TRANS START ;;;;;;;;
;;;;;;;;;;;;;; GRID TRANS START ;;;;;;;;
doGridTrans
.init

	move.l	screenpointer,a0
	jsr		clear4bpl
	move.l	screenpointer2,a0
	jsr		clear4bpl
	move.l	screenpointer3,a0
	jsr		clear4bpl

	move.w	#$2700,sr
	move.l	#gridVBL,$70
	move.l	#dummy,$120
	move.w	#$2300,sr
		wait_for_vbl


	jsr 	generateStartX			
	jsr 	generateEndX		
	jsr		init_exp_log_grid
	jsr		initRasterGridObject
			exitOnSpace


	move.w	#8,stepSpeedX
	move.w	#0,stepSpeedY
	move.w	#0,stepSpeedZ

	move.w	#0,$ffff8240
.mainloop2
	swapscreens
	wait_for_vbl
;	move.w	#$070,bgcolor
	raster	#$070
	jsr		clearLines
	jsr		doGridRotation
	jsr		doGridColors
	jsr		doGrid

	subq.w	#1,.counter
	bne		.x
		rts
.x

	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop2
	move.w	#-1,demo_exit
	rts

.counter		dc.w	347+128
grid_stopper	dc.w	33


;;;;;;;;;;;;;; GRID TRANS ROUT ;;;;;;;;;
;;;;;;;;;;;;;; GRID TRANS ROUT ;;;;;;;;;
;;;;;;;;;;;;;; GRID TRANS ROUT ;;;;;;;;;
init_exp_log_grid:   
    lea     log_src,A4    		; skip 0
    move.l  logpointer,d5
    move.l  d5,a2
    moveq   #-2,d6           	; index

    move.w  #-EXPS*2,(A2)+  	; NULL
    move.w  #LOGS-1-1,D7
.il:
    	move.w  (A4)+,D0        ; log
    	add.w   D0,D0
    	move.w  d0,(a2)+        ; pos2

    	add.w   #EXPS*2,D0      ; NEG

    	move.w  d6,d5           ; take negative value into account
    	move.l  d5,a3
    	move.w  d0,(a3)         ; move in value

    	subq.w  #2,d6
    dbra    D7,.il


	lea		$3000,a0
	move.w	#0,d0
.cl
		move.w	d0,(a0)+
		cmp.w	#$5000,a0
		bne		.cl



    move.w  #EXPS*2,D7
    lea     exp_src,a3

    lea  	$5000,a4
    lea     (a4,d7.w),a5
    lea     (a5,d7.w),a6

    move.w  #EXPS-1,D7
.ie2:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1

    	; this is specific for the rotation code
  		asr.w	#7,d0		; fix this in exptable
		add.w	d0,d0		; fix this in exptable
		add.w	d0,d0
		asr.w	#7,d1		; fix this in exptable
		add.w	d1,d1		; fix this in exptable
		add.w	d1,d1
		; end specific code
		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+

    dbra    D7,.ie2
    ; range 1000 to B000

    rts

doGrid
	lea		projectedPolySource,a6					
	move.l	a6,projectedPolySourcePointer
	move.l	screenpointer2,a0			;20		; smc = -8
	checkScreen
	move.l	a0,usp
	jsr		drawLineGrid
	raster #$770
	move.l	usp,a0
	jsr		copyLinesHalf
	raster	#$077

x set 0
	REPT 4
	move.l	usp,a0			;20		; smc = -8
	add.w	#20*160*x+10*160,a0
	jsr		drawLineGridInv
	move.l	projectedPolySourcePointer,a0
	addq.l	#2,a0
	move.l	a0,projectedPolySourcePointer
	raster #$770
	move.l	usp,a0
	add.w	#20*160*x+10*160,a0
	jsr		copyLines
	raster	#$077
x set x+1

	move.l	usp,a0			;20		; smc = -8
	add.w	#20*160*x+10*160,a0
	jsr		drawLineGrid
	raster #$770
	move.l	usp,a0
	add.w	#20*160*x+10*160,a0
	jsr		copyLines
	raster	#$077
x set x+1

	ENDR

	move.l	usp,a0			;20		; smc = -8
	add.w	#20*160*x+10*160,a0
	jsr		drawLineGridInv
	move.l	projectedPolySourcePointer,a0
	addq.l	#2,a0
	move.l	a0,projectedPolySourcePointer
	raster #$770
	move.l	usp,a0
	add.w	#20*160*x+10*160,a0
	jsr		copyLines
	raster	#$077
x set x+1

	move.l	usp,a0			;20		; smc = -8
	add.w	#20*160*x+10*160,a0
	jsr		drawLineGrid
	raster #$770
	move.l	usp,a0
	add.w	#20*160*x+10*160,a0
	jsr		copyLinesHalf
	raster	#$077



	raster	#$777

	rts

doGridColors
	lea		gridSteps,a0
	lea		gridColorSource,a1
	lea		grid_colors,a2
	move.w	#11-1,d7

.olx
		move.w	(a0)+,d0
		; divide by 16
		add.w	d0,d0		;	*2
		movem.l	(a1,d0.w),d1-d4
		movem.l	d1-d4,(a2)
		add.w	#16,a2
	dbra	d7,.olx
	rts

doGridRotation
	lea		projectedPolySource,a6					
	move.l	a6,projectedPolySourcePointer

	lea		gridSteps,a0
	move.l	a0,stepPointer

	rept 11
		jsr		fixStep	
		jsr		doRotationChecker				; blue
	endr
	rts

clearLines
	move.l	screenpointer2,a0
	checkScreen
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
o set 0
y set o
			movem.l	d0-d7/a1-a6,y(a0)
			movem.l	d0-d7/a1-a6,y+56(a0)
			movem.l	d0-d7/a1-a4,y+112(a0)
o set o+10*160

	REPT 10
y set o
			movem.l	d0-d7/a1-a6,y(a0)
			movem.l	d0-d7/a1-a6,y+56(a0)
			movem.l	d0-d7/a1-a4,y+112(a0)
o set o+20*160
	ENDR
	rts

gridVBL
	addq.w		#1,$466.w
	incSync
	move.l	screenpointer2,$ffff8200

	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b  #10,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.l	#timer_b_grid1,$120.w

	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on

	pusha0
	lea		grid_colors,a0
	move.l	(a0)+,$ffff8240+2*1		; color 1	bpl 1
	move.l	(a0)+,$ffff8240+2*3		; color 3	bpl 1 + 2
	move.l	(a0)+,$ffff8240+2*5		; color 3	bpl 1 + 4
	move.l	(a0)+,$ffff8240+2*7		; color 3	bpl 1 + 8
	move.l	a0,grid_color_pointer
	move.l	sndh_pointer,a0
	jsr		8(a0)
	popa0


	rte


timer_b_grid1
	pusha0
	move.l	grid_color_pointer,a0
	move.l	(a0)+,$ffff8240+2*1		; color 1	bpl 1
	move.l	(a0)+,$ffff8240+2*3		; color 3	bpl 1 + 2
	move.l	(a0)+,$ffff8240+2*5		; color 3	bpl 1 + 4
	move.l	(a0)+,$ffff8240+2*7		; color 3	bpl 1 + 8
	move.l	a0,grid_color_pointer
	popa0

	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b  #20,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.l	#timer_b_grid2,$120.w

	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on
	rte


timer_b_grid2
	pusha0
	move.l	grid_color_pointer,a0
	move.l	(a0)+,$ffff8240+2*1		; color 1	bpl 1
	move.l	(a0)+,$ffff8240+2*3		; color 3	bpl 1 + 2
	move.l	(a0)+,$ffff8240+2*5		; color 3	bpl 1 + 4
	move.l	(a0)+,$ffff8240+2*7		; color 3	bpl 1 + 8
	move.l	a0,grid_color_pointer
	popa0
	rte

initRasterGridObject
	move.w	#16,number_of_vertices
	move.w	#160*4,vertices_xoff
	move.w	#0,vertices_yoff

	move.l	tableSourcePointer,a1
	move.l	a1,currentObjectPointer

	lea		coordsourceRasterGrid,a0
	move.l	logpointer,d6
	move.w	number_of_vertices,d7
	subq.w	#1,d7
	move.w	#$5000,d0						; base address of low memory

.loop
	REPT 3
		move.w	(a0)+,d6			;8
		add.w	d6,d6			;4
		move.l	d6,a2			;4
		move.w	(a2),d1			;8
		add.w	d0,d1			;4
		move.w	d1,(a1)+		;8		-> 36*3
	ENDR
	dbra	d7,.loop
	rts

generateStartX
	move.l	x_start_pointer_1bpl,a0				; 20 * 16 * 4 = 1280 
	move.l	#20-1,d7
	move.l	#0,d0 		; val
.ol
	moveq	#16-1,d6	; do 16 il
	moveq	#-1,d1		; %1111111111111111
.il
		move.w	d0,(a0)+	; val,
		move.w	d1,(a0)+	; mask

		lsr.w	#1,d1
	dbra	d6,.il
	add.w	#8,d0
	dbra	d7,.ol
	rts


generateEndX
	move.l	x_end_pointer_1bpl,a0				; 20 * 16 * 4 = 1280
	move.l	#20-1,d7
	moveq	#0,d0
.ol
	moveq	#16-1,d6
	move.w	#%1000000000000000,d1
.il
		move.w	d0,(a0)+
		move.w	d1,(a0)+

		asr.w	#1,d1
	dbra	d6,.il
	add.w	#8,d0
	dbra	d7,.ol
	rts

drawLineGridInv
	lea		colordraw,a5
	move.l	a0,a1
	move.l	x_start_pointer_1bpl,a3		;20		; smc = -8
	move.l	x_end_pointer_1bpl,a4		;20		; smc = -8
	move.l	projectedPolySourcePointer,a2
	moveq	#-1,d6
	move.w	#7-1,d7
	add.w	#2,a2
	moveq	#8,d0
	jmp		doline

drawLineGrid
	lea		colordraw,a5
	move.l	a0,a1
	move.l	x_start_pointer_1bpl,a3		;20		; smc = -8
	move.l	x_end_pointer_1bpl,a4		;20		; smc = -8
	move.l	projectedPolySourcePointer,a2
	moveq	#-1,d6
	move.w	#8-1,d7
	moveq	#8,d0

doline
	moveq	#0,d1
	move.l	a1,a0
	move.w	(a2)+,d4
	move.w	(a2)+,d5
	cmp.w	d4,d5
	bne		.draw
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.draw
	cmp.w	d4,d5
	bge		.go
		moveq	#1,d1
		exg	d4,d5
.go
	subq.w	#4,d5

	move.w	(a3,d4.w),d2
	move.w	2(a3,d4.w),d4

	add.w	d2,a0

	move.w	(a4,d5.w),d3
	move.w	2(a4,d5.w),d5

	tst.w	d1
	bne		.othercolor

	move.l	(a5,d2.w),a6
	jmp		(a6)

.othercolor
	move.l	(a5,d2.w),a6
	jmp		(a6)


drawLineColor1
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,(a0)
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,(a0)
	or.w	d5,8(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,(a0)
	move.w	d6,8(a0)
	or.w	d5,16(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts



drawLineColor2
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,+2(a0)
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,+2(a0)
	or.w	d5,8+2(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,+2(a0)
	move.w	d6,8+2(a0)
	or.w	d5,16+2(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts


drawLineColor3
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,(a0)
		or.w	d5,+2(a0)
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	or.w	d5,8-4(a0)
	or.w	d5,8+2-4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	move.l	d6,8-4(a0)
	or.w	d5,16-4(a0)
	or.w	d5,16+2-4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

drawLineColor4
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,+4(a0)
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,+4(a0)
	or.w	d5,8+4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,+4(a0)
	move.w	d6,8+4(a0)
	or.w	d5,16+4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts


drawLineColor5
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,(a0)
		or.w	d5,+4(a0)
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,(a0)
	or.w	d4,+4(a0)
	or.w	d5,8(a0)
	or.w	d5,8+4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,(a0)
	or.w	d4,+4(a0)
	move.w	d6,8(a0)
	move.w	d6,8+4(a0)
	or.w	d5,16(a0)
	or.w	d5,16+4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts


drawLineColor6
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,+2(a0)
		or.w	d5,+4(a0)
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,+2(a0)
	or.w	d4,+4(a0)
	or.w	d5,8+2(a0)
	or.w	d5,8+4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,+2(a0)
	or.w	d4,+4(a0)
	move.l	d6,8+2(a0)
	or.w	d5,16+2(a0)
	or.w	d5,16+4(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts


drawLineColor7
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,(a0)+
		or.w	d5,(a0)+
		or.w	d5,(a0)+
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	add.w	#2,a0
	or.w	d5,(a0)+
	or.w	d5,(a0)+
	or.w	d5,(a0)+
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,(a0)+				;12
	or.w	d4,(a0)+			;16
	or.w	d4,(a0)+			;16
	add.w	#2,a0
	move.l	d6,(a0)+
	move.w	d6,(a0)+
	add.w	#2,a0
	or.w	d5,(a0)+
	or.w	d5,(a0)+
	or.w	d5,(a0)+
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

drawLineColor8
	sub.w	d2,d3
	bne		.somestuff
		and.w	d4,d5
		or.w	d5,+6(a0)
		dbra	d7,doline
		move.l	a2,projectedPolySourcePointer
		rts
.somestuff
	cmp.w	d0,d3
	bne		.useswhole
.nowhole
	or.w	d4,+6(a0)
	or.w	d5,8+6(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts

.useswhole	
	or.w	d4,+6(a0)
	move.w	d6,8+6(a0)
	or.w	d5,16+6(a0)
	dbra	d7,doline
	move.l	a2,projectedPolySourcePointer
	rts


fixStep
	move.l	stepPointer,a0
	move.w	(a0),d2
	beq		.dostop
.dostep
    add.w   stepSpeedX,d2								;16
    cmp.w   #256*2*2,d2										;4
    blt     .goodX										;12
        sub.w   #256*2*2,d2									;4
.goodX
	move.w	d2,(a0)+
	move.l	a0,stepPointer
    rts
.dostop
	tst.w	grid_stopper
	beq		.realstop
	subq.w	#1,grid_stopper
	jmp		.dostep
.realstop
	rts


copyLinesHalf
y set 0
	movem.l	y(a0),d0-d7/a1-a6			;8+6 = 14 = 7 block
	REPT 9
		movem.l	d0-d7/a1-a6,y+160(a0)
y set y+160
	ENDR
y set 0
	movem.l	y+56(a0),d0-d7/a1-a6			;8+6 = 14 = 7 block
	REPT 9
		movem.l	d0-d7/a1-a6,y+160+56(a0)
y set y+160
	ENDR
y set 0
	movem.l	y+112(a0),d0-d7/a1-a4			;8+6 = 14 = 7 block
	REPT 9
		movem.l	d0-d7/a1-a4,y+160+112(a0)
y set y+160
	ENDR
	rts



copyLines
y set 0
	movem.l	y(a0),d0-d7/a1-a6			;8+6 = 14 = 7 block
	REPT 19
		movem.l	d0-d7/a1-a6,y+160(a0)
y set y+160
	ENDR
y set 0
	movem.l	y+56(a0),d0-d7/a1-a6			;8+6 = 14 = 7 block
	REPT 19
		movem.l	d0-d7/a1-a6,y+160+56(a0)
y set y+160
	ENDR
y set 0
	movem.l	y+112(a0),d0-d7/a1-a4			;8+6 = 12 = 6 block
	REPT 19
		movem.l	d0-d7/a1-a4,y+160+112(a0)
y set y+160
	ENDR
	rts

doRotationChecker
	cmp.w	#-256,d2
	bge		.gogogo
		move.w	number_of_vertices,d5				; 20
		move.l	projectedPolySourcePointer,a6	
		subq	#1,d5								; 4
.fill
		move.w	#160*4,(a6)+
		dbra	d5,.fill
		move.l	a6,projectedPolySourcePointer
		rts
.gogogo
    move.w  currentStepY,d4								;16
.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		sintable,a0								;12
	lea		sintable+256,a1							;12

	move.w	(a0,d2.w),d1					; sin(A)	;around z axis		16
	move.w	(a1,d2.w),d2					; cos(A)						16

	move.l	#0,a0
	move.w	#$007F,d4

	move.l	logpointer,d0		;20
.xx
	move.w	d2,d7						;						4
	muls	d4,d7						;						42				1
	asr.w	#7,d7						;xx,zz					24	
	move.w	d7,d0						;						18
.xy
	move.w	d4,d7						;						4
	muls	d1,d7						;						42				2
	asr.w	#7,d7						;						24
;;;;;;;;;;;;;;;;;; CONSTANTS DONE ;;;;;;;;;;;;;;;;;;



.setupComplete						
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xxpg+2

	move.w	d3,d0	;xz			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xzpg+2

	move.w	d7,d0	;xy			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xypg+2


	move.l	currentObjectPointer,a5					; 20	
	move.l	projectedPolySourcePointer,a6	
	move.w	number_of_vertices,d5				; 20
	subq	#1,d5								; 4

	move.w	vertices_xoff,d6
	move.w	vertices_yoff,d7

gridRotationLoop

	movem.w	(a5)+,a0-a2	;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
	;	x	
xxpg	move.w		1234(a0),d0	;12				xx is offset into table for the value, smc
xypg	add.w		1234(a1),d0	;12				xy is offset into table for the value, smc
xzpg	add.w		1234(a2),d0	;12				xz is offset into table for the value, smc
	add.w		d6,d0
	move.w		d0,(a6)+

	;	y
;	move.w		d0,(a6)+

	dbra	d5,gridRotationLoop
	move.l	a6,projectedPolySourcePointer
	rts

;;;;;;;;;;;;;; GRID TRANS END ;;;;;;;;;;
;;;;;;;;;;;;;; GRID TRANS END ;;;;;;;;;;
;;;;;;;;;;;;;; GRID TRANS END ;;;;;;;;;;	
;;;;;;;;;;;;;; PULSE ROUTS ;;;;;;;;;;;;
;;;;;;;;;;;;;; PULSE ROUTS ;;;;;;;;;;;;
;;;;;;;;;;;;;; PULSE ROUTS ;;;;;;;;;;;;

;given d0, startx
;given d1, starty
;given d2, nr of blocks
;given d3, nr of lines
;copy square to buffer from a0 to a1 (sequential)


; left top block
;move
block_1_xoff	equ 5			; utmost left block
block_1_yoff	equ 32
block_1_width	equ 4
block_1_height	equ 51
block_1_switch	equ	0

block_1a_xoff	equ 9
block_1a_yoff	equ 57
block_1a_width	equ 3
block_1a_height equ 1
block_1a_switch equ 0

;or
block_2_xoff	equ 6			; utmost left block
block_2_yoff	equ 82
block_2_width	equ 1
block_2_height	equ 15
block_2_switch	equ	15

;move
block_3_xoff	equ 7			; top left block, no overlap
block_3_yoff	equ 83
block_3_width	equ 5
block_3_height	equ 20
block_3_switch	equ	0

;or
block_4_xoff	equ	7
block_4_yoff	equ 51
block_4_width	equ 5
block_4_height	equ 65
block_4_switch	equ	10

;or
block_5_xoff	equ	13
block_5_yoff	equ 55
block_5_width	equ 4
block_5_height	equ 64
block_5_switch	equ	26

;or
block_6_xoff	equ	13
block_6_yoff	equ 117
block_6_width	equ 1
block_6_height	equ 46
block_6_switch	equ	18

block_7_xoff	equ 12
block_7_yoff	equ 55
block_7_width	equ	1
block_7_height	equ 68
block_7_switch	equ 32

block_8_xoff	equ 12
block_8_yoff	equ 53
block_8_width	equ	1
block_8_height	equ 12
block_8_switch	equ 8

; 1: block
; 2: startx
; 3: starty
; 4: width
; 5: height
orBlock	macro
	move.l	screenpointer2,a0			; screen pointer
	lea		\1,a1						; get source in a1
	move.w	d4,d5						; decreased y-offset
	neg		d5							; use it as negative
	add.w	#\3,d5						; add the height of the picture	
	bge		.normal\@
		neg.w	d5
		ext.l	d5
		divs	#160,d5
		sub.w	d5,d7
		blt		.done\@
		asl.w	#3,d5
		move.w	#\4,d3
		muls	d3,d5
		add.w	d5,a1
		jmp		.ol\@
.normal\@
	add.w	d5,a0
.ol\@
o set \2*8
	REPT \4
		move.l	(a1)+,d0
		or.l	d0,o(a0)
		move.l	(a1)+,d0
		or.l	d0,o+4(a0)
o set o+8
	ENDR
	add.w	#160,a0
	dbra	d7,.ol\@

; now clean up the last line
	move.w	#\4,d0
	asl.w	#3,d0
	sub.w	d0,a1
o set \2*8
	REPT \4
		move.l	(a1)+,d0
		not.l	d0
		and.l	d0,o(a0)
		move.l	(a1)+,d0
		not.l	d0
		and.l	d0,o+4(a0)
o set o+8
	ENDR	
	move.w	#-1,moveDone
.done\@
	endm


moveBlock	macro
	moveq	#0,d2
	move.l	screenpointer2,a0			; screen pointer
	lea		\1,a1						; get source in a1
	move.w	#\3,d5
	sub.w	d4,d5
	bge		.normal\@
		moveq	#1,d2
		neg.w	d5
		ext.l	d5
		divs	#160,d5
		sub.w	d5,d7
		blt		.done\@
		asl.w	#3,d5
		move.w	#\4,d3
		muls	d3,d5
		add.w	d5,a1
	jmp		.ol\@

.normal\@
	add.w	d5,a0
.ol\@
o set \2*8
	REPT \4
		move.l	(a1)+,o(a0)
		move.l	(a1)+,o+4(a0)
o set o+8
	ENDR
	add.w	#160,a0
	dbra	d7,.ol\@
	move.w	#-1,moveDone
.done\@
	tst.w	d2
	beq		.exit\@
	move.l	#20-1,d7
	moveq	#0,d0
.ol2\@
o set \2*8
	REPT \4
		move.l	d0,o(a0)
		move.l	d0,o+4(a0)
o set o+8
	ENDR
	add.w	#160,a0
	dbra	d7,.ol2\@

.exit\@
	endm


moveDone	dc.w	-1

doTopHalf
	tst.w	moveDone
	beq		.exit

	move.w		#0,moveDone

	move.l		#block_1_height-1,d7
	moveBlock	block1,block_1_xoff,block_1_yoff*160,block_1_width

	move.l		#block_3_height-1,d7
	moveBlock	block3,block_3_xoff,block_3_yoff*160,block_3_width


	;	d4 is how many lines moved up
	;	first, this comes from the 3rd argument
	;	after, it goes from d7

	move.l		#block_4_height-1,d7
	cmp.w		#block_4_switch*160,d4
	blt			.or4
		moveBlock	block4,block_4_xoff,block_4_yoff*160,block_4_width
		jmp			.4done
.or4	
	orBlock		block4,block_4_xoff,block_4_yoff*160,block_4_width
.4done

	move.l		#block_5_height-1,d7
	cmp.w		#block_5_switch*160,d4
	blt			.or5
		moveBlock	block5,block_5_xoff,block_5_yoff*160,block_5_width
		jmp			.5done
.or5
	orBlock		block5,block_5_xoff,block_5_yoff*160,block_5_width
.5done

	move.l		#block_6_height-1,d7
	cmp.w		#block_6_switch*160,d4
	blt			.or6
		moveBlock	block6,block_6_xoff,block_6_yoff*160,block_6_width
		jmp			.6done
.or6
	orBlock		block6,block_6_xoff,block_6_yoff*160,block_6_width
.6done

	move.l		#block_8_height-1,d7
	cmp.w		#block_8_switch*160,d4
	blt			.8done
		moveBlock	block8,block_8_xoff,block_8_yoff*160,block_8_width
.8done

	move.l		#block_7_height-1,d7
	cmp.w		#block_7_switch*160,d4
	blt			.or7
		moveBlock	block7,block_7_xoff,block_7_yoff*160,block_7_width
		jmp			.7done
.or7
	orBlock		block7,block_7_xoff,block_7_yoff*160,block_7_width
.7done

	move.l		#block_2_height-1,d7
	cmp.w		#block_2_switch*160,d4
	blt			.or2
		moveBlock	block2,block_2_xoff,block_2_yoff*160,block_2_width
		jmp			.2done
.or2
	orBlock		block2,block_2_xoff,block_2_yoff*160,block_2_width
.2done

.exit
	rts

_copyTimes	dc.w	2
copyPulseLogo2
	tst.w	_copyTimes
	beq		.done
	subq.w	#1,_copyTimes
	lea		pulseLogoNew,a2
	move.l	screenpointer2,a0
	add.w	#31*160,a0
	move.l	#200-31-30-1,d7
.ol
	move.w	#20-1,d6
.il
		move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
	dbra	d6,.il
	dbra	d7,.ol
.done
	rts

initPulseColors
;	color 1:		bpl 1			; or	1				1	42
;	color 2:		bpl 1+2			; or 	2				3	46
;	color 3:		bpl 1+2+3		; or	3				7	4E
;	color 4:		bpl 1+3			; and 	neg	2			5	4A
;	color 5:		bpl 3			; and	neg 1			4	48
;	color 6:		bpl	2+3			; or	2				6	4C
;	color 7:		bpl	2			; and	neg 3			2	44
color1	equ $ffff8242
color2	equ $ffff8246
color3	equ $ffff8244

;red $500,$400,$200
;green $142,$131,$021
;blue $133,$023,$012

	move.w	#pulsebright,color1
	move.w	#pulsemid,color2
	move.w	#pulsedark,color3

	move.w	#0,$ffff8240
	move.w	#0,$ffff8248
	move.w	#0,$ffff824A
	move.w	#0,$ffff824C
	move.w	#0,$ffff824E
	move.w	#0,$ffff8250
	move.w	#0,$ffff8252
	move.w	#0,$ffff8254
	move.w	#0,$ffff8256
	move.w	#0,$ffff8258
	move.w	#0,$ffff825A
	move.w	#0,$ffff825C
	move.w	#0,$ffff825E
	rts

pulse_text_color
	cmp.w	#2,pulse_text_counter					; check if throttle is hit
	bne		.cont							; if not, exit
		move.w	#0,pulse_text_counter				; if so, start new counter
		tst.w	pulse_color_direction		; check direction
		blt		.negative					; if < 0, then negative
			add.w	#2,pulse_color_counter
			lea		pulse_color_list,a0
			add.w	pulse_color_counter,a0
			move.w	(a0)+,$ffff8240+2*8
			cmp.w	#74,pulse_color_counter
			bne		.cont
				move.w	#-1,pulse_color_direction
				rts
.negative
			sub.w	#2,pulse_color_counter
			lea		pulse_color_list,a0
			add.w	pulse_color_counter,a0
			move.w	(a0)+,$ffff8240+2*8
			tst.w	pulse_color_counter
			bne		.cont
				move.w	#1,pulse_color_direction
				add.w	#4,pulse_text_offset
.cont
	rts

line5	
	move.l	screenpointer2,a1
	add.w	#6+88*160+4*8,a1		; bitplane 4, 92 lines, 5 blocks to the right
	move.l	#28-1,d7
.ol
	move.l	#12-1,d6
.il
		move.w	#0,(a1)
		add.w	#8,a0
		add.w	#8,a1
		dbra	d6,.il
	add.w	#160-12*8,a0
	add.w	#160-12*8,a1
	dbra	d7,.ol
	rts

line0
	rts


line1
	lea		line1text,a0
	move.l	screenpointer2,a1
	add.w	#6+88*160+4*8,a1		; bitplane 4, 92 lines, 5 blocks to the right
	move.l	#28-1,d7
.ol
	move.l	#12-1,d6
.il
		move.w	(a0)+,(a1)
		add.w	#8,a1
		dbra	d6,.il
	add.w	#160-12*8,a1
	dbra	d7,.ol

	rts


line2
	lea		line2text,a0
	move.l	screenpointer2,a1
	add.w	#6+88*160+4*8,a1		; bitplane 4, 92 lines, 5 blocks to the right
	move.l	#28-1,d7
.ol
	move.l	#12-1,d6
.il
		move.w	(a0)+,(a1)
		add.w	#8,a1
		dbra	d6,.il
	add.w	#160-12*8,a1
	dbra	d7,.ol

	rts


line3
	lea		line3text,a0
	move.l	screenpointer2,a1
	add.w	#6+88*160+4*8,a1		; bitplane 4, 92 lines, 5 blocks to the right
	move.l	#28-1,d7
.ol
	move.l	#12-1,d6
.il
		move.w	(a0)+,(a1)
		add.w	#8,a1
		dbra	d6,.il
	add.w	#160-12*8,a1
	dbra	d7,.ol
	rts


line4
	lea		line4text,a0
	move.l	screenpointer2,a1
	add.w	#6+88*160+4*8,a1		; bitplane 4, 92 lines, 5 blocks to the right
	move.l	#28-1,d7
.ol
	move.l	#12-1,d6
.il
		move.w	(a0)+,(a1)
		add.w	#8,a1
		dbra	d6,.il
	add.w	#160-12*8,a1
	dbra	d7,.ol
	rts

nextstepcounter	dc.w	1

pulse_vbl
		addq.w		#1,$466.w
	incSync
	incSync
	addq.w	#2,vblcounter
	move.w	screenpointershifter,$ffff8200
	pusha0
	pushd0
	tst.w	nextstepcounter
	beq		.x
	cmp.w	#40,pulse_text_offset
	bne		.x
	lea		pulse_y_vals,a0
	add.w	vblcounter,a0
	move.w	(a0),d0
	; we have 13 colors
	 add.w	d0,d0		;4
	 add.w	d0,d0		;4
	 move.w d0,a0		;4	
	 add.w	d0,d0		;4
	 add.w	a0,d0		;4 = 20
;	muls	#12,d0
	lea		pulse_y_colors_list,a0
	add.w	d0,a0
	move.l	(a0)+,$ffff8240+2*4
	move.l	(a0)+,$ffff8240+2*6
	move.l	(a0)+,$ffff8240+2*8
	move.l	(a0)+,$ffff8240+2*10
	move.l	(a0)+,$ffff8240+2*12
	move.l	(a0)+,$ffff8240+2*14

	cmp.w	#206*2,vblcounter
	bne		.x
		subq	#1,nextstepcounter
.x
	popd0

	IFNE playmusic
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	popa0
	rte

pulse_timer_b
	pusha0
		move.l	rasterpointer,a0
		move.w	(a0)+,$ffff8240
		move.l	a0,rasterpointer
	popa0

	subq.w	#1,barcounter
	bne		.cont
	    move.b  #0,$fffffa1b.w    
		move.l	#pulse_timer_b2,$120.w
	    move.b  #25,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
	    rte
.cont

    move.b  #0,$fffffa1b.w    
	move.l	#pulse_timer_b,$120.w
    move.b  #25,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
	rte	

pulse_timer_b2
	pusha0
		move.l	rasterpointer,a0
		move.w	(a0)+,$ffff8240
		move.l	a0,rasterpointer
	popa0

    move.b  #0,$fffffa1b.w    
	move.l	#pulse_timer_b_end,$120.w
    move.b  #24,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
    rte


pulse_timer_b_end
	move.w	#0,$ffff8240
    move.b  #0,$fffffa1b.w    
    rte

; scan shit from left to right
; %1000000000000000
; given a 3x3 grid :
;
;	1	2	3
;	
;	4	5	6
;	
;	7	8	9
;x
; consider 5 as the current pixel,
;	- add current pixel coords to the list
;	- remove current pixel from source picture
;	- explore in the current order:
;		6,3,9,2,8,1,7,4
;	- first hit:
;		- make found pixel current pixel
;		- goto x
;	
; drawing method shouldbe:
;	- get current pointer
;	- find next pointer
;	- if next pointer is found, add +1 to drawing count, if count < 7
; 382 before it loops
_copyLogoWaiter	dc.w	2

drawPixelThings
	move.w	#64*4,d2												; some magic stuff, 64 points?
	move.l	screenpointer2,d6										; screen pointer
	move.l	d6,d5													; save screenpointer
	move.l	x_block_add_pointer,d0									; x_block
	move.l	d0,d3													; save

	lea		.colorTable,a0
	moveq	#0,d4
	move.w	colorListOffset,d4
	move.l	currentPointAddress,a6			; current head
	; make sure we dont have double -1
	move.w	(a6),d0
	bge		.continue
		addq.w	#4,colorListOffset
		cmp.w	#64*4,colorListOffset
		beq		.loop
		jmp		.found
.loop
		move.w	#0,itercount
		move.w	#0,colorListOffset
		subq.w	#1,_flatlinecount
		bgt		.skip
		lea		points,a6
		move.l	a6,currentPointAddress
		move.w	#0,vblcounter
		move.w	#$2700,sr		
		move.l 	#pulse_vbl,$70
		move.w	#$2300,sr
		subq.w	#1,_copyLogoWaiter
		rts
.skip	
		move.w	#0,vblcounter
		lea		flatline,a6
		move.l	a6,currentPointAddress
		rts

.continue
	; search the next pointer
.search
	; search for first x-value that is not d0
	lea		4(a6),a6
	cmp.w	(a6),d0
	beq		.search
	; when we hit here, we know that a6 points to the first x-value thats different, so from here we can move back
	; store this for the next iteration
.found
	move.l	a6,d2		
	move.w	d0,d7						; d6 is current streak
	move.l	(a0,d4.w),a5
	; draw pixel

.drawPixel
	move.w	-(a6),d5					; y
	move.w	-(a6),d0					; x
	cmp.w	d0,d7						; streak ended?
	bne		.streakend

.continuestreak
	move.w	d0,d3						; we draw 2 by 2
	addq.w	#4,d3						; x = x+1 for 2 by 2 block
	move.w	d5,d6

	move.l	d0,a3					;4		; first pixel x
	add.w	(a3)+,d6				;8		;	x offset
	move.l	d6,a2					;4		; screen + offset for x		
	move.w	(a3)+,d6				;8		; mask

	move.l	d3,a4					;4		; pixel + 1
	add.w	(a4)+,d5				;8
	move.l	d5,a3							; screen + offset for x+1
	move.w	(a4)+,d5						; mask

	; masks and addresses sreen:
	;	x	> a2 screen, d6 mask
	;	x+1	> a3 screen, d5 mask
	jmp		(a5)

.streakend
	cmp.w	itercount,d4
	bne		.checkmore
		add.w	#4,itercount
		move.l	d2,currentPointAddress
		rts

.checkmore
	addq.w	#4,d4					; here we change the drawing pixel method, bump offset by 4
	cmp.w	#62*4,d4						; check if we should stop drawing or not
	bne		.letsgo
		move.l	d2,currentPointAddress
		rts
.letsgo
	move.w	d0,d7					; we have a new stream, so change the x value 
	move.l	(a0,d4.w),a5
	jmp		.continuestreak			; lets draw!

.colorjump
.color1								; bpl 1
	or.w	d6,(a2)					;2
	or.w	d6,160(a2)				;4
	or.w	d5,(a3)					;2
	or.w	d5,160(a3)				;4
	not.w	d6
	not.w	d5
	and.w	d6,2(a2)
	and.w	d6,162(a2)
	and.w	d6,4(a2)
	and.w	d6,164(a2)
	and.w	d6,6(a2)
	and.w	d6,166(a2)
	and.w	d5,2(a3)
	and.w	d5,162(a3)
	and.w	d5,4(a3)
	and.w	d5,164(a3)
	and.w	d5,6(a3)
	and.w	d5,166(a3)

	jmp		.drawPixel				;4		16
	ds.b	8
.color2								; bpl 1+2
	or.w	d6,2(a2)				;4
	or.w	d6,160+2(a2)			;4
	or.w	d5,2(a3)				;4
	or.w	d5,160+2(a3)			;4
	jmp		.drawPixel				;4		;20
	ds.b	4

.color3		
	not.w	d5
	not.w	d6						; bpl 2

	and.w	d6,(a2)				;4
	and.w	d6,160(a2)			;4
	and.w	d5,(a3)				;4
	and.w	d5,160(a3)			;4
	jmp		.drawPixel				;4		;20
	ds.b	4


;.color3								; bpl 1+2+3
;	or.w	d6,4(a2)				;4
;	or.w	d6,160+4(a2)			;4
;	or.w	d5,4(a3)				;4
;	or.w	d5,160+4(a3)			;4
;	jmp		.drawPixel				;4		;20
;	ds.b	4
.color4								; bpl 1+3
	not.w	d6						;2
	and.w	d6,2(a2)				;4
	and.w	d6,160+2(a2)			;4
	not.w	d5						;2
	and.w	d5,2(a3)				;4
	and.w	d5,160+2(a3)			;4
	jmp		.drawPixel				;4	;24
.color5								; bpl 3
;	not.w	d6						;2
;	and.w	d6,(a2)					;2
;	and.w	d6,160(a2)				;4
;	not.w	d5						;2
;;	and.w	d5,(a3)					;2
;	and.w	d5,160(a3)				;4
	jmp		.drawPixel				;4
	ds.b	4
;.color6								; bpl 2+3
;	or.w	d6,2(a2)				;4
;	or.w	d6,160+2(a2)			;4
;	or.w	d5,2(a3)				;4
;	or.w	d5,160+2(a3)			;4
;	jmp		.drawPixel				;4	20
;	ds.b	4
;.color7								; bpl 2
;	not.w	d6						;2
;	and.w	d6,4(a2)				;4
;	and.w	d6,160+4(a2)			;4
;	not.w	d5						;2
;	and.w	d5,4(a3)				;4
;	and.w	d5,160+4(a3)			;4
;	jmp		.drawPixel				;4	24
;.color8								; bpl 2
;	not.w	d6						;2
;	move.w	d6,d1
;	swap	d1
;	move.w	d6,d1
;
;	and.l	d1,0(a2)				;4
;	and.l	d1,160(a2)			;4
;	and.l	d1,4(a2)				;4
;	and.l	d1,160+4(a2)			;4
;
;	not.w	d5						;2
;	move.w	d5,d1
;	swap	d1
;	move.w	d5,d1
;	and.l	d1,0(a3)
;	and.l	d1,160(a3)			;4
;	and.l	d1,4(a3)				;4
;	and.l	d1,160+4(a3)			;4
;	jmp		.drawPixel				;4	24


.colorTable	
	dc.l	.color1			;1
	dc.l	.color1			;2

	dc.l	.drawPixel			;3
	dc.l	.drawPixel			;4

	dc.l	.drawPixel			;5
	dc.l	.drawPixel			;6

	dc.l	.drawPixel			;7
	dc.l	.drawPixel			;8

	dc.l	.drawPixel			;9
	dc.l	.drawPixel			;10
	dc.l	.drawPixel			;11
	dc.l	.drawPixel			;12

	dc.l	.drawPixel			;13

	dc.l	.color2			;14
	dc.l	.color2			;15
	dc.l	.drawPixel			;16

	dc.l	.drawPixel			;17
	dc.l	.drawPixel			;18
	dc.l	.drawPixel			;19
	dc.l	.drawPixel			;20

	dc.l	.drawPixel			;21
	dc.l	.drawPixel			;22
	dc.l	.drawPixel			;23
	dc.l	.drawPixel			;24

	dc.l	.drawPixel			;25
	dc.l	.drawPixel			;26
	dc.l	.drawPixel			;27
	dc.l	.drawPixel			;28

	dc.l	.color3			;29
	dc.l	.color3			;30
	dc.l	.drawPixel			;31
	dc.l	.drawPixel			;32

	dc.l	.drawPixel			;33
	dc.l	.drawPixel			;34
	dc.l	.drawPixel			;35
	dc.l	.drawPixel			;36

	dc.l	.drawPixel			;37
	dc.l	.drawPixel			;38
	dc.l	.drawPixel			;39
	dc.l	.drawPixel			;40

	dc.l	.drawPixel			;41
	dc.l	.drawPixel			;42
	dc.l	.drawPixel			;43
	dc.l	.drawPixel			;44

	dc.l	.color4			;45
	dc.l	.color4			;46

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
.colorTableEnd


; image offset per line = 15*8 = 120 bytes per
; d6 y-off
; d7 loop
doBottomHalf
	move.w	#104-1,d7

	move.w	d7,d5				; totallength of picture
	add.w	d6,d5				; add y-offset
	neg.w	d5					; 
	add.w	#199,d5				; 
	bge		.ok
	add.w	d5,d7
	blt		.end
.ok

	muls	#160,d6
	lea		bufferbottom,a0
	move.l	screenpointer2,a1
	add.w	d6,a1

	; ok and now clear some more lines on top
	sub.w	#45*160,a1
	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,a2
	move.l	a2,a3
	move.l	a3,a4
	move.l	a4,a5
	move.l	a5,a6
	move.l	#45-1,d6
o set 0
.clear
o	set o+5*8		; from 2 to 6, 4 blocks skipped, 8 regs
			movem.l	d0-d5/a2-a6,o(a1)
			movem.l	d0-d5/a2-a6,o+44(a1)
			movem.l	d0-d4,o+88(a1)
			add.w	#160,a1
		dbra	d6,.clear
o set 0
.ol
o set o+5*8
		movem.l	(a0)+,d0-d6/a2-a6		; 12 longwords
		movem.l	d0-d6/a2-a6,o(a1)
		movem.l	(a0)+,d0-d6/a2-a6		; 12 longwords
		movem.l	d0-d6/a2-a6,o+48(a1)
		move.l	(a0)+,o+96(a1)
		move.l	(a0)+,o+100(a1)
		add.w	#160,a1
		dbra	d7,.ol
	rts

.end
	move.l	screenpointer2,a1
	add.w	#32000-5*160+96,a1
	move.l	#0,d0
o set 0
	REPT 5
		move.l	d0,o(a1)
		move.l	d0,o+4(a1)
o set o+160
	ENDR
	rts

;;;;;;;;;;;;;; PULSE END ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; PULSE END ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; PULSE END ;;;;;;;;;;;;;;;


;;;;;;;;;;;;;; OUTTRO START ;;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO START ;;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO START ;;;;;;;;;;;;
;pc1	equ $730
;pc2	equ $510
;pc3	equ $200

pc1	equ	$302
pc2	equ	$202
pc3	equ	$102

doOuttro
	move.w	#$2700,sr
	move.l	#dummy,$70
	move.w	#$2300,sr
	

	move.l	#screen1+65536,d0
	move.w	#0,d0
	move.l	d0,screenpointer
	add.l	#$10000,d0
	move.l	d0,screenpointer2

	move.l	screenpointer,a0
	jsr		clear4bpl
	move.l	screenpointer2,a0
	jsr		clear4bpl

	move.l	screenpointer,$ffff8200


	jsr		init_yblock_aligned
	jsr		init_xblock_aligned	

	lea		outtropoints,a0
	move.l	a0,currentPointAddress	


	lea		outtrotext,a0
	move.l	a0,_scrollerTextSourcePointer

	move.w	#1,_scrollSpeed
	move.w	#319,pixelPosition
	move.w	#0,_scrollTextOffset


	move.w	#pc1,$ffff8240+2*1
	move.w	#pc3,$ffff8240+2*2
	move.w	#pc2,$ffff8240+2*3

	move.w	#$0,$ffff8240+2*4

	move.w	#pc1,$ffff8240+2*5
	move.w	#pc3,$ffff8240+2*6
	move.w	#pc2,$ffff8240+2*7

	move.w	#$112,$ffff8240+2*8

	move.w	#pc1,$ffff8240+2*9
	move.w	#pc3,$ffff8240+2*10
	move.w	#pc2,$ffff8240+2*11

	move.w	#$112,$ffff8240+2*12

	move.w	#pc1,$ffff8240+2*13
	move.w	#pc3,$ffff8240+2*14
	move.w	#pc2,$ffff8240+2*15

	move.w	#0,_outtroactive
	
	move.w	#0,vblcounter

	move.w	#$2700,sr
	move.l	#outtro_vbl,$70
	move.w	#$2300,sr

;	move.w	#0,colorListOffset

	; prerender ... and the beat goes on ...

	move.l	#300-1,d7

.waiter
	wait_for_vbl
	exitOnSpace
	dbra	d7,.waiter


.mainloop
	lea		credslist,a0
	add.w	_credlistoffset,a0
	move.l	(a0),a0
	jsr		copyCreds
	move.w	#$0,$ffff8240
	exitOnSpace

	jmp		.mainloop

	rts
;;;;;;;;;;;;;; OUTTRO ROUTES ;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO ROUTES ;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO ROUTES ;;;;;;;;;;;
outtro_vbl
	move.l 	screenpointershifter,$ff8200
	addq 		#1,$466.w
	incSync
			swapscreens

	;Start up Timer B each VBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on
	IFNE	playmusic
	IFNE	playmusicinvbl				
		pusha0
		move.l	sndh_pointer,a0
		jsr		8(a0)
		popa0
	ENDC
	ENDC

	pushall

	lea		pulse_y_vals2,a0
	add.w	vblcounter,a0
	move.w	(a0),d0
	add.w	d0,d0
	; we have 13 colors
	lea		pulse_y_colors_list2,a0
	add.w	d0,a0
	move.w	(a0)+,$ffff8240+2*4
	move.w	(a0)+,$ffff8240+2*12
	addq.w	#2,vblcounter


	jsr		drawPixelThings2
	jsr		clearFontLine
	raster	#$700
	jsr		drawStringAtPixel
	raster	#$007
	jsr		advancePixelPosition
	raster	#$070

	subq.w	#1,_credcounter
	bne		.ok
		subq.w	#1,_drawCounter
		bne		.cont
			jsr		drawTimes
			move.w	#4,_drawCounter
.cont
		move.w	#384/2,_credcounter
		sub.w	#4,_credlistoffset
		bge		.ok
			move.w	#12,_credlistoffset
.ok
	popall
	rte	

_drawCounter		dc.w	6
_credcounter		dc.w	(384)/2
_credlistoffset 	dc.w	12
credslist
	dc.l	cred1
	dc.l	cred2
	dc.l	cred4
	dc.l	cred3


copyCreds
	move.l	screenpointer2,a1
	add.w	#50*160,a1
	move.l	#100-1,d7
.ol
o set 4
		REPT 20
			move.w	(a0)+,o(a1)
o set o+8
		ENDR
		add.w	#20*8,a1
	dbra	d7,.ol
	rts


drawPixelThings2
;	move.w	#46*4,d2												; some magic stuff, 64 points?
	move.l	screenpointer2,d6										; screen pointer
	move.l	d6,d5													; save screenpointer
	move.l	x_block_add_pointer,d0									; x_block
	move.l	d0,d3													; save

	lea		.colorTable,a0
	moveq	#0,d4
	move.w	colorListOffset,d4
	move.l	currentPointAddress,a6			; current head
	; make sure we dont have double -1
	move.w	(a6),d0
	bge		.continue
		addq.w	#4,colorListOffset
		cmp.w	#64*4,colorListOffset
		beq		.loop
		jmp		.found
.loop
		move.w	#0,itercount
		move.w	#0,colorListOffset
		lea		outtropoints,a6
		move.l	a6,currentPointAddress
		move.w	#0,vblcounter
		rts
.continue
	; search the next pointer
.search
	; search for first x-value that is not d0
	lea		4(a6),a6
	cmp.w	(a6),d0
	beq		.search
	; when we hit here, we know that a6 points to the first x-value thats different, so from here we can move back
	; store this for the next iteration
.found
	move.l	a6,d2		
	move.w	d0,d7						; d6 is current streak
	move.l	(a0,d4.w),a5
	; draw pixel

.drawPixel
	move.w	-(a6),d5					; y
	move.w	-(a6),d0					; x
	cmp.w	d0,d7						; streak ended?
	bne		.streakend

.continuestreak
	move.w	d0,d3						; we draw 2 by 2
	addq.w	#4,d3						; x = x+1 for 2 by 2 block
	move.w	d5,d6

	move.l	d0,a3					;4		; first pixel x
	add.w	(a3)+,d6				;8		;	x offset
	move.l	d6,a2					;4		; screen + offset for x		
	move.w	(a3)+,d6				;8		; mask

	move.l	d3,a4					;4		; pixel + 1
	add.w	(a4)+,d5				;8
	move.l	d5,a3							; screen + offset for x+1
	move.w	(a4)+,d5						; mask

	; masks and addresses sreen:
	;	x	> a2 screen, d6 mask
	;	x+1	> a3 screen, d5 mask
	jmp		(a5)

.streakend
	cmp.w	itercount,d4
	bne		.checkmore
		add.w	#4,itercount
		move.l	d2,currentPointAddress
		rts

.checkmore
	addq.w	#4,d4					; here we change the drawing pixel method, bump offset by 4
	cmp.w	#74*4,d4						; check if we should stop drawing or not
	bne		.letsgo
		move.l	d2,currentPointAddress
		rts
.letsgo
	move.w	d0,d7					; we have a new stream, so change the x value 
	move.l	(a0,d4.w),a5
	jmp		.continuestreak			; lets draw!

.colorjump
.color1								; bpl 1
	or.w	d6,(a2)					;2
	or.w	d6,160(a2)				;4
	or.w	d5,(a3)					;2
	or.w	d5,160(a3)				;4
	jmp		.drawPixel				;4		16
	ds.b	8
.color2								; bpl 1+2
	or.w	d6,2(a2)				;4
	or.w	d6,160+2(a2)			;4
	or.w	d5,2(a3)				;4
	or.w	d5,160+2(a3)			;4
	jmp		.drawPixel				;4		;20
	ds.b	4
.color3		
	not.w	d5
	not.w	d6						; bpl 2

	and.w	d6,(a2)				;4
	and.w	d6,160(a2)			;4
	and.w	d5,(a3)				;4
	and.w	d5,160(a3)			;4
	jmp		.drawPixel				;4		;20
	ds.b	4
.color4								; bpl 1+3
	not.w	d6						;2
	and.w	d6,2(a2)				;4
	and.w	d6,160+2(a2)			;4
	not.w	d5						;2
	and.w	d5,2(a3)				;4
	and.w	d5,160+2(a3)			;4
	jmp		.drawPixel				;4	;24
.color5								; bpl 3
	jmp		.drawPixel				;4
	ds.b	4


.colorTable
	dc.l	.color1	
	dc.l	.color1	
	dc.l	.drawPixel	
	dc.l	.drawPixel	

	dc.l	.drawPixel	
	dc.l	.drawPixel	

	dc.l	.drawPixel	
	dc.l	.drawPixel	

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel


	dc.l	.color2
	dc.l	.color2
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.color3
	dc.l	.color3
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.color4
	dc.l	.color4

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
.colorTableEnd
;;;;;;;;;;;;;; OUTTRO END ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO END ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO END ;;;;;;;;;;;;;;


;;;;;;;;;;;;;; DOTS START ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; DOTS START ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; DOTS START ;;;;;;;;;;;;;;
bgcolor				equ $ffff8240
nr_of_dots 			equ 95
nr_of_partitions	equ 16

front				equ $777
middle				equ	$555
back				equ	$333

;zero65536
;	move.l	#128-1,d7
;	move.l	#0,d0
;.clear
;	REPT 128
;		move.l	d0,(a0)+
;	ENDR
;	dbra	d7,.clear
;	rts

dotsEffect
.init

	move.l	backup_screenpointer2,screenpointer
	move.l	backup_screenpointer,screenpointer2
	move.l	alignpointer1,screenpointer3

	move.l	screenpointer,a0
	jsr		clear4bpl
	move.l	screenpointer2,a0
	jsr		clear4bpl

	jsr		init_xblock_aligned	
	jsr		init_exp_log					; 3 frames
	jsr		init_dots
	jsr		init_yblock_aligned

	move.w	#$2700,sr
	move.l	#drawVbl,$70.w				; drawVBL changes into dots_bg_vbl when done
	move.w	#$2300,sr
	wait_for_vbl


.mainloop_calc:
	jsr	doRotationDots
	jsr	savePixels
	add.l	#4,saveOffset
	cmp.l	#64,saveOffset
	bne		.cont
		move.l	savedTable_pointer,a0
		jmp		.mainloop_init
.cont
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop_calc
	move.w	#-1,demo_exit
	rts

.mainloop_init

	jsr		generateClearScreenCode
	jsr		generateDotsLoop
	move.l	#nr_of_dots*4*50,dataoffset

	move.w	#596,vblcounter

;;;;;; here the normal picture is unrolled, now we need to flash the shit
	move.w	#$2700,sr
	move.l  #dots_vbl,$70.w
	move.w	#$2300,sr

	wait_for_vbl

mainloop:
			swapscreens
			wait_for_vbl
			raster #$700
	jsr		cycleDotColors
	move.l	clearScreen1bplPointer,a0
	jsr		(a0)
	jsr		generateDots
	jsr		drawDots

			raster #$000
	cmp.w	#596-530,vblcounter
	bne		.gwan
		move.w	#0,dots_fade_out
.gwan

	cmp.w	#596-576,vblcounter
	bne		.gwan2
		move.w	#0,dots_color_fade
.gwan2

	subq.w	#1,vblcounter
	bne		.cont
		rts
.cont
	cmp.b 	#$39,$fffffc02.w
	bne		mainloop
	move.w	#-1,demo_exit
	rts
;;;;;;;;;;;;;; DOTS ROUTS ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; DOTS ROUTS ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; DOTS ROUTS ;;;;;;;;;;;;;;
dots_vbl:
	addq  	#1,$466.w
	incSync

	move.l	screenpointer2,$ffff8200
	pusha0
	pusha1
	move.l	sndh_pointer,a0
	jsr		8(a0)

    move.w  #$0,$FFFF8240.w ; cinemascope

    lea		dots_off+54,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal1,A0 ; "P" palette
    add.w	(a1),a0
    move.l  (a0)+,$ffff8240+2*8
    move.l  (a0)+,$ffff8240+2*10
    move.l  (a0)+,$ffff8240+2*12
    move.l  (a0)+,$ffff8240+2*14
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb0,$0120.w
    move.b  #1,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb0:        
    move.w  #$111,$FFFF8240.w
    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb1,$0120.w
    move.b  #39,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte





dots_tb0a:
	move.w	#$2700,sr			;Stop all interrupts

	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w
   	pushd0

	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
    nop

	move.w	#$111,$ffff8240
    clr.b   $fffffa19.w         	;Timer-A control (stop)											;24 => 6

    move.b 	#0,$fffffa1b.w    																		;20 => 5
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)									;28 => 7
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)										;28 => 7
    move.l  #dots_tb1,$120.w        ;Install our own Timer B						;24 => 6
    move.b  #39,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    popd0
    rte

dots_tb1:        
    pusha0
    pusha1
    lea		dots_off+48,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal2,A0 ; overlapping P/U
    add.w	(a1),a0
    move.l  (A0)+,$FFFF8240+9*2.w ; col 9
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb2,$0120.w
    move.b  #6,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb2:       
    pusha0
    pusha1
    lea		dots_off+42,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal3,A0 ; "U" palette
    add.w	(a1),a0
    move.l  (a0)+,$FFFF8240+2*11
    move.l  (a0)+,$FFFF8240+2*13
    move.w  (a0),$FFFF8240+2*15.w ; col 15
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb3,$0120.w
    move.b  #31,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb3:
    pusha0
    pusha1
		move.w	#$2700,sr			;Stop all interrupts
		dcb.w 	84,$4e71			;Zzzz


    lea		dots_off+36,a1
    add.w	dots_fade,a1  
    lea     dots_logo_pal4,A0 ; overlapping U/L
    add.w	(a1),a0
    move.l  (a0)+,$FFFF8240+2*9
    move.l  (a0)+,$FFFF8240+2*11 
    move.w  (a0),$FFFF8240+2*13
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb4,$0120.w
    move.b  #2,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb4:
    pusha0
    pusha1
    lea		dots_off+30,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal5,A0 ; "L"
    add.w	(a1),a0
    move.w  (A0)+,$FFFF8240+14*2.w ; col 14
    move.w  (A0)+,$FFFF8240+15*2.w ; col 15
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb5,$0120.w
    move.b  #32,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb5:
    pusha0
    pusha1
		move.w	#$2700,sr			;Stop all interrupts
		dcb.w 	84,$4e71			;Zzzz


    lea		dots_off+24,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal6,A0 ; overlapping L/S
    add.w	(a1),a0
    move.l  (a0)+,$FFFF8240+12*2.w 
    move.l  (a0)+,$FFFF8240+14*2.w 
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb6,$0120.w
    move.b  #1,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb6:
    pusha0   
    pusha1   
    lea		dots_off+18,a1          
    add.w	dots_fade,a1
    lea     dots_logo_pal7,A0 ; "S"
    add.w	(a1),a0
    move.l  (A0)+,$FFFF8240+9*2.w ; get 2 colors->col 9+10
    move.w  (A0)+,$FFFF8240+11*2.w ; one more (col 11)
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb7,$0120.w
    move.b  #34,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb7:
    pusha0
    pusha1
    lea		dots_off+12,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal8,A0 ; overlapping S/E
    add.w	(a1),a0
    move.l  (A0)+,$FFFF8240+10*2.w ; get 2 colors->col 10+11
    move.w  (A0)+,$FFFF8240+15*2.w ; one more (col 15)
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb8,$0120.w
    move.b  #2,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb8: 
    pusha0
    pusha1
    lea		dots_off+6,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal9,A0 ; overlapping S/E
    add.w	(a1),a0
    move.l  (A0)+,$FFFF8240+12*2.w ; get 2 colors->col 12+13
    move.w  (A0)+,$FFFF8240+14*2.w ; one more (col 14)
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb_end,$0120.w
    move.b  #49,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte




dots_tb_end
	move.w	#$2700,sr			;Stop all interrupts
	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w

   	pushd0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
    nop

	move.w	#$000,$ffff8240
	popd0

    move.b  #0,$FFFFFA1B.w

    subq.w	#1,dots_fade_counter
    bne		.end
    move.w	#fade_speed_frames,dots_fade_counter
    add.w	#2,dots_fade
    cmp.w	#(54*3),dots_fade
    bne		.end
    	move.w	#96,dots_fade
    	move.w	#$2700,sr
    	move.l	#dots_normal_vbl,$70
    	move.w	#$2300,sr
.end
    rte


dots_tb_end2:    
    move.w  #$00,$FFFF8240.w ; cinemascope
    move.b  #0,$FFFFFA1B.w

    subq.w	#1,dots_fade_counter
    bne		.end
    move.w	#fade_speed_frames,dots_fade_counter
    add.w	#2,dots_fade
    cmp.w	#(54*3),dots_fade
    bne		.end
    	move.w	#96,dots_fade
    	move.w	#$2700,sr
    	move.l	#dots_normal_vbl,$70
    	move.w	#$2300,sr
.end
    rte

dots_normal_vbl
	addq  	#1,$466.w
	incSync

	move.l	screenpointer2,$ffff8200
	pusha0
	pusha1
	move.l	sndh_pointer,a0
	jsr		8(a0)

    move.w  #$0,$FFFF8240.w ; cinemascope

    lea     dots_logo_pal1,A0 ; "P" palette
    add.w	dots_fade,a0
    move.l  (a0)+,$ffff8240+2*8
    move.l  (a0)+,$ffff8240+2*10
    move.l  (a0)+,$ffff8240+2*12
    move.l  (a0)+,$ffff8240+2*14
    popa1
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb0n,$0120.w
    move.b  #1,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
	rte

dots_tb0n:        
    move.w  #$111,$FFFF8240.w
    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb1n,$0120.w
    move.b  #39,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte


dots_tb1n:        
    pusha0
    lea     dots_logo_pal2,A0 ; overlapping P/U
    add.w	dots_fade,a0
    move.l  (A0)+,$FFFF8240+2*9 ; col 9
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb2n,$0120.w
    move.b  #6,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb2n:       
    pusha0
    lea     dots_logo_pal3,A0 ; "U" palette
    add.w	dots_fade,a0
    move.l  (a0)+,$FFFF8240+2*11
    move.l  (a0)+,$FFFF8240+2*13
    move.w  (a0),$FFFF8240+2*15.w ; col 15
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb3n,$0120.w
    move.b  #31,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb3n:
    pusha0
  		move.w	#$2700,sr			;Stop all interrupts
		dcb.w 	84,$4e71			;Zzzz

    lea     dots_logo_pal4,A0 ; overlapping U/L
    add.w	dots_fade,a0
    move.l  (a0)+,$FFFF8240+2*9
    move.l  (a0)+,$FFFF8240+2*11 
    move.w  (a0),$FFFF8240+2*13
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb4n,$0120.w
    move.b  #2,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb4n:
    pusha0
    lea     dots_logo_pal5,A0 ; "L"
    add.w	dots_fade,a0
    move.w  (A0)+,$FFFF8240+14*2.w ; col 14
    move.w  (A0)+,$FFFF8240+15*2.w ; col 15
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb5n,$0120.w
    move.b  #32,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb5n:
    pusha0
		move.w	#$2700,sr			;Stop all interrupts
		dcb.w 	84,$4e71			;Zzzz

    lea     dots_logo_pal6,A0 ; overlapping L/S
    add.w	dots_fade,a0
    move.l  (a0)+,$FFFF8240+12*2.w 
    move.l  (a0)+,$FFFF8240+14*2.w 
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb6n,$0120.w
    move.b  #1,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb6n:
    pusha0   
    lea     dots_logo_pal7,A0 ; "S"
    add.w	dots_fade,a0
    move.l  (A0)+,$FFFF8240+9*2.w ; get 2 colors->col 9+10
    move.w  (A0)+,$FFFF8240+11*2.w ; one more (col 11)
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb7n,$0120.w
    move.b  #34,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb7n:
    pusha0
    lea     dots_logo_pal8,A0 ; overlapping S/E
    add.w	dots_fade,a0
    move.l  (A0)+,$FFFF8240+10*2.w ; get 2 colors->col 10+11
    move.w  (A0)+,$FFFF8240+15*2.w ; one more (col 15)
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb8n,$0120.w
    move.b  #2,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb8n: 
    pusha0
    lea     dots_logo_pal9,A0 ; overlapping S/E
    add.w	dots_fade,a0
    move.l  (A0)+,$FFFF8240+12*2.w ; get 2 colors->col 12+13
    move.w  (A0)+,$FFFF8240+14*2.w ; one more (col 14)
    popa0

    move.b  #0,$FFFFFA1B.w
    move.l  #dots_tb_endn,$0120.w
    move.b  #50,$FFFFFA21.w
    move.b  #8,$FFFFFA1B.w
    rte

dots_tb_endn:    
    move.w  #$00,$FFFF8240.w ; cinemascope
    move.b  #0,$FFFFFA1B.w


    tst.w	dots_fade_out
    bne		.end

    subq.w	#1,dots_fade_counter
	bne		.end
	move.w	#fade_speed_frames,dots_fade_counter
	cmp.w	#19*16,dots_fade
	beq		.end
		add.w	#16,dots_fade

.end

	tst.w	dots_color_fade
	bne		.end2
	subq.w	#1,dots_color_counter
	bne		.end2
		move.w	#3,dots_color_counter
		cmp.w	#6*112,_dotsFadeOffset
		beq		.end2
			add.w	#112,_dotsFadeOffset
.end2

    rte

dots_fade_out		dc.w	1
dots_color_fade		dc.w	1
dots_color_counter	dc.w	3




fade_speed_frames	equ 2
dots_fade_counter
	dc.w	fade_speed_frames
dots_fade
	dc.w	0
dots_off
	dc.w	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0		; 27*2 = 54
	dc.w	0,	16,	32,	48,	64,	80,	96
	dc.w	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96		; 27
	dc.w	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96		; 27
	dc.w	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96,	96		; 27
	


;	0		1		2		3		4		5		6		7		8		9		10		11		12		13		14
;	$111,	$000,	$765,	$655,	$553,	$543,	$434,	$313,	$777,	$664,	$544,	$452,	$442,	$333,	$212

; 6 steps	!
dots_logo_pal1:		; P		;1		;2		;3		;4		;5		;6		;7		;8
					DC.W	$0,		$777,	$452,	$554,	$664,	$442,	$333,	$212				; start

					DC.W	$0,		$777,	$452,	$554,	$664,	$443,	$333,	$212				; 1				
					DC.W	$0,		$777,	$453,	$544,	$665,	$433,	$334,	$213				; 2
					DC.W	$0,		$777,	$454,	$545,	$655,	$434,	$324,	$213				; 3
					DC.W	$0,		$777,	$445,	$645,	$656,	$435,	$324,	$313				; 4
					DC.W	$0,		$777,	$545,	$645,	$656,	$435,	$424,	$313				; 5

				    DC.W	$0,		$777,	$546,	$646,	$657,	$535,	$424,	$313				; end	6

				    DC.W	$111,	$777,	$546,	$646,	$657,	$535,	$424,	$313				;1
				    DC.W	$222,	$777,	$546,	$646,	$657,	$535,	$424,	$323				;2
				    DC.W	$333,	$777,	$546,	$646,	$657,	$535,	$535,	$434				;3
				    DC.W	$444,	$777,	$546,	$646,	$657,	$545,	$646,	$545				;4
				    DC.W	$555,	$777,	$556,	$656,	$657,	$656,	$757,	$656				;5
				    DC.W	$666,	$777,	$667,	$767,	$667,	$767,	$767,	$767				;6
				    DC.W	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777				;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13


dots_logo_pal2:     ; P/U	
					DC.W 	$655,	$543,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; start

					DC.W 	$655,	$443,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 1
					DC.W 	$555,	$444,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 2
					DC.W 	$455,	$344,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 3
					DC.W 	$445,	$334,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 4
					DC.W 	$446,	$335,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 5

					DC.W 	$446,	$335,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; end	6

					DC.W 	$446,	$335,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;1
					DC.W 	$446,	$335,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;2	
					DC.W 	$446,	$335,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;3
					DC.W 	$446,	$445,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;4
					DC.W 	$556,	$556,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;5
					DC.W 	$667,	$667,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;6
					DC.W 	$777,	$777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13


dots_logo_pal3:    	; U ;dc.w 
					DC.W 	$777,	$765,	$553,	$434,	$313,	$-1,	$-1,	$-1					; start

					DC.W 	$777,	$665,	$543,	$334,	$313,	$-1,	$-1,	$-1					; 1
					DC.W 	$777,	$655,	$443,	$334,	$213,	$-1,	$-1,	$-1					; 2
					DC.W 	$777,	$656,	$444,	$234,	$213,	$-1,	$-1,	$-1					; 3
					DC.W 	$777,	$556,	$344,	$234,	$213,	$-1,	$-1,	$-1					; 4
					DC.W 	$777,	$557,	$345,	$224,	$113,	$-1,	$-1,	$-1					; 5

					DC.W 	$777,	$557,	$346,	$224,	$113,	$-1,	$-1,	$-1					; end	6

					DC.W 	$777,	$557,	$346,	$224,	$113,	$-1,	$-1,	$-1					;1
					DC.W 	$777,	$557,	$346,	$224,	$223,	$-1,	$-1,	$-1					;2
					DC.W 	$777,	$557,	$346,	$335,	$334,	$-1,	$-1,	$-1					;3
					DC.W 	$777,	$557,	$456,	$446,	$445,	$-1,	$-1,	$-1					;4
					DC.W 	$777,	$667,	$567,	$557,	$556,	$-1,	$-1,	$-1					;5
					DC.W 	$777,	$667,	$667,	$667,	$667,	$-1,	$-1,	$-1					;6
					DC.W 	$777,	$777,	$777,	$777,	$777,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13



dots_logo_pal4:    	; U/L
					DC.W 	$664,	$554,	$442,	$333,	$212,	$-1,	$-1,	$-1					; start

					DC.W 	$564,	$454,	$443,	$333,	$212,	$-1,	$-1,	$-1					; 1
					DC.W 	$565,	$454,	$443,	$233,	$112,	$-1,	$-1,	$-1					; 2
					DC.W 	$565,	$455,	$343,	$233,	$112,	$-1,	$-1,	$-1					; 3
					DC.W 	$566,	$455,	$344,	$233,	$122,	$-1,	$-1,	$-1					; 4
					DC.W 	$567,	$456,	$344,	$234,	$122,	$-1,	$-1,	$-1					; 5

					DC.W 	$567,	$456,	$345,	$234,	$123,	$-1,	$-1,	$-1					; end	6

					DC.W 	$567,	$456,	$345,	$234,	$123,	$-1,	$-1,	$-1					;1
					DC.W 	$567,	$456,	$345,	$234,	$223,	$-1,	$-1,	$-1					;2
					DC.W 	$677,	$567,	$456,	$345,	$334,	$-1,	$-1,	$-1					;3
					DC.W 	$777,	$677,	$567,	$456,	$445,	$-1,	$-1,	$-1					;4
					DC.W 	$777,	$777,	$677,	$567,	$556,	$-1,	$-1,	$-1					;5
					DC.W 	$777,	$777,	$777,	$677,	$667,	$-1,	$-1,	$-1					;6
					DC.W 	$777,	$777,	$777,	$777,	$777,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13


dots_logo_pal5:     ; L
					DC.W 	$0452,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; start

					DC.W 	$0453,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 1
					DC.W 	$0454,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 2
					DC.W 	$0454,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 3
					DC.W 	$0354,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 4
					DC.W 	$0354,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; 5

					DC.W 	$0355,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					; end	6

					DC.W 	$0355,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;1
					DC.W 	$0355,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;2
					DC.W 	$0355,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;3
					DC.W 	$0455,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;4
					DC.W 	$0566,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;5
					DC.W 	$0677,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;6
					DC.W 	$0777,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13


dots_logo_pal6:     ; L/S
					DC.W 	$0553,	$0543,	$0434,	$0313,	$-1,	$-1,	$-1,	$-1					; start

					DC.W 	$0553,	$0543,	$0334,	$0313,	$-1,	$-1,	$-1,	$-1					; 1
					DC.W 	$0553,	$0543,	$0333,	$0323,	$-1,	$-1,	$-1,	$-1					; 2
					DC.W 	$0453,	$0443,	$0343,	$0223,	$-1,	$-1,	$-1,	$-1					; 3
					DC.W 	$0453,	$0443,	$0343,	$0123,	$-1,	$-1,	$-1,	$-1					; 4
					DC.W 	$0453,	$0443,	$0342,	$0123,	$-1,	$-1,	$-1,	$-1					; 5

					DC.W	$0463,	$0454,	$0242,	$0122,	$-1,	$-1,	$-1,	$-1					; end	6

					DC.W	$0463,	$0454,	$0242,	$0122,	$-1,	$-1,	$-1,	$-1					;1
					DC.W	$0463,	$0454,	$0354,	$0233,	$-1,	$-1,	$-1,	$-1					;2
					DC.W	$0464,	$0454,	$0354,	$0344,	$-1,	$-1,	$-1,	$-1					;3
					DC.W	$0575,	$0565,	$0465,	$0455,	$-1,	$-1,	$-1,	$-1					;4
					DC.W	$0676,	$0666,	$0565,	$0555,	$-1,	$-1,	$-1,	$-1					;5
					DC.W	$777,	$777,	$676,	$666,	$-1,	$-1,	$-1,	$-1					;6
					DC.W	$777,	$777,	$777,	$777,	$-1,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13




dots_logo_pal7:     ; S
					DC.W 	$0777,	$0765,	$0655,	$-1,	$-1,	$-1,	$-1,	$-1					; start

					DC.W 	$0777,	$0765,	$0655,	$-1,	$-1,	$-1,	$-1,	$-1					; 1
					DC.W 	$0777,	$0665,	$0555,	$-1,	$-1,	$-1,	$-1,	$-1					; 2
					DC.W 	$0777,	$0666,	$0555,	$-1,	$-1,	$-1,	$-1,	$-1					; 3
					DC.W 	$0777,	$0566,	$0555,	$-1,	$-1,	$-1,	$-1,	$-1					; 4
					DC.W 	$0777,	$0566,	$0555,	$-1,	$-1,	$-1,	$-1,	$-1					; 5

					DC.W 	$0777,	$0576,	$0565,	$-1,	$-1,	$-1,	$-1,	$-1					; end

					DC.W 	$0777,	$0576,	$0565,	$-1,	$-1,	$-1,	$-1,	$-1					;1
					DC.W 	$0777,	$0576,	$0565,	$-1,	$-1,	$-1,	$-1,	$-1					;2
					DC.W 	$0777,	$0576,	$0566,	$-1,	$-1,	$-1,	$-1,	$-1					;3
					DC.W 	$0777,	$0676,	$0566,	$-1,	$-1,	$-1,	$-1,	$-1					;4
					DC.W 	$0777,	$0676,	$0577,	$-1,	$-1,	$-1,	$-1,	$-1					;5
					DC.W 	$0777,	$0777,	$0677,	$-1,	$-1,	$-1,	$-1,	$-1					;6
					DC.W 	$0777,	$0777,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13

dots_logo_pal8:     ; S/E
					DC.W 	$0554,	$0442,	$0333,	$-1,	$-1,	$-1,	$-1,	$-1					; start

					DC.W 	$0554,	$0442,	$0333,	$-1,	$-1,	$-1,	$-1,	$-1					;1
					DC.W 	$0654,	$0542,	$0433,	$-1,	$-1,	$-1,	$-1,	$-1					;2
					DC.W 	$0654,	$0542,	$0432,	$-1,	$-1,	$-1,	$-1,	$-1					;3
					DC.W 	$0653,	$0542,	$0422,	$-1,	$-1,	$-1,	$-1,	$-1					;4
					DC.W 	$0663,	$0542,	$0421,	$-1,	$-1,	$-1,	$-1,	$-1					;5

					DC.W 	$0763,	$0642,	$0521,	$-1,	$-1,	$-1,	$-1,	$-1					; end 6

					DC.W 	$0763,	$0642,	$0521,	$-1,	$-1,	$-1,	$-1,	$-1					;1
					DC.W 	$0763,	$0642,	$0522,	$-1,	$-1,	$-1,	$-1,	$-1					;2
					DC.W 	$0763,	$0643,	$0533,	$-1,	$-1,	$-1,	$-1,	$-1					;3
					DC.W 	$0754,	$0654,	$0544,	$-1,	$-1,	$-1,	$-1,	$-1					;4
					DC.W 	$0765,	$0755,	$0655,	$-1,	$-1,	$-1,	$-1,	$-1					;5
					DC.W 	$0766,	$0766,	$0655,	$-1,	$-1,	$-1,	$-1,	$-1					;6
					DC.W 	$0777,	$0777,	$0777,	$-1,	$-1,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13

dots_logo_pal9:     ; E
					DC.W 	$0452,	$0664,	$0212,	$-1,	$-1,	$-1,	$-1,	$-1					; start

					DC.W 	$0552,	$0664,	$0212,	$-1,	$-1,	$-1,	$-1,	$-1					; 1
					DC.W 	$0652,	$0664,	$0212,	$-1,	$-1,	$-1,	$-1,	$-1					; 2
					DC.W 	$0662,	$0674,	$0211,	$-1,	$-1,	$-1,	$-1,	$-1					; 3
					DC.W 	$0663,	$0674,	$0211,	$-1,	$-1,	$-1,	$-1,	$-1					; 4
					DC.W 	$0664,	$0674,	$0211,	$-1,	$-1,	$-1,	$-1,	$-1					; 5

					DC.W 	$0764,	$0774,	$0210,	$-1,	$-1,	$-1,	$-1,	$-1					; end	6

					DC.W 	$0764,	$0774,	$0211,	$-1,	$-1,	$-1,	$-1,	$-1					;1
					DC.W 	$0764,	$0774,	$0322,	$-1,	$-1,	$-1,	$-1,	$-1					;2
					DC.W 	$0764,	$0774,	$0433,	$-1,	$-1,	$-1,	$-1,	$-1					;3
					DC.W 	$0765,	$0775,	$0544,	$-1,	$-1,	$-1,	$-1,	$-1					;4
					DC.W 	$0765,	$0776,	$0655,	$-1,	$-1,	$-1,	$-1,	$-1					;5
					DC.W 	$0776,	$0777,	$0766,	$-1,	$-1,	$-1,	$-1,	$-1					;6
					DC.W 	$0777,	$0777,	$777,	$-1,	$-1,	$-1,	$-1,	$-1					;7
				    DC.W	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666				;8
				    DC.W	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$555				;9
				    DC.W	$444,	$444,	$444,	$444,	$444,	$444,	$444,	$444				;10
				    DC.W	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333				;11
				    DC.W	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222				;12
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13
				    DC.W	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111				;13


drawVbl
	move.w	#0,addcounter
		addq.w		#1,$466.w
	incSync
	incSync
	move.l	screenpointer2,$ffff8200

	movem.l	d0-d7/a0-a2,-(sp)

    clr.b   $fffffa19.w         	;Timer-A control (stop)
    bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
    bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
    move.b  #48,$fffffa1f.w         ;Timer A Delay (data)
    move.b  #%111,$fffffa19.w       ;Timer A Predivider (start Timer A)
    move.l	#meta_timer_a_curtain_start,$134.w    
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	move.l	sndh_pointer,a0
	jsr		8(a0)

	cmp.w	#202,lc
	beq		.unrolled

	lea		dotspicpalette,a0
	movem.l	(a0),d0-d7
	move.w	d0,$ffff8242
	movem.l	d1-d7,$ffff8244
	move.w	#0,$ffff8240

	jsr		drawLine

	movem.l	(sp)+,d0-d7/a0-a2

	rte


.unrolled
	move.w	#$2700,sr
	move.l	#dots_bg_vbl,$70
	move.w	#$2300,sr
	movem.l	(sp)+,d0-d7/a0-a2
	rte

curtain_start
	move.w	#$111,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l  #curtain_stop,$120.w        ;Install our own Timer B
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

curtain_stop
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.w	#$0,$ffff8240
	rte	


dots_bg_vbl
   	addq  	#1,$466.w
	incSync
	move.l	screenpointer2,$ffff8200

	movem.l	d0/a0-a2,-(sp)

    clr.b   $fffffa19.w         	;Timer-A control (stop)
    bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
    bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
    move.b  #48,$fffffa1f.w         ;Timer A Delay (data)
    move.b  #%111,$fffffa19.w       ;Timer A Predivider (start Timer A)
    move.l	#dots_tb0a,$134.w    
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	move.l	sndh_pointer,a0
	jsr		8(a0)

    move.w  #$0,$FFFF8240.w ; cinemascope

    lea		dots_off+54,a1
    add.w	dots_fade,a1
    lea     dots_logo_pal1,A0 ; "P" palette
    add.w	(a1),a0
    move.l  (a0)+,$ffff8240+2*8
    move.l  (a0)+,$ffff8240+2*10
    move.l  (a0)+,$ffff8240+2*12
    move.l  (a0)+,$ffff8240+2*14

	lea		logosplit,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#2*8,a1
	add.w	#2*8,a2
	move.l	#200-1,d0
.line
	REPT 3
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
	ENDR
	add.w	#160-3*8,a1
	add.w	#160-3*8,a2
	dbra	d0,.line

	movem.l	(sp)+,d0/a0-a2

    rte


init_exp_log:   
init_log:      
    lea     log_src,A4    		; skip 0
    move.l  logpointer,d5
    move.l  d5,a2
    moveq   #-2,d6           	; index

    move.w  #-EXPS*2,(A2)+  	; NULL
    move.w  #LOGS-1-1,D7
il:
    	move.w  (A4)+,D0        ; log
    	add.w   D0,D0
    	move.w  d0,(a2)+        ; pos2

    	add.w   #EXPS*2,D0      ; NEG

    	move.w  d6,d5           ; take negative value into account
    	move.l  d5,a3
    	move.w  d0,(a3)         ; move in value

    	subq.w  #2,d6
    dbra    D7,il

init_exp:      
	lea		$3000,a0
	move.w	#0,d0
.cl
		move.w	d0,(a0)+
		cmp.w	#$5000,a0
		bne		.cl

    move.w  #EXPS*2,D7
    lea     exp_src,a3

    lea  	$5000,a4
    lea     (a4,d7.w),a5
    lea     (a5,d7.w),a6

    move.w  #EXPS-1,D7
ie2:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1
		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+

    dbra    D7,ie2
    ; range 1000 to B000
    rts



init_dots
;tableSource
;x set 0
;	REPT 100
;y set -32
;		REPT 64
;			dc.w	x,y
;y set y+1
;		ENDR
;x set x+1
;	ENDR
	move.l	tableSourcePointer,a0
;	lea		tableSource,a0
	move.l	#100-1,d7
	moveq	#0,d0
.ol
	move.w	#-31,d1
.il
	REPT 64
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		addq.w	#1,d1
	ENDR
	addq.w	#1,d0
	dbra	d7,.ol


	move.w	#214*4,vertices_xoff
	move.w	#100*4,vertices_yoff

	move.l	#6400,number_of_vertices
	move.l	tableSourcePointer,a0
	move.l	a0,a1
	move.l	a1,currentObjectPointer

	move.l	logpointer,d6
	move.l	#max_nr_of_vertices,d7
	subq.l	#1,d7
	move.w	#$5000,d0						; base address of low memory

.loop
	REPT 2
		move.w	(a0)+,d6
		add.w	d6,d6
		move.l	d6,a2
		move.w	(a2),d1
		add.w	d0,d1
		move.w	d1,(a1)+
	ENDR

	dbra	d7,.loop
	rts	

doRotationDots
    move.w  #512*2,d7									;8
; do angular speeds and get indices 
    move.w  currentStepX,d2								;16
    cmp.w   d7,d2										;4
    blt     .goodX										;12
        sub.w   d7,d2									;4
.goodX
    move.w  d2,currentStepX								;16		--> 68
    add.w   #32*2,currentStepX								;16

;;;;;;;;;;;;;;;;;; ANGULAR SPEEDS DONE ;;;;;;;;;;;;;;;;;;

.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		sintable1,a0								;12
	lea		sintable1+256,a1							;12

	move.w	(a0,d2.w),d1					; sin(A)	;around z axis		16
	move.w	(a1,d2.w),d2					; cos(A)						16

	move.w	#$7F,d4
	move.w	d4,d6
	move.w	#0,d5

	; xx = cos(A) * cos(B)
.xx
	move.w	d2,d7						;						4
	muls	d4,d7						;						42				1
	asr.w	#7,d7						;xx,zz					24	
	move.w	d7,a2						;						18
															; ------> 88
	;xy = [sin(A)cos(B)]		
.xy
	move.w	d4,d7						;						4
	muls	d1,d7						;						42				2
	asr.w	#7,d7						;						24
	move.w	d7,a1						;						4
															; ------> 74
	;yx = [sin(A)cos(C) + cos(A)sin(B)sin(C)]
.yx
    move.w	d6,d0											;	4
    muls	d1,d0	; d0 = sin(A) * cos(C)						44		
    move.w	d2,d7											;	4
    muls	d3,d7	; d7 = cos(A) * sin(B)					;	44
    asr.w	#7,d7											;	24
    muls	d5,d7	; d7 = cos(A) * sin(B) * sin(C)			;	44
	add.w	d7,d0											;	10
	asr.w	#7,d0											;	22
	move.w	d0,a3											;	4
;	move.w	d0,yx											; ------> 200

	;yy = [-cos(A)cos(C) + sin(A)sin(B)sin(C)]
.yy
	move.w	d2,d7	; d7 = cos(A)							;	4
	neg		d7		; d7 = -cos(A)							;	4
	muls	d6,d7	; d7 = -cos(A) * cos(C)					;	44
	move.w	d1,d0		; sin(A)								4
	muls	d3,d0		; sin(A) * sin(B)						44
	asr.w	#7,d0		;										24;
	muls	d5,d0		; sin(A) * sin(B) * sin(C)				44
	add.l	d0,d7		;										8
	asr.w	#7,d7		;										24
															;---------> 204
	;yz = [-cos(B)sin(C)]

;;;;;;;;;;;;;;;;;; CONSTANTS DONE ;;;;;;;;;;;;;;;;;;

.setupComplete						
	move.l	logpointer,d0		;20

	move.w	a2,d0 ;xx			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),pxxp+2

	move.w	a1,d0	;xy			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),pxyp+2

	move.w	a3,d0	;yx			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),pyxp+2

	move.w	d7,d0	;yy			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),pyyp+2

	move.l	currentObjectPointer,a5					; 20							
	move.l	vertexprojection2_pointer,a6		; 20
	move.l	number_of_vertices,d5				; 20
	subq	#1,d5								; 4

loop11
	move.w	(a5)+,a0
	move.w	(a5)+,a1
	;	x	
pxxp	move.w		1234(a0),d0	;12				xx is offset into table for the value, smc
pxyp	add.w		1234(a1),d0	;12				xy is offset into table for the value, smc
		move.w		d0,(a6)+

	;	y
pyxp	move.w		1234(a0),d0	;12
pyyp	add.w		1234(a1),d0	;12
		move.w		d0,(a6)+

	dbra	d5,loop11
	rts

	; some useless stuff



savePixels:
	move.w	vertices_xoff,a0
	move.w	vertices_yoff,a1

	move.l	savedTable_pointer,a4
	add.l	saveOffset,a4

	move.l	vertexprojection2_pointer,a5														;20
	move.l	x_block_add_pointer,d0
	move.l	y_block_pointer,d1
	move.l	number_of_vertices,d7
	asr.l	#6,d7
	subq	#1,d7
	move.w	#%1111111111111100,d5
.loop
	REPT 64
	; here we start saving the data
	move.w	(a5)+,d0			;x-rot
	move.w	(a5)+,d1			;y-rot

	asr.w	#5,d0
	asr.w	#5,d1
	and.w	d5,d0
	and.w	d5,d1	

	add.w	a0,d0				;x-point
	add.w	a1,d1				;y-point

	move.l	d0,a3
	move.w	(a3)+,d6			;x offset-point
	move.l	d1,a2
	add.w	(a2),d6				;x+y offset-point
	move.w	d6,(a4)+			; save x+y offset
	move.w	(a3),(a4)+			; save mask
	; increase a4 offset		
	add.w	#64-4,a4	
	ENDR
	dbra	d7,.loop
	rts


genClearCodeRout
.loop
		move.w	d0,(a0)+
		move.w	d5,(a0)+
		add.w	d4,d5		
	dbra	d7,.loop
	addq.w	#8,d1
	rts

generateClearScreenCode
;	lea		clearScreen1bpl,a0
	move.l	clearScreen1bplPointer,a0
	move.l	a0,a1

	move.w	#$2079,(a0)+					; move.l x,a0
    move.l  #screenpointer2,(a0)+

    ; here we add #x indirect to a0
    move.w	#$41E8,(a0)+				;	lea		x(a0),a0		;2
    move.w	#0,(a0)+					;	x = 0					; <----- clearScreen1bpl+8

    move.w  #$7000,(a0)+                ;   moveq   #0,d0
;    move.w  #$7001,(a0)+                ;   moveq   #0,d0

    move.w	#160,d4
    move.w  #20-1,d6
    move.w  #200-1,d7

    move.w  #$3140,d0				;move.w	d0,x(a0)

    ; we do coding this shit from left to right now
    moveq 	#56,d1               ; offset

cc1 = 52
    move.w	d1,d5	; starting at 4th block (skip 3)
    add.w	#cc1*160,d5	; skip the first 20 lines
    move.w	#200-2*cc1-1,d7	; do 160 lines
    jsr		genClearCodeRout

cc2 = 31
    move.w	d1,d5	; starting at 4th block (skip 3)
    add.w	#cc2*160,d5	; skip the first 20 lines
    move.w	#200-2*cc2-1,d7	; do 160 lines
    jsr		genClearCodeRout

cc3 = 18
    move.w	d1,d5	; starting at 4th block (skip 3)
    add.w	#cc3*160,d5	; skip the first 20 lines
    move.w	#200-2*cc3-1,d7	; do 160 lines
    jsr		genClearCodeRout

cc4 = 8
    move.w	d1,d5	; starting at 4th block (skip 3)
    add.w	#cc4*160,d5	; skip the first 20 lines
    move.w	#200-2*cc4-1,d7	; do 160 lines
    jsr		genClearCodeRout

cc5 = 4
	move.w	d1,d5
	add.w	#cc5*160,d5
	move.w	#200-2*cc5-1,d7
    jsr		genClearCodeRout

cc6 = 0
	move.w	d1,d5
	add.w	#cc6*160,d5
	move.w	#200-2*cc6-1,d7
    jsr		genClearCodeRout

cc7 = 0
	move.w	d1,d5
	add.w	#cc7*160,d5
	move.w	#200-2*cc7-1,d7
    jsr		genClearCodeRout

cc8 = 0
	move.w	d1,d5
	add.w	#cc8*160,d5
	move.w	#200-2*cc8-1,d7
    jsr		genClearCodeRout

cc9 = 4
	move.w	d1,d5
	add.w	#cc9*160,d5
	move.w	#200-2*cc9-1,d7
    jsr		genClearCodeRout

cc10 = 8
	move.w	d1,d5
	add.w	#cc10*160,d5
	move.w	#200-2*cc10-1,d7
    jsr		genClearCodeRout

cc11 = 20
	move.w	d1,d5
	add.w	#cc11*160,d5
	move.w	#200-2*cc11-1,d7
    jsr		genClearCodeRout

cc12 = 33
	move.w	d1,d5
	add.w	#cc12*160,d5
	move.w	#200-2*cc12-1,d7
    jsr		genClearCodeRout

cc13 = 56
	move.w	d1,d5
	add.w	#cc13*160,d5
	move.w	#200-2*cc13-1,d7
    jsr		genClearCodeRout

; 13 * 200 = 2600
; 2600 - 248*2 = 2600 - 496 = 2104 * 16 = 33664

    move.w  #$4E75,(a0)+

	rts

generateDotsLoop
;	lea		dotsLoop,a0
	move.l	dotsLoopPointer,a0
	move.l	a0,a1
;		move.w	#$2449,(a0)+				;	movea.l	a1,a2
;		move.w	#$D5D8,(a0)+				;	adda.l	(a0)+,a2
	move.l	#$2449D5D8,d3
;		move.w	#$3E1A,(a0)+			;	move.w	(a2)+,d7
;		move.w	#$DE46,(a0)+			;	add.w	d6,d7
	move.l	#$3E1ADE46,d0
;		move.w	#$2647,(a0)+			;	movea.l	d7,a3
;		move.w	#$301A,(a0)+			;	move.w	(a2)+,d0
	move.l	#$2647301A,d1
;		move.w	#$8153,(a0)+			;	or.w	d0,(a3)
	move.w	#$8153,d2

	move.l	#nr_of_dots-1,d7
.outerloop
	moveq	#nr_of_partitions-1,d6

	move.l	d3,(a0)+
.innerloop
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.w	d2,(a0)+
		dbra	d6,.innerloop
	dbra	d7,.outerloop
	move.w	#$4ED6,(a0)+			; jmp (a6)
	rts

_dotsFadeOffset	dc.w	0

cycleDotColors
	lea		colorList,a0
	move.w	colorOffset2,d4
	move.w	_dotsFadeOffset,d3
	add.w	d4,d3
	add.w	d3,a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,$ffff8240

	add.w	#16,d4
	cmp.w	#$70,d4
	bne		.cont
		move.w	#16,d4
.cont
	move.w	d4,colorOffset2


	subq.w	#1,bitPlaneFlag
	bne		.noCheck		;---------------\
	move.w	#1,waitOneFrame					;
	move.w	#2,bitPlaneFlag					;
.checkColor									;
	add.w	#2,colorOffset					;
	cmp.w	#6,colorOffset					;
	bne		.noColorReset					;
		move.w	#0,colorOffset				;
.noColorReset								;
;	lea		clearScreen1bpl+8,a0			;
	move.l	clearScreen1bplPointer,a0
	move.w	colorOffset,8(a0)				;
.noCheck						;<----------/
	rts


generateDots
	; first
	lea		sdata,a1			; this is the dest
	move.l	#1<<12,d2
	moveq	#0,d0				; x position
	move.l	#nr_of_dots/5-1,d6
	lea		sinedata,a0
	add.w	soffset1,a0
.innerloop1
	REPT 5
		; here we do one iterations
		moveq	#0,d5				; zero out d5
		add.w	(a0)+,d5			; d5 holds 
		add.l	d0,d5
		add.w	#2,a0
;		move.l	d5,(a1)+
		add.l	d2,d0
	ENDR 
	dbra	d6,.innerloop1
	sub.w	#2,soffset1
	bge		.np1
		move.w	#200,soffset1
.np1

	; second
	lea		sdata2,a1
	move.l	#1<<12,d2
	move.l	#30<<12,d0				; x position
	lea		oForSine,a3
	add.w	listoffset,a3
	move.w	(a3),d6
	move.w	d6,d7
	neg.w	d7
	add.w	#95,d7
;	move.w	#95-1,d6
	lea		sinedata,a0
	add.w	soffset2,a0
.innerloop2
		; here we do one iterations
		moveq	#0,d5				; zero out d5
		add.w	(a0)+,d5			; d5 holds 
		add.l	d0,d5
		add.w	#2,a0
		move.l	d5,(a1)+
		add.l	d2,d0
	dbra	d6,.innerloop2

	lea		sinedata,a0
	add.w	soffset1,a0

.clear
		moveq	#0,d5				; zero out d5
		add.w	(a0)+,d5			; d5 holds 
		add.l	d0,d5
		add.w	#2,a0
		move.l	d5,(a1)+
		sub.l	d2,d0
		dbra	d7,.clear

	sub.w	#2,soffset2
	bge		.np2
		move.w	#200,soffset2
.np2

	add.w	#2,listoffset
	cmp.w	#95*2*2,listoffset
	bne		.x

		move.w	#0,listoffset
.x

	rts

drawDots
	move.w	colorOffset,d6					

	lea		xoffsetdata,a0
	add.w	xoffsetcounter,a0
	move.w	(a0),d5
	move.w	d5,d4
	lea		sdata,a0				; this has the sine, basically this is how the point gets generated
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a0

;	lea		savedTable,a1			; lookup table, for every pixel defined by a 100 x / 64 y pattern, we have 16 lookups sequentially
	move.l	savedTable_pointer,a1
	move.l	screenpointer2,d7		; upperword sorted

	move.w	#164*95,d0		;8
	; 164 times d5 ==
	; 128 + 32 + 4 times
	add.w	d5,d5		;4
	add.w	d5,d5		;4			;
	sub.w	d5,d0		;4			; -*4
	lsl.w	#3,d5		;12
	sub.w	d5,d0		;4			; -*32
	add.w	d5,d5		;4
	add.w	d5,d5		;4
	sub.w	d5,d0		;4			; -*128

;	lea		dotsLoop,a4		;8
	move.l	dotsLoopPointer,a4
	lea		.x1,a6
;	jmp		(a4,d0.w)
;	jmp		(a4)
.x1


	
	lea		sdata2,a0


;	lea		dotsLoop,a4
	move.l	dotsLoopPointer,a4
	lea		.x2,a6
	jmp		(a4)
.x2

		add.w	#2,xoffsetcounter
		cmp.w	#2*100,xoffsetcounter
		ble		.noreset
		move.w	#0,xoffsetcounter
.noreset

	rts

drawLine
	cmp.w	#200,lc
	bgt		.end

	lea		dotspic,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2

	; fixpic
	add.w	#16,a1
	add.w	#16,a2
	move.w	lc,d0
	; 160 = 128 + 32 + 4
	add.w	d0,d0	;2
	add.w	d0,d0	;4
	add.w	d0,d0	;8
	move.w	d0,d1		; save 8
	add.w	d0,d0	;16
	add.w	d0,d1		; add 8 = 24

	add.w	d1,a0


	add.w	d0,d0	;32
	move.w	d0,d1	;32
	add.w	d0,d0
	add.w	d0,d0	;128
	add.w	d0,d1	;160				; number of lines skipped	/ source = 3*8 = 24, target is 160

;	add.w	d1,a0
	add.w	d1,a1
	add.w	d1,a2

	move.l	#2-1,d1
.y
	REPT 3
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
	ENDR
;	add.l	#160-3*8,a0
	add.l	#160-3*8,a1
	add.l	#160-3*8,a2
	dbra	d1,.y


	add.l	#160,a1
	add.l	#160,a2
	add.l	#40*24-3*8,a0
	moveq	#20-1,d1
.x
	REPT 3
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
	ENDR
	sub.l	#24+24,a0
	add.l	#160-3*8,a1
	add.l	#160-3*8,a2
	dbra	d1,.x


	add.w	#2,lc
	rts

.end
	move.w	#$2700,sr
	move.l	#default_vbl2,$70.w
	move.w	#$2300,sr
	move.w	#0,go
	rts
;;;;;;;;;;;;;; DOTS END ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; DOTS END ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; DOTS END ;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;; GREETINGS START ;;;;;;;;;
;;;;;;;;;;;;;; GREETINGS START ;;;;;;;;;
;;;;;;;;;;;;;; GREETINGS START ;;;;;;;;;
resize						equ 1
z_on						equ 1
pers						equ 1190
debugfill					equ 0
blitter						equ 0
current_number_vertices		equ 8
current_number_polygons		equ 6
number_of_edges				equ 12
; object and drawing
checker						equ 1
checkerZoom					equ 0
sizeSwitch					equ 70
size						equ 60
lineloopsize				equ 9
divsize 					equ size+4
possize						equ (size)*2
negsize 					equ -possize
; some release switches
generateOffsetTables		equ 1
generateLinesRout			equ 1
; greetings
greetings_sprites_width   equ 20
greetings_sprites_height  equ 4
greetings_blockheight     equ 8
greetings_offset			equ 6
greetings_number_of_sprites       EQU greetings_sprites_width*greetings_sprites_height   ; all sprites
number_of_greetings     equ 9

;resize_steps			equ 512
;resize_start			equ	128+58

resize_steps			equ 384
resize_start			equ	86+58


doCubeEffect
.init
	move.w	#$2700,sr
	move.l	#default_vbl2,$70
	move.l	#dummy,$120 
	move.w	#$2300,sr
;			wait_for_vbl
;	move.w	#$777,$ffff8250

	jsr		init_yblock_aligned
	jsr		init_exp_log_cube
	jsr		initZTable
	jsr		initCubeObject				; 7 frames
	jsr		generateClearCode
	jsr		generateEorFillCode
	jsr		generateStuff
			exitOnSpace




	move.w	#70,sizeCounter
	lea		$ffff8240+2*2,a0
	move.l	#$07770777,d0
	rept 7
		move.l	d0,(a0)+
	endr

	move.w	#$777,$ffff8242
	move.w	#$777,$ffff8250

	move.w	#2,cubeScreenOffset						; FOR CUBE STUFF
	sub.w	#10*4,vertices_xoff
	add.w	#2*4,vertices_yoff

	move.w	#80*9,checker_lineoffset
	move.w	#9,checker_lineinv

	move.w	#0,checkerBlockRemove
	move.w	#1,checker_minus
	move.w	#2,checker_counter

	move.l	divtablepointer,a6
	move.l	a6,currentDivPointer


	screenswap


	move.w	#0,vblcounter

.checker1
	wait_for_vbl
	screenswap
	raster #$007
	tst.w	.screenclear
	beq		.noclear


	move.l	screenpointer2,a0
	jsr		clear4bpl

	subq.w	#1,.screenclear
	jmp		.skipdiv
.noclear

		jsr	initDivTableFrame
		tst.w	divFrameCounter
		bne		.x
			addq.w	#1,vblcounter
.x


			raster #$000
.skipdiv
		jsr	doChecker
			raster #$070

	subq.w	#1,.derpderp
	beq		.checkerPrecalc
			exitOnSpace
	jmp		.checker1


.rotatecounter	dc.w	100
.screenclear	dc.w	2
.derpderp		dc.w	3


.checkerPrecalc
.precalcInit	
	move.w	#$2700,sr
	move.l	#checker_vbl,$70
	move.w	#$2300,sr
;	wait_for_vbl



.precalcLoop
		raster #$007
	nop

	jsr		initDivTableFrame
	tst.w	divFrameCounter
	bne		.xy
		addq.w	#1,vblcounter
.xy
	

	jsr		initExplosionStuff    
	jsr		preshift_sprite
	jsr		prepareExplosion
			exitOnSpace

	cmp.w	#2,checker_counter
	bne		.precalcLoop
	cmp.w	#$0C30-$50*2,checker_lineoffset
	bne		.precalcLoop
	jmp		.checker2_init



.checker2_init




	move.w	#$2700,sr
	move.l	#default_vbl2,$70        
	move.w	#$2300,sr


	move.w	#1,checkerBlockRemove
	move.w	#2,stepSpeedX
	move.w	#resize_start,sizeCounter
	move.w	#2,cubeScreenOffset						; FOR CUBE STUFF


	REPT 2
			wait_for_vbl
			screenswap
	jsr		doChecker
	lea		*+8,a2
	jmp		gradientFlatShade
;.ag1
	jsr		clearArea3 					; white
	jsr		setSizeObject
	jsr		advanceRotationPoly
	jsr		doRotationPoly				; blue
	jsr		regelEdges					; bright red
	jsr		drawLines					; pink
	jsr 	eorFill3					; blue
			exitOnSpace
	ENDR


.checker2
			wait_for_vbl
			screenswap
	lea		*+8,a2
	jmp		gradientFlatShade
	jsr		doChecker
	jsr		clearArea3 					; white
	jsr		setSizeObject
	jsr		advanceRotationPoly
	jsr		doRotationPoly				; blue
	jsr		regelEdges					; bright red
	jsr		drawLines					; pink
	jsr 	eorFill3				; blue
			raster #$777
			exitOnSpace

	subq.w	#1,.rotatecounter
	bne		.checker2
	jmp		.checker3_init


.checker3_init
	move.w	#150,.rotatecounter
	move.w	#4,stepSpeedX
	move.w	#1,checker_counter
	move.w	#1,checker_counter_count
	move.w	#40*60*2,checker_max

.checker3
			wait_for_vbl
			screenswap
	lea		*+8,a2
	jmp		gradientFlatShade
	jsr		doChecker
	jsr		clearArea3 					; white
	jsr		setSizeObject
	jsr		advanceRotationPoly
	jsr		doRotationPoly				; blue
	jsr		regelEdges					; bright red
	jsr		drawLines					; pink
	jsr 	eorFill3				; blue
			raster #$777

	bne		.fadeCubeColor
		subq.w	#1,cube_gradientCounter
		bne		.fadeCubeColor
			move.w	#20,cube_gradientCounter
			cmp.w	#14*6,cube_gradientOffset
			bge		.fadeCubeColor
				add.w	#14,cube_gradientOffset
.fadeCubeColor
			exitOnSpace

	subq.w	#1,.rotatecounter
	bne		.checker3


.rotate1_init
	move.w	#6,stepSpeedX
	move.w	#4,stepSpeedY
	move.w	#6,stepSpeedZ
	move.w	#40*60*2,checker_max

.rotate1
			wait_for_vbl
			screenswap
	move.w	.cubespeed,checker_counter_count
	lea		*+8,a2
	jmp		gradientFlatShade
	jsr		doChecker
	jsr		clearArea3 					; white
	jsr		setSizeObject
	jsr		advanceRotationPoly
	jsr		doRotationPoly				; blue
	jsr		regelEdges					; bright red
	jsr		drawLines					; pink
	jsr 	eorFill3				; blue
			raster #$777
	
	tst.w	.cuberesize
	beq		.noresize
		add.w	#2,sizeCounter
		cmp.w	#resize_steps,sizeCounter
		blt		.noresize
			move.w	#0,sizeCounter
.noresize

	cmp.w	#2,checker_cycle
	bne		.ttt
		move.w	#40*126*2,checker_max
		move.w	#1,.cubespeed
.ttt

	cmp.w	#2,checker_cycle
	bne		.continue
		tst.w	checker_minus
		ble		.continue
		cmp.w	#40*101,checker_lineoffset		
		blt		.continue
			move.w	#$2700,sr
			move.l	#cube_vertcurtain_vbl,$70.w
			move.w	#$2300,sr

			move.w	checker_lineoffset,d0
			move.w	#2,.cuberesize
			cmp.w	#40*200,checker_lineoffset
			beq		.rotate2_init
.continue
			exitOnSpace
	jmp 	.rotate1

.cuberesize	dc.w	0
.cubespeed	dc.w	2

.rotate2_init
.rotate2
			wait_for_vbl
			screenswap
	lea		*+8,a2
	jmp		gradientFlatShade
	jsr		clearArea3 					; white
	jsr		setSizeObject
	jsr		advanceRotationPoly
	jsr		doRotationPoly				; blue
	jsr		regelEdges					; bright red
	jsr		drawLines					; pink
	jsr 	eorFill3				; blue
			raster #$777

	add.w	#2,sizeCounter
	cmp.w	#resize_steps,sizeCounter
	blt		.continue_rotation
		move.w	#0,sizeCounter
		jmp		.rotate3_init
.continue_rotation
			exitOnSpace
	jmp 	.rotate2

.rotate3_init
	; fix the vbl here
	move.w	#$2700,sr
	move.l	#cube_static_vbl,$70
	move.w	#$2300,sr

	jsr	clearArea3
		wait_for_vbl
		screenswap
	jsr	clearArea3
	move.w	#0,cubeScreenOffset						; FOR CUBE STUFF

	move.w	#gCMiddle,$ffff8248			; light text		color 4				bpl			3
	move.w	#gCMiddle,$ffff824A			; light text		color 5				bpl	1 +		3
	move.w	#gCMiddle,$ffff824C			; light text		color 6				bpl		2 +	3
	move.w	#gCMiddle,$ffff824E			; light text		color 7				bpl		2 +	3

	move.w	#gCBack,$ffff8250			; dark text			color 8				bpl				4
	move.w	#gCBack,$ffff8252			; dark text			color 9				bpl	1 +			4
	move.w	#gCBack,$ffff8254			; dark text			color 10			bpl     2 + 	4
	move.w	#gCBack,$ffff8256			; dark text			color 11			bpl 1 + 2 + 	4

	move.w	#gCFront,$ffff8258			; white text		color 12			bpl			3 + 4
	move.w	#gCFront,$ffff825A			; white text		color 13			bpl 1 +     3 + 4
	move.w	#gCFront,$ffff825c			; white	text		color 14			bpl 	2 + 3 + 4
	move.w	#gCFront,$ffff825e			; white	text		color 15			bpl 1 + 2 + 3 + 4

	move.w	#0,dhscounter
;	move.l	screenpointer2,d0
;	move.l	screenpointer,screenpointer2
;	move.l	d0,screenpointer

	lea		$ffff8240+8*2,a0
	move.l	#$5550555,(a0)+
	move.l	#$5550555,(a0)+
	move.l	#$5550555,(a0)+
	move.l	#$5550555,(a0)+

.rotate3
			wait_for_vbl
			screenswap

	jsr		advanceRotationPoly

	tst.w	slowcube
	beq		.nocounter						; if slowcube is 0, we dont throttle the speed
.slowcube_active
		tst.w	slowcubedoublebuffer			; check if we need to draw second frame
		beq		.slowbuffer
		subq.w	#1,dhscounter
		bne		.slowcubenodraw
		move.w	#0,slowcubedoublebuffer		; we do slowcubestuff, so make sure we do the next buffer as well

.nocounter
	; draw frame
	lea		*+8,a2
	jmp		gradientFlatShade
	jsr		clearArea3 					; white
	jsr		setSizeObject
	jsr		doRotationPoly				; blue
	jsr		regelEdges					; bright red
	jsr		drawLines					; pink
	jsr 	eorFill3					; blue
	move.w	#dhswaiter,dhscounter
.slowcubenodraw

	cmp.w	#resize_steps/4,sizeCounter							;1/4 of the sine
	bne		.check256
	jmp		.setFirsty
.check256		
	cmp.w	#resize_steps/2+resize_steps/4,sizeCounter			;3/4 of the sine
	bne		.gogogo4
.setFirsty
		move.w	#0,_firsty
.gogogo4

	; if sizeCounter == 0 or if its 256 then draw text
	cmp.w	#0,sizeCounter
	beq		.doTextReset
	cmp.w	#resize_steps/2,sizeCounter
	beq		.doText
	jmp		.notext

.doTextReset
.doText
	jsr		doGreetings
	tst.w	greetingsOffset
	bne		.notext
		rts
.notext

	add.w	#2,sizeCounter
	cmp.w	#resize_steps,sizeCounter
	blt		.continue_rotation2
		move.w	#0,sizeCounter
.continue_rotation2


;;;;;;;;;; greetings explode
	jsr		explodeGreetings
			exitOnSpace

	IFNE cubeframe
		move.w	#$077,$ffff8240
	ENDC
	jmp 	.rotate3


;;;;;;;;;;;;;;;;;;;;;;; slowcube part
.slowbuffer
	move.w	#1,slowcubedoublebuffer
	move.w	#255*2*2,d7
	move.w	stepSpeedX,d0
	move.w	stepSpeedY,d0
	move.w	stepSpeedZ,d0
	sub.w	d0,currentStepX
	bge		.ok1
		move.w	d7,currentStepX
.ok1
	sub.w	d0,currentStepY
	bge		.ok2
		move.w	d7,currentStepY
.ok2
	sub.w	d0,currentStepZ
	bge		.ok3
		move.w	d7,currentStepZ
.ok3
	sub.w	#2,sizeCounter
		lea		*+8,a2
		jmp		gradientFlatShade
		jsr		clearArea3 					; white
		jsr		setSizeObject
		jsr		doRotationPoly				; blue
		jsr		regelEdges					; bright red
		jsr		drawLines					; pink
		jsr 	eorFill3				; blue
	addq.w	#2,sizeCounter
    move.w  #256*2*2,d7									;8
; do angular speeds and get indices 
    move.w  currentStepX,d2								;16
    add.w   stepSpeedX,d2								;16
    cmp.w   d7,d2										;4
    blt     .goodX										;12
        sub.w   d7,d2									;4
.goodX
    move.w  d2,currentStepX								;16		--> 68

    move.w  currentStepY,d4								;16
    add.w   stepSpeedY,d4								;16
    cmp.w   d7,d4										;4
    blt     .goodY										;12
        sub.w   d7,d4									;4
.goodY
    move.w  d4,currentStepY								;16		--> 68

    move.w  currentStepZ,d6								;16
    add.w   stepSpeedZ,d6								;16
    cmp.w   d7,d6										;4
    blt     .goodZ										;12
        sub.w   d7,d6									;4
.goodZ
    move.w  d6,currentStepZ								;16		--> 68
    		exitOnSpace
	jmp		.slowcubenodraw

;;;;;;;;;;;;;; GREETINGS ROUT ;;;;;;;;;;
;;;;;;;;;;;;;; GREETINGS ROUT ;;;;;;;;;;
;;;;;;;;;;;;;; GREETINGS ROUT ;;;;;;;;;;
explodeGreetings
	tst.w	fillow
	bne		.end

	tst.w	_firsty									;only used here and set once
	bne		.notfirst
		move.w	#-1,_firsty
		move.w	#2,_waitexplosion
		move.w	#2,_cleargreetings
		jsr		prepareExplosionWithoutTest
		move.w	#1,explosion_done
.notfirst

	tst.w	explosion_done
	beq		.end


	cmp.w	#(resize_steps*4/3),sizeCounter
	bge		.end

	subq.w	#1,_waitexplosion
	bgt		.end
		jsr		clearGreetings
    	jsr     swap_killbuffers
		jsr		greetingsClearSprites
		jsr		greetingsShowSprites

.end
	rts



clearGreetings
	subq.w	#1,_cleargreetings
	blt		.end
;	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.w	#160*90,a0
	add.w	#160*90,a1
	moveq	#0,d0
o set 44
	REPT 31
y set o
		REPT 10
;			move.w	d0,y(a0)
			move.w	d0,y(a1)
y set y+8
		ENDR
o set o+160
	ENDR
.end
	rts


_cleargreetings	dc.w	1
_firsty			dc.w	1
_waitexplosion	dc.w	0

checker_vbl
	addq.w	#1,$466

	move.l	screenpointer,$ffff8200

	movem.l	d0-a6,-(sp)
			screenswap

	IFNE	playmusic
	IFNE	playmusicinvbl				
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	ENDC
			nop
			nop
			nop

	checkScreen



	jsr		doChecker
	movem.l	(sp)+,d0-a6
	rte

clear4bpl
		moveq	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		move.l	d0,a1
		move.l	d0,a2
		move.l	d0,a3
		move.l	d0,a4
		move.l	d0,a5
		move.l	d0,a6
		add.l	#32000,a0
		REPT 571
		movem.l	d0-d7/a1-a6,-(a0)
		ENDR
		movem.l	d0-d5,-(a0)
	rts

init_exp_log_cube:   

init_log_cube:      
    lea     log_src,A4    		; skip 0
    move.l  logpointer,d5
    move.l  d5,a2
    moveq   #-2,d6           	; index

    move.w  #-EXPS*2,(A2)+  	; NULL
    move.w  #LOGS-1-1,D7
.il:
    	move.w  (A4)+,D0        ; log
    	add.w   D0,D0
    	move.w  d0,(a2)+        ; pos2
    	add.w   #EXPS*2,D0      ; NEG
    	move.w  d6,d5           ; take negative value into account
    	move.l  d5,a3
    	move.w  d0,(a3)         ; move in value

    	subq.w  #2,d6
    dbra    D7,.il

init_exp_cube:      

    move.w  #EXPS*2,D7
    lea     exp_src,a3

    move.l	expointernorm,a0
    lea		(a0,d7.w),a1
    lea		(a1,d7.w),a2

    move.w  #EXPS-1,D7
.ie:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1
    	; this is specific for the rotation code
    	asr.w	#2,d0
    	asr.w	#2,d1
		move.w  d0,(a0)+
		move.w  d1,(a1)+
		move.w  d0,(a2)+
    dbra    D7,.ie


init_exp2_cube:    
	lea		$3000,a0
	moveq	#0,d0
.cl
		move.l	d0,(a0)+
		cmp.w	#$5000,a0
		bne		.cl

    move.w  #EXPS*2,D7
    lea     exp_src,a3

    lea  	$5000,a4
    lea     (a4,d7.w),a5
    lea     (a5,d7.w),a6

    move.w  #EXPS-1,D7
.ie2:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1

  		asr.w	#8,d0		; fix this in exptable
		asr.w	#8,d1		; fix this in exptable
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d1
		add.w	d1,d1

		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+

    dbra    D7,.ie2
    ; range 1000 to B000
    rts


redTable
	dc.w	$100
	dc.w	$200
	dc.w	$300
	dc.w	$400
	dc.w	$500
	dc.w	$600
	dc.w	$700

yellowTable
	dc.w	$011
	dc.w	$022
	dc.w	$033
	dc.w	$044
	dc.w	$055
	dc.w	$066
	dc.w	$077

greenTable
	dc.w	$010
	dc.w	$020
	dc.w	$030
	dc.w	$040
	dc.w	$050
	dc.w	$060
	dc.w	$070

blueTable
	dc.w	$001
	dc.w	$002
	dc.w	$003
	dc.w	$004
	dc.w	$005
	dc.w	$006
	dc.w	$007

whiteTable
	dc.w	$111
	dc.w	$222
	dc.w	$333
	dc.w	$444
	dc.w	$555
	dc.w	$777
	dc.w	$777

	dc.w	$111
	dc.w	$211
	dc.w	$322
	dc.w	$433
	dc.w	$544
	dc.w	$655
	dc.w	$766

	dc.w	$100
	dc.w	$211
	dc.w	$311
	dc.w	$422
	dc.w	$533
	dc.w	$644
	dc.w	$755

	dc.w	$100
	dc.w	$200
	dc.w	$311
	dc.w	$411
	dc.w	$522
	dc.w	$633
	dc.w	$744

	dc.w	$100
	dc.w	$200
	dc.w	$300
	dc.w	$411
	dc.w	$511
	dc.w	$622
	dc.w	$733

	dc.w	$100
	dc.w	$200
	dc.w	$300
	dc.w	$400
	dc.w	$511
	dc.w	$611
	dc.w	$722

	dc.w	$100
	dc.w	$200
	dc.w	$300
	dc.w	$400
	dc.w	$500
	dc.w	$611
	dc.w	$711

	dc.w	$100
	dc.w	$200
	dc.w	$300
	dc.w	$400
	dc.w	$500
	dc.w	$600
	dc.w	$700




	;	\1 	colortable				a0
	;	\2	colorpaletteaddress		d0,d1,d2
	;	\3	value					address1a
	;	
compareAndSetMulti	macro
	cmp.l	\2,d7					;	cmp.l	d0,d7
	blt		.set7\@
	cmp.l	\2,d6					;	cmp.l	d0,d6
	blt		.set6\@
	cmp.l	\2,d5					;	cmp.l	d0,d5
	blt		.set5\@
	cmp.l	\2,d4					;	cmp.l	d0,d4
	blt		.set4\@
	cmp.l	\2,d3					;	cmp.l	d0,d3
	blt		.set3\@
	cmp.l	\2,a3					;	cmp.l	d0,a3
	blt		.set2\@

	move.w	(a1),\2					;	move.w	(a1),d0
	jmp		.done\@
.set2\@
	move.w	2(a1),\2				;	
	jmp		.done\@
.set3\@
	move.w	4(a1),\2
	jmp		.done\@
.set4\@
	move.w	6(a1),\2
	jmp		.done\@
.set5\@
	move.w	8(a1),\2
	jmp		.done\@
.set6\@
	move.w	10(a1),\2
	jmp		.done\@
.set7\@
	move.w	12(a1),\2
.done\@
	move.w	\2,\3
	move.w	\2,\4
	move.w	\2,\5
	endm

	;	\1 	colortable
	;	\2	colorpaletteaddress
	;	\3	value
compareAndSet	macro
	lea		\1,a1

	cmp.l	\3,d7
	blt		.set7\@
	cmp.l	\3,d6
	blt		.set6\@
	cmp.l	\3,d5
	blt		.set5\@
	cmp.l	\3,d4
	blt		.set4\@
	cmp.l	\3,d3
	blt		.set3\@
	cmp.l	\3,a3
	blt		.set2\@

	move.w	(a1),\2
	jmp		.done\@
.set2\@
	move.w	2(a1),\2
	jmp		.done\@
.set3\@
	move.w	4(a1),\2
	jmp		.done\@
.set4\@
	move.w	6(a1),\2
	jmp		.done\@
.set5\@
	move.w	8(a1),\2
	jmp		.done\@
.set6\@
	move.w	10(a1),\2
	jmp		.done\@
.set7\@
	move.w	12(a1),\2

.done\@
	endm

; should draw at bitplanes 2 and 3
; 1 = 0
; 2 = 2	--> $ffff8244	color 1
; 3 = 4 --> $ffff8248	color 2
; 4 = 8
;		2+4 = 6 ==> $ffff824C color 3
cubecolor1	equ $ffff8242	; bpl 2 = color 2, and color 3 and color 10 ; --> 8244 (2), 8246 (3), 8254 (10)
cubecolor2	equ $ffff8244	; bpl 3 = color 4, and color 5 and color 12	; --> 8248 (4), 824A (5), 8256 (12) 
cubecolor3	equ $ffff8246	; bpl 2+3 = color 6, and color 7 and color 14; --> 825C (6), 825E (7), 825A

address1a	equ $ffff8244
address1b	equ $ffff8246
address1c	equ $ffff8254

address2a	equ	$ffff8248
address2b	equ $ffff824a
address2c	equ	$ffff8258

address3a	equ	$ffff824c
address3b	equ $ffff824e
address3c	equ $ffff825c
cube_gradientOffset
	dc.w	0
cube_gradientCounter
	dc.w	10

gradientFlatShade
	lea		cube_colorValues,a0
	movem.l	(a0)+,d0-d2

	move.l	#$02000,a3			; 2
	move.l	#$04000,d3			; 3
	move.l	#$07000,d4			; 4	
	move.l	#$09000,d5			; 5
	move.l	#$11000,d6			; 6
	move.l	#$1C000,d7			; 7

	lea		whiteTable,a1
	add.w	cube_gradientOffset,a1

	tst.w	cubeScreenOffset
	beq		.singleColor
.multiColor
	compareAndSetMulti	a1,d0,address1a,address1b,address1c
	compareAndSetMulti	a1,d1,address2a,address2b,address2c
	compareAndSetMulti	a1,d2,address3a,address3b,address3c
	jmp		(a2)

.singleColor
	compareAndSet	redTable,cubecolor1,d0
	compareAndSet	redTable,cubecolor2,d1
	compareAndSet	redTable,cubecolor3,d2
	jmp		(a2)






cube_timer_a_curtain_start:
	move.w	#$2700,sr			;Stop all interrupts
	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w
   	pushd0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop
    nop

	move.w	#$233,$ffff8240

    clr.b   $fffffa19.w         	;Timer-A control (stop)											;24 => 6

    move.b 	#0,$fffffa1b.w    																		;20 => 5
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)									;28 => 7
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)										;28 => 7
    move.l  #cstatic2,$120.w        ;Install our own Timer B						;24 => 6
    move.b  #199,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   	;20 => 5
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))								;20 => 5
	popd0
	rte



cube_static_vbl
	move.l 	screenpointershifter,$ff8200
	addq.w 		#1,$466.w
	incSync

	move.w	#0,$ffff8240


    clr.b   $fffffa19.w         	;Timer-A control (stop)
    bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
    bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
    move.b  #48,$fffffa1f.w         ;Timer A Delay (data)
    move.b  #%111,$fffffa19.w       ;Timer A Predivider (start Timer A)
    move.l	#cube_timer_a_curtain_start,$134.w    
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	pusha0
;	pushd0
;	move.l	sndh_pointer,a0
;	moveq	#0,d0
;	move.b	$b8(a0),d0
;	beq		.ok
;		move.w	#$700,$ffff8240
;		move.b	#0,$b8(a0)
;		jmp	.go
;.ok
;	move.w	#$000,$ffff8240
;.go
;	popd0

	IFNE playmusic
	move.l	sndh_pointer,a0
	jsr		8(a0)
	ENDC
	popa0
	rte



cstatic2
	IFNE cubeframe
	ELSE
	move.w	#$0,$ffff8240
  	ENDC
    move.b  #0,$fffffa1b.w  
    move.b  #0,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	rte

cube_vertcurtain_vbl
	move.l 	screenpointershifter,$ff8200
	addq.w 		#1,$466.w
	incSync

	move.w	#0,$ffff8240
	move.w	rasteroffsetstart,rasteroffset
	pusha0
		lea		rasterList,a0
		add.w	rasteroffset,a0
		move.l	a0,rasterpointer

	subq.w	#1,rastercounter
	bne		.nos
		move.w	#5,rastercounter
		subq.w	#2,rasteroffsetstart
		bge		.nos
			move.w	#0,rasteroffsetstart
.nos

	move.w	#7,barcounter
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.l	#timer_bx,$120.w

	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on

	IFNE playmusic
	move.l	sndh_pointer,a0
	jsr		8(a0)
	ENDC
	popa0

	rte


timer_bx
	pusha0
		move.l	rasterpointer,a0
		move.w	(a0)+,$ffff8240
		move.l	a0,rasterpointer
	popa0

	subq.w	#1,barcounter
	bne		.cont
	    move.b  #0,$fffffa1b.w    
		move.l	#timer_b2,$120.w
	    move.b  #25,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
	    rte
.cont
    move.b  #0,$fffffa1b.w    
	move.l	#timer_bx,$120.w
    move.b  #25,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
	rte	

timer_b2
	pusha0
		move.l	rasterpointer,a0
		move.w	(a0)+,$ffff8240
		move.l	a0,rasterpointer
	popa0

    move.b  #0,$fffffa1b.w    
	move.l	#timer_b_end,$120.w
    move.b  #24,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
    rte


timer_b_end
	move.w	#0,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
    rte

dhswaiter	equ 10

slowcube				dc.w	0
dhscounter				dc.w	dhswaiter
slowcubedoublebuffer	dc.w	-1

gCFront		equ 	$777
gCMiddle	equ 	$555
gCBack		equ		$333


doGreetings
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	lea		greetingsmove,a2
	add.w	#4,a0
	add.w	#4,a1
	move.l	#31-1,d7
	add.w	#160*90,a0
	add.w	#160*90,a1
	add.w	greetingsOffset,a2
.line
o set 40
		movem.w	(a2)+,d0-d6/a3-a5			;10
		move.w	d0,o(a0)
		move.w	d0,o(a1)
o set o+8
		move.w	d1,o(a0)
		move.w	d1,o(a1)
o set o+8
		move.w	d2,o(a0)
		move.w	d2,o(a1)
o set o+8
		move.w	d3,o(a0)
		move.w	d3,o(a1)
o set o+8
		move.w	d4,o(a0)
		move.w	d4,o(a1)
o set o+8

		move.w	d5,o(a0)
		move.w	d5,o(a1)
o set o+8
		move.w	d6,o(a0)
		move.w	d6,o(a1)
o set o+8
		move.w	a3,o(a0)
		move.w	a3,o(a1)
o set o+8
		move.w	a4,o(a0)
		move.w	a4,o(a1)
o set o+8
		move.w	a5,o(a0)
		move.w	a5,o(a1)

	add.w	#160,a0
	add.w	#160,a1
	dbra	d7,.line


	add.w	#32*20,greetingsOffset
	cmp.w	#32*20*4,greetingsOffset
	bne		.noslow
		move.w	#-1,slowcube
		jmp		.cont
.noslow	
	move.w	#0,slowcube
.cont
	cmp.w	#32*20*(number_of_greetings+1),greetingsOffset
	bne		.exit
		move.w	#0,greetingsOffset
.exit
	rts

doChecker		
	;a0,a1,a2,a3,a4,a5,a6
	;d3,d4,d5,d7
	;d0,d1,d2,d6

	move.l screenpointer2,a0
	add.w	#6,a0
	move.l	a0,usp

	move.w	checker_lineinv,d7
	addq.w	#2,d7
	move.w	d7,a5

	tst.w	checkerBlockRemove
	beq		.normal
		lea		lines2,a6
		add.w	checker_lineoffset,a6
		jmp		.start
.normal
		lea		lines,a6
		add.w	checker_lineoffset,a6
.start
	move.l	a6,a1
	move.l	a1,a3
	move.l	a1,a2
	add.w	#40,a2

	move.w	a5,d3
	move.w	d3,d4
	subq.w	#1,d4

	move.l	#100-1,d5
	add.w	#16000-160,a0
.firstblock_top
		move.l	a3,a1									; 4
		dbra	d7,*+12									; 12
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
			jmp		.restblock_top_init
o set 0
		REPT 10
			move.l	(a1)+,o(a0)							; 24 * 10 = 200
o set o+16
		ENDR
		sub.w	#160,a0										;8
	dbra	d5,.firstblock_top										;12 ===> (240 + 36) * 100 = 27600
	jmp		.bottompart

.restblock_top_init
	sub.w	#160,a0
	lea		lines,a1
	add.w	checker_lineoffset,a1
	move.l	a1,a3
	move.l	a1,a2
	add.w	#40,a2	

	move.l	a2,a1
	move.l	a3,a2
	move.l	a1,a3
	lsr.w	#1,d5
	add.w	#1,d5
.restblock_top
		move.l	a3,a1
		dbra	d3,*+12
			move.w	d4,d3
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
o set 0
		REPT 10
			move.l	(a1)+,o(a0)
o set o+16
		ENDR
		move.l	a3,a1
		REPT 10
			move.l	(a1)+,o(a0)
o set o+16
		ENDR
	sub.w	#320,a0
	dbra	d5,.restblock_top

;;;;;;;;;;;;;;;;;;;;;; 2nd half of screen
.bottompart
	move.l	a6,a1
	move.l	a1,a3
	move.l	a1,a2
	add.w	#40,a2

	move.w	a5,d7
	move.w	d7,d3

	move.l	usp,a0
	add.w	#16000,a0
	move.w	#100-1,d5							; this is 100 lines
.firstblock_bottom
		move.l	a3,a1
		dbra	d7,*+12							; this is checked everyline
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
			jmp		.restblock_bottom_init
o set 0
		REPT 10
			move.l	(a1)+,o(a0)					; this is one line
o set o+16
		ENDR
		add.w	#160,a0
	dbra	d5,.firstblock_bottom
	jmp		.endpart

.restblock_bottom_init
	lea		lines,a1
	add.w	checker_lineoffset,a1
	move.l	a1,a3
	move.l	a1,a2
	add.w	#40,a2
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
	lsr.w	#1,d5
	add.w	#1,d5
.restblock_bottom
		move.l	a3,a1
		dbra	d3,*+12							; this is checked everyline
			move.w	d4,d3
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
o set 0
		REPT 10
			move.l	(a1)+,o(a0)					; this is one line
o set o+16
		ENDR
		move.l	a3,a1
		REPT 10
			move.l	(a1)+,o(a0)					; this is one line
o set o+16
		ENDR
		add.w	#320,a0
	dbra	d5,.restblock_bottom

.endpart

	subq.w	#1,checker_counter
	bne		.gogo
		move.w	checker_counter_count,checker_counter
	tst.w	checker_minus
	beq		.gogo
	blt		.minus
		add.w	#1,checker_lineinv
		add.w	#40*2,checker_lineoffset
		move.w	checker_max,d0
		cmp.w	checker_lineoffset,d0
		bne		.gogo
			move.w	#-1,checker_minus
			add.w	#1,checker_counter_count
			add.w	#1,checker_cycle
			jmp		.gogo
.minus
		sub.w	#1,checker_lineinv
		sub.w	#40*2,checker_lineoffset
		bne		.gogo
			move.w	#1,checker_minus
.gogo
	rts

checker_linePointer		dc.l	0
checker_swapcols		dc.w	0
checker_minus			dc.w	1
checker_lineinv			dc.w	0
checker_lineoffset		dc.w	0
checker_counter_count	dc.w	1
checker_counter			dc.w	1
checker_cycle			dc.w	0
checker_max				dc.w	40*126*2


sizeCounter	
	dc.w	128
previousSize
	dc.w	0

setSizeObject
	lea		sizeTab,a0
	add.w	sizeCounter,a0
	move.l	logpointer,d2
	move.w	(a0),d2
	move.w	d2,previousSize
	cmp.w	#resize_steps,sizeCounter
	blt		.cont
		move.w	#0,sizeCounter
.cont

	lea		coordsource,a0
	move.l	cubeObjectPointer,a1

	move.w	#$5000,d0						; base address of low memory
	move.l	d2,a2
	move.w	(a2),d1
	add.w	d0,d1

	neg.w	d2
	move.l	d2,a2
	move.w	(a2),d2
	add.w	d0,d2

	move.w	d1,d3		;4
	swap	d3			;4
	move.w	d2,d3		;4	(d1,d2)


	;d1 is pos
	;d2 is neg
;p0	dc.w	negsize,negsize,negsize	; (-1,-1,-1)
	move.w 	d2,(a1)+										; 24 * 8 = 192
	move.w	d2,(a1)+
	move.w	d2,(a1)+
;p1	dc.w	possize,negsize,negsize ; ( 1,-1,-1)
;	move.w 	d1,(a1)+
;	move.w	d2,(a1)+
	move.l	d3,(a1)+
	move.w	d2,(a1)+
;p2	dc.w	negsize,possize,negsize	; (-1, 1,-1)
	move.w 	d2,(a1)+
;	move.w	d1,(a1)+
;	move.w	d2,(a1)+
	move.l	d3,(a1)+
;p3	dc.w	possize,possize,negsize	; ( 1, 1,-1)
	move.w 	d1,(a1)+
;	move.w	d1,(a1)+
;	move.w	d2,(a1)+
	move.l	d3,(a1)+
;p5	dc.w	negsize,negsize,possize	; (-1,-1, 1)
	move.w 	d2,(a1)+
	move.w	d2,(a1)+
	move.w	d1,(a1)+
;p6	dc.w	possize,negsize,possize ; ( 1,-1, 1)
;	move.w 	d1,(a1)+
;	move.w	d2,(a1)+
	move.l	d3,(a1)+
;	move.w	d1,(a1)+
;p7	dc.w	negsize,possize,possize	; (-1, 1, 1)
;	move.w 	d2,(a1)+
	move.l	d3,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
;p8	dc.w	possize,possize,possize	; ( 1, 1, 1)
	move.w 	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	rts


;greetingstmp	ds.l	10000	
;
;initGreetings
;	lea		greetings_planar_pic+34,a0
;	lea		greetingstmp,a1
;
;	move.l	a1,a2
;
;y set 0
;	REPT 6
;		REPT 32
;o set y
;			REPT 10
;				move.w	o(a0),(a1)+					; 31 * 6 * 2
;o set o+8
;			ENDR
;y set y+160
;		ENDR
;	ENDR
;
;y set 80
;	REPT 3
;		REPT 32
;o set y
;			REPT 10
;				move.w	o(a0),(a1)+					; 31 * 6 * 2
;o set o+8
;			ENDR
;y set y+160
;		ENDR
;	ENDR
;	sub.l	a2,a1
;	move.b	#0,$ffffc123
;	rts



generateMaskAndOffset macro
	move.l	pointer_\1_\1,a0
	move.l	#\1,d2				; firsthalf
	jsr		generateMaskAndOffsetRout
	endm

generateMaskAndOffsetRout
	moveq	#0,d0				; val 1
	moveq	#0,d1				; val 2
	swap	d2
	moveq	#20-1,d7				; outer
	moveq	#0,d3
	move.w	#-1,d3
.ol
	moveq	#8-1,d6
.il1
		move.l	d0,(a0)+		; val
		add.l	d2,d0			; set val+firsthalf
		dbra	d6,.il1

	addq.w	#1,d0				; val2+1
	moveq	#7-1,d6

.il2
		move.l	d0,(a0)+		; val
		add.l	d2,d0			; set val+secondhalf
		dbra	d6,.il2

	move.l	d0,(a0)+			; val
	and.l	d3,d0
	addq.w	#7,d0				; val2 += 7

	dbra	d7,.ol
	rts


;y_positive_target_abs
;val		set lines_with_add
;	REPT 20
;		REPT 8
;			dc.l	val
;val			set val+firsthalf
;		ENDR
;		REPT 7
;			dc.l	val
;val			set val+secondhalf
;		ENDR
;		dc.l	val
;val			set val+last
;	ENDR


generateSmcCode	macro
	move.l	\1,a0
	move.l	\2,d0
	move.l	#\3,d2
	move.l	#\4,d3
	jsr		generateSmcCodeRout
	endm

generateSmcCodeRout
	moveq	#20-1,d7
.olx
	moveq	#15-1,d6
.ilx1
		move.l	d0,(a0)+
		add.l	d2,d0
		dbra	d6,.ilx1

	move.l	d0,(a0)+
	add.l	d3,d0
	dbra	d7,.olx
	rts



generateLines4	macro
	move.l	\1,a0
	move.l	#$BD10BD28,a2		;	eor.b	d6,(a0) ; eor.b,d6,x(a0)
	move.l	#$BF10BF28,d1		;	eor.b	d7,(a0)	; eor.b	d7,x(a0)
	move.l	#$B910B928,d2		;	eor.b	d4,(a0) ; eor.b	d4,x(a0)
	move.l	#$05500568,d3		;	bchg	d2,(a0)	; bchg	d2,x(a0)
	move.l	#$BB10BB28,d4		;	eor.b	d5,(a0)	; eor.b	d5,x(a0)
	move.l	#$B510B528,d5		;	eor.b	d2,(a0)	; eor.b	d2,x(a0)
	move.l	#$01500168,d6		;	bchg	d0,(a0)	; eor.b	d2,x(a0)
	move.l	#$B118B128,a6		;	eor.b	d0,(a0)+	; eor.b	d0,1(a0)

	move.l	#$B110B128,a3		;	eor.b	d0,(a0) ; eor.b d0,2(a0)

	move.l	#$D24A,a1		;	add		a1,a0	;	add.w	a2,d1
	move.w	#$6404,a4			;	bcc.s	*+6
	move.l	#$41E8FF60,d0		;	add.w	#x,a0
	move.w	#\2,d0				;		x

	move.l	#lineloopsize-1,d7
	jsr		glR4
	endm

glR4
.loop
		move.l	a2,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+		
		move.w	a4,(a0)+
		move.l	d0,(a0)+		

		move.l	d1,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+		
		move.w	#1,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	#2,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a3,(a0)+				;	eor.b	d0,(a0) ; eor.b d0,x(a0)
		move.w	#2,(a0)+				;	#2
		move.w	#$5E48,(a0)+
		move.w	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.loop
	rts


generateLines3	macro
	move.l	\1,a0
	move.l	#$BD10BD28,a2		;	eor.b	d6,(a0) ; eor.b,d6,x(a0)
	move.l	#$BF10BF28,d1		;	eor.b	d7,(a0)	; eor.b	d7,x(a0)
	move.l	#$B910B928,d2		;	eor.b	d4,(a0) ; eor.b	d4,x(a0)
	move.l	#$05500568,d3		;	bchg	d2,(a0)	; bchg	d2,x(a0)
	move.l	#$BB10BB28,d4		;	eor.b	d5,(a0)	; eor.b	d5,x(a0)
	move.l	#$B510B528,d5		;	eor.b	d2,(a0)	; eor.b	d2,x(a0)
	move.l	#$01500168,d6		;	bchg	d0,(a0)	; eor.b	d2,x(a0)
	move.l	#$B118B128,a6		;	eor.b	d0,(a0)+	; eor.b	d0,1(a0)

	move.l	#$B110B128,a3		;	eor.b	d0,(a0) ; eor.b d0,2(a0)

	move.l	#$D0C9D24A,a1		;	add		a1,a0	;	add.w	a2,d1
	move.w	#$6404,a4			;	bcc.s	*+6
	move.l	#$41E8FF60,d0		;	add.w	#x,a0
	move.w	#\2,d0				;		x

	move.l	#lineloopsize-1,d7
	jsr		glR3
	endm

glR3
.loop
		move.l	a2,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+		
		move.w	a4,(a0)+
		move.l	d0,(a0)+		

		move.l	d1,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+		
		move.w	#1,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+		
		move.w	#2,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+

		move.l	a3,(a0)+				;	eor.b	d0,(a0) ; eor.b d0,x(a0)
		move.w	#2,(a0)+				;	#2
		move.w	#$5E48,(a0)+
		move.l	a1,(a0)+
		move.w	a4,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.loop
	rts

generateLines2	macro
	move.l	\1,a0
	move.l	#$BD10D24A,a2		;	eor.b	d6,(a0) ; add.w a2,a1
	move.l	#$BF10D24A,d1		;	eor.b	d7,(a0)	; add.w a2,d1
	move.l	#$B910D24A,d2		;	eor.b	d4,(a0) ; add.w a2,d1
	move.l	#$0550D24A,d3		;	bchg	d2,(a0)	; add.w a2,d1
	move.l	#$BB10D24A,d4		;	eor.b	d5,(a0)	; add.w a2,d1
	move.l	#$B510D24A,d5		;	eor.b	d2,(a0)	; add.w a2,d1
	move.l	#$0150D24A,d6		;	bchg	d0,(a0)	; add.w a2,d1
	move.l	#$B118D24A,a6		;	eor.b	d0,(a0)	; add.w a2,d1

	move.w	#$6404,a1			;	bcc.s	*+6
	move.l	#$41E8FF60,d0		;	add.w	#x,a0
	move.w	#\2,d0				;	
	move.l	#$B1105E48,a5		;	

	move.l	#lineloopsize-1,d7
	jsr		glR2
	endm

glR2
.loop
		move.l	a2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+
;;;;
		move.l	a2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

		move.l	a5,(a0)+
		move.w	d1,(a0)+
		move.w	a1,(a0)+
		move.l	d0,(a0)+

	dbra	d7,.loop
	rts


generateLines	macro
	move.l	\1,a0
	move.l	#$BD10D0C9,a2		;	eor.b	d6,(a0) ; add.w a1,a0
	move.l	#$BF10D0C9,d1		;	eor.b	d7,(a0)	; add.w a1,a0
	move.l	#$B910D0C9,d2		;	eor.b	d4,(a0) ; add.w	a1,a0
	move.l	#$0550D0C9,d3		;	bchg	d2,(a0)	; add.w	a1,a0
	move.l	#$BB10D0C9,d4		;	eor.b	d5,(a0)	; add.w	a1,a0
	move.l	#$B510D0C9,d5		;	eor.b	d2,(a0)	; add.w	a1,a0
	move.l	#$0150D0C9,d6		;	bchg	d0,(a0)	; add.w	a1,a0
	move.l	#$B118D0C9,a6		;	eor.b	d0,(a0)	; add.w	a1,a0

	move.l	#$D24A6404,a1		;	add.w	a2,d1	; bcc.s *+6
	move.l	#$41E8FF60,d0		;	add.w	#x,a0
	move.w	#\2,d0				;	x
	move.l	#$B1105E48,a5		;	

	move.l	#lineloopsize-1,d7
	jsr		glR

;		move.l	\1,a1
;		sub.l	a1,a0

	endm

glR
.loop
		move.l	a2,(a0)+			;		eor.b		d6,(a0)							;12		BD10				d0
									;		add.w		a1,a0							;8		D0C9	
		move.l	a1,(a0)+			;		add.w		a2,d1							;4		D24A 				a1
									;		bcc.s		*+6								;12		6404
		move.l	d0,(a0)+			;		add.w		#-160,a0						;8		41E8 FF60				a2


		move.l	d1,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	a6,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+
;;;;;
		move.l	a2,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d2,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d3,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d4,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d5,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

		move.l	d6,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+	

		move.l	a5,(a0)+
		move.w	d1,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)+

	dbra	d7,.loop
	rts

generateStuff

	generateLines	pointer_lines_with_add_neg,-160
	generateLines	pointer_lines_with_add,160,160
	generateLines2	pointer_lines_no_add_neg,-160
	generateLines2	pointer_lines_no_add_pos,160
	generateLines3	pointer_lines_with_add_neg_2lines,-160
	generateLines3	pointer_lines_with_add_2lines,160
	generateLines4	pointer_lines_no_add_neg_2lines,-160
	generateLines4	pointer_lines_no_add_pos_2lines,160

	generateMaskAndOffset	10
	generateSmcCode			pointer_10_12_neg,pointer_lines_no_add_neg,10,12
	generateSmcCode			pointer_10_12_pos,pointer_lines_no_add_pos,10,12

	generateMaskAndOffset	12
	generateSmcCode			pointer_12_14_neg,pointer_lines_with_add_neg,12,14
	generateSmcCode			pointer_12_14_pos,pointer_lines_with_add,12,14

	generateMaskAndOffset	14
	generateSmcCode			pointer_14_16_neg2,pointer_lines_no_add_neg_2lines,14,16
	generateSmcCode			pointer_14_16_pos2,pointer_lines_no_add_pos_2lines,14,16

	generateMaskAndOffset	16
	generateSmcCode			pointer_16_18_pos,pointer_lines_with_add_2lines,16,18
	generateSmcCode			pointer_16_18_neg,pointer_lines_with_add_neg_2lines,16,18
	rts


totalClear 	set 0
totalFill	set 0


generateClear	macro
	move.l	#$21400000+\1+\2*160,d2
	move.w	#200-2*\2-1,d7				
totalClear set totalClear+4*(200-2*\2)
	jsr		generateClearRout
	endm	

generateClearRout
	move.w	#160,d1
.loop
		move.l	d2,(a0)+
		add.w	d1,d2
	dbra	d7,.loop
	rts

generateFill	macro
	move.l	#$20280000+\1+\2*160,d2
	move.l	#$B1A80000+\1+\2*160+160,d3
totalFill set totalFill+8*(200-2*\2)
	move.w	#200-2*\2-1,d7
	jsr		generateFillRout
	endm

generateFillRout
	move.w	#160,d1
.loop
		move.l	d2,(a0)+
		move.l	d3,(a0)+
		add.w	d1,d2
		add.w	d1,d3
	dbra	d7,.loop
	rts


totalClear2 	set 0
totalFill2		set 0


generateClear2	macro
	move.l	#$21400000+\1+\2*160,d2
	move.w	#200-2*\2-1,d7				
totalClear2 set totalClear2+4*(200-2*\2)
	jsr		generateClearRout
	endm	


generateFill2	macro
	move.l	#$20280000+\1+\2*160,d2
	move.l	#$B1A80000+\1+\2*160+160,d3
totalFill2 set totalFill2+8*(200-2*\2)
	move.w	#200-2*\2-1,d7
	jsr		generateFillRout
	endm

qqq

generateClearCode
	IFNE debugfill
		moveq	#-1,d0
	ELSE
		moveq	#0,d0
	ENDC
	move.l	clearScreenPointer,a0

	generateClear	32,72			; done
	generateClear	40,40			; done
	generateClear	48,28			; done
	generateClear	56,20			; done
	generateClear	64,18			; done
	generateClear	72,12			; done
	generateClear	80,14
	generateClear	88,16
	generateClear	96,20			; done
	generateClear	104,30			; done
	generateClear	112,44			; done
	generateClear	120,82			; done
;	generateClear	128,80
	move.w	#$4e75,(a0)

	move.l	clearScreenPointer2,a0

	generateClear2	40,88			; done
	generateClear2	48,64			; done
	generateClear2	56,42			; done
	generateClear2	64,38
	generateClear2	72,32
	generateClear2	80,28
	generateClear2	88,28
	generateClear2	96,34
	generateClear2	104,56
	generateClear2	112,88
	move.w	#$4e75,(a0)
	rts


generateEorFillCode
	move.l	eorFillPointer,a0

	generateFill	32,72
	generateFill	40,40
	generateFill	48,28
	generateFill	56,20
	generateFill	64,18
	generateFill	72,12
	generateFill	80,14
	generateFill	88,16
	generateFill	96,20
	generateFill	104,30
	generateFill	112,44
	generateFill	120,82
;	generateFill	128,80
	move.w	#$4e75,(a0)


	move.l	eorFillPointer2,a0

	generateFill2	40,88
	generateFill2	48,64
	generateFill2	56,42
	generateFill2	64,38
	generateFill2	72,32
	generateFill2	80,28
	generateFill2	88,28
	generateFill2	96,34
	generateFill2	104,56
	generateFill2	112,88
	move.w	#$4e75,(a0)
	move.w	#totalFill+2,d2
	move.w	#totalFill2+2,d3
	rts

flipvar		dc.w	0
filvarold	dc.w	0
filcounter	dc.w	0
fillow		dc.w	-1
lowapp		dc.w	1

clearArea3
	IFNE debugfill
		moveq	#-1,d0
	ELSE
		moveq	#0,d0
	ENDC
	move.l	screenpointer2,a0
	add.w	cubeScreenOffset,a0

	move.w	flipvar,d0
	cmp.w	filvarold,d0
	beq		.x
		move.w	d0,filvarold
		move.w	filcounter,d1
		tst.w	lowapp
		bne		.xz
		eor.w	#-1,fillow

.xz
		move.w	#0,filcounter
		move.w	#0,lowapp

.x
;	move.w	d0,filvarold
	moveq	#0,d0

	move.w	previousSize,d2
	cmp.w	#$B8,d2
	ble		.smallClear

	move.w	#1,flipvar
	move.l	clearScreenPointer,a1
	jmp		(a1)
	rts

.smallClear
	move.w	#0,flipvar
	move.l	clearScreenPointer2,a1
	jmp		(a1)
	rts

eorFill3
	IFNE	rasters
	move.w	#$007,$ffff8240
	ENDC

	move.l	screenpointer2,a0
	add.w	cubeScreenOffset,a0

	lea		sizeTab,a1
	add.w	sizeCounter,a1
	move.w	(a1),d2
	cmp.w	#$B8,d2
	ble		.smallFill

	move.l	eorFillPointer,a1
	jmp		(a1)
.smallFill
	move.l	eorFillPointer2,a1
	jmp		(a1)


initCubeObject
	move.w	#8,number_of_vertices
	move.w	#current_number_polygons,number_of_polygons
	move.w	#171*4,vertices_xoff
	move.w	#100*4,vertices_yoff

	move.l cubeObjectPointer,a1

	lea		coordsource,a0
	move.l	logpointer,d6
	move.w	number_of_vertices,d7
	subq.l	#1,d7
	move.w	#$5000,d0						; base address of low memory

.loop
	REPT 3
		move.w	(a0)+,d6			;8
		add.w	d6,d6			;4
		move.l	d6,a2			;4
		move.w	(a2),d1			;8
		add.w	d0,d1			;4
		move.w	d1,(a1)+		;8		-> 36*3
	ENDR
	dbra	d7,.loop
	rts

initZTable
	move.l	zpointer,d0
	move.l	d0,a0

	moveq	#0,d1

	move.w	#255-1,d7

	move.l	#pers<<7,d3
	move.l	#pers,d5

	moveq	#-4,d6
	move.w	#-2,d0
	move.l	d0,a1

.loop
		move.l	d1,d4
		add.w	d5,d4		;8
		move.l	d3,d2		;12
		divs.w	d4,d2			;146
		add.w	d2,d2
		move.w	d2,(a0)+
		addq.w	#2,d1

		move.l	d6,d4
		add.w	d5,d4
		move.l	d3,d2
		divs.w	d4,d2
		add.w	d2,d2
		move.w	d2,(a1)

		sub.w	#2,a1
		subq.w	#2,d6

	dbra	d7,.loop
	rts

currentDivPointer	ds.l	1
savedDivD7			ds.l	1
divFrameCounter		dc.w	divsize*2-1

initDivTableFrame
	tst.w	divFrameCounter
	beq		.done
	move.l	currentDivPointer,a0
	move.l	savedDivD7,d7
	moveq	#0,d6
	moveq	#0,d5
	move.l	#128,d0
	move.w	#divsize*2,d2

; encoding: upper 8 bits is x
;			lower 8 bits is y
; offset is longword per item
.outerloop:
	moveq	#0,d6		; y
.innerloop:
	REPT 8
		move.l	d7,d5	; x																			;	4
		asl.l	#8,d5
		divu	d6,d5
		move.w	d5,d1
		clr.w	d5
		swap	d5
		asl.l	#8,d5
		divu	d6,d5
		swap	d1
		asr.l	#8,d1
		or.w	d5,d1
		swap	d1

		asl.w	#5,d1			;16
		move.w	d1,d3
		add.w	d1,d1
		add.w	d1,d1
		add.w	d3,d1			;---> 32 										; 177 vbl

		swap	d1
		move.l	d1,(a0)+

		;end actual calc
		addq	#1,d6	
	ENDR
																					;	4
		cmp		d0,d6																				;	8
		blt		.innerloop																			; ----> +12 ==> 426
	addq	#1,d7																					;	4
;	cmp		d2,d7																					;	8
;	blt		.outerloop																				; ---> 256*256*426 + 256*16 = 3.5sec precalc
	move.l	a0,currentDivPointer
	move.l	d7,savedDivD7
	subq.w	#1,divFrameCounter
.done

	rts

regelEdges:
	IFNE rasters
		move.w	#$700,$ffff8240
	ENDC

	lea		lineslist,a0
	moveq	#0,d0
.resetColors
o 	set 0
	REPT number_of_edges
		move.w	d0,o(a0)
o	set o+10
	ENDR

	lea		polyEdgesList2,a0						;12
	move.w	number_of_polygons,d7					;12
	subq.w	#1,d7
.checkAndSetPolyGon
	movem.l	(a0)+,a1-a4				; these are the pointers into the 2,4,4 structure	could be move.w		44 vs 28 --> 16 * 8 = 128

	move.l	(a3)+,a5															;12									8--> 4
	move.w	(a5)+,d4		
	move.w	(a5)+,d5
	move.l	(a1)+,a5															;12									8--> 4
	move.w	2(a5),a6
	move.w	d4,d6																;4
	sub.w	(a5),d6

	move.l	(a2)+,a5															;12									8-->
	sub.w	(a5)+,d4
	move.w	d5,d2				; save d5										;4
	sub.w	(a5)+,d5

	; z = (d1.x * d2.y) - (d1.y * d2.x)	
	muls	d5,d6				;d1.x * d2.y									;52		
	sub.w	a6,d2	; d1.y		;d1.y = v3.y - v1.y								;4
	muls	d4,d2				;d1.yllll * d2.x								;48	

	sub.l	d2,d6		; d7 = z			;6									;4
	lea		cube_colorValues,a5
	bgt		.visible															;12
;;;;;;;;;; notvisible
.notvisible
	addq.w	#2,d0																;4		
	cmp.w	#6,d0
	bne		.cont
		moveq	#0,d0
.cont
	dbra.w	d7,.checkAndSetPolyGon
	rts
;;;;;;;;;;; visible code
.visible
	addq.w	#2,d0
	cmp.w	#6,d0
	bne		.isnotzero
.iszero
		; is zero, means we color bpl 1
		moveq	#0,d0
		moveq	#%01,d1
		move.l	d6,0(a5)
		move.l	(a1),a1
		eor.w	d1,(a1)
		move.l	(a2),a2
		eor.w	d1,(a2)
		move.l	(a3),a3
		eor.w	d1,(a3)
		eor.w	d1,(a4)
	dbra	d7,.checkAndSetPolyGon
	rts

.isnotzero
	cmp.w	#2,d0
	bne		.isnottwo
.istwo
		moveq	#%10,d1
		move.l	d6,4(a5)
		move.l	(a1),a1
		eor.w	d1,(a1)
		move.l	(a2),a2
		eor.w	d1,(a2)
		move.l	(a3),a3
		eor.w	d1,(a3)
		eor.w	d1,(a4)
	dbra	d7,.checkAndSetPolyGon
	rts

.isnottwo
		moveq	#%11,d1
		move.l	d6,8(a5)
		move.l	(a1),a1
		eor.w	d1,(a1)
		move.l	(a2),a2
		eor.w	d1,(a2)
		move.l	(a3),a3
		eor.w	d1,(a3)
		eor.w	d1,(a4)
	dbra	d7,.checkAndSetPolyGon
	rts


drawLines:
	IFNE	rasters
		move.w	#$707,$ffff8240
	ENDC

	move.l	divtablepointer,a5								;12
	move.l	a5,usp									;4
	lea		lineslist,a5							;12

	move.l	y_block_pointer,d1
	move.l	d1,d3

	moveq	#%1000,d5				; 4 eor = 1000	8 bchg 
	moveq	#%100000,d4
	move.w	#%10000000,d6				; eor = 100000				; 111111
	moveq	#%1000000,d7
	swap	d7
	move.w	#number_of_edges-1,d7					; 
.doLine
	raster	#0
	; first word is used to determine if we need to draw
	move.w	(a5)+,d0		;2
	ble		.noDraw			;2						;+44
	; when we get here, its either 1,2,3
	; so we need to draw anyhow, so load the screen pointer
	move.l	screenpointer2,a0	
	add.w	cubeScreenOffset,a0
	raster #$707
				;
	subq.w	#2,d0			;2
	blt		.justDraw
	bgt		.drawTwo		;2			;+50 ; if result > 0 then its 3, draw two pixels
.drawOtherBitPlane	
	add.w	#2,a0			;2
.justDraw
	move.l	(a5)+,a6		;2		; next longword is first vertex pointer			;12				12									;8				12*4 = 48 saved
	move.w	(a6)+,d0		;2		; get x											;8				movem.w (a6,d0.w),d0-d1	28
	move.w	(a6),d1			;2		; get y											;8				swap	4
	move.l	(a5)+,a6		;2		; get 2nd vertex pointer						;12				movem.w	(a6,)						;8
	move.w	(a6)+,d2		;4												;20
	move.l	d1,d3
	move.w	(a6)+,d3		;4												;20
	swap	d7				;2
	lea		.ret1,a3
	jmp		drawLinePoly		;4
.ret1
	move.l	20(a3),(a4)			;2			;12
	swap	d7				;2
	dbra	d7,.doLine		;4
	rts						;2

	ds.l	20

.noDraw
	add.w	#8,a5			;2	; skip the line offset
	dbra	d7,.doLine		;4	;-48
	rts						;2


.drawTwo	; here
	move.l	(a5)+,a6		;2
	move.w	(a6)+,d0		;2
	move.w	(a6),d1			;2
	move.l	(a5)+,a6		;2
	move.w	(a6)+,d2		;4												;20
	move.l	d1,d3

	move.w	(a6)+,d3		;4												;20

	swap	d7				;2
	lea		.ret2,a3
	jmp		drawLinePoly2		;4
.ret2
	move.l	20(a3),(a4)+	;2				;12
	move.l	24(a3),(a4)		;4				;16

	swap	d7				;2
	dbra	d7,.doLine		;4
	rts						;2
	; some empty space to keep stuff
	ds.l	20

;	a0 is screenptr
;	a1 is divtable
;	a2 is fraction
;	a3 is y-offset
;	a4 is projectionptr
;	a5 is smc address
;	a6 is smc opcode

drawLinePoly
	cmp.w	d0,d2				; is d2 > d0 ?		;4			; determine left and right
	bge		.noswap									;12			; check if we need to swap
	exg		d0,d2									;8			; 	swap points
	exg		d1,d3									;8			; 
.noswap
	ext.l	d3										;4
	sub.w	d0,d2				; d2 is count (dx)	;4			; dx
	sub.w	d1,d3				; d3 is dy			;4			; dy
	bge		y_positive								;8	

;;;;;;;;;;;;;;;;;;;;; dy negative
y_negative
	neg		d3										;4			; dy is negative, make positive
	asl.l	#7,d3									;22			; shift for lookup
	or.w	d2,d3									;8			; dy/dx

	move.l	usp,a4									;4			; get divtable
	add.l	d3,a4									;8			; add offset dy/dx
	move.w	(a4)+,d3								;8			; get integer for division
	beq		no_add_y_negative									; if 0, then special case (opt)

.add_y_negative
	neg		d3										;4			; dy is positive but must be negative, thus....
	move.w	d3,a1									;8			; save dy integer
	move.w	(a4),a2									;8			; save dy decimal

	IFNE generateOffsetTables
mo12_1	lea		$123456789,a4
	ELSE
		lea		eor_mask_and_offset_12_12,a4		;8			; load offset table					; move.l	#$smcaddress,a4	;12
	ENDC
	add.w	d0,a4									;8			; add x offset for the table lookup

	and.w	#$3c,d0									;8			; 
	add.w	d0,d2									;4			; 

	move.l	(a4),d3									;12			; get offset for address
	move.l	d1,a4									;4
	add.w	(a4),d3									;8
	add.w	d3,a0				; screen+off		;8		
	swap	d3				; swap to mask			;4			-->48

	IFNE	generateOffsetTables
smc12_14_neg	lea		$123456789,a4
	ELSE
		lea 	y_negative_target_abs,a4			;8												; move.l	#$smcaddress,a4	;12
	ENDC
	move.l	(a4,d2.w),a4							;20
	move.l	(a4),20(a3)									;12			; move.l (a4),x(a3)					;16
	move.w	#$4ED3,(a4)								;12

	sub.w	d1,d1									;4
	moveq	#%1,d0									;4			; 1 eor = 01, 2 bchg = 10
	moveq	#%100,d2								;4			; 3 eor = 100, 5 bcgh = 10000


	move.l	pointer_lines_with_add_neg,a6
	add.w	d3,a6
	jmp		(a6)
;	jmp		lines_with_add_neg(PC,d3.w)				;16			; this can be rewritten to use a6
																;	move.l	#$smcaddress,a6			;12
																;	add.w	d3,a6					;8
																;	moveq	#%100,d3				;4		-> frees up d7, so no more swap d7 2 times (saves 4 cycles)
																;	jmp		(a6)					;8



y_positive
	asl.l	#7,d3									
	or.w	d2,d3

	move.l	usp,a4

	add.l	d3,a4		;8
	move.w	(a4)+,d3	;8

	beq		no_add_y_pos

	move.w	(a4),a2		;8
	move.w	d3,a1								;8
	IFNE generateOffsetTables
mo12_2	lea		$123456789,a4
	ELSE
		lea		eor_mask_and_offset_12_12,a4				;8		
	ENDC
	move.l	(a4,d0.w),d3		; eor/offset 16.16	;20		
	move.l	d1,a4			;4
	add.w	(a4),d3			;8
	add.w	d3,a0				; screen+off		;8		
	swap	d3				; swap to mask			;4			-->48

	and.w	#$3c,d0
	add.w	d0,d2
	IFNE	generateOffsetTables
smc12_14_pos		lea		$123456789,a4
	ELSE
		lea		y_positive_target_abs,a4					;8
	ENDC
	move.l	(a4,d2.w),a4
	move.l	(a4),20(a3)			; a6 is opcode		;12
	move.w	#$4ED3,(a4)	

	sub.w	d1,d1
	moveq	#%1,d0								;4		; 1 eor = 01, 2 bchg = 10
	moveq	#%100,d2							;4		; 3 eor = 100, 5 bcgh = 10000

	move.l	pointer_lines_with_add,a6
	add.w	d3,a6
	jmp		(a6)
;	jmp		lines_with_add(PC,d3.w)				;16



no_add_y_pos
	move.w	(a4),a2		;8
	; dx > dy

;	doLeftRightClipping	0,1

	IFNE generateOffsetTables
mo10_1	lea		$123456790,a4
	ELSE
		lea		eor_mask_and_offset_no_add,a4		;8
	ENDC
	move.l	(a4,d0.w),d3		; eor/offset 16.16	;20	

	move.l	d1,a4			;4
	add.w	(a4),d3			;8
	add.w	d3,a0				; screen+off		;8
	swap	d3				; swap to mask			;4
	and.w	#$3c,d0
	add.w	d0,d2


	IFNE	generateOffsetTables
smc10_12_pos		lea		$123456789,a4
	ELSE
		lea		targettable_noadd_pos,a4			;8
	ENDC
	
	move.l	(a4,d2.w),a4						;20
	move.l	(a4),20(a3)
	move.w	#$4ED3,(a4)	
	sub.w	d1,d1
	moveq	#%1,d0					; 1 eor = 01, 2 bchg 	= 10
	moveq	#%100,d2				; 3 eor = 100, 5 bcgh = 100000

	move.l	pointer_lines_no_add_pos,a6
	add.w	d3,a6
	jmp		(a6)


no_add_y_negative
	move.w	(a4),a2		;8
	IFNE 	generateOffsetTables
mo10_2	lea		$123456790,a4
	ELSE
		lea		eor_mask_and_offset_no_add,a4		;8
	ENDC
	move.l	(a4,d0.w),d3		; eor/offset 16.16	;20	
	move.l	d1,a4			;4
	add.w	(a4),d3			;8
	add.w	d3,a0				; screen+off		;8
	
	swap	d3				; swap to mask			;4

	and.w	#$3c,d0
	add.w	d0,d2
	IFNE	generateOffsetTables
smc10_12_neg		lea		$123456789,a4
	ELSE
		lea		targettable_noadd_neg,a4			;8
	ENDC
	move.l	(a4,d2.w),a4							;16
	move.l	(a4),20(a3)
	move.w	#$4ED3,(a4)	

	sub.w	d1,d1
	moveq	#%1,d0					; 1 eor = 01, 2 bchg 	= 10
	moveq	#%100,d2				; 3 eor = 100, 5 bcgh = 100000

	move.l	pointer_lines_no_add_neg,a6
	add.w	d3,a6
	jmp		(a6)
;	jmp		lines_no_add_neg(PC,d3.w)


drawLinePoly2
	cmp.w	d0,d2				; is d2 > d0 ?		;4
	bge		.noswap									;12
	exg		d0,d2									;8
	exg		d1,d3									;8
.noswap
	ext.l	d3
	sub.w	d0,d2				; d2 is count (dx)	;4
;	IFNE	hline_and_vline
;		beq		.vline
;	ENDC
	sub.w	d1,d3				; d3 is dy			;4
;	IFNE	hline_and_vline
;		beq		.hline
;	ENDC
	bge		y_positive_2lines							;8

y_negative_2lines
	neg		d3										;4	
	asl.l	#7,d3									;22
	or.w	d2,d3									;8

	move.l	usp,a4									;4
	add.l	d3,a4									;8
	move.w	(a4)+,d3								;8
	beq		no_add_y_negative_2lines

	neg		d3										;4

	move.w	(a4),a2									;8
	move.w	d3,a1									;8

	IFNE generateOffsetTables
mo16_1	lea		$123456790,a4
	ELSE
		lea		eor_mask_and_offset_2lines,a4		;8		
	ENDC
	move.l	(a4,d0.w),d3		; eor/offset 16.16	;20		
	move.l	d1,a4			;4
	add.w	(a4),d3			;8
	add.w	d3,a0				; screen+off		;8		
	swap	d3				; swap to mask			;4			-->48

	and.w	#$3c,d0
	add.w	d0,d2
	IFNE	generateOffsetTables
smc16_18_neg		lea		$123456789,a4
	ELSE
		lea 	y_negative_target_abs_2lines,a4			
	ENDC
	move.l	(a4,d2.w),a4
	move.l	(a4),20(a3)
	move.l	4(a4),24(a3)
	move.w	#$4ED3,(a4)	

	sub.w	d1,d1
	moveq	#%1,d0								;4		; 1 eor = 01, 2 bchg = 10
	moveq	#%100,d2							;4		; 3 eor = 100, 5 bcgh = 10000

	move.l	pointer_lines_with_add_neg_2lines,a6
	add.w	d3,a6
	jmp		(a6)
;	jmp		lines_with_add_neg_2lines(PC,d3.w)				;16


y_positive_2lines
	asl.l	#7,d3									
	or.w	d2,d3

	move.l	usp,a4

	add.l	d3,a4		;8
	move.w	(a4)+,d3	;8

	beq		no_add_y_pos_2lines

	move.w	(a4),a2		;8
	move.w	d3,a1								;8

;	doLeftRightClipping	1,1	;add, positive
	IFNE generateOffsetTables
mo16_2	lea		$123456790,a4
	ELSE
		lea		eor_mask_and_offset_2lines,a4				;8		
	ENDC
	move.l	(a4,d0.w),d3		; eor/offset 16.16	;20		
	move.l	d1,a4			;4
	add.w	(a4),d3			;8
	add.w	d3,a0				; screen+off		;8		
	swap	d3				; swap to mask			;4			-->48

	and.w	#$3c,d0
	add.w	d0,d2
	IFNE	generateOffsetTables
smc16_18_pos		lea		$123456789,a4
	ELSE
		lea		y_positive_target_abs_2lines,a4					;8
	ENDC
	move.l	(a4,d2.w),a4
	move.l	(a4),20(a3)			; a6 is opcode		;12
	move.l	4(a4),24(a3)						;28
	move.w	#$4ED3,(a4)	

	sub.w	d1,d1
	moveq	#%1,d0								;4		; 1 eor = 01, 2 bchg = 10
	moveq	#%100,d2							;4		; 3 eor = 100, 5 bcgh = 10000

	move.l	pointer_lines_with_add_2lines,a6
	add.w	d3,a6
	jmp		(a6)
;	jmp		lines_with_add_2lines(PC,d3.w)				;16


no_add_y_pos_2lines
	move.w	(a4),a2		;8

;	doLeftRightClipping	0,1	;no add, positive
	; dx > dy
	IFNE generateOffsetTables
mo14_1	lea		$123456790,a4
	ELSE
		lea		eor_mask_and_offset_no_add_2lines,a4		;8
	ENDC
	move.l	(a4,d0.w),d3		; eor/offset 16.16	;20	

	move.l	d1,a4			;4
	add.w	(a4),d3			;8
	add.w	d3,a0				; screen+off		;8
	
	swap	d3				; swap to mask			;4

	and.w	#$3c,d0
	add.w	d0,d2
	IFNE	generateOffsetTables
smc14_16_pos		lea		$123456789,a4
	ELSE
		lea		targettable_noadd_pos_2lines,a4		;8
	ENDC
	move.l	(a4,d2.w),a4						;20
	move.l	(a4),20(a3)
	move.l	4(a4),24(a3)
	move.w	#$4ED3,(a4)	

	sub.w	d1,d1
	moveq	#%1,d0					; 1 eor = 01, 2 bchg 	= 10
	moveq	#%100,d2				; 3 eor = 100, 5 bcgh = 100000

	move.l	pointer_lines_no_add_pos_2lines,a6
	add.w	d3,a6
	jmp		(a6)
;	jmp		lines_no_add_pos_2lines(pc,d3.w)			;16


no_add_y_negative_2lines
	move.w	(a4),a2		;8
	IFNE generateOffsetTables
mo14_2	lea		$123456790,a4
	ELSE
		lea		eor_mask_and_offset_no_add_2lines,a4		;8
	ENDC
	move.l	(a4,d0.w),d3		; eor/offset 16.16	;20	
	move.l	d1,a4									;4
	add.w	(a4),d3									;8
	add.w	d3,a0				; screen+off		;8
	
	swap	d3				; swap to mask			;4

	and.w	#$3c,d0
	add.w	d0,d2
	IFNE	generateOffsetTables
smc14_16_neg		lea	$123456789,a4
	ELSE
		lea		targettable_noadd_neg_2lines,a4		;8
	ENDC
	move.l	(a4,d2.w),a4					;16
	move.l	(a4),20(a3)
	move.l	4(a4),24(a3)
	move.w	#$4ED3,(a4)	

	sub.w	d1,d1
	moveq	#%1,d0					; 1 eor = 01, 2 bchg 	= 10
	moveq	#%100,d2				; 3 eor = 100, 5 bcgh = 100000

	move.l	pointer_lines_no_add_neg_2lines,a6
	add.w	d3,a6
	jmp		(a6)
;	jmp		lines_no_add_neg_2lines(PC,d3.w)
	

sinBsinC	dc.w	0
cosAcosC	dc.l	0
sinAcosC	dc.l	0


advanceRotationPoly
	raster	#$005
    move.w  #256*2*2,d7									;8
; do angular speeds and get indices 
    move.w  currentStepX,d2								;16
    add.w   stepSpeedX,d2								;16
    cmp.w   d7,d2										;4
    blt     .goodX										;12
        sub.w   d7,d2									;4
.goodX
    move.w  d2,currentStepX								;16		--> 68

    move.w  currentStepY,d4								;16
    add.w   stepSpeedY,d4								;16
    cmp.w   d7,d4										;4
    blt     .goodY										;12
        sub.w   d7,d4									;4
.goodY
    move.w  d4,currentStepY								;16		--> 68

    move.w  currentStepZ,d6								;16
    add.w   stepSpeedZ,d6								;16
    cmp.w   d7,d6										;4
    blt     .goodZ										;12
        sub.w   d7,d6									;4
.goodZ
    move.w  d6,currentStepZ								;16		--> 68
    rts

_currentStepX	ds.w	1
_currentStepY	ds.w	1
_currentStepZ	ds.w	1
_stepSpeedX		ds.w	1
_stepSpeedY		ds.w	1
_stepSpeedZ		ds.w	1

doRotationPoly

    move.w	currentStepX,d2
    move.w	currentStepY,d4
    move.w	currentStepZ,d6

;;;;;;;;;;;;;;;;;; ANGULAR SPEEDS DONE ;;;;;;;;;;;;;;;;;;

.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		sintable,a0								;12
	lea		sintable+256,a1							;12

	move.w	(a0,d2.w),d1					; sin(A)	;around z axis		16
	move.w	(a1,d2.w),d2					; cos(A)						16

	move.w	(a0,d4.w),d3					; sin(B)	;around y axis		16
	move.w	(a1,d4.w),d4					; cos(B)						16

	move.w	(a0,d6.w),d5					; sin(C)	;around x axis		16
	move.w	(a1,d6.w),d6					; cos(C)						16

	; xx = cos(A) * cos(B)
.xx
	move.w	d2,d7						;						4
	muls	d4,d7						;						42				1
	asr.w	#7,d7						;xx,zz					24	
	move.w	d7,a2						;						18
															; ------> 88
	;xy = [sin(A)cos(B)]		
.xy
	move.w	d4,d7						;						4
	muls	d1,d7						;						42				2
	asr.w	#7,d7						;						24
	move.w	d7,a1						;						4
															; ------> 74
	;xz = [sin(B)]	sB
.xz
	move.w	d3,a0						;						4
															; ------> 4
	;yx = [sin(A)cos(C) + cos(A)sin(B)sin(C)]
.yx
    move.w	d6,d0											;	4
    muls	d1,d0	; d0 = sin(A) * cos(C)						44	
    IFNE z_on	
	    move.l	d0,sinAcosC
    ENDC
;    move.w	d2,d7				; cos A						;	4
    ; d3 = sin B
    ; d5 = sin C
    move.w	d5,d7
    muls	d3,d7	; d7 = sin(B) * sin(C)					;	44
    asr.l	#7,d7											;	24
    move.w	d7,sinBsinC										;	16
    muls	d2,d7	; d7 = cos(A) * sin(B) * sin(C)			;	44
	add.l	d7,d0											;	10
	asr.l	#7,d0											;	22
	move.w	d0,a3											;	4




	;yy = [-cos(A)cos(C) + sin(A)sin(B)sin(C)]
.yy
	move.w	d2,d7	; d7 = cos(A)							;	4
	muls	d6,d7	; d7 = -cos(A) * cos(C)					;	44
	move.l	d7,cosAcosC
	neg.l	d7		; d7 = -cos(A)							;	4
	move.w	sinBsinC,d0	; sin(B)*sin(C)						;	12
	muls	d1,d0											;	44
	add.l	d0,d7		;										8
	asr.l	#7,d7		;										24
	move.w	d7,a4		;										4
															;---------> 204
	;yz = [-cos(B)sin(C)]
.yz
	move.w	d4,d7											;	4
	neg		d7												;	4
	muls	d5,d7											;	44
	asr.w	#7,d7											;	24
	move.w	d7,a6											;	4
															; ------> 80
															;--------------------> 100 + 156 + 88 + 74 + 4 + 200 + 204 + 80 = 906
	IFNE z_on
	;zx = [sin(A)sin(C) - cos(A)sin(B)cos(C)]
.zx
		move.w	d1,d0	; d0 = sin(A)
		muls	d5,d0	; d0 = sin(A) * sin(C)
		move.l	cosAcosC,d7		; d7 = cosA*cosC
		asr.l	#7,d7
		muls	d3,d7
		sub.l	d7,d0	; d0 = sin(A) * sin(C) - cos(A) * sin(B) * cos(C)
		asr.l	#7,d0	;
		move.w	d0,d7
;
;	;zy = [-cos(A)sin(C) - sin(A)sin(B)cos(C)]
.zy
		move.w	d2,d0	; d0 = cos(A)
		muls	d5,d0	; d0 = cos(A) * sin(C)
		neg.l	d0		; d0 = -cos(A) * sin(C)

		move.l	sinAcosC,d1
		asr.l	#7,d1
		muls	d3,d1

		sub.l	d1,d0	; d0 = -cos(A) * sin(C) - sin(A) * sin(B) * cos(C)
		asr.l	#7,d0	;
		move.w	d0,d3

;	zz = [cos(B)cos(C)]
.zz
		move.w	d4,d0	; d0 = cos(B)
		muls	d6,d0 	; d0 = cos(B) * cos(C)
		asr.w	#7,d0
		move.w	d0,d4
	ENDC

;;;;;;;;;;;;;;;;;; CONSTANTS DONE ;;;;;;;;;;;;;;;;;;
.setupComplete						

	move.l	logpointer,d0		;20

	move.w	a2,d0 ;xx			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xxp+2

	move.w	a0,d0	;xz			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xzp+2

	move.w	a1,d0	;xy			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xyp+2

	move.w	a3,d0	;yx			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),yxp+2

	move.w	a4,d0	;yy			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),yyp+2

	move.w	a6,d0				;4
	add.w	d0,d0	;yz			;4
	move.l	d0,a5				;4
	move.w	(a5),yzp+2

	IFNE	z_on
		move.w	d7,d0	;zx
		add.w	d0,d0
		move.l	d0,a5
		move.w	(a5),zxp+2

		move.w	d3,d0	;zy
		add.w	d0,d0
		move.l	d0,a5
		move.w	(a5),zyp+2

		move.w	d4,d0	;zz
		add.w	d0,d0
		move.l	d0,a5
		move.w	(a5),zzp+2
	ENDC

	move.l	cubeObjectPointer,a5					; 20	

	lea		projectedPolySource,a6						
	move.w	number_of_vertices,d5				; 20
	subq	#1,d5								; 4

	move.l	zpointer,d1
	move.l	expointernorm,d2
	move.l	d2,d3

	move.w	vertices_xoff,d6
	move.w	vertices_yoff,d7
	; vertices x,y
	; d6,d7

loop111
	IFNE z_on


	movem.w	(a5)+,a0-a2		;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
	;	z
zxp	move.w		1234(a0),d1	;12			; z*zx ... +
zyp	add.w		1234(a1),d1	;12			; z*zy ... +
zzp	add.w		1234(a2),d1	;12			; z*zz
	move.l		d1,a3		;4			; perspective value pointer
	move.w		(a3),d2		;8			; perspective value as log value
	move.w		d2,d3		;4			; duplicate				(52)

	;	x	
xxp	move.w		1234(a0),d0	;12			; x*xx ... +
xyp	add.w		1234(a1),d0	;12			; x*xy ... +
xzp	add.w		1234(a2),d0	;12			; x*xz 
	move.l		d0,a3		;4			; logpointer
	add.w		(a3),d2		;8			; add to focal length ( x * perspective )
	move.l		d2,a3		;4			; use exptable pointer
;	move.w		(a3),(a6)+	;12			; get/store actual x value (64)		; move.w	(a3),d5			;8
																			; add.w		d5,d5			;4
																			; add.w		d5,d5			;4
																			; add.w		d1,d5			;4
																			; move.w	d5,(a6)+		;8	=> + 16
	move.w		(a3),d4
	add.w		d4,d4
	add.w		d4,d4
	add.w		d6,d4
	move.w		d4,(a6)+

	;	y
yxp	move.w		1234(a0),d0	;12			; z*zx ... +
yyp	add.w		1234(a1),d0	;12			; z*zy ... +
yzp	add.w		1234(a2),d0	;12			; z*zz
	move.l		d0,a3		;4			; logpointer
	add.w		(a3),d3		;8			; add to local length ( y * perspective )
	move.l		d3,a3		;4			; use exptable pointer
;	move.w		(a3),(a6)+	;12			; get/store actual y value (64)
	move.w		(a3),d4
	add.w		d4,d4
	add.w		d4,d4
	add.w		d7,d4
	move.w		d4,(a6)+

	dbra	d5,loop111		;12			; 24 + 12 + 52 + 64 + 64 = 216
	rts

	ELSE
	movem.w	(a5)+,a0-a2	;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
	;	x	
xxp	move.w		1234(a0),d0	;12				xx is offset into table for the value, smc
xyp	add.w		1234(a1),d0	;12				xy is offset into table for the value, smc
xzp	add.w		1234(a2),d0	;12				xz is offset into table for the value, smc
	move.w		d0,(a6)+

	;	y
yxp	move.w		1234(a0),d0	;12
yyp	add.w		1234(a1),d0	;12
yzp	add.w		1234(a2),d0	;12
	move.w		d0,(a6)+

	dbra	d5,loop111
	rts

zxp	move.w		1234(a0),d0	;12
zyp	add.w		1234(a1),d0	;12
zzp	add.w		1234(a2),d0	;12
	ENDC

; explosion part
; explosion part
; explosion part



prepareExplosion
	tst.w	_prepexplodone
	beq		.donedd
    jsr     assign_flightpaths
    jsr     generate_splist
    jsr     prep_dellists
    add.l   #40960,sprite_data_offset_for_greetings
    move.w	#0,_prepexplodone
.donedd
    rts



prepareExplosionWithoutTest
    jsr     assign_flightpaths
    jsr     generate_splist
    jsr     prep_dellists
    add.l   #40960,sprite_data_offset_for_greetings
    rts


_prepexplodone	dc.w	-1

generate_splist:
;	lea     sprite_startpos,A0
	move.l	sprite_startpos_pointer,a0
;    lea     active_sprite_list,A1
    move.l	active_sprite_list_pointer,a1

    move.w  #greetings_number_of_sprites+30,D7 ; counter: no. sprite list entries
.ol
		move.l  (A0)+,(A1)+     ; xpos/ypos
    	move.w  (A0)+,(A1)+     ; flightpath
    dbra    D7,.ol

    ; 80 * 6 = 480
o set 0
    REPT 9
    	movem.l	(a0)+,d0-d7/a2-a6			; 8 + 5 = 13, 13*4 = 52 ;; --> 9 times
    	movem.l	d0-d7/a2-a6,o(a1)
o set o+52
    ENDR
    movem.l	(a0)+,d0-d2
    movem.l	d0-d2,o(a1)

    move.l  (A0),next_active_sprite ; pointer to next moving sprite
    rts

next_active_sprite	dc.l	0
explosion_done	dc.w	0

prep_dellists:  
    lea     delete_list1,A2
    move.l  a2,dellist_adr1
    lea     delete_list2,A3
    move.l  a3,dellist_adr2

    move.l  #0,a0


    move.w  #greetings_number_of_sprites-5,D7
.il   
       move.l  a0,(a2)+
       move.l  a0,(a3)+
    dbra    D7,.il
;    move.w  #greetings_number_of_sprites+1,D5         ; load number of sprites
    rts

swap_killbuffers:
    move.l  dellist_adr2,D7 ; exchange killbuffers
    move.l  dellist_adr1,dellist_adr2
    move.l  D7,dellist_adr1
    rts

greetingsClearSprites
    move.l  screenpointer2,d0
    movea.l dellist_adr2,A5
    moveq   #0,D6
    move.l  clearSpritesCodePointer,a1
    jmp     (a1)



initExplosionStuff
    tst.w   _explosionDone
    beq     .done
    jsr     encode_xpos
    jsr     generateClearSpritesCode
    jsr     generateShowSpriteCode
    jsr     generate_sprites
    jsr     generate_flpaths
    move.w  #0,_explosionDone
.done
    rts
_explosionDone  dc.w    1

encode_xpos:    
    move.l  xpos_splitted_pointer,a0
    moveq   #0,D0           ; word offset
encode_start:   
	moveq   #16-1,D7        ; counter: 16 preshift steps
    moveq   #0,D1           ; preshift offset
encode_xpos_loop:
        move.w 	D1,D2           ; copy preshift offset to dest register
        swap    D2              ; point to lower word of dest register
        move.w  D0,D2           ; copy word offset to dest register
        move.l  D2,(A0)+        ; store dest register

        add.w   #32,D1          ; load next preshift offset (lwordaligned)
        dbra    D7,encode_xpos_loop
    add.w   #8,D0           ; load next word offset
    cmpi.b  #240,D0         ; end of the line?
    bne.s   encode_start
    rts

generateClearSpritesCode
    move.l  clearSpritesCodePointer,a0
    move.l	a0,a1

;    lea		clearSpritesCode,a2

    move.l  #$301D2040,d0      ; move.w        (a5)+,d0
    move.l  #$31460000,d6      ; move.w        d6,0(a0)
    move.w  #8,d4            ; offset
    move.w  #152,d3
    move.w  #greetings_offset,d5
    move.l  #greetings_number_of_sprites+5,d7
.il
        move.w  d5,d6
        move.l  d0,(a0)+
        REPT greetings_blockheight
            move.l  d6,(a0)+                                ; (( 8 * 4 ) + 4 ) ==> 36 * (number_of_sprites+1)
            add.w   d4,d6
            move.l  d6,(a0)+
            add.w   d3,d6
        ENDR
    dbra    d7,.il
    move.w  #$4e75,(a0)+

    rts

greetingsShowSprites
;    move.b	#0,$ffffc123
    move.l  screenpointer2,a0

    move.l  sprite_data_pointer,a1
    move.l	sprite_data_offset_for_greetings,d0
    add.l	d0,a1

    move.l	active_sprite_list_pointer,a2
;    lea     active_sprite_list,A2 ; data of sprites to move
    move.l  xpos_splitted_pointer,d0

    move.w   #199*160,d2     ; ypos>199?
    move.l  dellist_adr2,a5
    move.l  A0,d1           ; move scr_adr to data register
    move.w  #512,D4         ; load D4 with preshift table offset to next sprite
    moveq   #0,D5           ; clear sprite counter


    move.l  showSpriteCodePointer,a3
    jmp     (a3)

    rts

showSpriteTemplate
    move.w (a2)+,d0 ; current x
    move.w (a2)+,d1 ; current y
    move.w (a2)+,a4  ;velocity pointer
    cmp.w   d2,d1     ; ypos>199
    bhi     end_draw       ; then don't show this sprite

    add.w   (a4)+,d0        ; add velocity x
    add.w   (a4)+,d1        ; add velocity y
 ;   addq.w  #4,a4
 ;   nop
    movem.w d0/d1/a4,-6(a2) ; save shit

    move.l  d0,a3           ; 
    move.l  a1,a6
    add.w   (a3)+,a6
    add.w   (a3)+,d1        ;8
    move.w  d1,(a5)+
    move.l  d1,a0           ;4
o   SET greetings_offset
    REPT greetings_blockheight          ;       ; 8 lines
        move.w  (A6)+,D0        ; load 1st word
        or.w    D0,o(A0)        ; show 1st word on screen
        move.w  (A6)+,D0        ; load 2nd word
        or.w    D0,o+8(A0)      ; show 2nd word on screen
o   SET o+160
    ENDR
    addq.w  #1,D5           ; sprite counter: how many sprites on screen?
end_draw
    adda.w  D4,A1           ; preshift table offset to next sprite
templateEnd                             ; 130 --> 32 * 4 + 2

generateShowSpriteCode
    movea.l showSpriteCodePointer,a0
    move.l	a0,a6
    lea     showSpriteTemplate,a2
    move.l  #greetings_number_of_sprites-1,d7
.ol
    	move.l  a2,a1
    	REPT 33
    		move.l  (a1)+,(a0)+
	    ENDR
;	    move.w  (a1)+,(a0)+
    dbra    d7,.ol
    move.w  #$4e75,(a0)+    ;rts

    rts

generate_sprites:
;	lea     sprite_startpos,A0
	move.l	sprite_startpos_pointer,a0
	move.w   #90*160,D1          ; y-start = 50
	moveq   #greetings_sprites_height-1,D7        ; counter: no. of sprites in y-direction
get_sprite_y:   
		move.w   #160*2,D0            
		moveq   #greetings_sprites_width-1,D6        ; counter: no. of sprites in x-direction
get_sprite_x:   
			move.w  d0,(A0)+        ; save sprite position
			move.w  d1,(a0)+
			move.w  #0,(A0)+        ; leave space for flightpath address
			addq.w  #1,no_of_sprites
			add.w  #8*4,D0           ; point to next x-position
		dbra    D6,get_sprite_x
		add.w  #8*160,D1           ; point to next y-start
	dbra    D7,get_sprite_y

	rts

preshift_sprite:
    tst.w   _preshiftdone
    beq     .done
    lea     greetings_source_pic,A0 ; sp1,l1...sp1,l8...sp2,l1...
    add.l   #1600,a0
    move.l  sprite_data_pointer,a1

goff set 0
    REPT number_of_greetings
        lea     greetings_source_pic,A0 ; sp1,l1...sp1,l8...sp2,l1...
        add.l   #1600*goff,a0
        moveq   #0,D0
        moveq   #0,D1
        jsr     doPreshift
goff set goff+1
    ENDR
    move.w	#0,_preshiftdone
.done
    rts
_preshiftdone   dc.w    1


doPreshift
    move.w  #greetings_number_of_sprites-1,d7
.spriteStart
    move.l  a1,a2                           ; yes I will copy from this when done, from start, so it will be iteration-1
    moveq	#0,d2
.spriteSpecialCase                          ; from source to target step
    REPT 8
        move.b  (a0)+,(a1)+
        move.b	d2,(a1)+
        move.w	d2,(a1)+
    ENDR

    moveq   #15-1,d6                        ; 15 times the single ror
.other15steps
 ;   REPT 8                         ;15 times 8 = 120
 ;   	move.l	(a2)+,d0
 ;   	ror.l	#1,d0
 ;   	move.l	d0,(a1)+
 ;   ENDR
        movem.l  (a2)+,d0-d5                    ; get longword from previous step
        ror.l   #1,d0                       ; move one to right
        ror.l   #1,d1                       ; move one to right
        ror.l   #1,d2                       ; move one to right
        ror.l   #1,d3                       ; move one to right
        ror.l   #1,d4                       ; move one to right
        ror.l   #1,d5                       ; move one to right
        movem.l  d0-d5,(a1)                    ; store
        add.w   #6*4,a1
        move.l  (a2)+,d0
        ror.l   #1,d0
        move.l  d0,(a1)+
        move.l  (a2)+,d0
        ror.l   #1,d0
        move.l  d0,(a1)+
    dbra    d6,.other15steps

    dbra    d7,.spriteStart

    rts


generate_flpaths:
                lea     $1000.w,A0      ; area to store the flightpaths
                lea     flightpath_adr,A1 ; table of flightpass addresses in lowmem
;                                       ; A2 = movement on x-axis
;                                       ; A3 = movement on y-axis
                moveq   #0,D0
                moveq   #0,D1

                moveq   #8-1,D7         ; counter: number of precalc flightpaths
calc_flightpath:jsr	   	random_flpath   ; get random x- and y-flightpaths
                move.w  A0,(A1)+        ; save startadr of current flightpath

cont_flightpath:move.b  (A3)+,D0        ; load y-data in flightpath dest register
                ext.w   D0              ; prepare for signed multiplication
                muls    #160,D0         ; get y offset

                swap    D0              ; load y offset it upper word
                clr.w   D0              ; erase sign/unsigned $FF's in .w

                move.b  (A2)+,D0        ; load x-data in flightpath dest register

                ext.w   D0              ; extend in case of negative x-offsets

                add.w   d0,d0
                add.w   d0,d0

                swap    D0              ; .w: y-offset

                move.l  D0,(A0)+        ; store flightpath dest register

                tst.b   (A3)            ; end of y-data-table? ("0")
                bne.s   cont_flightpath ; if not, calc next flpath entry

                dbra    D7,calc_flightpath

                rts

; *** random assignment of x and y flightpaths ********************************

random_flpath:  lea     flightpath_x_tables,A2
                lea     flightpath_y_tables,A3

random_x_flpath:move.w  current_x_flpath,D0 ; every of the 8 x-flightpaths
                addq.w  #4,current_x_flpath ; gets assigned once

                movea.l 0(A2,D0.w),A2   ; point to x-flightpath data

                jsr	    unroll_x_flpath ; increase 8 entry x-flightpath
                lea     unrolled_x_flpath,A2 ; point to unrolled x-flightpath

random_y_flpath:
                move.l  #$12345678,D0   ; generate random number
                addq.l  #5,D0
                rol.l   D0,D0
                add.b   $FFFF8209.w,D0
                add.b   $FFFF8209.w,D0
                move.l  D0,random_y_flpath+2

                and.l   #%11,D0         ; chose 1 of 4 (0...3)

                add.w   D0,D0           ; adjust to longwordsize
                add.w   D0,D0

                movea.l 0(A3,D0.w),A3   ; point to y-flightpath data

                rts

; *** unroll the 8-values-x-flightpath to "a lot"-values-x-flightpath *********

unroll_x_flpath:movem.l D6-D7/A2-A4,-(SP)

                lea     unrolled_x_flpath,A4

                movea.l A2,A3

                moveq   #9-1,D6
unroll_x_outloop:
                moveq   #8-1,D7         ; 8 values of the x-flightpath
unroll_x_inloop:move.b  (A2)+,D0        ; get x-value
                move.b  D0,(A4)+        ; store x-value

                dbra    D7,unroll_x_inloop

                movea.l A3,A2           ; restore pointer to start of table

                dbra    D6,unroll_x_outloop

                movem.l (SP)+,D6-D7/A2-A4

                rts

current_x_flpath:DS.W 1
unrolled_x_flpath:DS.W 10*10
flightpath_adr: DS.W 10       ; place to store the flightpath addresses

flightpath_x_tables:

                DC.L flightpath_x1
                DC.L flightpath_x2
                DC.L flightpath_x3
                DC.L flightpath_x4
                DC.L flightpath_x5
                DC.L flightpath_x6
                DC.L flightpath_x7
                DC.L flightpath_x8

flightpath_y_tables:

                DC.L flightpath_y1
                DC.L flightpath_y2
                DC.L flightpath_y3
                DC.L flightpath_y4

flightpath_x1:  DC.B -2,-2,-2,-3,-2,-2,-2,-2
                EVEN
flightpath_x2:  DC.B -2,-1,-2,-1,-2,-1,-2,-1
                EVEN
flightpath_x3:  DC.B -1,-1,-1,-1,-1,-1,-1,-1
                EVEN
flightpath_x4:  DC.B 0,0,0,0,0,0,0,0
                EVEN
flightpath_x5:  DC.B 1,1,1,1,1,1,1,1 ; x+1 = y+1
                EVEN
flightpath_x6:  DC.B 2,1,2,1,2,1,2,1
                EVEN
flightpath_x7:  DC.B 2,2,2,2,2,2,2,2
                EVEN
flightpath_x8:  DC.B 3,2,3,4,3,2,3,2
                EVEN


flightpath_y1:  DC.B -2,-3,-4,-1,2,2,3,3
                DC.B 3,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,8,6,8,8,8,8
                DC.B 8,8,8,8,8,8,9,9,9,9,9,9,9,9,9

                DC.B 0
                EVEN
flightpath_y2:  dc.b -1,-2,-3,-4,-2,-1,1,2,2,2
;				DC.B -2,-3,-4,-4,-6,-4,-4,-3,-2
                DC.B 2,2,2,3,3,3,4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,8,8,9,9,9
                DC.B 9,8,8,8,8,8,9,9,9,9,9,9,9,9,4,4,4,4,4

                DC.B 0
                EVEN

flightpath_y3:  DC.B -3,-6,-4,-1,2,2,3,4,5
                DC.B 5,5,5,5,6,6,6,6,6,7,7,7,7,7,7,8,8
                DC.B 8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9

                DC.B 0
                EVEN


flightpath_y4:  DC.B -1,-2,-1,1,1,1,2,2,2,2,2
                DC.B 2,2,2,3,3,3,4,4,4,4,4,5,5,5,5,6,6,6,6,6,7,7,7,7,7,7
                DC.B 8,8,8,8,8,8,9,9,9,9,9,9,9,9

                DC.B 0
                EVEN


assign_flightpaths:

                lea     flightpath_adr,A0
;                lea     sprite_startpos,A1
				move.l	sprite_startpos_pointer,a1

                addq.l  #4,A1           ; point the 3rd word (free data slot)

                move.w  #greetings_number_of_sprites+5,D7 ; counter: number of sprites
                lea     $FFFF8209.w,a2   
                move.l  #%1110,d6     
generate_random:
random:         move.l  #$12345678,D0   ; generate random number
                addq.l  #5,D0
                rol.l   D0,D0
                add.b   (a2),D0
                add.b   (a2),D0
                move.l  D0,random+2

                and.l   d6,D0        ; chose 1 of 8

                move.w  0(A0,D0.w),D1   ; get address of flightpath
                move.w  D1,(A1)         ; store in sprite parameters

                addq.l  #6,A1           ; adjust to next offset data slot

                dbra    D7,generate_random

                rts




;;;;;;;;;;;;;; GREETINGS END ;;;;;;;;;;;
;;;;;;;;;;;;;; GREETINGS END ;;;;;;;;;;;
;;;;;;;;;;;;;; GREETINGS END ;;;;;;;;;;;


;;;;;;;;;;;;;; C2P START ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; C2P START ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; C2P START ;;;;;;;;;;;;;;;
VIEWPORT_Y	equ	99
VIEWPORT_X	equ 20
SOURCE_Y	equ 256
SOURCE_X	equ	256


overlaywidth	equ 6

doadd		equ 1
dosub		equ 1
_fadedone	dc.w	1
powerpaloffset
	dc.w	0
powerpal1	
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-7
;	dc.w	$000,$000,$000,$000,$000,$100,$100,$110,$111,$100,$100,$100,$000,$000,$000,$000	;	-6
;	dc.w	$000,$000,$000,$000,$100,$200,$210,$220,$222,$210,$200,$100,$000,$000,$000,$000	;	-5
;	dc.w	$000,$000,$000,$000,$100,$310,$320,$330,$333,$320,$310,$200,$100,$000,$000,$000	;	-4
;	dc.w	$000,$000,$000,$100,$210,$421,$430,$441,$444,$431,$420,$310,$210,$110,$100,$000	;	-3
;	dc.w	$000,$000,$101,$200,$311,$531,$541,$551,$555,$541,$530,$420,$310,$210,$200,$100	;	-2
;	dc.w	$000,$100,$201,$311,$421,$542,$652,$661,$666,$652,$640,$530,$420,$310,$300,$200	;	-1
	
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777 ;   -7
	dc.w	$666,$666,$666,$666,$666,$666,$766,$776,$777,$766,$766,$666,$666,$666,$666,$666 ;   -6
	dc.w	$555,$555,$555,$555,$555,$655,$765,$775,$777,$765,$755,$655,$555,$555,$555,$555 ;   -5
	dc.w	$444,$444,$444,$444,$544,$654,$764,$774,$777,$764,$754,$644,$544,$444,$444,$444 ;   -4
	dc.w	$333,$333,$333,$433,$533,$653,$763,$773,$777,$763,$753,$643,$533,$433,$433,$333 ;   -3
	dc.w	$222,$222,$322,$422,$532,$653,$763,$772,$777,$763,$752,$642,$532,$422,$422,$322 ;   -2
	dc.w	$111,$211,$312,$422,$532,$653,$763,$772,$777,$763,$751,$641,$531,$421,$411,$311 ;   -1

	dc.w	$000,$201,$312,$422,$532,$653,$763,$771,$777,$763,$750,$640,$530,$420,$411,$301	;	total	
	dc.w	$000,$201,$312,$422,$532,$653,$763,$771,$777,$763,$750,$640,$530,$420,$411,$301	;	total	
	dc.w	$000,$100,$201,$311,$421,$542,$652,$661,$666,$652,$640,$530,$420,$310,$300,$200	;	-1
	dc.w	$000,$000,$101,$200,$311,$531,$541,$551,$555,$541,$530,$420,$310,$210,$200,$100	;	-2
	dc.w	$000,$000,$000,$100,$210,$421,$430,$441,$444,$431,$420,$310,$210,$110,$100,$000	;	-3
	dc.w	$000,$000,$000,$000,$100,$310,$320,$330,$333,$320,$310,$200,$100,$000,$000,$000	;	-4
	dc.w	$000,$000,$000,$000,$100,$200,$210,$220,$222,$210,$200,$100,$000,$000,$000,$000	;	-5
	dc.w	$000,$000,$000,$000,$000,$100,$100,$110,$111,$100,$100,$100,$000,$000,$000,$000	;	-6
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-7
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-8
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-9
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-10
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-11
powerpal2
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-7
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$110,$111,$100,$100,$000,$000,$000,$000,$000	;	-6
;	dc.w	$000,$000,$000,$000,$000,$010,$110,$220,$222,$210,$200,$100,$000,$000,$000,$000	;	-5
;	dc.w	$000,$000,$000,$000,$010,$120,$220,$330,$333,$320,$310,$200,$100,$000,$000,$000	;	-4
;	dc.w	$000,$000,$000,$010,$120,$230,$330,$440,$444,$430,$420,$310,$200,$100,$100,$000	;	-3
;	dc.w	$000,$000,$000,$120,$231,$340,$441,$550,$555,$541,$530,$420,$310,$200,$200,$100	;	-2
;	dc.w	$000,$000,$011,$231,$342,$451,$552,$660,$666,$652,$640,$530,$420,$310,$300,$200	;	-1

	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777 ;   -7
	dc.w	$666,$666,$666,$666,$666,$666,$666,$776,$777,$766,$766,$666,$666,$666,$666,$666 ;   -6
	dc.w	$555,$555,$555,$555,$555,$565,$665,$775,$777,$765,$755,$655,$555,$555,$555,$555	;	-5
	dc.w	$444,$444,$444,$444,$454,$564,$664,$774,$777,$764,$754,$644,$544,$444,$444,$444	;	-5
	dc.w	$333,$333,$333,$343,$453,$563,$663,$773,$777,$763,$753,$643,$533,$433,$433,$333	;	-3
	dc.w	$222,$222,$222,$342,$453,$562,$663,$772,$777,$763,$752,$642,$532,$422,$422,$322	;	-2
	dc.w	$111,$111,$122,$342,$453,$562,$663,$771,$777,$763,$751,$641,$531,$421,$411,$311	;	-1
	dc.w	$000,$011,$122,$342,$453,$562,$663,$771,$777,$763,$750,$640,$530,$420,$411,$301	;	total
	dc.w	$000,$011,$122,$342,$453,$562,$663,$771,$777,$763,$750,$640,$530,$420,$411,$301	;	total
	dc.w	$000,$000,$011,$231,$342,$451,$552,$660,$666,$652,$640,$530,$420,$310,$300,$200	;	-1
	dc.w	$000,$000,$000,$120,$231,$340,$441,$550,$555,$541,$530,$420,$310,$200,$200,$100	;	-2
	dc.w	$000,$000,$000,$010,$120,$230,$330,$440,$444,$430,$420,$310,$200,$100,$100,$000	;	-3
	dc.w	$000,$000,$000,$000,$010,$120,$220,$330,$333,$320,$310,$200,$100,$000,$000,$000	;	-4
	dc.w	$000,$000,$000,$000,$000,$010,$110,$220,$222,$210,$200,$100,$000,$000,$000,$000	;	-5
	dc.w	$000,$000,$000,$000,$000,$000,$000,$110,$111,$100,$100,$000,$000,$000,$000,$000	;	-6
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-7
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-8
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-9
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-10
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-11
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-12


_flashwaiter	dc.w	2


total_wait	equ 94
wait_before	equ 60
wait_after	equ (total_wait-wait_before)


doC2Peffect

	move.w	#$2700,sr
	move.l	#dummy_vbl2,$70
	move.w	#$2300,sr

	lea		powerpal1,a0
	movem.l (a0),d0-d7
	move.w	d0,$ffff8242
	movem.l	d1-d7,$ffff8244.w

	move.w	#7-1,d7
.whiteflash
			wait_for_vbl
		add.w	#$111,$ffff8240
	dbra	d7,.whiteflash


	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.l	screenpointer3,a2
	move.l	#0,d0
	move.l	#20-1,d7
.clear
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a2)+
	dbra	d7,.clear


;	jsr		initC2PUneven
;	jsr		generate2pxTabs				;19 this generates the 2 px tabs, this way the tabs are set up that the source picture can be read
;	jsr		generateC2P
;	jsr		generateC2PCopy
;	jsr		prepareOverlay


	move.w	#4,offset1step
	move.w	#4,offset2step
	move.w	#4,offset3step
	move.w	#0,offset1
	move.w	#0,offset2
	move.w	#0,offset3

	move.w	#$777,$ffff8240

	
	move.w	#$2700,sr
	move.l 	#c2p_vbl,$70
	move.w	#$2300,sr

;	move.w	#0,_yolo

	move.w	#0,$466.w
	move.w	#wait_after,_waitcounter
	move.w	#wait_before,_waitcounter_start

.c2ploop:	
		move.l	screenpointer,$ffff8200
		move.w	#0,_screenSwapped
		raster	#$0
		jsr		c2p_1to2_per2
		jsr		copy_c2p_lines
		jsr		doc2pOffset
		jsr		doOverlay
		add.w	#1,effectcounter
		jsr		swapscreens_c2p				; dont use jmp when it returns with rts, use branch then

		tst.w	_fadedone
		beq		.cont2
		add.w	#32,powerpaloffset
		cmp.w	#8*32,powerpaloffset
		bne		.cont2
			move.w	#0,_fadedone
.cont2


		cmp.w	#10,_waitcounter
		bgt		.ok
			add.w	#32,powerpaloffset
.ok
		tst.w	_waitcounter
		bne		.cont
			rts
.cont
	cmp.b 	#$39,$fffffc02.w
	bne		.c2ploop
	move.w	#-1,demo_exit
	rts

_screenSwapped 	dc.w	-1
;;;;;;;;;;;;;; C2P ROUT ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; C2P ROUT ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; C2P ROUT ;;;;;;;;;;;;;;;;
_flipcounter	dc.w	4
c2p_vbl:	
	addq.w 		#1,$466.w
	incSync
	pusha0
	pusha1



	IFNE	playmusic
	IFNE	playmusicinvbl				
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	ENDC
    IFNE    framecount
        addq.w  #1,_framecounter
    ENDC



    tst.w	_screenSwapped
    bne		.done
    tst.w	_fadedone
    bne		.doone

    move.l	screenpointer,a0
    cmp.l	_flippointer,a0
    bne		.done

    move.w	#-1,_screenSwapped
	tst.w	_flip
	bne		.dotwo
.doone
		lea		powerpal1,a0
		add.w	powerpaloffset,a0
		lea	$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
		jmp	.done
.dotwo
		lea		powerpal2,a0
		add.w	powerpaloffset,a0
		lea	$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
.done
;		pushd0
;			move.l	sndh_pointer,a0
;		move.b	$b8(a0),d0
;		beq		.ok
;			move.b	#0,$b8(a0)
;			move.w	#$700,$ffff8240
;.ok
;		popd0

		popa1
		popa0
	rte

initC2PUneven
	lea		angleTable,a0
	move.l	angleTable2Pointer,a1
	move.l	angleTable3Pointer,a2
	move.l	angleTable4Pointer,a3
	add.w	#1,a1
	add.w	#1,a3
	move.l	#65536/32-1,d7
.loop
	REPT 32
		move.b	(a0)+,d0
		move.b	d0,(a1)+
		lsr.b	#4,d0
		lsl.b	#2,d0
		move.b	d0,(a2)+
		move.b	d0,(a3)+
	ENDR
	dbra	d7,.loop
	rts

generate2pxTabs
	move.l	tab2px_1p,a0
	lea		TAB1,a1
	lea		TAB2,a2
	jsr		calcTab

	move.l	tab2px_2p,a0
	lea		TAB3,a1
	lea		TAB4,a2
	jsr		calcTab
	rts

generateC2PCopy
	move.l	c2pCopyPointer,a0
	move.l	#$4CEE3FFF,a1
	move.l	#$48EE3FFF,a2
	move.l	#$4CEE0FFF,a3
	move.l	#$48EE0FFF,a4

	move.l	#VIEWPORT_Y,d7
	jmp		generateC2PCopyCode


generateC2PCopyTunnel
	move.l	c2pCopyPointerTunnel,a0
;	lea		generatedC2P_copy,a0
	move.l	#$4CEE3FFF,a1
	move.l	#$48EE3FFF,a2
	move.l	#$4CEE0FFF,a3
	move.l	#$48EE0FFF,a4

	move.l	#VIEWPORT_Y-1,d7
generateC2PCopyCode
	moveq	#0,d0
	move.w	#160,d1

	move.w	#56,d2
	move.w	#160*2-112,d3

.loop
	move.l	a1,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x

	move.l	a2,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160

	add.w	d2,d0				;	x+56
	move.l	a1,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x+56

	add.w	d2,d1				;	x+160+56
	move.l	a2,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160+56

	add.w	d2,d0				;	x+56+56
	move.l	a3,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x+56+56

	add.w	d2,d1				;	x+160+56+56
	move.l	a4,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160+56+56

	add.w	d3,d0				;	pad to next 
	add.w	d3,d1				;	pad to next

	dbra	d7,.loop

	move.w	#$4e75,(a0)+
	rts

;$3018D059		a1
;(D059)
;$905A2640		a2
;(2640)
;$2A133218		a3
;(3218)
;$D259925A		a4
;(925A)
;$26418A93		a5
;(8A93)
;0BCE xxxx		d0
;0BCE yyyy		d1

;41E8 0060	lea x,a0
;43E9 0060	lea x,a1
;45EA 0060	lea x,a2
generateC2P
	move.l	c2pRoutPointer,a0
	move.l	#$3018D059,a1
	move.l	#$905A2640,a2
	move.l	#$2A133218,a3
	move.l	#$D259925A,a4
	move.l	#$26418A93,a5
	move.l	#$41E80060,d4

	move.l	#$43E90060,d2
	move.l	#$45EA0060,d3

	move.w	#SOURCE_X-VIEWPORT_X*8,d2
	move.w	#SOURCE_X-VIEWPORT_X*8,d3
	move.w	#SOURCE_X-VIEWPORT_X*8,d4
	move.w	#160+160-VIEWPORT_X*8,a6

	move.l	#$0BCE0000,d0
	add.w	#160,d1

	move.l	#VIEWPORT_Y-1,d7
	addq.w	#1,d7
	move.l	#VIEWPORT_X-1,d5

.ol
	move.l	d5,d6
.il
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#1,d0
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#7,d0
		dbra	d6,.il
	move.l	d4,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add.w	a6,d0
	dbra	d7,.ol

	move.w	#$4e75,(a0)+
	rts


; 256 vs 160 => 96 +-
; 256 vs 100 => 156 +-
_flip	dc.w	0
_frameSwapCounter	
	dc.w	78-7	; V
_frameSwapList
	dc.w	14	; V
	dc.w	13	; V
	dc.w	14	; V
	dc.w	14	; V
	dc.w	14	; V
	dc.w	13	; ok
	dc.w	14	; ok
	dc.w	14	; ok
	dc.w	14	; ok
	dc.w	13	; ok
	dc.w	-1

_frameSwapListOffset	dc.w	0
_flippointer			ds.l	1
; todo, something with 1 pixel
c2p_1to2_per2
	sub.w	#1,_frameSwapCounter
	bne		.noreset
		lea		_frameSwapList,a0
		add.w	_frameSwapListOffset,a0
		addq.w	#2,_frameSwapListOffset
		move.w	(a0),_frameSwapCounter
		move.l	screenpointer2,_flippointer
		tst.w	_flip
		beq		.setone
			move.w	#0,_flip
			jmp		.noreset
.setone
		move.w	#1,_flip
.noreset

	tst.w	_flip
	bne		.dotwo
.doone
	move.l	#angleTable,at1
	move.l	angleTable2Pointer,at2		
	jmp	.gogo
.dotwo
	move.l	angleTable3Pointer,at1
	move.l	angleTable4Pointer,at2
.gogo

	lea		c2ppath1,a6
	add.w	offset1,a6
	move.w	(a6),d0
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole1
	move.l	at1,a0
	and.w	#-2,d0
	jmp		.done1
.whole1
	move.l	at2,a0
.done1
	add.w	d0,a0

	lea		c2ppath2,a6
	add.w	offset2,a6
	move.w	(a6),d0
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole2
	move.l	at1,a1
	and.w	#-2,d0
	jmp		.done2
.whole2
	move.l	at2,a1
.done2
	add.w	d0,a1

	lea		c2ppath3,a6
	add.w	offset3,a6
	move.w	(a6),d0
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole3
	move.l	at1,a2
	and.w	#-2,d0
	jmp		.done3
.whole3
	move.l	at2,a2
.done3
	add.w	d0,a2

	move.l	tab2px_1p,d0
	move.l	tab2px_2p,d1
	move.l	screenpointer2,a6
	add.w	c2p_x_off,a6
	move.l	c2pRoutPointer,a4
	jmp		(a4)

copy_c2p_lines
	move.l	screenpointer2,a6
	add.w	c2p_x_off,a6
	move.l	c2pCopyPointer,a4
	jmp		(a4)

doc2pOffset
	move.w	offset1step,d0
	add.w	d0,offset1
	cmp.w	#120*2,offset1
	bne		.done1
		move.w	#0,offset1
.done1

	move.w	offset2step,d0
	add.w	d0,offset2
	cmp.w	#100*2,offset2
	bne		.done2
		move.w	#0,offset2
.done2

	move.w	offset3step,d0
	add.w	d0,offset3
	cmp.w	#150*2,offset3
	bne		.done3
		move.w	#0,offset3
.done3

	rts



_overlayoffset			dc.l	6*6*30*20			;22680
_overlaycounter			dc.w	7*21
_overlayscreenoffset	dc.w	0
_waitcounter_start		dc.w	0
; we want:
;	- music triggered effect switches
;	- wait with overlay rotate
;	- so
;	- wait_x, rotate, wait_y
;	- wait_x = 0; wait_y = 20

doOverlay
	lea		overlay,a1
	add.l	_overlayoffset,a1
	move.l	screenpointer2,a0
	add.w	_overlayscreenoffset,a0
	add.w	#169*160+160-48,a0
o set 0
	REPT 30
		REPT overlaywidth
			move.w	(a1)+,d0				; 9 * 53 * 8 = 3816
			move.l	(a1)+,d1
			and.l	d1,o(a0)
			and.l	d1,o+4(a0)
			or.w	d0,o+6(a0)
o set o+8
		ENDR
o set o+160-8*overlaywidth
	ENDR

	subq.w 	#1,_waitcounter_start
	bgt		.ok


	cmp.w	#6*6*30*20,_overlayoffset
;	bne		.nowait_effect

;	cmp.w	#


	subq.w	#1,_overlaycounter
	beq		.counterdone
	sub.l	#6*6*30,_overlayoffset
	bge		.ok
		move.l	#6*6*30*20,_overlayoffset
.ok
	rts

.counterdone
	move.l	#6*6*30*20,_overlayoffset
	move.w	#1,_overlaycounter
	subq.w 	#1,_waitcounter
	cmp.w	#20,_waitcounter
	bge		.ok2
	cmp.w	#33*160,_overlayscreenoffset
	beq		.ok2
		add.w	#2*160,_overlayscreenoffset
.ok2
	rts

swapscreens_normal:
		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	d0,screenpointer2
		rts	


swapscreens_c2p:
		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	screenpointer3,screenpointer2
		move.l	d0,screenpointer3
		rts	

backup_screenpointer	ds.l	1
backup_screenpointer2	ds.l	1

effectcounter			dc.w	0


calcTab
	move.l	#64-1,d7
	moveq	#0,d1
.outer
	move.l	#256-1,d6
	moveq	#0,d0
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			addq.w	#4,d0
			cmp.w	#64,d0
			bne		.noresetin
				moveq	#0,d0
.noresetin
		dbra	d6,.inner
		addq.w	#4,d1
		cmp.w	#64,d1
		bne		.noresetout
			moveq	#0,d1
.noresetout
	dbra	d7,.outer
	rts
;;;;;;;;;;;;;; C2P END ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; C2P END ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; C2P END ;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;; SCROLLER START ;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER START ;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER START ;;;;;;;;;;

dummy_vbl2:      
		addq.w	#1,$466
		pusha0
	  	move.l	sndh_pointer,a0
		jsr		8(a0)
		popa0
		rte

doScroller

	move.w	#$2700,sr
	move.l	#dummy_vbl2,$70
	move.w	#$2300,sr
	wait_for_vbl
	move.l	#screen1+65536,d0
	move.w	#0,d0
	move.l	d0,screenpointer
	add.l	#$10000,d0
	move.l	d0,screenpointer2


	move.l	screenpointer,d0
	add.l	#$8000,d0
	move.l	d0,screenpointer3


	move.l	screenpointer,a0
	jsr		clear4bpl
	move.l	screenpointer2,a0
	jsr		clear4bpl
			exitOnSpace
	move.l	screenpointer3,a0
	jsr		clear4bpl
	move.l	screenpointer4,a0
	jsr		clear4bpl
			exitOnSpace
	move.l	screenpointer5,a0
	jsr		clear4bpl
	move.l	screenpointer6,a0
	jsr		clear4bpl
			exitOnSpace
	move.l	screenpointer7,a0
	jsr		clear4bpl
	move.l	screenpointer8,a0
	jsr		clear4bpl
			exitOnSpace
	move.l	preshiftFontPointer,a0
	add.l	#32000,a0
	jsr		clear4bpl
	move.l	preshiftFontPointer,a0
	add.l	#64000,a0
	jsr		clear4bpl
	move.l	preshiftFontPointer,a0
	add.l	#96000,a0
	jsr		clear4bpl
			exitOnSpace



	move.w	#$2700,sr
	move.l	#default_vbl,$70
	move.w	#$2300,sr


	; WARNING NEED TO CLEAR SCREENS BEFORE USE
	wait_for_vbl

	move.w	#$2700,sr
	move.l	#code_vbl,$70
	move.w	#$2300,sr

	jsr 	generateStartX_scroll				; this different	inverted
	jsr 	generateEndX_scroll					; this different	inverted
			exitOnSpace
	jsr		generateHDrawTable1bpl				; this different		or => and move.w -1 => move.w 0
	jsr		generateHDrawTable2bpl				; this different
			exitOnSpace
 	jsr		init_yblock_aligned
 	jsr		generateBuildListSub
 	jsr		generateBuildListAdd

	move.l	#col1,colorpointer
	move.l	#col2,colorpointer2
	move.l	#col3,colorpointer3
	move.l	#col4,colorpointer4


	move.l	starLocs,a0
	move.l	starLocs2,a1
	move.l	starLocs3,a2
	move.l	starLocs4,a3
	move.l	screenpointer2,d0
	move.l	#number_of_stars-1,d7
.x1
		move.l	d0,(a0)+
		move.w	d0,(a0)+
		move.l	d0,(a1)+
		move.w	d0,(a1)+
		move.l	d0,(a2)+
		move.w	d0,(a2)+
		move.l	d0,(a3)+
		move.w	d0,(a3)+
	dbra	d7,.x1

	move.l	starLocs5,a0
	move.l	starLocs6,a1
	move.l	starLocs7,a2
	move.l	starLocs8,a3
	move.l	#number_of_stars-1,d7
.x2
		move.l	d0,(a0)+
		move.w	d0,(a0)+
		move.l	d0,(a1)+
		move.w	d0,(a1)+
		move.l	d0,(a2)+
		move.w	d0,(a2)+
		move.l	d0,(a3)+
		move.w	d0,(a3)+
	dbra	d7,.x2


 	move.w	#0,$ffff8240
	move.w	#$445,$ffff8240+2*4
 
 	move.w	#80+192,_star_wait

.star_wait
	wait_for_vbl
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	screenpointer3,screenpointer2
	move.l	screenpointer4,screenpointer3
	move.l	screenpointer5,screenpointer4
	move.l	screenpointer6,screenpointer5
	move.l	screenpointer7,screenpointer6
	move.l	screenpointer8,screenpointer7
	move.l	d0,screenpointer8

	jsr		doStars
			exitOnSpace

	subq.w	#1,_star_wait
	bne		.star_wait

	lea		polygonlist,a0
	move.l	a0,ptr

	move.w	#$2700,sr
	move.l	#precalc_vbl,$70
	move.w	#$2300,sr

 	jsr		preShiftFontInit
 			exitOnSpace
 	jsr		preShiftFont
 			exitOnSpace

 	move.w	#120-64,_star_wait

.wait	
			exitOnSpace
 	tst.w	polydone
 	bne		.wait

	jsr 	generateStartX2_scroll						; this different	inverted
	jsr 	generateEndX2_scroll						; this different	inverted
	jsr		generateHDrawTable1bpl2				; this different		or => and move.w -1 => move.w 0
	jsr		generateHDrawTable2bpl2
	move.w	#$7600,s1
	move.w	#$7600,s2

.wait2
			wait_for_vbl
			exitOnSpace
 	subq.w	#1,_star_wait
 	bne		.wait2

 	move.w	#1500-640,_scrollercounter

 	move.w	#$2700,sr
 	move.l	#code_vbl,$70
 	move.w	#$2300,sr

 	lea		scrollertext,a0
 	move.l	a0,_scrollerTextSourcePointer


.mainloop:
		wait_for_vbl
		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	screenpointer3,screenpointer2
		move.l	screenpointer4,screenpointer3
		move.l	screenpointer5,screenpointer4
		move.l	screenpointer6,screenpointer5
		move.l	screenpointer7,screenpointer6
		move.l	screenpointer8,screenpointer7
		move.l	d0,screenpointer8

		jsr		clearFontLine
		raster	#$700
		jsr		drawStringAtPixel
		raster	#$007
		jsr		advancePixelPosition
		raster	#$070
		jsr		doStars
		raster	#0


		subq.w	#1,_scrollercounter
		bne		.contx
			jmp	.scrollerout
.contx
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop
		move.w	#1,demo_exit
		rts

.scrollerout
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TO REMOVE THE BARS	;
	move.l	#28-1,d7
.www
		wait_for_vbl									;
		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	screenpointer3,screenpointer2
		move.l	screenpointer4,screenpointer3
		move.l	screenpointer5,screenpointer4
		move.l	screenpointer6,screenpointer5
		move.l	screenpointer7,screenpointer6
		move.l	screenpointer8,screenpointer7
		move.l	d0,screenpointer8
		jsr		doStars
				exitOnSpace
	dbra	d7,.www


	move.w	#$2700,sr									;
	move.l	#precalc_vbl2,$70							;
	move.w	#$2300,sr									;
	move.w 	#1,polydone									;
	lea		polygonlist,a0								;
	move.l	a0,ptr										;
	move.w	#0,planeoffset								;
	move.w	#8,planecounter								;
	move.w	#100,_scrollercounter
	move.l	#putPixelsOut,pixelPointer
.goout
			wait_for_vbl
			exitOnSpace
	subq.w	#1,_scrollercounter
	bne		.goout



	move.w	#$444,$ffff8240+2*4
	move.w	#21,_scrollercounter
	move.w	#5,vblcounter

.goout2
	wait_for_vbl
	subq.w	#1,_scrollercounter
	beq		.end2

	subq.w	#1,vblcounter
	bne		.xxx
		sub.w	#$111,$ffff8240+2*4
		move.w	#5,vblcounter
.xxx
		exitOnSpace

	jmp		.goout2

.end2


	rts
;;;;;;;;;;;;;; SCROLLER ROUTS ;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER ROUTS ;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER ROUTS ;;;;;;;;;;

_scrollercounter	dc.w	0
polydone		dc.w	1
planeoffset		dc.w	0
planecounter	dc.w	8
_star_wait		dc.w	0

planeRoutAndOffList
	dc.w	0
	dc.l	drawEdgeList			;1
	dc.w	2
	dc.l	drawEdgeList			;2
	dc.w	0
	dc.l	drawEdgeList2bpl		;3
	dc.w	2
	dc.l	drawEdgeList2bpl		;6







; ***************************************** END MAINLOOP ************






; we have 4 cases of the bars:
; 1	bpl 0
; 2	bpl 1
; 3	bpl 0+1
; 4	bpl 1+2
;
; we draw at bpl 2, so we have 2 concerns:
; a	the clearing
; b the painting
;
; a is covered by by jsut storing the area we drew
; b should be sorted by polling the area at bitplane 0 and 1, move.l (a0),d0
; 	so we should have our mask at .l not .w

clearPixel	macro
	move.l	(a0)+,a1			; screen address
	move.w	(a0)+,(a1)			; mask thats added
	endm

doPixel	macro
	move.l	a4,a0				;	4			
	add.w	(a5)+,a0			;	12			move.w	(a5)+,d6		(y value)		8
	move.w	(a5),d0				;	8			add.w	(a2,d0.w),d6					16
	add.w	(a2,d0.w),a0		;	20			move.w	(a5),d0			(x value)		8
	move.l	(a1,d0.w),d2		;	20			add.w	d6,a0							8

	sub.w	d5,d0				;	4
	bge		.noreset\@			;	12
		move.w	d6,d0
.noreset\@
	move.w	d0,(a5)+			;	8

	move.l	a0,(a3)+
	move.w	(a0),(a3)+
	move.l	d2,d1			; mask to d1
	and.l	-4(a0),d1		; see if we get zerood out
	bne		.skip\@
		or.w	d2,(a0)		; if we're zerood ot, theres nothing at bpl 0 or 1, so draw
.skip\@
	endm


doPixelOut	macro
	move.l	a4,a0				;	4			
	add.w	(a5)+,a0			;	12			move.w	(a5)+,d6		(y value)		8
	move.w	(a5),d0				;	8			add.w	(a2,d0.w),d6					16
	add.w	(a2,d0.w),a0		;	20			move.w	(a5),d0			(x value)		8
	move.l	(a1,d0.w),d2		;	20			add.w	d6,a0							8

	sub.w	d5,d0				;	4
	bge		.noreset\@			;	12
		move.w	d0,(a5)+
		move.l	a4,(a3)+
		move.w	#0,(a3)+
		jmp		.skip\@
.noreset\@
	move.w	d0,(a5)+			;	8

	move.l	a0,(a3)+
	move.w	(a0),(a3)+
	move.l	d2,d1			; mask to d1
	and.l	-4(a0),d1		; see if we get zerood out
	bne		.skip\@
		or.w	d2,(a0)		; if we're zerood ot, theres nothing at bpl 0 or 1, so draw
.skip\@
	endm

doStars

	move.l	starLocs,d0
	move.l	starLocs2,starLocs
	move.l	starLocs3,starLocs2
	move.l	starLocs4,starLocs3
	move.l	starLocs5,starLocs4
	move.l	starLocs6,starLocs5
	move.l	starLocs7,starLocs6
	move.l	starLocs8,starLocs7
	move.l	d0,starLocs8



	move.l	screenpointer2,a4
	add.w	#4,a4
	lea		pixelmask,a1
	lea		pixelblock,a2
	move.l	starLocs,a3
	lea		pixelposlist,a5

	move.l	pixelPointer,a6

	move.w	#319*4,d6

	move.w	#1*4,d5
	jsr		(a6)

	move.w	#2*4,d5
	jsr		(a6)

	move.w	#3*4,d5
	jsr		(a6)

	move.w	#4*4,d5
	jsr		(a6)

	move.w	#5*4,d5
	jsr		(a6)

	move.w	#6*4,d5
	jsr		(a6)

	move.w	#7*4,d5
	jsr		(a6)


	move.l	starLocs3,a0
	REPT number_of_stars
		clearPixel
	ENDR

	move.w	#$000,$ffff8240
	rts

pixelPointer	dc.l	putPixels

putPixels
	REPT number_of_stars/7
		doPixel
	ENDR
	rts

putPixelsOut
	REPT number_of_stars/7
		doPixelOut
	ENDR
	rts

clearFontLine
	raster	#$070
	move.l	screenpointer2,a0
	add.w	#86*160,a0
	add.w	#6,a0
	move.l	#34-1,d7
	move.w	#0,d0
.ol
o set 0
	REPT 20
		move.w	d0,o(a0)
o set o+8
	ENDR
	add.w	#160,a0
	dbra	d7,.ol
	rts


fontheight		equ 35
fontwidth		equ 2
letterswidth	equ 20/fontwidth
lettersheight	equ 3



preShiftFontInit
	lea		scrollerfont,a3
	move.l	preshiftFontPointer,a4
;	lea		preshifted,a4

	move.l	#lettersheight-1,d6
	moveq	#0,d2
.copyRow
		move.l	#letterswidth-1,d7	
.copyLetter
;			move.l	a3,a0
			move.l	a4,a1
o 			set 	0
			REPT fontheight
				move.w	(a3)+,(a1)+
				move.w	(a3)+,(a1)+
				move.w	d2,(a1)+
o 				set 	o+160
			ENDR
;			add.w	#fontwidth*8,a3
			add.w	#2*(fontwidth+1)*fontheight*16,a4
		dbra	d7,.copyLetter
;	add.w	#(fontheight-1)*160,a3
	dbra	d6,.copyRow
	rts

preShiftFont
;	lea		preshifted,a4
	move.l	preshiftFontPointer,a4

	move.l	#letterswidth*lettersheight-1,d7
.shiftChar
	move.l	a4,a0
	move.l	a4,a1
	add.l	#2*(fontwidth+1)*fontheight,a1
	move.w	#15-1,d6

.ol1
	REPT fontheight
		movem.w	(a0)+,d0-d2
		roxr.w	d0
		roxr.w	d1
		roxr.w	d2
		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+
	ENDR
	dbra	d6,.ol1

	add.l	#(fontwidth+1)*2*fontheight*16,a4
	dbra	d7,.shiftChar
	rts


scrollertextoff	dc.w		0
scrollerPixelOffset	dc.w	0			; 
scrollerBlockOffset	dc.w	0			;



; idea is to do: draw char at pixel
pixelPosition				dc.w	319
_pixelPosition				dc.w	0
_scrollTextOffset			dc.w	0
_scrollerTextSourcePointer	dc.l	0

drawStringAtPixel
	move.w	pixelPosition,d0
	move.w	d0,_pixelPosition

;	lea		scrollertext,a2					; string text
	move.l	_scrollerTextSourcePointer,a2
	add.w	_scrollTextOffset,a2
	lea		characterWidthTable,a3
	lea		pixelToBlockOfffsetTable,a4
	lea		pixelToPreshiftOffsetTable,a5
	move.l	preshiftFontPointer,a6

;	move.w	#30-1,d7				; static number of chars atm

.doChar
	move.w	_pixelPosition,d0
	add.w	d0,d0
	move.w	(a4,d0.w),d1						; d1 block offset into screen
	move.w	(a5,d0.w),d2						; d2 offset into preshift

	cmp.w	#1,d2

	cmp.w	#20*8,d1
	bge		.end

;	lea		preshifted,a0					; preshifted data
	move.l	a6,a0
	moveq	#0,d0
	move.b	(a2)+,d0
	sub.b	#65,d0			;4		; align to offset font
	bge		.nospace
		; if we are here, we've encountered a space
		add.w	#10,_pixelPosition
		move.w	#10,d4
		cmp.w	#-3*8,d1
		beq		.special
		jmp		.doChar
;		dbra	d7,.doChar
.nospace
	add.w	d0,d0
	move.w	(a3,d0.w),d4
	lsr.w	#2,d4
	add.w	d4,_pixelPosition
	muls	#(fontwidth+1)*2*fontheight*16/2,d0
	; then d0 is offset into the preshifted
	add.l	d0,a0
	add.w	d2,a0						; pixel offset

	move.l	screenpointer2,a1
	add.w	#6,a1						; bitplane offset
	add.w	#86*160,a1					; vertical offset
	add.w	d1,a1						; blockoffset added

	cmp.w	#19*8,d1
	beq		.lastblock
	cmp.w	#18*8,d1
	beq		.lasttwo
	cmp.w	#-1*8,d1
	beq		.firsttwo
	cmp.w	#-2*8,d1
	beq		.firstone
	cmp.w	#-3*8,d1
	beq		.special

.normal
o set 0
	REPT fontheight
y set o
		REPT fontwidth+1
			move.w	(a0)+,d0
			or.w	d0,y(a1)
y set y+8
		ENDR

o set o+160
	ENDR
;	dbra	d7,.doChar
	jmp		.doChar
.end
	rts

.lastblock
o set 0
	REPT fontheight
y set o
		REPT fontwidth-1
			move.w	(a0)+,d0
			or.w	d0,y(a1)
y set y+8
		ENDR
		add.w	#4,a0				; skip last block
o set o+160
	ENDR
;	dbra	d7,.doChar
	jmp		.doChar
	rts

.lasttwo
o set 0
	REPT fontheight
y set o
		REPT fontwidth
			move.w	(a0)+,d0
			or.w	d0,y(a1)
y set y+8
		ENDR
		add.w	#2,a0				; skip last block
o set o+160
	ENDR
;	dbra	d7,.doChar
	jmp		.doChar
	rts

.firsttwo
o set 8
	REPT fontheight
y set o
		add.w	#2,a0
		REPT fontwidth
			move.w	(a0)+,d0
			or.w	d0,y(a1)
y set y+8
		ENDR
o set o+160
	ENDR
;	dbra	d7,.doChar
	jmp		.doChar
	rts

.firstone
o set 16
	REPT fontheight
y set o
		add.w	#4,a0
		REPT fontwidth-1
			move.w	(a0)+,d0
			or.w	d0,y(a1)
y set y+8
		ENDR
o set o+160
	ENDR
;	dbra	d7,.doChar
	jmp		.doChar
	rts
		
.special
	tst.w	_outtroactive
	beq		.outtrospecial
	add.w	#1,_scrollTextOffset
	add.w	d4,pixelPosition
	jmp		.doChar

.resetshit
	move.w	#0,_scrollTextOffset
	move.w	#1,pixelPosition
;	move.b	#0,$fffc123
;	move.w	#319,pixelPosition
	jmp		.doChar

.outtrospecial
	add.w	#1,_scrollTextOffset
	cmp.w	#55,_scrollTextOffset
	beq		.resetshit
	add.w	d4,pixelPosition
	jmp		.doChar

_outtroactive	dc.w	1
_scrollSpeed	dc.w	6

advancePixelPosition
	move.w	_scrollSpeed,d0
	sub.w	d0,pixelPosition
	rts

speedlistoffset	dc.w	58

speedlist	;30
	dc.w	1
	dc.w	2
	dc.w	2
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	4
	dc.w	4
	dc.w	4
	dc.w	5
	dc.w	5
	dc.w	5
	dc.w	5
	dc.w	5
	dc.w	6
	dc.w	6
	dc.w	6
	dc.w	5
	dc.w	5
	dc.w	5
	dc.w	5
	dc.w	5
	dc.w	4
	dc.w	4
	dc.w	4
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	2
	dc.w	2
	dc.w	1

xoffset dc.w	0

advancePointer
		move.l	ptr,d0
		cmp.l	#endptr,d0
		bne		.x
			lea		polygonlist,a0
			move.l	a0,ptr
			move.w	#0,polydone
.x

		subq.w	#1,planecounter
		bne		.nopl
			move.w	#8,planecounter
			tst.w	planeoffset
			bne		.xtt
				move.w	#4*6,planeoffset
.xtt
			subq.w	#1*6,planeoffset
.nopl
	rts


drawBars
		tst.w	polydone
		beq		.nomore
.doPoly
		move.l	ptr,a0
		movem.l	(a0)+,d0-d3
		move.l	a0,ptr
		cmp.l	#-1,d3
		beq		.nomore

		move.l	d2,d5
		swap	d5
		move.w	#0,xoffset
		cmp.w	#160,d5
			blt	.ok
			jsr		adjustCoords
.ok

		jsr		polygonToEdgeList

		move.w	xoffset,d0
		lsr.w	#1,d0

		lea		planeRoutAndOffList,a6
		add.w	planeoffset,a6
		add.w	(a6)+,d0
		move.l	(a6),a6
		jsr		(a6)
		jmp		.doPoly
.nomore
	rts


removeBars
		tst.w	polydone
		beq		.nomore
.doPoly
		move.l	ptr,a0
		movem.l	(a0)+,d0-d3
		move.l	a0,ptr
		cmp.l	#-1,d3
		beq		.nomore

		move.l	d2,d5
		swap	d5
		move.w	#0,xoffset
		cmp.w	#160,d5
			blt	.ok
			jsr		adjustCoords
.ok

		jsr		polygonToEdgeList

		move.w	xoffset,d0
		lsr.w	#1,d0

		lea		planeRoutAndOffList,a6
		add.w	planeoffset,a6
		add.w	(a6)+,d0
		move.l	(a6),a6
		jsr		(a6)
		jmp		.doPoly
.nomore
	rts


adjustCoords
	move.w	#160,xoffset
	move.l	#160,d4
	swap	d4



	cmp.l	d4,d0
	ble		.no
	cmp.l	d4,d1
	ble		.no
	cmp.l	d4,d2
	ble		.no
	cmp.l	d4,d3
	ble		.no

	sub.l	d4,d0
	sub.l	d4,d1
	sub.l	d4,d2
	sub.l	d4,d3
	rts
.no
	move.w	#0,xoffset
	rts

ptr	ds.l	1

drawEdgeList
	move.l	screenpointer2,a0			;20		; smc = -8
	add.w	d0,a0
	lea		polygonLeft,a5				;12		
	lea		polygonRight+4,a6			;12
	moveq	#-4,d5						;4
	move.l	y_block_pointer,d0
	move.w	(a5)+,d0					;8
	add.w	d0,d0						;4
	add.w	d0,d0						;4
	move.l	d0,a1						;4
	add.w	(a1),a0						;16
	move.l	x_start_pointer_1bpl_scroll,d0		;20		; smc = -8
	move.l	x_end_pointer_1bpl_scroll,d1		;20		; smc = -8
	move.l	drawTablePointer1bpl_scroll,d2		;20		; smc = -8
s1	moveq	#-1,d3						;4
	move.w	(a5)+,d4					;8
	subq.w	#1,d4						;8
	move.l	d2,a4						;4
	jmp		(a4)						;8

drawEdgeList2bpl
	move.l	screenpointer2,a0
	add.w	d0,a0

	lea		polygonLeft,a5
	lea		polygonRight+4,a6
	moveq	#-4,d5
	move.l	y_block_pointer,d0
	move.w	(a5)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	d0,a1
	add.w	(a1),a0
	move.l	x_start_pointer_2bpl_scroll,d0
	move.l	x_end_pointer_2bpl_scroll,d1
	move.l	drawTablePointer2bpl_scroll,d2
s2	moveq	#-1,d3						;4		; we only need a word here
	move.w	(a5)+,d4
	subq.w	#1,d4
	move.l	d2,a4
	jmp		(a4)


initBuffer macro
	lea		\1,a0				;8
	move.w	\2,(a0)+			;8
	move.w	\3,d7				;4
	sub.w	\2,d7				;4
	move.w	d7,(a0)+			;8
	endm						;---->32


addEdgeToBuffer macro
	; we need:
	; d4 = x_top
	; d5 = y_top
	; d6 = x_bot
	; d7 = y_bot
	move.l	\1,d4						;4
	move.l	\2,d6						;4
	jsr		etb
	endm

etb
	move.w	d4,d5						;4
	swap	d4							;4
	move.w	d6,d7						;4
	swap	d6							;4
	lea		.returnaddress(pc),a2		;8
	jmp		buildList					;8	;+code execution, +8 jmp back --> 16
.returnaddress
	rts


;;;;; currently we do not take into account visibility, and therefore ordering of the vertices
; however, we should assume that a certain order is in place
; WE ASSUME RIGHT HAND SIDE RULE, E.G. 
;
;
;	/   <-\
;	|	  |
;	\-----/  <--- this is the order of the vertices, which should be visible, so all the vertices are ordered this way that are visible, and clockwise 
; 					if not visible; --> https://www.udacity.com/course/viewer#!/c-cs291/l-90856897/m-97415606
;
polygonToEdgeList			; we do this at most for 6 polygons in cube (glenz), or 3 (non-glenz)
	move.w	#1200,a6

	cmp.w	d0,d1
	bgt		.d0_above_d1
	blt		.d1_above_d0
.d0_equal_d1_and_d2_equal_d3	; d0=d1
	cmp.w	d0,d3
	bgt		.d0_d1_top
	blt		.d2_d3_top
;----------- START ALL SAME ----------------;
.all_same_y			; d0=d1=d2=d3
	illegal
		rts
;----------- END ALL SAME ------------------;

;----------- START D0_D1 TOP ---------------;	ok!
.d0_d1_top			; d0=d1 top				;
	; determine who is left and right		;
	;	line is d0,d3 d1,d2 				;
	cmp.l	d0,d1							;
	bgt		.d0_d1_top_d0_left				;
.d0_d1_top_d1_left							;	TC15: ok
	initBuffer	polygonLeft,d1,d2			;
	addEdgeToBuffer d1,d2					;
	initBuffer	polygonRight,d0,d3			;
	addEdgeToBuffer d0,d3					;
	rts										;
.d0_d1_top_d0_left							;	TC16: ok
	initBuffer	polygonLeft,d0,d3			;
	addEdgeToBuffer d0,d3					;
	initBuffer	polygonRight,d1,d2			;
	addEdgeToBuffer d1,d2					;
	rts										;
;----------- END D0_D1 TOP -----------------;

;----------- START D2_D3 TOP ---------------;	OK!
.d2_d3_top			; d2=d3 top				;
	cmp.l	d2,d3							;
	bgt		.d2_d3_top_d2_left				;
.d2_d3_top_d3_left							;	TC5: OK!
	initBuffer	polygonLeft,d3,d0			;
	addEdgeToBuffer d3,d0					;	--> 196 + 16 per line
	initBuffer	polygonRight,d2,d1			;
	addEdgeToBuffer d2,d1					;	--> 196 + 16 per line
	rts										;
.d2_d3_top_d2_left							;	TC6: OK!
	initBuffer	polygonLeft,d2,d1			;
	addEdgeToBuffer d1,d2					;	--> 196 + 16 per line
	initBuffer	polygonRight,d3,d0			;
	addEdgeToBuffer d3,d0					;	--> 196 + 16 per line
	rts										;
;----------- END D2_D3 TOP -----------------;

.d0_above_d1
	cmp.w	d0,d3
	bgt		.d0_top
	blt		.d3_above_d0d1
.d0_d3_top
	cmp.l	d0,d3
	bgt		.d0_d3_top_d0_left
;----------- BEGIN D0-D3 TOP ---------------;	OK!
.d0_d3_top_d3_left							;	TC3: OK!
	initBuffer	polygonLeft,d3,d2			;	
	addEdgeToBuffer d3,d1					;	--> 196 + 16 per line
	initBuffer	polygonRight,d0,d1			;
	addEdgeToBuffer d0,d1					;	--> 196 + 16 per line
	rts										;
											;
.d0_d3_top_d0_left							;	TC2: OK!
	initBuffer polygonLeft,d0,d1			;
	addEdgeToBuffer d0,d1					;	--> 196 + 16 per line
	initBuffer	polygonRight,d3,d2			;
	addEdgeToBuffer d3,d2					;	--> 196 + 16 per line
	rts										;
;----------- END D0-D3 TOP -----------------;

;----------- BEGIN D0 TOP ------------------;	OK!
.d0_top										;
	addq.w	#1,d2
	cmp.l	d1,d3							;
	bgt		.d0_top_d1_left					;
.d0_top_d3_left								;	TC4: OK!
	initBuffer 		polygonLeft,d0,d2		;	32
	addEdgeToBuffer d0,d3					;	--> 196 + 16 per line
	addEdgeToBuffer d3,d2					;	--> 196 + 16 per line
	initBuffer		polygonRight,d0,d2		;	32
	addEdgeToBuffer d0,d1					;	--> 196 + 16 per line
	addEdgeToBuffer d1,d2					;	--> 196 + 16 per line
	rts										;
.d0_top_d1_left								;	TC1: OK!
	initBuffer		polygonLeft,d0,d2		;	32
	addEdgeToBuffer d0,d1					;
	addEdgeToBuffer	d1,d2					;
	initBuffer		polygonRight,d0,d2		;	32
	addEdgeToBuffer	d0,d3					;
	addEdgeToBuffer	d3,d2					;
	rts										;
;----------- END D0 TOP --------------------;


.d3_above_d0d1
	cmp.w	d3,d2
	bgt		.d3_top
;----------- BEGIN D2 TOP ------------------;	ok!
.d2_top										;
	addq.w	#1,d0
	cmp.l	d1,d3							;
	bgt		.d2_top_d1_left					;
.d2_top_d3_left								;	TC7: ok!
	initBuffer		polygonLeft,d2,d0		;
	addEdgeToBuffer d2,d3					;
	addEdgeToBuffer d3,d0					;
	initBuffer 		polygonRight,d2,d0		;
	addEdgeToBuffer d2,d1					;
	addEdgeToBuffer d1,d0					;
	rts										;
.d2_top_d1_left								;	TC8: ok!
	initBuffer		polygonLeft,d2,d0		;
	addEdgeToBuffer d2,d1					;
	addEdgeToBuffer d1,d0					;
	initBuffer		polygonRight,d2,d0		;
	addEdgeToBuffer d2,d3					;
	addEdgeToBuffer d3,d0					;
	rts										;
;----------- END D2 TOP --------------------;

;----------- BEGIN D3 TOP ------------------;	OK!
.d3_top										;
	addq.w	#1,d1
	cmp.l	d0,d2							;
	bgt		.d3_top_d0_left					;
.d3_top_d2_left								;	TC9: ok!
	initBuffer		polygonLeft,d3,d1		;
	addEdgeToBuffer	d3,d2					;
	addEdgeToBuffer	d2,d1					;
	initBuffer		polygonRight,d3,d1		;
	addEdgeToBuffer	d3,d0					;
	addEdgeToBuffer	d0,d1					;
	rts										;
.d3_top_d0_left								;	TC10: ok!
	initBuffer		polygonLeft,d3,d1		;
	addEdgeToBuffer	d3,d0					;
	addEdgeToBuffer	d0,d1					;
	initBuffer		polygonRight,d3,d1		;
	addEdgeToBuffer	d3,d2					;
	addEdgeToBuffer	d2,d1					;
	rts										;
;----------- END D3 TOP --------------------;
.d1_above_d0
	cmp.w	d1,d2
	bgt		.d1_top
	blt		.d2_top
;----------- BEGIN D1-D2 TOP ---------------;	ok!	
.d1_d2_top									;
	cmp.l	d1,d2							;
	bgt		.d1_d2_top_d1_left				;
.d1_d2_top_d2_left							;	TC13: ok!
	initBuffer	polygonLeft,d2,d0			;	
	addEdgeToBuffer d2,d0					;
	initBuffer	polygonRight,d1,d3			;
	addEdgeToBuffer d1,d3					;
	rts										;
.d1_d2_top_d1_left							;	TC14: ok!
	initBuffer	polygonLeft,d1,d3			;	
	addEdgeToBuffer d1,d3					;
	initBuffer	polygonRight,d2,d0			;
	addEdgeToBuffer d2,d0					;
	rts										;
;----------- END D1-D2 TOP -----------------;		

;----------- BEGIN D1 TOP ------------------;		
.d1_top										;
	addq.w	#1,d3
	cmp.l	d0,d2							;
	bgt		.d1_top_d0_left					;
.d1_top_d2_left								;	TC11: ok!
	initBuffer		polygonLeft,d1,d3		;
	addEdgeToBuffer	d1,d2					;
	addEdgeToBuffer	d2,d3					;
	initBuffer		polygonRight,d1,d3		;
	addEdgeToBuffer	d1,d0					;
	addEdgeToBuffer	d0,d3					;
	rts										;
.d1_top_d0_left								;	TC12: ok!
	initBuffer		polygonLeft,d1,d3		;
	addEdgeToBuffer	d1,d0					;
	addEdgeToBuffer	d0,d3					;
	initBuffer		polygonRight,d1,d3		;
	addEdgeToBuffer	d1,d2					;
	addEdgeToBuffer	d2,d3					;
	rts										;
;----------- END D3 TOP --------------------;



;;;;;;
; needs:
;		d5 = y2
;		d7 = y1
;		d6 = x2
;		d4 = x1

;		a0 = buffer
;		a1 = divtable
;		a2 = return address
; cost: 132 init + 16 per line
tmp	dc.l	0

testx equ 1

buildList

	sub.w	d5,d7				;4		; dy = y2-y1
	sub.w	d4,d6				;4		; dx = x2-x1
	ble		.dx_neg				;12		; check for x_start > x_end, then we have a negative slope, since we go from top to bottom

.dx_noneg
	ext.l	d7		;dy
	ext.l	d6		;dx

	move.l	d0,tmp
	moveq	#0,d0

	asl.l	#8,d6
	divu	d7,d6
	move.w	d6,d0
	clr.w	d6
	swap	d6
	asl.l	#8,d6
	divu	d7,d6
	swap	d0
	asr.l	#8,d0
	or.w	d6,d0
	asl.l	#2,d0

	add.w	d7,d7				;4
	move.w	d7,d5				;4
	add.w	d7,d7				;4
	add.w	d5,d7				;4
	move.w	a6,d5				;4
	sub.w	d7,d5				;4

	move.l	d0,d7
	move.l	tmp,d0

	move.w	d7,a4				;4
	moveq	#0,d6				;4
	swap	d7					;4

	add.w	d4,d4				;4
	add.w	d4,d4				;4
	raster	#$040
	move.l	buildListAddPointer,a5
	jmp		(a5,d5.w)


.dx_neg									; dx is negative, so from left to right, but our lut has only positive values
	ext.l	d7		;dy
	ext.l	d6		;dx
	neg.l	d6					;8		; ...


	move.l	d0,tmp
	moveq	#0,d0

	asl.l	#8,d6
	divu	d7,d6
	move.w	d6,d0
	clr.w	d6
	swap	d6
	asl.l	#8,d6
	divu	d7,d6
	swap	d0
	asr.l	#8,d0
	or.w	d6,d0
	asl.l	#2,d0

	add.w	d7,d7				;4
	move.w	d7,d5				;4
	add.w	d7,d7				;4
	add.w	d5,d7				;4
	move.w	a6,d5				;4
	sub.w	d7,d5				;4


	move.l	d0,d7
	move.l	tmp,d0



	move.w	d7,a4				;4
	move.w	#-1,d6				;4
	swap	d7					;4

	add.w	d4,d4				;4
	add.w	d4,d4				;4

	raster	#$040
	move.l	buildListSubPointer,a5

	jmp		(a5,d5.w)

generateBuildListSub
	move.l	buildListSubPointer,a0
	move.l	#$30C49C4C,d0					
	move.l	#$994730C4,d1
	move.l	#$9C4C9947,d2
	move.l	#100-1,d7
.ox
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
	dbra	d7,.ox
	move.w	#$4ED2,(a0)
	rts

generateBuildListAdd
	move.l	buildListAddPointer,a0
	move.l	#$30C4DC4C,d0
	move.l	#$D94730C4,d1
	move.l	#$DC4CD947,d2
	move.l	#100-1,d7
.ox
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
	dbra	d7,.ox
	move.w	#$4ED2,(a0)
	rts


drawLineInitTemplate
	move.w	(a5)+,d0					;8				;2		; get x_start
	move.w	(a6)+,d1					;8				;2		; get x_end
	and.w	d5,d0						;4				;2		; zero out lower 2 bits
	and.w	d5,d1						;4				;2		; zero out lower 2 bits
	cmp.w	d0,d1
	move.l	d0,a1						;4				;2		; get address of xstart table
	move.l	d1,a2						;4				;2		; get address of xend table
	move.w	(a1)+,d2					;8				;2		; get offset xstart
	add.w	(a2)+,d2					;8				;2		; add offset xend
	move.w	(a1)+,d0					;8				;2		; get mask xstart
	move.w	(a2)+,d1					;8				;2		; get mask xend
	move.l	d2,a1						;4				;2		; use gotten offset for drawroutine
	jmp		(a1)						;8				;2		; jump to draw routine						;--> 24
		

generateHDrawTable1bpl
	move.l	drawTablePointer1bpl_scroll,a0
	move.l	a0,a5
	sub.l	#2,a5
	moveq	#0,d0					;$xbase=0
	moveq	#0,d1					;$xval
	moveq	#20,d2					;condition
	move.w	#$3143,d3
	move.w	#$8368,d4				

	lea		drawLineInitTemplate,a6
	REPT 10
		move.l	(a6)+,(a0)+
	ENDR
		move.w	(a6)+,(a0)

	move.l	drawTablePointer1bpl_scroll,a0
	move.l	a0,a2
	add.w	#128,a0


	moveq	#0,d7					;$x=0
.loop_x								;for($x=0;$x<20;$x++)-----------------------------------------------\
		move.w	d0,d1				;$xval = $xbase														|
		moveq	#0,d6				;$y=0																|
.loop_y								;for($y=0;$y<20;$t++)................................				|
			move.l	a0,a1			;													.				|
			cmp.w	d7,d6			;													.				|
			blt		.t_minus_i_lt0	;$diff < 0											.				|
			beq		.t_minus_i_eq0	;$diff == 0											.				|
.t_minus_i_gt0						;$diff > 1											.				|
			move.w	d0,d1			;													.				|
			move.w	#$8168,(a1)+	; or.w	d0,x(a0)									.				|
			move.w	d1,(a1)+		;  x												.				|
			add.w	#8,d1			;													.				|
			move.w	d6,d5			;													.				|
			sub.w	d7,d5			;													.				|
			subq.w	#2,d5			;													.				|
			blt		.x				;													.				|
.move_w_loop						;													.				|
;				move.w	#$3143,(a1)+; move.w	d3,x(a0) with....						.				|
				move.w	d3,(a1)+	; move.w	d3,x(a0) with....						.				|
				move.w	d1,(a1)+	;	.... $xval as offset							.				|
				addq.w	#8,d1		;													.				|
			dbra	d5,.move_w_loop	;													.				|
.x									;													.				|
;			move.w	#$8368,(a1)+	; or.w	d1,x(a0)									.				|
			move.w	d4,(a1)+		; or.w	d1,x(a0)									.				|
			move.w	d1,(a1)+		;													.				|
;			move.w	#$4ed2,(a1)+	;	jmp (a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
									;													.				|
.t_minus_i_eq0						;$diff == 0	; only hit at first step 				.				|
			move.w	#$c240,(a1)+	; and.w d0,d1										.				|
;			move.w	#$8368,(a1)+	; or.w	d1,x(a0) with.....							.				|
			move.w	d4,(a1)+		; or.w	d1,x(a0) with.....							.				|
			move.w	d1,(a1)+		;	..... $xval as offset							.				|
;			move.w	#$4ed2,(a1)+	; jmp	(a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
.t_minus_i_lt0						;$diff < 0											.				|
.nextiter_y							;													,				|
			add.w	#128,a0			; empty												.				|
			addq.w	#1,d6			; $y++												.				|
			cmp.w	#20,d6			; $y<20												.				|
		bne	.loop_y					; <..................................................				|
		addq.w	#8,d0				;																	|
		addq.w	#1,d7				; $x++																|
		cmp.w	#20,d7				; $x<20																|
	bne	    .loop_x					; <-----------------------------------------------------------------/

	rts


;	or.w	d0,2(a0)				;8168 000x
;	or.w	d1,2(a0)				;8368 000x
;	move.w	d3,2(a0)				;3143 0002
;	and.w	d0,2(a0)				;C168 0002
;	and.w	d1,2(a0)				;C368 0002
;	and.w	d0,d1					;C240
;	or.w	d0,d1					;8240
;	dc.w	$51CC					;dbra d4

generateHDrawTable1bpl2
	move.l	drawTablePointer1bpl_scroll,a0
	move.l	a0,a5
	sub.l	#2,a5
	moveq	#0,d0					;$xbase=0
	moveq	#0,d1					;$xval
	moveq	#20,d2					;condition
	move.w	#$3143,d3								;move.w	d3,x(a0), stays
;	move.w	#$8368,d4								;or.w	d1,x(a0), becomes 	and.w	d1,x(a0)
	move.w	#$C368,d4

	lea		drawLineInitTemplate,a6
	REPT 10
		move.l	(a6)+,(a0)+
	ENDR
		move.w	(a6)+,(a0)

	move.l	drawTablePointer1bpl_scroll,a0
	move.l	a0,a2
	add.w	#128,a0


	moveq	#0,d7					;$x=0
.loop_x								;for($x=0;$x<20;$x++)-----------------------------------------------\
		move.w	d0,d1				;$xval = $xbase														|
		moveq	#0,d6				;$y=0																|
.loop_y								;for($y=0;$y<20;$t++)................................				|
			move.l	a0,a1			;													.				|
			cmp.w	d7,d6			;													.				|
			blt		.t_minus_i_lt0	;$diff < 0											.				|
			beq		.t_minus_i_eq0	;$diff == 0											.				|
.t_minus_i_gt0						;$diff > 1											.				|
			move.w	d0,d1			;													.				|
;			move.w	#$8168,(a1)+	; or.w	d0,x(a0)									.				|
			move.w	#$C168,(a1)+	;		replaced by and.w d0,x(a0)
			move.w	d1,(a1)+		;  x												.				|
			add.w	#8,d1			;													.				|
			move.w	d6,d5			;													.				|
			sub.w	d7,d5			;													.				|
			subq.w	#2,d5			;													.				|
			blt		.x				;													.				|
.move_w_loop						;													.				|
				move.w	d3,(a1)+	; move.w	d3,x(a0) with....						.				|
				move.w	d1,(a1)+	;	.... $xval as offset							.				|
				addq.w	#8,d1		;													.				|
			dbra	d5,.move_w_loop	;													.				|
.x									;													.				|
			move.w	d4,(a1)+		; or.w	d1,x(a0)	/  and.w d1,x(a0)				.				|
			move.w	d1,(a1)+		;													.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+	; dbra
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
									;													.				|
.t_minus_i_eq0						;$diff == 0	; only hit at first step 				.				|
			move.w	#$c240,(a1)+	; and.w d0,d1										.				|
;			move.w	#$8368,(a1)+	; or.w	d1,x(a0) with.....							.				|
			move.w	d4,(a1)+		; or.w	d1,x(a0) with.....							.				|
			move.w	d1,(a1)+		;	..... $xval as offset							.				|
;			move.w	#$4ed2,(a1)+	; jmp	(a2)										.				|
			move.l	#$41e800a0,(a1)+	; add.w 160 to smt
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
.t_minus_i_lt0						;$diff < 0											.				|
.nextiter_y							;													,				|
			add.w	#128,a0			; empty												.				|
			addq.w	#1,d6			; $y++												.				|
			cmp.w	#20,d6			; $y<20												.				|
		bne	.loop_y					; <..................................................				|
		addq.w	#8,d0				;																	|
		addq.w	#1,d7				; $x++																|
		cmp.w	#20,d7				; $x<20																|
	bne	    .loop_x					; <-----------------------------------------------------------------/

	rts


drawLineInitTemplate2
	move.w	(a5)+,d0					;8				;2		; get x_start
	move.w	(a6)+,d1					;8				;2		; get x_end
	and.w	d5,d0						;4				;2		; zero out lower 2 bits
	and.w	d5,d1						;4				;2		; zero out lower 2 bits
	add.w	d0,d0
	add.w	d1,d1
	move.l	d0,a1						;4				;2		; get address of xstart table
	move.l	d1,a2						;4				;2		; get address of xend table
	move.w	(a1)+,d2					;8				;2		; get offset xstart
	add.w	(a2)+,d2					;8				;2		; add offset xend
	move.l	(a1)+,d6					;8				;2		; get mask xstart
	move.l	(a2)+,d7					;8				;2		; get mask xend
	move.l	d2,a1						;4				;2		; use gotten offset for drawroutine
	jmp		(a1)						;8				;2		; jump to draw routine						;--> 28


; same as above, but using .l
; also, this should be using d6 and d7 instead of d0,d1
generateHDrawTable2bpl
	move.l	drawTablePointer2bpl_scroll,a0
	move.l	a0,a5
	sub.l	#2,a5
	moveq	#0,d0					;$xbase=0
	moveq	#0,d1					;$xval
	moveq	#20,d2					;condition
	move.w	#$2143,d3				; move.w	d3,x(a0)	-> move.l	d3,x(a0)
	move.w	#$8FA8,d4				; or.w		d1,x(a0)	-> or.l		d7,x(a0)
									; $8168		or.w	d0,x(a0) -> or.l d7,x(a0)
	lea		drawLineInitTemplate2,a6
	REPT 7
		move.l	(a6)+,(a0)+
	ENDR

	move.l	drawTablePointer2bpl_scroll,a0
	add.w	#128,a0

	moveq	#0,d7					;$x=0
.loop_x								;for($x=0;$x<20;$x++)-----------------------------------------------\
		move.w	d0,d1				;$xval = $xbase														|
		moveq	#0,d6				;$y=0																|
.loop_y								;for($y=0;$y<20;$t++)................................				|
			move.l	a0,a1			;													.				|
			cmp.w	d7,d6			;													.				|
			blt		.t_minus_i_lt0	;$diff < 0											.				|
			beq		.t_minus_i_eq0	;$diff == 0											.				|
.t_minus_i_gt0						;$diff > 1											.				|
			move.w	d0,d1			;													.				|
			move.w	#$8DA8,(a1)+	; or.l	d0,x(a0)									.				|
			move.w	d1,(a1)+		;  x												.				|
			add.w	#8,d1			;													.				|
			move.w	d6,d5			;													.				|
			sub.w	d7,d5			;													.				|
			subq.w	#2,d5			;													.				|
			blt		.x				;													.				|
.move_w_loop						;													.				|
;				move.w	#$2143,(a1)+; move.l	d3,x(a0) with....						.				|
				move.w	d3,(a1)+	; move.l	d3,x(a0) with....						.				|
				move.w	d1,(a1)+	;	.... $xval as offset							.				|
				addq.w	#8,d1		;													.				|
			dbra	d5,.move_w_loop	;													.				|
.x									;													.				|
;			move.w	#$8FA8,(a1)+	; or.l	d7,x(a0)									.				|
			move.w	d4,(a1)+		; or.l	d7,x(a0)									.				|
			move.w	d1,(a1)+		;													.				|
;			move.w	#$4ed2,(a1)+	;	jmp (a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
									;													.				|
.t_minus_i_eq0						;$diff == 0	; only hit at first step 				.				|
			move.w	#$CE86,(a1)+	; and.l d6,d7										.				|
;			move.w	#$8FA8,(a1)+	; or.l	d7,x(a0) with.....							.				|
			move.w	d4,(a1)+		; or.l	d7,x(a0) with.....							.				|
			move.w	d1,(a1)+		;	..... $xval as offset							.				|
;			move.w	#$4ed2,(a1)+	; jmp	(a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
.t_minus_i_lt0						;$diff < 0											.				|
.nextiter_y							;													,				|
			add.w	#128,a0			; empty												.				|
			addq.w	#1,d6			; $y++												.				|
			cmp.w	#20,d6			; $y<20												.				|
		bne	.loop_y					; <..................................................				|
		addq.w	#8,d0				;																	|
		addq.w	#1,d7				; $x++																|
		cmp.w	#20,d7				; $x<20																|
	bne	    .loop_x					; <-----------------------------------------------------------------/
	rts




;		or.l	d6,2(a0)				;	8DA8 0002
;		or.l	d7,2(a0)				;	8FA8 0002
;		move.l	d3,2(a0)				;	2143 000x
;		and.l	d6,2(a0)				;	CDA8 0002
;		and.l	d7,2(a0)				;	CFA8 000x
;		and.l	d6,d7					;	CE86
;		or.l	d6,d7					;	8E86

generateHDrawTable2bpl2
	move.l	drawTablePointer2bpl_scroll,a0
	move.l	a0,a5
	sub.l	#2,a5
	moveq	#0,d0					;$xbase=0
	moveq	#0,d1					;$xval
	moveq	#20,d2					;condition
	move.w	#$2143,d3				; move.l	d3,x(a0)
	move.w	#$CFA8,d4				; or.l		d7,x(a0)
	lea		drawLineInitTemplate2,a6
	REPT 7
		move.l	(a6)+,(a0)+
	ENDR

	move.l	drawTablePointer2bpl_scroll,a0
	add.w	#128,a0

	moveq	#0,d7					;$x=0
.loop_x								;for($x=0;$x<20;$x++)-----------------------------------------------\
		move.w	d0,d1				;$xval = $xbase														|
		moveq	#0,d6				;$y=0																|
.loop_y								;for($y=0;$y<20;$t++)................................				|
			move.l	a0,a1			;													.				|
			cmp.w	d7,d6			;													.				|
			blt		.t_minus_i_lt0	;$diff < 0											.				|
			beq		.t_minus_i_eq0	;$diff == 0											.				|
.t_minus_i_gt0						;$diff > 1											.				|
			move.w	d0,d1			;													.				|
			move.w	#$CDA8,(a1)+	; or.l	d0,x(a0)									.				|
			move.w	d1,(a1)+		;  x												.				|
			add.w	#8,d1			;													.				|
			move.w	d6,d5			;													.				|
			sub.w	d7,d5			;													.				|
			subq.w	#2,d5			;													.				|
			blt		.x				;													.				|
.move_w_loop						;													.				|
;				move.w	#$2143,(a1)+; move.l	d3,x(a0) with....						.				|
				move.w	d3,(a1)+	; move.l	d3,x(a0) with....						.				|
				move.w	d1,(a1)+	;	.... $xval as offset							.				|
				addq.w	#8,d1		;													.				|
			dbra	d5,.move_w_loop	;													.				|
.x									;													.				|
;			move.w	#$8FA8,(a1)+	; or.l	d7,x(a0)									.				|
			move.w	d4,(a1)+		; or.l	d7,x(a0)									.				|
			move.w	d1,(a1)+		;													.				|
;			move.w	#$4ed2,(a1)+	;	jmp (a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
									;													.				|
.t_minus_i_eq0						;$diff == 0	; only hit at first step 				.				|
			move.w	#$8E86,(a1)+	; and.l d6,d7										.				|
;			move.w	#$8FA8,(a1)+	; or.l	d7,x(a0) with.....							.				|
			move.w	d4,(a1)+		; or.l	d7,x(a0) with.....							.				|
			move.w	d1,(a1)+		;	..... $xval as offset							.				|
;			move.w	#$4ed2,(a1)+	; jmp	(a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+
			move.w	a4,(a1)+
			move.w	#$4e75,(a1)+
			jmp		.nextiter_y		;													.				|
.t_minus_i_lt0						;$diff < 0											.				|
.nextiter_y							;													,				|
			add.w	#128,a0			; empty												.				|
			addq.w	#1,d6			; $y++												.				|
			cmp.w	#20,d6			; $y<20												.				|
		bne	.loop_y					; <..................................................				|
		addq.w	#8,d0				;																	|
		addq.w	#1,d7				; $x++																|
		cmp.w	#20,d7				; $x<20																|
	bne	    .loop_x					; <-----------------------------------------------------------------/
	rts



generateStartX_scroll
	move.l	x_start_pointer_1bpl_scroll,a0
	move.l	a0,a2
	move.l	x_start_pointer_2bpl_scroll,a1
	move.l	a1,a3
	move.l	#20-1,d7

	move.l	#128,d0 		; val
	moveq	#0,d2

.ol
	moveq	#16-1,d6	; do 16 il
	moveq	#-1,d1		; %1111111111111111
.il
		move.w	d0,(a0)+	; val,
		move.w	d1,(a0)+	; mask

		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+

		lsr.w	#1,d1
	dbra	d6,.il
	add.w	#2560,d0
	dbra	d7,.ol

	rts


generateStartX2_scroll
	move.l	x_start_pointer_1bpl_scroll,a0
	move.l	a0,a2
	move.l	x_start_pointer_2bpl_scroll,a1
	move.l	a1,a3
	move.l	#20-1,d7

	move.l	#128,d0 		; val
	moveq	#0,d2

.ol
	moveq	#16-1,d6	; do 16 il
	moveq	#0,d1		; 
	move.w	#-1,d3		; %1111111111111111
.il
		move.w	d0,(a0)+	; val,
		move.w	d1,(a0)+	; mask

		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+
		roxr.w	d3
		roxr.w	d1
	dbra	d6,.il
	add.w	#2560,d0
	dbra	d7,.ol

	rts


;initEndX
;	move.l	x_end_pointer_1bpl,a0
;	lea		x_mask_offset_end,a1
;	move.l	#320-1,d7
;.do1
;		move.l	(a1)+,(a0)+
;	dbra	d7,.do1
;	rts

generateEndX_scroll
	move.l	x_end_pointer_1bpl_scroll,a0
	move.l	x_end_pointer_2bpl_scroll,a1

	move.l	#20-1,d7

	moveq	#0,d0
	moveq	#0,d2
.ol
	moveq	#16-1,d6
	move.w	#%1000000000000000,d1
.il
		move.w	d0,(a0)+
		move.w	d1,(a0)+

		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+

		asr.w	#1,d1
	dbra	d6,.il
	add.w	#128,d0
	dbra	d7,.ol
	rts


generateEndX2_scroll
	move.l	x_end_pointer_1bpl_scroll,a0
	move.l	x_end_pointer_2bpl_scroll,a1

	move.l	#20-1,d7

	moveq	#0,d0
	moveq	#0,d2
.ol
	moveq	#16-1,d6
	move.w	#%1000000000000000,d1
	not.w	d1
.il
		move.w	d0,(a0)+
		move.w	d1,(a0)+

		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+

		asr.w	#1,d1
	dbra	d6,.il
	add.w	#128,d0
	dbra	d7,.ol
	rts
fontstart				equ 	53


precalc_vbl
	pushall
    move.l	screenpointer,d0
    lsr.w	#8,d0
    move.l	d0,$ff8200
    addq    	#1,$466.w
	incSync

	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	screenpointer3,screenpointer2
	move.l	screenpointer4,screenpointer3
	move.l	screenpointer5,screenpointer4
	move.l	screenpointer6,screenpointer5
	move.l	screenpointer7,screenpointer6
	move.l	screenpointer8,screenpointer7
	move.l	d0,screenpointer8
	jsr		fixColors

	IFNE	playmusic
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC

    lea		timerb,a0
    move.w	(a0)+,d0
    move.l	a0,_timer_b_pointer

    lea		scrollertextpalette2,a0
    move.l	a0,_timer_b_font_pointer
    move.w	#fontstart,_fontcounter

    lea		scroller_text_timer_b,a0
    move.l	a0,_timer_b_lines_font_pointer


    move.l	colorpointer,a0
	move.w	(a0)+,$fff8242
	move.w	(a0)+,$fff8244
	move.w	(a0)+,$fff8246
	move.w	(a0)+,$fff824C
    move.l	a0,_timer_b_col_pointer



	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l  #raster_b,$120.w        ;Install our own Timer B
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

		jsr		drawBars
		jsr		advancePointer
		jsr		doStars
		raster	#$007		
   	popall
   	rte


precalc_vbl2
	pushall
    move.l	screenpointer,d0
    lsr.w	#8,d0
    move.l	d0,$ff8200
    addq    	#1,$466.w
	incSync

		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	screenpointer3,screenpointer2
		move.l	screenpointer4,screenpointer3
		move.l	screenpointer5,screenpointer4
		move.l	screenpointer6,screenpointer5
		move.l	screenpointer7,screenpointer6
		move.l	screenpointer8,screenpointer7
		move.l	d0,screenpointer8
		jsr		fixColors

		IFNE playmusic
			move.l	sndh_pointer,a0
			jsr		8(a0)
		ENDC

    lea		timerb,a0
    move.w	(a0)+,d0
    move.l	a0,_timer_b_pointer

    lea		scrollertextpalette2,a0
    move.l	a0,_timer_b_font_pointer
    move.w	#fontstart,_fontcounter

    lea		scroller_text_timer_b,a0
    move.l	a0,_timer_b_lines_font_pointer


    move.l	colorpointer,a0
	move.w	(a0)+,$fff8242
	move.w	(a0)+,$fff8244
	move.w	(a0)+,$fff8246
	move.w	(a0)+,$fff824C
    move.l	a0,_timer_b_col_pointer



	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l  #raster_b,$120.w        ;Install our own Timer B
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

		jsr		removeBars
		jsr		advancePointer

		jsr		doStars
		raster	#$007		
   	popall
   	rte


colorpointer			ds.l	1
colorpointer2			ds.l	1
colorpointer3			ds.l	1
colorpointer4			ds.l	1

_timer_b_pointer		ds.l	1
_timer_b_col_pointer	ds.l	1


code_vbl
	pushd0
	pusha0
    move.l	screenpointer,d0
    lsr.w	#8,d0
    move.l	d0,$ff8200
    addq    	#1,$466.w
	incSync

    jsr		fixColors

    IFNE	playmusic
	  	move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC

    lea		timerb,a0
    move.w	(a0)+,d0
    move.l	a0,_timer_b_pointer

    lea		scrollertextpalette2,a0
    move.l	a0,_timer_b_font_pointer
    move.w	#fontstart,_fontcounter

    lea		scroller_text_timer_b,a0
    move.l	a0,_timer_b_lines_font_pointer

    move.l	colorpointer,a0
	move.w	(a0)+,$fff8242
	move.w	(a0)+,$fff8244
	move.w	(a0)+,$fff8246
	move.w	(a0)+,$fff824C
    move.l	a0,_timer_b_col_pointer

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l  #raster_b,$120.w        ;Install our own Timer B
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popa0
   	popd0
    rte

raster_b
	pusha0
	pushd0

	move.l	_timer_b_col_pointer,a0
	move.w	(a0)+,$fff8242
	move.w	(a0)+,$fff8244
	move.w	(a0)+,$fff8246
	move.w	(a0)+,$fff824C

	move.l	a0,_timer_b_col_pointer

	move.l	_timer_b_pointer,a0
	move.w	(a0)+,d0
	move.l	a0,_timer_b_pointer

	clr.b	$fffffa1b.w			;Timer B control (stop)
	subq.w	#1,_fontcounter
	bne		.ok
		move.l	#raster_b2,$120.w
		move.w	#19,_fontcounter
.ok
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
	popa0
	rte

raster_b2
	pusha0
	pusha1
	pushd0
	move.l	_timer_b_font_pointer,a0
	lea		$ffff8240+2*8,a1
	move.l	(a0)+,d0

	move.l	d0,(a1)+		;8,9
	move.l	d0,(a1)+		;10,11
	move.w	d0,(a1)+		;12
	move.l	d0,(a1)+
	move.l	a0,_timer_b_font_pointer

	move.l	_timer_b_lines_font_pointer,a0
	move.w	(a0)+,d0
	move.l	a0,_timer_b_lines_font_pointer


	clr.b	$fffffa1b.w			;Timer B control (stop)
	subq.w	#1,_fontcounter
	bne		.ok
		move.l	#raster_b,$120.w
		move.b	#5,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		popd0
		popa1
		popa0
		rte
.ok
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	popa1
	popa0
	rte

_timer_b_lines_font_pointer	ds.l	1
_timer_b_font_pointer		ds.l	1	
_fontcounter				dc.w	40

widthval equ 40

rasterCounter	dc.w	6

fixColors
	subq.w	#1,rasterCounter
	bne		.done2	
		move.w	#8,rasterCounter
		move.l	colorpointer4,d0
		move.l	colorpointer3,colorpointer4
		move.l	colorpointer2,colorpointer3
		move.l	colorpointer,colorpointer2
		move.l	d0,colorpointer
.done2
	rts

_demoloopcounter	dc.l	1

drawTimes
	addq.l	#1,_demoloopcounter
	move.l	_demoloopcounter,d0

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	lea		numbers,a2
	lea		sublist,a4
	add.l	#190*160,a0
	add.l	#190*160,a1

	lea		numbers,a2
	add.w	#80,a2
	sub.w	(a4),a0
	sub.w	(a4)+,a1
o set 6
	REPT 8 
		move.b	(a2),o(a0)
		move.b	(a2)+,o(a1)
o set o+160
	ENDR

	move.w	#10,d7
	lea		numbers,a2

.loop
	divs	d7,d0
	move.l	d0,d1
	swap	d1

	add.w	d1,d1	;2
	add.w	d1,d1	;4
	add.w	d1,d1	;8
	lea		(a2,d1.w),a3
	sub.w	(a4),a0
	sub.w	(a4)+,a1

o set 6
	REPT 8
		move.b	(a3),o(a0)
		move.b	(a3)+,o(a1)
o set o+160

	ENDR
	ext.l	d0
	cmp.w	#0,d0
	bne		.loop
.end

	rts

;;;;;;;;;;;;;; SCROLLER END ;;;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER END ;;;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER END ;;;;;;;;;;;;

;;;;;;;;;;;;;; PICTURE START ;;;;;;;;;;;
;;;;;;;;;;;;;; PICTURE START ;;;;;;;;;;;
;;;;;;;;;;;;;; PICTURE START ;;;;;;;;;;;

palette equ modpic+2

doPicture
	; first move in normal vbl
	move.l	screenpointer2,$ffff8200
	move.w	#$2700,sr
	move.l	#picture_vbl,$70
	move.w	#$2300,sr
	wait_for_vbl

	moveq	#0,d0
	lea		$ffff8240,a0
	REPT 8
		move.l	d0,(a0)+
	ENDR

	lea		modpic+34,a0
	move.l	screenpointer2,a1
	move.l	#33-1,d7
.copy
o set 0
	REPT 20
		movem.l	(a0)+,d0-d6/a2-a6			; 6 blocks, 12*4 we need 20*200
		movem.l	d0-d6/a2-a6,o(a1)
o set o+12*4
	ENDR
	add.w	#20*12*4,a1
	dbra	d7,.copy
	; 320 bytes/ 80 longwords blocks left
	move.l	#6-1,d7
.copy2
		movem.l	(a0)+,d0-d6/a2-a6			; 12 blocks, 12*4 we need 20*200
		movem.l	d0-d6/a2-a6,(a1)
		add.w	#12*4,a1
	dbra	d7,.copy2
	; 6 * 12 = 72 done, 8 left

	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)
	; 33 * 960
	; 320 togo
	wait_for_vbl


	; added
	move.w	#0,vblcounter


.picloop
	wait_for_vbl
	subq.w	#1,_picture_waiter
	bne		.picloop
		addq.w	#4,_picture_effect_offset
		jsr		initC2PUneven
				exitOnSpace
		jsr		generate2pxTabs				;19 this generates the 2 px tabs, this way the tabs are set up that the source picture can be read
				exitOnSpace
		jsr		generateC2P
				exitOnSpace
		jsr		generateC2PCopy
				exitOnSpace
		move.w	#4,_picture_waiter

											;	56 frames done
	move.w	#0,vblcounter

; SO NORMALLY 200 FRAMES HERE

	move.w	#3-1,d6
.doderp
	addq.w	#4,_picture_effect_offset
	move.w	#50-1,d7								; 150
.waitframe
			wait_for_vbl
	dbra	d7,.waitframe
	move.w	#-1,_text1_done
	dbra	d6,.doderp

	wait_for_vbl
	nop
	wait_for_vbl

; 	move.w	#50+4*9-1,d7							; 86
;.ddd
;			wait_for_vbl
;	dbra	d7,.ddd


	move.w	#2-1,d6									;152,188,224
.doderp2
	addq.w	#4,_picture_effect_offset
	move.w	#0,_fadestep_add
	move.w	#36-1,d7								; 164
.waitframe2
			wait_for_vbl
	dbra	d7,.waitframe2
	dbra	d6,.doderp2


	addq.w	#4,_picture_effect_offset
	move.w	#0,_fadestep_add
	move.w	#18-1,d7								; 164
.waitframe2b
			wait_for_vbl
	dbra	d7,.waitframe2b


	addq.w	#4,_picture_effect_offset
	move.w	#0,_fadestep_add

	move.w	#14,d7
.waitframe3
			wait_for_vbl
	dbra	d7,.waitframe3


;	moveq	#0,d0
;	move.w	vblcounter,d0
;	move.b	#0,$ffffc123					; 256 total, before flash

;	move.w	#10,d7
;.www
;	wait_for_vbl
;	exitOnSpace
;	dbra	d7,.www


;	moveq	#0,d0
;	move.w	vblcounter,d0
;	move.b	#0,$ffffc123
	rts
;;;;;;;;;;;;;; PICTURE ROUTS ;;;;;;;;;;;
;;;;;;;;;;;;;; PICTURE ROUTS ;;;;;;;;;;;
;;;;;;;;;;;;;; PICTURE ROUTS ;;;;;;;;;;;
_picdone				dc.w	1
_picture_waiter			dc.w	10
_picture_effect_offset	dc.w	0
_fadestep				dc.w	0
_fade_in_done			dc.w	1	
_fade_out_done			dc.w	1
_text1_done				dc.w	1
_text2_done				dc.w	1
_text3_done				dc.w	1
_fadestep_add			dc.w	0
_fade_waiter			dc.w	5

picture_effectlist
	dc.l	picture_no_effect
	dc.l	picture_fade_in
	dc.l	picture_flash
	dc.l	picture_flash
	dc.l	picture_flash
	dc.l	picture_text1
	dc.l	picture_text2
	dc.l	picture_text3
	dc.l	picture_fade_out

picture_fade_palette

			;0		;1		;2		;3		;4		;5		;6		;7		;8		;9		;10		;11		;12		;13		;14		;15
	dc.w	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000		;0	0
	dc.w	$000,	$000,	$000,	$101,	$101,	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111,	$111		;1	32
	dc.w	$000,	$000,	$000,	$101,	$201,	$212,	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222,	$222		;2	64
	dc.w	$000,	$000,	$000,	$101,	$201,	$312,	$322,	$323,	$333,	$333,	$333,	$333,	$333,	$333,	$333,	$333		;3	96
	dc.w	$000,	$000,	$000,	$101,	$201,	$312,	$422,	$423,	$433,	$443,	$444,	$444,	$444,	$444,	$444,	$444		;4	128
	dc.w	$000,	$000,	$000,	$101,	$201,	$312,	$422,	$523,	$533,	$543,	$554,	$554,	$554,	$555,	$555,	$555		;5	160
	dc.w	$000,	$000,	$000,	$101,	$201,	$312,	$422,	$523,	$633,	$643,	$654,	$655,	$665,	$666,	$666,	$666		;6	192
	dc.w	$000,	$000,	$000,	$101,	$201,	$312,	$422,	$523,	$633,	$643,	$654,	$754,	$764,	$766,	$777,	$777		;7	224

	dc.w	$000,	$000,	$000,	$101,	$201,	$312,	$422,	$523,	$633,	$643,	$654,	$754,	$764,	$766,	$777,	$777		;7	224
	dc.w	$000,	$111,	$111,	$111,	$211,	$312,	$422,	$523,	$633,	$643,	$654,	$754,	$764,	$766,	$777,	$777		;9	256
	dc.w	$000,	$222,	$222,	$222,	$222,	$322,	$422,	$523,	$633,	$643,	$654,	$754,	$764,	$766,	$777,	$777		;10	256
	dc.w	$000,	$333,	$333,	$333,	$333,	$333,	$433,	$533,	$633,	$643,	$654,	$754,	$764,	$766,	$777,	$777		;11	288
	dc.w	$000,	$444,	$444,	$444,	$444,	$444,	$444,	$544,	$644,	$644,	$654,	$754,	$764,	$766,	$777,	$777		;12	320
	dc.w	$000,	$555,	$555,	$555,	$555,	$555,	$555,	$555,	$655,	$655,	$655,	$755,	$765,	$766,	$777,	$777		;13	352
	dc.w	$000,	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$666,	$766,	$766,	$766,	$777,	$777		;14	384
	dc.w	$000,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;15	416
	dc.w	$000,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777,	$777		;15	416



picture_text_y_off		equ 126
picture_text1_x_offset	equ 2*8
picture_text2_x_offset	equ 6*8
picture_text3_x_offset	equ 11*8

picture_text_height		equ 59

text1_off equ picture_text_y_off*160+picture_text1_x_offset
text2_off equ picture_text_y_off*160+picture_text2_x_offset
text3_off equ picture_text_y_off*160+picture_text3_x_offset

text1_start			equ	12
text1_height		equ	57
text2_start			equ	69
text2_height		equ	58
text3_start			equ	127
text3_height		equ	59
text_blocks_width	equ	11
_fade_waiter_amount	equ 1

picture_flash
	tst.w	_text1_done
	beq		.end
		tst.w	_fadestep_add
		bne		.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#2,_fade_waiter
			add.w	#32,_fadestep
			cmp.w	#32*15,_fadestep
			bne		.gogo
				move.w	#1,_fadestep_add		; and we have to back
				jmp		.gogo
.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#_fade_waiter_amount,_fade_waiter
			sub.w	#32,_fadestep
			cmp.w	#32*7,_fadestep
			bne		.gogo
				move.w	#0,_text1_done
				move.w	#0,_fadestep_add
.gogo
		lea		$ffff8240,a0
		lea		picture_fade_palette,a1
		add.w	_fadestep,a1
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
.end
	rts

picture_text1
	tst.w	_text1_done
	beq		.end
		tst.w	_fadestep_add
		bne		.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#_fade_waiter_amount,_fade_waiter
			add.w	#32,_fadestep
			cmp.w	#32*15,_fadestep
			bne		.gogo
				move.w	#1,_fadestep_add		; and we have to back
				;;;; also move in the 2nd part here
					; make code here
					move.l	screenpointer2,a0
					lea		modpic1a,a1
					add.w	#text1_off,a0

					move.l	#picture_text_height-1,d7
.ol
o set 0
						REPT 6
							move.l	(a1)+,o(a0)
							move.l	(a1)+,o+4(a0)
o set o+8
						ENDR
						add.w	#160,a0
						dbra	d7,.ol
				jmp		.gogo
.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#_fade_waiter_amount,_fade_waiter
			sub.w	#32,_fadestep
			cmp.w	#32*7,_fadestep
			bne		.gogo
				move.w	#0,_text1_done
				move.w	#0,_fadestep_add
.gogo
		lea		$ffff8240,a0
		lea		picture_fade_palette,a1
		add.w	_fadestep,a1
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
.end
	rts



picture_text2
	tst.w	_text2_done
	beq		.end
		tst.w	_fadestep_add
		bne		.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#_fade_waiter_amount,_fade_waiter
			add.w	#32,_fadestep
			cmp.w	#32*15,_fadestep
			bne		.gogo
				move.w	#1,_fadestep_add		; and we have to back
				;;;; also move in the 2nd part here
					; make code here
					move.l	screenpointer2,a0
					lea		modpic1b,a1
					add.w	#text2_off,a0
					move.l	#picture_text_height-1,d7
.ol
o set 0
						REPT 6
							move.l	(a1)+,o(a0)
							move.l	(a1)+,o+4(a0)
o set o+8
						ENDR
					add.w	#160,a0
					dbra	d7,.ol

				jmp		.gogo
.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#_fade_waiter_amount,_fade_waiter
			sub.w	#32,_fadestep
			cmp.w	#32*7,_fadestep
			bne		.gogo
				move.w	#0,_text2_done
				move.w	#0,_fadestep_add
.gogo
		lea		$ffff8240,a0
		lea		picture_fade_palette,a1
		add.w	_fadestep,a1
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
.end
	rts


picture_text3
;					move.b	#0,$ffffc123
;					move.l	#-1,a0
	tst.w	_text3_done
	beq		.end
		tst.w	_fadestep_add
		bne		.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#_fade_waiter_amount,_fade_waiter
			add.w	#32,_fadestep
			cmp.w	#32*15,_fadestep
			bne		.gogo
				move.w	#1,_fadestep_add		; and we have to back
				;;;; also move in the 2nd part here
					; make code here
					move.l	screenpointer2,a0
					lea		modpic1c,a1
					add.w	#text3_off,a0

					move.l	#picture_text_height-1,d7
.ol
o set 0
						REPT 7
							move.l	(a1)+,o(a0)
							move.l	(a1)+,o+4(a0)
o set o+8
						ENDR
					add.w	#160,a0
					dbra	d7,.ol

				jmp		.gogo
.fadestep_sub
			subq.w	#1,_fade_waiter	
			bne		.end
			move.w	#1,_fade_waiter
			sub.w	#32,_fadestep
			cmp.w	#32*7,_fadestep
			bne		.gogo
				move.w	#0,_text3_done
				move.w	#0,_fadestep_add
.gogo
		lea		$ffff8240,a0
		lea		picture_fade_palette,a1
		add.w	_fadestep,a1
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
.end
	rts

picture_fade_out
	tst.w	_fade_out_done
	beq		.end
		subq.w	#1,_fade_waiter	
		bne		.end
		move.w	#1,_fade_waiter

		add.w	#32,_fadestep
		cmp.w	#32*16,_fadestep
		bne		.notdone
			move.w	#0,_fade_out_done
			move.w	#0,_picdone
.notdone

		lea		$ffff8242,a0
		lea		picture_fade_palette,a1
		add.w	_fadestep,a1
		movem.l	(a1)+,d0-d7
		move.w	d0,(a0)+
		movem.l	d1-d7,(a0)
.end
	rts

picture_no_effect
	rts


picture_fade_in
	tst.w	_fade_in_done
	beq		.end
		subq.w	#1,_fade_waiter	
		bne		.end
		move.w	#6,_fade_waiter

		add.w	#32,_fadestep
		cmp.w	#32*7,_fadestep
		bne		.notdone
			move.w	#0,_fade_in_done
.notdone

		lea		$ffff8240,a0
		lea		picture_fade_palette,a1
		add.w	_fadestep,a1
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
.end
	rts


picture_vbl
	pushall
		addq.w		#1,$466.w
	incSync
	incSync
	lea		picture_effectlist,a0
	add.w	_picture_effect_offset,a0
	move.l	(a0),a0
	jsr		(a0)

;	pushd0
;	move.l	sndh_pointer,a0
;	moveq	#0,d0
;	move.b	$b8(a0),d0
;	beq		.ok
;		move.w	#$700,$ffff8240
;		move.b	#0,$b8(a0)
;		moveq	#0,d0
;		move.w	vblcounter,d0
;		move.b	#0,$ffffc123
;		jmp		.nocol
;.ok
;	move.w	#$000,$ffff8240
;.nocol
;	moveq	#0,d0
;	popd0


	move.l	sndh_pointer,a0
	jsr		8(a0)

	addq.w	#1,vblcounter

	popall
	rte
;;;;;;;;;;;;;; PICTURE END ;;;;;;;;;;;;;
;;;;;;;;;;;;;; PICTURE END ;;;;;;;;;;;;;
;;;;;;;;;;;;;; PICTURE END ;;;;;;;;;;;;;

	section data

modpic
	incbin	res/picture/modfinal.pi1
modpic1a
	incbin	res/picture/ftext1.bin
modpic1b
	incbin	res/picture/ftext2.bin
modpic1c
	incbin	res/picture/ftext3.bin

	ds.b	4000


;;;;;;;;;;;;;; SCROLLER DATA ;;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER DATA ;;;;;;;;;;;
;;;;;;;;;;;;;; SCROLLER DATA ;;;;;;;;;;;
scroller_text_timer_b
	dc.w	3,3,2,2,1,1,2,1,1,2,1,1,2,1,1,2,1,1

scrollertextpalette2
	dc.w $421,$421		;6	
	dc.w $522,$522		;1
	dc.w $421,$421		;1
	dc.w $522,$522		;2
	dc.w $623,$623		;1
	dc.w $421,$421		;1
	dc.w $522,$522		;2
	dc.w $623,$623		;1
	dc.w $522,$522		;1
	dc.w $623,$623		;2
	dc.w $733,$733		;1
	dc.w $623,$623		;1
	dc.w $733,$733		;2
	dc.w $743,$743		;1
	dc.w $733,$733		;1
	dc.w $743,$743		;2
	dc.w $763,$763		;1
	dc.w $743,$743		;1
	dc.w $763,$763		;3
	dc.w $0,$0


scrollertext
;	dc.b	"AAAHHHH[[[ THIS WAS EXACTLY WHAT WAS STILL LACKING[[[ A SCROLLER]]]  ^HI XIA^  SOOOOOOO[[[ HERE WE ARE MY FRIENDS FAR UP NORTHe DEEP INSIDE DHS TERRITORY AND WE HAVE TO SAYe ITS GOOD TO BE BACK"
;	dc.b	" AND SEE YOU ALL ONCE MORE[[[ IT REALLY HAS BEEN TOO LONG[[[                                                 "		
;	even


;	dc.b	"HERE WE AREe FAR UP NORTHe DEEP INSIDE DHS TERRITORY[[[[   IT HAS BEEN SO GREAT TO MAKE ANOTHER DEMO FOR IT TOGETHERe FAR BETTER THAN BEI"
;	dc.b	"NG A PASSIVE OBSERVER[[[[ SO GO CREATE SOMETHING YOURSELF[[[                                                 "
;	even


	dc.b	"HERE WE ARE[[[  FAR UP NORTH IN EUROPE[[[  DEEP INSIDE DHS TERRITORY[[[  IN CONTRARY TO BEING PASSIVE OBSERVERS WE HAD A GREAT TIME MAKING ANOTHER DEMO TOGETHER AND[[[  WE ARE NOT STOPPING HERE"
	dc.b	"[[[  THE DEMOSCENE IS NOW]]]]  SO GO CRAFT CONTRIBUTIONS[[[[[[                                               "
	even

outtrotext
	dc.b	"AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON"
	even


sublist
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
numbers	incbin	res/pulse/numbers2.bin
cred1	incbin	res/pulse/cred1.bin
cred2	incbin	res/pulse/cred2.bin
cred3	incbin	res/pulse/cred3.bin
cred4	incbin	res/pulse/cred4.bin

outtrotextend


timerb		include	res/scroller/timersb.s
			dc.w	0
col			include	res/scroller/col5.s
			even


spacebardist equ 10*4 
space	equ 3*4
stdoff	equ 19*4
characterWidthTable
	dc.w	23*4+space		;a
	dc.w	18*4+space		;b
	dc.w	18*4+space		;c
	dc.w	22*4+space		;d
	dc.w	14*4+space		;e
	dc.w	14*4+space		;f
	dc.w	20*4+space		;g
	dc.w	22*4+space		;h
	dc.w	6*4+space		;i
	dc.w	12*4+space		;j
	dc.w	21*4+space		;k
	dc.w	14*4+space		;l
	dc.w	26*4+space		;m
	dc.w	20*4+space		;n
	dc.w	29*4+space		;o
	dc.w	17*4+space		;p
	dc.w	29*4+space		;q
	dc.w	19*4+space		;r
	dc.w	16*4+space		;s
	dc.w	16*4+space		;t
	dc.w	20*4+space		;u
	dc.w	23*4+space		;v
	dc.w	29*4+space		;w
	dc.w	22*4+space		;x
	dc.w	21*4+space		;y
	dc.w	17*4+space		;z
	dc.w	7*4+space		;.		[
	dc.w	7*4+space		;:		\
	dc.w	8*4+space		;!		]
	dc.w	15*4+space		;-		^
	dc.w	stdoff+space	;0		_
	dc.w	12*4+space		;1		'
	dc.w	17*4+space		;2		a
	dc.w	20*4+space		;3		b
	dc.w	stdoff+space	;4		c
	dc.w	20*4+space		;5		d
	dc.w	7*4+space		;,		e

polygonlist
	include "res/scroller/f1.s"
	include "res/scroller/f3.s"
endptr

scrollerfont
	incbin	"res/scroller/font.bin"

o set -40
	REPT 5
		REPT 16
			dc.w	o
		ENDR
o 		set 	o+8
	ENDR
pixelToBlockOfffsetTable												;
o set 0
	REPT 30
		REPT 16
			dc.w	o
		ENDR
o 		set 	o+8
	ENDR


	REPT 20
o set 0
		REPT 16
			dc.w	o*(fontwidth+1)*2*fontheight
o set o+1
		ENDR
	ENDR
pixelToPreshiftOffsetTable												;1280
	REPT 20
o set 0
		REPT 16
			dc.w	o*(fontwidth+1)*2*fontheight
o set o+1
		ENDR
	ENDR


pixelblock					; 320 * 2 = 640
val set 0
	REPT 20
		REPT 16
			dc.w	val
			dc.w	val
		ENDR
val set val+8
	ENDR
val set 0
	REPT 20
		REPT 16
			dc.w	val
			dc.w	val
		ENDR
val set val+8
	ENDR

pixelmask
	REPT 20					; 320 * 4 = 1280
pixel set $8000
	REPT 16
		dc.w	pixel
		dc.w	pixel
pixel set pixel>>1
	ENDR
	ENDR
;;;;; 320-639
	REPT 20					; 320 * 4 = 1280
	REPT 16
		dc.w	0
		dc.w	0
	ENDR
	ENDR



pixelposlist	
	include	res/scroller/stars.s


frameoffsetmax equ	4*4
frameoffset	dc.w	0
;;;;;;;;;;;;;; SCROLLER DATA END ;;;;;;;
;;;;;;;;;;;;;; SCROLLER DATA END ;;;;;;;
;;;;;;;;;;;;;; SCROLLER DATA END ;;;;;;;

;;;;;;;;;;;;;; TUNNEL DATA ;;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL DATA ;;;;;;;;;;;;;
;;;;;;;;;;;;;; TUNNEL DATA ;;;;;;;;;;;;;
tunnelhole	
	incbin		res/c2p/tunnelhole.bin

stforever
	incbin		res/c2p/stforever.bin

tunnel_offsmap
	include		res/c2p/offsmaptest.s				;32kb

texture
	incbin		res/c2p/tunneltext.bin

;;;;;;;;;;;;;; RASTER GRID DATA ;;;;;;;;
;;;;;;;;;;;;;; RASTER GRID DATA ;;;;;;;;
;;;;;;;;;;;;;; RASTER GRID DATA ;;;;;;;;
colordraw
	REPT 6
	dc.l	drawLineColor1
	ENDR
	REPT 5
	dc.l	drawLineColor2
	ENDR
	REPT 5
	dc.l	drawLineColor3
	ENDR
	REPT 3
	dc.l	drawLineColor4
	ENDR
	REPT 3
	dc.l	drawLineColor5
	ENDR
	REPT 4
	dc.l	drawLineColor6
	ENDR
	REPT 5
	dc.l	drawLineColor7
	ENDR
	REPT 6
	dc.l	drawLineColor8
	ENDR


;	dc.w $777,$762,$640,$621,$422,$403,$202

gf7	equ $777
gf6 equ $762
gf5 equ $640
gf4 equ $621
gf3 equ $422
gf2 equ $403
gf1 equ $202

;	dc.w $570,$460,$450,$340,$240,$230,$120
;	dc.w $450,$350,$250,$240,$230,$130,$120
gb7	equ $570
gb6	equ	$460
gb5	equ $450
gb4	equ $340
gb3	equ $240
gb2	equ $230
gb1	equ $120

	; front
			;1		;2	  	;3		;4		;5		;6		;7		;8
	dc.w	gf7,	gf7,	gf7,	gf5,	gf1,	gf1,	gf1,	gf1			;15
	dc.w	gf7,	gf7,	gf7,	gf5,	gf1,	gf1,	gf1,	gf1			;15
	dc.w	gf7,	gf7,	gf7,	gf5,	gf1,	gf1,	gf1,	gf1			;14
	dc.w	gf7,	gf7,	gf7,	gf5,	gf1,	gf1,	gf1,	gf1			;14
	dc.w	gf7,	gf7,	gf7,	gf5,	gf2,	gf1,	gf1,	gf1			;13
	dc.w	gf7,	gf7,	gf7,	gf5,	gf2,	gf1,	gf1,	gf1			;13
	dc.w	gf7,	gf7,	gf7,	gf5,	gf2,	gf2,	gf1,	gf1			;12
	dc.w	gf7,	gf7,	gf7,	gf5,	gf2,	gf2,	gf1,	gf1			;12
	dc.w	gf7,	gf7,	gf7,	gf5,	gf3,	gf2,	gf2,	gf1			;11
	dc.w	gf7,	gf7,	gf7,	gf5,	gf3,	gf2,	gf2,	gf1			;11
	dc.w	gf7,	gf7,	gf7,	gf5,	gf3,	gf3,	gf2,	gf2			;10
	dc.w	gf7,	gf7,	gf7,	gf5,	gf3,	gf3,	gf2,	gf2			;10
	dc.w	gf7,	gf7,	gf7,	gf5,	gf4,	gf3,	gf3,	gf2			;9
	dc.w	gf7,	gf7,	gf7,	gf5,	gf4,	gf3,	gf3,	gf2			;9
	dc.w	gf7,	gf7,	gf7,	gf6,	gf4,	gf4,	gf3,	gf3			;8
	dc.w	gf7,	gf7,	gf7,	gf6,	gf4,	gf4,	gf3,	gf3			;8
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf4,	gf4,	gf3			;7
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf4,	gf4,	gf3			;7
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf5,	gf4,	gf4			;6
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf5,	gf4,	gf4			;6
	dc.w	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4			;5
	dc.w	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4			;5
	dc.w	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5			;4
	dc.w	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5			;4
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5			;3
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5			;3
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6			;2
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6			;2
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6			;1
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6			;1
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7			;0
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7			;0

gridColorSource	

			;1		;2	  	;3		;4		;5		;6		;7		;8
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7			;0
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7			;0
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6			;1
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6			;1
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6			;2
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6			;2
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5			;3
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5			;3
	dc.w	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5			;4
	dc.w	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5			;4
	dc.w	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4			;5
	dc.w	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4			;5
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf5,	gf4,	gf4			;6
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf5,	gf4,	gf4			;6
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf4,	gf4,	gf3			;7
	dc.w	gf7,	gf7,	gf7,	gf6,	gf5,	gf4,	gf4,	gf3			;7
	dc.w	gf7,	gf7,	gf7,	gf6,	gf4,	gf4,	gf3,	gf3			;8
	dc.w	gf7,	gf7,	gf7,	gf6,	gf4,	gf4,	gf3,	gf3			;8
	dc.w	gf7,	gf7,	gf7,	gf6,	gf4,	gf3,	gf3,	gf2			;9
	dc.w	gf7,	gf7,	gf7,	gf6,	gf4,	gf3,	gf3,	gf2			;9
	dc.w	gf7,	gf7,	gf7,	gf6,	gf3,	gf3,	gf2,	gf2			;10
	dc.w	gf7,	gf7,	gf7,	gf6,	gf3,	gf3,	gf2,	gf2			;10
	dc.w	gf7,	gf7,	gf7,	gf6,	gf3,	gf2,	gf2,	gf1			;11
	dc.w	gf7,	gf7,	gf7,	gf6,	gf3,	gf2,	gf2,	gf1			;11
	dc.w	gf7,	gf7,	gf7,	gf6,	gf2,	gf2,	gf1,	gf1			;12
	dc.w	gf7,	gf7,	gf7,	gf6,	gf2,	gf2,	gf1,	gf1			;12
	dc.w	gf7,	gf7,	gf7,	gf6,	gf2,	gf1,	gf1,	gf1			;13
	dc.w	gf7,	gf7,	gf7,	gf6,	gf2,	gf1,	gf1,	gf1			;13
	dc.w	gf7,	gf7,	gf7,	gf6,	gf1,	gf1,	gf1,	gf1			;14
	dc.w	gf7,	gf7,	gf7,	gf6,	gf1,	gf1,	gf1,	gf1			;14
	dc.w	gf7,	gf7,	gf7,	gf6,	gf1,	gf1,	gf1,	gf1			;14
	dc.w	gf7,	gf7,	gf7,	gf6,	gf1,	gf1,	gf1,	gf1			;15
	dc.w	gf7,	gf7,	gf7,	gf6,	gf1,	gf1,	gf1,	gf1			;15





	dc.w	gb3,	gb2,	gb2,	gb1,	gb6,	gb7,	gb7,	gb7			;15
	dc.w	gb3,	gb2,	gb2,	gb1,	gb6,	gb7,	gb7,	gb7			;15
	dc.w	gb3,	gb3,	gb2,	gb2,	gb6,	gb7,	gb7,	gb7			;14
	dc.w	gb3,	gb3,	gb2,	gb2,	gb6,	gb7,	gb7,	gb7			;14
	dc.w	gb4,	gb3,	gb3,	gb2,	gb5,	gb7,	gb7,	gb7			;13
	dc.w	gb4,	gb3,	gb3,	gb2,	gb5,	gb7,	gb7,	gb7			;13
	dc.w	gb4,	gb4,	gb3,	gb3,	gb5,	gb7,	gb7,	gb7			;12
	dc.w	gb4,	gb4,	gb3,	gb3,	gb5,	gb7,	gb7,	gb7			;12
	dc.w	gb5,	gb4,	gb4,	gb3,	gb5,	gb7,	gb7,	gb7			;11
	dc.w	gb5,	gb4,	gb4,	gb3,	gb5,	gb7,	gb7,	gb7			;11
	dc.w	gb5,	gb5,	gb4,	gb4,	gb5,	gb7,	gb7,	gb7			;10
	dc.w	gb5,	gb5,	gb4,	gb4,	gb5,	gb7,	gb7,	gb7			;10
	dc.w	gb6,	gb5,	gb5,	gb4,	gb5,	gb7,	gb7,	gb7			;9
	dc.w	gb6,	gb5,	gb5,	gb4,	gb5,	gb7,	gb7,	gb7			;9
	dc.w	gb6,	gb6,	gb5,	gb5,	gb5,	gb7,	gb7,	gb7			;8
	dc.w	gb6,	gb6,	gb5,	gb5,	gb4,	gb7,	gb7,	gb7			;8
	dc.w	gb7,	gb6,	gb6,	gb5,	gb5,	gb7,	gb7,	gb7			;7
	dc.w	gb7,	gb6,	gb6,	gb5,	gb5,	gb7,	gb7,	gb7			;7
	dc.w	gb6,	gb6,	gb5,	gb5,	gb5,	gb7,	gb7,	gb7			;8
	dc.w	gb7,	gb7,	gb6,	gb6,	gb5,	gb7,	gb7,	gb7			;6
	dc.w	gb7,	gb7,	gb6,	gb6,	gb5,	gb7,	gb7,	gb7			;6
	dc.w	gb7,	gb7,	gb7,	gb6,	gb6,	gb7,	gb7,	gb7			;5
	dc.w	gb7,	gb7,	gb7,	gb6,	gb6,	gb7,	gb7,	gb7			;5
	dc.w	gb7,	gb7,	gb7,	gb7,	gb6,	gb7,	gb7,	gb7			;4
	dc.w	gb7,	gb7,	gb7,	gb7,	gb6,	gb7,	gb7,	gb7			;4
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;3
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;3
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;2
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;2
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;1
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;1
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;0
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;0


			;1		;2	  	;3		;4		;5		;6		;7		;8
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;0
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7			;0
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb6			;1
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb6			;1
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb6,	gb6			;2
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb7,	gb6,	gb6			;2
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb6,	gb6,	gb5			;3
	dc.w	gb7,	gb7,	gb7,	gb7,	gb7,	gb6,	gb6,	gb5			;3
	dc.w	gb7,	gb7,	gb7,	gb7,	gb6,	gb6,	gb5,	gb5			;4
	dc.w	gb7,	gb7,	gb7,	gb7,	gb6,	gb6,	gb5,	gb5			;4
	dc.w	gb7,	gb7,	gb7,	gb6,	gb6,	gb5,	gb5,	gb4			;5
	dc.w	gb7,	gb7,	gb7,	gb6,	gb6,	gb5,	gb5,	gb4			;5
	dc.w	gb7,	gb7,	gb7,	gb6,	gb5,	gb5,	gb4,	gb4			;6
	dc.w	gb7,	gb7,	gb7,	gb6,	gb5,	gb5,	gb4,	gb4			;6
	dc.w	gb7,	gb7,	gb7,	gb6,	gb5,	gb4,	gb4,	gb3			;7
	dc.w	gb7,	gb7,	gb7,	gb6,	gb5,	gb4,	gb4,	gb3			;7
	dc.w	gb7,	gb7,	gb7,	gb6,	gb4,	gb4,	gb3,	gb3			;8
	dc.w	gb7,	gb7,	gb7,	gb6,	gb4,	gb4,	gb3,	gb3			;8
	dc.w	gb7,	gb7,	gb7,	gb6,	gb4,	gb3,	gb3,	gb2			;9
	dc.w	gb7,	gb7,	gb7,	gb6,	gb4,	gb3,	gb3,	gb2			;9
	dc.w	gb7,	gb7,	gb7,	gb6,	gb3,	gb3,	gb2,	gb2			;10
	dc.w	gb7,	gb7,	gb7,	gb6,	gb3,	gb3,	gb2,	gb2			;10
	dc.w	gb7,	gb7,	gb7,	gb6,	gb3,	gb2,	gb2,	gb1			;11
	dc.w	gb7,	gb7,	gb7,	gb6,	gb3,	gb2,	gb2,	gb1			;11
	dc.w	gb7,	gb7,	gb7,	gb6,	gb2,	gb2,	gb1,	gb1			;12
	dc.w	gb7,	gb7,	gb7,	gb6,	gb2,	gb2,	gb1,	gb1			;12
	dc.w	gb7,	gb7,	gb7,	gb6,	gb2,	gb1,	gb1,	gb1			;13
	dc.w	gb7,	gb7,	gb7,	gb6,	gb2,	gb1,	gb1,	gb1			;13
	dc.w	gb7,	gb7,	gb7,	gb6,	gb1,	gb1,	gb1,	gb1			;14
	dc.w	gb7,	gb7,	gb7,	gb6,	gb1,	gb1,	gb1,	gb1			;14
	dc.w	gb7,	gb7,	gb7,	gb6,	gb1,	gb1,	gb1,	gb1			;14
	dc.w	gb7,	gb7,	gb7,	gb6,	gb1,	gb1,	gb1,	gb1			;15
	dc.w	gb7,	gb7,	gb7,	gb6,	gb1,	gb1,	gb1,	gb1			;15




			;1		;2	  	;3		;4		;5		;6		;7		;8
	dc.w	gf3,	gf3,	gf3,	gf2,	gf1,	gf1,	gf1,	gf1			;15
	dc.w	gf3,	gf3,	gf3,	gf2,	gf1,	gf1,	gf1,	gf1			;15
	dc.w	gf3,	gf3,	gf3,	gf3,	gf1,	gf1,	gf1,	gf1			;14
	dc.w	gf3,	gf3,	gf3,	gf3,	gf1,	gf1,	gf1,	gf1			;14
	dc.w	gf4,	gf3,	gf3,	gf3,	gf2,	gf1,	gf1,	gf1			;13
	dc.w	gf4,	gf3,	gf3,	gf3,	gf2,	gf1,	gf1,	gf1			;13
	dc.w	gf4,	gf4,	gf3,	gf3,	gf2,	gf2,	gf1,	gf1			;12
	dc.w	gf4,	gf4,	gf3,	gf3,	gf2,	gf2,	gf1,	gf1			;12
	dc.w	gf5,	gf4,	gf4,	gf3,	gf3,	gf2,	gf2,	gf1			;11
	dc.w	gf5,	gf4,	gf4,	gf3,	gf3,	gf2,	gf2,	gf1			;11
	dc.w	gf5,	gf5,	gf4,	gf4,	gf3,	gf3,	gf2,	gf2			;10
	dc.w	gf5,	gf5,	gf4,	gf4,	gf3,	gf3,	gf2,	gf2			;10
	dc.w	gf6,	gf5,	gf5,	gf4,	gf4,	gf3,	gf3,	gf2			;9
	dc.w	gf6,	gf5,	gf5,	gf4,	gf4,	gf3,	gf3,	gf2			;9
	dc.w	gf6,	gf6,	gf5,	gf5,	gf4,	gf4,	gf3,	gf3			;8
	dc.w	gf6,	gf6,	gf5,	gf5,	gf4,	gf4,	gf3,	gf3			;8
	dc.w	gf7,	gf6,	gf6,	gf5,	gf5,	gf4,	gf4,	gf3			;7
	dc.w	gf7,	gf6,	gf6,	gf5,	gf5,	gf4,	gf4,	gf3			;7
	dc.w	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4,	gf4			;6
	dc.w	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4,	gf4			;6
	dc.w	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4			;5
	dc.w	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5,	gf4			;5
	dc.w	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5			;4
	dc.w	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5,	gf5			;4
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5			;3
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6,	gf5			;3
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6			;2
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6,	gf6			;2
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6			;1
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf6			;1
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7			;0
	dc.w	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7,	gf7			;0




;;;;;; this defines the 14 points our object is made of
coordsourceRasterGrid:																;6		4		1
x	set -160+4
	REPT 16
		dc.w	x,0,0
x set x+21
	ENDR


gridSteps	
x set 0-24*30
	rept 11
		dc.w	x
x set x+24
	endr

;;;;;;;;;;;;; RASTER GRID DATA END	
;;;;;;;;;;;;; RASTER GRID DATA END	
;;;;;;;;;;;;; RASTER GRID DATA END	


;;;;;;;;;;;;; METABALL DATA
;;;;;;;;;;;;; METABALL DATA
;;;;;;;;;;;;; METABALL DATA
meta1			incbin		res/c2p/m1.bin
meta2			incbin		res/c2p/m2a.bin
meta3			incbin		res/c2p/meta3.bin

ball128			include	res/c2p/metaball128b.txt
ball100			include	res/c2p/metaball100b.txt
ball46			include	res/c2p/metaball46.txt


; we are (first color is raster curtain)
	dc.w $111,$422,$532,$642,$652,$763,$773,$776,$664,$653,$543,$332,$222,$233,$555,$777
; still
	dc.w $111,$310,$420,$430,$530,$540,$640,$641,$650,$751,$762,$764,$774,$775,$777,$776
; here
	dc.w $111,$212,$312,$322,$421,$431,$531,$533,$542,$643,$654,$656,$666,$766,$767,$777


pal1fade

			;1	;2		;3	;4	;5	;6		;7	;8	;9	;10	 ;11	;12	;13	 ;14	;15  ;16
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;1
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$222,$111,$111,$111,$111,$111,$111,$111		;2

	dc.w	$000,$111,$111,$111,$111,$211,$221,$221,$222,$211,$111,$111,$111,$111,$111,$111		;3
	dc.w	$000,$111,$111,$111,$111,$311,$321,$321,$333,$311,$111,$111,$111,$111,$111,$111		;4
	
	dc.w	$000,$111,$111,$111,$211,$321,$331,$332,$333,$321,$221,$211,$111,$111,$111,$111		;5
	dc.w	$000,$111,$111,$111,$211,$421,$431,$432,$444,$421,$221,$211,$111,$111,$111,$111		;6
	
	dc.w	$000,$111,$111,$111,$321,$431,$441,$443,$444,$432,$331,$321,$211,$111,$111,$111		;7
	dc.w	$000,$111,$111,$111,$321,$531,$541,$543,$555,$532,$331,$321,$211,$111,$111,$111		;8
	
	dc.w	$000,$111,$111,$221,$431,$541,$551,$554,$555,$543,$442,$431,$321,$111,$111,$111		;9
	dc.w	$000,$111,$111,$221,$431,$641,$651,$654,$666,$643,$442,$431,$321,$111,$111,$111		;10
	
	dc.w	$000,$111,$211,$331,$541,$652,$662,$665,$777,$654,$553,$542,$432,$221,$111,$111		;11
	dc.w	$000,$111,$211,$331,$541,$752,$762,$765,$777,$754,$553,$542,$432,$221,$111,$111		;12

	dc.w	$000,$211,$322,$442,$652,$763,$773,$776,$777,$765,$664,$653,$543,$332,$222,$222		;13				;;;; ALTERED
	dc.w	$000,$211,$322,$442,$652,$763,$773,$776,$777,$765,$664,$653,$543,$332,$222,$222		;13				;;;; ALTERED
	
	dc.w	$000,$111,$211,$331,$541,$652,$662,$765,$777,$754,$653,$542,$432,$221,$111,$111		;12
	dc.w	$000,$111,$211,$331,$541,$652,$662,$665,$777,$654,$553,$542,$432,$221,$111,$111		;11

	dc.w	$000,$111,$111,$221,$431,$541,$551,$654,$766,$643,$542,$431,$321,$111,$111,$111		;9
	dc.w	$000,$111,$111,$221,$431,$541,$551,$554,$666,$543,$442,$431,$321,$111,$111,$111		;10

	dc.w	$000,$111,$111,$111,$321,$431,$441,$543,$655,$532,$431,$321,$211,$111,$111,$111		;7
	dc.w	$000,$111,$111,$111,$321,$431,$441,$443,$555,$432,$331,$321,$211,$111,$111,$111		;8

	dc.w	$000,$111,$111,$111,$211,$321,$331,$432,$544,$421,$321,$211,$111,$111,$111,$111		;5
	dc.w	$000,$111,$111,$111,$211,$321,$331,$332,$444,$321,$221,$211,$111,$111,$111,$111		;6

	dc.w	$000,$111,$111,$111,$111,$211,$221,$321,$433,$311,$211,$111,$111,$111,$111,$111		;3
	dc.w	$000,$111,$111,$111,$111,$211,$221,$221,$333,$211,$111,$111,$111,$111,$111,$111		;4

	dc.w	$000,$111,$111,$111,$111,$111,$111,$211,$322,$211,$211,$111,$111,$111,$111,$111		;1
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$222,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;1
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;1
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2


pal2fade



	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$222	;6

	dc.w	$000,$111,$111,$111,$111,$111,$111,$211,$222,$211,$211,$211,$211,$211,$221,$222	;7
	dc.w	$000,$111,$111,$111,$111,$111,$111,$311,$322,$311,$311,$211,$311,$311,$321,$333	;7

	dc.w	$000,$111,$111,$111,$111,$111,$211,$311,$322,$311,$311,$311,$311,$321,$332,$333 ;8
	dc.w	$000,$111,$111,$111,$111,$111,$211,$411,$422,$411,$311,$411,$411,$421,$432,$444 ;8

	dc.w	$000,$111,$111,$111,$111,$211,$310,$410,$422,$410,$421,$421,$421,$432,$443,$444	;9
	dc.w	$000,$111,$111,$111,$211,$211,$310,$510,$522,$510,$421,$521,$521,$532,$543,$555	;9

	dc.w	$000,$111,$111,$211,$211,$311,$410,$520,$522,$520,$531,$531,$532,$543,$554,$555	;10
	dc.w	$000,$111,$111,$211,$211,$311,$410,$620,$622,$620,$531,$631,$632,$643,$654,$666	;10

	dc.w	$000,$111,$112,$212,$311,$411,$521,$621,$622,$630,$641,$642,$643,$654,$665,$777	;11
	dc.w	$000,$111,$112,$212,$311,$411,$521,$622,$722,$730,$741,$742,$743,$754,$765,$777	;11

	dc.w	$000,$112,$212,$312,$412,$512,$522,$622,$632,$642,$652,$752,$762,$772,$776,$777
	dc.w	$000,$112,$212,$312,$412,$512,$522,$622,$632,$642,$652,$752,$762,$772,$776,$777

	dc.w 	$000,$111,$111,$211,$311,$411,$411,$511,$521,$531,$541,$641,$651,$661,$665,$666	;11 new
	dc.w 	$000,$111,$111,$211,$311,$411,$411,$511,$521,$531,$541,$641,$651,$661,$665,$666	;11 new

	dc.w 	$000,$111,$111,$111,$211,$311,$311,$411,$411,$421,$431,$531,$541,$551,$554,$555	;10 new
	dc.w 	$000,$111,$111,$111,$211,$311,$311,$411,$411,$421,$431,$531,$541,$551,$554,$555	;10 new

	dc.w 	$000,$111,$111,$111,$111,$211,$211,$311,$311,$311,$321,$421,$431,$441,$443,$444	;9 new
	dc.w 	$000,$111,$111,$111,$111,$211,$211,$311,$311,$311,$321,$421,$431,$441,$443,$444	;9 new

	dc.w 	$000,$111,$111,$111,$111,$111,$111,$211,$211,$211,$211,$311,$321,$331,$332,$333 ;8 new
	dc.w 	$000,$111,$111,$111,$111,$111,$111,$211,$211,$211,$211,$311,$321,$331,$332,$333 ;8 new

	dc.w 	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$211,$211,$221,$221,$222	;7 new
	dc.w 	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$211,$211,$221,$221,$222	;7 new

	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6 new
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6 new
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;6



pal3fade
			;1	;2		;3	;4	;5	;6		;7	;8	;9	;10	 ;11	;12	;13	 ;14	;15  ;16
	; Palette 1
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111
      ; Palette 2
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$211,$212,$222
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$211,$212,$222
      ; Palette 3
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$211,$211,$212,$222,$322,$323,$333
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$211,$211,$212,$222,$322,$323,$333
      ; Palette 4
      dc.w $000,$111,$111,$111,$111,$111,$211,$211,$211,$311,$321,$323,$333,$433,$434,$444
      dc.w $000,$111,$111,$111,$111,$111,$211,$211,$211,$311,$321,$323,$333,$433,$434,$444
      ; Palette 5
      dc.w $000,$111,$111,$111,$211,$211,$311,$311,$321,$421,$432,$434,$444,$544,$545,$555
      dc.w $000,$111,$111,$111,$211,$211,$311,$311,$321,$421,$432,$434,$444,$544,$545,$555
      ; Palette 6
      dc.w $000,$111,$211,$211,$311,$321,$421,$422,$431,$532,$543,$545,$555,$655,$656,$666
      dc.w $000,$111,$211,$211,$311,$321,$421,$422,$431,$532,$543,$545,$555,$655,$656,$666
      ; Palette 7
      dc.w $000,$211,$312,$321,$421,$431,$531,$533,$542,$643,$654,$656,$666,$766,$767,$777
      dc.w $000,$211,$312,$321,$421,$431,$531,$533,$542,$643,$654,$656,$666,$766,$767,$777
      dc.w $000,$211,$312,$321,$421,$431,$531,$533,$542,$643,$654,$656,$666,$766,$767,$777
      dc.w $000,$211,$312,$321,$421,$431,$531,$533,$542,$643,$654,$656,$666,$766,$767,$777

	;;;; bright to dark
      ; Palette 8
      dc.w $000,$111,$211,$211,$311,$321,$421,$422,$431,$532,$543,$545,$555,$655,$656,$666
      dc.w $000,$111,$211,$211,$311,$321,$421,$422,$431,$532,$543,$545,$555,$655,$656,$666
      ; Palette 9
      dc.w $000,$111,$111,$111,$211,$211,$311,$311,$321,$421,$432,$434,$444,$544,$545,$555
      dc.w $000,$111,$111,$111,$211,$211,$311,$311,$321,$421,$432,$434,$444,$544,$545,$555
      ; Palette 10
      dc.w $000,$111,$111,$111,$111,$111,$211,$211,$211,$311,$321,$323,$333,$433,$434,$444
      dc.w $000,$111,$111,$111,$111,$111,$211,$211,$211,$311,$321,$323,$333,$433,$434,$444
      ; Palette 11
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$211,$211,$212,$222,$322,$323,$333
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$211,$211,$212,$222,$322,$323,$333
      ; Palette 12
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$211,$212,$222
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$211,$212,$222
      ; Palette 13
      dc.w $000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111



	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111		;2

;;;;;;;;;;;;; END METABALL DATA
;;;;;;;;;;;;; END METABALL DATA
;;;;;;;;;;;;; END METABALL DATA

;;;;;;;;;;;;; DIAG DATA
;;;;;;;;;;;;; DIAG DATA
;;;;;;;;;;;;; DIAG DATA
diagCurrentPosition
o set 0
	REPT 15
		dc.w	o
o set o-8*3
	ENDR 
	dc.w		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

lll
	dc.l	draw1
	dc.l	draw2
	dc.l	draw3
	dc.l	draw4
	dc.l	draw5
	dc.l	draw6
	dc.l	draw7
	dc.l	draw8
	dc.l	draw9
	dc.l	draw10
	dc.l	draw11
	dc.l	draw12
	dc.l	draw13
	dc.l	draw14
	dc.l	draw15
	dc.l	draw16

diagFaceStart equ $233

diagFadeTable
	dc.w	$233		;0
	dc.w	$234		;1
	dc.w	$244		;2
	dc.w	$344		;3
	dc.w	$345		;4
	dc.w	$355		;5
	dc.w	$455		;6
	dc.w	$456		;7
	dc.w	$455		;8
	dc.w	$355		;9
	dc.w	$354		;10
	dc.w	$344		;11
	dc.w	$244		;12
	dc.w	$243		;13
	dc.w	$233		;14
	dc.w	$133		;15
	dc.w	$132		;16
	dc.w	$122		;17
	dc.w	$121		;18
	dc.w	$011		;19
	dc.w	$010		;20
	dc.w	$000		;21
	dc.w	$000		;21
	dc.w	$000		;21
	dc.w	$000		;21
	dc.w	$000		;21
	dc.w	$000		;21
	dc.w	$000		;21
	dc.w	$000		;21



diagPaletteList
	dc.l	$ffff8240+2*9
	dc.l	$ffff8240+2*12
	dc.l	$ffff8240+2*3
	dc.l	$ffff8240+2*10
	dc.l	$ffff8240+2*13
	dc.l	$ffff8240+2*11
	dc.l	$ffff8240+2*7
	dc.l	$ffff8240+2*14
	dc.l	$ffff8240+2*5
	dc.l	$ffff8240+2*6
	dc.l	$ffff8240+2*4
	dc.l	$ffff8240+2*2
	dc.l	$ffff8240+2*1

;	ds.b	1000

; some k
lineslist1bpl
	dc.l	draw1					;
		dc.w	8,0
	dc.l	draw2
		dc.w	8,15*8
	dc.l	draw3
		dc.w	8,14*8
	dc.l	draw4
		dc.w	8,13*8
	dc.l	draw5
		dc.w	8,12*8
	dc.l	draw6
		dc.w	8,11*8
	dc.l	draw7
		dc.w	8,10*8
	dc.l	draw8
		dc.w	8,9*8
	dc.l	draw9
		dc.w	9,8*8
	dc.l	draw10
		dc.w	9,7*8
	dc.l	draw11
		dc.w	9,6*8
	dc.l	draw12
		dc.w	9,5*8
	dc.l	draw13
		dc.w	9,4*8
	dc.l	draw14
		dc.w	9,3*8
	dc.l	draw15
		dc.w	9,2*8
	dc.l	draw16
		dc.w	9,1*8

diagpicture
	incbin		res/diag/diag2.pi1

;;;;;;;;;;;;; END DIAG DATA
;;;;;;;;;;;;; END DIAG DATA
;;;;;;;;;;;;; END DIAG DATA

;;;;;;;;;;;;; PULSE DATA
;;;;;;;;;;;;; PULSE DATA
;;;;;;;;;;;;; PULSE DATA

rastercounter		dc.w	5
barcounter			dc.w	7
rasterpointer		dc.l	0
rasteroffsetstart	dc.w	15*2
rasteroffset		dc.w	0

line1text	incbin	res/pulse/line1a.bin
line2text	incbin	res/pulse/line2a.bin
line3text	incbin	res/pulse/line3.bin
line4text	incbin	res/pulse/line4.bin

block1	incbin	res/pulse/pulse_block1.bin
block2	incbin	res/pulse/pulse_block2.bin
block3	incbin	res/pulse/pulse_block3.bin
block4	incbin	res/pulse/pulse_block4.bin
block5	incbin	res/pulse/pulse_block5.bin
block6	incbin	res/pulse/pulse_block6.bin
block7	incbin	res/pulse/pulse_block7.bin
block8	incbin	res/pulse/pulse_block8.bin

pulse_text_offset
	dc.w	0
pulse_color_direction
	dc.w	1
pulse_color_counter
	dc.w	0
pulse_color_list
			;8	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000	
	dc.w	$000		
	dc.w	$000	
	dc.w	$111	
	dc.w	$111	
	dc.w	$222	
	dc.w	$222		
	dc.w	$222	
	dc.w	$333	
	dc.w	$333	
	dc.w	$333	
	dc.w	$444	
	dc.w	$444	
	dc.w	$444	
	dc.w	$444	
	dc.w	$555	
	dc.w	$555	
	dc.w	$555	
	dc.w	$555	
	dc.w	$666	
	dc.w	$666	
	dc.w	$666		
	dc.w	$666	
	dc.w	$777	
	dc.w	$777	
	dc.w	$777	
	dc.w	$777	
	dc.w	$777	
	dc.w	$777	
	dc.w	$777			;	208-172 = 36


pulse_y_colors_list
			;4		;5		;6		;7		;8		;9		;10		;11		;12		;13		;14		;15
	dc.w	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000		;0
	dc.w	$100,	$100,	$000,	$100,	$001,	$001,	$000,	$000,	$000,	$111,	$000,	$100		;1
	dc.w	$100,	$110,	$000,	$110,	$002,	$001,	$100,	$000,	$000,	$222,	$000,	$211		;2
	dc.w	$200,	$211,	$100,	$210,	$012,	$102,	$101,	$001,	$010,	$333,	$000,	$322		;3
	dc.w	$210,	$311,	$100,	$310,	$112,	$103,	$201,	$002,	$020,	$444,	$000,	$544		;4
	dc.w	$211,	$321,	$200,	$311,	$113,	$104,	$211,	$012,	$021,	$555,	$111,	$644		;5
	dc.w	$311,	$322,	$210,	$421,	$123,	$114,	$212,	$112,	$121,	$666,	$111,	$654		;6
	dc.w	$311,	$322,	$211,	$521,	$223,	$214,	$212,	$112,	$121,	$777,	$111,	$655		;7

pulse_y_colors_list2
	dc.w	$000,$112
	dc.w	$111,$112
	dc.w	$222,$222
	dc.w	$333,$333
	dc.w	$444,$444
	dc.w	$555,$555
	dc.w	$666,$666
	dc.w	$777,$777

pulse_text_list
	dc.l	line0
	dc.l	line0
	dc.l	line0
	dc.l	line1
	dc.l	line2
	dc.l	line3
	dc.l	line4
	dc.l	line5

rasterList		
	dc.w	$233
	dc.w	$233
	dc.w	$233
	dc.w	$233
	dc.w	$233
	dc.w	$233
	dc.w	$233
	dc.w	$233
	dc.w	$223
	dc.w	$222
	dc.w	$122
	dc.w	$112
	dc.w	$111
	dc.w	$001
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	-1,-1
points
	include	res/sh15/ani4.s
	REPT 70
		dc.w	$000			; because we read a bit more than the poitns on screen....
	ENDR
	dc.w	-1,-1

outtropoints
	include	res/pulse/outtro2.s
	REPT 65
		dc.w	$000
	ENDR
	dc.w	-1,-1

flatline			include	res/sh15/flatline.s
	dc.w	-1,-1

pulseLogoNew		incbin	res/pulse/pulselogo.bin
bufferbottom		incbin	res/pulse/pulse_logo_bottom.bin							; move to somewhere		; incbinned							-72000

;;;;;;;;; END PULSE DATA
;;;;;;;;; END PULSE DATA
;;;;;;;;; END PULSE DATA

;;;;;;;;; DOTS DATA
;;;;;;;;; DOTS DATA
;;;;;;;;; DOTS DATA
addcounter
	dc.w	0

addlist
	dc.w	$000,$000	;9
	dc.w	$000,$000	;9
	dc.w	$111,$111	;10
	dc.w	$111,$111	;10
	dc.w	$121,$121	;11
	dc.w	$122,$122	;12
	dc.w	$122,$122	;12
	dc.w	$122,$122	;12
	dc.w	$112,$112	;12
	dc.w	$112,$112	;12
	dc.w	$000,$000	;18
	dc.w	$000,$000	;18
	dc.w	$000,$000	;18
	dc.w	$000,$000	;18
	dc.w	$000,$000	;18
	dc.w	$000,$000	;18
	dc.w	$000,$000	;18
	dc.w	$000,$000	;18


lc	dc.w	-20
go	dc.w	-1

dataoffset2		dc.l	800
bitPlaneFlag	dc.w	2
waitOneFrame	dc.w	-1
soffset1		dc.w	200
soffset2		dc.w	100

logosplit		incbin	res/dots/logosplit2.bin
dotspicpalette	dc.w	$111,$000,$765,$655,$553,$543,$434,$313,$777,$664,$554,$452,$442,$333,$212

dotspic	
				incbin	res/dots/dotspic.bin
				ds.b	40*160

sinedata		include res/dots/sinedata.s
				include res/dots/sinedata.s
				include res/dots/sinedata.s
xoffsetdata		include	res/dots/xoffset.s
				include	res/dots/xoffset.s

;front				equ $777
;middle				equ	$555
;back				equ	$333


colorList			
					dc.w	$000,	front,	back,	front,	middle,	front,	middle,	front	;16			;1 front	; bpl0 = front bpl2 = back bpl3 = middle
					dc.w	$000,	front,	back,	front,	middle,	front,	middle,	front	;32			;1 front	; bpl0 = front bpl2 = back bpl3 = middle
					dc.w	$000,	middle,	front,	front,	back,	middle,	front,	front	;48			;2 front	; bpl0 = middle bpl2 = front bpl3 = back
					dc.w	$000,	middle,	front,	front,	back,	middle,	front,	front	;64			;2 front	; bpl0 = middle bpl2 = front bpl3 = back
					dc.w	$000,	back,	middle,	middle,	front,	front,	front,	front	;80			;4 front	; bpl0 = back bpl2 = middle bpl3 = front
					dc.w	$000,	back,	middle,	middle,	front,	front,	front,	front	;96			;4 front	; bpl0 = back bpl2 = middle bpl3 = front
					dc.w	$000,	front,	back,	front,	middle,	front,	middle,	front	;112		;1 front	; bpl0 = front bpl2 = back bpl3 = middle


					dc.w	$000,	$666,	$222,	$666,	$444,	$666,	$444,	$666	;16			;1 $666	; bpl0 = $666 bpl2 = $222 bpl3 = $444
					dc.w	$000,	$666,	$222,	$666,	$444,	$666,	$444,	$666	;32			;1 $666	; bpl0 = $666 bpl2 = $222 bpl3 = $444
					dc.w	$000,	$444,	$666,	$666,	$222,	$444,	$666,	$666	;48			;2 $666	; bpl0 = $444 bpl2 = $666 bpl3 = $222
					dc.w	$000,	$444,	$666,	$666,	$222,	$444,	$666,	$666	;64			;2 $666	; bpl0 = $444 bpl2 = $666 bpl3 = $222
					dc.w	$000,	$222,	$444,	$444,	$666,	$666,	$666,	$666	;80			;4 $666	; bpl0 = $222 bpl2 = $444 bpl3 = $666
					dc.w	$000,	$222,	$444,	$444,	$666,	$666,	$666,	$666	;96			;4 $666	; bpl0 = $222 bpl2 = $444 bpl3 = $666
					dc.w	$000,	$666,	$222,	$666,	$444,	$666,	$444,	$666	;112		;1 $666	; bpl0 = $666 bpl2 = $222 bpl3 = $444


					dc.w	$000,	$555,	$111,	$555,	$333,	$555,	$333,	$555	;16			;1 $555	; bpl0 = $555 bpl2 = $111 bpl3 = $333
					dc.w	$000,	$555,	$111,	$555,	$333,	$555,	$333,	$555	;32			;1 $555	; bpl0 = $555 bpl2 = $111 bpl3 = $333
					dc.w	$000,	$333,	$555,	$555,	$111,	$333,	$555,	$555	;48			;2 $555	; bpl0 = $333 bpl2 = $555 bpl3 = $111
					dc.w	$000,	$333,	$555,	$555,	$111,	$333,	$555,	$555	;64			;2 $555	; bpl0 = $333 bpl2 = $555 bpl3 = $111
					dc.w	$000,	$111,	$333,	$333,	$555,	$555,	$555,	$555	;80			;4 $555	; bpl0 = $111 bpl2 = $333 bpl3 = $555
					dc.w	$000,	$111,	$333,	$333,	$555,	$555,	$555,	$555	;96			;4 $555	; bpl0 = $111 bpl2 = $333 bpl3 = $555
					dc.w	$000,	$555,	$111,	$555,	$333,	$555,	$333,	$555	;112		;1 $555	; bpl0 = $555 bpl2 = $111 bpl3 = $333


					dc.w	$000,	$444,	$111,	$444,	$222,	$444,	$222,	$444	;16			;1 $444	; bpl0 = $444 bpl2 = $111 bpl3 = $222
					dc.w	$000,	$444,	$111,	$444,	$222,	$444,	$222,	$444	;32			;1 $444	; bpl0 = $444 bpl2 = $111 bpl3 = $222
					dc.w	$000,	$222,	$444,	$444,	$111,	$222,	$444,	$444	;48			;2 $444	; bpl0 = $222 bpl2 = $444 bpl3 = $111
					dc.w	$000,	$222,	$444,	$444,	$111,	$222,	$444,	$444	;64			;2 $444	; bpl0 = $222 bpl2 = $444 bpl3 = $111
					dc.w	$000,	$111,	$222,	$222,	$444,	$444,	$444,	$444	;80			;4 $444	; bpl0 = $111 bpl2 = $222 bpl3 = $444
					dc.w	$000,	$111,	$222,	$222,	$444,	$444,	$444,	$444	;96			;4 $444	; bpl0 = $111 bpl2 = $222 bpl3 = $444
					dc.w	$000,	$444,	$111,	$444,	$222,	$444,	$222,	$444	;112		;1 $444	; bpl0 = $444 bpl2 = $111 bpl3 = $222


					dc.w	$000,	$333,	$111,	$333,	$111,	$333,	$111,	$333	;16			;1 $333	; bpl0 = $333 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$333,	$111,	$333,	$111,	$333,	$111,	$333	;32			;1 $333	; bpl0 = $333 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$333,	$333,	$111,	$111,	$333,	$333	;48			;2 $333	; bpl0 = $111 bpl2 = $333 bpl3 = $111
					dc.w	$000,	$111,	$333,	$333,	$111,	$111,	$333,	$333	;64			;2 $333	; bpl0 = $111 bpl2 = $333 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$333,	$333,	$333,	$333	;80			;4 $333	; bpl0 = $111 bpl2 = $111 bpl3 = $333
					dc.w	$000,	$111,	$111,	$111,	$333,	$333,	$333,	$333	;96			;4 $333	; bpl0 = $111 bpl2 = $111 bpl3 = $333
					dc.w	$000,	$333,	$111,	$333,	$111,	$333,	$111,	$333	;112		;1 $333	; bpl0 = $333 bpl2 = $111 bpl3 = $111


					dc.w	$000,	$222,	$111,	$222,	$111,	$222,	$111,	$222	;16			;1 $222	; bpl0 = $222 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$222,	$111,	$222,	$111,	$222,	$111,	$222	;32			;1 $222	; bpl0 = $222 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$222,	$222,	$111,	$111,	$222,	$222	;48			;2 $222	; bpl0 = $111 bpl2 = $222 bpl3 = $111
					dc.w	$000,	$111,	$222,	$222,	$111,	$111,	$222,	$222	;64			;2 $222	; bpl0 = $111 bpl2 = $222 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$222,	$222,	$222,	$222	;80			;4 $222	; bpl0 = $111 bpl2 = $111 bpl3 = $222
					dc.w	$000,	$111,	$111,	$111,	$222,	$222,	$222,	$222	;96			;4 $222	; bpl0 = $111 bpl2 = $111 bpl3 = $222
					dc.w	$000,	$222,	$111,	$222,	$111,	$222,	$111,	$222	;112		;1 $222	; bpl0 = $222 bpl2 = $111 bpl3 = $111

					dc.w	$000,	$111,	$111,	$111,	$111,	$111,	$111,	$111	;16			;1 $111	; bpl0 = $111 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$111,	$111,	$111,	$111	;32			;1 $111	; bpl0 = $111 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$111,	$111,	$111,	$111	;48			;2 $111	; bpl0 = $111 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$111,	$111,	$111,	$111	;64			;2 $111	; bpl0 = $111 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$111,	$111,	$111,	$111	;80			;4 $111	; bpl0 = $111 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$111,	$111,	$111,	$111	;96			;4 $111	; bpl0 = $111 bpl2 = $111 bpl3 = $111
					dc.w	$000,	$111,	$111,	$111,	$111,	$111,	$111,	$111	;112		;1 $111	; bpl0 = $111 bpl2 = $111 bpl3 = $111


oForSine
	include	res/dots/offsetForSine.s

listoffset
	dc.w	0

;;;;;;;;; END DOTS DATA
;;;;;;;;; END DOTS DATA
;;;;;;;;; END DOTS DATA

;;;;;;;;; START GREETINGS DATA
;;;;;;;;; START GREETINGS DATA
;;;;;;;;; START GREETINGS DATA
; 6 faces, , each 6 faces has 4 faces -> 24 faces
; each face has 3 edges
; 72 edges, each edge double used, 36 edges
; 
; 	0:	52
;	1:	8
;	2:	64
;	3:	28
;	4:	240
;	5:	56
;	6:	4
;	7:	76
;	8:	16
;	9:	192
;	10:	48
;	11:	12
;	12:	144
;	13:	96,
		

;;;;; currently we do not take into account visibility, and therefore ordering of the vertices
; however, we should assume that a certain order is in place
; WE ASSUME RIGHT HAND SIDE RULE, E.G. 
;
;
;	/   <-\
;	|	  |
;	\-----/  <--- this is the order of the vertices, which should be visible, so all the vertices are ordered this way that are visible, and clockwise 
; 					if not visible; --> https://www.udacity.com/course/viewer#!/c-cs291/l-90856897/m-97415606
;

sizeTab
;	include	res/polygon/resize.s
	include	res/polygon/resize5.s


; move this to lower memory
polyEdgesList2
	dc.l	c01,c02,c03,a04	
	dc.l	c17,c18,c19,a06
	dc.l	c11,c12,c09,a02
	dc.l	c05,c06,c07,a08	
	dc.l	c21,c22,c23,a01
	dc.l	c13,c14,c15,a04


;	p0		p1
;
;
;
;	p2		p3
;

;																			6		4		1
; NEGATIVE Z PLANE															---		---		----
;p0	dc.w	negsize,negsize,negsize	; (-1,-1,-1)	left,	top,	back	;0		0		0*s
;p1	dc.w	possize,negsize,negsize ; ( 1,-1,-1)	right,	top,	back	;6		4		1*s
;p2	dc.w	negsize,possize,negsize	; (-1, 1,-1)	left,	bottom,	back	;12		8		2*s
;p3	dc.w	possize,possize,negsize	; ( 1, 1,-1)	right,	bottom,	back	;18		12		3*s


; POSITIVE Z PLANE
;p5	dc.w	negsize,negsize,possize	; (-1,-1, 1)	left,	top,	front	;30		20		5*s
;p6	dc.w	possize,negsize,possize ; ( 1,-1, 1)	right,	top,	front	;36		24		6*s
;p7	dc.w	negsize,possize,possize	; (-1, 1, 1)	left, 	bottom,	front	;42		28		7*s
;p8	dc.w	possize,possize,possize	; ( 1, 1, 1)	right,	bototm,	front	;48		32		8*s


lineslist
a01		dc.w	0							; right hand side from front to back						; 2,4,4 structure = 16*10 = 160
		dc.l	projectedPolySource+4		;1	( 1,-1,-1)			right, down, back
		dc.l	projectedPolySource+12		;3	( 1, 1,-1)			right, up, back
a02		dc.w	0
		dc.l	projectedPolySource+12		;3	( 1, 1,-1)			right, up, back
		dc.l	projectedPolySource+28		;8	( 1, 1, 1)			right, up, front
a03		dc.w	0
		dc.l	projectedPolySource+28		;8	( 1, 1, 1)			right, up, front
		dc.l	projectedPolySource+20		;6	( 1,-1, 1)			right, down, front
a04		dc.w	0
		dc.l	projectedPolySource+20		;6	( 1,-1, 1)			right, down, front
		dc.l	projectedPolySource+4		;1	( 1,-1,-1)			right, down, back		

a05		dc.w	0							; left hand side from front to back
		dc.l	projectedPolySource+0		;0	(-1,-1,-1)			left, down, back
		dc.l	projectedPolySource+16		;5	(-1,-1, 1)			left, down, front
a06		dc.w	0
		dc.l	projectedPolySource+16		;5	(-1,-1, 1)			left, down, front
		dc.l	projectedPolySource+24		;7	(-1, 1, 1)			left, up, front
a07		dc.w	0
		dc.l	projectedPolySource+24		;7	(-1, 1, 1)			left, up, front
		dc.l	projectedPolySource+8		;2	(-1, 1,-1)			left, up, back
a08		dc.w	0
		dc.l	projectedPolySource+8		;2	(-1, 1,-1)			left, up, back
		dc.l	projectedPolySource			;0	(-1,-1,-1)			left, down, back

a09		dc.w	0							; top side, from front to back, left to right
		dc.l	projectedPolySource+24		;7	(-1, 1, 1)			left, up, front
		dc.l	projectedPolySource+28		;8	( 1, 1, 1)			right, up, front
a11		dc.w	0
		dc.l	projectedPolySource+12		;3	( 1, 1,-1)			left, up, back
		dc.l	projectedPolySource+8		;2	(-1, 1,-1)			right, up, back

a13		dc.w	0							; bottom side
		dc.l	projectedPolySource+20		;6	( 1,-1, 1)			right, down, front
		dc.l	projectedPolySource+16		;5	(-1,-1, 1)			left, down, front
a15		dc.w	0
		dc.l	projectedPolySource			;0	(-1,-1,-1)			left, down, back
		dc.l	projectedPolySource+4		;1	( 1,-1,-1)			right, down, back




linesList2

	; vertexprojection

; 1 - 6 - 8 - 3
c01
		dc.l	projectedPolySource+4		;1	( 1,-1,-1)			right, down, back
		dc.l	a01							; right hand side from front to back	
;		dc.l	projectedPolySource+12		;3	( 1, 1,-1)			right, up, back
c02	
		dc.l	projectedPolySource+12		;3	( 1, 1,-1)			right, up, back
		dc.l	a02
;		dc.l	projectedPolySource+28		;8	( 1, 1, 1)			right, up, front
c03
		dc.l	projectedPolySource+28		;8	( 1, 1, 1)			right, up, front
		dc.l	a03
;		dc.l	projectedPolySource+20		;6	( 1,-1, 1)			right, down, front
c04
		dc.l	projectedPolySource+20		;6	( 1,-1, 1)			right, down, front
		dc.l	a04
;		dc.l	projectedPolySource+4		;1	( 1,-1,-1)			right, down, back		
; 0 - 5 - 7 - 2
c05
		dc.l	projectedPolySource			;0	(-1,-1,-1)			left, down, back
		dc.l	a05							; left hand side from front to back
;		dc.l	projectedPolySource+16		;5	(-1,-1, 1)			left, down, front
c06
		dc.l	projectedPolySource+16		;5	(-1,-1, 1)			left, down, front
		dc.l	a06
;		dc.l	projectedPolySource+24		;7	(-1, 1, 1)			left, up, front
c07
		dc.l	projectedPolySource+24		;7	(-1, 1, 1)			left, up, front
		dc.l	a07
;		dc.l	projectedPolySource+8		;2	(-1, 1,-1)			left, up, back
c08
		dc.l	projectedPolySource+8		;2	(-1, 1,-1)			left, up, back
		dc.l	a08
;		dc.l	projectedPolySource			;0	(-1,-1,-1)			left, down, back
; 7 - 8 - 3 - 2
c09
		dc.l	projectedPolySource+24		;7	(-1, 1, 1)			left, up, front
		dc.l	a09							; top side, from front to back, left to right
;		dc.l	projectedPolySource+28		;8	( 1, 1, 1)			right, up, front
c10
		dc.l	projectedPolySource+28		;8	( 1, 1, 1)			right, up, front
		dc.l	a02;equ		c02
;		dc.l	projectedPolySource+12		;3	( 1, 1,-1)			right, up, back
c11
		dc.l	projectedPolySource+12		;3	( 1, 1,-1)			left, up, back
		dc.l	a11
;		dc.l	projectedPolySource+8		;2	(-1, 1,-1)			right, up, back
c12
		dc.l	projectedPolySource+8		;2	(-1, 1,-1)			left, up, front
		dc.l	a07;equ		c07
;		dc.l	projectedPolySource+24		;7	(-1, 1, 1)			left, up, back

c13
		dc.l	projectedPolySource+20		;6	( 1,-1, 1)			right, down, front
		dc.l	a13							; bottom side
;		dc.l	projectedPolySource+16		;5	(-1,-1, 1)			left, down, front
c14
		dc.l	projectedPolySource+16		;5	(-1,-1, 1)			left, down, front
		dc.l	a05;equ		c05
;		dc.l	projectedPolySource			;0	(-1,-1,-1)			left, down, back
c15
		dc.l	projectedPolySource			;0	(-1,-1,-1)			left, down, back
		dc.l	a15
;		dc.l	projectedPolySource+4		;1	( 1,-1,-1)			right, down, back
c16
		dc.l	projectedPolySource+4		;1	( 1,-1,-1)			right, down, back
;		dc.l	projectedPolySource+20		;6	( 1,-1, 1)			right, down, front
		dc.l	a04;equ		c04


c17
		dc.l	projectedPolySource+16		;5	(-1,-1, 1)	lo		left, down, front
		dc.l	a13	;equ		c13		;dc.w	0			; front side
;		dc.l	projectedPolySource+20		;6	( 1,-1, 1)	ro		right, down, front
c18
		dc.l	projectedPolySource+20		;6	( 1,-1, 1)	ro		right, down, front
		dc.l	a03	;equ		c03		;dc.w	0
;		dc.l	projectedPolySource+28		;8	( 1, 1, 1)	rb		right, up, front
c19
		dc.l	projectedPolySource+28		;8	( 1, 1, 1)	rb
		dc.l	a09	;equ		c09		;dc.w	0
;		dc.l	projectedPolySource+24		;3	(-1, 1, 1)	lb
c20
;		dc.l	projectedPolySource+24		;3	(-1, 1, 1)	lb
		dc.l	projectedPolySource+16		;5	(-1,-1, 1)	lo
		dc.l	a06	;equ		c06		;dc.w	0

; 5 - 6 - 1 - 0

c21
		dc.l	projectedPolySource+4		;1	( 1,-1,-1)	
		dc.l	a15	;equ		c15		;dc.w	0			; back side
;		dc.l	projectedPolySource			;0	(-1,-1,-1)	
c22
		dc.l	projectedPolySource			;0	(-1,-1,-1)	
		dc.l	a08	;equ		c08		;dc.w	0
;		dc.l	projectedPolySource+8		;7	(-1, 1,-1)	
c23
		dc.l	projectedPolySource+8		;7	(-1, 1,-1)		
		dc.l	a11	;equ		c11		;dc.w	0
;		dc.l	projectedPolySource+12		;3	( 1, 1,-1)
c24
		dc.l	projectedPolySource+12		;3	( 1, 1,-1)
		dc.l	a01	;equ		c01		;dc.w	0
;		dc.l	projectedPolySource+4		;1	( 1,-1,-1)

	; 52 = 0
	; 8 = 4
	; 64 = 8
	; 28 = 12
	; 56 = 16
	; 4 = 20
	; 76 = 24
	; 16 = 28

sintable:
;	include	res/polygon/sin_ampl_127_steps_256.s
	include	res/polygon/sin_ampl_127_steps_512.s


;;;;;; this defines the 14 points our object is made of
coordsource:																;6		4		1
; NEGATIVE Z PLANE															---		---		----
p0	dc.w	negsize,negsize,negsize	; (-1,-1,-1)	left,	top,	back	;0		0		0*s
p1	dc.w	possize,negsize,negsize ; ( 1,-1,-1)	right,	top,	back	;6		4		1*s
p2	dc.w	negsize,possize,negsize	; (-1, 1,-1)	left,	bottom,	back	;12		8		2*s
p3	dc.w	possize,possize,negsize	; ( 1, 1,-1)	right,	bottom,	back	;18		12		3*s
; POSITIVE Z PLANE
p5	dc.w	negsize,negsize,possize	; (-1,-1, 1)	left,	top,	front	;30		20		5*s
p6	dc.w	possize,negsize,possize ; ( 1,-1, 1)	right,	top,	front	;36		24		6*s
p7	dc.w	negsize,possize,possize	; (-1, 1, 1)	left, 	bottom,	front	;42		28		7*s
p8	dc.w	possize,possize,possize	; ( 1, 1, 1)	right,	bototm,	front	;48		32		8*s

lines:			include res/sh15/lines2.txt		; 10160		--> 46144
lines2:			include res/sh15/lines3.txt		; 10160		--> 46144

; explosion data
; explosion data
; explosion data
greetingsmove
	incbin	"res/cube/greetingsmove.bin"
	ds.b	640
greetings_source_pic:      
	incbin	"res/cube/greetings_source_pic.bin"                       
sprite_data_offset_for_greetings        DC.l    -40960*2



;;;;;;;;; END GREETINGS DATA
;;;;;;;;; END GREETINGS DATA
;;;;;;;;; END GREETINGS DATA

;;;;;;;;; START C2P DATA
;;;;;;;;; START C2P DATA
;;;;;;;;; START C2P DATA
angleTable		;		ds.b	2*2*FLD_XSIZE*FLD_YSIZE					; 128 * 128 * 4 = 65536
	incbin	res/c2p/arctan3.bin

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

overlay
	incbin	res/c2p/overlay2.bin

	even
tunnelpallette:
 	dc.w	$000,$110,$211,$331,$442,$352,$263,$573,$164,$154,$144,$134,$123,$011,$001,$000	;13

	dc.w	$000,$221,$321,$421,$521,$731,$742,$741,$731,$722,$512,$501,$401,$301,$201,$101	;0

	dc.w	$000,$776,$766,$765,$763,$763,$752,$741,$731,$722,$512,$501,$401,$301,$201,$100	;0

	include res/c2p/c2ppath3.txt
	include	res/c2p/c2ppath4.txt

;;;;;;;;;;; END C2P DATA
;;;;;;;;;;; END C2P DATA
;;;;;;;;;;; END C2P DATA

; rotation includes 
sintable1:		include	res/polygon/sin_ampl_127_steps_512.s
log_src:        incbin 	res/explog/LOG.TAB
exp_src:        incbin 	res/explog/EXP.TAB

;sprite_data_pointer					dc.l	sprite_data


;	IFNE playmusic
music:	
	incbin	msx/PULSE89.SND
	even
intromusic
	incbin	msx/PLSINT11.SND
	even
	ds.b	200

	include	asm/lib.s

	even

	section bss
demo_exit							ds.w	1
screenpointer						ds.l	1
screenpointer2						ds.l	1
screenpointershifter				ds.l	1
screenpointer2shifter				ds.l	1
screen1:							ds.b	65536+65536
screen2:							ds.b	65536
align1:								ds.b	65536
align2:								ds.b	65536
align3:								ds.b	65536
align4:								ds.b	65536
align5:								ds.b	65536
align6:								ds.b	65536
align7:								ds.b	65536
align8:								ds.b	65536
align9:								ds.b	65536
align10:							ds.b	65536
align11:							ds.b	65536
align12:							ds.b	65536
alignpointer1						ds.l	1
alignpointer2						ds.l	1
alignpointer3						ds.l	1
alignpointer4						ds.l	1
alignpointer5						ds.l	1
alignpointer6						ds.l	1	
alignpointer7						ds.l	1	
alignpointer8						ds.l	1	
alignpointer9						ds.l	1	
alignpointer10						ds.l	1	
alignpointer11						ds.l	1	
alignpointer12						ds.l	1	
; lookup
;	DOTS										POLY							SCROLLER IST:			scroller soll:
;																				a:	screenpointer1		screenpointer1,screenpointer3		(need to set at initrout)
;																				b;  screenpointer2		screenpointer2,screenpointer4		(initblocks)
;	1: 	y_block_pointer							;1:	y_block_pointer				1:	y_block_pointer		y_block_pointer, lots of free space
;	2:	x_block_add_pointer						;2:	x_block_add_pointer			2:						x_start_pointer_1bpl_scroll,screenpointer5
;	3:	logpointer								;3:	logpointer					3:						x_start_pointer_2bpl_scroll,screenpointer6
;	4:	savedTable_pointer						;4:	zpointer					4:						x_end_pointer_1bpl_scroll,screenpointer7
;	5:	savedTable_pointer						;5:	divtablepointer				5:						x_end_pointer_2bpl_scroll,screenpointer8
;	6:	savedTable_pointer						;6:	sprite_data_pointer			6:						drawTablePointer1bpl_scroll
;	7:	savedTable_pointer						;7:								7:						drawTablePointer2bpl_scroll
;	8:	savedTable_pointer						;8:								8:						preshiftFontPointer
;	9:	savedTable_pointer						;9:	
;	10:	savedTable_pointer (first 25600)		;10:
;	11:	exppointer								;11:exppointer

	IFNE synccounter
_synccounter		ds.w	1
	ENDC


; general stuff
; general stuff
; general stuff
oldLower							ds.b	$a000
									ds.l	10
vblcounter							ds.w	1
									ds.l	10

; diag trans
; diag trans
; diag trans

draw1								ds.b	900		;14400	+ 4160 = 18560
draw2								ds.b	900
draw3								ds.b	900
draw4								ds.b	900
draw5								ds.b	900
draw6								ds.b	900
draw7								ds.b	900
draw8								ds.b	900
draw9								ds.b	900
draw10								ds.b	900
draw11								ds.b	900
draw12								ds.b	900
draw13								ds.b	900
draw14								ds.b	900
draw15								ds.b	900
draw16								ds.b	900
			
diagLinePointer						ds.l	1			;4160
copy4BLPointer						ds.l	1			;10674
	
; pulse effect
; pulse effect
; pulse effect
y_block_pointer						ds.l	1

;y_block_pointer						equ		alignpointer1
x_block_add_pointer					equ		alignpointer2
colorListOffset						ds.w	1
currentPointAddress					ds.l	1
pointOffset							ds.w	1
itercount							ds.w	1
pulse_text_counter					ds.w	1

; grid trans effect
x_start_pointer_1bpl				ds.l	1				;1280
x_end_pointer_1bpl					ds.l	1				;1280

projectedPolySourcePointer			ds.l	1
grid_color_pointer					ds.l	1
grid_colors							ds.w	12*8
stepPointer							ds.l	1


; metaballs effect
; metaballs effect
; metaballs effect
fadecounter							ds.w	1
fadepointer							ds.l	1
c2poffset1							ds.w	1
c2poffset2							ds.w	1
c2poffset3							ds.w	1
c2p_x_off							ds.w	1
c2ppathpointer1						ds.l	1
c2ppathpointer2						ds.l	1
c2ppathpointer3						ds.l	1
offset1								ds.w 	1
offset2								ds.w 	1
offset3								ds.w 	1
offset1step							ds.w	1
offset2step							ds.w	1
offset3step							ds.w	1

; dots effect
; dots effect
; dots effect
logpointer							equ 	alignpointer3
savedTable_pointer					equ 	alignpointer4			; spans 7: 4,5,6,7,8,9,10 (38400 left, so pointer10 + 25600)
tableSourcePointer					ds.l	1
clearScreen1bplPointer				ds.l	1
;tableSource						ds.b	6400*4	;25600		; should move to temp memory hole	; pointer10 + 25600
;clearScreen1bpl					ds.b	8542				; this should be moved				; pointer10 + 25600
dotsLoopPointer						ds.l	1
;dotsLoop							ds.b	16074				; should move to temp memory hole	; pointer10 + 25600+8542

saveOffset							ds.l	1
;savedTable							ds.b	409600				; should move to temp contigous memory
dataoffset							ds.l	1
colorOffset							ds.w	1
colorOffset2						ds.w	1
xoffsetcounter						ds.w	1
sdata								ds.b	100*4
sdata2								ds.b	100*4

; rotation stuf
currentStepX            			equ		_currentStepX
currentStepY            			equ		_currentStepY
currentStepZ            			equ		_currentStepZ
stepSpeedX              			equ		_stepSpeedX
stepSpeedY              			equ		_stepSpeedY
stepSpeedZ              			equ		_stepSpeedZ
vertices_xoff						ds.w	1	
vertices_yoff						ds.w	1		
; source
currentObjectPointer:				ds.l	1
cubeObjectPointer					ds.l	1


number_of_vertices					ds.w	1
number_of_polygons					ds.w	1
vertexloc_pointer					ds.l	1
vertexloc2_pointer					ds.l	1
projectedPolySource					ds.w	200

vertexprojection2_pointer			ds.l	1
; tunnel
; tunnel
; tunnel
generatedCodeWholePointer			ds.l	1					;80002
generatedCodePointer				ds.l	1					;26402
generatedCode2Pointer				ds.l	1					;27202
generatedCode3Pointer				ds.l	1					;26402

planartexturepointer1				ds.l	1					;49152
planartexturepointer2				ds.l	1					;49152
planartexturepointer3				ds.l	1					;49152
planartexturepointer4				ds.l	1					;49152
c2pCopyPointerTunnel				ds.l	1

; greetings
; greetings
; greetings
xpos_splitted_pointer   			equ 	alignpointer2		;1280
sprite_data_pointer					equ		alignpointer6		
	
clearSpritesCodePointer 			ds.l    1					;5442 
showSpriteCodePointer   			ds.l    1														;10562
active_sprite_list_pointer			ds.l	1
sprite_startpos_pointer				ds.l	1
dellist_adr1:   					DS.L 	1
dellist_adr2:   					DS.L 	1
delete_list1:   					DS.L 	20*4       ; 18*4*4 =      288                        ; adjust to number of active sprites!
delete_list2:   					DS.L 	20*4       ;               288     
no_of_sprites:  					DS.W 	1

zpointer							equ		alignpointer4			; first 512 and last 512 bytes used: 65536 - 1024 = 64512 (pointer+512)
expointernorm						equ		alignpointer12
divtablepointer						equ		alignpointer5
cubeScreenOffset					ds.w	1	; 96616
cube_colorValues					ds.l	16
									ds.w	1
greetingsOffset						ds.w	1
									ds.w	1
checkerBlockRemove					ds.w	1

; POLYGON POINTERS
pointer_10_10						ds.l	1		;1280
pointer_10_12_pos					ds.l	1		;1280
pointer_10_12_neg					ds.l	1		;1280
pointer_12_12						ds.l	1		;1280
pointer_12_14_pos					ds.l	1		;1280
pointer_12_14_neg					ds.l	1		;1280
pointer_14_14						ds.l	1		;1280
pointer_14_16_pos2					ds.l	1		;1280
pointer_14_16_neg2					ds.l	1		;1280
pointer_16_16						ds.l	1		;1280
pointer_16_18_pos					ds.l	1		;1280
pointer_16_18_neg					ds.l	1		;1280

pointer_lines_no_add_neg			ds.l	1		;1458
pointer_lines_no_add_pos			ds.l	1		;1458
pointer_lines_with_add_neg			ds.l	1		;1728
pointer_lines_with_add				ds.l	1		;1728
pointer_lines_no_add_neg_2lines		ds.l	1		;2034
pointer_lines_no_add_pos_2lines		ds.l	1		;2034
pointer_lines_with_add_2lines		ds.l	1		;2304
pointer_lines_with_add_neg_2lines	ds.l	1		;2304

clearScreenPointer					ds.l	1		;7202
eorFillPointer						ds.l	1		;14402
clearScreenPointer2					ds.l	1		;4226f
eorFillPointer2						ds.l	1		;8450

;;; C2p stuff
screenpointer3						ds.l	1	; alignpointer1
tab2px_1p							equ		alignpointer2
tab2px_2p							equ		alignpointer3
angleTable2Pointer					equ		alignpointer4
angleTable3Pointer					equ		alignpointer5
angleTable4Pointer					equ		alignpointer6

at1									ds.l	1
at2									ds.l	1
c2pRoutPointer						ds.l	1
c2pCopyPointer						ds.l	1

;;;;;;;;;;;;;;;; SCROLLER POINTERS
x_start_pointer_1bpl_scroll			equ		alignpointer2
x_start_pointer_2bpl_scroll			equ		alignpointer3
x_end_pointer_1bpl_scroll			equ		alignpointer4
x_end_pointer_2bpl_scroll			equ		alignpointer5
drawTablePointer1bpl_scroll			equ		alignpointer6
drawTablePointer2bpl_scroll			equ		alignpointer7
preshiftFontPointer					equ		alignpointer8

polygonLeft							ds.l	34
polygonRight						ds.l	34
screenpointer4						ds.l	1
screenpointer5						ds.l	1
screenpointer6						ds.l	1
screenpointer7						ds.l	1
screenpointer8						ds.l	1
buildListAddPointer					ds.l	1
buildListSubPointer					ds.l	1
starLocs							ds.l	1
starLocs2							ds.l	1
starLocs3							ds.l	1
starLocs4							ds.l	1
starLocs5							ds.l	1
starLocs6							ds.l	1
starLocs7							ds.l	1
starLocs8							ds.l	1


even

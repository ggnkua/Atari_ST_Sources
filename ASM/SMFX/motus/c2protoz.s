

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
SHOW_CPU			equ	0
USE_MYM_DUMP		equ 0


ROTO_EFFECT_VBL					equ 20*50-36-40		; special case, this one is in vbls																6647
ROTO_PANEL_IN_WAIT_VBL			equ 5				; number of frames delay before panel comes in
ROTO_PANEL_OUT_VBL				equ 760
ROTO_UNDERLINE_WAIT				equ 470		
C2P_ROTOZ_TEXTURE_FROM_PLANAR	equ 1
CHECK_VBL_OVERFLOW				equ 0
	ELSE
C2P_ROTOZ_TEXTURE_FROM_PLANAR	equ 1
	ENDC


ZOOMPAL	equ 0

fontpixels_drawn_per_effect_frame	equ 30*8
effect_frames_before_credits_start	equ 64
effect_fames_draw_credits			equ 68
effect_frames_display_credits		equ 28	;96
effect_frames_between_credits		equ 32	;100


sintable_length				equ	2048
sintable_size				equ	2048*2


viewport_width_blocks		equ 12
viewport_height_lines		equ 96


	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	TEXT
;    opt o-

	include macro.s


	IFEQ	STANDALONE
			initAndRun	standalone_init

standalone_init


	jsr		init_effect
	jsr		init_rotozoom
.x
	
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts
init_effect
;	move.w	#$222,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts

	ENDC






init_rotozoom
;	jsr		prepPanel
	move.l	screen1,d0
	move.l	d0,screenpointer
		move.l	d0,d1

	move.l	screen2,d0
		move.l	d0,screenpointer2
		move.l	d0,d1
		add.l	#$9000+9216,d1
		move.l	d1,doublescanlinespointer
		move.l	d1,chunkytextpointer
		add.l	#3500,d1
		move.l	d1,rotosmcpointer
		add.l	#1586,d1
		move.l	d1,ul3ptr
		add.l	#3360,d1



		move.l	d1,updateTexturePointer

	add.l	#$10000,d0
    move.l  d0,c2plookuptablepointer			;4
    add.l   #$40000,d0
    move.l  d0,text1pointer						;6
    add.l   #$20000,d0
    move.l  d0,text2pointer						;8				---> 524288 512kb
    add.l	#$20000,d0
    move.l	d0,panel4Pointer

	IFEQ	STANDALONE
    move.w  #$2700,sr
    move.l  #.wvbl,$70
    move.w  #$2300,sr
    ENDC
	jsr		generateC2PLookupTable

	; this is only for development purposes
	IFEQ	C2P_ROTOZ_TEXTURE_FROM_PLANAR
		lea		planarpic+128,a0
		move.l	chunkytextpointer,a1
		jsr		planarToChunkyRoto
	ELSE
		lea		texture,a0
		move.l	chunkytextpointer,a1
		jsr		cranker
	ENDC
	; end development purposes

	lea		panelroto,a0
	move.l	panel4Pointer,a1
	jsr		cranker
	

	jsr		generateTextureTables

	jsr		generateDoubleScanlines
	jsr		generateRotoCode
	jsr		preShiftPlasmaBar
;	jsr		generateUpdateTexture

   	lea		ul3,a0
   	move.l	ul3ptr,a1
   	jsr		cranker


	IFEQ	STANDALONE
	movem.l	moveBarPal2,d0-d7
	ELSE
	movem.l	flash3pal,d0-d7
	ENDC
	movem.l	d0-d7,rotozpal

	move.w	#ROTO_UNDERLINE_WAIT,tbwait
	IFNE	STANDALONE
	move.w	#180-6,tboc3framewait
	ENDC
	move.w	#2,botTimes

;	movem.l	planarpic+4,d0-d7
;	movem.l	d0-d7,$ffff8240


;	lea		routListTab,a0
;	moveq	#40,d0
;	REPT 18
;	move.w	d0,(a0)+
;	addq.w	#4,d0
;	ENDR
;	move.w	#$4e71,removePanelLamelsVoxel
;	move.w	#1,flipVoxel

;	moveq	#0,d0
;	move.w	$466.w,d0
;	move.b	#0,$ffffc123

    move.w  #0,$466
.www
	tst.w   $466.w
    beq     .www
    move.w	#0,$466

    move.w	#ROTO_EFFECT_VBL,effect_vbl_counter

    move.w	#$2700,sr
    move.l	#rotozoom_vbl,$70
    move.w	#$2300,sr
    move.w	#0,$466
.mainloop  
	cmp.w   #2,$466.w
    blt     .mainloop
    beq		.ok
    IFEQ	CHECK_VBL_OVERFLOW
;    	move.b	#0,$ffffc123
		lea		$ffff8240,a0
		move.w	#$700,d0
		rept 16
		move.w	d0,(a0)+
		endr
	ENDC
.ok

    move.w	#0,$466.w
		tst.w	rotobarsdone
		beq		.doItDiff
	    	jsr		movePlasmaBars
	    	jsr		scrubLowerPart
			jsr		doRotoZoom
			jsr		doC2P
			jsr		doC2P2
			jsr		doC2P3
			jsr		clearLinesHorizontal
			jsr		doubleLines
			jsr		moveRotoBars
			jmp		.skipRoto
.doItDiff
    	jsr		movePlasmaBars
    	jsr		scrubLowerPart
		jsr		doRotoZoom
;		jsr		drawCredits
		jsr		doC2PFast
		jsr		clearLinesHorizontal
		jsr		doubleLines
;		jsr		moveRotoBars
		jsr		drawPictureRoto
.skipRoto
	move.l	screenpointer2,$ffff8200
			swapscreens

		tst.w	effect_vbl_counter
		blt		.next
    	jmp		.mainloop
.next

	IFNE	STANDALONE
		jsr		precalcChecker
	ENDC

.wwww
	tst.w	fadeTransitionOff
	bne		.wwww
	move.w	#0,$466.w
.ww
	tst.w	$466.w
	beq		.ww
	move.w	#0,$466.w

	IFNE	STANDALONE
		jsr		clearMem
	ENDC

	rts  
.vblwaiter	dc.w	20
.rotoWait	dc.w	20
.wvbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
	IFEQ	USE_MYM_DUMP
		IFNE	STANDALONE
			jsr		replayMymDump
		ENDC
	ELSE
		jsr		musicPlayer+8
	ENDC
    rte

scrubLowerPart
	cmp.w	#$4e75,movePlasmaBars
	bne		.skip
		move.l	screenpointer,a0
		move.l	screenpointer2,a1
		add.l	#200*160,a0
		add.l	#200*160,a1
		move.w	.off,d0
		bne		.normal
.first
;		lea		underline+128+45*160,a2
		move.l	ul3ptr,a2
		moveq	#0,d0
		move.w	#2-1,d7
.cld
		REPT 20
			move.l	d0,(a0)+
			move.l	d0,(a1)+
		ENDR
		dbra	d7,.cld
		REPT 8
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
		ENDR
		move.w	#42-1,d7
.cpd2		
		REPT 20
			move.l	(a2)+,d0
			move.l	d0,(a0)+
			move.l	d0,(a1)+
		ENDR
		dbra	d7,.cpd2
		add.w	#22*160,.off
		rts

.normal
		add.w	d0,a0
		add.w	d0,a1
		moveq	#0,d0
		move.w	#18-1,d7
.lll
		REPT 20
			move.l	d0,(a0)+
			move.l	d0,(a1)+
		ENDR
		dbra	d7,.lll
		add.w	#9*160,.off
		cmp.w	#63*160,.off
		ble		.skip
			move.w	#$4e75,scrubLowerPart
.skip
	rts
.off	dc.w	0


fadeTransitionOff	dc.w	448
;--------------
;DEMOPAL - FadeOout table for transition, from original colors to white, then to bg color
;--------------		
; - from 480 to 0
fadeToTransitionTable

	IFEQ	ZOOMPAL
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;1
	dc.w	$000,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222	;2
	dc.w	$000,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333	;3
	dc.w	$000,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444	;4
	dc.w	$000,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555	;5
	dc.w	$000,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666	;6
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777	;7
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$776,$776,$776,$776,$777,$777	;8	
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$776,$776,$776,$776,$776,$667	;9	
	dc.w	$000,$767,$777,$777,$777,$777,$777,$777,$777,$776,$775,$775,$775,$775,$775,$556	;10	
	dc.w	$000,$656,$766,$766,$777,$777,$777,$777,$777,$775,$774,$774,$774,$674,$664,$445	;11	
	dc.w	$000,$545,$655,$755,$766,$766,$776,$777,$777,$774,$773,$773,$673,$573,$553,$334	;12	
	dc.w	$000,$434,$544,$644,$755,$755,$775,$776,$777,$773,$772,$672,$572,$462,$442,$223	;13	
	dc.w	$000,$323,$433,$533,$644,$744,$764,$775,$777,$772,$671,$571,$461,$351,$331,$112	;14	
	dc.w	$000,$212,$322,$422,$533,$633,$653,$774,$777,$671,$570,$460,$350,$240,$220,$001
	ELSE
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111	;1
	dc.w	$000,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222	;2
	dc.w	$000,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333	;3
	dc.w	$000,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444	;4
	dc.w	$000,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555	;5
	dc.w	$000,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666	;6
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777	;7
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777	;8
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$776,$776,$666	;9
	dc.w	$000,$767,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$775,$775,$555	;10
	dc.w	$000,$656,$766,$767,$777,$777,$777,$777,$777,$777,$777,$776,$777,$774,$664,$444	;11
	dc.w	$000,$545,$655,$756,$766,$777,$777,$777,$777,$777,$776,$775,$677,$663,$553,$333	;12
	dc.w	$000,$434,$544,$645,$755,$766,$777,$777,$777,$776,$775,$674,$566,$552,$442,$222	;13
	dc.w	$000,$323,$433,$534,$644,$755,$766,$777,$777,$775,$664,$563,$455,$441,$331,$111	;14
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000	;15
	ENDC

rotozoom_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblCounter
	subq.w	#1,effect_vbl_counter

	move.w	#$0,$ffff8240


	subq.w	#1,tbwait
	blt		.doOpen
		cmp.w	#$4e75,movePlasmaBars
		beq		.normalTB
.transitionActive
			

		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable_horbars,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		jmp		.doClose
.normalTB
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt

		jmp		.doClose
.doOpen
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#tboc3,$120.w
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w	
.doClose

	pushall
		IFEQ	C2P_ROTOZ_TEXTURE_FROM_PLANAR
			movem.l	planarpic+4,d0-d7
			movem.l	d0-d7,$ffff8240
		ELSE
		movem.l	rotozpal,d0-d7
		movem.l	d0-d7,$ffff8240
		
		subq.w	#1,.fadeww
		bge		.kkk
			lea		fadeToTransitionTable,a0
			add.w	fadeTransitionOff,a0
			movem.l	(a0),d0-d7
			movem.l	d0-d7,$ffff8240
			sub.w	#32,fadeTransitionOff
			bge		.kkk
				move.w	#0,fadeTransitionOff
.kkk
		ENDC


		subq.w	#1,.remove
		bge		.noremove
;			move.b	#0,$ffffc123
			jsr		removePanelLamelsRotozoom
.noremove

		IFNE	STANDALONE
			IFEQ	USE_MYM_DUMP
				jsr		replayMymDump
			ELSE
				jsr		musicPlayer+8
			ENDC
		ENDC
	popall
    rte
.remove	dc.w	ROTO_PANEL_OUT_VBL
.fadeww	dc.w	ROTO_EFFECT_VBL-10

rotozpal	ds.w	16

    IFEQ	STANDALONE
timer_b_open_curtain
	move.w	#$222,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte
	ENDC


tboc3
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#open_lower_border4,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

open_lower_border4
	move.w	#$2700,sr
	movem.l	d0/a0/a1,-(sp)
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    move.b  #0,$FFFF820A.w  
    REPT 16
		nop			; 12 nops		;64
	ENDR
    move.b  #2,$FFFF820A.w  ; 50 hz
    move.w	#$0,$ffff8240
			lea		.tab,a0
			add.w	.off,a0
			lea		.tabFull,a1
			add.w	(a0),a1
			lea		$ffff8240+1*2,a0
			REPT 7
			move.l	(a1)+,(a0)+
			ENDR
			move.w	(a1)+,(a0)+


			cmp.w	#30*2,.off
			beq		.testwait
				jmp		.subber
.testwait
			subq.w	#1,tboc3framewait
			bge		.kk

.subber
			sub.w	#2,.off
			bge		.kk
;				move.w	#120,tbwait
;				move.w	#65*2,.off
;				subq.w	#1,botTimes
;				bgt		.kk
					move.w	#32000,tbwait
					move.w	#65*2,.off
.kk



	movem.l	(sp)+,d0/a0/a1
    rte
.off	dc.w	65*2
;--------------
;DEMOPAL - palette for underline
;--------------		
.tabFull		
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;0
	dc.w	$100,$111,$100,$100,$100,$111,$111,$110,$111,$110,$110,$110,$110,$111,$100		;30
	dc.w	$100,$111,$110,$200,$210,$221,$222,$220,$222,$221,$221,$220,$110,$111,$100		;60
	dc.w	$100,$211,$210,$310,$310,$321,$333,$331,$332,$332,$331,$220,$110,$211,$100		;90
	dc.w	$200,$211,$310,$411,$420,$421,$443,$442,$444,$442,$441,$330,$220,$211,$110		;120
	dc.w	$201,$311,$320,$421,$520,$531,$542,$553,$555,$553,$442,$330,$220,$221,$110		;150
	dc.w	$201,$311,$420,$521,$620,$632,$653,$664,$666,$653,$552,$440,$330,$221,$110		;180
	dc.w	$201,$311,$421,$521,$630,$642,$653,$774,$777,$664,$552,$440,$330,$221,$110		;210

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
tboc3framewait	dc.w	140

 
generateC2PLookupTable
	move.l	c2plookuptablepointer,a4
;	move.l	a4,a5
;	add.l	#262144,a5							; 16*16*16*16*4

	lea		TAB3,a5
	lea		TAB4,a6
.loop
	lea		TAB1,a3
	move.l	#16-1,d7
.l4
		lea		TAB2,a2
		moveq	#16-1,d6
		move.l	(a3)+,d3
.l3
;			lea		TAB3,a1
			move.l	a5,a1
			moveq	#16-1,d5
			move.l	(a2)+,d2
			add.l	d3,d2
.l2
;				lea		TAB4,a0
				move.l	a6,a0
				move.l	(a1)+,d1
				add.l	d2,d1
;				move.l	#16-1,d4
;.l1
				REPT 16
					move.l	(a0)+,d0			;12				move.l	d1,d2		;4
					add.l	d1,d0				;8				add.l	(a0)+,d2	;16
					move.l	d0,(a4)+			;12		-> 32	move.l	d2,(a4)+	;12
;					move.l	d0,(a5)+
				ENDR
;				dbra	d4,.l1
			dbra	d5,.l2
		dbra	d6,.l3
	dbra	d7,.l4
	rts

	IFEQ	C2P_ROTOZ_TEXTURE_FROM_PLANAR
planarToChunkyRoto
	move.l	a1,a2
	move.l	#128-1,d6
.height
	move.l	#8-1,d7
.width
	movem.w	(a0)+,d0-d3		; 4 words
	REPT 16
		moveq	#0,d4
		moveq	#0,d5
		roxl.w	d5
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
	ENDR
	dbra	d7,.width

	; 320 width is 160 bytes
	; 128 width is 64 bytes 
	; 160-64 added
	add.w	#160-64,a0
	dbra	d6,.height

	sub.l	a2,a1						;16384
;	move.b	#0,$ffffc123
	rts
	ENDC

generateTextureTables
	move.l	chunkytextpointer,a0
	move.l	text1pointer,a1
	move.l	a1,a3
	add.l	#$10000,a3
	move.l	text2pointer,a2
	move.l	a2,a4
	add.l	#$10000,a4
	move.l	c2plookuptablepointer,d1

	move.w	#2048-1,d7
.loop
.off set 0
	REPT 8
		moveq	#0,d0				;4
		move.b	(a0)+,d0			;8
		lsl.w	#6,d0				;20
		move.w	d0,.off+2(a2)			;12
		move.w	d0,.off+2(a4)			;12
		lsl.w	#4,d0				;16
		move.w	d0,.off(a2)				;8
		move.w	d0,.off(a4)				;8	
		lsl.l	#4,d0				;16
		add.l	d1,d0				;8
		move.l	d0,(a1)+			;12
		move.l	d0,(a3)+			;12
.off set .off+4
	ENDR
	lea		32(a2),a2
	lea		32(a4),a4
	dbra	d7,.loop
	rts


cp2	
		movem.l	(a6)+,d0-d7/a0-a5				;56					124		;4			104
		movem.l	d0-d7/a0-a5,160-56(a6)			;					124		;6		
		movem.l	(a6)+,d0-d5/a0-a3											;4
		movem.l	d0-d5/a0-a3,160-40(a6)											;6
		lea		160+64(a6),a6						;					8	;4

generateDoubleScanlines
		move.l	doublescanlinespointer,a1
		move.w	#viewport_height_lines-1,d7

		movem.l	cp2,d0-d5
.copy2
		movem.l	d0-d5,(a1)
		add.w	#24,a1
		dbra	d7,.copy2
		move.w	#$4e75,(a1)+
		rts	



smccode
		move.w	d0,d2		;2			;	%.XXX XXXX xxxx xxxx		4	
		move.b	d1,d2		;2			;	%.XXX XXXX YYYY YYYy		4
		and.w	d5,d2		;2			;	%.XXX XXXX YYYY YYY.		4
		add.w	d2,d2		;2			;	%XXXX XXXY YYYY YY..		4
		move.w	d2,2(a0)	;4			;								8
		add.l	d3,d0		;2			;	$yy.. XXxx					8
		addx.b	d4,d1		;2			;	%YYYY YYYy 					4	--> 9
					
;add.l	d1,d0		;8		..YY yyyy			;d6 = 01fc	--> %0000 0001 1111 1100
;add.w	d3,d2		;4		.... XXxx			;d7 = fe00	--> %1111 1110 0000 0000
;move.l	d0,d5		;4		..YY yyyy
;swap	d5			;4		yyyy ..YY
;and.w	d6,d5		;4		.... 00YY
;move.w	d2,d4		;4		.... XXxx
;and.w	d7,d4		;4		.... XX00
;add.w	d4,d5		;4		.... XXYY
;move.w	d5,x(a0)	;12	--> 48


;	move.l	d0,d5
;	swap	d5
;	and.w	d6,d5
;	move.w	d2,d4
;	and.w	d7,d4
;	add.w	d4,d5
;	move.w	d5,o(a6)

										
;		move.w	d0,d2		;2				
;		move.b	d1,d2		;2			
;		and.w	d5,d2		;2			
;		add.w	d2,d2		;2			
;		move.w	d2,o+6(a0)	;4			
;		add.l	d3,d0		;2			
;		addx.b	d4,d1		;2			
;										
;		move.w	d0,d2		;2			
;		move.b	d1,d2		;2			
;		and.w	d5,d2		;2			
;		add.w	d2,d2		;2			
;		addq.w	#2,d2		;2			
;		move.w	d2,o+10(a0)	;4			
;		add.l	d3,d0		;2			
;		addx.b	d4,d1		;2
;
;		move.w	d0,d2		;2			
;		move.b	d1,d2		;2			
;		and.w	d5,d2		;2			
;		add.w	d2,d2		;2			
;		move.w	d2,o+14(a0)	;4			
;		add.l	d3,d0		;2			
;		addx.b	d4,d1		;2			


generateRotoCode
	lea		smccode,a0
	move.l	rotosmcpointer,a1
	move.l	(a0)+,d0		; move.w	d0,d2	;	move.b	d1,d2
	move.l	(a0)+,d1		; and.w		d5,d2	;	add.w	d2,d2
	move.l	(a0)+,d2		; move.w	d2,x(a0)		offset
	move.l	(a0)+,d3		; add.l		d3,d0	;	addx.b	d4,d1
	move.w	#$5442,d4		; addq.w	#2,d2
	move.w	#2,d5			; offset
	moveq	#0,d6
	move.w	#24,a2
	move.w	#viewport_width_blocks*2-1,d7
.generate
		move.w	d6,d5
		addq.w	#2,d5
		; first; off = 2
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; off = off + 4
		addq.w	#4,d5
		; second
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; off = off + 4
		addq.w	#4,d5
		; third
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.w	d4,(a1)+	; addq.w	#2,d2
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; off = off +4
		addq.w	#4,d5
		; forth
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; next!
		add.w	a2,d6
	dbra	d7,.generate
	move.w	#$4E75,(a1)+
	rts



_frameCounter dc.w	0

rotoCenter
	dc.w	$8000
	dc.w	$8000

Rotv_int_pos
	dc.w	0
Rotuv_pos
	dc.l	0
Rotv_int_inc
	dc.w	0
Rotuv_inc
	dc.l	0	
Rotorg_offset
	dc.w	0

doRotoZoom
	lea		sine_tbl3,a0										;8
	lea		sine_tbl3+(sintable_size/4),a1						;8

	move.w	_frameCounter,d0									;12
	sub.w	#8,d0												;8
	move.w	d0,_frameCounter			; save time				;16

	move.w	#sintable_size-2,d7			; sine max size mask

	move.w	d0,d1						; save to d1			;4
	move.w	d0,d6						; save to d6			;4

;	add.w	d1,d1
;	add.w	d1,d1
;	add.w	d1,d1


	and.w	d7,d1												;4
;	move.w	d1,d2
;	move.w	d1,d3
;	move.w	d1,d3												;4
	move.w	(a0,d1.w),d2				; sin() -> d2			;16
;	move.w	(a0,d1.w),d3				; sin() -> d3			;16
	move.w	(a0,d1.w),d3
	add.w	d3,d3
	add.w	d3,d3
	move.w	d3,d1
	add.w	d3,d3
	add.w	d1,d3
;	move.w	#$8000,d3
	add.w	d2,d2
	add.w	d2,d2
	move.w	d2,d1
	add.w	d2,d2
	add.w	d1,d2
	add.w	#$800,d2
;	move.w	d2,d1
;	add.w	d2,d2
;	add.w	d2,d2
;	add.w	d1,d2
;	add.w	#$8000,d2
;;	add.w	d2,d2
;	move.w	d2,d1
;	add.w	d2,d2
;	move.w	d2,d3
;	add.w	d1,d2
;	add.w	d2,d2
;	move.w	d2,d3

	movem.w	d2/d3,rotoCenter									;24		--> 290

.calc_xy_rot:
;	add.w	d0,d0												;4						 rotation
	move.w	d0,d1
;	add.w	d0,d0												;4
	add.w	d0,d0
;	add.w	d0,d0
	add.w	d1,d0												;4


	and.w	d7,d0												;4
	move.w	(a1,d0.w),d1										; cos
	move.w	(a0,d0.w),d0										; sin

	move.w	d1,d2			; cos(x)							;4
	neg.w	d2				;-cos(x)							;4
	move.w	d0,d3			; sin(x)							;4
; d2.w: a'.x, d3.w: a'.y
	;	d2	1.x 		-cos	-y													vertical
	;	d3	1.y			sin		x
	move.w	d0,d4												;4
	move.w	d1,d5												;4
;	add.w	d5,d5
	;	d4	2.x			sin		x													horizontal
	;	d5	2.y			cos		y
; And we calculate the amount of zoom... based on time
;	add.w	d6,d6
;	add.w	d6,d6
;	add.w	d6,d6												;4
;	add.w	d6,d6												;4

;	asl.w	#4,d6
	add.w	d6,d6
	add.w	d6,d6
	add.w	d6,d6
;	add.w	d6,d6
	and.w	d7,d6												;4
	move.w	(a1,d6.w),d6
	asr.w	#6,d6				;7								;18
	add.w	#$380,d6			;280							;10		-->	184


	muls.w	d6,d2												;50			1.x -cos		A
	muls.w	d6,d3												;52			1.y  sin
	muls.w	d6,d4												;52			2.x sin			B
	muls.w	d6,d5												;52			2.y cos
	add.l	d3,d3												;8
	add.l	d5,d5												;8

	swap	d2													;4
	swap	d3													;4
	swap	d4													;4
	swap	d5													;4		--> 238

	movem.w	rotoCenter,d6/d7									;24
	asr.w	d6													;10

	move.l	d2,d0												;4
	move.l	d3,d1												;4
	movea.l	d4,a4												;4
	movea.l	d5,a5												;4		--> 50		--> 762

	muls	#50,d0
	muls	#50,d1


	add.l	d0,d6
	add.l	d1,d7
	muls.w	#50,d4				
	muls.w	#50,d5				
	sub.l	d4,d6				
	sub.l	d5,d7				

;	sub.l	#$a00,d6


	move.l	a4,d4
	move.l	a5,d5


	; uv mappying
	;	u -> x
	;	v -> y
	move.l	#$0000FFFF,d0			; 3*8 + 12 = 36							; mask for lower word
	and.l	d0,d7					;				$----VVvv	;8			; get 8.8 position for topleft y 
	ror.l	#8,d7					; d7.l=     	$vv----VV	;24			; fraction in upper byte

	move.w	d7,Rotv_int_pos			; v_int_pos=	$------VV	;16			; save integer value
	move.w	d6,d7					; d7.l=     	$vv--UUuu	;4			; fraction y in upper byte, 8.8 x lower
	move.l	d7,Rotuv_pos			; uv_pos=   	$vv--UUuu	;20			; save 
; a (vector on the vertical screen axis)
	and.l	d0,d3					;				$----VYvy	;8			; mask
	ror.l	#8,d3					; d3.l=     	$vy----VY	;24			; put fraction up top
	move.w	d3,Rotv_int_inc			; v_int_inc=    $------VY	;16			; save for outer loop
	move.w	d2,d3					; d3.l=     	$vy--VXvx	;4			; put x value 
	move.l	d3,Rotuv_inc			; uv_inc=   	$vy--VXvx	;20			; safe
; b (vector on the horizontal screen axis)
	and.l	d0,d5					;				$----HYhy	;8
	ror.l	#8,d5					; d5.l=     	$hy----HY	;24
	move.w	d5,d0					; d0.w=         $------HY	;4
	move.w	d4,d5					; d5.l=     	$hy--HXhx	;4
	move.l	d5,d3					; d3.l=     	$hy--HXhx	;4
;	move.b	#0,$ffffc123
	move.w	d0,d4					; d4.w=         $------HY	;4


	move.w	#$7FFE,d5
	move.l	Rotuv_pos,d0			; `horizontal starting point'
	move.w	Rotv_int_pos,d1			; 

	move.w	d0,d2				;	$------BY
	move.b	d1,d2				; 	
	and.w	d5,d2				; %0UUUUUUUVVVVVVV0
	move.w	d2,Rotorg_offset

	; d0 uv position					; vv--UUuu
	; d1 v integer position				;     --VV
	; d2 local var						;
	; d3 								; hy--HXhx 	for addition and overflow
	; d4 								;     --HY
	; d5  $7ffe
	moveq	#0,d7
	movem.l	d0-a6,rotozSavedVals	

	rts

rotozSavedVals	ds.l	16

c2pLoopList
	dc.l	do4
	dc.l	do8
	dc.l	do12
	dc.l	do0

c2pLoopOff	dc.w	0
c2pLoopOff2	dc.w	0
c2pLoopOff3	dc.w	0








fixRotoSMC
	add.w	d7,a6
	move.l	a6,smcAddress				; base anchor											; do this 4 times
	move.l	(a6),savedLongWord			; save the longword that is to be overwritten			; do this 4 times
	neg.w	d7
	add.w	#12*48-2,d7					; length of current loop
	move.w	d7,c2pLoopJumpOffset+2		; write loadeable value to jump offset
	addq.w	#2,d7
	divs	#6,d7
	subq.w	#8,d7
	move.w	d7,c2pScreenOff
	move.l	jmppca6,(a6)			; write the jmp value to the thing
	rts


;	lea		c2pLoopList,a0
;	add.w	c2pLoopOff,a0
;	move.l	
	; 3kb code
do0
	lea		c2ploop0,a0
	; we can jump in
	move.w	#viewport_width_blocks*2+1-1,d7
.do0loop
o set 0
;	REPT viewport_width_blocks*2+1
		move.w	d0,d2					; $XX00		whole part of the stepx_x		%XXXXXXXX--------	4						move.l	d0,d5		;4
		move.b	d1,d2					; $XXYY		x increment					%XXXXXXXXYYYYYYYY	4							swap	d5			;4
		and.w	d5,d2					; and with %0111111111111110	%0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4	and.w	d6,d5		;4
		add.w	d2,d2					; %XXXXXXXYYYYYYY00	4																	move.w	d2,d4		;
		move.w	d2,o+2(a0)				;12													12									and.w	d7,d4		;4
		add.l	d3,d0					;													8									add.w	d4,d5		;4
		addx.b	d4,d1					;													4	--> 40 * 64 = 2560 				move.w	d5,0(a0)	;12
										;																						add.l	d1,d0		;8
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------										add.w	d3,d2		;4		-> 12 * 4 = 48
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY										move.l	d0,d5
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0										swap	d5
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00										and.w	d6,d5
		move.w	d2,o+6(a0)				;12																						move.w	d2,d4
		add.l	d3,d0					;																						and.w	d7,d4
		addx.b	d4,d1					;																						and.w	d4,d5
										;																						move.w	d5,4(a0)
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00
		addq.w	#2,d2																									;4 cycles * 16		4*40= 160
		move.w	d2,o+10(a0)				;12
		add.l	d3,d0					;	
		addx.b	d4,d1

		move.w	d0,d2					;	move absolute position to tmp	
		move.b	d1,d2					;	
		and.w	d5,d2					;
		add.w	d2,d2					;
		move.w	d2,o+14(a0)				;
		add.l	d3,d0					;
		addx.b	d4,d1					;
;o set o+24
;	ENDR
		lea		24(a0),a0
		dbra	d7,.do0loop
								; ( 40 * 4 + 4 ) * 2 * 20 = 164 * 40 = 6560
	lea		c2ploop0smcanchor,a6		; load anchor
	rts




do4
	lea		c2ploop4,a0
o set 0

		move.w	d0,d2					; $XX00		whole part of the stepx_x		%XXXXXXXX--------	4						move.l	d0,d5		;4
		move.b	d1,d2					; $XXYY		x increment					%XXXXXXXXYYYYYYYY	4							swap	d5			;4
		and.w	d5,d2					; and with %0111111111111110	%0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4	and.w	d6,d5		;4
		add.w	d2,d2					; %XXXXXXXYYYYYYY00	4																	move.w	d2,d4		;
		addq.w	#2,d2																									;4 cycles * 16		4*40= 160
		move.w	d2,o+4(a0)				;12													12									and.w	d7,d4		;4
		add.l	d3,d0					;													8									add.w	d4,d5		;4
		addx.b	d4,d1					;													4	--> 40 * 64 = 2560 				move.w	d5,0(a0)	;12
										;																						add.l	d1,d0		;8
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------										add.w	d3,d2		;4		-> 12 * 4 = 48
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY										move.l	d0,d5
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0										swap	d5
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00										and.w	d6,d5
		move.w	d2,o+8(a0)				;12																						move.w	d2,d4
		add.l	d3,d0					;																						and.w	d7,d4
		addx.b	d4,d1					;						
o set o+18
		move.w	#viewport_width_blocks*2-1-1,d7
.do4loop

;	REPT viewport_width_blocks*2-1 
		move.w	d0,d2					; $XX00		whole part of the stepx_x		%XXXXXXXX--------	4						move.l	d0,d5		;4
		move.b	d1,d2					; $XXYY		x increment					%XXXXXXXXYYYYYYYY	4							swap	d5			;4
		and.w	d5,d2					; and with %0111111111111110	%0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4	and.w	d6,d5		;4
		add.w	d2,d2					; %XXXXXXXYYYYYYY00	4																	move.w	d2,d4		;
		move.w	d2,o+2(a0)				;12													12									and.w	d7,d4		;4
		add.l	d3,d0					;													8									add.w	d4,d5		;4
		addx.b	d4,d1					;													4	--> 40 * 64 = 2560 				move.w	d5,0(a0)	;12
										;																						add.l	d1,d0		;8
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------										add.w	d3,d2		;4		-> 12 * 4 = 48
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY										move.l	d0,d5
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0										swap	d5
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00										and.w	d6,d5
		move.w	d2,o+6(a0)				;12																						move.w	d2,d4
		add.l	d3,d0					;																						and.w	d7,d4
		addx.b	d4,d1					;																						and.w	d4,d5
										;																						move.w	d5,4(a0)
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00
		addq.w	#2,d2																									;4 cycles * 16		4*40= 160
		move.w	d2,o+10(a0)				;12
		add.l	d3,d0					;	
		addx.b	d4,d1

		move.w	d0,d2					;	move absolute position to tmp	
		move.b	d1,d2					;	
		and.w	d5,d2					;
		add.w	d2,d2					;
		move.w	d2,o+14(a0)				;
		add.l	d3,d0					;
		addx.b	d4,d1					;
;o set o+24
;	ENDR								; ( 40 * 4 + 4 ) * 2 * 20 = 164 * 40 = 6560
		lea		24(a0),a0
		dbra	d7,.do4loop
	lea		c2ploop4smcanchor,a6		; load anchor
	rts

do8	
	lea		c2ploop8,a0

o set 0	
	move.w	#viewport_width_blocks*2+1-1,d7
.do8loop
;	REPT viewport_width_blocks*2+1
		move.w	d0,d2					; $XX00		whole part of the stepx_x		%XXXXXXXX--------	4						move.l	d0,d5		;4
		move.b	d1,d2					; $XXYY		x increment					%XXXXXXXXYYYYYYYY	4							swap	d5			;4
		and.w	d5,d2					; and with %0111111111111110	%0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4	and.w	d6,d5		;4
		add.w	d2,d2					; %XXXXXXXYYYYYYY00	4																	move.w	d2,d4		;
		move.w	d2,o+2(a0)				;12													12									and.w	d7,d4		;4
		add.l	d3,d0					;													8									add.w	d4,d5		;4
		addx.b	d4,d1					;													4	--> 40 * 64 = 2560 				move.w	d5,0(a0)	;12
										;																						add.l	d1,d0		;8
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------										add.w	d3,d2		;4		-> 12 * 4 = 48
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY										move.l	d0,d5
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0										swap	d5
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00										and.w	d6,d5
		move.w	d2,o+6(a0)				;12																						move.w	d2,d4
		add.l	d3,d0					;																						and.w	d7,d4
		addx.b	d4,d1					;																						and.w	d4,d5
										;																						move.w	d5,4(a0)
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00
		addq.w	#2,d2																									;4 cycles * 16		4*40= 160
		move.w	d2,o+10(a0)				;12
		add.l	d3,d0					;	
		addx.b	d4,d1

		move.w	d0,d2					;	move absolute position to tmp	
		move.b	d1,d2					;	
		and.w	d5,d2					;
		add.w	d2,d2					;
		move.w	d2,o+14(a0)				;
		add.l	d3,d0					;
		addx.b	d4,d1					;
;o set o+24
;	ENDR	
		lea	24(a0),a0
		dbra	d7,.do8loop

	lea		c2ploop8smcanchor,a6		; load anchor
	rts

do12
	lea		c2ploop12,a0
o set 0

		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------										add.w	d3,d2		;4		-> 12 * 4 = 48
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY										move.l	d0,d5
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0										swap	d5
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00										and.w	d6,d5
		move.w	d2,o+4(a0)				;12																						move.w	d2,d4
		add.l	d3,d0					;																						and.w	d7,d4
		addx.b	d4,d1					;																						and.w	d4,d5

		move.w	d0,d2					; $XX00		whole part of the stepx_x		%XXXXXXXX--------	4						move.l	d0,d5		;4
		move.b	d1,d2					; $XXYY		x increment					%XXXXXXXXYYYYYYYY	4							swap	d5			;4
		and.w	d5,d2					; and with %0111111111111110	%0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4	and.w	d6,d5		;4
		add.w	d2,d2					; %XXXXXXXYYYYYYY00	4																	move.w	d2,d4		;
		addq.w	#2,d2																									;4 cycles * 16		4*40= 160
		move.w	d2,o+8(a0)				;12													12									and.w	d7,d4		;4
		add.l	d3,d0					;													8									add.w	d4,d5		;4
		addx.b	d4,d1					;													4	--> 40 * 64 = 2560 				move.w	d5,0(a0)	;12
										;																						add.l	d1,d0		;8
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------										add.w	d3,d2		;4		-> 12 * 4 = 48
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY										move.l	d0,d5
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0										swap	d5
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00										and.w	d6,d5
		move.w	d2,o+12(a0)				;12																						move.w	d2,d4
		add.l	d3,d0					;																						and.w	d7,d4
		addx.b	d4,d1					;						
o set o+22
	move.w	#viewport_width_blocks*2-1-1,d7
.do12loop
;	REPT viewport_width_blocks*2-1 
		move.w	d0,d2					; $XX00		whole part of the stepx_x		%XXXXXXXX--------	4						move.l	d0,d5		;4
		move.b	d1,d2					; $XXYY		x increment					%XXXXXXXXYYYYYYYY	4							swap	d5			;4
		and.w	d5,d2					; and with %0111111111111110	%0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4	and.w	d6,d5		;4
		add.w	d2,d2					; %XXXXXXXYYYYYYY00	4																	move.w	d2,d4		;
		move.w	d2,o+2(a0)				;12													12									and.w	d7,d4		;4
		add.l	d3,d0					;													8									add.w	d4,d5		;4
		addx.b	d4,d1					;													4	--> 40 * 64 = 2560 				move.w	d5,0(a0)	;12
										;																						add.l	d1,d0		;8
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------										add.w	d3,d2		;4		-> 12 * 4 = 48
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY										move.l	d0,d5
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0										swap	d5
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00										and.w	d6,d5
		move.w	d2,o+6(a0)				;12																						move.w	d2,d4
		add.l	d3,d0					;																						and.w	d7,d4
		addx.b	d4,d1					;																						and.w	d4,d5
										;																						move.w	d5,4(a0)
		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------
		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY
		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0
		add.w	d2,d2					;								%XXXXXXXYYYYYYY00
		addq.w	#2,d2																									;4 cycles * 16		4*40= 160
		move.w	d2,o+10(a0)				;12
		add.l	d3,d0					;	
		addx.b	d4,d1

		move.w	d0,d2					;	move absolute position to tmp	
		move.b	d1,d2					;	
		and.w	d5,d2					;
		add.w	d2,d2					;
		move.w	d2,o+14(a0)				;
		add.l	d3,d0					;
		addx.b	d4,d1					;
;o set o+24
;	ENDR								; ( 40 * 4 + 4 ) * 2 * 20 = 164 * 40 = 6560
		lea	24(a0),a0
	dbra	d7,.do12loop
	lea		c2ploop12smcanchor,a6		; load anchor
	rts


c2pBlockOff	dc.w	0
c2pBlockOff2	dc.w	0
c2pBlockOff3	dc.w	0

c2pRotoList
	dc.l	c2ploop4
	dc.l	c2ploop8
	dc.l	c2ploop12
	dc.l	c2ploop0







c2pScreenOff	dc.w	0
jmppca6			dc.l	$4EFBE000
savedLongWord	dc.l	0
smcAddress		dc.l	0



doC2PFast
	movem.l	rotozSavedVals,d0-a6
	lea		c2ploop,a0
	move.l	rotosmcpointer,a1
	jsr		(a1)

	move.l	screenpointer2,a0
	add.w	#64+5*160,a0
	move.l	a0,a6
	move.l	text1pointer,a1
	add.l	#$10000,a1
	move.l	a1,d3
	move.l	d3,a2
	add.l	#$20000,a2
	move.l	a2,usp
	move.l	#viewport_height_lines-1,d7
	move.l	#$7ffe,d6

	move.w	Rotv_int_pos(pc),d1												;12
	move.w	Rotv_int_inc(pc),d2												;16
	move.l	Rotuv_pos(pc),d4												;16
	move.l	Rotuv_inc(pc),a4												;20
	move.w	Rotorg_offset(pc),a5											;12


c2ploop
o	SET 0
		REPT 	viewport_width_blocks	
			move.l	1234(a1),d0			;16					
			add.w	1234(a2),d0			;12
			add.w	1234(a2),d0			;12
			add.b	1234(a2),d0			;12
			move.l	d0,a3				;4
			move.l	(a3),d0				;12
			movep.l	d0,o(a0)			;24		-> 92			vs 100	40*100*8
	
			move.l	1234(a1),d0			
			add.w	1234(a2),d0
			add.w	1234(a2),d0
			add.b	1234(a2),d0
			move.l	d0,a3
			move.l	(a3),d0
			movep.l	d0,o+1(a0)			;*2 => 184			==> 12*184 = 2208 * 96 = 211968
o			SET 	o+8
		ENDR

		lea		320(a0),a0				; next scanline

		add.l	a4,d4					;	y += dy								;8
		addx.b	d2,d1					;	x += dx								;4
		move.w	d4,d0					;	YYyy								;4
		move.b	d1,d0					;	YYXX								;4
		and.w	d6,d0					;	mask								;4

		move.w	a5,d5					;	org to local						;4
		sub.w	d0,d5					;	org - YYXX							;4
		add.w	d5,d5					;	adjust for offset					;4

		move.l	d3,a1					;	texturepointer1						;8
		add.w	d5,a1					;	add offset to texturepointer		;4
		move.l	usp,a2					;	texcturepointer2					;4
		add.w	d5,a2					;	add offset to						;4		--> 56		d0,d1,d2,d3,d4,d5,d6,usp,a1,a2,a4,a5
	dbra	d7,c2ploop				
	rts


doC2P
	tst.w	rotobar1waiter
	bge		.skip
	movem.l	rotozSavedVals,d0-a6

	lea		c2pLoopList,a6
	add.w	c2pLoopOff,a6
	move.l	(a6),a5
	jsr		(a5)
	move.w	c2pBlockOff,d7
	jsr		fixRotoSMC

	move.l	screenpointer2,a0
	add.w	#5*160+64,a0
	add.w	c2pScreenOff,a0
	move.l	a0,a6
	move.l	text1pointer,a1
	add.l	#$10000,a1
	move.l	a1,d3
	move.l	d3,a2
	add.l	#$20000,a2
	move.l	a2,usp
	move.l	#$7ffe,d6

	move.w	Rotv_int_pos(pc),d1												;12
	move.w	Rotv_int_inc(pc),d2												;16
	move.l	Rotuv_pos(pc),d4												;16
	move.l	Rotuv_inc(pc),a4												;20
	move.w	Rotorg_offset(pc),a5											;12

	tst.w	rotobarsdone
	bne		.do32
		move.w	#96-1,d7
		jmp		.cont
.do32
	move.l	#32-1,d7
.cont
	move.l	(a1),d0
	lea		c2pRotoList,a6
	add.w	c2pLoopOff,a6
	move.l	(a6),a3
	jsr		setOffsetc2p				; do it like this, so we wont have to go around
	jsr		(a3)
	movem.l	d1/d2/d4/a1/a2/a4/a5,savedLoopVals
	move.l	smcAddress,a3
	move.l	savedLongWord,(a3)
.skip
	rts

doC2P2
	tst.w	rotobar2waiter
	bge		.skip
	move.w	#-1,.first
	tst.w	rotobar1waiter
	blt		.weGood
		move.w	#0,.first
.weGood

	movem.l	rotozSavedVals,d0-a6

	lea		c2pLoopList,a6
	add.w	c2pLoopOff2,a6
	move.l	(a6),a5
	jsr		(a5)
	move.w	c2pBlockOff2,d7
	jsr		fixRotoSMC

	move.l	screenpointer2,a0
	add.w	#(64+5)*160+64,a0
	add.w	c2pScreenOff,a0
	move.l	a0,a6
	move.l	text1pointer,a1
	add.l	#$10000,a1
	move.l	a1,d3
	move.l	d3,a2
	add.l	#$20000,a2
	move.l	a2,usp
	move.l	#$7ffe,d6

	move.w	Rotv_int_pos(pc),d1												;12
	move.w	Rotv_int_inc(pc),d2												;16
	move.l	Rotuv_pos(pc),d4												;16
	move.l	Rotuv_inc(pc),a4												;20
	move.w	Rotorg_offset(pc),a5											;12

	tst.w	.first
	bne		.weGood2
		move.w	#32-1,d7
.ll
		add.l	a4,d4					;	y += dy								;8
		addx.b	d2,d1					;	x += dx								;4
		move.w	d4,d0					;	YYyy								;4
		move.b	d1,d0					;	YYXX								;4
		and.w	d6,d0					;	mask								;4

		move.w	a5,d5					;	org to local						;4
		sub.w	d0,d5					;	org - YYXX							;4
		add.w	d5,d5					;	adjust for offset					;4

		move.l	d3,a1					;	texturepointer1						;8
		add.w	d5,a1					;	add offset to texturepointer		;8
		move.l	usp,a2					;	texcturepointer2					;4
		add.w	d5,a2					;	add offset to						;8		--> 64		d0,d1,d2,d3,d4,d5,d6,usp,a1,a2,a4,a5

		dbra	d7,.ll
		jmp		.fixed
.weGood2
	movem.l	savedLoopVals,d1/d2/d4/a1/a2/a4/a5
.fixed

	move.l	#32-1,d7

	move.l	(a1),d0
	lea		c2pRotoList,a6
	add.w	c2pLoopOff2,a6
	move.l	(a6),a3
	jsr		setOffsetc2p				; do it like this, so we wont have to go around
	jsr		(a3)
	movem.l	d1/d2/d4/a1/a2/a4/a5,savedLoopVals

	move.l	smcAddress,a3
	move.l	savedLongWord,(a3)
.skip
	rts
.first	dc.w	-1

doC2P3
	tst.w	rotobar3waiter
	bge		.skip
	movem.l	rotozSavedVals,d0-a6

	lea		c2pLoopList,a6
	add.w	c2pLoopOff3,a6
	move.l	(a6),a5
	jsr		(a5)
	move.w	c2pBlockOff3,d7
	jsr		fixRotoSMC

	move.l	screenpointer2,a0
	add.w	#(64+64+5)*160+64,a0
	add.w	c2pScreenOff,a0
	move.l	a0,a6
	move.l	text1pointer,a1
	add.l	#$10000,a1
	move.l	a1,d3
	move.l	d3,a2
	add.l	#$20000,a2
	move.l	a2,usp
	move.l	#$7ffe,d6

	move.w	Rotv_int_pos(pc),d1												;12
	move.w	Rotv_int_inc(pc),d2												;16
	move.l	Rotuv_pos(pc),d4												;16
	move.l	Rotuv_inc(pc),a4												;20
	move.w	Rotorg_offset(pc),a5											;12

	movem.l	savedLoopVals,d1/d2/d4/a1/a2/a4/a5


	move.l	#32-1,d7

	move.l	(a1),d0
	lea		c2pRotoList,a6
	add.w	c2pLoopOff3,a6
	move.l	(a6),a3
	jsr		setOffsetc2p				; do it like this, so we wont have to go around
	jsr		(a3)
	movem.l	d1/d2/d4/a1/a2/a4/a5,savedLoopVals

	move.l	smcAddress,a3
	move.l	savedLongWord,(a3)
.skip
	rts

savedLoopVals	ds.l	7

setOffsetc2p
c2pLoopJumpOffset
	move.w	#1234,a6
	rts


c2ploop0
o set 0
			move.l	1234(a1),d0					;4
			add.w	1234(a2),d0					;4
			add.w	1234(a2),d0					;4
			add.b	1234(a2),d0					;4
			move.l	d0,a3						;2
			move.l	(a3),d0						;2
			movep.l	d0,o(a0)					;4		--> 24 
	
			move.l	1234(a1),d0					;4
			add.w	1234(a2),d0					;4
			add.w	1234(a2),d0					;4
			add.b	1234(a2),d0					;4
			move.l	d0,a3						;2
			move.l	(a3),d0						;2
			movep.l	d0,o+1(a0)					;4		--> 24		so, number of blocks

o	SET o+8
c2ploop0smcanchor
		REPT 	viewport_width_blocks
			move.l	1234(a1),d0					;4
			add.w	1234(a2),d0					;4
			add.w	1234(a2),d0					;4
			add.b	1234(a2),d0					;4
			move.l	d0,a3						;2
			move.l	(a3),d0						;2
			movep.l	d0,o(a0)					;4		--> 24 
	
			move.l	1234(a1),d0					;4
			add.w	1234(a2),d0					;4
			add.w	1234(a2),d0					;4
			add.b	1234(a2),d0					;4
			move.l	d0,a3						;2
			move.l	(a3),d0						;2
			movep.l	d0,o+1(a0)					;4		--> 24		so, number of blocks
o			SET 	o+8
		ENDR

		lea		320(a0),a0				; next scanline

		add.l	a4,d4					;	y += dy								;8
		addx.b	d2,d1					;	x += dx								;4
		move.w	d4,d0					;	YYyy								;4
		move.b	d1,d0					;	YYXX								;4
		and.w	d6,d0					;	mask								;4

		move.w	a5,d5					;	org to local						;4
		sub.w	d0,d5					;	org - YYXX							;4
		add.w	d5,d5					;	adjust for offset					;4

		move.l	d3,a1					;	texturepointer1						;8
		add.w	d5,a1					;	add offset to texturepointer		;8
		move.l	usp,a2					;	texcturepointer2					;4
		add.w	d5,a2					;	add offset to						;8		--> 64		d0,d1,d2,d3,d4,d5,d6,usp,a1,a2,a4,a5
	dbra	d7,c2ploop0	
	rts		

c2ploop4
	
o	SET 0
;			move.l	1234(a1),d0			
;			add.w	1234(a2),d0
			sub.w	d0,d0																		;2
			move.w	1234(a2),d0																	;4	/	4
			add.b	1234(a2),d0																	;4	/	8
			move.l	d0,a3																		;2
			move.l	(a3),d0																		;2
			movep.l	d0,o+1(a0)			;*2 => 184			==> 20*184 = 3680					;4	/	14
o			SET 	o+8


c2ploop4smcanchor
		REPT 	viewport_width_blocks
			move.l	1234(a1),d0			;16					
			add.w	1234(a2),d0			;12
			add.w	1234(a2),d0			;12
			add.b	1234(a2),d0			;12
			move.l	d0,a3				;4
			move.l	(a3),d0				;12
			movep.l	d0,o(a0)			;24		-> 92			vs 100	40*100*8
	
			move.l	1234(a1),d0			
			add.w	1234(a2),d0
			add.w	1234(a2),d0
			add.b	1234(a2),d0
			move.l	d0,a3
			move.l	(a3),d0
			movep.l	d0,o+1(a0)			;*2 => 184			==> 20*184 = 3680
o			SET 	o+8
		ENDR

;			move.l	1234(a1),d0			;16																
;			add.w	1234(a2),d0			;12	
;			add.w	1234(a2),d0			;12
;			add.b	1234(a2),d0			;12
;			move.l	d0,a3				;4
;			move.l	(a3),d0				;12
;			movep.l	d0,o(a0)			;24		-> 92			vs 100	40*100*8




		lea		320(a0),a0				; next scanline

		add.l	a4,d4					;	y += dy								;8
		addx.b	d2,d1					;	x += dx								;4
		move.w	d4,d0					;	YYyy								;4
		move.b	d1,d0					;	YYXX								;4
		and.w	d6,d0					;	mask								;4

		move.w	a5,d5					;	org to local						;4
		sub.w	d0,d5					;	org - YYXX							;4
		add.w	d5,d5					;	adjust for offset					;4

		move.l	d3,a1					;	texturepointer1						;8
		add.w	d5,a1					;	add offset to texturepointer		;8
		move.l	usp,a2					;	texcturepointer2					;4
		add.w	d5,a2					;	add offset to						;8		--> 64		d0,d1,d2,d3,d4,d5,d6,usp,a1,a2,a4,a5

		move.l	(a1),d0					;	restore upper word
	
	dbra	d7,c2ploop4			

	lea		-32*320(a0),a0
	move.l	#%00000000000011110000000000001111,d0
.y set 0
	REPT 32
		and.l	d0,.y(a0)
		and.l	d0,.y+4(a0)
.y set .y+320
	ENDR
	rts

c2ploop8
o	SET 0

			move.l	1234(a1),d0			;16												
			add.w	1234(a2),d0			;12
			add.w	1234(a2),d0			;12
			add.b	1234(a2),d0			;12
			move.l	d0,a3				;4
			move.l	(a3),d0				;12
			movep.l	d0,o+1(a0)			;24		-> 92			vs 100	40*100*8
o set o+8
c2ploop8smcanchor
		REPT 	viewport_width_blocks
			move.l	1234(a1),d0			;16												
			add.w	1234(a2),d0			;12
			add.w	1234(a2),d0			;12
			add.b	1234(a2),d0			;12
			move.l	d0,a3				;4
			move.l	(a3),d0				;12
			movep.l	d0,o(a0)			;24		-> 92			vs 100	40*100*8
	
			move.l	1234(a1),d0			
			add.w	1234(a2),d0
			add.w	1234(a2),d0
			add.b	1234(a2),d0
			move.l	d0,a3
			move.l	(a3),d0
			movep.l	d0,o+1(a0)			;*2 => 184			==> 20*184 = 3680
o			SET 	o+8
		ENDR



		lea		320(a0),a0				; next scanline

		add.l	a4,d4					;	y += dy								;8
		addx.b	d2,d1					;	x += dx								;4
		move.w	d4,d0					;	YYyy								;4
		move.b	d1,d0					;	YYXX								;4
		and.w	d6,d0					;	mask								;4

		move.w	a5,d5					;	org to local						;4
		sub.w	d0,d5					;	org - YYXX							;4
		add.w	d5,d5					;	adjust for offset					;4

		move.l	d3,a1					;	texturepointer1						;8
		add.w	d5,a1					;	add offset to texturepointer		;8
		move.l	usp,a2					;	texcturepointer2					;4
		add.w	d5,a2					;	add offset to						;8		--> 64		d0,d1,d2,d3,d4,d5,d6,usp,a1,a2,a4,a5
	dbra	d7,c2ploop8		
	rts

c2ploop12
o	SET 0
			sub.w	d0,d0																		;2
			add.w	1234(a2),d0
			add.w	1234(a2),d0																	;4	/	4
			add.b	1234(a2),d0																	;4	/	8
			move.l	d0,a3																		;2
			move.l	(a3),d0																		;2
			movep.l	d0,o(a0)			;*2 => 184			==> 20*184 = 3680					;4	/	14

			move.l	1234(a1),d0			;16					
			add.w	1234(a2),d0			;12
			add.w	1234(a2),d0			;12
			add.b	1234(a2),d0			;12
			move.l	d0,a3				;4
			move.l	(a3),d0				;12
			movep.l	d0,o+1(a0)			;24		-> 92			vs 100	40*100*8
o			SET 	o+8
c2ploop12smcanchor
		REPT 	viewport_width_blocks
			move.l	1234(a1),d0			;16					
			add.w	1234(a2),d0			;12
			add.w	1234(a2),d0			;12
			add.b	1234(a2),d0			;12
			move.l	d0,a3				;4
			move.l	(a3),d0				;12
			movep.l	d0,o(a0)			;24		-> 92			vs 100	40*100*8
	
			move.l	1234(a1),d0			
			add.w	1234(a2),d0
			add.w	1234(a2),d0
			add.b	1234(a2),d0
			move.l	d0,a3
			move.l	(a3),d0
			movep.l	d0,o+1(a0)			;*2 => 184			==> 20*184 = 3680
o			SET 	o+8
		ENDR

		lea		320(a0),a0				; next scanline

		add.l	a4,d4					;	y += dy								;8
		addx.b	d2,d1					;	x += dx								;4
		move.w	d4,d0					;	YYyy								;4
		move.b	d1,d0					;	YYXX								;4
		and.w	d6,d0					;	mask								;4

		move.w	a5,d5					;	org to local						;4
		sub.w	d0,d5					;	org - YYXX							;4
		add.w	d5,d5					;	adjust for offset					;4

		move.l	d3,a1					;	texturepointer1						;8
		add.w	d5,a1					;	add offset to texturepointer		;8
		move.l	usp,a2					;	texcturepointer2					;4
		add.w	d5,a2					;	add offset to						;8		--> 64		d0,d1,d2,d3,d4,d5,d6,usp,a1,a2,a4,a5
		move.l	(a1),d0					; restore upper word		
	dbra	d7,c2ploop12			

	lea		-32*320(a0),a0
	move.l	#%00001111111111110000111111111111,d0
.y set 0
	REPT 32
		and.l	d0,.y(a0)
		and.l	d0,.y+4(a0)
.y set .y+320
	ENDR
	rts



doubleLines
	move.l	doublescanlinespointer,a0
	move.l	screenpointer2,a6
	add.w	#5*160+64,a6
	jmp		(a0)



timer_b_open_curtain_stable_horbars
		movem.l	d1-d2/a0/a1,-(sp)
		clr.b	$fffffa1b.w			;Timer B control (stop)

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

		dcb.w	59,$4e71

		move.w	#$111,$ffff8240

		lea		moveBarPal+2,a0
		add.w	moveBarsPalOff,a0
		lea		$ffff8242,a1
		move.w	(a0)+,(a1)+
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR


		movem.l	(sp)+,d1-d2/a0/a1
		move.l	#timer_b_horbars2_rotoz,$120.w
		move.b	#66,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte


timer_b_horbars2_rotoz
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#68,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_horbars3_rotoz,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	pusha0
	pusha1
		lea		moveBarPal2+2,a0
		add.w	moveBarsPalOff2,a0
		lea		$ffff8242,a1
		move.w	(a0)+,(a1)+
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	rte

timer_b_horbars3_rotoz
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#65-1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	IFEQ	STANDALONE
	move.l	#timer_b_close_curtain,$120.w
	ELSE	
	move.l	#timer_b_close_curtain_stable,$120.w
	ENDC
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	pusha0
	pusha1
		lea		moveBarPal3+2,a0
		add.w	moveBarsPalOff3,a0
		lea		$ffff8242,a1
		move.w	(a0)+,(a1)+
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	rte


moveRotoBars
	tst.w	.roto1done
	beq		.skip1
	subq.w	#1,rotobar1waiter
	bge		.skip1
		add.w	#4,c2pLoopOff
		cmp.w	#16,c2pLoopOff
		bne		.skip1
			move.w	#0,c2pLoopOff
			add.w	#48,c2pBlockOff
			sub.w	#32,moveBarsPalOff
			bge		.palok1
				move.w	#0,moveBarsPalOff
.palok1
			cmp.w	#12*48,c2pBlockOff
			bne		.skip1
				move.w	#11*48,c2pBlockOff
				move.w	#12,c2pLoopOff
				move.w	#0,.roto1done
.skip1
	tst.w	.roto2done
	beq		.skip2
	subq.w	#1,rotobar2waiter
	bge		.skip2
		add.w	#4,c2pLoopOff2
		cmp.w	#16,c2pLoopOff2
		bne		.skip2
			move.w	#0,c2pLoopOff2
			add.w	#48,c2pBlockOff2
			sub.w	#32,moveBarsPalOff2
			bge		.palok2
				move.w	#0,moveBarsPalOff2
.palok2
			cmp.w	#12*48,c2pBlockOff2
			bne		.skip2
				move.w	#11*48,c2pBlockOff2
				move.w	#12,c2pLoopOff2
				move.w	#0,.roto2done
.skip2

	tst.w	.roto3done
	beq		.skip3
	subq.w	#1,rotobar3waiter
	bge		.skip3
		add.w	#4,c2pLoopOff3
		cmp.w	#16,c2pLoopOff3
		bne		.skip3
			move.w	#0,c2pLoopOff3
			add.w	#48,c2pBlockOff3
			sub.w	#32,moveBarsPalOff3
			bge		.palok3
				move.w	#0,moveBarsPalOff3
.palok3
			cmp.w	#12*48,c2pBlockOff3
			bne		.skip3
				move.w	#11*48,c2pBlockOff3
				move.w	#12,c2pLoopOff3
				move.w	#0,.roto3done
.skip3

	moveq	#0,d0
	add.w	.roto1done,d0
	add.w	.roto2done,d0
	add.w	.roto3done,d0
	bne		.ok
		move.w	#$4e75,moveRotoBars
;		move.b	#0,$ffffc123
		move.w	#0,rotobarsdone
		movem.l	$ffff8240,d0-d7
		movem.l	d0-d7,rotozpal
		move.w	#$0,rotozpal
.ok	
	rts
.roto1done		dc.w	-1
.roto2done		dc.w	-1
.roto3done		dc.w	-1
rotobar1waiter	dc.w	10
rotobar2waiter	dc.w	0
rotobar3waiter	dc.w	20
rotobarsdone	dc.w	-1

moveBarsPalOff	dc.w	11*32
moveBarsPalOff2	dc.w	11*32
moveBarsPalOff3	dc.w	11*32

	dc.w	$000,$212,$322,$422,$533,$633,$653,$774,$777,$671,$570,$460,$350,$240,$220,$001

;--------------
;DEMOPAL - transition IN palette fade, for top bar, from original top bar color from plasma, to destination palette
;--------------		
; - from -7 to 0
moveBarPal
	IFEQ	ZOOMPAL	
	dc.w	$000,$212,$322,$422,$533,$633,$653,$774,$777,$671,$570,$460,$350,$240,$220,$001
	dc.w	$000,$212,$322,$422,$533,$633,$652,$763,$777,$661,$670,$450,$350,$240,$220,$001		;-1
	dc.w	$000,$212,$322,$422,$533,$632,$652,$763,$776,$661,$670,$450,$350,$240,$220,$001		;-2
	dc.w	$000,$202,$322,$412,$533,$632,$652,$763,$776,$661,$660,$450,$450,$340,$320,$001		;-2
	dc.w	$000,$202,$322,$412,$522,$632,$642,$753,$776,$651,$660,$450,$450,$340,$320,$001		;-3
	dc.w	$000,$202,$322,$412,$522,$632,$642,$752,$775,$651,$660,$550,$440,$340,$420,$001		;-4
	dc.w	$000,$202,$312,$402,$522,$632,$641,$752,$775,$651,$650,$550,$440,$441,$420,$001		;-4
	dc.w	$000,$202,$312,$402,$522,$621,$631,$742,$775,$641,$650,$540,$441,$441,$410,$001		;-5
	dc.w	$000,$202,$312,$402,$522,$621,$631,$742,$765,$641,$640,$540,$441,$431,$410,$001		;-5
	dc.w	$000,$201,$312,$401,$511,$621,$631,$741,$765,$641,$640,$530,$531,$431,$401,$001		;-6
	dc.w	$000,$201,$312,$401,$511,$611,$621,$741,$765,$641,$641,$531,$531,$421,$401,$001		;-6
	dc.w	$000,$201,$301,$401,$511,$611,$621,$741,$765,$741,$641,$531,$521,$411,$401,$001
	ELSE

	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000

	ENDC

;--------------
;DEMOPAL - transition IN palette fade, for middle bar, from original top bar color from plasma, to destination palette
;--------------		
; - from -7 to 0
moveBarPal2
	IFEQ	ZOOMPAL
	dc.w	$000,$212,$322,$422,$533,$633,$653,$774,$777,$671,$570,$460,$350,$240,$220,$001
	dc.w	$000,$212,$321,$422,$533,$633,$643,$774,$777,$671,$560,$450,$350,$240,$220,$001		;-1
	dc.w	$000,$212,$321,$422,$533,$632,$642,$773,$776,$661,$560,$450,$350,$240,$220,$001		;-2
	dc.w	$000,$312,$321,$421,$532,$632,$642,$773,$776,$661,$560,$450,$450,$340,$320,$001		;-2
	dc.w	$000,$312,$321,$421,$532,$632,$642,$773,$776,$661,$660,$450,$450,$340,$320,$001		;-3
	dc.w	$000,$311,$321,$411,$532,$622,$642,$762,$766,$661,$660,$550,$440,$340,$420,$001		;-4
	dc.w	$000,$311,$320,$411,$532,$622,$641,$762,$766,$760,$660,$550,$440,$430,$420,$001		;-4
	dc.w	$000,$301,$320,$410,$531,$621,$631,$761,$765,$760,$660,$540,$440,$430,$410,$001		;-5
	dc.w	$000,$301,$310,$410,$521,$621,$631,$761,$765,$760,$650,$540,$440,$430,$410,$001		;-5
	dc.w	$000,$301,$310,$410,$521,$621,$631,$751,$765,$760,$650,$540,$530,$420,$410,$001		;-6
	dc.w	$000,$301,$310,$410,$521,$621,$631,$750,$764,$760,$650,$540,$530,$420,$411,$001		;-6
	dc.w	$000,$300,$310,$410,$520,$620,$630,$750,$764,$750,$650,$540,$530,$420,$410,$000



	ELSE

	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000


	ENDC


;--------------
;DEMOPAL - transition IN palette fade, for bottom bar, from original top bar color from plasma, to destination palette
;--------------		
; - from -7 to 0
moveBarPal3
	IFEQ	ZOOMPAL
	dc.w	$000,$212,$322,$422,$533,$633,$653,$774,$777,$671,$570,$460,$350,$240,$220,$001
	dc.w	$000,$211,$322,$422,$533,$633,$652,$673,$777,$671,$570,$460,$340,$340,$220,$001		;-1
	dc.w	$000,$211,$322,$422,$533,$533,$652,$673,$777,$671,$570,$460,$340,$340,$220,$001		;-2
	dc.w	$000,$211,$322,$422,$533,$532,$662,$673,$677,$671,$560,$450,$340,$340,$220,$001		;-2
	dc.w	$000,$211,$222,$422,$542,$532,$662,$673,$676,$671,$560,$450,$340,$330,$220,$001		;-3
	dc.w	$000,$211,$221,$432,$542,$532,$662,$673,$676,$671,$561,$450,$441,$330,$220,$001		;-4
	dc.w	$000,$211,$221,$432,$542,$532,$662,$673,$676,$661,$561,$450,$441,$330,$221,$001		;-4
	dc.w	$000,$210,$221,$431,$541,$542,$662,$673,$676,$661,$561,$450,$441,$330,$221,$001		;-5
	dc.w	$000,$110,$221,$431,$541,$541,$662,$672,$576,$661,$561,$451,$441,$330,$221,$001		;-5
	dc.w	$000,$110,$221,$431,$541,$541,$661,$672,$575,$661,$561,$451,$441,$331,$221,$001		;-6
	dc.w	$000,$110,$221,$431,$541,$541,$661,$672,$575,$661,$561,$452,$442,$331,$221,$001		;-6
	dc.w	$000,$110,$220,$431,$541,$551,$661,$671,$675,$661,$561,$451,$441,$331,$221,$111
	ELSE

	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000
	dc.w	$000,$212,$322,$423,$533,$644,$655,$776,$777,$664,$553,$452,$341,$330,$220,$000

	ENDC

removePanelLamelsRotozoom
	tst.w	.flip
	blt		.back

	move.l	screen2,a0
	add.w	#4*160,a0
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
	lea		.routListTab,a4

xx2r macro
		move.w	(a4)+,a2
		move.l	(a3,a2),a5
		move.l	a6,a0
		jsr		(a5)
		add.w	#160*14,a6
	endm
	REPT 14
			xx2r
	ENDR
	neg.w	.flip
.end
	rts

.back

	move.l	screen1,a0
	add.w	#4*160,a0
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
	lea		.routListTab,a4


xxr macro
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
			xxr
	ENDR
	neg.w	.flip
	rts
.flip dc.w	1


.routListTab
.l set 10
.inc set 1
	REPT 18
	dc.w	.l*4		;0
.l set .l+.inc
	ENDR


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

.noClear2
	move.w	#$4e75,removePanelLamelsRotozoom
.noClear
	rts


; krets stuff:
;	move.l	(a3)+,a4		; get texture line I suppose
;	move.l	d5,d2			; get the delta vector
;	asr.l	#3,d2			; /8
;	
;
;
;
;
;	move.w	d2,d1			; upper byte
;	move.b	x(a4),d1		; lower byte
;	sub.w	d4,d2			; d?
;	move.l	d1,a1
;	move.l	(a1),d3			; 
;	move.w	d2,d7			;
;	move.b	y(a4),d7		;
;	sub.w	d4,d2			;
;	move.l	d7,a1
;	or.l	(a1),d3			;
;	movep.l	d3,off(a0)
;
;	move.w	d2,d1			;
;	move.b	x(a4),d1		;
;	sub.w	d4,d2			;
;	move.l	d1,a1
;	move.l	(a1),d3
;	move.w	d2,d7
;	move.b	y(a4),d7
;	sub.w	d4,d2
;	move.l	d7,a1
;	or.l	(a1),d3
;	movep.l	d3,off+1(a0)
;	...
;	add.l	d6,d5
;	
;	
;




clearLinesHorizontal
	move.l	screenpointer2,a0
	add.w	#(62+3)*160+64,a0
	lea		320(a0),a1
	lea		66*160+96(a1),a2
	lea		320(a2),a3
	moveq	#0,d0

	lea		.table,a4
	move.w	.skipNumber,d1
	cmp.w	#12,d1
	ble		.okkk
		move.w	#12,d1
.okkk
	lsl.w	#4,d1
	neg.w	d1
	jmp		(a4,d1.w)

	REPT 12
		move.l	d0,(a0)+	;
		move.l	d0,(a0)+	;
		move.l	d0,(a1)+	;
		move.l	d0,(a1)+	;
		move.l	d0,-(a2)	;
		move.l	d0,-(a2)	;
		move.l	d0,-(a3)	;
		move.l	d0,-(a3)	;	16s
	ENDR
.table

;	cmp.w	#12,.skipNumber
;	beq		.finish
	lea		.masks,a4
	add.w	.maskOffset,a4
	move.l	(a4)+,d0
	move.l	(a4)+,d1

	and.l	d0,(a0)+
	and.l	d0,(a0)+
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	and.l	d1,-(a2)
	and.l	d1,-(a2)
	and.l	d1,-(a3)
	and.l	d1,-(a3)

;	add.w	#8,.maskOffset
;	cmp.w	#4*8,.maskOffset
;	bne		.ok
;		move.w	#0,.maskOffset
;;		add.w	#1,.skipNumber
;		cmp.w	#13,.skipNumber
;		blt		.ok
;			move.w	#13,.skipNumber
;;			move.w	#0,horizontalBarsDone
;			move.w	#$4e75,doc2pOffset
	tst.w	rotobarsdone
	bne		.end
	subq.w	#1,.waiter
	bge		.ok
	subq.w	#8,.maskOffset
	bge		.ok
		move.w	#3*8,.maskOffset
		subq.w	#1,.skipNumber
		bge		.ok
			move.w	#0,.skipNumber
			move.w	#$4e75,clearLinesHorizontal
			moveq	#0,d0
			move.w	vblCounter,d0
;			move.b	#0,$ffffc123
.ok
.end
	rts
.finish
	rts
.waiter		dc.w	10
.maskOffset	dc.w	0
.skipNumber	dc.w	13
.masks
	dc.l	-1
	dc.l	-1
	dc.l	%00001111111111110000111111111111
	dc.l	%11111111111100001111111111110000
	dc.l	%00000000111111110000000011111111
	dc.l	%11111111000000001111111100000000
	dc.l	%00000000000011110000000000001111
	dc.l	%11110000000000001111000000000000





;;------- copy plasmabars stuff

plasmaBarList
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0


copyPlasmaBars
	; a0 is screen
	; a1 is source
	; d0 is blockoff
	move.l	a0,a6
	lea		160(a0),a2
	move.w	#64,d5
	move.w	d0,d7
	lsr.w	#3,d7
	cmp.w	#13,d7
	bge		.clear
	move.l	#0,a4
	muls	#12,d7
	move.w	#32-1,d6
.loop
;		move.w	d7,d4
		add.w	d0,a1
;.il
		jmp		2(pc,d7)
		REPT 12
			movem.l	(a1)+,d2-d3		;4
			move.l	d2,(a0)+		;2
			move.l	d3,(a0)+		;2
			move.l	d2,(a2)+		;2
			move.l	d3,(a2)+		;2
		ENDR
;		dbra	d4,.il
		move.l	a4,(a0)+
		move.l	a4,(a0)+
		move.l	a4,(a2)+
		move.l	a4,(a2)+
		add.w	d0,a0
		add.w	d0,a2
		lea		320-96-8(a0),a0
		lea		320-96-8(a2),a2
	dbra	d6,.loop	
.end
	rts
.clear
	move.w	#32-1,d6
.l	
		move.l	a4,(a0)+
		move.l	a4,(a0)+
		move.l	a4,(a2)+
		move.l	a4,(a2)+
		lea		320-8(a0),a0
		lea		320-8(a2),a2
	dbra	d6,.l
	rts



movePlasmaBars
	move.l	screenpointer2,a0
	add.w	#5*160,a0
	lea		plasmaBarList,a1
	add.w	.routListOff1,a1
	move.l	(a1),a1					; source
	move.w	.blockOff1,d0
	jsr		copyPlasmaBars


	move.l	screenpointer2,a0
	add.w	#69*160,a0
	lea		plasmaBarList,a1
	add.w	.routListOff2,a1
	move.l	(a1),a1					; source
	add.w	#32*8*12,a1
	move.w	.blockOff2,d0
	jsr		copyPlasmaBars


	move.l	screenpointer2,a0
	add.w	#133*160,a0
	lea		plasmaBarList,a1
	add.w	.routListOff3,a1
	move.l	(a1),a1					; source
	add.w	#64*8*12,a1
	move.w	.blockOff3,d0
	jsr		copyPlasmaBars	

	subq.w	#1,.wait1
	bge		.skip1
		add.w	#4,.routListOff1
		cmp.w	#16,.routListOff1
		bne		.skip1
			move.w	#0,.routListOff1
			add.w	#8,.blockOff1
			cmp.w	#11*8,.blockOff1
			ble		.skip1
				move.w	#32000,.wait1
.skip1
	subq.w	#1,.wait2
	bge		.skip2
		add.w	#4,.routListOff2
		cmp.w	#16,.routListOff2
		bne		.skip2
			move.w	#0,.routListOff2
			add.w	#8,.blockOff2
			cmp.w	#11*8,.blockOff2
			ble		.skip2
				move.w	#32000,.wait2

.skip2
	subq.w	#1,.wait3
	bge		.skip3
		add.w	#4,.routListOff3
		cmp.w	#16,.routListOff3
		bne		.skip3
			move.w	#0,.routListOff3
			add.w	#8,.blockOff3
			cmp.w	#11*8,.blockOff3
			ble		.skip3
				move.w	#3,.stopWaiter
.skip3
														;576 + 12 = 588 * 96 = 56448
	subq.w	#1,.stopWaiter
	bge		.end
		move.w	#$4e75,movePlasmaBars
.end
	rts
.tmpoff			dc.w	0
.routListOff1	dc.w	0
.routListOff2	dc.w	0
.routListOff3	dc.w	0
.blockOff1		dc.w	0
.blockOff2		dc.w	0
.blockOff3		dc.w	0
.wait1			dc.w	10
.wait2			dc.w	0
.wait3			dc.w	20
.stopWaiter		dc.w	32000


preShiftPlasmaBar
	IFEQ	STANDALONE

	lea		plasmabars,a0
	move.l	a0,plasmaBarList
	lea		plasmabars4,a1	
	move.l	a1,plasmaBarList+4
	jsr		doShift
	lea		plasmabars4,a0
	lea		plasmabars8,a1	
	move.l	a1,plasmaBarList+8
	jsr		doShift
	lea		plasmabars8,a0
	lea		plasmabars12,a1	
	move.l	a1,plasmaBarList+12
	jsr		doShift

	ELSE
	move.l	screen1,a0
	add.l	#32000,a0
	move.l	a0,plasmaBarList
	add.l	#9216,a0
	move.l	a0,plasmaBarList+4
	add.l	#9216,a0
	move.l	a0,plasmaBarList+8
	move.l	screen2,a0
	add.l	#32000,a0
	move.l	a0,plasmaBarList+12

;	lea		plasmabars,a0
;	lea		plasmabars4,a1	
	move.l	plasmaBarList,a0
	move.l	plasmaBarList+4,a1
	jsr		doShift
;	lea		plasmabars4,a0
;	lea		plasmabars8,a1	
	move.l	plasmaBarList+4,a0
	move.l	plasmaBarList+8,a1
	jsr		doShift
;	lea		plasmabars8,a0
;	lea		plasmabars12,a1	
	move.l	plasmaBarList+8,a0
	move.l	plasmaBarList+12,a1
	jsr		doShift
	ENDC
	rts


doShift
	move.l	a0,a2
	move.l	a1,a3
	move.w	#4-1,d7		
.doPlane
		move.w	#96-1,d6			;96 lines
.doit
			moveq	#0,d5		; we want to start with a clear thing
			move.l	d5,d4		; we need to save on for last
.x set 0
				move.w	.x(a0),d1		; get first plane
				move.w	d1,d2
.x set .x+8
			REPT 11
				move.w	d2,d0
				move.w	.x(a0),d1
				move.w	d1,d2
				REPT 4
					roxl.w	d1
					roxl.w	d0
				ENDR
				move.w	d0,.x-8(a1)
.x set .x+8
			ENDR

			REPT 4
				roxl.w	d4
				roxl.w	d2
			ENDR
			move.w	d2,.x-8(a1)
			lea	12*8(a0),a0
			lea	12*8(a1),a1		
		dbra	d6,.doit

		lea		2(a2),a2
		lea		2(a3),a3
		move.l	a2,a0
		move.l	a3,a1
	dbra	d7,.doPlane
	rts

;--------------------------------------------------------


_transition	dc.w	0
_credActive		dc.w	0


;list	
;	dc.l	cred_mod
;	dc.l	cred_505

;listoff		dc.w	4
;creditsOff	dc.l	0
;credsWaiter	dc.w	2
;
;
;_creditsWait	dc.w	effect_frames_before_credits_start
;drawCredits
;	subq.w	#1,_creditsWait
;	bgt		.dontDraw
;	lea		list,a0
;	add.w	listoff,a0
;	move.l	(a0),a0
;	move.l	(a0)+,a6		; max size
;	add.l	creditsOff,a0
;
;	move.l	c2plookuptablepointer,a5
;	move.l	text1pointer,a1
;	move.l	a1,a3
;	add.l	#$10000,a3
;	move.l	text2pointer,a2
;	move.l	a2,a4
;	add.l	#$10000,a4
;
;;	move.w	#30-1,d7
;
;	cmp.l	creditsOff,a6													
;	blt		.creditsDrawDone		
;
;	; a0 source
;	; a1	target1
;	; a2	target2
;	; a3	target3
;	; a4	target4
;	; a5 lookuptable
;.loop	
;	move.l	updateTexturePointer,a6
;	jsr		(a6)
;
;;	REPT fontpixels_drawn_per_effect_frame			;-> 11040 bytes																		moveq	#0,d0			;4
;;		moveq	#0,d0				;4											move.w	(a0)+,d0		;8						move.l	(a0)+,d0		;12
;;		move.w	(a0)+,d0			;8		; oh look, new value				move.l	(a0)+,d6		;12						move.l	(a0)+,d6		;12
;;		blt		.end				;8											move.w	d0,2(a2,d6.l)	;16						move.l	d0,(a2,d6.l)	;20
;;		move.l	(a0)+,d6			;12		; oh look, distance into target		move.w	d0,2(a4,d6.l)	;16						move.l	d0,(a4,d6.l)	;20
;;		move.w	2(a2,d6.l),-6(a0)	;24											move.w	(a0)+,d0		;8						move.l	(a0)+,d0		;12
;;		move.w	d0,2(a2,d6.l)		;16											move.w	d0,(a2,d6.l)	;16						move.l	d0,(a1,d6.l)	;20
;;		move.w	d0,2(a4,d6.l)		;16											move.w	d0,(a4,d6.l)	;16						move.l	d0,(a3,d6.l)	;20	116
;;		lsl.w	#4,d0				;12											move.l	(a0)+,d0		;12
;;		move.w	d0,(a2,d6.l)		;16											move.l	d0,(a1,d6.l)	;20
;;		move.w	d0,(a4,d6.l)		;16											move.l	d0,(a3,d6.l)	;20	--> 144
;;		lsl.l	#4,d0				;16										
;;		add.l	a5,d0				;8										
;;		move.l	d0,(a1,d6.l)		;20										
;;		move.l	d0,(a3,d6.l)		;20	--> 196																								
;;	ENDR																	
;																			
;																			
;																			
;.end																		
;	add.l	#(4+2)*fontpixels_drawn_per_effect_frame,creditsOff		; now duration is looped over size of pixels, should be frames		
;.creditsDrawDone
;	subq.w	#1,_drawFrames	
;	bne		.drawNextFrame
;		move.w	#effect_fames_draw_credits,_drawFrames
;		move.l	#0,creditsOff										; reset offset into buffer										
;		move.w	#effect_frames_display_credits,_creditsWait			; wait a few frames to display text
;		subq.w	#1,credsWaiter										; tell it to do 1 more loop, if reaches 0 then switch buffer
;		bne		.kkk
;			move.w	#-1,_transition
;			move.w	#0,_credActive
;			subq.w	#4,listoff
;			blt		.exit
;			move.w	#2,credsWaiter
;			move.w	#effect_frames_between_credits,_creditsWait
;.kkk
;.drawNextFrame
;.dontDraw
;	rts
;.exit
;	move.w	#12,listoff
;	move.w	#2,credsWaiter
;	move.w	#$7999,_creditsWait
;	move.w	#-1,_roto_exit
;	rts
;
;_roto_exit	dc.w	0
;_drawFrames	dc.w	effect_fames_draw_credits


;generateUpdateTexture
;	move.l	updateTexturePointer,a0
;	move.w	#fontpixels_drawn_per_effect_frame-1,d7			;30*8*46
;
;	lea		.template,a1
;	movem.l	(a1)+,d0-d6/a2/a3/a4/a5		;	
;	move.w	(a1)+,a6
;	move.w	#fontpixels_drawn_per_effect_frame*46-18,d1
;;	move.w	#$2B14-6,d1		;	blt						;11022			;11040-18
;	;d0	moveq		
;	move.w	#46,a1
;
;.loop
;		movem.l	d0-d6/a2/a3/a4/a5,(a0)
;		lea		11*4(a0),a0
;		move.w	a6,(a0)+
;		sub.w	a1,d1
;	dbra	d7,.loop
;	move.w	#$4e75,(a0)+
;
;	rts
;.template
;		moveq	#0,d0				;	d0
;		move.w	(a0)+,d0			;	d0	
;		blt		*+$1234				;	d1
;		move.l	(a0)+,d6			;	d2
;		move.w	2(a2,d6.l),-6(a0)	;	d2.2	d3
;		move.w	d0,2(a2,d6.l)		;	d4
;		move.w	d0,2(a4,d6.l)		;	d5
;		lsl.w	#4,d0				;	d6
;		move.w	d0,(a2,d6.l)		;	d6.2	a2
;		move.w	d0,(a4,d6.l)		;	a2.2	a3
;		lsl.l	#4,d0				;	a3.2
;		add.l	a5,d0				;	a4
;		move.l	d0,(a1,d6.l)		;	a4.2	a5
;		move.l	d0,(a3,d6.l)		;	a5.2	a6



drawPictureRoto
	subq.w	#1,.waiter
	bgt		.end
;	lea		panel3+128,a0
	move.l	panel4Pointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	moveq	#0,d0
	move.w	drawOffRoto,d0

	tst.w	.even
	blt		.uneven
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
		movem.l	d0-d7,32(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,160(a1)
		movem.l	d0-d7,160(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+160(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+160(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,320(a1)
		movem.l	d0-d7,320(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+320(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+320(a2)


;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,480(a1)
		movem.l	d0-d7,480(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+480(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+480(a2)


;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,640(a1)
		movem.l	d0-d7,640(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+640(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+640(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,800(a1)
		movem.l	d0-d7,800(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+800(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+800(a2)

		add.w	#160*12,drawOffRoto
		cmp.w	#160*200,drawOffRoto
		ble		.end
			neg.w	.even
			move.w	#160*186,drawOffRoto
;			sub.w	#160,drawOffPlasma
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

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,160(a1)
		movem.l	d0-d7,160(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+160(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+160(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,320(a1)
		movem.l	d0-d7,320(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+320(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+320(a2)


;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,480(a1)
		movem.l	d0-d7,480(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+480(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+480(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,640(a1)
		movem.l	d0-d7,640(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+640(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+640(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,800(a1)
		movem.l	d0-d7,800(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32+800(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,32+800(a2)

		sub.w	#160*12,drawOffRoto
		bge		.end
			move.w	#$4e75,drawPictureRoto
.end
	rts
.waiter		dc.w	ROTO_PANEL_IN_WAIT_VBL
.even		dc.w	1
.copystuff	dc.w	1
drawOffRoto	dc.w	0



	section DATA

sine_tbl3:
	include	"data/rotoz/sintable_amp32768_steps2048.s"


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
		move.w	#$111,$ffff8240.w


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

plasmabars		incbin	"data/c2pproto/plasmabars2.bin"
plasmabars4		ds.b	9216
plasmabars8		ds.b	9216
plasmabars12	ds.b	9216

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

;; change this path in order to include a different texture
;20:30 <@wietze> OMG MODMATE CHANGE HERE
	IFEQ	C2P_ROTOZ_TEXTURE_FROM_PLANAR
planarpic
	;incbin	"data/rotoz/texture.neo"				; 128x128	= 16384
	incbin	"gfx/textures/rototexture3.neo"
	ELSE
texture
	incbin	"data/c2pproto/texture6.crk"				; 5295
	even
	ENDC

panelroto	
		incbin	"data/c2pproto/panel4f.crk"
	even
;panel3
;	incbin	"data/c2pproto/panel4.neo"



;panelBuffer	ds.b	200*8*8		;12800
;prepPanel
;	lea		panel3+128,a0
;	lea		panelBuffer,a1
;.y set 0
;	REPT 200
;.x set .y
;		REPT 8
;			move.l .x(a0),(a1)+
;			move.l .x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;	lea		panelBuffer,a0
;	move.b	#0,$ffffc123
;	rts

ul3	incbin	"data/ul3.crk"
	even
ul3ptr		ds.l	1


;cred_mod
;	include	"data/c2pproto/mod"				;11kb
;
;cred_505
;	include	 "data/c2pproto/505"			;10kb


    IFEQ    STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
tbwait 		dc.w	50       
botTimes	dc.w	0
underline	incbin	"gfx/c2p/underline.neo"
    ENDC

text1pointer			ds.l	1
text2pointer			ds.l	1
c2plookuptablepointer	ds.l	1
chunkytextpointer		ds.l	1
doublescanlinespointer	ds.l	1
rotosmcpointer			ds.l	1
updateTexturePointer	ds.l	1
panel4Pointer			ds.l	1

    IFEQ    STANDALONE
	section BSS

    rsreset
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2      ds.l    1
screen1             ds.l    1
screen2             ds.l    1
vblCounter			ds.w	1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
    ENDC
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

FRAMECOUNT					equ 0
loadmusic					equ FALSE
PLAYMUSIC					equ true
playmusicinvbl				equ true
useblitter					equ 1
	ENDC


picture_height_3bpl		equ 57
pixel_width_3bpl		equ 224
planaroffsetconst		equ (pixel_width_3bpl/16)*6*picture_height_3bpl			;58*224/16*6 	


picture_height_1bpl		equ 50
pixel_width_1bpl		equ 192
planaroffsetconst_1bpl	equ (pixel_width_1bpl/16)*2*picture_height_1bpl			;58*224/16*6 	


	incdir ../lib
	incdir	fx/scale
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	TEXT


    IFEQ	STANDALONE

	include macro.s
		allocateStackAndShrink								; stack + superexec
	; INIT SETUP CODE ---------------------------------------
	jsr	saveAndKillTimers									; kill timers and save them
	jsr	disableMouse										; turn off mouse
	jsr	backupPalAndScrMemAndResolutionAndSetLowRes			; save screen address and other display properties
	jsr	checkMachineTypeAndSetStuff							; check machine type, disable cache
	jsr	setScreen64kAligned									; set 2 screens at 64k aligned
	IFEQ loadmusic
		jsr	loadMusic
		tst.w	fail
		bne		.exit
	ENDC	

	move.w	#$2700,sr
	move.l	#dummy,$70
	move.w	#$2300,sr

	jsr		init_effect2
.mainloop


	tst.w	genDone
	bne		.ok
	cmp.w	#pixel_width_3bpl-1,size
	bgt		.tt
		addq.w	#2,size
.tt
	move.w	size,d0
	jsr		doScale

	addq.w	#1,frames
	cmp.w	#pixel_width_3bpl-1,size
	bne		.ok	
		moveq	#0,d0
		move.w	frames,d0
		move.w	#0,size
		move.w	#-1,genDone
		move.l	#0,planarOffset

		move.l	screenpointer,a0
		move.l	screenpointer2,a1
		move.w	#44-1,d7
		move.l	#0,d0
.cl	
		REPT 20
		move.l	d0,(a0)+
		move.w	#-1,(a0)+
		move.w	d0,(a0)+
		move.l	d0,(a1)+
		move.w	#-1,(a1)+
		move.w	d0,(a1)+
		ENDR
		move.w	#0,size
	dbra	d7,.cl	

.ok





	cmp.b 	#$39,$fffffc02.w								; spacebar to exit
	bne		.mainloop										;



.exit
	move.b	#0,$ffffc123
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
	jsr restoresForMachineTypes
	jsr	restorePalAndScreenMemAndResolution
	jsr	restoreTimers
	IFEQ	PLAYMUSIC
		jsr	stopMusic
	ENDC
	jsr	enableMouse
	rts

drawPic
	move.l	screenpointer2,a0
	add.w	#24,a0
	move.l	planarpicbsspointer,a1
	add.l	planarOffset,a1
	move.w	#picture_height_3bpl-1,d7
.doLine
		REPT 14
			move.l	(a1)+,(a0)+
			add.w	#2,a0
			move.w	(a1)+,(a0)+
		ENDR
	add.w	#48,a0	
	dbra	d7,.doLine	
	rts

doResult
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.w	#80*160,a0
	add.w	#80*160,a1
	move.l	planarpicbsspointer,a2
	move.w	#picture_height_3bpl-1,d7
	moveq	#0,d1
.doLine
	REPT 14
		move.w	(a2)+,d0
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		add.w	#2,a0
		add.w	#2,a1
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+
	ENDR
	add.w	#48,a0
	add.w	#48,a1
	dbra	d7,.doLine
	rts

init_effect2
	jsr		init_scale_pointers_3bpl		
	move.w	#$777,$ffff8240+15*2
	jsr		copyReference
	; first copy source to chunky
	jsr		planarToChunky2
	; then copy target back to planar
	move.l	chunkypicbsspointer,a0
	move.l	planarpicbsspointer,a2
	jsr		chunkyToPlanar_3bpl
	; dotest
	jsr		doResult

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.w	#-1,d0
	move.w	#200-1,d7
.ddd	
o set 6
	REPT 20
		move.w	d0,o(a0)
		move.w	d0,o(a1)
o set o+8
	ENDR
	add.w	#160,a0
	add.w	#160,a1

	dbra	d7,.ddd

	move.w	#$2700,sr
	move.l	#effect_vbl,$70
	move.w	#$2300,sr
	rts

effect_vbl
	pushall
	addq.w	#1,$466.w
	move.l	screenpointer2,$ffff8200
			screenswap
	addq.w	#1,frames
	move.w	#0,$ffff8240
	tst.w	genDone
	beq		.no2
		moveq	#0,d0
		move.w	frames,d0
		jsr		drawPic
		jsr		increaseStep
.no2
	MOVE.W	#$0300,$FFFF8240+2*9
	popall
	rte

genDone	dc.w	0

copyReference
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	lea		gfx+128,a2
	move.w	#picture_height_3bpl-1,d7
.doLine
		REPT 14
		move.l	(a2),(a0)+
		move.l	(a2)+,(a1)+
		move.l	(a2),(a0)+
		move.l	(a2)+,(a1)+
		ENDR
		add.w	#6*8,a0
		add.w	#6*8,a1
		add.w	#6*8,a2
	dbra	d7,.doLine

	rts

; this is what we want to do inline

chunkyToPlanar_3bpl
;	lea		chunkypicbss,a0
;	lea		planarpicbss,a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	#picture_height_3bpl-1,d7
.height	
	move.w	#14-1,d6
;	add.w	#0,a2			; offset of skipped blocks
.width
		REPT 16
			move.b	(a0)+,d0		;40 per pixel
			add.b	d0,d0			
			addx.w	d3,d3			
			add.b	d0,d0			
			addx.w	d4,d4																																																																																																																																														
			add.b	d0,d0
			addx.w	d1,d1
;			add.b	d0,d0
;			addx.w	d2,d2
		ENDR

		move.w	d1,(a2)+				; plane 3
		move.w	d4,(a2)+				; plane 2
		move.w	d3,(a2)+				; plane 1

;		add.w	#0,a2		;offset for skipped blocks
		dbra	d6,.width
	dbra	d7,.height
	rts
	ENDC

scaletimes		dc.w	0
pixel_width		dc.w	0
picture_height	dc.w	0


init_scale_3bpl
	jsr		init_scale_pointers_3bpl
	jsr		unpackScaleLogo
	jsr		planarToChunky2	; move source to chunky
	move.w	#0,scaletimes
	move.w	#1,size
.next
	cmp.w	#pixel_width_3bpl-1,size
	beq		.done
		addq.w	#1,scaletimes
		addq.w	#2,size
		move.w	size,d0
		jsr		doScale
		jmp		.next
.done
	rts

init_scale_pointers_3bpl
	move.l	alignpointer2,d0
	move.l	d0,chunkypicbsspointer	;8960
	add.l	#pixel_width_3bpl*picture_height_3bpl,d0
	move.l	d0,planarpicbsspointer	;531552		113 * 14*6*40
	add.l	#113*14*6*picture_height_3bpl,d0						
	move.l	d0,yofflistpointer		;800
	add.l	#800,d0			
	move.l	d0,smcCodePointer		;3586
	add.l	#3586,d0
	move.l	d0,planarConversionCodePointer	; 3670
	add.l	#3670,d0

	move.l	planarpicbsspointer,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	IFNE	STANDALONE
	add.l	#113*14*6*picture_height_3bpl,a0			; 13 * 4 = 52
	move.w	#113*14*6*picture_height_3bpl/24/52,d7
.clear
		REPT 24
		movem.l	d0-d6/a1-a6,-(a0)
		ENDR
	dbra	d7,.clear
	ENDC
	move.l	planarpicbsspointer,a0


	jsr		scaleGenYOffList_3bpl
	jsr		genSMCSMC_3bpl
	jsr		genPlanarConversionCode_3bpl

	rts


size		dc.w	1			;59
frames		dc.w	0


increaseStep
	add.l	#planaroffsetconst,planarOffset
	cmp.l	#planaroffsetconst*100,planarOffset
	bne		.ok
		move.l	#0,planarOffset
.ok
	rts

bufferClearHax	dc.w	2

doScale

	move.l	#0,d5
	move.l	d0,a4				; save size
	; d0 is size
	move.l	#pixel_width_3bpl,d1				; original
	moveq	#0,d2
	divu	d0,d1				; divide
	move.w	d1,d2				; put whole in lower word
	clr.w	d1					; clear lower word
	swap	d1					; put remainder in lower word
	asl.l	#8,d1				; shift up 8 positions
	divu	d0,d1				; divide again
	asl.w	#8,d1
	swap	d2					; swap words, so fraction is in lower
	or.w	d1,d2				; OR into the bits
	swap	d2					; fraction,whole					x step				03000002

	; y offset into chunky buffer
	move.l	#pixel_width_3bpl,d1		; total width
	moveq	#0,d5
	divu	d1,d0				; d0 is current width so we have size	(1/xstep)
	move.w	d0,d5				; save
	clr.w	d0					; clear	
	swap	d0
	asl.l	#8,d0				
	divu	d1,d0		
	asl.w	#8,d0
	swap	d5
	or.w	d0,d5

;	nop
;	nop
;	mulu	#picture_height_3bpl,d5				;57

	move.l	d5,d0	;1
	add.l	d5,d5	

	add.l	d5,d5	;4
	add.l	d5,d5	;8
	add.l	d5,d0

	add.l	d5,d5	;16
	add.l	d5,d0

	add.l	d5,d5	;32
	add.l	d0,d5	;57


	swap	d5					; fradtion,whole y step
	neg.w	d5
	add.w	#picture_height_3bpl,d5
	lsr		d5					; half y

	add.l	d5,d5		;2
	add.l	d5,d5		;4
	move.l	d5,d0
	add.l	d5,d5		;8
	add.l	d5,d5		;16
	add.l	d5,d0		;20
	add.l	d5,d5		;32
	add.l	d5,d5		;64
	add.l	d0,d5


;	mulu	#pixel_width_3bpl/16*2*3,d5				;84
	move.w	d5,a5

	move.l	chunkypicbsspointer,a0

	; add offset thats not used
	; clear offset value
	moveq	#0,d0
	move.l	#$10280000,d3
	moveq	#0,d1
	; now do smc
	move.w	a4,d4
	add.w	d4,d4	;2
	add.w	d4,d4	;4
	add.w	d4,d4	;8
	neg.w	d4
	move.w	#pixel_width_3bpl,d6
	add.w	#pixel_width_3bpl*8,d4
	; load for smc

;	lea		.jmptable2,a3	
	move.l	planarConversionCodePointer,a3	
	move.l	smcCodePointer,a1
	lea		.return,a2
	jmp		(a1,d4.w)
;	jmp		.smcCode(pc,d4.w)			; offset in d4
;.smcCode	
;o set 0
;	REPT pixel_width_3bpl/16												; 320*8 = 2560
;		REPT 16
;			move.w	d0,d3					;						3600
;			move.l	d3,o(a3)				;4 size					2743 0000
;			add.l	d2,d0					;2						D082
;			addx.w	d1,d0					;2						D141
;			cmp.w	d6,d0					;4						B046
;			bgt		.ttt					;4						6E00 0DDC
;o set o+16	
;		ENDR
;o set o+6
;	ENDR
;.ttt
;	jmp		(a2)						;4ED2

.return
	move.w	#picture_height_3bpl-1,d7
	moveq	#0,d5
	moveq	#0,d0
	moveq	#0,d6
	move.l	yofflistpointer,a3
	move.l	d2,a4	
	move.w	#picture_height_3bpl,a6

	move.l	planarpicbsspointer,a1
	add.l	planarOffset,a1
	; and here we should add height as well
	add.w	a5,a1
	lea		hax,a2
	move.l	planarConversionCodePointer,a5
.doLine
	move.w	d5,d0																					;3005	
	add.w	d0,d0																					;D040
	add.w	d0,d0																					;D040
	move.l	(a3,d0.w),a0			;20																;2073 0000
	jsr		(a5)
	add.l	a4,d5
	addx.w	d6,d5
	cmp.w	a6,d5
	bgt		.end
	jmp		.doLine
.end
	add.l	#planaroffsetconst,planarOffset
	rts

genPlanarConversionCode_3bpl
	move.l	planarConversionCodePointer,a0			;00000E56
	move.l	a0,a1
	move.l	#$102AFFFF,d0					;move.b -1(a2),d0
	move.l	#$D000D542,d1					;add.b	d0,d0	addx.w	d2,d2
	move.l	#$D000D944,d2					;add.b	d0,d0	addx.w	d4,d4
	move.l	#$D000D341,d3					;add.b	d0,d0	addx.w	d1,d1
	move.l	#$32C132C4,d4
	move.w	#$32C2,d5

	move.w	#pixel_width_3bpl/16-1,d7
.ol
		move.w	#16-1,d6
.il
			move.l	d0,(a0)+
			move.l	d1,(a0)+
			move.l	d2,(a0)+
			move.l	d3,(a0)+
		dbra	d6,.il
		move.l	d4,(a0)+
		move.w	d5,(a0)+
	dbra	d7,.ol
	move.w	#$4E75,(a0)+
	rts


genSMCSMC_3bpl
	move.l	smcCodePointer,a0
	move.l	#$36002743,d0				;move.w	d0,d3 ; move.l	d3,o(a3)
	move.w	#0,d1						;o
	move.l	#$d082d141,d2				;add.l	d2,d0 ;	add.l	d2,d0
	move.l	#$b0466e00,d3
	move.w	#$0DDC+22,d4
	move.w	#pixel_width_3bpl/16-1,d7
.ol
		move.w	#16-1,d6
.il
			move.l	d0,(a0)+	;
			move.w	d1,(a0)+	;
			move.l	d2,(a0)+	;
			move.l	d3,(a0)+	;
			move.w	d4,(a0)+	;	
			add.w	#16,d1
			sub.w	#16,d4
		dbra	d6,.il
		add.w	#6,d1
	dbra	d7,.ol
	move.w	#$4ED2,(a0)+
	rts


	DC.W	0
hax
	DC.W	0


planarOffset	dc.l	0


scaleGenYOffList_3bpl
	moveq	#0,d0
	move.l	chunkypicbsspointer,d1
	move.l	yofflistpointer,a0
	move.w	#200-1,d7
.g
		move.l	d1,(a0)+
		add.l	#pixel_width_3bpl,d1
	dbra	d7,.g
	rts

;gfxbuffer	ds.b	14*8*57			;6384
;
;prepgfx
;	lea		gfx+128,a0
;	lea		gfxbuffer,a1
;y set 0
;	REPT 57
;o set y
;		REPT 14
;			move.l	o(a0),(a1)+
;			move.l	o+4(a0),(a1)+
;o set o+8
;		ENDR
;y set y+160
;	ENDR
;	lea		gfxbuffer,a0
;	move.b	#0,$ffffc123
;	rts

; writes to chunky squentially
planarToChunky2
	lea		scalelogo,a0
	move.l	chunkypicbsspointer,a1
	move.l	#picture_height_3bpl-1,d6
.height
	move.l	#14-1,d7
.width
		movem.w	(a0)+,d0-d3		; 4 words, 4x 16 pixel
		REPT 16					; rotate all 4 buffers, one pixel per
			moveq	#0,d4
			moveq	#0,d5
			roxl.w	d5		; clear buffer	
			roxl.w	d3		; get plane 4 bit
			roxl.w	d4		; store
			roxl.w	d2		; get plane 3 bit
			roxl.w	d4		; store
			roxl.w	d1		; get plane 2 bit
			roxl.w	d4		; store
			roxl.w	d0		; get plane 1 bit
			roxl.w	d4		; store
			lsl.w	#4,d4

			move.b	d4,(a1)+	; store byte
		ENDR
		dbra	d7,.width
;		add.w	#48,a0
	dbra	d6,.height
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;; 1 BPL SCALING
init_scale_1bpl
	jsr		init_scale_pointers_1bpl			; fix pointers
	jsr		unpackPlanarBuffer

	move.l	#0,planarBufferOff
	move.w	#0,$466.w
doTwoMore
	nop
	move.w	#2-1,d7			
.times
		pushd7
	jsr		genPlanarConversionCode_1bpl
	lea		planarBuffer,a0
	add.l	planarBufferOff,a0
	add.l	#50*12*2,planarBufferOff
	jsr		planarToChunky_1bpl	; move source to chunky
	move.w	#3,size
.next
	cmp.w	#pixel_width_1bpl-1,size
	beq		.done
		addq.w	#4,size
		move.w	size,d0
		jsr		doScale_1bpl
		jmp		.next

.done
		popd7
		dbra	d7,.times

		nop
		move.w	#$4e75,init_scale_1bpl

		rts

doMore
	move.w	#2-1,doTwoMore+4			; smc the move.w
	move.l	#0,planarOffset
	jmp		doTwoMore+2


init_scale_pointers_1bpl
	move.l	alignpointer4,d0
	add.l	#2560,d0
	add.l	#1280,d0
	move.l	d0,chunkypicbsspointer	;9600
	add.l	#pixel_width_1bpl*picture_height_1bpl,d0
	move.l	d0,yofflistpointer		;800
	add.l	#800,d0			
	move.l	d0,smcCodePointer		;3586
	add.l	#3586,d0
	move.l	d0,planarConversionCodePointer	; 3670
	add.l	#3670,d0
;	lea		mySpace,a0
	move.l	d0,planarpicbsspointer	;531552		113 * 14*6*40
	move.l	d0,savedPlanarpicbsspointer

	move.l	planarpicbsspointer,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6

	add.l	#200*12*2*picture_height_1bpl,a0			; 13 * 4 = 52
	move.w	#200*12*2*picture_height_1bpl/24/52,d7
.clear
		REPT 24
		movem.l	d0-d6/a1-a6,-(a0)
		ENDR
	dbra	d7,.clear

	move.l	#0,planarOffset
	jsr		scaleGenYOffList_1bpl
	jsr		genSMCSMC_1bpl
	rts


increaseStep_1bpl
	add.l	#planaroffsetconst_1bpl,planarOffset
	cmp.l	#planaroffsetconst_1bpl*50,planarOffset
	bne		.ok
		move.l	#0,planarOffset
.ok
	rts


doScale_1bpl
	move.l	#0,d5

	move.l	d0,a4				; save size

	; d0 is size
	move.l	#pixel_width_1bpl,d1				; original
	moveq	#0,d2
	divu	d0,d1				; divide
	move.w	d1,d2				; put whole in lower word
	clr.w	d1					; clear lower word
	swap	d1					; put remainder in lower word
	asl.l	#8,d1				; shift up 8 positions
	divu	d0,d1				; divide again
	asl.w	#8,d1
	swap	d2					; swap words, so fraction is in lower
	or.w	d1,d2				; OR into the bits
	swap	d2					; fraction,whole					x step				03000002

	; y offset into chunky buffer
	move.l	#pixel_width_1bpl,d1		; total width
	moveq	#0,d5
	divu	d1,d0				; d0 is current width so we have size	(1/xstep)
	move.w	d0,d5				; save
	clr.w	d0					; clear	
	swap	d0
	asl.l	#8,d0				
	divu	d1,d0		
	asl.w	#8,d0
	swap	d5
	or.w	d0,d5

	mulu	#picture_height_1bpl,d5
	swap	d5					; fradtion,whole y step
	neg.w	d5
	add.w	#picture_height_1bpl,d5
	lsr		d5					; half y
	mulu	#pixel_width_1bpl/16*2,d5
	move.w	d5,a5

	move.l	chunkypicbsspointer,a0

	; add offset thats not used
	; clear offset value
	moveq	#0,d0
	move.l	#$10280000,d3
	moveq	#0,d1
	; now do smc
;	move.w	#0,d4
	move.w	a4,d4
	add.w	d4,d4	;2
	add.w	d4,d4	;4
	add.w	d4,d4	;8
	neg.w	d4
	move.w	#pixel_width_1bpl,d6
	add.w	#pixel_width_1bpl*8,d4
	; load for smc

;	lea		.jmptable2,a3	
	move.l	planarConversionCodePointer,a3	
	move.l	smcCodePointer,a1
	lea		.return,a2
	jmp		(a1,d4.w)
;	move.b	#0,$ffffc123
;	jmp		.smcCode(pc,d4.w)			; offset in d4
;.smcCode	
;o set 0
;	REPT 224/16												; 320*8 = 2560
;		REPT 16
;			move.w	d0,d3					;						3600					;2
;			move.l	d3,o(a3)				;4 size					2743 0000				;4
;			add.l	d2,d0					;2						D082					;2
;			addx.w	d1,d0					;2						D141					;2
;			cmp.w	d6,d0					;4						B046					;2
;			bgt		.ttt					;4						6E00 0DDC				;4			---> 2524 (2560)		(16)			3548		3584 , dus 16*pixel_width_1bpl-36
;o set o+8
;		ENDR
;o set o+2
;	ENDR
;.ttt

.return
	move.w	#picture_height_1bpl-1,d7
	moveq	#0,d5
	moveq	#0,d0
	moveq	#0,d6
	move.l	yofflistpointer,a3
	move.l	d2,a4	
	move.w	#picture_height_1bpl-1,a6

	move.l	planarpicbsspointer,a1
	add.l	planarOffset,a1
	; and here we should add height as well
	add.w	a5,a1
	lea		hax,a2
	move.l	planarConversionCodePointer,a5
.doLine
	move.w	d5,d0																					;3005	
	add.w	d0,d0																					;D040
	add.w	d0,d0																					;D040
	move.l	(a3,d0.w),a0			;20																;2073 0000
	jsr		(a5)
	add.l	a4,d5
	addx.w	d6,d5
	cmp.w	a6,d5
	bgt		.end
	jmp		.doLine
.end

	add.l	#planaroffsetconst_1bpl,planarOffset
	rts

genPlanarConversionCode_1bpl
	move.l	planarConversionCodePointer,a0			;00000E56
	move.l	a0,a1
	move.l	#$102AFFFF,d0					;move.b -1(a2),d0
	move.l	#$D000D542,d1					;add.b	d0,d0	addx.w	d2,d2
	move.w	#$32C2,d5						; move.w	d2,(a1)+

	move.w	#pixel_width_1bpl/16-1,d7
.ol
;		move.w	#16-1,d6
;.il
		REPT 16
			move.l	d0,(a0)+
			move.l	d1,(a0)+
		ENDR
;		dbra	d6,.il
;		move.l	d4,(a0)+
		move.w	d5,(a0)+
	dbra	d7,.ol
	move.w	#$4E75,(a0)+
	rts

genSMCSMC_1bpl
	move.l	smcCodePointer,a0
	move.l	#$36002743,d0				;move.w	d0,d3 ; move.l	d3,o(a3)
	move.w	#0,d1						;o
	move.l	#$d082d141,d2				;add.l	d2,d0 ;	add.l	d2,d0
	move.l	#$b0466e00,d3
	move.w	#pixel_width_1bpl*16-36+22,d4		
	move.w	#pixel_width_1bpl/16-1,d7
.ol
		move.w	#16-1,d6
.il
			move.l	d0,(a0)+	;
			move.w	d1,(a0)+	;
			move.l	d2,(a0)+	;
			move.l	d3,(a0)+	;
			move.w	d4,(a0)+	;	
			add.w	#8,d1
			sub.w	#16,d4
		dbra	d6,.il
		add.w	#2,d1
	dbra	d7,.ol
	move.w	#$4ED2,(a0)+
	rts

scaleGenYOffList_1bpl
	moveq	#0,d0
	move.l	chunkypicbsspointer,d1
	move.l	yofflistpointer,a0
	move.w	#200-1,d7
.g
		move.l	d1,(a0)+
		add.l	#pixel_width_1bpl,d1
	dbra	d7,.g
	rts

; writes to chunky squentially
planarToChunky_1bpl
	move.l	chunkypicbsspointer,a1
	;9600
	moveq	#0,d0
	move.w	#150-1,d7
.doit
	REPT 4*4
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.doit

;	lea		gfx+128,a0
	move.l	chunkypicbsspointer,a1
	move.l	a1,a2
	move.l	#picture_height_1bpl-1,d6
.height
	move.l	#(pixel_width_1bpl/16)-1,d7
.width
		move.w	(a0)+,d0		; 4 words, 4x 16 pixel
		REPT 16					; rotate all 4 buffers, one pixel per
			moveq	#0,d4
			moveq	#0,d5
			roxl.w	d5		; clear buffer	
			roxl.w	d0		; get plane 4 bit
;			roxl.w	d4		; store
;			roxl.w	d2		; get plane 3 bit
;			roxl.w	d4		; store
;			roxl.w	d1		; get plane 2 bit
;			roxl.w	d4		; store
;			roxl.w	d0		; get plane 1 bit
			roxl.w	d4		; store
			lsl.w	#7,d4

			move.b	d4,(a1)+	; store byte
		ENDR
		dbra	d7,.width
;		add.w	#(320-pixel_width_1bpl)/2,a0
	dbra	d6,.height
	sub.l	a2,a1
	rts

;sourceToPlanar_1bpl
;	move	#4-1,d7
;.il
;y set 0
;	REPT 50
;o set y
;		REPT 12
;			move.w	o(a0),(a1)+
;o set o+8
;		ENDR
;y set y+160
;	ENDR
;	add.l	#50*160,a0
;	dbra	d7,.il
;	rts


unpackPlanarBuffer
	lea		planarBufferPacked,a0
	lea		planarBuffer,a1
	jsr		d_lz77
	rts

unpackScaleLogo
	lea		scalelogoPacked,a0
	lea		scalelogo,a1
	jsr		d_lz77
	rts


	SECTION DATA

scalelogoPacked			incbin	"fx/scale/scalelogo.l77"				; 6384		3784
planarBufferPacked		incbin	"fx/scale/greetings2.l77"				; 6000		3707
	even


	IFEQ STANDALONE
alignpointer2				DC.L	TTT
alignpointer3				dc.l	BLOC
savedPlanarpicbsspointer	ds.l	0
planarpicbsspointer			dC.l	TTT2
yofflistpointer				DC.L	HEHE
smcCodePointer				DC.L	HEHE+32000
planarConversionCodePointer	dc.l	HEHE+64000
	include		lib.s
	include		

	IFNE	loadmusic
music
;	incbin		stnews.snd
	ENDC
	ENDC

	SECTION BSS
; general stuff
chunkypicbsspointer			ds.l	1	
	IFEQ	STANDALONE
screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1
screen1:					ds.b	65536+65536
screen2:					ds.b	65536
myhax
BLOC						ds.b	466816*2
TTT							DS.B	65536*2

TTT2						DS.B	65536*10
HEHE						DS.B	65536*4
	ELSE
planarpicbsspointer			ds.l	1	
savedPlanarpicbsspointer	ds.l	1
yofflistpointer				ds.l	1	
smcCodePointer				ds.l	1
planarConversionCodePointer	ds.l	1		;;3670
	ENDC


;planarBuffer				ds.b	9600		;6000
planarBufferOff				ds.l	1

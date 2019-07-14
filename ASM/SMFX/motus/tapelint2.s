KALMS 		equ 1
PREPTAPE	equ 1
YMTEST		equ 0
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


TAPE_UNDERLINE_WAIT_VBL	equ 70
TAPE_UNDERLINE_ACTIVE_VBL	equ 200
TAPELINT_MOVEOUT_FRAMES	equ 200
TAPE_LINT_STATIC_VBL	equ 100
TAPELINE_FADEIN_VBL_WAIT	equ 0

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
;	jsr		prepBuffs
	jsr		init_demo
	jsr		init_tapelint2
	move.w	#1000,effect_vbl_counter
	jsr		tapelint2_mainloop

.demostart


	
.x
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


v_45_90ptr			ds.l	1
v_m45_m90ptr		ds.l	1
v_0_45ptr			ds.l	1
v_m0_m45ptr			ds.l	1
v_45ptr				ds.l	1
v_m45ptr			ds.l	1

init_tapelint2
	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2
	move.l	screen2,d0
	add.l	#$10000,d0
	move.l	d0,unpackedDataPointer		;83602
	add.l	#83602,d0
	move.l	d0,lineDataPointer			;?
	add.l	#166102,d0
	move.l	d0,v_45_90ptr
	add.l	#2802,d0
	move.l	d0,v_m45_m90ptr
	add.l	#2802,d0
	move.l	d0,v_0_45ptr
	add.l	#3842,d0
	move.l	d0,v_m0_m45ptr
	add.l	#3842,d0
	move.l	d0,v_45ptr
	add.l	#3202,d0
	move.l	d0,v_m45ptr
	add.l	#3202,d0
	move.l	d0,clearLeftPointer
	add.l	#3000,d0
	move.l	d0,clearRightPointer
	add.l	#3000,d0

	add.l	#2560,d0
	move.l	d0,tapePositionTablePointer
	add.l	#2560,d0
	move.l	d0,stForeverPointer
	IFNE	STANDALONE
	lea		peep,a0
	move.l	a0,musicBufferPointer
	move.l	d0,musicDumperPointer
	ENDC


    move.w  #$2700,sr
    move.l  #.wvbl,$70
    move.w  #$2300,sr
    IFEQ	PREPTAPE
	    jsr		prepTape
	ENDC
	move.w	#0,$466.w

	wait_for_vbl
	movem.l	tapePal+2+3*32,d0-d7
	movem.l	d0-d6,$ffff8240+2*1
	swap	d7
	move.w	d7,$ffff8240+2*15

	move.l	screenpointer,a1
	jsr		copyTape						;1
	move.l	screenpointer2,a1
	jsr		copyTape						;1

.ag
	tst.w	$466.w
	beq		.ag
	move.w	#0,$466.w


 


	jsr		bellman_init_line				;1	frame

	lea		linedatacrk,a0
	move.l	unpackedDataPointer,a1
	jsr		cranker							;17	frames
	jsr		copyStuff						;18	frames

	jsr		initLineDivTable
	jsr		genClearCanvasLine
	jsr		genTapePositionTable
													; setup takes 36 frames
	move.w	#$2700,sr
	move.l	#tapeline2_vbl,$70
	move.w	#$2300,sr	

	; unpack st forever

	lea		stForever,a0
	move.l	stForeverPointer,a1
	jsr		cranker

	move.l	screen1,a0
	move.l	screen2,a1
	move.l	stForeverPointer,a2
	add.w	#128,a2
	add.l	#200*160,a0
	add.l	#200*160,a1
	move.w	#44-1,d7
.cp
	REPT 40
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.cp
	moveq	#0,d0
	move.w	#6-1,d7
.cp2
	REPT 40
		move.l	d0,(a0)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.cp2


	move.w	#0,vblcount


    rts
.wvbl
	move.w	#$0,$ffff8240
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    addq.w	#1,vblcount

;	clr.b	$fffffa1b.w			;Timer B control (stop)
;	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
;	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
;;	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
;	move.l	#timer_b_open_curtain,$120.w
;	bclr	#3,$fffffa17.w			;Automatic end of interrupt
;	move.b	#8,$fffffa1b.w	

		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt

	    pushall

	    lea		tapePal,a0
	    add.w	tapePalOff,a0
	    movem.l	2(a0),d0-d7
		movem.l	d0-d6,$ffff8240+2*1
		swap	d7
		move.w	d7,$ffff8240+2*15

	    subq.w	#1,tapePalWaiter
	    bge		.kk
	    	move.w	#2,tapePalWaiter
	    	sub.w	#32,tapePalOff
	    	bge		.kk
	    		move.w	#0,tapePalOff

.kk



    	IFNE	STANDALONE
    		jsr	musicPlayer+8
    	ENDC
    popall
    rte
tapePalOff	dc.w	3*32
tapePalWaiter	dc.w	3


timer_b_open_curtain_stable_lint
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
		move.w	#$777,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
		tst.w	lint_open_lower
		bne		.normal
		move.l	#timer_b_open_lower_stable_lint,$120
		move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte
.normal
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte


lint_open_lower	dc.w	1


timer_b_open_lower_stable_lint
	move.w	#$2700,sr
	movem.l	d0/a0/a1,-(sp)
	move.w	#0,a0
	lea		$ffff8240,a1
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    move.b  #0,$FFFF820A.w  
    REPT 16
		nop			; 12 nops		;64
	ENDR
    move.b  #2,$FFFF820A.w  ; 50 hz
    move.w	a0,(a1)
;    move.w	#$0,$ffff8240

	lea		.tab+2,a0
	add.w	.off,a0
;	lea		$ffff8240+1*2,a1
	lea		$ffff8240+1*2,a1
	REPT 7
	move.l	(a0)+,(a1)+
	ENDR
	move.w	(a0)+,(a1)+

	subq.w	#1,.waiter
	bge		.kk

	cmp.w	#7*32,.off
	beq		.keepColour
		jmp		.subber
.keepColour
		subq.w	#1,.colorHold
		bge		.kk
.subber
		subq.w	#1,.colorFadeSpeed
		bge		.kk
			move.w	#3,.colorFadeSpeed
			sub.w	#32,.off
			bge		.kk
				move.w	#0,.off
				move.w	#-1,lint_open_lower
.kk
	movem.l	(sp)+,d0/a0/a1
    rte
.colorFadeSpeed	dc.w	3 
.waiter		dc.w	0
.colorHold	dc.w	TAPE_UNDERLINE_ACTIVE_VBL
.off		dc.w	14*32
.tab	
;.col set 0
;	REPT 7
;.col set .col+$111
;		dc.w	.col
;	ENDR
;	REPT 8
;		REPT 16
;			dc.w	.col
;.col set .col-$111
;		ENDR
;	ENDR

; yellow-purple ### modmate

    dc.w $000,$001,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000 ; 7
    dc.w $000,$112,$200,$200,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000 ; 6
    dc.w $000,$223,$310,$300,$200,$100,$100,$100,$000,$000,$000,$001,$000,$000,$000,$000 ; 5
    dc.w $000,$334,$420,$410,$300,$200,$200,$200,$100,$000,$000,$112,$011,$000,$000,$000 ; 4
    dc.w $000,$445,$530,$520,$410,$300,$300,$300,$200,$100,$000,$123,$011,$000,$000,$000 ; 3
    dc.w $000,$556,$641,$631,$521,$410,$400,$400,$300,$200,$000,$124,$011,$000,$000,$000 ; 2
    dc.w $000,$667,$752,$742,$632,$521,$511,$501,$401,$201,$100,$124,$011,$000,$000,$000 ; 1

    dc.w $000,$667,$752,$742,$632,$521,$511,$501,$401,$201,$100,$124,$011,$000,$000,$000 ; 1
    dc.w $000,$556,$641,$631,$521,$410,$400,$400,$300,$200,$000,$013,$001,$000,$000,$000 ; 2
	dc.w $000,$445,$530,$520,$410,$300,$300,$300,$200,$100,$000,$002,$000,$000,$000,$000 ; 3
	dc.w $000,$334,$420,$410,$300,$200,$200,$200,$100,$000,$000,$000,$000,$000,$000,$000 ; 4
    dc.w $000,$223,$310,$300,$200,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000 ; 5
    dc.w $000,$112,$200,$200,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000 ; 6
    dc.w $000,$001,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000 ; 7
    dc.w $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000 ; 8

;	yellow

;	dc.w	$000,$001,$100,$100,$000,$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000	;7
;	dc.w	$000,$112,$200,$200,$100,$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000	;6
;	dc.w	$000,$223,$310,$300,$200,$100,$100,$100,$000,$000,$000,$001,$000,$000,$000,$000	;5
;	dc.w	$000,$334,$420,$410,$300,$200,$200,$200,$100,$000,$000,$001,$000,$000,$000,$000	;4
;	dc.w	$000,$445,$530,$520,$410,$300,$300,$300,$200,$100,$000,$002,$000,$000,$000,$000	;3
;	dc.w	$000,$556,$640,$630,$520,$410,$400,$400,$300,$200,$000,$013,$000,$000,$000,$000	;2
;	dc.w	$000,$667,$751,$741,$631,$520,$510,$500,$400,$200,$100,$124,$011,$000,$000,$000	;1

;	dc.w	$000,$667,$751,$741,$631,$520,$510,$500,$400,$200,$100,$124,$011,$000,$000,$000	;1
;	dc.w	$000,$556,$640,$630,$520,$410,$400,$400,$300,$200,$000,$013,$000,$000,$000,$000	;2
;	dc.w	$000,$223,$310,$300,$200,$100,$100,$100,$000,$000,$000,$001,$000,$000,$000,$000	;5
;	dc.w	$000,$112,$200,$200,$100,$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000	;6
;	dc.w	$000,$001,$100,$100,$000,$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000	;7
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000	;8




;	red
;	dc.w	$000,$001,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;1
;	dc.w	$000,$112,$200,$200,$200,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;2
;	dc.w	$000,$223,$300,$300,$300,$200,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000	;3
;	dc.w	$000,$334,$410,$400,$400,$300,$200,$100,$100,$000,$000,$000,$000,$000,$001,$000	;4
;	dc.w	$000,$445,$520,$500,$500,$400,$300,$200,$200,$100,$000,$000,$000,$000,$002,$000	;5
;	dc.w	$000,$556,$631,$611,$601,$501,$401,$300,$300,$200,$100,$100,$000,$000,$013,$000	;6
;	dc.w	$000,$667,$742,$722,$712,$602,$502,$401,$400,$300,$200,$200,$100,$000,$124,$011	;7
;
;
;	dc.w	$000,$667,$742,$722,$712,$602,$502,$401,$400,$300,$200,$200,$100,$000,$124,$011	;1
;	dc.w	$000,$556,$631,$611,$601,$501,$401,$300,$300,$200,$100,$100,$000,$000,$013,$000	;2
;	dc.w	$000,$445,$520,$500,$500,$400,$300,$200,$200,$100,$000,$000,$000,$000,$002,$000	;3
;	dc.w	$000,$334,$410,$400,$400,$300,$200,$100,$100,$000,$000,$000,$000,$000,$001,$000	;4
;	dc.w	$000,$223,$300,$300,$300,$200,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000	;5
;	dc.w	$000,$112,$200,$200,$200,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;6
;	dc.w	$000,$001,$100,$100,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;7
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;8


;	purple
;	dc.w	$000,$001,$101,$101,$101,$001,$001,$000,$000,$000,$000,$000,$000,$000,$000,$000		;1
;	dc.w	$000,$112,$202,$202,$202,$102,$002,$001,$000,$000,$000,$000,$000,$000,$000,$000		;2
;	dc.w	$000,$223,$303,$303,$303,$203,$103,$102,$001,$000,$000,$000,$000,$000,$000,$000		;3
;	dc.w	$000,$334,$414,$404,$404,$304,$204,$103,$102,$000,$000,$000,$000,$000,$001,$000		;4
;	dc.w	$000,$445,$525,$505,$505,$405,$305,$204,$203,$101,$001,$000,$000,$000,$012,$000		;5
;	dc.w	$000,$556,$636,$616,$606,$506,$406,$305,$304,$202,$102,$101,$001,$000,$013,$000		;6
;	dc.w	$000,$667,$747,$727,$717,$607,$507,$406,$405,$303,$203,$202,$102,$000,$124,$011		;7
;
;	dc.w	$000,$667,$747,$727,$717,$607,$507,$406,$405,$303,$203,$202,$102,$000,$124,$011		;1
;	dc.w	$000,$556,$636,$616,$606,$506,$406,$305,$304,$202,$102,$101,$001,$000,$013,$000		;2
;	dc.w	$000,$445,$525,$505,$505,$405,$305,$204,$203,$101,$001,$000,$000,$000,$012,$000		;3
;	dc.w	$000,$334,$414,$404,$404,$304,$204,$103,$102,$000,$000,$000,$000,$000,$001,$000		;4
;	dc.w	$000,$223,$303,$303,$303,$203,$103,$102,$001,$000,$000,$000,$000,$000,$000,$000		;5
;	dc.w	$000,$112,$202,$202,$202,$102,$002,$001,$000,$000,$000,$000,$000,$000,$000,$000		;6
;	dc.w	$000,$001,$101,$101,$101,$001,$001,$000,$000,$000,$000,$000,$000,$000,$000,$000		;7
;	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;8


stForeverPointer	ds.l	1
stForever
	incbin	"gfx/tape/stforeveryellow.crk"
	even


timer_b_tapelint
	move.w	#$777,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#113,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_tapelintpart,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

timer_b_tapelintpart
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#86-1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain_stable,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	pushall
		REPT 14
			or.l	d7,d7
		ENDR
		lea		newpalFade,a0
		add.w	newPalOff,a0
		move.w	(a0)+,$ffff8240+2*1
		move.w	(a0)+,$ffff8240+2*5
		move.w	(a0)+,$ffff8240+2*15
		subq.w	#1,.waiter
		bge		.kk
			move.w	#3,.waiter
			subq.w	#6,newPalOff
			bge		.kk
				move.w	#0,newPalOff
.kk	
	popall
	rte	
.waiter	dc.w	TAPELINE_FADEIN_VBL_WAIT

newPalOff
	dc.w	7*6

newpalFade
	dc.w	$000,$000,$000
	dc.w	$111,$111,$111
	dc.w	$222,$222,$222
	dc.w	$333,$333,$333
	dc.w	$444,$444,$444
	dc.w	$555,$555,$555
	dc.w	$666,$555,$666
	dc.w	$777,$555,$666

newpal
.pal set $103
	REPT 16
		dc.w	.pal
.pal set .pal+77
	ENDR

    IFEQ	STANDALONE
timer_b_open_curtain
	move.w	#$777,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte
	ENDC

vblcount	dc.w	0

tapelint2_mainloop
    move.w  #0,$466
.w  
	tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    	subq.w	#1,.times
    	blt		.skip

    		move.l	screenpointer,a0
    		pusha0
			move.l	screenpointer2,a0
			add.w	#15*160,a0
			move.l	a0,usp
			move.l	#0,d0    	
	    	jsr		doLintEffect
	    	popa0
			add.w	#15*160,a0
			move.l	a0,usp
			move.l	#0,d0    	
	    	jsr		doLintEffect




    		move.l	screenpointer,a0
    		pusha0
    		move.l	framePointer,a6
    		pusha6
			move.l	screenpointer2,a0
			add.w	#15*160,a0
			move.l	a0,usp
			move.l	#0,d0    	
	    	jsr		doLintEffect
	    	popa6
	    	popa0
	    	move.l	a6,framePointer
			add.w	#15*160,a0
			move.l	a0,usp
			move.l	#0,d0    	
	    	jsr		doLintEffect






	    	move.w	#-1,.times
	    	jmp		.cont
.skip
		IFNE	STANDALONE
	    tst.w	.www
    	beq		.kkk
    		jsr		prepMymLocal
	    	move.w	#MYM_DUMP2_NR_PATTERNS*192-1,d7					; MYM_DUMP1_NR_PATTERNS * 192 
			jsr		dumpMymFrames
			IFNE	STANDALONE
				jsr		preshiftTape
			ENDC
			move.w	#0,.www
.kkk
		ENDC

.cont
		tst.w	effect_vbl_counter
		blt		.nextScene
   	jmp		.w
.nextScene
	move.l	#tapelint3_vbl,$70
	move.w	#TAPELINT_MOVEOUT_FRAMES,effect_vbl_counter
	move.w	#0,$466.w
.again
	tst.w	$466.w
	beq		.again
	move.w	#0,$466.w

	subq.w	#1,effect_vbl_counter
	bge		.again

    rts
.times	dc.w	2
.www	dc.w	-1


prepMymLocal
	IFNE	STANDALONE
	lea		myZoomAnimationPointer,a0
	move.l	a0,musicBufferPointer

	lea		songPositionData,a0
	move.b	#MYM_DUMP2_SONG_POS,(a0)+		; pattern
	move.b	#MYM_DUMP2_CHAN1_PATTR,(a0)+
	move.b	#MYM_DUMP2_CHAN2_PATTR,(a0)+
	move.b	#MYM_DUMP2_CHAN3_PATTR,(a0)+

	move.b	#MYM_DUMP2_SONG_POS_NEXT,(a0)+
	move.b	#MYM_DUMP2_CHAN1_PATTR_NEXT,(a0)+
	move.b	#MYM_DUMP2_CHAN2_PATTR_NEXT,(a0)+
	move.b	#MYM_DUMP2_CHAN3_PATTR_NEXT,(a0)+

	lea		advanceSNDData,a0

	move.b	#MYM_DUMP2_SONG_POS_END,(a0)+		; pattern
	move.b	#MYM_DUMP2_CHAN1_PATTR_END,(a0)+
	move.b	#MYM_DUMP2_CHAN2_PATTR_END,(a0)+
	move.b	#MYM_DUMP2_CHAN3_PATTR_END,(a0)+

	move.b	#MYM_DUMP2_SONG_POS_NEXT_END,(a0)+
	move.b	#MYM_DUMP2_CHAN1_PATTR_NEXT_END,(a0)+
	move.b	#MYM_DUMP2_CHAN2_PATTR_NEXT_END,(a0)+
	move.b	#MYM_DUMP2_CHAN3_PATTR_NEXT_END,(a0)+
	IFEQ	YMTEST
	move.w	#MYM_DUMP2_NR_PATTERNS*192-5,mymFrames
	ENDC
	jsr		doMymStuff
	
	ENDC
	move.w	#$4e75,prepMymLocal
	rts

tapelint3_vbl
	addq.w	#1,$466.w
	move.w	#$0,$ffff8240
	
    addq.w	#1,cummulativeCount
    addq.w	#1,vblcount
    subq.w	#1,effect_vbl_counter

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w	


	pushall
		IFNE	STANDALONE
			jsr		replayMymDump
			jsr		advanceSNDPosLocal2
		ENDC
			jsr		moveTapeOut


	popall
		move.l	screenpointer2,$ffff8200
	    swapscreens

	rte


tapePosition	dc.w	80


genTapePositionTable
	move.l	tapePositionTablePointer,a0
	lea		-2560(a0),a0
	move.l	#80,d0		;.xoff
	move.l	#107*12*8,d2
	move.w	#20-1,d7
.ol
		moveq	#0,d1
		REPT 16
			move.l	d0,(a0)+
			move.l	d1,(a0)+
			add.l	d2,d1
		ENDR
		subq.l	#4,d0
	dbra	d7,.ol

	move.w	#20-1,d7
	moveq	#0,d0
.ol2
		moveq	#0,d1
		REPT 16
			move.l	d0,(a0)+
			move.l	d1,(a0)+
			add.l	d2,d1
		ENDR
		addq.l	#8,d0
	dbra	d7,.ol2
	rts

tapePositionTablePointer	dc.l	0

moveTapeOut
	move.l	tapePicBufferPointer,a0
	move.l	screenpointer2,a1
	add.w	#15*160,a1
;	lea		tapePositionTable,a6
	move.l	tapePositionTablePointer,a6
	move.w	#107-1,d7
	moveq	#0,d4
	tst.w	.clearStuff
	beq		.cont
;		move.b	#0,$ffffc123
;		moveq	#-1,d4
.xxx
			move.l	d4,(a1)
			move.l	d4,4(a1)
			move.l	d4,8(a1)
			move.l	d4,12(a1)
			move.l	d4,16(a1)
			move.l	d4,20(a1)
			move.l	d4,24(a1)
			move.l	d4,28(a1)
			lea		160(a1),a1
		dbra	d7,.xxx
		rts

.cont
	move.w	tapePosition,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	bge		.ngt
		add.w	d0,a6
		move.l	(a6)+,d0
		move.l	d0,d6
		add.w	d6,d6
		move.w	d6,d5
		add.l	(a6)+,a0
		jmp		.gogogo
.ngt	
	add.w	d0,a6
	add.l	(a6)+,a1
	add.l	(a6)+,a0
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d0
.gogogo
.cp
		add.w	d6,a0
		jmp		.here(pc,d0.w)
.here
		REPT 12
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
			move.l	d4,(a1)+
			move.l	d4,(a1)+
			move.l	d4,(a1)+
			move.l	d4,(a1)+
			move.l	d4,(a1)+
			move.l	d4,(a1)+
		add.w	d5,a1
		lea		160-96-8-8-8(a1),a1
	dbra	d7,.cp


	lea		tapePositionList,a0
	add.w	tapePositionListOff,a0
	move.w	(a0),tapePosition
	cmp.w	#-192,(a0)
	beq		.enddone
		add.w	#2,tapePositionListOff
	rts
.enddone
	move.w	#-1,.clearStuff
	rts
.doneg	dc.w	1
.clearStuff 	dc.w	0


tapePositionListOff	dc.w	0
tapePositionList
; modmate change movement here
	dc.w	80							; starting position
	dc.w 83,87,90,92,94,95,96,97,97,98,98
	dc.w 97,97,96,96,95,94,92,90,87,83,78,73,67,60,53,45,35,25,10,-5,-20,-35,-50,-70,-90,-110,-130,-160,-190
	dc.w	-192,-192,-192,-192,-192,-192,-192,-192,-192,-192,-192		; end


tapeline2_vbl
	addq.w	#1,$466.w
	move.w	#$0,$ffff8240
	
    addq.w	#1,cummulativeCount
    addq.w	#1,vblcount
    subq.w	#1,effect_vbl_counter


    tst.w	newPalOff
    beq		.normal
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_tapelint,$120.w
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w	
  	  jmp		.tbset
.normal
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable_lint,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt

		subq.w	#1,.holdit
		bge		.tbset
.herr
			tst.w	.first
			bne		.tbset
			move.w	#0,lint_open_lower
			move.w	#-1,.first


.tbset



	pushall
  
  	    lea		tapePal,a0
	    add.w	tapePalOff,a0
	    movem.l	2(a0),d0-d7
		movem.l	d0-d6,$ffff8240+2*1
		swap	d7
		move.w	d7,$ffff8240+2*15

	    subq.w	#1,tapePalWaiter
	    bge		.kk
	    	move.w	#2,tapePalWaiter
	    	sub.w	#32,tapePalOff
	    	bge		.kk
	    		move.w	#0,tapePalOff

.kk


  	IFNE	STANDALONE

    	subq.w	#1,.normalFrames
    	blt		.doMym
	    	jsr		musicPlayer+8
.ttttt	    	
	    	jmp		.continue
.doMym
			jsr		replayMymDump
			jsr		advanceSNDPosLocal2
.continue
    	ENDC

    	subq.w	#1,.waiter
    	bge		.skip
			move.l	screenpointer2,a0
			add.w	#15*160,a0
			move.l	a0,usp
			move.l	#0,d0
	;		add.w	#2,a0
			jsr		clearCanvasLine
	    	jsr		doLintEffect
	    	jsr		fixbugtape
	    	jsr		doTapeMove
	    	addq.w	#1,tapelintCounter
.skip
		move.l	screenpointer2,$ffff8200
	    swapscreens



    popall
    rte
.first	dc.w	0
.waiter			dc.w	TAPE_LINT_STATIC_VBL
.holdit			dc.w	TAPE_UNDERLINE_WAIT_VBL
	IFNE STANDALONE
.normalFrames	dc.w	MYM_DUMP2_START
	ENDC

tapelintCounter	dc.w	0

fixbugtape
	subq.w	#1,.tt
	bge		.kk
		move.w	#$4e75,fixbugtape
.kk
	move.l	screenpointer2,a0
	add.w	#115*160+72,a0
		move.w	#%1111,d0
		move.w	#%1100000000000000,d1
		not.w	d1
		not.w	d0
		and.w	d0,(a0)
		and.w	d1,8(a0)
		and.w	d0,160(a0)
	rts
.tt	dc.w	30

advanceSNDPosLocal2
	IFEQ	YMTEST
	jsr		advanceSNDPos
;	jsr		killMusic
	ENDC
	move.w	#$4e75,advanceSNDPosLocal2
	rts

doLintEffect

        lea     mul_tab,A2  ;mul table
		lea		lineDivTable,a4		;8

		move.l	framePointer,a6
		tst.w	4(a6)
		blt		.endFrame
.drawFrame
			move.l	a6,a0
			move.l	usp,a1
			jsr		bellman_draw_line
			move.w	d0,(a3)
			add.w	#4,a6
			tst.w	4(a6)
			bge		.drawFrame
.nextFrame
		subq.w	#1,.www
		bge		.endFrame
		add.w	#6,a6
		move.l	a6,framePointer
		jmp		.continue
.endFrame
		moveq	#0,d0
		move.w	vblcount,d0
		move.w	#0,vblcount
.continue
;		move.w	#$666,$ffff8240

   	rts
.www	dc.w	1



divcount	dc.w	0

	
initLineDivTable
	lea		lineDivTable,a0

	moveq	#0,d0

	move.w	#8-1,d7
.l
		moveq	#0,d1
		move.w	#8-1,d6
.i
			move.l	d0,d2
			swap	d2
			divu	d1,d2
			move.w	d2,(a0)+
			
			add.w	#1,d1
		dbra	d6,.i
		add.w	#1,d0
	dbra	d7,.l
	lea		lineDivTable,a0
	rts

	;8x8
	;0/i
	;1/i
	;2/i


lineDivTable	ds.w	8*8


clearLeftPointer	dc.l	0
clearRightPointer	dc.l	0

genClearCanvasLine
	lea		.leftDefs,a0
	move.l	clearLeftPointer,a1
	move.l	.template,d0

	jsr		genClearCode

	lea		.rightDefs,a0
	move.l	clearRightPointer,a1
	jsr		genClearCode
	rts


.template
	move.w	d0,1234(a0)

.leftDefs
	dc.w	160*100+72,10,2
	dc.w	160*110+64,10,3
	dc.w	160*120+24,56,7
	dc.w	160*100+80,10,3
	dc.w	160*110+80,10,4
	dc.w	160*120+80,26,5
	dc.w	160*146+80,19,3
	dc.w	160*165+80,12,2
	dc.w	-1
.rightDefs
	dc.w	160*100+80,10,10
	dc.w	160*110+80,10,4
	dc.w	160*120+80,60,7
	dc.w	-1



genClearCode
.again
	move.w	(a0)+,d0
	move.w	(a0)+,d7
	subq.w	#1,d7
	move.w	(a0)+,d5
	subq.w	#1,d5
	move.w	#160,d4
.ol
		move.l	d0,d1
		move.w	d5,d6
.il	
			move.l	d1,(a1)+
			addq.w	#8,d1
		dbra	d6,.il
		add.w	d4,d0
	dbra	d7,.ol

	tst.w	(a0)
	bge		.again
	move.w	#$4e75,(a1)+
	rts




clearCanvasLine							; this is 5 kb of code, can be generated
	;clearLeft
	cmp.w	#120,tapelintCounter
	blt		.noLeft

	move.l	clearLeftPointer,a6
	jmp		(a6)

.noLeft
	move.l	clearRightPointer,a6
	jmp		(a6)

;.y set 160*100+72
;	REPT 10
;.x set .y
;		REPT 2
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;.y set 160*110+64
;	REPT 10
;.x set .y
;		REPT 3
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;
;.y set 160*120+24
;	REPT 56
;.x set .y
;		REPT 7
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;	;clearRight
;.y set 160*100+80
;	REPT 10
;.x set .y
;		REPT 3
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;.y set 160*110+80
;	REPT 10
;.x set .y
;		REPT 4
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;
;.y set 160*120+80
;	REPT 26
;.x set .y
;		REPT 5
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;.y set 160*146+80
;	REPT 19
;.x set .y
;		REPT 3
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;.y set 160*165+80
;	REPT 12
;.x set .y
;		REPT 2
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;	rts

;.noLeft
;	jsr		clearRightPointer
	;clearRight
;.y set 160*100+80
;	REPT 10
;.x set .y
;		REPT 3
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;.y set 160*110+80
;	REPT 10
;.x set .y
;		REPT 4
;			move.w	d0,.x(a0)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;
;.y set 160*120+80
;	REPT 60
;.x set .y
;		REPT 7
;			move.w	d0,.x(a0)					; 520 * 4 = 2080
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR


	rts



copyTape
	move.l	screenpointer2,$ffff8200

	IFEQ	STANDALONE
	lea		tapeBuffer,a0
	ELSE
	move.l	tapePicBufferPointer,a0
	ENDC
;	move.l	screenpointer,a1
;	move.l	screenpointer2,a2
	add.w	#5*160,a1
;	add.w	#5*160,a2
	moveq	#0,d0
	move.w	#10-1,d7
.cl1
		lea		5*8(a1),a1
		lea		5*8(a2),a2
		REPT 11
			move.l	d0,(a1)+
			move.l	d0,(a1)+
;			move.l	d0,(a2)+
;			move.l	d0,(a2)+
		ENDR
		lea		4*8(a1),a1
;		lea		4*8(a2),a2
	dbra	d7,.cl1

	move.w	#107-1,d7
.cp
	lea		5*8(a1),a1
;	lea		5*8(a2),a2
	REPT 12
		move.l	(a0)+,(a1)+
;		move.l	d0,(a1)+
;		move.l	d0,(a2)+
		move.l	(a0)+,(a1)+
;		move.l	d0,(a1)+
;		move.l	d0,(a2)+
	ENDR
		lea		3*8(a1),a1
;		lea		3*8(a2),a2
	dbra	d7,.cp
	move.l	#0,d0
	move.w	#10-1,d7
.cl2
		lea		5*8(a1),a1
;		lea		5*8(a2),a2
		REPT 11
			move.l	d0,(a1)+
			move.l	d0,(a1)+
;			move.l	d0,(a2)+
;			move.l	d0,(a2)+
		ENDR
		lea		4*8(a1),a1
;		lea		4*8(a2),a2
	dbra	d7,.cl2

	rts



	section DATA

	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
		include		lib/mymdump.s
		include		musicplayer.s			;30kb
musicBufferPointer	ds.l	1
musicPlayer			ds.l	1
mymFrames			ds.l	1

    ENDC



draw_line
;	move.w	(a6),d0			;x1
;	sub.w	4(a6),d0		;x1-x2
;	beq		.vertical
;	blt		.x2_gt_x1
;.x1_gt_x2					; we draw from left to
;
;
;.vertical


fake			ds.w	1
                ;PART 'line rout'
bellman_draw_line:
; Line-Rout ver. 1.1b (optimized a lot and then some more) (low/mid/high)
; pre calculated lists and selfmodifying code to skip the time eating loops
; Coded by Criz/2SMART4U
; 1/13-93  20.47

lw:              equ    160
ww:              equ    8               ;8=low 4=mid 2=high
shift:           equ    1               ;1=low 2=mid 3=high

; a0.l = (x1.w,y1.w,x2.w,y2.w)
; a1.l = screen address

                moveq   #0,D4           ;clear for later use
;                lea     mul_tab(PC),A2  ;mul table

                move.w  (A0),D1         ;x1
                sub.w   4(A0),D1        ;x1-x2
                beq     vert            ;x1-x2=0 -> vertical line
                bmi.s   dx_neg          ;negative delta x?
;postive delta x
                move.w  4(A0),D0        ;start with x2
                move.w  6(A0),D2        ;start with y2
                move.w  2(A0),D3        ;y1
                sub.w   D2,D3           ;y1-y2=delta y
*               beq     horiz           ;y1-y1=0 -> horizontal line
                bmi     dy_neg          ;delta y negative?
                bra.s   dy_pos          ;delta y positive?

;negative delta x
dx_neg:
                neg.w   D1              ;make pos
                move.w  (A0)+,D0        ;start with x1
                move.w  (A0)+,D2        ;start with y1
                move.w  2(A0),D3        ;y2
                sub.w   D2,D3           ;y2-y1=delta y
*               beq     horiz
                bmi     dy_neg

;postive delta y
dy_pos:
; d0=start x d1=deltax=xlength
; d2=start y d3=deltay
                move.w  D3,D4           ;d4=deltay
                sub.w   D1,D4           ;delty-deltax
                blt     less_than_45
                bgt.s   more_than_45

;--------> V=45 <----------
                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw

                move.w  D0,D6           ;startx -> d6
                move.w  D0,D2           ;startx -> d2
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16

                move.w  #$8000,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

;                lea     buf+v_45,A0     ;pre calced point list
				move.l	v_45ptr,a0
                lsl.w   #3,D2           ;startx*8=start offset
                lsl.w   #3,D1           ;length*8, each is 8 bytes
                addq.w  #8,D1
                add.w   D2,D1           ;where to stop
                move.l	a0,a3
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3) ;put an RTS there instead
                move.w  #lw,D3          ;line width
                jmp     0(A0,D2.w)      ;draw the fuckin' line

;--------> 45 < V <= 90 <----------
more_than_45:
;                moveq   #0,D4
                move.w  D1,D4           ;d4=deltax
;                swap    D4              ;*65536
 ;               addq.w	#1,divcount
  ;              divu    D3,D4           ;d4.w=ystep*65536


                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d3,d4				;4
                add.w	d4,d4				;4
                move.w	(a4,d4.w),d4		;16

;                move.w	d1,d4
 ;               swap	d4
  ;              divu	d3,d4


                move.w  #$8000,D5

                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw
                move.w  D0,D6           ;startx -> d6
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16

                move.w  d5,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

                ;14 = 8+4+2
                add.w	d3,d3	
                move.w	d3,d0	
                add.w	d3,d3	
                add.w	d3,d0	
                add.w	d3,d3	
                add.w	d0,d3	
 	
;                lea     mul_14_tab(PC),A0							;8
 ;               add.w   D3,D3           ;*2							;4
  ;              move.w  0(A0,D3.w),D3   ;*14						;16
                move.w  #199*14,D0      ;list length-14
                sub.w   D3,D0           ;-line length=start offset
                move.w  #lw,D3
;                lea     buf+v_45_90,A0  ;pre calced point list
				move.l	v_45_90ptr,a0
                lea		fake,a3
                jmp     0(A0,D0.w)

less_than_45:

;---------> 0 <= V > 45 <------------
                move.w  D3,D4           ;d4=deltay
;                swap    D4              ;*65536
;                addq.w	#1,divcount
;                divu    D1,D4           ;d4.w=ystep*65536

                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d1,d4				;4
                add.w	d4,d4				;4
                move.w	(a4,d4.w),d4		;16

                move.w  #$8000,D5

                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw
                move.w  D0,D6           ;startx -> d6
                move.w  D0,D2           ;startx -> d2
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16

                move.w  d5,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

                add.w	d2,d2
                add.w	d2,d2
                move.w	d2,d0
                add.w	d2,d2
                add.w	d0,d2

                addq.w	#1,d1
                add.w	d1,d1
                add.w	d1,d1
                move.w	d1,d0
                add.w	d1,d1
                add.w	d0,d1

                add.w	d2,d1			;12*4 = 48

;                lea     buf+v_0_45,A0   ;pre calced point list
				move.l	v_0_45ptr,a0
                move.l	a0,a3
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3) ;put an RTS there instead
                move.w  #lw,D3          ;line width
                jmp     0(A0,D2.w)      ;draw the fuckin' line

;------> negative delta y <-------
dy_neg:
; d0=start x d1=deltax=xlength
; d2=start y d3=deltay
                neg.w   D3
                move.w  D3,D4           ;d4=deltay
                sub.w   D1,D4           ;delty-deltax
                blt     less_than_m45
                bgt.s   more_than_m45

;---------> V=(-45) <----------
                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw
                move.w  D0,D6           ;startx -> d6
                move.w  D0,D2           ;startx -> d2
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16

                move.w  #$8000,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

;                lea     buf+v_m45,A0    ;pre calced point list
				move.l	v_m45ptr,a0
                lsl.w   #3,D2           ;startx*8=start offset
                lsl.w   #3,D1           ;length*8, each is 8 bytes
                addq.w  #8,D1
                add.w   D2,D1           ;where to stop

                move.l	a0,a3
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3) ;put an RTS there instead
                move.w  #lw,D3          ;line width
                jmp     0(A0,D2.w)      ;draw the fuckin' line

;---------> (-45) < - >= (-90) <-------------
more_than_m45:
;                moveq   #0,D4
                move.w  D1,D4           ;d4=deltax
;                swap    D4              ;*65536
 ;               addq.w	#1,divcount
  ;              divu    D3,D4           ;d4.w=ystep*65536


                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d3,d4				;4
                add.w	d4,d4				;4
                move.w	(a4,d4.w),d4		;16


                move.w  #$8000,D5

                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw
                move.w  D0,D6           ;startx -> d6
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16

                move.w  d5,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

                add.w	d3,d3	;2
                move.w	d3,d0
                add.w	d3,d3	;4
                add.w	d3,d0
                add.w	d3,d3
                add.w	d0,d3

;                lea     mul_14_tab(PC),A0
 ;               add.w   D3,D3           ;*2
  ;              move.w  0(A0,D3.w),D3   ;each is 14 bytes
                move.w  #199*14,D0      ;list length-14
                sub.w   D3,D0           ;-line length=start offset
                move.w  #lw,D3          ;line width
;                lea     buf+v_m45_m90,A0 ;pre calced point list
				move.l	v_m45_m90ptr,a0
                lea		fake,a3
                jmp     0(A0,D0.w)
less_than_m45:
;---------> 1 <-> (-45) <--------------

                move.w  D3,D4           ;d4=deltay
;                swap    D4              ;*65536
;                addq.w	#1,divcount
;                divu    D1,D4           ;d4.w=ystep*65536


                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d4,d4				;4
                add.w	d1,d4				;4
                add.w	d4,d4				;4
                move.w	(a4,d4.w),d4		;16

                move.w  #$8000,D5

                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw
                move.w  D0,D6           ;startx -> d6
                move.w  D0,D2           ;startx -> d2
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16

                move.w  d5,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

                add.w	d2,d2
                add.w	d2,d2
                move.w	d2,d0
                add.w	d2,d2
                add.w	d0,d2

                addq.w	#1,d1
                add.w	d1,d1
                add.w	d1,d1
                move.w	d1,d0
                add.w	d1,d1
                add.w	d0,d1
                add.w	d2,d1			;12*4 = 48

;                lea     buf+v_m0_m45,A0 ;pre calced point list
				move.l	v_m0_m45ptr,a0

                move.l	a0,a3
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3);put an RTS there instead
                move.w  #lw,D3          ;line width
                jmp     (A0,D2.w)      ;draw the fuckin' line

;---------> V=0 <---------- (horizontal line)
horiz:
                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw
                move.w  D0,D6           ;startx -> d6
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16
                move.w  #$8000,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

looph:          or.w    D6,(A1)         ;plot point
                ror.w   #1,D6
                bcc.s   dont_addh
                addq.w  #ww,A1
dont_addh:      dbra    D1,looph
				lea		fake,a3
				rts

;---------> V=90 <---------- (vertical line)
vert:
                move.w  4(A0),D0        ;start with x2
                move.w  6(A0),D2        ;start with y2
                move.w  2(A0),D3        ;y1
                sub.w   D2,D3           ;y1-y2=delta y
                bge.s   pos_vert
                neg.w   D3
                move.w  2(A0),D2        ;start with y1
pos_vert:
                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw
                move.w  D0,D6           ;startx -> d6
                andi.w  #$FFF0,D6       ;div 16 * 16
                lsr.w   #shift,D6       ;/2
                adda.w  D6,A1           ;add x offset
                and.w   #$000F,D0       ;mod 16

                move.w  #$8000,D6       ;d6=bitmask
                ror.w   D0,D6           ;start pixel

loopv:          or.w    D6,(A1)         ;plot point
                adda.w  #lw,A1
                dbra    D3,loopv
                lea		fake,a3
line_done:      rts

**** Make som premodified lists ****
bellman_init_line:
; 45 <-> 90
                move.w  #200-1,D1
;                lea     buf+v_45_90,A1
				move.l	v_45_90ptr,a1
copy1b:         move.w  #(d_45_90_e-d_45_90)/2-1,D0
                lea     d_45_90(PC),A0
copy1:          move.w  (A0)+,(A1)+
                dbra    D0,copy1
                dbra    D1,copy1b
                move.w  #$4E75,(A1)     ;rts
; -45 <-> -90
                move.w  #200-1,D1
;                lea     buf+v_m45_m90,A1
				move.l	v_m45_m90ptr,a1
copy2b:         move.w  #(d_m45_m90_e-d_m45_m90)/2-1,D0
                lea     d_m45_m90(PC),A0
copy2:          move.w  (A0)+,(A1)+
                dbra    D0,copy2
                dbra    D1,copy2b
                move.w  #$4E75,(A1)     ;rts
; 0 <-> 45
                move.w  #320/16-1,D1
;                lea     buf+v_0_45,A1
				move.l	v_0_45ptr,a1
copy3d:         move.w  #15-1,D2        ;15 first
copy3b:         move.w  #(d_0_45_1_e-d_0_45_1)/2-1,D0
                lea     d_0_45_1(PC),A0
copy3:          move.w  (A0)+,(A1)+
                dbra    D0,copy3
                dbra    D2,copy3b
                move.w  #(d_0_45_2_e-d_0_45_2)/2-1,D0
                lea     d_0_45_2(PC),A0
copy3c:         move.w  (A0)+,(A1)+
                dbra    D0,copy3c
                dbra    D1,copy3d
                move.w  #$4E75,(A1)     ;rts
; -0 <-> -45
                move.w  #320/16-1,D1
;                lea     buf+v_m0_m45,A1
				move.l	v_m0_m45ptr,a1
copy4d:         move.w  #15-1,D2        ;15 first
copy4b:         move.w  #(d_m0_m45_1_e-d_m0_m45_1)/2-1,D0
                lea     d_m0_m45_1(PC),A0
copy4:          move.w  (A0)+,(A1)+
                dbra    D0,copy4
                dbra    D2,copy4b
                move.w  #(d_m0_m45_2_e-d_m0_m45_2)/2-1,D0
                lea     d_m0_m45_2(PC),A0
copy4c:         move.w  (A0)+,(A1)+
                dbra    D0,copy4c
                dbra    D1,copy4d
                move.w  #$4E75,(A1)     ;rts
; 45
                move.w  #400/16-1,D1
;                lea     buf+v_45,A1
				move.l	v_45ptr,a1
copy5d:         move.w  #15-1,D2        ;15 first
copy5b:         move.w  #(d_45_1_e-d_45_1)/2-1,D0
                lea     d_45_1(PC),A0
copy5:          move.w  (A0)+,(A1)+
                dbra    D0,copy5
                dbra    D2,copy5b
                move.w  #(d_45_2_e-d_45_2)/2-1,D0
                lea     d_45_2(PC),A0
copy5c:         move.w  (A0)+,(A1)+
                dbra    D0,copy5c
                dbra    D1,copy5d
                move.w  #$4E75,(A1)     ;rts
; -45
                move.w  #400/16-1,D1
;                lea     buf+v_m45,A1
				move.l	v_m45ptr,a1
copy6d:         move.w  #15-1,D2        ;15 first
copy6b:         move.w  #(d_m45_1_e-d_m45_1)/2-1,D0
                lea     d_m45_1(PC),A0
copy6:          move.w  (A0)+,(A1)+
                dbra    D0,copy6
                dbra    D2,copy6b
                move.w  #(d_m45_2_e-d_m45_2)/2-1,D0
                lea     d_m45_2(PC),A0
copy6c:         move.w  (A0)+,(A1)+
                dbra    D0,copy6c
                dbra    D1,copy6d
                move.w  #$4E75,(A1)     ;rts
                rts
****** Some data to use doing the lists ******
; in use: d3,d4,d5,d6,a1
; 45 <-> 90
d_45_90:        or.w    D6,(A1)         ;plot point
                adda.w  D3,A1
                add.w   D4,D5
                bcc.s   d_45_90_e
                ror.w   #1,D6
                bcc.s   d_45_90_e
                addq.w  #ww,A1
d_45_90_e:
; -45 <-> -90
d_m45_m90:
                or.w    D6,(A1)         ;plot point
                suba.w  D3,A1
                add.w   D4,D5
                bcc.s   d_m45_m90_e
                ror.w   #1,D6
                bcc.s   d_m45_m90_e
                addq.w  #ww,A1
d_m45_m90_e:
; 0 <-> 45
d_0_45_1:
                or.w    D6,(A1)         ;plot point
                ror.w   #1,D6           ;rotate to next point
                add.w   D4,D5           ;add fraction
                bcc.s   d_0_45_1_e      ;next y?
                adda.w  #lw,A1          ;next y
d_0_45_1_e:
d_0_45_2:
; the 16th one, adds to the next word
                or.w    D6,(A1)         ;plot point
                ror.w   #1,D6           ;rotate to next point
                addq.w  #ww,A1          ;next word
                add.w   D4,D5           ;add fraction
                bcc.s   d_0_45_2_e      ;next y?
                adda.w  D3,A1           ;next y
d_0_45_2_e:
; -0 <-> -45
d_m0_m45_1:
                or.w    D6,(A1)         ;plot point
                ror.w   #1,D6           ;rotate to next point
                add.w   D4,D5           ;add fraction
                bcc.s   d_m0_m45_1_e    ;next y?
                suba.w  #lw,A1          ;next y
d_m0_m45_1_e:
d_m0_m45_2:
; the 16th one, adds to the next word
                or.w    D6,(A1)         ;plot point
                ror.w   #1,D6           ;rotate to next point
                addq.w  #ww,A1          ;next word
                add.w   D4,D5           ;add fraction
                bcc.s   d_m0_m45_2_e    ;next y?
                suba.w  D3,A1           ;next y
d_m0_m45_2_e:
; 45
d_45_1:
                or.w    D6,(A1)         ;plot point
                adda.w  #lw,A1          ;next line
                ror.w   #1,D6           ;rotate
d_45_1_e:
d_45_2:
;16th adds the word offset
                or.w    D6,(A1)         ;plot point
                adda.w  D3,A1           ;next line
                ror.w   #1,D6           ;rotate
                addq.w  #ww,A1          ;next word
d_45_2_e:
; -45
d_m45_1:
                or.w    D6,(A1)         ;plot point
                suba.w  #lw,A1          ;next line
                ror.w   #1,D6           ;rotate
d_m45_1_e:
d_m45_2:
;16th adds the word offset
                or.w    D6,(A1)         ;plot point
                suba.w  D3,A1           ;next line
                ror.w   #1,D6           ;rotate
                addq.w  #ww,A1          ;next word
d_m45_2_e:
mul_tab:
i               SET 0
                REPT 200
                DC.w i*lw
i               SET i+1
                ENDR


copyStuff
;	lea		lines3,a0
;	lea		lines2,a1
	move.l	unpackedDataPointer,a0
	move.l	lineDataPointer,a1
	move.l	a1,a2
	move.l	lineDataPointer,framePointer
	move.w	#-1,d7
	moveq	#0,d6
	move.w	#49,d5
.gogo
	moveq	#0,d0
	move.b	(a0)+,d0			; is x or -1
	beq		.endFrame
		add.w	d5,d0			;x+50
		move.w	d0,(a1)+
		moveq	#0,d0
		move.b	(a0)+,d0		;y
		move.w	d0,(a1)+
	jmp		.gogo

.endFrame
	tst.b	(a0)+
	bne 	.error
	move.w	d7,(a1)+

	tst.w	(a0)
	bne		.gogo
	jmp		.end
.error
;	move.b	#0,$ffffc123
	nop
.end
	move.l	#-1,(a1)+
	move.l	#-1,(a1)+

;	sub.l	a2,a1
;	move.b	#0,$ffffc123


	rts


textFade
			;0	1		2	3	4	5		6	7	8		9	10	11	12	13		14	15
	dc.w	$740,$740,$740,$740,$740,$740,$740,$740,$740,$740,$740,$740,$740,$740,$740,$740

    section DATA
tapePal	
	dc.w	$777,$001,$740,$566,$555,$000,$640,$444,$531,$322,$222,$111,$101,$775,$666,$100
	dc.w	$777,$112,$751,$677,$666,$111,$751,$555,$642,$433,$333,$222,$212,$776,$777,$211
	dc.w	$777,$223,$762,$777,$777,$222,$762,$666,$753,$544,$444,$333,$323,$777,$777,$322
	dc.w	$777,$334,$773,$777,$777,$333,$773,$777,$764,$655,$555,$444,$434,$777,$777,$433

    IFEQ	PREPTAPE
tapelint
	incbin	'gfx/tape/tapemeasure3.neo'									; 32128 / 3562
prepTape
	lea		tapelint+128+47*160,a0
	lea		tapeBuffer,a3
	move.w	#107-1,d7
	moveq	#0,d1
.cp
	lea		5*8(a0),a0
	REPT 11
		move.l	(a0)+,d0
		move.l	d0,(a3)+
		move.l	(a0)+,d0
		move.l	d0,(a3)+
	ENDR
		move.l	d1,(a3)+			; we need 16 free bits on the right
		move.l	d1,(a3)+
		lea		4*8(a0),a0
	dbra	d7,.cp
	lea		tapeBuffer,a0
	sub.l	a0,a3
	move.b	#0,$ffffc123
	rts

tapeBuffer			ds.b	12*8*107		; 9416		--> 10272
	ELSE
	IFEQ	STANDALONE
tapeBuffer	incbin		"data/tape/tapepic3.bin"						; 9416		/ 3562
	ENDC
	ENDC
framePointer		dc.l	0

linedatacrk		incbin	'data/tape/tapedata.crk'						; 34765
			even

unpackedDataPointer	ds.l	1
lineDataPointer		ds.l	1

; 83 y
; 11 x

tl1buff		incbin	"data/tape/tl1buff.bin"
tl2buff		incbin	"data/tape/tl2buff.bin"
tl3buff		incbin	"data/tape/tl3buff.bin"
tl4buff		incbin	"data/tape/tl4buff.bin"
tl5buff		incbin	"data/tape/tl5buff.bin"

tlList
	dc.l	tl1buff
	dc.l	tl2buff
	dc.l	tl3buff
	dc.l	tl4buff
	dc.l	tl5buff
	dc.l	tl1buff
	dc.l	tl2buff
	dc.l	tl3buff
	dc.l	tl4buff
	dc.l	tl5buff

doTapeMove
	subq.w	#1,.times
	blt		.kz
	move.l	screenpointer2,a0
	lea		tlList,a1
	add.w	.off,a1
	move.l	(a1),a1

.y set 51*160
	REPT 19
.x set .y+11*8
		REPT 2
			move.l	(a1)+,.x(a0)
			move.l	(a1)+,.x+4(a0)
.x set .x+8
		ENDR
.y set .y+160
	ENDR

	subq.w	#1,.www
	bge		.k
	move.w	#4,.www
	sub.w	#4,.off
	bge		.k
		move.w	#16,.off
.k
	rts
.kz
	rts
.off	dc.w	16
.www	dc.w	1
.times	dc.w	450

;prepBuffs
;	lea		tl1+128,a0
;	lea		tl1buff,a1
;.y set 83*160
;	REPT 19
;.x set .y+11*8
;		REPT 2
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;	lea		tl2+128,a0
;	lea		tl2buff,a1
;.y set 83*160
;	REPT 19
;.x set .y+11*8
;		REPT 2
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;	lea		tl3+128,a0
;	lea		tl3buff,a1
;.y set 83*160
;	REPT 19
;.x set .y+11*8
;		REPT 2
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;	lea		tl4+128,a0
;	lea		tl4buff,a1
;.y set 83*160
;	REPT 19
;.x set .y+11*8
;		REPT 2
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;
;	lea		tl5+128,a0
;	lea		tl5buff,a1
;.y set 83*160
;	REPT 19
;.x set .y+11*8
;		REPT 2
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR	
;
;	lea		tl1buff,a0
;	lea		tl2buff,a1
;	lea		tl3buff,a2
;	lea		tl4buff,a3
;	lea		tl5buff,a4
;	move.b	#0,$ffffc123
;	rts
;
;tl1	incbin	"gfx/tape/frames/1.neo"
;tl2	incbin	"gfx/tape/frames/2.neo"
;tl3	incbin	"gfx/tape/frames/3.neo"
;tl4	incbin	"gfx/tape/frames/4.neo"
;tl5	incbin	"gfx/tape/frames/5.neo"

    IFEQ	STANDALONE
	section BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
snd
	ENDC


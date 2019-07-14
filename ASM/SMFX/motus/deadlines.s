
SCALE_SOURCE_HEIGHT	equ	53
SCALE_SOURCE_WIDTH	equ 18*16
SCALE_FRAMES		equ 22

; total size:
;	53*17*2*22 = 40kb



	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
DEADLINES_CRUSH_DELAY	equ 70
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1


	ENDC

ONE_BPL	equ 0


	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	TEXT

	include macro.s

	IFEQ	STANDALONE
			initAndRun	init_effect

init_effect
	jsr		init_demo
	move.w	#16000,effect_vbl_counter
	jsr		init_deadlines
	jsr		deadlines_mainloop
.demostart
.x
		move.l	screenpointer2,$ffff8200
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;
	rts

init_demo	
;	jsr		prepDeadlines
	move.w	#$777,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts
	ENDC

	even


init_deadlines
	jsr		init_deadline_pointers

	move.w	#$777,timer_b_open_curtain_stable_col+2

	move.w	#$2700,sr
	move.l	#deadlines_vbl,$70
	move.w	#$2300,sr

	movem.l	deadlinespal+2,d0-d7
	movem.l	d0-d6,$ffff8242
	swap	d7
	move.w	d7,$ffff8240+15*2

    rts


init_deadline_pointers
	move.l	screen2,d0
	add.l	#$10000,d0

	IFEQ	STANDALONE
		add.l	#$10000,d0
		move.l	d0,deadlines1ptr
		add.l	#1908,d0
		move.l	d0,deadlines4ptr
		add.l	#7632,d0
		move.l	d0,smfxtopptr
		add.l	#2640,d0
		move.l	d0,smfxbotptr
		add.l	#3952,d0
		move.l	d0,ytableBufferPointer
		add.l	#240,d0
		move.l	d0,deadlinesCanvasPointer
		add.l	#15264,d0
		move.l	d0,deadlinesBufferPointer
		add.l	#15264,d0
		move.l	d0,picBufferPointer
	ELSE
		move.l	#myZoomAnimationPointer,d0
		move.l	d0,deadlines1ptr
		add.l	#1908,d0
		move.l	d0,deadlines4ptr
		add.l	#7632,d0
		move.l	d0,smfxtopptr
		add.l	#2640,d0
		move.l	d0,smfxbotptr
		add.l	#3952,d0



		move.l	d0,ytableBufferPointer
		add.l	#240,d0
		move.l	d0,deadlinesCanvasPointer
		add.l	#15264,d0
		move.l	d0,deadlinesBufferPointer
		add.l	#15264,d0
		move.l	d0,picBufferPointer
	ENDC


	lea		deadlines1crk,a0
	move.l	deadlines1ptr,a1
	jsr		cranker

	lea		deadlines4crk,a0
	move.l	deadlines4ptr,a1
	jsr		cranker


	IFEQ	DEADLINES_HOLES
	move.l	deadlines4ptr,a0
	move.l	deadlines1ptr,a1
	move.w	#1908/2-1,d7
.lll
	movem.w	(a0)+,d0-d3
	or.w	d3,d0		
	or.w	d2,d0		
	or.w	d1,d0	
	move.w	d0,(a1)+
	dbra	d7,.lll	
	ENDC


	lea		smfxtopcrk,a0
	move.l	smfxtopptr,a1
	jsr		cranker

	lea		smfxbotcrk,a0
	move.l	smfxbotptr,a1
	jsr		cranker

	jsr		genytableBufferPointer

	IFEQ	ONE_BPL
		jsr		planarToChunky_deadlines_1bpl
	ELSE
		jsr		planarToChunky_deadlines	; convert planar pic to chunky
		jsr		calc1pxTab_deadline			; create 1to1 c2p tabs
	ENDC
	move.w	#$4e75,init_deadline_pointers
	rts

scrumytableBufferPointer
	move.l	deadlinesCanvasPointer,a0
	move.w	#15264/4-1,d7
	moveq	#0,d0
.cl
	move.l	d0,(a0)+
	dbra	d7,.cl
	rts



deadlines_vbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    subq.w	#1,effect_vbl_counter

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	#timer_b_open_curtain_stable,$120.w
	move.b	#188,$fffffa21.w		;Timer B data
	move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


    pushall
	move.l	screenpointer2,$ffff8200	
			swapscreens

;	clr.b	$fffffa1b.w			;Timer B control (stop)
;	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
;	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
;	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
;	move.l	#timer_b_open_curtain,$120.w
;	bclr	#3,$fffffa17.w			;Automatic end of interrupt
;	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

    IFNE	STANDALONE
    	jsr		musicPlayer+8
    ENDC


	jsr		myFadeStuff
    	cmp.w	#$4e75,precalcAnim
    	bne		.skip
    		IFEQ	ONE_BPL
    			jsr		displayPic1bpl
    		ELSE
	    		jsr		displayPic
	    	ENDC
.skip

    tst.w	bgColFlashCheckerOff
    bgt		.kkk
    	subq.w	#1,.delay
    	bge		.kkk
    	move.l	#smfx_crushes_deadlines_vbl_init,$70
.kkk
    popall
    rte
.delay	dc.w	DEADLINES_CRUSH_DELAY


envmap_go	dc.w	-1

smfx_crushes_deadlines_vbl_init
    move.l	#smfx_crushes_deadlines_vbl_init,$70
    move.w	#-1,envmap_go
smfx_crushes_deadlines_vbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    subq.w	#1,effect_vbl_counter
	move.l	screenpointer2,$ffff8200	


;	cmp.w	#101,smfxbotcounter
	tst.w	crunchDoneFlag
	beq		.doDyn
;	bne		.doDyn
.doStatic
	subq.w	#1,.hax
	beq		.doDyn
;		clr.b	$fffffa1b.w			;Timer B control (stop)
;		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
;		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
;		move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
;		move.l	#timer_b_open_curtain_checker_static,$120.w
;		bclr	#3,$fffffa17.w			;Automatic end of interrupt
;		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_checker_stable_static,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt



	jmp		.tbdone

.doDyn
		;Start up Timer B each VBL
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_checker_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
.tbdone

    pushall
	movem.l	smfxpaltop,d0-d7
	movem.l	d0-d7,$ffff8240
	move.w	#0,$ffff8240


	move.w	smfxbotcounter,d0
	move.w	#74,d1
	sub.w	d0,d1
	bge		.ok
;		move.b	#0,$ffffc123
		neg.w	d0
		add.w	#75,d0		; number of things to change
		move.w	#71-8,d1		; deadlines
		sub.w	d0,d1		; deadlines
		move.b	d1,deadlinestart
		move.w	#52+8+9,d1
		add.w	d0,d1
		add.w	d0,d1
		move.b	d1,deadlineend
		move.w	#76-9,d1
		sub.w	d0,d1
		move.b	d1,curtainclose

.ok

    IFNE	STANDALONE
    	jsr		musicPlayer+8
    ENDC


	jsr		crunch
	jsr		doSMFX

	subq.w	#1,.waiter3
	bge		.quit
		move.l	#omg_deadlines_vbl,$70
		move.w	#1,omgSize
.quit

			swapscreens

    popall
    rte
.hax	dc.w	1
.waiter3	dc.w	90

omg_deadlines_vbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    subq.w	#1,effect_vbl_counter
    pushall
	move.l	screenpointer,$ffff8200	
			swapscreens

	movem.l	smfxpaltop,d0-d7
	movem.l	d0-d7,$ffff8240

	tst.w	omgSize
	ble		.rr

	cmp.w	#$4e75,doOMG
	bne		.docurt
;	jmp		.afterhax
.tthax
;	move.w	#$300,$ffff8240
;.afterhax
	IFEQ	STANDALONE
	movem.l	orig+6,d0-d7
	ELSE
	movem.l	omgpal+2,d0-d7
	ENDC
	swap	d7
	movem.l	d0-d6,$ffff8240+2
	move.w	d7,$ffff8240

	move.w	#0,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		move.w	#0,tbdone

	jmp		.rr

.docurt

	move.w	#0,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain_middle,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	move.w	omgSize,d0
	move.w	#100,d1
	sub.w	d0,d1
	ble		.tthax

	move.b	d1,middlestart			; middlestart + middlesize + middle end. = 199
	add.w	d0,d0
	sub.w	#3,d0
	bgt		.kkkk
		move.w	#1,d0
.kkkk
	move.b	d0,middlesize
	move.w	#199,d0
	sub.b	middlestart,d0
	sub.b	middlesize,d0
	move.b	d0,middleend
.rr

    IFNE	STANDALONE
    	jsr		musicPlayer+8
    ENDC

.tt
    tst.w	tbdone
    bne		.tt
	jsr		doOMG
	move.w	#-1,tbdone
	jsr		copySMFX2


	popall
	rte
.onemoretime	dc.w	1

tbdone			dc.w	-1

deadlinestart	dc.b	71
				dc.b	0
deadlineend		dc.b	53
				dc.b	0

curtainclose	dc.b	75
				dc.b	0

middlestart		dc.b	98
				dc.b	0
middlesize		dc.b	2
				dc.b	0
middleend		dc.b	99
				dc.b	0

timer_b_open_curtain_middle	
	move.w	#$777,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	middlestart,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_middle,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#0,tbdone
	rte

timer_b_middle
	pusha0
	pusha1
		IFEQ	STANDALONE
		lea		orig+6,a0
		ELSE
		lea		omgpal+2,a0
		ENDC
		lea		$ffff8240+2,a1
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	middlesize,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_middle_bottom,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

timer_b_middle_bottom
	pusha0
	pusha1
		lea		smfxpalbot+2,a0
		lea		$ffff8240+2,a1
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	middleend,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	


timer_b_open_curtain_checker_static
	move.w	#$777,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#98,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_smfx_bott,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte




timer_b_open_curtain_checker_stable_static
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

		dcb.w	59,$4e71
		move.w	#$777,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#98,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_smfx_bott,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte





timer_b_smfx_bott
	pusha0
	pusha1
		lea	smfxpalbot+2,a0
		lea	$ffff8242,a1
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#101-1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain_stable,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	



timer_b_open_curtain_checker
	move.w	#$777,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	deadlinestart,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_deadline,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_open_curtain_checker_stable
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

		dcb.w	59,$4e71
		move.w	#$777,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
		move.b	#0,$fffffa1b.w			;Timer B control (stop)
		subq.b	#1,deadlinestart
		move.b	deadlinestart,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_deadline_stable,$120.w
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		addq.b	#1,deadlinestart
		rte	

timer_b_deadline_stable
		move.w	#$2700,sr
		movem.l	d0/a0/a1,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_open_curtain_checker_stable

.wait:		dcb.w	134,$4e71 

		lea		deadlinespal+2,a0
		lea		$ffff8240+2*1,a1
		REPT 7
		move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)
;		move.w	#$700,$ffff8240

		sub.b	#1,deadlineend

		move.b	#0,$fffffa1b.w			;Timer B control (stop)
		move.b	deadlineend,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_smfx_bot_stable,$120.w
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		addq.b	#1,deadlineend
		movem.l	(sp)+,d0/a0/a1
		rte	



timer_b_deadline
	pusha0
	pusha1
		lea		deadlinespal+2,a0
		lea		$ffff8240+2*1,a1
		REPT 7
		move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	deadlineend,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_smfx_bot,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_smfx_bot_stable
		move.w	#$2700,sr
		movem.l	d0/a0/a1,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_open_curtain_checker_stable

.wait:		dcb.w	134,$4e71 

;	move.w	#0,$ffff8240
		lea	smfxpalbot,a0
		lea	$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	
	
		move.b	#0,$fffffa1b.w			;Timer B control (stop)
		subq.b	#1,curtainclose
		move.b	curtainclose,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		addq.b	#1,curtainclose


		movem.l	(sp)+,d0/a0/a1
		rte		



timer_b_smfx_bot
	pusha0
	pusha1
		lea	smfxpalbot,a0
		lea	$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	curtainclose,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	



	IFEQ	STANDALONE
timer_b_open_curtain
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte

timer_b_close_curtain_stable
		move.w	#$2700,sr
		movem.l	d0/a0,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_smfx_bot

.wait:		dcb.w	134,$4e71 

		move.w	#$000,$ffff8240.w

		movem.l	(sp)+,d0/a0
		rte
	ENDC


;curPathSize is used to show current position
;	anything > 71 is crunched
; 	and every value counts for 2
;	so

;	move.w	#-71,d0
;	add.w	curPathSize,d0
;	add.w	d0,d0
;	neg.w	d0
;	add.w	#52

crunchList
	dc.w	48
	dc.w	36
	dc.w	18
	dc.w	8
	dc.w	1
crunchOff
	dc.w	0

crunch
	subq.w	#1,.waiter
	bge		.end
;	lea		deadlines+128,a0
;	lea		deadlines4,a0
	move.l	deadlines4ptr,a0
	move.l	screenpointer2,a1
;	add.w	#52*160,a0
	add.w	#(72+52)*160+1*8,a1

	move.l	a0,a5
	move.l	a1,a6

	moveq	#0,d0
	move.w	#52,d0
	asl.l	#8,d0

	lea		crunchList,a4
	add.w	crunchOff,a4
	move.w	(a4),d1
	move.w	d1,d3

	divs	d1,d0
	ext.l	d0
	subq.w	#1,d1
	asl.l	#8,d0

	move.l	#52<<16,d6


;	move.w	size,d3
	neg.w	d3
	add.w	#52,d3
	lsr.w	d3
	muls	#160,d3
	sub.w	d3,a6
	moveq	#0,d3

.x set 160
	REPT 40
		move.l	d3,.x(a6)
.x set .x+4
	ENDR

.cp

	move.l	d6,d5
	sub.w	d5,d5
	swap	d5
	muls	#144,d5
	move.l	a5,a0
	move.l	a6,a1
	add.w	d5,a0

.x set 0
		REPT 18
			move.l	.x(a0),.x(a1)
			move.l	.x+4(a0),.x+4(a1)
.x set .x+8
		ENDR

	sub.l	d0,d6
	sub.w	#160,a6

	dbra	d1,.cp
.skip
	moveq	#0,d6
.x set -160
	REPT 40
		move.l	d6,.x(a1)
.x set .x+4
	ENDR

	add.w	#2,crunchOff
	cmp.w	#8,crunchOff
	bne		.end
		move.w	#$4e75,crunch

;	subq.w	#1,.ttt
;	bge		.end
;		move.w	#2,.ttt
;		sub.w	#1,size
.end
	rts
.waiter	dc.w	16
.ttt	dc.w	2


doSMFX
;	subq.w	#1,.waiter
;	bge		.end


	move.w	smfxtopcounter,d0
	ble		.skiptop

;		lea		smfxtop,a0
		move.l	smfxtopptr,a0
		move.l	screenpointer2,a1
		add.w	#1*160,a1
		move.l	#0,a6

		; if we get here, we have lines to draw
		cmp.w	#33,d0			; if larger than 33, we need to skip lines :)
		ble		.noskiptop
			move.w	d0,d1
			sub.w	#33,d1
;			muls	#160,d1
;			add.w	d1,a1
			subq.w	#1,d1			; number of lines to clear
			moveq	#0,d6
.cl
				REPT 30
					move.l	d6,(a1)+
				ENDR
				lea		40(a1),a1
			dbra	d1,.cl
			move.w	#33-1,d7
			jmp		.cp1
.noskiptop
		; if we get here, we're less than 33, so we need to skip
		; d0 = number of lines, but smaller than 33
		move.w	d0,d1
		neg.w	d1
		add.w	#33,d1	; lines to skipp
		muls	#80,d1
		add.w	d1,a0
		move.w	d0,d7
		subq.w	#1,d7
		move.l	#0,a6
.cp1
			REPT 10
				move.l	a6,(a1)+
			ENDR
			REPT 20
				move.l	(a0)+,(a1)+
			ENDR
			REPT 10
				move.l	a6,(a1)+
			ENDR
		dbra	d7,.cp1

		tst.w	crunchDoneFlag
		beq		.skiptop
		moveq	#0,d0
		move.w	#20,d7
.cll
		REPT 40
			move.l	d0,(a1)+
		ENDR
		dbra	d7,.cll

.skiptop

	move.w	smfxbotcounter,d0
	ble		.skipbot
;		lea		smfxbot,a0
		move.l	smfxbotptr,a0
		move.l	screenpointer2,a1
		add.w	#(199)*160,a1
		move.l	#0,a6
		cmp.w	#38,d0
		ble		.noskipbot
			move.w	#38-1,d7
			move.w	d0,d1
			move.w	d1,d2
			sub.w	#38,d2
			move.w	d2,.leftOver
			muls	#160,d1
			sub.w	d1,a1
			jmp		.cp2
.noskipbot
		; if we get here we're less than 38
		move.w	d0,d7
		muls	#160,d0
		sub.w	d0,a1
		move.w	#-1,.leftOver
.cp2
			REPT 6
				move.l	a6,(a1)+
			ENDR

			REPT 26
				move.l	(a0)+,(a1)+
			ENDR

;			movem.l	(a0)+,d0-d6/a3/a4/a5			;11
;			movem.l	d0-d6/a3/a4/a5,(a1)
;			movem.l	(a0)+,d0-d6/a3/a4/a5
;			movem.l	d0-d6/a3/a4/a5,40(a1)
;			movem.l	(a0)+,d0-d5
;			movem.l	d0-d5,80(a1)
;.x set 104
			REPT 8
				move.l	a6,(a1)+
;.x set .x+4
			ENDR
;			lea		160-24(a1),a1
		dbra	d7,.cp2

		move.w	.leftOver,d7
		blt		.skipbot
			moveq	#0,d6
.cl2
			REPT 34
				move.l	d6,(a1)+
			ENDR
			lea		24(a1),a1
		dbra	d7,.cl2
.skipbot


	lea		deadlinespath,a0
	add.w	deadlinespathoff,a0
	move.w	(a0),d0
	move.w	d0,curPathSize
	move.w	d0,smfxbotcounter
	subq.w	#4,d0
	move.w	d0,smfxtopcounter

	add.w	#2,deadlinespathoff
	cmp.w	#29*2,deadlinespathoff
	ble		.okz
		move.w	#29*2,deadlinespathoff
.okz

;	add.w	#1,smfxtopcounter
	cmp.w	#97,smfxtopcounter
	ble		.tok
		move.w	#97,smfxtopcounter
		move.w	#-1,crunchDoneFlag
		subq.w	#1,.herp
		bge		.tok
			move.w	#$4e75,doSMFX
.tok
;	add.w	#1,smfxbotcounter
	cmp.w	#101,smfxbotcounter
	ble		.bok
		move.w	#101,smfxbotcounter
.bok	



.end
	rts
.leftOver	dc.w	0
.first		dc.w	0
.waiter		dc.w	40
.herp		dc.w	5
deadlinespathoff	dc.w	0
deadlinespath		include	"data/deadlines/path3.s"
crunchDoneFlag	dc.w	0
curPathSize		dc.w	0
smfxtopcounter	dc.w	-4
smfxbotcounter	dc.w	0



; vbl: set smfx
; timer b: open curtain, schedule timer to do meet deadlines palette
; timer_deadline, set deadline color, schedule timer for  end deadline
; timer_enddeadline, set smfx bottom color, schedule timer for close curtain
; close curtain




precalcAnim
	jsr		scrumytableBufferPointer
.calc
	cmp.w	#SCALE_SOURCE_WIDTH,curSize
	beq		.end
.last
			jsr		testScale
		IFEQ	ONE_BPL
			jsr		c2p1to1_deadlines_test_1bpl
		ELSE
			jsr		c2p1to1_deadlines_test
		ENDC
		jmp		.calc
.end
	move.w	#$4e75,precalcAnim

	tst.w	.done
	bne		.realend
		move.w	#-1,.done
		jmp		.last
.realend
	rts
.done	dc.w	0

deadlines_mainloop
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    	jsr		precalcAnim

    	IFNE	STANDALONE
    	tst.w	envmap_go
    	beq		.skip
    		jsr		precalc_envmap
.skip	
		ENDC
    	tst.w	effect_vbl_counter
    	blt		.next
    jmp		.w
.next
	rts


;--------------
;DEMOPAL - flash from 1bpl to 4bpl deadlines logo, flashing from white. from end of table to front
;--------------		
deadlinespal
bgColFlashChecker
	dc.w	$777,$345,$456,$567,$765,$566,$663,$564,$754,$553,$454,$644,$443,$344,$534,$233			;0
	dc.w	$666,$345,$456,$567,$765,$566,$663,$564,$754,$553,$454,$644,$443,$344,$534,$233			;32
	dc.w	$555,$345,$456,$567,$765,$566,$663,$564,$754,$553,$454,$644,$443,$344,$534,$333			;64
	dc.w	$444,$445,$456,$567,$765,$566,$664,$564,$754,$554,$454,$644,$444,$444,$544,$444			;96
	dc.w	$333,$555,$556,$567,$765,$566,$665,$565,$755,$555,$555,$655,$555,$555,$555,$555			;128
	dc.w	$222,$666,$666,$667,$766,$666,$666,$666,$766,$666,$666,$666,$666,$666,$666,$666			;160
	dc.w	$111,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777			;192
	dc.w	$111,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777			;224
bgColFlashCheckerOff	dc.w	224

myFadeStuff
	subq.w	#1,backgroundWaiter
	bge		.skip
		subq.w	#1,.fw
		bge		.skip
			move.w	#1,.fw
			sub.w	#32,bgColFlashCheckerOff
			bge		.skip2
				move.w	#0,bgColFlashCheckerOff
.skip2
			lea		bgColFlashChecker,a0
			add.w	bgColFlashCheckerOff,a0
			move.w	(a0),timer_b_open_curtain+2
			move.w	(a0)+,timer_b_open_curtain_stable_col+2
			lea		$ffff8240+2*1,a1
			REPT 15
				move.w	(a0)+,(a1)+
			ENDR
.skip
	rts
.fw	dc.w	0

displayPic1bpl
	tst.w	.ft
	bne		.notfirst
		move.w	#-1,.ft
		IFEQ	STANDALONE
			move.w	#21,backgroundWaiter
		ELSE
			move.w	#-1,backgroundWaiter
		ENDC
.notfirst
	move.l	picBufferPointer,a0
	add.l	.picOff,a0
	move.l	screenpointer2,a1
	add.w	#72*160+1*8,a1

	cmp.l	#((SCALE_SOURCE_WIDTH/16)*2)*SCALE_SOURCE_HEIGHT*SCALE_FRAMES,.picOff
	beq		.normal

	move.w	#SCALE_SOURCE_HEIGHT-1,d7
.l
.x set 0
		REPT SCALE_SOURCE_WIDTH/16
			IFEQ STANDALONE
				move.w	(a0)+,.x(a1)
			ELSE
				move.w	(a0)+,d0
				or.w	d0,.x(a1)
			ENDC
.x set .x+8
		ENDR

		lea		160(a1),a1
	dbra	d7,.l

	add.l	#((SCALE_SOURCE_WIDTH/16)*2)*SCALE_SOURCE_HEIGHT,.picOff
	rts
.picOff	dc.l	0
.normal
	move.l	deadlines4ptr,a0
	move.w	#SCALE_SOURCE_HEIGHT-1,d7
.cp
.x set 0
		REPT SCALE_SOURCE_WIDTH/16
			move.l	(a0)+,.x(a1)
			move.l	(a0)+,.x+4(a1)
.x set .x+8
		ENDR
		lea		160(a1),a1
	dbra	d7,.cp
	rts
.ft	dc.w	0
backgroundWaiter	dc.w	32000


curSize		dc.w	1


testScale
	moveq	#0,d0
	move.w	curSize,d0					; current size

	move.l	#0,d5						; clear
	moveq	#0,d2						; clear

	move.l	#SCALE_SOURCE_WIDTH,d1			; original width
	divu	d0,d1						; original width/ desired size
	move.w	d1,d2						; put whole in lower word
	clr.w	d1							; clear lower word
	swap	d1							; put remainder in lower word
	asl.l	#8,d1						; shift up 8 positions
	divu	d0,d1						; divide again
	asl.w	#8,d1		
	swap	d2							; swap words, so fraction is in lower
	or.w	d1,d2						; OR into the bits
	swap	d2							; fraction,whole					x step				03000002

	; so we have scale
	; scale * height = total scaled height
	; (total height - total scaled height) / 2 = lines skipped

	; y offset into chunky buffer
	move.l	#SCALE_SOURCE_WIDTH,d1			; total width
	moveq	#0,d5						; clear
	divu	d1,d0						; d0 is current width so we have size	(1/xstep)
	move.w	d0,d5						; save whole
	clr.w	d0							; clear	
	swap	d0
	asl.l	#8,d0				
	divu	d1,d0		
	asl.w	#8,d0
	swap	d5
	or.w	d0,d5						; whole,fraction

	move.w	d5,d6

	mulu	#SCALE_SOURCE_HEIGHT,d5
	swap	d5
	neg.w	d5
	add.w	#SCALE_SOURCE_HEIGHT,d5
	lsr.w	d5

	mulu	#SCALE_SOURCE_WIDTH,d5				;57

	mulu	#SCALE_SOURCE_WIDTH,d6
	swap 	d6
	neg.w	d6
	add.w	#SCALE_SOURCE_WIDTH,d6
	lsr.w	d6
	add.w	d6,d5


	; now to use this fraction to make the stepping into the linefilling code
	lea		.doLine,a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	#SCALE_SOURCE_WIDTH,d7
	move.l	d2,d3
.o set 0
	REPT SCALE_SOURCE_WIDTH				;4 kb
		move.w	d0,.o+2(a0)
		add.l	d2,d0
		addx.w	d1,d0
		cmp.w	d0,d7
		ble		.end
.o set .o+4
	ENDR
.end

	; now use the generated prestepped lineloop to copy from chunky buffer to canvas
;	lea		deadlinesBuffer,a0
	move.l	deadlinesBufferPointer,a0
;	lea		deadlinesCanvas,a1
	move.l	deadlinesCanvasPointer,a1
	add.w	d5,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d7
	move.w	#SCALE_SOURCE_HEIGHT,d5
	move.l	ytableBufferPointer,a2
;	lea		.ytable,a2
.doLine
	REPT SCALE_SOURCE_WIDTH				;1 kb
		move.b	-1(a0),(a1)+
	ENDR
	add.l	d3,d7						
	addx.w	d1,d7						
	move.w	d7,d6						
	add.w	d6,d6						
	add.w	d6,d6						
	move.l	(a2,d6.w),a0
	cmp.w	d7,d5
	bge		.doLine

	IFEQ	ONE_BPL
		add.w	#(SCALE_SOURCE_WIDTH/SCALE_FRAMES),curSize
	ELSE
		add.w	#(SCALE_SOURCE_WIDTH/SCALE_FRAMES),curSize
	ENDC
	cmp.w	#SCALE_SOURCE_WIDTH,curSize
	ble		.ok
		move.w	#SCALE_SOURCE_WIDTH,curSize
.ok
		rts

ytableBufferPointer	ds.l	1

genytableBufferPointer
	move.l	ytableBufferPointer,a0
	move.l	deadlinesBufferPointer,d0
	move.l	#SCALE_SOURCE_WIDTH,d1
	move.w	#60-1,d7
.ddd
		move.l	d0,(a0)+
		add.l	d1,d0
	dbra	d7,.ddd
	rts

;ytableBuffer
;.y set 0
;	REPT 60
;		dc.l	deadlinesBuffer+.y
;.y set .y+SCALE_SOURCE_WIDTH
;	ENDR






;	IFEQ	STANDALONE
;doScale
;	move.w	curSize,d0					; desired size
;	move.l	d0,a4						; save size
;
;	move.l	#0,d5						; clear
;	moveq	#0,d2						; clear
;
;	move.l	#SCALE_SOURCE_WIDTH,d1			; original width
;	divu	d0,d1						; original width/ desired size
;	move.w	d1,d2						; put whole in lower word
;	clr.w	d1							; clear lower word
;	swap	d1							; put remainder in lower word
;	asl.l	#8,d1						; shift up 8 positions
;	divu	d0,d1						; divide again
;	asl.w	#8,d1		
;	swap	d2							; swap words, so fraction is in lower
;	or.w	d1,d2						; OR into the bits
;	swap	d2							; fraction,whole					x step				03000002
;
;	; y offset into chunky buffer
;	move.l	#SCALE_SOURCE_WIDTH,d1		; total width
;	moveq	#0,d5
;	divu	d1,d0				; d0 is current width so we have size	(1/xstep)
;	move.w	d0,d5				; save
;	clr.w	d0					; clear	
;	swap	d0
;	asl.l	#8,d0				
;	divu	d1,d0		
;	asl.w	#8,d0
;	swap	d5
;	or.w	d0,d5
;
;;	mulu	#SCALE_SOURCE_WIDTH,d5				;57
;	; 320 =>	256 + 64
;	asl.l	#6,d5		; 64
;	move.l	d5,d0		; save
;	add.l	d5,d5		;128
;	add.l	d5,d5		;256
;	add.l	d0,d5		;256+64
;
;
;	swap	d5					; fradtion,whole y step
;	neg.w	d5
;	add.w	#SCALE_SOURCE_HEIGHT,d5
;	lsr		d5					; half y
;
;;	mulu	#(SCALE_SOURCE_WIDTH/16)*2*4,d5				;84	= (224/16)*2*3
;
;	; 320/16 = 20 * 2 * 4 =  160
;	;	32+128
;	asl.w	#5,d5
;	move.w	d5,d0
;	add.w	d5,d5
;	add.w	d5,d5
;	add.w	d0,d5
;
;	move.w	d5,a5
;
;; now that we have all in order, lets smc some data
;
;
;
;
;
;	move.l	chunkypicbsspointer,a0
;
;	; add offset thats not used
;	; clear offset value
;	moveq	#0,d0
;	move.l	#$10280000,d3
;	moveq	#0,d1
;	; now do smc
;	move.w	a4,d4
;	add.w	d4,d4	;2
;	add.w	d4,d4	;4
;	add.w	d4,d4	;8
;	neg.w	d4
;	move.w	#SCALE_SOURCE_WIDTH,d6
;	add.w	#SCALE_SOURCE_WIDTH*8,d4
;	; load for smc
;
;;	lea		.jmptable2,a3	
;	move.l	planarConversionCodePointer,a3	
;	move.l	smcCodePointer,a1
;	lea		.return,a2
;;	jmp		(a1,d4.w)
;	jmp		.smcCode(pc,d4.w)			; offset in d4
;.smcCode	
;o set 0
;	REPT 320/16												; 320*8 = 2560
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
;;	jmp		(a2)						;4ED2
;
;.return
;	move.w	#picture_height_3bpl-1,d7
;	moveq	#0,d5
;	moveq	#0,d0
;	moveq	#0,d6
;	move.l	yofflistpointer,a3
;	move.l	d2,a4	
;	move.w	#picture_height_3bpl,a6
;
;	move.l	planarpicbsspointer,a1
;	add.l	planarOffset,a1
;	; and here we should add height as well
;	add.w	a5,a1
;	lea		hax,a2
;	move.l	planarConversionCodePointer,a5
;.doLine
;	move.w	d5,d0																					;3005	
;	add.w	d0,d0																					;D040
;	add.w	d0,d0																					;D040
;	move.l	(a3,d0.w),a0			;20																;2073 0000
;	jsr		(a5)
;	add.l	a4,d5
;	addx.w	d6,d5
;	cmp.w	a6,d5
;	bgt		.end
;	jmp		.doLine
;.end
;	add.l	#planaroffsetconst,planarOffset
;	rts	
;	ENDC



c2p1to1_deadlines_test_1bpl
	cmp.w	#SCALE_SOURCE_WIDTH,curSize
	bne		.skipOrig
		move.l	deadlinesBufferPointer,a4
		jmp		.done
.skipOrig
	move.l	deadlinesCanvasPointer,a4
.done
	move.l	picBufferPointer,a2
	add.l	.picOff,a2
	
	move.w	#SCALE_SOURCE_HEIGHT-1,d7
.l
	REPT (SCALE_SOURCE_WIDTH/16)

		REPT 16
			move.b	(a4)+,d0				;16*6+2 = 98  (*20 = 1960)
			add.b	d0,d0
			addx.w	d4,d4
		ENDR
		move.w	d4,(a2)+
	ENDR
	dbra	d7,.l

	add.l	#((SCALE_SOURCE_WIDTH/16)*2)*SCALE_SOURCE_HEIGHT,.picOff
	cmp.l	#((SCALE_SOURCE_WIDTH/16)*2)*SCALE_SOURCE_HEIGHT*SCALE_FRAMES,.picOff
	bne		.kk
		move.w	#$4e75,c2p1to1_deadlines_test_1bpl
.kk
	rts	
.picOff	dc.l	0


planarToChunky_deadlines_1bpl
	move.l	deadlines1ptr,a0
	move.l	deadlinesBufferPointer,a1

	move.l	#SCALE_SOURCE_HEIGHT-1,d6						;height

.height
	move.l	#(SCALE_SOURCE_WIDTH/16)-1,d7						;width
.width
		move.w	(a0)+,d0
;		movem.w	(a0)+,d0-d3						;1st plane
;		or.w	d1,d0
;		or.w	d2,d0
;		or.w	d3,d0
		REPT 16
			moveq	#0,d4
			moveq	#0,d5
			roxl.w	d5
			roxl.w	d0
			roxl.w	d4
			lsl.w	#7,d4
			move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
		ENDR
		dbra	d7,.width
;	lea		((320-SCALE_SOURCE_WIDTH)/16)*8(a0),a0
	dbra	d6,.height						; 128 * ( 32*4 + 8*16 ) = 128 * (128+128) = 32768
	rts	



	IFNE	ONE_BPL

displayPic
;	lea		picBuffer,a0
	move.l	picBufferPointer,a0
	add.l	.picOff,a0
	move.l	screenpointer2,a1
	add.w	#90*160,a1
	move.w	#SCALE_SOURCE_HEIGHT-1,d7
.l

		movem.l	(a0)+,d0-d6/a2/a3/a4
		movem.l	d0-d6/a2/a3/a4,(a1)
		movem.l	(a0)+,d0-d6/a2/a3/a4
		movem.l	d0-d6/a2/a3/a4,40(a1)
		movem.l	(a0)+,d0-d6/a2/a3/a4
		movem.l	d0-d6/a2/a3/a4,80(a1)
		movem.l	(a0)+,d0-d6/a2/a3/a4
		movem.l	d0-d6/a2/a3/a4,120(a1)
		lea		160(a1),a1

	dbra	d7,.l
	add.l	#160*22,.picOff
	cmp.l	#160*22*40,.picOff
	bne		.kkkk
		move.l	#160*22*39,.picOff
.kkkk
	rts
.picOff	dc.l	0

c2p1to1_deadlines_test
;	lea		deadlinesBuffer,a4
	cmp.w	#SCALE_SOURCE_WIDTH,curSize
	bne		.skipOrig
		move.l	deadlinesBufferPointer,a4
;		lea		deadlinesBuffer,a4
		jmp		.done
.skipOrig
;	lea		deadlinesCanvas,a4
	move.l	deadlinesCanvasPointer,a4
.done
;	move.l	screenpointer2,a2
;	add.w	#90*160,a2
;	lea		picBuffer,a2
	move.l	picBufferPointer,a2
	add.l	.picOff,a2

    move.l 	tab1px_1p_deadline,d0					; c2p_1px_tab_aligned1
    move.l 	tab1px_2p_deadline,d1					; c2p_1px_tab_aligned2
    move.l 	tab1px_3p_deadline,d2					; c2p_1px_tab_aligned2
    move.l 	tab1px_4p_deadline,d3					; c2p_1px_tab_aligned2


    move.w	#SCALE_SOURCE_HEIGHT-1,d4
.loop
y set 0
;	REPT 75												;13312
a               set y
    	REPT    SCALE_SOURCE_WIDTH/16									
    		move.w  (a4)+,d0				;8	
    		move.w  (a4)+,d1				;8	
    		move.w  (a4)+,d2				;8	
    		move.w	(a4)+,d3				;8		--> 32
    										;	
    		move.l	d0,a3					;4
    		move.l  (a3),d7					;12						
    		move.l	d1,a3					;4
    		or.l    (a3),d7					;16						
    		move.l	d2,a3					;4
    		or.l    (a3),d7					;16						
    		move.l	d3,a3					;4
    		or.l    (a3),d7					;16			16+3*20 = 76			
    		movep.l d7,a(a2) 				;24			+24				==> 32 + 100 = 132*2 = 
	;-----------
   			move.w  (a4)+,d0				;8
    		move.w  (a4)+,d1				;8
    		move.w  (a4)+,d2				;8
    		move.w	(a4)+,d3				;8
   		
    		move.l	d0,a3					;4
    		move.l  (a3),d7					;12
    		move.l	d1,a3					;4
    		or.l    (a3),d7					;16
    		move.l	d2,a3
    		or.l    (a3),d7					;16
    		move.l	d3,a3
    		or.l    (a3),d7			;20
    		movep.l d7,a+1(a2) 				;24 		32+16+20+60 = 48+80 = 128 => 256 for 16 px => 16 cycles per

a           set a+8
    endr
    		lea		160(a2),a2
    	dbra	d4,.loop


    	add.l	#160*22,.picOff
    	cmp.l	#160*22*40,.picOff
    	bne		.kk
    		move.w	#$4e75,c2p1to1_deadlines_test
.kk
	rts
.picOff	dc.l	0

	
;planarToChunky_deadlines
;	lea		deadlines+128+89*160,a0
;;	lea		deadlinesBuffer,a1
;	move.l	deadlinesBufferPointer,a1
;
;	move.l	#SCALE_SOURCE_HEIGHT-1,d6
;
;.height
;	move.l	#20-1,d7
;.width
;	movem.w	(a0)+,d0-d3		; 4 words
;	REPT 16
;		moveq	#0,d4
;		moveq	#0,d5
;		roxl.w	d5
;		roxl.w	d3
;		roxl.w	d4
;		roxl.w	d2
;		roxl.w	d4
;		roxl.w	d1
;		roxl.w	d4
;		roxl.w	d0
;		roxl.w	d4
;		add.w	d4,d4
;		add.w	d4,d4
;		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
;	ENDR
;	dbra	d7,.width
;	dbra	d6,.height						; 128 * ( 32*4 + 8*16 ) = 128 * (128+128) = 32768
;	rts

calc1pxTab_deadline
	move.l 	tab1px_1p_deadline,a5
	lea     TAB1,a0
	move.w	#16-1,d7
	moveq   #0,d3
.oloop1
	moveq   #0,d4
	move.l	a5,a6
	move.w	#16-1,d6
.iloop1
			move.l  (a0,d3.w),d2
			and.l   #$80808080,d2
	
			move.l  (a0,d4.w),d5
			and.l   #$40404040,d5
			or.l    d5,d2
	
			move.l  d2,(a6)+
			addq.w  #4,d4
		dbra	d6,.iloop1

		lea     $0400(a5),a5
		addq.w  #4,d3
	dbra	d7,.oloop1
 

	move.l	tab1px_2p_deadline,a5
	lea     TAB2,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop2
        moveq   #0,d4
        move.w	#16-1,d6
        move.l	a5,a6
.iloop2
        	move.l  0(a0,d3.w),d2
        	and.l   #$20202020,d2
 
        	move.l  0(a0,d4.w),d5
        	and.l   #$10101010,d5
        	or.l    d5,d2
 
        	move.l  d2,(a6)+
        	addq.w  #4,d4
        	dbra	d6,.iloop2
        lea     $0400(a5),a5
        addq.w  #4,d3
    dbra	d7,.oloop2


	move.l	tab1px_3p_deadline,a5
	lea     TAB3,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop3
		moveq   #0,d4
		move.l	a5,a6
		move.w	#16-1,d6
.iloop3
			move.l  0(a0,d3.w),d2
			and.l   #$08080808,d2
			
			move.l  0(a0,d4.w),d5
			and.l   #$04040404,d5
			or.l    d5,d2

;			cmpa.l  #$00000400,a6
;			blt     .nolsdo22
				move.l  d2,(a6)+
;.nolsdo22:
	        addq.w  #4,d4
	    dbra	d6,.iloop3

        lea     $0400(a5),a5
        addq.w  #4,d3
      	dbra	d7,.oloop3
 


	move.l	tab1px_4p_deadline,a5
	lea     TAB4,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop4
		moveq   #0,d4
		move.l	a5,a6
		move.w	#16-1,d6
.iloop4
			move.l  0(a0,d3.w),d2
			and.l   #$02020202,d2
			
			move.l  0(a0,d4.w),d5
			and.l   #$01010101,d5
			or.l    d5,d2
			
			move.l  d2,(a6)+
			addq.w  #4,d4
		dbra	d6,.iloop4
		lea     $0400(a5),a5
		addq.w  #4,d3
	dbra	d7,.oloop4
 	rts



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


	section DATA

;SCALE_SOURCE_HEIGHT	equ	53
;SCALE_SOURCE_WIDTH		equ 18*16

;prepDeadlines
;	lea		deadlines+128,a0
;	lea		deadlines4,a1
;	move.w	#SCALE_SOURCE_HEIGHT-1,d7
;.cp
;.x set 0
;	REPT SCALE_SOURCE_WIDTH/16
;		move.l	.x(a0),(a1)+
;		move.l	.x+4(a0),(a1)+
;.x set .x+8
;	ENDR
;	lea		160(a0),a0
;	dbra	d7,.cp
;
;
;	lea		deadlinesb+128,a0
;	lea		deadlines1,a1
;	move.w	#SCALE_SOURCE_HEIGHT-1,d7
;.cp2
;.x set 0
;	REPT SCALE_SOURCE_WIDTH/16
;		move.w	.x(a0),(a1)+
;.x set .x+8
;	ENDR
;	lea		160(a0),a0
;	dbra	d7,.cp2
;
;	lea		deadlines1,a0
;	lea		deadlines4,a1
;	move.b	#0,$ffffc123
;	rts




deadlines1ptr	ds.l	1
deadlines4ptr	ds.l	1
smfxtopptr		ds.l	1
smfxbotptr		ds.l	1

deadlines1crk	incbin	"data/deadlines/deadlines1.crk"		;crunched 1908 to 598 bytes
	even
deadlines4crk	incbin	"data/deadlines/deadlines4.crk"		;crunched 7632 to 4162 bytes
	even
																						; 
smfxtopcrk		incbin	"data/deadlines/smfxtop.crk"		;crunched 2640 to 1652 bytes								; 10*16 wide, 33 high, start: 5*8 bytes off
	even
smfxbotcrk		incbin	"data/deadlines/smfxbot.crk"		;crunched 3952 to 1618 bytes								; 13*16 wide, 38 high, start: 3*8 bytes off
	even

;deadlines	incbin	"data/deadlines/deadlines9.neo"
;deadlinesb	incbin	"data/deadlines/deadlines9b.neo"

;deadlines1	incbin	"data/deadlines/deadlines1.bin"		;crunched 1908 to 598 bytes
;deadlines4	incbin	"data/deadlines/deadlines4.bin"		;crunched 7632 to 4162 bytes
																						; 
;smfxtop		incbin	"data/deadlines/smfxtop.bin"		;crunched 2640 to 1652 bytes								; 10*16 wide, 33 high, start: 5*8 bytes off
;smfxbot		incbin	"data/deadlines/smfxbot.bin"		;crunched 3952 to 1618 bytes								; 13*16 wide, 38 high, start: 3*8 bytes off


;--------------
;DEMOPAL - smfx logo top and bottom palettes
;--------------		
smfxpaltop		dc.w	$777,$666,$774,$762,$751,$640,$730,$710,$600,$362,$242,$132,$222,$112,$111,$000
smfxpalbot		dc.w	$777,$666,$222,$111,$764,$752,$642,$532,$422,$566,$456,$346,$235,$464,$354,$244

	IFEQ	STANDALONE
orig	incbin	"gfx/omg!/omg2!.neo"
	even
	ENDC


;smfxtop		ds.b	10*8*33		; start: 5*8 bytes off
;smfxbot		ds.b	13*8*38		; start: 3*8 bytes off
;
;smfxlogo	incbin	"data/deadlines/smfx.neo"
;
;prepLogo
;	lea		smfxlogo+128+67*160,a0
;	lea		smfxtop,a1
;	move.w	#33-1,d7
;.cp
;.x set 40
;		REPT 10
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;		lea		160(a0),a0
;	dbra	d7,.cp
;
;	lea		smfxlogo+128+100*160,a0
;	lea		smfxbot,a1
;	move.w	#38-1,d7
;.cp2
;.x set 24
;		REPT 13
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;		lea		160(a0),a0
;	dbra	d7,.cp2
;
;	lea		smfxtop,a0
;	move.b	#0,$ffffc123		;2640
;	lea		smfxbot,a0
;	move.b	#0,$ffffc123		;3952
;	rts



	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
    ENDC

copySMFX2
	cmp.w	#99,omgSize
	bge		.end
	move.l	screenpointer2,a1
	move.l	smfxtopptr,a0
	; relate omgsize to the 2 positions of the smfx parts
	move.w	#68,d0
	sub.w	omgSize,d0
	bge		.kk
		move.w	d0,d1
		move.w	#33-1,d7
		neg.w	d1	
		sub.w	d1,d7
		move.w	d1,d2
		muls	#80,d2
		add.w	d2,a0
		jmp		.doTop
.kk
	muls	#160,d0
	add.w	d0,a1
	move.w	#33-1,d7
.doTop
	lea		40(a1),a1
	REPT 	20
		move.l	(a0)+,(a1)+
	ENDR
	lea		40(a1),a1

	dbra	d7,.doTop



	move.l	smfxbotptr,a0
	move.l	screenpointer2,a1
	move.w	#68+30,d0
	add.w	omgSize,d0
	move.w	#200-33,d1
	sub.w	d0,d1
	bge		.kkkk2
		move.w	#33-1,d7
		muls	#160,d0
		add.w	d0,a1
		neg.w	d1
		sub.w	d1,d7
;		move.w	d1,d2
;		muls	#160,d2
;		sub.w	d2,a1
;		muls	#30,d1
;		jmp		.tab2(pc,d1)
		jmp		.tab2
.kkkk2

	move.w	#33-1,d7
	muls	#160,d0
	add.w	d0,a1
.tab2
;.y set 24
;	REPT 33
;			movem.l	(a0)+,d0-d6/a3/a4/a5			;4
;			movem.l	d0-d6/a3/a4/a5,.y(a1)			;6
;			movem.l	(a0)+,d0-d6/a3/a4/a5			;4
;			movem.l	d0-d6/a3/a4/a5,40+.y(a1)		;6
;			movem.l	(a0)+,d0-d5						;4
;			movem.l	d0-d5,80+.y(a1)					;6
;.y set .y+160
;	ENDR
		lea	24(a1),a1
		REPT 26
			move.l	(a0)+,(a1)+			;104+24 = 128
		ENDR
		lea	32(a1),a1
	dbra	d7,.tab2


.end
	move.l	screenpointer2,a0
	moveq	#0,d0
	REPT 40
		move.l	d0,(a0)+
	ENDR

	rts

doOMG
	move.w	omgSize,d0
	ble		.end
		cmp.w	#100,d0
		ble		.kkkk
			subq.w	#1,.twice
			bge		.kkkk
			move.w	#100,d0
			move.w	#100,omgSize
			move.w	#$4e75,doOMG
.kkkk
		IFEQ	STANDALONE
			lea		orig+128,a0
		ELSE
			move.l	omgpointer,a0
			add.w	#128,a0
		ENDC
		move.l	screenpointer2,a1
;		move.b	#0,$ffffc123
		move.w	#100,d1				; middle
		move.w	d1,d7
		sub.w	d0,d7
		move.w	d7,.save
		muls	#160,d7
		add.w	d7,a1				; top screen
		add.w	d7,a0				; start source

; how abouw we do top + bottom

		move.w	d0,d7
		lsr.w	#1,d7
		subq.w	#1,d7
		blt		.end
		cmp.w	#10,d7
		blt		.cp
			moveq	#5,d7
.cp
.x set 0
			REPT 80
				move.l	(a0)+,(a1)+
.x set .x+4
			ENDR
;.x set 0
;			movem.l	(a0)+,d0-d6/a2-a6			;7+5 = 12 = 48
;			movem.l	d0-d6/a2-a6,.x(a1)
;			movem.l	(a0)+,d0-d6/a2-a6			;7+5 = 12 = 48
;			movem.l	d0-d6/a2-a6,.x+48(a1)
;			movem.l	(a0)+,d0-d6/a2-a6			;7+5 = 12 = 48
;			movem.l	d0-d6/a2-a6,.x+96(a1)
;			movem.l	(a0)+,d0-d3
;			movem.l	d0-d3,.x+144(a1)
;.x set .x+160
;			movem.l	(a0)+,d0-d6/a2-a6			;7+5 = 12 = 48
;			movem.l	d0-d6/a2-a6,.x(a1)
;			movem.l	(a0)+,d0-d6/a2-a6			;7+5 = 12 = 48
;			movem.l	d0-d6/a2-a6,.x+48(a1)
;			movem.l	(a0)+,d0-d6/a2-a6			;7+5 = 12 = 48
;			movem.l	d0-d6/a2-a6,.x+96(a1)
;			movem.l	(a0)+,d0-d3
;			movem.l	d0-d3,.x+144(a1)
;			lea		320(a1),a1
	dbra	d7,.cp



; bottom
	move.w	omgSize,d0
	move.w	d0,d7
	add.w	#100,d0
	muls	#160,d0

	IFEQ	STANDALONE
		lea		orig+128,a0
	ELSE
		move.l	omgpointer,a0
		add.w	#128,a0
	ENDC
	move.l	screenpointer2,a1
	add.w	#160*99,a0
	add.w	#160*99,a1

.chc
	cmp.w	#20,d7
	blt		.gog
		sub.w	#10,d7
		add.w	#160*10,a0
		add.w	#160*10,a1
		jmp		.chc
.gog

	subq.w	#1,d7
.cp2
.x set 0
		REPT 40
			move.l	(a0)+,(a1)+
		ENDR
	dbra	d7,.cp2


.end

	move.l	screenpointer2,a0
	moveq	#0,d0
	REPT 40
		move.l	d0,(a0)+
	ENDR
;	subq.w	#1,.waiter3
;	bge		.quit

		add.w	#1,omgSize
;.quit
	rts
.twice	dc.w	2
.save	dc.w	0
;.waiter3	dc.w	90
omgSize		dc.w	0


deadlinesCanvasPointer	ds.l	1	
deadlinesBufferPointer	ds.l	1
picBufferPointer		ds.l	1

;					ds.b	2
;deadlinesCanvas		ds.b	SCALE_SOURCE_WIDTH*SCALE_SOURCE_HEIGHT		;14416
;					ds.b	2
;deadlinesBuffer		ds.b	SCALE_SOURCE_WIDTH*SCALE_SOURCE_HEIGHT		;14416
tab1px_1p_deadline	ds.l	1
tab1px_2p_deadline	ds.l	1
tab1px_3p_deadline	ds.l	1
tab1px_4p_deadline	ds.l	1


    IFEQ	STANDALONE
	section BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
	ENDC

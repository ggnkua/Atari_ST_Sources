
nr_of_frames		equ	13
GREETINGS_WAITER	equ 90
NR_OF_GREETINGS		equ 8
blockCodeUsed		equ 1


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

	ENDC

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	TEXT

	include macro.s

	IFEQ	STANDALONE
			initAndRun	init_effect

init_effect
;	jsr		prepTunnel


	jsr		init_demo
	move.w	#500,effect_vbl_counter
	jsr		init_greetings

	rts
.demostart	
.x
		move.l	screenpointer2,$ffff8200
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts


init_demo
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts
	ENDC


init_greetings
	move.l	screen2,d0
	move.l	d0,clearBlocksPtr
	move.l	d0,clearBlocksPtr2

	add.l	#65536*7,d0
	move.l	d0,x_table_pointer_explode
	add.l	#20*16*4,d0
	move.l	d0,blockCodePointer
	add.l	#5120,d0
	move.l	d0,explode_clear1aPointerGreetings
	add.l	#1600,d0
	move.l	d0,explode_clear1bPointerGreetings
	add.l	#1600,d0
	move.l	d0,explode_clear2aPointerGreetings
	add.l	#1600,d0
	move.l	d0,explode_clear2bPointerGreetings
	add.l	#1600,d0
	move.l	d0,explode_clear3aPointerGreetings
	add.l	#1600,d0
	move.l	d0,explode_clear3bPointerGreetings
	add.l	#1600,d0
	move.l	d0,renderPointer
	add.l	#120*160,d0
	move.l	d0,greetings_blocks_pointer
	add.l	#160*120,d0


	move.l	screen1,a0
	move.w	#99-1,d7
	moveq	#0,d0
.xxx
		REPT 40
			move.l	d0,(a0)+
		ENDR
	dbra	d7,.xxx
	lea		70*160(a0),a0
	move.w	#31-1,d7
.xxx2
	REPT 40
		move.l	d0,(a0)+
	ENDR

	dbra	d7,.xxx2

	move.w	#$2700,sr
	move.l	#greetings_vbl_intro,$70
	move.w	#$2300,sr

	jsr		prepScreenList
	lea		screenList,a0
	move.l	(a0),a1
	lea		vtunnelcrk,a0
	jsr		cranker
	move.l	renderPointer,a0
	moveq	#0,d0
	move.w	#100-1,d7
.llx
	REPT 40
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.llx

	lea		blockCodecrk,a0
	move.l	blockCodePointer,a1
	jsr		cranker

	jsr		genBlockSizes

	lea		greetingsCrank,a0
	move.l	greetingsPointer,a1
	jsr		cranker

	move.l	greetingsPointer,d0
	lea		explodeSourceList,a0
	move.l	d0,(a0)+
	add.l	#3056,d0
	move.l	d0,(a0)+
	add.l	#2552,d0
	move.l	d0,(a0)+
	add.l	#2624,d0
	move.l	d0,(a0)+
	add.l	#2240,d0
	move.l	d0,(a0)+
	add.l	#2432,d0
	move.l	d0,(a0)+
	add.l	#1736,d0
	move.l	d0,(a0)+
	add.l	#3000,d0
	move.l	d0,(a0)+
	add.l	#2200,d0
	move.l	d0,(a0)+

;	jsr		initHighTonesList

	movem.l	explode_clear1aPointerGreetings,a0-a5
	move.l	#-1,(a0)
	move.l	#-1,(a1)
	move.l	#-1,(a2)
	move.l	#-1,(a3)
	move.l	#-1,(a4)
	move.l	#-1,(a5)

	jsr		genExplodeXTable
	jsr		copySourceExplode
	jsr		renderBlocks

.effect
	jsr		.precalcLocal
	tst.w	effect_vbl_counter
	bge		.effect
    rts
.precalcLocal
	IFNE	STANDALONE
		jsr		init_tapetext_pointers
		jsr		initDivTable
		jsr		initDivTable2
	ENDC	
	move.w	#$4e75,.precalcLocal
	rts






greetings_vbl_intro
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
    subq.w	#1,effect_vbl_counter
    pushall
    move.l	screen1,$ffff8200
        	IFNE	STANDALONE

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain_static,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w	
    		ENDC    	

   	move.l	#$7770777,d0
   	lea		$ffff8242,a0
   	REPT 7
   		move.l	d0,(a0)+
   	ENDR
   	move.w	d0,(a0)+
   	move.w	#$300,$ffff8240+8*2

   	subq.w	#1,.frameskip
 	bge	.cont
		move.l	screen2,$ffff8200
    	move.l	#greetings_vbl,$70
.cont

    IFNE	STANDALONE
    	jsr		musicPlayer+8
    ENDC


    popall



    rte
.frameskip	dc.w	37



greetings_vbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    subq.w	#1,effect_vbl_counter
    pushall

	lea		timer_b_list,a0
	add.w	timer_b_listOff,a0
	move.l	(a0),d0

	;Start up Timer B each VBL
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	d0,$120.w
	move.b	#188,$fffffa21.w		;Timer B data
	move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt	


	move.b	musicPlayer+$b8,d0
	cmp.b	#$ff,d0
	bne		.nope
		move.w	#1,.drumwaiter
.nope

		subq.w	#1,.drumwaiter
		bge		.kkk
			move.w	#6,.drumwaiter
			jsr		doDrumFade
.kkk
	moveq	#0,d1
	cmp.b	#$dd,d0
	bne		.noadd
		move.w	#6,d1
		jmp		.dobar
.noadd
	cmp.b	#$de,d0
	bne		.nobar
.dobar
		move.b	#0,musicPlayer+$b8

		cmp.w	#16*54,highTonesListOff
		beq		.nobar

		lea		highTonesList,a0
		add.w	highTonesListOff,a0

		lea		barsColorList,a1
		add.w	barsColorListOff,a1
		add.w	#4,a1
		add.w	d1,a1
		jmp		.ttt
.next
		lea		16(a0),a0
		add.w	#2,a1
.ttt
		tst.l	(a0)
		bge		.next


		move.w	(a1),d0			; color value
		cmp.w	#$765,d0
		bne		.next1
			move.l	#label765,8(a0)
			jmp		.cont
.next1
		cmp.w	#$567,d0
		bne		.next2
			move.l	#label567,8(a0)
			jmp		.cont
.next2
		cmp.w	#$753,d0
		bne		.next3
			move.l	#label753,8(a0)
			jmp		.cont
.next3
		cmp.w	#$675,d0
		bne		.next4
			move.l	#label675,8(a0)
			jmp		.cont
.next4		
		cmp.w	#$667,d0
		bne		.next5
			move.l	#label667,8(a0)
			jmp		.cont
.next5
		cmp.w	#$576,d0
		bne		.next6
			move.l	#label576,8(a0)
			jmp		.cont
.next6
;		move.b	#0,$ffffc123
		jmp		.next
			move.l	#label777,8(a0)
.cont


		move.l	a1,4(a0)



		move.l	#15,(a0)
		add.w	#16,highTonesListOff
		; here we add the current thing to a list to fade
.nobar
	
    jsr		setColorBars


    	move.w	#0,$ffff8240+2*4
    	move.w	#0,$ffff8240+2*5
    	move.w	#0,$ffff8240+2*6
    	move.w	#0,$ffff8240+2*7

    IFNE	STANDALONE
    	jsr		musicPlayer+8
    ENDC


	tst.w	.swapCols
	beq		.sss
		jsr		swapCols
		move.w	#0,.swapCols

.sss


    lea		screenList,a0
    add.w	.screenOff,a0
    move.l	(a0),d0
    move.l	d0,screenpointer2
    lsr.w	#8,d0
    move.l	d0,$ffff8200
    add.w	#4,.screenOff
    cmp.w	#nr_of_frames*4,.screenOff
    bne		.kk
    	move.w	#0,.screenOff
.kk


	tst.w	arpOn
	bge		.skip
		subq.w	#1,.explodeWaiter
		bge		.skip
			jsr		doGreetingsExplodeEffect
.skip
;	jsr		doCols


;    ;swapscreens
;    lea		screenList,a0
;    add.w	.screenOff,a0
;    move.l	(a0),d0
;    lsr.w	#8,d0
;    move.l	d0,$ffff8200
;    add.w	#4,.screenOff
;    cmp.w	#nr_of_frames*4,.screenOff
;    bne		.kk
;    	move.w	#0,.screenOff
;.kk

	;swapcols
	subq.w	#1,.colsWaiter
	bge		.kkn
		move.w	#nr_of_frames-1,.colsWaiter
		move.w	#-1,.swapCols
.kkn

    popall
    rte
.drumwaiter		dc.w	32000
.explodeWaiter	dc.w	GREETINGS_WAITER   
.wframes		dc.w	200   
.colsWaiter		dc.w	4
.screenOff		dc.w	0
.swapCols		dc.w	0
.swaiter		dc.w	1
.colorListPointer	dc.l	barsColorList


;initHighTonesList
;	rts
;	lea		highTonesList,a0
;	move.l	#-32000,d7
;.again
;	cmp.l	(a0),d7
;	beq		.end
;		move.l	4(a0),a1
;		move.w	(a1),d0			; color value
;		cmp.w	#$765,d0
;		bne		.next1
;			move.l	#label765,8(a0)
;			jmp		.cont
;.next1
;		cmp.w	#$567,d0
;		bne		.next2
;			move.l	#label567,8(a0)
;			jmp		.cont
;.next2
;		cmp.w	#$753,d0
;		bne		.next3
;			move.l	#label753,8(a0)
;			jmp		.cont
;.next3
;		cmp.w	#$675,d0
;		bne		.next4
;			move.l	#label675,8(a0)
;			jmp		.cont
;.next4		
;		cmp.w	#$667,d0
;		bne		.next5
;			move.l	#label667,8(a0)
;			jmp		.cont
;.next5
;		cmp.w	#$576,d0
;		bne		.next6
;			move.l	#label576,8(a0)
;			jmp		.cont
;.next6
;		move.b	#0,$ffffc123
;			move.l	#label777,8(a0)
;.cont
;		lea		16(a0),a0
;		jmp		.again
;.end
;	rts

highTonesListOff	dc.w	0
highTonesList
	REPT 55
	dc.l	-1,barsColorList+084-20,0,30
	ENDR
;	dc.l	-1,barsColorList+086-20,0,30
;	dc.l	-1,barsColorList+090-20,0,30
;	dc.l	-1,barsColorList+088-20,0,30
;	dc.l	-1,barsColorList+092-20,0,30
;	dc.l	-1,barsColorList+090-20,0,30
;	dc.l	-1,barsColorList+094-20,0,30
;	dc.l	-1,barsColorList+098-20,0,30
;	dc.l	-1,barsColorList+096-20,0,30
;	dc.l	-1,barsColorList+084+4,0,30
;	dc.l	-1,barsColorList+080+4,0,30
;	dc.l	-1,barsColorList+082+4,0,30
;	dc.l	-1,barsColorList+088+4,0,30
;	dc.l	-1,barsColorList+090+4,0,30
;	dc.l	-1,barsColorList+086+4,0,30
;	dc.l	-1,barsColorList+094+4,0,30
;	dc.l	-1,barsColorList+098+4,0,30
;	dc.l	-1,barsColorList+096+4,0,30
;	dc.l	-1,barsColorList+084+26,0,30
;	dc.l	-1,barsColorList+080+26,0,30
;	dc.l	-1,barsColorList+082+26,0,30
;	dc.l	-1,barsColorList+088+26,0,30
;	dc.l	-1,barsColorList+090+26,0,30
;	dc.l	-1,barsColorList+086+26,0,30
;	dc.l	-1,barsColorList+094+26,0,30
;	dc.l	-1,barsColorList+098+26,0,30
;	dc.l	-1,barsColorList+096+26,0,30
;	dc.l	-1,barsColorList+084+48,0,30
;	dc.l	-1,barsColorList+080+48,0,30
;	dc.l	-1,barsColorList+082+48,0,30
;	dc.l	-1,barsColorList+088+48,0,30
;	dc.l	-1,barsColorList+090+48,0,30
;	dc.l	-1,barsColorList+086+48,0,30
;	dc.l	-1,barsColorList+094+48,0,30
;	dc.l	-1,barsColorList+098+48,0,30
;	dc.l	-1,barsColorList+096+48,0,30
;	dc.l	-1,barsColorList+084+68,0,30
;	dc.l	-1,barsColorList+080+68,0,30
;	dc.l	-1,barsColorList+082+68,0,30
;	dc.l	-1,barsColorList+086+68,0,30
;	dc.l	-1,barsColorList+088+68,0,30
;	dc.l	-1,barsColorList+090+68,0,30
;	dc.l	-1,barsColorList+094+68,0,30
;	dc.l	-1,barsColorList+098+68,0,30
;	dc.l	-1,barsColorList+096+68,0,30
;	dc.l	-1,barsColorList+084+86,0,30
;	dc.l	-1,barsColorList+080+86,0,30
;	dc.l	-1,barsColorList+082+86,0,30
;	dc.l	-1,barsColorList+086+86,0,30
	dc.l	-32000




VTUNNEL_DEBUG	equ 1
debugCols	macro
.c set $700
		REPT 7
			dc.w	.c
			dc.w	.c
.c set .c+$011
		ENDR			
	endm


label765
	IFEQ	VTUNNEL_DEBUG
		debugCols
	ENDC
	dc.w	$765	;dc.w	$765	;$765
	dc.w	$765	;dc.w	$765	;$765
	dc.w	$764	;dc.w	$765
	dc.w	$754	;dc.w	$775
	dc.w	$654	;dc.w	$775
	dc.w	$653	;dc.w	$776
	dc.w	$643	;dc.w	$776
	dc.w	$543	;dc.w	$777
	dc.w	$432
	dc.w	$432
	dc.w	$543	;dc.w	$777
	dc.w	$643	;dc.w	$776
	dc.w	$653	;dc.w	$776
	dc.w	$654	;dc.w	$775
	dc.w	$754	;dc.w	$775
	dc.w	$764	;dc.w	$765
	dc.w	$765	;dc.w	$765

label567
	IFEQ	VTUNNEL_DEBUG
		debugCols
	ENDC
	dc.w	$567	;dc.w	$567
	dc.w	$567	;dc.w	$567
	dc.w	$467	;dc.w	$567
	dc.w	$457	;dc.w	$577
	dc.w	$456	;dc.w	$577
	dc.w	$356	;dc.w	$677
	dc.w	$346	;dc.w	$677
	dc.w	$345	;dc.w	$777
	dc.w	$234
	dc.w	$234
	dc.w	$345	;dc.w	$777
	dc.w	$346	;dc.w	$677
	dc.w	$356	;dc.w	$677
	dc.w	$456	;dc.w	$577
	dc.w	$457	;dc.w	$577
	dc.w	$467	;dc.w	$567
	dc.w	$567	;dc.w	$567

label576
	IFEQ	VTUNNEL_DEBUG
		debugCols
	ENDC
	dc.w	$576	;dc.w	$576
	dc.w	$576	;dc.w	$576
	dc.w	$476	;dc.w	$576
	dc.w	$475	;dc.w	$577
	dc.w	$465	;dc.w	$577
	dc.w	$365	;dc.w	$677
	dc.w	$364	;dc.w	$677
	dc.w	$354	;dc.w	$777
	dc.w	$243
	dc.w	$243
	dc.w	$354	;dc.w	$777
	dc.w	$364	;dc.w	$677
	dc.w	$365	;dc.w	$677
	dc.w	$465	;dc.w	$577
	dc.w	$475	;dc.w	$577
	dc.w	$476	;dc.w	$576
	dc.w	$576	;dc.w	$576

label753
	IFEQ	VTUNNEL_DEBUG
		debugCols
	ENDC
	dc.w	$753	;	dc.w	$753
	dc.w	$753	;	dc.w	$753
	dc.w	$752	;	dc.w	$753
	dc.w	$742	;	dc.w	$765
	dc.w	$642	;	dc.w	$765
	dc.w	$641	;	dc.w	$776
	dc.w	$631	;	dc.w	$776
	dc.w	$531	;	dc.w	$777
	dc.w	$420
	dc.w	$420
	dc.w	$531	;	dc.w	$777
	dc.w	$631	;	dc.w	$776
	dc.w	$641	;	dc.w	$776
	dc.w	$642	;	dc.w	$765
	dc.w	$742	;	dc.w	$765
	dc.w	$752	;	dc.w	$753
	dc.w	$753	;	dc.w	$753

label667
	IFEQ	VTUNNEL_DEBUG
		debugCols
	ENDC
	dc.w	$667	;	dc.w	$667
	dc.w	$667	;	dc.w	$667
	dc.w	$567	;	dc.w	$667
	dc.w	$557	;	dc.w	$677
	dc.w	$556	;	dc.w	$677
	dc.w	$456	;	dc.w	$677
	dc.w	$446	;	dc.w	$677
	dc.w	$445	;	dc.w	$777
	dc.w	$334
	dc.w	$334
	dc.w	$445	;	dc.w	$777
	dc.w	$446	;	dc.w	$677
	dc.w	$456	;	dc.w	$677
	dc.w	$556	;	dc.w	$677
	dc.w	$557	;	dc.w	$677
	dc.w	$567	;	dc.w	$667
	dc.w	$667	;	dc.w	$667

label675
	IFEQ	VTUNNEL_DEBUG
		debugCols
	ENDC
	dc.w	$675	;	dc.w	$675
	dc.w	$675	;	dc.w	$675
	dc.w	$674	;	dc.w	$675
	dc.w	$574	;	dc.w	$676
	dc.w	$564	;	dc.w	$676
	dc.w	$563	;	dc.w	$677
	dc.w	$463	;	dc.w	$677
	dc.w	$453	;	dc.w	$777
	dc.w	$342
	dc.w	$342
	dc.w	$453	;	dc.w	$777
	dc.w	$463	;	dc.w	$677
	dc.w	$563	;	dc.w	$677
	dc.w	$564	;	dc.w	$676
	dc.w	$574	;	dc.w	$676
	dc.w	$674	;	dc.w	$675
	dc.w	$675	;	dc.w	$675


label777
	IFEQ	VTUNNEL_DEBUG
		debugCols
	ENDC
	REPT 14
		dc.w	$777
	ENDR







regList
	dc.w	$8246
	dc.w	$8244
	dc.w	$8242
	dc.w	$8246
	dc.w	$8244
	dc.w	$8242
regListOff
	dc.w	0

col1	dc.w	$122
col2	dc.w	$300
col3	dc.w	$531


doCols		
	lea		regList,a0
	add.w	regListOff,a0
	move.w	(a0)+,a1
	move.w	col1,(a1)
	move.w	(a0)+,a1
	move.w	col2,(a1)
	move.w	(a0)+,a1
	move.w	col3,(a1)
	rts
swapCols

	add.w	#2,regListOff
	cmp.w	#6,regListOff
	bne		.kk
		move.w	#0,regListOff
.kk





	rts

screenList
	REPT nr_of_frames
		dc.l	0
	ENDR

prepScreenList
	lea		screenList,a0
	move.l	screen2,d0
	move.l	#$8000,d1
	REPT nr_of_frames
		move.l	d0,(a0)+
		add.l	d1,d0
	ENDR
	rts


arpOn	dc.w	0
; set initial colors and set bars
setColorBars

;	clr.b	$fffffa1b.w			;Timer B control (stop)
;	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
;	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
;	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
;	move.l	d0,$120.w
;	bclr	#3,$fffffa17.w			;Automatic end of interrupt
;	move.b	#8,$fffffa1b.w	
;	move.w	#0,$ffff8240


	add.w	#4,timer_b_listOff
	cmp.w	#13*4,timer_b_listOff
	bne		.ll
		move.w	#0,timer_b_listOff
.ll

    move.b	musicPlayer+$b8,d0
    beq		.kk
    	move.b	#0,musicPlayer+$b8
    	cmp.b	#$f0,d0
    	bne		.normie
    		move.w	#-1,arpOn    		
.normie

    	subq.w	#1,.zynctimes
    	blt		.kk
    	lea		barsColorList,a0
    	add.w	barsColorListOff,a0

    	lea		stepPalList,a1
.try
    	cmp.l	#-32000,(a1)
    	beq		.kk
    	tst.l	(a1)
    	blt		.foundplace
    		lea		12(a1),a1
    		jmp		.try
.foundplace
			moveq	#0,d1
			move.b	d0,d1		; value 
			move.l	d1,d0

			move.l	.offThingsPtr,a3
			move.l	#8,(a1)+
			move.l	(a3)+,(a1)+
	    	lea		barsColorList,a0
			add.l	(a3)+,a0
			move.l	a0,(a1)+
			move.l	a3,.offThingsPtr
.kk



	lea		stepPalList,a0
.next
	cmp.l	#-32000,(a0)
	beq		.endList
		subq.l	#1,(a0)
		blt		.skip
.found
		move.l	(a0)+,d0
		add.w	d0,d0
		move.l	(a0)+,a1
		add.w	d0,a1
		move.l	(a0)+,a2
		move.w	(a1),(a2)
		move.w	(a1),16(a2)		; next pattern
		move.w	(a1),32(a2)		; next pattern
;		move.w	(a1),48(a2)		; next pattern
		jmp		.next
.skip
		lea		12(a0),a0
		jmp		.next
.endList
	lea		barsColorList,a0
	add.w	barsColorListOff,a0
	lea		$ffff8240+2,a1
	move.w	(a0)+,(a1)+						; first
	move.w	(a0)+,(a1)+						; second
	move.w	(a0)+,(a1)+						; third
	move.w	(a0)+,vt_color1_new				; forth
	move.w	(a0)+,vt_color2_new				; fifth
	move.w	(a0)+,vt_color3_new				; sixth	
	move.w	(a0)+,vt_color4_new				; seventh


;todo
; add fades and target list
	tst.w	arpOn
	beq		.endd
		jsr		doArpFade
.endd


;	move.b	#0,$ffffc123
	lea		highTonesList,a0
	move.l	#-32000,d7
	jmp		.gogo
.nextxx
		lea		12(a0),a0
.gogo
	cmp.l	(a0),d7
	beq		.trueend
		sub.l	#1,(a0)+	
		blt		.nextxx
			move.l	(a0)+,a1		; target address
			move.l	(a0)+,a2		; source address
			add.l	(a0),a2

			move.w	(a2),(a1)		; set color
			sub.l	#2,(a0)+
			bge		.gogo
				move.l	#0,-4(a0)

.trueend
	rts
.currentActive	dc.l	0
.zynctimes		dc.w	8
.offThingsPtr	dc.l	.ssss
.ssss
	dc.l	.stepPal2,2			;dark green						; one below the first
	dc.l	.stepPal3,8
	dc.l	.stepPal5,12	;brown
	dc.l	.stepPal0,16			;red
	dc.l	.stepPal1,4				;blue
	dc.l	.stepPal5,6
	dc.l	.stepPal2,10			;dark green
	dc.l	.stepPal3,14				;orange
	dc.l	.stepPal6,10
	dc.l	.stepPal0,28


DDDBUG	equ 1

; MODMATE CHANGE HERE
.stepPal0				; 777 -> 300
	dc.w	$300
	dc.w	$411
	dc.w	$522
	dc.w	$633
	dc.w	$744
	dc.w	$755
	dc.w	$766
	IFEQ	DDDBUG
	dc.w	0
	ELSE
	dc.w	$777
	ENDC

.stepPal1				; 777 -> 753
	dc.w	$200
	dc.w	$311
	dc.w	$422
	dc.w	$533
	dc.w	$644
	dc.w	$755
	dc.w	$766
	IFEQ	DDDBUG
	dc.w	0
	ELSE
	dc.w	$777
	ENDC

.stepPal2				; 777 -> 122
	dc.w	$400
	dc.w	$411
	dc.w	$422
	dc.w	$433
	dc.w	$544
	dc.w	$655
	dc.w	$766
	IFEQ	DDDBUG
	dc.w	0
	ELSE
	dc.w	$777
	ENDC

.stepPal3				; 777 -> 765
	dc.w	$311
	dc.w	$311
	dc.w	$422
	dc.w	$533
	dc.w	$544
	dc.w	$655
	dc.w	$766
	IFEQ	DDDBUG
	dc.w	0
	ELSE
	dc.w	$777
	ENDC

.stepPal4				; 777 -> 567
	dc.w	$531
	dc.w	$642
	dc.w	$643
	dc.w	$654
	dc.w	$765
	dc.w	$766
	dc.w	$777
	IFEQ	DDDBUG
	dc.w	0
	ELSE
	dc.w	$777
	ENDC

.stepPal5				; 777 -> 567
	dc.w	$421
	dc.w	$431
	dc.w	$433
	dc.w	$544
	dc.w	$655
	dc.w	$766
	dc.w	$777
	IFEQ	DDDBUG
	dc.w	0
	ELSE
	dc.w	$777
	ENDC

.stepPal6
	dc.w	$643
	dc.w	$643
	dc.w	$653
	dc.w	$753
	dc.w	$754
	dc.w	$765
	dc.w	$776
	IFEQ	DDDBUG
	dc.w	0
	ELSE
	dc.w	$777
	ENDC


stepPalList
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0
	dc.l	-1,0,0

	dc.l	-32000	; end

fadeToWhite
	REPT 8*8
	dc.w	$777
	ENDR

doDrumFade
	lea		myDrumFadeLabel-8,a0
	move.l	a0,a2
	lea		fadeToWhite,a1
	move.w	#22,d0
	jsr		fadeCol
	rts


doArpFade
	lea		barsColorList+36,a0
	move.l	a0,a2
	lea		targetFades,a1
	move.w	nrOfFades,d0
	jsr		fadeCol

	subq.w	#1,.waiter
	bge		.kkkl
		move.w	#2,.waiter
		addq.w	#1,nrOfFades
		cmp.w	#14,nrOfFades
		ble		.kkkl
		move.w	#14,nrOfFades
.kkkl
	subq.w	#1,.times
	bge		.ok
		move.w	#$4e75,doArpFade
.ok
	rts
.waiter	dc.w	0
.times	dc.w	26*2
nrOfFades	dc.w	1

; MODMATE CHANGE HERE
targetFades
		dc.w	$765
		dc.w	$567
		dc.w	$576
		dc.w	$753
		dc.w	$667
		dc.w	$675
		dc.w	$765
		dc.w	$567
		dc.w	$576
		dc.w	$753
		dc.w	$667
		dc.w	$675
		dc.w	$765
		dc.w	$567
		dc.w	$576
		dc.w	$753
		dc.w	$667
		dc.w	$675

;============== ST palette fade 8-steps ================
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
;out:	start palette overwritten one step closer to end palette
fadeCol:		
		movem.l	d0-d6/a0-a2,-(sp)

		move.w	d0,d6
		subq.w	#1,d6
.loop:
		move.w	(a0)+,d0			;source
		move.w	(a1)+,d3			;dest
		move.w	d0,d1
		move.w	d0,d2
		move.w	d3,d4
		move.w	d3,d5

		and.w	#$0700,d0
		and.w	#$0700,d3
		and.w	#$0070,d1
		and.w	#$0070,d4
		and.w	#$0007,d2
		and.w	#$0007,d5

.red:		cmp.w	d0,d3
		beq.s	.green
		blt.s	.redsub
		add.w	#$0100,d0
		bra.s	.green
.redsub:	sub.w	#$0100,d0


.green:		cmp.w	d1,d4
		beq.s	.blue
		blt.s	.greensub
		add.w	#$0010,d1
		bra.s	.blue
.greensub:	sub.w	#$0010,d1


.blue:		cmp.w	d2,d5
		beq.s	.store
		blt.s	.bluesub
		addq.w	#$1,d2
		bra.s	.store
.bluesub:	subq.w	#$1,d2

.store:		or.w	d1,d0
		or.w	d2,d0
		move.w	d0,(a2)+

		dbra	d6,.loop

		movem.l	(sp)+,d0-d6/a0-a2
		rts

timer_b_current_pointer	dc.l	timer_b_frame1

T_DBUG	equ 1

vt_color1_new	dc.w	0
vt_color2_new	dc.w	0
vt_color3_new	dc.w	0
vt_color4_new	dc.w	0

t1_1	equ 17
t1_2	equ 49-17
t1_3	equ 80-49
t1_4	equ 135-80
t1_5	equ 199-135

timer_b_listOff	dc.w	48
timer_b_list
	dc.l	timer_b_frame10
	dc.l	timer_b_frame11
	dc.l	timer_b_frame12
	dc.l	timer_b_frame13
	dc.l	timer_b_frame1
	dc.l	timer_b_frame2
	dc.l	timer_b_frame3
	dc.l	timer_b_frame4
	dc.l	timer_b_frame5
	dc.l	timer_b_frame6
	dc.l	timer_b_frame7
	dc.l	timer_b_frame8
	dc.l	timer_b_frame9




timer_b_frame1
timer_b_frame2
timer_b_frame3
timer_b_frame4
timer_b_frame5
timer_b_frame6
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

		dcb.w	59-6-8,$4e71


		movem.l	(sp)+,d1-d2/a0



	IFEQ	T_DBUG	
		move.w	#$000,$ffff8240.w
	ELSE
		move.w	#$777,$ffff8240.w
	ENDC
	move.b	#0,$fffffa1b.w			
	move.b	#t1_1,$fffffa21.w		
	move.l	#timer_b_1_col1,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_1_col1
	IFEQ	T_DBUG
		add.w	#$101,$fff8240
	ENDC
	move.w	vt_color1_new,$ffff8240+2*1
	move.b	#0,$fffffa1b.w			
	move.b	#t1_2,$fffffa21.w		
	move.l	#timer_b_1_col2,$120.w
	move.b	#8,$fffffa1b.w	
	rte

timer_b_1_col2
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color2_new,$ffff8240+2*2
	move.b	#0,$fffffa1b.w			
	move.b	#t1_3,$fffffa21.w		
	move.l	#timer_b_1_col3,$120.w
	move.b	#8,$fffffa1b.w	
	rte

timer_b_1_col3
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color3_new,$ffff8240+2*3
	move.b	#0,$fffffa1b.w			
	move.b	#t1_4,$fffffa21.w		
	move.l	#timer_b_1_col4,$120.w
	move.b	#8,$fffffa1b.w	
	rte

timer_b_1_col4
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color4_new,$ffff8240+2*1
	move.b	#0,$fffffa1b.w			
	move.b	#t1_5-1,$fffffa21.w		
	move.l	#timer_b_close_curtain_stable,$120.w
	move.b	#8,$fffffa1b.w	
	rte

t7_1	equ 5
t7_2	equ	49-5


timer_b_frame7
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

		dcb.w	59-6-8,$4e71


		movem.l	(sp)+,d1-d2/a0
	IFEQ	T_DBUG
	move.w	#$707,$ffff8240.w
	ELSE
	move.w	#$777,$ffff8240.w
	ENDC
	move.b	#0,$fffffa1b.w			
	move.b	#t7_1,$fffffa21.w		
	move.l	#timer_b_7_col1,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_7_col1
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color1_new,$ffff8240+2*1
	move.b	#0,$fffffa1b.w			
	move.b	#t7_2,$fffffa21.w		
	move.l	#timer_b_1_col2,$120.w
	move.b	#8,$fffffa1b.w	
	rte




t8_1	equ 1
t8_2	equ 49-1

timer_b_frame8
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

		dcb.w	59-6-8,$4e71


		movem.l	(sp)+,d1-d2/a0
	IFEQ	T_DBUG
	move.w	#$050,$ffff8240.w
	ELSE
	move.w	#$777,$ffff8240.w
	ENDC
	move.b	#0,$fffffa1b.w			
	move.b	#t8_1,$fffffa21.w		
	move.l	#timer_b_8_col1,$120.w
	move.b	#8,$fffffa1b.w			

	add.w	#2,barsColorListOff				;// WOOPWOOP!

	rte

timer_b_8_col1
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color1_new,$ffff8240+2*1
	move.b	#0,$fffffa1b.w			
	move.b	#t8_2,$fffffa21.w		
	move.l	#timer_b_1_col2,$120.w
	move.b	#8,$fffffa1b.w	
	rte



t10_1	equ 29
t10_2	equ	61-29
t10_3	equ 92-61
t10_4	equ	172-92
t10_5	equ 199-172

timer_b_frame9
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

		dcb.w	59-6-8,$4e71


		movem.l	(sp)+,d1-d2/a0
	IFEQ	T_DBUG
	move.w	#$007,$ffff8240.w
	ELSE
	move.w	#$777,$ffff8240.w
	ENDC
	move.b	#0,$fffffa1b.w			
	move.b	#t10_1,$fffffa21.w		
	move.l	#timer_b_9_col1,$120.w
	move.b	#8,$fffffa1b.w			
	rte


timer_b_9_col1
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color1_new,$ffff8240+2*1
	move.b	#0,$fffffa1b.w			
	move.b	#t10_2,$fffffa21.w		
	move.l	#timer_b_9_col2,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_9_col2
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color2_new,$ffff8240+2*2
	move.b	#0,$fffffa1b.w			
	move.b	#t10_3,$fffffa21.w		
	move.l	#timer_b_9_col3,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_9_col3
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color3_new,$ffff8240+2*3
	move.b	#0,$fffffa1b.w			
	move.b	#t10_4+27-1,$fffffa21.w		
	move.l	#timer_b_close_curtain_stable,$120.w
	move.b	#8,$fffffa1b.w			
	rte




timer_b_frame10
	IFEQ	T_DBUG
	move.w	#$033,$ffff8240.w
	jmp		conttt
	ENDC
timer_b_frame11
	IFEQ	T_DBUG
	move.w	#$333,$ffff8240.w
	jmp		conttt
	ENDC
timer_b_frame12
	IFEQ	T_DBUG
	move.w	#$330,$ffff8240.w
	jmp		conttt
	ENDC
timer_b_frame13
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

		dcb.w	59-6-8,$4e71


		movem.l	(sp)+,d1-d2/a0

	IFEQ	T_DBUG
	move.w	#$300,$ffff8240.w
	ELSE
	move.w	#$777,$ffff8240.w
	ENDC
conttt
	move.b	#0,$fffffa1b.w			
	move.b	#t10_1,$fffffa21.w		
	move.l	#timer_b_10_col1,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_10_col1
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color1_new,$ffff8240+2*1
	move.b	#0,$fffffa1b.w			
	move.b	#t10_2,$fffffa21.w		
	move.l	#timer_b_10_col2,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_10_col2
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color2_new,$ffff8240+2*2
	move.b	#0,$fffffa1b.w			
	move.b	#t10_3,$fffffa21.w		
	move.l	#timer_b_10_col3,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_10_col3
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color3_new,$ffff8240+2*3
	move.b	#0,$fffffa1b.w			
	move.b	#t10_4,$fffffa21.w		
	move.l	#timer_b_10_col4,$120.w
	move.b	#8,$fffffa1b.w			
	rte

timer_b_10_col4
	IFEQ	T_DBUG
	add.w	#$101,$fff8240
	ENDC
	move.w	vt_color4_new,$ffff8240+2*1
	move.b	#0,$fffffa1b.w			
	move.b	#27-1,$fffffa21.w		
	move.l	#timer_b_close_curtain_stable,$120.w
	move.b	#8,$fffffa1b.w			
	rte

; so we have barsColorListOff, which is always accurate,
;	and we can use this to do stuff

barsColorListOff	dc.w	0
barsColorList
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$300
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$311
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	REPT 9
		dc.w	$765
		dc.w	$567
		dc.w	$576
		dc.w	$753
		dc.w	$667
		dc.w	$675
	ENDR
myDrumFadeLabel		;22
	REPT 1
		dc.w	$765
		dc.w	$567
		dc.w	$576
		dc.w	$753
		dc.w	$777
		dc.w	$777
	ENDR	
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777

; list:
;	10
;
;	11
;
;	12
;
;	1...


;sourceList
;		dc.l	i10+128
;		dc.l	i11+128
;		dc.l	i12+128
;		dc.l	i13+128
;		dc.l	i1+128
;		dc.l	i2+128
;		dc.l	i3+128
;		dc.l	i4+128
;		dc.l	i5+128
;		dc.l	i6+128
;		dc.l	i7+128
;		dc.l	i8+128
;		dc.l	i9+128
;		dc.l	-1
;
;
;prepScreens
;	moveq	#0,d0
;	lea		sourceList,a5
;	lea		screenList,a6
;	move.w	#nr_of_frames-1,d7
;.list
;		move.l	(a5)+,a0
;		move.l	(a6)+,a1
;				REPT 20
;					move.l	d0,(a1)+
;					move.l	d0,(a1)+
;				ENDR
;		REPT 199
;			REPT 20
;				move.l	(a0)+,(a1)+
;				move.l	(a0)+,(a1)+
;			ENDR
;		ENDR
;	dbra	d7,.list
;
;
;
;	lea		screenList,a0
;	move.l	(a0)+,a0
;	rts
;
;	IFEQ	nr_of_frames-13
;
;i1	incbin	"data/vtunnel/12 - retouch/1.neo"
;i2	incbin	"data/vtunnel/12 - retouch/2.neo"
;i3	incbin	"data/vtunnel/12 - retouch/3.neo"
;i4	incbin	"data/vtunnel/12 - retouch/4.neo"
;i5	incbin	"data/vtunnel/12 - retouch/5.neo"
;i6	incbin	"data/vtunnel/12 - retouch/6.neo"
;i7	incbin	"data/vtunnel/12 - retouch/7.neo"
;i8	incbin	"data/vtunnel/12 - retouch/8.neo"
;i9	incbin	"data/vtunnel/12 - retouch/9.neo"
;i10	incbin	"data/vtunnel/12 - retouch/10.neo"
;i11	incbin	"data/vtunnel/12 - retouch/11.neo"
;i12	incbin	"data/vtunnel/12 - retouch/12.neo"
;i13	incbin	"data/vtunnel/12 - retouch/13.neo"
;	ELSE
;i1	incbin	"data/vtunnel/9/1.neo"
;i2	incbin	"data/vtunnel/9/2.neo"
;i3	incbin	"data/vtunnel/9/3.neo"
;i4	incbin	"data/vtunnel/9/4.neo"
;i5	incbin	"data/vtunnel/9/5.neo"
;i6	incbin	"data/vtunnel/9/6.neo"
;i7	incbin	"data/vtunnel/9/7.neo"
;i8	incbin	"data/vtunnel/9/8.neo"
;i9	incbin	"data/vtunnel/9/9.neo"
;i10
;i11
;i12
;i13
;
;	ENDC

greetingsPointer	dc.l	vtunnelcrk
vtunnelcrk	incbin	"data/vtunnel/vtunnelnew4.crk"
	even

;buffer	ds.b	12*32000
;
;prepTunnel
;	lea		sourceList,a6
;	lea		buffer,a1
;.next
;	move.l	(a6)+,a0
;	cmp.l	#-1,a0
;	beq		.end
;	move.w	#200-1,d7
;.lll
;	REPT 40
;		move.l	(a0)+,(a1)+
;	ENDR
;	dbra	d7,.lll
;	jmp		.next
;.end
;	lea		buffer,a0
;	move.b	#0,$ffffc123
;	rts








;init_greetings_explode
;
;	move.l	screen2,d0
;	move.l	d0,clearBlocksPtr
;	move.l	d0,clearBlocksPtr2
;	add.l	#65536*10,d0
;	move.l	d0,x_table_pointer_explode
;	add.l	#20*16*4,d0
;	move.l	d0,blockCodePointer
;	add.l	#5120,d0
;	move.l	d0,explode_clear1aPointerGreetings
;	add.l	#1600,d0
;	move.l	d0,explode_clear1bPointerGreetings
;	add.l	#1600,d0
;	move.l	d0,explode_clear2aPointerGreetings
;	add.l	#1600,d0
;	move.l	d0,explode_clear2bPointerGreetings
;	add.l	#1600,d0
;	move.l	d0,explode_clear3aPointerGreetings
;	add.l	#1600,d0
;	move.l	d0,explode_clear3bPointerGreetings
;	add.l	#1600,d0
;	move.l	d0,renderPointer
;	add.l	#100*160,d0
;	move.l	d0,greetings_blocks_pointer
;
;
;	jsr		prepScreenList
;	lea		screenList,a0
;	move.l	(a0),a1
;;	move.l	a1,$ffff8200
;	lea		vtunnelcrk,a0
;	jsr		cranker
;
;	lea		blockCodecrk,a0
;	move.l	blockCodePointer,a1
;	jsr		cranker
;
;	lea		greetingsCrank,a0
;	move.l	greetingsPointer,a1
;	jsr		cranker
;
;	move.b	#0,$ffffc123
;
;	jsr		genBlockSizes
;
;	movem.l	explode_clear1aPointerGreetings,a0-a5
;	move.l	#-1,(a0)
;	move.l	#-1,(a1)
;	move.l	#-1,(a2)
;	move.l	#-1,(a3)
;	move.l	#-1,(a4)
;	move.l	#-1,(a5)
;
;
;	jsr		genExplodeXTable
;	jsr		copySourceExplode
;	jsr		renderBlocks
;	rts

blockYPos	dc.w	200


blockCodecrk	incbin	"data/greetings/blockCode2.crk"
	even


clearPrevBlocks
	subq.w	#1,clearTimesGreetings
	blt		.end
	move.l	clearBlocksPtr2,a0
	move.w	#60-1,d7
	moveq	#0,d0
.l	
.x set 4
	REPT 20
		move.w	d0,.x(a0)
.x set .x+8
	ENDR
	lea		160(a0),a0
	dbra	d7,.l
	move.l	clearBlocksPtr,d0
	move.l	clearBlocksPtr2,clearBlocksPtr
	move.l	d0,clearBlocksPtr2
.end
	rts

clearTimesGreetings	dc.w	0

drawBlocks
	move.l	screenpointer2,a0
	move.l	renderPointer,a1

	move.w	blockYPos,d0
	neg.w	d0
	add.w	#200,d0
	ble		.end

	move.w	#200,d6
	sub.w	d0,d6
	muls	#160,d6
	add.w	d6,a0

	move.l	a0,clearBlocksPtr

	cmp.w	#60,d0
	ble		.kk
		move.w	#60,d0
.kk
	move.w	d0,d7
.ylo
.x set 0
	REPT 20
		move.w	.x(a1),.x+4(a0)
.x set .x+8
	ENDR
	lea		160(a1),a1
	lea		160(a0),a0
	dbra	d7,.ylo
.end

	sub.w	#5,blockYPos
	cmp.w	#80,blockYPos
	bge		.kkk
		move.w	#80,blockYPos
.kkk
	rts

doGreetingsExplodeEffect


    	jsr		clearExplodeBlocksGreetings
    	subq.w	#1,waiter
    	blt		.drawExplodeBlock1
    		cmp.w	#80,blockYPos
    		beq		.draw2
.haha
				jsr		clearPrevBlocks
	    		jsr		drawBlocks
	    		move.w	#1,clearTimesGreetings
	    		jmp		.skip
.draw2
				subq.w	#1,twiceEx
				bge		.haha
		    	jsr		drawExplodeBlocks2Greetings
	    	jmp		.skip
.drawExplodeBlock1
			jsr		drawExplodeBlocksGreetings
.skip
;    	move.w	#$777,$ffff8240
    			    

    	subq.w	#1,zyncsim
    	bge		.nos
    		move.w	#95,zyncsim
    		move.w	#2,twiceEx
    		move.w	#20,sizeCounter
    		move.w	#45,waiter
    		move.w	#200,blockYPos
			jsr		copySourceExplode
			jsr		clearBlockBuffer
			move.w	#1,.renderBlockWaiter
			subq.w	#1,.greetings
			bge		.nos
				move.w	#$4e75,doGreetingsExplodeEffect
				; we can exit here
.nos	
	subq.w	#1,.renderBlockWaiter
	bge		.skipxz
			jsr		renderBlocks
			move.w	#32000,.renderBlockWaiter
.skipxz
	
;	move.w	#$666,$ffff8240
	rts
.renderBlockWaiter	dc.w	32000
.greetings	dc.w	NR_OF_GREETINGS-1
.screenOff	dc.w	0
waiter	dc.w	45
zyncsim	dc.w	100
twiceEx	dc.w	2



x_table_pointer_explode	ds.l	1

genExplodeXTable
	move.l	x_table_pointer_explode,a0
	moveq	#32,d2
	move.w	#20-1,d7
	moveq	#0,d0		; .x
.oloop
		move.w	#16-1,d6
		moveq	#0,d1		;off
.iloop
		move.w	d0,(a0)+	;.x
		move.w	d1,(a0)+	;.off
		add.w	d2,d1
	dbra	d6,.iloop
	addq.w	#8,d0
	dbra	d7,.oloop
	rts


; sp2 = next screen
; 
clearExplodeBlocksGreetings
	move.l 	screenpointer2,d7
	move.l	explode_clear1aPointerGreetings,a0
	move.l	explode_clear1bPointerGreetings,a1

	moveq	#0,d0
.doOne
	move.l	(a0)+,d7
	blt		.doTwo
			move.l	d7,a6
			move.w	d0,(a6)
			move.w	d0,160(a6)
			move.w	d0,320(a6)
			move.w	d0,480(a6)
			move.w	d0,640(a6)
		jmp		.doOne
.doTwo
	move.l	(a1)+,d7
	blt		.end
		move.l	d7,a6
		move.w	d0,(a6)
		move.w	d0,8(a6)
		move.w	d0,160(a6)
		move.w	d0,168(a6)
		move.w	d0,320(a6)
		move.w	d0,328(a6)
		move.w	d0,480(a6)
		move.w	d0,488(a6)
		move.w	d0,640(a6)
		move.w	d0,648(a6)
		jmp		.doTwo
.end
	rts

endList
	move.l	#-1,(a1)+
	move.l	#-1,(a2)+

	move.l	explode_clear1aPointerGreetings,d0
	move.l	explode_clear2aPointerGreetings,explode_clear1aPointerGreetings
	move.l	explode_clear3aPointerGreetings,explode_clear2aPointerGreetings
	move.l	d0,explode_clear3aPointerGreetings

	move.l	explode_clear1bPointerGreetings,d0
	move.l	explode_clear2bPointerGreetings,explode_clear1bPointerGreetings
	move.l	explode_clear3bPointerGreetings,explode_clear2bPointerGreetings
	move.l	d0,explode_clear3bPointerGreetings

	rts

sizeCounter	dc.w	20

drawExplodeBlocks2Greetings
	move.l	screenpointer2,d2
;	lsr.w	#8,d0
	add.l	#4,d2
	move.l	explode_clear3aPointerGreetings,a1
	move.l	explode_clear3bPointerGreetings,a2
	lea		.doDot,a3
	move.l	greetings_blocks_pointer,a5
	move.l	x_table_pointer_explode,a6
	move.w	#160,d6
	move.l	a6,usp
	moveq	#0,d7
	move.l	#32000,d1
	move.l	blockCodePointer,a4
	add.w	#2048,a4
.doDot
	move.w	(a5)+,d0			; x
	blt		endList
		move.l	usp,a6
		add.w	d0,a6
		move.w	(a6)+,d7		;x
		add.w	(a5)+,d7
		add.w	#4,a5
		move.w	(a6)+,d0		;jumpoff
		add.w	d0,d0
		move.l	d2,a0
		cmp.l	d1,d7
		bge		.doDot
		add.w	d7,a0
		jmp		(a4,d0)

exitBlocks
	move.l	explode_clear3aPointerGreetings,a1
	move.l	explode_clear3bPointerGreetings,a2
	move.l	#-1,(a1)
	move.l	#-1,(a2)
	rts

renderBlocks
	move.w	#200,blockYPos
	move.l	renderPointer,d2
	move.l	explode_clear3aPointerGreetings,a1
	move.l	explode_clear3bPointerGreetings,a2
	lea		.doDot,a3
	move.l	greetings_blocks_pointer,a5
	move.l	x_table_pointer_explode,a6
	move.w	#160,d6
	move.l	a6,usp
	moveq	#0,d7
	move.l	#32000,d1
	move.l	blockCodePointer,a4
	add.w	#2048,a4
;	move.l	blockSizes-4,a4
;	lea		d3_block0,a4
.doDot
	move.w	(a5)+,d0			; x
	blt		exitBlocks
		move.l	usp,a6
		add.w	d0,a6
		move.w	(a6)+,d7		;x
		add.w	(a5)+,d7
		sub.w	#80*160,d7
		add.w	#4,a5
		move.w	(a6)+,d0		;jumpoff
		add.w	d0,d0
		move.l	d2,a0
		add.w	d7,a0
		jmp		(a4,d0)	


genBlockSizes
	lea		blockSizes-13*4,a0
	move.l	blockCodePointer,a1
	REPT 13
		move.l	a1,(a0)+
	ENDR
	add.w	#1024,a1
	REPT 6
		move.l	a1,(a0)+
	ENDR
	add.w	#1024,a1
	REPT 4
		move.l	a1,(a0)+
	ENDR
	add.w	#1024,a1
	REPT 10
		move.l	a1,(a0)+
	ENDR
	add.w	#1024,a1
;	REPT 6
;		move.l	a1,(a0)+
;	ENDR
	sub.w	#1024,a1
	move.l	a1,(a0)+
	rts


	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
blockSizes
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

	dc.l	0

DIRECTION_UP	equ 0

drawExplodeBlocksGreetings
	move.l	screenpointer2,d2
	add.l	#4,d2
	move.l	explode_clear3aPointerGreetings,a1
	move.l	explode_clear3bPointerGreetings,a2
	lea		.doDot,a3
	move.l	greetings_blocks_pointer,a5
	move.l	x_table_pointer_explode,a6
	move.w	#160,d6
	move.l	a6,usp
	moveq	#0,d7
	subq.w	#1,sizeCounter
	move.w	sizeCounter,d5
	add.w	d5,d5
	add.w	d5,d5
	lea		blockSizes,a6
	move.l	(a6,d5.w),a4

	move.w	#%1111000000000000,d1
	move.w	#%0111100000000000,d3
	move.w	#%0011110000000000,d4
	move.w	#%0001111000000000,d5


	jmp		.doDot
.doDotSkip
		add.w	#4,a5
.doDot												;d1,d3,d4,d5
	move.w	(a5)+,d0			; x
	blt		endList
		move.l	usp,a6
		add.w	d0,a6
		move.w	(a6)+,d7		;x
		add.w	(a5)+,d7
		blt		.doDotSkip
		move.w	(a5)+,d0
		add.w	d0,-6(a5)		; xOFF
;		cmp.w	#159*4,-6(a5)
;		beq		.skip
;		bge		.less
;.more
;		add.w	#4,-2(a5)
;		jmp		.skip
;.less
;		sub.w	#4,-2(a5)
;.skip

		move.w	(a5),d0
		IFEQ	DIRECTION_UP
			add.w	d0,-4(a5)
		ELSE
			sub.w	d0,-4(a5)		; xOFF
		ENDC
		sub.w	d6,(a5)+
		move.w	(a6)+,d0		;jumpoff
		add.w	d0,d0
		move.l	d2,a0
;		cmp.w	d1,d7
;		bge		.doDot
		tst.w	d7
		blt		.doDot
		add.w	d7,a0
		jmp		(a4,d0)


	IFEQ	blockCodeUsed

blockCode
d1_block0
	or.w	#%1000000000000000,(a0)				;4
	move.l	a0,(a1)+							;2
	jmp		(a3)								;2
	ds.b	24+32

d1_block1
	or.w	#%0100000000000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block2
	or.w	#%0010000000000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block3
	or.w	#%0001000000000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block4
	or.w	#%0000100000000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block5
	or.w	#%0000010000000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block6
	or.w	#%0000001000000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block7
	or.w	#%0000000100000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block8
	or.w	#%0000000010000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block9
	or.w	#%0000000001000000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block10
	or.w	#%0000000000100000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block11
	or.w	#%0000000000010000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block12
	or.w	#%0000000000001000,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block13
	or.w	#%0000000000000100,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block14
	or.w	#%0000000000000010,(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	24+32

d1_block15
	or.w	#%0000000000000001,(a0)					;4
	move.l	a0,(a1)+								;2
	jmp		(a3)									;2			26
	ds.b	24+32



d2_block0
	or.w	#%1100000000000000,(a0)				;4
	or.w	#%1100000000000000,160(a0)			;6
	move.l	a0,(a1)+							;2
	jmp		(a3)								;2
	ds.b	18+32

d2_block1
	or.w	#%0110000000000000,(a0)
	or.w	#%0110000000000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block2
	or.w	#%0011000000000000,(a0)
	or.w	#%0011000000000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block3
	or.w	#%0001100000000000,(a0)
	or.w	#%0001100000000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block4
	or.w	#%0000110000000000,(a0)
	or.w	#%0000110000000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block5
	or.w	#%0000011000000000,(a0)
	or.w	#%0000011000000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block6
	or.w	#%0000001100000000,(a0)
	or.w	#%0000001100000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block7
	or.w	#%0000000110000000,(a0)
	or.w	#%0000000110000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block8
	or.w	#%0000000011000000,(a0)
	or.w	#%0000000011000000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block9
	or.w	#%0000000001100000,(a0)
	or.w	#%0000000001100000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block10
	or.w	#%0000000000110000,(a0)
	or.w	#%0000000000110000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block11
	or.w	#%0000000000011000,(a0)
	or.w	#%0000000000011000,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block12
	or.w	#%0000000000001100,(a0)
	or.w	#%0000000000001100,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block13
	or.w	#%0000000000000110,(a0)
	or.w	#%0000000000000110,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block14
	or.w	#%0000000000000011,(a0)
	or.w	#%0000000000000011,160(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	18+32

d2_block15
	or.w	#%0000000000000001,(a0)					;4
	or.w	#%1000000000000000,8(a0)				;6
	or.w	#%0000000000000001,160(a0)				;6
	or.w	#%1000000000000000,168(a0)				;6
	move.l	a0,(a2)+								;2
	jmp		(a3)									;2			26
	ds.b	6+32


d3_block0
	move.w	#%1110000000000000,d7
	or.w	d7,(a0)				;4
	or.w	d7,160(a0)			;6
	or.w	d7,320(a0)			;6
	move.l	a0,(a1)+							;2
	jmp		(a3)								;2
	ds.b	14+32

d3_block1
	move.w	#%0111000000000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block2
	move.w	#%0011100000000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block3
	move.w	#%0001110000000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block4
	move.w	#%0000111000000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block5
	move.w	#%0000011100000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block6
	move.w	#%0000001110000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block7
	move.w	#%0000000111000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block8
	move.w	#%0000000011100000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block9
	move.w	#%0000000001110000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block10
	move.w	#%0000000000111000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block11
	move.w	#%0000000000011100,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block12
	move.w	#%0000000000001110,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block13
	move.w	#%0000000000000111,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	14+32

d3_block14
	moveq	#%0000000000000011,d0
	or.w	d0,(a0)
	or.w	d0,160(a0)
	or.w	d0,320(a0)
	move.w	#%1000000000000000,d7
	or.w	d7,8(a0)				;6
	or.w	d7,168(a0)				;6
	or.w	d7,328(a0)				;6
	move.l	a0,(a2)+
	jmp		(a3)
	ds.b	0+32

d3_block15
	moveq	#1,d0
	or.w	d0,(a0)					;4
	or.w	d0,160(a0)				;6
	or.w	d0,320(a0)				;6
	move.w	#%1100000000000000,d7
	or.w	d7,8(a0)				;6
	or.w	d7,168(a0)				;6
	or.w	d7,328(a0)				;6
	move.l	a0,(a2)+								;2
	jmp		(a3)									;2			26
	ds.b	0+32


;	move.w	#%1111000000000000,d1


d4_block0
;	move.w	#%1111000000000000,d7
	or.w	d1,(a0)				;4
	or.w	d1,160(a0)			;6
	or.w	d1,320(a0)			;6
	or.w	d1,480(a0)			;6
	move.l	a0,(a1)+							;2
	jmp		(a3)								;2
	ds.b	10+32+4

;	move.w	#%0111100000000000,d3

d4_block1
;	move.w	#%0111100000000000,d7
	or.w	d3,(a0)
	or.w	d3,160(a0)
	or.w	d3,320(a0)
	or.w	d3,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32+4

;	move.w	#%0011110000000000,d4

d4_block2
;	move.w	#%0011110000000000,d7
	or.w	d4,(a0)
	or.w	d4,160(a0)
	or.w	d4,320(a0)
	or.w	d4,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32+4


;	move.w	#%0001111000000000,d5
d4_block3
;	move.w	#%0001111000000000,d7
	or.w	d5,(a0)
	or.w	d5,160(a0)
	or.w	d5,320(a0)
	or.w	d5,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32+4

d4_block4
	move.w	#%0000111100000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block5
	move.w	#%0000011110000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block6
	move.w	#%0000001111000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block7
	move.w	#%0000000111100000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block8
	move.w	#%0000000011110000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block9
	move.w	#%0000000001111000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block10
	move.w	#%0000000000111100,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block11
	move.w	#%0000000000011110,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block12
	move.w	#%0000000000001111,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	10+32

d4_block13
	move.w	#%0000000000000111,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)
	move.w	#%1000000000000000,d7		;4
	or.w	d7,8(a0)
	or.w	d7,168(a0)
	or.w	d7,328(a0)
	or.w	d7,488(a0)
	move.l	a0,(a2)+
	jmp		(a3)
	ds.b	22

d4_block14
	moveq	#%0000000000000011,d0
	or.w	d0,(a0)
	or.w	d0,160(a0)
	or.w	d0,320(a0)
	or.w	d0,480(a0)
	move.w	#%1100000000000000,d7
	or.w	d7,8(a0)				;6
	or.w	d7,168(a0)				;6
	or.w	d7,328(a0)				;6
	or.w	d7,488(a0)				;6
	move.l	a0,(a2)+
	jmp		(a3)
	ds.b	24

d4_block15
	moveq	#1,d0
	or.w	d0,(a0)					;4
	or.w	d0,160(a0)				;6
	or.w	d0,320(a0)				;6
	or.w	d0,480(a0)				;6
	move.w	#%1110000000000000,d7
	or.w	d7,8(a0)				;6
	or.w	d7,168(a0)				;6
	or.w	d7,328(a0)				;6
	or.w	d7,488(a0)				;6
	move.l	a0,(a2)+								;2
	jmp		(a3)									;2			26
	ds.b	24


d5_block0
	move.w	#%1111100000000000,d7
	or.w	d7,(a0)				;4
	or.w	d7,160(a0)			;6
	or.w	d7,320(a0)			;6
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+							;2
	jmp		(a3)								;2
	ds.b	6+32

d5_block1
	move.w	#%0111110000000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block2
	move.w	#%0011111000000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block3
	move.w	#%0001111100000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block4
	move.w	#%0000111110000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block5
	move.w	#%0000011111000000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block6
	move.w	#%0000001111100000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block7
	move.w	#%0000000111110000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block8
	move.w	#%0000000011111000,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block9
	move.w	#%0000000001111100,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block10
	move.w	#%0000000000111110,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block11
	move.w	#%0000000000011111,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.l	a0,(a1)+
	jmp		(a3)
	ds.b	6+32

d5_block12
	move.w	#%0000000000001111,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)			;6
	or.w	d7,640(a0)			;6
	move.w	#%1000000000000000,d7
	or.w	d7,8(a0)
	or.w	d7,168(a0)
	or.w	d7,328(a0)
	or.w	d7,488(a0)			;6
	or.w	d7,648(a0)			;6
	move.l	a0,(a2)+
	jmp		(a3)
	ds.b	14

d5_block13
	move.w	#%0000000000000111,d7
	or.w	d7,(a0)
	or.w	d7,160(a0)
	or.w	d7,320(a0)
	or.w	d7,480(a0)
	or.w	d7,640(a0)
	move.w	#%1100000000000000,d7		;4
	or.w	d7,8(a0)
	or.w	d7,168(a0)
	or.w	d7,328(a0)
	or.w	d7,488(a0)
	or.w	d7,648(a0)
	move.l	a0,(a2)+
	jmp		(a3)
	ds.b	14

d5_block14
	moveq	#%0000000000000011,d0
	or.w	d0,(a0)
	or.w	d0,160(a0)
	or.w	d0,320(a0)
	or.w	d0,480(a0)
	or.w	d0,640(a0)
	move.w	#%1110000000000000,d7
	or.w	d7,8(a0)				;6
	or.w	d7,168(a0)				;6
	or.w	d7,328(a0)				;6
	or.w	d7,488(a0)				;6
	or.w	d7,648(a0)				;6
	move.l	a0,(a2)+
	jmp		(a3)
	ds.b	16

d5_block15
	moveq	#1,d0
	or.w	d0,(a0)					;4
	or.w	d0,160(a0)				;6
	or.w	d0,320(a0)				;6
	or.w	d0,480(a0)				;6
	or.w	d0,640(a0)				;6
	move.w	#%1111000000000000,d7
	or.w	d7,8(a0)				;6
	or.w	d7,168(a0)				;6
	or.w	d7,328(a0)				;6
	or.w	d7,488(a0)				;6
	or.w	d7,648(a0)				;6
	move.l	a0,(a2)+								;2
	jmp		(a3)									;2			26
	ds.b	16
	endc




copySourceExplode
	lea		explodeSourceList,a6
	add.w	.greetingsOff,a6
	add.w	#4,.greetingsOff
	cmp.w	#32,.greetingsOff
	bne		.kkk
		move.w	#0,.greetingsOff
.kkk
	move.l	(a6)+,a0
;	move.l	(a5),a0
	move.l	(a6)+,a2
;	move.l	(a5),a2

	move.l	greetings_blocks_pointer,a1
.go
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	a0,a2
	bgt		.go
	rts
.greetingsOff	dc.w	0



greetings_blocks_pointer		ds.l	1
explode_clear1aPointerGreetings	dc.l	0
explode_clear1bPointerGreetings	dc.l	0
explode_clear2aPointerGreetings	dc.l	0
explode_clear2bPointerGreetings	dc.l	0
explode_clear3aPointerGreetings	dc.l	0
explode_clear3bPointerGreetings	dc.l	0
renderPointer					dc.l	0
blockCodePointer				dc.l	0
clearBlocksPtr					dc.l	0
clearBlocksPtr2					dc.l	0

clearBlockBuffer
	move.l	renderPointer,a0
	move.w	#100-1,d7
	moveq	#0,d0
.dpd
.x set 0
	REPT 20
		move.w	d0,.x(a0)
.x set .x+8
	ENDR
	lea		160(a0),a0
	dbra	d7,.dpd
	rts



;test_newline
;	include	"data/greetings/test_newline2.s"		;	3104
;test_avena
;	include	"data/greetings/test_avena.s"			;	2552
;test_dbug
;	include	"data/greetings/test_dbug2.s"			;	2624
;test_dek
;	include	"data/greetings/test_dek22.s"			;	2240
;test_newbeat
;	include	"data/greetings/test_newbeat2.s"		;	2432
;test_sector1
;	include	"data/greetings/test_sector12.s"		;	1736
;test_dhs
;	include	"data/greetings/test_dsh2.s"			;	3000
;test_pdx
;	include	"data/greetings/test_pdx2.s"			;	2200
;test_end


greetingsCrank
	incbin	"data/greetings/greetingsconcat.crk"
	even

explodeSourceList
	dc.l	0	;text_newline
	dc.l	0	;text_avena
	dc.l	0	;text_dbug
	dc.l	0	;text_dek
	dc.l	0	;text_newbeat
	dc.l	0	;text_sector1
	dc.l	0	;text_dhs
	dc.l	0	;text_pdx
	dc.l	0	;text_end


;text_dek		dc.l	test_dek
;text_newline	dc.l	test_newline
;text_dhs		dc.l	test_dhs
;text_avena		dc.l	test_avena
;text_newbeat	dc.l	test_newbeat
;text_sector1	dc.l	test_sector1
;text_dbug		dc.l	test_dbug
;text_pdx		dc.l	test_pdx
;text_end		dc.l	test_end



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





	section DATA

	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
    ENDC


	section BSS

    rsreset


    IFEQ	STANDALONE
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
	ENDC

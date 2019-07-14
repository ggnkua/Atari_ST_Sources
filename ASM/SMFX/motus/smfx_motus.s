
PREPLETTERS	equ 1

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


SMFX_WAITER_S					equ 1
SMFX_WAITER_F					equ SMFX_WAITER_S+60
SMFX_WAITER_X					equ SMFX_WAITER_F+40
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
	move.w	#5000,effect_vbl_counter
	jsr		init_smfx_motus
	jsr		smfx_motus_mainloop


.demostart


	
.x
		move.l	screenpointer2,$ffff8200
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts



init_demo
	move.w	#$111,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts
	ENDC


init_smfx_motus
	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2
	move.l	screen2,d0
	add.l	#$10000,d0
	move.l	d0,rasterListPointer		; 274 * 2
	add.l	#274*2,d0
	move.l	d0,rasterSourcePointer
	add.l	#10960,d0
	move.l	d0,letter_s_pointer
	add.l	#2688,d0
	move.l	d0,letter_m_pointer
	add.l	#5400,d0
	move.l	d0,letter_f_pointer
	add.l	#5640,d0
	move.l	d0,letter_x_pointer

	IFEQ	PREPLETTERS
	jsr		prepS
	jsr		prepM
	jsr		prepF
	jsr		prepX
	ENDC

	lea		sbuffer,a0
	move.l	letter_s_pointer,a1
	jsr		cranker

	lea		mbuffer,a0
	move.l	letter_m_pointer,a1
	jsr		cranker

	lea		fbuffer,a0
	move.l	letter_f_pointer,a1
	jsr		cranker

	lea		xbuffer,a0
	move.l	letter_x_pointer,a1
	jsr		cranker

	lea		rastershitcrk,a0
	move.l	rasterSourcePointer,a1
	jsr		cranker

    move.w  #$2700,sr
    move.l  #.wvbl,$70
    move.w  #$2300,sr

    movem.l	palFadeThing+7*32,d0-d7
    movem.l	d0-d7,$ffff8240

    move.w	#$4e71,drawM
    jsr		drawM

	move.l	screenpointer2,$ffff8200

    rts
.wvbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    move.w	#0,$ffff8240
		pushall
	IFNE	STANDALONE
		jsr		musicPlayer+8
	ENDC

		subq.w	#1,.sWaiter
		bge		.skips
			jsr		drawS
.skips

		subq.w	#1,.fWaiter
		bge		.skipf
			jsr		drawF
.skipf

		subq.w	#1,.xWaiter
		bge		.skipx
			jsr		drawX
.skipx

		subq.w	#1,.waiter
		bge		.skip
			jsr		generateRasterList2
			move.l	rasterListPointer,ptr2
			clr.b   $fffffa1b.w         ;Timer B control (stop)
			bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
			bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
			move.l	#timer_b_raster,$120.w			;Install our own Timer B
			move.b  #1,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
			move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
			bclr	#3,$fffffa17.w			;Automatic end of interrupt

			subq.w	#1,.palwaiter
			bge		.skip
				lea		palFadeThing,a0
				add.w	.palFadeOff,a0
				movem.l	(a0),d0-d7
				movem.l	d0-d7,$ffff8240
				move.w	#1,.palwaiter
				sub.w	#32,.palFadeOff
				bge		.skip
					move.w	#32000,.palwaiter
					move.w	#0,.palFadeOff
					move.w	#0,smfxFadeDone
.skip
		popall

    rte
.waiter	dc.w	50+80
.palFadeOff	dc.w	7*32
.palwaiter	dc.w	40
.sWaiter	dc.w	SMFX_WAITER_S
.fWaiter	dc.w	SMFX_WAITER_F
.xWaiter	dc.w	SMFX_WAITER_X



drawS
;	lea		s+128,a0
;	lea		sbuffer,a0
	move.l	letter_s_pointer,a0
	move.l	screenpointer2,a1
;	add.w	#48*160+16,a0
	add.w	#50*160+16,a1
	move.w	#84-1,d7
.cp
		movem.l	(a0)+,d0-d6
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+
		or.l	d3,(a1)+
		or.l	d4,(a1)+
		or.l	d5,(a1)+
		or.l	d6,(a1)+

		move.l	(a0)+,d0
		or.l	d0,(a1)+

;		lea		160-32(a0),a0
		lea		160-32(a1),a1

	dbra	d7,.cp
	move.w	#$4e75,drawS

	rts

	; start 33y, 40x off off, 5 blocks wide, 135 high 
drawM
	nop
;	lea		mbuffer,a0
	move.l	letter_m_pointer,a0
	move.l	screenpointer2,a1
	add.w	#33*160+40,a1
	move.w	#135-1,d7
.cp
		movem.l	(a0)+,d0-d6	
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.l	d3,(a1)+
		move.l	d4,(a1)+
		move.l	d5,(a1)+
		move.l	d6,(a1)+

		movem.l	(a0)+,d0-d2
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+

;		lea		160-40(a0),a0
		lea		160-40(a1),a1
	
	dbra	d7,.cp
	move.w	#$4e75,drawM
	rts

drawF
;	lea		f+128,a0
;	lea		fbuffer,a0
	move.l	letter_f_pointer,a0
	move.l	screenpointer2,a1
;	add.w	#32*160+64,a0
	add.w	#37*160+64,a1
	move.w	#141-1,d7
.cp
		movem.l	(a0)+,d0-d6	
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+
		or.l	d3,(a1)+
		or.l	d4,(a1)+
		or.l	d5,(a1)+
		or.l	d6,(a1)+

		movem.l	(a0)+,d0-d2
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+

;		lea		160-40(a0),a0
		lea		160-40(a1),a1

	dbra	d7,.cp
	move.w	#$4e75,drawF
	rts


drawX
;	lea		x+128,a0
;	lea		xbuffer,a0
	move.l	letter_x_pointer,a0
	move.l	screenpointer2,a1
;	add.w	#96*160+80,a0
	add.w	#100*160+80,a1
	move.w	#68-1,d7
.cp
		movem.l	(a0)+,d0-d6			;14 regs wide
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+
		or.l	d3,(a1)+
		or.l	d4,(a1)+
		or.l	d5,(a1)+
		or.l	d6,(a1)+

		movem.l	(a0)+,d0-d6
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+
		or.l	d3,(a1)+
		or.l	d4,(a1)+
		or.l	d5,(a1)+
		or.l	d6,(a1)+

;		lea		160-56(a0),a0
		lea		160-56(a1),a1
	dbra	d7,.cp

	move.w	#$4e75,drawX
	rts


smfxFadeDone	dc.w	-1

;--------------
;DEMOPAL - fade of the drawn SMFX logo to the background color for transition, starts at end, goes to 0
;--------------
palFadeThing
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$100,$222
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$100,$211,$333
	dc.w	$000,$111,$111,$111,$111,$111,$111,$111,$001,$111,$111,$111,$111,$200,$322,$444
	dc.w	$000,$111,$111,$111,$111,$111,$100,$100,$002,$111,$111,$001,$100,$300,$433,$555
	dc.w	$000,$111,$111,$001,$100,$101,$200,$201,$103,$010,$111,$112,$211,$410,$544,$666
	dc.w	$000,$011,$111,$112,$211,$212,$311,$312,$214,$121,$222,$223,$322,$521,$655,$777

smfx_motus_mainloop
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    	tst.w	smfxFadeDone
    	bne		.skipp
    		move.l	screenpointer,a0
    		move.l	screenpointer2,a1
    		moveq	#0,d0
    		move.w	#200-1,d7
.cl
			REPT 40
				move.l	d0,(a0)+
				move.l	d0,(a1)+
			ENDR
			dbra	d7,.cl
.skipp
    	subq.w	#1,effect_vbl_counter
    	blt		.next
    jmp		.w
.next
	rts

ptr2	dc.l	0

timer_b_raster
	pusha0
		move.l	ptr2,a0
		move.w	(a0)+,$ffff8240
		move.l	a0,ptr2
	popa0
	rte


generateRasterList2
;	lea		rastershit,a1
	move.l	rasterSourcePointer,a1
	add.l	.frame,a1
	add.w	#29*2,a1
	move.l	rasterListPointer,a0
	move.w	#200-1,d7
.lll
;	REPT 200
		move.w	(a1)+,(a0)+
;	ENDR
	dbra	d7,.lll
	move.w	#0,-(a0)

	subq.w	#1,.waiter
	bge		.skip
		move.w	#2,.waiter
		add.l	#274*2,.frame
.skip

		subq.w	#1,.times
		bge		.skip2
			moveq	#0,d0
			move.w	#$111,d1
			move.l	rasterListPointer,a0
			move.w	#199-1,d7
.lll2
;			REPT 199
				move.w	d1,(a0)+
;			ENDR
			dbra	d7,.lll2
;			REPT 44
;				move.w	d0,(a0)+
;			ENDR
.skip2
	rts
.waiter	dc.l	80
.times	dc.w	45

.frame	dc.l	0


	IFEQ	PREPLETTERS
prepS
	lea		s+128,a0
	lea		sbuffer,a1
	add.w	#16+50*160,a0
.y set 0
	REPT 84
.x set .y	
		REPT 4
			move.l	.x(a0),(a1)+
			move.l	.x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	lea		sbuffer,a0
	move.l	#84*4*8,d0
	move.b	#0,$ffffc123
	rts

prepM
	lea		m+128,a0
	lea		mbuffer,a1
	add.w	#40+33*160,a0
.y set 0
	REPT 135
.x set .y
		REPT 5
			move.l	.x(a0),(a1)+
			move.l	.x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	lea		mbuffer,a0
	move.l	#135*5*8,d0
	move.b	#0,$ffffc123
	rts

prepF
	lea		f+128,a0
	lea		fbuffer,a1
	add.w	#37*160+64,a0
.y set 0
	REPT 141
.x set .y
		REPT 5
			move.l	.x(a0),(a1)+
			move.l	.x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	lea		fbuffer,a0
	move.l	#141*5*8,d0
	move.b	#0,$ffffc123

prepX
	lea		x+128,a0
	lea		xbuffer,a1
	add.w	#100*160+80,a0
.y set 0
	REPT 68
.x set .y
		REPT 7
			move.l	.x(a0),(a1)+
			move.l	.x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	lea		xbuffer,a0
	move.l	#68*7*8,d0
	move.b	#0,$ffffc123
	rts

	; start 50y, 16 x-offset, 4 blocks wide, 84 high
sbuffer		ds.b	84*4*8
	; start 33y, 40x off off, 5 blocks wide, 135 high 
mbuffer		ds.b	135*5*8
	; start 37 y, 64 x off, 5 blocks wide, 141 high
fbuffer		ds.b	141*5*8
	; start 100y, 80x off, 7 blocks wide, 68 high
xbuffer		ds.b	68*7*8
	section DATA

;smfx_motus	incbin	"data/smfxmotus/mf2.neo"

s			incbin	"data/smfxmotus/s.neo"
m			incbin	"data/smfxmotus/m.neo"
f			incbin	"data/smfxmotus/f.neo"
x			incbin	"data/smfxmotus/x.neo"
	ELSE
sbuffer		incbin	"data/smfxmotus/letter_s.crk"			;1216	
	even
mbuffer		incbin	"data/smfxmotus/letter_m.crk"			;2138
	even
fbuffer		incbin	"data/smfxmotus/letter_f.crk"			;1689
	even
xbuffer		incbin	"data/smfxmotus/letter_x.crk"			;1144			;---> 6187
	even
	ENDC


;rastershit	include	"data/smfxmotus/rasters.s"
rastershitcrk	incbin	"data/smfxmotus/rasters.crk"		;423
	even
;rastershit	incbin	"data/smfxmotus/rasters.bin"

	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
    ENDC
rasterListPointer	ds.l	1
rasterSourcePointer	ds.l	1
letter_s_pointer	ds.l	1
letter_m_pointer	ds.l	1
letter_f_pointer	ds.l	1
letter_x_pointer	ds.l	1




    IFEQ	STANDALONE
	section BSS

    rsreset
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
	ENDC

; SMOKE.S
;
;


screenlines		equ	240
bytesperline		equ	384*2
lines			equ	240
pixels			equ	384

blobsize_x		equ	10
blobsize_y		equ	10

smoke_init:
		bsr	per_init
		lea	smoke_table,a1
		bsr	per_calc
		jsr	make_smoke



;--------------------------------------------------------------

display_routine:
		bsr	do_effects
		illegal

initialize_routine:
		bsr	set_res
		rts

do_effects:

		bsr	clearscreens
		;bsr	clearscreen
loop:
		move.w	#200,d0
		lea	create_frame1,a0
		bsr	main_loop
		move.w	#64,d0
		lea	create_frame2,a0
		bsr	main_loop
		bra	loop
		rts

main_loop:
		subq.w	#1,d0
.main_loop
		move.w	d0,-(a7)
		pea	(a0)
		pea	.return(pc)
		pea	(a0)
		rts
.return:	jsr	screen_swap
		move.l	(a7)+,a0
		move.w	(a7)+,d0
		dbf	d0,.main_loop
		rts

create_frame1:
		bsr	draw_smoke
		bsr	smoke_screen
		rts

create_frame2:
		bsr	smoke_screen
		rts



mstart
;--------------------------------------------------------------
;						get_random
tex_random:
get_random:	movem.w	random_seed,d0/d1/d2
		add.w	d2,d1
		add.w	d1,d0
		add.w	#1,d0
		mulu.w	#259,d0
		mulu.w	#59,d1
		add.w	#17,d1
		mulu.w	#9,d2
		add.w	#7,d2
		movem.w	d0/d1/d2,random_seed
		swap	d0
		rts

;--------------------------------------------------------------
set_res:
;        MOVE.L   #$C6008D,$FFFF8282.W
;        MOVE.L   #$1502AC,$FFFF8286.W
;        MOVE.L   #$8D0096,$FFFF828A.W
;        MOVE.L   #$41903AF,$FFFF82A2.W
;        MOVE.L   #$8F008D,$FFFF82A6.W
;        MOVE.L   #$3AD0415,$FFFF82AA.W
;        MOVE.W   #$200,$FFFF820A.W
;        MOVE.W   #$186,$FFFF82C0.W
;        CLR.W    $FFFF8266.W
;        MOVE.W   #$100,$FFFF8266.W
;        MOVE.W   #$5,$FFFF82C2.W
;        MOVE.W   #$140,$FFFF8210.W
;
;		move.w	#(384-320),$ffff820e.w	;line width in words

		move.w	#$64,-(a7)
		move.w	#$3,-(a7)
		move.l	logic(pc),-(a7)
		move.l	logic(pc),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea	14(a7),a7

		;ori.w	#1,$ffff82c2.w	
		clr.l	$ffff9800.w
		rts


;--------------------------------------------------------------
smoke_screen:
		move.l	#$0009,d0
		movec	d0,cacr

		bsr	update_smoke 

		movem.l	smokes,a1-a2
		exg.l	a1,a2
		movem.l	a1-a2,smokes

		move.l	logic(pc),a4
		lea	(BytesPerLine*60.l,a4),a4
	
		lea	reduce_table,a5
		lea	smoke_colour_table,a6
		moveq	#0,d3
		moveq	#0,d4			;output byte

		move.w	#100-1,d0		;d0 = line count
.line:
		move.w	#192-1,d1		;d1 = pixel count
.pixel:
		move.w	(a0)+,d3		;d3 = smoke offset
		move.w	(a2,d3.w*2),d3		;get old graphic
		move.w	(a5,d3.w*2),d3		;reduce the value
		move.w	d3,(a1)+		;save in buffer2
		swap	d4
		move.w	(a6,d3.w*2),d4		;get colour
		move.l	d4,(a4)+		;draw it
		addq.l	#2,a2			;yeuch!
		dbf	d1,.pixel

		lea	(384-192)*2(a0),a0
		dbf	d0,.line
		rts

update_smoke:
		lea	sine1,a0
		bsr	update_sines
		lea	sine_table,a2
		move.w	(a2,d0.w*2),d0
		move.w	(a2,d1.w*2),d1

		muls.w	#192,d0
		swap	d0
		add.w	#96,d0

		muls.w	#100,d1
		swap	d1
		add.w	#50,d1

		muls.w	#384*2,d1

		muls.w	#2,d0
		add.l	d0,d1
		lea	(smoke_table,d1.l),a0
		rts


draw_smoke:
		move.w	#6-1,d7
		lea	sine_smoke,a0
.ds
		movem.l	d7/a0,-(a7)
		bsr	.draw_blob
		movem.l	(a7)+,d7/a0
		lea	18(a0),a0
		dbf	d7,.ds
		rts

.draw_blob:
		lea	sine_table,a2
		bsr	update_sines
		move.w	(a2,d0.w*2),d6
		move.w	(a2,d1.w*2),d7
		bsr	update_sines
		move.w	(a2,d0.w*2),d4
		move.w	(a2,d1.w*2),d5
		asr	d4
		asr	d5
		asr	d6
		asr	d7
		add.w	d4,d6
		add.w	d5,d7
		move.w	d6,d0
		move.w	d7,d1

		muls.w	#40*2,d0
		swap	d0
		add.w	#192/2,d0

		muls.w	#36*2,d1
		swap	d1
		add.w	#46,d1

		muls.w	#192*2,d1
		muls.w	#2,d0
		add.l	d0,d1
		move.w	(a0),d5
		swap	d5
		move.w	(a0),d5

		move.l	smokes,a0
		lea	(a0,d1.l),a0
		move.l	a0,a1


; Draw them:
		move.l	a0,a1
		move.w	#blobsize_y-1,d7
.dr2		move.w	#blobsize_x/2-1,d6
.dr1		add.l	d5,(a0)+
		dbf	d6,.dr1
		lea	192*2-4*blobsize_x/2(a0),a0
		dbf	d7,.dr2

; Now blur them:
		lea	-192*2*2-2*2(a1),a1
		moveq	#blobsize_y+4-1,d7
.loop1:
		moveq	#blobsize_x+4-1,d6		;d6 across
		lea	192*2(a1),a3
		lea	2(a1),a2
		lea	4(a3),a4

.loop2:		move.w	(a1),d0
		add.w	(a2)+,d0
		add.w	(a3)+,d0
		add.w	(a4)+,d0
		move.w	d0,d1
		asr.w	#2,d1
		move.w	d1,(a1)+
		dbf	d6,.loop2
		lea	192*2-2*(blobsize_x+4)(a1),a1
		dbf	d7,.loop1
		rts


update_sines:
		movem.w	(a0)+,d2/d3

		move.w	(a0),d0
		add.w	d2,d0
		and.w	#$1ff,d0
		move.w	d0,(a0)+

		move.w	(a0),d1
		add.w	d3,d1
		and.w	#$1ff,d1
		move.w	d1,(a0)+
		rts

		
;--------------------------------------------------------------
make_smoke:
		lea	smoke_table,a0
		move.l	a0,a1
		lea	sine_table,a2
		move.l	#384*200,d7
.ms:
		move.w	(a0)+,d0
		asr.w	#2,d0
		and.w	#$1ff,d0
		move.w	(a2,d0.w*2),d1
		add.w	#$200/4,d0
		and.w	#$1ff,d0
		move.w	(a2,d0.w*2),d0
		muls.w	#3,d0
		muls.w	#3,d1
		swap	d0
		swap	d1
		add.w	#1,d0
		add.w	#1,d1
		muls.w	#192,d0
		add.w	d0,d1

		move.w	d1,(a1)+
		subq.l	#1,d7
		bne.s	.ms
		rts


		include	perlin.s

mend

;--------------------------------------------------------------
			section	data

random_seed:		ds.w	3

sine1:			dc.w	2,-2,2,2
			dc.w	0,0


sine_smoke:
			dc.w	+2,+4,0,0
			dc.w	+1,-6,0,0
			dc.w	+16*1

			dc.w	+8,+2,0,0
			dc.w	+1,+3,0,0
			dc.w	-16*1

			dc.w	+7,+3,0,0
			dc.w	+1,-2,0,0
			dc.w	+16*1

			dc.w	+7,-3,0,0
			dc.w	+4,+2,0,0
			dc.w	-16*1

			dc.w	+9,+3,0,0
			dc.w	+2,-5,0,0
			dc.w	+16*1

			dc.w	+4,+2,0,0
			dc.w	+7,-3,0,0
			dc.w	-16*1



sine_table		incbin	incbin\sine.dat

smokes			dc.l	smoke_buffer_1,smoke_buffer_2
			even
	
;--------------------------------------------------------------
			dcb.w	256,-255
o			set	-255

			rept	255
			dc.w	o
o			set	o+1
			endr

			dcb.w	3,0
reduce_table:
			dcb.w	3,0
o			set	0
			rept	255
			dc.w	o
o			set	o+1
			endr
			dcb.w	256,255

;--------------------------------------------------------------

			rept	512-29*6
			dc.w	-1
			endr

o			set	29

			rept	29
			trucol	(o),o,o+1
			trucol	(o),o,o+1
			trucol	(o),o,o+1
			trucol	(o),o,o+1
			trucol	(o),o,o+1
			trucol	(o),o,o+1
o			set	o-1
			endr

			dc.w	$800

smoke_colour_table:
			dc.w	0

o			set	0
			rept	30
			trucol	o,o+1,o+1
			trucol	o,o+1,o+1
			trucol	o,o+1,o+1
			trucol	o,o+1,o+1
			trucol	o,o+1,o+1
			trucol	o,o+1,o+1
o			set	o+1
			endr

			rept	512-30*6
			dc.w	-1
			endr
;--------------------------------------------------------------


			section	bss

			ds.w	192*10
smoke_buffer_1		ds.w	192*100
			ds.w	192*10
smoke_buffer_2		ds.w	192*100
			ds.w	192*10

smoke_table:		ds.w	384*256


			ds.l	300
stack


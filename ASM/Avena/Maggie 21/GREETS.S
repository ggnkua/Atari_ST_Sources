;
;
;	Greetings
;

; NOTE: put the actual blitting on an Interrupt and make the
;  text buffers in normal time?

; a6 is nearly always used as the start of greet_data buffers
;


bufferheight = 32

		section	text

greetings
		pea	(a6)
		jsr	clear_screens
		bsr	swap_screens

		move.l	#greet_draw,vbl_routine

		lea	greet_data_1,a6
		bsr	clear_buffer
		lea	greet_data_2,a6
		bsr	clear_buffer

		lea	greetings_list,a0
greet_loop:
		lea	greet_data_1,a6
		bsr	check_for_new
		lea	greet_data_2,a6
		bsr	check_for_new
		lea	greet_data_3,a6
		bsr	check_for_new
		bra	greet_loop


greet_done:
		move.w	#200,d5			;wait enough
.loop		bsr	wait_vbl
		dbf	d5,.loop

		clr.l	vbl_routine
		move.l	(a7)+,a6
		rts



check_for_new:
		cmp.w	#1,onflag(a6)
		bne.s	.dontdo			;buffer switched off

		move.w	#-1,onflag(a6)		;switch off temporarily
		move.l	a0,-(a7)
		bsr	clear_buffer
		move.l	(a7)+,a0
		bsr	buffer_text

		move.l	a0,-(a7)
		bsr	init_greet

		move.w	#0,onflag(a6)		;put it on
		move.l	(a7)+,a0
.dontdo
		move.b	(a0),d0
		bmi.s	.finished

		cmp.b	#1,d0
		bne.s	.1
		move.w	#1,greet_data_1+onflag
		addq.l	#1,a0
.1		cmp.b	#2,d0
		bne.s	.2
		move.w	#1,greet_data_2+onflag
		addq.l	#1,a0
.2		cmp.b	#3,d0
		bne.s	.3
		move.w	#1,greet_data_3+onflag
		addq.l	#1,a0
.3		cmp.b	#4,d0
		bne.s	.4
		move.w	#1,greet_data_4+onflag
		addq.l	#1,a0
.4		rts




.finished:	move.l	(a7)+,d0		;oops
		bra	greet_done
		rts


;--------------------------------------------------------------
greet_draw:
		lea	greet_data_1,a6
		bsr	draw_greet
		lea	greet_data_2,a6
		bsr	draw_greet
		lea	greet_data_3,a6
		bsr	draw_greet
		lea	greet_data_4,a6
		bsr	draw_greet

		bsr	swap_screens
; Can't wait for a vbl. We're in the interrupt, dummy!
		rts



get_height:
		movem.l	greet_height(a6),d0/d1/d2/d3/d4
		move.l	d3,d4
		move.l	d0,d3			;save old coords...

		add.l	d1,d0
		add.l	d2,d1
		movem.l	d0/d1/d2/d3/d4,greet_height(a6)
		rts

;--------------------------------------------------------------
clear_difference:
		cmp.w	d0,d4			;old height > new height
		bgt	.clear_bottom

		sub.w	d4,d0			;get difference
		exg.l	d0,d4			;swap 'em
						;d4 = difference
						;d0 = top height
		bsr	fix_copy_regs
		bsr	clearit
		rts
.clear_bottom:
		sub.w	d0,d4
		add.w	#bufferheight,d0			;now at bottom
		bsr	fix_copy_regs
		bsr	clearit
		rts


;--------------------------------------------------------------
clearit:
		subq.w	#1,d1
		bmi.s	.dontdo

		move.l	logic,a1
		add.w	bitoffset(a6),a1
		mulu.w	#160,d0
		add.l	d0,a1
		moveq	#0,d2
.copy:
o		set	0
		rept	20
		move.w	d2,o(a1)
o		set	o+8
		endr

		lea	160(a1),a1
		dbf	d1,.copy

.dontdo		rts



;--------------------------------------------------------------

copy_to_screen:
		move.w	#bufferheight,d4	;intended height
		bsr	fix_copy_regs

		move.l	logic,a1
		add.w	bitoffset(a6),a1

		mulu.w	#160,d0
		add.l	d0,a1
		subq.w	#1,d1
		bmi.s	.dontdo
.copy:
o		set	0
		rept	20
		move.w	(a0)+,o(a1)
o		set	o+8
		endr

		lea	160(a1),a1
		dbf	d1,.copy
.dontdo
		rts


fix_copy_regs:
		cmp.w	#200,d0
		bge.s	.ohdear
		move.w	#200,d1
		sub.w	d0,d1
		cmp.w	d4,d1
		blt.s	.clipped
		move.w	d4,d1			;max of bufferheight
.clipped:		
		rts
.ohdear:
		moveq	#0,d0
		moveq	#0,d1
		rts


; call with a0 - text string

buffer_text:
		move.w	#0,text_x
		move.w	#0,text_y

.get_letter
		moveq	#0,d2
		move.b	(a0)+,d2		;d0 = letter to do
		beq	.text_done
		moveq	#0,d1
		sub.w	#" ",d2
		move.w	#Char_Width,d1
		lea	text_convert_table,a5
		move.b	(a5,d2.w),d2
		bpl.s	.ok2
		move.w	#Space_Width,d1
		bra	.dont_draw
.ok2
		move.w	d1,text_to_add
		pea	(a0)
		  bsr	   .text_draw_letter
		move.l	(a7)+,a0
.dont_draw:
		move.w	text_to_add,d0
		add.w	d0,text_x
		bra	.get_letter

.text_done:	;subq.l	#1,a0
		rts

;--------------------------------------------------------------
.text_draw_letter:
		movem.w	text_x,d0/d1
		mulu.w	#8*48,d2
		add.l	#text_font+(8*8),d2
		move.l	d2,a0

		move.l	textbuffer(a6),A1

		mulu.w	#40,D1			;can't be bothered...
		add.l	D1,A1

		move.w	D0,D1
		and.w	#$F,D0			;d0 = shift amt

		move.w	d0,d7
		lea	text_mask_table,a5

		add.w	d7,d7
		move.w	0(a5,d7.w),d6		;left mask
		move.w	d6,d7
		not.w	d7

		eor.w	d0,d1			;d1 = x-offset
		asr.w	#3,d1			;16 pixels = 2 bytes
		add.w	d1,a1

		moveq	#bufferheight-1,d5
.doline:
		move.l	(a0)+,d1		;fiddle with
		or.l	(a0)+,d1		;convert 2 oneplane
		ror.l	d0,d1
		eor.w	d1,2(a1)		;middle section sorted...
		swap	d1
		move.w	d1,d3
		and.w	d6,d3
		eor.w	d3,0(a1)
		and.w	d7,d1
		eor.w	d1,4(a1)
		lea	40(a1),a1
		dbf	d5,.doline
		rts

clear_buffer:
		move.l	textbuffer(a6),a0
		move.w	#(40*bufferheight)/4-1,d0
		moveq	#0,d1
.clear		move.l	d1,(a0)+
		dbf	d0,.clear
		rts

get_random_number:
		tst.w	random_done
		bne.s	.ok
		move.w	$468.w,random_seed
		st	random_done
.ok		movem.w	random_seed,d0/d1/d2
		add.w	d2,d1
		rol.w	#5,d2
		add.w	#$8231,d2
		ror.w	#3,d1
		sub.w	#$3279,d1
		sub.w	d1,d0
		movem.w	d0/d1/d2,random_seed
		rts


init_greet:
		movem.l	d0-a6,-(a7)
		bsr	get_random_number
		and.w	#%111,d0
		mulu.w	#2*4,d0
		add.l	#greet_height_init,d0
		move.l	d0,a1

		movem.l	(a1),d5-d6

		;bsr	get_random_number
		;ext.l	d0
		;ext.l	d1
		;asr.l	#5,d0
		;asr.l	#5,d1
		;add.l	d0,d5
		;add.l	d1,d6
		movem.l	d5-d6,greet_speed(a6)

		move.l	#200*$10000,d7

		move.l	d7,greet_height(a6)
		move.l	d7,old_height1(a6)
		move.l	d7,old_height2(a6)
		movem.l	(a7)+,d0-a6
		rts

draw_greet:
		tst.w	onflag(a6)		;-1 = channel switched off
		bne	.noton			;0 = onscreen

		bsr	get_height
		swap	d0
		swap	d4
		bsr	clear_difference
		move.l	textbuffer(a6),a0
		move.w	greet_height(a6),d0
		bsr	copy_to_screen

		move.w	greet_height(a6),d0
		cmp.w	#220,d0
		blt.s	.stillon		;gone off?

		move.w	#1,onflag(a6)		;1 = signal new needed
.stillon
		rts

.noton:
.dontchange:
		rts


greetings_list:
		dc.b	' Muchos Hellos to',0
		dc.b	'Reservoir Gods',0
		dc.b	'             ExA',0
		dc.b	'     Absence',0
		dc.b	'        Aura',0
		dc.b	' Arto et Andres',0
		dc.b	2
		dc.b	'    EkO     ',0
		dc.b	'  Adrenaline',0
		dc.b	'         Niels',0
		dc.b	'     Therapy',0
		dc.b	'          Hydroxid',0
		dc.b	'Psychosis',0
		dc.b	'         Lazer',0
		dc.b	'     Inter',0
		dc.b	'        T S C C',0
		dc.b	'    Stax',0
		dc.b	'       Aggression',0
		dc.b	'NoCrew',0
		dc.b	'      Impulse',0
		dc.b	3
		dc.b	'Oxyron',0
		dc.b	'    Sanity',0
		dc.b	'         Sentry',0
		dc.b	'  N P G',0
		dc.b	'           F O G',0
		dc.b	'    W E G',0
		dc.b	'           Igloo',0
		dc.b	'        New Trend',0
		dc.b	4
		dc.b	'Senior Dads',0
		dc.b	'     DBA',0
		dc.b	'      STosser Mag',0
		dc.b	'          A D M',0
		dc.b	'  Arnel',0
		dc.b	'        Quasar',0
		dc.b	'  Flinny',0
		dc.b	'     Goodmans PDL',0
		dc.b	'            McFly',0
		dc.b	' John and his wife',0
		dc.b	-1

		even
greetings_palette:
		dc.w	0
		dcb.w	15,$0fff



		rsreset
greet_height:	rs.l	1
greet_speed	rs.l	1
		rs.l	1
old_height1	rs.l	1
old_height2	rs.l	1
textbuffer	rs.l	1
onflag		rs.w	1
bitoffset	rs.w	1


greet_data_1	ds.b	textbuffer
		dc.l	textbuffer1
		dc.w	1			;signal new needed
		dc.w	0
greet_data_2	ds.b	textbuffer
		dc.l	textbuffer2
		dc.w	-1
		dc.w	2
greet_data_3	ds.b	textbuffer
		dc.l	textbuffer3
		dc.w	-1
		dc.w	4
greet_data_4	ds.b	textbuffer
		dc.l	textbuffer4
		dc.w	-1
		dc.w	6

spconst		equ	$d000
spconst2	equ	$3000

greet_height_init:
		dc.l	 -8*spconst
		dc.l	 +1*spconst2

		dc.l	 -10*spconst
		dc.l	 +2*spconst2

		dc.l	-14*spconst
		dc.l	 +2*spconst2

		dc.l	 -9*spconst
		dc.l	 +1*spconst2

		dc.l	 -5*spconst
		dc.l	 +1*spconst2/2

		dc.l	 -10*spconst
		dc.l	 +2*spconst2

		dc.l	-14*spconst
		dc.l	 +2*spconst2

		dc.l	 -6*spconst
		dc.l	 +1*spconst2/2


		section	bss
random_done		ds.w	1
random_seed		ds.w	3


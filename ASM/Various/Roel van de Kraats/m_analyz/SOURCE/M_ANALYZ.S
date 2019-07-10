;                   Music Analyzer
;               by Roel van de Kraats
;                       1995
;                   Main Program

;tabsize=8


len_of_scr	equ	153600
len_scopebuf	equ	128*256/8*4
len_vubuf	equ	60*80/8*4
len_iconsbuf	equ	32/8*4*32*22
len_mstxtbuf	equ	12*64/8*4
len_mousedata	equ	8*256
len_helpdiag	equ	256/8*4*350
len_hdiagsave	equ	(256+16)/8*4*(350+8)
b_line		equ	320
points		equ	256
x		equ	13000		;dsp x and y memory size
y		equ	8000
_frclock	equ	$466
_hz_200		equ	$4ba

speedtest	equ	0		;<>0 : press ESC to show speed

		text

start:		lea.l	start-256, a1		; Start of Basepage
		move.l	12(a1), d1		; Size of Text
		add.l	20(a1), d1		; Size of Data
		add.l	28(a1), d1		; Size of BSS
		add.l	#256,	d1		; Size of Basepage

		move.l	d1,  -(sp)
		move.l	a1,  -(sp)		; Startaddress
		clr	-(sp)			; dummy
		move	#74, -(sp)		; Mshrink
		trap	#1			; Gemdos

		add.l	a1, d1			; new stack
		and.b	#$fc, d1
		move.l	d1, sp			; Stack in BSS

clear_keys:
		; Cconis()
		move	#11,-(sp)
		trap	#1
		addq.l	#2, sp
		cmp.w	#-1,D0
		bne	no_more_keys

		; Cconin()
		move	#1, -(sp)
		trap	#1
		addq.l	#2, sp
		bra	clear_keys
no_more_keys:

		; Kbshift(-1)
		move.w	#-1,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.l	#4,sp

		lsr.w	#4,d0
		and.w	#1,d0
		move.w	d0,old_capslock		;save for restore later

		bset	#4,d0			;capslock on

		; Kbshift()
		move.w	d0,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.l	#4,sp

		bsr	appl_init		;init gem (e.g. for alerts)

		pea	check_cookies
		move.w	#$26,-(sp)
		trap	#14			;Supexec()
		addq.l	#6,sp

		tst.w	d0
		beq	wrong_machine		;not a falcon or compatible!

		move.w	#$59,-(sp)		;VgetMonitor()
		trap	#14
		addq.l	#2,sp
		move.w	d0,monitor		;for later use
		cmp.w	#0,d0
		beq	wrong_scr		;monochrome monitor

		move.l	#len_of_scr,-(SP)
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	D0,scr1
		beq	outofmem
		move.l	d0,scr

		move.l	#len_of_scr,-(SP)
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	D0,scr2
		beq	outofmem

		move.l	#len_scopebuf,-(SP)
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	D0,scopebuf
		beq	outofmem

		move.l	#len_vubuf,-(SP)
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	D0,vubuf
		beq	outofmem

		move.l	#len_iconsbuf,-(SP)
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	d0,icons
		beq	outofmem

		move.l	#len_mstxtbuf*2,-(SP)	;2 times: 2 texts
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	d0,mstexts
		beq	outofmem

		move.l	#len_mousedata,-(SP)
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	d0,mousedata
		beq	outofmem

		move.l	#len_helpdiag,-(SP)
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	d0,helpdiag
		beq	outofmem

		move.l	#len_hdiagsave,-(SP)	;for help dialog save background
		move.w	#72,-(SP)
		trap	#1			;Malloc
		addq.l	#6,SP
		move.l	d0,hdiagsave
		beq	outofmem

		bsr	install_sound

		bsr	decode_imgs		;XIMG -> raw data


		move.w	#256,d0
		bsr	graf_mouse		;(vdi) mouse off

		;Super()
		move.l	#0,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_superstack


		bsr	key_click_off		;else problem with SAM

		;0-1000 -> 0-255
		lea	mainscrdat+22,a0	;start of palette in img-file
		lea	palet,a1
		move.w	#15,d0
loop_sp:	clr.b	(a1)+
		clr.l	d1
		move.w	(a0)+,d1
		mulu.w	#255,d1
		divu	#1000,d1
		move.b	d1,(a1)+
		clr.l	d1
		move.w	(a0)+,d1
		mulu.w	#255,d1
		divu	#1000,d1
		move.b	d1,(a1)+
		clr.l	d1
		move.w	(a0)+,d1
		mulu.w	#255,d1
		divu	#1000,d1
		move.b	d1,(a1)+
		dbra	d0,loop_sp


		;clear screen
		move.l	#len_of_scr/4,d0
		move.l	scr1,a1
loop_clrscr:	clr.l	(a1)+
		subq.l	#1,d0
		bne	loop_clrscr


		bsr	init_video

		;copy ms texts (scope range)
		move.l	scr2,a0
		adda.l	#b_line*388+(144/8*4),a0
		move.l	scr2,a1		
		adda.l	#b_line*388+(432/8*4),a1
		move.l	mstexts,a2
		move.l	a2,a3
		adda.l	#len_mstxtbuf,a3
		move.w	#11,d0
loop_cptxt:	move.l	(a0),(a2)+
		move.l	4(a0),(a2)+
		move.l	8(a0),(a2)+
		move.l	12(a0),(a2)+
		move.l	16(a0),(a2)+
		move.l	20(a0),(a2)+
		move.l	24(a0),(a2)+
		move.l	28(a0),(a2)+
		move.l	(a1),(a3)+
		move.l	4(a1),(a3)+
		move.l	8(a1),(a3)+
		move.l	12(a1),(a3)+
		move.l	16(a1),(a3)+
		move.l	20(a1),(a3)+
		move.l	24(a1),(a3)+
		move.l	28(a1),(a3)+
		add.l	#b_line,a0
		add.l	#b_line,a1
		dbra	d0,loop_cptxt

		clr.w	mstxtwhich		;31.2 ms standard

		;copy scope
		move.l	scr2,a0
		adda.l	#b_line*331+(48/8*4),a0
		move.l	scopebuf,a1
		move.w	#127,d0
loop_cpsc:	move.w	#31,d1
loop_cpsc2:	move.l	(a0)+,(a1)+
		dbra	d1,loop_cpsc2
		adda.w	#b_line-128,a0
		dbra	d0,loop_cpsc

		;copy vu
		move.l	scr2,a0
		adda.l	#b_line*30+(48/8*4),a0
		move.l	vubuf,a1
		move.w	#59,d0
loop_cpvu:	move.w	#9,d1
loop_cpvu2:	move.l	(a0)+,(a1)+
		dbra	d1,loop_cpvu2
		adda.l	#b_line-40,a0
		dbra	d0,loop_cpvu

		;copy screen
		move.l	#len_of_scr/4,d0
		move.l	scr2,a0
		move.l	scr1,a1
loop_cpyscr:	move.l	(a0)+,(a1)+
		subq.l	#1,d0
		bne	loop_cpyscr


		move.l	scr2,scr		;1st screen
		move.w	#11,d0
		move.w	#40,d1
		move.w	lgain,d2
		bsr	put_icon
		move.w	#27,d0
		move.w	#40,d1
		move.w	rgain,d2
		bsr	put_icon
		move.w	#17,d1
		sub.w	speaker,d1
		move.w	d1,d2
		move.w	#16,d0
		move.w	#56,d1
		bsr	put_icon

		move.l	scr1,scr
		move.w	#11,d0			;put icons on 2nd screen too
		move.w	#40,d1
		move.w	lgain,d2
		bsr	put_icon
		move.w	#27,d0
		move.w	#40,d1
		move.w	rgain,d2
		bsr	put_icon
		move.w	#17,d1
		sub.w	speaker,d1
		move.w	d1,d2
		move.w	#16,d0
		move.w	#56,d1
		bsr	put_icon

		move.w	#-1,icon1x		;no icons to put
		move.w	#-1,icon2x

		clr.w	leftvu
		clr.w	rightvu

		move.w	#14*2-1,d0
		lea	left_bars,a0
loop_clrbars:	clr.w	(a0)+
		dbra	d0,loop_clrbars

		bsr	init_mouse		;own mouse routines

		clr.w	freeze			;freeze off
		clr.w	helpdiag_on		;help dialog not shown
		clr.w	restdiag_count		;no restore help dialog background (2: both screens, 1: one screen to go)
		clr.l	old_hz200		;for speed control

	IF	speedtest!=0
		bsr	init_test
	ENDIF


;------------------------------------------------------------------------------

main_loop:

	IF	speedtest!=0
		add.l	#1,testcnt
	ENDIF

		tst.w	freeze
		bne	freeze1			;don't get data from dsp

		move.l	#$123456,sendbuf	;magic number

		move.l	#2+points*2*2,-(sp)	;vu data + scope left+right full/small range
		pea	buf
		move.l	#1,-(sp)
		pea	sendbuf+1		;send lower 3 bytes of long
		move.w	#96,-(sp)		;if something goes really wrong try #97 (Dsp_BlkHandShake) here
		trap	#14			;Dsp_DoBlock
		lea	18(sp),sp
freeze1:

		;clear vu background
		move.l	vubuf,a0
		move.l	scr,a1
		adda.l	#b_line*31+(48/8*4),a1
		move.w	#59,d0
loop_clrvu:
		movem.l (a0)+,d1-d7/a2-a4
		adda.w	#40,a1
		movem.l d1-d7/a2-a4,-(a1)
		adda.w	#232+40,a1
		movem.l d1-d7/a2-a4,-(a1)
		adda.w	#b_line-232,a1
		dbra	d0,loop_clrvu


		lea	log,a0
		move.w	buf,d0
		lsr.w	#5,d0
		move.b	(a0,d0),d1
		lsl.w	#8,d1

		move.w	leftvu,d2

		tst.w	freeze
		bne	freeze5

		cmp.w	d1,d2
		bgt	contlvu			;smaller than before
		sub.w	d2,d1
		asr.w	#1,d1			;slow it down a little to
		add.w	d1,d2			;make it look more real
		bra	contlvu2
contlvu:
		sub.w	#$500,d2		;constant speed backwards
		bpl	contlvu2
		clr.w	d2
contlvu2:	move.w	d2,leftvu
freeze5:
		;and right channel

		move.w	buf+3,d0
		lsr.w	#5,d0
		move.b	(a0,d0),d1
		lsl.w	#8,d1
		move.w	rightvu,d2

		tst.w	freeze
		bne	freeze6

		cmp.w	d1,d2
		bgt	contrvu
		sub.w	d2,d1
		asr.w	#1,d1
		add.w	d1,d2
		bra	contrvu2
contrvu:
		sub.w	#$500,d2
		bpl	contrvu2
		clr.w	d2
contrvu2:	move.w	d2,rightvu
freeze6:

		move.w	#88,d0
		move.w	leftvu,d1
		lsr.w	#8,d1
		bsr	put_vu
		move.w	#552,d0
		move.w	rightvu,d1
		lsr.w	#8,d1
		bsr	put_vu



		;clear scope background
		move.l	scopebuf,a0
		move.l	scr,a1
		adda.l	#b_line*331+(48/8*4),a1
		move.w	#127,d0
loop_clrsc:
		movem.l (a0)+,d1-d7/a2-a6
		adda.w	#48,a1
		movem.l d1-d7/a2-a6,-(a1)
		adda.w	#144+48,a1
		movem.l d1-d7/a2-a6,-(a1)
		movem.l (a0)+,d1-d7/a2-a6
		suba.w	#144-(48+48),a1
		movem.l d1-d7/a2-a6,-(a1)
		adda.w	#144+48,a1
		movem.l d1-d7/a2-a6,-(a1)
		movem.l (a0)+,d1-d7/a2
		suba.w	#144-(48+32),a1
		movem.l d1-d7/a2,-(a1)
		adda.w	#144+32,a1
		movem.l d1-d7/a2,-(a1)
		adda.w	#b_line+32-144-128,a1
		dbra	d0,loop_clrsc

		tst.w	mstxtwhich		;which data to put
		bne	full_range

		move.w	#49,d0
		lea	leftbuf,a0
		bsr	put_scope

		move.w	#337,d0
		lea	rightbuf,a0
		bsr	put_scope

		bra	small_range
full_range:
		move.w	#49,d0
		lea	leftbufsm,a0
		bsr	put_scope

		move.w	#337,d0
		lea	rightbufsm,a0
		bsr	put_scope
small_range:

		tst.w	helpdiag_on
		beq	no_helpdiag

		;put help dialog
		move.l	helpdiag,a0
		move.l	scr,a1
		add.l	#65*b_line+b_line/2-(256/8*4)/2+8*4,a1
		move.w	#349,d0
loop_put_help:
		REPT	4
		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,-(a1)
		adda.w	#8*4*2,a1
		ENDM
		adda.w	#b_line-(256/8*4),a1

		dbra	d0,loop_put_help

		;draw left shadow, odd lines
		move.l	scr,a1
		add.l	#73*b_line+b_line/2-(256/8*4)/2-7,a1
		move.l	a1,a2
		move.b	#$55,d1
		move.b	#$aa,d2
		move.w	#350/2-1,d0
loop_put_help2:
		and.b	d1,(a1)
		and.b	d1,2(a1)
		and.b	d1,4(a1)
		or.b	d2,6(a1)
		adda.w	#b_line*2,a1
		dbra	d0,loop_put_help2

		rol.b	#1,d1
		rol.b	#1,d2

		;even lines
		move.l	a2,a1
		add.w	#b_line,a1
		move.w	#350/2-1,d0
loop_put_help5:
		and.b	d1,(a1)
		and.b	d1,2(a1)
		and.b	d1,4(a1)
		or.b	d2,6(a1)
		adda.w	#b_line*2,a1
		dbra	d0,loop_put_help5

		;draw lower shadow
		move.l	scr,a1
		add.l	#415*b_line+b_line/2-(256/8*4)/2,a1
		move.w	#$5555,d1
		move.w	#$aaaa,d2
		move.w	#7,d0
loop_put_help4:
		move.w	#14,d3
loop_put_help3:
		and.w	d1,(a1)+
		and.w	d1,(a1)+
		and.w	d1,(a1)+
		or.w	d2,(a1)+

		dbra	d3,loop_put_help3

		and.b	d1,(a1)
		and.b	d1,2(a1)
		and.b	d1,4(a1)
		or.b	d2,6(a1)
		rol.w	#1,d1
		rol.w	#1,d2
		adda.w	#b_line-128+8,a1

		dbra	d0,loop_put_help4

no_helpdiag:

		move.w	#-1,new_scr		;new screen address has to be set in vertical blank interrupt
		bsr	wait_forvbl

	IF	speedtest=0
		bsr	wait_forhz200		;not too fast on faster computers
	ENDIF


		tst.w	restdiag_count
		beq	no_restorediag

		;restore help dialog background on this screen
		move.l	hdiagsave,a0
		move.l	scr,a1
		add.l	#65*b_line+b_line/2-(128/2+8),a1
		move.w	#358-1,d0
loop_restdiag:
		movem.l	(a0)+,d1-d7/a2
		adda.w	#8*4,a1
		movem.l	d1-d7/a2,-(a1)
		adda.w	#8*4*2,a1

		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,-(a1)
		adda.w	#8*4*2,a1

		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,-(a1)
		adda.w	#8*4,a1

		movem.l	(a0)+,d1-d7/a2-a4
		adda.w	#10*4,a1
		movem.l	d1-d7/a2-a4,-(a1)
		adda.w	#10*4,a1

		adda.w	#b_line-(128+8),a1

		dbra	d0,loop_restdiag
		subq.w	#1,restdiag_count	;this screen done
no_restorediag:

		cmp.w	#-1,icon1x		;icon to put on this screen?
		beq	no_icon1
		move.w	icon1x,d0
		move.w	icon1y,d1
		move.w	icon1n,d2
		bsr	put_icon
		move.w	#-1,icon1x
no_icon1:
		cmp.w	#-1,icon2x		;icon to put on this screen?
		beq	no_icon2
		move.w	icon2x,d0
		move.w	icon2y,d1
		move.w	icon2n,d2
		bsr	put_icon
		move.w	#-1,icon2x
no_icon2:


		;clear spectrum analyzer bars
		move.l	scr,a0
		adda.l	#b_line*130+4*8+112,a0
		move.l	a0,a1
		adda.w	#18*8,a1
		moveq	#0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.w	#143,d0
loop_clrsp:	movem.l d1-d7,-(a0)
		movem.l d1-d7,-(a0)
		movem.l d1-d7,-(a0)
		movem.l d1-d7,-(a0)
		movem.l d1-d7,-(a1)
		movem.l d1-d7,-(a1)
		movem.l d1-d7,-(a1)
		movem.l d1-d7,-(a1)
		adda.w	#b_line+112,a0
		adda.w	#b_line+112,a1
		dbra	d0,loop_clrsp



		tst.w	freeze
		bne	freeze2			;don't get data from dsp

		move.l	#14*2,-(sp)
		pea	buf2
		move.l	#1,-(sp)
		pea	sendbuf+1
		move.w	#97,-(sp)
		trap	#14			;Dsp_BlkHandShake
		lea	18(sp),sp
freeze2:

		;put spectrum analyzer bars
		move.w	#13,d2
		lea	buf2,a1
		lea	left_bars,a3
		lea	log2,a2
		move.w	#4,d3
loop_putlbars:
		move.w	(a3),d1
		tst.w	freeze
		bne	freeze3

		move.w	(a1)+,d1
		addq.l	#1,a1
		and.w	#$7ff,d1
		move.b	(a2,d1),d1
		and.w	#$ff,d1
		move.w	(a3),d4
		sub.w	d4,d1
		asr.w	#1,d1			;slow it down a little
		add.w	d4,d1
freeze3:
		move.w	d1,(a3)+

		move	d3,d0
		bsr	draw_bar
		addq.w	#1,d3
		dbra	d2,loop_putlbars


		move.w	#13,d2
		;lea	buf2+14*3,a1
		lea	right_bars,a3
		;lea	log2,a2
		move.w	#22,d3
loop_putrbars:
		move.w	(a3),d1
		tst.w	freeze
		bne	freeze4

		move.w	(a1)+,d1
		addq.l	#1,a1
		and.w	#$7ff,d1
		move.b	(a2,d1),d1
		and.w	#$ff,d1
		move.w	(a3),d4
		sub.w	d4,d1
		asr.w	#1,d1
		add.w	d4,d1
freeze4:
		move.w	d1,(a3)+

		move	d3,d0
		bsr	draw_bar
		addq.w	#1,d3
		dbra	d2,loop_putrbars



		tst.w	mbut
		bne	mb_pressed
		clr.w	mouse_but
		bra	mb_not_pressed
mb_pressed:
		add.w	#1,mouse_but		;don't repeat too fast
mb_not_pressed:

		tst.w	helpdiag_on
		beq	no_help_on
		tst.w	mouse_but
		bgt	restore_diag

		; Cconis()
		move	#11, -(sp)
		trap	#1
		addq.l	#2, sp
		cmp.w	#-1,D0
		bne	main_loop

		; Crawcin()
		move	#7, -(sp)
		trap	#1
		addq.l	#2, sp

restore_diag:
		clr.w	helpdiag_on
		move.w	#2,restdiag_count	;clear on both screens (later)
		move.w	#-8,mouse_but
		bra	main_loop
no_help_on:

		move.w	#$1234,d7		;magic number (means: no command)

		tst.w	mouse_but
		ble	no_mousebut

		move.w	#-4,mouse_but		;don't repeat too fast

		;left channel down
		move.w	#145,d0
		move.w	#40,d1
		move.w	#183,d2
		move.w	#76,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box1
		move.w	#2,d7			;scancode 2 -> key '1'
		bra	no_mousebut		;simulate keyboard
not_in_box1:

		move.w	#193,d0
		move.w	#50,d1
		move.w	#240,d2
		move.w	#76,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box2
		move.w	#3,d7			;left channel up
		bra	no_mousebut
not_in_box2:

		move.w	#250,d0
		move.w	#55,d1
		move.w	#288,d2
		move.w	#108,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box3
		move.w	#6,d7			;speaker
		bra	no_mousebut
not_in_box3:

		move.w	#289,d0
		move.w	#55,d1
		move.w	#320,d2
		move.w	#108,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box4
		move.w	#7,d7			;freeze
		bra	no_mousebut
not_in_box4:

		move.w	#321,d0
		move.w	#55,d1
		move.w	#352,d2		;icon
		move.w	#108,d3
		bsr	test_mouse_in_box
		tst.w	d0
		bne	in_box5
		move.w	#47,d0
		move.w	#329,d1
		move.w	#305,d2		;left scope
		move.w	#459,d3
		bsr	test_mouse_in_box
		tst.w	d0
		bne	in_box5
		move.w	#335,d0
		move.w	#329,d1
		move.w	#593,d2		;right scope
		move.w	#459,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box5
in_box5:
		move.w	#8,d7			;zoom
		bra	no_mousebut
not_in_box5:

		move.w	#353,d0
		move.w	#55,d1
		move.w	#390,d2
		move.w	#108,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box6
		move.w	#9,d7			;quit
		bra	no_mousebut
not_in_box6:

		move.w	#400,d0
		move.w	#50,d1
		move.w	#442,d2
		move.w	#76,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box7
		move.w	#4,d7			;right channel down
		bra	no_mousebut
not_in_box7:

		move.w	#450,d0
		move.w	#40,d1
		move.w	#497,d2
		move.w	#76,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box8
		move.w	#5,d7			;right channel up
		bra	no_mousebut
not_in_box8:

		move.w	#440,d0
		move.w	#3,d1
		move.w	#610,d2
		move.w	#18,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box9
		move.w	#98,d7			;help
		bra	no_mousebut
not_in_box9:

		move.w	#217,d0
		move.w	#36,d1
		move.w	#250,d2
		move.w	#50,d3
		bsr	test_mouse_in_box
		tst.w	d0
		bne	in_box10
		move.w	#390,d0
		move.w	#36,d1
		move.w	#422,d2
		move.w	#50,d3
		bsr	test_mouse_in_box
		tst.w	d0
		beq	not_in_box10
in_box10:					;link button(s)
		; Kbshift(-1)
		move.w	#-1,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.l	#4,sp
		bchg	#4,d0			;swap capslock
		; Kbshift(-1)
		move.w	d0,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.l	#4,sp

		bra	no_mousebut
not_in_box10:

no_mousebut:
		; Cconis()
		move	#11, -(sp)
		trap	#1
		addq.l	#2, sp
		cmp.w	#-1,D0
		bne	no_key

		; Crawcin()
		move	#7, -(sp)
		trap	#1
		addq.l	#2, sp
		swap	d0
		move.w	d0,d7
no_key:

		; Kbshift(-1)
		move.w	#-1,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.l	#4,sp
		move.b	d0,d1
		and.b	#%11,d0		;shift keys
		tst.b	d0
		sne	d0
		eor	d1,d0		;xor with capslock
		lsr.b	#4,d0
		and.w	#1,d0		;1 if shift or capslock pressed, 0 if shift and capslock pressed or no key pressed
		move.w	d0,shift

		tst.w	d0
		beq	link_col1
		move.l	$ffff9800+11*4,link_col
		bra	link_col2
link_col1:
		move.l	$ffff9800+3*4,link_col
link_col2:


		cmp.w	#$1234,d7		;no command
		beq	main_loop


		move.w	d7,d0

		cmp.b	#2,d0		; 1
		beq	lgainleft
		cmp.b	#109,d0		; 1 on numeric keypad
		bne	no_lgainleft
lgainleft:
		tst.w	lgain
		beq	cont_lgl
		subq.w	#1,lgain
		move.w	lgain,d0
		lsl.w	#4,d0

		move.w	d0,-(SP)
		move.w	#2,-(SP)
		move.w	#130,-(SP)	;soundcmd()
		trap	#14
		addq.l	#6,SP

		move.w	#11,d0
		move.w	#40,d1
		move.w	lgain,d2
		move.w	d0,icon1x
		move.w	d1,icon1y	;draw icon on 2nd screen later
		move.w	d2,icon1n
		bsr	put_icon
cont_lgl:	tst.w	shift
		beq	main_loop	;no shift pressed
		clr.w	shift		;no repeat forever (l->r->l->r->...)
		bra	rgainleft
no_lgainleft:

		cmp.b	#3,d0		; 2
		beq	lgainright
		cmp.b	#110,d0
		bne	no_lgainright
lgainright:
		move.w	lgain,d0
		cmp.w	#15,d0
		beq	cont_lgr
		addq.w	#1,lgain
		move.w	lgain,d0
		lsl.w	#4,d0

		move.w	d0,-(SP)
		move.w	#2,-(SP)
		move.w	#130,-(SP)	;soundcmd()
		trap	#14
		addq.l	#6,SP

		move.w	#11,d0
		move.w	#40,d1
		move.w	lgain,d2
		move.w	d0,icon1x
		move.w	d1,icon1y
		move.w	d2,icon1n
		bsr	put_icon
cont_lgr:	tst.w	shift
		beq	main_loop
		clr.w	shift
		bra	rgainright
no_lgainright:

		cmp.b	#4,d0		; 3
		beq	rgainleft
		cmp.b	#111,d0
		bne	no_rgainleft
rgainleft:
		tst.w	rgain
		beq	cont_rgl
		subq.w	#1,rgain
		move.w	rgain,d0
		lsl.w	#4,d0

		move.w	d0,-(SP)
		move.w	#3,-(SP)
		move.w	#130,-(SP)	;soundcmd()
		trap	#14
		addq.l	#6,SP

		move.w	#27,d0
		move.w	#40,d1
		move.w	rgain,d2
		move.w	d0,icon2x
		move.w	d1,icon2y
		move.w	d2,icon2n
		bsr	put_icon
cont_rgl:	tst.w	shift
		beq	main_loop
		clr.w	shift
		bra	lgainleft
no_rgainleft:

		cmp.b	#5,d0		; 4
		beq	rgainright
		cmp.b	#106,d0
		bne	no_rgainright
rgainright:
		move.w	rgain,d0
		cmp.w	#15,d0
		beq	cont_rgr
		addq.w	#1,rgain
		move.w	rgain,d0
		lsl.w	#4,d0

		move.w	d0,-(SP)
		move.w	#3,-(SP)
		move.w	#130,-(SP)	;soundcmd()
		trap	#14
		addq.l	#6,SP

		move.w	#27,d0
		move.w	#40,d1
		move.w	rgain,d2
		move.w	d0,icon2x
		move.w	d1,icon2y
		move.w	d2,icon2n
		bsr	put_icon
cont_rgr:	tst.w	shift
		beq	main_loop
		clr.w	shift
		bra	lgainright
no_rgainright:

		cmp.b	#6,d0		; 5
		beq	do_speaker
		cmp.b	#107,d0
		bne	no_speaker
do_speaker:
		subq.w	#1,speaker	;1->0/0->1
		neg.w	speaker
		bsr	set_speaker
		move.w	#17,d1
		sub.w	speaker,d1
		move.w	d1,d2
		move.w	#16,d0
		move.w	#56,d1
		move.w	d0,icon1x
		move.w	d1,icon1y
		move.w	d2,icon1n
		bsr	put_icon
		bra	main_loop
no_speaker:

		cmp.b	#7,d0		; 6
		beq	do_freeze
		cmp.b	#108,d0
		bne	no_freeze
do_freeze:
		move.w	freeze,d0
		neg.w	d0
		addq.w	#1,d0
		move.w	d0,freeze

		move.w	#18,d2
		add.w	d0,d2
		move.w	#18,d0
		move.w	#56,d1
		move.w	d0,icon1x
		move.w	d1,icon1y
		move.w	d2,icon1n
		bsr	put_icon
no_freeze:

		cmp.b	#8,d0		; 7
		beq	scopezoom
		cmp.b	#103,d0
		bne	no_scopezoom
scopezoom:
		move.w	mstxtwhich,d0
		subq.w	#1,d0
		neg.w	d0		;1->0, 0->1
		move.w	d0,mstxtwhich
		mulu.w	#len_mstxtbuf,d0
		move.l	mstexts,a0
		add.l	d0,a0		;start of buffer

		move.l	scopebuf,a1
		add.l	#57*(256/8*4)+(96/8*4),a1

		move.w	#11,d0
loop_cptxt2:	move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,28(a1)
		add.l	#256/8*4,a1
		dbra	d0,loop_cptxt2

		move.w	#20,d2
		add.w	mstxtwhich,d2
		move.w	#20,d0
		move.w	#56,d1
		move.w	d0,icon1x
		move.w	d1,icon1y
		move.w	d2,icon1n
		bsr	put_icon

		bra	main_loop
no_scopezoom:

	IF	speedtest!=0
		cmp.w	#1,d0		;escape
		bne	no_esc

		bsr	test
		bra	main_loop
no_esc:
	ENDIF

		cmp.b	#98,d0		;help
		bne	no_help

		move.w	#-1,helpdiag_on

		;save dialog background
		move.l	hdiagsave,a0
		move.l	scr,a1
		add.l	#65*b_line+b_line/2-(128/2+8),a1
		move.w	#358-1,d0
loop_savediag:
		movem.l	(a1)+,d1-d7/a2
		adda.w	#8*4,a0
		movem.l	d1-d7/a2,-(a0)
		adda.w	#8*4*2,a0

		movem.l	(a1)+,d1-d7/a2
		movem.l	d1-d7/a2,-(a0)
		adda.w	#8*4*2,a0

		movem.l	(a1)+,d1-d7/a2
		movem.l	d1-d7/a2,-(a0)
		adda.w	#8*4,a0

		movem.l	(a1)+,d1-d7/a2-a4
		adda.w	#10*4,a0
		movem.l	d1-d7/a2-a4,-(a0)
		adda.w	#10*4,a0

		adda.w	#b_line-(128+8),a1

		dbra	d0,loop_savediag

		bra	main_loop
no_help:

		cmp.b	#9,d0		; 8
		beq	the_end
		cmp.b	#104,d0
		bne	main_loop


the_end:
		bsr	exit_mouse

		bsr	restore_video

		bsr	key_click_old

		;Super()
		move.l	old_superstack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		bsr	restore_sound

		move.w	#257,d0
		bsr	graf_mouse		;vdi mouse on

		move.w	monitor,d0
		cmp.w	#2,d0
		beq	vga
		bsr	better_buy_vga		;put alert
vga:
		bra	exit


;-----------------------------------------------------------------------------

	IF	speedtest!=0

init_test:
		move.l	#0,testcnt
		move.l	_hz_200,tstold200
		rts
test:
		move.l	_hz_200,d0
		sub.l	tstold200,d0
		move.l	#8,d1
		lea	tstbuf1,a0
		bsr	l_to_a

		move.l	testcnt,d0
		move.l	#8,d1
		lea	tstbuf2,a0
		bsr	l_to_a

		pea	tstbuf
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.l	testcnt
		move.l	_hz_200,tstold200
		rts

;---long to ascii---
;value in D0.l
;field length in D1.l
;return address in A0.l
l_to_a:		move.l	A0,A2
		move.l	#10,D2
		sub.l	D1,D2
		bmi	bindasc5
		lsl.l	#2,D2
		move.l	#numbers,A1
		add.l	D2,A1
		move.b	#'0',D2
bindasc1:	sub.l	(A1),D0
		bcs	bindasc2
		add.w	#1,D2
		bra	bindasc1
bindasc2:	add.l	(A1)+,D0
		tst.l	(A1)
		beq	bindasc4
		move.b	D2,(A0)+
		lsl	#8,D2
		move.b	#'0',D2
		bra	bindasc1
bindasc4:	move.b	D2,(A0)+
		move.b	#' ',(A0)+
bindasc5:	cmp.b	#'0',(A2)+
		bne	bindasc6
		move.b	#' ',-1(A2)
		bra	bindasc5
bindasc6:	rts

		data

numbers:	dc.l	1000000000,100000000,10000000,1000000
		dc.l	100000,10000,1000,100,10,1,0
tstbuf:		dc.b	27,'H('
tstbuf1:	dc.b	'00000000 / 200) seconds,'
tstbuf2:	dc.b	'00000000 program loops',0

		bss

testcnt:	ds.l	1
tstold200:	ds.l	1

		text


	ENDIF


;x1 in d0, y1 in d1, x2 in d2, y2 in d3
;ret d0: in=1, out=0
test_mouse_in_box:
		move.w	mouse_x,d4
		move.w	mouse_y,d5
		cmp.w	d4,d0
		bgt	not_in_box
		cmp.w	d5,d1
		bgt	not_in_box
		cmp.w	d4,d2
		blt	not_in_box
		cmp.w	d5,d3
		blt	not_in_box
		move.w	#1,d0
		rts
not_in_box:
		clr.w	d0
		rts

wait_forvbl:
		move.l	_frclock,d1
wait_vbl:	cmp.l	_frclock,d1
		beq	wait_vbl
		rts


wait_forhz200:
		move.l	old_hz200,d0
		add.l	#8,d0			;max 200/8 times a second
wait_hz200:	cmp.l	_hz_200,d0
		bgt	wait_hz200
		move.l	_hz_200,old_hz200
		rts


;video

;addr in a0
;data in 'VgetRGB' format
set_palet:
		lea	$ffff9800,a1
		move.w	#15,d0
loop_setp:
		move.b	(a0)+,d1
		move.b	(a0)+,d1
		lsl.l	#8,d1
		move.b	(a0)+,d1
		lsl.l	#8,d1
		lsl.l	#8,d1
		move.b	(a0)+,d1
		move.l	d1,(a1)+
		dbra	d0,loop_setp
		rts


;addr in a0
set_regs:
		bsr	wait_forvbl

		move.b	(a0)+,$FFFF820A
		move.b	(a0)+,$FFFF8260
		move.w	(a0)+,$FFFF8266
		move.w	(a0)+,$FFFF8282
		move.w	(a0)+,$FFFF828C
		move.w	(a0)+,$FFFF82AC
		move.w	(a0)+,$FFFF82C0
		move.w	(a0)+,$FFFF82C2
		move.w	(a0)+,$FFFF8284
		move.w	(a0)+,$FFFF8286
		move.w	(a0)+,$FFFF8288
		move.w	(a0)+,$FFFF828A
		move.w	(a0)+,$FFFF82A2
		move.w	(a0)+,$FFFF82A4
		move.w	(a0)+,$FFFF82A6
		move.w	(a0)+,$FFFF82A8
		move.w	(a0)+,$FFFF82AA
		move.w	(a0)+,$FFFF8210
		rts

get_regs:
		bsr	wait_forvbl

		move.b	$FFFF820A,(a0)+
		move.b	$FFFF8260,(a0)+
		move.w	$FFFF8266,(a0)+
		move.w	$FFFF8282,(a0)+
		move.w	$FFFF828C,(a0)+
		move.w	$FFFF82AC,(a0)+
		move.w	$FFFF82C0,(a0)+
		move.w	$FFFF82C2,(a0)+
		move.w	$FFFF8284,(a0)+
		move.w	$FFFF8286,(a0)+
		move.w	$FFFF8288,(a0)+
		move.w	$FFFF828A,(a0)+
		move.w	$FFFF82A2,(a0)+
		move.w	$FFFF82A4,(a0)+
		move.w	$FFFF82A6,(a0)+
		move.w	$FFFF82A8,(a0)+
		move.w	$FFFF82AA,(a0)+
		move.w	$FFFF8210,(a0)+

		rts

save_palette:
		lea	$ffff8240,a0
		move.w	#15,d0
		lea	old_stpalet,a1
loop_savestp:	move.w	(a0)+,(a1)+
		dbra	d0,loop_savestp
		lea	$ffff9800,a0
		move.w	#255,d0
		lea	old_palet,a1
loop_savep:	move.l	(a0)+,(a1)+
		dbra	d0,loop_savep
		rts

rest_palette:
		lea	$ffff8240,a0
		move.w	#15,d0
		lea	old_stpalet,a1
loop_reststp:	move.w	(a1)+,(a0)+
		dbra	d0,loop_reststp
		lea	$ffff9800,a0
		move.w	#255,d0
		lea	old_palet,a1
loop_restp:	move.l	(a1)+,(a0)+
		dbra	d0,loop_restp
		rts

init_video:
		bsr	save_palette

		move.w	#2,-(sp)
		trap	#14			;Physbase()
		addq.l	#2,sp
		move.l	d0,old_physscr

		move.w	#3,-(sp)
		trap	#14			;Logbase()
		addq.l	#2,sp
		move.l	d0,old_logscr

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)		;VsetMode()
		trap	#14
		addq.l	#4,sp
		move.w	d0,old_mode

		and.w	#$20,d0			;PAL bit
		lsr.w	#5,d0
		move.w	d0,pal

		move.w	d0,-(sp)
		move.w	#$5b,-(sp)		;VgetSize()
		trap	#14
		addq.l	#4,sp
		move.l	d0,old_scrlen

		cmp.l	#len_of_scr,d0
		bgt	cont_vid1

		move.w	#-1,-(sp)
		move.l	scr1,-(sp)
		move.l	scr1,-(sp)
		move.w	#5,-(sp)		;Setscreen
		trap	#14
		lea	$c(sp),sp
cont_vid1:

		move.l	#old_regs,a0
		bsr	get_regs

		move.w	vga_mode,d1
		move.w	monitor,d0
		cmp.w	#2,d0
		beq	set_mode
		move.w	tv60_mode,d1
		tst.w	pal
		beq	set_mode
		move.w	tv50_mode,d1
set_mode:
		move.w	d1,-(sp)
		move.w	#$58,-(sp)		;VsetMode()
		trap	#14
		addq.l	#4,sp


		lea.l	vidregs_vga,a0
		move.w	monitor,d0
		cmp.w	#2,d0
		beq	set_vid
		lea.l	vidregs_tv60,a0
		tst.w	pal
		beq	set_vid
		lea.l	vidregs_tv50,a0
set_vid:
		bsr	set_regs

		move.l	old_scrlen,d0
		cmp.l	#len_of_scr,d0
		ble	cont_vid2

		move.w	#-1,-(sp)
		move.l	scr1,-(sp)
		move.l	scr1,-(sp)
		move.w	#5,-(sp)		;Setscreen
		trap	#14
		lea	$c(sp),sp
cont_vid2:

		lea	palet,a0
		pea	set_palet

		rts


restore_video:
		move.l	old_scrlen,d0
		cmp.l	#len_of_scr,d0
		ble	cont_vid3

		move.w	#-1,-(sp)
		move.l	old_physscr,-(sp)
		move.l	old_logscr,-(sp)
		move.w	#5,-(sp)		;Setscreen
		trap	#14
		lea	$c(sp),sp
cont_vid3:


;-only necessary for Screenblaster (BlowUp?) [because VsetMode()
;doesn't work when SB installed (except when in st compatible mode)].
;-gives problems in ST- and 4-color modes so just skip it in these modes.
;so don't try to return to the desktop when in 4-color
;with SB installed. (but who uses 4 colors anyway?)

		move.w	old_mode,d0
		btst	#7,d0			;ST Mode?
		bne	no_setregs		;skip it
		and.w	#7,d0
		cmp.w	#1,d0			;4 colors?
		beq	no_setregs

		lea	old_regs,a0
		bsr	set_regs
no_setregs:

		move.w	old_mode,-(sp)
		move.w	#$58,-(sp)		;VsetMode()
		trap	#14
		addq.l	#4,sp

		move.l	old_scrlen,d0
		cmp.l	#len_of_scr,d0
		bgt	cont_vid4

		move.w	#-1,-(sp)
		move.l	old_physscr,-(sp)
		move.l	old_logscr,-(sp)
		move.w	#5,-(sp)		;Setscreen()
		trap	#14
		lea	$c(sp),sp
cont_vid4:
		bsr	rest_palette

		rts




key_click_off:
		move.b	$484,oldconterm
		move.b	#2,$484			;conterm: repeat=on
		rts

key_click_old:
		move.b	oldconterm,$484
		rts


;ret d0:0=error
check_cookies:
		move.l	#'_CPU',d0
		bsr	get_cookie
		tst.w	d0
		beq	ret_check_c0

		cmp.l	#30,d1
		blt	ret_check_c0

		move.l	#'_SND',d0
		bsr	get_cookie
		tst.w	d0
		beq	ret_check_c0

		and.l	#$1c,d1
		cmp.l	#$1c,d1
		blt	ret_check_c0

		move.w	#-1,d0
		rts

ret_check_c0:	clr.w	d0
		rts


;d0:cookie
;ret d1:value
;ret d0:found (1) or not (0)
get_cookie:
		move.l	$5a0,a0
		beq	ret_getcookie0		;no cookie jar installed
loop_getcookie:
		cmp.l	(a0)+,d0
		bne	wrong_cookie
		move.l	(a0),d1
		move.w	#1,d0
		rts
wrong_cookie:	addq.l	#4,a0
		tst.l	-8(a0)
		bne	loop_getcookie

ret_getcookie0: clr.w	d0
		rts



;draw bar for spectrum analyzer
;d0=x, d1=h
draw_bar:
		move.l	scr,a0
		adda.l	#272*b_line,a0
		lsl.w	#3,d0
		adda.w	d0,a0
		move.l	#$00000000,d4
		move.l	#$00003ffc,d5
		move.l	#$3ffc3ffc,d6
		move.l	#$3ffc0000,d7
		move.l	d5,(a0)
		move.l	d4,4(a0)
		sub.w	#b_line,a0
		tst.w	d1
		bne	cont_db
		rts
cont_db:	subq.w	#1,d1
loop_db:	move.l	d6,(a0)
		move.l	d7,4(a0)
		move.l	d5,-b_line(a0)
		move.l	d4,4-b_line(a0)
		sub.w	#b_line*2,a0
		dbra	d1,loop_db
		rts

;not documented!
get_speaker:
		move.w	#14,-(sp)
		move.l	#$1c0000,-(sp)
		trap	#14
		addq.l	#6,sp
		clr.w	speaker
		btst	#6,d0
		bne	ret_gs
		move.w	#1,speaker
ret_gs: 	rts

;not documented!
set_speaker:
		move.w	speaker,d6
		lsl.w	#6,d6
		bchg	#6,d6
		move.w	#14,-(sp)
		move.l	#$1c0000,-(sp)
		trap	#14
		addq.l	#6,sp
		bclr	#6,d0
		or.w	d6,d0
		move.w	#$8e,-(sp)
		move.w	d0,-(sp)
		move.w	#$1c,-(sp)
		trap	#14
		addq.l	#6,sp
		rts

;d0=x/16, d1=y, d2=num
put_icon:
		move.l	scr,a1
		mulu.w	#b_line,d1
		adda.l	d1,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		move.l	icons,a2
		lsl.w	#1,d2
		lsl.w	#8,d2
		adda.w	d2,a2
		move.w	#31,d0
loop_pi:	move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		adda.w	#b_line-16,a1
		dbra	d0,loop_pi
		rts

;d0=start x, a0=buf
put_scope:
		move.l	scr,a2
		move.w	d0,d1
		and.b	#$f0,d1
		lsr.w	#1,d1
		add.w	d1,a2
		move.w	d0,d1
		and.w	#$f,d1
		neg.w	d1
		add.w	#15,d1
		moveq	#0,d4
		bset	d1,d4

		move.w	#254,d1
		move.b	(a0),d7			;first data point
		ext.w	d7
		neg.w	d7
		add.w	#394,d7
loop_ps:
		addq.w	#3,a0
		move.b	(a0),d2			;get next data point
		ext.w	d2
		neg.w	d2
		add.w	#394,d2

		move.w	#-b_line,d6
		move.w	d7,d3
		sub.w	d2,d7
		bpl	cont_ps
		neg.w	d6
		neg.w	d7
cont_ps:	move.l	a2,a1

		ext.l	d3
		lsl.l	#6,d3			;
		add.l	d3,a1			;* 320
		lsl.l	#2,d3			;
		add.l	d3,a1

		move.w	d4,d5			;with one bit set
		not.w	d5
		tst.w	d7
		beq	cont_ps4
		subq.w	#1,d7
cont_ps4:
		move.w	d7,d0
		lsr.w	#1,d7

		sub.w	d7,d0

loop_ps2:
		and.w	d5,(a1)
		;and.w	d5,2(a1)		;these bitplanes don't change
		or.w	d4,4(a1)
		;and.w	d5,6(a1)		;
		adda.w	d6,a1
		dbra	d0,loop_ps2

		tst.w	d1
		beq	cont_ps3		;last datapoint
		ror.w	d4
		btst	#15,d4
		beq	cont_ps2
		addq.w	#8,a2
		addq.w	#8,a1
cont_ps2:
		move.w	d7,d0
		beq	cont_ps3
		move.w	d4,d5
		not.w	d5
loop_ps3:
		and.w	d5,(a1)
		;and.w	d5,2(a1)
		or.w	d4,4(a1)
		;and.w	d5,6(a1)
		adda.w	d6,a1
		dbra	d0,loop_ps3
cont_ps3:

		move.w	d2,d7
		dbra	d1,loop_ps
		rts

;d0=x, d1=angle
put_vu:
		lea	vu_x,a0
		ext.w	d1
		move.w	(a0,d1*2),d2	;x
		lea	vu_y,a0
		move.w	(a0,d1*2),d3	;y
		move.w	d2,d4
		ext.l	d4
		lsl.l	#8,d4		;x*256
		move.w	d3,d1		;y
		neg.w	d1
		divs	d1,d4		;dx*256/dy
		add.w	#83,d3		;y
		move.w	d0,d2
		ext.l	d2
		lsl.l	#8,d2		;x*256
		move.l	scr,a0
		ext.l	d4
		move.w	d3,d0
		subq.w	#1,d0	
		move.w	#83,d3
loop_pvu:
		move.l	a0,a1
		move.w	d3,d7
		mulu.w	#b_line,d7
		add.l	d7,a1
		move.l	d2,d7
		lsr.l	#8,d7
		move.w	d7,d6
		and.b	#$f0,d6
		lsr.w	#1,d6
		and.w	#$f,d7
		neg.w	d7
		add.w	#15,d7
		moveq	#0,d5
		bset	d7,d5
		or.w	d5,(a1,d6)
		or.w	d5,2(a1,d6)
		or.w	d5,4(a1,d6)
		or.w	d5,6(a1,d6)

		add.l	d4,d2

		subq.w	#1,d3
		cmp.w	d0,d3
		bne	loop_pvu

		rts

install_sound:	move.w	#128,-(SP)
		trap	#14			;locksnd()
		addq.l	#2,SP
		tst.w	D0
		bmi	snd_locked

		move.w	#104,-(SP)
		trap	#14			;Dsp_Lock()
		addq.l	#2,SP
		tst.w	D0
		bmi	dsp_locked

		move.w	#113,-(sp)
		trap	#14			;Dsp_RequestUniqueAbility()
		addq.l	#2,sp
		move.w	d0,ability

		pea	ymem
		pea	xmem
		move.w	#106,-(sp)
		trap	#14			;Dsp_Available()
		lea	$A(sp),sp

		move.l	xmem,d0
		cmp.l	#x,d0
		bmi	Flush
		move.l	ymem,d0
		cmp.l	#y,d0
		bpl	NoFlush
Flush:		move.w	#115,-(sp)
		trap	#14			;Dsp_FlushSubroutines()
		addq.l	#2,sp
NoFlush:

		move.l	ymem,-(sp)
		move.l	xmem,-(sp)
		move.w	#107,-(sp)
		trap	#14			;Dsp_Reserve()
		lea	$A(sp),sp
		tst.w	d0
		bne	OutOfDSPMem

		move.l	#end_of_dspbin,d0
		sub.l	#dsp_bin,d0
		divu	#3,d0			;length in dsp-words

		move.w	ability,-(sp)
		move.l	d0,-(sp)
		pea	dsp_bin
		move.w	#$6d,-(sp)
		trap	#14			;Dsp_ExecProg()
		lea	12(sp),sp


		clr.w	D4
		clr.w	D5
		lea	old_sndstate,A4
save_snd:	move.w	#-1,-(SP)
		move.w	D4,-(SP)
		move.w	#130,-(SP)		;soundcmd()
		trap	#14
		addq.l	#6,SP

		move.w	D0,(A4,D5)
		addq.w	#2,D5
		addq.w	#1,D4
		cmp.w	#7,D4
		bne	save_snd

		bsr	get_speaker
		move.w	speaker,old_speaker
		clr.w	speaker
		bsr	set_speaker

	;	move.w	#1,-(SP)
	;	move.w	#140,-(SP)		;sndstatus(1)
	;	trap	#14
	;	addq.l	#4,SP			;gives problems sometimes, so just leave it out

		move.w	(A4),-(SP)
		clr.w	-(SP)
		move.w	#130,-(SP)		;old left output level
		trap	#14			;soundcmd()
		addq.l	#6,SP

		move.w	2(A4),-(SP)
		move.w	#1,-(SP)
		move.w	#130,-(SP)		;old right output level
		trap	#14			;soundcmd()
		addq.l	#6,SP

		move.w	4(a4),d0
		lsr.w	#4,d0
		move.w	d0,lgain

		move.w	4(A4),-(SP)
		move.w	#2,-(SP)
		move.w	#130,-(SP)		;old left input level
		trap	#14			;soundcmd()
		addq.l	#6,SP

		move.w	6(a4),d0
		lsr.w	#4,d0
		move.w	d0,rgain

		move.w	6(A4),-(SP)
		move.w	#3,-(SP)
		move.w	#130,-(SP)		;old right input level
		trap	#14			;soundcmd()
		addq.l	#6,SP

		move.w	#1,-(SP)
		move.w	#4,-(SP)
		move.w	#130,-(SP)		;adder input from ADC
		trap	#14			;soundcmd()
		addq.l	#6,SP

		move.w	#0,-(SP)
		move.w	#5,-(SP)
		move.w	#130,-(SP)		;ADC input microphone
		trap	#14			;soundcmd()
		addq.l	#6,SP

		move.w	#1,-(sp)
		move.w	#1,-(sp)
		move.w	#137,-(sp)		;dsptristate(1,1);
		trap	#14
		addq.l	#6,sp

		move.w	#1,-(SP)
		move.w	#132,-(SP)
		trap	#14			;setmode(1);
		addq.l	#4,SP

		move.w	#1,-(SP)
		move.w	#2,-(SP)
		move.w	#0,-(SP)
		move.w	#0,-(SP)
		move.w	#0,-(SP)
		move.w	#139,-(SP)
		trap	#14			;devconnect(DMAPLAY, 0, CLK_25M, 2, 1)
		lea	$C(SP),SP		;32780 Hz. My 'Atari Developers Documentation' says 33880 Hz,
						;but I think that this is an error. (25175000 Hz/256/(2+1)=32780 Hz)

		move.w	#1,-(SP)
		move.w	#2,-(SP)
		move.w	#0,-(SP)
		move.w	#0,-(SP)
		move.w	#1,-(SP)
		move.w	#139,-(SP)
		trap	#14			;devconnect(DSPXMIT, 0, CLK_25M, 2, 1)
		lea	$C(SP),SP

		move.w	#1,-(SP)
		move.w	#2,-(SP)
		move.w	#0,-(SP)
		move.w	#0,-(SP)
		move.w	#2,-(SP)
		move.w	#139,-(SP)
		trap	#14			;devconnect(EXTINP, 0, CLK_25M, 2, 1)
		lea	$C(SP),SP

		move.w	#1,-(SP)
		move.w	#2,-(SP)
		move.w	#0,-(SP)
		move.w	#2,-(SP)
		move.w	#3,-(SP)
		move.w	#139,-(SP)
		trap	#14			;devconnect(ADC, DSPRECV, CLK_25M, 2, 1)
		lea	$C(SP),SP

		clr.w	-(SP)
		move.w	#136,-(SP)
		trap	#14			;buffoper(0);
		addq.l	#4,SP

		rts

restore_sound:

		move.w	old_speaker,speaker
		bsr	set_speaker

		;move.w #1,-(SP)
		;move.w #140,-(SP)		;sndstatus(1)
		;trap	#14
		;addq.l #4,SP

		move.w	#0,-(sp)
		move.w	#0,-(sp)
		move.w	#137,-(sp)		;dsptristate(0,0);
		trap	#14
		addq.l	#6,sp

		clr.w	D4
		clr.w	D5
		move.l	#old_sndstate,A4
get_snd:	move.w	(A4,D5),-(SP)
		move.w	D4,-(SP)
		move.w	#130,-(SP)		;soundcmd()
		trap	#14
		addq.l	#6,SP

		addq.w	#2,D5
		addq.w	#1,D4
		cmp.w	#7,D4
		bne	get_snd

		move.w	#105,-(SP)
		trap	#14			;Dsp_Unlock()
		addq.l	#2,SP

		move.w	#129,-(SP)
		trap	#14			;unlocksnd()
		addq.l	#2,SP

		rts

dsp_locked:
		move.w	#129,-(SP)
		trap	#14			;unlocksnd()
		addq.l	#2,SP

		lea	dsp_locked_txt,a0
		bra	error

snd_locked:
		lea	snd_locked_txt,a0
		bra	error

outofmem:
		lea	outofmem_txt,a0
		bra	error


OutOfDSPMem:	move.w	#105,-(SP)
		trap	#14			;Dsp_Unlock()
		addq.l	#2,SP

		move.w	#129,-(SP)
		trap	#14			;unlocksnd()
		addq.l	#2,SP

		lea	outofmem_txt2,a0
		bra	error

wrong_machine:
		lea	wrong_mach_txt,a0
		bra	error

wrong_scr:
		lea	wrong_scr_txt,a0
		bra	error

better_buy_vga:
		move.w	#0,d0
		bsr	graf_mouse
		lea	better_vga_txt,a0
		move.w	#1,d0
		bsr	form_alert
		rts

exit:
		bsr	appl_exit

		; Kbshift(-1)
		move.w	#-1,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.l	#4,sp

		move.w	old_capslock,d1
		lsl.w	#4,d1
		bclr	#4,d0
		or.w	d1,d0

		; Kbshift()
		move.w	d0,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.l	#4,sp

		; Pterm0()
		clr.w	-(SP)
		trap	#1

;alert string in a0
error:
		move.l	a0,a6
		move.w	#0,d0			;arrow
		bsr	graf_mouse
		move.l	a6,a0
		move.w	#1,d0
		bsr	form_alert
		bra	exit


appl_init:	lea	contrl,a0
		move.w	#10,(a0)
		move.w	#0,2(a0)
		move.w	#1,4(a0)
		move.w	#0,6(a0)
		move.w	#0,8(a0)
		move.l	#aespb,d1
		move.w	#200,d0			;aes
		trap	#2			;gem
		move.w	int_out,d0
		rts

appl_exit:	lea	contrl,a0
		move.w	#19,(a0)
		move.w	#0,2(a0)
		move.w	#1,4(a0)
		move.w	#0,6(a0)
		move.w	#0,8(a0)
		move.l	#aespb,d1
		move.w	#200,d0
		trap	#2
		move.w	int_out,d0
		rts

;string in a0
;def_but in d0
form_alert:	lea	contrl,a1
		move.w	#52,(a1)
		move.w	#1,2(a1)
		move.w	#1,4(a1)
		move.w	#1,6(a1)
		move.w	#0,8(a1)
		move.l	a0,addr_in
		move.w	d0,int_in
		move.l	#aespb,d1
		move.w	#200,d0
		trap	#2
		move.w	int_out,d0
		rts

;mnumber in d0
graf_mouse:	lea	contrl,a0
		move.w	#78,(a0)
		move.w	#1,2(a0)
		move.w	#1,4(a0)
		move.w	#1,6(a0)
		move.w	#0,8(a0)
		move.w	d0,int_in
		move.l	#0,addr_in
		move.l	#aespb,d1
		move.w	#200,d0
		trap	#2
		move.w	int_out,d0
		rts



decode_imgs:
		lea	mainscrdat,a0
		move.l	scr2,dest
		bsr	dec_img
		lea	iconsdat,a0
		move.l	icons,dest
		bsr	dec_img
		lea	mousedat,a0
		move.l	mousedata,dest
		bsr	dec_img
		lea	helpdat,a0
		move.l	helpdiag,dest
		bsr	dec_img
		rts

dec_img:
		move.w	6(a0),patt_len
		moveq	#0,d0
		move.w	12(a0),d0
		lsr.l	#3,d0			;bytes per line per plane
		move.l	d0,bperlineplane
		lsl.l	#2,d0			;*planes
		move.l	d0,bytesperline
		move.w	14(a0),lines
		move.w	2(a0),d0		;header length in words
		add.w	d0,d0			;header length in bytes
		add.w	d0,a0

		move.w	#0,repeat
		move.w	lines,d7
		subq.w	#1,d7
loop_y:
		move.w	repeat,d0
		bne	do_repeat

		bsr	plane
		add.l	#2,dest
		bsr	plane
		add.l	#2,dest
		bsr	plane
		add.l	#2,dest
		bsr	plane
		move.l	bytesperline,d0
		subq.l	#6,d0
		add.l	d0,dest

		bra	no_repeat
do_repeat:
		subq.w	#1,d0
		move.w	d0,repeat
		move.l	dest,a2
		move.l	a2,a3
		sub.l	bytesperline,a3
		move.l	bytesperline,d0
		lsr.l	#1,d0
		subq.w	#1,d0
loop_rep:
		move.w	(a3)+,(a2)+
		dbra	d0,loop_rep
		move.l	bytesperline,d0
		add.l	d0,dest
no_repeat:
		dbra	d7,loop_y

		rts
plane:
		lea	linebuf,a1
		bsr	read_line
		move.l	dest,a2
		lea	linebuf,a1
		move.w	#39,d0
loop_x:		move.w	(a1)+,(a2)
		addq.l	#8,a2
		dbra	d0,loop_x
		rts

read_line:
		move.b	(a0)+,d0
		bne	no_null

		move.b	(a0)+,d0
		bne	pattern

		;replication
		move.b	(a0)+,d0

		moveq	#0,d0
		move.b	(a0)+,d0
		subq.w	#1,d0
		move.w	d0,repeat
		move.l	a1,d0
		bra	read_line
no_null:
		cmp.b	#$80,d0
		bne	solid_run

		;bit_string

		moveq	#0,d0
		move.b	(a0)+,d0
		subq.w	#1,d0
loop_bs:
		move.b	(a0)+,(a1)+
		dbra	d0,loop_bs
		bra	end_rout
solid_run:
		move.b	d0,d1
		and.b	#$80,d1
		sne	d1
		and.w	#$7f,d0
		subq.w	#1,d0
loop_sr:
		move.b	d1,(a1)+
		dbra	d0,loop_sr
		bra	end_rout
pattern:
		move.w	patt_len,d1
		subq.w	#1,d1
		and.w	#$ff,d0
		subq.w	#1,d0
loop_p1:
		move.l	a0,a2
		move.w	d1,d2
loop_p2:
		move.b	(a2)+,(a1)+
		dbra	d2,loop_p2
		dbra	d0,loop_p1

		addq.w	#1,d1
		add.w	d1,a0
end_rout:
		move.l	a1,d0
		sub.l	#linebuf,d0
		cmp.l	bperlineplane,d0
		blt	read_line
		rts



init_mouse:
		move.w	#320,mouse_x
		move.w	#240,mouse_y
		clr.w	mbut
		move.w	#-1,old_mouse_x		;no restore 1st time
		clr.w	new_scr			;no set screen
		clr.w	curr_mouse		;full mouse
		move.l	$ffff9800+11*4,link_col	;color for link buttons

		lea	mousemask,a0
		move.l	mousedata,a2
		move.w	#16*16-1,d0
loop_make_mask:
		move.w	(a2)+,d1
		or.w	(a2)+,d1
		or.w	(a2)+,d1
		or.w	(a2)+,d1
		move.w	d1,(a0)+
		dbra	d0,loop_make_mask

		move.w	#$22,-(sp)		;Kbdvbase()
		trap	#14
		addq.l	#2,sp
		move.l	d0,a0

		move.l	16(a0),old_mousevec
wait_drvstat:
		tst.w	36(a0)
		bne	wait_drvstat

		move.l	#mousevec,16(a0)

		move.l	$70,old_vbl_int
		move.l	#vbl_interrupt,$70

		rts

exit_mouse:
		move.l	old_vbl_int,$70

		move.w	#$22,-(sp)		;Kbdvbase()
		trap	#14
		addq.l	#2,sp
		move.l	d0,a0

wait_drvstat2:
		tst.w	36(a0)
		bne	wait_drvstat2

		move.l	old_mousevec,16(a0)

		rts

draw_mouse:
		move.w	mouse_x,d6
		move.w	mouse_y,d5
		move.w	d5,old_mouse_y
		move.w	d6,old_mouse_x

		move.l	mousedata,a1
		move.w	curr_mouse,d0
		lsr.w	#1,d0
		lsl.w	#7,d0			;*16*(16/8*2)
		add.w	d0,a1
		move.l	a1,a2

		move.l	scr2,a0
		move.l	a0,old_mouse_scr
		move.w	d5,d0		;my
		move.w	d0,d2
		mulu.w	#b_line,d0
		add.l	d0,a0

		move.w	d6,d4		;mx
		move.w	d4,d0
		lsr.w	#4,d4		;in words
		lsl.w	#3,d4		;*planes *2

		add.w	d4,a0

		move.w	d0,d1
		and.b	#$f0,d1
		sub.w	d1,d0

		move.w	#15,d3
		add.w	#16-480,d2
		bmi	cont_m1
		sub.w	d2,d3
cont_m1:
		lea	mousemask,a2
		move.w	curr_mouse,d7
		lsr.w	#1,d7
		lsl.w	#5,d7
		add.w	d7,a2
		lea	mousesaved,a3

		tst.w	d0
		beq	loop_putm_noshift

		cmp.w	#b_line-8,d4
		bge	last_word1
loop_putm:
		REPT	4
		move.w	8(a0),d7
		swap	d7
		move.w	(a0)+,d7
		rol.l	d0,d7
		move.w	d7,(a3)+
		ENDM
		sub.w	#8,a0

		moveq	#0,d7
		move.w	(a2)+,d7
		ror.l	d0,d7
		not.l	d7
		and.w	d7,(a0)
		and.w	d7,2(a0)
		and.w	d7,4(a0)
		and.w	d7,6(a0)
		swap	d7
		and.w	d7,8(a0)
		and.w	d7,10(a0)
		and.w	d7,12(a0)
		and.w	d7,14(a0)

		REPT	4
		moveq	#0,d7
		move.w	(a1)+,d7
		ror.l	d0,d7
		or.w	d7,(a0)+
		swap	d7
		or.w	d7,6(a0)
		ENDM

		add.w	#b_line-8,a0
		dbra	d3,loop_putm

		bra	end_putm

last_word1:
loop_putm2:
		REPT	4
		moveq	#0,d7
		move.w	(a0)+,d7
		rol.l	d0,d7
		move.w	d7,(a3)+
		ENDM
		sub.w	#8,a0

		moveq	#0,d7
		move.w	(a2)+,d7
		ror.l	d0,d7
		not.l	d7
		and.w	d7,(a0)
		and.w	d7,2(a0)
		and.w	d7,4(a0)
		and.w	d7,6(a0)

		REPT	4
		moveq	#0,d7
		move.w	(a1)+,d7
		ror.l	d0,d7
		or.w	d7,(a0)+
		ENDM

		add.w	#b_line-8,a0
		dbra	d3,loop_putm2
		bra	end_putm
loop_putm_noshift:
		move.l	(a0),(a3)+
		move.l	4(a0),(a3)+

		move.w	(a2)+,d7
		not.w	d7
		and.w	d7,(a0)
		and.w	d7,2(a0)
		and.w	d7,4(a0)
		and.w	d7,6(a0)

		move.l	(a1)+,d7
		or.l	d7,(a0)+
		move.l	(a1)+,d7
		or.l	d7,(a0)+

		add.w	#b_line-8,a0
		dbra	d3,loop_putm_noshift

end_putm:
		rts

remove_mouse:
		move.w	old_mouse_x,d6
		move.w	old_mouse_y,d5
		cmp.w	#-1,d6
		beq	end_remm

		move.l	old_mouse_scr,a0
		move.w	d5,d0		;omy
		move.w	d0,d2
		mulu.w	#b_line,d0
		add.l	d0,a0

		move.w	d6,d4		;omx
		move.w	d4,d0
		lsr.w	#4,d4
		lsl.w	#2,d4		;*planes
		add.w	d4,d4		;in bytes

		add.w	d4,a0

		move.w	d0,d1
		and.w	#$fff0,d1
		sub.w	d1,d0

		move.w	#15,d3
		add.w	#16-480,d2
		bmi	cont_rm1
		sub.w	d2,d3
cont_rm1:
		lea	mousesaved,a1
		tst.w	d0
		beq	loop_remm_noshift
		move.l	#$ffff0000,d7	;mask
		ror.l	d0,d7
loop_remm:
		and.w	d7,(a0)
		and.w	d7,2(a0)
		and.w	d7,4(a0)
		and.w	d7,6(a0)
		cmp.w	#b_line-8,d4
		bge	cont_rm3
		swap	d7
		and.w	d7,8(a0)
		and.w	d7,10(a0)
		and.w	d7,12(a0)
		and.w	d7,14(a0)
		swap	d7
cont_rm3:
		move.w	#3,d6
loop_remm2:
		moveq	#0,d5
		move.w	(a1)+,d5
		ror.l	d0,d5
		or.w	d5,(a0)+
		cmp.w	#b_line-8,d4
		bge	cont_rm2
		swap	d5
		or.w	d5,6(a0)
cont_rm2:
		dbra	d6,loop_remm2

		add.w	#b_line-8,a0
		dbra	d3,loop_remm

		bra	end_remm
loop_remm_noshift:
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

		add.w	#b_line-8,a0
		dbra	d3,loop_remm_noshift
end_remm:

		rts

		dc.l	'XBRA'
		dc.l	'MOUS'
old_mousevec:	ds.l	1
mousevec:
		move.w	d0,-(sp)
		move.b	1(a0),d0
		ext.w	d0
		add.w	mouse_x,d0
		bge	cont_mv1
		clr.w	d0
cont_mv1:	cmp.w	#639,d0
		ble	cont_mv2
		move.w	#639,d0
cont_mv2:	move.w	d0,mouse_x
		move.b	2(a0),d0
		ext.w	d0
		add.w	mouse_y,d0
		bge	cont_mv3
		clr.w	d0
cont_mv3:	cmp.w	#479,d0
		ble	cont_mv4
		move.w	#479,d0
cont_mv4:	move.w	d0,mouse_y
		move.b	(a0),d0
		and.w	#3,d0
		move.w	d0,mbut
		move.w	(sp)+,d0
		rts

		dc.l	'XBRA'
		dc.l	'MOUS'
old_vbl_int:	ds.l	1
vbl_interrupt:
		movem.l	d0-d7/a0-a3,-(sp)

		move.l	link_col,$ffff9800+13*4

		move.w	mouse_x,d6
		move.w	mouse_y,d5

		tst.w	mbut			;mousebutton pressed?
		bne	m_not_same		;don't fade out

		cmp.w	old_mouse_x,d6		;
		bne	m_not_same		;
		cmp.w	old_mouse_y,d5		;mouse moved?
		bne	m_not_same		;don't fade out

		add.w	#1,mouse_count
		move.w	mouse_count,d0
		cmp.w	#100,d0			;100 vbl's
		ble	m_same
		move.w	curr_mouse,d0
		cmp.w	#30,d0
		beq	m_same
		add.w	#1,curr_mouse		;fade out

		bra	m_same
m_not_same:
		clr.w	mouse_count		;wait for 100 vbl's again
		clr.w	curr_mouse		;full pointer again
m_same:
		bsr	remove_mouse

		tst.w	new_scr
		beq	no_new_scr

		move.l	scr1,A0
		move.l	scr2,scr1
		move.l	A0,scr2			;swap pointers
		move.l	scr1,scr

		move.l	scr2,d0
		swap	d0
		move.b	d0,$ffff8201
		rol.l	#8,d0
		move.b	d0,$ffff8203
		rol.l	#8,d0
		move.b	d0,$ffff820d
		clr.l	new_scr			;not again
no_new_scr:

		bsr	draw_mouse

		movem.l	(sp)+,d0-d7/a0-a3
		add.l	#1,_frclock		;don't forget this!
		rte



		data


wrong_scr_txt:	dc.b	'[3][Sorry...|Music Analyzer cannot|run on a monochrome monitor][Exit]',0
snd_locked_txt: dc.b	'[3][Sound System locked !][Exit]',0
dsp_locked_txt: dc.b	'[3][DSP locked !][Exit]',0
outofmem_txt:	dc.b	'[3][Out of memory !][Exit]',0
outofmem_txt2:	dc.b	'[3][Out of DSP memory !][Exit]',0
wrong_mach_txt: dc.b	'[3][Sorry...|Music Analyzer can only run|on an Atari 680x0 (x>=3)|machine with DSP, Codec and|Connection Matrix (a Falcon!)][Exit]',0
better_vga_txt:	dc.b	'[1][If you want this program|to look even better|(or just wanna read the|texts), buy yourself a|VGA monitor !][ ... ]',0

		even


		;Use the linker
		IMPORT	log, log2, dsp_bin, end_of_dspbin
		IMPORT	mainscrdat, iconsdat, mousedat, helpdat

		;When you don't use a linker
;		even
;		include	'log_vu.s'
;		even
;		include	'log_spec.s'
;		even
;		include	'dsp_bin.s'
;		even
;mainscrdat:	incbin	'mainscr.img'
;		even
;helpdat:	incbin	'help.img'
;		even
;iconsdat:	incbin	'icons.img'
;		even
;mousedat:	incbin	'mouse.img'
;		even


;relative coordinates for vu
;0 to 90 degrees
vu_x:		DC.W	-31,-31,-30,-29,-29,-28,-28,-27
		DC.W	-26,-26,-25,-25,-24,-23,-23,-22
		DC.W	-21,-21,-20,-19,-19,-18,-17,-16
		DC.W	-16,-15,-14,-14,-13,-12,-11,-11
		DC.W	-10,-9,-8,-8,-7,-6,-5,-5
		DC.W	-4,-3,-2,-2,-1, 0, 1, 2
		DC.W	 2, 3, 4, 5, 5, 6, 7, 8
		DC.W	 8, 9, 10, 11, 11, 12, 13, 14
		DC.W	 14, 15, 16, 16, 17, 18, 19, 19
		DC.W	 20, 21, 21, 22, 23, 23, 24, 25
		DC.W	 25, 26, 26, 27, 28, 28, 29, 29
		DC.W	 30, 31, 31
vu_y:		DC.W	-31,-32,-32,-33,-33,-34,-34,-35
		DC.W	-35,-36,-36,-36,-37,-37,-38,-38
		DC.W	-38,-39,-39,-40,-40,-40,-41,-41
		DC.W	-41,-41,-42,-42,-42,-42,-43,-43
		DC.W	-43,-43,-43,-43,-43,-44,-44,-44
		DC.W	-44,-44,-44,-44,-44,-44,-44,-44
		DC.W	-44,-44,-44,-44,-44,-44,-43,-43
		DC.W	-43,-43,-43,-43,-43,-42,-42,-42
		DC.W	-42,-41,-41,-41,-41,-40,-40,-40
		DC.W	-39,-39,-38,-38,-38,-37,-37,-36
		DC.W	-36,-36,-35,-35,-34,-34,-33,-33
		DC.W	-32,-32,-31


vga_mode:	dc.w	%111010
tv60_mode:	dc.w	%100001010
tv50_mode:	dc.w	%100101010

;640*480, 16 col
;Vsetmode(-1) =$003A %0000000000111010
vidregs_vga:
 		dc.b	$02	; (=%00000010) $FFFF820A
		dc.b	$00	; (=%00000000) $FFFF8260
		dc.w	$0000	; (=%0000000000000000) $FFFF8266
		dc.w	$00C6	; (=%0000000011000110) $FFFF8282
		dc.w	$0096	; (=%0000000010010110) $FFFF828C
		dc.w	$0415	; (=%0000010000010101) $FFFF82AC
		dc.w	$0186	; (=%0000000110000110) $FFFF82C0
		dc.w	$0008	; (=%0000000000001000) $FFFF82C2
		dc.w	$008D	; (=%0000000010001101) $FFFF8284
		dc.w	$0015	; (=%0000000000010101) $FFFF8286
		dc.w	$02A3	; (=%0000001010100011) $FFFF8288
		dc.w	$007C	; (=%0000000001111100) $FFFF828A
		dc.w	$0419	; (=%0000010000011001) $FFFF82A2
		dc.w	$03FF	; (=%0000001111111111) $FFFF82A4
		dc.w	$003F	; (=%0000000000111111) $FFFF82A6
		dc.w	$003F	; (=%0000000000111111) $FFFF82A8
		dc.w	$03FF	; (=%0000001111111111) $FFFF82AA
		dc.w	$00A0	; (=%0000000010100000) $FFFF8210

;640*480 (changed from 640*400), 16 col, 50 Hz
;Vsetmode(-1) =$012A %0000000100101010
vidregs_tv50:
		dc.b	$02	; (=%00000010) $FFFF820A
		dc.b	$00	; (=%00000000) $FFFF8260
		dc.w	$0000	; (=%0000000000000000) $FFFF8266
		dc.w	$01FE	; (=%0000000111111110) $FFFF8282
		dc.w	$01B2	; (=%0000000110110010) $FFFF828C
		dc.w	$026B	; (=%0000001001101011) $FFFF82AC
		dc.w	$0181	; (=%0000000110000001) $FFFF82C0
		dc.w	$0006	; (=%0000000000000110) $FFFF82C2
		dc.w	$0199	; (=%0000000110011001) $FFFF8284
		dc.w	$0050	; (=%0000000001010000) $FFFF8286
		dc.w	$004D	; (=%0000000001001101) $FFFF8288
		dc.w	$00FE	; (=%0000000011111110) $FFFF828A
		dc.w	$0270	; (=%0000001001110000) $FFFF82A2
		dc.w	$0265	; (=%0000001001100101) $FFFF82A4
		dc.w	$002F	; (=%0000000000101111) $FFFF82A6
		dc.w	$56   ;$007E	; (=%0000000001111110) $FFFF82A8
		dc.w	$236  ;$020E	; (=%0000001000001110) $FFFF82AA
		dc.w	$00A0	; (=%0000000010100000) $FFFF8210

;640*480 (changed from 640*400), 16 col, 60 Hz
;Vsetmode(-1) =$010A %0000000100001010
vidregs_tv60:
		dc.b	$00	; (=%00000000) $FFFF820A
		dc.b	$00	; (=%00000000) $FFFF8260
		dc.w	$0000	; (=%0000000000000000) $FFFF8266
		dc.w	$01FF	; (=%0000000111111111) $FFFF8282
		dc.w	$01B4	; (=%0000000110110100) $FFFF828C
		dc.w	$0207	; (=%0000001000000111) $FFFF82AC
		dc.w	$0181	; (=%0000000110000001) $FFFF82C0
		dc.w	$0006	; (=%0000000000000110) $FFFF82C2
		dc.w	$0197	; (=%0000000110010111) $FFFF8284
		dc.w	$0050	; (=%0000000001010000) $FFFF8286
		dc.w	$004D	; (=%0000000001001101) $FFFF8288
		dc.w	$00FD	; (=%0000000011111101) $FFFF828A
		dc.w	$020C	; (=%0000001000001100) $FFFF82A2
		dc.w	$0201	; (=%0000001000000001) $FFFF82A4
		dc.w	$0016	; (=%0000000000010110) $FFFF82A6
		dc.w	$24   ;$004C	; (=%0000000001001100) $FFFF82A8
		dc.w	$204  ;$01DC	; (=%0000000111011100) $FFFF82AA
		dc.w	$00A0	; (=%0000000010100000) $FFFF8210

aespb:		dc.l	contrl,global,int_in,int_out,addr_in,addr_out

		bss

mouse_x:	ds.w	1
mouse_y:	ds.w	1
mouse_but:	ds.w	1
old_mouse_x:	ds.w	1
old_mouse_y:	ds.w	1
curr_mouse:	ds.w	1
mousedata:	ds.l	1
mousemask:	ds.w	16*16
mousesaved:	ds.w	16*4
new_scr:	ds.w	1
old_mouse_scr:	ds.l	1
mouse_count:	ds.w	1
mbut:		ds.w	1
link_col:	ds.l	1

linebuf:	ds.b	80
dest:		ds.l	1
patt_len:	ds.w	1
repeat:		ds.w	1
bytesperline:	ds.l	1
bperlineplane:	ds.l	1
lines:		ds.w	1

int_in:		ds.w	16
int_out:	ds.w	7
contrl:		ds.w	5
global:		ds.w	15
addr_in:	ds.l	2
addr_out:	ds.l	1

icon1x:		ds.w	1
icon1y:		ds.w	1
icon1n:		ds.w	1
icon2x:		ds.w	1
icon2y:		ds.w	1
icon2n:		ds.w	1

scr1:		ds.l	1
scr2:		ds.l	1
scr:		ds.l	1
scopebuf:	ds.l	1
icons:		ds.l	1
vubuf:		ds.l	1
helpdiag:	ds.l	1
helpdiag_on:	ds.w	1
hdiagsave:	ds.l	1
restdiag_count:	ds.w	1
mstexts:	ds.l	1
mstxtwhich:	ds.w	1
freeze:		ds.w	1
buf:		ds.b	6
leftbuf:	ds.b	points*3
rightbuf:	ds.b	points*3
leftbufsm:	ds.b	points*3
rightbufsm:	ds.b	points*3
buf2:		ds.b	14*3*2
left_bars:	ds.w	14
right_bars:	ds.w	14
leftvu: 	ds.w	1
rightvu:	ds.w	1
old_sndstate:	ds.w	7
old_speaker:	ds.w	1
palet:		ds.l	16
old_palet:	ds.l	256
old_stpalet:	ds.w	16
ability:	ds.w	1
xmem:		ds.l	1
ymem:		ds.l	1
sendbuf:	ds.l	1
lgain:		ds.w	1
rgain:		ds.w	1
speaker:	ds.w	1
leftspect:	ds.w	14
rightspect:	ds.w	14
shift:		ds.w	1
old_mode:	ds.w	1
old_regs:	ds.w	20
old_scrlen:	ds.l	1
old_physscr: 	ds.l	1
old_logscr: 	ds.l	1
monitor:	ds.w	1
pal:		ds.w	1
old_hz200:	ds.l	1
oldconterm:	ds.w	1
old_superstack:	ds.l	1
old_capslock:	ds.w	1

		end
